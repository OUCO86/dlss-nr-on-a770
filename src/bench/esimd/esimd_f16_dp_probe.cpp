// esimd_f16_dp_probe.cpp -- CONFIRM the f16 dpas layout the delta probes recovered:
//   A_simd[i*16 + k]            (row-major, k 0..15)
//   B_simd[(k/2)*16 + j*2 + (k%2)]   (OpsPerChannel=2: each dword packs k,k+1 for one j)
//   C[i*8 + j]                  (row-major 8x8)
// Fill Asrc[i][k], Bsrc[k][j] with distinct values, pack per the hypothesis, one dpas,
// compare C to the host dot product sum_k Asrc[i][k]*Bsrc[k][j]. 0/64 bad => confirmed.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu)) if(d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  half hA[128],hB[128];
  for(int i=0;i<8;i++)for(int k=0;k<16;k++) hA[i*16+k]=half(float(i*16+k+1));
  for(int k=0;k<16;k++)for(int j=0;j<8;j++) hB[(k/2)*16 + j*2 + (k%2)]=half(float(k*8+j+1));
  half* dA=malloc_device<half>(128,q); half* dB=malloc_device<half>(128,q);
  float* dC=malloc_device<float>(64,q);
  q.memcpy(dA,hA,256).wait(); q.memcpy(dB,hB,256).wait();
  q.parallel_for(range<1>(1),[=](item<1>) SYCL_ESIMD_KERNEL {
    esimd::simd<half,128> a(dA, esimd::overaligned_tag<16>{});
    esimd::simd<half,128> b(dB, esimd::overaligned_tag<16>{});
    esimd::simd<float,64> c(0.f);
    c = esimd::xmx::dpas<8,8,float>(c,b,a);
    c.copy_to(dC);
  }).wait();
  float got[64]; q.memcpy(got,dC,256).wait();
  int bad=0;
  for(int i=0;i<8;i++)for(int j=0;j<8;j++){
    float exp=0; for(int k=0;k<16;k++) exp += float(i*16+k+1)*float(k*8+j+1);
    if(got[i*8+j]!=exp){bad++; if(bad<=4)printf("  C[%d][%d] got %g exp %g\n",i,j,got[i*8+j],exp);}
  }
  printf("LAYOUT A[i*16+k] B[(k/2)*16+j*2+(k%2)] C[i*8+j]: %s (%d/64 bad)\n", bad?"FALSE":"TRUE", bad);
  return 0;
}
