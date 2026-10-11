"""shm_vs_pipe — what a frame's 8.3 MB costs on its way to the daemon and back.

The layer lives in the game and the daemon is another process, so every frame's colour
crosses between them twice: once on the way in, once as the answer. Today both crossings
are `WriteFile` / `ReadFile` on a byte-mode named pipe, which copies the bytes into a
kernel buffer and out of it again. A file mapping the two processes share would let one
end write the bytes where the other reads them.

Three ways of making the crossing, timed in one process on two threads so the pair can
alternate within a run, which is the only way here to tell a real difference from the
card and the machine drifting under it:

- `pipe` — both ways through the pipe, as it is now;
- `shm`  — the colour and the answer in a shared mapping, the pipe carrying only the
  16-byte header and a 4-byte "the answer is there";
- `shm0` — the same, except the answer is read where it lies instead of being copied
  out, which is what the layer could do if its result pointed into the mapping.

The pipe is what synchronises the two ends either way: the header arrives after the
colour was written, and the answer's notice arrives after the answer was, so no event
or semaphore is needed and none is timed.

    python src/bench/shm_vs_pipe.py [--rounds 40] [--size 1920x1080]
"""
import argparse
import ctypes
import statistics
import sys
import threading
import time
from ctypes import wintypes

_k32 = ctypes.WinDLL("kernel32", use_last_error=True)
_INVALID = ctypes.c_size_t(-1).value

PIPE_ACCESS_DUPLEX = 0x00000003
PIPE_TYPE_BYTE = 0x00000000
PIPE_WAIT = 0x00000000
GENERIC_READ_WRITE = 0x80000000 | 0x40000000
OPEN_EXISTING = 3
FILE_MAP_ALL_ACCESS = 0xF001F
PAGE_READWRITE = 0x04

_k32.CreateNamedPipeW.restype = wintypes.HANDLE
_k32.CreateNamedPipeW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD,
                                  wintypes.DWORD, wintypes.DWORD, wintypes.DWORD,
                                  wintypes.DWORD, ctypes.c_void_p]
_k32.ConnectNamedPipe.argtypes = [wintypes.HANDLE, ctypes.c_void_p]
_k32.ConnectNamedPipe.restype = wintypes.BOOL
_k32.DisconnectNamedPipe.argtypes = [wintypes.HANDLE]
_k32.CreateFileW.restype = wintypes.HANDLE
_k32.CreateFileW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD,
                             ctypes.c_void_p, wintypes.DWORD, wintypes.DWORD,
                             wintypes.HANDLE]
_k32.ReadFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                          ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
_k32.ReadFile.restype = wintypes.BOOL
_k32.WriteFile.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                           ctypes.POINTER(wintypes.DWORD), ctypes.c_void_p]
_k32.WriteFile.restype = wintypes.BOOL
_k32.CloseHandle.argtypes = [wintypes.HANDLE]
_k32.CloseHandle.restype = wintypes.BOOL
_k32.CreateFileMappingW.restype = wintypes.HANDLE
_k32.CreateFileMappingW.argtypes = [wintypes.HANDLE, ctypes.c_void_p, wintypes.DWORD,
                                    wintypes.DWORD, wintypes.DWORD, wintypes.LPCWSTR]
_k32.OpenFileMappingW.restype = wintypes.HANDLE
_k32.OpenFileMappingW.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.LPCWSTR]
_k32.MapViewOfFile.restype = ctypes.c_void_p
_k32.MapViewOfFile.argtypes = [wintypes.HANDLE, wintypes.DWORD, wintypes.DWORD,
                               wintypes.DWORD, ctypes.c_size_t]
_k32.UnmapViewOfFile.argtypes = [ctypes.c_void_p]
_k32.UnmapViewOfFile.restype = wintypes.BOOL

PIPE = "\\\\.\\pipe\\nr_bench_shm_vs_pipe"
MAPPING = "Local\\NR_BENCH_SHM_VS_PIPE"

PIPE_MODE = 1
SHM_MODE = 2
SHM0_MODE = 3
NAMES = {PIPE_MODE: "pipe", SHM_MODE: "shm", SHM0_MODE: "shm0"}


def _read(handle, pointer, count, chunk=1 << 20):
    """`count` bytes out of the pipe, the way the daemon reads a frame."""
    got = wintypes.DWORD(0)
    while count > 0:
        want = wintypes.DWORD(min(chunk, count))
        if not _k32.ReadFile(handle, ctypes.c_void_p(pointer), want,
                             ctypes.byref(got), None):
            raise OSError(ctypes.get_last_error(), "ReadFile")
        if got.value == 0:
            raise OSError(109, "ReadFile: the peer closed")
        pointer += got.value
        count -= got.value


def _write(handle, pointer, count, chunk=1 << 20):
    sent = wintypes.DWORD(0)
    while count > 0:
        want = wintypes.DWORD(min(chunk, count))
        if not _k32.WriteFile(handle, ctypes.c_void_p(pointer), want,
                              ctypes.byref(sent), None):
            raise OSError(ctypes.get_last_error(), "WriteFile")
        if sent.value == 0:
            raise OSError(109, "WriteFile wrote nothing")
        pointer += sent.value
        count -= sent.value


def serve(path, size, rounds, modes, out, ready):
    """The daemon's end: one pipe, one mapping, then `rounds` exchanges."""
    try:
        _serve(path, size, rounds, modes, out, ready)
    except BaseException as exc:                       # a thread's traceback is lost
        print(f"server: {type(exc).__name__}: {exc}", flush=True)
        raise


def _serve(path, size, rounds, modes, out, ready):
    handle = _k32.CreateNamedPipeW(path, PIPE_ACCESS_DUPLEX,
                                   PIPE_TYPE_BYTE | PIPE_WAIT, 4,
                                   1 << 20, 1 << 20, 0, None)
    if int(handle) == _INVALID:
        raise OSError(ctypes.get_last_error(), "CreateNamedPipeW")
    mapping = _k32.CreateFileMappingW(wintypes.HANDLE(_INVALID), None, PAGE_READWRITE,
                                      0, 2 * size, MAPPING)
    if int(mapping) == _INVALID:
        raise OSError(ctypes.get_last_error(), "CreateFileMappingW")
    base = _k32.MapViewOfFile(mapping, FILE_MAP_ALL_ACCESS, 0, 0, 2 * size)
    if not base:
        raise OSError(ctypes.get_last_error(), "MapViewOfFile")
    inbox = (ctypes.c_char * size)()
    outbox = (ctypes.c_char * size)()
    header = (ctypes.c_uint32 * 4)()
    notice = (ctypes.c_uint32 * 1)()
    inbox_at, outbox_at = ctypes.addressof(inbox), ctypes.addressof(outbox)
    request_at, answer_at = base, base + size
    ready.set()
    if not _k32.ConnectNamedPipe(handle, None):
        err = ctypes.get_last_error()
        if err != 535:            # ERROR_PIPE_CONNECTED
            raise OSError(err, "ConnectNamedPipe")
    for mode in modes:
        _read(handle, ctypes.addressof(header), 16, chunk=16)
        mark = time.perf_counter()
        got = header[0]
        if got == PIPE_MODE:
            _read(handle, inbox_at, size)
        # what the daemon does with the answer it is about to send: it lies in a
        # HOST_READ buffer either way, so it is produced before the crossing starts.
        if got == PIPE_MODE:
            _write(handle, outbox_at, size)
        else:
            ctypes.memmove(answer_at, outbox_at, size)
            _write(handle, ctypes.addressof(notice), 4, chunk=4)
        out.setdefault(NAMES.get(got, got), []).append(time.perf_counter() - mark)
    _k32.UnmapViewOfFile(base)
    _k32.CloseHandle(mapping)
    _k32.CloseHandle(handle)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--size", default="1920x1080")
    parser.add_argument("--rounds", type=int, default=40)
    parser.add_argument("--pipe-buffer", type=int, default=1 << 20)
    args = parser.parse_args()
    width, height = (int(v) for v in args.size.split("x"))
    size = width * height * 4

    rounds = max(1, args.rounds)
    modes = [PIPE_MODE, SHM_MODE, SHM0_MODE] * rounds

    server_time, client_time = {}, {}
    ready = threading.Event()
    thread = threading.Thread(target=serve,
                              args=(PIPE, size, rounds, modes, server_time, ready),
                              daemon=True)
    thread.start()
    ready.wait()

    handle = _k32.CreateFileW(PIPE, GENERIC_READ_WRITE, 0, None, OPEN_EXISTING, 0, None)
    if int(handle) == _INVALID:
        raise OSError(ctypes.get_last_error(), "CreateFileW")
    mapping = _k32.OpenFileMappingW(FILE_MAP_ALL_ACCESS, False, MAPPING)
    if int(mapping) == _INVALID:
        raise OSError(ctypes.get_last_error(), "OpenFileMappingW")
    base = _k32.MapViewOfFile(mapping, FILE_MAP_ALL_ACCESS, 0, 0, 2 * size)
    if not base:
        raise OSError(ctypes.get_last_error(), "MapViewOfFile")

    outgoing = (ctypes.c_char * size)()
    result = (ctypes.c_char * size)()
    header = (ctypes.c_uint32 * 4)()
    notice = (ctypes.c_uint32 * 1)()
    outgoing_at, result_at = ctypes.addressof(outgoing), ctypes.addressof(result)
    request_at, answer_at = base, base + size

    for mode in modes:
        header[0] = mode
        mark = time.perf_counter()
        if mode == PIPE_MODE:
            _write(handle, ctypes.addressof(header), 16, chunk=16)
            _write(handle, outgoing_at, size)
            _read(handle, result_at, size)
        else:
            ctypes.memmove(request_at, outgoing_at, size)
            _write(handle, ctypes.addressof(header), 16, chunk=16)
            _read(handle, ctypes.addressof(notice), 4, chunk=4)
            if mode == SHM0_MODE:
                pass                      # read where it lies: nothing to copy
            else:
                ctypes.memmove(result_at, answer_at, size)
        client_time.setdefault(NAMES[mode], []).append(time.perf_counter() - mark)

    _k32.UnmapViewOfFile(base)
    _k32.CloseHandle(mapping)
    _k32.CloseHandle(handle)
    thread.join()

    print(f"{width}x{height}, {size / 1e6:.2f} MB a frame, {rounds} rounds of each, "
          f"pipe buffer {args.pipe_buffer >> 20} MB")
    print(f"{'':8} {'layer end':>12} {'daemon end':>12} {'round trip':>12}")
    for name in ("pipe", "shm", "shm0"):
        layer = statistics.median(client_time[name])
        daemon = statistics.median(server_time.get(name, [0.0]))
        print(f"{name:8} {layer * 1e3:12.2f} {daemon * 1e3:12.2f} "
              f"{(layer + daemon) * 1e3:12.2f} ms")
    return 0


if __name__ == "__main__":
    sys.exit(main())
