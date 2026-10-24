// bench_p4vec.cpp -- section 97: locate the P4-softmax vectorization divergence. Path A =
// the SHIPPED scalar softmax chain (bench_smesimd path B, bit-exact). Path C = the v2 P4
// VECTORIZED chain (simd<float,32> affine+clamp + select<16,2> bit-pack + bit_cast_view
// expand + scalar sequential total + e4m3_vec probs). Dump the FIRST divergent quantity:
// clamp-after(a), the packed weights (w), total, recip, final probs. Same random rows.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include "publish_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static inline float eh_round(float x){ return (float)(half)x; }
static inline float eh_mul(float a,float b){ return (float)(half)(a*b); }
static inline float eh_add(float a,float b){ return (float)(half)(a+b); }
static inline float ef_mul(float a,float b){ return (esimd::simd<float,1>(a)*esimd::simd<float,1>(b))[0]; }
static inline float ef_div(float a,float b){ return (esimd::simd<float,1>(a)/esimd::simd<float,1>(b))[0]; }
static inline esimd::simd<float,32> mulh(esimd::simd<float,32> v,float s){
    return esimd::convert<float>(esimd::convert<half>(v*esimd::simd<float,32>(s))); }
template<int N> static esimd::simd<float,N> e4m3_vec(esimd::simd<float,N> x){
    esimd::simd<float,N> mag=esimd::abs(x); mag=(esimd::min)(mag,esimd::simd<float,N>(448.0f));
    esimd::simd<int32_t,N> mb; mb=mag.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> exp=(mb>>23)&esimd::simd<int32_t,N>(0xFF);
    exp=(esimd::max)(exp,esimd::simd<int32_t,N>(121))-3;
    esimd::simd<int32_t,N> sb=exp<<23; esimd::simd<float,N> step; step=sb.template bit_cast_view<float>();
    esimd::simd<int32_t,N> rb=(esimd::simd<int32_t,N>(254)-exp)<<23; esimd::simd<float,N> recip; recip=rb.template bit_cast_view<float>();
    esimd::simd<float,N> t=mag*recip; esimd::simd<float,N> r=esimd::rnde<float>(t)*step;
    esimd::simd<int32_t,N> ri; ri=r.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> negm=x<esimd::simd<float,N>(0.0f);
    esimd::simd<int32_t,N> out=(ri&esimd::simd<int32_t,N>(0x7FFFFFFF))|(negm<<31);
    esimd::simd<float,N> res; res=out.template bit_cast_view<float>(); return res; }

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const unsigned ROWS=2048, COLS=64;
  std::mt19937 rng(11); std::uniform_real_distribution<float> ds(-18.f,18.f), db(-6.f,6.f);
  std::vector<float> hs(ROWS*COLS), hb(ROWS*COLS);
  for(auto&x:hs)x=ds(rng); for(auto&x:hb)x=db(rng);
  float* S=(float*)malloc_device(hs.size()*4,q); q.memcpy(S,hs.data(),hs.size()*4).wait();
  float* B=(float*)malloc_device(hb.size()*4,q); q.memcpy(B,hb.data(),hb.size()*4).wait();
  // outputs: A path (scalar) and C path (vectorized): weights + probs + total + recip
  half* WA=(half*)malloc_device(ROWS*COLS*2,q); half* WB=(half*)malloc_device(ROWS*COLS*2,q);
  half* PA=(half*)malloc_device(ROWS*COLS*2,q); half* PC=(half*)malloc_device(ROWS*COLS*2,q);
  float* TA=(float*)malloc_device(ROWS*2*4,q); float* TC=(float*)malloc_device(ROWS*2*4,q);
  q.memset(WA,0,ROWS*COLS*2).wait(); q.memset(WB,0,ROWS*COLS*2).wait();
  q.memset(PA,0,ROWS*COLS*2).wait(); q.memset(PC,0,ROWS*COLS*2).wait();
  // ---- A: scalar chain (the proven one) ----
  q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it) SYCL_ESIMD_KERNEL {
    unsigned r=(unsigned)it.get_id(0); const float* row=S+(size_t)r*COLS; size_t boff=(size_t)r*COLS;
    half* outr=WA+(size_t)r*COLS; float wf[64]; float total=0.f;
    for(unsigned c=0;c<COLS;c+=2u){
      float l0=row[c]+B[boff+c], l1=row[c+1u]+B[boff+c+1u];
      float a0=eh_add(eh_mul(eh_round(l0),0.044921875f),1.30078125f);
      float a1=eh_add(eh_mul(eh_round(l1),0.044921875f),1.30078125f);
      a0=a0<1.03125f?1.03125f:(a0>1.5693359375f?1.5693359375f:a0);
      a1=a1<1.03125f?1.03125f:(a1>1.5693359375f?1.5693359375f:a1);
      uint32_t packed=(uint32_t)bit_cast<uint16_t>(half(a0))|((uint32_t)bit_cast<uint16_t>(half(a1))<<16);
      uint32_t tr=(packed<<5)+0x7FF88000u;
      half h0=bit_cast<half>((uint16_t)(tr&0xFFFFu)), h1=bit_cast<half>((uint16_t)((tr>>16)&0xFFFFu));
      total+=(float)h0; total+=(float)h1; outr[c]=h0; outr[c+1u]=h1;
      wf[c]=(float)h0; wf[c+1u]=(float)h1;
    }
    float trh=eh_round(total); float recip=eh_round(ef_div(1.0f,trh));
    TA[(size_t)r*2]=total; TA[(size_t)r*2+1]=recip;
    half* pr=PA+(size_t)r*COLS;
    for(unsigned c=0;c<COLS;++c){ pr[c]=half(qr_e4m3_scalar(eh_round(ef_mul(wf[c],recip)))); }
  }); });
  q.wait();
  // ---- C: vectorized chain (the v2 P4 attempt) ----
  q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it) SYCL_ESIMD_KERNEL {
    unsigned r=(unsigned)it.get_id(0); const float* row=S+(size_t)r*COLS; size_t boff=(size_t)r*COLS;
    half* outr=WB+(size_t)r*COLS;
    esimd::simd<float,32> s0(row), s1(row+32);
    esimd::simd<float,32> b0(B+boff), b1(B+boff+32);
    esimd::simd<float,32> hl0=esimd::convert<float>(esimd::convert<half>(s0+b0));
    esimd::simd<float,32> hl1=esimd::convert<float>(esimd::convert<half>(s1+b1));
    esimd::simd<float,32> a0=esimd::convert<float>(esimd::convert<half>(mulh(hl0,0.044921875f)+esimd::simd<float,32>(1.30078125f)));
    esimd::simd<float,32> a1=esimd::convert<float>(esimd::convert<half>(mulh(hl1,0.044921875f)+esimd::simd<float,32>(1.30078125f)));
    a0=(esimd::min)((esimd::max)(a0,esimd::simd<float,32>(1.03125f)),esimd::simd<float,32>(1.5693359375f));
    a1=(esimd::min)((esimd::max)(a1,esimd::simd<float,32>(1.03125f)),esimd::simd<float,32>(1.5693359375f));
    esimd::simd<half,16> e0=esimd::convert<half>(a0.template select<16,2>(0).read());
    esimd::simd<half,16> o0=esimd::convert<half>(a0.template select<16,2>(1).read());
    esimd::simd<half,16> e1=esimd::convert<half>(a1.template select<16,2>(0).read());
    esimd::simd<half,16> o1=esimd::convert<half>(a1.template select<16,2>(1).read());
    esimd::simd<uint16_t,16> e0b; e0b=e0.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> o0b; o0b=o0.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> e1b; e1b=e1.bit_cast_view<uint16_t>();
    esimd::simd<uint16_t,16> o1b; o1b=o1.bit_cast_view<uint16_t>();
    esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0b)|(esimd::convert<uint32_t>(o0b)<<16);
    esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1b)|(esimd::convert<uint32_t>(o1b)<<16);
    esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
    esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
    esimd::simd<half,32> w0; w0=t0.bit_cast_view<half>();
    esimd::simd<half,32> w1; w1=t1.bit_cast_view<half>();
    w0.copy_to(outr); w1.copy_to(outr+32);
    float total=0.f;
    for(unsigned c=0;c<COLS;++c) total+=(float)outr[c];
    float trh=eh_round(total); float recip=eh_round(ef_div(1.0f,trh));
    TC[(size_t)r*2]=total; TC[(size_t)r*2+1]=recip;
    esimd::simd<half,32> pw0=esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w0),recip)));
    esimd::simd<half,32> pw1=esimd::convert<half>(e4m3_vec<32>(mulh(esimd::convert<float>(w1),recip)));
    pw0.copy_to(PC+(size_t)r*COLS); pw1.copy_to(PC+(size_t)r*COLS+32);
  }); });
  q.wait();
  // compare weights (WA vs WB), total/recip (TA vs TC), probs (PA recomputed scalar vs PC)
  std::vector<half> wa(ROWS*COLS),wb(ROWS*COLS); std::vector<float> ta(ROWS*2),tc(ROWS*2);
  q.memcpy(wa.data(),WA,wa.size()*2).wait(); q.memcpy(wb.data(),WB,wb.size()*2).wait();
  q.memcpy(ta.data(),TA,ta.size()*4).wait(); q.memcpy(tc.data(),TC,tc.size()*4).wait();
  uint64_t wdiff=0,tdiff=0,rdiff=0; size_t firstw=0; bool any=false;
  for(size_t i=0;i<wa.size();++i) if(bit_cast<uint16_t>(wa[i])!=bit_cast<uint16_t>(wb[i])){ wdiff++; if(!any){firstw=i;any=true;} }
  for(unsigned r=0;r<ROWS;++r){ if(bit_cast<uint32_t>(ta[r*2])!=bit_cast<uint32_t>(tc[r*2]))tdiff++;
    if(bit_cast<uint32_t>(ta[r*2+1])!=bit_cast<uint32_t>(tc[r*2+1]))rdiff++; }
  printf("weights scalar-vs-vec: %llu/%zu differ\n",(unsigned long long)wdiff,wa.size());
  if(any){ size_t r=firstw/COLS,c=firstw%COLS; printf("  first w-diff row %u col %u: A=%.6g B=%.6g\n",(unsigned)r,(unsigned)c,(float)wa[firstw],(float)wb[firstw]); }
  printf("total: %llu/%u differ   recip: %llu/%u differ\n",(unsigned long long)tdiff,ROWS,(unsigned long long)rdiff,ROWS);
  std::vector<half> pa(ROWS*COLS),pc(ROWS*COLS);
  q.memcpy(pa.data(),PA,pa.size()*2).wait(); q.memcpy(pc.data(),PC,pc.size()*2).wait();
  uint64_t pdiff=0; size_t firstp=0; bool anp=false;
  for(size_t i=0;i<pa.size();++i) if(bit_cast<uint16_t>(pa[i])!=bit_cast<uint16_t>(pc[i])){ pdiff++; if(!anp){firstp=i;anp=true;} }
  printf("probs scalar-vs-vec: %llu/%zu differ\n",(unsigned long long)pdiff,pa.size());
  if(anp){ size_t r=firstp/COLS,c=firstp%COLS; printf("  first p-diff row %u col %u: A=%.6g B=%.6g\n",(unsigned)r,(unsigned)c,(float)pa[firstp],(float)pc[firstp]); }
  return 0;
}
