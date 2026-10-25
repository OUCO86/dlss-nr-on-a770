// bench_leg3.cpp -- section 99: the LEG3 residual anomaly. NR_WB_STOP delta says
// 3.5ms/call for a pass whose traffic is ~33MB (dC3 f32 read + image half read +
// target half write) = should be ~0.08ms at 400GB/s. 44x off = bug. Isolate the
// kernel alone at frame shapes (windows=1020/2040, width=960, height=544, across,
// C=32, epi=1 narrow): scalar vs 32-wide ESIMD vs pure-contiguous (no gather map).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include "publish_kernel.hpp"
#include "window_block_v2.hpp"
using namespace sycl;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{unsigned windows,across;};
  std::vector<Cfg> cfgs={{1020,34},{2040,68},{1360,45}};
  const unsigned width=960, height=544, C=32, top=0, left=0;
  for(auto cf:cfgs){
    unsigned windows=cf.windows, across=cf.across, rows=windows*64u;
    half* ImgH=(half*)malloc_device((size_t)height*width*C,q);
    float* dC3=(float*)malloc_device((size_t)rows*C*4,q);
    float* cp=(float*)malloc_device(C*4,q);
    half* Tgt=(half*)malloc_device((size_t)height*width*C,q);
    q.memset(ImgH,0x3c,(size_t)height*width*C*2).wait();
    q.memset(dC3,0,(size_t)rows*C*4).wait();
    q.memset(cp,0,C*4).wait();
    auto timeit=[&](const char* nm, std::function<event()> fn){
      double best=1e9;
      for(int it=0;it<5;++it){ event e=fn(); e.wait();
        auto s0=e.get_profiling_info<info::event_profiling::command_start>();
        auto t0=e.get_profiling_info<info::event_profiling::command_end>();
        best=std::min(best,(double)(t0-s0)/1e6); }
      double mb=(double)rows*C*(4.0+2.0+2.0)/1e6;
      printf("  w=%-5u %-22s %8.4f ms  %7.1f MB/s-eff\n",windows,nm,best,mb/best*1000.0);
    };
    printf("cfg windows=%u across=%u rows=%u traffic=%.1fMB\n",windows,across,rows,
      (double)rows*C*8/1e6);
    // (a) scalar (the pre-§99 form)
    timeit("scalar", [&]{ return q.parallel_for(range((size_t)rows*C),[=](item<1> it){
      size_t i=it.get_id(0); unsigned r=(unsigned)(i/C), col=(unsigned)(i%C);
      unsigned window=r/64u, token=r%64u;
      unsigned y=(window/across)*8u+token/8u, x=(window%across)*8u+token%8u;
      if(y<top||x<left||y-top>=height||x-left>=width) return;
      size_t out=((size_t)(y-top)*width+(x-left))*C+col;
      float sk=(float)ImgH[out];
      ((half*)Tgt)[out]=half(qr_e4m3(sycl::fma(sk,cp[col],dC3[i])));
    });});
    // (b) 32-wide ESIMD (the §99 form)
    timeit("esimd32", [&]{ return q.parallel_for(range((size_t)rows),[=](item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      unsigned r=(unsigned)it.get_id(0);
      unsigned window=r/64u, token=r%64u;
      unsigned y=(window/across)*8u+token/8u, x=(window%across)*8u+token%8u;
      if(y<top||x<left||y-top>=height||x-left>=width) return;
      size_t out=((size_t)(y-top)*width+(x-left))*C;
      esimd::simd<float,32> c3=esimd::block_load<float,32>(dC3+(size_t)r*C,esimd::overaligned_tag<16>{});
      esimd::simd<float,32> sk=esimd::convert<float>(esimd::block_load<half,32>(ImgH+out,esimd::overaligned_tag<16>{}));
      esimd::simd<float,32> cv=esimd::block_load<float,32>(cp,esimd::overaligned_tag<16>{});
      esimd::simd<float,32> total=sk*cv+c3;
      esimd::block_store<half,32>((half*)Tgt+out,esimd::convert<half>(wbv2::e4m3_vec<32>(total)),esimd::overaligned_tag<16>{});
    });});
    // (c) pure contiguous (NO gather map: out = i) -- isolates the scatter tax
    timeit("contig", [&]{ return q.parallel_for(range((size_t)rows),[=](item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      unsigned r=(unsigned)it.get_id(0);
      size_t out=(size_t)r*C;
      esimd::simd<float,32> c3=esimd::block_load<float,32>(dC3+out,esimd::overaligned_tag<16>{});
      esimd::simd<float,32> sk=esimd::convert<float>(esimd::block_load<half,32>(ImgH+out,esimd::overaligned_tag<16>{}));
      esimd::simd<float,32> cv=esimd::block_load<float,32>(cp,esimd::overaligned_tag<16>{});
      esimd::simd<float,32> total=sk*cv+c3;
      esimd::block_store<half,32>((half*)Tgt+out,esimd::convert<half>(wbv2::e4m3_vec<32>(total)),esimd::overaligned_tag<16>{});
    });});
    free(ImgH,q);free(dC3,q);free(cp,q);free(Tgt,q);
  }
  return 0;
}
