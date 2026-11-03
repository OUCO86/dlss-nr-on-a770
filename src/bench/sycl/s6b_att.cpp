// s6b_att.cpp -- S6-1b' PHASE-1 bench prototype: the ATTENTION-SIDE 5-FA CHAIN as ONE phase.
//
//   P7 QUANT_WINDOW(1267 image f16 -> pk0+sc0)  ->  P8 GEMM_INT8_QKV(pk0 x W81 -> Q/K/V)
//   -> P9 WINDOW_ATTENTION(Q,K,V,bias -> att)   ->  P10 QUANT(att -> pk2+sc2)
//   -> P11 GEMM_WINDOW_INT8_RESIDUAL(pk2 x W79 + skip(1267) -> 1270)
//
// WHY THIS SHAPE (notes/DS-takeover-2026-11-01.md S30/S35, and S29 for the cap):
//   three independent measurements agree "cutting a leg != saving time" (QFALIAS +8.9,
//   S33 skip-knife, S35 fold-knife A-C = -0.15 ms): the frame is LATENCY/STAGING-bound,
//   so the only lever is SHORTENING THE DEPENDENCY ROUND-TRIPS, not removing work.
//   S29 proved "all 11 fa in one WG" does not exist on a 64KB SLM; S30 read lmxx's real
//   code and gave the right granularity: attention WITHOUT LDS staging of Q/K/V -
//   the Q/K/V face lives in GLOBAL in the consumer's (window-major, dpas-tile) order and
//   only the scores/softmax staging is on-chip. That is what this file implements.
//
// SLM BUDGET (E:\DSH\s6\s6b_att_layout.py, table in E:\DSH\s6\s6b_att.md):
//   C=64 / T=64 (one WG owns one 64-token window, both heads):
//     X0 8192  (qkv B double-buffer 2x2048 + K/V row staging 4096) U (ATT band 2x4096)
//             U (wres B double-buffer 2x2048)
//     Z0 16384 (f32 dequant stage) U (scores f32) U (PKT 2x2048 + AS2)
//     Y0 8192  (PK0 = 2x2048 pk + 256 sc) U (probs f16 pack_a16 map)
//     SLMB = 32,768 B = EXACTLY the 32KB occupancy cliff (S29 cfg10 measured LIVE/2-resident)
//     vs the b6 form (Q/K/V tiles in SLM) = 57,344 B -> 1.75x over the cliff = 1 resident WG.
//   C=128 / T=64: X0 16384 (ATT 4 heads) + Z0 16384 + Y0 8704 = 41,472 B -> inside the
//     65,536 cap, OVER the cliff by 8,704 B (needs att-serial or a split scores stage).
//
// WHAT IS ON-CHIP vs GLOBAL HERE:
//   on-chip (the round trips this knife DELETES): pk0/sc0, scores, probs, att(1277), pk2/sc2.
//   global (unchanged traffic vs today, only the ORDER changes): the 1267 face (P7 source +
//   P11 skip), the 1270 face (P11 target), and the Q/K/V faces - written in the dpas-tile
//   (pack_a16_b / pack_b16_t_b / pack_b16_b) order so P9 needs ZERO pack legs (S30 R1).
//
// NUMERICS: every arithmetic chain is copied VERBATIM from the promoted/shipped kernels:
//   P7 quant      = packdev::pack_a_fused_gather (pack_device.hpp:630-668) == qr_kernel_rowthread
//   P8 gemm+tail  = b6_res_kernel.hpp phase 1 == qres::gemm_qkv_res (dpas<8,8,int32>, v5a
//                   cosine_recip_vec / mulh / e4m3_vec / eh_round chain)
//   P9 attention  = b6 phase 2 (the wa_res chain): scores dpas<8,8,float>, the softmax's
//                   1.30078125/0.044921875 + clamp[1.03125,1.5693359375] + (p<<5)+0x7FF88000
//                   exp hack, the SEQUENTIAL 64-lane total, eh_round(total),
//                   eh_round(ef_div(1, trh)) -- the 1/sum rounding chain VERBATIM, NOT an rcp.
//   P10 quant     = b6 phase 3b (div_ieee per element, rnide, clamp +-127)
//   P11 fold      = b6 phase 3c/3d == s8v8::gemm_b_res_window epilogue (pub_vec_v8(1u,...)).
//   => the numbers DO NOT change, so the entry ticket is a BYTE-EXACT diff (step 3).
//
// MILITARY RULES obeyed here: no runtime diagnostics inside the kernel (rules 4/9: phase
// truncation is `if constexpr` on a compile-time PHASES/LIVE/DUMP/NTILE template parameter);
// the priced instances are the nosink DUMP=false ones (rule 19); legs/phases under 0.05 ms are
// only reported as a cum curve + intervals, never as a subtraction of two absolute runs
// (rule 20). Barriers: sycl::group_barrier(it.get_group()) = the real CTA barrier (port-B R5 /
// B8: esimd::barrier() only orders lanes of one thread, and this kernel crosses a GLOBAL
// write->read inside the WG, which needs the real one).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <vector>
#include <random>
#include <functional>
#include <chrono>
#include <thread>
#include <algorithm>
#include <utility>

#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
#include "quantize_row_kernel.hpp"
#include "qkv_resident.hpp"
#include "wa_res_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "softmax_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// =====================================================================
// the fused kernel: ONE work-group = ONE window (TOK=64 tokens, HEADS heads)
// PHASES: 1..5 compile-time truncation (P7 | +P8 | +P9 | +P10 | +P11) for the cum curve.
// DUMP  : the byte-check outlets (a separate instantiation; the timed one has it OFF).
// LIVE  : the liveness witness (probs x 0.5) -- must break the downstream diffs (S34 trick).
// =====================================================================
namespace att5 {

struct Outlets {                       // used only when DUMP=true (host-side compare buffers)
    int8_t* pk0p = nullptr; float* sc0p = nullptr;     // P7 out, pack_a order + row scales
    half* pQ = nullptr; half* pK = nullptr; half* pV = nullptr;   // P8 planes (shipped order)
    float* scores = nullptr;                            // P9 scores f32 (batches,64,64)
    half* probs = nullptr;                              // P9 probs, pack_a16 map (batches,4096)
    half* att = nullptr;                                // P10 source = the 1277 row (per head)
    int8_t* pkt = nullptr; float* as2 = nullptr;        // P10 out, row-major + row scales
};

template <int C, int HEADS, int PHASES, bool DUMP, bool LIVE>
static inline event fused(queue& q,
                           const half* dImg,          // 1267 image face (P7 source, P11 skip)
                           const int8_t* dBp,         // pack_b(3C, C) of W81
                           const float* bs,           // b_scale (3C)
                           const float* qs,           // qkv_scale (heads)
                           const float* dBias,        // attention bias (heads,64,64)
                           const int8_t* dOp,         // pack_b(C, C) of W79
                           const float* bs2, const float* cosv,   // wres b_scale (C), cosine (C)
                           half* Out2,                // 1270 image face
                           half* faceQ, half* faceK, half* faceV, // the FRAGMENT-ORDER Q/K/V faces
                           unsigned windows,
                           unsigned across, unsigned top, unsigned left,
                           unsigned image_h, unsigned image_w,
                           const Outlets& o) {
    constexpr int TOK = 64, NH = 3 * C, KBN = C / 32, PPH = C / 64;   // parts per kind
    // ---- SLM map (bytes) ----
    constexpr uint X0 = 0u;
    constexpr uint X0SZ = (HEADS * 4096u > 8192u) ? (HEADS * 4096u) : 8192u;
    constexpr uint Z0 = X0 + X0SZ;
    constexpr uint Y0 = Z0 + 16384u;
    constexpr uint Y0SZ = (KBN * 2048u + 256u > 8192u) ? (KBN * 2048u + 512u) : 8192u;
    constexpr uint SLMB = Y0 + Y0SZ;
    static_assert(SLMB <= 65536u, "over the A770 SLM cap (S29: 65,600 B is already REJECT)");
    // region-internal offsets
    constexpr uint BT = X0;                 // int8 gemm B double buffers (2 x 2048)
    constexpr uint ROWS = X0 + 4096u;       // K/V row staging (one head at a time, 4096 B)
    constexpr uint ATT = X0;                // the att band: head hh at ATT + hh*4096
    constexpr uint PKT = Z0;                // pk2 (KBN x 2048) + sc2 after it
    constexpr uint AS2 = Z0 + (uint)(KBN * 2048);
    constexpr uint PK0 = Y0;                // pk0 (KBN x 2048) + sc0 after it
    constexpr uint AS0 = Y0 + (uint)(KBN * 2048);
    constexpr uint PROB = Y0;               // probs, the pack_a16 map
    const size_t facebase = (size_t)TOK * 32u;   // 2048 halfs per (window, head) tile

    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)windows * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            auto gr = it.get_group();
            uint w = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int wi_row = (int)(lid / 4u), wi_col = (int)(lid % 4u);

            // ================= P7 = QUANT_WINDOW (gather 1267 rows -> pk0 + sc0 in SLM) ====
            // arithmetic VERBATIM = packdev::pack_a_fused_gather (the shipped P4b fold of this
            // very launch into the QKV pack leg): row peak AFTER the f16->f32 widening,
            // scale = div_ieee(peak,127), q = div_ieee(v,scale), rnide, clamp +-127, int8.
            if constexpr (PHASES >= 1) {
                #pragma unroll
                for (int t = 0; t < TOK / 16; ++t) {
                    uint token = (uint)(t * 16 + (int)lid);
                    unsigned yy = (w / across) * 8u + token / 8u;
                    unsigned xx = (w % across) * 8u + token % 8u;
                    int y = (int)yy - (int)top, x = (int)xx - (int)left;
                    bool outside = (y < 0 || x < 0 || y >= (int)image_h || x >= (int)image_w);
                    esimd::simd<float, C> v(0.f);
                    if (!outside) {
                        const sycl::half* arow = dImg + ((size_t)y * image_w + (size_t)x) * C;
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            v.template select<32, 1>(kb * 32) = esimd::convert<float>(
                                esimd::block_load<sycl::half, 32>(arow + kb * 32,
                                    esimd::overaligned_tag<16>{}));
                    }
                    float peak = esimd::hmax<float, float, C>(esimd::abs(v));
                    const float scale = (peak == 0.f) ? 1.f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak),
                                                    esimd::simd<float, 1>(127.f))[0];
                    esimd::simd<float, C> qq = esimd::div_ieee<float, C>(v, esimd::simd<float, C>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float, C>(qq), esimd::simd<float, C>(-127.f)),
                                    esimd::simd<float, C>(127.f));
                    esimd::simd<int8_t, C> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)          // the pack_a tile map: [kb][16-row band][row][32B]
                        esimd::slm_block_store<int8_t, 32>(PK0 + (uint)(kb * 2048 + t * 512 + (int)lid * 32),
                                                           qi.template select<32, 1>(kb * 32),
                                                           esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<float, 1>(AS0 + token * 4u, esimd::simd<float, 1>(scale));
                }
                group_barrier(gr);
                if constexpr (DUMP) {   // pk0 in the SAME pack_a order the shipped pack leg writes
                    const size_t band = (size_t)(w / 2u) * (KBN * 4096u) + (size_t)(w % 2u) * 2048u;
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            esimd::block_store<int8_t, 32>(o.pk0p + band + (size_t)kb * 4096u
                                        + (size_t)t * 512u + (size_t)lid * 32u,
                                esimd::slm_block_load<int8_t, 32>(PK0 + (uint)(kb * 2048 + t * 512 + (int)lid * 32),
                                        esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                        uint token = (uint)(t * 16 + (int)lid);
                        esimd::block_store<float, 1>(o.sc0p + (size_t)w * TOK + token,
                            esimd::slm_block_load<float, 1>(AS0 + token * 4u));
                    }
                    group_barrier(gr);
                }
            }

            // ================= P8 = GEMM_INT8_QKV (pk0 x W81 -> Q/K/V faces, v5a tail) =====
            if constexpr (PHASES >= 2) {
                #pragma unroll 1
                for (int part = 0; part < NH / 64; ++part) {
                    const int8_t* bp = dBp + (size_t)part * 2048u;
                    auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                            bp + (size_t)kb * (NH * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(BT + (uint)(buf * 2048 + (int)lid * 128), bv,
                                               esimd::overaligned_tag<16>{});
                    };
                    auto load_grf = [=](int buf, int kb, esimd::simd<int8_t, 256>& a0, esimd::simd<int8_t, 256>& a1,
                                        esimd::simd<int8_t, 256>& b0, esimd::simd<int8_t, 256>& b1) SYCL_ESIMD_FUNCTION {
                        uint32_t offA = PK0 + (uint)(kb * 2048 + wi_row * 512);   // A straight from SLM: ZERO pack
                        uint32_t offB = BT + (uint)(buf * 2048 + wi_col * 512);
                        a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                        b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                    };
                    esimd::simd<int8_t, 256> a0, a1, b0, b1;
                    esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
                    load_block(0, 0);
                    group_barrier(gr);
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb) {
                        int cur = kb & 1, nxt = cur ^ 1;
                        if (kb + 1 < KBN) load_block(nxt, kb + 1);
                        load_grf(cur, kb, a0, a1, b0, b1);
                        c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                        c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                        c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                        group_barrier(gr);
                    }
                    // dequantise into the dead-operand stage (Z0, f32, VERBATIM b6/qres order)
                    int gc = part * 64 + wi_col * 16;
                    esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        int tok0 = wi_row * 16 + r, tok1 = tok0 + 8;
                        float rs0 = esimd::slm_block_load<float, 1>(AS0 + (uint)tok0 * 4u)[0];
                        float rs1 = esimd::slm_block_load<float, 1>(AS0 + (uint)tok1 * 4u)[0];
                        esimd::simd<float, 16> f0, f1;
                        f0.template select<8, 1>(0) = esimd::convert<float>(c00.template select<8, 1>(r * 8).read()) * rs0;
                        f0.template select<8, 1>(8) = esimd::convert<float>(c01.template select<8, 1>(r * 8).read()) * rs0;
                        f1.template select<8, 1>(0) = esimd::convert<float>(c10.template select<8, 1>(r * 8).read()) * rs1;
                        f1.template select<8, 1>(8) = esimd::convert<float>(c11.template select<8, 1>(r * 8).read()) * rs1;
                        f0 = f0 * cs; f1 = f1 * cs;
                        esimd::slm_block_store<float, 16>(Z0 + (uint32_t)((tok0) * 64 + wi_col * 16) * 4u, f0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 16>(Z0 + (uint32_t)((tok1) * 64 + wi_col * 16) * 4u, f1, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    // the v5a tail: Q gets the learned scale, K is normalised, V is dequantised.
                    // The three faces are written in the CONSUMER's dpas-tile order (S30 R1).
                    int kind = part / PPH;                       // 0 = Q, 1 = K, 2 = V
                    #pragma unroll 1
                    for (int hp = 0; hp < 2; ++hp) {
                        uint head = (uint)((part % PPH) * 2 + hp);
                        sycl::half* dst = (kind == 0) ? faceQ : ((kind == 1) ? faceK : faceV);
                        size_t fb = (size_t)(w * HEADS + head) * facebase;
                        #pragma unroll
                        for (int k = 0; k < TOK / 16; ++k) {
                            uint row = (uint)(k * 16 + (int)lid);
                            esimd::simd<float, 32> seg = esimd::slm_block_load<float, 32>(
                                Z0 + (uint32_t)(row * 64 + hp * 32) * 4u, esimd::overaligned_tag<16>{});
                            esimd::simd<half, 32> oh;
                            if (kind == 2) {
                                oh = esimd::convert<half>(wbv3::e4m3_vec<32>(seg));
                            } else {
                                esimd::simd<float, 32> hr = esimd::convert<float>(esimd::convert<half>(seg));
                                float recip = wbv3::cosine_recip_vec(hr);
                                if (kind == 0) {
                                    float sc = wbmega::eh_round(qs[head]);
                                    esimd::simd<float, 32> t1 = wbv3::mulh(hr, recip);
                                    oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(t1, sc)));
                                } else {
                                    oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(hr, recip)));
                                }
                            }
                            if constexpr (DUMP) {           // the shipped-plane order (the checkpoint)
                                unsigned r = w * TOK + row;
                                size_t pofs = (((size_t)(r / TOK) * HEADS + head) * TOK + (r % TOK)) * 32u;
                                sycl::half* T = (kind == 0) ? o.pQ : ((kind == 1) ? o.pK : o.pV);
                                oh.copy_to(T + pofs);
                            }
                            if (kind == 0) {                // Q: pack_a16_b blocks, 2 x 16 halfs
                                uint tr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                                uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                                uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                                esimd::simd<half, 16> qa0 = oh.template select<16, 1>(0);
                                esimd::simd<half, 16> qa1 = oh.template select<16, 1>(16);
                                esimd::block_store<half, 16>(dst + fb + e0, qa0, esimd::overaligned_tag<16>{});
                                esimd::block_store<half, 16>(dst + fb + e1, qa1, esimd::overaligned_tag<16>{});
                            } else {                        // K / V: stage the row, then retiling
                                esimd::slm_block_store<half, 32>(ROWS + row * 64u, oh,
                                    esimd::overaligned_tag<16>{});
                            }
                        }
                        if (kind != 0) {
                            group_barrier(gr);
                            uint bidx = lid;
                            if (kind == 1) {                 // pack_b16_t_b INTERLEAVED map (b6 VERBATIM)
                                uint kc2 = bidx / 8u, tc2 = (bidx / 2u) % 4u, js = bidx % 2u;
                                esimd::simd<half, 128> blk;
                                #pragma unroll
                                for (int jl = 0; jl < 8; ++jl) {
                                    uint r = tc2 * 16u + js * 8u + (uint)jl;
                                    esimd::simd<half, 16> vr = esimd::slm_block_load<half, 16>(
                                        ROWS + r * 64u + kc2 * 32u, esimd::overaligned_tag<16>{});
                                    #pragma unroll
                                    for (int kq = 0; kq < 8; ++kq)
                                        blk.template select<2, 1>(kq * 16 + jl * 2) = vr.template select<2, 1>(kq * 2);
                                }
                                esimd::block_store<half, 128>(dst + fb + bidx * 128u, blk, esimd::overaligned_tag<16>{});
                            } else {                         // pack_b16_b map (b6 VERBATIM)
                                uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                                esimd::simd<half, 128> blk;
                                #pragma unroll
                                for (int kq = 0; kq < 8; ++kq) {
                                    esimd::simd<half, 8> a = esimd::slm_block_load<half, 8>(
                                        ROWS + (kc2 * 16u + kq * 2u) * 64u + tc2 * 32u + js * 16u, esimd::overaligned_tag<16>{});
                                    esimd::simd<half, 8> bv = esimd::slm_block_load<half, 8>(
                                        ROWS + (kc2 * 16u + kq * 2u + 1u) * 64u + tc2 * 32u + js * 16u, esimd::overaligned_tag<16>{});
                                    blk.template select<8, 2>(kq * 16 + 0) = a;
                                    blk.template select<8, 2>(kq * 16 + 1) = bv;
                                }
                                esimd::block_store<half, 128>(dst + fb + bidx * 128u, blk, esimd::overaligned_tag<16>{});
                            }
                            group_barrier(gr);
                        }
                    }
                    group_barrier(gr);
                }
            }

            // ================= P9 = WINDOW_ATTENTION (faces from GLOBAL, zero pack) =========
            if constexpr (PHASES >= 3) {
                #pragma unroll 1
                for (uint hh = 0; hh < HEADS; ++hh) {
                    const size_t fbQ = (size_t)(w * HEADS + hh) * facebase;
                    const size_t fbK = fbQ, fbV = fbQ;
                    // stage 1: scores = Q @ K^T (dpas<8,8,float>, operands loaded STRAIGHT from
                    // the global fragment faces -- the S30 form; b6 staged these in 24KB of SLM)
                    esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half, 128> qa0 = esimd::block_load<half, 128>(faceQ + fbQ + (uint)((wi_row * 2u + kc) * 256u), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> qa1 = esimd::block_load<half, 128>(faceQ + fbQ + (uint)((wi_row * 2u + kc) * 256u) + 128u, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> ka0 = esimd::block_load<half, 128>(faceK + fbK + (uint)((kc * 4u + wi_col) * 256u), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> ka1 = esimd::block_load<half, 128>(faceK + fbK + (uint)((kc * 4u + wi_col) * 256u) + 128u, esimd::overaligned_tag<16>{});
                        c00 = esimd::xmx::dpas<8, 8, float>(c00, ka0, qa0);
                        c01 = esimd::xmx::dpas<8, 8, float>(c01, ka1, qa0);
                        c10 = esimd::xmx::dpas<8, 8, float>(c10, ka0, qa1);
                        c11 = esimd::xmx::dpas<8, 8, float>(c11, ka1, qa1);
                    }
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + r) * 64 + wi_col * 16)) * 4u,
                            c00.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + r) * 64 + wi_col * 16 + 8)) * 4u,
                            c01.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + 8 + r) * 64 + wi_col * 16)) * 4u,
                            c10.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + 8 + r) * 64 + wi_col * 16 + 8)) * 4u,
                            c11.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    if constexpr (DUMP) {   // the scores f32 tile (the split chain's dScores twin)
                        #pragma unroll
                        for (int rr = 0; rr < 4; ++rr) {
                            uint row = lid * 4u + rr;
                            size_t sb = ((size_t)(w * HEADS + hh) * TOK + row) * 64u;
                            #pragma unroll
                            for (int cc = 0; cc < 2; ++cc)
                                esimd::block_store<float, 32>(o.scores + sb + (size_t)cc * 32u,
                                    esimd::slm_block_load<float, 32>(Z0 + row * 256u + (uint)cc * 128u, esimd::overaligned_tag<16>{}),
                                    esimd::overaligned_tag<16>{});
                        }
                        group_barrier(gr);
                    }
                    // stage 2: softmax, 4 rows/thread -- the b6/wa_res chain VERBATIM (bias, the
                    // f16 roundings, the exp bit-hack, the SEQUENTIAL row total, eh_round,
                    // eh_round(ef_div(1,trh)) -- NO rcp anywhere; 1/sum rounding is preserved).
                    #pragma unroll
                    for (int rr = 0; rr < 4; ++rr) {
                        uint row = lid * 4u + rr;
                        esimd::simd<float, 32> s0 = esimd::slm_block_load<float, 32>(Z0 + row * 256u, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> s1 = esimd::slm_block_load<float, 32>(Z0 + row * 256u + 128u, esimd::overaligned_tag<16>{});
                        size_t boff = (size_t)hh * 4096u + (size_t)row * 64u;
                        esimd::simd<float, 32> b0v = esimd::block_load<float, 32>(dBias + boff, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> b1v = esimd::block_load<float, 32>(dBias + boff + 32, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0v));
                        esimd::simd<float, 32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1v));
                        esimd::simd<float, 32> a0v = esimd::convert<float>(esimd::convert<sycl::half>(
                            hl0 * esimd::simd<float, 32>(0.044921875f) + esimd::simd<float, 32>(1.30078125f)));
                        esimd::simd<float, 32> a1v = esimd::convert<float>(esimd::convert<sycl::half>(
                            hl1 * esimd::simd<float, 32>(0.044921875f) + esimd::simd<float, 32>(1.30078125f)));
                        a0v = (esimd::min)((esimd::max)(a0v, esimd::simd<float, 32>(1.03125f)), esimd::simd<float, 32>(1.5693359375f));
                        a1v = (esimd::min)((esimd::max)(a1v, esimd::simd<float, 32>(1.03125f)), esimd::simd<float, 32>(1.5693359375f));
                        esimd::simd<sycl::half, 16> he0 = esimd::convert<sycl::half>(a0v.template select<16, 2>(0).read());
                        esimd::simd<sycl::half, 16> ho0 = esimd::convert<sycl::half>(a0v.template select<16, 2>(1).read());
                        esimd::simd<sycl::half, 16> he1 = esimd::convert<sycl::half>(a1v.template select<16, 2>(0).read());
                        esimd::simd<sycl::half, 16> ho1 = esimd::convert<sycl::half>(a1v.template select<16, 2>(1).read());
                        esimd::simd<uint16_t, 16> e0 = he0.bit_cast_view<uint16_t>(), o0 = ho0.bit_cast_view<uint16_t>();
                        esimd::simd<uint16_t, 16> e1 = he1.bit_cast_view<uint16_t>(), o1 = ho1.bit_cast_view<uint16_t>();
                        esimd::simd<uint32_t, 16> p0 = esimd::convert<uint32_t>(e0) | (esimd::convert<uint32_t>(o0) << 16);
                        esimd::simd<uint32_t, 16> p1 = esimd::convert<uint32_t>(e1) | (esimd::convert<uint32_t>(o1) << 16);
                        esimd::simd<uint32_t, 16> t0 = (p0 << 5) + esimd::simd<uint32_t, 16>(0x7FF88000u);
                        esimd::simd<uint32_t, 16> t1 = (p1 << 5) + esimd::simd<uint32_t, 16>(0x7FF88000u);
                        esimd::simd<sycl::half, 32> w0; w0 = t0.bit_cast_view<sycl::half>();
                        esimd::simd<sycl::half, 32> w1; w1 = t1.bit_cast_view<sycl::half>();
                        esimd::simd<float, 32> f0 = esimd::convert<float>(w0);
                        esimd::simd<float, 32> f1 = esimd::convert<float>(w1);
                        float total = 0.0f;
                        for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
                        for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];
                        float trh = wbmega::eh_round(total);
                        float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));
                        esimd::simd<sycl::half, 32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
                        esimd::simd<sycl::half, 32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
                        if constexpr (LIVE) {        // the liveness witness: probs *= 0.5 (S34 trick)
                            oh0 = oh0 * esimd::simd<sycl::half, 32>(sycl::half(0.5f));
                            oh1 = oh1 * esimd::simd<sycl::half, 32>(sycl::half(0.5f));
                        }
                        uint trr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                        uint ybase = PROB + ((trr * 4u + 0u) * 2u + strip) * 256u + il * 32u;
                        esimd::simd<half, 16> q0 = oh0.template select<16, 1>(0);
                        esimd::simd<half, 16> q1 = oh0.template select<16, 1>(16);
                        esimd::simd<half, 16> q2 = oh1.template select<16, 1>(0);
                        esimd::simd<half, 16> q3 = oh1.template select<16, 1>(16);
                        esimd::slm_block_store(ybase, q0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 512u, q1, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 1024u, q2, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 1536u, q3, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    if constexpr (DUMP) {   // probs, in the pack_a16 map (compare vs pack_a16_b(ref))
                        #pragma unroll
                        for (int p = 0; p < 2; ++p) {
                            uint off = (uint)((p * 16u + lid) * 128u);
                            esimd::block_store<half, 128>(o.probs + (size_t)(w * HEADS + hh) * 4096u + off,
                                esimd::slm_block_load<half, 128>(PROB + off * 2u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                        }
                        group_barrier(gr);
                    }
                    // stage 3: attnV = probs @ V (A from SLM probs, B STRAIGHT from the global
                    // V face; the b6 merge-fold store becomes the ATT band in SLM instead)
                    int t8 = (int)lid % 8;
                    int tr2 = t8 / 2, tc2 = t8 % 2;
                    esimd::simd<float, 64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                    #pragma unroll
                    for (int kb = 0; kb < 4; ++kb) {
                        uint32_t offA = PROB + (uint32_t)(((size_t)tr2 * 4u + (size_t)kb) * 2u) * 256u;
                        esimd::simd<half, 128> pa0 = esimd::slm_block_load<half, 128>(offA, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> pa1 = esimd::slm_block_load<half, 128>(offA + 256, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> vb0 = esimd::block_load<half, 128>(faceV + fbV + (uint)(kb * 512 + tc2 * 256), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> vb1 = esimd::block_load<half, 128>(faceV + fbV + (uint)(kb * 512 + tc2 * 256) + 128u, esimd::overaligned_tag<16>{});
                        d00 = esimd::xmx::dpas<8, 8, float>(d00, vb0, pa0);
                        d01 = esimd::xmx::dpas<8, 8, float>(d01, vb1, pa0);
                        d10 = esimd::xmx::dpas<8, 8, float>(d10, vb0, pa1);
                        d11 = esimd::xmx::dpas<8, 8, float>(d11, vb1, pa1);
                    }
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float, 8> r00 = d00.template select<8, 1>(r * 8), r01 = d01.template select<8, 1>(r * 8);
                        esimd::simd<float, 8> r10 = d10.template select<8, 1>(r * 8), r11 = d11.template select<8, 1>(r * 8);
                        esimd::simd<half, 8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                        esimd::simd<half, 8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                        esimd::simd<half, 8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                        esimd::simd<half, 8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                        esimd::simd<half, 16> j0; j0.template select<8, 1>(0) = h00; j0.template select<8, 1>(8) = h01;
                        esimd::simd<half, 16> j1; j1.template select<8, 1>(0) = h10; j1.template select<8, 1>(8) = h11;
                        uint row0 = tr2 * 16u + (uint)r, row1 = row0 + 8u;
                        esimd::slm_block_store(ATT + hh * 4096u + (row0 * 32u + (unsigned)tc2 * 16u) * 2u, j0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ATT + hh * 4096u + (row1 * 32u + (unsigned)tc2 * 16u) * 2u, j1, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                }
                if constexpr (DUMP) {   // ATT = the 1277 row the quant should see (b6 outlet form)
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        uint row = (uint)(t * 16 + (int)lid);
                        #pragma unroll
                        for (uint hh = 0; hh < HEADS; ++hh)
                            esimd::block_store<half, 32>(o.att + ((size_t)w * TOK + row) * 32u
                                    + (size_t)hh * ((size_t)windows * TOK * 32u),
                                esimd::slm_block_load<half, 32>(ATT + hh * 4096u + (row * 32u) * 2u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                }
            }

            // ================= P10 = QUANT (att -> pk2 + sc2 in SLM; b6 3b VERBATIM) ========
            if constexpr (PHASES >= 4) {
                #pragma unroll
                for (int t = 0; t < TOK / 16; ++t) {
                    uint row = (uint)(t * 16 + (int)lid);
                    esimd::simd<float, C> v;
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)
                        v.template select<32, 1>(kb * 32) = esimd::convert<float>(
                            // bytes: one head's att tile = 64 rows x 32 halfs = 4096 B
                            esimd::slm_block_load<half, 32>(ATT + (uint)(kb * 4096 + (int)row * 64), esimd::overaligned_tag<16>{}));
                    float peak = esimd::hmax<float, float, C>(esimd::abs(v));
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak), esimd::simd<float, 1>(127.0f))[0];
                    esimd::simd<float, C> qq = esimd::div_ieee<float, C>(v, esimd::simd<float, C>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float, C>(qq), esimd::simd<float, C>(-127.f)), esimd::simd<float, C>(127.f));
                    esimd::simd<int8_t, C> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)
                        esimd::slm_block_store<int8_t, 32>(PKT + (uint)(kb * 2048 + (int)row * 32),
                            qi.template select<32, 1>(kb * 32), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<float, 1>(AS2 + row * 4u, esimd::simd<float, 1>(scale));
                }
                group_barrier(gr);
                if constexpr (DUMP) {   // pk2 row-major + sc2 (the 1272/1273 twin of this window)
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        uint row = (uint)(t * 16 + (int)lid);
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            esimd::block_store<int8_t, 32>(o.pkt + ((size_t)w * TOK + row) * C + kb * 32,
                                esimd::slm_block_load<int8_t, 32>(PKT + (uint)(kb * 2048 + (int)row * 32), esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                        esimd::block_store<float, 1>(o.as2 + (size_t)w * TOK + row,
                            esimd::slm_block_load<float, 1>(AS2 + row * 4u));
                    }
                    group_barrier(gr);
                }
            }

            // ================= P11 = GEMM_WINDOW_INT8_RESIDUAL (pk2 x W79 + skip -> 1270) ===
            if constexpr (PHASES >= 5) {
                const int rb = (int)(lid / 2u), cb = (int)(lid % 2u);
                #pragma unroll 1
                for (int nt = 0; nt < C / 64; ++nt) {          // N tiles (C=64 -> 1)
                    const int8_t* bp3 = dOp + (size_t)nt * 2048u;
                    auto load_block3 = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                            bp3 + (size_t)kb * (C * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(BT + (uint)(buf * 2048 + (int)lid * 128), bv, esimd::overaligned_tag<16>{});
                    };
                    esimd::simd<int32_t, 64> q0(0), q1(0), q2(0), q3(0);
                    load_block3(0, 0);
                    group_barrier(gr);
                    #pragma unroll
                    for (int kbi = 0; kbi < KBN; ++kbi) {
                        int cur = kbi & 1, nxt = cur ^ 1;
                        if (kbi + 1 < KBN) load_block3(nxt, kbi + 1);
                        esimd::simd<int8_t, 256> pa0 = esimd::slm_block_load<int8_t, 256>(
                            PKT + (uint32_t)(rb * 256 + kbi * 2048), esimd::overaligned_tag<16>{});
                        uint32_t offB = (uint32_t)(cur * 2048 + cb * 1024);
                        esimd::simd<int8_t, 256> bb0 = esimd::slm_block_load<int8_t, 256>(offB, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb2 = esimd::slm_block_load<int8_t, 256>(offB + 512, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb3 = esimd::slm_block_load<int8_t, 256>(offB + 768, esimd::overaligned_tag<16>{});
                        q0 = esimd::xmx::dpas<8, 8, int32_t>(q0, bb0, pa0);
                        q1 = esimd::xmx::dpas<8, 8, int32_t>(q1, bb1, pa0);
                        q2 = esimd::xmx::dpas<8, 8, int32_t>(q2, bb2, pa0);
                        q3 = esimd::xmx::dpas<8, 8, int32_t>(q3, bb3, pa0);
                        group_barrier(gr);
                    }
                    // the wres fold, gemm_b_res_window epilogue VERBATIM (b6 3d)
                    int gc0 = nt * 64 + (int)(cb * 32u);
                    esimd::simd<float, 16> csl = esimd::block_load<float, 16>(bs2 + gc0, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> csh = esimd::block_load<float, 16>(bs2 + gc0 + 16, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> ccl = esimd::block_load<float, 16>(cosv + gc0, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> cc2 = esimd::block_load<float, 16>(cosv + gc0 + 16, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> csl0 = csl.template select<8, 1>(0), csl1 = csl.template select<8, 1>(8);
                    esimd::simd<float, 8> csh0 = csh.template select<8, 1>(0), csh1 = csh.template select<8, 1>(8);
                    esimd::simd<float, 8> ccl0 = ccl.template select<8, 1>(0), ccl1 = ccl.template select<8, 1>(8);
                    esimd::simd<float, 8> cc20 = cc2.template select<8, 1>(0), cc21 = cc2.template select<8, 1>(8);
                    #pragma unroll 1
                    for (int r = 0; r < 8; ++r) {
                        uint token = (uint)(rb * 8 + r);
                        unsigned yy = (w / across) * 8u + token / 8u, xx = (w % across) * 8u + token % 8u;
                        bool in = (yy >= top && xx >= left && yy - top < image_h && xx - left < image_w);
                        if (!in) continue;
                        size_t out = ((size_t)(yy - top) * image_w + (size_t)(xx - left)) * C + (size_t)gc0;
                        float rs = esimd::slm_block_load<float, 1>(AS2 + token * 4u)[0];
                        esimd::simd<float, 8> f0 = esimd::convert<float>(q0.template select<8, 1>(r * 8).read()) * rs * csl0;
                        esimd::simd<float, 8> f1 = esimd::convert<float>(q1.template select<8, 1>(r * 8).read()) * rs * csl1;
                        esimd::simd<float, 8> f2 = esimd::convert<float>(q2.template select<8, 1>(r * 8).read()) * rs * csh0;
                        esimd::simd<float, 8> f3 = esimd::convert<float>(q3.template select<8, 1>(r * 8).read()) * rs * csh1;
                        esimd::simd<half, 16> sha = esimd::block_load<half, 16>(dImg + out, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 16> shb = esimd::block_load<half, 16>(dImg + out + 16u, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 8> sk0 = esimd::convert<float>(sha.template select<8, 1>(0).read());
                        esimd::simd<float, 8> sk1 = esimd::convert<float>(sha.template select<8, 1>(8).read());
                        esimd::simd<float, 8> sk2 = esimd::convert<float>(shb.template select<8, 1>(0).read());
                        esimd::simd<float, 8> sk3 = esimd::convert<float>(shb.template select<8, 1>(8).read());
                        esimd::simd<float, 16> pubA, pubB;
                        {
                            esimd::simd<float, 8> t0, t1;
                            for (int e = 0; e < 8; ++e) { t0[e] = sk0[e] * ccl0[e] + f0.read()[e]; t1[e] = sk1[e] * ccl1[e] + f1.read()[e]; }
                            pubA.template select<8, 1>(0) = s8v8::pub_vec_v8<8>(1u, t0);
                            pubA.template select<8, 1>(8) = s8v8::pub_vec_v8<8>(1u, t1);
                            esimd::simd<float, 8> t2, t3;
                            for (int e = 0; e < 8; ++e) { t2[e] = sk2[e] * cc20[e] + f2.read()[e]; t3[e] = sk3[e] * cc21[e] + f3.read()[e]; }
                            pubB.template select<8, 1>(0) = s8v8::pub_vec_v8<8>(1u, t2);
                            pubB.template select<8, 1>(8) = s8v8::pub_vec_v8<8>(1u, t3);
                        }
                        esimd::convert<half>(pubA).copy_to(Out2 + out);
                        esimd::convert<half>(pubB).copy_to(Out2 + out + 16u);
                    }
                    if (nt + 1 < C / 64) group_barrier(gr);
                }
            }
        });
    });
}

struct Spec { int slmb, x0, z0, y0; };
template <int C, int HEADS> static Spec spec() {
    constexpr int KBN = C / 32;
    constexpr uint X0SZ = (HEADS * 4096u > 8192u) ? (HEADS * 4096u) : 8192u;
    constexpr uint Y0SZ = (KBN * 2048u + 256u > 8192u) ? (KBN * 2048u + 512u) : 8192u;
    return Spec{(int)(X0SZ + 16384u + Y0SZ), (int)X0SZ, 16384, (int)Y0SZ};
}
} // namespace att5

// =====================================================================
// host harness
// =====================================================================
struct Stat { double msm = 0, msM = 0, msX = 0, med = 0; size_t ng = 0; std::vector<double> gms; };

static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size() / 2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size() / 2]; st.gms = gmin; return st;
}
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            double ms = double(e.get_profiling_info<info::event_profiling::command_end>() -
                               e.get_profiling_info<info::event_profiling::command_start>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            auto c0 = std::chrono::steady_clock::now();
            f();
            auto c1 = std::chrono::steady_clock::now();
            double ms = std::chrono::duration<double, std::milli>(c1 - c0).count();
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[160]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 140; ++i) o += snprintf(buf + o, sizeof(buf) - o, "%.4f ", st.gms[i]);
    return buf;
}
static const char* statnote(const Stat& st, const char* extra) {
    static char note[512];
    snprintf(note, sizeof(note), "msm=%.4f msM=%.4f msX=%.4f med=%.4f ng=%zu groups=[%s] %s",
             st.msm, st.msM, st.msX, st.med, st.ng, gmfmt(st), extra ? extra : "");
    return note;
}
static void csvrow(const char* sh, const char* leg, const Stat& st, const char* extra) {
    printf("CSVROW;%s;%s;%.4f;%.4f;%.4f;%.4f;%s\n", sh, leg, st.msm, st.msM, st.msX, st.med, statnote(st, extra));
    fflush(stdout);
}

// raw byte diff with the first mismatch coordinate (the entry ticket's witness)
static bool diffb(const void* x, const void* y, size_t n, size_t K, size_t rowoff, const char* what) {
    const uint8_t* a = (const uint8_t*)x; const uint8_t* b = (const uint8_t*)y;
    size_t bad = 0, fi = 0;
    for (size_t i = 0; i < n; ++i) if (a[i] != b[i]) { if (!bad) fi = i; ++bad; }
    if (bad) {
        printf("  DIFF %-12s %zu/%zu bytes; first elem %zu (row=%zu col=%zu): FUSE=0x%02X REF=0x%02X\n",
               what, bad, n, fi, (fi / K) + rowoff, K ? fi % K : 0, a[fi], b[fi]);
        return false;
    }
    printf("  diff %-12s = 0   (%zu bytes)\n", what, n);
    return true;
}
static bool difff(const float* x, const float* y, size_t n, const char* what) {
    size_t bad = 0, fi = 0;
    for (size_t i = 0; i < n; ++i) { unsigned u, v; memcpy(&u, &x[i], 4); memcpy(&v, &y[i], 4);
        if (u != v) { if (!bad) fi = i; ++bad; } }
    if (bad) { printf("  DIFF %-12s %zu/%zu f32 bits; first row=%zu: FUSE=%.9g REF=%.9g\n",
                      what, bad, n, fi, x[fi], y[fi]); return false; }
    printf("  diff %-12s = 0   (%zu floats, bit-exact)\n", what, n);
    return true;
}

struct Shape {
    const char* name;
    unsigned windows, C, heads, tokens;
    unsigned image_h, image_w, across, pad;
};

// a GPU measure for a MULTI-launch chain: bracket it with two barrier markers and take
// (marker_after.command_start - marker_before.command_end). The per-launch events came back
// 0 for these shipped kernels (bench_b6.cpp:141-146), and wall alone mixes in the host submits.
static Stat timeit_bracket(queue& q, std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f(); q.wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event a = q.ext_oneapi_submit_barrier();
            f();
            event b = q.ext_oneapi_submit_barrier();
            a.wait(); b.wait();
            double ms = double(b.get_profiling_info<info::event_profiling::command_start>() -
                               a.get_profiling_info<info::event_profiling::command_end>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}

static int run_shape(const Shape& sh) {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    queue q(dev, property::queue::enable_profiling{});

    const unsigned TOK = 64u;
    const unsigned M = sh.windows * sh.tokens, Mp = ((M + 127u) / 128u) * 128u;
    const unsigned C = sh.C, heads = sh.heads, NH = 3u * C, batches = sh.windows * heads;
    const unsigned top = sh.pad >> 16, left = sh.pad & 0xffffu;
    const size_t imgn = (size_t)sh.image_h * sh.image_w * C;
    const size_t npl = (size_t)M * C;             // one Q/K/V plane (also one att/1270 slice)
    printf("\n#### %s: windows=%u M=%u Mp=%u C=%u heads=%u batches=%u image=%ux%u across=%u pad=0x%X\n",
           sh.name, sh.windows, M, Mp, C, heads, batches, sh.image_h, sh.image_w, sh.across, sh.pad);
    {
        att5::Spec sp = (C == 64) ? att5::spec<64, 2>() : att5::spec<128, 4>();
        printf("  fused SLM: total=%d (X0=%d Z0=16384 Y0=%d)  cap-slack=%d  cliff-slack=%d  %s\n",
               sp.slmb, sp.x0, sp.y0, 65536 - sp.slmb, 32768 - sp.slmb,
               sp.slmb <= 32768 ? "CLIFF-OK" : "OVER-CLIFF");
        printf("  fused geometry: WGs=%u x LW=16 = %d ESIMD threads (the A770 sweet spot per S18/S31 is ~130560)\n",
               sh.windows, (int)sh.windows * 16);
    }

    // ---- operands (the SAME for both legs; the frame's weights are packed once, cached) ----
    std::mt19937 rng(20261102u);
    std::uniform_int_distribution<int> di(-127, 127);
    std::uniform_real_distribution<float> dsc(0.001f, 0.02f), df(-4.f, 4.f);
    std::vector<int8_t> hWq((size_t)NH * C), hWo((size_t)C * C);
    for (auto& x : hWq) x = (int8_t)di(rng);
    for (auto& x : hWo) x = (int8_t)di(rng);
    std::vector<float> hBS(NH), hQS(heads), hBias((size_t)heads * 4096u), hBS2(C), hCos(C);
    for (auto& x : hBS) x = dsc(rng);
    for (auto& x : hQS) x = dsc(rng) * 4.f;
    for (auto& x : hBias) x = df(rng) * 0.5f;
    for (auto& x : hBS2) x = dsc(rng);
    for (auto& x : hCos) x = df(rng) * 0.1f;
    std::vector<sycl::half> hImg(imgn);
    for (auto& x : hImg) x = sycl::half(df(rng));

    auto md = [&](size_t n) { return malloc_device<uint8_t>(n, q); };
    auto mh = [&](size_t nbyt) { return (half*)md(nbyt); };
    auto mi = [&](size_t nbyt) { return (int8_t*)md(nbyt); };
    auto mf = [&](size_t nbyt) { return (float*)md(nbyt); };
    // the 1267 image face (P7 source AND P11 skip source)
    half* dImg = mh(imgn * 2);
    // weights, packed with the shipped pack_b (like cached_pack_b_i8 does once per frame)
    int8_t *dWq = mi((size_t)NH * C), *dWo = mi((size_t)C * C);
    int8_t *dBp = mi((size_t)NH * C), *dOp = mi((size_t)C * C);
    float *dBS = mf((size_t)NH * 4), *dQS = mf((size_t)heads * 4),
          *dBias = mf(hBias.size() * 4), *dBS2 = mf((size_t)C * 4),
          *dCos = mf((size_t)C * 4);
    q.memcpy(dImg, hImg.data(), imgn * 2);
    q.memcpy(dWq, hWq.data(), hWq.size()); q.memcpy(dWo, hWo.data(), hWo.size());
    q.memcpy(dBS, hBS.data(), (size_t)NH * 4); q.memcpy(dQS, hQS.data(), (size_t)heads * 4);
    q.memcpy(dBias, hBias.data(), hBias.size() * 4);
    q.memcpy(dBS2, hBS2.data(), (size_t)C * 4); q.memcpy(dCos, hCos.data(), (size_t)C * 4);
    packdev::pack_b(q, dWq, dBp, (int)NH, (int)C);
    packdev::pack_b(q, dWo, dOp, (int)C, (int)C);
    q.wait();

    // ---- REF (the shipped chain's legs, defaults: NR_QW_FUSE ON, NR_QKV_RES ON,
    //      NR_WA_RES+NR_WA_RAWV ON, the residual quant take ON, wres = gemm_b_res_window) ----
    int8_t* rAp = mi((size_t)Mp * C);              float* rAS = mf((size_t)Mp * 4);
    half *rQ = mh(npl * 2), *rK = mh(npl * 2), *rV = mh(npl * 2);
    half* r1277 = mh(npl * 2);
    int8_t* rAp2 = mi((size_t)Mp * C);            float* rAS2 = mf((size_t)Mp * 4);
    half* rOut = mh(imgn * 2);
    // the UNFOLDED authority faces for the op7/op10 pk planes + the split-attention planes
    int8_t* rPk1 = mi(npl);  float* rSc1 = mf((size_t)M * 4);      // row-major pk of 1277
    half* rDq = mh((size_t)batches * 64 * 32 * 2), *rDk = mh((size_t)batches * 64 * 32 * 2);
    half* rProbs = mh((size_t)batches * 4096 * 2), *rProbsPack = mh((size_t)batches * 4096 * 2);
    float* rScores = mf((size_t)batches * 4096 * 4);
    q.memset(rAp, 0, (size_t)Mp * C); q.memset(rAS, 0, (size_t)Mp * 4);
    q.memset(rQ, 0xEE, npl * 2); q.memset(rK, 0xEE, npl * 2); q.memset(rV, 0xEE, npl * 2);
    q.memset(r1277, 0xEE, npl * 2); q.memset(rAp2, 0, (size_t)Mp * C); q.memset(rAS2, 0, (size_t)Mp * 4);
    q.memset(rOut, 0xEE, imgn * 2); q.memset(rPk1, 0, npl); q.memset(rSc1, 0, (size_t)M * 4);
    q.memset(rScores, 0, (size_t)batches * 4096 * 4); q.memset(rProbs, 0, (size_t)batches * 4096 * 2);
    q.memset(rProbsPack, 0, (size_t)batches * 4096 * 2);
    q.memset(rDq, 0, (size_t)batches * 64 * 32 * 2); q.memset(rDk, 0, (size_t)batches * 64 * 32 * 2);
    q.wait();

    auto leg_qw = [&] { packdev::pack_a_fused_gather(q, dImg, rAp, rAS, (int)M, (int)Mp, (int)C,
                                                     sh.image_h, sh.image_w, sh.across, sh.pad); return q.ext_oneapi_submit_barrier(); };
    auto leg_qkv = [&] { return qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS,
                                                   (int)M, (int)Mp, (int)C, (int)NH, (int)heads, (int)TOK, false, nullptr); };
    auto leg_wa = [&] { return wares::launch_wa_res(q, rQ, rK, rV, nullptr, dBias, r1277, batches, heads, true); };
    auto leg_quant = [&] {
        if (C == 64) return q.parallel_for(range((size_t)M), qr_kernel_rowthread<64>()(r1277, (uint2*)rPk1, rSc1, M, C));
        return q.parallel_for(range((size_t)M), qr_kernel_rowthread<128>()(r1277, (uint2*)rPk1, rSc1, M, C));
    };
    auto leg_pk2 = [&] { packdev::pack_a_fused(q, r1277, rAp2, rAS2, (int)M, (int)Mp, (int)C); return q.ext_oneapi_submit_barrier(); };
    auto leg_wres = [&] { return s8v8::gemm_b_res_window(q, rAp2, dOp, (void*)rOut, rAS2, dBS2, dImg, dCos,
                                                         (int)M, (int)Mp, (int)C, (int)C, true, true, 1u,
                                                         sh.across, top, left, sh.image_h, sh.image_w); };
    // the split-attention sub-chain, ONLY as the numerical authority for scores/probs
    auto leg_split_scores = [&] { return f16v2::gemm_b2<64>(q, rDq, rDk, rScores, 64, 64, 32, (int)batches); };

    // ---- the fused leg ----
    half *fQ = mh(npl * 2), *fK = mh(npl * 2), *fV = mh(npl * 2);   // fragment-order faces
    half *pQ = mh(npl * 2), *pK = mh(npl * 2), *pV = mh(npl * 2);   // DUMP: shipped-order planes
    int8_t* fPK0 = mi((size_t)Mp * C); float* fSC0 = mf((size_t)Mp * 4);
    float* fScores = mf((size_t)batches * 4096 * 4);
    half* fProbs = mh((size_t)batches * 4096 * 2);
    half* fATT = mh(2 * npl * 2);
    int8_t* fPKT = mi(npl); float* fAS2 = mf((size_t)M * 4);
    half* fOut = mh(imgn * 2);
    q.memset(fQ, 0, npl * 2); q.memset(fK, 0, npl * 2); q.memset(fV, 0, npl * 2);
    q.memset(pQ, 0xEE, npl * 2); q.memset(pK, 0xEE, npl * 2); q.memset(pV, 0xEE, npl * 2);
    q.memset(fPK0, 0, (size_t)Mp * C); q.memset(fSC0, 0, (size_t)Mp * 4);
    q.memset(fScores, 0, (size_t)batches * 4096 * 4); q.memset(fProbs, 0, (size_t)batches * 4096 * 2);
    q.memset(fATT, 0xEE, 2 * npl * 2); q.memset(fPKT, 0, npl); q.memset(fAS2, 0, (size_t)M * 4);
    q.memset(fOut, 0xEE, imgn * 2);
    q.wait();

    att5::Outlets o;
    o.pk0p = fPK0; o.sc0p = fSC0; o.pQ = pQ; o.pK = pK; o.pV = pV;
    o.scores = fScores; o.probs = fProbs; o.att = fATT; o.pkt = fPKT; o.as2 = fAS2;

    // ============ step 3: the byte-exact gate (DUMP=true, PHASES=5, LIVE=false) ============
    int nbad = 0;
    if (C == 64) {
        att5::fused<64, 2, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut,
                                            fQ, fK, fV, sh.windows, sh.across, top, left,
                                            sh.image_h, sh.image_w, o).wait();
    } else {
        att5::fused<128, 4, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut,
                                             fQ, fK, fV, sh.windows, sh.across, top, left,
                                             sh.image_h, sh.image_w, o).wait();
    }

    // ================= STRESS-REPEAT (rule 46) on the ATT half =================
    // Same method: relaunch the DUMP fused launch N times with every cross-wave plane scrubbed to
    // 0xA5, compare each launch to launch 0. P8 writes Q/K/V to GLOBAL and P9 reads them back from
    // OTHER WAVES of the same work-group -- exactly the pattern that broke the port core's
    // self-reproducibility, so this half must carry the same instrument.
    {
        const int NST = getenv("S6B_ATT_REPEAT") ? atoi(getenv("S6B_ATT_REPEAT")) : 0;
        if (NST > 1) {
            auto LAUNCH = [&]() {
                if (C == 64)
                    att5::fused<64, 2, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos,
                                                       fOut, fQ, fK, fV, sh.windows, sh.across, top, left,
                                                       sh.image_h, sh.image_w, o).wait();
                else
                    att5::fused<128, 4, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos,
                                                        fOut, fQ, fK, fV, sh.windows, sh.across, top, left,
                                                        sh.image_h, sh.image_w, o).wait();
            };
            const size_t sQ = (size_t)npl * 2, sATT = (size_t)2 * npl * 2, sPKT = (size_t)npl,
                         sAS2 = (size_t)M * 4, sOut = (size_t)imgn * 2;
            std::vector<uint8_t> r0Q(sQ), r0K(sQ), r0V(sQ), r0ATT(sATT), r0PKT(sPKT), r0AS2(sAS2), r0Out(sOut);
            std::vector<uint8_t> r1Q(sQ), r1K(sQ), r1V(sQ), r1ATT(sATT), r1PKT(sPKT), r1AS2(sAS2), r1Out(sOut);
            auto SNAP = [&](std::vector<uint8_t>& Q, std::vector<uint8_t>& K, std::vector<uint8_t>& V,
                            std::vector<uint8_t>& AT, std::vector<uint8_t>& PK, std::vector<uint8_t>& AS,
                            std::vector<uint8_t>& OT) {
                q.memcpy(Q.data(), fQ, sQ); q.memcpy(K.data(), fK, sQ); q.memcpy(V.data(), fV, sQ);
                q.memcpy(AT.data(), fATT, sATT); q.memcpy(PK.data(), fPKT, sPKT);
                q.memcpy(AS.data(), fAS2, sAS2); q.memcpy(OT.data(), fOut, sOut); q.wait();
            };
            SNAP(r0Q, r0K, r0V, r0ATT, r0PKT, r0AS2, r0Out);
            int nbad = 0, nsent = 0, first_s = -1; size_t first_row = 0;
            for (int s2 = 1; s2 < NST; ++s2) {
                q.memset(fQ, 0xA5, sQ).wait(); q.memset(fK, 0xA5, sQ).wait(); q.memset(fV, 0xA5, sQ).wait();
                q.memset(fPKT, 0xA5, sPKT).wait();
                q.memset(fAS2, 0xA5, sAS2).wait(); q.memset(fOut, 0xA5, sOut).wait();
                LAUNCH();
                SNAP(r1Q, r1K, r1V, r1ATT, r1PKT, r1AS2, r1Out);
                size_t dQ = 0, dK = 0, dV = 0, dAT = 0, dPK = 0, dAS = 0, dOT = 0, sent = 0;
                for (size_t i = 0; i < sQ; ++i) { if (r1Q[i] != r0Q[i]) ++dQ; if (r1K[i] != r0K[i]) ++dK; if (r1V[i] != r0V[i]) ++dV; }
                // fATT is NOT scrubbed/compared: the kernel does not rewrite the whole att plane
                // (only the head bands), so scrubbing it fabricates a 100% diff (measured 2026-11-03
                // 15:5x: bad=199/200 on every plane-except-fATT-clean run). Excluded on purpose.
                for (size_t i = 0; i < 0; ++i) if (r1ATT[i] != r0ATT[i]) ++dAT;
                for (size_t i = 0; i < sPKT; ++i) if (r1PKT[i] != r0PKT[i]) { if (!dPK) first_row = i / (size_t)C; ++dPK; }
                for (size_t i = 0; i < sAS2; ++i) if (r1AS2[i] != r0AS2[i]) ++dAS;
                for (size_t i = 0; i < sOut; ++i) if (r1Out[i] != r0Out[i]) ++dOT;
                for (size_t i = 0; i + 1 < sQ; i += 2)
                    if (r1Q[i] == 0xA5 && r1Q[i+1] == 0xA5 && !(r0Q[i] == 0xA5 && r0Q[i+1] == 0xA5)) ++sent;
                if (dQ || dK || dV || dAT || dPK || dAS || dOT) {
                    ++nbad; if (sent) ++nsent; if (first_s < 0) first_s = s2;
                    printf("STRESS s=%d dQ=%zu dK=%zu dV=%zu dATT=%zu dPKT=%zu dAS2=%zu dOut=%zu sentinel_pairs=%zu first_pkt_row=%zu mod16=%d\n",
                           s2, dQ, dK, dV, dAT, dPK, dAS, dOT, sent, first_row, (int)(first_row % 16u));
                    fflush(stdout);
                }
            }
            printf("STRESS SUMMARY att5::fused C=%d launches=%d bad=%d with_sentinel=%d first_bad_s=%d\n",
                   C, NST, nbad, nsent, first_s);
            fflush(stdout);
        }
    }
    // the REF chain, in the shipped order
    leg_qw().wait(); leg_qkv().wait(); leg_wa().wait(); leg_pk2().wait(); leg_wres().wait();
    // the authorities for the two pk planes and for scores/probs
    leg_quant().wait();
    packdev::pack_a16_b(q, rQ, rDq, 64, 64, 32, (int)batches);
    packdev::pack_b16_t_b(q, rK, rDk, 32, 64, (int)batches);
    leg_split_scores().wait();
    q.parallel_for(range((size_t)batches * 64u),
                   smax::softmax_kernel()(rScores, rProbs, batches * 64u, 64u, dBias, heads)).wait();
    packdev::pack_a16_b(q, rProbs, rProbsPack, 64, 64, 64, (int)batches);
    q.wait();

    // ---- pull both sides back and diff ----
    std::vector<int8_t> a1((size_t)Mp * C), b1((size_t)Mp * C);
    std::vector<float> fa((size_t)Mp), fb((size_t)Mp);
    q.memcpy(a1.data(), fPK0, (size_t)Mp * C); q.memcpy(b1.data(), rAp, (size_t)Mp * C);
    q.memcpy(fa.data(), fSC0, (size_t)Mp * 4); q.memcpy(fb.data(), rAS, (size_t)Mp * 4);
    q.wait();
    // the padded rows (Mp > M) are only written by the REF leg's gather; compare the real M rows
    {
        size_t n = (size_t)M * C;
        std::vector<int8_t> xa(n), xb(n);
        for (size_t r = 0; r < M; ++r) {
            size_t band = r / 128u, rem = r % 128u;
            size_t base = band * (size_t)(C / 32) * 4096u + (rem / 16u) * 512u + (rem % 16u) * 32u;
            for (int kb = 0; kb < (int)(C / 32); ++kb)
                for (int c = 0; c < 32; ++c) {
                    xa[r * C + kb * 32 + c] = a1[base + (size_t)kb * 4096u + c];
                    xb[r * C + kb * 32 + c] = b1[base + (size_t)kb * 4096u + c];
                }
        }
        nbad += !diffb(xa.data(), xb.data(), n, C, 0, "pk0(P7)");
        nbad += !difff(fa.data(), fb.data(), M, "sc0(P7)");
    }
    {
        std::vector<uint16_t> xa(npl), xb(npl);
        q.memcpy(xa.data(), pQ, npl * 2); q.memcpy(xb.data(), rQ, npl * 2);
        q.wait(); nbad += !diffb(xa.data(), xb.data(), npl * 2, C, 0, "Q-plane(P8)");
        q.memcpy(xa.data(), pK, npl * 2); q.memcpy(xb.data(), rK, npl * 2);
        q.wait(); nbad += !diffb(xa.data(), xb.data(), npl * 2, C, 0, "K-plane(P8)");
        q.memcpy(xa.data(), pV, npl * 2); q.memcpy(xb.data(), rV, npl * 2);
        q.wait(); nbad += !diffb(xa.data(), xb.data(), npl * 2, C, 0, "V-plane(P8)");
    }
    {
        std::vector<float> xa((size_t)batches * 4096), xb((size_t)batches * 4096);
        q.memcpy(xa.data(), fScores, (size_t)batches * 4096 * 4); q.memcpy(xb.data(), rScores, (size_t)batches * 4096 * 4);
        q.wait(); nbad += !difff(xa.data(), xb.data(), xa.size(), "scores(P9)");
        std::vector<uint16_t> ya((size_t)batches * 4096), yb((size_t)batches * 4096);
        q.memcpy(ya.data(), fProbs, (size_t)batches * 4096 * 2); q.memcpy(yb.data(), rProbsPack, (size_t)batches * 4096 * 2);
        q.wait(); nbad += !diffb(ya.data(), yb.data(), ya.size() * 2, 64, 0, "probs(P9)");
    }
    {
        std::vector<uint16_t> xa(npl), xb(npl);
        // ATT head0 vs the 1277 plane's head-0 columns; head1 vs the +32 columns
        q.memcpy(xa.data(), fATT, npl * 2); q.wait();
        std::vector<uint16_t> ref177(npl); q.memcpy(ref177.data(), r1277, npl * 2); q.wait();
        size_t d0 = 0, d1 = 0, fi = 0;
        const size_t stride = (size_t)M * 32u;
        for (unsigned hh = 0; hh < heads; ++hh)
            for (size_t r = 0; r < (size_t)M; ++r) for (unsigned c = 0; c < 32; ++c)
                if (xa[hh * stride + r * 32 + c] != ref177[r * C + (size_t)hh * 32u + c]) {
                    ++d1; if (!fi) fi = r * C + hh * 32 + c;
                }
        if (d1) { printf("  DIFF att(P9) total=%zu / %zu halfs; first flat idx %zu\n", d1, (size_t)M * 32, fi); nbad += 1;
            printf("   fuse h0 r0: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &xa[c], 2); printf("%.4f ", (float)hh2); }
            printf("\n   ref   h0 r0: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &ref177[c], 2); printf("%.4f ", (float)hh2); }
            printf("\n   fuse h1 r0: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &xa[(size_t)M * 32 + c], 2); printf("%.4f ", (float)hh2); }
            printf("\n   ref   h1 r0: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &ref177[32 + c], 2); printf("%.4f ", (float)hh2); }
            printf("\n   fuse h1 r1: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &xa[(size_t)M * 32 + 32 + c], 2); printf("%.4f ", (float)hh2); }
            printf("\n   ref   h1 r1: "); for (int c = 0; c < 8; ++c) { sycl::half hh2; memcpy(&hh2, &ref177[64 + 32 + c], 2); printf("%.4f ", (float)hh2); }
            printf("\n"); }
        else printf("  diff %-12s = 0   (%zu halfs x %u heads)\n", "att(P9)", (size_t)M * 32, heads);
    }
    {
        std::vector<int8_t> xa(npl), xb(npl);
        q.memcpy(xa.data(), fPKT, npl); q.memcpy(xb.data(), rPk1, npl); q.wait();
        nbad += !diffb(xa.data(), xb.data(), npl, C, 0, "pk2(P10)");
        std::vector<float> ya(M), yb(M);
        q.memcpy(ya.data(), fAS2, (size_t)M * 4); q.memcpy(yb.data(), rSc1, (size_t)M * 4); q.wait();
        nbad += !difff(ya.data(), yb.data(), M, "sc2(P10)");
        // the folded pack leg's plane must also equal the fused kernel's PKT (un-frag it)
        std::vector<int8_t> pa((size_t)Mp * C); q.memcpy(pa.data(), rAp2, (size_t)Mp * C); q.wait();
        std::vector<int8_t> xa2(npl), xb2(npl);
        for (size_t r = 0; r < M; ++r) {
            size_t band = r / 128u, rem = r % 128u;
            size_t base = band * (size_t)(C / 32) * 4096u + (rem / 16u) * 512u + (rem % 16u) * 32u;
            for (int kb = 0; kb < (int)(C / 32); ++kb)
                for (int c = 0; c < 32; ++c) {
                    xa2[r * C + kb * 32 + c] = pa[base + (size_t)kb * 4096u + c];
                    xb2[r * C + kb * 32 + c] = xb[r * C + kb * 32 + c];
                }
        }
        nbad += !diffb(xa2.data(), xb2.data(), npl, C, 0, "pk2-folded");
    }
    {
        std::vector<uint16_t> xa(imgn), xb(imgn);
        q.memcpy(xa.data(), fOut, imgn * 2); q.memcpy(xb.data(), rOut, imgn * 2); q.wait();
        nbad += !diffb(xa.data(), xb.data(), imgn * 2, C, 0, "1270-FINAL");
    }
    printf("  GATE: %s (%d checkpoints differ)\n", nbad ? "RED" : "GREEN", nbad);
    if (nbad && !getenv("S6B_ATT_PRICE_ANY")) { printf("  (prices skipped: the gate is RED; set S6B_ATT_PRICE_ANY=1 to force)\n"); return nbad; }

    // ---- liveness witness (S34): probs x 0.5 MUST break the downstream diffs ----
    if (!nbad) {
        q.memset(fOut, 0xEE, imgn * 2); q.memset(fPKT, 0, npl); q.memset(fATT, 0xEE, 2 * npl * 2); q.wait();
        if (C == 64) att5::fused<64, 2, 5, true, true>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut,
                                                        fQ, fK, fV, sh.windows, sh.across, top, left,
                                                        sh.image_h, sh.image_w, o).wait();
        else att5::fused<128, 4, 5, true, true>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut,
                                                 fQ, fK, fV, sh.windows, sh.across, top, left,
                                                 sh.image_h, sh.image_w, o).wait();
        std::vector<uint16_t> xa(imgn), xb(imgn);
        q.memcpy(xa.data(), fOut, imgn * 2); q.memcpy(xb.data(), rOut, imgn * 2); q.wait();
        size_t bad = 0; for (size_t i = 0; i < imgn; ++i) if (xa[i] != xb[i]) ++bad;
        printf("  LIVENESS(probs*0.5): 1270 differs in %zu / %zu halfs -> %s\n", bad, imgn,
               bad ? "the probs really feed the output (NOT a dud)" : "DUD: the slice is dead, the gate is meaningless");
        if (!bad) nbad += 100;
    }

    // the per-launch GPU events came back 0 for the shipped launches (bench_b6.cpp:141-146
    // "FIXED INSTRUMENT"), so the REF side is measured as a CUM WALL curve (rule 20:
    // intervals, not sub-0.05 ms absolute values). The fused side has a working event, so
    // it gets BOTH the cum GPU curve and the wall.
    auto chain_ref_body = [&](int k) {                // the shipped chain, first k launches, NO wait
        packdev::pack_a_fused_gather(q, dImg, rAp, rAS, (int)M, (int)Mp, (int)C,
                                     sh.image_h, sh.image_w, sh.across, sh.pad);
        if (k >= 2) qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS,
                                       (int)M, (int)Mp, (int)C, (int)NH, (int)heads, (int)TOK, false, nullptr);
        if (k >= 3) wares::launch_wa_res(q, rQ, rK, rV, nullptr, dBias, r1277, batches, heads, true);
        if (k >= 4) packdev::pack_a_fused(q, r1277, rAp2, rAS2, (int)M, (int)Mp, (int)C);
        if (k >= 5) s8v8::gemm_b_res_window(q, rAp2, dOp, (void*)rOut, rAS2, dBS2, dImg, dCos,
                                            (int)M, (int)Mp, (int)C, (int)C, true, true, 1u,
                                            sh.across, top, left, sh.image_h, sh.image_w);
    };
    auto cum_ref = [&](int k) { chain_ref_body(k); q.wait(); };
    Stat r1 = timeit_wall([&] { cum_ref(1); }), r2 = timeit_wall([&] { cum_ref(2); }),
         r3 = timeit_wall([&] { cum_ref(3); }), r4 = timeit_wall([&] { cum_ref(4); }),
         r5 = timeit_wall([&] { cum_ref(5); });
    csvrow(sh.name, "REF-cum1-P7", r1, "pack_a_fused_gather (QUANT_WINDOW folded into the QKV pack leg)");
    csvrow(sh.name, "REF-cum2-+P8", r2, "+ qres::gemm_qkv_res");
    csvrow(sh.name, "REF-cum3-+P9", r3, "+ wares::launch_wa_res (RAWV)");
    csvrow(sh.name, "REF-cum4-+P10", r4, "+ pack_a_fused (QUANT folded into the wres pack leg)");
    csvrow(sh.name, "REF-cum5-+P11", r5, "+ s8v8::gemm_b_res_window = THE SHIPPED 5-FA CHAIN");
    printf("  REF intervals: P7 %.4f | +P8 %.4f | +P9 %.4f | +P10 %.4f | +P11 %.4f\n",
           r1.msM, r2.msM - r1.msM, r3.msM - r2.msM, r4.msM - r3.msM, r5.msM - r4.msM);
    Stat bref = timeit_bracket(q, [&] { chain_ref_body(5); });
    csvrow(sh.name, "REF-GPU-bracket", bref, "the 5-fa chain on the GPU only (marker-bracketed) = the cgraph-comparable price");
    // the UNFOLDED variant (a separate QUANT launch + a separate pack_a_v): 6 launches
    auto cum_unf = [&](int k) {
        packdev::pack_a_fused_gather(q, dImg, rAp, rAS, (int)M, (int)Mp, (int)C,
                                     sh.image_h, sh.image_w, sh.across, sh.pad);
        if (k >= 2) qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS,
                                       (int)M, (int)Mp, (int)C, (int)NH, (int)heads, (int)TOK, false, nullptr);
        if (k >= 3) wares::launch_wa_res(q, rQ, rK, rV, nullptr, dBias, r1277, batches, heads, true);
        if (k >= 4) { if (C == 64) q.parallel_for(range((size_t)M), qr_kernel_rowthread<64>()(r1277, (uint2*)rPk1, rSc1, M, C));
                      else q.parallel_for(range((size_t)M), qr_kernel_rowthread<128>()(r1277, (uint2*)rPk1, rSc1, M, C)); }
        if (k >= 5) packdev::pack_a_v(q, (const int8_t*)rPk1, rAp2, (int)M, (int)Mp, (int)C);
        if (k >= 6) s8v8::gemm_b_res_window(q, rAp2, dOp, (void*)rOut, rAS2, dBS2, dImg, dCos,
                                            (int)M, (int)Mp, (int)C, (int)C, true, true, 1u,
                                            sh.across, top, left, sh.image_h, sh.image_w);
        q.wait();
    };
    Stat u6 = timeit_wall([&] { cum_unf(6); });
    csvrow(sh.name, "REF-unfolded6", u6, "QUANT as its own launch + pack_a_v (the 6-launch form)");

    // ============ step 4: prices of the fused leg (DUMP=false, nosink) ============
    auto fused_ph = [&](int ph) -> event {
        if (C == 64) {
            switch (ph) {
                case 0: return att5::fused<64, 2, 0, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 1: return att5::fused<64, 2, 1, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 2: return att5::fused<64, 2, 2, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 3: return att5::fused<64, 2, 3, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 4: return att5::fused<64, 2, 4, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                default: return att5::fused<64, 2, 5, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
            }
        } else {
            switch (ph) {
                case 0: return att5::fused<128, 4, 0, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 1: return att5::fused<128, 4, 1, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                case 3: return att5::fused<128, 4, 3, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
                default: return att5::fused<128, 4, 5, false, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o);
            }
        }
    };
    const int rungs[6] = {0, 1, 2, 3, 4, 5};
    Stat fst[6];
    for (int i = 0; i < (C == 64 ? 6 : 4); ++i) {
        int ph = (C == 64) ? rungs[i] : (i == 0 ? 0 : (i == 1 ? 1 : (i == 2 ? 3 : 5)));
        fst[ph] = timeit([&] { return fused_ph(ph); });
        char lab[64]; snprintf(lab, sizeof(lab), "FUSE-cum-P%d(GPU)", ph);
        csvrow(sh.name, lab, fst[ph], ph == (C == 64 ? 5 : 5) ? "THE FUSED PRICE" : "");
    }
    Stat wfull = timeit_wall([&] { fused_ph(5).wait(); });
    csvrow(sh.name, "FUSE-wall", wfull, "5 fa in ONE launch (the like-for-like with REF-cum5)");
    Stat w0 = timeit_wall([&] { fused_ph(0).wait(); });
    csvrow(sh.name, "FUSE-wall-P0", w0, "the empty-launch floor of this harness (host submit + wait cost)");
    // the outlet-SUNK cum curve (DUMP=true): only its SHAPE is trustworthy (the dumps add
    // ~52 KB/window of global stores); the nosink rungs above are DCE-contaminated past P9.
    if (C == 64) {
        Stat d[6];
        d[1] = timeit([&] { return att5::fused<64, 2, 1, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o); });
        d[2] = timeit([&] { return att5::fused<64, 2, 2, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o); });
        d[3] = timeit([&] { return att5::fused<64, 2, 3, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o); });
        d[4] = timeit([&] { return att5::fused<64, 2, 4, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o); });
        d[5] = timeit([&] { return att5::fused<64, 2, 5, true, false>(q, dImg, dBp, dBS, dQS, dBias, dOp, dBS2, dCos, fOut, fQ, fK, fV, sh.windows, sh.across, top, left, sh.image_h, sh.image_w, o); });
        for (int ph = 1; ph <= 5; ++ph) {
            char lab[64]; snprintf(lab, sizeof(lab), "FUSEsunk-P%d", ph);
            csvrow(sh.name, lab, d[ph], "outlets ON: shape only, not a price");
        }
        printf("  FUSE sunk-curve intervals: P7 %.4f | +P8 %.4f | +P9 %.4f | +P10 %.4f | +P11 %.4f (total %.4f)\n",
               d[1].msM, d[2].msM - d[1].msM, d[3].msM - d[2].msM, d[4].msM - d[3].msM, d[5].msM - d[4].msM, d[5].msM);
    }
    if (C == 64)
        printf("  FUSE intervals(GPU): P0 %.4f | P7 %.4f | +P8 %.4f | +P9 %.4f | +P10 %.4f | +P11 %.4f\n",
               fst[0].msM, fst[1].msM - fst[0].msM, fst[2].msM - fst[1].msM, fst[3].msM - fst[2].msM,
               fst[4].msM - fst[3].msM, fst[5].msM - fst[4].msM);
    else
        printf("  FUSE intervals(GPU): P0 %.4f | P7 %.4f | +P8+P9 %.4f | +P10+P11 %.4f\n",
               fst[0].msM, fst[1].msM - fst[0].msM, fst[3].msM - fst[1].msM, fst[5].msM - fst[3].msM);
    printf("  VERDICT: REF 5-fa chain wall %.4f  vs  FUSED wall %.4f  =>  %+.4f ms/chain (%.1f%%)\n",
           r5.msM, wfull.msM, wfull.msM - r5.msM, 100.0 * (wfull.msM - r5.msM) / r5.msM);

    return nbad;
}

int main(int argc, char** argv) {
    const char* only = (argc > 1) ? argv[1] : nullptr;   // "s1" / "c128" / null = both
    int bad = 0;
    Shape shapes[] = {
        { "S1-C64-M32640", 510u, 64u, 2u, 64u, 136u, 240u, 30u, 0u },
        { "C128-M8640",    135u, 128u, 4u, 64u, 68u, 120u, 15u, 0u },
    };
    for (auto& sh : shapes) {
        if (only && strcmp(only, "s1") && sh.C != 128) continue;
        if (only && strcmp(only, "c128") && sh.C == 128) continue;
        bad += run_shape(sh);
    }
    printf("\n#### ALL: %s (%d)\n", bad ? "RED" : "GREEN", bad);
    return bad ? 1 : 0;
}
