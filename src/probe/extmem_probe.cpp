// Can the A770 carry the bridge?
//
// The bridge that costs the least is the one nothing crosses the CPU in: the game's D3D12
// textures are created as shared resources and imported into a Vulkan device of our own on
// the same adapter, and the two sides are ordered on the GPU by a shared D3D12 fence
// imported as a Vulkan timeline semaphore. Whether that is possible at all is a question
// about the driver, not about the game, so it is asked here, in a process of its own, before
// a line of it goes into the host.
//
// The order of the questions and the shape of each answer are taken from the reference
// bridge, refs/optiscaler/src/windows/pe/nr_pe_bridge.cpp:
//   Device::create      169-229   instance, the LUID match, the required extensions
//   Device::external_ok 360-374   whether a format can be imported at all
//   Device::import_image 416-467  the import itself
//   Device::import_fence          a shared D3D12 fence as a timeline semaphore
//
// What differs, and only this: the extensions. The reference's list
// (nr_pe_bridge.cpp:50-56) carries VK_KHR_cooperative_matrix and VK_EXT_shader_float8 for
// its network, which is not ours. Here the list is the external-memory pair plus timeline
// semaphores, which is what the hand-over itself needs.
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <dxgi1_4.h>
#include <d3d12.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <wrl/client.h>

using Microsoft::WRL::ComPtr;

namespace {

struct Candidate {
    const char* name;
    DXGI_FORMAT dxgi;
    VkFormat vk;
    UINT bytes;
};

// The formats the neural pass would actually be handed: LOP gives R11G11B10_FLOAT colour,
// R16G16_FLOAT motion and a depth it reads as one float per texel.
const Candidate kCandidates[] = {
    { "R8G8B8A8_UNORM", DXGI_FORMAT_R8G8B8A8_UNORM, VK_FORMAT_R8G8B8A8_UNORM, 4 },
    { "R16G16_FLOAT", DXGI_FORMAT_R16G16_FLOAT, VK_FORMAT_R16G16_SFLOAT, 4 },
    { "R11G11B10_FLOAT", DXGI_FORMAT_R11G11B10_FLOAT, VK_FORMAT_B10G11R11_UFLOAT_PACK32, 4 },
    { "R32_FLOAT", DXGI_FORMAT_R32_FLOAT, VK_FORMAT_R32_SFLOAT, 4 },
};

const char* const kExtensions[] = {
    VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME,
    VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME,
    VK_KHR_TIMELINE_SEMAPHORE_EXTENSION_NAME,
};

int failures = 0;

void say(const char* fmt, ...)
{
    va_list a;
    va_start(a, fmt);
    std::vprintf(fmt, a);
    va_end(a);
    std::putchar('\n');
    std::fflush(stdout);
}

void fail(const char* what)
{
    ++failures;
    say("   FAIL %s", what);
}

// ---------------------------------------------------------------- D3D12 side

ComPtr<IDXGIAdapter1> PickIntelAdapter()
{
    ComPtr<IDXGIFactory4> factory;
    if (FAILED(CreateDXGIFactory2(0, IID_PPV_ARGS(&factory)))) {
        fail("CreateDXGIFactory2");
        return {};
    }
    ComPtr<IDXGIAdapter1> found;
    for (UINT i = 0;; ++i) {
        ComPtr<IDXGIAdapter1> a;
        if (factory->EnumAdapters1(i, &a) == DXGI_ERROR_NOT_FOUND) break;
        DXGI_ADAPTER_DESC1 d {};
        if (FAILED(a->GetDesc1(&d))) continue;
        char narrow[256] {};
        for (int c = 0; c < 255 && d.Description[c]; ++c) narrow[c] = (char) d.Description[c];
        say("   adapter %u: vendor 0x%04x device 0x%04x  %s", i, d.VendorId, d.DeviceId, narrow);
        // 0x8086 is Intel, and the A770 is the card the game renders on here.
        if (!found && d.VendorId == 0x8086) found = a;
    }
    if (!found) fail("no Intel adapter");
    return found;
}

// ---------------------------------------------------------------- Vulkan side

VkInstance g_instance {};
VkPhysicalDevice g_physical {};
VkDevice g_device {};
VkPhysicalDeviceMemoryProperties g_memory {};
PFN_vkGetMemoryWin32HandlePropertiesKHR g_handle_properties {};

bool CreateInstance()
{
    uint32_t api = 0;
    if (vkEnumerateInstanceVersion(&api) != VK_SUCCESS || api < VK_API_VERSION_1_3) {
        fail("the Vulkan loader is older than 1.3");
        return false;
    }
    VkApplicationInfo app { VK_STRUCTURE_TYPE_APPLICATION_INFO };
    app.pApplicationName = "extmem-probe";
    app.apiVersion = VK_API_VERSION_1_3;
    VkInstanceCreateInfo ici { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
    ici.pApplicationInfo = &app;
    if (vkCreateInstance(&ici, nullptr, &g_instance) != VK_SUCCESS) {
        fail("vkCreateInstance");
        return false;
    }
    return true;
}

bool PickByLuid(const LUID& luid)
{
    uint32_t count = 0;
    vkEnumeratePhysicalDevices(g_instance, &count, nullptr);
    std::vector<VkPhysicalDevice> devices(count);
    vkEnumeratePhysicalDevices(g_instance, &count, devices.data());
    for (VkPhysicalDevice pd : devices) {
        VkPhysicalDeviceIDProperties id { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES };
        VkPhysicalDeviceProperties2 p { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 };
        p.pNext = &id;
        vkGetPhysicalDeviceProperties2(pd, &p);
        say("   vulkan: %s (api %u.%u.%u) luid %s", p.properties.deviceName,
            VK_API_VERSION_MAJOR(p.properties.apiVersion), VK_API_VERSION_MINOR(p.properties.apiVersion),
            VK_API_VERSION_PATCH(p.properties.apiVersion), id.deviceLUIDValid ? "valid" : "absent");
        if (id.deviceLUIDValid && std::memcmp(id.deviceLUID, &luid, sizeof luid) == 0) {
            g_physical = pd;
            return true;
        }
    }
    fail("no Vulkan device has the D3D12 adapter's LUID");
    return false;
}

bool CreateDevice()
{
    uint32_t n = 0;
    vkEnumerateDeviceExtensionProperties(g_physical, nullptr, &n, nullptr);
    std::vector<VkExtensionProperties> have(n);
    vkEnumerateDeviceExtensionProperties(g_physical, nullptr, &n, have.data());
    for (const char* e : kExtensions) {
        bool found = false;
        for (const auto& h : have) found = found || std::strcmp(h.extensionName, e) == 0;
        say("   %-40s %s", e, found ? "present" : "MISSING");
        if (!found) {
            fail("the driver lacks a required extension");
            return false;
        }
    }

    VkPhysicalDeviceVulkan12Features f12 { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES };
    VkPhysicalDeviceVulkan13Features f13 { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_3_FEATURES };
    f12.pNext = &f13;
    VkPhysicalDeviceFeatures2 supported { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2, &f12 };
    vkGetPhysicalDeviceFeatures2(g_physical, &supported);
    say("   timelineSemaphore %s, synchronization2 %s", f12.timelineSemaphore ? "yes" : "NO",
        f13.synchronization2 ? "yes" : "no");
    if (!f12.timelineSemaphore) {
        fail("no timeline semaphores: the shared fence cannot be imported");
        return false;
    }

    const float priority = 1.0f;
    VkDeviceQueueCreateInfo qi { VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
    qi.queueFamilyIndex = 0;
    qi.queueCount = 1;
    qi.pQueuePriorities = &priority;
    VkDeviceCreateInfo di { VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, &f12 };
    di.queueCreateInfoCount = 1;
    di.pQueueCreateInfos = &qi;
    di.enabledExtensionCount = (uint32_t) (sizeof kExtensions / sizeof kExtensions[0]);
    di.ppEnabledExtensionNames = kExtensions;
    if (vkCreateDevice(g_physical, &di, nullptr, &g_device) != VK_SUCCESS) {
        fail("vkCreateDevice");
        return false;
    }
    vkGetPhysicalDeviceMemoryProperties(g_physical, &g_memory);
    g_handle_properties = reinterpret_cast<PFN_vkGetMemoryWin32HandlePropertiesKHR>(
        vkGetDeviceProcAddr(g_device, "vkGetMemoryWin32HandlePropertiesKHR"));
    if (!g_handle_properties) fail("vkGetMemoryWin32HandlePropertiesKHR does not resolve");
    return g_handle_properties != nullptr;
}

// nr_pe_bridge.cpp:360-374: ask before importing, because the answer is a property of the
// format as much as of the driver.
bool ExternalOk(VkFormat format, VkImageUsageFlags usage, bool* dedicated)
{
    VkPhysicalDeviceExternalImageFormatInfo ext {
        VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO };
    ext.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT;
    VkPhysicalDeviceImageFormatInfo2 info { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2 };
    info.pNext = &ext;
    info.format = format;
    info.type = VK_IMAGE_TYPE_2D;
    info.tiling = VK_IMAGE_TILING_OPTIMAL;
    info.usage = usage;
    VkExternalImageFormatProperties ep { VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES };
    VkImageFormatProperties2 props { VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2 };
    props.pNext = &ep;
    if (vkGetPhysicalDeviceImageFormatProperties2(g_physical, &info, &props) != VK_SUCCESS) return false;
    const auto f = ep.externalMemoryProperties.externalMemoryFeatures;
    *dedicated = (f & VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT) != 0;
    return (f & VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT) != 0;
}

uint32_t MemoryType(uint32_t bits)
{
    for (uint32_t i = 0; i < g_memory.memoryTypeCount; ++i)
        if ((bits >> i) & 1u) return i;
    return UINT32_MAX;
}

// nr_pe_bridge.cpp:416-467: the import itself.
bool ImportImage(HANDLE handle, uint32_t width, uint32_t height, VkFormat format, bool storage,
                 VkImage* image, VkDeviceMemory* memory)
{
    VkExternalMemoryImageCreateInfo ext { VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO };
    ext.handleTypes = VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT;
    VkImageCreateInfo ci { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
    ci.pNext = &ext;
    ci.imageType = VK_IMAGE_TYPE_2D;
    ci.format = format;
    ci.extent = { width, height, 1 };
    ci.mipLevels = 1;
    ci.arrayLayers = 1;
    ci.samples = VK_SAMPLE_COUNT_1_BIT;
    ci.tiling = VK_IMAGE_TILING_OPTIMAL;
    ci.usage = VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT |
               VK_IMAGE_USAGE_SAMPLED_BIT | (storage ? VK_IMAGE_USAGE_STORAGE_BIT : 0);
    ci.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    if (vkCreateImage(g_device, &ci, nullptr, image) != VK_SUCCESS) {
        fail("vkCreateImage");
        return false;
    }

    VkMemoryWin32HandlePropertiesKHR hp { VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR };
    VkResult pr = g_handle_properties(g_device, VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT,
                                      handle, &hp);
    if (pr != VK_SUCCESS) {
        fail("vkGetMemoryWin32HandlePropertiesKHR");
        return false;
    }
    uint32_t index = MemoryType(hp.memoryTypeBits);
    if (index == UINT32_MAX) {
        fail("no memory type accepts the handle");
        return false;
    }

    VkMemoryRequirements req {};
    vkGetImageMemoryRequirements(g_device, *image, &req);
    VkMemoryDedicatedAllocateInfo dedicated { VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO };
    dedicated.image = *image;
    VkImportMemoryWin32HandleInfoKHR import { VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR };
    import.pNext = &dedicated;
    import.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT;
    import.handle = handle;
    VkMemoryAllocateInfo alloc { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    alloc.pNext = &import;
    alloc.allocationSize = req.size;
    alloc.memoryTypeIndex = index;
    VkResult r = vkAllocateMemory(g_device, &alloc, nullptr, memory);
    if (r != VK_SUCCESS) {
        fail("vkAllocateMemory (import)");
        return false;
    }
    r = vkBindImageMemory(g_device, *image, *memory, 0);
    if (r != VK_SUCCESS) fail("vkBindImageMemory");
    say("   imported: %u x %u, %llu bytes, memory type %u", width, height,
        (unsigned long long) req.size, index);
    return r == VK_SUCCESS;
}

}  // namespace

int main()
{
    say("extmem probe: can a D3D12 resource on this adapter be imported into a Vulkan device?");

    // ---- the D3D12 device on the Intel adapter, and the LUID that names it
    ComPtr<IDXGIAdapter1> adapter = PickIntelAdapter();
    if (!adapter) return 2;
    ComPtr<ID3D12Device> d3d;
    if (FAILED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_12_1, IID_PPV_ARGS(&d3d)))) {
        fail("D3D12CreateDevice");
        return 2;
    }
    const LUID luid = d3d->GetAdapterLuid();
    say("   d3d12 device: LUID %08lx%08lx", (unsigned long) luid.HighPart, (unsigned long) luid.LowPart);

    // ---- our own Vulkan device on the same adapter
    if (!CreateInstance()) return 2;
    if (!PickByLuid(luid)) return 2;
    if (!CreateDevice()) return 2;
    say("   vulkan device created on the same adapter");

    // ---- which of the formats the pass would be handed can be imported
    say("   importable formats (usage TRANSFER|SAMPLED|STORAGE):");
    std::vector<const Candidate*> ok;
    for (const Candidate& c : kCandidates) {
        bool dedicated = false;
        const bool importable = ExternalOk(c.vk, VK_IMAGE_USAGE_TRANSFER_SRC_BIT |
                                                      VK_IMAGE_USAGE_TRANSFER_DST_BIT |
                                                      VK_IMAGE_USAGE_SAMPLED_BIT |
                                                      VK_IMAGE_USAGE_STORAGE_BIT, &dedicated);
        say("     %-18s %s%s", c.name, importable ? "importable" : "no",
            dedicated ? " (dedicated only)" : "");
        if (importable) ok.push_back(&c);
    }
    if (ok.empty()) fail("no format the pass needs can be imported");

    // ---- one real hand-over: share a D3D12 texture, import it
    if (!ok.empty()) {
        const uint32_t w = 960, h = 540;
        for (const Candidate* c : ok) {
            D3D12_HEAP_PROPERTIES heap {};
            heap.Type = D3D12_HEAP_TYPE_DEFAULT;
            D3D12_RESOURCE_DESC desc {};
            desc.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
            desc.Width = w;
            desc.Height = h;
            desc.DepthOrArraySize = 1;
            desc.MipLevels = 1;
            desc.Format = c->dxgi;
            desc.SampleDesc.Count = 1;
            desc.Layout = D3D12_TEXTURE_LAYOUT_UNKNOWN;
            desc.Flags = D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;
            ComPtr<ID3D12Resource> resource;
            HRESULT hr = d3d->CreateCommittedResource(&heap, D3D12_HEAP_FLAG_SHARED, &desc,
                                                     D3D12_RESOURCE_STATE_COMMON, nullptr,
                                                     IID_PPV_ARGS(&resource));
            if (FAILED(hr)) {
                fail("CreateCommittedResource (shared)");
                continue;
            }
            HANDLE handle = nullptr;
            hr = d3d->CreateSharedHandle(resource.Get(), nullptr, GENERIC_ALL, nullptr, &handle);
            if (FAILED(hr) || !handle) {
                fail("CreateSharedHandle");
                continue;
            }
            say("   %s:", c->name);
            VkImage image {};
            VkDeviceMemory memory {};
            if (ImportImage(handle, w, h, c->vk, true, &image, &memory)) {
                vkFreeMemory(g_device, memory, nullptr);
                vkDestroyImage(g_device, image, nullptr);
            }
            CloseHandle(handle);
        }
    }

    // ---- the other half of the hand-over: a shared D3D12 fence as a timeline semaphore
    ComPtr<ID3D12Fence> fence;
    if (SUCCEEDED(d3d->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&fence)))) {
        HANDLE handle = nullptr;
        if (SUCCEEDED(d3d->CreateSharedHandle(fence.Get(), nullptr, GENERIC_ALL, nullptr, &handle)) &&
            handle) {
            VkSemaphoreTypeCreateInfo type { VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO };
            type.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE;
            type.initialValue = 0;
            VkImportSemaphoreWin32HandleInfoKHR import {
                VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR };
            import.pNext = &type;
            import.semaphore = VK_NULL_HANDLE;
            import.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT;
            import.handle = handle;
            VkSemaphore semaphore {};
            VkSemaphoreCreateInfo ci { VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, &import };
            if (vkCreateSemaphore(g_device, &ci, nullptr, &semaphore) == VK_SUCCESS) {
                say("   shared D3D12 fence -> timeline semaphore: ok");
                vkDestroySemaphore(g_device, semaphore, nullptr);
            } else {
                fail("the shared fence could not be imported as a timeline semaphore");
            }
            CloseHandle(handle);
        } else {
            fail("CreateSharedHandle (fence)");
        }
    } else {
        fail("CreateFence (shared)");
    }

    say(failures ? "RESULT: the bridge cannot be built here as it stands"
                 : "RESULT: the bridge's hand-over works on this adapter");
    return failures ? 1 : 0;
}
