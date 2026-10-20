// repro_vk_sycl.cpp -- reproduce the game-process condition offline (section 92):
// the bridge's Vulkan hand-over device on the Arc is UP before my dll inits, and in
// the game my SYCL then enumerated only the OpenCL-backed Arc (census pending -- the
// 2026-10-20 GPUCrash: graph_run hit UR error 68 on the opencl Arc). This exe makes a
// minimal Arc Vulkan device (probe_vk_l0_import's make_vk, the senior-verified form),
// THEN loads libxmx_sycl.dll and calls xmx_init, printing the census the dll writes
// beside itself. One variable: Vulkan-device-before-SYCL-init.
#include <vulkan/vulkan.h>
#include <windows.h>
#include <cstdio>
#include <cstdint>
#include <vector>

int main() {
    setvbuf(stdout, nullptr, _IONBF, 0);
    // ---- the game's condition: an Arc Vulkan device, up before NR ----
    VkInstanceCreateInfo ici{ VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
    const char* iext[] = { "VK_KHR_get_physical_device_properties2",
                           "VK_KHR_external_memory_capabilities" };
    ici.enabledExtensionCount = 2; ici.ppEnabledExtensionNames = iext;
    VkInstance inst = VK_NULL_HANDLE;
    if (vkCreateInstance(&ici, nullptr, &inst) != VK_SUCCESS) {
        std::printf("FAIL vkCreateInstance\n"); return 1;
    }
    uint32_t npd = 0; vkEnumeratePhysicalDevices(inst, &npd, nullptr);
    std::vector<VkPhysicalDevice> all(npd);
    vkEnumeratePhysicalDevices(inst, &npd, all.data());
    VkPhysicalDevice pd = VK_NULL_HANDLE;
    for (auto p : all) {
        VkPhysicalDeviceProperties pr; vkGetPhysicalDeviceProperties(p, &pr);
        std::printf("vk device: %s vendor 0x%x device 0x%x\n", pr.deviceName, pr.vendorID, pr.deviceID);
        if (pr.vendorID == 0x8086 && pr.deviceID == 0x56a0) pd = p;
    }
    if (!pd) { std::printf("no A770 on the Vulkan side\n"); return 1; }
    const char* dext[] = { "VK_KHR_external_memory_win32" };
    VkDeviceCreateInfo dci{ VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
    dci.enabledExtensionCount = 1; dci.ppEnabledExtensionNames = dext;
    uint32_t nq = 0; vkGetPhysicalDeviceQueueFamilyProperties(pd, &nq, nullptr);
    float prio = 0.0f;
    VkDeviceQueueCreateInfo qi{ VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
    qi.queueFamilyIndex = 0; qi.queueCount = 1; qi.pQueuePriorities = &prio;
    if (nq) { dci.queueCreateInfoCount = 1; dci.pQueueCreateInfos = &qi; }
    VkDevice dev = VK_NULL_HANDLE;
    if (vkCreateDevice(pd, &dci, nullptr, &dev) != VK_SUCCESS) {
        std::printf("FAIL vkCreateDevice\n"); return 1;
    }
    std::printf("Arc Vulkan device UP (the game's condition). Now loading my dll...\n");

    // ONE variable at a time: NR_GAME_TBB=1 preloads the GAME's tbb12.dll (as UE4 does
    // for embree/OIDN) before my dll -- the suspected cause of the game process losing
    // the Level-Zero adapter (the 2026-10-20 census showed only backend=1 there).
    if (getenv("NR_GAME_TBB")) {
        HMODULE gt = LoadLibraryExW(L"F:\\Game\\Lies of P\\LiesofP\\Binaries\\Win64\\tbb12.dll",
                                    nullptr, 0);
        std::printf("game tbb12 preloaded: %s\n", gt ? "yes" : "NO");
    }

    // ---- my engine inits AFTER the Vulkan device exists ----
    HMODULE mine = LoadLibraryA("libxmx_sycl.dll");
    if (!mine) { std::printf("FAIL LoadLibrary\n"); return 1; }
    auto x_init = (int(*)(void))GetProcAddress(mine, "xmx_init");
    auto x_error = (const char*(*)(void))GetProcAddress(mine, "xmx_error");
    int rc = x_init();
    std::printf("xmx_init rc=%d err=%s\n", rc, rc ? x_error() : "");
    // if init passed, prove the queue actually computes (a tiny pre run via the native gate path
    // is overkill here; rc==0 + census backend=2 is the answer to THIS question).
    return rc == 0 ? 0 : 2;
}
