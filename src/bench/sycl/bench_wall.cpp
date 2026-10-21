// bench_wall.cpp -- section 93: PRECISELY characterize the third wall with single-variable
// tests, each in its own process (DEVICE_LOST poisons the L0 context).
//   A = 2 subgroups, per-subgroup SLM + barrier, no dpas
//   B = 2 subgroups, dpas global->global, no SLM/barrier
//   C = 2 subgroups, per-subgroup SLM + dpas
//   D = 2 subgroups, CROSS-subgroup shared SLM (sub0 writes, all read) + barrier, no dpas
//   E = 2 subgroups, cross-shared SLM + dpas (megakernel shape, small)
//   F = 4 subgroups (128 thr), cross-shared SLM + dpas
//   G = 8 subgroups (256 thr), cross-shared SLM + dpas (the .comp shape)
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
int main(int argc,char**argv){
  char mode=argc>1?argv[1][0]:'A';
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  half* A=(half*)malloc_device(64*64*2,q); half* B=(half*)malloc_device(64*64*2,q);
  float* C=(float*)malloc_device(64*64*4,q);
  std::vector<half> ha(64*64, half(1.f)), hb(64*64, half(1.f));
  q.memcpy(A,ha.data(),ha.size()*2).wait(); q.memcpy(B,hb.data(),hb.size()*2).wait();
  printf("mode=%c launching...\n",mode); fflush(stdout);
  try {
    if(mode=='A'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<256u>(); uint lid=(uint)it.get_local_id(0); uint sub=lid/32u, local=lid%32u;
        esimd::simd<float,8> v(float(sub*100u+local));
        esimd::slm_block_store(local*32u,v,esimd::overaligned_tag<16>{}); esimd::barrier();
        esimd::simd<float,8> r=esimd::slm_block_load<float,8>(local*32u,esimd::overaligned_tag<16>{});
        r.copy_to(C+(size_t)lid*8u); }); });
    } else if(mode=='B'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint lid=(uint)it.get_local_id(0); uint sub=lid/32u;
        esimd::simd<half,128> a0(A+(size_t)sub*128u,esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(B+(size_t)sub*128u,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f); c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        c.copy_to(C+(size_t)sub*64u); }); });
    } else if(mode=='C'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<2048u>(); uint lid=(uint)it.get_local_id(0); uint sub=lid/32u;
        esimd::simd<half,128> av(A+(size_t)sub*128u,esimd::overaligned_tag<16>{});
        esimd::slm_block_store(sub*1024u,av,esimd::overaligned_tag<16>{}); esimd::barrier();
        esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(sub*1024u,esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(B+(size_t)sub*128u,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f); c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        c.copy_to(C+(size_t)sub*64u); }); });
    } else if(mode=='D'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<256u>(); uint lid=(uint)it.get_local_id(0); uint local=lid%32u;
        if(lid<32u){ esimd::simd<float,8> v(float(local)+1.f); esimd::slm_block_store(local*32u,v,esimd::overaligned_tag<16>{}); }
        esimd::barrier();
        esimd::simd<float,8> r=esimd::slm_block_load<float,8>(local*32u,esimd::overaligned_tag<16>{});
        r.copy_to(C+(size_t)lid*8u); }); });
    } else if(mode=='E'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<256u>(); uint lid=(uint)it.get_local_id(0); uint local=lid%32u;
        if(lid<32u){ esimd::simd<half,128> av(A+(size_t)local*4u,esimd::overaligned_tag<16>{}); esimd::slm_block_store(0u,av,esimd::overaligned_tag<16>{}); }
        esimd::barrier();
        esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(0u,esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(B+(size_t)(lid/32u)*128u,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f); c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        c.copy_to(C+(size_t)(lid/32u)*64u); }); });
    } else if(mode=='F'){
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(128u),range(128u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<512u>(); uint lid=(uint)it.get_local_id(0); uint local=lid%32u;
        if(lid<32u){ esimd::simd<half,128> av(A+(size_t)local*4u,esimd::overaligned_tag<16>{}); esimd::slm_block_store(0u,av,esimd::overaligned_tag<16>{}); }
        esimd::barrier();
        esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(0u,esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(B+(size_t)(lid/32u)*128u,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f); c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        c.copy_to(C+(size_t)(lid/32u)*64u); }); });
    } else { // G
      q.submit([&](handler& h){ h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        esimd::slm_init<1024u>(); uint lid=(uint)it.get_local_id(0); uint local=lid%32u;
        if(lid<32u){ esimd::simd<half,128> av(A+(size_t)local*4u,esimd::overaligned_tag<16>{}); esimd::slm_block_store(0u,av,esimd::overaligned_tag<16>{}); }
        esimd::barrier();
        esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(0u,esimd::overaligned_tag<16>{});
        esimd::simd<half,128> b0(B+(size_t)(lid/32u)*128u,esimd::overaligned_tag<16>{});
        esimd::simd<float,64> c(0.f); c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        c.copy_to(C+(size_t)(lid/32u)*64u); }); });
    }
    q.wait();
    std::vector<float> hc(64*64); q.memcpy(hc.data(),C,hc.size()*4).wait();
    printf("mode=%c OK (C[0]=%.1f)\n",mode,hc[0]);
  } catch(const sycl::exception&e){ printf("mode=%c THREW: %s\n",mode,e.what()); return 2; }
  return 0;
}
