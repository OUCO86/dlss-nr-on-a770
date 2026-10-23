// bench_v2crash.cpp -- section 96: bisect the v2 DEVICE_LOST by SHAPE, real sizes.
// W0: nd(windows*256/256) ESIMD kernel: P0-only writes (scalar global scatter) + barrier
//     + return. If THIS crashes -> the crash is the giant workgroup-count ESIMD launch
//     or the scatter pattern, NOT the dpas tiles.
// W1: + one P1-style tile per subset of SGs (16 tiles of the 24) + store16.
// W2: full P1 (24 tiles loop).
// All write into per-window slices in ONE big pool allocation, mirroring launch_v2.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <string>
#include <random>
#include "publish_kernel.hpp"
#include "window_block_mega.hpp"     // eh_* helpers + tile8-like patterns? no, define own
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

constexpr size_t WSL = 45056;   // halfs per window (same as wbv2)

int main(int argc,char**argv){
  int mode = argc>1?atoi(argv[1]):0;
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  unsigned windows=(argc>2)?(unsigned)atoi(argv[2]):2040u;
  half* WS=(half*)malloc_device(windows*WSL*2,q);
  q.memset(WS,0,windows*WSL*2).wait();
  half* WP=(half*)malloc_device(32*96*2 + 4096,q);   // fake packed weights area (kb2 tc6 -> 12 blocks? sizes per f16v1: K=32,N=96: 2*6*2*128 = 3072)
  std::vector<half> hw(3072,half(0.5f)); q.memcpy(WP,hw.data(),3072*2).wait();
  printf("mode=%d launching nd(%u x 256) ESIMD...\n",mode,windows); fflush(stdout);
  try{
    q.submit([&](handler& h){
      unsigned LW=(argc>3)?(unsigned)atoi(argv[3]):256u;
      h.parallel_for(nd_range<1>(range((size_t)windows*LW),range(LW)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
        uint window=(uint)it.get_group(0);
        uint lid=(uint)it.get_local_id(0);
        uint nsg=LW>>4;
        uint sgid=lid>>4;
        half* w=WS+(size_t)window*WSL;
        float* f32w=(float*)w;
        // P0-style scatter: 64x32 halfs into AQO (pa16 map inlined)
        {
          uint t=lid>>2, c0=(lid&3u)*8u;
          for(uint e=0;e<8;++e){ uint k=c0+e;
            uint tr=t>>4, strip=(t>>3)&1u, il=t&7u, kc=k>>4;
            uint d=((tr*2u+kc)*2u+strip)*128u + il*16u + (k&15u);
            w[d]=half(1.0f); }
        }
        if (mode<200) group_barrier(it.get_group());
        if (mode>=1){
          // P1 tiles: store f32 dCq-style outputs (24/16 or 16/16 tiles)
          uint nt = (mode>=2)?24u:16u;
          for (uint tile=sgid; tile<nt; tile+=nsg){
            uint tr=tile/6u, tc=tile%6u;
            esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
            for(int kc=0;kc<2;++kc){
              const half* ab=w+(size_t)tr*512u+(size_t)kc*256u;
              const half* bb=WP+(size_t)tc*256u+(size_t)kc*(size_t)6*256u;
              esimd::simd<half,128> a0(ab,esimd::overaligned_tag<16>{});
              esimd::simd<half,128> a1(ab+128,esimd::overaligned_tag<16>{});
              esimd::simd<half,128> b0(bb,esimd::overaligned_tag<16>{});
              esimd::simd<half,128> b1(bb+128,esimd::overaligned_tag<16>{});
              c00=esimd::xmx::dpas<8,8,float>(c00,b0,a0);
              c01=esimd::xmx::dpas<8,8,float>(c01,b1,a0);
              c10=esimd::xmx::dpas<8,8,float>(c10,b0,a1);
              c11=esimd::xmx::dpas<8,8,float>(c11,b1,a1);
            }
            float* out=f32w+2048/2+(size_t)(tr*16u)*96u+tc*16u;
            for(int r=0;r<8;++r){
              esimd::simd<float,8> r00=c00.template select<8,1>(r*8), r01=c01.template select<8,1>(r*8);
              esimd::simd<float,8> r10=c10.template select<8,1>(r*8), r11=c11.template select<8,1>(r*8);
              r00.copy_to(out+(size_t)r*96);        r01.copy_to(out+(size_t)r*96+8);
              r10.copy_to(out+(size_t)(8+r)*96);    r11.copy_to(out+(size_t)(8+r)*96+8);
            }
          }
          group_barrier(it.get_group());
        }
        if (mode>=3){
          // P2-style: threads 0..127 read the f32 region scalar + write packs (register pressure test)
          if(lid<128u){ float hv[32]; uint r=lid&63u;
            for(uint c=0;c<32;++c) hv[c]=f32w[2048/2+r*96u+c+(lid<64u?0u:32u)];
            w[14336u + r*32u + (lid&31u)] = half(hv[(lid>>5)&31u]); }
          group_barrier(it.get_group());
        }
        // final: window 0 lane 0 prints a checksum so host can verify it ran
        if(window==0u && lid==0u){ float s=0; for(int i=0;i<96;++i) s+=f32w[2048/2+i];
          // can't printf in kernel; encode into WS tail slot
          w[WSL-1]=half(s); }
      }); });
    q.wait();
    std::vector<half> tail(1);
    q.memcpy(tail.data(),WS+(size_t)0*WSL+WSL-1,2).wait();
    printf("mode=%d OK, cksum=%s\n",mode,tail[0]==half(0.f)?"0?":std::to_string((float)tail[0]).c_str());
  }catch(const sycl::exception&e){ printf("mode=%d THREW: %.160s\n",mode,e.what()); return 2; }
  return 0;
}
