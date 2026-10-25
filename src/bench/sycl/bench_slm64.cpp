// bench_slm64.cpp -- can an ESIMD kernel slm_init<65536> (64KB) compile AND run on the
// A770 (local_mem_size=64KB reported)? v9b (fold quant into the batched producer with
// BN=ldc=512 whole-row workgroups) needs A(32x32=1KB) + B(32x512=16KB) double-buffered
// = 34KB, plus rmax. If 64KB works, v9b is viable; if not, the fold needs a two-pass
// partial-max scheme instead.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
using namespace sycl;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev);
  int* out=(int*)malloc_device(4,q); q.memset(out,0,16).wait();
  // 64KB SLM, 64 threads, each writes its local id back
  try{
    q.parallel_for(nd_range<1>(range(64u),range(64u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      namespace esimd = sycl::ext::intel::esimd;
      esimd::slm_init<65536>();
      uint lid=(uint)it.get_local_id(0);
      esimd::simd<float,16> v(0.f);
      esimd::slm_block_store(lid*64u, v, esimd::overaligned_tag<16>{});
      esimd::barrier();
      esimd::simd<float,16> r = esimd::slm_block_load<float,16>(lid*64u, esimd::overaligned_tag<16>{});
      if(lid==0u) out[0]=1;
    }).wait();
    int h=0; q.memcpy(&h,out,4).wait();
    printf("slm_init<65536>: %s (out=%d)\n", h==1?"RUNS OK":"WRONG", h);
  }catch(const std::exception&e){ printf("slm_init<65536> THREW: %.120s\n",e.what()); }
  return 0;
}
