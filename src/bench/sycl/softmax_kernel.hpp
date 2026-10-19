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
            float recip = (float)sycl::half(sycl::ext::intel::math::fdiv_rn(1.0f, trh));
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
            float recip = (float)sycl::half(sycl::ext::intel::math::fdiv_rn(1.0f, trh));
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

} // namespace smax
