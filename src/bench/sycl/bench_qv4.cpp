// bench_qv4.cpp -- B3-2 quant leg (the leg map says the quant family sits on the
// critical path: Q_STOP=9 = -6.9ms). bench_qv3 measured the shipping rowthread at
// the frame shapes: K=256 -> 355 GB/s (fine), K=128 -> 181, K=64 -> 221 GB/s.
// The gap is ARITHMETIC, not guesswork: rowthread = ONE row per thread; at K=64 a
// thread moves 128B read + 64B write = sub-transaction granularity (the DRAM/L2
// sector is 64B; a warp of 32 threads on 32 distinct 128B-apart rows = 32 sectors
// spread over 4KB = poor row-buffer locality). FIX = R rows per thread, R*K halfs
// CONTIGUOUS per thread (K=64: R=8 -> 1KB read + 512B write per thread; K=128:
// R=4; K=256: R=2). Each row's peak = its own hmax (bit-exact: the rowthread
// hmax order per row is unchanged), encode per row. Grid shrinks by R.
// Judges: (1) byte-diff vs the shipping rowthread kernel (pk + scale), (2) GB/s
// at the frame shapes, (3) then the dll switch + family marginal + frame A/B.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
using namespace sycl;

// shipping reference: rowthread (quantize_row_kernel.hpp VERBATIM, inlined)
template <int KMAX>
static event qr_ref(queue& q, const half* a, uint2* pk, float* sc, unsigned m){
  return q.parallel_for(range(m), [=](item<1> it) SYCL_ESIMD_KERNEL {
    namespace esimd = sycl::ext::intel::esimd;
    unsigned row=(unsigned)it.get_id(0); const size_t base=(size_t)row*KMAX;
    esimd::simd<float,KMAX> reg=esimd::convert<float>(
      esimd::block_load<half,KMAX>(a+base, esimd::overaligned_tag<16>{}));
    float peak=esimd::hmax<float,float,KMAX>(esimd::abs(reg));
    const float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
    sc[row]=scale;
    esimd::simd<float,KMAX> qq=esimd::div_ieee<float,KMAX>(reg,esimd::simd<float,KMAX>(scale));
    qq=esimd::min(esimd::max(esimd::rnde<float,KMAX>(qq),esimd::simd<float,KMAX>(-127.f)),esimd::simd<float,KMAX>(127.f));
    esimd::block_store<int8_t,KMAX>((int8_t*)pk+base, esimd::convert<int8_t>(esimd::convert<int>(qq)), esimd::overaligned_tag<16>{});
  });
}
// NEW: R rows per thread, R*KMAX contiguous halfs per thread.
template <int KMAX, int R>
static event qr_multirow(queue& q, const half* a, uint2* pk, float* sc, unsigned m){
  return q.parallel_for(range((size_t)m/R + ((m%R)?1:0)), [=](item<1> it) SYCL_ESIMD_KERNEL {
    namespace esimd = sycl::ext::intel::esimd;
    unsigned r0 = (unsigned)it.get_id(0) * R;
    const size_t base = (size_t)r0 * KMAX;
    // ONE contiguous load of R*KMAX halfs (R loads of KMAX: each still a 32/64/128B
    // block; adjacent in memory = one coalesced region per thread).
    esimd::simd<float,KMAX*R> reg;
    #pragma unroll
    for (int j = 0; j < R; ++j)
      reg.template select<KMAX,1>(j*KMAX) = esimd::convert<float>(
        esimd::block_load<half,KMAX>(a + base + (size_t)j*KMAX, esimd::overaligned_tag<16>{}));
    esimd::simd<int8_t,KMAX*R> out;
    #pragma unroll
    for (int j = 0; j < R; ++j) {
      esimd::simd<float,KMAX> seg = reg.template select<KMAX,1>(j*KMAX);
      float peak=esimd::hmax<float,float,KMAX>(esimd::abs(seg));
      const float scale=(peak==0.f)?1.f:esimd::div_ieee<float,1>(esimd::simd<float,1>(peak),esimd::simd<float,1>(127.f))[0];
      if (r0+(unsigned)j < m) sc[r0+j]=scale;
      esimd::simd<float,KMAX> qq=esimd::div_ieee<float,KMAX>(seg,esimd::simd<float,KMAX>(scale));
      qq=esimd::min(esimd::max(esimd::rnde<float,KMAX>(qq),esimd::simd<float,KMAX>(-127.f)),esimd::simd<float,KMAX>(127.f));
      out.template select<KMAX,1>(j*KMAX)=esimd::convert<int8_t>(esimd::convert<int>(qq));
    }
    #pragma unroll
    for (int j = 0; j < R; ++j)
      if (r0+(unsigned)j < m)
        esimd::block_store<int8_t,KMAX>((int8_t*)pk+base+(size_t)j*KMAX,
            out.template select<KMAX,1>(j*KMAX), esimd::overaligned_tag<16>{});
  });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{unsigned M,K,R;};
  // the frame's SURVIVING quant shapes (leg census): (M,K) x count
  std::vector<Cfg> cfgs={{32640,64,8},{8160,128,4},{8160,512,1},{32640,256,2},
                         {2040,256,4},{192,1024,1},{640,2048,1}};
  for(auto cf:cfgs){
    unsigned M=cf.M,K=cf.K,R=cf.R;
    if ((K*R)>4096){ printf("M=%u K=%u R=%u SKIP (reg too big)\n",M,K,R); continue; }
    std::vector<half> hA((size_t)M*K); std::mt19937 rng(4);
    std::uniform_real_distribution<float> df(-6.f,6.f);
    for(auto&x:hA)x=half(df(rng));
    half* dA=malloc_device<half>(hA.size(),q);
    uint2* pk1=malloc_device<uint2>((size_t)M*K/4u,q), *pk2=malloc_device<uint2>((size_t)M*K/4u,q);
    float *s1=malloc_device<float>(M,q), *s2=malloc_device<float>(M,q);
    q.memcpy(dA,hA.data(),hA.size()*2).wait();
    q.memset(pk1,0,(size_t)M*K); q.memset(pk2,0,(size_t)M*K);
    q.memset(s1,0,M*4); q.memset(s2,0,M*4); q.wait();
    // reference by K
    if(K==64) qr_ref<64>(q,dA,pk1,s1,M).wait();
    else if(K==128) qr_ref<128>(q,dA,pk1,s1,M).wait();
    else if(K==256) qr_ref<256>(q,dA,pk1,s1,M).wait();
    else if(K==512) qr_ref<512>(q,dA,pk1,s1,M).wait();
    else { printf("M=%u K=%u: ref unsupported\n",M,K); continue; }
    if(K==64){ if(R==8) qr_multirow<64,8>(q,dA,pk2,s2,M).wait(); }
    else if(K==128){ if(R==4) qr_multirow<128,4>(q,dA,pk2,s2,M).wait(); }
    else if(K==256){ if(R==2) qr_multirow<256,2>(q,dA,pk2,s2,M).wait(); else if(R==4) qr_multirow<256,4>(q,dA,pk2,s2,M).wait(); }
    else if(K==512){ if(R==1) qr_multirow<512,1>(q,dA,pk2,s2,M).wait(); }
    std::vector<uint8_t> b1((size_t)M*K), b2((size_t)M*K);
    std::vector<float> h1(M), h2(M);
    q.memcpy(b1.data(),pk1,(size_t)M*K).wait(); q.memcpy(b2.data(),pk2,(size_t)M*K).wait();
    q.memcpy(h1.data(),s1,M*4).wait(); q.memcpy(h2.data(),s2,M*4).wait();
    size_t d=0; for(size_t i=0;i<(size_t)M*K;++i) if(b1[i]!=b2[i]) ++d;
    size_t ds=0; for(unsigned i=0;i<M;++i){ unsigned u1,u2; memcpy(&u1,&h1[i],4); memcpy(&u2,&h2[i],4); if(u1!=u2) ++ds; }
    auto timeit=[&](std::function<event()> fn){ double best=1e9;
      for(int it=0;it<9;++it){ event e=fn(); e.wait();
        double t=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
        best=std::min(best,t/1e6);} return best;};
    double tr=1e9, tm=1e9;
    if(K==64){ tr=timeit([&]{return qr_ref<64>(q,dA,pk1,s1,M);}); tm=timeit([&]{return qr_multirow<64,8>(q,dA,pk2,s2,M);}); }
    else if(K==128){ tr=timeit([&]{return qr_ref<128>(q,dA,pk1,s1,M);}); tm=timeit([&]{return qr_multirow<128,4>(q,dA,pk2,s2,M);}); }
    else if(K==256){ tr=timeit([&]{return qr_ref<256>(q,dA,pk1,s1,M);}); tm=timeit([&]{return qr_multirow<256,2>(q,dA,pk2,s2,M);}); }
    else if(K==512){ tr=timeit([&]{return qr_ref<512>(q,dA,pk1,s1,M);}); tm=timeit([&]{return qr_multirow<512,1>(q,dA,pk2,s2,M);}); }
    double gb=(double)M*K*(2.0+1.0)/tm/1e6;   // 1-read accounting (f16 in + int8 out)
    printf("M=%-6u K=%-5u R=%u: ref %.4f ms | multi %.4f ms (%.0f GB/s 1-read) pkdiff %zu sdiff %zu %s\n",
           M,K,R,tr,tm,gb,d,ds,d||ds?"NOT-EXACT":"EXACT");
  }
  return 0;
}
