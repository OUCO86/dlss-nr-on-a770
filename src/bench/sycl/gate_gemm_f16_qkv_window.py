#!/usr/bin/env python3
"""f16 gemm_qkv_window FOUNDATION gate (section 88 route; window_block's first leg).

The f16 twin of the green int8_qkv swap-in #4 (section 75) with the window gather +
publish_image of gemm_staged.comp:222-243. Math pinned from qkv_epilogue.glsl:40-77 + the
gather loader BEFORE writing (section 73):
    gather: row r -> window=r/64, token=r%64; y=(window/across)*8+token/8 - top,
      x=(window%across)*8+token%8 - left; OUT OF RANGE -> the row's 32 channels are 0.0;
      else at=(y*width+x)*32+c, read image (half iff image_mode&1), e4m3 each (publish_image
      always for window blocks), store as the half A row.
    acc = A @ B (B (32, 96) row-major, NOT transposed) -> f32.
    qkv_epilogue (f16 path QKV_READ=float(stage), NO dequantise scale): per row, per head,
      the 32 columns of Q/K/V: Q/K half_round -> cosine_reciprocal -> hmul -> (Q) hmul scale;
      V raw; publish = e4m3 -> half, scatter (window,head,token,32).

Criterion = WITHIN-ONE vs the numpy golden (the f16v1 GEMM leg carries the hardware
K-order slack, section 81; the cosine/publish/scatter legs are the gated arithmetic).
heads==1 (captured window blocks), so the scatter is row-major (rows,32).
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
    ("xmx_rec_gemm_qkv_window", [ctypes.c_int] * 6 + [ctypes.c_uint] * 9),
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

def run(height, width, top, left, image_half, label):
    global fails
    C = 32; heads = 1; tokens = 64; NH = 3 * C
    ph, pw = window_extent(height, width, top, left)
    across = pw // 8
    windows = (ph // 8) * (pw // 8)
    rows = windows * tokens
    pad = (top << 16) | left
    image_mode = (1 if image_half else 0) | 2      # publish_image always
    rng = np.random.default_rng(88150 + height * 7 + width * 3 + top * 11 + left * 13 + image_half)
    pixels = height * width
    img = rng.uniform(-1, 1, size=pixels * C)
    if image_half:
        imgbuf = np.asarray(img, np.float16)
    else:
        imgbuf = img.astype(np.float32)
    W = rng.uniform(-0.25, 0.25, size=C * NH).astype(np.float16)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)

    him = lib.xmx_buf_create_kind(pixels * C * (2 if image_half else 4), 2 if image_half else 4)
    hw = lib.xmx_buf_create_kind(C * NH * 2, 2)
    hq = lib.xmx_buf_create_kind(rows * C * 2, 2); hk = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hv = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hs = lib.xmx_buf_create_kind(heads * 4, 4)
    ok(min(him, hw, hq, hk, hv, hs) > 0, f"{label}: buffers")
    up(him, imgbuf); up(hw, W); up(hs, qkv_scale)
    lib.xmx_buf_zero(hq); lib.xmx_buf_zero(hk); lib.xmx_buf_zero(hv)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_qkv_window(him, hw, hq, hk, hv, hs, rows, C, heads, tokens,
                                     width, height, across, pad, image_mode)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    gq = np.zeros(rows * C * 2, np.uint8); lib.xmx_buf_download(hq, gq.ctypes.data, 0, rows * C * 2)
    gk = np.zeros(rows * C * 2, np.uint8); lib.xmx_buf_download(hk, gk.ctypes.data, 0, rows * C * 2)
    gv = np.zeros(rows * C * 2, np.uint8); lib.xmx_buf_download(hv, gv.ctypes.data, 0, rows * C * 2)
    for h in (him, hw, hq, hk, hv, hs): lib.xmx_buf_destroy(h)

    # ---- numpy golden: gather -> e4m3 half A -> acc -> cosine norm -> e4m3 scatter ----
    A = np.zeros((rows, C), np.float16)
    for r in range(rows):
        w = r // tokens; t = r % tokens
        y = (w // across) * 8 + t // 8 - top
        x = (w % across) * 8 + t % 8 - left
        if y < 0 or x < 0 or y >= height or x >= width:
            continue
        at = (y * width + x) * C
        for c in range(C):
            A[r, c] = np.float16(NM.e4m3(float(imgbuf.view(np.float16)[at + c]) if image_half else float(imgbuf[at + c])))
    acc = (A.astype(np.float32) @ W.view(np.float16).astype(np.float32).reshape(C, NH)).astype(np.float32)
    A4 = acc[:, :C].reshape(windows, tokens, heads, 32)
    K4 = acc[:, C:2 * C].reshape(windows, tokens, heads, 32)
    V4 = acc[:, 2 * C:].reshape(windows, tokens, heads, 32)
    wq = np.asarray(NM.vendor_cosine_publish(np.ascontiguousarray(A4.transpose(0, 2, 1, 3)), qkv_scale), np.float16).reshape(rows * C)
    wk = np.asarray(NM.vendor_cosine_publish(np.ascontiguousarray(K4.transpose(0, 2, 1, 3)), None), np.float16).reshape(rows * C)
    wv = np.asarray(NM.e4m3(np.ascontiguousarray(V4.transpose(0, 2, 1, 3))), np.float16).reshape(rows * C)
    for got, want, tag in ((gq, wq, "Q"), (gk, wk, "K"), (gv, wv, "V")):
        gh = got.view(np.uint16); wh = want.view(np.uint16)
        gz = (gh & 0x7FFF) == 0; wz = (wh & 0x7FFF) == 0
        same = bool(((gh == wh) | (gz & wz)).all())
        if same:
            ok(True, f"{label} {tag}: OUT BITS EQUAL ({windows}w {height}x{width} origin({-top},{-left}) {'half' if image_half else 'float'} image)")
        else:
            d = np.flatnonzero(gh != wh); e = int(d[0])
            ok(False, f"{label} {tag}: {d.size} bad; first {e} got 0x{gh[e]:04x} want 0x{wh[e]:04x}")

# the captured window-block geometries (section 88's plan dump: 544x960, 272x480) shrunk
# for CI, plus a cropped origin (top/left>0) and both image widths.
run(16, 24, 0, 0, False, "QKVW-16x24-float")
run(16, 24, 0, 0, True, "QKVW-16x24-half")
run(20, 36, 4, 4, False, "QKVW-20x36-crop")
run(8, 8, 0, 0, True, "QKVW-8x8-half")
run(40, 56, 0, 0, False, "QKVW-40x56-float")

print(f"\nGEMM_F16_QKV_WINDOW {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
