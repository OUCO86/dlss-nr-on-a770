// requant_kernel.hpp -- int32 GEMM accumulator -> int8 + row scale (route B connective
// tissue, section 42). The rq kernel (v3) fuses this into an N==64 GEMM, but the global
// attention GEMMs are N=640/1024 (scores, attnV) and outproj is N=channels -- none is
// N==64, so they run on the general-N v1 int32 kernel and need this SEPARATE exit pass
// to re-enter the int8 straight-through world (attended -> outproj, scores -> softmax).
//
// Contract = v3's EXACTLY (gemm_s8_v3_kernel.hpp:131-133, and gate_gemm_s8rq's golden):
//   fp = float(acc) * a_scale[row] * b_scale[col]   (shipped left-to-right dequantise,
//        island-3; the same two f32 multiplies gemm_int8 / the store path do)
//   rmax = max|fp| over the row
//   new_scale = rmax / 127.0f
//   out = clip(rint(fp * (127.0f / rmax)), -127, 127)   (multiply-form, island-4 rounding)
// NOT int8_quant.quantise (that keeps scale=1.0 for a zero row; the v3 chain uses
// inv=0 -> out=0, scale=0 -- the two differ only on all-zero rows, and the chain's
// requantize is the v3 one, so the golden must be too).
//
// One work-item per row (the RMSNorm/Softmax champion shape, skill pack techniques.md:113);
// the row max is a register reduction, cols <= 1024 fits. Plain SYCL (calls cr_mul/rint,
// the libdevice ops the gated kernels already use). Bounded gate (within-one + scale<=1ulp):
// requantize is lossy, same criteria as gate_gemm_s8rq / gate_cosine_i8 / gate_softmax_i8.
#pragma once
#include <sycl/sycl.hpp>
#include "publish_kernel.hpp"   // cr_mul (= fmul_rn, correctly-rounded, no contraction)

namespace requant {

inline auto requant_i8_kernel() {
    return [](const int32_t* acc, const float* a_scale, const float* b_scale,
              signed char* out8, float* scale, unsigned rows, unsigned cols) {
        return [=](sycl::item<1> it) {
            unsigned r = (unsigned)it.get_id(0);
            if (r >= rows) return;
            const int32_t* arow = acc + (size_t)r * cols;
            signed char* orow = out8 + (size_t)r * cols;
            float as = a_scale[r];
            // pass 1: row absmax of the dequantised values (fp), left-to-right order.
            float rmax = 0.0f;
            for (unsigned c = 0; c < cols; ++c) {
                float fp = cr_mul(cr_mul((float)arow[c], as), b_scale[c]);
                float aa = fp < 0.0f ? -fp : fp;
                if (aa > rmax) rmax = aa;
            }
            // pass 2: v3's requantize (multiply-form inv=127/rmax, rint, clip +-127).
            // Recompute fp (pure arithmetic, no float scratch) so both passes agree.
            float ns = rmax / 127.0f;
            float inv = (rmax > 0.0f) ? 127.0f / rmax : 0.0f;
            for (unsigned c = 0; c < cols; ++c) {
                float fp = cr_mul(cr_mul((float)arow[c], as), b_scale[c]);
                float q = sycl::min(sycl::max(sycl::rint(fp * inv), -127.0f), 127.0f);
                orow[c] = (signed char)(int)q;
            }
            scale[r] = ns;
        };
    };
}

} // namespace requant
