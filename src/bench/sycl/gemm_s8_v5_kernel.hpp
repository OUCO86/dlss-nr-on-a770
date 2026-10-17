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
#include "cosine_tree_kernel.hpp"  // ctree::cosine_reciprocal / vit_reciprocal (island-2)

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

// ---- S3a pass 1: Q/K branch, GEMM + dequantise -> float32 global (tile-local). ----
// The cross-WI need is ONLY the fragment-tree norm (one head's 32 channels in one hand),
// and ESIMD cannot call the libdevice rounding ops the proven ctree uses -- so the chain
// composes three gated pieces first (section 22's precedent: v1-int32 was a PATH gate,
// v3 fused it later). S3b = fold passes 2+3 back in with esimd-native arithmetic.
// Each WI dequantises its own 16x16 tile (shipped multiply order, :210) and stores f32.
static inline sycl::event gemm_qkv_deq(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                       const float* a_scale, const float* b_scale,
                                       float* OUT,
                                       int M, int channels) {
    int NB = channels / BN;
    int wg = (M / BM) * NB;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            int col0 = wg_col * BN;
            const int8_t* apb = Ap + (size_t)(wg_row * (channels / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
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
            int gr = wg_row * BM + wi_row * 16, gc = col0 + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                int rowA = gr + r, rowB = gr + 8 + r;
                if (rowA < M) {
                    float asA = a_scale[rowA];
                    esimd::simd<float, 8> f00 = esimd::convert<float>(c00.select<8, 1>(r * 8).read());
                    esimd::simd<float, 8> f01 = esimd::convert<float>(c01.select<8, 1>(r * 8).read());
                    esimd::block_store(OUT + (size_t)rowA * channels + gc,
                                       f00 * asA * esimd::block_load<float, 8>(b_scale + gc, esimd::overaligned_tag<16>{}));
                    esimd::block_store(OUT + (size_t)rowA * channels + gc + 8,
                                       f01 * asA * esimd::block_load<float, 8>(b_scale + gc + 8, esimd::overaligned_tag<16>{}));
                }
                if (rowB < M) {
                    float asB = a_scale[rowB];
                    esimd::simd<float, 8> f10 = esimd::convert<float>(c10.select<8, 1>(r * 8).read());
                    esimd::simd<float, 8> f11 = esimd::convert<float>(c11.select<8, 1>(r * 8).read());
                    esimd::block_store(OUT + (size_t)rowB * channels + gc,
                                       f10 * asB * esimd::block_load<float, 8>(b_scale + gc, esimd::overaligned_tag<16>{}));
                    esimd::block_store(OUT + (size_t)rowB * channels + gc + 8,
                                       f11 * asB * esimd::block_load<float, 8>(b_scale + gc + 8, esimd::overaligned_tag<16>{}));
                }
            }
        });
    });
}

// ---- route-B block 3 (section 38/41): the V branch with COLUMN quantization. ----
// Why columns: attnV = P.V reduces over TOKENS, so a per-token (row) scale on V would
// sit INSIDE the accumulation sum (vs_t * Σ ... wrong). A per-(window,channel) column
// scale factors out of the sum cleanly (Σ_t p_t * (v_tc * cs_c) = cs_c * Σ_t p_t v_tc).
// The seniors' e4m3 per-element container never had this problem; int8 does.
//
// No float stage needed (unlike the Q/K draft's mistake): the accumulator GRFs c00..c11
// are still live in the epilogue (v3's phase2 requantizes straight from them). Phase 1
// computes each column's local max ACROSS the WI's 16 rows (the transposed v3 pattern:
// eight row-vectors, abs, element-wise max -- 16 columns per WI), atomic-fmax into SLM
// colmax. Phase 2 re-derives the dequantised value from the same GRFs (pure arithmetic,
// no memory), reads colmax, requantizes (v3's contract: inv=127/cmax, rint, clip +-127,
// scale=cmax/127) and scatters int8 in (window, head, token, 32) order.
//
// Window structure: BM=128 rows = 2 windows of tokens=64 (the window-attention token
// count; the gate uses tokens=64). WI tiles are 16 rows at wi_row*16, and 64 % 16 == 0,
// so every tile lies wholly inside ONE window: window_local = wi_row >= 4. colmax is
// [2 windows][BN=64 cols] = 512 B of SLM after the operand buffers.
static const int CMAX_BASE = SLM_TOTAL;                 // bytes
static const int SLM_TOTAL_V8 = SLM_TOTAL + 2 * BN * 4; // + 512 B colmax

static inline sycl::event gemm_qkv_v_i8(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                        const float* a_scale, const float* b_scale,
                                        signed char* V8, float* v_scale,
                                        int M, int channels, int heads, int tokens) {
    int NB = channels / BN;
    int wg = (M / BM) * NB;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL_V8>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            int col0 = wg_col * BN;
            // zero the colmax region BEFORE any atomic-fmax (v3's lesson: without the
            // init the atomic races garbage -- gemm_s8_v3_kernel.hpp:63-67).
            for (int j = 0; j < 2 * BN / NT; ++j)
                esimd::slm_block_store(CMAX_BASE + (lid + NT * j) * 4,
                                       esimd::simd<float, 1>(0.f), esimd::overaligned_tag<16>{});
            const int8_t* apb = Ap + (size_t)(wg_row * (channels / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
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
            int gr = wg_row * BM + wi_row * 16, gc = col0 + wi_col * 16;
            int wloc = wi_row >= 4 ? 1 : 0;              // tile wholly inside one window
            // ---- phase 1: column-local max across the tile's 16 rows, atomic-fmax ----
            // deq = float(acc) * a_scale[row] * b_scale[col] (shipped left-to-right order).
            // The row scale varies per row, so the abs-max over rows must be taken AFTER
            // the full dequantise (unlike v3, whose row-max only needed col_scale folded).
            {
                esimd::simd<float, 8> m_lo(0.f), m_hi(0.f);   // cols gc..gc+7, gc+8..gc+15
                for (int r = 0; r < 8; ++r) {
                    int rowA = gr + r, rowB = gr + 8 + r;
                    float asA = a_scale[rowA < M ? rowA : M - 1];
                    float asB = a_scale[rowB < M ? rowB : M - 1];
                    esimd::simd<float, 8> cs_lo = esimd::block_load<float, 8>(b_scale + gc, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> cs_hi = esimd::block_load<float, 8>(b_scale + gc + 8, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> f00 = esimd::convert<float>(c00.select<8, 1>(r * 8).read()) * asA * cs_lo;
                    esimd::simd<float, 8> f01 = esimd::convert<float>(c01.select<8, 1>(r * 8).read()) * asA * cs_hi;
                    esimd::simd<float, 8> f10 = esimd::convert<float>(c10.select<8, 1>(r * 8).read()) * asB * cs_lo;
                    esimd::simd<float, 8> f11 = esimd::convert<float>(c11.select<8, 1>(r * 8).read()) * asB * cs_hi;
                    m_lo = esimd::max(m_lo, esimd::abs(f00));
                    m_hi = esimd::max(m_hi, esimd::abs(f01));
                    m_lo = esimd::max(m_lo, esimd::abs(f10));
                    m_hi = esimd::max(m_hi, esimd::abs(f11));
                }
                for (int j = 0; j < 8; ++j) {
                    esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                        esimd::simd<uint32_t, 1>((uint32_t)(CMAX_BASE + (wloc * BN + wi_col * 16 + j) * 4)),
                        esimd::simd<float, 1>(m_lo[j]));
                    esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                        esimd::simd<uint32_t, 1>((uint32_t)(CMAX_BASE + (wloc * BN + wi_col * 16 + 8 + j) * 4)),
                        esimd::simd<float, 1>(m_hi[j]));
                }
            }
            esimd::barrier();
            // ---- phase 2: re-derive deq from the live GRFs, requantize by column, scatter ----
            // colmax is per (window, column) and does NOT depend on r, so read the two
            // 8-wide runs ONCE (v3's slm_block_load pattern; there is no scalar slm_load).
            esimd::simd<float, 8> lo127(-127.f), hi127(127.f);
            esimd::simd<float, 8> cm_lo = esimd::slm_block_load<float, 8>(
                CMAX_BASE + (wloc * BN + wi_col * 16) * 4, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> cm_hi = esimd::slm_block_load<float, 8>(
                CMAX_BASE + (wloc * BN + wi_col * 16 + 8) * 4, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> inv_lo(0.f), inv_hi(0.f);
            for (int j = 0; j < 8; ++j) {
                float cl = cm_lo[j], ch = cm_hi[j];      // simd<float,1> -> float (v3's pattern)
                inv_lo[j] = (cl > 0.f) ? 127.0f / cl : 0.f;
                inv_hi[j] = (ch > 0.f) ? 127.0f / ch : 0.f;
            }
            esimd::simd<float, 8> cs_lo = esimd::block_load<float, 8>(b_scale + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> cs_hi = esimd::block_load<float, 8>(b_scale + gc + 8, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                int rowA = gr + r, rowB = gr + 8 + r;
                if (rowA < M) {
                    float asA = a_scale[rowA];
                    int window = rowA / tokens, token = rowA % tokens;
                    esimd::simd<float, 8> f00 = esimd::convert<float>(c00.select<8, 1>(r * 8).read()) * asA * cs_lo;
                    esimd::simd<float, 8> f01 = esimd::convert<float>(c01.select<8, 1>(r * 8).read()) * asA * cs_hi;
                    esimd::simd<float, 8> q00 = esimd::min(esimd::max(esimd::rnde<float, 8>(f00 * inv_lo), lo127), hi127);
                    esimd::simd<float, 8> q01 = esimd::min(esimd::max(esimd::rnde<float, 8>(f01 * inv_hi), lo127), hi127);
                    for (int j = 0; j < 8; ++j) {
                        int cA = gc + j, cB = gc + 8 + j;
                        size_t atA = (((size_t)window * heads + cA / 32) * tokens + token) * 32 + (cA % 32);
                        size_t atB = (((size_t)window * heads + cB / 32) * tokens + token) * 32 + (cB % 32);
                        V8[atA] = (signed char)(int)q00[j];
                        V8[atB] = (signed char)(int)q01[j];
                    }
                }
                if (rowB < M) {
                    float asB = a_scale[rowB];
                    int window = rowB / tokens, token = rowB % tokens;
                    esimd::simd<float, 8> f10 = esimd::convert<float>(c10.select<8, 1>(r * 8).read()) * asB * cs_lo;
                    esimd::simd<float, 8> f11 = esimd::convert<float>(c11.select<8, 1>(r * 8).read()) * asB * cs_hi;
                    esimd::simd<float, 8> q10 = esimd::min(esimd::max(esimd::rnde<float, 8>(f10 * inv_lo), lo127), hi127);
                    esimd::simd<float, 8> q11 = esimd::min(esimd::max(esimd::rnde<float, 8>(f11 * inv_hi), lo127), hi127);
                    for (int j = 0; j < 8; ++j) {
                        int cA = gc + j, cB = gc + 8 + j;
                        size_t atA = (((size_t)window * heads + cA / 32) * tokens + token) * 32 + (cA % 32);
                        size_t atB = (((size_t)window * heads + cB / 32) * tokens + token) * 32 + (cB % 32);
                        V8[atA] = (signed char)(int)q10[j];
                        V8[atB] = (signed char)(int)q11[j];
                    }
                }
            }
            // column scales: the window-first WIs (wi_row 0 and 4) write their 16+16 cols.
            if (wi_row == 0 || wi_row == 4) {
                esimd::simd<float, 16> cm16 = esimd::slm_block_load<float, 16>(
                    CMAX_BASE + (wloc * BN + wi_col * 16) * 4, esimd::overaligned_tag<16>{});
                int gwindow = wg_row * (BM / tokens) + wloc;
                for (int j = 0; j < 16; ++j)
                    v_scale[(size_t)gwindow * channels + col0 + wi_col * 16 + j] = cm16[j] / 127.0f;
            }
        });
    });
}

} // namespace s8v5
