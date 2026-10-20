// test_pack_device.cpp -- section 55 foundation gate for pack_device.hpp: the device
// gather must be BIT-EXACT against the host pack it replaces (gemm_s8_v8 / gemm_f16_v1),
// on random inputs, across the plan's real shapes. A wrong index decomposition is the
// section-73 failure mode, so this is checked before any recorder is converted.
#include <sycl/sycl.hpp>
#include <cstdio>
#include <vector>
#include <cstdint>
#include <cstring>
#include "gemm_s8_v8_kernel.hpp"
#include "gemm_f16_v1_kernel.hpp"
#include "pack_device.hpp"

static int fails = 0;
static void ok(bool c, const char* m) { std::printf("%s %s\n", c ? "ok   " : "FAIL ", m); if (!c) ++fails; }

int main() {
    sycl::device dev;
    for (auto& d : sycl::device::get_devices(sycl::info::device_type::gpu))
        if (d.get_backend() == sycl::backend::ext_oneapi_level_zero &&
            d.get_info<sycl::info::device::name>().find("Arc") != std::string::npos) { dev = d; break; }
    if (dev.get_backend() != sycl::backend::ext_oneapi_level_zero) { std::printf("no L0 Arc\n"); return 1; }
    sycl::queue q(dev);

    uint32_t s = 0xBADC0DEu;
    auto lcg = [&]{ s = s * 1664525u + 1013904223u; return s; };

    // ---- int8 pack_a / pack_b across plan shapes ----
    for (auto [M, N, K] : std::vector<std::tuple<int,int,int>>{
             {128,64,32},{192,4096,1024},{640,512,512},{130560,512,512},{8192,64,64}}) {
        int Mp = ((M + 127) / 128) * 128;
        std::vector<int8_t> A((size_t)M * K), B((size_t)N * K);   // A is the REAL M rows
        for (auto& v : A) v = (int8_t)(lcg() & 0xFF);
        for (auto& v : B) v = (int8_t)(lcg() & 0xFF);
        // reference = the host path the recorder used: copy into a zero-padded Mp*K, pack.
        std::vector<int8_t> hApad((size_t)Mp * K, 0);
        std::memcpy(hApad.data(), A.data(), (size_t)M * K);
        std::vector<int8_t> hAp((size_t)Mp * K), hBp((size_t)N * K);
        s8v8::pack_a(hApad.data(), hAp.data(), Mp, K);
        s8v8::pack_b(B.data(), hBp.data(), N, K);
        size_t apack = (size_t)Mp * K;
        int8_t *dA = sycl::malloc_device<int8_t>(A.size(), q), *dAp = sycl::malloc_device<int8_t>(apack, q);
        int8_t *dB = sycl::malloc_device<int8_t>(B.size(), q), *dBp = sycl::malloc_device<int8_t>(B.size(), q);
        q.memcpy(dA, A.data(), A.size()).wait(); q.memcpy(dB, B.data(), B.size()).wait();
        packdev::pack_a(q, dA, dAp, M, Mp, K);
        packdev::pack_b(q, dB, dBp, N, K);
        std::vector<int8_t> gAp(apack), gBp(B.size());
        q.memcpy(gAp.data(), dAp, apack).wait(); q.memcpy(gBp.data(), dBp, B.size()).wait();
        char msg[128];
        snprintf(msg, sizeof msg, "int8 pack_a %dx%dx%d", M, N, K);
        ok(gAp == hAp, msg);
        snprintf(msg, sizeof msg, "int8 pack_b %dx%dx%d", M, N, K);
        ok(gBp == hBp, msg);
        sycl::free(dA, q); sycl::free(dAp, q); sycl::free(dB, q); sycl::free(dBp, q);
    }

    // ---- f16 pack_a / pack_b / pack_b_t across plan shapes ----
    for (auto [M, N, K] : std::vector<std::tuple<int,int,int>>{
             {128,64,32},{130560,128,64},{640,512,512},{2048,32,128},{64,64,32}}) {
        int Mp = ((M + 15) / 16) * 16;
        std::vector<sycl::half> A((size_t)M * K), B((size_t)K * N), Bt((size_t)N * K);
        for (auto& v : A) v = sycl::half((float)(lcg() % 1000) / 100.0f - 5.0f);
        for (auto& v : B) v = sycl::half((float)(lcg() % 1000) / 100.0f - 5.0f);
        for (auto& v : Bt) v = sycl::half((float)(lcg() % 1000) / 100.0f - 5.0f);
        std::vector<sycl::half> hApad((size_t)Mp * K, sycl::half(0.0f));
        std::memcpy(hApad.data(), A.data(), (size_t)M * K * 2);
        std::vector<sycl::half> hAp((size_t)Mp * K), hBp((size_t)K * N), hBtp((size_t)K * N);
        f16v1::pack_a(hApad.data(), hAp.data(), Mp, K);
        f16v1::pack_b(B.data(), hBp.data(), K, N);
        f16v1::pack_b_t(Bt.data(), hBtp.data(), K, N);
        size_t apack = (size_t)Mp * K, abytes = A.size() * 2, bbytes = B.size() * 2;
        sycl::half *dA = sycl::malloc_device<sycl::half>(A.size(), q), *dAp = sycl::malloc_device<sycl::half>(apack, q);
        sycl::half *dB = sycl::malloc_device<sycl::half>(B.size(), q), *dBp = sycl::malloc_device<sycl::half>(B.size(), q);
        sycl::half *dBt = sycl::malloc_device<sycl::half>(Bt.size(), q), *dBtp = sycl::malloc_device<sycl::half>(Bt.size(), q);
        q.memcpy(dA, A.data(), abytes).wait(); q.memcpy(dB, B.data(), bbytes).wait(); q.memcpy(dBt, Bt.data(), bbytes).wait();
        packdev::pack_a16(q, dA, dAp, M, Mp, K);
        packdev::pack_b16(q, dB, dBp, K, N);
        packdev::pack_b16_t(q, dBt, dBtp, K, N);
        std::vector<sycl::half> gAp(apack), gBp(B.size()), gBtp(Bt.size());
        q.memcpy(gAp.data(), dAp, apack * 2).wait(); q.memcpy(gBp.data(), dBp, bbytes).wait(); q.memcpy(gBtp.data(), dBtp, bbytes).wait();
        char msg[128];
        auto cmp = [](const std::vector<sycl::half>& x, const std::vector<sycl::half>& y){
            return std::memcmp(x.data(), y.data(), x.size()*2) == 0; };
        snprintf(msg, sizeof msg, "f16 pack_a %dx%dx%d", M, N, K); ok(cmp(gAp, hAp), msg);
        snprintf(msg, sizeof msg, "f16 pack_b %dx%dx%d", M, N, K); ok(cmp(gBp, hBp), msg);
        snprintf(msg, sizeof msg, "f16 pack_b_t %dx%dx%d", M, N, K); ok(cmp(gBtp, hBtp), msg);
        sycl::free(dA,q);sycl::free(dAp,q);sycl::free(dB,q);sycl::free(dBp,q);sycl::free(dBt,q);sycl::free(dBtp,q);
    }

    std::printf("\nPACK_DEVICE %s (%d fails)\n", fails ? "RED" : "GREEN", fails);
    return fails ? 1 : 0;
}
