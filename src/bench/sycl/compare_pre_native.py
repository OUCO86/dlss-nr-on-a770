#!/usr/bin/env python3
"""Compare the native level_zero pre_kernel output (_pre_device.bin) against the
nr_pre.comp line-by-line numpy golden, reading the SAME input bytes the exe dumped.
This is the pre numerical validation on the game's actual backend (level_zero); the
Python ctypes harness can't reach level_zero (section 60), so the native exe produces
the device side and this script the golden side from identical inputs.
"""
import numpy as np, pathlib, sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
D = pathlib.Path(r"E:\WorkBuddy\2026-10-09-04-20-55\oneapi")

H = W = SH = SW = 16; pitch = SW; pixels = H * W
colour = np.frombuffer((D / "_pre_colour.bin").read_bytes(), np.uint32)
motion = np.frombuffer((D / "_pre_motion.bin").read_bytes(), np.float32)
prev = np.frombuffer((D / "_pre_prev.bin").read_bytes(), np.float32)
plan = np.frombuffer((D / "_pre_plan.bin").read_bytes(), np.float32)
table = np.frombuffer((D / "_pre_table.bin").read_bytes(), np.float32)
got = np.frombuffer((D / "_pre_device.bin").read_bytes(), np.uint8)

def half_(x): return np.float32(np.float16(x))
def decode11(v):
    e = (v >> 6) & 0x1F; m = v & 0x3F
    return 0.0 if e == 0 else float(64 + m) * np.float32(2.0 ** (e - 21))
def decode10(v):
    e = (v >> 5) & 0x1F; m = v & 0x1F
    return 0.0 if e == 0 else float(32 + m) * np.float32(2.0 ** (e - 20))
def catmull(normalized, dimension):
    pixel = np.float32(normalized) * np.float32(dimension) - np.float32(0.5)
    base_index = np.floor(pixel)
    t = np.clip(pixel - base_index, 0.0, 1.0)
    square = t * t; cube = square * t
    weight0 = -0.5 * t + square - 0.5 * cube
    w1 = 1.0 - 2.5 * square + 1.5 * cube
    w2 = 0.5 * t + 2.0 * square - 1.5 * cube
    weight3 = -0.5 * square + 0.5 * cube
    gain = w1 + w2
    base = base_index + 0.5
    lower = 0.5; upper = float(dimension) - 0.5
    return (np.clip(base - 1.0, lower, upper), np.clip(base + (0.0 if gain == 0 else w2 / gain), lower, upper),
            np.clip(base + 2.0, lower, upper), weight0, weight3, gain)
def bilinear(x, y, height, width, prev):
    px = x - 0.5; py = y - 0.5
    x0 = int(np.clip(np.floor(px), 0, width - 1)); y0 = int(np.clip(np.floor(py), 0, height - 1))
    x1 = min(x0 + 1, width - 1); y1 = min(y0 + 1, height - 1)
    tx = np.clip(px - x0, 0.0, 1.0); ty = np.clip(py - y0, 0.0, 1.0)
    out = []
    for ch in range(3):
        top = prev[(y0 * width + x0) * 3 + ch] * (1 - tx) + prev[(y0 * width + x1) * 3 + ch] * tx
        bot = prev[(y1 * width + x0) * 3 + ch] * (1 - tx) + prev[(y1 * width + x1) * 3 + ch] * tx
        out.append(top * (1 - ty) + bot * ty)
    return out

noiseAt = 0; controlAt = H * W * 3; rowsAt = controlAt + 5; columnsAt = rowsAt + H
fresh = table[65539]
def golden_pixel(pixel):
    x = pixel % W; y = pixel // W
    row = int(np.frombuffer(np.float32(plan[rowsAt + y]).tobytes(), np.int32)[0])
    column = int(np.frombuffer(np.float32(plan[columnsAt + x]).tobytes(), np.int32)[0])
    source = row * SW + column
    word = int(colour[row * pitch + column])
    rgb = [decode11(word & 0x7FF), decode11((word >> 11) & 0x7FF), decode10((word >> 22) & 0x3FF)]
    exposure = table[65538]
    if exposure > 0: rgb = [np.float32(np.float32(c) / np.float32(exposure)) for c in rgb]
    display = [max(c, 0.0) for c in rgb]
    lit = 0.2126 * display[0] + 0.7152 * display[1] + 0.0722 * display[2]
    if lit > 0.75:
        rolled = 0.75 + 0.25 * (1 - np.exp(-(lit - 0.75) / 0.25))
        scale = rolled / max(lit, 1e-6)
    else:
        scale = 1.0
    rgb = [np.float32(c) * np.float32(scale) for c in rgb]
    su = np.float32((x + 0.5) / W) + np.float32(motion[source * 2] / W)
    sv = np.float32((y + 0.5) / H) + np.float32(motion[source * 2 + 1] / H)
    u = su if su >= 0 else 0.0; v = sv if sv >= 0 else 0.0
    u = min(max(u, 0.0), 1.0); v = min(max(v, 0.0), 1.0)
    xo0, xm, xo3, xw0, xw3, xg = catmull(u, W)
    yo0, ym, yo3, yw0, yw3, yg = catmull(v, H)
    weights = [xw0 * yg, xg * yw0, xg * yg, xg * yw3, xw3 * yg]
    coords = [(xo0, ym), (xm, yo0), (xm, ym), (xm, yo3), (xo3, ym)]
    was = [0.0, 0.0, 0.0]
    for i in range(5):
        tap = bilinear(coords[i][0], coords[i][1], H, W, prev)
        for ch in range(3): was[ch] += weights[i] * tap[ch]
    denom = sum(weights)
    was = [np.float32(w) / np.float32(denom) for w in was]
    values = [0.0] * 16
    for ch in range(3):
        scaled = half_(half_(half_(rgb[ch]) - 0.5) * 0.125)
        values[ch] = plan[noiseAt + pixel * 3 + ch]
        values[4 + ch] = scaled
        values[7 + ch] = scaled if fresh != 0 else half_(half_(half_(was[ch]) - 0.5) * 0.125)
    values[3] = 1.0
    for ch in range(5): values[10 + ch] = plan[controlAt + ch]
    values[15] = 0.0
    return [np.float16(v) for v in values]

want = np.array([v for p in range(pixels) for v in golden_pixel(p)], np.float16)
gh = got.view(np.uint16); wh = want.view(np.uint16)
gz = (gh & 0x7FFF) == 0; wz = (wh & 0x7FFF) == 0
gf = got.view(np.float16).astype(np.float32); wf = want.astype(np.float32)
tol = np.maximum(np.abs(wf) * 2.0 ** -10, 2.0 ** -13)
within = (np.abs(gf - wf) <= tol) | (gz & wz)
nbad = int((~within).sum())
print(f"device features vs nr_pre.comp golden: {nbad} bad of {gh.size}")
if nbad:
    for e in np.flatnonzero(~within)[:12]:
        p, c = divmod(int(e), 16)
        print(f"  pixel {p} ch {c}: got {gf[e]:.6g} want {wf[e]:.6g}")
print("PRE_NATIVE " + ("GREEN" if nbad == 0 else "RED"))
sys.exit(1 if nbad else 0)
