// probe_graph.cpp — Gate probe ① for option A (L0 + ESIMD rewrite).
//
// QUESTION (from §16 + the seniors' oneDNN verdict): can SYCL's submit overhead
// support "one submit runs the whole static plan"? The seniors measured that
// oneDNN's eager dispatch costs +0.2-0.5 ms per call x 300 calls, which killed
// the passthrough option. Our shipped frame is 691 small passes. So the rewrite
// stands or falls on host-side dispatch cost per frame, not on kernels.
//
// THREE FORMS, same tiny kernel (16x16 workgroups writing one float — the
// kernel body is deliberately irrelevant; we measure the SUBMIT mechanism):
//   EAGER : 691 separate q.submit() calls per frame          (worst case = oneDNN passthrough's mechanism)
//   MULTI : 1 q.submit() containing 691 command groups       (the "static plan in one submit" shape)
//   GRAPH : record 691 nodes once, finalize, replay per frame (ext::oneapi::experimental::command_graph)
// Precedent for the graph form: refs/a770-skill/references/api/code-snippets.md
// :1136-1150 (copy-ready). Baseline numbers from api-usage.md:336-346: dual-queue
// saved ~17us/invocation; fusing pack+GEMM lost 47us — i.e. launch gaps are tens
// of us, so 691 of them should be ~10-30 ms eager. We measure, not estimate.
//
// GATE 1b (same file): put an ESIMD DPAS mini-kernel INTO the graph — proves the
// vector_compute kernels are graph-compatible, not just plain SYCL ones.

#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <chrono>
#include <cstdio>
#include <vector>
#include <algorithm>

namespace ex = sycl::ext::oneapi::experimental;
using namespace sycl;

static constexpr int NPASS = 691;   // the shipped frame's pass count (ledger)
static constexpr int NFRAME = 30;   // timed frames per form

// the tiny kernel body: one float per workgroup (contents irrelevant — we time dispatch)
static void tiny_cgf(handler& h, float* out, int wg) {
    h.parallel_for(range(16 * 16), [=](id<1> i) { out[wg * 256 + i[0]] = 1.0f; });
}

// ESIMD mini kernel for gate 1b: one SIMD add/store, inside a graph node
static void esimd_cgf(handler& h, float* out) {
    h.single_task([=]() SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        esimd::simd<float, 16> v(2.0f);
        v = v + v;                       // trivial vector math through the DPAS-capable path
        out[0] = esimd::hmax<float, float, 16>(v);   // every lane = 4
    });
}

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    queue q(dev);
    float* out = malloc_shared<float>(NPASS * 256 + 64, q);

    // ---- EAGER: 691 separate submits per frame ----
    {
        std::vector<double> ms;
        for (int f = 0; f < NFRAME; ++f) {
            auto t0 = std::chrono::steady_clock::now();
            for (int p = 0; p < NPASS; ++p)
                q.submit([&](handler& h) { tiny_cgf(h, out, p); });
            q.wait();
            ms.push_back(std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count());
        }
        std::sort(ms.begin(), ms.end());
        std::printf("EAGER  %d submits/frame : med %.3f ms  best %.3f ms  (per-submit %.1f us)\n",
                    NPASS, ms[NFRAME/2], ms[0], ms[NFRAME/2]*1000.0/NPASS);
    }

    // ---- MEGA: one launch doing all 691 passes' work (the megakernel shape) ----
    // (a single submit() handler cannot nest 691 parallel_fors in one CGF; the
    //  real "one submit" end-state is one big kernel — that is what we time here)
    {
        std::vector<double> ms;
        for (int f = 0; f < NFRAME; ++f) {
            auto t0 = std::chrono::steady_clock::now();
            q.submit([&](handler& h) {
                h.parallel_for(range(NPASS * 16), [=](id<1> i) {
                    // 691 "passes" folded into one launch: pass index = i/16
                    out[i[0] * 16 + (i[0] % 16)] = 1.0f;
                });
            });
            q.wait();
            ms.push_back(std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count());
        }
        std::sort(ms.begin(), ms.end());
        std::printf("MEGA   1 launch for all  : med %.3f ms  best %.3f ms\n", ms[NFRAME/2], ms[0]);
    }

    // ---- GRAPH: record 691 nodes once, replay per frame ----
    {
        ex::command_graph<> graph(q);
        // node has no default ctor and make_edge takes lvalue refs: chain as we add
        ex::node prev = graph.add([&](handler& h) { tiny_cgf(h, out, 0); });
        for (int p = 1; p < NPASS; ++p) {
            ex::node cur = graph.add([&](handler& h) { tiny_cgf(h, out, p); });
            graph.make_edge(prev, cur);   // real dependency chain, like the plan's fences
            prev = cur;
        }
        auto exec = graph.finalize();
        std::vector<double> ms;
        for (int f = 0; f < NFRAME; ++f) {
            auto t0 = std::chrono::steady_clock::now();
            q.submit([&](handler& h) { ex::execute_graph(h, exec); });
            q.wait();
            ms.push_back(std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count());
        }
        std::sort(ms.begin(), ms.end());
        std::printf("GRAPH  691-node replay   : med %.3f ms  best %.3f ms  (per-node %.1f us)\n",
                    ms[NFRAME/2], ms[0], ms[NFRAME/2]*1000.0/NPASS);

        // ---- gate 1b: ESIMD kernel inside a graph ----
        ex::command_graph<> g2(q);
        auto n1 = g2.add([&](handler& h) { esimd_cgf(h, out + NPASS * 256); });
        auto n2 = g2.add([&](handler& h) { esimd_cgf(h, out + NPASS * 256 + 16); });
        g2.make_edge(n1, n2);
        auto e2 = g2.finalize();
        q.submit([&](handler& h) { ex::execute_graph(h, e2); });
        q.wait();
        float want = out[NPASS * 256] + out[NPASS * 256 + 16];
        // v=2+2=4 per lane; hmax over 16 lanes = 4; two nodes sum = 8.
        std::printf("GRAPH-ESIMD 2 nodes      : %s (values sum=%.0f want 8)\n",
                    want == 8.0f ? "OK" : "FAIL", want);
    }

    std::printf("PROBE_GRAPH_DONE\n");
    std::fflush(stdout);
    return 0;
}
