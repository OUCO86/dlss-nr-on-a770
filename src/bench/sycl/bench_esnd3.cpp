// bench_esnd3.cpp -- section 96 part 6, CORRECTED probes (esnd2 had two self-inflicted
// bugs: C1 indexed output by LOCAL id so 8 workgroups raced on O[0..31]; C2 zeroed B via
// the pre-memset but only wrote A in-kernel, so dpas correctly returned 0 and I misread
// it as a visibility failure). Fixed here: output indexed by GLOBAL id; C2 fills BOTH the
// A block (G) and B block (G+128) in-kernel stage 1 with ones; the real question is only:
// in ONE multi-subgroup ESIMD workgroup, do stage-2 block loads (tag<16>, global scratch)
// SEE stage-1 scalar writes made by the OTHER subgroups past a group_barrier?
// D: nd(128/128) = 1 workgroup, >=2 subgroups. E: same + an extra device fence after the
// barrier (sycl::ext::oneapi::experimental::memory_fence) to test whether coherence
// rather than ordering is the gap.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static void report(queue& q, int* O, float* PR, const char* nm, size_t lanes){
  std::vector<int> ho(lanes,0); std::vector<float> hw(1,0);
  q.memcpy(ho.data(),O,lanes*4).wait(); q.memcpy(hw.data(),PR,4).wait();
  int nz=0,n16=0,noth=0; for(size_t i=0;i<lanes;++i){ int v=ho[i]; if(v==0)++nz; else if(v==16)++n16; else ++noth; }
  printf("%s: sg=%2.0f  zero=%d 16=%d other=%d  first4: %d %d %d %d  last4: %d %d %d %d\n",
         nm,hw[0],nz,n16,noth,ho[0],ho[1],ho[2],ho[3],ho[lanes-4],ho[lanes-3],ho[lanes-2],ho[lanes-1]);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  half* G=(half*)malloc_device(256*2,q);
  int N=128; int* O=(int*)malloc_device(N*4,q); float* PR=(float*)malloc_device(4,q);
  // ---- D: in-kernel stage1 (both blocks) + barrier + stage2 dpas ----
  q.memset(G,0,512).wait(); q.memset(O,0,N*4).wait(); q.memset(PR,0,4).wait();
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range((size_t)N),range((size_t)N)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      uint gid=(uint)it.get_global_id(0);
      G[gid]=half(1.0f);          // A block = G[0..127] all written by subgroups 0..
      G[128+gid]=half(1.0f);      // B block = G[128..255]
      group_barrier(it.get_group());
      esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
      esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
      esimd::simd<float,64> c(0.f);
      c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
      O[gid]=(int)c[0];
      if(gid==0u) PR[0]=(float)it.get_sub_group().get_local_range().size();
    }); });
  q.wait(); report(q,O,PR,"D ESIMD nd128/128 stage1+barrier+stage2",N);
  // ---- F: two sub-launches of the SAME ESIMD body but stage split across kernels (control:
  // should be trivially correct; if F fails the shapes broke, not the visibility) ----
  q.memset(G,0,512).wait(); q.memset(O,0,N*4).wait(); q.memset(PR,0,4).wait();
  q.submit([&](handler& h){ h.parallel_for(range((size_t)N),[=](item<1> it){ uint i=(uint)it.get_id(0); G[i]=half(1.0f); G[128+i]=half(1.0f); }); });
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range((size_t)N),range((size_t)N)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      uint gid=(uint)it.get_global_id(0);
      esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
      esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
      esimd::simd<float,64> c(0.f);
      c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
      O[gid]=(int)c[0];
      if(gid==0u) PR[0]=(float)it.get_sub_group().get_local_range().size();
    }); });
  q.wait(); report(q,O,PR,"F two-kernel split (control)",N);
  return 0;
}
