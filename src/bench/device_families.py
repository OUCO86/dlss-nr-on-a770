#!/usr/bin/env python3
"""Where a frame's device time goes, named by the device itself.

`src/bench/pass_time.py` names each pass after the Python call that recorded it, matched by
index. That correspondence does not hold: `ffn_fused` records several device passes for
one call, so every pass after the first of them is attributed one place along from its
own shape, and the shapes it reports are quietly wrong.

The device already puts a kind on every timestamp it writes — GEMM, tiled, staged, unary,
row, history, copy — and it does not care who asked. This sums those instead. The names
are coarser than `ffn_fused` or `quantize_row`, but they cannot be out of step, and the
total is the same either way.

    python src/bench/device_families.py [rounds]

The first frame is recorded and necessarily pays recording; `rounds` frames are then
replayed from the captured graph, which is what a game does after its first frame, and the
mean of those is what is reported. One frame is not a measurement.
"""
import collections
import pathlib
import statistics
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))

FAMILIES = ("gemm", "tiled", "staged", "unary", "row", "history", "copy", "start")


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    height, width_ = 448, 768

    import xmxres
    import nr_model
    import nr_frame_resident as F

    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    xmxres.profile(True)
    rt = xmxres.Runtime()
    frame = F.ResidentFrame(rt, model.weights, height, width_)
    frame.run(np.zeros((height, width_, 16), np.float32))      # records the graph

    totals = collections.Counter()
    counts = collections.Counter()
    per_sub = collections.Counter()
    frames = []
    for _ in range(rounds):
        xmxres.profile_reset()
        frame.run(np.zeros((height, width_, 16), np.float32))
        each = xmxres.profile_each()
        kinds = xmxres.profile_each_kinds()
        frames.append(sum(ms for ms in each if ms >= 0))
        for i, ms in enumerate(each):
            if ms < 0 or i >= len(kinds):
                continue
            family, sub = kinds[i] // 32, kinds[i] % 32
            name = FAMILIES[family] if family < len(FAMILIES) else str(family)
            totals[name] += ms
            counts[name] += 1
            per_sub[(name, sub)] += ms

    device = statistics.median(frames)
    print(f"\n{width_}x{height}: mean of {rounds} replayed frames, "
          f"{sum(counts.values())} passes a frame")
    print(f"  {'family':10s} {'ms':>8s} {'share':>7s} {'n':>6s} {'ms/pass':>9s}")
    for name, ms in totals.most_common():
        ms /= rounds
        n = counts[name] / rounds
        print(f"  {name:10s} {ms:8.2f} {100 * ms / device:6.1f} % {n:6.0f} {ms / n:9.3f}")
    print(f"  {'-- device':10s} {device:8.2f} {100.0:6.1f} % "
          f"{sum(counts.values()) / rounds:6.0f}   (min {min(frames):.2f}, "
          f"max {max(frames):.2f} over the rounds)")

    print("\n  the busiest kind within each family, where a family has more than one:")
    seen = collections.defaultdict(list)
    for (name, sub), ms in per_sub.items():
        seen[name].append((ms, sub))
    for name in [n for n, _ in totals.most_common()]:
        rows = sorted(seen[name], reverse=True)[:4]
        if len(rows) < 2:
            continue
        print(f"    {name:10s} " + "  ".join(
            f"sub {sub}: {ms / rounds:6.2f} ms" for ms, sub in rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
