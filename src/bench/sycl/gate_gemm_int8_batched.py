#!/usr/bin/env python3
"""batched-int8 swap-in gate (route(a) step 3 #2, sections 71-73).

Layout pinned from gemm_staged_int8.comp:136-147 BEFORE writing the golden (the first
cut's golden used a different 2-D map and disagreed with the device exactly when strides
went NONZERO -- section 25: once both sides are checked against the .comp, the device was
right and the reference got fixed):

    A[r][k][g] = Araw[g*sa + r*lda + k]     (lda==0 -> K; sa==0 broadcasts A)
    B[n][k][g] = Braw[g*sb + n*ldb + k]     (ldb==0 -> K)
    C[r][c][g] = Cout[g*sc + r*ldc + c]     (ldc==0 -> N; sc ELEMENTS)
    a_scale index = g*scale_stride + r      (.comp roff)
    b_scale index = (sb!=0 ? g*N : 0) + c   (.comp soff)

The plan's own six variants (section 73) all use scale_stride=0 (one quantise pass for
the whole wide activation -- .comp:140-143's comment), sb = one whole weight block per
group, sc=N with ldc=batch*N (the groups' columns land side by side in one wide row),
and the A-sliced variants carry lda = batch*K (columns sliced). Variants below mirror
that structure with M shrunk -- this is a numerics/ABI gate, NOT a perf run (sections
58/69: frame time is only the user's, in LOP).
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
    ("xmx_rec_gemm_int8_batched", [ctypes.c_int] * 5 + [ctypes.c_uint] * 12),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def run(M, N, K, batch, sa, sb, sc, lda, ldb, ldc, scale_stride, flags, label):
    global fails
    epi = (flags >> 8) & 0xF
    lda_e = lda or K; ldb_e = ldb or K; ldc_e = ldc or N
    rng = np.random.default_rng(7170 + M + N * 3 + K * 5 + batch * 7 + sa + sb + sc)
    A_n = (batch - 1) * sa + (M - 1) * lda_e + K
    B_n = (batch - 1) * sb + (N - 1) * ldb_e + K
    C_n = (batch - 1) * sc + (M - 1) * ldc_e + N
    A = rng.integers(-127, 128, size=A_n, dtype=np.int8)
    Bt = rng.integers(-127, 128, size=B_n, dtype=np.int8)
    ascale = np.float32(1e-6) * (1 + rng.random((batch - 1) * scale_stride + M).astype(np.float32) * 3)
    bscale = np.float32(1e-6) * (1 + rng.random((batch - 1) * (N if sb else 0) + N).astype(np.float32) * 3)
    wsz = 2 if (flags & 0x1000) else 4

    ha = lib.xmx_buf_create_kind(A_n, 1); hb = lib.xmx_buf_create_kind(B_n, 1)
    hc = lib.xmx_buf_create_kind(C_n * wsz, wsz)
    has = lib.xmx_buf_create_kind(ascale.nbytes, 4)
    hbs = lib.xmx_buf_create_kind(bscale.nbytes, 4)
    if not (ha > 0 and hb > 0 and hc > 0 and has > 0 and hbs > 0):
        ok(False, f"{label}: buffers ({ha},{hb},{hc},{has},{hbs})"); return
    ok(lib.xmx_buf_upload(ha, np.ascontiguousarray(A).ctypes.data, 0, A_n) == 0, f"{label}: upload A")
    ok(lib.xmx_buf_upload(hb, np.ascontiguousarray(Bt).ctypes.data, 0, B_n) == 0, f"{label}: upload B")
    ok(lib.xmx_buf_upload(has, np.ascontiguousarray(ascale).ctypes.data, 0, ascale.nbytes) == 0, f"{label}: upload as")
    ok(lib.xmx_buf_upload(hbs, np.ascontiguousarray(bscale).ctypes.data, 0, bscale.nbytes) == 0, f"{label}: upload bs")
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_int8_batched(ha, hb, hc, has, hbs, M, N, K, batch, sa, sb, sc,
                                       lda, ldb, ldc, scale_stride, flags)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(C_n * wsz, np.uint8); lib.xmx_buf_download(hc, got.ctypes.data, 0, C_n * wsz)
    for h in (ha, hb, hc, has, hbs): lib.xmx_buf_destroy(h)

    # golden on the SAME flat map
    want = np.zeros(C_n, np.float32)
    for g in range(batch):
        Ag = np.array([[A[g * sa + r * lda_e + k] for k in range(K)] for r in range(M)])
        Bg = np.array([[Bt[g * sb + n * ldb_e + k] for k in range(K)] for n in range(N)])
        acc = (Ag.astype(np.int64) @ Bg.astype(np.int64).T).astype(np.float32)
        asg = ascale[g * scale_stride: g * scale_stride + M]
        v = (acc * asg[:, None]).astype(np.float32)
        bsg = bscale[g * N: g * N + N] if sb else bscale[:N]
        v = (v * bsg[None, :]).astype(np.float32)
        if epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(v))
        elif epi == 1: v = NM.e4m3(v)
        elif epi == 2: v = NM.quadratic_gate_activation(v)
        else: v = NM._half_rounded(v)
        for r in range(M):
            base = g * sc + r * ldc_e
            want[base: base + N] = v[r]
    wantb = (np.asarray(want, np.float16) if wsz == 2 else want).view(np.uint8)
    same = np.array_equal(got, wantb)
    nbad = int((got != wantb).sum())
    ok(same, f"{label}: OUT BITS EQUAL ({nbad} bad bytes of {C_n * wsz})")
    if not same:
        ge = got.view(np.uint16 if wsz == 2 else np.uint32)
        we = wantb.view(np.uint16 if wsz == 2 else np.uint32)
        bad_e = np.flatnonzero(ge != we)
        e = int(bad_e[0]); gg = r = c = None
        for x in range(batch):
            rel = e - x * sc
            if 0 <= rel < M * ldc_e and (rel % ldc_e) < N:
                gg, r, c = x, rel // ldc_e, rel % ldc_e; break
        print(f"      first bad elem {e} -> (g,r,c)=({gg},{r},{c}) got {ge[e]} want {we[e]}; total {len(bad_e)}")

# D1: batch=1 all-zero -- must equal the already-GREEN plain gemm_int8 (regression anchor)
run(128, 64, 64, 1, 0, 0, 0, 0, 0, 0, 0, 4352, "D1-batch1-eq-plain")
# P1 (plan v1 structure, M shrunk): broadcast A; two weight blocks; columns side by side
run(256, 128, 64, 2, 0, 8192, 128, 64, 64, 256, 0, 4864, "P1-broadcast-2blocks")
# P2 (plan v2 structure, M shrunk): A col-sliced lda=2K sa=K; N=32 -> gemm32 tail
run(256, 32, 128, 2, 128, 4096, 32, 256, 128, 64, 0, 4352, "P2-colsliced-A-N32")
# P3 (FRAME SHAPE #2, section 99): M=8160 N=128 K=128 b=4 sa=0 ldc=512 epi3 -- the
# v9b BN=512 branch, never gated before (the frame went 0% with BN=256 green).
run(8160, 128, 128, 4, 0, 16384, 128, 128, 128, 512, 0, 4864, "P3-frame-broadcast-4blocks")
# T1: batch=4 per-group row scales (scale_stride=M, an invented stress case)
run(128, 64, 32, 4, 0, 2048, 64, 0, 0, 256, 128, 4352, "T1-4group-scalestride")

print(f"\nGEMM_INT8_BATCHED {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
