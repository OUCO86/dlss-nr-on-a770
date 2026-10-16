// probe_d3d12_ze.cpp — Gate probe ② for option A (L0 + ESIMD rewrite).
//
// QUESTION (§16): can the bridge's D3D12 fence + shared buffers be imported into
// a Level Zero context and correctly ordered against L0 work? The bridge feeds
// the game's D3D12 device to the core via NT shared handles today (Vulkan side:
// libxmx.c:1655 xmx_sem_import_fence, :3368 memory import — both shipped, both
// verified). If the same handles import into L0, the backend swap keeps the
// bridge untouched. This is the LAST gate before funding the 3777-line rewrite.
//
// API ground truth (ze_api.h, this SDK = spec 1.19.12):
//   - there is NO zeImportExternalFence; fences arrive as EXTERNAL SEMAPHORES:
//     zeDeviceImportExternalSemaphoreExt (:15192) with
//     ze_external_semaphore_ext_desc_t.flags = ZE_EXTERNAL_SEMAPHORE_EXT_FLAG_D3D12_FENCE (:15085)
//     and pNext -> ze_external_semaphore_win32_ext_desc_t{handle} (:15111);
//   - wait/signal on them: zeCommandListAppendWaitExternalSemaphoreExt (:15317),
//     which the spec says is IMMEDIATE-command-list-only ("Commandlist handle does
//     not correspond to an immediate command list" is an invalid-arg) — a hard
//     constraint on the static-plan shape, so we test on an immediate list here;
//   - memory: zeMemAllocDevice pNext -> ze_external_memory_import_win32_handle_t
//     (:8125) with flags ZE_EXTERNAL_MEMORY_TYPE_FLAG_D3D12_RESOURCE (:440).
//
// D3D12 shared handle source: ID3D12Device::CreateSharedHandle (fence + committed
// resource). Same-card guarantee: pick the adapter whose vendorId==0x8086 &
// deviceId==0x56a0 (A770) for D3D12, and the Intel GPU ze_device for L0; print
// both so a mismatch is visible (the 9070XT-enumerates-first trap, memory rule).
//
// GATE A (sync ordering):
//   fence starts signaled at 1. L0 immediate list waits for value 2 (not yet met)
//   -> must NOT complete; a second thread SetSignalByIndex to 2 -> must complete
//   within a short host sync. Control: wait for value 999 that never comes ->
//   zeCommandListHostSynchronize must time out (proves the wait really waits,
//   not a silent no-op — the 10-13 lesson).
// GATE B (buffer import):
//   import the D3D12 committed resource into L0 -> non-null device ptr; then
//   zeMemGetAllocProperties reports it as an import. (Data-path fill/readback
//   = GATE C, added next step, one variable at a time.)

#include <windows.h>
#include <d3d12.h>
#include <dxgi1_6.h>
#include <level_zero/ze_api.h>
#include <cstdio>
#include <cstring>
#include <cstdint>

#pragma comment(lib, "d3d12.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "ze_loader.lib")

static int fails = 0;
#define OKAY(cond, msg, ...) do { if (!(cond)) { std::printf("FAIL  " msg "\n", ##__VA_ARGS__); fails++; } \
                                  else { std::printf("ok    " msg "\n", ##__VA_ARGS__); } } while (0)

static ID3D12Device* d3d = nullptr;
static ID3D12CommandQueue* cmdq = nullptr;   // needed to advance the fence (host has no SetSignal)
static ID3D12Fence*  fence = nullptr;
static ID3D12Heap*   heap = nullptr;
static ID3D12Resource* res = nullptr;
static HANDLE fenceHandle = nullptr, resHandle = nullptr;
static const uint64_t RES_BYTES = 16ull << 20; // 16 MB: the hand-over's floor (nr_fuse_probe.cpp:50)

static bool make_d3d12() {
    IDXGIFactory6* fac = nullptr;
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&fac)))) { std::printf("FAIL CreateDXGIFactory1\n"); return false; }
    IDXGIAdapter1* ad = nullptr;
    // pick the Intel Arc A770 explicitly (vendor 0x8086)
    for (UINT i = 0; fac->EnumAdapters1(i, &ad) != DXGI_ERROR_NOT_FOUND; ++i) {
        DXGI_ADAPTER_DESC1 dd; ad->GetDesc1(&dd);
        if (dd.VendorId == 0x8086) { std::printf("d3d12 adapter: %S (0x%x:0x%x)\n", dd.Description, dd.VendorId, dd.DeviceId); break; }
        ad->Release(); ad = nullptr;
    }
    if (!ad) { std::printf("no Intel adapter for D3D12\n"); fac->Release(); return false; }
    if (FAILED(D3D12CreateDevice(ad, D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&d3d)))) { std::printf("FAIL D3D12CreateDevice\n"); ad->Release(); fac->Release(); return false; }
    ad->Release(); fac->Release();

    // SHARED so CreateSharedHandle can export an NT handle. A D3D12 fence's
    // SetSignal value is already a monotonic 64-bit counter (SDK d3d12.h:3957 has
    // no MONOTONIC flag — the counter is inherent), which is exactly what the L0
    // wait_params.value orders against. Same reasoning as libxmx.c:1653's
    // "a shared fence carries a counter" for the Vulkan timeline import.
    if (FAILED(d3d->CreateFence(1, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fence)))) { std::printf("FAIL CreateFence\n"); return false; }
    D3D12_COMMAND_QUEUE_DESC qd = {};
    qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    if (FAILED(d3d->CreateCommandQueue(&qd, IID_PPV_ARGS(&cmdq)))) { std::printf("FAIL CreateCommandQueue\n"); return false; }
    // Access=GENERIC_ALL: the seniors' verified precedent — nr_fuse_probe.cpp:243-244
    // does CreateFence(0, SHARED) + CreateSharedHandle(fence, nullptr, GENERIC_ALL, ...).
    // (SYNCHRONIZE alone fails on this driver, hr printed for the record.)
    HRESULT hrF = d3d->CreateSharedHandle(fence, nullptr, GENERIC_ALL, nullptr, &fenceHandle);
    if (FAILED(hrF)) { std::printf("FAIL fence CreateSharedHandle hr=0x%08x\n", (unsigned)hrF); return false; }

    // Shared buffer: the seniors' verified form (nr_fuse_probe.cpp:48-77):
    // CreateCommittedResource + D3D12_HEAP_FLAG_SHARED, width floored at 16MB
    // and rounded to 64KB ("the hand-over's own rule"). CreateHeap+Placed with
    // 1MB failed E_INVALIDARG (0x80070057) — do not re-litigate, copy the senior.
    D3D12_HEAP_PROPERTIES hp = {};
    hp.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC rd = {};
    rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    rd.Width = RES_BYTES; rd.Height = 1; rd.DepthOrArraySize = 1; rd.MipLevels = 1;
    rd.SampleDesc.Count = 1; rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    if (FAILED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_SHARED, &rd,
                                            D3D12_RESOURCE_STATE_COMMON, nullptr,
                                            IID_PPV_ARGS(&res)))) { std::printf("FAIL CreateCommittedResource\n"); return false; }
    if (FAILED(d3d->CreateSharedHandle(res, nullptr, GENERIC_ALL, nullptr, &resHandle))) { std::printf("FAIL res CreateSharedHandle\n"); return false; }
    return true;
}

static ze_driver_handle_t zdrv = nullptr;
static ze_device_handle_t zdev = nullptr;
static ze_context_handle_t zctx = nullptr;
static ze_command_queue_handle_t zq = nullptr;
static ze_command_list_handle_t zcl = nullptr; // immediate

static bool make_l0() {
    if (zeInit(ZE_INIT_FLAG_GPU_ONLY) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeInit\n"); return false; }
    uint32_t n = 0; zeDriverGet(&n, nullptr);
    ze_driver_handle_t* ds = new ze_driver_handle_t[n]; zeDriverGet(&n, ds);
    for (uint32_t i = 0; i < n; ++i) {
        uint32_t m = 0; zeDeviceGet(ds[i], &m, nullptr);
        ze_device_handle_t* dd = new ze_device_handle_t[m]; zeDeviceGet(ds[i], &m, dd);
        for (uint32_t j = 0; j < m; ++j) {
            ze_device_properties_t p = { ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES };
            zeDeviceGetProperties(dd[j], &p);
            if (p.type == ZE_DEVICE_TYPE_GPU && p.vendorId == 0x8086) {
                std::printf("l0 device: %s (0x%x:0x%x)\n", p.name, p.vendorId, p.deviceId);
                zdrv = ds[i]; zdev = dd[j];
                break;
            }
        }
        delete[] dd; if (zdev) break;
    }
    delete[] ds;
    if (!zdev) { std::printf("no Intel GPU in L0\n"); return false; }
    ze_context_desc_t cd = { ZE_STRUCTURE_TYPE_CONTEXT_DESC };
    if (zeContextCreate(zdrv, &cd, &zctx) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeContextCreate\n"); return false; }
    ze_command_queue_desc_t qd = { ZE_STRUCTURE_TYPE_COMMAND_QUEUE_DESC, nullptr, 0, 0, 0, ZE_COMMAND_QUEUE_MODE_DEFAULT, ZE_COMMAND_QUEUE_PRIORITY_NORMAL };
    if (zeCommandQueueCreate(zctx, zdev, &qd, &zq) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeCommandQueueCreate\n"); return false; }
    ze_command_list_desc_t cld = { ZE_STRUCTURE_TYPE_COMMAND_LIST_DESC };
    // immediate command list: required for external-semaphore wait/signal per spec
    if (zeCommandListCreateImmediate(zctx, zdev, &qd, &zcl) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeCommandListCreateImmediate\n"); return false; }
    return true;
}

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);   // crash-proof tracing: no buffering
    if (!make_d3d12()) return 1;
    if (!make_l0()) return 1;

    // ---- GATE A: import the D3D12 fence as an L0 external semaphore ----
    ze_external_semaphore_win32_ext_desc_t win = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WIN32_EXT_DESC };
    win.handle = fenceHandle; win.name = nullptr;
    ze_external_semaphore_ext_desc_t ed = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_EXT_DESC };
    ed.pNext = &win;
    ed.flags = ZE_EXTERNAL_SEMAPHORE_EXT_FLAG_D3D12_FENCE;
    ze_external_semaphore_ext_handle_t xsem = nullptr;
    ze_result_t r = zeDeviceImportExternalSemaphoreExt(zdev, &ed, &xsem);
    OKAY(r == ZE_RESULT_SUCCESS && xsem, "GATE A import: D3D12 fence -> L0 external semaphore (r=0x%x)", (unsigned)r);

    if (xsem) {
        // wait for value 2 (fence currently at 1): must NOT complete until signaled
        ze_external_semaphore_wait_params_ext_t wp = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WAIT_PARAMS_EXT };
        wp.value = 2;
        r = zeCommandListAppendWaitExternalSemaphoreExt(zcl, 1, &xsem, &wp, nullptr, 0, nullptr);
        OKAY(r == ZE_RESULT_SUCCESS, "GATE A append wait(value=2) on immediate list (r=0x%x)", (unsigned)r);
        if (r == ZE_RESULT_SUCCESS) {
            // it was submitted; a host sync with a tiny timeout must NOT succeed yet
            ze_result_t t0 = zeCommandListHostSynchronize(zcl, 50); // 50 us
            OKAY(t0 == ZE_RESULT_NOT_READY, "GATE A wait blocks while fence<2 (sync=0x%x)", (unsigned)t0);
            // advance the D3D12 fence to 2 via the command queue (host has no SetSignal)
            cmdq->Signal(fence, 2);
            ze_result_t t1 = zeCommandListHostSynchronize(zcl, 2000000); // up to 2 s
            OKAY(t1 == ZE_RESULT_SUCCESS, "GATE A wait released after fence>=2 (sync=0x%x)", (unsigned)t1);
        }
        // control: wait for a value that never comes -> must time out (not no-op).
        // Then release it anyway: a doomed pending wait is exactly what poisoned
        // every later submit for a minute on 2026-10-13 (libxmx.c:1648 comment) —
        // leave the device clean before zeDeviceRelease.
        ze_external_semaphore_wait_params_ext_t wp2 = { ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WAIT_PARAMS_EXT };
        wp2.value = 999;
        r = zeCommandListAppendWaitExternalSemaphoreExt(zcl, 1, &xsem, &wp2, nullptr, 0, nullptr);
        if (r == ZE_RESULT_SUCCESS) {
            ze_result_t t2 = zeCommandListHostSynchronize(zcl, 100000); // 100 ms
            OKAY(t2 == ZE_RESULT_NOT_READY, "GATE A control wait(999) times out (sync=0x%x)", (unsigned)t2);
            cmdq->Signal(fence, 999);
            ze_result_t t3 = zeCommandListHostSynchronize(zcl, 2000000);
            OKAY(t3 == ZE_RESULT_SUCCESS, "GATE A control wait released (device left clean, sync=0x%x)", (unsigned)t3);
        }
        zeDeviceReleaseExternalSemaphoreExt(xsem);
    }

    // ---- GATE C0 (isolation): same copy+sync on a PLAIN L0 device alloc (no import).
    // Separates "imported memory is special" from "my immediate-list copy/sync usage
    // is wrong" — one variable. If C0 also NOT_READY, the bug is my usage, not the import.
    {
        ze_device_mem_alloc_desc_t plain = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC };
        plain.ordinal = 0; void* pp = nullptr;
        r = zeMemAllocDevice(zctx, &plain, 4096, 256, zdev, &pp);
        OKAY(r == ZE_RESULT_SUCCESS && pp, "GATE C0 plain device alloc (r=0x%x)", (unsigned)r);
        if (pp) {
            uint32_t src[1024]; for (int i = 0; i < 1024; ++i) src[i] = 0x11223344u + i;
            r = zeCommandListAppendMemoryCopy(zcl, pp, src, 4096, nullptr, 0, nullptr);
            ze_result_t sc = (r == ZE_RESULT_SUCCESS) ? zeCommandListHostSynchronize(zcl, 2000000) : r;
            OKAY(r == ZE_RESULT_SUCCESS && sc == ZE_RESULT_SUCCESS,
                 "GATE C0 copy->plain + hostSync (append=0x%x sync=0x%x)  [if this FAILS, my immediate-list usage is wrong, not the import]",
                 (unsigned)r, (unsigned)sc);
            zeMemFree(zctx, pp);
        }
    }

    // ---- GATE B: import the D3D12 committed resource into L0 memory ----
    ze_external_memory_import_win32_handle_t mi = { ZE_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMPORT_WIN32 };
    mi.flags = ZE_EXTERNAL_MEMORY_TYPE_FLAG_D3D12_RESOURCE;
    mi.handle = resHandle; mi.name = nullptr;
    ze_device_mem_alloc_desc_t dad = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC };
    dad.pNext = &mi; dad.ordinal = 0;
    void* ptr = nullptr;
    r = zeMemAllocDevice(zctx, &dad, RES_BYTES, 256, zdev, &ptr);
    OKAY(r == ZE_RESULT_SUCCESS && ptr, "GATE B import: D3D12 resource -> L0 device ptr (r=0x%x ptr=%p)", (unsigned)r, ptr);
    if (ptr) {
        ze_memory_allocation_properties_t mp = { ZE_STRUCTURE_TYPE_MEMORY_ALLOCATION_PROPERTIES };
        zeMemGetAllocProperties(zctx, ptr, &mp, nullptr);
        std::printf("      alloc type=%d id=%llu pageSize=%llu\n", (int)mp.type,
                    (unsigned long long)mp.id, (unsigned long long)mp.pageSize);

        // ---- GATE C (data path): L0 writes the imported buffer, D3D12 reads it back.
        // An import that "succeeds" but maps phantom memory would pass GATE B and die
        // here — and the real pipeline is exactly this direction (NR writes, game reads).
        uint32_t* pat = new uint32_t[RES_BYTES / 4];
        for (uint64_t i = 0; i < RES_BYTES / 4; ++i) pat[i] = 0xC0FFEE00u + (uint32_t)i;
        // 1) small copy first (16B) — if even that hangs, it's not a size/timeout issue
        r = zeCommandListAppendMemoryCopy(zcl, ptr, pat, 16, nullptr, 0, nullptr);
        ze_result_t sc0 = (r == ZE_RESULT_SUCCESS) ? zeCommandListHostSynchronize(zcl, 3000000) : r;
        std::printf("      probe: 16B copy-in append=0x%x sync=0x%x\n", (unsigned)r, (unsigned)sc0);
        // 2) is the immediate list still healthy? plain copy on a fresh alloc must pass
        {
            ze_device_mem_alloc_desc_t pl = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC }; pl.ordinal = 0;
            void* pp2 = nullptr; zeMemAllocDevice(zctx, &pl, 4096, 256, zdev, &pp2);
            r = zeCommandListAppendMemoryCopy(zcl, pp2, pat, 4096, nullptr, 0, nullptr);
            ze_result_t scx = (r == ZE_RESULT_SUCCESS) ? zeCommandListHostSynchronize(zcl, 3000000) : r;
            std::printf("      probe: list-health plain copy sync=0x%x\n", (unsigned)scx);
            zeMemFree(zctx, pp2);
        }
        // 3) the real 16MB copy-in with a long timeout
        r = zeCommandListAppendMemoryCopy(zcl, ptr, pat, RES_BYTES, nullptr, 0, nullptr);
        OKAY(r == ZE_RESULT_SUCCESS, "GATE C L0 copy host->imported ptr (r=0x%x)", (unsigned)r);
        if (r == ZE_RESULT_SUCCESS) {
            ze_result_t sc = zeCommandListHostSynchronize(zcl, 10000000); // 10 s
            OKAY(sc == ZE_RESULT_SUCCESS, "GATE C L0 copy completed (sync=0x%x)", (unsigned)sc);
            // GATE C2: pure-L0 read-back — copy the imported memory into a HOST alloc
            // and compare. Pins L0 read+write correctness on the import, independent of
            // the D3D12 scaffolding below.
            if (sc == ZE_RESULT_SUCCESS) {
                ze_host_mem_alloc_desc_t had = { ZE_STRUCTURE_TYPE_HOST_MEM_ALLOC_DESC };
                void* hback = nullptr;
                zeMemAllocHost(zctx, &had, 4096, 64, &hback);
                r = zeCommandListAppendMemoryCopy(zcl, hback, ptr, 4096, nullptr, 0, nullptr);
                ze_result_t sc2 = (r == ZE_RESULT_SUCCESS) ? zeCommandListHostSynchronize(zcl, 3000000) : r;
                uint64_t bad = 0;
                if (sc2 == ZE_RESULT_SUCCESS && hback) {
                    uint32_t* g = (uint32_t*)hback;
                    for (int i = 0; i < 1024; ++i) if (g[i] != 0xC0FFEE00u + (uint32_t)i) { bad++; if (bad==1) std::printf("      C2 first mismatch %d: got 0x%x\n", i, g[i]); }
                }
                OKAY(sc2 == ZE_RESULT_SUCCESS && bad == 0, "GATE C2 pure-L0 read-back of imported memory: %s (sync=0x%x bad=%llu)",
                     bad ? "CORRUPT" : (sc2==ZE_RESULT_SUCCESS?"BIT-EXACT":"NOT VERIFIED"), (unsigned)sc2, (unsigned long long)bad);
                if (hback) zeMemFree(zctx, hback);
            }
            if (sc != ZE_RESULT_SUCCESS) { std::printf("      GATE C data-path NOT verified — skipping readback\n"); }
            else {
            // D3D12 readback: READBACK heap, initial state COPY_DEST. The earlier
            // UPLOAD + GENERIC_READ -> COPY_DEST barrier was the invalid transition that
            // made Close return E_INVALIDARG (MS docs ResourceBarrier: "validation failure
            // causes ID3D12GraphicsCommandList::Close to return E_INVALIDARG"). READBACK
            // buffers start in COPY_DEST and map directly — no transition needed for rb.
            ID3D12Resource* rb = nullptr;
            D3D12_HEAP_PROPERTIES up = {}; up.Type = D3D12_HEAP_TYPE_READBACK;
            D3D12_RESOURCE_DESC rrd = {};
            rrd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER; rrd.Width = RES_BYTES;
            rrd.Height = rrd.DepthOrArraySize = rrd.MipLevels = 1; rrd.SampleDesc.Count = 1;
            rrd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
            HRESULT hrc = d3d->CreateCommittedResource(&up, D3D12_HEAP_FLAG_NONE, &rrd,
                                                       D3D12_RESOURCE_STATE_COPY_DEST, nullptr,
                                                       IID_PPV_ARGS(&rb));
            OKAY(SUCCEEDED(hrc), "GATE C readback resource (hr=0x%x)", (unsigned)hrc);
            if (SUCCEEDED(hrc)) {
                ID3D12GraphicsCommandList* cl = nullptr;
                ID3D12CommandAllocator* ca = nullptr;
                HRESULT h1 = d3d->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&ca));
                HRESULT h2 = ca ? d3d->CreateCommandList(1, D3D12_COMMAND_LIST_TYPE_DIRECT, ca, nullptr, IID_PPV_ARGS(&cl)) : E_FAIL;
                OKAY(SUCCEEDED(h1) && SUCCEEDED(h2) && cl, "GATE C cmdlist (h1=0x%x h2=0x%x)", (unsigned)h1, (unsigned)h2);
                if (cl) {
                // only res needs a transition (COMMON -> COPY_SOURCE); rb already COPY_DEST
                D3D12_RESOURCE_BARRIER bk = {};
                bk.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
                bk.Transition.pResource = res;
                bk.Transition.StateBefore = D3D12_RESOURCE_STATE_COMMON;
                bk.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_SOURCE;
                cl->ResourceBarrier(1, &bk);
                cl->CopyResource(rb, res);
                D3D12_RESOURCE_BARRIER bk2 = {};
                bk2.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
                bk2.Transition.pResource = res;
                bk2.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_SOURCE;
                bk2.Transition.StateAfter = D3D12_RESOURCE_STATE_COMMON;
                cl->ResourceBarrier(1, &bk2);
                HRESULT hrClose = cl->Close();
                OKAY(SUCCEEDED(hrClose), "GATE C cmdlist Close (hr=0x%x)", (unsigned)hrClose);
                if (SUCCEEDED(hrClose)) {
                ID3D12CommandList* lists[] = { cl };
                cmdq->ExecuteCommandLists(1, lists);
                cmdq->Signal(fence, 1000);
                int spins = 0;
                while (fence->GetCompletedValue() < 1000 && ++spins < 20000000) { /* bounded spin */ }
                void* p = nullptr;
                HRESULT hrMap = rb->Map(0, nullptr, &p);
                if (SUCCEEDED(hrMap) && p) {
                uint32_t* got = (uint32_t*)p;
                uint64_t bad = 0;
                for (uint64_t i = 0; i < RES_BYTES / 4; ++i)
                    if (got[i] != 0xC0FFEE00u + (uint32_t)i) { bad++; if (bad == 1) std::printf("      first mismatch at %llu: got 0x%x want 0x%x\n",
                        (unsigned long long)i, got[i], 0xC0FFEE00u + (uint32_t)i); }
                OKAY(bad == 0, "GATE C3 FULL CROSS-API: L0 wrote, D3D12 read back %s (%llu/%llu wrong)",
                     bad ? "CORRUPT" : "BIT-EXACT", (unsigned long long)bad, (unsigned long long)(RES_BYTES / 4));
                rb->Unmap(0, nullptr);
                }
                }
                cl->Release();
                }
                ca->Release(); rb->Release();
            }
            }  // close else (readback only ran when the L0 copy verified)
        }
        delete[] pat;
        zeMemFree(zctx, ptr);
    }

    std::printf("PROBE_D3D12_ZE %s (%d fails)\n", fails ? "RED" : "GREEN", fails);
    std::fflush(stdout);
    return fails ? 2 : 0;
}
