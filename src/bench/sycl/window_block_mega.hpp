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
    unsigned epilogue, bool narrow)
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
                    float h[32]; for(int i=0;i<32;++i) h[i]=rv[i];
                    esimd::simd<half,32> out;
                    if(part<2){
                        for(int i=0;i<32;++i) h[i]=eh_round(h[i]);
                        float recip=cosine_recip_esimd(h);
                        float sc=part==0?eh_round(QkvScale[0]):1.0f;
                        for(int i=0;i<32;++i){ float v=eh_mul(h[i],recip); if(part==0) v=eh_mul(v,sc); out[i]=half(qr_e4m3_scalar(v)); }
                    } else {
                        for(int i=0;i<32;++i) out[i]=half(qr_e4m3_scalar(h[i]));
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
                esimd::simd<float,64> sc8[8];
                for(int j=0;j<8;++j) sc8[j]=esimd::simd<float,64>(0.f);
                // A = Q rows q0..q0+7 (8 tokens x 32 ch) as f16 fragments; B = K cols.
                // Rebuild A-fragment for these 8 rows into AFRG, then dpas over K.
                if(local<4u){ uint kc=local/2u,rg=local%2u; esimd::simd<half,64> a;
                    for(int j=0;j<4;++j){ esimd::simd<half,32> r=esimd::slm_block_load<half,32>(Q+(q0+rg*4u+j)*64u,esimd::overaligned_tag<16>{});
                        esimd::simd<half,16> hh=(kc==0u)?r.template select<16,1>(0):r.template select<16,1>(16); a.template select<16,1>(j*16u)=hh; }
                    esimd::slm_block_store(AFRG+kc*256u+rg*128u,a,esimd::overaligned_tag<16>{}); }
                esimd::barrier();
                for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int j=0;j<8;++j){
                        // K fragment: keys j*8..j*8+7, channels kc*16..kc*16+15 (col-major B)
                        esimd::simd<half,128> b0;
                        for(int kr=0;kr<8;++kr){ esimd::simd<half,16> krow=esimd::slm_block_load<half,16>(K+(j*8u+kr)*64u+kc*32u,esimd::overaligned_tag<16>{});
                            b0.template select<16,1>(kr*16u)=krow; }
                        sc8[j]=esimd::xmx::dpas<8,8,float>(sc8[j],b0,a0);
                    }
                }
                // add bias + softmax weights() per query row; store the 64 weights as HALF
                // in VAL (8 rows x 64 x 2B = 1024B, exactly the VAL region).
                for(int j=0;j<8;++j){
                    for(int r=0;r<8;++r){
                        esimd::simd<float,8> s=sc8[j].template select<8,1>(r*8);
                        uint qrow=q0+r, kcol=j*8u;
                        for(int e=0;e<8;++e){ float lg=s[e]+Bias[qrow*64u+kcol+e];
                            float a=eh_add(eh_mul(eh_round(lg),0.044921875f),1.30078125f);
                            a=a<1.03125f?1.03125f:(a>1.5693359375f?1.5693359375f:a);
                            uint16_t bb=(uint16_t)(half)a;
                            uint32_t tr=((uint32_t)bb<<5)+0x7FF88000u;
                            s[e]=(float)(half)(uint16_t)(tr&0xFFFFu); }
                        esimd::slm_block_store(VAL+r*256u+j*32u,s,esimd::overaligned_tag<16>{});
                    }
                }
                esimd::barrier();
                // per query row: total=sum 64 weights (sequential f32, golden :234), recip, e4m3
                for(int r=0;r<8;++r){
                    uint qrow=q0+r;
                    float total=0.f; float wf[64];
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ float wv=s[e]; total+=wv; wf[j*8u+e]=wv; } }
                    float trh=eh_round(total);
                    float recip=eh_round(1.0f/trh);   // softmax recip = 1/half(total) (no sqrt)
                    esimd::simd<half,64> w;
                    for(int e=0;e<64;++e){ float v=eh_mul(wf[e],recip); w[e]=half(qr_e4m3_scalar(v)); }
                    esimd::slm_block_store(SCR+qrow*128u,w,esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
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
} // namespace wbmega
