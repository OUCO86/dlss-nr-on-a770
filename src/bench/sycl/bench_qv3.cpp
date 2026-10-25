// bench_qv3.cpp -- section 99: quantize at senior geometry. The senior (quantize_row.comp)
// = warp per row, ONE global read (row held in registers), shuffle row-max, no barrier.
// My shipping ESIMD qr = TWO global reads + SLM + barrier. This bench tests 3 forms at
// the frame shapes: (a) shipping double-read, (b) single-read register-hold (V vectors
// per lane, V=chunks/per_row), (c) ONE THREAD PER ROW (K<=256: the whole row in GRF
// registers, hmax intra-thread, ZERO SLM, ZERO barrier).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <algorithm>
using namespace sycl;

// (b) single-read register-hold: template V = max vectors of 16 halfs per lane
template<int V>
static event qk_b(queue& q, const half* src, uint2* pk, float* sc, unsigned m, unsigned k){
  const unsigned words=k/8u, chunks=words/2u;      // 16-half chunks
  const unsigned SUB=16u;
  unsigned pr=1u; while(pr<chunks && pr<SUB) pr<<=1; if(pr>SUB) pr=SUB;
  const unsigned per_row=pr, rows_per_warp=SUB/per_row;
  const unsigned LW=64u, WARPS=LW/SUB;
  size_t ngroups=((size_t)m+WARPS*rows_per_warp-1)/(WARPS*rows_per_warp);
  return q.submit([&](handler& h){
    h.parallel_for(sycl::nd_range<1>(sycl::range(LW*ngroups), sycl::range(LW)),
      [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      esimd::slm_init<64*4>();
      unsigned lx=(unsigned)it.get_local_id(0);
      unsigned warp=lx/SUB, lane=lx%SUB;
      unsigned which=lane/per_row, within=lane%per_row;
      unsigned row=(unsigned)it.get_group(0)*WARPS*rows_per_warp + warp*rows_per_warp + which;
      bool live=row<m; unsigned held=live?row:m-1u;
      const size_t base=(size_t)held*k;
      esimd::simd<float,16> reg[V]; esimd::simd<float,16> accmax(0.f);
      #pragma unroll
      for(int i=0;i<V;++i){
        unsigned c=within+(unsigned)i*per_row;
        if(c<chunks){
          esimd::simd<half,16> hh=esimd::block_load<half,16>(src+base+(size_t)c*16u,esimd::overaligned_tag<16>{});
          reg[i]=esimd::convert<float>(hh);
          accmax=esimd::max(accmax,esimd::abs(reg[i]));
        }
      }
      esimd::slm_block_store(lx*4,esimd::simd<float,1>(esimd::hmax<float,float,16>(accmax)),esimd::overaligned_tag<16>{});
      esimd::barrier();
      unsigned bl=(warp*SUB+which*per_row)*4u;
      float full=0.f;
      esimd::simd<float,16> seg=esimd::slm_block_load<float,16>(bl,esimd::overaligned_tag<16>{});
      if(per_row>=16u) full=esimd::hmax<float,float,16>(seg);
      else for(unsigned i=0;i<per_row;++i){float v=seg[i];full=full>v?full:v;}
      float scale=(full==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(full),esimd::simd<float,1>(127.f))[0];
      if(live&&within==0u) sc[row]=scale;
      uint4* dst4=(uint4*)pk; const size_t row4=(size_t)row*(words/2u);
      #pragma unroll
      for(int i=0;i<V;++i){
        unsigned c=within+(unsigned)i*per_row;
        if(c<chunks){
          esimd::simd<float,16> q=esimd::div_ieee<float,16>(reg[i],esimd::simd<float,16>(scale));
          q=esimd::min(esimd::max(esimd::rnde<float,16>(q),esimd::simd<float,16>(-127.f)),esimd::simd<float,16>(127.f));
          esimd::simd<int8_t,16> o=esimd::convert<int8_t>(esimd::convert<int>(q));
          if(live) esimd::block_store<unsigned,4>((unsigned*)(dst4+row4+c),o.template bit_cast_view<unsigned>());
        }
      }
    });
  });
}
// (c) ONE THREAD PER ROW (K<=256): whole row in registers, no SLM, no barrier
template<int KMAX>
static event qk_c(queue& q, const half* src, uint2* pk, float* sc, unsigned m, unsigned k){
  return q.submit([&](handler& h){
    h.parallel_for(sycl::range(m),[=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      unsigned row=(unsigned)it.get_id(0);
      const size_t base=(size_t)row*k;
      esimd::simd<float,KMAX> reg=esimd::convert<float>(esimd::block_load<half,KMAX>(src+base,esimd::overaligned_tag<16>{}));
      // (c) requires k==KMAX exactly -- main() only instantiates matching pairs
      float peak=esimd::hmax<float,float,KMAX>(esimd::abs(reg));
      float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
      sc[row]=scale;
      esimd::simd<float,KMAX> qv=esimd::div_ieee<float,KMAX>(reg,esimd::simd<float,KMAX>(scale));
      qv=esimd::min(esimd::max(esimd::rnde<float,KMAX>(qv),esimd::simd<float,KMAX>(-127.f)),esimd::simd<float,KMAX>(127.f));
      esimd::simd<int8_t,KMAX> o=esimd::convert<int8_t>(esimd::convert<int>(qv));
      esimd::block_store<int8_t,KMAX>((int8_t*)pk+base,o,esimd::overaligned_tag<16>{});
    });
  });
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  for(auto [M,K]:std::vector<std::pair<int,int>>{{8160,128},{32640,256},{8160,512},{640,2048},{32640,64}}){
    half* src=(half*)malloc_device((size_t)M*K*2,q);
    uint2* pk=(uint2*)malloc_device((size_t)M*K,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    q.memset(src,0x30,(size_t)M*K*2).wait();
    auto t=[&](std::function<event()> f,const char* nm){
      double best=1e9;
      for(int i=0;i<7;++i){event e=f();e.wait();
        auto s0=e.get_profiling_info<info::event_profiling::command_start>();
        auto t0=e.get_profiling_info<info::event_profiling::command_end>();
        best=std::min(best,(double)(t0-s0)/1e6);}
      double mb=((double)M*K*(2.0+1.0)+M*4.0)/1e6;   // single-read traffic
      printf("  M=%-6d K=%-5d %-12s %8.4f ms  %6.1f GB/s(1-read)\n",M,K,nm,best,mb/best);
    };
    printf("M=%d K=%d:/n",M,K);
    int chunks=K/16;
    if(chunks<=1) t([&]{return qk_b<1>(q,src,pk,sc,M,K);},"b-reg1");
    else if(chunks==2) t([&]{return qk_b<2>(q,src,pk,sc,M,K);},"b-reg2");
    else if(chunks==4) t([&]{return qk_b<4>(q,src,pk,sc,M,K);},"b-reg4");
    else if(chunks==8) t([&]{return qk_b<8>(q,src,pk,sc,M,K);},"b-reg8");
    else if(chunks==16) t([&]{return qk_b<16>(q,src,pk,sc,M,K);},"b-reg16");
    if(K==64) t([&]{return qk_c<64>(q,src,pk,sc,M,K);},"c-rowthread");
    if(K==128) t([&]{return qk_c<128>(q,src,pk,sc,M,K);},"c-rowthread");
    if(K==256) t([&]{return qk_c<256>(q,src,pk,sc,M,K);},"c-rowthread");
    free(src,q);free(pk,q);free(sc,q);
  }
  return 0;
}
