// gate_post_native.cpp -- drive MY libxmx_sycl.dll's xmx_rec_post on Level-Zero (the
// game's path), dump the composed result bytes + the exact inputs, for the three-way
// shadow (compare_post_native.py + gate_post_shadow.cpp). Same shape as gate_pre_native.
// nr_replay.c:693 passes neural=history (the kept prediction writes back into the SAME
// buffer the next frame reads) -- we do the same to exercise that alias.
#include <windows.h>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <vector>

typedef int (*x_init_t)(void);
typedef int (*x_create_t)(unsigned long long, int);
typedef int (*x_upload_t)(int, const void*, unsigned long long, unsigned long long);
typedef int (*x_download_t)(int, void*, unsigned long long, unsigned long long);
typedef int (*x_zero_t)(int);
typedef int (*x_begin_t)(void);
typedef int (*x_submit_t)(void);
typedef int (*x_rec_post_t)(int, int, int, int, int, int, unsigned, unsigned, unsigned,
                            unsigned, unsigned, unsigned);
typedef const char* (*x_error_t)(void);

static uint32_t lcg(uint32_t& s) { s = s * 1664525u + 1013904223u; return s; }

int main() {
    HMODULE mine = LoadLibraryA("libxmx_sycl.dll");
    if (!mine) { std::printf("FAIL LoadLibrary\n"); return 1; }
    auto x_init = (x_init_t)GetProcAddress(mine, "xmx_init");
    auto x_create = (x_create_t)GetProcAddress(mine, "xmx_buf_create_kind");
    auto x_upload = (x_upload_t)GetProcAddress(mine, "xmx_buf_upload");
    auto x_download = (x_download_t)GetProcAddress(mine, "xmx_buf_download");
    auto x_zero = (x_zero_t)GetProcAddress(mine, "xmx_buf_zero");
    auto x_begin = (x_begin_t)GetProcAddress(mine, "xmx_begin");
    auto x_submit = (x_submit_t)GetProcAddress(mine, "xmx_submit");
    auto x_rec_post = (x_rec_post_t)GetProcAddress(mine, "xmx_rec_post");
    auto x_error = (x_error_t)GetProcAddress(mine, "xmx_error");
    if (!x_init || !x_create || !x_upload || !x_download || !x_begin || !x_submit || !x_rec_post) {
        std::printf("FAIL GetProcAddress\n"); return 1;
    }
    if (x_init() != 0) { std::printf("FAIL init: %s\n", x_error()); return 1; }

    const unsigned H = 16, W = 16, SH = 16, SW = 16, pitch = SW, pixels = SH * SW;
    uint32_t s = 0xBEEF01u;
    std::vector<uint32_t> colour(SH * SW);
    std::vector<float> head(H * W * 4), prev(H * W * 3);
    for (auto& v : colour) v = lcg(s);
    for (auto& v : head) v = ((float)lcg(s) / 2147483648.0f) - 1.0f;   // [-1,1) logits
    for (auto& v : prev) v = (float)lcg(s) / 4294967295.0f;            // [0,1)
    std::vector<float> table(65540, 0.0f);
    for (int i = 0; i < 65536; i++) table[i] = (float)lcg(s) / 4294967295.0f;   // gate sigmoids
    table[65536] = 0.8f;   // intensity
    table[65537] = 1.0f;   // confidence
    table[65538] = 0.5f;   // exposure

    auto mk = [&](const void* p, size_t n) -> int {
        int h = x_create(n, 0);
        if (h < 0) { std::printf("FAIL create: %s\n", x_error()); exit(1); }
        x_upload(h, p, 0, n);
        return h;
    };
    int hc = mk(colour.data(), colour.size() * 4);
    int hhd = mk(head.data(), head.size() * 4);
    int hh = mk(prev.data(), prev.size() * 4);          // history (also the neural target)
    int hr = x_create(pixels * 4, 0); x_zero(hr);        // result (R11G11B10 words)
    int ht = mk(table.data(), table.size() * 4);
    if (x_begin() != 0) { std::printf("FAIL begin\n"); return 1; }
    int rc = x_rec_post(hc, hhd, hh, hr, ht, hh, pixels, H, W, pitch, SH, SW);  // neural=history
    if (rc != 0) { std::printf("FAIL rec_post: %s\n", x_error()); return 1; }
    int sp = x_submit();
    if (sp < 0) { std::printf("FAIL submit: %s\n", x_error()); return 1; }
    std::vector<uint8_t> got(pixels * 4);
    x_download(hr, got.data(), 0, got.size());
    std::vector<uint8_t> neu(prev.size() * 4);
    x_download(hh, neu.data(), 0, neu.size());          // the kept prediction (history now)
    auto dump = [&](const char* name, const void* p, size_t n) {
        FILE* f = fopen(name, "wb"); fwrite(p, 1, n, f); fclose(f);
    };
    dump("_post_colour.bin", colour.data(), colour.size() * 4);
    dump("_post_head.bin", head.data(), head.size() * 4);
    dump("_post_prev.bin", prev.data(), prev.size() * 4);
    dump("_post_table.bin", table.data(), table.size() * 4);
    dump("_post_device.bin", got.data(), got.size());
    dump("_post_neural.bin", neu.data(), neu.size());
    std::printf("OK submit rc=0, wrote _post_device.bin (%zu) + _post_neural.bin (%zu) + inputs\n",
                got.size(), neu.size());
    return 0;
}
