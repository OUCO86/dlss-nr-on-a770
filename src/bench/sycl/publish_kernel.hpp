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

// ESIMD-safe spelling of the SAME function: no SYCL device calls, no libdevice, plain
// scalar C++ (sycl::bit_cast is a pure compile-time reinterpret, ESIMD-fine -- unlike
// ext::intel::math::fmul_rn, which is a libdevice wrapper and the compiler refuses to
// call from an ESIMD context. std::bit_cast is NOT available in the device library;
// icx says so and points at sycl::bit_cast. The ternaries replace fmin/max; the
// round-half-even is explicit -- t = mag*reciprocal is in [0,16) on this clamp, so the
// int cast is a floor). qr_e4m3 above stays for the SYCL kernels; the PUBLISH gate
// re-runs over BOTH after any change, and gate_qkv_v checks this one end-to-end.
static inline float qr_e4m3_scalar(float x) {
    float mag = x < 0.0f ? -x : x;
    mag = mag < 448.0f ? mag : 448.0f;
    int exponent = (sycl::bit_cast<int>(mag) >> 23) & 0xFF;
    exponent = (exponent > 121 ? exponent : 121) - 3;
    float step = sycl::bit_cast<float>(exponent << 23);
    float reciprocal = sycl::bit_cast<float>((254 - exponent) << 23);
    float t = mag * reciprocal;                       // [0,16): exact f32 mul, no add to contract
    float fl = (float)(int)t;                         // floor (t >= 0)
    float frac = t - fl;
    float r;
    if (frac > 0.5f) r = fl + 1.0f;
    else if (frac < 0.5f) r = fl;
    else r = ((int)fl & 1) ? fl + 1.0f : fl;          // ties to even
    r = r * step;
    return x < 0.0f ? -r : r;
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

// QKV pass 3: publish + scatter. Reads the normalised f32 in row-major (row, channel)
// order (channel = head*32 + c within the row, channels = heads*32), writes e4m3 halves
// to the (window, head, token, 32) target -- qkv_epilogue.glsl:60-75's at formula. Plain
// SYCL (not ESIMD) so qr_e4m3 (the libdevice spelling, already PUBLISH-gated bit-exact)
// is legal here. count = rows*channels elements.
inline auto qkv_scatter_kernel() {
    return [](const float* src, sycl::half* dst, unsigned rows, unsigned heads,
              unsigned tokens) {
        return [=](sycl::item<1> it) {
            unsigned g = (unsigned)it.get_id(0);
            if (g >= rows * heads * 32u) return;
            unsigned row = g / (heads * 32u), rem = g % (heads * 32u);
            unsigned head = rem / 32u, chan = rem % 32u;
            unsigned window = row / tokens, token = row % tokens;
            size_t at = (((size_t)window * heads + head) * tokens + token) * 32u + chan;
            dst[at] = sycl::half(qr_e4m3(src[g]));
        };
    };
}

// int8 -> float32 publish: dst[i] = publish(epilogue, f32(src[i]) * scale[i/cols]).
// The chain tail: the producer's int8 output + its per-row new_scale dequantise back to
// float (section 9 island-3, the scale multiply, done with cr_mul = fmul_rn so it is the
// correctly-rounded multiply the shipped dequantise does) then the publish rounding chain
// (island-4). This is the seam the OLD chain paid a quantize_row + a dequant pass for; in
// the int8-straight-through chain it is ONE elementwise pass and it is the last one.
inline auto unary_i8_kernel() {
    return [](const signed char* src, const float* scale, float* dst,
              unsigned count, unsigned cols, unsigned epilogue) {
        return [=](sycl::item<1> it) {
            unsigned i = (unsigned)it.get_id(0);
            if (i >= count) return;
            float v = cr_mul((float)src[i], scale[i / cols]);
            dst[i] = qr_publish(epilogue, v);
        };
    };
}
