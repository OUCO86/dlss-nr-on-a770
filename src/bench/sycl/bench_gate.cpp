// bench_gate.cpp -- section 92 ISOLATED test: which ESIMD spelling of the gate polynomial
// is bit-exact vs the golden qr_gate_activation? Stop guessing the fix.
//   0 = plain float * + (current gate_esimd)
//   1 = esimd::simd<float,1> operators (SIMD ops may not contract)
//   2 = explicit two-step with a barrier via (float)(half) on the product first
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
#include <cmath>
#include <random>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static float half_round(float x){ return (float)(sycl::half)x; }
static float golden_gate(float x){
    float wide=half_round(x);
    float clamped=std::fmin(std::fmax(wide,-4.0f),4.0f);
    float linear=(std::fabs(clamped) * -0.055908203125f);
    linear = (linear + 0.447265625f);
    linear = half_round(linear);
    linear = (linear * clamped);
    linear = (linear + 0.89453125f);
    linear = half_round(linear);
    return half_round(wide * linear);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int N=4096;
  std::vector<float> in(N); std::mt19937 rng(1); std::uniform_real_distribution<float> dist(-8.f,8.f);
  for(int i=0;i<N;++i) in[i]=dist(rng);
  float* dIn=(float*)malloc_device(N*4,q); float* dOut=(float*)malloc_device(N*4,q);
  q.memcpy(dIn,in.data(),N*4).wait();
  std::vector<float> gold(N); for(int i=0;i<N;++i) gold[i]=golden_gate(in[i]);
  auto run=[&](int variant){
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range((size_t)N),range(32u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint i=(uint)it.get_global_id(0);
        float x=dIn[i];
        float wide=(float)(half)x;
        float clamped=wide<-4.f?-4.f:(wide>4.f?4.f:wide);
        float ac=clamped<0.f?-clamped:clamped;
        float linear, res;
        if(variant==0){
          linear=ac*-0.055908203125f; linear=(float)(half)(linear+0.447265625f);
          linear=(float)(half)(linear*clamped);
          linear=(float)(half)(linear+0.89453125f);
          res=(float)(half)(wide*linear);
        } else {
          // esimd::simd<float,1> ops: each op is a separate instruction, no contraction
          esimd::simd<float,1> L=esimd::simd<float,1>(ac)*esimd::simd<float,1>(-0.055908203125f);
          L=L+esimd::simd<float,1>(0.447265625f);
          float l0=(float)(half)L[0];
          esimd::simd<float,1> M=esimd::simd<float,1>(l0)*esimd::simd<float,1>(clamped);
          M=M+esimd::simd<float,1>(0.89453125f);
          float l1=(float)(half)M[0];
          esimd::simd<float,1> R=esimd::simd<float,1>(wide)*esimd::simd<float,1>(l1);
          res=(float)(half)R[0];
        }
        dOut[i]=res;
      }); });
    q.wait();
    std::vector<float> got(N); q.memcpy(got.data(),dOut,N*4).wait();
    int bad=0; for(int i=0;i<N;++i) if(sycl::bit_cast<uint32_t>(got[i])!=sycl::bit_cast<uint32_t>(gold[i])) bad++;
    printf("variant %d: %d/%d mismatch\n",variant,bad,N);
  };
  run(0); run(1);
  return 0;
}
