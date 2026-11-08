// window_block_v4.hpp -- section 100 P1: the senior's STAGE DISCIPLINE on our
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

namespace wbv4 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM map (bytes): AQO 0..4096 | QPO 4096..8192 | KTO 8192..12288 | VPO 12288..16384 |
//                  ATO 16384..20480 | PPO 20480..28672 | SCR 28672..45056 (4SG x 4KB)
constexpr uint S_AQO=0, S_QPO=4096, S_KTO=8192, S_VPO=12288, S_ATO=16384, S_PPO=20480, S_SCR=28672;
constexpr uint SCR_SG=4096;

inline event launch_v4full(queue& q, const void* Img, bool image_half,
    const half* WqkvPacked, const half* WprojPacked,
    half* Tgt, float* TgtF, const float* Bias, const float* Cos, const float* QkvScale,
    unsigned windows, unsigned image_h, unsigned image_w,
    unsigned window_cols, unsigned pad_top, unsigned pad_left,
    unsigned epilogue, bool narrow,
    unsigned stop_stage = 0, half* DumpKV = nullptr)
{
    LC_TICK();   // #145 军规 132: launch counted at helper entry
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
            // P8-blade2 (B1, branch b1-wblock-resident; bench-proven QKV 0.518->
            // 0.474, FULL 1.216->1.111, all seven JUDGEs EXACT): TWO-PHASE QKV.
            // The fill probe (a196d5e) says v4 is LATENCY-bound; the per-part
            // store->barrier->reload chains serialize. Phase 1: dpas + merged
            // f32 stores for ALL THREE parts into THREE separate scr slabs
            // (scrA/scrB split the 4KB subgroup SCR; scrC aliases the PPO head,
            // DEAD until softmax -- the phase-2 loop consumes scrC fully before
            // P4 writes PPO, then a barrier). ONE barrier. Phase 2: reload +
            // epilogue + scatter for all three; the per-row op CHAIN is VERBATIM
            // the old body -> bit-identical by construction.
            uint scrA = S_SCR + sgid*SCR_SG;
            uint scrB = S_SCR + sgid*SCR_SG + 2048u;
            uint scrC = S_PPO + sgid*2048u;
            // C7 BLADE (2026-11-08, lane-disjoint P1; same family as C5/P3, audit s6/layer1.md 76,
            // 定档 s6/c7_p1.cpp: uniform 0.2598 vs lane-disjoint 0.1266 ms/launch = -51.3 percent,
            // static 63 dpas / 81 send.slm / 531 instr -> 6 / 27 / 113).
            // The old loop was SUBGROUP-UNIFORM (Ab = S_AQO + sgid*1024, WqkvPacked + (part*2+cd)*256
            // carry NO lane term) => all 16 lanes recomputed the same 16x32 part block 16 times
            // (48 dpas + 24 SLM + 24 weight loads + 48 stores per lane).
            // NEW: the 3 parts x (2 row-blocks x 4 col-blocks) = 24 jobs of one 8x8 tile; lane takes
            // job `lane`, and lanes 0..7 take the extra job lane+16 => 24 jobs over 16 lanes, every
            // output element computed EXACTLY ONCE (24 x 64 = 1,536 = 3 parts x 16 rows x 32 cols).
            // K chain per element UNCHANGED: tile8s(kb_n=2,tc_n=6) accumulated c00 as
            // dpas(b0@kc0, a0@kc0) then dpas(b0@kc1, a0@kc1) -- same order, same fragments here.
            // Operand slices are byte-identical to tile8s's: a = S_AQO + sgid*1024 + kc*512 + rb*256
            // (rows rb*8..rb*8+7 of K-chunk kc), b = WqkvPacked + (part*2 + (cb>>1))*256 + (cb&1)*128
            // + kc*(tc_n*2*128 = 1536) (cols cb*8..cb*8+7). SCR byte map UNCHANGED
            // (row*128B + col*4B, row stride 32 floats), so P2's reload loop (:112-202) and the
            // stop_stage 10/11/12 dumps read the same bytes.
            #pragma unroll
            for (uint pass = 0; pass < 2u; ++pass) {
                uint job = lane + pass*16u;
                if (job < 24u) {
                    uint part = job >> 3, tile = job & 7u;
                    uint rb = tile & 1u, cb = tile >> 1u;
                    uint scr = (part==0u)? scrA : (part==1u)? scrB : scrC;
                    const half* Wb = WqkvPacked + (size_t)(part*2u + (cb>>1u))*256u + (size_t)(cb&1u)*128u;
                    esimd::simd<float,64> c(0.f);
                    #pragma unroll
                    for (uint kc = 0; kc < 2u; ++kc)
                        c = esimd::xmx::dpas<8, 8, float>(c,
                            esimd::simd<half,128>(Wb + (size_t)kc*1536u, esimd::overaligned_tag<16>{}),
                            esimd::slm_block_load<half,128>(S_AQO + sgid*1024u + kc*512u + rb*256u, esimd::overaligned_tag<16>{}));
                    #pragma unroll
                    for (int r = 0; r < 8; ++r)
                        esimd::slm_block_store(scr + (rb*8u + (uint)r)*128u + cb*32u,
                                               c.template select<8,1>(r*8));   // 8-float block: no OWORD tag
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
                    // B3-1 (2026-10-30 supply census, THE hot path): the old form
                    // wrote the V tile with 32 TWO-BYTE scalar SLM stores per row
                    // (pb16_dest_kn scatter) -- ~2048 narrow messages per window x 20
                    // layers = the biggest hot-loop supply tax the loopmix ledger
                    // pointed at. blade-7 form (proven on the wa_res K/V gathers):
                    // row -> the thread's OWN scr slot (ONE 64B store; the f32 value
                    // there was consumed by THIS thread's load above = slot-local),
                    // subgroup barrier, then lanes 0..3 assemble the 4 blocks
                    // (tc x js) with 8x(2x16B loads + interleave) + ONE 256B store.
                    // pb16_dest_kn(r,c,4,2): block=(sgid*2+tc)*2+js, elem=kq*16+jl*2
                    // +kpar <- row sgid*16+2kq+kpar, col tc*16+js*8+jl. Values/
                    // addresses identical by construction; WINDOW_BLOCK gate judges.
                    esimd::slm_block_store(scr + r2 * 32u * 2u, oh, esimd::overaligned_tag<16>{});
                    esimd::barrier();
                    if (lane < 4u) {
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
                        // B3-1 (K side): 16 x 4-BYTE scatter stores -> the same
                        // blade-7 wide form. pb16t_dest(r,c,2,4): tc=r>>4=sgid (the
                        // K side's rows are the token dim: nrow=r, k=c): block =
                        // (kc*4+sgid)*2+js, js=(r>>3)&1, elem = kq*16 + jl*2 + kpar
                        // <- scr row (sgid*16 + js*8 + jl), col kc*16 + kq*2 + kpar.
                        esimd::slm_block_store(scr + r2 * 32u * 2u, oh, esimd::overaligned_tag<16>{});
                        esimd::barrier();
                        if (lane < 4u) {   // 4 KT blocks per subgroup: kc(0..1) x js(0..1)
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
            // C5 BLADE (2026-11-08, lane-disjoint P3; audit s6/layer1.md 76, A/B定档 s6/c5_ab.cpp):
            // The old shape was SUBGROUP-UNIFORM: qb = S_QPO + sgid*1024 and bb = S_KTO + tc*512
            // carry NO lane term, so all 16 lanes of a subgroup loaded identical operands and
            // recomputed the whole 16x64 block 16 times (32 dpas + 20 SLM loads + 64 SLM stores
            // per lane). window_block was the ONLY dpas family in the engine written that way --
            // s8v8/ffn2/ffnc/att5/b6/wares all use per-thread disjoint tiles (see
            // gemm_s8_v8_kernel.hpp:772 "THREAD-LOCAL -- 32 disjoint 16x16 blocks").
            // A/B skeleton probe on the identical shape (same useful work, 2040 WGs, 3 procs/arm,
            // cold caches): uniform 0.2619 ms/launch vs lane-disjoint 0.0918 ms/launch
            // = -65.1 percent wall (static slots 36->2 dpas, 87->17 send.slm, 432->78 instr).
            // NEW SHAPE: each lane owns ONE 8x8 output tile --
            //   rowblk = lane&1 (rows 0-7 / 8-15 of the subgroup slab),
            //   colblk = lane>>1 (8 tiles of 8 cols) -- 2 x 8 = 16 tiles = the 16x64 block
            //   exactly once (no overlap, no gap: 16 lanes x 64 outputs = 1,024).
            // BIT-EXACTNESS: per output ELEMENT the K chain is untouched -- the engine's c00
            // accumulated dpas(b0 = cols 0..7,K 0..15 ; aq0 = rows 0..7,K 0..15) THEN
            // dpas(b2 = same cols,K 16..31 ; aq2 = same rows,K 16..31) into the SAME register
            // fragment. Here the same lane runs exactly those two steps for its own (rowblk,
            // colblk) pair with byte-identical operand slices (aq0/aq1 = K 0..15 of rows 0-7 /
            // 8-15 at qb+0/qb+256; aq2/aq3 = K 16..31 at qb+512/qb+768; b0/b1 = K 0..15 / 16..31
            // of col tile colblk at KA + (colblk>>1)*512 + (colblk&1)*256 and +2048).
            // Accumulator fragment layout = row*8+col (same as the old c00/c01/c10/c11), and the
            // SCR byte map is UNCHANGED: row*256B + col*4B (colblk*32B = tc*64B + (colblk&1)*32B)
            // => the stop_stage==5 scores dump (:253-266) and P4 (:268-311) read the same bytes
            // as before, and P4's row-sum order (c=0..63) is not touched at all.
            {
              uint qb = S_QPO + sgid*1024u;
              uint rowblk = lane & 1u, colblk = lane >> 1u;
              esimd::simd<half,128> aq0 = esimd::slm_block_load<half,128>(qb + rowblk*256u, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq1 = esimd::slm_block_load<half,128>(qb + 512u + rowblk*256u, esimd::overaligned_tag<16>{});
              uint bb = S_KTO + (colblk >> 1u)*512u + (colblk & 1u)*256u;
              esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(bb, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(bb + 2048u, esimd::overaligned_tag<16>{});
              esimd::simd<float,64> c(0.f);
              c = esimd::xmx::dpas<8, 8, float>(c, b0, aq0);   // K = 0..15  (engine step 1)
              c = esimd::xmx::dpas<8, 8, float>(c, b1, aq1);   // K = 16..31 (engine step 2)
              uint scr = S_SCR + sgid*SCR_SG;
              #pragma unroll
              for (int r = 0; r < 8; ++r)
                  esimd::slm_block_store(scr + (rowblk*8u + (uint)r)*256u + colblk*32u,
                                         c.template select<8,1>(r*8));   // 8-float block: no OWORD tag (no such overload)
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
            // C7 (lane-disjoint P5, 定档 s6/c7_p56.cpp PHASE=5: uniform 0.2009 vs disjoint 0.0966
            // ms/launch = -51.9 percent; static 37 dpas / 66 send.slm / 287 instr -> 4 / 18 / 94).
            // Subgroup block = 16 rows x 32 cols with K=64 = 8 tiles of 8x8 -> lanes 0..7 each take
            // one tile (rb = lane&1 rows, cb = lane>>1 cols), lanes 8..15 idle. Conservation:
            // 8 tiles x 4 dpas = 32 dpas = the old 2 tc x tile8ss(kb_n=4) = 32 dpas; outputs
            // 8 x 64 = 512 = 16 x 32 exactly once. K chain per element unchanged (kc = 0,1,2,3 of
            // 16 into the SAME fragment). Operand slices byte-identical to tile8ss:
            //   a = S_PPO + sgid*2048 + kc*512 + rb*256 ; b = S_VPO + (cb>>1)*512 + (cb&1)*256 + kc*1024
            // (tile8ss used bb = Bb + kc*tc_n*2*256 = kc*1024 bytes, b0 = bb, b1 = bb+256).
            // SCR byte map unchanged (row*128B + col*4B) => the stop_stage==8 dump and P6 read the
            // same bytes; PPO/VPO are untouched.
            if (lane < 8u) {
                uint rb = lane & 1u, cb = lane >> 1u;
                esimd::simd<float,64> c(0.f);
                #pragma unroll
                for (uint kc = 0; kc < 4u; ++kc)
                    c = esimd::xmx::dpas<8, 8, float>(c,
                        esimd::slm_block_load<half,128>(S_VPO + (cb>>1u)*512u + (cb&1u)*256u + kc*1024u, esimd::overaligned_tag<16>{}),
                        esimd::slm_block_load<half,128>(S_PPO + sgid*2048u + kc*512u + rb*256u, esimd::overaligned_tag<16>{}));
                uint scr = S_SCR + sgid*SCR_SG;
                #pragma unroll
                for (int r = 0; r < 8; ++r)
                    esimd::slm_block_store(scr + (rb*8u + (uint)r)*128u + cb*32u,
                                           c.template select<8,1>(r*8));   // 8-float block: no OWORD tag
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
            // C7 (lane-disjoint P6 outproj, 定档 s6/c7_p56.cpp PHASE=6: uniform 0.1536 vs disjoint
            // 0.0832 ms/launch = -45.8 percent; static 19 dpas / 50 send.slm / 241 instr -> 2 / 14 / 82).
            // Subgroup block = 16 rows x 32 cols with K=32 = 8 tiles of 8x8 -> lanes 0..7 one tile
            // each (rb = lane&1, cb = lane>>1), lanes 8..15 idle. Conservation: 8 tiles x 2 dpas =
            // 16 dpas = the old 2 tc x tile8s(kb_n=2) = 16 dpas; outputs 512 = 16 x 32 once.
            // Per-element K chain unchanged (kc 0 then 1 of 16 into the SAME fragment). Operand
            // slices byte-identical to tile8s: a = S_ATO + sgid*1024 + kc*512 + rb*256;
            // b = WprojPacked + (cb>>1)*256 + (cb&1)*128 + kc*(tc_n*2*128 = 512) halves.
            // SCR byte map unchanged => the stop_stage==9 dump and P7 read the same bytes.
            if (lane < 8u) {
                uint rb = lane & 1u, cb = lane >> 1u;
                const half* Wb = WprojPacked + (size_t)(cb >> 1u)*256u + (size_t)(cb & 1u)*128u;
                esimd::simd<float,64> c(0.f);
                #pragma unroll
                for (uint kc = 0; kc < 2u; ++kc)
                    c = esimd::xmx::dpas<8, 8, float>(c,
                        esimd::simd<half,128>(Wb + (size_t)kc*512u, esimd::overaligned_tag<16>{}),
                        esimd::slm_block_load<half,128>(S_ATO + sgid*1024u + kc*512u + rb*256u, esimd::overaligned_tag<16>{}));
                uint scr = S_SCR + sgid*SCR_SG;
                #pragma unroll
                for (int r = 0; r < 8; ++r)
                    esimd::slm_block_store(scr + (rb*8u + (uint)r)*128u + cb*32u,
                                           c.template select<8,1>(r*8));   // 8-float block: no OWORD tag
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

} // namespace wbv4
