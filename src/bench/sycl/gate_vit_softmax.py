#!/usr/bin/env python3
"""vit_softmax foundation gate (route(a) step 3, section 86).

attention.comp:221-241 `vit_softmax` TRANSCRIBED to numpy (the .comp is the authority,
section 34/76 discipline -- nr_model.vit_attend is only within-one, not this):
  blocks = ceil(tokens/64); zero = vit_weight(0)
  per block b: for c in 0..7: pair[j] (j 0..3) = hadd(w0,w1), k0=b*64+c+16j, k1=k0+8,
     w = k<tokens ? vit_weight(a[base+k]) : zero; column[c] = hadd(hadd(hadd(p0,p1),p2),p3)
  even = hadd(hadd(hadd(c0,c2),c4),c6); odd = hadd(hadd(hadd(c1,c3),c5),c7)
  total = hadd(total, hadd(even,odd))
  padding = blocks*64 - tokens; if padding>0: total = hadd(total, -hmul(zero,padding))
  reciprocal[row] = half_round(1.0/total)
  store(base+k) = k<tokens ? e4m3(vit_weight(a[base+k])) : 0.0   (narrow: half out)
hadd/hmul = half_round(f32 op) (cosine_tree.glsl:16-17). vit_weight = the ViT's own
affine + 4-bit shift (attention.comp:297-302). Compare: probs as half BYTES (0-differ),
reciprocals as f32 BITS.
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
    ("xmx_rec_vit_softmax", [ctypes.c_int] * 3 + [ctypes.c_uint] * 3),
):
    getattr(lib, nm).argtypes = at
    getattr(lib, nm).restype = ctypes.c_int

fails = 0
def ok(cond, msg):
    global fails
    print(("ok    " if cond else "FAIL  ") + msg, flush=True)
    if not cond: fails += 1

ok(lib.xmx_init() == 0, "init")

def hr(x): return np.float32(np.float16(np.float32(x)))
def hadd(l, r): return hr(np.float32(l) + np.float32(r))
def hmul(l, r): return hr(np.float32(l) * np.float32(r))

def vit_weight(logit):
    affine = hr(hr(np.float32(logit)) * np.float32(0.08953857421875) + np.float32(1.708984375))
    affine = np.clip(affine, np.float32(1.439453125), np.float32(1.9775390625))
    bits = np.asarray(affine, np.float16).reshape(1).view(np.uint16)[0]
    shifted = np.uint16(((np.uint32(bits) << 4) + np.uint32(0x4000)) & np.uint32(0xFFFF))
    return float(np.asarray(shifted, np.uint16).reshape(1).view(np.float16)[0])

def run(rows, tokens, stride, label):
    global fails
    if stride == 0: stride = tokens
    rng = np.random.default_rng(8680 + rows + tokens * 3 + stride * 5)
    src = rng.uniform(-6, 6, size=rows * stride).astype(np.float32)
    hs = lib.xmx_buf_create_kind(rows * stride * 4, 4)
    hd = lib.xmx_buf_create_kind(rows * stride * 2, 2)
    hr_ = lib.xmx_buf_create_kind(rows * 4, 4)
    ok(min(hs, hd, hr_) > 0, f"{label}: buffers")
    lib.xmx_buf_upload(hs, np.ascontiguousarray(src).ctypes.data, 0, rows * stride * 4)
    lib.xmx_buf_zero(hd); lib.xmx_buf_zero(hr_)
    ok(lib.xmx_begin() == 0, f"{label}: begin")
    rc = lib.xmx_rec_vit_softmax(hs, hd, hr_, rows, tokens, stride)
    ok(rc == 0, f"{label}: rec" + ("" if rc == 0 else " err=" + lib.xmx_error().decode(errors="replace")))
    ok(lib.xmx_submit() == 0, f"{label}: submit")
    gp = np.zeros(rows * stride, np.float16); lib.xmx_buf_download(hd, gp.ctypes.data, 0, rows * stride * 2)
    gr = np.zeros(rows, np.float32); lib.xmx_buf_download(hr_, gr.ctypes.data, 0, rows * 4)
    for h in (hs, hd, hr_): lib.xmx_buf_destroy(h)

    # golden: the .comp transcription
    blocks = (tokens + 63) // 64
    zero = vit_weight(0.0)
    wprobs = np.zeros(rows * stride, np.float16)
    wrec = np.zeros(rows, np.float32)
    for r in range(rows):
        base = r * stride
        total = np.float32(0.0)
        for b in range(blocks):
            column = [np.float32(0.0)] * 8
            for c in range(8):
                pair = []
                for j in range(4):
                    k0 = b * 64 + c + 16 * j; k1 = k0 + 8
                    w0 = vit_weight(src[base + k0]) if k0 < tokens else zero
                    w1 = vit_weight(src[base + k1]) if k1 < tokens else zero
                    pair.append(hadd(w0, w1))
                column[c] = hadd(hadd(hadd(pair[0], pair[1]), pair[2]), pair[3])
            even = hadd(hadd(hadd(column[0], column[2]), column[4]), column[6])
            odd = hadd(hadd(hadd(column[1], column[3]), column[5]), column[7])
            total = hadd(total, hadd(even, odd))
        padding = blocks * 64 - tokens
        if padding > 0: total = hadd(total, -hmul(zero, np.float32(padding)))
        wrec[r] = hr(np.float32(1.0) / total)
        for k in range(stride):
            wprobs[base + k] = np.float16(NM.e4m3(np.float32(vit_weight(src[base + k])))) if k < tokens else np.float16(0.0)
    samep = np.array_equal(gp.view(np.uint16), wprobs.view(np.uint16))
    samer = np.array_equal(gr.view(np.uint32), wrec.view(np.uint32))
    ok(samep and samer, f"{label}: probs 0-differ={samep} reciprocals bits-equal={samer} "
                        f"({rows}x{tokens} stride={stride})")

run(64, 64, 64, "VS-64x64")            # one full block
run(64, 64, 96, "VS-64x64-stride96")   # stride > tokens (pad columns)
run(128, 240, 256, "VS-128x240")       # partial last block + padding correction
run(32, 17, 32, "VS-32x17-odd")        # odd tokens, one block, padding
run(640, 640, 640, "VS-640x640")       # 10 blocks (the 1280x768 bottleneck)

print(f"\nVIT_SOFTMAX {'GREEN' if not fails else 'RED'} ({fails} fails)")
sys.exit(1 if fails else 0)
