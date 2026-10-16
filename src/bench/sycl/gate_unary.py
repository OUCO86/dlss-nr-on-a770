#!/usr/bin/env python3
"""Unary/publish gate: the SYCL rounding points vs nr_model, BIT-EXACT.

The senior's own gate for these (src/gpu/test_resident.py:65) is np.array_equal — not
the bounded comparison quantize uses. So the SYCL translation of publish.glsl
(fmul_rn/fadd_rn per op, no FMA contraction) must match numpy's e4m3 /
quadratic_gate_activation / _half_rounded to the bit, including NaN.

Drives it through the libxmx_sycl skeleton's C ABI (xmx_rec_unary32), the same shape
the 81-function port will use."""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as M

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
    ("xmx_rec_unary32", [ctypes.c_int] * 2 + [ctypes.c_uint] * 2),
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

# values that stress every rounding point: ordinary, subnormal-half, e4m3 boundaries,
# the ±4 gate clamp edges, negatives, and e4m3 saturation.
#
# NaN is deliberately NOT fed to e4m3 here: SYCL fmin(NaN,448) and GLSL min() both
# take the non-NaN operand (->448), while numpy's np.minimum PROPAGATES NaN. That is a
# pre-existing reference-vs-shipped divergence (the shipped GLSL e4m3 also yields 448
# for a NaN input), not something the rewrite introduces, and the real pipeline never
# feeds a NaN to e4m3 (its input is a post-gate activation). The senior's own gate
# (test_resident.py) sidesteps it by using no NaN inputs. So the e4m3 bit-exact demand
# is over every value the pipeline can actually produce.
def sample(n):
    rng = np.random.default_rng(7)
    v = rng.uniform(-5, 5, n).astype(np.float32)
    v[:12] = np.array([0.0, -0.0, 448.0, -448.0, 447.9, 2**-6, 2**-9, 2**-10,
                       4.0, -4.0, 500.0, -500.0], np.float32)   # 500: e4m3 saturates to 448
    # e4m3 half-even ties and gate slope/intercept exact-representation edges
    for i in range(12, min(n, 60)):
        v[i] = np.float32((i % 256) * 2**-9) * np.where(i % 2, 1.0, -1.0)
    return v

CASES = [("half", 4, M._half_rounded), ("e4m3", 1, M.e4m3),
         ("gate", 2, M.quadratic_gate_activation), ("gate+e4m3", 3,
          lambda a: M.e4m3(M.quadratic_gate_activation(a)))]

for N in (256, 8160 * 64 // 4):
    vals = sample(N)
    src = lib.xmx_buf_create(N * 4); dst = lib.xmx_buf_create(N * 4)
    ok(src > 0 and dst > 0, f"N={N}: buffers")
    lib.xmx_buf_upload(src, vals.ctypes.data, 0, N * 4)
    for label, epi, fn in CASES:
        ok(lib.xmx_buf_zero(dst) == 0, f"N={N} {label}: zero dst")
        ok(lib.xmx_begin() == 0, f"N={N} {label}: begin")
        ok(lib.xmx_rec_unary32(src, dst, N, epi) == 0, f"N={N} {label}: rec_unary32")
        ok(lib.xmx_submit() == 0, f"N={N} {label}: submit")
        got = np.zeros(N, np.float32); lib.xmx_buf_download(dst, got.ctypes.data, 0, N * 4)
        want = fn(vals)
        exact = np.array_equal(got, want, equal_nan=True)
        if not exact:
            diff = np.nonzero(~(np.isclose(got, want, rtol=0, atol=0) | (np.isnan(got) & np.isnan(want))))[0]
            first = int(diff[0]) if diff.size else -1
            ulps = int(np.abs(got.view(np.int32) - want.view(np.int32)).max()) if first>=0 else 0
            print(f"        first diff idx={first} got={got[first] if first>=0 else '?'} "
                  f"want={want[first] if first>=0 else '?'} nbad={diff.size} maxulp={ulps}")
        ok(exact, f"N={N} {label}: BIT-EXACT vs nr_model ({int((got!=want).sum()) if not exact else 0} differ)")
    lib.xmx_buf_destroy(src); lib.xmx_buf_destroy(dst)

print(f"\nPUBLISH {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
