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
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(das,as.data(),as.size()*4).wait(); q.memcpy(dbs,bs.data(),bs.size()*4).wait();
    packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,K,0,b);
    packdev::gather_pack_b_b(q,dB,dBp,N,K,K,0,b);
    q.wait();
    double best=1e9;
    for(int it=0;it<7;++it){
      event e=s8v8::gemm_b_pub(q,dAp,dBp,dC,das,dbs,M,Mp,N,K,b,(size_t)Mp*N,(unsigned)N,(unsigned)Mp,(unsigned)N,false,1u);
      e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t0-s0)/1e6);
    }
    double gf=2.0*M*N*K*b/1e9;
    printf("M=%-6d N=%-4d K=%-4d b=%d  gemm_b_pub=%8.4f ms  %7.0f GF/s\n",M,N,K,b,best,gf/best);
    free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(das,q);free(dbs,q);free(dC,q);
  }
  return 0;
}
