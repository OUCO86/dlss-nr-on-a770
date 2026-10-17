#!/usr/bin/env python3
"""v7 (BN=32 fused-requant with A row scale) gate: route-B attnV/outproj, section 52.

Two properties, both from the section-52 a_scale algebra:
1. bounded requantize (same criteria as the s8rq gate): reconstruction int8*new_scale
   within half a step of fp = acc*a_scale[row]*b_scale[col] (numpy, divide-form), and
   new_scale within 1 ulp of rmax/127.
2. the STRONG scale-invariance: multiplying one row's a_scale by any positive factor
   leaves the int8 bytes IDENTICAL (rmax and inv rescale together) and multiplies that
   row's new_scale by exactly the factor. This is what lets softmax_i8's probs row scale
   ps_q flow through attnV into new_scale without touching quantization -- the attended
   amplitude is exactly right in the scale vector. If the fold were buggy (e.g. applied
   to fp but not inv) this catches it immediately.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM  # noqa: F401  (parity with the other gates; not used in the body)

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
    ("xmx_rec_gemm_s8rq32", [ctypes.c_int] * 6 + [ctypes.c_uint] * 3),
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

def once(M, N, K, a, b, a_scale, col_scale, label):
    ha = lib.xmx_buf_create(M * K); hb = lib.xmx_buf_create(K * N)
    hc = lib.xmx_buf_create_kind(M * N, 1)
    has = lib.xmx_buf_create_kind(M * 4, 4)
    hcs = lib.xmx_buf_create_kind(N * 4, 4)
    hns = lib.xmx_buf_create_kind(M * 4, 4)
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, M * K)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, K * N)
    lib.xmx_buf_upload(has, np.ascontiguousarray(a_scale, np.float32).ctypes.data, 0, M * 4)
    lib.xmx_buf_upload(hcs, np.ascontiguousarray(col_scale, np.float32).ctypes.data, 0, N * 4)
    lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
    lib.xmx_begin()
    rc = lib.xmx_rec_gemm_s8rq32(ha, hb, hc, has, hcs, hns, M, N, K)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * N, np.int8); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N)
    gns = np.zeros(M, np.float32); lib.xmx_buf_download(hns, gns.ctypes.data, 0, M * 4)
    for h in (ha, hb, hc, has, hcs, hns): lib.xmx_buf_destroy(h)
    return got.reshape(M, N), gns

def bounded(M, N, K, a, b, a_scale, col_scale, label):
    got, gns = once(M, N, K, a, b, a_scale, col_scale, label)
    f32 = np.float32
    acc = a.astype(np.int32) @ b.astype(np.int32)
    fp = (acc.astype(f32) * a_scale.astype(f32)[:, None]).astype(f32) * col_scale.astype(f32)[None, :]
    rmax = np.max(np.abs(fp), axis=1)
    wns = (rmax / f32(127.0)).astype(f32)
    q = np.divide(fp, wns[:, None], out=np.zeros_like(fp, np.float64), where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    step = got.astype(np.float64) * gns.astype(np.float64)[:, None]
    tol = 0.5 + 2.0 ** -16
    within = np.abs(step - fp.astype(np.float64)) <= np.maximum(gns.astype(np.float64), 1e-30)[:, None] * tol
    sculp = int(np.abs(gns.view(np.int32) - wns.view(np.int32)).max())
    exact = np.array_equal(got, want)
    ok(bool(within.all()) and sculp <= 1,
       f"{label} {M}x{N}x{K}: within-one {bool(within.all())}, scale<=1ulp (max {sculp}), "
       f"divide-form byte-equal {exact}")

def invariance(M, N, K, a, b, a_scale, col_scale, row, factor, label):
    g0, s0 = once(M, N, K, a, b, a_scale, col_scale, f"{label}:base")
    a1 = a_scale.astype(np.float64).copy()
    a1[row] *= factor
    g1, s1 = once(M, N, K, a, b, a1.astype(np.float32), col_scale, f"{label}:scaled")
    same = np.array_equal(g0, g1)                       # int8 bytes invariant
    # new_scale row *= factor (1-ulp on f32), every other row bit-identical
    others = np.array_equal(np.delete(s0, row), np.delete(s1, row))
    expect = a_scale.astype(np.float64)[row] * factor * np.max(np.abs((a.astype(np.int32)[row] @ b.astype(np.int32)).astype(np.float64) * col_scale.astype(np.float64))) / 127.0
    r_ok = int(np.abs(s1[row].view(np.int32) if False else np.float32(s1[row]).view(np.int32) - np.float32(s0[row] * factor).view(np.int32))) <= 2
    ok(same and others and r_ok,
       f"{label}: row{row} a_scale x{factor}: int8 invariant {same}, other scales identical "
       f"{others}, scaled-row within-2ulp {r_ok}")

rng = np.random.default_rng(555)
def shapes():
    for M, N, K, label in ((640, 32, 640, "attnV-global-640"), (256, 32, 256, "attnV-720p"),
                           (128, 32, 128, "attnV-small"), (640, 32, 128, "outproj-32"),
                           (1024, 32, 64, "attnV-windowM1024")):
        a = rng.integers(-127, 128, size=(M, K), dtype=np.int8)
        b = rng.integers(-127, 128, size=(K, N), dtype=np.int8)
        a_scale = (0.001 * (np.arange(M) % 31 + 1)).astype(np.float32)
        col_scale = (0.002 * (np.arange(N) % 13 + 1)).astype(np.float32)
        yield M, N, K, a, b, a_scale, col_scale, label

for M, N, K, a, b, a_scale, col_scale, label in list(shapes()):
    bounded(M, N, K, a, b, a_scale, col_scale, label)
for M, N, K, a, b, a_scale, col_scale, label in list(shapes())[:3]:
    invariance(M, N, K, a, b, a_scale, col_scale, 17, 3.7, label)
    invariance(M, N, K, a, b, a_scale, col_scale, 0, 0.5, label + "-row0")

print(f"\nGEMM_S8RQ32 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
