// publish_kernel.hpp — the SYCL translation of publish.glsl's rounding points + the
// elementwise unary pass. The senior's device-vs-numpy gate for these is BIT-EXACT
// (test_resident.py:65 np.array_equal), unlike quantize's bounded one — so every
// rounding point is written with correctly-rounded primitives (fmul_rn/fadd_rn),
// never a fused multiply-add, exactly as publish.glsl uses `precise` to forbid the
// contraction that would skip the half-rounding between multiply and add.
//
// half_round: float -> half -> float (round-to-nearest-even = numpy astype(float16)).
// publish.glsl keeps two spellings because Mesa vs Intel differ on which survives;
// SYCL's sycl::half conversion is the hardware one and matches numpy on this box.
//
// e4m3 / gate_activation / publish: transcribed line-for-line from publish.glsl.
#pragma once
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>

static inline float qr_half_round(float x) {
    return (float)sycl::half(x);   // f32 -> f16 (RNE) -> f32
}
// correctly-rounded scalar ops (no contraction) — the `precise` equivalent
static inline float cr_mul(float a, float b) { return sycl::ext::intel::math::fmul_rn(a, b); }
static inline float cr_add(float a, float b) { return sycl::ext::intel::math::fadd_rn(a, b); }

static inline float qr_e4m3(float x) {
    float magnitude = sycl::fmin(sycl::fabs(x), 448.0f);
    int exponent = (sycl::bit_cast<int>(magnitude) >> 23) & 0xFF;
    exponent = sycl::max(exponent, 121) - 3;
    float step = sycl::bit_cast<float>(exponent << 23);
    float reciprocal = sycl::bit_cast<float>((254 - exponent) << 23);
    float rounded = cr_mul(sycl::rint(cr_mul(magnitude, reciprocal)), step);   // roundEven, then * step
    return x < 0.0f ? -rounded : rounded;
}

static inline float qr_gate_activation(float x) {
    float wide = qr_half_round(x);
    float clamped = sycl::clamp(wide, -4.0f, 4.0f);
    float linear = cr_mul(sycl::fabs(clamped), -0.055908203125f);
    linear = cr_add(linear, 0.447265625f);
    linear = qr_half_round(linear);
    linear = cr_mul(linear, clamped);
    linear = cr_add(linear, 0.89453125f);
    linear = qr_half_round(linear);
    return qr_half_round(cr_mul(wide, linear));
}

static inline float qr_publish(unsigned epilogue, float value) {
    if (epilogue == 2u || epilogue == 3u) value = qr_gate_activation(value);
    if (epilogue == 1u || epilogue == 3u) value = qr_e4m3(value);
    if (epilogue == 4u) value = qr_half_round(value);
    return value;
}

// elementwise unary: dst[i] = publish(epilogue, src[i]). float32 both sides — the
// dtype plumbing (half buffers) comes with the buffer-table wiring; this isolates the
// rounding-point contract, which is what the senior's gate checks.
inline auto unary_kernel() {
    return [](sycl::float4* src, sycl::float4* dst, unsigned count4, unsigned epilogue) {
        return [=](sycl::item<1> it) {
            unsigned i = (unsigned)it.get_id(0);
            if (i >= count4) return;
            sycl::float4 v = src[i];
            sycl::float4 r;
            r.x() = qr_publish(epilogue, v.x());
            r.y() = qr_publish(epilogue, v.y());
            r.z() = qr_publish(epilogue, v.z());
            r.w() = qr_publish(epilogue, v.w());
            dst[i] = r;
        };
    };
}
