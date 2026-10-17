#!/usr/bin/env python3
"""Route-B connective-tissue gate (section 42): int32 GEMM accumulator -> int8 + row scale.

The attention GEMMs whose N is not 64 (global scores 640x640x32, attnV 640x1024x640,
outproj) run on the general-N v1 int32 kernel (gated in gate_gemm_s8) and need THIS exit
pass to re-enter the int8 straight-through world. The v1 GEMM's correctness is already
proven separately (section 25: each segment gated on its own), so this gate feeds an int32
accumulator directly and checks only the dequantise + requantize.

Golden = gate_gemm_s8rq's EXACT v3 contract (NOT int8_quant.quantise -- that keeps scale=1.0
for a zero row; the v3 chain uses inv=0 -> out=0, scale=0, and the chain's requantize is the
v3 one):
  fp = float(acc) * a_scale[row] * b_scale[col]   (left-to-right, shipped dequantise)
  rmax = max|fp| over the row; ns = rmax/127
  want = clip(rint(fp/ns), -127, 127)             (divide-form reference)
Kernel uses the multiply-form (fp * 127/rmax); the two differ <=1 ULP at ties -> within-one
tolerates it (section 25: never chase the tie difference). Bounded gate: within-one + scale<=1ulp.

Grid trick: acc is an exact int32 (numpy a@b), scales 2^-8 -> fp exact in f32 -> only the
final requantize is lossy. Shapes = the global attention GEMMs' real N/K.
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
    ("xmx_rec_requant_i8", [ctypes.c_int] * 5 + [ctypes.c_uint] * 2),
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

def run(rows, cols, label):
    global fails
    rng = np.random.default_rng(313 + rows + cols)
    # an exact int32 accumulator (what the v1 GEMM produces; its correctness is gated in
    # gate_gemm_s8, so here we feed it directly and test only dequantise+requantize).
    acc = rng.integers(-200000, 200001, size=(rows, cols)).astype(np.int32)
    acc[0] = 0                                   # a zero row: the inv=0 / scale=0 path
    a_scale = np.full(rows, STEP, np.float32)
    b_scale = (0.001 * (np.arange(cols) % 37 + 1)).astype(np.float32)

    hacc = lib.xmx_buf_create_kind(rows * cols * 4, 4)
    has = lib.xmx_buf_create_kind(rows * 4, 4)
    hbs = lib.xmx_buf_create_kind(cols * 4, 4)
    ho = lib.xmx_buf_create_kind(rows * cols, 1)
    hs = lib.xmx_buf_create_kind(rows * 4, 4)
    ok(min(hacc, has, hbs, ho, hs) > 0, f"{label}: 5 buffers")
    lib.xmx_buf_upload(hacc, acc.ctypes.data, 0, rows * cols * 4)
    lib.xmx_buf_upload(has, a_scale.ctypes.data, 0, rows * 4)
    lib.xmx_buf_upload(hbs, b_scale.ctypes.data, 0, cols * 4)
    lib.xmx_buf_zero(ho); lib.xmx_buf_zero(hs)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_requant_i8(hacc, has, hbs, ho, hs, rows, cols)
    ok(rc == 0, f"{label}: rec_requant_i8" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(rows * cols, np.int8); lib.xmx_buf_download(ho, got.ctypes.data, 0, rows * cols)
    gns = np.zeros(rows, np.float32); lib.xmx_buf_download(hs, gns.ctypes.data, 0, rows * 4)

    f32 = np.float32
    fp = (acc.astype(f32) * a_scale.astype(f32)[:, None]).astype(f32) * b_scale.astype(f32)[None, :]
    rmax = np.max(np.abs(fp), axis=1)
    wns = (rmax / f32(127.0)).astype(f32)
    q = np.divide(fp, wns[:, None], out=np.zeros_like(fp, dtype=np.float64), where=wns[:, None] > 0)
    want = np.clip(np.rint(q), -127, 127).astype(np.int8)
    gp = got.reshape(rows, cols)
    step = gp.astype(np.float64) * gns.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - fp.astype(np.float64)) <= np.maximum(gns.astype(np.float64), 1e-30)[:, None] * limit
    sculp = int(np.abs(gns.view(np.int32) - wns.view(np.int32)).max())
    worst = float(np.max(np.abs(step - fp) / np.maximum(gns, 1e-30)[:, None]))
    ok(bool(within.all()) and sculp <= 1,
       f"{label} {rows}x{cols}: within-one {bool(within.all())} (worst {worst:.5f} step), "
       f"scale<=1ulp (max {sculp})")
    for h in (hacc, has, hbs, ho, hs): lib.xmx_buf_destroy(h)

# global attention's real GEMM N/K (the shapes the rq N==64 kernel cannot serve):
run(640, 640, "scores")        # QK^T: 640 tokens x 640 keys
run(640, 1024, "attnV")        # P.V: 640 tokens x 1024 channels
run(640, 1024, "outproj")      # attended -> out projection input
run(192, 192, "scores-192")    # a 1024x576 frame's global block
run(256, 256, "scores-256")    # 720p global block

print(f"\nREQUANT_I8 {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
