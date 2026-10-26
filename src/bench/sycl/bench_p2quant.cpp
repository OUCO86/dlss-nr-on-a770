// bench_p2quant.cpp -- section 100 P2 quant bench: WHY is the quant family 46 GB/s?
// Three variants on frame-real shapes (K=64/128/256/512, the 95% of traffic):
//   A. rowthread DIV (the shipped form): div_ieee(reg, scale) per element.
//   B. rowthread RECIP: one IEEE division per ROW (127/peak), then a MULTIPLY per
//      element -- the senior's OWN shipped form (quantize_row.comp:18-20 "the grid is
//      reached by multiplying by 127/peak rather than dividing by the scale: one
//      division a row instead of one a value"). His test comment admits the device
//      scale lands 1 ULP off the correctly-rounded quotient on some rows, and his
//      contract is BOUNDED (packed <=1, scale <=1 ulp, reconstruction <= half-step),
//      NOT bit-exact-vs-numpy. Our fdiv_rn choice made us numpy-exact; if the chain
//      still matches the senior's frames 100% with recip, that was over-tightening.
//   C. pure traffic (load f16 + store int8, no divide) = the bandwidth ceiling.
// Judges: (1) speed of each; (2) packed-element diff count A vs B (how many of the
// 664M/element-per-frame actually flip); (3) the scale's own ulp distribution.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <sycl/ext/intel/math.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template <int KMAX, int MODE>   // 0=DIV 1=RECIP 2=PURE (no rounding work)
auto qr_var() {
    return [=](sycl::half* a_src, int8_t* packed, float* scales, unsigned m) {
        return [=](sycl::item<1> it) SYCL_ESIMD_KERNEL {
        unsigned row = (unsigned)it.get_id(0);
        const size_t base = (size_t)row * KMAX;
        esimd::simd<float,KMAX> reg = esimd::convert<float>(
            esimd::block_load<sycl::half,KMAX>(a_src + base, esimd::overaligned_tag<16>{}));
        if (MODE == 2) {
            esimd::block_store<int8_t,KMAX>(packed + base,
                esimd::convert<int8_t>(esimd::convert<int>(reg)), esimd::overaligned_tag<16>{});
            return;
        }
        float peak = esimd::hmax<float,float,KMAX>(esimd::abs(reg));
        float scale = (peak == 0.0f) ? 1.0f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
        scales[row] = scale;
        esimd::simd<float,KMAX> q;
        if (MODE == 0) {
            q = esimd::div_ieee<float,KMAX>(reg, esimd::simd<float,KMAX>(scale));
        } else {
            // the senior's form: reciprocal = 127/peak ONE division, then a MUL per value
            float recip = (peak == 0.0f) ? 1.0f
                : esimd::div_ieee<float,1>(esimd::simd<float,1>(127.0f), esimd::simd<float,1>(peak))[0];
            q = reg * esimd::simd<float,KMAX>(recip);
        }
        q = esimd::min(esimd::max(esimd::rnde<float,KMAX>(q), esimd::simd<float,KMAX>(-127.f)), esimd::simd<float,KMAX>(127.f));
        esimd::block_store<int8_t,KMAX>(packed + base,
            esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
        };
    };
}

template <int KMAX>
static double timed(queue& q, sycl::half* src, int8_t* pk, float* sc, unsigned m, int mode){
    double best=1e9;
    for(int it=0;it<12;++it){
        event e;
        if(mode==0) e=q.parallel_for(range(m), qr_var<KMAX,0>()(src,pk,sc,m));
        else if(mode==1) e=q.parallel_for(range(m), qr_var<KMAX,1>()(src,pk,sc,m));
        else e=q.parallel_for(range(m), qr_var<KMAX,2>()(src,pk,sc,m));
        e.wait();
        auto s0=e.get_profiling_info<info::event_profiling::command_start>();
        auto t0=e.get_profiling_info<info::event_profiling::command_end>();
        best=std::min(best,(double)(t0-s0)/1e6);
    }
    return best;
}

template <int KMAX>
static void one(queue& q, unsigned m){
    size_t n=(size_t)m*KMAX;
    sycl::half* src = malloc_device<sycl::half>(n,q);
    int8_t* pA = malloc_device<int8_t>(n,q);
    int8_t* pB = malloc_device<int8_t>(n,q);
    float* sA = malloc_device<float>(m,q);
    float* sB = malloc_device<float>(m,q);
    std::vector<sycl::half> h(n);
    std::mt19937 rng(7); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(size_t i=0;i<n;++i) h[i]=sycl::half(df(rng));
    q.memcpy(src,h.data(),n*2).wait();
    double t0=timed<KMAX>(q,src,pA,sA,m,0);
    double t1=timed<KMAX>(q,src,pB,sB,m,1);
    std::vector<int8_t> a(n), b(n);
    std::vector<float> sa(m), sb(m);
    q.memcpy(a.data(),pA,n).wait(); q.memcpy(b.data(),pB,n).wait();
    q.memcpy(sa.data(),sA,m*4).wait(); q.memcpy(sb.data(),sB,m*4).wait();
    size_t diff=0; for(size_t i=0;i<n;++i) if(a[i]!=b[i]) diff++;
    size_t su=0; int maxu=0;
    double t2=timed<KMAX>(q,src,pA,sA,m,2);   // PURE re-writes pA AFTER the captures
    for(unsigned i=0;i<m;++i){ int32_t ua,ub; memcpy(&ua,&sa[i],4); memcpy(&ub,&sb[i],4);
        if(ua!=ub){su++; maxu=std::max(maxu,(int)std::abs(ua-ub));} }
    double trafficMB = n*3.0/1e6;
    printf("K=%4d M=%6u  DIV %7.3fms (%5.0f GB/s)  RECIP %7.3fms (%5.0f GB/s)  PURE %7.3fms (%5.0f GB/s)  | packed-diff %8zu (%.4f%%)  scale-ulp-diff rows %6zu/%u maxulp %d\n",
        KMAX,m,t0,trafficMB/t0,t1,trafficMB/t1,t2,trafficMB/t2,diff,100.0*diff/n,su,m,maxu);
    free(src,q);free(pA,q);free(pB,q);free(sA,q);free(sB,q);
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  // frame-real: K=256 M=32640x? -- the plan's real Ms (sum over calls per K):
  one<64>(q, 2142000u/64);   // K=64  elems 136.8M -> rows ~2.14M (64 calls; one big launch)
  one<128>(q, 104988672u/128);
  one<256>(q, 209059840u/256);
  one<512>(q, 149553152u/512);
  return 0;
}
