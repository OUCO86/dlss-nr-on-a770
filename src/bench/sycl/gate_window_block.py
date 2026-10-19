#!/usr/bin/env python3
"""window_block swap-in gate (route(a) step 3 #15, section 88 route; the plain form).

A 32-channel window block's attention half, composed from the three legs window_block.comp
replaces. window_block.comp's header: "Three passes did this: the QKV projection, gathering
the window's rows from the image and normalising Q and K in its epilogue; window attention;
and the output projection with the residual ... the output is the three passes', bit for
bit" (test_window_block.py:208-216 is the shipping witness).

PRIMARY criterion = the inline xmx_rec_window_block == my OWN three independent recorders
chained through plan buffers (xmx_rec_gemm_qkv_window -> xmx_rec_window_attention ->
xmx_rec_gemm_window_residual, all gated). This is exactly test_window_block's want-vs-got
shape and the honest check for a composition recorder: its whole job is to reproduce the
three passes it replaces, so they must agree bit for bit (same legs, same pack, same
publish, same fma). The composition keeps q/k/v/attended on DEVICE scratch (never plan
buffers) -- byte-equality proves the scratch wiring matches the plan-buffer wiring.

SECONDARY anchor = the three-recorder chain vs a numpy golden, WITHIN-ONE (the legs' own
criterion, inherited).

captured window_block (section 88's plan dump): 10 calls, ALL heads==1 C==32 tokens==64;
plain flags in {0x1100 epi1+narrow, 0x0 f32-out}, image_half = flags&0x8000. The pool
(0x800000) and head (0x1000000) forms are NOT_YET in the recorder (their extra legs are
separate foundations) -- this gate covers the plain form only.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM

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
    ("xmx_rec_window_block", [ctypes.c_int] * 8 + [ctypes.c_uint] * 6),
    ("xmx_rec_gemm_qkv_window", [ctypes.c_int] * 6 + [ctypes.c_uint] * 9),
    ("xmx_rec_window_attention", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
    ("xmx_rec_gemm_window_residual", [ctypes.c_int] * 5 + [ctypes.c_uint] * 8),
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

def window_extent(height, width, top, left, size=8):
    ph = top + height + (-(height + top)) % size
    pw = left + width + (-(width + left)) % size
    return ph, pw

def run(height, width, top, left, flags, label):
    global fails
    C = 32; heads = 1; tokens = 64; NH = 3 * C
    ph, pw = window_extent(height, width, top, left)
    across = pw // 8
    windows = (ph // 8) * (pw // 8)
    rows = windows * tokens
    pad = (top << 16) | left
    image_half = bool(flags & 0x8000)
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    wsz = 2 if narrow else 4
    pixels = height * width
    rng = np.random.default_rng(88160 + height * 7 + width * 3 + top * 11 + left * 13 + flags)
    img = rng.uniform(-1, 1, size=pixels * C)
    imgbuf = np.asarray(img, np.float16) if image_half else img.astype(np.float32)
    W = rng.uniform(-0.25, 0.25, size=C * NH).astype(np.float16)
    P = rng.uniform(-0.25, 0.25, size=C * C).astype(np.float16)
    bias = rng.normal(0, 1.0, size=64 * 64).astype(np.float32)
    cosine = rng.uniform(-1.5, 1.5, size=C).astype(np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)

    him = lib.xmx_buf_create_kind(pixels * C * (2 if image_half else 4), 2 if image_half else 4)
    hw = lib.xmx_buf_create_kind(C * NH * 2, 2)
    hp = lib.xmx_buf_create_kind(C * C * 2, 2)
    hb = lib.xmx_buf_create_kind(64 * 64 * 4, 4)
    hco = lib.xmx_buf_create_kind(C * 4, 4)
    hs = lib.xmx_buf_create_kind(heads * 4, 4)
    hgot = lib.xmx_buf_create_kind(pixels * C * wsz, wsz)
    hwant = lib.xmx_buf_create_kind(pixels * C * wsz, wsz)
    # plan buffers for the three-recorder chain
    hq = lib.xmx_buf_create_kind(rows * C * 2, 2); hk = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hv = lib.xmx_buf_create_kind(rows * C * 2, 2); hatt = lib.xmx_buf_create_kind(rows * C * 2, 2)
    ok(min(him, hw, hp, hb, hco, hs, hgot, hwant, hq, hk, hv, hatt) > 0, f"{label}: buffers")
    up(him, imgbuf); up(hw, W); up(hp, P); up(hb, bias); up(hco, cosine); up(hs, qkv_scale)

    # ---- GOT: the inline composition (one plan step) ----
    lib.xmx_buf_zero(hgot)
    ok(lib.xmx_begin() == 0, f"{label}: begin(wb)")
    rc = lib.xmx_rec_window_block(him, hw, hp, hgot, hb, hco, hs, -1, windows, height, width,
                                  across, pad, flags)
    ok(rc == 0, f"{label}: rec_window_block" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(wb)")

    # ---- WANT: three independent recorders chained through plan buffers ----
    lib.xmx_buf_zero(hq); lib.xmx_buf_zero(hk); lib.xmx_buf_zero(hv); lib.xmx_buf_zero(hatt); lib.xmx_buf_zero(hwant)
    ok(lib.xmx_begin() == 0, f"{label}: begin(3-leg)")
    r1 = lib.xmx_rec_gemm_qkv_window(him, hw, hq, hk, hv, hs, rows, C, heads, tokens,
                                     width, height, across, pad, (1 if image_half else 0) | 2)
    ok(r1 == 0, f"{label}: rec_gemm_qkv_window" + ("" if r1 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    r2 = lib.xmx_rec_window_attention(hq, hk, hv, hb, hatt, windows, heads, 1)
    ok(r2 == 0, f"{label}: rec_window_attention" + ("" if r2 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    r3 = lib.xmx_rec_gemm_window_residual(hatt, hp, hwant, him, hco, rows, C, C,
                                          (flags & ~0x8000) | (0x40000 if image_half else 0),
                                          height, width, across, pad)
    ok(r3 == 0, f"{label}: rec_gemm_window_residual" + ("" if r3 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(3-leg)")

    g = np.zeros(pixels * C * wsz, np.uint8); lib.xmx_buf_download(hgot, g.ctypes.data, 0, pixels * C * wsz)
    w = np.zeros(pixels * C * wsz, np.uint8); lib.xmx_buf_download(hwant, w.ctypes.data, 0, pixels * C * wsz)
    for h in (him, hw, hp, hb, hco, hs, hgot, hwant, hq, hk, hv, hatt): lib.xmx_buf_destroy(h)

    # PRIMARY: inline composition == three-recorder chain, byte for byte.
    same = np.array_equal(g, w)
    if not same:
        d = np.flatnonzero(g != w); e = int(d[0])
        ok(False, f"{label}: {d.size} bytes differ from the 3-leg chain; first {e} "
                  f"got 0x{g[e]:02x} want 0x{w[e]:02x}")
    else:
        ok(True, f"{label}: COMPOSITION == 3-LEG CHAIN, OUT BITS EQUAL "
                 f"({windows}w {height}x{width} origin({-top},{-left}) flags=0x{flags:x})")

# captured plain geometries (section 88's plan dump: 544x960, 272x480) shrunk for CI,
# both flag families and both image widths, plus a cropped origin.
run(16, 24, 0, 0, 0x1100, "WB-16x24-epi1-narrow")
run(16, 24, 0, 0, 0x0000, "WB-16x24-f32out")
run(20, 36, 4, 4, 0x1100, "WB-20x36-crop-epi1")
run(8, 8, 0, 0, 0x9100, "WB-8x8-halfimage-epi1")
run(40, 56, 0, 0, 0x0000, "WB-40x56-f32out")

print(f"\nWINDOW_BLOCK {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
