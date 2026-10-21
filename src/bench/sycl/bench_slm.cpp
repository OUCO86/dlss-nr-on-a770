// bench_slm.cpp -- section 93: is the real wall SLM SIZE, not multi-subgroup? bench_wall
// proved 256-thread ESIMD + cross-subgroup SLM + dpas does NOT crash. mega256 crashed with
// slm_init<8*2560>=20480B. Scan slm_init sizes at 256 threads (8 subgroups), each in its
// own process. Find the exact SLM ceiling.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;
template<int BYTES> void run(queue& q, float* C){
  q.submit([&](handler& h){
    h.parallel_for(nd_range<1>(range(256u),range(256u)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
      esimd::slm_init<BYTES>();
      uint lid=(uint)it.get_local_id(0);
      esimd::simd<float,8> v(float(lid)+1.f);
      esimd::slm_block_store((lid%32u)*32u,v,esimd::overaligned_tag<16>{});
      esimd::barrier();
      esimd::simd<float,8> r=esimd::slm_block_load<float,8>((lid%32u)*32u,esimd::overaligned_tag<16>{});
      r.copy_to(C+(size_t)lid*8u);
    }); });
  q.wait();
}
int main(int argc,char**argv){
  int bytes=argc>1?atoi(argv[1]):2048;
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* C=(float*)malloc_device(256*8*4,q);
  printf("slm=%d launching...\n",bytes); fflush(stdout);
  try {
    switch(bytes){
      case 1024: run<1024>(q,C); break;
      case 2048: run<2048>(q,C); break;
      case 4096: run<4096>(q,C); break;
      case 8192: run<8192>(q,C); break;
      case 12288: run<12288>(q,C); break;
      case 16384: run<16384>(q,C); break;
      case 20480: run<20480>(q,C); break;
      case 24576: run<24576>(q,C); break;
      case 32768: run<32768>(q,C); break;
      case 49152: run<49152>(q,C); break;
      case 65536: run<65536>(q,C); break;
      default: printf("bad size\n"); return 1;
    }
    std::vector<float> hc(256*8); q.memcpy(hc.data(),C,hc.size()*4).wait();
    int ok=0; for(size_t i=0;i<hc.size();++i) if(hc[i]==float(i/8u%256u)+1.f) ok++;
    printf("slm=%d OK (%d/%zu correct)\n",bytes,ok,hc.size());
  } catch(const sycl::exception&e){ printf("slm=%d THREW: %s\n",bytes,e.what()); return 2; }
  return 0;
}
