#!/usr/bin/env python3
"""merge_heads foundation gate (route(a) step 3, section 84).

resident.comp:626-641 MERGE_HEADS transcribed to numpy: (windows,heads,tokens,32) ->
(windows,tokens,C). For output index (c, rest): token=rest%tokens, window=rest/tokens,
at=(window*heads + c/32)*tokens + token, value=load_a(at*32 + c%32), then store =
publish(epi, value) -> half iff narrow. The 4th leg of window_attention's four-pass
golden (test_window_attention.py:55: rt.merge_heads(expected, expected_merge, ...,
epilogue=EPI_E4M3, narrow=True)). Input is the attnV f32 context (f32 load), output
half. publish chain = the already-gated qr_publish (PUBLISH gate).
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
    ("xmx_rec_merge_heads", [ctypes.c_int] * 2 + [ctypes.c_uint] * 6),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def run(windows, tokens, channels, heads, epilogue, narrow, label):
    global fails
    assert channels == heads * 32
    rng = np.random.default_rng(8480 + windows + tokens * 3 + channels * 5 + epilogue)
    src = rng.uniform(-2, 2, size=windows * heads * tokens * 32).astype(np.float32)
    wsz = 2 if narrow else 4
    hs = lib.xmx_buf_create_kind(src.nbytes, 4)
    hd = lib.xmx_buf_create_kind(windows * tokens * channels * wsz, wsz)
    ok(min(hs, hd) > 0, f"{label}: buffers")
    lib.xmx_buf_upload(hs, np.ascontiguousarray(src).ctypes.data, 0, src.nbytes)
    lib.xmx_buf_zero(hd)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_merge_heads(hs, hd, windows, tokens, channels, heads, epilogue, 1 if narrow else 0)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    got = np.zeros(windows * tokens * channels * wsz, np.uint8)
    lib.xmx_buf_download(hd, got.ctypes.data, 0, windows * tokens * channels * wsz)
    lib.xmx_buf_destroy(hs); lib.xmx_buf_destroy(hd)

    # golden: numpy reshape (windows,heads,tokens,32) -> (windows,tokens,heads*32)
    s4 = src.reshape(windows, heads, tokens, 32)
    out = np.zeros((windows, tokens, channels), np.float32)
    for w in range(windows):
        for t in range(tokens):
            for c in range(channels):
                out[w, t, c] = s4[w, c // 32, t, c % 32]
    flat = out.reshape(-1)
    if epilogue == 1: v = NM.e4m3(flat)
    elif epilogue == 3: v = NM.e4m3(NM.quadratic_gate_activation(flat))
    elif epilogue == 2: v = NM.quadratic_gate_activation(flat)
    elif epilogue == 4: v = NM._half_rounded(flat)
    else: v = flat
    want = (np.asarray(v, np.float16) if narrow else np.asarray(v, np.float32)).view(np.uint8)
    same = np.array_equal(got, want)
    nbad = int((got != want).sum())
    ok(same, f"{label}: OUT BITS EQUAL ({windows}x{tokens}x{channels} epi={epilogue} narrow={narrow}, {nbad} bad)")

run(2, 64, 128, 4, 1, True, "MH-2x64x128-epi1")     # window_attention's real merge shape
run(1, 64, 512, 16, 1, True, "MH-1x64x512-epi1")
run(3, 64, 64, 2, 1, True, "MH-3x64x64-epi1")
run(2, 64, 128, 4, 0, False, "MH-f32out-stress")    # no publish, f32 out (recorder supports)

print(f"\nMERGE_HEADS {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
