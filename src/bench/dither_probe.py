"""Would a dither put the seam back the way the game had it?

The measurement that settled it is not the one about neighbours. It is that the
composed frame uses **39 levels where the game's own bytes used 137** — the
gradient is still there, but it is spread over a third of the levels, so each
step is three and a half times as tall and the boundary between two steps is a
line you can see. A glow is made of a few dozen of them. That is the patchwork.

Dither is how renderers have always answered this, and it is why the game's own
frame has no seams: a sub-level noise added before the byte is written turns a
straight step into a scattered one. The band is still there — it has to be, the
byte is still one of 256 — but its boundary is no longer a line.

This asks three things of a dither on the composed frame: does it break the
long runs of one byte into short ones, does it cost anything in the levels the
frame can hold, and does it touch what the network actually did.
"""

import os
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "src"))
os.environ.setdefault("NR_ROOT", str(ROOT))

import nr_frame  # noqa: E402

W, H = 1920, 1080
LOW = (448, 768)


def glow():
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    base = 0.06 + 0.02 * np.sin(2 * np.pi * (x / W * 1.3 + 0.2))
    g = 0.55 * np.exp(-(((x - 0.46 * W) / (0.30 * W)) ** 2
                        + ((y - 0.55 * H) / (0.34 * H)) ** 2))
    return base[..., None] + g[..., None] * np.array([1.0, 0.52, 0.26], np.float32)


def runs(bytes_img):
    """How long a stretch of one byte is, on average, along a row.

    This is the number that says "banded". A banded gradient is made of long
    runs: a whole region shares a byte, and the run ends only where the band
    does. Dithered, the run ends almost at once and the eye sees speckle where
    it would have seen an edge.
    """
    red = bytes_img[..., 0].astype(np.int16)
    change = red[:, 1:] != red[:, :-1]
    lengths, current = [], np.ones(red.shape[0], np.int64)
    for col in range(change.shape[1]):
        current = np.where(change[:, col], 1, current + 1)
        lengths.append(current.copy())
    all_runs = np.concatenate(lengths)
    return float(all_runs.mean()), float(np.percentile(all_runs, 99))


def bayer(h, w):
    """A 8x8 ordered dither, in levels. Cheap, fixed, and the same for every
    frame, which a temporal one would not be."""
    y, x = np.mgrid[0:h, 0:w]
    acc, bit = np.zeros((h, w), np.int64), 1
    yy, xx = y.copy(), x.copy()
    for _ in range(3):
        acc = acc * 4 + ((xx & 1) * 2 + ((yy & 1) ^ (xx & 1)))
        yy, xx, bit = yy >> 1, xx >> 1, bit * 2
    return (acc + 0.5) / 64.0 - 0.5


def main():
    clean = glow().astype(np.float32)
    print("building the resident backend...")
    model = nr_frame.ResidentBackend(str(nr_frame.WEIGHTS))

    small = nr_frame.nr_image.bilinear(clean, LOW)
    head, _ = nr_frame.run_head(model, small, profile="standard")
    # `samples` is not enough: the bytes are the question, so ask the fused pass
    # for them and keep the float composition too, which `change_rows` withholds.
    encoded = np.zeros((H, W, 4), np.uint8)
    composed = nr_frame.nr_image.compose_encode(
        head, clean, None, None, None, encoded, top=0, left=0, bgra=True,
        intensity=1.0)
    plain = encoded[..., :3]

    # The dither belongs where the byte is written, which is inside the pass; done
    # here on the float composition it is the same arithmetic one quantise later.
    dither = bayer(H, W)[..., None]
    dithered = np.clip(np.round(np.clip(composed, 0, 1) * 255.0 + dither), 0, 255
                       ).astype(np.uint8)

    game_bytes = np.clip(np.round(clean * 255.0), 0, 255).astype(np.uint8)

    # The composition comes back RGB and the bytes are written BGRA, so a channel
    # has to be named before the two are compared. Comparing them the other way
    # round reports the distance from red to blue and calls it the dither's cost.
    print(f"\n{'frame':34s} {'mean run':>9s} {'p99 run':>8s} {'levels':>7s}")
    print("  (red channel; the bytes are BGRA, so red is `encoded[..., 2]`)")
    for label, img, red_at in (("the game's own bytes", game_bytes, 0),
                               ("the composed frame, as it is now", plain, 2),
                               ("the composed frame, dithered", dithered, 0)):
        red = img[..., red_at].astype(np.int16)[:, :, None]
        mean_run, p99 = runs(np.repeat(red, 3, axis=2))
        levels = int(np.unique(red).size)
        print(f"{label:34s} {mean_run:9.2f} {p99:8.0f} {levels:7d}")

    # What it costs, in the same channel in both: the composed frame, dithered or
    # not, is one picture, and the only difference is the sub-level noise.
    diff = np.abs(dithered[..., 0].astype(np.float32)
                  - plain[..., 2].astype(np.float32))
    print(f"\nthe dither moves a pixel by {diff.mean():.3f} of a level on average, "
          f"and by more than one level for {(diff > 1).mean() * 100:.2f}% of pixels")
    print("(a dither of half a level cannot move a byte by more than one, so "
          "anything above\n that is the composed frame's own step, not the dither)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
