#!/usr/bin/env python3
"""Does withholding the composition change the bytes the game receives, or the change figure?

`compose_encode` grew a mode that answers `change` — the figure the daemon logs — from inside
the pass and writes no composition at all, because nobody downstream reads it: `--dump` and
`--meter` are the only takers and neither runs during a game. That is a large saving offered
in exchange for a claim, so this checks the claim rather than trusting it.

Two things have to hold, and they are checked against one real captured frame, in one process,
alternating so nothing here depends on the machine drifting between runs:

  1. `encoded` is byte for byte what it was. This is what the game is handed; it is the only
     output that cannot move, and the reason nothing else about the pass is negotiated.
  2. `change` is the same number the daemon's own `mean_change` computes over every fourth
     row, to the five places the log prints it in.

Usage:  python3 src/bench/check_compose_change.py [capture.nrn]
"""

import os
import pathlib
import struct
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
if not (ROOT / "src" / "ref" / "nr_image.py").exists():
    ROOT = HERE.parents[1]
if not os.environ.get("NR_ROOT"):
    os.environ["NR_ROOT"] = str(ROOT)
for sub in ("src/ref", "src/layer"):
    sys.path.insert(0, str(ROOT / sub))

import numpy as np

import nr_frame
import nr_image


def frame_npy(path):
    """One NRN0 capture as float32 (H, W, 3) in 0-1, the way `decode` leaves it."""
    raw = open(path, "rb").read()
    magic, width, height, vk_format = struct.unpack("<4I", raw[:16])
    if magic != 0x304E524E:
        raise SystemExit(f"{path}: not an NRN0 capture")
    body = np.frombuffer(raw, np.uint8, offset=16).reshape(height, width, 4)
    bgr = (body[..., [2, 1, 0]] if vk_format in (44, 50) else body[..., :3])
    return np.ascontiguousarray(bgr.astype(np.float32) / 255.0)


def mean_change(fresh, was):
    """The daemon's own figure: `nr_daemon.mean_change` over every `CHANGE_ROWS`-th row."""
    return float(np.abs(fresh[::4] - was[::4]).mean())


def once(colour, head, history=None, previous=None, **kwargs):
    encoded = np.zeros((colour.shape[0], colour.shape[1], 4), np.uint8)
    if os.environ.get("CHECK_DEBUG"):
        print(f"    once: colour {colour.shape} head {head.shape} "
              f"history {None if history is None else history.shape}", flush=True)
    result = nr_image.compose_encode(head, colour, history, previous, None, encoded, **kwargs)
    return encoded, result


def describe(name, colour, head, temporal):
    """One shape of call, checked both ways. Returns 0 where nothing differs."""
    history = previous = None
    extra = {}
    if temporal:
        # The daemon's temporal path: a history of the colour's own shape, a table, and the
        # hold and release the knobs carry. This one takes `compose_encode_row`'s template,
        # whose metering is written separately from the slow loop's, so it needs its own turn.
        rng = np.random.default_rng(4)
        history = np.ascontiguousarray(colour + rng.uniform(-0.02, 0.02, colour.shape)
                                       .astype(np.float32))
        previous = np.ascontiguousarray(colour - 0.01)
        table = nr_frame.gate_table(float(nr_frame.BLEND_SCALE))
        extra = dict(table=table, confidence=1.0, blend_scale=float(nr_frame.BLEND_SCALE),
                     hold=0.5, slope=float(np.float32(-255.0 * 0.5 / nr_frame.HOLD_RAMP)),
                     release=0.25)
    written, withheld = [], []
    changes_old, changes_new = [], []
    for _ in range(11):
        encoded_old, composed = once(colour, head, history, previous, top=0, left=0,
                                     bgra=True, intensity=1.0, **extra)
        changes_old.append(mean_change(composed, colour))
        written.append(encoded_old.copy())
        encoded_new, metred = once(colour, head, history, previous, top=0, left=0,
                                   bgra=True, intensity=1.0, change_rows=4, **extra)
        changes_new.append(metred)
        withheld.append(encoded_new.copy())

    print(f"\n{name}")
    print(f"  change, composition kept   {changes_old[5]:.6f}")
    print(f"  change, metred in the pass {changes_new[5]:.6f}")
    drift = abs(changes_new[5] - changes_old[5])
    print(f"  difference {drift:.2e}" + ("" if drift < 5e-4 else "   << not the same figure"))
    same = [(old == new).all() for old, new in zip(written, withheld)]
    print(f"  encoded identical in {sum(same)}/{len(same)} alternating turns"
          f"   ({(written[0] == withheld[0]).all()}, {written[0].size} bytes)")
    if not all(same):
        bad = written[0] != withheld[0]
        print(f"  differs at {len(np.argwhere(bad))} bytes, "
              f"first: {np.argwhere(bad)[:3].tolist()}")
        return 1
    return 0 if drift < 5e-4 else 1


def main():
    capture = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / "work" / "capture.nrn")
    colour = np.ascontiguousarray(frame_npy(capture))
    height, width = colour.shape[:2]
    # The network's extent, which is what the daemon hands the composition: three channels
    # for a still frame, four once a history travels with it.
    rows, cols = round(height * 0.4), round(width * 0.4)
    small = np.ascontiguousarray(colour[:rows, :cols])
    still_head = small
    temporal_head = np.ascontiguousarray(
        np.concatenate([small, np.zeros((rows, cols, 1), np.float32)], axis=2))
    print(f"{width}x{height} from {pathlib.Path(capture).name}, head {cols}x{rows} "
          f"(3 channels still, 4 with a history)")

    failures = describe("still, no history            [slow path]", colour, still_head, False)
    failures += describe("temporal, with a history     [fast path]", colour, temporal_head,
                         True)
    return failures


if __name__ == "__main__":
    sys.exit(main())
