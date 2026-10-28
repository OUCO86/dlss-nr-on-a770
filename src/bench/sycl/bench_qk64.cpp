// bench_qk64.cpp -- P8-j: K=64 rowthread (128B/row transactions, 158 GB/s) vs
// MULTI-ROW threads: thread owns R consecutive rows (row-major = ONE contiguous
// 128R-byte read; per-row hmax segments keep the values bit-identical).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include "quantize_row_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
template <int R>
static void qr_k64_multi(sycl::queue& q, sycl::half* a_src, sycl::uint2* packed,
                        float* scales, unsigned m) {
    q.parallel_for(sycl::range(m / R), [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        unsigned row0 = (unsigned)it.get_id(0) * R;
        const size_t base = (size_t)row0 * 64u;
        esimd::simd<sycl::half,64*R> reg = esimd::convert<sycl::half>(
            esimd::block_load<sycl::half,64*R>(a_src + base, esimd::overaligned_tag<16>{}));
        auto f = esimd::convert<float>(reg);
        for (int r2 = 0; r2 < R; ++r2) {
            esimd::simd<float,64> seg = f.template select<64,1>(r2*64);
            float peak = esimd::hmax<float,float,64>(esimd::abs(seg));
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            scales[row0 + r2] = scale;
            esimd::simd<float,64> qq = esimd::div_ieee<float,64>(seg, esimd::simd<float,64>(scale));
            qq = esimd::min(esimd::max(esimd::rnde<float,64>(qq), esimd::simd<float,64>(-127.f)), esimd::simd<float,64>(127.f));
            esimd::block_store<int8_t,64>((int8_t*)packed + base + (size_t)r2*64u,
                esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
        }
    });
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  for(unsigned M : {32640u, 35712u, 33728u, 34560u}){
    std::vector<half> hsrc((size_t)M*64);
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hsrc)x=half(df(rng));
    half* dsrc=malloc_device<half>((size_t)M*64,q);
    uint2* pk=malloc_device<uint2>((size_t)M*64,q);      // M*K int8 = M*K bytes; uint2 = 4B: M*16
    uint2* pk2=malloc_device<uint2>((size_t)M*64,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    float* sc2=(float*)malloc_device((size_t)M*4,q);
    q.memcpy(dsrc,hsrc.data(),(size_t)M*64*2).wait();
    auto tm=[&](std::function<void()> f,int n)->double{
      f(); q.wait(); auto t0=std::chrono::steady_clock::now();
      for(int i=0;i<n;++i) f(); q.wait();
      return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
    double b1=tm([&]{ qr_launch_esimd(q,dev,dsrc,pk,sc,M,64u); },15);
    double b2=tm([&]{ qr_k64_multi<2>(q,dsrc,pk2,sc2,M); },15);
    double b4=tm([&]{ qr_k64_multi<4>(q,dsrc,pk2,sc2,M); },15);
    // bit-exactness vs the shipped rowthread form:
    qr_launch_esimd(q,dev,dsrc,pk,sc,M,64u); q.wait();
    qr_k64_multi<4>(q,dsrc,pk2,sc2,M); q.wait();
    std::vector<uint8_t> h1((size_t)M*64),h2((size_t)M*64);
    q.memcpy(h1.data(),pk,(size_t)M*64).wait(); q.memcpy(h2.data(),pk2,(size_t)M*64).wait();
    size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
    std::vector<float> s1(M),s2(M);
    q.memcpy(s1.data(),sc,(size_t)M*4).wait(); q.memcpy(s2.data(),sc2,(size_t)M*4).wait();
    size_t sdiff=0; for(size_t i=0;i<M;++i) if(s1[i]!=s2[i]) sdiff++;
    double bytes=(double)M*64*3.0+M*4;
    printf("M=%-6u rowthread=%7.4f  x2=%7.4f  x4=%7.4f ms  (%.0f -> %.0f GB/s)  diff=%zu/%zu sdiff=%zu\n",
           M,b1,b2,b4,bytes/b1/1e6,bytes/b4/1e6,diff,h1.size(),sdiff);
    free(dsrc,q);free(pk,q);free(pk2,q);free(sc,q);free(sc2,q);
  }
  return 0;
}
