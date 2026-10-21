// bench_batched.cpp -- section 92 DERIVATION (not trial-and-error): the FLOPs counter
// says batched runs at 0.70 TOPS vs the senior's 2.1 (int32-store) / 11.8 (fused-store).
// Measure MY gemm_b (int32 store) vs gemm_b_pub (fused) at the REAL batched shape, GPU
// event timing, compute TOPS. This tests the store-width hypothesis on my kernel.
// Real shape (shape dump): M=32640 N=128 K=64 batch=2, ldc=256 (strided, 50% waste).
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include "gemm_s8_v8_kernel.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property_list{property::queue::in_order{}, property::queue::enable_profiling{}});
  const int M=32640,N=128,K=64,batch=2,Mp=((M+127)/128)*128;
  const size_t sa=(size_t)batch*Mp*K, sb=(size_t)batch*N*K, sc=(size_t)batch*Mp*N, so=(size_t)batch*M*256;
  const double flops=2.0*M*N*K*batch;
  int8_t* Ap=(int8_t*)malloc_device(sa,q);
  int8_t* Bp=(int8_t*)malloc_device(sb,q);
  int32_t* C32=(int32_t*)malloc_device(sc*4,q);
  half* Cout=(half*)malloc_device(so*2,q);
  float* as=(float*)malloc_device((size_t)batch*Mp*4,q);
  float* bs=(float*)malloc_device((size_t)batch*N*4,q);
  std::vector<int8_t> ha(sa,(int8_t)3), hb(sb,(int8_t)3);
  q.memcpy(Ap,ha.data(),sa).wait(); q.memcpy(Bp,hb.data(),sb).wait();
  std::vector<float> hsa((size_t)batch*Mp,1.f), hsb((size_t)batch*N,1.f);
  q.memcpy(as,hsa.data(),hsa.size()*4).wait(); q.memcpy(bs,hsb.data(),hsb.size()*4).wait();
  auto T=[&](const char* nm, std::function<event()> f){
    f().wait(); event e=f(); e.wait();
    double ms=(double)(e.get_profiling_info<info::event_profiling::command_end>()-
                       e.get_profiling_info<info::event_profiling::command_start>())/1e6;
    printf("%-22s %8.3f ms   %6.2f TOPS\n", nm, ms, flops/ms/1e9);
  };
  for(int i=0;i<3;i++){ s8v8::gemm_b(q,Ap,Bp,C32,Mp,N,K,batch).wait(); }
  T("gemm_b (int32 store)",[&]{ return s8v8::gemm_b(q,Ap,Bp,C32,Mp,N,K,batch); });
  for(int i=0;i<3;i++){ s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*256,256,0,0,true).wait(); }
  T("gemm_b_pub (fused)",[&]{ return s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*256,256,0,0,true); });
  // dense ldc=N (no stride waste) to isolate the stride cost
  T("gemm_b_pub dense ldc=128",[&]{ return s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*N,128,0,0,true); });
  return 0;
}
