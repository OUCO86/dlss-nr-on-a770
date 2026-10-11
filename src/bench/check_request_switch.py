"""Does the device's request survive the extent moving under it?

A letterboxed frame is a different extent, and `ResidentBackend` keeps one: it closes
the frame it drops. A pass that captured that frame then writes its features into
device memory that has been given back, and the graph's own input no longer is where
the pass thinks it is — so `ResidentFrame.run` copies, and copies out of released
memory. That cost eight seconds a frame, with the card idle.

This runs frames at one extent, asks for another the way a letterboxed frame does,
then comes back and runs more — and says both whether the answer is still the host's
and whether anything was copied at all.

    python src/bench/check_request_switch.py [frames]

The new shader is read from `work/_pre_resident.spv` when it exists, so trying a
change never has to move the shipped one.
"""

import os
import pathlib
import statistics
import sys
import time

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
for part in ("src", "src/gpu", "src/ref"):
    sys.path.insert(0, str(ROOT / part))

_probe = ROOT / "work" / "_pre_resident.spv"
if _probe.exists():
    os.environ.setdefault("XMX_UNARY_SPV", str(_probe))

import nr_frame                                     # noqa: E402
import nr_image                                     # noqa: E402

SOURCE_WIDTH, SOURCE_HEIGHT = 1920, 1080
# A letterboxed frame: 848 columns of bars, and the 1072 inside them at the same scale.
BOXED_WIDTH = 1072
SCALE, MIN_EXTENT = 0.4, 512
PROFILE = "standard"
# What a copy out of released device memory costs, and what an honest one costs.
CARRIED_LIMIT_MS = 20.0


def extent_and_geometry(width, height):
    wide, tall = nr_frame.render_extent(width, height, SCALE, MIN_EXTENT)
    geometry = nr_frame.network_geometry(int(wide), int(tall), minimum=MIN_EXTENT)
    return (int(wide), int(tall)), geometry


def host_request(payload, geometry, inner_shape, history):
    whole = nr_image.decode8(payload, SOURCE_WIDTH, SOURCE_HEIGHT, True)
    inner = nr_image.bilinear(whole, (inner_shape[0], inner_shape[1]))
    return nr_frame.build_features(inner, geometry=geometry, history=history,
                                   **nr_frame.PROFILES[PROFILE])


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    rng = np.random.default_rng(20261011)

    (wide_a, tall_a), geometry_a = extent_and_geometry(SOURCE_WIDTH, SOURCE_HEIGHT)
    (wide_b, tall_b), geometry_b = extent_and_geometry(BOXED_WIDTH, SOURCE_HEIGHT)
    inner_a = (tall_a, wide_a, 3)
    inner_b = (tall_b, wide_b, 3)
    if geometry_a.network_width == geometry_b.network_width:
        raise SystemExit("the two extents must give different networks for this to mean "
                         "anything")

    backend = nr_frame.ResidentBackend()
    print(f"A: inner {wide_a}x{tall_a} -> network "
          f"{geometry_a.network_width}x{geometry_a.network_height}")
    print(f"B: inner {wide_b}x{tall_b} -> network "
          f"{geometry_b.network_width}x{geometry_b.network_height} (the letterboxed one)")

    def build(geometry, inner):
        return backend.request_pass(
            geometry, source=(SOURCE_WIDTH, SOURCE_HEIGHT), inner=inner,
            noise=nr_frame.deterministic_noise(geometry.network_height,
                                               geometry.network_width, 0),
            controls=nr_frame.control_vector(PROFILE), bgra=True)

    request = build(geometry_a, (wide_a, tall_a))
    carried, mismatched = [], 0

    def one(geometry, inner_shape, request, frame):
        """A frame both ways. Returns whether the head agreed, and what was copied."""
        payload = rng.integers(0, 256, size=SOURCE_HEIGHT * SOURCE_WIDTH * 4,
                               dtype=np.uint8).tobytes()
        history = (None if frame == 0
                   else rng.random(inner_shape).astype(np.float32) * 0.5)
        head_host = np.array(backend.run_features(
            host_request(payload, geometry, inner_shape, history)), copy=True)
        carried.append(backend.split[0] * 1e3)

        request.prepare(payload)
        head_device = np.array(backend.run_features(request.assemble(history)), copy=True)
        carried.append(backend.split[0] * 1e3)
        if head_host.tobytes() != head_device.tobytes():
            delta = np.abs(head_host - head_device)
            print(f"  frame {frame}: {int((delta > 0).sum())} of {delta.size} head "
                  f"values differ, largest {delta.max():.3e}")
            return 1
        return 0

    for frame in range(frames):
        mismatched += one(geometry_a, inner_a, request, frame)
    before = list(carried)

    # The letterboxed frame: the host's path, and the backend asked for the other
    # extent — which is what closes the frame the pass above was built on.
    payload = rng.integers(0, 256, size=SOURCE_HEIGHT * SOURCE_WIDTH * 4,
                           dtype=np.uint8).tobytes()
    backend.run_features(host_request(payload, geometry_b, inner_b, None))
    print(f"\nasked for the letterboxed extent; the host's own copy was "
          f"{backend.split[0] * 1e3:.2f} ms")

    # Back to the first extent **without** rebuilding the pass, which is the harshest
    # form of this: the daemon only rebuilds when its key moves, and a caller that
    # kept the old object has to work too. The pass must ask the backend for the frame
    # rather than have kept it, because the one it was built on is closed now.
    after = []
    carried = after
    for frame in range(frames):
        mismatched += one(geometry_a, inner_a, request, frame)

    # The device's path copies nothing, so its carried time is the host's write and
    # not a read back. Both columns are host then device, for every frame.
    host_before = before[0::2]
    device_before = before[1::2]
    device_after = after[1::2]
    median = statistics.median
    print()
    print(f"byte-identical heads: {2 * frames - mismatched}/{2 * frames}")
    print(f"device carried, before the switch: {median(device_before):7.2f} ms")
    print(f"device carried, after  the switch: {median(device_after):7.2f} ms")
    print(f"(the host's own, for scale:        {median(host_before):7.2f} ms)")
    failed = mismatched or median(device_after) > CARRIED_LIMIT_MS
    if median(device_after) > CARRIED_LIMIT_MS:
        print(f"\nFAILED: {median(device_after):.2f} ms copies where the device's "
              f"request should copy nothing — the pass is writing into a frame the "
              f"backend has closed")
    print("ok" if not failed else "not ok")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
