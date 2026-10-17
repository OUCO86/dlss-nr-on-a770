#!/usr/bin/env python3
"""S3a Q/K chain gate: three composed passes (GEMM+deq -> cosine_norm[_q] -> publish+scatter).

ESIMD cannot call the libdevice rounding ops (fmul_rn/fdiv_rn) the PROVEN cosine tree uses,
so the Q/K branch composes three already-gated pieces first -- the same staged rhythm the
senior used (v1-int32 was a path gate, v3 fused later). S3b folds passes 2+3 into the ESIMD
main loop with esimd-native arithmetic.

Pass 1 = gemm_qkv_deq (ESIMD, tile-local: int8 GEMM -> dequantise island-3 -> f32).
Pass 2 = cosine_norm (K) / cosine_norm_q (Q, learned per-head scale after the norm,
         VIT_ROOT between for vit) -- the island-2 tree, plain SYCL, COSINE-gated.
Pass 3 = qkv_scatter -- e4m3 (island-4, PUBLISH-gated) -> (window,head,token,32) scatter.

Golden = nr_model: window path vendor_cosine_publish (transposed to (b,h,t,32) first,
:432-433); vit path the vit_attend chain (:754-756, (b,t,h,32) order). Grid trick: small
integer operands x 2^-8 scales -> deq = acc*2^-16 exact in f32 -> whole chain bit-exact.
"""
import ctypes, os, pathlib, sys, math
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
    ("xmx_rec_gemm_qkv_deq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 2),
    ("xmx_rec_cosine_norm", [ctypes.c_int] * 2 + [ctypes.c_uint] * 2),
    ("xmx_rec_cosine_norm_q", [ctypes.c_int] * 3 + [ctypes.c_uint] * 3),
    ("xmx_rec_qkv_scatter", [ctypes.c_int] * 2 + [ctypes.c_uint] * 3),
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

def scatter4(want4, windows, tokens, heads, order):
    out = np.empty(windows * tokens * heads * 32, np.float16)
    for w in range(windows):
        for t in range(tokens):
            for h in range(heads):
                for c in range(32):
                    at = ((w * heads + h) * tokens + t) * 32 + c
                    out[at] = np.float16(want4[w, h, t, c] if order == "whtc" else want4[w, t, h, c])
    return out

def run(windows, tokens, channels, vit, is_q, label):
    global fails
    heads = channels // 32
    rows = windows * tokens
    assert rows % 128 == 0 and channels % 64 == 0
    rng = np.random.default_rng(5 + rows + channels + 13 * vit + 3 * is_q)
    lim = 3 if vit else 40
    a = rng.integers(-lim, lim + 1, size=(rows, channels)).astype(np.int8)
    b = rng.integers(-lim, lim + 1, size=(channels, channels)).astype(np.int8)
    a_scale = np.full(rows, STEP, np.float32)
    b_scale = np.full(channels, STEP, np.float32)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)).astype(np.float32)

    ha = lib.xmx_buf_create(rows * channels); hb = lib.xmx_buf_create(channels * channels)
    hf = lib.xmx_buf_create_kind(rows * channels * 4, 4)     # dequantised f32
    hn = lib.xmx_buf_create_kind(rows * channels * 4, 4)     # normalised f32
    ht = lib.xmx_buf_create_kind(rows * channels * 2, 2)     # scattered e4m3 halves
    has = lib.xmx_buf_create_kind(rows * 4, 4); hbs = lib.xmx_buf_create_kind(channels * 4, 4)
    hqs = lib.xmx_buf_create_kind(heads * 4, 4)
    ok(min(ha, hb, hf, hn, ht, has, hbs, hqs) > 0, f"{label}: 8 buffers")
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, rows * channels)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hbs, b_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_upload(hqs, qkv_scale.ctypes.data, 0, heads * 4)
    for h in (hf, hn, ht): lib.xmx_buf_zero(h)

    # ONE submit, three passes -- the Q/K seam the old chain paid a float32 round-trip +
    # a separate cosine publish + a split for.
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_qkv_deq(ha, hb, hf, has, hbs, rows, channels)
    ok(rc == 0, f"{label}: p1 gemm_qkv_deq" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    # pass 2 flattens (row, head) pairs: each row of the GEMM output carries heads
    # separate 32-channel heads, and the tree normalises ONE head at a time. The
    # kernel's head index = (flattened row) % heads, matching the (row*heads+head) layout.
    if is_q:
        rc = lib.xmx_rec_cosine_norm_q(hf, hn, hqs, rows * heads, heads, 1 if vit else 0)
        ok(rc == 0, f"{label}: p2 cosine_norm_q" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    else:
        rc = lib.xmx_rec_cosine_norm(hf, hn, rows * heads, 1 if vit else 0)
        ok(rc == 0, f"{label}: p2 cosine_norm (K)" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    rc = lib.xmx_rec_qkv_scatter(hn, ht, rows, heads, tokens)
    ok(rc == 0, f"{label}: p3 qkv_scatter" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit (3 passes)")

    got = np.zeros(rows * channels, np.float16)
    lib.xmx_buf_download(ht, got.ctypes.data, 0, rows * channels * 2)

    acc = a.astype(np.int32) @ b.astype(np.int32)
    deq = (acc.astype(np.float32) * STEP).astype(np.float32) * STEP
    q4 = deq.reshape(windows, tokens, heads, 32)
    if not vit:
        q4t = np.ascontiguousarray(q4.transpose(0, 2, 1, 3))
        want4 = NM.vendor_cosine_publish(q4t, qkv_scale) if is_q else NM.vendor_cosine_publish(q4t, None)
        want = scatter4(want4, windows, tokens, heads, "whtc")
    else:
        norm = NM._vit_norm(q4)[..., None]     # nr_model:754 broadcasts the reciprocal over the 32 channels
        root = NM._half_rounded(np.float32(math.sqrt(32)))
        learned = NM._half_rounded(qkv_scale).reshape(1, 1, heads, 1)
        if is_q:
            want4 = NM.e4m3(NM._half_rounded(NM._half_rounded(NM._half_rounded(q4 * norm) * root) * learned))
        else:
            want4 = NM.e4m3(NM._half_rounded(q4 * norm))
        want = scatter4(want4, windows, tokens, heads, "wthc")
    exact = np.array_equal(got.view(np.uint16), want.view(np.uint16))
    if not exact:
        d = np.nonzero(got.view(np.uint16) != want.view(np.uint16))[0]
        print(f"        nbad={d.size} first at={int(d[0])}: got {got[d[0]]} want {want[d[0]]}")
    ok(exact, f"{label} {windows}x{tokens}x{channels} vit={vit} is_q={is_q}: "
              f"QKV Q/K 3-pass chain BIT-EXACT vs nr_model ({int((got.view(np.uint16)!=want.view(np.uint16)).sum()) if not exact else 0} differ)")
    for h in (ha, hb, hf, hn, ht, has, hbs, hqs): lib.xmx_buf_destroy(h)

run(2, 64, 64, 0, 1, "win-Q")
run(2, 64, 64, 0, 0, "win-K")
run(2, 64, 256, 0, 1, "win-Q8h")
run(2, 64, 256, 0, 0, "win-K8h")
run(2, 64, 64, 1, 1, "vit-Q")
run(2, 64, 64, 1, 0, "vit-K")

print(f"\nQKV_QK {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
