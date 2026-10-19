// gate_pre_native.cpp -- drive MY libxmx_sycl.dll's xmx_rec_pre on the Level-Zero
// backend (the game's actual path; the Python ctypes harness enumerates the Arc as
// opencl, section 60, where the big pre_kernel faults). Loads the dll the way
// gate_d3d_import.cpp does (LoadLibrary + GetProcAddress), builds deterministic inputs,
// runs pre, and dumps the feature bytes to a file. The numpy golden (gate_pre.py's
// transcription of nr_pre.comp) is the authority -- this exe only produces the DEVICE
// side, so we never re-derive the arithmetic in C++ (section 20's host-ref trap).
//
// Inputs are a fixed seed LCG so the Python golden can reproduce them exactly.
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
typedef int (*x_rec_pre_t)(int, int, int, int, int, unsigned, unsigned, unsigned,
                           unsigned, unsigned, unsigned, unsigned, int);
typedef const char* (*x_error_t)(void);

static uint32_t lcg(uint32_t& s) { s = s * 1664525u + 1013904223u; return s; }
// int32 -> float bit pattern (icx C++17 has no std::bit_cast; memcpy is the portable form)
static float i2f(int v) { float f; std::memcpy(&f, &v, sizeof f); return f; }

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
    auto x_rec_pre = (x_rec_pre_t)GetProcAddress(mine, "xmx_rec_pre");
    auto x_error = (x_error_t)GetProcAddress(mine, "xmx_error");
    if (!x_init || !x_create || !x_upload || !x_download || !x_zero || !x_begin ||
        !x_submit || !x_rec_pre) { std::printf("FAIL GetProcAddress\n"); return 1; }
    if (x_init() != 0) { std::printf("FAIL init: %s\n", x_error()); return 1; }

    const unsigned H = 16, W = 16, SH = 16, SW = 16, pitch = SW, pixels = H * W;
    uint32_t s = 0xC0FFEEu;
    std::vector<uint32_t> colour(SH * SW);
    std::vector<float> motion(SH * SW * 2), prev(H * W * 3);
    for (auto& v : colour) v = lcg(s);
    for (auto& v : motion) v = ((float)lcg(s) / 2147483648.0f) - 2.0f;   // [-2,2)
    for (auto& v : prev) v = (float)lcg(s) / 4294967295.0f;              // [0,1)
    std::vector<float> noise(H * W * 3);
    for (auto& v : noise) v = (float)lcg(s) / 4294967295.0f;
    std::vector<float> plan;
    for (auto v : noise) plan.push_back(v);
    for (float c : {0.0f, 1.0f, 1.0f, -1.0f, -1.0f}) plan.push_back(c);
    // rows/columns ride as int32 BIT PATTERNS (the shader reads them with
    // floatBitsToInt; NrPipeline.cpp:608 memcpy's int32 into these float slots) --
    // NOT float(i), whose bit pattern is a huge wrong index (the section-73 lesson).
    for (unsigned i = 0; i < H; i++) plan.push_back(i2f((int)i));
    for (unsigned i = 0; i < W; i++) plan.push_back(i2f((int)i));
    std::vector<float> table(65540, 0.0f);
    table[65536] = 1.0f; table[65537] = 1.0f; table[65538] = 0.5f; table[65539] = 1.0f;

    auto mk = [&](const void* p, size_t n) -> int {
        int h = x_create(n, 0);
        if (h < 0) { std::printf("FAIL create: %s\n", x_error()); exit(1); }
        x_upload(h, p, 0, n);
        return h;
    };
    int hc = mk(colour.data(), colour.size() * 4);
    int hm = mk(motion.data(), motion.size() * 4);
    int hh = mk(prev.data(), prev.size() * 4);
    int hp = mk(plan.data(), plan.size() * 4);
    int ht = mk(table.data(), table.size() * 4);
    int hf = x_create(pixels * 16 * 2, 0);
    x_zero(hf);
    if (x_begin() != 0) { std::printf("FAIL begin\n"); return 1; }
    int rc = x_rec_pre(hc, hm, hh, hf, hp, pixels, H, W, pitch, SH, SW, 0, ht);
    if (rc != 0) { std::printf("FAIL rec_pre: %s\n", x_error()); return 1; }
    int sp = x_submit();
    if (sp < 0) { std::printf("FAIL submit: %s\n", x_error()); return 1; }
    std::vector<uint8_t> got(pixels * 16 * 2);
    x_download(hf, got.data(), 0, got.size());
    // dump the EXACT inputs too, so the Python golden reads the same bytes (no LCG
    // reproduction risk) and compares the device features to the nr_pre.comp transcription.
    auto dump = [&](const char* name, const void* p, size_t n) {
        FILE* f = fopen(name, "wb"); fwrite(p, 1, n, f); fclose(f);
    };
    dump("_pre_colour.bin", colour.data(), colour.size() * 4);
    dump("_pre_motion.bin", motion.data(), motion.size() * 4);
    dump("_pre_prev.bin", prev.data(), prev.size() * 4);
    dump("_pre_plan.bin", plan.data(), plan.size() * 4);
    dump("_pre_table.bin", table.data(), table.size() * 4);
    FILE* fp = fopen("_pre_device.bin", "wb");
    fwrite(got.data(), 1, got.size(), fp);
    fclose(fp);
    std::printf("OK submit rc=0, wrote _pre_device.bin (%zu bytes) + inputs\n", got.size());
    return 0;
}
