// bench_reqd_esimd.cpp -- section 96 part 2 CLEAN: three independent kernels, each a full
// copy of the SAME esimd body (global block-load tag<16> x128h + dpas<8,8,float> + scalar
// store) but each with a different [[intel::reqd_sub_group_size(W]] on a PLAIN nd kernel
// (no SYCL_ESIMD_KERNEL marker). Answers the v2 questions: (a) what width does a plain
// kernel + esimd body ACTUALLY get (sg probe), (b) do the shipped-body types (which force
// dpas N=8 by their operand shapes: the gemm static_asserts) even compile at reqd 16/32,
// (c) does IGC's divide-by-zero extend to esimd-in-plain-kernel at reqd 32 or was it
// joint_matrix-only (it was: reqd32+esimd without dpas = fine per the earlier note; dpas
// here = the interesting combo). Correct target: all ones in A/B packs -> every D lane 16.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

struct tag8  { static constexpr int W=8; };
struct tag16 { static constexpr int W=16; };
struct tag32 { static constexpr int W=32; };
template<typename TAG>
static bool run(queue& q, half* G, const char* nm){
  float* O=(float*)malloc_device(8*4,q); float* PR=(float*)malloc_device(4,q);
  q.memset(O,0,32).wait(); q.memset(PR,0,4).wait();
  constexpr int W=TAG::W;
  bool threw=false;
  try{
    q.submit([&](handler& h){
      auto k=[=](nd_item<1> it){
        auto sg=it.get_sub_group();
        uint lid=(uint)it.get_local_id(0);
        esimd::simd<sycl::half,128> a0(G,esimd::overaligned_tag<16>{});
        esimd::simd<sycl::half,128> b0(G+128,esimd::overaligned_tag<16>{});
        esimd::simd<float,8> c(0.f);
        c=esimd::xmx::dpas<8,8,float>(c,b0,a0);
        if(lid==0u){ PR[0]=(float)sg.get_local_range().size();
          for(int i=0;i<8;++i) O[i]=c[i]; }
      };
      if constexpr(W==8)  h.parallel_for(nd_range<1>(range(64u),range(64u)),
        [=](nd_item<1> it) [[intel::reqd_sub_group_size(8)]]  { k(it); });
      if constexpr(W==16) h.parallel_for(nd_range<1>(range(64u),range(64u)),
        [=](nd_item<1> it) [[intel::reqd_sub_group_size(16)]] { k(it); });
      if constexpr(W==32) h.parallel_for(nd_range<1>(range(64u),range(64u)),
        [=](nd_item<1> it) [[intel::reqd_sub_group_size(32)]] { k(it); });
    });
    q.wait();
  }catch(const sycl::exception&e){ threw=true; printf("[%s] THREW: %.60s\n",nm,e.what()); }
  if(threw) return false;
  float hp=0; std::vector<float> ho(8,0.f);
  q.memcpy(&hp,PR,4).wait(); q.memcpy(ho.data(),O,32).wait();
  bool ok=true; for(float v:ho) if(v!=16.f) ok=false;
  printf("[%s] got sg=%2.0f  D[0..3]=%.1f %.1f %.1f %.1f -> %s\n",nm,hp,ho[0],ho[1],ho[2],ho[3],ok?"CORRECT":"WRONG");
  return true;
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  std::vector<half> hg(256,half(1.0f));   // A block 128h + B block 128h = 512B, all ones
  half* G=(half*)malloc_device(512,q); q.memcpy(G,hg.data(),512).wait();
  printf("plain nd kernel + reqd_sub_group_size + esimd global-blocks + dpas<8,8,float>(D simd<f32,8>,A/B simd<h,128>)\n");
  run<tag8 >(q,G,"reqd8 ");
  run<tag16>(q,G,"reqd16");
  run<tag32>(q,G,"reqd32");
  return 0;
}
