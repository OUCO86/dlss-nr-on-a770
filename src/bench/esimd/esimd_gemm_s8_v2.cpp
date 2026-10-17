// esimd_gemm_s8_v2.cpp — the rewrite's core move: int8 GEMM with a FUSED, CORRECT
// requantize epilogue (dequant -> per-row absmax -> requant -> int8 straight out).
// Eliminates BOTH unhealthy forms at once: the int32 output write-amplification
// (补测五: 9216x128x128 2.3->12.9 TOPS just by going int8) AND the separate
// quantize round-trip (ledger 3.09ms).
//
// Math (derived 2026-10-16): A int8 (+row_scale_A), B int8 (+col_scale_B), acc
// int32.  The requantized output
//   fp[m][n]  = acc[m][n] * col_scale_B[n]
//   rmax[m]   = max_n |fp[m][n]|
//   out[m][n] = clamp(rnd(fp[m][n] * 127/rmax[m]), -127, 127)   (int8)
//   new_scale[m] = rmax[m]/127
// row_scale_A CANCELS — an int8-straight-through chain never needs the input
// activation scale inside the GEMM. That is why the quantize round-trip dies.
//
// wide producer: BN = N (here 128), so one work-group owns whole rows; rmax is a
// per-row reduction across the WI_COLS work-items sharing a row, done with the
// probe-verified slm_atomic fmax (no global round-trip, no cross-WG atomics).
//
// Geometry: BM=64 BN=128 BK=32, 32 work-items = 4 wi_rows x 8 wi_cols, each a
// 16x16 C tile (4 int32 accumulators). dpas BK=32 = one _K=32 step (s8
// OpsPerChannel=4). Primitives verified by probe_api.cpp: hmax->scalar, rnde,
// convert<To>, abs, simd[0], slm_atomic_update<fmax>.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <chrono>
#include <vector>
#include <array>

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static const int BM = 64, BN = 128, BK = 32, NT = 32;
static const int WI_ROWS = BM / 16, WI_COLS = BN / 16;   // 4 x 8 = 32
static const int SLM_A = BM * BK;          // 2048 B per buffer
static const int SLM_B = BK * BN;          // 4096 B per buffer
static const int SLM_AB = 2 * SLM_A + 2 * SLM_B;         // 12288 B
static const int RMAX_BASE = SLM_AB;       // rmax[BM] floats = 256 B
static const int SLM_TOTAL = SLM_AB + BM * 4;            // 12544 B, under 32 KB

static void pack_a(const int8_t* A, int8_t* Ap, int M, int K) {
    int wgr = M / BM, kb_n = K / BK;
    for (int w = 0; w < wgr; ++w)
        for (int kb = 0; kb < kb_n; ++kb)
            for (int wi = 0; wi < WI_ROWS; ++wi)
                for (int row = 0; row < 16; ++row)
                    for (int k = 0; k < 32; ++k)
                        Ap[(((size_t)(w * kb_n + kb) * WI_ROWS + wi) * 512) + row * 32 + k] =
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

static event gemm_s8(queue& q, const int8_t* Ap, const int8_t* Bp, const float* col_scale,
                     int8_t* C8, float* new_scale, int M, int N, int K) {
    int wg = (M / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range(wg * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLM_TOTAL>();
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int NB = N / BN;
            int wg_row = gid / NB, wg_col = gid % NB;
            int wi_row = lid / WI_COLS, wi_col = lid % WI_COLS;
            // zero the rmax array cooperatively (each WI clears slots lid, lid+32)
            esimd::slm_block_store(RMAX_BASE + lid * 4, esimd::simd<float, 1>(0.f), esimd::overaligned_tag<16>{});
            esimd::slm_block_store(RMAX_BASE + (lid + 32) * 4, esimd::simd<float, 1>(0.f), esimd::overaligned_tag<16>{});
            const int8_t* apb = Ap + (size_t)(wg_row * (K / BK)) * WI_ROWS * 512;
            const int8_t* bp = Bp + (size_t)wg_col * (BN / 8) * 256;
            auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                // A block is BM*BK = 64*32 = 2048 B; 32 WI cooperate at 64 B each
                // (NOT 128 — that was v1's BM=128 geometry and corrupted A here).
                esimd::simd<int8_t, 64> av = esimd::block_load<int8_t, 64>(
                    apb + (size_t)kb * SLM_A + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 64, av, esimd::overaligned_tag<16>{});
                // B block is BK*BN = 32*128 = 4096 B; 32 WI at 128 B each.
                esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                    bp + (size_t)kb * N * 32 + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(2 * SLM_A + buf * SLM_B + lid * 128, bv, esimd::overaligned_tag<16>{});
            };
            auto load_grf = [=](int buf, esimd::simd<int8_t,256>& a0, esimd::simd<int8_t,256>& a1,
                                esimd::simd<int8_t,256>& b0, esimd::simd<int8_t,256>& b1) SYCL_ESIMD_FUNCTION {
                uint32_t offA = buf * SLM_A + wi_row * 512;
                uint32_t offB = 2 * SLM_A + buf * SLM_B + wi_col * 512;
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
            esimd::simd<float, 8> cs_lo = esimd::block_load<float, 8>(col_scale + gc, esimd::overaligned_tag<16>{});
            esimd::simd<float, 8> cs_hi = esimd::block_load<float, 8>(col_scale + gc + 8, esimd::overaligned_tag<16>{});
            // ---- phase 1: per-row local absmax, atomic-fmax into SLM rmax ----
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
            // ---- phase 2: read row absmax, requantize, store int8 ----
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
    std::printf("device: %s\n", dev.get_info<info::device::name>().c_str());

    {
        int M = 9216, N = 128, K = 128;
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hAp((size_t)M * K), hBp((size_t)K * N);
        std::vector<float> col_scale(N);
        for (int n = 0; n < N; ++n) col_scale[n] = 0.001f * (n % 37 + 1);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_a(hA.data(), hAp.data(), M, K); pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hAp.size(), q), *dB = malloc_device<int8_t>(hBp.size(), q);
        float* dcs = malloc_device<float>(N, q);
        int8_t* dC8 = malloc_device<int8_t>((size_t)M * N, q);
        float* dns = malloc_device<float>(M, q);
        q.memcpy(dA, hAp.data(), hAp.size()); q.memcpy(dB, hBp.data(), hBp.size());
        q.memcpy(dcs, col_scale.data(), N * sizeof(float)).wait();
        gemm_s8(q, dA, dB, dcs, dC8, dns, M, N, K).wait();
        std::vector<int8_t> hC8((size_t)M * N);
        std::vector<float> hns(M);
        q.memcpy(hC8.data(), dC8, hC8.size()); q.memcpy(hns.data(), dns, M * sizeof(float)).wait();
        long long bad = 0; int shown = 0;
        std::vector<float> fp(N);
        for (int m = 0; m < M; ++m) {
            float rmax = 0.f;
            for (int n = 0; n < N; ++n) {
                int32_t a = 0;
                for (int k = 0; k < K; ++k) a += (int32_t)hA[(size_t)m * K + k] * hB[(size_t)k * N + n];
                fp[n] = (float)a * col_scale[n];
                if (std::fabs(fp[n]) > rmax) rmax = std::fabs(fp[n]);
            }
            float ns = rmax / 127.0f;
            if (std::fabs(hns[m] - ns) > 1e-4f * (ns + 1.f)) { if (shown < 5) std::printf("  scale m=%d got %.6f want %.6f\n", m, hns[m], ns); ++shown; ++bad; }
            for (int n = 0; n < N; ++n) {
                int8_t want = (int8_t)std::max(-127, std::min(127, (int)std::nearbyint(fp[n] / ns)));
                if (hC8[(size_t)m * N + n] != want) {
                    if (bad < 5) std::printf("  out (%d,%d): got %d want %d\n", m, n, (int)hC8[(size_t)m * N + n], (int)want);
                    ++bad;
                }
            }
        }
        std::printf("correctness 9216x128x128 fused-requant: %s (%lld/%d wrong, %d scale)\n",
                    bad ? "FAIL" : "PASS", bad, (long long)M * N, shown);
        free(dA, q); free(dB, q); free(dcs, q); free(dC8, q); free(dns, q);
        if (bad) return 1;
    }
    // speed: the true fused-requantize int8 output (NOT truncated) vs v1's int32
    // (9216x128x128=4.1) and v1 truncated-int8 (13.1).  wide producer constrains
    // BN==N==128, so only N=128 shapes here; K is the reduction dim, free.
    // 130560x128x64 = l4 QKV real shape (section 23: v1-int32 269.4us/7.9 TOPS);
    // M=130560=64*2040 divides BM=64 exactly, so v2 covers it with zero padding.
    for (auto cfg : std::vector<std::array<int, 3>>{{9216, 128, 128}, {8640, 128, 128}, {4096, 128, 512}, {130560, 128, 64}, {130560, 128, 128}}) {
        int M = cfg[0], N = cfg[1], K = cfg[2];
        std::vector<int8_t> hA((size_t)M * K), hB((size_t)K * N), hAp((size_t)M * K), hBp((size_t)K * N);
        std::vector<float> col_scale(N, 0.001f);
        for (size_t i = 0; i < hA.size(); ++i) hA[i] = (int8_t)((i * 7 + 3) % 201 - 100);
        for (size_t i = 0; i < hB.size(); ++i) hB[i] = (int8_t)((i * 11 + 5) % 181 - 90);
        pack_a(hA.data(), hAp.data(), M, K); pack_b(hB.data(), hBp.data(), K, N);
        int8_t *dA = malloc_device<int8_t>(hAp.size(), q), *dB = malloc_device<int8_t>(hBp.size(), q);
        float* dcs = malloc_device<float>(N, q);
        int8_t* dC8 = malloc_device<int8_t>((size_t)M * N, q);
        float* dns = malloc_device<float>(M, q);
        q.memcpy(dA, hAp.data(), hAp.size()); q.memcpy(dB, hBp.data(), hBp.size());
        q.memcpy(dcs, col_scale.data(), N * sizeof(float)).wait();
        gemm_s8(q, dA, dB, dcs, dC8, dns, M, N, K).wait();
        double best = 1e18;
        for (int r = 0; r < 5; ++r) {
            event e = gemm_s8(q, dA, dB, dcs, dC8, dns, M, N, K);
            e.wait();
            double ms = dev_ms(e);
            if (ms < best) best = ms;
        }
        double tops = 2.0 * M * N * K / (best / 1e3) / 1e12;
        std::printf("dev-time %dx%dx%d fused-requant-int8: %.4f ms  %.1f TOPS  (coopmat 24.8: %.2fx)\n",
                    M, N, K, best, tops, tops / 24.8);
        free(dA, q); free(dB, q); free(dcs, q); free(dC8, q); free(dns, q);
    }
    std::printf("V2_DONE\n");
    return 0;
}
