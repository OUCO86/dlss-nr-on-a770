#!/usr/bin/env python3
"""ffn swap-in gate (route(a) step 3 #12, section 88 route).

The fused feed-forward is composed from the two green f16 legs. ffn_fused.comp's header
says it is "Bit-identical to the two GEMMs by construction", and test_ffn_fused.py:65-69
is the shipping witness for the decomposition (pinned in the recorder comment first):
    pass 1 (expand):  gemm(a, expand -> hidden16, M, hidden, cin, epi=GATE_E4M3, narrow)
    pass 2 (project): gemm_residual(hidden16, projection, skip, cosine -> out, epi, narrow, skip_half)

PRIMARY criterion = BYTE-EQUAL between my composed xmx_rec_ffn and my OWN two-leg
decomposition (xmx_rec_gemm + xmx_rec_gemm_residual, both already gated -- section 82 and
the section-88 f16-residual gate). This is exactly test_ffn_fused's want-vs-got shape, and
it is the honest thing to check for a COMPOSITION recorder: the composition's whole job is
to reproduce the decomposition it replaces, so the two must agree bit for bit (same f16v1
legs, same pack, same publish, same fma). A within-one-vs-numpy check would only re-test
the legs (already gated) and would be polluted by the hidden16 e4m3-boundary flip the
projection amplifies -- which is a LEG property, not a composition bug.

SECONDARY anchor = the decomposition vs a numpy two-pass golden, WITHIN-ONE (the legs'
own criterion, inherited). Kept small so the gate still catches a gross composition error
that byte-equality against the decomposition would miss (e.g. wrong operand wiring that
happens to match a wrong decomposition -- impossible here since the decomposition is the
numpy-anchored one, but the belt is cheap).

captured ffn (section 88's plan dump): 8 calls, ALL groups==1, cin==32, hidden==128,
M=130560, flags in {0x40000 half-skip f32-out, 0x0 f32-skip f32-out}, epi=0. M shrunk for
CI (256/512) keeping cin/hidden/groups/flags exact.
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
    ("xmx_rec_ffn", [ctypes.c_int] * 6 + [ctypes.c_uint] * 5),
    ("xmx_rec_gemm", [ctypes.c_int] * 3 + [ctypes.c_uint] * 14),
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

def run(M, cin, hidden, groups, flags, label):
    global fails
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    half_skip = bool(flags & 0x40000)
    wsz = 2 if narrow else 4
    rng = np.random.default_rng(88120 + M + cin * 3 + hidden * 5 + groups * 7 + flags)
    # f16 inputs in O(1) (the real activation regime); expand/projection weights small.
    A = rng.uniform(-1, 1, size=M * cin).astype(np.float16)
    E = rng.uniform(-0.25, 0.25, size=cin * hidden).astype(np.float16)
    P = rng.uniform(-0.1, 0.1, size=hidden * cin).astype(np.float16)
    sgns = rng.choice(np.float32([-1.0, 1.0]), size=M * cin)
    if half_skip:
        skip = np.asarray(sgns * rng.uniform(0.4, 1.0, size=M * cin).astype(np.float32), np.float16)
    else:
        skip = (sgns * rng.uniform(0.4, 1.0, size=M * cin).astype(np.float32)).astype(np.float32)
    cosine = (rng.uniform(0.4, 1.0, size=cin).astype(np.float32)
              * rng.choice(np.float32([-1.0, 1.0]), size=cin)).astype(np.float32)

    ha = lib.xmx_buf_create_kind(M * cin * 2, 2)
    he = lib.xmx_buf_create_kind(cin * hidden * 2, 2)
    hp = lib.xmx_buf_create_kind(hidden * cin * 2, 2)
    hh = lib.xmx_buf_create_kind(M * hidden * 2, 2)          # hidden16 (f16, always narrow)
    hsk = lib.xmx_buf_create_kind(M * cin * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(cin * 4, 4)
    hgot = lib.xmx_buf_create_kind(M * cin * wsz, wsz)
    hwant = lib.xmx_buf_create_kind(M * cin * wsz, wsz)
    ok(min(ha, he, hp, hh, hsk, hco, hgot, hwant) > 0, f"{label}: buffers")
    up(ha, A); up(he, E); up(hp, P); up(hsk, skip); up(hco, cosine)

    # ---- GOT: the composed ffn recorder (one plan step) ----
    lib.xmx_buf_zero(hgot)
    ok(lib.xmx_begin() == 0, f"{label}: begin(ffn)")
    rc = lib.xmx_rec_ffn(ha, he, hp, hgot, hsk, hco, M, cin, hidden, groups, flags)
    ok(rc == 0, f"{label}: rec_ffn" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(ffn)")

    # ---- WANT: my two green legs, decomposed exactly as test_ffn_fused does ----
    lib.xmx_buf_zero(hh); lib.xmx_buf_zero(hwant)
    ok(lib.xmx_begin() == 0, f"{label}: begin(decomp)")
    # expand: epi=3 (GATE_E4M3) + narrow (0x1000), transposed bit 0, batch=1 dense
    rc1 = lib.xmx_rec_gemm(ha, he, hh, M, hidden, cin, 1, 0, 0, 0, (3 << 8) | 0x1000, 0, 0, 0, 0, 0, 0)
    ok(rc1 == 0, f"{label}: rec_gemm(expand)" + ("" if rc1 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    # projection: gemm_residual(hidden16, P, out, skip, cosine, M, cin, hidden, flags)
    rc2 = lib.xmx_rec_gemm_residual(hh, hp, hwant, hsk, hco, M, cin, hidden, flags)
    ok(rc2 == 0, f"{label}: rec_gemm_residual(project)" + ("" if rc2 == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit(decomp)")

    g = np.zeros(M * cin * wsz, np.uint8); lib.xmx_buf_download(hgot, g.ctypes.data, 0, M * cin * wsz)
    w = np.zeros(M * cin * wsz, np.uint8); lib.xmx_buf_download(hwant, w.ctypes.data, 0, M * cin * wsz)
    for h in (ha, he, hp, hh, hsk, hco, hgot, hwant): lib.xmx_buf_destroy(h)

    # PRIMARY: composed == decomposition, byte for byte.
    same = np.array_equal(g, w)
    if not same:
        d = np.flatnonzero(g != w); e = int(d[0]); r, c = divmod(e, cin)
        ok(False, f"{label}: {d.size} bytes differ from the decomposition; first ({r},{c}) "
                  f"got 0x{g[e]:02x} want 0x{w[e]:02x}")
    else:
        ok(True, f"{label}: COMPOSITION == DECOMPOSITION, OUT BITS EQUAL "
                 f"({M}x{cin}x{hidden} groups={groups} flags=0x{flags:x})")

    # SECONDARY anchor: the decomposition vs a numpy two-pass golden, WITHIN-ONE.
    acc1 = (A.view(np.float16).astype(np.float32).reshape(M, cin)
            @ E.view(np.float16).astype(np.float32).reshape(cin, hidden)).astype(np.float32)
    hid = np.asarray(NM.e4m3(NM.quadratic_gate_activation(acc1)), np.float16)   # publish(3)
    acc2 = (hid.astype(np.float32) @ P.view(np.float16).astype(np.float32).reshape(hidden, cin)).astype(np.float32)
    sk = skip.view(np.float16).astype(np.float32) if half_skip else skip.astype(np.float32)
    total = (acc2 + sk.reshape(M, cin) * cosine.astype(np.float32)[None, :]).astype(np.float32)
    if epi == 1: v = NM.e4m3(total)
    elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(total))
    elif epi == 2: v = NM.quadratic_gate_activation(total)
    elif epi == 4: v = NM._half_rounded(total)
    else: v = total
    wantf = np.asarray(v, np.float32 if not narrow else np.float16).reshape(M * cin)
    gv = g.view(np.float16).astype(np.float32) if narrow else g.view(np.float32)
    tol = np.maximum(np.abs(wantf) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(gv - wantf) > tol).sum())
    ok(nbad == 0, f"{label}: numpy two-pass WITHIN-ONE anchor ({nbad} bad)")

# captured ffn families (section 88's plan dump), M shrunk for CI, cin/hidden/groups/flags exact
run(256, 32, 128, 1, 0x40000, "FFN-256-halfskip-f32out")     # the dominant captured form
run(256, 32, 128, 1, 0x00000, "FFN-256-f32skip-f32out")
run(512, 32, 128, 1, 0x40000, "FFN-512-halfskip-f32out")
run(192, 32, 128, 1, 0x41100, "FFN-192-narrow-epi1-halfskip")  # narrow+epi1 stress (not captured)
run(64, 32, 128, 1, 0x40000, "FFN-64-halfskip-f32out")

print(f"\nFFN {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
