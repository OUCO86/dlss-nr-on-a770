"""Is the patchwork the network's own 8x8 windows, or the upscale's?

`image_io.smooth_pattern` was written for this question and its comment says why:
the network has 8x8 attention windows and five 2x resamplings, so content with a
fixed period can meet processing with a fixed period and produce something that
is not denoising.

A fire's glow is the case that shows it — a broad translucent wash with no
texture to hide behind. An 8-pixel window in the head is **20 pixels in the
frame** at render_scale 0.4, which is the size a seam has to be to be called
patchwork. (The upscale's own grid is 2.5 px; work/_grid_artifact.py measured it
at 4% of one 8-bit level, far too small to see.)

This runs the resident path the game runs and asks the two halves separately:

  head   768x448  — does the network's own picture carry an 8 px period?
  frame  1920x1080 — does the composed frame carry a 20 px one?

If only the frame has it, the upscale made it. If the head has it first, the
network did, and the upscale only carried it over.

No image files: `run_head` and `compose` are called in process, so ImageMagick
(which the still-frame tools want and this machine does not have) is not needed.
"""

import os
import pathlib
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "src"))
os.environ.setdefault("NR_ROOT", str(ROOT))

import nr_frame  # noqa: E402

W, H = 1920, 1080


def firelight():
    """A dark frame under a broad translucent glow: no texture, slow gradient.

    Free of noise on purpose. Noise is what would hide a periodic structure in
    the output, and a game's own dither is what keeps banding off the game's own
    frame, so leaving both out is what lets the measurement answer the question.
    """
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    base = 0.06 + 0.02 * np.sin(2 * np.pi * (x / W * 1.3 + 0.2))
    glow = 0.55 * np.exp(-(((x - 0.46 * W) / (0.30 * W)) ** 2
                           + ((y - 0.55 * H) / (0.34 * H)) ** 2))
    warm = np.array([1.00, 0.52, 0.26], np.float32)
    return np.clip(base[..., None] + glow[..., None] * warm, 0.0, 1.0).astype(np.float32)


def spectrum(img):
    """Power at each spatial period, so a structure the network imposed shows as
    a bump at its own period rather than as a broad gradient."""
    grey = img[..., :3].mean(axis=2).astype(np.float64)
    grey = grey - grey.mean()
    p = np.abs(np.fft.fft2(grey)) ** 2
    fy = np.fft.fftfreq(grey.shape[0])[:, None]
    fx = np.fft.fftfreq(grey.shape[1])[None, :]
    freq = np.sqrt(fx ** 2 + fy ** 2)
    freq[0, 0] = 1e-9
    period = 1.0 / freq
    bins = np.arange(2.0, 200.0, 1.0)
    idx = np.digitize(period.ravel(), bins)
    total = np.bincount(idx, weights=p.ravel(), minlength=len(bins) + 1)
    count = np.bincount(idx, minlength=len(bins) + 1)
    mean = np.where(count > 0, total / np.maximum(count, 1), 0.0)
    return bins, mean[:len(bins)]


def band(bins, mean, lo, hi):
    sel = (bins >= lo) & (bins <= hi)
    return float(mean[sel].sum())


def peaks(name, img, limit=5):
    """The periods that stand above their own neighbourhood."""
    bins, mean = spectrum(img)
    print(f"--- {name} ({img.shape[1]}x{img.shape[0]}) ---")
    order = np.argsort(mean)[::-1]
    shown = []
    for i in order:
        if any(abs(bins[i] - s) < 8 for s in shown):
            continue
        lo, hi = max(0, i - 9), min(len(bins), i + 10)
        around = np.concatenate([mean[lo:i], mean[i + 1:hi]])
        if around.size and around.mean() > 0 and mean[i] > 1.25 * around.mean():
            print(f"    period {bins[i]:5.1f} px  "
                  f"{mean[i] / around.mean():5.2f}x the neighbourhood")
            shown.append(bins[i])
        if len(shown) >= limit:
            break
    if not shown:
        print("    nothing stands above its neighbourhood")
    return bins, mean


def main():
    src = firelight()
    print("building the resident backend (the game's own path)...")
    started = time.perf_counter()
    model = nr_frame.ResidentBackend(str(nr_frame.WEIGHTS))
    print(f"ready in {time.perf_counter() - started:.1f}s")

    # The game's route, and not the still frame's: the daemon scales the 1920x1080
    # frame down to the network's extent before the network sees it, and the head
    # that comes back is interpolated back up inside `nr_image.compose`. Running
    # the network at the frame's own extent — which is what a still frame does —
    # skips both and cannot show either.
    low_h, low_w = 448, 768
    small = nr_frame.nr_image.bilinear(src, (low_h, low_w))
    print(f"the network's input {small.shape[1]}x{small.shape[0]}")

    started = time.perf_counter()
    head, elapsed = nr_frame.run_head(model, small, profile="standard")
    print(f"network {elapsed:.1f}s   head {head.shape[1]}x{head.shape[0]} "
          f"min {head.min():+.4f} max {head.max():+.4f} sd {head.std():.4f}")
    # `nr_image.compose_encode` is what the daemon calls, and its first clause is
    # the whole point: "bilinear of the head to the colour's extent, then
    # compose". It hands back both the float composition and the bytes it would
    # have written, so the interpolation and the 8-bit quantisation can be asked
    # about separately — the first in `output`, the second in `encoded`.
    encoded = np.zeros((H, W, 4), np.uint8)
    output = nr_frame.nr_image.compose_encode(
        head, src, None, None, None, encoded, top=0, left=0, bgra=True,
        intensity=1.0)
    print(f"composed in {time.perf_counter() - started - elapsed:.1f}s")
    bytes_out = encoded[..., :3].astype(np.float32) / 255.0
    print(f"encoded: {len(np.unique(encoded[..., 0]))} distinct levels in red")

    bins_i, mean_i = peaks("the input, as the game draws it", src)
    bins_h, mean_h = peaks("the head, the network's own picture", head[..., :3])
    bins_o, mean_o = peaks("the frame, composed at full extent", output)
    bins_b, mean_b = peaks("the frame, in the 8-bit bytes it is written as",
                           bytes_out)

    print("\n--- the question ---")
    print("  an 8 px window in the head is 20 px in the frame at render_scale 0.4")
    head_px = head.shape[1]
    scale = W / head_px
    print(f"  the head is {head_px} wide, so 8 in it is {8 * scale:.1f} in the frame\n")
    for lo, hi, label in ((8 * scale - 3, 8 * scale + 3,
                           f"around {8 * scale:.0f} px  (the head's 8x8 windows)"),
                          (scale - 1, scale + 1,
                           f"around {scale:.1f} px  (the upscale's own grid)")):
        pi, ph = band(bins_i, mean_i, lo, hi), band(bins_h, mean_h, lo / scale, hi / scale)
        po, pb = band(bins_o, mean_o, lo, hi), band(bins_b, mean_b, lo, hi)
        print(f"  {label}")
        print(f"      input {pi:.3e}   head {ph:.3e} (at its own scale)")
        print(f"      frame {po:.3e}   bytes {pb:.3e}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
