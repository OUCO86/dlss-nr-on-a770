// esimd_dpas_peak.cpp — the number that decides the whole rewrite:
// the RAW issue ceiling of the A770 XMX array via ESIMD s8 DPAS, with no data
// movement (operands live in registers, the loop only issues dpas).  This is
// the true denominator for "75% of hardware compute" — not the 262 marketing
// figure, not the 24.8 coopmat ceiling (a Vulkan->DPAS codegen tax).
//
// One ESIMD work-item = one SIMD8 hardware thread. 4096 work-items fill the
// machine (hardware.md: "Hardware thread count 4096"). Each does ILP=4
// independent dpas per iteration (different accumulators, same register
// operands — pure issue-rate, no dependency stall).
//   esimd::xmx::dpas<SystolicDepth=8, RepeatCount(M)=8, CT=float>(C,B,A):
//   s8 OpsPerChannel=4 => _K=32, _N=ExecSize=8.  One dpas = 2*M*K*N = 4096 flop.
//
// operand layout (dpas.hpp static_asserts):
//   A: simd<int8_t,256>  _M*_K = 8*32 = 256 s8  (row-major)
//   B: simd<int8_t,256>  _K*_N = 32*8 = 256 s8  (VNNI fill order; element TYPE
//      must be int8_t so BPrecision deduces s8 — a uint32 simd deduces Invalid)
//   C: simd<float,64>    _M*_N = 8*8 = 64 f32
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <chrono>

using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

#ifndef NW
#define NW 128
#endif
#ifndef NT
#define NT 32
#endif
#ifndef REPS
#define REPS 2000
#endif

static void body(queue& q, int8_t* Abuf, int8_t* Bbuf, float* Cout, int THREADS) {
    q.parallel_for(nd_range<1>(range<1>(THREADS), range<1>(NT)),
                   [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        int lid = (int)it.get_global_id(0);
        esimd::simd<int8_t, 256> a(Abuf, esimd::overaligned_tag<16>{});
        esimd::simd<int8_t, 256> b(Bbuf, esimd::overaligned_tag<16>{});
        esimd::simd<float, 64> c0(0.f), c1(0.f), c2(0.f), c3(0.f);
        for (int r = 0; r < REPS; ++r) {
            c0 = esimd::xmx::dpas<8, 8, float>(c0, b, a);
            c1 = esimd::xmx::dpas<8, 8, float>(c1, b, a);
            c2 = esimd::xmx::dpas<8, 8, float>(c2, b, a);
            c3 = esimd::xmx::dpas<8, 8, float>(c3, b, a);
        }
        esimd::simd<float, 64> s = c0 + c1 + c2 + c3;
        s.copy_to(Cout + lid * 64);
    }).wait();
}

int main() {
    device dev;
    for (auto& dd : device::get_devices(info::device_type::gpu))
        if (dd.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = dd; break; }
    std::printf("device: %s  driver %s\n", dev.get_info<info::device::name>().c_str(),
                dev.get_info<info::device::driver_version>().c_str());
    queue q(dev);

    const int THREADS = NW * NT;
    int8_t* Abuf = malloc_host<int8_t>(256, q);
    int8_t* Bbuf = malloc_host<int8_t>(256, q);
    for (int i = 0; i < 256; ++i) Abuf[i] = (int8_t)((i % 251) - 125);
    for (int i = 0; i < 256; ++i) Bbuf[i] = (int8_t)((i % 249) - 124);
    float* Cout = malloc_shared<float>((size_t)THREADS * 64, q);

    body(q, Abuf, Bbuf, Cout, THREADS);   // warm
    double best = 1e18;
    for (int rep = 0; rep < 3; ++rep) {
        auto t0 = std::chrono::high_resolution_clock::now();
        body(q, Abuf, Bbuf, Cout, THREADS);
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        if (ms < best) best = ms;
    }
    double dpas_total = (double)THREADS * 4.0 * REPS;
    double flop = dpas_total * 4096.0;
    double tops = flop / (best / 1e3) / 1e12;
    std::printf("NW=%d NT=%d REPS=%d ILP=4  dpas=%.3e  wall=%.2f ms\n", NW, NT, REPS, dpas_total, best);
    std::printf("XMX RAW s8 DPAS issue ceiling = %.1f TOPS   (= %.1f%% of 262 marketing)\n",
                tops, tops / 262.0 * 100.0);
    std::printf("vs coopmat 24.8 = %.2fx;  vs oneDNN 71.9 = %.2fx\n", tops / 24.8, tops / 71.9);
    std::printf("PEAK_OK\n");
    free(Abuf, q); free(Bbuf, q); free(Cout, q);
    return 0;
}
