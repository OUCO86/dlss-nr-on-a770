// bench_pchain.cpp -- section 96: complete P-chain arithmetic audit for v2. Each plain-
// context gate-proven kernel (the joint-resident stop-dump-100% normalize chain + softmax
// chain + publish/residual chain) gets an ESIMD twin (esimd::simd<float,1> unfused ops +
// bit_cast + qr_e4m3_scalar + esimd hw-div/esqrt) and we compare BITWISE on random data
// shaped exactly like the v2 phases consume them. This settles ALL remaining phase risks
// (P2 normalize, P4 weights, P7 publish) before the big kernel is written.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "softmax_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static inline float ef_mul(float a,float b){ return (esimd::simd<float,1>(a)*esimd::simd<float,1>(b))[0]; }
static inline float ef_add(float a,float b){ return (esimd::simd<float,1>(a)+esimd::simd<float,1>(b))[0]; }
static inline float ef_div(float a,float b){ return (esimd::simd<float,1>(a)/esimd::simd<float,1>(b))[0]; }
static inline float ef_sqrt(float a){ return (esimd::simd<float,1> esimd::sqrt(esimd::simd<float,1>(a)))[0]; }

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const unsigned ROWS=2048;
  std::mt19937 rng(7); std::uniform_real_distribution<float> df(-6.f,6.f);
  std::vector<float> hf(ROWS*32), bs(ROWS);
  for(auto&x:hf)x=df(rng); for(auto&x:bs)x=df(rng)*0.5f;
  float* F=(float*)malloc_device(hf.size()*4,q); q.memcpy(F,hf.data(),hf.size()*4).wait();
  float* B=(float*)malloc_device(bs.size()*4,q); q.memcpy(B,bs.data(),bs.size()*4).wait();

  // ===== C1: cosine normalize chain (joint P2 verbatim) plain vs ESIMD =====
  {
    half* O1=(half*)malloc_device(ROWS*32*2,q); half* O2=(half*)malloc_device(ROWS*32*2,q);
    q.memset(O1,0,ROWS*64).wait(); q.memset(O2,0,ROWS*64).wait();
    q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it){
      unsigned r=(unsigned)it.get_id(0); float hv[32];
      for(uint c=0;c<32;++c) hv[c]=F[(size_t)r*32+c];
      for(uint c=0;c<32;++c) hv[c]=qr_half_round(hv[c]);
      float recip=ctree::cosine_reciprocal(hv);
      for(uint c=0;c<32;++c) O1[(size_t)r*32+c]=half(qr_e4m3(ctree::cr_hmul(hv[c],recip)));
    });});
    q.wait();
    q.submit([&](handler& h){ h.parallel_for(range(ROWS),[=](item<1> it) SYCL_ESIMD_KERNEL {
      unsigned r=(unsigned)it.get_id(0); float hv[32];
      for(uint c=0;c<32;++c) hv[c]=F[(size_t)r*32+c];
      for(uint c=0;c<32;++c) hv[c]=(float)(half)hv[c];           // qr_half_round twin
      // ctree::cosine_reciprocal twin: the reduce uses cr_hfma/cr_hmul/cr_hadd -- in ESIMD
      // the exact chain per ctree (see cosine_tree_kernel.hpp lines 27-49) with eh_* style
      // half-rounds IS the right form here (the reduce values ARE half containers).
      float partial[4][2],two[4][2],one[4][2];
      for(int lane=0;lane<4;++lane)for(int p=0;p<2;++p){
        int ch=lane*8+2*p;
        float first=ctree::cr_hfma(hv[ch+8],hv[ch+8],ctree::cr_hmul(hv[ch],hv[ch]));
        float second=ctree::cr_hfma(hv[ch+24],hv[ch+24],ctree::cr_hmul(hv[ch+16],hv[ch+16]));
        partial[lane][p]=ctree::cr_hadd(first,second);
      }
      printf("") /*placeholder removed next*/;
      one[0][0]=0; (void)two; (void)one;
      float rec=0; O2[(size_t)r*32]=(half)rec;
    });});
    q.wait();
  }
  printf("C1 draft (ctree inside ESIMD: does it compile?) -- see above errors if any\n");
  return 0;
}
