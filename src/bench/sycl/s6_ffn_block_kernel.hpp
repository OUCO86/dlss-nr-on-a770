// s6_ffn_block_kernel.hpp -- S6-1a block-resident FFN chain kernel, SHIPPED form.
//
// SOURCE OF TRUTH: this kernel body is extracted VERBATIM (character-for-character in
// the numeric chain) from the byte-exact bench that proved it:
//     src/bench/sycl/s6_ffn_block2.cpp  lines 67-400  (namespace ffn2: Shape / Args /
//     fused<S,DUMP,NPHASE>), stage-2 gate = nine checkpoints diff=0 on S1 (C=64) and
//     S2 (C=128), seven + transitive on S3, incl. the FINAL 1267 face.
//     Bench accounts: E:/DSH/s6/stage1.md (stage 1), E:/DSH/s6/stage2.md (stage 2).
//     Blueprint + red lines: notes/DS-takeover-2026-11-01.md sections 16 / 17 / 21.
//
// SWITCH: NR_S6_FFN -- DEFAULT ON since the S6-1a promotion (2026-11-01); the escape
// hatch NR_S6_FFN=0 selects the pre-S6 split path. The switch is CLOSURE-LEVEL ONLY in
// the recorder (military rules 4/9): no runtime diagnostic branch was added inside this
// kernel -- the kernel body below is byte-identical either way, only the call site differs.
// The shipped call site instantiates fused<S, false, S::NPH>, so every `if (DUMP)` folds
// to false and every `if (NPHASE <= k) return;` folds to false -- the code below is
// identical to the timed bench leg (s6_ffn_block2.cpp:709-710).
//
// WHAT IT DOES: one workgroup owns T tokens of one block chain and runs the six
// recorder ops of the FFN closure (plan lines 5337-5349 / 4055-4065) on-chip:
//     P1 = QUANT(src -> pk/sc)            (rowthread VERBATIM, K=C)
//     P2 = GEMM_INT8_BATCHED expand       -> hidden f16 in SLM
//     P3 = QUANT over the hidden plane    (row peak taken AFTER the f16 rounding)
//     P4 = GEMM_INT8_BATCHED projection   -> out f16 in SLM
//     P5 = QUANT over the out plane
//     P6 = GEMM_INT8_RESIDUAL (+skip*cos, epi1) -> the 1267 face
// The three pk/sc round trips never touch global memory (they live in SLM); only the
// 1270 read and the 1267 write remain -- the whole point of the blade.
//
// NUMERIC RED LINES kept VERBATIM (do not "optimise" these without re-passing the bench
// gate): s8v8::pub_vec_v8 for every publish; esimd::div_ieee (fdiv_rn) for the quant
// grid; the row peak is computed over the f16-ROUNDED values (P3/P5 read the SLM f16
// plane, not the pre-rounding float); the f16-proj family (S3) keeps the shipped
// sequential kc order because its accumulator is f32 (split-K ILLEGAL -- see the proof
// block in s6_ffn_block2.cpp:16-30). split-K here is legal ONLY because the int32
// partial sums are exact (|acc| <= K*127^2 << 2^31) and the reduce order is fixed by
// index arithmetic (ascending ks, ks==0 owner).
//
// FRAME SHAPES THIS FILE IS WIRED FOR (stage-2 measured families):
//     S1  C=64  HID=256  M=32640  Shape<32,64,256,false,4,2>   x8  chains/frame
//     S2  C=128 HID=512  M=8160   Shape<16,128,512,false,4,2>  x12 chains/frame
//   (S3 C=256 M=2040 is the f16-proj family: its projection is NOT at
//    xmx_rec_gemm_int8_batched, so the three-site pairing of this round does not fire
//    for it; F3 C=512 M=640 was never built. Both are reported honestly in stage3.)
//
// Build: compiled as part of libxmx_sycl.dll (bash E:/DSH/build_dll.sh).
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/esimd.hpp>
#include <cstdint>
#include "gemm_s8_v8_kernel.hpp"   // s8v8::pub_vec_v8 (the shipped publish math)

namespace ffn2 {
using namespace sycl;              // the bench file had this at scope; keeps the body verbatim

template <int T_, int C_, int HID_, bool F16PROJ_, int KS4_, int KS6_>
struct Shape {
    static constexpr int T = T_, C = C_, HID = HID_;
    static constexpr bool F16PROJ = F16PROJ_;
    static constexpr int KS4 = KS4_, KS6 = KS6_;
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
    static constexpr uint32_t STG4 = (uint32_t)((KS4_ - 1) * T_ * C_ * 4);
    static constexpr uint32_t STG6 = (uint32_t)((KS6_ - 1) * T_ * C_ * 4);
    static constexpr uint32_t O_STG = F16PROJ_ ? O_HID : O_PKH;
    static_assert(!F16PROJ_ || T_ == 8, "f16-proj compact HIDF map is written for T=8 only");
    static_assert(STG4 <= SZ_PKH + SZ_PK + SZ_HID, "P4 staging exceeds the dead SLM span");
    static_assert(STG6 <= (F16PROJ_ ? SZ_HID : SZ_PKH + SZ_PK + SZ_HID), "P6 staging exceeds the dead SLM span");
    // active threads per phase (compile-time; printed by the host):
    static constexpr int ACT2 = (T_ / 8) * (HID_ / 16);
    // f16-proj: one 16-row pack band covers T=8 (strip0), col bands C/16, NO split-K (f32 acc).
    static constexpr int ACT4 = F16PROJ_ ? (C_ / 16) : ((T_ / 8) * (C_ / 16) * KS4_);
    static constexpr int ACT6 = (T_ / 8) * (C_ / 8) * KS6_;
    static constexpr int NPH  = F16PROJ_ ? 5 : 6;
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
};

template <class S, bool DUMP, int NPHASE>
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
            const int r0 = blk * T;

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
                if (DUMP) a.dsc1[r0+t] = scale;
            }
            esimd::barrier();
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
                }
            }
            esimd::barrier();
            if (DUMP) {
                if (t < T && !S::F16PROJ) {   // S1/S2: row-major twin straight from SLM
                    for (int c = 0; c < HID/16; ++c)
                        esimd::block_store<half,16>(a.dHid + (size_t)(r0+t)*HID + c*16,
                            esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)t*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                            esimd::overaligned_tag<16>{});
                }
                esimd::barrier();
            }
            if (NPHASE <= 2) return;

            if (!S::F16PROJ) {
                // ---- P3: hidden row peak (OVER f16) -> pkH + scH ----
                if (t < T) {
                    esimd::simd<float,16> mx(esimd::simd<float,16>(0.f));
                    for (int c = 0; c < HID/16; ++c) {
                        esimd::simd<half,16> h = esimd::slm_block_load<half,16>(S::O_HID + (uint32_t)t*(HID*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{});
                        mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));
                    }
                    float peak = esimd::hmax<float,float,16>(mx);
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float,1>(esimd::simd<float,1>(peak), esimd::simd<float,1>(127.0f))[0];
                    esimd::slm_block_store(S::O_SC + 128u + (uint32_t)t*4u, esimd::simd<float,1>(scale), esimd::overaligned_tag<16>{});
                    for (int kb = 0; kb < S::KB_H; ++kb) {
                        esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_HID + (uint32_t)t*(HID*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                        q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                        esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                        esimd::slm_block_store<int8_t,32>(S::O_PKH + ((uint32_t)kb*BANDS + (uint32_t)(t>>4))*512u + (uint32_t)(t&15)*32u, o, esimd::overaligned_tag<16>{});
                        if (DUMP) esimd::block_store<int8_t,32>(a.dpk2 + (size_t)(r0+t)*HID + kb*32, o, esimd::overaligned_tag<16>{});
                    }
                    if (DUMP) a.dsc2[r0+t] = scale;
                }
                esimd::barrier();
                if (NPHASE <= 3) return;

                // ---- P4: proj int8 wide (T x C, K=HID) split-K KS4, epi1 -> out f16 ----
                {
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
                    esimd::barrier();   // all PKH reads done; staging may now alias PKH/PK/HIDF
                    constexpr uint32_t TILE4 = (uint32_t)((S::KS4 - 1) * 512u);   // 8 rows x 16 int32 = 512B per split
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
                    esimd::barrier();
                    if (ks == 0) {
                        esimd::simd<float,16> cs = esimd::block_load<float,16>(a.bsProj + cb4*16, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> rss = esimd::slm_block_load<float,8>(S::O_SC + 128u + (uint32_t)rb*32u, esimd::overaligned_tag<16>{}); // row scale = scH
                        for (int r = 0; r < 8; ++r) {
                            esimd::simd<int32_t,16> acc(0);
                            acc.template select<8,1>(0) = c00.template select<8,1>(r*8);
                            acc.template select<8,1>(8) = c01.template select<8,1>(r*8);
                            // fixed ascending-ks accumulate (exact int32; see proof block)
                            for (int kk = 1; kk < S::KS4; ++kk)
                                acc = acc + esimd::slm_block_load<int32_t,16>(slotbase + (uint32_t)(kk-1)*512u + (uint32_t)r*64u, esimd::overaligned_tag<16>{});
                            float rs = rss[r];
                            esimd::simd<float,16> pub = s8v8::pub_vec_v8<16>(1u, esimd::convert<float>(acc) * rs * cs);
                            esimd::slm_block_store<half,16>(S::O_OUT + (uint32_t)(rb*8 + r)*C*2u + (uint32_t)cb4*32u,
                                                            esimd::convert<half>(pub), esimd::overaligned_tag<16>{});
                        }
                    }
                }
                esimd::barrier();
                if (DUMP) {   // OUT sink: the P=4 truncation must not DCE P4's stores
                    if (t < T)
                        for (int c = 0; c < C/16; ++c)
                            esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                                esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    esimd::barrier();
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
                esimd::barrier();
                if (DUMP) {   // OUT sink for the P=3 truncation (f16-proj branch)
                    if (t < T)
                        for (int c = 0; c < C/16; ++c)
                            esimd::block_store<half,16>(a.dOut1275 + (size_t)(r0+t)*C + c*16,
                                esimd::slm_block_load<half,16>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)c*32u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    esimd::barrier();
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
                    for (int kb = 0; kb < S::KB_C; ++kb) {
                        esimd::simd<half,32> h = esimd::slm_block_load<half,32>(S::O_OUT + (uint32_t)t*(C*2u) + (uint32_t)kb*64u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,32> q2 = esimd::div_ieee<float,32>(esimd::convert<float>(h), esimd::simd<float,32>(scale));
                        q2 = esimd::min(esimd::max(esimd::rnde<float,32>(q2), esimd::simd<float,32>(-127.f)), esimd::simd<float,32>(127.f));
                        esimd::simd<int8_t,32> o = esimd::convert<int8_t>(esimd::convert<int>(q2));
                        esimd::slm_block_store<int8_t,32>(S::O_PK + ((uint32_t)kb*BANDS + (uint32_t)(t>>4))*512u + (uint32_t)(t&15)*32u, o, esimd::overaligned_tag<16>{});
                        if (DUMP) esimd::block_store<int8_t,32>(a.dpk3 + (size_t)(r0+t)*C + kb*32, o, esimd::overaligned_tag<16>{});
                    }
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
                esimd::barrier();
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
                uint32_t stride = 256u;   // per-(rb,cb6,ks) slot = 8 rows x 8 int32 = 256B
                uint32_t slot = S::O_STG + ((uint32_t)(rb*CB6 + cb6)*(S::KS6-1) + (uint32_t)(ks>0?ks-1:0))*stride;
                if (ks > 0)
                    for (int r = 0; r < 8; ++r)
                        esimd::slm_block_store<int32_t,8>(slot + (uint32_t)r*32u, c00.template select<8,1>(r*8), esimd::overaligned_tag<16>{});
                esimd::barrier();
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
