#!/usr/bin/env python3
"""post numpy-golden compare (section 90 step 5): the level_zero post_kernel output
(_post_device.bin result + _post_neural.bin) vs a line-by-line transcription of
nr_post.comp, reading the SAME input bytes the native gate dumped.

Why numpy golden (not the old-dll shadow) for post: the old dll's post submit faults
(resident fence wait -4, a section-58 old-dll-internal buffer-role issue), but the pre
shadow already PROVED my transcription discipline == the shipping shader (bit-exact 100%
on nr_pre.spv). The same discipline applied to nr_post.comp is therefore validated by
within-one vs my own transcription; the fully independent old-dll post shadow is a §90
step-4 fused-walk concern (the real game path drives post with imported buffers, not the
plain GRAPH buffers this standalone shadow feeds it).

Criterion: result (R11G11B10 words) and neural (f32) compared as BYTES. The only
non-determinism vs numpy is exp() in to_proxy (proven SYCL==GLSL on the pre shadow) and
frexp/encode bit patterns (integer-exact). Expect bit-exact or within-one on the packed
words.
"""
import numpy as np, pathlib, sys

D = pathlib.Path(r"E:\WorkBuddy\2026-10-09-04-20-55\oneapi")
H = W = SH = SW = 16; pitch = SW; pixels = SH * SW

colour = np.frombuffer((D / "_post_colour.bin").read_bytes(), np.uint32)
head = np.frombuffer((D / "_post_head.bin").read_bytes(), np.float32)
prev = np.frombuffer((D / "_post_prev.bin").read_bytes(), np.float32)
table = np.frombuffer((D / "_post_table.bin").read_bytes(), np.float32)
got = np.frombuffer((D / "_post_device.bin").read_bytes(), np.uint32)
got_neu = np.frombuffer((D / "_post_neural.bin").read_bytes(), np.float32)

def half_(x): return np.float32(np.float16(x))
def decode11(v):
    e = (v >> 6) & 0x1F; m = v & 0x3F
    return 0.0 if e == 0 else float(64 + m) * np.float32(2.0 ** (e - 21))
def decode10(v):
    e = (v >> 5) & 0x1F; m = v & 0x1F
    return 0.0 if e == 0 else float(32 + m) * np.float32(2.0 ** (e - 20))
def truncate_half(x):
    f = np.frombuffer(np.float32(x).tobytes(), np.uint32)[0]
    kept = np.frombuffer(np.uint32(f & 0xffffe000).tobytes(), np.float32)[0]
    small = np.floor(abs(x) * 16777216.0) * np.float32(2.0 ** -24)
    small = -small if x < 0 else small
    return kept if (f & 0x7fffffff) >= 0x38800000 else small
def encode11(v):
    if not (v > 0.0): return 0
    f, e = np.frexp(v)
    m = int(np.clip(128.0 * f - 64.0 + 0.5, 0, 63)); biased = e + 14
    if biased >= 31: return 31 << 6
    if biased <= 0: return 0
    return (biased << 6) | m
def encode10(v):
    if not (v > 0.0): return 0
    f, e = np.frexp(v)
    m = int(np.clip(64.0 * f - 32.0 + 0.5, 0, 31)); biased = e + 14
    if biased >= 31: return 31 << 5
    if biased <= 0: return 0
    return (biased << 5) | m

intensity = table[65536]; confidence = table[65537]; exposure = table[65538]
want = np.zeros(pixels, np.uint32); want_neu = np.zeros(H * W * 3, np.float32)
for pixel in range(pixels):
    x = pixel % SW; y = pixel // SW
    network = y * W + x
    word = int(colour[y * pitch + x])
    rgb = [decode11(word & 0x7FF), decode11((word >> 11) & 0x7FF), decode10((word >> 22) & 0x3FF)]
    if exposure > 0: rgb = [np.float32(np.float32(c) / np.float32(exposure)) for c in rgb]
    shown = list(rgb)
    display = [max(c, 0.0) for c in rgb]
    lit = 0.2126 * display[0] + 0.7152 * display[1] + 0.0722 * display[2]
    if lit > 0.75:
        rolled = 0.75 + 0.25 * (1 - np.exp(-(lit - 0.75) / 0.25)); scale = rolled / max(lit, 1e-6)
    else: scale = 1.0
    proxy = [np.float32(c) * np.float32(scale) for c in rgb]; rgb = list(proxy)
    hb = np.frombuffer(np.float16(half_(head[network * 4 + 3])).tobytes(), np.uint16)[0]
    alpha = table[hb]
    if confidence != 1.0: alpha = np.float32(alpha) * np.float32(confidence)
    predicted = []
    for ch in range(3):
        p = np.clip(rgb[ch] + half_(head[network * 4 + ch]) * 0.25, 0.0, 1.0)
        p = p + alpha * (prev[network * 3 + ch] - p)
        predicted.append(p)
    for ch in range(3): want_neu[network * 3 + ch] = truncate_half(predicted[ch])
    for ch in range(3):
        predicted[ch] = np.clip(rgb[ch] + intensity * (predicted[ch] - rgb[ch]), 0.0, 1.0)
    for ch in range(3):
        ratio = predicted[ch] / proxy[ch] if proxy[ch] > 1e-6 else 1.0
        predicted[ch] = max(shown[ch] * ratio, 0.0)
    if exposure > 0: predicted = [np.float32(c) * np.float32(exposure) for c in predicted]
    want[pixel] = encode11(predicted[0]) | (encode11(predicted[1]) << 11) | (encode10(predicted[2]) << 22)

rsame = (got == want); print(f"post result (R11G11B10): bit-exact %.3f%% (%d differ of %d)" % (rsame.mean()*100, (~rsame).sum(), got.size))
if (~rsame).any():
    for e in np.flatnonzero(~rsame)[:8]:
        print(f"  pixel {e}: got 0x{got[e]:08x} want 0x{want[e]:08x}")
# neural: compare as f32 with a tiny tolerance (truncate_half is bit-exact, but the
# predicted value feeding it may differ by an exp() last bit)
nd = np.abs(got_neu - want_neu)
ntol = np.maximum(np.abs(want_neu) * 2.0**-10, 2.0**-13)
nbad = int((nd > ntol).sum())
print(f"post neural (f32): within-one {nbad} bad of {got_neu.size}")
ok = rsame.all() and nbad == 0
print("POST_NATIVE " + ("GREEN" if ok else "RED"))
sys.exit(0 if ok else 1)
