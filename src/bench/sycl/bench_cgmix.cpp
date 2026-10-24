// bench_cgmix.cpp -- section 98 isolation part 3: the engine's sequence is EXECUTE-then-
// RECORD-then-REPLAY on the SAME in_order queue (warm run first, to pre-fill the pool).
// The passing probes never mixed direct execution with capture on one queue. Reproduce:
// (D) submit 691 kernels DIRECT (execute), then record the same 691, then replay.
// (E) same but record BEFORE any direct execution (pure capture process).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdint>
#include <cstdio>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
namespace gr = sycl::ext::oneapi::experimental;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::in_order{});
  float* BUF=(float*)malloc_device(4096*4,q);
  q.memset(BUF,0,4096*4).wait();
  const int N=691;
  auto body=[&](handler& h, int i){ h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      for(int k=0;k<64;++k) BUF[(size_t)i*4+(k%4)]=c[k]; }); };
  // D: EXECUTE first (warm), then record, then replay -- the engine's exact sequence
  try{
    for(int i=0;i<N;++i) q.submit([&](handler& h){ body(h,i); });
    q.wait();
    printf("D: warm direct-execution done\n");
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    cg.begin_recording(q);
    for(int i=0;i<N;++i) q.submit([&](handler& h){ body(h,i); });
    cg.end_recording(q);
    auto eg=cg.finalize();
    q.ext_oneapi_graph(eg).wait();
    printf("D execute->record->replay: REPLAY OK\n");
  }catch(const std::exception&e){ printf("D execute->record->replay: THREW %.100s\n",e.what()); }
  return 0;
}
