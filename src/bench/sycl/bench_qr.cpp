// bench_qr.cpp -- B2 disambiguation: the 160 surviving quantize launches cost
// 9.0ms/frame vs a 2.64ms traffic floor. KERNEL-BOUND or LAUNCH-BOUND?
// Time each of the 8 census shapes ISOLATED (warm, back-to-back).
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <chrono>
#include "quantize_row_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  struct S{unsigned M,K;};
  S shapes[]={{640,2048},{8160,512},{32640,256},{2040,256},{192,1024},{8160,128},{32640,64},{2560,256}};
  unsigned reps[]={40,40,30,40,40,40,30,40};
  double tot_launch=0;
  for(int si=0;si<8;++si){
    unsigned M=shapes[si].M, K=shapes[si].K;
    half* a=malloc_device<half>((size_t)M*K,q);
    uint2* pk=malloc_device<uint2>((size_t)M*K/4+64,q);
    float* sc=malloc_device<float>((size_t)M+16,q);
    q.parallel_for(range((size_t)M*K),[=](item<1> it){ a[it.get_id(0)]=half((float)(it.get_id(0)%251)-125.f); }).wait();
    // warm
    for(int i=0;i<5;++i) qr_launch_esimd(q,dev,a,pk,sc,M,K);
    q.wait();
    auto t0=std::chrono::steady_clock::now();
    for(int r=0;r<(int)reps[si];++r) qr_launch_esimd(q,dev,a,pk,sc,M,K);
    q.wait();
    double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/reps[si];
    double mb=(double)M*K*(2+1)/1e6;
    printf("M=%6u K=%5u : %7.3f ms  (%6.1f MB, %6.1f GB/s eff)\n", M,K,ms,mb,mb/ms);
    tot_launch+=ms;
    free(a,q);free(pk,q);free(sc,q);
  }
  printf("sum-of-shapes (one each) = %.3f ms\n", tot_launch);
  // also: empty-launch overhead reference (K=64 tiny M)
  return 0;
}
