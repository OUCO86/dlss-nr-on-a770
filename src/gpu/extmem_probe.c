/* Can two VkDevices on this one Arc card share a buffer, and what does it cost?
 *
 * Phase 2 of notes/host-passes-to-gpu.md wants the layer and the daemon to hand each
 * other frames without the bytes crossing the bus: one exports a VkDeviceMemory, the
 * other imports it.
 *
 * What the specification says, and what this measures:
 *  - VkImportMemoryWin32HandleInfoKHR: "For handle types defined as NT handles, the
 *    imported memory object holds a reference to its payload." Importing is not a copy;
 *    both devices address the same memory.
 *  - but writes are only guaranteed visible to the queue family that made them, and a
 *    fence waited on in the *exporting* device creates no execution dependency at all in
 *    the *importing* one. The documented symptom of missing that is stale data.
 *
 * So this asks, in order:
 *   1. does the driver report the buffer as exportable and importable?
 *   2. can we build two VkDevices on the one physical device, export a handle, import it?
 *   3. is it really the same memory — does a fill through A show up when B reads?
 *   4. and the other way, B writes and A reads.
 *
 * Both 3 and 4 are run twice: with nothing but a fence on the writer, and with an
 * exported/imported semaphore carrying the dependency across the devices.
 *
 * ⚠ A first version of this probe reported every word wrong and blamed stale data. It
 * was the probe's own bug: vkCmdFillBuffer takes a *32-bit* pattern, so 0xAB lands in
 * memory as AB 00 00 00, while the comparison asked every byte to equal 0xAB — three
 * bytes in four can never match. Patterns here are therefore four repeated bytes
 * (0xA5A5A5A5 and friends). Check that before believing any "stale" result.
 *
 *   build: tools\build_extmem_probe.bat
 */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <stdlib.h>

#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>

#define SZ (1u << 20)

/* four byte patterns, so a stale read cannot look like a current one */
#define P_AA 0xA5A5A5A5u
#define P_BB 0x5A5A5A5Au
#define P_AB 0x3C3C3C3Cu
#define P_BA 0xC3C3C3C3u

static int failures;
static VkPhysicalDevice g_pd;
static uint32_t g_host_type = UINT32_MAX;

#define TRY(what, call)                                                        \
	do {                                                                   \
		VkResult r_ = (call);                                          \
		if (r_ != VK_SUCCESS) {                                        \
			printf("  FAIL %s: %d\n", (what), (int)r_);            \
			failures++;                                            \
			return 1;                                              \
		}                                                              \
	} while (0)

struct side {
	VkDevice dev;
	VkQueue queue;
	uint32_t family;
	VkCommandPool pool;
};

static uint32_t compute_family(VkPhysicalDevice pd)
{
	uint32_t n = 0;
	vkGetPhysicalDeviceQueueFamilyProperties(pd, &n, NULL);
	VkQueueFamilyProperties *p = calloc(n ? n : 1, sizeof *p);
	vkGetPhysicalDeviceQueueFamilyProperties(pd, &n, p);
	uint32_t found = UINT32_MAX;
	for (uint32_t i = 0; i < n; i++)
		if (p[i].queueFlags & VK_QUEUE_COMPUTE_BIT) {
			found = i;
			break;
		}
	free(p);
	return found;
}

static int make_side(VkPhysicalDevice pd, struct side *s)
{
	static const char *ext[] = { VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME,
				     VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME };
	float prio = 1.0f;
	s->family = compute_family(pd);
	if (s->family == UINT32_MAX) {
		printf("  FAIL no compute queue family\n");
		return 1;
	}
	VkDeviceQueueCreateInfo qci = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
		.queueFamilyIndex = s->family, .queueCount = 1, .pQueuePriorities = &prio,
	};
	VkDeviceCreateInfo dci = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
		.queueCreateInfoCount = 1, .pQueueCreateInfos = &qci,
		.enabledExtensionCount = 2, .ppEnabledExtensionNames = ext,
	};
	TRY("vkCreateDevice", vkCreateDevice(pd, &dci, NULL, &s->dev));
	vkGetDeviceQueue(s->dev, s->family, 0, &s->queue);
	VkCommandPoolCreateInfo cpci = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
		.queueFamilyIndex = s->family,
	};
	TRY("vkCreateCommandPool", vkCreateCommandPool(s->dev, &cpci, NULL, &s->pool));
	return 0;
}

static VkCommandBuffer begin_cmd(struct side *s)
{
	VkCommandBufferAllocateInfo ai = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
		.commandPool = s->pool, .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
		.commandBufferCount = 1,
	};
	VkCommandBuffer cb;
	if (vkAllocateCommandBuffers(s->dev, &ai, &cb) != VK_SUCCESS)
		return NULL;
	VkCommandBufferBeginInfo bi = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
	if (vkBeginCommandBuffer(cb, &bi) != VK_SUCCESS)
		return NULL;
	return cb;
}

/* Submit `cb`, optionally waiting on one semaphore and/or signalling one, and block
 * until the queue is done with it. */
static int end_cmd(struct side *s, VkCommandBuffer cb, VkSemaphore wait,
		   VkSemaphore signal)
{
	TRY("vkEndCommandBuffer", vkEndCommandBuffer(cb));
	VkFenceCreateInfo fci = { .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
	VkFence f;
	TRY("vkCreateFence", vkCreateFence(s->dev, &fci, NULL, &f));
	VkPipelineStageFlags stage = VK_PIPELINE_STAGE_TRANSFER_BIT;
	VkSubmitInfo si = {
		.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
		.commandBufferCount = 1, .pCommandBuffers = &cb,
		.waitSemaphoreCount = wait ? 1u : 0u, .pWaitSemaphores = &wait,
		.pWaitDstStageMask = &stage,
		.signalSemaphoreCount = signal ? 1u : 0u, .pSignalSemaphores = &signal,
	};
	VkResult r = vkQueueSubmit(s->queue, 1, &si, f);
	if (r == VK_SUCCESS)
		r = vkWaitForFences(s->dev, 1, &f, VK_TRUE, ~(uint64_t)0);
	vkDestroyFence(s->dev, f, NULL);
	if (r != VK_SUCCESS) {
		printf("  FAIL submit/wait: %d\n", (int)r);
		failures++;
		return 1;
	}
	return 0;
}

static uint32_t pick_memory(VkMemoryRequirements req, VkMemoryPropertyFlags want)
{
	VkPhysicalDeviceMemoryProperties mp;
	vkGetPhysicalDeviceMemoryProperties(g_pd, &mp);
	for (uint32_t i = 0; i < mp.memoryTypeCount; i++) {
		if (!(req.memoryTypeBits & (1u << i)))
			continue;
		if ((mp.memoryTypes[i].propertyFlags & want) == want)
			return i;
	}
	return UINT32_MAX;
}

static int fill(struct side *s, VkBuffer buf, unsigned pattern, VkSemaphore signal)
{
	VkCommandBuffer cb = begin_cmd(s);
	if (!cb)
		return 1;
	vkCmdFillBuffer(cb, buf, 0, SZ, pattern);
	return end_cmd(s, cb, NULL, signal);
}

/* How many bytes of `src`, read back through device `s`, are not `expect`. ~0u on
 * any API failure. */
static unsigned read_back(struct side *s, VkBuffer src, unsigned char expect,
			  VkSemaphore wait)
{
	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = SZ, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	VkBuffer host;
	if (vkCreateBuffer(s->dev, &ci, NULL, &host) != VK_SUCCESS)
		return ~0u;
	VkMemoryRequirements r;
	vkGetBufferMemoryRequirements(s->dev, host, &r);
	VkMemoryAllocateInfo mai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		.allocationSize = r.size, .memoryTypeIndex = g_host_type,
	};
	VkDeviceMemory m;
	if (vkAllocateMemory(s->dev, &mai, NULL, &m) != VK_SUCCESS)
		return ~0u;
	vkBindBufferMemory(s->dev, host, m, 0);
	VkCommandBuffer cb = begin_cmd(s);
	if (!cb)
		return ~0u;
	VkBufferCopy cp = { .size = SZ };
	vkCmdCopyBuffer(cb, src, host, 1, &cp);
	if (end_cmd(s, cb, wait, NULL))
		return ~0u;
	unsigned char *p;
	if (vkMapMemory(s->dev, m, 0, SZ, 0, (void **)&p) != VK_SUCCESS)
		return ~0u;
	unsigned wrong = 0;
	for (unsigned i = 0; i < SZ; i++)
		if (p[i] != expect)
			wrong++;
	printf("      first bytes: %02x %02x %02x %02x (wanted %02x)\n",
	       p[0], p[1], p[2], p[3], expect);
	vkUnmapMemory(s->dev, m);
	vkFreeMemory(s->dev, m, NULL);
	vkDestroyBuffer(s->dev, host, NULL);
	return wrong;
}

/* A semaphore A can signal that B can wait on. */
static int make_shared_semaphore(struct side *from, struct side *to,
				 VkSemaphore *a, VkSemaphore *b, HANDLE *handle)
{
	VkExportSemaphoreCreateInfo esci = {
		.sType = VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO,
		.handleTypes = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkSemaphoreCreateInfo sci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &esci,
	};
	TRY("vkCreateSemaphore (export)", vkCreateSemaphore(from->dev, &sci, NULL, a));
	PFN_vkGetSemaphoreWin32HandleKHR get = (PFN_vkGetSemaphoreWin32HandleKHR)
		vkGetDeviceProcAddr(from->dev, "vkGetSemaphoreWin32HandleKHR");
	if (!get) {
		printf("  FAIL vkGetSemaphoreWin32HandleKHR absent\n");
		return 1;
	}
	VkSemaphoreGetWin32HandleInfoKHR ghi = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_GET_WIN32_HANDLE_INFO_KHR,
		.semaphore = *a,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	TRY("vkGetSemaphoreWin32HandleKHR", get(from->dev, &ghi, handle));
	VkImportSemaphoreWin32HandleInfoKHR ishi = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
		.handle = *handle,
	};
	VkSemaphoreCreateInfo sci2 = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &ishi,
	};
	TRY("vkCreateSemaphore (import)", vkCreateSemaphore(to->dev, &sci2, NULL, b));
	return 0;
}

int main(void)
{
	static const char *iext[] = {
		VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME,
		VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_EXTENSION_NAME,
		VK_KHR_EXTERNAL_FENCE_CAPABILITIES_EXTENSION_NAME,
	};
	VkInstanceCreateInfo ici = {
		.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		.enabledExtensionCount = 3, .ppEnabledExtensionNames = iext,
	};
	VkInstance inst;
	TRY("vkCreateInstance", vkCreateInstance(&ici, NULL, &inst));

	uint32_t n = 0;
	vkEnumeratePhysicalDevices(inst, &n, NULL);
	VkPhysicalDevice *pds = calloc(n ? n : 1, sizeof *pds);
	vkEnumeratePhysicalDevices(inst, &n, pds);
	for (uint32_t i = 0; i < n && !g_pd; i++) {
		VkPhysicalDeviceProperties p;
		vkGetPhysicalDeviceProperties(pds[i], &p);
		if (p.vendorID == 0x8086) {
			g_pd = pds[i];
			printf("device: %s (vendor 0x%x)\n", p.deviceName, p.vendorID);
		}
	}
	if (!g_pd) {
		printf("FAIL: no Intel physical device\n");
		return 1;
	}

	/* the host memory type, for reading things back */
	VkBuffer scratch_ci_holder;
	VkBufferCreateInfo sci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = 4096, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
	};
	{	/* any device will do to ask what a host-visible buffer wants */
		struct side tmp;
		if (make_side(g_pd, &tmp)) {
			printf("FAIL: cannot build a device\n");
			return 1;
		}
		vkCreateBuffer(tmp.dev, &sci, NULL, &scratch_ci_holder);
		VkMemoryRequirements r;
		vkGetBufferMemoryRequirements(tmp.dev, scratch_ci_holder, &r);
		g_host_type = pick_memory(r, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
					     VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
		vkDestroyBuffer(tmp.dev, scratch_ci_holder, NULL);
		vkDestroyCommandPool(tmp.dev, tmp.pool, NULL);
		vkDestroyDevice(tmp.dev, NULL);
	}
	if (g_host_type == UINT32_MAX) {
		printf("FAIL: no HOST_VISIBLE memory type\n");
		return 1;
	}

	printf("\n[1] does the driver say a buffer can cross devices?\n");
	VkPhysicalDeviceExternalBufferInfo bi = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkExternalBufferProperties bp = {
		.sType = VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES,
	};
	vkGetPhysicalDeviceExternalBufferProperties(g_pd, &bi, &bp);
	VkExternalMemoryFeatureFlags f = bp.externalMemoryProperties.externalMemoryFeatures;
	printf("  opaque_win32 buffer: exportable=%d importable=%d\n",
	       !!(f & VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT),
	       !!(f & VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT));

	printf("\n[2] two devices, one export, one import\n");
	struct side a = { 0 }, b = { 0 };
	if (make_side(g_pd, &a) || make_side(g_pd, &b)) {
		printf("FAIL: could not build two devices\n");
		return 1;
	}
	printf("  queue families: A=%u B=%u\n", a.family, b.family);

	VkExternalMemoryBufferCreateInfo embi = {
		.sType = VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO,
		.handleTypes = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkBufferCreateInfo bci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .pNext = &embi,
		.size = SZ,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	VkBuffer ba;
	TRY("vkCreateBuffer (exportable)", vkCreateBuffer(a.dev, &bci, NULL, &ba));
	VkMemoryRequirements ra;
	vkGetBufferMemoryRequirements(a.dev, ba, &ra);
	uint32_t type = pick_memory(ra, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
	if (type == UINT32_MAX) {
		printf("  FAIL no DEVICE_LOCAL memory type\n");
		return 1;
	}
	VkExportMemoryAllocateInfo emai = {
		.sType = VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO,
		.handleTypes = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkMemoryAllocateInfo mai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &emai,
		.allocationSize = ra.size, .memoryTypeIndex = type,
	};
	VkDeviceMemory ma;
	TRY("vkAllocateMemory (export)", vkAllocateMemory(a.dev, &mai, NULL, &ma));
	TRY("vkBindBufferMemory (A)", vkBindBufferMemory(a.dev, ba, ma, 0));

	HANDLE handle = NULL;
	VkMemoryGetWin32HandleInfoKHR ghi = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR,
		.memory = ma,
		.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	PFN_vkGetMemoryWin32HandleKHR get_handle = (PFN_vkGetMemoryWin32HandleKHR)
		vkGetDeviceProcAddr(a.dev, "vkGetMemoryWin32HandleKHR");
	if (!get_handle) {
		printf("  FAIL vkGetMemoryWin32HandleKHR absent\n");
		return 1;
	}
	TRY("vkGetMemoryWin32HandleKHR", get_handle(a.dev, &ghi, &handle));
	printf("  exported handle %p, %llu bytes\n", (void *)handle,
	       (unsigned long long)ra.size);

	VkBufferCreateInfo bci2 = bci;
	bci2.pNext = NULL;
	VkBuffer bb;
	TRY("vkCreateBuffer (import side)", vkCreateBuffer(b.dev, &bci2, NULL, &bb));
	VkMemoryRequirements rb;
	vkGetBufferMemoryRequirements(b.dev, bb, &rb);
	VkImportMemoryWin32HandleInfoKHR ihi = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR,
		.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
		.handle = handle,
	};
	VkMemoryAllocateInfo mai2 = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &ihi,
		.allocationSize = rb.size, .memoryTypeIndex = type,
	};
	VkDeviceMemory mb;
	TRY("vkAllocateMemory (import)", vkAllocateMemory(b.dev, &mai2, NULL, &mb));
	TRY("vkBindBufferMemory (B)", vkBindBufferMemory(b.dev, bb, mb, 0));
	printf("  imported; both buffers bound\n");

	printf("\n[3] within one device (sanity: the fill and the read-back work)\n");
	if (fill(&a, ba, P_AA, NULL))
		return 1;
	printf("  A writes, A reads: %u of %u bytes wrong\n",
	       read_back(&a, ba, (unsigned char)P_AA, NULL), SZ);
	if (fill(&b, bb, P_BB, NULL))
		return 1;
	printf("  B writes, B reads: %u of %u bytes wrong\n",
	       read_back(&b, bb, (unsigned char)P_BB, NULL), SZ);

	printf("\n[4] across devices, nothing but a fence on the writer\n");
	if (fill(&a, ba, P_AB, NULL))
		return 1;
	printf("  A writes, B reads: %u of %u bytes wrong\n",
	       read_back(&b, bb, (unsigned char)P_AB, NULL), SZ);

	printf("\n[5] across devices, dependency carried by a shared semaphore\n");
	{
		VkSemaphore sa, sb;
		HANDLE sh = NULL;
		if (make_shared_semaphore(&a, &b, &sa, &sb, &sh))
			return 1;
		printf("  semaphore exported and imported\n");
		if (fill(&a, ba, P_BA, sa))
			return 1;
		printf("  A writes, B reads: %u of %u bytes wrong\n",
		       read_back(&b, bb, (unsigned char)P_BA, sb), SZ);
		vkDestroySemaphore(a.dev, sa, NULL);
		vkDestroySemaphore(b.dev, sb, NULL);
		CloseHandle(sh);
	}

	printf("\n[6] and back the other way (B writes, A reads)\n");
	{
		VkSemaphore sb2, sa2;
		HANDLE sh2 = NULL;
		if (make_shared_semaphore(&b, &a, &sb2, &sa2, &sh2))
			return 1;
		if (fill(&b, bb, P_AA, sb2))
			return 1;
		printf("  B writes, A reads: %u of %u bytes wrong\n",
		       read_back(&a, ba, (unsigned char)P_AA, sa2), SZ);
		vkDestroySemaphore(b.dev, sb2, NULL);
		vkDestroySemaphore(a.dev, sa2, NULL);
		CloseHandle(sh2);
	}

	CloseHandle(handle);
	printf(failures ? "\nPROBE FAILED\n" : "\nPROBE OK\n");
	return failures ? 1 : 0;
}
