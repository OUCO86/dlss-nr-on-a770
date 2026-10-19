#!/usr/bin/env python3
"""global_attention swap-in gate (route(a) step 3 #10, section 86).

End-to-end against the FOUR-PASS golden test_global_attention.py:62-68 uses (the fused
shipping kernel is proven bit-identical to it, up to the GEMMs' own rounding):
    scores[h] = Q[h] @ K[h]^T                              (rows x rows f32)
    probs[h], recip[h] = vit_softmax(scores[h], tokens, stride=rows)   (unnormalised e4m3
        weights + the vendor's half-add-tree reciprocal)
    ctx[h] = probs[h] @ V[h]                               (rows x 32 f32)
    merged[token, c] = e4m3(half_round(half_round(ctx[c//32][token][c%32]) * recip[c//32][token]))
Q/K/V are (heads,rows,32) half (the QKV epilogue's output); merged is (rows,heads*32) half.

Criterion: WITHIN-ONE on the final output (the two f16 gemm legs carry the hardware
K-accumulation-order slack; vit_softmax and merge are bit-exact from their own gates).
Inputs are e4m3-grid halves (what the real chain feeds).
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
    ("xmx_rec_global_attention", [ctypes.c_int] * 4 + [ctypes.c_uint] * 3),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def hr(x): return np.float32(np.float16(np.float32(x)))
def hadd(l, r): return hr(np.float32(l) + np.float32(r))
def hmul(l, r): return hr(np.float32(l) * np.float32(r))
def vit_weight(logit):
    affine = hr(hr(np.float32(logit)) * np.float32(0.08953857421875) + np.float32(1.708984375))
    affine = np.clip(affine, np.float32(1.439453125), np.float32(1.9775390625))
    bits = np.asarray(affine, np.float16).reshape(1).view(np.uint16)[0]
    shifted = np.uint16(((np.uint32(bits) << 4) + np.uint32(0x4000)) & np.uint32(0xFFFF))
    return float(np.asarray(shifted, np.uint16).reshape(1).view(np.float16)[0])

def vit_softmax_row(row, tokens, stride):
    blocks = (tokens + 63) // 64
    zero = vit_weight(0.0)
    total = np.float32(0.0)
    for b in range(blocks):
        column = [np.float32(0.0)] * 8
        for c in range(8):
            pair = []
            for j in range(4):
                k0 = b * 64 + c + 16 * j; k1 = k0 + 8
                w0 = vit_weight(row[k0]) if k0 < tokens else zero
                w1 = vit_weight(row[k1]) if k1 < tokens else zero
                pair.append(hadd(w0, w1))
            column[c] = hadd(hadd(hadd(pair[0], pair[1]), pair[2]), pair[3])
        even = hadd(hadd(hadd(column[0], column[2]), column[4]), column[6])
        odd = hadd(hadd(hadd(column[1], column[3]), column[5]), column[7])
        total = hadd(total, hadd(even, odd))
    padding = blocks * 64 - tokens
    if padding > 0: total = hadd(total, -hmul(zero, np.float32(padding)))
    recip = hr(np.float32(1.0) / total)
    probs = np.zeros(stride, np.float16)
    for k in range(stride):
        probs[k] = np.float16(NM.e4m3(np.float32(vit_weight(row[k])))) if k < tokens else np.float16(0.0)
    return probs, recip

def run(rows, tokens, heads, label):
    global fails
    rng = np.random.default_rng(8680 + rows * 3 + tokens * 5 + heads * 7)
    def e4grid(shape):
        return np.asarray(NM.e4m3(rng.normal(0, 0.5, size=shape).astype(np.float32)), np.float16)
    Q = e4grid((heads, rows, 32)); K = e4grid((heads, rows, 32)); V = e4grid((heads, rows, 32))
    CH = heads * 32
    hq = lib.xmx_buf_create_kind(Q.nbytes, 2); hk = lib.xmx_buf_create_kind(K.nbytes, 2)
    hv = lib.xmx_buf_create_kind(V.nbytes, 2); hm = lib.xmx_buf_create_kind(rows * CH * 2, 2)
    ok(min(hq, hk, hv, hm) > 0, f"{label}: buffers")
    for h, a in ((hq, Q), (hk, K), (hv, V)):
        lib.xmx_buf_upload(h, np.ascontiguousarray(a).ctypes.data, 0, a.nbytes)
    lib.xmx_buf_zero(hm)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_global_attention(hq, hk, hv, hm, rows, tokens, heads)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * CH, np.float16); lib.xmx_buf_download(hm, got.ctypes.data, 0, rows * CH * 2)
    for h in (hq, hk, hv, hm): lib.xmx_buf_destroy(h)

    # golden four-pass
    ctx = np.zeros((heads, rows, 32), np.float32)
    recip = np.zeros((heads, rows), np.float32)
    for h in range(heads):
        scores = Q[h].astype(np.float32) @ K[h].astype(np.float32).T
        probs = np.zeros((rows, rows), np.float16)
        for r in range(rows):
            probs[r], recip[h, r] = vit_softmax_row(scores[r], tokens, rows)
        ctx[h] = probs.astype(np.float32) @ V[h].astype(np.float32)
    merged = np.zeros((rows, CH), np.float32)
    for t in range(rows):
        for c in range(CH):
            h = c // 32
            merged[t, c] = NM.e4m3(hr(hr(ctx[h, t, c % 32]) * recip[h, t]))
    want = np.asarray(merged.reshape(-1), np.float16)
    gf = got.astype(np.float32); wf = want.astype(np.float32)
    tol = np.maximum(np.abs(wf) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(gf - wf) > tol).sum())
    if nbad == 0:
        ok(True, f"{label}: WITHIN-ONE ({rows}x{tokens}x{heads})")
    else:
        e = int(np.flatnonzero(np.abs(gf - wf) > tol)[0])
        ok(False, f"{label}: {nbad} outside-one; first elem {e} got {gf[e]} want {wf[e]}")

run(64, 64, 32, "GA-64x64x32")          # the graph's own shape (320x320 net)
run(256, 240, 32, "GA-256x240x32")      # partial last block + padding correction
run(32, 16, 32, "GA-32x16x32")          # tokens < rows
run(96, 90, 8, "GA-96x90x8")            # odd tokens
run(640, 640, 4, "GA-640x640x4")        # the 1280x768 bottleneck

print(f"\nGLOBAL_ATTENTION {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
