#!/usr/bin/env python3
"""GEMM path-validation gate: the senior's proven v1 ESIMD int8 GEMM driven through
the libxmx_sycl skeleton's begin->rec_gemm_s8->submit pipeline, checked bit-exact
against numpy's exact integer product.

The authority is int8 x int8 -> int32 EXACT (test_gemm_int8.py:68 `a.astype(int32) @
b.astype(int32)`, judged wrong==0) — integer math, no rounding tolerance needed. This
cut proves the PIPELINE (C ABI -> buffer table -> record/submit -> ESIMD kernel ->
exact int32 readback), not speed; the shapes are v1's own proven ones. Speed/merge is
the next step (the real pipeline's N is narrow — 32..96 — so the merge to wide is what
recovers TOPS; see notes section 8/9).

Run from oneapi/ (SYCL runtime chain there)."""
import ctypes, os, pathlib, sys
import numpy as np

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
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create", [ctypes.c_ulonglong]),
    ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_rec_gemm_s8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 3),
):
    if hasattr(lib, nm):
        getattr(lib, nm).argtypes = at
        getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "xmx_init")

def run(M, N, K, label):
    global fails
    rng = np.random.default_rng(11 + M + N + K)
    a = rng.integers(-127, 128, size=(M, K), dtype=np.int8)
    b = rng.integers(-127, 128, size=(K, N), dtype=np.int8)
    ha = lib.xmx_buf_create(M * K)
    hb = lib.xmx_buf_create(K * N)
    hc = lib.xmx_buf_create_kind(M * N * 4, 4)   # int32 out
    ok(ha > 0 and hb > 0 and hc > 0, f"{label} {M}x{N}x{K}: buffers")
    ok(lib.xmx_buf_upload(ha, a.ctypes.data, 0, M * K) == 0, f"{label}: upload a")
    ok(lib.xmx_buf_upload(hb, b.ctypes.data, 0, K * N) == 0, f"{label}: upload b")
    ok(lib.xmx_buf_zero(hc) == 0, f"{label}: zero c")
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    ok(lib.xmx_rec_gemm_s8(ha, hb, hc, M, N, K) == 0, f"{label}: rec_gemm_s8")
    rc = lib.xmx_submit()
    ok(rc == 0, f"{label}: submit" + ("" if rc == 0 else "  err=" + lib.xmx_error().decode(errors='replace')))
    got = np.zeros(M * N, np.int32); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N * 4)
    want = (a.astype(np.int32) @ b.astype(np.int32)).reshape(M, N)
    gp = got.reshape(M, N)
    wrong = int((gp != want).sum())
    if wrong:
        d = np.nonzero(gp != want); i = (d[0][0], d[1][0])
        print(f"        first diff at {i}: got {gp[i]} want {want[i]}")
    ok(wrong == 0, f"{label} {M}x{N}x{K}: int32 BIT-EXACT vs numpy a@b ({wrong}/{M*N} wrong)")
    for h in (ha, hb, hc): lib.xmx_buf_destroy(h)

# v1's own proven correctness shape + a wider one that exercises the K-loop pipeline.
run(256, 256, 256, "v1-correct-shape")
run(512, 128, 96,  "wide-ish")
run(1024, 256, 512, "k-loop")

print(f"\nGEMM_S8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
