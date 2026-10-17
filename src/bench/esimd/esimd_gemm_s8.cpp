// esimd_gemm_s8.cpp — the rewrite's first real GEMM: ESIMD s8 DPAS, ladder step
// 14 form (dpas BK=32, per-thread 16x16 C tile), operands direct from global in
// v0 (no SLM relay yet — correctness and the first sustainable-TOPS number first;
// the 4-buffer B pipeline is the next iteration).
//
// s8 DPAS geometry (verified against dpas.hpp static_asserts, 2026-10-16):
//   esimd::xmx::dpas<SystolicDepth=8, RepeatCount=8, int32>(C,B,A)
//   OpsPerChannel=4 => _K=32, _N=8; A=simd<int8,256> (_M*_K row-major),
//   B=simd<int8,256> (_K*_N VNNI: each n channel's 32 k-bytes contiguous),
//   C=simd<int32,64>.  s8 accumulates in int32, NOT float: dpas.hpp's integer
//   branch requires result/C types ud/d (a float accumulator compiles but the
//   hardware returns NaN — the bug that cost a run tonight). The seniors' int8
//   GEMM dst is s32 for the same reason; requantize to int8 is the next stage.
//
// B pre-packed on the host (weights are static — packing once outside the timed
// loop is legitimate, same contract as the seniors' oneDNN runs):
//   Bp[((kk/32)*N + n)*32 + kg*4 + k4] = B[(kk/32*32 + kg*4 + k4)*N + n]
//
// Shapes: correctness on 256x256x256 vs an exact int32 CPU reference; speed on
// 8192x1024x1024 (oneDNN's 71.9 TOPS shape) and 4096x4096x4096.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <vector>
#include <array>

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static void pack_b(const int8_t* B, int8_t* Bp, int K, int N) {
    // Hardware VNNI order for the B operand (verified against the seniors'
    // skeleton slm_block_load(offB + (kq*BN + col)*4)): within a K-block of 32,
    // the 8 k-groups (kq=0..7) are OUTER and the columns INNER, and each dword
    // holds 4 consecutive K (s8 OpsPerChannel=4). We pack per 8-column group so
    // each dpas B operand is 256 contiguous bytes:
    //   Bp[((kk32*(N/8) + ntile)*64 + kq*8 + nl)*4 + j] = B[(kk32*32 + kq*4 + j)*N + (ntile*8 + nl)]
    for (int kk32 = 0; kk32 < K / 32; ++kk32)
        for (int ntile = 0; ntile < N / 8; ++ntile)
            for (int kq = 0; kq < 8; ++kq)
                for (int nl = 0; nl < 8; ++nl)
                    for (int j = 0; j < 4; ++j)
                        Bp[(((size_t)kk32 * (N / 8) + ntile) * 64 + kq * 8 + nl) * 4 + j] =
                            B[(size_t)(kk32 * 32 + kq * 4 + j) * N + (ntile * 8 + nl)];
}

static void gemm_s8(queue& q, const int8_t* A, const int8_t* Bp, int32_t* C,
                    int M, int N, int K) {
    int tiles = (M / 16) * (N / 16);
    q.parallel_for(range(tiles), [=](item<1> it) SYCL_ESIMD_KERNEL {
        int gid = (int)it.get_id(0);
        int NB = N / 16;
        int m0 = (gid / NB) * 16, n0 = (gid % NB) * 16;
        esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
        for (int kk = 0; kk < K; kk += 32) {
            esimd::simd<int8_t, 256> a0, a1;
            for (int r = 0; r < 8; ++r) {
                a0.select<32, 1>(r * 32) = esimd::block_load<int8_t, 32>(
                    A + (size_t)(m0 + r) * K + kk, esimd::overaligned_tag<16>{});
                a1.select<32, 1>(r * 32) = esimd::block_load<int8_t, 32>(
                    A + (size_t)(m0 + 8 + r) * K + kk, esimd::overaligned_tag<16>{});
            }
            // B: each 8-column group (ntile=n0/8) is 256 contiguous bytes at
            // ((kk/32)*(N/8) + ntile)*256, matching pack_b's layout.
            size_t bbase = (size_t)(kk / 32) * (N / 8);
            esimd::simd<int8_t, 256> b0 = esimd::block_load<int8_t, 256>(
                Bp + (bbase + (size_t)(n0 / 8)) * 256, esimd::overaligned_tag<16>{});
            esimd::simd<int8_t, 256> b1 = esimd::block_load<int8_t, 256>(
                Bp + (bbase + (size_t)(n0 / 8) + 1) * 256, esimd::overaligned_tag<16>{});
            c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
            c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
            c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
            c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
        }
        // store C in 64-byte rows (two 16-int rows per accumulator pair), the
        // seniors' code-snippets.md:100-109 form: view=view assign, one block_store.
        for (int r = 0; r < 8; ++r) {
            esimd::simd<int32_t, 16> row0;
            row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
            row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
            esimd::block_store<int32_t, 16>(C + (size_t)(m0 + r) * N + n0, row0,
                                            esimd::overaligned_tag<16>{});
            esimd::simd<int32_t, 16> row1;
            row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
            row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
            esimd::block_store<int32_t, 16>(C + (size_t)(m0 + 8 + r) * N + n0, row1,
                                            esimd::overaligned_tag<16>{});
        }
    }).wait();
}

int main() {
    device dev;
    for (auto& dd : device::get_devices(info::device_type::gpu))
        if (dd.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = dd; break; }
    std::printf("device: %s\n", dev.get_info<info::device::name>().c_str());
    queue q(dev);

    // ---- correctness: 256x256x256 vs exact int32 CPU reference ----
    {
        int M = 256, N = 256, K = 256;
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hBp((size_t)K * N);
        std::vector<int32_t> hC((size_t)M * N, 0);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hA.size(), q), *dBp = malloc_device<int8_t>(hBp.size(), q);
        int32_t* dC = malloc_device<int32_t>(hC.size(), q);
        q.memcpy(dA, hA.data(), hA.size());
        q.memcpy(dBp, hBp.data(), hBp.size()).wait();
        gemm_s8(q, dA, dBp, dC, M, N, K);
        q.memcpy(hC.data(), dC, hC.size() * sizeof(int32_t)).wait();
        auto refAt = [&](int m, int n) {
            int32_t r = 0;
            for (int k = 0; k < K; ++k) r += (int32_t)hA[(size_t)m * K + k] * hB[(size_t)k * N + n];
            return r;
        };
        long long bad = 0;
        for (int m = 0; m < M; ++m)
            for (int n = 0; n < N; ++n)
                if (hC[(size_t)m * N + n] != refAt(m, n)) ++bad;
        std::printf("correctness 256x256x256: %s (%lld/%d wrong)\n",
                    bad ? "FAIL" : "PASS", bad, M * N);
        std::printf("want 8x8 top-left:\n");
        for (int m = 0; m < 8; ++m) { for (int n = 0; n < 8; ++n) std::printf("%7d", refAt(m, n)); std::printf("\n"); }
        std::printf("got  8x8 top-left:\n");
        for (int m = 0; m < 8; ++m) { for (int n = 0; n < 8; ++n) std::printf("%7d", hC[(size_t)m * N + n]); std::printf("\n"); }
        free(dA, q); free(dBp, q); free(dC, q);
        if (bad) return 1;
    }

    // ---- speed: EVERY major frame GEMM shape (by GFLOP from the ledger) vs the
    // merged ideal shapes.  This is the "swap the engine" per-shape verdict: does
    // ESIMD beat coopmat on the shapes the network actually produces?  All M%16==0,
    // N%16==0, K%32==0.  coopmat reference TOPS from notes/onednn-vs-coopmat.
    for (auto cfg : std::vector<std::array<int, 3>>{
             {192, 4096, 1024}, {640, 512, 512}, {2560, 256, 256}, {960, 512, 512},
             {768, 512, 512}, {192, 1024, 1024}, {32640, 64, 64}, {8640, 128, 128},
             {240, 4096, 1024}, {8192, 1024, 1024}, {4096, 4096, 4096}}) {
        int M = cfg[0], N = cfg[1], K = cfg[2];
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hBp((size_t)K * N);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hA.size(), q), *dBp = malloc_device<int8_t>(hBp.size(), q);
        int32_t* dC = malloc_device<int32_t>((size_t)M * N, q);
        q.memcpy(dA, hA.data(), hA.size());
        q.memcpy(dBp, hBp.data(), hBp.size()).wait();
        gemm_s8(q, dA, dBp, dC, M, N, K);              // warm
        double best = 1e18;
        for (int r = 0; r < 3; ++r) {
            auto t0 = std::chrono::high_resolution_clock::now();
            gemm_s8(q, dA, dBp, dC, M, N, K);
            auto t1 = std::chrono::high_resolution_clock::now();
            double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
            if (ms < best) best = ms;
        }
        double tops = 2.0 * M * N * K / (best / 1e3) / 1e12;
        std::printf("speed %dx%dx%d: %.3f ms  %.1f TOPS  (oneDNN 71.9: %.2fx, coopmat 24.8: %.2fx)\n",
                    M, N, K, best, tops, tops / 71.9, tops / 24.8);
        free(dA, q); free(dBp, q); free(dC, q);
    }
    std::printf("GEMM_S8_DONE\n");
    return 0;
}
