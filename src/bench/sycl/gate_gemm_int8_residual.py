#!/usr/bin/env python3
"""int8-residual swap-in gate (route(a) step 3 #3, section 74).

The shipping math (.comp:274-281, pinned in the recorder comment before EITHER side was
written -- section 73's lesson):
    stage = f32(f32(f32(acc) * a_scale[r]) * b_scale[c])        (two rounded f32 muls)
    total = fma( skipped, cosine[c], stage )                    (ONE fused rounding)
    out   = publish(epi, total) -> f16 (narrow) / f32
skipped = half iff 0x40000 else f32; cosine f32[N]; at = r*N+c (non-window).

Device uses sycl::fma (HW FMA = correctly-rounded single rounding). The golden reproduces
that with the f64 trick: the product sk*cp is EXACT in f64 (11+24=35 bits), stage is
exact in f64, and the SUM is exact in f64 whenever the exponent gap <= 18 -- the test
asserts that gap for every element, so float(f64sum) == a correct fma bit-for-bit.

HARNESS DISCIPLINE (this gate's first three runs were RED on a HARNESS bug, not the
recorder -- proved by the A=0 ramp probes passing 256/256 rows at plan sizes): numpy
silently PROMOTES f32 * rng.choice(float64) to float64, and uploading that 8-byte array
into a 4-byte-per-element buffer overruns it and feeds the kernel garbage (the 448
saturations). EVERY uploaded array is now built float32/float16 EXPLICITLY (an .astype
after any multiply that touches a Python float), and up() asserts the dtype before it
uploads -- the trap cannot silently return.

Variants: the plan's real families (section 74's dump: 2040x256x256 x16, 640x512x512? no
-- that was plain gemm_int8; residual families are (2040,256,256),(640,512,512),(8160,128,
128),(32640,64,64),(192,1024,4096),(192,1024,1024), ALL flags 0x41100 = epi1+narrow+
half-skip), shrunk for CI speed but keeping the N/K ratios and the padded-M (192) case,
plus an R0 zero-A variant (the hand-computed probe that proved the recorder clean) and an
R4 f32-skip stress (half_skip off -- the recorder supports it, the plan never uses it).
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
    ("xmx_rec_gemm_int8_residual", [ctypes.c_int] * 7 + [ctypes.c_uint] * 4),
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

def run(M, N, K, flags, label, zero_A=False):
    global fails
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    half_skip = bool(flags & 0x40000)
    rng = np.random.default_rng(7470 + M + N * 3 + K * 5 + flags)
    accscale = float(np.sqrt(K)) * 127.0 * 127.0 / 3.0
    # stage tuned to O(1): same-magnitude addends -- the real residual regime (.comp's
    # branch is added to a projection answer of its own scale), and the f64-exact fma
    # trick needs gap <= 18 (asserted below).
    ascale = np.float32(accscale ** -0.5) * (np.float32(0.95) + rng.random(M).astype(np.float32) * np.float32(0.1))
    bscale = np.float32(accscale ** -0.5) * (np.float32(0.95) + rng.random(N).astype(np.float32) * np.float32(0.1))
    A = (np.zeros((M, K), np.int8) if zero_A
         else rng.integers(-127, 128, size=(M, K), dtype=np.int8))
    Bt = rng.integers(-127, 128, size=(N, K), dtype=np.int8)     # transposed storage
    sgns = rng.choice(np.float32([-1.0, 1.0]), size=M * N)       # f32 signs: no promotion
    if half_skip:
        skip = np.asarray(sgns * rng.uniform(0.4, 1.0, size=M * N).astype(np.float32), np.float16)
    else:
        skip = (sgns * rng.uniform(0.4, 1.0, size=M * N).astype(np.float32)).astype(np.float32)
    cosine = (rng.uniform(0.4, 1.0, size=N).astype(np.float32)
              * rng.choice(np.float32([-1.0, 1.0]), size=N)).astype(np.float32)
    wsz = 2 if narrow else 4

    ha = lib.xmx_buf_create_kind(M * K, 1); hb = lib.xmx_buf_create_kind(N * K, 1)
    hc = lib.xmx_buf_create_kind(M * N * wsz, wsz)
    has = lib.xmx_buf_create_kind(M * 4, 4); hbs = lib.xmx_buf_create_kind(N * 4, 4)
    hsk = lib.xmx_buf_create_kind(M * N * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(N * 4, 4)
    ok(min(ha, hb, hc, has, hbs, hsk, hco) > 0, f"{label}: buffers")
    up(ha, A); up(hb, Bt); up(has, ascale); up(hbs, bscale); up(hsk, skip); up(hco, cosine)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_int8_residual(ha, hb, hc, has, hbs, hsk, hco, M, N, K, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * N * wsz, np.uint8); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N * wsz)
    for h in (ha, hb, hc, has, hbs, hsk, hco): lib.xmx_buf_destroy(h)

    # golden: two-step f32 (matches cr_mul), then f64-exact fma with the gap asserted.
    acc = (A.astype(np.int64) @ Bt.astype(np.int64).T).astype(np.float32)
    stage = (acc * ascale[:, None]).astype(np.float32)
    stage = (stage * bscale[None, :]).astype(np.float32)
    sk = skip.view(np.float16).astype(np.float32) if half_skip else skip.astype(np.float32)
    prod64 = sk.reshape(M, N).astype(np.float64) * cosine.astype(np.float64)[None, :]
    st64 = stage.astype(np.float64)
    e_p = np.floor(np.log2(np.abs(prod64) + (prod64 == 0)))
    e_s = np.floor(np.log2(np.abs(st64) + (st64 == 0)))
    gap = np.abs(np.where(prod64 == 0, e_s, np.where(st64 == 0, e_p, e_p - e_s)))
    assert float(gap.max()) <= 18.0, f"{label}: f64 exponent gap {gap.max()} -- widen the band"
    total = (prod64 + st64).astype(np.float32)
    if epi == 1: v = NM.e4m3(total)
    elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(total))
    elif epi == 2: v = NM.quadratic_gate_activation(total)
    else: v = NM._half_rounded(total)
    want = (np.asarray(v, np.float16) if narrow else np.asarray(v, np.float32)).reshape(M * N).view(np.uint8)
    same = np.array_equal(got, want)
    nbad = int((got != want).sum())
    if same:
        ok(True, f"{label}: OUT BITS EQUAL ({M}x{N}x{K} flags=0x{flags:x}{', zero-A' if zero_A else ''})")
    else:
        ge = got.view(np.uint16 if wsz == 2 else np.uint32)
        we = want.view(np.uint16 if wsz == 2 else np.uint32)
        d = np.flatnonzero(ge != we)
        e = int(d[0]); r, c = divmod(e, N)
        ok(False, f"{label}: {nbad} bad bytes; first ({r},{c}) got 0x{ge[e]:04x} want 0x{we[e]:04x}")

# R0: the hand-probe that proved the recorder clean at plan sizes, as a permanent anchor
run(256, 256, 256, 0x41100, "R0-zeroA", zero_A=True)
# the plan's real N/K families, M shrunk for CI (2040/32640/8160 keep the gate fast; the
# full-M versions ride the permissive walk's blob data instead):
run(256, 256, 256, 0x41100, "R1-256-halfskip")
run(192, 1024, 1024, 0x41100, "R2-192x1024-paddedM")           # padded tail + real N,K
run(640, 512, 512, 0x41100, "R3-640x512-planfam")              # exact plan family size
run(128, 64, 64, 0x21100, "R4-f32skip-stress")                 # half_skip OFF

print(f"\nGEMM_INT8_RESIDUAL {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
