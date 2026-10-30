// window_block_v4ph.hpp -- POOL/HEAD variant: a SEPARATE kernel (the plain v4.hpp stays the promoted 8aec17d codegen VERBATIM; no shared template -> no cross-instantiation codegen shift). Same stages, same operator, plus the senior's pool fold (:522-527) and head GEMM+compact store (:461-505) outlets. section 100 P1: the senior's STAGE DISCIPLINE on our
// untouched dpas operator (bench_v4full: ALL SEVEN regions bit-exact vs v3 over
// 8.36M half-slots each; FULL 2.12x, 2.98 -> 1.40 ms per 2040-window call).
// Row-ownership end to end, ONE group barrier (v3: ~10), per-subgroup 4KB SCR
// reused across stages (v3: 24KB DCQ + 16KB DSC slabs), softmax's WGT round-trip
// deleted. Operator = wbv3 tile8s/tile8ss/store16s/e4m3_vec/cosine_recip_vec/mulh
// + pack maps VERBATIM. Opt-in NR_WB_V4 (plain form first; pool/head follow).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include "window_block_v3.hpp"
#include "window_block_mega.hpp"

namespace wbv4ph {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM map (bytes): AQO 0..4096 | QPO 4096..8192 | KTO 8192..12288 | VPO 12288..16384 |
//                  ATO 16384..20480 | PPO 20480..28672 | SCR 28672..45056 (4SG x 4KB)
constexpr uint S_AQO=0, S_QPO=4096, S_KTO=8192, S_VPO=12288, S_ATO=16384, S_PPO=20480, S_SCR=28672;
constexpr uint SCR_SG=4096;

inline event launch_v4ph(queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,
    half* Tgt, float* TgtF, const float* Bias, const float* Cos, const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr,
    bool pooling = false, bool head = false, half* Pl = nullptr, const half* HeadWp = nullptr,
    half* HeadADump = nullptr, float* ProjFDump = nullptr, float* TotalDump = nullptr)
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

            // ===== P1+P2 fused (the slice VERBATIM) =====
            // P8-blade2 (B1, the v4 twin, bench-proven on the v4 copy first): TWO-PHASE QKV
            // -- phase 1 dpas+merged-stores for all 3 parts into scrA/scrB/scrC
            // (the subgroup SCR 4KB splits in two; scrC aliases the PPO head,
            // dead until softmax), ONE barrier, phase 2 reload+epilogue+scatter
            // with the per-row chain VERBATIM. JUDGEs all seven EXACT on the twin.
            uint scrA = S_SCR + sgid*SCR_SG;
            uint scrB = S_SCR + sgid*SCR_SG + 2048u;
            uint scrC = S_PPO + sgid*2048u;
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
                uint scr = (part==0u)? scrA : (part==1u)? scrB : scrC;
                uint r2 = lane, r = sgid*16u + lane;
                esimd::simd<float,32> hv = esimd::slm_block_load<float,32>(
                    scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                // B3-1 RACE FIX (walk 1301 byte-1 mismatch, gate-green frame-red --
                // the P2-era class again): the half temp lands in scr's FIRST 1KB,
                // which overlaps OTHER threads' f32 rows (row r2 f32 = bytes
                // r2*128..+127; thread r2>=2's temp = r2*64..+63 sits inside row
                // r2/2's f32). Every hv load must complete before ANY temp write:
                // one barrier after the loads. (The old scatter form never touched
                // scr, so it had no such hazard.)
                if (part != 0u) esimd::barrier();
                if (part == 2u) {
                    esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(hv));
                    // B3-1 (2026-10-30, the supply census): this staging wrote the
                    // tile with THIRTY-TWO 2-BYTE scalar SLM stores per row
                    // (pb16_dest_kn scatter) -- ~2048 narrow messages per window,
                    // the frame's biggest hot-loop supply tax (v4full 20 calls).
                    // blade-7 form (proven on the wa_res K/V gathers): the row's
                    // 32 halves go to the thread's OWN scr slot (ONE 64B store --
                    // the f32 value there was consumed by THIS thread's load above,
                    // slot-local, no race), then lanes 0..7 assemble the 8 tile
                    // blocks (kc 0..3 x js 0..1) from the 1KB region: 8 x 32B
                    // row-slice loads + in-register interleave + ONE 256B store.
                    // Values/addresses identical to the scalar form by construction.
                    esimd::slm_block_store(scr + r2 * 32u * 2u, oh, esimd::overaligned_tag<16>{});
                    esimd::barrier();
                    if (lane < 4u) {   // 4 V blocks per sgid: tc(0..1) x js(0..1)
                        uint tc = lane >> 1, js = lane & 1u;
                        esimd::simd<half,128> blk;
                        #pragma unroll
                        for (int kq = 0; kq < 8; ++kq) {
                            esimd::simd<half,8> a = esimd::slm_block_load<half,8>(
                                scr + ((uint)(2*kq) * 32u + tc * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                            esimd::simd<half,8> bv = esimd::slm_block_load<half,8>(
                                scr + ((uint)(2*kq+1) * 32u + tc * 16u + js * 8u) * 2u, esimd::overaligned_tag<16>{});
                            blk.template select<8,2>(kq * 16 + 0) = a;
                            blk.template select<8,2>(kq * 16 + 1) = bv;
                        }
                        esimd::slm_block_store(S_VPO + (((sgid * 2u + tc) * 2u + js) * 128u) * 2u,
                                               blk, esimd::overaligned_tag<16>{});
                    }
                    esimd::barrier();
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
                        // B3-1 (K side): 16 x 4-BYTE scatter stores -> blade-7 wide
                        // form (the KT blocks (kc*4+tc)*2+js, tc=sgid: 4 blocks per
                        // subgroup, lanes 0..3 assemble). scrB slot is this thread's
                        // own (its f32 was consumed by the part's load above).
                        esimd::slm_block_store(scr + r2 * 32u * 2u, oh, esimd::overaligned_tag<16>{});
                        esimd::barrier();
                        if (lane < 4u) {   // 4 K blocks per sgid: kc(0..1) x js(0..1)
                            uint kc2 = lane >> 1, js = lane & 1u;
                            esimd::simd<half,128> blk;
                            #pragma unroll
                            for (int jl = 0; jl < 8; ++jl) {
                                esimd::simd<half,16> vr = esimd::slm_block_load<half,16>(
                                    scr + ((js * 8u + (uint)jl) * 32u + kc2 * 16u) * 2u, esimd::overaligned_tag<16>{});
                                #pragma unroll
                                for (int kq = 0; kq < 8; ++kq)
                                    blk.template select<2,1>(kq * 16 + jl * 2) = vr.template select<2,1>(kq * 2);
                            }
                            esimd::slm_block_store(S_KTO + (((kc2 * 4u + sgid) * 2u + js) * 128u) * 2u,
                                                   blk, esimd::overaligned_tag<16>{});
                        }
                        esimd::barrier();
                    }
                }
            }
            // v5c: the end-QKV subgroup barrier serves ONLY the stop=10/11/12
            // DUMP path (cross-subgroup map reads); the frame path's cross-
            // subgroup sync is the group_barrier below, and scrA/B/C phase-2
            // reads are subgroup-local. Skip it when not dumping.
            if (DumpKV) esimd::barrier();
            auto dump_region = [&](uint reg) SYCL_ESIMD_FUNCTION {
                if (DumpKV) { half* d=DumpKV+(size_t)window*4096u;
                    for (uint i=0;i<2048u;i+=64u) d[i+lid]=wbv3::lh16(reg+(i+lid)*2u)[0]; } };
            if (stop_stage == 10u) { dump_region(S_QPO); return; }
            if (stop_stage == 11u) { dump_region(S_KTO); return; }
            if (stop_stage == 12u) { dump_region(S_VPO); return; }
            group_barrier(it.get_group());          // KTO/VPO shared for P3/P5

            // ===== P3 scores: rows owned, cols 0..63 =====
            // P8-f (section 100): the A tile is the SAME across all four tc blocks
            // -- hoisted to registers once (the v4 twin; bench_v4full JUDGEs EXACT).
            {
              uint qb = S_QPO + sgid*1024u;
              esimd::simd<half,128> aq0 = esimd::slm_block_load<half,128>(qb, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq1 = esimd::slm_block_load<half,128>(qb + 256, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq2 = esimd::slm_block_load<half,128>(qb + 512, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq3 = esimd::slm_block_load<half,128>(qb + 768, esimd::overaligned_tag<16>{});
              for (uint tc = 0; tc < 4u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                uint bb = S_KTO + tc*512u;
                esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(bb + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, aq0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, aq0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, aq1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, aq1);
                esimd::simd<half,128> c0 = esimd::slm_block_load<half,128>(bb + 2048, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> c1 = esimd::slm_block_load<half,128>(bb + 2304, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, c0, aq2);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, c1, aq2);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, c0, aq3);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, c1, aq3);
                uint scr = S_SCR + sgid*SCR_SG;
                #pragma unroll
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
            if (stop_stage == 9u) {   // projected rows, FULL f32 (the section-100
                uint sg = lid >> 4, rr = lid & 15u;   // outproj-order judge vs A2's dC3)
                uint scr = S_SCR + sg*SCR_SG;
                if (ProjFDump) for (uint c = 0; c < 32; ++c)
                    ProjFDump[(size_t)window*2048u + lid*32u + c] =
                        esimd::slm_block_load<float,1>(scr + (rr*32u+c)*4u)[0];
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] =
                        half(esimd::slm_block_load<float,1>(scr + (rr*32u+c)*4u)[0]);
                return;
            }

            // ===== P7 residual fma + publish; form outlets (pool/head), plain tail =====
            // FMA-CONTRACTION FIX (section 100, the ULP root cause pinned by the
            // witness experiment: A2 total == fma-numpy 100%%, old v4ph total ==
            // muladd-numpy 100%%): the loads and the expression must be ADJACENT in
            // one straight-line block -- sk pre-initialized to 0 and conditionally
            // reassigned made it a phi node and blocked the single-HW-FMA lowering
            // A2's f16v3 gets (its row loop does `if(out) continue; sk=load;
            // total=sk*cv+acc;` -- same shape as the `if(inimg){...}` here).
            {
                uint r2 = lane, r = sgid*16u + lane;
                uint scr = S_SCR + sgid*SCR_SG;
                int y = (int)((window / window_cols) * 8u + (r >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (r & 7u)) - (int)left;
                bool inimg = y >= 0 && y < (int)image_h && x >= 0 && x < (int)image_w;
                size_t at = ((size_t)(inimg ? y : 0) * image_w + (size_t)(inimg ? x : 0)) * 32u;
                esimd::simd<float,32> sk, cosv, proj, total;
                if (inimg) {
                    if (image_half) {
                        esimd::simd<half,32> hh((const half*)Img + at, esimd::overaligned_tag<16>{});
                        sk = esimd::convert<float>(hh);
                    } else sk.copy_from((const float*)Img + at);
                    cosv.copy_from(Cos);
                    proj = esimd::slm_block_load<float,32>(scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                    total = sk * cosv + proj;     // adjacent -> ONE HW FMA (senior :442)
                } else { sk = cosv = proj = total = esimd::simd<float,32>(0.f); }
                if (stop_stage == 13u && ProjFDump) {   // the sk|cosv|proj witness (block
                    auto skv = sk.read(); auto cvv = cosv.read(); auto prv = proj.read(); // layout)
                    float* d = ProjFDump + ((size_t)window*64u + (size_t)r) * 96u;
                    for (uint c = 0; c < 32u; ++c){ d[c]=skv[c]; d[32+c]=cvv[c]; d[64+c]=prv[c]; }
                    return;
                }
                if (head) {
                    // senior :445-447 + leg4: published halves stay on-chip as the head
                    // GEMM's A, pa16-packed into the scratch's SECOND half. Out-of-image
                    // rows -> total=0 -> kh=0 (the senior's kept init-zero :432).
                    esimd::barrier();               // every lane read proj before packing
                    esimd::simd<half,32> kh = esimd::convert<half>(total);
                    if (HeadADump && inimg) {   // crop-order A dump == the split chain's
                        auto kv = kh.read();    // dOut16 layout. y,x are ALREADY crop-local
                        half* d = HeadADump + ((size_t)y * image_w + (size_t)x) * 32u;  // (P7 minus top/left)
                        for (uint c = 0; c < 32u; ++c) d[c] = kv[c];
                    }
                    uint strip=(r2>>3)&1u, il=r2&7u;
                    uint hbase = scr + 2048u;
                    wbv3::sh16(hbase + (((0u*2u+strip)*128u + il*16u))*2u, kh.template select<16,1>(0).read());
                    wbv3::sh16(hbase + (((1u*2u+strip)*128u + il*16u))*2u, kh.template select<16,1>(16).read());
                    esimd::barrier();
                    esimd::simd<float,64> h00(0.f),h01(0.f),h10(0.f),h11(0.f);
                    wbv3::tile8s(h00,h01,h10,h11, hbase, HeadWp, 2, 1);   // 16 rows x 16 cols
                    // compact store: cols 0..3 (xmxres leading (0,0,4); senior :491-497).
                    if (inimg) {
                        auto hv0 = h00.read();   // rows 0..7  x cols 0..7
                        auto hv1 = h10.read();   // rows 8..15 x cols 0..7
                        float* dst = TgtF + ((size_t)y * image_w + (size_t)x) * 4u;
                        if (lane < 8u) { for (uint c = 0; c < 4u; ++c) dst[c] = hv0[lane*8u + c]; }
                        else           { for (uint c = 0; c < 4u; ++c) dst[c] = hv1[(lane-8u)*8u + c]; }
                    }
                    return;
                }
                if (pooling) {
                    // senior :449-456 + A2 + the scalar chain: target ALWAYS half(e4m3(total));
                    // raw total stays in scratch for the fold.
                    if (inimg)
                        esimd::convert<half>(wbv3::e4m3_vec<32>(total)).copy_to(Tgt + at);
                    esimd::slm_block_store(scr + r2*32u*4u, total, esimd::overaligned_tag<16>{});
                    if (TotalDump && inimg) {   // the f32 total in the BLOCK layout
                        auto tv = total.read(); // (window*64 + token)*32 + c == A2's
                        float* d = TotalDump + ((size_t)window*64u + (size_t)r) * 32u;  // Stage
                        for (uint c = 0; c < 32u; ++c) d[c] = tv[c];
                    }
                    esimd::barrier();
                    // fold per-subgroup: rows 2*sgid,2*sgid+1 (tokens sgid*16..+15) = pooled
                    // row py=sgid. senior :522-527 tap order ((UL+LL)+UR)+LR, *0.25, e4m3.
                    uint px = lane >> 2, cq = (lane & 3u) * 8u;
                    int iy = (int)((window / window_cols) * 8u + 2u*sgid) - (int)top;
                    int ix = (int)((window % window_cols) * 8u + 2u*px) - (int)left;
                    if (iy >= 0 && ix >= 0 && iy < (int)image_h && ix < (int)image_w) {
                        auto UL = esimd::slm_block_load<float,8>(scr + (2u*px)*128u + cq*4u);
                        auto LL = esimd::slm_block_load<float,8>(scr + (8u+2u*px)*128u + cq*4u);
                        auto UR = esimd::slm_block_load<float,8>(scr + (2u*px+1u)*128u + cq*4u);
                        auto LR = esimd::slm_block_load<float,8>(scr + (8u+2u*px+1u)*128u + cq*4u);
                        esimd::simd<float,8> tot = ((UL + LL) + UR) + LR;
                        esimd::simd<half,8> ph = esimd::convert<half>(wbv3::e4m3_vec<8>(tot * esimd::simd<float,8>(0.25f)));
                        size_t out = ((size_t)(iy / 2) * (image_w / 2u) + (size_t)(ix / 2)) * 32u + cq;
                        ph.copy_to(Pl + out);
                    }
                    return;
                }
                // plain outlet (VERBATIM the 8aec17d P7 form)
                if (inimg) {
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

} // namespace wbv4ph
