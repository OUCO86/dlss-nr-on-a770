/* nr_extmem.h — the layer's own device on the card that does the work.
 *
 * The layer lives in the game's process and already has a VkDevice there: the one the
 * game made, on the card that renders. The Neural Renderer runs on the *other* card,
 * and nothing in the game's device can reach it. So the layer makes a second device of
 * its own, on the Intel card, purely to hold a mapping onto the two buffers the daemon
 * put the frame in and the answer in. The frame then never crosses to the CPU at all:
 * the layer writes the raw bytes into the daemon's own input buffer, and reads the
 * answer out of the daemon's own output buffer.
 *
 * That is the whole point of Phase 2 — `notes/phase2-extmem-design.md`. What it
 * replaces is a file mapping: the layer memcpy'd 8.29 MB in, the daemon read it, the
 * daemon memcpy'd 8.29 MB back, the layer read that. Both copies go away, and so does
 * the pipe's part in carrying them.
 *
 * ⚠ Everything here fails soft. `nrx_open` returning anything but 0 leaves `nrx_ready()`
 * false, and the caller sends the frame the way it always has. A second device in a
 * game's process is the one thing in this design nobody has measured, and the cost of
 * being wrong about it must be a fallback, not a crash.
 *
 * Windows only. The header is included unconditionally so the layer's call sites
 * compile unchanged on Linux, where every function is a no-op that says no.
 */
#ifndef NR_EXTMEM_H
#define NR_EXTMEM_H

#include <stddef.h>

#ifdef _WIN32

/* Take over the buffers and the semaphore the daemon duplicated to this process, and
 * map the buffers. `*_bytes` are the sizes the daemon created them with; the import
 * allocates that much. Returns 0, or -1 with `nrx_error()` set.
 *
 * `answer_handle` may be 0: the answer crossing in a slot in the file mapping is the
 * ordinary way still, and the half of this that is built first — the frame going into
 * the daemon's buffer instead of the mapping — needs the frame's buffer and the
 * semaphore and nothing else. `nrx_answer()` then says no for the whole session.
 *
 * The semaphore is a timeline semaphore: binary semaphores may not be waited on before
 * their signal has been submitted (VUID-vkQueueSubmit-pWaitSemaphores-03238), which is
 * exactly the shape of "the frame is on its way" — see refs/vulkan-sync/README.md. */
int nrx_open(unsigned long long raw_handle, unsigned long long raw_bytes,
	     unsigned long long answer_handle, unsigned long long answer_bytes,
	     unsigned long long sem_handle);

/* Where to write the frame, and how much fits. NULL while not ready. */
void *nrx_raw(size_t *bytes);

/* Where the answer will be. NULL while not ready. */
void *nrx_answer(size_t *bytes);

/* Tell the daemon the frame is there. `value` is the frame number: a timeline
 * semaphore's payload only ever increases (its spec's Issue 4), so counting is the
 * only thing to count. */
int nrx_signal(unsigned long long value);

/* Give the mapping back. Safe to call when nothing was opened. */
void nrx_close(void);

/* Whether a frame may go this way. */
int nrx_ready(void);

/* Why the last call failed, or NULL. */
const char *nrx_error(void);

#else

static int nrx_open(unsigned long long a, unsigned long long b, unsigned long long c,
		    unsigned long long d, unsigned long long e)
{
	(void)a; (void)b; (void)c; (void)d; (void)e;
	return -1;
}
static void *nrx_raw(size_t *bytes) { if (bytes) *bytes = 0; return NULL; }
static void *nrx_answer(size_t *bytes) { if (bytes) *bytes = 0; return NULL; }
static int nrx_signal(unsigned long long v) { (void)v; return -1; }
static void nrx_close(void) { }
static int nrx_ready(void) { return 0; }
static const char *nrx_error(void) { return "external memory is Windows only"; }

#endif

#endif
