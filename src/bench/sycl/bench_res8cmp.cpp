// bench_res8cmp -- the RES8 blade's bench gate: gemm_b_res (f16 plane) vs
// gemm_b_res8 (row-scale E4M3 byte plane) at the frame's 1267 shapes
// (32640x64x64 b1-style single; the recorder calls it per group). Judge:
// (1) the byte round-trip error envelope (plane SNR >= ~30dB expected),
// (2) the DRAM time win (bytes half the f16 traffic).
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <cmath>
#include <vector>
#include <random>
#include <algorithm>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  struct C{int M,N,K;}; C cfgs[]={{32640,64,64},{8160,64,64},{2040,64,64},{192,64,64}};
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K; int Mp=((M+127)/128)*128;
    std::vector<int8_t> hA((size_t)Mp*K), hB((size_t)N*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:hA)x=(int8_t)da(rng); for(auto&x:hB)x=(int8_t)da(rng);
    std::vector<float> hAs(Mp,0.01f), hBs(N,0.02f), hCos(N,0.5f), hSk((size_t)Mp*N);
    std::uniform_real_distribution<float> ds(-6.f,6.f);
    for(auto&x:hSk)x=ds(rng);
    // pack A/B on host (the proven maps)
    std::vector<int8_t> hAp((size_t)Mp*K), hBp((size_t)N*K);
    s8v8::pack_a(hA.data(), hAp.data(), Mp, K);
    s8v8::pack_b(hB.data(), hBp.data(), N, K);
    int8_t *dAp=(int8_t*)malloc_device(hAp.size(),q),*dBp=(int8_t*)malloc_device(hBp.size(),q);
    float *dAs=(float*)malloc_device((size_t)Mp*4,q),*dBs=(float*)malloc_device((size_t)N*4,q),*dCos=(float*)malloc_device((size_t)N*4,q);
    half* dSk16=(half*)malloc_device((size_t)Mp*N*2,q);
    int8_t* dSk8=(int8_t*)malloc_device((size_t)Mp*N,q);
    float* dSkS=(float*)malloc_device((size_t)Mp*4,q);
    half* dC16=(half*)malloc_device((size_t)Mp*N*2,q);
    int8_t* dC8=(int8_t*)malloc_device((size_t)Mp*N,q);
    float* dCS=(float*)malloc_device((size_t)Mp*4,q);
    q.memcpy(dAp,hAp.data(),hAp.size()).wait(); q.memcpy(dBp,hBp.data(),hBp.size()).wait();
    q.memcpy(dAs,hAs.data(),(size_t)Mp*4).wait(); q.memcpy(dBs,hBs.data(),(size_t)N*4).wait();
    q.memcpy(dCos,hCos.data(),(size_t)N*4).wait();
    std::vector<half> hSk16(hSk.size()); for(size_t i=0;i<hSk.size();++i) hSk16[i]=half(hSk[i]);
    q.memcpy(dSk16,hSk16.data(),hSk16.size()*2).wait();
    // build the byte skip plane from the f16 one (row pow2 scale + e4m3 snap) via host ref
    std::vector<int8_t> hSk8(hSk.size()); std::vector<float> hSkS(Mp,1.f);
    for(int r=0;r<Mp;++r){ float pk=0; for(int c=0;c<N;++c) pk=std::max(pk,std::fabs(hSk[(size_t)r*N+c]));
      float s=1.f; if(pk>0){ float r0=pk/448.f; int le=std::ilogbf(r0); if((r0/std::ldexp(1.f,le))>1.f) le++; s=std::ldexp(1.f,le);} hSkS[r]=s;
      for(int c=0;c<N;++c){ float v=hSk[(size_t)r*N+c]/s; // snap e4m3
        float a=std::fabs(v); a=std::min(a,448.f); float dec;
        if(a<0.015625f){ float qq=std::nearbyint(a*512.f); if(qq>7)qq=7; dec=qq/512.f; }
        else { int e=std::ilogbf(a); float step=std::ldexp(1.f,e-3); float qq=std::nearbyint(a/step); if(qq==16){qq=8;e++;step*=2.f;} dec=qq*step; }
        hSk8[(size_t)r*N+c]=(int8_t)(uint8_t)( (v<0?0x80u:0u) | (dec==0?0u:0u) ); // code below via decode re-encode
        // store DECODED value instead: the kernel decodes byte->value; encode the dec back to code
        float dd=dec; uint32_t bb; std::memcpy(&bb,&dd,4); int eb=(bb>>23)&255, mb=(bb>>20)&7;
        uint32_t code = (eb>=121)? (uint32_t)(((eb-120)<<3)|mb) : (uint32_t)std::nearbyint(dec*512.f);
        if(v<0)code|=0x80; hSk8[(size_t)r*N+c]=(int8_t)(uint8_t)code; } }
    q.memcpy(dSk8,hSk8.data(),hSk8.size()).wait(); q.memcpy(dSkS,hSkS.data(),(size_t)Mp*4).wait();
    auto tev=[&](std::function<event()> f)->double{ double b=1e9;
      for(int i=0;i<9;++i){ event e=f(); e.wait();
        b=std::min(b,(double)(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>())/1e6);} return b;};
    double t16=tev([&]{ return s8v8::gemm_b_res(q,dAp,dBp,(void*)dC16,dAs,dBs,(const void*)dSk16,dCos,M,Mp,N,K,true,true,1u); });
    double t8 =tev([&]{ return s8v8::gemm_b_res8(q,dAp,dBp,dC8,dCS,(const float*)dAs,dBs,(const int8_t*)dSk8,(const float*)dSkS,dCos,M,Mp,N,K); });
    std::vector<half> hc16((size_t)Mp*N); std::vector<int8_t> hc8((size_t)Mp*N); std::vector<float> hs8(Mp);
    q.memcpy(hc16.data(),dC16,hc16.size()*2).wait(); q.memcpy(hc8.data(),dC8,hc8.size()).wait(); q.memcpy(hs8.data(),dCS,(size_t)Mp*4).wait();
    // decode the byte output on host, compare vs the f16 output
    double se=0,ss=0; int bad=0;
    for(int r=0;r<Mp;++r){ float s=hs8[r];
      for(int c=0;c<N;++c){ uint32_t b=(uint8_t)hc8[(size_t)r*N+c]; int eb=(b>>3)&15, mb=b&7; float dv;
        if(eb==0) dv=mb/512.f; else dv=(1.f+mb*0.125f)*std::ldexp(1.f,eb-7);
        if(b&0x80)dv=-dv; dv*=s;
        float ref=(float)hc16[(size_t)r*N+c]; se+=(dv-ref)*(dv-ref); ss+=(double)ref*ref;
        if(std::fabs(dv-ref) > 0.35f*std::fabs(ref)+0.02f) bad++; } }
    double snr = ss>0 ? 10*std::log10(ss/(se+1e-30)) : 999;
    printf("M=%-6d N=%d K=%d  f16=%.4f res8=%.4f ms (%.2fx)  plane SNR=%.1f dB grossbad=%d\n",
           M,N,K,t16,t8,t16/t8,snr,bad);
    free(dAp,q);free(dBp,q);free(dAs,q);free(dBs,q);free(dCos,q);free(dSk16,q);free(dSk8,q);free(dSkS,q);free(dC16,q);free(dC8,q);free(dCS,q);
  }
  return 0;
}
