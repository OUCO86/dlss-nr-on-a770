// gate_mega.cpp -- section 92 B1: prove window_block_mega LEG1 is bit-exact against the
// split path (gather + pack_a16 + f16v1::gemm + scalar ctree epilogue) on identical
// inputs, BEFORE wiring it into the engine. Random image + QKV weights; compare dQ/dK/dV
// byte-for-byte. Fast standalone compile (~2 min) so I iterate on the kernel, not the build.
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include <random>
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"
#include "publish_kernel.hpp"
#include "cosine_tree_kernel.hpp"
#include "window_block_mega.hpp"
using namespace sycl;

int main() {
    device dev;
    for (auto& d : device::get_devices(info::device_type::gpu))
        if (d.get_backend() == backend::ext_oneapi_level_zero &&
            d.get_info<info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != backend::ext_oneapi_level_zero) { std::printf("no L0 Arc\n"); return 1; }
    queue q(dev, property::queue::in_order{});

    const unsigned C = 32, NH = 96, tokens = 64;
    const unsigned image_h = 544, image_w = 960, window_cols = 120;
    const unsigned pad_top = 0, pad_left = 0;
    const unsigned windows = (image_h / 8) * (image_w / 8);   // 68*120 = 8160
    const unsigned rows = windows * tokens;
    const int Mp = (int)(((rows + 15u) / 16u) * 16u);

    std::printf("[gate] alloc start\n"); std::fflush(stdout);
    std::mt19937 rng(12345);
    std::uniform_real_distribution<float> dist(-3.f, 3.f);
    std::vector<half> hImg((size_t)image_h * image_w * C);
    for (auto& x : hImg) x = half(dist(rng));
    std::vector<half> hW((size_t)C * NH);
    for (auto& x : hW) x = half(dist(rng) * 0.1f);
    std::vector<float> hScale(1, dist(rng));

    half* Img = (half*)malloc_device(hImg.size() * 2, q);
    half* W = (half*)malloc_device(hW.size() * 2, q);
    float* Sc = (float*)malloc_device(4, q);
    q.memcpy(Img, hImg.data(), hImg.size() * 2).wait();
    q.memcpy(W, hW.data(), hW.size() * 2).wait();
    q.memcpy(Sc, hScale.data(), 4).wait();

    // ---- reference: the split path ----
    half* dAref = (half*)malloc_device((size_t)rows * C * 2, q);
    half* dApre = (half*)malloc_device((size_t)Mp * C * 2, q);
    half* dWp = (half*)malloc_device((size_t)C * NH * 2, q);
    float* dCq = (float*)malloc_device((size_t)Mp * NH * 4, q);
    half* dQr = (half*)malloc_device((size_t)rows * C * 2, q);
    half* dKr = (half*)malloc_device((size_t)rows * C * 2, q);
    half* dVr = (half*)malloc_device((size_t)rows * C * 2, q);
    // Reference gather: EXACTLY the mega's window geometry (pad 0, in-bounds), so both
    // paths see identical A. row r -> window w=r/64, sub=(r/8)%8, t=r%8; y=(w/window_cols)*8+sub,
    // x=(w%window_cols)*8+t; e4m3 publish.
    q.parallel_for(range((size_t)rows * C), [=](item<1> it) {
        size_t i = it.get_id(0);
        unsigned r = (unsigned)(i / C), c = (unsigned)(i % C);
        unsigned w = r / 64u, sub = (r / 8u) % 8u, t = r % 8u;
        int y = (int)((w / window_cols) * 8u + sub);
        int x = (int)((w % window_cols) * 8u + t);
        if (y < 0 || x < 0 || y >= (int)image_h || x >= (int)image_w) { dAref[i] = half(0.f); return; }
        size_t at = ((size_t)y * image_w + (size_t)x) * 32u + c;
        dAref[i] = half(qr_e4m3((float)Img[at]));
    }).wait();
    packdev::pack_a16(q, dAref, dApre, (int)rows, Mp, (int)C);
    packdev::pack_b16(q, W, dWp, (int)C, (int)NH);
    f16v1::gemm(q, dApre, dWp, dCq, Mp, (int)NH, (int)C).wait();
    q.parallel_for(range((size_t)rows), [=](item<1> it) {
        unsigned r = (unsigned)it.get_id(0);
        float row32[32];
        for (int c2 = 0; c2 < 32; ++c2) row32[c2] = qr_half_round(dCq[(size_t)r * NH + c2]);
        float recip = ctree::cosine_reciprocal(row32);
        float sc = qr_half_round(Sc[0]);
        for (int c2 = 0; c2 < 32; ++c2) {
            float v = qr_half_round(cr_mul(row32[c2], recip));
            v = qr_half_round(cr_mul(v, sc));
            dQr[(size_t)r * 32u + c2] = half(qr_e4m3(v));
        }
        for (int c2 = 0; c2 < 32; ++c2) row32[c2] = qr_half_round(dCq[(size_t)r * NH + C + c2]);
        float krec = ctree::cosine_reciprocal(row32);
        for (int c2 = 0; c2 < 32; ++c2)
            dKr[(size_t)r * 32u + c2] = half(qr_e4m3(qr_half_round(cr_mul(row32[c2], krec))));
        for (int c2 = 0; c2 < 32; ++c2)
            dVr[(size_t)r * 32u + c2] = half(qr_e4m3(dCq[(size_t)r * NH + 2u * C + c2]));
    }).wait();

    std::printf("[gate] reference done\n"); std::fflush(stdout);
    // ---- mega path ----
    half* dQm = (half*)malloc_device((size_t)rows * C * 2, q);
    half* dKm = (half*)malloc_device((size_t)rows * C * 2, q);
    half* dVm = (half*)malloc_device((size_t)rows * C * 2, q);
    // the mega needs the packed W (same dWp) and reads the image directly with the SAME
    // gather the split path used. For the gate, feed a straight image (pad 0, in-bounds).
    try {
        std::printf("[gate] mega launching\n"); std::fflush(stdout);
        wbmega::launch_leg1(q, Img, true, dWp, dQm, dKm, dVm, windows, image_h, image_w,
                            window_cols, pad_top, pad_left, Sc).wait();
        std::printf("[gate] mega done\n"); std::fflush(stdout);
    } catch (const sycl::exception& e) {
        std::printf("[gate] MEGA THREW: %s\n", e.what()); std::fflush(stdout); return 2;
    }

    std::printf("[gate] mega done\n"); std::fflush(stdout);
    // ---- compare ----
    std::vector<half> rq(rows * C), rm(rows * C), rkq(rows * C), rkm(rows * C), rvq(rows * C), rvm(rows * C);
    q.memcpy(rq.data(), dQr, rq.size() * 2).wait(); q.memcpy(rm.data(), dQm, rm.size() * 2).wait();
    q.memcpy(rkq.data(), dKr, rkq.size() * 2).wait(); q.memcpy(rkm.data(), dKm, rkm.size() * 2).wait();
    q.memcpy(rvq.data(), dVr, rvq.size() * 2).wait(); q.memcpy(rvm.data(), dVm, rvm.size() * 2).wait();
    auto cmp = [&](const char* nm, std::vector<half>& a, std::vector<half>& b) {
        size_t bad = 0; for (size_t i = 0; i < a.size(); ++i) if (a[i] != b[i]) bad++;
        std::printf("%-4s bit-exact %zu/%zu %s\n", nm, a.size() - bad, a.size(), bad ? "FAIL" : "OK");
        return bad;
    };
    size_t bad = cmp("dQ", rq, rm) + cmp("dK", rkq, rkm) + cmp("dV", rvq, rvm);
    std::printf("MEGA LEG1 GATE: %s\n", bad ? "RED" : "GREEN");
    return bad ? 1 : 0;
}
