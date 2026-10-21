// bench_xsub.cpp -- section 93: THE megakernel命门. Does SLM written by subgroup A become
// visible to subgroup B in an ESIMD kernel? Clean design: each subgroup's lane 0 writes a
// UNIQUE value (sub+1) to offset sub*128; after the barrier, each subgroup's lane 0 reads
// offset ((sub+1)%8)*128 (the NEXT subgroup's slot). If cross-subgroup SLM works, every
// reader gets the neighbor's value. If SLM is per-subgroup-private, readers get 0.
// Also test with esimd::barrier() vs group_barrier() vs both.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(int argc,char**argv){
  int bmode=argc>1?atoi(argv[1]):0;  // 0=esimd::barrier 1=group_barrier 2=both
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* C=(float*)malloc_device(8*4,q);
  printf("bmode=%d launching...\n",bmode); fflush(stdout);
  try {
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<1024u>();
        uint lid=(uint)it.get_local_id(0);
        uint sub=lid/32u, local=lid%32u;
        if(local==0u){ esimd::simd<float,1> v(float(sub+1));
          esimd::slm_block_store(sub*128u,v,esimd::overaligned_tag<16>{}); }
        if(bmode==0||bmode==2) esimd::barrier();
        if(bmode==1||bmode==2) group_barrier(it.get_group());
        uint roff = (bmode==3) ? sub*128u : ((sub+1u)%8u)*128u;
        if(local==0u){ esimd::simd<float,1> r=esimd::slm_block_load<float,1>(roff,esimd::overaligned_tag<16>{});
          C[sub]=r[0]; }
      }); });
    q.wait();
    std::vector<float> hc(8); q.memcpy(hc.data(),C,32).wait();
    printf("bmode=%d: sub0 read %.0f (want 2), sub1 %.0f (want 3), sub7 %.0f (want 1)\n",
           bmode,hc[0],hc[1],hc[7]);
    int ok=0; for(int s=0;s<8;++s) if(hc[s]==float((s+1)%8+1)) ok++;
    printf("  %d/8 correct -> %s\n",ok, ok==8?"CROSS-SUBGROUP SLM WORKS":"broken");
  } catch(const sycl::exception&e){ printf("bmode=%d THREW: %s\n",bmode,e.what()); return 2; }
  return 0;
}
