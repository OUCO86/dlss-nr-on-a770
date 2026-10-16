#!/usr/bin/env python3
"""Vertical-slice gate: the libxmx_sycl skeleton, driven through ctypes with xmxres.py's
EXACT argtypes, running a real quantize_row through the begin->rec_quant->submit path and
judged against the authoritative numpy contract (int8_quant.quantise + the senior's
bounded criteria). Proves the whole architecture (C ABI + buffer table + record/submit +
SYCL kernel) before the 81-function port grows on it.

Run from oneapi/ (the staging dir where sycl9.dll and its chain live)."""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import int8_quant

for d in (os.getcwd(), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k32 = ctypes.windll.kernel32
_k32.SetErrorMode(0x8002)
for _dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    _p = pathlib.Path.cwd() / _dep
    if _p.exists():
        _k32.LoadLibraryExW(str(_p), 0, 0)

DLL = pathlib.Path.cwd() / "libxmx_sycl.dll"
if not DLL.exists():
    DLL = pathlib.Path(__file__).resolve().parent / "libxmx_sycl.dll"
lib = ctypes.CDLL(str(DLL))

# xmxres.py's exact argtypes for every function the skeleton implements
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []),
    ("xmx_buf_create", [ctypes.c_ulonglong]),
    ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]),
    ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []),
    ("xmx_abort", []),
    ("xmx_submit", []),
    ("xmx_rec_quant", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2),
):
    if hasattr(lib, nm):
        getattr(lib, nm).argtypes = at
        getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "xmx_init (no-arg, as xmx.py binds)")

def run_case(m, k, label):
    global fails
    rng = np.random.default_rng(1234 + m * 7 + k)
    vals = rng.uniform(-1, 1, (m, k)).astype(np.float16).astype(np.float32)
    half = vals.astype(np.float16)
    src = lib.xmx_buf_create(m * k * 2)
    pk = lib.xmx_buf_create_kind(m * k, 1)
    sc = lib.xmx_buf_create_kind(m * 4, 4)
    ok(src > 0 and pk > 0 and sc > 0, f"{label}: three buffer handles {src},{pk},{sc}")
    ok(lib.xmx_buf_upload(src, half.ctypes.data, 0, m * k * 2) == 0, f"{label}: upload source")
    ok(lib.xmx_buf_zero(pk) == 0 and lib.xmx_buf_zero(sc) == 0, f"{label}: zero outputs")
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    ok(lib.xmx_rec_quant(src, pk, sc, m, k) == 0, f"{label}: rec_quant recorded")
    ok(lib.xmx_submit() == 0, f"{label}: submit ran the SYCL kernel")
    gotp = np.zeros(m * k, np.int8); lib.xmx_buf_download(pk, gotp.ctypes.data, 0, m * k)
    gets = np.zeros(m, np.float32);  lib.xmx_buf_download(sc, gets.ctypes.data, 0, m * 4)
    wp, ws = int8_quant.quantise(vals, 1)
    gp = gotp.reshape(m, k)
    ulps = np.abs(gets.view(np.int32) - ws.view(np.int32))
    d = np.abs(gp.astype(np.int32) - wp.astype(np.int32))
    step = gp.astype(np.float64) * gets.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - vals.astype(np.float64)) <= gets.astype(np.float64)[:, None] * limit
    ok(int(ulps.max()) <= 1 and int(d.max()) <= 1 and bool(within.all()),
       f"{label} {m}x{k}: numpy gate scale<=1ulp(max {int(ulps.max())}), packed<=1(max {int(d.max())}, "
       f"{int((gp!=wp).sum())}/{m*k}), within-one {bool(within.all())}")
    for b in (src, pk, sc): lib.xmx_buf_destroy(b)

run_case(8160, 64, "l2")
run_case(192, 1024, "l0")
run_case(64, 16, "tiny")

print(f"\nLIBXMX_SYCL {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
