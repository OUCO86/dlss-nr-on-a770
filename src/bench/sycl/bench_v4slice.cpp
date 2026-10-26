// bench_v4slice.cpp -- section 100 P1 v4 FIRST CUT: the senior's stage DISCIPLINE on OUR
// operator (dpas tile8/store16 VERBATIM). Slice = P0 (gather) + P1 (QKV gemm) + P2
// (normalize+pack). What changes vs v3 (mechanism only):
//   * NO 24KB f32 DCQ slab: each subgroup OWNS one 16-row block (tr=sgid); its QKV
//     tiles compute into registers, spill to a 2KB PER-SUBGROUP scratch (the senior's
//     1KB kilobyte, f32 so 2KB here), and the SAME subgroup normalizes+packs those
//     rows -- rows never cross subgroups.
//   * barriers: ONE group barrier after AQO (P1 reads other subgroups' A rows), then
//     subgroup-local barriers inside the part loop (the senior's double-layer rule),
//     one final group barrier at the pack handoff. v3 pays 5 group barriers here.
//   * weights: stay GRF-loaded from the packed global (our pb16 packs are contiguous
//     128-half blocks -- the senior's "stage weights to SLM" lesson targeted coopmat's
//     strided row loads; our tile8s has no such striding. If the ladder later says B
//     loads dominate, THAT is when to SLM-stage them.)
// Judges: QPO/KTO/VPO RAW-REGION bytes vs v3 (stop=10/11/12) -- bit-exact or dead.
// Timing: best-of-7 event, same dump on both sides.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include "window_block_v3.hpp"
#include "window_block_mega.hpp"
#include "gemm_s8_v8_kernel.hpp"    // s8v8 (dependency of gemm_f16_v1_kernel.hpp)
#include "gemm_f16_v1_kernel.hpp"   // f16v1::pack_b (host-side weight pack for the bench)
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ---- the v4 slice kernel (P0+P1+P2 only) ----
// SLM map (bytes): AQO 0..4096 | QPO 4096..8192 | KTO 8192..12288 | VPO 12288..16384
//                 | SCR 16384..24576 (4 subgroups x 2KB: 16 rows x 32 f32)
// TOTAL 24KB -> 2 WG/EU (v3: 64KB -> 1).
static constexpr uint V4_AQO = 0, V4_QPO = 4096, V4_KTO = 8192, V4_VPO = 12288, V4_SCR = 16384;
static constexpr uint V4_SCR_SG = 2048;   // per-subgroup scratch bytes (16*32*4)

inline event launch_v4slice(queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, half* TgtDump,
    const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols)
{
    constexpr uint LW = 64u;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)windows*LW), range(LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<24576>();
            uint window = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint sgid = lid >> 4, lane = lid & 15u;

            // ===== P0: gather (VERBATIM v3 P0; pack map pa16 for A of scores) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3));
                int x = (int)((window % window_cols) * 8u + (t & 7u));
                uint tr=t>>4, strip=(t>>3)&1u, il=t&7u;
                uint base1 = ((tr*2u+0u)*2u+strip)*128u + il*16u;
                uint base2 = ((tr*2u+1u)*2u+strip)*128u + il*16u;
                esimd::simd<float,32> v;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    if (image_half) {
                        esimd::simd<half,32> hv((const half*)Img + at, esimd::overaligned_tag<16>{});
                        v = esimd::convert<float>(hv);
                    } else {
                        v = esimd::simd<float,32>((const float*)Img + at, esimd::overaligned_tag<16>{});
                    }
                } else v = esimd::simd<float,32>(0.0f);
                esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(v));
                wbv3::sh16(V4_AQO + base1*2u, oh.template select<16,1>(0).read());
                wbv3::sh16(V4_AQO + base2*2u, oh.template select<16,1>(16).read());
            }
            group_barrier(it.get_group());

            // ===== P1+P2 FUSED per row-block (the senior's structure) =====
            // this subgroup owns rows tr=sgid (16 rows). part Q: tc 0,1; K: 2,3; V: 4,5.
            for (uint part = 0; part < 3u; ++part) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8s(c00,c01,c10,c11, V4_AQO + sgid*1024u,
                             WqkvPacked + (size_t)(part*2u + 0u)*256u, 2, 6);
                // the second 16-col tile of this part
                esimd::simd<float,64> d00(0.f),d01(0.f),d10(0.f),d11(0.f);
                wbv3::tile8s(d00,d01,d10,d11, V4_AQO + sgid*1024u,
                             WqkvPacked + (size_t)(part*2u + 1u)*256u, 2, 6);
                // spill the 16x32 f32 block to THIS subgroup's scratch (store16s pattern)
                uint scr = V4_SCR + sgid*V4_SCR_SG;
                for (int r = 0; r < 8; ++r) {
                    esimd::slm_block_store(scr + (uint)r*32u*4u,
                        c00.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)r*32u*4u + 32u,
                        c01.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u,
                        c10.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u + 32u,
                        c11.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)r*32u*4u + 64u,
                        d00.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)r*32u*4u + 96u,
                        d01.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u + 64u,
                        d10.template select<8,1>(r*8));
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u + 96u,
                        d11.template select<8,1>(r*8));
                }
                esimd::barrier();               // SUBGROUP-local (the senior's rule)
                // each lane owns one row of the block: normalize + pack (VERBATIM v3 P2)
                uint r2 = lane;
                uint r  = sgid*16u + r2;        // global row in the window
                esimd::simd<float,32> hv = esimd::slm_block_load<float,32>(
                    scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                if (part == 2u) {               // V: raw e4m3 -> VPO (pb16 map, v3-identical)
                    esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(hv));
                    auto ov = oh.read();
                    for (uint c = 0; c < 32; ++c)
                        esimd::slm_block_store(V4_VPO + wbv3::pb16_dest_kn(r,c,4u,2u)*2u,
                                               esimd::simd<half,1>(ov[c]));
                } else {
                    esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(hv));
                    float recip = wbv3::cosine_recip_vec(hr);
                    if (part == 0u) {           // Q: * scale -> QPO (pa16 map)
                        float sc = wbmega::eh_round(QkvScale[0]);
                        esimd::simd<float,32> qv = wbv3::mulh(wbv3::mulh(hr, recip), sc);
                        esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(qv));
                        uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                        wbv3::sh16(V4_QPO + (((tr*2u+0u)*2u+strip)*128u + il*16u)*2u,
                                   oh.template select<16,1>(0).read());
                        wbv3::sh16(V4_QPO + (((tr*2u+1u)*2u+strip)*128u + il*16u)*2u,
                                   oh.template select<16,1>(16).read());
                    } else {                    // K: -> KTO (transposed map)
                        esimd::simd<float,32> kv = wbv3::mulh(hr, recip);
                        esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(kv));
                        auto ov = oh.read();
                        for (uint c = 0; c < 32; ++c)
                            esimd::slm_block_store(V4_KTO + wbv3::pb16t_dest(r,c,2u,4u)*2u,
                                                   esimd::simd<half,1>(ov[c]));
                    }
                }
                esimd::barrier();               // subgroup: scratch reusable next part
            }
            group_barrier(it.get_group());      // packs visible for the next stage (P3)

            // raw-region dump for the judge (same 2048-half stride as v3 stops 10-12)
            for (uint reg3 = 0; reg3 < 3u; ++reg3) {
                uint reg = (reg3==0u)?V4_QPO:(reg3==1u)?V4_KTO:V4_VPO;
                half* d = TgtDump + (size_t)reg3 * (size_t)windows * 4096u;
                for (uint i = 0; i < 2048u; i += 64u)
                    d[(size_t)window*4096u + i + lid] = wbv3::lh16(reg + (i + lid)*2u)[0];
            }
        });
    });
}

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  const unsigned windows=2040, image_h=544, image_w=960, window_cols=34;
  const unsigned C=32, NH=96;
  std::mt19937 rng(11);
  std::uniform_real_distribution<float> df(-6.f,6.f);
  // image f32
  std::vector<float> img((size_t)image_h*image_w*C);
  for(auto&x:img)x=df(rng);
  // raw QKV weights 32x96 half -> f16v1::pack_b (K=32? NO: logical B = C rows? v3 P1 consumes
  // the SAME WqkvPacked the recorder built: cached_pack_b_f16(qkv, Wraw, C, NH) = pack_b(K=C,N=NH)).
  std::vector<half> wraw((size_t)C*NH);
  for(auto&x:wraw)x=half(df(rng));
  std::vector<half> wpk((size_t)C*NH);
  f16v1::pack_b(wraw.data(),wpk.data(),(int)C,(int)NH);   // host pack (bench convenience)
  float qs[1]={0.125f};
  float* dImg=malloc_device<float>(img.size(),q);
  half* dW=malloc_device<half>(wpk.size(),q);
  float* dQs=malloc_device<float>(4,q);
  half* dRef=malloc_device<half>((size_t)3*windows*4096,q);   // v3 dumps (3 runs)
  half* dV4 =malloc_device<half>((size_t)3*windows*4096,q);
  q.memcpy(dImg,img.data(),img.size()*4).wait();
  q.memcpy(dW,wpk.data(),wpk.size()*2).wait();
  q.memcpy(dQs,qs,4).wait();
  q.memset(dRef,0,(size_t)3*windows*4096*2).wait();
  q.memset(dV4,0,(size_t)3*windows*4096*2).wait();
  auto timeit=[&](const char* nm, std::function<event()> fn){
    double best=1e9;
    for(int it=0;it<9;++it){ event e=fn(); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t0-s0)/1e6);}
    printf("%-14s %.4f ms/call  (%u windows)\n",nm,best,windows);
    return best;
  };
  // v3 reference: P0+P1+P2 with stop=10/11/12 (region dumps). Bias/Cos/Tgt dummies.
  float* dDummy=malloc_device<float>(64*64*4,q);
  q.memset(dDummy,0,(size_t)64*64*4).wait();
  double t3=0;
  for(unsigned st=10;st<=12u;++st)
    t3+=timeit("v3 slice", [&]{ return wbv3::launch_v3(q,dImg,false,dW,dW,
        (half*)dDummy,(float*)dDummy,dDummy,dDummy,dQs,
        windows,image_h,image_w,window_cols,0u,0u,0u,false,st,
        dRef + (st-10u)*(size_t)windows*4096); });   // distinct region per stop
  t3/=3.0;
  double t4=timeit("v4 slice", [&]{ return launch_v4slice(q,dImg,false,dW,dV4,dQs,
      windows,image_h,image_w,window_cols); });
  // judge: raw bytes of the three regions
  std::vector<half> ref((size_t)3*windows*4096), got((size_t)3*windows*4096);
  q.memcpy(ref.data(),dRef,ref.size()*2).wait();
  q.memcpy(got.data(),dV4,got.size()*2).wait();
  unsigned bad[3]={0,0,0};
  for(unsigned rg=0;rg<3u;++rg){
    const uint16_t* pr=reinterpret_cast<const uint16_t*>(ref.data())+rg*(size_t)windows*4096;
    const uint16_t* pg=reinterpret_cast<const uint16_t*>(got.data())+rg*(size_t)windows*4096;
    for(size_t i=0;i<(size_t)windows*4096;++i) if(pr[i]!=pg[i]) bad[rg]++;
  }
  printf("JUDGE raw-region mismatches: QPO=%u KTO=%u VPO=%u  (of %zu each) => %s\n",
    bad[0],bad[1],bad[2],(size_t)windows*4096,(bad[0]|bad[1]|bad[2])?"BAD":"EXACT");
  printf("time v3=%.4f v4=%.4f  ratio=%.2fx\n",t3,t4,t3/t4);
  return (bad[0]|bad[1]|bad[2])?1:0;
}
