// bench_batched.cpp -- section 99: MY v8 batched GEMM at the frame's real shapes vs the
// senior's width-sweep healthy-chain table (int8 staged: 8160x128x128=0.071ms/3742GF,
// 32640x128x256=0.172/12461, 640x128x256=0.069/609, 8160x256x256=0.110/9686).
// Frames (from the shape survey): (M,N,K,b) = (2040,128,256,8)x32 (32640,128,64,2)x16
// (32640,32,128,2)x16 (640,64,256,8)x32 (8160,128,128,4)x24 (8160,32,128,4)x24.
// gemm_b_pub path (epi1/3 narrow) and gemm_b (int32 out) both timed.
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{int M,N,K,b;};
  std::vector<Cfg> cfgs={{2040,128,256,8},{32640,128,64,2},{32640,32,128,2},
                         {640,64,256,8},{8160,128,128,4},{8160,32,128,4}};
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K,b=cf.b;
    int Mp=((M+127)/128)*128;
    std::vector<int8_t> A((size_t)b*M*K),B((size_t)b*K*N),Ap((size_t)b*Mp*K),Bp((size_t)b*K*N);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as((size_t)b*Mp,1.f),bs((size_t)b*N,1.f);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
    int8_t *dAp=(int8_t*)malloc_device(Ap.size(),q),*dBp=(int8_t*)malloc_device(Bp.size(),q);
    float *das=(float*)malloc_device(as.size()*4,q),*dbs=(float*)malloc_device(bs.size()*4,q);
    half* dC=(half*)malloc_device((size_t)b*Mp*N*2,q);
    int32_t* dC32=(int32_t*)malloc_device((size_t)b*Mp*N*4,q);
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(das,as.data(),as.size()*4).wait(); q.memcpy(dbs,bs.data(),bs.size()*4).wait();
    packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,K,0,b);
    packdev::gather_pack_b_b(q,dB,dBp,N,K,K,0,b);
    q.wait();
    double bestb=1e9,bestp=1e9;
    for(int it=0;it<7;++it){
      event e=s8v8::gemm_b(q,dAp,dBp,dC32,Mp,N,K,b); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      bestb=std::min(bestb,(double)(t0-s0)/1e6);
    }
    for(int it=0;it<7;++it){
      event e=s8v8::gemm_b_pub(q,dAp,dBp,(void*)dC,das,dbs,M,Mp,N,K,b,(size_t)Mp*N,(unsigned)N,0u,0u,true,3u); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      bestp=std::min(bestp,(double)(t0-s0)/1e6);
    }
    // section 100 §99-item-3: acc-via-SLM publish tail, full (32KB) and half (16KB)
    double bestf=1e9,besth=1e9;
    half* dCf=(half*)malloc_device((size_t)b*Mp*N*2,q);
    half* dCh=(half*)malloc_device((size_t)b*Mp*N*2,q);
    for(int it=0;it<7;++it){
      event e=s8v8::gemm_b_pub_slm<false>(q,dAp,dBp,(void*)dCf,das,dbs,M,Mp,N,K,b,(size_t)Mp*N,(unsigned)N,0u,0u,true,3u); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      bestf=std::min(bestf,(double)(t0-s0)/1e6);
    }
    for(int it=0;it<7;++it){
      event e=s8v8::gemm_b_pub_slm<true>(q,dAp,dBp,(void*)dCh,das,dbs,M,Mp,N,K,b,(size_t)Mp*N,(unsigned)N,0u,0u,true,3u); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      besth=std::min(besth,(double)(t0-s0)/1e6);
    }
    // bit-exactness vs the GATED gemm_b_pub output (same inputs, same epi)
    std::vector<half> hp((size_t)b*Mp*N), hf((size_t)b*Mp*N), hh((size_t)b*Mp*N);
    q.memcpy(hp.data(),dC,hp.size()*2).wait();
    q.memcpy(hf.data(),dCf,hf.size()*2).wait();
    q.memcpy(hh.data(),dCh,hh.size()*2).wait();
    size_t df=0,dh=0;
    for(size_t i=0;i<hp.size();++i){ if(memcmp(&hp[i],&hf[i],2)) df++; if(memcmp(&hp[i],&hh[i],2)) dh++; }
    double gf=2.0*M*N*K*b/1e9;
    printf("M=%-6d N=%-4d K=%-4d b=%d  gemm_b=%8.4f | pub=%8.4f | pub_slm=%8.4f (diff %zu) | pub_slm_half=%8.4f (diff %zu) ms\n",
      M,N,K,b,bestb,bestp,bestf,df,besth,dh);
    free(dC32,q); free(dCf,q); free(dCh,q);
    free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(das,q);free(dbs,q);free(dC,q);
  }
  return 0;
}
