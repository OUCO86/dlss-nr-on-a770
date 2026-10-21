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
#include "publish_kernel.hpp"   // qr_e4m3_scalar (ESIMD-safe) for the fused store
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
// batched (section 92, R8a shape-merge): `batch` INDEPENDENT groups in ONE dispatch --
// the batch is the grid's z dimension, exactly how the shipped engine does it
// (libxmx.c:2334 vkCmdDispatch(..., batch); gemm_staged.comp:115 gl_WorkGroupID.z). The
// per-group operands are contiguous (Ap at g*Mp*K, Bp at g*N*K, C32 at g*Mp*N), so the
// only change vs gemm() above is the base-pointer shift by the group stride -- the dpas
// inner loop is byte-identical, hence bit-exact by construction. This replaces the
// recorder's for(g){gemm()} host loop, which turned one big dispatch into `batch` small
// under-filled ones (the M=640 batch=8 = 8x160-thread pathology the user caught).
static inline sycl::event gemm_b(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                 int32_t* C32, int Mp, int N, int K, int batch) {
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            int32_t* c_g = C32 + (size_t)g * cb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN / 8) * 256;
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
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

// gemm32 with the batch folded into the grid (section 92, R8a): same fork discipline as
// gemm_b -- per-group contiguous operands, dpas loop byte-identical, bit-exact by
// construction. For the batched family's N=32 shapes.
static inline sycl::event gemm32_b(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                   int32_t* C32, int Mp, int N, int K, int batch) {
    const int BN32 = 32, NT32 = 16, WI_ROWS = BM / 16, WI_COLS = BN32 / 16;
    const int SLM_A32 = BM * BK, SLM_B32 = BK * BN32;
    const int SLM_B32_BASE = 2 * SLM_A32;
    const int SLM_TOTAL32 = 2 * SLM_A32 + 2 * SLM_B32;
    int wg = (Mp / BM) * (N / BN32);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT32), range(NT32)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL32>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN32;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            int32_t* c_g = C32 + (size_t)g * cb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN32 / 8) * 256;
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
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
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
// gemm_b_pub -- the fused epilogue the user ordered (section 92): the batched family's
// GEMM writes its result DIRECTLY published (dequant + e4m3 + strided store), so the
// int32 dC scratch and the separate publish kernel both disappear. The dpas main loop is
// BYTE-IDENTICAL to gemm_b above (same operands, same order) -- only the store phase
// changes -- so the accumulator values are bit-exact by construction. The publish math
// (convert<float>(acc) * row_scale * col_scale, then e4m3) uses plain ESIMD ops, which
// are the correctly-rounded hardware multiply -- the same semantics as the publish
// kernel's cr_mul (= fmul_rn), and exactly the pattern gemm_s8_v3_kernel.hpp uses in its
// fused requantize store (GEMM_S8RQ32 green). Scope: epi 0/1 (no gate activation); the
// gate polynomial needs fmul_rn (libdevice, banned in ESIMD), so epi 2/3 stay on the
// split path. The recorder picks per flags.
// gate_esimd / pub_esimd (section 92): the epi2/3 gate-activation polynomial in ESIMD-
// native ops. normalize_esimd proved plain l*r+acc == fadd_rn(fmul_rn) bit-exact in an
// ESIMD kernel (no FMA contraction there), so the gate chain is safe here -- unlike the
// SYCL publish kernel where the earlier PUBLISH RED showed contraction. The GEMM_INT8_
// BATCHED gate (which has epi3 cases) is the judge.
static inline float gate_esimd(float x) {
    // esimd::simd<float,1> ops are SEPARATE instructions (no FMA contraction).
    // bench_gate.cpp PROVED this spelling is bit-exact vs qr_gate_activation (0/4096)
    // while plain float * + is NOT (748/4096 -- the compiler contracts mul+add into an
    // FMA, skipping the product's intermediate f32 rounding that fmul_rn forces). The
    // half_round positions match the golden exactly (after each +const, and at the end).
    float wide = (float)(half)x;
    float clamped = wide < -4.0f ? -4.0f : (wide > 4.0f ? 4.0f : wide);
    float ac = clamped < 0.0f ? -clamped : clamped;   // fabs (sycl::fabs is banned in ESIMD)
    esimd::simd<float,1> L = esimd::simd<float,1>(ac) * esimd::simd<float,1>(-0.055908203125f);
    L = L + esimd::simd<float,1>(0.447265625f);
    float l0 = (float)(half)L[0];
    esimd::simd<float,1> M = esimd::simd<float,1>(l0) * esimd::simd<float,1>(clamped);
    M = M + esimd::simd<float,1>(0.89453125f);
    float l1 = (float)(half)M[0];
    esimd::simd<float,1> R = esimd::simd<float,1>(wide) * esimd::simd<float,1>(l1);
    return (float)(half)R[0];
}
static inline float pub_esimd(unsigned epi, float v) {
    if (epi == 2u || epi == 3u) v = gate_esimd(v);
    if (epi == 1u || epi == 3u) v = qr_e4m3_scalar(v);
    if (epi == 4u) v = (float)(half)v;
    return v;
}
static inline sycl::event gemm_b_pub(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     int M, int Mp, int N, int K, int batch,
                                     size_t sc, unsigned ldc, unsigned scale_stride,
                                     unsigned col_stride, bool narrow, unsigned epi) {
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN / 8) * 256;
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
            // ---- fused publish store (the ordered change): dequant + e4m3 + strided
            // write, straight from the accumulator registers. Scale pointers are the
            // group's: as + g*scale_stride (rows), bs + g*col_stride (cols; col_stride
            // is N when the plan gives per-group col scales, else 0). ----
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            const float* gas = as + (size_t)g * scale_stride;
            const float* gbs = bs + (size_t)g * col_stride;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(
                gbs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    float rs = gas[rr0];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 16> pub;
                    for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, f0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8 + e] = pub_esimd(epi, f1.read()[e]);
                    size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (rr1 < M) {
                    float rs = gas[rr1];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 16> pub;
                    for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, g0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8 + e] = pub_esimd(epi, g1.read()[e]);
                    size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}
} // namespace s8v8
