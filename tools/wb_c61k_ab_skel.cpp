// C61k: the missing cell -- the FUSED packer path, which the engine actually uses (C61i's
// runtime table: all 96 gir legs have fused_r=1 => pack_a_fused64).  Never compared before.
// CHECK1b: pack_a_fused64_k<K> vs pack_a_fused  -> byte permutation identity
// CHECK2b: (pack_a_fused + s8v8::gemm_b_res) vs (pack_a_fused64 + s8v8b::gemm_b_res) -> per element
// Shapes = the two the runtime really runs through BK64.
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
    struct Sh { int K, N, M, Mp; };
    const Sh S[2] = { {256, 256, 2040, 2048}, {512, 512, 640, 640} };
    std::mt19937 rng(61122u);
    int fails = 0;
    for (int si = 0; si < 2; ++si) {
        int K = S[si].K, N = S[si].N, M = S[si].M, Mp = S[si].Mp;
        printf("\n=== fused-packer shape (K=%d,N=%d,M=%d,Mp=%d) ===\n", K, N, M, Mp);
        // f16 activation source (values chosen so the e4m3-ish quantize is exercised: +-127 range)
        std::vector<sycl::half> hA16((size_t)Mp * K);
        for (size_t i = 0; i < hA16.size(); ++i)
            hA16[i] = sycl::half(((float)(rng() % 20000) - 10000.0f) / 78.0f);
        std::vector<int8_t> hB((size_t)N * K);
        for (auto& v : hB) v = (int8_t)(rng() % 251 - 125);
        std::vector<float> has(Mp), hbs(N), hcos(N), hskip((size_t)Mp * N);
        for (auto& v : has) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hbs) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hcos) v = 0.001f * (float)(rng() % 2000 + 1);
        for (auto& v : hskip) v = 0.01f * (float)((int)(rng() % 2000) - 1000);

        sycl::half* a16 = sycl::malloc_device<sycl::half>((size_t)Mp * K, q);
        int8_t* dB = sycl::malloc_device<int8_t>((size_t)N * K, q);
        int8_t* dA32 = sycl::malloc_device<int8_t>((size_t)Mp * K, q);
        int8_t* dA64 = sycl::malloc_device<int8_t>((size_t)Mp * K, q);
        int8_t* dBp = sycl::malloc_device<int8_t>((size_t)N * K, q);
        float* sc32 = sycl::malloc_device<float>(Mp, q);
        float* sc64 = sycl::malloc_device<float>(Mp, q);
        float* as = sycl::malloc_device<float>(Mp, q);
        float* bs = sycl::malloc_device<float>(N, q);
        float* cs = sycl::malloc_device<float>(N, q);
        float* skp = sycl::malloc_device<float>((size_t)Mp * N, q);
        void* C1 = sycl::malloc_device<unsigned char>((size_t)Mp * N * 4, q);
        void* C2 = sycl::malloc_device<unsigned char>((size_t)Mp * N * 4, q);
        q.memcpy(a16, hA16.data(), (size_t)Mp * K * 2);
        q.memcpy(dB, hB.data(), (size_t)N * K);
        q.memcpy(as, has.data(), (size_t)Mp * 4);
        q.memcpy(bs, hbs.data(), (size_t)N * 4);
        q.memcpy(cs, hcos.data(), (size_t)N * 4);
        q.memcpy(skp, hskip.data(), (size_t)Mp * N * 4);
        q.wait();

        packdev::pack_a_fused(q, a16, dA32, sc32, M, Mp, K);
        packdev::pack_a_fused64(q, a16, dA64, sc64, M, Mp, K);
        packdev::pack_b(q, dB, dBp, N, K);
        q.wait();

        // ---- CHECK 1b: the two fused packers agree byte-for-byte under the BK=64 permutation ----
        {
            std::vector<int8_t> p32((size_t)Mp * K), p64((size_t)Mp * K);
            std::vector<float> s32(Mp), s64(Mp);
            q.memcpy(p32.data(), dA32, (size_t)Mp * K);
            q.memcpy(p64.data(), dA64, (size_t)Mp * K);
            q.memcpy(s32.data(), sc32, (size_t)Mp * 4);
            q.memcpy(s64.data(), sc64, (size_t)Mp * 4);
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
            int sbad = 0;
            for (int i = 0; i < Mp; ++i) if (std::memcmp(&s32[i], &s64[i], 4) != 0) ++sbad;
            printf("  CHECK1b fused-packer bytes: mismatched = %d", bad);
            if (fb >= 0) printf("   first d64=%d (w=%d kb=%d wi=%d kc=%d row=%d k=%d, val32=%d val64=%d)",
                                fb, fb / 8192, ((fb / 1024) % kb64n), ((fb / 1024) % 8),
                                ((fb / 512) % 2), ((fb % 512) / 32), fb % 32,
                                (int)p32[((size_t)((fb / 8192) * kb32n + (((fb / 1024) % kb64n) * 2 + ((fb / 512) % 2))) * 8 + ((fb / 1024) % 8)) * 512 + (fb % 512)],
                                (int)p64[fb]);
            printf("\n  CHECK1b scales: mismatched rows = %d\n", sbad);
            if (bad || sbad) fails++;
        }
        // ---- CHECK 2b: packer+reader pairs, full flag grid ----
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
                size_t bytes = cells * (nar ? 2u : 4u), esz = nar ? 2u : 4u;
                q.memcpy(c1.data(), C1, bytes);
                q.memcpy(c2.data(), C2, bytes);
                q.wait();
                size_t nbad = 0, fi = 0;
                for (size_t i = 0; i < cells; ++i)
                    if (std::memcmp(&c1[i * esz], &c2[i * esz], esz) != 0) { if (!nbad) fi = i; ++nbad; }
                if (nbad) {
                    printf("  CHECK2b epi=%u hs=%d nar=%d: BAD %zu/%zu  first (row=%zu,col=%zu) wi_row=%zu wi_col=%zu\n",
                           epi, hs, nar, nbad, cells, fi / N, fi % N, (fi / N % 128) / 16, (fi % 64) / 16);
                    fails++;
                }
            }
        printf("  CHECK2b: 16 flag combos done for this shape (only BAD lines printed)\n");
        sycl::free(a16, q); sycl::free(dB, q); sycl::free(dA32, q); sycl::free(dA64, q);
        sycl::free(dBp, q); sycl::free(sc32, q); sycl::free(sc64, q); sycl::free(as, q);
        sycl::free(bs, q); sycl::free(cs, q); sycl::free(skp, q); sycl::free(C1, q); sycl::free(C2, q);
    }
    printf("\nSUMMARY C61k: failing checks = %d\n", fails);
    return 0;
}
