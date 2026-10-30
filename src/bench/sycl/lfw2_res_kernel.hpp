// lfw2_res_kernel.hpp -- B5-5b SLICE 2 (2026-10-30): qkv+attention fused, but
// WG = one (window, head) BATCH -- the wa_res parallelism class (1020-1116 WGs,
// NOT slice 1's 510 fat WGs that serialized the whole chain per WG and lost the
// frame A/B by +0.5). Per WG:
//   phase 1: qkv gemm at BM=64(tokens) x BN=32(head slice) x K=C=64, NT=16,
//            8 row-bands (lid/2) x 2 col-bands (lid%2); the s8v8 double-buffer
//            loop shrunk per qres's map (A blocks = pack_a wi bands 512B, the
//            thread frag = the 8-row HALF of a band, a0 = 256B at rb*256 --
//            IDENTICAL bytes to the NT=32 chain's a0/a1 halves); B = the head's
//            4 pack_b n-tile blocks per kb at (kb*24 + part*8 + hh*4)*256.
//            3 parts (Q,K,V) x kb_n=2 x 2 dpas = 12 dpas.
//   v5a tail (qres VERBATIM tree) per row (64 tasks / 16 threads = 4 each):
//            half_round -> cosine_recip_vec -> mulh -> (Q: *eh_round(qs[hh])) ->
//            e4m3_vec; DOUBLE-WRITES: plane slice at ((w*heads+hh)*64+row)*32
//            (downstream quant chain still reads the planes) + the wa tile:
//            Q -> QT direct (pack_a16_b map), K/V -> Y temp row-major then the
//            blade-7 block-gather -> KT (pack_b16_t_b) / VT (pack_b16_b).
//   phase 2: wa_res stages 1-3 for THIS head VERBATIM (tiles pre-filled by
//            phase 1 -- the Q/K/V RAW GATHERS of wa_res never happen).
// What vanishes vs the split chain: the wa launch (1020 launches), the qkv gemm
// launch (120), the wa operand gathers (QT/KT/VT come from registers/SLM), and
// the Q/K plane WRITE->READ round trip for the attention itself (the planes are
// still written once for the downstream layer chain -- slice 1's bench truth:
// the plan's next-layer quant reads 1274/1275/1276, they cannot disappear yet).
// SLM = the wa_res map EXACTLY (45056: X 8 ops, Z 16 stage->scores, Y 8
// temps->probs, QT/KT/VT 4 each). Judges: bench_lfw2 (same reference chain =
// qres planes + wa_res Out) then the recorder trio + frame A/B.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"

namespace lfw2 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const uint X0 = 0u;        // 8KB: gemm operand double buffers (all gemm stages)
static const uint Z0 = 8192u;     // 16KB: qkv f32 stage (8KB used), then scores 64x64
static const uint Y0 = 24576u;    // 8KB: K/V temps (4KB each), then probs pack_a16
static const uint QT = 32768u;    // 4KB: Q tile (this head)
static const uint KT = 36864u;    // 4KB: K tile
static const uint VT = 40960u;    // 4KB: V tile
static const uint SLMB = 45056u;

// b = windows*heads batches (the wa_res numbering); planes per-plane (M*C halves).
static inline sycl::event launch_lfw2(sycl::queue& q, const int8_t* dAp, const int8_t* dBp,
                                      sycl::half* Out, const float* as, const float* bs,
                                      const float* qs, const float* dBias,
                                      unsigned windows, unsigned heads,
                                      sycl::half* Qp, sycl::half* Kp, sycl::half* Vp) {
    constexpr unsigned C = 64u, NH = 192u, tokens = 64u;
    const unsigned batches = windows * heads;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)batches * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            uint b = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint w = b / heads, hh = b % heads;
            int rb = (int)(lid / 2u);        // 8 row-bands of 8 tokens
            int cb = (int)(lid % 2u);        // 2 col-bands of 16

            // ================= phase 1: qkv gemm x3 parts (BN=32) ================
            #pragma unroll 1
            for (int part = 0; part < 3; ++part) {
                const int SLM_AB = 2048, SLM_BB = 1024;    // bytes per buffer
                const int kb_n = (int)C / 32;              // 2
                const uint band = w / 2u;                  // 128-row pack_a bands
                const uint wioff = (w % 2u) * 2048u;       // second 64 rows of the band
                const int8_t* apb = dAp + (size_t)band * kb_n * 4096u + wioff;
                // B n-tile blocks: global ntiles part*8 + hh*4 + 0..3 per kb slice
                const int8_t* bp = dBp + (size_t)(part * 8u + hh * 4u) * 256u;
                auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int8_t,128> av = esimd::block_load<int8_t,128>(
                        apb + (size_t)kb * 4096u + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_AB + lid * 128u, av, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,64> bv = esimd::block_load<int8_t,64>(
                        bp + (size_t)kb * (NH * 32u) + lid * 64u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(2 * SLM_AB + buf * SLM_BB + lid * 64u, bv, esimd::overaligned_tag<16>{});
                };
                esimd::simd<int32_t,64> c0(0), c1(0);
                load_block(0, 0);
                esimd::barrier();
                #pragma unroll
                for (int kbi = 0; kbi < kb_n; ++kbi) {
                    int cur = kbi & 1, nxt = cur ^ 1;
                    if (kbi + 1 < kb_n) load_block(nxt, kbi + 1);
                    esimd::simd<int8_t,256> a0 = esimd::slm_block_load<int8_t,256>(
                        (uint32_t)(cur * SLM_AB + rb * 256), esimd::overaligned_tag<16>{});
                    uint32_t offB = (uint32_t)(2 * SLM_AB + cur * SLM_BB + cb * 512);
                    esimd::simd<int8_t,256> b0 = esimd::slm_block_load<int8_t,256>(offB, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,256> b1 = esimd::slm_block_load<int8_t,256>(offB + 256, esimd::overaligned_tag<16>{});
                    c0 = esimd::xmx::dpas<8,8,int32_t>(c0, b0, a0);
                    c1 = esimd::xmx::dpas<8,8,int32_t>(c1, b1, a0);
                    esimd::barrier();
                }
                // stage (float(c)*as[r])*bs[col] -> Z (64x32 f32 slice, row-major)
                int gc = (int)(part * C + hh * 32u) + cb * 16;
                esimd::simd<float,16> cs = esimd::block_load<float,16>(bs + gc, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    int gr = (int)(w * tokens) + rb * 8 + r;
                    float rs = as[gr];
                    esimd::simd<float,16> f;
                    f.template select<8,1>(0) = esimd::convert<float>(c0.template select<8,1>(r*8).read()) * rs;
                    f.template select<8,1>(8) = esimd::convert<float>(c1.template select<8,1>(r*8).read()) * rs;
                    f = f * cs;
                    esimd::slm_block_store<float,16>(Z0 + (uint32_t)((rb*8 + r) * 32 + cb * 16) * 4u, f, esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
                // v5a tail: 64 row tasks / 16 threads = 4 each (qres VERBATIM)
                #pragma unroll
                for (int t = 0; t < 4; ++t) {
                    uint row = (uint)(t * 16 + (int)lid);
                    esimd::simd<float,32> seg = esimd::slm_block_load<float,32>(
                        Z0 + row * 128u, esimd::overaligned_tag<16>{});
                    esimd::simd<half,32> oh;
                    if (part == 2) {
                        oh = esimd::convert<half>(wbv3::e4m3_vec<32>(seg));
                    } else {
                        esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(seg));
                        float recip = wbv3::cosine_recip_vec(hr);
                        if (part == 0) {
                            float sc = wbmega::eh_round(qs[hh]);
                            esimd::simd<float,32> t1 = wbv3::mulh(hr, recip);
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(t1, sc)));
                        } else {
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(hr, recip)));
                        }
                    }
                    // plane slice (the qres scatter map: ((w*heads+head)*tokens+t)*32)
                    {
                        sycl::half* T = (part == 0) ? Qp : ((part == 1) ? Kp : Vp);
                        oh.copy_to(T + ((size_t)b * tokens + row) * 32u);
                    }
                    if (part == 0) {
                        // Q -> QT direct (pack_a16_b map, k contiguous)
                        uint tr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                        uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                        uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                        esimd::simd<half,16> qa0 = oh.template select<16,1>(0), qa1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(QT + e0 * 2u, qa0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(QT + e1 * 2u, qa1, esimd::overaligned_tag<16>{});
                    } else {
                        // K/V -> Y temp row-major (4KB), block-gathered below
                        uint off = (row * 32u) * 2u;
                        esimd::simd<half,16> ya0 = oh.template select<16,1>(0), ya1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(Y0 + off, ya0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(Y0 + off + 32u, ya1, esimd::overaligned_tag<16>{});
                    }
                }
                esimd::barrier();
                if (part == 1 || part == 2) {
                    // blade-7 wide-message gather Y -> KT (pack_b16_t_b) / VT (pack_b16_b)
                    uint bidx = lid;
                    uint dst = (part == 1) ? KT : VT;
                    if (part == 1) {
                        uint kc2 = bidx / 8u, tc2 = (bidx / 2u) % 4u, js = bidx % 2u;
                        esimd::simd<half,128> blk;
                        #pragma unroll
                        for (int jl = 0; jl < 8; ++jl) {
                            uint r = tc2 * 16u + js * 8u + (uint)jl;
                            esimd::simd<half,16> vr = esimd::slm_block_load<half,16>(
                                Y0 + (r * 32u + kc2 * 16u) * 2u, esimd::overaligned_tag<16>{});
                            #pragma unroll
                            for (int kq = 0; kq < 8; ++kq)
                                blk.template select<2,1>(kq * 16 + jl * 2) = vr.template select<2,1>(kq * 2);
                        }
                        esimd::slm_block_store(dst + bidx * 256u, blk, esimd::overaligned_tag<16>{});
                    } else {
                        uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                        esimd::simd<half,128> blk;
                        #pragma unroll
                        for (int kq = 0; kq < 8; ++kq) {
                            esimd::simd<half,8> a = esimd::slm_block_load<half,8>(
                                Y0 + ((kc2 * 16u + kq * 2u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                            esimd::simd<half,8> bv = esimd::slm_block_load<half,8>(
                                Y0 + ((kc2 * 16u + kq * 2u + 1u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                            blk.template select<8,2>(kq * 16 + 0) = a;
                            blk.template select<8,2>(kq * 16 + 1) = bv;
                        }
                        esimd::slm_block_store(dst + bidx * 256u, blk, esimd::overaligned_tag<16>{});
                    }
                    esimd::barrier();   // Y free for the probs
                }
            }

            // ============ phase 2: wa_res stages 1-3 for THIS head (VERBATIM) ====
            const int TS = 16, BK = 16;
            const int SLM_A = 64*BK*2, SLM_B = BK*64*2, SLM_B_BASE = 2*SLM_A;
            int wi_row = (int)(lid / 4u), wi_col = (int)(lid % 4u);
            auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                #pragma unroll
                for (int p = 0; p < 4; ++p) {
                    int tt = (int)(lid / 4u), w4 = (int)(lid % 4u);
                    if (tt != p) continue;
                    esimd::simd<half,64> av = esimd::slm_block_load<half,64>(
                        QT + (uint)(((tt*2+kc)*2)*128 + w4*64) * 2u, esimd::overaligned_tag<16>{});
                    esimd::simd<half,64> bv = esimd::slm_block_load<half,64>(
                        KT + (uint)(((kc*4+tt)*2)*128 + w4*64) * 2u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(X0 + buf * SLM_A + (uint)(tt * 256 + w4 * 64) * 2u, av, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(X0 + SLM_B_BASE + buf * SLM_B + (uint)(tt * 256 + w4 * 64) * 2u, bv, esimd::overaligned_tag<16>{});
                }
            };
            esimd::simd<float,64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            load_block(0, 0);
            esimd::barrier();
            #pragma unroll
            for (int kb = 0; kb < 2; ++kb) {
                int cur = kb & 1, nxt = cur ^ 1;
                if (kb + 1 < 2) load_block(nxt, kb + 1);
                uint32_t offA = X0 + cur * SLM_A + (uint)wi_row * (TS * BK * 2);
                uint32_t offB = X0 + SLM_B_BASE + cur * SLM_B + (uint)wi_col * (TS * BK * 2);
                esimd::simd<half,128> qa0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> qa1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> ka0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> ka1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8,8,float>(c00, ka0, qa0);
                c01 = esimd::xmx::dpas<8,8,float>(c01, ka1, qa0);
                c10 = esimd::xmx::dpas<8,8,float>(c10, ka0, qa1);
                c11 = esimd::xmx::dpas<8,8,float>(c11, ka1, qa1);
                esimd::barrier();
            }
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                esimd::slm_block_store<float,8>(Z0 + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16)) * 4u,
                    c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(Z0 + (uint32_t)(((wi_row*16 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c01.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(Z0 + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16)) * 4u,
                    c10.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,8>(Z0 + (uint32_t)(((wi_row*16 + 8 + r) * 64 + wi_col*16 + 8)) * 4u,
                    c11.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            // softmax (wa_res stage 2 VERBATIM; probs -> Y pack_a16)
            #pragma unroll
            for (int rr = 0; rr < 4; ++rr) {
                uint row = lid * 4u + rr;
                uint rgl = b * 64u + row;
                esimd::simd<float,32> s0 = esimd::slm_block_load<float,32>(Z0 + row * 256u, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> s1 = esimd::slm_block_load<float,32>(Z0 + row * 256u + 128u, esimd::overaligned_tag<16>{});
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
                uint trr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                uint ybase = Y0 + ((trr * 4u + 0u) * 2u + strip) * 256u + il * 32u;
                esimd::simd<half,16> q0 = oh0.template select<16,1>(0), q1 = oh0.template select<16,1>(16);
                esimd::simd<half,16> q2 = oh1.template select<16,1>(0), q3 = oh1.template select<16,1>(16);
                esimd::slm_block_store(ybase, q0, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(ybase + 512u, q1, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(ybase + 1024u, q2, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(ybase + 1536u, q3, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            // attnV (wa_res stage 3 VERBATIM; B from the VT tile SLM->SLM)
            {
                const int SLM_B2 = BK*32*2;
                const int BCH2 = (BK*32)/8;
                int t8 = (int)lid % 8;
                int tr2 = t8 / 2, tc2 = t8 % 2;
                auto load_block2 = [&](int buf, int kc) SYCL_ESIMD_FUNCTION {
                    #pragma unroll
                    for (int i = 0; i < BCH2 / 64; ++i) {
                        int lb = t8 * BCH2 + i * 64;
                        esimd::simd<half,64> v2 = esimd::slm_block_load<half,64>(
                            VT + (uint)(kc * 512 + lb) * 2u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(X0 + 4096u + buf * SLM_B2 + lb * 2, v2, esimd::overaligned_tag<16>{});
                    }
                };
                esimd::simd<float,64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                load_block2(0, 0);
                esimd::barrier();
                for (int kb = 0; kb < 4; ++kb) {
                    int cur = kb & 1, nxt = cur ^ 1;
                    if (kb + 1 < 4) load_block2(nxt, kb + 1);
                    uint32_t offA = Y0 + (uint32_t)(((size_t)tr2 * 4u + (size_t)kb) * 2u) * 256u;
                    uint32_t offB = X0 + 4096u + cur * SLM_B2 + tc2 * (TS * BK * 2);
                    esimd::simd<half,128> pa0 = esimd::slm_block_load<half,128>(offA, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> pa1 = esimd::slm_block_load<half,128>(offA + 256, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> vb0 = esimd::slm_block_load<half,128>(offB, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> vb1 = esimd::slm_block_load<half,128>(offB + 256, esimd::overaligned_tag<16>{});
                    d00 = esimd::xmx::dpas<8,8,float>(d00, vb0, pa0);
                    d01 = esimd::xmx::dpas<8,8,float>(d01, vb1, pa0);
                    d10 = esimd::xmx::dpas<8,8,float>(d10, vb0, pa1);
                    d11 = esimd::xmx::dpas<8,8,float>(d11, vb1, pa1);
                    esimd::barrier();
                }
                const unsigned CH = heads * 32u;
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                    esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                    esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                    esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                    esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                    esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                    size_t o0 = (((size_t)w * 64u + (size_t)(tr2 * 16 + r)) * CH
                                 + hh * 32u + (unsigned)tc2 * 16u);
                    size_t o2 = (((size_t)w * 64u + (size_t)(tr2 * 16 + 8 + r)) * CH
                                 + hh * 32u + (unsigned)tc2 * 16u);
                    h00.copy_to(Out + o0); h01.copy_to(Out + o0 + 8u);
                    h10.copy_to(Out + o2); h11.copy_to(Out + o2 + 8u);
                }
            }
        });
    });
}
}
