// bench_packvec.cpp -- section 100 P8-first: the batched family's pack_a gather at
// its SCALAR form (1 byte/thread -- today's gather_pack_a_b) vs a 128-BIT VECTOR
// form (16 bytes/thread: the tile's row segment kb*32..+32 is CONTIGUOUS in the
// source AND in the tile -> one 16B load + one 16B store).
// The senior's Windows ledger (improve-shared-memory.md "copy the operand bits in
// 128-bit vectors: 4032x256x256 145->95us") proves this lever on this driver
// family; our pack is the worst spelling (byte scalar). EXACT = byte diff 0;
// speed = wall-clock min-of-trials per launch pair (host-timed; the pack fns
// return void).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>
#include <functional>
#include "pack_device.hpp"
using namespace sycl;

// the vector form: SAME map as gather_pack_a_b, items = 16-byte runs.
// tile block = BM(128) x BK(32): 8 wi-blocks x 512B; off = row*32 + k with
// k in {0,16} -> the run never crosses a row AND stays 16-aligned on both sides
// (given lda%16==0 and sa%16==0 -- the frame: lda=K (mult 32), sa=0).
static void gather_pack_a_b_v(sycl::queue& q, const int8_t* Araw, int8_t* Ap,
                              int M, int Mp, int K, int lda, size_t sa, int batch) {
    const int BM = 128, BK = 32;
    int wgr = Mp / BM, kb_n = K / BK;
    size_t per = (size_t)wgr * kb_n * 8 * 512;
    q.parallel_for(sycl::range((size_t)batch * per / 16), [=](sycl::item<1> it) {
        size_t d16 = it.get_id(0);
        size_t gg = d16 / (per / 16); size_t d = (d16 % (per / 16)) * 16;
        size_t blk = d / 512; int off = (int)(d % 512);
        int wi = (int)(blk % 8); size_t wk = blk / 8;
        int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
        int row = off / 32;                          // off%32 = k = 0 or 16
        int srow = w * BM + wi * 16 + row;
        sycl::vec<unsigned, 4> v(0u);
        if (srow < M) {
            const sycl::vec<unsigned, 4>* sp = reinterpret_cast<const sycl::vec<unsigned, 4>*>(
                Araw + gg * sa + (size_t)srow * lda + (size_t)kb * BK + (off % 32));
            v = *sp;
        }
        *reinterpret_cast<sycl::vec<unsigned, 4>*>(Ap + gg * per + d) = v;
    });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{int M,N,K,b;};
  std::vector<Cfg> cfgs={{2040,128,256,8},{32640,128,64,2},{32640,32,128,2},
                         {640,64,256,8},{8160,128,128,4},{8160,32,128,4}};
  auto time_n = [&](std::function<void()> f, int n)->double {
      f(); q.wait();
      auto t0 = std::chrono::steady_clock::now();
      for (int i = 0; i < n; ++i) f();
      q.wait();
      auto t1 = std::chrono::steady_clock::now();
      return std::chrono::duration<double, std::milli>(t1 - t0).count() / n;
  };
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K,b=cf.b;
    int Mp=((M+127)/128)*128;
    std::vector<int8_t> A((size_t)b*M*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:A)x=(int8_t)da(rng);
    size_t per=(size_t)Mp*K;
    std::vector<int8_t> Ap((size_t)b*per, 0x5A), Ap2((size_t)b*per, 0x5A);
    int8_t *dA=(int8_t*)malloc_device(A.size(),q);
    int8_t *dAp=(int8_t*)malloc_device(Ap.size(),q),*dAp2=(int8_t*)malloc_device(Ap2.size(),q);
    q.memcpy(dA,A.data(),A.size()).wait();
    q.memset(dAp,0x5A,Ap.size()); q.memset(dAp2,0x5A,Ap2.size()); q.wait();
    packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,K,0,b);
    gather_pack_a_b_v(q,dA,dAp2,M,Mp,K,K,0,b);
    q.wait();
    std::vector<int8_t> h1(Ap.size()), h2(Ap2.size());
    q.memcpy(h1.data(),dAp,h1.size()).wait();
    q.memcpy(h2.data(),dAp2,h2.size()).wait();
    size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
    double bs=time_n([&]{ packdev::gather_pack_a_b(q,dA,dAp,M,Mp,K,K,0,b); },21);
    double bv=time_n([&]{ gather_pack_a_b_v(q,dA,dAp2,M,Mp,K,K,0,b); },21);
    printf("M=%-6d N=%-4d K=%-4d b=%d  scalar=%8.4f vec16=%8.4f ms  diff=%zu / %zu\n",
           M,N,K,b,bs,bv,diff,h1.size());
    free(dA,q);free(dAp,q);free(dAp2,q);
  }
  return 0;
}
