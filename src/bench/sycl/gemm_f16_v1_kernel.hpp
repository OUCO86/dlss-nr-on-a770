// gemm_f16_v1_kernel.hpp -- the f16 dpas GEMM as a reusable header (section 81/81.5:
// layout probe-confirmed, tile standalone GREEN 32x32x32 0 bad). One work-item = one
// 16x16 output tile: 2 A row-strips x 2 B col-strips = 4 dpas per 16-K step, f32
// accumulators, per-row store. Shapes: M padded to 16 by the caller, N %16==0, K %16==0.
//
// Layout (section 81, esimd_f16_dp_probe.cpp LAYOUT TRUE 0/64):
//   A_simd[i*16 + k]                       row-major (i 0..7, k 0..15)
//   B_simd[(k/2)*16 + j_local*2 + (k%2)]   OpsPerChannel=2 packing
//   C[i*8 + j]                             row-major 8x8 per dpas
// pack_a/pack_b below produce exactly these from row-major M x K / K x N halfs.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>

namespace f16v1 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int TS = 16;   // tile side (8x8 per dpas, 2x2 dpas = 16x16)

// A: Mp x K row-major halfs -> Ap blocks indexed (tr, kc, strip).
static inline void pack_a(const half* A, half* Ap, int Mp, int K) {
    int tr_n = Mp / TS, kb_n = K / TS;
    for (int tr = 0; tr < tr_n; ++tr)
        for (int kc = 0; kc < kb_n; ++kc)
            for (int strip = 0; strip < 2; ++strip)
                for (int il = 0; il < 8; ++il)
                    for (int k = 0; k < 16; ++k)
                        Ap[(((size_t)(tr * kb_n + kc) * 2 + strip) * 128) + il * 16 + k] =
                            A[(size_t)(tr * TS + strip * 8 + il) * K + kc * TS + k];
}
// B: K x N row-major halfs -> Bp blocks indexed (kc, tc, jstrip).
static inline void pack_b(const half* B, half* Bp, int K, int N) {
    int kb_n = K / TS, tc_n = N / TS;
    for (int kc = 0; kc < kb_n; ++kc)
        for (int tc = 0; tc < tc_n; ++tc)
            for (int js = 0; js < 2; ++js)
                for (int k = 0; k < 16; ++k)
                    for (int jl = 0; jl < 8; ++jl)
                        Bp[(((size_t)(kc * tc_n + tc) * 2 + js) * 128) + (k / 2) * 16 + jl * 2 + (k % 2)] =
                            B[(size_t)(kc * TS + k) * N + tc * TS + js * 8 + jl];
}

// B TRANSPOSED: the scores leg's K is stored (N, K) row-major (tokens x head_dim), and
// gemm_staged.comp:16 `transposed = flags bit 0` makes ldb default to K -- logical
// B[k][j] = Bmem[j*K + k]. Same dpas operand layout, only the source index flips.
static inline void pack_b_t(const half* B, half* Bp, int K, int N) {
    int kb_n = K / TS, tc_n = N / TS;
    for (int kc = 0; kc < kb_n; ++kc)
        for (int tc = 0; tc < tc_n; ++tc)
            for (int js = 0; js < 2; ++js)
                for (int k = 0; k < 16; ++k)
                    for (int jl = 0; jl < 8; ++jl)
                        Bp[(((size_t)(kc * tc_n + tc) * 2 + js) * 128) + (k / 2) * 16 + jl * 2 + (k % 2)] =
                            B[(size_t)(tc * TS + js * 8 + jl) * K + kc * TS + k];
}

// C = A @ B, f32 accumulate, Mp x N. Ap/Bp packed. Returns the event.
static inline sycl::event gemm(sycl::queue& q, const half* Ap, const half* Bp,
                               float* C, int Mp, int N, int K) {
    int tr_n = Mp / TS, tc_n = N / TS, kb_n = K / TS;
    return q.submit([&](handler& h) {
        h.parallel_for(range<1>((size_t)tr_n * tc_n), [=](item<1> it) SYCL_ESIMD_KERNEL {
            int t = (int)it.get_id(0); int tr = t / tc_n, tc = t % tc_n;
            esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
            for (int kc = 0; kc < kb_n; ++kc) {
                const half* ab = Ap + ((size_t)(tr * kb_n + kc) * 2) * 128;
                const half* bb = Bp + ((size_t)(kc * tc_n + tc) * 2) * 128;
                esimd::simd<half, 128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> a1(ab + 128, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b0(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half, 128> b1(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, a1);
            }
            float* out = C + (size_t)(tr * TS) * N + tc * TS;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<float, 8> r00 = c00.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r01 = c01.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r10 = c10.template select<8, 1>(r * 8);
                esimd::simd<float, 8> r11 = c11.template select<8, 1>(r * 8);
                r00.copy_to(out + (size_t)r * N);       r01.copy_to(out + (size_t)r * N + 8);
                r10.copy_to(out + (size_t)(8 + r) * N); r11.copy_to(out + (size_t)(8 + r) * N + 8);
            }
        });
    });
}

} // namespace f16v1
