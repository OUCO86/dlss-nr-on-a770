#!/usr/bin/env python3
"""Is a frame the layer wrote into the daemon's own buffer the frame the daemon would
have read out of the mapping?

Phase 2's first half: instead of copying the frame into a file mapping for the daemon
to copy out of again, the layer writes it into a buffer the daemon allocated, and the
daemon reads it there. What has to be true of the new spelling is that the graph is
handed the same bytes: `prepare(payload)` copies the payload into the pass's buffer,
`prepare(payload, in_raw=True)` is told the bytes are already in it.

Both are run here over one frame, and what the pass made of each — the decoded and
resampled inner, which is the graph's whole input — is compared byte for byte.

    python src/bench/check_extmem_forward.py [--size 1920x1080] [--scale 0.4]

Crossing a process is not this script's to prove, and it is already proved:
`check_extmem_export.py` has the buffer (0 of 1048576 bytes wrong, each way) and
`check_extmem_export_sem.py` has the semaphore (1501.5 ms for a signal 1500 ms away,
which is the direction Phase 2 needs — the daemon waits, the layer signals). What is
new code here is the daemon's half of the reading, and that is what this measures.

Exits 77, skipped, unless the resident backend and its host library are both there.
"""
import argparse
import os
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
    sys.path.insert(0, str(ROOT / sub))

# The switch is read once, when the buffer is allocated: a buffer is exportable or it
# is not, from the moment it exists. So it is set before the backend is built, which is
# when the daemon's own start-up would have set it.
os.environ["NR_EXTMEM"] = "1"

import game_settings                                         # noqa: E402
import live_rates                                            # noqa: E402
import nr_frame                                              # noqa: E402
import xmxres                                                # noqa: E402


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--size", default="1920x1080")
    parser.add_argument("--scale", type=float, default=0.4)
    parser.add_argument("--min-extent", type=int, default=320)
    args = parser.parse_args()

    width, height = (int(v) for v in args.size.split("x"))
    pixels = width * height
    print(f"{width}x{height} at scale {args.scale}, one frame, both spellings")

    # What the daemon's own start-up would have done: the integer graph is the one the
    # game runs, and a benchmark that forgets it measures the float one instead.
    game_settings.apply()
    try:
        backend = nr_frame.ResidentBackend()
    except Exception as error:                                # pragma: no cover
        print(f"skipped: no resident backend ({error})")
        return 77

    # The network's extent, which the scale decides and the buffer does not: the frame
    # the layer writes is the game's own, at the window's resolution, whatever the
    # network is handed.
    extent = nr_frame.render_extent(width, height, args.scale, args.min_extent)
    geometry = nr_frame.network_geometry(extent[0], extent[1],
                                         minimum=args.min_extent)
    inner = (extent[1], extent[0])
    profile = "standard"
    noise = nr_frame.deterministic_noise(geometry.network_height,
                                         geometry.network_width, 0)
    controls = nr_frame.control_vector(profile)

    # Made before the pass, and kept by the backend rather than by the pass: that is
    # what leaves one buffer and one handle for the life of the daemon however often
    # the extent moves.
    raw = backend.extmem_input(pixels)
    if raw is None or not getattr(raw, "exportable", False):
        print("FAILED: the frame's buffer is not one the layer could be given")
        return 1
    print(f"  buffer: {raw.nbytes >> 20} MB, exportable, "
          f"host-visible {bool(raw.mapped)}")

    # Two passes rather than one run twice: a pass carries the frame before's inner to
    # difference against, and a second run through the same one would be a different
    # measurement — not of the spelling, but of there being a frame before.
    request_a = backend.request_pass(geometry, source=(width, height), inner=inner,
                                     noise=noise, controls=controls, bgra=True)
    request_b = backend.request_pass(geometry, source=(width, height), inner=inner,
                                     noise=noise, controls=controls, bgra=True)
    payload = live_rates.frame(width, height, 1)

    # 1. The way it is now: the bytes come off the wire and the host writes them in.
    target = request_a.inner[request_a.which]
    request_a.prepare(payload)
    want = np.array(xmxres.host_view(target, dtype=np.float32), copy=True)

    # 2. The way Phase 2 does it: the layer wrote them into the buffer, and the host
    # write is the whole of what that saves.
    view = backend.extmem_view(pixels * 4)
    if view is None:
        print("FAILED: the backend has no view onto the buffer it handed out")
        return 1
    written = np.frombuffer(payload, np.uint8)
    view[...] = written
    # What the daemon would read, and what the graph was given: the buffer's own bytes
    # have to be the frame's, or nothing below means anything.
    in_buffer = np.frombuffer(view, np.uint8)
    wrong = int((in_buffer != written).sum())
    print(f"  the buffer holds the frame: {wrong} of {written.size} bytes wrong")
    if wrong:
        print("FAILED: the frame's own bytes did not land in the buffer")
        return 1

    target = request_b.inner[request_b.which]
    request_b.prepare(view, in_raw=True)
    got = np.array(xmxres.host_view(target, dtype=np.float32), copy=True)

    if want.shape != got.shape:
        print(f"FAILED: the inner came out a different shape: {want.shape} vs {got.shape}")
        return 1
    same = want == got
    wrong = int((~same).sum())
    print(f"  inner: {want.size} floats, {wrong} wrong")
    if wrong:
        at = np.argwhere(~same)[:8]
        for index in at:
            index = tuple(index)
            print(f"    {index}: {want[index]!r} vs {got[index]!r}")
        return 1
    print("\nthe graph was handed the same bytes either way")
    return 0


if __name__ == "__main__":
    sys.exit(main())
