"""Does the device's composition give back the bytes the host's does?

`POST_COMPOSE` is `nr_compose_encode`: the head up both bilinear axes, the temporal
gate, the truncation onto the half grid, the grade, and the encoding into the words
the game is handed. This runs a frame both ways and compares the bytes, which is the
only thing downstream ever sees.

    python src/bench/check_post_compose.py [frames] [still|temporal]

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
import xmxres                                       # noqa: E402

WIDTH, HEIGHT = 1920, 1080
HEAD_WIDTH, HEAD_HEIGHT = 768, 448
LOCAL = 256
INTENSITY = 1.0
CHANGE_ROWS, STEP = 4, 8


def axis_plan(source_extent, count):
    """`nr_image._axis_plan`'s three arrays, packed as one float32 run."""
    packed = []
    for array in nr_image._axis_plan(source_extent, count):
        flat = np.ascontiguousarray(np.asarray(array).reshape(-1))
        if flat.dtype != np.float32:
            flat = np.ascontiguousarray(flat.astype(np.int32)).view(np.float32)
        packed.append(flat.astype(np.float32))
    return np.ascontiguousarray(np.concatenate(packed))


def parameters(width, height, scalars, gate):
    """The one block the pass reads: both gather tables, the 256 byte values, the
    gate table, and the scalars."""
    plan_y = axis_plan(HEAD_HEIGHT, height)
    plan_x = axis_plan(HEAD_WIDTH, width)
    by255 = (np.arange(256, dtype=np.float32) / np.float32(255.0))
    return np.ascontiguousarray(np.concatenate(
        [plan_y, plan_x, by255, gate, np.asarray(scalars, np.float32)]))


class Device:
    def __init__(self, width, height, channels, gate):
        self.width, self.height, self.channels = width, height, channels
        self.pixels = width * height
        self.groups = -(-self.pixels // LOCAL)
        self.sampled = -(-width // STEP) * -(-height // STEP)
        self.runtime = xmxres.Runtime()
        self.raw = self.runtime.buffer(self.pixels, np.uint32, xmxres.HOST_WRITE)
        self.head = self.runtime.buffer(HEAD_HEIGHT * HEAD_WIDTH * channels,
                                        np.float32, xmxres.GRAPH)
        # The frame before: its composition as float32 triples, then — at `3 * pixels`
        # — its own words, four bytes a pixel. Decoded in the pass, so the host never
        # holds 25 MB of float32 pixels it only ever differences against.
        self.history = self.runtime.buffer(4 * self.pixels, np.float32,
                                           xmxres.HOST_WRITE)
        composed = self.pixels * 3
        neural = composed
        partial = self.groups
        samples = self.sampled * channels
        words = self.pixels
        self.at = dict(composed=0, neural=composed,
                       partial=composed + neural,
                       samples=composed + neural + partial,
                       encoded=composed + neural + partial + samples)
        self.size = composed + neural + partial + samples + words
        self.answer = self.runtime.buffer(self.size, np.float32, xmxres.HOST_READ)
        self.params = None

    def scalars(self, top=0, left=0, change_rows=CHANGE_ROWS, with_history=True):
        return [INTENSITY, 1.0, 0.0, 0.0, 0.0, 1.0,          # scale..confidence
                top, left, self.width, change_rows, STEP,
                self.at["samples"], self.at["encoded"], self.at["partial"],
                self.at["neural"], 0.0, 0.0, 0.0,             # the grade's three
                0.0, 0.0]                                    # which of `d`'s two

    def load(self, gate, **kwargs):
        scalars = self.scalars(**kwargs)
        block = parameters(self.width, self.height, scalars, gate)
        if self.params is None:
            self.params = self.runtime.buffer(block.size, np.float32, xmxres.GRAPH)
        xmxres.host_write(self.params, block)
        return block

    def run(self, payload, head, history=None, previous=None, previous_words=None,
            gate=None, **kwargs):
        self.load(gate, **kwargs)
        xmxres.host_write(self.raw, np.frombuffer(payload, np.uint32))
        xmxres.host_write(self.head, np.ascontiguousarray(head.reshape(-1), np.float32))
        if history is not None:
            flat = np.ascontiguousarray(history.reshape(-1), np.float32)
            block = np.zeros(4 * self.pixels, np.float32)
            block[:flat.size] = flat
            if previous_words is not None:
                block.view(np.uint32)[3 * self.pixels:] = previous_words
            xmxres.host_write(self.history, block)
        self.runtime.begin()
        self.runtime.post_compose(
            self.raw, self.head, self.params, self.history, self.answer,
            width=self.width, height=self.height, source_width=self.width,
            head_width=HEAD_WIDTH, head_height=HEAD_HEIGHT, channels=self.channels,
            with_history=history is not None, with_previous=previous is not None)
        self.runtime.submit()
        words = self.answer.download(np.float32, self.size)
        # The words were written as bytes and read back as floats: the bits are what
        # matter, so reinterpret rather than convert.
        return np.ascontiguousarray(words[self.at["encoded"]:]).view(np.uint32).view(np.uint8)


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    temporal = (sys.argv[2] if len(sys.argv) > 2 else "temporal") != "still"
    channels = 4 if temporal else 3
    gate = nr_frame.gate_table(float(nr_frame.BLEND_SCALE))
    device = Device(WIDTH, HEIGHT, channels, gate)
    rng = np.random.default_rng(20261011)

    print(f"{WIDTH}x{HEAD_HEIGHT} head {HEAD_WIDTH}x{HEAD_HEIGHT}, "
          f"{channels} channels, {'temporal' if temporal else 'still'}, {frames} frames")

    host_ms, device_ms, mismatch = [], [], 0
    for frame in range(frames):
        payload = rng.integers(0, 256, size=HEIGHT * WIDTH * 4, dtype=np.uint8).tobytes()
        head = rng.random((HEAD_HEIGHT, HEAD_WIDTH, channels)).astype(np.float32)
        history = previous = previous_words = None
        if temporal:
            history = rng.random((HEIGHT, WIDTH, 3)).astype(np.float32)
            # The frame before's pixels reach the device as the bytes the game sent
            # rather than as float32: the pass decodes them through the same 256
            # values, and the host decodes the same bytes for its own side.
            before = rng.integers(0, 256, size=HEIGHT * WIDTH * 4, dtype=np.uint8).tobytes()
            previous = nr_image.decode8(before, WIDTH, HEIGHT, True)
            previous_words = np.frombuffer(before, np.uint32)

        started = time.perf_counter()
        colour = nr_image.decode8(payload, WIDTH, HEIGHT, True)
        encoded_host = bytearray(payload)
        nr_frame.compose_encode(head, colour,
                                np.frombuffer(encoded_host, np.uint8).reshape(HEIGHT, WIDTH, 4),
                                bgra=True, intensity=INTENSITY, history=history,
                                history_confidence=1.0, history_previous=previous,
                                samples=STEP, change_rows=0)
        host_ms.append((time.perf_counter() - started) * 1e3)

        started = time.perf_counter()
        got = device.run(payload, head, history, previous, previous_words, gate=gate)
        device_ms.append((time.perf_counter() - started) * 1e3)

        if bytes(got) != bytes(encoded_host):
            mismatch += 1
            want = np.frombuffer(bytes(encoded_host), np.uint8)
            if got.shape != want.shape:
                print(f"  frame {frame}: shape {got.shape} vs {want.shape}")
                continue
            delta = np.abs(got.astype(np.int16) - want.astype(np.int16))
            bad = int((delta > 0).sum())
            print(f"  frame {frame}: {bad} of {delta.size} bytes differ, "
                  f"largest {int(delta.max())}")
            for i in np.flatnonzero(delta > 0)[:6]:
                print(f"    byte {i}: device {int(got[i])} host {int(want[i])}")

    median = statistics.median
    print()
    print(f"byte-identical frames: {frames - mismatch}/{frames}")
    print(f"host   decode + compose_encode: {median(host_ms):7.2f} ms")
    print(f"device one pass + the read back: {median(device_ms):7.2f} ms "
          f"(the read is {WIDTH * HEIGHT * 4 / 1e6:.1f} MB the host path never makes)")
    return 1 if mismatch else 0


if __name__ == "__main__":
    sys.exit(main())
