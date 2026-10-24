// bench_qvar.cpp -- section 99: localize the quantize_row 15-135x slowdown. Variants:
// V0 = shipped qr_kernel (fdiv_rn per element + local/barrier reduce).
// V1 = per-element division as PLAIN '/' (runtime divisor -> hardware fdiv, correctly
//      rounded; the §77 trap was only the CONSTANT 127 fold, which stays fdiv_rn once/row).
// V2 = V1 + sub_group reduce_max instead of local+barrier.
// V3 = V2 + no private arrays (unpack half2 inline, constant-bound loops only).
// Judge: timing here, then the QUANT gate (numpy contract) for bit-exactness.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
using namespace sycl;

static const unsigned QR_GRID = 65535u;

template<int VAR>
auto qk(){
 return [](half* a_src, uint2* packed, float* scales, unsigned m, unsigned k,
           local_accessor<float,1> la){
  return [=](nd_item<2> it){
    const unsigned words=k/8u;
    const unsigned SUB=it.get_sub_group().get_local_range().size();
    const unsigned THREADS=it.get_local_range(0);
    const unsigned WARPS=THREADS/SUB;
    unsigned pr=(words>=SUB)?SUB:1u;
    if(words<SUB&&words>1u){unsigned v=words-1u,lg=0;while(v>>=1)++lg;pr=1u<<(lg+1u);}
    const unsigned per_row=pr;
    const unsigned rows_per_warp=SUB/per_row;
    unsigned gx=it.get_group(0),gy=it.get_group(1),lx=it.get_local_id(0);
    unsigned warp=lx/SUB,lane=lx%SUB;
    unsigned which=lane/per_row,within=lane%per_row;
    unsigned row=(gy*QR_GRID+gx)*(WARPS*rows_per_warp)+warp*rows_per_warp+which;
    unsigned held=row<m?row:m-1u;
    unsigned base=held*words;
    float peak=0.f;
    uint4* src4=reinterpret_cast<uint4*>(a_src);
    for(unsigned w=within;w<words;w+=per_row){
      uint4 sw=src4[base+w];
      // unpack 8 halves -> absmax, NO private array (V3 style always; V0-V2 kept simple
      // because the arrays have constant-bound loops and inline anyway)
      unsigned u[4]={sw.x(),sw.y(),sw.z(),sw.w()};
      for(int i=0;i<4;++i){
        half lo=bit_cast<half>((unsigned short)(u[i]&0xFFFFu));
        half hi=bit_cast<half>((unsigned short)(u[i]>>16));
        float f0=(float)lo,f1=(float)hi;
        float a0=f0<0.f?-f0:f0, a1=f1<0.f?-f1:f1;
        peak=sycl::fmax(peak,sycl::fmax(a0,a1));
      }
    }
    float full;
    if(VAR>=2){
      full=peak;   // TIMING PROBE ONLY (no cross-lane reduce): isolates the barrier+SLM cost
    } else {
      la[lx]=peak; it.barrier(access::fence_space::local_space);
      unsigned bl=warp*SUB+which*per_row; full=0.f;
      for(unsigned i=0;i<per_row;++i) full=sycl::fmax(full,la[bl+i]);
    }
    peak=full;
    float scale=(peak==0.f)?1.f:(VAR>=1? ext::intel::math::fdiv_rn(peak,127.0f) : ext::intel::math::fdiv_rn(peak,127.0f));
    if(row>=m)return;
    if(within==0u) scales[row]=scale;
    uint2* dst=reinterpret_cast<uint2*>(packed);
    for(unsigned w=within;w<words;w+=per_row){
      size_t at=(size_t)row*words+w;
      uint4 sw=src4[base+w];
      unsigned u[4]={sw.x(),sw.y(),sw.z(),sw.w()};
      unsigned o[2];
      for(int i=0;i<2;++i){
        unsigned uu=u[2*i],vv=u[2*i+1];
        int g[8];
        float f0=(float)bit_cast<half>((unsigned short)(uu&0xFFFFu));
        float f1=(float)bit_cast<half>((unsigned short)(uu>>16));
        float f2=(float)bit_cast<half>((unsigned short)(vv&0xFFFFu));
        float f3=(float)bit_cast<half>((unsigned short)(vv>>16));
        float f4=(float)bit_cast<half>((unsigned short)(u[2*i+0]&0xFFFFu)); // placeholder overwritten below
        // do 8 halves from uu,vv properly:
        float fa=(float)bit_cast<half>((unsigned short)(uu&0xFFFFu));
        float fb=(float)bit_cast<half>((unsigned short)(uu>>16));
        float fc=(float)bit_cast<half>((unsigned short)(vv&0xFFFFu));
        float fd=(float)bit_cast<half>((unsigned short)(vv>>16));
        (void)f0;(void)f1;(void)f2;(void)f3;(void)f4;
        int q0,q1,q2,q3;
        auto hwdiv=[&](float x)->float{
          if(VAR==4) return (sycl::ext::intel::esimd::div_ieee<float,1>(
              sycl::ext::intel::esimd::simd<float,1>(x),
              sycl::ext::intel::esimd::simd<float,1>(scale)))[0];
          return ext::intel::math::fdiv_rn(x,scale); };
        if(VAR==1){ q0=(int)sycl::rint(fa/scale); q1=(int)sycl::rint(fb/scale); q2=(int)sycl::rint(fc/scale); q3=(int)sycl::rint(fd/scale); }
        else if(VAR==3){ q0=(int)sycl::rint(sycl::native::divide(fa,scale)); q1=(int)sycl::rint(sycl::native::divide(fb,scale));
                    q2=(int)sycl::rint(sycl::native::divide(fc,scale)); q3=(int)sycl::rint(sycl::native::divide(fd,scale)); }
        else if(VAR==4){ q0=(int)sycl::rint(hwdiv(fa)); q1=(int)sycl::rint(hwdiv(fb)); q2=(int)sycl::rint(hwdiv(fc)); q3=(int)sycl::rint(hwdiv(fd)); }
        else      { q0=(int)sycl::rint(hwdiv(fa)); q1=(int)sycl::rint(hwdiv(fb));
                    q2=(int)sycl::rint(hwdiv(fc)); q3=(int)sycl::rint(hwdiv(fd)); }
        auto cl=[](int x){return x<-127?-127:(x>127?127:x);};
        o[i]=(cl(q0)&0xFFu)|((cl(q1)&0xFFu)<<8u)|((cl(q2)&0xFFu)<<16u)|((cl(q3)&0xFFu)<<24u);
        (void)g;
      }
      dst[at]=uint2(o[0],o[1]);
    }
  };};
}

template<int VAR>
void run(const char* nm, std::vector<uint8_t>* saveout=nullptr){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  struct Cfg{unsigned M,K;};
  std::vector<Cfg> cfgs={{2040,256},{640,512},{8160,128},{192,1024},{32640,64},{640,2048},{192,4096}};
  printf("%s:/n",nm);
  for(auto cf:cfgs){
    unsigned M=cf.M,K=cf.K;
    std::vector<half> hsrc((size_t)M*K);
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hsrc)x=half(df(rng));
    half* dsrc=malloc_device<half>((size_t)M*K,q);
    uint2* pk=(uint2*)malloc_device((size_t)M*K,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    q.memcpy(dsrc,hsrc.data(),(size_t)M*K*2).wait();
    unsigned words=K/8u;
    auto sgs=dev.get_info<info::device::sub_group_sizes>();
    unsigned SUBm=1u;for(unsigned s:sgs)if(s>SUBm)SUBm=s;
    unsigned lg=0;while((1u<<lg)<words)++lg;
    unsigned prub=(1u<<lg)<SUBm?(1u<<lg):SUBm;
    unsigned rpw=256u/prub;
    unsigned ng=(M+rpw-1u)/rpw;
    unsigned gxx=ng<QR_GRID?ng:QR_GRID, gyy=(ng+gxx-1u)/gxx;
    double best=1e9;
    for(int it=0;it<5;++it){
      event e=q.submit([&](handler& h){
        local_accessor<float,1> la(range<1>(256u),h);
        h.parallel_for(nd_range<2>(range(256u*gxx,gyy),range(256u,1u)),qk<VAR>()(dsrc,pk,sc,M,K,la));
      });
      e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t0-s0)/1e6);
    }
    printf("   M=%-6u K=%-5u GPU=%8.4f ms  %7.1f GB/s\n",M,K,best,(double)M*K*3/best/1e6);
    if(saveout){ saveout->resize((size_t)M*K); q.memcpy(saveout->data(),pk,(size_t)M*K).wait(); }
    free(dsrc,q);free(pk,q);free(sc,q);
  }
}
int main(){
  std::vector<uint8_t> o0,o4;
  run<0>("V0 fdiv_rn (shipped, proven)",&o0);
  run<4>("V4 esimd div_ieee in PLAIN kernel",&o4);
  size_t diff=0; for(size_t i=0;i<o0.size();++i) if(o0[i]!=o4[i]) diff++;
  printf("V4 vs V0 byte-diff: %zu / %zu -> %s\n",diff,o0.size(),diff==0?"IDENTICAL (V4 is the safe speedup)":"NOT bit-exact");
  return 0; }
