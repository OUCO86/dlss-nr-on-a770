#!/usr/bin/env python3
"""staged against tiled, same device, same dll, one environment variable apart.

`libxmx.c` routes a plain GEMM to the tiled kernel and says why in a comment:
at M = 61440, N = 128 the tiled kernel led at every depth of K, with no cross-
ing point, staged 1494/2848/3478/3685/3482 GF/s against tiled 2135/5340/6811/
6888/6850. That is the "staged costs about half the throughput" claim, and it
is the reason the fused integer GEMM was never worth wiring up — that kernel is
a staged one.

`logs/bench-overhead.txt` happens to be the staged half of that pair, which is
how the two got separated into a comment and a log. This puts them back in one
table, measured now: the same sweep, and the routes chosen by XMX_PREFER_STAGED.
The variable is read when the library starts, so the two spellings are two
processes.

    python src/bench/st_vs_tiled.py                  # the route a game gets
    XMX_PREFER_STAGED=1 python src/bench/st_vs_tiled.py
"""
import os
import pathlib
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]   # src/bench/ -> the repo root
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres  # noqa: E402

rt = xmxres.Runtime()

CALLS = 4          # as bench_overhead's K sweep does it, so the two are comparable
REPEATS = 7


def once(m, n, k, calls=CALLS, repeats=REPEATS):
    a = rt.buffer(m * k, np.float16)
    w = rt.buffer(k * n, np.float16)
    c = rt.buffer(m * n, np.float32)
    best = 1e9
    for r in range(repeats):
        rt.begin()
        for _ in range(calls):
            rt.gemm(a, w, c, m, n, k, epilogue=0)
        t = time.perf_counter()
        rt.submit()
        if r:
            best = min(best, time.perf_counter() - t)
    for buf in (a, w, c):
        buf.free()
    return best


def sweep(m, n, ks):
    print("  %8s %6s %10s %10s" % ("M", "K", "ms", "GFLOP/s"), flush=True)
    out = {}
    for k in ks:
        dt = once(m, n, k)
        f = 2.0 * m * n * k * CALLS
        out[k] = f / dt / 1e9
        print("  %8d %6d %10.3f %10.1f" % (m, k, 1000 * dt, out[k]), flush=True)
    return out


print("route: %s" % ("staged (XMX_PREFER_STAGED=1)"
                     if os.environ.get("XMX_PREFER_STAGED") == "1"
                     else "default (tiled, what a game gets)"), flush=True)

KS = (32, 128, 512, 2048, 8192)
sweep(61440, 128, KS)

# The frame's own shapes sit at the other end: M is the token count, not a
# hundred thousand, and the sweep above says nothing about them.
print(flush=True)
print("  the frame's own shapes (M = tokens, K = channels)", flush=True)
print("  %8s %6s %6s %10s %10s" % ("M", "N", "K", "ms", "GFLOP/s"), flush=True)
for m, n, k in ((21504, 128, 64), (5376, 128, 128), (1344, 256, 256),
                (384, 512, 512), (96, 4096, 1024), (96, 1024, 4096)):
    dt = once(m, n, k)
    f = 2.0 * m * n * k * CALLS
    print("  %8d %6d %6d %10.3f %10.1f" % (m, n, k, 1000 * dt, f / dt / 1e9), flush=True)
