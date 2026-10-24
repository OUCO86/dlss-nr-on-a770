// bench_cgraph.cpp -- section 98: can oneAPI command_graph collapse N kernel launches into
// ONE submit? This is the fix for the 455ms CPU-enqueue wall (submit_probe: enqueue=455ms,
// gpu_drain=0.2ms over 691 closures). Probe: 691 tiny kernels, (A) plain loop submit,
// (B) command_graph capture -> instantiate -> single submit. If B's enqueue is ~ms, the
// engine's graph_run should be rebuilt on command_graph (keeping the ESIMD+dpas kernels).
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdint>
#include <cstdio>
#include <chrono>
#include <vector>
using namespace sycl;
namespace gr = sycl::ext::oneapi::experimental;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  int* buf=(int*)malloc_device(691*4,q);
  q.memset(buf,0,691*4).wait();
  const int N=691;

  // A: plain loop (today's shape)
  {
    auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<N;++i) q.submit([&](handler& h){ h.parallel_for(range(64u),[=](item<1> it){ buf[i]+=(int)it.get_id(0); }); });
    auto t1=std::chrono::steady_clock::now();
    q.wait();
    auto t2=std::chrono::steady_clock::now();
    printf("A plain loop:  enqueue=%.1f ms  drain=%.1f ms\n",
      std::chrono::duration<double,std::milli>(t1-t0).count(),
      std::chrono::duration<double,std::milli>(t2-t1).count());
  }
  // B: command_graph
  try{
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<N;++i){
      cg.add([&](handler& h){ h.parallel_for(range(1u),[=](item<1> it){ buf[i]=42; }); });
    }
    auto eg = cg.finalize();
    auto t1=std::chrono::steady_clock::now();
    q.ext_oneapi_graph(eg);
    q.ext_oneapi_graph(eg);   // 2nd replay: the SAME eg object reused (engine will cache it)
    q.wait();
    auto t2=std::chrono::steady_clock::now();
    printf("B command_graph: capture+finalize=%.1f ms  replay-submit=%.1f ms\n",
      std::chrono::duration<double,std::milli>(t1-t0).count(),
      std::chrono::duration<double,std::milli>(t2-t1).count());
    std::vector<int> hb(N); q.memcpy(hb.data(),buf,N*4).wait();
    int nz=0,n42=0; for(int v:hb){ if(v)nz++; if(v==42)n42++; }
    printf("B ran: slots set=%d/691 value42=%d/691 (expect 691/691 after 2 replays)\n",nz,n42);
  }catch(const sycl::exception&e){ printf("B THREW: %.200s\n",e.what()); return 2; }
  return 0;
}
