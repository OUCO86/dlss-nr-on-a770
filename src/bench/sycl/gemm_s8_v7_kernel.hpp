// gemm_s8_v7_kernel.hpp — v3's fused-requantize GEMM at BN=32 (route-B P2, section 50
// point 3: the N=32 gap is OUR kernel-shape problem; build the variant, don't defer).
//
// Target shapes: attnV = P.V, N=32 (head_dim) K=tokens -- the senior's own call proves the
// shape (nr_resident.py:585: gemm(probs16, v16, context, padded, 32, padded, batch=heads));
// at GLOBAL blocks per-head M=padded(tokens)=640=5*128 satisfies BM=128. Window blocks'
// M=64 per (window,head) does NOT -- they wait for the megakernel batching windows into M
// (section 7 (6): make M big); this kernel is exactly the stage the megakernel reuses.
// Also outproj at C=32 window blocks (N=32, K=32) -- same geometry, small M: megakernel too.
//
// Geometry: BM=128, BN=32, BK=32, NT=16 (one subgroup), 8x2 WI grid of 16x16 tiles.
//   A block = 128*32 = 4096 B -> 16 WI at 256 B each. B block = 32*32 = 1024 B -> 16 WI at
//   64 B. GRF load: a0,a1 at offA=buf*4096+wi_row*512 (wi_row=lid/2 spans 0..7 = BM/16);
//   b0,b1 at offB=SLM_B_BASE+buf*1024+wi_col*512 (wi_col=lid%2 spans 0..1; the tile's
//   32k x 16 cols = 512 B). 4x dpas<8,8,int32 per K step, double-buffered, exactly v3.
// Fused-requantize epilogue = v3's verbatim (section 24's contract, already gated 4 shapes
// in SKELETON_GEMM_RQ): col_scale folded into fp, row absmax via SLM atomic-fmax (whole row
// lives in the workgroup since N==BN==32), out=clip(rnde(fp*127/rmax),+-127), new_scale=
// rmax/127, int8 store at (gr+r)*N+gc with gc in {0,16} (16B-aligned).
// pack_a/pack_b: v3's formulas already take N as a parameter (N/8 tiles -> 4 at N=32).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>

namespace s8v7 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 32, BK = 32, NT = 16;
static const int WI_ROWS = BM / 16, WI_COLS = BN / 16;          // 8 x 2 = 16 = NT
static const int SLM_A = BM * BK;                               // 4096
static const int SLM_B = BK * BN;                               // 1024
static const int SLM_B_BASE = 2 * SLM_A;
static const int RMAX_BASE = 2 * SLM_A + 2 * SLM_B;             // 10240
static const int SLM_TOTAL = RMAX_BASE + BM * 4;                // 10752 B

// pack_a identical to v3 (A is BM x K, independent of BN).
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
// pack_b: v3's formula with N a parameter (N/8 = 4 tiles at N=32).
static inline void pack_b(const int8_t* B, int8_t* Bp, int K, int N) {
    for (int kk32 = 0; kk32 < K / 32; ++kk32)
        for (int ntile = 0; ntile < N / 8; ++ntile)
            for (int kq = 0; kq < 8; ++kq)
                for (int nl = 0; nl < 8; ++nl)
                    for (int j = 0; j < 4; ++j)
                        Bp[(((size_t)kk32 * (N / 8) + ntile) * 64 + kq * 8 + nl) * 4 + j] =
                            B[(size_t)(kk32 * 32 + kq * 4 + j) * N + (ntile * 8 + nl)];
}

// C8 = int8 (M*N), new_scale = float[M], col_scale = float[N]. a_scale = float[M] folded
// into the dequantise (attnV's A row scale = softmax_i8's probs ps_q -- section 52: it is
// the real per-query amplitude and must reach new_scale; passing an all-ones a_scale
// degenerates to the col-scale-only case the s8rq-N32 gate already proved = consistency).
// fp = float(acc) * a_scale[row] * b_scale[col], shipped left-to-right (island-3, the
// same order requant_i8/softmax_i8 use), then the v3 row-requantize contract.
static inline sycl::event gemm_s8rq32(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                      const float* a_scale, const float* col_scale,
                                      int8_t* C8, float* new_scale,
                                      int M, int N, int K) {
    int wg = (M / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            // rmax init BEFORE any atomic-fmax (v3's lesson: races garbage without it).
            // BM=128 floats / 16 WI = 8 strided stores.
            for (int j = 0; j < 8; ++j)
                esimd::slm_block_store(RMAX_BASE + (lid + NT * j) * 4,
                                       esimd::simd<float, 1>(0.f), esimd::overaligned_tag<16>{});
            int NB = N / BN;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 256> av = esimd::block_load<int8_t, 256>(
                    apb + (size_t)kb * SLM_A + lid * 256, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 256, av, esimd::overaligned_tag<16>{});
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
            // ---- v3's fused-requantize epilogue (row lives wholly in the workgroup) ----
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            esimd::simd<float, 8> cs_lo = esimd::block_load<float, 8>(col_scale + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> cs_hi = esimd::block_load<float, 8>(col_scale + gc + 8, esimd::overaligned_tag<16>{});
            for (int r = 0; r < 8; ++r) {
                float as0 = a_scale[gr + r], as1 = a_scale[gr + 8 + r];   // per-row A scale
                esimd::simd<float, 8> f0 = esimd::convert<float>(c00.select<8,1>(r*8).read()) * as0 * cs_lo;
                esimd::simd<float, 8> f1 = esimd::convert<float>(c01.select<8,1>(r*8).read()) * as0 * cs_hi;
                esimd::simd<float, 8> g0 = esimd::convert<float>(c10.select<8,1>(r*8).read()) * as1 * cs_lo;
                esimd::simd<float, 8> g1 = esimd::convert<float>(c11.select<8,1>(r*8).read()) * as1 * cs_hi;
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
                float as0 = a_scale[gr + r], as1 = a_scale[gr + 8 + r];
                if (wi_col == 0) { new_scale[gr + r] = rm0 / 127.0f; new_scale[gr + 8 + r] = rm1 / 127.0f; }
                esimd::simd<float, 8> q00 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c00.select<8,1>(r*8).read()) * as0 * cs_lo * inv0), lo127), hi127);
                esimd::simd<float, 8> q01 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c01.select<8,1>(r*8).read()) * as0 * cs_hi * inv0), lo127), hi127);
                esimd::simd<int8_t, 8> o00 = esimd::convert<int8_t>(esimd::convert<int>(q00));
                esimd::simd<int8_t, 8> o01 = esimd::convert<int8_t>(esimd::convert<int>(q01));
                esimd::simd<int8_t, 16> ob0; ob0.select<8, 1>(0) = o00; ob0.select<8, 1>(8) = o01;
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + r) * N + gc, ob0, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> q10 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c10.select<8,1>(r*8).read()) * as1 * cs_lo * inv1), lo127), hi127);
                esimd::simd<float, 8> q11 = esimd::min(esimd::max(esimd::rnde<float,8>(esimd::convert<float>(c11.select<8,1>(r*8).read()) * as1 * cs_hi * inv1), lo127), hi127);
                esimd::simd<int8_t, 8> o10 = esimd::convert<int8_t>(esimd::convert<int>(q10));
                esimd::simd<int8_t, 8> o11 = esimd::convert<int8_t>(esimd::convert<int>(q11));
                esimd::simd<int8_t, 16> ob1; ob1.select<8, 1>(0) = o10; ob1.select<8, 1>(8) = o11;
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + 8 + r) * N + gc, ob1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

} // namespace s8v7
