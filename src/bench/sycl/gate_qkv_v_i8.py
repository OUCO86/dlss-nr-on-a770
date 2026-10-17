#!/usr/bin/env python3
"""Route-B block 3 gate (section 41): the QKV V branch with COLUMN quantization.

Why columns (section 38's nailed reason): attnV = P.V reduces over TOKENS, so a per-token
(row) scale on V would sit INSIDE the accumulation sum. A per-(window,channel) column
scale factors out cleanly. The seniors' e4m3 per-element container never had this; int8 does.

Chain: int8 GEMM -> dequantise (island-3, shipped left-to-right) -> column max across the
window's 64 token-rows (SLM atomic-fmax, the transposed v3 pattern) -> v3's requantize
contract (inv=127/cmax, rint, clip +-127, scale=cmax/127) -> int8 + column scale, scattered
to (window, head, token, 32).

Grid trick (test_gemm_int8_qkv.py:30): small integer operands x 2^-8 scales -> deq =
acc*2^-16 EXACT in f32 -> only the final requantize is lossy -> BOUNDED gate (within-one +
scale<=1ulp), same criteria as gate_gemm_s8rq / gate_cosine_i8 / gate_softmax_i8.
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
    ("xmx_rec_gemm_qkv_v_i8", [ctypes.c_int] * 6 + [ctypes.c_uint] * 4),
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

def run(windows, tokens, channels, label):
    global fails
    heads = channels // 32
    rows = windows * tokens
    assert rows % 128 == 0 and channels % 64 == 0 and tokens == 64
    rng = np.random.default_rng(1207 + rows + channels)
    a = rng.integers(-40, 41, size=(rows, channels)).astype(np.int8)
    b = rng.integers(-40, 41, size=(channels, channels)).astype(np.int8)
    a_scale = np.full(rows, STEP, np.float32)
    b_scale = (0.001 * (np.arange(channels) % 37 + 1)).astype(np.float32)

    ha = lib.xmx_buf_create(rows * channels); hb = lib.xmx_buf_create(channels * channels)
    hv8 = lib.xmx_buf_create_kind(rows * channels, 1)          # int8 out
    hvs = lib.xmx_buf_create_kind(windows * channels * 4, 4)   # column scale per (window,channel)
    has = lib.xmx_buf_create_kind(rows * 4, 4)
    hbs = lib.xmx_buf_create_kind(channels * 4, 4)
    ok(min(ha, hb, hv8, hvs, has, hbs) > 0, f"{label}: 6 buffers")
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, rows * channels)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, channels * channels)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hbs, b_scale.ctypes.data, 0, channels * 4)
    lib.xmx_buf_zero(hv8); lib.xmx_buf_zero(hvs)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_qkv_v_i8(ha, hb, hv8, hvs, has, hbs, rows, channels, heads, tokens)
    ok(rc == 0, f"{label}: rec_gemm_qkv_v_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * channels, np.int8); lib.xmx_buf_download(hv8, got.ctypes.data, 0, rows * channels)
    gvs = np.zeros(windows * channels, np.float32); lib.xmx_buf_download(hvs, gvs.ctypes.data, 0, windows * channels * 4)

    # reference: exact dequantise, then the COLUMN max over the window's token rows.
    acc = a.astype(np.int32) @ b.astype(np.int32)
    deq = (acc.astype(np.float32) * a_scale[:, None]).astype(np.float32) * b_scale[None, :]
    deq4 = deq.reshape(windows, tokens, channels)
    cmax = np.max(np.abs(deq4), axis=1)                       # (windows, channels)
    wns = (cmax / np.float32(127.0)).astype(np.float32)
    q = np.divide(deq4, wns[:, None, :], out=np.zeros_like(deq4, dtype=np.float64),
                  where=wns[:, None, :] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)     # (windows, tokens, channels)

    # scatter the reference into (window, head, token, 32) order and compare.
    wantlin = np.empty(rows * channels, np.int8)
    for w in range(windows):
        for t in range(tokens):
            for c in range(channels):
                at = ((w * heads + c // 32) * tokens + t) * 32 + (c % 32)
                wantlin[at] = want[w, t, c]
    gp = got.reshape(rows, channels)
    exact = np.array_equal(gp, wantlin.reshape(rows, channels))

    # within-one reconstruction: the int8 at each SCATTERED position, times that source
    # element's column scale, must land within half a step of deq. got is the scattered
    # buffer (window,head,token,32); un-scatter it back to (windows,tokens,channels) so
    # it lines up with deq element-for-element (reading the scattered buffer as row-major
    # would misalign every position -- that was the first run's 254-step artifact).
    got_flat = got.reshape(rows * channels)
    gu = np.empty((windows, tokens, channels), np.int8)
    for w in range(windows):
        for t in range(tokens):
            for c in range(channels):
                at = ((w * heads + c // 32) * tokens + t) * 32 + (c % 32)
                gu[w, t, c] = got_flat[at]
    cs = gvs.reshape(windows, channels)
    deq4 = deq.reshape(windows, tokens, channels)
    step = gu.astype(np.float64) * cs[:, None, :].astype(np.float64)
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - deq4.astype(np.float64)) <= np.maximum(cs[:, None, :].astype(np.float64), 1e-30) * limit
    sculp = int(np.abs(gvs.view(np.int32) - wns.ravel().view(np.int32)).max())
    worst = float(np.max(np.abs(step - deq4) / np.maximum(cs[:, None, :], 1e-30)))
    ok(bool(within.all()) and sculp <= 1,
       f"{label} {windows}x{tokens}x{channels}: within-one {bool(within.all())} (worst {worst:.5f} step), "
       f"col_scale<=1ulp (max {sculp}); bit-exact-vs-divide-form {exact} (tie diffs OK, section 25)")
    for h in (ha, hb, hv8, hvs, has, hbs): lib.xmx_buf_destroy(h)

run(2, 64, 64, "l2-v")       # 128 rows = 2 windows
run(2, 64, 256, "l1-v")      # 8 heads
run(2, 64, 512, "l0-v")      # 16 heads
run(4, 64, 128, "wide-v")    # 4 windows
run(16, 64, 64, "big-v")     # 1024 rows, R8a-legal big M

print(f"\nQKV_V_I8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
