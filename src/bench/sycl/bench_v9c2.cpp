// bench_v9c2.cpp -- v9c geometry scan: BM x NT combos on the two frame sa=0 shapes.
// Judge = host golden bit-exact + time vs senior (0.107 / 0.071 ms gemm-only).
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>
#include <random>
#include <cmath>
#include "gemm_s8_v9c_kernel.hpp"
#include "gemm_s8_v8_kernel.hpp"
using namespace sycl;

template<int BMv,int NTv,bool SG>
void run_one(queue& q, int M,int N,int K,int b){
  int ldc=N*b; int Mp=((M+BMv-1)/BMv)*BMv;
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
  s8v9c::pack_a9b<BMv>(q,dA,dAp,M,Mp,K,K);
  s8v9c::pack_b9b(q,dB,dBp,K,N,ldc,K,(size_t)N*K,b);
  q.wait();
  if(ldc==256) s8v9c::gemm_b_rq9b<256,true,BMv,NTv,SG>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u).wait();
  else         s8v9c::gemm_b_rq9b<512,true,BMv,NTv,SG>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u).wait();
  std::vector<int8_t> got((size_t)M*ldc); q.memcpy(got.data(),dPk,(size_t)M*ldc).wait();
  std::vector<float> gsc(M); q.memcpy(gsc.data(),dSc,(size_t)M*4).wait();
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
  uint64_t vd=0,sd=0;
  for(size_t i=0;i<got.size();++i)if(got[i]!=want[i])vd++;
  for(int r=0;r<M;++r)if(!(gsc[r]==wsc[r]))sd++;
  double best=1e9;
  for(int it=0;it<7;++it){
    event e=(ldc==256)?s8v9c::gemm_b_rq9b<256,true,BMv,NTv,SG>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u)
                      :s8v9c::gemm_b_rq9b<512,true,BMv,NTv,SG>(q,dAp,dBp,(sycl::half*)dPk,dSc,dAs,dBs,M,Mp,K,3u);
    e.wait();
    auto s0=e.get_profiling_info<info::event_profiling::command_start>();
    auto t0=e.get_profiling_info<info::event_profiling::command_end>();
    best=std::min(best,(double)(t0-s0)/1e6);}
  printf("  BM=%-3d NT=%-3d SG=%d M=%-6d ldc=%-5d: %s %llu %llu  time=%.4f ms (%.0f GF/s)\n",
    BMv,NTv,(int)SG,M,ldc,(vd==0&&sd==0)?"EXACT":"BAD",
    (unsigned long long)vd,(unsigned long long)sd,best,2.0*M*ldc*K/1e6/best);
  free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(dPk,q);free(dSc,q);free(dAs,q);free(dBs,q);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  printf("senior targets: 32640x128x64b2 -> 0.107ms, 8160x128x128b4 -> 0.071ms (gemm alone)\n");
  printf("== BM64 NT64 single-buffer (senior KC staging) ==\n"); run_one<64,64,true>(q,32640,128,64,2); run_one<64,64,true>(q,8160,128,128,4);
  printf("== BM64 NT64 double-buffer (the old form) ==\n"); run_one<64,64,false>(q,32640,128,64,2); run_one<64,64,false>(q,8160,128,128,4);
  printf("== BM32 NT64 single ==\n"); run_one<32,64,true>(q,32640,128,64,2); run_one<32,64,true>(q,8160,128,128,4);
  printf("== BM32 NT32 single ==\n"); run_one<32,32,true>(q,32640,128,64,2); run_one<32,32,true>(q,8160,128,128,4);
  return 0;
}
