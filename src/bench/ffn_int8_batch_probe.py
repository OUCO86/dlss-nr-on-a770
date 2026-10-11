#!/usr/bin/env python3
"""What the grouped feed-forward's products cost with the group inside the dispatch.

`src/bench/ffn_int8_probe.py` measured the integer path losing this part of the frame
by 0.26 ms, and that number is the reason 130 products are still float. But the integer
column there was `groups` separate `gemm_int8` calls, because the kernel had no group
index, against a float column that was one batched call — so what it compared was the
integer GEMM's arithmetic *minus* batching against the float GEMM's *plus* it. The same
table says what each is worth on its own: unbatched against unbatched the integer
product wins by 1.55x, and batching the float one is worth 5.37 ms of 14.92.

`xmx_rec_gemm_int8_batched` now takes the group from `gl_WorkGroupID.z`, so the two can
be combined. This measures the combination against both halves, on the shapes a frame
really runs:

    python src/bench/ffn_int8_batch_probe.py

Every shape gets `groups` weights of its own — not one weight read `groups` times —
because a shared operand would be read out of the cache on every group after the first
and would flatter both batched columns by the same unearned margin.
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
import traffic_audit as TA                                        # noqa: E402
import int8_quant                                                 # noqa: E402

REPEATS = 7
GROUPS = 4          # the branched blocks' count; the split family's is 8, see below
AMPLIFY = 12


def the_shapes():
    """Every float16 product one frame records, as (rows, cols, inner) -> how many."""
    for name in TA.HOOKS:
        if hasattr(xmxres.Runtime, name):
            TA.wrap(name)
    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    rt = xmxres.Runtime()
    real_prepare = F.ResidentFrame._prepare_scratch

    def counted(self, capture):
        out = real_prepare(self, capture)
        TA.CALLS.clear()
        return out

    F.ResidentFrame._prepare_scratch = counted
    frame = F.ResidentFrame(rt, model.weights, 448, 768)
    frame.run(np.zeros((448, 768, 16), np.float32))
    return (collections.Counter((c["rows"], c["cols"], c["inner"])
                                for c in TA.CALLS if c["kind"] == "gemm")), rt


class Fixture:
    """One shape's buffers, with `GROUPS` independent sets of weights."""

    def __init__(self, rt, rows, cols, inner):
        self.rt, self.rows, self.cols, self.inner = rt, rows, cols, inner
        rng = np.random.default_rng(rows * 7919 + cols * 104729 + inner)
        if cols % 32 or inner % 64:
            self.ready = False
            return
        self.a = rt.buffer_from(
            (rng.standard_normal((rows, inner)).astype(np.float32) * 0.2).astype(np.float16),
            np.float16)
        # One weight per group, quantised the way `nr_resident.quantise_weight` does it,
        # and laid out the way the batched kernel reads them: group `g`'s matrix at
        # `g * cols * inner`, its scales at `g * cols`.
        half = np.empty((GROUPS, cols, inner), np.float16)
        packed = np.empty((GROUPS, cols, inner), np.int8)
        scale = np.empty((GROUPS, cols), np.float32)
        for g in range(GROUPS):
            weight = rng.standard_normal((inner, cols)).astype(np.float32) * 0.05
            half[g] = weight.astype(np.float16).T
            # The same arithmetic `nr_resident.quantise_weight` hands the kernel: B as
            # (N, K), one scale per output column.
            p, s = int8_quant.quantise(weight, 0)
            packed[g] = p.T
            scale[g] = s
        self.w = rt.buffer_from(np.ascontiguousarray(half.reshape(-1, inner)), np.float16)
        self.wq = rt.buffer_from(np.ascontiguousarray(packed.reshape(-1, inner)), np.int8)
        self.w_scale = rt.buffer_from(np.ascontiguousarray(scale.reshape(-1)), np.float32)
        # One weight per group as a buffer of its own, for the unbatched integer column,
        # which has no offsets to reach into the shared one with.
        self.solo = [rt.buffer_from(np.ascontiguousarray(packed[g]), np.int8)
                     for g in range(GROUPS)]
        self.solo_scale = [rt.buffer_from(np.ascontiguousarray(scale[g]), np.float32)
                           for g in range(GROUPS)]
        self.packed = rt.buffer(rows * inner, np.int8)
        self.a_scale = rt.buffer(rows, np.float32)
        self.c = rt.buffer(rows * cols * GROUPS * 2 * 4, np.float16)
        self.ready = True

    def free(self):
        for name in ("a", "w", "wq", "w_scale", "packed", "a_scale", "c"):
            buf = getattr(self, name, None)
            if buf is not None:
                buf.free()
        for buf in getattr(self, "solo", []) + getattr(self, "solo_scale", []):
            buf.free()


def strides(fx):
    return (0, fx.inner * fx.cols, fx.cols)


def fp16_batched(fx, epilogue, narrow):
    fx.rt.gemm(fx.a, fx.w, fx.c, fx.rows, fx.cols, fx.inner, batch=GROUPS,
               strides=strides(fx), leading=(0, 0, fx.cols),
               epilogue=epilogue, narrow=narrow)


def fp16_separate(fx, epilogue, narrow):
    for g in range(GROUPS):
        fx.rt.gemm(fx.a, fx.w, fx.c, fx.rows, fx.cols, fx.inner,
                   leading=(0, 0, fx.cols),
                   offsets=(0, g * fx.inner * fx.cols, g * fx.cols),
                   epilogue=epilogue, narrow=narrow)


def int8_batched(fx, epilogue, narrow):
    fx.rt.quantize_row(fx.a, fx.packed, fx.a_scale, fx.rows, fx.inner)
    fx.rt.gemm_int8_batched(fx.packed, fx.wq, fx.c, fx.a_scale, fx.w_scale,
                            fx.rows, fx.cols, fx.inner, batch=GROUPS,
                            strides=strides(fx), leading=(0, 0, fx.cols),
                            epilogue=epilogue, narrow=narrow)


def int8_separate(fx, epilogue, narrow):
    fx.rt.quantize_row(fx.a, fx.packed, fx.a_scale, fx.rows, fx.inner)
    for g in range(GROUPS):
        fx.rt.gemm_int8(fx.packed, fx.solo[g], fx.c, fx.a_scale, fx.solo_scale[g],
                        fx.rows, fx.cols, fx.inner, epilogue=epilogue, narrow=narrow)


ROUTES = (("fp16/b", fp16_batched), ("fp16/1", fp16_separate),
          ("int8/1", int8_separate), ("int8/b", int8_batched))


def wall(rt, fx, build, calls, epilogue, narrow):
    """`calls` products in one submission, timed from the host, empty submission removed."""
    rt.begin()
    for _ in range(calls):
        build(fx, epilogue, narrow)
    mark = time.perf_counter()
    rt.submit()
    return time.perf_counter() - mark


def main():
    counted, rt = the_shapes()
    print(f"{sum(counted.values())} float16 products in one frame\n")
    order = sorted(counted.items(), key=lambda kv: (-kv[1], kv[0]))
    fixtures = {}
    for shape, _ in order:
        fx = Fixture(rt, *shape)
        fixtures[shape] = fx if fx.ready else None
    gate = sum(1 for (r, c, k) in counted if c % 32 == 0 and k % 64 == 0)
    print(f"  {gate} of them have a shape the integer GEMM accepts")
    print(f"  {GROUPS} groups, microseconds per call, median of {REPEATS} rounds of the "
          f"four routes alternating in one process\n")
    print(f"  {'M x N x K':>18s} {'n':>4s} " + " ".join(f"{name:>10s}" for name, _ in ROUTES)
          + f" {'int8/b vs fp16/b':>18s}", flush=True)

    totals = collections.defaultdict(float)
    for shape, n in order:
        fx = fixtures[shape]
        rows, cols, inner = shape
        if fx is None:
            print(f"  {rows:6d}x{cols:4d}x{inner:4d} {n:4d}   (no integer copy: shape)")
            continue
        samples = collections.defaultdict(list)
        for _ in range(REPEATS):
            for name, build in ROUTES:
                per = ((wall(rt, fx, build, AMPLIFY, xmxres.EPI_E4M3, True)
                        - wall(rt, fx, build, 0, xmxres.EPI_E4M3, True))
                       / AMPLIFY * 1e6)
                samples[name].append(per)
        best = {name: statistics.median(v) for name, v in samples.items()}
        for name in best:
            totals[name] += best[name] * n * 1e-3
        print(f"  {rows:6d}x{cols:4d}x{inner:4d} {n:4d} "
              + " ".join(f"{best[name]:10.1f}" for name, _ in ROUTES)
              + f" {best['int8/b'] - best['fp16/b']:+18.1f}", flush=True)
        fx.free()

    print(f"\n  the whole frame, {AMPLIFY} products a submission, milliseconds:")
    print("  " + " ".join(f"{name:>10s}" for name, _ in ROUTES))
    print("  " + " ".join(f"{totals[name]:10.2f}" for name, _ in ROUTES))
    base, new = totals["fp16/b"], totals["int8/b"]
    print(f"\n  int8 batched against float batched: {new - base:+.2f} ms "
          f"({(base - new) / base * 100:+.1f} %)")
    print("  (the column a frame runs is the one near 8.5, where `frame_ledger.py` puts")
    print("   these 130 products. int8/1 reproduces `ffn_int8_probe.py`'s 9.81 here.)")


if __name__ == "__main__":
    main()
