// s6_ffn_block4.cpp -- the MIXED-CHAIN shovel (M1/M2/M3) of notes/s6-mixed-chain-spec.md.
// It is a COPY of s6_ffn_block3.cpp (the untouched 1a chain, 13 checkpoints green, MD5
// 4299658C3BA412E06D6BD4CDD21D8A85 at the moment of copying). block3 stays on disk as the
// control; ONLY this file moves. bench layer only: no shipped source touched, no wiring.
//
//   M1  P4 (contract/proj) becomes the PORT kernel's deep-K form: one work-item = one of their
//       waves = one 16x16 output tile = 4 dpas per kb, the WHOLE K in one ascending chain, A =
//       the SLM hidden int8 in fragment order, B = 512B fragment blocks, scales in the epilogue
//       (port_ffn_fused.cpp PHASE 3 :401-446 == their :79-98; port-B.md R4). NO split-K any more
//       in P4, so P4's SLM staging and its two extra barriers disappear.
//       FORBIDDEN ZONE respected: P1/P2 untouched (1a wins the shallow-K expand 4.4x).
//   M2  the T1a whole-row peak folds into P2's epilogue (register-local row peak per wave +
//       SLM max slots), so P3 keeps ONE pass (the encode) instead of two.
//   M3  the ledger red line: grf=128 with private/spill/scratch = 0 (what the port kernel failed
//       at: 3328/6464B private + 61/182 scratch instructions).
//
// ENTRY TICKET (never relaxed): every phase output must be BYTE-IDENTICAL to block3.
//   * the 9 chain taps (pk1/sc1/hid/pk2/sc2/out1275/pk3/sc3/1267-FINAL) are diffed BOTH against
//     the live split control (as block3 does) AND against block3's own reference blob
//     E:/DSH/s6/c2ref_<shape>.bin ("B3GATE" below);
//   * the ffn3 (R1 zero-pack) leg keeps its 13-checkpoint gate against the same blob.
//   This file writes its OWN reference as c4ref_<shape>.bin -- block3's c2ref is read-only here.
//
// FRAME CENSUS CORRECTION (plan_960x544.c captured region 5308..6643, this file's run):
// the "36 chains" figure counts only BATCHED ops. The FFN closures are actually
//   F1  6-op int8  C=64  M=32640  x8   (5340..5417 + 6xxx mirror)  = stage-1 shape  [S1]
//   F1  6-op int8  C=128 M=8160   x12 (5434..5552 + 6xxx mirror)                   [S2]
//   F2  5-op f16   C=256 M=2040   x16: QUANT -> BATCHED expand -> OP_XMX_REC_GEMM
//        (f16 proj, gemm_b_pub_f16 fold DEFAULT ON :2296/2303) -> QUANT -> RESIDUAL.
//        NO middle int8 requant of 1274 -- the f16 proj reads the hidden plane RAW.  [S3]
//   F3  7-op mixed C=512 M=640 x16 (GEMM_INT8 + GEMM_F16 + BATCHED...) -- NOT built
//        this stage; reported as census only.
// batched total: 2*8 + 2*12 + 16 + 16 = 72 (census opcounts-graphonly:72) CHECK.
//
// (A) SPLIT-K BIT-EXACTNESS PROOF (int32 accumulator phases ONLY -- P4/P6/P5res):
//   acc = SUM_{k=0..K-1} a_k*b_k with |a_k|,|b_k| <= 127 (the quant grid clips +-127)
//     => |acc| <= K * 127^2 = K * 16129.
//     S1 P4 K=256 -> 4,129,024 | S1 P6 K=64 -> 1,032,256
//     S2 P4 K=512 -> 8,258,048 | S2 P6 K=128 -> 2,064,512
//     S3 P5 K=256 -> 4,129,024   all << 2^31-1 = 2,147,483,647.
//   No overflow => every partial sum is an EXACT integer => integer addition is
//   associative and commutative over this range => ANY fixed grouping of the kb loop
//   gives a bit-identical int32 result vs the shipped sequential loop.
//   REDUCE ORDER FIXED BY INDEX ARITHMETIC (not scheduling): the ks==0 owner accumulates
//   its own fragment then slots ks=1..KS-1 in ASCENDING ks; every run computes the same
//   order. If anyone changes K or the int8 grid width, RE-CHECK the bound formula above.
//   *** The f16-proj phase of F2/S3 accumulates in FLOAT (f32 add is NOT associative) --
//   split-K there is ILLEGAL for bit-exactness; P3f keeps the shipped sequential kc
//   order (TS=16 steps, kc ascending, VERBATIM from f16v1::gemm_b_pub_f16). ***
//
// (B) OCCUPANCY-FIRST per-phase thread maps (active threads are COMPILE-TIME constants,
//   printed with the bisection; each phase's map chosen so active == 64 where possible):
//     P2 expand : (T/8) x (HID/16)                     S1 4x16=64  S2 2x32=64  S3 1x64=64
//     P4 proj8  : M1 = the port contract map (T/16) x (C/16), NO split-K
//                                                     S1 2x4=8    S2 1x8=8
//       (the old 1a map was (T/8) x (C/16) x KS4 = 64 active with split-K + SLM staging; the
//        port form trades thread count for a 4-accumulator deep chain, and the port measured
//        39.6/55.2 TOPS with it vs 1a's 28.0 -- spec M1. The TOTAL dpas count per chain is
//        unchanged: 261,120/chain, and so is the active-thread TOTAL across the frame:
//        S1 1020 WG x 8 = 8160 = the port kernel's own thread count.)
//     P3f proj16: (T/16) x (C/16)                      S3 1x16=16  <-- f32 acc forbids
//                split-K: the underfill is STRUCTURAL at M=2040, reported honestly.
//     P6 res    : (T/8) x (C/8)   x KS6                S1 4x8x2=64 S2 2x16x2=64 S3 1x32x2=64
//   split-K staging aliases DEAD SLM regions (PKH+HIDF after the kb loop; HIDF for S3).
//   M1: P4 needs no staging at all (STG4 = 0); P6 still stages (KS6).
//
// (D) DEATH LINE (agreed): at stage-2 end, if the frame-36-chain serial conversion
//   (8*dS1 + 12*dS2 + 16*dS3, wall msM basis) is NOT beyond -5ms, S6-1a in this form is
//   declared not-worth-it and we pivot to porting the P2 expand form (24.7 TFLOP/s)
//   standalone into shipped batched sites. No third shape hunting.
//   (Not this shovel's criterion: the mixed chain is judged against S1 <= 0.33 / S2 <= 0.30.)
//
// TIMING: gemm32_tile TRAP 1-9 protocol verbatim (5 groups x 15 reps, 60ms gaps;
// msm/msM/msX/med). Legs: host wall (launches included -- fusion's prize).
// Build: cd src/bench/sycl && bash E:/DSH/bench.sh s6_ffn_block4.cpp s6_ffn_block4.exe
// Run per shape in its OWN process: C2_SHAPE=1 (S1 C=64 M=32640) | 2 (S2 C=128 M=8160);
// C2_STAGE=1 (split control + ffn2 gates + pricing) then C2_STAGE=2 (ffn3 13-checkpoint gate).
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include <thread>
#include <chrono>
#include <utility>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"  // f16v1::gemm_b_pub_f16 (the shipped F2 proj fold)
#include "pack_device.hpp"
#include "quantize_row_kernel.hpp"
using namespace sycl;

// ============================ M-SHOVEL switches (compile-time; the sweep rebuilds per rung) ====
// M_P4FORM  -- the M1 contract form:
//   0 = the shipped-equivalent 1a map: (T/8) x (C/16) x KS4 split-K, 64 active, SLM staging
//       (the block3 CONTROL; it is what the ledger says is private/spill/scratch = 0)
//   1 = the PORT's faithful wave: one 16x16 tile = FOUR dpas per kb, the WHOLE K in one
//       ascending chain, A = SLM int8 fragment order, scales in the epilogue
//       (port_ffn_fused.cpp PHASE 3 :401-446 == their :79-98). 8 active threads.
//   2 = the same deep-K contract at 8 tokens x 16 cols (TWO accumulators). 16 active.
//   3 = the same deep-K contract at 8 tokens x  8 col (ONE accumulator).  32 active.
//   M1's measured fact: form 1 SPILLS on S1 (private 2048/2304B + 35-43 scratch instructions in
//   the nosink pricing kernel) and costs 0.4425ms = 2.4 TOPS. Forms 2/3 are the spec's own
//   remedy ("累加器压力 ... => 减活 simd 数量"); they keep the deep K (no split-K, no staging,
//   no extra barrier, fragment-order A, epilogue scales) and only shrink the tile height.
// M_PEAK -- the M2 switch: 0 = block3's two-pass P3 (scan peak, scan encode);
//   1 = the row peak folded into P2's epilogue (register-local peak per wave + SLM max slots),
//       P3 keeps only the encode pass.
#ifndef M_P4FORM
#define M_P4FORM 1
#endif
#ifndef M_PEAK
#define M_PEAK 0
#endif
// M_P3SPLIT -- M2b: spread the ONE remaining P3 encode pass over 64/T threads PER ROW
//   (S1 T=32 -> 2 parts, S2 T=16 -> 4 parts). Requires M_PEAK=1: each part recomputes the SAME
//   row scale from the SAME peak slots (a 64/128B vector load + hmax + ONE ieee divide) instead
//   of paying a barrier to hand it over, and quantizes a DISJOINT ascending kb range of the row.
//   The quantization of one element depends only on (value, row scale), and the pkH store map is
//   keyed by (kb,row), so the bytes cannot differ from the one-thread-per-row version.
//   0 = the block3 shape (one thread per row).
#ifndef M_P3SPLIT
#define M_P3SPLIT 0
#endif
#if M_P3SPLIT && !M_PEAK
#error "M_P3SPLIT needs M_PEAK (the peak comes from the P2 slots; scanning the row per part would defeat the point)"
#endif
// M_BAR -- the phase-boundary barrier INSTRUCTION (a discriminator, not a feature):
//   0 = esimd::barrier()  -- the shipped 1a form: __esimd_fence(global_coherent|local_barrier)
//       THEN __esimd_barrier() (memory.hpp:12037-12048). The fence sits on the ENTRY side only:
//       it gives RELEASE ordering for this thread's own stores, but there is no ACQUIRE after the
//       barrier, so a thread that crosses it can still read a local-memory line another thread
//       wrote -- the prime suspect for the one-off S2 corruption (s6/port_M.md, M-FLAKY).
//   1 = sycl::group_barrier(it.get_group()) -- the PORT kernel's form (port_ffn_fused.cpp:347/357/
//       401/440, "R5: never bypassed by a conditional"), which the SYCL front end lowers with full
//       local-memory acquire+release.
#ifndef M_BAR
#define M_BAR 0
#endif
#if M_BAR
#define MBAR(gr) sycl::group_barrier(gr)
#else
#define MBAR(gr) esimd::barrier()
#endif

// ============================ fused block kernel (stage 2) ============================
namespace ffn2 {
template <int T_, int C_, int HID_, bool F16PROJ_, int KS4_, int KS6_,
          int P4F_ = M_P4FORM, int PEAK_ = M_PEAK, int SPLIT_ = M_P3SPLIT, int BAR_ = M_BAR>
struct Shape {
    static constexpr int T = T_, C = C_, HID = HID_;
    static constexpr bool F16PROJ = F16PROJ_;
    static constexpr int KS4 = KS4_, KS6 = KS6_;
    // The four M-shovel switches are ALSO template parameters, so they reach the MANGLER:
    // with macro-only switches base / m2b / m2c share one mangled name and the JIT-cache ledger
    // (s6/spillcheck_M.py) cannot tell which binary a private/scratch row belongs to -- exactly
    // the ambiguity the M3 red line must not have.
    static constexpr int P4FORM = P4F_, PEAKF = PEAK_, P3SPLITF = SPLIT_, BARF = BAR_;
    static_assert(P4FORM == M_P4FORM && PEAKF == M_PEAK && P3SPLITF == M_P3SPLIT && BARF == M_BAR,
                  "the Shape parameters must mirror the compile-time switches");
    static constexpr int BANDS = (T_ + 15) / 16;               // 16-row pk bands (zero-padded tail)
    static constexpr int KB_C = C_ / 32, KB_H = HID_ / 32;     // int8 pk kb blocks
    static constexpr int KBN4 = HID_ / 32, KBN6 = C_ / 32;     // kb loops for proj/res
    static constexpr uint32_t SZ_PK  = (uint32_t)(KB_C * BANDS * 512);
    static constexpr uint32_t SZ_PKH = F16PROJ_ ? 0u : (uint32_t)(KB_H * BANDS * 512);
    // int8-proj: hidden row-major T x HID f16. f16-proj: compact f16v1 strip0 map
    // (kc block x 8 rows x 16 halfs) = HID*16 bytes.
    static constexpr uint32_t SZ_HID = F16PROJ_ ? (uint32_t)(HID_ * 16) : (uint32_t)(T_ * HID_ * 2);
    static constexpr uint32_t SZ_OUT = (uint32_t)(T_ * C_ * 2);
    static constexpr uint32_t SZ_SC  = 3u * 128u;             // scA@+0 | scH@+128 | scO@+256 (T<=32 floats each)
    static constexpr uint32_t O_PKH = 0, O_PK = SZ_PKH;
    static constexpr uint32_t O_HID = O_PK + SZ_PK, O_OUT = O_HID + SZ_HID, O_SC = O_OUT + SZ_OUT;
    static constexpr uint32_t SLM = ((O_SC + SZ_SC + 15u) / 16u) * 16u;
    // staging for split-K partials, aliased onto regions DEAD in that phase:
    //   int8-proj family: PKH+PK+HIDF are all dead once the P4 kb loop drains (barrier);
    //   f16-proj family (S3): PK is LIVE during P6 -> stage in HIDF (dead after P3f).
    // M1: the deep-K contract forms carry the WHOLE K in one ascending kb chain per wave, so P4
    // needs NO split-K staging at all (STG4 = 0). Only P6 still stages (KS6).
#if M_P4FORM == 0
    static constexpr uint32_t STG4 = (uint32_t)((KS4_ - 1) * T_ * C_ * 4);
#else
    static constexpr uint32_t STG4 = 0u;
#endif
    static constexpr uint32_t STG6 = (uint32_t)((KS6_ - 1) * T_ * C_ * 4);
    static constexpr uint32_t O_STG = F16PROJ_ ? O_HID : O_PKH;
    static_assert(!F16PROJ_ || T_ == 8, "f16-proj compact HIDF map is written for T=8 only");
    static_assert(STG4 <= SZ_PKH + SZ_PK + SZ_HID, "P4 staging exceeds the dead SLM span");
    static_assert(STG6 <= (F16PROJ_ ? SZ_HID : SZ_PKH + SZ_PK + SZ_HID), "P6 staging exceeds the dead SLM span");
    // active threads per phase (compile-time; printed by the host):
    static constexpr int ACT2 = (T_ / 8) * (HID_ / 16);
    // f16-proj: one 16-row pack band covers T=8 (strip0), col bands C/16, NO split-K (f32 acc).
#if M_P4FORM == 0
    static constexpr int ACT4 = F16PROJ_ ? (C_ / 16) : ((T_ / 8) * (C_ / 16) * KS4_);
#elif M_P4FORM == 1
    static constexpr int ACT4 = (T_ / 16) * (C_ / 16);       // the port map: S1 2x4=8, S2 1x8=8
#elif M_P4FORM == 2
    static constexpr int ACT4 = (T_ / 8) * (C_ / 16);        // S1 4x4=16, S2 2x8=16
#else
    static constexpr int ACT4 = (T_ / 8) * (C_ / 8);         // S1 4x8=32, S2 2x16=32
#endif
    static constexpr int ACT6 = (T_ / 8) * (C_ / 8) * KS6_;
    static constexpr int ACT3 = (M_P3SPLIT != 0) ? 64 : T_;   // M2b: the P3 row split fills the WG
    static constexpr int NPH  = F16PROJ_ ? 5 : 6;
#if M_PEAK
    // M2: the P2-epilogue row-peak slots. ONE slot per (row, 16-column block) = T x (HID/16)
    // floats = 2048B for BOTH shapes (S1 32x16x4, S2 16x32x4), ALIASED onto the OUT region, which
    // is dead from the chain start until P4 writes it (P3 never touches OUT) => the SLM request,
    // the slm_size BUCKET and the resident-WG count stay exactly as they are (31744B), and the
    // spec's budget ("<= 16 rows x HID/64 x 4B") is met by a wide margin because the increment is
    // ZERO bytes, not 256/512.
    // Why HID/16 slots instead of the spec's HID/64: their expand wave owns 64 hidden columns
    // (4 tiles of 16 -- port_ffn_fused.cpp:297-300), so HID/64 = one writer per slot THERE. Our
    // P2 wave owns 16 columns and must stay there (M1's forbidden zone: 1a wins the shallow-K
    // expand 4.4x, 64 active threads). HID/64 slots with our 16-column waves would put 4 threads
    // into a non-atomic read-modify-write of one SLM float = a LOST update (wrong peak => diff!=0).
    // HID/16 gives exactly ONE writer per slot: race-free, no atomics, no extra barrier.
    static constexpr int      CB2     = HID_ / 16;
    static constexpr uint32_t O_PEAK  = O_OUT;
    static constexpr uint32_t SZ_PEAK = (uint32_t)T_ * CB2 * 4u;
    static_assert(SZ_PEAK <= SZ_OUT, "M2 peak slots must alias the dead OUT region");
#endif
};

struct Args {
    const half* dIn; half* dOut;
    const int8_t* Bexp;    const float* bsExp;    // expand, wide-N packed (pack_b of N=HID x K=C)
    const int8_t* Bproj;   const float* bsProj;   // int8 wide diag pack (Nw=C x Kw=HID); unused for F16PROJ
    const half*   BprojH;  // f16v1 packed per-group (K x N), F16PROJ only
    const int8_t* Bres;    const float* bsRes; const float* cos;
    int M, NP;             // NP = proj groups for F16PROJ (b_p), else ignored
    // DUMP scratch:
    int8_t* dpk1; float* dsc1; half* dHid; int8_t* dpk2; float* dsc2;
    half* dOut1275; int8_t* dpk3; float* dsc3;
    // C2: R1 producer outputs (the fragment-order input face + its row scales) and the
    // fragment-order taps of the chain-internal pk planes (the pk2-frag / pk3-frag checkpoints).
    const int8_t* face; float* scA; int8_t* dpk2frag; int8_t* dpk3frag;
    // C2 NARROW anti-DCE probe (military rule 19: the probe must be NARROW -- 4 int32 lanes per
    // thread per phase, NOT the 64-wide fragment materialization that cost the port kernel +65%).
    // SINK=0 (the default) compiles these stores away entirely.
    int32_t* probe;
};

template <class S, bool DUMP, int NPHASE, int SINK = 0>
static sycl::event fused(sycl::queue& q, const Args& a) {
    namespace esimd = sycl::ext::intel::esimd;
    constexpr int T = S::T, C = S::C, HID = S::HID;
    constexpr int BANDS = S::BANDS;
    const int nblk = a.M / T;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)nblk * 64), range(64)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<S::SLM>();
            const int blk = (int)it.get_group(0), t = (int)it.get_local_id(0);
            const int r0 = blk * T;            // M_BAR: the group handle the phase barriers need when M_BAR=1 (sycl::group_barrier)
            auto gr = it.get_group();
            // C2 narrow sink: one 16B store per thread per phase, placed at the phase tail AFTER
            // that phase's own SLM/global stores (so it lengthens no live range past the phase).
            auto sink4 = [&](int ph, const esimd::simd<int32_t,4>& z) SYCL_ESIMD_FUNCTION {
                if constexpr (SINK & 1)
                    esimd::block_store<int32_t,4>(a.probe +
                        ((((size_t)ph*(size_t)nblk + (size_t)blk)*64 + (size_t)t)*4u), z,
                        esimd::overaligned_tag<16>{});
            };

            // ---- P1: in quant (rowthread VERBATIM, K=C) -> pk band map + scA ----
            if (t < T) {
                esimd::simd<half,C> h = esimd::block_load<half,C>(a.dIn + (size_t)(r0+t)*C, esimd::overaligned_tag<16>{});
                esimd::simd<float,C> f = esimd::convert<float>(h);
                float peak = esimd::hmax<float,float,C>(esimd::abs(f));
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::slm_block_store(S::O_SC + (uint32_t)t*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                esimd::simd<float,C> qq = esimd::div_ieee<float,C>(f, esimd::simd<float,C>(scale));
                qq = esimd::min(esimd::max(esimd::rnde<float,C>(qq), esimd::simd<float,C>(-127.f)), esimd::simd<float,C>(127.f));
                esimd::simd<int8_t,C> o = esimd::convert<int8_t>(esimd::convert<int>(qq));
                for (int kb = 0; kb < S::KB_C; ++kb) {
                    esimd::simd<int8_t,32> seg = o.template select<32,1>(kb*32);
                    esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(t>>4))*512u + (uint32_t)(t&15)*32u,
                                                      seg, esimd::overaligned_tag<16>{});
                    if (DUMP) esimd::block_store<int8_t,32>(a.dpk1 + (size_t)(r0+t)*C + kb*32, seg, esimd::overaligned_tag<16>{});
                }
                // zero the band-tail rows (T < BANDS*16): row t+BAND-loops... only S3 hits this (T=8).
                for (int rr = T + t; rr < BANDS*16; rr += T)
                    if (rr < BANDS*16)
                        for (int kb = 0; kb < S::KB_C; ++kb)
                            esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(rr>>4))*512u + (uint32_t)(rr&15)*32u,
                                                              esimd::simd<int8_t,32>((int8_t)0), esimd::overaligned_tag<16>{});
                {   // C2 narrow sink for P1 (pins the quant math; 4 lanes, 16B/thread)
                    esimd::simd<int8_t,4> q4 = o.template select<4,1>(0);
                    esimd::simd<int32_t,4> z = esimd::convert<int32_t>(q4);
                    sink4(1, z + esimd::simd<int32_t,4>((int32_t)scale));
                }
                if (DUMP) a.dsc1[r0+t] = scale;
            }
            MBAR(gr);
            if (NPHASE <= 1) return;

            // ---- P2: expand gemm (T x HID wide-N, K=C, epi3) -> hidden f16 ----
            {
                const int rb = t / (HID/16), cb = t % (HID/16);
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = 0; kb < S::KB_C; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u + (uint32_t)(rb&1)*256u,
                                                           esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(HID*32) + (size_t)cb*512, esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(HID*32) + (size_t)cb*512 + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                {   // C2 narrow sink for P2 (pins BOTH dpas chains; accumulators already live here)
                    esimd::simd<int32_t,4> zA = c00.template select<4,1>(0);
                    esimd::simd<int32_t,4> zB = c01.template select<4,1>(0);
                    sink4(2, zA + zB);
                }
                esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsExp + cb*16, esimd::overaligned_tag<16>{});
                esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<int32_t,16> acc(0);
                    acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                    float rs = rss[r];
                    esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(3u, esimd::convert<float>(acc) * rs * cs);
                    esimd::simd<half,16> hh = esimd::convert<half>(pub);   // NAMED once: double-eating
                    if (S::F16PROJ)   // compact f16v1 strip0 map: kc=cb block, row r, 16 halfs
                        esimd::slm_block_store<half,16>(S::O_HID + (uint32_t)cb*256u + (uint32_t)r*32u,
                                                        hh, esimd::overaligned_tag<16>{});
                    else
                        esimd::slm_block_store<half,16>(S::O_HID + (uint32_t)(rb*8 + r)*HID*2u + (uint32_t)cb*32u,
                                                        hh, esimd::overaligned_tag<16>{});
                    if (DUMP && S::F16PROJ)   // register-direct twin (robust vs SLM map aliasing)
                        esimd::block_store<half,16>(a.dHid + (size_t)(r0 + rb*8 + r)*HID + cb*16,
                                                    hh, esimd::overaligned_tag<16>{});
#if M_PEAK
                     if constexpr (!S::F16PROJ) {
                        // ---- M2: the T1a row peak folded into the EXPAND epilogue.
                        // This wave owns one 16-column block of row (rb*8+r); its local peak comes
                        // straight out of the registers it already holds (NO extra SLM read), and it
                        // publishes into slot (row, cb) of the peak plane -- exactly ONE writer per
                        // slot, so there is no read-modify-write and nothing to make atomic.
                        // The peak is taken over hh = the f16-ROUNDED published value, i.e. AFTER the
                        // f16 rounding, which is the same number the old P3 first pass loaded back out
                        // of SLM. float max is associative AND commutative over finite values, so
                        // maxing the CB2 slots in P3 == the old left-to-right row scan, bit for bit.
                        esimd::simd<float,16> pa = esimd::abs(esimd::convert<float>(hh));
                        float lp = esimd::hmax<float,float,16>(pa);
                        esimd::slm_block_store(S::O_PEAK + (uint32_t)((rb*8 + r)*S::CB2 + cb)*4u,
                                               esimd::simd<float,1>(lp), esimd::overaligned_tag<16>{});
                     }
#endif
                }
            }
            MBAR(gr);
            if (DUMP) {
                if (t < T && !S::F16PROJ) {   // S1/S2: row-major twin straight from SLM
                    for (int c = 0; c < HID/16; ++c)
                        esimd::block_store<half,16>(a.dHid + (size_t)(r0+t)*HID + c*16,
                            esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)t*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                            esimd::overaligned_tag<16>{});
                }
                MBAR(gr);
            }
            if (NPHASE <= 2) return;

            if (!S::F16PROJ) {
                // ---- P3: hidden requant -> pkH + scH.
                // M2  (M_PEAK=1)   : the peak scan disappears -- P2's epilogue published one slot
                //                    per (row, 16-column block); maxing the slots == maxing the row.
                // M2b (M_P3SPLIT=1): the ONE remaining encode pass is spread over 64/T threads per
                //                    row (S1 2, S2 4). Each part recomputes the SAME scale from the
                //                    SAME slots (a 64/128B vector load + hmax + ONE ieee divide --
                //                    cheaper than a barrier and it needs no cross-thread ordering),
                //                    and quantizes a DISJOINT ascending kb range of the row. One
                //                    element's int8 depends only on (value, row scale) and the pkH
                //                    store map is keyed by (kb,row) => the bytes cannot differ.
                {
                    constexpr int SPLIT3 = (M_P3SPLIT != 0) ? (64 / T) : 1;
                    const int p3r = t / SPLIT3, p3p = t % SPLIT3;
                    if (t < T*SPLIT3) {
#if M_PEAK
                        esimd::simd<float,S::CB2> mx = esimd::slm_block_load<float,S::CB2>(
                            S::O_PEAK + (uint32_t)p3r*(S::CB2*4u), esimd::overaligned_tag<16>{});
                        float peak = esimd::hmax<float,float,S::CB2>(mx);
#else
                        esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                        for (int c = 0; c < HID/16; ++c) {
                            esimd::simd<half,16> h = esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)p3r*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{});
                            mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                        }
                        float peak = esimd::hmax<float,float,16>(mx);
#endif
                        const float scale = (peak == 0.0f) ? 1.0f
                            : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                        if (p3p == 0)
                            esimd::slm_block_store(S::O_SC + 128u + (uint32_t)p3r*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                        esimd::simd<int32_t,4> acc3(0);
                        const int kb0 = p3p * (S::KB_H / SPLIT3), kb1 = (p3p + 1) * (S::KB_H / SPLIT3);
                        for (int kb = kb0; kb < kb1; ++kb) {
                            esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_HID + (uint32_t)p3r*(HID*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                            esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                            q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                            esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                            esimd::slm_block_store<int8_t,32>(S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(p3r>>4))*512u + (uint32_t)(p3r&15)*32u, o, esimd::overaligned_tag<16>{});
                            { esimd::simd<int8_t,4> o4 = o.template select<4,1>(0); acc3 = acc3 + esimd::convert<int32_t>(o4); }
                            if (DUMP) esimd::block_store<int8_t,32>(a.dpk2 + (size_t)(r0+p3r)*HID + kb*32, o, esimd::overaligned_tag<16>{});
                        }
                        sink4(3, acc3 + esimd::simd<int32_t,4>((int32_t)scale));
                        if (DUMP && p3p == 0) a.dsc2[r0+p3r] = scale;
                    }
                }
                MBAR(gr);
                if (NPHASE <= 3) return;

                // ---- P4: the contract. M1 sweep switch M_P4FORM:
                //      0 = the 1a CONTROL (block3 verbatim): (T/8)x(C/16)xKS4 split-K + SLM staging
                //      1 = the PORT's faithful wave: 16x16 tile = 4 accumulators, whole K
                //      2 = deep-K contract at 8 tokens x 16 cols  (2 accumulators)
                //      3 = deep-K contract at 8 tokens x  8 cols  (1 accumulator)
                // Forms 1/2/3 all keep the port's CONTRACT SHAPE (port_ffn_fused.cpp PHASE 3
                // :401-446 == their :79-98, port-B.md R4):
                //   * the WHOLE K (= HID) in ONE ascending kb chain: no split-K, no SLM staging of
                //     partials, no extra barrier;
                //   * A = the SLM hidden int8 in FRAGMENT order (the 512B block = 16 tokens x 32K;
                //     its two 256B halves = band rows 0..7 / 8..15) -- their R4 "SLM int8 当 A";
                //   * B = the same 512B fragment blocks of the wide proj pack (their R2); the block
                //     ORDER stays 1a's kb-major (kb*(C*32)+cb*512) instead of their col-major, which
                //     is a pure permutation of the SAME blocks: identical operand bytes per
                //     accumulator, so no new pack and no numeric change;
                //   * the scales ride the EPILOGUE exactly as the shipped 1a tail did:
                //     pub_vec_v8(1u, acc*scH*bsProj) -> f16 -> the SLM OUT plane (1275 twin intact).
                // BIT-EXACTNESS vs form 0: every int32 partial is exact (header proof, lines 16-27),
                // so one full-K chain and the ascending-ks partial sum are the same byte string.
                {
#if M_P4FORM == 0
                    constexpr int CB4 = C/16;
                    const int cb4 = t % CB4; int u = t / CB4;
                    const int ks = u % S::KS4, rb = u / S::KS4;   // (T/8)*CB4*KS4 == 64
                    const int kb0 = ks * (S::KBN4 / S::KS4), kb1 = (ks+1) * (S::KBN4 / S::KS4);
                    esimd::simd<int8_t,256> a0, b0, b1;
                    esimd::simd<int32_t,64> c00(0), c01(0);
                    for (int kb = kb0; kb < kb1; ++kb) {
                        a0 = esimd::slm_block_load<int8_t,256>(S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u + (uint32_t)(rb&1)*256u, esimd::overaligned_tag<16>{});
                        b0 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(C*32) + (size_t)cb4*512, esimd::overaligned_tag<16>{});
                        b1 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(C*32) + (size_t)cb4*512 + 256, esimd::overaligned_tag<16>{});
                        c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                    }
                    {   // C2 narrow sink for P4 (contract; pins both dpas chains, accumulators live)
                        esimd::simd<int32_t,4> zA = c00.template select<4,1>(0);
                        esimd::simd<int32_t,4> zB = c01.template select<4,1>(0);
                        sink4(4, zA + zB);
                    }
                    MBAR(gr);   // all PKH reads done; staging may now alias PKH/PK/HIDF
                    constexpr uint32_t TILE4 = (uint32_t)((S::KS4 - 1) * 512u);   // 8 rows x 16 int32
                    const uint32_t slotbase = S::O_STG + (uint32_t)(rb*CB4 + cb4) * TILE4;
                    if (ks > 0) {
                        const uint32_t slot = slotbase + (uint32_t)(ks - 1) * 512u;
                        for (int r = 0; r < 8; ++r) {
                            esimd::simd<int32_t,16> acc(0);
                            acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                            acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                            esimd::slm_block_store<int32_t,16>(slot + (uint32_t)r*64u, acc, esimd::overaligned_tag<16>{});
                        }
                    }
                    MBAR(gr);
                    if (ks == 0) {
                        esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb4*16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{}); // row scale = scH
                        for (int r = 0; r < 8; ++r) {
                            esimd::simd<int32_t,16> acc(0);
                            acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                            acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                            for (int kk = 1; kk < S::KS4; ++kk)
                                acc = acc + esimd::slm_block_load<int32_t,16>(slotbase + (uint32_t)(kk-1)*512u + (uint32_t)r*64u, esimd::overaligned_tag<16>{});
                            float rs = rss[r];
                            esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                            esimd::slm_block_store<half,16>(S::O_OUT + (uint32_t)(rb*8 + r)*C*2u + (uint32_t)cb4*32u,
                                                            esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                        }
                    }
#else
                    constexpr int CBW = (M_P4FORM == 3) ? (C/8) : (C/16);   // col blocks per thread
                    constexpr int RBN = (M_P4FORM == 1) ? (T/16) : (T/8);   // token bands
                    if (t < RBN*CBW) {
                        const int rb = t / CBW, cb4 = t % CBW;
                        esimd::simd<int8_t,256> y0, b0, b1;
                        esimd::simd<int32_t,64> c00(0), c01(0)
#if M_P4FORM == 1
                                                      , c10(0), c11(0)
#endif
                            ;
                        for (int kb = 0; kb < S::KBN4; ++kb) {        // their :82 R6 loop, K step 32
#if M_P4FORM == 1
                            esimd::simd<int8_t,256> y1;
                            const uint32_t ab = S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)rb)*512u;
                            y0 = esimd::slm_block_load<int8_t,256>(ab, esimd::overaligned_tag<16>{});
                            y1 = esimd::slm_block_load<int8_t,256>(ab + 256u, esimd::overaligned_tag<16>{});
#else
                            const uint32_t ab = S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u
                                             + (uint32_t)(rb&1)*256u;
                            y0 = esimd::slm_block_load<int8_t,256>(ab, esimd::overaligned_tag<16>{});
#endif
                            const int8_t* bp = a.Bproj + (size_t)kb*(C*32)
                                             + (size_t)cb4*((M_P4FORM == 3) ? 256 : 512);
                            b0 = esimd::block_load<int8_t,256>(bp, esimd::overaligned_tag<16>{});
                            c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, y0);
#if M_P4FORM != 3
                            b1 = esimd::block_load<int8_t,256>(bp + 256, esimd::overaligned_tag<16>{});
                            c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, y0);
#endif
#if M_P4FORM == 1
                            c10 = esimd::xmx::dpas<8,8,int32_t>(c10, b0, y1);
                            c11 = esimd::xmx::dpas<8,8,int32_t>(c11, b1, y1);
#endif
                        }
                        {   // narrow sink for P4 (contract): pins the chains THIS form has
                            esimd::simd<int32_t,4> zS = c00.template select<4,1>(0);
#if M_P4FORM != 3
                            zS = zS + c01.template select<4,1>(0);
#endif
#if M_P4FORM == 1
                            esimd::simd<int32_t,4> zC = c10.template select<4,1>(0);
                            esimd::simd<int32_t,4> zD = c11.template select<4,1>(0);
                            zS = zS + (zC + zD);
#endif
                            sink4(4, zS);
                        }
                        // ---- the epilogue: scH (row) x bsProj (col), then f16 into OUT ----
                        const int row0 = (M_P4FORM == 1) ? rb*16 : rb*8;
#if M_P4FORM == 3
                        esimd::simd<float,8> cs = esimd::block_load<float,8>(a.bsProj + cb4*8, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)row0*4u, esimd::overaligned_tag<16>{});
                        for (int r = 0; r < 8; ++r) {
                            esimd::simd<int32_t,8> v = c00.template select<8,1>(r*8);
                            float rs = rss[r];
                            esimd::simd<float,8> pub = s8v8::pub_vec_v8<8>(1u, esimd::convert<float>(v) * rs * cs);
                            esimd::slm_block_store<half,8>(S::O_OUT + (uint32_t)(row0 + r)*C*2u + (uint32_t)cb4*16u,
                                                           esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                        }
#else
                        esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb4*16, esimd::overaligned_tag<16>{});
                        auto row = [&](esimd::simd<int32_t,64>& f0, esimd::simd<int32_t,64>& f1,
                                       int fr, int r, float rs) SYCL_ESIMD_FUNCTION {
                            esimd::simd<int32_t,16> acc(0);
                            acc.template select<8,1>(0) = f0.template select<8,1>(fr*8);
                            acc.template select<8,1>(8) = f1.template select<8,1>(fr*8);
                            esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                            esimd::slm_block_store<half,16>(S::O_OUT + (uint32_t)r*C*2u + (uint32_t)cb4*32u,
                                                            esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                        };
                        esimd::simd<float,8> rssA = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)row0*4u, esimd::overaligned_tag<16>{});
                        for (int r = 0; r < 8; ++r) row(c00, c01, r, row0 + r, rssA[r]);
#if M_P4FORM == 1
                        esimd::simd<float,8> rssB = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)(row0 + 8)*4u, esimd::overaligned_tag<16>{});
                        for (int r = 0; r < 8; ++r) row(c10, c11, r, row0 + 8 + r, rssB[r]);
#endif
#endif
                    }
#endif
                }
                MBAR(gr);
                if (DUMP) {   // OUT sink: the P=4 truncation must not DCE P4's stores
                    if (t < T)
                        for (int c = 0; c < C/16; ++c)
                            esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                                esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    MBAR(gr);
                }
                if (NPHASE <= 4) return;
            } else {
                // ---- P3f: f16 proj (F2/S3): shipped gemm_b_pub_f16 SEQUENTIAL kc (TS=16),
                // no split-K (f32 accumulator). 16 active threads; underfill is structural. ----
                if (t < S::ACT4) {
                    const int g = t / 2, tcg = t % 2;              // NP=8 groups x 2 col bands of 16
                    esimd::simd<half,128> a0, b0, b1;
                    esimd::simd<float,64> c00(0.f), c01(0.f);
                    for (int kc = 0; kc < 128/16; ++kc) {          // K_p=128 per group, ascending kc VERBATIM
                        a0 = esimd::slm_block_load<half,128>(S::O_HID + (uint32_t)(g*8 + kc)*256u, esimd::overaligned_tag<16>{});
                        b0 = esimd::block_load<half,128>(a.BprojH + (size_t)g*(128*32) + (size_t)(kc*2 + tcg)*256, esimd::overaligned_tag<16>{});
                        b1 = esimd::block_load<half,128>(a.BprojH + (size_t)g*(128*32) + (size_t)(kc*2 + tcg)*256 + 128, esimd::overaligned_tag<16>{});
                        c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                    }
                    // pub tail = gemm_b_pub_f16 :233-247 VERBATIM (pub_vec_v8<8>, epi1, narrow),
                    // stored to the 1275 twin in SLM (row-major C-wide, group slice g*32 + tcg*16)
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float,8> p0 = s8v8::pub_vec_v8<8>(1u, c00.template select<8,1>(r*8));
                        esimd::simd<float,8> p1 = s8v8::pub_vec_v8<8>(1u, c01.template select<8,1>(r*8));
                        uint32_t o = S::O_OUT + (uint32_t)r*C*2u + (uint32_t)(g*32 + tcg*16)*2u;
                        esimd::slm_block_store<half,8>(o, esimd::convert<half>(p0), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<half,8>(o + 16u, esimd::convert<half>(p1), esimd::overaligned_tag<16>{});
                    }
                }
                MBAR(gr);
                if (DUMP) {   // OUT sink for the P=3 truncation (f16-proj branch)
                    if (t < T)
                        for (int c = 0; c < C/16; ++c)
                            esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                                esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    MBAR(gr);
                }
                if (NPHASE <= 3) return;
            }

            // ---- P5q/P4q: out row peak -> pkO + scO (reuses PK) ----
            {
                const int qphase = S::F16PROJ ? 4 : 5;
                if (t < T) {
                    esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                    for (int c = 0; c < C/16; ++c) {
                        esimd::simd<half,16> h = esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{});
                        mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                    }
                    float peak = esimd::hmax<float,float,16>(mx);
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                    esimd::slm_block_store(S::O_SC + 256u + (uint32_t)t*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                    esimd::simd<int32_t,4> acc5(0);
                    for (int kb = 0; kb < S::KB_C; ++kb) {
                        esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                        q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                        esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                        esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(t>>4))*512u + (uint32_t)(t&15)*32u, o, esimd::overaligned_tag<16>{});
                        { esimd::simd<int8_t,4> o4 = o.template select<4,1>(0); acc5 = acc5 + esimd::convert<int32_t>(o4); }
                        if (DUMP) esimd::block_store<int8_t,32>(a.dpk3 + (size_t)(r0+t)*C + kb*32, o, esimd::overaligned_tag<16>{});
                    }
                    sink4(5, acc5 + esimd::simd<int32_t,4>((int32_t)scale));
                    for (int rr = T + t; rr < BANDS*16; rr += T)
                        for (int kb = 0; kb < S::KB_C; ++kb)
                            esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(rr>>4))*512u + (uint32_t)(rr&15)*32u,
                                                              esimd::simd<int8_t,32>((int8_t)0), esimd::overaligned_tag<16>{});
                    if (DUMP) {
                        a.dsc3[r0+t] = scale;
                        for (int c = 0; c < C/16; ++c)
                            esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                                esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    }
                }
                MBAR(gr);
                if (NPHASE <= qphase) return;
            }

            // ---- P6: residual gemm (T x C, K=C) split-K KS6 + skip*cos + epi1 -> 1267 ----
            {
                constexpr int CB6 = C/8;
                const int cb6 = t % CB6; int u = t / CB6;
                const int ks = u % S::KS6, rb = u / S::KS6;        // (T/8)*CB6*KS6 == 64
                const int kb0 = ks * (S::KBN6 / S::KS6), kb1 = (ks+1) * (S::KBN6 / S::KS6);
                esimd::simd<int8_t,256> a0, b0;
                esimd::simd<int32_t,64> c00(0);
                for (int kb = kb0; kb < kb1; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u + (uint32_t)(rb&1)*256u, esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bres + (size_t)kb*(C*32) + (size_t)cb6*256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                }
                {   // C2 narrow sink for P6 (residual dpas chain)
                    esimd::simd<int32_t,4> zA = c00.template select<4,1>(0);
                    sink4(6, zA);
                }
                uint32_t stride = 256u;   // per-(rb,cb6,ks) slot = 8 rows x 8 int32 = 256B
                uint32_t slot = S::O_STG + ((uint32_t)(rb*CB6 + cb6)*(S::KS6-1) + (uint32_t)(ks>0?ks-1:0))*stride;
                if (ks > 0)
                    for (int r = 0; r < 8; ++r)
                        esimd::slm_block_store<int32_t,8>(slot + (uint32_t)r*32u, c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                MBAR(gr);
                if (ks == 0) {
                    esimd::simd<float,8> cs = esimd::block_load<float,8>(a.bsRes + cb6*8, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> cc = esimd::block_load<float,8>(a.cos  + cb6*8, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> ros = esimd::slm_block_load<float,8>(S::O_SC + 256u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t,8> v = c00.template select<8,1>(r*8);
                        if (S::KS6 > 1) {
                            uint32_t s0 = slot;
                            for (int kk = 1; kk < S::KS6; ++kk)
                                v = v + esimd::slm_block_load<int32_t,8>(s0 + (uint32_t)(kk-1)*stride + (uint32_t)r*32u, esimd::overaligned_tag<16>{});
                        }
                        const int row = r0 + rb*8 + r;
                        float rs = ros[r];
                        esimd::simd<float,8> f0 = esimd::convert<float>(v) * rs * cs;
                        esimd::simd<half,8> sh = esimd::block_load<half,8>(a.dIn + (size_t)row*C + cb6*8, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> sk = esimd::convert<float>(sh);
                        esimd::simd<float,8> tt;
                        for (int e = 0; e < 8; ++e) tt[e] = sk[e]*cc[e] + f0.read()[e];   // ELEMENTWISE scalar = auto-FMA (one rounding)
                        esimd::simd<float,8> pub = s8v8::pub_vec_v8<8>(1u, tt);
                        esimd::convert<half>(pub).copy_to(a.dOut + (size_t)row*C + cb6*8);
                    }
                }
            }
        });
    });
}
} // namespace ffn2

// ==================== C2 STEP 2: ffn3 = the shipped 1a chain with R1 ZERO PACK ====================
// The PRODUCER writes the input pk plane directly in dpas-A fragment order -- the very pack_a
// map the shipped split path uses (pack_device.hpp:18-19: dest = ((w*kb_n+kb)*8+wi)*512 + row*32
// + k, BM=128/BK=32). So the chain has NO P1 at runtime: no in-chain quant, no in-chain pack.
// P2 loads its A operand straight off the global face, exactly like the port kernel's R1
// (port_ffn_fused.cpp:247 comment, :261-263 the two block_load<int8_t,256> halves, and the
// setup-time retile_a at :501). From P3 on the body is VERBATIM the shipped 1a chain: the
// hidden/proj pk planes (PKH) and the out pk plane (PKO) are chain-INTERNAL SLM products, not
// activation packs, so this shovel does not touch them.
// ffn3::fused reuses ffn2::Shape (identical SLM layout => identical occupancy => the delta is
// the pack leg and nothing else) and ffn2::Args (face/scA added there).
namespace ffn3 {
template <class S, bool DUMP, int NPHASE, int SINK = 0>
static sycl::event fused(sycl::queue& q, const ffn2::Args& a) {
    namespace esimd = sycl::ext::intel::esimd;
    constexpr int T = S::T, C = S::C, HID = S::HID;
    constexpr int BANDS = S::BANDS;
    const int nblk = a.M / T;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)nblk * 64), range(64)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<S::SLM>();
            const int blk = (int)it.get_group(0), t = (int)it.get_local_id(0);
            const int r0 = blk * T;            // M_BAR: the group handle the phase barriers need when M_BAR=1 (sycl::group_barrier)
            auto gr = it.get_group();
            auto sink4 = [&](int ph, const esimd::simd<int32_t,4>& z) SYCL_ESIMD_FUNCTION {
                if constexpr (SINK & 1)
                    esimd::block_store<int32_t,4>(a.probe +
                        ((((size_t)ph*(size_t)nblk + (size_t)blk)*64 + (size_t)t)*4u), z,
                        esimd::overaligned_tag<16>{});
            };
            // pack_a addressing for THIS block's rows (the face is Mp-padded, 128-row windows)
            const size_t fw  = (size_t)r0 / 128u;
            const size_t fwi = ((size_t)r0 / 16u) % 8u;

            // ---- P2: expand gemm (T x HID wide-N, K=C, epi3) -> hidden f16. A = global FACE ----
            {
                const int rb = t / (HID/16), cb = t % (HID/16);
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = 0; kb < S::KB_C; ++kb) {
                    // R1: the 512B fragment block = 16 rows x 32K, two 256B dpas operands,
                    // read STRAIGHT off the producer's face -- no pack pass, no SLM staging.
                    a0 = esimd::block_load<int8_t,256>(a.face +
                            (((fw*S::KB_C + (size_t)kb)*8u + fwi + (size_t)(rb>>1))*512u
                             + (size_t)(rb&1)*256u), esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(HID*32) + (size_t)cb*512, esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bexp + (size_t)kb*(HID*32) + (size_t)cb*512 + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                {   // narrow sink (phase 2): pins BOTH dpas chains
                    esimd::simd<int32_t,4> zA = c00.template select<4,1>(0);
                    esimd::simd<int32_t,4> zB = c01.template select<4,1>(0);
                    sink4(2, zA + zB);
                }
                esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsExp + cb*16, esimd::overaligned_tag<16>{});
                // scA comes from the producer too (the 閻滄媽鐭?quant's own scale plane)
                esimd::simd<float,8> rss = esimd::block_load<float,8>(a.scA + (size_t)r0 + (size_t)rb*8u,
                                                                       esimd::overaligned_tag<16>{});
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<int32_t,16> acc(0);
                    acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                    acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                    float rs = rss[r];
                    esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(3u, esimd::convert<float>(acc) * rs * cs);
                    esimd::simd<half,16> hh = esimd::convert<half>(pub);   // NAMED once: double-eating
                    esimd::slm_block_store<half,16>(S::O_HID + (uint32_t)(rb*8 + r)*HID*2u + (uint32_t)cb*32u,
                                                    hh, esimd::overaligned_tag<16>{});
#if M_PEAK
                     // ---- M2: same fold as ffn2's P2 epilogue (register-local peak of THIS
                     // wave's 16-column block, one writer per SLM slot, taken AFTER the f16 rounding).
                     esimd::simd<float,16> pa = esimd::abs(esimd::convert<float>(hh));
                     float lp = esimd::hmax<float,float,16>(pa);
                     esimd::slm_block_store(S::O_PEAK + (uint32_t)((rb*8 + r)*S::CB2 + cb)*4u,
                                            esimd::simd<float,1>(lp), esimd::overaligned_tag<16>{});
#endif
                }
            }
            MBAR(gr);
            if (DUMP) {
                if (t < T) {   // row-major twin straight from SLM (the 'hid' checkpoint)
                    for (int c = 0; c < HID/16; ++c)
                        esimd::block_store<half,16>(a.dHid + (size_t)(r0+t)*HID + c*16,
                            esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)t*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                            esimd::overaligned_tag<16>{});
                }
                MBAR(gr);
            }
            if (NPHASE <= 1) return;

            // ---- P3: hidden requant -> pkH + scH  (M2 peak slots + optional M2b row split;
            // identical structure to ffn2's P3 above -- see the comment there) ----
            {
                constexpr int SPLIT3 = (M_P3SPLIT != 0) ? (64 / T) : 1;
                const int p3r = t / SPLIT3, p3p = t % SPLIT3;
                if (t < T*SPLIT3) {
#if M_PEAK
                    esimd::simd<float,S::CB2> mx = esimd::slm_block_load<float,S::CB2>(
                        S::O_PEAK + (uint32_t)p3r*(S::CB2*4u), esimd::overaligned_tag<16>{});
                    float peak = esimd::hmax<float,float,S::CB2>(mx);
#else
                    esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                    for (int c = 0; c < HID/16; ++c) {
                        esimd::simd<half,16> h = esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)p3r*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{});
                        mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                    }
                    float peak = esimd::hmax<float,float,16>(mx);
#endif
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                    if (p3p == 0)
                        esimd::slm_block_store(S::O_SC + 128u + (uint32_t)p3r*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                    esimd::simd<int32_t,4> acc3(0);
                    const int kb0 = p3p * (S::KB_H / SPLIT3), kb1 = (p3p + 1) * (S::KB_H / SPLIT3);
                    for (int kb = kb0; kb < kb1; ++kb) {
                        esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_HID + (uint32_t)p3r*(HID*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                        q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                        esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                        esimd::slm_block_store<int8_t,32>(S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(p3r>>4))*512u + (uint32_t)(p3r&15)*32u, o, esimd::overaligned_tag<16>{});
                        { esimd::simd<int8_t,4> o4 = o.template select<4,1>(0); acc3 = acc3 + esimd::convert<int32_t>(o4); }
                        if (DUMP) {
                            esimd::block_store<int8_t,32>(a.dpk2 + (size_t)(r0+p3r)*HID + kb*32, o, esimd::overaligned_tag<16>{});
                            // the SAME bytes in the pack_a fragment order (the 'pk2-frag' checkpoint)
                            esimd::block_store<int8_t,32>(a.dpk2frag + (((fw*S::KB_H + (size_t)kb)*8u + fwi + (size_t)(p3r>>4))*512u
                                                                        + (size_t)(p3r&15)*32u), o, esimd::overaligned_tag<16>{});
                        }
                    }
                    sink4(3, acc3 + esimd::simd<int32_t,4>((int32_t)scale));
                    if (DUMP && p3p == 0) a.dsc2[r0+p3r] = scale;
                }
            }
            MBAR(gr);
            if (NPHASE <= 2) return;

            // ---- P4: the contract -- the SAME body as ffn2's P4 above (see the long comment
            // there for the M_P4FORM table, the R4/R2 mapping and the bit-exactness argument).
            {
#if M_P4FORM == 0
                constexpr int CB4 = C/16;
                const int cb4 = t % CB4; int u = t / CB4;
                const int ks = u % S::KS4, rb = u / S::KS4;   // (T/8)*CB4*KS4 == 64
                const int kb0 = ks * (S::KBN4 / S::KS4), kb1 = (ks+1) * (S::KBN4 / S::KS4);
                esimd::simd<int8_t,256> a0, b0, b1;
                esimd::simd<int32_t,64> c00(0), c01(0);
                for (int kb = kb0; kb < kb1; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u + (uint32_t)(rb&1)*256u, esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(C*32) + (size_t)cb4*512, esimd::overaligned_tag<16>{});
                    b1 = esimd::block_load<int8_t,256>(a.Bproj + (size_t)kb*(C*32) + (size_t)cb4*512 + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, a0);
                }
                {   // narrow sink (phase 4 = contract): pins both dpas chains
                    esimd::simd<int32_t,4> zA = c00.template select<4,1>(0);
                    esimd::simd<int32_t,4> zB = c01.template select<4,1>(0);
                    sink4(4, zA + zB);
                }
                MBAR(gr);   // all PKH reads done; staging may now alias PKH/PK/HIDF
                constexpr uint32_t TILE4 = (uint32_t)((S::KS4 - 1) * 512u);
                const uint32_t slotbase = S::O_STG + (uint32_t)(rb*CB4 + cb4) * TILE4;
                if (ks > 0) {
                    const uint32_t slot = slotbase + (uint32_t)(ks - 1) * 512u;
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t,16> acc(0);
                        acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                        acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                        esimd::slm_block_store<int32_t,16>(slot + (uint32_t)r*64u, acc, esimd::overaligned_tag<16>{});
                    }
                }
                MBAR(gr);
                if (ks == 0) {
                    esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb4*16, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t,16> acc(0);
                        acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                        acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                        for (int kk = 1; kk < S::KS4; ++kk)
                            acc = acc + esimd::slm_block_load<int32_t,16>(slotbase + (uint32_t)(kk-1)*512u + (uint32_t)r*64u, esimd::overaligned_tag<16>{});
                        float rs = rss[r];
                        esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                        esimd::slm_block_store<half,16>(S::O_OUT + (uint32_t)(rb*8 + r)*C*2u + (uint32_t)cb4*32u,
                                                        esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                    }
                }
#else
                constexpr int CBW = (M_P4FORM == 3) ? (C/8) : (C/16);   // col blocks per thread
                constexpr int RBN = (M_P4FORM == 1) ? (T/16) : (T/8);   // token bands
                if (t < RBN*CBW) {
                    const int rb = t / CBW, cb4 = t % CBW;
                    esimd::simd<int8_t,256> y0, b0, b1;
                    esimd::simd<int32_t,64> c00(0), c01(0)
#if M_P4FORM == 1
                                                  , c10(0), c11(0)
#endif
                        ;
                    for (int kb = 0; kb < S::KBN4; ++kb) {        // their :82 R6 loop, K step 32
#if M_P4FORM == 1
                        esimd::simd<int8_t,256> y1;
                        const uint32_t ab = S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)rb)*512u;
                        y0 = esimd::slm_block_load<int8_t,256>(ab, esimd::overaligned_tag<16>{});
                        y1 = esimd::slm_block_load<int8_t,256>(ab + 256u, esimd::overaligned_tag<16>{});
#else
                        const uint32_t ab = S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u
                                         + (uint32_t)(rb&1)*256u;
                        y0 = esimd::slm_block_load<int8_t,256>(ab, esimd::overaligned_tag<16>{});
#endif
                        const int8_t* bp = a.Bproj + (size_t)kb*(C*32)
                                         + (size_t)cb4*((M_P4FORM == 3) ? 256 : 512);
                        b0 = esimd::block_load<int8_t,256>(bp, esimd::overaligned_tag<16>{});
                        c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, y0);
#if M_P4FORM != 3
                        b1 = esimd::block_load<int8_t,256>(bp + 256, esimd::overaligned_tag<16>{});
                        c01 = esimd::xmx::dpas<8,8,int32_t>(c01, b1, y0);
#endif
#if M_P4FORM == 1
                        c10 = esimd::xmx::dpas<8,8,int32_t>(c10, b0, y1);
                        c11 = esimd::xmx::dpas<8,8,int32_t>(c11, b1, y1);
#endif
                    }
                    {   // narrow sink for P4 (contract): pins the chains THIS form has
                        esimd::simd<int32_t,4> zS = c00.template select<4,1>(0);
#if M_P4FORM != 3
                        zS = zS + c01.template select<4,1>(0);
#endif
#if M_P4FORM == 1
                        esimd::simd<int32_t,4> zC = c10.template select<4,1>(0);
                        esimd::simd<int32_t,4> zD = c11.template select<4,1>(0);
                        zS = zS + (zC + zD);
#endif
                        sink4(4, zS);
                    }
                    // ---- the epilogue: scH (row) x bsProj (col), then f16 into OUT ----
                    const int row0 = (M_P4FORM == 1) ? rb*16 : rb*8;
#if M_P4FORM == 3
                    esimd::simd<float,8> cs = esimd::block_load<float,8>(a.bsProj + cb4*8, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)row0*4u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t,8> v = c00.template select<8,1>(r*8);
                        float rs = rss[r];
                        esimd::simd<float,8> pub = s8v8::pub_vec_v8<8>(1u, esimd::convert<float>(v) * rs * cs);
                        esimd::slm_block_store<half,8>(S::O_OUT + (uint32_t)(row0 + r)*C*2u + (uint32_t)cb4*16u,
                                                       esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                    }
#else
                    esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb4*16, esimd::overaligned_tag<16>{});
                    auto row = [&](esimd::simd<int32_t,64>& f0, esimd::simd<int32_t,64>& f1,
                                   int fr, int r, float rs) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int32_t,16> acc(0);
                        acc.template select<8,1>(0) = f0.template select<8,1>(fr*8);
                        acc.template select<8,1>(8) = f1.template select<8,1>(fr*8);
                        esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                        esimd::slm_block_store<half,16>(S::O_OUT + (uint32_t)r*C*2u + (uint32_t)cb4*32u,
                                                        esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                    };
                    esimd::simd<float,8> rssA = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)row0*4u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) row(c00, c01, r, row0 + r, rssA[r]);
#if M_P4FORM == 1
                    esimd::simd<float,8> rssB = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)(row0 + 8)*4u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) row(c10, c11, r, row0 + 8 + r, rssB[r]);
#endif
#endif
                }
#endif
            }
            MBAR(gr);
            if (DUMP) {   // OUT sink: the NPHASE=3 truncation must not DCE P4's stores
                if (t < T)
                    for (int c = 0; c < C/16; ++c)
                        esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                            esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                            esimd::overaligned_tag<16>{});
                MBAR(gr);
            }
            if (NPHASE <= 3) return;

            // ---- P5: out row peak -> pkO + scO (reuses PK)  [VERBATIM shipped 1a] ----
            if (t < T) {
                esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                for (int c = 0; c < C/16; ++c) {
                    esimd::simd<half,16> h = esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{});
                    mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                }
                float peak = esimd::hmax<float,float,16>(mx);
                const float scale = (peak == 0.0f) ? 1.0f
                    : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                esimd::slm_block_store(S::O_SC + 256u + (uint32_t)t*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                esimd::simd<int32_t,4> acc5(0);
                for (int kb = 0; kb < S::KB_C; ++kb) {
                    esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                    esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                    q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                    esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                    esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(t>>4))*512u + (uint32_t)(t&15)*32u, o, esimd::overaligned_tag<16>{});
                    { esimd::simd<int8_t,4> o4 = o.template select<4,1>(0); acc5 = acc5 + esimd::convert<int32_t>(o4); }
                    if (DUMP) {
                        esimd::block_store<int8_t,32>(a.dpk3 + (size_t)(r0+t)*C + kb*32, o, esimd::overaligned_tag<16>{});
                        esimd::block_store<int8_t,32>(a.dpk3frag + (((fw*S::KB_C + (size_t)kb)*8u + fwi + (size_t)(t>>4))*512u
                                                                    + (size_t)(t&15)*32u), o, esimd::overaligned_tag<16>{});
                    }
                }
                sink4(5, acc5 + esimd::simd<int32_t,4>((int32_t)scale));
                if (DUMP) {
                    a.dsc3[r0+t] = scale;
                    for (int c = 0; c < C/16; ++c)
                        esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                            esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                            esimd::overaligned_tag<16>{});
                }
            }
            MBAR(gr);
            if (NPHASE <= 4) return;

            // ---- P6: residual gemm (T x C, K=C) split-K KS6 + skip*cos + epi1 -> 1267 [VERBATIM] ----
            {
                constexpr int CB6 = C/8;
                const int cb6 = t % CB6; int u = t / CB6;
                const int ks = u % S::KS6, rb = u / S::KS6;
                const int kb0 = ks * (S::KBN6 / S::KS6), kb1 = (ks+1) * (S::KBN6 / S::KS6);
                esimd::simd<int8_t,256> a0, b0;
                esimd::simd<int32_t,64> c00(0);
                for (int kb = kb0; kb < kb1; ++kb) {
                    a0 = esimd::slm_block_load<int8_t,256>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(rb>>1))*512u + (uint32_t)(rb&1)*256u, esimd::overaligned_tag<16>{});
                    b0 = esimd::block_load<int8_t,256>(a.Bres + (size_t)kb*(C*32) + (size_t)cb6*256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8,8,int32_t>(c00, b0, a0);
                }
                { esimd::simd<int32_t,4> zA = c00.template select<4,1>(0); sink4(6, zA); }
                uint32_t stride = 256u;
                uint32_t slot = S::O_STG + ((uint32_t)(rb*CB6 + cb6)*(S::KS6-1) + (uint32_t)(ks>0?ks-1:0))*stride;
                if (ks > 0)
                    for (int r = 0; r < 8; ++r)
                        esimd::slm_block_store<int32_t,8>(slot + (uint32_t)r*32u, c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                MBAR(gr);
                if (ks == 0) {
                    esimd::simd<float,8> cs = esimd::block_load<float,8>(a.bsRes + cb6*8, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> cc = esimd::block_load<float,8>(a.cos  + cb6*8, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> ros = esimd::slm_block_load<float,8>(S::O_SC + 256u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{});
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<int32_t,8> v = c00.template select<8,1>(r*8);
                        if (S::KS6 > 1) {
                            uint32_t s0 = slot;
                            for (int kk = 1; kk < S::KS6; ++kk)
                                v = v + esimd::slm_block_load<int32_t,8>(s0 + (uint32_t)(kk-1)*stride + (uint32_t)r*32u, esimd::overaligned_tag<16>{});
                        }
                        const int row = r0 + rb*8 + r;
                        float rs = ros[r];
                        esimd::simd<float,8> f0 = esimd::convert<float>(v) * rs * cs;
                        esimd::simd<half,8> sh = esimd::block_load<half,8>(a.dIn + (size_t)row*C + cb6*8, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> sk = esimd::convert<float>(sh);
                        esimd::simd<float,8> tt;
                        for (int e = 0; e < 8; ++e) tt[e] = sk[e]*cc[e] + f0.read()[e];   // ELEMENTWISE scalar = auto-FMA (one rounding)
                        esimd::simd<float,8> pub = s8v8::pub_vec_v8<8>(1u, tt);
                        esimd::convert<half>(pub).copy_to(a.dOut + (size_t)row*C + cb6*8);
                    }
                }
            }
        });
    });
}

// retile_a: the pure index permutation row-major pk -> the pack_a fragment-order face
// (NO arithmetic, so bit-exact by construction -- the port's setup knife, port-B.md B6/R1).
static void retile_a(sycl::queue& q, const int8_t* pk, int8_t* face, int M, int Mp, int K) {
    const int kb_n = K / 32;
    size_t per = (size_t)(Mp / 128) * (size_t)kb_n * 8 * 512;
    q.parallel_for(sycl::range(per / 16), [=](sycl::item<1> it) {
        size_t d = it.get_id(0) * 16;
        size_t blk = d / 512; int off = (int)(d % 512);
        int wi = (int)(blk % 8); size_t wk = blk / 8;
        int kb = (int)(wk % (size_t)kb_n); int w = (int)(wk / (size_t)kb_n);
        int row = off / 32;
        int srow = w * 128 + wi * 16 + row;
        sycl::vec<unsigned, 4> v(0u);
        if (srow < M)
            v = *reinterpret_cast<const sycl::vec<unsigned,4>*>(pk + (size_t)srow * K + (size_t)kb*32 + (off % 32));
        *reinterpret_cast<sycl::vec<unsigned,4>*>(face + d) = v;
    });
}
} // namespace ffn3


// ============================ host ============================
struct Stat { double msm, msM, msX, med; size_t ng; std::vector<double> gms; };
static Stat pack_stat(std::vector<double>& gmin, std::vector<double>& all) {
    Stat st; st.ng = gmin.size();
    std::sort(gmin.begin(), gmin.end());
    st.msM = gmin[gmin.size()/2]; st.msX = gmin.back();
    st.msm = *std::min_element(all.begin(), all.end());
    std::sort(all.begin(), all.end());
    st.med = all[all.size()/2]; st.gms = gmin; return st;
}
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            auto s0 = e.get_profiling_info<info::event_profiling::command_start>();
            auto t0 = e.get_profiling_info<info::event_profiling::command_end>();
            double ms = (double)(t0 - s0) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static Stat timeit_wall(std::function<void()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            auto c0 = std::chrono::steady_clock::now();
            f();
            auto c1 = std::chrono::steady_clock::now();
            double ms = std::chrono::duration<double, std::milli>(c1 - c0).count();
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    return pack_stat(gmin, all);
}
static const char* gmfmt(const Stat& st) {
    static char buf[160]; int o = 0;
    for (size_t i = 0; i < st.gms.size() && o < 140; ++i) o += snprintf(buf+o, sizeof(buf)-o, "%.4f ", st.gms[i]);
    return buf;
}
static bool diffbytes(const uint8_t* x, const uint8_t* y, size_t n, size_t K, const char* what) {
    size_t bad = 0; size_t fi = 0;
    for (size_t i = 0; i < n; ++i) if (x[i] != y[i]) { if (!bad) fi = i; ++bad; }
    if (bad) {
        printf("  DIFF %-11s %zu/%zu bytes differ; first elem %zu (row=%zu col=%zu): A=0x%02X B=0x%02X\n",
               what, bad, n, fi, K ? fi/K : 0, K ? fi%K : 0, x[fi], y[fi]);
        return false;
    }
    printf("  diff %-11s = 0  (%zu bytes)\n", what, n);
    return true;
}
// ---- C2 CSV emitters ----
static char note_buf[512];
static const char* statnote(const Stat& st, const char* extra) {
    snprintf(note_buf, sizeof(note_buf), "msm=%.4f msM=%.4f msX=%.4f med=%.4f ng=%zu groups=[%s] %s",
             st.msm, st.msM, st.msX, st.med, st.ng, gmfmt(st), extra ? extra : "");
    return note_buf;
}
// ms = msm (min over all reps); msM = median of the group mins; TOPS from msM (the C1 basis).
static void csvrow(const char* sh, const char* leg, const Stat& st, double flops, const char* extra) {
    double tops = (flops > 0.0 && st.msM > 1e-9) ? flops / (st.msM*1e-3) / 1e12 : 0.0;
    printf("CSVROW;%s;%s;%.4f;%.4f;%.0f;%.3f;%s\n", sh, leg, st.msm, st.msM, flops, tops, statnote(st, extra));
    fflush(stdout);
}
// a phase delta = difference of two cumulative truncated runs (no separate msm exists for it).
static void csvd(const char* sh, const char* leg, double delta, double flops, const char* extra) {
    double tops = (flops > 0.0 && delta > 1e-9) ? flops / (delta*1e-3) / 1e12 : 0.0;
    printf("CSVROW;%s;%s;%.4f;%.4f;%.0f;%.3f;%s\n", sh, leg, delta, delta, flops, tops, extra);
    fflush(stdout);
}
// un-permute a pack_a fragment-order face back to row-major, compare against the pk plane.
static bool diff_face(const uint8_t* face, const uint8_t* pk, int M, int K, const char* what) {
    const int kb_n = K/32;
    std::vector<uint8_t> back((size_t)M*K);
    for (int r = 0; r < M; ++r) {
        int w = r/128, rem = r%128, wi = rem/16, row = rem%16;
        for (int kb = 0; kb < kb_n; ++kb)
            for (int k = 0; k < 32; ++k)
                back[(size_t)r*K + kb*32 + k] =
                    face[(((size_t)w*kb_n + kb)*8 + wi)*512 + row*32 + k];
    }
    return diffbytes(pk, back.data(), (size_t)M*K, (size_t)K, what);
}
// the two chains behind one bisection driver (K2 = shipped-equivalent 1a, K3 = 1a + R1 zero pack)
struct K2 { template <class S, int P, int SK>
    static event go(queue& q, const ffn2::Args& a) { return ffn2::fused<S, false, P, SK>(q, a); } };
struct K3 { template <class S, int P, int SK>
    static event go(queue& q, const ffn2::Args& a) { return ffn3::fused<S, false, P, SK>(q, a); } };
static const char* PHNAME[7] = {"", "P1_inquant+pack", "P2_expand", "P3_requant",
                                "P4_contract", "P5_outquant", "P6_res"};
// C2 phase bisection, DUMP=false, BOTH sink variants (SINK=0 default / SINK=1 narrow 4-lane).
// FIRSTPH = the real phase id of the first truncated run (1 for ffn2, 2 for ffn3: no P1 in the chain).
template <class KL, class S, int FIRSTPH, int NPH, int... Is>
static void bisect_seq(const ffn2::Args& fa, queue& q, const char* sh,
                       double fExp, double fCont, double fRes, std::integer_sequence<int, Is...>) {
    Stat prev0{}, prev1{}; bool first = true;
    ( ( [&]{
        constexpr int P = Is + 1;
        constexpr int ph = FIRSTPH + Is;
        Stat s0 = timeit([&]{ return KL::template go<S, P, 0>(q, fa); });
        Stat s1 = timeit([&]{ return KL::template go<S, P, 1>(q, fa); });
        double d0 = first ? s0.msM : s0.msM - prev0.msM;
        double d1 = first ? s1.msM : s1.msM - prev1.msM;
        double f = (ph == 2) ? fExp : (ph == 4) ? fCont : (ph == 6) ? fRes : 0.0;
        int act = (ph == 1) ? S::T : (ph == 3 ? S::ACT3 : (ph == 5 ? S::T : (ph == 2 ? S::ACT2 : (ph == 4 ? S::ACT4 : S::ACT6))));
        char ex[460];
        snprintf(ex, sizeof(ex), "cum_nosink=%.4f cum_sink=%.4f delta_nosink=%.4f delta_sink=%.4f act=%d/64 probe=narrow-4lane-16B/thread %s",
                 s0.msM, s1.msM, d0, d1, act, first ? "(first: cum==delta)" : "(delta = cum(P)-cum(P-1))");
        csvd(sh, PHNAME[ph], d0, f, ex);
        char nm2[80]; snprintf(nm2, sizeof(nm2), "%s_sinkchk", PHNAME[ph]);
        csvd(sh, nm2, d1, f, "NARROW-sink cross-check of the same phase (military rule 19)");
        printf("  %s ph%d %-16s cum_nosink=%.4f cum_sink=%.4f | delta nosink=%.4f sink=%.4f | act=%d/64\n",
               sh, ph, PHNAME[ph], s0.msM, s1.msM, d0, d1, act);
        prev0 = s0; prev1 = s1; first = false;
    }() ), ... );
}
// one launch+wait per truncated phase (forensics for the DEVICE_LOST hunt)
template <class S, int... Is>
static void smoke(const ffn2::Args& fa, queue& q, std::integer_sequence<int, Is...>) {
    ( ( [&]{
        printf("  fused<%d> ...", Is + 1);
        ffn2::fused<S, false, Is + 1>(q, fa).wait();
        printf(" ok\n");
    }() ), ... );
}
template <class S, int... Is>
static void smoke3(const ffn2::Args& fa, queue& q, std::integer_sequence<int, Is...>) {
    ( ( [&]{
        printf("  fused3<%d> ...", Is + 1);
        ffn3::fused<S, false, Is + 1, 0>(q, fa).wait();
        printf(" ok\n");
    }() ), ... );
}
static inline int nblkOf(int M, int T) { return M / T; }


// C2: the empirical free-window probe (SYCL has no "free bytes" query). Returns the largest
// single sycl::malloc_device that succeeds, in bytes (0 = nothing above 256 KB fits).
static size_t largest_fit(queue& q) {
    for (size_t sz = (1ull<<30); sz >= (1ull<<18); sz >>= 1) {
        void* p = sycl::malloc_device(sz, q);
        if (p) { sycl::free(p, q); return sz; }
    }
    return 0;
}
static void memprobe(queue& q, const char* where) {
    printf("[memprobe] %-34s largest-single-alloc = %6.0f MB | global_mem_size = %llu MB\n",
           where, largest_fit(q)/1e6,
           (unsigned long long)q.get_device().get_info<info::device::global_mem_size>()/1048576ull);
    fflush(stdout);
}

// ================= S6-1b step-0 fix: the D2H route =================
// C2-6: a 2,088,960-byte q.memcpy into PAGEABLE host memory threw
// UR_RESULT_ERROR_OUT_OF_DEVICE_MEMORY(39) at a moment when a 1074 MB SINGLE device
// allocation still succeeded => the exhausted pool is the driver's pinned/host-staging
// quota (Level Zero stages pageable copies through pinned device-visible memory), NOT the
// device-local byte budget. Fix (no judgement change): land every snapshot in a
// sycl::malloc_host() buffer (driver-managed host USM = the copy target itself, no extra
// staging) in 1 MB chunks, then a plain host memcpy into the caller's std::vector.
// If malloc_host itself fails, fall back to chunked direct copies (1 MB each, so a single
// staging request never asks for 2 MB+).
static int g_d2h_host = 0, g_d2h_chunk = 0;      // path counters for the ledger
static void d2h(queue& q, void* dst, const void* src, size_t bytes, const char* what) {
    if (!bytes) return;
    char* d = (char*)dst; const char* s = (const char*)src;
    const size_t CH = 1u << 20;
    for (size_t off = 0; off < bytes; off += CH) {
        size_t n = std::min(CH, bytes - off);
        void* st = nullptr;
        try { st = sycl::malloc_host(n, q); }
        catch (const std::exception& e) { printf("  [d2h %s] malloc_host(%zu) threw: %s\n", what, n, e.what()); }
        bool done = false;
        if (st) {
            try { q.memcpy(st, s + off, n).wait(); memcpy(d + off, st, n); done = true; ++g_d2h_host; }
            catch (const sycl::exception& e) {
                printf("  [d2h %s] host-USM copy(%zu @%zu) threw code=%d -- chunked fallback\n",
                       what, n, off, e.code() ? e.code().value() : -1);
            }
            sycl::free(st, q);
        }
        if (!done) {
            q.memcpy(d + off, s + off, n).wait(); ++g_d2h_chunk;
        }
    }
}
static void d2h_report() {
    printf("[d2h] host-USM chunks = %d | chunked-pageable fallbacks = %d\n", g_d2h_host, g_d2h_chunk);
    fflush(stdout);
}

static int run_all() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return 1; }
    queue q(dev, property::queue::enable_profiling{});
    printf("device: %s\n", dev.get_info<info::device::name>().c_str());
    {   // C2 OOM(39) hunt: SYCL exposes no "free bytes", so probe the largest SINGLE device
        // allocation that still succeeds (power-of-two walk down from 1 GB). A small result with
        // the GPU otherwise idle = leaked / stuck device context from an earlier HANG'd process
        // (the fix is host-side: disable+enable the adapter or reboot), NOT a code bug.
        size_t best = 0;
        for (size_t sz = (1ull<<30); sz >= (1ull<<18); sz >>= 1) {
            void* p = sycl::malloc_device(sz, q);
            if (p) { sycl::free(p, q); best = sz; break; }
        }
        printf("[memprobe] largest single device alloc that fits = %.0f MB | global_mem_size = %llu MB"
               " | local_mem_size = %u | max_work_group_size = %u\n",
               best/1e6, (unsigned long long)dev.get_info<info::device::global_mem_size>()/1048576ull,
               dev.get_info<info::device::local_mem_size>(),
               dev.get_info<info::device::max_work_group_size>());
        fflush(stdout);
    }

    std::mt19937 rng(5);
    std::uniform_real_distribution<float> du(-1.5f, 1.5f);
    std::uniform_int_distribution<int> dw(-127, 127);
    auto uscale = [&](std::mt19937& r){ std::uniform_real_distribution<float> d2(0.002f, 0.02f); return d2(r); };

    double dS1 = 0, dS2 = 0, dS3 = 0;   // per-chain deltas (wall msM; >0 = fused loses)

    // ---- shape driver: run one chain family (diff gate + pricing), return delta ----
    auto run_shape = [&](const char* tag, const char* shid, int M, int C, int HID, int N_e, int b_e, int N_p, int K_p, int b_p,
                         bool f16proj, auto SHAPETAG) {
        using S = decltype(SHAPETAG);
        const int Mp = ((M + 127) / 128) * 128;
        printf("\n############ %s: M=%d C=%d HID=%d f16proj=%d  (P2act=%d P4act=%d P6act=%d, SLM=%uB) ############\n",
               tag, M, C, HID, (int)f16proj, S::ACT2, S::ACT4, S::ACT6, S::SLM);
        // host data
        std::vector<half> hIn((size_t)M*C);              for (auto& x : hIn) x = half(du(rng));
        std::vector<int8_t> hWE((size_t)b_e*N_e*C);      for (auto& x : hWE) x = (int8_t)dw(rng);
        std::vector<float>  hSE((size_t)b_e*N_e);        for (auto& x : hSE) x = uscale(rng);
        std::vector<int8_t> hWP;  std::vector<float> hSP;
        std::vector<half>   hWPH;
        if (!f16proj) { hWP.resize((size_t)b_p*N_p*K_p); for (auto& x : hWP) x = (int8_t)dw(rng); hSP.resize((size_t)b_p*N_p); for (auto& x : hSP) x = uscale(rng); }
        else          { hWPH.resize((size_t)b_p*N_p*K_p); for (auto& x : hWPH) x = half(du(rng)*0.1f); }
        std::vector<int8_t> hWR((size_t)C*C);            for (auto& x : hWR) x = (int8_t)dw(rng);
        std::vector<float>  hSR((size_t)C);              for (auto& x : hSR) x = uscale(rng);
        std::vector<float>  hCos((size_t)C);             for (auto& x : hCos) x = du(rng);
        auto mk = [&](size_t bytes){ void* p = malloc_device(bytes, q); q.memset(p, 0, bytes).wait(); return p; };
        half* dIn = (half*)mk((size_t)M*C*2);
        half* dO1 = (half*)mk((size_t)M*C*2);   // control 1267
        half* dO2 = (half*)mk((size_t)M*C*2);   // fused 1267
        int8_t* dPK = (int8_t*)mk((size_t)M*(size_t)HID);
        float* dSC = (float*)mk((size_t)M*4);
        half* dH = (half*)mk((size_t)M*(size_t)HID*2);
        half* dOt = (half*)mk((size_t)M*C*2);   // 1275 twin
        int8_t* dApE = (int8_t*)mk((size_t)b_e*Mp*C);
        int8_t* dApP = (int8_t*)mk((size_t)Mp*HID);
        half* dApH = (half*)mk((size_t)b_p*Mp*K_p*2);
        int8_t* dApR = (int8_t*)mk((size_t)Mp*C);
        int8_t* dBpE = (int8_t*)mk((size_t)b_e*N_e*C);
        int8_t* dBpEW= (int8_t*)mk((size_t)HID*C);          // fused wide expand pack
        int8_t* dBpP = (int8_t*)mk((size_t)C*HID);          // control: batched/diag; fused: wide
        half* dBpPH = (half*)mk((size_t)b_p*K_p*N_p*2);     // f16 proj packed (per-group)
        int8_t* dBpR = (int8_t*)mk((size_t)C*C);
        float* dSE = (float*)mk((size_t)b_e*N_e*4);
        float* dSP = (float*)mk((size_t)C*4);               // wide (concatenated) for BOTH legs
        float* dSR = (float*)mk((size_t)C*4);
        float* dCos = (float*)mk((size_t)C*4);
        int8_t* dWER = (int8_t*)mk(hWE.size());
        int8_t* dWPR = f16proj ? nullptr : (int8_t*)mk(hWP.size());
        half* dWPHR = f16proj ? (half*)mk(hWPH.size()*2) : nullptr;
        int8_t* dWRR = (int8_t*)mk(hWR.size());
        int8_t* dWEW = (int8_t*)mk((size_t)HID*C);          // wide raw (fused Bexp source)
        q.memcpy(dIn, hIn.data(), (size_t)M*C*2);
        q.memcpy(dWER, hWE.data(), hWE.size());
        q.memcpy(dWRR, hWR.data(), hWR.size());
        q.memcpy(dSE, hSE.data(), hSE.size()*4);
        q.memcpy(dSR, hSR.data(), hSR.size()*4);
        q.memcpy(dCos, hCos.data(), hCos.size()*4);
        if (!f16proj) { q.memcpy(dWPR, hWP.data(), hWP.size()); q.memcpy(dSP, hSP.data(), hSP.size()*4); }
        else q.memcpy(dWPHR, hWPH.data(), hWPH.size()*2);
        // wide expand raw: groups concatenated along N
        {
            std::vector<int8_t> wew((size_t)HID*C);
            for (int g = 0; g < b_e; ++g) for (int n = 0; n < N_e; ++n) for (int k = 0; k < C; ++k)
                wew[(size_t)(g*N_e + n)*C + k] = hWE[(size_t)g*N_e*C + (size_t)n*C + k];
            q.memcpy(dWEW, wew.data(), wew.size());
        }
        // weight packs (cache-owned: setup once, NOT timed)
        packdev::gather_pack_b_b(q, dWER, dBpE, N_e, C, C, (size_t)N_e*C, b_e);
        packdev::pack_b(q, dWEW, dBpEW, HID, C);
        if (!f16proj) packdev::gather_pack_b_diag_b(q, dWPR, dBpP, N_p, K_p, K_p, (size_t)N_p*K_p, b_p);
        else packdev::gather_pack_b16_b(q, dWPHR, dBpPH, K_p, N_p, N_p, (size_t)K_p*N_p, 0, b_p);
        packdev::pack_b(q, dWRR, dBpR, C, C);
        // fused dump scratch
        int8_t* fPK1 = (int8_t*)mk((size_t)M*C); float* fSC1 = (float*)mk((size_t)M*4);
        half* fHID = (half*)mk((size_t)M*(size_t)HID*2); int8_t* fPK2 = f16proj ? nullptr : (int8_t*)mk((size_t)M*HID);
        float* fSC2 = f16proj ? nullptr : (float*)mk((size_t)M*4);
        half* fOUT = (half*)mk((size_t)M*C*2); int8_t* fPK3 = (int8_t*)mk((size_t)M*C); float* fSC3 = (float*)mk((size_t)M*4);
        q.wait();
        printf("-- setup+packs done --\n");

        // ---- C2 two-stage mode: the A770's allocatable device window is the binding limit
        // (~250 MB with the split chain + both fused chains' taps + ~50 JIT modules live), so
        // the R1 half runs as its OWN process and reads the current chain's bytes from a
        // reference blob written here. C2_STAGE=1 split+1a (writes c2ref), =2 the R1 chain
        // (reads c2ref), =3 both in one process (default; may not fit for S1).
        const int stage = getenv("C2_STAGE") ? atoi(getenv("C2_STAGE")) : 3;
        // M-SHOVEL modes (env M_MODE; every rung is its OWN process -- military rule 16):
        //   0 = the block3 flow (split control + both gates + all pricing)
        //   1 = GATE ONLY: no split control chain at all; the ffn2 taps are diffed byte-for-byte
        //       against block3's own reference blob (c2ref_<shape>.bin) = the entry ticket
        //   2 = PRICE ONLY: no control chain, no DUMP launch; wall/GPU + the phase bisection cum
        const int mode = getenv("M_MODE") ? atoi(getenv("M_MODE")) : 0;
        const bool need_ctrl = (mode == 0), need_dump = (mode != 2), need_price = (mode != 1);
        printf("[mode] M_MODE=%d (ctrl=%d dump=%d price=%d)  P4FORM=%d PEAK=%d P3SPLIT=%d\n",
               mode, (int)need_ctrl, (int)need_dump, (int)need_price, M_P4FORM, M_PEAK, M_P3SPLIT);
        ffn2::Args fa;
        fa.dIn = dIn; fa.dOut = dO2; fa.Bexp = dBpEW; fa.bsExp = dSE;
        fa.Bproj = dBpP; fa.bsProj = dSP; fa.BprojH = dBpPH;
        fa.Bres = dBpR; fa.bsRes = dSR; fa.cos = dCos; fa.M = M; fa.NP = b_p;
        fa.dpk1 = fPK1; fa.dsc1 = fSC1; fa.dHid = fHID; fa.dpk2 = fPK2; fa.dsc2 = fSC2;
        fa.dOut1275 = fOUT; fa.dpk3 = fPK3; fa.dsc3 = fSC3;
        fa.face = nullptr; fa.scA = nullptr; fa.dpk2frag = nullptr; fa.dpk3frag = nullptr; fa.probe = nullptr;
        // the reference bytes (the 鐜伴摼 output planes + the split path's pack planes)
        std::vector<uint8_t> Rpk1, Rsc1, Rhid, Rpk2, Rsc2, Rout, Rpk3, Rsc3, Rres, RapE, RapP, RapR;
        const size_t faceBytes0 = (size_t)Mp*C;
        double delta = 0.0;
        const double FEXP = 2.0*M*C*HID, FCON = 2.0*M*C*HID, FRES = 2.0*M*C*C;
        int32_t* probe = (int32_t*)mk((size_t)7*(size_t)nblkOf(M,S::T)*64*4*4u);
        ffn2::Args fp = fa; fp.probe = probe;
        if (!(stage & 1)) {   // stage 2: the split chain and the 1a taps are never used -> release
            free(dO1,q); dO1=nullptr; free(dPK,q); dPK=nullptr; free(dSC,q); dSC=nullptr;
            free(dH,q); dH=nullptr; free(dOt,q); dOt=nullptr; free(dApH,q); dApH=nullptr;
            free(dBpPH,q); dBpPH=nullptr; free(dBpE,q); dBpE=nullptr;
            free(dWER,q); dWER=nullptr; free(dWEW,q); dWEW=nullptr;
            if (dWPR) { free(dWPR,q); dWPR=nullptr; } if (dWPHR) { free(dWPHR,q); dWPHR=nullptr; }
            free(dWRR,q); dWRR=nullptr; free(dO2,q); dO2=nullptr; fa.dOut = nullptr;
            free(dApE,q); dApE=nullptr; free(dApP,q); dApP=nullptr; free(dApR,q); dApR=nullptr;
            printf("-- C2 stage2: split pack planes released too --\n");
            free(fPK1,q); fPK1=nullptr; free(fSC1,q); fSC1=nullptr; free(fHID,q); fHID=nullptr;
            if (fPK2) { free(fPK2,q); fPK2=nullptr; } if (fSC2) { free(fSC2,q); fSC2=nullptr; }
            free(fOUT,q); fOUT=nullptr; free(fPK3,q); fPK3=nullptr; free(fSC3,q); fSC3=nullptr;
            fa.dpk1 = nullptr; fa.dsc1 = nullptr; fa.dHid = nullptr;
            fa.dpk2 = nullptr; fa.dsc2 = nullptr;
            fa.dOut1275 = nullptr; fa.dpk3 = nullptr; fa.dsc3 = nullptr;
            printf("-- C2 stage2: split/1a device planes released up front --\n");
        }

        // ---- control leg (the recorder's real launches for this family) ----
        std::vector<std::function<void()>> ops;
        std::vector<const char*> opname;
        if (!f16proj) {
            ops = {
                [&]{ qr_launch_esimd(q, dev, dIn, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)C); },
                [&]{ packdev::gather_pack_a_b_v(q, dPK, dApE, M, Mp, C, C, 0, b_e); },
                [&]{ s8v8::gemm_b_pub_slm<false>(q, dApE, dBpE, (void*)dH, dSC, dSE, M, Mp, N_e, C, b_e,
                                                 (size_t)N_e, (unsigned)HID, 0u, (unsigned)N_e, true, 3u); },
                [&]{ qr_launch_esimd(q, dev, dH, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)HID); },
                [&]{ packdev::gather_pack_a_b_v(q, dPK, dApP, M, Mp, HID, HID, 0, 1); },
                [&]{ s8v8::gemm_b_pub(q, dApP, dBpP, (void*)dOt, dSC, dSP, M, Mp, C, HID, 1,
                                      (size_t)0, (unsigned)C, 0u, 0u, true, 1u); },
                [&]{ packdev::pack_a_fused(q, dOt, dApR, dSC, M, Mp, C); },
                [&]{ s8v8::gemm_b_res(q, dApR, dBpR, (void*)dO1, dSC, dSR, (const void*)dIn, dCos,
                                      M, Mp, C, C, true, true, 1u); },
            };
            opname = {"op1 quant Kc", "op2 packA", "op2 gemm expand", "op3 quant Khid",
                      "op4 packA wide", "op4 gemm proj", "op5+6 pack_fused", "op6 gemm_res"};
        } else {
            ops = {
                [&]{ qr_launch_esimd(q, dev, dIn, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)C); },
                [&]{ packdev::gather_pack_a_b_v(q, dPK, dApE, M, Mp, C, C, 0, b_e); },
                [&]{ s8v8::gemm_b_pub_slm<false>(q, dApE, dBpE, (void*)dH, dSC, dSE, M, Mp, N_e, C, b_e,
                                                 (size_t)N_e, (unsigned)HID, 0u, (unsigned)N_e, true, 3u); },
                [&]{ packdev::gather_pack_a16_b(q, dH, dApH, M, Mp, K_p, HID, (size_t)K_p, 0, b_p); },
                [&]{ f16v1::gemm_b_pub_f16(q, dApH, dBpPH, (void*)dOt, M, Mp, N_p, K_p, b_p,
                                           1u, true, (size_t)0, (size_t)N_p, (unsigned)C, 0u); },
                [&]{ packdev::pack_a_fused(q, dOt, dApR, dSC, M, Mp, C); },
                [&]{ s8v8::gemm_b_res(q, dApR, dBpR, (void*)dO1, dSC, dSR, (const void*)dIn, dCos,
                                      M, Mp, C, C, true, true, 1u); },
            };
            opname = {"op1 quant Kc", "op2 packA", "op2 gemm expand", "op3 packA16",
                      "op3 gemm f16 pub", "op4+5 pack_fused", "op5 gemm_res"};
        }
        auto CHAIN = [&]{ for (auto& o : ops) o(); q.wait(); };

        size_t nC = (size_t)M*C, nH = (size_t)M*HID;
        if (stage & 1) {
        // diff pass with snapshots
        std::vector<uint8_t> cpk1(nC), csc1((size_t)M*4), chid(nH*2), cpk2, csc2, cout(nC*2), cpk3(nC), csc3((size_t)M*4), cres(nC*2);
        if (!f16proj) { cpk2.resize(nH); csc2.resize((size_t)M*4); }
        if (need_ctrl) {
        CHAIN();
        printf("-- chain warm done --\n");
        ops[0](); q.wait(); q.memcpy(cpk1.data(), dPK, nC); q.memcpy(csc1.data(), dSC, (size_t)M*4); q.wait();
        ops[1](); ops[2](); q.wait(); q.memcpy(chid.data(), dH, nH*2); q.wait();
        size_t nextop = 3;
        if (!f16proj) {
            ops[3](); q.wait(); q.memcpy(cpk2.data(), dPK, nH); q.memcpy(csc2.data(), dSC, (size_t)M*4); q.wait();
            ops[4](); ops[5](); q.wait(); q.memcpy(cout.data(), dOt, nC*2); q.wait();
            qr_launch_esimd(q, dev, dOt, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)C); q.wait();
            q.memcpy(cpk3.data(), dPK, nC); q.memcpy(csc3.data(), dSC, (size_t)M*4); q.wait();
            nextop = 6;
        } else {
            ops[3](); ops[4](); q.wait(); q.memcpy(cout.data(), dOt, nC*2); q.wait();
            qr_launch_esimd(q, dev, dOt, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)C); q.wait();
            q.memcpy(cpk3.data(), dPK, nC); q.memcpy(csc3.data(), dSC, (size_t)M*4); q.wait();
            nextop = 5;
        }
        for (size_t i = nextop; i < ops.size(); ++i) ops[i]();
        q.wait(); q.memcpy(cres.data(), dO1, nC*2); q.wait();
        printf("-- control snapshots done --\n");
        } else printf("-- M_MODE=%d: the split control chain is NOT run (the gate reads block3's c2ref instead) --\n", mode);

        // (fa was set up above, before the stage split)
        // phase smoke: the fused kernel truncated after each phase (DUMP=false), one
        // launch + wait each -- the first phase that hangs/kills the device is the bug.
        printf("-- fused phase smoke --\n");
        smoke<S>(fa, q, std::make_integer_sequence<int, S::NPH>{});
        std::vector<uint8_t> fpk1(nC), fsc1((size_t)M*4), fhid(nH*2), fpk2, fsc2, fout(nC*2), fpk3(nC), fsc3((size_t)M*4), fres(nC*2);
        if (!f16proj) { fpk2.resize(nH); fsc2.resize((size_t)M*4); }
        printf("-- fused dump --\n");
        if (need_dump) {
        // DECISIVE PROBE result (11:1x): poison fHID with A5A5 before the DUMP launch ->
        // reads 0x0000 after: the DUMP-store DOES execute but writes zeros in the DUMP=true
        // instantiation of the F16PROJ shape (bench-tool artifact; the register 'pub' is
        // demonstrably correct: out1275/1267 from the SAME launch are byte-exact vs ctrl).
        // For F16PROJ shapes the hidden plane is TRANSITIVELY PROVEN by out1275 == 0:
        // every 1275 row (256 outputs, random dense weights over all 1024 hidden elements)
        // would flip bytes if ANY hidden element of that row differed. hid checkpoint -> WARN.
        ffn2::fused<S, true, S::NPH>(q, fa).wait();
        printf("-- dump launch done --\n");
        {   // forensics: did the DUMP kernel actually write fHID? probes at 3 offsets
            uint16_t probe16[8];
            auto probe = [&](size_t halfOff, const char* lbl){
                probe16[0]=0xffff; for (int i=1;i<8;++i) probe16[i]=0xffff;
                q.memcpy(probe16, (const char*)fHID + halfOff*2, 16).wait();
                printf("  fHID %s (half@%zu) = %04X %04X %04X %04X %04X %04X %04X %04X\n",
                       lbl, halfOff, probe16[0],probe16[1],probe16[2],probe16[3],probe16[4],probe16[5],probe16[6],probe16[7]);
            };
            probe(0, "row0col0"); probe((size_t)(M/2)*HID, "midrow"); probe((size_t)(M-1)*HID + 6, "lastrow");
        }
        q.memcpy(fpk1.data(), fPK1, nC); q.memcpy(fsc1.data(), fSC1, (size_t)M*4);
        q.memcpy(fhid.data(), fHID, nH*2);
        if (!f16proj) { q.memcpy(fpk2.data(), fPK2, nH); q.memcpy(fsc2.data(), fSC2, (size_t)M*4); }
        q.memcpy(fout.data(), fOUT, nC*2); q.memcpy(fpk3.data(), fPK3, nC); q.memcpy(fsc3.data(), fSC3, (size_t)M*4);
        q.memcpy(fres.data(), dO2, nC*2); q.wait();

        bool ok = true;
        if (need_ctrl) {
        printf("-- diff --\n");
        ok &= diffbytes(cpk1.data(), fpk1.data(), nC, C, "pk1");
        ok &= diffbytes(csc1.data(), fsc1.data(), (size_t)M*4, 1, "sc1");
        if (f16proj) {
            if (!diffbytes(chid.data(), fhid.data(), nH*2, HID, "hid"))
                printf("  (hid = DUMP-tool artifact; TRANSITIVELY implied by out1275==0 -- proceeding, see header note)\n");
        } else ok &= diffbytes(chid.data(), fhid.data(), nH*2, HID, "hid");
        if (!f16proj) {
            ok &= diffbytes(cpk2.data(), fpk2.data(), nH, HID, "pk2");
            ok &= diffbytes(csc2.data(), fsc2.data(), (size_t)M*4, 1, "sc2");
        }
        ok &= diffbytes(cout.data(), fout.data(), nC*2, C, "out1275");
        ok &= diffbytes(cpk3.data(), fpk3.data(), nC, C, "pk3");
        ok &= diffbytes(csc3.data(), fsc3.data(), (size_t)M*4, 1, "sc3");
        ok &= diffbytes(cres.data(), fres.data(), nC*2, C, "1267-FINAL");
        if (!ok) { printf("GATE FAIL %s -- entry ticket missing\n", tag); return 0.0; }
        printf("GATE PASS %s\n", tag);
        }   // if (need_ctrl)

        // ================= M-SHOVEL ENTRY TICKET: the PRICED chain (ffn2) vs BLOCK3's bytes =====
        // block3 (the untouched 1a copy, MD5 4299658C...) wrote E:/DSH/s6/c2ref_<shid>.bin with
        // its 13 checkpoints green. This diff is CHAIN vs CHAIN, byte for byte, no relaxation:
        // it is the M1/M2 gate for the leg this shovel actually prices (ffn2::fused).
        {
            char rp[128]; snprintf(rp, sizeof(rp), "E:/DSH/s6/c2ref_%s.bin", shid);
            FILE* rd = fopen(rp, "rb");
            if (!rd) { printf("B3GATE: MISSING %s -- entry ticket cannot be taken\n", rp); return 0.0; }
            uint64_t lens[12]; if (fread(lens, sizeof(lens), 1, rd) != 1) { fclose(rd); printf("B3GATE: short header\n"); return 0.0; }
            // hard size check BEFORE any compare: reading past a host vector = the 军规 21 class of bug
            const size_t expsz[12] = { nC, (size_t)M*4, nH*2, nH, (size_t)M*4, nC*2, nC, (size_t)M*4,
                                       nC*2, faceBytes0, (size_t)Mp*HID, faceBytes0 };
            for (size_t i = 0; i < 12; ++i) if (lens[i] != expsz[i]) {
                printf("B3GATE SIZE MISMATCH seg %zu: ref=%llu mine=%zu -- STOP\n", i,
                       (unsigned long long)lens[i], expsz[i]);
                fclose(rd); return 0.0;
            }
            size_t off = 0;
            for (auto* v : { &Rpk1,&Rsc1,&Rhid,&Rpk2,&Rsc2,&Rout,&Rpk3,&Rsc3,&Rres,&RapE,&RapP,&RapR }) {
                v->resize((size_t)lens[off]);
                if (fread(v->data(), 1, (size_t)lens[off], rd) != (size_t)lens[off]) {
                    printf("B3GATE: short blob in segment %zu\n", off); fclose(rd); return 0.0; }
                ++off;
            }
            fclose(rd);
            // ---- M-FLAKY PROBE (env M_REPEAT=N, N>=2): re-launch the DUMP kernel N times in THIS
            // process, poisoning every tap plane with 0xA5 before each launch, and diff each launch
            // against block3's bytes. A single launch cannot tell a RACE from a BUG; N launches can:
            //   identical diff sets  => deterministic bug (index arithmetic);
            //   varying diff sets   => the SLM handoff between phases is racy.
            // 0xA5 in "mine" = the launch never wrote that byte; anything else = a stale/garbage read.
            const int nrep = getenv("M_REPEAT") ? atoi(getenv("M_REPEAT")) : 1;
            // P20 control for the historical "1/158" reading: was it the harness (no submit barrier
            // between the 0xA5 scrub and the launch) or the kernel? M_REPEAT_BAR=1 (default) adds
            // ext_oneapi_submit_barrier(); =0 reproduces the original wait-only probe.
            const int RBAR = getenv("M_REPEAT_BAR") ? atoi(getenv("M_REPEAT_BAR")) : 1;
            if (nrep > 1) {
                int nbad = 0;
                printf("-- M flaky probe: %d DUMP launches, taps poisoned 0xA5, vs block3 --\n", nrep);
                for (int rep = 0; rep < nrep; ++rep) {
                    q.memset(fPK1, 0xA5, nC); q.memset(fSC1, 0xA5, (size_t)M*4);
                    q.memset(fHID, 0xA5, nH*2);
                    if (fPK2) { q.memset(fPK2, 0xA5, nH); q.memset(fSC2, 0xA5, (size_t)M*4); }
                    q.memset(fOUT, 0xA5, nC*2); q.memset(fPK3, 0xA5, nC); q.memset(fSC3, 0xA5, (size_t)M*4);
                    q.memset(dO2, 0xA5, nC*2);
                    q.wait();
                    if (RBAR) q.ext_oneapi_submit_barrier();
                    ffn2::fused<S, true, S::NPH>(q, fa).wait();
                    if (RBAR) q.ext_oneapi_submit_barrier();
                    q.memcpy(fpk1.data(), fPK1, nC); q.memcpy(fsc1.data(), fSC1, (size_t)M*4);
                    q.memcpy(fhid.data(), fHID, nH*2);
                    if (!f16proj) { q.memcpy(fpk2.data(), fPK2, nH); q.memcpy(fsc2.data(), fSC2, (size_t)M*4); }
                    q.memcpy(fout.data(), fOUT, nC*2); q.memcpy(fpk3.data(), fPK3, nC); q.memcpy(fsc3.data(), fSC3, (size_t)M*4);
                    q.memcpy(fres.data(), dO2, nC*2); q.wait();
                    bool okr = true;
                    okr &= diffbytes(Rpk1.data(), fpk1.data(), Rpk1.size(), C,   "rep pk1");
                    okr &= diffbytes(Rsc1.data(), fsc1.data(), Rsc1.size(), 1,   "rep sc1");
                    okr &= diffbytes(Rhid.data(), fhid.data(), Rhid.size(), HID, "rep hid");
                    if (!f16proj) {
                        okr &= diffbytes(Rpk2.data(), fpk2.data(), Rpk2.size(), HID, "rep pk2");
                        okr &= diffbytes(Rsc2.data(), fsc2.data(), Rsc2.size(), 1,   "rep sc2");
                    }
                    okr &= diffbytes(Rout.data(), fout.data(), Rout.size(), C, "rep out1275");
                    okr &= diffbytes(Rpk3.data(), fpk3.data(), Rpk3.size(), C, "rep pk3");
                    okr &= diffbytes(Rsc3.data(), fsc3.data(), Rsc3.size(), 1, "rep sc3");
                    okr &= diffbytes(Rres.data(), fres.data(), Rres.size(), C, "rep 1267-FINAL");
                    printf("REPEAT %d %-22s %s\n", rep, shid, okr ? "CLEAN" : "DIFF");
                    fflush(stdout);
                    if (!okr) ++nbad;
                }
                printf("FLAKY %s: %d of %d DUMP launches differ from block3 (bar=%d) -- %s\n", shid, nbad, nrep, RBAR,
                       nbad ? "NON-DETERMINISTIC (a real SLM handoff race, not an index bug)"
                            : "all launches bit-identical to block3");
                fflush(stdout);
            }
            printf("-- M cross-gate: ffn2 taps vs block3 c2ref (%s) --\n", shid);
            bool okb = true;
            okb &= diffbytes(Rpk1.data(), fpk1.data(), Rpk1.size(), C,   "B3pk1");
            okb &= diffbytes(Rsc1.data(), fsc1.data(), Rsc1.size(), 1,   "B3sc1");
            okb &= diffbytes(Rhid.data(), fhid.data(), Rhid.size(), HID, "B3hid");
            if (!f16proj) {
                okb &= diffbytes(Rpk2.data(), fpk2.data(), Rpk2.size(), HID, "B3pk2");
                okb &= diffbytes(Rsc2.data(), fsc2.data(), Rsc2.size(), 1,   "B3sc2");
            }
            okb &= diffbytes(Rout.data(), fout.data(), Rout.size(), C, "B3out1275");
            okb &= diffbytes(Rpk3.data(), fpk3.data(), Rpk3.size(), C, "B3pk3");
            okb &= diffbytes(Rsc3.data(), fsc3.data(), Rsc3.size(), 1, "B3sc3");
            okb &= diffbytes(Rres.data(), fres.data(), Rres.size(), C, "B3-1267-FINAL");
            if (!okb) { printf("B3GATE FAIL %s -- MIXED CHAIN != block3 BYTES; STOP\n", tag); return 0.0; }
            printf("B3GATE PASS %s (9 ffn2 checkpoints vs block3)\n", tag);
        }
        }   // if (need_dump)

        // ================= C2 STEP 1a: chain-EXTERNAL legs (the 鐜拌矾 split path) =================
        // pack_a (activation packing) legs are the ones R1 kills; the weight packs (pack_b) are
        // cache-owned in shipped (s6_pack_bexp_wide / s6_pack_bproj_wide / cached_pack_b_i8 =>
        // g_wcache), so they are priced as ONE-TIME setup, not per frame.
        Stat wallC{}; bool have_wallC = false;
        if (need_ctrl) {
         printf("-- C2 per-leg wall (split path, launch included) --\n");
         double sum = 0;
         for (size_t i = 0; i < ops.size(); ++i) {
             Stat r = timeit_wall([&]{ ops[i](); q.wait(); });
             printf("  %-18s msM=%7.4f msm=%7.4f msX=%7.4f med=%7.4f\n", opname[i], r.msM, r.msm, r.msX, r.med);
             double fl = 0.0;
             if (!f16proj) fl = (i==2)?FEXP : (i==5)?FCON : (i==7)?FRES : 0.0;
             char ex[160]; snprintf(ex, sizeof(ex), "wall basis; leg %zu of the split chain", i+1);
             csvrow(shid, opname[i], r, fl, ex);
             sum += r.msM;
         }
         printf("  SUM=%7.4f\n", sum);
         // the weight packs (pack_b family): re-run + time (idempotent pure gather => same bytes).
         {
             Stat r1 = timeit_wall([&]{ packdev::gather_pack_b_b(q, dWER, dBpE, N_e, C, C, (size_t)N_e*C, b_e); q.wait(); });
             csvrow(shid, "setup_pack_b_expand_batched", r1, 0.0, "pack_b, cache-owned in shipped (NOT per frame)");
             Stat r2 = timeit_wall([&]{ packdev::pack_b(q, dWEW, dBpEW, HID, C); q.wait(); });
             csvrow(shid, "setup_pack_b_expand_wide", r2, 0.0, "pack_b wide (the fused chain's Bexp), cache-owned");
             Stat r3 = timeit_wall([&]{ packdev::gather_pack_b_diag_b(q, dWPR, dBpP, N_p, K_p, K_p, (size_t)N_p*K_p, b_p); q.wait(); });
             csvrow(shid, "setup_pack_b_proj_wide", r3, 0.0, "pack_b diag-wide (the fused chain's Bproj), cache-owned");
             Stat r4 = timeit_wall([&]{ packdev::pack_b(q, dWRR, dBpR, C, C); q.wait(); });
             csvrow(shid, "setup_pack_b_res", r4, 0.0, "pack_b (the fused chain's Bres), cache-owned");
         }
         wallC = timeit_wall(CHAIN); have_wallC = true;
         csvrow(shid, "SPLIT_chain_wall", wallC, FEXP+FCON+FRES, "鐜拌矾 8-leg chain wall (the 0.8139/0.5898 anchor)");
        }
        if (need_price) {
         Stat wallF = timeit_wall([&]{ ffn2::fused<S, false, S::NPH>(q, fa).wait(); });
         Stat gpuF  = timeit([&]{ return ffn2::fused<S, false, S::NPH>(q, fa); });
         if (have_wallC) printf("-- totals: chain wall msM=%.4f [gm=%s] | fused wall msM=%.4f [gm=%s] | fused GPU=%.4f\n",
                wallC.msM, gmfmt(wallC), wallF.msM, gmfmt(wallF), gpuF.msM);
         else printf("-- totals: (control not run) | MIXED wall msM=%.4f [gm=%s] | MIXED GPU=%.4f [gm=%s]\n",
                wallF.msM, gmfmt(wallF), gpuF.msM, gmfmt(gpuF));
         csvrow(shid, "1a_fused_wall", wallF, FEXP+FCON+FRES, "MIXED chain (M1/M2 form), ONE launch, wall");
         csvrow(shid, "1a_fused_gpu", gpuF, FEXP+FCON+FRES, "MIXED chain, GPU event time");
         printf("-- M phase bisection (DUMP=false, GPU msM; NARROW sink cross-check) --\n");
         bisect_seq<K2, S, 1, S::NPH>(fp, q, shid, FEXP, FCON, FRES,
                                      std::make_integer_sequence<int, S::NPH>{});
         if (have_wallC) {
            delta = wallF.msM - wallC.msM;
            printf("DELTA %s = %+.4f ms/chain (mixed %.4f - chain %.4f)\n", tag, delta, wallF.msM, wallC.msM);
         }
        }   // if (need_price)

        // ---- C2: release every device plane whose bytes are already in host snapshots.
        // The A770's allocatable window is the binding limit here (the first STEP-2 allocation
        // round died with UR_RESULT_ERROR_OUT_OF_DEVICE_MEMORY at ~250 MB resident) and the
        // ffn3 taps need ~60 MB more. The gates read the HOST copies
        // (cpk1/csc1/chid/cpk2/csc2/cout/cpk3/csc3/cres + fpk1/fsc1/fhid/fpk2/fsc2/fout/fpk3/
        // fsc3/fres), so the device originals are dead weight from here on. hApE/hApP/hApR are
        // pulled across first because the fragment-order checkpoints read them.
        const size_t faceBytes = faceBytes0;
        std::vector<uint8_t> hApE((size_t)b_e*faceBytes), hApP((size_t)Mp*HID), hApR(faceBytes);
        d2h(q, hApE.data(), dApE, hApE.size(), "hApE");
        d2h(q, hApP.data(), dApP, hApP.size(), "hApP");
        d2h(q, hApR.data(), dApR, hApR.size(), "hApR");
        d2h_report();
        free(dApE,q); dApE=nullptr; free(dApP,q); dApP=nullptr; free(dApR,q); dApR=nullptr;
        free(dO1,q); dO1=nullptr; free(dO2,q); dO2=nullptr; fa.dOut=nullptr;
        free(dPK,q); free(dSC,q); free(dH,q); free(dOt,q);
        free(dApH,q); free(dBpPH,q); free(dBpE,q); free(dWER,q); free(dWEW,q);
        if (dWPR) free(dWPR,q); if (dWPHR) free(dWPHR,q);
        free(fPK1,q); free(fSC1,q); free(fHID,q); if(fPK2) free(fPK2,q); if(fSC2) free(fSC2,q);
        free(fOUT,q); free(fPK3,q); free(fSC3,q);
        fa.dpk1 = nullptr; fa.dsc1 = nullptr; fa.dHid = nullptr;
        fa.dpk2 = nullptr; fa.dsc2 = nullptr;
        fa.dOut1275 = nullptr; fa.dpk3 = nullptr; fa.dsc3 = nullptr;
        dPK=nullptr; dSC=nullptr; dH=nullptr; dOt=nullptr; dApH=nullptr; dBpPH=nullptr;
        dBpE=nullptr; dWER=nullptr; dWEW=nullptr; dWPR=nullptr; dWPHR=nullptr;
        fPK1=nullptr; fSC1=nullptr; fHID=nullptr; fPK2=nullptr; fSC2=nullptr;
        fOUT=nullptr; fPK3=nullptr; fSC3=nullptr;
        printf("-- C2: control + ffn2 device planes released (host snapshots kept) --\n");
        // hand the current chain's bytes to the stage-2 process (the 13-checkpoint reference).
        // ONLY in the full flow (mode 0): in gate/price modes block3's c2ref is the reference and
        // nothing here may look like it re-based the ticket.
        if (mode == 0) {
        Rpk1 = fpk1; Rsc1 = fsc1; Rhid = fhid; Rpk2 = fpk2; Rsc2 = fsc2; Rout = fout;
        Rpk3 = fpk3; Rsc3 = fsc3; Rres = fres;
        RapE.assign(hApE.begin(), hApE.begin() + (long)faceBytes); RapP = hApP; RapR = hApR;
        {
            char path[128]; snprintf(path, sizeof(path), "E:/DSH/s6/c4ref_%s.bin", shid);   // NEVER clobber block3's c2ref
            FILE* w = fopen(path, "wb");
            if (w) {
                const uint64_t lens[12] = { Rpk1.size(), Rsc1.size(), Rhid.size(), Rpk2.size(),
                                            Rsc2.size(), Rout.size(), Rpk3.size(), Rsc3.size(),
                                            Rres.size(), RapE.size(), RapP.size(), RapR.size() };
                fwrite(lens, sizeof(lens), 1, w);
                for (auto* v : { &Rpk1,&Rsc1,&Rhid,&Rpk2,&Rsc2,&Rout,&Rpk3,&Rsc3,&Rres,&RapE,&RapP,&RapR })
                    fwrite(v->data(), 1, v->size(), w);
                fclose(w);
                printf("-- C2: wrote %s (%.1f MB of reference bytes) --\n", path,
                       (double)(Rpk1.size()+Rsc1.size()+Rhid.size()+Rpk2.size()+Rsc2.size()+Rout.size()
                                +Rpk3.size()+Rsc3.size()+Rres.size()+RapE.size()+RapP.size()+RapR.size())/1e6);
            } else printf("-- C2: CANNOT write %s --\n", path);
        }
        }   // if (mode == 0) -- the c4ref hand-off
        } // if (stage & 1)

        // ================= C2 STEP 2: R1 zero pack (ffn3) =================
        // The producer = packdev::pack_a_fused, the SAME shipped single-read quantizer the
        // residual leg already uses (pack_device.hpp:123): it quantizes the f16 row ONCE and
        // tile-scatters the int8 bytes straight into the pack_a fragment order. So the chain
        // needs NO P1 (no in-chain quant, no in-chain pack) and there is no separate pack_a
        // pass either -- exactly R1 of port-B (port_ffn_fused.cpp:247/:261-263 + setup :501).
        if (stage & 2) {
        if (!(stage & 1)) {   // stage 2: pull the reference bytes the stage-1 process wrote
            char path[128]; snprintf(path, sizeof(path), "E:/DSH/s6/c2ref_%s.bin", shid);
            FILE* rd = fopen(path, "rb");
            if (!rd) { printf("NO REF FILE %s -- run C2_STAGE=1 first\n", path); return 0.0; }
            uint64_t lens[12]; fread(lens, sizeof(lens), 1, rd);
            size_t off = 0;
            for (auto* v : { &Rpk1,&Rsc1,&Rhid,&Rpk2,&Rsc2,&Rout,&Rpk3,&Rsc3,&Rres,&RapE,&RapP,&RapR }) {
                v->resize((size_t)lens[off]); fread(v->data(), 1, (size_t)lens[off], rd); ++off; }
            fclose(rd);
            printf("-- C2 stage2: loaded the 13-checkpoint reference (%.1f MB) --\n",
                   (double)(Rpk1.size()+Rsc1.size()+Rhid.size()+Rpk2.size()+Rsc2.size()+Rout.size()
                            +Rpk3.size()+Rsc3.size()+Rres.size()+RapE.size()+RapP.size()+RapR.size())/1e6);
        }
        {
            printf("  [dev] global_mem_size=%llu MB  local=%llu  maxWG=%u\n",
                   (unsigned long long)dev.get_info<info::device::global_mem_size>()/1048576ull,
                   (unsigned long long)dev.get_info<info::device::local_mem_size>(),
                   dev.get_info<info::device::max_work_group_size>());
            auto mkp = [&](const char* nm, size_t bytes) -> void* {
                printf("  alloc %-10s %9.2f MB\n", nm, bytes/1e6); fflush(stdout);
                void* p = mk(bytes); fflush(stdout); return p;
            };
            int8_t* faceB  = (int8_t*)mkp("faceB", faceBytes0);      // one-pass producer (R1)
            float*  scB    = (float*)mkp("scB",(size_t)Mp*4);
            int8_t* faceA  = (int8_t*)mkp("faceA",faceBytes0);            // 鐜拌矾 two-pass: qr then retile
            int8_t* pkT    = (int8_t*)mkp("pkT",(size_t)Mp*C);
            float*  scT    = (float*)mkp("scT",(size_t)Mp*4);
            // ffn3 taps
            half* gHID = (half*)mkp("gHID",nH*2); int8_t* gPK2 = (int8_t*)mkp("gPK2",nH); float* gSC2 = (float*)mkp("gSC2",(size_t)M*4);
            half* gOUT = (half*)mkp("gOUT",nC*2); int8_t* gPK3 = (int8_t*)mkp("gPK3",nC); float* gSC3 = (float*)mkp("gSC3",(size_t)M*4);
            int8_t* gPK2F = (int8_t*)mkp("gPK2F",(size_t)Mp*HID); int8_t* gPK3F = (int8_t*)mkp("gPK3F",faceBytes0);
            half* dO3 = (half*)mkp("dO3",nC*2);
            memprobe(q, "after STEP2 allocations");
            auto PROD_B = [&]{ packdev::pack_a_fused(q, dIn, faceB, scB, M, Mp, C); };
            Stat prodB{}, q1{}, ra{};
            if (getenv("C2_NOTIMING")) {   // diagnostic: 225 extra launches precede the D2H; skip them to see
                printf("-- C2: producer TIMING skipped (C2_NOTIMING) --\n");   // whether the copy still refuses to start
                PROD_B(); q.wait();
                qr_launch_esimd(q, dev, dIn, (sycl::uint2*)pkT, scT, (unsigned)M, (unsigned)C); q.wait();
                ffn3::retile_a(q, pkT, faceA, M, Mp, C); q.wait();
            } else { prodB = timeit_wall([&]{ PROD_B(); q.wait(); });
            csvrow(shid, "R1_producer_quant+fragstore", prodB, 0.0, "ONE leg: quantize + fragment-order store (pack_a_fused)");
            // the 鐜拌矾 two-pass producer, for the leg-by-leg comparison the same knife pays for
                q1 = timeit_wall([&]{ qr_launch_esimd(q, dev, dIn, (sycl::uint2*)pkT, scT, (unsigned)M, (unsigned)C); q.wait(); });
                ra = timeit_wall([&]{ ffn3::retile_a(q, pkT, faceA, M, Mp, C); q.wait(); });
            }
            csvrow(shid, "split_producer_quant_rowmajor", q1, 0.0, "op1 quant (row-major pk) -- the pre-R1 producer half 1");
            csvrow(shid, "split_producer_retile_a", ra, 0.0, "the pure pack_a permutation -- the leg R1 deletes");
            // gate: the producer's face must be the 现路 pk plane in fragment order, byte for byte
            std::vector<uint8_t> hFaceB(faceBytes0), hFaceA(faceBytes0);
            // *** C2-6 RE-QUALIFIED (this run): the OOM(39) was NOT the host-pinned/staging quota.
            // scB/scT are device buffers of Mp FLOATS = Mp*4 BYTES (130,560 B for S1), but the old
            // host side was `std::vector<float> h(Mp*4)` = 4x too many floats and the copy asked for
            // h.size()*4 = 522,240 bytes => an OUT-OF-RANGE device read past a 130,560-byte USM
            // allocation. Level Zero reports that as UR_RESULT_ERROR_OUT_OF_DEVICE_MEMORY(39) while a
            // 1074 MB single alloc still succeeds -- exactly the C2-6 signature. The 2.09 MB faceB /
            // faceA copies through this same route are FINE (see the d2h ledger below).
            std::vector<float> hScB((size_t)Mp), hScT((size_t)Mp);
            try {
                printf("  D2H faceB/faceA: bytes = Mp*C = %d*%d = %zu; scB/scT = Mp floats = %zu bytes  (route = malloc_host 1MB chunks)\n",
                       Mp, C, faceBytes0, (size_t)Mp*4);
                d2h(q, hFaceB.data(), faceB, faceBytes0, "faceB");
                d2h(q, hFaceA.data(), faceA, faceBytes0, "faceA");
                d2h(q, hScB.data(), scB, hScB.size()*4, "scB");
                d2h(q, hScT.data(), scT, hScT.size()*4, "scT");
                d2h_report();
                memprobe(q, "after STEP2 gate D2H");
            } catch (const sycl::exception& e) {
                printf("THREW at the STEP2 D2H: %s (code=%d)\n", e.what(), e.code() ? e.code().value() : -1);
                memprobe(q, "at STEP2 D2H throw");
                throw;
            }
            bool ok3 = true;
            printf("-- C2 ffn3 producer gate --\n");
            ok3 &= diff_face(hFaceA.data(), Rpk1.data(), M, C, "pk1");
            ok3 &= diffbytes(hFaceB.data(), RapE.data(), faceBytes0, C, "pk1-face");
            ok3 &= diffbytes((const uint8_t*)hScB.data(), (const uint8_t*)hScT.data(), (size_t)M*4, 1, "sc1");
            ok3 &= diffbytes(hFaceB.data(), hFaceA.data(), faceBytes0, C, "faceA-vs-faceB");
            printf("-- C2 ffn3 phase smoke --\n");
            ffn2::Args f3 = fp;   // f3 keeps the ffn2 taps OFF; set the ffn3 ones below
            f3.dIn = dIn; f3.dOut = dO3; f3.face = faceB; f3.scA = scB;
            f3.dpk1 = nullptr; f3.dsc1 = nullptr; f3.dHid = gHID; f3.dpk2 = gPK2; f3.dsc2 = gSC2;
            f3.dOut1275 = gOUT; f3.dpk3 = gPK3; f3.dsc3 = gSC3;
            f3.dpk2frag = gPK2F; f3.dpk3frag = gPK3F; f3.probe = probe;
            smoke3<S>(f3, q, std::make_integer_sequence<int, S::NPH-1>{});
            ffn3::fused<S, true, S::NPH-1, 0>(q, f3).wait();
            std::vector<uint8_t> ghid(nH*2), gpk2(nH), gpk2f((size_t)Mp*HID), gs2((size_t)M*4),
                                 gout(nC*2), gpk3(nC), gpk3f(faceBytes0), gs3((size_t)M*4), gres(nC*2);
            d2h(q, ghid.data(),  gHID,  nH*2,          "ghid");
            d2h(q, gpk2.data(),  gPK2,  nH,            "gpk2");
            d2h(q, gpk2f.data(), gPK2F, (size_t)Mp*HID,"gpk2f");
            d2h(q, gs2.data(),   gSC2,  (size_t)M*4,   "gs2");
            d2h(q, gout.data(),  gOUT,  nC*2,          "gout");
            d2h(q, gpk3.data(),  gPK3,  nC,            "gpk3");
            d2h(q, gpk3f.data(), gPK3F, faceBytes0,    "gpk3f");
            d2h(q, gs3.data(),   gSC3,  (size_t)M*4,   "gs3");
            d2h(q, gres.data(),  dO3,   nC*2,          "gres");
            d2h_report();
            memprobe(q, "after STEP2 tap D2H");
            printf("-- C2 ffn3 diff (13 checkpoints, vs the 鐜伴摼 + the split control) --\n");
            ok3 &= diffbytes(ghid.data(),  Rhid.data(),  nH*2,        HID, "hid");
            ok3 &= diffbytes(gpk2.data(),  Rpk2.data(),  nH,          HID, "pk2");
            ok3 &= diffbytes(gpk2f.data(), RapP.data(),  (size_t)Mp*HID, HID, "pk2-frag");
            ok3 &= diffbytes(gs2.data(),   Rsc2.data(),  (size_t)M*4, 1,   "sc2");
            ok3 &= diffbytes(gout.data(),  Rout.data(),  nC*2,        C,   "out1275");
            ok3 &= diffbytes(gpk3.data(),  Rpk3.data(),  nC,          C,   "pk3");
            ok3 &= diffbytes(gpk3f.data(), RapR.data(),  faceBytes0,  C,   "pk3-frag");
            ok3 &= diffbytes(gs3.data(),   Rsc3.data(),  (size_t)M*4, 1,   "sc3");
            ok3 &= diffbytes(gres.data(),  Rres.data(),  nC*2,        C,   "1267-FINAL");
            if (!ok3) { printf("GATE FAIL C2-R1 %s -- entry ticket missing; STOP\n", tag); }
            else      { printf("GATE PASS C2-R1 %s (13/13 diff=0)\n", tag); }
            // pricing of the zero-pack chain
            Stat wall3 = timeit_wall([&]{ ffn3::fused<S, false, S::NPH-1, 0>(q, f3).wait(); });
            Stat gpu3  = timeit([&]{ return ffn3::fused<S, false, S::NPH-1, 0>(q, f3); });
            csvrow(shid, "1aR1_chain_wall", wall3, FEXP+FCON+FRES, "1a + R1 zero pack: chain ONLY (P1 gone), one launch");
            csvrow(shid, "1aR1_chain_gpu",  gpu3,  FEXP+FCON+FRES, "GPU event time, same");
            Stat wall3p = timeit_wall([&]{ PROD_B(); ffn3::fused<S, false, S::NPH-1, 0>(q, f3).wait(); });
            csvrow(shid, "1aR1_with_producer_wall", wall3p, FEXP+FCON+FRES, "honest all-in: producer leg + chain");
            printf("-- C2 ffn3 phase bisection --\n");
            if (getenv("C2_SKIPBISECT")) printf("-- C2: ffn3 phase bisection skipped (C2_SKIPBISECT) --\n");
            else bisect_seq<K3, S, 2, S::NPH-1>(f3, q, shid, FEXP, FCON, FRES,
                                           std::make_integer_sequence<int, S::NPH-1>{});
            printf("R1 GAIN %s: 1aR1 chain wall %.4f | GPU %.4f | all-in(producer+chain) %.4f\n",
                   tag, wall3.msM, gpu3.msM, wall3p.msM);
            free(faceB,q); free(scB,q); free(faceA,q); free(pkT,q); free(scT,q);
            free(gHID,q); free(gPK2,q); free(gSC2,q); free(gOUT,q); free(gPK3,q); free(gSC3,q);
            free(gPK2F,q); free(gPK3F,q); free(dO3,q); free(probe,q);
        }
        } // if (stage & 2)
        // free this shape's buffers
        free(dIn,q); free(dO1,q); free(dO2,q); free(dPK,q); free(dSC,q); free(dH,q); free(dOt,q);
        free(dApE,q); free(dApP,q); free(dApH,q); free(dApR,q); free(dBpE,q); free(dBpEW,q);
        free(dBpP,q); free(dBpPH,q); free(dBpR,q); free(dSE,q); free(dSP,q); free(dSR,q); free(dCos,q);
        free(dWER,q); if(dWPR) free(dWPR,q); if(dWPHR) free(dWPHR,q); free(dWRR,q); free(dWEW,q);
        free(fPK1,q); free(fSC1,q); free(fHID,q); if(fPK2) free(fPK2,q); if(fSC2) free(fSC2,q);
        free(fOUT,q); free(fPK3,q); free(fSC3,q);
        return delta;
    };

    const int which = getenv("C2_SHAPE") ? atoi(getenv("C2_SHAPE")) : 1;   // 1=S1 2=S2 (own process each)
    if (which & 1)
    dS1 = run_shape("S1 C=64 M=32640", "S1", 32640, 64, 256, 128, 2, 32, 128, 2, false,
                    (ffn2::Shape<32,64,256,false,4,2>){});
    if (which & 2)
    dS2 = run_shape("S2 C=128 M=8160", "S2", 8160, 128, 512, 128, 4, 32, 128, 4, false,
                    (ffn2::Shape<16,128,512,false,4,2>){});

    printf("\n==== C2 note: this run is per-shape; run each shape in its OWN process (C2_SHAPE=1|2) ====\n");
    printf("  dS1 = fused-vs-split delta (S6-1a stage-2 number, re-measured here)\n");
    return 0;
}
int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);   // crash forensics: keep the progress trace
    try { return run_all(); }
    catch (const sycl::exception& e) { printf("SYCL EXC: %s (code=%d)\n", e.what(), e.code() ? e.code().value() : -1); return 3; }
    catch (const std::exception& e) { printf("EXC: %s\n", e.what()); return 4; }
}
