// bench_prepost.cpp -- attribute the 13s pre / 13s post (section 92). The fused walk
// timing showed pass 2 (pre) = 12958 ms and pass 691 (post) = 13148 ms at 960x544 --
// pure elementwise kernels that should run in <1 ms. This isolates the suspect libdevice
// calls (fdiv_rn, exp2, frexp) with micro-kernels at the SAME per-pixel counts the real
// kernels use, plus a trivial launch and the full kernels. One compile, one run, ground
// truth on where the 13 seconds goes.
#include <sycl/sycl.hpp>
#include <sycl/ext/intel/math.hpp>
#include <cstdio>
#include <chrono>
#include <vector>
#include <cstring>
#include <cstdint>
#include <functional>
#include "publish_kernel.hpp"   // cr_mul/cr_add (pre/post_kernel depend on these, as the dll does)
#include "gemm_s8_v8_kernel.hpp" // s8v8 pack/gemm for the closure decomposition
#include "pre_kernel.hpp"
#include "post_kernel.hpp"

static sycl::queue* Q = nullptr;
static double now_ms() {
    static auto t0 = std::chrono::steady_clock::now();
    return std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
}

int main() {
    sycl::device dev;
    for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
        if (d.get_backend() == sycl::backend::ext_oneapi_level_zero &&
            d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != sycl::backend::ext_oneapi_level_zero) { std::printf("no L0 Arc\n"); return 1; }
    Q = new sycl::queue(dev);
    std::printf("device: %s\n", dev.get_info<sycl::info::device::name>().c_str());

    const unsigned H = 544, W = 960, pixels = H * W;
    float* out = sycl::malloc_device<float>(pixels * 8, *Q);
    float* ain = sycl::malloc_device<float>(pixels * 8, *Q);
    std::vector<float> host(pixels * 8, 1.5f);
    Q->memcpy(ain, host.data(), host.size() * 4).wait();

    auto timeit = [&](const char* name, std::function<void()> fn) {
        double a = now_ms(); fn(); double b = now_ms();
        std::printf("%-22s %10.2f ms\n", name, b - a);
    };

    timeit("trivial write", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            out[it.get_id(0)] = 0.0f; }).wait(); });

    timeit("fdiv_rn x5/pixel", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            size_t i = it.get_id(0); float v = ain[i];
            for (int k = 0; k < 5; k++) v = sycl::ext::intel::math::fdiv_rn(v, 1.3f + k);
            out[i] = v; }).wait(); });

    timeit("plain / x5/pixel", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            size_t i = it.get_id(0); float v = ain[i];
            for (int k = 0; k < 5; k++) v = v / (1.3f + k);
            out[i] = v; }).wait(); });

    timeit("exp2 x4/pixel", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            size_t i = it.get_id(0); float v = ain[i];
            for (int k = 0; k < 4; k++) v = sycl::exp2(v * 0.01f + k);
            out[i] = v; }).wait(); });

    timeit("frexp x3/pixel", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            size_t i = it.get_id(0); float v = ain[i]; float acc = 0;
            for (int k = 0; k < 3; k++) { int e; float f = sycl::frexp(v + k, &e); acc += f * (float)e; }
            out[i] = acc; }).wait(); });

    timeit("half cvt x12/pixel", [&]{
        Q->parallel_for(sycl::range(pixels), [=](sycl::item<1> it){
            size_t i = it.get_id(0); float v = ain[i];
            for (int k = 0; k < 12; k++) v = (float)sycl::half(v) + 0.001f;
            out[i] = v; }).wait(); });

    // ---- the full kernels, same inputs as gate_pre_native (synth, identity mirror) ----
    unsigned* colour = sycl::malloc_device<unsigned>(pixels, *Q);
    float* motion = sycl::malloc_device<float>(pixels * 2, *Q);
    float* prev = sycl::malloc_device<float>(pixels * 3, *Q);
    sycl::half* feats = sycl::malloc_device<sycl::half>(pixels * 16, *Q);
    size_t plan_n = (size_t)H * W * 3 + 5 + H + W;
    float* plan = sycl::malloc_device<float>(plan_n, *Q);
    float* table = sycl::malloc_device<float>(65540, *Q);
    float* neural = sycl::malloc_device<float>(pixels * 3, *Q);
    unsigned* result = sycl::malloc_device<unsigned>(pixels, *Q);
    {
        std::vector<unsigned> c(pixels); uint32_t s = 0xC0FFEEu;
        auto lcg = [&]{ s = s * 1664525u + 1013904223u; return s; };
        for (auto& v : c) v = lcg();
        Q->memcpy(colour, c.data(), c.size() * 4).wait();
        std::vector<float> m(pixels * 2), p(pixels * 3);
        for (auto& v : m) v = ((float)lcg() / 2147483648.0f) - 1.0f;
        for (auto& v : p) v = (float)lcg() / 4294967295.0f;
        Q->memcpy(motion, m.data(), m.size() * 4).wait();
        Q->memcpy(prev, p.data(), p.size() * 4).wait();
        std::vector<float> pl(plan_n);
        for (size_t i = 0; i < (size_t)H * W * 3; i++) pl[i] = (float)lcg() / 4294967295.0f;
        pl[(size_t)H * W * 3] = 0; pl[(size_t)H * W * 3 + 1] = 1; pl[(size_t)H * W * 3 + 2] = 1;
        pl[(size_t)H * W * 3 + 3] = -1; pl[(size_t)H * W * 3 + 4] = -1;
        size_t rowsAt = (size_t)H * W * 3 + 5;
        for (unsigned y = 0; y < H; y++) { int v = (int)y; float f; memcpy(&f, &v, 4); pl[rowsAt + y] = f; }
        size_t colsAt = rowsAt + H;
        for (unsigned x = 0; x < W; x++) { int v = (int)x; float f; memcpy(&f, &v, 4); pl[colsAt + x] = f; }
        Q->memcpy(plan, pl.data(), pl.size() * 4).wait();
        std::vector<float> tb(65540, 0.0f);
        for (int i = 0; i < 65536; i++) tb[i] = (float)lcg() / 4294967295.0f;
        tb[65536] = 1; tb[65537] = 1; tb[65538] = 0.5f; tb[65539] = 1.0f;
        Q->memcpy(table, tb.data(), tb.size() * 4).wait();
    }
    prepass::PreArgs PA{ colour, motion, prev, feats, plan, table, pixels, H, W, W, H, W, 0u };
    postpass::PostArgs AA{ colour, (const float*)feats, prev, result, table, neural, pixels, H, W, W, H, W };
    timeit("full pre_kernel", [&]{ Q->parallel_for(sycl::range(pixels), prepass::pre_kernel(PA)).wait(); });
    timeit("full post_kernel", [&]{ Q->parallel_for(sycl::range(pixels), postpass::post_kernel(AA)).wait(); });
    timeit("full pre again", [&]{ Q->parallel_for(sycl::range(pixels), prepass::pre_kernel(PA)).wait(); });
    std::printf("(post's head input is the feats buffer here -- shape only, timing is what matters)\n");

    // ---- decompose the 13s/pass: a real gemm_int8 closure at the plan's biggest shape
    // (M=130560 N=512 K=512, the l4 QKV family). Time each stage separately, and the
    // per-pass malloc/free churn, to find where 13 seconds actually goes (PCIe transfer
    // of 66MB should be ~ms, so 13s means a second pathology: alloc storm or CPU pack).
    {
        const int M = 130560, N = 512, K = 512, Mp = ((M + 127) / 128) * 128;
        const size_t na = (size_t)Mp * K, nb = (size_t)N * K;
        std::vector<int8_t> hA((size_t)M * K, 3), hB(nb, 3), hAp(na), hBp(nb);
        int8_t *Araw = sycl::malloc_device<int8_t>((size_t)M * K, *Q);
        int8_t *Braw = sycl::malloc_device<int8_t>(nb, *Q);
        Q->memcpy(Araw, hA.data(), (size_t)M * K).wait();
        Q->memcpy(Braw, hB.data(), nb).wait();
        std::vector<float> as(M, 1.0f), bs(N, 1.0f);
        float *das = sycl::malloc_device<float>(M * 4, *Q), *dbs = sycl::malloc_device<float>(N * 4, *Q);
        Q->memcpy(das, as.data(), M * 4).wait(); Q->memcpy(dbs, bs.data(), N * 4).wait();
        sycl::half* Cout = sycl::malloc_device<sycl::half>((size_t)M * N * 2, *Q);

        timeit("  download A+B (host)", [&]{
            std::vector<int8_t> a((size_t)M * K), b(nb);
            Q->memcpy(a.data(), Araw, (size_t)M * K).wait();
            Q->memcpy(b.data(), Braw, nb).wait(); });
        timeit("  pack_a+pack_b (CPU)", [&]{
            s8v8::pack_a(hA.data(), hAp.data(), Mp, K);
            s8v8::pack_b(hB.data(), hBp.data(), N, K); });
        timeit("  malloc 3 dev bufs", [&]{
            void* x = sycl::malloc_device(na, *Q); void* y = sycl::malloc_device(nb, *Q);
            void* z = sycl::malloc_device((size_t)Mp * N * 4, *Q);
            sycl::free(x, *Q); sycl::free(y, *Q); sycl::free(z, *Q); });
        int8_t *dAp = sycl::malloc_device<int8_t>(na, *Q), *dBp = sycl::malloc_device<int8_t>(nb, *Q);
        int32_t *dC = sycl::malloc_device<int32_t>((size_t)Mp * N * 4, *Q);
        timeit("  upload packed", [&]{
            Q->memcpy(dAp, hAp.data(), na).wait(); Q->memcpy(dBp, hBp.data(), nb).wait(); });
        timeit("  gemm (device)", [&]{ s8v8::gemm(*Q, dAp, dBp, dC, Mp, N, K).wait(); });
        timeit("  publish (device)", [&]{
            Q->parallel_for(sycl::range((size_t)M * N), [=](sycl::item<1> it){
                size_t i = it.get_id(0); unsigned r = (unsigned)(i / N), col = (unsigned)(i % N);
                float v = cr_mul(cr_mul((float)dC[(size_t)r * N + col], das[r]), dbs[col]);
                ((sycl::half*)Cout)[i] = sycl::half(qr_publish(1u, v)); }).wait(); });
        // the whole closure, as the recorder runs it every frame:
        timeit("  FULL closure (as-is)", [&]{
            std::vector<int8_t> ha((size_t)M * K), hb(nb), hap(na, 0), hbp(nb);
            Q->memcpy(ha.data(), Araw, (size_t)M * K).wait();
            std::memcpy(hap.data(), ha.data(), (size_t)M * K);
            Q->memcpy(hb.data(), Braw, nb).wait();
            s8v8::pack_a(hap.data(), hAp.data(), Mp, K); s8v8::pack_b(hb.data(), hbp.data(), N, K);
            void* x = sycl::malloc_device(na, *Q); void* y = sycl::malloc_device(nb, *Q);
            void* z = sycl::malloc_device((size_t)Mp * N * 4, *Q);
            Q->memcpy(x, hAp.data(), na).wait(); Q->memcpy(y, hbp.data(), nb).wait();
            s8v8::gemm(*Q, (int8_t*)x, (int8_t*)y, (int32_t*)z, Mp, N, K).wait();
            sycl::free(x, *Q); sycl::free(y, *Q); sycl::free(z, *Q); });
    }
    return 0;
}
