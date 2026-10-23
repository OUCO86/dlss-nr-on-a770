// bench_esimops.cpp -- section 96 probe: are the JOINT-kernel-proven scalar helpers
// (ctree::cosine_reciprocal, cr_hmul, qr_e4m3, qr_publish, sycl::fma/min/max/rint,
// ext::intel::math::fdiv_rn) COMPILABLE and CORRECT inside a SYCL_ESIMD_KERNEL? v2 wants
// to copy the joint kernel's arithmetic verbatim into one ESIMD workgroup; this settles
// whether that is legal. Thread0 computes 6 fingerprints in the ESIMD kernel and the same
// 6 in a plain kernel; match = all good.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
using namespace sycl;

static inline void chain(float* o, const float* a){
    // a = 32 floats
    float rec = ctree::cosine_reciprocal(a);
    float m0 = ctree::cr_hmul(a[0], rec);
    float e0 = qr_e4m3(m0);
    float d1 = sycl::ext::intel::math::fdiv_rn(1.0f, e0 + 1.0f);
    float f2 = sycl::fma(a[1], a[2], a[3]);
    float p3 = qr_publish(3u, f2);
    float mm = sycl::min(sycl::max(a[4], 1.03125f), 1.5693359375f);
    float rn = sycl::rint(a[5]);
    o[0]=rec; o[1]=m0; o[2]=e0; o[3]=d1; o[4]=f2; o[5]=p3; o[6]=mm; o[7]=rn;
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  std::vector<float> ha(32); for(int i=0;i<32;++i) ha[i]=0.1f*(i+1)+1.3f;
  float* A=(float*)malloc_device(32*4,q); q.memcpy(A,ha.data(),128).wait();
  float* OE=(float*)malloc_device(8*4,q); float* OP=(float*)malloc_device(8*4,q);
  q.memset(OE,0,32).wait(); q.memset(OP,0,32).wait();
  try{
    q.submit([&](handler& h){
      h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
        float loc[8];
        chain(loc, A);
        for(int i=0;i<8;++i) OE[i]=loc[i];
      }); });
    q.wait();
    printf("ESIMD variant COMPILED+RAN\n");
  }catch(const sycl::exception&e){ printf("ESIMD THREW: %.120s\n",e.what()); return 2; }
  q.submit([&](handler& h){
    h.parallel_for(range(1u),[=](item<1> it){
      float loc[8];
      chain(loc, A);
      for(int i=0;i<8;++i) OP[i]=loc[i];
    }); });
  q.wait();
  std::vector<float> he(8),hp(8);
  q.memcpy(he.data(),OE,32).wait(); q.memcpy(hp.data(),OP,32).wait();
  int bitmatch=0; for(int i=0;i<8;++i) if(sycl::bit_cast<uint32_t>(he[i])==sycl::bit_cast<uint32_t>(hp[i])) bitmatch++;
  printf("fingerprints: ESIMD vs PLAIN bit-match %d/8\n",bitmatch);
  for(int i=0;i<8;++i) printf("  [%d] esimd=%.9g plain=%.9g\n",i,he[i],hp[i]);
  return bitmatch==8?0:1;
}
