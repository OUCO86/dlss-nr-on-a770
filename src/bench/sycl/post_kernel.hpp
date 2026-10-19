// post_kernel.hpp -- SYCL port of src/gpu/nr_post.comp (the fused image OUTPUT, Mochi's
// Kind::Post). route(a) step 5 (section 90): the game runs the fused path, so the dll
// must compose the network's head back into the game's colour format exactly as
// nr_post.comp does. Elementwise (no GEMM) -- the green unary-kernel family.
//
// EVERY op transcribed from nr_post.comp BEFORE writing the golden (section 73). The
// .comp's `precise` = no FMA contraction (cr_mul/cr_add). exp() appears only in to_proxy
// (the same luminance knee as pre, already proven SYCL==GLSL bit-exact on this Arc,
// section 90's pre shadow). The gate is the old dll's nr_post.spv on identical inputs
// (section 62 shadow), the authority -- not numpy.
//
// Push layout (nr_post.comp:24-31 + libxmx.c:3495 xmx_rec_post):
//   a = colour (R11G11B10, sa words/row)   b = head (f32, (k,batch,4))
//   c = previous output (f32, (k,batch,3))  d = result (R11G11B10, sa words/row)
//   m = pixels on the SOURCE extent, n = 3, k = network height, batch = network width
//   sa = pitch, sb = source height, sc = source width, flags = 0
//   p0/p1 = the gate table's address   p2/p3 = the kept prediction (neural) address
//   table: intensity[65536], confidence[65537], exposure[65538]
#pragma once
#include <sycl/sycl.hpp>

namespace postpass {

// correctly-rounded div/sub (the .comp's `/` and `-`; section 20/74 division discipline).
// cr_sub(a,b) = fadd_rn(a,-b): IEEE subtraction and adding the negation are both
// correctly rounded and give the same result.
static inline float cr_div(float a, float b) { return sycl::ext::intel::math::fdiv_rn(a, b); }
static inline float cr_sub(float a, float b) { return sycl::ext::intel::math::fadd_rn(a, -b); }

static inline float half_(float x) { return (float)sycl::half(x); }

// decode11/decode10 (nr_post:47-57) -- identical to pre's.
static inline float decode11(unsigned v) {
    unsigned e = (v >> 6u) & 0x1Fu, m = v & 0x3Fu;
    return e == 0u ? 0.0f : (float)(64u + m) * sycl::exp2((float)e - 21.0f);
}
static inline float decode10(unsigned v) {
    unsigned e = (v >> 5u) & 0x1Fu, m = v & 0x1Fu;
    return e == 0u ? 0.0f : (float)(32u + m) * sycl::exp2((float)e - 20.0f);
}

// truncate_half (nr_post:38-45): the mantissa's low 13 bits DROPPED (not rounded), and a
// subnormal a multiple of 2^-24. This is what the next frame's history is made of.
static inline float truncate_half(float x) {
    unsigned f = sycl::bit_cast<unsigned>(x);
    float kept = sycl::bit_cast<float>(f & 0xffffe000u);
    float small = sycl::floor(sycl::fabs(x) * 16777216.0f) * sycl::exp2(-24.0f);
    small = x < 0.0f ? -small : small;
    return (f & 0x7fffffffu) >= 0x38800000u ? kept : small;
}

// encode11/encode10 (nr_post:61-79): frexp -> mantissa (128f-64) / (64f-32), exponent+14.
static inline unsigned encode11(float v) {
    if (!(v > 0.0f)) return 0u;
    int e; float f = sycl::frexp(v, &e);
    unsigned m = (unsigned)sycl::clamp(128.0f * f - 64.0f + 0.5f, 0.0f, 63.0f);
    int biased = e + 14;
    if (biased >= 31) return 31u << 6u;
    if (biased <= 0) return 0u;
    return ((unsigned)biased << 6u) | m;
}
static inline unsigned encode10(float v) {
    if (!(v > 0.0f)) return 0u;
    int e; float f = sycl::frexp(v, &e);
    unsigned m = (unsigned)sycl::clamp(64.0f * f - 32.0f + 0.5f, 0.0f, 31.0f);
    int biased = e + 14;
    if (biased >= 31) return 31u << 5u;
    if (biased <= 0) return 0u;
    return ((unsigned)biased << 5u) | m;
}

// to_proxy (nr_post:104-110): the same luminance knee as pre (exp2 form, proven exact).
static inline float luminance(float r, float g, float b) {
    return cr_add(cr_mul(0.2126f, r), cr_add(cr_mul(0.7152f, g), 0.0722f * b));
}
static inline float to_proxy_scale(float lit) {
    if (!(lit > 0.75f)) return 1.0f;
    float rolled = cr_add(cr_mul(0.25f, 1.0f - sycl::exp2(-(lit - 0.75f) * 1.4426950408889634f / 0.25f)), 0.75f);
    return rolled / sycl::max(lit, 1e-6f);
}

struct PostArgs {
    const unsigned* colour;    // a
    const float* head;         // b
    const float* prev;         // c
    unsigned* result;          // d
    const float* table;        // p0/p1
    float* neural;             // p2/p3
    unsigned m, k, batch, sa, sb, sc;
};

static inline auto post_kernel(PostArgs A) {
    return [A](sycl::item<1> it) {
        unsigned pixel = (unsigned)it.get_id(0);
        if (pixel >= A.m) return;
        unsigned width = A.sc;                       // SOURCE width (nr_post:115)
        unsigned x = pixel % width, y = pixel / width;
        unsigned network = y * A.batch + x;          // head indexed by the NETWORK width
        float intensity = A.table[65536u];
        float confidence = A.table[65537u];
        float exposure = A.table[65538u];

        unsigned word = A.colour[y * A.sa + x];
        float rgb[3];
        rgb[0] = decode11(word & 0x7FFu);
        rgb[1] = decode11((word >> 11u) & 0x7FFu);
        rgb[2] = decode10((word >> 22u) & 0x3FFu);
        if (exposure > 0.0f)
            for (int ch = 0; ch < 3; ch++) rgb[ch] = sycl::ext::intel::math::fdiv_rn(rgb[ch], exposure);
        float shown[3];
        for (int ch = 0; ch < 3; ch++) shown[ch] = rgb[ch];
        float proxyScale = to_proxy_scale(luminance(rgb[0], rgb[1], rgb[2]));
        float proxy[3];
        for (int ch = 0; ch < 3; ch++) { proxy[ch] = cr_mul(rgb[ch], proxyScale); rgb[ch] = proxy[ch]; }

        // the gate: the head's 4th channel rounded to half, its bits index the table.
        unsigned bits = (unsigned)sycl::bit_cast<unsigned short>(sycl::half(half_(A.head[network * 4u + 3u])));
        float alpha = A.table[bits];
        if (confidence != 1.0f) alpha = cr_mul(alpha, confidence);

        float blend = intensity;
        float predicted[3];
        for (int ch = 0; ch < 3; ch++) {
            predicted[ch] = sycl::clamp(cr_add(rgb[ch], cr_mul(half_(A.head[network * 4u + ch]), 0.25f)), 0.0f, 1.0f);
            predicted[ch] = cr_add(predicted[ch], cr_mul(alpha, cr_sub(A.prev[network * 3u + ch], predicted[ch])));
        }
        // kept BEFORE the blend: the next frame's history is the model's own prediction.
        for (int ch = 0; ch < 3; ch++) A.neural[network * 3u + ch] = truncate_half(predicted[ch]);

        for (int ch = 0; ch < 3; ch++)
            predicted[ch] = sycl::clamp(cr_add(rgb[ch], cr_mul(blend, cr_sub(predicted[ch], rgb[ch]))), 0.0f, 1.0f);

        // resolve: the model's RATIO to the proxy carries over onto the untouched original.
        for (int ch = 0; ch < 3; ch++) {
            float proxyLinear = proxy[ch];
            float modelLinear = predicted[ch];
            float ratio = proxyLinear > 1e-6f ? cr_div(modelLinear, proxyLinear) : 1.0f;
            predicted[ch] = sycl::max(cr_mul(shown[ch], ratio), 0.0f);
        }
        if (exposure > 0.0f)
            for (int ch = 0; ch < 3; ch++) predicted[ch] = cr_mul(predicted[ch], exposure);
        A.result[y * A.sa + x] = encode11(predicted[0]) | (encode11(predicted[1]) << 11u)
                               | (encode10(predicted[2]) << 22u);
    };
}

} // namespace postpass
