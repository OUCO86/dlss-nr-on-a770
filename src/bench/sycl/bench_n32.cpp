// bench_n32.cpp -- section 100 P8: the batched family's N=32 shapes (the frame:
// (32640,32,128,b2)x16 + (8160,32,128,b4)x24 = 40 calls) run SPLIT today:
// gemm32_b (BN=32) + a SCALAR elementwise publish (the fat the fused BN=64 tail
// already killed for N=128). (bench_batched's N=32 rows are EMPTY LAUNCHES:
// wg=(Mp/128)*(32/64)=0 -- the 0.0019ms there is a no-op, not a measurement.)
// P8-b: the frame plan calls {1272,b,1275,1273,bs, 32640,32,128,2, sa=128,
// sb=4096, sc=32, lda=256, ldb=128, ldc=64, ss=0, epi1}: the group A slices are
// ROW-INTERLEAVED (lda=K*batch, sa=K) -> the RAW A already IS the wide row;
// sc=N && ldc=N*batch -> the wide C row is exactly the ldc layout; sb=N*K ->
// the B is block-diagonal in the wide operand; b_scale raw = batch*N floats
// concatenated = the wide bs array. So ONE wide gemm (M, Nw=N*b, Kw=K*b) with
// gather_pack_a_b_v(sa=0,batch=1) + gather_pack_b_diag_b is EXACT, zero padding.
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
    int Nw=N*b, Kw=K*b;
    // raw A = M x Kw ROW-INTERLEAVED (frame lda=Kw, sa=K); raw B = b slices of N x K
    std::vector<int8_t> A((size_t)M*Kw),B((size_t)b*N*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:A)x=(int8_t)da(rng); for(auto&x:B)x=(int8_t)da(rng);
    std::vector<float> as((size_t)Mp,1.f),bs((size_t)Nw,1.f);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q),*dB=(int8_t*)malloc_device(B.size(),q);
    int8_t *dAp=(int8_t*)malloc_device((size_t)b*Mp*K,q),*dBp=(int8_t*)malloc_device((size_t)b*N*K,q);
    float *das=(float*)malloc_device(as.size()*4,q),*dbs=(float*)malloc_device(bs.size()*4,q);
    half* dC=(half*)malloc_device((size_t)b*Mp*N*2,q);
    int32_t* dC32=(int32_t*)malloc_device((size_t)b*Mp*N*4,q);
    q.memcpy(dA,A.data(),A.size()).wait(); q.memcpy(dB,B.data(),B.size()).wait();
    q.memcpy(das,as.data(),as.size()*4).wait(); q.memcpy(dbs,bs.data(),bs.size()*4).wait();
    // ---- split legs (today's recorder form): lda=Kw, sa=K
    packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,Kw,(size_t)K,b);
    packdev::gather_pack_b_b(q,dB,dBp,N,K,K,(size_t)N*K,b);
    q.wait();
    double t_g32 = tm([&]{ s8v8::gemm32_b(q,dAp,dBp,dC32,Mp,N,K,b); }, 15);
    double t_pub = tm([&]{
      q.parallel_for(sycl::range((size_t)b*M*N), [=](sycl::item<1> it){
        size_t i = it.get_id(0);
        unsigned mn = M*N;
        unsigned g=(unsigned)(i/mn); size_t rem=i%mn;
        unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
        float v = cr_mul(cr_mul((float)dC32[(size_t)g*Mp*N+(size_t)r*N+col], das[r]), dbs[(size_t)g*N+col]);
        ((half*)dC)[(size_t)g*Mp*N+(size_t)r*N+col] = sycl::half(qr_publish(1u, v));   // epi1 = the frame's N=32 calls
      });
    }, 15);
    printf("M=%-6d N=%-4d K=%-4d b=%d  SPLIT gemm32=%8.4f pub_scalar=%8.4f total=%8.4f ms\n",
           M,N,K,b,t_g32,t_pub,t_g32+t_pub);

    // ---- the wide merge (EXACT, zero padding) ----
    int8_t* dApw=(int8_t*)malloc_device((size_t)Mp*Kw,q);
    int8_t* dBpw=(int8_t*)malloc_device((size_t)Nw*Kw,q);
    packdev::gather_pack_a_b_v(q,dA,dApw,M,Mp,Kw,Kw,0,1);
    packdev::gather_pack_b_diag_b(q,dB,dBpw,N,K,K,(size_t)N*K,b);
    q.wait();
    half* dCw=(half*)malloc_device((size_t)Mp*Nw*2,q);
    double t_wp = tm([&]{ s8v8::gemm_b_pub(q,dApw,dBpw,(void*)dCw,das,dbs,M,Mp,Nw,Kw,1,
                                           (size_t)0,(unsigned)Nw,0u,0u,true,1u); }, 15);
    double t_wslm = tm([&]{ s8v8::gemm_b_pub_slm<false>(q,dApw,dBpw,(void*)dCw,das,dbs,M,Mp,Nw,Kw,1,
                                           (size_t)0,(unsigned)Nw,0u,0u,true,1u); }, 15);
    double t_apack = tm([&]{ packdev::gather_pack_a_b_v(q,dA,dApw,M,Mp,Kw,Kw,0,1); }, 15);
    printf("   WIDE pub=%8.4f pub_slm=%8.4f | pack_a_wide=%8.4f  total_pub=%8.4f total_slm=%8.4f ms\n",
           t_wp, t_wslm, t_apack, t_wp+t_apack, t_wslm+t_apack);

    // ---- EXACT check: wide pub vs the split chain (both epi1) ----
    // one truth pass of the split legs (the timed loops already produced dC32/dC;
    // rerun deterministically):
    s8v8::gemm32_b(q,dAp,dBp,dC32,Mp,N,K,b).wait();
    q.parallel_for(sycl::range((size_t)b*M*N), [=](sycl::item<1> it){
        size_t i = it.get_id(0); unsigned mn=M*N;
        unsigned g=(unsigned)(i/mn); size_t rem=i%mn;
        unsigned r=(unsigned)(rem/N), col=(unsigned)(rem%N);
        float v = cr_mul(cr_mul((float)dC32[(size_t)g*Mp*N+(size_t)r*N+col], das[r]), dbs[(size_t)g*N+col]);
        ((half*)dC)[(size_t)g*Mp*N+(size_t)r*N+col] = sycl::half(qr_publish(1u, v));
    }).wait();
    s8v8::gemm_b_pub(q,dApw,dBpw,(void*)dCw,das,dbs,M,Mp,Nw,Kw,1,(size_t)0,(unsigned)Nw,0u,0u,true,1u).wait();
    std::vector<half> hs((size_t)b*Mp*N), hw((size_t)Mp*Nw);
    q.memcpy(hs.data(),dC,hs.size()*2).wait();
    q.memcpy(hw.data(),dCw,hw.size()*2).wait();
    size_t wd=0;
    for(int r2=0;r2<M;++r2) for(int cw=0;cw<Nw;++cw){
        int g2=cw/N, col=cw%N;
        half a = hw[(size_t)r2*Nw+cw];
        half bb_ = hs[(size_t)g2*Mp*N+(size_t)r2*N+col];
        if (memcmp(&a,&bb_,2)) { if (wd<4) printf("WDIFF r=%d cw=%d wide=%.6g split=%.6g\n",r2,cw,(float)a,(float)bb_); wd++; }
    }
    printf("   WIDE pub vs split-publish byte diff: %zu / %zu\n", wd, (size_t)M*Nw);
    free(dA,q);free(dB,q);free(dAp,q);free(dBp,q);free(das,q);free(dbs,q);free(dC,q);free(dC32,q);
    free(dApw,q);free(dBpw,q);free(dCw,q);
  }
  return 0;
}
