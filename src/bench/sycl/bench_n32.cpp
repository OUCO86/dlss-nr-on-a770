// bench_n32.cpp -- section 100 P8: the batched family's N=32 shapes (the frame:
// (32640,32,128,b2)x16 + (8160,32,128,b4)x24 = 40 calls) run SPLIT today:
// gemm32_b (BN=32) + a SCALAR elementwise publish over batch*M*N (2.09M/1.05M
// elements per call -- the fat the fused BN=64 tail already killed for N=128).
// (bench_batched's N=32 rows are EMPTY LAUNCHES: wg=(Mp/128)*(32/64)=0 for the
// BN=64 variants -- the 0.0019ms there is a no-op, not a measurement. This bench
// times the REAL split legs and the candidate: gemm_b_pub_slm at BN=64 with the
// CACHED B zero-padded to 64 rows + a column-guarded publish.)
#include <sycl/sycl.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <functional>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
using namespace sycl;

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  auto tm = [&](std::function<void()> f, int n)->double {
      f(); q.wait();
      auto t0 = std::chrono::steady_clock::now();
      for (int i = 0; i < n; ++i) f();
      q.wait();
      auto t1 = std::chrono::steady_clock::now();
      return std::chrono::duration<double, std::milli>(t1 - t0).count() / n;
  };
  struct Cfg{int M,N,K,b;};
  std::vector<Cfg> cfgs={{32640,32,128,2},{8160,32,128,4}};
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K,b=cf.b;
    int Mp=((M+127)/128)*128;
    std::vector<int8_t> A((size_t)b*M*K),B((size_t)b*N*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as((size_t)b*Mp,1.f),bs((size_t)b*N,1.f);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
    int8_t *dAp=(int8_t*)malloc_device((size_t)b*Mp*K,q),*dBp=(int8_t*)malloc_device((size_t)b*K*N,q);
    float *das=(float*)malloc_device(as.size()*4,q),*dbs=(float*)malloc_device(bs.size()*4,q);
    half* dC=(half*)malloc_device((size_t)b*Mp*N*2,q);
    int32_t* dC32=(int32_t*)malloc_device((size_t)b*Mp*N*4,q);
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(das,as.data(),as.size()*4).wait(); q.memcpy(dbs,bs.data(),bs.size()*4).wait();
    packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,K,0,b);
    packdev::gather_pack_b_b(q,dB,dBp,N,K,K,0,b);
    q.wait();
    // leg 1: gemm32_b alone (the shipped int32 stage for N=32)
    double t_g32 = tm([&]{ s8v8::gemm32_b(q,dAp,dBp,dC32,Mp,N,K,b); }, 15);
    // leg 2: the scalar publish (the recorder's form, VERBATIM map)
    double t_pub = tm([&]{
      q.parallel_for(sycl::range((size_t)b*M*N), [=](sycl::item<1> it){
        size_t i = it.get_id(0);
        unsigned mn = M*N;
        unsigned g=(unsigned)(i/mn); size_t rem=i%mn;
        unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
        float* gas=(float*)das+(size_t)g*0; (void)gas;
        float v = cr_mul(cr_mul((float)dC32[(size_t)g*Mp*N+(size_t)r*N+col], das[(size_t)g*Mp+r]), dbs[col]);
        ((half*)dC)[(size_t)g*Mp*N+(size_t)r*N+col] = sycl::half(qr_publish(3u, v));
      });
    }, 15);
    printf("M=%-6d N=%-4d K=%-4d b=%d  gemm32=%8.4f pub_scalar=%8.4f  split_total=%8.4f ms\n",
           M,N,K,b,t_g32,t_pub,t_g32+t_pub);
    // candidate sizing (TIMING ONLY -- the store map here writes the padded N64
    // layout; the promoted form masks cols>=N): pad B to 64 rows, bs to 64.
    int8_t* dBp64=(int8_t*)malloc_device((size_t)b*64*K,q);
    q.memset(dBp64,0,(size_t)b*64*K);
    for(int g2=0;g2<b;++g2) q.memcpy(dBp64+(size_t)g2*64*K,dB+(size_t)g2*N*K,(size_t)N*K).wait();
    float* dbs64=(float*)malloc_device((size_t)b*64*4,q);
    q.memcpy(dbs64,bs.data(),(size_t)b*N*4);
    q.memset((char*)dbs64+(size_t)b*N*4,0,(size_t)b*(64-N)*4); q.wait();
    half* dC64=(half*)malloc_device((size_t)b*Mp*64*2,q);
    int32_t* dC32b=(int32_t*)malloc_device((size_t)b*Mp*64*4,q);   // padded-width stage (the split-run dC32 is only N=32 wide -- writing 64 into it = OOB fault)
    double t_g64 = tm([&]{ s8v8::gemm_b(q,dAp,dBp64,dC32b,Mp,64,K,b); }, 15);
    double t_fused = tm([&]{ s8v8::gemm_b_pub_slm<false>(q,dAp,dBp64,(void*)dC64,das,dbs64,M,Mp,64,K,b,
                                             (size_t)Mp*64,64u,0u,0u,true,3u); }, 15);
    printf("   padded-BN64: gemm_b(int32)=%8.4f  gemm_b_pub_slm(FUSED)=%8.4f ms\n", t_g64, t_fused);
    free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(das,q);free(dbs,q);free(dC,q);free(dC32,q);
    free(dBp64,q);free(dbs64,q);free(dC64,q);free(dC32b,q);
  }
  return 0;
}
