// bench_nodetax.cpp -- the EXACT price of one command-graph node on A770.
// Why: the unary probe (NR_U_STOP 8 vs 9) said 36 nodes cost -5.8ms with only
// ~1.2ms of kernel -> ~0.16ms/node; the frame has 691 nodes; the chip's cs4
// shell-vs-full gap needs a floor explanation. THIS measures the floor directly:
// build cgraphs of K EMPTY parallel_for nodes (K = 1..512), replay each many
// times, report ms and ms/node. If the curve is linear with a fat per-node
// slope, the merge blades (batch small adjacent ops into ONE launch) are the
// campaign's biggest remaining lever -- priced BEFORE any kernel work, per the
// user's standing order.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdio>
#include <chrono>
#include <algorithm>
using namespace sycl;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  namespace gr = sycl::ext::oneapi::experimental;
  for (int K : {1, 8, 32, 64, 128, 256, 512}) {
    // record K empty nodes (each: a 1-item parallel_for writing one float --
    // too small to matter, the point is the NODE)
    float* sink = malloc_device<float>(4, q);
    auto eg = std::make_shared<gr::command_graph<gr::graph_state::modifiable>>(q);
    eg->begin_recording(q);
    for (int i = 0; i < K; ++i)
      q.parallel_for(range(1), [=](item<1>){ sink[0] = (float)i; });
    eg->end_recording(q);
    auto exec = eg->finalize();
    // warm
    q.ext_oneapi_graph(exec).wait();
    double best=1e9;
    for (int r = 0; r < 15; ++r) {
      auto t0 = std::chrono::steady_clock::now();
      q.ext_oneapi_graph(exec).wait();
      best = std::min(best, std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count());
    }
    printf("K=%4d empty nodes: %8.4f ms  (%.4f ms/node)\n", K, best, best/K);
    sycl::free(sink, q);
  }
  return 0;
}
