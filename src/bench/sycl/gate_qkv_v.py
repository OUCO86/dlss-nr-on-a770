#!/usr/bin/env python3
"""QKV V-branch fused epilogue gate (section 35).

The senior's grid trick from test_gemm_int8_qkv.py: operands are small integers and the
scales are 2^-8, so float(acc)*a_scale*b_scale is the EXACT product in float32 -- kernel
and reference see identical values, and the e4m3 publish chain becomes bit-exact gateable
(no new golden: e4m3 = nr_model.e4m3, already gated bit-exact in the PUBLISH gate).

V branch = int8 GEMM -> dequantise (island-3, two f32 multiplies left-to-right per
gemm_staged_int8.comp:210) -> e4m3 (island-4) -> scatter to (window, head, token, 32)
(qkv_epilogue.glsl:60-75). V skips the cosine normalise (epilogue:57); Q/K come next.
"""
import ctypes, os, pathlib, sys
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
    ("xmx_rec_gemm_qkv_v", [ctypes.c_int] * 5 + [ctypes.c_uint] * 4),
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

STEP = np.float32(2.0 ** -8)   # the grid: exact in f32 products (test_gemm_int8_qkv.py:30)

def run(windows, tokens, channels, label):
    global fails
    heads = channels // 32
    rows = windows * tokens
    assert rows % 128 == 0 and channels % 64 == 0
    rng = np.random.default_rng(7 + rows + channels)
    a = rng.integers(-40, 41, size=(rows, channels)).astype(np.int8)
    b = rng.integers(-40, 41, size=(channels, channels)).astype(np.int8)
    a_scale = np.full(rows, STEP, np.float32)
    b_scale = np.full(channels, STEP, np.float32)

    ha = lib.xmx_buf_create(rows * channels)
    hb = lib.xmx_buf_create(channels * channels)
    hv = lib.xmx_buf_create_kind(rows * channels * 2, 2)   # f16 out
    has = lib.xmx_buf_create_kind(rows * 4, 4)
    hbs = lib.xmx_buf_create_kind(channels * 4, 4)
    ok(min(ha, hb, hv, has, hbs) > 0, f"{label}: 5 buffers")
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, rows * channels)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hbs, b_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_zero(hv)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_qkv_v(ha, hb, hv, has, hbs, rows, channels, heads, tokens)
    ok(rc == 0, f"{label}: rec_gemm_qkv_v" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * channels, np.float16)
    lib.xmx_buf_download(hv, got.ctypes.data, 0, rows * channels * 2)

    # reference: exact dequantise (int acc * 2^-16, both multiplies exact on this grid)
    # -> e4m3 -> the (window,head,token,32) scatter, epilogue :60-75's at formula.
    acc = a.astype(np.int32) @ b.astype(np.int32)
    deq = (acc.astype(np.float32) * STEP).astype(np.float32) * STEP   # left-to-right, both exact
    vals = NM.e4m3(deq.ravel())
    want = np.empty(rows * channels, np.float16)
    for r in range(rows):
        window, token = r // tokens, r % tokens
        for c in range(channels):
            head, chan = c // 32, c % 32
            at = ((window * heads + head) * tokens + token) * 32 + chan
            want[at] = np.float16(vals[r * channels + c])
    exact = np.array_equal(got.view(np.uint16), want.view(np.uint16))
    if not exact:
        d = np.nonzero(got.view(np.uint16) != want.view(np.uint16))[0]
        print(f"        nbad={d.size} first idx={int(d[0])}: got {got[d[0]]} want {want[d[0]]}")
    ok(exact, f"{label} {windows}x{tokens}x{channels}: V epilogue BIT-EXACT vs e4m3+scatter ({int((got.view(np.uint16)!=want.view(np.uint16)).sum()) if not exact else 0} differ)")
    for h in (ha, hb, hv, has, hbs): lib.xmx_buf_destroy(h)

# QKV geometries (V part only) at the v1 geometry's granularity: M = rows % 128 == 0.
# R8a: the frame's small-M QKV instances (64/96/160/192 rows) are megakernel STAGES in the
# healthy chain, never standalone dispatches -- the standalone path gate covers the big-M
# forms (l2/l1/l0 blocks at 128-row granularity) that the megakernel's GEMM stage becomes.
run(2, 64, 64, "l2-qkv")      # 128 rows, 2 heads
run(2, 64, 256, "l1-qkv")     # 128 rows, 8 heads
run(2, 64, 512, "l0-qkv")     # 128 rows, 16 heads
run(4, 64, 128, "wide-qkv")   # 256 rows, 4 heads
run(8, 128, 64, "big-qkv")    # 1024 rows, 2 heads (R8a-legal big M)

# the guard: M % 64 != 0 must be refused, not silently wrong (R8a shapes come later via
# the megakernel; the standalone kernel tiles at BM=64).
print()
rows, channels = 96, 1024
a = np.zeros((rows, channels), np.int8); b = np.zeros((channels, channels), np.int8)
s = np.full(rows, STEP, np.float32)
ha = lib.xmx_buf_create(rows * channels); hb = lib.xmx_buf_create(channels * channels)
hv = lib.xmx_buf_create_kind(rows * channels * 2, 2); has = lib.xmx_buf_create_kind(rows * 4, 4)
hbs = lib.xmx_buf_create_kind(channels * 4, 4)
lib.xmx_begin()
rc = lib.xmx_rec_gemm_qkv_v(ha, hb, hv, has, hbs, rows, channels, 32, 96)
ok(rc != 0, f"guard: M=96 not 0 mod 64 refused (rc={rc}, err={lib.xmx_error().decode(errors='replace')[:60]})")
lib.xmx_abort()
for h in (ha, hb, hv, has, hbs): lib.xmx_buf_destroy(h)

# ---- identity diagnosis (--diag): B = identity, scales = 1.0, A = multiples of 4
# (exact through e4m3). Then deq[r,c] = a[r,c] EXACTLY: any mismatch is a GEMM-layout or
# scatter-index bug, never a rounding one. For each bad at, list which (r,c) could have
# produced the value the kernel actually put there -- the candidate-at set reveals the
# permutation the kernel applied.
def diag_identity(windows, tokens, channels, label):
    global fails
    heads = channels // 32
    rows = windows * tokens
    a = np.array([(((r * 3 + c) % 9) * 4 - 16) for r in range(rows) for c in range(channels)],
                 dtype=np.int8).reshape(rows, channels)
    b = np.eye(channels, dtype=np.int8)
    a_scale = np.ones(rows, np.float32)
    b_scale = np.ones(channels, np.float32)
    ha = lib.xmx_buf_create(rows * channels); hb = lib.xmx_buf_create(channels * channels)
    hv = lib.xmx_buf_create_kind(rows * channels * 2, 2)
    has = lib.xmx_buf_create_kind(rows * 4, 4); hbs = lib.xmx_buf_create_kind(channels * 4, 4)
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, rows * channels)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hbs, b_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_zero(hv)
    lib.xmx_begin()
    lib.xmx_rec_gemm_qkv_v(ha, hb, hv, has, hbs, rows, channels, heads, tokens)
    rc = lib.xmx_submit()
    ok(rc == 0, f"diag {label}: submit")
    got = np.zeros(rows * channels, np.float16)
    lib.xmx_buf_download(hv, got.ctypes.data, 0, rows * channels * 2)
    want = np.zeros(rows * channels, np.float16)
    atof = {}
    for r in range(rows):
        w_, t_ = r // tokens, r % tokens
        for c in range(channels):
            h_, ch_ = c // 32, c % 32
            at = ((w_ * heads + h_) * tokens + t_) * 32 + ch_
            want[at] = np.float16(int(a[r, c]))
            atof.setdefault(int(a[r, c]), []).append(at)
    bad = np.nonzero(got.view(np.uint16) != want.view(np.uint16))[0]
    print(f"diag {label} {windows}x{tokens}x{channels}: nbad={bad.size}/{rows*channels}")
    # full row dump: window=1, token=1 (rowA=65) -- 64 values got vs want, plus a[r,c]
    if rows > tokens:
        w_, t_ = 1, 1
        row = []
        for c_ in range(channels):
            h_, ch_ = c_ // 32, c_ % 32
            at = ((w_ * heads + h_) * tokens + t_) * 32 + ch_
            row.append((int(a[w_ * tokens + t_, c_]), int(got[at]), int(want[at])))
        print("  row65 (a, got, want):")
        for seg in range(0, channels, 16):
            print("   ", [f"{x}/{y}/{z}" for x, y, z in row[seg:seg+16]])
    for at in list(bad)[:6]:
        g = int(got[at])
        cands = atof.get(g, [])[:6]
        print(f"  at={at}: got {g} want {int(want[at])}  value {g} lives at r,c where scatter-at in {cands}")
    for h in (ha, hb, hv, has, hbs): lib.xmx_buf_destroy(h)

if "--diag" in sys.argv:
    diag_identity(2, 64, 64, "l2")
    diag_identity(1, 128, 64, "one-window-128rows")
    print(f"\nDIAG done ({fails} fails)")
    sys.exit(0)

print(f"\nQKV_V {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
