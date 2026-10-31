// bench_s8w5.cpp -- S4 W5/GRF-resident-B priced BEFORE the dll (military rule 8;
// the §6.22 density ledger: s8v8 per kb per subgroup reads 32KB SLM vs 6KB unique
// = 5.3x; the B half's 8x redundancy = 8 wi_row threads re-reading the same B
// fragment). lmxx's W5 shares the LDS weight across 5 waves (reads /5, 48.8->37us);
// OUR form (per §6.22's pinned fix): the B operand lives IN REGISTERS for the
// whole K span (K<=128 -> kb_n<=4 -> 4x2x256B = 2KB/thread extra, the safe zone
// the chip's 12x-simd<float,64>=3KB wall taught us), SLM carries ONLY A.
// Shapes = the frame's gemm_b/gemm32_b/qkv family at K<=128 (the census above).
// Judge: byte diff vs the shipped gemm_b/gemm32_b at the SAME inputs = EXACT
// (the dpas order per kb is unchanged; only the operand residence moves), then time.
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
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---- the variant: gemm_b with B GRF-resident (K = kb_n*32, kb_n <= 4) ----
static inline sycl::event gemm_b_resb(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                      int32_t* C32, int Mp, int N, int K, int batch) {
    const int BM = 128, BN = 64, BK = 32, NT = 32;
    const int SLM_A = BM * BK;              // 4KB
    const int kb_n = K / BK;
    if (kb_n > 4) { return s8v8::gemm_b(q, Ap, Bp, C32, Mp, N, K, batch); }  // fallback
    // SLM: A triple-buffer (s8d2) + B single staging block (kb_n*2KB, read once)
    const int SLM_BFULL = kb_n * BK * BN;   // <= 8KB
    const int SLM_TOTAL = 3 * SLM_A + SLM_BFULL;
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * 4096 + 4 * 2048>();   // 20KB max (kb_n<=4)
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb_g = Ap + (size_t)g * (size_t)Mp * K;
            const int8_t* bp_g  = Bp + (size_t)g * (size_t)N * K;
            int32_t* c_g = C32 + (size_t)g * (size_t)Mp * N;
            const int8_t* apb = apb_g + (size_t)(wg_row * kb_n) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN / 8) * 256;
            // PROLOGUE: the whole B for this column block -> SLM (one pass), then
            // into GRF (kb_n x {b0,b1}). SLM B staging = kb_n*BK*BN contiguous bytes.
            {
                esimd::simd<int8_t, 64> bv = esimd::block_load<int8_t, 64>(
                    bp + lid * 64, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(3 * SLM_A + lid * 64, bv, esimd::overaligned_tag<16>{});
                for (int kb = 1; kb < kb_n; ++kb) {
                    esimd::simd<int8_t, 64> bv2 = esimd::block_load<int8_t, 64>(
                        bp + (size_t)kb * N * 32 + lid * 64, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(3 * SLM_A + kb * SLM_A / 2 + lid * 64, bv2, esimd::overaligned_tag<16>{});
                }
            }
            auto load_a = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
            };
            esimd::simd<int8_t, 256> bres[4][2];
            esimd::simd<int8_t, 256> a0, a1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_a(0, 0);
            if (kb_n > 1) load_a(1, 1);
            esimd::barrier();
            #pragma unroll
            for (int kb = 0; kb < 4; ++kb) {
                if (kb < kb_n) {
                    uint32_t offB = 3 * SLM_A + kb * (SLM_A / 2) + wi_col * 512;
                    bres[kb][0] = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                    bres[kb][1] = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                }
            }
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_a((b + 2) % 3, b + 2);   // depth-2: NEVER the cur slot
                uint32_t offA = cur * SLM_A + wi_row * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, bres[b][0], a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, bres[b][1], a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, bres[b][0], a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, bres[b][1], a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<int32_t, 16> row0;
                row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                esimd::simd<int32_t, 16> row1;
                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

// ---- the variant: gemm_b with B GRF-resident (K = kb_n*32, kb_n <= 4) ----
// v2 (the fix v1's 0.58-0.76x shape): B = the CACHED weight pack -> load it
// DIRECTLY into GRF (block_load, no SLM staging round-trip at all -- the b16b
// lesson: SLM-staged residency costs more than it saves). A keeps the s8d2
// triple-buffer SLM path; B's per-kb SLM reads (8x redundant) vanish.
static inline sycl::event gemm_b_resb2(sycl::queue& q, const int8_t* Ap, const int8_t* Bp,
                                       int32_t* C32, int Mp, int N, int K, int batch) {
    const int BM = 128, BN = 64, BK = 32, NT = 32;
    const int SLM_A = BM * BK;              // 4KB
    const int kb_n = K / BK;
    int wg = (Mp / BM) * (N / BN);
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wg * batch * NT), range(NT)), [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<3 * 4096>();    // A triple-buffer only
            int gid = (int)it.get_group(0);
            int lid = (int)it.get_local_id(0);
            int g = gid / wg; int loc = gid % wg;
            int NB = N / BN;
            int wg_row = loc / NB, wg_col = loc % NB;
            int wi_row = lid / 4, wi_col = lid % 4;
            const int8_t* apb_g = Ap + (size_t)g * (size_t)Mp * K;
            const int8_t* bp_g  = Bp + (size_t)g * (size_t)N * K;
            int32_t* c_g = C32 + (size_t)g * (size_t)Mp * N;
            const int8_t* apb = apb_g + (size_t)(wg_row * kb_n) * 8 * 512;
            const int8_t* bp = bp_g + (size_t)wg_col * (BN / 8) * 256;
            auto load_a = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                esimd::simd<int8_t, 128> av = esimd::block_load<int8_t, 128>(
                    apb + (size_t)kb * SLM_A + lid * 128, esimd::overaligned_tag<16>{});
                esimd::slm_block_store(buf * SLM_A + lid * 128, av, esimd::overaligned_tag<16>{});
            };
            // B straight global -> GRF (the map the SLM loop fed: offB = kb*2048 +
            // wi_col*512 in the packed block; the packed block per kb = N*32 bytes
            // starting at bp + kb*N*32; wi_col = lid%4 owns the 512B fragment).
            esimd::simd<int8_t, 256> bres[4][2];
            #pragma unroll
            for (int kb = 0; kb < 4; ++kb) {
                if (kb < kb_n) {
                    const int8_t* bs_ = bp + (size_t)kb * N * 32 + wi_col * 512;
                    bres[kb][0] = esimd::block_load<int8_t, 256>(bs_ + 0, esimd::overaligned_tag<16>{});
                    bres[kb][1] = esimd::block_load<int8_t, 256>(bs_ + 256, esimd::overaligned_tag<16>{});
                }
            }
            esimd::simd<int8_t, 256> a0, a1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_a(0, 0);
            if (kb_n > 1) load_a(1, 1);
            esimd::barrier();
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_a((b + 2) % 3, b + 2);
                uint32_t offA = cur * SLM_A + wi_row * 512;
                a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, bres[b][0], a0);
                c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, bres[b][1], a0);
                c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, bres[b][0], a1);
                c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, bres[b][1], a1);
                esimd::barrier();
            }
            int gr = wg_row * BM + wi_row * 16, gc = wg_col * BN + wi_col * 16;
            for (int r = 0; r < 8; ++r) {
                esimd::simd<int32_t, 16> row0;
                row0.select<8, 1>(0) = c00.select<8, 1>(r * 8);
                row0.select<8, 1>(8) = c01.select<8, 1>(r * 8);
                esimd::simd<int32_t, 16> row1;
                row1.select<8, 1>(0) = c10.select<8, 1>(r * 8);
                row1.select<8, 1>(8) = c11.select<8, 1>(r * 8);
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + r) * N + gc, row0, esimd::overaligned_tag<16>{});
                esimd::block_store<int32_t, 16>(c_g + (size_t)(gr + 8 + r) * N + gc, row1, esimd::overaligned_tag<16>{});
            }
        });
    });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  auto tev=[&](std::function<event()> f)->double{
    double b=1e9;
    for(int i=0;i<11;++i){ event e=f(); e.wait();
      b=std::min(b,(double)(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>())/1e6);}
    return b;};
  struct Cfg{int M,N,K,b;};
  // the frame's K<=128 gemm family (census 18:0x): batched x6 + qkv's gemm (N=384)
  std::vector<Cfg> cfgs={{32640,128,64,2},{32640,32,128,2},{8160,128,128,4},{8160,32,128,4},
                         {2040,128,128,8},{130560,384,128,1},{8160,384,128,1}};
  for(auto cf:cfgs){
    int M=cf.M,N=cf.N,K=cf.K,b=cf.b;
    int Mp=((M+127)/128)*128;
    // A padded to Mp rows (zeros) -- the host pack_a reads the full Mp grid (the
    // device gather guards, the host twin does not; padding rows feed the tile map).
    std::vector<int8_t> A((size_t)b*Mp*K,0),B((size_t)b*N*K),Ap((size_t)b*Mp*K),Bp((size_t)b*N*K);
    std::mt19937 rng(5); std::uniform_int_distribution<int> da(-127,127);
    for(int gg=0;gg<b;++gg) for(int r=0;r<M;++r) for(int k=0;k<K;++k)
        A[(size_t)gg*Mp*K+(size_t)r*K+k]=(int8_t)da(rng);
    for(auto&x:B)x=(int8_t)da(rng);
    for(int gg=0;gg<b;++gg) s8v8::pack_a(A.data()+(size_t)gg*Mp*K, Ap.data()+(size_t)gg*Mp*K, Mp, K);
    for(int gg=0;gg<b;++gg) s8v8::pack_b(B.data()+(size_t)gg*N*K, Bp.data()+(size_t)gg*N*K, N, K);
    int8_t *dAp=(int8_t*)malloc_device(Ap.size(),q),*dBp=(int8_t*)malloc_device(Bp.size(),q);
    int32_t* dC1=(int32_t*)malloc_device((size_t)b*Mp*N*4,q);
    int32_t* dC2=(int32_t*)malloc_device((size_t)b*Mp*N*4,q);
    q.memcpy(dAp,Ap.data(),Ap.size()).wait(); q.memcpy(dBp,Bp.data(),Bp.size()).wait();
    q.memset(dC1,0,(size_t)b*Mp*N*4); q.memset(dC2,0x5A,(size_t)b*Mp*N*4); q.wait();
    size_t nout=(size_t)b*Mp*N;
    std::vector<int32_t> h1(nout);
    double base, alt=-1, alt2=-1; size_t d2=0, d3=0;
    if (N % 64 == 0) {
        base=tev([&]{ return s8v8::gemm_b(q,dAp,dBp,dC1,Mp,N,K,b); });
        q.memcpy(h1.data(),dC1,nout*4).wait();
        q.memset(dC2,0x5A,nout*4); q.wait();
        alt =tev([&]{ return gemm_b_resb(q,dAp,dBp,dC2,Mp,N,K,b); });
        { std::vector<int32_t> h2(nout); q.memcpy(h2.data(),dC2,nout*4).wait();
          for(size_t i=0;i<nout;++i) if(h1[i]!=h2[i]) d2++; }
        q.memset(dC2,0x5A,nout*4); q.wait();
        alt2=tev([&]{ return gemm_b_resb2(q,dAp,dBp,dC2,Mp,N,K,b); });
        { std::vector<int32_t> h3(nout); q.memcpy(h3.data(),dC2,nout*4).wait();
          for(size_t i=0;i<nout;++i) if(h1[i]!=h3[i]) d3++; }
        printf("M=%-7d N=%-4d K=%-4d b=%d  gemm=%8.4f | resb=%8.4f (%.2fx d=%zu) | resb2=%8.4f (%.2fx d=%zu)\n",
               M,N,K,b,base,alt,base/alt,d2,alt2,base/alt2,d3);
    } else {
        base=tev([&]{ return s8v8::gemm32_b(q,dAp,dBp,dC1,Mp,N,K,b); });
        printf("M=%-7d N=%-4d K=%-4d b=%d  gemm32=%8.4f (resb32 = next)\n", M,N,K,b,base);
    }
    free(dAp,q);free(dBp,q);free(dC1,q);free(dC2,q);
  }
  return 0;
}
