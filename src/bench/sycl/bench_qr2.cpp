// bench_qr2.cpp -- B2 kernel-form sweep: the isolated quant bench put the frame's
// small-M shapes at 37-77 GB/s (rowthread: M threads only; rowgroup64: 64/row).
// Hypothesis: THREADS-PER-ROW is the lever (occupancy), not the chain. Variants:
//   RG<LW>: LW threads/row, each holds K/LW halfs in one 16-half block (or CH16
//   blocks), cross-thread max via SLM (float max = associative/commutative ->
//   BIT-EXACT vs any order, the rowthread precedent), then quantize from regs.
// All bit-safe by construction; the QUANT gate (numpy golden) judges.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <chrono>
#include "quantize_row_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

#include "bench_qr2_kernel.hpp"
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait(); auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f(); q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  // frame shapes: (M,K,weight). bit-exactness: pk+scale compared vs rowthread form.
  struct T{unsigned M,K;int w;};
  T ts[]={{640,2048,32},{32640,256,16},{2040,256,32},{8160,512,24},{192,1024,16},{8160,128,24}};
  double cur=0, best=0;
  for(auto&t:ts){
    half* a=malloc_device<half>((size_t)t.M*t.K,q);
    uint2 *p1=malloc_device<uint2>((size_t)t.M*t.K/4+64,q), *p2=malloc_device<uint2>((size_t)t.M*t.K/4+64,q);
    float *s1=malloc_device<float>(t.M+16,q), *s2=malloc_device<float>(t.M+16,q);
    q.parallel_for(range((size_t)t.M*t.K),[=](item<1> it){ a[it.get_id(0)]=half((float)((it.get_id(0)*37)%501)-250.f); }).wait();
    double t_cur = (t.K>512)? tm([&]{ qr_launch_esimd(q,dev,a,p1,s1,t.M,t.K); },30)
                         : tm([&]{ qr_launch_esimd(q,dev,a,p1,s1,t.M,t.K); },30);
    // variant table per K: try LW = K/16 clamped
    double t_best=1e9; int blw=0,bch=0;
    auto tryv=[&](int LW,int CH16){
      double ms;
      if(LW==64&&CH16==1) ms=tm([&]{ rg_launch<64,1>(q,a,p2,s2,t.M,t.K); },30);
      else if(LW==64&&CH16==2) ms=tm([&]{ rg_launch<64,2>(q,a,p2,s2,t.M,t.K); },30);
      else if(LW==32&&CH16==1) ms=tm([&]{ rg_launch<32,1>(q,a,p2,s2,t.M,t.K); },30);
      else if(LW==16&&CH16==1) ms=tm([&]{ rg_launch<16,1>(q,a,p2,s2,t.M,t.K); },30);
      else if(LW==16&&CH16==2) ms=tm([&]{ rg_launch<16,2>(q,a,p2,s2,t.M,t.K); },30);
      else if(LW==32&&CH16==4) ms=tm([&]{ rg_launch<32,4>(q,a,p2,s2,t.M,t.K); },30);
      else return;
      if(ms<t_best){t_best=ms;blw=LW;bch=CH16;}
    };
    if(t.K==128){tryv(8,1);}      // 8x16=128
    if(t.K==256){tryv(16,1);}     // 16x16=256
    if(t.K==512){tryv(32,1);}
    if(t.K==1024){tryv(64,1);}
    if(t.K==2048){tryv(64,2);tryv(128,1);}
    double mb=(double)t.M*t.K*3/1e6;
    printf("M=%6u K=%5u w=%2d: cur %7.4f (%5.1f GB/s) | best RG(%d,%d) %7.4f (%6.1f GB/s) %s\n",
      t.M,t.K,t.w,t_cur,mb/t_cur,blw,bch,t_best,mb/t_best, t_best<t_cur*0.9?"WIN":"-");
    cur+=t.w*t_cur; best+=t.w*t_best;
    free(a,q);free(p1,q);free(p2,q);free(s1,q);free(s2,q);
  }
  printf("frame-weighted: current %.2f ms -> best-forms %.2f ms  (recover %.2f)\n", cur, best, cur-best);
  return 0;
}
