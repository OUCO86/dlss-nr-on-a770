#!/usr/bin/env python3
"""Cosine-normalise (island-2) gate: the SYCL fragment tree vs nr_model, BIT-EXACT.

Golden = nr_model.vendor_cosine_normalize (ref/nr_model.py:242, the window-block tree)
and nr_model._vit_norm (:683, the ViT tree) -- shipped authority, the same functions the
senior's test_gemm_int8_qkv.py / test_resident.py chain uses. No new golden (section 25).

Inputs are half-rounded f32 (the golden's domain: vendor_cosine_normalize half-rounds
internally; _vit_norm documents half inputs) plus the tree's edge cases: a zero head
(the floor path), a huge head (overflow into inf under half arithmetic), and ties.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM

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
    ("xmx_rec_cosine_norm", [ctypes.c_int] * 2 + [ctypes.c_uint] * 2),
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

def sample(rows):
    rng = np.random.default_rng(99 + rows)
    v = rng.uniform(-4, 4, (rows, 32)).astype(np.float32)
    v = NM._half_rounded(v)
    v[0] = 0.0                                   # floor path: zero head
    v[1] = NM._half_rounded(np.full(32, 300.0, np.float32))   # large: half squares overflow
    v[2] = NM._half_rounded(np.full(32, 0.001, np.float32))   # tiny: near floor
    for r in range(3, min(rows, 12)):            # ties: powers of two plus a 1.5x
        v[r] = NM._half_rounded(np.full(32, float(2 ** (r % 8)) * 1.5, np.float32))
    return v

def run(rows, vit, label):
    global fails
    vals = sample(rows)
    hs = lib.xmx_buf_create_kind(rows * 32 * 4, 4)
    hd = lib.xmx_buf_create_kind(rows * 32 * 4, 4)
    ok(hs > 0 and hd > 0, f"{label}: buffers")
    lib.xmx_buf_upload(hs, vals.ctypes.data, 0, rows * 32 * 4)
    lib.xmx_buf_zero(hd)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    ok(lib.xmx_rec_cosine_norm(hs, hd, rows, 1 if vit else 0) == 0, f"{label}: rec_cosine_norm")
    rc = lib.xmx_submit()
    ok(rc == 0, f"{label}: submit" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    got = np.zeros(rows * 32, np.float32); lib.xmx_buf_download(hd, got.ctypes.data, 0, rows * 32 * 4)
    # _vit_norm returns only the reciprocal; the epilogue's hmul(h[i],reciprocal)
    # (qkv_epilogue.glsl:53) and vit_attend:755 both half_round the product. The kernel
    # does qr_half_round(cr_mul(...)); the golden must wrap it the same way (window path's
    # vendor_cosine_normalize already half_rounds internally at nr_model.py:277).
    want = NM._half_rounded(NM._vit_norm(vals)[:, None] * vals).astype(np.float32) if vit else \
           NM.vendor_cosine_normalize(vals).astype(np.float32)
    exact = np.array_equal(got.reshape(rows, 32), want.reshape(rows, 32), equal_nan=True)
    if not exact:
        g, w = got.reshape(rows, 32), want.reshape(rows, 32)
        bad = np.nonzero(~(np.isclose(g, w, rtol=0, atol=0) | (np.isnan(g) & np.isnan(w))))
        for r, c in list(zip(*bad))[:5]:
            print(f"        ({r},{c}): got {g[r,c]} want {w[r,c]}")
        print(f"        nbad={bad[0].size}")
    ok(exact, f"{label} rows={rows}: BIT-EXACT vs nr_model ({label.split()[0]})")
    lib.xmx_buf_destroy(hs); lib.xmx_buf_destroy(hd)

run(256, 0, "window-tree")
run(8192, 0, "window-tree-big")
run(256, 1, "vit-tree")
run(8192, 1, "vit-tree-big")

print(f"\nCOSINE {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
