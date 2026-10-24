// bench_launchcost.cpp -- section 97: the v2 stop=65535 probe showed an EMPTY fused kernel
// (nd_range 2040x64, SYCL_ESIMD_KERNEL, immediate return) costs 85.1ms over 55 launches =
// 1.55ms/launch. The split path's ESIMD gemm kernels use plain range() launches and cost
// far less. Isolate WHICH property is the poison: (A) nd_range vs range, (B) group_barrier
// present in the (unexecuted) code, (C) kernel size (big fused body compiled in), (D) the
// 2040x64 shape itself. Each variant: 55 launches of the same kernel, timed.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <chrono>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template<typename F>
static double bench(const char* nm, F&& submit){
  auto t0=std::chrono::high_resolution_clock::now();
  for(int i=0;i<55;++i) submit();
  auto t1=std::chrono::high_resolution_clock::now();
  double ms=std::chrono::duration<double,std::milli>(t1-t0).count();
  printf("%-46s %7.1f ms total, %.3f ms/launch\n",nm,ms,ms/55);
  return ms;
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  half* WS=(half*)malloc_device((size_t)2040*43008*2,q);
  const size_t N=(size_t)2040*64;
  // GPU clock warmup: 200 dummy launches of a trivial kernel before any measurement
  for(int i=0;i<200;++i) q.submit([&](handler& h){ h.parallel_for(range(4096u),[=](item<1> it){ ((half*)WS)[(size_t)it.get_id(0)%4096]=half((float)i); }); });
  q.wait();
  // A: nd_range(2040x64,64) ESIMD, empty body
  bench("A nd64 ESIMD empty", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  bench("A2 nd64 ESIMD empty (2nd, JIT warm)", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // B: same + group_barrier in code (unexecuted path? no: executed by all)
  bench("B nd64 ESIMD + group_barrier", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      group_barrier(it.get_group());
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // C: range() ESIMD empty (the split-gemm launch shape)
  bench("C range ESIMD empty", [&]{ q.submit([&](handler& h){
    h.parallel_for(range(N),[=](item<1> it) SYCL_ESIMD_KERNEL {
      if(it.get_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // D: nd_range PLAIN (no ESIMD) empty
  bench("D nd64 plain empty", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it){
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // E: nd_range ESIMD with a big live register footprint (4x simd<float,64> kept alive)
  bench("E nd64 ESIMD + 256 live f32 regs", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      esimd::simd<float,64> c00(1.f),c01(2.f),c10(3.f),c11(4.f);
      for(int k=0;k<4;++k){ c00=c00*esimd::simd<float,64>(1.001f); c01=c01*esimd::simd<float,64>(1.001f);
                            c10=c10*esimd::simd<float,64>(1.001f); c11=c11*esimd::simd<float,64>(1.001f); }
      float s=c00[0]+c01[0]+c10[0]+c11[0];
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(s);
    }); }); q.wait(); });
  // F: nd_range(2040x32,32) ESIMD empty -- half the workgroups? no: same threads, 2 SGs
  bench("F nd32 ESIMD empty (4080 wg? no: 2040x32 thr)", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range((size_t)2040*32),range(32u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // H: v2-shaped kernel: stack arrays wf[64]+hv[32] (like P4/P2) but NEVER executed
  // (early return) -> isolates the STATIC cost: private-memory stack frame allocation
  // per launch for 2040x64 threads.
  bench("H nd64 ESIMD + dead wf[64]/hv[32] stack", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      float wf[64]; float hv[32];
      if(it.get_global_id(0)==999999u){ wf[0]=1.f; hv[0]=2.f; ((half*)WS)[1]=half(wf[0]+hv[0]); }
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  // I: same but arrays forced live (write+read back) -> true stack usage
  bench("I nd64 ESIMD + LIVE wf[64] stack", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(N),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      float wf[64]; for(int i=0;i<64;++i) wf[i]=(float)i;
      float s=0; for(int i=0;i<64;++i) s+=wf[i];
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(s);
    }); }); q.wait(); });
  // G: 510 workgroups x 64 (4 windows per workgroup, same total threads /4 wg)
  bench("G nd64x510 ESIMD empty", [&]{ q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range((size_t)510*64),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      if(it.get_global_id(0)==0u) ((half*)WS)[0]=half(1.f);
    }); }); q.wait(); });
  return 0;
}
