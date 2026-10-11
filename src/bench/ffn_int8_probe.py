#!/usr/bin/env python3
"""The 130 float16 products still in the frame, against the integer path.

`notes/improve-int8-a770.md` — "Why the frame's big shapes are not on the integer
path" — has the answer to why they are float: not the shape (129 of 130 pass the
tile gate), not the accuracy, and by its own re-measurement not the speed either
(1.32x, 1.42x, 1.04x for the three 21504-row shapes). It is wiring, and the part
that needs a kernel is the grouped feed-forward: `_ffn_groups` calls `gemm` with
`batch=groups` and strides, and `gemm_int8` has neither a batch nor offsets.

So before anything is built, what a conversion would actually buy, measured now:

    python src/bench/ffn_int8_probe.py

Three things are timed for every shape a frame really runs, **in one process and
alternating**, because on this card a pair of runs taken one after the other cannot
tell the effect apart from the card drifting between them (the note that cost a
"two reads beat one read" 0.46 ms that was really ±0.2 ms of noise):

    fp16/b   the call as the frame makes it, `batch=groups`
    fp16/1   the same work as `groups` separate calls — what a conversion that has
             no batch to fall back on would have to beat
    int8     `quantize_row` once (A is broadcast, so one quantise feeds the whole
             group) then `groups` separate `gemm_int8`

The integer path is off by default in anything that is not the daemon, so the
settings go on first; without them this would measure the 415-pass float graph.
"""
import collections
import pathlib
import statistics
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "bench"))
import game_settings                                              # noqa: E402
game_settings.apply()
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "work"))
import xmxres                                                     # noqa: E402
import nr_model                                                   # noqa: E402
import nr_frame_resident as F                                     # noqa: E402
import nr_resident                                                # noqa: E402
import traffic_audit as TA                                        # noqa: E402

REPEATS = 9
GROUPS = (1, 2, 4)      # the branched blocks are channels // 64, so 1, 2 or 4


def the_shapes():
    """Every float16 product one frame records, as (rows, cols, inner) -> how many."""
    for name in TA.HOOKS:
        if hasattr(xmxres.Runtime, name):
            TA.wrap(name)
    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    rt = xmxres.Runtime()
    # The frame's first pass plans the scratch, and planning records products of its own.
    # Those are not part of a frame, so the count starts after it.
    real_prepare = F.ResidentFrame._prepare_scratch

    def counted(self, capture):
        out = real_prepare(self, capture)
        TA.CALLS.clear()
        return out

    F.ResidentFrame._prepare_scratch = counted
    frame = F.ResidentFrame(rt, model.weights, 448, 768)
    frame.run(np.zeros((448, 768, 16), np.float32))
    counted = collections.Counter((c["rows"], c["cols"], c["inner"])
                                  for c in TA.CALLS if c["kind"] == "gemm")
    return counted, rt


class Fixture:
    """One shape's buffers, built once: the weights do not change between frames."""

    def __init__(self, rt, rows, cols, inner, narrow=True):
        self.rt, self.rows, self.cols, self.inner = rt, rows, cols, inner
        rng = np.random.default_rng(rows * 7919 + cols * 104729 + inner)
        # The weights are quantised once, the way `nr_resident.quantise_weight` does it:
        # the kernel wants B as (N, K) and a scale per output column.
        weight = rng.standard_normal((inner, cols)).astype(np.float32) * 0.05
        integer = nr_resident.quantise_weight(rt, weight)
        self.a = rt.buffer_from(
            (rng.standard_normal((rows, inner)).astype(np.float32) * 0.2).astype(np.float16),
            np.float16)
        self.w = rt.buffer_from(weight.astype(np.float16), np.float16)
        if integer is None:
            self.ready = False
            return
        self.wq, self.w_scale = integer
        self.packed = rt.buffer(rows * inner, np.int8)
        self.a_scale = rt.buffer(rows, np.float32)
        self.c = rt.buffer(rows * cols * (2 if narrow else 4) * 4,
                           np.float16 if narrow else np.float32)
        self.ready = True

    def free(self):
        for name in ("a", "w", "wq", "w_scale", "packed", "a_scale", "c"):
            buf = getattr(self, name, None)
            if buf is not None:
                buf.free()


def fp16_batched(fx, groups, epilogue, narrow):
    fx.rt.gemm(fx.a, fx.w, fx.c, fx.rows, fx.cols, fx.inner, batch=groups,
               strides=(0, fx.inner * fx.cols, fx.cols), leading=(0, 0, fx.cols),
               epilogue=epilogue, narrow=narrow)


def fp16_separate(fx, groups, epilogue, narrow):
    for _ in range(groups):
        fx.rt.gemm(fx.a, fx.w, fx.c, fx.rows, fx.cols, fx.inner,
                   epilogue=epilogue, narrow=narrow)


def int8_separate(fx, groups, epilogue, narrow):
    fx.rt.quantize_row(fx.a, fx.packed, fx.a_scale, fx.rows, fx.inner)
    for _ in range(groups):
        fx.rt.gemm_int8(fx.packed, fx.wq, fx.c, fx.a_scale, fx.w_scale,
                        fx.rows, fx.cols, fx.inner, epilogue=epilogue, narrow=narrow)


ROUTES = (("fp16/b", fp16_batched), ("fp16/1", fp16_separate), ("int8", int8_separate))


AMPLIFY = 12


def wall(rt, fx, groups, build, calls, epilogue, narrow):
    """`calls` products in one submission, timed from the host.

    One product in one submission costs about 0.17 ms however small it is, which at
    these sizes is most of what there is to measure. Recording the same product `calls`
    times and subtracting an empty submission leaves `calls` products' worth of work
    against one lot of overhead — and it needs no timestamps, so it cannot be charged
    for them.
    """
    rt.begin()
    for _ in range(calls):
        build(fx, groups, epilogue, narrow)
    mark = time.perf_counter()
    rt.submit()
    return time.perf_counter() - mark


def main():
    counted, rt = the_shapes()
    print(f"{sum(counted.values())} float16 products in one frame\n")
    order = sorted(counted.items(), key=lambda kv: (-kv[1], kv[0]))
    fixtures = {}
    for (rows, cols, inner), n in order:
        fx = Fixture(rt, rows, cols, inner)
        fixtures[(rows, cols, inner)] = fx if fx.ready else None
    gate = sum(1 for (r, c, k) in counted if c % 32 == 0 and k % 64 == 0)
    print(f"  {gate} of them have a shape the integer GEMM accepts\n")

    header = f"  {'M x N x K':>18s} {'n':>4s} " + " ".join(
        f"{name + '/g%d' % g:>13s}" for g in GROUPS for name, _ in ROUTES)
    print(header, flush=True)

    totals = {g: collections.defaultdict(float) for g in GROUPS}
    for (rows, cols, inner), n in order:
        fx = fixtures[(rows, cols, inner)]
        if fx is None:
            print(f"  {rows:6d}x{cols:4d}x{inner:4d} {n:4d}   (no integer copy: shape)")
            continue
        # One epilogue throughout: the publish is a per-element transform on the way to
        # memory, and E4M3 is the one every one of these shapes ends in.
        best = {}
        samples = collections.defaultdict(list)
        for _ in range(REPEATS):
            for groups in GROUPS:
                for name, build in ROUTES:
                    # Not the least of these: a difference of two timings can come out
                    # negative when the empty submission was the slow one, and the least
                    # of nine differences is then a noise floor, not a measurement.
                    per = ((wall(rt, fx, groups, build, AMPLIFY, xmxres.EPI_E4M3, True)
                            - wall(rt, fx, groups, build, 0, xmxres.EPI_E4M3, True))
                           / AMPLIFY * 1e6)
                    samples[(groups, name)].append(per)
        for key, values in samples.items():
            best[key] = statistics.median(values)
        cells = []
        for groups in GROUPS:
            for name, _ in ROUTES:
                cells.append(f"{best[(groups, name)]:13.1f}")
                totals[groups][name] += best[(groups, name)] * n * 1e-3
        print(f"  {rows:6d}x{cols:4d}x{inner:4d} {n:4d} " + " ".join(cells), flush=True)
        fx.free()

    for label, table in (("the whole frame, %d products a submission" % AMPLIFY, totals),):
        print(f"\n  {label}, milliseconds:")
        print(f"  {'groups':>6s} " + " ".join(f"{name:>10s}" for name, _ in ROUTES)
              + f" {'int8 vs fp16/b':>15s}")
        for groups in GROUPS:
            row = [table[groups][name] for name, _ in ROUTES]
            print(f"  {groups:6d} " + " ".join(f"{v:10.2f}" for v in row)
                  + f" {row[2] - row[0]:+15.2f}")

    print("\n  (microseconds per call, the median of %d rounds of the three routes" % REPEATS)
    print("   alternating in one process. `frame_ledger.py` puts these 130 at 8.42 ms for")
    print("   the whole frame, so the column that lands near 8 is the one a frame runs.)")


if __name__ == "__main__":
    main()
