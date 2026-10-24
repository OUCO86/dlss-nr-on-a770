// bench_cgisolate.cpp -- section 98: WHICH kernel property breaks command_graph replay?
// The engine's real replay crashed DEVICE_LOST, but the trivial-kernel probe replayed fine.
// Isolate: record+replay graphs of (1) plain kernel, (2) ESIMD no-dpas, (3) ESIMD+dpas,
// (4) nd_range ESIMD+group_barrier, (5) ESIMD+dpas+nd_range+barrier (the v2 shape),
// (6) 691 mixed real-shape launches. Each in its OWN graph; print pass/fail per case.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <sycl/ext/oneapi/experimental/graph.hpp>
#include <cstdint>
#include <cstdio>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
namespace gr = sycl::ext::oneapi::experimental;


static void trycase(const char* nm, queue& q, float* BUF, std::function<void(handler&)> body){
  try{
    gr::command_graph<gr::graph_state::modifiable> cg(q);
    cg.add(body);
    auto eg = cg.finalize();
    q.ext_oneapi_graph(eg).wait();
    printf("CASE %-34s REPLAY OK\n", nm);
  }catch(const std::exception&e){
    printf("CASE %-34s THREW: %.120s\n", nm, e.what());
  }
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* BUF=(float*)malloc_device(4096*4,q); q.memset(BUF,0,4096*4).wait();

  trycase("1 plain range", q, BUF, [&](handler& h){
    h.parallel_for(range(64u),[=](item<1> it){ BUF[it.get_id(0)]=1.f; }); });
  trycase("2 ESIMD no-dpas", q, BUF, [&](handler& h){
    h.parallel_for(range(64u),[=](item<1> it) SYCL_ESIMD_KERNEL {
      esimd::simd<float,16> v(BUF+(size_t)it.get_id(0)*16u); v=v*2.f; v.copy_to(BUF+(size_t)it.get_id(0)*16u); }); });
  trycase("3 ESIMD + dpas", q, BUF, [&](handler& h){
    h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      for(int i=0;i<64;++i) BUF[i]=c[i]; }); });
  trycase("4 nd ESIMD + group_barrier", q, BUF, [&](handler& h){
    h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      group_barrier(it.get_group());
      if(it.get_global_id(0)==0u) BUF[100]=3.f; }); });
  trycase("5 nd ESIMD + dpas + barrier (v2 shape)", q, BUF, [&](handler& h){
    h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
      esimd::simd<float,64> c(0.f);
      c = esimd::xmx::dpas<8,8,float>(c, b, a);
      group_barrier(it.get_group());
      if(it.get_global_id(0)==0u) BUF[200]=c[0]; }); });
    {
    // build a 691-node graph of case-3 bodies
    try{
      gr::command_graph<gr::graph_state::modifiable> cg(q);
      for(int i=0;i<691;++i)
        cg.add([&](handler& h){ h.parallel_for(range(1u),[=](item<1>) SYCL_ESIMD_KERNEL {
          esimd::simd<half,128> a(half(1.0f)), b(half(1.0f));
          esimd::simd<float,64> c(0.f);
          c = esimd::xmx::dpas<8,8,float>(c, b, a);
          for(int k=0;k<64;++k) BUF[(size_t)i*4+ (k%4)] = c[k]; }); });
      auto eg = cg.finalize();
      q.ext_oneapi_graph(eg).wait();
      printf("CASE %-34s REPLAY OK\n","6 691x ESIMD+dpas nodes");
    }catch(const std::exception&e){ printf("CASE %-34s THREW: %.120s\n","6 691x ESIMD+dpas nodes",e.what()); }
  }
  return 0;
}
