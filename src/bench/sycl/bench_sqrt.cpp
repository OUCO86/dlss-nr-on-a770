// bench_sqrt.cpp -- section 93: find the standard-SYCL expression that bit-matches the
// golden's normalize_esimd recip = eh_round(1.0f / esimd::sqrt(norm)). esimd::sqrt is a
// SIMD instruction; sycl::sqrt is scalar. Test which standard-SYCL form reproduces the
// ESIMD chain's bits. x = realistic cosine-norm range.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <sycl/ext/intel/math.hpp>
#include <cstdio>
#include <vector>
#include <random>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  const int N=65536;
  std::vector<float> x(N); std::mt19937 rng(9);
  std::uniform_real_distribution<float> dd(0.00006f, 8.f);
  for(int i=0;i<N;++i) x[i]=dd(rng);
  float* X=(float*)malloc_device(N*4,q); q.memcpy(X,x.data(),N*4).wait();
  float* OE=(float*)malloc_device(N*4,q);   // golden: 1.0f/esimd::sqrt
  float* OS=(float*)malloc_device(N*4,q);   // 1.0f/sycl::sqrt
  float* ON=(float*)malloc_device(N*4,q);   // native::rsqrt
  float* OF=(float*)malloc_device(N*4,q);   // fdiv_rn(1.0f, sycl::sqrt)
  float* ONS=(float*)malloc_device(N*4,q);  // fdiv_rn(1.0f, native::sqrt)
  float* OIM=(float*)malloc_device(N*4,q);  // fdiv_rn(1.0f, ext::intel::math::sqrt)
  q.submit([&](handler&h){ h.parallel_for(nd_range<1>(range((size_t)N),range(32u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
    uint i=(uint)it.get_global_id(0); float v=X[i];
    OE[i]=(float)(half)(1.0f / esimd::sqrt(esimd::simd<float,1>(v))[0]);
  });});
  q.submit([&](handler&h){ h.parallel_for(range((size_t)N),[=](item<1> it){ size_t i=it.get_id(0); float v=X[i];
    OS[i]=(float)(half)(1.0f / sycl::sqrt(v));
    ON[i]=(float)(half)(sycl::native::rsqrt(v));
    OF[i]=(float)(half)(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::sqrt(v)));
    ONS[i]=(float)(half)(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::native::sqrt(v)));
    OIM[i]=(float)(half)(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::ext::intel::math::sqrt(v)));
  });});
  q.wait();
  std::vector<float> oe(N),o(N); q.memcpy(oe.data(),OE,N*4).wait();
  auto cmp=[&](float* buf,const char* nm){ q.memcpy(o.data(),buf,N*4).wait();
    int bad=0; for(int i=0;i<N;++i) if(bit_cast<uint32_t>(oe[i])!=bit_cast<uint32_t>(o[i])) bad++;
    printf("  %-28s: %d/%d mismatch vs golden\n",nm,bad,N); };
  printf("golden = half_round(1.0f/esimd::sqrt(x))\n");
  cmp(OS,"1.0f/sycl::sqrt"); cmp(ON,"native::rsqrt"); cmp(OF,"fdiv_rn(1,sycl::sqrt)");
  cmp(ONS,"fdiv_rn(1,native::sqrt)"); cmp(OIM,"fdiv_rn(1,imf::sqrt)");
  return 0;
}
