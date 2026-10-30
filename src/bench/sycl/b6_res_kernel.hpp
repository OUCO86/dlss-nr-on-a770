// b6_res_kernel.hpp -- B6-1 (2026-10-30, the traffic-roof campaign §6.22-23):
// ONE resident kernel per WINDOW (slice-1 geometry: WG = window, qkv full-width
// BN=64, BOTH heads' tiles -- NOT lfw2's per-head WG: phase-3's outproj K=64
// spans both heads' attended cols (1277 is (32640,64) token-major with
// head-concat cols -- the wa_res merge-fold map, verified against the quant's
// row addressing), a cross-WG impossibility). Chain fused:
//   qkv gemm+tail -> wa stages 1-3 per head -> attended-quantize -> outproj gemm
//   -> residual fold -> write 1270. The 1277 attended plane (census: for THESE
//   16 layers its only reader is the matching quant, which moves inside), the
//   attended-pk plane (1272 leg) and the 1270 skip-side round trip all become
//   SLM-only; the wa + quant + wres LAUNCHES disappear.
// Phases 1-2 = slice-1 lfw VERBATIM (bench_lfw 8/8 EXACT: planes + Out), with
//   stage-3's global Out store REPLACED by ATT joins into the dead tile region:
//   after head-hh's stage-3, QT[hh]'s 4KB is dead (head-1's tiles live in the
//   OTHER 4KB sub-regions of the 8KB QT band) -> ATT_hh = QT + hh*4096,
//   [token][32] f16 = the shipped 1277 slice VERBATIM.
// Phase 3 NEW:
//   3b quantize: 4 rows/thread: ATT0 row (32 halves) ++ ATT1 row (32) = the
//      1277 row (token-major, head-concat) VERBATIM; hmax -> fdiv_rn(peak,127)
//      -> fdiv_rn(v,scale) -> rint -> clamp -> int8 (the qr_kernel_rowthread/
//      shipped-quant authority: fdiv_rn per element, NOT the mulh shortcut);
//      PKT = kb-slice-major [kb][row][32B] at Z0 (the gemm SLM_A band layout),
//      AS2 = 64 f32 row-scales at Z0+4096 (= the shipped 1273 slice, index
//      w*64+token = the wres a_scale addressing VERBATIM);
//   3c outproj gemm int8 64x64xK64 NT16: thread tile = 8 rows (rb=lid/2) x 32
//      cols (cb=lid%2): A = PKT SLM-direct 256B/kb; B = dOp (pack_b(64,64),
//      cached) staged X0 2x2048B; 4 dpas/kb (the BN=64 tile, full width);
//   3d fold = gemm_b_res_window epilogue VERBATIM: f = float(c)*as2[tok]*bs2
//      [col]; straight-line sk*cc + f = ONE HW FMA (the section-75 shape rule);
//      pub_vec_v8(epi=1); narrow f16; the image-map slot ((yy-top)*image_w +
//      (xx-left))*64 + gc with the bounds cull; skip = 1267 f16 at that slot.
// SLM: X0 8K | Z0 16K (h-stage/scores/PKT+AS2) | Y0 8K (temps/probs) |
//      QT 8K (QT0|QT1 = ATT after phase 2) | KT 8K | VT 8K | SLMB 57344
//      (the 64KB bucket, slice-1's blade-8 map). No new allocation.
// Guard (recorder): the lfw guard + the FOLLOWING two recorded calls = exactly
// quant(1277 -> 1272, 1273, M, 64) and gemm_window_int8_residual(that pk, W,
// 1270, 1273, b_scale, skip=1267, cosine, M,64,64, 0x41100, h,w,across...);
// the quant + wres closures no-op; THIS launch produces 1270 directly.
// Escape NR_B6=0 (falls back to the lfw2 probe / the shipped chain).
// Judges: bench_b6 (vs the shipped qres+wa_res+quant+wres trio), the
// WINDOW_ATTENTION/QUANT/WINDOW_INT8_RESIDUAL gates, 1301, 16-pair A/B.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"

namespace b6 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const uint X0 = 0u;
static const uint Z0 = 8192u;
static const uint Y0 = 24576u;
static const uint QT = 32768u, KT = 40960u, VT = 49152u;
static const uint SLMB = 57344u;

static inline sycl::event launch_b6(sycl::queue& q, const int8_t* dAp, const int8_t* dBp,
                                    const float* as, const float* bs,
                                    const float* qs, const float* dBias,
                                    unsigned windows,
                                    sycl::half* Qp, sycl::half* Kp, sycl::half* Vp,
                                    const int8_t* dOp, const float* bs2, const float* cosv,
                                    const sycl::half* dSkip, sycl::half* Out2,
                                    unsigned across, unsigned top, unsigned left,
                                    unsigned image_h, unsigned image_w,
                                    int8_t* DbgPKT = nullptr, float* DbgAS = nullptr,
                                    half* DbgATT = nullptr) {
    constexpr unsigned heads = 2u, C = 64u, NH = 192u;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)windows * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            uint w = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int wi_row = (int)(lid / 4u), wi_col = (int)(lid % 4u);

            // ============ phase 1: qkv gemm x3 parts (BN=64) + v5a tail ========
            #pragma unroll 1
            for (int part = 0; part < 3; ++part) {
                const int SLM_AB = 2048, SLM_BB = 2048;
                const int kb_n = (int)C / 32;
                const uint band = w / 2u;
                const uint hb = (w % 2u) * 2048u;
                const int8_t* apb = dAp + (size_t)band * kb_n * 4096u + hb;
                const int8_t* bp = dBp + (size_t)part * 2048u;
                auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int8_t,128> av = esimd::block_load<int8_t,128>(
                        apb + (size_t)kb * 4096u + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_AB + lid * 128u, av, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t,128> bv = esimd::block_load<int8_t,128>(
                        bp + (size_t)kb * (NH * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(2 * SLM_AB + buf * SLM_BB + lid * 128u, bv, esimd::overaligned_tag<16>{});
                };
                auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                    esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                    uint32_t offA = buf * SLM_AB + wi_row * 512;
                    uint32_t offB = 2 * SLM_AB + buf * SLM_BB + wi_col * 512;
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
                #pragma unroll
                for (int k = 0; k < 8; ++k) {
                    int idx = k * 16 + (int)lid;
                    int row = idx / 2, hpart = idx % 2;
                    unsigned head = (unsigned)hpart;
                    esimd::simd<float,32> seg = esimd::slm_block_load<float,32>(
                        Z0 + (uint32_t)(row * 64 + hpart * 32) * 4u, esimd::overaligned_tag<16>{});
                    esimd::simd<half,32> oh;
                    if (part == 2) {
                        oh = esimd::convert<half>(wbv3::e4m3_vec<32>(seg));
                    } else {
                        esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(seg));
                        float recip = wbv3::cosine_recip_vec(hr);
                        if (part == 0) {
                            float sc = wbmega::eh_round(qs[head]);
                            esimd::simd<float,32> t1 = wbv3::mulh(hr, recip);
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(t1, sc)));
                        } else {
                            oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(hr, recip)));
                        }
                    }
                    // plane scatter (the slice-1/qres map VERBATIM -- the downstream
                    // chain still reads 1274/1275/1276; the Q/K/V planes STAY).
                    {
                        unsigned r = w * 64u + (unsigned)row;
                        size_t pofs = (((size_t)(r / 64u) * heads + head) * 64u + (r % 64u)) * 32u;
                        sycl::half* T = (part == 0) ? Qp : ((part == 1) ? Kp : Vp);
                        oh.copy_to(T + pofs);
                    }
                    if (part == 0) {
                        uint tr = (uint)row / 16u, strip = ((uint)row % 16u) / 8u, il = (uint)row % 8u;
                        uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                        uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                        esimd::simd<half,16> qa0 = oh.template select<16,1>(0), qa1 = oh.template select<16,1>(16);
                        esimd::slm_block_store(QT + head * 4096u + e0 * 2u, qa0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(QT + head * 4096u + e1 * 2u, qa1, esimd::overaligned_tag<16>{});
                    } else {
                        uint off = (head * 2048u + (uint)row * 32u) * 2u;
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
                        uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                        #pragma unroll 1
                        for (uint head = 0; head < heads; ++head) {
                            esimd::simd<half,128> blk;
                            #pragma unroll
                            for (int kq = 0; kq < 8; ++kq) {
                                esimd::simd<half,8> a = esimd::slm_block_load<half,8>(
                                    Y0 + (head * 2048u + (kc2 * 16u + kq * 2u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                                esimd::simd<half,8> bv = esimd::slm_block_load<half,8>(
                                    Y0 + (head * 2048u + (kc2 * 16u + kq * 2u + 1u) * 32u + tc2 * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                                blk.template select<8,2>(kq * 16 + 0) = a;
                                blk.template select<8,2>(kq * 16 + 1) = bv;
                            }
                            esimd::slm_block_store(dst + head * 4096u + bidx * 256u, blk, esimd::overaligned_tag<16>{});
                        }
                    }
                    esimd::barrier();
                }
            }

            // ============ phase 2: wa stages 1-3 per head (slice-1 VERBATIM,
            //            stage-3 OUT -> ATT = QT[hh] instead of global 1277) ====
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
                                VT + hh * 4096u + (uint)(kc * 512 + lb) * 2u, esimd::overaligned_tag<16>{});
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
                    // B6: ATT_hh = QT + hh*4096 ([token][32] f16; the head-hh tiles
                    // are dead from here; head-(1-hh)'s tiles live in the OTHER 4KB
                    // sub-region of the same band -> no clash). The shipped chain
                    // wrote the f16 1277 plane here; its readers for THESE layers
                    // are only the fused quant below (census).
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float,8> r00 = d00.template select<8,1>(r*8), r01 = d01.template select<8,1>(r*8);
                        esimd::simd<float,8> r10 = d10.template select<8,1>(r*8), r11 = d11.template select<8,1>(r*8);
                        esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                        esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                        esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                        esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                        esimd::simd<half,16> j0; j0.template select<8,1>(0) = h00; j0.template select<8,1>(8) = h01;
                        esimd::simd<half,16> j1; j1.template select<8,1>(0) = h10; j1.template select<8,1>(8) = h11;
                        uint row0 = tr2 * 16u + (uint)r, row1 = row0 + 8u;
                        esimd::slm_block_store(QT + hh * 4096u + (row0 * 32u + (unsigned)tc2 * 16u) * 2u,
                                               j0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(QT + hh * 4096u + (row1 * 32u + (unsigned)tc2 * 16u) * 2u,
                                               j1, esimd::overaligned_tag<16>{});
                    }
                    esimd::barrier();
                }
            }

            // ============ phase 3b: attended quantize -> PKT (Z0) + AS2 ========
            #pragma unroll
            for (int t = 0; t < 4; ++t) {
                uint row = (uint)(t * 16 + (int)lid);
                esimd::simd<half,32> a0h = esimd::slm_block_load<half,32>(QT + (row * 32u) * 2u, esimd::overaligned_tag<16>{});
                esimd::simd<half,32> a1h = esimd::slm_block_load<half,32>(QT + 4096u + (row * 32u) * 2u, esimd::overaligned_tag<16>{});
                if (DbgATT) {   // ATT dump = the 1277 row the quant should see
                    esimd::block_store<half,32>(DbgATT + ((size_t)w*64u+row)*32u, a0h, esimd::overaligned_tag<16>{});
                    esimd::block_store<half,32>(DbgATT + ((size_t)w*64u+row)*32u + (size_t)windows*64u*32u, a1h, esimd::overaligned_tag<16>{});
                }

                esimd::simd<float,64> v;
                v.template select<32,1>(0) = esimd::convert<float>(a0h);
                v.template select<32,1>(32) = esimd::convert<float>(a1h);   // (1) was an OFFSET bug: lanes 1..32!
                float peak = esimd::hmax<float,float,64>(esimd::abs(v));
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::simd<float,64> qq = esimd::div_ieee<float,64>(v, esimd::simd<float,64>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,64>(qq), esimd::simd<float,64>(-127.f)), esimd::simd<float,64>(127.f));
                esimd::simd<int8_t,64> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                esimd::slm_block_store<int8_t,32>(Z0 + row * 32u, qi.template select<32,1>(0), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<int8_t,32>(Z0 + 2048u + row * 32u, qi.template select<32,1>(32), esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,1>(Z0 + 4096u + row * 4u, esimd::simd<float,1>(scale));
            }
            esimd::barrier();
            if (DbgPKT) {   // B6-1 bisect outlet: PKT row-major + AS per window
                #pragma unroll
                for (uint t2 = 0; t2 < 4u; ++t2) { uint row = t2*16u + lid;
                    esimd::block_store<int8_t,32>(DbgPKT + ((size_t)w*64u + row)*64u,
                        esimd::slm_block_load<int8_t,32>(Z0 + row*32u, esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                    esimd::block_store<int8_t,32>(DbgPKT + ((size_t)w*64u + row)*64u + 32u,
                        esimd::slm_block_load<int8_t,32>(Z0 + 2048u + row*32u, esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                    esimd::block_store<float,1>(DbgAS + (size_t)w*64u + row,
                        esimd::slm_block_load<float,1>(Z0 + 4096u + row * 4u));
                }
            }
            esimd::barrier();

            // ============ phase 3c: outproj gemm int8 64x64xK64 ================
            {
                const int SLM_BB3 = 2048;
                const int8_t* bp3 = dOp;
                auto load_block3 = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int8_t,128> bv = esimd::block_load<int8_t,128>(
                        bp3 + (size_t)kb * (64u * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(buf * SLM_BB3 + lid * 128u, bv, esimd::overaligned_tag<16>{});
                };
                int rb = (int)(lid / 2u), cb = (int)(lid % 2u);
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
                esimd::simd<float,16> cc2 = esimd::block_load<float,16>(cosv + gc0 + 16, esimd::overaligned_tag<16>{});
                esimd::simd<float,8> csl0=csl.template select<8,1>(0), csl1=csl.template select<8,1>(8);
                esimd::simd<float,8> csh0=csh.template select<8,1>(0), csh1=csh.template select<8,1>(8);
                esimd::simd<float,8> ccl0=ccl.template select<8,1>(0), ccl1=ccl.template select<8,1>(8);
                esimd::simd<float,8> cc20=cc2.template select<8,1>(0), cc21=cc2.template select<8,1>(8);
                #pragma unroll 1
                for (int r = 0; r < 8; ++r) {
                    uint token = (uint)(rb * 8 + r);
                    unsigned yy = (w / across) * 8u + token / 8u, xx = (w % across) * 8u + token % 8u;
                    bool in = (yy >= top && xx >= left && yy - top < image_h && xx - left < image_w);
                    if (!in) continue;
                    size_t out = ((size_t)(yy - top) * image_w + (xx - left)) * 64u + (size_t)gc0;
                    float rs = esimd::slm_block_load<float,1>(Z0 + 4096u + token * 4u)[0];
                    esimd::simd<float,8> f0 = esimd::convert<float>(o0.template select<8,1>(r*8).read()) * rs * csl0;
                    esimd::simd<float,8> f1 = esimd::convert<float>(o1.template select<8,1>(r*8).read()) * rs * csl1;
                    esimd::simd<float,8> f2 = esimd::convert<float>(o2.template select<8,1>(r*8).read()) * rs * csh0;
                    esimd::simd<float,8> f3 = esimd::convert<float>(o3.template select<8,1>(r*8).read()) * rs * csh1;
                    esimd::simd<half,16> sha = esimd::block_load<half,16>(dSkip + out, esimd::overaligned_tag<16>{});
                    esimd::simd<half,16> shb = esimd::block_load<half,16>(dSkip + out + 16u, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> sk0 = esimd::convert<float>(sha.template select<8,1>(0).read());
                    esimd::simd<float,8> sk1 = esimd::convert<float>(sha.template select<8,1>(8).read());
                    esimd::simd<float,8> sk2 = esimd::convert<float>(shb.template select<8,1>(0).read());
                    esimd::simd<float,8> sk3 = esimd::convert<float>(shb.template select<8,1>(8).read());
                    esimd::simd<float,16> pubA, pubB;
                    {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl0[e] + f0.read()[e]; t1[e] = sk1[e]*ccl1[e] + f1.read()[e]; }
                        pubA.template select<8,1>(0) = s8v8::pub_vec_v8<8>(1u, t0);
                        pubA.template select<8,1>(8) = s8v8::pub_vec_v8<8>(1u, t1);
                        esimd::simd<float,8> t2, t3;
                        for (int e = 0; e < 8; ++e) { t2[e] = sk2[e]*cc20[e] + f2.read()[e]; t3[e] = sk3[e]*cc21[e] + f3.read()[e]; }
                        pubB.template select<8,1>(0) = s8v8::pub_vec_v8<8>(1u, t2);
                        pubB.template select<8,1>(8) = s8v8::pub_vec_v8<8>(1u, t3);
                    }
                    esimd::convert<half>(pubA).copy_to(Out2 + out);
                    esimd::convert<half>(pubB).copy_to(Out2 + out + 16u);
                }
            }
        });
    });
}
}
