// bench_dpasm2.cpp -- section 95 keystone v2: the user's mechanism, JIT path, no ocloc.
// __spirv_SubgroupMatrixMultiplyAccumulateINTEL is the LOW-LEVEL XMX intrinsic (the same one
// esimd::xmx::dpas lowers to -- the shipped f16v1::gemm runs on it). Call it from a PLAIN
// nd_range kernel (no ESIMD, no joint_matrix). Vector layouts taken verbatim from sycl-tla's
// mma_xe.hpp asm: SRC1_UD=128 elts u16 (=64 u32) for A, SRC2_UD=M*8=64 elts u16 (=32 u32)
// for B, DST/SRC0 = M=8 f32. M8 N8 K16 f16->f32, ExecutionSize=8, SystolicDepth=8, Repeat=8.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
// the SPIR-V builtin declaration (intel/llvm sycl/detail/spirv.hpp pattern)
extern "C" {
SYCL_EXTERNAL sycl::ext::intel::esimd::simd<float,8> __spirv_SubgroupMatrixMultiplyAccumulateINTEL(
    unsigned ExecutionSize, unsigned SystolicDepth, unsigned RepeatCount,
    sycl::ext::intel::esimd::simd<uint32_t,64> A,
    sycl::ext::intel::esimd::simd<uint32_t,32> B,
    sycl::ext::intel::esimd::simd<float,8> C);
}
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* Out=(float*)malloc_device(8*4,q);
  printf("launching PLAIN-kernel __spirv_...AccumulateINTEL (JIT)...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(8u),range(8u)),[=](nd_item<1> it){
        sycl::ext::intel::esimd::simd<uint32_t,64> A;
        sycl::ext::intel::esimd::simd<uint32_t,32> B;
        sycl::ext::intel::esimd::simd<float,8> C(0.f);
        A = uint32_t(0x3C003C00u);   // two half 1.0 per dword
        B = uint32_t(0x3C003C00u);
        auto D = __spirv_SubgroupMatrixMultiplyAccumulateINTEL(8u,8u,8u,A,B,C);
        if(it.get_local_id(0)==0u)
          for(int i=0;i<8;++i) Out[i]=D[i];
      }); });
    q.wait();
    std::vector<float> hc(8); q.memcpy(hc.data(),Out,32).wait();
    printf("dpas-intrinsic PLAIN KERNEL JIT: ran, D[0..3]=%.1f %.1f %.1f %.1f (want 16 = K)\n",hc[0],hc[1],hc[2],hc[3]);
    bool ok=true; for(float v:hc) if(v!=16.f) ok=false;
    printf("=> %s\n", ok?"MECHANISM CONFIRMED (XMX intrinsic works in plain kernel, JIT, no ocloc)":"ran but values wrong (layout to fix)");
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
