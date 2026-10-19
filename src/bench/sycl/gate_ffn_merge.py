#!/usr/bin/env python3
"""ffn_merge swap-in gate (route(a) step 3 #14, section 88 route).

Block 70's fused feed-forward with its input made in the same pass (ffn_fused.comp flag
0x1000000, libxmx.c:3157). test_glue.py:317-322 is the shipping witness: ffn_merge ==
upsample_merge THEN the plain fused feed-forward. The merge arithmetic (merged4 /
resident.comp UPSAMPLE_MERGE:555-560, identical line-for-line) is pinned in the recorder
comment first (section 73):
    above  = ((y/2)*source_width + x/2)*32 + c   (x=pixel%width, y=pixel/width)
    scaled = f32(src[above]) * sin[c]            precise, rounded on its own (cr_mul)
    merged = fma( f32(skip[i]), cos[c], scaled ) the residual pass's fused add
    raw f32 merged  -> the feed-forward's residual skip (FloatBuf, mask has no 0x40000)
    e4m3(merged) half -> the expand GEMM's input

Criterion = WITHIN-ONE vs the numpy four-pass golden. The merged4 elementwise leg is exact
(no gemm slack: f32 mul + f64-exact fma), so only the two f16v1 GEMMs (expand, projection)
carry the hardware K-order slack -- exactly section 85's end-to-end shape. A gross wiring
bug in merged4 shows as a large diff (far outside within-one), not a 1-ULP flip.

captured ffn_merge: 1 call height=544 width=960 source_width=480 flags=0 (f32-out). Even
extents kept per the guard (libxmx.c:3161); shrunk for CI with source_width wider than half
(the +extra case test_glue runs -- level above may be wider than width/2).
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
    ("xmx_rec_ffn_merge", [ctypes.c_int] * 7 + [ctypes.c_uint] * 4),
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

def run(height, width, source_width, flags, label):
    global fails
    M = height * width
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    wsz = 2 if narrow else 4
    rng = np.random.default_rng(88140 + height * 7 + width * 3 + source_width + flags)
    nsrc = (height // 2) * source_width * 32
    src = rng.uniform(-1, 1, size=nsrc).astype(np.float16)
    sk = rng.uniform(-1, 1, size=M * 32).astype(np.float16)
    sincos = rng.uniform(-2, 2, 64).astype(np.float32)
    E = rng.uniform(-0.25, 0.25, size=32 * 128).astype(np.float16)
    P = rng.uniform(-0.1, 0.1, size=128 * 32).astype(np.float16)
    cosine = (rng.uniform(-1.5, 1.5, 32).astype(np.float32)).astype(np.float32)

    hsrc = lib.xmx_buf_create_kind(nsrc * 2, 2)
    hsk = lib.xmx_buf_create_kind(M * 32 * 2, 2)
    hsc = lib.xmx_buf_create_kind(64 * 4, 4)
    he = lib.xmx_buf_create_kind(32 * 128 * 2, 2)
    hp = lib.xmx_buf_create_kind(128 * 32 * 2, 2)
    ho = lib.xmx_buf_create_kind(M * 32 * wsz, wsz)
    hco = lib.xmx_buf_create_kind(32 * 4, 4)
    ok(min(hsrc, hsk, hsc, he, hp, ho, hco) > 0, f"{label}: buffers")
    up(hsrc, src); up(hsk, sk); up(hsc, sincos); up(he, E); up(hp, P); up(hco, cosine)
    lib.xmx_buf_zero(ho)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_ffn_merge(hsrc, hsk, hsc, he, hp, ho, hco, height, width, source_width, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * 32 * wsz, np.uint8); lib.xmx_buf_download(ho, got.ctypes.data, 0, M * 32 * wsz)
    for h in (hsrc, hsk, hsc, he, hp, ho, hco): lib.xmx_buf_destroy(h)

    # ---- numpy four-pass golden ----
    sin = sincos[0:32].astype(np.float64); cos = sincos[32:64].astype(np.float64)
    srcf = src.view(np.float16).astype(np.float32)
    skf = sk.view(np.float16).astype(np.float32)
    scaled = np.zeros(M * 32, np.float32); merged = np.zeros(M * 32, np.float32)
    e_p64 = np.zeros((M, 32)); s64 = np.zeros((M, 32))
    for i in range(M * 32):
        c = i % 32; pixel = i // 32; x = pixel % width; y = pixel // width
        above = ((y // 2) * source_width + (x // 2)) * 32 + c
        scaled[i] = (srcf[above] * sin[c]).astype(np.float32)[()]
        # fma(skip, cos, scaled): exact in f64
        prod = np.float64(skf[i]) * cos[c]
        merged[i] = (prod + np.float64(scaled[i])).astype(np.float32)
        e_p64[pixel, c] = abs(np.floor(np.log2(abs(prod) + (prod == 0))) - np.floor(np.log2(abs(scaled[i]) + (scaled[i] == 0))))
        s64[pixel, c] = prod
    assert float(e_p64.max()) <= 18.0, f"{label}: merged fma exponent gap {e_p64.max()}"

    m16 = np.asarray(NM.e4m3(merged), np.float16).reshape(M, 32)
    exp = (m16.astype(np.float32) @ E.view(np.float16).astype(np.float32).reshape(32, 128)).astype(np.float32)
    hid = np.asarray(NM.e4m3(NM.quadratic_gate_activation(exp)), np.float16)
    proj = (hid.astype(np.float32) @ P.view(np.float16).astype(np.float32).reshape(128, 32)).astype(np.float32).reshape(M, 32)
    # total = fma(raw merged, cosine[col], proj): exact in f64 (gap assert)
    prod2 = merged.reshape(M, 32).astype(np.float64) * cosine.astype(np.float64)[None, :]
    g2 = np.abs(np.where(prod2 == 0, np.floor(np.log2(np.abs(proj)+1e-30)),
                         np.where(proj == 0, np.floor(np.log2(np.abs(prod2))+1e-30),
                                  np.floor(np.log2(np.abs(prod2))) - np.floor(np.log2(np.abs(proj))))))
    assert float(g2.max()) <= 18.0, f"{label}: total fma exponent gap {g2.max()}"
    total = (prod2 + proj.astype(np.float64)).astype(np.float32).reshape(M * 32)
    if epi == 1: v = NM.e4m3(total)
    elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(total))
    elif epi == 2: v = NM.quadratic_gate_activation(total)
    elif epi == 4: v = NM._half_rounded(total)
    else: v = total
    wantf = np.asarray(v, np.float32 if not narrow else np.float16).astype(np.float32).reshape(M * 32)
    gv = got.view(np.float16).astype(np.float32) if narrow else got.view(np.float32)
    tol = np.maximum(np.abs(wantf) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(gv - wantf) > tol).sum())
    if nbad:
        e = int(np.flatnonzero(np.abs(gv - wantf) > tol)[0]); r, c = divmod(e, 32)
        ok(False, f"{label}: {nbad} bad; first ({r},{c}) got {gv[e]:.6g} want {wantf[e]:.6g}")
    else:
        ok(True, f"{label}: FOUR-PASS WITHIN-ONE ({height}x{width} sw={source_width} flags=0x{flags:x})")

run(16, 24, 12, 0x000, "MERGE-16x24")
run(20, 36, 21, 0x000, "MERGE-20x36-sw>half")      # the +extra level-above-wider case
run(8, 8, 4, 0x000, "MERGE-8x8")
run(16, 24, 12, 0x1100, "MERGE-16x24-narrow-epi1-stress")

print(f"\nFFN_MERGE {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
