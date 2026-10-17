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
#include "publish_kernel.hpp"   // qr_half_round, cr_mul, cr_add, qr_e4m3, qr_e4m3_scalar

namespace smax {

static const float SOFT_SCALE     = 0.044921875f;
static const float SOFT_BIAS      = 1.30078125f;
static const float SOFT_LO        = 1.03125f;
static const float SOFT_HI        = 1.5693359375f;
static const uint32_t SOFT_MAGIC  = 0x7FF88000u;

inline auto softmax_kernel() {
    return [](const float* src, sycl::half* dst, unsigned rows, unsigned cols) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            const float* row = src + (size_t)r * cols;
            sycl::half* outr = dst + (size_t)r * cols;
            // affine + bit-pair transform -> weights (kept as f16 for the two passes).
            // cols is even (golden :215 requires it); process pairs like the shipped kernel.
            float total = 0.0f;
            for (unsigned c = 0; c < cols; c += 2u) {
                // golden :216-220: half_round(value) then *= scale then += bias, ALL in
                // f32 with NO intermediate half-round; the single round to half is the
                // final astype (the bit-pack below). clamp is f32 (bounds exact in half).
                float a0 = cr_add(cr_mul(qr_half_round(row[c]),     SOFT_SCALE), SOFT_BIAS);
                float a1 = cr_add(cr_mul(qr_half_round(row[c + 1]), SOFT_SCALE), SOFT_BIAS);
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
            float recip = (float)sycl::half(sycl::ext::intel::math::fdiv_rn(1.0f, trh));
            for (unsigned c = 0; c < cols; ++c) {
                float w = (float)outr[c];
                outr[c] = sycl::half(qr_e4m3(qr_half_round(cr_mul(w, recip))));
            }
        };
    };
}

} // namespace smax
