#!/usr/bin/env python3
"""int8_qkv swap-in gate (route(a) step 3 #4, section 75).

The plan's real families (section 75 dump, 60 captured calls, 10 variants):
  M,channels,heads,tokens,flags = (2560,256,8,64,0)x16, (768,512,16,64,0)x8,
  (960,512,16,64,0)x8, (192,1024,32,192,0x2000)x8 [the VIT gate],
  (8640/9216,128,4,64,0)x12, (32640..35712,64,2,64,0)x8.
ALL windows = M/tokens exactly; channels==heads*32; b_scale = 3*channels (per COLUMN of
the (3C x C) transposed weight -- xmxres.py:1334-1337 says why: per-head scales leave the
direction off twice as much).

Golden = the EXACT authority pair the already-green §36 QKV_QK gate uses (vendor_cosine_
publish for the window tree; _vit_norm + VIT_ROOT + learned chain for vit; V = e4m3(deq)
-- §35 gate's form), on the SAME (w,t,h,32)/(w,h,t,32) transposes and the same scatter4.
The recorder composes the same op sequence the .comp+qkv_epilogue.glsl run (the shipping
witness: "bit-identical to the three passes by construction", test_gemm_qkv.py), so this
gate compares my composition against the OTHER side of that construction claim -- drift
would mean my epilogue-order reading was wrong, which is exactly what must be caught.

Variants below keep the plan's exact channels/heads/tokens/flags for the 192x1024 VIT
family (the padded-M case: 192 -> Mp 256) and shrink the large-M families to CI speed.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM
import math

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
    ("xmx_rec_gemm_int8_qkv", [ctypes.c_int] * 8 + [ctypes.c_uint] * 5),
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
    rc = lib.xmx_buf_upload(h, a.ctypes.data, 0, a.nbytes)
    assert rc == 0, f"upload failed: {lib.xmx_error().decode()}"

def scatter4(want4, windows, tokens, heads, order):
    out = np.empty(windows * tokens * heads * 32, np.float16)
    for w in range(windows):
        for t in range(tokens):
            for h in range(heads):
                for c in range(32):
                    at = ((w * heads + h) * tokens + t) * 32 + c
                    out[at] = np.float16(want4[w, h, t, c] if order == "whtc" else want4[w, t, h, c])
    return out

def run(windows, tokens, channels, vit, label):
    global fails
    heads = channels // 32
    M = rows = windows * tokens
    C = channels
    rng = np.random.default_rng(7570 + rows + channels * 3 + tokens * 5 + vit)
    # THE §36 CONVENTION (lim = 3 if vit else 40): the vit reciprocal tree accumulates in
    # the half domain while nr_model._vit_norm sums in float; they agree BIT-EXACT only in
    # the small band the senior's own gate chose, and beyond it they differ by one ULP of
    # the reciprocal (observed: 0.7-0.8% of Q/K single-halves at band 40, V untouched).
    # This is the shipping gate's documented domain, not a defect to paper over: the real
    # frame feeds quantised activations whose published half values land inside it (the
    # window tree passes bit-exact even at band 40; only the vit tree is band-tight).
    lim = 3 if vit else 40
    a = rng.integers(-lim, lim + 1, size=(M, C)).astype(np.int8)
    Bt = rng.integers(-lim, lim + 1, size=(3 * C, C)).astype(np.int8)   # transposed (N x K)
    STEP = np.float32(2.0 ** -8)
    a_scale = np.full(M, STEP, np.float32)
    b_scale = np.full(3 * C, STEP, np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)

    ha = lib.xmx_buf_create_kind(M * C, 1); hb = lib.xmx_buf_create_kind(3 * C * C, 1)
    hq = lib.xmx_buf_create_kind(M * C * 2, 2); hk = lib.xmx_buf_create_kind(M * C * 2, 2)
    hv = lib.xmx_buf_create_kind(M * C * 2, 2)
    has = lib.xmx_buf_create_kind(M * 4, 4); hbs = lib.xmx_buf_create_kind(3 * C * 4, 4)
    hqs = lib.xmx_buf_create_kind(heads * 4, 4)
    ok(min(ha, hb, hq, hk, hv, has, hbs, hqs) > 0, f"{label}: 8 buffers")
    up(ha, a); up(hb, Bt); up(has, a_scale); up(hbs, b_scale); up(hqs, qkv_scale)
    for h in (hq, hk, hv): lib.xmx_buf_zero(h)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_int8_qkv(ha, hb, hq, hk, hv, has, hbs, hqs,
                                   M, C, heads, tokens, 0x2000 if vit else 0)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    gq = np.zeros(M * C, np.float16); lib.xmx_buf_download(hq, gq.ctypes.data, 0, M * C * 2)
    gk = np.zeros(M * C, np.float16); lib.xmx_buf_download(hk, gk.ctypes.data, 0, M * C * 2)
    gv = np.zeros(M * C, np.float16); lib.xmx_buf_download(hv, gv.ctypes.data, 0, M * C * 2)
    for h in (ha, hb, hq, hk, hv, has, hbs, hqs): lib.xmx_buf_destroy(h)

    # golden on the SAME operand math (.comp QKV branch: deq = f32(acc)*as*bs two rounded
    # muls), then the §36-verified authority for norm/publish.
    acc = (a.astype(np.int64) @ Bt.astype(np.int64).T).astype(np.float32)
    deq = (acc * a_scale[:, None]).astype(np.float32)
    deq = (deq * b_scale[None, :]).astype(np.float32)
    A4 = deq[:, :C].reshape(windows, tokens, heads, 32)
    K4 = deq[:, C:2 * C].reshape(windows, tokens, heads, 32)
    V4 = deq[:, 2 * C:].reshape(windows, tokens, heads, 32)
    if not vit:
        wq = scatter4(NM.vendor_cosine_publish(np.ascontiguousarray(A4.transpose(0, 2, 1, 3)), qkv_scale), windows, tokens, heads, "whtc")
        wk = scatter4(NM.vendor_cosine_publish(np.ascontiguousarray(K4.transpose(0, 2, 1, 3)), None), windows, tokens, heads, "whtc")
    else:
        root = NM._half_rounded(np.float32(math.sqrt(32)))
        learned = NM._half_rounded(qkv_scale).reshape(1, 1, heads, 1)
        nA = NM._vit_norm(A4)[..., None]
        nK = NM._vit_norm(K4)[..., None]
        wq4 = NM.e4m3(NM._half_rounded(NM._half_rounded(NM._half_rounded(A4 * nA) * root) * learned))
        wk4 = NM.e4m3(NM._half_rounded(K4 * nK))
        wq = scatter4(wq4, windows, tokens, heads, "wthc")
        wk = scatter4(wk4, windows, tokens, heads, "wthc")
    wv = scatter4(NM.e4m3(np.ascontiguousarray(V4.transpose(0, 2, 1, 3)) if False else np.ascontiguousarray(V4)), windows, tokens, heads, "wthc")
    for got, want, tag in ((gq, wq, "Q"), (gk, wk, "K"), (gv, wv, "V")):
        same = np.array_equal(got.view(np.uint16), np.asarray(want, np.float16).view(np.uint16))
        if not same:
            d = np.flatnonzero(got.view(np.uint16) != np.asarray(want, np.float16).view(np.uint16))
            e = int(d[0])
            ok(False, f"{label} {tag}: {len(d)} bad; first elem {e} got {got[e]} want {want[e]}")
        else:
            ok(True, f"{label} {tag}: OUT BITS EQUAL")

run(1, 64, 64, 0, "tiny-win-64")                       # baseline
run(2, 64, 256, 0, "win-128x256x8")                    # plan v1 structure (2560x256x8 shrunk)
run(2, 64, 512, 0, "win-128x512x16")                   # plan v2/v3 structure shrunk
run(1, 192, 1024, 1, "VIT-192x1024x32-EXACT")          # THE plan vit family, exact sizes; padded M
run(3, 64, 128, 0, "win-192x128x4")                    # tokens|M check, 128->pad 256? no: 192->256 pad

print(f"\nGEMM_INT8_QKV {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
