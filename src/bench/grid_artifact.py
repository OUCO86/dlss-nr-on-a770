"""What the head's upscale does to a smooth gradient.

The head comes out of the network at the network's extent (768x448 for a 1920x1080
frame at render_scale 0.4) and is interpolated up to the frame's before it is
composed. The plan it uses is `nr_image._axis_plan`: two taps, a linear weight.
That is C0 but not C1 — the slope jumps at every source grid line, which is 2.5
output pixels apart here.

In a textured region that jump is buried. In a full-screen translucent light —
a fire's glow, where there is no texture to hide behind — the eye is very good at
seeing a first-derivative discontinuity, and it sees it as a line. That is the
mach band, and it is what a "patchwork" of "seams" would be made of.

This measures it: how big the slope jump is, how far it stands above what the
true signal would give, and what three other kernels would do instead.
"""

import numpy as np

EXTENT, COUNT = 768, 1920          # head columns -> frame columns
RATIO = COUNT / EXTENT             # 2.5


def axis_plan(extent, count):
    """`nr_image._axis_plan`, verbatim."""
    centres = (np.arange(count, dtype=np.float64) + 0.5) * (extent / count) - 0.5
    low = np.clip(np.floor(centres), 0, extent - 1)
    high = np.clip(low + 1, 0, extent - 1)
    weight = np.clip(centres - low, 0.0, 1.0)
    return low.astype(int), high.astype(int), weight


def upscale(src, count, kernel):
    """One axis. `kernel(w)` is the weight given to the high tap."""
    extent = len(src)
    low, high, w = axis_plan(extent, count)
    return src[low] * (1.0 - kernel(w)) + src[high] * kernel(w)


KERNELS = {
    "bilinear  (what runs now)": lambda w: w,
    "smoothstep  w*w*(3-2w)":    lambda w: w * w * (3.0 - 2.0 * w),
    "catmull-rom (4 tap)":       "cubic",
    "b-spline    (4 tap)":       "bspline",
}


def cubic(src, count):
    """Catmull-Rom through the four nearest samples."""
    extent = len(src)
    centres = (np.arange(count, dtype=np.float64) + 0.5) * (extent / count) - 0.5
    i = np.floor(centres).astype(int)
    t = centres - i
    pad = np.r_[src[0], src, src[-1], src[-1]]

    def g(k):
        return pad[np.clip(i + k, 0, extent - 1) + 1]

    p0, p1, p2, p3 = g(-1), g(0), g(1), g(2)
    return (p1 + 0.5 * t * (p2 - p0 + t * (2 * p0 - 5 * p1 + 4 * p2 - p3
                                           + t * (3 * (p1 - p2) + p3 - p0))))


def bspline(src, count):
    extent = len(src)
    centres = (np.arange(count, dtype=np.float64) + 0.5) * (extent / count) - 0.5
    i = np.floor(centres).astype(int)
    t = centres - i
    pad = np.r_[src[0], src, src[-1], src[-1]]
    g = lambda k: pad[np.clip(i + k, 0, extent - 1) + 1]
    p0, p1, p2, p3 = g(-1), g(0), g(1), g(2)
    return (p0 * (1 - t) ** 3 + p1 * (3 * t ** 3 - 6 * t ** 2 + 4)
            + p2 * (-3 * t ** 3 + 3 * t ** 2 + 3 * t + 1) + p3 * t ** 3) / 6.0


def source(kind):
    """Two extents of smooth light, sampled at the head's resolution."""
    u = np.arange(EXTENT, dtype=np.float64) / EXTENT
    if kind == "glow":
        # A fire's glow across half the frame: broad, no texture, the whole point.
        return 0.25 + 0.45 * np.exp(-((u - 0.42) / 0.22) ** 2)
    return 0.30 + 0.10 * (1.0 + np.cos(2 * np.pi * (u - 0.5))) / 2.0


def truth(signal, count):
    """The same light sampled where the frame's pixels are, with no upscale in
    between. This is what the eye would have been given had the network run at the
    frame's extent, and it is the only fair reference: it has the network's own
    resolution limit in it already, since both come from the same 768 samples."""
    v = np.arange(count, dtype=np.float64) / count
    if signal == "glow":
        return 0.25 + 0.45 * np.exp(-((v - 0.42) / 0.22) ** 2)
    return 0.30 + 0.10 * (1.0 + np.cos(2 * np.pi * (v - 0.5))) / 2.0


def measure(y, ref):
    """How visible the grid is, and how much detail the kernel kept.

    `seam` is the largest jump in the output's own slope, measured against the
    largest the true signal would give on its own. A slope that jumps where the
    true one does not is a line the eye can find. `flat` is what it costs: how
    much of the signal's own gradient the kernel has taken out.
    """
    g = np.diff(y)
    gg = np.diff(g)                       # the jump in the slope
    refg = np.diff(ref)
    refgg = np.diff(refg)
    seam = np.abs(gg).max() / max(np.abs(refgg).max(), 1e-12)
    flat = 1.0 - np.abs(g).max() / max(np.abs(refg).max(), 1e-12)
    return seam, flat, np.abs(y - ref).max()


print(f"the head's {EXTENT} columns become the frame's {COUNT}: {RATIO:.2f}x\n")
for signal in ("glow", "ramp"):
    src = source(signal)
    ref = truth(signal, COUNT)
    print(f"--- {signal} ---")
    print(f"  {'kernel':30s} {'seam':>8s} {'flat':>8s} {'maxerr':>10s}")
    for name, kernel in KERNELS.items():
        y = (cubic(src, COUNT) if kernel == "cubic"
             else bspline(src, COUNT) if kernel == "bspline"
             else upscale(src, COUNT, kernel))
        seam, flat, err = measure(y, ref)
        print(f"  {name:30s} {seam:8.1f}x {flat * 100:7.2f}% {err:10.6f}")
    print()

# Where the seams fall: the period of the slope jumps, in output pixels.
src = source("glow")
y = upscale(src, COUNT, KERNELS["bilinear  (what runs now)"])
g = np.diff(y)
gg = np.abs(np.diff(g))
peaks = np.argsort(gg)[-12:]
print("the twelve biggest slope jumps land at output columns:",
      sorted(int(p) for p in peaks))
print(f"gaps between them: {np.diff(sorted(peaks)).tolist()}")
print(f"the grid line is {RATIO:.1f} output pixels apart, so a period of "
      f"{RATIO:.1f} here is the upscale's own structure")

# And what it is worth in the frame's bytes.
blend, head_share = 1.0, 0.25
print(f"\nthe head reaches the frame through `out = rgb + blend * (predicted - rgb)`")
print(f"and `predicted = rgb + half(h) * {head_share}`, so a head error of e costs "
      f"the frame {blend * head_share:.2f} * e")
print(f"one 8-bit level is {1 / 255:.6f}, so the head would have to be wrong by "
      f"{1 / 255 / (blend * head_share):.6f} to move the frame one level")
