#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  queue q;
  q.submit([&](handler& h){ h.parallel_for(range(16), [=](item<1> it) SYCL_ESIMD_KERNEL {
    esimd::simd<float,128> c(0.f);
    esimd::simd<half,128> b; esimd::simd<half,256> a;
    c = esimd::xmx::dpas<8,16,float>(c, b, a);   // RC=16 probe
    esimd::simd<float,128> d(0.f);
    d = esimd::xmx::dpas<16,8,float>(d, b, a);   // SD=16 probe
  });}).wait();
  return 0;
}
