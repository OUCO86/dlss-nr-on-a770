// esimd_gemm_s8_v1.cpp — full-ladder form (seniors' step 16-18 structure) for s8:
// A host-packed, A+B staged through SLM double-buffered, one barrier per K block.
//
// Two self-corrections baked in (both were MY errors, per user 2026-10-16 17:47):
//  (1) timing is DEVICE EVENT TIME (command_end - command_start), the seniors'
//      protocol — wall-clock on 0.1ms kernels is dominated by launch overhead and
//      made the narrow shapes look worse than they are;
//  (2) //DSTORE_INT8 switches the C store from int32 to truncated int8 (values
//      WRONG, speed-only) to isolate the write-amplification variable: a
//      32640x64x64 tile writes 8 MB of int32 but only 2 MB of int8. If narrow
//      shapes jump ~3x, the "narrow is dead" reading was my int32 output, and the
//      fused dequant->requant->int8 epilogue (the rewrite's core move) is the fix.
//
// s8 geometry: SystolicDepth=8, OpsPerChannel=4 => one dpas _K=32, so BK=32 is
// ONE dpas per (a,b) pair (bf16 needed two). BM=128 BN=64 BK=32, 32 work-items
// (8 wi_rows x 4 wi_cols), each 16x16 C tile, int32 accumulators (s8 MUST
// accumulate int32 — a float accumulator compiles but the hardware returns NaN).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <vector>
#include <array>

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 128, BN = 64, BK = 32, NT = 32;
static const int SLM_A = BM * BK;          // 4096 bytes
static const int SLM_B = BK * BN;          // 2048 bytes
static const int SLM_B_BASE = 2 * SLM_A;   // double-buffered A first
static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;  // 12 KB, under the 32 KB cliff

static void pack_a(const int8_t* A, int8_t* Ap, int M, int K) {
    int wgr = M / BM, kb_n = K / BK;
    for (int w = 0; w < wgr; ++w)
        for (int kb = 0; kb < kb_n; ++kb)
            for (int wi = 0; wi < 8; ++wi)
                for (int row = 0; row < 16; ++row)
                    for (int k = 0; k < 32; ++k)
                        Ap[(((size_t)(w * kb_n + kb) * 8 + wi) * 512) + row * 32 + k] =
                            A[(size_t)(w * BM + wi * 16 + row) * K + kb * BK + k];
}
static void pack_b(const int8_t* B, int8_t* Bp, int K, int N) {
    for (int kk32 = 0; kk32 < K / 32; ++kk32)
        for (int ntile = 0; ntile < N / 8; ++ntile)
            for (int kq = 0; kq < 8; ++kq)
                for (int nl = 0; nl < 8; ++nl)
                    for (int j = 0; j < 4; ++j)
                        Bp[(((size_t)kk32 * (N / 8) + ntile) * 64 + kq * 8 + nl) * 4 + j] =
                            B[(size_t)(kk32 * 32 + kq * 4 + j) * N + (ntile * 8 + nl)];
}

static event gemm_s8(queue& q, const int8_t* Ap, const int8_t* Bp,
                     int32_t* C32, int8_t* C8, int M, int N, int K) {
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
                // B: pack_b is kk32-major — a kb block spans ALL N (N*32 bytes);
                // the wg_col's 8 ntile are contiguous only WITHIN the block.
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
#ifdef STORE_INT8
                // speed-only: truncate int32 -> low byte (values WRONG, traffic right).
                esimd::simd<int8_t, 64> rb0 = row0.bit_cast_view<int8_t>();
                esimd::simd<int8_t, 64> rb1 = row1.bit_cast_view<int8_t>();
                esimd::simd<int8_t, 16> ob0 = rb0.select<16, 4>(0);
                esimd::simd<int8_t, 16> ob1 = rb1.select<16, 4>(0);
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + r) * N + gc, ob0, esimd::overaligned_tag<16>{});
                esimd::block_store<int8_t, 16>(C8 + (size_t)(gr + 8 + r) * N + gc, ob1, esimd::overaligned_tag<16>{});
#else
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(C32 + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
#endif
            }
        });
    });
}

static double dev_ms(event& e) {
    auto s = e.get_profiling_info<info::event_profiling::command_start>();
    auto t = e.get_profiling_info<info::event_profiling::command_end>();
    return (double)(t - s) / 1e6;
}

int main() {
    device dev;
    for (auto& dd : device::get_devices(info::device_type::gpu))
        if (dd.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = dd; break; }
    queue q(dev, property::queue::enable_profiling{});
    std::printf("device: %s   store=%s\n", dev.get_info<info::device::name>().c_str(),
#ifdef STORE_INT8
                "int8(truncated,speed-only)");
#else
                "int32");
#endif

    // correctness only in the int32 build
#ifndef STORE_INT8
    {
        int M = 256, N = 256, K = 256;
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hAp((size_t)M * K), hBp((size_t)K * N);
        std::vector<int32_t> hC((size_t)M * N, 0);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_a(hA.data(), hAp.data(), M, K); pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hAp.size(), q), *dB = malloc_device<int8_t>(hBp.size(), q);
        int32_t* dC = malloc_device<int32_t>(hC.size(), q);
        int8_t* dC8 = malloc_device<int8_t>(hC.size(), q);
        q.memcpy(dA, hAp.data(), hAp.size()); q.memcpy(dB, hBp.data(), hBp.size()).wait();
        gemm_s8(q, dA, dB, dC, dC8, M, N, K).wait();
        q.memcpy(hC.data(), dC, hC.size() * sizeof(int32_t)).wait();
        long long bad = 0;
        for (int m = 0; m < M; ++m) for (int n = 0; n < N; ++n) {
            int32_t ref = 0;
            for (int k = 0; k < K; ++k) ref += (int32_t)hA[(size_t)m * K + k] * hB[(size_t)k * N + n];
            if (hC[(size_t)m * N + n] != ref) ++bad;
        }
        std::printf("correctness 256x256x256: %s (%lld/%d)\n", bad ? "FAIL" : "PASS", bad, M * N);
        if (bad) return 1;
    }
#endif
    for (auto cfg : std::vector<std::array<int, 3>>{
             {32640, 64, 64}, {9216, 128, 128}, {2560, 256, 256}, {768, 512, 512},
             {640, 512, 512}, {8192, 1024, 1024}, {4096, 4096, 4096}}) {
        int M = cfg[0], N = cfg[1], K = cfg[2];
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hAp((size_t)M * K), hBp((size_t)K * N);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_a(hA.data(), hAp.data(), M, K); pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hAp.size(), q), *dB = malloc_device<int8_t>(hBp.size(), q);
        int32_t* dC = malloc_device<int32_t>((size_t)M * N, q);
        int8_t* dC8 = malloc_device<int8_t>((size_t)M * N, q);
        q.memcpy(dA, hAp.data(), hAp.size()); q.memcpy(dB, hBp.data(), hBp.size()).wait();
        gemm_s8(q, dA, dB, dC, dC8, M, N, K).wait();   // warm
        double best = 1e18;
        for (int r = 0; r < 5; ++r) {
            event e = gemm_s8(q, dA, dB, dC, dC8, M, N, K);
            e.wait();
            double ms = dev_ms(e);
            if (ms < best) best = ms;
        }
        double tops = 2.0 * M * N * K / (best / 1e3) / 1e12;
        std::printf("dev-time %dx%dx%d: %.4f ms  %.1f TOPS  (coopmat 24.8: %.2fx)\n",
                    M, N, K, best, tops, tops / 24.8);
        free(dA, q); free(dB, q); free(dC, q); free(dC8, q);
    }
    std::printf("V1_DONE\n");
    return 0;
}
