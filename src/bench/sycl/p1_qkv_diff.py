#!/usr/bin/env python3
"""P1 diff net (route B, sections 49/50): old Vulkan QKV chain vs my L0 int8 chain,
SAME int8 operands, same process, byte-diff on the published e4m3-as-f16 outputs.

Both chains eat identical int8 activations/weights and identical row/column scales. The
GEMM is integer-exact on both engines; the dequantise is the same two left-to-right f32
multiplies; the cosine tree is bit-exact (all three proven section 32-39). So the ONLY
divergence is the seam container: the old chain publishes e4m3 straight off the fp32
value; my chain requantizes to int8+scale (straight-through currency) and this gate's
boundary publish turns it back into e4m3. The diff IS the P1 seam-form tax, measured on
REAL weights (dlssnr-logical.safetensors) with the senior's own activation construction
(standard_normal * 0.3, test_resident.py:156) -- no synthetic grid, no golden needed.

Layout: the old chain writes Q/K/V in (window,head,token,32) scattered order; my chain's
Q/K come out linear (row, head*32+chan) and V scattered (section 35/39/41). The compare
maps through the same at() formula, so a layout bug would show as total mismatch, not
noise. Guard-fill (FILL is not an e4m3 value) checks every element was written.

Two engines, one process: work/libxmx.dll (Vulkan coopmat) and oneapi/libxmx_sycl.dll
(Level Zero ESIMD). Each keeps its own device context and buffer table -- the section 18
gate already proved both address the same A770.
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]          # .../src/dlss-nr-on-a770 (repo root)
ONER = ROOT.parent.parent                                  # .../2026-10-09-04-20-55 (staged oneapi lives here)
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))

for d in (str(ONER / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
          r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
    if os.path.isdir(d):
        try: os.add_dll_directory(d)
        except OSError: pass
_k32 = ctypes.windll.kernel32
_k32.SetErrorMode(0x8002)
for _dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
    _p = ONER / "oneapi" / _dep
    if _p.exists():
        _k32.LoadLibraryExW(str(_p), 0, 0)

MY = ctypes.CDLL(str(ONER / "oneapi" / "libxmx_sycl.dll"))
MY.xmx_error.restype = ctypes.c_char_p
for nm, at in (
    ("xmx_init", []), ("xmx_buf_create_kind", [ctypes.c_ulonglong, ctypes.c_int]),
    ("xmx_buf_upload", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_download", [ctypes.c_int, ctypes.c_void_p, ctypes.c_ulonglong, ctypes.c_ulonglong]),
    ("xmx_buf_zero", [ctypes.c_int]), ("xmx_buf_destroy", [ctypes.c_int]),
    ("xmx_begin", []), ("xmx_abort", []), ("xmx_submit", []),
    ("xmx_rec_gemm_qkv_v_i8", [ctypes.c_int] * 6 + [ctypes.c_uint] * 4),
    ("xmx_rec_gemm_qkv_deq", [ctypes.c_int] * 5 + [ctypes.c_uint] * 2),
    ("xmx_rec_cosine_norm_i8", [ctypes.c_int] * 3 + [ctypes.c_uint] * 2 + [ctypes.c_int, ctypes.c_uint]),
):
    getattr(MY, nm).argtypes = at
    getattr(MY, nm).restype = ctypes.c_int
if MY.xmx_init() != 0:
    raise SystemExit("my L0 init: " + MY.xmx_error().decode())

import nr_model as NM            # noqa: E402
import int8_quant                # noqa: E402
import xmxres as X               # noqa: E402  (the shipped Vulkan runtime module)

rt = X.Runtime()                 # loads work/libxmx.dll + the shipped spv set

weights, _meta = NM.load_logical(str(ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors"))
GUARD = 64
FILL = np.float16(-11.1)

def at(w, head, token, chan, heads, tokens):
    return ((w * heads + head) * tokens + token) * 32 + chan

def to_linear(arr, windows, tokens, heads):
    """arr is scattered (window,head,token,32) -> linear (rows=w*tokens+t, channel=head*32+chan)."""
    rows = windows * tokens
    lin = np.empty((rows, heads * 32), arr.dtype)
    for w in range(windows):
        for h in range(heads):
            for t in range(tokens):
                for c in range(32):
                    lin[w * tokens + t, h * 32 + c] = arr[at(w, h, t, c, heads, tokens)]
    return lin.reshape(rows, heads * 32)

def to_scatter(grid, windows, tokens, heads):
    """grid (rows, C=heads*32) linear -> scattered (window,head,token,32) flat."""
    rows = windows * tokens
    out = np.empty(rows * heads * 32, grid.dtype)
    for w in range(windows):
        for t in range(tokens):
            for c in range(heads * 32):
                out[at(w, c // 32, t, c % 32, heads, tokens)] = grid[w * tokens + t, c]
    return out

def deq_chain(a8, wKN, asc, wsc, C, heads, vit, qkvs, is_q):
    """the shared pre-container x both chains compute (int32-exact GEMM + identical f32)."""
    acc = a8.reshape(-1, C).astype(np.int32) @ wKN.astype(np.int32)     # (rows, C)
    dq = ((acc.astype(np.float32) * asc[:, None]).astype(np.float32) * wsc[None, :])
    v = NM._half_rounded(dq.reshape(-1, 32))                            # (rows*heads, 32)
    if not vit:
        n = NM.vendor_cosine_normalize(v)
        if is_q:
            sc = NM._half_rounded(qkvs).astype(np.float32)[np.arange(v.shape[0]) % heads][:, None]
            return NM._half_rounded(n * sc).reshape(-1)
        return n.reshape(-1)
    nrm = NM._vit_norm(v)[:, None]
    x = NM._half_rounded(v * nrm)
    if is_q:
        root = NM._half_rounded(np.float32(np.sqrt(32)))
        sc = NM._half_rounded(qkvs).astype(np.float32)[np.arange(v.shape[0]) % heads][:, None]
        x = NM._half_rounded(NM._half_rounded(x * root) * sc)
    return x.reshape(-1)

def compare(prefix, block, vit):
    qkv32 = weights[f"{prefix}.qkv_weight"]          # logical (C, 3C)
    scale = np.ascontiguousarray(weights[f"{prefix}.attn_scale"].astype(np.float32))
    C = qkv32.shape[0]
    heads = C // 32
    tokens = 64
    windows = 12                                     # test_resident.py's window grid
    rows = windows * tokens

    wb = np.ascontiguousarray(qkv32.T)                # (3C, C): row = output channel
    w8, wsc = int8_quant.quantise(wb, axis=1)         # one scale per output channel
    rng = np.random.default_rng(4242 + C)
    act = (rng.standard_normal((rows, C)) * 0.3).astype(np.float32)   # senior's construction
    a8, asc = int8_quant.quantise(act, axis=1)
    wQ8, wK8, wV8 = (np.ascontiguousarray(w8[s:s + C].T) for s in (0, C, 2 * C))  # (K=in, N=out)

    # ---- old chain (Vulkan coopmat int8 QKV) ----
    bufs = []
    def ob(n, dt):
        b = rt.buffer(n, dt); bufs.append(b); return b
    oa, ow = ob(rows * C, np.int8), ob(3 * C * C, np.int8)
    oas, ows, oscale = ob(rows, np.float32), ob(3 * C, np.float32), ob(heads, np.float32)
    oq, ok, ov = (ob(rows * C + GUARD, np.float16) for _ in range(3))
    X.host_write(oa, a8); X.host_write(ow, w8)
    X.host_write(oas, asc); X.host_write(ows, wsc); X.host_write(oscale, scale)
    for t in (oq, ok, ov):
        X.host_write(t, np.full(rows * C + GUARD, FILL, np.float16))
    rt.begin()
    rt.gemm_int8_qkv(oa, ow, oq, ok, ov, oas, ows, oscale, rows, C, heads, tokens, vit=vit)
    rt.submit()
    old = {}
    for name, t in zip("QKV", (oq, ok, ov)):
        v = X.host_view(t, np.float16)
        assert (v[rows * C:] == FILL).all(), f"{name} guard overwritten"
        assert not (v[:rows * C] == FILL).any(), f"{name} left unwritten"
        old[name] = v[:rows * C].copy()
    for b in bufs: b.free()

    # ---- my chain (L0 ESIMD int8, section 46's six-pass QKV) ----
    def mb(n, kind):
        return MY.xmx_buf_create_kind(n, kind)
    ma = mb(rows * C, 1)
    mwQ, mwK, mwV = mb(C * C, 1), mb(C * C, 1), mb(C * C, 1)
    mas = mb(rows * 4, 4)
    mwQs, mwKs, mwVs = (mb(C * 4, 4) for _ in range(3))
    mqf, mkf = mb(rows * C * 4, 4), mb(rows * C * 4, 4)
    mq8, mk8, mv8 = mb(rows * C, 1), mb(rows * C, 1), mb(rows * C, 1)
    mqs, mks = mb(rows * heads * 4, 4), mb(rows * heads * 4, 4)
    mvs = mb(windows * C * 4, 4); mqkvs = mb(heads * 4, 4)
    def up(h, arr, n):
        assert MY.xmx_buf_upload(h, arr.ctypes.data, 0, n) == 0, MY.xmx_error()
    up(ma, a8, rows * C)
    up(mwQ, wQ8, C * C); up(mwK, wK8, C * C); up(mwV, wV8, C * C)
    up(mas, asc, rows * 4)
    up(mwQs, wsc[0:C], C * 4); up(mwKs, wsc[C:2 * C], C * 4); up(mwVs, wsc[2 * C:3 * C], C * 4)
    up(mqkvs, scale, heads * 4)
    for h in (mqf, mkf, mq8, mk8, mv8, mqs, mks, mvs): MY.xmx_buf_zero(h)
    assert MY.xmx_begin() == 0
    assert MY.xmx_rec_gemm_qkv_v_i8(ma, mwV, mv8, mvs, mas, mwVs, rows, C, heads, tokens) == 0, MY.xmx_error()
    assert MY.xmx_rec_gemm_qkv_deq(ma, mwQ, mqf, mas, mwQs, rows, C) == 0, MY.xmx_error()
    assert MY.xmx_rec_cosine_norm_i8(mqf, mq8, mqs, rows * heads, 1 if vit else 0, mqkvs, heads) == 0, MY.xmx_error()
    assert MY.xmx_rec_gemm_qkv_deq(ma, mwK, mkf, mas, mwKs, rows, C) == 0, MY.xmx_error()
    assert MY.xmx_rec_cosine_norm_i8(mkf, mk8, mks, rows * heads, 1 if vit else 0, 0, 0) == 0, MY.xmx_error()
    assert MY.xmx_submit() == 0, MY.xmx_error().decode()

    def dl(h, n, dt):
        a = np.zeros(n, dt); MY.xmx_buf_download(h, a.ctypes.data, 0, a.nbytes); return a
    mq8v, mk8v, mv8v = dl(mq8, rows * C, np.int8), dl(mk8, rows * C, np.int8), dl(mv8, rows * C, np.int8)
    mqs_v, mks_v = dl(mqs, rows * heads, np.float32), dl(mks, rows * heads, np.float32)
    mvs_v = dl(mvs, windows * C, np.float32)
    for h in (ma, mwQ, mwK, mwV, mas, mwQs, mwKs, mwVs, mqf, mkf, mq8, mk8, mv8,
              mqs, mks, mvs, mqkvs):
        MY.xmx_buf_destroy(h)

    # everything compared in LINEAR (rows, C=heads*32) space. The old chain and my V come
    # out scattered; my Q/K come out (row, head*32+chan) = linear. Un-scatter the former.
    oldL, mineL, xL = {}, {}, {}
    for name in "QKV":
        oldL[name] = to_linear(old[name], windows, tokens, heads)
    # boundary publish (the P1 seam tax): e4m3(int8 * scale) as f16.
    mq8L = mq8v.reshape(rows * heads, 32)            # my Q/K are already (row,head)-flattened = linear
    mk8L = mk8v.reshape(rows * heads, 32)
    qpub = NM.e4m3(mq8L.astype(np.float32) * mqs_v[:, None].astype(np.float32)).astype(np.float16)
    kpub = NM.e4m3(mk8L.astype(np.float32) * mks_v[:, None].astype(np.float32)).astype(np.float16)
    mineL["Q"] = qpub.reshape(rows, C)
    mineL["K"] = kpub.reshape(rows, C)
    vlin = to_linear(mv8v, windows, tokens, heads).reshape(rows, C)          # un-scatter V int8
    vwin = np.repeat(mvs_v.reshape(windows, C), tokens, axis=0).reshape(rows, C)  # row r -> window scale
    mineL["V"] = NM.e4m3(vlin.astype(np.float32) * vwin.astype(np.float32)).astype(np.float16)
    # shared pre-container x, linear (rows, C)
    for name, arr in (("Q", deq_chain(a8, wQ8, asc, wsc[0:C], C, heads, vit, scale, True)),
                      ("K", deq_chain(a8, wK8, asc, wsc[C:2 * C], C, heads, vit, scale, False)),
                      ("V", ((a8.reshape(-1, C).astype(np.int32) @ wV8.astype(np.int32))
                             .astype(np.float32) * asc[:, None]).astype(np.float32)
                            * wsc[2 * C:3 * C][None, :])):
        xL[name] = arr.reshape(rows, C).astype(np.float64)

    print(f"\n== block{block} C={C} heads={heads} windows={windows} vit={vit} ==")
    tot = 0
    for name in "QKV":
        o, m, x = oldL[name], mineL[name], xL[name]
        diff = np.flatnonzero(o.view(np.uint16) != m.view(np.uint16))
        rms_o = float(np.sqrt(np.mean((o.astype(np.float64) - x) ** 2)))
        rms_m = float(np.sqrt(np.mean((m.astype(np.float64) - x) ** 2)))
        worst = float(np.max(np.abs(o.reshape(-1)[diff].astype(np.float64)
                                    - m.reshape(-1)[diff].astype(np.float64)))) if diff.size else 0.0
        print(f"  {name}: diff {diff.size}/{o.size} ({100.0 * diff.size / o.size:.4f}%), "
              f"max {worst:.6g} | rms-to-x old {rms_o:.6f} mine {rms_m:.6f} "
              f"({'mine better' if rms_m < rms_o else ('old better' if rms_o < rms_m else 'equal')})")
        tot += diff.size
    # localize any V gap before the container: is my int8*scale still within-one of x?
    vrec = vlin.astype(np.float64) * vwin.astype(np.float64)
    tol = 0.5 + 2.0 ** -16
    step_ok = np.abs(vrec - xL["V"]) <= np.maximum(vwin.astype(np.float64), 1e-30) * tol
    print(f"  V within-one(int8*scale vs x) {step_ok.all()} "
          f"(bad {(~step_ok).sum()}/{xL['V'].size}); x-V rms {np.sqrt((xL['V']**2).mean()):.4f} "
          f"typical step {np.median(vwin):.5f}")
    return tot

cands = sorted({(k, weights[k].shape[0]) for k in weights
                if k.endswith(".qkv_weight") and weights[k].shape[0] % 64 == 0},
               key=lambda t: t[1])
seen, total = set(), 0
for k, C in cands:
    block = k.split(".")[0]
    if block in seen:
        continue
    seen.add(block)
    total += compare(f"{block}.layer0", block[5:], False)
    if len(seen) >= 3:
        break
print(f"\nP1 DIFF NET: total differing bytes across both chains = {total} "
      f"(this is the seam-form tax: int8-requant+publish vs direct e4m3, real weights)")
