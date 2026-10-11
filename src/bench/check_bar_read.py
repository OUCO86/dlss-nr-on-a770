#!/usr/bin/env python3
"""What it costs the host to read a frame's worth of bytes out of each kind of memory.

Phase 2's way back put the answer in a type 3 buffer — VRAM seen through the bar —
and had the layer read it there instead of out of the slot in shared memory. The
game went from 40.0 ms to 50.0 ms with that on, and then crashed, while the
device's own time never moved (gpu stayed at 38 ms). So the whole of it is on the
host, and there is only one read that changed hands.

`notes/host-passes-to-gpu.md` measures the host *writing* the bar at about 1.5 ms
for 8.3 MB, and the device writing system memory at 0.197 ms/MB. What it never
measures is the host *reading* the bar — the section's own table just assumes it,
and guesses 1–2 ms. This is that number.

    python3 src/bench/check_bar_read.py [repeats]

A PCIe bar is uncached and a read cannot be posted: a write can be combined and
forgotten, a read has to wait for the round trip. The two directions of the same
window are not the same price, and this says how far apart they are.
"""
import statistics
import sys
import time

import ctypes

import numpy as np

ROOT = __file__.rsplit("\\", 3)[0] if "\\" in __file__ else __file__.rsplit("/", 3)[0]
sys.path.insert(0, ROOT + "/src/gpu")
sys.path.insert(0, ROOT + "/src/bench")
sys.path.insert(0, ROOT + "/src/ref")

import xmxres                                                # noqa: E402

# One 1920x1080 frame's answer, in bytes.
BYTES = 1920 * 1080 * 4
MB = BYTES / (1 << 20)


def measure(kind, label, repeats):
    """Read `BYTES` out of a buffer of this kind, `repeats` times."""
    runtime = xmxres.Runtime()
    buffer = runtime.buffer(BYTES // 4, np.uint32, kind)
    view = xmxres.host_view(buffer, dtype=np.uint8, shape=(BYTES,))
    coherent, memory_type, _ = xmxres.buffer_place(buffer)
    # Written once so the pages are there, then read; the read is what is being timed
    # and nothing about it should depend on whether the buffer was ever touched.
    view[:] = 0
    # Two ways of moving the same bytes out, because they are not the same price on
    # uncached memory: `memmove` is what the layer actually calls in
    # `nr_layer.c:exchange_receive`, and NumPy's `copy` is what a Python reader
    # reaches for. Reporting one and using the other is how a measurement ends up
    # 400 ms away from what the game saw.
    out = np.empty(BYTES, np.uint8)
    timed = {}
    for how in ("memmove", "numpy copy"):
        def once():
            if how == "memmove":
                ctypes.memmove(out.ctypes.data, view.ctypes.data, BYTES)
            else:
                view.copy()
        once()                          # the first read of a bar page is not the read
        taken = []
        for _ in range(repeats):
            start = time.perf_counter()
            once()
            taken.append(time.perf_counter() - start)
        timed[how] = statistics.median(taken)
    for how, median in timed.items():
        print(f"  {label:<24} type {memory_type} {'coherent' if coherent else 'NOT':>3}"
              f"  {how:<11} {1000 * median:8.2f} ms for {MB:.1f} MB"
              f"  = {MB / median / 1024:7.2f} GB/s"
              f"  = {1000 * median / MB:7.2f} ms/MB")
    return timed["memmove"]


def main():
    repeats = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    print(f"the host reading {MB} MB out of each kind of memory ({repeats} reads):")
    bar = measure(xmxres.HOST_WRITE, "type 3, VRAM through the bar", repeats)
    system = measure(xmxres.HOST_READ, "type 2, system memory", repeats)
    print()
    print(f"  the bar costs {1000 * (bar - system):+.2f} ms a frame to read from, "
          f"against system memory")
    print(f"  ({bar / system:.1f}x slower)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
