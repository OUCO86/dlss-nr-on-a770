/* Does a VkDeviceMemory exported by one *process* work inside another?
 *
 * This is the gate Phase 2 has to pass. notes/host-passes-to-gpu.md §14 showed two
 * VkDevices in one process sharing a buffer, which proves the driver can do it but
 * says nothing about the part that matters: the layer lives inside the game process,
 * the daemon is a separate one. Across a process boundary the NT handle has to be
 * carried over (DuplicateHandle, or inheritance), the importing side has to be told
 * which memory type the payload is, and the dependency has to travel as an exported
 * semaphore — a fence waited on by the writer means nothing to the reader.
 *
 * What the specification says about each of those:
 *  - VkImportMemoryWin32HandleInfoKHR: "the imported memory object holds a reference
 *    to its payload". Importing is not a copy, so both processes address one buffer.
 *  - vkGetMemoryWin32HandlePropertiesKHR: the importing process must pick its
 *    memoryTypeIndex from the bits the driver reports *for that handle*, not from
 *    whatever it would have picked for a fresh allocation.
 *  - VK_KHR_external_semaphore_win32: a binary semaphore exported as OPAQUE_WIN32 can
 *    be imported and waited on; that wait is what makes the writer's commands visible
 *    to the reader's queue.
 *  - the handle type is NT, so the application owns it and must CloseHandle it.
 *
 * How this runs: one executable, two roles. The parent builds device A, allocates an
 * exportable 1 MB buffer and two exportable semaphores, then spawns itself as a child
 * over two anonymous pipes. The child builds its own device B, imports the buffer and
 * both semaphores, and then takes commands from the parent:
 *
 *   read aa sem      parent filled 0xA5A5A5A5 and signalled sem A->B; child waits, reads
 *   read ab nosem    parent filled 0x3C3C3C3C, no semaphore at all; child reads anyway
 *   read ba sem-async parent filled 0xC3C3C3C3, signalled, and did *not* wait its fence
 *                    before telling the child to read. If the semaphore really carries
 *                    the dependency this one is clean; that is the interesting case.
 *   write bb sem     child fills 0x5A5A5A5A and signals sem B->A; parent reads
 *
 * Two ways of getting the handle across are tried, because the driver is free to make
 * one of them fail: DuplicateHandle into the child (the call a real launcher would use),
 * and, if that refuses, plain inheritance. The child reports which one it ended up with.
 *
 * ⚠ Patterns are four repeated bytes. vkCmdFillBuffer takes a 32-bit pattern, so a
 * single-byte value lands in memory as AB 00 00 00; the first version of the in-process
 * probe compared byte by byte and reported everything wrong. See §14.
 *
 *   build: tools\build_extmem_xproc.bat     run: work\extmem_xproc.exe
 */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <vulkan/vulkan.h>
#include <vulkan/vulkan_win32.h>

#define SZ (1u << 20)

#define P_AA 0xA5A5A5A5u /* parent -> child, with semaphore */
#define P_AB 0x3C3C3C3Cu /* parent -> child, no semaphore */
#define P_BA 0xC3C3C3C3u /* parent -> child, semaphore, parent does not wait */
#define P_BB 0x5A5A5A5Au /* child -> parent, with semaphore */
#define P_CC 0x0F0F0F0Fu /* parent's CPU writes the BAR, child's GPU reads */
#define P_DD 0xF0F0F0F0u /* same, with vkFlushMappedMemoryRanges first */
#define P_EE 0x69696969u /* child's GPU writes the BAR, parent's CPU reads it */

static int failures;
static VkPhysicalDevice g_pd;

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
	uint32_t host_type;
};

static VkPhysicalDevice pick_intel(VkInstance inst)
{
	uint32_t n = 0;
	vkEnumeratePhysicalDevices(inst, &n, NULL);
	VkPhysicalDevice *pds = calloc(n ? n : 1, sizeof *pds);
	vkEnumeratePhysicalDevices(inst, &n, pds);
	VkPhysicalDevice found = NULL;
	for (uint32_t i = 0; i < n && !found; i++) {
		VkPhysicalDeviceProperties p;
		vkGetPhysicalDeviceProperties(pds[i], &p);
		if (p.vendorID == 0x8086) {
			found = pds[i];
			printf("  device: %s (vendor 0x%x)\n", p.deviceName, p.vendorID);
		}
	}
	free(pds);
	return found;
}

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

static uint32_t pick_memory(VkMemoryRequirements req, uint32_t allowed_bits,
			    VkMemoryPropertyFlags want)
{
	VkPhysicalDeviceMemoryProperties mp;
	vkGetPhysicalDeviceMemoryProperties(g_pd, &mp);
	for (uint32_t i = 0; i < mp.memoryTypeCount; i++) {
		if (!(allowed_bits & (1u << i)))
			continue;
		if (!(req.memoryTypeBits & (1u << i)))
			continue;
		if ((mp.memoryTypes[i].propertyFlags & want) == want)
			return i;
	}
	return UINT32_MAX;
}

static VkInstance make_instance(void)
{
	static const char *iext[] = {
		VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME,
		VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_EXTENSION_NAME,
		VK_KHR_EXTERNAL_FENCE_CAPABILITIES_EXTENSION_NAME,
	};
	/* apiVersion 0 is what an instance gets by default, and with it the loader treats
	 * the device as 1.0: vkGetDeviceProcAddr then has no vkSignalSemaphore to hand
	 * back, which is a confusing way to discover that timeline semaphores are missing.
	 * They are 1.2 core, so say so. */
	VkApplicationInfo app = {
		.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
		.pApplicationName = "extmem_xproc", .apiVersion = VK_API_VERSION_1_3,
	};
	VkInstanceCreateInfo ici = {
		.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .pApplicationInfo = &app,
		.enabledExtensionCount = 3, .ppEnabledExtensionNames = iext,
	};
	VkInstance inst;
	VkResult r = vkCreateInstance(&ici, NULL, &inst);
	if (r != VK_SUCCESS) {
		printf("  FAIL vkCreateInstance: %d\n", (int)r);
		failures++;
		return NULL;
	}
	return inst;
}

static int make_side(struct side *s)
{
	static const char *ext[] = { VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME,
				     VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME,
				     VK_KHR_EXTERNAL_FENCE_WIN32_EXTENSION_NAME };
	float prio = 1.0f;
	s->family = compute_family(g_pd);
	if (s->family == UINT32_MAX) {
		printf("  FAIL no compute queue family\n");
		return 1;
	}
	VkDeviceQueueCreateInfo qci = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
		.queueFamilyIndex = s->family, .queueCount = 1, .pQueuePriorities = &prio,
	};
	/* Timeline semaphores are core in 1.2 but not on by default, and a wait on one is
	 * only legal if the device was created asking for them. */
	VkPhysicalDeviceVulkan12Features v12 = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
		.timelineSemaphore = VK_TRUE,
	};
	/* VkDeviceCreateInfo::pNext takes VkPhysicalDeviceFeatures2, and the 1.2 block
	 * hangs off *that* — chaining it straight onto the device is not a spelling the
	 * specification offers, and asking for a feature that way is silently dropped
	 * rather than reported. */
	VkPhysicalDeviceFeatures2 f2 = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2, .pNext = &v12,
	};
	VkDeviceCreateInfo dci = {
		.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, .pNext = &f2,
		.queueCreateInfoCount = 1, .pQueueCreateInfos = &qci,
		.enabledExtensionCount = 3, .ppEnabledExtensionNames = ext,
	};
	TRY("vkCreateDevice", vkCreateDevice(g_pd, &dci, NULL, &s->dev));
	vkGetDeviceQueue(s->dev, s->family, 0, &s->queue);
	VkCommandPoolCreateInfo cpci = {
		.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
		.queueFamilyIndex = s->family,
	};
	TRY("vkCreateCommandPool", vkCreateCommandPool(s->dev, &cpci, NULL, &s->pool));

	/* a host-visible type, for reading bytes back to compare */
	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = 4096, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
	};
	VkBuffer scratch;
	TRY("vkCreateBuffer (scratch)", vkCreateBuffer(s->dev, &ci, NULL, &scratch));
	VkMemoryRequirements r;
	vkGetBufferMemoryRequirements(s->dev, scratch, &r);
	s->host_type = pick_memory(r, ~0u, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
					  VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
	vkDestroyBuffer(s->dev, scratch, NULL);
	if (s->host_type == UINT32_MAX) {
		printf("  FAIL no HOST_VISIBLE memory type\n");
		return 1;
	}
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

static int end_cmd(struct side *s, VkCommandBuffer cb, VkSemaphore wait,
		   VkSemaphore signal, int block)
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
	VkResult r = vkQueueSubmit(s->queue, 1, &si, block ? f : VK_NULL_HANDLE);
	if (r == VK_SUCCESS && block)
		r = vkWaitForFences(s->dev, 1, &f, VK_TRUE, ~(uint64_t)0);
	if (!block) {
		/* still need the fence to be reaped; a plain wait keeps valgrind-style
		 * complaints away and costs nothing here */
		vkWaitForFences(s->dev, 1, &f, VK_TRUE, ~(uint64_t)0);
	}
	vkDestroyFence(s->dev, f, NULL);
	if (r != VK_SUCCESS) {
		printf("  FAIL submit/wait: %d\n", (int)r);
		failures++;
		return 1;
	}
	return 0;
}

static int fill(struct side *s, VkBuffer buf, unsigned pattern, VkSemaphore wait,
		VkSemaphore signal, int block)
{
	VkCommandBuffer cb = begin_cmd(s);
	if (!cb)
		return 1;
	vkCmdFillBuffer(cb, buf, 0, SZ, pattern);
	return end_cmd(s, cb, wait, signal, block);
}

/* Bytes of `src`, copied out through a fresh host buffer in `s`, that are not the
 * low byte of `pattern`. ~0u on any API failure. */
static unsigned read_back(struct side *s, VkBuffer src, unsigned pattern,
			  VkSemaphore wait)
{
	unsigned char expect = (unsigned char)(pattern & 0xff);
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
		.allocationSize = r.size, .memoryTypeIndex = s->host_type,
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
	if (end_cmd(s, cb, wait, NULL, 1))
		return ~0u;
	unsigned char *p;
	if (vkMapMemory(s->dev, m, 0, SZ, 0, (void **)&p) != VK_SUCCESS)
		return ~0u;
	unsigned wrong = 0;
	for (unsigned i = 0; i < SZ; i++)
		if (p[i] != expect)
			wrong++;
	printf("      first bytes: %02x %02x %02x %02x (wanted %02x)\n", p[0], p[1],
	       p[2], p[3], expect);
	vkUnmapMemory(s->dev, m);
	vkFreeMemory(s->dev, m, NULL);
	vkDestroyBuffer(s->dev, host, NULL);
	return wrong;
}

/* ---------------------------------------------------------------- pipes ---- */

static void write_line(HANDLE h, const char *s)
{
	char buf[256];
	int n = snprintf(buf, sizeof buf, "%s\n", s);
	DWORD written = 0;
	WriteFile(h, buf, (DWORD)n, &written, NULL);
}

/* one byte at a time: blocking, and never overruns */
static int read_line(HANDLE h, char *out, size_t cap)
{
	size_t n = 0;
	while (n + 1 < cap) {
		char c;
		DWORD got = 0;
		if (!ReadFile(h, &c, 1, &got, NULL) || got != 1)
			return 0;
		if (c == '\n')
			break;
		out[n++] = c;
	}
	out[n] = 0;
	return 1;
}

static HANDLE h_from_str(const char *s)
{
	return (HANDLE)(uintptr_t)strtoull(s, NULL, 16);
}

/* --------------------------------------------------------------- child ---- */

static int child_main(void)
{
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
	/* unbuffered: printf goes straight to the pipe, so the parent sees the lines in
	 * the order they were produced rather than after the next WriteFile */
	setvbuf(stdout, NULL, _IONBF, 0);
	g_pd = pick_intel(inst);
	if (!g_pd) {
		printf("child: no Intel physical device\n");
		return 1;
	}
	struct side b = { 0 };
	if (make_side(&b))
		return 1;
	HANDLE hout = GetStdHandle(STD_OUTPUT_HANDLE);
	HANDLE hin = GetStdHandle(STD_INPUT_HANDLE);
	char line[256];
	char say[256];

	/* the parent sends the handle values as the first line, so it can pass the ones
	 * DuplicateHandle produced rather than the ones it holds itself */
	HANDLE hmem = NULL, ha2b = NULL, hb2a = NULL;
	if (!read_line(hin, line, sizeof line)) {
		printf("child: no handles arrived\n");
		return 1;
	}
	HANDLE hmem2 = NULL;
	{
		char m[32], m2[32], s1[32], s2[32];
		if (sscanf(line, "handles %31s %31s %31s %31s", m, m2, s1, s2) != 4) {
			printf("child: bad handles line '%s'\n", line);
			return 1;
		}
		hmem = h_from_str(m);
		hmem2 = h_from_str(m2);
		ha2b = h_from_str(s1);
		hb2a = h_from_str(s2);
	}

#define SAY(...)                                                               \
	do {                                                                   \
		snprintf(say, sizeof say, __VA_ARGS__);                        \
		write_line(hout, say);                                         \
	} while (0)

	/* which memory type does the driver allow for this payload? */
	PFN_vkGetMemoryWin32HandlePropertiesKHR props =
		(PFN_vkGetMemoryWin32HandlePropertiesKHR)
			vkGetDeviceProcAddr(b.dev, "vkGetMemoryWin32HandlePropertiesKHR");
	if (!props) {
		SAY("child: vkGetMemoryWin32HandlePropertiesKHR absent");
		return 1;
	}
	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = SZ,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	HANDLE mems[2] = { hmem, hmem2 };
	VkBuffer bufs[2] = { VK_NULL_HANDLE, VK_NULL_HANDLE };
	for (int i = 0; i < 2; i++) {
		if (!mems[i])
			continue;
		VkMemoryWin32HandlePropertiesKHR hp = {
			.sType = VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR,
		};
		if (props(b.dev, VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT, mems[i],
			  &hp) != VK_SUCCESS) {
			SAY("child: vkGetMemoryWin32HandlePropertiesKHR failed for buffer %d", i);
			return 1;
		}
		VkBuffer bb;
		if (vkCreateBuffer(b.dev, &ci, NULL, &bb) != VK_SUCCESS) {
			SAY("child: vkCreateBuffer failed");
			return 1;
		}
		VkMemoryRequirements rb;
		vkGetBufferMemoryRequirements(b.dev, bb, &rb);
		/* buffer 1 is the one the parent's CPU writes, so it has to be host visible */
		VkMemoryPropertyFlags want = i ? (VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT |
						  VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
					       : VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
		uint32_t bits = hp.memoryTypeBits;
		uint32_t type = pick_memory(rb, bits, want);
		if (type == UINT32_MAX)
			type = pick_memory(rb, bits, 0);
		if (type == UINT32_MAX && bits == 0) {
			/* The specification reads "one bit set for every memory type which the
			 * specified handle can be imported as", so zero means none at all —
			 * which cannot be true of a handle that came from this very card, and
			 * the in-process probe (§14) imports without asking. Take the buffer's
			 * own requirements instead and let vkAllocateMemory be the judge. */
			type = pick_memory(rb, ~0u, want);
			if (type != UINT32_MAX && i == 0)
				SAY("child: driver reported memoryTypeBits 0x0 for the handle; using "
				    "the buffer's own 0x%x instead",
				    rb.memoryTypeBits);
		}
		SAY("child: buffer %d: handle allows memoryTypeBits 0x%x -> type %u (needs 0x%x)",
		    i, bits, type, rb.memoryTypeBits);
		if (type == UINT32_MAX) {
			SAY("child: no usable memory type for the imported payload");
			return 1;
		}
		VkImportMemoryWin32HandleInfoKHR ihi = {
			.sType = VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR,
			.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
			.handle = mems[i],
		};
		VkMemoryAllocateInfo mai = {
			.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &ihi,
			.allocationSize = rb.size, .memoryTypeIndex = type,
		};
		VkDeviceMemory mb;
		if (vkAllocateMemory(b.dev, &mai, NULL, &mb) != VK_SUCCESS) {
			SAY("child: vkAllocateMemory (import %d) failed", i);
			return 1;
		}
		if (vkBindBufferMemory(b.dev, bb, mb, 0) != VK_SUCCESS) {
			SAY("child: vkBindBufferMemory failed");
			return 1;
		}
		bufs[i] = bb;
	}
	VkBuffer bb = bufs[0];
	VkBuffer bb2 = bufs[1];

	VkSemaphore wait_a2b = VK_NULL_HANDLE, sig_b2a = VK_NULL_HANDLE;
	for (int i = 0; i < 2; i++) {
		VkImportSemaphoreWin32HandleInfoKHR ishi = {
			.sType = VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR,
			.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
			.handle = i == 0 ? ha2b : hb2a,
		};
		VkSemaphoreCreateInfo sci = {
			.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &ishi,
		};
		VkSemaphore *out = i == 0 ? &wait_a2b : &sig_b2a;
		if (vkCreateSemaphore(b.dev, &sci, NULL, out) != VK_SUCCESS) {
			SAY("child: vkCreateSemaphore (import %d) failed", i);
			return 1;
		}
	}
	SAY("child: imported memory %llx and both semaphores",
	    (unsigned long long)(uintptr_t)hmem);

	while (read_line(hin, line, sizeof line)) {
		unsigned wrong;
		if (!strcmp(line, "quit")) {
			SAY("R 0 child done");
			break;
		} else if (!strcmp(line, "read aa sem")) {
			wrong = read_back(&b, bb, P_AA, wait_a2b);
			SAY("R %u child read 0xA5.. waiting the exported semaphore", wrong);
		} else if (!strcmp(line, "read ab nosem")) {
			wrong = read_back(&b, bb, P_AB, VK_NULL_HANDLE);
			SAY("R %u child read 0x3C.. with no semaphore at all", wrong);
		} else if (!strcmp(line, "read ba sem-async")) {
			wrong = read_back(&b, bb, P_BA, wait_a2b);
			SAY("R %u child read 0xC3.. semaphore only, parent never blocked", wrong);
		} else if (!strcmp(line, "read cc cpu")) {
			wrong = read_back(&b, bb2, P_CC, wait_a2b);
			SAY("R %u child read 0x0F.. written by the parent's CPU, no flush", wrong);
		} else if (!strcmp(line, "read dd cpu-flush")) {
			wrong = read_back(&b, bb2, P_DD, wait_a2b);
			SAY("R %u child read 0xF0.. written by the parent's CPU, flushed", wrong);
		} else if (!strcmp(line, "write bar")) {
			/* the return leg: the daemon's GPU produces the answer, the layer's CPU
			 * reads it. Nothing here waits on anything on the reading side. */
			if (!bb2) {
				SAY("R 999 child has no host-visible buffer to write");
				continue;
			}
			if (fill(&b, bb2, P_EE, VK_NULL_HANDLE, sig_b2a, 1)) {
				SAY("R 999 child fill (BAR) failed");
				continue;
			}
			SAY("R 0 child wrote 0x69.. into the shared BAR and signalled B->A");
		} else if (!strcmp(line, "write bb sem")) {
			if (fill(&b, bb, P_BB, VK_NULL_HANDLE, sig_b2a, 1)) {
				SAY("R 999 child fill failed");
				continue;
			}
			SAY("R 0 child wrote 0x5A.. and signalled B->A");
		} else {
			SAY("child: unknown command '%s'", line);
		}
		fflush(stdout);
	}
	return failures ? 1 : 0;
#undef SAY
}

/* ---------------------------------------------------------------- guest ---- */

/* The role the other side plays once libxmx can export: `guest <handle> <expect>`
 * imports a buffer the caller already exported, reads it back through its own device,
 * and reports how many bytes are not `expect`. It then writes 0x5A.. over it, so the
 * caller can check the write back the other way.
 *
 * This is the whole point of the exercise: the buffer was allocated by a different
 * process, on a device this process never saw being created. */
static int guest_main(const char *handle_hex, const char *expect_hex, const char *size_hex)
{
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
	g_pd = pick_intel(inst);
	if (!g_pd) {
		printf("guest: no Intel physical device\n");
		return 1;
	}
	struct side b = { 0 };
	if (make_side(&b))
		return 1;
	/* "-" means read the handle from stdin: the caller has to DuplicateHandle it into
	 * this process first, which it can only do once this process exists. */
	HANDLE hmem;
	if (!strcmp(handle_hex, "-")) {
		char line[64];
		if (!read_line(GetStdHandle(STD_INPUT_HANDLE), line, sizeof line)) {
			printf("guest: no handle on stdin\n");
			return 1;
		}
		hmem = h_from_str(line);
	} else {
		hmem = h_from_str(handle_hex);
	}
	unsigned expect = (unsigned)strtoul(expect_hex, NULL, 16) & 0xff;
	size_t bytes = strtoull(size_hex, NULL, 0);
	if (!bytes)
		bytes = SZ;

	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = bytes,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	VkBuffer bb;
	if (vkCreateBuffer(b.dev, &ci, NULL, &bb) != VK_SUCCESS) {
		printf("guest: vkCreateBuffer failed\n");
		return 1;
	}
	VkMemoryRequirements rb;
	vkGetBufferMemoryRequirements(b.dev, bb, &rb);
	/* the driver answers 0x0 here (see §15); fall back to what the buffer asks for */
	uint32_t type = pick_memory(rb, ~0u, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT |
					       VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
	if (type == UINT32_MAX)
		type = pick_memory(rb, ~0u, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
	if (type == UINT32_MAX)
		type = pick_memory(rb, ~0u, 0);
	VkImportMemoryWin32HandleInfoKHR ihi = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR,
		.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
		.handle = hmem,
	};
	VkMemoryAllocateInfo mai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .pNext = &ihi,
		.allocationSize = rb.size, .memoryTypeIndex = type,
	};
	VkDeviceMemory mb;
	if (vkAllocateMemory(b.dev, &mai, NULL, &mb) != VK_SUCCESS) {
		printf("guest: vkAllocateMemory (import) failed\n");
		return 1;
	}
	if (vkBindBufferMemory(b.dev, bb, mb, 0) != VK_SUCCESS) {
		printf("guest: vkBindBufferMemory failed\n");
		return 1;
	}
	printf("guest: imported %llu bytes from handle %s (memory type %u)\n",
	       (unsigned long long)bytes, handle_hex, type);

	/* read it back: does what the other process wrote look like what it wrote? */
	VkBufferCreateInfo hci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		.size = bytes, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
	};
	VkBuffer host;
	if (vkCreateBuffer(b.dev, &hci, NULL, &host) != VK_SUCCESS) {
		printf("guest: vkCreateBuffer (host) failed\n");
		return 1;
	}
	VkMemoryRequirements hr;
	vkGetBufferMemoryRequirements(b.dev, host, &hr);
	VkMemoryAllocateInfo hmai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		.allocationSize = hr.size, .memoryTypeIndex = b.host_type,
	};
	VkDeviceMemory hm;
	if (vkAllocateMemory(b.dev, &hmai, NULL, &hm) != VK_SUCCESS) {
		printf("guest: vkAllocateMemory (host) failed\n");
		return 1;
	}
	vkBindBufferMemory(b.dev, host, hm, 0);
	VkCommandBuffer cb = begin_cmd(&b);
	VkBufferCopy cp = { .size = bytes };
	vkCmdCopyBuffer(cb, bb, host, 1, &cp);
	if (end_cmd(&b, cb, NULL, NULL, 1)) {
		printf("guest: read-back submit failed\n");
		return 1;
	}
	unsigned char *p;
	if (vkMapMemory(b.dev, hm, 0, bytes, 0, (void **)&p) != VK_SUCCESS) {
		printf("guest: vkMapMemory failed\n");
		return 1;
	}
	unsigned wrong = 0;
	for (size_t i = 0; i < bytes; i++)
		if (p[i] != expect)
			wrong++;
	printf("guest: first bytes %02x %02x %02x %02x (wanted %02x)\n", p[0], p[1], p[2],
	       p[3], expect);
	vkUnmapMemory(b.dev, hm);
	printf("R %u of %llu bytes wrong\n", wrong, (unsigned long long)bytes);

	/* and write something the caller can check */
	cb = begin_cmd(&b);
	vkCmdFillBuffer(cb, bb, 0, bytes, P_BB);
	if (end_cmd(&b, cb, NULL, NULL, 1)) {
		printf("guest: fill failed\n");
		return 1;
	}
	printf("guest: wrote 0x5A.. back\n");
	return wrong ? 1 : 0;
}

/* What this card actually offers, read back rather than assumed.
 *
 * The point of printing it as a table is that binary and timeline semaphores report
 * separately — VK_KHR_timeline_semaphore resolves "Do we want to support external
 * sharing of the new synchronization primitive type?" with yes, and says the two may
 * have different handle types. They are also governed by different rules once shared:
 * a binary semaphore may only be waited on if it is signalled or has a signal already
 * submitted, whereas a timeline one may be waited on before anything signals it. So
 * which of the two this card can share decides what Phase 2 is allowed to do. */
static int caps_main(void)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
	g_pd = pick_intel(inst);
	if (!g_pd) {
		printf("no Intel physical device\n");
		return 1;
	}
	struct {
		const char *name;
		VkExternalSemaphoreHandleTypeFlagBits type;
	} st[] = {
		{ "opaque_win32", VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT },
		{ "opaque_win32_kmt", VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT },
		{ "d3d12_fence", VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT },
	};
	VkSemaphoreTypeCreateInfo tl = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO,
		.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE,
		.initialValue = 0,
	};
	VkSemaphoreTypeCreateInfo bin = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO,
		.semaphoreType = VK_SEMAPHORE_TYPE_BINARY,
	};
	printf("external semaphore, as reported by the driver\n");
	printf("%-18s %-9s %-6s %-6s\n", "handle type", "sem type", "export", "import");
	for (size_t i = 0; i < sizeof st / sizeof st[0]; i++)
		for (int t = 0; t < 2; t++) {
			VkSemaphoreTypeCreateInfo *stci = t ? &tl : &bin;
			VkPhysicalDeviceExternalSemaphoreInfo esi = {
				.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO,
				.pNext = stci,
				.handleType = st[i].type,
			};
			VkExternalSemaphoreProperties esp = {
				.sType = VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES,
			};
			vkGetPhysicalDeviceExternalSemaphoreProperties(g_pd, &esi, &esp);
			VkExternalSemaphoreFeatureFlags f = esp.externalSemaphoreFeatures;
			printf("%-18s %-9s %-6d %-6d\n", st[i].name, t ? "timeline" : "binary",
			       !!(f & VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT),
			       !!(f & VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT));
		}
	struct {
		const char *name;
		VkExternalFenceHandleTypeFlagBits type;
	} ft[] = {
		{ "opaque_win32", VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT },
		{ "opaque_win32_kmt", VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT },
	};
	printf("\nexternal fence\n");
	printf("%-18s %-6s %-6s\n", "handle type", "export", "import");
	for (size_t i = 0; i < sizeof ft / sizeof ft[0]; i++) {
		VkPhysicalDeviceExternalFenceInfo efi = {
			.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO,
			.handleType = ft[i].type,
		};
		VkExternalFenceProperties efp = {
			.sType = VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES,
		};
		vkGetPhysicalDeviceExternalFenceProperties(g_pd, &efi, &efp);
		VkExternalFenceFeatureFlags f = efp.externalFenceFeatures;
		printf("%-18s %-6d %-6d\n", ft[i].name,
		       !!(f & VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT),
		       !!(f & VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT));
	}
	return 0;
}

/* -------------------------------------------------------------- parent ---- */

static int export_semaphore(struct side *a, VkSemaphore *sem, HANDLE *handle, int timeline)
{
	VkExportSemaphoreCreateInfo esci = {
		.sType = VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO,
		.handleTypes = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkSemaphoreTypeCreateInfo stci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO, .pNext = &esci,
		.semaphoreType = timeline ? VK_SEMAPHORE_TYPE_TIMELINE : VK_SEMAPHORE_TYPE_BINARY,
	};
	VkSemaphoreCreateInfo sci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &stci,
	};
	TRY("vkCreateSemaphore (export)", vkCreateSemaphore(a->dev, &sci, NULL, sem));
	PFN_vkGetSemaphoreWin32HandleKHR get = (PFN_vkGetSemaphoreWin32HandleKHR)
		vkGetDeviceProcAddr(a->dev, "vkGetSemaphoreWin32HandleKHR");
	if (!get) {
		printf("  FAIL vkGetSemaphoreWin32HandleKHR absent\n");
		return 1;
	}
	VkSemaphoreGetWin32HandleInfoKHR ghi = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_GET_WIN32_HANDLE_INFO_KHR,
		.semaphore = *sem,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	TRY("vkGetSemaphoreWin32HandleKHR", get(a->dev, &ghi, handle));
	return 0;
}

/* Does a wait on a semaphore actually hold a submit back on this card?
 *
 * Two batches go in, in this order: the first waits on a semaphore nobody has signalled
 * yet, the second signals it — but only after `ms`. If the wait is real, the first
 * cannot run until the second has gone in, so (a) waiting for it takes at least `ms`
 * and (b) the buffer ends up holding the first batch's pattern, because the second
 * ran first. If the wait is ignored, both are immediate and the second wins.
 *
 * Nothing here crosses a process boundary, so whatever it says is about the driver. */
static int waittest(struct side *s, unsigned long ms)
{
	VkExportSemaphoreCreateInfo esci = {
		.sType = VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO,
		.handleTypes = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkSemaphoreCreateInfo sci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &esci,
	};
	VkSemaphore sem;
	TRY("vkCreateSemaphore", vkCreateSemaphore(s->dev, &sci, NULL, &sem));

	VkBufferCreateInfo ci = {
		.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = SZ,
		.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
		.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
	};
	VkBuffer buf;
	TRY("vkCreateBuffer", vkCreateBuffer(s->dev, &ci, NULL, &buf));
	VkMemoryRequirements r;
	vkGetBufferMemoryRequirements(s->dev, buf, &r);
	uint32_t mt = pick_memory(r, r.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
	VkMemoryAllocateInfo mai = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = r.size,
		.memoryTypeIndex = mt,
	};
	VkDeviceMemory mem;
	TRY("vkAllocateMemory", vkAllocateMemory(s->dev, &mai, NULL, &mem));
	vkBindBufferMemory(s->dev, buf, mem, 0);

	VkCommandBuffer cb1 = begin_cmd(s);
	vkCmdFillBuffer(cb1, buf, 0, SZ, P_EE);
	vkEndCommandBuffer(cb1);
	VkFenceCreateInfo fci = { .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
	VkFence f1, f2;
	vkCreateFence(s->dev, &fci, NULL, &f1);
	vkCreateFence(s->dev, &fci, NULL, &f2);
	VkPipelineStageFlags stage = VK_PIPELINE_STAGE_TRANSFER_BIT;
	VkSubmitInfo si1 = {
		.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1,
		.pCommandBuffers = &cb1, .waitSemaphoreCount = 1, .pWaitSemaphores = &sem,
		.pWaitDstStageMask = &stage,
	};
	LARGE_INTEGER t0, t1, freq;
	QueryPerformanceFrequency(&freq);
	QueryPerformanceCounter(&t0);
	TRY("vkQueueSubmit (waited)", vkQueueSubmit(s->queue, 1, &si1, f1));
	Sleep(ms);
	VkCommandBuffer cb2 = begin_cmd(s);
	vkCmdFillBuffer(cb2, buf, 0, SZ, P_AA);
	vkEndCommandBuffer(cb2);
	VkSubmitInfo si2 = {
		.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1,
		.pCommandBuffers = &cb2, .signalSemaphoreCount = 1, .pSignalSemaphores = &sem,
	};
	TRY("vkQueueSubmit (signalling)", vkQueueSubmit(s->queue, 1, &si2, f2));
	VkResult w = vkWaitForFences(s->dev, 1, &f1, VK_TRUE, ~(uint64_t)0);
	QueryPerformanceCounter(&t1);
	double elapsed = (double)(t1.QuadPart - t0.QuadPart) / (double)freq.QuadPart * 1000.0;
	vkWaitForFences(s->dev, 1, &f2, VK_TRUE, ~(uint64_t)0);
	if (w != VK_SUCCESS) {
		printf("R 999 waited submit never finished: %d\n", (int)w);
		return 1;
	}
	/* Both batches go to one queue, so they run in the order they were submitted: the
	 * waited one first, once the semaphore lets it. Being held back does not reorder
	 * them, so the pattern left behind is the second batch's either way — it is here
	 * to show both really ran, while the elapsed time is what decides the question. */
	unsigned after_aa = read_back(s, buf, P_AA, VK_NULL_HANDLE);
	printf("R 0 waited submit finished %.1f ms in (signalled after %lu ms); buffer "
	       "holds the second batch's pattern, %u bytes differ\n",
	       elapsed, ms, after_aa);
	vkDestroyFence(s->dev, f1, NULL);
	vkDestroyFence(s->dev, f2, NULL);
	vkDestroySemaphore(s->dev, sem, NULL);
	vkFreeMemory(s->dev, mem, NULL);
	vkDestroyBuffer(s->dev, buf, NULL);
	return (elapsed >= 0.8 * (double)ms && after_aa == 0) ? 0 : 1;
}

/* The mirror of semhost: take a semaphore *somebody else* exported and signal it from
 * here. `src/bench/check_extmem_export_sem.py` uses it to ask whether a semaphore
 * libxmx exported behaves like one this probe exported — the same payload shared the
 * other way round is not something the earlier test covered, and libxmx is the side
 * that will own it in Phase 2. */
static int sigpeer_main(void)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
	g_pd = pick_intel(inst);
	if (!g_pd) {
		printf("sigpeer: no Intel physical device\n");
		return 1;
	}
	struct side b = { 0 };
	if (make_side(&b))
		return 1;
	HANDLE hin = GetStdHandle(STD_INPUT_HANDLE);
	char line[256];
	if (!read_line(hin, line, sizeof line)) {
		printf("sigpeer: no handle arrived\n");
		return 1;
	}
	unsigned long long hv = 0;
	if (sscanf(line, "sem %llx", &hv) != 1 || !hv) {
		printf("sigpeer: bad handle line '%s'\n", line);
		return 1;
	}
	/* A timeline semaphore, because that is what libxmx exports: importing one handle
	 * as the wrong kind is refused, and the two cannot be told apart from the number. */
	VkSemaphoreTypeCreateInfo stci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO,
		.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE,
	};
	VkSemaphoreCreateInfo sci = {
		.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO, .pNext = &stci,
	};
	VkSemaphore sem = VK_NULL_HANDLE;
	if (vkCreateSemaphore(b.dev, &sci, NULL, &sem) != VK_SUCCESS) {
		printf("sigpeer: vkCreateSemaphore failed\n");
		return 1;
	}
	PFN_vkImportSemaphoreWin32HandleKHR imp = (PFN_vkImportSemaphoreWin32HandleKHR)
		vkGetDeviceProcAddr(b.dev, "vkImportSemaphoreWin32HandleKHR");
	if (!imp) {
		printf("sigpeer: vkImportSemaphoreWin32HandleKHR absent\n");
		return 1;
	}
	VkImportSemaphoreWin32HandleInfoKHR ii = {
		.sType = VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR,
		.semaphore = sem,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
		.handle = (HANDLE)(uintptr_t)hv,
	};
	if (imp(b.dev, &ii) != VK_SUCCESS) {
		printf("sigpeer: import failed\n");
		return 1;
	}
	printf("READY\n");
	fflush(stdout);

	while (read_line(hin, line, sizeof line)) {
		unsigned long ms = 0;
		unsigned long long value = 0;
		if (!strcmp(line, "quit")) {
			printf("R 0 sigpeer done\n");
			break;
		} else if (sscanf(line, "signal %llu after %lu", &value, &ms) == 2) {
			Sleep(ms);
			PFN_vkSignalSemaphore sig = (PFN_vkSignalSemaphore)
				vkGetDeviceProcAddr(b.dev, "vkSignalSemaphore");
			if (!sig) {
				printf("R 999 vkSignalSemaphore absent\n");
				continue;
			}
			VkSemaphoreSignalInfo ssi = {
				.sType = VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO,
				.semaphore = sem, .value = value,
			};
			VkResult r = sig(b.dev, &ssi);
			if (r) {
				printf("R 999 vkSignalSemaphore failed (%d)\n", r);
				continue;
			}
			printf("R 0 signalled %llu after %lu ms\n", value, ms);
		} else {
			printf("sigpeer: unknown command '%s'\n", line);
		}
		fflush(stdout);
	}
	return 0;
}

/* The layer's half of Phase 2, standing on its own: make a semaphore somebody else can
 * wait on, hand it to the process whose pid we are given, and signal it only after a
 * delay. A submit that really waits on it cannot finish before the delay is up, and one
 * that ignores it finishes at once — that difference is the whole point of this role.
 *
 * `semhost <parent-pid>`; it prints `S <handle>` and then takes `signal-after <ms>`. */
static int semhost_main(unsigned long parent_pid, int timeline)
{
	setvbuf(stdout, NULL, _IONBF, 0);
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
	g_pd = pick_intel(inst);
	if (!g_pd) {
		printf("semhost: no Intel physical device\n");
		return 1;
	}
	struct side b = { 0 };
	if (make_side(&b))
		return 1;
	VkSemaphore sem = VK_NULL_HANDLE;
	HANDLE hsem = NULL;
	if (export_semaphore(&b, &sem, &hsem, timeline)) {
		printf("semhost: could not export a semaphore\n");
		return 1;
	}
	HANDLE parent = OpenProcess(PROCESS_DUP_HANDLE, FALSE, (DWORD)parent_pid);
	if (!parent) {
		printf("semhost: OpenProcess(%lu) failed: %lu\n", parent_pid, GetLastError());
		return 1;
	}
	HANDLE dup = NULL;
	if (!DuplicateHandle(GetCurrentProcess(), hsem, parent, &dup, 0, FALSE,
			     DUPLICATE_SAME_ACCESS)) {
		printf("semhost: DuplicateHandle failed: %lu\n", GetLastError());
		CloseHandle(parent);
		return 1;
	}
	CloseHandle(parent);
	printf("S %llx\n", (unsigned long long)(uintptr_t)dup);
	fflush(stdout);

	HANDLE hin = GetStdHandle(STD_INPUT_HANDLE);
	char line[256];
	while (read_line(hin, line, sizeof line)) {
		unsigned long ms = 0;
		if (!strcmp(line, "quit")) {
			printf("R 0 semhost done\n");
			break;
		} else if (sscanf(line, "waittest %lu", &ms) == 1) {
			return waittest(&b, ms);
		} else if (sscanf(line, "signal-after %lu", &ms) == 1) {
			Sleep(ms);
			if (timeline) {
				/* The host can advance a timeline semaphore directly, with no GPU
				 * work of its own — which is the whole reason the layer can say
				 * "the bytes are there" without submitting anything. */
				PFN_vkSignalSemaphore sig = (PFN_vkSignalSemaphore)
					vkGetDeviceProcAddr(b.dev, "vkSignalSemaphore");
				if (!sig) {
					printf("R 999 vkSignalSemaphore absent\n");
					continue;
				}
				VkSemaphoreSignalInfo ssi = {
					.sType = VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO,
					.semaphore = sem, .value = 1,
				};
				VkResult sr = sig(b.dev, &ssi);
				if (sr) {
					printf("R 999 vkSignalSemaphore failed (%d)\n", sr);
					continue;
				}
			} else {
				VkCommandBuffer cb = begin_cmd(&b);
				if (!cb || end_cmd(&b, cb, VK_NULL_HANDLE, sem, 1)) {
					printf("R 999 semhost signal failed\n");
					continue;
				}
			}
			printf("R 0 signalled after %lu ms\n", ms);
		} else {
			printf("semhost: unknown command '%s'\n", line);
		}
		fflush(stdout);
	}
	CloseHandle(hsem);
	return failures ? 1 : 0;
}

/* Read from the child until a result line arrives, echoing whatever else it says.
 * `until`, when given, stops at the first line containing that text instead — the
 * handshake at start-up has no result line to wait for.
 * Returns 0 on success, 1 if the child went quiet. */
static int collect(HANDLE rd, unsigned *wrong, int *bad, const char *until)
{
	/* The child writes commentary lines as well as its result line, so keep reading
	 * until a result arrives — otherwise the result of command N shows up under
	 * command N+1, which reads exactly like a synchronisation failure and is not one. */
	for (int i = 0; i < 16; i++) {
		char line[256];
		if (!read_line(rd, line, sizeof line)) {
			printf("  FAIL child stopped answering\n");
			*bad = 1;
			return 1;
		}
		if (line[0] == 'R' && line[1] == ' ') {
			unsigned n = (unsigned)strtoul(line + 2, NULL, 10);
			*wrong += n;
			printf("  %s\n", line + 2);
			return 0;
		}
		printf("  child: %s\n", line);
		if (until && strstr(line, until))
			return 0;
	}
	printf("  FAIL child sent %s but never got there\n", until ? until : "a result");
	*bad = 1;
	return 1;
}

static int parent_main(void)
{
	int bad = 0;
	unsigned wrong = 0;

	setvbuf(stdout, NULL, _IONBF, 0);

	uint32_t n = 0;
	VkInstance inst = make_instance();
	if (!inst)
		return 1;
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

	printf("\n[1] what the driver promises for handles that cross processes\n");
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
	printf("  buffer  opaque_win32: exportable=%d importable=%d\n",
	       !!(f & VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT),
	       !!(f & VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT));
	VkPhysicalDeviceExternalSemaphoreInfo esi = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO,
		.handleType = VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkExternalSemaphoreProperties esp = {
		.sType = VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES,
	};
	vkGetPhysicalDeviceExternalSemaphoreProperties(g_pd, &esi, &esp);
	VkExternalSemaphoreFeatureFlags sf = esp.externalSemaphoreFeatures;
	printf("  semaphore opaque_win32: exportable=%d importable=%d\n",
	       !!(sf & VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT),
	       !!(sf & VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT));
	VkPhysicalDeviceExternalFenceInfo efi = {
		.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO,
		.handleType = VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	VkExternalFenceProperties efp = { .sType = VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES };
	vkGetPhysicalDeviceExternalFenceProperties(g_pd, &efi, &efp);
	VkExternalFenceFeatureFlags ff = efp.externalFenceFeatures;
	printf("  fence    opaque_win32: exportable=%d importable=%d\n",
	       !!(ff & VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT),
	       !!(ff & VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT));

	printf("\n[2] parent: exportable buffer and two semaphores\n");
	struct side a = { 0 };
	if (make_side(&a))
		return 1;
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
	uint32_t type = pick_memory(ra, ~0u, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
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
	TRY("vkBindBufferMemory", vkBindBufferMemory(a.dev, ba, ma, 0));

	PFN_vkGetMemoryWin32HandleKHR get_handle = (PFN_vkGetMemoryWin32HandleKHR)
		vkGetDeviceProcAddr(a.dev, "vkGetMemoryWin32HandleKHR");
	if (!get_handle) {
		printf("  FAIL vkGetMemoryWin32HandleKHR absent\n");
		return 1;
	}
	VkMemoryGetWin32HandleInfoKHR ghi = {
		.sType = VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR,
		.memory = ma,
		.handleType = VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
	};
	HANDLE hmem = NULL;
	TRY("vkGetMemoryWin32HandleKHR", get_handle(a.dev, &ghi, &hmem));
	VkSemaphore a2b, b2a;
	HANDLE ha2b = NULL, hb2a = NULL;
	if (export_semaphore(&a, &a2b, &ha2b, 0) || export_semaphore(&a, &b2a, &hb2a, 0))
		return 1;
	printf("  memory handle %p (%llu bytes), semaphores %p and %p\n", (void *)hmem,
	       (unsigned long long)ra.size, (void *)ha2b, (void *)hb2a);

	/* A second buffer, this one host visible: DEVICE_LOCAL|HOST_VISIBLE is the BAR
	 * mapping on this card (type 3, 15.9 GiB heap), and whether a byte the CPU puts
	 * there is what another process's GPU reads is the whole of Phase 2 — and the
	 * standing suspicion behind the NR_INPUT_VIEW NaN (notes §5). */
	VkBuffer ba2 = VK_NULL_HANDLE;
	VkDeviceMemory ma2 = VK_NULL_HANDLE;
	HANDLE hmem2 = NULL;
	{
		VkBufferCreateInfo ci2 = {
			.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .pNext = &embi,
			.size = SZ,
			.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT |
				 VK_BUFFER_USAGE_TRANSFER_DST_BIT,
			.sharingMode = VK_SHARING_MODE_EXCLUSIVE,
		};
		VkMemoryRequirements r2;
		if (vkCreateBuffer(a.dev, &ci2, NULL, &ba2) == VK_SUCCESS) {
			vkGetBufferMemoryRequirements(a.dev, ba2, &r2);
			uint32_t t2 = pick_memory(r2, ~0u,
						  VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT |
							  VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);
			if (t2 == UINT32_MAX) {
				printf("  no DEVICE_LOCAL|HOST_VISIBLE type: [8] will be skipped\n");
				vkDestroyBuffer(a.dev, ba2, NULL);
				ba2 = VK_NULL_HANDLE;
			} else {
				VkMemoryAllocateInfo mai2 = {
					.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
					.pNext = &emai, .allocationSize = r2.size,
					.memoryTypeIndex = t2,
				};
				if (vkAllocateMemory(a.dev, &mai2, NULL, &ma2) != VK_SUCCESS ||
				    vkBindBufferMemory(a.dev, ba2, ma2, 0) != VK_SUCCESS) {
					printf("  FAIL: could not allocate the host-visible buffer\n");
					return 1;
				}
				VkMemoryGetWin32HandleInfoKHR g2 = {
					.sType =
						VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR,
					.memory = ma2,
					.handleType =
						VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT,
				};
				if (get_handle(a.dev, &g2, &hmem2) != VK_SUCCESS) {
					printf("  FAIL: could not export the host-visible buffer\n");
					return 1;
				}
				VkPhysicalDeviceMemoryProperties mp;
				vkGetPhysicalDeviceMemoryProperties(g_pd, &mp);
				printf("  cpu-writable buffer: memory type %u (flags 0x%x), handle %p\n",
				       t2, mp.memoryTypes[t2].propertyFlags, (void *)hmem2);
			}
		}
	}

	printf("\n[3] spawn the child and hand it the handles\n");
	char exe[MAX_PATH];
	GetModuleFileNameA(NULL, exe, MAX_PATH);
	SECURITY_ATTRIBUTES sa = { sizeof sa, NULL, TRUE };
	HANDLE in_rd = NULL, in_wr = NULL, out_rd = NULL, out_wr = NULL;
	if (!CreatePipe(&out_rd, &out_wr, &sa, 0) || !CreatePipe(&in_rd, &in_wr, &sa, 0)) {
		printf("  FAIL CreatePipe: %lu\n", GetLastError());
		return 1;
	}
	/* mark the Vulkan handles inheritable too, so that inheritance is available as
	 * a fallback; DuplicateHandle is tried first and reported separately */
	SetHandleInformation(hmem, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT);
	SetHandleInformation(ha2b, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT);
	SetHandleInformation(hb2a, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT);
	if (hmem2)
		SetHandleInformation(hmem2, HANDLE_FLAG_INHERIT, HANDLE_FLAG_INHERIT);

	STARTUPINFOA si = { 0 };
	si.cb = sizeof si;
	si.dwFlags = STARTF_USESTDHANDLES;
	si.hStdInput = in_rd;
	si.hStdOutput = out_wr;
	si.hStdError = out_wr;
	PROCESS_INFORMATION pi = { 0 };
	char cmdline[512];
	snprintf(cmdline, sizeof cmdline, "\"%s\" child", exe);
	if (!CreateProcessA(exe, cmdline, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi)) {
		printf("  FAIL CreateProcess: %lu\n", GetLastError());
		return 1;
	}
	CloseHandle(out_wr);
	CloseHandle(in_rd);

	int dup_ok = 1;
	HANDLE dmem = NULL, da2b = NULL, db2a = NULL, dmem2 = NULL;
	if (!DuplicateHandle(GetCurrentProcess(), hmem, pi.hProcess, &dmem, 0, FALSE,
			     DUPLICATE_SAME_ACCESS))
		dup_ok = 0;
	if (hmem2 && !DuplicateHandle(GetCurrentProcess(), hmem2, pi.hProcess, &dmem2, 0,
				      FALSE, DUPLICATE_SAME_ACCESS))
		dup_ok = 0;
	if (!DuplicateHandle(GetCurrentProcess(), ha2b, pi.hProcess, &da2b, 0, FALSE,
			     DUPLICATE_SAME_ACCESS))
		dup_ok = 0;
	if (!DuplicateHandle(GetCurrentProcess(), hb2a, pi.hProcess, &db2a, 0, FALSE,
			     DUPLICATE_SAME_ACCESS))
		dup_ok = 0;
	if (dup_ok)
		printf("  DuplicateHandle into the child worked (memory %p -> %p)\n",
		       (void *)hmem, (void *)dmem);
	else
		printf("  DuplicateHandle refused (last error %lu); falling back to the "
		       "inherited values\n",
		       GetLastError());

	{
		char hand[200];
		snprintf(hand, sizeof hand, "handles %llx %llx %llx %llx",
			 (unsigned long long)(uintptr_t)(dup_ok ? dmem : hmem),
			 (unsigned long long)(uintptr_t)(hmem2 ? (dup_ok ? dmem2 : hmem2)
								 : 0),
			 (unsigned long long)(uintptr_t)(dup_ok ? da2b : ha2b),
			 (unsigned long long)(uintptr_t)(dup_ok ? db2a : hb2a));
		write_line(in_wr, hand);
	}

	/* Child opens with its device line and the memory type it picked; read until it
	 * says the import worked. */
	if (collect(out_rd, &wrong, &bad, "imported"))
		return 1;
	if (bad)
		return 1;

	printf("\n[4] parent fills, child reads, dependency carried by a semaphore\n");
	if (fill(&a, ba, P_AA, VK_NULL_HANDLE, a2b, 1))
		return 1;
	write_line(in_wr, "read aa sem");
	collect(out_rd, &wrong, &bad, NULL);

	printf("\n[5] parent fills, child reads, no semaphore (expected to be undefined)\n");
	if (fill(&a, ba, P_AB, VK_NULL_HANDLE, VK_NULL_HANDLE, 1))
		return 1;
	write_line(in_wr, "read ab nosem");
	collect(out_rd, &wrong, &bad, NULL);

	printf("\n[6] parent fills and signals but does not wait; child still reads\n");
	if (fill(&a, ba, P_BA, VK_NULL_HANDLE, a2b, 1))
		return 1;
	write_line(in_wr, "read ba sem-async");
	collect(out_rd, &wrong, &bad, NULL);

	printf("\n[7] child fills, parent reads, dependency carried the other way\n");
	write_line(in_wr, "write bb sem");
	collect(out_rd, &wrong, &bad, NULL);
	{
		unsigned w = read_back(&a, ba, P_BB, b2a);
		printf("  R %u parent read 0x5A.. waiting the imported semaphore\n", w);
		wrong += w;
	}

	if (hmem2) {
		/* An empty batch that signals a2b puts the child's read after the CPU's
		 * writes: the writes are not in any queue, so this is the only thing that
		 * orders them. */
		printf("\n[8] the parent's CPU writes the BAR; the child's GPU reads it\n");
		void *p = NULL;
		if (vkMapMemory(a.dev, ma2, 0, SZ, 0, &p) != VK_SUCCESS) {
			printf("  FAIL vkMapMemory\n");
			return 1;
		}
		memset(p, (int)(P_CC & 0xff), SZ);
		vkUnmapMemory(a.dev, ma2);
		{
			VkCommandBuffer cb = begin_cmd(&a);
			end_cmd(&a, cb, VK_NULL_HANDLE, a2b, 1);
		}
		write_line(in_wr, "read cc cpu");
		collect(out_rd, &wrong, &bad, NULL);

		printf("\n[9] the same, but flushing the range before unmapping\n");
		if (vkMapMemory(a.dev, ma2, 0, SZ, 0, &p) != VK_SUCCESS) {
			printf("  FAIL vkMapMemory\n");
			return 1;
		}
		memset(p, (int)(P_DD & 0xff), SZ);
		VkMappedMemoryRange rng = {
			.sType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
			.memory = ma2, .offset = 0, .size = SZ,
		};
		vkFlushMappedMemoryRanges(a.dev, 1, &rng);
		vkUnmapMemory(a.dev, ma2);
		{
			VkCommandBuffer cb = begin_cmd(&a);
			end_cmd(&a, cb, VK_NULL_HANDLE, a2b, 1);
		}
		write_line(in_wr, "read dd cpu-flush");
		collect(out_rd, &wrong, &bad, NULL);

		/* The return leg, which is how the answer would come back: the daemon's GPU
		 * writes it, and the layer's CPU reads the very same bytes with no semaphore
		 * wait and no invalidate — only the pipe says the work is done. */
		printf("\n[10] the child's GPU writes the BAR; the parent's CPU reads it\n");
		write_line(in_wr, "write bar");
		collect(out_rd, &wrong, &bad, NULL);
		void *p2 = NULL;
		if (vkMapMemory(a.dev, ma2, 0, SZ, 0, &p2) != VK_SUCCESS) {
			printf("  FAIL vkMapMemory\n");
			return 1;
		}
		const unsigned char *q = p2;
		unsigned char want = (unsigned char)(P_EE & 0xff);
		unsigned w = 0;
		for (unsigned i = 0; i < SZ; i++)
			if (q[i] != want)
				w++;
		printf("      first bytes: %02x %02x %02x %02x (wanted %02x)\n", q[0], q[1],
		       q[2], q[3], want);
		printf("  R %u parent CPU read 0x69.. the child's GPU wrote, no wait at all\n",
		       w);
		wrong += w;
		vkUnmapMemory(a.dev, ma2);
	}

	write_line(in_wr, "quit");
	collect(out_rd, &wrong, &bad, NULL);
	WaitForSingleObject(pi.hProcess, 5000);
	DWORD code = 0;
	GetExitCodeProcess(pi.hProcess, &code);
	printf("  child exit code %lu\n", (unsigned long)code);
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	CloseHandle(in_wr);
	CloseHandle(out_rd);
	CloseHandle(hmem);
	CloseHandle(ha2b);
	CloseHandle(hb2a);

	printf("\n  total bytes wrong across both processes: %u\n", wrong);
	if (wrong || bad || failures) {
		printf("\nPROBE FAILED\n");
		return 1;
	}
	printf("\nPROBE OK: two processes share one buffer on this card\n");
	return 0;
}

int main(int argc, char **argv)
{
	if (argc >= 2 && !strcmp(argv[1], "caps"))
		return caps_main();
	if (argc >= 2 && !strcmp(argv[1], "child"))
		return child_main();
	if (argc >= 3 && !strcmp(argv[1], "semhost"))
		/* `semhost <parent-pid> [timeline]` — a timeline semaphore is signalled from
		 * the host rather than by a submitted batch. */
		return semhost_main(strtoul(argv[2], NULL, 10),
				   argc >= 4 && !strcmp(argv[3], "timeline"));
	if (argc >= 2 && !strcmp(argv[1], "sigpeer"))
		/* takes the handle on stdin, not the command line: it is duplicated in after
		 * this process is already running */
		return sigpeer_main();
	if (argc >= 4 && !strcmp(argv[1], "guest"))
		return guest_main(argv[2], argv[3], argc >= 5 ? argv[4] : "0");
	if (argc >= 2 && strcmp(argv[1], "guest") && strcmp(argv[1], "child")) {
		printf("usage: %s [guest <handle-hex> <expect-hex> [bytes] | child]\n", argv[0]);
		return 1;
	}
	return parent_main();
}
