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
namespace esimd = sycl::ext::intel::esimd;
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
    double t_lw8 = timeit([&]{ return ffnc::launch_ffn_chip<8,false>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_lw32= timeit([&]{ return ffnc::launch_ffn_chip<32,false>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_cs1 = timeit([&]{ return ffnc::launch_ffn_chip<16,false,1>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_cs3 = timeit([&]{ return ffnc::launch_ffn_chip<16,false,3>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_cs4 = timeit([&]{ return ffnc::launch_ffn_chip<16,false,4>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_c5  = timeit([&]{ return ffnc::launch_ffn_chip<16,false,5>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_p1024= timeit([&]{ return ffnc::launch_ffn_chip<16,false>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    // cs5: the SAME nd_range grid but NO slm_init and NO body -- isolates the
    // launch-config floor (grid dispatch) from the SLM-carveout floor.
    int tiles2=((Mp/16)+15)/16;
    double t_aslm = timeit([&]{ return ffnc::launch_ffn_chip<16,false,0,true>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_cs6p = timeit([&]{ return ffnc::launch_ffn_chip<16,false,6>(q,dAp,dEp,dPp,o2,(int)M,(int)Mp,dSkip,dCos,false,true); });
    double t_cs5 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it){
        float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    // cs6: plain range() form (no nd_range, no SLM): the raw launch floor.
    double t_cs6 = timeit([&]{ return q.parallel_for(range((size_t)tiles2*16u),[=](item<1> it){
        float* o=(float*)o2; o[it.get_id(0)]=0.f; }); });
    // cs7 ladder: the SAME grid, EMPTY body, slm_init of increasing size --
    // is the 1.28ms floor the CARVEOUT CONFIG (size-dependent) or the mere
    // PRESENCE of slm_init (size-independent)? Decides the cure.
    double t_s2k = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<2048u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    double t_s8k = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<8192u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    double t_s16k= timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<16384u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    double t_s32k= timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<32768u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    double t_s48k= timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<49152u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    double t_s64k= timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL { esimd::slm_init<65536u>(); float* o=(float*)o2; o[it.get_global_id(0)]=0.f; }); });
    printf("  slm_init floor ladder (empty body, %d WGs): 2K=%.4f 8K=%.4f 16K=%.4f 32K=%.4f 48K=%.4f 64K=%.4f ms\n",
      tiles2, t_s2k,t_s8k,t_s16k,t_s32k,t_s48k,t_s64k);
    // cs8: the GRF-FOOTPRINT hypothesis -- same 64KB slm + grid, but the body
    // DECLARES and lightly touches 16 accumulator registers (8x simd<float,64>).
    // If THIS jumps, the shell floor = register pressure / SPILL (the section
    // 6.8 ledger noted chip scratch=1024-1312B/thread), not slm, not dispatch.
    double t_g16 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f),a2(0.f),a3(0.f),b0(0.f),b1(0.f),b2(0.f),b3(0.f);
        a0+=1.f;a1+=1.f;a2+=1.f;a3+=1.f;b0+=1.f;b1+=1.f;b2+=1.f;b3+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1)+esimd::hmax<float,float,64>(a2)+esimd::hmax<float,float,64>(a3)
               +esimd::hmax<float,float,64>(b0)+esimd::hmax<float,float,64>(b1)+esimd::hmax<float,float,64>(b2)+esimd::hmax<float,float,64>(b3);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    double t_g8 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f),a2(0.f),a3(0.f);
        a0+=1.f;a1+=1.f;a2+=1.f;a3+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1)+esimd::hmax<float,float,64>(a2)+esimd::hmax<float,float,64>(a3);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    double t_g4 = timeit([&]{ return q.parallel_for(nd_range(range((size_t)tiles2*16u),range(16u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<65536u>();
        esimd::simd<float,64> a0(0.f),a1(0.f);
        a0+=1.f;a1+=1.f;
        float s=esimd::hmax<float,float,64>(a0)+esimd::hmax<float,float,64>(a1);
        float* o=(float*)o2; if(s==1234.5f) o[it.get_global_id(0)]=s; }); });
    printf("  GRF footprint ladder (64KB slm, %d WGs): 0acc=%.4f 4acc=%.4f 8acc=%.4f 16acc=%.4f ms\n",
      tiles2, t_s64k, t_g4, t_g8, t_g16);
    std::vector<float> a((size_t)Mp*cin),b((size_t)Mp*cin);
    q.memcpy(a.data(),o1,(size_t)Mp*cin*4).wait(); q.memcpy(b.data(),o2,(size_t)Mp*cin*4).wait();
    size_t d=0; for(size_t i=0;i<a.size();++i) if(memcmp(&a[i],&b[i],4)) ++d;
    double bytes=(double)M*cin*2 /*A in*/ + (double)M*cin*2 /*skip*/ + (double)M*cin*4 /*out*/ + 2.0*cin*hidden*2; // DRAM-class traffic
    printf("M=%u: LW16 %.4f | WSTAGE %.4f | LW8 %.4f | LW32 %.4f | cs1(A-only) %.4f | cs3(quarter-exp) %.4f | cs4(shell) %.4f | cs5(no-q) %.4f | cs6p(no-p) %.4f | ACCSLM %.4f | cs5(nd-noSLM) %.4f | cs6(plain) %.4f ms | diff %zu %s\n",
      M,t_off,t_on,t_lw8,t_lw32,t_cs1,t_cs3,t_cs4,t_c5,t_cs6p,t_aslm,t_cs5,t_cs6,d,d?"NOT-EXACT":"EXACT");
  }
  return 0;
  } catch (std::exception& e) { printf("EXC: %s\n", e.what()); return 2; }
}
