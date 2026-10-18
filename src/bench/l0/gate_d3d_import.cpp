// gate_d3d_import.cpp -- route(a) step 2 (section 64/66): the GAME's data leg through MY
// dll. The bridge (game process) owns a D3D12 device + shared buffer + fence; the shipping
// plan drives libxmx.dll which imports them (xmx_buf_import / xmx_sem_import_fence). This
// gate loads MY libxmx_sycl.dll the same way (LoadLibrary + GetProcAddress, the nr_replay
// pattern) and proves the one open question end-to-end:
//   D3D12 writes a pattern into a SHARED device buffer -> my xmx_buf_import takes that
//   handle -> (1) my xmx_buf_download reads it back BIT-EXACT (the SYCL runtime touches
//   imported D3D12 memory), and (2) a green recorder (xmx_rec_gemm_s8rq) COMPUTES on the
//   imported buffer as its operand A, and the result matches numpy.
// Section 18 already proved the D3D12<->L0 import primitive is two-way bit-exact; the new
// thing here is that it goes through MY SYCL queue, which is what makes the fused graph
// replay read the game's live features. ensure_ze_world adopts SYCL's native context first
// (so import and kernels are one runtime); the stderr census shows which path ran.
//
// D3D12 setup is copied from probe_d3d12_ze.cpp's make_d3d12 verbatim (adapter pick by
// vendor 0x8086, CreateCommittedResource + D3D12_HEAP_FLAG_SHARED, CreateSharedHandle
// GENERIC_ALL, the 16 MB floor, the upload->default CopyResource + fence to have the GPU
// -- not just the host -- write it, matching the game's "copy features then signal" order).
#include <windows.h>
#include <d3d12.h>
#include <dxgi1_6.h>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <vector>

#pragma comment(lib, "d3d12.lib")
#pragma comment(lib, "dxgi.lib")

static int fails = 0;
#define OKAY(cond, msg, ...) do { if (!(cond)) { std::printf("FAIL  " msg "\n", ##__VA_ARGS__); fails++; } \
                                  else { std::printf("ok    " msg "\n", ##__VA_ARGS__); } } while (0)

static const uint64_t RES_BYTES = 16ull << 20;
static ID3D12Device* d3d = nullptr;
static ID3D12CommandQueue* cmdq = nullptr;
static ID3D12Fence* fence = nullptr;
static ID3D12Resource* res = nullptr;
static HANDLE resHandle = nullptr;

// my dll's C ABI, grabbed the way nr_replay.c grabs libxmx's
static int (*x_init)(void);
static int (*x_buf_import)(unsigned long long, unsigned long long);
static int (*x_buf_download)(int, void*, unsigned long long, unsigned long long);
static int (*x_buf_upload)(int, const void*, unsigned long long, unsigned long long);
static int (*x_buf_zero)(int);
static int (*x_begin)(void);
static int (*x_submit)(void);
static int (*x_rec_s8rq)(int, int, int, int, int, unsigned, unsigned, unsigned);
static const char* (*x_error)(void);
static void (*x_idle)(void);

static bool make_d3d12() {
    IDXGIFactory6* fac = nullptr;
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&fac)))) { std::printf("FAIL CreateDXGIFactory1\n"); return false; }
    IDXGIAdapter1* ad = nullptr;
    for (UINT i = 0; fac->EnumAdapters1(i, &ad) != DXGI_ERROR_NOT_FOUND; ++i) {
        DXGI_ADAPTER_DESC1 dd; ad->GetDesc1(&dd);
        if (dd.VendorId == 0x8086) { std::printf("d3d12 adapter: %S (0x%x:0x%x)\n", dd.Description, dd.VendorId, dd.DeviceId); break; }
        ad->Release(); ad = nullptr;
    }
    if (!ad) { std::printf("no Intel adapter\n"); fac->Release(); return false; }
    if (FAILED(D3D12CreateDevice(ad, D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&d3d)))) { std::printf("FAIL D3D12CreateDevice\n"); ad->Release(); fac->Release(); return false; }
    ad->Release(); fac->Release();
    D3D12_COMMAND_QUEUE_DESC qd = {}; qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    if (FAILED(d3d->CreateCommandQueue(&qd, IID_PPV_ARGS(&cmdq)))) { std::printf("FAIL CreateCommandQueue\n"); return false; }
    if (FAILED(d3d->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fence)))) { std::printf("FAIL CreateFence\n"); return false; }

    D3D12_HEAP_PROPERTIES hp = {}; hp.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC rd = {};
    rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER; rd.Width = RES_BYTES; rd.Height = 1;
    rd.DepthOrArraySize = 1; rd.MipLevels = 1; rd.SampleDesc.Count = 1; rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    if (FAILED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_SHARED, &rd, D3D12_RESOURCE_STATE_COPY_DEST, nullptr, IID_PPV_ARGS(&res)))) { std::printf("FAIL CreateCommittedResource\n"); return false; }

    // GPU-write a pattern (upload staging -> CopyResource into the shared DEFAULT buffer),
    // the game's order: fill then signal.
    D3D12_HEAP_PROPERTIES uh = {}; uh.Type = D3D12_HEAP_TYPE_UPLOAD;
    D3D12_RESOURCE_DESC urd = rd;
    ID3D12Resource* up = nullptr;
    if (FAILED(d3d->CreateCommittedResource(&uh, D3D12_HEAP_FLAG_NONE, &urd, D3D12_RESOURCE_STATE_GENERIC_READ, nullptr, IID_PPV_ARGS(&up)))) { std::printf("FAIL upload\n"); return false; }
    void* m = nullptr; up->Map(0, nullptr, &m);
    uint32_t* pat = (uint32_t*)m;
    for (uint64_t i = 0; i < RES_BYTES / 4; ++i) pat[i] = 0xD3D10000u + (uint32_t)i;
    up->Unmap(0, nullptr);
    ID3D12CommandAllocator* ca = nullptr; ID3D12GraphicsCommandList* cl = nullptr;
    d3d->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&ca));
    d3d->CreateCommandList(1, D3D12_COMMAND_LIST_TYPE_DIRECT, ca, nullptr, IID_PPV_ARGS(&cl));
    cl->CopyResource(res, up);
    D3D12_RESOURCE_BARRIER b = {}; b.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    b.Transition.pResource = res; b.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_DEST;
    b.Transition.StateAfter = D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE;
    cl->ResourceBarrier(1, &b);
    cl->Close();
    ID3D12CommandList* lists[] = { cl };
    cmdq->ExecuteCommandLists(1, lists);
    cmdq->Signal(fence, 1);
    while (fence->GetCompletedValue() < 1) { /* spin */ }
    if (FAILED(d3d->CreateSharedHandle(res, nullptr, GENERIC_ALL, nullptr, &resHandle))) { std::printf("FAIL CreateSharedHandle res\n"); return false; }
    std::printf("d3d12 wrote + exported shared buffer handle 0x%llx\n", (unsigned long long)(uintptr_t)resHandle);
    up->Release(); cl->Release(); ca->Release();
    return true;
}

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);
    if (!make_d3d12()) return 1;

    HMODULE mine = LoadLibraryA("libxmx_sycl.dll");
    if (!mine) { std::printf("FAIL: my dll not found (%u)\n", (unsigned)GetLastError()); return 1; }
    x_init = (int(*)(void))GetProcAddress(mine, "xmx_init");
    x_buf_import = (int(*)(unsigned long long, unsigned long long))GetProcAddress(mine, "xmx_buf_import");
    x_buf_download = (int(*)(int, void*, unsigned long long, unsigned long long))GetProcAddress(mine, "xmx_buf_download");
    x_buf_upload = (int(*)(int, const void*, unsigned long long, unsigned long long))GetProcAddress(mine, "xmx_buf_upload");
    x_buf_zero = (int(*)(int))GetProcAddress(mine, "xmx_buf_zero");
    x_begin = (int(*)(void))GetProcAddress(mine, "xmx_begin");
    x_submit = (int(*)(void))GetProcAddress(mine, "xmx_submit");
    x_rec_s8rq = (int(*)(int,int,int,int,int,unsigned,unsigned,unsigned))GetProcAddress(mine, "xmx_rec_gemm_s8rq");
    x_error = (const char*(*)(void))GetProcAddress(mine, "xmx_error");
    x_idle = (void(*)(void))GetProcAddress(mine, "xmx_idle");
    OKAY(x_init && x_buf_import && x_buf_download && x_rec_s8rq, "my dll C ABI present (game-ABI names)");
    if (fails) return 1;

    OKAY(x_init() == 0, "my xmx_init while a live D3D12 device owns the same GPU");
    int ib = x_buf_import((unsigned long long)(uintptr_t)resHandle, RES_BYTES);
    OKAY(ib > 0, "my xmx_buf_import(handle,bytes) -> id %d %s", ib,
         ib > 0 ? "" : (x_error() ? x_error() : ""));
    if (ib <= 0) { std::printf("\nD3D_IMPORT RED (%d fails)\n", fails); return 1; }

    // (1) my download reads the D3D12-written pattern bit-exact through the SYCL runtime.
    std::vector<uint32_t> host(RES_BYTES / 4, 0);
    int rc = x_buf_download(ib, host.data(), 0, RES_BYTES);
    if (x_idle) x_idle();
    uint64_t bad = 0, first = 0;
    for (uint64_t i = 0; i < RES_BYTES / 4; ++i)
        if (host[i] != 0xD3D10000u + (uint32_t)i) { if (!bad) first = i; ++bad; }
    OKAY(rc == 0 && bad == 0,
         "MY SYCL queue reads the imported D3D12 buffer BIT-EXACT (%s)"
         " (append rc=0x%x, wrong=%llu%scould be the section-60 cross-context problem)",
         "", rc, (unsigned long long)bad,
         bad ? (std::printf("      first wrong at %llu: got 0x%x\n", (unsigned long long)first, host[first]), " -- ") : "");

    // (2) a green recorder computes ON the imported buffer as operand A. rq shape is
    // M*K bytes into the first part; use a small M*N*K that fits RES_BYTES: M=256,N=64,
    // K=256 -> A is 256*256=65536 int8 (<=16MB). But the imported buffer holds a u32
    // pattern, not a valid A; so upload a real A INTO the imported id first (proving the
    // kernel can both see writes to and compute on imported memory), then read result.
    // Keep it honest: one more import-free leg -- a plain operand B/scales come from my
    // own buffers; only A is imported. This is the fused path's reality (features live in
    // imported memory; the first GEMM reads them).
    const unsigned M = 256, N = 64, K = 256;
    std::vector<int8_t> A(M * K), B(K * N);
    for (uint64_t i = 0; i < M * (uint64_t)K; ++i) A[i] = (int8_t)((i * 7 + 3) % 251 - 125);
    for (uint64_t i = 0; i < (uint64_t)K * N; ++i) B[i] = (int8_t)((i * 11 + 5) % 251 - 125);
    // overwrite the front of the imported D3D12 buffer with A through MY upload:
    int ur = x_buf_upload(ib, A.data(), 0, M * K);
    OKAY(ur == 0, "upload A into the imported buffer (rc=0x%x)", (unsigned)ur);
    int hB = 0, hC = 0, hCS = 0, hNS = 0;
    // B/scales/out need MY device buffers -- but the only create entry exported to the
    // game ABI is buf_create_kind; grab it too.
    int (*x_buf_kind)(unsigned long long, int) = (int(*)(unsigned long long,int))GetProcAddress(mine, "xmx_buf_create_kind");
    if (x_buf_kind) {
        hB = x_buf_kind(K * N, 1); hC = x_buf_kind(M * N, 1);
        hCS = x_buf_kind(N * 4, 4); hNS = x_buf_kind(M * 4, 4);
        float col[64]; for (unsigned c = 0; c < N; ++c) col[c] = 0.001f * (float)(c % 37 + 1);
        x_buf_upload(hB, B.data(), 0, K * N);
        x_buf_upload(hCS, col, 0, N * 4);
        x_buf_zero(hC); x_buf_zero(hNS);
        x_begin();
        int rec = x_rec_s8rq(ib, hB, hC, hCS, hNS, M, N, K);   // A is the IMPORTED buffer
        x_submit(); if (x_idle) x_idle();
        OKAY(rec == 0, "recorder runs with imported buffer as operand A (rc=0x%x)%s", rec,
             rec ? (std::printf(" err=%s", x_error()), "") : "");
        std::vector<int8_t> out(M * N);
        std::vector<float> ns(M, 0.f);
        x_buf_download(hC, out.data(), 0, M * N);
        x_buf_download(hNS, ns.data(), 0, M * 4);
        // numpy authority for the same A/B -- and read A back from the imported buffer to
        // prove the kernel saw the uploaded bytes, not stale ones.
        std::vector<int8_t> Aback(M * K, 0);
        x_buf_download(ib, Aback.data(), 0, M * K);
        int abad = 0; for (uint64_t i = 0; i < M * (uint64_t)K; ++i) if (Aback[i] != A[i]) { ++abad; break; }
        OKAY(abad == 0, "imported buffer reads back the uploaded A (no stale) %s", abad ? "" : "");
        // bounded check against a numpy int32 GEMM + row requantize, using Aback (device truth)
        long bad = 0; double worst_rel = 0.0; long worst_abs = 0;
        for (unsigned r = 0; r < M; ++r) {
            double peak = 0; std::vector<double> row(N);
            for (unsigned c = 0; c < N; ++c) { long acc = 0; for (unsigned k = 0; k < K; ++k) acc += (int)Aback[(size_t)r*K+k]*(int)B[(size_t)k*N+c]; row[c]=acc*(double)col[c]; double a = row[c] < 0 ? -row[c] : row[c]; if (a > peak) peak = a; }
            double s = peak / 127.0;
            for (unsigned c = 0; c < N; ++c) {
                double got = (double)out[(size_t)r*N+c] * (double)ns[r];
                double err = got - row[c]; if (err < 0) err = -err;
                double lim = (s > 1e-30 ? s : 1e-30) * (0.5 + 1.0 / 65536.0);   // within-one, the green gate's definition
                if (err > lim) ++bad;
                if (err > worst_abs) worst_abs = (long)err;
                double rel = err / (row[c] < 0 ? -row[c] : (row[c] > 1e-9 ? row[c] : 1e-9));
                if (rel > worst_rel) worst_rel = rel;
            }
        }
        OKAY(bad == 0, "recorder on the imported operand A is within-one (rows exceeding the "
             "green gate's 0.5*new_scale bound: %ld; worst abs %ld vs new_scale ~%g)",
             bad, worst_abs, 127.0);
    } else {
        OKAY(false, "buf_create_kind not exported (cannot build the compute leg)");
    }

    res->Release(); fence->Release(); cmdq->Release(); d3d->Release();
    std::printf("\nD3D_IMPORT %s (%d fails)\n", fails ? "RED" : "GREEN", fails);
    return fails ? 1 : 0;
}
