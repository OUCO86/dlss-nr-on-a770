// bench_batched.cpp -- section 92 DERIVATION (not trial-and-error): the FLOPs counter
// says batched runs at 0.70 TOPS vs the senior's 2.1 (int32-store) / 11.8 (fused-store).
// Measure MY gemm_b (int32 store) vs gemm_b_pub (fused) at the REAL batched shape, GPU
// event timing, compute TOPS. This tests the store-width hypothesis on my kernel.
// Real shape (shape dump): M=32640 N=128 K=64 batch=2, ldc=256 (strided, 50% waste).
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
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
    printf("%-22s %8.3f ms   %6.2f TOPS\n", nm, ms, flops/ms/1e9); fflush(stdout);
  };
  for(int i=0;i<3;i++){ s8v8::gemm_b(q,Ap,Bp,C32,Mp,N,K,batch).wait(); }
  T("gemm_b (int32 store)",[&]{ return s8v8::gemm_b(q,Ap,Bp,C32,Mp,N,K,batch); });
  for(int i=0;i<3;i++){ s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*256,256,0,0,true).wait(); }
  T("gemm_b_pub (fused)",[&]{ return s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*256,256,0,0,true); });
  // dense ldc=N (no stride waste) to isolate the stride cost
  T("gemm_b_pub dense ldc=128",[&]{ return s8v8::gemm_b_pub(q,Ap,Bp,Cout,as,bs,M,Mp,N,K,batch,(size_t)M*N,128,0,0,true); });
  // DERIVE the scaffolding cost: publish (dequant+e4m3+strided) and gather_pack_a_b
  // individually, with GB/s to classify bandwidth- vs compute-bound.
  int8_t* dAp2=(int8_t*)malloc_device((size_t)batch*Mp*K,q);
  const int8_t* Araw=(const int8_t*)malloc_device((size_t)batch*M*64,q);
  auto T2=[&](const char* nm, std::function<event()> f, double bytes){
    f().wait(); event e=f(); e.wait();
    double ms=(double)(e.get_profiling_info<info::event_profiling::command_end>()-
                       e.get_profiling_info<info::event_profiling::command_start>())/1e6;
    printf("%-26s %8.3f ms  %7.1f GB/s\n", nm, ms, bytes/ms/1e6); fflush(stdout);
  };
  // publish: reads dC int32 (batch*Mp*N*4), writes Cout half (batch*M*N*2)
  double pub_bytes=(double)batch*Mp*N*4 + (double)batch*M*N*2;
  for(int i=0;i<3;i++) q.parallel_for(range((size_t)batch*M*N),[=](item<1> it){
    size_t idx=it.get_id(0); unsigned mn=M*N; unsigned g=(unsigned)(idx/mn); size_t rem=idx%mn;
    unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
    float v=cr_mul(cr_mul((float)C32[(size_t)g*Mp*N+(size_t)r*N+col], as[(size_t)g*Mp+r]), bs[(size_t)g*N+col]);
    ((half*)Cout)[(size_t)g*M*256+(size_t)r*256+col]=half(qr_e4m3(v)); }).wait();
  T2("publish (e4m3+dequant)",[&]{ return q.parallel_for(range((size_t)batch*M*N),[=](item<1> it){
    size_t idx=it.get_id(0); unsigned mn=M*N; unsigned g=(unsigned)(idx/mn); size_t rem=idx%mn;
    unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
    float v=cr_mul(cr_mul((float)C32[(size_t)g*Mp*N+(size_t)r*N+col], as[(size_t)g*Mp+r]), bs[(size_t)g*N+col]);
    ((half*)Cout)[(size_t)g*M*256+(size_t)r*256+col]=half(qr_e4m3(v)); }); }, pub_bytes);
  // publish WITHOUT e4m3 (just dequant+store) to isolate the e4m3 cost
  T2("publish (no e4m3)",[&]{ return q.parallel_for(range((size_t)batch*M*N),[=](item<1> it){
    size_t idx=it.get_id(0); unsigned mn=M*N; unsigned g=(unsigned)(idx/mn); size_t rem=idx%mn;
    unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
    float v=cr_mul(cr_mul((float)C32[(size_t)g*Mp*N+(size_t)r*N+col], as[(size_t)g*Mp+r]), bs[(size_t)g*N+col]);
    ((half*)Cout)[(size_t)g*M*256+(size_t)r*256+col]=half(v); }); }, pub_bytes);
  // PREDICTION from the derivation: publish is latency-bound (33 GB/s << 500). Vectorize
  // it: 4 elements per work-item -> 4 independent e4m3 chains -> ILP. Verify in bench.
  auto pub4=[&](int per){ return q.parallel_for(range((size_t)batch*M*N/per),[=](item<1> it){
    size_t base=it.get_id(0)*per;
    for(int e=0;e<per;++e){ size_t idx=base+e; if(idx>=(size_t)batch*M*N) break;
      unsigned mn=M*N; unsigned g=(unsigned)(idx/mn); size_t rem=idx%mn;
      unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
      float v=cr_mul(cr_mul((float)C32[(size_t)g*Mp*N+(size_t)r*N+col], as[(size_t)g*Mp+r]), bs[(size_t)g*N+col]);
      ((half*)Cout)[(size_t)g*M*256+(size_t)r*256+col]=half(qr_e4m3(v)); } }); };
  for(int i=0;i<3;i++) pub4(4).wait();
  T2("publish 4-elem/item",[&]{ return pub4(4); }, pub_bytes);
  for(int i=0;i<3;i++) pub4(8).wait();
  T2("publish 8-elem/item",[&]{ return pub4(8); }, pub_bytes);
  // DERIVED: is batched's 123ms scaffolding gather_pack or publish? gather_pack_a_b
  // moves batch*Mp*K int8 (~4MB) -> should be ~0.02ms. Measure to confirm publish is the
  // real cost (then the strided-ABI finding stands and batched has no clean win).
  int8_t* dApG=(int8_t*)malloc_device((size_t)batch*Mp*K,q);
  double gp_bytes=(double)batch*M*K + (double)batch*Mp*K;
  auto gp=[&](){ return q.submit([&](handler& hh){
    const int BM=128,BK=32; int wgr=Mp/BM,kb_n=K/BK; size_t per=(size_t)wgr*kb_n*8*512;
    hh.parallel_for(range((size_t)batch*per),[=](item<1> it){
      size_t gg=it.get_id(0)/per; size_t d=it.get_id(0)%per;
      size_t blk=d/512; int off=(int)(d%512); int wi=(int)(blk%8); size_t wk=blk/8;
      int kb=(int)(wk%(size_t)kb_n); int w=(int)(wk/(size_t)kb_n); int row=off/32,k=off%32;
      int srow=w*BM+wi*16+row; dApG[gg*per+d]= srow<M? Araw[gg*(size_t)M*64+(size_t)srow*K+kb*BK+k]:(int8_t)0; }); }); };
  for(int i=0;i<3;i++) gp().wait();
  T2("gather_pack_a_b",[&]{ return gp(); }, gp_bytes);
  return 0;
}
