#!/usr/bin/env python3
"""Can a buffer the daemon allocated be used by a process that never made it?

This is the first gate in notes/phase2-extmem-design.md section 5. The cross-process
probe (`extmem_xproc.exe`, notes/host-passes-to-gpu.md section 15) proved the card can
do it with buffers it allocated itself; this proves it for buffers allocated through
`libxmx`, which is what the daemon actually has — a different memory allocation path,
picked by `memtype()` rather than by the probe, with DEVICE_ADDRESS flags on it.

What it does:

  1. allocate a HOST_WRITE buffer the way the frame's `raw` buffer is allocated, but
     exportable, and write a byte pattern into it;
  2. spawn `extmem_xproc.exe guest`, which knows nothing about libxmx, and hand it the
     handle — duplicated into that process, because a handle is only a number inside
     the process that owns it;
  3. the guest imports the buffer, reads it back through its own device, and reports
     how many bytes differ;
  4. the guest then fills the buffer with a second pattern, and this process checks it
     can see that too — the way back, which is the direction the answer travels.

    python src/bench/check_extmem_export.py [megabytes]

Exits non-zero if any byte differs.
"""
import ctypes
import os
import pathlib
import subprocess
import sys

import numpy as np

from ctypes import wintypes

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))

import xmxres  # noqa: E402

EXE = ROOT / "work" / "extmem_xproc.exe"
WROTE = 0xA5   # what this process puts in the buffer
WROTE_BACK = 0x5A   # what the guest answers with

PROCESS_DUP_HANDLE = 0x0040
DUPLICATE_SAME_ACCESS = 0x0002

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
k32.GetCurrentProcess.restype = wintypes.HANDLE
k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
k32.OpenProcess.restype = wintypes.HANDLE
k32.DuplicateHandle.argtypes = [wintypes.HANDLE, wintypes.HANDLE, wintypes.HANDLE,
                                ctypes.POINTER(wintypes.HANDLE), wintypes.DWORD,
                                wintypes.BOOL, wintypes.DWORD]
k32.DuplicateHandle.restype = wintypes.BOOL


def duplicate_into(pid, handle):
    """A copy of `handle` that is valid inside process `pid`.

    A handle is an index into one process's table, so the number means nothing next
    door. Inheritance would be simpler but only goes parent -> child, and in Phase 2
    the buffers belong to the daemon, which is the *child*.
    """
    target = k32.OpenProcess(PROCESS_DUP_HANDLE, False, pid)
    if not target:
        raise ctypes.WinError(ctypes.get_last_error())
    dup = wintypes.HANDLE()
    ok = k32.DuplicateHandle(k32.GetCurrentProcess(), wintypes.HANDLE(handle), target,
                             ctypes.byref(dup), 0, False, DUPLICATE_SAME_ACCESS)
    k32.CloseHandle(target)
    if not ok:
        raise ctypes.WinError(ctypes.get_last_error())
    return int(dup.value or 0)


def main():
    megabytes = float(sys.argv[1]) if len(sys.argv) > 1 else 1.0
    nbytes = int(megabytes * (1 << 20))
    if not EXE.exists():
        print(f"missing {EXE} — build it with tools\\build_extmem_xproc.bat")
        return 1

    rt = xmxres.Runtime()
    lib = rt.lib
    if not hasattr(lib, "xmx_buf_create_exportable"):
        print("this libxmx.dll cannot export buffers — rebuild with tools\\build_msvc.bat")
        return 1

    # HOST_WRITE is where the frame's bytes go today: device memory with a BAR mapping,
    # which is the memory type this whole idea rests on.
    buf = rt.buffer(nbytes // 4, np.float32, kind=xmxres.HOST_WRITE, exportable=True)
    if not buf.exportable:
        print("the buffer came back not exportable")
        return 1
    handle = buf.handle()
    print(f"buffer {buf.id}: {nbytes} bytes, kind HOST_WRITE, handle {handle:#x}")

    view = buf.view(np.uint8)
    view[:] = WROTE
    print(f"wrote {view.nbytes} bytes of {WROTE:#02x}")

    proc = subprocess.Popen([str(EXE), "guest", "-", f"{WROTE:02x}", str(nbytes)],
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True)
    dup = duplicate_into(proc.pid, handle)
    print(f"duplicated into the guest as {dup:#x}")
    proc.stdin.write(f"{dup:x}\n")
    proc.stdin.flush()
    out, _ = proc.communicate(timeout=120)
    print("--- guest ---")
    print(out.rstrip())
    print("-------------")

    bad = 0
    for line in out.splitlines():
        if line.startswith("R "):
            bad = int(line[2:].split()[0])

    # the way back: the guest filled the buffer with 0x5A through its own device
    seen = int(view[0])
    print(f"after the guest wrote: first byte {seen:#02x} (wanted {WROTE_BACK:#02x})")
    if seen != WROTE_BACK:
        bad += 1

    if bad or proc.returncode:
        print(f"\nFAILED: {bad} bytes wrong, guest exit {proc.returncode}")
        return 1
    print("\nOK: a libxmx buffer was read and written by a process that never made it")
    return 0


if __name__ == "__main__":
    sys.exit(main())
