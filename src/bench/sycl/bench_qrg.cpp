// bench_qrg.cpp -- P8-j: the K>512 double-read ESIMD path (640x2048 = 23 GB/s,
// 192x4096 = 14 GB/s) vs a WORKGROUP-PER-ROW SINGLE-READ form: LW=64 threads own
// one row; each thread holds CH=K/64 elements IN REGISTERS (1-4 x simd<half,16>);
// the row peak = hmax in-thread then a 64-float SLM cross-thread max (float max is
// associative/commutative -> bit-identical to any order, the rowthread precedent);
// quantize from the registers (NO second global read). Global traffic 2x -> 1x.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <functional>
#include "quantize_row_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// CH16 = K/64/16 blocks of 16 halves per thread. K=1024->1, 2048->2, 4096->4.
template <int CH16>
static void qr_rowgroup(sycl::queue& q, sycl::half* a_src, sycl::uint2* packed,
                        float* scales, unsigned m) {
    constexpr int K = CH16 * 16 * 64;
    q.submit([&](handler& h){
      h.parallel_for(sycl::nd_range<1>(sycl::range(m * 64u), sycl::range(64u)),
        [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<256>();   // the P8-c SLM rule: declare EXACTLY 256B (a bucket boundary) -- 64 float slots
        unsigned row = (unsigned)it.get_group(0);
        unsigned tid = (unsigned)it.get_local_id(0);
        const size_t base = (size_t)row * K;
        esimd::simd<sycl::half,16> reg[CH16];
        esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
        #pragma unroll
        for (int c = 0; c < CH16; ++c) {
            reg[c] = esimd::block_load<sycl::half,16>(a_src + base + (size_t)(c*64u + tid)*16u,
                                                      esimd::overaligned_tag<16>{});
            mx = esimd::max(mx, esimd::abs(esimd::convert<float>(reg[c])));
        }
        float local = esimd::hmax<float,float,16>(mx);
        esimd::slm_block_store(tid * 4u, esimd::simd<float,1>(local), esimd::overaligned_tag<16>{});
        esimd::barrier();
        esimd::simd<float,64> all = esimd::slm_block_load<float,64>(0u, esimd::overaligned_tag<16>{});
        float peak = esimd::hmax<float,float,64>(all);
        const float scale = (peak == 0.0f) ? 1.0f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
        if (tid == 0u) scales[row] = scale;
        #pragma unroll
        for (int c = 0; c < CH16; ++c) {
            esimd::simd<float,16> f = esimd::convert<float>(reg[c]);
            esimd::simd<float,16> qq = esimd::div_ieee<float,16>(f, esimd::simd<float,16>(scale));
            qq = esimd::min(esimd::max(esimd::rnde<float,16>(qq), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
            esimd::block_store<int8_t,16>((int8_t*)packed + base + (size_t)(c*64u + tid)*16u,
                esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
        }
      });
    });
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait(); auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f(); q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  struct Cfg{unsigned M,K;};
  std::vector<Cfg> cfgs={{640,2048},{192,1024},{192,4096},{2040,1024},{32640,1024}};
  for(auto cf:cfgs){
    unsigned M=cf.M,K=cf.K;
    std::vector<half> hsrc((size_t)M*K);
    std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hsrc)x=half(df(rng));
    half* dsrc=malloc_device<half>((size_t)M*K,q);
    uint2* pk=malloc_device<uint2>((size_t)M*K/4,q);
    uint2* pk2=malloc_device<uint2>((size_t)M*K/4,q);
    float* sc=(float*)malloc_device((size_t)M*4,q);
    float* sc2=(float*)malloc_device((size_t)M*4,q);
    q.memcpy(dsrc,hsrc.data(),(size_t)M*K*2).wait();
    double b1=tm([&]{ qr_launch_esimd(q,dev,dsrc,pk,sc,M,K); },15);
    double b2=0;
    if(K==1024) b2=tm([&]{ qr_rowgroup<1>(q,dsrc,pk2,sc2,M); },15);
    if(K==2048) b2=tm([&]{ qr_rowgroup<2>(q,dsrc,pk2,sc2,M); },15);
    if(K==4096) b2=tm([&]{ qr_rowgroup<4>(q,dsrc,pk2,sc2,M); },15);
    if(K==1024){ qr_launch_esimd(q,dev,dsrc,pk,sc,M,K); qr_rowgroup<1>(q,dsrc,pk2,sc2,M); }
    if(K==2048){ qr_launch_esimd(q,dev,dsrc,pk,sc,M,K); qr_rowgroup<2>(q,dsrc,pk2,sc2,M); }
    if(K==4096){ qr_launch_esimd(q,dev,dsrc,pk,sc,M,K); qr_rowgroup<4>(q,dsrc,pk2,sc2,M); }
    q.wait();
    std::vector<uint8_t> h1((size_t)M*K),h2((size_t)M*K);
    q.memcpy(h1.data(),pk,(size_t)M*K).wait(); q.memcpy(h2.data(),pk2,(size_t)M*K).wait();
    size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
    std::vector<float> s1(M),s2(M);
    q.memcpy(s1.data(),sc,(size_t)M*4).wait(); q.memcpy(s2.data(),sc2,(size_t)M*4).wait();
    size_t sdiff=0; for(size_t i=0;i<M;++i) if(s1[i]!=s2[i]) sdiff++;
    double bytes=(double)M*K*3.0+M*4;
    printf("M=%-6u K=%-5u  double-read=%8.4f  rowgroup-1read=%8.4f ms (%.0f -> %.0f GB/s)  diff=%zu sdiff=%zu\n",
           M,K,b1,b2,bytes/b1/1e6,bytes/b2/1e6,diff,sdiff);
    free(dsrc,q);free(pk,q);free(pk2,q);free(sc,q);free(sc2,q);
  }
  return 0;
}
