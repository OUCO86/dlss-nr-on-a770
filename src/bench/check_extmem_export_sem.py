#!/usr/bin/env python
"""Does a semaphore libxmx *exported* order another process's wait?

`check_extmem_sem.py` covers the way round that Phase 2 first needed: somebody else
exports a semaphore, libxmx imports it and waits. This one covers the mirror, because
in the real wiring the semaphore belongs to the daemon — the layer writes into buffers
the daemon allocated, so the daemon is the side that waits and therefore the side that
has to hand the semaphore out.

So: libxmx exports a timeline semaphore, this process duplicates the handle into a
second, unrelated process, and that process signals it N milliseconds from now. A
submit here that waits on the semaphore must then take about N milliseconds to return.
If it comes straight back, the wait is not ordering anything and a frame would run on
bytes that had not arrived.

Run with one argument, how far away to put the signal, in milliseconds.
"""
import ctypes
import ctypes.wintypes as wt
import pathlib
import subprocess
import sys
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres  # noqa: E402

EXE = ROOT / "work" / "extmem_xproc.exe"
PROCESS_DUP_HANDLE = 0x0040
DUPLICATE_SAME_ACCESS = 0x0002


def duplicate_into(pid, handle):
    """Give process `pid` a handle of its own onto the same object.

    A handle is a number in one process; the copy lands in the other one as a different
    number, which is why the child cannot simply be told ours.
    """
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.OpenProcess.restype = wt.HANDLE
    kernel32.OpenProcess.argtypes = [wt.DWORD, wt.BOOL, wt.DWORD]
    kernel32.DuplicateHandle.argtypes = [wt.HANDLE, wt.HANDLE, wt.HANDLE,
                                         ctypes.POINTER(wt.HANDLE), wt.DWORD, wt.BOOL,
                                         wt.DWORD]
    target = kernel32.OpenProcess(PROCESS_DUP_HANDLE, False, pid)
    if not target:
        raise OSError(f"OpenProcess({pid}) failed: {ctypes.get_last_error()}")
    copy = wt.HANDLE()
    ok = kernel32.DuplicateHandle(kernel32.GetCurrentProcess(), wt.HANDLE(handle),
                                  target, ctypes.byref(copy), 0, False,
                                  DUPLICATE_SAME_ACCESS)
    kernel32.CloseHandle(target)
    if not ok:
        raise OSError(f"DuplicateHandle failed: {ctypes.get_last_error()}")
    return copy.value


def main():
    delay_ms = int(sys.argv[1]) if len(sys.argv) > 1 else 1500
    if not EXE.exists():
        print(f"missing {EXE} — build it with tools\\build_extmem_xproc.bat")
        return 1

    rt = xmxres.Runtime()
    a = rt.buffer(4096, "f4")
    w = rt.buffer(4096, "f4")
    c = rt.buffer(4096, "f4")

    def submit():
        rt.begin()
        rt.gemm(a, w, c, 64, 64, 64)
        started = time.perf_counter()
        rt.submit()
        return time.perf_counter() - started

    sid = rt.export_semaphore()
    ours = rt.semaphore_handle(sid)
    print(f"libxmx exported a timeline semaphore as id {sid}, handle {ours:#x}")

    proc = subprocess.Popen([str(EXE), "sigpeer"], stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, text=True, bufsize=1)
    try:
        theirs = duplicate_into(proc.pid, ours)
        print(f"  duplicated into the peer as {theirs:#x}")
        proc.stdin.write(f"sem {theirs:x}\n")
        proc.stdin.flush()
        # The peer names its device before it says anything else, so read until READY
        # rather than once: taking the first line for the answer makes a working peer
        # look like one that refused the handle.
        line = ""
        for _ in range(16):
            line = proc.stdout.readline().strip()
            if not line or line == "READY":
                break
            print(f"    peer: {line}")
        if line != "READY":
            print(f"  the peer did not import it: {line!r}")
            return 1
        print("  the peer imported it")

        plain = submit()
        print(f"  a submit with no wait:          {1000 * plain:.1f} ms")

        # Tell the peer to signal, then submit: the two overlap, so the submit is the
        # thing being measured rather than the delay.
        proc.stdin.write(f"signal 1 after {delay_ms}\n")
        proc.stdin.flush()
        rt.extmem_wait(sid, 1)
        held = submit()
        print(f"  a submit waiting on it:         {1000 * held:.1f} ms "
              f"(signal {delay_ms} ms away)")
        print(f"  the counter afterwards:         {rt.semaphore_value(sid)}")

    finally:
        # The peer sits waiting for its next command, so it has to be told to go rather
        # than waited for: without this it outlives the run and holds the semaphore's
        # payload open.
        try:
            proc.stdin.write("quit\n")
            proc.stdin.flush()
        except (BrokenPipeError, ValueError, OSError):
            pass
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)

    floor = 0.8 * delay_ms / 1000.0
    if held < floor:
        print(f"\nFAILED: the waited submit came back in {1000 * held:.1f} ms, under "
              f"{1000 * floor:.0f} ms. A semaphore libxmx exported does not order a "
              f"submit, so Phase 2 cannot be built on one.")
        return 1
    print(f"\nOK: {1000 * held:.1f} ms against a signal {delay_ms} ms away. A semaphore "
          f"libxmx exported does order a submit across a process boundary.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
