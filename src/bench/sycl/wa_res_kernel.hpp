// wa_res_kernel.hpp -- section 100 P10: the window_attention RESIDENT block.
// One WG = one batch (window x head): scores gemm (the promoted f16v2 gemm_b2<64>
// loop VERBATIM) -> the accumulator staged into SLM Z (the gemm_b_pub_slm
// untouched-store pattern) -> softmax reads 64 rows from SLM, writes e4m3 probs
// into Y in the pack_a16 block map (the smax_esimd math VERBATIM) -> attnV
// consumes A from Y directly (the tile8s pattern; its B re-stages through the
// now-dead X operand slots) with the P9 merge-fold store. dScores (16KB/batch
// f32) and dProbs+dAp (8KB/batch half) NEVER touch global; 2 launches fold away.
// SLM = 8 (X ops) + 16 (Z scores) + 8 (Y probs) = 32KB at LW=16 (gemm_b2<64>'s
// NT -- NOT the 64/128 hazard lines). Stage 3 runs the gemm_b2<32> NT=8 band
// map on all 16 threads (threads 8..15 duplicate 0..7: identical work, identical
// stores -- the barrier counts stay EVEN, the P3c discipline). bench_wa_res at
// the frame shape (batches=1020 heads=2): 9.2x vs the promoted split, EXACT.
// Guards (recorder): merged==1, bias present-or-null both fine (the map handles
// null), tokens==64, heads*32==channels. Escape NR_WA_RES=0 -> the P4c/P9 chain.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"

namespace wares {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

#define WA_X 0u
#define WA_Z 8192u
#define WA_Y 24576u
#define WA_SLM 32768u

// dAq/dBk/dBv are the recorder's PRE-PACKED operands (the promoted pack passes
// stay -- this fold kills the MIDDLE buffers dScores/dProbs/dAp and the two
// middle launches, not the operand packs). Out = the merged (windows,64,CH) half.
static inline event launch_wa_res(queue& q, const half* dAq, const half* dBk, const half* dBv,
                                  const float* dBias, half* Out, unsigned batches, unsigned heads) {
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)batches * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<WA_SLM>();
            uint b  = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            // ===== stage 1: scores gemm (the gemm_b2<64> loop VERBATIM; BM=64,BN=64,
            // BK=16; NT=16: WIR=4, WIC=4; ACH=(64*16)/16=64, BCH=(16*64)/16=64) =====
            const int TS = 16, BM = 64, BN = 64, BK = 16;
            const int SLM_A = BM*BK*2, SLM_B = BK*BN*2, SLM_B_BASE = 2*SLM_A;
            const int ACH = (BM*BK)/16, BCH = (BK*BN)/16;
            const int kb_n = 32/BK;             // 2
            const half* Ab = dAq + (size_t)b * 64 * 32;
            const half* Bb = dBk + (size_t)b * 32 * 64;
            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                #pragma unroll
                for (int i = 0; i < ACH / 64; ++i) {
                    int la = lid * ACH + i * 64;
                    int trl = la / 256, within = la % 256;
                    esimd::simd<half,64> v = esimd::block_load<half,64>(
                        Ab + ((size_t)((trl) * kb_n + kc) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(WA_X + buf * SLM_A + la * 2, v, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < BCH / 64; ++i) {
                    int lb = lid * BCH + i * 64;
                    int tcl = lb / 256, within = lb % 256;
                    esimd::simd<half,64> v = esimd::block_load<half,64>(
                        Bb + ((size_t)(kc * 4 + (tcl)) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(WA_X + SLM_B_BASE + buf * SLM_B + lb * 2, v, esimd::overaligned_tag<16>{});
                }
            };
            int wi_row = lid / 4, wi_col = lid % 4;
            esimd::simd<float,64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            load_block(0, 0);
            esimd::barrier();
            for (int kb = 0; kb < kb_n; ++kb) {
                int cur = kb & 1, nxt = cur ^ 1;
                if (kb + 1 < kb_n) load_block(nxt, kb + 1);
                uint32_t offA = WA_X + cur * SLM_A + wi_row * (TS * BK * 2);
                uint32_t offB = WA_X + SLM_B_BASE + cur * SLM_B + wi_col * (TS * BK * 2);
                esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                esimd::barrier();
            }
            // stage the scores into Z (the pub_slm C-stage: fragments -> SLM f32,
            // the tile's own row-major map (wi_row band r, wi_col band 16 cols))
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16)) * 4u,
                    c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c01.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16)) * 4u,
                    c10.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(WA_Z + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c11.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            
            // ===== stage 2: softmax, 4 rows per thread (the smax_esimd math VERBATIM;
            // the row source = Z (SLM), the probs dest = Y in the pack_a16 map) =====
            for (int rr = 0; rr < 4; ++rr) {
                uint row = lid * 4u + rr;                    // local row in the batch
                uint rgl = b * 64u + row;                    // the global row (bias map)
                esimd::simd<float,32> s0 = esimd::slm_block_load<float,32>(WA_Z + row * 256u, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> s1 = esimd::slm_block_load<float,32>(WA_Z + row * 256u + 128u, esimd::overaligned_tag<16>{});
                size_t boff = ((size_t)(rgl / 64u) % (size_t)heads) * 4096u + (size_t)(rgl % 64u) * 64u;
                esimd::simd<float,32> b0v = esimd::block_load<float,32>(dBias + boff, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> b1v = esimd::block_load<float,32>(dBias + boff + 32, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0v));
                esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1v));
                esimd::simd<float,32> a0v = esimd::convert<float>(esimd::convert<sycl::half>(
                    hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                esimd::simd<float,32> a1v = esimd::convert<float>(esimd::convert<sycl::half>(
                    hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                a0v = (esimd::min)((esimd::max)(a0v, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                a1v = (esimd::min)((esimd::max)(a1v, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                esimd::simd<sycl::half,16> he0=esimd::convert<sycl::half>(a0v.template select<16,2>(0).read());
                esimd::simd<sycl::half,16> ho0=esimd::convert<sycl::half>(a0v.template select<16,2>(1).read());
                esimd::simd<sycl::half,16> he1=esimd::convert<sycl::half>(a1v.template select<16,2>(0).read());
                esimd::simd<sycl::half,16> ho1=esimd::convert<sycl::half>(a1v.template select<16,2>(1).read());
                esimd::simd<uint16_t,16> e0=he0.bit_cast_view<uint16_t>(), o0=ho0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> e1=he1.bit_cast_view<uint16_t>(), o1=ho1.bit_cast_view<uint16_t>();
                esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
                esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
                esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<sycl::half,32> w0; w0=t0.bit_cast_view<sycl::half>();
                esimd::simd<sycl::half,32> w1; w1=t1.bit_cast_view<sycl::half>();
                esimd::simd<float,32> f0 = esimd::convert<float>(w0);
                esimd::simd<float,32> f1 = esimd::convert<float>(w1);
                float total = 0.0f;
                for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
                for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));
                esimd::simd<sycl::half,32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
                esimd::simd<sycl::half,32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
                // pack_a16 store into Y: tr=row/16, strip=(row%16)/8, il=row%8;
                // dest((tr*4+kc)*2+strip)*128 + il*16 + k16 (halfs)
                uint trr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                uint base = WA_Y + ((trr * 4u + 0u) * 2u + strip) * 256u + il * 32u;   // BYTES: block(tr,0)=(tr*4)*512; strip +256; il*16 half = il*32 B
                esimd::simd<half,16> q0 = oh0.template select<16,1>(0), q1 = oh0.template select<16,1>(16);
                esimd::simd<half,16> q2 = oh1.template select<16,1>(0), q3 = oh1.template select<16,1>(16);
                esimd::slm_block_store(base, q0, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 512u, q1, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 1024u, q2, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(base + 1536u, q3, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            
            // ===== stage 3: attnV (BN=32: gemm_b2<32> geometry, NT=8 -> threads 0..7;
            // A from Y (SLM, the tile8s pattern), B from global dBv, merge-fold store) =====
            {
                const int SLM_B2 = BK*32*2;                 // 1024
                const int BCH2 = (BK*32)/8;                 // 64
                int t8 = (int)lid % 8;
                const half* Bb2 = dBv + (size_t)b * 64 * 32;
                int tr2 = t8 / 2, tc2 = t8 % 2;
                auto load_block2 = [&](int buf, int kc) SYCL_ESIMD_FUNCTION {
                    // A: this WG's probs live in Y ALREADY in the pack_a16 block map --
                    // gemm_b2's load_block stages A blocks (tr,kc) into SLM_A; here the
                    // A block (tr2,kc) IS at Y ((tr2*4+kc)*2+strip)*128: the tile8s form
                    // reads A fragments DIRECTLY from Y (no restage). B: global pack.
                    #pragma unroll
                    for (int i = 0; i < BCH2 / 64; ++i) {
                        int lb = t8 * BCH2 + i * 64;
                        int tcl = lb / 256, within = lb % 256;
                        esimd::simd<half,64> v = esimd::block_load<half,64>(
                            Bb2 + ((size_t)(kc * 2 + tcl) * 2) * 128 + within, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(WA_X + 4096u + buf * SLM_B2 + lb * 2, v, esimd::overaligned_tag<16>{});
                    }
                };
                esimd::simd<float,64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                load_block2(0, 0);
                esimd::barrier();
                for (int kb = 0; kb < 4; ++kb) {     // K=64: kb_n=4
                    int cur = kb & 1, nxt = cur ^ 1;
                    if (kb + 1 < 4) load_block2(nxt, kb + 1);
                    uint32_t offA = WA_Y + (uint32_t)(((size_t)tr2 * 4u + (size_t)kb) * 2u) * 256u;
                    uint32_t offB = WA_X + 4096u + cur * SLM_B2 + tc2 * (TS * BK * 2);
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                    d00 = esimd::xmx::dpas<8,8,float>(d00, b0, a0);
                    d01 = esimd::xmx::dpas<8,8,float>(d01, b1, a0);
                    d10 = esimd::xmx::dpas<8,8,float>(d10, b0, a1);
                    d11 = esimd::xmx::dpas<8,8,float>(d11, b1, a1);
                    esimd::barrier();
                }
                // merge-fold store (the gemm_b2_merge tail VERBATIM): batch b =
                // window*heads + head; the fragment rows tr2*16 + {r, 8+r}, cols tc2*16+c
                unsigned window = b / heads, head = b % heads;
                const unsigned CH = heads * 32u;
                
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                    esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                    esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                    esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                    esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                    esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                    size_t o0 = (((size_t)window * 64u + (size_t)(tr2 * 16 + r)) * CH
                                 + head * 32u + (unsigned)tc2 * 16u);
                    size_t o2 = (((size_t)window * 64u + (size_t)(tr2 * 16 + 8 + r)) * CH
                                 + head * 32u + (unsigned)tc2 * 16u);
                    h00.copy_to(Out + o0); h01.copy_to(Out + o0 + 8u);
                    h10.copy_to(Out + o2); h11.copy_to(Out + o2 + 8u);
                }
            }   // stage 3 all-16 (8 duplicate bands -- identical work, identical stores)
        });
    });
}
}
