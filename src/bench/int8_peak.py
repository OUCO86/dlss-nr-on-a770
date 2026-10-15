#!/usr/bin/env python3
"""Peak integer GEMM throughput of the shipped int8 kernel, and what the frame's real
shapes get beside it.

The question this answers, in one run: the frame spends 17.6 ms of its 44.7 on the
int8 GEMM family (frame_ledger, 960x544). Is that because the kernel is slow, or
because the shapes are small? So measure the same kernel on a grid that saturates the
machine (many full 64x32 blocks over every XMX engine) and on every shape the frame
actually records, and report GFLOP/s for both.

Device time, not wall: `xmxres.profile(True)` turns on the per-pass timestamps libxmx
writes with its own stamps, so a submit's total is the sum of the passes' device
times and launch never enters the number.

    python src/bench/int8_peak.py

int8 is counted as 2 FLOP per multiply-add (mul + add), the same convention
`tiled_ab.py` and `block_peak.py` use for fp16, so the columns compare.
"""
import os
import pathlib
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "bench"))
import game_settings
game_settings.apply()
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres

# A saturating grid: one column block of 1024, `groups` row blocks of 64, K deep
# enough that the loads amortise. 64*groups rows x 1024 cols x K, so the block count
# climbs past the 64 XMX engines x 4 subgroups the machine can hold at once.
SATURATE = [(64 * g, 1024, 1024) for g in (16, 32, 64, 128, 256, 512)]

# Every int8 GEMM shape the 960x544 frame records, from work/ledger-960x544.txt:
# (M, N, K, calls). The big QKV projections, the split FFN, the grouped feed-forward.
FRAME = [
    (32640, 64, 64, 2), (32640, 128, 64, 2), (35712, 64, 64, 2), (34560, 64, 64, 2),
    (33728, 64, 64, 2), (8640, 128, 128, 6), (9216, 128, 128, 6), (2560, 256, 256, 16),
    (192, 1024, 1024, 8), (768, 512, 512, 8), (960, 512, 512, 8), (2560, 256, 256, 16),
    (640, 512, 512, 16), (640, 2048, 512, 16), (240, 4096, 1024, 16),
]


def run(rt, m, n, k, calls, fp16=False):
    """One saturated GEMM shape, device time. `fp16` runs the float staged kernel
    through the same profile, so the two columns are the same machine, same power
    cap, same timing basis — the only difference is the path (int8 vs fp16 coopmat)."""
    dt = np.float16 if fp16 else np.int8
    a = rt.buffer(m * k, dt)
    w = rt.buffer(k * n, dt)
    c = rt.buffer(m * n, np.float32)
    if fp16:
        xmxres.profile(True)
        best = 1e18
        for repeat in range(3):
            xmxres.profile_reset()
            rt.begin()
            for _ in range(calls):
                rt.gemm(a, w, c, m, n, k)
            rt.submit()   # blocks on the fence; device done on return
            device = sum(ms for ms in xmxres.profile_each() if ms >= 0)
            if device > 0:
                best = min(best, device)
        flop = 2.0 * m * n * k * calls
        for buf in (a, w, c):
            buf.free()
        return best, flop / (best * 1e-3) / 1e9
    a_scale = rt.buffer(m, np.float32)
    w_scale = rt.buffer(n, np.float32)
    xmxres.profile(True)
    best = 1e18
    for repeat in range(3):
        xmxres.profile_reset()
        rt.begin()
        for _ in range(calls):
            rt.gemm_int8(a, w, c, a_scale, w_scale, m, n, k)
        rt.submit()   # submit_commands blocks on its fence: the device is done on return
        device = sum(ms for ms in xmxres.profile_each() if ms >= 0)
        if device > 0:
            best = min(best, device)
    flop = 2.0 * m * n * k * calls
    for buf in (a, w, c, a_scale, w_scale):
        buf.free()
    return best, flop / (best * 1e-3) / 1e9  # ms, GFLOP/s


def main():
    rt = xmxres.Runtime()
    print("saturating grid (one kernel, many blocks):")
    print("  --- int8 (the shipped path) ---")
    peak = 0.0
    for m, n, k in SATURATE:
        ms, rate = run(rt, m, n, k, 1)
        peak = max(peak, rate)
        print(f"  {m:6d}x{n:4d}x{k:4d}  {ms:8.3f} ms  {rate:9.1f} GFLOP/s", flush=True)
    print(f"  int8 peak {peak:.1f} GFLOP/s")
    print("  --- fp16 (the same coopmat path, float operands) ---")
    fp_peak = 0.0
    for m, n, k in SATURATE:
        ms, rate = run(rt, m, n, k, 1, fp16=True)
        fp_peak = max(fp_peak, rate)
        print(f"  {m:6d}x{n:4d}x{k:4d}  {ms:8.3f} ms  {rate:9.1f} GFLOP/s", flush=True)
    print(f"  fp16 peak {fp_peak:.1f} GFLOP/s; int8/fp16 = {peak / fp_peak:.2f}x"
          f"   (hardware contract says int8 = 2x fp16)")
    print()
    print("the frame's real shapes (device time for all its calls):")
    tot_ms = tot_flop = 0.0
    for m, n, k, calls in FRAME:
        ms, rate = run(rt, m, n, k, calls)
        tot_ms += ms
        tot_flop += 2.0 * m * n * k * calls
        print(f"  {m:6d}x{n:4d}x{k:4d} x{calls:<3d} {ms:8.3f} ms  {rate:9.1f} GFLOP/s"
              f"  {rate / peak * 100:5.1f}% of peak", flush=True)
    print(f"  frame int8 total {tot_ms:.2f} ms, aggregate {tot_flop / (tot_ms * 1e-3) / 1e9:.1f} GFLOP/s")


if __name__ == "__main__":
    main()
