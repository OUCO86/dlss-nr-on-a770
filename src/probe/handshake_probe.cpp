// Can this adapter carry the hand-over itself, and if it can, which half of it?
//
// The host's between slot does the reference's hand-over: the game's D3D12 queue signals a
// shared fence, a Vulkan submit waits on that fence, and signals a second shared fence that
// the D3D12 queue later waits on. In Lies of P the first three submissions were taken and
// every one after them was refused, each after waiting a quarter of a second for work that
// never finished. The D3D12 side was never in doubt -- it signalled 105 values and saw all
// 105 complete. What was not known is which half of the hand-over this adapter fails to do.
//
// That is a question about the driver, so it is asked here, in a process of its own, with no
// game, no hook and no frame. Each case below varies one thing and prints what it saw, so the
// answer is a line of output and not an inference from a frame rate.
//
//   whether Vulkan can see a value D3D12 signalled, read with vkGetSemaphoreCounterValue
//   whether a Vulkan submit that waits on that value ever finishes
//   whether D3D12 can see the value the Vulkan submit signalled back
//   whether the way the fence was imported changes any of the three
//   whether an empty command buffer, or the wait stage, changes any of the three
//
// The shape of the import is the reference's, refs/optiscaler/src/windows/pe/nr_pe_bridge.cpp
// Device::import_fence (989-1027), and the submit is its Device::submit (917-964).
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <dxgi1_4.h>
#include <d3d12.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <wrl/client.h>

using Microsoft::WRL::ComPtr;

namespace {

VkInstance g_instance = VK_NULL_HANDLE;
VkPhysicalDevice g_physical = VK_NULL_HANDLE;
VkDevice g_device = VK_NULL_HANDLE;
VkQueue g_queue = VK_NULL_HANDLE;
VkCommandPool g_pool = VK_NULL_HANDLE;
uint32_t g_family = 0;
PFN_vkImportSemaphoreWin32HandleKHR g_import = nullptr;

void say(const char* fmt, ...)
{
    va_list a;
    va_start(a, fmt);
    std::printf("  ");
    std::vprintf(fmt, a);
    std::printf("\n");
    va_end(a);
    std::fflush(stdout);
}

ComPtr<IDXGIAdapter1> PickIntelAdapter()
{
    ComPtr<IDXGIFactory4> factory;
    if (FAILED(CreateDXGIFactory2(0, IID_PPV_ARGS(&factory)))) return nullptr;
    for (UINT i = 0;; ++i)
    {
        ComPtr<IDXGIAdapter1> adapter;
        if (factory->EnumAdapters1(i, &adapter) == DXGI_ERROR_NOT_FOUND) break;
        DXGI_ADAPTER_DESC1 desc {};
        adapter->GetDesc1(&desc);
        if (desc.VendorId == 0x8086)
        {
            char name[128] {};
            for (int c = 0; c < 128 && desc.Description[c]; ++c) name[c] = static_cast<char>(desc.Description[c]);
            say("d3d12 adapter %u: %s (vendor %04x device %04x)", i, name, desc.VendorId, desc.DeviceId);
            return adapter;
        }
    }
    return nullptr;
}

bool CreateInstanceAndDevice(const LUID& luid)
{
    VkApplicationInfo app { VK_STRUCTURE_TYPE_APPLICATION_INFO };
    app.pApplicationName = "handshake_probe";
    app.apiVersion = VK_API_VERSION_1_3;
    VkInstanceCreateInfo ici { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
    ici.pApplicationInfo = &app;
    if (vkCreateInstance(&ici, nullptr, &g_instance) != VK_SUCCESS)
    {
        say("vkCreateInstance failed");
        return false;
    }

    uint32_t count = 0;
    vkEnumeratePhysicalDevices(g_instance, &count, nullptr);
    std::vector<VkPhysicalDevice> devices(count);
    vkEnumeratePhysicalDevices(g_instance, &count, devices.data());

    for (auto d : devices)
    {
        VkPhysicalDeviceIDProperties id { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES };
        VkPhysicalDeviceProperties2 props { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
        props.pNext = &id;
        vkGetPhysicalDeviceProperties2(d, &props);
        if (id.deviceLUIDValid && std::memcmp(id.deviceLUID, &luid, sizeof luid) == 0)
        {
            g_physical = d;
            say("vulkan device: %s (vendor %04x device %04x, api %u.%u)", props.properties.deviceName,
                props.properties.vendorID, props.properties.deviceID,
                VK_VERSION_MAJOR(props.properties.apiVersion), VK_VERSION_MINOR(props.properties.apiVersion));
            break;
        }
    }
    if (g_physical == VK_NULL_HANDLE)
    {
        say("no vulkan device has the d3d12 adapter's LUID");
        return false;
    }

    uint32_t families = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(g_physical, &families, nullptr);
    std::vector<VkQueueFamilyProperties> qf(families);
    vkGetPhysicalDeviceQueueFamilyProperties(g_physical, &families, qf.data());
    for (uint32_t i = 0; i < families; ++i)
        if ((qf[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) && (qf[i].queueFlags & VK_QUEUE_COMPUTE_BIT))
        {
            g_family = i;
            break;
        }

    VkPhysicalDeviceVulkan12Features f12 { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES };
    f12.timelineSemaphore = VK_TRUE;
    const char* ext[] = { VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME,
                          VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME };
    const float priority = 1.0f;
    VkDeviceQueueCreateInfo qi { VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
    qi.queueFamilyIndex = g_family;
    qi.queueCount = 1;
    qi.pQueuePriorities = &priority;
    VkDeviceCreateInfo ci { VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
    ci.pNext = &f12;
    ci.queueCreateInfoCount = 1;
    ci.pQueueCreateInfos = &qi;
    ci.enabledExtensionCount = 2;
    ci.ppEnabledExtensionNames = ext;
    if (vkCreateDevice(g_physical, &ci, nullptr, &g_device) != VK_SUCCESS)
    {
        say("vkCreateDevice failed");
        return false;
    }
    vkGetDeviceQueue(g_device, g_family, 0, &g_queue);

    g_import = reinterpret_cast<PFN_vkImportSemaphoreWin32HandleKHR>(
        vkGetDeviceProcAddr(g_device, "vkImportSemaphoreWin32HandleKHR"));
    if (!g_import)
    {
        say("no vkImportSemaphoreWin32HandleKHR on the device");
        return false;
    }

    VkCommandPoolCreateInfo pool { VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
    pool.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
    pool.queueFamilyIndex = g_family;
    if (vkCreateCommandPool(g_device, &pool, nullptr, &g_pool) != VK_SUCCESS)
    {
        say("vkCreateCommandPool failed");
        return false;
    }

    VkPhysicalDeviceExternalSemaphoreInfo info { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO };
    VkSemaphoreTypeCreateInfo type { VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO };
    type.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE;
    info.pNext = &type;
    info.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT;
    VkExternalSemaphoreProperties sp { VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES };
    vkGetPhysicalDeviceExternalSemaphoreProperties(g_physical, &info, &sp);
    say("driver says a D3D12 fence is importable as a timeline semaphore: %s (exportable: %s)",
        (sp.externalSemaphoreFeatures & VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT) ? "yes" : "NO",
        (sp.externalSemaphoreFeatures & VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT) ? "yes" : "no");
    return true;
}

// The reference's import, as a separate function so the other one can be measured beside it.
VkSemaphore ImportTwoStep(HANDLE handle)
{
    VkSemaphoreTypeCreateInfo type { VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO };
    type.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE;
    VkSemaphoreCreateInfo ci { VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, &type };
    VkSemaphore s = VK_NULL_HANDLE;
    if (vkCreateSemaphore(g_device, &ci, nullptr, &s) != VK_SUCCESS) return VK_NULL_HANDLE;
    VkImportSemaphoreWin32HandleInfoKHR im { VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR };
    im.semaphore = s;
    im.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT;
    im.handle = handle;
    if (g_import(g_device, &im) != VK_SUCCESS)
    {
        vkDestroySemaphore(g_device, s, nullptr);
        return VK_NULL_HANDLE;
    }
    return s;
}

// What the host did before: the import chained onto the create.
VkSemaphore ImportAtCreate(HANDLE handle)
{
    VkSemaphoreTypeCreateInfo type { VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO };
    type.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE;
    VkImportSemaphoreWin32HandleInfoKHR im { VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR };
    im.pNext = &type;
    im.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT;
    im.handle = handle;
    VkSemaphoreCreateInfo ci { VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, &im };
    VkSemaphore s = VK_NULL_HANDLE;
    if (vkCreateSemaphore(g_device, &ci, nullptr, &s) != VK_SUCCESS) return VK_NULL_HANDLE;
    return s;
}

bool ShareFence(ID3D12Device* d3d, ComPtr<ID3D12Fence>* out, HANDLE* handle)
{
    ComPtr<ID3D12Fence> fence;
    if (FAILED(d3d->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fence)))) return false;
    if (FAILED(d3d->CreateSharedHandle(fence.Get(), nullptr, GENERIC_ALL, nullptr, handle))) return false;
    *out = fence;
    return true;
}

// One case, one line each: what D3D12 signalled, what Vulkan made of it, whether the submit
// finished, and what D3D12 made of what Vulkan signalled back.
void RunCase(const char* name, ID3D12Device* d3d, ID3D12CommandQueue* queue, bool twoStep, bool useWait,
             bool recordBarrier, VkPipelineStageFlags stage)
{
    say("case %s:", name);

    ComPtr<ID3D12Fence> to;
    ComPtr<ID3D12Fence> from;
    HANDLE toHandle = nullptr;
    HANDLE fromHandle = nullptr;
    if (!ShareFence(d3d, &to, &toHandle) || !ShareFence(d3d, &from, &fromHandle))
    {
        say("   could not share the fences");
        return;
    }
    VkSemaphore toSem = twoStep ? ImportTwoStep(toHandle) : ImportAtCreate(toHandle);
    VkSemaphore fromSem = twoStep ? ImportTwoStep(fromHandle) : ImportAtCreate(fromHandle);
    CloseHandle(toHandle);
    CloseHandle(fromHandle);
    if (!toSem || !fromSem)
    {
        say("   the fences could not be imported");
        return;
    }

    // The D3D12 half first, and waited for from the CPU so that the value is not merely
    // queued but reached. Without this the Vulkan wait below could be blamed for a signal
    // the GPU had not run yet.
    UINT64 value = 0;
    if (useWait)
    {
        value = 1;
        if (FAILED(queue->Signal(to.Get(), value)))
        {
            say("   d3d12 Signal failed");
            return;
        }
        HANDLE ev = CreateEventW(nullptr, FALSE, FALSE, nullptr);
        to->SetEventOnCompletion(value, ev);
        const DWORD w = WaitForSingleObject(ev, 5000);
        CloseHandle(ev);
        if (w != WAIT_OBJECT_0)
        {
            say("   d3d12 never reached the value it signalled -- the queue itself is not running");
            return;
        }
    }

    uint64_t seen = UINT64_MAX;
    const VkResult gr = vkGetSemaphoreCounterValue(g_device, toSem, &seen);
    if (useWait)
        say("   d3d12 signalled %llu; vulkan reads %s", (unsigned long long) value,
            gr == VK_SUCCESS ? std::to_string(seen).c_str() : "unreadable");

    VkCommandBuffer cmd = VK_NULL_HANDLE;
    VkCommandBufferAllocateInfo ai { VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
    ai.commandPool = g_pool;
    ai.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    ai.commandBufferCount = 1;
    if (vkAllocateCommandBuffers(g_device, &ai, &cmd) != VK_SUCCESS)
    {
        say("   no command buffer");
        return;
    }
    VkCommandBufferBeginInfo bi { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    bi.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(cmd, &bi);
    if (recordBarrier)
        vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
                             0, 0, nullptr, 0, nullptr, 0, nullptr);
    vkEndCommandBuffer(cmd);

    const uint64_t signalValue = 1;
    VkTimelineSemaphoreSubmitInfo ts { VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO };
    VkSubmitInfo si { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    si.pNext = &ts;
    si.commandBufferCount = 1;
    si.pCommandBuffers = &cmd;
    si.signalSemaphoreCount = 1;
    si.pSignalSemaphores = &fromSem;
    ts.signalSemaphoreValueCount = 1;
    ts.pSignalSemaphoreValues = &signalValue;
    if (useWait)
    {
        si.waitSemaphoreCount = 1;
        si.pWaitSemaphores = &toSem;
        si.pWaitDstStageMask = &stage;
        ts.waitSemaphoreValueCount = 1;
        ts.pWaitSemaphoreValues = &value;
    }

    VkFence done = VK_NULL_HANDLE;
    VkFenceCreateInfo fi { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
    vkCreateFence(g_device, &fi, nullptr, &done);

    const VkResult sr = vkQueueSubmit(g_queue, 1, &si, done);
    if (sr != VK_SUCCESS)
    {
        say("   vkQueueSubmit failed (%d)", static_cast<int>(sr));
        return;
    }

    const VkResult wr = vkWaitForFences(g_device, 1, &done, VK_TRUE, 2000000000ull);
    say("   vulkan submit %s%s", wr == VK_SUCCESS ? "finished" : "DID NOT FINISH in 2s",
        useWait ? (wr == VK_SUCCESS ? " (the wait was satisfied)" : " (the wait was never satisfied)") : "");

    const UINT64 back = from->GetCompletedValue();
    say("   vulkan signalled %llu into the other fence; d3d12 reads %llu", (unsigned long long) signalValue,
        (unsigned long long) back);

    vkDestroyFence(g_device, done, nullptr);
    vkFreeCommandBuffers(g_device, g_pool, 1, &cmd);
    vkDestroySemaphore(g_device, toSem, nullptr);
    vkDestroySemaphore(g_device, fromSem, nullptr);
}

}  // namespace

int main()
{
    say("handshake probe: which half of the D3D12 <-> Vulkan hand-over does this adapter do?");

    ComPtr<IDXGIAdapter1> adapter = PickIntelAdapter();
    if (!adapter)
    {
        say("no Intel adapter");
        return 2;
    }
    ComPtr<ID3D12Device> d3d;
    if (FAILED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&d3d))))
    {
        say("D3D12CreateDevice failed");
        return 2;
    }
    const LUID luid = d3d->GetAdapterLuid();
    say("d3d12 LUID %08lx%08lx", (unsigned long) luid.HighPart, (unsigned long) luid.LowPart);

    D3D12_COMMAND_QUEUE_DESC qd {};
    qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    ComPtr<ID3D12CommandQueue> queue;
    if (FAILED(d3d->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue))))
    {
        say("CreateCommandQueue failed");
        return 2;
    }

    if (!CreateInstanceAndDevice(luid)) return 2;

    const VkPipelineStageFlags all = VK_PIPELINE_STAGE_ALL_COMMANDS_BIT;
    const VkPipelineStageFlags top = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;

    say("");
    RunCase("A  two-step import, wait, empty command buffer", d3d.Get(), queue.Get(), true, true, false, all);
    say("");
    RunCase("B  import at create, wait, empty command buffer", d3d.Get(), queue.Get(), false, true, false, all);
    say("");
    RunCase("C  two-step import, wait, barrier recorded", d3d.Get(), queue.Get(), true, true, true, all);
    say("");
    RunCase("D  two-step import, wait at TOP_OF_PIPE", d3d.Get(), queue.Get(), true, true, false, top);
    say("");
    RunCase("E  two-step import, no wait: signal only", d3d.Get(), queue.Get(), true, false, false, all);
    say("");
    say("read the last line of each case: if vulkan reads the value d3d12 signalled and the submit");
    say("still does not finish, the wait is the half that fails. If vulkan reads 0, the import never");
    say("shared the fence at all.");
    return 0;
}
