// qkv_resident.hpp -- section 100 P5: the QKV gemm with the SENIOR'S resident
// epilogue (qkv_epilogue.glsl, our geometry). The split path writes dC (int32
// Mp x 3C = 25MB/call) then a separate norm_scatter kernel reads it back -- the
// 21.3ms tail of the QKV family. Here: after the dpas loop (byte-identical to
// s8v8::gemm), the fragments dequantise ((float(c)*as[r])*bs[n], the scatter
// kernel's EXACT left-to-right float form) into the DEAD OPERAND SLM as float
// bits (BM x BN int32 = 128x64x4 = 32KB, aliasing SLM_A/SLM_B exactly like the
// promoted gemm_b_pub_slm), one barrier, then each thread owns WHOLE tile rows
// (r = lid, lid+NT, ...): it reads its row's 64 contiguous floats from SLM --
// BN=64 blocks are head-aligned (head=32 cols) and the frame's C=64 makes each
// block exactly one PART (Q|K|V) x 2 heads -- runs the qkv_norm_scatter_esimd
// butterfly VERBATIM (the virtual-lane idx(j)=(j/2)*8+2l+e pairings, the same
// eh_* single-rounding ops, same order -- the SLM staging in the original only
// moves bytes, the arithmetic tree per element is identical), and publishes
// e4m3 straight to the Q/K/V targets at = ((w*heads+head)*tokens+t)*32+c.
// dC AND the 21ms tail kernel both vanish. NON-VIT ONLY + C%64==0 (the frame
// is C=64; the 16 vit calls keep the scalar split -- vit's different tree).
// NO extra SLM beyond the 32KB tile (the senior's power-of-two 23ms lesson).
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "window_block_mega.hpp"   // wbmega::eh_* / esqrt / qr_e4m3_scalar family

namespace qres {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static inline sycl::event gemm_qkv_res(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                       half* Q, half* Kk, half* V,
                                       const float* as, const float* bs, const float* qs,
                                       int M, int Mp, int C, int NH, int heads, int tokens) {
    using namespace s8v8;   // BM BN BK NT SLM_*
    const int wg = (Mp / BM) * (NH / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<BM * BN * 4>();   // 32KB = the tile over the operand region
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = NH / BN;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (C / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * NH * 32 + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM_B_BASE + buf * SLM_B + lid * 64, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A + wi_row * 512;
                uint32_t offB = SLM_B_BASE + buf * SLM_B + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            esimd::barrier();
            int kb_n = C / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b & 1, nxt = cur ^ 1;
                if (b + 1 < kb_n) load_block(nxt, b + 1);
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            // ---- stage: (float(c)*as[r])*bs[col] -> float bits in the dead operand SLM
            int gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                int gr0 = wg_row * BM + wi_row * 16 + r, gr1 = gr0 + 8;
                float rs0 = as[gr0 < M ? gr0 : (M - 1)], rs1 = as[gr1 < M ? gr1 : (M - 1)];
                esimd::simd<float,16> f0, f1;
                f0.template select<8,1>(0) = esimd::convert<float>(c00.template select<8,1>(r*8).read()) * rs0;
                f0.template select<8,1>(8) = esimd::convert<float>(c01.template select<8,1>(r*8).read()) * rs0;
                f1.template select<8,1>(0) = esimd::convert<float>(c10.template select<8,1>(r*8).read()) * rs1;
                f1.template select<8,1>(8) = esimd::convert<float>(c11.template select<8,1>(r*8).read()) * rs1;
                f0 = f0 * cs; f1 = f1 * cs;
                esimd::slm_block_store<float,16>((uint32_t)((wi_row*16 + r) * BN + wi_col*16) * 4u, f0, esimd::overaligned_tag<16>{});
                esimd::slm_block_store<float,16>((uint32_t)((wi_row*16 + 8 + r) * BN + wi_col*16) * 4u, f1, esimd::overaligned_tag<16>{});
            }
            esimd::barrier();
            // ---- head tail v2: one thread = one (row, head) = 32 cols (the v1
            // row-wide h[64]+hr[32] live set spilled the GRF -- A/B showed no win;
            // halving it: 256 (row,head) tasks / 32 threads = 8 each). ----
            const int part = (wg_col * BN) / C;                 // C==64==BN: 0=Q 1=K 2=V
            const unsigned head0 = (unsigned)((wg_col * BN) % C) / 32u;
            for (int k = 0; k < BM * 2 / NT; ++k) {
                int idx = k * NT + lid;
                int row = idx / 2, hpart = idx % 2;   // NOT 'half': it shadows the type
                int r = wg_row * BM + row;
                if (r >= M) continue;
                esimd::simd<float,32> seg = esimd::slm_block_load<float,32>(
                    (uint32_t)(row * BN + hpart * 32) * 4u, esimd::overaligned_tag<16>{});
                float h[32];
                for (int i = 0; i < 32; ++i) h[i] = seg[i];
                unsigned head = head0 + (unsigned)hpart;
                unsigned w = (unsigned)r / (unsigned)tokens, t = (unsigned)r % (unsigned)tokens;
                size_t at = (((size_t)w * heads + head) * tokens + t) * 32u;
                if (part == 2) {                     // V: deq-only, e4m3 (no round first)
                    for (int i = 0; i < 32; ++i)
                        V[at + i] = sycl::half(qr_e4m3_scalar(h[i]));
                    continue;
                }
                float hr[32];
                for (int i = 0; i < 32; ++i) hr[i] = wbmega::eh_round(h[i]);
                float pv[8];
                for (int l = 0; l < 4; ++l)
                    for (int p2 = 0; p2 < 2; ++p2) {
                        auto HX = [&](int j) { return hr[(j/2)*8 + 2*l + (j%2)]; };
                        pv[2*l + p2] = wbmega::eh_add(
                            wbmega::eh_hfma(HX(2+p2), HX(2+p2), wbmega::eh_mul(HX(p2),   HX(p2))),
                            wbmega::eh_hfma(HX(6+p2), HX(6+p2), wbmega::eh_mul(HX(4+p2), HX(4+p2))));
                    }
                float two00 = wbmega::eh_add(pv[0], pv[4]);
                float two10 = wbmega::eh_add(pv[2], pv[6]);
                float one00 = wbmega::eh_add(two00, two10);
                float two01 = wbmega::eh_add(pv[1], pv[5]);
                float two11 = wbmega::eh_add(pv[3], pv[7]);
                float one01 = wbmega::eh_add(two01, two11);
                float norm = wbmega::eh_add(one00, one01);
                float floorv = wbmega::eh_round(ctree::COSINE_NORM_FLOOR);
                norm = norm > floorv ? norm : floorv;
                float recip = wbmega::eh_round(1.0f / wbmega::esqrt(norm));
                half* T = (part == 0) ? Q : Kk;
                float sc = (part == 0) ? wbmega::eh_round(qs[head]) : 1.0f;
                for (int i = 0; i < 32; ++i) {
                    float value = wbmega::eh_mul(hr[i], recip);
                    if (part == 0) value = wbmega::eh_mul(value, sc);
                    T[at + i] = sycl::half(qr_e4m3_scalar(value));
                }
            }
        });
    });
}
}
