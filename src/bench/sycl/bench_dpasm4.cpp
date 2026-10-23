// bench_dpasm4.cpp -- section 95 keystone v4: THE user-mechanism crux. Can esimd::xmx::dpas
// (the working, JIT-lowered XMX intrinsic the shipped f16v1::gemm uses) be called from a
// PLAIN nd_range kernel -- NOT SYCL_ESIMD_KERNEL? If yes: plain kernel + XMX intrinsic +
// standard local_accessor (cross-subgroup shared, bench_jmf-proven) + group_barrier = the
// user's exact mechanism, with NO AOT/ocloc needed. This is the decisive go/no-go.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* Out=(float*)malloc_device(64*4,q);
  printf("launching PLAIN nd_range kernel calling esimd::xmx::dpas...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      local_accessor<float,1> SLM(range(2048u), h);
      h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
        // NO SYCL_ESIMD_KERNEL marker -- this is a plain kernel
        float* s=SLM.get_pointer();
        uint lid=(uint)it.get_local_id(0);
        // operands via memory (the broadcast ctor may fold; the shipped gemm loads from ptrs)
        half* buf=(half*)s;
        for(int i=0;i<128;++i) buf[i]=half(1.0f);
        group_barrier(it.get_group());
        esimd::simd<half,128> a(buf, esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b(buf+128, esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f);
        c = esimd::xmx::dpas<8,8,float>(c, b, a);   // M8 N8 K16 f16->f32
        for(int i=0;i<64;++i) s[lid*64u+i]=c[i];
        group_barrier(it.get_group());
        if(lid==0u) for(int i=0;i<64;++i) Out[i]=s[i];
      }); });
    q.wait();
    std::vector<float> hc(64); q.memcpy(hc.data(),Out,256).wait();
    printf("PLAIN-kernel esimd::xmx::dpas: c[0..3]=%.1f %.1f %.1f %.1f (want 16=K)\n",hc[0],hc[1],hc[2],hc[3]);
    bool ok=true; for(float v:hc) if(v!=16.f) ok=false;
    printf("=> %s\n", ok?"MECHANISM CONFIRMED (dpas in plain kernel, JIT, shared SLM, no ocloc)":"ran but values wrong");
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
