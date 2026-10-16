#!/usr/bin/env python3
"""ABI gate: load the icx-built C++/SYCL dll through ctypes with the EXACT argtypes
xmxres.py binds, drive a real SYCL kernel, check the result. Proves route A' host<->
kernel bridge before porting the 81-function skeleton. Run from oneapi/ (sycl9.dll adjacent)."""
import ctypes, os, pathlib, sys
import numpy as np  # noqa: F401  (proves the venv that runs the daemon has numpy too)

HERE = pathlib.Path(__file__).resolve().parent
# Python 3.8+ does not search PATH or cwd for a dll's DEPENDENCIES (sycl9.dll etc).
# Register the staging dir (where the dll + sycl runtime sit) and the toolchain bin.
for d in (str(pathlib.Path.cwd()), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        os.add_dll_directory(d)
# prefer a dll in the cwd (the oneapi/ staging dir, where sycl9.dll lives), else next to
# the script — a missing dependent dll is indistinguishable from a missing module here.
DLL = pathlib.Path.cwd() / "abibridge.dll"
if not DLL.exists():
    DLL = HERE / "abibridge.dll"

# sycl9.dll's implicit chain (libmmd, tbb, ur_loader, ur_win_proxy_loader) must be warm
# before a dll that links sycl9 resolves — the daemon has the whole runtime loaded at the
# time it CDLLs libxmx, so mirror that here. LoadLibraryExW in dependency order.
_k32 = ctypes.windll.kernel32
_k32.SetErrorMode(0x8002)
for _dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    _p = pathlib.Path.cwd() / _dep
    if _p.exists():
        _k32.LoadLibraryExW(str(_p), 0, 0)

lib = ctypes.CDLL(str(DLL))

# xmxres.py shapes: restype c_int everywhere, c_char_p for error
lib.xmx_error.restype = ctypes.c_char_p
lib.xmx_init.restype = ctypes.c_int
lib.xmx_transform.argtypes = [ctypes.c_ulonglong, ctypes.c_ulonglong, ctypes.c_uint]
lib.xmx_transform.restype = ctypes.c_int
lib.xmx_alloc.argtypes = [ctypes.POINTER(ctypes.c_ulonglong), ctypes.c_uint]
lib.xmx_alloc.restype = ctypes.c_int
lib.xmx_free.argtypes = [ctypes.c_ulonglong]; lib.xmx_free.restype = ctypes.c_int
lib.xmx_write.argtypes = [ctypes.c_ulonglong, ctypes.c_void_p, ctypes.c_uint]; lib.xmx_write.restype = ctypes.c_int
lib.xmx_read.argtypes = [ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_uint]; lib.xmx_read.restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "xmx_init() == 0 (ctypes c_int, no name-mangling error)")

# allocate two device buffers through the C ABI, as u64 handles
pa = ctypes.c_ulonglong(); pb = ctypes.c_ulonglong()
ok(lib.xmx_alloc(ctypes.byref(pa), 8) == 0 and pa.value, "xmx_alloc src -> u64 handle")
ok(lib.xmx_alloc(ctypes.byref(pb), 8) == 0 and pb.value, "xmx_alloc dst -> u64 handle")

src = np.arange(8, dtype=np.float32)
ok(lib.xmx_write(pa.value, src.ctypes.data, 32) == 0, "xmx_write host->device")
ok(lib.xmx_transform(pa.value, pb.value, 8) == 0, "xmx_transform drove a real SYCL kernel")

dst = np.zeros(8, dtype=np.float32)
ok(lib.xmx_read(dst.ctypes.data, pb.value, 32) == 0, "xmx_read device->host")
want = src * 2.0 + 1.0
ok(np.array_equal(dst, want), f"SYCL kernel result bit-exact: {dst.tolist()}")

em = lib.xmx_error()
ok(isinstance(em, bytes) and em == b"", "xmx_error() returns c_char_p (empty on success)")

print(f"\nABIBRIDGE {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
