// window_block_mega.hpp -- B1 megakernel, first increment (section 92): LEG1 fused.
// One workgroup = one window ROW (8 tokens); 32 threads = 1 subgroup -- exactly the
// proven s8v8 ESIMD shape (the gate caught DEVICE_LOST on the 256-thread/16B-block
// variant: SLM block ops in this codebase are all >=64B and every working ESIMD kernel
// uses local=32). Gather 8 tokens (e4m3 publish), build the f16v1 A-fragment, project to
// Q/K/V with the SAME dpas geometry as f16v1::gemm (proven bit-exact), normalise Q and K
// with the ctree butterfly (8 lanes each own one row end-to-end -- no cross-lane
// broadcast needed), publish, write dQ/dK/dV.
//
// This replaces the split path's FOUR kernels (gather, pack_a16, gemm, scalar epilogue)
// and their global round-trips: the 12.6MB dCq scratch and the 1.05ms/call scalar
// epilogue both disappear.
//
// Contraction safety (section 92): eh_hfma's product l*r is EXACT in f32 (both operands
// are half-rounded, 11x11 bits <= 24), so an FMA contraction rounds only the add -- the
// same single rounding as fadd_rn(fmul_rn()). eh_mul/eh_add are single ops. qr_e4m3_scalar
// is the proven ESIMD-safe spelling (cosine_tree_kernel.hpp).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "publish_kernel.hpp"
#include <cmath>
#include "cosine_tree_kernel.hpp"

namespace wbmega {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static inline float eh_round(float x) { return (float)(half)x; }
static inline float eh_mul(float a, float b) { return (float)(half)(a * b); }
static inline float eh_add(float a, float b) { return (float)(half)(a + b); }
static inline float eh_hfma(float l, float r, float acc) { return (float)(half)(l * r + acc); }
static inline float esqrt(float x) { esimd::simd<float, 1> v(x); return esimd::sqrt(v)[0]; }

// cosine_recip_esimd: the ctree reduce order, ESIMD-native (used by launch_full stage 3).
static inline float cosine_recip_esimd(const float* h) {
    float partial[4][2];
    for (int lane = 0; lane < 4; ++lane)
        for (int parity = 0; parity < 2; ++parity) {
            int ch = lane * 2 + parity;
            float first  = eh_hfma(h[ch + 8],  h[ch + 8],  eh_mul(h[ch],       h[ch]));
            float second = eh_hfma(h[ch + 24], h[ch + 24], eh_mul(h[ch + 16], h[ch + 16]));
            partial[lane][parity] = eh_add(first, second);
        }
    float two[4][2], one[4][2];
    for (int lane = 0; lane < 4; ++lane)
        for (int p = 0; p < 2; p++) two[lane][p] = eh_add(partial[lane][p], partial[lane ^ 2][p]);
    for (int lane = 0; lane < 4; ++lane)
        for (int p = 0; p < 2; p++) one[lane][p] = eh_add(two[lane][p], two[lane ^ 1][p]);
    float norm = eh_add(one[0][0], one[0][1]);
    float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
    norm = norm > floorv ? norm : floorv;
    return eh_round(1.0f / esqrt(norm));
}
// cosine_recip_esimd_32 -- GENERATED (kdis/gen_cr32.py lineage) named-arg twin of
// cosine_recip_esimd above: IDENTICAL operation order, 32 named floats, no array inside.
// SPILL FIX (ISA ledger 2, 2026-10-29): the caller's h[32] escaped -> scratch 2304B/thread.
static inline float cosine_recip_esimd_32(float h0, float h1, float h2, float h3, float h4, float h5, float h6, float h7, float h8, float h9, float h10, float h11, float h12, float h13, float h14, float h15, float h16, float h17, float h18, float h19, float h20, float h21, float h22, float h23, float h24, float h25, float h26, float h27, float h28, float h29, float h30, float h31) {
    float one00 = eh_add(eh_add(eh_add(eh_hfma(h8,h8,eh_mul(h0,h0)), eh_hfma(h24,h24,eh_mul(h16,h16))), eh_add(eh_hfma(h12,h12,eh_mul(h4,h4)), eh_hfma(h28,h28,eh_mul(h20,h20)))), eh_add(eh_add(eh_hfma(h10,h10,eh_mul(h2,h2)), eh_hfma(h26,h26,eh_mul(h18,h18))), eh_add(eh_hfma(h14,h14,eh_mul(h6,h6)), eh_hfma(h30,h30,eh_mul(h22,h22)))));
    float one01 = eh_add(eh_add(eh_add(eh_hfma(h9,h9,eh_mul(h1,h1)), eh_hfma(h25,h25,eh_mul(h17,h17))), eh_add(eh_hfma(h13,h13,eh_mul(h5,h5)), eh_hfma(h29,h29,eh_mul(h21,h21)))), eh_add(eh_add(eh_hfma(h11,h11,eh_mul(h3,h3)), eh_hfma(h27,h27,eh_mul(h19,h19))), eh_add(eh_hfma(h15,h15,eh_mul(h7,h7)), eh_hfma(h31,h31,eh_mul(h23,h23)))));
    float norm = eh_add(one00, one01);
    float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
    norm = norm > floorv ? norm : floorv;
    return eh_round(1.0f / esqrt(norm));
}

// gate_esimd / pub_esimd: the epi2/3 gate polynomial + publish dispatch, ESIMD-native.
static inline float gate_esimd(float x) {
    float wide = (float)(half)x;
    float clamped = wide < -4.0f ? -4.0f : (wide > 4.0f ? 4.0f : wide);
    float ac = clamped < 0.0f ? -clamped : clamped;
    float linear = ac * -0.055908203125f;
    linear = (float)(half)(linear + 0.447265625f);
    linear = (float)(half)(linear * clamped);
    linear = (float)(half)(linear + 0.89453125f);
    return (float)(half)(wide * linear);
}
static inline float pub_esimd(unsigned epi, float v) {
    if (epi == 2u || epi == 3u) v = gate_esimd(v);
    if (epi == 1u || epi == 3u) v = qr_e4m3_scalar(v);
    if (epi == 4u) v = (float)(half)v;
    return v;
}

// SLM byte layout (one subgroup): ROW 512B (8 tokens x 32 halves) | AFRG 512B (2 kc x
// 128 halves) | VAL 1024B (8 tokens x 32 floats) | PAR 512B (8 rows x 16 floats pad).
static const uint ROW_B  = 0u;
static const uint AFRG_B = 512u;
static const uint VAL_B  = 1024u;
static const uint PAR_B  = 2048u;
static const uint SLM_TOTAL_B = 2560u;

inline sycl::event launch_leg1(
    sycl::queue& q,
    const void* Img, bool image_half,
    const half* WqkvPacked,                    // f16v1 pack_b of the (32 x 96) QKV weights
    half* dQ, half* dK, half* dV,              // published outputs (rows x 32 halves)
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    const float* QkvScale)
{
    // one workgroup per window row: windows*8 rows, 32 threads each
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range(windows * 8u * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL_B>();
            uint wgr = (uint)it.get_group(0);          // window*8 + sub
            uint lid = (uint)it.get_local_id(0);
            uint window = wgr / 8u, sub = wgr % 8u;
            uint row0 = wgr * 8u;                      // first global row of this 8-token line

            uint top = pad_top, left = pad_left;
            int y  = (int)((window / window_cols) * 8u + sub) - (int)top;
            int x0 = (int)((window % window_cols) * 8u) - (int)left;
            bool row_in = y >= 0 && y < (int)image_h;

            // ---- 1) gather: 8 lanes, one full token (32 ch = 64B) each ----
            if (lid < 8u) {
                esimd::simd<half, 32> v;
                int x = x0 + (int)lid;
                if (row_in && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (int e = 0; e < 32; ++e) {
                        float f = image_half ? (float)((const half*)Img)[at + e]
                                             : ((const float*)Img)[at + e];
                        v[e] = half(qr_e4m3_scalar(f));
                    }
                } else {
                    for (int e = 0; e < 32; ++e) v[e] = half(0.f);
                }
                esimd::slm_block_store(ROW_B + lid * 64u, v, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();

            // ---- 2) A-fragment: afrg[kc*128 + i*16 + k] = row[i*32 + kc*16 + k] ----
            // ESIMD select offsets must be COMPILE-TIME (the gate caught a runtime
            // select<16,1>(kc*16) faulting). 4 lanes: (kc, rowgroup of 4 tokens). Each
            // loads 4 tokens (4x64B), picks the kc half via a compile-time ternary, and
            // writes 64 rows-halves = 128B as two 64B SLM stores.
            if (lid < 4u) {
                uint kc = lid / 2u, rg = lid % 2u;
                esimd::simd<half, 64> a;                 // 4 rows x 16 halves
                for (int j = 0; j < 4; ++j) {
                    esimd::simd<half, 32> r = esimd::slm_block_load<half, 32>(
                        ROW_B + (rg * 4u + j) * 64u, esimd::overaligned_tag<16>{});
                    esimd::simd<half, 16> half16 = (kc == 0u) ? r.template select<16, 1>(0)
                                                              : r.template select<16, 1>(16);
                    a.template select<16, 1>(j * 16u) = half16;
                }
                esimd::slm_block_store(AFRG_B + kc * 256u + rg * 128u, a, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();

            // ---- 3) QKV projection: dpas geometry identical to f16v1::gemm ----
            for (int part = 0; part < 3; ++part) {
                esimd::simd<float, 64> acc0(0.f), acc1(0.f), acc2(0.f), acc3(0.f);
                for (int kc = 0; kc < 2; ++kc) {
                    esimd::simd<half, 128> a0 = esimd::slm_block_load<half, 128>(
                        AFRG_B + kc * 256u, esimd::overaligned_tag<16>{});
                    for (int tl = 0; tl < 2; ++tl) {
                        int tc = part * 2 + tl;
                        esimd::simd<half, 128> b0(WqkvPacked + (((size_t)kc * 6u + tc) * 2u + 0u) * 128u,
                                                  esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> b1(WqkvPacked + (((size_t)kc * 6u + tc) * 2u + 1u) * 128u,
                                                  esimd::overaligned_tag<16>{});
                        if (tl == 0) { acc0 = esimd::xmx::dpas<8, 8, float>(acc0, b0, a0);
                                       acc1 = esimd::xmx::dpas<8, 8, float>(acc1, b1, a0); }
                        else         { acc2 = esimd::xmx::dpas<8, 8, float>(acc2, b0, a0);
                                       acc3 = esimd::xmx::dpas<8, 8, float>(acc3, b1, a0); }
                    }
                }
                // store 8 rows x 32 floats: 2 x 64B per row, 16 lanes
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float, 16> q0, q1;
                    q0.template select<8, 1>(0)  = acc0.template select<8, 1>(r * 8);
                    q0.template select<8, 1>(8)  = acc1.template select<8, 1>(r * 8);
                    q1.template select<8, 1>(0)  = acc2.template select<8, 1>(r * 8);
                    q1.template select<8, 1>(8)  = acc3.template select<8, 1>(r * 8);
                    esimd::slm_block_store(VAL_B + r * 128u, q0, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(VAL_B + r * 128u + 64u, q1, esimd::overaligned_tag<16>{});
                }
                esimd::barrier();

                // ---- 4) epilogue: 8 lanes, one row each, end-to-end (no broadcast) ----
                if (lid < 8u) {
                    esimd::simd<float, 32> rowv = esimd::slm_block_load<float, 32>(
                        VAL_B + lid * 128u, esimd::overaligned_tag<16>{});
                    // SPILL FIX (ISA ledger 2, 2026-10-29): h[32] + partial/two/one arrays
                    // escaped -> scratch 2304B/thread (ze_info spill audit). Named scalars +
                    // the generated named-arg twin (identical operation order).
                    float rv0 = rowv[0], rv1 = rowv[1], rv2 = rowv[2], rv3 = rowv[3], rv4 = rowv[4], rv5 = rowv[5], rv6 = rowv[6], rv7 = rowv[7], rv8 = rowv[8], rv9 = rowv[9], rv10 = rowv[10], rv11 = rowv[11], rv12 = rowv[12], rv13 = rowv[13], rv14 = rowv[14], rv15 = rowv[15], rv16 = rowv[16], rv17 = rowv[17], rv18 = rowv[18], rv19 = rowv[19], rv20 = rowv[20], rv21 = rowv[21], rv22 = rowv[22], rv23 = rowv[23], rv24 = rowv[24], rv25 = rowv[25], rv26 = rowv[26], rv27 = rowv[27], rv28 = rowv[28], rv29 = rowv[29], rv30 = rowv[30], rv31 = rowv[31];
                    esimd::simd<half, 32> out8;
                    if (part < 2) {
                        rv0 = eh_round(rv0);
                        rv1 = eh_round(rv1);
                        rv2 = eh_round(rv2);
                        rv3 = eh_round(rv3);
                        rv4 = eh_round(rv4);
                        rv5 = eh_round(rv5);
                        rv6 = eh_round(rv6);
                        rv7 = eh_round(rv7);
                        rv8 = eh_round(rv8);
                        rv9 = eh_round(rv9);
                        rv10 = eh_round(rv10);
                        rv11 = eh_round(rv11);
                        rv12 = eh_round(rv12);
                        rv13 = eh_round(rv13);
                        rv14 = eh_round(rv14);
                        rv15 = eh_round(rv15);
                        rv16 = eh_round(rv16);
                        rv17 = eh_round(rv17);
                        rv18 = eh_round(rv18);
                        rv19 = eh_round(rv19);
                        rv20 = eh_round(rv20);
                        rv21 = eh_round(rv21);
                        rv22 = eh_round(rv22);
                        rv23 = eh_round(rv23);
                        rv24 = eh_round(rv24);
                        rv25 = eh_round(rv25);
                        rv26 = eh_round(rv26);
                        rv27 = eh_round(rv27);
                        rv28 = eh_round(rv28);
                        rv29 = eh_round(rv29);
                        rv30 = eh_round(rv30);
                        rv31 = eh_round(rv31);
                        float recip = cosine_recip_esimd_32(rv0, rv1, rv2, rv3, rv4, rv5, rv6, rv7, rv8, rv9, rv10, rv11, rv12, rv13, rv14, rv15, rv16, rv17, rv18, rv19, rv20, rv21, rv22, rv23, rv24, rv25, rv26, rv27, rv28, rv29, rv30, rv31);
                        float sc = part == 0 ? eh_round(QkvScale[0]) : 1.0f;
                        float v0 = eh_mul(rv0, recip);
                        if (part == 0) v0 = eh_mul(v0, sc);
                        out8[0] = half(qr_e4m3_scalar(v0));
                        float v1 = eh_mul(rv1, recip);
                        if (part == 0) v1 = eh_mul(v1, sc);
                        out8[1] = half(qr_e4m3_scalar(v1));
                        float v2 = eh_mul(rv2, recip);
                        if (part == 0) v2 = eh_mul(v2, sc);
                        out8[2] = half(qr_e4m3_scalar(v2));
                        float v3 = eh_mul(rv3, recip);
                        if (part == 0) v3 = eh_mul(v3, sc);
                        out8[3] = half(qr_e4m3_scalar(v3));
                        float v4 = eh_mul(rv4, recip);
                        if (part == 0) v4 = eh_mul(v4, sc);
                        out8[4] = half(qr_e4m3_scalar(v4));
                        float v5 = eh_mul(rv5, recip);
                        if (part == 0) v5 = eh_mul(v5, sc);
                        out8[5] = half(qr_e4m3_scalar(v5));
                        float v6 = eh_mul(rv6, recip);
                        if (part == 0) v6 = eh_mul(v6, sc);
                        out8[6] = half(qr_e4m3_scalar(v6));
                        float v7 = eh_mul(rv7, recip);
                        if (part == 0) v7 = eh_mul(v7, sc);
                        out8[7] = half(qr_e4m3_scalar(v7));
                        float v8 = eh_mul(rv8, recip);
                        if (part == 0) v8 = eh_mul(v8, sc);
                        out8[8] = half(qr_e4m3_scalar(v8));
                        float v9 = eh_mul(rv9, recip);
                        if (part == 0) v9 = eh_mul(v9, sc);
                        out8[9] = half(qr_e4m3_scalar(v9));
                        float v10 = eh_mul(rv10, recip);
                        if (part == 0) v10 = eh_mul(v10, sc);
                        out8[10] = half(qr_e4m3_scalar(v10));
                        float v11 = eh_mul(rv11, recip);
                        if (part == 0) v11 = eh_mul(v11, sc);
                        out8[11] = half(qr_e4m3_scalar(v11));
                        float v12 = eh_mul(rv12, recip);
                        if (part == 0) v12 = eh_mul(v12, sc);
                        out8[12] = half(qr_e4m3_scalar(v12));
                        float v13 = eh_mul(rv13, recip);
                        if (part == 0) v13 = eh_mul(v13, sc);
                        out8[13] = half(qr_e4m3_scalar(v13));
                        float v14 = eh_mul(rv14, recip);
                        if (part == 0) v14 = eh_mul(v14, sc);
                        out8[14] = half(qr_e4m3_scalar(v14));
                        float v15 = eh_mul(rv15, recip);
                        if (part == 0) v15 = eh_mul(v15, sc);
                        out8[15] = half(qr_e4m3_scalar(v15));
                        float v16 = eh_mul(rv16, recip);
                        if (part == 0) v16 = eh_mul(v16, sc);
                        out8[16] = half(qr_e4m3_scalar(v16));
                        float v17 = eh_mul(rv17, recip);
                        if (part == 0) v17 = eh_mul(v17, sc);
                        out8[17] = half(qr_e4m3_scalar(v17));
                        float v18 = eh_mul(rv18, recip);
                        if (part == 0) v18 = eh_mul(v18, sc);
                        out8[18] = half(qr_e4m3_scalar(v18));
                        float v19 = eh_mul(rv19, recip);
                        if (part == 0) v19 = eh_mul(v19, sc);
                        out8[19] = half(qr_e4m3_scalar(v19));
                        float v20 = eh_mul(rv20, recip);
                        if (part == 0) v20 = eh_mul(v20, sc);
                        out8[20] = half(qr_e4m3_scalar(v20));
                        float v21 = eh_mul(rv21, recip);
                        if (part == 0) v21 = eh_mul(v21, sc);
                        out8[21] = half(qr_e4m3_scalar(v21));
                        float v22 = eh_mul(rv22, recip);
                        if (part == 0) v22 = eh_mul(v22, sc);
                        out8[22] = half(qr_e4m3_scalar(v22));
                        float v23 = eh_mul(rv23, recip);
                        if (part == 0) v23 = eh_mul(v23, sc);
                        out8[23] = half(qr_e4m3_scalar(v23));
                        float v24 = eh_mul(rv24, recip);
                        if (part == 0) v24 = eh_mul(v24, sc);
                        out8[24] = half(qr_e4m3_scalar(v24));
                        float v25 = eh_mul(rv25, recip);
                        if (part == 0) v25 = eh_mul(v25, sc);
                        out8[25] = half(qr_e4m3_scalar(v25));
                        float v26 = eh_mul(rv26, recip);
                        if (part == 0) v26 = eh_mul(v26, sc);
                        out8[26] = half(qr_e4m3_scalar(v26));
                        float v27 = eh_mul(rv27, recip);
                        if (part == 0) v27 = eh_mul(v27, sc);
                        out8[27] = half(qr_e4m3_scalar(v27));
                        float v28 = eh_mul(rv28, recip);
                        if (part == 0) v28 = eh_mul(v28, sc);
                        out8[28] = half(qr_e4m3_scalar(v28));
                        float v29 = eh_mul(rv29, recip);
                        if (part == 0) v29 = eh_mul(v29, sc);
                        out8[29] = half(qr_e4m3_scalar(v29));
                        float v30 = eh_mul(rv30, recip);
                        if (part == 0) v30 = eh_mul(v30, sc);
                        out8[30] = half(qr_e4m3_scalar(v30));
                        float v31 = eh_mul(rv31, recip);
                        if (part == 0) v31 = eh_mul(v31, sc);
                        out8[31] = half(qr_e4m3_scalar(v31));
                        half* dst = part == 0 ? dQ : dK;
                        out8.copy_to(dst + (size_t)(row0 + lid) * 32u);
                    } else {
                        out8[0] = half(qr_e4m3_scalar(rv0));
                        out8[1] = half(qr_e4m3_scalar(rv1));
                        out8[2] = half(qr_e4m3_scalar(rv2));
                        out8[3] = half(qr_e4m3_scalar(rv3));
                        out8[4] = half(qr_e4m3_scalar(rv4));
                        out8[5] = half(qr_e4m3_scalar(rv5));
                        out8[6] = half(qr_e4m3_scalar(rv6));
                        out8[7] = half(qr_e4m3_scalar(rv7));
                        out8[8] = half(qr_e4m3_scalar(rv8));
                        out8[9] = half(qr_e4m3_scalar(rv9));
                        out8[10] = half(qr_e4m3_scalar(rv10));
                        out8[11] = half(qr_e4m3_scalar(rv11));
                        out8[12] = half(qr_e4m3_scalar(rv12));
                        out8[13] = half(qr_e4m3_scalar(rv13));
                        out8[14] = half(qr_e4m3_scalar(rv14));
                        out8[15] = half(qr_e4m3_scalar(rv15));
                        out8[16] = half(qr_e4m3_scalar(rv16));
                        out8[17] = half(qr_e4m3_scalar(rv17));
                        out8[18] = half(qr_e4m3_scalar(rv18));
                        out8[19] = half(qr_e4m3_scalar(rv19));
                        out8[20] = half(qr_e4m3_scalar(rv20));
                        out8[21] = half(qr_e4m3_scalar(rv21));
                        out8[22] = half(qr_e4m3_scalar(rv22));
                        out8[23] = half(qr_e4m3_scalar(rv23));
                        out8[24] = half(qr_e4m3_scalar(rv24));
                        out8[25] = half(qr_e4m3_scalar(rv25));
                        out8[26] = half(qr_e4m3_scalar(rv26));
                        out8[27] = half(qr_e4m3_scalar(rv27));
                        out8[28] = half(qr_e4m3_scalar(rv28));
                        out8[29] = half(qr_e4m3_scalar(rv29));
                        out8[30] = half(qr_e4m3_scalar(rv30));
                        out8[31] = half(qr_e4m3_scalar(rv31));
                        out8.copy_to(dV + (size_t)(row0 + lid) * 32u);
                    }
                }
                esimd::barrier();
            }
        });
    });
}
// normalize_esimd -- the .comp's 4-lane butterfly cosine normalize as a standalone ESIMD
// kernel (section 92). The scalar split epilogue runs 1 work-item/row (4.04ms at the real
// shape); the .comp uses 4 lanes/row with a butterfly reduce (subgroupShuffleXor 2 then 1)
// so all lanes work and the reduce is log-depth. ESIMD has no shuffle (quantize_row_sycl
// .cpp:12), so the butterfly goes through SLM (the proven workaround). One workgroup = 32
// threads = 8 rows x 4 lanes. Reads dCq (global f32 Mp x NH), writes dQ/dK/dV (half).
inline sycl::event normalize_esimd(sycl::queue& q, const float* dCq,
                                   half* dQ, half* dK, half* dV,
                                   const float* qs, unsigned rows, unsigned NH, unsigned C) {
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)rows / 8u * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<8u * 16u * 4u>();   // 8 rows x (Q,K) x 4 lanes x 2 parity floats
            uint r  = (uint)it.get_group(0) * 8u + (uint)it.get_local_id(0) / 4u;
            uint l  = (uint)it.get_local_id(0) % 4u;
            uint rl = (uint)it.get_local_id(0) / 4u;
            // this lane's 8 channels: g*8 + 2l, g*8 + 2l + 1
            float hq[8], hk[8];
            for (int g = 0; g < 4; ++g) {
                hq[2u*g]   = eh_round(dCq[(size_t)r * NH + g * 8u + 2u*l]);
                hq[2u*g+1] = eh_round(dCq[(size_t)r * NH + g * 8u + 2u*l + 1u]);
                hk[2u*g]   = eh_round(dCq[(size_t)r * NH + C + g * 8u + 2u*l]);
                hk[2u*g+1] = eh_round(dCq[(size_t)r * NH + C + g * 8u + 2u*l + 1u]);
            }
            // partial[lane][parity] via SLM, then butterfly two[l]=hadd(p[l],p[l^2]),
            // one[0]=hadd(two[0],two[1]), norm=hadd(one[0][0],one[0][1]) -- ctree order.
            float pq[2], pk[2];
            for (int p = 0; p < 2; ++p) {
                pq[p] = eh_add(eh_hfma(hq[2+p], hq[2+p], eh_mul(hq[p], hq[p])),
                               eh_hfma(hq[6+p], hq[6+p], eh_mul(hq[4+p], hq[4+p])));
                pk[p] = eh_add(eh_hfma(hk[2+p], hk[2+p], eh_mul(hk[p], hk[p])),
                               eh_hfma(hk[6+p], hk[6+p], eh_mul(hk[4+p], hk[4+p])));
            }
            esimd::simd<float,2> tq; tq[0]=pq[0]; tq[1]=pq[1];
            esimd::slm_block_store((rl*16u + l*2u) * 4u, tq, esimd::overaligned_tag<16>{});
            esimd::simd<float,2> tk; tk[0]=pk[0]; tk[1]=pk[1];
            esimd::slm_block_store((rl*16u + 8u + l*2u) * 4u, tk, esimd::overaligned_tag<16>{});
            esimd::barrier();
            float recip[2];
            for (int which = 0; which < 2; ++which) {
                uint base = (rl*16u + which*8u) * 4u;     // bytes: 4 lanes x 2 parity
                esimd::simd<float,8> pv = esimd::slm_block_load<float,8>(base, esimd::overaligned_tag<16>{});
                // pv[l*2+p] = partial[l][p]. ctree: two[l]=hadd(p[l],p[l^2]); one[0]=hadd(two[0],two[1]);
                float two00 = eh_add(pv[0], pv[4]);   // two[0][0]=hadd(p[0][0],p[2][0])
                float two10 = eh_add(pv[2], pv[6]);   // two[1][0]=hadd(p[1][0],p[3][0])
                float one00 = eh_add(two00, two10);
                float two01 = eh_add(pv[1], pv[5]);
                float two11 = eh_add(pv[3], pv[7]);
                float one01 = eh_add(two01, two11);
                float norm = eh_add(one00, one01);
                float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                norm = norm > floorv ? norm : floorv;
                // 1.0f/esqrt is bit-exact here (the first ESIMD epilogue proved it); bare
                // / in an ESIMD kernel is the hardware correctly-rounded divide, NOT the
                // approximate reciprocal icx emits in a SYCL kernel (the §20 context).
                recip[which] = eh_round(1.0f / esqrt(norm));
            }
            float sc = eh_round(qs[0]);
            // each lane owns 8 channels (g*8+2l, g*8+2l+1); scalar stores (a 32-wide
            // copy_to would race -- all 4 lanes target the same row).
            for (int g = 0; g < 4; ++g) {
                uint c0 = g*8u + 2u*l;
                dQ[(size_t)r*32u + c0]   = half(qr_e4m3_scalar(eh_mul(eh_mul(hq[2u*g],   recip[0]), sc)));
                dQ[(size_t)r*32u + c0+1] = half(qr_e4m3_scalar(eh_mul(eh_mul(hq[2u*g+1], recip[0]), sc)));
                dK[(size_t)r*32u + c0]   = half(qr_e4m3_scalar(eh_mul(hk[2u*g],   recip[1])));
                dK[(size_t)r*32u + c0+1] = half(qr_e4m3_scalar(eh_mul(hk[2u*g+1], recip[1])));
                dV[(size_t)r*32u + c0]   = half(qr_e4m3_scalar(dCq[(size_t)r*NH + 2u*C + c0]));
                dV[(size_t)r*32u + c0+1] = half(qr_e4m3_scalar(dCq[(size_t)r*NH + 2u*C + c0 + 1u]));
            }
        });
    });
}

// qkv_norm_esimd -- the int8_qkv stage-2 normalise as the 4-lane ESIMD butterfly
// (section 92, same template as normalize_esimd). One workgroup = 32 threads = 8
// (row,head) pairs x 4 lanes; each lane owns 8 channels of its row. Loads dC int32,
// dequantises (acc*as[r])*bs[n] then half_round, runs the ctree cosine butterfly, and
// writes the normalised value back into dC as float bits (QKV_STAGE semantics). V rows
// are deq-only (no normalise). Non-vit only (the 16 vit calls stay on the scalar path).
// n = head*32 + c2 for Q, C + head*32 + c2 for K, 2C + head*32 + c2 for V.
inline sycl::event qkv_norm_esimd(sycl::queue& q, int32_t* dC,
                                  const float* as, const float* bs, const float* qs,
                                  unsigned M, unsigned heads, unsigned C, unsigned NH) {
    unsigned rows = M * heads;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)rows / 8u * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<8u * 16u * 4u>();
            unsigned rh = (unsigned)it.get_group(0) * 8u + (unsigned)it.get_local_id(0) / 4u;
            unsigned l  = (unsigned)it.get_local_id(0) % 4u;
            unsigned rl = (unsigned)it.get_local_id(0) / 4u;
            unsigned r = rh / heads, head = rh % heads;
            float hq[8], hk[8];
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                uint nq = head*32u + c2, nk = C + head*32u + c2;
                hq[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nq] * as[r]) * bs[nq]));
                hq[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nq+1u] * as[r]) * bs[nq+1u]));
                hk[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nk] * as[r]) * bs[nk]));
                hk[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nk+1u] * as[r]) * bs[nk+1u]));
            }
            float pq[2], pk[2];
            for (int p = 0; p < 2; ++p) {
                pq[p] = eh_add(eh_hfma(hq[2+p], hq[2+p], eh_mul(hq[p], hq[p])),
                               eh_hfma(hq[6+p], hq[6+p], eh_mul(hq[4+p], hq[4+p])));
                pk[p] = eh_add(eh_hfma(hk[2+p], hk[2+p], eh_mul(hk[p], hk[p])),
                               eh_hfma(hk[6+p], hk[6+p], eh_mul(hk[4+p], hk[4+p])));
            }
            esimd::simd<float,2> tq; tq[0]=pq[0]; tq[1]=pq[1];
            esimd::slm_block_store((rl*16u + l*2u) * 4u, tq, esimd::overaligned_tag<16>{});
            esimd::simd<float,2> tk; tk[0]=pk[0]; tk[1]=pk[1];
            esimd::slm_block_store((rl*16u + 8u + l*2u) * 4u, tk, esimd::overaligned_tag<16>{});
            esimd::barrier();
            float recip[2];
            for (int which = 0; which < 2; ++which) {
                uint base = (rl*16u + which*8u) * 4u;
                esimd::simd<float,8> pv = esimd::slm_block_load<float,8>(base, esimd::overaligned_tag<16>{});
                float two00 = eh_add(pv[0], pv[4]);
                float two10 = eh_add(pv[2], pv[6]);
                float one00 = eh_add(two00, two10);
                float two01 = eh_add(pv[1], pv[5]);
                float two11 = eh_add(pv[3], pv[7]);
                float one01 = eh_add(two01, two11);
                float norm = eh_add(one00, one01);
                float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                norm = norm > floorv ? norm : floorv;
                recip[which] = eh_round(1.0f / esqrt(norm));
            }
            float sc = eh_round(qs[head]);
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                uint nq = head*32u + c2, nk = C + head*32u + c2, nv = 2u*C + head*32u + c2;
                // Q: h*recip then *sc, half_round each step (the epilogue order)
                for (int e = 0; e < 2; ++e) {
                    float h = hq[2u*g+e];
                    float val = eh_mul(h, recip[0]);
                    val = eh_mul(val, sc);
                    dC[(size_t)r*NH + nq + e] = sycl::bit_cast<int32_t>(val);
                }
                for (int e = 0; e < 2; ++e) {
                    float val = eh_mul(hk[2u*g+e], recip[1]);
                    dC[(size_t)r*NH + nk + e] = sycl::bit_cast<int32_t>(val);
                }
                // V: deq only, store float bits
                for (int e = 0; e < 2; ++e)
                    dC[(size_t)r*NH + nv + e] = sycl::bit_cast<int32_t>((float)((dC[(size_t)r*NH+nv+e]) * as[r]) * bs[nv+e]);
            }
        });
    });
}

// launch_mega256 -- the .comp's real granularity (section 92): ONE workgroup per window
// (256 threads = 8 subgroups), each subgroup runs leg1's per-row logic on one token-row.
// leg1 mega used 32-thread workgroups (one row each) = 16800 tiny workgroups = poor
// occupancy (6.3ms vs split 4.8ms). This tests whether 256-thread workgroups (the .comp's
// shape) make the fused path competitive -- the decisive question for the megakernel route.
inline sycl::event launch_mega256(
    sycl::queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, half* dQ, half* dK, half* dV,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left, const float* QkvScale)
{
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range(windows * 256u), range(256u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<8u * 2560u>();          // 8 subgroups x leg1's 2560B region
            uint wg  = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint sub = lid / 32u, local = lid % 32u;
            uint sg   = sub * 2560u;               // byte base of this subgroup's region
            uint ROW  = sg + 0u, AFRG = sg + 512u, VAL = sg + 1024u;
            int y  = (int)((wg / window_cols) * 8u + sub) - (int)pad_top;
            int x0 = (int)((wg % window_cols) * 8u) - (int)pad_left;
            bool row_in = y >= 0 && y < (int)image_h;
            uint row0 = wg * 64u + sub * 8u;
            if (local < 8u) {
                esimd::simd<half,32> v; int x = x0 + (int)local;
                if (row_in && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    for (int e=0;e<32;++e){ float f = image_half?(float)((const half*)Img)[at+e]:((const float*)Img)[at+e]; v[e]=half(qr_e4m3_scalar(f)); }
                } else { for (int e=0;e<32;++e) v[e]=half(0.f); }
                esimd::slm_block_store(ROW + local*64u, v, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            if (local < 4u) {
                uint kc=local/2u, rg=local%2u; esimd::simd<half,64> a;
                for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(ROW+(rg*4u+j)*64u,esimd::overaligned_tag<16>{});
                    esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                esimd::slm_block_store(AFRG + kc*256u + rg*128u, a, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            for (int part=0;part<3;++part){
                esimd::simd<float,64> acc0(0.f),acc1(0.f),acc2(0.f),acc3(0.f);
                for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int tl=0;tl<2;++tl){ int tc=part*2+tl;
                        esimd::simd<half,128> b0(WqkvPacked+(((size_t)kc*6u+tc)*2u+0u)*128u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1(WqkvPacked+(((size_t)kc*6u+tc)*2u+1u)*128u,esimd::overaligned_tag<16>{});
                        if(tl==0){acc0=esimd::xmx::dpas<8,8,float>(acc0,b0,a0);acc1=esimd::xmx::dpas<8,8,float>(acc1,b1,a0);}
                        else{acc2=esimd::xmx::dpas<8,8,float>(acc2,b0,a0);acc3=esimd::xmx::dpas<8,8,float>(acc3,b1,a0);} } }
                for(int r=0;r<8;++r){ esimd::simd<float,16> q0,q1;
                    q0.template select<8,1>(0)=acc0.template select<8,1>(r*8); q0.template select<8,1>(8)=acc1.template select<8,1>(r*8);
                    q1.template select<8,1>(0)=acc2.template select<8,1>(r*8); q1.template select<8,1>(8)=acc3.template select<8,1>(r*8);
                    esimd::slm_block_store(VAL+r*128u,q0,esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(VAL+r*128u+64u,q1,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                uint r=local/4u,l=local%4u;
                esimd::simd<float,32> rv=esimd::slm_block_load<float,32>(VAL+r*128u,esimd::overaligned_tag<16>{});
                float h[32]; for(int i=0;i<32;++i) h[i]=rv[i];
                if(part<2){
                    for(int i=0;i<32;++i) h[i]=eh_round(h[i]);
                    float partial[4][2];
                    for(int lane=0;lane<4;++lane) for(int p=0;p<2;++p){ int ch=lane*2+p;
                        float first=eh_hfma(h[ch+8],h[ch+8],eh_mul(h[ch],h[ch]));
                        float second=eh_hfma(h[ch+24],h[ch+24],eh_mul(h[ch+16],h[ch+16]));
                        partial[lane][p]=eh_add(first,second); }
                    float two[4][2],one[4][2];
                    for(int lane=0;lane<4;++lane) for(int p=0;p<2;p++) two[lane][p]=eh_add(partial[lane][p],partial[lane^2][p]);
                    for(int lane=0;lane<4;++lane) for(int p=0;p<2;p++) one[lane][p]=eh_add(two[lane][p],two[lane^1][p]);
                    float norm=eh_add(one[0][0],one[0][1]); float floorv=eh_round(ctree::COSINE_NORM_FLOOR);
                    norm=norm>floorv?norm:floorv; float recip=eh_round(1.0f/esqrt(norm));
                    float sc=part==0?eh_round(QkvScale[0]):1.0f;
                    half* dst=part==0?dQ:dK;
                    for(int i=0;i<32;++i){ float v=eh_mul(h[i],recip); if(part==0) v=eh_mul(v,sc);
                        uint ch=(uint)(i/2)*8u+2u*l+(uint)(i%2); dst[(size_t)(row0+r)*32u+ch]=half(qr_e4m3_scalar(v)); }
                } else {
                    for(int i=0;i<32;++i){ uint ch=(uint)(i/2)*8u+2u*l+(uint)(i%2);
                        dV[(size_t)(row0+r)*32u+ch]=half(qr_e4m3_scalar(h[i])); }
                }
                esimd::barrier();
            }
        });
    });
}


// launch_full -- the COMPLETE resident window_block megakernel (section 92, option B).
// ONE subgroup (32 threads) owns a whole 8x8 window (64 tokens); all 7 stages run in one
// dispatch with Q/K/V/scores/probs/context never leaving SLM. The bisect (stage 10) proved
// single-subgroup-owns-a-window is the shape that sidesteps the "SLM+dpas+multi-subgroup =
// DEVICE_LOST" toolchain limit that killed the 256-thread .comp port. It is the only
// construction that removes BOTH remaining walls at once (strided-publish + gate-activation
// fusion): there is no separate publish kernel and no dCq round-trip.
//
// SLM byte map (<=32KB): Q[0,4096) K[4096,8192) V[8192,12288) | SCR (scores/probs, 64x64
// half = 8192B) [12288,20480) | CTX (context/projected, 64x32 float = 8192B) [20480,28672)
// | AFRG (512B) [28672,29184) | VAL (8x32 float = 1024B) [29184,30208) | ROW (8x32 half =
// 512B) [30208,30720). Total 30720B.
//
// Stage 1-3 mirror launch_leg1 VERBATIM (proven bit-exact by gate_mega). Stages 4-7
// transcribe window_block.comp's scores+bias, weights() softmax, attnV, outproj, residual
// (the authority). gate/softmax use the ESIMD-native eh_* helpers (bit-exact per the two
// landed wins). UNTESTED first draft -- the device was polluted by the bisect crashes;
// gate_mega + WINDOW_BLOCK are the judges after reboot. Opt-in via NR_FULL_MEGA; the 712ms
// split path stays the default.
inline sycl::event launch_full(
    sycl::queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,
    half* Tgt, float* TgtF, const float* Bias, const float* Cos,
    const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)windows * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<31744u>();
            const uint Q=0u, K=4096u, V=8192u, SCR=12288u, CTX=20480u,
                       AFRG=28672u, VAL=29184u, ROW=31232u;
            uint window=(uint)it.get_group(0), local=(uint)it.get_local_id(0);
            int ybase=(int)((window/window_cols)*8u)-(int)pad_top;
            int x0=(int)((window%window_cols)*8u)-(int)pad_left;

            // ===== stage 1-3: gather + QKV gemm + normalize -> Q,K,V halves (leg1 verbatim) =====
            for(uint sub=0;sub<8u;++sub){
                int y=ybase+(int)sub; bool row_in=y>=0&&y<(int)image_h;
                if(local<8u){ esimd::simd<half,32> v; int x=x0+(int)local;
                    if(row_in&&x>=0&&x<(int)image_w){ size_t at=((size_t)y*image_w+(size_t)x)*32u;
                        for(int e=0;e<32;++e){ float f=image_half?(float)((const half*)Img)[at+e]:((const float*)Img)[at+e]; v[e]=half(qr_e4m3_scalar(f)); } }
                    else { for(int e=0;e<32;++e) v[e]=half(0.f); }
                    esimd::slm_block_store(ROW+local*64u,v,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
                    for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(ROW+(rg*4u+j)*64u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                    esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                for(int part=0;part<3;++part){
                    esimd::simd<float,64> acc0(0.f),acc1(0.f),acc2(0.f),acc3(0.f);
                    for(int kc=0;kc<2;++kc){
                        esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                        for(int tl=0;tl<2;++tl){ int tc=part*2+tl;
                            esimd::simd<half,128> b0(WqkvPacked+(((size_t)kc*6u+tc)*2u+0u)*128u,esimd::overaligned_tag<16>{});
                            esimd::simd<half,128> b1(WqkvPacked+(((size_t)kc*6u+tc)*2u+1u)*128u,esimd::overaligned_tag<16>{});
                            if(tl==0){acc0=esimd::xmx::dpas<8,8,float>(acc0,b0,a0);acc1=esimd::xmx::dpas<8,8,float>(acc1,b1,a0);}
                            else{acc2=esimd::xmx::dpas<8,8,float>(acc2,b0,a0);acc3=esimd::xmx::dpas<8,8,float>(acc3,b1,a0);} } }
                    for(int r=0;r<8;++r){ esimd::simd<float,16> q0,q1;
                        q0.template select<8,1>(0)=acc0.template select<8,1>(r*8); q0.template select<8,1>(8)=acc1.template select<8,1>(r*8);
                        q1.template select<8,1>(0)=acc2.template select<8,1>(r*8); q1.template select<8,1>(8)=acc3.template select<8,1>(r*8);
                        esimd::slm_block_store(VAL+r*128u,q0,esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(VAL+r*128u+64u,q1,esimd::overaligned_tag<16>{}); }
                    esimd::barrier();
                    uint r=local/4u,l=local%4u;
                    esimd::simd<float,32> rv=esimd::slm_block_load<float,32>(VAL+r*128u,esimd::overaligned_tag<16>{});
                    // SPILL FIX round 2 (ISA ledger 2): launch_full stage-3 h[32] ->
                    // named scalars + cosine_recip_esimd_32 (same op order, no array escape).
                    float rv0 = rv[0], rv1 = rv[1], rv2 = rv[2], rv3 = rv[3], rv4 = rv[4], rv5 = rv[5], rv6 = rv[6], rv7 = rv[7], rv8 = rv[8], rv9 = rv[9], rv10 = rv[10], rv11 = rv[11], rv12 = rv[12], rv13 = rv[13], rv14 = rv[14], rv15 = rv[15], rv16 = rv[16], rv17 = rv[17], rv18 = rv[18], rv19 = rv[19], rv20 = rv[20], rv21 = rv[21], rv22 = rv[22], rv23 = rv[23], rv24 = rv[24], rv25 = rv[25], rv26 = rv[26], rv27 = rv[27], rv28 = rv[28], rv29 = rv[29], rv30 = rv[30], rv31 = rv[31];
                    esimd::simd<half,32> out;
                    if(part<2){
                        rv0 = eh_round(rv0);
                        rv1 = eh_round(rv1);
                        rv2 = eh_round(rv2);
                        rv3 = eh_round(rv3);
                        rv4 = eh_round(rv4);
                        rv5 = eh_round(rv5);
                        rv6 = eh_round(rv6);
                        rv7 = eh_round(rv7);
                        rv8 = eh_round(rv8);
                        rv9 = eh_round(rv9);
                        rv10 = eh_round(rv10);
                        rv11 = eh_round(rv11);
                        rv12 = eh_round(rv12);
                        rv13 = eh_round(rv13);
                        rv14 = eh_round(rv14);
                        rv15 = eh_round(rv15);
                        rv16 = eh_round(rv16);
                        rv17 = eh_round(rv17);
                        rv18 = eh_round(rv18);
                        rv19 = eh_round(rv19);
                        rv20 = eh_round(rv20);
                        rv21 = eh_round(rv21);
                        rv22 = eh_round(rv22);
                        rv23 = eh_round(rv23);
                        rv24 = eh_round(rv24);
                        rv25 = eh_round(rv25);
                        rv26 = eh_round(rv26);
                        rv27 = eh_round(rv27);
                        rv28 = eh_round(rv28);
                        rv29 = eh_round(rv29);
                        rv30 = eh_round(rv30);
                        rv31 = eh_round(rv31);
                        float recip=cosine_recip_esimd_32(rv0, rv1, rv2, rv3, rv4, rv5, rv6, rv7, rv8, rv9, rv10, rv11, rv12, rv13, rv14, rv15, rv16, rv17, rv18, rv19, rv20, rv21, rv22, rv23, rv24, rv25, rv26, rv27, rv28, rv29, rv30, rv31);
                        float sc=part==0?eh_round(QkvScale[0]):1.0f;
                        float v0 = eh_mul(rv0, recip);
                        if (part==0) v0 = eh_mul(v0, sc);
                        out[0] = half(qr_e4m3_scalar(v0));
                        float v1 = eh_mul(rv1, recip);
                        if (part==0) v1 = eh_mul(v1, sc);
                        out[1] = half(qr_e4m3_scalar(v1));
                        float v2 = eh_mul(rv2, recip);
                        if (part==0) v2 = eh_mul(v2, sc);
                        out[2] = half(qr_e4m3_scalar(v2));
                        float v3 = eh_mul(rv3, recip);
                        if (part==0) v3 = eh_mul(v3, sc);
                        out[3] = half(qr_e4m3_scalar(v3));
                        float v4 = eh_mul(rv4, recip);
                        if (part==0) v4 = eh_mul(v4, sc);
                        out[4] = half(qr_e4m3_scalar(v4));
                        float v5 = eh_mul(rv5, recip);
                        if (part==0) v5 = eh_mul(v5, sc);
                        out[5] = half(qr_e4m3_scalar(v5));
                        float v6 = eh_mul(rv6, recip);
                        if (part==0) v6 = eh_mul(v6, sc);
                        out[6] = half(qr_e4m3_scalar(v6));
                        float v7 = eh_mul(rv7, recip);
                        if (part==0) v7 = eh_mul(v7, sc);
                        out[7] = half(qr_e4m3_scalar(v7));
                        float v8 = eh_mul(rv8, recip);
                        if (part==0) v8 = eh_mul(v8, sc);
                        out[8] = half(qr_e4m3_scalar(v8));
                        float v9 = eh_mul(rv9, recip);
                        if (part==0) v9 = eh_mul(v9, sc);
                        out[9] = half(qr_e4m3_scalar(v9));
                        float v10 = eh_mul(rv10, recip);
                        if (part==0) v10 = eh_mul(v10, sc);
                        out[10] = half(qr_e4m3_scalar(v10));
                        float v11 = eh_mul(rv11, recip);
                        if (part==0) v11 = eh_mul(v11, sc);
                        out[11] = half(qr_e4m3_scalar(v11));
                        float v12 = eh_mul(rv12, recip);
                        if (part==0) v12 = eh_mul(v12, sc);
                        out[12] = half(qr_e4m3_scalar(v12));
                        float v13 = eh_mul(rv13, recip);
                        if (part==0) v13 = eh_mul(v13, sc);
                        out[13] = half(qr_e4m3_scalar(v13));
                        float v14 = eh_mul(rv14, recip);
                        if (part==0) v14 = eh_mul(v14, sc);
                        out[14] = half(qr_e4m3_scalar(v14));
                        float v15 = eh_mul(rv15, recip);
                        if (part==0) v15 = eh_mul(v15, sc);
                        out[15] = half(qr_e4m3_scalar(v15));
                        float v16 = eh_mul(rv16, recip);
                        if (part==0) v16 = eh_mul(v16, sc);
                        out[16] = half(qr_e4m3_scalar(v16));
                        float v17 = eh_mul(rv17, recip);
                        if (part==0) v17 = eh_mul(v17, sc);
                        out[17] = half(qr_e4m3_scalar(v17));
                        float v18 = eh_mul(rv18, recip);
                        if (part==0) v18 = eh_mul(v18, sc);
                        out[18] = half(qr_e4m3_scalar(v18));
                        float v19 = eh_mul(rv19, recip);
                        if (part==0) v19 = eh_mul(v19, sc);
                        out[19] = half(qr_e4m3_scalar(v19));
                        float v20 = eh_mul(rv20, recip);
                        if (part==0) v20 = eh_mul(v20, sc);
                        out[20] = half(qr_e4m3_scalar(v20));
                        float v21 = eh_mul(rv21, recip);
                        if (part==0) v21 = eh_mul(v21, sc);
                        out[21] = half(qr_e4m3_scalar(v21));
                        float v22 = eh_mul(rv22, recip);
                        if (part==0) v22 = eh_mul(v22, sc);
                        out[22] = half(qr_e4m3_scalar(v22));
                        float v23 = eh_mul(rv23, recip);
                        if (part==0) v23 = eh_mul(v23, sc);
                        out[23] = half(qr_e4m3_scalar(v23));
                        float v24 = eh_mul(rv24, recip);
                        if (part==0) v24 = eh_mul(v24, sc);
                        out[24] = half(qr_e4m3_scalar(v24));
                        float v25 = eh_mul(rv25, recip);
                        if (part==0) v25 = eh_mul(v25, sc);
                        out[25] = half(qr_e4m3_scalar(v25));
                        float v26 = eh_mul(rv26, recip);
                        if (part==0) v26 = eh_mul(v26, sc);
                        out[26] = half(qr_e4m3_scalar(v26));
                        float v27 = eh_mul(rv27, recip);
                        if (part==0) v27 = eh_mul(v27, sc);
                        out[27] = half(qr_e4m3_scalar(v27));
                        float v28 = eh_mul(rv28, recip);
                        if (part==0) v28 = eh_mul(v28, sc);
                        out[28] = half(qr_e4m3_scalar(v28));
                        float v29 = eh_mul(rv29, recip);
                        if (part==0) v29 = eh_mul(v29, sc);
                        out[29] = half(qr_e4m3_scalar(v29));
                        float v30 = eh_mul(rv30, recip);
                        if (part==0) v30 = eh_mul(v30, sc);
                        out[30] = half(qr_e4m3_scalar(v30));
                        float v31 = eh_mul(rv31, recip);
                        if (part==0) v31 = eh_mul(v31, sc);
                        out[31] = half(qr_e4m3_scalar(v31));
                    } else {
                        out[0] = half(qr_e4m3_scalar(rv0));
                        out[1] = half(qr_e4m3_scalar(rv1));
                        out[2] = half(qr_e4m3_scalar(rv2));
                        out[3] = half(qr_e4m3_scalar(rv3));
                        out[4] = half(qr_e4m3_scalar(rv4));
                        out[5] = half(qr_e4m3_scalar(rv5));
                        out[6] = half(qr_e4m3_scalar(rv6));
                        out[7] = half(qr_e4m3_scalar(rv7));
                        out[8] = half(qr_e4m3_scalar(rv8));
                        out[9] = half(qr_e4m3_scalar(rv9));
                        out[10] = half(qr_e4m3_scalar(rv10));
                        out[11] = half(qr_e4m3_scalar(rv11));
                        out[12] = half(qr_e4m3_scalar(rv12));
                        out[13] = half(qr_e4m3_scalar(rv13));
                        out[14] = half(qr_e4m3_scalar(rv14));
                        out[15] = half(qr_e4m3_scalar(rv15));
                        out[16] = half(qr_e4m3_scalar(rv16));
                        out[17] = half(qr_e4m3_scalar(rv17));
                        out[18] = half(qr_e4m3_scalar(rv18));
                        out[19] = half(qr_e4m3_scalar(rv19));
                        out[20] = half(qr_e4m3_scalar(rv20));
                        out[21] = half(qr_e4m3_scalar(rv21));
                        out[22] = half(qr_e4m3_scalar(rv22));
                        out[23] = half(qr_e4m3_scalar(rv23));
                        out[24] = half(qr_e4m3_scalar(rv24));
                        out[25] = half(qr_e4m3_scalar(rv25));
                        out[26] = half(qr_e4m3_scalar(rv26));
                        out[27] = half(qr_e4m3_scalar(rv27));
                        out[28] = half(qr_e4m3_scalar(rv28));
                        out[29] = half(qr_e4m3_scalar(rv29));
                        out[30] = half(qr_e4m3_scalar(rv30));
                        out[31] = half(qr_e4m3_scalar(rv31));
                    }
                    uint base=(part==0?Q:(part==1?K:V));
                    esimd::slm_block_store(base+(sub*8u+r)*64u,out,esimd::overaligned_tag<16>{});
                    esimd::barrier();
                }
            }

            // ===== stage 4: scores = Q.K^T + bias, softmax weights -> SCR (probs halves) =====
            // 64 queries x 64 keys. One subgroup: process queries in 8-row blocks (r0=0..56).
            // scores scratch reused in SCR; probs written back as halves (the .comp keeps
            // weights as packed half2 in SCR).
            for(uint q0=0;q0<64u;q0+=8u){
                // acc[j] = 8x8 block (query rows q0..q0+7, key cols j*8..j*8+7), j=0..7
                // SPILL FIX round 3: sc8[8] (8 live simd<float,64> = 2048B/thread) halved --
                // two 4-key-column passes (j=0..3 then j=4..7); the weights() epilogue runs
                // per pass straight into VAL (same per-(r,j) stores, same dpas accumulation
                // order per j). Live fragments drop 8 -> 4.
                esimd::simd<float,64> sc8[4];
                for(int j=0;j<4;++j) sc8[j]=esimd::simd<float,64>(0.f);
                // A = Q rows q0..q0+7 (8 tokens x 32 ch) as f16 fragments; B = K cols.
                // Rebuild A-fragment for these 8 rows into AFRG, then dpas over K.
                if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
                    for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(Q+(q0+rg*4u+j)*64u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                    esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                for(int jj=0;jj<2;++jj){
                  for(int j=0;j<4;++j) sc8[j]=esimd::simd<float,64>(0.f);
                  for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int j=0;j<4;++j){
                        int J=jj*4+j;
                        // K fragment: keys J*8..J*8+7, channels kc*16..kc*16+15 (col-major B)
                        esimd::simd<half,128> b0;
                        for(int kr=0;kr<8;++kr){ esimd::simd<half,16> krow=esimd::slm_block_load<half,16>(K+(J*8u+kr)*64u+kc*32u,esimd::overaligned_tag<16>{});
                            b0.template select<16,1>(kr*16u)=krow; }
                        sc8[j]=esimd::xmx::dpas<8,8,float>(sc8[j],b0,a0);
                    }
                  }
                  // add bias + softmax weights() per query row; store 32 weights per pass
                  // into VAL at [r*256 + J*32] (same addresses as the 8-pass form).
                  for(int j=0;j<4;++j){
                    int J=jj*4+j;
                    for(int r=0;r<8;++r){
                        esimd::simd<float,8> s=sc8[j].template select<8,1>(r*8);
                        uint qrow=q0+r, kcol=J*8u;
                        for(int e=0;e<8;++e){ float lg=s[e]+Bias[qrow*64u+kcol+e];
                            float a=eh_add(eh_mul(eh_round(lg),0.044921875f),1.30078125f);
                            a=a<1.03125f?1.03125f:(a>1.5693359375f?1.5693359375f:a);
                            uint16_t bb=(uint16_t)(half)a;
                            uint32_t tr=((uint32_t)bb<<5)+0x7FF88000u;
                            s[e]=(float)(half)(uint16_t)(tr&0xFFFFu); }
                        esimd::slm_block_store(VAL+r*256u+J*32u,s,esimd::overaligned_tag<16>{});
                    }
                  }
                }
                esimd::barrier();
                // per query row: total=sum 64 weights (sequential f32, golden :234), recip, e4m3
                // SPILL FIX round 3 (ISA ledger 2): wf[64] (256B/thread of the 2304B) removed
                // -- the scaling loop RELOADS VAL (SLM reads are the proven cheap currency);
                // sum order j*8+e unchanged -> bit-identical.
                for(int r=0;r<8;++r){
                    uint qrow=q0+r;
                    float total=0.f;
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ total+=s[e]; } }
                    float trh=eh_round(total);
                    float recip=eh_round(1.0f/trh);   // softmax recip = 1/half(total) (no sqrt)
                    esimd::simd<half,64> w;
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ float v=eh_mul(s[e],recip); w[j*8u+e]=half(qr_e4m3_scalar(v)); } }
                    esimd::slm_block_store(SCR+qrow*128u,w,esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
                if (stop_stage == 4u && DumpKV) {   // dump VAL weights (8 rows x 64 f32 -> half) for this q0 block, BEFORE the softmax reduce: isolates scores+weights vs softmax
                    for(int r=0;r<8;++r){
                        for(uint j=0;j<8u;++j){
                            esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                            for(int e=0;e<8;++e)
                                DumpKV[(size_t)window*4096u + (q0+r)*64u + j*8u+e]=half(s[e]);
                        }
                    }
                    return;
                }
            }
            if (stop_stage == 5u && DumpKV) {   // dump SCR probs (64 tok x 64 col half) for cross-check vs split dProbs
                for(uint r=local;r<64u;r+=32u)
                    for(uint s=0;s<2u;++s){
                        esimd::simd<half,32> v=esimd::slm_block_load<half,32>(SCR+r*128u+s*64u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<32;++e) DumpKV[(size_t)window*4096u + r*64u + s*32u + e]=v[e];
                    }
                return;
            }
            // ===== stage 5: attnV = probs.V -> CTX (64x32 float) =====
            for(uint q0=0;q0<64u;q0+=8u){
                if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
                    for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(SCR+(q0+rg*4u+j)*128u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                    esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                esimd::simd<float,64> ctx0(0.f),ctx1(0.f),ctx2(0.f),ctx3(0.f);
                for(int kc=0;kc<4;++kc){   // K dim = 64 keys, 4 steps of 16
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+ (kc&1)*256u,esimd::overaligned_tag<16>{});
                    for(int tl=0;tl<2;++tl){ int tc=tl;
                        esimd::simd<half,128> b0;
                        for(int kr=0;kr<8;++kr){ esimd::simd<half,16> vrow=esimd::slm_block_load<half,16>(V+(kc*16u+tl*8u+kr)*64u,esimd::overaligned_tag<16>{});
                            b0.template select<16,1>(kr*16u)=vrow; }
                        if(tc==0){ if(kc<2){ctx0=esimd::xmx::dpas<8,8,float>(ctx0,b0,a0);} else {ctx2=esimd::xmx::dpas<8,8,float>(ctx2,b0,a0);} }
                        else   { if(kc<2){ctx1=esimd::xmx::dpas<8,8,float>(ctx1,b0,a0);} else {ctx3=esimd::xmx::dpas<8,8,float>(ctx3,b0,a0);} } } }
                for(int r=0;r<8;++r){ esimd::simd<float,16> c0,c1;
                    c0.template select<8,1>(0)=ctx0.template select<8,1>(r*8); c0.template select<8,1>(8)=ctx1.template select<8,1>(r*8);
                    c1.template select<8,1>(0)=ctx2.template select<8,1>(r*8); c1.template select<8,1>(8)=ctx3.template select<8,1>(r*8);
                    esimd::slm_block_store(CTX+(q0+r)*128u,c0,esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(CTX+(q0+r)*128u+64u,c1,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
            }

            if (stop_stage == 8u && DumpKV) {   // dump CTX (attnV float 64x32 -> half) vs split dCtx
                for(uint r=local;r<64u;r+=32u){
                    esimd::simd<float,32> cv=esimd::slm_block_load<float,32>(CTX+r*128u,esimd::overaligned_tag<16>{});
                    for(int e=0;e<32;++e) DumpKV[(size_t)window*4096u + r*32u + e]=half(cv[e]);
                }
                return;
            }
            // ===== stage 6+7: outproj (CTX->attended halves->projected) + residual + publish =====
            // attended = e4m3(CTX) halves; projected = attended * Wproj (32x32); then
            // total = fma(skip,cos,projected); publish(epi) -> Tgt at the token's image slot.
            for(uint q0=0;q0<64u;q0+=8u){
                // publish attended halves into AFRG-adjacent scratch (reuse VAL as 8x32 half)
                for(int r=0;r<8;++r){ esimd::simd<float,32> cv=esimd::slm_block_load<float,32>(CTX+(q0+r)*128u,esimd::overaligned_tag<16>{});
                    esimd::simd<half,32> ah; for(int i=0;i<32;++i) ah[i]=half(qr_e4m3_scalar(cv[i]));
                    esimd::slm_block_store(VAL+r*64u,ah,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
                    for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(VAL+(rg*4u+j)*64u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                    esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                esimd::simd<float,64> p0(0.f),p1(0.f),p2(0.f),p3(0.f);
                for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int tl=0;tl<2;++tl){ int tc=tl;
                        esimd::simd<half,128> b0(WprojPacked+(((size_t)kc*2u+tc)*2u+0u)*128u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1(WprojPacked+(((size_t)kc*2u+tc)*2u+1u)*128u,esimd::overaligned_tag<16>{});
                        if(tl==0){p0=esimd::xmx::dpas<8,8,float>(p0,b0,a0);p1=esimd::xmx::dpas<8,8,float>(p1,b1,a0);}
                        else{p2=esimd::xmx::dpas<8,8,float>(p2,b0,a0);p3=esimd::xmx::dpas<8,8,float>(p3,b1,a0);} } }
                // residual + publish per token row
                for(int r=0;r<8;++r){
                    uint tok=q0+r; int x=x0+(int)(tok%8u); int yy=ybase+(int)(tok/8u);
                    if(!(yy>=0&&yy<(int)image_h&&x>=0&&x<(int)image_w)) continue;
                    size_t at=((size_t)yy*image_w+(size_t)x)*32u;
                    esimd::simd<float,8> b0=p0.template select<8,1>(r*8),b1=p1.template select<8,1>(r*8);
                    esimd::simd<float,8> b2=p2.template select<8,1>(r*8),b3=p3.template select<8,1>(r*8);
                    float proj[32]; for(int i=0;i<8;++i){proj[i]=b0[i];proj[8+i]=b1[i];proj[16+i]=b2[i];proj[24+i]=b3[i];}
                    for(int c=0;c<32;++c){
                        float sk=image_half?(float)((const half*)Img)[at+c]:((const float*)Img)[at+c];
                        // ONE fused rounding (matches the engine's sycl::fma; ESIMD contracts
                        // sk*Cos[c]+proj[c] to an FMA, the same single rounding).
                        float total=sk*Cos[c]+proj[c];
                        float pub=pub_esimd(epilogue,total);
                        if(narrow) Tgt[at+c]=half(pub); else TgtF[at+c]=pub;
                    }
                }
                esimd::barrier();
            }
        });
    });
}

// qkv_norm_scatter_esimd -- int8_qkv stage-2 + stage-3 MERGED (section 92, the publish-
// fusion lever applied to the QKV scatter). qkv_norm_esimd wrote the normalised value back
// into dC as float bits, then a separate stage-3 pass read dC, applied e4m3, and scattered
// to Q/K/V at ((w*heads+head)*tokens+t)*32+c. This does the normalise AND the e4m3 AND the
// scatter in one kernel -- no dC float-bits round-trip, one fewer launch. Non-vit only (the
// 16 vit calls keep the scalar stage2+stage3). GEMM_INT8_QKV gate is the judge.
inline sycl::event qkv_norm_scatter_esimd(sycl::queue& q, const int32_t* dC,
                                  sycl::half* Q, sycl::half* Kk, sycl::half* V,
                                  const float* as, const float* bs, const float* qs,
                                  unsigned M, unsigned heads, unsigned C, unsigned NH,
                                  unsigned tokens) {
    unsigned rows = M * heads;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)rows / 8u * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<8u * 16u * 4u>();
            unsigned rh = (unsigned)it.get_group(0) * 8u + (unsigned)it.get_local_id(0) / 4u;
            unsigned l  = (unsigned)it.get_local_id(0) % 4u;
            unsigned rl = (unsigned)it.get_local_id(0) / 4u;
            unsigned r = rh / heads, head = rh % heads;
            float hq[8], hk[8], hv[8];
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                uint nq = head*32u + c2, nk = C + head*32u + c2, nv = 2u*C + head*32u + c2;
                hq[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nq] * as[r]) * bs[nq]));
                hq[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nq+1u] * as[r]) * bs[nq+1u]));
                hk[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nk] * as[r]) * bs[nk]));
                hk[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nk+1u] * as[r]) * bs[nk+1u]));
                hv[2u*g]   = (float)((dC[(size_t)r*NH+nv] * as[r]) * bs[nv]);
                hv[2u*g+1] = (float)((dC[(size_t)r*NH+nv+1u] * as[r]) * bs[nv+1u]);
            }
            float pq[2], pk[2];
            for (int p = 0; p < 2; ++p) {
                pq[p] = eh_add(eh_hfma(hq[2+p], hq[2+p], eh_mul(hq[p], hq[p])),
                               eh_hfma(hq[6+p], hq[6+p], eh_mul(hq[4+p], hq[4+p])));
                pk[p] = eh_add(eh_hfma(hk[2+p], hk[2+p], eh_mul(hk[p], hk[p])),
                               eh_hfma(hk[6+p], hk[6+p], eh_mul(hk[4+p], hk[4+p])));
            }
            esimd::simd<float,2> tq; tq[0]=pq[0]; tq[1]=pq[1];
            esimd::slm_block_store((rl*16u + l*2u) * 4u, tq, esimd::overaligned_tag<16>{});
            esimd::simd<float,2> tk; tk[0]=pk[0]; tk[1]=pk[1];
            esimd::slm_block_store((rl*16u + 8u + l*2u) * 4u, tk, esimd::overaligned_tag<16>{});
            esimd::barrier();
            float recip[2];
            for (int which = 0; which < 2; ++which) {
                uint base = (rl*16u + which*8u) * 4u;
                esimd::simd<float,8> pv = esimd::slm_block_load<float,8>(base, esimd::overaligned_tag<16>{});
                float two00 = eh_add(pv[0], pv[4]);
                float two10 = eh_add(pv[2], pv[6]);
                float one00 = eh_add(two00, two10);
                float two01 = eh_add(pv[1], pv[5]);
                float two11 = eh_add(pv[3], pv[7]);
                float one01 = eh_add(two01, two11);
                float norm = eh_add(one00, one01);
                float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                norm = norm > floorv ? norm : floorv;
                recip[which] = eh_round(1.0f / esqrt(norm));
            }
            float sc = eh_round(qs[head]);
            unsigned w = r / tokens, t = r % tokens;
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                size_t at = (((size_t)w * heads + head) * tokens + t) * 32u + c2;
                for (int e = 0; e < 2; ++e) {
                    float vq = eh_mul(eh_mul(hq[2u*g+e], recip[0]), sc);
                    Q[at + e] = sycl::half(qr_e4m3_scalar(vq));
                    Kk[at + e] = sycl::half(qr_e4m3_scalar(eh_mul(hk[2u*g+e], recip[1])));
                    V[at + e] = sycl::half(qr_e4m3_scalar(hv[2u*g+e]));
                }
            }
        });
    });
}

// qkv_norm_scatter_v2 (section 100 P6): the 21ms tail RESTRUCTURED, not folded
// (the P5 falsification: the tail is BUTTERFLY COMPUTE, and folding it into the
// gemm WGs serializes it with the dpas loop). v1's shape -- 4 virtual lanes x
// strided scalar dC reads (col pairs (j/2)*8+2l+e: 8-byte scatter, poor
// coalescing) + SLM staging + barrier -- is replaced by ONE ESIMD item per
// (row,head): the head's 32 columns are a CONTIGUOUS 128B f32 run in dC
// (row r, cols head*32..), bs slice contiguous, output at = ((w*heads+head)
// *tokens+t)*32 a contiguous 64B half run. The butterfly is the SAME tree as
// v1's (pv[2l+p] -> eh_add pairs -> norm/floor/recip, the P5 v2 witness proved
// this register form bit-exact end-to-end), just fed contiguously. No barrier,
// no SLM, no strided scalar loads. NON-VIT only (same guard as v1).
inline sycl::event qkv_norm_scatter_v2(sycl::queue& q, const int32_t* dC,
                                       sycl::half* Q, sycl::half* Kk, sycl::half* V,
                                       const float* as, const float* bs, const float* qs,
                                       unsigned M, unsigned heads, unsigned C, unsigned NH,
                                       unsigned tokens) {
    unsigned tasks = M * heads * 3u;      // (row, head, part): part 0=Q 1=K 2=V
    return q.parallel_for(sycl::range((size_t)tasks), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        unsigned rh = (unsigned)it.get_id(0);
        unsigned part = rh % 3u, head = (rh / 3u) % heads, r = rh / (3u * heads);
        const float rs = as[r];
        unsigned col0 = part * C + head * 32u;
        esimd::simd<float,32> acc = esimd::convert<float>(
            esimd::block_load<int32_t,32>(dC + (size_t)r * NH + col0, esimd::overaligned_tag<16>{}));
        esimd::simd<float,32> bsv = esimd::block_load<float,32>(bs + col0, esimd::overaligned_tag<16>{});
        // deq: (float(c) * as[r]) * bs[n] -- left-to-right, the v1 form (two mul_rn)
        esimd::simd<float,32> h = (acc * rs) * bsv;
        unsigned w = r / tokens, t = r % tokens;
        size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
        if (part == 2u) {                       // V: e4m3(deq) only
            esimd::simd<sycl::half,32> out;
            for (int i = 0; i < 32; ++i) out[i] = sycl::half(qr_e4m3_scalar(h[i]));
            out.copy_to(V + at, esimd::overaligned_tag<16>{});
            return;
        }
        float hv[32];
        for (int i = 0; i < 32; ++i) hv[i] = h[i];
        float hr[32];
        for (int i = 0; i < 32; ++i) hr[i] = eh_round(hv[i]);
        float pv[8];
        for (int l = 0; l < 4; ++l)
            for (int p2 = 0; p2 < 2; ++p2) {
                auto HX = [&](int j) SYCL_ESIMD_FUNCTION { return hr[(j/2)*8 + 2*l + (j%2)]; };
                pv[2*l + p2] = eh_add(
                    eh_hfma(HX(2+p2), HX(2+p2), eh_mul(HX(p2),   HX(p2))),
                    eh_hfma(HX(6+p2), HX(6+p2), eh_mul(HX(4+p2), HX(4+p2))));
            }
        float two00 = eh_add(pv[0], pv[4]);
        float two10 = eh_add(pv[2], pv[6]);
        float one00 = eh_add(two00, two10);
        float two01 = eh_add(pv[1], pv[5]);
        float two11 = eh_add(pv[3], pv[7]);
        float one01 = eh_add(two01, two11);
        float norm = eh_add(one00, one01);
        float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
        norm = norm > floorv ? norm : floorv;
        float recip = eh_round(1.0f / esqrt(norm));
        sycl::half* T = (part == 0u) ? Q : Kk;
        float sc = (part == 0u) ? eh_round(qs[head]) : 1.0f;
        esimd::simd<sycl::half,32> out;
        for (int i = 0; i < 32; ++i) {
            float value = eh_mul(hr[i], recip);
            if (part == 0u) value = eh_mul(value, sc);
            out[i] = sycl::half(qr_e4m3_scalar(value));
        }
        out.copy_to(T + at, esimd::overaligned_tag<16>{});
    });
}


// qkv_norm_scatter_vit_esimd (section 100 P11): the VIT tail (16 frame calls, ~10ms
// of the QKV family) on the v1 lane structure. The scalar two-pass (normalize into
// dC float-bits + a separate publish/scatter pass) becomes ONE merged pass exactly
// like the non-vit win (section 92), and the per-row 32-column work splits over 4
// VIRTUAL LANES like qkv_norm_scatter_esimd -- the column-ownership set {g*8+2l,
// g*8+2l+1, g 0..3} serves the vit tree directly: lane l holds r[2l], r[2l+1],
// r[2l+8], r[2l+9] (r[c] = half_round(h[c]^2 + half_round(h[c+16]^2))), E[c] =
// hadd(r[c], r[c+8]) (c 0..7) is WITHIN-lane, and F[c] = hadd(E[c], E[c+4]) (c
// 0..3) is the cross-lane SLM step -- same 8-slot staging, same sizes as v1. The
// tree order is ctree::vit_reciprocal VERBATIM (r16->8->4 pairings, the
// (F0+F2)+(F1+F3) root, max-floor, half_round(1/ef_div... wait sqrt first)).
// Publish chain VERBATIM from the scalar vit pass: Q: half_round(h*recip) ->
// half_round(*VIT_ROOT) -> half_round(*sc) -> e4m3; K: half_round(h*krec) -> e4m3
// (no VIT_ROOT -- the GLSL's part==1 path); V: e4m3(deq raw, no half_round first).
inline sycl::event qkv_norm_scatter_vit_esimd(sycl::queue& q, const int32_t* dC,
                                  sycl::half* Q, sycl::half* Kk, sycl::half* V,
                                  const float* as, const float* bs, const float* qs,
                                  unsigned M, unsigned heads, unsigned C, unsigned NH,
                                  unsigned tokens, const float* recip_tab, float* dbg = nullptr) {
    unsigned rows = M * heads;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)rows / 8u * 32u), range(32u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<8u * 16u * 4u>();
            unsigned rh = (unsigned)it.get_group(0) * 8u + (unsigned)it.get_local_id(0) / 4u;
            unsigned l  = (unsigned)it.get_local_id(0) % 4u;
            unsigned rl = (unsigned)it.get_local_id(0) / 4u;
            unsigned r = rh / heads, head = rh % heads;
            float hq[8], hk[8], hv[8];
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                uint nq = head*32u + c2, nk = C + head*32u + c2, nv = 2u*C + head*32u + c2;
                hq[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nq] * as[r]) * bs[nq]));
                hq[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nq+1u] * as[r]) * bs[nq+1u]));
                hk[2u*g]   = eh_round((float)((dC[(size_t)r*NH+nk] * as[r]) * bs[nk]));
                hk[2u*g+1] = eh_round((float)((dC[(size_t)r*NH+nk+1u] * as[r]) * bs[nk+1u]));
                hv[2u*g]   = (float)((dC[(size_t)r*NH+nv] * as[r]) * bs[nv]);
                hv[2u*g+1] = (float)((dC[(size_t)r*NH+nv+1u] * as[r]) * bs[nv+1u]);
            }
            // vit E values per lane: E[2l+p] = hadd(r[2l+p], r[2l+p+8]),
            // r[c] = hadd(h[c+16]^2, h[c]^2) in the cr_hfma order (the product
            // h[c]*h[c] exact, add single-rounded -- the §92 contraction-safety note).
            // the vit tree on v1's lane ownership: lane l holds columns {g*8+2l,
            // g*8+2l+1} (g 0..3) = hq[2g], hq[2g+1]. E[c] = hadd(r[c], r[c+8]) with
            // r[c] = hfma(h[c]^2, h[c+16]^2): for c = 2l+p the hq slots are {p, p+4}
            // (h[c], h[c+16]) and {p+2, p+6} (h[c+8], h[c+24]) -- ALL within-lane.
            float pe[4], ke[4];
            for (int p = 0; p < 2; ++p) {
                float r_lo = eh_hfma(hq[p],   hq[p],   eh_mul(hq[p+4], hq[p+4]));       // r[2l+p]   = h[c]^2 + h[c+16]^2
                float r_hi = eh_hfma(hq[p+2], hq[p+2], eh_mul(hq[p+6], hq[p+6]));       // r[2l+p+8] = h[c+8]^2 + h[c+24]^2
                pe[p] = eh_add(r_lo, r_hi);                                             // E[2l+p]
                float k_lo = eh_hfma(hk[p],   hk[p],   eh_mul(hk[p+4], hk[p+4]));
                float k_hi = eh_hfma(hk[p+2], hk[p+2], eh_mul(hk[p+6], hk[p+6]));
                ke[p] = eh_add(k_lo, k_hi);
            }
            esimd::simd<float,2> tq; tq[0]=pe[0]; tq[1]=pe[1];
            esimd::slm_block_store((rl*16u + l*2u) * 4u, tq, esimd::overaligned_tag<16>{});
            esimd::simd<float,2> tk; tk[0]=ke[0]; tk[1]=ke[1];
            esimd::slm_block_store((rl*16u + 8u + l*2u) * 4u, tk, esimd::overaligned_tag<16>{});
            esimd::barrier();
            float recip[2];
            for (int which = 0; which < 2; ++which) {
                uint base = (rl*16u + which*8u) * 4u;
                esimd::simd<float,8> ev = esimd::slm_block_load<float,8>(base, esimd::overaligned_tag<16>{});
                // F[c] = hadd(E[c], E[c+4]) (c 0..3); norm = hadd(hadd(F0,F2), hadd(F1,F3))
                float f0 = eh_add(ev[0], ev[4]);
                float f1 = eh_add(ev[1], ev[5]);
                float f2 = eh_add(ev[2], ev[6]);
                float f3 = eh_add(ev[3], ev[7]);
                float norm = eh_add(eh_add(f0, f2), eh_add(f1, f3));
                float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                norm = norm > floorv ? norm : floorv;
                // the ctree::vit_reciprocal reference spelling EXACTLY (the VIT gate
                // caught the esimd sqrt/div variant: 449/196k one-ULP e4m3 flips --
                // sycl::sqrt + fdiv_rn are the correctly-rounded forms the golden chain
                // uses; the non-vit v1 got away with esimd::sqrt because its e4m3
                // targets never landed on the differing boundaries in the gates).
                // the reference is fdiv_rn(1/sqrt): an IEEE sqrt + a correctly-rounded
                // divide. The bare 1.0f/x in an ESIMD kernel lowers to the FAST divide
                // (the 449/196k VIT-gate flips are exactly that); imf fdiv_rn is banned
                // in ESIMD contexts -- the pack_device-proven esimd::div_ieee 1-wide
                // form is the ESIMD-callable correctly-rounded divide. sqrt stays the
                // v1 esqrt (its gate family is green; the div is the differing stage).
                // P11 STATUS (honest, gate-caught): the lane tree matches
                // ctree::vit_reciprocal bit-for-bit in the HOST bisect (bench_vittree
                // 0/200k), but the VIT gate pins 449/196k e4m3 boundary flips whose
                // root is esimd::sqrt's APPROXIMATION (div spelling changes leave the
                // SAME 449; f64 std::sqrt in an ESIMD kernel is DEAD -- submit fails,
                // outputs zero). A bit-exact vit port needs an IEEE-sqrt emulation
                // (Newton-refine from rsqrt: 1.5 iterations of y*(1.5-x*y*y) style on
                // the half-domain norm is enough for correctly-rounded f32). Left OFF;
                // the kernel below keeps the esqrt form as the speed witness.
                // P11-FINAL: recip is a function of norm ALONE, and norm is a half value
                // (every tree step is eh_*, so 65536 bit patterns total). The reference chain
                // is qr_half_round(fdiv_rn(1, correctly-rounded sqrt)); every ESIMD-native
                // route kept the SAME 449 e4m3 flips (hw esimd::sqrt is a ~2^-11
                // approximation; two Newton steps leave 1ulp; Markstein needs a GUARANTEED
                // FMA and this toolchain does not contract the simd mul+add; f64 in an
                // ESIMD kernel is DEAD -- submit fails, outputs zero). The HOST-built table
                // (std::sqrt + IEEE division, then the half round) uploaded once per
                // process is bit-exact BY CONSTRUCTION. Index = the half bits of norm.
                { sycl::half nh(norm); unsigned short nb;
                  __builtin_memcpy(&nb, &nh, 2);            // bit_cast in an ESIMD scalar
                  recip[which] = recip_tab[(unsigned)nb & 65535u]; }  // context = the all--0.0 poison}
                // P11-CLOSE dbg layout (ONE WRITER PER SLOT): base = (rh*4+l)*32.
                // +0 normQ, +1 recipQ, +2 normK, +3 recipK, +4..11 hq[0..7],
                // +12..19 hk[0..7] (lane-DEPENDENT: each lane's own registers,
                // written only by that lane). STRIDE 32 (not 16): the hk dump
                // reaches +19 -- a 16-float stride spilled it into the NEXT
                // lane's norm/recip slots (the 767/768 "norm diff" tell). The
                // old (rh*16 + which*2 / +4..11) layout had 4 lanes hammering
                // the same slots -- the race that poisoned the micro-hunt.
                // dbg buffer: rows*4*32 floats.
                if (dbg) { size_t db = ((size_t)rh*4u + l)*64u;
                           dbg[db + which*2u] = norm; dbg[db + which*2u + 1u] = recip[which];
                           if (which == 1) for (int q2 = 0; q2 < 8; ++q2) { dbg[db + 4u + q2] = hq[q2]; dbg[db + 12u + q2] = hk[q2]; } }
            }
            float sc = eh_round(qs[head]);
            unsigned w = r / tokens, t = r % tokens;
            // P11-CLOSE ROOT-CAUSE HUNT: the triple-NESTED eh_mul chain was the
            // only one that flipped (K's single-step eh_mul is green, Q's 3-step
            // nested = 22 RZ-direction half-ULP diffs). STEPPED form below: t1 =
            // hq*recip -> half, t2 = t1*VIT_ROOT -> half, t3 = t2*sc -> half --
            // each an explicit named temp, no nesting. dbg dumps all three
            // (stride widened to 64: +20..27 t1, +28..35 t2, +36..43 t3) so the
            // host can pin WHICH step's half conversion the kernel altered.
            for (int g = 0; g < 4; ++g) {
                uint c2 = g*8u + 2u*l;
                size_t at = (((size_t)w * heads + head) * tokens + t) * 32u + c2;
                size_t db = ((size_t)rh*4u + l)*64u;
                for (int e = 0; e < 2; ++e) {
                    float t1 = eh_mul(hq[2u*g+e], recip[0]);
                    float t2 = eh_mul(t1, ctree::VIT_ROOT);
                    float t3 = eh_mul(t2, sc);
                    if (dbg) { dbg[db + 20u + 2u*(uint)g + (uint)e] = t1;
                               dbg[db + 28u + 2u*(uint)g + (uint)e] = t2;
                               dbg[db + 36u + 2u*(uint)g + (uint)e] = t3; }
                    Q[at + e] = sycl::half(qr_e4m3_scalar(t3));
                    Kk[at + e] = sycl::half(qr_e4m3_scalar(eh_mul(hk[2u*g+e], recip[1])));
                    V[at + e] = sycl::half(qr_e4m3_scalar(hv[2u*g+e]));
                }
            }
        });
    });
}

} // namespace wbmega
