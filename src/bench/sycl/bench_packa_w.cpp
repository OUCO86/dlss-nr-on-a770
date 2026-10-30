// bench_packa_w.cpp -- B3-2 leg 2: the pack_a leg (the leg map prices the f16
// family's pack leg at -5.4ms ON THE CRITICAL PATH: B_STOP=1 = 76.5 > BASE while
// B_STOP=2 = 74.9 -- removing the GEMM exposes the pack leg standing ALONE).
// pack_a_v = pure copy: read the int8 plane (coalesced), write the s8v8 tile
// layout. THE FLAW (address arithmetic, not a guess): in pack_a_v each thread
// WRITES a 16B vec at d = id*16 -- consecutive threads land 16B apart inside the
// SAME 512B A-band block, so a 32-thread message's 512B is a fine contiguous
// write... but the READ side strides: thread d reads row = off/32 (16 rows x 32B)
// -- 16 different rows x 32B = 16 sectors per 512B, and consecutive threads read
// DIFFERENT rows (off jumps 512B per thread) = 32 threads x 16B from 16 scattered
// rows. The WIDE variant: one thread copies a WHOLE 512B band-block (16 x 32B
// loads from its 16 rows, one 512B... no: the block's 512B = rows x32B: thread
// reads 16 contiguous 32B row-slices (strided K apart) and writes ONE contiguous
// 512B region (4 x 128B messages). Grid shrinks 32x. Judges: byte-diff vs
// pack_a_v (the shipping tile) + GB/s at the frame's pack shapes.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include <functional>
#include "pack_device.hpp"
using namespace sycl;
// event-returning twin of packdev::pack_a_v (the shipping form under test): the
// map is copied VERBATIM from pack_device.hpp (only the return type differs).
static event pack_a_v_ev(queue& q, const int8_t* A, int8_t* Ap, int M, int Mp, int K) {
    const int BM = 128, BK = 32;
    int wgr = Mp / BM, kb_n = K / BK;
    size_t n = (size_t)wgr * kb_n * 8 * 512;
    return q.parallel_for(sycl::range(n / 16), [=](sycl::item<1> it) {
        size_t d = it.get_id(0) * 16;
        size_t blk = d / 512; int off = (int)(d % 512);
        int wi = (int)(blk % 8); size_t wk = blk / 8;
        int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
        int row = off / 32;
        int srow = w * BM + wi * 16 + row;
        sycl::vec<unsigned, 4> v(0u);
        if (srow < M)
            v = *reinterpret_cast<const sycl::vec<unsigned, 4>*>(
                A + (size_t)srow * K + (size_t)kb * BK + (off % 32));
        *reinterpret_cast<sycl::vec<unsigned, 4>*>(Ap + d) = v;
    });
}

// the wide variant: thread = one 512B tile block = (w,kb,wi) band; reads the 16
// source rows (srow = w*128 + wi*16 + r) x 32B slice at kb*32, writes 4x128B.
static event pack_a_w(queue& q, const int8_t* A, int8_t* Ap, int M, int Mp, int K) {
    (void)0;
    const int BM = 128, BK = 32;
    int wgr = Mp / BM, kb_n = K / BK;
    size_t nblk = (size_t)wgr * kb_n * 8;          // 512B blocks
    return q.parallel_for(range(nblk), [=](item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        size_t blk = (size_t)it.get_id(0);
        int wi = (int)(blk % 8); size_t wk = blk / 8;
        int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
        int8_t* dst = Ap + blk * 512;
        #pragma unroll
        for (int r = 0; r < 16; ++r) {
            int srow = w * BM + wi * 16 + r;
            esimd::simd<int8_t,32> v((int8_t)0);
            if (srow < M)
                v = esimd::block_load<int8_t,32>(A + (size_t)srow * K + (size_t)kb * BK,
                                                 esimd::overaligned_tag<16>{});
            esimd::block_store<int8_t,32>(dst + r * 32, v, esimd::overaligned_tag<16>{});
        }
    });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  struct Cfg{int M,K;};
  // the frame's pack_a leg shapes (int8 pk -> tiled dAp), from the leg census
  std::vector<Cfg> cfgs={{32640,64},{8160,128},{2040,256},{640,512},{192,1024},{8160,512},{32640,256}};
  for(auto cf:cfgs){
    int M=cf.M,K=cf.K; int Mp=((M+127)/128)*128;
    std::vector<int8_t> hA((size_t)Mp*K); std::mt19937 rng(3);
    std::uniform_int_distribution<int> da(-127,127);
    for(auto&x:hA)x=(int8_t)da(rng);
    int8_t *dA=malloc_device<int8_t>(hA.size(),q);
    int8_t *p1=malloc_device<int8_t>(hA.size(),q), *p2=malloc_device<int8_t>(hA.size(),q);
    q.memcpy(dA,hA.data(),hA.size()).wait();
    q.memset(p1,0,hA.size()); q.memset(p2,0,hA.size()); q.wait();
    packdev::pack_a_v(q,dA,p1,M,Mp,K); q.wait();
    pack_a_w(q,dA,p2,M,Mp,K); q.wait();
    std::vector<int8_t> b1(hA.size()), b2(hA.size());
    q.memcpy(b1.data(),p1,hA.size()).wait(); q.memcpy(b2.data(),p2,hA.size()).wait();
    size_t d=0; for(size_t i=0;i<b1.size();++i) if(b1[i]!=b2[i]) ++d;
    auto timeit=[&](std::function<event()> fn){ double best=1e9;
      for(int it=0;it<9;++it){ event e=fn(); e.wait();
        double t=double(e.get_profiling_info<info::event_profiling::command_end>()-
                        e.get_profiling_info<info::event_profiling::command_start>());
        best=std::min(best,t/1e6);}
      return best;};
    double tv=timeit([&]{ return pack_a_v_ev(q,dA,p1,M,Mp,K); });
    double tw=timeit([&]{ return pack_a_w(q,dA,p2,M,Mp,K); });
    double gb=(double)hA.size()*2.0/tw/1e6;
    printf("M=%-6d K=%-5d: v=%.4f w=%.4f ms (%.0f GB/s r+w) diff %zu %s\n",
           M,K,tv,tw,gb,d,d?"NOT-EXACT":"EXACT");
  }
  return 0;
}
