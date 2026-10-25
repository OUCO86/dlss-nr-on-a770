// bench_v9c.cpp -- standalone gate: v9c FOLD vs host golden, the two frame sa=0 shapes.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <cmath>
#include "gemm_s8_v9c_kernel.hpp"
#include "gemm_s8_v8_kernel.hpp"   // pub_esimd host-side scalar reference
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  for(auto [M,N,K,b]:std::vector<std::tuple<int,int,int,int>>{{32640,128,64,2},{8160,128,128,4}}){
    int ldc=N*b; int Mp=((M+63)/64)*64;
    std::mt19937 rng(7); std::uniform_int_distribution<int> da(-127,127);
    std::uniform_real_distribution<float> ds(0.001f,4.f);
    std::vector<int8_t> A((size_t)M*K),B((size_t)b*N*K);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as(Mp),bs(ldc);
    for(auto&x:as)x=ds(rng); for(auto&x:bs)x=ds(rng);
    int8_t*dA=malloc_device<int8_t>(A.size(),q),*dB=malloc_device<int8_t>(B.size(),q);
    int8_t*dAp=malloc_device<int8_t>((size_t)Mp*K,q),*dBp=malloc_device<int8_t>((size_t)K*ldc,q);
    int8_t*dPk=malloc_device<int8_t>((size_t)Mp*ldc,q); float*dSc=malloc_device<float>((size_t)Mp*4,q);
    float*dAs=malloc_device<float>(as.size()*4,q),*dBs=malloc_device<float>(bs.size()*4,q);
    q.memcpy(dA,A.data(),A.size()).wait();q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(dAs,as.data(),as.size()*4).wait();q.memcpy(dBs,bs.data(),bs.size()*4).wait();
    q.memset(dPk,0,(size_t)Mp*ldc).wait();
    s8v9c::pack_a9b(q,dA,dAp,M,Mp,K,K);
    s8v9c::pack_b9b(q,dB,dBp,K,N,ldc,K,(size_t)N*K,b);
    q.wait();
    if(ldc==256) s8v9c::gemm_b_rq9b<256,true>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u);
    else         s8v9c::gemm_b_rq9b<512,true>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u);
    q.wait();
    std::vector<int8_t> got((size_t)M*ldc); q.memcpy(got.data(),dPk,(size_t)M*ldc).wait();
    std::vector<float> gsc(M); q.memcpy(gsc.data(),dSc,(size_t)M*4).wait();
    // host golden
    std::vector<int8_t> want((size_t)M*ldc); std::vector<float> wsc(M);
    for(int r=0;r<M;++r){
      float peak=0; std::vector<float> pub(ldc);
      for(int n=0;n<ldc;++n){
        int g=n/N,j=n%N; int64_t a=0;
        for(int k=0;k<K;++k)a+=(int64_t)A[(size_t)r*K+k]*B[(size_t)g*N*K+(size_t)j*K+k];
        float p=s8v8::pub_esimd(3u,(float)a*as[r]*bs[n]); pub[n]=p;
        if(std::fabs(p)>peak)peak=std::fabs(p);
      }
      float sc=(peak==0.f)?1.f:(float)((double)peak/127.0); wsc[r]=sc;
      for(int n=0;n<ldc;++n){
        float v=pub[n]; float qq=(float)((double)v/(double)sc);
        int qi=(int)std::nearbyint(qq); qi=qi<-127?-127:(qi>127?127:qi);
        want[(size_t)r*ldc+n]=(int8_t)qi;
      }
    }
    uint64_t vd=0; size_t first=0; bool any=false; uint64_t sd=0;
    for(size_t i=0;i<got.size();++i)if(got[i]!=want[i]){vd++;if(!any){first=i;any=true;}}
    for(int r=0;r<M;++r)if(!(gsc[r]==wsc[r]))sd++;
    printf("v9c M=%d N=%d K=%d b=%d ldc=%d: int8 diff=%llu/%lld scale diff=%llu %s\n",
      M,N,K,b,ldc,(unsigned long long)vd,(long long)got.size(),(unsigned long long)sd,
      (vd==0&&sd==0)?"BIT-EXACT":"MISMATCH");
    if(any){size_t r=first/ldc,n=first%ldc;
      printf("  first r=%zu n=%zu got=%d want=%d\n",r,n,(int)got[first],(int)want[first]);}
    // timing (vs senior 0.071/0.107 at these shapes)
    double best=1e9;
    for(int it=0;it<7;++it){
      event e=(ldc==256)?s8v9c::gemm_b_rq9b<256,true>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u)
                        :s8v9c::gemm_b_rq9b<512,true>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u);
      e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t0-s0)/1e6);}
    printf("  v9c FOLD time = %.4f ms  (%.0f GF/s)   [senior gemm alone: 0.107 / 0.071]\n",
      best, 2.0*M*ldc*K/1e6/best);
    free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(dPk,q);free(dSc,q);free(dAs,q);free(dBs,q);
  }
  return 0;
}
