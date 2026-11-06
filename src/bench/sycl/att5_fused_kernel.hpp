// att5_fused_kernel.hpp -- the C=64 attention half of the port-E chain, SHIPPED form.
//
// SOURCE OF TRUTH: extracted VERBATIM (the numeric chain is character-for-character the
// bench's) from the byte-exact bench that proved it:
//     src/bench/sycl/s6b_att.cpp  lines 87-617  (namespace att5: Outlets / fused<C,HEADS,PHASES,DUMP,LIVE>)
//     gate: 12 checkpoints diff=0 vs the shipped split legs on S1 (C=64 M=32640) and C128;
//     self-repetition: att5::fused 0 bad / 1200 relaunches (E:/DSH/s6/knife2b.md #67);
//     composition gate: port_e_chain.cpp -- 25 checkpoints diff=0; the 3-launch and the 2-launch
//     forms are byte-identical to the 13-launch shipped chain (knife2b.md #70/#73/#77).
//
// SWITCH: NR_ATT5_FUSE -- DEFAULT 0 (the split path verbatim). =1 replaces the five recorder
// closures of the C=64 attention half (plan closures 641-645: QUANT_WINDOW, GEMM_INT8_QKV,
// WINDOW_ATTENTION, QUANT, GEMM_WINDOW_INT8_RESIDUAL) with ONE launch. The switch is
// CLOSURE-LEVEL ONLY in the recorder (military rules 4/9): no branch was added inside this
// kernel; the body below is byte-identical either way, only the call site differs.
// The shipped call site instantiates fused<64,2,5,false,false>, so every if (DUMP) folds away
// -- identical to the priced bench leg (port_e_chain.cpp L1n: 0.4336 ms alone, 0.9421 ms composed).
//
// GEOMETRY IS LOCKED (knife2b #64/#68): TOK=64 tokens/window, NH=3C, LW=16, SLM 32,768 B at
// C=64 (2 resident WG), grid = windows*16.  LW=32 is FORBIDDEN (measured deadlock region) and
// the C=128 rung is NOT wired into the engine (+51% slower, SLM 41,984 B crosses the 32 KB cliff).
//
// NUMERICS: accumulation order, fdiv_rn, the e4m3 snap, eh_round/ef_div and the FMA contraction
// are exactly the bench's. No esimd::shuffle was introduced anywhere in this chain.
//
// The two using-declarations below are the bench's OWN file-scope ones (s6b_att.cpp:77-78),
// relocated into this namespace so the body stays verbatim; they cannot leak into the TU.

namespace att5 {
using namespace sycl;
namespace esimd = sycl::ext::intel::esimd;


struct Outlets {                       // used only when DUMP=true (host-side compare buffers)
    int8_t* pk0p = nullptr; float* sc0p = nullptr;     // P7 out, pack_a order + row scales
    half* pQ = nullptr; half* pK = nullptr; half* pV = nullptr;   // P8 planes (shipped order)
    float* scores = nullptr;                            // P9 scores f32 (batches,64,64)
    half* probs = nullptr;                              // P9 probs, pack_a16 map (batches,4096)
    half* att = nullptr;                                // P10 source = the 1277 row (per head)
    int8_t* pkt = nullptr; float* as2 = nullptr;        // P10 out, row-major + row scales
};

template <int C, int HEADS, int PHASES, bool DUMP, bool LIVE>
static inline event fused(queue& q,
                           const half* dImg,          // 1267 image face (P7 source, P11 skip)
                           const int8_t* dBp,         // pack_b(3C, C) of W81
                           const float* bs,           // b_scale (3C)
                           const float* qs,           // qkv_scale (heads)
                           const float* dBias,        // attention bias (heads,64,64)
                           const int8_t* dOp,         // pack_b(C, C) of W79
                           const float* bs2, const float* cosv,   // wres b_scale (C), cosine (C)
                           half* Out2,                // 1270 image face
                           half* faceQ, half* faceK, half* faceV, // the FRAGMENT-ORDER Q/K/V faces
                           unsigned windows,
                           unsigned across, unsigned top, unsigned left,
                           unsigned image_h, unsigned image_w,
                           const Outlets& o) {
    LC_TICK();   // #145 军规 132: launch counted at helper entry
    constexpr int TOK = 64, NH = 3 * C, KBN = C / 32, PPH = C / 64;   // parts per kind
    // ---- SLM map (bytes) ----
    constexpr uint X0 = 0u;
    constexpr uint X0SZ = (HEADS * 4096u > 8192u) ? (HEADS * 4096u) : 8192u;
    constexpr uint Z0 = X0 + X0SZ;
    constexpr uint Y0 = Z0 + 16384u;
    constexpr uint Y0SZ = (KBN * 2048u + 256u > 8192u) ? (KBN * 2048u + 512u) : 8192u;
    constexpr uint SLMB = Y0 + Y0SZ;
    static_assert(SLMB <= 65536u, "over the A770 SLM cap (S29: 65,600 B is already REJECT)");
    // region-internal offsets
    constexpr uint BT = X0;                 // int8 gemm B double buffers (2 x 2048)
    constexpr uint ROWS = X0 + 4096u;       // K/V row staging (one head at a time, 4096 B)
    constexpr uint ATT = X0;                // the att band: head hh at ATT + hh*4096
    constexpr uint PKT = Z0;                // pk2 (KBN x 2048) + sc2 after it
    constexpr uint AS2 = Z0 + (uint)(KBN * 2048);
    constexpr uint PK0 = Y0;                // pk0 (KBN x 2048) + sc0 after it
    constexpr uint AS0 = Y0 + (uint)(KBN * 2048);
    constexpr uint PROB = Y0;               // probs, the pack_a16 map
    const size_t facebase = (size_t)TOK * 32u;   // 2048 halfs per (window, head) tile

    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)windows * 16u), range(16u)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<SLMB>();
            auto gr = it.get_group();
            uint w = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            int wi_row = (int)(lid / 4u), wi_col = (int)(lid % 4u);

            // ================= P7 = QUANT_WINDOW (gather 1267 rows -> pk0 + sc0 in SLM) ====
            // arithmetic VERBATIM = packdev::pack_a_fused_gather (the shipped P4b fold of this
            // very launch into the QKV pack leg): row peak AFTER the f16->f32 widening,
            // scale = div_ieee(peak,127), q = div_ieee(v,scale), rnide, clamp +-127, int8.
            if constexpr (PHASES >= 1) {
                #pragma unroll
                for (int t = 0; t < TOK / 16; ++t) {
                    uint token = (uint)(t * 16 + (int)lid);
                    unsigned yy = (w / across) * 8u + token / 8u;
                    unsigned xx = (w % across) * 8u + token % 8u;
                    int y = (int)yy - (int)top, x = (int)xx - (int)left;
                    bool outside = (y < 0 || x < 0 || y >= (int)image_h || x >= (int)image_w);
                    esimd::simd<float, C> v(0.f);
                    if (!outside) {
                        const sycl::half* arow = dImg + ((size_t)y * image_w + (size_t)x) * C;
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            v.template select<32, 1>(kb * 32) = esimd::convert<float>(
                                esimd::block_load<sycl::half, 32>(arow + kb * 32,
                                    esimd::overaligned_tag<16>{}));
                    }
                    float peak = esimd::hmax<float, float, C>(esimd::abs(v));
                    const float scale = (peak == 0.f) ? 1.f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak),
                                                    esimd::simd<float, 1>(127.f))[0];
                    esimd::simd<float, C> qq = esimd::div_ieee<float, C>(v, esimd::simd<float, C>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float, C>(qq), esimd::simd<float, C>(-127.f)),
                                    esimd::simd<float, C>(127.f));
                    esimd::simd<int8_t, C> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)          // the pack_a tile map: [kb][16-row band][row][32B]
                        esimd::slm_block_store<int8_t, 32>(PK0 + (uint)(kb * 2048 + t * 512 + (int)lid * 32),
                                                           qi.template select<32, 1>(kb * 32),
                                                           esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<float, 1>(AS0 + token * 4u, esimd::simd<float, 1>(scale));
                }
                group_barrier(gr);
                if constexpr (DUMP) {   // pk0 in the SAME pack_a order the shipped pack leg writes
                    const size_t band = (size_t)(w / 2u) * (KBN * 4096u) + (size_t)(w % 2u) * 2048u;
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            esimd::block_store<int8_t, 32>(o.pk0p + band + (size_t)kb * 4096u
                                        + (size_t)t * 512u + (size_t)lid * 32u,
                                esimd::slm_block_load<int8_t, 32>(PK0 + (uint)(kb * 2048 + t * 512 + (int)lid * 32),
                                        esimd::overaligned_tag<16>{}), esimd::overaligned_tag<16>{});
                        uint token = (uint)(t * 16 + (int)lid);
                        esimd::block_store<float, 1>(o.sc0p + (size_t)w * TOK + token,
                            esimd::slm_block_load<float, 1>(AS0 + token * 4u));
                    }
                    group_barrier(gr);
                }
            }

            // ================= P8 = GEMM_INT8_QKV (pk0 x W81 -> Q/K/V faces, v5a tail) =====
            if constexpr (PHASES >= 2) {
                #pragma unroll 1
                for (int part = 0; part < NH / 64; ++part) {
                    const int8_t* bp = dBp + (size_t)part * 2048u;
                    auto load_block = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                            bp + (size_t)kb * (NH * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(BT + (uint)(buf * 2048 + (int)lid * 128), bv,
                                               esimd::overaligned_tag<16>{});
                    };
                    auto load_grf = [=](int buf, int kb, esimd::simd<int8_t, 256>& a0, esimd::simd<int8_t, 256>& a1,
                                        esimd::simd<int8_t, 256>& b0, esimd::simd<int8_t, 256>& b1) SYCL_ESIMD_FUNCTION {
                        uint32_t offA = PK0 + (uint)(kb * 2048 + wi_row * 512);   // A straight from SLM: ZERO pack
                        uint32_t offB = BT + (uint)(buf * 2048 + wi_col * 512);
                        a0 = esimd::slm_block_load<int8_t, 256>(offA + 0, esimd::overaligned_tag<16>{});
                        a1 = esimd::slm_block_load<int8_t, 256>(offA + 256, esimd::overaligned_tag<16>{});
                        b0 = esimd::slm_block_load<int8_t, 256>(offB + 0, esimd::overaligned_tag<16>{});
                        b1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                    };
                    esimd::simd<int8_t, 256> a0, a1, b0, b1;
                    esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
                    load_block(0, 0);
                    group_barrier(gr);
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb) {
                        int cur = kb & 1, nxt = cur ^ 1;
                        if (kb + 1 < KBN) load_block(nxt, kb + 1);
                        load_grf(cur, kb, a0, a1, b0, b1);
                        c00 = esimd::xmx::dpas<8, 8, int32_t>(c00, b0, a0);
                        c01 = esimd::xmx::dpas<8, 8, int32_t>(c01, b1, a0);
                        c10 = esimd::xmx::dpas<8, 8, int32_t>(c10, b0, a1);
                        c11 = esimd::xmx::dpas<8, 8, int32_t>(c11, b1, a1);
                        group_barrier(gr);
                    }
                    // dequantise into the dead-operand stage (Z0, f32, VERBATIM b6/qres order)
                    int gc = part * 64 + wi_col * 16;
                    esimd::simd<float, 16> cs = esimd::block_load<float, 16>(bs + gc, esimd::overaligned_tag<16>{});
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        int tok0 = wi_row * 16 + r, tok1 = tok0 + 8;
                        float rs0 = esimd::slm_block_load<float, 1>(AS0 + (uint)tok0 * 4u)[0];
                        float rs1 = esimd::slm_block_load<float, 1>(AS0 + (uint)tok1 * 4u)[0];
                        esimd::simd<float, 16> f0, f1;
                        f0.template select<8, 1>(0) = esimd::convert<float>(c00.template select<8, 1>(r * 8).read()) * rs0;
                        f0.template select<8, 1>(8) = esimd::convert<float>(c01.template select<8, 1>(r * 8).read()) * rs0;
                        f1.template select<8, 1>(0) = esimd::convert<float>(c10.template select<8, 1>(r * 8).read()) * rs1;
                        f1.template select<8, 1>(8) = esimd::convert<float>(c11.template select<8, 1>(r * 8).read()) * rs1;
                        f0 = f0 * cs; f1 = f1 * cs;
                        esimd::slm_block_store<float, 16>(Z0 + (uint32_t)((tok0) * 64 + wi_col * 16) * 4u, f0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 16>(Z0 + (uint32_t)((tok1) * 64 + wi_col * 16) * 4u, f1, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    // the v5a tail: Q gets the learned scale, K is normalised, V is dequantised.
                    // The three faces are written in the CONSUMER's dpas-tile order (S30 R1).
                    int kind = part / PPH;                       // 0 = Q, 1 = K, 2 = V
                    #pragma unroll 1
                    for (int hp = 0; hp < 2; ++hp) {
                        uint head = (uint)((part % PPH) * 2 + hp);
                        sycl::half* dst = (kind == 0) ? faceQ : ((kind == 1) ? faceK : faceV);
                        size_t fb = (size_t)(w * HEADS + head) * facebase;
                        #pragma unroll
                        for (int k = 0; k < TOK / 16; ++k) {
                            uint row = (uint)(k * 16 + (int)lid);
                            esimd::simd<float, 32> seg = esimd::slm_block_load<float, 32>(
                                Z0 + (uint32_t)(row * 64 + hp * 32) * 4u, esimd::overaligned_tag<16>{});
                            esimd::simd<half, 32> oh;
                            if (kind == 2) {
                                oh = esimd::convert<half>(wbv3::e4m3_vec<32>(seg));
                            } else {
                                esimd::simd<float, 32> hr = esimd::convert<float>(esimd::convert<half>(seg));
                                float recip = wbv3::cosine_recip_vec(hr);
                                if (kind == 0) {
                                    float sc = wbmega::eh_round(qs[head]);
                                    esimd::simd<float, 32> t1 = wbv3::mulh(hr, recip);
                                    oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(t1, sc)));
                                } else {
                                    oh = esimd::convert<half>(wbv3::e4m3_vec<32>(wbv3::mulh(hr, recip)));
                                }
                            }
                            if constexpr (DUMP) {           // the shipped-plane order (the checkpoint)
                                unsigned r = w * TOK + row;
                                size_t pofs = (((size_t)(r / TOK) * HEADS + head) * TOK + (r % TOK)) * 32u;
                                sycl::half* T = (kind == 0) ? o.pQ : ((kind == 1) ? o.pK : o.pV);
                                oh.copy_to(T + pofs);
                            }
                            if (kind == 0) {                // Q: pack_a16_b blocks, 2 x 16 halfs
                                uint tr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                                uint e0 = ((tr * 2u + 0u) * 2u + strip) * 128u + il * 16u;
                                uint e1 = ((tr * 2u + 1u) * 2u + strip) * 128u + il * 16u;
                                esimd::simd<half, 16> qa0 = oh.template select<16, 1>(0);
                                esimd::simd<half, 16> qa1 = oh.template select<16, 1>(16);
                                esimd::block_store<half, 16>(dst + fb + e0, qa0, esimd::overaligned_tag<16>{});
                                esimd::block_store<half, 16>(dst + fb + e1, qa1, esimd::overaligned_tag<16>{});
                            } else {                        // K / V: stage the row, then retiling
                                esimd::slm_block_store<half, 32>(ROWS + row * 64u, oh,
                                    esimd::overaligned_tag<16>{});
                            }
                        }
                        if (kind != 0) {
                            group_barrier(gr);
                            uint bidx = lid;
                            if (kind == 1) {                 // pack_b16_t_b INTERLEAVED map (b6 VERBATIM)
                                uint kc2 = bidx / 8u, tc2 = (bidx / 2u) % 4u, js = bidx % 2u;
                                esimd::simd<half, 128> blk;
                                #pragma unroll
                                for (int jl = 0; jl < 8; ++jl) {
                                    uint r = tc2 * 16u + js * 8u + (uint)jl;
                                    esimd::simd<half, 16> vr = esimd::slm_block_load<half, 16>(
                                        ROWS + r * 64u + kc2 * 32u, esimd::overaligned_tag<16>{});
                                    #pragma unroll
                                    for (int kq = 0; kq < 8; ++kq)
                                        blk.template select<2, 1>(kq * 16 + jl * 2) = vr.template select<2, 1>(kq * 2);
                                }
                                esimd::block_store<half, 128>(dst + fb + bidx * 128u, blk, esimd::overaligned_tag<16>{});
                            } else {                         // pack_b16_b map (b6 VERBATIM)
                                uint kc2 = bidx / 4u, tc2 = (bidx / 2u) % 2u, js = bidx % 2u;
                                esimd::simd<half, 128> blk;
                                #pragma unroll
                                for (int kq = 0; kq < 8; ++kq) {
                                    esimd::simd<half, 8> a = esimd::slm_block_load<half, 8>(
                                        ROWS + (kc2 * 16u + kq * 2u) * 64u + tc2 * 32u + js * 16u, esimd::overaligned_tag<16>{});
                                    esimd::simd<half, 8> bv = esimd::slm_block_load<half, 8>(
                                        ROWS + (kc2 * 16u + kq * 2u + 1u) * 64u + tc2 * 32u + js * 16u, esimd::overaligned_tag<16>{});
                                    blk.template select<8, 2>(kq * 16 + 0) = a;
                                    blk.template select<8, 2>(kq * 16 + 1) = bv;
                                }
                                esimd::block_store<half, 128>(dst + fb + bidx * 128u, blk, esimd::overaligned_tag<16>{});
                            }
                            group_barrier(gr);
                        }
                    }
                    group_barrier(gr);
                }
            }

            // ================= P9 = WINDOW_ATTENTION (faces from GLOBAL, zero pack) =========
            if constexpr (PHASES >= 3) {
                #pragma unroll 1
                for (uint hh = 0; hh < HEADS; ++hh) {
                    const size_t fbQ = (size_t)(w * HEADS + hh) * facebase;
                    const size_t fbK = fbQ, fbV = fbQ;
                    // stage 1: scores = Q @ K^T (dpas<8,8,float>, operands loaded STRAIGHT from
                    // the global fragment faces -- the S30 form; b6 staged these in 24KB of SLM)
                    esimd::simd<float, 64> c00(0.f), c01(0.f), c10(0.f), c11(0.f);
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half, 128> qa0 = esimd::block_load<half, 128>(faceQ + fbQ + (uint)((wi_row * 2u + kc) * 256u), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> qa1 = esimd::block_load<half, 128>(faceQ + fbQ + (uint)((wi_row * 2u + kc) * 256u) + 128u, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> ka0 = esimd::block_load<half, 128>(faceK + fbK + (uint)((kc * 4u + wi_col) * 256u), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> ka1 = esimd::block_load<half, 128>(faceK + fbK + (uint)((kc * 4u + wi_col) * 256u) + 128u, esimd::overaligned_tag<16>{});
                        c00 = esimd::xmx::dpas<8, 8, float>(c00, ka0, qa0);
                        c01 = esimd::xmx::dpas<8, 8, float>(c01, ka1, qa0);
                        c10 = esimd::xmx::dpas<8, 8, float>(c10, ka0, qa1);
                        c11 = esimd::xmx::dpas<8, 8, float>(c11, ka1, qa1);
                    }
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + r) * 64 + wi_col * 16)) * 4u,
                            c00.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + r) * 64 + wi_col * 16 + 8)) * 4u,
                            c01.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + 8 + r) * 64 + wi_col * 16)) * 4u,
                            c10.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store<float, 8>(Z0 + (uint32_t)(((wi_row * 16 + 8 + r) * 64 + wi_col * 16 + 8)) * 4u,
                            c11.template select<8, 1>(r * 8), esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    if constexpr (DUMP) {   // the scores f32 tile (the split chain's dScores twin)
                        #pragma unroll
                        for (int rr = 0; rr < 4; ++rr) {
                            uint row = lid * 4u + rr;
                            size_t sb = ((size_t)(w * HEADS + hh) * TOK + row) * 64u;
                            #pragma unroll
                            for (int cc = 0; cc < 2; ++cc)
                                esimd::block_store<float, 32>(o.scores + sb + (size_t)cc * 32u,
                                    esimd::slm_block_load<float, 32>(Z0 + row * 256u + (uint)cc * 128u, esimd::overaligned_tag<16>{}),
                                    esimd::overaligned_tag<16>{});
                        }
                        group_barrier(gr);
                    }
                    // stage 2: softmax, 4 rows/thread -- the b6/wa_res chain VERBATIM (bias, the
                    // f16 roundings, the exp bit-hack, the SEQUENTIAL row total, eh_round,
                    // eh_round(ef_div(1,trh)) -- NO rcp anywhere; 1/sum rounding is preserved).
                    #pragma unroll
                    for (int rr = 0; rr < 4; ++rr) {
                        uint row = lid * 4u + rr;
                        esimd::simd<float, 32> s0 = esimd::slm_block_load<float, 32>(Z0 + row * 256u, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> s1 = esimd::slm_block_load<float, 32>(Z0 + row * 256u + 128u, esimd::overaligned_tag<16>{});
                        size_t boff = (size_t)hh * 4096u + (size_t)row * 64u;
                        esimd::simd<float, 32> b0v = esimd::block_load<float, 32>(dBias + boff, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> b1v = esimd::block_load<float, 32>(dBias + boff + 32, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 32> hl0 = esimd::convert<float>(esimd::convert<sycl::half>(s0 + b0v));
                        esimd::simd<float, 32> hl1 = esimd::convert<float>(esimd::convert<sycl::half>(s1 + b1v));
                        esimd::simd<float, 32> a0v = esimd::convert<float>(esimd::convert<sycl::half>(
                            hl0 * esimd::simd<float, 32>(0.044921875f) + esimd::simd<float, 32>(1.30078125f)));
                        esimd::simd<float, 32> a1v = esimd::convert<float>(esimd::convert<sycl::half>(
                            hl1 * esimd::simd<float, 32>(0.044921875f) + esimd::simd<float, 32>(1.30078125f)));
                        a0v = (esimd::min)((esimd::max)(a0v, esimd::simd<float, 32>(1.03125f)), esimd::simd<float, 32>(1.5693359375f));
                        a1v = (esimd::min)((esimd::max)(a1v, esimd::simd<float, 32>(1.03125f)), esimd::simd<float, 32>(1.5693359375f));
                        esimd::simd<sycl::half, 16> he0 = esimd::convert<sycl::half>(a0v.template select<16, 2>(0).read());
                        esimd::simd<sycl::half, 16> ho0 = esimd::convert<sycl::half>(a0v.template select<16, 2>(1).read());
                        esimd::simd<sycl::half, 16> he1 = esimd::convert<sycl::half>(a1v.template select<16, 2>(0).read());
                        esimd::simd<sycl::half, 16> ho1 = esimd::convert<sycl::half>(a1v.template select<16, 2>(1).read());
                        esimd::simd<uint16_t, 16> e0 = he0.bit_cast_view<uint16_t>(), o0 = ho0.bit_cast_view<uint16_t>();
                        esimd::simd<uint16_t, 16> e1 = he1.bit_cast_view<uint16_t>(), o1 = ho1.bit_cast_view<uint16_t>();
                        esimd::simd<uint32_t, 16> p0 = esimd::convert<uint32_t>(e0) | (esimd::convert<uint32_t>(o0) << 16);
                        esimd::simd<uint32_t, 16> p1 = esimd::convert<uint32_t>(e1) | (esimd::convert<uint32_t>(o1) << 16);
                        esimd::simd<uint32_t, 16> t0 = (p0 << 5) + esimd::simd<uint32_t, 16>(0x7FF88000u);
                        esimd::simd<uint32_t, 16> t1 = (p1 << 5) + esimd::simd<uint32_t, 16>(0x7FF88000u);
                        esimd::simd<sycl::half, 32> w0; w0 = t0.bit_cast_view<sycl::half>();
                        esimd::simd<sycl::half, 32> w1; w1 = t1.bit_cast_view<sycl::half>();
                        esimd::simd<float, 32> f0 = esimd::convert<float>(w0);
                        esimd::simd<float, 32> f1 = esimd::convert<float>(w1);
                        float total = 0.0f;
                        for (unsigned cc = 0; cc < 32u; ++cc) total += f0[cc];
                        for (unsigned cc = 0; cc < 32u; ++cc) total += f1[cc];
                        float trh = wbmega::eh_round(total);
                        float recip = wbmega::eh_round(wbv2::ef_div(1.0f, trh));
                        esimd::simd<sycl::half, 32> oh0 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w0), recip)));
                        esimd::simd<sycl::half, 32> oh1 = esimd::convert<sycl::half>(wbv2::e4m3_vec<32>(wbv2::mulh(esimd::convert<float>(w1), recip)));
                        if constexpr (LIVE) {        // the liveness witness: probs *= 0.5 (S34 trick)
                            oh0 = oh0 * esimd::simd<sycl::half, 32>(sycl::half(0.5f));
                            oh1 = oh1 * esimd::simd<sycl::half, 32>(sycl::half(0.5f));
                        }
                        uint trr = row / 16u, strip = (row % 16u) / 8u, il = row % 8u;
                        uint ybase = PROB + ((trr * 4u + 0u) * 2u + strip) * 256u + il * 32u;
                        esimd::simd<half, 16> q0 = oh0.template select<16, 1>(0);
                        esimd::simd<half, 16> q1 = oh0.template select<16, 1>(16);
                        esimd::simd<half, 16> q2 = oh1.template select<16, 1>(0);
                        esimd::simd<half, 16> q3 = oh1.template select<16, 1>(16);
                        esimd::slm_block_store(ybase, q0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 512u, q1, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 1024u, q2, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ybase + 1536u, q3, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                    if constexpr (DUMP) {   // probs, in the pack_a16 map (compare vs pack_a16_b(ref))
                        #pragma unroll
                        for (int p = 0; p < 2; ++p) {
                            uint off = (uint)((p * 16u + lid) * 128u);
                            esimd::block_store<half, 128>(o.probs + (size_t)(w * HEADS + hh) * 4096u + off,
                                esimd::slm_block_load<half, 128>(PROB + off * 2u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                        }
                        group_barrier(gr);
                    }
                    // stage 3: attnV = probs @ V (A from SLM probs, B STRAIGHT from the global
                    // V face; the b6 merge-fold store becomes the ATT band in SLM instead)
                    int t8 = (int)lid % 8;
                    int tr2 = t8 / 2, tc2 = t8 % 2;
                    esimd::simd<float, 64> d00(0.f), d01(0.f), d10(0.f), d11(0.f);
                    #pragma unroll
                    for (int kb = 0; kb < 4; ++kb) {
                        uint32_t offA = PROB + (uint32_t)(((size_t)tr2 * 4u + (size_t)kb) * 2u) * 256u;
                        esimd::simd<half, 128> pa0 = esimd::slm_block_load<half, 128>(offA, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> pa1 = esimd::slm_block_load<half, 128>(offA + 256, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> vb0 = esimd::block_load<half, 128>(faceV + fbV + (uint)(kb * 512 + tc2 * 256), esimd::overaligned_tag<16>{});
                        esimd::simd<half, 128> vb1 = esimd::block_load<half, 128>(faceV + fbV + (uint)(kb * 512 + tc2 * 256) + 128u, esimd::overaligned_tag<16>{});
                        d00 = esimd::xmx::dpas<8, 8, float>(d00, vb0, pa0);
                        d01 = esimd::xmx::dpas<8, 8, float>(d01, vb1, pa0);
                        d10 = esimd::xmx::dpas<8, 8, float>(d10, vb0, pa1);
                        d11 = esimd::xmx::dpas<8, 8, float>(d11, vb1, pa1);
                    }
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        esimd::simd<float, 8> r00 = d00.template select<8, 1>(r * 8), r01 = d01.template select<8, 1>(r * 8);
                        esimd::simd<float, 8> r10 = d10.template select<8, 1>(r * 8), r11 = d11.template select<8, 1>(r * 8);
                        esimd::simd<half, 8> h00 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r00));
                        esimd::simd<half, 8> h01 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r01));
                        esimd::simd<half, 8> h10 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r10));
                        esimd::simd<half, 8> h11 = esimd::convert<half>(s8v8::e4m3_vec_v8<8>(r11));
                        esimd::simd<half, 16> j0; j0.template select<8, 1>(0) = h00; j0.template select<8, 1>(8) = h01;
                        esimd::simd<half, 16> j1; j1.template select<8, 1>(0) = h10; j1.template select<8, 1>(8) = h11;
                        uint row0 = tr2 * 16u + (uint)r, row1 = row0 + 8u;
                        esimd::slm_block_store(ATT + hh * 4096u + (row0 * 32u + (unsigned)tc2 * 16u) * 2u, j0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(ATT + hh * 4096u + (row1 * 32u + (unsigned)tc2 * 16u) * 2u, j1, esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                }
                if constexpr (DUMP) {   // ATT = the 1277 row the quant should see (b6 outlet form)
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        uint row = (uint)(t * 16 + (int)lid);
                        #pragma unroll
                        for (uint hh = 0; hh < HEADS; ++hh)
                            esimd::block_store<half, 32>(o.att + ((size_t)w * TOK + row) * 32u
                                    + (size_t)hh * ((size_t)windows * TOK * 32u),
                                esimd::slm_block_load<half, 32>(ATT + hh * 4096u + (row * 32u) * 2u, esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                    }
                    group_barrier(gr);
                }
            }

            // ================= P10 = QUANT (att -> pk2 + sc2 in SLM; b6 3b VERBATIM) ========
            if constexpr (PHASES >= 4) {
                #pragma unroll
                for (int t = 0; t < TOK / 16; ++t) {
                    uint row = (uint)(t * 16 + (int)lid);
                    esimd::simd<float, C> v;
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)
                        v.template select<32, 1>(kb * 32) = esimd::convert<float>(
                            // bytes: one head's att tile = 64 rows x 32 halfs = 4096 B
                            esimd::slm_block_load<half, 32>(ATT + (uint)(kb * 4096 + (int)row * 64), esimd::overaligned_tag<16>{}));
                    float peak = esimd::hmax<float, float, C>(esimd::abs(v));
                    const float scale = (peak == 0.0f) ? 1.0f
                        : esimd::div_ieee<float, 1>(esimd::simd<float, 1>(peak), esimd::simd<float, 1>(127.0f))[0];
                    esimd::simd<float, C> qq = esimd::div_ieee<float, C>(v, esimd::simd<float, C>(scale));
                    qq = esimd::min(esimd::max(esimd::rnde<float, C>(qq), esimd::simd<float, C>(-127.f)), esimd::simd<float, C>(127.f));
                    esimd::simd<int8_t, C> qi = esimd::convert<int8_t>(esimd::convert<int>(qq));
                    #pragma unroll
                    for (int kb = 0; kb < KBN; ++kb)
                        esimd::slm_block_store<int8_t, 32>(PKT + (uint)(kb * 2048 + (int)row * 32),
                            qi.template select<32, 1>(kb * 32), esimd::overaligned_tag<16>{});
                    esimd::slm_block_store<float, 1>(AS2 + row * 4u, esimd::simd<float, 1>(scale));
                }
                group_barrier(gr);
                if constexpr (DUMP) {   // pk2 row-major + sc2 (the 1272/1273 twin of this window)
                    #pragma unroll
                    for (int t = 0; t < TOK / 16; ++t) {
                        uint row = (uint)(t * 16 + (int)lid);
                        #pragma unroll
                        for (int kb = 0; kb < KBN; ++kb)
                            esimd::block_store<int8_t, 32>(o.pkt + ((size_t)w * TOK + row) * C + kb * 32,
                                esimd::slm_block_load<int8_t, 32>(PKT + (uint)(kb * 2048 + (int)row * 32), esimd::overaligned_tag<16>{}),
                                esimd::overaligned_tag<16>{});
                        esimd::block_store<float, 1>(o.as2 + (size_t)w * TOK + row,
                            esimd::slm_block_load<float, 1>(AS2 + row * 4u));
                    }
                    group_barrier(gr);
                }
            }

            // ================= P11 = GEMM_WINDOW_INT8_RESIDUAL (pk2 x W79 + skip -> 1270) ===
            if constexpr (PHASES >= 5) {
                const int rb = (int)(lid / 2u), cb = (int)(lid % 2u);
                #pragma unroll 1
                for (int nt = 0; nt < C / 64; ++nt) {          // N tiles (C=64 -> 1)
                    const int8_t* bp3 = dOp + (size_t)nt * 2048u;
                    auto load_block3 = [=](int buf, int kb) SYCL_ESIMD_FUNCTION {
                        esimd::simd<int8_t, 128> bv = esimd::block_load<int8_t, 128>(
                            bp3 + (size_t)kb * (C * 32u) + lid * 128u, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(BT + (uint)(buf * 2048 + (int)lid * 128), bv, esimd::overaligned_tag<16>{});
                    };
                    esimd::simd<int32_t, 64> q0(0), q1(0), q2(0), q3(0);
                    load_block3(0, 0);
                    group_barrier(gr);
                    #pragma unroll
                    for (int kbi = 0; kbi < KBN; ++kbi) {
                        int cur = kbi & 1, nxt = cur ^ 1;
                        if (kbi + 1 < KBN) load_block3(nxt, kbi + 1);
                        esimd::simd<int8_t, 256> pa0 = esimd::slm_block_load<int8_t, 256>(
                            PKT + (uint32_t)(rb * 256 + kbi * 2048), esimd::overaligned_tag<16>{});
                        uint32_t offB = (uint32_t)(cur * 2048 + cb * 1024);
                        esimd::simd<int8_t, 256> bb0 = esimd::slm_block_load<int8_t, 256>(offB, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb1 = esimd::slm_block_load<int8_t, 256>(offB + 256, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb2 = esimd::slm_block_load<int8_t, 256>(offB + 512, esimd::overaligned_tag<16>{});
                        esimd::simd<int8_t, 256> bb3 = esimd::slm_block_load<int8_t, 256>(offB + 768, esimd::overaligned_tag<16>{});
                        q0 = esimd::xmx::dpas<8, 8, int32_t>(q0, bb0, pa0);
                        q1 = esimd::xmx::dpas<8, 8, int32_t>(q1, bb1, pa0);
                        q2 = esimd::xmx::dpas<8, 8, int32_t>(q2, bb2, pa0);
                        q3 = esimd::xmx::dpas<8, 8, int32_t>(q3, bb3, pa0);
                        group_barrier(gr);
                    }
                    // the wres fold, gemm_b_res_window epilogue VERBATIM (b6 3d)
                    int gc0 = nt * 64 + (int)(cb * 32u);
                    esimd::simd<float, 16> csl = esimd::block_load<float, 16>(bs2 + gc0, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> csh = esimd::block_load<float, 16>(bs2 + gc0 + 16, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> ccl = esimd::block_load<float, 16>(cosv + gc0, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 16> cc2 = esimd::block_load<float, 16>(cosv + gc0 + 16, esimd::overaligned_tag<16>{});
                    esimd::simd<float, 8> csl0 = csl.template select<8, 1>(0), csl1 = csl.template select<8, 1>(8);
                    esimd::simd<float, 8> csh0 = csh.template select<8, 1>(0), csh1 = csh.template select<8, 1>(8);
                    esimd::simd<float, 8> ccl0 = ccl.template select<8, 1>(0), ccl1 = ccl.template select<8, 1>(8);
                    esimd::simd<float, 8> cc20 = cc2.template select<8, 1>(0), cc21 = cc2.template select<8, 1>(8);
                    #pragma unroll 1
                    for (int r = 0; r < 8; ++r) {
                        uint token = (uint)(rb * 8 + r);
                        unsigned yy = (w / across) * 8u + token / 8u, xx = (w % across) * 8u + token % 8u;
                        bool in = (yy >= top && xx >= left && yy - top < image_h && xx - left < image_w);
                        if (!in) continue;
                        size_t out = ((size_t)(yy - top) * image_w + (size_t)(xx - left)) * C + (size_t)gc0;
                        float rs = esimd::slm_block_load<float, 1>(AS2 + token * 4u)[0];
                        esimd::simd<float, 8> f0 = esimd::convert<float>(q0.template select<8, 1>(r * 8).read()) * rs * csl0;
                        esimd::simd<float, 8> f1 = esimd::convert<float>(q1.template select<8, 1>(r * 8).read()) * rs * csl1;
                        esimd::simd<float, 8> f2 = esimd::convert<float>(q2.template select<8, 1>(r * 8).read()) * rs * csh0;
                        esimd::simd<float, 8> f3 = esimd::convert<float>(q3.template select<8, 1>(r * 8).read()) * rs * csh1;
                        esimd::simd<half, 16> sha = esimd::block_load<half, 16>(dImg + out, esimd::overaligned_tag<16>{});
                        esimd::simd<half, 16> shb = esimd::block_load<half, 16>(dImg + out + 16u, esimd::overaligned_tag<16>{});
                        esimd::simd<float, 8> sk0 = esimd::convert<float>(sha.template select<8, 1>(0).read());
                        esimd::simd<float, 8> sk1 = esimd::convert<float>(sha.template select<8, 1>(8).read());
                        esimd::simd<float, 8> sk2 = esimd::convert<float>(shb.template select<8, 1>(0).read());
                        esimd::simd<float, 8> sk3 = esimd::convert<float>(shb.template select<8, 1>(8).read());
                        esimd::simd<float, 16> pubA, pubB;
                        {
                            esimd::simd<float, 8> t0, t1;
                            for (int e = 0; e < 8; ++e) { t0[e] = sk0[e] * ccl0[e] + f0.read()[e]; t1[e] = sk1[e] * ccl1[e] + f1.read()[e]; }
                            pubA.template select<8, 1>(0) = s8v8::pub_vec_v8<8>(1u, t0);
                            pubA.template select<8, 1>(8) = s8v8::pub_vec_v8<8>(1u, t1);
                            esimd::simd<float, 8> t2, t3;
                            for (int e = 0; e < 8; ++e) { t2[e] = sk2[e] * cc20[e] + f2.read()[e]; t3[e] = sk3[e] * cc21[e] + f3.read()[e]; }
                            pubB.template select<8, 1>(0) = s8v8::pub_vec_v8<8>(1u, t2);
                            pubB.template select<8, 1>(8) = s8v8::pub_vec_v8<8>(1u, t3);
                        }
                        esimd::convert<half>(pubA).copy_to(Out2 + out);
                        esimd::convert<half>(pubB).copy_to(Out2 + out + 16u);
                    }
                    if (nt + 1 < C / 64) group_barrier(gr);
                }
            }
        });
    });
}

struct Spec { int slmb, x0, z0, y0; };
template <int C, int HEADS> static Spec spec() {
    constexpr int KBN = C / 32;
    constexpr uint X0SZ = (HEADS * 4096u > 8192u) ? (HEADS * 4096u) : 8192u;
    constexpr uint Y0SZ = (KBN * 2048u + 256u > 8192u) ? (KBN * 2048u + 512u) : 8192u;
    return Spec{(int)(X0SZ + 16384u + Y0SZ), (int)X0SZ, 16384, (int)Y0SZ};
}

} // namespace att5
