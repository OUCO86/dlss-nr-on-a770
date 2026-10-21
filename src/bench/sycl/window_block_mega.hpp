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
#include "cosine_tree_kernel.hpp"

namespace wbmega {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static inline float eh_round(float x) { return (float)(half)x; }
static inline float eh_mul(float a, float b) { return (float)(half)(a * b); }
static inline float eh_add(float a, float b) { return (float)(half)(a + b); }
static inline float eh_hfma(float l, float r, float acc) { return (float)(half)(l * r + acc); }
static inline float esqrt(float x) { esimd::simd<float, 1> v(x); return esimd::sqrt(v)[0]; }

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
                    float h[32];
                    for (int i = 0; i < 32; ++i) h[i] = rowv[i];
                    esimd::simd<half, 32> out8;
                    if (part < 2) {
                        for (int i = 0; i < 32; ++i) h[i] = eh_round(h[i]);
                        // ctree::cosine_reciprocal order, scalar (ESIMD-native helpers)
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
                            for (int p2 = 0; p2 < 2; p2++) two[lane][p2] = eh_add(partial[lane][p2], partial[lane ^ 2][p2]);
                        for (int lane = 0; lane < 4; ++lane)
                            for (int p2 = 0; p2 < 2; p2++) one[lane][p2] = eh_add(two[lane][p2], two[lane ^ 1][p2]);
                        float norm = eh_add(one[0][0], one[0][1]);
                        float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                        norm = norm > floorv ? norm : floorv;
                        float recip = eh_round(1.0f / esqrt(norm));
                        float sc = part == 0 ? eh_round(QkvScale[0]) : 1.0f;
                        for (int i = 0; i < 32; ++i) {
                            float v = eh_mul(h[i], recip);
                            if (part == 0) v = eh_mul(v, sc);
                            out8[i] = half(qr_e4m3_scalar(v));
                        }
                        half* dst = part == 0 ? dQ : dK;
                        out8.copy_to(dst + (size_t)(row0 + lid) * 32u);
                    } else {
                        for (int i = 0; i < 32; ++i) out8[i] = half(qr_e4m3_scalar(h[i]));
                        out8.copy_to(dV + (size_t)(row0 + lid) * 32u);
                    }
                }
                esimd::barrier();
            }
        });
    });
}
} // namespace wbmega
