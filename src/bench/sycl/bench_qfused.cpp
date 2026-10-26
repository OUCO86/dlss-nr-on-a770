// bench_qfused.cpp -- section 100 P2 CONSUMER-SIDE FUSION go/no-go (ESIMD rowthread
// forms, VERBATIM from the shipped qr_kernel_rowthread + the pack copy stage).
// Census: 444/448 quants feed the VERY NEXT op (the int8 gemm's pack/gather pass).
// Two-pass (today): [launch Q] f16->int8 pk (rowthread) ; [launch P] pk->dAp copy.
// Fused (target):    [launch F] f16->dAp directly (rowthread quant, store to the
// pack destination). Kills the quant launch + one full read+write pass.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include <cmath>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template <int KMAX>
auto k_quant(){   // the shipped rowthread form: f16 -> int8 pk + scales
    return [=](sycl::half* a_src, int8_t* packed, float* scales, unsigned m){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            unsigned row = (unsigned)it.get_id(0);
            const size_t base = (size_t)row * KMAX;
            esimd::simd<float,KMAX> reg = esimd::convert<float>(
                esimd::block_load<sycl::half,KMAX>(a_src + base, esimd::overaligned_tag<16>{}));
            float peak = esimd::hmax<float,float,KMAX>(esimd::abs(reg));
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            scales[row] = scale;
            esimd::simd<float,KMAX> q = esimd::div_ieee<float,KMAX>(reg, esimd::simd<float,KMAX>(scale));
            q = esimd::min(esimd::max(esimd::rnde<float,KMAX>(q), esimd::simd<float,KMAX>(-127.f)), esimd::simd<float,KMAX>(127.f));
            esimd::block_store<int8_t,KMAX>(packed + base,
                esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
        };
    };
}
auto k_pack(){   // pk -> dAp, 16-byte vectorized copy (traffic == the real pack's)
    return [=](const int8_t* pk, int8_t* dAp, size_t n){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            size_t i = (size_t)it.get_id(0) * 16u;
            if (i + 16u <= n)
                esimd::block_store<int8_t,16>(dAp + i,
                    esimd::block_load<int8_t,16>(pk + i, esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
        };
    };
}
template <int KMAX>
auto k_fused(){  // f16 -> dAp directly (quant inline at the pack stage)
    return [=](sycl::half* a_src, int8_t* dAp, float* scales, unsigned m){
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
            unsigned row = (unsigned)it.get_id(0);
            const size_t base = (size_t)row * KMAX;
            esimd::simd<float,KMAX> reg = esimd::convert<float>(
                esimd::block_load<sycl::half,KMAX>(a_src + base, esimd::overaligned_tag<16>{}));
            float peak = esimd::hmax<float,float,KMAX>(esimd::abs(reg));
            const float scale = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
            scales[row] = scale;
            esimd::simd<float,KMAX> q = esimd::div_ieee<float,KMAX>(reg, esimd::simd<float,KMAX>(scale));
            q = esimd::min(esimd::max(esimd::rnde<float,KMAX>(q), esimd::simd<float,KMAX>(-127.f)), esimd::simd<float,KMAX>(127.f));
            esimd::block_store<int8_t,KMAX>(dAp + base,
                esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
        };
    };
}

template <int KMAX>
static void one(queue& q, unsigned m, const char* lbl){
    size_t n=(size_t)m*KMAX;
    sycl::half* src = malloc_device<sycl::half>(n,q);
    int8_t* pkA = malloc_device<int8_t>(n,q);
    int8_t* dpA = malloc_device<int8_t>(n,q);
    int8_t* dpB = malloc_device<int8_t>(n,q);
    float* sA = malloc_device<float>(m,q);
    float* sB = malloc_device<float>(m,q);
    std::vector<sycl::half> h(n);
    std::mt19937 rng(11); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    q.memset(pkA,0,n); q.memset(dpA,0,n); q.memset(dpB,0,n); q.wait();
    auto timeit=[&](std::function<std::vector<event>()> fn){
        double best=1e9;
        for(int it=0;it<12;++it){ auto es=fn(); for(auto&e:es) e.wait();
          double t=0; for(auto&e:es) t+=double(e.get_profiling_info<info::event_profiling::command_end>()
                                              - e.get_profiling_info<info::event_profiling::command_start>());
          best=std::min(best,t/1e6);} return best;};
    // two-pass: time the PAIR (sum of both kernels' GPU time; the frame pays one
    // graph-node gap on top for the second launch -- that gap is what the skip probe
    // counted at ~28us/call, NOT measured here).
    double t2 = timeit([&]{
        event e1=q.parallel_for(range(m), k_quant<KMAX>()(src,pkA,sA,m));
        event e2=q.parallel_for(range(n/16u), k_pack()(pkA,dpA,n)); return std::vector<event>{e1,e2}; });
    double tf = timeit([&]{ return std::vector<event>{q.parallel_for(range(m), k_fused<KMAX>()(src,dpB,sB,m))}; });
    std::vector<int8_t> a(n), b(n);
    q.memcpy(a.data(),dpA,n).wait(); q.memcpy(b.data(),dpB,n).wait();
    size_t diff=0; for(size_t i=0;i<n;++i) if(a[i]!=b[i]) diff++;
    printf("%-16s M=%6u K=%4d  two-pass %7.3fms  fused %7.3fms  ratio %.2fx  | packed-diff %zu %s\n",
        lbl,m,KMAX,t2,tf,t2/tf,diff,diff?"NOT-EXACT":"EXACT");
    free(src,q);free(pkA,q);free(dpA,q);free(dpB,q);free(sA,q);free(sB,q);
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  one<64>(q, 32640, "x16 K64");
  one<128>(q, 8160, "x24 K128");
  one<256>(q, 2040, "x32 K256");
  one<512>(q, 640,  "x32 K512");
  one<2048>(q, 640, "x32 K2048");
  one<4096>(q, 192, "x16 K4096");
  return 0;
}
