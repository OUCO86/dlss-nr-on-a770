// bench_srcmodes.cpp -- section 96: dpas operand SOURCE variants in a PLAIN SG8 kernel.
// bench_dpasm4 (block-load from local_accessor with overaligned_tag<16) gave c=0 while
// bench_dpasm5 (broadcast ctor) gave 16. Suspects: (a) 16B-alignment UB on local base,
// (b) esimd block loads from local space unsupported/miscompiled in plain kernels.
// This tests each source path with uniform 1.0 operands; PASS = c0==16.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

template<int MODE> static void run(queue& q, half* Gb, float* out){
  q.submit([&](handler& h){
    local_accessor<float,1> SLM(range(256u), h);
    h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
      uint lid=(uint)it.get_local_id(0);
      float* sf=SLM.get_pointer(); half* hb=(half*)sf;
       (void)hb;
      esimd::simd<sycl::half,128> a,b;
      if constexpr(MODE==0){ a=esimd::simd<sycl::half,128>(half(1.f)); b=esimd::simd<sycl::half,128>(half(1.f)); }
      else if constexpr(MODE==1){ a=esimd::simd<sycl::half,128>(Gb,esimd::overaligned_tag<16>{}); b=esimd::simd<sycl::half,128>(Gb+128,esimd::overaligned_tag<16>{}); }
      else if constexpr(MODE==2){ a=esimd::simd<sycl::half,128>(Gb,esimd::overaligned_tag<8>{}); b=esimd::simd<sycl::half,128>(Gb+128,esimd::overaligned_tag<8>{}); }
      else if constexpr(MODE==3||MODE==4||MODE==5||MODE==6){
        for(uint i=lid;i<256u;i+=32u) hb[i]=half(1.f);
        group_barrier(it.get_group());
        if constexpr(MODE==3){ a=esimd::simd<sycl::half,128>(hb,esimd::overaligned_tag<16>{}); b=esimd::simd<sycl::half,128>(hb+128,esimd::overaligned_tag<16>{}); }
        if constexpr(MODE==4){ size_t ad=(size_t)(void*)hb; size_t pad=(16u-(ad&15u))&15u; half*hp=hb+pad;
          a=esimd::simd<sycl::half,128>(hp,esimd::overaligned_tag<16>{}); b=esimd::simd<sycl::half,128>(hp+128,esimd::overaligned_tag<16>{}); }
        if constexpr(MODE==5){ a=esimd::simd<sycl::half,128>(hb,esimd::overaligned_tag<4>{}); b=esimd::simd<sycl::half,128>(hb+128,esimd::overaligned_tag<4>{}); }
        if constexpr(MODE==6){ for(int i=0;i<128;++i) a[i]=hb[i]; for(int i=0;i<128;++i) b[i]=hb[128+i]; }
      }
      esimd::simd<float,64> c(0.f);
      c=esimd::xmx::dpas<8,8,float>(c,b,a);
      if(lid==0u) for(int i=0;i<64;++i) out[i]=c[i];
    });});
  q.wait();
  std::vector<float> hc(64); q.memcpy(hc.data(),out,256).wait();
  bool ok=(hc[0]==16.f && hc[15]==16.f && hc[16]==16.f && hc[63]==16.f);
  printf("[M%d] %s  c0=%.1f c15=%.1f c16=%.1f c63=%.1f\n",MODE,ok?"PASS":"FAIL",hc[0],hc[15],hc[16],hc[63]);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  half* G=(half*)malloc_device(256*2,q);
  std::vector<half> hg(256,half(1.0f)); q.memcpy(G,hg.data(),512).wait();
  const char* names[]={"bcast(global-ref)","glob tag16","glob tag8","SLM tag16 raw","SLM tag16 padded","SLM tag4","SLM scalar[]"};
  for(int m=0;m<7;++m){
    float* O=(float*)malloc_device(64*4,q); q.memset(O,0,256).wait();
    if(m==0) run<0>(q,G,O); else if(m==1) run<1>(q,G,O); else if(m==2) run<2>(q,G,O);
    else if(m==3) run<3>(q,G,O); else if(m==4) run<4>(q,G,O); else if(m==5) run<5>(q,G,O);
    else run<6>(q,G,O);
    printf("   ^ %s\n",names[m]);
  }
  return 0;
}
