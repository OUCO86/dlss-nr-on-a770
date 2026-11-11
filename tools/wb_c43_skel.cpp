// C43 skeleton probe: PURE DISPATCH / SLM / BARRIER roof for the shipped shapes.
// Same nd_range, same LW, same slm_init, same barrier count as the shipped instance;
// NO loads, NO stores of data, NO arithmetic chains (only a trivial accumulate so the
// loop body cannot be optimised away).  Measures: "this shape, under this dispatch,
// cannot run faster than this".  Zero relation to the engine build: standalone bench.
// Jun190: the queue is explicitly in_order. Jun192: nothing to hash (no data planes).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <chrono>
#include <cstdio>
#include <cstdlib>

using namespace sycl;

static const uint SLM_WB = 45056u;     // window_block_v4ph.hpp:38  esimd::slm_init<45056>()
static const uint BAR_WB = 18u;        // C18 guard row: signal.barrier 18, fence.slm 18

// WB giant pool: 8160 windows x LW 64 (wb_ga_ops.csv plan_line 5313)
// WB giant head: 8349 windows x LW 64 (closure 691)
// WB sibling   : 2040 windows x LW 64 (plan_line 5317; leg 0.82-0.87 ms)
template <int WINDOWS, int LW, int BARRIERS>
static float run_wb(queue& q, int reps) {
    sycl::range<1> g((size_t)WINDOWS * LW);
    sycl::range<1> l(LW);
    double best = 1e30;
    for (int r = 0; r < reps; ++r) {
        auto t0 = std::chrono::steady_clock::now();
        for (int pass = 0; pass < 9; ++pass) {
            q.parallel_for(sycl::nd_range<1>(g, l), [=](sycl::nd_item<1> it) {
                sycl::ext::intel::esimd::slm_init<SLM_WB>();
                float acc = 0.0f;
                for (uint b = 0; b < BARRIERS; ++b) {
                    acc += (float)(it.get_local_id(0) & 7);
                    it.barrier(sycl::access::fence_space::local_space);
                }
                if (acc < -1e30f) it.barrier(sycl::access::fence_space::local_space);  // keep acc live (never taken)
            }).wait();
        }
        auto t1 = std::chrono::steady_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count() / 9.0;
        if (ms < best) best = ms;
    }
    return (float)best;
}

// GA softmax leg: 768 groups x LW 256 (notes: 6,144 -> 768 groups, WG = 8 rows x 32 lanes)
template <int GROUPS, int LW>
static float run_ga(queue& q, int reps) {
    sycl::range<1> g((size_t)GROUPS * LW), l(LW);
    double best = 1e30;
    for (int r = 0; r < reps; ++r) {
        auto t0 = std::chrono::steady_clock::now();
        for (int pass = 0; pass < 9; ++pass) {
            q.parallel_for(sycl::nd_range<1>(g, l), [=](sycl::nd_item<1> it) {
                float acc = 0.0f;
                for (int b = 0; b < 6; ++b) {          // the shipped form has a handful of SG barriers
                    acc += (float)(it.get_local_id(0) & 3);
                    it.barrier(sycl::access::fence_space::local_space);
                }
                if (acc < -1e30f) it.barrier(sycl::access::fence_space::local_space);  // keep acc live (never taken)
            }).wait();
        }
        auto t1 = std::chrono::steady_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count() / 9.0;
        if (ms < best) best = ms;
    }
    return (float)best;
}

int main(int argc, char** argv) {
    const char* dev = getenv("SYCL_DEVICE_FILTER");
    printf("c43 skeleton probe: filter=%s\n", dev ? dev : "(none)");
    queue q(device{}, property::queue::in_order{});
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());
    int reps = argc > 1 ? atoi(argv[1]) : 3;
    printf("pool_giant   %.4f ms\n", run_wb<8160, 64, BAR_WB>(q, reps));
    printf("head_giant   %.4f ms\n", run_wb<8349, 64, BAR_WB>(q, reps));
    printf("sibling_2040 %.4f ms\n", run_wb<2040, 64, BAR_WB>(q, reps));
    printf("none_8160    %.4f ms\n", run_wb<8160, 64, 0>(q, reps));      // barrier-free control
    printf("ga_softmax   %.4f ms\n", run_ga<768, 256>(q, reps));
    printf("ga_softmax_noBar %.4f ms\n", run_ga<768, 256>(q, reps));     // same arm (barriers inside)
    return 0;
}
