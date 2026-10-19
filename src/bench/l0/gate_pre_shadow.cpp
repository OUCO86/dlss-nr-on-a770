// gate_pre_shadow.cpp -- the FULLY INDEPENDENT shadow (section 62): drive the OLD
// libxmx.dll's xmx_rec_pre (real nr_pre.spv, Vulkan) on the SAME input bytes the
// level_zero gate dumped (_pre_colour/motion/prev/plan/table.bin), and write the old
// engine's feature bytes. Three-way compare (compare_pre_native.py): my SYCL device vs
// the old Vulkan device vs the numpy transcription of nr_pre.comp. If all three agree
// within-one, the port is byte-faithful to the shipping shader -- not just to my reading
// of it.
//
// The old dll needs the full init sequence nr_replay.c:940-968 uses (res_init sets the
// pipeline layout xmx_rec_pre binds against). Its buf_create_kind's second arg is the
// buffer KIND (0=GRAPH), not esz (section 69). Its pre barrier loop skips non-imported
// buffers (libxmx.c:3457), so plain GRAPH buffers work for the shadow.
#include <windows.h>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <vector>

typedef int (*x_init_t)(const char*);
typedef int (*x_res_init_t)(const char*, const char*, const char*, const char*, const char*, const char*);
typedef int (*x_staged32_init_t)(const char*, const char*);
typedef int (*x_rows_init_t)(const char*);
typedef int (*x_tiled32_init_t)(const char*);
typedef int (*x_prepost_init_t)(const char*, const char*);
typedef int (*x_create_t)(unsigned long long, int);
typedef int (*x_upload_t)(int, const void*, unsigned long long, unsigned long long);
typedef int (*x_download_t)(int, void*, unsigned long long, unsigned long long);
typedef int (*x_zero_t)(int);
typedef int (*x_begin_t)(void);
typedef int (*x_submit_t)(void);
typedef int (*x_rec_pre_t)(int, int, int, int, int, unsigned, unsigned, unsigned,
                           unsigned, unsigned, unsigned, unsigned, int);
typedef const char* (*x_error_t)(void);

static std::vector<uint8_t> slurp(const char* p) {
    FILE* f = fopen(p, "rb"); if (!f) { std::printf("FAIL open %s\n", p); exit(1); }
    fseek(f, 0, SEEK_END); size_t n = ftell(f); fseek(f, 0, SEEK_SET);
    std::vector<uint8_t> v(n); fread(v.data(), 1, n, f); fclose(f); return v;
}

int main() {
    HMODULE old = LoadLibraryA("libxmx_old.dll");   // staged copy of work/libxmx.dll
    if (!old) { std::printf("FAIL LoadLibrary old\n"); return 1; }
    auto x_init = (x_init_t)GetProcAddress(old, "xmx_init");
    auto x_res_init = (x_res_init_t)GetProcAddress(old, "xmx_res_init");
    auto x_staged32_init = (x_staged32_init_t)GetProcAddress(old, "xmx_staged32_init");
    auto x_rows_init = (x_rows_init_t)GetProcAddress(old, "xmx_rows_init");
    auto x_tiled32_init = (x_tiled32_init_t)GetProcAddress(old, "xmx_tiled32_init");
    auto x_prepost_init = (x_prepost_init_t)GetProcAddress(old, "xmx_prepost_init");
    auto x_create = (x_create_t)GetProcAddress(old, "xmx_buf_create_kind");
    auto x_upload = (x_upload_t)GetProcAddress(old, "xmx_buf_upload");
    auto x_download = (x_download_t)GetProcAddress(old, "xmx_buf_download");
    auto x_zero = (x_zero_t)GetProcAddress(old, "xmx_buf_zero");
    auto x_begin = (x_begin_t)GetProcAddress(old, "xmx_begin");
    auto x_submit = (x_submit_t)GetProcAddress(old, "xmx_submit");
    auto x_rec_pre = (x_rec_pre_t)GetProcAddress(old, "xmx_rec_pre");
    auto x_error = (x_error_t)GetProcAddress(old, "xmx_error");
    if (!x_init || !x_res_init || !x_prepost_init || !x_create || !x_upload ||
        !x_download || !x_begin || !x_submit || !x_rec_pre) {
        std::printf("FAIL GetProcAddress (old)\n"); return 1;
    }
    const char* W = "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work\\";
    auto path = [&](const char* n) { static char buf[512]; snprintf(buf, sizeof buf, "%s%s", W, n); return buf; };
    if (x_init(path("gemm_coopmat.spv")) != 0) { std::printf("FAIL old init: %s\n", x_error()); return 1; }
    x_res_init(path("gemm_resident.spv"), path("resident.spv"), path("attention.spv"),
               path("history.spv"), path("gemm_tiled.spv"), path("gemm_staged.spv"));
    x_staged32_init(path("gemm_staged32.spv"), path("gemm_staged32_deep.spv"));
    x_rows_init(path("attention_rows.spv"));
    x_tiled32_init(path("gemm_tiled32.spv"));
    if (x_prepost_init(path("nr_pre.spv"), path("nr_post.spv")) != 0) {
        std::printf("FAIL old prepost_init: %s\n", x_error()); return 1;
    }

    const unsigned H = 16, Wd = 16, SH = 16, SW = 16, pitch = SW, pixels = H * Wd;
    auto colour = slurp("_pre_colour.bin");
    auto motion = slurp("_pre_motion.bin");
    auto prev = slurp("_pre_prev.bin");
    auto plan = slurp("_pre_plan.bin");
    auto table = slurp("_pre_table.bin");
    auto mk = [&](std::vector<uint8_t>& b) -> int {
        int h = x_create(b.size(), 0);
        if (h < 0) { std::printf("FAIL old create: %s\n", x_error()); exit(1); }
        x_upload(h, b.data(), 0, b.size());
        return h;
    };
    int hc = mk(colour), hm = mk(motion), hh = mk(prev), hp = mk(plan), ht = mk(table);
    int hf = x_create(pixels * 16 * 2, 0);
    x_zero(hf);
    if (x_begin() != 0) { std::printf("FAIL old begin\n"); return 1; }
    int rc = x_rec_pre(hc, hm, hh, hf, hp, pixels, H, Wd, pitch, SH, SW, 0, ht);
    if (rc != 0) { std::printf("FAIL old rec_pre: %s\n", x_error()); return 1; }
    int sp = x_submit();
    if (sp < 0) { std::printf("FAIL old submit: %s\n", x_error()); return 1; }
    std::vector<uint8_t> got(pixels * 16 * 2);
    x_download(hf, got.data(), 0, got.size());
    FILE* fp = fopen("_pre_old.bin", "wb"); fwrite(got.data(), 1, got.size(), fp); fclose(fp);
    std::printf("OK old submit rc=%d passes=%d, wrote _pre_old.bin (%zu bytes)\n", sp, sp, got.size());
    return 0;
}
