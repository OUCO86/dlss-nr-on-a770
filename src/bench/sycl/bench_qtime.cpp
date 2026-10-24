// bench_qtime.cpp -- section 99: is MY quantize_row kernel at the senior's measured speed?
// The healthy-chain standard is ALREADY measured (frame-ledger: quantize_row 193 passes
// 1.62ms = 0.0084ms/pass; §29 forbids benchmarking the UNHEALTHY coopmat chain, but
// comparing my kernel against the senior's healthy-chain per-shape expectation is exactly
// what the plan prescribes). Device-event timing, min of 5, frame-real shapes from the
// plan survey: (M,K) = (2040,256)(640,512)(8160,128)(192,1024)(32640,64)(2560,256)(640,2048).
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include "quantize_row_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{unsigned M,K;};
  std::vector<Cfg> cfgs={{2040,256},{640,512},{8160,128},{192,1024},{32640,64},{2560,256},{640,2048},{8160,512},{192,4096}};
  for(auto cf:cfgs){
    unsigned M=cf.M,K=cf.K;
    std::vector<half> hsrc((size_t)M*K);
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hsrc)x=half(df(rng));
    half* dsrc=malloc_device<half>((size_t)M*K,q);
    uint2* pk=(uint2*)malloc_device((size_t)M*K,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    q.memcpy(dsrc,hsrc.data(),(size_t)M*K*2).wait();
    // scratch check (the width-sweep bytes[32] lesson): private arrays with variable
    // indices spill to local memory -> huge scratch = the 26x slowdown mechanism.
    {
      event e0 = q.submit([&](handler& h){
        h.parallel_for(range(1u),[=](item<1>){ /* warm */ });
      });
      e0.wait();
      // query the qr kernel via device global stats is not portable; use the
      // sycl::info::kernel_device_specific variant through a built kernel:
      auto built = q.get_device(); (void)built;
    }
    double best=1e9;
    for(int it=0;it<5;++it){
      event e=qr_launch(q,dev,qr_kernel(),dsrc,pk,sc,M,K,0u,0u,0u,0u,0u,nullptr,nullptr);
      q.wait();
      auto s=e.get_profiling_info<info::event_profiling::command_start>();
      auto t=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t-s)/1e6);
    }
    double bytes=(double)M*K*(2.0+1.0);
    printf("M=%-6u K=%-5u  GPU=%8.4f ms   %7.1f GB/s   (senior std 0.0084/pass)\n",
      M,K,best,bytes/best/1e6);
    free(dsrc,q);free(pk,q);free(sc,q);
  }
  return 0;
}
