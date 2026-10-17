#!/usr/bin/env python3
"""Route-B block 1 gate (section 38): cosine-normalise -> register row-max -> requantize
to int8 + per-row scale. BOUNDED criteria (requantize is lossy), exactly like gate_gemm_s8rq.

Golden fp = the normalised (and for Q, learned-scale-multiplied) value the f32 gate already
proved bit-exact (vendor_cosine_normalize :242 / the vit chain :754), then int8_quant-style
requantize: rmax = max|fp|, ns = rmax/127, want = clip(rint(fp/ns), -127, 127).
The kernel uses the v3 multiply-form (fp * 127/rmax); the golden uses the divide-form
(fp/ns) -- they differ by <=1 ULP at ties, which is what within-one tolerates (section 25:
never chase the tie difference, it is a reference artifact).

Zero rows: rmax=0 -> the kernel's inv=0 path yields int8 0 and scale 0; the golden guards
the divide-by-zero the same way.
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

def golden_fp(vals, heads, vit, is_q, qkv_scale):
    """the normalised (+ learned scale for Q) f32, matching the f32 gate's authority.
    _vit_norm's contract (nr_model:683 docstring) is that its input is ALREADY half values
    (it half_rounds the high squares but not the operand); the kernel half_rounds first
    (qr_half_round is idempotent on a half input), so the golden must too. For the window
    path vendor_cosine_normalize half_rounds internally (:243) so this is a no-op there."""
    vals = NM._half_rounded(vals)
    if not vit:
        norm = NM.vendor_cosine_normalize(vals)          # (rows,32), each element half-rounded
        if is_q:
            sc = NM._half_rounded(qkv_scale).astype(np.float32)
            scper = sc[np.arange(vals.shape[0]) % heads][:, None]
            return NM._half_rounded(norm * scper)
        return norm
    norm = NM._vit_norm(vals)[:, None]
    v = NM._half_rounded(vals * norm)
    if is_q:
        root = NM._half_rounded(np.float32(math.sqrt(32)))
        sc = NM._half_rounded(qkv_scale).astype(np.float32)
        scper = sc[np.arange(vals.shape[0]) % heads][:, None]
        v = NM._half_rounded(NM._half_rounded(v * root) * scper)
    return v

def sample(rows):
    rng = np.random.default_rng(411 + rows)
    v = rng.uniform(-4, 4, (rows, 32)).astype(np.float32)
    v[0] = 0.0                                            # zero head -> rmax 0 path
    v[1] = NM._half_rounded(np.full(32, 300.0, np.float32))  # overflow-ish squares
    v[2] = NM._half_rounded(np.full(32, 0.0005, np.float32)) # tiny -> near floor
    return v

def run(rows, heads, vit, is_q, label):
    global fails
    assert rows % heads == 0
    vals = sample(rows)
    qkv_scale = (0.5 + rng.random(heads).astype(np.float32)) if (is_q) else np.zeros(heads, np.float32)
    hs = lib.xmx_buf_create_kind(rows * 32 * 4, 4)
    ho = lib.xmx_buf_create_kind(rows * 32, 1)
    hc = lib.xmx_buf_create_kind(rows * 4, 4)
    hq = lib.xmx_buf_create_kind(heads * 4, 4) if is_q else 0
    ok(hs > 0 and ho > 0 and hc > 0, f"{label}: buffers")
    lib.xmx_buf_upload(hs, vals.ctypes.data, 0, rows * 32 * 4)
    if is_q: lib.xmx_buf_upload(hq, qkv_scale.ctypes.data, 0, heads * 4)
    lib.xmx_buf_zero(ho); lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_cosine_norm_i8(hs, ho, hc, rows, 1 if vit else 0, hq, heads if is_q else 0)
    ok(rc == 0, f"{label}: rec_cosine_norm_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * 32, np.int8); lib.xmx_buf_download(ho, got.ctypes.data, 0, rows * 32)
    gns = np.zeros(rows, np.float32);   lib.xmx_buf_download(hc, gns.ctypes.data, 0, rows * 4)

    fp = golden_fp(vals, heads, vit, is_q, qkv_scale)
    rmax = np.max(np.abs(fp), axis=1)
    wns = (rmax / np.float32(127.0)).astype(np.float32)
    # divide-form reference requantize; zero rows -> 0 (the kernel's inv=0 path). np.divide
    # with where= guards the 0/0 without the (256,)-vs-(256,32) broadcast trap.
    q = np.divide(fp, wns[:, None], out=np.zeros_like(fp, dtype=np.float64),
                  where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    gp = got.reshape(rows, 32)
    # within-one (the senior's rq criterion): reconstructed int8*scale lands within half a
    # quantization step of the golden fp; new_scale within 1 ulp.
    step = gp.astype(np.float64) * gns.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - fp.astype(np.float64)) <= np.maximum(gns.astype(np.float64), 1e-30)[:, None] * limit
    sculp = int(np.abs(gns.view(np.int32) - wns.view(np.int32)).max())
    exact = np.array_equal(gp, want)
    worst = float(np.max(np.abs(step - fp) / np.maximum(gns, 1e-30)[:, None]))
    ok(bool(within.all()) and sculp <= 1,
       f"{label} rows={rows} heads={heads} vit={vit} is_q={is_q}: within-one {bool(within.all())} "
       f"(worst {worst:.5f} step), scale<=1ulp (max {sculp}); bit-exact-vs-divide-form {exact} "
       f"(tie diffs OK, section 25)")
    for h in (hs, ho, hc, hq):
        if h: lib.xmx_buf_destroy(h)

rng = np.random.default_rng(7)
run(256, 2, 0, 0, "K-win")
run(256, 2, 0, 1, "Q-win")
run(512, 8, 0, 1, "Q8h-win")
run(256, 2, 1, 0, "K-vit")
run(256, 2, 1, 1, "Q-vit")
run(8192, 16, 0, 1, "Q16h-big")

print(f"\nCOSINE_I8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
