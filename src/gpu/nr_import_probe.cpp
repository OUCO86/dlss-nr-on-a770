// nr_import_probe.cpp -- can the network's device read what D3D12 wrote?
//
// The smallest question the fused path rests on, asked on its own: make a shared
// D3D12 buffer, write a known colour into it from the D3D12 side, import the handle
// into the Vulkan device the network runs on, and read the bytes back. No shaders,
// no network, no plan -- just the import.
//
// If this reads back the colour that was written, the import is sound and whatever
// is wrong is further in. If it does not, the two halves are not looking at the same
// memory and no amount of pass plumbing will fix it.

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wrl/client.h>
#include <d3d12.h>
#include <dxgi1_4.h>
#include <stdio.h>
#include <stdint.h>

using Microsoft::WRL::ComPtr;

typedef int (*init_fn)(const char*);
typedef int (*res_init_fn)(const char*, const char*, const char*,
                           const char*, const char*, const char*);
typedef int (*import_fn)(unsigned long long, unsigned long long);
typedef int (*download_fn)(int, void*, unsigned long long, unsigned long long);
typedef const char* (*error_fn)(void);

static UINT64 shared_width(UINT64 bytes)
{
    const UINT64 floor = UINT64(16) << 20;
    UINT64 w = (bytes + 65535) & ~UINT64(65535);
    return w < floor ? floor : w;
}

// 0.5 in every channel of R11G11B10.
static uint32_t half_word(void)
{
    const uint32_t r = (14u << 6u) | 0u;
    const uint32_t g = (14u << 6u) | 0u;
    const uint32_t b = (14u << 5u) | 0u;
    return r | (g << 11u) | (b << 22u);
}

#define NR_FOLDER "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work"

int main(void)
{
    const UINT64 bytes = (UINT64)960 * 540 * 4;
    const UINT64 width = shared_width(bytes);

    // ---- the D3D12 side: a shared buffer with a known colour in it -------------
    ComPtr<IDXGIFactory4> factory;
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&factory)))) { printf("no DXGI factory\n"); return 1; }
    ComPtr<IDXGIAdapter1> adapter;
    for (UINT i = 0; factory->EnumAdapters1(i, &adapter) != DXGI_ERROR_NOT_FOUND; ++i)
    {
        DXGI_ADAPTER_DESC1 d {};
        adapter->GetDesc1(&d);
        if (d.VendorId == 0x8086) break;
        adapter.Reset();
    }
    if (!adapter) { printf("no Intel adapter\n"); return 1; }

    ComPtr<ID3D12Device> d3d;
    if (FAILED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&d3d))))
    { printf("no D3D12 device\n"); return 1; }

    ComPtr<ID3D12CommandQueue> queue;
    D3D12_COMMAND_QUEUE_DESC qd {};
    qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    d3d->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue));
    ComPtr<ID3D12CommandAllocator> alloc;
    d3d->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&alloc));
    ComPtr<ID3D12GraphicsCommandList> list;
    d3d->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, alloc.Get(), nullptr, IID_PPV_ARGS(&list));
    ComPtr<ID3D12Fence> done;
    d3d->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&done));

    ComPtr<ID3D12Resource> shared;
    {
        D3D12_HEAP_PROPERTIES hp {};
        hp.Type = D3D12_HEAP_TYPE_DEFAULT;
        D3D12_RESOURCE_DESC rd {};
        rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
        rd.Width = width;
        rd.Height = rd.DepthOrArraySize = rd.MipLevels = 1;
        rd.SampleDesc.Count = 1;
        rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
        if (FAILED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_SHARED, &rd,
                                                D3D12_RESOURCE_STATE_COMMON, nullptr,
                                                IID_PPV_ARGS(&shared))))
        { printf("no shared buffer\n"); return 1; }
    }

    ComPtr<ID3D12Resource> upload;
    {
        D3D12_HEAP_PROPERTIES hp {};
        hp.Type = D3D12_HEAP_TYPE_UPLOAD;
        D3D12_RESOURCE_DESC rd {};
        rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
        rd.Width = bytes;
        rd.Height = rd.DepthOrArraySize = rd.MipLevels = 1;
        rd.SampleDesc.Count = 1;
        rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
        d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &rd,
                                     D3D12_RESOURCE_STATE_GENERIC_READ, nullptr, IID_PPV_ARGS(&upload));
    }

    uint32_t* words = nullptr;
    upload->Map(0, nullptr, (void**)&words);
    for (UINT64 i = 0; i < bytes / 4u; ++i) words[i] = half_word();
    upload->Unmap(0, nullptr);

    list->CopyBufferRegion(shared.Get(), 0, upload.Get(), 0, bytes);
    list->Close();
    ID3D12CommandList* lists[] = { list.Get() };
    queue->ExecuteCommandLists(1, lists);
    const UINT64 v = done->GetCompletedValue() + 1;
    queue->Signal(done.Get(), v);
    HANDLE ev = CreateEventA(nullptr, FALSE, FALSE, nullptr);
    done->SetEventOnCompletion(v, ev);
    WaitForSingleObject(ev, INFINITE);
    CloseHandle(ev);

    HANDLE handle = nullptr;
    if (FAILED(d3d->CreateSharedHandle(shared.Get(), nullptr, GENERIC_ALL, nullptr, &handle)) || !handle)
    { printf("the shared handle was refused\n"); return 1; }
    printf("D3D12: wrote 0x%08X everywhere (%llu bytes in a %llu byte resource)\n",
           half_word(), (unsigned long long)bytes, (unsigned long long)width);

    // ---- the Vulkan side: import the same handle and read it back --------------
    HMODULE lib = LoadLibraryA(NR_FOLDER "\\libxmx.dll");
    if (!lib) { printf("libxmx.dll would not load\n"); return 1; }
    init_fn init = (init_fn)GetProcAddress(lib, "xmx_init");
    res_init_fn res_init = (res_init_fn)GetProcAddress(lib, "xmx_res_init");
    import_fn import = (import_fn)GetProcAddress(lib, "xmx_buf_import");
    download_fn download = (download_fn)GetProcAddress(lib, "xmx_buf_download");
    error_fn why = (error_fn)GetProcAddress(lib, "xmx_error");
    if (!init || !res_init || !import || !download)
    { printf("libxmx.dll does not have the calls\n"); return 1; }

    // The resident runtime, which is what the import asks for: the shaders the
    // network's own passes are built from, in the order the replay gives them.
    char gemm[1024], res[6][1024];
    sprintf_s(gemm, sizeof gemm, "%s\\gemm_coopmat.spv", NR_FOLDER);
    const char* names[6] = { "gemm_resident.spv", "resident.spv", "attention.spv",
                             "history.spv", "gemm_tiled.spv", "gemm_staged.spv" };
    for (int i = 0; i < 6; ++i) sprintf_s(res[i], sizeof res[i], "%s\\%s", NR_FOLDER, names[i]);

    if (init(gemm) != 0)
    { printf("xmx_init failed: %s\n", why ? why() : ""); return 1; }
    if (res_init(res[0], res[1], res[2], res[3], res[4], res[5]) != 0)
    { printf("xmx_res_init failed: %s\n", why ? why() : ""); return 1; }

    // Twice, because that is what the slot does now: the hand-over imports the handle
    // on its own device and the network imports the same handle on another. Asking it
    // twice on one device is enough to see whether a second import of one resource is
    // itself the thing that goes wrong.
    const int first = import((unsigned long long)handle, width);
    printf("Vulkan: first import is buffer %d\n", first);
    const int id = import((unsigned long long)handle, width);
    if (id < 0) { printf("the second import failed: %s\n", why ? why() : ""); return 1; }
    printf("Vulkan: second import is buffer %d\n", id);

    uint32_t back[8] = { 0 };
    if (download(id, back, 0, sizeof back) != 0)
    { printf("the download failed: %s\n", why ? why() : ""); return 1; }

    printf("Vulkan read back: ");
    for (int i = 0; i < 8; ++i) printf("%08X ", back[i]);
    printf("\n%s\n", back[0] == half_word() ? "THE SAME BYTES: the import is sound"
                                            : "DIFFERENT BYTES: the two sides are not one memory");
    return 0;
}
