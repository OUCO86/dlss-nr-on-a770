#!/usr/bin/env python3
"""Read a captured pair of frames: measure them, and write pictures to look at.

    python src/bench/read_capture.py work/capture_in.nrn work/capture_out.nrn

The layer writes sixteen bytes of header (magic, width, height, VkFormat) and
then the pixels, in the swapchain's own format - B8G8R8A8 at 1080p here, so red
is channel 2 and blue is channel 0. Getting that backwards reports a difference
of nineteen colour steps between the red channel and the blue one.

Two things come out of it:

  numbers      levels and run length, so banding can be told from no banding,
               and a spectrum so a repeating grid can be told from the picture.
  pictures     capture_in.png / capture_out.png for the whole frame, and _zoom
               for the middle blown up nearest-neighbour - which keeps the steps
               in instead of smoothing them away, which is the whole point.

The pictures are what matter. A seam is something you can see, and a number that
moves by four per cent of one colour step is not an answer either way.
"""
import pathlib
import struct
import sys
import zlib

import numpy as np

MAGIC = 0x304E524E
MAGIC_MASKED = 0x314E524E


def read(path):
    raw = pathlib.Path(path).read_bytes()
    head = np.frombuffer(raw[:16], dtype="<u4")
    magic, width, height, fmt = (int(v) for v in head)
    body = np.frombuffer(raw[16:], dtype=np.uint8)
    want = width * height * 4
    if body.size < want:
        raise SystemExit(f"{path}: got {body.size} bytes, expected {want}")
    return {"magic": magic, "width": width, "height": height, "format": fmt,
            "bgra": body[:want].reshape(height, width, 4),
            "masked": magic == MAGIC_MASKED}


def banding(plane):
    """How many 8-bit steps the plane uses, and how long a run of one value gets.

    A flat band is a long run of one byte value. Short runs mean the steps are
    small and close together, which is what a smooth ramp looks like; long runs
    are rings you can see.
    """
    values = np.unique(plane)
    longest = []
    for row in plane:
        edges = np.flatnonzero(np.diff(row)) + 1
        bounds = np.concatenate(([0], edges, [row.size]))
        longest.append(np.diff(bounds).max())
    return int(values.size), float(np.mean(longest)), float(np.percentile(longest, 99))


def spectrum_peaks(plane, axis=0, top=3):
    """The spacings, in pixels, of the repeating lines that stand out most.

    The mean along the other axis is a one-dimensional signal, and a grid's lines
    are in its spectrum - but so is the picture, and it is a thousand times louder
    than the one colour step a seam is worth. So the shape is taken off first with
    a 61 px moving average, and what is left is judged on prominence: how far a
    bin stands above its neighbours, not how loud it is.

    A grid one pixel wide has as much energy in its harmonics as in its
    fundamental, so the period reported is often a fraction of the real spacing.
    Read it as "something repeats every N px, or a multiple of it".
    """
    length = plane.shape[axis]
    signal = plane.mean(axis=1 - axis).astype(np.float64)
    if not np.any(signal):
        return []
    kernel = np.ones(61) / 61.0
    signal = signal - np.convolve(signal, kernel, mode="same")
    spectrum = np.abs(np.fft.rfft(signal))
    if spectrum.size < 8:
        return []
    hi = max(8, length // 3)
    found = []
    for k in range(2, hi):
        around = np.concatenate((spectrum[max(2, k - 6):k - 1],
                                 spectrum[k + 2:k + 7]))
        base = float(np.median(around)) if around.size else 0.0
        if base <= 0.0:
            continue
        found.append((float(spectrum[k] / base), float(length / k)))
    found.sort(reverse=True)
    return found[:top]


def write_png(path, rgb):
    """A true-colour PNG, written here because no image tool is installed."""
    height, width = rgb.shape[:2]
    raw = b"".join(b"\x00" + np.ascontiguousarray(rgb[y]).tobytes()
                   for y in range(height))

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    body = (chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 6))
           + chunk(b"IEND", b""))
    pathlib.Path(path).write_bytes(b"\x89PNG\r\n\x1a\n" + body)


def shrink(plane, step):
    """Nearest-neighbour shrink: averaging would smooth the steps away."""
    return plane[::step, ::step]


def zoom(plane, factor):
    """Nearest-neighbour blow-up: keeps the steps, which is the thing to see."""
    return np.repeat(np.repeat(plane, factor, axis=0), factor, axis=1)


def describe(name, frame):
    bgra = frame["bgra"]
    b, g, r = bgra[..., 0], bgra[..., 1], bgra[..., 2]
    print(f"--- {name}: {frame['width']}x{frame['height']} "
          f"format {frame['format']} ({'masked' if frame['masked'] else 'plain'})")
    for label, plane in (("red", r), ("green", g), ("blue", b)):
        levels, mean_run, p99_run = banding(plane)
        print(f"    {label:<6} levels {levels:>4}   "
              f"mean longest run {mean_run:>7.2f} px   p99 {p99_run:>7.2f} px")
    for label, axis in (("rows", 0), ("columns", 1)):
        peaks = spectrum_peaks(r, axis)
        if not peaks:
            print(f"    {label:<6} no repeating line found")
            continue
        for prominence, period in peaks:
            print(f"    {label:<6} period {period:>7.2f} px   "
                  f"stands {prominence:>5.1f}x above its neighbours")
    return r.astype(np.float32)


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    out_dir = pathlib.Path(sys.argv[1]).resolve().parent
    reds = []
    for arg in sys.argv[1:]:
        frame = read(arg)
        stem = pathlib.Path(arg).stem
        reds.append(describe(pathlib.Path(arg).name, frame))
        bgra = frame["bgra"]
        # The whole frame, halved, so it fits on a screen.
        small = np.stack([shrink(bgra[..., 2], 2), shrink(bgra[..., 1], 2),
                      shrink(bgra[..., 0], 2)], axis=-1)
        write_png(out_dir / f"{stem}.png", small)
        # The middle, blown up nearest-neighbour so the steps survive.
        cy, cx = frame["height"] // 2, frame["width"] // 2
        patch = bgra[cy - 128:cy + 128, cx - 128:cx + 128]
        big = np.stack([zoom(patch[..., 2], 4), zoom(patch[..., 1], 4),
                        zoom(patch[..., 0], 4)], axis=-1)
        write_png(out_dir / f"{stem}_zoom.png", big)
        print(f"    wrote {stem}.png and {stem}_zoom.png")

    if len(reds) == 2:
        diff = np.abs(reds[1] - reds[0])
        print("\n--- in vs out (red channel)")
        print(f"    mean |difference| {diff.mean():>7.4f} of 255   "
              f"max {diff.max():>6.1f}")
        print(f"    pixels moving a whole 8-bit step or more: "
              f"{(diff >= 1.0).mean() * 100:>6.2f}%")


if __name__ == "__main__":
    main()
