/*
 * gpu_pick.h — choose which physical device the XMX kernels run on.
 *
 * Upstream takes pds[0] unconditionally, which is fine on the single-GPU
 * machines it was developed on and wrong anywhere else. This machine has two:
 *
 *     device 0: AMD Radeon RX 9070 XT     (vendor 0x1002, device 0x7550)
 *     device 1: Intel Arc A770 Graphics   (vendor 0x8086, device 0x56a0)
 *
 * Enumeration order is not guaranteed and pds[0] here is the AMD card, so the
 * kernels would be built for a device that does not advertise the
 * cooperative-matrix configuration they ask for.
 *
 * Selection order:
 *   1. XMX_GPU_INDEX (or NR_GPU_INDEX) — an explicit index, when you want one.
 *   2. vendorID 0x8086 — Intel, which is what this port targets.
 *   3. pds[0] — the old behaviour, so nothing regresses on a one-GPU machine.
 *
 * Requires <vulkan/vulkan.h>, <stdlib.h> and <stdio.h> already included.
 */

#ifndef XMX_GPU_PICK_H
#define XMX_GPU_PICK_H

#include <vulkan/vulkan.h>
#include <stdlib.h>
#include <stdio.h>

#define XMX_VENDOR_INTEL 0x8086u

/* Returns the chosen device, or VK_NULL_HANDLE if there is no device at all.
 * `out_count` may be NULL. On stderr it names what it picked and why, because
 * silently running on the wrong card shows up as a wrong answer, not an error. */
static inline VkPhysicalDevice
xmx_pick_device(VkInstance inst, const char *who, uint32_t *out_count)
{
	uint32_t n = 0;
	vkEnumeratePhysicalDevices(inst, &n, NULL);
	if (out_count)
		*out_count = n;
	if (!n)
		return VK_NULL_HANDLE;

	VkPhysicalDevice *pds = calloc(n, sizeof *pds);
	if (!pds)
		return VK_NULL_HANDLE;
	vkEnumeratePhysicalDevices(inst, &n, pds);

	const char *want = getenv("XMX_GPU_INDEX");
	if (!want || !*want)
		want = getenv("NR_GPU_INDEX");

	uint32_t chosen = 0;
	const char *why = "first device";

	if (want && *want) {
		long asked = strtol(want, NULL, 10);
		if (asked >= 0 && (unsigned long)asked < n) {
			chosen = (uint32_t)asked;
			why = "XMX_GPU_INDEX";
		} else {
			fprintf(stderr, "%s: XMX_GPU_INDEX=%s is out of range (%u devices); "
			                "falling back\n", who, want, n);
		}
	}

	if (!want || !*want) {
		for (uint32_t i = 0; i < n; i++) {
			VkPhysicalDeviceProperties p;
			vkGetPhysicalDeviceProperties(pds[i], &p);
			if (p.vendorID == XMX_VENDOR_INTEL) {
				chosen = i;
				why = "Intel vendor match";
				break;
			}
		}
	}

	VkPhysicalDeviceProperties props;
	vkGetPhysicalDeviceProperties(pds[chosen], &props);
	fprintf(stderr, "%s: device %u/%u %s (vendor 0x%04x, device 0x%04x) [%s]\n",
	        who, chosen, n, props.deviceName, props.vendorID, props.deviceID, why);

	VkPhysicalDevice pd = pds[chosen];
	free(pds);
	return pd;
}

#endif /* XMX_GPU_PICK_H */
