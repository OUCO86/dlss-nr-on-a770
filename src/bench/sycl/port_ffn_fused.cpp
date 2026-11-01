// port_ffn_fused.cpp -- S6-1b PORT phase B: FAITHFUL port of
//   E:\DSH\backup\pre-port-2026-11-01\lmxx_src_ref\native_wave_ffn_fused.hlsl (101 lines)
// into ONE ESIMD kernel, plus a byte-for-byte diff against the shipped (现路) FFN chain.
// B stage = correctness ONLY (no pricing, no S3, no wiring, no shipped edits).
//
// ---------------- BLUEBOOK MAPPING (their line -> our line, see port_B.md) ----------------
//   :51  if(gid.x*16>=width*height)return;   -> R7 linear 16-token groups + WG-UNIFORM cull
//   :55  for g < MATRIX_CHANNELS/32          -> PHASE 1 kb loop, K step = 32 (R6)
//   :56  A::Load(input, gid.x*16*C+g*32,C,RowMajor,16)
//                                          -> R1 ZERO PACK: the input face arrives from setup
//                                            already in dpas-A fragment order (16 tok x 32K =
//                                            512B blocks, group-major); the kernel only does
//                                            block_load of the fragment (256B halves).
//   :60/:85 B::Load(weights,((col/16)*(K/32)+g)*512,16,RowMajor,16)  [NATIVE_TILED_WEIGHTS]
//                                          -> R2: Wexp/Wproj are pre-tiled ONCE in setup into
//                                            exactly that 512B block order (cb-major outer,
//                                            kb inner); run-time = zero pack_b.
//   :64  Multiply / MultiplyAccumulate      -> T3: ESIMD dpas<8,8,int32_t>, 4 per 16x16 tile
//                                            (A rows = tokens in the SECOND operand slot, the
//                                            weights in the FIRST -- the shipped gemm_s8_v8
//                                            convention, gemm_s8_v8_kernel.hpp:678).
//   :67-73 Activate() = gate + Ffast(e4m3)  -> s8v8::pub_vec_v8(3u, ...) (gate_vec_v8 +
//                                            e4m3_vec_v8). Our shipped publish IS the e4m3 grid
//                                            (port.md 0.1-1), so this is not a grid change.
//   :75  acc.Cast<OPERAND>().Store(hidden)  -> R4: the accumulator registers encode to e4m3
//                                            BYTES and land straight in SLM (their LDS hidden
//                                            is e4m3 too, 16 x 4C bytes -- same 16B/row store).
//   :78  GroupMemoryBarrierWithGroupSync()  -> R5: group_barrier(it.get_group()). TOOLCHAIN
//                                            DEVIATION: this oneAPI has NO sycl::fence_option
//                                            (group_barrier(gr, fence_option::CTA) does not
//                                            compile), so the barrier is the shipped form every
//                                            SLM-sharing core here uses. Never bypassed by a
//                                            conditional: NPHASE is compile-time (= work-group
//                                            uniform) and the R7 cull is written WG-uniform.
//   :83  A::Load(hidden, g*32/4, HIDDEN/4)  -> R4: the contract loads the SLM hidden as INT8
//                                            (T1 requant, in place at the same fragment
//                                            offsets); the scale is multiplied in the EPILOGUE.
//   :92  Ffast(H(acc))                      -> T1: our shipped contract epilogue is
//                                            pub_vec_v8(1u, acc*row_scale*col_scale) -- e4m3
//                                            only, NO extra f16 pre-round (that IS the shipped
//                                            numerics chain; do not "improve" it here).
//   :96/:98 acc.Store(output,...)            -> the 1275 out plane (f16) + an SLM copy feeding
//                                            the row-scale requant (T1 needs a row peak their
//                                            elementwise e4m3 grid does not).
//
// ---------------- ALLOWED CHANGES ONLY (T/D), all listed in port_B.md ----------------
//   T1  OPERAND F8_E4M3FN -> int8 + per-row scale. Consequences (all in-kernel, SLM-only):
//       (a) the hidden row peak needs the WHOLE HID row, which their per-wave 64-column slice
//           cannot see -> one extra SLM micro-pass that requantizes the e4m3 bytes IN PLACE
//           into int8+scale at the same fragment offsets (their core has no such pass because
//           e4m3 is elementwise and scale-free);
//       (b) barriers: theirs 1 (expand->contract), ours 4 (+requant->contract, +contract->
//           outquant, +outquant->residual). A conditional bypass of any barrier is illegal
//           (正案: early-return-before-barrier = HANG).
//   T3  dx::linalg wave MMA -> dpas<8,8,32> (R6 says the K=32 step is already native-aligned).
//   D1  geometry from port.md A-phase: 1 ESIMD work-item = 1 of their waves (32 lanes, 16x16
//       tile, SIMD16); W = C/16 waves/group (64->4, 128->8); G = 16/W token-groups per WG
//       => LW = W*G = 16 work-items/WG, SLM ~28.5KB < the 32KB occupancy cliff.
//   +   the RESIDUAL op (their chain's NEXT dispatch, not in their 101 lines) is carried in the
//       same kernel so the final 1267 plane is a checkpoint of this same launch. Verbatim from
//       s6_ffn_block2.cpp P6 (sk*cc+f0 elementwise = auto-FMA single rounding, pub_vec_v8(1u)).
//
// NUMERICS LOCKED TO THE SHIPPED CHAIN (user's rule): row peak taken AFTER the f16 rounding,
// div_ieee(rnde + clamp +-127), P6 elementwise sk*cc+f0, split-K only in int32 phases (the port
// uses NO split-K: sequential ascending kb == 现路's ascending-ks sum because every partial is
// an exact int32 -- s6_ffn_block2.cpp:16-27 proof; the ACCUMULATION SEMANTICS ARE NOT CHANGED).
//
// Reference (现路) = the shipped separate-op chain s6_ffn_block2.cpp drives (op1..op8), which
// that file proves is byte-identical to its fused ffn2::fused (GATE PASS, 9 checkpoints).
// Checkpoints: pk1/sc1, hid f16 (tap), hidden int8+sc2 (SLM dump, both row-major AND the raw
// fragment map), out 1275, pk3/sc3 (+ fragment map), 1267-FINAL.
//
// Build+run: cd E:/DSH/dlss-nr-on-a770/src/bench/sycl
//            bash E:/DSH/bench.sh port_ffn_fused.cpp port_ffn_fused.exe
// Env: PORT_SHAPES bit0=S1(C64,M32640,HID256) bit1=S2(C128,M8160,HID512); default 3 = both.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <random>
#include <functional>
#include <algorithm>
#include <chrono>
#include <thread>
#include <cmath>
#include "gemm_s8_v8_kernel.hpp"
#include "pack_device.hpp"
#include "quantize_row_kernel.hpp"
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// ============================ T1: e4m3 byte codec (SLM transient) ============================
// Their LDS hidden is E4M3 (:48). Our transient has to be 1 byte/element to fit the SLM budget
// at D1's G (2 bytes = f16 would double it past the 32KB cliff), and e4m3 is EXACTLY what the
// shipped publish (pub_vec_v8 epi3/epi1 -> e4m3_vec_v8) produces, so the round trip is lossless:
//   encode of an on-grid f32 -> byte -> decode -> the SAME f32 bit pattern.
// e4m3_vec_v8 (gemm_s8_v8_kernel.hpp:393-408) saturates at +-448 and grids every value onto the
// e4m3 lattice (subnormal step 2^-9), so no rounding is done here -- only re-encoding.
// NOTE: every step is MATERIALIZED into a named simd (ESIMD expression templates do not carry
// member calls like bit_cast_view / convert).
template <int N>
static inline esimd::simd<int8_t, N> e4m3_enc(esimd::simd<float, N> v) {
    esimd::simd<int32_t, N> bi = v.template bit_cast_view<int32_t>();
    esimd::simd<int32_t, N> mg = bi & esimd::simd<int32_t, N>(0x7FFFFFFF);
    esimd::simd<int32_t, N> ex0 = mg >> 23;
    esimd::simd<int32_t, N> ex = ex0 & esimd::simd<int32_t, N>(0xFF);
    esimd::simd<int32_t, N> mn0 = mg & esimd::simd<int32_t, N>(0x7FFFFF);
    esimd::simd<int32_t, N> mn = mn0 >> 20;                                        // normal path
    esimd::simd<int32_t, N> sg0 = bi >> 31;
    esimd::simd<int32_t, N> sg = sg0 & esimd::simd<int32_t, N>(1);
    // subnormal path: |v| is a multiple of 2^-9 -> int(|v|*512) is exact
    esimd::simd<float, N> av = esimd::abs(v) * esimd::simd<float, N>(512.0f);
    esimd::simd<int32_t, N> msub = esimd::convert<int32_t>(av);
    esimd::simd<int32_t, N> e4x = ex - 120;
    esimd::simd<int32_t, N> e4 = esimd::max(e4x, esimd::simd<int32_t, N>(0));      // 0 => subnormal
    esimd::simd<bool, N> isnorm = ex >= esimd::simd<int32_t, N>(121);
    // PIT FALL (measured, 11-01 15:2x): an ESIMD simd<bool,N> converts to int32 as 0/1, NOT as an
    // all-ones mask (window_block_v3.hpp:43-44 documents exactly this for the sign bit). Building
    // a simd<int32_t,N> from the predicate and using it with &/~ silently keeps only bit0 -> the
    // e4m3 bytes came out as (msub & ~1). All-ones masks are built BY SUBTRACTION here.
    esimd::simd<int32_t, N> mk1(isnorm);
    esimd::simd<int32_t, N> mo(esimd::simd<int32_t, N>(0) - mk1);   // all-ones where normal
    esimd::simd<int32_t, N> ms(mk1 - esimd::simd<int32_t, N>(1));   // all-ones where subnormal
    esimd::simd<int32_t, N> a1 = mn & mo;
    esimd::simd<int32_t, N> a2 = msub & ms;
    esimd::simd<int32_t, N> m3 = a1 | a2;
    esimd::simd<int32_t, N> s1 = e4 << 3;
    esimd::simd<int32_t, N> s2 = sg << 7;
    esimd::simd<int32_t, N> byte = (s2 | s1) | m3;
    return esimd::convert<int8_t>(byte);
}
template <int N>
static inline esimd::simd<float, N> e4m3_dec(esimd::simd<int8_t, N> raw) {
    esimd::simd<int32_t, N> x0 = esimd::convert<int32_t>(raw);
    esimd::simd<int32_t, N> x = x0 & esimd::simd<int32_t, N>(0xFF);
    esimd::simd<int32_t, N> sg0 = x >> 7;
    esimd::simd<int32_t, N> sg = sg0 & esimd::simd<int32_t, N>(1);
    esimd::simd<int32_t, N> e4x = x >> 3;
    esimd::simd<int32_t, N> e4 = e4x & esimd::simd<int32_t, N>(0xF);
    esimd::simd<int32_t, N> m3 = x & esimd::simd<int32_t, N>(7);
    esimd::simd<int32_t, N> e32 = e4 + 120;
    esimd::simd<int32_t, N> eb = e32 << 23;
    esimd::simd<int32_t, N> mb = m3 << 20;
    esimd::simd<int32_t, N> nb = eb | mb;                                          // normal path
    esimd::simd<bool, N> isnorm = e4 >= esimd::simd<int32_t, N>(1);
    esimd::simd<int32_t, N> mk1(isnorm);
    esimd::simd<int32_t, N> mo(esimd::simd<int32_t, N>(0) - mk1);   // all-ones where normal
    esimd::simd<int32_t, N> ms(mk1 - esimd::simd<int32_t, N>(1));   // all-ones where subnormal
    // subnormal path: m3 * 2^-9 is exact in f32 (m3 in 0..7)
    esimd::simd<float, N> subf = esimd::convert<float>(m3) * esimd::simd<float, N>(0.001953125f);
    esimd::simd<int32_t, N> sb = subf.template bit_cast_view<int32_t>();
    esimd::simd<int32_t, N> b1 = nb & mo;
    esimd::simd<int32_t, N> b2 = sb & ms;
    esimd::simd<int32_t, N> sign = sg << 31;
    esimd::simd<int32_t, N> bits = (b1 | b2) | sign;
    esimd::simd<float, N> res = bits.template bit_cast_view<float>();
    return res;
}

// ============================ the port ============================
namespace port {

// C1 (11-01 16:xx): the geometry is now a SWEEP KNOB, not a constant.
//   Geo<C, HID, TG, G, WM, KNIFE>  -- the six slots spillcheck_port.py's label() already expects.
//   TG = token rows per group (16 = faithful R7; C1 does NOT open the 32-token rung),
//   G  = token-groups per work-group  => LW = W*G*WM work-items/WG  (the occupancy knob),
//   WM = waves per work-item (1 = faithful),
//   KNIFE = 1 -> C1's SLM knife: NO `out` copy in SLM; PHASE 4's row peak reads the f16 values
//                back from the GLOBAL 1275 plane (one extra global read pass per row, in exchange
//                for TG*C*2 bytes per group of SLM). KNIFE = 0 -> the B-stage SLM layout (anchor).
//   W=C/16 and the 16x16 tile stay faithful. The old static_assert(LW==16) is gone; the 32KB
//   "occupancy cliff" and the 64KB SLM cap are reported as FITS/CLIFF, not asserted, so the sweep
//   can walk past the cliff on purpose and still be refused by the cap.
template <int C_, int HID_, int TG_, int G_, int WM_, int KNIFE_>
struct Geo {
    static constexpr int C = C_, HID = HID_, TG = TG_, G = G_, WM = WM_, KN = KNIFE_;
    static constexpr int W = C / 16;            // their WAVES = C/16 (their :15) -- faithful
    static constexpr int LW = W * G * WM;       // ESIMD work-items (=waves) per WG
    static constexpr int KB_C = C / 32, KB_H = HID / 32;   // R6: K step 32
    static constexpr int RPI = TG / W;          // rows per work-item in the requant passes
    static_assert(TG == 16, "R7 faithful: 16-token groups (C1 keeps them; no 32-token rung)");
    static_assert(WM == 1, "C1 keeps 1 wave per work-item (faithful)");
    static_assert(TG % W == 0, "requant passes split TG rows over the W waves");
    // ---- SLM, per token-group (bytes). R3: the hidden plane NEVER touches global. ----
    static constexpr uint32_t O_HIDF = 0;                       // e4m3 bytes -> int8, fragment order
    static constexpr uint32_t SZ_HIDF = (uint32_t)TG * (uint32_t)HID;
    static constexpr uint32_t SZ_OUT = (KN == 0) ? ((uint32_t)TG * (uint32_t)C * 2u) : 0u; // C1 knife
    static constexpr uint32_t O_OUT = O_HIDF + SZ_HIDF;         // contract out f16 (TG x C), KN==0 only
    static constexpr uint32_t O_PK = O_OUT + SZ_OUT;            // out int8, fragment order (P6 A)
    static constexpr uint32_t SZ_PK = (uint32_t)TG * (uint32_t)C;
    static constexpr uint32_t O_SC = O_PK + SZ_PK;              // scH @ +0 | scO @ +64
    static constexpr uint32_t SZ_SC = 128u;
    static constexpr uint32_t PG = O_SC + SZ_SC;                // per-group span
    static constexpr uint32_t SLM = ((PG * (uint32_t)G + 15u) / 16u) * 16u;
    static constexpr uint32_t CAP = 65536u;       // A-stage: the 64KB SLM cap per WG (hard)
    static constexpr uint32_t CLIFF = 32768u;     // A-stage: the 32KB occupancy cliff (soft)
    static constexpr bool FITS = (PG * (uint32_t)G <= CAP);
};

struct Args {
    const int8_t* pkA;      // R1 input face, dpas-A fragment order (group-major 512B blocks)
    const float*  scA;      // T1 input row scales (producer side)
    const int8_t* Wexp;     // R2 expand weights, their 512B order (N=HID, K=C)
    const float*  bsExp;
    const int8_t* Wproj;    // R2 contract weights, their 512B order (N=C, K=HID)
    const float*  bsProj;
    const int8_t* Bres;     // residual weights (our pack_b map; NOT part of their core)
    const float*  bsRes;
    const float*  cos;
    const half*   dIn;      // skip connection
    half*         dOut;     // 1267 plane
    int M, NGRP;            // NGRP = 16-token groups, PADDED to a multiple of G (host rule)
    // ---- anti-DCE sink (C1): per-phase fragments stored under a RUNTIME flag the compiler
    // cannot fold (it is a kernel argument read from memory). The flag is 0 at run time, so the
    // stores never execute, but every phase's accumulator/result lanes stay live even when the
    // launch is truncated by NPHASE -- which is what the per-phase timings rely on.
    int sinkFlag;
    int32_t* dSink;         // [NGRPpad*W][5 phases][64 int32]
    // ---- bench-only taps; exist ONLY in the DUMP=true instantiation ----
    half*   dHid;           // pub values as f16 (proves the e4m3 transient == 现路 hidden f16)
    int8_t* dfrag1;         // the e4m3 BYTES phase 1 wrote, dumped as stored (fragment order)
    half*   ddec;           // phase 2's DECODE of those bytes, row-major (isolates the codec)
    int8_t* dpk2; float* dsc2;      // hidden int8 row-major + scales
    int8_t* dfrag2;                 // the SLM hidden map dumped AS STORED (fragment order)
    half*   dOut1275;               // contract out plane
    int8_t* dpk3; float* dsc3;      // out int8 row-major + scales
    int8_t* dfrag3;                 // the SLM pkO map as stored
};

template <class S, bool DUMP, int NPHASE>
static sycl::event fused(sycl::queue& q, const Args& a) {
    constexpr int C = S::C, HID = S::HID, W = S::W, G = S::G, LW = S::LW;
    constexpr int KB_C = S::KB_C, KB_H = S::KB_H, RPI = S::RPI, TG = S::TG, KN = S::KN;
    constexpr uint32_t PG = S::PG;
    const int ngrp = a.NGRP;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)(ngrp / G) * (size_t)LW), range((size_t)LW)),
                       [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<S::SLM>();
#ifdef PORT_SINKS
            const bool sf = (a.sinkFlag != 0);     // diagnostic build: per-phase anti-DCE sinks ON
#else
            // Default: the sink STORES are compiled away. C1 measured why -- they are NOT needed
            // here (every phase ends in an SLM or global store, and SLM is WG-shared, so the
            // compiler cannot prove it is unread => no phase can be DCE'd), and paying for them
            // is expensive: grf_count is already pinned at 128, so widening the dpas accumulators'
            // live range spills (private 3328->3584, scratch instructions 61->174, chain +64%).
            // Build with -DPORT_SINKS to get the sink cross-check (C1-3 in s6/port_C1.md).
            const bool sf = false;
#endif
            const int t    = (int)it.get_local_id(0);
            const int gidx = t / W, w = t % W;              // their "wave" (their :52)
            const int grp  = (int)it.get_group(0) * G + gidx;
            const int r0   = grp * 16;                      // R7 linear token order, 16/group
            const uint32_t SB    = (uint32_t)gidx * PG;
            const uint32_t HIDF  = SB + S::O_HIDF;
            const uint32_t OUTP  = SB + S::O_OUT;
            const uint32_t PKO   = SB + S::O_PK;
            const uint32_t SCB   = SB + S::O_SC;
            auto gr = it.get_group();

            // R7 cull (their :51). D1 packs G groups per WG, so the predicate is written on the
            // WHOLE-WG span (wg*G*16): it is then work-group-UNIFORM, which is what R5 needs --
            // a per-group predicate would let some work-items walk past the barrier their peers
            // wait on (= the 正案 HANG). The host also guarantees ngrp % G == 0.
            if ((int)it.get_group(0) * G * 16 >= a.M) return;

            // ==================== PHASE 1: expand (their :53-76) ====================
            {
                esimd::simd<int8_t, 256> y0, y1;
                esimd::simd<int32_t, 64> q0_00(0), q0_01(0), q0_10(0), q0_11(0);
                esimd::simd<int32_t, 64> q1_00(0), q1_01(0), q1_10(0), q1_11(0);
                esimd::simd<int32_t, 64> q2_00(0), q2_01(0), q2_10(0), q2_11(0);
                esimd::simd<int32_t, 64> q3_00(0), q3_01(0), q3_10(0), q3_11(0);
                // R1: A operand straight off the face, fragment order, NO pack pass.
                auto gemm_tile = [&](esimd::simd<int32_t, 64>& c00, esimd::simd<int32_t, 64>& c01,
                                     esimd::simd<int32_t, 64>& c10, esimd::simd<int32_t, 64>& c11,
                                     const int8_t* bp,
                                     const esimd::simd<int8_t, 256>& a0,
                                     const esimd::simd<int8_t, 256>& a1) SYCL_ESIMD_FUNCTION {
                    // R2: 512B fragment block, two 256B dpas operands (T3: 4 x 8x8x32 = 16x16).
                    esimd::simd<int8_t, 256> b0 = esimd::block_load<int8_t, 256>(bp, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t, 256> b1 = esimd::block_load<int8_t, 256>(bp + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                    c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                    c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                    c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                };
                for (int kb = 0; kb < KB_C; ++kb) {                    // R6: K step 32 (their :55)
                    const int8_t* ap = a.pkA + ((size_t)grp * KB_C + (size_t)kb) * 512u;
                    y0 = esimd::block_load<int8_t, 256>(ap, esimd::overaligned_tag<16>{});
                    y1 = esimd::block_load<int8_t, 256>(ap + 256, esimd::overaligned_tag<16>{});
                    // their :57-58: [unroll] n<4, col = (wave*4+n)*16 -- four tiles per wave
                    gemm_tile(q0_00, q0_01, q0_10, q0_11, a.Wexp + ((size_t)(w*4+0)*KB_C + kb)*512u, y0, y1);
                    gemm_tile(q1_00, q1_01, q1_10, q1_11, a.Wexp + ((size_t)(w*4+1)*KB_C + kb)*512u, y0, y1);
                    gemm_tile(q2_00, q2_01, q2_10, q2_11, a.Wexp + ((size_t)(w*4+2)*KB_C + kb)*512u, y0, y1);
                    gemm_tile(q3_00, q3_01, q3_10, q3_11, a.Wexp + ((size_t)(w*4+3)*KB_C + kb)*512u, y0, y1);
                }
                // R4: encode in the accumulator REGISTERS, then drop straight into SLM.
                // (two 8-wide scale loads, like the shipped P2's simd<float,8> rss: a dynamic
                //  index >= 8 into a 16-wide simd is not something the shipped chain relies on)
                esimd::simd<float, 8> rssA = esimd::block_load<float, 8>(a.scA + r0, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> rssB = esimd::block_load<float, 8>(a.scA + r0 + 8, esimd::overaligned_tag<16>{});
                auto store_tile = [&](esimd::simd<int32_t, 64>& c00, esimd::simd<int32_t, 64>& c01,
                                      esimd::simd<int32_t, 64>& c10, esimd::simd<int32_t, 64>& c11,
                                      int col, const esimd::simd<float, 16>& cs) SYCL_ESIMD_FUNCTION {
                    const uint32_t fb = HIDF + (uint32_t)(col >> 5)*512u + (uint32_t)(col & 31);
                    // fr = the row INSIDE the 8x8 fragment (select offset fr*8, 0..7 -- a fragment
                    // only has 8 rows, so the offset must never reach 64); r = the tile row 0..15.
                    auto row = [&](esimd::simd<int32_t, 64>& f0, esimd::simd<int32_t, 64>& f1,
                                   int fr, int r, float rs) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int32_t, 16> acc(0);
                        acc.template select<8, 1>(0) = f0.template select<8, 1>(fr*8);
                        acc.template select<8, 1>(8) = f1.template select<8, 1>(fr*8);
                        // shipped expand epilogue VERBATIM (s6_ffn_block2.cpp:177): acc*scA*bsExp, epi3
                        esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(
                            3u, esimd::convert<float>(acc) * rs * cs);
                        if (DUMP) esimd::convert<half>(pub).copy_to(a.dHid + (size_t)(r0 + r)*HID + col);
                        esimd::simd<int8_t, 16> eb = e4m3_enc<16>(pub);
                        if (DUMP) esimd::block_store<int8_t, 16>(
                            a.dfrag1 + (size_t)grp*(16*HID) + (size_t)(col >> 5)*512u + (uint32_t)(col & 31)
                            + (uint32_t)r*32u, eb, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(fb + (uint32_t)r*32u, eb, esimd::overaligned_tag<16>{});
                    };
                    for (int r = 0; r < 8; ++r) row(c00, c01, r, r,     rssA[r]);
                    for (int r = 0; r < 8; ++r) row(c10, c11, r, r + 8, rssB[r]);
                };
                store_tile(q0_00, q0_01, q0_10, q0_11, (w*4+0)*16,
                           esimd::block_load<float, 16>(a.bsExp + (w*4+0)*16, esimd::overaligned_tag<16>{}));
                store_tile(q1_00, q1_01, q1_10, q1_11, (w*4+1)*16,
                           esimd::block_load<float, 16>(a.bsExp + (w*4+1)*16, esimd::overaligned_tag<16>{}));
                store_tile(q2_00, q2_01, q2_10, q2_11, (w*4+2)*16,
                           esimd::block_load<float, 16>(a.bsExp + (w*4+2)*16, esimd::overaligned_tag<16>{}));
                store_tile(q3_00, q3_01, q3_10, q3_11, (w*4+3)*16,
                           esimd::block_load<float, 16>(a.bsExp + (w*4+3)*16, esimd::overaligned_tag<16>{}));
                // ---- PHASE 1 sink (expand / = 现路 P2): all 16 accumulator fragments are live ----
                if (sf) {
                    esimd::simd<int32_t, 64> z =
                        ((((q0_00 + q0_01) + (q0_10 + q0_11)) + ((q1_00 + q1_01) + (q1_10 + q1_11))) +
                         (((q2_00 + q2_01) + (q2_10 + q2_11)) + ((q3_00 + q3_01) + (q3_10 + q3_11))));
                    z.copy_to(a.dSink + ((size_t)grp * W + (size_t)w) * 320);
                }
            }
            group_barrier(gr);              // R5
            if (NPHASE <= 1) return;

            // ==================== PHASE 2: T1 requant (e4m3 bytes -> int8 + row scale) ====================
            // Their core has NO such pass: e4m3 is elementwise and scale-free. Our int8 grid needs a
            // ROW PEAK over the whole HID row, which no single wave owns -> the e4m3 bytes are
            // requantized IN PLACE at the same fragment offsets (T1a; the peak is taken over the
            // published values = "行峰值在 f16 舍入之后取", identical values, f16/e4m3 are the same
            // lattice points here).
            {
                esimd::simd<int32_t, 32> s2(0);            // PHASE 2 sink accumulator
                for (int i = 0; i < RPI; ++i) {
                    const int r = w * RPI + i;
                    esimd::simd<float, 32> mx(esimd::simd<float, 32>(0.f));
                    for (int kb = 0; kb < KB_H; ++kb) {
                        const uint32_t fo = HIDF + (uint32_t)kb*512u + (uint32_t)r*32u;
                        esimd::simd<float, 32> v = e4m3_dec<32>(
                            esimd::slm_block_load<int8_t, 32>(fo, esimd::overaligned_tag<16>{}));
                        if (DUMP) esimd::block_store<half, 32>(
                            a.ddec + (size_t)(r0 + r)*HID + (size_t)kb*32u,
                            esimd::convert<half>(v), esimd::overaligned_tag<16>{});
                        mx = esimd::max(mx, esimd::abs(v));           // max: exact, order-free
                    }
                    float peak = esimd::hmax<float, float, 32>(mx);
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak),
                                                    esimd::simd<float, 1>(127.0f))[0];
                    esimd::slm_block_store(SCB + (uint32_t)r*4u, esimd::simd<float, 1>(scale),
                                           esimd::overaligned_tag<16>{});
                    for (int kb = 0; kb < KB_H; ++kb) {
                        const uint32_t fo = HIDF + (uint32_t)kb*512u + (uint32_t)r*32u;
                        esimd::simd<float, 32> h = e4m3_dec<32>(
                            esimd::slm_block_load<int8_t, 32>(fo, esimd::overaligned_tag<16>{}));
                        // shipped quantize chain VERBATIM (s6_ffn_block2.cpp:216-218)
                        esimd::simd<float, 32> q = esimd::div_ieee<float, 32>(h, esimd::simd<float, 32>(scale));
                        q = esimd::min(esimd::max(esimd::rnde<float, 32>(q), esimd::simd<float, 32>(-127.f)),
                                       esimd::simd<float, 32>(127.f));
                        esimd::simd<int8_t, 32> o = esimd::convert<int8_t>(esimd::convert<int>(q));
                        esimd::slm_block_store(fo, o, esimd::overaligned_tag<16>{});
                        if (sf) { esimd::simd<int32_t, 32> oi = esimd::convert<int32_t>(o); s2 = s2 + oi; }
                        if (DUMP) {
                            esimd::block_store<int8_t, 32>(a.dpk2 + (size_t)(r0 + r)*HID + kb*32, o,
                                                           esimd::overaligned_tag<16>{});
                            esimd::block_store<int8_t, 32>(a.dfrag2 + (size_t)grp*(16*HID) + (size_t)kb*512u
                                                           + (uint32_t)r*32u, o, esimd::overaligned_tag<16>{});
                        }
                    }
                    if (DUMP) a.dsc2[r0 + r] = scale;
                }
                if (sf) s2.copy_to(a.dSink + ((size_t)grp * W + (size_t)w) * 320 + 64);
            }
            group_barrier(gr);              // R5
            if (NPHASE <= 2) return;

            // ==================== PHASE 3: contract (their :79-98) ====================
            {
                const int col = w * 16;                              // their :81
                esimd::simd<int8_t, 256> y0, y1;
                esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
                for (int kb = 0; kb < KB_H; ++kb) {                  // R6, their :82
                    // R4: A operand = the SLM hidden as INT8, fragment order, zero pack.
                    y0 = esimd::slm_block_load<int8_t, 256>(HIDF + (uint32_t)kb*512u, esimd::overaligned_tag<16>{});
                    y1 = esimd::slm_block_load<int8_t, 256>(HIDF + (uint32_t)kb*512u + 256u, esimd::overaligned_tag<16>{});
                    // R2: their :85 offset ((col/16)*(HID/32)+g)*512
                    const int8_t* bp = a.Wproj + ((size_t)(col/16)*KB_H + (size_t)kb)*512u;
                    esimd::simd<int8_t, 256> b0 = esimd::block_load<int8_t, 256>(bp, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t, 256> b1 = esimd::block_load<int8_t, 256>(bp + 256, esimd::overaligned_tag<16>{});
                    c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, y0);
                    c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, y0);
                    c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, y1);
                    c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, y1);
                }
                // T1: the scales ride the EPILOGUE (their core has none). Sequential ascending kb
                // above == 现路 P4's ascending-ks split-K sum: every partial is an exact int32.
                esimd::simd<float, 16> cs = esimd::block_load<float, 16>(a.bsProj + col, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> rssA = esimd::slm_block_load<float, 8>(SCB, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> rssB = esimd::slm_block_load<float, 8>(SCB + 32u, esimd::overaligned_tag<16>{});
                auto row = [&](esimd::simd<int32_t, 64>& f0, esimd::simd<int32_t, 64>& f1,
                               int fr, int r, float rs) SYCL_ESIMD_FUNCTION {
                    esimd::simd<int32_t, 16> acc(0);
                    acc.template select<8, 1>(0) = f0.template select<8, 1>(fr*8);
                    acc.template select<8, 1>(8) = f1.template select<8, 1>(fr*8);
                    // shipped proj epilogue VERBATIM (s6_ffn_block2.cpp:266): acc*scH*bsProj, epi1
                    esimd::simd<float, 16> pub = s8v8::pub_vec_v8<16>(
                        1u, esimd::convert<float>(acc) * rs * cs);
                    esimd::simd<half, 16> hh = esimd::convert<half>(pub);
                    if (KN == 0) esimd::slm_block_store(OUTP + (uint32_t)r*(C*2u) + (uint32_t)col*2u, hh,
                                                        esimd::overaligned_tag<16>{});
                    hh.copy_to(a.dOut1275 + (size_t)(r0 + r)*C + col);   // their :98 (the 1275 plane)
                };
                for (int r = 0; r < 8; ++r) {
                    row(c00, c01, r, r,     rssA[r]);
                    row(c10, c11, r, r + 8, rssB[r]);
                }
                // ---- PHASE 3 sink (contract / = 现路 P4) ----
                if (sf) {
                    esimd::simd<int32_t, 64> z = (c00 + c01) + (c10 + c11);
                    z.copy_to(a.dSink + ((size_t)grp * W + (size_t)w) * 320 + 128);
                }
            }
            group_barrier(gr);              // R5
            if (NPHASE <= 3) return;

            // ==================== PHASE 4: out row peak -> pkO (T1; = 现路 P5q) ====================
            // C1 KNIFE (KN==1): the f16 row is NOT copied into SLM by PHASE 3; the row peak and the
            // requant read it back from the GLOBAL 1275 plane (their :98 output, which this kernel
            // already writes). Cost: one extra global read pass over TG*C f16 per group. Payoff:
            // -TG*C*2 bytes of SLM per group (S1 2048B, S2 4096B) -> the occupancy knob below.
            // Cross-wave read-after-write inside the WG is ordered by the R5 group_barrier above
            // (the 1275 plane is written by all W waves of this group and read back row-wise).
            {
                esimd::simd<int32_t, 32> s4(0);            // PHASE 4 sink accumulator
                for (int i = 0; i < RPI; ++i) {
                    const int r = w * RPI + i;
                    const half* rowp = a.dOut1275 + (size_t)(r0 + r) * C;
                    esimd::simd<float, 16> mx(esimd::simd<float, 16>(0.f));
                    for (int c = 0; c < C/16; ++c) {
                        esimd::simd<half, 16> h = (KN == 0)
                            ? esimd::slm_block_load<half, 16>(
                                  OUTP + (uint32_t)r*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{})
                            : esimd::block_load<half, 16>(rowp + c*16, esimd::overaligned_tag<16>{});
                        mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                    }
                    float peak = esimd::hmax<float, float, 16>(mx);
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak),
                                                    esimd::simd<float, 1>(127.0f))[0];
                    esimd::slm_block_store(SCB + 64u + (uint32_t)r*4u, esimd::simd<float, 1>(scale),
                                           esimd::overaligned_tag<16>{});
                    for (int kb = 0; kb < KB_C; ++kb) {
                        esimd::simd<half, 32> h = (KN == 0)
                            ? esimd::slm_block_load<half, 32>(
                                  OUTP + (uint32_t)r*(C*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{})
                            : esimd::block_load<half, 32>(rowp + kb*32, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> q = esimd::div_ieee<float, 32>(esimd::convert<float>(h),
                                                                              esimd::simd<float, 32>(scale));
                        q = esimd::min(esimd::max(esimd::rnde<float, 32>(q), esimd::simd<float, 32>(-127.f)),
                                       esimd::simd<float, 32>(127.f));
                        esimd::simd<int8_t, 32> o = esimd::convert<int8_t>(esimd::convert<int>(q));
                        esimd::slm_block_store<int8_t, 32>(PKO + (uint32_t)kb*512u + (uint32_t)r*32u, o,
                                                           esimd::overaligned_tag<16>{});
                        if (sf) { esimd::simd<int32_t, 32> oi = esimd::convert<int32_t>(o); s4 = s4 + oi; }
                        if (DUMP) {
                            esimd::block_store<int8_t, 32>(a.dpk3 + (size_t)(r0 + r)*C + kb*32, o,
                                                           esimd::overaligned_tag<16>{});
                            esimd::block_store<int8_t, 32>(a.dfrag3 + (size_t)grp*(16*C) + (size_t)kb*512u
                                                           + (uint32_t)r*32u, o, esimd::overaligned_tag<16>{});
                        }
                    }
                    if (DUMP) a.dsc3[r0 + r] = scale;
                }
                if (sf) s4.copy_to(a.dSink + ((size_t)grp * W + (size_t)w) * 320 + 192);
            }
            group_barrier(gr);              // R5
            if (NPHASE <= 4) return;

            // ==================== PHASE 5: residual gemm (our chain's next op; = 现路 P6) ====================
            // Not in their 101 lines -- carried here so 1267 is a checkpoint of the same launch.
            // Wave w takes the 16 output columns [w*16, w*16+16) and all 16 token rows.
            {
                esimd::simd<int8_t, 256> y0, y1;
                esimd::simd<int32_t, 64> r00(0), r01(0), r10(0), r11(0);
                for (int kb = 0; kb < KB_C; ++kb) {
                    y0 = esimd::slm_block_load<int8_t, 256>(PKO + (uint32_t)kb*512u, esimd::overaligned_tag<16>{});
                    y1 = esimd::slm_block_load<int8_t, 256>(PKO + (uint32_t)kb*512u + 256u, esimd::overaligned_tag<16>{});
                    const int8_t* bp = a.Bres + (size_t)kb*(C*32) + (size_t)(w*2)*256u;
                    esimd::simd<int8_t, 256> b0 = esimd::block_load<int8_t, 256>(bp, esimd::overaligned_tag<16>{});
                    esimd::simd<int8_t, 256> b1 = esimd::block_load<int8_t, 256>(bp + 256, esimd::overaligned_tag<16>{});
                    r00 = esimd::xmx::dpas<8, 8, int32_t>(r00, b0, y0);
                    r01 = esimd::xmx::dpas<8, 8, int32_t>(r01, b1, y0);
                    r10 = esimd::xmx::dpas<8, 8, int32_t>(r10, b0, y1);
                    r11 = esimd::xmx::dpas<8, 8, int32_t>(r11, b1, y1);
                }
                const int colb = w * 16;
                esimd::simd<float, 8> rosA = esimd::slm_block_load<float, 8>(SCB + 64u, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> rosB = esimd::slm_block_load<float, 8>(SCB + 96u, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> cs0 = esimd::block_load<float, 8>(a.bsRes + colb, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> cs1 = esimd::block_load<float, 8>(a.bsRes + colb + 8, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> cc0 = esimd::block_load<float, 8>(a.cos + colb, esimd::overaligned_tag<16>{});
                esimd::simd<float, 8> cc1 = esimd::block_load<float, 8>(a.cos + colb + 8, esimd::overaligned_tag<16>{});
                auto res_row = [&](const esimd::simd<int32_t, 8>& v, int r, int col,
                                   const esimd::simd<float, 8>& cs, const esimd::simd<float, 8>& cc,
                                   float rs) SYCL_ESIMD_FUNCTION {
                    const size_t at = (size_t)(r0 + r)*C + col;
                    // shipped P6 VERBATIM (s6_ffn_block2.cpp:387-393): f0 = acc*scO*bsRes, then the
                    // ELEMENTWISE scalar sk*cc+f0 (auto-FMA, ONE rounding), then pub epi1.
                    esimd::simd<float, 8> f0 = esimd::convert<float>(v) * rs * cs;
                    esimd::simd<half, 8> sh = esimd::block_load<half, 8>(a.dIn + at, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> sk = esimd::convert<float>(sh);
                    esimd::simd<float, 8> tt;
                    for (int e = 0; e < 8; ++e) tt[e] = sk[e]*cc[e] + f0.read()[e];
                    esimd::simd<float, 8> pub = s8v8::pub_vec_v8<8>(1u, tt);
                    esimd::convert<half>(pub).copy_to(a.dOut + at);
                };
                for (int r = 0; r < 8; ++r) {
                    // materialized: the dpas accumulator fragments are read through select<8,1>
                    const esimd::simd<int32_t, 8> v00 = r00.template select<8, 1>(r*8);
                    const esimd::simd<int32_t, 8> v01 = r01.template select<8, 1>(r*8);
                    const esimd::simd<int32_t, 8> v10 = r10.template select<8, 1>(r*8);
                    const esimd::simd<int32_t, 8> v11 = r11.template select<8, 1>(r*8);
                    res_row(v00, r,     colb,     cs0, cc0, rosA[r]);
                    res_row(v01, r,     colb + 8, cs1, cc1, rosA[r]);
                    res_row(v10, r + 8, colb,     cs0, cc0, rosB[r]);
                    res_row(v11, r + 8, colb + 8, cs1, cc1, rosB[r]);
                }
                // ---- PHASE 5 sink (residual gemm / = 现路 P6) ----
                if (sf) {
                    esimd::simd<int32_t, 64> z = (r00 + r01) + (r10 + r11);
                    z.copy_to(a.dSink + ((size_t)grp * W + (size_t)w) * 320 + 256);
                }
            }
        });
    });
}
} // namespace port

// ============================ setup-side retiles (R1/R2) ============================
// Pure index permutations (no arithmetic) => bit-exact by construction, and they run ONCE in
// setup (cache-owned), never in the timed chain.
static void retile_a(queue& q, const int8_t* pk, int8_t* face, int M, int C) {
    const size_t KB = (size_t)(C / 32), per = KB * 512u;
    q.parallel_for(range((size_t)M * C), [=](id<1> i) {
        size_t d = i[0], g = d / per, rem = d % per;
        size_t kb = rem / 512u; int off = (int)(rem % 512u);
        face[d] = pk[(g*16 + (size_t)(off/32))*(size_t)C + kb*32u + (size_t)(off%32)];
    }).wait();
}
// 现路 pack_b blocks (kb-major, 256B = 8 N-rows x 32 K) -> THEIR 512B fragment blocks
// ((col/16)*(K/32) + kb) * 512, i.e. cb-major outer, two 8-row halves inside.
static void retile_b(queue& q, const int8_t* src, int8_t* dst, int N, int K) {
    const size_t KB = (size_t)(K / 32), N8 = (size_t)(N / 8), per = KB * 512u;
    q.parallel_for(range((size_t)N * K), [=](id<1> i) {
        size_t d = i[0], cb = d / per, rem = d % per;
        size_t kb = rem / 512u, off = rem % 512u, hh = off / 256u, ii = off % 256u;
        dst[d] = src[(kb*N8 + 2*cb + hh)*256u + ii];
    }).wait();
}

// ============================ host ============================
// C1 protocol: 5 groups x 15 reps, 60 ms between groups; msM = median of the group minimums,
// msm = global min, msX = global max, med = global median (event-profiling GPU time).
struct Stat { double msm, msM, msX, med; };
static Stat timeit(std::function<event()> f, size_t groups = 5, size_t reps = 15, int gap_ms = 60) {
    f().wait();
    std::vector<double> gmin, all;
    for (size_t gi = 0; gi < groups; ++gi) {
        if (gi) std::this_thread::sleep_for(std::chrono::milliseconds(gap_ms));
        double lo = 1e9;
        for (size_t it = 0; it < reps; ++it) {
            event e = f(); e.wait();
            double ms = (double)(e.get_profiling_info<info::event_profiling::command_end>()
                               - e.get_profiling_info<info::event_profiling::command_start>()) / 1e6;
            lo = std::min(lo, ms); all.push_back(ms);
        }
        gmin.push_back(lo);
    }
    std::sort(all.begin(), all.end());
    std::sort(gmin.begin(), gmin.end());
    Stat st; st.msM = gmin[gmin.size()/2]; st.msm = all.front();
    st.msX = all.back(); st.med = all[all.size()/2]; return st;
}

static int gfails = 0;
// byte diff with the first-deviation coordinate in EVERY axis the plane has
static bool diffbytes(const uint8_t* x, const uint8_t* y, size_t n, size_t K, const char* what,
                      const char* phase, int esz = 1) {
    size_t bad = 0, fi = 0;
    for (size_t i = 0; i < n; ++i) if (x[i] != y[i]) { if (!bad) fi = i; ++bad; }
    if (bad) {
        ++gfails;
        size_t el = fi / (size_t)esz;
        printf("  DIFF %-10s %zu/%zu bytes; first byte %zu (elem %zu row=%zu col=%zu): "
               "现路=0x%02X port=0x%02X   <== diverges at/after [%s]\n",
               what, bad, n, fi, el, el/K, el%K, x[fi], y[fi], phase);
        return false;
    }
    printf("  diff %-10s = 0  (%zu bytes)\n", what, n);
    return true;
}
static bool diffsc(const float* x, const float* y, size_t n, const char* what, const char* phase) {
    size_t bad = 0, fi = 0;
    for (size_t i = 0; i < n; ++i) if (memcmp(&x[i], &y[i], 4) != 0) { if (!bad) fi = i; ++bad; }
    if (bad) {
        ++gfails;
        printf("  DIFF %-10s %zu/%zu; first row %zu: 现路=%.9g port=%.9g  <== [%s]\n",
               what, bad, n, fi, (double)x[fi], (double)y[fi], phase);
        return false;
    }
    printf("  diff %-10s = 0  (%zu scales)\n", what, n);
    return true;
}

// Host reference for the port's e4m3 byte codec, computed from the 现路 f16 hidden plane
// (pub values, already on the e4m3 lattice). BENCH FORENSICS ONLY: it localizes a divergence
// into "encode wrong" vs "SLM store/read wrong" vs "decode wrong".
static uint8_t host_e4m3(uint16_t hb) {
    sycl::half h; std::memcpy(&h, &hb, 2);
    float v = (float)h;
    uint32_t b; std::memcpy(&b, &v, 4);
    uint32_t sg = (b >> 31) & 1u, mg = b & 0x7FFFFFFFu;
    uint32_t ex = (mg >> 23) & 0xFFu;
    uint32_t e4, m3;
    if (ex >= 121u) { e4 = ex - 120u; m3 = (mg & 0x7FFFFFu) >> 20; }
    else            { e4 = 0u;        m3 = (uint32_t)(int)(std::fabs(v) * 512.0f); }
    return (uint8_t)((sg << 7) | (e4 << 3) | (m3 & 7u));
}

// C1: one (shape, G, KNIFE) configuration per call; the geometry comes in as the type S.
// Padding rule: a work-group carries G token-groups (and the cull is WG-uniform), so every
// buffer the kernel touches by ROW must cover ceil(ngrp/G)*G groups = Mpad rows. The 现路
// control leg and all 13 diffs stay on the REAL M rows.
template <class S>
static bool run_shape(const char* tag, int M, int N_e, int b_e, int N_p, int K_p, int b_p) {
    constexpr int C = S::C, HID = S::HID, W = S::W, G = S::G, LW = S::LW, KN = S::KN;
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { printf("no L0 Arc\n"); return false; }
    queue q(dev, property::queue::enable_profiling{});
    printf("[dev] local_mem_size=%u B  max_work_group_size=%u  max_compute_units=%u  sub_dev=%u\n",
           dev.get_info<info::device::local_mem_size>(), dev.get_info<info::device::max_work_group_size>(),
           dev.get_info<info::device::max_compute_units>(),
           dev.get_info<info::device::partition_max_sub_devices>());

    const int ngrp = M / 16;
    if (M % 16) { printf("%s: M not a multiple of 16 -- geometry illegal\n", tag); return false; }
    const int ngrpP = ((ngrp + G - 1) / G) * G;
    const int Mpad  = ngrpP * 16;
    const int nWG   = ngrpP / G;
    printf("\n############ %s: M=%d C=%d HID=%d | W=%d G=%d LW=%d KN=%d | ngrp=%d->%d WG=%d "
           "SLM=%uB %s%s | threads=%d ############\n",
           tag, M, C, HID, W, G, LW, KN, ngrp, ngrpP, nWG, S::SLM, (S::SLM > S::CLIFF ? ">32KB" : "<=32KB"),
           (S::SLM > S::CLIFF ? "*" : ""), nWG * LW);

    std::mt19937 rng(5);
    std::uniform_real_distribution<float> du(-1.5f, 1.5f);
    std::uniform_int_distribution<int> dw(-127, 127);
    auto uscale = [&](std::mt19937& r){ std::uniform_real_distribution<float> d2(0.002f, 0.02f); return d2(r); };

    const int Mp = ((M + 127) / 128) * 128;
    std::vector<half> hIn((size_t)M*C);              for (auto& x : hIn) x = half(du(rng));
    std::vector<int8_t> hWE((size_t)b_e*N_e*C);      for (auto& x : hWE) x = (int8_t)dw(rng);
    std::vector<float>  hSE((size_t)b_e*N_e);        for (auto& x : hSE) x = uscale(rng);
    std::vector<int8_t> hWP((size_t)b_p*N_p*K_p);    for (auto& x : hWP) x = (int8_t)dw(rng);
    std::vector<float>  hSP((size_t)b_p*N_p);        for (auto& x : hSP) x = uscale(rng);
    std::vector<int8_t> hWR((size_t)C*C);            for (auto& x : hWR) x = (int8_t)dw(rng);
    std::vector<float>  hSR((size_t)C);              for (auto& x : hSR) x = uscale(rng);
    std::vector<float>  hCos((size_t)C);             for (auto& x : hCos) x = du(rng);
    std::vector<int8_t> hWEW((size_t)HID*C);         // wide raw expand weights (groups along N)
    for (int g = 0; g < b_e; ++g) for (int n = 0; n < N_e; ++n) for (int k = 0; k < C; ++k)
        hWEW[(size_t)(g*N_e + n)*C + k] = hWE[(size_t)g*N_e*C + (size_t)n*C + k];

    auto mk = [&](size_t bytes){ void* p = malloc_device(bytes, q); q.memset(p, 0, bytes).wait(); return p; };
    // Mpad-sized rows where the PORT kernel touches them (dIn is read by PHASE 5 up to Mpad rows;
    // dPK/dSC feed retile_a/pScA up to Mpad rows). 现路 planes stay M/Mp-sized below.
    half* dIn  = (half*)mk((size_t)Mpad*C*2);
    half* dO1  = (half*)mk((size_t)M*C*2);          // 现路 1267
    half* dO2  = (half*)mk((size_t)Mpad*C*2);       // port 1267
    int8_t* dPK  = (int8_t*)mk((size_t)Mpad*(size_t)HID);
    float* dSC   = (float*)mk((size_t)Mpad*4);
    half* dH     = (half*)mk((size_t)M*(size_t)HID*2);
    half* dOt    = (half*)mk((size_t)M*C*2);        // 现路 1275
    int8_t* dApE = (int8_t*)mk((size_t)b_e*Mp*C);
    int8_t* dApP = (int8_t*)mk((size_t)Mp*HID);
    int8_t* dApR = (int8_t*)mk((size_t)Mp*C);
    int8_t* dBpE  = (int8_t*)mk((size_t)b_e*N_e*C);
    int8_t* dBpEW = (int8_t*)mk((size_t)HID*C);
    int8_t* dBpP  = (int8_t*)mk((size_t)C*HID);
    int8_t* dBpR  = (int8_t*)mk((size_t)C*C);
    float* dSE = (float*)mk((size_t)b_e*N_e*4);
    float* dSP = (float*)mk((size_t)C*4);
    float* dSR = (float*)mk((size_t)C*4);
    float* dCos = (float*)mk((size_t)C*4);
    int8_t* dWER = (int8_t*)mk(hWE.size());
    int8_t* dWPR = (int8_t*)mk(hWP.size());
    int8_t* dWRR = (int8_t*)mk(hWR.size());
    int8_t* dWEW = (int8_t*)mk(hWEW.size());
    q.memcpy(dIn, hIn.data(), (size_t)M*C*2);
    q.memcpy(dWER, hWE.data(), hWE.size());
    q.memcpy(dWPR, hWP.data(), hWP.size());
    q.memcpy(dWRR, hWR.data(), hWR.size());
    q.memcpy(dWEW, hWEW.data(), hWEW.size());
    q.memcpy(dSE, hSE.data(), hSE.size()*4);
    q.memcpy(dSP, hSP.data(), hSP.size()*4);
    q.memcpy(dSR, hSR.data(), hSR.size()*4);
    q.memcpy(dCos, hCos.data(), hCos.size()*4);

    // ---- weight packs (现路 maps, cache-owned) ----
    packdev::gather_pack_b_b(q, dWER, dBpE, N_e, C, C, (size_t)N_e*C, b_e);
    packdev::pack_b(q, dWEW, dBpEW, HID, C);
    packdev::gather_pack_b_diag_b(q, dWPR, dBpP, N_p, K_p, K_p, (size_t)N_p*K_p, b_p);
    packdev::pack_b(q, dWRR, dBpR, C, C);
    printf("-- packs done --\n");

    // ---- 现路 control leg (the shipped separate ops, s6_ffn_block2.cpp:585-595 VERBATIM) ----
    std::vector<std::function<void()>> ops = {
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
    size_t nC = (size_t)M*C, nH = (size_t)M*HID;
    std::vector<uint8_t> cpk1(nC), csc1((size_t)M*4), chid(nH*2), cpk2(nH), csc2((size_t)M*4),
                         cout(nC*2), cpk3(nC), csc3((size_t)M*4), cres(nC*2);
    ops[0](); q.wait();
    q.memcpy(cpk1.data(), dPK, nC); q.memcpy(csc1.data(), dSC, (size_t)M*4); q.wait();
    // ---- R1/R2: the port's faces, built ONCE in setup from the producer's own outputs ----
    const size_t nCp = (size_t)Mpad*C, nHp = (size_t)Mpad*HID;   // PADDED allocations (kernel rows)
    int8_t* pPkA  = (int8_t*)mk(nCp);
    float*  pScA  = (float*)mk((size_t)Mpad*4);
    int8_t* pWExp = (int8_t*)mk((size_t)HID*C);
    int8_t* pWPrj = (int8_t*)mk((size_t)C*HID);
    q.memcpy(pScA, dSC, (size_t)M*4);
    retile_a(q, dPK, pPkA, Mpad, C);
    retile_b(q, dBpEW, pWExp, HID, C);
    retile_b(q, dBpP,  pWPrj, C,  HID);
    q.wait();
    printf("-- port faces done (R1 retile_a %zu B, R2 retile_b %zu + %zu B) --\n", nC, (size_t)HID*C, (size_t)C*HID);
    // continue the chain + snapshots
    ops[1](); ops[2](); q.wait(); q.memcpy(chid.data(), dH, nH*2); q.wait();
    ops[3](); q.wait(); q.memcpy(cpk2.data(), dPK, nH); q.memcpy(csc2.data(), dSC, (size_t)M*4); q.wait();
    ops[4](); ops[5](); q.wait(); q.memcpy(cout.data(), dOt, nC*2); q.wait();
    qr_launch_esimd(q, dev, dOt, (sycl::uint2*)dPK, dSC, (unsigned)M, (unsigned)C); q.wait();
    q.memcpy(cpk3.data(), dPK, nC); q.memcpy(csc3.data(), dSC, (size_t)M*4); q.wait();
    ops[6](); ops[7](); q.wait(); q.memcpy(cres.data(), dO1, nC*2); q.wait();
    printf("-- 现路 snapshots done --\n");

    // ---- the port ----
    port::Args fa;
    fa.pkA = pPkA; fa.scA = pScA; fa.Wexp = pWExp; fa.bsExp = dSE;
    fa.Wproj = pWPrj; fa.bsProj = dSP; fa.Bres = dBpR; fa.bsRes = dSR; fa.cos = dCos;
    fa.dIn = dIn; fa.dOut = dO2; fa.M = M; fa.NGRP = ngrpP;
    int32_t* pSink = (int32_t*)mk((size_t)ngrpP * W * 320 * 4);
    const int sinkOn = getenv("PORT_SINK") ? atoi(getenv("PORT_SINK")) : 0;
    fa.sinkFlag = sinkOn;                           // 0 = branch never taken, but the compiler
                                                    // cannot fold it (kernel arg) => no phase DCE.
                                                    // 1 = the sinks really store (DCE cross-check).
    half* pH = (half*)mk(nHp*2);
    int8_t* pFR1 = (int8_t*)mk(nHp); half* pDEC = (half*)mk(nHp*2);
    int8_t* pPK2 = (int8_t*)mk(nHp); float* pSC2 = (float*)mk((size_t)Mpad*4); int8_t* pFR2 = (int8_t*)mk(nHp);
    half* pOUT = (half*)mk(nCp*2);
    int8_t* pPK3 = (int8_t*)mk(nCp); float* pSC3 = (float*)mk((size_t)Mpad*4); int8_t* pFR3 = (int8_t*)mk(nCp);
    fa.dHid = pH; fa.dfrag1 = pFR1; fa.ddec = pDEC;
    fa.dpk2 = pPK2; fa.dsc2 = pSC2; fa.dfrag2 = pFR2;
    fa.dOut1275 = pOUT; fa.dpk3 = pPK3; fa.dsc3 = pSC3; fa.dfrag3 = pFR3;
    fa.dSink = pSink;
    q.memset(pH, 0xA5, nHp*2); q.memset(pFR1, 0xA5, nHp); q.memset(pDEC, 0xA5, nHp*2);
    q.memset(pPK2, 0xA5, nHp); q.memset(pSC2, 0xA5, (size_t)Mpad*4);
    q.memset(pFR2, 0xA5, nHp); q.memset(pOUT, 0xA5, nCp*2); q.memset(pPK3, 0xA5, nCp);
    q.memset(pSC3, 0xA5, (size_t)Mpad*4); q.memset(pFR3, 0xA5, nCp); q.memset(dO2, 0xA5, nCp*2);
    q.memset(pSink, 0, (size_t)ngrpP * W * 320 * 4);
    q.wait();
    printf("-- port fused launch --\n");
    port::fused<S, true, 5>(q, fa).wait();
    printf("-- port launch done --\n");

    std::vector<uint8_t> fpk1(nC), fsc1((size_t)M*4), fhid(nH*2), ffr1(nH), fdec(nH*2),
                         fpk2(nH), fsc2((size_t)M*4),
                         ffr2(nH), fout(nC*2), fpk3(nC), fsc3((size_t)M*4), ffr3(nC), fres(nC*2);
    q.memcpy(fpk1.data(), pPkA, nC);
    q.memcpy(fsc1.data(), pScA, (size_t)M*4);
    q.memcpy(fhid.data(), pH, nH*2);
    q.memcpy(ffr1.data(), pFR1, nH); q.memcpy(fdec.data(), pDEC, nH*2);
    q.memcpy(fpk2.data(), pPK2, nH); q.memcpy(fsc2.data(), pSC2, (size_t)M*4); q.memcpy(ffr2.data(), pFR2, nH);
    q.memcpy(fout.data(), pOUT, nC*2);
    q.memcpy(fpk3.data(), pPK3, nC); q.memcpy(fsc3.data(), pSC3, (size_t)M*4); q.memcpy(ffr3.data(), pFR3, nC);
    q.memcpy(fres.data(), dO2, nC*2);
    q.wait();

    // un-fragment the port's faces back to row-major so they meet the 现路 planes head on
    std::vector<uint8_t> uPk1(nC), uPk2(nH), uPk3(nC);
    { const size_t per = (size_t)(C/32)*512u;
      for (size_t d = 0; d < nC; ++d) { size_t g = d/per, rem = d%per, kb = rem/512u; int off = (int)(rem%512u);
          uPk1[(g*16 + off/32)*(size_t)C + kb*32u + off%32] = fpk1[d]; } }
    { const size_t per = (size_t)(HID/32)*512u;
      for (size_t d = 0; d < nH; ++d) { size_t g = d/per, rem = d%per, kb = rem/512u; int off = (int)(rem%512u);
          uPk2[(g*16 + off/32)*(size_t)HID + kb*32u + off%32] = ffr2[d]; } }
    { const size_t per = (size_t)(C/32)*512u;
      for (size_t d = 0; d < nC; ++d) { size_t g = d/per, rem = d%per, kb = rem/512u; int off = (int)(rem%512u);
          uPk3[(g*16 + off/32)*(size_t)C + kb*32u + off%32] = ffr3[d]; } }

    printf("-- diff (现路 vs port) --\n");
    bool ok = true;
    ok &= diffbytes(cpk1.data(), uPk1.data(), nC, C, "pk1-face", "setup R1 retile");
    ok &= diffsc((const float*)csc1.data(), (const float*)fsc1.data(), M, "sc1", "setup (producer quant)");
    // ---- T1 codec forensics: encode+store, then decode (localizes the e4m3 transient) ----
    std::vector<uint8_t> uFr1(nH), exp1(nH);
    { const size_t per = (size_t)(HID/32)*512u;
      for (size_t d = 0; d < nH; ++d) { size_t g = d/per, rem = d%per, kb = rem/512u; int off = (int)(rem%512u);
          uFr1[(g*16 + off/32)*(size_t)HID + kb*32u + off%32] = ffr1[d]; } }
    { const uint16_t* hc = (const uint16_t*)chid.data();
      for (size_t i = 0; i < nH; ++i) exp1[i] = host_e4m3(hc[i]); }
    ok &= diffbytes(exp1.data(), uFr1.data(), nH, HID, "e4m3-enc", "PHASE 1 encode/store");
    ok &= diffbytes(chid.data(), fdec.data(), nH*2, HID, "e4m3-dec", "PHASE 2 decode", 2);
    {   // eyeball: group 0 row 0, first 16 hidden columns
        printf("  [forensic] row0 col0..15  现路 f16:");
        for (int j = 0; j < 16; ++j) printf(" %8.4f", (float)((const half*)chid.data())[j]);
        printf("\n  [forensic] row0 col0..15  enc(exp):");
        for (int j = 0; j < 16; ++j) printf(" %02X", exp1[j]);
        printf("\n  [forensic] row0 col0..15  enc(port):");
        for (int j = 0; j < 16; ++j) printf(" %02X", uFr1[j]);
        printf("\n  [forensic] row0 col0..15  dec(port):");
        for (int j = 0; j < 16; ++j) printf(" %8.4f", (float)((const half*)fdec.data())[j]);
        printf("\n  [forensic] row8 col0..15  dec(port):");
        for (int j = 0; j < 16; ++j) printf(" %8.4f", (float)((const half*)fdec.data())[(size_t)8*HID + j]);
        printf("\n  [forensic] row0 col64..79 dec(port):");
        for (int j = 0; j < 16; ++j) printf(" %8.4f", (float)((const half*)fdec.data())[64 + j]);
        printf("\n");
    }
    ok &= diffbytes(chid.data(), fhid.data(), nH*2, HID, "hid-f16", "PHASE 1 pub (epi3)", 2);
    ok &= diffbytes(cpk2.data(), fpk2.data(), nH, HID, "pk2-slm", "PHASE 2 requant");
    ok &= diffbytes(cpk2.data(), uPk2.data(), nH, HID, "pk2-frag", "PHASE 2 fragment order");
    ok &= diffsc((const float*)csc2.data(), (const float*)fsc2.data(), M, "sc2", "PHASE 2 row peak");
    ok &= diffbytes(cout.data(), fout.data(), nC*2, C, "out-1275", "PHASE 3 contract", 2);
    ok &= diffbytes(cpk3.data(), fpk3.data(), nC, C, "pk3", "PHASE 4 outquant");
    ok &= diffbytes(cpk3.data(), uPk3.data(), nC, C, "pk3-frag", "PHASE 4 fragment order");
    ok &= diffsc((const float*)csc3.data(), (const float*)fsc3.data(), M, "sc3", "PHASE 4 row peak");
    ok &= diffbytes(cres.data(), fres.data(), nC*2, C, "1267-FINAL", "PHASE 5 residual", 2);

    // ---- C1: per-phase timing by NPHASE truncation (compile-time => work-group-uniform, the
    // R5 barriers stay legal). Each phase has its own anti-DCE sink, so a truncated launch still
    // computes the WHOLE phase. Phases: 1 expand(=现路 P2) / 2 T1 requant / 3 contract(=P4) /
    // 4 outquant(=P5q) / 5 residual(=P6).
    Stat t1 = timeit([&]{ return port::fused<S, false, 1>(q, fa); });
    Stat t2 = timeit([&]{ return port::fused<S, false, 2>(q, fa); });
    Stat t3 = timeit([&]{ return port::fused<S, false, 3>(q, fa); });
    Stat t4 = timeit([&]{ return port::fused<S, false, 4>(q, fa); });
    Stat t5 = timeit([&]{ return port::fused<S, false, 5>(q, fa); });
    const double ph[5] = { t1.msM, t2.msM - t1.msM, t3.msM - t2.msM,
                           t4.msM - t3.msM, t5.msM - t4.msM };
    const double fExp = 2.0 * (double)M * (double)HID * (double)C;   // expand: N=HID, K=C
    const double fCon = 2.0 * (double)M * (double)C * (double)HID;   // contract: N=C, K=HID
    const double fRes = 2.0 * (double)M * (double)C * (double)C;     // residual: N=C, K=C
    auto tops = [](double flops, double ms) { return (ms > 1e-9) ? flops / ms / 1e9 : 0.0; };
    printf("-- phase msM: expand=%.4f requant=%.4f contract=%.4f outquant=%.4f res=%.4f "
           "(chain=%.4f) [sink=%d] --\n", ph[0], ph[1], ph[2], ph[3], ph[4], t5.msM, sinkOn);
    printf("-- TOPS: P2expand=%.3f P4contract=%.3f P6res=%.3f CHAIN=%.3f (FLOPs %.3f/%.3f/%.3f) --\n",
           tops(fExp, ph[0]), tops(fCon, ph[2]), tops(fRes, ph[4]),
           tops(fExp + fCon + fRes, t5.msM), fExp/1e6, fCon/1e6, fRes/1e6);
    // machine-readable sweep row (grf/spill/scratch come from spillcheck_port.py afterwards)
    printf("ROW;%s;%d;%d;%d;%u;%d;%.4f;%.4f;%.4f;%.4f;%d;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f\n",
           tag, LW, G, KN, S::SLM, ok ? 0 : 1, t5.msM, t5.msm, t5.msX, t5.med, nWG * LW,
           tops(fExp, ph[0]), tops(fCon, ph[2]), tops(fRes, ph[4]), tops(fExp + fCon + fRes, t5.msM),
           ph[0], ph[1], ph[2], ph[3], ph[4]);
    printf("%s %s\n", ok ? "GATE PASS" : "GATE FAIL", tag);

    free(dIn,q); free(dO1,q); free(dO2,q); free(dPK,q); free(dSC,q); free(dH,q); free(dOt,q);
    free(dApE,q); free(dApP,q); free(dApR,q); free(dBpE,q); free(dBpEW,q); free(dBpP,q); free(dBpR,q);
    free(dSE,q); free(dSP,q); free(dSR,q); free(dCos,q);
    free(dWER,q); free(dWPR,q); free(dWRR,q); free(dWEW,q);
    free(pPkA,q); free(pScA,q); free(pWExp,q); free(pWPrj,q); free(pSink,q);
    free(pH,q); free(pFR1,q); free(pDEC,q);
    free(pPK2,q); free(pSC2,q); free(pFR2,q); free(pOUT,q);
    free(pPK3,q); free(pSC3,q); free(pFR3,q);
    return ok;
}

// ---- C1 rung dispatch: one (shape, G, KNIFE) configuration per process ----
template <int C_, int HID_, int G_, int KN_>
static bool rung(const char* tag, int M, int N_e, int b_e, int N_p, int K_p, int b_p) {
    using S = port::Geo<C_, HID_, 16, G_, 1, KN_>;
    if constexpr (!S::FITS) {
        printf("SKIPROW;%s;LW%d;G%d;KN%d;SLM=%u;PG=%u x G=%d = %u > CAP %u\n",
               tag, S::LW, G_, KN_, S::SLM, S::PG, G_, S::PG * (uint32_t)G_, S::CAP);
        return true;
    } else return run_shape<S>(tag, M, N_e, b_e, N_p, K_p, b_p);
}

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);
    const int shape = getenv("PORT_SHAPE") ? atoi(getenv("PORT_SHAPE")) : 1;
    const int g     = getenv("PORT_G") ? atoi(getenv("PORT_G")) : (shape == 1 ? 4 : 2);
    const int kn    = getenv("PORT_KN") ? atoi(getenv("PORT_KN")) : 1;
    bool ok = true;
    if (shape == 1) {
        const char* tg = "S1-C64H256";  int M = 32640, Ne = 128, be = 2, Np = 32, Kp = 128, bp = 2;
        if      (g == 4  && kn == 0) ok = rung<64,256,4,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 8  && kn == 0) ok = rung<64,256,8,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 4  && kn == 1) ok = rung<64,256,4,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 8  && kn == 1) ok = rung<64,256,8,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 16 && kn == 1) ok = rung<64,256,16,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 16 && kn == 0) ok = rung<64,256,16,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 32 && kn == 1) ok = rung<64,256,32,1>(tg,M,Ne,be,Np,Kp,bp);   // LW=128
        else if (g == 32 && kn == 0) ok = rung<64,256,32,0>(tg,M,Ne,be,Np,Kp,bp);   // LW=128
        else printf("S1: no such rung (G=%d KN=%d)\n", g, kn);
    } else {
        const char* tg = "S2-C128H512"; int M = 8160, Ne = 128, be = 4, Np = 32, Kp = 128, bp = 4;
        if      (g == 2 && kn == 0) ok = rung<128,512,2,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 4 && kn == 0) ok = rung<128,512,4,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 2 && kn == 1) ok = rung<128,512,2,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 4 && kn == 1) ok = rung<128,512,4,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 8 && kn == 1) ok = rung<128,512,8,1>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 8 && kn == 0) ok = rung<128,512,8,0>(tg,M,Ne,be,Np,Kp,bp);
        else if (g == 16 && kn == 1) ok = rung<128,512,16,1>(tg,M,Ne,be,Np,Kp,bp);  // LW=128
        else if (g == 16 && kn == 0) ok = rung<128,512,16,0>(tg,M,Ne,be,Np,Kp,bp);  // LW=128
        else printf("S2: no such rung (G=%d KN=%d)\n", g, kn);
    }
    printf("\n==== PORT C1 shape=%d G=%d KN=%d: %s (fails=%d) ====\n",
           shape, g, kn, ok ? "diff=0 on every checkpoint" : "SEE DIFF LINES", gfails);
    return ok ? 0 : 1;
}
