"""Does the wired composition give back the bytes the host's does?

`RequestPass.finish` is the whole back half of a frame on the device: the head up
both bilinear axes, the temporal gate over the previous frame's prediction, the
truncation onto the half grid, the grade, the encoding — and what the frame after
this one will steady against, which it leaves on the card rather than on the host.

This runs two frames both ways — the first with no history to have, the second
steadied against the first — and compares the bytes, which is the only thing the
game ever sees, together with the change figure and the gate's samples.

    python src/bench/check_wired_finish.py

The new shader is read from `work/_pre_resident.spv` when it exists, so trying a
change never has to move the shipped one.
"""

import os
import pathlib
import sys

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
import nr_frame_resident                            # noqa: E402
import xmxres                                       # noqa: E402

WIDTH, HEIGHT = 1920, 1080
INNER_W, INNER_H = 768, 448
CHANNELS = 4
STEP = 8
CHANGE_ROWS = 4
INTENSITY = 1.0


def main():
    geometry = nr_frame.NetworkGeometry(INNER_W, INNER_H, INNER_W, INNER_H)
    grade = nr_frame.grade_for(**nr_frame.PROFILES["standard"])
    rng = np.random.default_rng(20261011)

    runtime = xmxres.Runtime()
    # No backend: `finish` never asks it for a frame, only `assemble` does.
    request = nr_frame_resident.RequestPass(
        runtime, None, geometry, source=(WIDTH, HEIGHT), inner=(INNER_W, INNER_H),
        noise=nr_frame.deterministic_noise(INNER_H, INNER_W, 0),
        controls=nr_frame.control_vector("standard"), bgra=True)
    head_buffer = runtime.buffer(INNER_H * INNER_W * CHANNELS, np.float32,
                                 xmxres.GRAPH)

    def device(payload, head, has_history):
        xmxres.host_write(head_buffer,
                          np.ascontiguousarray(head.reshape(-1), np.float32))
        request.prepare(payload)
        words, change, samples = request.finish(
            head_buffer, INNER_W, channels=CHANNELS, intensity=INTENSITY,
            scale=float(nr_frame.BLEND_SCALE), grade=tuple(np.asarray(grade).reshape(-1)[:3]),
            confidence=1.0, hold=0.0, slope=0.0, release=0.0,
            has_history=has_history, keep_neural=True,
            change_rows=CHANGE_ROWS, bgra=True)
        return np.ascontiguousarray(words).view(np.uint8), change, samples

    def host(payload, head, neural, history=None, previous=None):
        colour = nr_image.decode8(payload, WIDTH, HEIGHT, True)
        encoded = bytearray(payload)
        composed, samples = nr_frame.compose_encode(
            head, colour,
            np.frombuffer(encoded, np.uint8).reshape(HEIGHT, WIDTH, 4),
            bgra=True, intensity=INTENSITY, history=history,
            history_confidence=1.0, history_previous=previous, samples=STEP,
            change_rows=0, grade=grade, neural=neural)
        change = float(np.abs(composed[::CHANGE_ROWS] - colour[::CHANGE_ROWS]).mean())
        return colour, encoded, neural, change, samples

    print(f"{WIDTH}x{HEIGHT} from a {INNER_W}x{INNER_H} head, {CHANNELS} channels, "
          f"two frames (the second steadied against the first)")

    mismatch = 0
    history = previous = None
    for frame in range(2):
        payload = rng.integers(0, 256, size=HEIGHT * WIDTH * 4, dtype=np.uint8).tobytes()
        head = rng.random((INNER_H, INNER_W, CHANNELS)).astype(np.float32)
        neural = np.empty((HEIGHT, WIDTH, 3), np.float32)

        colour, encoded, neural, host_change, host_samples = host(
            payload, head, neural, history=history, previous=previous)
        words, device_change, device_samples = device(payload, head,
                                                      has_history=history is not None)

        label = "no history" if history is None else "steadied"
        if bytes(words) != bytes(encoded):
            mismatch += 1
            want = np.frombuffer(bytes(encoded), np.uint8)
            got = np.asarray(words)
            delta = np.abs(got.astype(np.int16) - want.astype(np.int16))
            print(f"  frame {frame} ({label}): {int((delta > 0).sum())} of "
                  f"{delta.size} bytes differ, largest {int(delta.max())}")
        else:
            print(f"  frame {frame} ({label}): byte-identical")
        print(f"    change  host {host_change:.5f}   device {device_change:.5f}")
        if host_samples.shape == device_samples.shape:
            same = int(np.array_equal(
                np.asarray(host_samples, np.float32),
                np.asarray(device_samples, np.float32)))
            print(f"    samples {device_samples.shape}: {'identical' if same else 'DIFFER'}")
        else:
            print(f"    samples shape {device_samples.shape} vs {host_samples.shape}")

        history, previous = neural, colour

    print()
    print(f"byte-identical frames: {2 - mismatch}/2")
    return 1 if mismatch else 0


if __name__ == "__main__":
    sys.exit(main())
