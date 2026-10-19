#!/usr/bin/env python3
"""window_block HEAD form gate (route(a) step 3 #17, section 88 route; block 70).

The head form (flags 0x1000000): the block's output is NOT stored as the image -- it feeds
the compact head GEMM directly (test_window_block.py:143-152). Decomposition:
    leg1 gemm_qkv_window -> q,k,v
    leg2 window_attention -> attended (merged)
    leg3 gemm_window_residual (narrow, epi=0) -> out16 (pixels x 32 half) = half(fma(image,cosine,acc))
    leg4 gemm(out16, head weights 32 x 16 -> target, compact_output) -> target[pixel*4+c] = (out16@W)[pixel*16+c], c<4

The head weights ride the `pooled` ABI slot (libxmx.c:2632: "pooled carries the head's
weights"). The target is pixels x 4 float32 (compact). No independent compact-GEMM recorder
exists, so this gate checks the inline composition against a numpy four-leg golden,
WITHIN-ONE (the f16v1 GEMM legs carry the hardware K-order slack; the target is float32,
no publish).
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
    flags = 0x1000000 | (0x8000 if image_half else 0)
    pixels = height * width
    rng = np.random.default_rng(88180 + height * 7 + width * 3 + top * 11 + left * 13 + image_half)
    img = rng.uniform(-1, 1, size=pixels * C)
    imgbuf = np.asarray(img, np.float16) if image_half else img.astype(np.float32)
    W = rng.uniform(-0.25, 0.25, size=C * NH).astype(np.float16)
    P = rng.uniform(-0.25, 0.25, size=C * C).astype(np.float16)
    bias = rng.normal(0, 1.0, size=64 * 64).astype(np.float32)
    cosine = rng.uniform(-1.5, 1.5, size=C).astype(np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)
    hw = np.zeros((C, 16), np.float32); hw[:, :4] = rng.normal(0, 0.3, (C, 4))
    headw = hw.astype(np.float16)

    him = lib.xmx_buf_create_kind(pixels * C * (2 if image_half else 4), 2 if image_half else 4)
    hqkv = lib.xmx_buf_create_kind(C * NH * 2, 2)
    hpr = lib.xmx_buf_create_kind(C * C * 2, 2)
    hb = lib.xmx_buf_create_kind(64 * 64 * 4, 4)
    hco = lib.xmx_buf_create_kind(C * 4, 4)
    hs = lib.xmx_buf_create_kind(heads * 4, 4)
    hwt = lib.xmx_buf_create_kind(C * 16 * 2, 2)          # head weights in the pooled slot
    htg = lib.xmx_buf_create_kind(pixels * 4 * 4, 4)      # compact float32 target
    ok(min(him, hqkv, hpr, hb, hco, hs, hwt, htg) > 0, f"{label}: buffers")
    up(him, imgbuf); up(hqkv, W); up(hpr, P); up(hb, bias); up(hco, cosine); up(hs, qkv_scale); up(hwt, headw)
    lib.xmx_buf_zero(htg)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_window_block(him, hqkv, hpr, htg, hb, hco, hs, hwt, windows, height, width, across, pad, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(pixels * 4 * 4, np.uint8); lib.xmx_buf_download(htg, got.ctypes.data, 0, pixels * 4 * 4)
    for h in (him, hqkv, hpr, hb, hco, hs, hwt, htg): lib.xmx_buf_destroy(h)

    # ---- numpy four-leg golden ----
    A = np.zeros((rows, C), np.float16)
    for r in range(rows):
        w = r // tokens; t = r % tokens
        y = (w // across) * 8 + t // 8 - top; x = (w % across) * 8 + t % 8 - left
        if y < 0 or x < 0 or y >= height or x >= width: continue
        at = (y * width + x) * C
        for c in range(C):
            A[r, c] = np.float16(NM.e4m3(float(imgbuf.view(np.float16)[at + c]) if image_half else float(imgbuf[at + c])))
    acc = (A.astype(np.float32) @ W.view(np.float16).astype(np.float32).reshape(C, NH)).astype(np.float32)
    A4 = acc[:, :C].reshape(windows, tokens, heads, 32); K4 = acc[:, C:2*C].reshape(windows, tokens, heads, 32); V4 = acc[:, 2*C:].reshape(windows, tokens, heads, 32)
    q = np.asarray(NM.vendor_cosine_publish(np.ascontiguousarray(A4.transpose(0,2,1,3)), qkv_scale), np.float16).reshape(rows, C)
    k = np.asarray(NM.vendor_cosine_publish(np.ascontiguousarray(K4.transpose(0,2,1,3)), None), np.float16).reshape(rows, C)
    v = np.asarray(NM.e4m3(np.ascontiguousarray(V4.transpose(0,2,1,3))), np.float16).reshape(rows, C)
    # window attention (heads==1)
    att = np.zeros((rows, C), np.float16)
    for w in range(windows):
        sc = q[w*64:(w+1)*64].astype(np.float32) @ k[w*64:(w+1)*64].astype(np.float32).T
        pr = np.asarray(NM.vendor_approximate_softmax(sc + bias.reshape(64, 64)), np.float32).astype(np.float16)
        ctx = pr.astype(np.float32) @ v[w*64:(w+1)*64].astype(np.float32)
        for t in range(64):
            for c in range(C):
                att[w*64+t, c] = np.float16(NM.e4m3(ctx[t, c]))
    # leg3: out16[pixel*32+c] = half(fma(image[out], cosine[c], (att@P)[r,c]))
    acc3 = (att.astype(np.float32) @ P.view(np.float16).astype(np.float32).reshape(C, C)).astype(np.float32)
    imgf = imgbuf.view(np.float16).astype(np.float32) if image_half else imgbuf.astype(np.float32)
    out16 = np.zeros((pixels, C), np.float16)
    for r in range(rows):
        w = r // 64; t = r % 64
        y = (w // across) * 8 + t // 8; x = (w % across) * 8 + t % 8
        if y < top or x < left or y - top >= height or x - left >= width: continue
        out = (y - top) * width + (x - left)
        for c in range(C):
            total = (np.float64(imgf[out*C+c]) * np.float64(cosine[c]) + np.float64(acc3[r, c])).astype(np.float32)
            out16[out, c] = np.float16(total)
    # leg4: target[pixel*4+c] = (out16 @ headw)[pixel*16+c], c<4
    h4 = (out16.astype(np.float32) @ headw.view(np.float16).astype(np.float32).reshape(C, 16)).astype(np.float32)
    want = np.zeros(pixels * 4, np.float32)
    for p in range(pixels):
        for c in range(4): want[p*4+c] = h4[p, c]
    gv = got.view(np.float32)
    tol = np.maximum(np.abs(want) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(gv - want) > tol).sum())
    if nbad:
        e = int(np.flatnonzero(np.abs(gv - want) > tol)[0])
        ok(False, f"{label}: {nbad} bad; first {e} got {gv[e]:.6g} want {want[e]:.6g}")
    else:
        ok(True, f"{label}: HEAD FOUR-LEG WITHIN-ONE ({windows}w {height}x{width} origin({-top},{-left}) {'half' if image_half else 'float'} image)")

run(16, 24, 0, 0, False, "HEAD-16x24-float")
run(20, 36, 4, 4, True, "HEAD-20x36-crop-half")
run(8, 8, 0, 0, True, "HEAD-8x8-half")

print(f"\nWINDOW_BLOCK_HEAD {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
