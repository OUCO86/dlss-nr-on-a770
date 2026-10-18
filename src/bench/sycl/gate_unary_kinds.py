#!/usr/bin/env python3
"""unary-KINDS swap-in gate (route(a) step 3 #7, section 79).

NOT the PUBLISH gate (gate_unary.py drives xmx_rec_unary32, the elementwise rounding
chain). This one drives the GAME's xmx_rec_unary(kind, a, b, c, d, n, channels, p0,
batch, sa, sb, sc, k) -- the captured graph's 16 calls use FOUR flags words (section 79's
dump):
  18    = 0x12    E4M3_HALF    x5   (a f32 -> e4m3 -> half; no epilogue/narrow bits)
  4364  = 0x110C  POOL2        x5   (2x2 NHWC average, epi=E4M3, narrow out, a f32)
  69909 = 0x11115 UPSAMPLE_ADD x4   (a half nearest-2x + b half * sine[c], epi=E4M3, narrow)
  16    = 0x10    PAD_END      x2   (a f32 -> zero-extend, no epilogue, f32 out)
Each golden is the resident.comp branch TRANSCRIBED to numpy (the .comp is the authority,
same discipline as section 34/76): POOL2's column-first add order (.comp:529-531),
UPSAMPLE_ADD's two non-fused precise steps (.comp:598-600), PAD_END's in-bounds test
(.comp:607-609). publish chain = the already-gated qr_publish (epi from flags>>8).
Compare: half outputs as raw BYTES (0-differ), f32 outputs as bits.
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
    ("xmx_rec_unary", [ctypes.c_uint] + [ctypes.c_int] * 4 + [ctypes.c_uint] * 2
                       + [ctypes.c_float] + [ctypes.c_uint] * 5),
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

def mk(kind, a, b, d, n, ch, sa, sb, sc, kk, out_half, label):
    ha = lib.xmx_buf_create_kind(a.nbytes, 2 if a.dtype == np.float16 else 4)
    hb = -1
    if b is not None:
        hb = lib.xmx_buf_create_kind(b.nbytes, 2 if b.dtype == np.float16 else 4)
    hd = -1
    if d is not None:
        hd = lib.xmx_buf_create_kind(d.nbytes, 4)
    wsz = 2 if out_half else 4
    # n IS the total element count (resident.comp's index runs 0..n-1); channels is only
    # the modulo stride for POOL2/UPSAMPLE/PAD. So the output buffer is n*wsz, not n*ch*wsz.
    hc = lib.xmx_buf_create_kind(n * wsz, wsz)
    if min(ha, hc) <= 0 or (hb >= 0 and False) or (hd >= 0 and False):
        ok(False, f"{label}: buffers"); return None, wsz
    ok(min(ha, hc) > 0, f"{label}: buffers")
    up(ha, a)
    if b is not None: up(hb, b)
    if d is not None: up(hd, d)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_unary(kind, ha, hb, hc, hd, n, ch, np.float32(1.0), 0, sa, sb, sc, kk)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(n * wsz, np.uint8); lib.xmx_buf_download(hc, got.ctypes.data, 0, n * wsz)
    for h in (ha, hb, hd, hc):
        if h >= 0: lib.xmx_buf_destroy(h)
    return got, wsz

def test_e4m3_half():
    # E4M3_HALF: n = TOTAL elements, channels unused (the plan passes channels=0 for it).
    n = 256 * 64
    rng = np.random.default_rng(7910)
    a = rng.uniform(-3, 3, size=n).astype(np.float32)
    got, wsz = mk(18, a, None, None, n, 0, 0, 0, 0, 0, True, "E4M3_HALF")
    if got is None: return
    want = np.asarray(NM.e4m3(a), np.float16).view(np.uint8)
    ok(np.array_equal(got, want), f"E4M3_HALF: OUT BITS EQUAL ({int((got != want).sum())} bad)")

def test_pool2():
    h, w, ch = 8, 12, 64
    n = (h // 2) * (w // 2) * ch
    rng = np.random.default_rng(7911)
    a = rng.uniform(-2, 2, size=h * w * ch).astype(np.float32)
    got, wsz = mk(0x110C, a, None, None, n, ch, 0, w, 0, 0, True, "POOL2")
    if got is None: return
    out = np.zeros(n, np.float32)
    for i in range(n):
        cc = i % ch; rest = i // ch
        x = rest % (w // 2); y = rest // (w // 2)
        base = (2 * y * w + 2 * x) * ch + cc
        t = np.float32(a[base] + a[base + w * ch])
        t = np.float32(t + a[base + ch])
        t = np.float32(t + a[base + (w + 1) * ch])
        out[i] = t
    out = np.float32(out * np.float32(0.25))
    want = np.asarray(NM.e4m3(out), np.float16).view(np.uint8)
    ok(np.array_equal(got, want), f"POOL2: OUT BITS EQUAL ({int((got != want).sum())} bad)")

def test_upsample_add():
    h, w, ch = 8, 12, 64
    n = h * w * ch
    rng = np.random.default_rng(7912)
    # flags 0x11115: bit 16 (b half) set, bit 15 (a half) NOT -> a is f32, b is f16.
    a = rng.uniform(-2, 2, size=(h // 2) * (w // 2) * ch).astype(np.float32)
    b = rng.uniform(-1, 1, size=n).astype(np.float16)
    d = rng.uniform(-1, 1, size=ch).astype(np.float32)
    got, wsz = mk(0x11115, a, b, d, n, ch, w, w // 2, 0, 0, True, "UPSAMPLE_ADD")
    if got is None: return
    out = np.zeros(n, np.float32)
    for i in range(n):
        cc = i % ch; rest = i // ch
        x = rest % w; y = rest // w
        aval = np.float32(a[((y // 2) * (w // 2) + (x // 2)) * ch + cc])
        scaled = np.float32(np.float32(b[i]) * d[cc])
        out[i] = np.float32(aval + scaled)
    want = np.asarray(NM.e4m3(out), np.float16).view(np.uint8)
    ok(np.array_equal(got, want), f"UPSAMPLE_ADD: OUT BITS EQUAL ({int((got != want).sum())} bad)")

def test_pad_end():
    h, w, ch = 6, 10, 64
    padded = 16
    n = h * padded * ch
    rng = np.random.default_rng(7913)
    a = rng.uniform(-2, 2, size=h * w * ch).astype(np.float32)
    got, wsz = mk(0x10, a, None, None, n, ch, h, w, padded, 0, False, "PAD_END")
    if got is None: return
    out = np.zeros(n, np.float32)
    for i in range(n):
        cc = i % ch; rest = i // ch
        x = rest % padded; y = rest // padded
        out[i] = a[(y * w + x) * ch + cc] if (y < h and x < w) else 0.0
    want = out.view(np.uint8)
    ok(np.array_equal(got, want), f"PAD_END: OUT BITS EQUAL ({int((got != want).sum())} bad)")

test_e4m3_half()
test_pool2()
test_upsample_add()
test_pad_end()

print(f"\nUNARY_KINDS {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
