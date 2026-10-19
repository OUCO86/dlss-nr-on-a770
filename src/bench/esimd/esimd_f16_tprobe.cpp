// esimd_f16_tprobe.cpp -- isolate the transposed-B pack: A = identity (16x16), B stored
// (N,K) row-major with Bmem[j][k] = j*16+k+1 (distinct). C[i][j] = sum_k I[i][k]*B[k][j]
// = B[i][j] = Bmem[j][i] = j*16+i+1. If the pack is right, C[i*16+j] == j*16+i+1.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
static const int TS=16;
int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu)) if(d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  const int M=16,N=16,K=16;
  half hA[256], hB[256];
  for(int i=0;i<16;i++)for(int k=0;k<16;k++) hA[i*16+k]=half(i==k?1.f:0.f);
  for(int j=0;j<16;j++)for(int k=0;k<16;k++) hB[j*16+k]=half(float(j*16+k+1));   // (N,K)
  // pack_a row-major
  half Ap[2*128];
  for(int strip=0;strip<2;strip++)for(int il=0;il<8;il++)for(int k=0;k<16;k++)
    Ap[(strip*128)+il*16+k]=hA[(strip*8+il)*16+k];
  // pack_b_t: Bp[((kc*tc_n+tc)*2+js)*128 + (k/2)*16+jl*2+(k%2)] = B[(tc*TS+js*8+jl)*K + kc*TS+k]
  int kb_n=K/TS, tc_n=N/TS;
  half Bp[kb_n*tc_n*2*128];
  for(int kc=0;kc<kb_n;kc++)for(int tc=0;tc<tc_n;tc++)for(int js=0;js<2;js++)
    for(int k=0;k<16;k++)for(int jl=0;jl<8;jl++)
      Bp[((kc*tc_n+tc)*2+js)*128 + (k/2)*16+jl*2+(k%2)] = hB[(tc*TS+js*8+jl)*K + kc*TS+k];
  half* dA=malloc_device<half>(256,q); half* dB=malloc_device<half>(256,q);
  float* dC=malloc_device<float>(256,q);
  q.memcpy(dA,Ap,512).wait(); q.memcpy(dB,Bp,512).wait();
  q.parallel_for(range<1>(1),[=](item<1>) SYCL_ESIMD_KERNEL {
    esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
    esimd::simd<half,128> a0(dA,esimd::overaligned_tag<16>{});
    esimd::simd<half,128> a1(dA+128,esimd::overaligned_tag<16>{});
    esimd::simd<half,128> b0(dB,esimd::overaligned_tag<16>{});
    esimd::simd<half,128> b1(dB+128,esimd::overaligned_tag<16>{});
    c00=esimd::xmx::dpas<8,8,float>(c00,b0,a0);
    c01=esimd::xmx::dpas<8,8,float>(c01,b1,a0);
    c10=esimd::xmx::dpas<8,8,float>(c10,b0,a1);
    c11=esimd::xmx::dpas<8,8,float>(c11,b1,a1);
    float* out=dC;
    for(int r=0;r<8;r++){
      esimd::simd<float,8> r00=c00.template select<8,1>(r*8);
      esimd::simd<float,8> r01=c01.template select<8,1>(r*8);
      esimd::simd<float,8> r10=c10.template select<8,1>(r*8);
      esimd::simd<float,8> r11=c11.template select<8,1>(r*8);
      r00.copy_to(out+(size_t)r*16);      r01.copy_to(out+(size_t)r*16+8);
      r10.copy_to(out+(size_t)(8+r)*16);  r11.copy_to(out+(size_t)(8+r)*16+8);
    }
  }).wait();
  float got[256]; q.memcpy(got,dC,1024).wait();
  int bad=0;
  for(int i=0;i<16;i++)for(int j=0;j<16;j++){
    float exp=float(j*16+i+1);
    if(got[i*16+j]!=exp){bad++; if(bad<=6)printf("  C[%d][%d] got %g exp %g\n",i,j,got[i*16+j],exp);}
  }
  printf("TRANSPOSED PACK: %s (%d/256 bad)\n", bad?"FALSE":"TRUE", bad);
  return 0;
}
