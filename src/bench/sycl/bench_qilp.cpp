// bench_qilp.cpp -- quant rowthread ILP pricing: 1-row/thread (shipping) vs
// 2-row/thread (two independent fdiv chains hide each other's latency). Same
// per-row arithmetic VERBATIM -> bit-exact by construction; the question is ONLY
// throughput at the frame's surviving shapes. Shapes from the EXEC census.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include "quantize_row_kernel.hpp"
using namespace sycl;

template<int KMAX, int R>
static event rowt(queue& q, half* src, uint2* pk, float* sc, unsigned m){
  return q.parallel_for(range((size_t)m/R), [=](item<1> it) SYCL_ESIMD_KERNEL {
    namespace esimd = sycl::ext::intel::esimd;
    unsigned r0 = (unsigned)it.get_id(0)*R;
    esimd::simd<float,KMAX> reg[R];
    #pragma unroll
    for(int t=0;t<R;++t){
      unsigned row=r0+t; if(row>=m) continue;
      reg[t]=esimd::convert<float>(esimd::block_load<half,KMAX>(src+(size_t)row*KMAX, esimd::overaligned_tag<16>{}));
    }
    #pragma unroll
    for(int t=0;t<R;++t){
      unsigned row=r0+t; if(row>=m) continue;
      float peak=esimd::hmax<float,float,KMAX>(esimd::abs(reg[t]));
      const float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
      sc[row]=scale;
      esimd::simd<float,KMAX> qq=esimd::div_ieee<float,KMAX>(reg[t],esimd::simd<float,KMAX>(scale));
      qq=esimd::min(esimd::max(esimd::rnde<float,KMAX>(qq),esimd::simd<float,KMAX>(-127.f)),esimd::simd<float,KMAX>(127.f));
      esimd::block_store<int8_t,KMAX>((int8_t*)pk+(size_t)row*KMAX, esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
    }
  });
}
static double t11(queue&q,std::function<event()>f){double b=1e9;for(int i=0;i<15;++i){event e=f();e.wait();b=std::min(b,(double)(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>())/1e6);}return b;}
int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu)) if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  struct S{unsigned m,k;}; S ss[]={{32640,256},{8160,512},{8160,128},{2040,256},{32640,64}};
  for(auto&MK:ss){
    size_t n=(size_t)MK.m*MK.k;
    std::vector<half> hs(n); std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hs)x=half(df(rng));
    half* src=malloc_device<half>(n,q); uint2* p1=malloc_device<uint2>(n,q); uint2* p2=malloc_device<uint2>(n,q);
    float* s1=malloc_device<float>(MK.m,q); float* s2=malloc_device<float>(MK.m,q);
    q.memcpy(src,hs.data(),n*2); q.wait();
    event e1=rowt<256,1>(q,src,p1,s1,MK.m); // NOTE: only KMAX==MK.k shapes valid; we pick K=256 rows below
    e1.wait();
    double a=1e9,b=1e9;
    #define PRICE(KK) do{ \
      a=t11(q,[&]{return rowt<KK,1>(q,src,p1,s1,MK.m);}); \
      b=t11(q,[&]{return rowt<KK,2>(q,src,p2,s2,MK.m);}); }while(0)
    if(MK.k==256) PRICE(256); else if(MK.k==512) PRICE(512); else if(MK.k==128) PRICE(128); else if(MK.k==64) PRICE(64); else continue;
    std::vector<int8_t> h1(n),h2(n); q.memcpy(h1.data(),p1,n).wait(); q.memcpy(h2.data(),p2,n).wait();
    std::vector<float> g1(MK.m),g2(MK.m); q.memcpy(g1.data(),s1,MK.m*4).wait(); q.memcpy(g2.data(),s2,MK.m*4).wait();
    size_t d=0; for(size_t i=0;i<n;++i) if(h1[i]!=h2[i])++d;
    size_t sd=0; for(unsigned i=0;i<MK.m;++i) if(memcmp(&g1[i],&g2[i],4))++sd;
    printf("M=%u K=%u: 1-row %.4f ms | 2-row %.4f ms (%.2fx) | pk-diff %zu scale-diff %zu %s\n",
      MK.m,MK.k,a,b,a/b,d,sd,(d||sd)?"NOT-EXACT":"EXACT");
  }
  return 0;
}
