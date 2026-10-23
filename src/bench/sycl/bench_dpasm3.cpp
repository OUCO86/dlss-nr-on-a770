// bench_dpasm3.cpp -- section 95 keystone v3: the user's mechanism via the LOW-LEVEL XMX
// SPIR-V builtin, JIT path (no ocloc, no AOT). __spirv_SubgroupMatrixMultiplyAccumulateINTEL
// is the SPV_INTEL_subgroup_matrix_multiply_accumulate op (same one esimd::xmx::dpas lowers
// to, and the one vllm-xpu-kernels enables with -spirv-ext=+SPV_INTEL_subgroup_matrix_multiply_accumulate).
// Declared here with __DPCPP_SYCL_EXTERNAL (the pattern matrix-intel.hpp uses for vendor
// builtins) and called from a PLAIN nd_range kernel (no ESIMD, no joint_matrix).
// Layout per the SPIR-V spec: A = Repeat x (SystolicDepth*8/16) u32 = 8x2 u32? For f16:
// OpsPerChannel=2, K=SystolicDepth*2=16, A per-thread = M*K*16bits/32 = 8*16/2 = 64 u32,
// B = K*N*16/32 = 16*8/2 = 32 u32 (N=ExecutionSize=8), D/C = M f32 = 8.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
extern __DPCPP_SYCL_EXTERNAL sycl::ext::intel::esimd::simd<float,8>
__spirv_SubgroupMatrixMultiplyAccumulateINTEL(
    unsigned ExecutionSize, unsigned SystolicDepth, unsigned RepeatCount,
    sycl::ext::intel::esimd::simd<uint32_t,64> A,
    sycl::ext::intel::esimd::simd<uint32_t,32> B,
    sycl::ext::intel::esimd::simd<float,8> C);
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  float* Out=(float*)malloc_device(8*4,q);
  printf("launching PLAIN-kernel __spirv_SubgroupMatrixMultiplyAccumulateINTEL (JIT)...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(8u),range(8u)),[=](nd_item<1> it){
        sycl::ext::intel::esimd::simd<uint32_t,64> A(uint32_t(0x3C003C00u)); // half 1.0 x2
        sycl::ext::intel::esimd::simd<uint32_t,32> B(uint32_t(0x3C003C00u));
        sycl::ext::intel::esimd::simd<float,8> C(0.f);
        auto D = __spirv_SubgroupMatrixMultiplyAccumulateINTEL(8u,8u,8u,A,B,C);
        if(it.get_local_id(0)==0u)
          for(int i=0;i<8;++i) Out[i]=D[i];
      }); });
    q.wait();
    std::vector<float> hc(8); q.memcpy(hc.data(),Out,32).wait();
    printf("dpas-intrinsic PLAIN KERNEL JIT: D[0..3]=%.1f %.1f %.1f %.1f (want 16=K)\n",hc[0],hc[1],hc[2],hc[3]);
    bool ok=true; for(float v:hc) if(v!=16.f) ok=false;
    printf("=> %s\n", ok?"MECHANISM CONFIRMED (XMX builtin in plain kernel, JIT, no ocloc)":"ran, values wrong (layout to fix)");
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
