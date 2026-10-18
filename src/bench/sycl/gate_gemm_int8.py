#!/usr/bin/env python3
"""gemm_int8 swap-in gate (route(a) step 3 #1, section 71): the two REAL plan families --
  (640, 512, 512, flags=4352)  epilogue 1 = e4m3, narrow half out
  (192, 4096, 1024, flags=4864) epilogue 3 = gate THEN e4m3, narrow half out
(M=192 exercises the padded-BM path: rows 192..255 exist only inside the kernel.)
Golden = the shipping numpy authorities (nr_model.e4m3 :196 / quadratic_gate_activation
:173 -- the same functions the PUBLISH gate proved our qr_publish bit-exact against),
and the float32 multiply chain (acc -> *a_scale[row] -> *b_scale[col], left-to-right,
each rounded to f32) written in numpy float32 so the bits match cr_mul exactly.
Criterion: f16 OUT BITS EQUAL (the publish-family gates' 0-differ standard, not bounded).
B is fed TRANSPOSED (N x K row-major) -- the shipped operand form (libxmx.c:2877).
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
    ("xmx_rec_gemm_int8", [ctypes.c_int] * 5 + [ctypes.c_uint] * 4),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def run(M, N, K, flags, label):
    global fails
    epi = (flags >> 8) & 0xF
    rng = np.random.default_rng(5150 + M * 7 + N + K * 13)
    A = rng.integers(-127, 128, size=(M, K), dtype=np.int8)
    Bt = rng.integers(-127, 128, size=(N, K), dtype=np.int8)     # TRANSPOSED storage (N x K)
    # f32 scales chosen so published values live in the e4m3 sweet spot with some
    # clamp-side traffic for the gate (epi=3): |acc| ~ up to K*127^2/3.
    ascale = np.float32(1e-6) * (1 + rng.random(M).astype(np.float32) * 3.0)
    bscale = np.float32(1e-6) * (1 + rng.random(N).astype(np.float32) * 3.0)

    ha = lib.xmx_buf_create_kind(M * K, 1)
    hb = lib.xmx_buf_create_kind(N * K, 1)
    hc = lib.xmx_buf_create_kind(M * N * 2, 2)     # half out (narrow, 0x1000 set)
    has = lib.xmx_buf_create_kind(M * 4, 4)
    hbs = lib.xmx_buf_create_kind(N * 4, 4)
    ok(min(ha, hb, hc, has, hbs) > 0, f"{label}: buffers")
    lib.xmx_buf_upload(ha, np.ascontiguousarray(A).ctypes.data, 0, M * K)
    lib.xmx_buf_upload(hb, np.ascontiguousarray(Bt).ctypes.data, 0, N * K)
    lib.xmx_buf_upload(has, np.ascontiguousarray(ascale).ctypes.data, 0, M * 4)
    lib.xmx_buf_upload(hbs, np.ascontiguousarray(bscale).ctypes.data, 0, N * 4)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_int8(ha, hb, hc, has, hbs, M, N, K, flags)
    ok(rc == 0, f"{label}: rec_gemm_int8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit" + ("" if rc == 0 else ""))
    got = np.zeros(M * N * 2, np.uint8)
    lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N * 2)
    for h in (ha, hb, hc, has, hbs): lib.xmx_buf_destroy(h)

    # golden: exact int32 acc, then the SAME f32 chain and the shipping publish.
    acc = A.astype(np.int64) @ Bt.astype(np.int64).T
    assert np.abs(acc).max() < 2**31, "int32 range"
    v = acc.astype(np.float32)
    v = (v * ascale[:, None]).astype(np.float32)          # cr_mul #1 (f32-rounded)
    v = (v * bscale[None, :]).astype(np.float32)          # cr_mul #2
    if epi == 3:
        v = NM.quadratic_gate_activation(v)
        v = NM.e4m3(v)
    elif epi == 1:
        v = NM.e4m3(v)
    elif epi == 2:
        v = NM.quadratic_gate_activation(v)
    else:
        v = NM._half_rounded(v)
    want = np.asarray(v, np.float16).view(np.uint8).reshape(M * N * 2)
    g = got.reshape(M, N * 2); w = want.reshape(M, N * 2)
    same = np.array_equal(g, w)
    nbad = int((g != w).sum())
    detail = ""
    if not same:
        i, j = np.unravel_index(int(np.argmax(g != w)), g.shape)
        gv = got.reshape(M, N).view(np.uint16)[i, j // 2 * 0 + 0] if False else None
        go = np.frombuffer(got[i * N * 2:(i + 1) * N * 2], np.float16)[j // 2]
        wo = np.frombuffer(want[i * N * 2:(i + 1) * N * 2], np.float16)[j // 2]
        detail = f"; first bad ({i},{j}): got {go} want {wo}"
    ok(same, f"{label} M={M} N={N} K={K} flags={flags} (epi={epi}, narrow): f16 OUT BITS EQUAL "
             f"({nbad} bad bytes of {M * N * 2}{detail})")

run(640, 512, 512, 4352, "planA-640x512x512-e4m3")
run(192, 4096, 1024, 4864, "planB-192x4096x1024-gate")
# one wide-M sanity (the padded tail on an exact multiple stays byte-identical too)
run(128, 64, 32, 4352, "tiny-128x64x32")

print(f"\nGEMM_INT8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
