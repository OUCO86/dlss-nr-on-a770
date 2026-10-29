// cosine_tree_kernel.hpp — SYCL translation of cosine_tree.glsl (the shipped authority:
// "the only way to be sure they agree is one copy of the arithmetic"). The fragment tree
// is bit-exact by construction: every step is half_round(op) with NO contraction, which
// is what `precise` does in GLSL and what cr_mul/cr_add/qr_half_round do here
// (publish_kernel.hpp, already bit-exact-gated against nr_model).
//
// Golden = nr_model.vendor_cosine_normalize (ref/nr_model.py:242) and _vit_norm (:683).
// inversesqrt = fdiv_rn(1.0f, sycl::sqrt(norm)): sqrt is IEEE-exact in float32, the
// divide is correctly rounded, then half_round -- matching the golden's
// _half_rounded(1.0f/sqrt(norm)) (numpy float32 divide is RN too). fdiv_rn because icx
// lowers bare 1.0f/x to an approximate reciprocal (the §20 lesson).
//
// Form: one work-item per row of 32 (the senior's RMSNorm-ladder champion shape from
// refs/a770-skill techniques.md:113: SIMD32, no cross-lane reduce). This is the island-2
// building block shared by the QKV epilogue and attention's row pass.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>
#include "publish_kernel.hpp"   // qr_half_round, cr_mul, cr_add

namespace ctree {

static const float COSINE_NORM_FLOOR = 0.00006198883056640625f;
static const float VIT_ROOT = 5.65625f;   // half(sqrt(32)), cosine_tree.glsl:58

// the half-fma spelling: half_round(l*r + acc) with the multiply-add NOT contracted
static inline float cr_hfma(float l, float r, float acc) {
    return qr_half_round(sycl::ext::intel::math::fadd_rn(sycl::ext::intel::math::fmul_rn(l, r), acc));
}
static inline float cr_hmul(float l, float r) { return qr_half_round(cr_mul(l, r)); }
static inline float cr_hadd(float l, float r) { return qr_half_round(cr_add(l, r)); }

// cosine_tree.glsl:25-40, verbatim op order. h = one head's 32 channels, already
// half-rounded scalars.
static inline float cosine_reciprocal(const float* h) {
    float partial[4][2];
    for (int lane = 0; lane < 4; ++lane)
        for (int parity = 0; parity < 2; ++parity) {
            int ch = lane * 2 + parity;
            float first  = cr_hfma(h[ch + 8],  h[ch + 8],  cr_hmul(h[ch],       h[ch]));
            float second = cr_hfma(h[ch + 24], h[ch + 24], cr_hmul(h[ch + 16], h[ch + 16]));
            partial[lane][parity] = cr_hadd(first, second);
        }
    float two[4][2], one[4][2];
    for (int lane = 0; lane < 4; ++lane)
        for (int p = 0; p < 2; p++) two[lane][p] = cr_hadd(partial[lane][p], partial[lane ^ 2][p]);
    for (int lane = 0; lane < 4; ++lane)
        for (int p = 0; p < 2; p++) one[lane][p] = cr_hadd(two[lane][p], two[lane ^ 1][p]);
    float norm = sycl::max(cr_hadd(one[0][0], one[0][1]), qr_half_round(COSINE_NORM_FLOOR));
    return qr_half_round(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::sqrt(norm)));
}

// cosine_reciprocal_32 -- GENERATED (kdis/gen_cr32.py) from the exact tree of
// cosine_reciprocal above: same operation ORDER, 32 named params, no array inside.
// Lets the caller keep its row in SSA registers (kill hv[32] -> private/scratch spill).
static inline float cosine_reciprocal_32(float h0, float h1, float h2, float h3, float h4, float h5, float h6, float h7, float h8, float h9, float h10, float h11, float h12, float h13, float h14, float h15, float h16, float h17, float h18, float h19, float h20, float h21, float h22, float h23, float h24, float h25, float h26, float h27, float h28, float h29, float h30, float h31) {
    float one00 = cr_hadd(cr_hadd(cr_hadd(cr_hfma(h8,h8,cr_hmul(h0,h0)), cr_hfma(h24,h24,cr_hmul(h16,h16))), cr_hadd(cr_hfma(h12,h12,cr_hmul(h4,h4)), cr_hfma(h28,h28,cr_hmul(h20,h20)))), cr_hadd(cr_hadd(cr_hfma(h10,h10,cr_hmul(h2,h2)), cr_hfma(h26,h26,cr_hmul(h18,h18))), cr_hadd(cr_hfma(h14,h14,cr_hmul(h6,h6)), cr_hfma(h30,h30,cr_hmul(h22,h22)))));
    float one01 = cr_hadd(cr_hadd(cr_hadd(cr_hfma(h9,h9,cr_hmul(h1,h1)), cr_hfma(h25,h25,cr_hmul(h17,h17))), cr_hadd(cr_hfma(h13,h13,cr_hmul(h5,h5)), cr_hfma(h29,h29,cr_hmul(h21,h21)))), cr_hadd(cr_hadd(cr_hfma(h11,h11,cr_hmul(h3,h3)), cr_hfma(h27,h27,cr_hmul(h19,h19))), cr_hadd(cr_hfma(h15,h15,cr_hmul(h7,h7)), cr_hfma(h31,h31,cr_hmul(h23,h23)))));
    float norm = sycl::max(cr_hadd(one00, one01), qr_half_round(COSINE_NORM_FLOOR));
    return qr_half_round(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::sqrt(norm)));
}

// cosine_tree.glsl:47-54, the ViT variant (opendlss_reference), verbatim.
static inline float vit_reciprocal(const float* h) {
    float r[16];
    for (int c = 0; c < 16; ++c) r[c] = cr_hfma(h[c], h[c], cr_hmul(h[c + 16], h[c + 16]));
    for (int c = 0; c < 8; ++c) r[c] = cr_hadd(r[c], r[c + 8]);
    for (int c = 0; c < 4; ++c) r[c] = cr_hadd(r[c], r[c + 4]);
    float norm = sycl::max(cr_hadd(cr_hadd(r[0], r[2]), cr_hadd(r[1], r[3])), qr_half_round(COSINE_NORM_FLOOR));
    return qr_half_round(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::sqrt(norm)));
}

// kernel: rows x 32 f32 in, normalized f32 out (each output element itself half-rounded,
// exactly as the golden returns astype(float32) of half values). vit flag picks the tree.
// scale (optional, may be null): the QKV epilogue's learned scale, applied AFTER the
// norm exactly as qkv_epilogue.glsl:52-54 -- Q gets hmul(value, half_round(scale[head])),
// and for vit the VIT_ROOT multiply comes between the norm and the scale. K passes null
// (the GLSL's scale=1.0 path). head index of each 32-row = row % heads.
inline auto cosine_norm_kernel() {
    return [](const float* src, float* dst, unsigned rows, unsigned vit,
              const float* scale, unsigned heads) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            float h[32];
            const float* s = src + (size_t)r * 32u;
            for (int i = 0; i < 32; ++i) h[i] = qr_half_round(s[i]);
            float recip = vit ? vit_reciprocal(h) : cosine_reciprocal(h);
            float sc = scale ? qr_half_round(scale[r % heads]) : 0.0f;
            for (int i = 0; i < 32; ++i) {
                float v = cr_mul(h[i], recip);        // hmul's half_round is the store below
                if (scale) {
                    if (vit) v = cr_mul(qr_half_round(v), VIT_ROOT);
                    v = cr_mul(qr_half_round(v), sc);
                }
                dst[(size_t)r * 32u + i] = qr_half_round(v);
            }
        };
    };
}

// int8 requantize variant (route B, section 38 block 1): cosine-normalise -> the row's
// absmax (FREE, all 32 channels are already in registers h[32]) -> requantize to int8 +
// per-row scale. This is v3's fused-requantize contract applied to the cosine output
// instead of a GEMM accumulator: fp = the normalised (and optionally scale-multiplied)
// value; rmax = max|fp| over the row; out = clip(rnde(fp * 127/rmax), -127, 127);
// new_scale = rmax/127. row_scale_A cancels in the int8-straight-through chain (v2 math),
// so the scores rq GEMM eats these int8 Q/K directly -- the e4m3 publish + a quantize_row
// the old chain paid at this seam both die.
//
// The normalised fp values are the SAME half-rounded products the f32 golden returns
// (vendor_cosine_normalize / the vit chain), so the golden is that chain piped through
// int8_quant.quantise -- both shipped authority, no new golden (section 25). Bounded gate
// (within-one + scale<=1ulp), like the rq gate: requantize is lossy quantization.
inline auto cosine_norm_i8_kernel() {
    return [](const float* src, signed char* out8, float* scale, unsigned rows,
              unsigned vit, const float* qscale, unsigned heads) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            float h[32];
            const float* s = src + (size_t)r * 32u;
            for (int i = 0; i < 32; ++i) h[i] = qr_half_round(s[i]);
            float recip = vit ? vit_reciprocal(h) : cosine_reciprocal(h);
            float sc = qscale ? qr_half_round(qscale[r % heads]) : 0.0f;
            float fp[32], rmax = 0.0f;
            for (int i = 0; i < 32; ++i) {
                float v = cr_mul(h[i], recip);
                if (qscale) {
                    if (vit) v = qr_half_round(cr_mul(qr_half_round(v), VIT_ROOT));
                    v = qr_half_round(cr_mul(qr_half_round(v), sc));
                } else {
                    v = qr_half_round(v);
                }
                fp[i] = v;
                float a = v < 0.0f ? -v : v;
                if (a > rmax) rmax = a;
            }
            float ns = rmax / 127.0f;
            float inv = (rmax > 0.0f) ? 127.0f / rmax : 0.0f;
            for (int i = 0; i < 32; ++i) {
                float q = sycl::rint(fp[i] * inv);
                q = sycl::min(sycl::max(q, -127.0f), 127.0f);
                out8[(size_t)r * 32u + i] = (signed char)(int)q;
            }
            scale[r] = ns;
        };
    };
}

} // namespace ctree
