// bench_laws.cpp -- the A770 LITTLE'S-LAW / RESIDENCY curve, measured before ANY
// further residency-shaped blade (the user's standing order: model + measure
// first, cut second). Question: for the frame's access pattern (independent
// 32B-lane strided half loads, the chip's dEp/dPp weight stream and the
// elementwise legs' shape), how much in-flight load volume does one A770 SM
// need to saturate, and how does that split across (threads/WG) x (WG/SM)?
// One ESIMD kernel, ALL shape params from the host (no template zoo).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
#include <algorithm>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

int main(int argc, char** argv){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  const size_t MB = 64ull<<20;              // 64MB source (bigger than L2: DRAM-bound)
  half* src = malloc_device<half>(MB/2, q);
  q.parallel_for(range(MB/2), [=](item<1> it){ ((half*)src)[it.get_id(0)] = half((float)(it.get_id(0)%97)); }).wait();
  float* sink = malloc_device<float>(64<<20, q);

  struct Cfg { int NT; int SLMKB; int ILP; const char* note; };
  Cfg cfgs[] = {
    {16, 0, 8,  "NT16 deep-ILP"},
    {16, 0, 16, "NT16 x16"},
    {32, 0, 8,  "NT32 x8"},
    {64, 0, 4,  "NT64 x4"},
    {32, 0, 4,  "NT32 x4"},
    {16, 0, 4,  "NT16 x4"},
    {8,  0, 8,  "NT8 x8"},
  };
  printf("DRAM read stream (64MB working set), GB/s by shape:\n");
  for(auto&C:cfgs){
    int ILP=C.ILP, NT=C.NT;
    size_t wgs = (16u*1024u*1024u/ (size_t)NT);   // ~16M lanes total
    auto e = q.submit([&](handler& h){
      h.parallel_for(nd_range(range(wgs*NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint g=(uint)it.get_group(0); uint l=(uint)it.get_local_id(0);
        size_t base=((size_t)g*NT+l)*32u;
        esimd::simd<float,16> acc(0.f);
        for(int i=0;i<ILP;++i){
          size_t off=(base+(size_t)i*(size_t)NT*32u)%(MB/2);
          acc += esimd::convert<float>(esimd::block_load<half,16>(src+off, esimd::overaligned_tag<16>{}));
        }
        if (esimd::hmax<float,float,16>(acc) == 123456.789f) sink[base]=1.f;
      });
    });
    e.wait();
    double t=1e9;
    for(int r=0;r<9;++r){
      event ee=q.submit([&](handler& h){
        h.parallel_for(nd_range(range(wgs*NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
          uint g=(uint)it.get_group(0); uint l=(uint)it.get_local_id(0);
          size_t base=((size_t)g*NT+l)*32u;
          esimd::simd<float,16> acc(0.f);
          for(int i=0;i<ILP;++i){
            size_t off=(base+(size_t)i*(size_t)NT*32u)%(MB/2);
            acc += esimd::convert<float>(esimd::block_load<half,16>(src+off, esimd::overaligned_tag<16>{}));
          }
          if (esimd::hmax<float,float,16>(acc) == 123456.789f) sink[base]=1.f;
        });
      });
      ee.wait();
      t=std::min(t,(double)(ee.get_profiling_info<info::event_profiling::command_end>()-ee.get_profiling_info<info::event_profiling::command_start>())/1e6);
    }
    // bytes actually read = wgs*NT*ILP*32 halfs*2B, capped by the 64MB set (wraps): count real = min(wgs*NT*ILP*64B, ... just report the streamed volume)
    double bytes=(double)wgs*NT*ILP*32.0*2.0;
    printf("  %-14s NT=%2d ILP=%2d : %8.4f ms  %6.1f GB/s (streamed %.1f MB)\n",
           C.note, NT, ILP, t, bytes/t/1e6, bytes/1e6);
  }
  return 0;
}
