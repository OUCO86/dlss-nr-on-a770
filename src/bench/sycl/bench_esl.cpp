// bench_esl.cpp -- section 93: THE third combination never tested. Can an ESIMD kernel
// (SYCL_ESIMD_KERNEL, dpas at SIMD32) use the STANDARD local_accessor (per-workgroup shared
// SLM) + group_barrier to share data ACROSS subgroups? If yes, we reproduce the Vulkan coopmat
// structure (SIMD32 dpas + workgroup shared + workgroup barrier) and resident fusion is fast.
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
  float* C=(float*)malloc_device(256*4,q);
  printf("launching ESIMD + local_accessor + group_barrier...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      local_accessor<float,1> SLM(range(64u), h);
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        float* s=SLM.get_pointer();
        uint lid=(uint)it.get_local_id(0);
        uint sub=lid/32u, local=lid%32u;
        if(local==0u) s[sub*4u] = float(sub+1);
        group_barrier(it.get_group());
        if(local==0u) C[sub] = s[((sub+1u)%8u)*4u];
      }); });
    q.wait();
    std::vector<float> hc(8); q.memcpy(hc.data(),C,32).wait();
    int ok=0; for(int s=0;s<8;++s) if(hc[s]==float((s+1)%8+1)) ok++;
    printf("cross-subgroup via local_accessor: %d/8 correct -> %s\n",ok,
           ok==8?"WORKS (45ms path OPEN)":"broken (per-subgroup)");
    printf("  sub0 read %.0f (want 2), sub7 %.0f (want 1)\n",hc[0],hc[7]);
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
