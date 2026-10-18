#!/usr/bin/env python3
"""window-int8-residual swap-in gate (route(a) step 3 #5, section 76).

The map is residual_epilogue.glsl:4-15 TRANSCRIBED to numpy line-for-line (the .glsl is
the shipping authority, same discipline as section 34's cosine_tree verbatim move):
    pixel = index / n;  window = pixel / 64;  token = pixel % 64
    y = (window / window_cols) * 8 + token / 8
    x = (window % window_cols) * 8 + token % 8
    top = pad >> 16;  left = pad & 0xffff
    out of [top, top+image_h) x [left, left+image_w)  ->  CONTINUE (no read, no write)
    index := ((y - top) * image_w + x - left) * n + index % n        (the inout remap)
after the remap, at is what reads the skip buffer (.comp:261: skip lives in IMAGE layout,
size image_h*image_w*n) and the answer lands at .comp:297 (`out4 -> HalfBuf(pc.c).v4[at>>2]`).
cosine reads at % n = c (the map preserves %n).

Math identical to the plain residual gate otherwise (sycl::fma single rounding, f64-exact
golden with the gap<=18 assert, the section 74 f32-band rules: uniform-ish O(1) scales,
|skip|,|cos| >= 0.4 away from zero, dtype asserts on every upload).

Plan families mirrored (section 76's dump; CI-shrunk but keeping the pad/across/N
structure and the window-major r = window*64+token layout):
  W1 (768,512,512,0x41100, h20 w32 across4 pad0)          -- exact plan tuple
  W2 (768,512,512,0x41100, h20 w32 across4 pad top=4)     -- the crop case (128 dropped)
  W3 (960,512,512,0x41100, h20 w32 across5 pad top4 left4)-- both-edge crop
  W4 (256,64,64,0x40100, h20 w32 across4 pad0)            -- WIDE f32-out variant (epi0)
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
    ("xmx_rec_gemm_window_int8_residual", [ctypes.c_int] * 7 + [ctypes.c_uint] * 8),
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
    rc = lib.xmx_buf_upload(h, a.ctypes.data, 0, a.nbytes)
    assert rc == 0, f"upload failed: {lib.xmx_error().decode()}"

def map_index(idx, n, image_h, image_w, cols, top, left):
    """residual_epilogue.glsl:5-14 verbatim -> (out_index_or_None)."""
    pixel = idx // n
    window = pixel // 64
    token = pixel % 64
    y = (window // cols) * 8 + token // 8
    x = (window % cols) * 8 + token % 8
    if y < top or x < left or y - top >= image_h or x - left >= image_w:
        return None
    return ((y - top) * image_w + x - left) * n + idx % n

def run(M, N, K, flags, h, w, across, pad, label):
    global fails
    epi = (flags >> 8) & 0xF
    narrow = bool(flags & 0x1000)
    half_skip = bool(flags & 0x40000)
    top, left = pad >> 16, pad & 0xffff
    rng = np.random.default_rng(7670 + M + N * 3 + K * 5 + h * 7 + w + across * 11 + pad)
    accscale = float(np.sqrt(K)) * 127.0 * 127.0 / 3.0
    ascale = np.float32(accscale ** -0.5) * (np.float32(0.95) + rng.random(M).astype(np.float32) * np.float32(0.1))
    bscale = np.float32(accscale ** -0.5) * (np.float32(0.95) + rng.random(N).astype(np.float32) * np.float32(0.1))
    A = rng.integers(-3, 4, size=(M, K), dtype=np.int8)      # small band: O(1) stage
    Bt = rng.integers(-3, 4, size=(N, K), dtype=np.int8)     # transposed (N x K)
    img_elems = h * w * N
    sgns = rng.choice(np.float32([-1.0, 1.0]), size=img_elems)
    if half_skip:
        skip = np.asarray(sgns * rng.uniform(0.4, 1.0, size=img_elems).astype(np.float32), np.float16)
    else:
        skip = (sgns * rng.uniform(0.4, 1.0, size=img_elems).astype(np.float32)).astype(np.float32)
    cosine = (rng.uniform(0.4, 1.0, size=N).astype(np.float32)
              * rng.choice(np.float32([-1.0, 1.0]), size=N)).astype(np.float32)
    wsz = 2 if narrow else 4

    ha = lib.xmx_buf_create_kind(M * K, 1); hb = lib.xmx_buf_create_kind(N * K, 1)
    hc = lib.xmx_buf_create_kind(img_elems * wsz, wsz)
    has = lib.xmx_buf_create_kind(M * 4, 4); hbs = lib.xmx_buf_create_kind(N * 4, 4)
    hsk = lib.xmx_buf_create_kind(img_elems * (2 if half_skip else 4), 2 if half_skip else 4)
    hco = lib.xmx_buf_create_kind(N * 4, 4)
    ok(min(ha, hb, hc, has, hbs, hsk, hco) > 0, f"{label}: buffers")
    up(ha, A); up(hb, Bt); up(has, ascale); up(hbs, bscale); up(hsk, skip); up(hco, cosine)
    lib.xmx_buf_zero(hc)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_gemm_window_int8_residual(ha, hb, hc, has, hbs, hsk, hco,
                                               M, N, K, flags, h, w, across, pad)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(img_elems * wsz, np.uint8)
    lib.xmx_buf_download(hc, got.ctypes.data, 0, img_elems * wsz)
    for hh in (ha, hb, hc, has, hbs, hsk, hco): lib.xmx_buf_destroy(hh)

    # golden: block math on dC-order (M-major over windows), skip/cosine via the SAME map.
    acc = (A.astype(np.int64) @ Bt.astype(np.int64).T).astype(np.float32)
    stage = (acc * ascale[:, None]).astype(np.float32)
    stage = (stage * bscale[None, :]).astype(np.float32)
    sk_arr = skip.view(np.float16).astype(np.float32) if half_skip else skip.astype(np.float32)
    want = np.full(img_elems, np.nan, np.float64)
    gaps = []
    for r in range(M):
        for c in range(N):
            idx = r * N + c
            out = map_index(idx, N, h, w, across, top, left)
            if out is None:
                continue                      # cropped padding: untouched
            prod = float(sk_arr[out]) * float(cosine[c])
            total = np.float32(prod + float(stage[r, c]))   # f64 add is exact (gap check)
            gaps.append(abs(np.floor(np.log2(abs(prod) + (prod == 0))) -
                            np.floor(np.log2(abs(float(stage[r, c])) + (stage[r, c] == 0)))))
            if epi == 1: v = NM.e4m3(total)
            elif epi == 3: v = NM.e4m3(NM.quadratic_gate_activation(total))
            elif epi == 2: v = NM.quadratic_gate_activation(total)
            else: v = total
            want[out] = v
    assert max(gaps) <= 18.0, f"{label}: f64 gap {max(gaps)}"
    # untouched pixels must still be zero (we zeroed C before): compare only mapped cells,
    # AND assert the unmapped image cells are exactly 0.
    mapped = np.zeros(img_elems, bool)
    for r in range(M):
        for c in range(N):
            out = map_index(r * N + c, N, h, w, across, top, left)
            if out is not None: mapped[out] = True
    if narrow:
        gv = got.view(np.float16); wv = np.where(mapped, np.nan_to_num(want), 0).astype(np.float16)
    else:
        gv = got.view(np.float32); wv = np.where(mapped, np.nan_to_num(want), 0).astype(np.float32)
    same = np.array_equal(gv.view(np.uint16 if narrow else np.uint32),
                          wv.view(np.uint16 if narrow else np.uint32))
    nbad = int((gv.view(np.uint16 if narrow else np.uint32) != wv.view(np.uint16 if narrow else np.uint32)).sum())
    ok(same, f"{label}: OUT BITS EQUAL ({M}w-grid {h}x{w} across{across} pad0x{pad:x} "
             f"mapped {int(mapped.sum())}/{img_elems} dropped {int((~mapped).sum())}, {nbad} bad)")

# exact plan tuples (the 768x512 pair + the 960 crop both edges); W4 = f32-out (epi 0)
run(768, 512, 512, 0x41100, 20, 32, 4, 0x0, "W1-768x512-pad0")
run(768, 512, 512, 0x41100, 20, 32, 4, 0x40000, "W2-768x512-top4")
run(960, 512, 512, 0x41100, 20, 32, 5, 0x40004, "W3-960x512-both4")
run(192, 64, 64, 0x40100, 20, 32, 4, 0x4, "W4-f32out-left4")

print(f"\nWINDOW_INT8_RESIDUAL {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
