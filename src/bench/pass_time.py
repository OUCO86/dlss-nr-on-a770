#!/usr/bin/env python3
"""Where a frame's *time* goes, measured by the device, attributed to pass kinds.

`src/bench/traffic_audit.py` counts bytes. Bytes are not time: a pass that reads 130 MB out
of DRAM and a pass that reads 130 MB that is still in L2 cost very different things, and
on this card the whole network sits near the DRAM ceiling, so the difference is the
whole question. `libxmx` timestamps every pass on the device (`xmx_profile`), and the
passes come back in recording order, which is the order this script's hooks see them.

So: record a real frame, read the device's own milliseconds per pass, and add them up by
kind. Everything an optimisation can hope to win is one of these rows.
"""
import collections
import os
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import xmxres
import nr_model
import nr_frame_resident as F
import traffic_audit as TA


def main():
    height = int(os.environ.get("AUDIT_H", "1080"))
    width_ = int(os.environ.get("AUDIT_W", "1920"))
    for name in TA.HOOKS:
        if hasattr(xmxres.Runtime, name):
            TA.wrap(name)

    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    rt = xmxres.Runtime()

    real_prepare = F.ResidentFrame._prepare_scratch

    def counted(self, capture):
        out = real_prepare(self, capture)
        # the dry run is over: what follows is one frame, and the counter starts here
        TA.CALLS.clear()
        TA.MISSED.clear()
        xmxres.profile_reset()
        return out

    F.ResidentFrame._prepare_scratch = counted
    xmxres.profile(True)
    frame = F.ResidentFrame(rt, model.weights, height, width_)
    frame.run(np.zeros((height, width_, 16), np.float32))

    each = xmxres.profile_each()
    calls = list(TA.CALLS)
    # One frame is not a measurement. A replayed frame has no Python calls to attribute —
    # the graph is already recorded — so the recording frame's own list is what names the
    # passes in every frame after it, in the same order, and the numbers below are the mean
    # of `rounds` replays. Two runs of one frame put the same kind 4 ms apart.
    rounds = int(os.environ.get("AUDIT_ROUNDS", "6"))
    if rounds > 0:
        slots = max(len(each), len(calls))
        summed = [0.0] * slots
        hits = [0] * slots
        for _ in range(rounds):
            xmxres.profile_reset()
            frame.run(np.zeros((height, width_, 16), np.float32))
            for i, ms in enumerate(xmxres.profile_each()):
                if ms < 0 or i >= slots:
                    continue
                summed[i] += ms
                hits[i] += 1
        each = [summed[i] / hits[i] if hits[i] else 0.0 for i in range(slots)]
        print(f"\n{height}x{width_}: mean of {rounds} replayed frames, "
              f"{len(calls)} passes recorded, {len(each)} timed by the device")
    else:
        print(f"\n{height}x{width_}: {len(calls)} passes recorded, "
              f"{len(each)} timed by the device")
    if len(each) != len(calls):
        print(f"  MISMATCH: {len(each)} timestamps against {len(calls)} recorded passes — "
              f"the attribution below is only good for the first {min(len(each), len(calls))}")

    n = min(len(each), len(calls))
    by_kind = collections.Counter()
    count_kind = collections.Counter()
    bytes_kind = TA.collections.Counter()
    for i in range(n):
        ms = each[i]
        if ms < 0:
            continue
        kind = calls[i]["kind"]
        by_kind[kind] += ms
        count_kind[kind] += 1
        bytes_kind[kind] += calls[i]["read"] + calls[i]["write"]

    # The device timed passes this script cannot name, because the recorder that made them
    # is not in HOOKS. They are still milliseconds the frame paid, so they belong in the
    # total — an attribution that quietly drops a quarter of the device was the whole
    # reason this frame looked 9 ms cheaper than the wall clock around it.
    total = sum(ms for ms in each if ms >= 0)
    unattributed = total - sum(by_kind.values())
    if unattributed > 0.005:
        by_kind["(no name for these)"] += unattributed
        count_kind["(no name for these)"] += len(each) - n
    total_bytes = sum(bytes_kind.values())
    print(f"  {'kind':22s} {'ms':>9s} {'share':>7s} {'n':>5s} {'GB':>8s} {'GB/s':>7s}")
    for kind, ms in by_kind.most_common():
        gb = bytes_kind[kind] / 1e9
        print(f"  {kind:22s} {ms:9.2f} {100 * ms / total:6.1f} % {count_kind[kind]:5d}"
              f" {gb:8.2f} {gb / (ms / 1e3):7.0f}")
    print(f"  {'-- everything':22s} {total:9.2f} {100.0:6.1f} % {n:5d}"
          f" {total_bytes / 1e9:8.2f} {total_bytes / 1e9 / (total / 1e3):7.0f}")

    print("\n  the passes whose cost does not follow the frame, by shape "
          "(M at or below 8192):")
    small = [(i, each[i]) for i in range(n) if 0 < calls[i]["rows"] <= 8192]
    shape_ms = TA.collections.Counter()
    shape_n = TA.collections.Counter()
    for i, ms in small:
        c = calls[i]
        key = (c["kind"], c["cols"], c["inner"])
        shape_ms[key] += ms
        shape_n[key] += 1
    small_total = sum(ms for _, ms in small)
    print(f"    {'kind':22s} {'cols':>6s} {'inner':>6s} {'n':>5s} {'ms':>8s} {'share of frame':>15s}")
    for key, ms in shape_ms.most_common(12):
        print(f"    {key[0]:22s} {key[1]:6d} {key[2]:6d} {shape_n[key]:5d} {ms:8.2f}"
              f" {100 * ms / total:14.1f} %")
    print(f"    {'-- all of them':22s} {'':6s} {'':6s} {len(small):5d} {small_total:8.2f}"
          f" {100 * small_total / total:14.1f} %")

    print("\n  the twenty slowest single passes:")
    order = sorted(range(n), key=lambda i: -each[i])[:20]
    for i in order:
        c = calls[i]
        gb = (c["read"] + c["write"]) / 1e9
        print(f"    {c['kind']:22s} rows={c['rows']:<8d} cols={c['cols']:<6d}"
              f" inner={c['inner']:<6d} batch={c['batch']:<4d}"
              f" {each[i]:8.2f} ms  {gb * 1e3:9.2f} MB  "
              f"{gb / (each[i] / 1e3):7.0f} GB/s")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
