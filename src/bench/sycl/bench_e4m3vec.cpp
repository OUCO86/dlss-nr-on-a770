// bench_e4m3vec.cpp -- section 97: branch-free vectorized e4m3 for v2's scalar phases.
// qr_e4m3_scalar has 3 branches (clamp/sign/ties) -> masked-SIMD divergence cost. This is
// the simd<float,N> version: abs/min/bit_cast_view<int>/shifts/rnde(RNE == the scalar
// floor+tie-to-even chain for t in [0,16))/sign via simd_mask ternary. Judge: bit-exact vs
// qr_e4m3_scalar over random +-500 + boundary/tie/-0.0 edges.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include "publish_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template<int N>
static esimd::simd<float,N> e4m3_vec(esimd::simd<float,N> x){
    esimd::simd<float,N> mag = esimd::abs(x);
    mag = (esimd::min)(mag, esimd::simd<float,N>(448.0f));
    esimd::simd<int32_t,N> mb; mb = mag.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> exp = (mb >> 23) & esimd::simd<int32_t,N>(0xFF);
    exp = (esimd::max)(exp, esimd::simd<int32_t,N>(121)) - 3;
    esimd::simd<int32_t,N> sb = exp << 23; esimd::simd<float,N> step; step = sb.template bit_cast_view<float>();
    esimd::simd<int32_t,N> rb = (esimd::simd<int32_t,N>(254) - exp) << 23; esimd::simd<float,N> recip; recip = rb.template bit_cast_view<float>();
    esimd::simd<float,N> t = mag * recip;
    esimd::simd<float,N> r = esimd::rnde<float>(t) * step;
    // sign: the golden uses the PREDICATE (x < 0), not the sign bit -- -0.0 must map to
    // +0. simd_mask converts to a -1/0 int vector; AND the sign bit from that.
    esimd::simd<int32_t,N> ri; ri = r.template bit_cast_view<int32_t>();
    esimd::simd<int32_t,N> negm = x < esimd::simd<float,N>(0.0f);   // 0/1 per element
    esimd::simd<int32_t,N> out = (ri & esimd::simd<int32_t,N>(0x7FFFFFFF)) | (negm << 31);
    esimd::simd<float,N> res; res = out.template bit_cast_view<float>();
    return res;
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int M=4096;
  std::mt19937 rng(3); std::uniform_real_distribution<float> du(-500.f,500.f);
  std::vector<float> in(M);
  for(int i=0;i<M;++i) in[i]=du(rng);
  float edges[]={0.f,-0.f,0.5f,-0.5f,1.5f,-1.5f,2.5f,3.5f,448.f,-448.f,449.f,1e-8f,-1e-8f,
                 0.001953125f,0.00390625f,0.005859375f,260.f,261.f,130.f,131.f,
                 0.0078125f,0.01171875f,-0.0078125f,447.9f,448.1f,1.0e30f,-1.0e30f};
  for(size_t i=0;i<sizeof(edges)/sizeof(float) && (int)i<M; ++i) in[i]=edges[i];
  float* In=(float*)malloc_device(M*4,q); q.memcpy(In,in.data(),M*4).wait();
  float* Ov=(float*)malloc_device(M*4,q); float* Os=(float*)malloc_device(M*4,q);
  q.memset(Ov,0,M*4).wait(); q.memset(Os,0,M*4).wait();
  try{
    q.submit([&](handler& h){
      h.parallel_for(range(M/16),[=](item<1> it) SYCL_ESIMD_KERNEL {
        uint base=(uint)it.get_id(0)*16u;
        esimd::simd<float,16> x(In+base);
        esimd::simd<float,16> y=e4m3_vec<16>(x);
        y.copy_to(Ov+base);
      }); });
    q.wait();
    q.submit([&](handler& h){
      h.parallel_for(range(M),[=](item<1> it){ uint i=(uint)it.get_id(0); Os[i]=qr_e4m3_scalar(In[i]); }); });
    q.wait();
  }catch(const sycl::exception&e){ printf("THREW: %.200s\n",e.what()); return 2; }
  std::vector<float> hv(M),hs(M);
  q.memcpy(hv.data(),Ov,M*4).wait(); q.memcpy(hs.data(),Os,M*4).wait();
  int diff=0;
  for(int i=0;i<M;++i) if(bit_cast<uint32_t>(hv[i])!=bit_cast<uint32_t>(hs[i])) diff++;
  printf("e4m3_vec vs e4m3_scalar: %d/%d differ -> %s\n",diff,M,diff==0?"BIT-EXACT":"MISMATCH");
  int shown=0;
  for(int i=0;i<M && shown<6;++i) if(bit_cast<uint32_t>(hv[i])!=bit_cast<uint32_t>(hs[i])){
    printf("  in=%.9g vec=%.9g(0x%08x) scalar=%.9g(0x%08x)\n",in[i],hv[i],bit_cast<uint32_t>(hv[i]),hs[i],bit_cast<uint32_t>(hs[i])); shown++; }
  return 0;
}
