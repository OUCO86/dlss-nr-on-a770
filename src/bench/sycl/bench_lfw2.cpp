// bench_lfw.cpp -- B5-5b SLICE 2 instrument (WG = one (window,head) batch -- the wa_res parallelism class) (the wa_res promotion discipline: the
// gate proves the geometry BEFORE the recorder path is trusted). Reference = the
// two PROMOTED kernels back-to-back: qres::gemm_qkv_res (the qkv fold, NT=32) ->
// planes Q/K/V, then wares::launch_wa_res (the attention resident block) -> Out.
// The lfw2 kernel must reproduce BOTH: (a) its phase-1 plane scatter byte-equal to
// qres's planes (isolates the NEW NT=16 qkv geometry + the v5a tail reuse), and
// (b) its Out byte-equal to the wa_res Out (isolates the tile-direct wiring +
// phase-2). BISECT diffs: planes, then Out. Shape: C=64, heads=2, tokens=64,
// windows = the frame's 510/558 (the guard set).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <random>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "gemm_f16_v2_kernel.hpp"
#include "window_block_mega.hpp"
#include "window_block_v2.hpp"
#include "window_block_v3.hpp"
#include "qkv_resident.hpp"
#include "wa_res_kernel.hpp"
#include "lfw2_res_kernel.hpp"
#include "pack_device.hpp"
#include "softmax_kernel.hpp"

using namespace sycl;

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    queue q(dev);
    constexpr unsigned C = 64u, heads = 2u, tokens = 64u, NH = 192u;
    for (unsigned windows : {510u, 558u}) {
        unsigned M = windows * tokens, Mp = ((M + 127u) / 128u) * 128u;
        std::mt19937 rng(7);
        std::uniform_int_distribution<int> di(-127, 127);
        std::uniform_real_distribution<float> df(-4.f, 4.f), dsc(0.001f, 0.02f);
        // packed operands DIRECTLY (both kernels consume the pack maps; generate the
        // PACK bytes randomly = the maps are inputs, no pack bugs can hide)
        std::vector<int8_t> hAp((size_t)Mp * C), hBp((size_t)NH * C);
        for (auto& x : hAp) x = (int8_t)di(rng);
        for (auto& x : hBp) x = (int8_t)di(rng);
        // rows >= M in the pack: zero (the pack_a pad form) so the tail's clamp is moot
        for (unsigned r = M; r < Mp; ++r)
            for (unsigned kb = 0; kb < C / 32u; ++kb)
                for (unsigned wi = 0; wi < 8; ++wi)
                    for (unsigned b = 0; b < 512; ++b)
                        hAp[(size_t)((r / 128u * (C / 32u) + kb) * 8 + (r % 128u) / 16u) * 512 + (r % 16u) * 32u + b % 32u] = 0;
        std::vector<float> hAS(Mp), hBS(NH), hQS(heads), hBias((size_t)heads * 4096u);
        for (auto& x : hAS) x = dsc(rng);
        for (auto& x : hBS) x = dsc(rng);
        for (auto& x : hQS) x = dsc(rng) * 4.f;
        for (auto& x : hBias) x = df(rng) * 0.5f;
        int8_t *dAp = malloc_device<int8_t>(hAp.size(), q), *dBp = malloc_device<int8_t>(hBp.size(), q);
        float *dAS = malloc_device<float>(Mp, q), *dBS = malloc_device<float>(NH, q),
              *dQS = malloc_device<float>(heads, q), *dBias = malloc_device<float>(hBias.size(), q);
        q.memcpy(dAp, hAp.data(), hAp.size()); q.memcpy(dBp, hBp.data(), hBp.size());
        q.memcpy(dAS, hAS.data(), Mp * 4); q.memcpy(dBS, hBS.data(), NH * 4);
        q.memcpy(dQS, hQS.data(), heads * 4); q.memcpy(dBias, hBias.data(), hBias.size() * 4);
        size_t npl = (size_t)M * C;   // per-plane halves
        sycl::half *Q1 = malloc_device<sycl::half>(npl, q), *K1 = malloc_device<sycl::half>(npl, q), *V1 = malloc_device<sycl::half>(npl, q);
        sycl::half *Q2 = malloc_device<sycl::half>(npl, q), *K2 = malloc_device<sycl::half>(npl, q), *V2 = malloc_device<sycl::half>(npl, q);
        q.memset(Q1, 0, npl * 2); q.memset(K1, 0, npl * 2); q.memset(V1, 0, npl * 2);
        q.memset(Q2, 0, npl * 2); q.memset(K2, 0, npl * 2); q.memset(V2, 0, npl * 2);
        size_t nout = (size_t)windows * 64u * heads * 32u;
        sycl::half *OutRef = malloc_device<sycl::half>(nout, q), *OutLfw = malloc_device<sycl::half>(nout, q);
        q.memset(OutRef, 0, nout * 2); q.memset(OutLfw, 0, nout * 2);
        // ---- reference: qres planes, then wa_res (RAW operands = the planes) ----
        qres::gemm_qkv_res(q, dAp, dBp, Q1, K1, V1, dAS, dBS, dQS, (int)M, (int)Mp, (int)C, (int)NH, (int)heads, (int)tokens, false, nullptr).wait();
        wares::launch_wa_res(q, Q1, K1, V1, nullptr, dBias, OutRef, windows * heads, heads, true).wait();
        // ---- lfw: planes + Out in ONE launch ----
        lfw2::launch_lfw2(q, dAp, dBp, OutLfw, dAS, dBS, dQS, dBias, windows, heads, Q2, K2, V2).wait();
        auto diffp = [&](sycl::half* a, sycl::half* b, size_t n, const char* lab) {
            std::vector<sycl::half> ha(n), hb(n);
            q.memcpy(ha.data(), a, n * 2).wait(); q.memcpy(hb.data(), b, n * 2).wait();
            size_t d = 0; size_t first = (size_t)-1;
            for (size_t i = 0; i < n; ++i) {
                unsigned short ua, ub; memcpy(&ua, &ha[i], 2); memcpy(&ub, &hb[i], 2);
                if (ua != ub) { ++d; if (first == (size_t)-1) first = i; }
            }
            printf("lfw2 vs ref %s: diff %zu / %zu %s\n", lab, d, n, d ? "NOT-EXACT" : "EXACT");
            if (d && first != (size_t)-1) {
                float fa, fb; { sycl::half h = ha[first]; fa = (float)h; } { sycl::half h = hb[first]; fb = (float)h; }
                printf("   first idx %zu (row %zu, col %zu): got %.6g want %.6g\n",
                       first, first / C, first % C, fa, fb);
            }
        };
        diffp(Q2, Q1, npl, "Q-plane");
        diffp(K2, K1, npl, "K-plane");
        diffp(V2, V1, npl, "V-plane");
        diffp(OutLfw, OutRef, nout, "Out");
        printf("== windows=%u done ==\n", windows);
    }
    return 0;
}
