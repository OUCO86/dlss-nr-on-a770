#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
using namespace sycl; namespace esimd = sycl::ext::intel::esimd;
int main(){
  device dev; for(auto&d:device::get_devices(info::device_type::gpu)) if(d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev); float* out=malloc_shared<float>(16,q);
  q.single_task([=]() SYCL_ESIMD_KERNEL {
    esimd::simd<float,8> v(3.7f);
    esimd::simd<float,8> r = esimd::rnde<float,8>(v);          // round-to-even -> 4.0
    esimd::simd<int,8> ri = esimd::convert<int>(r);
    esimd::simd<int8_t,8> r8 = esimd::convert<int8_t>(ri);
    float m = esimd::hmax<float,float,8>(v);                    // 3.7
    esimd::simd<int32_t,8> iv(11);
    esimd::simd<float,8> fv = esimd::convert<float>(iv);                    // int32->float member
    out[0]=m; out[1]=(float)r8[0]; out[2]=fv[0]; out[3]=(float)esimd::abs(esimd::simd<float,8>(-2.3f))[0];
  }).wait();
  std::printf("scalar: hmax=%.2f r8=%d tofloat=%.1f abs=%.2f (want 3.70 4 11.0 2.30)\n",out[0],(int)out[1],out[2],out[3]);
  std::fflush(stdout);
  q.parallel_for(nd_range(range(2),range(2)),[=](nd_item<1> it) SYCL_ESIMD_KERNEL {
    esimd::slm_init<8>();
    float mine = (it.get_local_id(0)==0)? 5.0f : 9.0f;
    esimd::simd<uint32_t,1> off(0u);
    esimd::slm_atomic_update<esimd::atomic_op::fmax,float,1>(off, esimd::simd<float,1>(mine));
    esimd::barrier();
    float got = esimd::slm_atomic_update<esimd::atomic_op::load,float,1>(off).data()[0];
    if(it.get_local_id(0)==0) out[4]=got;
  }).wait();
  std::printf("slm_atomic fmax over 2 WI = %.1f (want 9.0)\n",out[4]);
  bool ok = out[0]==3.70f && (int)out[1]==4 && out[2]==11.0f && out[3]==2.30f && out[4]==9.0f;
  std::printf(ok?"PROBE_OK\n":"PROBE_MISMATCH\n");
  return 0;
}
