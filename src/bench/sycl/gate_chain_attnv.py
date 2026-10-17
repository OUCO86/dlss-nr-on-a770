#!/usr/bin/env python3
"""Attention ring-tail integration gate (section 53 item 1): the WHOLE attention loop in
int8, one submit, golden on the DEVICE's own upstream bytes (section 25 discipline).

Per head of a global block (M=K=640 = the 1920x1088 frame's token count; window blocks'
M=64 still wait for the megakernel's batching, so this uses the shapes v7 accepts TODAY):
  int8 Q,K,V (head rows x 32) + their scales  ->
  v1 gemm_s8(Q, K^T) -> int32 scores acc            (gated in gate_gemm_s8)
  softmax_i8(acc, q_scale, k_scale, bias) -> int8 probs + row scale ps   (gated in 40)
  v7 gemm_s8rq32(probs, V, ps, Vcol_scale) -> int8 attended + attended_scale  (gated in 53)

The golden attended is recomputed in numpy from the DOWNLOADED device int8 (probs, ps, V,
Vcol) -- never a re-derived constant -- then requantized with the v3 divide-form and compared
within-one (attended is lossy at that last requantize only; everything upstream is integer-
exact or the already-gated softmax chain). Bounded criteria: within-one + scale<=1ulp.

This closes route B's attention loop end-to-end: QKV -> scores -> softmax -> attnV -> (the
attended int8 + scale is exactly outproj's b_scale input, so outproj chains with no seam).
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM

for d in (os.getcwd(), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k32 = ctypes.windll.kernel32
_k32.SetErrorMode(0x8002)
for _dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    _p = pathlib.Path.cwd() / _dep
    if _p.exists():
        _k32.LoadLibraryExW(str(_p), 0, 0)

DLL = pathlib.Path.cwd() / "libxmx_sycl.dll"
if not DLL.exists():
    DLL = pathlib.Path(__file__).resolve().parent / "libxmx_sycl.dll"
lib = ctypes.CDLL(str(DLL))
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create", [ctypes.c_ulonglong]),
    ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_rec_gemm_s8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 3),
    ("xmx_rec_softmax_i8", [ctypes.c_int] * 6 + [ctypes.c_uint] * 2),
    ("xmx_rec_gemm_s8rq32", [ctypes.c_int] * 6 + [ctypes.c_uint] * 3),
):
    if hasattr(lib, nm):
        getattr(lib, nm).argtypes = at
        getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "xmx_init")
STEP = np.float32(2.0 ** -8)

def run(tokens, heads, label):
    global fails
    assert tokens % 128 == 0
    rng = np.random.default_rng(4141 + tokens + heads)
    q8 = rng.integers(-40, 41, size=(heads, tokens, 32)).astype(np.int8)
    k8 = rng.integers(-40, 41, size=(heads, tokens, 32)).astype(np.int8)
    v8 = rng.integers(-40, 41, size=(heads, tokens, 32)).astype(np.int8)   # per-head int8 V
    qs = np.full((heads, tokens), STEP, np.float32)
    ks = np.full((heads, tokens), STEP, np.float32)
    # V column scale per head (length 32 = N axis), realistic (not constant).
    vcol = (0.004 * (np.arange(32) % 21 + 1)).astype(np.float32)
    bias = np.zeros((heads, tokens, tokens), np.float32)

    ok(lib.xmx_begin() == 0, f"{label}: begin")
    handles = []
    for h in range(heads):
        hq = lib.xmx_buf_create(tokens * 32)
        hkt = lib.xmx_buf_create(32 * tokens)
        hacc = lib.xmx_buf_create_kind(tokens * tokens * 4, 4)
        hqs = lib.xmx_buf_create_kind(tokens * 4, 4)
        hks = lib.xmx_buf_create_kind(tokens * 4, 4)
        hb = lib.xmx_buf_create_kind(tokens * tokens * 4, 4)
        hp = lib.xmx_buf_create_kind(tokens * tokens, 1)
        hps = lib.xmx_buf_create_kind(tokens * 4, 4)
        hv = lib.xmx_buf_create(tokens * 32)
        hvc = lib.xmx_buf_create_kind(32 * 4, 4)
        hatt = lib.xmx_buf_create_kind(tokens * 32, 1)
        hats = lib.xmx_buf_create_kind(tokens * 4, 4)
        handles.append((h, hq, hkt, hacc, hqs, hks, hb, hp, hps, hv, hvc, hatt, hats))
        kT = np.ascontiguousarray(k8[h].T)               # (32, tokens) = K^T layout seam
        lib.xmx_buf_upload(hq, q8[h].ctypes.data, 0, tokens * 32)
        lib.xmx_buf_upload(hkt, kT.ctypes.data, 0, 32 * tokens)
        lib.xmx_buf_upload(hqs, qs[h].ctypes.data, 0, tokens * 4)
        lib.xmx_buf_upload(hks, ks[h].ctypes.data, 0, tokens * 4)
        lib.xmx_buf_upload(hb, bias[h].ctypes.data, 0, tokens * tokens * 4)
        lib.xmx_buf_upload(hv, v8[h].ctypes.data, 0, tokens * 32)
        lib.xmx_buf_upload(hvc, vcol.ctypes.data, 0, 32 * 4)
        for x in (hacc, hp, hps, hatt, hats): lib.xmx_buf_zero(x)
        rc = lib.xmx_rec_gemm_s8(hq, hkt, hacc, tokens, tokens, 32)
        ok(rc == 0, f"{label} h{h}: scores gemm_s8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
        rc = lib.xmx_rec_softmax_i8(hacc, hqs, hks, hb, hp, hps, tokens, tokens)
        ok(rc == 0, f"{label} h{h}: softmax_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
        rc = lib.xmx_rec_gemm_s8rq32(hp, hv, hatt, hps, hvc, hats, tokens, 32, tokens)
        ok(rc == 0, f"{label} h{h}: attnV rq32" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit (whole attention loop, {heads} heads x 3 passes)")

    f32 = np.float32
    for (h, hq, hkt, hacc, hqs, hks, hb, hp, hps, hv, hvc, hatt, hats) in handles:
        # DOWNLOAD the device's own probs/ps/V/Vcol (never re-derive) and rebuild the true
        # attended fp from them, then requantize (divide-form) and compare within-one.
        P = np.zeros(tokens * tokens, np.int8); lib.xmx_buf_download(hp, P.ctypes.data, 0, tokens * tokens)
        ps = np.zeros(tokens, np.float32); lib.xmx_buf_download(hps, ps.ctypes.data, 0, tokens * 4)
        V = np.zeros(tokens * 32, np.int8); lib.xmx_buf_download(hv, V.ctypes.data, 0, tokens * 32)
        vc = np.zeros(32, np.float32); lib.xmx_buf_download(hvc, vc.ctypes.data, 0, 32 * 4)
        got = np.zeros(tokens * 32, np.int8); lib.xmx_buf_download(hatt, got.ctypes.data, 0, tokens * 32)
        gats = np.zeros(tokens, np.float32); lib.xmx_buf_download(hats, gats.ctypes.data, 0, tokens * 4)
        Pf = P.reshape(tokens, tokens).astype(np.float64)
        Vf = V.reshape(tokens, 32).astype(np.float64)
        raw = Pf @ Vf                                        # int32-exact sum, in f64
        fp = (raw * ps.astype(np.float64)[:, None]) * vc.astype(np.float64)[None, :]
        rmax = np.max(np.abs(fp), axis=1)
        wns = (rmax / np.float64(127.0)).astype(np.float32)
        q = np.divide(fp, wns[:, None].astype(np.float64), out=np.zeros_like(fp), where=wns[:, None] > 0)
        want = np.clip(np.rint(q), -127, 127).astype(np.int8)
        gp = got.reshape(tokens, 32)
        step = gp.astype(np.float64) * gats.astype(np.float64)[:, None]
        tol = 0.5 + 2.0 ** -16
        within = np.abs(step - fp) <= np.maximum(gats.astype(np.float64), 1e-30)[:, None] * tol
        sculp = int(np.abs(gats.view(np.int32) - wns.view(np.int32)).max())
        ok(bool(within.all()) and sculp <= 1,
           f"{label} h{h} attended: within-one {bool(within.all())}, scale<=1ulp (max {sculp})")
    for (h, *hs) in handles:
        for x in hs: lib.xmx_buf_destroy(x)

run(640, 4, "global-640x4")
run(256, 2, "global-256x2")

print(f"\nCHAIN_ATTNV {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
