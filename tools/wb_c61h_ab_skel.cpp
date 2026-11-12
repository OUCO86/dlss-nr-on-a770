// C61h: extended host-side bit-exactness arm -- real gir shape groups x real flag combinations.
// Shapes come from tools/rt_per_closure.csv (the gir decision table):
//   (K,N,M) = (64,64,32640) (128,128,8160) (256,256,2040) (512,512,640) | (1024,1024,192) (4096,1024,192)
// Mp = ceil(M/128)*128.  Only the K<=512 groups are reachable by the BK=64 predicate; the K>512
// groups are marked N/A (they fall back to the shipped pair in the engine).
// Per shape: CHECK 1 = pack_a64 vs pack_a permutation; CHECK 2 = s8v8 vs s8v8b, per flag combo,
// printing the first bad element's (row,col) and which kb/kc/wi stripe it belongs to.
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
    struct Sh { int K, N, M; };
    const Sh SH[6] = { {64,64,32640}, {128,128,8160}, {256,256,2040}, {512,512,640},
                       {1024,1024,192}, {4096,1024,192} };
    std::mt19937 rng(20261112u);
    int tot_bad = 0;
    for (int si = 0; si < 6; ++si) {
        int K = SH[si].K, N = SH[si].N, M = SH[si].M;
        int Mp = ((M + 127) / 128) * 128;
        bool reachable = (K % 64 == 0 && K <= 512);
        printf("\n=== shape (K=%d,N=%d,M=%d,Mp=%d)  BK64 reachable=%s ===\n", K, N, M, Mp,
               reachable ? "YES" : "no (N/A in engine)");
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
              *cs = sycl::malloc_device<float>(N, q), *skp = sycl::malloc_device<float>((size_t)Mp * N, q);
        void *C1 = sycl::malloc_device<unsigned char>((size_t)Mp * N * 4, q);
        void *C2 = sycl::malloc_device<unsigned char>((size_t)Mp * N * 4, q);
        q.memcpy(dA, hA.data(), (size_t)M * K); q.memcpy(dB, hB.data(), (size_t)N * K);
        q.memcpy(as, has.data(), (size_t)Mp * 4); q.memcpy(bs, hbs.data(), (size_t)N * 4);
        q.memcpy(cs, hcos.data(), (size_t)N * 4); q.memcpy(skp, hskip.data(), (size_t)Mp * N * 4);
        q.wait();
        packdev::pack_a(q, dA, dA32, M, Mp, K);
        packdev::pack_a64(q, dA, dA64, M, Mp, K);
        packdev::pack_b(q, dB, dBp, N, K);
        q.wait();

        // ---- CHECK 1: pack_a64 == permute(pack_a)? ----
        {
            std::vector<int8_t> p32((size_t)Mp * K), p64((size_t)Mp * K);
            q.memcpy(p32.data(), dA32, (size_t)Mp * K);
            q.memcpy(p64.data(), dA64, (size_t)Mp * K);
            q.wait();
            int bad = 0, fb = -1;
            int kb64n = K / 64, kb32n = K / 32;
            for (int w = 0; w < Mp / 128; ++w)
                for (int kb = 0; kb < kb64n; ++kb)
                    for (int wi = 0; wi < 8; ++wi)
                        for (int kc = 0; kc < 2; ++kc)
                            for (int row = 0; row < 16; ++row)
                                for (int k = 0; k < 32; ++k) {
                                    size_t d64 = (((size_t)w * kb64n + kb) * 8 + wi) * 1024 + kc * 512 + row * 32 + k;
                                    size_t d32 = (((size_t)w * kb32n + (kb * 2 + kc)) * 8 + wi) * 512 + row * 32 + k;
                                    if (p64[d64] != p32[d32]) { if (fb < 0) fb = (int)d64; ++bad; }
                                }
            printf("  CHECK1 packer permutation: mismatched bytes = %d", bad);
            if (fb >= 0) printf("   first d64=%d -> w=%d kb=%d wi=%d kc=%d row=%d k=%d", fb,
                                (fb / 8192), ((fb / 1024) % (K / 64)), ((fb / 1024) % 8),
                                ((fb / 512) % 2), ((fb % 512) / 32), fb % 32);
            printf("\n");
            if (bad) tot_bad++;
        }
        if (!reachable) { printf("  CHECK2 skipped: this shape falls back to the shipped pair in the engine\n"); }
        else {
            // ---- CHECK 2: the two kernels, over the full flag grid ----
            size_t cells = (size_t)Mp * N;
            std::vector<unsigned char> c1(cells * 4), c2(cells * 4);
            for (unsigned epi = 0; epi < 4; ++epi)
              for (int hs = 0; hs < 2; ++hs)
                for (int nar = 0; nar < 2; ++nar) {
                    s8v8::gemm_b_res(q, dA32, dBp, C1, as, bs, (const void*)skp, cs, M, Mp, N, K,
                                     (bool)nar, (bool)hs, epi);
                    s8v8b::gemm_b_res(q, dA64, dBp, C2, as, bs, (const void*)skp, cs, M, Mp, N, K,
                                      (bool)nar, (bool)hs, epi);
                    q.wait();
                    size_t bytes = cells * (nar ? 2u : 4u);
                    q.memcpy(c1.data(), C1, bytes);
                    q.memcpy(c2.data(), C2, bytes);
                    q.wait();
                    size_t esz = nar ? 2u : 4u;
                    size_t nbad = 0, fi = 0;
                    for (size_t i = 0; i < cells; ++i) {
                        if (std::memcmp(&c1[i * esz], &c2[i * esz], esz) != 0) {
                            if (!nbad) fi = i;
                            ++nbad;
                        }
                    }
                    if (nbad) {
                        size_t row = fi / N, col = fi % N;
                        printf("  CHECK2 epi=%u half_skip=%d narrow=%d: BAD %zu/%zu  first (row=%zu,col=%zu)"
                               "  wi_row=%zu wi_col=%zu\n", epi, hs, nar, nbad, cells, row, col,
                               (row % 128) / 16, (col % 64) / 16);
                        tot_bad++;
                    } else {
                        printf("  CHECK2 epi=%u half_skip=%d narrow=%d: bit-exact (%zu elements)\n",
                               epi, hs, nar, cells);
                    }
                }
        }
        sycl::free(dA, q); sycl::free(dB, q); sycl::free(dA32, q); sycl::free(dA64, q);
        sycl::free(dBp, q); sycl::free(as, q); sycl::free(bs, q); sycl::free(cs, q);
        sycl::free(skp, q); sycl::free(C1, q); sycl::free(C2, q);
    }
    printf("\nSUMMARY: failing checks = %d\n", tot_bad);
    return 0;
}
