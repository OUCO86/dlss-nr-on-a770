// bench_v9.cpp -- section 99: numeric gate for the v9 fused-quant producer BEFORE wiring
// it into the engine. Judge = the SPLIT CHAIN, not the coopmat frame: run gemm_b (int32
// out) + the v8 pub arithmetic + quantize_row semantics on HOST in numpy-equivalent C++
// (the senior's test_gemm_int8_staged pattern), compare int8 + new_scale elementwise.
// Shapes: the batched family's real N=128 rows: M=2040 K=256 b=8, M=8160 K=128 b=4,
// M=32640 K=64 b=2 (from the shape survey). epi=1 (e4m3) and epi=3 (gate+e4m3).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <cmath>
#include <sycl/ext/intel/math.hpp>
#include "gemm_s8_v9b_kernel.hpp"
#include "pack_device.hpp"
#include "gemm_s8_v8_kernel.hpp"
#include "publish_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  struct Cfg{int M,N,K,b;};
  std::vector<Cfg> cfgs={{32640,128,64,2},{8160,128,128,4}};
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K,b=cf.b; int ldc=N*b;
    int Mp32=((M+31)/32)*32;
    std::mt19937 rng(7);
    std::uniform_int_distribution<int> da(-127,127);
    std::uniform_real_distribution<float> ds(0.001f,4.f);
    std::vector<int8_t> A((size_t)M*K),B((size_t)b*N*K);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as((size_t)Mp32),bs((size_t)ldc);
    for(auto&x:as)x=ds(rng); for(auto&x:bs)x=ds(rng);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
    float *dAs=(float*)malloc_device(as.size()*4,q),*dBs=(float*)malloc_device(bs.size()*4,q);
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(dAs,as.data(),as.size()*4).wait(); q.memcpy(dBs,bs.data(),bs.size()*4).wait();
    // ---- SPLIT reference: v8 pack (per-group) + gemm_b_pub half + qr_kernel ----
    int Mp128=((M+127)/128)*128;
    int8_t* dAp8=(int8_t*)malloc_device((size_t)b*Mp128*K,q);
    int8_t* dBp8=(int8_t*)malloc_device((size_t)b*N*K,q);
    sycl::half* dC8=(sycl::half*)malloc_device((size_t)b*Mp128*ldc*2,q);
    q.memset(dC8,0,(size_t)b*Mp128*ldc*2).wait();
    packdev::gather_pack_a_b(q,dA,dAp8,M,Mp128,K,K,0,b);
    packdev::gather_pack_b_b(q,dB,dBp8,N,K,K,0,b);
    s8v8::gemm_b_pub(q,dAp8,dBp8,dC8,dAs,dBs,M,Mp128,N,K,b,(size_t)Mp128*N? (size_t)Mp128*0+0:0,0,0,0,false,3u);
    // NOTE: gemm_b_pub ldc/sc strides for the flat ldc layout: sc=0? c flat r*ldc+n:
    // gemm_b_pub out = g*sc + r*ldc + col. For the CONCATENATED layout (v9b's c), group g
    // occupies cols [g*N,(g+1)*N) of the SAME row -> out = r*ldc + g*N + j: sc=0, ldc=ldc,
    // col_stride=N, and the B pack must be the CONCATENATED (K x ldc) VNNI = pack_b9b.
    // So the split reference uses v9b's packs with gemm_b_pub geometry BM=32? NO --
    // gemm_b_pub is BM=128. Simplest correct reference: HOST numpy-equivalent (bench_v9's
    // host matmul golden) + host pub + host quant. Do that instead.
    q.wait();
    std::vector<int8_t> hA(A),hB(B);
    std::vector<int32_t> acc((size_t)M*ldc);
    for(int r=0;r<M;++r) for(int n=0;n<ldc;++n){
      int g=n/N, j=n%N; int64_t a=0;
      for(int k=0;k<K;++k) a+=(int64_t)hA[(size_t)r*K+k]*hB[(size_t)g*N*K+(size_t)j*K+k]; // (N x K) transposed
      acc[(size_t)r*ldc+n]=(int32_t)a;
    }
    std::vector<float> pub((size_t)M*ldc);
    for(int r=0;r<M;++r) for(int n=0;n<ldc;++n)
      pub[(size_t)r*ldc+n]=s8v8::pub_esimd(3u,(float)acc[(size_t)r*ldc+n]*as[r]*bs[n]);
    std::vector<int8_t> want((size_t)M*ldc); std::vector<float> wsc(M);
    for(int r=0;r<M;++r){
      float peak=0; for(int n=0;n<ldc;++n){float v=pub[(size_t)r*ldc+n]; v=v<0?-v:v; if(v>peak)peak=v;}

      float sc=(peak==0.f)?1.f:(float)((double)peak/127.0);
      // fdiv_rn(peak,127): peak/127 is EXACT in f32 (127 not pow2) -- use the same
      // correctly-rounded path as the kernel: emulate via double then round? The kernel
      // uses div_ieee (hw RN). Host: (float)((double)peak/127.0) == RN of the exact
      // quotient (double has 53 bits > f32 needs for the round) -- standard trick.
      wsc[r]=sc;
      for(int n=0;n<ldc;++n){
        float v=pub[(size_t)r*ldc+n];
        float q=(float)((double)v/(double)sc);
        int qi=(int)std::rint(q); qi=qi<-127?-127:(qi>127?127:qi);
        want[(size_t)r*ldc+n]=(int8_t)qi;
      }
    }
    // ---- v9b FOLD device run ----
    int8_t* dAp9=(int8_t*)malloc_device((size_t)Mp32*K,q);
    int8_t* dBp9=(int8_t*)malloc_device((size_t)K*ldc,q);
    int8_t* dPk=(int8_t*)malloc_device((size_t)Mp32*ldc,q);
    float* dSc=(float*)malloc_device((size_t)Mp32*4,q);
    q.memset(dPk,0,(size_t)Mp32*ldc).wait(); q.memset(dSc,0,(size_t)Mp32*4).wait();
    s8v9b::pack_a9b(q,dA,dAp9,M,Mp32,K,K);
    s8v9b::pack_b9b(q,dB,dBp9,K,N,ldc,K,(size_t)N*K,b);
    q.wait();
    if(ldc==256) s8v9b::gemm_b_rq9b<256,true>(q,dAp9,dBp9,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp32,K,3u);
    else         s8v9b::gemm_b_rq9b<512,true>(q,dAp9,dBp9,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp32,K,3u);
    q.wait();
    std::vector<int8_t> got((size_t)M*ldc); q.memcpy(got.data(),dPk,(size_t)M*ldc).wait();
    std::vector<float> gsc(M); q.memcpy(gsc.data(),dSc,(size_t)M*4).wait();
    uint64_t vdiff=0,sdiff=0; size_t first=0; bool any=false;
    for(size_t i=0;i<got.size();++i) if(got[i]!=want[i]){vdiff++; if(!any){first=i;any=true;}}
    for(int r=0;r<M;++r) if(!(gsc[r]==wsc[r])) sdiff++;
    printf("M=%d N=%d K=%d b=%d ldc=%d epi3: int8 diff=%llu/%lld scale diff=%llu/%d %s\n",
      M,N,K,b,ldc,(unsigned long long)vdiff,(long long)got.size(),(unsigned long long)sdiff,M,
      vdiff==0&&sdiff==0?"BIT-EXACT vs host golden":"MISMATCH");
    if(any){size_t r=first/ldc,n=first%ldc;
      printf("  first r=%zu n=%zu got=%d want=%d pub=%.6g acc=%d as=%.4g bs=%.4g sc=%.6g\n",
        r,n,(int)got[first],(int)want[first],pub[first],acc[first],as[r],bs[n],wsc[r]);}
    free(dA,q);free(dB,q);free(dAs,q);free(dBs,q);free(dAp8,q);free(dBp8,q);free(dC8,q);
    free(dAp9,q);free(dBp9,q);free(dPk,q);free(dSc,q);
  }
  return 0;
}
