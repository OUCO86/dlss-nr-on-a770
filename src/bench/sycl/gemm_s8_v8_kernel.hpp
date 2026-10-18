// gemm_s8_v8_kernel.hpp -- the FIRST kernel of the swap-in campaign (section 71, the
// user's approved two-pass plan: GEMM -> int32 temp, then a gated elementwise
// publish -> f16). v1's PROVEN main loop stays byte-identical; the two things that
// change are host-side packing only:
//
//   pack_b_v8: the game's B arrives TRANSPOSED -- libxmx.c:2877 "B the weights stored
//   transposed, int8 N x K" -- while v1's pack_b reads row-major K x N. This variant
//   reads (n,k) = B[n*K + k] and emits the identical packed layout, so the kernel's
//   inner loop is untouched. Same dpas operand order as v1's pack_b (the packed word
//   layout is byte-for-byte the target: pack_b writes B[(kk32*32+kq*4+j)*N + ...],
//   ours writes B[(ntile*8+nl)*K + (kk32*32+kq*4+j)] -- the transpose, nothing else).
//
//   pad_m: M=192 (the second plan family, section 71) is not a multiple of BM=128 and
//   the main loop indexes the row grid in whole blocks. We PAD the activation to a
//   whole 128-block (zero rows produce garbage rows we never publish) instead of
//   adding a guard to the proven inner loop: the kernel file stays a verbatim fork.
//   The publish step (a separate pass) reads only rows < M.
//
// Shapes: M padded to 128k, N %64==0, K %32==0. C32 is (Mp x N) int32.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstring>

namespace s8v8 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 64, BK = 32, NT = 32;
static const int SLM_A = BM * BK;
static const int SLM_B = BK * BN;
static const int SLM_B_BASE = 2 * SLM_A;
static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;

// A: M x K row-major (only the first M rows meaningful; the caller zero-padded the
// host copy to Mp rows). Same map as v1's pack_a evaluated on the PADDED matrix.
static inline void pack_a(const int8_t* A, int8_t* Ap, int Mp, int K) {
    int wgr = Mp / BM, kb_n = K / BK;
    for (int w = 0; w < wgr; ++w)
        for (int kb = 0; kb < kb_n; ++kb)
            for (int wi = 0; wi < 8; ++wi)
                for (int row = 0; row < 16; ++row)
                    for (int k = 0; k < 32; ++k)
                        Ap[(((size_t)(w * kb_n + kb) * 8 + wi) * 512) + row * 32 + k] =
                            A[(size_t)(w * BM + wi * 16 + row) * K + kb * BK + k];
}
// B TRANSPOSED: N x K row-major -- emit v1's packed layout exactly.
static inline void pack_b(const int8_t* B, int8_t* Bp, int N, int K) {
    for (int kk32 = 0; kk32 < K / 32; ++kk32)
        for (int ntile = 0; ntile < N / 8; ++ntile)
            for (int kq = 0; kq < 8; ++kq)
                for (int nl = 0; nl < 8; ++nl)
                    for (int j = 0; j < 4; ++j)
                        Bp[(((size_t)kk32 * (N / 8) + ntile) * 64 + kq * 8 + nl) * 4 + j] =
                            B[(size_t)(ntile * 8 + nl) * K + (kk32 * 32 + kq * 4 + j)];
}

// the launch: v1's gemm_s8 verbatim (Mp = padded M, N %64, K %32). C32 = Mp x N int32.
static inline sycl::event gemm(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                               int32_t* C32, int Mp, int N, int K) {
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
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
            int kb_n = K / BK;
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
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<int32_t, 16> row0;
                row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                esimd::simd<int32_t, 16> row1;
                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}


// --- BN=32 variant for the batched family's N=32 column blocks (section 73): the v7
// loop geometry VERBATIM (WI 8x2, NT=16, 256B A loads, 64B B loads), with v7's FUSED
// requantize epilogue replaced by the raw int32 store of v1 (the two-pass plan, section
// 71). pack_b32 == v7's pack_b read on the TRANSPOSED (N x K) form, matching pack_b here.
static inline void pack_b32(const int8_t* B, int8_t* Bp, int N, int K) {
    // identical map to pack_b -- it already takes N as a parameter (N/8=4 tiles at 32).
    pack_b(B, Bp, N, K);
}
static inline sycl::event gemm32(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                 int32_t* C32, int Mp, int N, int K) {
    const int BN32 = 32, NT32 = 16, WI_ROWS = BM / 16, WI_COLS = BN32 / 16;
    const int SLM_A32 = BM * BK, SLM_B32 = BK * BN32;
    const int SLM_B32_BASE = 2 * SLM_A32;
    const int SLM_TOTAL32 = 2 * SLM_A32 + 2 * SLM_B32;
    int wg = (Mp / BM) * (N / BN32);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT32), range(NT32)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL32>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN32;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN32 / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> av = esimd::block_load<int8_t, 256>(
                    apb + (size_t)kb * SLM_A32 + lid * 256, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A32 + lid * 256, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM_B32_BASE + buf * SLM_B32 + lid * 64, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A32 + wi_row * 512;
                uint32_t offB = SLM_B32_BASE + buf * SLM_B32 + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            esimd::barrier();
            int kb_n = K / BK;
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
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN32 + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<int32_t, 16> row0;
                row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                esimd::simd<int32_t, 16> row1;
                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}
} // namespace s8v8
