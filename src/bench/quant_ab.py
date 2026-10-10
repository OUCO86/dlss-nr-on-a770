#!/usr/bin/env python3
"""Two spellings of the activation quantiser, head to head in one process.

The quantiser walks its row twice: once for the peak that sets the grid, then again to put
the values on it. Two reads of every word, in the second largest line in the frame, looked
like the obvious thing to fix — keep four words a lane in named registers (an array would
spill), read once, reduce, quantise from the registers. `work/quantize_row_onepass.spv` is
that spelling.

It is slower, and `notes/device-budget-a770.md` says why: the second walk is not costing
anything, because the first one has just left the row in L2. What the registers buy is
nothing and what they cost is occupancy.

    python src/bench/quant_ab.py [rounds]

`Runtime.quantize_row` reads `XMX_QUANT_SPV` and re-initialises every time it is called,
so the two spellings can take turns inside one process. That matters more than it sounds:
loading the weights takes about four minutes, and a subprocess per measurement spends most
of its life doing that rather than what is being measured. What does have to be discarded
is the captured graph, whose passes were recorded with whichever spelling was current.
"""
import os
import pathlib
import statistics
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))

SPELLINGS = [("two walks", "quantize_row.spv"),
             ("one walk", "quantize_row_onepass.spv")]


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 3

    import xmxres
    import nr_model
    import nr_frame_resident as F

    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    xmxres.profile(True)
    rt = xmxres.Runtime()
    frame = F.ResidentFrame(rt, model.weights, 448, 768)
    features = np.zeros((448, 768, 16), np.float32)

    results = {name: [] for name, _ in SPELLINGS}
    for round_ in range(rounds):
        for name, spv in SPELLINGS:
            os.environ["XMX_QUANT_SPV"] = str(ROOT / "work" / spv)
            frame._graphs.clear()          # the recorded passes name the old shader
            frame.run(features)            # re-records; its own cost is not counted
            xmxres.profile_reset()
            for _ in range(frames):
                frame.run(features)
            # Every submit appends to the same list, so this is `frames` frames' worth.
            total = sum(ms for ms in xmxres.profile_each() if ms >= 0) / frames
            results[name].append(total)
            print(f"  round {round_}  {name:11s} device {total:7.2f} ms", flush=True)

    print(f"\n  {'':13s} {'device':>9s}")
    medians = {}
    for name, _ in SPELLINGS:
        medians[name] = statistics.median(results[name])
        print(f"  {name:13s} {medians[name]:9.2f}")
    base, new = medians["two walks"], medians["one walk"]
    print(f"\n  one walk against two: {new - base:+.2f} ms of {base:.2f} "
          f"({100 * (new - base) / base:+.1f} %)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
