// ffn_chip_kernel.hpp -- section 100 P3c v3d: the ffn_fused CHIP form, PROMOTED
// (bench_ffnchip: 4.4x vs the promoted split -- 0.384 vs 1.701 ms at M=130560 --
// and BIT-EXACT diff 0 / 4,177,920). The three lessons to the win, all banked:
// (1) an ESIMD dpas tile lives in ONE thread's registers -- the senior's coopmat
//     "subgroup takes 16 rows" maps to "THREAD takes 16 rows"; v2's sgid split
//     gave 16 work-items per tile = exactly the 16x cost (skip-pub bisect proved
//     the structure was otherwise right);
// (2) SLM weight staging WINS over global B reads (v3 6.1 vs v3b 8.9) -- BUT the
//     winning v3c keeps weights GLOBAL and stages only A/HS per-thread (64KB SLM,
//     LW=32) -- the bench ran this map GREEN and fast on this box;
// (3) the killer margin was the SCALAR pub chain: pub_vec_v8<8> (section 99's
//     bench_pubvec: vector == scalar-identical for epi 0/1/3/4 over 1M values)
//     turned 2.33 into 0.38. The residual fma stays AUTO-CONTRACTED (gemm_b_res
//     golden semantics, section 92).
// Guards (recorder): cin==32, hidden==128, f32 out (the captured ffn/stem/merge
// flags: epi 0), residual skip half (0x40000) or f32. Escape hatch NR_FFN_CHIP=0
// restores the promoted two-gemm tile-chain form.
#pragma once
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"

namespace ffnc {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;

// SLM map: EA (A operand, per-thread 1KB pack_a16 blocks) + HS (hidden stage,
// per-thread 1KB) = 64KB at LW=32. Weights from GLOBAL (L2-backed).
#define FFC_EA_OFF 0u

#define FFC_SLM_BYTES (64u * 1024u)

// P8-l (section 100): the RESIDUAL-FUSED store. dSkip/cp non-null => the store
// loop computes Cout = fma(skip, cos, acc) IN THE SAME PASS and the separate
// residual tail (ffn_tail_res) plus the dC2 scratch (67MB write + 67MB read per
// stem call, the L2-thrash the cgraph ledger priced at ~8.8ms/frame) VANISH.
// Bit-exactness: the tail's sycl::fma(sk,cv,c2) and here the auto-contracted
// sk*cv+acc are the SAME single-fused-rounding FMA per lane (the gemm_b_res
// golden semantics, section 92); epi=0 publish is the identity and the skip is
// RAW f32 (NO e4m3 boundary -- the P3c plain-ffn 131/8192 lesson was the
// half-skip + epi!=0 form, which stays on the split chain). Used ONLY by the
// stem/merge recorder sites (their guards checked there).
// P8-o: template on LW -- the SLM map scales with the workgroup (EA = LW x 1KB,
// HS = LW x 1KB): LW=32 -> 64KB (1 WG/SM), LW=16 -> 32KB (2 WG/SM). The occupancy
// hypothesis for the chip's frame-vs-isolated gap (P8-n: latency chain, NOT the
// round-trip -- the mega removed 100MB of it and the marginal stayed flat).
template <int LW, bool WSTAGE = false>
static inline event launch_ffn_chip(queue& q, const half* dA, const half* dEp,
                                    const half* dPp, float* Cout, int M, int Mp,
                                    const void* dSkip = nullptr, const float* cp = nullptr,
                                    bool half_skip = false,
                                    bool fjoin = true,
                                    bool pw16 = true,
                                    bool ff9 = true) {   // B3-ffn-9: hoisted cp + 16-wide skip loads (escape NR_FF9=0)
    const unsigned cin = 32;
    int tiles = Mp / 16;
    int wgs = (tiles + LW - 1) / LW;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wgs * (unsigned)LW), range((unsigned)LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<(unsigned)LW * 2048u + (WSTAGE ? 16384u : 0u)>();   // EA+HS (+16KB weight stage)
            uint wg = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int tr = (int)(wg * (unsigned)LW + lid);
            const bool ours = (tr < tiles);   // HANG LESSON (the gate caught it,
                                       // the bench hid it): an early return BEFORE
                                       // esimd::barrier desyncs the WG barrier --
                                       // bench M=130560 had tiles=8160 %32==0 so no
                                       // thread ever returned; the gate's M=256 ->
                                       // tiles=16 -> 16 threads skipped the barrier
                                       // -> DEADLOCK. Guard the WORK, never the
                                       // barrier.
            // ---- v3c: A operand -> SLM (pack_a16 map), NOT GRF: frees 4 x 256B
            // registers -- the 16-live-GRF spill suspect (v9b ">8 accs" family) ----
            uint ea = FFC_EA_OFF + lid * 1024u;
            #pragma unroll
            for (int r = 0; r < 8 && ours; ++r) {
                esimd::simd<half,32> v((half)0.f);
                if (tr * 16 + r < (int)M)
                    v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + r) * cin, esimd::overaligned_tag<16>{});
                esimd::simd<half,16> lo0 = v.template select<16,1>(0), hi0 = v.template select<16,1>(16);
                esimd::slm_block_store(ea + (uint)r*32u, lo0, esimd::overaligned_tag<16>{});          // block(kc0,strip0)
                esimd::slm_block_store(ea + 512u + (uint)r*32u, hi0, esimd::overaligned_tag<16>{});    // block(kc1,strip0)
            }
            #pragma unroll
            for (int r = 0; r < 8 && ours; ++r) {
                esimd::simd<half,32> v((half)0.f);
                if (tr * 16 + 8 + r < (int)M)
                    v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + 8 + r) * cin, esimd::overaligned_tag<16>{});
                esimd::simd<half,16> lo1 = v.template select<16,1>(0), hi1 = v.template select<16,1>(16);
                esimd::slm_block_store(ea + 256u + (uint)r*32u, lo1, esimd::overaligned_tag<16>{});    // block(kc0,strip1)
                esimd::slm_block_store(ea + 768u + (uint)r*32u, hi1, esimd::overaligned_tag<16>{});    // block(kc1,strip1)
            }
            // B3-ffn-2 (Little's-law fix for the chip's 138 GB/s): the c-loop
            // weight loads are THE redundant global traffic -- every thread loads
            // 16KB of dEp+dPp (64 x 256B) and the LW threads of a WG load the SAME
            // 16KB => 256KB of L2 reads per tile, 8160 tiles x 16KB = 130MB of
            // weight fetches per stem call (MORE than the 100MB data traffic).
            // Stage both weight planes (8+8KB) into SLM ONCE per WG (cooperative:
            // LW=16 threads x 1KB each), then the c-loop reads are slm_block_load
            // (same values, same order, same 256B blocks -> bit-exact by
            // construction; no GRF cost -- the register wall (v3c) stays honored).
            uint wsb = (unsigned)LW * 2048u;      // after EA+HS (LW=16: 32KB..48KB, 64KB bucket)
            if (WSTAGE) {   // 4096 halfs each plane / LW=16 threads = 256 halfs/thread
                #pragma unroll
                for (int i = 0; i < 2; ++i) {
                    uint off = (uint)(lid * 256u + i * 128u);
                    esimd::simd<half,128> wv = esimd::block_load<half,128>(dEp + off, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(wsb + off * 2u, wv, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < 2; ++i) {
                    uint off = (uint)(lid * 256u + i * 128u);
                    esimd::simd<half,128> wv = esimd::block_load<half,128>(dPp + off, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(wsb + 8192u + off * 2u, wv, esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();   // v3c FIX: the A stores must be visible before the
                                // SLM loads (v3b had no SLM A; the removed weight
                                // barrier also guarded this -- restore it here)
            if (!ours) return;  // SAFE after the barrier
            uint hs = FFC_EA_OFF + (unsigned)LW * 1024u + lid * 1024u;   // the HS area follows EA (LW-scaled)   // per-thread 1KB hidden stage (this chunk)
            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31
            const esimd::simd<half,8> z8((half)0.f);
            for (int c = 0; c < 4; ++c) {
                for (int tl = 0; tl < 2; ++tl) {
                    esimd::simd<float,64> e00(0.f), e01(0.f), e10(0.f), e11(0.f);
                    // B3-ffn-10 (prefetch depth-2: the c-loop issued each weight
                    // load IMMEDIATELY before its dpas = every global load ate its
                    // ~300-cycle latency inline. Issue BOTH kc slices' b0/b1 up
                    // front (4 loads in flight), then the dpas sequence consumes
                    // them. Loads are pure; dpas order/values UNCHANGED = bit-exact
                    // by construction. NR_FFP=0 escape via the old inline form?
                    // (kept single-form: this IS the shipping shape; the judge is
                    // bench_b3 + FFN gate + 1301 + 16-pair.)
                    uint tc = (uint)(c * 2 + tl);
                    const half* bb0 = dEp + ((size_t)0u * 8u + tc) * 2u * 128u;
                    const half* bb1 = dEp + ((size_t)1u * 8u + tc) * 2u * 128u;
                    esimd::simd<half,128> w00 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((0u * 8u + tc) * 2u * 128u) * 2u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb0, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> w01 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((0u * 8u + tc) * 2u * 128u + 128u) * 2u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb0 + 128, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> w10 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((1u * 8u + tc) * 2u * 128u) * 2u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb1, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> w11 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((1u * 8u + tc) * 2u * 128u + 128u) * 2u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb1 + 128, esimd::overaligned_tag<16>{});
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+0u)*256u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+1u)*256u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b0 = kc ? w10 : w00;
                        esimd::simd<half,128> b1 = kc ? w11 : w01;
                        e00 = esimd::xmx::dpas<8,8,float>(e00, b0, a0);
                        e01 = esimd::xmx::dpas<8,8,float>(e01, b1, a0);
                        e10 = esimd::xmx::dpas<8,8,float>(e10, b0, a1);
                        e11 = esimd::xmx::dpas<8,8,float>(e11, b1, a1);
                    }
                    uint hb = hs + (uint)(tl * 2u) * 256u;
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        bool in0 = (tr * 16 + r) < (int)M, in1 = (tr * 16 + 8 + r) < (int)M;
                        esimd::simd<half,8> h00, h01, h10, h11;
                        // B3-ffn-3 (the chip anatomy §6.26: 98% of the leg is ENCODE
                        // ISSUE; pub_vec ran as simd<8> chains on 16/32-wide EUs =
                        // half the slot wasted per instruction). Widen the adjacent
                        // 8+8 col-groups of one row into ONE simd<16> pub call: the
                        // chains are PURELY ELEMENTWISE (gate/e4m3 f32 ops; width
                        // cannot change a bit), and the pair is exactly what the
                        // fjoin stores below re-join anyway. 4x vec8 pub -> 2x vec16.
                        if (in0 && pw16) { esimd::simd<float,16> a;
                            a.template select<8,1>(0) = e00.template select<8,1>(r*8);
                            a.template select<8,1>(8) = e01.template select<8,1>(r*8);
                            esimd::simd<half,16> hj = esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, a));
                            h00 = hj.template select<8,1>(0); h01 = hj.template select<8,1>(8); }
                        else if (in0) { esimd::simd<float,8> a = e00.template select<8,1>(r*8), b = e01.template select<8,1>(r*8);
                            h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                            h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                        else { h00 = z8; h01 = z8; }
                        if (in1 && pw16) { esimd::simd<float,16> a;
                            a.template select<8,1>(0) = e10.template select<8,1>(r*8);
                            a.template select<8,1>(8) = e11.template select<8,1>(r*8);
                            esimd::simd<half,16> hj = esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, a));
                            h10 = hj.template select<8,1>(0); h11 = hj.template select<8,1>(8); }
                        else if (in1) { esimd::simd<float,8> a = e10.template select<8,1>(r*8), b = e11.template select<8,1>(r*8);
                            h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                            h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                        else { h10 = z8; h11 = z8; }
                        // B3-ffn-1 (leg map 11:0x: the ffn leg = -11.4 wall, the chip
                        // kernel itself priced at 106-135 GB/s by bench_ffnchip):
                        // the four 16B SLM stores below are ADJACENT PAIRS (h00|
                        // h01 at +16B, h10|h11 at +256B+16B) -- join into two 32B
                        // stores (values identical by construction; the P8-q2
                        // store-join precedent, bench-proven instruction-count win).
                        // (fjoin is a host-captured param now -- ESIMD bans non-const statics)
                        if (fjoin) {
                        esimd::simd<half,16> j0; j0.template select<8,1>(0) = h00; j0.template select<8,1>(8) = h01;
                        esimd::simd<half,16> j1; j1.template select<8,1>(0) = h10; j1.template select<8,1>(8) = h11;
                        esimd::slm_block_store(hb + (uint)r * 32u, j0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, j1, esimd::overaligned_tag<16>{});
                        } else {
                        esimd::slm_block_store(hb + (uint)r * 32u, h00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + (uint)r * 32u + 16u, h01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, h10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u + 16u, h11, esimd::overaligned_tag<16>{});
                        }
                    }
                }
                // (v3: NO barrier here -- HS is this thread's private 1KB; the
                // in-order ESIMD pipeline orders the stores before the loads.
                // The v2 barriers were for the SHARED per-subgroup stage, gone now.)
                // B3-ffn-10b HYBRID: the full 8-reg proj hoist cost +3% (GRF
                // pressure = the v3c wall again); REVERT proj to inline, KEEP
                // the expand 4-load hoist (only 2 extra live regs there).
                #pragma unroll
                for (int kc2 = 0; kc2 < 2; ++kc2) {
                    uint kcg = (uint)(c * 2 + kc2);
                    uint ab = hs + (uint)(kc2 * 2u) * 256u;
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                    const half* bb = dPp + ((size_t)kcg * 2u + 0u) * 2u * 128u;
                    uint wb = wsb + 8192u + kcg * 1024u;
                    esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    p00 = esimd::xmx::dpas<8,8,float>(p00, b0, a0);
                    p01 = esimd::xmx::dpas<8,8,float>(p01, b1, a0);
                    p10 = esimd::xmx::dpas<8,8,float>(p10, b0, a1);
                    p11 = esimd::xmx::dpas<8,8,float>(p11, b1, a1);
                    bb += 256;
                    esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> c1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 768u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    q00 = esimd::xmx::dpas<8,8,float>(q00, c0, a0);
                    q01 = esimd::xmx::dpas<8,8,float>(q01, c1, a0);
                    q10 = esimd::xmx::dpas<8,8,float>(q10, c0, a1);
                    q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);
                }
            }
            // B3-ffn-9 (the leg ledger: the ffn leg = -10.5 wall but the chip's own
            // traffic roof is ~2.5ms -> the leg is ISSUE-bound; the fold re-reads the
            // 32-float cosine plane cp EIGHT TIMES PER ROW-HALF (loop-invariant!) and
            // loads skip as 8-wide 32B messages). Hoist cp to two 16-wide registers
            // outside the r-loop; widen the skip load to 16-wide (64B). The FMA shape
            // rule is UNTOUCHED: every 8-lane o = k*w + acc keeps the identical
            // straight-line text (the section-75 lesson is about PHI reassignment,
            // not hoisting); the FFN gate + 1301 are the judges. NR_FF9=0 escape.
            esimd::simd<float,16> wcA, wcB;
            if (dSkip && ff9) { wcA = esimd::block_load<float,16>(cp, esimd::overaligned_tag<16>{});
                                 wcB = esimd::block_load<float,16>(cp + 16, esimd::overaligned_tag<16>{}); }
            size_t outb = (size_t)(tr * 16) * cin;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                if (tr * 16 + r < M) {
                    esimd::simd<float,8> f0 = p00.template select<8,1>(r*8), f1 = p01.template select<8,1>(r*8);
                    esimd::simd<float,8> g0 = q00.template select<8,1>(r*8), g1 = q01.template select<8,1>(r*8);
                    // P8-l + B5-3 REWRITE (2026-10-29): the ffn-main 131/8192 gate red was
                    // the scope/phi contraction trap (section 75's lesson: reassigning f0
                    // inside if(dSkip){} makes k*w+f lower as muladd = TWO roundings; the
                    // green ffn_tail_res tv form is a straight-line load-then-expression =
                    // ONE HW FMA). sycl::fma on simds is a compile error in ESIMD (section
                    // 93), so the fix is the section-75 SHAPE: each branch computes its
                    // store value in a straight-line block (load immediately adjacent to
                    // the expression, no phi reassignment of f0..g1).
                    size_t rb = outb + (size_t)r * cin;
                    if (dSkip) {
                        // B5-3: the skip load honors half_skip (ffn-main's 0x40000 form):
                        // the tail read (float)(half)skp[i] == a half block_load + convert.
                        if (ff9) {
                            esimd::simd<float,16> kA = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                            esimd::simd<float,16> kB = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb + 16u, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb + 16u, esimd::overaligned_tag<16>{});
                            { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcA.template select<8,1>(0) + f0;
                              esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcA.template select<8,1>(8) + f1;
                              esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                            { esimd::simd<float,8> oA = kB.template select<8,1>(0) * wcB.template select<8,1>(0) + g0;
                              esimd::simd<float,8> oB = kB.template select<8,1>(8) * wcB.template select<8,1>(8) + g1;
                              esimd::simd<float,16> ob; ob.template select<8,1>(0) = oA; ob.template select<8,1>(8) = oB; ob.copy_to(Cout + rb + 16u); }
                        } else {
                        auto fold8 = [&](esimd::simd<float,8>& acc, size_t off) SYCL_ESIMD_FUNCTION {
                            esimd::simd<float,8> k = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,8>(
                                      (const half*)dSkip + rb + off, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,8>((const float*)dSkip + rb + off,
                                      esimd::overaligned_tag<16>{});
                            esimd::simd<float,8> w = esimd::block_load<float,8>(cp + off,
                                      esimd::overaligned_tag<16>{});
                            esimd::simd<float,8> o = k * w + acc;   // straight-line = ONE HW FMA
                            return o;
                        };
                        { esimd::simd<float,16> oa; oa.template select<8,1>(0) = fold8(f0, 0);
                          oa.template select<8,1>(8) = fold8(f1, 8); oa.copy_to(Cout + rb); }
                        { esimd::simd<float,16> ob; ob.template select<8,1>(0) = fold8(g0, 16);
                          ob.template select<8,1>(8) = fold8(g1, 24); ob.copy_to(Cout + rb + 16u); }
                        }
                    } else {
                        f0.copy_to(Cout + rb + 0);
                        f1.copy_to(Cout + rb + 8);
                        g0.copy_to(Cout + rb + 16);
                        g1.copy_to(Cout + rb + 24);
                    }
                }
                if (tr * 16 + 8 + r < M) {
                    esimd::simd<float,8> f0 = p10.template select<8,1>(r*8), f1 = p11.template select<8,1>(r*8);
                    esimd::simd<float,8> g0 = q10.template select<8,1>(r*8), g1 = q11.template select<8,1>(r*8);
                    size_t rb = outb + (size_t)(8+r) * cin;
                    if (dSkip) {
                        if (ff9) {
                            esimd::simd<float,16> kA = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                            esimd::simd<float,16> kB = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb + 16u, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb + 16u, esimd::overaligned_tag<16>{});
                            { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcA.template select<8,1>(0) + f0;
                              esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcA.template select<8,1>(8) + f1;
                              esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                            { esimd::simd<float,8> oA = kB.template select<8,1>(0) * wcB.template select<8,1>(0) + g0;
                              esimd::simd<float,8> oB = kB.template select<8,1>(8) * wcB.template select<8,1>(8) + g1;
                              esimd::simd<float,16> ob; ob.template select<8,1>(0) = oA; ob.template select<8,1>(8) = oB; ob.copy_to(Cout + rb + 16u); }
                        } else {
                        auto fold8 = [&](esimd::simd<float,8>& acc, size_t off) SYCL_ESIMD_FUNCTION {
                            esimd::simd<float,8> k = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,8>(
                                      (const half*)dSkip + rb + off, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,8>((const float*)dSkip + rb + off,
                                      esimd::overaligned_tag<16>{});
                            esimd::simd<float,8> w = esimd::block_load<float,8>(cp + off,
                                      esimd::overaligned_tag<16>{});
                            esimd::simd<float,8> o = k * w + acc;   // straight-line = ONE HW FMA
                            return o;
                        };
                        { esimd::simd<float,16> oa; oa.template select<8,1>(0) = fold8(f0, 0);
                          oa.template select<8,1>(8) = fold8(f1, 8); oa.copy_to(Cout + rb); }
                        { esimd::simd<float,16> ob; ob.template select<8,1>(0) = fold8(g0, 16);
                          ob.template select<8,1>(8) = fold8(g1, 24); ob.copy_to(Cout + rb + 16u); }
                        }
                    } else {
                        f0.copy_to(Cout + rb + 0);
                        f1.copy_to(Cout + rb + 8);
                        g0.copy_to(Cout + rb + 16);
                        g1.copy_to(Cout + rb + 24);
                    }
                }
            }
        });
    });
}

// P8-n / B1 BRICK 1 (section 100): the STEM MEGAKERNEL -- pass A (the adapter
// gemm) and the chip (expand+projection+fused residual) in ONE launch; the 16x32
// f32 tile (ES), its e4m3 halves (EA, the chip's pack_a16 map) and the hidden
// stage (HS) live in PER-THREAD SLM-PRIVATE areas (4KB x LW=16 = 64KB, the proven
// cap). dS (67MB) and dH16 (33MB) NEVER TOUCH GLOBAL -- the P8-n ledger's
// 3.4ms/call in-frame chip penalty (cold re-read of pass A's just-written 100MB)
// is the target. Bit-exact: phase-1 dpas VERBATIM = f16v1::gemm; EA = pub_vec
// e4m3 (== dH16, P8-m proven); phase-2 = the chip's c-loop VERBATIM; residual
// reads ES (= P8-l's dS read). ALL SLM offsets compile-time constants (the
// A-map lesson). bench_stem_mega: diff 0 / 16,711,680 EXACT vs the shipped
// dual+chip-res chain at M=522240; isolated delta +0.19ms (the frame A/B is the
// real judge -- the isolated bench cannot see the L2 interaction being removed).
// Register budget: phase1 8 accs, phase2 8+4 = 12 live -- the senior probe's
// SAFE line (<=12 accs, scratch 0). LW=16 (not 32): the per-thread 4KB map is
// identical, the WG count doubles -- occupancy is EU-slot-bound, not LW-bound.
// SLM per thread: ES 2048B (16x32 f32 row-major), EA 1024B (the chip's pack_a16
// map of e4m3 halfs), HS 1024B (the chip's hidden stage). LW=16 -> 64KB.
#define SM_ES 0u
#define SM_EA 2048u
#define SM_HS 3072u
#define SM_THR 4096u

static inline event stem_mega(queue& q, const half* dAp, const half* dAdB, const half* dEp,
                       const half* dPp, const float* cp, float* Cout, int M, int Mp) {
    const int tiles = Mp / 16;
    const int LW = getenv("SM_LW") ? atoi(getenv("SM_LW")) : 16;
    int wgs = (tiles + LW - 1) / LW;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wgs * LW), range((size_t)LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<64u * 1024u>();
            uint wg = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int tr = (int)(wg * (unsigned)LW + lid);
            const bool ours = (tr < tiles);
            uint sb = lid * SM_THR;
            uint es = sb + SM_ES, ea = sb + SM_EA, hs = sb + SM_HS;
            // ---- phase 1: the adapter gemm (features @ adapter, 16x32x16):
            // TWO tc tiles (cols 0-15, 16-31), each the gemm() load/dpas sequence VERBATIM.
            esimd::simd<float,64> c00(0.f),c01(0.f),c10(0.f),c11(0.f);   // tc=0
            esimd::simd<float,64> d00(0.f),d01(0.f),d10(0.f),d11(0.f);   // tc=1
            if (ours) {
                const half* ab = dAp + (size_t)tr * 2u * 128u;           // pack_a16: kc=0 only, K=16: blocks (tl0,tl1) 128 halfs each
                esimd::simd<half,128> a0(ab, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> a1(ab + 128, esimd::overaligned_tag<16>{});
                const half* bb = dAdB;                                    // tc_n=2, kb_n=1: tile(tc) at (0*2+tc)*128 halfs
                esimd::simd<half,128> b0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> b1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                c00 = esimd::xmx::dpas<8,8,float>(c00, b0, a0);
                c01 = esimd::xmx::dpas<8,8,float>(c01, b1, a0);
                c10 = esimd::xmx::dpas<8,8,float>(c10, b0, a1);
                c11 = esimd::xmx::dpas<8,8,float>(c11, b1, a1);
                const half* bb2 = dAdB + 2u * 128u;                       // tc=1
                esimd::simd<half,128> e0 = esimd::block_load<half,128>(bb2, esimd::overaligned_tag<16>{});
                esimd::simd<half,128> e1 = esimd::block_load<half,128>(bb2 + 128, esimd::overaligned_tag<16>{});
                d00 = esimd::xmx::dpas<8,8,float>(d00, e0, a0);
                d01 = esimd::xmx::dpas<8,8,float>(d01, e1, a0);
                d10 = esimd::xmx::dpas<8,8,float>(d10, e0, a1);
                d11 = esimd::xmx::dpas<8,8,float>(d11, e1, a1);
            }
            // ES (f32 row-major 16x32) + EA (the chip's pack_a16 map, e4m3 halfs) stores:
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                if (ours) {
                    esimd::simd<float,8> r00 = c00.template select<8,1>(r*8), r01 = c01.template select<8,1>(r*8);
                    esimd::simd<float,8> r10 = d00.template select<8,1>(r*8), r11 = d01.template select<8,1>(r*8);
                    esimd::slm_block_store(es + (uint)r*128u,        r00, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)r*128u + 32u,  r01, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)r*128u + 64u,  r10, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)r*128u + 96u,  r11, esimd::overaligned_tag<16>{});
                    esimd::simd<float,8> s00 = c10.template select<8,1>(r*8), s01 = c11.template select<8,1>(r*8);
                    esimd::simd<float,8> s10 = d10.template select<8,1>(r*8), s11 = d11.template select<8,1>(r*8);
                    esimd::slm_block_store(es + (uint)(8+r)*128u,        s00, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)(8+r)*128u + 32u,  s01, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)(8+r)*128u + 64u,  s10, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(es + (uint)(8+r)*128u + 96u,  s11, esimd::overaligned_tag<16>{});
                    // EA: the chip's map -- block(kc,strip): (kc*2+strip)*256B + r*32B; cols
                    // 0-7 at +0, 8-15 at +16 (half,8 stores; e4m3 = pub_vec_v8(1u) == dH16).
                    esimd::slm_block_store(ea + (uint)r*32u,              esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + (uint)r*32u + 16u,        esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 512u + (uint)r*32u,       esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 512u + (uint)r*32u + 16u, esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 256u + (uint)r*32u,       esimd::convert<half>(s8v8::e4m3_vec_v8<8>(s00)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 256u + (uint)r*32u + 16u, esimd::convert<half>(s8v8::e4m3_vec_v8<8>(s01)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 768u + (uint)r*32u,       esimd::convert<half>(s8v8::e4m3_vec_v8<8>(s10)), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 768u + (uint)r*32u + 16u, esimd::convert<half>(s8v8::e4m3_vec_v8<8>(s11)), esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();          // HANG RULE: the barrier is OUTSIDE the ours guard
            if (!ours) return;
            // ---- phase 2: the chip's c-loop VERBATIM (EA/HS reads, dEp/dPp weights) ----
            esimd::simd<float,64> p00(0.f),p01(0.f),p10(0.f),p11(0.f);
            esimd::simd<float,64> q00(0.f),q01(0.f),q10(0.f),q11(0.f);
            const esimd::simd<half,8> z8((half)0.f);
            for (int c = 0; c < 4; ++c) {
                for (int tl = 0; tl < 2; ++tl) {
                    esimd::simd<float,64> e00(0.f),e01(0.f),e10(0.f),e11(0.f);
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+0u)*256u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+1u)*256u, esimd::overaligned_tag<16>{});
                        uint tc2 = (uint)(c * 2 + tl);
                        const half* bb = dEp + ((size_t)kc * 8u + tc2) * 2u * 128u;
                        esimd::simd<half,128> b0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        e00 = esimd::xmx::dpas<8,8,float>(e00, b0, a0);
                        e01 = esimd::xmx::dpas<8,8,float>(e01, b1, a0);
                        e10 = esimd::xmx::dpas<8,8,float>(e10, b0, a1);
                        e11 = esimd::xmx::dpas<8,8,float>(e11, b1, a1);
                    }
                    uint hb = hs + (uint)(tl * 2u) * 256u;
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e00.template select<8,1>(r*8)));
                        esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e01.template select<8,1>(r*8)));
                        esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e10.template select<8,1>(r*8)));
                        esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e11.template select<8,1>(r*8)));
                        esimd::slm_block_store(hb + (uint)r * 32u, h00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + (uint)r * 32u + 16u, h01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, h10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u + 16u, h11, esimd::overaligned_tag<16>{});
                    }
                }
                #pragma unroll
                for (int kc2 = 0; kc2 < 2; ++kc2) {
                    uint kcg = (uint)(c * 2 + kc2);
                    uint ab = hs + (uint)(kc2 * 2u) * 256u;
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                    const half* bb = dPp + ((size_t)kcg * 2u + 0u) * 2u * 128u;
                    esimd::simd<half,128> b0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    p00 = esimd::xmx::dpas<8,8,float>(p00, b0, a0);
                    p01 = esimd::xmx::dpas<8,8,float>(p01, b1, a0);
                    p10 = esimd::xmx::dpas<8,8,float>(p10, b0, a1);
                    p11 = esimd::xmx::dpas<8,8,float>(p11, b1, a1);
                    bb += 256;
                    esimd::simd<half,128> c0 = esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> c1 = esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    q00 = esimd::xmx::dpas<8,8,float>(q00, c0, a0);
                    q01 = esimd::xmx::dpas<8,8,float>(q01, c1, a0);
                    q10 = esimd::xmx::dpas<8,8,float>(q10, c0, a1);
                    q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);
                }
            }
            // ---- residual from ES + store (the P8-l fused tail, skip from SLM now) ----
            size_t outb = (size_t)(tr * 16) * 32;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                if (tr * 16 + r < M) {
                    size_t rb = outb + (size_t)r * 32;
                    #pragma unroll
                    for (int cc = 0; cc < 4; ++cc) {
                        esimd::simd<float,8> acc = (cc==0)? p00.template select<8,1>(r*8) : (cc==1)? p01.template select<8,1>(r*8) : (cc==2)? q00.template select<8,1>(r*8) : q01.template select<8,1>(r*8);
                        esimd::simd<float,8> sk = esimd::slm_block_load<float,8>(es + (uint)r*128u + (uint)cc*32u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> w  = esimd::block_load<float,8>(cp + cc*8, esimd::overaligned_tag<16>{});
                        (sk * w + acc).copy_to(Cout + rb + cc*8);
                    }
                }
                if (tr * 16 + 8 + r < M) {
                    size_t rb = outb + (size_t)(8+r) * 32;
                    #pragma unroll
                    for (int cc = 0; cc < 4; ++cc) {
                        esimd::simd<float,8> acc = (cc==0)? p10.template select<8,1>(r*8) : (cc==1)? p11.template select<8,1>(r*8) : (cc==2)? q10.template select<8,1>(r*8) : q11.template select<8,1>(r*8);
                        esimd::simd<float,8> sk = esimd::slm_block_load<float,8>(es + (uint)(8+r)*128u + (uint)cc*32u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,8> w  = esimd::block_load<float,8>(cp + cc*8, esimd::overaligned_tag<16>{});
                        (sk * w + acc).copy_to(Cout + rb + cc*8);
                    }
                }
            }
        });
    });
}
}
