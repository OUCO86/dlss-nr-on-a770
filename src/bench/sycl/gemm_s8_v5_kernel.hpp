// gemm_s8_v5_kernel.hpp — the QKV projection as ONE ESIMD pass (V branch first).
//
// v1/v3's main loop (int8 -> int32) + the shipped gemm_staged_int8.comp QKV epilogue
// (bit 0x100000): dequantise (island-3) -> publish E4M3 (island-4) -> scatter the three
// outputs Q,K,V into (window, head, token, 32) order (qkv_epilogue.glsl:60-75).
//
// V-ONLY step (this file, section 33's "one variable"): V skips the cosine normalise, so
// every element is dequantised + published + scattered entirely within its own WI's 16x16
// tile -- NO cross-WI SLM float stage needed. Q/K need the head's 32 channels in one hand
// (the fragment-tree norm), which is the shipped kernel's SLM float-stage trick -- that is
// the NEXT step, done with v3's proven cross-WI SLM pattern (rmax atomic), not guessed.
//
// Geometry = v1/v3's proven tiling: BM=128 BN=64 BK=32, 32 WI = 8x4 (WI_ROWS=BM/16=8,
// wi_row=lid/4 spans 0..7 exactly). The first draft's BM=64 was broken: WI_ROWS=4 but
// wi_row=lid/WI_COLS=lid/4 spans 0..7, so offA=wi_row*512 read PAST SLM_A (2048 B) and
// load_block's lid*64 only covered half the 4096 B buffer the addressing assumed -- one
// block row hid it (bad rows >= M get skipped), two block rows corrupted rows 64..127.
// channels % 64 == 0 (xmxres.py:1331) => BN=64 spans whole heads; head = col/32.
//
// Dequantise order = shipped (gemm_staged_int8.comp:210): float(acc) * a_scale[row] *
// b_scale[col], left to right, two f32 multiplies. Publish = e4m3(value) as f16.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "publish_kernel.hpp"   // qr_e4m3_scalar (ESIMD-safe), qr_half_round, cr_mul

namespace s8v5 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 64, BK = 32, NT = 32;
static const int WI_ROWS = BM / 16, WI_COLS = BN / 16;          // 8 x 4 = 32 = NT
static const int SLM_A = BM * BK;                               // 4096 B per buffer
static const int SLM_B = BK * BN;                               // 2048 B per buffer
static const int SLM_B_BASE = 2 * SLM_A;
static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;             // 12288 B (v1/v3's budget)

static inline void pack_a(const int8_t* A, int8_t* Ap, int M, int K) {
    int wgr = M / BM, kb_n = K / BK;
    for (int w = 0; w < wgr; ++w)
        for (int kb = 0; kb < kb_n; ++kb)
            for (int wi = 0; wi < WI_ROWS; ++wi)
                for (int row = 0; row < 16; ++row)
                    for (int k = 0; k < 32; ++k)
                        Ap[(((size_t)(w * kb_n + kb) * WI_ROWS + wi) * 512) + row * 32 + k] =
                            A[(size_t)(w * BM + wi * 16 + row) * K + kb * BK + k];
}
static inline void pack_b(const int8_t* B, int8_t* Bp, int K, int N) {
    for (int kk32 = 0; kk32 < K / 32; ++kk32)
        for (int ntile = 0; ntile < N / 8; ++ntile)
            for (int kq = 0; kq < 8; ++kq)
                for (int nl = 0; nl < 8; ++nl)
                    for (int j = 0; j < 4; ++j)
                        Bp[(((size_t)kk32 * (N / 8) + ntile) * 64 + kq * 8 + nl) * 4 + j] =
                            B[(size_t)(kk32 * 32 + kq * 4 + j) * N + (ntile * 8 + nl)];
}

// scatter one 8-col run of one row: value -> e4m3 -> target[(window,head,token,32)]
// V-branch-only GEMM: C[M,channels] = A[M,channels] @ Bv[channels,channels], with the
// V weights alone (the Q/K column blocks need the fragment-tree norm and come next).
// b_scale is the V part's columns (length channels); output V is rows*(channels) halves
// scattered to (window, head, token, 32).
static inline sycl::event gemm_qkv_v(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     const float* a_scale, const float* b_scale,
                                     sycl::half* V,
                                     int M, int channels, int heads, int tokens) {
    int NB = channels / BN;                 // V's own column blocks
    int wg = (M / BM) * NB;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            int col0 = wg_col * BN;         // absolute V column of the block
            const int8_t* apb = Ap + (size_t)(wg_row * (channels / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                // A block = BM*BK = 128*32 = 4096 B: 32 WI at 128 B each (v1's width).
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
                // B block = BK*BN = 32*64 = 2048 B: 32 WI at 64 B each.
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * channels * 32 + lid * 64, esimd::overaligned_tag<16>{});
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
            int kb_n = channels / BK;
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
            // ---- V branch: dequantise -> e4m3 -> scatter, all within each WI's tile ----
            int gr = wg_row * BM + wi_row * 16, gc = col0 + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                int rowA = gr + r, rowB = gr + 8 + r;
                if (rowA < M) {
                    float asA = a_scale[rowA];
                    int window = rowA / tokens, token = rowA % tokens;
                    // c00: cols gc..gc+7 (head = gc/32 within channels, chan = gc%32 .. +7)
                    esimd::simd<float, 8> f00 = esimd::convert<float>(c00.select<8, 1>(r * 8).read());
                    esimd::simd<float, 8> f01 = esimd::convert<float>(c01.select<8, 1>(r * 8).read());
                    for (int i = 0; i < 8; ++i) {
                        int cA = gc + i, cB = gc + 8 + i;
                        int headA = (cA % channels) / 32, chanA = cA % 32;
                        int headB = (cB % channels) / 32, chanB = cB % 32;
                        float vA = f00[i] * asA * b_scale[cA];
                        float vB = f01[i] * asA * b_scale[cB];
                        size_t atA = ((size_t)window * heads + headA) * tokens + token;
                        size_t atB = ((size_t)window * heads + headB) * tokens + token;
                        V[atA * 32 + chanA] = sycl::half(qr_e4m3_scalar(vA));
                        V[atB * 32 + chanB] = sycl::half(qr_e4m3_scalar(vB));
                    }
                }
                if (rowB < M) {
                    float asB = a_scale[rowB];
                    int window = rowB / tokens, token = rowB % tokens;
                    esimd::simd<float, 8> f10 = esimd::convert<float>(c10.select<8, 1>(r * 8).read());
                    esimd::simd<float, 8> f11 = esimd::convert<float>(c11.select<8, 1>(r * 8).read());
                    for (int i = 0; i < 8; ++i) {
                        int cA = gc + i, cB = gc + 8 + i;
                        int headA = (cA % channels) / 32, chanA = cA % 32;
                        int headB = (cB % channels) / 32, chanB = cB % 32;
                        float vA = f10[i] * asB * b_scale[cA];
                        float vB = f11[i] * asB * b_scale[cB];
                        size_t atA = ((size_t)window * heads + headA) * tokens + token;
                        size_t atB = ((size_t)window * heads + headB) * tokens + token;
                        V[atA * 32 + chanA] = sycl::half(qr_e4m3_scalar(vA));
                        V[atB * 32 + chanB] = sycl::half(qr_e4m3_scalar(vB));
                    }
                }
            }
        });
    });
}

} // namespace s8v5
