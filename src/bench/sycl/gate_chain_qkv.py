#!/usr/bin/env python3
"""Full QKV projection chain gate (section 45 capstone): one submit -> int8 Q, K, V.

The real QKV is ONE projection (weight 3*channels x channels) split into Q/K/V, then
cosine-normalise Q,K (Q also learned-scaled) and publish all three. In the int8-straight-
through chain that is, in ONE begin/submit:
  entry quantize (fp16 -> int8 + row scale)  [once]
  V: gemm_qkv_v_i8  (GEMM + column requantize -> int8 V + per-(window,channel) scale)
  Q: gemm_qkv_deq (GEMM -> f32) then cosine_norm_i8 (norm + learned scale + row requantize)
  K: gemm_qkv_deq (GEMM -> f32) then cosine_norm_i8 (norm + row requantize, no scale)
=> int8 Q,K,V + their scales, ready for the scores/attnV GEMMs. The old chain paid a
float32 round-trip + two cosine publishes + a split + a quantize_row here (qkv_epilogue
header: block0 720p = 377 MB x3, 19 ms); this chain pays the entry quantize once.

Every branch's arithmetic is ALREADY gated on its own (v_i8 41, cosine_i8 39, deq 36);
this gate proves the COMPOSITION -- one submit, the three weight slices of the real
projection, the shared entry-quantized activation, and the three int8 outputs. Bounded
criteria (requantize lossy), goldens = the same nr_model authorities the per-branch gates
used (vendor_cosine_publish chain; the v_i8 column-requant reference). No new golden.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import nr_model as NM
import int8_quant

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
    ("xmx_rec_quant", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2),
    ("xmx_rec_gemm_qkv_v_i8", [ctypes.c_int] * 6 + [ctypes.c_uint] * 4),
    ("xmx_rec_gemm_qkv_deq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 2),
    ("xmx_rec_cosine_norm_i8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2 + [ctypes.c_int, ctypes.c_uint]),
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

def bounded_i8(got8, gscale, fp, label):
    """within-one + scale<=1ulp vs the fp the branch should have requantized (v3 contract)."""
    f32 = np.float32
    rmax = np.max(np.abs(fp), axis=1)
    wns = (rmax / f32(127.0)).astype(f32)
    q = np.divide(fp, wns[:, None], out=np.zeros_like(fp, dtype=np.float64), where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    step = got8.astype(np.float64) * gscale.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - fp.astype(np.float64)) <= np.maximum(gscale.astype(np.float64), 1e-30)[:, None] * limit
    sculp = int(np.abs(gscale.view(np.int32) - wns.view(np.int32)).max())
    ok(bool(within.all()) and sculp <= 1,
       f"{label}: within-one {bool(within.all())}, scale<=1ulp (max {sculp})")

def run(windows, tokens, channels, vit, label):
    global fails
    heads = channels // 32
    rows = windows * tokens
    assert rows % 128 == 0 and channels % 64 == 0 and tokens == 64
    rng = np.random.default_rng(2727 + rows + channels + 5 * vit)
    vals = rng.uniform(-1, 1, (rows, channels)).astype(np.float16).astype(np.float32)
    half = vals.astype(np.float16)
    # the real projection weight: (3*channels, channels); slice into Q,K,V weight blocks.
    wfull = rng.integers(-40, 41, size=(3 * channels, channels)).astype(np.int8)
    wQ = np.ascontiguousarray(wfull[0:channels])
    wK = np.ascontiguousarray(wfull[channels:2 * channels])
    wV = np.ascontiguousarray(wfull[2 * channels:3 * channels])
    a_scale = np.full(rows, STEP, np.float32)
    wQ_scale = (0.001 * (np.arange(channels) % 37 + 1)).astype(np.float32)
    wK_scale = (0.002 * (np.arange(channels) % 29 + 1)).astype(np.float32)
    wV_scale = (0.003 * (np.arange(channels) % 23 + 1)).astype(np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)

    hsrc = lib.xmx_buf_create(rows * channels * 2)
    haq = lib.xmx_buf_create_kind(rows * channels, 1)
    has = lib.xmx_buf_create_kind(rows * 4, 4)
    hwQ = lib.xmx_buf_create(channels * channels); hwK = lib.xmx_buf_create(channels * channels)
    hwV = lib.xmx_buf_create(channels * channels)
    hwQs = lib.xmx_buf_create_kind(channels * 4, 4); hwKs = lib.xmx_buf_create_kind(channels * 4, 4)
    hwVs = lib.xmx_buf_create_kind(channels * 4, 4)
    hqf = lib.xmx_buf_create_kind(rows * channels * 4, 4)   # Q f32 (deq)
    hkf = lib.xmx_buf_create_kind(rows * channels * 4, 4)   # K f32 (deq)
    hq8 = lib.xmx_buf_create_kind(rows * channels, 1)       # Q int8 (rows*heads*32)
    hk8 = lib.xmx_buf_create_kind(rows * channels, 1)       # K int8
    hqs = lib.xmx_buf_create_kind(rows * heads * 4, 4)      # Q row scale (one per head-row)
    hks = lib.xmx_buf_create_kind(rows * heads * 4, 4)      # K row scale
    hv8 = lib.xmx_buf_create_kind(rows * channels, 1)       # V int8
    hvs = lib.xmx_buf_create_kind(windows * channels * 4, 4)  # V col scale
    hqkvs = lib.xmx_buf_create_kind(heads * 4, 4)
    ok(min(hsrc, haq, has, hwQ, hwK, hwV, hqf, hkf, hq8, hk8, hqs, hks, hv8, hvs, hqkvs) > 0,
       f"{label}: 17 buffers")
    lib.xmx_buf_upload(hsrc, half.ctypes.data, 0, rows * channels * 2)
    lib.xmx_buf_upload(hwQ, wQ.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(hwK, wK.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(hwV, wV.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hwQs, wQ_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_upload(hwKs, wK_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_upload(hwVs, wV_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_upload(hqkvs, qkv_scale.ctypes.data, 0, heads * 4)
    for h in (haq, has, hqf, hkf, hq8, hk8, hqs, hks, hv8, hvs): lib.xmx_buf_zero(h)

    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_quant(hsrc, haq, has, rows, channels)
    ok(rc == 0, f"{label}: entry quantize" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    rc = lib.xmx_rec_gemm_qkv_v_i8(haq, hwV, hv8, hvs, has, hwVs, rows, channels, heads, tokens)
    ok(rc == 0, f"{label}: V gemm+colquant")
    rc = lib.xmx_rec_gemm_qkv_deq(haq, hwQ, hqf, has, hwQs, rows, channels)
    ok(rc == 0, f"{label}: Q gemm->f32")
    rc = lib.xmx_rec_cosine_norm_i8(hqf, hq8, hqs, rows * heads, 1 if vit else 0, hqkvs, heads)
    ok(rc == 0, f"{label}: Q cosine_norm_i8")
    rc = lib.xmx_rec_gemm_qkv_deq(haq, hwK, hkf, has, hwKs, rows, channels)
    ok(rc == 0, f"{label}: K gemm->f32")
    rc = lib.xmx_rec_cosine_norm_i8(hkf, hk8, hks, rows * heads, 1 if vit else 0, 0, 0)
    ok(rc == 0, f"{label}: K cosine_norm_i8")
    ok(lib.xmx_submit() == 0, f"{label}: submit (full QKV, 6 passes)")

    # downloads
    aq = np.zeros(rows * channels, np.int8); lib.xmx_buf_download(haq, aq.ctypes.data, 0, rows * channels)
    qf = np.zeros(rows * channels, np.float32); lib.xmx_buf_download(hqf, qf.ctypes.data, 0, rows * channels * 4)
    kf = np.zeros(rows * channels, np.float32); lib.xmx_buf_download(hkf, kf.ctypes.data, 0, rows * channels * 4)
    q8 = np.zeros(rows * channels, np.int8); lib.xmx_buf_download(hq8, q8.ctypes.data, 0, rows * channels)
    k8 = np.zeros(rows * channels, np.int8); lib.xmx_buf_download(hk8, k8.ctypes.data, 0, rows * channels)
    qsc = np.zeros(rows * heads, np.float32); lib.xmx_buf_download(hqs, qsc.ctypes.data, 0, rows * heads * 4)
    ksc = np.zeros(rows * heads, np.float32); lib.xmx_buf_download(hks, ksc.ctypes.data, 0, rows * heads * 4)
    v8 = np.zeros(rows * channels, np.int8); lib.xmx_buf_download(hv8, v8.ctypes.data, 0, rows * channels)
    vsc = np.zeros(windows * channels, np.float32); lib.xmx_buf_download(hvs, vsc.ctypes.data, 0, windows * channels * 4)

    # the entry quantize is the shared input; verify it once (bounded, int8_quant contract).
    wp, ws = int8_quant.quantise(vals, 1)
    ok(int(np.abs(aq.reshape(rows, channels).astype(np.int32) - wp.astype(np.int32)).max()) <= 1,
       f"{label}: entry quantize packed<=1")
    # the DEVICE's row scale from the entry quantize (NOT the constant STEP) -- the
    # branches dequantise with this, so the golden must use the same bytes (section 25).
    dev_as = np.zeros(rows, np.float32); lib.xmx_buf_download(has, dev_as.ctypes.data, 0, rows * 4)

    # Q/K: the deq f32 the branch fed to cosine_norm_i8, recomputed from the DEVICE's aq
    # and the DEVICE's entry row scale.
    def branch_fp(aq8, w, wscale):
        acc = aq8.reshape(rows, channels).astype(np.int32) @ w.astype(np.int32)
        return (acc.astype(np.float32) * dev_as[:, None]).astype(np.float32) * wscale[None, :]
    qfp = branch_fp(aq, wQ, wQ_scale)
    kfp = branch_fp(aq, wK, wK_scale)
    # the normalised (+ learned scale for Q) fp that cosine_norm_i8 requantizes. The
    # kernel treats its input as (rows*heads, 32) -- one head per row, learned scale
    # indexed by (row*heads+head) % heads = head. So the fp reference is (rows*heads, 32).
    def norm_fp(fp, is_q):
        v = NM._half_rounded(fp.reshape(rows * heads, 32))
        if not vit:
            n = NM.vendor_cosine_normalize(v)
            if is_q:
                sc = NM._half_rounded(qkv_scale).astype(np.float32)[np.arange(rows * heads) % heads][:, None]
                return NM._half_rounded(n * sc)
            return n
        nrm = NM._vit_norm(v)[:, None]
        x = NM._half_rounded(v * nrm)
        if is_q:
            root = NM._half_rounded(np.float32(np.sqrt(32)))
            sc = NM._half_rounded(qkv_scale).astype(np.float32)[np.arange(rows * heads) % heads][:, None]
            x = NM._half_rounded(NM._half_rounded(x * root) * sc)
        return x
    bounded_i8(q8.reshape(rows * heads, 32), qsc, norm_fp(qfp, True), f"{label} Q")
    bounded_i8(k8.reshape(rows * heads, 32), ksc, norm_fp(kfp, False), f"{label} K")

    # V: column requantize reference (the v_i8 gate's own logic), un-scatter then compare.
    vfp = branch_fp(aq, wV, wV_scale).reshape(windows, tokens, channels)
    cmax = np.max(np.abs(vfp), axis=1)
    wns = (cmax / np.float32(127.0)).astype(np.float32)
    q = np.divide(vfp, wns[:, None, :], out=np.zeros_like(vfp, dtype=np.float64), where=wns[:, None, :] > 0)
    wantV = np.clip(np.rint(q), -127, 127).astype(np.int8)
    vflat = v8.reshape(rows * channels)
    gu = np.empty((windows, tokens, channels), np.int8)
    for w in range(windows):
        for t in range(tokens):
            for c in range(channels):
                at = ((w * heads + c // 32) * tokens + t) * 32 + (c % 32)
                gu[w, t, c] = vflat[at]
    step = gu.astype(np.float64) * wns.astype(np.float64)[:, None, :]
    within = np.abs(step - vfp.astype(np.float64)) <= np.maximum(wns.astype(np.float64), 1e-30)[:, None, :] * (0.5 + 2.0 ** -16)
    sculp = int(np.abs(vsc.view(np.int32) - wns.ravel().view(np.int32)).max())
    ok(bool(within.all()) and sculp <= 1, f"{label} V: within-one {bool(within.all())}, col_scale<=1ulp (max {sculp})")

    for h in (hsrc, haq, has, hwQ, hwK, hwV, hwQs, hwKs, hwVs, hqf, hkf, hq8, hk8, hqs, hks, hv8, hvs, hqkvs):
        lib.xmx_buf_destroy(h)

run(2, 64, 64, 0, "qkv-win-2h")
run(2, 64, 256, 0, "qkv-win-8h")
run(4, 64, 128, 0, "qkv-win-4h")
run(2, 64, 64, 1, "qkv-vit-2h")
# section-58 follow-up: the shipped vit door is C=1024 (blocks 31-38). The proven chain,
# unchanged, at that channel count (rows=256, heads=32) -- the decisive shape test:
run(4, 64, 1024, 0, "qkv-win-C1024")
run(4, 64, 1024, 1, "qkv-vit-C1024")

print(f"\nCHAIN_QKV {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
