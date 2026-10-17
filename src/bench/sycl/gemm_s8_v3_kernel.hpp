// gemm_s8_v3_kernel.hpp — v1's efficient main loop (BM128/BN64/BK32/NT32, double-buffer
// SLM, 4x dpas) + v2's PROVEN fused-requantize epilogue, swapped in verbatim. The
// variable layouts align (both use wi_row=lid/4, wi_col=lid%4, gr=wg_row*BM+wi_row*16,
// gc=wg_col*BN+wi_col*16, c00..c11 as 4x simd<int32,64>), so v2's phase1 (per-row absmax
// atomic-fmax into SLM rmax) + phase2 (read row absmax, requantize, int8 store +
// new_scale) drop straight into v1's store position.
//
// CONSTRAINT: N must equal BN (=64), so the whole row lives in one workgroup and the
// row absmax is complete. That is the design fact §23 forced: fused requantize needs the
// whole row in-group, and it is the ONLY way to get the 4x store-traffic payoff (writing
// int32 then re-reading it for a separate requantize = 9 B/elem = the shipped float32-out
// cost, zero payoff). N=128 shapes need a BN=128 variant (next step); here BN=64 covers
// attnV/outproj/FFNproj (real N=32 padded to 64, section 8's table).
//
// RMAX_BASE = 2*SLM_A + 2*SLM_B (right after the operand buffers); SLM_TOTAL adds BM*4.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>

namespace s8v3 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 64, BK = 32, NT = 32;
static const int SLM_A = BM * BK;            // 4096
static const int SLM_B = BK * BN;            // 2048
static const int SLM_B_BASE = 2 * SLM_A;
static const int RMAX_BASE = 2 * SLM_A + 2 * SLM_B;   // 12288
static const int SLM_TOTAL = RMAX_BASE + BM * 4;      // 12800 < 32 KB

// pack_a/pack_b identical to v1 (N=BN=64 here).
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

// C8 = int8 output (M*N), new_scale = float[M]. col_scale = the b_scale[N] dequant of the
// int32 accumulator before requantize (exact-float math, matches v2's host golden).
static inline sycl::event gemm_s8(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                  const float* col_scale, int8_t* C8, float* new_scale,
                                  int M, int N, int K) {
    int wg = (M / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            // v2 initializes its rmax region to 0 before the atomic-fmax (esimd_gemm_s8_v2.cpp:76-77);
            // v1 had no rmax so its loop omitted this. BM=128 needs 128 floats = 4 strided stores
            // (lid=0..31, j=0..3 -> 0..127). Without it the atomic-fmax races garbage (large-M FAIL).
            for (int j = 0; j < 4; ++j)
                esimd::slm_block_store(RMAX_BASE + (lid + 32 * j) * 4,
                                       esimd::simd<float, 1>(0.f), esimd::overaligned_tag<16>{});
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
            // ---- v2's fused-requantize epilogue, verbatim (esimd_gemm_s8_v2.cpp:115-156) ----
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 8> cs_lo = esimd::block_load<float, 8>(col_scale + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> cs_hi = esimd::block_load<float, 8>(col_scale + gc + 8, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * cs_lo;
                esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * cs_hi;
                esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * cs_lo;
                esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * cs_hi;
                float pm0 = esimd::max(esimd::hmax<float,float,8>(esimd::abs(f0)),
                                       esimd::hmax<float,float,8>(esimd::abs(f1)));
                float pm1 = esimd::max(esimd::hmax<float,float,8>(esimd::abs(g0)),
                                       esimd::hmax<float,float,8>(esimd::abs(g1)));
                int lr0 = wi_row * 16 + r, lr1 = wi_row * 16 + 8 + r;
                esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                    esimd::simd<uint32_t, 1>((uint32_t)(RMAX_BASE + lr0 * 4)), esimd::simd<float, 1>(pm0));
                esimd::slm_atomic_update<esimd::atomic_op::fmax, float, 1>(
                    esimd::simd<uint32_t, 1>((uint32_t)(RMAX_BASE + lr1 * 4)), esimd::simd<float, 1>(pm1));
            }
            esimd::barrier();
            esimd::simd<float, 16> rmaxv = esimd::slm_block_load<float, 16>(
                RMAX_BASE + wi_row * 16 * 4, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> lo127(-127.f), hi127(127.f);
            for (int r = 0; r < 8; ++r) {
                float rm0 = rmaxv[r], rm1 = rmaxv[8 + r];
                float inv0 = (rm0 > 0.f) ? 127.0f / rm0 : 0.f;
                float inv1 = (rm1 > 0.f) ? 127.0f / rm1 : 0.f;
                if (wi_col == 0) { new_scale[gr + r] = rm0 / 127.0f; new_scale[gr + 8 + r] = rm1 / 127.0f; }
                esimd::simd<float, 8> q00 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c00.select<8,1>(r*8).read()) * cs_lo * inv0), lo127), hi127);
                esimd::simd<float, 8> q01 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c01.select<8,1>(r*8).read()) * cs_hi * inv0), lo127), hi127);
                esimd::simd<int8_t, 8> o00 = esimd::convert<int8_t>(esimd::convert<int>(q00));
                esimd::simd<int8_t, 8> o01 = esimd::convert<int8_t>(esimd::convert<int>(q01));
                esimd::simd<int8_t, 16> ob0; ob0.select<8, 1>(0) = o00; ob0.select<8, 1>(8) = o01;
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + r) * N + gc, ob0, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> q10 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c10.select<8,1>(r*8).read()) * cs_lo * inv1), lo127), hi127);
                esimd::simd<float, 8> q11 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c11.select<8,1>(r*8).read()) * cs_hi * inv1), lo127), hi127);
                esimd::simd<int8_t, 8> o10 = esimd::convert<int8_t>(esimd::convert<int>(q10));
                esimd::simd<int8_t, 8> o11 = esimd::convert<int8_t>(esimd::convert<int>(q11));
                esimd::simd<int8_t, 16> ob1; ob1.select<8, 1>(0) = o10; ob1.select<8, 1>(8) = o11;
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + 8 + r) * N + gc, ob1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

} // namespace s8v3
