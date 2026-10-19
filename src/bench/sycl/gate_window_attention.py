#!/usr/bin/env python3
"""window_attention swap-in gate (route(a) step 3 #9, section 85).

End-to-end against the FOUR-PASS golden test_window_attention.py:52-55 uses (the fused
shipping kernel is proven bit-identical to it):
    scores[b] = Q[b] @ K[b]^T                       (64x64 f32)
    probs[b]  = vendor_approximate_softmax(scores[b] + bias[b % heads])   (e4m3 grid, f16)
    ctx[b]    = probs[b] @ V[b]                     (64x32 f32)
    merged[w,t,c] = e4m3(ctx[w*heads + c/32][t][c%32])   (windows,64,heads*32) half
Q/K/V are (batches,64,32) half (batches = windows*heads, the QKV epilogue's output form);
bias is (heads,64,64) f32.

Criterion: WITHIN-ONE on the final output. The two f16 gemm legs carry the hardware
K-accumulation-order slack (sections 81/82); the softmax and merge legs are bit-exact
(their own gates). So the end-to-end diff is bounded by the gemm legs -- exactly the
section-51 net the whole swap runs on. Inputs are e4m3-grid halves (what the real chain
feeds), so the products are small and within-one is tight.
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
    ("xmx_rec_window_attention", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def run(windows, heads, use_bias, merged, label):
    global fails
    batches = windows * heads
    rng = np.random.default_rng(8580 + windows * 7 + heads * 3 + use_bias * 11 + merged)
    # e4m3-grid halves (what the QKV epilogue actually publishes)
    def e4grid(shape):
        return np.asarray(NM.e4m3(rng.uniform(-2, 2, size=shape).astype(np.float32)), np.float16)
    Q = e4grid((batches, 64, 32)); K = e4grid((batches, 64, 32)); V = e4grid((batches, 64, 32))
    bias = rng.uniform(-3, 3, size=(heads, 64, 64)).astype(np.float32) if use_bias else None

    hq = lib.xmx_buf_create_kind(Q.nbytes, 2); hk = lib.xmx_buf_create_kind(K.nbytes, 2)
    hv = lib.xmx_buf_create_kind(V.nbytes, 2)
    hb = -1
    if use_bias: hb = lib.xmx_buf_create_kind(heads * 64 * 64 * 4, 4)
    out_elems = windows * 64 * heads * 32 if merged else batches * 64 * 32
    wsz = 2 if merged else 4
    ho = lib.xmx_buf_create_kind(out_elems * wsz, wsz)
    ok(min(hq, hk, hv, ho) > 0 and (hb > 0 if use_bias else True), f"{label}: buffers")
    for h, a in ((hq, Q), (hk, K), (hv, V)):
        lib.xmx_buf_upload(h, np.ascontiguousarray(a).ctypes.data, 0, a.nbytes)
    if use_bias: lib.xmx_buf_upload(hb, np.ascontiguousarray(bias).ctypes.data, 0, heads * 64 * 64 * 4)
    lib.xmx_buf_zero(ho)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_window_attention(hq, hk, hv, hb, ho, batches, heads, 1 if merged else 0)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(out_elems * wsz, np.uint8); lib.xmx_buf_download(ho, got.ctypes.data, 0, out_elems * wsz)
    for h in (hq, hk, hv, hb, ho):
        if h >= 0: lib.xmx_buf_destroy(h)

    # golden four-pass
    scores = np.zeros((batches, 64, 64), np.float32)
    for b in range(batches):
        scores[b] = Q[b].astype(np.float32) @ K[b].astype(np.float32).T
    probs = np.zeros((batches, 64, 64), np.float16)
    for b in range(batches):
        s = scores[b] + (bias[b % heads] if use_bias else 0.0)
        probs[b] = np.asarray(NM.vendor_approximate_softmax(s), np.float32).astype(np.float16)
    ctx = np.zeros((batches, 64, 32), np.float32)
    for b in range(batches):
        ctx[b] = probs[b].astype(np.float32) @ V[b].astype(np.float32)
    if merged:
        out = np.zeros((windows, 64, heads * 32), np.float32)
        for w in range(windows):
            for t in range(64):
                for c in range(heads * 32):
                    out[w, t, c] = ctx[w * heads + c // 32, t, c % 32]
        want = np.asarray(NM.e4m3(out.reshape(-1)), np.float16).view(np.uint8)
        gv = got.view(np.uint16); wv = want.view(np.uint16)
        gz = (gv & 0x7FFF) == 0; wz = (wv & 0x7FFF) == 0
        # within-one at the half level: equal bits, both-zero, or adjacent half values
        gf = got.view(np.float16).astype(np.float32); wf = want.view(np.float16).astype(np.float32)
        tol = np.maximum(np.abs(wf) * 2.0 ** -10, 2.0 ** -13)
        within = (np.abs(gf - wf) <= tol) | (gz & wz)
        nbad = int((~within).sum())
        ok(nbad == 0, f"{label}: merged WITHIN-ONE ({windows}w {heads}h bias={use_bias}, {nbad} bad)")
    else:
        gv = got.view(np.float32); wf = ctx.reshape(-1)
        tol = np.maximum(np.abs(wf) * 2.0 ** -10, 2.0 ** -13)
        nbad = int((np.abs(gv - wf) > tol).sum())
        ok(nbad == 0, f"{label}: ctx WITHIN-ONE ({windows}w {heads}h bias={use_bias}, {nbad} bad)")

run(2, 4, True, True, "WA-2w4h-bias-merged")     # the plan's dominant shape (merged=1)
run(2, 4, True, False, "WA-2w4h-bias-ctx")
run(1, 16, True, True, "WA-1w16h-bias-merged")
run(3, 2, False, True, "WA-3w2h-nobias-merged")
run(4, 8, True, True, "WA-4w8h-bias-merged")

print(f"\nWINDOW_ATTENTION {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
