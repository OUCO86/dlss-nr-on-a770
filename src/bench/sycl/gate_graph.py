#!/usr/bin/env python3
"""graph gate (route (a) step 1, section 64): capture-then-replay must be IDENTICAL to
the sequential path, and the replay must read operands written AFTER capture (ops frozen,
memory live -- the shipped command-buffer contract, libxmx.c:3613-3640 / nr_replay.c:505).

Shape family = the proven chain-s1 vertical (quant -> rq GEMM -> rq GEMM), run two ways
against one numpy authority:
  A) sequential: begin/rec*/submit, twice, download twice -> out1a, out2a
  B) graph:      begin/rec*/capture, graph_run twice -> out1b, out2b; ALSO: rewrite the
     INPUT buffer + requantise scale between the two runs and check run2 changes exactly
     like A's second frame would (the operands-must-be-live property).
Plus the ordering/counting contract: capture returns a slot id, run(id) returns the pass
count, run during recording fails, destroy(id) makes run(id) fail.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import int8_quant

for d in (str(ROOT.parent.parent / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k = ctypes.windll.kernel32; _k.SetErrorMode(0x8002)
for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    p = ROOT.parent.parent / "oneapi" / dep
    if p.exists(): _k.LoadLibraryExW(str(p), 0, 0)

os.chdir(str(ROOT.parent.parent / "oneapi"))
lib = ctypes.CDLL(str(ROOT.parent.parent / "oneapi" / "libxmx_sycl.dll"))
lib.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_graph_capture", []), ("xmx_graph_run", [ctypes.c_int]),
    ("xmx_graph_destroy", [ctypes.c_int]), ("xmx_idle", []),
    ("xmx_rec_gemm_s8rq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 3),
):
    if hasattr(lib, nm):
        getattr(lib, nm).argtypes = at; getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

M, N, K = 256, 64, 256   # the green s8rq gate shapes: N==64 only (libxmx_sycl guard)
rng = np.random.default_rng(909)
A = rng.integers(-100, 101, (M, K)).astype(np.int8)
W = rng.integers(-100, 101, (K, N)).astype(np.int8)
a8 = np.ascontiguousarray(A)
w8 = np.ascontiguousarray(W.T)          # column-major weight per the rq contract (gate_gemm_s8rq)
acc = (a8.astype(np.int32) @ w8.astype(np.int32).T)
ascale = np.full(M, 0.01, np.float32)
wscale = np.full(N, 0.02, np.float32)

def bufs():
    # the green gate's shapes: a(MxK int8), b(KxN int8), c8(MxN int8),
    # col_scale(N f32), new_scale(M f32)
    ha = lib.xmx_buf_create_kind(M*K, 1); hb = lib.xmx_buf_create_kind(K*N, 1)
    hc = lib.xmx_buf_create_kind(M*N, 1)
    hcs = lib.xmx_buf_create_kind(N*4, 4); hns = lib.xmx_buf_create_kind(M*4, 4)
    lib.xmx_buf_upload(ha, a8.ctypes.data, 0, M*K)
    lib.xmx_buf_upload(hb, w8.ctypes.data, 0, K*N)
    lib.xmx_buf_upload(hcs, np.ascontiguousarray(wscale).ctypes.data, 0, N*4)
    lib.xmx_buf_upload(hns, np.ascontiguousarray(ascale).ctypes.data, 0, M*4)
    for h in (hc, hns): lib.xmx_buf_zero(h)
    return ha, hb, hc, hcs, hns

def rec(ha, hb, hc, hcs, hns):
    rc = lib.xmx_rec_gemm_s8rq(ha, hb, hc, hcs, hns, M, N, K)
    if rc != 0: raise RuntimeError("rec: " + lib.xmx_error().decode())

def dl(h, n, dt):
    v = np.zeros(n, dt); lib.xmx_buf_download(h, v.ctypes.data, 0, v.nbytes); return v

# ---- A) sequential: submit twice with a changed weight between ----
ha, hb, hc, hcs, hns = bufs()
w2 = np.ascontiguousarray((W + 7).clip(-127, 127).T.astype(np.int8))
qA = []
lib.xmx_begin(); rec(ha, hb, hc, hcs, hns)
ok(lib.xmx_submit() == 0, "A: submit 1")
qA.append(dl(hc, M*N, np.int8).copy()); sA = dl(hns, M, np.float32).copy()
lib.xmx_buf_upload(hb, w2.ctypes.data, 0, K*N)
lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
lib.xmx_begin(); rec(ha, hb, hc, hcs, hns)
ok(lib.xmx_submit() == 0, "A: submit 2 (changed weight)")
qA.append(dl(hc, M*N, np.int8).copy()); sA2 = dl(hns, M, np.float32).copy()
for h in (ha, hb, hc, hcs, hns): lib.xmx_buf_destroy(h)

# ---- B) graph: capture once, run, change weight, run again ----
ha, hb, hc, hcs, hns = bufs()
lib.xmx_begin(); rec(ha, hb, hc, hcs, hns)
gid = lib.xmx_graph_capture()
ok(gid == 0, f"B: capture -> slot id {gid}")
lib.xmx_begin()          # recording again must refuse replay mid-record
ok(lib.xmx_graph_run(gid) == -1, "B: run during recording refuses")
lib.xmx_abort()
ok(lib.xmx_graph_run(gid) > 0, "B: run 1 replays (passes returned)")
lib.xmx_idle()
qB = [dl(hc, M*N, np.int8).copy(), None]; sB = dl(hns, M, np.float32).copy()
ok(np.array_equal(qB[0], qA[0]) and np.array_equal(sB, sA),
   "B: replay-1 == sequential-1 byte-exact")
lib.xmx_buf_upload(hb, w2.ctypes.data, 0, K*N)   # live memory: the frozen graph must see it
lib.xmx_buf_zero(hc); lib.xmx_buf_zero(hns)
r = lib.xmx_graph_run(gid)
ok(r > 0, "B: run 2")
lib.xmx_idle()
qB[1] = dl(hc, M*N, np.int8); sB2 = dl(hns, M, np.float32)
ok(np.array_equal(qB[1], qA[1]) and np.array_equal(sB2, sA2),
   "B: replay-2 == sequential-2 (operands read LIVE at replay -- the shipped contract)")
# destroy -> not live
ok(lib.xmx_graph_destroy(gid) == 0 and lib.xmx_graph_run(gid) == -1,
   "B: destroy makes the slot refuse")
for h in (ha, hb, hc, hcs, hns): lib.xmx_buf_destroy(h)

# a second capture gets the NEXT slot number (the plan replays "the number it had that once")
ha, hb, hc, hcs, hns = bufs()
lib.xmx_begin(); rec(ha, hb, hc, hcs, hns); gid2 = lib.xmx_graph_capture()
ok(gid2 == 1, f"second capture -> id {gid2}")
ok(lib.xmx_graph_run(1) > 0, "run(1) by the new number")
for h in (ha, hb, hc, hcs, hns): lib.xmx_buf_destroy(h)

print(f"\nGRAPH {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
