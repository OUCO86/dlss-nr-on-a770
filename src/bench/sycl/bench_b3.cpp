// bench_b3.cpp -- the B3 bandwidth-efficiency instrument for the ffn chip (the
// ONLY thing this needs to answer: does WG-cooperative weight staging (the
// Little's-law fix: kill the 16x redundant L2 weight reads per tile) move the
// chip's 138 GB/s toward the 560 roof?). Calls the SHIPPED launcher twice:
// wstage=false (the current form) vs wstage=true (the staged form). Bit-exact
// by construction (same values/order, SLM vs global source) -- the diff check
// proves it; the timing is the verdict. Shapes = the frame's real ffn sizes.
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include "ffn_chip_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;

int main(){ try {
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  for (unsigned M : {130560u, 522240u}) {
    unsigned Mp=((M+15u)/16u)*16u, cin=32u, hidden=128u;
    std::vector<half> hA((size_t)Mp*cin*2ull);   // f16 activations (raw A)
    std::vector<half> hE((size_t)cin*hidden*2), hP((size_t)hidden*cin*2);
    std::vector<float> hSkip((size_t)M*cin); std::vector<float> hCos(cin);
    std::mt19937 rng(7); std::uniform_real_distribution<float> df(-3.f,3.f);
    for(auto&x:hA)x=half(df(rng)); for(auto&x:hE)x=half(df(rng)); for(auto&x:hP)x=half(df(rng));
    for(auto&x:hSkip)x=df(rng); for(auto&x:hCos)x=df(rng)*0.1f;
    half *dA=malloc_device<half>(hA.size(),q),*dE=malloc_device<half>(hE.size(),q),
         *dP=malloc_device<half>(hP.size(),q); float *dSkip=malloc_device<float>(hSkip.size(),q);
    float *dCos=malloc_device<float>(cin,q);
    q.memcpy(dA,hA.data(),hA.size()*2); q.memcpy(dE,hE.data(),hE.size()*2);
    q.memcpy(dP,hP.data(),hP.size()*2); q.memcpy(dSkip,hSkip.data(),hSkip.size()*4);
    q.memcpy(dCos,hCos.data(),cin*4); q.wait();
    // the packed weights (the launcher takes the PACKED maps)
    half *dEp=malloc_device<half>(hE.size(),q), *dPp=malloc_device<half>(hP.size(),q);
    packdev::pack_b16(q,dE,dEp,(int)cin,(int)hidden);
    packdev::pack_b16(q,dP,dPp,(int)hidden,(int)cin);
    half *dAp=malloc_device<half>((size_t)Mp*cin,q);
    packdev::pack_a16(q,dA,dAp,(int)M,(int)Mp,(int)cin);
    q.wait();
    float *o1=malloc_device<float>((size_t)Mp*cin*4,q), *o2=malloc_device<float>((size_t)Mp*cin*4,q);
    q.memset(o1,0,(size_t)Mp*cin*4); q.memset(o2,0,(size_t)Mp*cin*4); q.wait();
    auto timeit=[&](std::function<event()> fn){ double best=1e9;
      for(int it=0;it<11;++it){ event e=fn(); e.wait();
        double t=double(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>());
        best=std::min(best,t/1e6);} return best;};
    double t_off = timeit([&]{ return ffnc::launch_ffn_chip<16,false>(q,dAp,dEp,dPp,o1,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_on  = timeit([&]{ return ffnc::launch_ffn_chip<16,true>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    std::vector<float> a((size_t)Mp*cin),b((size_t)Mp*cin);
    q.memcpy(a.data(),o1,(size_t)Mp*cin*4).wait(); q.memcpy(b.data(),o2,(size_t)Mp*cin*4).wait();
    size_t d=0; for(size_t i=0;i<a.size();++i) if(memcmp(&a[i],&b[i],4)) ++d;
    double bytes=(double)M*cin*2 /*A in*/ + (double)M*cin*2 /*skip*/ + (double)M*cin*4 /*out*/ + 2.0*cin*hidden*2; // DRAM-class traffic
    printf("M=%u: chip off-staging %.4f ms | on-staging %.4f ms | diff %zu %s | GB/s %.0f -> %.0f\n",
      M,t_off,t_on,d,d?"NOT-EXACT":"EXACT", bytes/t_off/1e3, bytes/t_on/1e3);
  }
  return 0;
  } catch (std::exception& e) { printf("EXC: %s\n", e.what()); return 2; }
}
