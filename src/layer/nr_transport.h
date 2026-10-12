/* nr_transport.h — the frame transport, in one place.
 *
 * Upstream this project talks to the daemon over a Unix socket, which is what the
 * Linux build does (NR_TRANSPORT_UNIX below, the default there). On Windows the same
 * conversation has to happen over a named pipe: Winsock's AF_UNIX exists but cannot
 * bind here (measured: bind() fails WSAENETDOWN 10050), and CPython on Windows does
 * not expose socket.AF_UNIX at all, so the daemon side could not answer even if the
 * layer could ask. A named pipe is the transport both ends can reach.
 *
 * Only the transport is different. The bytes on the wire — 16-byte header, then the
 * colour, then the interface mask for a masked frame — are unchanged, so a daemon on
 * either platform speaks the same protocol.
 *
 * The pipe is opened in byte mode and read with PeekNamedPipe + a deadline, because a
 * named pipe has no SO_RCVTIMEO: a blocking ReadFile waits forever when the daemon has
 * nothing to say, which is what the Unix build's 60-second timeout exists to prevent.
 */
#ifndef NR_TRANSPORT_H
#define NR_TRANSPORT_H

#ifdef _WIN32

#include <windows.h>
#include <stdint.h>
#include <string.h>      /* memcpy, memset: the mapping is copied into and out of */
#include <stdio.h>   /* snprintf, used by both arms */

/* One connected endpoint. `handle` is a pipe handle; `deadline` is the same
 * whole-exchange budget the Unix build gives SO_SNDTIMEO/SO_RCVTIMEO. */
typedef struct {
	HANDLE handle;
	DWORD deadline_ms;
} nr_link;

/* A wait of one millisecond is only one millisecond if somebody has asked for one:
 * the timer Windows keeps otherwise is 15.6 ms, and then a Sleep(1) costs sixteen
 * and the layer's wait for the answer — the whole of the daemon's time for the frame —
 * is spent in steps that size. Asked once, when the layer first connects, and left
 * asked: it is a per-process count that the process's own exit undoes.
 *
 * winmm is loaded rather than linked, so building the layer needs no import library.
 */
static void nr_link_timer(void)
{
	HMODULE winmm = LoadLibraryA("winmm.dll");
	if (!winmm) return;
	UINT (*begin)(UINT) = (UINT (*)(UINT))(void *)GetProcAddress(winmm,
								     "timeBeginPeriod");
	if (begin) begin(1);
}

static int nr_link_connect(nr_link *link, const char *path)
{
	static int timer_asked;
	if (!timer_asked) {
		timer_asked = 1;
		nr_link_timer();
	}
	link->handle = INVALID_HANDLE_VALUE;
	link->deadline_ms = 60000;

	/* The daemon creates the pipe before it listens, so the first attempt can
	 * catch ERROR_FILE_NOT_FOUND while it is still starting. WaitNamedPipe does
	 * not distinguish "not yet" from "never", so this polls instead. */
	for (int attempt = 0; attempt < 100; attempt++) {
		HANDLE h = CreateFileA(path, GENERIC_READ | GENERIC_WRITE, 0, NULL,
				       OPEN_EXISTING, 0, NULL);
		if (h != INVALID_HANDLE_VALUE) {
			DWORD mode = PIPE_READMODE_BYTE;
			SetNamedPipeHandleState(h, &mode, NULL, NULL);
			link->handle = h;
			return 0;
		}
		DWORD e = GetLastError();
		/* ERROR_PIPE_BUSY is every instance spoken for, and ERROR_NO_DATA is an
		 * instance caught in the middle of being closed by the daemon's last frame —
		 * with several frames on their way at once one of the two is the normal state
		 * of the pipe, not a failure, and both pass in the time it takes the daemon
		 * to accept the frame before this one. Only a pipe that is not there at all
		 * (ERROR_FILE_NOT_FOUND) belongs to the same wait: that is start-up. */
		if (e != ERROR_PIPE_BUSY && e != ERROR_FILE_NOT_FOUND && e != ERROR_NO_DATA)
			return -1;
		Sleep(50);
	}
	return -1;
}

static void nr_link_close(nr_link *link)
{
	if (link->handle != INVALID_HANDLE_VALUE) CloseHandle(link->handle);
	link->handle = INVALID_HANDLE_VALUE;
}

/* A connection carried as an int, so callers that keep one across calls do not have to
 * name the platform type. Only ever round-tripped through the pair below. */
static int nr_link_handle(nr_link link)
{
	return (int)(intptr_t)link.handle;
}

static nr_link nr_link_from_handle(int fd)
{
	nr_link link;
	link.handle = (HANDLE)(intptr_t)fd;
	link.deadline_ms = 60000;
	return link;
}

/* Send exactly `count` bytes, or fail. The layer's three writes are small
 * (16-byte header, then the colour, then nothing) but the colour is a whole
 * frame, so this loops the way the Unix build's send() loop does. */
static int nr_link_write(nr_link *link, const void *data, size_t count)
{
	const unsigned char *p = data;
	DWORD budget = link->deadline_ms;
	while (count > 0) {
		DWORD chunk = (DWORD)(count > (1u << 20) ? (1u << 20) : count);
		DWORD written = 0;
		if (!WriteFile(link->handle, p, chunk, &written, NULL)) return -1;
		if (written == 0) return -1;
		p += written;
		count -= written;
		(void)budget;
	}
	return 0;
}

/* Read exactly `count` bytes within the deadline, or fail.
 *
 * PeekNamedPipe first: ReadFile on a byte-mode pipe returns whatever is there,
 * including zero bytes, so a single blocking ReadFile cannot express "wait until
 * count bytes exist, but not past the deadline" the way read() on a socket can. */
static int nr_link_read(nr_link *link, void *data, size_t count)
{
	unsigned char *p = data;
	DWORD waited = 0;
	while (count > 0) {
		DWORD available = 0;
		if (!PeekNamedPipe(link->handle, NULL, 0, NULL, &available, NULL))
			return -1;
		if (available == 0) {
			/* One millisecond, not ten. The layer sends a frame and reads its answer
			 * in the same present, so this wait is the whole of the daemon's time
			 * for the frame — 40 ms and more — and the answer is there somewhere in
			 * it. Polling it in tens of milliseconds gave away half a step's worth
			 * of that every frame for no reason: the deadline is a minute, and
			 * nothing is being saved by being slow to notice. Measured on this
			 * machine, Sleep's own granularity is 1.5 ms at 1 and 10.2 ms at 10.
			 */
			if (waited >= link->deadline_ms) return -1;
			Sleep(1);
			waited += 1;
			continue;
		}
		DWORD want = (DWORD)(count < available ? count : available);
		DWORD got = 0;
		if (!ReadFile(link->handle, p, want, &got, NULL)) return -1;
		if (got == 0) return -1;
		p += got;
		count -= got;
	}
	return 0;
}

/* ---- the frame's bytes through a file mapping instead of the pipe ------------
 *
 * A byte-mode pipe copies twice: once into the kernel buffer on the way out and once
 * out of it on the way in. A mapping both processes can see copies once, the writer's
 * own memcpy into it, and the reader reads the bytes where they lie. At 1920x1080,
 * 8.29 MB each way, `src/bench/shm_vs_pipe.py` times the round trip at 5.96 ms through
 * the pipe and 2.12 ms through a mapping, alternating within one process so the two
 * cannot be told apart by drift.
 *
 * The pipe still carries the header and, on the way back, a four-byte notice. That is
 * what synchronises the pair, so there is no event to create and none to wait on: the
 * header is written after the request is in the mapping, and the notice after the
 * answer is, so a byte read out of the pipe is proof the bytes behind it are there.
 *
 * The mapping is made by the daemon, which knows its own pixel limit; the layer opens
 * it by name and reads the layout out of its first 64 bytes. A layer that finds no
 * mapping — an older daemon, or `NR_SHM=0` — sends the frame through the pipe and
 * nothing else changes.
 */

#define NR_SHM_MAGIC 0x4D52534Eu      /* what the daemon writes in the layout head */
#define NR_SHM_VERSION 3u
#define NR_SHM_MAX_SLOTS 8u
#define NR_SHM_HEAD 128u              /* the layout head, and the slots' alignment */

/* Version 2 added the three handles at the end of the head: the layout only had the
 * two sizes in it before, and there was no room for what Phase 2 needs to say. The
 * head grew from 64 to 128 bytes, which is also a change of version, so a layer and a
 * daemon that disagree about it refuse the mapping instead of reading a handle out of
 * a head that never had one.
 *
 * The handles are only there when `NR_EXTMEM` is set on the daemon's side. A handle is
 * a number inside the process that holds it, so the daemon has to DuplicateHandle all
 * three into the layer's process before writing them — the numbers it writes are not
 * the ones it got from the driver.
 *
 * Version 3 put the count of offers behind them, at offset 72. It is there because the
 * handles cannot say it themselves: the same process is not the only thing that hands
 * out the same low handle numbers, a fresh one does too. The second game to ask a
 * daemon that outlived the first for frames is offered handles that read exactly like
 * the first game's and are not its own, and importing one is asking for memory by a
 * number that means something else here — vkAllocateMemory (import) says no, which is
 * twice in the log of 2026-10-12. Only the daemon knows whether it has offered them
 * again, and the count is how it says so. */
#define NR_SHM_EXTMEM 12u             /* offset of the flag, 1 when the handles are set */
#define NR_SHM_OFFERS 72u             /* offset of the count of offers, raised by the daemon */

/* The magic on the wire. The two shared-memory values are the pipe's two with 2 added,
 * so a daemon that has never heard of a mapping rejects them rather than reading the
 * bytes behind them out of a pipe that holds none. */
#define NR_MAGIC 0x304E524Eu
#define NR_MAGIC_MASKED 0x314E524Eu
#define NR_MAGIC_SHM 0x324E524Eu
#define NR_MAGIC_SHM_MASKED 0x334E524Eu
/* The same two with 4 added: the frame is already in the daemon's own buffer, put
 * there by this process, and the answer is to be read out of the daemon's own. Per
 * frame rather than per session, because the layer may fail to import the buffers the
 * daemon offered and then has to fall back — and a daemon that waited for a signal
 * that was never going to come would hang until its fence timed out. */
#define NR_MAGIC_EXTMEM 0x344E524Eu
#define NR_MAGIC_EXTMEM_MASKED 0x354E524Eu

typedef struct {
	HANDLE mapping;
	unsigned char *base;
	unsigned slots;      /* how many frames may be in the mapping at once */
	size_t colour;       /* bytes of one colour plane, 4 x the pixel limit */
	size_t mask;         /* bytes of one interface plane, 1 x the pixel limit */
	size_t stride;       /* bytes of one slot: colour, then mask, then the answer */
	int usable;
} nr_shm;

/* Where the daemon writes its layout, as 32-bit words then 64-bit sizes. The three
 * handles are left zero here: they are a per-process number nobody can fill in but the
 * daemon, which writes them once it has duplicated them. */
static void nr_shm_write_layout(unsigned char *base, unsigned slots, size_t colour,
				size_t mask)
{
	uint32_t *head = (uint32_t *)base;
	head[0] = NR_SHM_MAGIC;
	head[1] = NR_SHM_VERSION;
	head[2] = slots;
	head[3] = 0;
	uint64_t *sizes = (uint64_t *)(base + 16);
	sizes[0] = (uint64_t)colour;
	sizes[1] = (uint64_t)mask;
	for (size_t at = 32; at < NR_SHM_HEAD; at += 8)
		*(uint64_t *)(base + at) = 0;
}

/* The handles the daemon duplicated into this process, or 0 for any it did not.
 * Returns 1 when the head says they are there. The caller is expected to check the
 * sizes too: a buffer the layer thinks is bigger than it is would be written past.
 *
 * `answer` may be 0: the answer crossing in a slot is the ordinary way still, and
 * Phase 2's first half — the frame going straight into the daemon's buffer — does not
 * need it. What has to be there is the frame's buffer and the semaphore, so those are
 * what this asks for. */
static int nr_shm_extmem(const nr_shm *shm, unsigned long long *raw,
			 unsigned long long *answer, unsigned long long *sem,
			 size_t *raw_bytes, size_t *answer_bytes,
			 unsigned long long *offers)
{
	if (!shm->usable) return 0;
	uint32_t *head = (uint32_t *)shm->base;
	if (head[1] < 2 || head[NR_SHM_EXTMEM / 4] != 1) return 0;
	uint64_t *words = (uint64_t *)(shm->base + 32);
	*raw = words[0];
	*answer = words[1];
	*sem = words[2];
	*raw_bytes = (size_t)words[3];
	*answer_bytes = (size_t)words[4];
	/* Version 3's count. A head too old to carry one is read as no offer at all,
	 * which is the truth for it: a daemon that cannot count its offers cannot have
	 * made a second one. */
	*offers = head[1] >= 3 ? *(uint64_t *)(shm->base + NR_SHM_OFFERS) : 0;
	return *raw && *sem && *raw_bytes;
}

/* Opens the mapping the daemon made for this pipe, and reads its layout. Returns -1
 * when there is none, which is the ordinary state of an older daemon or of `NR_SHM=0`;
 * the caller then sends the frame through the pipe. */
static int nr_shm_open(nr_shm *shm, const char *pipe_path)
{
	memset(shm, 0, sizeof *shm);
	const char *tail = strrchr(pipe_path, '\\');
	tail = tail ? tail + 1 : pipe_path;
	char name[128];
	if (snprintf(name, sizeof name, "Local\\NR_SHM_%s", tail) >= (int)sizeof name)
		return -1;
	HANDLE mapping = OpenFileMappingA(FILE_MAP_READ | FILE_MAP_WRITE, FALSE, name);
	if (mapping == NULL || mapping == INVALID_HANDLE_VALUE) return -1;
	unsigned char *base = MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE,
					   0, 0, 0);
	if (!base) {
		CloseHandle(mapping);
		return -1;
	}
	uint32_t *head = (uint32_t *)base;
	if (head[0] != NR_SHM_MAGIC || head[1] != NR_SHM_VERSION ||
	    head[2] == 0 || head[2] > NR_SHM_MAX_SLOTS) {
		UnmapViewOfFile(base);
		CloseHandle(mapping);
		return -1;
	}
	uint64_t *sizes = (uint64_t *)(base + 16);
	shm->mapping = mapping;
	shm->base = base;
	shm->slots = head[2];
	shm->colour = (size_t)sizes[0];
	shm->mask = (size_t)sizes[1];
	shm->stride = 2 * shm->colour + shm->mask;
	shm->usable = shm->colour > 0 && shm->mask > 0;
	if (!shm->usable) {
		UnmapViewOfFile(base);
		CloseHandle(mapping);
		memset(shm, 0, sizeof *shm);
		return -1;
	}
	return 0;
}

static void nr_shm_close(nr_shm *shm)
{
	if (shm->base) UnmapViewOfFile(shm->base);
	if (shm->mapping && shm->mapping != INVALID_HANDLE_VALUE) CloseHandle(shm->mapping);
	memset(shm, 0, sizeof *shm);
}

/* The three planes of one slot: what the layer put in, its interface mask, and where
 * the daemon leaves the answer. The mask follows the colour so a masked frame's one
 * memcpy fills both. */
static unsigned char *nr_shm_request(nr_shm *shm, unsigned slot)
{
	return shm->base + NR_SHM_HEAD + (size_t)slot * shm->stride;
}

static unsigned char *nr_shm_mask(nr_shm *shm, unsigned slot)
{
	return nr_shm_request(shm, slot) + shm->colour;
}

static unsigned char *nr_shm_answer(nr_shm *shm, unsigned slot)
{
	return nr_shm_mask(shm, slot) + shm->mask;
}

#else  /* the Linux build, unchanged: a Unix socket */

/* The mapping is a Windows answer to a Windows cost. On Linux the frame crosses on the
 * socket, which is already a single copy, so there is nothing here to replace and these
 * are defined only so the layer's one set of call sites compiles unchanged. */

#define NR_MAGIC 0x304E524Eu
#define NR_MAGIC_MASKED 0x314E524Eu
#define NR_MAGIC_SHM 0x324E524Eu
#define NR_MAGIC_SHM_MASKED 0x334E524Eu
/* The same two with 4 added: the frame is already in the daemon's own buffer, put
 * there by this process, and the answer is to be read out of the daemon's own. Per
 * frame rather than per session, because the layer may fail to import the buffers the
 * daemon offered and then has to fall back — and a daemon that waited for a signal
 * that was never going to come would hang until its fence timed out. */
#define NR_MAGIC_EXTMEM 0x344E524Eu
#define NR_MAGIC_EXTMEM_MASKED 0x354E524Eu

/* The layer's one set of call sites has to compile here too, so the shape is the same
 * and the three places are never reached: `usable` is what keeps them that way. */
typedef struct {
	int usable;
	unsigned slots;
	size_t colour;
	size_t mask;
	size_t stride;
	void *base;
} nr_shm;

static int nr_shm_open(nr_shm *shm, const char *pipe_path)
{
	(void)pipe_path;
	memset(shm, 0, sizeof *shm);
	return -1;
}

static void nr_shm_close(nr_shm *shm)
{
	memset(shm, 0, sizeof *shm);
}

static unsigned char *nr_shm_request(nr_shm *shm, unsigned slot)
{
	(void)shm;
	(void)slot;
	return NULL;
}

static unsigned char *nr_shm_mask(nr_shm *shm, unsigned slot)
{
	(void)shm;
	(void)slot;
	return NULL;
}

static unsigned char *nr_shm_answer(nr_shm *shm, unsigned slot)
{
	(void)shm;
	(void)slot;
	return NULL;
}

static int nr_shm_extmem(const nr_shm *shm, unsigned long long *raw,
			 unsigned long long *answer, unsigned long long *sem,
			 size_t *raw_bytes, size_t *answer_bytes,
			 unsigned long long *offers)
{
	(void)shm;
	*raw = *answer = *sem = 0;
	*raw_bytes = *answer_bytes = 0;
	*offers = 0;
	return 0;
}

#include <sys/socket.h>
#include <sys/types.h>   /* ssize_t, which <sys/socket.h> does not promise */
#include <sys/un.h>
#include <sys/time.h>
/* read(), write() and close() come from <unistd.h>; errno and EINTR from <errno.h>.
 * <stdio.h> is for snprintf below — this header is included before the includer's own
 * stdio in one of its two callers, so it cannot rely on theirs. */
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>      /* memset, for the shape the Windows arm has */

typedef struct {
	int fd;
} nr_link;

static int nr_link_connect(nr_link *link, const char *path)
{
	link->fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (link->fd < 0) return -1;
	struct timeval timeout = { .tv_sec = 60 };
	if (setsockopt(link->fd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof timeout) ||
	    setsockopt(link->fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof timeout)) {
		close(link->fd);
		link->fd = -1;
		return -1;
	}
	struct sockaddr_un address = { .sun_family = AF_UNIX };
	snprintf(address.sun_path, sizeof address.sun_path, "%s", path);
	if (connect(link->fd, (struct sockaddr *)&address, sizeof address) < 0) {
		close(link->fd);
		link->fd = -1;
		return -1;
	}
	return 0;
}

static void nr_link_close(nr_link *link)
{
	if (link->fd >= 0) close(link->fd);
	link->fd = -1;
}

/* A connection carried as an int, so callers that keep one across calls do not have to
 * name the platform type. Only ever round-tripped through the pair below. */
static int nr_link_handle(nr_link link)
{
	return link.fd;
}

static nr_link nr_link_from_handle(int fd)
{
	nr_link link;
	link.fd = fd;
	return link;
}

static int nr_link_write(nr_link *link, const void *data, size_t count)
{
	const unsigned char *p = data;
	while (count > 0) {
		ssize_t n = send(link->fd, p, count, MSG_NOSIGNAL);
		if (n < 0 && errno == EINTR) continue;
		if (n <= 0) return -1;
		p += n;
		count -= (size_t)n;
	}
	return 0;
}

static int nr_link_read(nr_link *link, void *data, size_t count)
{
	unsigned char *p = data;
	while (count > 0) {
		ssize_t n = read(link->fd, p, count);
		if (n < 0 && errno == EINTR) continue;
		if (n <= 0) return -1;
		p += n;
		count -= (size_t)n;
	}
	return 0;
}

#endif

#endif
