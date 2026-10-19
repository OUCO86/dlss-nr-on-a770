// pre_kernel.hpp — SYCL port of src/gpu/nr_pre.comp (the fused image INPUT, Mochi's
// Kind::Pre). route(a) step 5 (section 90): the game runs the FUSED path, so the dll
// must produce the sixteen feature channels from the game's own colour/motion/history
// exactly as nr_pre.comp does. Elementwise/geometry (no GEMM/coopmat) -- the same family
// as the green unary kernels.
//
// EVERY op is transcribed from nr_pre.comp BEFORE writing the golden (section 73). The
// .comp's `precise` qualifier means "no FMA contraction, each step rounds separately" --
// mirrored with cr_mul/cr_add (fmul_rn/fadd_rn), NEVER a fused fma (that is the opposite
// of precise; section 21/74's contraction lesson). For the few lines the .comp does NOT
// mark precise, we still use the non-contracted form (the conservative choice); the
// shadow gate (old dll's nr_pre.spv vs this kernel, identical inputs, compare feature
// BYTES) is the arbiter of any residual contraction/exp difference -- section 62.
//
// The ONE known bit-exact risk is exp() in to_proxy (nr_pre:135): GLSL exp (old dll,
// Vulkan driver) vs sycl::exp (icx) on this Arc. The authoritative golden is the OLD dll
// running nr_pre.spv, NOT numpy (GLSL exp and numpy exp differ in the last bit; the
// contract is byte-identical features). Features are fp16-packed (11-bit mantissa), which
// absorbs most f32 last-bit differences -- the shadow gate reveals the boundary cases.
//
// Push layout (nr_pre.comp:26-33 + libxmx.c:3424 xmx_rec_pre):
//   a = colour (R11G11B10, `sa` words a row)   b = motion (f32, (sb,sc,2), pixels)
//   c = previous output (f32, (k,batch,3))      d = features (fp16, (k,batch,16))
//   m = pixels on the network extent, n = 16, k = network height, batch = network width
//   sa = pitch (words/row), sb = source height, sc = source width, flags (1 = uv given)
//   p0/p1 = the plan's address (BITS)   p2/p3 = the table's address (exposure [65538],
//         fresh-history flag [65539])
#pragma once
#include <sycl/sycl.hpp>

namespace prepass {

// correctly-rounded division (the .comp's `/`; section 20/74's fdiv_rn discipline -- icx
// otherwise lowers to an approximate reciprocal).
static inline float cr_div(float a, float b) { return sycl::ext::intel::math::fdiv_rn(a, b); }

// half_(x): round to half and back (nr_pre:40).
static inline float half_(float x) { return (float)sycl::half(x); }

// decode11/decode10 (nr_pre:46-58): R11G11B10 unsigned, bias 15, implicit mantissa.
static inline float decode11(unsigned v) {
    unsigned e = (v >> 6u) & 0x1Fu, m = v & 0x3Fu;
    return e == 0u ? 0.0f : (float)(64u + m) * sycl::exp2((float)e - 21.0f);
}
static inline float decode10(unsigned v) {
    unsigned e = (v >> 5u) & 0x1Fu, m = v & 0x1Fu;
    return e == 0u ? 0.0f : (float)(32u + m) * sycl::exp2((float)e - 20.0f);
}

// catmull (nr_pre:64-82). `precise float pixel` = cr_add(cr_mul(norm,dim), -0.5).
struct Catmull { float outer0, middle, outer3, weight0, weight3, gain; };
static inline Catmull catmull(float normalized, unsigned dimension) {
    float pixel = cr_add(cr_mul(normalized, (float)dimension), -0.5f);   // precise
    float base_index = sycl::floor(pixel);
    float t = sycl::clamp(pixel - base_index, 0.0f, 1.0f);
    float square = t * t, cube = square * t;
    Catmull c;
    c.weight0 = cr_add(cr_mul(-0.5f, t), cr_add(square, -0.5f * cube));
    float w1 = cr_add(cr_mul(-2.5f, square), cr_add(cr_mul(1.5f, cube), 1.0f));
    float w2 = cr_add(cr_mul(0.5f, t), cr_add(cr_mul(2.0f, square), -1.5f * cube));
    c.weight3 = cr_add(cr_mul(-0.5f, square), 0.5f * cube);
    c.gain = w1 + w2;
    float base = base_index + 0.5f;
    float lower = 0.5f, upper = (float)dimension - 0.5f;
    c.outer0 = sycl::clamp(base - 1.0f, lower, upper);
    c.middle = sycl::clamp(base + (c.gain == 0.0f ? 0.0f : w2 / c.gain), lower, upper);
    c.outer3 = sycl::clamp(base + 2.0f, lower, upper);
    return c;
}

// to_proxy (nr_pre:131-137): the luminance knee. exp() is the bit-exact risk (header).
static inline float luminance(float r, float g, float b) {
    return cr_add(cr_mul(0.2126f, r), cr_add(cr_mul(0.7152f, g), 0.0722f * b));
}
static inline float to_proxy_scale(float lit) {
    if (!(lit > 0.75f)) return 1.0f;
    float rolled = cr_add(cr_mul(0.25f, 1.0f - sycl::exp(-(lit - 0.75f) / 0.25f)), 0.75f);
    return rolled / sycl::max(lit, 1e-6f);
}

struct PreArgs {
    const unsigned* colour;      // a
    const float* motion;         // b
    const float* prev;           // c
    sycl::half* features;        // d (16 halves a pixel)
    const float* plan;           // p0/p1
    const float* table;          // p2/p3
    unsigned m, k, batch, sa, sb, sc, flags;
};

static inline auto pre_kernel(PreArgs A) {
    return [A](sycl::item<1> it) {
        unsigned pixel = (unsigned)it.get_id(0);
        if (pixel >= A.m) return;
        unsigned width = A.batch, height = A.k;
        unsigned x = pixel % width, y = pixel / width;
        const unsigned noiseAt = 0u;
        const unsigned controlAt = height * width * 3u;
        const unsigned rowsAt = controlAt + 5u;
        const unsigned columnsAt = rowsAt + height;
        int row = sycl::bit_cast<int>(A.plan[rowsAt + y]);
        int column = sycl::bit_cast<int>(A.plan[columnsAt + x]);
        unsigned source = (unsigned)row * A.sc + (unsigned)column;

        unsigned word = A.colour[(unsigned)row * A.sa + (unsigned)column];
        float rgb[3];
        rgb[0] = decode11(word & 0x7FFu);
        rgb[1] = decode11((word >> 11u) & 0x7FFu);
        rgb[2] = decode10((word >> 22u) & 0x3FFu);
        float exposure = A.table[65538u];
        if (exposure > 0.0f)
            for (int ch = 0; ch < 3; ch++) rgb[ch] = sycl::ext::intel::math::fdiv_rn(rgb[ch], exposure);
        float proxyScale = to_proxy_scale(luminance(rgb[0], rgb[1], rgb[2]));
        for (int ch = 0; ch < 3; ch++) rgb[ch] = cr_mul(rgb[ch], proxyScale);

        float u, v;
        if (A.flags != 0u) {
            u = A.motion[source * 2u];
            v = A.motion[source * 2u + 1u];
        } else {
            // precise su = (x+0.5)/width + motion/width  (two rounded adds, no contraction)
            float su = cr_add(cr_div((float)x + 0.5f, (float)width), cr_div(A.motion[source * 2u], (float)width));
            float sv = cr_add(cr_div((float)y + 0.5f, (float)height), cr_div(A.motion[source * 2u + 1u], (float)height));
            u = su; v = sv;
        }
        if (!(u >= 0.0f)) u = 0.0f;
        if (!(v >= 0.0f)) v = 0.0f;
        u = sycl::clamp(u, 0.0f, 1.0f);
        v = sycl::clamp(v, 0.0f, 1.0f);

        Catmull cx = catmull(u, width), cy = catmull(v, height);
        float weights[5] = { cx.weight0 * cy.gain, cx.gain * cy.weight0, cx.gain * cy.gain,
                             cx.gain * cy.weight3, cx.weight3 * cy.gain };
        float coords[5][2] = { {cx.outer0, cy.middle}, {cx.middle, cy.outer0}, {cx.middle, cy.middle},
                               {cx.middle, cy.outer3}, {cx.outer3, cy.middle} };
        float was[3] = {0.0f, 0.0f, 0.0f};
        for (int i = 0; i < 5; i++) {
            // bilinear (nr_pre:84-100) over the previous output (k,batch,3)
            float bx = coords[i][0] - 0.5f, by = coords[i][1] - 0.5f;
            int x0 = (int)sycl::clamp(sycl::floor(bx), 0.0f, (float)(width - 1u));
            int y0 = (int)sycl::clamp(sycl::floor(by), 0.0f, (float)(height - 1u));
            int x1 = sycl::min(x0 + 1, (int)(width - 1u));
            int y1 = sycl::min(y0 + 1, (int)(height - 1u));
            float tx = sycl::clamp(bx - (float)x0, 0.0f, 1.0f);
            float ty = sycl::clamp(by - (float)y0, 0.0f, 1.0f);
            for (int ch = 0; ch < 3; ch++) {
                // precise top = prev[y0,x0]*(1-tx) + prev[y0,x1]*tx  (two rounded muls, one add)
                float top = cr_add(cr_mul(A.prev[((unsigned)y0 * width + (unsigned)x0) * 3u + ch], 1.0f - tx),
                                   A.prev[((unsigned)y0 * width + (unsigned)x1) * 3u + ch] * tx);
                float bot = cr_add(cr_mul(A.prev[((unsigned)y1 * width + (unsigned)x0) * 3u + ch], 1.0f - tx),
                                   A.prev[((unsigned)y1 * width + (unsigned)x1) * 3u + ch] * tx);
                float tap = cr_add(cr_mul(top, 1.0f - ty), bot * ty);
                was[ch] = cr_add(was[ch], weights[i] * tap);   // precise term, then +=
            }
        }
        float denominator = weights[0] + weights[1];
        denominator += weights[2]; denominator += weights[3]; denominator += weights[4];
        for (int ch = 0; ch < 3; ch++) was[ch] = sycl::ext::intel::math::fdiv_rn(was[ch], denominator);

        float values[16];
        float fresh = A.table[65539u];
        for (int ch = 0; ch < 3; ch++) {
            float scaled = half_(cr_mul(half_(half_(rgb[ch]) - 0.5f), 0.125f));
            values[ch] = A.plan[noiseAt + pixel * 3u + ch];
            values[4u + ch] = scaled;
            values[7u + ch] = fresh != 0.0f ? scaled
                                            : half_(cr_mul(half_(half_(was[ch]) - 0.5f), 0.125f));
        }
        values[3] = 1.0f;
        for (int ch = 0; ch < 5; ch++) values[10u + ch] = A.plan[controlAt + ch];
        values[15] = 0.0f;
        for (int j = 0; j < 16; j++) A.features[pixel * 16u + j] = (sycl::half)values[j];
    };
}

} // namespace prepass
