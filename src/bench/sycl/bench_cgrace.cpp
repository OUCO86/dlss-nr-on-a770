// bench_cgrace.cpp -- section 98 isolation part 4: does stream-capture on an in_order queue
// preserve SERIAL order between graph nodes? The engine reuses one pool block across
// closures (A writes scratch, puts it, B gets the SAME pointer, reads it). If the graph
// parallelizes nodes, B races A -> garbage or fault. Test: node1 writes BUF[i]=i (691
// kernels), node2 sums BUF into OUT. Plain in_order = correct. Graph replay: if the sum
// is wrong/zero, capture did NOT serialize -> that is the engine's DEVICE_LOST mechanism.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdint>
#include <cstdio>
using namespace sycl;
namespace gr = sycl::ext::oneapi::experimental;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::in_order{});
  int* BUF=(int*)malloc_device(691*4,q); int* OUT=(int*)malloc_device(4,q);
  q.memset(BUF,0,691*4).wait(); q.memset(OUT,0,4).wait();
  // plain in_order execution first (control)
  for(int i=0;i<691;++i) q.submit([&](handler& h){ h.parallel_for(range(1u),[=](item<1>){ BUF[i]=i+1; }); });
  q.submit([&](handler& h){ h.parallel_for(range(1u),[=](item<1>){ int t=0; for(int k=0;k<691;++k) t+=BUF[k]; OUT[0]=t; }); });
  q.wait();
  int hsum=0; q.memcpy(&hsum,OUT,4).wait();
  printf("plain in_order sum=%d (expect %d)\n",hsum,691*692/2);
  // now record the SAME sequence via stream capture and replay
  q.memset(BUF,0,691*4).wait(); q.memset(OUT,0,4).wait();
  gr::command_graph<gr::graph_state::modifiable> cg(q);
  cg.begin_recording(q);
  for(int i=0;i<691;++i) q.submit([&](handler& h){ h.parallel_for(range(1u),[=](item<1>){ BUF[i]=i+1; }); });
  // THE SUSPECT: a queue-level memcpy INSIDE the recording (the engine records these).
  // UR/L0 splits memcpy onto the copy-engine command-list -> concurrent with compute.
  int* TMP=(int*)malloc_device(691*4,q);
  q.memcpy(TMP, BUF, 691*4);            // recorded as a MEMCPY node
  q.submit([&](handler& h){ h.parallel_for(range(1u),[=](item<1>){ int t=0; for(int k=0;k<691;++k) t+=TMP[k]; OUT[0]=t; }); });
  cg.end_recording(q);
  auto eg=cg.finalize();
  try{
    q.ext_oneapi_graph(eg).wait();
    int gsum=0; q.memcpy(&gsum,OUT,4).wait();
    printf("graph replay sum=%d (expect %d) -> %s\n",gsum,691*692/2,
           gsum==691*692/2?"SERIALIZED OK":"RACE / NOT SERIALIZED");
  }catch(const std::exception&e){ printf("graph replay THREW: %.100s\n",e.what()); }
  return 0;
}
