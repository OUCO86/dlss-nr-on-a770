// bench_packa_v.cpp -- P8-c: pack_a (contiguous, the residual/qkv/int8-gemm
// families' A leg) scalar 1B/thread vs vec16. Shapes from the plan census:
// residual M=2040..35712 K=64..4096; qkv fallback M=192 K=1024; int8 M=640 K=512.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <functional>
#include "pack_device.hpp"
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait();
    auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f();
    q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  struct Cfg{int M,K;};
  std::vector<Cfg> cfgs={{2040,4096},{35712,64},{8160,256},{2040,256},{192,1024},{640,512},{32640,128}};
  for(auto cf:cfgs){
    int M=cf.M,K=cf.K; int Mp=((M+127)/128)*128;
    std::vector<int8_t> A((size_t)M*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:A)x=(int8_t)da(rng);
    int8_t*dA=(int8_t*)malloc_device(A.size(),q);
    int8_t*dP=(int8_t*)malloc_device((size_t)Mp*K,q),*dQ=(int8_t*)malloc_device((size_t)Mp*K,q);
    q.memcpy(dA,A.data(),A.size()).wait();
    q.memset(dP,0x5A,(size_t)Mp*K); q.memset(dQ,0x5A,(size_t)Mp*K); q.wait();
    packdev::pack_a(q,dA,dP,M,Mp,K);
    packdev::pack_a_v(q,dA,dQ,M,Mp,K);
    q.wait();
    std::vector<int8_t> h1((size_t)Mp*K),h2((size_t)Mp*K);
    q.memcpy(h1.data(),dP,h1.size()).wait(); q.memcpy(h2.data(),dQ,h2.size()).wait();
    size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
    double bs=tm([&]{ packdev::pack_a(q,dA,dP,M,Mp,K); },21);
    double bv=tm([&]{ packdev::pack_a_v(q,dA,dQ,M,Mp,K); },21);
    printf("M=%-6d K=%-5d  scalar=%8.4f vec16=%8.4f ms  diff=%zu / %zu\n",
           M,K,bs,bv,diff,h1.size());
    free(dA,q);free(dP,q);free(dQ,q);
  }
  return 0;
}
