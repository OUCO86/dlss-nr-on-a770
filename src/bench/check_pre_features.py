"""Does the device's feature pass give back the host's own sixteen channels?

`nr_features_half` is one pass on the device now (`PRE_FEATURES` in `resident.comp`):
the mirror onto the network extent, the three roundings of `scaled_color`, the noise,
the five controls and the history in channels 7-9, written straight into the graph's
input. This checks that pass against the host's, with and without a history, over
random frames at the extent a 1920x1080 frame at scale 0.4 actually reaches.

    python src/bench/check_pre_features.py [frames]

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
import xmxres                                       # noqa: E402

SOURCE_WIDTH, SOURCE_HEIGHT = 1920, 1080
SCALE, MIN_EXTENT = 0.4, 512
PROFILE = "standard"


def geometry_and_extent():
    wide, tall = nr_frame.render_extent(SOURCE_WIDTH, SOURCE_HEIGHT, SCALE, MIN_EXTENT)
    return nr_frame.network_geometry(int(wide), int(tall), minimum=MIN_EXTENT)


def controls_for(profile):
    """The five values `build_features` puts in channels 10-14, each rounded to half."""
    values = dict(nr_frame.PROFILES[profile])
    return np.array([nr_frame.half(values.get("normalized_style", 0.0)),
                     nr_frame.half(values.get("local_tone_strength", 1.0)),
                     nr_frame.half(values.get("local_structure_strength", 1.0)),
                     -1.0, -1.0], np.float32)


def plan_for(geometry, noise, controls):
    """Row gather, column gather, noise, controls — one float buffer, in that order."""
    rows = np.ascontiguousarray(geometry.source_rows()).astype(np.int32).view(np.float32)
    columns = np.ascontiguousarray(geometry.source_columns()).astype(np.int32).view(np.float32)
    flat = np.ascontiguousarray(noise.reshape(-1)).astype(np.float32)
    joined = np.ascontiguousarray(np.concatenate([rows, columns, flat, controls]))
    return joined, rows.size, rows.size + columns.size


class Device:
    def __init__(self, geometry, plan, inner_shape):
        self.geometry = geometry
        self.plan, self.columns_at, self.noise_at = plan
        self.width, self.height = geometry.network_width, geometry.network_height
        self.pixels = self.width * self.height
        self.inner_height, self.inner_width = inner_shape
        self.runtime = xmxres.Runtime()
        self.inner = self.runtime.buffer(self.inner_height * self.inner_width * 3,
                                        np.float32, xmxres.HOST_WRITE)
        self.history = self.runtime.buffer(self.inner_height * self.inner_width * 3,
                                          np.float32, xmxres.HOST_WRITE)
        self.plan_buf = self.runtime.buffer(self.plan.size, np.float32, xmxres.HOST_WRITE)
        self.features = self.runtime.buffer(self.pixels * 16, np.float16, xmxres.GRAPH)
        self.controls_at = self.plan.size - 5
        xmxres.host_write(self.plan_buf, self.plan)
        self.marks = {}

    def run(self, inner, history=None):
        started = time.perf_counter()
        xmxres.host_write(self.inner, inner)
        if history is not None:
            xmxres.host_write(self.history, history)
        self.marks["write"] = (time.perf_counter() - started) * 1e3

        started = time.perf_counter()
        self.runtime.begin()
        self.runtime.pre_features(self.inner, self.plan_buf, self.features,
                                  width=self.width, height=self.height,
                                  inner_width=self.inner_width,
                                  columns_at=self.columns_at, noise_at=self.noise_at,
                                  controls_at=self.controls_at,
                                  history=None if history is None else self.history)
        self.runtime.submit()
        self.marks["pass"] = (time.perf_counter() - started) * 1e3
        return self.features

    def read(self):
        return self.features.download(np.float16, self.pixels * 16).reshape(
            self.height, self.width, 16)


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 6
    geometry = geometry_and_extent()
    inner_height = SOURCE_HEIGHT if False else None
    # the inner extent the network is handed, from the same call the daemon makes
    wide, tall = nr_frame.render_extent(SOURCE_WIDTH, SOURCE_HEIGHT, SCALE, MIN_EXTENT)
    inner_shape = (int(tall), int(wide))
    noise = nr_frame.deterministic_noise(geometry.network_height, geometry.network_width, 0)
    controls = controls_for(PROFILE)
    device = Device(geometry, plan_for(geometry, noise, controls), inner_shape)

    print(f"inner {inner_shape[1]}x{inner_shape[0]} -> network "
          f"{geometry.network_width}x{geometry.network_height}, {frames} frames")

    rng = np.random.default_rng(20261011)
    host_ms, device_ms = [], []
    marks = {"write": [], "pass": []}
    mismatched = 0
    for frame in range(frames):
        inner = rng.random(inner_shape + (3,), dtype=np.float32) * 2.0 - 0.5
        history = None if frame % 3 == 0 else rng.random(inner_shape + (3,),
                                                         dtype=np.float32) * 2.0 - 0.5

        started = time.perf_counter()
        expected = nr_frame.build_features(inner, geometry=geometry, history=history,
                                           **nr_frame.PROFILES[PROFILE])
        expected = expected.astype(np.float16)
        host_ms.append((time.perf_counter() - started) * 1e3)

        started = time.perf_counter()
        device.run(inner, history)
        for name, values in marks.items():
            values.append(device.marks[name])
        got = device.read()
        device_ms.append((time.perf_counter() - started) * 1e3)

        if got.tobytes() != expected.tobytes():
            mismatched += 1
            delta = np.abs(got.astype(np.float32) - expected.astype(np.float32))
            bad = int((delta > 0).sum())
            print(f"  frame {frame} (history {'no' if history is None else 'yes'}): "
                  f"{bad} of {delta.size} differ, largest {delta.max() if bad else 0:.3e}")

    median = statistics.median
    print()
    print(f"byte-identical frames: {frames - mismatched}/{frames}")
    print(f"host   features+half : median {median(host_ms):6.2f} ms")
    print(f"device write+pass    : median {median(marks['write']) + median(marks['pass']):6.2f} ms"
          f"  (write {median(marks['write']):.2f}, pass {median(marks['pass']):.2f})")
    return 1 if mismatched else 0


if __name__ == "__main__":
    sys.exit(main())
