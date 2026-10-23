// bench_lanesplit.cpp -- section 96 part 3 (clean rewrite): two probes, one binary.
// P1: PLAIN nd_range(64/64) + esimd GLOBAL tag<16 block-loads + dpas<8,8,float>, with
// A-block ROW SIGNATURE (row r of the pack holds all-halfs value (r+1)*10; B = all 1).
//   -> every lane writes its own c[0] to OutA[lid]; PR[0] reports the real sub-group
//   width. If the kernel is compiled as real SIMD-split, lanes carry DIFFERENT dots
//   (each holds its A rows) => DISTINCT; if esimd falls back scalar-redup every lane
//   computes identically => ALL-SAME c0 (=160). This also tells us whether f16v1-
//   shape operand blocks (B=128h -> N=8, static_assert'd sg 8/16 only) really run at
//   SIMD8 like the shipped gemm's own shapes force (the reqd-print earlier said a
//   bogus "1"; this P1 print is the real width probe).
// P2: global-handoff visibility for the v2 skeleton: one plain nd(128/128) kernel:
//   phase 1 every thread scalar-writes Gtmp[lid]=half(1.f); group_barrier; phase 2
//   every subgroup block-load (tag<16, aligned pool base) from Gtmp + B static all-1,
//   dpas -> OutB[lid]=c[0]. If barrier orders global stores for global loads => every
//   lane gets 16.0; if some subgroup read stale zeros => count of c==0 > 0 = broken
//   and v2 needs explicit fences not just barriers. Gtmp zeroed by a preceding kernel.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
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

  std::vector<half> hA(256,half(1.0f));
  for(int r=0;r<8;++r) for(int k=0;k<16;++k) hA[r*16+k]=half((float)((r+1)*10));
  std::vector<half> hB(256,half(1.0f));           // B block row = all ones, rows 0..3 used by reads?
  half* GA=(half*)malloc_device(256*2,q); half* GB=(half*)malloc_device(256*2,q);
  q.memcpy(GA,hA.data(),512).wait(); q.memcpy(GB,hB.data(),512).wait();

  // ---- P1 ----
  int* O1=(int*)malloc_device(64*4,q); float* W1=(float*)malloc_device(4,q);
  q.memset(O1,0,256).wait();
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
      esimd::simd<sycl::half,128> a0(GA,esimd::overaligned_tag<16>{});
      esimd::simd<sycl::half,128> b0(GB,esimd::overaligned_tag<16>{});
      esimd::simd<float,64> c(0.f);
      c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
      O1[lid]=(int)c[0];
      if(lid==0u) W1[0]=(float)sg.get_local_range().size();
    }); });
  q.wait();
  { std::vector<int> ho(64,0); std::vector<float> hw(1,0);
    q.memcpy(ho.data(),O1,256).wait(); q.memcpy(hw.data(),W1,4).wait();
    bool same=true; for(int i=1;i<64;++i) if(ho[i]!=ho[0]) same=false;
    printf("P1: real-sg-width=%2.0f  lane c0s[0..7]: %d %d %d %d %d %d %d %d -> %s\n",
      hw[0],ho[0],ho[1],ho[2],ho[3],ho[4],ho[5],ho[6],ho[7], same?"ALL-SAME(redup?)":"DISTINCT(real split)"); }

  // ---- P2 ----
  half* Gtmp=(half*)malloc_device(256*2,q);
  q.submit([&](handler& h){
    h.parallel_for(range(256u),[=](item<1> it){ Gtmp[(size_t)it.get_id(0)]=half(0.0f); }); });
  q.wait();
  int* O2=(int*)malloc_device(128*4,q); float* W2=(float*)malloc_device(4,q);
  q.memset(O2,0,512).wait();
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(128u),range(128u)),[=](nd_item<1> it){
      auto sg=it.get_sub_group(); uint lid=(uint)it.get_local_id(0);
      if(lid<128u) Gtmp[lid]=half(1.0f);              // phase 1: whole group scalar writes A-block values
      group_barrier(it.get_group());
      esimd::simd<sycl::half,128> a0(Gtmp,esimd::overaligned_tag<16>{});
      esimd::simd<sycl::half,128> b0(GB,esimd::overaligned_tag<16>{});
      esimd::simd<float,64> c(0.f);
      c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
      O2[lid]=(int)c[0];
      if(lid==0u) W2[0]=(float)sg.get_local_range().size();
    }); });
  q.wait();
  { std::vector<int> ho(128,0); std::vector<float> hw(1,0);
    q.memcpy(ho.data(),O2,512).wait(); q.memcpy(hw.data(),W2,4).wait();
    int n16=0,nzero=0,noth=0;
    for(int v:ho){ if(v==16)++n16; else if(v==0)++nzero; else ++noth; }
    printf("P2: real-sg-width=%2.0f  c0==16:%d/128 zero:%d other:%d -> %s\n",
      hw[0],n16,nzero,noth, (n16==128)?"BARRIER-VISIBILITY OK (global handoff by same-kernel)":
      ((noth==0&&nzero>0)?"STALE-ZEROS: barriers alone DO NOT order global store->load!!": "MIXED")); }

  return 0;
}
