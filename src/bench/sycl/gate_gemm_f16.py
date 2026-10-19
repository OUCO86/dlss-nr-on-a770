#!/usr/bin/env python3
"""fp16 gemm swap-in gate (route(a) step 3 #8, section 82).

The LAST undisputed family (42 captured calls). Math pinned from gemm_staged.comp:14-18
+ the epilogue tail BEFORE writing (section 73's discipline):
    per group g: A[r][k] = Araw[oa + g*sa + r*lda + k]   (lda==0 -> K; sa/sb/sc ELEMENTS
                 -- .comp:14 `ao = batch*pc.sa` with no /16, unlike the int8 push)
               B[k][j] = Braw[ob + g*sb + k*ldb + j]   (ldb==0 -> N; transposed bit 0 in
                 EVERY captured call, so B is (K,N) row-major -- matches f16v1 pack_b)
               C[r][j] = Cout[oc + g*sc + r*ldc + j]   (ldc==0 -> N)
    out = publish(epi, acc) -> half iff 0x1000 else f32 (epi = bt>>8 & 0xF).
captured bt in {4352=epi1+narrow, 4608=epi2+narrow, 0=f32}; batch in {1,8}; the batched
families carry lda = batch*K (A column-sliced) and ldc = batch*N (outputs side by side).

Golden = numpy f32 dot product, WITHIN-ONE (section 81: the K-accumulation order is
hardware-defined; inputs are exact halves so the f32 sum error is tiny -- the tile probe
measured maxrel 1.6e-5). NOT bit-equal: the senior's own coopmat golden (test_gemm_qkv.py)
is the shipping rt.gemm, and a bit-exact-vs-coopmat check is the section-51 pairing, not
this numerics gate.

Variants mirror the plan's real structure (section 82's dump), M shrunk for CI but lda
column-slicing + both epilogues + padded-M kept.
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
    ("xmx_rec_gemm", [ctypes.c_int] * 3 + [ctypes.c_uint] * 14),
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

def run(M, N, K, batch, sa, sb, sc, bt, lda, ldb, ldc, oa, ob, oc, label):
    global fails
    epi = (bt >> 8) & 0xF
    narrow = bool(bt & 0x1000)
    lda_e = lda or K; ldb_e = ldb or N; ldc_e = ldc or N
    rng = np.random.default_rng(8280 + M + N * 3 + K * 5 + batch * 7 + bt + lda + ldc)
    A_n = oa + (batch - 1) * sa + (M - 1) * lda_e + K
    B_n = ob + (batch - 1) * sb + (K - 1) * ldb_e + N
    C_n = oc + (batch - 1) * sc + (M - 1) * ldc_e + N
    A = rng.uniform(-1, 1, size=A_n).astype(np.float16)
    B = rng.uniform(-1, 1, size=B_n).astype(np.float16)
    wsz = 2 if narrow else 4
    ha = lib.xmx_buf_create_kind(A_n * 2, 2); hb = lib.xmx_buf_create_kind(B_n * 2, 2)
    hc = lib.xmx_buf_create_kind(C_n * wsz, wsz)
    ok(min(ha, hb, hc) > 0, f"{label}: buffers")
    up(ha, A); up(hb, B)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm(ha, hb, hc, M, N, K, batch, sa, sb, sc, bt, lda, ldb, ldc, oa, ob, oc)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(C_n * wsz, np.uint8); lib.xmx_buf_download(hc, got.ctypes.data, 0, C_n * wsz)
    for h in (ha, hb, hc): lib.xmx_buf_destroy(h)

    # golden: numpy f32 dot per group, same flat map, then publish.
    want = np.zeros(C_n, np.float32)
    for g in range(batch):
        Ag = np.array([[float(A[oa + g * sa + r * lda_e + k]) for k in range(K)] for r in range(M)])
        # B is (K,N) row-major: B[k][j] = B[k*ldb_e + j]. Outer loop k (K rows), inner j.
        Bg = np.array([[float(B[ob + g * sb + k * ldb_e + j]) for j in range(N)] for k in range(K)])
        acc = (Ag.astype(np.float32) @ Bg.astype(np.float32)).astype(np.float32)
        if epi == 1: v = NM.e4m3(acc)
        elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(acc))
        elif epi == 2: v = NM.quadratic_gate_activation(acc)
        elif epi == 4: v = NM._half_rounded(acc)
        else: v = acc
        for r in range(M):
            base = oc + g * sc + r * ldc_e
            want[base: base + N] = v[r]
    # SECTION 25's correct split: the GEMM's job is the f32 accumulator; the publish chain
    # is ALREADY bit-exact-gated (PUBLISH gate). So the gemm criterion is acc within-one,
    # measured on the f32-out path (bt=0), NOT on the published bits -- a 1-ULP f32
    # accumulation-order difference (hardware-defined, section 81) legitimately lands on
    # the far side of an e4m3/gate rounding boundary and shows as 1-2 half-ulp there.
    # For a narrow variant we ALSO re-run with bt=0 and check the device's own published
    # output equals publish(epi, device_acc) -- self-consistency of the two legs, with the
    # publish leg's correctness inherited from its own gate.
    gv = got.view(np.float16).astype(np.float32) if narrow else got.view(np.float32)
    if not narrow:
        wv = want.astype(np.float32)
        tol = np.maximum(np.abs(wv) * 2.0 ** -10, 2.0 ** -13)
        nbad = int((np.abs(gv - wv) > tol).sum())
        ok(nbad == 0, f"{label}: ACC WITHIN-ONE ({M}x{N}x{K} batch={batch} bt=0x{bt:x})"
                      + ("" if nbad == 0 else f" ({nbad} bad)"))
        return
    # narrow: run the SAME operands with bt=0 to get the device's raw f32 acc
    ha2 = lib.xmx_buf_create_kind(A_n * 2, 2); hb2 = lib.xmx_buf_create_kind(B_n * 2, 2)
    hc2 = lib.xmx_buf_create_kind(C_n * 4, 4)
    up(ha2, A); up(hb2, B); lib.xmx_buf_zero(hc2)
    lib.xmx_begin()
    assert lib.xmx_rec_gemm(ha2, hb2, hc2, M, N, K, batch, sa, sb, sc, 0, lda, ldb, ldc, oa, ob, oc) == 0
    assert lib.xmx_submit() == 0
    accf = np.zeros(C_n * 4, np.uint8); lib.xmx_buf_download(hc2, accf.ctypes.data, 0, C_n * 4)
    for h in (ha2, hb2, hc2): lib.xmx_buf_destroy(h)
    acc = accf.view(np.float32)
    # (a) device acc within-one vs numpy acc
    wacc = np.zeros(C_n, np.float32)
    for g2 in range(batch):
        Ag = np.array([[float(A[oa + g2 * sa + r * lda_e + k]) for k in range(K)] for r in range(M)])
        Bg = np.array([[float(B[ob + g2 * sb + k * ldb_e + j]) for j in range(N)] for k in range(K)])
        a2 = (Ag.astype(np.float32) @ Bg.astype(np.float32)).astype(np.float32)
        for r in range(M):
            base = oc + g2 * sc + r * ldc_e
            wacc[base: base + N] = a2[r]
    tol = np.maximum(np.abs(wacc) * 2.0 ** -10, 2.0 ** -13)
    nbad = int((np.abs(acc - wacc) > tol).sum())
    # (b) published == publish(epi, device acc) (the publish leg, gated separately)
    if epi == 1: pub = NM.e4m3(acc)
    elif epi == 3: pub = NM.e4m3(NM.quadratic_gate_activation(acc))
    elif epi == 2: pub = NM.quadratic_gate_activation(acc)
    elif epi == 4: pub = NM._half_rounded(acc)
    else: pub = acc
    wantb = np.asarray(pub, np.float16).view(np.uint8)
    # SIGNED-ZERO carve-out (section 82, measured): in the gate's clamp-saturated region
    # (|acc| > 4) the linear term collapses to +0.0 (IEEE: x + (-x) = +0.0) and the final
    # wide * +0.0 is -0.0 in numpy but +0.0 from the device's fmul_rn -- a compiler
    # signed-zero difference, NUMERICALLY IRRELEVANT (+0.0 == -0.0, every downstream read
    # treats both as zero). The PUBLISH gate never saw it because np.array_equal uses ==
    # (which equates them); this gate's byte compare did. Accept byte-equal OR both-zero.
    # compare at the HALF level (both are M*N uint16): byte-equal OR both-zero-magnitude
    # (a half is +/-0.0 iff its low 15 bits are 0; +0.0=0x0000, -0.0=0x8000).
    gh = got.view(np.uint16); wh = wantb.view(np.uint16)
    gz = (gh & 0x7FFF) == 0; wz = (wh & 0x7FFF) == 0
    sameb = bool(((gh == wh) | (gz & wz)).all())
    ok(nbad == 0 and sameb, f"{label}: ACC WITHIN-ONE ({nbad} bad) + PUBLISH self-consistent "
                            f"({sameb}) ({M}x{N}x{K} batch={batch} bt=0x{bt:x})")

# single-batch families (the plan's real N/K, M shrunk; padded-M kept on the 192 case)
run(192, 512, 1024, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "G1-192x512x1024-f32out")   # epi0, padded M
run(640, 256, 64, 1, 0, 0, 0, 4352, 0, 0, 0, 0, 0, 0, "G2-640x256x64-epi1")
run(640, 256, 64, 1, 0, 0, 0, 4608, 0, 0, 0, 0, 0, 0, "G3-640x256x64-epi2")
# batched families: lda = batch*K column-slice, ldc = batch*N side-by-side (plan structure)
run(256, 32, 128, 8, 128, 4096, 32, 4352, 1024, 0, 256, 0, 0, 0, "G4-batched8-lda1024")
run(256, 256, 64, 8, 64, 16384, 256, 4608, 0, 0, 2048, 0, 0, 0, "G5-batched8-epi2")

print(f"\nGEMM_F16 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
