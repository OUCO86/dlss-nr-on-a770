/* Minimal headless application used to check both loader architectures. */
#include <stdio.h>
#include <vulkan/vulkan.h>

int main(void)
{
    const char *layer = "VK_LAYER_dlssnr_intel";
    VkApplicationInfo app = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "nr-layer-check", .apiVersion = VK_API_VERSION_1_1 };
    VkInstanceCreateInfo info = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app, .enabledLayerCount = 1, .ppEnabledLayerNames = &layer };
    VkInstance instance;
    VkResult r = vkCreateInstance(&info, NULL, &instance);
    if (r) { fprintf(stderr, "create instance: %d\n", r); return 1; }
    uint32_t count = 0;
    r = vkEnumeratePhysicalDevices(instance, &count, NULL);
    vkDestroyInstance(instance, NULL);
    if (r || !count) { fprintf(stderr, "physical devices: %d (%u)\n", r, count); return 1; }
    printf("%zu-bit layer loaded; %u physical device(s)\n", sizeof(void *) * 8, count);
    return 0;
}
