#!/usr/bin/env python3
"""Attention scores-ring integration gate (section 43): Q_int8/K_int8 -> scores -> probs.

Every block is already gated on its own (cosine_norm_i8 39, v1 gemm_s8 gate_gemm_s8,
softmax_i8 40). This gate proves the SEAM between them: the K^T layout (scores = Q.K^T,
the senior's matmul_nt reads key column-major for free; my v1 pack_b wants B row-major
(K,N), so the host transposes k_int8 (tokens,32) -> (32,tokens)), the scale axes (q_scale
per query-row, k_scale per key-column), and softmax_i8 eating the v1 int32 accumulator.

Per-head: global attention is (heads, tokens, 32); scores is one (tokens,tokens) GEMM per
head. This path gate loops the heads (the batched form is the megakernel's job, R8a).

Chain golden (section 25: each segment's lossiness isolated, downstream golden uses the
UPSTREAM DEVICE bytes, not a re-derived numpy):
  - acc bit-exact vs numpy q_int8 @ k_int8^T (int32 exact, the v1 GEMM's contract).
  - probs bounded vs the numpy softmax_i8 chain fed the DEVICE's acc + q_scale + k_scale
    + bias (within-one + scale<=1ulp, the v3 requantize contract).
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

def softmax_i8_numpy(acc, qs, ks, bias):
    """the numpy softmax_i8 chain (dequantise -> gated affine/bit-pair/sum/recip -> requantize)."""
    f32 = np.float32
    deq = (acc.astype(f32) * qs.astype(f32)[:, None]).astype(f32) * ks.astype(f32)[None, :]
    deq = (deq + bias.astype(f32)).astype(f32)
    x = golden_x(deq)
    rmax = np.max(np.abs(x), axis=1)
    wns = (rmax / f32(127.0)).astype(f32)
    q = np.divide(x, wns[:, None], out=np.zeros_like(x, dtype=np.float64), where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    return x, want, wns

def golden_x(deq):
    affine = NM._half_rounded(deq)
    affine = np.float32(0.044921875) * affine
    affine = affine + np.float32(1.30078125)
    np.clip(affine, np.float32(1.03125), np.float32(1.5693359375), out=affine)
    affine = affine.astype(np.float16)
    bits = affine.view(np.uint16).astype(np.uint32)
    pairs = bits.reshape(*bits.shape[:-1], bits.shape[-1] // 2, 2)
    packed = pairs[..., 0] | (pairs[..., 1] << np.uint32(16))
    transformed = (packed << np.uint32(5)) + np.uint32(0x7FF88000)
    wb = np.stack((transformed & np.uint32(0xFFFF), (transformed >> np.uint32(16)) & np.uint32(0xFFFF)),
                  axis=-1).reshape(bits.shape)
    weights = wb.astype(np.uint16).view(np.float16)
    totals = weights.sum(axis=-1, keepdims=True, dtype=np.float16)
    reciprocal = (np.float32(1.0) / totals.astype(np.float32)).astype(np.float16)
    return NM._half_rounded(weights.astype(np.float32) * reciprocal.astype(np.float32))

def run(tokens, heads, with_bias, label):
    global fails
    assert tokens % 128 == 0
    rng = np.random.default_rng(1717 + tokens + heads)
    q8 = rng.integers(-40, 41, size=(heads, tokens, 32)).astype(np.int8)
    k8 = rng.integers(-40, 41, size=(heads, tokens, 32)).astype(np.int8)
    qs = np.full((heads, tokens), STEP, np.float32)
    ks = np.full((heads, tokens), STEP, np.float32)
    bias = rng.uniform(-0.5, 0.5, (heads, tokens, tokens)).astype(np.float32) if with_bias \
           else np.zeros((heads, tokens, tokens), np.float32)

    # ONE submit: per-head scores GEMM (v1, K^T via host transpose) then softmax_i8.
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    accs, probs, pscales = [], [], []
    for h in range(heads):
        hq = lib.xmx_buf_create(tokens * 32)
        hk = lib.xmx_buf_create(32 * tokens)          # B is (K=32, N=tokens) row-major = k^T
        hacc = lib.xmx_buf_create_kind(tokens * tokens * 4, 4)
        hqs = lib.xmx_buf_create_kind(tokens * 4, 4)
        hks = lib.xmx_buf_create_kind(tokens * 4, 4)
        hb = lib.xmx_buf_create_kind(tokens * tokens * 4, 4)
        hp = lib.xmx_buf_create_kind(tokens * tokens, 1)
        hps = lib.xmx_buf_create_kind(tokens * 4, 4)
        lib.xmx_buf_upload(hq, q8[h].ctypes.data, 0, tokens * 32)
        kT = np.ascontiguousarray(k8[h].T)            # (32, tokens) -- the K^T layout seam
        lib.xmx_buf_upload(hk, kT.ctypes.data, 0, 32 * tokens)
        lib.xmx_buf_upload(hqs, qs[h].ctypes.data, 0, tokens * 4)
        lib.xmx_buf_upload(hks, ks[h].ctypes.data, 0, tokens * 4)
        lib.xmx_buf_upload(hb, bias[h].ctypes.data, 0, tokens * tokens * 4)
        lib.xmx_buf_zero(hacc); lib.xmx_buf_zero(hp); lib.xmx_buf_zero(hps)
        rc = lib.xmx_rec_gemm_s8(hq, hk, hacc, tokens, tokens, 32)
        ok(rc == 0, f"{label} h{h}: rec_gemm_s8 (K^T)" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
        rc = lib.xmx_rec_softmax_i8(hacc, hqs, hks, hb, hp, hps, tokens, tokens)
        ok(rc == 0, f"{label} h{h}: rec_softmax_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
        accs.append((h, hacc)); probs.append((h, hp, hps))
    ok(lib.xmx_submit() == 0, f"{label}: submit (whole scores ring, {heads} heads x 2 passes)")

    for h, hacc in accs:
        acc = np.zeros(tokens * tokens, np.int32); lib.xmx_buf_download(hacc, acc.ctypes.data, 0, tokens * tokens * 4)
        acc = acc.reshape(tokens, tokens)
        want_acc = q8[h].astype(np.int32) @ k8[h].astype(np.int32).T   # exact int32
        ok(np.array_equal(acc, want_acc), f"{label} h{h}: scores acc BIT-EXACT vs q@k^T ({int((acc!=want_acc).sum())} differ)")
    for h, hp, hps in probs:
        acc = np.zeros(tokens * tokens, np.int32); lib.xmx_buf_download(accs[h][1], acc.ctypes.data, 0, tokens * tokens * 4)
        acc = acc.reshape(tokens, tokens)
        got = np.zeros(tokens * tokens, np.int8); lib.xmx_buf_download(hp, got.ctypes.data, 0, tokens * tokens)
        gns = np.zeros(tokens, np.float32); lib.xmx_buf_download(hps, gns.ctypes.data, 0, tokens * 4)
        x, want, wns = softmax_i8_numpy(acc, qs[h], ks[h], bias[h])
        gp = got.reshape(tokens, tokens)
        step = gp.astype(np.float64) * gns.astype(np.float64)[:, None]
        limit = 0.5 + np.float64(2.0 ** -16)
        within = np.abs(step - x.astype(np.float64)) <= np.maximum(gns.astype(np.float64), 1e-30)[:, None] * limit
        sculp = int(np.abs(gns.view(np.int32) - wns.view(np.int32)).max())
        ok(bool(within.all()) and sculp <= 1,
           f"{label} h{h}: probs within-one {bool(within.all())}, scale<=1ulp (max {sculp})")
    # cleanup all handles
    for h, hacc in accs: lib.xmx_buf_destroy(hacc)
    for h, hp, hps in probs: lib.xmx_buf_destroy(hp); lib.xmx_buf_destroy(hps)

run(640, 4, 1, "global-640x4")     # the 1920x1088 frame's global block
run(256, 8, 0, "global-256x8")     # 720p global block, no bias
run(128, 2, 1, "small")

print(f"\nCHAIN_SCORES {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
