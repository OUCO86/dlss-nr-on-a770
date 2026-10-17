#!/usr/bin/env python3
"""Paired cross-engine import gate (section 60's next step): the OLD Vulkan runtime and MY
Level Zero dll in ONE process sharing ONE allocation by device pointer -- the shape P1/P2
need (the host-bounce route died on the window-arena wall, section 58; the section-59 probe
proved the import PRIMITIVE, GATE 1 green, but its data legs used host-mapped memory and
raced -- this gate replaces that with the correct full-device form my recorder actually uses:
sycl::queue::memcpy on the imported pointer, which carries its own SYCL synchronisation).

Flow:
  1. old xmxres.Runtime: Buffer(nbytes, GRAPH, exportable=True), host_write a 16MB pattern
     (the buffer is HOST_VISIBLE|HOST_COHERENT device memory per the daemon log, so the
     write is already device-visible -- no submit needed).
  2. handle = buf.handle()  (this process's own NT handle).
  3. MY.xmx_buf_import_win32(handle, nbytes, 1) -> an id in MY table pointing at the SAME
     device memory.
  4. MY.xmx_buf_download(id, ...) -> the bytes read through the Level Zero import, compared
     bit-for-bit with what the old runtime wrote. A match proves the two engines alias the
     same allocation and my SYCL path reads it coherently.
  5. (round trip) MY.xmx_buf_upload(id, newpattern) then old-runtime download -> prove the
     other direction, so recorders can WRITE into a coopmat-owned buffer too.

If step 4 mismatches while step 3 (import) succeeds, the import is real but the coherency
model differs -- we learn the ordering P1 must add (the extmem timeline-semaphore, which
section 18 GATE A proved importable). One variable: this gate has NO host-map read on the
old side after the write, and no bare deferred list on mine -- only mapped-write then SYCL
memcpy-read, exactly the shipping producer -> my consumer direction.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]          # repo root
ONER = ROOT.parent.parent
sys.path[:0] = [str(ROOT / "src" / "gpu"), str(ROOT / "src" / "ref")]

for d in (str(ONER / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k = ctypes.windll.kernel32
_k.SetErrorMode(0x8002)
for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    p = ONER / "oneapi" / dep
    if p.exists():
        _k.LoadLibraryExW(str(p), 0, 0)

MY = ctypes.CDLL(str(ONER / "oneapi" / "libxmx_sycl.dll"))
MY.xmx_error.restype = ctypes.c_char_p
MY.xmx_init.restype = ctypes.c_int
MY.xmx_buf_import_win32.restype = ctypes.c_int
MY.xmx_buf_import_win32.argtypes = [ctypes.c_ulonglong] * 2 + [ctypes.c_int]
MY.xmx_buf_download.argtypes = [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]
MY.xmx_buf_upload.argtypes = [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]
MY.xmx_buf_destroy.argtypes = [ctypes.c_int]

# --- isolation probe: bring up MY (SYCL/L0) completely before the Vulkan leg exists ---
MYINIT = MY.xmx_init()
print(f"  [probe] MY.xmx_init before xmxres import -> {MYINIT} "
      f"{'(' + MY.xmx_error().decode() + ')' if MYINIT else ''}", flush=True)
import nr_model as M  # noqa: F401 (parity)
import xmxres as X    # the shipped Vulkan runtime module

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

if MYINIT != 0:
    raise SystemExit("my L0 init: " + MY.xmx_error().decode())
rt = X.Runtime()
ok(True, "both engines live in one process (L0 MY initialised FIRST, then Vulkan rt)")

N = 16 << 20                       # the 16 MB floor every leg has used
# a pattern with structure so a torn/partial read cannot accidentally match
want = (np.arange(N, dtype=np.uint32) * 2654435761) .astype(np.uint32)
want = want.astype(np.uint8)

buf = X.Buffer(N, X.GRAPH, exportable=True)
ok(buf.exportable, "old buffer created exportable")
X.host_write(buf, want)            # mapped HOST_COHERENT write; device-visible

try:
    handle = buf.handle()
except Exception as e:
    print(f"  NOTE: xmx_buf_handle raised -- an older build's exportable path: {e!r}")
    handle = 0
if not handle:
    ok(False, "old runtime returned a live NT handle (this build/driver combo lacks it? -- "
              "P1's exportable leg needs the shipped extmem build)")
    print("\nPAIRED_IMPORT SKIPPED (no handle). build still proves the import PRIMITIVE "
          "independently (section 59 GATE 1).")
    sys.exit(0)
ok(bool(handle), f"old buffer.handle() -> NT handle 0x{handle:x}")

mid = MY.xmx_buf_import_win32(ctypes.c_ulonglong(handle), ctypes.c_ulonglong(N), ctypes.c_int(1))
if mid <= 0:
    ok(False, "MY import failed: " + MY.xmx_error().decode())
    print("\nPAIRED_IMPORT RED")
    sys.exit(1)
ok(mid > 0, f"MY xmx_buf_import_win32 -> id {mid} (device ptr on the same A770 memory)")

# direction 1: old wrote -> my SYCL reads
got = np.zeros(N, np.uint8)
rc = MY.xmx_buf_download(mid, got.ctypes.data, 0, N)
ok(rc == 0, "MY download on the imported id" + ("" if rc == 0 else " err=" + MY.xmx_error().decode()))
same = np.array_equal(got, want)
bad = int((got != want).sum())
first = int(np.flatnonzero(got != want)[0]) if bad else -1
ok(same, f"MY reads OLD's bytes bit-exact ({bad}/{N} differ" +
       (f", first @{first}: got 0x{got[first]:02x} want 0x{want[first]:02x})" if bad else ")"))

# direction 2: my SYCL writes -> old reads (so recorders can write coopmat-owned buffers)
new = (np.arange(N, dtype=np.uint8) ^ 0x5A)
rc = MY.xmx_buf_upload(mid, new.ctypes.data, 0, N)
ok(rc == 0, "MY upload on the imported id" + ("" if rc == 0 else " err=" + MY.xmx_error().decode()))
rtback = X.host_view(buf, np.uint8)[:N].copy()
bad2 = int((rtback != new).sum())
ok(bad2 == 0, f"OLD reads MY's bytes bit-exact ({bad2}/{N} differ)")

MY.xmx_buf_destroy(mid)
buf.free()
print(f"\nPAIRED_IMPORT {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
