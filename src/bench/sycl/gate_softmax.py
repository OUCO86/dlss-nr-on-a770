#!/usr/bin/env python3
"""Softmax island-1 gate: the SYCL bit-affine softmax vs nr_model, BIT-EXACT.

Golden = nr_model.vendor_approximate_softmax (:211), the shipped authority the senior's
window_attention.comp:54-62 implements in GLSL. The kernel re-derives every step:
half_round -> f32 scale/bias -> f32 clamp (bounds exact in half) -> one f16 round ->
the coupled half-pair bit transform ((packed<<5)+0x7FF88000) -> sequential f32 row sum
rounded once to f16 (the golden's comment is explicit that numpy does NOT accumulate in
half) -> f32 reciprocal -> e4m3.

Inputs stress the transform's domain: values that clamp at both bounds, values whose
affine hits the magic-add overflow boundary, ties, negatives, and a zero row (reciprocal
of a zero sum -> the golden's inf path).
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
    ("xmx_rec_softmax", [ctypes.c_int] * 2 + [ctypes.c_uint] * 2),
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

# The affine maps value -> half_round(value)*0.044921875 + 1.30078125 clamped to
# [1.03125, 1.5693359375]. To exercise the clamp edges and the magic-add overflow, feed
# values across the whole pre-clamp range plus the exact clamp crossover points.
def sample(rows, cols):
    rng = np.random.default_rng(202 + rows * 3 + cols)
    v = rng.uniform(-30, 30, (rows, cols)).astype(np.float32)
    # clamp crossovers: affine==LO at value=(1.03125-1.30078125)/0.044921875; HI at
    # (1.5693359375-1.30078125)/0.04492125. Put a few exactly there and near them.
    lo_v = np.float32((1.03125 - 1.30078125) / 0.044921875)
    hi_v = np.float32((1.5693359375 - 1.30078125) / 0.044921875)
    v[0, :4] = np.array([lo_v, hi_v, lo_v - 0.001, hi_v + 0.001], np.float32)
    v[1, :8] = 0.0                       # a mid row: all-zero logits -> uniform weights
    for r in range(2, min(rows, 10)):    # ties on the f16 grid, both signs
        v[r] = np.float32((r % 7) - 3) * np.float32(2 ** -4)
    return v

def run(rows, cols, label):
    global fails
    assert cols % 2 == 0
    vals = sample(rows, cols)
    hs = lib.xmx_buf_create_kind(rows * cols * 4, 4)
    hd = lib.xmx_buf_create_kind(rows * cols * 2, 2)
    ok(hs > 0 and hd > 0, f"{label}: buffers")
    lib.xmx_buf_upload(hs, vals.ctypes.data, 0, rows * cols * 4)
    lib.xmx_buf_zero(hd)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_softmax(hs, hd, rows, cols)
    ok(rc == 0, f"{label}: rec_softmax" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * cols, np.float16); lib.xmx_buf_download(hd, got.ctypes.data, 0, rows * cols * 2)
    want = NM.vendor_approximate_softmax(vals)   # (rows, cols) float32 (e4m3 grid, f32-typed)
    # every e4m3 value is exactly representable in half (exponent range [-6,8], 3-bit
    # mantissa), so astype(f16) is lossless and the bit compare is the senior's contract.
    want16 = np.asarray(want, np.float32).astype(np.float16)
    exact = np.array_equal(got.view(np.uint16), want16.ravel().view(np.uint16))
    if not exact:
        g = got.reshape(rows, cols); w = want16
        d = np.nonzero(g.view(np.uint16) != w.view(np.uint16))
        for r, c in list(zip(*d))[:5]:
            print(f"        ({r},{c}): got {g[r,c]} want {w[r,c]} (logit {vals[r,c]})")
        print(f"        nbad={d[0].size}")
    ok(exact, f"{label} {rows}x{cols}: BIT-EXACT vs vendor_approximate_softmax "
              f"({int((got.view(np.uint16)!=want16.ravel().view(np.uint16)).sum()) if not exact else 0} differ)")
    lib.xmx_buf_destroy(hs); lib.xmx_buf_destroy(hd)

run(64, 64, "w64")        # window attention: 64 tokens
run(256, 64, "w64-big")
run(64, 128, "w128")      # global attention: 128 tokens
run(128, 256, "w256")     # vit path token count

print(f"\nSOFTMAX {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
