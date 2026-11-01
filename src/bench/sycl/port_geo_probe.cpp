// port_geo_probe.cpp -- S6-1b PORT phase A: D1 geometry survival probe.
// Question: their core's thread geometry ([WaveSize(32)] numthreads(32*WAVES),
// WAVES = C/16 => C=64:128, C=128:256, C=256:512 DX threads/group) -- can that
// work-group size SURVIVE on our A770 under ESIMD, with (a) a CTA group_barrier,
// (b) dpas<8,8,32>, (c) both, at SLM in {8,16,32,48,64} KB?
// Every config runs in its OWN PROCESS (the driver), 3 reps, each rep watched with a
// 20 s watchdog: a HANG is reported and the process hard-exits (never wedge the box).
// A canary launch (single task, dpas, no SLM/barrier) runs after every rep to detect a
// wedged GPU, so a hang is attributed to the CONFIG, not to a dead adapter.
//
// ESIMD model note (this decides the port's D1): in this toolchain ONE ESIMD work-item
// == one HW thread == one of their DX *waves* (its simd<T,N> program is spread over that
// thread's 32 lanes; a 16x16 tile per work-item runs SIMD16 like the shipped fused kernel).
// So their "32*WAVES threads" == WAVES ESIMD work-items (C=256 -> 16, NOT 512).
// The probe still sweeps LW in SYCL-local-size units {64,128,256,512} as asked, because
// our hang records (LW>=128+barrier, bench_v2crash) are written in that unit.
//
// Build: cd src/bench/sycl && bash E:/DSH/bench.sh port_geo_probe.cpp port_geo_probe.exe
// Run  : port_geo_probe.exe <LW> <MODE> <SLM_KB> <ITERS> [NGROUPS]
//   MODE: 0 = SLM traffic only (heavy vectors, NO barrier, NO dpas)
//         1 = heavy traffic + CTA group_barrier
//         2 = dpas<8,8,32> only (no SLM traffic, no barrier)
//         3 = traffic + barrier + dpas (the shape the port actually needs)
//         4 = LIGHT traffic + barrier (no wide vectors at all -> minimal GRF)
//         5 = LIGHT traffic only
//   ITERS=0 = pure launch-legality test (loop body never runs).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>
#include <atomic>
#include <chrono>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template <int LW, int SLMKB, int MODE>
static event probe(queue& q, float* sink, int ngroups, int iters) {
    constexpr bool LIGHT  = (MODE >= 4);
    constexpr bool BAR    = (MODE == 1 || MODE == 3 || MODE == 4);
    constexpr bool TRAFFIC= (MODE == 0 || MODE == 1 || MODE == 3 || MODE == 4 || MODE == 5);
    constexpr bool DPAS   = (MODE == 2 || MODE == 3);
    constexpr int  VEC    = LIGHT ? 4 : 0;      // light = 4 int32 = 16B per thread
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)ngroups * LW), range((size_t)LW)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMKB * 1024>();
            const int t = (int)it.get_local_id(0);
            // per-thread SLM region (bytes) for the heavy traffic modes
            constexpr int per = (SLMKB * 1024) / LW;
            constexpr int HVEC = (per >= 256) ? 64 : (per >= 128) ? 32 : (per >= 64) ? 16
                             : (per >= 32) ? 8 : 4;
            constexpr int CVEC = LIGHT ? VEC : HVEC;
            esimd::simd<int32_t, CVEC> d(0);
            esimd::simd<int8_t, 256> a(int8_t(3)), b(int8_t(5));
            esimd::simd<int32_t, 64> c(0);
            for (int i = 0; i < iters; ++i) {
                if (TRAFFIC) {
                    esimd::slm_block_store<int32_t, CVEC>((uint32_t)t * CVEC * 4u,
                        esimd::simd<int32_t, CVEC>(i + t), esimd::overaligned_tag<16>{});
                    if (BAR) group_barrier(it.get_group());
                    d = d + esimd::slm_block_load<int32_t, CVEC>((uint32_t)((t + 1) % LW) * CVEC * 4u,
                        esimd::overaligned_tag<16>{});
                    if (BAR) group_barrier(it.get_group());
                }
                if (DPAS) {
                    c = esimd::xmx::dpas<8, 8, int32_t>(c, a, b);
                    c = esimd::xmx::dpas<8, 8, int32_t>(c, a, b);
                }
            }
            float s = (float)d[0];
            if (DPAS) s += (float)c[0];
            if (t == 0) sink[it.get_group(0)] = s;   // anti-DCE sink (rule 15)
        });
    });
}

// dispatch over the swept grid
static bool dispatch(int lw, int mode, int slm, queue& q, float* sink, int ngroups, int iters, event* out) {
    const int key = lw * 10000 + slm * 10 + mode;
    switch (key) {
#define CASE(L_, S_, M_) case (L_*10000 + S_*10 + M_): *out = probe<L_, S_, M_>(q, sink, ngroups, iters); return true;
#define CASEM(L_, S_) CASE(L_,S_,0) CASE(L_,S_,1) CASE(L_,S_,2) CASE(L_,S_,3) CASE(L_,S_,4) CASE(L_,S_,5)
    CASEM(64, 8)  CASEM(64, 16) CASEM(64, 32) CASEM(64, 48) CASEM(64, 64)
    CASEM(128, 8) CASEM(128,16) CASEM(128,32) CASEM(128,48) CASEM(128,64)
    CASEM(256, 8) CASEM(256,16) CASEM(256,32) CASEM(256,48) CASEM(256,64)
    CASEM(512, 8) CASEM(512,16) CASEM(512,32) CASEM(512,48) CASEM(512,64)
#undef CASEM
#undef CASE
    default: break;
    }
    return false;
}
static bool canary(queue& q, float* sink) {
    q.submit([&](handler& h) {
        h.parallel_for(range(1u), [=](item<1>) SYCL_ESIMD_KERNEL {
            esimd::simd<int8_t, 256> a(int8_t(3)), b(int8_t(5));
            esimd::simd<int32_t, 64> c(0);
            c = esimd::xmx::dpas<8, 8, int32_t>(c, a, b);
            sink[0] = (float)c[0];
        });
    });
    return true;
}

int main(int argc, char** argv) {
    setvbuf(stdout, nullptr, _IONBF, 0);
    if (argc < 5) { printf("usage: %s LW MODE SLM_KB ITERS [NGROUPS]\n", argv[0]); return 2; }
    const int lw = atoi(argv[1]), mode = atoi(argv[2]), slm = atoi(argv[3]), iters = atoi(argv[4]);
    const int total = 130560;                       // same thread budget as the 2040x64 safe zone
    int ngroups = argc > 5 ? atoi(argv[5]) : (total / lw);
    if (ngroups < 1) ngroups = 1;

    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    printf("device=%s max_wg=%u\n", dev.get_info<info::device::name>().c_str(),
           (unsigned)dev.get_info<info::device::max_work_group_size>());
    queue q(dev, property::queue::enable_profiling{});
    float* sink = (float*)malloc_device((size_t)ngroups * 4 + 64, q);
    q.memset(sink, 0, (size_t)ngroups * 4 + 64).wait();

    printf("PROBE lw=%d mode=%d slm=%dKB ngroups=%d iters=%d\n", lw, mode, slm, ngroups, iters);
    for (int rep = 0; rep < 3; ++rep) {
        auto t0 = std::chrono::steady_clock::now();
        std::atomic<bool> done{false}, fired{false};
        std::thread killer([&]{
            while (!done.load()) {
                if (std::chrono::steady_clock::now() - t0 > std::chrono::seconds(20)) {
                    printf("  REP%d HANG (>20s)\n", rep); fflush(stdout);
                    fired.store(true);
                    _exit(3);
                }
                std::this_thread::sleep_for(std::chrono::milliseconds(50));
            }
        });
        event e{};
        bool ok = dispatch(lw, mode, slm, q, sink, ngroups, iters, &e);
        if (!ok) { done.store(true); killer.join(); printf("  no instantiation for this config\n"); return 2; }
        q.wait();
        auto t1 = std::chrono::steady_clock::now();
        done.store(true); killer.join();
        double wall = std::chrono::duration<double, std::milli>(t1 - t0).count();
        double gpu = 0.0;
        try {
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0e = e.get_profiling_info<info::event_profiling::command_end>();
            gpu = (double)(t0e - s0) / 1e6;
        } catch (...) {}
        printf("  REP%d OK wall=%.3f gpu=%.3f ms\n", rep, wall, gpu); fflush(stdout);
        // canary: is the GPU still alive after this rep?
        auto c0 = std::chrono::steady_clock::now();
        canary(q, sink + ngroups);
        q.wait();
        printf("       canary %.1f us\n", std::chrono::duration<double, std::micro>(std::chrono::steady_clock::now() - c0).count());
        fflush(stdout);
    }
    printf("VERDICT lw=%d mode=%d slm=%d ALIVE\n", lw, mode, slm);
    free(sink, q);
    return 0;
}
