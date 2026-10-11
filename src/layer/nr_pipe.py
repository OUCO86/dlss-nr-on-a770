"""nr_pipe — the Windows named-pipe transport for the layer/daemon pair.

The Linux build speaks over a Unix socket: the daemon `bind()`s, the layer
`connect()`s, and both use the byte stream unchanged. On Windows the two ends
meet on a named pipe instead — Winsock's `AF_UNIX` cannot bind here and CPython
has no `socket.AF_UNIX` at all, so a Win32 named pipe is the only transport
both sides can reach (see the t15 build notes, section A.7).

The bytes are unchanged: 16-byte header, then the colour, then the mask for a
masked frame. Only the endpoint changes, so this module reproduces just enough
of the `socket` interface for `nr_daemon` — `.accept()` on the server, and
`.recv()` / `.recv_into()` / `.sendall()` / `.settimeout()` / `.close()` on a
connection — so the daemon's frame loop stays as it is.

`CreateNamedPipe` is reached through `ctypes` on kernel32: the machine has no
`pywin32`, and the standard library is enough (measured in section A.7.9).
"""
import ctypes
import errno
import mmap
import struct
import time
from ctypes import wintypes

import numpy as np

_k32 = ctypes.WinDLL("kernel32", use_last_error=True)

PIPE_ACCESS_DUPLEX = 0x00000003
PIPE_TYPE_BYTE = 0x00000000
PIPE_READMODE_BYTE = 0x00000000
PIPE_WAIT = 0x00000000

ERROR_PIPE_CONNECTED = 535
ERROR_PIPE_BUSY = 231        # every instance is in use; retry, it is not a failure
ERROR_BROKEN_PIPE = 109
ERROR_NO_DATA = 232

INVALID_HANDLE_VALUE = wintypes.HANDLE(-1).value

_k32.CreateNamedPipeW.restype = wintypes.HANDLE
_k32.CreateNamedPipeW.argtypes = [
    wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD, wintypes.DWORD,
    wintypes.DWORD, wintypes.DWORD, wintypes.DWORD, ctypes.c_void_p]
_k32.ConnectNamedPipe.argtypes = [wintypes.HANDLE, ctypes.c_void_p]
_k32.ConnectNamedPipe.restype = wintypes.BOOL
_k32.ReadFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                          ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
_k32.ReadFile.restype = wintypes.BOOL
_k32.WriteFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                           ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
_k32.WriteFile.restype = wintypes.BOOL
_k32.CloseHandle.argtypes = [wintypes.HANDLE]
_k32.CloseHandle.restype = wintypes.BOOL
_k32.DisconnectNamedPipe.argtypes = [wintypes.HANDLE]
_k32.DisconnectNamedPipe.restype = wintypes.BOOL


class NamedPipeConnection:
    """One connected byte-mode pipe endpoint, shaped like a socket."""

    def __init__(self, handle, timeout=None):
        self._handle = int(handle)
        self._timeout = timeout
        self._open = True

    def settimeout(self, seconds):
        self._timeout = seconds

    def recv(self, count):
        """Read up to `count` bytes; b'' when the peer closed cleanly."""
        buf = bytearray(count)
        return bytes(buf[:self.recv_into(buf, count)])

    def recv_into(self, buffer, count=0):
        """Read up to `count` bytes (all `buffer` holds when 0) straight into `buffer`, as a
        socket's `recv_into` does; 0 when the peer closed cleanly. `nr_daemon.receive` takes
        this path: a frame then lands in its buffer with no copy on the way, where reading
        each megabyte into a fresh buffer of its own, copying it out and joining the pieces
        took 3.5 ms of a 1280x720 frame against Linux's 0.9."""
        if not self._open:
            return 0
        view = memoryview(buffer).cast("B")
        count = min(count or len(view), len(view))
        if not count:
            return 0
        target = (ctypes.c_char * count).from_buffer(view)
        got = wintypes.DWORD(0)
        if _k32.ReadFile(self._handle, target, count, ctypes.byref(got), None):
            return got.value
        err = ctypes.get_last_error()
        if err in (ERROR_BROKEN_PIPE, ERROR_NO_DATA):
            # The layer closed its end: clean EOF, not a failure.
            self._open = False
            return 0
        # A byte-mode pipe on a blocking ReadFile returns only when data
        # arrives or the peer closes; this path is unexpected rather than a
        # timeout, so it surfaces as an error the daemon's frame loop can
        # already swallow ("frame rejected/failed").
        raise OSError(err, "ReadFile")

    def sendall(self, data):
        """Write all of `data` from where it lies. A writable buffer — the answer the daemon
        composes into the request's own bytes — is handed to WriteFile as it is, and so is
        `bytes`; copying the frame twice on the way out took 2.7 ms of a 1280x720 frame
        against Linux's 0.75. WriteFile on this blocking pipe returns once the bytes are the
        pipe's, so the caller may reuse its buffer straight after."""
        view = memoryview(data).cast("B")
        total = len(view)
        if not total:
            return
        if view.readonly:
            whole = data if isinstance(data, bytes) else view.tobytes()
            holder = ctypes.c_char_p(whole)
            base = ctypes.cast(holder, ctypes.c_void_p).value
        else:
            holder = (ctypes.c_char * total).from_buffer(view)
            base = ctypes.addressof(holder)
        sent = 0
        while sent < total:
            written = wintypes.DWORD(0)
            ok = _k32.WriteFile(self._handle, ctypes.c_void_p(base + sent), total - sent,
                                ctypes.byref(written), None)
            if not ok:
                err = ctypes.get_last_error()
                if err == ERROR_BROKEN_PIPE:
                    self._open = False
                    raise BrokenPipeError(err, "WriteFile")
                raise OSError(err, "WriteFile")
            if written.value == 0:
                raise OSError(errno.EPIPE, "WriteFile wrote nothing")
            sent += written.value
        del holder

    def close(self):
        # EOF/broken-pipe marks the stream unusable but does not release its handle.
        # Status probes close without sending a header, so this distinction matters
        # even when every real frame succeeds. Release once, independent of _open.
        if self._handle is not None:
            _k32.CloseHandle(self._handle)
            self._handle = None
        self._open = False

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()


class NamedPipeServer:
    """A byte-mode named pipe the layer connects to, shaped like a listening socket."""

    def __init__(self, path, backlog=4, buffer_size=1 << 20, timeout=None):
        self.path = path
        self.backlog = backlog
        self.buffer_size = buffer_size
        self._timeout = timeout
        self._handle = self._make()

    def _make(self, attempts=50):
        """Create one pipe instance.

        ERROR_PIPE_BUSY means the instance count is momentarily at `backlog` — the
        normal state while accepted connections are still open. It is not fatal: wait
        and retry, and only give up when the caller really cannot get an endpoint.
        """
        for attempt in range(attempts):
            handle = _k32.CreateNamedPipeW(
                self.path, PIPE_ACCESS_DUPLEX,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
                self.backlog, self.buffer_size, self.buffer_size, 0, None)
            value = int(handle)
            if value != INVALID_HANDLE_VALUE:
                return value
            err = ctypes.get_last_error()
            if err != ERROR_PIPE_BUSY:
                raise OSError(err, "CreateNamedPipeW")
            time.sleep(0.02 * (attempt + 1))
        raise OSError(ctypes.get_last_error(), "CreateNamedPipeW")

    def accept(self):
        """Wait for one client, then return a connected `NamedPipeConnection`."""
        if not self._handle:
            # Every instance was in use last time round; make a new one now.
            self._handle = self._make()
        # ConnectNamedPipe says no in two ways that are not failures, and both have
        # to be told apart from one that is:
        #   ERROR_PIPE_CONNECTED (535) - the client was already there, which is the
        #     ordinary case when it connected while we were between instances;
        #   ERROR_NO_DATA (232) - a client connected and hung up again before we
        #     got here, which a layer that closed its frame's connection does as a
        #     matter of course. The endpoint has to be reset and waited on again.
        #   Anything else is a real error.
        # Raising on the second is what let one closed connection end the daemon
        # and leave the game waiting on a pipe nobody answered.
        for attempt in range(64):
            ok = _k32.ConnectNamedPipe(self._handle, None)
            if ok:
                break
            err = ctypes.get_last_error()
            if err == ERROR_PIPE_CONNECTED:
                break
            if err != ERROR_NO_DATA:
                raise OSError(err, "ConnectNamedPipe")
            _k32.DisconnectNamedPipe(self._handle)
        connection = NamedPipeConnection(self._handle, self._timeout)
        # A fresh pipe instance replaces the one just handed over, so the next
        # `accept` waits on a new endpoint rather than the one in use. When the
        # backlog is momentarily full this leaves `_handle` empty and the next
        # accept() creates the instance instead - so a busy pipe costs a retry,
        # not the daemon.
        try:
            self._handle = self._make()
        except OSError:
            self._handle = 0
        return connection, None

    def close(self):
        if self._handle:
            _k32.DisconnectNamedPipe(self._handle)
            _k32.CloseHandle(self._handle)
            self._handle = None


def server(path, backlog=4, timeout=None):
    return NamedPipeServer(path, backlog=backlog, timeout=timeout)


class FrameMapping:
    """The file mapping a frame crosses in, in place of the pipe.

    A byte-mode pipe copies the frame twice: once into the kernel's buffer on the way
    out of the layer and once out of it into the daemon, and the same again for the
    answer. Here the layer writes the frame where the daemon reads it, and the daemon
    leaves the answer where the layer reads it — one copy each way, made by whoever
    already has the bytes. `src/bench/shm_vs_pipe.py` times the round trip at
    1920x1080 at 5.96 ms through the pipe and 2.12 ms through this, alternating within
    one process so the two cannot be told apart by drift.

    The daemon makes the mapping, because the pixel limit that sizes it is the daemon's,
    and the layer finds it by name — the pipe's name with `NR_SHM_` in front — and reads
    the layout out of its first 64 bytes, which is all it needs to know where a slot is.
    A layer that finds no mapping sends the frame on the pipe and nothing else changes.

    A slot holds one frame: the colour, then its interface mask, then the answer. There
    are as many as frames may be on their way at once. The pipe still carries the header
    and, on the way back, four bytes saying the answer is in the slot — which is what
    keeps the two ends in order without another object to wait on: the header is written
    after the request is, and the four bytes after the answer is.
    """

    MAGIC = 0x4D52534E
    # 2 added the handles at the end of the head; the head grew from 64 to 128 bytes to
    # hold them. A layer that only knows version 1 refuses the mapping, which is what
    # makes growing it safe.
    VERSION = 2
    HEAD = 128
    SLOTS = 4

    def __init__(self, pipe_path, pixels, slots=SLOTS):
        """Make the mapping, or open the one already there — and lay the head out.

        Constructing one is not a read-only act, and that is worth saying plainly
        because it cost a day. It rewrites the head (so handles published in it
        are gone) and it touches a byte a page across the *whole* mapping, slots
        included. Open one after an answer has been written into a slot and you
        have zeroed a byte of every 4096 of that answer.

        At 1920x1080 that is 2024 bytes: one byte a page, every 8 rows by every
        128 columns, channel 0 only, and the same ones every time — which is what
        a frame that came back wrong looks like, and is not. `check_extmem_
        roundtrip.py` had this in the loop that read the answer back and spent a
        day measuring its own footprint.

        Only the daemon makes one (`_mapping`), once, before any frame. The layer
        opens the mapping in C, `nr_shm_open`, which reads the head and writes
        nothing. A test that wants to read an answer out of a slot has to open
        the mapping before the frame, and keep it.
        """
        self.name = "Local\\NR_SHM_" + pipe_path.rsplit("\\", 1)[-1]
        self.slots = slots
        self.colour = pixels * 4
        self.mask = pixels
        self.stride = 2 * self.colour + self.mask
        self._map = mmap.mmap(-1, self.HEAD + self.stride * slots, tagname=self.name)
        # The mapping's pages are committed as they are written, and one frame in a slot
        # was committing the whole slot: the first frame in each of the four ran 5 ms
        # slower than every frame after it, measured over twelve frames. Touching a byte
        # a page makes them the daemon's start-up cost instead of the game's first four
        # frames'. Before the layout goes in, which the first page carries.
        np.frombuffer(self._map, np.uint8)[::4096] = 0
        struct.pack_into("<4I", self._map, 0, self.MAGIC, self.VERSION, slots, 0)
        struct.pack_into("<QQ", self._map, 16, self.colour, self.mask)
        # No handles yet, and the flag that says so: the layer must not read a handle
        # out of a head that was never given one.
        struct.pack_into("<5Q", self._map, 32, 0, 0, 0, 0, 0)
        struct.pack_into("<I", self._map, 12, 0)

    def publish_extmem(self, raw, answer, sem, raw_bytes, answer_bytes):
        """Offer the layer the frame's buffers, as handles in *its* process.

        The three numbers have to have been duplicated into the layer's process first:
        a handle is only meaningful where it was made. The flag goes in last, so a
        layer reading the head never sees sizes without the handles they belong to.
        """
        struct.pack_into("<5Q", self._map, 32, raw, answer, sem, raw_bytes, answer_bytes)
        struct.pack_into("<I", self._map, 12, 1)

    def _plane(self, slot, offset, count):
        at = self.HEAD + slot * self.stride + offset
        return memoryview(self._map)[at:at + count]

    def request(self, slot, count):
        """Where the layer left the frame's colour, and the mask after it."""
        return self._plane(slot, 0, count)

    def interface(self, slot, count):
        return self._plane(slot, self.colour, count)

    def answer(self, slot, count):
        """Where the answer goes, for the layer to read out of the same slot."""
        return self._plane(slot, self.colour + self.mask, count)

    def close(self):
        self._map.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()


PROCESS_DUP_HANDLE = 0x0040
DUPLICATE_SAME_ACCESS = 0x00000002

_k32.GetCurrentProcess.restype = wintypes.HANDLE
_k32.OpenProcess.restype = wintypes.HANDLE
_k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
_k32.DuplicateHandle.restype = wintypes.BOOL
_k32.DuplicateHandle.argtypes = [wintypes.HANDLE, wintypes.HANDLE, wintypes.HANDLE,
                                 ctypes.POINTER(wintypes.HANDLE), wintypes.DWORD,
                                 wintypes.BOOL, wintypes.DWORD]


def duplicate_to(pid, handles):
    """Put handles into another process, and return the numbers it will know them by.

    A handle is only a number where it was made. The daemon's buffers are the daemon's
    to export, so the layer needs them duplicated into its own process before it can
    import either, and the numbers it gets are not the ones the driver handed out.

    The duplicated handles live in the layer's process, which closes them when it is
    done with them; nothing here can, and nothing here needs to.
    """
    source = _k32.GetCurrentProcess()
    target = _k32.OpenProcess(PROCESS_DUP_HANDLE, False, int(pid))
    if not target:
        raise OSError(ctypes.get_last_error(), f"OpenProcess({pid})")
    out = []
    try:
        for handle in handles:
            got = wintypes.HANDLE()
            ok = _k32.DuplicateHandle(source, wintypes.HANDLE(int(handle)), target,
                                      ctypes.byref(got), 0, False,
                                      DUPLICATE_SAME_ACCESS)
            if not ok:
                raise OSError(ctypes.get_last_error(), "DuplicateHandle")
            out.append(int(got.value))
    finally:
        _k32.CloseHandle(target)
    return out
