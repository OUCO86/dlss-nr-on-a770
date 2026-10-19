// esimd_f16_tile.cpp -- the f16 GEMM tile, standalone (section 81's probe-confirmed
// layout: A_simd[i*16+k] row-major; B_simd[(k/2)*16 + j_local*2 + (k%2)]; C[i*8+j]).
// One work-item = one 16x16 output tile: 2 A row-strips x 2 B col-strips = 4 dpas per
// 16-K step, accumulating. Store is PER ROW (simd<float,64> = 8 rows x 8 cols
// row-major; v1's store pattern). Host checks vs an f32 dot product with within-one
// (K-accumulation order is hardware-defined; the coopmat pairing comes later, section 51).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu)) if(d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  const int M=32,N=32,K=32;                 // 2x2 tiles, 2 K steps
  std::vector<half> A(M*K), B(K*N);
  std::vector<float> Cref(M*N), Cgot(M*N);
  srand(4242);
  for(auto&x:A) x=half((rand()%2001-1000)/500.0f);
  for(auto&x:B) x=half((rand()%2001-1000)/500.0f);
  for(int i=0;i<M;i++)for(int j=0;j<N;j++){float s=0;for(int k=0;k<K;k++)s+=float(A[i*K+k])*float(B[k*N+j]);Cref[i*N+j]=s;}
  int tr_n=M/16, tc_n=N/16, kb_n=K/16;
  std::vector<half> Ap(size_t(tr_n*kb_n*2*128)), Bp(size_t(kb_n*tc_n*2*128));
  for(int tr=0;tr<tr_n;tr++)for(int kc=0;kc<kb_n;kc++)for(int strip=0;strip<2;strip++)
    for(int il=0;il<8;il++)for(int k=0;k<16;k++)
      Ap[((size_t)(tr*kb_n+kc)*2+strip)*128 + il*16 + k] = A[(size_t)(tr*16+strip*8+il)*K + kc*16+k];
  for(int kc=0;kc<kb_n;kc++)for(int tc=0;tc<tc_n;tc++)for(int js=0;js<2;js++)
    for(int k=0;k<16;k++)for(int jl=0;jl<8;jl++)
      Bp[((size_t)(kc*tc_n+tc)*2+js)*128 + (k/2)*16 + jl*2 + (k%2)] = B[(size_t)(kc*16+k)*N + tc*16+js*8+jl];
  half* dA=malloc_device<half>(Ap.size(),q); half* dB=malloc_device<half>(Bp.size(),q);
  float* dC=malloc_device<float>(M*N,q);
  q.memcpy(dA,Ap.data(),Ap.size()*2).wait(); q.memcpy(dB,Bp.data(),Bp.size()*2).wait();
  q.parallel_for(range<1>(tr_n*tc_n),[=](item<1> it) SYCL_ESIMD_KERNEL {
    int t=(int)it.get_id(0); int tr=t/tc_n, tc=t%tc_n;
    esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
    for(int kc=0;kc<kb_n;kc++){
      const half* ab=dA+((size_t)(tr*kb_n+kc)*2)*128;
      const half* bb=dB+((size_t)(kc*tc_n+tc)*2)*128;
      esimd::simd<half,128> a0(ab, esimd::overaligned_tag<16>{});
      esimd::simd<half,128> a1(ab+128, esimd::overaligned_tag<16>{});
      esimd::simd<half,128> b0(bb, esimd::overaligned_tag<16>{});
      esimd::simd<half,128> b1(bb+128, esimd::overaligned_tag<16>{});
      c00=esimd::xmx::dpas<8,8,float>(c00,b0,a0);
      c01=esimd::xmx::dpas<8,8,float>(c01,b1,a0);
      c10=esimd::xmx::dpas<8,8,float>(c10,b0,a1);
      c11=esimd::xmx::dpas<8,8,float>(c11,b1,a1);
    }
    float* out=dC+(size_t)(tr*16)*N+tc*16;
    for(int r=0;r<8;r++){
      esimd::simd<float,8> r00=c00.template select<8,1>(r*8);
      esimd::simd<float,8> r01=c01.template select<8,1>(r*8);
      esimd::simd<float,8> r10=c10.template select<8,1>(r*8);
      esimd::simd<float,8> r11=c11.template select<8,1>(r*8);
      r00.copy_to(out+(size_t)r*N);      r01.copy_to(out+(size_t)r*N+8);
      r10.copy_to(out+(size_t)(8+r)*N);  r11.copy_to(out+(size_t)(8+r)*N+8);
    }
  }).wait();
  q.memcpy(Cgot.data(),dC,M*N*4).wait();
  int bad=0; double maxrel=0;
  for(int i=0;i<M*N;i++){
    double tol=std::max(1e-3, std::fabs(Cref[i])*1e-3);   // within-one-ish for f32 sums of 32 half products
    if(std::fabs(Cgot[i]-Cref[i])>tol){bad++; if(bad<=4)printf("  [%d] got %g exp %g\n",i,Cgot[i],Cref[i]);}
    double rel=std::fabs(Cgot[i]-Cref[i])/(std::fabs(Cref[i])+1e-9); if(rel>maxrel)maxrel=rel;
  }
  printf("F16 TILE 32x32x32: %s (%d bad, maxrel %.2e)\n", bad?"RED":"GREEN", bad, maxrel);
  return bad?1:0;
}
