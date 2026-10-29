// lfw_res_kernel.hpp -- B5-5b SLICE 1 (2026-10-29, the user's one-core-per-layer
// order): qkv + window attention FUSED into ONE resident launch, WG = one WINDOW
// (64 tokens), NT=16 (the wa_res geometry verbatim). The qkv int8 gemm runs the
// s8v8 loop at BM=64 (3 part-blocks Q|K|V over NH=192, BN=64, K=C=64), the qres
// v2 tail runs the PROMOTED v5a vector tree (cosine_recip_vec/mulh/e4m3_vec) and
// publishes the e4m3 halves DIRECTLY into the wa_res SLM tiles: Q -> WA_QT in the
// pack_a16_b map (2 contiguous 16-half stores per row-head), K/V -> the Y temp
// row-major, then blade-7 block-assembly gathers Y -> WA_KT / WA_VT (wide 256B
// messages). Planes 1274/1275/1276 NEVER EXIST for these calls; wa's Q/K/V RAW
// gathers never happen; the whole wa launch dissolves. Phase 2 = the wa_res
// stages 1-3 VERBATIM per head (scores gemm from QT/KT tiles, softmax from Z with
// the bias map writing probs into Y, attnV from Y+VT, merge-fold store to
// Out=1277 unchanged).
// Guards (recorder side): non-vit, C==64, heads==2, tokens==64, merged==1, bias
// present, M%64==0 -- the frame's 16 biggest window layers (batches 1020-1116,
// ~40% of the wa family). SLM = the existing WA layout 45056B (Z doubles as the
// qkv h-stage, Y as the K/V temp then the probs; QT/KT/VT are FILLED BY PHASE 1).
// NO new allocation, NO extra barriers beyond the pipeline's own.
// Bit-exactness: qkv frags/stage/deq order = qres VERBATIM; tail = qres v3 (v5a
// tree); K/V tile maps = pack_b16_t_b / pack_b16_b VERBATIM (blade-7 restructure,
// values identical by construction); stages 1-3 = wa_res VERBATIM.
// Judges: GEMM_INT8_QKV + WINDOW_ATTENTION gates (the recorder runs the fused
// path under the guard) + end-to-end 1301 vs bk + determinism + frame A/B.
// Escape: NR_LFW_FUSE=0 restores the split qkv+wa pair.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v3.hpp"
#include "window_block_v2.hpp"

namespace lfw {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM map (wa_res's regions; the constants are local to avoid macro clashes)
static const uint X0 = 0u;        // 8KB: gemm operand double buffers (all phases)
static const uint Z0 = 8192u;     // 16KB: f32 staging (qkv h-inputs, then scores)
static const uint Y0 = 24576u;    // 8KB: K/V temps (phase 1), probs (phase 2)
// BLADE-8 FIX (bench_lfw caught it -- the wa_res header's OWN overlap warning
// class): this WG holds a whole WINDOW = BOTH heads, so each tile region needs
// 2 x 4KB = 8KB (wa_res sized them 4KB because its WG = one (window,head) batch).
// The old map wrote QT[head1] over KT and VT[head1] past the SLM top -> head-1
// garbage (bench_lfw: planes EXACT, Out head-0 EXACT, head-1 49% wrong).
static const uint QT = 32768u;    // 8KB: Q tiles (2 heads x 4KB)
static const uint KT = 40960u;    // 8KB: K tiles
static const uint VT = 49152u;    // 8KB: V tiles
static const uint SLMB = 57344u;  // 56KB: the 64KB bucket == v4full/wa_res's bucket (no occupancy change)

// windows = M/64; heads=2, C=64, NH=192, tokens=64 fixed by the guard.
// Qp/Kp/Vp: the qkv TARGET planes -- the downstream plan still READS 1274/1275/1276
// (the next layer's quant/take chain consumes them), so the tail DOUBLE-WRITES:
// tiles (for this kernel's attention) + plane scatter (for the plan, the qres
// form verbatim). The planes keep existing; what dissolves is the qkv GEMM/TAIL
// launches, the wa operand gathers, and the whole wa launch.
static inline sycl::event launch_lfw(sycl::queue& q, const int8_t* dAp, const int8_t* dBp,
                                     sycl::half* Out, const float* as, const float* bs,
                                     const float* qs, const float* dBias,
                                     unsigned windows,
                                     sycl::half* Qp, sycl::half* Kp, sycl::half* Vp) {
    constexpr unsigned heads = 2u, C = 64u, NH = 192u;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)windows * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            uint w = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int wi_row = (int)(lid / 4u), wi_col = (int)(lid % 4u);

            // ============ phase 1: qkv gemm x3 parts -> v5a tail -> tiles =========
            #pragma unroll 1
            for (int part = 0; part < 3; ++part) {
                const int SLM_A = 2048, SLM_B = 2048;   // halfs per double buffer
                const int kb_n = (int)C / 32;           // 2
                const uint band = w / 2u;               // 128-row pack_a bands
                const uint hb = (w % 2u) * 2048u;     // second 64-row half of band (NOT "half": shadows the type)
                const int8_t* apb = dAp + (size_t)band * kb_n * 4096u + hb;
                const int8_t* bp = dBp + (size_t)part * 2048u;   // column block part
                auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int8_t,128> av = esimd::block_load<int8_t,128>(
                        apb + (size_t)kb * 4096u + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_A + lid * 128u, av, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,128> bv = esimd::block_load<int8_t,128>(
                        bp + (size_t)kb * (NH * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(2 * SLM_A + buf * SLM_B + lid * 128u, bv, esimd::overaligned_tag<16>{});
                };
                auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                    esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                    uint32_t offA = buf * SLM_A + wi_row * 512;
                    uint32_t offB = 2 * SLM_A + buf * SLM_B + wi_col * 512;
                    a0 = esimd::slm_block_load<int8_t,256>(offA + 0, esimd::overaligned_tag<16>{});
                    a1 = esimd::slm_block_load<int8_t,256>(offA + 256, esimd::overaligned_tag<16>{});
                    b0 = esimd::slm_block_load<int8_t,256>(offB + 0, esimd::overaligned_tag<16>{});
                    b1 = esimd::slm_block_load<int8_t,256>(offB + 256, esimd::overaligned_tag<16>{});
                };
                esimd::simd<int8_t,256> a0, a1, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0), c10(0), c11(0);
                load_block(0, 0);
                esimd::barrier();
                #pragma unroll
                for (int b = 0; b < kb_n; ++b) {
                    int cur = b & 1, nxt = cur ^ 1;
                    if (b + 1 < kb_n) load_block(nxt, b + 1);
                    load_grf(cur, a0, a1, b0, b1);
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                    c10 = esimd::xmx::dpas<8,8,int32_t>(c10, b0, a1);
                    c11 = esimd::xmx::dpas<8,8,int32_t>(c11, b1, a1);
                    esimd::barrier();
                }
                // stage (float(c)*as[r])*bs[col] -> Z (qres order VERBATIM; rows are
                // the window's 64 tokens; the guard M%64==0 means NO pad rows)
                int gc = part * (int)C + wi_col * 16;
                esimd::simd<float,16> cs = esimd::block_load<float,16>(bs + gc, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    int gr0 = (int)(w * 64u) + wi_row * 16 + r, gr1 = gr0 + 8;
                    float rs0 = as[gr0], rs1 = as[gr1];
                    esimd::simd<float,16> f0, f1;
                    f0.template select<8,1>(0) = esimd::convert<float>(c00.template select<8,1>(r*8).read()) * rs0;
                    f0.template select<8,1>(8) = esimd::convert<float>(c01.template select<8,1>(r*8).read()) * rs0;
                    f1.template select<8,1>(0) = esimd::convert<float>(c10.template select<8,1>(r*8).read()) * rs1;
                    f1.template select<8,1>(8) = esimd::convert<float>(c11.template select<8,1>(r*8).read()) * rs1;
                    f0 = f0 * cs; f1 = f1 * cs;
                    esimd::slm_block_store<float,16>(Z0 + (uint32_t)((wi_row*16 + r) * 64 + wi_col*16) * 4u, f0, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<float,16>(Z0 + (uint32_t)((wi_row*16 + 8 + r) * 64 + wi_col*16) * 4u, f1, esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
                // tail: 128 (row,head) tasks / 16 threads = 8 each (qres v3 VERBATIM)
                #pragma unroll
                for (int k = 0; k < 8; ++k) {
                    int idx = k * 16 + (int)lid;
                    int row = idx / 2, hpart = idx % 2;
                    unsigned head = (unsigned)hpart;
                    esimd::simd<float,32> seg = esimd::slm_block_load<float,32>(
                        Z0 + (uint32_t)(row * 64 + hpart * 32) * 4u, esimd::overaligned_tag<16>{});
                    esimd::simd<half,32> oh;
                    if (part == 2) {                       // V: e4m3(deq) only
                        oh = esimd::convert<half>(wbv3::e4m3_vec<32>(seg));
                    } else {
                        esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(seg));
                        float recip = wbv3::cosine_recip_vec(hr);
                        if (part == 0) {
                            float sc = wbmega::eh_round(qs[head]);
                            esimd::simd<float,32> t1 = wbv3::mulh(hr, recip);   // non-vit: no VIT_ROOT
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(t1, sc)));
                        } else {
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(hr, recip)));
                        }
                    }
                    // plane scatter (the qres tail form VERBATIM): the plan's
                    // downstream quant/batched chain still reads the target planes;
                    // at = ((w*heads+head)*tokens + t)*32 with tokens=64.
                    {
                        unsigned r = w * 64u + (unsigned)row;
                        size_t pofs = (((size_t)(r / 64u) * heads + head) * 64u + (r % 64u)) * 32u;
                        sycl::half* T = (part == 0) ? Qp : ((part == 1) ? Kp : Vp);
                        oh.copy_to(T + pofs);
                    }
                    if (part == 0) {
                        // Q -> QT[head] in the pack_a16_b map (k contiguous):
                        // elem = ((tr*2+kc)*2+strip)*128 + il*16 + k
                        uint tr = (uint)row / 16u, strip = ((uint)row % 16u) / 8u, il = (uint)row % 8u;
                        uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                        uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                        esimd::simd<half,16> qa0 = oh.template select<16,1>(0), qa1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(QT + head * 4096u + e0 * 2u, qa0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(QT + head * 4096u + e1 * 2u, qa1, esimd::overaligned_tag<16>{});
                    } else {
                        // K/V temp -> Y0 (2 heads x 4KB = the 8KB region exactly;
                        // the K gather's barrier frees it for the V temp; phase 2's
                        // softmax reuses it for the probs after the V gather).
                        uint tb = Y0;
                        uint off = (head * 2048u + (uint)row * 32u) * 2u;
                        esimd::simd<half,16> ya0 = oh.template select<16,1>(0), ya1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(tb + off, ya0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(tb + off + 32u, ya1, esimd::overaligned_tag<16>{});
                    }
                }
                esimd::barrier();
                if (part == 1 || part == 2) {
                    // blade-7 block-gather Y -> KT / VT (wide 256B messages).
                    // KT block bidx = (kc*4+tc)*2+js: elem kq*16 + jl*2 + kpar <-
                    //   raw row tc*16+js*8+jl, col kc*16 + kq*2 + kpar.
                    // VT block bidx = (kc*4+tc*2? NO -- pack_b16_b: blocks (kc*2+tc)*2+js
                    //   with the tile elem = kq*16 + j, j = jl*2+kpar <- raw row
                    //   kc*16+kq*2+(j%2), col tc*16+js*8+j/2 -- the wa_res raw_v map.
                    uint bidx = lid;
                    uint dst = (part == 1) ? KT : VT;
                    if (part == 1) {
                        uint kc2 = bidx / 8u, tc2 = (bidx / 2u) % 4u, js = bidx % 2u;
                        #pragma unroll 1
                        for (uint head = 0; head < heads; ++head) {
                            esimd::simd<half,128> blk;
                            #pragma unroll
                            for (int jl = 0; jl < 8; ++jl) {
                                uint r = tc2 * 16u + js * 8u + (uint)jl;
                                esimd::simd<half,16> vr = esimd::slm_block_load<half,16>(
                                    Y0 + (head * 2048u + r * 32u + kc2 * 16u) * 2u, esimd::overaligned_tag<16>{});
                                #pragma unroll
                                for (int kq = 0; kq < 8; ++kq)
                                    blk.template select<2,1>(kq * 16 + jl * 2) = vr.template select<2,1>(kq * 2);
                            }
                            esimd::slm_block_store(dst + head * 4096u + bidx * 256u, blk, esimd::overaligned_tag<16>{});
                        }
                    } else {
                        // V temp -> Y0 after the K gather's barrier.
                        // the pack_b16_b map: blocks (kc*2+tc)*2+js, kc 0..1, tc 0..1,
                        // js 0..1 (8 blocks/head x 8 kq-runs... wa_res raw_v VERBATIM:
                        // bidx = kc*4 + tc*2 + js over 16 blocks, tile elem =
                        // bidx*128 + kq*16 + j, j = jl*2+kpar <- raw row kc*16+kq*2+(j&1),
                        // col tc*16 + js*8 + j/2.
                        uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                        uint vtmp = Y0;   // the V temp reuses Y0 (the K gather's barrier freed it)
                        #pragma unroll 1
                        for (uint head = 0; head < heads; ++head) {
                            esimd::simd<half,128> blk;
                            #pragma unroll
                            for (int kq = 0; kq < 8; ++kq) {
                                esimd::simd<half,8> a = esimd::slm_block_load<half,8>(
                                    vtmp + (head * 2048u + (kc2 * 16u + kq * 2u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                                esimd::simd<half,8> bv = esimd::slm_block_load<half,8>(
                                    vtmp + (head * 2048u + (kc2 * 16u + kq * 2u + 1u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                                blk.template select<8,2>(kq * 16 + 0) = a;
                                blk.template select<8,2>(kq * 16 + 1) = bv;
                            }
                            esimd::slm_block_store(dst + head * 4096u + bidx * 256u, blk, esimd::overaligned_tag<16>{});
                        }
                    }
                    esimd::barrier();   // Y free for the next temp / the probs
                }
            }

            // ============ phase 2: wa_res stages 1-3 per head (VERBATIM) =========
            const int TS = 16, BK = 16;
            const int SLM_A = 64*BK*2, SLM_B = BK*64*2, SLM_B_BASE = 2*SLM_A;
            #pragma unroll 1
            for (uint hh = 0; hh < heads; ++hh) {
                uint b = w * heads + hh;
                auto load_block = [=](int buf, int kc) SYCL_ESIMD_FUNCTION {
                    #pragma unroll
                    for (int p = 0; p < 4; ++p) {
                        int tt = (int)(lid / 4u), w4 = (int)(lid % 4u);
                        if (tt != p) continue;
                        esimd::simd<half,64> av = esimd::slm_block_load<half,64>(
                            QT + hh * 4096u + (uint)(((tt*2+kc)*2)*128 + w4*64) * 2u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,64> bv = esimd::slm_block_load<half,64>(
                            KT + hh * 4096u + (uint)(((kc*4+tt)*2)*128 + w4*64) * 2u, esimd::overaligned_tag<16>{});
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
                // softmax (wa_res stage 2 VERBATIM; probs -> Y in the pack_a16 map)
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
                // attnV (wa_res stage 3 VERBATIM, raw_v: B from VT[h] SLM->SLM)
                {
                    const int SLM_B2 = BK*32*2;                 // 1024 halfs
                    const int BCH2 = (BK*32)/8;                 // 64
                    int t8 = (int)lid % 8;
                    int tr2 = t8 / 2, tc2 = t8 % 2;
                    auto load_block2 = [&](int buf, int kc) SYCL_ESIMD_FUNCTION {
                        #pragma unroll
                        for (int i = 0; i < BCH2 / 64; ++i) {
                            int lb = t8 * BCH2 + i * 64;
                            esimd::simd<half,64> v2 = esimd::slm_block_load<half,64>(
                                VT + hh * 4096u + (uint)(kc * 512 + lb) * 2u, esimd::overaligned_tag<16>{});
                            esimd::slm_block_store(X0 + 4096u + buf * SLM_B2 + lb * 2, v2, esimd::overaligned_tag<16>{});
                        }
                    };
                    esimd::simd<float,64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                    load_block2(0, 0);
                    esimd::barrier();
                    for (int kb = 0; kb < 4; ++kb) {     // K=64: kb_n=4
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
                    esimd::barrier();   // Y reused by the next head's softmax
                }
            }
        });
    });
}
}
