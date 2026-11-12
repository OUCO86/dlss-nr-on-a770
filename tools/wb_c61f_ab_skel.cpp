// C61f: host-side bit-exactness arm -- s8v8::gemm_b_res (BK=32) vs s8v8b::gemm_b_res (BK=64),
// same logical inputs, packed by pack_a / pack_a64 respectively.  Two independent checks:
//   CHECK 1 (packer): is pack_a64 a correct permutation of pack_a?  (pure byte identity)
//   CHECK 2 (kernel): is C(f32) bit-identical?  first bad (row,col) + per-K report.
// Diff != 0 kills the variant -- this is the same discipline bench_s8v8_tile.cpp states.
#define LC_TICK() do {} while (0)
#define LC_ADD(field, v) do {} while (0)
#include <sycl/sycl.hpp>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <random>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"

int main() {
    sycl::queue q{sycl::property_list{sycl::property::queue::enable_profiling(),
                                      sycl::property::queue::in_order{}}};
    printf("device: %s\n", q.get_device().get_info<sycl::info::device::name>().c_str());
    const int M = 256, Mp = 256, N = 64;
    const int KS[3] = {64, 128, 512};
    std::mt19937 rng(12345);
    for (int ki = 0; ki < 3; ++ki) {
        int K = KS[ki];
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)N * K);
        for (auto& v : hA) v = (int8_t)(rng() % 251 - 125);
        for (auto& v : hB) v = (int8_t)(rng() % 251 - 125);
        std::vector<float> has(Mp), hbs(N), hcos(N), hskip((size_t)Mp * N);
        for (auto& v : has) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hbs) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hcos) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hskip) v = 0.01f * (float)((int)(rng() % 2000) - 1000);

        int8_t *dA = sycl::malloc_device<int8_t>((size_t)M * K, q);
        int8_t *dB = sycl::malloc_device<int8_t>((size_t)N * K, q);
        int8_t *dA32 = sycl::malloc_device<int8_t>((size_t)Mp * K, q);
        int8_t *dA64 = sycl::malloc_device<int8_t>((size_t)Mp * K, q);
        int8_t *dBp = sycl::malloc_device<int8_t>((size_t)N * K, q);
        float *as = sycl::malloc_device<float>(Mp, q), *bs = sycl::malloc_device<float>(N, q),
              *cs = sycl::malloc_device<float>(N, q);
        float *skp = sycl::malloc_device<float>((size_t)Mp * N, q);
        float *C1 = sycl::malloc_device<float>((size_t)Mp * N, q);
        float *C2 = sycl::malloc_device<float>((size_t)Mp * N, q);
        q.memcpy(dA, hA.data(), (size_t)M * K);
        q.memcpy(dB, hB.data(), (size_t)N * K);
        q.memcpy(as, has.data(), (size_t)Mp * 4);
        q.memcpy(bs, hbs.data(), (size_t)N * 4);
        q.memcpy(cs, hcos.data(), (size_t)N * 4);
        q.memcpy(skp, hskip.data(), (size_t)Mp * N * 4);
        q.wait();

        packdev::pack_a(q, dA, dA32, M, Mp, K);
        packdev::pack_a64(q, dA, dA64, M, Mp, K);
        packdev::pack_b(q, dB, dBp, N, K);
        q.wait();

        // ---- CHECK 1: pack_a64 == permute(pack_a) ? ----
        std::vector<int8_t> p32((size_t)Mp * K), p64((size_t)Mp * K);
        q.memcpy(p32.data(), dA32, (size_t)Mp * K);
        q.memcpy(p64.data(), dA64, (size_t)Mp * K);
        q.wait();
        int bad = 0, firstbad = -1;
        int kb64n = K / 64, kb32n = K / 32;
        for (int w = 0; w < Mp / 128; ++w)
            for (int kb = 0; kb < kb64n; ++kb)
                for (int wi = 0; wi < 8; ++wi)
                    for (int kc = 0; kc < 2; ++kc)
                        for (int row = 0; row < 16; ++row)
                            for (int k = 0; k < 32; ++k) {
                                size_t d64 = (((size_t)w * kb64n + kb) * 8 + wi) * 1024 + kc * 512 + row * 32 + k;
                                size_t d32 = (((size_t)w * kb32n + (kb * 2 + kc)) * 8 + wi) * 512 + row * 32 + k;
                                if (p64[d64] != p32[d32]) { if (!bad) firstbad = (int)d64; ++bad; }
                            }
        printf("\n=== K=%d  packer check: mismatched operand bytes = %d", K, bad);
        if (bad) printf("   first bad d64=%d (row=%d)", firstbad, (firstbad / 4) / 4);
        printf("\n");

        // ---- CHECK 2: the two kernels' C ----
        s8v8::gemm_b_res(q, dA32, dBp, (void*)C1, as, bs, (const void*)skp, cs, M, Mp, N, K,
                         false, false, 0u);
        s8v8b::gemm_b_res(q, dA64, dBp, (void*)C2, as, bs, (const void*)skp, cs, M, Mp, N, K,
                         false, false, 0u);
        q.wait();
        std::vector<float> c1((size_t)Mp * N), c2((size_t)Mp * N);
        q.memcpy(c1.data(), C1, (size_t)Mp * N * 4);
        q.memcpy(c2.data(), C2, (size_t)Mp * N * 4);
        q.wait();
        int nbad = 0, fr = -1, fc = -1;
        for (int r = 0; r < Mp; ++r)
            for (int c = 0; c < N; ++c) {
                size_t i = (size_t)r * N + c;
                if (std::memcmp(&c1[i], &c2[i], 4) != 0) {
                    if (!nbad) { fr = r; fc = c; }
                    ++nbad;
                }
            }
        printf("    kernel check: C elements differing = %d / %d", nbad, Mp * N);
        if (nbad) printf("   first bad (row,col)=(%d,%d)  base=%.9g new=%.9g",
                         fr, fc, (double)c1[(size_t)fr * N + fc], (double)c2[(size_t)fr * N + fc]);
        printf("\n");
        sycl::free(dA, q); sycl::free(dB, q); sycl::free(dA32, q); sycl::free(dA64, q);
        sycl::free(dBp, q); sycl::free(as, q); sycl::free(bs, q); sycl::free(cs, q);
        sycl::free(skp, q); sycl::free(C1, q); sycl::free(C2, q);
    }
    return 0;
}
