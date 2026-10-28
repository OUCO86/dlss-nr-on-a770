// bench_tail.cpp -- P8-k2: the ffn residual tail is MLP-bound (46 GB/s = 1/10th
// DRAM; the row-parallel wide form measured WIDTH-INSENSITIVE). The MLP lever:
// R rows per thread = R INDEPENDENT load streams (the loads issue back-to-back
// before any dependency chain consumes them). Bit-exact is the same argument as
// P8-k (epi=0 identity, per-lane single-rounding FMA). Frame shape = the stem's
// M=522240 x 32 f32 (dS + dC2 reads, Cout write).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <chrono>
#include <functional>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template <int R>
static void tail_rows(queue& q, const float* dSkip, const float* dC2, const float* cp,
                      float* Cout, unsigned M) {
    q.parallel_for(sycl::range(M / R), [=](item<1> it) SYCL_ESIMD_KERNEL {
        unsigned row0 = (unsigned)it.get_id(0) * R;
        size_t base = (size_t)row0 * 32u;
        esimd::simd<float,32> sk[R], c2[R];
        #pragma unroll
        for (int r = 0; r < R; ++r)
            sk[r] = esimd::block_load<float,32>(dSkip + base + (size_t)r*32u, esimd::overaligned_tag<16>{});
        #pragma unroll
        for (int r = 0; r < R; ++r)
            c2[r] = esimd::block_load<float,32>(dC2 + base + (size_t)r*32u, esimd::overaligned_tag<16>{});
        esimd::simd<float,32> cv = esimd::block_load<float,32>(cp, esimd::overaligned_tag<16>{});
        #pragma unroll
        for (int r = 0; r < R; ++r) {
            esimd::simd<float,32> total = sk[r] * cv + c2[r];
            esimd::block_store<float,32>(Cout + base + (size_t)r*32u, total, esimd::overaligned_tag<16>{});
        }
    });
}
// the scalar reference (the pre-P8-k form) via plain SYCL:
static void tail_scalar(queue& q, const float* dSkip, const float* dC2, const float* cp,
                        float* Cout, unsigned M) {
    q.parallel_for(range((size_t)M*32), [=](item<1> it){
        size_t i = it.get_id(0);
        Cout[i] = std::fma(dSkip[i], cp[i % 32u], dC2[i]);
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
  unsigned M=522240;   // the stem shape
  std::vector<float> dS((size_t)M*32), dC((size_t)M*32), cp(32);
  std::mt19937 rng(5); std::uniform_real_distribution<float> df(-4.f,4.f);
  for(auto&x:dS)x=df(rng); for(auto&x:dC)x=df(rng); for(auto&x:cp)x=df(rng)*0.1f;
  float *a=malloc_device<float>(dS.size(),q), *b=malloc_device<float>(dC.size(),q),
        *c=malloc_device<float>(32,q), *o1=malloc_device<float>(dS.size(),q),
        *o2=malloc_device<float>(dS.size(),q);
  q.memcpy(a,dS.data(),dS.size()*4); q.memcpy(b,dC.data(),dC.size()*4);
  q.memcpy(c,cp.data(),128); q.wait();
  double bs=tm([&]{ tail_scalar(q,a,b,c,o1,M); },15);
  double b1=tm([&]{ tail_rows<1>(q,a,b,c,o2,M); },15);
  double b2=tm([&]{ tail_rows<2>(q,a,b,c,o2,M); },15);
  double b4=tm([&]{ tail_rows<4>(q,a,b,c,o2,M); },15);
  double b8=tm([&]{ tail_rows<8>(q,a,b,c,o2,M); },15);
  // bit-exactness of the R=4 form vs the scalar (std::fma = the same single rounding):
  tail_scalar(q,a,b,c,o1,M); q.wait();
  tail_rows<4>(q,a,b,c,o2,M); q.wait();
  std::vector<float> h1(dS.size()), h2(dS.size());
  q.memcpy(h1.data(),o1,h1.size()*4).wait(); q.memcpy(h2.data(),o2,h2.size()*4).wait();
  size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
  double bytes=(double)M*32*4*3;
  printf("M=%u x32 f32 tail: scalar=%7.4f  R1=%7.4f  R2=%7.4f  R4=%7.4f  R8=%7.4f ms\n", M,bs,b1,b2,b4,b8);
  printf("best GB/s: scalar %.0f  R1 %.0f  R2 %.0f  R4 %.0f  R8 %.0f   (traffic %.0fMB) diff(R4 vs scalar)=%zu\n",
         bytes/bs/1e6,bytes/b1/1e6,bytes/b2/1e6,bytes/b4/1e6,bytes/b8/1e6,bytes/1e6,diff);
  return 0;
}
