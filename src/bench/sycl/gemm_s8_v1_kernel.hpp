// gemm_s8_v1_kernel.hpp — the senior's PROVEN v1 ESIMD int8 GEMM (esimd_gemm_s8_v1.cpp),
// extracted verbatim as the single source of truth for the skeleton's rec_gemm_int8.
// correctness int32 path only (the STORE_INT8 truncated-speed branch is a benchmark
// artifact, not a shipping output — §9's single world wants exact int32 + requant in
// the epilogue, which is the NEXT step, not this path-validation cut).
//
// BM=128 BN=64 BK=32 NT=32, double-buffered SLM (12 KB), 4x dpas<8,8,int32> per step,
// VNNI-packed operands. s8 accumulates in int32 (a float accumulator returns NaN on
// the hardware — the bug the senior's header note records). Operands arrive PRE-PACKED
// (pack_a/pack_b below, host-side — weights are static, packing once outside the timed
// loop is the senior's contract, same as the oneDNN runs).
//
// Shapes must satisfy M%128==0, N%64==0, K%32==0 (the senior's constraint).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>

namespace s8v1 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 64, BK = 32, NT = 32;
static const int SLM_A = BM * BK;
static const int SLM_B = BK * BN;
static const int SLM_B_BASE = 2 * SLM_A;
static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;

// host packing, byte-identical to esimd_gemm_s8_v1.cpp:55-77 (the gate uses these so
// the packed operands match what the kernel expects — no divergence).
static inline void pack_a(const int8_t* A, int8_t* Ap, int M, int K) {
    int wgr = M / BM, kb_n = K / BK;
    for (int w = 0; w < wgr; ++w)
        for (int kb = 0; kb < kb_n; ++kb)
            for (int wi = 0; wi < 8; ++wi)
                for (int row = 0; row < 16; ++row)
                    for (int k = 0; k < 32; ++k)
                        Ap[(((size_t)(w * kb_n + kb) * 8 + wi) * 512) + row * 32 + k] =
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

// the launch, verbatim from gemm_s8() minus the C8/STORE_INT8 branch. Ap/Bp packed,
// C32 exact int32 output. Returns the event so the caller can profile or wait.
static inline sycl::event gemm_s8(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                  int32_t* C32, int M, int N, int K) {
    int wg = (M / BM) * (N / BN);
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

} // namespace s8v1
