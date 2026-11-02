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

// SLM map v2 (wb_slm 驻留刀, 45,056B -> 32,768B; 账与生命周期证明 = tools/wb_slm_layout.py)
// 旧 map v1（45,056B = AQO|QPO|KTO|VPO|ATO 各 4096 + PPO 8192 + SCR 16384）见 git HEAD。
// 0..4095            : VPO  连续 4096B 全局区（P5 的 wbv3::tile8ss B 侧步长写死 = kc*1024，不许拆）
// 4096+sgid*7168     : 每 sub-group 私有 7,168B 槽，四段：
//   S0 sg+0    2048B : accA(PH1..PH2_0 f32 part0) / QPO(PH2_0..P3) / PROBS(P4..P5)
//   S1 sg+2048 2048B : accB(PH1..PH2_1) / SCORES(P3..P4) / ATT(P5..P6A) / PROJ(P6B..P7)
//   S2 sg+4096 2048B : accC(PH1..PH2_2) / SCORES 续(P3..P4) / ATO(P6A..P6B) / HEAD-A(v4ph P7 head)
//   S3 sg+6144 1024B : AQO(P0..PH1) / KTO(PH2_1..P3)
//     ★ S3 只准放这两块：KTO 在 P3 被**别的 SG**读，而 P3..P6 之间没有 group_barrier
//       （只有 SG 级 esimd::barrier），所以更晚写同槽的东西（ATO 第一版放这儿 => 1301 全帧 MISMATCH）
//       都不许进 S3。要进 S3 必须先在 P3 之后补一个 group_barrier（那是另一把刀）。
// 只在栅栏点换租户；单位一律「字节」，half-index->byte 的 *2 只出现在表达式末尾一处（军规 25）。
constexpr uint SG_STRIDE=7168u, SG_BASE=4096u;
constexpr uint S_VPO=0u;                                       // 连续 4096B
constexpr uint S_AQO=6144u, S_KTO=6144u;                        // S3（见上：不许有晚写者）
constexpr uint S_ATO=5120u;                                    // S2 后半：全程只有本 SG 读写
constexpr uint S_ACCA=0u,  S_QPO=0u,  S_PROBS=0u;               // S0
constexpr uint S_ACCB=2048u, S_SCORES=2048u, S_SLAB=2048u, S_ATT=2048u, S_PROJ=2048u;  // S1
constexpr uint S_ACCC=4096u, S_HEADA=4096u;                     // S2 (S_SLAB 覆盖 S1+S2)
constexpr uint SLM_BYTES=SG_BASE+SG_STRIDE*4u;                  // = 32,768
static_assert(SLM_BYTES == 32768u, "wb_slm: 必须落在 32KB 占用崖内(<=32768)");
static_assert(S_SCORES + 4096u <= SG_STRIDE, "wb_slm: SCORES(4096B) 必须整段在 SG 槽内");
static_assert(S_PROBS + 2048u <= SG_STRIDE, "wb_slm: PROBS(2048B) 必须整段在 SG 槽内");
static_assert(S_KTO + 1024u <= SG_STRIDE, "wb_slm: KTO 必须在 S3 的 1024B 内");
static_assert(S_ATO >= S_ACCC && S_ATO + 1024u <= S_ACCC + 2048u, "wb_slm: ATO 必须在 S2 内(禁入 S3:KTO 跨 SG 读)");
static_assert(S_HEADA >= S_ACCC && S_HEADA + 1024u <= S_ACCC + 2048u, "wb_slm: HEAD-A 必须在 S2 内");

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
            esimd::slm_init<32768>();   // wb_slm: 见上面的 map（32,768B）
            uint window = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            uint sgid = lid >> 4, lane = lid & 15u;
            uint sbase = SG_BASE + sgid*SG_STRIDE;   // 本 SG 的 7,168B 槽起点
            auto sgb = [&](uint s) SYCL_ESIMD_FUNCTION { return SG_BASE + s*SG_STRIDE; };   // 跨 SG 读 KTO / 诊断 dump 用
            uint top = pad_top, left = pad_left;
            if (stop_stage == 0xFFFFu || stop_stage == 0xFFFEu) return;

            // ===== P0 gather (VERBATIM v3; rows already subgroup-owned) =====
            {
                uint t = lid;
                int y = (int)((window / window_cols) * 8u + (t >> 3)) - (int)top;
                int x = (int)((window % window_cols) * 8u + (t & 7u)) - (int)left;
                uint strip=(t>>3)&1u, il=t&7u;   // tr=t>>4 == sgid：已折进 sbase 的 S3 基址
                uint base1 = ((0u*2u+strip)*128u) + il*16u;   // 本 SG 的 A 块 0（half 单位）
                uint base2 = ((1u*2u+strip)*128u) + il*16u;   // 本 SG 的 A 块 1
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
                wbv3::sh16(sbase + S_AQO + base1*2u, oh.template select<16,1>(0).read());
                wbv3::sh16(sbase + S_AQO + base2*2u, oh.template select<16,1>(16).read());
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
            uint scrA = sbase + S_ACCA;   // S0
            uint scrB = sbase + S_ACCB;   // S1
            uint scrC = sbase + S_ACCC;   // S2（同槽后面装 PROBS）
            #pragma unroll
            for (uint part = 0; part < 3u; ++part) {
                uint scr = (part==0u)? scrA : (part==1u)? scrB : scrC;
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8s(c00,c01,c10,c11, sbase + S_AQO,
                             WqkvPacked + (size_t)(part*2u+0u)*256u, 2, 6);
                esimd::simd<float,64> d00(0.f),d01(0.f),d10(0.f),d11(0.f);
                wbv3::tile8s(d00,d01,d10,d11, sbase + S_AQO,
                             WqkvPacked + (size_t)(part*2u+1u)*256u, 2, 6);
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    // BLADE-3 (ISA ledger 1, 2026-10-29, twin of the bench win): merge the
                    // 16-wide m01+n01 (and m11+n11) stores -- they are the LEFT/RIGHT halves
                    // of the SAME 32-float row (row*128B and row*128B+64B). 32-wide single
                    // store: 96 -> 48 store.slm per call. Element values and select source
                    // order UNCHANGED -> bit-identical. Bench A/B 5/5 W (-0.021ms FULL).
                    esimd::simd<float,32> mrow;
                    mrow.template select<8,1>(0)  = c00.template select<8,1>(r*8);
                    mrow.template select<8,1>(8)  = c01.template select<8,1>(r*8);
                    mrow.template select<8,1>(16) = d00.template select<8,1>(r*8);
                    mrow.template select<8,1>(24) = d01.template select<8,1>(r*8);
                    esimd::simd<float,32> nrow;
                    nrow.template select<8,1>(0)  = c10.template select<8,1>(r*8);
                    nrow.template select<8,1>(8)  = c11.template select<8,1>(r*8);
                    nrow.template select<8,1>(16) = d10.template select<8,1>(r*8);
                    nrow.template select<8,1>(24) = d11.template select<8,1>(r*8);
                    esimd::slm_block_store(scr + (uint)r*32u*4u,      mrow);
                    esimd::slm_block_store(scr + (uint)(8+r)*32u*4u,  nrow);
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
                        uint strip=(r>>3)&1u, il=r&7u;   // tr=r>>4 == sgid：已折进 sbase
                        wbv3::sh16(sbase + S_QPO + (((0u*2u+strip)*128u) + il*16u)*2u,
                                   oh.template select<16,1>(0).read());
                        wbv3::sh16(sbase + S_QPO + (((1u*2u+strip)*128u) + il*16u)*2u,
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
                            esimd::slm_block_store(sbase + S_KTO + ((kc2 * 2u + js) * 128u) * 2u,
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
            // 新布局下 QPO/KTO 不再是连续 4096B 区（每 SG 一段），按逻辑字节序重映射读。
            auto dump_qpo = [&]() SYCL_ESIMD_FUNCTION {
                if (!DumpKV) return; half* d = DumpKV+(size_t)window*4096u;
                for (uint i=0;i<2048u;i+=64u) { uint e=i+lid;
                    d[e]=wbv3::lh16(sgb(e>>9u) + S_QPO + ((e*2u)&1023u))[0]; } };
            auto dump_kto = [&]() SYCL_ESIMD_FUNCTION {
                if (!DumpKV) return; half* d = DumpKV+(size_t)window*4096u;
                for (uint i=0;i<2048u;i+=64u) { uint e=i+lid; uint b=e*2u;
                    d[e]=wbv3::lh16(sgb((b>>9u)&3u) + S_KTO + (b>>11u)*512u + ((b>>8u)&1u)*256u + (b&255u))[0]; } };
            if (stop_stage == 10u) { dump_qpo(); return; }
            if (stop_stage == 11u) { dump_kto(); return; }
            if (stop_stage == 12u) { dump_region(S_VPO); return; }
            group_barrier(it.get_group());          // KTO/VPO shared for P3/P5

            // ===== P3 scores: rows owned, cols 0..63 =====
            // P8-f (section 100): the A tile (S_QPO + sgid*1024, kc 0..1) is the
            // SAME across all four tc blocks -- hoist to registers ONCE (4 x
            // simd<half,128> = the whole 2KB A row-block; tile8ss's A-side SLM
            // re-reads 4x vanish). Bench judges = the seven stage-dump regions,
            // all EXACT (bench_v4full); scores stage 0.333->0.289 ms/call.
            {
              uint qb = sbase + S_QPO;   // 本 SG 的 Q 面 1KB（S0 前 1KB）
              esimd::simd<half,128> aq0 = esimd::slm_block_load<half,128>(qb, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq1 = esimd::slm_block_load<half,128>(qb + 256, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq2 = esimd::slm_block_load<half,128>(qb + 512, esimd::overaligned_tag<16>{});
              esimd::simd<half,128> aq3 = esimd::slm_block_load<half,128>(qb + 768, esimd::overaligned_tag<16>{});
              for (uint tc = 0; tc < 4u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                uint bb = sgb(tc) + S_KTO;   // 逻辑 KTO 块 tc = SG tc 的 K 面（新布局：每 SG 1KB 连续）
                esimd::simd<half,128> b0 = esimd::slm_block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::slm_block_load<half,128>(bb + 256, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, b0, aq0);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, b1, aq0);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, b0, aq1);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, b1, aq1);
                esimd::simd<half,128> c0 = esimd::slm_block_load<half,128>(bb + 512, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> c1 = esimd::slm_block_load<half,128>(bb + 768, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8, 8, float>(c00, c0, aq2);
                c01 = esimd::xmx::dpas<8, 8, float>(c01, c1, aq2);
                c10 = esimd::xmx::dpas<8, 8, float>(c10, c0, aq3);
                c11 = esimd::xmx::dpas<8, 8, float>(c11, c1, aq3);
                uint scr = sbase + S_SLAB;
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
                // (scr = sbase + S_SLAB + row_in_block*stride); the dump's lid is a GLOBAL
                // row -- map it. (The judge was wrong, not the kernel: probs, computed
                // from these same scores, came out EXACT.)
                if (DumpKV) {
                    uint sg = lid >> 4, rr = lid & 15u;
                    uint scr = sgb(sg) + S_SLAB;
                    for (uint c = 0; c < 64; ++c)
                        DumpKV[(size_t)window*4096u + lid*64u + c] =
                            half(esimd::slm_block_load<float,1>(scr + (rr*64u+c)*4u)[0]);
                }
                return;
            }

            // ===== P4 softmax row-local (NO WGT round-trip) =====
            {
                uint scr = sbase + S_SLAB;
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
                uint strip=(r>>3)&1u, il=r&7u;   // tr=r>>4 == sgid：已折进 sbase
                wbv3::sh16(sbase + S_PROBS + (((0*2u+strip)*128u) + il*16u)*2u, oh0.template select<16,1>(0).read());
                wbv3::sh16(sbase + S_PROBS + (((1*2u+strip)*128u) + il*16u)*2u, oh0.template select<16,1>(16).read());
                wbv3::sh16(sbase + S_PROBS + (((2*2u+strip)*128u) + il*16u)*2u, oh1.template select<16,1>(0).read());
                wbv3::sh16(sbase + S_PROBS + (((3*2u+strip)*128u) + il*16u)*2u, oh1.template select<16,1>(16).read());
            }
            esimd::barrier();
            if (stop_stage == 6u) {   // probs map-dump (v3 stop=6 form)
                if (DumpKV) for (uint c = 0; c < 64; ++c)
                    DumpKV[(size_t)window*4096u + lid*64u + c] =
                        wbv3::lh16(sgb(lid>>4u) + S_PROBS + (wbv3::pa16_dest(lid,c,4u) - (lid>>4u)*1024u)*2u)[0];
                return;
            }

            // ===== P5 attnV rows-owned: 2 tiles per subgroup =====
            for (uint tc = 0; tc < 2u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8ss(c00,c01,c10,c11, sbase + S_PROBS, S_VPO + tc*512u, 4, 2);
                wbv3::store16s(sbase + S_SLAB + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            esimd::barrier();
            if (stop_stage == 8u) {   // attended rows (v3 stop=8 form: f32->half)
                uint sg = lid >> 4, rr = lid & 15u;
                uint scr = sgb(sg) + S_SLAB;
                if (DumpKV) for (uint c = 0; c < 32; ++c)
                    DumpKV[(size_t)window*4096u + lid*32u + c] =
                        half(esimd::slm_block_load<float,1>(scr + (rr*32u+c)*4u)[0]);
                return;
            }

            // ===== P6 attended->ATO (owned rows), outproj rows-owned =====
            {
                uint scr = sbase + S_SLAB;
                uint r2 = lane, r = sgid*16u + lane;
                esimd::simd<float,32> cv = esimd::slm_block_load<float,32>(scr + r2*32u*4u, esimd::overaligned_tag<16>{});
                esimd::simd<half,32> oh = esimd::convert<half>(wbv3::e4m3_vec<32>(cv));
                uint strip=(r>>3)&1u, il=r&7u;   // tr=r>>4 == sgid：已折进 sbase
                wbv3::sh16(sbase + S_ATO + (((0*2u+strip)*128u) + il*16u)*2u, oh.template select<16,1>(0).read());
                wbv3::sh16(sbase + S_ATO + (((1*2u+strip)*128u) + il*16u)*2u, oh.template select<16,1>(16).read());
            }
            esimd::barrier();
            for (uint tc = 0; tc < 2u; ++tc) {
                esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);
                wbv3::tile8s(c00,c01,c10,c11, sbase + S_ATO, WprojPacked + (size_t)tc*256u, 2, 2);
                wbv3::store16s(sbase + S_SLAB + tc*16u*4u, 32, c00,c01,c10,c11);
            }
            esimd::barrier();
            if (stop_stage == 9u) {   // projected rows (v3 stop=9 form)
                uint sg = lid >> 4, rr = lid & 15u;
                uint scr = sgb(sg) + S_SLAB;
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
                    proj = esimd::slm_block_load<float,32>(sbase + S_SLAB + r2*32u*4u, esimd::overaligned_tag<16>{});
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
