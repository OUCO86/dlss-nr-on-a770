#!/usr/bin/env python3
"""ffn_stem swap-in gate (route(a) step 3 #13, section 88 route).

Block 0's fused feed-forward with its input made in the same pass (ffn_fused.comp flag
0x2000000, libxmx.c:3191). The decomposition is pinned from the .comp BEFORE writing
(section 73's discipline); test_glue.py's `ffn_fused_stem` against `gemm_dual` + the
fused feed-forward is the shipping witness that the fused pass == these steps:
    pass A: stem = features(M x 16) @ adapter(16 x 32) -> f32
            hidden16 = e4m3(stem) as half          (the .comp stem branch: e4m3 ONLY)
            the RAW f32 stem is kept as the residual's skip (flags mask 0x1f00 has no
            0x40000 -> add_gemm_residual reads pc.d as FloatBuf, residual_epilogue.glsl:20)
    pass B: expand = hidden16 @ expand(32 x 128) -> f32 -> publish(3)=gate->e4m3 -> half
    pass C: proj   = hidden @ projection(128 x 32) -> f32
            total  = fma( stem_raw[i], cosine[col], proj[i] )   ONE fused rounding
            out    = publish(epi, total) -> f16 iff 0x1000 else f32

Criterion = WITHIN-ONE vs the numpy three-pass golden (section 85's end-to-end shape):
all three GEMMs are the gated f16v1 legs carrying the hardware K-order slack (section 81),
the publish/e4m3/fma arithmetic is the gated legs (PUBLISH gate, section 74's fma). The
raw-stem skip's slack enters `total` directly (O(1) value, ~2^-10 relative), inside the tol.

captured ffn_stem: 1 call, M=522240, flags=0 (epi=0 f32-out) -- the FIRST recorder in the
captured graph (step 2534), the game face's hard gate. M shrunk for CI keeping the shape
ratios; a narrow+epi1 stress variant beyond the captured flags.
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
    ("xmx_rec_ffn_stem", [ctypes.c_int] * 6 + [ctypes.c_uint] * 2),
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

def run(M, flags, label):
    global fails
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    wsz = 2 if narrow else 4
    rng = np.random.default_rng(88130 + M + flags)
    F = rng.uniform(-1, 1, size=M * 16).astype(np.float16)
    AD = rng.uniform(-0.5, 0.5, size=16 * 32).astype(np.float16)
    E = rng.uniform(-0.25, 0.25, size=32 * 128).astype(np.float16)
    P = rng.uniform(-0.1, 0.1, size=128 * 32).astype(np.float16)
    cosine = (rng.uniform(0.4, 1.0, size=32).astype(np.float32)
              * rng.choice(np.float32([-1.0, 1.0]), size=32)).astype(np.float32)

    hf = lib.xmx_buf_create_kind(M * 16 * 2, 2)
    had = lib.xmx_buf_create_kind(16 * 32 * 2, 2)
    he = lib.xmx_buf_create_kind(32 * 128 * 2, 2)
    hp = lib.xmx_buf_create_kind(128 * 32 * 2, 2)
    ho = lib.xmx_buf_create_kind(M * 32 * wsz, wsz)
    hco = lib.xmx_buf_create_kind(32 * 4, 4)
    ok(min(hf, had, he, hp, ho, hco) > 0, f"{label}: buffers")
    up(hf, F); up(had, AD); up(he, E); up(hp, P); up(hco, cosine)
    lib.xmx_buf_zero(ho)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_ffn_stem(hf, had, he, hp, ho, hco, M, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * 32 * wsz, np.uint8); lib.xmx_buf_download(ho, got.ctypes.data, 0, M * 32 * wsz)
    for h in (hf, had, he, hp, ho, hco): lib.xmx_buf_destroy(h)

    # numpy three-pass golden
    stem = (F.view(np.float16).astype(np.float32).reshape(M, 16)
            @ AD.view(np.float16).astype(np.float32).reshape(16, 32)).astype(np.float32)
    hid16 = np.asarray(NM.e4m3(stem), np.float16)                 # e4m3 ONLY (the .comp branch)
    exp = (hid16.astype(np.float32) @ E.view(np.float16).astype(np.float32).reshape(32, 128)).astype(np.float32)
    hid = np.asarray(NM.e4m3(NM.quadratic_gate_activation(exp)), np.float16)   # publish(3)
    proj = (hid.astype(np.float32) @ P.view(np.float16).astype(np.float32).reshape(128, 32)).astype(np.float32)
    # total = fma(stem_raw, cosine[col], proj) -- single fused rounding; exact in f64 (gap assert)
    prod64 = stem.astype(np.float64) * cosine.astype(np.float64)[None, :]
    st64 = proj.astype(np.float64)
    e_p = np.floor(np.log2(np.abs(prod64) + (prod64 == 0)))
    e_s = np.floor(np.log2(np.abs(st64) + (st64 == 0)))
    gap = np.abs(np.where(prod64 == 0, e_s, np.where(st64 == 0, e_p, e_p - e_s)))
    assert float(gap.max()) <= 18.0, f"{label}: f64 exponent gap {gap.max()} -- widen the band"
    total = (prod64 + st64).astype(np.float32)
    if epi == 1: v = NM.e4m3(total)
    elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(total))
    elif epi == 2: v = NM.quadratic_gate_activation(total)
    elif epi == 4: v = NM._half_rounded(total)
    else: v = total
    wantf = np.asarray(v, np.float32).reshape(M * 32)
    gv = got.view(np.float16).astype(np.float32) if narrow else got.view(np.float32)
    tol = np.maximum(np.abs(wantf) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(gv - wantf) > tol).sum())
    if nbad:
        e = int(np.flatnonzero(np.abs(gv - wantf) > tol)[0]); r, c = divmod(e, 32)
        ok(False, f"{label}: {nbad} bad; first ({r},{c}) got {gv[e]:.6g} want {wantf[e]:.6g}")
    else:
        ok(True, f"{label}: THREE-PASS WITHIN-ONE ({M} rows, flags=0x{flags:x})")

# captured form (flags=0: epi=0 f32-out) at shrunk M + the padded-M case + a narrow stress
run(256, 0x000, "STEM-256-f32out")
run(512, 0x000, "STEM-512-f32out")
run(192, 0x000, "STEM-192-paddedM")
run(64, 0x000, "STEM-64-f32out")
run(256, 0x1100, "STEM-256-narrow-epi1-stress")

print(f"\nFFN_STEM {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
