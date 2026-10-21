// bench_fma.cpp -- section 93: ISOLATE the 13/522240 mismatches of the residual-fma fused
// store (gemm_res, reverted). The split pass uses sycl::fma(sk, cp[col], acc) = ONE fused
// rounding. Question: which ESIMD spelling reproduces it bit-exactly?
//   0 = scalar sk*cc + acc        (the gemm_res spelling that gave 13 mismatches)
//   1 = simd<float,8> sk*cc+acc   (SIMD-typed: gate_esimd lesson says SIMD ops don't contract)
//   2 = two-step: t=sk*cc; t+acc with simd<float,1> (forced DOUBLE rounding = NOT fma)
// golden = host std::fma (IEEE single rounding) + qr_publish chain.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
#include <cmath>
#include <random>
#include "publish_kernel.hpp"
#include "gemm_s8_v8_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int N=1048576;
  std::vector<float> sk(N),cp(N),acc(N);
  std::mt19937 rng(7);
  std::uniform_real_distribution<float> dsk(-3.f,3.f), dcp(-2.f,2.f), dacc(-50.f,50.f);
  for(int i=0;i<N;++i){ sk[i]=dsk(rng); cp[i]=dcp(rng); acc[i]=dacc(rng); }
  float* dSk=(float*)malloc_device(N*4,q); float* dCp=(float*)malloc_device(N*4,q);
  float* dAc=(float*)malloc_device(N*4,q); float* dOut=(float*)malloc_device(N*4,q);
  q.memcpy(dSk,sk.data(),N*4).wait(); q.memcpy(dCp,cp.data(),N*4).wait(); q.memcpy(dAc,acc.data(),N*4).wait();
  const unsigned epi=1u;   // e4m3 publish (the ffn_stem/merge pass-C form)
  std::vector<float> gold(N);
  for(int i=0;i<N;++i) gold[i]=qr_publish(epi, std::fmaf(sk[i],cp[i],acc[i]));
  auto run=[&](int variant){
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range((size_t)N),range(32u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint i=(uint)it.get_global_id(0);
        float s=dSk[i], c=dCp[i], a=dAc[i], total;
        if(variant==3){ total = sycl::fma(s,c,a); }
        else if(variant==0){ total = s*c + a; }
        else if(variant==1){
          esimd::simd<float,1> S(s),C(c),A(a);
          total = (S*C + A)[0];
        } else {
          esimd::simd<float,1> S(s),C(c),A(a);
          esimd::simd<float,1> T=S*C;          // rounded product
          total = (T + A)[0];                  // then add = DOUBLE rounding
        }
        dOut[i]=s8v8::pub_esimd(epi,total);
      }); });
    q.wait();
    std::vector<float> got(N); q.memcpy(got.data(),dOut,N*4).wait();
    int bad=0; for(int i=0;i<N;++i) if(bit_cast<uint32_t>(got[i])!=bit_cast<uint32_t>(gold[i])) bad++;
    printf("variant %d: %d/%d mismatch\n",variant,bad,N);
  };
  run(0); run(1); run(2); run(3);
  return 0;
}
