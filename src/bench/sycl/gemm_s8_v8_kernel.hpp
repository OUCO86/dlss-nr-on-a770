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
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer (10-31: the proven depth-2 form, this file's remaining double-buffer cores)
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
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
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer
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
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
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
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    const int BN32 = 32, NT32 = 16, WI_ROWS = BM / 16, WI_COLS = BN32 / 16;
    const int SLM_A32 = BM * BK, SLM_B32 = BK * BN32;
    const int SLM_B32_BASE = 2 * SLM_A32;
    const int SLM_TOTAL32 = 2 * SLM_A32 + 2 * SLM_B32;
    int wg = (Mp / BM) * (N / BN32);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K, cb = (size_t)Mp * N;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT32), range(NT32)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A32 + 3 * SLM_B32>();   // s8d2 three-buffer
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
            const int SLM_B32_BASE3 = 3 * SLM_A32;   // s8d2: third buffer slot
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> av = esimd::block_load<int8_t, 256>(
                    apb + (size_t)kb * SLM_A32 + lid * 256, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A32 + lid * 256, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM_B32_BASE3 + buf * SLM_B32 + lid * 64, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A32 + wi_row * 512;
                uint32_t offB = SLM_B32_BASE3 + buf * SLM_B32 + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
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
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    const int BN32 = 32, NT32 = 16, WI_ROWS = BM / 16, WI_COLS = BN32 / 16;
    const int SLM_A32 = BM * BK, SLM_B32 = BK * BN32;
    const int SLM_B32_BASE = 2 * SLM_A32;
    const int SLM_TOTAL32 = 2 * SLM_A32 + 2 * SLM_B32;
    int wg = (Mp / BM) * (N / BN32);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT32), range(NT32)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A32 + 3 * SLM_B32>();   // s8d2 three-buffer
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN32;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN32 / 8) * 256;
            const int SLM_B32_BASE3 = 3 * SLM_A32;   // s8d2: third buffer slot
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> av = esimd::block_load<int8_t, 256>(
                    apb + (size_t)kb * SLM_A32 + lid * 256, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A32 + lid * 256, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM_B32_BASE3 + buf * SLM_B32 + lid * 64, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A32 + wi_row * 512;
                uint32_t offB = SLM_B32_BASE3 + buf * SLM_B32 + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
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
// ---- section 99 (RE-APPLIED, grep-verified): VECTORIZED publish for the fused stores.
// bench_pubvec A/B: epi 0/1/3/4 scalar-vs-vector IDENTICAL over 1M values; epi2 differs
// only on -0.0 sign (kept on the scalar path). e4m3_vec = the wbv2 proven block
// (bench_e4m3vec 0/4096); gate chain = gate_esimd's statement structure on 8 lanes
// (simd ops are separate instructions, no FMA contraction -- §92). gemm_b_pub only:
// gemm_b_res's scalar sk*c+f CONTRACTIONS are golden semantics (the earlier vector
// res form broke the frame 0% -- do NOT vectorize res's fma). ----
template <int N>
static inline esimd::simd<float,N> e4m3_vec_v8(esimd::simd<float,N> x){
    esimd::simd<float,N> mag = esimd::abs(x);
    mag = (esimd::min)(mag, esimd::simd<float,N>(448.0f));
    esimd::simd<int32_t,N> mb; mb = mag.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> exp = (mb >> 23) & esimd::simd<int32_t,N>(0xFF);
    exp = (esimd::max)(exp, esimd::simd<int32_t,N>(121)) - 3;
    esimd::simd<int32_t,N> sb = exp << 23; esimd::simd<float,N> step; step = sb.template bit_cast_view<float>();
    esimd::simd<int32_t,N> rb = (esimd::simd<int32_t,N>(254) - exp) << 23; esimd::simd<float,N> recip; recip = rb.template bit_cast_view<float>();
    esimd::simd<float,N> t = mag * recip;
    esimd::simd<float,N> r = esimd::rnde<float>(t) * step;
    esimd::simd<int32_t,N> ri; ri = r.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> negm = x < esimd::simd<float,N>(0.0f);
    esimd::simd<int32_t,N> out = (ri & esimd::simd<int32_t,N>(0x7FFFFFFF)) | (negm << 31);
    esimd::simd<float,N> res; res = out.template bit_cast_view<float>();
    return res;
}
template <int N>
static inline esimd::simd<float,N> gate_vec_v8(esimd::simd<float,N> x) {
    esimd::simd<float,N> wide = esimd::convert<float>(esimd::convert<half>(x));
    esimd::simd<float,N> clamped = (esimd::min)((esimd::max)(wide, esimd::simd<float,N>(-4.0f)), esimd::simd<float,N>(4.0f));
    esimd::simd<float,N> ac = esimd::abs(clamped);
    esimd::simd<float,N> L = ac * esimd::simd<float,N>(-0.055908203125f);
    L = L + esimd::simd<float,N>(0.447265625f);
    esimd::simd<float,N> l0 = esimd::convert<float>(esimd::convert<half>(L));
    esimd::simd<float,N> M = l0 * clamped;
    M = M + esimd::simd<float,N>(0.89453125f);
    esimd::simd<float,N> l1 = esimd::convert<float>(esimd::convert<half>(M));
    esimd::simd<float,N> R = wide * l1;
    esimd::simd<float,N> res = esimd::convert<float>(esimd::convert<half>(R));
    // BLADE-6 (cross-validation census 19:4x, the user's "still meat" call was RIGHT):
    // the frame's gemm-f16 family has 32 epi=2 (gate) calls -- the "cold" scalar
    // branch is HOT (15-30 instrs/element x 128 elements/thread). bench_pubvec's
    // 1M-value A/B localized the ONLY vector-vs-scalar epi2 difference to the -0.0
    // SIGN (the scalar clamp ternaries take the else-path for -0.0; hw min/max fold
    // it to +0.0). Sign-preserving tail: where x == 0, force the ZERO WITH X'S SIGN
    // (2 wide ops, branchless) => bit-identical to the scalar form BY CONSTRUCTION
    // over the whole bench sweep. The GEMM_F16 gate (it has epi2 cases) + end-to-end
    // 1301 are the judges.
    esimd::simd<uint32_t,N> xb = x.template bit_cast_view<uint32_t>();
    esimd::simd<bool,N> isz = (xb & esimd::simd<uint32_t,N>(0x7FFFFFFFu)) == esimd::simd<uint32_t,N>(0u);
    esimd::simd<uint32_t,N> zb = esimd::simd<uint32_t,N>(isz);   // all-ones mask where x == +-0.0
    esimd::simd<uint32_t,N> signedzero = (xb & esimd::simd<uint32_t,N>(0x80000000u));  // -0.0 bits when x<0, +0.0 otherwise
    esimd::simd<uint32_t,N> rb; rb = res.template bit_cast_view<uint32_t>();
    rb = (rb & ~zb) | (signedzero & zb);
    esimd::simd<float,N> out; out = rb.template bit_cast_view<float>();
    return out;
}
template <int N>
static inline esimd::simd<float,N> pub_vec_v8(unsigned epi, esimd::simd<float,N> v) {
    if (epi == 2u || epi == 3u) v = gate_vec_v8<N>(v);
    if (epi == 1u || epi == 3u) v = e4m3_vec_v8<N>(v);
    if (epi == 4u) v = esimd::convert<float>(esimd::convert<half>(v));
    return v;
}
static inline sycl::event gemm_b_pub(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     int M, int Mp, int N, int K, int batch,
                                     size_t sc, unsigned ldc, unsigned scale_stride,
                                     unsigned col_stride, bool narrow, unsigned epi) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer
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
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
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
                    esimd::simd<int32_t, 16> acc(0);
                    acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                    esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                    size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (rr1 < M) {
                    float rs = gas[rr1];
                    esimd::simd<int32_t, 16> acc(0);
                    acc.template select<8,1>(0) = c10.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c11.template select<8,1>(r*8);
                    esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                    size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}

// gemm32_b_pub -- KNIFE C (2026-11-01): the fused-publish twin of gemm32_b for the
// batched family's N=32 sites. plan_960x544.c captured graph (the region xmx_graph_run
// replays, lines 5308..6643) contains xmx_rec_gemm_int8_batched with M=32640 N=32 K=128
// batch=2 EIGHT times (5345/5369/5391/5413/6541/6563/6585/6607) and M=8160 N=32 K=128
// batch=4 TWELVE times (5438/5460/5482/5504/5526/5548/6407/6429/6451/6473/6495/6517).
// The split branch they WOULD take is gemm32_b (raw int32, :2700) + a SEPARATE scalar
// publish parallel_for (:2702-2716) -- see FRAME REACHABILITY at the bottom of this comment:
// on the frame those 20 calls are already folded by P8-b wide-merge and never get here.
// Measured at the frame's OWN strides (lda=K*batch,
// sa=K, sb=N*K, sc=N, ldc=N*batch, col_stride=N, epi1, narrow), 8 processes pooled, 5
// groups x 15 reps with a 60 ms gap, msM = median of the group-mins:
//     M=32640: gemm32_b 0.0930 + publish 0.3928 = 0.4858  (publish = 31.9 GB/s = 5.7% of
//              the 560 GB/s roof -- 4.2x the GEMM it follows)
//     M=8160 : gemm32_b 0.0701 + publish 0.2056 = 0.2756  (publish = 30.5 GB/s = 5.4%)
// this kernel (bench): 0.0701 / 0.0447 ms per call TOTAL. That -6.05 ms/frame is a SERIAL
// bench number for a path the frame does not execute -- it books ZERO to the frame (see
// FRAME REACHABILITY below and the 16-pair A/B in the takeover notes). Numbers + protocol:
// src/bench/sycl/gemm32_tile_run.txt (STEP 0 section).
// GEOMETRY is moved VERBATIM out of src/bench/sycl/gemm32_tile.cpp, where it is
// g32v::gemm32_var<32,32,32,2,1,true> (BN32 / BK32 / NT32 threads-per-WG / 2 SLM buffers
// per operand / thread tile 8 rows x 16 cols / fused publish) -- that file diffs this
// exact code path byte-for-byte against shipped gemm32_b on the raw leg and against the
// recorder's publish map on this leg (diff = 0 over 2088960 / 1044480 elements).
// WHY this geometry: at N=32 the shipped NT16 map (16 threads/WG, 16 rows x 16 cols per
// thread) leaves only (Mp/128)*batch workgroups -- on the M=8160 site that is 256 WGs and
// the machine is under-filled; NT32 (thread tile 8x16, 2 accumulator
// fragments instead of 4) doubles the WGs and halves the live accumulator set: -49.5% on
// M=8160 and neutral-or-better on M=32640. Depth-2 buffers (10KB SLM, prefetch depth 1)
// beat the shipped s8d2 triple buffer (15KB) on both. JIT-cache ledger for this shape:
// grf_count=128, spill=private=scratch=0, 0 scratch instructions, slm_size 10240 exactly.
// The publish math is gemm_b_pub's chain VERBATIM (convert<float>(acc) * rs * cs, then
// pub_vec_v8<16>): epi 0/1/3/4 only, same gate/contraction caveat as gemm_b_pub's comment
// (:345-355) -- epi2/3 stay on the split path unless gemm_b_pub itself allows them.
// GATE: the recorder picks this kernel only when NR_G32_PUB != 0 (default OFF); NR_G32_PUB=0
// reverts to gemm32_b + publish.
// FRAME REACHABILITY (measured with a closure-level probe print in a rebuilt dll, then
// removed -- 2026-11-01): the 20 N=32 batched calls in the captured graph DO NOT reach this
// kernel or the split path either. libxmx_sycl.cpp:2478-2503 (P8-b wide-merge, DEFAULT ON,
// escape NR_B_WIDE=0) already folds them into ONE wide gemm_b_pub (Nw=N*batch, Kw=K*batch,
// block-diagonal B, fused publish) and returns; substituting every plan tuple into wide_ok
// gives 20/20 caught, 0 missed. So gemm32_b + separate publish is DEAD CODE on the frame
// (reachable only under NR_B_WIDE=0), and THIS kernel is its fused twin: it is kept as (a)
// the correct form of the NR_B_WIDE=0 escape path and (b) an S6 brick -- the BN32 geometry
// previously had no pub twin at all, and block-resident stages need BN32 + fused store.
// NO frame saving may be booked to this kernel; the prices above are bench-layer only.
static inline sycl::event gemm32_b_pub(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                       void* Cout, const float* as, const float* bs,
                                       int M, int Mp, int N, int K, int batch,
                                       size_t sc, unsigned ldc, unsigned scale_stride,
                                       unsigned col_stride, bool narrow, unsigned epi) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    const int BN32 = 32, NT32P = 32, ROW_BANDS = BM / 8, COL_BANDS = BN32 / 16;
    const int SLM_A32 = BM * BK, SLM_B32 = BK * BN32;      // 4096 / 1024 bytes per buffer
    const int A_PER = SLM_A32 / NT32P;                    // 128 B of A per thread
    const int B_PER = SLM_B32 / NT32P;                    //  32 B of B per thread
    const int SLM_B32_BASE = 2 * SLM_A32;                 // the two B buffers follow the A
    int wg = (Mp / BM) * (N / BN32);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT32P), range(NT32P)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<2 * SLM_A32 + 2 * SLM_B32>();   // depth-1 double buffer, 10KB
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN32;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / COL_BANDS, wi_col = lid % COL_BANDS;
            // the A pack band is 16 rows; this thread owns HALF of one (8 rows).
            int packwi = wi_row / 2, subrow = (wi_row % 2) * 8;
            const int8_t* apb_g = Ap + (size_t)g * apb;
            const int8_t* bp_g  = Bp + (size_t)g * bpb;
            const int8_t* apb = apb_g + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN32 / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, A_PER> av = esimd::block_load<int8_t, A_PER>(
                    apb + (size_t)kb * SLM_A32 + lid * A_PER, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A32 + lid * A_PER, av, esimd::overaligned_tag<16>{});
                esimd::simd<int8_t, B_PER> bv = esimd::block_load<int8_t, B_PER>(
                    bp + (size_t)kb * N * 32 + lid * B_PER, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(SLM_B32_BASE + buf * SLM_B32 + lid * B_PER, bv, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0);
            int kb_n = K / BK;
            load_block(0, 0);                              // prologue: depth 1
            esimd::barrier();
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 2;
                if (b + 1 < kb_n) load_block((b + 1) % 2, b + 1);
                uint32_t offA = (uint32_t)(cur * SLM_A32) + (uint32_t)(packwi * 512)
                              + (uint32_t)(subrow * 32);
                uint32_t offB = SLM_B32_BASE + (uint32_t)(cur * SLM_B32)
                              + (uint32_t)(wi_col * 512);
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                esimd::barrier();
            }
            // ---- fused publish store, the gemm_b_pub tail VERBATIM (gemm_b_pub:505-522),
            // minus the second row group (this thread tile is 8 rows, not 16). ----
            int gr = wg_row * BM + wi_row * 8, gc = wg_col * BN32 + wi_col * 16;
            const float* gas = as + (size_t)g * scale_stride;
            const float* gbs = bs + (size_t)g * col_stride;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(
                gbs + gc, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r;
                if (rr0 < M) {
                    float rs = gas[rr0];
                    esimd::simd<int32_t, 16> acc(0);
                    acc.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                    acc.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                    esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                    size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}

// gemm_b_pub_slm -- section 100 §99-item-3: the acc-via-SLM publish tail (the senior's
// pattern, gemm_staged.comp:309-322 -- "the publish happens on scalars, after an
// UNTOUCHED STORE TO SHARED MEMORY"). bench_batched's honest split: gemm_b (raw int32
// store) 0.096-0.142ms but gemm_b_pub 0.112-0.244 -- the PUBLISH TAIL costs more than
// the dpas body: c00..c11 (4 x simd<int32,64> = 256 int32/thread) stay live through
// the whole tail (GRF pressure -> spill) and every row is re-assembled from two
// select<8,1> slices (register shuffles). The senior's cure, translated: after the
// loop the accumulators go WHOLE into the operand SLM the last load_grf already killed
// (C-stage aliases SLM_A/SLM_B: the tile is BM x BN int32 = 32KB, the allocation is
// 2*SLM_A + 2*SLM_B = 45056B), one barrier, then each thread reads back CONTIGUOUS
// 16-wide rows (one LDS, zero assembly) and runs the pub_vec_v8 chain VERBATIM (bit-
// exact by construction -- same ops, same order as the green gemm_b_pub tail) with a
// 32B contiguous global store. Accumulators die at the SLM store -> the tail's live
// set drops. HALF=1 stages only the tile's LOW half (16KB) and keeps the proven
// register tail for the high half -- the occupancy probe (the v9c lesson: SLM size
// costs WG/SM; bench decides which wins). The stage map is the exact inverse of the
// read map: thread (wi_row,wi_col) owns tile rows wi_row*16+{0..15}, cols
// wi_col*16+{0..15}; fragment c0q row r = cols wi_col*16 + q*8.. (matches the dpas
// layout the green tail already assembles from).
template <bool HALF>
static inline sycl::event gemm_b_pub_slm(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     int M, int Mp, int N, int K, int batch,
                                     size_t sc, unsigned ldc, unsigned scale_stride,
                                     unsigned col_stride, bool narrow, unsigned epi) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    // the tile's int32 C-stage in BYTES. Full = the tile layout, BM*BN*4 = 32768.
    // HALF = a COMPACT per-thread block: thread (wi_row,wi_col) stages only its low
    // 8 rows x 16 cols at (wi_row*4+wi_col)*128 + r*16 + {0..15} -- 32 threads x 128
    // int32 = 16KB total (the row-index space of the full map would still reach
    // 30.5KB; the compact map is what makes the occupancy probe real). Both overlap the 12KB
    // operand region -- legal, operands are dead after the loop's final barrier.
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<HALF ? 18432 : 32768>();   // s8d2: operands 18KB; the HALF compact stage (16KB) aliases the dead operand region after the loop's final barrier
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
            // the untouched store: accumulators -> the dead operand SLM (alias base 0).
            // FULL: the tile's own layout -- thread (wi_row,wi_col) owns rows
            // wi_row*16+{0..15}, cols wi_col*16+{0..15}; 8-lane fragments at the dpas
            // positions, byte offsets = element*4 (the §36 rule; 32B/64B fragments,
            // tag<16>). HALF: a COMPACT block -- thread's low 8 rows x 16 cols at
            // (wi_row*4+wi_col)*128 + r*16 + {0..15}, so the stage region is 16KB.
            if (!HALF) {
                for (int r = 0; r < 8; ++r) {
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 16 + r) * BN + wi_col * 16) * 4u,
                        c00.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 16 + r) * BN + wi_col * 16 + 8) * 4u,
                        c01.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 16 + 8 + r) * BN + wi_col * 16) * 4u,
                        c10.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 16 + 8 + r) * BN + wi_col * 16 + 8) * 4u,
                        c11.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                }
            } else {
                for (int r = 0; r < 8; ++r) {
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 4 + wi_col) * 128 + r * 16) * 4u,
                        c00.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<int32_t, 8>((uint32_t)((wi_row * 4 + wi_col) * 128 + r * 16 + 8) * 4u,
                        c01.template select<8,1>(r * 8), esimd::overaligned_tag<16>{});
                }
            }
            // NO barrier here (unlike the senior's :323): the stage map is
            // THREAD-LOCAL -- 8 wi_row x 4 wi_col = 32 disjoint 16x16 blocks cover the
            // 128x64 tile and every thread reads back exactly what it wrote. The SLM
            // detour's whole job here is killing the accumulator live-set (GRF spill),
            // not exchanging data; the cross-thread barriers inside the K loop stay.
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            const float* gas = as + (size_t)g * scale_stride;
            const float* gbs = bs + (size_t)g * col_stride;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(
                gbs + gc, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r;
                if (rr0 < M) {
                    float rs = gas[rr0];
                    uint32_t roff = HALF
                        ? (uint32_t)((wi_row * 4 + wi_col) * 128 + r * 16) * 4u
                        : (uint32_t)((wi_row * 16 + r) * BN + wi_col * 16) * 4u;
                    esimd::simd<int32_t, 16> acc = esimd::slm_block_load<int32_t, 16>(
                        roff, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                    size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (HALF) continue;
                int rr1 = gr + 8 + r;
                if (rr1 < M) {
                    float rs = gas[rr1];
                    esimd::simd<int32_t, 16> acc = esimd::slm_block_load<int32_t, 16>(
                        (uint32_t)((wi_row * 16 + 8 + r) * BN + wi_col * 16) * 4u, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                    size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
            if (HALF) {   // the high half keeps the proven register tail (c10/c11 live)
                for (int r = 0; r < 8; ++r) {
                    int rr1 = gr + 8 + r;
                    if (rr1 < M) {
                        float rs = gas[rr1];
                        esimd::simd<int32_t, 16> acc(0);
                        acc.template select<8,1>(0) = c10.template select<8,1>(r*8);
                        acc.template select<8,1>(8) = c11.template select<8,1>(r*8);
                        esimd::simd<float, 16> pub = pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                        size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                        if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                        else        pub.copy_to((float*)Cout + out);
                    }
                }
            }
        });
    });
}

// gemm_b_res -- the int8_residual fused store (section 92, same lever as gemm_b_pub).
// The residual epilogue is stage=deq(acc)*as[r]*bs[col]; total=fma(skip[i],cos[col],stage);
// publish(epi). The engine uses sycl::fma = ONE fused rounding; in an ESIMD kernel the
// plain sk*cp+stage auto-contracts to an FMA (the gate_esimd lesson, used correctly here),
// so the semantics match. skip is per-element (M x N, half or float), cos is per-column (N).
// dpas main loop byte-identical to gemm_b/gemm_b_pub. GEMM_INT8_RESIDUAL gate is the judge.
// RES8-ALL (10-31, the user's "牺牲画质不顾一切" blade): residual planes stored as
// row-scale E4M3 BYTES. plane bytes = M*N (1B/elem) + M row-scales (f32, pow2 so the
// decode is an exponent add and the encode a pow2 divide -- the lmxx residual form:
// "residual scale f32[] + E4M3 bytes"). N==BN==64 -> the WHOLE row lives in one WG:
// partial absmax per thread (its 16 cols x 2 rows) -> SLM [BM][4] f32 -> ONE barrier
// -> row peak -> scale = 2^ceil(log2(peak/448)) -> v*recip(s) -> e4m3 grid snap
// (e4m3_vec on the scaled value) -> pack 4 codes/word -> 64B store. The f16 path
// stays verbatim under RES8=false (NR_RES8=0 escape, bit-exact old chain).
// skip-decode (RES8SKIP): 64B byte load -> bit-trick e4m3->f32 (lmxx's composite:
// mantissa<<20 | (e+120)<<23, subnormal band folded) -> *row scale -> f32.
template <int N>
static inline esimd::simd<float, N> res8_decode(const int8_t* p, float s) {
    esimd::simd<int8_t, N> b8 = esimd::block_load<int8_t, N>(p, esimd::overaligned_tag<16>{});
    esimd::simd<uint32_t, N> b = esimd::convert<uint32_t>(b8) & 255u;
    esimd::simd<uint32_t, N> sgn = (b >> 7) << 31;
    esimd::simd<uint32_t, N> e = (b >> 3) & 15u, m = b & 7u;
    esimd::simd<uint32_t, N> isn = (e != 0u);                       // 1 normal / 0 subnormal
    esimd::simd<uint32_t, N> nb = ((e + 120u) << 23) | (m << 20);
    esimd::simd<uint32_t, N> sb = m << 14;                          // m * 2^-9 as f32 bits
    esimd::simd<uint32_t, N> fb = (nb * isn) | (sb * (1u - isn));
    esimd::simd<uint32_t, N> signedv = fb | sgn;
    esimd::simd<float, N> v = signedv.template bit_cast_view<float>();
    return v * esimd::simd<float, N>(s);
}
// encode: a value ALREADY snapped to the e4m3 grid (e4m3_vec_v8 output) -> byte code.
template <int N>
static inline esimd::simd<int8_t, N> res8_encode(esimd::simd<float, N> g) {
    esimd::simd<int32_t, N> b = g.template bit_cast_view<int32_t>();
    esimd::simd<int32_t, N> eb = (b >> 23) & 255, mb = (b >> 20) & 7;
    esimd::simd<int32_t, N> sgn = (b >> 31) << 7;
    esimd::simd<int32_t, N> isn = (eb >= 121);                      // 1 normal band
    esimd::simd<int32_t, N> norm = ((eb - 120) << 3) | mb;
    esimd::simd<float, N> ag = esimd::abs(g);
    esimd::simd<int32_t, N> sub = esimd::convert<int32_t>(esimd::rnde<float>(ag * esimd::simd<float, N>(512.f)));
    esimd::simd<int32_t, N> code = (norm * isn) | (sub * (1 - isn));
    return esimd::convert<int8_t>((code | sgn) & 255);
}
static inline sycl::event gemm_b_res(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     const void* skip, const float* cos,
                                     int M, int Mp, int N, int K,
                                     bool narrow, bool half_skip, unsigned epi) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer
            int loc = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    float rs = as[rr0];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    // fma: sk*cos + stage (one fused rounding, matches sycl::fma).
                    // BLADE-4 (ISA density ledger 2026-10-29): the pub chain here ran
                    // 128 SCALAR pub_esimd calls/thread (~1800 instrs) vs 8 dpas = the
                    // 0.1% density the census counted. The fma expression stays
                    // ELEMENTWISE byte-identical (the "do NOT vectorize res's fma"
                    // warning: a simd sk*c+f lowers as muladd = two roundings, frame 0%);
                    // only the PUB step is vectorized via pub_vec_v8 (bench_pubvec: epi
                    // 0/1/3/4 scalar-vs-vec IDENTICAL over 1M values; the frame's res
                    // flags 0x41100 -> epi=1; epi==2 keeps the scalar -0.0 path).
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + f0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + f1.read()[e]);
                    }
                    size_t out = (size_t)rr0 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (rr1 < M) {
                    float rs = as[rr1];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + g0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + g1.read()[e]);
                    }
                    size_t out = (size_t)rr1 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}

// ---- KNIFE1-BMERGE twin: batched gemm_b_res (knife 1 A3). Per-group faces come from a device descriptor
// // table, so the merged groups need NOT be contiguous. The kernel body below is the shipped
// // gemm_b_res body VERBATIM (generated copy: same ops, same order, same epilogue) -- only the
// // group index and the pointer sources differ. NR_BMERGE=0 never reaches this entry point.
struct S8ResDesc { const int8_t* A; const int8_t* B; void* C;
                 const float* as; const float* bs; const void* skip; const float* cos; };
static inline sycl::event gemm_b_res_batch(sycl::queue& q, const S8ResDesc* desc,
                                           int M, int Mp, int N, int K, int batch,
                                           bool narrow, bool half_skip, unsigned epi) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer
            int gid = (int)it.get_group(0);
            int g = gid / wg; int loc = gid % wg;
            int lid = (int)it.get_local_id(0);
            const S8ResDesc d = desc[g];
            const int8_t* Ap = d.A; const int8_t* Bp = d.B; void* Cout = d.C;
            const float* as = d.as; const float* bs = d.bs;
            const void* skip = d.skip; const float* cos = d.cos;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    float rs = as[rr0];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    // fma: sk*cos + stage (one fused rounding, matches sycl::fma).
                    // BLADE-4 (ISA density ledger 2026-10-29): the pub chain here ran
                    // 128 SCALAR pub_esimd calls/thread (~1800 instrs) vs 8 dpas = the
                    // 0.1% density the census counted. The fma expression stays
                    // ELEMENTWISE byte-identical (the "do NOT vectorize res's fma"
                    // warning: a simd sk*c+f lowers as muladd = two roundings, frame 0%);
                    // only the PUB step is vectorized via pub_vec_v8 (bench_pubvec: epi
                    // 0/1/3/4 scalar-vs-vec IDENTICAL over 1M values; the frame's res
                    // flags 0x41100 -> epi=1; epi==2 keeps the scalar -0.0 path).
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + f0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + f1.read()[e]);
                    }
                    size_t out = (size_t)rr0 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (rr1 < M) {
                    float rs = as[rr1];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + g0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + g1.read()[e]);
                    }
                    size_t out = (size_t)rr1 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}

// gemm_b_res8 -- RES8-ALL writer leg (10-31, the quality-sacrifice blade the user
// ordered ON the 71-layer model): same proven main loop as gemm_b_res, but the
// epilogue stages the pub tile to SLM (the pub_slm pattern; the 32KB tile aliases
// the dead operand region after the loop's final barrier), ONE barrier, then each
// thread reads its 16 rows' FULL 64-wide row from SLM, computes the row absmax,
// picks the pow2 scale s = 2^ceil(log2(peak/448)) (peak/s in [224,448]), snaps
// v/s to the e4m3 grid (e4m3_vec_v8 = the shipped chain) and writes 16 BYTES at
// (row*N + gc) + the row scale (wi_col==0 writes scales[row]). DRAM per call:
// M*N f16 (131KB) -> M*N bytes + M*4 scales (67.6KB) = HALF. Buffer allocation
// UNCHANGED (the plan's 66.8MB stays; the kernels just touch half of it).
// Readers switch to res8_decode (window-resid skip / QUANT_WINDOW gather / FFN
// skip / plain QUANT) -- paired atomically per plane by the NR_RES8 recorder gate.
static inline sycl::event gemm_b_res8(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                      int8_t* Cout8, float* rowScales,
                                      const float* as, const float* bs,
                                      const int8_t* skip8, const float* skipScales,
                                      const float* cos,
                                      int M, int Mp, int N, int K) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<32768>();   // the 128x64 f32 tile (32KB) aliases the 18KB operand region post-barrier (the pub_slm pattern)
            int loc = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;
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
            if (K / BK > 1) load_block(1, 1);
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            // ---- RES8 epilogue part 1: deq + skip-decode + fma + e4m3 publish ->
            // the f32 tile in SLM (the pub_slm map VERBATIM: thread (wi_row,wi_col)
            // owns rows wi_row*16+{0..15} x cols wi_col*16+{0..15}).
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    float rs = as[rr0];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    float sks = skipScales[rr0];
                    esimd::simd<float,16> skk = res8_decode<16>(skip8 + (size_t)rr0*N + gc, sks);
                    esimd::simd<float, 8> sk0 = skk.template select<8,1>(0), sk1 = skk.template select<8,1>(8);
                    esimd::simd<float,8> t0, t1;
                    for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                    esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                    esimd::simd<float,16> pub = pub_vec_v8<16>(1u, tt);
                    esimd::slm_block_store<uint32_t,8>(uint32_t(((wi_row*16 + r) * BN + gc % BN)) * 4u, pub.template select<8,1>(0).template bit_cast_view<uint32_t>(), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<uint32_t,8>(uint32_t(((wi_row*16 + r) * BN + gc % BN + 8)) * 4u, pub.template select<8,1>(8).template bit_cast_view<uint32_t>(), esimd::overaligned_tag<16>{});
                }
                if (rr1 < M) {
                    float rs = as[rr1];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    float sks = skipScales[rr1];
                    esimd::simd<float,16> skk = res8_decode<16>(skip8 + (size_t)rr1*N + gc, sks);
                    esimd::simd<float, 8> sk0 = skk.template select<8,1>(0), sk1 = skk.template select<8,1>(8);
                    esimd::simd<float,8> t0, t1;
                    for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                    esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                    esimd::simd<float,16> pub = pub_vec_v8<16>(1u, tt);
                    esimd::slm_block_store<uint32_t,8>(uint32_t(((wi_row*16 + 8 + r) * BN + gc % BN)) * 4u, pub.template select<8,1>(0).template bit_cast_view<uint32_t>(), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<uint32_t,8>(uint32_t(((wi_row*16 + 8 + r) * BN + gc % BN + 8)) * 4u, pub.template select<8,1>(8).template bit_cast_view<uint32_t>(), esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();
            // ---- part 2: the 128 tile rows over all 32 threads (4/thread, NO
            // wi_col redundancy -- the 4x-encode was the 0.5x bug). slm offsets
            // are BYTES (the §36 rule): row*BN*4.
            #pragma unroll 1
            for (int rr = 0; rr < 4; ++rr) {
                int row = lid * 4 + rr;                    // tile-local row
                int grow = wg_row * BM + row;
                if (grow >= M) break;
                esimd::simd<float, 64> v = esimd::slm_block_load<float, 64>(uint32_t(row * BN) * 4u, esimd::overaligned_tag<16>{});
                float peak = esimd::hmax<float,float,64>(esimd::abs(v));
                if (peak > 0.f) {
                    // s = 2^ceil(log2(peak/448)); scalar bit-reinterp via memcpy (the
                    // 1-wide SIMD bit_cast_view is not instantiable -- named-temp rule)
                    float r0 = esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(448.f))[0];
                    int32_t rb; __builtin_memcpy(&rb, &r0, 4);
                    int32_t le = ((rb >> 23) & 255) - 127;         // floor(log2(r0))
                    uint32_t man = (uint32_t)rb & 0x7FFFFFu;
                    int32_t k = le + (man ? 1 : 0);                // ceil(log2(r0))
                    uint32_t sbits = (uint32_t)(k + 127) << 23;    // 2^k (k in [-126,126])
                    float s; __builtin_memcpy(&s, &sbits, 4);
                    rowScales[grow] = s;
                    esimd::simd<float,64> g = e4m3_vec_v8<64>(v * esimd::div_ieee<float,64>(esimd::simd<float,64>(1.f), esimd::simd<float,64>(s)));
                    esimd::block_store<int8_t,64>(Cout8 + (size_t)grow*N, res8_encode<64>(g), esimd::overaligned_tag<16>{});
                } else {
                    rowScales[grow] = 1.f;
                    esimd::simd<int8_t,64> z((int8_t)0);
                    esimd::block_store<int8_t,64>(Cout8 + (size_t)grow*N, z, esimd::overaligned_tag<16>{});
                }
            }
        });
    });
}

// gemm_b_res_window -- the window-int8-residual fused store (section 92). Identical to
// gemm_b_res EXCEPT the store index: the gemm row rr is a window-token row (window*64+
// token), and the output lands at the IMAGE slot out = ((yy-top)*image_w+(xx-left))*N+gc
// with the same bounds cull the split publish pass does; skip is read at that same out.
// dpas main loop byte-identical. WINDOW_INT8_RESIDUAL gate is the judge.
static inline sycl::event gemm_b_res_window(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     const void* skip, const float* cos,
                                     int M, int Mp, int N, int K,
                                     bool narrow, bool half_skip, unsigned epi,
                                     unsigned across, unsigned top, unsigned left,
                                     unsigned image_h, unsigned image_w, unsigned nband = 1) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    size_t apb = (size_t)Mp * K, bpb = (size_t)N * K;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // s8d2 three-buffer
            int loc = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8 * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;   // s8d2: third buffer slot
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
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
                load_grf(cur, a0, a1, b0, b1);
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    unsigned window=(unsigned)rr0/64u, token=(unsigned)rr0%64u;
                    unsigned yy=(window/across)*8u+token/8u, xx=(window%across)*8u+token%8u;
                    bool in=(yy>=top&&xx>=left&&yy-top<image_h&&xx-left<image_w);
                    size_t out=in?(((size_t)(yy-top)*image_w+(xx-left))*N+gc):0;
                    float rs = as[(size_t)rr0 * nband + (nband > 1u ? (unsigned)(gc / 128) : 0u)];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {   // BLADE-4: same fma text, vectorized pub chain (epi1 proven)
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                    for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + f0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + f1.read()[e]);
                    }
                    if (in) { if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                              else        pub.copy_to((float*)Cout + out); }
                }
                if (rr1 < M) {
                    unsigned window=(unsigned)rr1/64u, token=(unsigned)rr1%64u;
                    unsigned yy=(window/across)*8u+token/8u, xx=(window%across)*8u+token%8u;
                    bool in=(yy>=top&&xx>=left&&yy-top<image_h&&xx-left<image_w);
                    size_t out=in?(((size_t)(yy-top)*image_w+(xx-left))*N+gc):0;
                    float rs = as[(size_t)rr1 * nband + (nband > 1u ? (unsigned)(gc / 128) : 0u)];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {   // BLADE-4 (window variant, second row): same rule
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                    for (int e = 0; e < 8; ++e) pub[e] = pub_esimd(epi, sk0[e]*ccl[e] + g0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = pub_esimd(epi, sk1[e]*cch[e] + g1.read()[e]);
                    }
                    if (in) { if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                              else        pub.copy_to((float*)Cout + out); }
                }
            }
        });
    });
}
} // namespace s8v8

// ============================================================================================
// C61b (2026-11-12): s8v8b -- the BK=64 form of the gemm_int8_residual path ONLY.
// The old s8v8 namespace stays byte-for-byte untouched for every other family; the gir call
// site in libxmx_sycl.cpp switches here when (K % 64 == 0) (all gir shapes qualify: the
// ledger's K set is {64,128,256,512,1024,4096}).
//
// Why this is bit-identical: int32 dpas accumulation is exact and associative over K, and the
// operand bytes are the SAME packed-A / packed-B planes -- an operand block here simply spans
// two consecutive kk32 blocks (the bench bench_s8v8_tile.cpp says it verbatim: "BK=64 needs a
// different A pack map (B pack needs nothing -- kk32 blocks are adjacent in global, so one SLM
// buffer just spans two of them)"). The A gather re-orders [kb][wi] -> [wi][kc] in SLM so the
// dpas stripes match; nothing else in the kernel changes. bench_s8v8_tile priced this form:
// 11 variants x 5 shapes x 3 processes, ALL diff=0, scratch=0, grf<=128, dynamic LSC -30%.
// ============================================================================================
namespace s8v8b {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static const int BM = 128, BN = 64, BK = 64, NT = 32;
static const int SLM_A = BM * BK;            // 8,192
static const int SLM_B = BK * BN;            // 4,096
static const int KC    = BK / 32;            // 2 dpas K-chunks per operand block
static const int A_WI  = 16 * BK;            // 1,024 B per wi_row (16 rows x BK)
static const int B_KC  = BN * 32;            // 2,048 B per kc (BN cols x 32 k)

static inline sycl::event gemm_b_res(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                     void* Cout, const float* as, const float* bs,
                                     const void* skip, const float* cos,
                                     int M, int Mp, int N, int K,
                                     bool narrow, bool half_skip, unsigned epi) {
    LC_TICK();   // #145 junreg 132: launch counted at helper entry
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * SLM_A + 3 * SLM_B>();   // 3x8192 + 3x4096 = 36,864 B (<= 48 KB, C53-proven safe)
            int loc = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            // SAME packed-A planes as s8v8 (kk32 blocks of 128 rows x 32 k = 4,096 B); an operand
            // block here spans TWO of them (BK=64), gathered into the SLM order [wi][kc][row][k].
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * 8192;   // BK=64: 8 x 1024 B per kb
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            const int SLM_B_BASE = 3 * SLM_A;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                // C61c: the plane is packed in the BK=64 order by pack_a64 / pack_a_fused64,
                // so the operand block is contiguous -- one linear 256 B message per thread
                // (the form bench_s8v8_tile validated at diff=0).
                esimd::simd<int8_t, 256> av = esimd::block_load<int8_t, 256>(
                    apb + (size_t)kb * SLM_A + lid * 256, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 256, av, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                        bp + ((size_t)kb * KC + kc) * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLM_B_BASE + buf * SLM_B + kc * B_KC + lid * 64, bv, esimd::overaligned_tag<16>{});
                }
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& a2, esimd::simd<int8_t,256>& a3,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1,
                                esimd::simd<int8_t,256>& b2, esimd::simd<int8_t,256>& b3) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A + wi_row * A_WI;
                uint32_t offB = SLM_B_BASE + buf * SLM_B + wi_col * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0,   esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                a2 = esimd::slm_block_load<int8_t, 256>(offA + 512, esimd::overaligned_tag<16>{});
                a3 = esimd::slm_block_load<int8_t, 256>(offA + 768, esimd::overaligned_tag<16>{});
                b0 = esimd::slm_block_load<int8_t, 256>(offB + 0,     esimd::overaligned_tag<16>{});
                b1 = esimd::slm_block_load<int8_t, 256>(offB + 256,   esimd::overaligned_tag<16>{});
                b2 = esimd::slm_block_load<int8_t, 256>(offB + 2048,  esimd::overaligned_tag<16>{});
                b3 = esimd::slm_block_load<int8_t, 256>(offB + 2304,  esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> a0, a1, a2, a3, b0, b1, b2, b3;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            if (K / BK > 1) load_block(1, 1);
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);
                load_grf(cur, a0, a1, a2, a3, b0, b1, b2, b3);
                // kc = 0 chunk
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                // kc = 1 chunk (the same accumulators, next 32 of K) -- dpas is exact and
                // associative over K, so the K order is free: C53 proved this bit-identical.
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b2, a2);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b3, a2);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b2, a3);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b3, a3);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    float rs = as[rr0];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr0*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    // fma: sk*cos + stage (one fused rounding, matches sycl::fma).
                    // BLADE-4 (ISA density ledger 2026-10-29): the pub chain here ran
                    // 128 SCALAR pub_esimd calls/thread (~1800 instrs) vs 8 dpas = the
                    // 0.1% density the census counted. The fma expression stays
                    // ELEMENTWISE byte-identical (the "do NOT vectorize res's fma"
                    // warning: a simd sk*c+f lowers as muladd = two roundings, frame 0%);
                    // only the PUB step is vectorized via pub_vec_v8 (bench_pubvec: epi
                    // 0/1/3/4 scalar-vs-vec IDENTICAL over 1M values; the frame's res
                    // flags 0x41100 -> epi=1; epi==2 keeps the scalar -0.0 path).
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = s8v8::pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + f0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + f1.read()[e]);
                    }
                    size_t out = (size_t)rr0 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
                if (rr1 < M) {
                    float rs = as[rr1];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + (size_t)rr1*N + gc, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = s8v8::pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                        for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + g0.read()[e]);
                        for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + g1.read()[e]);
                    }
                    size_t out = (size_t)rr1 * N + gc;
                    if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                    else        pub.copy_to((float*)Cout + out);
                }
            }
        });
    });
}
} // namespace s8v8b

// C82: the BN=128 / NT=64 / BK=64 tile family, copied from the bench form that is
// bit-exact against a host int32 reference at the C512 tier shapes (3 cold processes,
// correct=tot, bad=0; s6/layer1.md 171/174/177). Selected ONLY by NR_C512_BAND + the
// shape gate; default OFF leaves today's path byte-identical.
namespace s8v8d {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static const int BM = 128, BN = 64, BK = 32, NT = 32;
template <int BNV, int BKV, int NTV, int NBUF, int MODE, bool PUB>
static inline sycl::event gemm_var(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                   int32_t* C32, void* Cout, const float* as, const float* bs,
                                   int M, int Mp, int N, int K, int batch,
                                   size_t sc, unsigned ldc, unsigned scale_stride,
                                   unsigned col_stride, bool narrow, unsigned epi) {
    constexpr int SLM_A  = BM * BKV;              // A bytes per operand buffer (128 rows x BK)
    constexpr int SLM_B  = BKV * BNV;             // B bytes per operand buffer
    constexpr int A_WI   = 16 * BKV;              // A stripe bytes per thread (16 rows x BK)
    constexpr int KC     = BKV / 32;              // 32-K dpas chunks per kb block
    constexpr int STRIPE = (MODE >= 2) ? 1024 : 512;  // B stripe bytes per thread per kc
    int wg = (Mp / BM) * (N / BNV);
    size_t apb_sz = (size_t)Mp * K, bpb_sz = (size_t)N * K, cb_sz = (size_t)Mp * N;
    int kb_n = K / BKV;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NTV), range(NTV)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            constexpr uint32_t SLMB_BASE = NBUF * SLM_A;   // B buffers follow the A buffers
            esimd::slm_init<NBUF * SLM_A + NBUF * SLM_B>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BNV;
            int wg_row = loc / NB, wg_col = loc % NB;
            constexpr int WIC = (MODE == 1) ? 8 : 4;       // col bands: NT64 -> 8, NT32 -> 4
            int wi_row = lid / WIC, wi_col = lid % WIC;
            const int8_t* apb = Ap + (size_t)g * apb_sz + (size_t)(wg_row * kb_n) * SLM_A;
            const int8_t* bp  = Bp + (size_t)g * bpb_sz + (size_t)wg_col * (BNV / 8) * 256;
            int32_t* c_g = C32 + (size_t)g * cb_sz;
            // global -> SLM block copy of one kb. The A block is contiguous (pack_a64
            // lays it out per (w,kb)). The B block is KC kk32 blocks -- pack_b puts
            // consecutive kk32 blocks N*32 bytes apart in global, so they are only
            // adjacent when N==BNV; copy them piecewise at their SLM slots (KC=1
            // reduces to the shipped single linear copy).
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, SLM_A / NTV> av = esimd::block_load<int8_t, SLM_A / NTV>(
                    apb + (size_t)kb * SLM_A + lid * (SLM_A / NTV), esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * (SLM_A / NTV), av, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    esimd::simd<int8_t, SLM_B / KC / NTV> bv = esimd::block_load<int8_t, SLM_B / KC / NTV>(
                        bp + (size_t)kb * N * BKV + (size_t)kc * (N * 32) + lid * (SLM_B / KC / NTV),
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLMB_BASE + buf * SLM_B + kc * (SLM_B / KC)
                        + lid * (SLM_B / KC / NTV), bv, esimd::overaligned_tag<16>{});
                }
            };
            // one full K-sweep over column-tile s (s=0/1 only for MODE2; else s=0).
            auto sweep = [&](int s) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> a0, a1, b0, b1, b2, b3;
                esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
                esimd::simd<int32_t, 64> c02(0), c03(0), c12(0), c13(0);
                // MODE2 second-sweep fast path: when the whole kb pipeline fits in the
                // buffers (kb_n <= NBUF), sweep(1) reads the still-resident SLM and
                // touches global ZERO. Otherwise it re-loads every block (the honest
                // double-load form). NBUF=3 with K=64/128 and NBUF=4 with K<=128 hit it.
                int load_this = (s == 0 || kb_n > NBUF) ? 1 : 0;
                int nb = (NBUF - 1 < kb_n) ? NBUF - 1 : kb_n;
                if (load_this) for (int p = 0; p < nb; ++p) load_block(p, p);
                esimd::barrier();
                for (int b = 0; b < kb_n; ++b) {
                    int cur = b % NBUF;
                    int nx = b + NBUF - 1;
                    if (load_this && nx < kb_n) load_block(nx % NBUF, nx);
                    #pragma unroll
                    for (int kc = 0; kc < KC; ++kc) {
                        uint32_t offA = (uint32_t)(cur * SLM_A) + (uint32_t)(wi_row * A_WI) + (uint32_t)(kc * 512);
                        uint32_t offB = SLMB_BASE + (uint32_t)(cur * SLM_B)
                                      + (uint32_t)(kc * (BNV * 32)) + (uint32_t)(wi_col * STRIPE)
                                      + (MODE == 2 ? (uint32_t)(s * 512) : 0u);
                        a0 = esimd::slm_block_load<int8_t, 256>(offA + 0,   esimd::overaligned_tag<16>{});
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                        b0 = esimd::slm_block_load<int8_t, 256>(offB + 0,   esimd::overaligned_tag<16>{});
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                        if (MODE == 3) {
                            b2 = esimd::slm_block_load<int8_t, 256>(offB + 512, esimd::overaligned_tag<16>{});
                            b3 = esimd::slm_block_load<int8_t, 256>(offB + 768, esimd::overaligned_tag<16>{});
                        }
                        c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                        c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                        c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                        if (MODE == 3) {
                            c02 = esimd::xmx::dpas<8, 8, int32_t>(c02, b2, a0);
                            c03 = esimd::xmx::dpas<8, 8, int32_t>(c03, b3, a0);
                            c12 = esimd::xmx::dpas<8, 8, int32_t>(c12, b2, a1);
                            c13 = esimd::xmx::dpas<8, 8, int32_t>(c13, b3, a1);
                        }
                    }
                    esimd::barrier();
                }
                // ---- store: the shipped v8 tails VERBATIM (raw = gemm_b's block_store
                // pair; pub = gemm_b_pub's cs/rs/acc-assembly/pub_vec_v8 chain) ----
                int gr = wg_row * BM + wi_row * 16;
                int gc = wg_col * BNV + (MODE >= 2 ? wi_col * 32 : wi_col * 16)
                       + (MODE == 2 ? s * 16 : 0);
                if (!PUB) {
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t, 16> row0;
                        row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                        row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                        esimd::simd<int32_t, 16> row1;
                        row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                        row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                        esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                        esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
                        if (MODE == 3) {
                            esimd::simd<int32_t, 16> row0h;
                            row0h.select<8, 1>(0) = c02.select<8, 1>(r * 8);
                            row0h.select<8, 1>(8) = c03.select<8, 1>(r * 8);
                            esimd::simd<int32_t, 16> row1h;
                            row1h.select<8, 1>(0) = c12.select<8, 1>(r * 8);
                            row1h.select<8, 1>(8) = c13.select<8, 1>(r * 8);
                            esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc + 16, row0h, esimd::overaligned_tag<16>{});
                            esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc + 16, row1h, esimd::overaligned_tag<16>{});
                        }
                    }
                } else {
                    const float* gas = as + (size_t)g * scale_stride;
                    const float* gbs = bs + (size_t)g * col_stride;
                    esimd::simd<float, 16> cs = esimd::block_load<float, 16>(
                        gbs + gc, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> cs2;
                    if (MODE == 3) cs2 = esimd::block_load<float, 16>(gbs + gc + 16, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        int rr0 = gr + r, rr1 = gr + 8 + r;
                        if (rr0 < M) {
                            float rs = gas[rr0];
                            esimd::simd<int32_t, 16> acc(0);
                            acc.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                            acc.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                            esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                            if (MODE == 3) {
                                esimd::simd<int32_t, 16> acc2(0);
                                acc2.select<8, 1>(0) = c02.select<8, 1>(r * 8);
                                acc2.select<8, 1>(8) = c03.select<8, 1>(r * 8);
                                esimd::simd<float, 16> pub2 = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc2) * rs * cs2);
                                if (narrow) esimd::convert<half>(pub2).copy_to((half*)Cout + out + 16);
                                else        pub2.copy_to((float*)Cout + out + 16);
                            }
                        }
                        if (rr1 < M) {
                            float rs = gas[rr1];
                            esimd::simd<int32_t, 16> acc(0);
                            acc.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                            acc.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                            esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc) * rs * cs);
                            size_t out = (size_t)g * sc + (size_t)rr1 * ldc + gc;
                            if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                            else        pub.copy_to((float*)Cout + out);
                            if (MODE == 3) {
                                esimd::simd<int32_t, 16> acc2(0);
                                acc2.select<8, 1>(0) = c12.select<8, 1>(r * 8);
                                acc2.select<8, 1>(8) = c13.select<8, 1>(r * 8);
                                esimd::simd<float, 16> pub2 = s8v8::pub_vec_v8<16>(epi, esimd::convert<float>(acc2) * rs * cs2);
                                if (narrow) esimd::convert<half>(pub2).copy_to((half*)Cout + out + 16);
                                else        pub2.copy_to((float*)Cout + out + 16);
                            }
                        }
                    }
                }
            };
            sweep(0);
            if (MODE == 2) sweep(1);   // the blueprint form's second 16-col tile
        });
    });
}
} // namespace s8v8d

// ============================================================================
// C89 (knife A'): the wres leg's PUBLISH epilogue on a BN=128 / NT=64 / BK=64 tile.
// The tile math is copied from the bench form that is bit-exact against a host int32
// reference at this tier's shapes (s6/layer1.md 171/174/177/183: correct=tot, bad=0),
// and the res/skip/window tail is copied VERBATIM from s8v8::gemm_b_res_window
// (gemm_s8_v8_kernel.hpp:1324-1389) -- the accumulator set (c00,c01,c10,c11) and the
// gr/gc mapping match exactly, so the tail needs no semantic change.
// Selected ONLY by NR_WRES_PUB128 + the pinned live shape; default OFF = byte-identical.
// SLM: 2*(128*64) + 2*(64*128) = 32,768 B  -> stays in the 3-WG/Xe-core bucket.
namespace s8v8t {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static inline sycl::event gemm_b_res_window_128(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                                void* Cout, const float* as, const float* bs,
                                                const void* skip, const float* cos,
                                                int M, int Mp, int N, int K,
                                                bool narrow, bool half_skip, unsigned epi,
                                                unsigned across, unsigned top, unsigned left,
                                                unsigned image_h, unsigned image_w, unsigned nband = 1) {
    LC_TICK();
    constexpr int BM = 128, BNV = 128, BKV = 64, NTV = 64, NBUF = 2, MODE = 1;
    constexpr int BN = BNV;                     // the copied window tail refers to BN
    constexpr int SLM_A = BM * BKV, SLM_B = BKV * BNV, A_WI = 16 * BKV;
    constexpr int KC = BKV / 32;
    constexpr int STRIPE = (MODE >= 2) ? 1024 : 512;
    int32_t* C32 = nullptr;                     // the raw-int32 sink is unused in this form
    const int batch = 1;
    int wg = (Mp / BM) * (N / BNV);
    size_t apb_sz = (size_t)Mp * K, bpb_sz = (size_t)N * K, cb_sz = (size_t)Mp * N;
    int kb_n = K / BKV;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NTV), range(NTV)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            constexpr uint32_t SLMB_BASE = NBUF * SLM_A;   // B buffers follow the A buffers
            esimd::slm_init<NBUF * SLM_A + NBUF * SLM_B>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BNV;
            int wg_row = loc / NB, wg_col = loc % NB;
            constexpr int WIC = (MODE == 1) ? 8 : 4;       // col bands: NT64 -> 8, NT32 -> 4
            int wi_row = lid / WIC, wi_col = lid % WIC;
            const int8_t* apb = Ap + (size_t)g * apb_sz + (size_t)(wg_row * kb_n) * SLM_A;
            const int8_t* bp  = Bp + (size_t)g * bpb_sz + (size_t)wg_col * (BNV / 8) * 256;
            int32_t* c_g = C32 + (size_t)g * cb_sz;
            // global -> SLM block copy of one kb. The A block is contiguous (pack_a64
            // lays it out per (w,kb)). The B block is KC kk32 blocks -- pack_b puts
            // consecutive kk32 blocks N*32 bytes apart in global, so they are only
            // adjacent when N==BNV; copy them piecewise at their SLM slots (KC=1
            // reduces to the shipped single linear copy).
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, SLM_A / NTV> av = esimd::block_load<int8_t, SLM_A / NTV>(
                    apb + (size_t)kb * SLM_A + lid * (SLM_A / NTV), esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * (SLM_A / NTV), av, esimd::overaligned_tag<16>{});
                #pragma unroll
                for (int kc = 0; kc < KC; ++kc) {
                    esimd::simd<int8_t, SLM_B / KC / NTV> bv = esimd::block_load<int8_t, SLM_B / KC / NTV>(
                        bp + (size_t)kb * N * BKV + (size_t)kc * (N * 32) + lid * (SLM_B / KC / NTV),
                        esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(SLMB_BASE + buf * SLM_B + kc * (SLM_B / KC)
                        + lid * (SLM_B / KC / NTV), bv, esimd::overaligned_tag<16>{});
                }
            };
            esimd::simd<int8_t, 256> a0, a1, b0, b1, b2, b3;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            esimd::simd<int32_t, 64> c02(0), c03(0), c12(0), c13(0);   // MODE=3 lanes, unused here
            const int load_this = 1;                       // MODE=1: a single sweep
            { int nb = (NBUF - 1 < kb_n) ? NBUF - 1 : kb_n;
              for (int p = 0; p < nb; ++p) load_block(p, p); }
            esimd::barrier();
                for (int b = 0; b < kb_n; ++b) {
                    int cur = b % NBUF;
                    int nx = b + NBUF - 1;
                    if (load_this && nx < kb_n) load_block(nx % NBUF, nx);
                    #pragma unroll
                    for (int kc = 0; kc < KC; ++kc) {
                        uint32_t offA = (uint32_t)(cur * SLM_A) + (uint32_t)(wi_row * A_WI) + (uint32_t)(kc * 512);
                        uint32_t offB = SLMB_BASE + (uint32_t)(cur * SLM_B)
                                      + (uint32_t)(kc * (BNV * 32)) + (uint32_t)(wi_col * STRIPE)
                                      + 0u;
                        a0 = esimd::slm_block_load<int8_t, 256>(offA + 0,   esimd::overaligned_tag<16>{});
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                        b0 = esimd::slm_block_load<int8_t, 256>(offB + 0,   esimd::overaligned_tag<16>{});
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                        if (MODE == 3) {
                            b2 = esimd::slm_block_load<int8_t, 256>(offB + 512, esimd::overaligned_tag<16>{});
                            b3 = esimd::slm_block_load<int8_t, 256>(offB + 768, esimd::overaligned_tag<16>{});
                        }
                        c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                        c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                        c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                        if (MODE == 3) {
                            c02 = esimd::xmx::dpas<8, 8, int32_t>(c02, b2, a0);
                            c03 = esimd::xmx::dpas<8, 8, int32_t>(c03, b3, a0);
                            c12 = esimd::xmx::dpas<8, 8, int32_t>(c12, b2, a1);
                            c13 = esimd::xmx::dpas<8, 8, int32_t>(c13, b3, a1);
                        }
                    }
                    esimd::barrier();
                }
            // ---- the shipped window tail, VERBATIM (s8v8::gemm_b_res_window:1324-1389) ----
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 16> cc = esimd::block_load<float, 16>(cos + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> csl = cs.template select<8,1>(0), csh = cs.template select<8,1>(8);
            esimd::simd<float, 8> ccl = cc.template select<8,1>(0), cch = cc.template select<8,1>(8);
            for (int r = 0; r < 8; ++r) {
                int rr0 = gr + r, rr1 = gr + 8 + r;
                if (rr0 < M) {
                    unsigned window=(unsigned)rr0/64u, token=(unsigned)rr0%64u;
                    unsigned yy=(window/across)*8u+token/8u, xx=(window%across)*8u+token%8u;
                    bool in=(yy>=top&&xx>=left&&yy-top<image_h&&xx-left<image_w);
                    size_t out=in?(((size_t)(yy-top)*image_w+(xx-left))*N+gc):0;
                    float rs = as[(size_t)rr0 * nband + (nband > 1u ? (unsigned)(gc / 128) : 0u)];
                    esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {   // BLADE-4: same fma text, vectorized pub chain (epi1 proven)
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + f0.read()[e]; t1[e] = sk1[e]*cch[e] + f1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = s8v8::pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                    for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + f0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + f1.read()[e]);
                    }
                    if (in) { if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                              else        pub.copy_to((float*)Cout + out); }
                }
                if (rr1 < M) {
                    unsigned window=(unsigned)rr1/64u, token=(unsigned)rr1%64u;
                    unsigned yy=(window/across)*8u+token/8u, xx=(window%across)*8u+token%8u;
                    bool in=(yy>=top&&xx>=left&&yy-top<image_h&&xx-left<image_w);
                    size_t out=in?(((size_t)(yy-top)*image_w+(xx-left))*N+gc):0;
                    float rs = as[(size_t)rr1 * nband + (nband > 1u ? (unsigned)(gc / 128) : 0u)];
                    esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * rs * csl;
                    esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * rs * csh;
                    esimd::simd<float, 8> sk0, sk1;
                    if (half_skip) {
                        esimd::simd<half,16> sh = esimd::block_load<half,16>((const half*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = esimd::convert<float>(sh.template select<8,1>(0).read()); sk1 = esimd::convert<float>(sh.template select<8,1>(8).read());
                    } else {
                        esimd::simd<float,16> sf = esimd::block_load<float,16>((const float*)skip + out, esimd::overaligned_tag<16>{});
                        sk0 = sf.template select<8,1>(0); sk1 = sf.template select<8,1>(8);
                    }
                    esimd::simd<float, 16> pub;
                    if (epi != 2u) {   // BLADE-4 (window variant, second row): same rule
                        esimd::simd<float,8> t0, t1;
                        for (int e = 0; e < 8; ++e) { t0[e] = sk0[e]*ccl[e] + g0.read()[e]; t1[e] = sk1[e]*cch[e] + g1.read()[e]; }
                        { esimd::simd<float,16> tt; tt.template select<8,1>(0) = t0; tt.template select<8,1>(8) = t1;
                          pub = s8v8::pub_vec_v8<16>(epi, tt); }   // B3-ffn-4: 8-wide EU-slot waste (see chip ffn-3)
                    } else {
                    for (int e = 0; e < 8; ++e) pub[e] = s8v8::pub_esimd(epi, sk0[e]*ccl[e] + g0.read()[e]);
                    for (int e = 0; e < 8; ++e) pub[8+e] = s8v8::pub_esimd(epi, sk1[e]*cch[e] + g1.read()[e]);
                    }
                    if (in) { if (narrow) esimd::convert<half>(pub).copy_to((half*)Cout + out);
                              else        pub.copy_to((float*)Cout + out); }
                }
            }
        });
    });
}
} // namespace s8v8t
