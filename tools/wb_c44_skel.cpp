// C44 skeleton probe (copy of tools/wb_c43_skel.cpp, extended). Same rules: same nd_range /
// same LW / same slm_init / same barrier count as the shipped instance; NO arithmetic chains,
// NO data movement.  Measures the SHAPE ROOF (dispatch + SLM + barrier structure).
// Geometry provenance (all from ledgers / shipped sources, nothing invented):
//   WB v4ph      : window_block_v4ph.hpp:34-38  LW=64, slm_init<45056>, 18 barriers (C18 guard row)
//                  windows: pool 8160 / head 8349 / sibling 2040  (wb_ga_ops.csv plan_line 5313/5317)
//   ffn2::fused  : s6_ffn_block_kernel.hpp:110  nd_range(nblk*64, 64); nblk = 1,536 (S6-1a dispatch
//                  form, notes); slm 2048+512+4096+1024 = 7,680 -> 8,192 (ffn_fusion_slm.csv, T=16);
//                  12 SG barriers (barrier_audit_after.csv: WG=0,SG=12)
//   s8v8::gemm_b : gemm_s8_v8_kernel.hpp:30-32  BM=128 BN=64 BK=32 NT=32, slm_init<3*SLM_A+3*SLM_B>
//                  = 18,432 B; groups for gemm_int8_residual: M=32640 (chain_map.csv) / BM=128 = 255
//   GA softmax   : leg_decomp.csv smax::vit_softmax_tiled  slm=0, barriers=0; 768 groups x LW 256
//                  (notes: WG = 8 rows x 32 lanes, 6,144 -> 768 groups)
//   GA other legs: leg_decomp.csv f16v1::gemm_b / packdev::pack_*  slm=0, barriers=0; 5 legs/closure
// Jun190 in_order queue.  Jun195/197 runtime placement, never hard-link the slot dll.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <chrono>
#include <cstdio>
#include <cstdlib>
using namespace sycl;

template <int WINDOWS, int LW, int SLM, int BARRIERS>
static float run_shape(queue& q, int reps) {
    sycl::range<1> g((size_t)WINDOWS * LW), l(LW);
    double best = 1e30;
    for (int r = 0; r < reps; ++r) {
        auto t0 = std::chrono::steady_clock::now();
        for (int pass = 0; pass < 9; ++pass) {
            q.parallel_for(sycl::nd_range<1>(g, l), [=](sycl::nd_item<1> it) {
                if (SLM > 0) {
                    if (SLM == 45056) sycl::ext::intel::esimd::slm_init<45056>();
                    else if (SLM == 18432) sycl::ext::intel::esimd::slm_init<18432>();
                    else sycl::ext::intel::esimd::slm_init<8192>();
                }
                float acc = 0.0f;
                for (int b = 0; b < BARRIERS; ++b) {
                    acc += (float)(it.get_local_id(0) & 7);
                    it.barrier(sycl::access::fence_space::local_space);
                }
                if (acc < -1e30f) it.barrier(sycl::access::fence_space::local_space);
            }).wait();
        }
        auto t1 = std::chrono::steady_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count() / 9.0;
        if (ms < best) best = ms;
    }
    return (float)best;
}

// a launch-count arm: N sequential empty kernels (the GA pack/gemm legs are 5 per closure)
template <int NLAUNCH, int GROUPS, int LW>
static float run_multi(queue& q, int reps) {
    sycl::range<1> g((size_t)GROUPS * LW), l(LW);
    double best = 1e30;
    for (int r = 0; r < reps; ++r) {
        auto t0 = std::chrono::steady_clock::now();
        for (int pass = 0; pass < 9; ++pass) {
            for (int k = 0; k < NLAUNCH; ++k)
                q.parallel_for(g, [=](sycl::item<1> it) {
                    float v = (float)(it.get_id(0) & 3);
                    if (v < -1e30f) v = 0.0f;   // never taken; the launch itself is what is timed
                });
            q.wait();
        }
        auto t1 = std::chrono::steady_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count() / 9.0;
        if (ms < best) best = ms;
    }
    return (float)best;
}

int main(int argc, char** argv) {
    printf("c44 skeleton probe: filter=%s\n", getenv("SYCL_DEVICE_FILTER") ? getenv("SYCL_DEVICE_FILTER") : "(none)");
    queue q(device{}, property::queue::in_order{});
    printf("device: %s\n", q.get_device().get_info<info::device::name>().c_str());
    int reps = argc > 1 ? atoi(argv[1]) : 3;
    // WB (carry-over arms, now with the barrier count as a real template parameter)
    printf("pool_giant      %.4f\n", run_shape<8160, 64, 45056, 18>(q, reps));
    printf("head_giant      %.4f\n", run_shape<8349, 64, 45056, 18>(q, reps));
    printf("pool_nobar      %.4f\n", run_shape<8160, 64, 45056, 0>(q, reps));
    printf("head_nobar      %.4f\n", run_shape<8349, 64, 45056, 0>(q, reps));
    printf("sibling_2040    %.4f\n", run_shape<2040, 64, 45056, 18>(q, reps));
    // ffn2::fused 1a (ffn_merge): 1,536 groups x LW64, slm 8192, 12 SG barriers
    printf("ffnmerge_skel   %.4f\n", run_shape<1536, 64, 8192, 12>(q, reps));
    printf("ffnmerge_nobar  %.4f\n", run_shape<1536, 64, 8192, 0>(q, reps));
    // s8v8::gemm_b (gemm_int8_residual self-check): 255 groups x NT32, slm 18432, 1 barrier
    printf("gir_skel        %.4f\n", run_shape<255, 32, 18432, 1>(q, reps));
    printf("gir_nobar       %.4f\n", run_shape<255, 32, 18432, 0>(q, reps));
    // GA: softmax arm with the ledger's real structure (slm=0, barriers=0) + the 5 other legs as empty launches
    printf("ga_softmax0bar  %.4f\n", run_shape<768, 256, 0, 0>(q, reps));
    printf("ga_softmax6bar  %.4f\n", run_shape<768, 256, 0, 6>(q, reps));
    printf("ga_5emptylegs   %.4f\n", run_multi<5, 768, 256>(q, reps));
    return 0;
}
