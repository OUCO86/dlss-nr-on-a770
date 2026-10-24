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
#include "gemm_s8_v9_kernel.hpp"
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
  struct Cfg{int M,K,batch;};
  std::vector<Cfg> cfgs={{2048,256,8},{2040,256,8},{8160,128,4},{32640,64,2},{32704,64,2}};
  for(auto cf:cfgs) for(unsigned epi : {1u,3u}){
    int M=cf.M,K=cf.K,b=cf.batch,N=128;
    int Mp=((M+63)/64)*64;
    std::mt19937 rng(7);
    std::uniform_int_distribution<int> da(-127,127);
    std::uniform_real_distribution<float> ds(0.001f,4.f);
    std::vector<int8_t> A((size_t)b*M*K),B((size_t)b*K*N);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as((size_t)b*Mp),bs((size_t)b*N);
    for(auto&x:as)x=ds(rng); for(auto&x:bs)x=ds(rng);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
    float *dAs=(float*)malloc_device(as.size()*4,q),*dBs=(float*)malloc_device(bs.size()*4,q);
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(dAs,as.data(),as.size()*4).wait(); q.memcpy(dBs,bs.data(),bs.size()*4).wait();
    int8_t* dAp=(int8_t*)malloc_device((size_t)b*Mp*K,q);
    int8_t* dBp=(int8_t*)malloc_device((size_t)b*K*N,q);
    int8_t* dC8=(int8_t*)malloc_device((size_t)b*Mp*N,q);
    float* dNs=(float*)malloc_device((size_t)b*Mp*4,q);
    q.memset(dC8,0,(size_t)b*Mp*N).wait(); q.memset(dNs,0,(size_t)b*Mp*4).wait();
    s8v9::pack_a9(q,dA,dAp,M,Mp,K,K,(size_t)M*K,b);
    s8v9::pack_b9(q,dB,dBp,K,N,N,(size_t)K*N,b);
    q.wait();
    s8v9::gemm_b_rq(q,dAp,dBp,dC8,dNs,dAs,dBs,M,Mp,N,K,b,(size_t)Mp*N,(unsigned)N,(unsigned)Mp,(unsigned)N,epi);
    q.wait();
    // reference: HOST int32 matmul (exact, geometry-independent golden -- senior's
    // test_gemm_int8_staged pattern). NOT v8 gemm_b: its BM=128 pack layout is
    // incompatible with pack_a9's BM=64 blocks.
    std::vector<int32_t> hC32((size_t)b*Mp*N,0);
    for(int g=0;g<b;++g) for(int r=0;r<M;++r) for(int c=0;c<N;++c){
      int64_t acc=0;
      for(int k=0;k<K;++k) acc+=(int64_t)A[(size_t)g*M*K+(size_t)r*K+k]*B[(size_t)g*K*N+(size_t)k*N+c];
      hC32[(size_t)g*Mp*N+(size_t)r*N+c]=(int32_t)acc;
    }
    std::vector<int8_t> hC8((size_t)b*Mp*N); q.memcpy(hC8.data(),dC8,hC8.size()).wait();
    std::vector<float> hNs((size_t)b*Mp); q.memcpy(hNs.data(),dNs,hNs.size()*4).wait();
    uint64_t vdiff=0,sdiff=0; size_t first=0; bool any=false;
    float kscale=0,hscale=0; int gotv=0,wantv=0; float pubv=0; int32_t accv=0; size_t firstr=0; bool rany=false;
    for(int g=0;g<b;++g) for(int r=0;r<M;++r){
      // host reference: f = acc*as*bs -> pub_esimd -> peak -> scale=fdiv_rn(peak,127) -> rint(f/scale)
      float peak=0.f;
      std::vector<float> pubs(N);
      for(int c=0;c<N;++c){
        float f=(float)hC32[(size_t)g*Mp*N+(size_t)r*N+c]*as[(size_t)g*Mp+r]*bs[(size_t)g*N+c];
        float v=s8v8::pub_esimd(epi,f);
        pubs[c]=v; peak=std::fmax(peak,std::fabs(v));
      }
      float scale=(peak==0.f)?1.f:sycl::ext::intel::math::fdiv_rn(peak,127.f);
      for(int c=0;c<N;++c){
        int want=(int)std::rint(sycl::ext::intel::math::fdiv_rn(pubs[c],scale));
        want=want<-127?-127:(want>127?127:want);
        size_t idx=(size_t)g*Mp*N+(size_t)r*N+c;
        if((int)hC8[idx]!=want){ vdiff++; if(!any){first=idx;any=true;gotv=hC8[idx];wantv=want;pubv=pubs[c];accv=hC32[idx];} }
      }
      size_t sidx=(size_t)g*Mp+r;
      if(!(hNs[sidx]==scale)){ sdiff++;
        if(!rany){rany=true;firstr=(size_t)r;kscale=hNs[sidx];hscale=scale;} }
    }
    printf("M=%d K=%d b=%d epi=%u: int8 diff=%llu/%lld  scale diff=%llu/%d  %s\n",
      M,K,b,epi,(unsigned long long)vdiff,(long long)(size_t)b*M*N,
      (unsigned long long)sdiff,b*M,vdiff==0&&sdiff==0?"BIT-EXACT vs split-chain":"MISMATCH");
    if(any){size_t r=(first%((size_t)Mp*N))/N,c=first%N,g=(int)(first/((size_t)Mp*N));
      printf("   first g=%d r=%zu c=%zu: got=%d want=%d pub=%.6f acc=%d\n",g,r,c,gotv,wantv,pubv,accv); }
    if(rany) printf("   first SCALE-diff row r=%zu: kernel=%.9g host=%.9g bits k=%08x h=%08x\n",firstr,kscale,hscale,
                    (unsigned)bit_cast<uint32_t>(kscale),(unsigned)bit_cast<uint32_t>(hscale));
    free(dA,q);free(dB,q);free(dAs,q);free(dBs,q);free(dAp,q);free(dBp,q);free(dC8,q);free(dNs,q);
  }
  return 0;
}
