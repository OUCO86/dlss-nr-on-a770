// bench_qsplit.cpp -- the ROWSPLIT quantize (senior quantize_row.comp LAYOUT idea,
// ESIMD form): the 59us/quant vs his 8.5us gap is PARALLELISM, not arithmetic --
// he splits every row across lanes (each reads whole 16B words, row max in a
// 4-lane shuffle, no barriers) and packs short rows several-to-a-warp. Our
// rowthread holds a row in ONE thread: at M=640 the grid is 640 threads (the
// A770 wants 100K+); at K=64 each thread chains 128B of sequential lane reads.
// THE FORM: LW=64 threads/WG, LPR = K/16 threads own one row (each reads exactly
// 16 halfs = 32B, one instruction), partial max -> 4B SLM, ONE barrier, read
// back the LPR partials (<=256B), hmax, quantize 16, store 16B. float max is
// associative/commutative (the rowgroup precedent) = bit-identical to rowthread's
// in-register hmax; scale/div/rnde/clip text VERBATIM. Frame shapes priced
// against the CURRENT dispatch (rowthread K<=512 / rowgroup K>512).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include <algorithm>
#include <functional>
#include <chrono>
using namespace sycl;

template <int LPR>   // lanes per row; each lane 16 halfs; WG=64 threads
inline auto qr_split(sycl::half* a_src, sycl::uint2* packed, float* scales, unsigned m) {
    return [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        esimd::slm_init<256>();
        constexpr unsigned K = LPR * 16u;
        constexpr unsigned RPW = 64u / LPR;          // rows per workgroup
        // NO early return before esimd::barrier (the old HANG lesson: a
        // workgroup-partial exit desyncs the barrier -> stale SLM reads).
        // Clamp instead: tail threads do redundant work on the last valid row,
        // every lane reaches the barrier, and the STORE is gated by row<m.
        unsigned row = (unsigned)it.get_group(0) * RPW + (unsigned)it.get_local_id(0) / LPR;
        unsigned lane = (unsigned)it.get_local_id(0) % LPR;
        const bool live = row < m;
        if (!live) row = m - 1u;
        const size_t base = (size_t)row * K;
        esimd::simd<float,16> reg = esimd::convert<float>(
            esimd::block_load<sycl::half,16>(a_src + base + lane*16u, esimd::overaligned_tag<16>{}));
        float part = esimd::hmax<float,float,16>(esimd::abs(reg));
        esimd::slm_block_store((uint)it.get_local_id(0)*4u, esimd::simd<float,1>(part), esimd::overaligned_tag<16>{});
        esimd::barrier();
        // read back THIS row's LPR partials only. (The old fixed-width 16-float
        // read ran past the 256B SLM for LPR=4/8 at high q0 -> UB.) LPR is a
        // power of two in {4,8,16}; byte offset q0*4 stays 16B-aligned.
        unsigned q0 = (unsigned)(it.get_local_id(0)/LPR)*LPR;   // this row's first partial
        esimd::simd<float,LPR> all = esimd::slm_block_load<float,LPR>(q0*4u, esimd::overaligned_tag<16>{});
        float peak = esimd::hmax<float,float,LPR>(all);
        const float scale = (peak == 0.0f) ? 1.0f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
        if (live && lane == 0u) scales[row] = scale;
        esimd::simd<float,16> q = esimd::div_ieee<float,16>(reg, esimd::simd<float,16>(scale));
        q = esimd::min(esimd::max(esimd::rnde<float,16>(q), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
        if (live) esimd::block_store<int8_t,16>((int8_t*)packed + base + lane*16u,
            esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
    };
}
// LPR=32/64 variant for K=512/1024: two 16-float SLM bands summed via hmax of the pair.
template <int LPR>
inline auto qr_split2(sycl::half* a_src, sycl::uint2* packed, float* scales, unsigned m) {
    return [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        esimd::slm_init<256>();
        constexpr unsigned K = LPR * 16u;
        unsigned row = (unsigned)it.get_group(0);
        unsigned lane = (unsigned)it.get_local_id(0);
        const size_t base = (size_t)row * K;
        esimd::simd<float,16> reg = esimd::convert<float>(
            esimd::block_load<sycl::half,16>(a_src + base + lane*16u, esimd::overaligned_tag<16>{}));
        float part = esimd::hmax<float,float,16>(esimd::abs(reg));
        esimd::slm_block_store(lane*4u, esimd::simd<float,1>(part), esimd::overaligned_tag<16>{});
        esimd::barrier();
        esimd::simd<float,16> a0 = esimd::slm_block_load<float,16>(0u, esimd::overaligned_tag<16>{});
        esimd::simd<float,16> a1 = esimd::slm_block_load<float,16>(64u, esimd::overaligned_tag<16>{});
        esimd::simd<float,16> m01 = esimd::max(a0,a1);
        float peak;
        if constexpr (LPR==32) peak = esimd::hmax<float,float,16>(m01);
        else { esimd::simd<float,16> a2 = esimd::slm_block_load<float,16>(128u, esimd::overaligned_tag<16>{});
               esimd::simd<float,16> a3 = esimd::slm_block_load<float,16>(192u, esimd::overaligned_tag<16>{});
               peak = esimd::hmax<float,float,16>(esimd::max(m01, esimd::max(a2,a3))); }
        const float scale = (peak == 0.0f) ? 1.0f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
        if (lane == 0u) scales[row] = scale;
        esimd::simd<float,16> q = esimd::div_ieee<float,16>(reg, esimd::simd<float,16>(scale));
        q = esimd::min(esimd::max(esimd::rnde<float,16>(q), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
        esimd::block_store<int8_t,16>((int8_t*)packed + base + lane*16u,
            esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
    };
}
// Generalized NCH-chunk rowsplit: LPR lanes/row, each holds NCH x simd<half,16>
// (K = LPR*16*NCH). Prices K=1024 (LPR=64,NCH=1 -- same footprint as rowgroup
// but 2 rows/WG) and K=2048 (LPR=32,NCH=2 -> 16 GRF halfs*2 vs rowgroup's 32x2).
template <int LPR, int NCH>
inline auto qr_splitN(sycl::half* a_src, sycl::uint2* packed, float* scales, unsigned m) {
    return [=](sycl::nd_item<1> it) SYCL_ESIMD_KERNEL {
        namespace esimd = sycl::ext::intel::esimd;
        constexpr unsigned K = LPR * 16u * NCH;
        esimd::slm_init<256>();   // one 4B partial per thread, 64 threads/WG
        constexpr unsigned RPW = 64u / LPR;
        unsigned row = (unsigned)it.get_group(0) * RPW + (unsigned)it.get_local_id(0) / LPR;
        unsigned lane = (unsigned)it.get_local_id(0) % LPR;
        const bool live = row < m;
        if (!live) row = m - 1u;
        const size_t base = (size_t)row * K;
        esimd::simd<sycl::half,16> reg[NCH];
        esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
        #pragma unroll
        for (int c = 0; c < NCH; ++c) {
            reg[c] = esimd::block_load<sycl::half,16>(a_src + base + (size_t)(c*LPR + lane)*16u,
                                                      esimd::overaligned_tag<16>{});
            mx = esimd::max(mx, esimd::abs(esimd::convert<float>(reg[c])));
        }
        esimd::slm_block_store((uint)it.get_local_id(0)*4u,
            esimd::simd<float,1>(esimd::hmax<float,float,16>(mx)), esimd::overaligned_tag<16>{});
        esimd::barrier();
        unsigned q0 = (unsigned)(it.get_local_id(0)/LPR)*LPR;
        esimd::simd<float,LPR> all = esimd::slm_block_load<float,LPR>(q0*4u, esimd::overaligned_tag<16>{});
        float peak = esimd::hmax<float,float,LPR>(all);
        const float scale = (peak == 0.0f) ? 1.0f
            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
        if (live && lane == 0u) scales[row] = scale;
        #pragma unroll
        for (int c = 0; c < NCH; ++c) {
            esimd::simd<float,16> q = esimd::div_ieee<float,16>(esimd::convert<float>(reg[c]), esimd::simd<float,16>(scale));
            q = esimd::min(esimd::max(esimd::rnde<float,16>(q), esimd::simd<float,16>(-127.f)), esimd::simd<float,16>(127.f));
            if (live) esimd::block_store<int8_t,16>((int8_t*)packed + base + (size_t)(c*LPR + lane)*16u,
                esimd::convert<int8_t>(esimd::convert<int>(q)), esimd::overaligned_tag<16>{});
        }
    };
}
#include "quantize_row_kernel.hpp"

int main(){
  try {
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev, property::queue::enable_profiling{});
  struct S{unsigned m,k;}; S ss_all[]={{640,2048},{2040,256},{8160,512},{8160,128},{32640,64},{32640,256},{192,1024}};
  // QS_ONLY=m,k to bisect a DEVICE_LOST to one shape
  std::vector<S> ss;
  for (auto&s : ss_all) {
    const char* only = getenv("QS_ONLY");
    if (!only) { ss.push_back(s); continue; }
    unsigned om, ok; if (sscanf(only, "%u,%u", &om, &ok)==2 && om==s.m && ok==s.k) ss.push_back(s);
  }
  // GPU-side event timing (command_start..command_end): submit latency and the
  // CPU submit floor are EXCLUDED on both sides -- that floor (~50-70us/launch
  // wall) dominated the naive wall loops and hid the real kernel delta.
  auto t11=[&](std::function<event()>f){double b=1e9;
    for(int i=0;i<15;++i){event e=f();e.wait();
      b=std::min(b,(double)(e.get_profiling_info<info::event_profiling::command_end>()-e.get_profiling_info<info::event_profiling::command_start>())/1e6);}
    return b;};
  for(auto&MK:ss){
    size_t n=(size_t)MK.m*MK.k;
    std::vector<half> hs(n); std::mt19937 rng(3); std::uniform_real_distribution<float> df(-8.f,8.f);
    for(auto&x:hs)x=half(df(rng));
    half* src=malloc_device<half>(n,q);
    uint2* p1=malloc_device<uint2>(n,q); uint2* p2=malloc_device<uint2>(n,q);
    float* s1=malloc_device<float>(MK.m,q); float* s2=malloc_device<float>(MK.m,q);
    // poison p2/s2: unwritten regions must show as diffs, not accidental matches.
    // NOTE the host vectors MUST outlive q.wait() (queue::memcpy keeps using the
    // host pointer until the copy completes — a scoped temp is a dangling DMA).
    std::vector<uint8_t> pz(n, 0xAA);
    std::vector<float> sz(MK.m, -12345.f);
    q.memcpy(src,hs.data(),n*2);
    q.memcpy(p2, pz.data(), n);
    q.memcpy(s2, sz.data(), MK.m*4);
    q.wait();
    double oldb=t11([&]{ event e; qr_launch_esimd(q,dev,src,p1,s1,MK.m,MK.k,&e); return e; });
    double nw=1e9;
    // grid = ceil(m / RPW) groups, RPW = 64/LPR rows per WG. (The old LPR=16 line
    // used m/16+1 groups = only m/4 rows covered -> 3/4 of the output never written.)
    auto ngroups = [&](unsigned LPRv){ unsigned RPW = 64u/LPRv; return (size_t)((MK.m + RPW - 1u)/RPW); };
    unsigned LPR = MK.k/16u;
    const bool noalt = getenv("QS_NOALT") != nullptr;   // bisect: current+diff only
    if (noalt) nw = 0.0;
    if (!noalt && LPR==4)  nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range(ngroups(4)*64u),range(64u)),qr_split<4>(src,p2,s2,MK.m));}); });
    if (LPR==8)  nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range(ngroups(8)*64u),range(64u)),qr_split<8>(src,p2,s2,MK.m));}); });
    if (LPR==16) nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range(ngroups(16)*64u),range(64u)),qr_split<16>(src,p2,s2,MK.m));}); });
    if (LPR==32) nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range((size_t)MK.m*32u),range(32u)),qr_split2<32>(src,p2,s2,MK.m));}); });
    if (LPR==64) nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range((size_t)MK.m*64u),range(64u)),qr_split2<64>(src,p2,s2,MK.m));}); });
    if (LPR==128) nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range((size_t)MK.m*64u),range(64u)),qr_splitN<64,2>(src,p2,s2,MK.m));}); });
    if (LPR==256) nw=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range((size_t)MK.m*64u),range(64u)),qr_splitN<64,4>(src,p2,s2,MK.m));}); });
    std::vector<int8_t> h1(n),h2(n); q.memcpy(h1.data(),p1,n).wait(); q.memcpy(h2.data(),p2,n).wait();
    std::vector<float> g1(MK.m),g2(MK.m); q.memcpy(g1.data(),s1,MK.m*4).wait(); q.memcpy(g2.data(),s2,MK.m*4).wait();
    size_t d=0; for(size_t i=0;i<n;++i) if(h1[i]!=h2[i])++d;
    size_t sd=0; for(unsigned i=0;i<MK.m;++i) if(memcmp(&g1[i],&g2[i],4))++sd;
    double gbs=(double)(n*3)/nw/1e6;
    printf("M=%-6u K=%-5u current %8.4f | split %8.4f (%.2fx, %.0f GB/s) | diff %zu/%zu %s\n",
        MK.m,MK.k,oldb,nw,oldb/nw,gbs,d,sd,(d||sd)?"NOT-EXACT":"EXACT");
    // alt shape for K=1024: splitN<64,1> vs the split2/rowgroup forms (own buffer)
    if (LPR==64) {
        uint2* p3=malloc_device<uint2>(n,q);
        float* s3=malloc_device<float>(MK.m,q);
        double v=t11([&]{ return q.submit([&](handler&h){h.parallel_for(nd_range(range((size_t)MK.m*64u),range(64u)),qr_splitN<64,1>(src,p3,s3,MK.m));}); });
        std::vector<int8_t> h3(n); q.memcpy(h3.data(),p3,n).wait();
        size_t d3=0; for(size_t i=0;i<n;++i) if(h1[i]!=h3[i])++d3;
        printf("   alt qr_splitN<64,1> %8.4f (%.2fx vs current) diff %zu\n", v, oldb/v, d3);
        free(p3,q); free(s3,q);
    }
  }
  }
  catch (const std::exception& e){ printf("EXC: %s\n", e.what()); return 1; }
  return 0;
}
