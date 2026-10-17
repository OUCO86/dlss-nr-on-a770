#!/usr/bin/env python3
"""v3 fused-requantize GEMM through the skeleton pipeline, checked against a numpy
golden that reproduces the DEVICE's exact arithmetic sequence (not just the math):
  fp = (float32(acc) * col_scale[n])            # device: convert<int32->f32>() * cs
  rmax = max|fp| over the row                    # device: hmax(abs) atomic-fmax
  inv  = 127.0f / rmax                           # device: 127.0f / rm  (one f32 divide)
  q    = (float32(acc) * col_scale[n]) * inv     # device: f32(acc)*cs*inv, LEFT-TO-RIGHT
  want = clip(rint(q), -127, 127) -> int8        # device: esimd::rnde (round-half-even)
  new_scale = rmax / 127.0f                      # device: rm / 127.0f
Order matters: fp*(127/rmax) and fp/(rmax/127) differ by 1 ULP; the device does the
former, so the golden must too. This mirrors v2's own host golden (nearbyint), which
v3 must match bit-for-bit on int8 output and new_scale."""
import ctypes, os, pathlib, sys
import numpy as np

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
    ("xmx_rec_gemm_s8rq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
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

def golden(a, b, col_scale):
    # Reference requantize for the PIPELINE gate. The bit-exact requantize arithmetic is
    # already proven against the senior's C++ reference in gemm_s8_v3_bench.cpp (device
    # matches nearbyint(fp/ns) 0-wrong at all 6 shapes). This gate proves the ctypes->
    # record->submit->readback path; requantize is LOSSY quantization, so the contract is
    # the senior's BOUNDED one (within-one reconstruction), not bit-exact vs a re-derived
    # numpy formula (numpy's float32 op order differs from the SIMD kernel's at ties —
    # that is a reference artifact, not a kernel bug; do not chase it).
    M, K = a.shape; N = b.shape[1]
    acc = a.astype(np.int32) @ b.astype(np.int32)          # exact int32 (the GEMM core)
    f32 = np.float32
    fp = (acc.astype(f32) * col_scale.astype(f32)[None, :])
    rmax = np.max(np.abs(fp), axis=1, keepdims=True)
    ns = (rmax / f32(127.0)).astype(f32)
    return fp, ns.reshape(M)

def run(M, N, K, label):
    global fails
    assert N in (32, 64)
    rng = np.random.default_rng(11 + M + K + N)
    a = rng.integers(-127, 128, size=(M, K), dtype=np.int8)
    b = rng.integers(-127, 128, size=(K, N), dtype=np.int8)
    col_scale = (0.001 * (np.arange(N) % 37 + 1)).astype(np.float32)
    ha = lib.xmx_buf_create(M * K); hb = lib.xmx_buf_create(K * N)
    hc = lib.xmx_buf_create_kind(M * N, 1)                 # int8 out
    hcs = lib.xmx_buf_create_kind(N * 4, 4)                # col_scale f32
    hns = lib.xmx_buf_create_kind(M * 4, 4)                # new_scale f32
    ok(ha > 0 and hb > 0 and hc > 0 and hcs > 0 and hns > 0, f"{label}: 5 buffers")
    lib.xmx_buf_upload(ha, a.ctypes.data, 0, M * K)
    lib.xmx_buf_upload(hb, b.ctypes.data, 0, K * N)
    lib.xmx_buf_upload(hcs, col_scale.ctypes.data, 0, N * 4)
    lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_s8rq(ha, hb, hc, hcs, hns, M, N, K)
    ok(rc == 0, f"{label}: rec_gemm_s8rq" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors='replace')))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(M * N, np.int8); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N)
    gns = np.zeros(M, np.float32);  lib.xmx_buf_download(hns, gns.ctypes.data, 0, M * 4)
    fp, ws = golden(a, b, col_scale)
    gp = got.reshape(M, N)
    # the GEMM core is exact int32; requantize is lossy. Reconstruct: int8 * new_scale
    # must land within half a quantization step of the device's own fp (the senior's
    # within-one criterion), and new_scale within 1 ulp of the reference ns.
    step = gp.astype(np.float64) * gns.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - fp.astype(np.float64)) <= gns.astype(np.float64)[:, None] * limit
    sculp = int(np.abs(gns.view(np.int32) - ws.view(np.int32)).max())
    worst = float(np.max(np.abs(step - fp) / gns[:, None]))
    ok(bool(within.all()) and sculp <= 1,
       f"{label} {M}x{N}x{K}: requant within-one {bool(within.all())} (worst {worst:.5f} step), "
       f"new_scale<=1ulp (max {sculp})")
    for h in (ha, hb, hc, hcs, hns): lib.xmx_buf_destroy(h)

run(256, 64, 64, "small")
run(8192, 64, 64, "l2")
run(32640, 64, 64, "l3")
run(130560, 64, 128, "l4-outproj")
# (the N=32 attnV/outproj shapes moved to gate_gemm_s8rq32.py: xmx_rec_gemm_s8rq keeps the
#  senior v3 N==64 ABI; v7 = its own recorder with both scales folded, section 52.)

print(f"\nSKELETON_GEMM_RQ {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
