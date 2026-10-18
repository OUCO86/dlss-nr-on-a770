#!/usr/bin/env python3
"""quant_window swap-in gate (route(a) step 3 #6, section 77).

Composition, not new math: the recorder feeds the SAME proven qr_kernel that
xmx_rec_quant runs (already 0-differ vs numpy on plain/tiny/gather in the standalone
probe) with the 0x400000 gather flag + the four geometry words. The gate therefore
checks the WIRING end-to-end at the plan's real tuples:
  image (height x width, f16, K channels/pixel) -> window-major rows r = window*64+token
  gathered from the image at y=(window/across)*8+token/8, x=(window%across)*8+token%8
  minus (top,left) from pad; OUTSIDE -> the row quantises as all-zero with scale 1.0
  (quantize_row.comp:195-208 + the "empty row" scale rule, mirrored in the golden).
Arithmetic golden = the shipping authority int8_quant.quantise(axis=1) -- NOT a new one
(section 25). Packed compared as raw BYTES (0-differ), scales as f32 bits.

Plan families mirrored: (768,512,20,32,4,pad0/top4), (960,512,20,32,5,both4),
(2560,256,34,60,8,pad0), (32640,64,136,240,30,pad0 shrunk to 1280 for CI).
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import int8_quant as IQ

for d in (str(ROOT.parent.parent / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k = ctypes.windll.kernel32; _k.SetErrorMode(0x8002)
os.chdir(str(ROOT.parent.parent / "oneapi"))
for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    p = pathlib.Path.cwd() / dep
    if p.exists(): _k.LoadLibraryExW(str(p), 0, 0)

lib = ctypes.CDLL(str(pathlib.Path.cwd() / "libxmx_sycl.dll"))
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []),
    ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_rec_quant_window", [ctypes.c_int] * 3 + [ctypes.c_uint] * 6),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def up(h, arr):
    a = np.ascontiguousarray(arr)
    assert a.dtype in (np.float32, np.float16, np.int8), f"upload dtype {a.dtype}"
    assert lib.xmx_buf_upload(h, a.ctypes.data, 0, a.nbytes) == 0, lib.xmx_error().decode()

def run(M, K, h, w, across, pad, label):
    global fails
    top, left = pad >> 16, pad & 0xffff
    rng = np.random.default_rng(7770 + M + K * 3 + h * 7 + w + across * 11 + pad)
    img = rng.uniform(-2.0, 2.0, size=(h * w * K)).astype(np.float16)
    hs = lib.xmx_buf_create_kind(img.nbytes, 2)
    hp = lib.xmx_buf_create_kind(M * K, 1)
    hsc = lib.xmx_buf_create_kind(M * 4, 4)
    ok(min(hs, hp, hsc) > 0, f"{label}: buffers")
    up(hs, img)
    lib.xmx_buf_zero(hp); lib.xmx_buf_zero(hsc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_quant_window(hs, hp, hsc, M, K, h, w, across, pad)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    gp = np.zeros(M * K, np.int8); lib.xmx_buf_download(hp, gp.ctypes.data, 0, M * K)
    gsc = np.zeros(M, np.float32); lib.xmx_buf_download(hsc, gsc.ctypes.data, 0, M * 4)
    for hh in (hs, hp, hsc): lib.xmx_buf_destroy(hh)

    # golden: gather rows (image layout), then int8_quant.quantise per row; outside rows
    # are all-zero with scale 1.0 (the .comp's empty-row rule).
    rows = np.zeros((M, K), np.float32)
    inside = np.zeros(M, bool)
    for r in range(M):
        token = r % 64; window = r // 64
        y = (window // across) * 8 + token // 8 - top
        x = (window % across) * 8 + token % 8 - left
        if 0 <= y < h and 0 <= x < w:
            inside[r] = True
            base = (y * w + x) * K
            rows[r] = img[base:base + K].astype(np.float32)
    packed, scales = IQ.quantise(rows, axis=1)
    # quantise() already maps an all-zero row to scale 1.0 + zeros -- the outside rows
    # need no special case beyond being zero, which they are.
    # (M*K,) flat vs (M,K) 2-D: array_equal says False on SHAPE alone -- the fourth
    # harness bug of this campaign (the device was right; the probe passed 768/768).
    same_p = np.array_equal(gp, packed.reshape(M * K))
    same_s = np.array_equal(gsc.view(np.uint32), scales.view(np.uint32))
    ok(same_p and same_s, f"{label}: packed 0-differ={same_p} scales bits-equal={same_s} "
                          f"(inside {int(inside.sum())}/{M}, pad=0x{pad:x})")

run(768, 512, 20, 32, 4, 0x0, "QW1-768x512-pad0")
run(768, 512, 20, 32, 4, 0x40000, "QW2-768x512-top4")
run(960, 512, 20, 32, 5, 0x40004, "QW3-960x512-both4")
run(2560, 256, 34, 60, 8, 0x0, "QW4-2560x256-pad0")
run(1280, 64, 136, 240, 30, 0x4, "QW5-1280x64-left4")   # plan family shrunk for CI

print(f"\nQUANT_WINDOW {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
