// bench_dpasm5.cpp -- section 95: A/B decisive. Same dpas body in (1) SYCL_ESIMD_KERNEL and
// (2) PLAIN nd_range kernel. If ESIMD=16 and plain=0, dpas is silently dropped outside ESIMD
// (=> the "plain kernel + XMX intrinsic" mechanism FAILS, must stay ESIMD). If both=16, the
// user's exact mechanism (plain kernel + dpas + shared SLM + group_barrier) WORKS.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* OE=(float*)malloc_device(64*4,q); float* OP=(float*)malloc_device(64*4,q);
  // (1) ESIMD kernel
  q.submit([&](handler& h){
    h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      for(int i=0;i<64;++i) OE[i]=c[i];
    }); });
  // (2) PLAIN kernel, same body
  q.submit([&](handler& h){
    h.parallel_for(range(1u),[=](item<1>) {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      for(int i=0;i<64;++i) OP[i]=c[i];
    }); });
  q.wait();
  std::vector<float> he(64),hp(64);
  q.memcpy(he.data(),OE,256).wait(); q.memcpy(hp.data(),OP,256).wait();
  printf("ESIMD kernel:  c[0..3]=%.1f %.1f %.1f %.1f\n",he[0],he[1],he[2],he[3]);
  printf("PLAIN kernel:  c[0..3]=%.1f %.1f %.1f %.1f\n",hp[0],hp[1],hp[2],hp[3]);
  bool eok=he[0]==16.f, pok=hp[0]==16.f;
  printf("=> ESIMD %s, PLAIN %s\n", eok?"WORKS":"no", pok?"WORKS (user mechanism GO)":"DROPPED (must stay ESIMD)");
  return 0;
}
