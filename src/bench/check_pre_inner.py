"""Does the device's own request pass give back the host's bytes?

`nr_decode8` and the two bilinear axes `nr_daemon.resample` runs are one pass on the
device now (`PRE_INNER` in `resident.comp`). This puts that pass beside the host's over
random full-resolution frames, alternating inside one process so a drifting clock
cannot flatter either side, and reports agreement and cost separately. The same pass
also sums |this inner - the frame before's| a workgroup, which is the cut test; that
sum is checked against the host's own difference too.

    python src/bench/check_pre_inner.py [frames] [identity]

"identity" asks for the source's own extent, where every weight is zero and the
resample is a copy: what is left is the decode, so a difference appearing only there
is the decode's and one that shows up under scaling is the interpolation's.

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
import xmxres                                       # noqa: E402

SOURCE_WIDTH, SOURCE_HEIGHT = 1920, 1080
SCALE, MIN_EXTENT = 0.4, 512
LOCAL = 256                                         # resident.comp's workgroup width


def inner_extent():
    """The extent the network is handed at this scale, (width, height)."""
    wide, tall = nr_frame.render_extent(SOURCE_WIDTH, SOURCE_HEIGHT, SCALE, MIN_EXTENT)
    return int(wide), int(tall)


def plan_for(inner_width, inner_height):
    """The gather tables and the byte scale, as the one float buffer PRE_INNER reads.

    `nr_image.bilinear` runs the rows first and then the columns, and hands each axis
    its own low, high and weight; the order here is the order the shader reads them
    in. Indices are int32, carried as float bits. The 256 entries of `byte / 255.0f`
    follow, because a division in the shader becomes a multiply by the reciprocal on
    this compiler and disagrees with the host's in the last bit on half the values.
    """
    packed = []
    for extent, count in ((SOURCE_HEIGHT, inner_height), (SOURCE_WIDTH, inner_width)):
        for array in nr_image._axis_plan(extent, count):
            flat = np.ascontiguousarray(np.asarray(array).reshape(-1))
            if flat.dtype != np.float32:
                flat = np.ascontiguousarray(flat.astype(np.int32)).view(np.float32)
            packed.append(flat.astype(np.float32))
    packed.append((np.arange(256, dtype=np.float32) / np.float32(255.0)).astype(np.float32))
    joined = np.ascontiguousarray(np.concatenate(packed))
    return joined, joined.size - 256


def host_inner(payload, inner_height, inner_width):
    """What the daemon does today: decode the bytes, then resample them."""
    whole = nr_image.decode8(payload, SOURCE_WIDTH, SOURCE_HEIGHT, True)
    return nr_image.bilinear(whole, (inner_height, inner_width))


class Device:
    """The same two steps as one pass, with the buffers they need kept between frames.

    Two inners, so the frame before's can stay on the device as `previous` instead of
    coming back to the host — which is the point, since reading one back is far and
    away the most expensive thing this file measures.
    """

    def __init__(self, inner_width, inner_height, plan):
        self.inner_width, self.inner_height = inner_width, inner_height
        self.pixels = inner_width * inner_height
        self.plan, self.scale_at = plan
        self.runtime = xmxres.Runtime()
        self.raw = self.runtime.buffer(SOURCE_WIDTH * SOURCE_HEIGHT, np.uint32,
                                       xmxres.HOST_WRITE)
        self.plan_buf = self.runtime.buffer(self.plan.size, np.float32, xmxres.HOST_WRITE)
        self.inner = [self.runtime.buffer(self.pixels * 3, np.float32, xmxres.GRAPH)
                      for _ in range(2)]
        self.which = 0
        groups = -(-self.pixels // LOCAL)
        self.partial = self.runtime.buffer(groups, np.float32, xmxres.HOST_READ)
        self.groups = groups
        xmxres.host_write(self.plan_buf, self.plan)
        self.marks = {}

    def run(self, payload, previous=None):
        """Write `payload` into the extent and return the buffer it landed in."""
        target = self.inner[self.which]
        started = time.perf_counter()
        xmxres.host_write(self.raw, np.frombuffer(payload, np.uint32))
        self.marks["write"] = (time.perf_counter() - started) * 1e3

        started = time.perf_counter()
        self.runtime.begin()
        self.runtime.pre_inner(self.raw, self.plan_buf, target,
                               width=self.inner_width, height=self.inner_height,
                               source_width=SOURCE_WIDTH, source_height=SOURCE_HEIGHT,
                               partial=self.partial, scale_at=self.scale_at,
                               previous=previous, bgra=True)
        self.runtime.submit()
        self.marks["pass"] = (time.perf_counter() - started) * 1e3
        self.which ^= 1
        return target

    def read(self, buffer):
        return buffer.download(np.float32, self.pixels * 3).reshape(
            self.inner_height, self.inner_width, 3)

    def cut(self):
        """|this inner - the previous one|, summed: the cut test's numerator."""
        return float(self.partial.download(np.float32, self.groups).sum())


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 7
    identity = len(sys.argv) > 2 and sys.argv[2] == "identity"
    inner_width, inner_height = ((SOURCE_WIDTH, SOURCE_HEIGHT) if identity
                                 else inner_extent())
    device = Device(inner_width, inner_height, plan_for(inner_width, inner_height))

    print(f"source {SOURCE_WIDTH}x{SOURCE_HEIGHT} -> inner {inner_width}x{inner_height}, "
          f"{frames} frames")

    rng = np.random.default_rng(20261011)
    host_ms, device_ms = [], []
    marks = {"write": [], "pass": [], "read": []}
    mismatched = 0
    payloads = []
    for frame in range(frames):
        payload = rng.integers(0, 256, size=SOURCE_HEIGHT * SOURCE_WIDTH * 4,
                               dtype=np.uint8).tobytes()
        payloads.append(payload)

        started = time.perf_counter()
        expected = host_inner(payload, inner_height, inner_width)
        host_ms.append((time.perf_counter() - started) * 1e3)

        started = time.perf_counter()
        target = device.run(payload)
        for name, values in marks.items():
            if name != "read":
                values.append(device.marks[name])
        started_read = time.perf_counter()
        got = device.read(target)
        marks["read"].append((time.perf_counter() - started_read) * 1e3)
        device_ms.append((time.perf_counter() - started) * 1e3)

        if got.tobytes() != expected.tobytes():
            mismatched += 1
            delta = np.abs(got - expected)
            print(f"  frame {frame}: {int((delta > 0).sum())} of {delta.size} differ, "
                  f"largest {delta.max():.3e}")

    # The cut: this frame's inner against the frame before's, both on the device.
    previous = None
    expecteds = [host_inner(p, inner_height, inner_width) for p in payloads]
    cuts_host, cuts_device = [], []
    for payload, expected in zip(payloads, expecteds):
        device.run(payload, previous=previous)
        if previous is not None:
            cuts_device.append(device.cut())
        previous = device.inner[device.which ^ 1]
    for before, after in zip(expecteds, expecteds[1:]):
        cuts_host.append(float(np.abs(after - before).sum()))

    median = statistics.median
    print()
    print(f"byte-identical frames: {frames - mismatched}/{frames}")
    print(f"host   decode+resample: median {median(host_ms):6.2f} ms")
    print(f"device write+pass     : median {median(marks['write']) + median(marks['pass']):6.2f} ms"
          f"  (write {median(marks['write']):.2f}, pass {median(marks['pass']):.2f})")
    print(f"       reading it back: median {median(marks['read']):6.2f} ms"
          f"  — verification only, the graph never does this")
    if cuts_host:
        worst = max(abs(g - h) / h for g, h in zip(cuts_device, cuts_host))
        print(f"cut sums: host {cuts_host[0]:.1f} vs device {cuts_device[0]:.1f}, "
              f"worst relative gap {worst:.2e} over {len(cuts_host)} frames")
    return 1 if mismatched else 0


if __name__ == "__main__":
    sys.exit(main())
