// bench_qesimd.cpp -- section 100 P8-j: quant at the FRAME path (qr_launch_esimd --
// rowthread for K<=512, the double-read ESIMD for K>512). bench_qtime measured the
// OLD plain qr_kernel path (2-28 GB/s) = the wrong road (the sixth bench-lie catch).
// The frame census (NR_Q_STATS): 448 live quants, 1.7GB total traffic in 13.9ms
// = 122 GB/s vs the A770's ~450 GB/s ceiling -- 3.7x headroom. This bench prices
// every frame shape on the frame kernel, split by path.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
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
  // the census shapes with call counts (from qkeys.txt, frame-real):
  struct Cfg{unsigned M,K,n;};
  std::vector<Cfg> cfgs={{32640,64,16},{32640,256,16},{35712,64,4},{33728,64,4},{34560,64,4},
                         {8160,128,12},{8160,512,12},{640,512,64},{640,2048,16},
                         {2040,256,32},{2560,256,16},{192,1024,8},{192,4096,4},{960,512,16},{768,512,16}};
  double gtot=0, gbytes=0;
  for(auto cf:cfgs){
    unsigned M=cf.M,K=cf.K,n=cf.n;
    std::vector<half> hsrc((size_t)M*K);
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hsrc)x=half(df(rng));
    half* dsrc=malloc_device<half>((size_t)M*K,q);
    uint2* pk=(uint2*)malloc_device((size_t)M*K,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    q.memcpy(dsrc,hsrc.data(),(size_t)M*K*2).wait();
    double best=1e9;
    for(int it=0;it<9;++it){
      event e=q.submit([&](handler& h){ (void)h; });   // placeholder not used
      auto t0=std::chrono::steady_clock::now();
      for(int r2=0;r2<5;++r2) qr_launch_esimd(q,dev,dsrc,pk,sc,M,K);
      q.wait();
      auto t1=std::chrono::steady_clock::now();
      best=std::min(best,std::chrono::duration<double,std::milli>(t1-t0).count()/5);
      (void)e;
    }
    double bytes=(double)M*K*(2.0+1.0)+M*4;
    double gbs=bytes/best/1e6;
    gtot+=best*n; gbytes+=bytes*n;
    printf("M=%-6u K=%-5u x%-3u  %8.4f ms  %7.1f GB/s  [%s]\n",
           M,K,n,best,gbs, K<=512?"rowthread":"esimd-double");
    free(dsrc,q);free(pk,q);free(sc,q);
  }
  printf("census-weighted frame quant total = %.1f ms at %.1f GB/s (frame ledger: 13.9)\n",
         gtot, gbytes/gtot/1e6);
  return 0;
}
