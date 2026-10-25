#!/usr/bin/env python3
"""window_block swap-in gate (route(a) step 3 #15/#16, section 88 route; plain + pool forms).

A 32-channel window block's attention half, composed from the three legs window_block.comp
replaces. window_block.comp's header: "Three passes did this: the QKV projection gathering
the window rows from the image and normalising Q/K in its epilogue; window attention; and
the output projection with the residual ... the output is the three passes' bit for bit"
(test_window_block.py is the shipping witness).

PRIMARY criterion = the inline xmx_rec_window_block == my OWN three independent recorders
chained through plan buffers (gemm_qkv_window -> window_attention -> gemm_window_residual
[plain] / gemm_window_residual_pool [pool], all gated). The honest check for a composition
recorder: its whole job is to reproduce the passes it replaces, so they agree bit for bit.

captured window_block = 10 calls: plain 8 (flags 0x1100 / 0x0), pool 1 (0x800000), head 1
(0x1000000). The head form's chain leg = the compact-head GEMM (test_window_block.py:151-152
rt.gemm(out16, weights, target, pixels, 16, 32, compact_output=True) -- xmxres.py:1791-1800
carries it as bt bit 0x10000 with N=16, ldc=4, plain FP32; the shipping guard libxmx.c:2290
pins the same requirements). The inline recorder already built that leg (section 88 #16);
the head case here is its gate, and the expected values the section-99 pool/head ESIMD
fusion must keep bit-exact.
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
    ("xmx_rec_gemm_window_residual_pool", [ctypes.c_int] * 6 + [ctypes.c_uint] * 8),
    ("xmx_rec_gemm", [ctypes.c_int] * 3 + [ctypes.c_uint] * 14),
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
    pooling = bool(flags & 0x800000)
    head = bool(flags & 0x1000000)
    narrow = bool(flags & 0x1000)
    wsz = 2 if (narrow or pooling) else 4
    pixels = height * width
    rng = np.random.default_rng(88160 + height * 7 + width * 3 + top * 11 + left * 13 + flags)
    img = rng.uniform(-1, 1, size=pixels * C)
    imgbuf = np.asarray(img, np.float16) if image_half else img.astype(np.float32)
    W = rng.uniform(-0.25, 0.25, size=C * NH).astype(np.float16)
    P = rng.uniform(-0.25, 0.25, size=C * C).astype(np.float16)
    bias = rng.normal(0, 1.0, size=64 * 64).astype(np.float32)
    cosine = rng.uniform(-1.5, 1.5, size=C).astype(np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)
    # the head form's weights (test_window_block.py:125-127): 32x16, only four columns
    # matter for the compact store; fill all sixteen so a wrong column would be caught.
    headw = np.zeros((C, 16), np.float16)
    headw[:, :4] = rng.normal(0, 0.3, (C, 4)).astype(np.float16)
    headw[:, 4:] = rng.normal(0, 0.3, (C, 12)).astype(np.float16)
    te = pixels * 4 * 4 if head else pixels * C * wsz   # target bytes: compact f32 x4, else image

    him = lib.xmx_buf_create_kind(pixels * C * (2 if image_half else 4), 2 if image_half else 4)
    hw = lib.xmx_buf_create_kind(C * NH * 2, 2)
    hp = lib.xmx_buf_create_kind(C * C * 2, 2)
    hb = lib.xmx_buf_create_kind(64 * 64 * 4, 4)
    hco = lib.xmx_buf_create_kind(C * 4, 4)
    hs = lib.xmx_buf_create_kind(heads * 4, 4)
    hgot = lib.xmx_buf_create_kind(te, 4 if head else wsz)
    hwant = lib.xmx_buf_create_kind(te, 4 if head else wsz)
    hq = lib.xmx_buf_create_kind(rows * C * 2, 2); hk = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hv = lib.xmx_buf_create_kind(rows * C * 2, 2); hatt = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hpooled = -1; hpw = -1
    if pooling:
        hpooled = lib.xmx_buf_create_kind(pixels // 4 * C * 2, 2)
        hpw = lib.xmx_buf_create_kind(pixels // 4 * C * 2, 2)
    if head:
        hpw = lib.xmx_buf_create_kind(C * 16 * 2, 2)   # the head weights ride the `pooled` slot
    ok(min(him, hw, hp, hb, hco, hs, hgot, hwant, hq, hk, hv, hatt) > 0 and (hpooled > 0 if pooling else True),
       f"{label}: buffers")
    up(him, imgbuf); up(hw, W); up(hp, P); up(hb, bias); up(hco, cosine); up(hs, qkv_scale)
    for h in (hgot, hwant, hq, hk, hv, hatt): lib.xmx_buf_zero(h)
    if pooling: lib.xmx_buf_zero(hpooled); lib.xmx_buf_zero(hpw)
    if head: up(hpw, headw.ravel())

    ok(lib.xmx_begin() == 0, f"{label}: begin(wb)")
    rc = lib.xmx_rec_window_block(him, hw, hp, hgot, hb, hco, hs,
                                  (hpooled if pooling else hpw),
                                  windows, height, width, across, pad, flags)
    ok(rc == 0, f"{label}: rec_window_block" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(wb)")

    for h in (hq, hk, hv, hatt, hwant): lib.xmx_buf_zero(h)
    if pooling: lib.xmx_buf_zero(hpw)
    ok(lib.xmx_begin() == 0, f"{label}: begin(3-leg)")
    r1 = lib.xmx_rec_gemm_qkv_window(him, hw, hq, hk, hv, hs, rows, C, heads, tokens,
                                     width, height, across, pad, (1 if image_half else 0) | 2)
    ok(r1 == 0, f"{label}: rec_gemm_qkv_window" + ("" if r1 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    r2 = lib.xmx_rec_window_attention(hq, hk, hv, hb, hatt, windows, heads, 1)
    ok(r2 == 0, f"{label}: rec_window_attention" + ("" if r2 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    if head:
        # leg 3 = the narrow residual into out16 (pixels x 32 half), leg 4 = the compact
        # head GEMM (test_window_block.py:148-152; xmxres.py:1791-1800: leading=(0,0,4),
        # batch strides dense, sc=rows*4, bt bit 0x10000, plain FP32).
        r3 = lib.xmx_rec_gemm_window_residual(
            hatt, hp, hv, him, hco, rows, C, C,
            (flags & ~0x1000000 & ~0x8000) | 0x1000 | (0x40000 if image_half else 0),
            height, width, across, pad)
        ok(r3 == 0, f"{label}: rec_gemm_window_residual(narrow)" + ("" if r3 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
        r4 = lib.xmx_rec_gemm(hv, hpw, hwant, pixels, 16, C, 1,
                              pixels * C, C * 16, pixels * 4, 0x10000,
                              0, 0, 4, 0, 0, 0)
        ok(r4 == 0, f"{label}: rec_gemm(compact head)" + ("" if r4 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    elif pooling:
        r3 = lib.xmx_rec_gemm_window_residual_pool(
            hatt, hp, hwant, him, hco, hpw, rows, C, C,
            (flags & ~0x800000 & ~0x8000) | (0x40000 if image_half else 0),
            height, width, across, pad)
        ok(r3 == 0, f"{label}: rec_gemm_window_residual_pool" + ("" if r3 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    else:
        r3 = lib.xmx_rec_gemm_window_residual(
            hatt, hp, hwant, him, hco, rows, C, C,
            (flags & ~0x8000) | (0x40000 if image_half else 0),
            height, width, across, pad)
        ok(r3 == 0, f"{label}: rec_gemm_window_residual" + ("" if r3 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(3-leg)")

    g = np.zeros(te, np.uint8); lib.xmx_buf_download(hgot, g.ctypes.data, 0, te)
    w = np.zeros(te, np.uint8); lib.xmx_buf_download(hwant, w.ctypes.data, 0, te)
    same = bool(np.array_equal(g, w))
    tag = "target"
    if pooling and same:
        gp = np.zeros(pixels // 4 * C * 2, np.uint8); lib.xmx_buf_download(hpooled, gp.ctypes.data, 0, pixels // 4 * C * 2)
        wp = np.zeros(pixels // 4 * C * 2, np.uint8); lib.xmx_buf_download(hpw, wp.ctypes.data, 0, pixels // 4 * C * 2)
        if not np.array_equal(gp, wp): same = False; tag = "pooled"
    for h in (him, hw, hp, hb, hco, hs, hgot, hwant, hq, hk, hv, hatt, hpooled, hpw):
        if h >= 0: lib.xmx_buf_destroy(h)

    if same:
        ok(True, f"{label}: COMPOSITION == 3-LEG CHAIN, OUT BITS EQUAL "
                 f"({windows}w {height}x{width} origin({-top},{-left}) flags=0x{flags:x})")
    else:
        ok(False, f"{label}: {tag} differs from the 3-leg chain ({height}x{width} flags=0x{flags:x})")

# captured plain geometries (544x960, 272x480) shrunk for CI; both flag families and image widths.
run(16, 24, 0, 0, 0x1100, "WB-16x24-epi1-narrow")
run(16, 24, 0, 0, 0x0000, "WB-16x24-f32out")
run(20, 36, 4, 4, 0x1100, "WB-20x36-crop-epi1")
run(8, 8, 0, 0, 0x9100, "WB-8x8-halfimage-epi1")
run(40, 56, 0, 0, 0x0000, "WB-40x56-f32out")
# the POOL form (block 0): even extents/pads, target half by definition, +the pooled output.
run(16, 24, 0, 0, 0x800000, "WB-16x24-pool-floatimage")
run(20, 36, 4, 4, 0x808000, "WB-20x36-crop-pool-halfimage")
# the HEAD form (block 70): compact f32 target (pixels x 4), head weights in the pooled
# slot, chain = narrow residual -> out16 + compact GEMM (0x10000).
run(20, 36, 4, 4, 0x1000000, "WB-20x36-crop-head")
run(16, 24, 0, 0, 0x1008000, "WB-16x24-head-halfimage")

print(f"\nWINDOW_BLOCK {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
