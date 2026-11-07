// softmax_kernel.hpp — the vendor's half bit-affine softmax (section 9 island-1), the
// SYCL translation of nr_model.vendor_approximate_softmax (:211) and the bit-pair
// transform in window_attention.comp:54-62.
//
// Bit-exact contract (the golden is authority, already shipped):
//   affine = half_round(value) * 0.044921875 + 1.30078125, clamped to
//            [1.03125, 1.5693359375] (both bounds exact in half, so clamp-before-round
//            == clamp-after-round), rounded to half;
//   the coupled half-pair transform: pack two adjacent f16 into one u32,
//            transformed = (packed << 5) + 0x7FF88000, split back to two f16 weights;
//   totals = the row sum accumulated SEQUENTIALLY in float32, rounded once at the end
//            (the golden's comment :236-238 is explicit: numpy runs it sequentially and
//            rounds once -- a tree/butterfly reduce would give a different answer);
//   reciprocal = half_round(1.0f / (float)totals);
//   out = e4m3(half_round((float)weight * (float)reciprocal)).
//
// One work-item per row (the senior's RMSNorm/Softmax champion shape, skill pack
// techniques.md:113/259). `cols` is the token count (the softmax axis). The row's weights
// live in a local array because the sum pass and the normalise pass both need them --
// at cols<=128 that is 256 B; spilling is a perf concern for the S-series, not a
// correctness one (this is a bit-exact numeric gate).
#pragma once
#include <sycl/sycl.hpp>
#include <cstdlib>                 // NR_SMAX_FORM / NR_SMAX_TRACE (getenv/atoi)
#include <cstdio>                  // the [smaxform] routing trace
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"   // cr_hadd, cr_hmul (the half-domain add/mul)   // qr_half_round, cr_mul, cr_add, qr_e4m3, qr_e4m3_scalar

namespace smax {
// #146 (layer-2 family #1, 2026-11-06): local correctly-rounded shadows + contraction off for this
// region only. L1SMAX marks the site for the ledger.
#pragma clang fp contract(off)
static inline float cr_mul(float a, float b) { return a * b; }
static inline float cr_add(float a, float b) { return a + b; }
static inline float cr_div(float a, float b) { return a / b; }

// NR_SMAX_FORM (layer1 SS53, certified 2026-11-07): the multi-row form of vit_softmax_tiled -- a ROW
// SLICE OF 32 LANES (two sub-groups at the instance's measured simd=16) instead of one work-item per
// row, 8 rows per work-group, the four pair-partials staged in local memory and folded by the row's
// lane 0 in the shipped LEFT-ASSOCIATIVE order. Bench: DIFFARM Ap 0/1,179,648 and recip 0/6,144 (byte
// identical), ratio 2.948 (48/48 paired samples >= 2.0), work-groups 6,144 -> 768, grf 128 / simd 16 /
// barrier 1 / scratch 0 / SLM 1,024 B (measured by the launch-time probe, layer1 SS53d).
// Default ON; NR_SMAX_FORM=0 escapes to the shipped one-item-per-row form.
static inline bool smax_form_on() {
    static bool v = !getenv("NR_SMAX_FORM") || atoi(getenv("NR_SMAX_FORM")) != 0;
    return v;
}
// The form's shape contract: blocks tile tokens by 64 (so every lane owns exactly one shipped
// pair-slot), work-groups tile rows by 8 (so no group is half-inactive), and the A-tile map needs
// stride % 16 == 0 (the shipped recorder already requires it). Anything else stays on the old form.
static inline bool smax_form_ok(unsigned nrows, unsigned tokens, unsigned stride) {
    return (tokens % 64u) == 0u && (nrows % 8u) == 0u && (stride % 16u) == 0u && stride >= tokens;
}
// routing table for the gates: NR_SMAX_TRACE=1 prints which shape took which form (bounded).
static inline void smax_form_trace(unsigned nrows, unsigned tokens, unsigned stride, bool taken) {
    static int n = 0;
    if (!getenv("NR_SMAX_TRACE") || n >= 64) return;
    ++n;
    printf("[smaxform] nrows=%u tokens=%u stride=%u -> %s\n",
           nrows, tokens, stride, taken ? "NEW multirow" : "OLD one-item");
}

static const float SOFT_SCALE     = 0.044921875f;
static const float SOFT_BIAS      = 1.30078125f;
static const float SOFT_LO        = 1.03125f;
static const float SOFT_HI        = 1.5693359375f;
static const uint32_t SOFT_MAGIC  = 0x7FF88000u;

inline auto softmax_kernel() {
    return [](const float* src, sycl::half* dst, unsigned rows, unsigned cols,
              const float* bias, unsigned heads) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            const float* row = src + (size_t)r * cols;
            sycl::half* outr = dst + (size_t)r * cols;
            // bias (attention.comp:223 `prepared`: logit += pc.b.v[bias_index] BEFORE the
            // half_round of the bit-affine; flags 0x2000 selects it, p0 clamp unused here).
            // bias_offset (attention.comp:240): scores (windows*heads, n, n), bias
            // (heads, n, n): ((row/n) % heads)*n*n + (row%n)*n.
            size_t boff = bias ? ((size_t)((r / cols) % (heads ? heads : 1u)) * cols * cols
                                  + (size_t)(r % cols) * cols) : 0;
            // affine + bit-pair transform -> weights (kept as f16 for the two passes).
            // cols is even (golden :215 requires it); process pairs like the shipped kernel.
            float total = 0.0f;
            for (unsigned c = 0; c < cols; c += 2u) {
                // golden :216-220: half_round(value) then *= scale then += bias, ALL in
                // f32 with NO intermediate half-round; the single round to half is the
                // final astype (the bit-pack below). clamp is f32 (bounds exact in half).
                float l0 = bias ? row[c] + bias[boff + c] : row[c];
                float l1 = bias ? row[c + 1] + bias[boff + c + 1] : row[c + 1];
                float a0 = cr_add(cr_mul(qr_half_round(l0),     SOFT_SCALE), SOFT_BIAS);
                float a1 = cr_add(cr_mul(qr_half_round(l1),     SOFT_SCALE), SOFT_BIAS);
                a0 = sycl::min(sycl::max(a0, SOFT_LO), SOFT_HI);
                a1 = sycl::min(sycl::max(a1, SOFT_LO), SOFT_HI);
                uint16_t b0 = sycl::bit_cast<uint16_t>(sycl::half(a0));   // the one f16 round
                uint16_t b1 = sycl::bit_cast<uint16_t>(sycl::half(a1));
                uint32_t packed = (uint32_t)b0 | ((uint32_t)b1 << 16);
                uint32_t tr = (packed << 5) + SOFT_MAGIC;
                uint16_t w0 = (uint16_t)(tr & 0xFFFFu), w1 = (uint16_t)((tr >> 16) & 0xFFFFu);
                sycl::half h0 = sycl::bit_cast<sycl::half>(w0), h1 = sycl::bit_cast<sycl::half>(w1);
                // golden :234-236 is EXPLICIT: sum(dtype=float16) does NOT accumulate in
                // half -- numpy runs it sequentially in FLOAT32 and rounds ONCE at the end.
                // (That is why it is reproducible at all; a per-step f16 accumulator would
                // drift and would not match the shipped kernels.)
                total += (float)h0;
                total += (float)h1;
                outr[c] = h0; outr[c + 1] = h1;
            }
            // totals rounded to half (the astype(f16) of the sum), then the reciprocal is
            // a plain IEEE f32 divide + one round to half (golden :237-239).
            float trh = (float)sycl::half(total);
            float recip = (float)sycl::half(cr_div(1.0f, trh));
            for (unsigned c = 0; c < cols; ++c) {
                float w = (float)outr[c];
                outr[c] = sycl::half(qr_e4m3(qr_half_round(cr_mul(w, recip))));
            }
        };
    };
}

// route-B block 2 (section 38/39): the scores seam's softmax, int8 all the way out.
// Input = the int32 accumulator of Q.K^T (the v1 GEMM's C), per-row q_scale, per-column
// (key) k_scale, and the attention bias -- the dequantise (island-3, cr_mul left-to-right
// like the shipped store path) and the bias add (the senior's f32 tile add,
// window_attention.comp:94-103) happen at island-1's entrance, then the SAME affine +
// bit-pair + sequential-sum + reciprocal chain as the gated softmax kernel above (line
// by line identical), then instead of the e4m3 container: x = half_round(w*recip) (the
// golden's pre-e4m3 value, exact in f16 -- scratch re-used), rmax over the row from
// REGISTERS (free), and v3's requantize contract (inv=127/rmax, rint, clip +-127,
// scale=rmax/127) -> int8 probs + row scale straight into the attnV rq GEMM. The e4m3
// publish + the quantize_row before attnV both die at this seam.
inline auto softmax_i8_kernel() {
    return [](const int32_t* acc, const float* qs, const float* ks, const float* bias,
              sycl::half* scratch, signed char* out8, float* scale,
              unsigned rows, unsigned cols) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            const int32_t* arow = acc + (size_t)r * cols;
            const float* brow = bias + (size_t)r * cols;
            sycl::half* wrow = scratch + (size_t)r * cols;
            float qsr = qs[r];
            float total = 0.0f;
            for (unsigned c = 0; c < cols; c += 2u) {
                float l0 = cr_add(cr_mul(cr_mul((float)arow[c], qsr), ks[c]), brow[c]);
                float l1 = cr_add(cr_mul(cr_mul((float)arow[c + 1u], qsr), ks[c + 1u]), brow[c + 1u]);
                float a0 = cr_add(cr_mul(qr_half_round(l0), SOFT_SCALE), SOFT_BIAS);
                float a1 = cr_add(cr_mul(qr_half_round(l1), SOFT_SCALE), SOFT_BIAS);
                a0 = sycl::min(sycl::max(a0, SOFT_LO), SOFT_HI);
                a1 = sycl::min(sycl::max(a1, SOFT_LO), SOFT_HI);
                uint16_t b0 = sycl::bit_cast<uint16_t>(sycl::half(a0));
                uint16_t b1 = sycl::bit_cast<uint16_t>(sycl::half(a1));
                uint32_t packed = (uint32_t)b0 | ((uint32_t)b1 << 16);
                uint32_t tr = (packed << 5) + SOFT_MAGIC;
                sycl::half h0 = sycl::bit_cast<sycl::half>((uint16_t)(tr & 0xFFFFu));
                sycl::half h1 = sycl::bit_cast<sycl::half>((uint16_t)((tr >> 16) & 0xFFFFu));
                total += (float)h0;
                total += (float)h1;
                wrow[c] = h0; wrow[c + 1u] = h1;
            }
            float trh = (float)sycl::half(total);
            float recip = (float)sycl::half(cr_div(1.0f, trh));
            float rmax = 0.0f;
            for (unsigned c = 0; c < cols; ++c) {
                float x = qr_half_round(cr_mul((float)wrow[c], recip));
                wrow[c] = sycl::half(x);
                float aa = x < 0.0f ? -x : x;
                if (aa > rmax) rmax = aa;
            }
            float ns = rmax / 127.0f;
            float inv = (rmax > 0.0f) ? 127.0f / rmax : 0.0f;
            signed char* orow = out8 + (size_t)r * cols;
            for (unsigned c = 0; c < cols; ++c) {
                float x = (float)wrow[c];
                float q = sycl::min(sycl::max(sycl::rint(x * inv), -127.0f), 127.0f);
                orow[c] = (signed char)(int)q;
            }
            scale[r] = ns;
        };
    };
}

// vit_weight (attention.comp:297-302 / global_attention.comp:82-87): the ViT's
// exponential, its OWN affine (0.08953857421875 / 1.708984375, clamp [1.439453125,
// 1.9775390625]) and a 4-bit shift where the window blocks' is 5. Transcribed verbatim.
static inline float vit_weight(float logit) {
    float affine = cr_add(cr_mul(qr_half_round(logit), 0.08953857421875f), 1.708984375f);
    affine = qr_half_round(affine);
    affine = sycl::min(sycl::max(affine, 1.439453125f), 1.9775390625f);
    uint16_t bits = sycl::bit_cast<uint16_t>(sycl::half(affine));
    uint16_t shifted = (uint16_t)((((uint32_t)bits << 4) + 0x4000u) & 0xFFFFu);
    return (float)sycl::bit_cast<sycl::half>(shifted);
}

// vit_softmax_kernel (attention.comp:221-241 `vit_softmax`, one work-item per row):
//   blocks = ceil(tokens/64); zero = vit_weight(0);
//   per block: column[c] (c 0..7) = hadd-tree over pair[j] (j 0..3), pair[j] =
//     hadd(w0,w1) with k0=b*64+c+16j, k1=k0+8, w = k<tokens ? vit_weight(a[base+k]) : zero;
//   total = hadd(total, hadd(even,odd)) with even=hadd(hadd(hadd(c0,c2),c4),c6),
//     odd=hadd(hadd(hadd(c1,c3),c5),c7);
//   padding = blocks*64 - tokens; if padding>0 total = hadd(total, -hmul(zero,padding));
//   reciprocal[row] = half_round(1.0/total);
//   store(base+k) = k<tokens ? e4m3(vit_weight(a[base+k])) : 0.0   (narrow: half out).
inline auto vit_softmax_kernel() {
    return [](const float* src, sycl::half* dst, float* recip, unsigned rows,
              unsigned tokens, unsigned stride) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            const float* row = src + (size_t)r * stride;
            unsigned blocks = (tokens + 63u) / 64u;
            float zero = vit_weight(0.0f), total = 0.0f;
            for (unsigned b = 0; b < blocks; ++b) {
                float column[8];
                for (unsigned c = 0; c < 8u; ++c) {
                    float pair[4];
                    for (unsigned j = 0; j < 4u; ++j) {
                        unsigned k0 = b * 64u + c + 16u * j, k1 = k0 + 8u;
                        float w0 = k0 < tokens ? vit_weight(row[k0]) : zero;
                        float w1 = k1 < tokens ? vit_weight(row[k1]) : zero;
                        pair[j] = ctree::cr_hadd(w0, w1);
                    }
                    column[c] = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(pair[0], pair[1]), pair[2]), pair[3]);
                }
                float even = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[0], column[2]), column[4]), column[6]);
                float odd  = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[1], column[3]), column[5]), column[7]);
                total = ctree::cr_hadd(total, ctree::cr_hadd(even, odd));
            }
            unsigned padding = blocks * 64u - tokens;
            if (padding > 0u) total = ctree::cr_hadd(total, -ctree::cr_hmul(zero, (float)padding));
            recip[r] = qr_half_round(cr_div(1.0f, total));
            sycl::half* outr = dst + (size_t)r * stride;
            for (unsigned k = 0; k < stride; ++k)
                outr[k] = sycl::half(k < tokens ? qr_e4m3(vit_weight(row[k])) : 0.0f);
        };
    };
}

// vit_softmax_tiled (section 100 P4): the SAME row/total/reciprocal math and the SAME
// per-element value qr_e4m3(vit_weight(row[k])) / zero -- but the store lands DIRECTLY
// in the f16v1 pack_a16_b A-tile layout of the attnV gemm (dest = h*per +
// ((tr*kb_n+kc)*2+strip)*128 + il*16 + k16, srow = tr*16+strip*8+il), so the dProbs
// buffer (heads x rows x rows halfs -- the frame's biggest scratch) and the separate
// pack_a16_b pass both vanish. Same lever as gemm_pub_pa16 (P3a, promoted): pack_a16
// is a pure gather of exactly these values; rows here are ALWAYS < Mp (the recorder
// guards rows%16==0 -> Mp==rows), pad COLUMNS (k>=tokens) keep the original's zero.
inline auto vit_softmax_tiled() {
    return [](const float* src, sycl::half* Ap, float* recip, unsigned nrows,
              unsigned tokens, unsigned stride) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= nrows) return;
            const float* row = src + (size_t)r * stride;
            unsigned blocks = (tokens + 63u) / 64u;
            float zero = vit_weight(0.0f), total = 0.0f;
            for (unsigned b = 0; b < blocks; ++b) {
                float column[8];
                for (unsigned c = 0; c < 8u; ++c) {
                    float pair[4];
                    for (unsigned j = 0; j < 4u; ++j) {
                        unsigned k0 = b * 64u + c + 16u * j, k1 = k0 + 8u;
                        float w0 = k0 < tokens ? vit_weight(row[k0]) : zero;
                        float w1 = k1 < tokens ? vit_weight(row[k1]) : zero;
                        pair[j] = ctree::cr_hadd(w0, w1);
                    }
                    column[c] = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(pair[0], pair[1]), pair[2]), pair[3]);
                }
                float even = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[0], column[2]), column[4]), column[6]);
                float odd = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[1], column[3]), column[5]), column[7]);
                total = ctree::cr_hadd(total, ctree::cr_hadd(even, odd));
            }
            unsigned padding = blocks * 64u - tokens;
            if (padding > 0u) total = ctree::cr_hadd(total, -ctree::cr_hmul(zero, (float)padding));
            recip[r] = qr_half_round(cr_div(1.0f, total));
            // tile addressing: head h = r / rows_, row_local srow = r % rows_ where
            // rows_ = stride (the gemm's M == K == rows; one head's block).
            unsigned rows_ = stride;
            unsigned h = r / rows_, srow = r % rows_;
            unsigned tr = srow / 16u, strip = (srow % 16u) / 8u, il = srow % 8u;
            unsigned kb_n = stride / 16u;
            size_t per = (size_t)(stride / 16u) * kb_n * 2u * 128u;   // = Mp*K, Mp=rows
            sycl::half* Apb = Ap + (size_t)h * per;
            for (unsigned k = 0; k < stride; ++k) {
                sycl::half v = sycl::half(k < tokens ? qr_e4m3(vit_weight(row[k])) : 0.0f);
                unsigned kc = k / 16u, k16 = k % 16u;
                Apb[((size_t)(tr * kb_n + kc) * 2u + strip) * 128u + il * 16u + k16] = v;
            }
        };
    };
}

// vit_softmax_tiled_multirow -- the certified multi-row form (s6/smax2_bench.cpp MR<false>, byte
// -identical to vit_softmax_tiled there). Same pure arithmetic, same tile addresses, same reciprocal
// spelling (cr_div inside the contract(off) region); only the WORK DECOMPOSITION differs: lane L of a
// 32-lane row slice owns pair-slot (c = L&7, j = L>>3) of the current 64-column block, stages
// ps[rl*32 + c*4 + j], and the row's lane 0 folds the four partials of each of the 8 columns
// left-associatively (softmax_kernel.hpp:239), then the even/odd column fold (:241-242) and the
// ascending block accumulation (:243). The store pass splits the columns over the lanes, which makes
// each sub-group's store a contiguous 16 x f16 = 32 B write.
static const unsigned SMR_RPB = 8u;      // rows per work-group
static const unsigned SMR_RLW = 32u;     // lanes per row
struct tiled_multirow {
    const float* src; sycl::half* Ap; float* recip; unsigned nrows, tokens, stride;
    sycl::local_accessor<float, 1> la;
    void operator()(sycl::nd_item<1> nd) const {
        unsigned lid = (unsigned)nd.get_local_id(0);
        unsigned rl = lid / SMR_RLW, L = lid % SMR_RLW;
        unsigned r = (unsigned)nd.get_group(0) * SMR_RPB + rl;
        bool act = r < nrows;                       // padded groups: skip the work, keep the barriers uniform
        float* ps = la.get_pointer();
        const float* row = act ? (src + (size_t)r * stride) : src;
        unsigned blocks = (tokens + 63u) / 64u;
        float zero = vit_weight(0.0f), total = 0.0f;
        nd.barrier(sycl::access::fence_space::local_space);
        for (unsigned b = 0; b < blocks; ++b) {
            if (act) {
                unsigned c = L & 7u, j = L >> 3u;
                unsigned k0 = b * 64u + c + 16u * j, k1 = k0 + 8u;
                float w0 = k0 < tokens ? vit_weight(row[k0]) : zero;
                float w1 = k1 < tokens ? vit_weight(row[k1]) : zero;
                ps[rl * SMR_RLW + c * 4u + j] = ctree::cr_hadd(w0, w1);                    // :237
            }
            nd.barrier(sycl::access::fence_space::local_space);
            if (act && L == 0u) {
                float column[8];
                const float* pp = ps + rl * SMR_RLW;
                for (unsigned cc = 0; cc < 8u; ++cc)
                    column[cc] = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(
                          pp[cc * 4u], pp[cc * 4u + 1u]), pp[cc * 4u + 2u]), pp[cc * 4u + 3u]);   // :239
                float even = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[0], column[2]), column[4]), column[6]);
                float odd  = ctree::cr_hadd(ctree::cr_hadd(ctree::cr_hadd(column[1], column[3]), column[5]), column[7]);
                total = ctree::cr_hadd(total, ctree::cr_hadd(even, odd));                  // :241-243
            }
            nd.barrier(sycl::access::fence_space::local_space);
        }
        if (act && L == 0u) {
            unsigned padding = blocks * 64u - tokens;
            if (padding > 0u) total = ctree::cr_hadd(total, -ctree::cr_hmul(zero, (float)padding));
            recip[r] = qr_half_round(cr_div(1.0f, total));                                 // :246-247
        }
        if (act) {
            unsigned rows_ = stride;
            unsigned h = r / rows_, srow = r % rows_;
            unsigned tr = srow / 16u, strip = (srow % 16u) / 8u, il = srow % 8u;
            unsigned kb_n = stride / 16u;
            size_t per = (size_t)(stride / 16u) * kb_n * 2u * 128u;
            sycl::half* Apb = Ap + (size_t)h * per;
            for (unsigned k = L; k < stride; k += SMR_RLW) {                               // :256-259
                sycl::half v = sycl::half(k < tokens ? qr_e4m3(vit_weight(row[k])) : 0.0f);
                unsigned kc = k / 16u, k16 = k % 16u;
                Apb[((size_t)(tr * kb_n + kc) * 2u + strip) * 128u + il * 16u + k16] = v;
            }
        }
    }
};

// #145 (军规 132): launch wrappers with the census tick at entry. The kernel type is
// unchanged, so the GEN instruction census stays comparable; the recorder no longer writes a
// parallel_for at the call site, and nothing is wrapped around a launch.
static inline void launch_vit_softmax_tiled(sycl::queue& q, sycl::range<1> r, const float* src,
                                            sycl::half* Ap, float* recip,
                                            unsigned nrows, unsigned tokens, unsigned stride) {
    LC_TICK();
    bool take = smax_form_on() && smax_form_ok(nrows, tokens, stride);
    smax_form_trace(nrows, tokens, stride, take);
    if (take) {
        // global = nrows * 32 lanes, local = 8 rows x 32 lanes = 256 -> nrows/8 work-groups (6,144 -> 768
        // at the shipped GA shape). SLM = 8 rows x 32 pair-slots x 4 B = 1,024 B per work-group.
        q.submit([&](sycl::handler& h) {
            sycl::local_accessor<float, 1> la(sycl::range<1>(SMR_RPB * SMR_RLW), h);
            h.parallel_for(sycl::nd_range<1>(sycl::range<1>((size_t)nrows * SMR_RLW),
                                             sycl::range<1>(SMR_RPB * SMR_RLW)),
                           tiled_multirow{src, Ap, recip, nrows, tokens, stride, la});
        });
        return;
    }
    q.parallel_for(r, vit_softmax_tiled()(src, Ap, recip, nrows, tokens, stride));
}
static inline void launch_vit_softmax_kernel(sycl::queue& q, sycl::range<1> r, const float* src,
                                             sycl::half* dst, float* recip,
                                             unsigned nrows, unsigned tokens, unsigned stride) {
    LC_TICK();
    q.parallel_for(r, vit_softmax_kernel()(src, dst, recip, nrows, tokens, stride));
}
} // namespace smax
