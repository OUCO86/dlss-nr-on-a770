// bench_dpasm.cpp -- section 95: KEYSTONE for the "bypass" path. Prove that sycl-tla's
// XE_DPAS_TT (inline GenISA dpas asm, NOT joint_matrix, NOT ESIMD) compiles and RUNS without
// crashing inside a PLAIN nd_range SYCL kernel on the A770 with local icx 2026.1.1. This is
// the mechanism the user directed: workgroup + subgroup + XMX intrinsic + standard
// group_barrier. Numerical correctness is NOT the point here (that comes when wired into the
// resident kernel with stage-dumps); the point is: does the dpas-asm path survive compile +
// launch + execute on THIS toolchain + THIS GPU.
#include <sycl/sycl.hpp>
#include <cute/tensor.hpp>
#include <cute/arch/mma_xe.hpp>
#include <cstdio>
#include <vector>
using namespace sycl;
using namespace cute;
int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev);
  // f16 dpas atom: D=float, A=hf, B=hf, C=float, M=8. K=256/16=16.
  using Op = XE_DPAS_TT<8, dpas_type::f, dpas_type::hf, dpas_type::hf, dpas_type::f>;
  using DV = Op::DVector; using AV = Op::AVector; using BV = Op::BVector; using CV = Op::CVector;
  printf("DVector/AVector/BVector sizes: %d/%d/%d bytes\n",(int)sizeof(DV),(int)sizeof(AV),(int)sizeof(BV));
  float* Out=(float*)malloc_device(64*4,q);
  printf("launching plain-kernel dpas-asm...\n"); fflush(stdout);
  try {
    q.submit([&](handler& h){
      h.parallel_for(nd_range<1>(range(32u),range(32u)),[=](nd_item<1> it){
        Op op; DV d; AV a; BV b; CV c;
        for(int i=0;i<(int)(sizeof(a)/2);++i) reinterpret_cast<unsigned short*>(&a)[i]=0x3C00u; // half 1.0
        for(int i=0;i<(int)(sizeof(b)/2);++i) reinterpret_cast<unsigned short*>(&b)[i]=0x3C00u;
        for(int i=0;i<(int)(sizeof(c)/4);++i) reinterpret_cast<float*>(&c)[i]=0.f;
        op.fma(d,a,b,c);
        if(it.get_local_id(0)==0u)
          for(int i=0;i<(int)(sizeof(d)/4);++i) Out[i]=reinterpret_cast<float*>(&d)[i];
      }); });
    q.wait();
    std::vector<float> hc(64); q.memcpy(hc.data(),Out,64*4).wait();
    printf("dpas-asm PLAIN KERNEL: ran OK, d[0..3]=%.1f %.1f %.1f %.1f\n",hc[0],hc[1],hc[2],hc[3]);
    printf("=> MECHANISM CONFIRMED (dpas asm works outside ESIMD/joint_matrix)\n");
  } catch(const sycl::exception&e){ printf("THREW: %s\n",e.what()); return 2; }
  return 0;
}
