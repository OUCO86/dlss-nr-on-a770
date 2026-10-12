// Asks the second question the bridge rests on, in a process of its own.
//
// The first one (extmem_probe.cpp) was whether a shared D3D12 resource on this adapter can
// be imported into a Vulkan device of our own. It can. This one is whether the game's
// command list can be cut around the upscaler's evaluate, so that work on our own queue can
// be sandwiched between the two halves on the GPU:
//
//     [ producer ... ] -> Execute -> our work -> Execute -> [ continuation ... ]
//
// The shape is the reference's (DlssNr::Submission, from the project this work is modelled
// on). Nothing here is invented: CommandListProxy, ILogicalCommandList::SplitSegments,
// SubmissionHooks::Arm and the between slot come from that tree, unmodified.
//
// What is proved, if it works, is the ordering. Two textures are used so that a single
// execute demonstrates both halves: the producer clears the first, the continuation clears
// the second. If the first is red and the second green afterwards, both halves ran, in that
// order, and the between callback ran between them. A copy of the real hand-over (Vulkan
// work inside the between slot) is not attempted here; one variable at a time.

#include <windows.h>
#include <d3d12.h>
#include <dxgi1_6.h>

#include <cstdio>
#include <vector>

#include <wrl/client.h>

#include "submission/CommandListProxy.h"
#include "submission/SubmissionHooks.h"

using Microsoft::WRL::ComPtr;
using DlssNr::Submission::CommandListProxy;
using DlssNr::Submission::ILogicalCommandList;

namespace
{

constexpr UINT kSize = 64;
constexpr DXGI_FORMAT kFormat = DXGI_FORMAT_R8G8B8A8_UNORM;

struct Adapter
{
    ComPtr<IDXGIAdapter1> adapter;
    UINT vendor = 0;
    char name[128] {};
};

// The A770 is not the first adapter this machine enumerates, so it is found rather than taken.
bool pickIntel(std::vector<Adapter>& out)
{
    ComPtr<IDXGIFactory6> factory;
    if (FAILED(CreateDXGIFactory2(0, IID_PPV_ARGS(&factory))))
        return false;
    ComPtr<IDXGIAdapter1> a;
    for (UINT i = 0; SUCCEEDED(factory->EnumAdapters1(i, &a)); ++i)
    {
        DXGI_ADAPTER_DESC1 d {};
        a->GetDesc1(&d);
        Adapter entry;
        entry.adapter = a;
        entry.vendor = d.VendorId;
        int n = WideCharToMultiByte(CP_UTF8, 0, d.Description, -1, entry.name,
                                    sizeof entry.name, nullptr, nullptr);
        if (n <= 0)
            entry.name[0] = 0;
        out.push_back(entry);
        a.Reset();
    }
    return !out.empty();
}

ComPtr<ID3D12Resource> makeTexture(ID3D12Device* dev)
{
    D3D12_RESOURCE_DESC d {};
    d.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    d.Width = kSize;
    d.Height = kSize;
    d.DepthOrArraySize = 1;
    d.MipLevels = 1;
    d.Format = kFormat;
    d.SampleDesc.Count = 1;
    d.Flags = D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET;

    D3D12_HEAP_PROPERTIES hp {};
    hp.Type = D3D12_HEAP_TYPE_DEFAULT;

    D3D12_CLEAR_VALUE clear {};
    clear.Format = kFormat;
    clear.Color[0] = 0.f;
    clear.Color[1] = 0.f;
    clear.Color[2] = 0.f;
    clear.Color[3] = 1.f;

    ComPtr<ID3D12Resource> r;
    if (FAILED(dev->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &d,
                                            D3D12_RESOURCE_STATE_COMMON, &clear,
                                            IID_PPV_ARGS(&r))))
        return nullptr;
    return r;
}

// One pixel from the middle, read back through its own list so the read cannot be mistaken
// for part of the cut.
bool readCentre(ID3D12Device* dev, ID3D12CommandQueue* queue, ID3D12Resource* tex, float rgba[4])
{
    const UINT rowBytes = kSize * 4;
    const UINT64 total = rowBytes * kSize;

    D3D12_HEAP_PROPERTIES rb {};
    rb.Type = D3D12_HEAP_TYPE_READBACK;
    D3D12_RESOURCE_DESC bd {};
    bd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    bd.Width = total;
    bd.Height = 1;
    bd.DepthOrArraySize = 1;
    bd.MipLevels = 1;
    bd.SampleDesc.Count = 1;
    bd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;

    ComPtr<ID3D12Resource> buf;
    if (FAILED(dev->CreateCommittedResource(&rb, D3D12_HEAP_FLAG_NONE, &bd,
                                            D3D12_RESOURCE_STATE_COPY_DEST, nullptr,
                                            IID_PPV_ARGS(&buf))))
        return false;

    ComPtr<ID3D12CommandAllocator> alloc;
    ComPtr<ID3D12GraphicsCommandList> list;
    if (FAILED(dev->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&alloc))))
        return false;
    if (FAILED(dev->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, alloc.Get(), nullptr,
                                      IID_PPV_ARGS(&list))))
        return false;

    D3D12_RESOURCE_BARRIER toSrc {};
    toSrc.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    toSrc.Transition.pResource = tex;
    toSrc.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
    toSrc.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET;
    toSrc.Transition.StateAfter = D3D12_RESOURCE_STATE_COPY_SOURCE;
    list->ResourceBarrier(1, &toSrc);

    D3D12_TEXTURE_COPY_LOCATION src {};
    src.pResource = tex;
    src.Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
    src.SubresourceIndex = 0;
    D3D12_TEXTURE_COPY_LOCATION dst {};
    dst.pResource = buf.Get();
    dst.Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
    dst.PlacedFootprint.Offset = 0;
    dst.PlacedFootprint.Footprint.Format = kFormat;
    dst.PlacedFootprint.Footprint.Width = kSize;
    dst.PlacedFootprint.Footprint.Height = kSize;
    dst.PlacedFootprint.Footprint.Depth = 1;
    dst.PlacedFootprint.Footprint.RowPitch = rowBytes;
    list->CopyTextureRegion(&dst, 0, 0, 0, &src, nullptr);

    D3D12_RESOURCE_BARRIER back {};
    back.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    back.Transition.pResource = tex;
    back.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
    back.Transition.StateBefore = D3D12_RESOURCE_STATE_COPY_SOURCE;
    back.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;
    list->ResourceBarrier(1, &back);

    if (FAILED(list->Close()))
        return false;

    ID3D12CommandList* lists[] = { list.Get() };
    queue->ExecuteCommandLists(1, lists);

    ComPtr<ID3D12Fence> fence;
    if (FAILED(dev->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence))))
        return false;
    HANDLE ev = CreateEventW(nullptr, FALSE, FALSE, nullptr);
    if (!ev)
        return false;
    queue->Signal(fence.Get(), 1);
    fence->SetEventOnCompletion(1, ev);
    WaitForSingleObject(ev, 5000);
    CloseHandle(ev);

    void* p = nullptr;
    if (FAILED(buf->Map(0, nullptr, &p)))
        return false;
    const auto* bytes = static_cast<const unsigned char*>(p);
    const size_t off = (kSize / 2) * rowBytes + (kSize / 2) * 4;
    for (int i = 0; i < 4; ++i)
        rgba[i] = bytes[off + i] / 255.f;
    buf->Unmap(0, nullptr);
    return true;
}

// Stands in for the work that will run in the between slot. Counts, and reports the queue
// it was handed, which is what the real enqueue needs in order to order itself against it.
std::atomic<int> g_betweenHits { 0 };
ID3D12CommandQueue* g_betweenQueue = nullptr;

void betweenThunk(ID3D12CommandQueue* queue, ID3D12CommandList*, void*)
{
    g_betweenQueue = queue;
    g_betweenHits.fetch_add(1, std::memory_order_relaxed);
    std::printf("   between slot ran on queue %p (hit %d)\n", reinterpret_cast<void*>(queue),
                g_betweenHits.load(std::memory_order_relaxed));
}

} // namespace

int main()
{
    std::printf("command-list split probe\n\n");

    std::vector<Adapter> adapters;
    if (!pickIntel(adapters))
    {
        std::printf("no DXGI adapters\n");
        return 2;
    }
    for (auto& a : adapters)
        std::printf("   adapter: vendor 0x%04x  %s\n", a.vendor, a.name);

    Adapter* chosen = nullptr;
    for (auto& a : adapters)
        if (a.vendor == 0x8086)
            chosen = &a;
    if (!chosen)
    {
        std::printf("no Intel adapter; using the first one\n");
        chosen = &adapters[0];
    }
    std::printf("   chosen: %s\n\n", chosen->name);

    ComPtr<ID3D12Device> dev;
    if (FAILED(D3D12CreateDevice(chosen->adapter.Get(), D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&dev))))
    {
        std::printf("D3D12CreateDevice failed\n");
        return 2;
    }

    D3D12_COMMAND_QUEUE_DESC qd {};
    qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    ComPtr<ID3D12CommandQueue> queue;
    if (FAILED(dev->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue))))
    {
        std::printf("CreateCommandQueue failed\n");
        return 2;
    }

    // Arm before any list is created: the hook has to be in place for the list we cut.
    DlssNr::Submission::Hooks::SetProxyWrap(true);
    DlssNr::Submission::Hooks::SetWrapOpenLists(true);
    const HRESULT armed = DlssNr::Submission::Hooks::Arm(dev.Get(), queue.Get());
    std::printf("   submission hooks armed: 0x%08x\n", static_cast<unsigned>(armed));
    if (FAILED(armed))
        return 2;

    ComPtr<ID3D12CommandAllocator> alloc;
    if (FAILED(dev->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&alloc))))
        return 2;

    ComPtr<ID3D12GraphicsCommandList> list;
    // Goes through the hook, so this is the proxy rather than the real list.
    HRESULT hr = dev->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, alloc.Get(), nullptr,
                                        IID_PPV_ARGS(&list));
    std::printf("   CreateCommandList: 0x%08x\n", static_cast<unsigned>(hr));
    if (FAILED(hr))
        return 2;

    ComPtr<ILogicalCommandList> logical;
    hr = list->QueryInterface(IID_PPV_ARGS(&logical));
    std::printf("   ILogicalCommandList: 0x%08x %s\n", static_cast<unsigned>(hr),
                logical ? "(proxied)" : "(NOT proxied)");
    if (!logical)
    {
        std::printf("RESULT: no proxy; the split cannot be made\n");
        return 1;
    }

    if (logical->IsSplitIneligible())
    {
        const char* why = logical->SplitRejectionReason();
        std::printf("   split ineligible: %s\n", why ? why : "(no reason given)");
        std::printf("RESULT: this list cannot be cut\n");
        return 1;
    }

    // Two textures: one cleared by each half.
    ComPtr<ID3D12Resource> texA = makeTexture(dev.Get());
    ComPtr<ID3D12Resource> texB = makeTexture(dev.Get());
    if (!texA || !texB)
    {
        std::printf("texture creation failed\n");
        return 2;
    }

    D3D12_DESCRIPTOR_HEAP_DESC hd {};
    hd.NumDescriptors = 2;
    hd.Type = D3D12_DESCRIPTOR_HEAP_TYPE_RTV;
    ComPtr<ID3D12DescriptorHeap> heap;
    if (FAILED(dev->CreateDescriptorHeap(&hd, IID_PPV_ARGS(&heap))))
        return 2;
    const UINT stride = dev->GetDescriptorHandleIncrementSize(D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
    D3D12_CPU_DESCRIPTOR_HANDLE rtvA = heap->GetCPUDescriptorHandleForHeapStart();
    D3D12_CPU_DESCRIPTOR_HANDLE rtvB = rtvA;
    rtvB.ptr += stride;
    dev->CreateRenderTargetView(texA.Get(), nullptr, rtvA);
    dev->CreateRenderTargetView(texB.Get(), nullptr, rtvB);

    // ---- producer half ------------------------------------------------------------------
    D3D12_RESOURCE_BARRIER b1 {};
    b1.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    b1.Transition.pResource = texA.Get();
    b1.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
    b1.Transition.StateBefore = D3D12_RESOURCE_STATE_COMMON;
    b1.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;
    list->ResourceBarrier(1, &b1);

    const float red[4] = { 1.f, 0.f, 0.f, 1.f };
    list->ClearRenderTargetView(rtvA, red, 0, nullptr);

    // ---- the cut ------------------------------------------------------------------------
    hr = logical->SplitSegments();
    std::printf("   SplitSegments: 0x%08x\n", static_cast<unsigned>(hr));
    if (FAILED(hr))
    {
        std::printf("RESULT: the cut failed\n");
        return 1;
    }

    // ---- continuation half --------------------------------------------------------------
    D3D12_RESOURCE_BARRIER b2 {};
    b2.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
    b2.Transition.pResource = texB.Get();
    b2.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
    b2.Transition.StateBefore = D3D12_RESOURCE_STATE_COMMON;
    b2.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;
    list->ResourceBarrier(1, &b2);

    const float green[4] = { 0.f, 1.f, 0.f, 1.f };
    list->ClearRenderTargetView(rtvB, green, 0, nullptr);

    if (FAILED(list->Close()))
    {
        std::printf("Close failed\n");
        return 2;
    }

    // ---- execute: producer, between, continuation ---------------------------------------
    DlssNr::Submission::Hooks::SetBetween(&betweenThunk, nullptr);
    ID3D12CommandList* lists[] = { list.Get() };
    queue->ExecuteCommandLists(1, lists);

    ComPtr<ID3D12Fence> fence;
    dev->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&fence));
    HANDLE ev = CreateEventW(nullptr, FALSE, FALSE, nullptr);
    queue->Signal(fence.Get(), 1);
    fence->SetEventOnCompletion(1, ev);
    WaitForSingleObject(ev, 5000);
    CloseHandle(ev);

    std::printf("   between hits: %d\n", g_betweenHits.load());

    float a[4] {}, b[4] {};
    const bool ra = readCentre(dev.Get(), queue.Get(), texA.Get(), a);
    const bool rb = readCentre(dev.Get(), queue.Get(), texB.Get(), b);
    std::printf("   producer texture    : %.2f %.2f %.2f %.2f%s\n", a[0], a[1], a[2], a[3],
                ra ? "" : "  (read failed)");
    std::printf("   continuation texture: %.2f %.2f %.2f %.2f%s\n", b[0], b[1], b[2], b[3],
                rb ? "" : "  (read failed)");

    const bool producerRan = ra && a[0] > 0.5f && a[1] < 0.5f;
    const bool continuationRan = rb && b[1] > 0.5f && b[0] < 0.5f;
    const bool betweenRan = g_betweenHits.load() > 0;

    std::printf("\n");
    if (producerRan && betweenRan && continuationRan)
    {
        std::printf("RESULT: the list was cut and both halves ran, the between slot between them\n");
        return 0;
    }
    std::printf("RESULT: producer=%d between=%d continuation=%d\n", int(producerRan),
                int(betweenRan), int(continuationRan));
    return 1;
}
