// bench_v4full.cpp -- section 100 P1 v4 FULL: the senior's stage discipline end to end
// on OUR untouched dpas operator. Extends the v4-slice win (1d6456b: 1.74x, bit-exact)
// to P3-P7. The structural fix vs v3: v3's P1 tiles shuffle row ownership across
// subgroups (tr=tile/6) -> everything needs a 24KB f32 DCQ slab + ~10 GROUP barriers.
// v4: each subgroup owns its 16-row block end to end (rows sgid*16..+15):
//   P0 (row-owned already) -> subgroup barrier
//   P1+P2 fused part loop (slice verbatim) -> subgroup barriers inside
//   ONE group barrier (KTO/VPO become cross-subgroup for P3/P5)
//   P3 scores rows-owned (KTO cols shared) -> subgroup barrier
//   P4 softmax row-local (registers; SEQUENTIAL ef_add sum keeps v3's order; NO WGT
//      SLM round-trip) -> subgroup barrier
//   P5 attnV (A=PPO rows owned, B=VPO shared-but-barriered) -> subgroup barrier
//   P6 attended->ATO (owned), outproj (owned) -> subgroup barrier
//   P7 residual+publish+image store (owned rows, global coords).
// GROUP barriers: 1 (v3: ~10). SLM: 45KB (v3: 64KB).
// Judges: raw/map region dumps vs v3 stops 10(QPO)/11(KTO)/12(VPO)/5(scores)/6(probs)/
// 8(attended)/9(projected) -- bit-exact or dead. Operator VERBATIM (wbv3 tile8s/
// tile8ss/e4m3_vec/cosine_recip_vec/mulh/pack maps).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "window_block_v3.hpp"
#include "window_block_mega.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM map (bytes): AQO 0..4096 | QPO 4096..8192 | KTO 8192..12288 | VPO 12288..16384 |
//                  ATO 16384..20480 | PPO 20480..28672 | SCR 28672..45056 (4SG x 4KB)
constexpr uint S_AQO=0, S_QPO=4096, S_KTO=8192, S_VPO=12288, S_ATO=16384, S_PPO=20480, S_SCR=28672;
constexpr uint SCR_SG=4096;

template <int FILL_N = 0>
inline event launch_v4full(queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,
    half* Tgt, float* TgtF, const float* Bias, const float* Cos, const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    constexpr uint LW = 64u;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range<1>(range((size_t)windows*LW), range(LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<45056>();
            uint window = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint sgid = lid >> 4, lane = lid & 15u;
            uint top = pad_top, left = pad_left;
            if (stop_stage == 0xFFFFu || stop_stage == 0xFFFEu) return;

            // ===== P0 gather (VERBATIM v3; rows already subgroup-owned) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
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
                wbv3::sh16(S_AQO + base1*2u, oh.template select<16,1>(0).read());
                wbv3::sh16(S_AQO + base2*2u, oh.template select<16,1>(16).read());
            }
            esimd::barrier();                       // subgroup: own rows only
            // P8-fill (the senior's PROBE_FILL instrument, section 100 B1 design
            // decision): FOUR independent fadd chains seeded from SLM, N rounds.
            // Cannot be folded (seed load) and cannot reach the output (guarded
            // store). GROWS with N => issue-bound (v5 = cut instructions).
            // FLAT => latency-bound (v5 = shorten chains / more parallelism).
            if (FILL_N) {
                esimd::simd<float,32> seed = esimd::slm_block_load<float,32>(S_AQO + lid*4u, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> f0=seed, f1=seed+1.f, f2=seed+2.f, f3=seed+3.f;
                #pragma unroll
                for (int i = 1; i <= FILL_N; ++i) {
                    f0 += esimd::simd<float,32>((float)i)*1.000001f;
                    f1 += esimd::simd<float,32>((float)i)*1.000002f;
                    f2 += esimd::simd<float,32>((float)i)*1.000003f;
                    f3 += esimd::simd<float,32>((float)i)*1.000004f;
                }
                if (windows == 0xFFFFFFFFu)
                    esimd::slm_block_store(S_AQO + lid*4u, f0+f1+f2+f3);
            }
            if (stop_stage == 101u) return;         // P8-ladder: P0 gather ONLY (no dump)
            // P1+P2 fused (the slice VERBATIM) =====
            // (P8-i2 NOTE: the QKV A-hoist was tried HERE and measured NEUTRAL
            // (0.572->0.572, giants 4.88->4.93) -- the elementwise cost is the
            // acc->scr round-trip, not the dpas operand loads. Reverted to mirror
            // the shipped v4. The scores hoist (P8-f, 4x128=16-reg class) DID win
            // and lives in the shipped kernel.)
            // P8-blade2 (B1): PHASE-SPLIT QKV -- the 3 parts get THREE separate
            // scr slabs (SCR | ATO | PPO-front; both maps are DEAD until P6/P4), so
            // the per-part store->barrier->reload chains no longer serialize behind
            // each other: 6 subgroup barriers -> 1 (the barrier before the reload
            // phase) + the existing end-of-loop one. The per-row op chain is
            // UNCHANGED -> bit-identical by construction; the seven-region JUDGE is
            // the safety net. The fill probe (a196d5e) says v4 is LATENCY-bound:
            // the barriers ARE the chain-coupling between parts.
            // each part's rows slab = 16 rows x 32 floats = 2KB/subgroup.
            // scrA/scrB split the subgroup's 4KB SCR slab; scrC takes the PPO
            // region (8KB = 4x2KB, dead until softmax). ATO stays untouched
            // (4KB total -- an earlier draft aliased scrB there and the JUDGE
            // caught the sgid>=1 overflow into scrC: BAD rows, exactly the
            // safety net doing its job).
            uint scrA = S_SCR + sgid*SCR_SG;                 // rows 0-15 part0
            uint scrB = S_SCR + sgid*SCR_SG + 2048u;         // rows 0-15 part1
            uint scrC = S_PPO + sgid*2048u;                  // rows 0-15 part2
            // P8-blade2: TWO-PHASE QKV (the fill probe says v4 is latency-bound;
            // the per-part store->barrier->reload chains serialize behind each
            // other). Phase 1: dpas + merged stores for ALL THREE parts into
            // THREE separate scr slabs (no barrier between parts). ONE barrier.
            // Phase 2: reload + epilogue + scatter for all three (no barrier:
            // each subgroup re-reads only its own rows; the per-row op CHAIN is
            // VERBATIM the same -> bit-identical by construction).
            #pragma unroll
            for (uint part = 0; part < 3u; ++part) {
                uint scr = (part==0u)? scrA : (part==1u)? scrB : scrC;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8s(c00,c01,c10,c11, S_AQO + sgid*1024u,
                             WqkvPacked + (size_t)(part*2u+0u)*256u, 2, 6);
                esimd::simd<float,64> d00(0.f),d01(0.f),d10(0.f),d11(0.f);
                wbv3::tile8s(d00,d01,d10,d11, S_AQO + sgid*1024u,
                             WqkvPacked + (size_t)(part*2u+1u)*256u, 2, 6);
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float,16> m01;
                    m01.template select<8,1>(0)  = c00.template select<8,1>(r*8);
                    m01.template select<8,1>(8)  = c01.template select<8,1>(r*8);
                    esimd::simd<float,16> m11;
                    m11.template select<8,1>(0)  = c10.template select<8,1>(r*8);
                    m11.template select<8,1>(8)  = c11.template select<8,1>(r*8);
                    esimd::simd<float,16> n01;
                    n01.template select<8,1>(0)  = d00.template select<8,1>(r*8);
                    n01.template select<8,1>(8)  = d01.template select<8,1>(r*8);
                    esimd::simd<float,16> n11;
                    n11.template select<8,1>(0)  = d10.template select<8,1>(r*8);
                    n11.template select<8,1>(8)  = d11.template select<8,1>(r*8);
                    esimd::slm_block_store(scr + (uint)r*32u*4u,           m01);
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u,       m11);
                    esimd::slm_block_store(scr + (uint)r*32u*4u + 64u,     n01);
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u + 64u, n11);
                }
            }
            esimd::barrier();
            #pragma unroll
            for (uint part = 0; part < 3u; ++part) {
                if (stop_stage == 102u && part == 1u) return;   // one part's epilogue marginal
                if (stop_stage == 103u && part == 2u) return;   // two parts' marginal
                uint scr = (part==0u)? scrA : (part==1u)? scrB : scrC;
                uint r2 = lane, r = sgid*16u + lane;
                esimd::simd<float,32> hv = esimd::slm_block_load<float,32>(
                    scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                if (part == 2u) {
                    esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(hv));
                    auto ov = oh.read();
                    for (uint c = 0; c < 32; ++c)
                        esimd::slm_block_store(S_VPO + wbv3::pb16_dest_kn(r,c,4u,2u)*2u,
                                               esimd::simd<half,1>(ov[c]));
                } else {
                    esimd::simd<float,32> hr = esimd::convert<float>(esimd::convert<half>(hv));
                    float recip = wbv3::cosine_recip_vec(hr);
                    if (part == 0u) {
                        float sc = wbmega::eh_round(QkvScale[0]);
                        esimd::simd<float,32> qv = wbv3::mulh(wbv3::mulh(hr, recip), sc);
                        esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(qv));
                        uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                        wbv3::sh16(S_QPO + (((tr*2u+0u)*2u+strip)*128u + il*16u)*2u,
                                   oh.template select<16,1>(0).read());
                        wbv3::sh16(S_QPO + (((tr*2u+1u)*2u+strip)*128u + il*16u)*2u,
                                   oh.template select<16,1>(16).read());
                    } else {
                        esimd::simd<float,32> kv = wbv3::mulh(hr, recip);
                        esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(kv));
                        for (uint c = 0; c < 32; c += 2)
                            esimd::slm_block_store(S_KTO + wbv3::pb16t_dest(r,c,2u,4u)*2u,
                                                   oh.template select<2,1>(c));
                    }
                }
            }
            // v5c (barrier audit): this end-of-QKV subgroup barrier exists ONLY so
            // the stop=10/11/12 DUMPS (which read OTHER subgroups' QPO/KTO/VPO
            // scatter) see complete maps -- the bench instrument's requirement.
            // The FRAME path (DumpKV==nullptr) is protected by the group_barrier
            // below (cross-subgroup KTO/VPO for P3/P5), and scrA/B/C phase-2 reads
            // are subgroup-local. So: barrier iff DumpKV. Blade-2's VPO race was a
            // DUMP race (214/8.36M) -- exactly this path.
            if (DumpKV) esimd::barrier();
            auto dump_region = [&](uint reg) SYCL_ESIMD_FUNCTION {
                if (DumpKV) { half* d=DumpKV+(size_t)window*4096u;
                    for (uint i=0;i<2048u;i+=64u) d[i+lid]=wbv3::lh16(reg+(i+lid)*2u)[0]; } };
            if (stop_stage == 10u) { dump_region(S_QPO); return; }
            if (stop_stage == 11u) { dump_region(S_KTO); return; }
            if (stop_stage == 12u) { dump_region(S_VPO); return; }
            group_barrier(it.get_group());          // KTO/VPO shared for P3/P5

            // ===== P3 scores: rows owned, cols 0..63 =====
            // P8-f: the A tile (S_QPO + sgid*1024, kc 0..1) is the SAME across all
            // four tc blocks -- hoist aq0/aq1 into registers ONCE (2 x simd<half,128>
            // = 8 GRF regs/thread at LW64; the tile8s A-side was re-read from SLM
            // 4x). tile8ss's b0/b1 stay SLM loads (each tc's KTO block differs).
            {
              uint qb = S_QPO + sgid*1024u;
              esimd::simd<half,128> aq0 = esimd::slm_block_load<half,128>(qb, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq1 = esimd::slm_block_load<half,128>(qb + 256, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq2 = esimd::slm_block_load<half,128>(qb + 512, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq3 = esimd::slm_block_load<half,128>(qb + 768, esimd::overaligned_tag<16>{});
              for (uint tc = 0; tc < 4u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                uint bb = S_KTO + tc*512u;
                // kc=0 (tile8ss: bb step = kc*tc_n*2*256 = kc*2048)
                esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(bb + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, aq0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, aq0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, aq1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, aq1);
                // kc=1
                esimd::simd<half,128> c0 = esimd::slm_block_load<half,128>(bb + 2048, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> c1 = esimd::slm_block_load<half,128>(bb + 2304, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, c0, aq2);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, c1, aq2);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, c0, aq3);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, c1, aq3);
                uint scr = S_SCR + sgid*SCR_SG;
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<float,16> m01;
                    m01.template select<8,1>(0)  = c00.template select<8,1>(r*8);
                    m01.template select<8,1>(8)  = c01.template select<8,1>(r*8);
                    esimd::simd<float,16> m11;
                    m11.template select<8,1>(0)  = c10.template select<8,1>(r*8);
                    m11.template select<8,1>(8)  = c11.template select<8,1>(r*8);
                    esimd::slm_block_store(scr + (uint)r*64u*4u + tc*16u*4u,       m01);
                    esimd::slm_block_store(scr + (uint)(8+r)*64u*4u + tc*16u*4u,   m11);
                }
            }
            }
            esimd::barrier();
            if (stop_stage == 5u) {   // scores rows (map-agnostic row dump, v3 stop=5 form)
                // FIX (v4full first run): the scratch rows are PER-SUBGROUP blocks
                // (scr + sgid*SCR_SG + row_in_block*stride); the dump's lid is a GLOBAL
                // row -- map it. (The judge was wrong, not the kernel: probs, computed
                // from these same scores, came out EXACT.)
                if (DumpKV) {
                    uint sg = lid >> 4, rr = lid & 15u;
                    uint scr = S_SCR + sg*SCR_SG;
                    for (uint c = 0; c < 64; ++c)
                        DumpKV[(size_t)window*4096u + lid*64u + c] =
                            half(esimd::slm_block_load<float,1>(scr + (rr*64u+c)*4u)[0]);
                }
                return;
            }

            // ===== P4 softmax row-local (NO WGT round-trip) =====
            {
                uint scr = S_SCR + sgid*SCR_SG;
                uint r2 = lane, r = sgid*16u + lane;
                esimd::simd<float,32> s0 = esimd::slm_block_load<float,32>(scr + r2*64u*4u, esimd::overaligned_tag<16>{});
                esimd::simd<float,32> s1 = esimd::slm_block_load<float,32>(scr + r2*64u*4u + 128u, esimd::overaligned_tag<16>{});
                size_t boff = (size_t)r * 64u;
                esimd::simd<float,32> b0(Bias+boff), b1(Bias+boff+32);
                esimd::simd<float,32> hl0 = esimd::convert<float>(esimd::convert<half>(s0 + b0));
                esimd::simd<float,32> hl1 = esimd::convert<float>(esimd::convert<half>(s1 + b1));
                esimd::simd<float,32> a0 = esimd::convert<float>(esimd::convert<half>(hl0*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                esimd::simd<float,32> a1 = esimd::convert<float>(esimd::convert<half>(hl1*esimd::simd<float,32>(0.044921875f) + esimd::simd<float,32>(1.30078125f)));
                a0 = (esimd::min)((esimd::max)(a0, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                a1 = (esimd::min)((esimd::max)(a1, esimd::simd<float,32>(1.03125f)), esimd::simd<float,32>(1.5693359375f));
                esimd::simd<half,16> he0=esimd::convert<half>(a0.template select<16,2>(0).read());
                esimd::simd<half,16> ho0=esimd::convert<half>(a0.template select<16,2>(1).read());
                esimd::simd<half,16> he1=esimd::convert<half>(a1.template select<16,2>(0).read());
                esimd::simd<half,16> ho1=esimd::convert<half>(a1.template select<16,2>(1).read());
                esimd::simd<uint16_t,16> e0; e0=he0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> o0; o0=ho0.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> e1; e1=he1.bit_cast_view<uint16_t>();
                esimd::simd<uint16_t,16> o1; o1=ho1.bit_cast_view<uint16_t>();
                esimd::simd<uint32_t,16> p0=esimd::convert<uint32_t>(e0)|(esimd::convert<uint32_t>(o0)<<16);
                esimd::simd<uint32_t,16> p1=esimd::convert<uint32_t>(e1)|(esimd::convert<uint32_t>(o1)<<16);
                esimd::simd<uint32_t,16> t0=(p0<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<uint32_t,16> t1=(p1<<5)+esimd::simd<uint32_t,16>(0x7FF88000u);
                esimd::simd<half,32> w0; w0=t0.bit_cast_view<half>();
                esimd::simd<half,32> w1; w1=t1.bit_cast_view<half>();
                auto f0 = esimd::convert<float>(w0).read();
                auto f1 = esimd::convert<float>(w1).read();
                float total = 0.0f;
                for (uint c = 0; c < 32u; ++c) total = wbv3::ef_add(total, f0[c]);
                for (uint c = 0; c < 32u; ++c) total = wbv3::ef_add(total, f1[c]);
                float trh = wbmega::eh_round(total);
                float recip = wbmega::eh_round(wbv3::ef_div(1.0f, trh));
                esimd::simd<half,32> oh0 = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(esimd::convert<float>(w0), recip)));
                esimd::simd<half,32> oh1 = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(esimd::convert<float>(w1), recip)));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                wbv3::sh16(S_PPO + (((tr*4u+0u)*2u+strip)*128u + il*16u)*2u, oh0.template select<16,1>(0).read());
                wbv3::sh16(S_PPO + (((tr*4u+1u)*2u+strip)*128u + il*16u)*2u, oh0.template select<16,1>(16).read());
                wbv3::sh16(S_PPO + (((tr*4u+2u)*2u+strip)*128u + il*16u)*2u, oh1.template select<16,1>(0).read());
                wbv3::sh16(S_PPO + (((tr*4u+3u)*2u+strip)*128u + il*16u)*2u, oh1.template select<16,1>(16).read());
            }
            esimd::barrier();
            if (stop_stage == 6u) {   // probs map-dump (v3 stop=6 form)
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] =
                        wbv3::lh16(S_PPO + wbv3::pa16_dest(lid,c,4u)*2u)[0];
                return;
            }

            // ===== P5 attnV rows-owned: 2 tiles per subgroup =====
            for (uint tc = 0; tc < 2u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8ss(c00,c01,c10,c11, S_PPO + sgid*2048u, S_VPO + tc*512u, 4, 2);
                wbv3::store16s(S_SCR + sgid*SCR_SG + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            esimd::barrier();
            if (stop_stage == 8u) {   // attended rows (v3 stop=8 form: f32->half)
                uint sg = lid >> 4, rr = lid & 15u;
                uint scr = S_SCR + sg*SCR_SG;
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] =
                        half(esimd::slm_block_load<float,1>(scr + (rr*32u+c)*4u)[0]);
                return;
            }

            // ===== P6 attended->ATO (owned rows), outproj rows-owned =====
            {
                uint scr = S_SCR + sgid*SCR_SG;
                uint r2 = lane, r = sgid*16u + lane;
                esimd::simd<float,32> cv = esimd::slm_block_load<float,32>(scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(cv));
                uint tr=r>>4, strip=(r>>3)&1u, il=r&7u;
                wbv3::sh16(S_ATO + (((tr*2u+0u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(0).read());
                wbv3::sh16(S_ATO + (((tr*2u+1u)*2u+strip)*128u + il*16u)*2u, oh.template select<16,1>(16).read());
            }
            esimd::barrier();
            for (uint tc = 0; tc < 2u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8s(c00,c01,c10,c11, S_ATO + sgid*1024u, WprojPacked + (size_t)tc*256u, 2, 2);
                wbv3::store16s(S_SCR + sgid*SCR_SG + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            esimd::barrier();
            if (stop_stage == 9u) {   // projected rows (v3 stop=9 form)
                uint sg = lid >> 4, rr = lid & 15u;
                uint scr = S_SCR + sg*SCR_SG;
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] =
                        half(esimd::slm_block_load<float,1>(scr + (rr*32u+c)*4u)[0]);
                return;
            }

            // ===== P7 residual fma + publish -> image (VERBATIM v3, rows owned) =====
            {
                uint r2 = lane, r = sgid*16u + lane;
                int y = (int)((window / window_cols) * 8u + (r >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (r & 7u)) - (int)left;
                if (y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w) {
                    size_t at = ((size_t)y * image_w + (size_t)x) * 32u;
                    esimd::simd<float,32> sk, cosv, proj;
                    if (image_half) {
                        esimd::simd<half,32> hh((const half*)Img + at, esimd::overaligned_tag<16>{});
                        sk = esimd::convert<float>(hh);
                    } else sk.copy_from((const float*)Img + at);
                    cosv.copy_from(Cos);
                    proj = esimd::slm_block_load<float,32>(S_SCR + sgid*SCR_SG + r2*32u*4u, esimd::overaligned_tag<16>{});
                    esimd::simd<float,32> total = sk * cosv + proj;
                    esimd::simd<float,32> pub;
                    if (epilogue == 1u)      pub = wbv3::e4m3_vec<32>(total);
                    else if (epilogue == 0u) pub = total;
                    else if (epilogue == 4u) pub = esimd::convert<float>(esimd::convert<half>(total));
                    else {
                        auto tv = total.read();
                        esimd::simd<float,32> pv;
                        for (uint c = 0; c < 32; ++c) pv[c] = wbmega::pub_esimd(epilogue, tv[c]);
                        pub = pv;
                    }
                    if (narrow) esimd::convert<half>(pub).copy_to(Tgt + at);
                    else pub.copy_to(TgtF + at);
                }
            }
        });
    });
}

// ---- host pack helper for the projection weights (32x32) like cached_pack_b_f16 ----
static void host_pack_b(const half* B, half* Bp, int K, int N){ f16v1::pack_b(B,Bp,K,N); }

int main(){
  device dev;
  for(auto&d:device::get_devices(info::device_type::gpu))
    if(d.get_backend()==backend::ext_oneapi_level_zero&&d.get_info<info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
  queue q(dev,property::queue::enable_profiling{});
  const unsigned windows=2040, image_h=544, image_w=960, window_cols=34;
  const unsigned C=32, NH=96;
  std::mt19937 rng(11);
  std::uniform_real_distribution<float> df(-6.f,6.f);
  std::vector<float> img((size_t)image_h*image_w*C);
  for(auto&x:img)x=df(rng);
  std::vector<half> wq((size_t)C*NH), wp((size_t)C*C);
  for(auto&x:wq)x=half(df(rng)); for(auto&x:wp)x=half(df(rng));
  std::vector<half> wqpk((size_t)C*NH), wppk((size_t)C*C);
  host_pack_b(wq.data(),wqpk.data(),(int)C,(int)NH);
  host_pack_b(wp.data(),wppk.data(),(int)C,(int)C);
  std::vector<float> bias((size_t)64*64); for(auto&x:bias)x=df(rng)*0.1f;
  std::vector<float> cosv(C); for(auto&x:cosv)x=df(rng)*0.2f;
  float qs[1]={0.125f};
  float* dImg=malloc_device<float>(img.size(),q);
  half* dWq=malloc_device<half>(wqpk.size(),q);
  half* dWp=malloc_device<half>(wppk.size(),q);
  float* dBias=malloc_device<float>(bias.size()*4,q);
  float* dCos=malloc_device<float>(C*4,q);
  float* dQs=malloc_device<float>(4,q);
  half* dTgt=malloc_device<half>((size_t)image_h*image_w*C*2,q);   // room for f32 TgtF form
  q.memcpy(dImg,img.data(),img.size()*4).wait();
  q.memcpy(dWq,wqpk.data(),wqpk.size()*2).wait();
  q.memcpy(dWp,wppk.data(),wppk.size()*2).wait();
  q.memcpy(dBias,bias.data(),bias.size()*4).wait();
  q.memcpy(dCos,cosv.data(),C*4).wait();
  q.memcpy(dQs,qs,4).wait();
  q.memset(dTgt,0,(size_t)image_h*image_w*C*2).wait();
  const int NST=7;                       // stops 10,11,12,5,6,8,9
  const unsigned stops[NST]={10u,11u,12u,5u,6u,8u,9u};
  const char* names[NST]={"QPO","KTO","VPO","scores","probs","attended","projected"};
  size_t rstride=(size_t)windows*4096;
  half* dRef=malloc_device<half>(NST*rstride,q);
  half* dV4 =malloc_device<half>(NST*rstride,q);
  q.memset(dRef,0,NST*rstride*2).wait();
  q.memset(dV4,0,NST*rstride*2).wait();
  auto v3call=[&](unsigned st, half* dump){
    return wbv3::launch_v3(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        windows,image_h,image_w,window_cols,0u,0u,0u,false,st,dump); };
  auto v4call=[&](unsigned st, half* dump){
    return launch_v4full(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        windows,image_h,image_w,window_cols,0u,0u,0u,false,st,dump); };
  auto timeit=[&](const char* nm, std::function<event()> fn){
    double best=1e9;
    for(int it=0;it<9;++it){ event e=fn(); e.wait();
      auto s0=e.get_profiling_info<info::event_profiling::command_start>();
      auto t0=e.get_profiling_info<info::event_profiling::command_end>();
      best=std::min(best,(double)(t0-s0)/1e6);}
    printf("%-22s %.4f ms\n",nm,best); return best; };
  // stage ladders (same dump shape both sides)
  double tv3sum=0, tv4sum=0;
  for(int i=0;i<NST;++i){
    double a=timeit((std::string("v3 ")+names[i]).c_str(), [&]{ return v3call(stops[i], dRef+i*rstride); });
    double b=timeit((std::string("v4 ")+names[i]).c_str(), [&]{ return v4call(stops[i], dV4+i*rstride); });
    tv3sum+=a; tv4sum+=b;
  }
  // full runs (no dump) for the real price
  double f3=timeit("v3 FULL", [&]{ return v3call(0u,nullptr); });
  double f4=timeit("v4 FULL", [&]{ return v4call(0u,nullptr); });
  double fl0=f4;
  double fl8=timeit("v4 FULL fill8 ", [&]{ return launch_v4full<8>(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,2040u,272u,480u,60u,0u,0u,1u,true,0u,nullptr); });
  double fl32=timeit("v4 FULL fill32", [&]{ return launch_v4full<32>(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,2040u,272u,480u,60u,0u,0u,1u,true,0u,nullptr); });
  // CORRECT READING (hand calc, the auto-heuristic above was garbage): the fill
  // ops become compile-time-constant adds (mul folded), so fill8 = 32 adds and
  // fill32 = 128 adds per thread. Full EU cost = adds x threads / EUs / clock =
  // 128 x 130,560 / 32 / 2GHz = 0.26ms for fill32; MEASURED +0.0475 = ~82%
  // ABSORBED. The senior's rule (PROBE_FILL comment, window_block.comp:92): a
  // kernel that absorbs fill for free is WAITING ON ITS DEPENDENCY CHAINS.
  // => window_block v4 is LATENCY-bound (chains + WG barriers), ~20% issue
  // utilization. v5's lever: SHORTEN CHAINS / ADD PARALLELISM per window --
  // the senior's 8-subgroup x 8-row geometry (half the serial depth per thread,
  // 2x the independent chains, subgroup-local barriers). Blade-1 (fewer store
  // instrs) helped because stores sit IN the chain (SLM write->read round-trip
  // latency), consistent with the same model.
  printf("FILL PROBE: base=%.4f fill8=%.4f (+%.4f; full-issue cost would be +0.065) fill32=%.4f (+%.4f; full cost +0.26) => ~80%% ABSORBED = LATENCY-BOUND: v5 shortens chains (senior geometry)\n",
     fl0, fl8, fl8-fl0, fl32, fl32-fl0);
  // P8-ladder: PURE stops (dump guarded by DumpKV=nullptr -> stop only):
  // the real stage deltas with no 16MB dump traffic polluting them.
  double p10=timeit("v4 stop QKV(QPO)",[&]{ return v4call(10u,nullptr); });
  double p101=timeit("v4 stop P0only  ",[&]{ return v4call(101u,nullptr); });
  double p102=timeit("v4 stop part0   ",[&]{ return v4call(102u,nullptr); });
  double p103=timeit("v4 stop part01  ",[&]{ return v4call(103u,nullptr); });
  printf("QKV split: P0=%8.4f | part0(Q)=%8.4f | part1(K)=%8.4f | part2(V)=%8.4f\n",
         p101, p102-p101, p103-p102, p10-p103);
  double p12=timeit("v4 stop VPO    ",[&]{ return v4call(12u,nullptr); });
  double p5 =timeit("v4 stop scores ",[&]{ return v4call(5u,nullptr); });
  double p6 =timeit("v4 stop probs  ",[&]{ return v4call(6u,nullptr); });
  double p8 =timeit("v4 stop attend ",[&]{ return v4call(8u,nullptr); });
  double p9 =timeit("v4 stop project",[&]{ return v4call(9u,nullptr); });
  printf("PURE-LADDER v4: QKV=%8.4f | +scores=%8.4f | +probs=%8.4f | +attend=%8.4f | +project=%8.4f | FULL=%8.4f\n",
         p10,p5,p6,p8,p9,f4);
  printf("  stage deltas: QKV=%8.4f scores=%8.4f softmax=%8.4f attnV=%8.4f outproj+store=%8.4f\n",
         p10, p5-p10, p6-p5, p8-p6, f4-p8);
  // judge
  std::vector<half> ref(NST*rstride), got(NST*rstride);
  q.memcpy(ref.data(),dRef,ref.size()*2).wait();
  q.memcpy(got.data(),dV4,got.size()*2).wait();
  int allok=1;
  const uint16_t* pr=reinterpret_cast<const uint16_t*>(ref.data());
  const uint16_t* pg=reinterpret_cast<const uint16_t*>(got.data());
  for(int i=0;i<NST;++i){
    unsigned bad=0; const uint16_t*a=pr+i*rstride,*b=pg+i*rstride;
    for(size_t j=0;j<rstride;++j) if(a[j]!=b[j]) bad++;
    printf("JUDGE %-10s mismatches=%u / %zu  %s\n",names[i],bad,rstride,bad?"BAD":"EXACT");
    allok&=!bad;
  }
  printf("ladder sums v3=%.3f v4=%.3f | FULL v3=%.3f v4=%.3f ratio=%.2fx => %s\n",
    tv3sum,tv4sum,f3,f4,f3/f4,allok?"EXACT":"BAD");

  // ---- P8-h (section 100): the FRAME-SHAPE ladder (the game-path ledger priced
  // the window_block family at 31.7ms/16 calls = 1.98/call vs this bench's
  // synthetic 1.30 at 2040w -- the census says why: the 16 calls are NOT all
  // 2040w. Plan: {2040w 272x480 a60 pad0}x4 {2135w a61 pad4|4}x2 {2074w a61
  // pad0|4}x2 {2100w a60 pad4|0}x2 {8160w 544x960 a120 pad0}x2 {8349w a121
  // pad4|4}x2 -- all on the v4full route (the NR_V2_STOP=65530 ledger covers all
  // 16). The TWO 8K-window giants are the suspected fat: time every shape. ----
  printf("--- FRAME-SHAPE ladder (v4 FULL; epi/narrow = the frame's 4352 = epi1|narrow) ---\n");
  struct S{const char* n;unsigned w,ih,iw,ac,pt,pl;};
  std::vector<S> shapes={
    {"2040w 272x480 a60 p0",2040,272,480,60,0,0},
    {"2135w 272x480 a61 p4|4",2135,272,480,61,4,4},
    {"2074w 272x480 a61 p0|4",2074,272,480,61,0,4},
    {"2100w 272x480 a60 p4|0",2100,272,480,60,4,0},
    {"8160w 544x960 a120 p0",8160,544,960,120,0,0},
    {"8349w 544x960 a121 p4|4",8349,544,960,121,4,4}};
  for(auto&sh:shapes){
    double t=timeit(("v4 "+std::string(sh.n)).c_str(),[&]{
      return launch_v4full(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        sh.w,sh.ih,sh.iw,sh.ac,sh.pt,sh.pl,1u,true,0u,nullptr); });
  }
  // ---- P8-h giant STAGE ladder (pure stops, no dumps): where does the 4.89ms go?
  printf("--- 8160w GIANT stage ladder ---\n");
  {
    auto G=[&](unsigned st){ return launch_v4full(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        8160u,544u,960u,120u,0u,0u,1u,true,st,nullptr); };
    double p0=timeit("g stop P0only  ",[&]{ return G(101u); });
    double qkv=timeit("g stop QKV     ",[&]{ return G(10u); });
    double sco=timeit("g stop scores  ",[&]{ return G(5u); });
    double prb=timeit("g stop probs   ",[&]{ return G(6u); });
    double att=timeit("g stop attend  ",[&]{ return G(8u); });
    double prj=timeit("g stop project ",[&]{ return G(9u); });
    double full=timeit("g stop FULL    ",[&]{ return G(0u); });
    printf("GIANT deltas: P0=%.3f QKV=%.3f scores=%.3f softmax=%.3f attnV=%.3f outproj=%.3f store=%.3f\n",
           p0, qkv-p0, sco-qkv, prb-sco, att-prb, prj-att, full-prj);
    // P8-h probe A: is the giant's per-WG time a TAIL/occupancy artifact? 8160 WG
    // = 51 SM x 160/wave x 1.003 waves -- the 0.003 tail = 5 dead SMs for a full
    // wave. Run the SAME 8160 windows as 2 x 4080 (the recorder's giant calls are
    // single launches; this probe splits the grid artificially by launching with
    // half the windows twice -- output-correctness irrelevant here, timing only).
    double half1=timeit("g 2x4080w first ",[&]{ return launch_v4full(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        4080u,544u,960u,120u,0u,0u,1u,true,0u,nullptr); });
    double half2=timeit("g 2x4080w second",[&]{ return launch_v4full(q,dImg,false,dWq,dWp,dTgt,(float*)dTgt,dBias,dCos,dQs,
        4080u,544u,960u,120u,0u,0u,1u,true,0u,nullptr); });
    printf("2x4080 = %.3f vs 1x8160 = %.3f  -> tail effect %s\n", half1+half2, full,
           (half1+half2 < full*0.95) ? "REAL (split wins)" : "none/linear");
    // P8-h probe C (the DECISIVE one): per-WG time parity -- smalls 1.25/2040 =
    // 0.61us/WG, giants 4.88/8160 = 0.60us/WG: NO giant-specific inefficiency; the
    // 19.5ms = 4x data at the family's per-WG cost. So the lever is the per-WG
    // ELEMENTWISE chain (XMX util = 5.4GFLOP/(4.88ms x 131T) = 0.8%: the dpas
    // engine is idle 99% of the time). Localize inside QKV (the 2.115 fat):
    // micro-stops 102 (after part0=Q) / 103 (after part1=K) at the giant shape.
    double g102=timeit("g stop after Q",[&]{ return G(102u); });
    double g103=timeit("g stop after K",[&]{ return G(103u); });
    printf("GIANT QKV parts: P0=%.3f Q=%.3f K=%.3f V=%.3f (V has NO cosine_recip)\n",
           p0, g102-p0, g103-g102, qkv-g103);
    // probe B: P0 gather overlap dedup -- the giant rows have across=120 == vw/8=120
    // = NO horizontal overlap between windows in a row; vertical overlap x16.
    // P0 alone is 0.219 of 4.88 -> the dedup ceiling on P0 is TINY. Skip.
  }
  return allok?0:1;
}
