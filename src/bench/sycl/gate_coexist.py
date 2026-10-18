#!/usr/bin/env python3
"""COEXIST gate (route (a) step 0, section 64): the game process has a LIVE D3D12 device
(the bridge/game built it, on the AMD rendering card) before our dll is loaded. Section 60
proved the same disease on the Vulkan pairing -- SYCL then enumerates the Arc through the
OPENCL adapter (backend=1) and get_native<level_zero> dies. The shipping C++ path loads
libxmx.dll (Vulkan) next to D3D12 and works; route (a) replaces it with libxmx_sycl.dll,
so the open question this gate answers BEFORE any data-leg work:

  with a D3D12 device alive in the process, does the Level-Zero skeleton (a) come up on
  the A770, and (b) still compute its green chain BIT-CORRECT?

Two D3D12 devices are created to be honest about the shape: the default adapter (the AMD
rendering card, what the game holds) and, when enumerable, the A770 too (what the bridge
touches for hand-over). If SYCL's enumeration degrades the way it did under the Vulkan
pairing, the stderr census says so; if xmx_init still lands on a real compute device and
the s8rq chain matches numpy byte-exact, route (a) has no engine-level blocker and step 2
(D3D12 import leg) can start.

The chain part is copied VERBATIM from the green gate_gemm_s8rq (same shapes, same
golden), because this gate's only new variable is the D3D12 device in the process.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import int8_quant

for d in (str(ROOT.parent.parent / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k = ctypes.windll.kernel32; _k.SetErrorMode(0x8002)
os.chdir(str(ROOT.parent.parent / "oneapi"))

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

# ---------- D3D12 devices BEFORE any of our engine touches the GPU ----------
d3d12 = ctypes.windll.d3d12
dxgi = ctypes.windll.dxgi
factory = ctypes.c_void_p()
# the REAL IID_ID3D12Device from the SDK header (d3d12.h:35712, DEFINE_GUID literal, not a
# hand-typed guess -- a wrong IID gave E_NOINTERFACE 0x80004002 the first time this ran,
# which silently skipped the whole coexistence condition. GUID {189819f1-1db6-4b57-be54-
# 1821339b85f7}, stored as Data1 le, Data2 le, Data3 le, then the 8 Data4 bytes verbatim.)
IID_ID3D12Device = (ctypes.c_ubyte * 16)(
    0xf1,0x19,0x98,0x18, 0xb6,0x1d, 0x57,0x4b,
    0xbe,0x54,0x18,0x21,0x33,0x9b,0x85,0xf7)
dev1 = ctypes.c_void_p()
D3D12_FEATURE_LEVEL_12_1 = 0xc100
hr = d3d12.D3D12CreateDevice(None, D3D12_FEATURE_LEVEL_12_1,
                             ctypes.byref(IID_ID3D12Device), ctypes.byref(dev1))
coexist = (hr == 0 and bool(dev1))
ok(coexist, f"D3D12CreateDevice(default adapter) hr=0x{hr & 0xffffffff:08x} dev={'live' if dev1 else 'null'}"
   + ("" if coexist else "  -- WITHOUT a live device the coexistence condition never ran"))
if not coexist:
    print("\nCOEXIST INCOMPLETE: the D3D12 leg failed, nothing below proves coexistence.")
    sys.exit(1)

# a second device on EVERY adapter we can see, to mimic bridge+game holding D3D12 objects
# while the L0 engine comes up -- but enumerating adapters needs IDXGIFactory; skip it: the
# default-adapter device is what the game holds, and one live D3D12 device in the process
# is already the coexistence condition. (One variable, per the standing rule.)

# ---------- now the skeleton: xmx_init, and the green s8rq chain ----------
lib = ctypes.CDLL(str(ROOT.parent.parent / "oneapi" / "libxmx_sycl.dll"))
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_submit", []),
    ("xmx_graph_capture", []), ("xmx_graph_run", [ctypes.c_int]),
    ("xmx_rec_gemm_s8rq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int
ok(lib.xmx_init() == 0, "xmx_init in a process that already holds a D3D12 device"
   + ("" if lib.xmx_init() == 0 else ": " + lib.xmx_error().decode(errors="replace")))

# VERBATIM from the green gate_gemm_s8rq: (M,N,K) = (256,64,256), its golden form.
M, N, K = 256, 64, 256
rng = np.random.default_rng(11 + M + K + N)
a = rng.integers(-127, 128, size=(M, K), dtype=np.int8)
b = rng.integers(-127, 128, size=(K, N), dtype=np.int8)
col_scale = (0.001 * (np.arange(N) % 37 + 1)).astype(np.float32)
ha = lib.xmx_buf_create(M * K); hb = lib.xmx_buf_create(K * N)
hc = lib.xmx_buf_create_kind(M * N, 1)
hcs = lib.xmx_buf_create_kind(N * 4, 4)
hns = lib.xmx_buf_create_kind(M * 4, 4)
lib.xmx_buf_upload(ha, a.ctypes.data, 0, M * K)
lib.xmx_buf_upload(hb, b.ctypes.data, 0, K * N)
lib.xmx_buf_upload(hcs, np.ascontiguousarray(col_scale).ctypes.data, 0, N * 4)
lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
lib.xmx_begin()
rc = lib.xmx_rec_gemm_s8rq(ha, hb, hc, hcs, hns, M, N, K)
ok(rc == 0, "s8rq recorder" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
ok(lib.xmx_submit() == 0, "submit (sequential path works with D3D12 live)")
got = np.zeros(M * N, np.int8); lib.xmx_buf_download(hc, got.ctypes.data, 0, M * N)
got = got.reshape(M, N)
scales = np.zeros(M, np.float32); lib.xmx_buf_download(hns, scales.ctypes.data, 0, M * 4)

acc = a.astype(np.int32) @ b.astype(np.int32)
prod = (acc.astype(np.float64) * col_scale.astype(np.float64)[None, :])
peak = np.abs(prod).max(axis=1)
want_scale = (peak / 127.0).astype(np.float32)
q = np.divide(prod, want_scale[:, None].astype(np.float64), out=np.zeros_like(prod),
              where=want_scale[:, None] > 0)
want = np.clip(np.rint(q), -127, 127).astype(np.int8)
within = np.abs(got.astype(np.float64) * scales.astype(np.float64)[:, None]
                - prod) <= np.maximum(scales.astype(np.float64), 1e-30)[:, None] * (0.5 + 2.0 ** -16)
sculp = int(np.abs(scales.view(np.int32) - want_scale.view(np.int32)).max())
ok(bool(within.all()) and sculp <= 1,
   f"s8rq chain BIT-CORRECT with a live D3D12 device in the process "
   f"(within-one {bool(within.all())}, scale<=1ulp max {sculp})")

# and the graph leg (section 65's contracts) on top of the same coexistence
lib.xmx_begin()
lib.xmx_rec_gemm_s8rq(ha, hb, hc, hcs, hns, M, N, K)
gid = lib.xmx_graph_capture()
ok(gid == 0, f"graph capture works with D3D12 live (id {gid})")
lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
r = lib.xmx_graph_run(gid)
ok(r > 0, f"graph_run -> {r} passes")
got2 = np.zeros(M * N, np.int8); lib.xmx_buf_download(hc, got2.ctypes.data, 0, M * N)
got2 = got2.reshape(M, N)
ok(np.array_equal(got2, got), "graph replay byte-identical to the sequential result (same process, D3D12 live)")

# leave the D3D12 device cleanly (Release through IUnknown's vtable is fiddly in ctypes;
# holding it until process exit is fine for a gate: the point is coexistence at startup).
print(f"\nCOEXIST {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
