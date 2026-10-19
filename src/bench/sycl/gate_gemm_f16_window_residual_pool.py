#!/usr/bin/env python3
"""f16 gemm_window_residual_pool FOUNDATION gate (section 88 route; window_block POOL leg).

Isolated numpy golden (section 55: gate each foundation on its own, not only via the
composition). Math pinned from gemm_staged.comp:346-390 + libxmx.c:2393 BEFORE writing:
    acc = attended @ P (f32)
    for block i=(r,col), r=window*64+token: map y=(window/across)*8+token/8, x=...;
      if in-range: out=(y-top)*width*C+(x-left)*C+col;
        total = fma( image[out], cosine[col], acc[i] )   (skip = the image, half iff 0x40000)
        skip_out[out] = e4m3(total) as half;  dStage[i] = total (raw)
    pooled: per window, 16 pooled pixels p, token=(p/4)*16+(p%4)*2, taps in order
      (token, token+8, token+1, token+9): total4 = ((dStage[t]+dStage[t+8])+dStage[t+1])+dStage[t+9];
      pooled[half-res index] = e4m3(0.25*total4) as half.
Criterion: skip_out and pooled both OUT BITS EQUAL (the f16v1 GEMM leg's K-order slack is
the same on both sides of the inline==chain check, but here the golden is numpy f32 dot --
so WITHIN-ONE on the raw total would be the strict reading; however skip_out/pooled are
e4m3-quantised, and the senior's own pool test (test_glue gemm_residual_pool) is BIT-EXACT
against the two-pass path, so we compare the recorder to the numpy two-pass with WITHIN-ONE
tolerance on the e4m3 grid: equal bits OR adjacent e4m3 codes).
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
    ("xmx_rec_gemm_window_residual_pool", [ctypes.c_int] * 6 + [ctypes.c_uint] * 8),
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

def e4m3_adjacent(a_bits, b_bits):
    # equal, or both zero-magnitude, or adjacent e4m3 codes (within-one on the grid)
    if a_bits == b_bits: return True
    if (a_bits & 0x7FFF) == 0 and (b_bits & 0x7FFF) == 0: return True
    return abs(int(a_bits) - int(b_bits)) <= 1

def run(height, width, top, left, half_skip, label):
    global fails
    C = 32
    ph, pw = window_extent(height, width, top, left)
    across = pw // 8
    windows = (ph // 8) * (pw // 8)
    rows = windows * 64
    pad = (top << 16) | left
    pixels = height * width
    rng = np.random.default_rng(88170 + height * 7 + width * 3 + top * 11 + left * 13 + half_skip)
    att = rng.uniform(-1, 1, size=rows * C).astype(np.float16)
    P = rng.uniform(-0.25, 0.25, size=C * C).astype(np.float16)
    img = (rng.uniform(-1, 1, size=pixels * C).astype(np.float16) if half_skip
           else rng.uniform(-1, 1, size=pixels * C).astype(np.float32))
    cosine = rng.uniform(-1.5, 1.5, size=C).astype(np.float32)
    flags = 0x40000 if half_skip else 0

    hatt = lib.xmx_buf_create_kind(rows * C * 2, 2)
    hp = lib.xmx_buf_create_kind(C * C * 2, 2)
    him = lib.xmx_buf_create_kind(pixels * C * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(C * 4, 4)
    hso = lib.xmx_buf_create_kind(pixels * C * 2, 2)
    hpl = lib.xmx_buf_create_kind(pixels // 4 * C * 2, 2)
    ok(min(hatt, hp, him, hco, hso, hpl) > 0, f"{label}: buffers")
    up(hatt, att); up(hp, P); up(him, img); up(hco, cosine)
    lib.xmx_buf_zero(hso); lib.xmx_buf_zero(hpl)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_window_residual_pool(hatt, hp, hso, him, hco, hpl, rows, C, C,
                                               flags, height, width, across, pad)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    gso = np.zeros(pixels * C * 2, np.uint8); lib.xmx_buf_download(hso, gso.ctypes.data, 0, pixels * C * 2)
    gpl = np.zeros(pixels // 4 * C * 2, np.uint8); lib.xmx_buf_download(hpl, gpl.ctypes.data, 0, pixels // 4 * C * 2)
    for h in (hatt, hp, him, hco, hso, hpl): lib.xmx_buf_destroy(h)

    # numpy golden
    acc = (att.view(np.float16).astype(np.float32).reshape(rows, C)
           @ P.view(np.float16).astype(np.float32).reshape(C, C)).astype(np.float32)
    imgf = img.view(np.float16).astype(np.float32) if half_skip else img.astype(np.float32)
    dStage = np.zeros(rows * C, np.float32)
    wso = np.zeros(pixels * C, np.float16)
    for r in range(rows):
        w = r // 64; t = r % 64
        y = (w // across) * 8 + t // 8; x = (w % across) * 8 + t % 8
        if y < top or x < left or y - top >= height or x - left >= width: continue
        for c in range(C):
            out = (y - top) * width * C + (x - left) * C + c
            total = (np.float64(imgf[out]) * np.float64(cosine[c]) + np.float64(acc[r, c])).astype(np.float32)
            dStage[r * C + c] = total
            wso[out] = np.float16(NM.e4m3(total))
    wpl = np.zeros(pixels // 4 * C, np.float16)
    for w in range(windows):
        for p in range(16):
            t = (p // 4) * 16 + (p % 4) * 2
            y = (w // across) * 8 + t // 8; x = (w % across) * 8 + t % 8
            if y < top or x < left or y - top >= height or x - left >= width: continue
            base = w * 64 * C
            for c in range(C):
                tot = ((dStage[base + t * C + c] + dStage[base + (t + 8) * C + c])
                       + dStage[base + (t + 1) * C + c]) + dStage[base + (t + 9) * C + c]
                out = ((y - top) // 2) * (width // 2) * C + ((x - left) // 2) * C + c
                wpl[out] = np.float16(NM.e4m3(np.float32(tot) * np.float32(0.25)))
    for got, want, tag in ((gso, wso, "skip_out"), (gpl, wpl, "pooled")):
        gh = got.view(np.uint16); wh = want.view(np.uint16)
        bad = [i for i in range(len(gh)) if not e4m3_adjacent(gh[i], wh[i])]
        if not bad:
            ok(True, f"{label} {tag}: OUT BITS EQUAL / within-one ({windows}w {height}x{width} origin({-top},{-left}) {'half' if half_skip else 'float'} skip)")
        else:
            e = bad[0]
            ok(False, f"{label} {tag}: {len(bad)} bad; first {e} got 0x{gh[e]:04x} want 0x{wh[e]:04x}")

run(16, 24, 0, 0, False, "POOL-16x24-floatskip")
run(16, 24, 0, 0, True, "POOL-16x24-halfskip")
run(20, 36, 4, 4, True, "POOL-20x36-crop-halfskip")
run(8, 8, 0, 0, True, "POOL-8x8-halfskip")

print(f"\nGEMM_F16_WINDOW_RESIDUAL_POOL {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
