// bench_esnd2.cpp -- section 96 part 5: pin down the two all-zero/sg-odd readings.
// C1: ESIMD nd(256/32) = 8 subgroups: block-load G+dpas, NO barrier, G pre-filled by a
//     SEPARATE earlier kernel (launch boundary = full coherence). If C1 correct => the
//     stage1-write+barrier+stage2-read INSIDE the ESIMD kernel was the poison (barrier
//     does not order global for esimd block loads, or scalar writes inside ESIMD kernels
//     drop). If C1 zero too => dpas itself is silently dropped in nd-range ESIMD kernels
//     (multi-subgroup poison, matching the old DEVICE_LOST bisect but now silent).
// C2: ESIMD nd(64/64) = 1 subgroup/workgroup, in-kernel stage1+barrier+stage2. If C2 OK
//     while C1 broken it is the multi-subgroup interaction specifically.
// C3: same body but plain range() launch + item (the EXACT f16v1::gemm launch shape, no
//     nd/barrier at all) as the positive control that the shapes/loads still work.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

static void fill(queue& q, half* G, const std::vector<half>& h){ q.memcpy(G,h.data(),h.size()*2).wait(); }
static void report(queue& q, int* O, float* PR, const char* nm, size_t lanes){
  std::vector<int> ho(lanes,0); std::vector<float> hw(1,0);
  q.memcpy(ho.data(),O,lanes*4).wait(); q.memcpy(hw.data(),PR,4).wait();
  int nz=0,n16=0,noth=0; for(int v:ho){ if(v==0)++nz; else if(v==16)++n16; else ++noth; }
  printf("%s: sg=%2.0f  c0: zero=%d 16=%d other=%d  first4: %d %d %d %d\n",
         nm,hw[0],nz,n16,noth,ho[0],ho[1],ho[2],ho[3]);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  std::vector<half> hA(128,half(1.0f));
  std::vector<half> hB(128,half(1.0f));
  half* G=(half*)malloc_device(512,q);
  // ---- C1: prefilled G (separate launch), ESIMD nd(256/32), no in-kernel writes ----
  fill(q,G,hA); { std::vector<half> tmp(128,half(1.f)); q.memcpy(G+128,tmp.data(),256).wait(); }
  // note A and B both all-ones => c0=16
  { int* O=(int*)malloc_device(256*4,q); float* PR=(float*)malloc_device(4,q);
    q.memset(O,0,1024).wait(); q.memset(PR,0,4).wait();
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(256u),range(32u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint lid=(uint)it.get_local_id(0);
        esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
        esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f);
        c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        O[lid]=(int)c[0];
        if(lid==0u) PR[0]=(float)it.get_sub_group().get_local_range().size();
      }); });
    q.wait(); report(q,O,PR,"C1 ESIMD nd256/32 prefilled no-barrier",256); }
  // ---- C2: ESIMD nd(64/64) 1 subgroup, in-kernel stage1+barrier+stage2 ----
  q.memset(G,0,512).wait();
  { int* O=(int*)malloc_device(64*4,q); float* PR=(float*)malloc_device(4,q);
    q.memset(O,0,256).wait(); q.memset(PR,0,4).wait();
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint lid=(uint)it.get_local_id(0);
        G[lid]=half(1.0f);                       // stage1 in-kernel
        group_barrier(it.get_group());
        esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
        esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f);
        c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        O[lid]=(int)c[0];
        if(lid==0u) PR[0]=(float)it.get_sub_group().get_local_range().size();
      }); });
    q.wait(); report(q,O,PR,"C2 ESIMD nd64/64 1-sub in-kernel+barrier",64); }
  // ---- C3: plain range() + item<1>, prefilled (the f16v1::gemm launch shape) ----
  fill(q,G,hA); { std::vector<half> tmp(128,half(1.f)); q.memcpy(G+128,tmp.data(),256).wait(); }
  { int* O=(int*)malloc_device(64*4,q); float* PR=(float*)malloc_device(4,q);
    q.memset(O,0,256).wait(); q.memset(PR,0,4).wait();
    q.submit([&](handler& h){
      h.parallel_for(range(8u),[=](item<1> it) SYCL_ESIMD_KERNEL {
        uint t=(uint)it.get_id(0);
        esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
        esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f);
        c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        O[t]=(int)c[0];
        if(t==0u) PR[0]=999.f; // marker only (range launch has no sg API)
      }); });
    q.wait(); report(q,O,PR,"C3 range()+item 8 witems (f16v1 shape)",64); }
  return 0;
}
