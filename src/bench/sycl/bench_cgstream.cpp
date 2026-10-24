// bench_cgstream.cpp -- section 98 isolation part 2: the engine records via STREAM CAPTURE
// (begin_recording + queue.submit + end_recording), the passing probe used explicit cg.add.
// Same 691 ESIMD+dpas kernels, three capture flavors: (A) stream capture on the DEFAULT
// out-of-order queue; (B) stream capture on an IN_ORDER queue (the engine's GQ shape);
// (C) explicit add on in_order. Which flavor DEVICE_LOSTs at replay?
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdint>
#include <cstdio>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
namespace gr = sycl::ext::oneapi::experimental;

static bool replay(queue& q, gr::command_graph<gr::graph_state::executable>& eg, const char* nm){
  try{ q.ext_oneapi_graph(eg).wait(); printf("%-40s REPLAY OK\n",nm); return true; }
  catch(const std::exception&e){ printf("%-40s THREW: %.100s\n",nm,e.what()); return false; }
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q0(dev);
  float* BUF=(float*)malloc_device(4096*4,q0);
  q0.wait();
  const int N=691;
  auto body=[&](handler& h, int i){ h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      for(int k=0;k<64;++k) BUF[(size_t)i*4+(k%4)]=c[k]; }); };

  // A: stream capture, out-of-order queue
  {
    queue q(dev);
    q.memset(BUF,0,4096*4).wait();
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    cg.begin_recording(q);
    for(int i=0;i<N;++i) q.submit([&](handler& h){ body(h,i); });
    cg.end_recording(q);
    auto eg=cg.finalize();
    replay(q,eg,"A stream-capture OOO queue");
  }
  // B: stream capture, in_order queue (engine shape)
  {
    queue q(dev, property::queue::in_order{});
    q.memset(BUF,0,4096*4).wait();
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    cg.begin_recording(q);
    for(int i=0;i<N;++i) q.submit([&](handler& h){ body(h,i); });
    cg.end_recording(q);
    auto eg=cg.finalize();
    replay(q,eg,"B stream-capture IN_ORDER queue");
  }
  // C: explicit add on in_order queue
  {
    queue q(dev, property::queue::in_order{});
    q.memset(BUF,0,4096*4).wait();
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    for(int i=0;i<N;++i) cg.add([&](handler& h){ body(h,i); });
    auto eg=cg.finalize();
    replay(q,eg,"C explicit add IN_ORDER queue");
  }
  return 0;
}
