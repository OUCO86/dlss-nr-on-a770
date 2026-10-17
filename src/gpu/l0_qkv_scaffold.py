"""l0_qkv_scaffold.py -- TEMPORARY image-quality scaffold (user ruling 2026-10-17).

If the file `work/l0_qkv` exists when a Runtime is constructed, the game's QKV door --
`gemm_qkv`, the fp16 coopmat one the shipping config actually takes (the `int8_qkv`
flag is decided at construction and NOT re-decided by set_int8: xmxres.py:840's own
confession "a switch that measured as working while doing nothing at all in a real
run") -- is swapped to my L0 int8 straight-through chain (the six passes gated in
section 46), boundary-published back to the shipped e4m3-halves so every downstream
coopmat consumer is untouched. This is NOT the shipping design: the host bounce costs
a round-trip per QKV; it exists so the user can SEE my chain's picture in Lies of P.
Delete work/l0_qkv and the daemon runs the shipped path untouched.

Every failure mode falls back to the original door and says so once -- the game must
always produce an image, scaffold never worse than shipped.
"""
import ctypes
import os
import pathlib

import numpy as np

MARKER = "l0_qkv"
_C = {"swapped": 0, "fellback": 0, "printed": 0}
_LIB = {"dll": None}


def _load_l0():
    """Load libxmx_sycl.dll (Level Zero) alongside the running Vulkan libxmx.dll. The
    section-18 probe already proved the two coexist on this box (same A770, separate
    contexts); buffer passing is host-bounce here, not interop -- scaffold, not design."""
    repo = pathlib.Path(__file__).resolve().parents[2]
    oner = repo.parent.parent
    for d in (str(oner / "oneapi"), r"E:\WorkBuddy\toolchain-mamba\sycl\Library\bin",
              r"E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64"):
        if os.path.isdir(d):
            try: os.add_dll_directory(d)
            except OSError: pass
    k = ctypes.windll.kernel32
    k.SetErrorMode(0x8002)
    for dep in ("libmmd.dll", "tbb12.dll", "ur_win_proxy_loader.dll", "ur_loader.dll", "sycl9.dll"):
        p = oner / "oneapi" / dep
        if p.exists():
            k.LoadLibraryExW(str(p), 0, 0)
    dll = ctypes.CDLL(str(oner / "oneapi" / "libxmx_sycl.dll"))
    dll.xmx_error.restype = ctypes.c_char_p
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
        getattr(dll, nm).argtypes = at
        getattr(dll, nm).restype = ctypes.c_int
    if dll.xmx_init() != 0:
        raise RuntimeError("L0 init: " + dll.xmx_error().decode())
    return dll


def install_l0_qkv(rt):
    import xmxres, int8_quant, nr_model as NM
    dll = _load_l0()
    _LIB["dll"] = dll
    orig = rt.gemm_qkv

    # the shipped non-window gemm_qkv path needs a (rows, C) half buffer: without
    # fuse_partition the graph records a partition pass first, and the gather's values
    # are the shipping partition's own bytes (bit-identical, resident.comp's reference) --
    # we reuse the shipping pass instead of writing our own gather.
    rt.fuse_partition = False
    # replay mode replays a CACHED Vulkan command graph and never calls the Python
    # recorders -- the bounce would silently never fire (the swapped=0 trap of today).
    os.environ["NR_FRAME_MODE"] = "block"

    def bounce(a, weight, q, k, v, scale, rows, channels, heads, tokens, *,
               window=None, image_half=False, publish_image=False, vit=False):
        if vit or window is not None or tokens != 64 or (rows % 128) or (channels % 64):
            return orig(a, weight, q, k, v, scale, rows, channels, heads, tokens,
                        window=window, image_half=image_half, publish_image=publish_image,
                        vit=vit)
        try:
            rt.submit()                     # the int8_bottleneck.py int8_rows pattern
            av = xmxres.host_view(a, np.float16, shape=(rows, channels))
            a8, asc = int8_quant.quantise(av.astype(np.float32), axis=1)   # §30: bit-exact
            # resident weight layout is (C, 3C) row-major (input-major), the LOGICAL
            # orientation -- NOT the (3C, C) gemm_int8_qkv buffer form. Orientation trap,
            # checked against nr_model's qkv_weight shape (test_nr_model.py:97: (64,192)).
            wv = xmxres.host_view(weight, np.float16, shape=(channels, 3 * channels))
            w8, wsc = int8_quant.quantise(wv.astype(np.float32), axis=0)  # per output column
            sc = xmxres.host_view(scale, np.float32, shape=(heads,)).copy()
            windows = rows // tokens
            mb = lambda n, kind: dll.xmx_buf_create_kind(n, kind)
            ma = mb(rows * channels, 1)
            mQ = mb(channels * channels, 1); mK = mb(channels * channels, 1)
            mV = mb(channels * channels, 1)
            mas = mb(rows * 4, 4)
            mQs = mb(channels * 4, 4); mKs = mb(channels * 4, 4); mVs = mb(channels * 4, 4)
            mqf = mb(rows * channels * 4, 4); mkf = mb(rows * channels * 4, 4)
            mq8 = mb(rows * channels, 1); mk8 = mb(rows * channels, 1)
            mv8 = mb(rows * channels, 1)
            mqs = mb(rows * heads * 4, 4); mks = mb(rows * heads * 4, 4)
            mvs = mb(windows * channels * 4, 4); mqkvs = mb(heads * 4, 4)
            def up(h, arr, n):
                if dll.xmx_buf_upload(h, np.ascontiguousarray(arr).ctypes.data, 0, n) != 0:
                    raise RuntimeError("upload: " + dll.xmx_error().decode())
            up(ma, a8, rows * channels)
            up(mQ, np.ascontiguousarray(w8[:, 0:channels]), channels * channels)
            up(mK, np.ascontiguousarray(w8[:, channels:2 * channels]), channels * channels)
            up(mV, np.ascontiguousarray(w8[:, 2 * channels:3 * channels]), channels * channels)
            up(mas, asc, rows * 4)
            up(mQs, wsc[0:channels], channels * 4); up(mKs, wsc[channels:2 * channels], channels * 4)
            up(mVs, wsc[2 * channels:3 * channels], channels * 4)
            up(mqkvs, sc, heads * 4)
            for h in (mqf, mkf, mq8, mk8, mv8, mqs, mks, mvs): dll.xmx_buf_zero(h)
            dll.xmx_begin()
            def call(fn, *args):
                if fn(*args) != 0:
                    raise RuntimeError(fn.__name__ + ": " + dll.xmx_error().decode())
            call(dll.xmx_rec_gemm_qkv_v_i8, ma, mV, mv8, mvs, mas, mVs,
                 rows, channels, heads, tokens)
            call(dll.xmx_rec_gemm_qkv_deq, ma, mQ, mqf, mas, mQs, rows, channels)
            call(dll.xmx_rec_cosine_norm_i8, mqf, mq8, mqs, rows * heads, 0, mqkvs, heads)
            call(dll.xmx_rec_gemm_qkv_deq, ma, mK, mkf, mas, mKs, rows, channels)
            call(dll.xmx_rec_cosine_norm_i8, mkf, mk8, mks, rows * heads, 0, 0, 0)
            if dll.xmx_submit() != 0:
                raise RuntimeError("submit: " + dll.xmx_error().decode())
            def dlf(h, n, dt):
                arr = np.zeros(n, dt)
                if dll.xmx_buf_download(h, arr.ctypes.data, 0, arr.nbytes) != 0:
                    raise RuntimeError("download: " + dll.xmx_error().decode())
                return arr
            q8 = dlf(mq8, rows * channels, np.int8).reshape(rows * heads, 32)
            k8 = dlf(mk8, rows * channels, np.int8).reshape(rows * heads, 32)
            v8 = dlf(mv8, rows * channels, np.int8)          # already scattered (section 41)
            qsc = dlf(mqs, rows * heads, np.float32)[:, None]
            ksc = dlf(mks, rows * heads, np.float32)[:, None]
            vsc = dlf(mvs, windows * channels, np.float32)
            for h in (ma, mQ, mK, mV, mas, mQs, mKs, mVs, mqf, mkf, mq8, mk8, mv8,
                      mqs, mks, mvs, mqkvs):
                dll.xmx_buf_destroy(h)
            # boundary publish: e4m3(int8 * scale) -> the shipped f16 container
            qp = NM.e4m3(q8.astype(np.float32) * qsc).astype(np.float16).reshape(rows, channels)
            kp = NM.e4m3(k8.astype(np.float32) * ksc).astype(np.float16).reshape(rows, channels)
            # my Q/K are linear (row=w*tokens+t, col=h*32+c); the consumers read the
            # shipped scatter (w,h,t,c) contiguous -- one transpose, no per-element loop.
            qp = qp.reshape(windows, tokens, heads, 32).transpose(0, 2, 1, 3).ravel()
            kp = kp.reshape(windows, tokens, heads, 32).transpose(0, 2, 1, 3).ravel()
            vs3 = vsc.reshape(windows, heads, 32)[:, :, None, :]       # (w,h,1,32) over v8's (w,h,t,c)
            vp = NM.e4m3(v8.reshape(windows, heads, tokens, 32).astype(np.float32)
                         * vs3).astype(np.float16)
            xmxres.host_write(q, qp)
            xmxres.host_write(k, kp)
            xmxres.host_write(v, vp.ravel())
            _C["swapped"] += 1
            if _C["swapped"] % 40 == 1:
                print(f"  [l0_qkv scaffold] swapped={_C['swapped']} fellback={_C['fellback']} "
                      f"rows={rows} C={channels} heads={heads}", flush=True)
            rt.begin()
            return rt
        except Exception as e:
            _C["fellback"] += 1
            if _C["printed"] < 3:
                _C["printed"] += 1
                print(f"  [l0_qkv scaffold] FALLBACK to shipped gemm_qkv: {e}", flush=True)
            return orig(a, weight, q, k, v, scale, rows, channels, heads, tokens,
                        window=window, image_half=image_half, publish_image=publish_image,
                        vit=vit)

    rt.gemm_qkv = bounce
    print(f"  [l0_qkv scaffold] armed: marker {MARKER} present; QKV door -> L0 int8 chain "
          f"(block mode forced, fuse_partition off for the bounce path)", flush=True)


def report():
    print(f"  [l0_qkv scaffold] totals: swapped={_C['swapped']} fellback={_C['fellback']}",
          flush=True)
