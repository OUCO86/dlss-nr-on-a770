// bench_slm128.cpp -- the user's spec: Xe-HPG SLM hardware max = 128KB per Xe core
// (192KB L1+SLM dynamic split); SYCL's local_mem_size=64KB is only the DEFAULT query
// value. Test what slm_init<> ACTUALLY compiles+runs: 64K, 96K, 110592 (v2's 108KB
// slice!), 128K. If 108KB fits, v3 = v2's WS slice moved to SLM verbatim (no lifetime
// aliasing). Each size: write+barrier+read-back pattern over the whole region.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
using namespace sycl;

template<int BYTES>
static bool try_slm(queue& q, int* out){
  try{
    q.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      esimd::slm_init<BYTES>();
      uint lid=(uint)it.get_local_id(0);
      // touch the WHOLE region: 64 threads x BYTES/64 each, stride 16B blocks
      for (uint off = lid*(BYTES/64u); off < (uint)(lid+1)*(BYTES/64u); off += 64u)
        esimd::slm_block_store(off, esimd::simd<float,16>((float)(off&1023)), esimd::overaligned_tag<16>{});
      esimd::barrier();
      bool ok=true;
      for (uint off = lid*(BYTES/64u); off < (uint)(lid+1)*(BYTES/64u); off += 64u){
        esimd::simd<float,16> r = esimd::slm_block_load<float,16>(off, esimd::overaligned_tag<16>{});
        if (r[0] != (float)(off&1023)) ok=false;
      }
      esimd::barrier();
      if(ok && lid==0u) out[0]=1;
    }).wait();
    int h=0; q.memcpy(&h,out,4).wait();
    return h==1;
  }catch(const std::exception&e){ printf("  %d THREW: %.600s\n",BYTES,e.what()); return false; }
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  int* out=(int*)malloc_device(8,q);
  q.memset(out,0,4).wait();
  bool ok = try_slm<SLM_SIZE>(q,out);
  printf("slm_init<%d>: %s\n", SLM_SIZE, ok?"RUNS OK (full-region R/W verified)":"FAILS");
  return 0;
}
