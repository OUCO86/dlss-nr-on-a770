// bench_jmt.cpp -- section 93: DECISION GATE for the resident port. joint_matrix (the
// coopmat primitive that works in standard SYCL) vs the ESIMD dpas<8,8> my engine uses
// today, at the REAL window_block QKV leg shape (64 tokens x 96 out x 32 K per window,
// 2100 windows). If joint_matrix's throughput is comparable to ESIMD (~5 TOPS on these
// shapes), the resident fusion is worth building; if it is far slower, the port cannot
// reach 45ms and I must know that before writing 400 lines.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/matrix/matrix.hpp>
#include <cstdio>
#include <vector>
#include <chrono>
#include <random>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
namespace jm = sycl::ext::oneapi::experimental::matrix;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property_list{property::queue::enable_profiling{}});
  const int W=2100, TOK=64, NOUT=96, KK=32;
  const size_t rows=(size_t)W*TOK;
  std::vector<half> hA(rows*KK, half(0.3f)), hB((size_t)KK*NOUT, half(0.2f));
  half* A=(half*)malloc_device(hA.size()*2,q); half* B=(half*)malloc_device(hB.size()*2,q);
  q.memcpy(A,hA.data(),hA.size()*2).wait(); q.memcpy(B,hB.data(),hB.size()*2).wait();
  double flops=2.0*(double)rows*NOUT*KK;
  auto best=[&](std::function<event()>&& f)->double{
    f().wait(); double b=1e9;
    for(int i=0;i<5;i++){ event s=q.submit([&](handler&h){h.parallel_for(range(1u),[](item<1>){});});
      event e=f(); e.wait();
      double ms=(double)(e.get_profiling_info<info::event_profiling::command_end>()-
                         s.get_profiling_info<info::event_profiling::command_start>())/1e6;
      if(ms<b)b=ms; }
    return b; };
  // ---- joint_matrix path: one workgroup (256 thr / 8 subgroups) per window ----
  // store to a real float buffer (avoid the null trick)
  float* Of=(float*)malloc_device(rows*NOUT*4,q);
  auto jmrun2=[&](){ return q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range((size_t)W*256u),range(256u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint sub=sg.get_group_id();
      uint window=(uint)it.get_group(0);
      for(int cb=0;cb<NOUT;cb+=8){
        jm::joint_matrix<decltype(sg),float,jm::use::accumulator,8,8,jm::layout::dynamic> mc;
        jm::joint_matrix_fill(sg,mc,0.f);
        for(int kb=0;kb<KK;kb+=16){
          jm::joint_matrix<decltype(sg),half,jm::use::a,8,16,jm::layout::row_major> ma;
          jm::joint_matrix_load(sg,ma,multi_ptr<half,access::address_space::global_space>(A+((size_t)window*TOK+sub*8)*KK+kb),KK);
          jm::joint_matrix<decltype(sg),half,jm::use::b,16,8,jm::layout::row_major> mb;
          jm::joint_matrix_load(sg,mb,multi_ptr<half,access::address_space::global_space>(B+(size_t)kb*NOUT+cb),NOUT);
          jm::joint_matrix_mad(sg,mc,ma,mb,mc);
        }
        jm::joint_matrix_store(sg,mc,multi_ptr<float,access::address_space::global_space>(Of+((size_t)window*TOK+sub*8)*NOUT+cb),NOUT,jm::layout::row_major);
      }
    }); }); };
  double t1=best(jmrun2);
  printf("joint_matrix QKV: %.3f ms  %.2f TOPS\n",t1,flops/t1/1e9);
  // ---- ESIMD f16v1::gemm path (today's engine) ----
  const int Mp=(int)(((rows+15)/16)*16);
  half* dAp=(half*)malloc_device((size_t)Mp*KK*2,q); half* dBp=(half*)malloc_device((size_t)KK*NOUT*2,q);
  packdev::pack_a16(q,A,dAp,(int)rows,Mp,KK); packdev::pack_b16(q,B,dBp,KK,NOUT);
  float* dC=(float*)malloc_device((size_t)Mp*NOUT*4,q);
  auto esimd=[&](){ return f16v1::gemm(q,dAp,dBp,dC,Mp,NOUT,KK); };
  double t2=best(esimd);
  printf("ESIMD f16v1::gemm QKV: %.3f ms  %.2f TOPS\n",t2,flops/t2/1e9);
  return 0;
}
