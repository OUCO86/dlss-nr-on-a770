// bench_bar.cpp -- section 93: THE key question for the megakernel. bench_wall showed
// 256-thread ESIMD + cross-subgroup SLM + dpas does NOT crash, but G gave C[0]=0.0 (wrong)
// -> esimd::barrier() does NOT synchronize across subgroups (ESIMD spec: subgroup size 1,
// barrier = compiler fence). Test whether standard SYCL group_barrier fixes cross-subgroup
// SLM producer/consumer. Verify by checking ALL subgroups read sub0's written value.
//   H = 256 thr, sub0 writes SLM, esimd::barrier(), all read   (expect: sub1..7 read garbage)
//   I = 256 thr, sub0 writes SLM, group_barrier(it.get_group()), all read  (expect: all correct)
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(int argc,char**argv){
  char mode=argc>1?argv[1][0]:'H';
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* C=(float*)malloc_device(256*4,q);
  printf("mode=%c launching...\n",mode); fflush(stdout);
  try {
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<128u>();
        uint lid=(uint)it.get_local_id(0);
        uint local=lid%32u;
        if(lid<32u){ esimd::simd<float,8> v(float(42.0f));
          esimd::slm_block_store(0u,v,esimd::overaligned_tag<16>{}); }
        if(mode=='H') esimd::barrier();
        else          group_barrier(it.get_group());
        esimd::simd<float,8> r=esimd::slm_block_load<float,8>(0u,esimd::overaligned_tag<16>{});
        r.copy_to(C+(size_t)lid*8u);
      }); });
    q.wait();
    std::vector<float> hc(256*8); q.memcpy(hc.data(),C,hc.size()*4).wait();
    int ok=0,bad=0; for(size_t i=0;i<hc.size();++i){ if(hc[i]==42.f) ok++; else bad++; }
    printf("mode=%c: %d read 42.0, %d wrong (subgroups 1-7 = indices 256..2047)\n",mode,ok,bad);
    printf("  sample: C[0]=%.1f C[256]=%.1f C[1024]=%.1f C[2040]=%.1f\n",hc[0],hc[256],hc[1024],hc[2040]);
  } catch(const sycl::exception&e){ printf("mode=%c THREW: %s\n",mode,e.what()); return 2; }
  return 0;
}
