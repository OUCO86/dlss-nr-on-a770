// bench_p4vec2.cpp -- section 97: locate the FIRST divergent intermediate in P4 softmax
// vectorization. Two paths compute identical stage values with different spellings:
//   A = scalar (the shipped form): eh_round(s+B) -> eh_add(eh_mul(hl,scale),bias) -> clamp
//       -> bit_pack((c,c+1) pairs) -> expand halfs.
//   C = vectorized simd<float,32>: convert<half>(s+B) -> convert<half>(mulh+bias) -> esimd
//       min/max clamp -> select<16,2> even/odd -> bit_pack uint32 -> bit_cast_view<half>.
// Dump per-stage (hl, a, w) for the FIRST 32 channels of each row and compare. Whichever
// stage first differs is where the 1-ULP enters (hl->a = affine/clamp spellings; a->w =
// the bit-pack mapping). This settles whether P4 CAN be vectorized safely at all.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static inline float eh_round(float x){ return (float)(half)x; }
static inline float eh_mul(float a,float b){ return (float)(half)(a*b); }
static inline float eh_add(float a,float b){ return (float)(half)(a+b); }
static inline esimd::simd<float,32> mulh(esimd::simd<float,32> v,float s){
    return esimd::convert<float>(esimd::convert<half>(v*esimd::simd<float,32>(s))); }

#define COLS 64u
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const unsigned ROWS=256;
  std::mt19937 rng(11); std::uniform_real_distribution<float> ds(-18.f,18.f), db(-6.f,6.f);
  std::vector<float> hs(ROWS*COLS), hb(ROWS*COLS);
  for(auto&x:hs)x=ds(rng); for(auto&x:hb)x=db(rng);
  float* S=(float*)malloc_device(hs.size()*4,q); q.memcpy(S,hs.data(),hs.size()*4).wait();
  float* B=(float*)malloc_device(hb.size()*4,q); q.memcpy(B,hb.data(),hb.size()*4).wait();
  // stage buffers (f32): hlA,hlC,aA,aC (64 per row) ; wA,wC are the bit-pack-expanded halfs (64/row, store as float for compare)
  float *hlA,*hlC,*aA,*aC,*wA,*wC;
  auto alloc=[&](float**p){ *p=(float*)malloc_device((size_t)ROWS*COLS*4,q); q.memset(*p,0,(size_t)ROWS*COLS*4).wait(); };
  alloc(&hlA);alloc(&hlC);alloc(&aA);alloc(&aC);alloc(&wA);alloc(&wC);

  // A: scalar stages (ESIMD kernel to match div/round context)
  q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it) SYCL_ESIMD_KERNEL {
    unsigned r=(unsigned)it.get_id(0); const float* row=S+(size_t)r*COLS; size_t boff=(size_t)r*COLS;
    for(unsigned c=0;c<COLS;c+=2u){
      float hl0=eh_round(row[c]+B[boff+c]);
      float hl1=eh_round(row[c+1u]+B[boff+c+1u]);
      hlA[(size_t)r*COLS+c]=hl0; hlA[(size_t)r*COLS+c+1u]=hl1;
      float a0=eh_add(eh_mul(hl0,0.044921875f),1.30078125f);
      float a1=eh_add(eh_mul(hl1,0.044921875f),1.30078125f);
      a0=a0<1.03125f?1.03125f:(a0>1.5693359375f?1.5693359375f:a0);
      a1=a1<1.03125f?1.03125f:(a1>1.5693359375f?1.5693359375f:a1);
      aA[(size_t)r*COLS+c]=a0; aA[(size_t)r*COLS+c+1u]=a1;
      uint32_t packed=(uint32_t)bit_cast<uint16_t>(half(a0))|((uint32_t)bit_cast<uint16_t>(half(a1))<<16);
      uint32_t tr=(packed<<5)+0x7FF88000u;
      half h0=bit_cast<half>((uint16_t)(tr&0xFFFFu)), h1=bit_cast<half>((uint16_t)((tr>>16)&0xFFFFu));
      wA[(size_t)r*COLS+c]=(float)h0; wA[(size_t)r*COLS+c+1u]=(float)h1;
    }
  }); });
  q.wait();
  // C: vectorized stages
  q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it) SYCL_ESIMD_KERNEL {
    unsigned r=(unsigned)it.get_id(0); const float* row=S+(size_t)r*COLS; size_t boff=(size_t)r*COLS;
    esimd::simd<float,32> s0(row), s1(row+32), b0(B+boff), b1(B+boff+32);
    esimd::simd<float,32> hl0=esimd::convert<float>(esimd::convert<half>(s0+b0));
    esimd::simd<float,32> hl1=esimd::convert<float>(esimd::convert<half>(s1+b1));
    hl0.copy_to(hlC+(size_t)r*COLS); hl1.copy_to(hlC+(size_t)r*COLS+32);
    // FIX: mulh() half-rounds the product (that is eh_mul), then the +bias must round ONCE
    // in f32 (eh_add). The old spelling mulh+bias+convert<half> double-rounded the product.
    esimd::simd<float,32> m0=hl0*esimd::simd<float,32>(0.044921875f);
    esimd::simd<float,32> m1=hl1*esimd::simd<float,32>(0.044921875f);
    esimd::simd<float,32> a0=esimd::convert<float>(esimd::convert<half>(m0+esimd::simd<float,32>(1.30078125f)));
    esimd::simd<float,32> a1=esimd::convert<float>(esimd::convert<half>(m1+esimd::simd<float,32>(1.30078125f)));
    a0=(esimd::min)((esimd::max)(a0,esimd::simd<float,32>(1.03125f)),esimd::simd<float,32>(1.5693359375f));
    a1=(esimd::min)((esimd::max)(a1,esimd::simd<float,32>(1.03125f)),esimd::simd<float,32>(1.5693359375f));
    a0.copy_to(aC+(size_t)r*COLS); a1.copy_to(aC+(size_t)r*COLS+32);
    esimd::simd<half,16> he0=esimd::convert<half>(a0.template select<16,2>(0).read());
    esimd::simd<half,16> ho0=esimd::convert<half>(a0.template select<16,2>(1).read());
    esimd::simd<half,16> he1=esimd::convert<half>(a1.template select<16,2>(0).read());
    esimd::simd<half,16> ho1=esimd::convert<half>(a1.template select<16,2>(1).read());
    esimd::simd<uint16_t,16> e0; e0=he0.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> o0; o0=ho0.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> e1; e1=he1.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> o1; o1=ho1.bit_cast_view<uint16_t>();
    esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
    esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
    esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
    esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
    esimd::simd<half,32> w0; w0=t0.bit_cast_view<half>();
    esimd::simd<half,32> w1; w1=t1.bit_cast_view<half>();
    esimd::convert<float>(w0).copy_to(wC+(size_t)r*COLS);
    esimd::convert<float>(w1).copy_to(wC+(size_t)r*COLS+32);
  }); });
  q.wait();
  auto cmp=[&](float*X,float*Y,const char*n){
    std::vector<float> xa((size_t)ROWS*COLS),yb((size_t)ROWS*COLS);
    q.memcpy(xa.data(),X,xa.size()*4).wait(); q.memcpy(yb.data(),Y,yb.size()*4).wait();
    uint64_t d=0; size_t fi=0; bool any=false;
    for(size_t i=0;i<xa.size();++i) if(bit_cast<uint32_t>(xa[i])!=bit_cast<uint32_t>(yb[i])){d++;if(!any){fi=i;any=true;}}
    printf("stage %-4s: %llu/%zu differ\n",n,(unsigned long long)d,xa.size());
    if(any) printf("   first idx row%u col%u: A=%.9g C=%.9g\n",(unsigned)(fi/COLS),(unsigned)(fi%COLS),xa[fi],yb[fi]);
  };
  cmp(hlA,hlC,"hl");
  cmp(aA,aC,"a");
  cmp(wA,wC,"w");
  return 0;
}
