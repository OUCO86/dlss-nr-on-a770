#!/usr/bin/env python3
"""Does folding the integer projection's residual into its GEMM actually save anything?

The integer path has been paying for its residual with a pass of its own: write the
float32 branch out, read it back, add `skip * cosine`, publish, write again. 120 passes
a frame, 2.38 ms of the device's 36.4 (`notes/frame-ledger-a770.md`), and one pass more
than the float path pays for the same job. `gemm_staged_int8.comp` has a residual
epilogue now, so those 120 passes can go.

What the saving is, though, is arithmetic so far and not measurement. A pass that
disappears into the one before it does not necessarily get cheaper by what it cost:
the fused GEMM is a bigger shader than the plain one, and both come out of the same
pipeline, so whatever registers the residual needs are spent on every integer product
in the frame, including the 68 that have no residual to add. Occupancy paid there could
easily cost back what the removed pass saves.

So this alternates, within one process, on the game's own frame and extent. Sitting in
one process is the point: two runs of this load about a gigabyte of weights each and
take a quarter of an hour, and a machine that has drifted between them — clocks,
memory, whatever else is on the card — reports a difference that is not the change. The
order alternates too, so a drift that only goes one way does not land entirely on one
side.

    python src/bench/int8_residual_ab.py [rounds]   # rounds pairs of frames
"""
import pathlib
import statistics
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "src" / "layer"))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

FAMILIES = ("gemm", "tiled", "staged", "unary", "row", "history", "copy", "start")


def say(*a):
    print(*a, flush=True)


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    height, width = 448, 768

    import xmxres
    import nr_model
    import nr_frame_resident as F
    import game_settings

    game_settings.apply()

    say("loading the weights ...")
    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    xmxres.profile(True)
    rt = xmxres.Runtime()
    frame = F.ResidentFrame(rt, model.weights, height, width)
    features = np.zeros((height, width, 16), np.float32)

    def switch(enabled):
        """Leave the recording — graphs and the graph key's cache — for the other path.
        Not the scratch plan: the two-pass path needs every role the fused one does and
        one more, so a plan discovered with it covers both, and re-planning every round
        costs far more than the extra buffer is worth keeping it out of the way of."""
        rt.int8_residual = enabled
        for graph in frame._graphs.values():
            graph.free()
        frame._graphs.clear()

    def measure(enabled):
        switch(enabled)
        frame.run(features)                     # records; not the steady state
        device, walls, passes = [], [], []
        split = {}
        for _ in range(2):
            xmxres.profile_reset()
            frame.run(features)
            each = xmxres.profile_each()
            kinds = xmxres.profile_each_kinds()
            device.append(sum(ms for ms in each if ms >= 0))
            walls.append(1000 * frame.split[1])
            passes.append(len(each))
            for j, ms in enumerate(each):
                if ms < 0 or j >= len(kinds):
                    continue
                family = int(kinds[j]) // 32
                sub = int(kinds[j]) % 32
                name = FAMILIES[family] if family < len(FAMILIES) else str(family)
                key = f"{name}/{sub}" if sub else name
                split[key] = split.get(key, 0.0) + ms / 2
        return statistics.mean(device), statistics.mean(walls), statistics.mean(passes), split

    # Plan the scratch once, on the wider of the two graphs, before anything is timed.
    switch(False)
    frame.run(features)
    say("recording once, then alternating the epilogue ...")
    for enabled in (True, False):
        measure(enabled)                        # warm-up; nothing the game sees
    taken = {True: [], False: []}
    clock = {True: [], False: []}
    counted = {True: [], False: []}
    splits = {True: {}, False: {}}
    for round_index in range(rounds):
        # The order reverses each round, so a drift in one direction does not become
        # one side's advantage.
        order = (True, False) if round_index % 2 == 0 else (False, True)
        for enabled in order:
            device, wall, passes, split = measure(enabled)
            taken[enabled].append(device)
            clock[enabled].append(wall)
            counted[enabled].append(passes)
            for key, ms in split.items():
                splits[enabled][key] = splits[enabled].get(key, 0.0) + ms / rounds
            say(f"  round {round_index} {'fused  ' if enabled else 'two-pass'}: "
                f"device {device:6.2f} ms over {passes:4.0f} passes, wall {wall:6.2f} ms")

    fused = statistics.median(taken[True])
    pair = statistics.median(taken[False])
    say("")
    say(f"  {'':12s} {'device':>8s} {'wall':>8s} {'passes':>8s}")
    for label, values, clocked, counting in (("fused", taken[True], clock[True], counted[True]),
                                             ("two-pass", taken[False], clock[False],
                                              counted[False])):
        say(f"  {label:12s} {statistics.median(values):8.2f} "
            f"{statistics.median(clocked):8.2f} {statistics.median(counting):8.0f}")
    say(f"  {'saved':12s} {pair - fused:8.2f} ms   "
        f"({100 * (pair - fused) / pair:+.1f} % of the device's own time), "
        f"{statistics.median(counted[False]) - statistics.median(counted[True]):.0f} passes")
    worst = max(abs(v - statistics.median(taken[k]))
                for k in taken for v in taken[k])
    say(f"  spread within a side {worst:.2f} ms — anything smaller than that is noise")

    say(f"\n  {'family/kind':14s} {'fused':>8s} {'two-pass':>9s} {'saved':>8s}")
    both = sorted(set(splits[True]) | set(splits[False]))
    for key in sorted(both, key=lambda k: -abs(splits[True].get(k, 0.0)
                                               - splits[False].get(k, 0.0))):
        before, after = splits[False].get(key, 0.0), splits[True].get(key, 0.0)
        say(f"  {key:14s} {after:8.2f} {before:9.2f} {before - after:8.2f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
