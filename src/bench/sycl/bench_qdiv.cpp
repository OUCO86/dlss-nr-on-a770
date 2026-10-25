// bench_qdiv.cpp -- section 99: is esimd::div_ieee a SINGLE hardware fdiv, or a
// reciprocal+Newton SEQUENCE? Time the quant kernel 3 ways at the frame's dominant
// shape (M=8160 K=128, M=32640 K=256): (a) div_ieee (shipping), (b) plain simd '/',
// (c) multiply by a precomputed reciprocal (WRONG semantics, timing ceiling only).
// (b)~(c) >> (a) => div_ieee is the wall. All results discarded; this is timing.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
using namespace sycl;
template<int MODE>
static event qk(queue& q, const half* src, int8_t* pk, float* sc, unsigned m, unsigned k){
  const unsigned words=k/8u, chunks=words/2u;
  return q.submit([&](handler& h){
    // 16 lanes per row, 4 rows per WG of 64 threads; one WG per 4 rows
    size_t ngroups=(m+3u)/4u;
    h.parallel_for(sycl::nd_range<1>(sycl::range(64u*ngroups), sycl::range(64u)),
      [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      unsigned row=(unsigned)it.get_group(0)*4u + ((unsigned)it.get_local_id(0)>>4);
      unsigned lane=(unsigned)it.get_local_id(0)&15u;
      if(row>=m) return;
      const size_t base=(size_t)row*k;
      esimd::simd<float,16> accmax(0.f);
      for(unsigned c=lane;c<chunks;c+=16u){
        esimd::simd<half,16> hh=esimd::block_load<half,16>(src+base+(size_t)c*16u,esimd::overaligned_tag<16>{});
        accmax=esimd::max(accmax,esimd::abs(esimd::convert<float>(hh)));
      }
      esimd::slm_block_store((it.get_local_id(0)&~15u)*4u,esimd::simd<float,1>(esimd::hmax<float,float,16>(accmax)),esimd::overaligned_tag<16>{});
      esimd::barrier();
      unsigned bl=(it.get_local_id(0)&~15u)*4u;
      float full=0.f;
      for(unsigned i=0;i<16u;++i){float v=esimd::slm_block_load<float,1>(bl+i*4u)[0];full=full>v?full:v;}
      float scale=(full==0.f)?1.f:(esimd::div_ieee<float,1>(esimd::simd<float,1>(full),esimd::simd<float,1>(127.0f)))[0];
      if(lane==0u) sc[row]=scale;
      esimd::simd<float,16> sv;
      if(MODE==0) sv=esimd::simd<float,16>(scale);
      else if(MODE==1) sv=esimd::simd<float,16>(1.0f/scale);   // '/' via reciprocal mult -- WRONG, timing only
      else sv=esimd::simd<float,16>(scale);
      for(unsigned c=lane;c<chunks;c+=16u){
        esimd::simd<half,16> hh=esimd::block_load<half,16>(src+base+(size_t)c*16u,esimd::overaligned_tag<16>{});
        esimd::simd<float,16> f=esimd::convert<float>(hh);
        esimd::simd<float,16> q;
        if(MODE==0) q=esimd::div_ieee<float,16>(f,sv);
        else if(MODE==1) q=f*sv;
        else q=f/sv;                                            // plain ESIMD '/'
        q=esimd::min(esimd::max(esimd::rnde<float,16>(q),esimd::simd<float,16>(-127.f)),esimd::simd<float,16>(127.f));
        esimd::simd<int8_t,16> o=esimd::convert<int8_t>(esimd::convert<int>(q));
        esimd::block_store<int8_t,16>(pk+(size_t)row*k+(size_t)c*16u,o,esimd::overaligned_tag<16>{});
      }
    });
  });
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  for(auto [M,K]:std::vector<std::pair<int,int>>{{8160,128},{32640,256},{8160,512}}){
    half* src=(half*)malloc_device((size_t)M*K*2,q);
    int8_t* pk=(int8_t*)malloc_device((size_t)M*K,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    q.memset(src,0x30,(size_t)M*K*2).wait();
    struct N{const char* n;int id;};
    for(auto nm:{N{"div_ieee",0},N{"plain /",2},N{"rcp-mult(wrong)",1}}){
      double best=1e9;
      for(int i=0;i<5;++i){event e=(nm.id==0)?qk<0>(q,src,pk,sc,M,K):(nm.id==1)?qk<1>(q,src,pk,sc,M,K):qk<2>(q,src,pk,sc,M,K);e.wait();
        auto s=e.get_profiling_info<info::event_profiling::command_start>();
        auto t=e.get_profiling_info<info::event_profiling::command_end>();
        best=std::min(best,(double)(t-s)/1e6);}
      double mb=((double)M*K*(2.0+2.0+1.0)+M*4.0)/1e6;   // two read passes
      printf("M=%-6d K=%-4d %-15s %8.4f ms  %6.1f GB/s\n",M,K,nm.n,best,mb/best*1000.0);
    }
    free(src,q);free(pk,q);free(sc,q);
  }
  return 0;
}
