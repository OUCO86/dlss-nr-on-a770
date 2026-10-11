"""The head must stay where the graph left it, and a check has to be able to say so.

`check_wired_finish.py` proves the composition is *correct* — its bytes match the
host's. It cannot prove the head was not carried back across the bus on the way
there, because it builds the pass and calls `finish` directly and never asks a frame
for a head at all. That is not a gap in that check so much as a different question,
and it is the question this one asks: how much came back, and in what form.

A captured graph runs by two branches — the one that captures it and the one that
replays it on every frame after — and only the first was told the head stays. The
first frame was fine and every frame after read 25 MB out of device memory, 212 ms
each, which a game felt immediately and no byte comparison could see. So this runs
several frames through the real backend, because the second one is the one that
matters, and it asserts on the third number of `ResidentBackend.split`, which is
host write, graph, host read: the read is the only one allowed to be more than a
rounding error here, and it is the one that says a copy happened.

Usage: python src/bench/check_head_on_device.py [frames]
"""
import sys
import pathlib
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
for part in ("src", "src/gpu", "src/ref"):
    sys.path.insert(0, str(ROOT / part))

import nr_frame

SOURCE_WIDTH, SOURCE_HEIGHT = 1920, 1080
SCALE, MIN_EXTENT = 0.4, 512
PROFILE = "standard"
# Reads that are only ever a mapped pointer or nothing at all. The host's own path
# reads the head back on purpose, so its budget is the one measured before the head
# moved: under a millisecond at this extent.
READ_BUDGET_MS = 5.0


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    wide, tall = nr_frame.render_extent(SOURCE_WIDTH, SOURCE_HEIGHT, SCALE, MIN_EXTENT)
    geometry = nr_frame.network_geometry(int(wide), int(tall), minimum=MIN_EXTENT)
    inner_shape = (int(tall), int(wide), 3)
    noise = nr_frame.deterministic_noise(geometry.network_height, geometry.network_width, 0)
    controls = nr_frame.control_vector(PROFILE)

    rng = np.random.default_rng(20261011)
    payloads = [rng.integers(0, 256, size=SOURCE_HEIGHT * SOURCE_WIDTH * 4,
                             dtype=np.uint8).tobytes()
                for _ in range(frames)]

    print(f"{SOURCE_WIDTH}x{SOURCE_HEIGHT} -> "
          f"network {geometry.network_width}x{geometry.network_height}, "
          f"{frames} frames, read budget {READ_BUDGET_MS:.0f} ms")

    failed = 0
    for on in (True, False):
        backend = nr_frame.ResidentBackend(head_on_device=on)
        request = backend.request_pass(geometry, source=(SOURCE_WIDTH, SOURCE_HEIGHT),
                                       inner=(int(wide), int(tall)), noise=noise,
                                       controls=controls, bgra=True)
        reads, forms = [], []
        for index in range(frames):
            request.prepare(payloads[index])
            history = (None if index == 0
                       else rng.random(inner_shape).astype(np.float32) * 0.5)
            head = backend.run_features(request.assemble(history))
            carried, ran, read = backend.split
            reads.append(read * 1e3)
            # A tuple is (buffer, stride), which is what the composition wants; an
            # array is the head back on the host, which is what this is watching for.
            forms.append("device" if isinstance(head, tuple) else "host")
            if on != isinstance(head, tuple):
                failed += 1
        worst = max(reads)
        over = worst > READ_BUDGET_MS
        if over:
            failed += 1
        print(f"  head_on_device={str(on):<5} form {'/'.join(forms)}  "
              f"reads {'/'.join(f'{value:.2f}' for value in reads)} ms  "
              f"{'OVER BUDGET' if over else 'within budget'}")
        request.close()

    print()
    if failed:
        print(f"FAILED: {failed} assertion(s) — the head is crossing the bus")
    else:
        print("the head stays on the card, and every frame after the first agrees")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
