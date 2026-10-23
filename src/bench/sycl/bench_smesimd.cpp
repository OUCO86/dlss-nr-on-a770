// bench_smesimd.cpp -- section 96: does the ESIMD-context (eh_*) transcription of the
// softmax_kernel chain (affine + clamp + bit-pair transform + sequential total + recip +
// e4m3) match the shipped plain-context softmax_kernel (cr_* helpers) BIT-FOR-BIT? v2's P4
// needs this; ext::intel::math cr_* are illegal in ESIMD so the eh_* form is the only
// option -- the mega normalize used it and is gate-proven, but the softmax chain (transform
// + recip + 64-wide total) has never been A/B'd. Random score rows + random bias, both
// paths on device, compare all 64 output halfs per row bitwise. rows=4096 for coverage.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <string>
#include <random>
#include "publish_kernel.hpp"
#include "softmax_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static inline float eh_round(float x){ return (float)(half)x; }
static inline float eh_mul(float a,float b){ return (float)(half)(a*b); }
static inline float eh_add(float a,float b){ return (float)(half)(a+b); }

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const unsigned rows=4096, cols=64;
  std::mt19937 rng(11); std::uniform_real_distribution<float> ds(-18.f,18.f), db(-6.f,6.f);
  std::vector<float> hs(rows*cols), hb(rows*cols);
  for(auto&x:hs)x=ds(rng); for(auto&x:hb)x=db(rng);
  float* S=(float*)malloc_device(hs.size()*4,q); q.memcpy(S,hs.data(),hs.size()*4).wait();
  float* Bs=(float*)malloc_device(hb.size()*4,q); q.memcpy(Bs,hb.data(),hb.size()*4).wait();
  half* OA=(half*)malloc_device(rows*cols*2,q); half* OB=(half*)malloc_device(rows*cols*2,q);
  float* MA=(float*)malloc_device(rows*cols*4,q); float* MB=(float*)malloc_device(rows*cols*4,q);  // stage: after half_round(l)
  float* PA=(float*)malloc_device(rows*cols*4,q); float* PB=(float*)malloc_device(rows*cols*4,q);  // stage: after clamp
  float* TA=(float*)malloc_device(rows*3*4,q);  float* TB=(float*)malloc_device(rows*3*4,q);       // stage: total,trh,recip
  q.memset(OA,0,rows*cols*2).wait(); q.memset(OB,0,rows*cols*2).wait();
  // path A: the SHIPPED softmax_kernel (plain context, cr_*)
  q.submit([&](handler& h){
    h.parallel_for(range(rows),[=](item<1> it){
      unsigned r=(unsigned)it.get_id(0);
      const float* row=S+(size_t)r*cols;
      size_t boff=(size_t)((r/cols)%1u)*cols*cols + (size_t)(r%cols)*cols;
      half* outr=OA+(size_t)r*cols;
      float total=0.0f;
      for(unsigned c=0;c<cols;c+=2u){
        float l0 = row[c] + Bs[boff+c];
        float l1 = row[c+1u] + Bs[boff+c+1u];
        float hl0=qr_half_round(l0), hl1=qr_half_round(l1);
        MA[(size_t)r*cols+c]=hl0; MA[(size_t)r*cols+c+1u]=hl1;
        float a0 = cr_add(cr_mul(hl0,     0.044921875f), 1.30078125f);
        float a1 = cr_add(cr_mul(hl1,     0.044921875f), 1.30078125f);
        a0 = sycl::min(sycl::max(a0, 1.03125f), 1.5693359375f);
        a1 = sycl::min(sycl::max(a1, 1.03125f), 1.5693359375f);
        PA[(size_t)r*cols+c]=a0; PA[(size_t)r*cols+c+1u]=a1;
        uint32_t packed = (uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a0))
                        | ((uint32_t)sycl::bit_cast<uint16_t>(sycl::half(a1)) << 16);
        uint32_t tr = (packed << 5) + 0x7FF88000u;
        uint16_t w0=(uint16_t)(tr&0xFFFFu), w1=(uint16_t)((tr>>16)&0xFFFFu);
        sycl::half h0=sycl::bit_cast<sycl::half>(w0), h1=sycl::bit_cast<sycl::half>(w1);
        total += (float)h0; total += (float)h1;
        outr[c]=h0; outr[c+1u]=h1;
      }
      float trh=(float)sycl::half(total);
      float recip=(float)sycl::half(sycl::ext::intel::math::fdiv_rn(1.0f,trh));
      TA[(size_t)r*3]=(float)sycl::half(total); TA[(size_t)r*3+1]=trh; TA[(size_t)r*3+2]=recip;
      for(unsigned c=0;c<cols;++c){
        float w=(float)outr[c];
        outr[c]=sycl::half(qr_e4m3(qr_half_round(cr_mul(w,recip))));
      }
    }); });
  q.wait();
  // path B: ESIMD kernel, 1 work-item per row, eh_* chain mirroring softmax_kernel lines.
  // NOTE head index: softmax_kernel uses boff = ((r/cols)%heads)*cols*cols + (r%cols)*cols;
  // heads=1 -> boff = (r%64)*64. Replicate EXACTLY (bias rows repeat every 64).
  try{
    q.submit([&](handler& h){
      h.parallel_for(range(rows),[=](item<1> it) SYCL_ESIMD_KERNEL {
        unsigned r=(unsigned)it.get_id(0);
        const float* row=S+(size_t)r*cols;
        size_t boff=(size_t)(r%64u)*cols;
        half* outr=OB+(size_t)r*cols;
        float total=0.0f;
        for(unsigned c=0;c<cols;c+=2u){
          float l0=row[c]+Bs[boff+c], l1=row[c+1u]+Bs[boff+c+1u];
          float hl0=eh_round(l0), hl1=eh_round(l1);
          MB[(size_t)r*cols+c]=hl0; MB[(size_t)r*cols+c+1u]=hl1;
          // EXACT fp32 single-round chain, unfused: esimd::simd<float,1> ops cannot be
          // merged into FMA by the backend (they are separate vector instructions), which
          // reproduces cr_add(cr_mul(...)) == fadd_rn(fmul_rn(...)) without the half-rounds
          // the eh_* helpers add (the chain is fp32-rounded then cast ONCE to half at the
          // bit-pack; eh_* double-rounded it -> the after-clamp divergence).
          float m0=(esimd::simd<float,1>(hl0)*esimd::simd<float,1>(0.044921875f))[0];
          float m1=(esimd::simd<float,1>(hl1)*esimd::simd<float,1>(0.044921875f))[0];
          float a0=(esimd::simd<float,1>(m0)+esimd::simd<float,1>(1.30078125f))[0];
          float a1=(esimd::simd<float,1>(m1)+esimd::simd<float,1>(1.30078125f))[0];
          a0=a0<1.03125f?1.03125f:(a0>1.5693359375f?1.5693359375f:a0);
          a1=a1<1.03125f?1.03125f:(a1>1.5693359375f?1.5693359375f:a1);
          PB[(size_t)r*cols+c]=a0; PB[(size_t)r*cols+c+1u]=a1;
          uint16_t b0=sycl::bit_cast<uint16_t>(sycl::half(a0)), b1=sycl::bit_cast<uint16_t>(sycl::half(a1));
          uint32_t packed=(uint32_t)b0|((uint32_t)b1<<16);
          uint32_t tr=(packed<<5)+0x7FF88000u;
          half h0=sycl::bit_cast<half>((uint16_t)(tr&0xFFFFu)), h1=sycl::bit_cast<half>((uint16_t)((tr>>16)&0xFFFFu));
          total+=(float)h0; total+=(float)h1;
          outr[c]=h0; outr[c+1u]=h1;
        }
        float trh=(float)(half)total;
        float recip; esimd::simd<float,1> one(1.0f), th(trh); recip=(float)(half)(one/th)[0]; // hw div, ESIMD
        TB[(size_t)r*3]=(float)eh_round(total); TB[(size_t)r*3+1]=trh; TB[(size_t)r*3+2]=recip;
        for(unsigned c=0;c<cols;++c){
          float w=(float)outr[c];
          float mv=(esimd::simd<float,1>(w)*esimd::simd<float,1>(recip))[0];
          outr[c]=half(qr_e4m3_scalar(qr_half_round(mv)));
        }
      }); });
    q.wait();
  }catch(const sycl::exception&e){ printf("ESIMD THREW: %.150s\n",e.what()); return 2; }
  std::vector<half> a(rows*cols), b(rows*cols);
  q.memcpy(a.data(),OA,a.size()*2).wait(); q.memcpy(b.data(),OB,b.size()*2).wait();
  auto cmpf=[&](float* X,float* Y,const char* nm){
    std::vector<float> xa(rows*cols), yb(rows*cols);
    q.memcpy(xa.data(),X,rows*cols*4).wait(); q.memcpy(yb.data(),Y,rows*cols*4).wait();
    uint64_t d=0; size_t first=0; bool any=false;
    for(size_t i=0;i<xa.size();++i) if(sycl::bit_cast<uint32_t>(xa[i])!=sycl::bit_cast<uint32_t>(yb[i])){ d++; if(!any){first=i;any=true;} }
    printf("  stage %-14s differ %llu/%zu\n",nm,(unsigned long long)d,xa.size());
    if(d) printf("      first idx=%zu A=%.9g B=%.9g\n",first,xa[first],yb[first]);
  };
  cmpf(MA,MB,"half_round(l)"); cmpf(PA,PB,"after-clamp");
  { std::vector<float> ta(rows*3),tb(rows*3);
    q.memcpy(ta.data(),TA,rows*3*4).wait(); q.memcpy(tb.data(),TB,rows*3*4).wait();
    uint64_t d1=0,d2=0,d3=0;
    for(size_t r=0;r<rows;++r){
      if(sycl::bit_cast<uint32_t>(ta[r*3])!=sycl::bit_cast<uint32_t>(tb[r*3]))d1++;
      if(sycl::bit_cast<uint32_t>(ta[r*3+1])!=sycl::bit_cast<uint32_t>(tb[r*3+1]))d2++;
      if(sycl::bit_cast<uint32_t>(ta[r*3+2])!=sycl::bit_cast<uint32_t>(tb[r*3+2]))d3++;
    }
    printf("  stage total=%llu trh=%llu recip=%llu (of %u) first r0: A tot=%.6f recip=%.8f B tot=%.6f recip=%.8f\n",
      (unsigned long long)d1,(unsigned long long)d2,(unsigned long long)d3,rows,ta[0],ta[2],tb[0],tb[2]);
  }
  uint64_t diff=0;
  for(size_t i=0;i<a.size();++i)
    if(sycl::bit_cast<uint16_t>(a[i])!=sycl::bit_cast<uint16_t>(b[i])) diff++;
  printf("softmax plain(cr_*) vs ESIMD(eh_*): %llu/%zu differ -> %s\n",
    (unsigned long long)diff,a.size(), diff==0?"BIT-EXACT (P4 safe in v2)":"MISMATCH (v2 P4 needs work)");
  return 0;
}
