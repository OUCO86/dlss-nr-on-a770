// probe_vk_l0_import.cpp -- GATE: Vulkan-exported OPAQUE_WIN32 memory imported by Level
// Zero on the SAME A770, then data both directions bit-exact. Section 58's next step:
// the host-bounce scaffold died on the window-block arena wall (V1/V2 controls, no L0
// involved), so P1/P2 must share ONE allocation across the two engines -- the shipped
// runtime already makes exportable Vulkan buffers (xmxres buf_create_exportable / libxmx
// xmx_buf_exported) and my chain runs in-process on Level Zero (libxmx_sycl). This proves
// the two legs alias the same memory, the direction the D3D12 probe proved for D3D12
// (section 18, probe_d3d12_ze.cpp -- its L0-side forms are copied from there verbatim).
//
// Why no Vulkan buffer/queue/semaphore here: one variable is "can the two APIs alias ONE
// allocation and read each other's writes". The Vulkan leg is only vkAllocateMemory
// (host-visible|host-coherent|device-local, exactly this box's type 3 per the daemon log
// "buffers in card memory: type 3, DEVICE_LOCAL HOST_VISIBLE HOST_COHERENT") + vkMapMemory.
// All movement happens on the L0 side (AppendMemoryCopy + hostSynchronize), which is what
// my SYCL kernels actually do with the pointer. If even THIS aliases wrong, the shared-
// buffer route is dead and P1 must fall back to per-buffer host copies; if it is bit-exact
// both ways, P1's dual-engine wiring is legal.
//
// Section 18's hard lessons baked in:
//   * ask the DEDICATED capability getter (zeDeviceGetExternalMemoryProperties), not a
//     pNext bolt-on -- the pNext route returned 0x0 on this driver and nearly mis-scoped it.
//   * both legs must name the SAME physical card: vendor 0x8086 device 0x56a0 (A770), and
//     the L0 leg must also require type==GPU (not the iGPU), like libxmx_sycl's xmx_init.
#include <level_zero/ze_api.h>
#include <windows.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>
#include <cstdio>
#include <cstring>
#include <vector>
#include <cstdint>

static int g_fails = 0;
#define OKAY(cond, msg, ...) do { if (!(cond)) { ++g_fails; std::printf("FAIL  " msg "\n", ##__VA_ARGS__); } \
                                  else { std::printf("ok    " msg "\n", ##__VA_ARGS__); } } while (0)

static const uint64_t RES_BYTES = 16ull << 20;   // the 16 MB floor the seniors use

// ---------------- Vulkan leg ----------------
static VkInstance   g_inst = VK_NULL_HANDLE;
static VkPhysicalDevice g_pd = VK_NULL_HANDLE;
static VkDevice     g_dev  = VK_NULL_HANDLE;
static VkDeviceMemory g_mem = VK_NULL_HANDLE;
static void*        g_map  = nullptr;
static HANDLE       g_handle = nullptr;

static bool make_vk()
{
    VkInstanceCreateInfo ici{ VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
    const char* iext[] = { "VK_KHR_get_physical_device_properties2",
                           "VK_KHR_external_memory_capabilities" };
    ici.enabledExtensionCount = 2; ici.ppEnabledExtensionNames = iext;
    if (vkCreateInstance(&ici, nullptr, &g_inst) != VK_SUCCESS) {
        std::printf("FAIL vkCreateInstance (loader? no ICD?)\n"); return false;
    }
    uint32_t npd = 0; vkEnumeratePhysicalDevices(g_inst, &npd, nullptr);
    std::vector<VkPhysicalDevice> all(npd);
    vkEnumeratePhysicalDevices(g_inst, &npd, all.data());
    for (auto p : all) {
        VkPhysicalDeviceProperties pr; vkGetPhysicalDeviceProperties(p, &pr);
        std::printf("vk device: %s vendor 0x%x device 0x%x\n", pr.deviceName, pr.vendorID, pr.deviceID);
        if (pr.vendorID == 0x8086 && pr.deviceID == 0x56a0) g_pd = p;
    }
    if (!g_pd) { std::printf("no A770 on the Vulkan side\n"); return false; }

    const char* dext[] = { "VK_KHR_external_memory_win32" };
    VkDeviceCreateInfo dci{ VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
    dci.enabledExtensionCount = 1; dci.ppEnabledExtensionNames = dext;
    // a queue is not used, but a device must be created with >=0 queues; a single family
    // with priority 0 keeps it minimal yet valid.
    uint32_t nq = 0; vkGetPhysicalDeviceQueueFamilyProperties(g_pd, &nq, nullptr);
    std::vector<VkDeviceQueueCreateInfo> qis;
    float prio = 0.0f;
    if (nq) {
        VkDeviceQueueCreateInfo qi{ VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
        qi.queueFamilyIndex = 0; qi.queueCount = 1; qi.pQueuePriorities = &prio;
        qis.push_back(qi);
        dci.queueCreateInfoCount = (uint32_t)qis.size(); dci.pQueueCreateInfos = qis.data();
    }
    if (vkCreateDevice(g_pd, &dci, nullptr, &g_dev) != VK_SUCCESS) {
        std::printf("FAIL vkCreateDevice (external_memory_win32 unsupported?)\n"); return false;
    }

    // buffer-level external-memory capability query (the correct one for a plain
    // allocation; the host-pointer struct is a different feature entirely -- the field
    // names I first guessed belong to it). Print the mask and require EXPORTABLE.
    VkPhysicalDeviceExternalBufferInfo ebi{ VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO };
    ebi.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT;
    VkExternalBufferProperties ebp{ VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES };
    PFN_vkGetPhysicalDeviceExternalBufferProperties getEBP =
        (PFN_vkGetPhysicalDeviceExternalBufferProperties)
        vkGetInstanceProcAddr(g_inst, "vkGetPhysicalDeviceExternalBufferProperties");
    if (getEBP) getEBP(g_pd, &ebi, &ebp);
    std::printf("vk OPAQUE_WIN32 buffer: features=0x%x exportFromImported=0x%x compatible=0x%x\n",
                (unsigned)ebp.externalMemoryProperties.externalMemoryFeatures,
                (unsigned)ebp.externalMemoryProperties.exportFromImportedHandleTypes,
                (unsigned)ebp.externalMemoryProperties.compatibleHandleTypes);
    if (!(ebp.externalMemoryProperties.externalMemoryFeatures & VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT))
        std::printf("  NOTE: driver did not list EXPORTABLE for this usage; proceeding anyway -- "
                    "vkAllocateMemory will be the real answer\n");

    // pick a memory type that is device-local AND host-visible AND host-coherent (this
    // box's type 3) AND listed by the export-capable mask above.
    VkPhysicalDeviceMemoryProperties mp{};
    vkGetPhysicalDeviceMemoryProperties(g_pd, &mp);
    uint32_t want = VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
                  | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    int idx = -1;
    for (uint32_t i = 0; i < mp.memoryTypeCount; ++i) {
        if ((mp.memoryTypes[i].propertyFlags & want) == want) { idx = (int)i; break; }
    }
    if (idx < 0) { std::printf("no device-local+host-visible+coherent memory type\n"); return false; }
    std::printf("chosen vk memory type %d (flags 0x%x)\n", idx,
                (unsigned)mp.memoryTypes[idx].propertyFlags);

    VkExportMemoryAllocateInfo exp{ VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO };
    exp.handleTypes = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT;
    VkMemoryAllocateInfo ai{ VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    ai.pNext = &exp;
    ai.allocationSize = RES_BYTES; ai.memoryTypeIndex = (uint32_t)idx;
    if (vkAllocateMemory(g_dev, &ai, nullptr, &g_mem) != VK_SUCCESS) {
        std::printf("FAIL vkAllocateMemory (exportable)\n"); return false;
    }
    // repo-local vulkan-1.lib has no win32 KHR import symbols (libxmx.c:1462 solved it:
    // ask the loader at runtime). Copy that precedent exactly.
    PFN_vkGetMemoryWin32HandleKHR getHandle = (PFN_vkGetMemoryWin32HandleKHR)
        vkGetDeviceProcAddr(g_dev, "vkGetMemoryWin32HandleKHR");
    if (!getHandle) { std::printf("FAIL: loader lacks vkGetMemoryWin32HandleKHR\n"); return false; }
    VkMemoryGetWin32HandleInfoKHR hi{ VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR };
    hi.memory = g_mem; hi.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT;
    if (getHandle(g_dev, &hi, &g_handle) != VK_SUCCESS || !g_handle) {
        std::printf("FAIL vkGetMemoryWin32HandleKHR\n"); return false;
    }
    if (vkMapMemory(g_dev, g_mem, 0, RES_BYTES, 0, &g_map) != VK_SUCCESS || !g_map) {
        std::printf("FAIL vkMapMemory\n"); return false;
    }
    return true;
}

// ---------------- Level Zero leg ----------------
static ze_driver_handle_t g_zdrv = nullptr;
static ze_device_handle_t g_zdev = nullptr;
static ze_context_handle_t g_zctx = nullptr;
static ze_command_queue_handle_t g_zq = nullptr;
static ze_command_list_handle_t g_zcl = nullptr;

static bool make_l0()
{
    if (zeInit(ZE_INIT_FLAG_GPU_ONLY) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeInit\n"); return false; }
    uint32_t nd = 0; zeDriverGet(&nd, nullptr);
    std::vector<ze_driver_handle_t> ds(nd); zeDriverGet(&nd, ds.data());
    for (uint32_t i = 0; i < nd && !g_zdev; ++i) {
        uint32_t m = 0; zeDeviceGet(ds[i], &m, nullptr);
        std::vector<ze_device_handle_t> dd(m); zeDeviceGet(ds[i], &m, dd.data());
        for (uint32_t j = 0; j < m; ++j) {
            ze_device_properties_t p = { ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES };
            zeDeviceGetProperties(dd[j], &p);
            if (p.type == ZE_DEVICE_TYPE_GPU && p.vendorId == 0x8086) {
                std::printf("l0 device: %s (0x%x:0x%x)\n", p.name, p.vendorId, p.deviceId);
                g_zdrv = ds[i]; g_zdev = dd[j]; break;
            }
        }
    }
    if (!g_zdev) { std::printf("no Intel GPU in L0\n"); return false; }
    ze_context_desc_t cd = { ZE_STRUCTURE_TYPE_CONTEXT_DESC };
    if (zeContextCreate(g_zdrv, &cd, &g_zctx) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeContextCreate\n"); return false; }
    ze_command_queue_desc_t qd = { ZE_STRUCTURE_TYPE_COMMAND_QUEUE_DESC, nullptr, 0, 0, 0,
                                   ZE_COMMAND_QUEUE_MODE_DEFAULT, ZE_COMMAND_QUEUE_PRIORITY_NORMAL };
    if (zeCommandQueueCreate(g_zctx, g_zdev, &qd, &g_zq) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeCommandQueueCreate\n"); return false; }
    if (zeCommandListCreateImmediate(g_zctx, g_zdev, &qd, &g_zcl) != ZE_RESULT_SUCCESS) { std::printf("FAIL zeCommandListCreateImmediate\n"); return false; }
    return true;
}

static void fill_pat(uint32_t* a, uint64_t n, uint32_t seed) {
    for (uint64_t i = 0; i < n / 4; ++i) a[i] = seed + (uint32_t)i * 2654435761u;
}
static int cmp_pat(const uint32_t* got, const uint32_t* want, uint64_t n, const char* what) {
    uint64_t bad = 0, first = 0;
    for (uint64_t i = 0; i < n / 4; ++i) if (got[i] != want[i]) { if (!bad) first = i; ++bad; }
    if (bad) std::printf("  %s: %llu/%llu wrong (first idx %llu: got 0x%x want 0x%x)\n",
                         what, (unsigned long long)bad, (unsigned long long)(n / 4),
                         (unsigned long long)first, got[first], want[first]);
    return (int)bad;
}

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);       // crash-proof tracing (senior's rule)
    if (!make_vk()) { std::printf("=> GATE INCOMPLETE: %d\n", g_fails); return 1; }
    if (!make_l0()) { std::printf("=> GATE INCOMPLETE: %d\n", g_fails); return 1; }

    // GATE 0 (capability, dedicated getter -- section 18 lesson): must list OPAQUE_WIN32.
    ze_device_external_memory_properties_t emp = { ZE_STRUCTURE_TYPE_DEVICE_EXTERNAL_MEMORY_PROPERTIES };
    zeDeviceGetExternalMemoryProperties(g_zdev, &emp);
    std::printf("l0 external memory importTypes=0x%x exportTypes=0x%x\n",
                (unsigned)emp.memoryAllocationImportTypes,
                (unsigned)emp.memoryAllocationExportTypes);
    OKAY(emp.memoryAllocationImportTypes & ZE_EXTERNAL_MEMORY_TYPE_FLAG_OPAQUE_WIN32,
         "GATE 0 L0 advertises OPAQUE_WIN32 import (0x%x)",
         (unsigned)emp.memoryAllocationImportTypes);

    // GATE 1 import: the Vulkan OPAQUE_WIN32 NT handle -> an L0 device pointer.
    ze_external_memory_import_win32_handle_t mi = { ZE_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMPORT_WIN32 };
    mi.flags = ZE_EXTERNAL_MEMORY_TYPE_FLAG_OPAQUE_WIN32;
    mi.handle = g_handle; mi.name = nullptr;
    ze_device_mem_alloc_desc_t dad = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC };
    dad.pNext = &mi; dad.ordinal = 0;
    void* ptr = nullptr;
    ze_result_t r = zeMemAllocDevice(g_zctx, &dad, RES_BYTES, 256, g_zdev, &ptr);
    OKAY(r == ZE_RESULT_SUCCESS && ptr, "GATE 1 import: Vulkan OPAQUE_WIN32 -> L0 ptr (r=0x%x ptr=%p)",
         (unsigned)r, ptr);

    if (ptr) {
        ze_memory_allocation_properties_t ap = { ZE_STRUCTURE_TYPE_MEMORY_ALLOCATION_PROPERTIES };
        zeMemGetAllocProperties(g_zctx, ptr, &ap, nullptr);
        std::printf("      l0 alloc type=%d id=%llu pageSize=%llu\n", (int)ap.type,
                    (unsigned long long)ap.id, (unsigned long long)ap.pageSize);

        // V-b control 1 (isolation, C0 of section 18's shape): immediate-list copy on a
        // PLAIN alloc completes with SUCCESS -> the binary's immediate+sync combo is fine;
        // then the SAME combo on the imported alloc is the single variable.
        {
            ze_device_mem_alloc_desc_t plain = { ZE_STRUCTURE_TYPE_DEVICE_MEM_ALLOC_DESC };
            plain.ordinal = 0; void* pp = nullptr;
            ze_result_t pr = zeMemAllocDevice(g_zctx, &plain, 4096, 256, g_zdev, &pp);
            if (pr == ZE_RESULT_SUCCESS && pp) {
                uint32_t src[1024]; for (int i = 0; i < 1024; ++i) src[i] = 0x11223344u + i;
                ze_result_t ar = zeCommandListAppendMemoryCopy(g_zcl, pp, src, 4096, nullptr, 0, nullptr);
                ze_result_t sr = (ar == ZE_RESULT_SUCCESS) ? zeCommandListHostSynchronize(g_zcl, 2000000) : ar;
                OKAY(ar == ZE_RESULT_SUCCESS && sr == ZE_RESULT_SUCCESS,
                     "C0 plain alloc immediate copy+sync (append=0x%x sync=0x%x) [combo itself is fine]",
                     (unsigned)ar, (unsigned)sr);
                zeMemFree(g_zctx, pp);
            }
        }

        // GATE 2 (Vulkan wrote -> L0 reads): pattern written through vkMapMemory must be
        // visible bit-exact to an L0 AppendMemoryCopy (imported -> host staging).
        ze_command_list_handle_t dl = nullptr;
        (void)dl;
        ze_command_list_desc_t cld = { ZE_STRUCTURE_TYPE_COMMAND_LIST_DESC };
        cld.commandQueueGroupOrdinal = 0;     // the same group the queue was made on
        ze_result_t cr = zeCommandListCreate(g_zctx, g_zdev, &cld, &dl);
        if (cr != ZE_RESULT_SUCCESS || !dl) {
            OKAY(false, "deferred zeCommandListCreate (r=0x%x) -- gates skip", (unsigned)cr);
            goto skip_data;
        }
        uint32_t* vp = (uint32_t*)g_map;
        fill_pat(vp, RES_BYTES, 0xC0FFEE00u);
        std::vector<uint32_t> host(RES_BYTES / 4, 0);
        r = zeCommandListAppendMemoryCopy(dl, host.data(), ptr, RES_BYTES, nullptr, 0, nullptr);
        zeCommandListClose(dl);
        ze_result_t er = zeCommandQueueExecuteCommandLists(g_zq, 1, &dl, nullptr);
        ze_result_t sc = (er == ZE_RESULT_SUCCESS) ? zeCommandQueueSynchronize(g_zq, 2000000) : er;
        int bad2 = cmp_pat(host.data(), vp, RES_BYTES, "GATE 2 vk->l0");
        OKAY(r == ZE_RESULT_SUCCESS && sc == ZE_RESULT_SUCCESS && bad2 == 0,
             "GATE 2 (deferred) Vulkan write seen by L0 bit-exact (exec=0x%x qsync=0x%x wrong=%d)",
             (unsigned)er, (unsigned)sc, bad2);

        // GATE 3 (L0 wrote -> Vulkan reads): host->imported copy, then read through the
        // SAME Vulkan mapping. HOST_COHERENT should make it visible with no flush; if it
        // is not visible, that is a real finding (P1 would need explicit vkInvalidate).
        std::vector<uint32_t> src(RES_BYTES / 4, 0);
        fill_pat(src.data(), RES_BYTES, 0x12340000u);
        zeCommandListReset(dl);
        r = zeCommandListAppendMemoryCopy(dl, ptr, src.data(), RES_BYTES, nullptr, 0, nullptr);
        zeCommandListClose(dl);
        er = zeCommandQueueExecuteCommandLists(g_zq, 1, &dl, nullptr);
        sc = (er == ZE_RESULT_SUCCESS) ? zeCommandQueueSynchronize(g_zq, 2000000) : er;
        int bad3 = cmp_pat(vp, src.data(), RES_BYTES, "GATE 3 l0->vk");
        OKAY(r == ZE_RESULT_SUCCESS && sc == ZE_RESULT_SUCCESS && bad3 == 0,
             "GATE 3 (deferred) L0 write seen by Vulkan bit-exact (exec=0x%x qsync=0x%x wrong=%d)"
             " [if wrong, P1 needs an explicit coherence step]",
             (unsigned)r, (unsigned)sc, bad3);
skip_data:
        zeMemFree(g_zctx, ptr);
    }

    // teardown (keep it clean so a re-run is not poisoned by a leaked import)
    if (g_map) vkUnmapMemory(g_dev, g_mem);
    if (g_handle) CloseHandle(g_handle);
    if (g_mem) vkFreeMemory(g_dev, g_mem, nullptr);
    if (g_zcl) zeCommandListDestroy(g_zcl);
    if (g_zq) zeCommandQueueDestroy(g_zq);
    if (g_zctx) zeContextDestroy(g_zctx);
    if (g_dev) vkDestroyDevice(g_dev, nullptr);
    if (g_inst) vkDestroyInstance(g_inst, nullptr);

    std::printf("\nPROBE_VK_L0_IMPORT %s (%d fails)\n", g_fails ? "RED" : "GREEN", g_fails);
    return g_fails ? 1 : 0;
}
