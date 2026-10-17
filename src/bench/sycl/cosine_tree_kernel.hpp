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

} // namespace ctree
