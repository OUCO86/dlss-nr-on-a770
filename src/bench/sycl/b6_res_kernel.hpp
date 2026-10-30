// b6_res_kernel.hpp -- B6-1 (2026-10-30, the traffic-roof campaign §6.22): ONE
// resident kernel per window covering qkv + window-attention + attended-quant +
// outproj + residual-fold. The traffic ledger proved the frame sits on the
// plane-transfer roof (write+one-read ~= 68ms ~= frame time); blade wins only
// shave issue overhead on top. B6 deletes ROUND TRIPS: the 1277 attended plane
// (W120/R120 -- census: its ONLY readers are the 16 lfw-layer quants, which move
// inside this kernel), the attended-pk plane (1272 leg) and the 1270 skip-side
// plane all become SLM-only; the wa + quant + wres launches fold into one.
// Phases 1-2 = lfw2 VERBATIM (bench_lfw2 8/8 EXACT today). Phase 3 NEW:
//  (a) stage-3 attended halves join into ATT = Y0 (64 rows x 64 halfs, col =
//      hh*32+c) instead of the global 1277 plane;
//  (b) attended quantize: 4 rows/thread: 128B block load, hmax(abs) ->
//      scale = fdiv_rn(peak,127), qq = fdiv_rn(v,scale), rint, clamp [-127,127],
//      int8 -> PKT = Z0 row-major [row][kb*32+c] (4KB) + AS2 = Z0+4096 (64 f32
//      scales). The chain is the qr_kernel_rowthread / quantize VERBATIM
//      (fdiv_rn per element = the shipped quant semantics, NOT the mulh form);
//  (c) outproj gemm int8 BM64(tokens) x BN64 x K64, NT16: thread tile = 8 rows
//      (rb) x 32 cols (cb); A = PKT SLM-direct (256B/kb), B = dOp (cached packed
//      weight, global->X0 staging 2x2048B, 8x reuse across rb like phase 1);
//  (d) epilogue = gemm_b_res_window's fold VERBATIM: f = float(c)*as2[tok]*bs2
//      [col]; straight-line sk*ccl + f = ONE HW FMA (the section-75 shape rule);
//      pub_vec_v8(epi=1); narrow -> f16 store at the IMAGE-MAP slot (window/
//      token -> yy/xx cull), skip read from 1267 f16 at that same slot.
// SLM = the lfw2 map (45056B, 64KB bucket). NO new allocation.
// Guard (recorder): lfw2 guard + the FOLLOWING two recorded calls are exactly
// quant(1277 -> pk 1272, sc 1273) and gemm_window_int8_residual(that pk, W,
// out 1270, sc, b_scale 80, skip 1267, cosine 72) with flags 0x41100 (epi1,
// narrow, half_skip) + image map (across/top/left/h) + M == the lfw M. The
// recorder rewrites the wres closure to no-op and the quant closure to no-op;
// THIS launch produces 1270 directly. Escape NR_B6=0.
// Judges: bench_b6 (fused vs shipped trio), WINDOW_ATTENTION + QUANT +
// WINDOW_INT8_RESIDUAL gates, 1301 EXACT, 16-pair A/B.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"

namespace b6 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const uint X0 = 0u;        // 8KB: gemm operand buffers (all phases)
static const uint Z0 = 8192u;     // 16KB: qkv stage -> scores -> PKT(4KB)+AS2(256B)
static const uint Y0 = 24576u;    // 8KB: K/V temps -> probs -> ATTENDED (phase 3)
static const uint QT = 32768u, KT = 36864u, VT = 40960u;
static const uint SLMB = 45056u;

static inline sycl::event launch_b6(sycl::queue& q, const int8_t* dAp, const int8_t* dBp,
                                    const float* as, const float* bs,
                                    const float* qs, const float* dBias,
                                    unsigned windows, unsigned heads,
                                    sycl::half* Qp, sycl::half* Kp, sycl::half* Vp,
                                    const int8_t* dOp, const float* bs2, const float* cosv,
                                    const sycl::half* dSkip, sycl::half* Out2,
                                    unsigned across, unsigned top, unsigned left,
                                    unsigned image_h, unsigned image_w) {
    constexpr unsigned C = 64u, NH = 192u, tokens = 64u;
    const unsigned batches = windows * heads;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)batches * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            uint b = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint w = b / heads, hh = b % heads;
            int rb = (int)(lid / 2u);
            int cb = (int)(lid % 2u);

            // ================= phases 1-2: lfw2 VERBATIM ========================
            #pragma unroll 1
            for (int part = 0; part < 3; ++part) {
                const int SLM_AB = 2048, SLM_BB = 1024;
                const int kb_n = (int)C / 32;
                const uint band = w / 2u;
                const uint wioff = (w % 2u) * 2048u;
                const int8_t* apb = dAp + (size_t)band * kb_n * 4096u + wioff;
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
                    {
                        sycl::half* T = (part == 0) ? Qp : ((part == 1) ? Kp : Vp);
                        oh.copy_to(T + ((size_t)b * tokens + row) * 32u);
                    }
                    if (part == 0) {
                        uint tr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                        uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                        uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                        esimd::simd<half,16> qa0 = oh.template select<16,1>(0), qa1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(QT + e0 * 2u, qa0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(QT + e1 * 2u, qa1, esimd::overaligned_tag<16>{});
                    } else {
                        uint off = (row * 32u) * 2u;
                        esimd::simd<half,16> ya0 = oh.template select<16,1>(0), ya1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(Y0 + off, ya0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(Y0 + off + 32u, ya1, esimd::overaligned_tag<16>{});
                    }
                }
                esimd::barrier();
                if (part == 1 || part == 2) {
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
                    esimd::barrier();
                }
            }

            // ---- phase 2: wa stages 1-2 for THIS head (scores + softmax) ----
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
            #pragma unroll 1
            for (uint h2 = 0; h2 < heads; ++h2) {
                uint b2 = w * heads + h2;
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
                #pragma unroll
                for (int rr = 0; rr < 4; ++rr) {
                    uint row = lid * 4u + rr;
                    uint rgl = b2 * 64u + row;
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
                // attnV stage 3 (wa_res VERBATIM); the attended halves go to ATT (Y0
                // cols h2*32..) instead of the global 1277 plane.
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
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                        esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                        esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                        esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                        esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                        esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                        // B6-1: joined 16-half stores into ATT (Y0): row-major 64x64,
                        // col = h2*32 + tc2*16 (+8). (The shipped path wrote the f16
                        // 1277 plane here; its only readers = the 16 quants, now here.)
                        esimd::simd<half,16> j0; j0.template select<8,1>(0) = h00; j0.template select<8,1>(8) = h01;
                        esimd::simd<half,16> j1; j1.template select<8,1>(0) = h10; j1.template select<8,1>(8) = h11;
                        uint row0 = tr2 * 16u + (uint)r, row1 = row0 + 8u;
                        esimd::slm_block_store(Y0 + (row0 * 64u + h2 * 32u + (unsigned)tc2 * 16u) * 2u,
                                               j0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(Y0 + (row1 * 64u + h2 * 32u + (unsigned)tc2 * 16u) * 2u,
                                               j1, esimd::overaligned_tag<16>{});
                    }
                    esimd::barrier();   // ATT ready (both heads after the loop)
                }
            }

            // ============ phase 3a/3b: attended quantize -> PKT + AS2 ==========
            // 64 rows / 16 threads = 4 each. The chain = the shipped quant
            // (quantize_row / qr_kernel_rowthread): scale = fdiv_rn(hmax|v|,127),
            // qq = fdiv_rn(v,scale), rint, clamp [-127,127], int8 (the fdiv_rn
            // per-element form -- NOT the mulh shortcut: the quantize gate's
            // authority). ATT rows are 64 halfs = 128B.
            #pragma unroll
            for (int t = 0; t < 4; ++t) {
                uint row = (uint)(t * 16 + (int)lid);
                esimd::simd<float,64> v = esimd::convert<float>(
                    esimd::slm_block_load<half,64>(Y0 + row * 128u, esimd::overaligned_tag<16>{}));
                float peak = esimd::hmax<float,float,64>(esimd::abs(v));
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::simd<float,64> qq = esimd::div_ieee<float,64>(v, esimd::simd<float,64>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,64>(qq), esimd::simd<float,64>(-127.f)), esimd::simd<float,64>(127.f));
                // PKT = kb-slice-major [kb][row][32B] (the gemm SLM_A band layout:
                // phase 3c's a0 = Z0 + kbi*2048 + rb*256 = 8 rows x 32B contiguous).
                esimd::simd<int8_t,64> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                esimd::slm_block_store<int8_t,32>(Z0 + row * 32u, qi.template select<32,1>(0), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<int8_t,32>(Z0 + 2048u + row * 32u, qi.template select<32,1>(1), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,1>(Z0 + 4096u + row * 4u, esimd::simd<float,1>(scale));
            }
            esimd::barrier();

            // ============ phase 3c: outproj gemm int8 (BM64 x BN64 x K64) ======
            // A = PKT (Z0 row-major [row][kb*32+c]) SLM-direct; B = dOp packed
            // (kb*N*32 + ...; block per kb = 64x32 = 2048B staged X0 2-buffer).
            {
                const int SLM_BB3 = 2048;
                const int8_t* bp3 = dOp;
                auto load_block3 = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int8_t,128> bv = esimd::block_load<int8_t,128>(
                        bp3 + (size_t)kb * (64u * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_BB3 + lid * 128u, bv, esimd::overaligned_tag<16>{});
                };
                esimd::simd<int32_t,64> o0(0), o1(0), o2(0), o3(0);
                load_block3(0, 0);
                esimd::barrier();
                #pragma unroll
                for (int kbi = 0; kbi < 2; ++kbi) {
                    int cur = kbi & 1, nxt = cur ^ 1;
                    if (kbi + 1 < 2) load_block3(nxt, kbi + 1);
                    esimd::simd<int8_t,256> a0 = esimd::slm_block_load<int8_t,256>(
                        Z0 + (uint32_t)(rb * 256 + kbi * 2048), esimd::overaligned_tag<16>{});
                    uint32_t offB = (uint32_t)(cur * SLM_BB3 + cb * 1024);
                    esimd::simd<int8_t,256> b0 = esimd::slm_block_load<int8_t,256>(offB, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,256> b1 = esimd::slm_block_load<int8_t,256>(offB + 256, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,256> b2 = esimd::slm_block_load<int8_t,256>(offB + 512, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,256> b3 = esimd::slm_block_load<int8_t,256>(offB + 768, esimd::overaligned_tag<16>{});
                    o0 = esimd::xmx::dpas<8,8,int32_t>(o0, b0, a0);
                    o1 = esimd::xmx::dpas<8,8,int32_t>(o1, b1, a0);
                    o2 = esimd::xmx::dpas<8,8,int32_t>(o2, b2, a0);
                    o3 = esimd::xmx::dpas<8,8,int32_t>(o3, b3, a0);
                    esimd::barrier();
                }
                // ============ phase 3d: the wres fold VERBATIM ================
                int gc0 = (int)(cb * 32u);
                esimd::simd<float,16> csl = esimd::block_load<float,16>(bs2 + gc0, esimd::overaligned_tag<16>{});
                esimd::simd<float,16> csh = esimd::block_load<float,16>(bs2 + gc0 + 16, esimd::overaligned_tag<16>{});
                esimd::simd<float,16> ccl = esimd::block_load<float,16>(cosv + gc0, esimd::overaligned_tag<16>{});
                esimd::simd<float,16> cch = esimd::block_load<float,16>(cosv + gc0 + 16, esimd::overaligned_tag<16>{});
                esimd::simd<float,8> csl0=csl.template select<8,1>(0), csl1=csl.template select<8,1>(8);
                esimd::simd<float,8> csh0=csh.template select<8,1>(0), csh1=csh.template select<8,1>(8);
                esimd::simd<float,8> ccl0=ccl.template select<8,1>(0), ccl1=ccl.template select<8,1>(8);
                esimd::simd<float,8> cch0=cch.template select<8,1>(0), cch1=cch.template select<8,1>(8);
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    uint token = (uint)(rb * 8 + r);
                    unsigned yy = (w / across) * 8u + token / 8u, xx = (w % across) * 8u + token % 8u;
                    bool in = (yy >= top && xx >= left && yy - top < image_h && xx - left < image_w);
                    if (!in) continue;
                    size_t out = ((size_t)(yy - top) * image_w + (xx - left)) * 64u + (size_t)gc0;
                    // attended scales (AS2) play the a_scale role (the shipped chain
                    // read plane 1273; we read the in-kernel AS2 -- same values, never
                    // left the chip). row token of THIS window:
                    float rs = esimd::slm_block_load<float,1>(Z0 + 4096u + token * 4u)[0];
                    esimd::simd<float,8> f0 = esimd::convert<float>(o0.template select<8,1>(r*8).read()) * rs * csl0;
                    esimd::simd<float,8> f1 = esimd::convert<float>(o1.template select<8,1>(r*8).read()) * rs * csl1;
                    esimd::simd<float,8> f2 = esimd::convert<float>(o2.template select<8,1>(r*8).read()) * rs * csh0;
                    esimd::simd<float,8> f3 = esimd::convert<float>(o3.template select<8,1>(r*8).read()) * rs * csh1;
                    // skip = the f16 image plane at the SAME slot, 32 cols wide:
                    // two 16-half block loads (cols gc0..+15, +16..+31).
                    esimd::simd<half,16> sha = esimd::block_load<half,16>(dSkip + out, esimd::overaligned_tag<16>{});
                    esimd::simd<half,16> shb = esimd::block_load<half,16>(dSkip + out + 16u, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> sk0 = esimd::convert<float>(sha.template select<8,1>(0).read());
                    esimd::simd<float,8> sk1 = esimd::convert<float>(sha.template select<8,1>(8).read());
                    esimd::simd<float,8> sk2 = esimd::convert<float>(shb.template select<8,1>(0).read());
                    esimd::simd<float,8> sk3 = esimd::convert<float>(shb.template select<8,1>(8).read());
                    // the fold: straight-line sk*cc + f per 8-group = ONE HW FMA each
                    // (the section-75 shape rule; the gemm_b_res_window BLADE-4 form:
                    // the fma expression elementwise, pub_vec_v8 on the vector tails).
                    esimd::simd<float,16> pubA, pubB;
                    {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl0[e] + f0.read()[e]; t1[e] = sk1[e]*ccl1[e] + f1.read()[e]; }
                        pubA.template select<8,1>(0) = s8v8::pub_vec_v8<8>(1u, t0);
                        pubA.template select<8,1>(8) = s8v8::pub_vec_v8<8>(1u, t1);
                        esimd::simd<float,8> t2, t3;
                        for (int e = 0; e < 8; ++e) { t2[e] = sk2[e]*cch0[e] + f2.read()[e]; t3[e] = sk3[e]*cch1[e] + f3.read()[e]; }
                        pubB.template select<8,1>(0) = s8v8::pub_vec_v8<8>(1u, t2);
                        pubB.template select<8,1>(8) = s8v8::pub_vec_v8<8>(1u, t3);
                    }
                    esimd::convert<half>(pubA).copy_to(Out2 + out);
                    esimd::convert<half>(pubB).copy_to(Out2 + out + 16u);
                }
                esimd::barrier();   // X0 reused by the next head's stages / PKT done
            }
        });
    });
}
}
