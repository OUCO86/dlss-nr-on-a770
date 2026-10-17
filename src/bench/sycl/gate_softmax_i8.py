#!/usr/bin/env python3
"""Route-B block 2 gate (section 38/40): the scores seam softmax, int8 all the way out.

Chain under test: int32 QK^T accumulator + per-row q_scale + per-column k_scale + f32 bias
  -> dequantise (island-3, cr_mul left-to-right) + bias add (senior f32 tile add,
     window_attention.comp:94-103)
  -> the gated softmax affine/bit-pair/sequential-sum/reciprocal chain (== vendor chain,
     proven bit-exact in gate_softmax, section 37)
  -> x = half_round(weight*reciprocal) (the golden's PRE-e4m3 value; the e4m3 container is
     what route B deletes)
  -> register row-max -> v3 requantize (inv=127/rmax, rint, clip +-127, scale=rmax/127)
  -> int8 probabilities + row scale (feed the attnV rq GEMM directly).

Grid trick (test_gemm_int8_qkv.py:30): q8,k8 small integers, scales 2^-8 -> deq = acc*2^-16
EXACT in f32, so the whole softmax chain is exact and only the final requantize is lossy ->
BOUNDED gate (within-one + scale<=1ulp), the same criteria as gate_gemm_s8rq / gate_cosine_i8.

golden x = nr_model's OWN softmax chain replayed to the pre-e4m3 value (the exact functions
the shipped vendor_approximate_softmax calls: _half_rounded, the bit transform, the f16-dtype
row sum, the f32 reciprocal). No new golden -- these are the section-37-authority steps.
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

def golden_x(deq):
    """nr_model's softmax chain replayed to the PRE-e4m3 x (vendor:211-240 up to :239).
    Uses the shipped helpers so it is the same authority gate_softmax already matched."""
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
    return NM._half_rounded(weights.astype(np.float32) * reciprocal.astype(np.float32))  # x, pre-e4m3

def sample(rows, cols, with_bias):
    rng = np.random.default_rng(909 + rows + cols + 3 * with_bias)
    q8 = rng.integers(-40, 41, size=(rows, 32)).astype(np.int8)
    k8 = rng.integers(-40, 41, size=(cols, 32)).astype(np.int8)
    acc = (q8.astype(np.int32) @ k8.astype(np.int32).T)          # (rows, cols) int32 exact
    qs = np.full(rows, STEP, np.float32)
    ks = np.full(cols, STEP, np.float32)
    if with_bias:
        bias = rng.uniform(-0.5, 0.5, (rows, cols)).astype(np.float32)
    else:
        bias = np.zeros((rows, cols), np.float32)
    return acc, qs, ks, bias

def run(rows, cols, with_bias, label):
    global fails
    acc, qs, ks, bias = sample(rows, cols, with_bias)
    hacc = lib.xmx_buf_create_kind(rows * cols * 4, 4)
    hq = lib.xmx_buf_create_kind(rows * 4, 4)
    hk = lib.xmx_buf_create_kind(cols * 4, 4)
    hb = lib.xmx_buf_create_kind(rows * cols * 4, 4)
    ho = lib.xmx_buf_create_kind(rows * cols, 1)
    hs = lib.xmx_buf_create_kind(rows * 4, 4)
    ok(min(hacc, hq, hk, hb, ho, hs) > 0, f"{label}: 6 buffers")
    lib.xmx_buf_upload(hacc, acc.ctypes.data, 0, rows * cols * 4)
    lib.xmx_buf_upload(hq, qs.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hk, ks.ctypes.data, 0, cols * 4)
    lib.xmx_buf_upload(hb, bias.ctypes.data, 0, rows * cols * 4)
    lib.xmx_buf_zero(ho); lib.xmx_buf_zero(hs)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_softmax_i8(hacc, hq, hk, hb, ho, hs, rows, cols)
    ok(rc == 0, f"{label}: rec_softmax_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * cols, np.int8); lib.xmx_buf_download(ho, got.ctypes.data, 0, rows * cols)
    gns = np.zeros(rows, np.float32); lib.xmx_buf_download(hs, gns.ctypes.data, 0, rows * 4)

    deq = (acc.astype(np.float32) * qs[:, None]).astype(np.float32) * ks[None, :]
    deq = (deq + bias).astype(np.float32)
    x = golden_x(deq)
    rmax = np.max(np.abs(x), axis=1)
    wns = (rmax / np.float32(127.0)).astype(np.float32)
    q = np.divide(x, wns[:, None], out=np.zeros_like(x, dtype=np.float64), where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    gp = got.reshape(rows, cols)
    step = gp.astype(np.float64) * gns.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - x.astype(np.float64)) <= np.maximum(gns.astype(np.float64), 1e-30)[:, None] * limit
    sculp = int(np.abs(gns.view(np.int32) - wns.view(np.int32)).max())
    worst = float(np.max(np.abs(step - x) / np.maximum(gns, 1e-30)[:, None]))
    ok(bool(within.all()) and sculp <= 1,
       f"{label} {rows}x{cols} bias={with_bias}: within-one {bool(within.all())} (worst {worst:.5f} step), "
       f"scale<=1ulp (max {sculp})")
    for h in (hacc, hq, hk, hb, ho, hs): lib.xmx_buf_destroy(h)

run(256, 64, 0, "win-nobias")     # window attention, 64 keys, no bias
run(256, 64, 1, "win-bias")       # with the per-head bias tile
run(128, 128, 1, "global")        # global attention, 128 keys
run(64, 256, 0, "vit")            # vit token count
run(2048, 64, 1, "big")           # R8a-legal big M

print(f"\nSOFTMAX_I8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
