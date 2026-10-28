// bench_stem_mega.cpp -- P8-n/B1 brick 1: the STEM MEGAKERNEL (design per the
// 16:57 review, Phase-2 SLM form). Today's stem = pack_a16 + gemm_dual_pub (pass A:
// dS 67MB + dH16 33MB global) + the chip (re-reads BOTH = the 3.4ms/call in-frame
// penalty, P8-n ledger). The mega keeps the 16x32 f32 tile + its e4m3 halves + the
// hidden stage in PER-THREAD SLM PRIVATE AREAS (ES 2KB + EA 1KB + HS 1KB = 4KB,
// LW=16 -> 64KB = the proven cap): global traffic = features 17MB in + Cout 67MB
// out ONLY. Bit-exact chain: phase-1 dpas VERBATIM = gemm() (dS identical) -> ES;
// EA = the pub_vec e4m3 of the SAME ES values (= dH16 identical, P8-m proven);
// phase-2 = the chip's c-loop VERBATIM (EA/HS/weights, same dpas order); the
// residual fma reads ES (== P8-l's dS read). ALL SLM offsets compile-time constants
// (the A-map lesson: never dynamic assembly).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <chrono>
#include <functional>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "ffn_chip_kernel.hpp"
#include "pack_device.hpp"
using namespace sycl;
using ffnc::stem_mega;
namespace esimd = sycl::ext::intel::esimd;


int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero &&
       d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  if(dev.get_backend()!=backend::ext_oneapi_level_zero){printf("no L0 Arc\n");return 1;}
  queue q(dev, property::queue::enable_profiling{});
  auto tm=[&](std::function<void()> f,int n)->double{
    f(); q.wait(); auto t0=std::chrono::steady_clock::now();
    for(int i=0;i<n;++i) f(); q.wait();
    return std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count()/n;};
  unsigned M=522240;  int Mp=(int)((M+15)/16*16);
  std::vector<half> feat((size_t)M*16), ad(16*32), ex(32*128), pr(128*32);
  std::vector<float> cp(32);
  std::mt19937 rng(7); std::uniform_real_distribution<float> df(-4.f,4.f);
  for(auto&x:feat)x=half(df(rng)); for(auto&x:ad)x=half(df(rng)*0.2f);
  for(auto&x:ex)x=half(df(rng)*0.2f); for(auto&x:pr)x=half(df(rng)*0.2f);
  for(auto&x:cp)x=df(rng)*0.1f;
  half *dF=malloc_device<half>(feat.size(),q), *dAd=malloc_device<half>(ad.size(),q),
       *dEx=malloc_device<half>(ex.size(),q), *dPr=malloc_device<half>(pr.size(),q);
  float* dcp=malloc_device<float>(32,q);
  q.memcpy(dF,feat.data(),feat.size()*2); q.memcpy(dAd,ad.data(),ad.size()*2);
  q.memcpy(dEx,ex.data(),ex.size()*2); q.memcpy(dPr,pr.data(),pr.size()*2);
  q.memcpy(dcp,cp.data(),128); q.wait();
  // packed operands:
  half* dAp=malloc_device<half>((size_t)Mp*16,q);           // pack_a16(M,16)
  half* dAdB=malloc_device<half>(ad.size(),q);              // pack_b16 adapter (16,32)
  half* dEp=malloc_device<half>(ex.size(),q);               // pack_b16 expand (32,128)
  half* dPp=malloc_device<half>(pr.size(),q);               // pack_b16 projection (128,32)
  packdev::pack_a16(q, dF, dAp, (int)M, Mp, 16);
  packdev::pack_b16(q, dAd, dAdB, 16, 32);
  packdev::pack_b16(q, dEx, dEp, 32, 128);
  packdev::pack_b16(q, dPr, dPp, 128, 32);
  // REFERENCE = the shipped 3-pass chain (pack already done above; dual + chip-fused-res):
  float* dS=malloc_device<float>((size_t)Mp*32,q);
  half* dH16=malloc_device<half>((size_t)M*32,q);
  float* outRef=malloc_device<float>((size_t)M*32,q);
  float* outMega=malloc_device<float>((size_t)M*32,q);
  q.memset(outMega,0,(size_t)M*32*4); q.wait();
  f16v1::gemm_dual_pub(q, dAp, dAdB, dS, dH16, (int)M, Mp, 32, 16).wait();
  ffnc::launch_ffn_chip<32>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp).wait();
  // MEGA:
  stem_mega(q, dAp, dAdB, dEp, dPp, dcp, outMega, (int)M, Mp).wait();
  std::vector<float> h1((size_t)M*32), h2((size_t)M*32);
  q.memcpy(h1.data(),outRef,h1.size()*4).wait(); q.memcpy(h2.data(),outMega,h2.size()*4).wait();
  size_t diff=0; for(size_t i=0;i<h1.size();++i) if(h1[i]!=h2[i]) diff++;
  printf("mega vs shipped-chain: diff=%zu / %zu  %s\n", diff, h1.size(), diff?"BAD":"EXACT");
  double t3=tm([&]{ f16v1::gemm_dual_pub(q, dAp, dAdB, dS, dH16, (int)M, Mp, 32, 16);
                    ffnc::launch_ffn_chip<32>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp); },15);
  double tM=tm([&]{ stem_mega(q, dAp, dAdB, dEp, dPp, dcp, outMega, (int)M, Mp); },15);
  double t3p=tm([&]{ packdev::pack_a16(q, dF, dAp, (int)M, Mp, 16);
                     f16v1::gemm_dual_pub(q, dAp, dAdB, dS, dH16, (int)M, Mp, 32, 16);
                     ffnc::launch_ffn_chip<32>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp); },15);
  double tMp=tm([&]{ packdev::pack_a16(q, dF, dAp, (int)M, Mp, 16);
                     stem_mega(q, dAp, dAdB, dEp, dPp, dcp, outMega, (int)M, Mp); },15);
  printf("M=%u: chain %8.4f | mega %8.4f | delta %+.3f\n", M, t3, tM, t3-tM);
  printf("M=%u WITH pack: chain %8.4f | mega %8.4f | delta %+.3f\n", M, t3p, tMp, t3p-tMp);
  // P8-o: the chip's OWN LW ladder (the occupancy hypothesis for the frame-vs-
  // isolated gap): LW=32 (64KB, 1 WG/SM, shipped) vs LW=16 (32KB, 2 WG/SM).
  double tL16=tm([&]{ ffnc::launch_ffn_chip<16>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp); },15);
  ffnc::launch_ffn_chip<16>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp).wait();
  q.memcpy(h1.data(),outRef,h1.size()*4).wait();
  size_t diffL=0; { std::vector<float> h3(h1.size()); q.memcpy(h3.data(),outMega,h3.size()*4).wait();
    for(size_t i=0;i<h1.size();++i) if(h1[i]!=h3[i]) diffL++; }
  printf("chip LW=16: %8.4f ms (vs LW32 chain-chip part; diff vs mega out %zu)\n", tL16, diffL);
  // P8-o clock test: the SUSTAINED-LOAD hypothesis for the chain's in-frame
  // marginal (4.5ms/call) vs isolated (1.83): short bursts run at boost, the
  // frame is 115ms of continuous GPU work. Time the chain in EARLY reps vs
  // LATE reps of a long sustained loop.
  auto tmwin=[&](int a,int b){ // time reps [a,b) of the chain
    double tot=0; int n=b-a;
    for(int i=0;i<b;++i){
      auto t0=std::chrono::steady_clock::now();
      f16v1::gemm_dual_pub(q, dAp, dAdB, dS, dH16, (int)M, Mp, 32, 16);
      ffnc::launch_ffn_chip<32>(q, dH16, dEp, dPp, outRef, (int)M, Mp, dS, dcp);
      q.wait();
      double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
      if(i>=a) tot+=ms;
    }
    return tot/n; };
  tmwin(0,20);   // warm the loop (first 20 discarded into measurement below as "early")
  double early=tmwin(20,60), mid=tmwin(150,190), late=tmwin(400,440), vlate=tmwin(900,940);
  printf("sustained chain: early(20-60)=%.3f mid(150-190)=%.3f late(400-440)=%.3f vlate(900-940)=%.3f ms\n", early, mid, late, vlate);
  return 0;
}
