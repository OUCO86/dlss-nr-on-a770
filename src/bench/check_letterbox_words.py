"""The bars found in the bytes are the bars found in the decoded frame.

`nr_daemon.active_region` reads a float32 frame; `active_region_words` reads the bytes
the game sent. They are two ways of asking one question and the host now answers it in
bytes so that the widening into floats can be skipped, which makes them worth pinning
against each other: every case below has to give the same four numbers both ways.

The interesting cases are the ones near the tolerance. `LETTERBOX_TOLERANCE` is 2/255,
so a byte of 2 is black and a byte of 3 is not, and a bar whose alpha is 255 — which is
what a game actually sends — must still be found, since alpha is not a colour.

    python src/bench/check_letterbox_words.py [cases]
"""

import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
for place in ("src", "src/layer", "src/ref"):
    sys.path.insert(0, str(ROOT / place))

import nr_daemon


def words_of(pixels):
    """A frame as the game sends it: four bytes a pixel, alpha opaque."""
    block = np.zeros(pixels.shape[:2] + (4,), np.uint8)
    block[..., :3] = pixels
    block[..., 3] = 255
    return bytearray(block.tobytes())


def case(name, width, height, pixels):
    words = words_of(pixels)
    from_words = nr_daemon.active_region_words(words, width, height)
    frame = nr_daemon.decode(words, width, height, 50)
    from_frame = nr_daemon.active_region(frame)
    return name, from_words, from_frame


def build(rng, width, height, bars=0, level=0, field=200, edges=0):
    """A picture with `bars` black rows above and below, `edges` black columns either side."""
    pixels = rng.integers(0, field + 1, (height, width, 3)).astype(np.uint8)
    if bars:
        pixels[:bars] = level
        pixels[height - bars:] = level
    if edges:
        pixels[:, :edges] = level
        pixels[:, width - edges:] = level
    return pixels


def main(count=6):
    rng = np.random.default_rng(20261011)
    cases = []
    for size in ((768, 448), (1024, 768), (1920, 1080)):
        width, height = size
        cases.append(case(f"{width}x{height} no bars", width, height,
                          build(rng, width, height)))
        # 16:9 inside 4:3 is the letterbox this was written for: a quarter of the rows
        bars = height // 8
        cases.append(case(f"{width}x{height} {2 * bars}px of bars", width, height,
                          build(rng, width, height, bars=bars)))
        cases.append(case(f"{width}x{height} bars and pillars", width, height,
                          build(rng, width, height, bars=bars, edges=width // 8)))
        # a bar one value below the tolerance, and one above: 2 is black, 3 is not
        cases.append(case(f"{width}x{height} bars at the tolerance", width, height,
                          build(rng, width, height, bars=bars, level=2)))
        cases.append(case(f"{width}x{height} bars one above it", width, height,
                          build(rng, width, height, bars=bars, level=3)))
        # a dark scene, and a black one: neither is a letterbox
        cases.append(case(f"{width}x{height} a dark scene", width, height,
                          build(rng, width, height, field=2)))
        cases.append(case(f"{width}x{height} a black frame", width, height,
                          np.zeros((height, width, 3), np.uint8)))
        # one side only, which is a dark sky and not a letterbox
        one = build(rng, width, height)
        one[:bars] = 0
        cases.append(case(f"{width}x{height} one bar only", width, height, one))

    bad = 0
    for name, from_words, from_frame in cases:
        same = from_words == from_frame
        bad += 0 if same else 1
        mark = "ok  " if same else "FAIL"
        print(f"  {mark} {name:<34} bytes {tuple(int(v) for v in from_words)}"
              f"   frame {tuple(int(v) for v in from_frame)}")

    # The cached path matters more than the scan: it is what runs every frame. Eight lines
    # decide whether the bounds still hold, and the two readings have to agree on them.
    width, height = 1024, 768
    bars = height // 8
    first = build(rng, width, height, bars=bars)
    words = words_of(first)
    key = (width, height, 50)
    words_box = nr_daemon.Letterbox()
    frame_box = nr_daemon.Letterbox()
    held = []
    for index in range(int(count)):
        if index:
            # the bar stops being black, then starts again: each should force a rescan
            pixels = build(rng, width, height, bars=bars,
                           level=(3 if index == 1 else 0))
            words = words_of(pixels)
        frame = nr_daemon.decode(words, width, height, 50)
        by_words = words_box.region(None, key, words=words, shape=(width, height))
        by_frame = frame_box.region(frame, key)
        same = by_words == by_frame
        bad += 0 if same else 1
        held.append(f"{'ok  ' if same else 'FAIL'} frame {index}: "
                    f"bytes {tuple(int(v) for v in by_words)}"
                    f"   frame {tuple(int(v) for v in by_frame)}")
    print()
    for line in held:
        print("  " + line)

    print()
    print(f"  {len(cases) + len(held)} cases, {bad} disagreeing")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(int(sys.argv[1]) if len(sys.argv) > 1 else 6))
