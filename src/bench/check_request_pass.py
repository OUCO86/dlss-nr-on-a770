"""Does the device's request give the graph the same answer the host's does?

`RequestPass` takes the game's own bytes to the graph's input without the host holding
the decoded frame or its resampled copy. This runs a frame both ways through a real
backend and compares what the network answers, so the wiring is checked and not only
the two passes on their own.

    python src/bench/check_request_pass.py [frames]

The new shader is read from `work/_pre_resident.spv` when it exists, so trying a change
never has to move the shipped one.
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
SCALE, MIN_EXTENT = 0.4, 512
PROFILE = "standard"


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    wide, tall = nr_frame.render_extent(SOURCE_WIDTH, SOURCE_HEIGHT, SCALE, MIN_EXTENT)
    geometry = nr_frame.network_geometry(int(wide), int(tall), minimum=MIN_EXTENT)
    inner_shape = (int(tall), int(wide), 3)

    backend = nr_frame.ResidentBackend()
    noise = nr_frame.deterministic_noise(geometry.network_height, geometry.network_width, 0)
    request = backend.request_pass(geometry, source=(SOURCE_WIDTH, SOURCE_HEIGHT),
                                   inner=(int(wide), int(tall)), noise=noise,
                                   controls=nr_frame.control_vector(PROFILE), bgra=True)

    print(f"inner {int(wide)}x{int(tall)} -> network "
          f"{geometry.network_width}x{geometry.network_height}, {frames} frames")

    rng = np.random.default_rng(20261011)
    host_ms, device_ms, carried = [], [], {"host": [], "device": []}
    mismatched = 0
    for frame in range(frames):
        payload = rng.integers(0, 256, size=SOURCE_HEIGHT * SOURCE_WIDTH * 4,
                               dtype=np.uint8).tobytes()
        history = (None if frame == 0 else
                   rng.random(inner_shape).astype(np.float32) * 0.5)

        # The host's way: decode, resample, assemble, then copy into the graph's input.
        started = time.perf_counter()
        whole = nr_image.decode8(payload, SOURCE_WIDTH, SOURCE_HEIGHT, True)
        inner = nr_image.bilinear(whole, (inner_shape[0], inner_shape[1]))
        features = nr_frame.build_features(inner, geometry=geometry, history=history,
                                           **nr_frame.PROFILES[PROFILE])
        before = time.perf_counter() - started
        started = time.perf_counter()
        head_host = np.array(backend.run_features(features), copy=True)
        ran_host = (time.perf_counter() - started) * 1e3
        carried["host"].append(before * 1e3)
        host_ms.append(before * 1e3 + ran_host)

        # The device's way: two passes, and the graph reads what they wrote.
        started = time.perf_counter()
        request.prepare(payload)
        features_device = request.assemble(history)
        before = time.perf_counter() - started
        started = time.perf_counter()
        head_device = np.array(backend.run_features(features_device), copy=True)
        ran_device = (time.perf_counter() - started) * 1e3
        carried["device"].append(before * 1e3)
        device_ms.append(before * 1e3 + ran_device)

        if head_host.tobytes() != head_device.tobytes():
            mismatched += 1
            delta = np.abs(head_host - head_device)
            print(f"  frame {frame}: {int((delta > 0).sum())} of {delta.size} head values "
                  f"differ, largest {delta.max():.3e}")

    median = statistics.median
    print()
    print(f"byte-identical heads: {frames - mismatched}/{frames}")
    print(f"host   to the head: {median(host_ms):7.2f} ms "
          f"(before the graph {median(carried['host']):6.2f})")
    print(f"device to the head: {median(device_ms):7.2f} ms "
          f"(before the graph {median(carried['device']):6.2f})")
    print(f"         difference {median(host_ms) - median(device_ms):+7.2f} ms — "
          f"both include the same graph, so this is the request's own cost")
    return 1 if mismatched else 0


if __name__ == "__main__":
    sys.exit(main())
