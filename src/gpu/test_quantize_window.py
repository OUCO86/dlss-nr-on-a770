#!/usr/bin/env python3
"""The gathered quantiser against the two passes it replaces, value for value.

A window block's QKV projection on the integer path has to gather its tokens out of the
image before it can put them on the integer path's grid, and `gemm_staged_int8` has no
epilogue to fold that gather into. So the graph recorded `partition` — a pass that read
the image and wrote it back in window order — purely so `quantize_row` could read the
copy straight through. Two passes where the float path pays one, and the gather is the
only reason either of them exists.

`Runtime.quantize_window` folds the gather into the quantiser: the same index `partition`
made, applied to the image where it lies, so the copy never exists and the pass that
wrote it never runs. This checks that what comes out is the same thing — packed bytes
and per-row scales, bit for bit — on the shapes the frame actually uses, including the
edges that only a shifted origin produces: a window that hangs off the top or left of
the image, and one that hangs off the bottom or right because the padded extent is
larger than the image's own.

The comparison is against the two passes and not against the host reference, because
`src/gpu/test_quantize_row.py` already settles the quantiser against
`int8_quant.quantise`. What is in question here is only the gather.
"""
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres as X

FAILURES = []


def check(name, ok, detail=""):
    print(f"  [{'ok  ' if ok else 'FAIL'}] {name}{'  ' + detail if detail else ''}", flush=True)
    if not ok:
        FAILURES.append(name)


def window_extent(height, width, origin, size=8):
    pad_top, pad_left = -origin[0], -origin[1]
    padded_height = pad_top + height + (-(height + pad_top)) % size
    padded_width = pad_left + width + (-(width + pad_left)) % size
    return padded_height, padded_width


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(11)
    cases = 0

    def one(height, width, channels, origin, label):
        nonlocal cases
        padded_height, padded_width = window_extent(height, width, origin)
        across = padded_width // 8
        windows = (padded_height // 8) * (padded_width // 8)
        rows = windows * 64
        pad = ((-origin[0]) << 16) | (-origin[1])

        image = (rng.standard_normal((height * width, channels)).astype(np.float32)
                 * (10.0 ** rng.uniform(-2, 2, (height * width, 1)))).astype(np.float16)

        source = rt.buffer(height * width * channels, np.float16)
        win16 = rt.buffer(rows * channels, np.float16)
        packed = rt.buffer(rows * channels, np.int8)
        scale = rt.buffer(rows, np.float32)
        fused = rt.buffer(rows * channels, np.int8)
        fused_scale = rt.buffer(rows, np.float32)
        X.host_write(source, image)
        X.host_write(win16, np.full(rows * channels, np.nan, np.float16))
        X.host_write(packed, np.full(rows * channels, 0, np.int8))
        X.host_write(scale, np.full(rows, np.nan, np.float32))
        X.host_write(fused, np.full(rows * channels, 0, np.int8))
        X.host_write(fused_scale, np.full(rows, np.nan, np.float32))

        # The way it ran: gather into a copy, then grid the copy.
        rt.begin()
        rt.partition(source, win16, height, width, channels, origin=origin,
                     narrow=True, a_half=True)
        rt.quantize_row(win16, packed, scale, rows, channels)
        rt.submit()
        want_packed = X.host_view(packed, np.int8, (rows, channels)).copy()
        want_scale = X.host_view(scale, np.float32, (rows,)).copy()

        # The way it runs now: grid the image through the gather, in one pass.
        rt.begin()
        rt.quantize_window(source, fused, fused_scale, rows, channels,
                           height=height, width=width, across=across, pad=pad)
        rt.submit()
        got_packed = X.host_view(fused, np.int8, (rows, channels)).copy()
        got_scale = X.host_view(fused_scale, np.float32, (rows,)).copy()

        same_packed = bool((got_packed == want_packed).all())
        same_scale = bool(np.array_equal(got_scale.view(np.int32),
                                         want_scale.view(np.int32)))
        finite = bool(np.isfinite(got_scale).all())
        nonzero = int(np.count_nonzero(got_scale))
        check(f"{label} {height}x{width}x{channels} origin={origin}",
              same_packed and same_scale and finite,
              f"packed {'identical' if same_packed else 'DIFFERENT'},"
              f" scales {'identical' if same_scale else 'DIFFERENT'},"
              f" {nonzero}/{rows} non-empty, all finite: {finite}")
        for buf in (source, win16, packed, scale, fused, fused_scale):
            buf.free()
        cases += 1

    # The shapes the frame's window blocks use: 64 channels at 192x112 and up.
    one(112, 192, 64, (0, 0), "C=64")
    one(112, 192, 64, (-4, -4), "C=64 shifted")
    one(56, 96, 128, (0, 0), "C=128")
    one(56, 96, 128, (-4, -4), "C=128 shifted")
    one(28, 48, 256, (-4, -4), "C=256 shifted")
    # An extent that is not a whole number of windows, so the padded one reaches past
    # the image on the right and the bottom as well as the left and the top.
    one(30, 50, 64, (-4, -4), "ragged")

    print(f"\nwindow gather: {cases} cases against partition + quantize_row")
    if FAILURES:
        print(f"  {len(FAILURES)} failed: {FAILURES}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
