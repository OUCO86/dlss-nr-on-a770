// bench_pubvec.cpp -- section 99: WHY did the vectorized publish break the frame
// (gates GREEN but end-to-end 0%)? A/B the scalar pub_esimd chain vs the vector
// pub_vec_v8 chain on frame-real-ish data, bit by bit, for epi 0/1/2/3/4.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include "gemm_s8_v8_kernel.hpp"
#include "publish_kernel.hpp"   // qr_publish = the PLAIN-kernel publish chain (proven bit-identical to s8v8::pub_esimd by the §92 gates)
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int N=1<<20;
  std::vector<float> in(N);
  std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
  std::uniform_real_distribution<float> df2(-0.5f,0.5f);
  for(auto&x:in)x=(rng()%2)?df(rng):df2(rng);
  float* din=malloc_device<float>(N,q); float* dout=malloc_device<float>(N,q);
  q.memcpy(din,in.data(),(size_t)N*4).wait();
  for(unsigned epi : {0u,1u,2u,3u,4u}){
    q.parallel_for(range((size_t)N),[=](item<1> it){
      int i=(int)it.get_id(0);
      dout[i]=qr_publish(epi, din[i]);
    }).wait();
    std::vector<float> h1(N); q.memcpy(h1.data(),dout,(size_t)N*4).wait();
    q.parallel_for(range((size_t)N/8),[=](item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      int i=(int)it.get_id(0)*8;
      esimd::simd<float,8> v(din+i);
      v.copy_to(dout+i);
      // NOTE: pub_vec_v8 lives in the WORKING-TREE header only if present; replicate
      // the vector chain HERE so this bench survives the git revert:
      auto gate=[&](esimd::simd<float,8> x) SYCL_ESIMD_FUNCTION {
        esimd::simd<float,8> wide=esimd::convert<float>(esimd::convert<sycl::half>(x));
        esimd::simd<float,8> clamped=(esimd::min)((esimd::max)(wide,esimd::simd<float,8>(-4.f)),esimd::simd<float,8>(4.f));
        esimd::simd<float,8> ac=esimd::abs(clamped);
        esimd::simd<float,8> L=ac*esimd::simd<float,8>(-0.055908203125f);
        L=L+esimd::simd<float,8>(0.447265625f);
        esimd::simd<float,8> l0=esimd::convert<float>(esimd::convert<sycl::half>(L));
        esimd::simd<float,8> M=l0*clamped; M=M+esimd::simd<float,8>(0.89453125f);
        esimd::simd<float,8> l1=esimd::convert<float>(esimd::convert<sycl::half>(M));
        esimd::simd<float,8> R=wide*l1;
        return esimd::convert<float>(esimd::convert<sycl::half>(R)); };
      auto e4=[&](esimd::simd<float,8> x) SYCL_ESIMD_FUNCTION {
        esimd::simd<float,8> mag=esimd::abs(x);
        mag=(esimd::min)(mag,esimd::simd<float,8>(448.f));
        esimd::simd<int32_t,8> mb; mb=mag.template bit_cast_view<int32_t>();
        esimd::simd<int32_t,8> exp=(mb>>23)&esimd::simd<int32_t,8>(0xFF);
        exp=(esimd::max)(exp,esimd::simd<int32_t,8>(121))-3;
        esimd::simd<int32_t,8> sb=exp<<23; esimd::simd<float,8> step; step=sb.template bit_cast_view<float>();
        esimd::simd<int32_t,8> rb=(esimd::simd<int32_t,8>(254)-exp)<<23; esimd::simd<float,8> recip; recip=rb.template bit_cast_view<float>();
        esimd::simd<float,8> t=mag*recip;
        esimd::simd<float,8> r=esimd::rnde<float>(t)*step;
        esimd::simd<int32_t,8> ri; ri=r.template bit_cast_view<int32_t>();
        esimd::simd<int32_t,8> negm=x<esimd::simd<float,8>(0.f);
        esimd::simd<int32_t,8> out=(ri&esimd::simd<int32_t,8>(0x7FFFFFFF))|(negm<<31);
        esimd::simd<float,8> res; res=out.template bit_cast_view<float>();
        return res; };
      esimd::simd<float,8> v2(din+i);
      if(epi==2u||epi==3u) v2=gate(v2);
      if(epi==1u||epi==3u) v2=e4(v2);
      if(epi==4u) v2=esimd::convert<float>(esimd::convert<sycl::half>(v2));
      v2.copy_to(dout+i);
    }).wait();
    std::vector<float> h2(N); q.memcpy(h2.data(),dout,(size_t)N*4).wait();
    size_t diff=0; uint64_t firstbits1=0,firstbits2=0; int firsti=-1;
    for(int i=0;i<N;++i){
      uint32_t b1=0,b2=0; memcpy(&b1,&h1[i],4); memcpy(&b2,&h2[i],4);
      if(b1!=b2){ diff++; if(firsti<0){firsti=i;firstbits1=b1;firstbits2=b2;} }
    }
    printf("epi=%u: scalar-vs-vector diff %zu / %d %s\n",epi,diff,N,diff==0?"IDENTICAL":"DIVERGE");
    if(firsti>=0){
      float f1,f2; memcpy(&f1,&firstbits1,4); memcpy(&f2,&firstbits2,4);
      printf("   first i=%d in=%.9g scalar=%.9g(0x%08x) vector=%.9g(0x%08x)\n",
             firsti,in[firsti],f1,firstbits1,f2,firstbits2);
    }
  }
  return 0;
}
