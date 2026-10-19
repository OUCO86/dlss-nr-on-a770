#!/usr/bin/env python3
"""f16 gemm_residual FOUNDATION gate (route(a) step 3, section 88 -- the f16 twin of the
green int8 residual swap-in #3, needed to compose ffn/window_block).

Math pinned from libxmx.c:2365 + residual_epilogue.glsl:18-23 + gemm_staged.comp:346
BEFORE writing either side (section 73's discipline):
    total = fma( skipped, cosine[c], acc )   ONE fused rounding (device sycl::fma = HW FMA)
    out   = publish(epi, total) -> f16 iff 0x1000 else f32
    skipped = half iff 0x40000 else f32; cosine f32[N]; at = r*N+c (non-window).
The ONLY difference from the int8 residual: the f16 acc is already the true value, so
there is NO cr_mul(row)*cr_mul(col) dequantise step -- total = fma(skip, cos, acc) direct.

CRITERION = section 82's f16 split (NOT bit-equal): the f16 GEMM's accumulator carries a
hardware-defined K-accumulation-order slack (section 81), so `total` inherits it. The
f32-out path measures total WITHIN-ONE vs the numpy f64-exact fma (the fma itself is exact
via the gap<=18 trick; the slack is the acc). For a narrow variant we ALSO re-run with
epi=0 to get the device's raw total and check publish(epi, device_total) == the device's
narrow output -- the two-leg self-consistency, with the publish leg's correctness inherited
from its own PUBLISH gate (section 25's split). Signed-zero carve-out as in gate_gemm_f16.

HARNESS DISCIPLINE (section 74): every uploaded array is built float32/float16 EXPLICITLY
and up() asserts the dtype -- numpy's silent f32*f64 promotion overruns the buffer.

Variants mirror test_ffn_fused.py's parameter grid (epilogue in {0, EPI_E4M3}, narrow in
{False,True}, skip_half in {False,True}) at f16-residual shapes (the ffn projection's
rows x 32 x 128 and the outproj-style rows x channels x channels).
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
    ("xmx_rec_gemm_residual", [ctypes.c_int] * 5 + [ctypes.c_uint] * 4),
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

def device_total(M, N, K, A, B, skip, cosine, half_skip):
    """run the SAME operands with epi=0, narrow=0 (f32-out) to get the device's raw total."""
    ha = lib.xmx_buf_create_kind(M * K * 2, 2); hb = lib.xmx_buf_create_kind(K * N * 2, 2)
    hc = lib.xmx_buf_create_kind(M * N * 4, 4)
    hsk = lib.xmx_buf_create_kind(M * N * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(N * 4, 4)
    up(ha, A); up(hb, B); up(hsk, skip); up(hco, cosine); lib.xmx_buf_zero(hc)
    assert lib.xmx_begin() == 0
    # epi=0 + f32-out to read the raw total, but KEEP the half_skip bit (0x40000) so the
    # skip buffer is read with the same dtype it was built with -- dropping it here would
    # make the recorder read a half skip as f32 (garbage).
    assert lib.xmx_rec_gemm_residual(ha, hb, hc, hsk, hco, M, N, K, (0x40000 if half_skip else 0)) == 0
    assert lib.xmx_submit() == 0
    raw = np.zeros(M * N * 4, np.uint8); lib.xmx_buf_download(hc, raw.ctypes.data, 0, M * N * 4)
    for h in (ha, hb, hc, hsk, hco): lib.xmx_buf_destroy(h)
    return raw.view(np.float32)

def run(M, N, K, flags, label):
    global fails
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    half_skip = bool(flags & 0x40000)
    rng = np.random.default_rng(8880 + M + N * 3 + K * 5 + flags)
    # f16 inputs in O(1): the real residual regime (a projection answer added to a skip of
    # its own scale). gap<=18 asserted below for the f64-exact fma.
    A = rng.uniform(-1, 1, size=M * K).astype(np.float16)
    B = rng.uniform(-1, 1, size=K * N).astype(np.float16)
    sgns = rng.choice(np.float32([-1.0, 1.0]), size=M * N)
    if half_skip:
        skip = np.asarray(sgns * rng.uniform(0.4, 1.0, size=M * N).astype(np.float32), np.float16)
    else:
        skip = (sgns * rng.uniform(0.4, 1.0, size=M * N).astype(np.float32)).astype(np.float32)
    cosine = (rng.uniform(0.4, 1.0, size=N).astype(np.float32)
              * rng.choice(np.float32([-1.0, 1.0]), size=N)).astype(np.float32)
    wsz = 2 if narrow else 4

    ha = lib.xmx_buf_create_kind(M * K * 2, 2); hb = lib.xmx_buf_create_kind(K * N * 2, 2)
    hc = lib.xmx_buf_create_kind(M * N * wsz, wsz)
    hsk = lib.xmx_buf_create_kind(M * N * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(N * 4, 4)
    ok(min(ha, hb, hc, hsk, hco) > 0, f"{label}: buffers")
    up(ha, A); up(hb, B); up(hsk, skip); up(hco, cosine)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_residual(ha, hb, hc, hsk, hco, M, N, K, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * N * wsz, np.uint8); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N * wsz)
    for h in (ha, hb, hc, hsk, hco): lib.xmx_buf_destroy(h)

    # golden total: numpy f32 acc, then the f64-exact fma (gap asserted).
    acc = (A.view(np.float16).astype(np.float32).reshape(M, K)
           @ B.view(np.float16).astype(np.float32).reshape(K, N)).astype(np.float32)
    sk = skip.view(np.float16).astype(np.float32) if half_skip else skip.astype(np.float32)
    prod64 = sk.reshape(M, N).astype(np.float64) * cosine.astype(np.float64)[None, :]
    st64 = acc.astype(np.float64)
    e_p = np.floor(np.log2(np.abs(prod64) + (prod64 == 0)))
    e_s = np.floor(np.log2(np.abs(st64) + (st64 == 0)))
    gap = np.abs(np.where(prod64 == 0, e_s, np.where(st64 == 0, e_p, e_p - e_s)))
    assert float(gap.max()) <= 18.0, f"{label}: f64 exponent gap {gap.max()} -- widen the band"
    total = (prod64 + st64).astype(np.float32).reshape(M * N)

    # the device's raw total (epi=0, f32-out) -- the f16 gemm's acc slack lives here.
    dev_total = device_total(M, N, K, A, B, skip, cosine, half_skip)
    tol = np.maximum(np.abs(total) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(dev_total - total) > tol).sum())

    if not narrow:
        # f32-out: the published value IS the total (epi applied). For epi=0 that is the
        # raw total; for epi!=0 apply publish to the device total and compare within-one
        # of the published grid. Simplest honest check: device total within-one (above) AND
        # the f32-out output equals publish(epi, device_total) leg-consistently.
        if epi == 0:
            ok(nbad == 0, f"{label}: TOTAL WITHIN-ONE ({M}x{N}x{K} flags=0x{flags:x})"
                          + ("" if nbad == 0 else f" ({nbad} bad)"))
            return
        # epi!=0 f32-out: compare the output to publish(epi, device_total) (two-leg).
        if epi == 1: pub = NM.e4m3(dev_total)
        elif epi == 3: pub = NM.e4m3(NM.quadratic_gate_activation(dev_total))
        elif epi == 2: pub = NM.quadratic_gate_activation(dev_total)
        else: pub = NM._half_rounded(dev_total)
        wantf = np.asarray(pub, np.float32)
        gv = got.view(np.float32)
        gh = gv.view(np.uint32); wh = wantf.view(np.uint32)
        gz = (gh & 0x7FFFFFFF) == 0; wz = (wh & 0x7FFFFFFF) == 0
        sameb = bool(((gh == wh) | (gz & wz)).all())
        ok(nbad == 0 and sameb, f"{label}: TOTAL WITHIN-ONE ({nbad} bad) + PUBLISH self-consistent "
                                f"({sameb}) ({M}x{N}x{K} flags=0x{flags:x})")
        return

    # narrow (f16 out): publish(epi, device_total) == device narrow output (two-leg).
    if epi == 1: pub = NM.e4m3(dev_total)
    elif epi == 3: pub = NM.e4m3(NM.quadratic_gate_activation(dev_total))
    elif epi == 2: pub = NM.quadratic_gate_activation(dev_total)
    elif epi == 4: pub = NM._half_rounded(dev_total)
    else: pub = dev_total
    wantb = np.asarray(pub, np.float16).view(np.uint8)
    gh = got.view(np.uint16); wh = wantb.view(np.uint16)
    gz = (gh & 0x7FFF) == 0; wz = (wh & 0x7FFF) == 0
    sameb = bool(((gh == wh) | (gz & wz)).all())
    ok(nbad == 0 and sameb, f"{label}: TOTAL WITHIN-ONE ({nbad} bad) + PUBLISH self-consistent "
                            f"({sameb}) ({M}x{N}x{K} flags=0x{flags:x})")

# the ffn projection's real shape (rows x 32 x 128) + an outproj-style (rows x channels x
# channels), across test_ffn_fused's epilogue/narrow/skip_half grid. M shrunk for CI.
run(256, 32, 128, 0x00000, "F1-256x32x128-f32out-epi0-f32skip")
run(256, 32, 128, 0x41000, "F2-256x32x128-narrow-epi0-halfskip")
run(256, 32, 128, 0x41100, "F3-256x32x128-narrow-epi1-halfskip")   # the ffn narrow path
run(640, 64, 64, 0x41100, "F4-640x64x64-narrow-epi1-halfskip")     # outproj-style
run(192, 128, 128, 0x01000, "F5-192x128x128-narrow-epi0-f32skip")  # padded M, f32 skip
run(128, 32, 128, 0x40100, "F6-128x32x128-f32out-epi1-halfskip")   # epi1 f32-out

print(f"\nGEMM_F16_RESIDUAL {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
