/* nr_extmem.c — the layer's own device on the card that does the work.
 *
 * See nr_extmem.h for what this is for. Everything here is Windows-only; the header
 * gives the Linux build stubs that say no, so this file is only ever compiled there.
 *
 * The shape of each call was checked against the specification before it was written
 * — refs/vulkan-sync/ holds the pages, and README.md says which conclusion came from
 * where. Two of them changed the code:
 *
 *   * A buffer that will be bound to imported memory must be created with
 *     VkExternalMemoryBufferCreateInfo in its pNext chain. It is easy to leave out:
 *     vkCreateBuffer and vkBindBufferMemory both succeed without it, and the failure
 *     shows up later as DEVICE_LOST. (vulkan_core.h:5871)
 *   * The semaphore is a timeline one, not binary: VUID-vkQueueSubmit-pWaitSemaphores-
 *     03238 forbids waiting on a binary one before its signal has been submitted, and
 *     "the frame's bytes are on their way" is exactly that. Timeline semaphores have no
 *     such rule — VK_KHR_timeline_semaphore Issue 3: "RESOLVED : No."
 *
 * And one from the driver rather than the spec: it reports memoryTypeBits 0x0 from
 * vkGetMemoryWin32HandlePropertiesKHR, which reads as "this handle cannot be imported
 * at all". It is a driver bug, so the buffer's own requirements are used instead and
 * vkAllocateMemory is left to be the judge.
 */

#include "nr_extmem.h"

#ifdef _WIN32

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NRX_INTEL_VENDOR 0x8086

static VkInstance nrx_inst;
static VkPhysicalDevice nrx_pd;
static VkDevice nrx_dev;

static VkBuffer nrx_raw_buf, nrx_ans_buf;
static VkDeviceMemory nrx_raw_mem, nrx_ans_mem;
static void *nrx_raw_p, *nrx_ans_p;
static size_t nrx_raw_n, nrx_ans_n;

static VkSemaphore nrx_sem;

static int nrx_live;
static const char *nrx_err;

static void nrx_fail(const char *what)
{
	if (!nrx_err)
		nrx_err = what;
}

/* ------------------------------------------------------------------ device ---- */

static VkPhysicalDevice pick_intel(VkInstance inst)
{
	uint32_t n = 0;
	if (vkEnumeratePhysicalDevices(inst, &n, NULL) != VK_SUCCESS || n == 0) {
		nrx_fail("vkEnumeratePhysicalDevices");
		return NULL;
	}
	VkPhysicalDevice *list = calloc(n, sizeof *list);
	if (!list) {
		nrx_fail("out of memory");
		return NULL;
	}
	if (vkEnumeratePhysicalDevices(inst, &n, list) != VK_SUCCESS) {
		free(list);
		nrx_fail("vkEnumeratePhysicalDevices");
		return NULL;
	}
	/* The card that does the Neural Renderer's work, by vendor. Enumeration order puts
	 * the AMD card first on this machine, so picking by index would pick the one that
	 * renders the game — see notes/device-budget-a770.md. */
	VkPhysicalDevice found = NULL;
	for (uint32_t i = 0; i < n; i++) {
		VkPhysicalDeviceProperties p;
		vkGetPhysicalDeviceProperties(list[i], &p);
		if (p.vendorID == NRX_INTEL_VENDOR) {
			found = list[i];
			break;
		}
	}
	free(list);
	if (!found)
		nrx_fail("no Intel physical device");
	return found;
}

static uint32_t compute_family(VkPhysicalDevice pd)
{
	uint32_t n = 0;
	vkGetPhysicalDeviceQueueFamilyProperties(pd, &n, NULL);
	VkQueueFamilyProperties *q = calloc(n ? n : 1, sizeof *q);
	if (!q) {
		nrx_fail("out of memory");
		return UINT32_MAX;
	}
	vkGetPhysicalDeviceQueueFamilyProperties(pd, &n, q);
	uint32_t best = UINT32_MAX;
	for (uint32_t i = 0; i < n; i++)
		if (q[i].queueFlags & VK_QUEUE_COMPUTE_BIT) {
			best = i;
			break;
		}
	free(q);
	if (best == UINT32_MAX)
		nrx_fail("no compute queue family");
	return best;
}

static int make_device(void)
{
	if (nrx_dev)
		return 0;

	/* apiVersion has to be filled in: an instance that does not ask is treated as 1.0,
	 * and vkGetDeviceProcAddr then cannot find vkSignalSemaphore, which is 1.2. */
	VkApplicationInfo app = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
				  .pApplicationName = "nr_layer_extmem",
				  .apiVersion = VK_API_VERSION_1_3 };
	VkInstanceCreateInfo ici = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
				     .pApplicationInfo = &app };
	if (vkCreateInstance(&ici, NULL, &nrx_inst) != VK_SUCCESS) {
		nrx_fail("vkCreateInstance");
		return -1;
	}
	nrx_pd = pick_intel(nrx_inst);
	if (!nrx_pd)
		return -1;

	uint32_t family = compute_family(nrx_pd);
	if (family == UINT32_MAX)
		return -1;

	float prio = 1.0f;
	VkDeviceQueueCreateInfo qci = { .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
					.queueFamilyIndex = family, .queueCount = 1,
					.pQueuePriorities = &prio };
	const char *ext[] = { VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME,
			      VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME };
	/* The feature has to hang off VkPhysicalDeviceFeatures2: put in
	 * VkDeviceCreateInfo's own pNext it is silently dropped, and the first
	 * vkSignalSemaphore then fails rather than the device creation. */
	VkPhysicalDeviceTimelineSemaphoreFeatures ts = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES,
		.timelineSemaphore = VK_TRUE,
	};
	VkPhysicalDeviceFeatures2 pf2 = { .sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2,
					 .pNext = &ts };
	VkDeviceCreateInfo dci = { .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
				   .pNext = &pf2,
				   .queueCreateInfoCount = 1, .pQueueCreateInfos = &qci,
				   .enabledExtensionCount = 2, .ppEnabledExtensionNames = ext };
	if (vkCreateDevice(nrx_pd, &dci, NULL, &nrx_dev) != VK_SUCCESS) {
		nrx_fail("vkCreateDevice");
		nrx_dev = NULL;
		return -1;
	}
	return 0;
}

/* ------------------------------------------------------------ imported memory -- */

/* The memory types an imported buffer may ask for, in the order they suit the two
 * halves of Phase 2. They are opposites, on purpose:
 *
 *   RAW_    the daemon's *device* reads it every frame. Device-local is the fast
 *           place for that, and the host side only ever writes, which is the cheap
 *           direction through the bar even uncached. This is type 3 here.
 *   HOST_   the *host* reads it every frame — the answer, in the layer. A read of
 *           device memory through the bar is uncached and cannot be posted: 7.9 MB
 *           measures 376.77 ms there against 0.40 ms out of cached system memory
 *           (check_bar_read.py). HOST_CACHED is what buys that. This is type 2 here,
 *           and it is the same bit nr_layer.c:1346 asks for first for its own
 *           staging buffer, which is why the host read on the way in was never slow.
 *
 * Picking "the first host-visible type" answers both with type 3, and with it a
 * frame rate that follows the answer's read down.
 *
 * The driver answers vkGetMemoryWin32HandlePropertiesKHR with memoryTypeBits 0x0 on
 * this card, so the buffer's own requirements are what is looked at. */
#define WANT_RAW   (VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | \
		    VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
#define WANT_HOST  (VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | \
		    VK_MEMORY_PROPERTY_HOST_COHERENT_BIT | VK_MEMORY_PROPERTY_HOST_CACHED_BIT)

static uint32_t pick_type(VkMemoryRequirements *req, VkMemoryPropertyFlags want)
{
	VkPhysicalDeviceMemoryProperties props;
	vkGetPhysicalDeviceMemoryProperties(nrx_pd, &props);
	/* The flags wanted, then just host-visible: an import that cannot have what it
	 * asked for is still better off mapped than refused. */
	for (int pass = 0; pass < 2; pass++) {
		VkMemoryPropertyFlags asking = pass == 0 ? want
					     : VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT;
		for (uint32_t i = 0; i < props.memoryTypeCount; i++) {
			if (!(req->memoryTypeBits & (1u << i)))
				continue;
			if ((props.memoryTypes[i].propertyFlags & asking) == asking)
				return i;
		}
	}
	return UINT32_MAX;
}

/* Bring in one exported buffer and map it. Returns 0, or -1 with nrx_err set.
 *
 * `bytes` is the size the daemon allocated, which is what the payload is and therefore
 * the whole of what may be asked for: vkAllocateMemory's VUID-vkAllocateMemory-
 * pAllocateInfo-01713 caps allocationSize at the heap, and an import has no business
 * asking for more than the export made. */
static int import_buffer(VkDeviceSize bytes, unsigned long long handle,
			 VkMemoryPropertyFlags want, VkBuffer *out_buf,
			 VkDeviceMemory *out_mem, void **out_ptr, uint32_t *out_type)
{
	const VkExternalMemoryHandleTypeFlagBits type =
		VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT;

	/* Required: without this the buffer may not be bound to imported memory. It is not
	 * caught at either call, so it is here rather than left to be discovered. */
	VkExternalMemoryBufferCreateInfo embci = {
		.sType = VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO,
		.handleTypes = type,
	};
	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .pNext = &embci,
		.size = bytes,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT |
			 VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	VkBuffer buf;
	if (vkCreateBuffer(nrx_dev, &ci, NULL, &buf) != VK_SUCCESS) {
		nrx_fail("vkCreateBuffer");
		return -1;
	}
	VkMemoryRequirements req;
	vkGetBufferMemoryRequirements(nrx_dev, buf, &req);
	uint32_t mt = pick_type(&req, want);
	if (out_type)
		*out_type = mt;
	if (mt == UINT32_MAX || req.size > bytes) {
		vkDestroyBuffer(nrx_dev, buf, NULL);
		nrx_fail(req.size > bytes ? "the exported buffer is too small"
					  : "no host-visible memory type for the import");
		return -1;
	}
	VkImportMemoryWin32HandleInfoKHR ihi = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR,
		.handleType = type,
		.handle = (HANDLE)(uintptr_t)handle,
	};
	VkMemoryAllocateInfo mai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &ihi,
		.allocationSize = bytes, .memoryTypeIndex = mt,
	};
	VkDeviceMemory mem;
	if (vkAllocateMemory(nrx_dev, &mai, NULL, &mem) != VK_SUCCESS) {
		vkDestroyBuffer(nrx_dev, buf, NULL);
		nrx_fail("vkAllocateMemory (import)");
		return -1;
	}
	if (vkBindBufferMemory(nrx_dev, buf, mem, 0) != VK_SUCCESS) {
		vkFreeMemory(nrx_dev, mem, NULL);
		vkDestroyBuffer(nrx_dev, buf, NULL);
		nrx_fail("vkBindBufferMemory");
		return -1;
	}
	void *p = NULL;
	if (vkMapMemory(nrx_dev, mem, 0, bytes, 0, &p) != VK_SUCCESS) {
		vkFreeMemory(nrx_dev, mem, NULL);
		vkDestroyBuffer(nrx_dev, buf, NULL);
		nrx_fail("vkMapMemory");
		return -1;
	}
	*out_buf = buf;
	*out_mem = mem;
	*out_ptr = p;
	return 0;
}

/* ---------------------------------------------------------------- semaphore --- */

static int import_semaphore(unsigned long long handle)
{
	VkSemaphoreTypeCreateInfo stci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO,
		.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE,
	};
	VkSemaphoreCreateInfo sci = { .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
				      .pNext = &stci };
	if (vkCreateSemaphore(nrx_dev, &sci, NULL, &nrx_sem) != VK_SUCCESS) {
		nrx_fail("vkCreateSemaphore");
		return -1;
	}
	PFN_vkImportSemaphoreWin32HandleKHR import = (PFN_vkImportSemaphoreWin32HandleKHR)
		vkGetDeviceProcAddr(nrx_dev, "vkImportSemaphoreWin32HandleKHR");
	if (!import) {
		nrx_fail("vkImportSemaphoreWin32HandleKHR absent");
		return -1;
	}
	VkImportSemaphoreWin32HandleInfoKHR ii = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR,
		.semaphore = nrx_sem,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
		.handle = (HANDLE)(uintptr_t)handle,
	};
	if (import(nrx_dev, &ii) != VK_SUCCESS) {
		nrx_fail("vkImportSemaphoreWin32HandleKHR");
		return -1;
	}
	return 0;
}

/* ------------------------------------------------------------------ public ---- */

/* The handles were duplicated into this process by the daemon, which cannot close
 * them from where it is. Importing does not take them over either, so a caller that
 * gave up on them has to let them go itself. */
static void nrx_drop_handles(unsigned long long raw_handle,
			     unsigned long long answer_handle,
			     unsigned long long sem_handle)
{
	if (raw_handle) CloseHandle((HANDLE)(uintptr_t)raw_handle);
	if (answer_handle) CloseHandle((HANDLE)(uintptr_t)answer_handle);
	if (sem_handle) CloseHandle((HANDLE)(uintptr_t)sem_handle);
}

/* `answer_handle` may be 0: the answer still crosses in a slot in the file mapping,
 * and Phase 2's first half — the frame going into the daemon's own buffer instead of
 * the mapping — needs only the buffer and the semaphore. */
int nrx_open(unsigned long long raw_handle, unsigned long long raw_bytes,
	     unsigned long long answer_handle, unsigned long long answer_bytes,
	     unsigned long long sem_handle)
{
	nrx_close();
	nrx_err = NULL;
	if (!raw_handle || !sem_handle || !raw_bytes) {
		nrx_fail("the daemon gave an incomplete set of handles");
		nrx_drop_handles(raw_handle, answer_handle, sem_handle);
		return -1;
	}
	if (make_device()) {
		nrx_drop_handles(raw_handle, answer_handle, sem_handle);
		return -1;
	}
	uint32_t raw_type = UINT32_MAX, answer_type = UINT32_MAX;
	/* The daemon's device reads this one every frame; the host only writes it. */
	if (import_buffer((VkDeviceSize)raw_bytes, raw_handle, WANT_RAW, &nrx_raw_buf,
			  &nrx_raw_mem, &nrx_raw_p, &raw_type)) {
		nrx_drop_handles(raw_handle, answer_handle, sem_handle);
		return -1;
	}
	nrx_raw_n = (size_t)raw_bytes;
	if (answer_handle && answer_bytes
	    /* The host reads this one every frame — this is the answer, and it is the
	     * read that decides whether the way back is worth having. */
	    && import_buffer((VkDeviceSize)answer_bytes, answer_handle, WANT_HOST,
			     &nrx_ans_buf, &nrx_ans_mem, &nrx_ans_p, &answer_type)) {
		nrx_drop_handles(raw_handle, answer_handle, sem_handle);
		nrx_close();
		return -1;
	}
	nrx_ans_n = answer_handle && answer_bytes ? (size_t)answer_bytes : 0;
	if (import_semaphore(sem_handle)) {
		nrx_drop_handles(raw_handle, answer_handle, sem_handle);
		nrx_close();
		return -1;
	}
	nrx_live = 1;
	/* The memory type each import landed in goes out with the sizes, because it is
	 * the one thing that decides what the host's read of the answer costs and it
	 * cannot be asked for afterwards. Type 2 on this card is cached system memory,
	 * type 3 is device memory behind the bar; an answer read out of type 3 measures
	 * 376.77 ms for 7.9 MB against 0.40 ms out of type 2 (check_bar_read.py). If the
	 * answer's type is not 2, the way back is being paid for and not bought. */
	if (nrx_ans_n)
		fprintf(stderr, "[nr_layer] the frame goes straight into the daemon's "
				"buffers: %zu MB raw in memory type %u, %zu MB answer in "
				"memory type %u, over a timeline semaphore\n",
			nrx_raw_n >> 20, raw_type, nrx_ans_n >> 20, answer_type);
	else
		fprintf(stderr, "[nr_layer] the frame goes straight into the daemon's "
				"buffer: %zu MB in memory type %u, over a timeline "
				"semaphore; the answer still crosses in a slot\n",
			nrx_raw_n >> 20, raw_type);
	return 0;
}

void *nrx_raw(size_t *bytes)
{
	if (bytes)
		*bytes = nrx_live ? nrx_raw_n : 0;
	return nrx_live ? nrx_raw_p : NULL;
}

void *nrx_answer(size_t *bytes)
{
	if (bytes)
		*bytes = nrx_live ? nrx_ans_n : 0;
	return nrx_live ? nrx_ans_p : NULL;
}

int nrx_signal(unsigned long long value)
{
	if (!nrx_live) {
		nrx_fail("no external semaphore is open");
		return -1;
	}
	PFN_vkSignalSemaphore signal =
		(PFN_vkSignalSemaphore)vkGetDeviceProcAddr(nrx_dev, "vkSignalSemaphore");
	if (!signal) {
		nrx_fail("vkSignalSemaphore absent");
		return -1;
	}
	VkSemaphoreSignalInfo si = { .sType = VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO,
				     .semaphore = nrx_sem, .value = value };
	VkResult r = signal(nrx_dev, &si);
	if (r != VK_SUCCESS) {
		nrx_fail("vkSignalSemaphore");
		return -1;
	}
	return 0;
}

void nrx_close(void)
{
	if (nrx_dev) {
		if (nrx_raw_p) vkUnmapMemory(nrx_dev, nrx_raw_mem);
		if (nrx_ans_p) vkUnmapMemory(nrx_dev, nrx_ans_mem);
		if (nrx_raw_buf) vkDestroyBuffer(nrx_dev, nrx_raw_buf, NULL);
		if (nrx_ans_buf) vkDestroyBuffer(nrx_dev, nrx_ans_buf, NULL);
		if (nrx_raw_mem) vkFreeMemory(nrx_dev, nrx_raw_mem, NULL);
		if (nrx_ans_mem) vkFreeMemory(nrx_dev, nrx_ans_mem, NULL);
		if (nrx_sem) vkDestroySemaphore(nrx_dev, nrx_sem, NULL);
	}
	/* The imported handles belong to whoever held them on the other side: importing
	 * does not take ownership, so nothing here closes them. */
	if (nrx_dev) vkDestroyDevice(nrx_dev, NULL);
	if (nrx_inst) vkDestroyInstance(nrx_inst, NULL);
	memset(&nrx_raw_buf, 0, (char *)&nrx_ans_n + sizeof nrx_ans_n - (char *)&nrx_raw_buf);
	nrx_dev = NULL;
	nrx_inst = NULL;
	nrx_pd = NULL;
	nrx_sem = NULL;
	nrx_raw_p = nrx_ans_p = NULL;
	nrx_raw_n = nrx_ans_n = 0;
	nrx_live = 0;
}

int nrx_ready(void)
{
	return nrx_live;
}

const char *nrx_error(void)
{
	return nrx_err;
}

#endif /* _WIN32 */
