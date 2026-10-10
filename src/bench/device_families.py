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

# What each (family, sub) is, read off the `stamp()` call in `src/gpu/libxmx.c`.
# A sub that is not listed here is the kernel's own kind word (a unary op, or the
# block type `bt` of a float GEMM) and is printed as a bare number.
NAMES = {
    ("gemm", 30): "int8 GEMM, staged (xmx_rec_gemm_int8 / _qkv / _fused)",
    ("gemm", 31): "ffn_fused / _merge / _stem",
    ("unary", 12): "quantize_row",
    ("row", 2): "qkv (attention.comp)",
    ("row", 3): "window_attention",
    ("row", 4): "window_block",
    ("row", 5): "global_attention",
}


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
    per_sub_n = collections.Counter()
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
            per_sub_n[(name, sub)] += 1

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

    print(f"\n  {'kind':12s} {'ms':>7s} {'share':>7s} {'n':>6s} {'ms/pass':>9s}   what")
    for (name, sub), ms in per_sub.most_common():
        n = per_sub_n[(name, sub)] / rounds
        label = NAMES.get((name, sub), "")
        print(f"  {name}/{sub:<7d} {ms / rounds:7.2f} {100 * ms / rounds / device:6.1f} % "
              f"{n:6.0f} {ms / rounds / n:9.3f}   {label}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
