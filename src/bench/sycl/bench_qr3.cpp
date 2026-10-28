// bench_qr3.cpp -- the adjudication bench: qr_kernel_rowgroup<2> (the shipped
// K=2048 form) vs my rg_launch<64,2> (the sweep's "WIN") at 640x2048, same
// buffers, interleaved A/B, plus byte-exactness of the two.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <chrono>
#include <vector>
#include "quantize_row_kernel.hpp"
#include "bench_qr2_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  unsigned M=640,K=2048;
  half* a=malloc_device<half>((size_t)M*K,q);
  uint2 *pa=malloc_device<uint2>((size_t)M*K/4+64,q), *pb=malloc_device<uint2>((size_t)M*K/4+64,q);
  float *sa=malloc_device<float>(M+16,q), *sb=malloc_device<float>(M+16,q);
  q.parallel_for(range((size_t)M*K),[=](item<1> it){ a[it.get_id(0)]=half((float)((it.get_id(0)*37)%501)-250.f); }).wait();
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait(); auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f(); q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  auto SHIP=[&]{ q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range((size_t)M*64u), range(64u)), qr_kernel_rowgroup<2>()(a,pa,sa,M,K)); }); };
  auto MINE=[&]{ rg_launch<128,1>(q,a,pb,sb,M,K); };
  for(int i=0;i<5;++i){SHIP();MINE();} q.wait();
  for(int r=0;r<6;++r){
    double x=tm(SHIP,30), y=tm(MINE,30);
    printf("round%d: shipped %7.4f | mine %7.4f\n", r, x, y);
  }
  // byte-exact check
  SHIP(); MINE(); q.wait();
  std::vector<uint64_t> ha(M*K/4), hb(M*K/4); std::vector<float> hsa(M), hsb(M);
  q.memcpy(ha.data(),pa,ha.size()*8).wait(); q.memcpy(hb.data(),pb,hb.size()*8).wait();
  q.memcpy(hsa.data(),sa,M*4).wait(); q.memcpy(hsb.data(),sb,M*4).wait();
  size_t dpk=0,dsc=0;
  for(size_t i=0;i<ha.size();++i) if(ha[i]!=hb[i]) dpk++;
  for(unsigned i=0;i<M;++i) if(hsa[i]!=hsb[i]) dsc++;
  printf("pk-diff=%zu scale-diff=%zu\n", dpk, dsc);
  return 0;
}
