#!/usr/bin/env python3
"""One frame, all the way down: what the device spends, and who asked for it.

Two questions that used to need two runs, each paying a quarter of an hour to load a
gigabyte of weights, and each answering only its own half:

* `device_families.py` — how the device's milliseconds split by the kind it stamps on
  every pass, which cannot be out of step because the device writes the stamps itself.
* `tiled_shapes.py` — what shapes the float16 products are, read off the Python calls.

Neither says *which line of the graph* a pass came from, and that is the only thing that
turns a number into somewhere to go. So this hooks every runtime method, keeps the
`nr_resident.py` line that called it, records one frame, and then replays it with the
device's timestamps on. One load, both answers.

    python src/bench/frame_ledger.py [rounds]

Prints as it goes, because the load alone is most of the wall clock and a run that dies
at ten minutes should have said something by then.
"""
import collections
import os
import pathlib
import statistics
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

FAMILIES = ("gemm", "tiled", "staged", "unary", "row", "history", "copy", "start")
NAMES = {
    ("gemm", 30): "int8 GEMM, staged (rec_gemm_int8 / _qkv / _fused)",
    ("gemm", 31): "ffn_fused / _merge / _stem",
    ("unary", 12): "quantize_row",
    ("row", 2): "qkv (attention.comp)",
    ("row", 3): "window_attention",
    ("row", 4): "window_block",
    ("row", 5): "global_attention",
}


def say(*a):
    print(*a, flush=True)


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 6
    height, width_ = 448, 768

    import xmxres
    import nr_model
    import nr_frame_resident as F
    import traffic_audit as TA
    import game_settings

    game_settings.apply()

    # Which part of the graph is being recorded. Walking the stack is the obvious way
    # and it does not work here: for the plain `gemm` calls there is no frame below the
    # hook at all, so every one of them came back unnamed. Marking the recorder
    # functions themselves does not care who called whom.
    site_now = ["?"]

    def instrument(module):
        """Mark the graph's own functions, and their classes' methods, as they are
        entered. Methods count: a `gemm` recorded from one of them is recorded from
        nowhere as far as a module-level walk is concerned."""
        def patch(owner, name, fn):
            code = getattr(fn, "__code__", None)
            if code is None or not code.co_filename.endswith("nr_resident.py"):
                return
            label = f"{name}:{code.co_firstlineno}"

            def wrapped(*a, **kw):
                previous = site_now[0]
                site_now[0] = label
                try:
                    return fn(*a, **kw)
                finally:
                    site_now[0] = previous

            wrapped.__name__ = getattr(fn, "__name__", name)
            setattr(owner, name, wrapped)

        for name, value in list(vars(module).items()):
            if isinstance(value, type) and value.__module__ == module.__name__:
                for mname, method in list(vars(value).items()):
                    patch(value, mname, method)
            patch(module, name, value)

    import nr_resident

    instrument(nr_resident)
    instrument(F)          # it re-exports some of them under its own names

    def wrap(name):
        """`traffic_audit`'s hook, plus the part of the graph that made the call."""
        real = getattr(xmxres.Runtime, name)
        sig = TA.HOOKS[name]

        def hooked(self, *args, **kw):
            site = site_now[0]
            mark = len(TA.CALLS)
            try:
                bound = sig(self, args, kw)
            except Exception:
                TA.MISSED[name] += 1
                bound = None
            if bound is not None:
                TA.account(name, *bound)
            # Some of the shape readers above account for their call themselves and
            # return None (`s_gemm` does, to carry the weight counts), so the entry is
            # already there. Mark whatever this call added, however it added it.
            for entry in TA.CALLS[mark:]:
                entry["site"] = site
            return real(self, *args, **kw)

        hooked.__name__ = name
        setattr(xmxres.Runtime, name, hooked)

    say("loading the weights ...")
    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    for name in TA.HOOKS:
        if hasattr(xmxres.Runtime, name):
            wrap(name)
    say("weights in, starting the device ...")
    xmxres.profile(True)
    rt = xmxres.Runtime()
    frame = F.ResidentFrame(rt, model.weights, height, width_)

    real_prepare = F.ResidentFrame._prepare_scratch

    def counted(self, capture):
        out = real_prepare(self, capture)
        TA.CALLS.clear()
        return out

    F.ResidentFrame._prepare_scratch = counted
    say("recording one frame ...")
    frame.run(np.zeros((height, width_, 16), np.float32))
    calls = list(TA.CALLS)
    say(f"recorded: {len(calls)} calls")

    totals = collections.Counter()
    counts = collections.Counter()
    per_sub = collections.Counter()
    per_sub_n = collections.Counter()
    frames = []
    for i in range(rounds):
        xmxres.profile_reset()
        frame.run(np.zeros((height, width_, 16), np.float32))
        each = xmxres.profile_each()
        kinds = xmxres.profile_each_kinds()
        frames.append(sum(ms for ms in each if ms >= 0))
        for j, ms in enumerate(each):
            if ms < 0 or j >= len(kinds):
                continue
            family, sub = int(kinds[j]) // 32, int(kinds[j]) % 32
            name = FAMILIES[family] if family < len(FAMILIES) else str(family)
            totals[name] += ms
            counts[name] += 1
            per_sub[(name, sub)] += ms
            per_sub_n[(name, sub)] += 1
        say(f"  replay {i + 1}/{rounds}: {frames[-1]:.2f} ms")

    device = statistics.median(frames)
    say(f"\n{width_}x{height}: median of {rounds} replayed frames "
        f"(min {min(frames):.2f}, max {max(frames):.2f})")
    say(f"  {'family':10s} {'ms':>8s} {'share':>7s} {'n':>6s} {'ms/pass':>9s}")
    for name, ms in totals.most_common():
        ms /= rounds
        n = counts[name] / rounds
        say(f"  {name:10s} {ms:8.2f} {100 * ms / device:6.1f} % {n:6.0f} {ms / n:9.3f}")
    say(f"  {'-- device':10s} {device:8.2f} {100.0:6.1f} % "
        f"{sum(counts.values()) / rounds:6.0f}")

    say(f"\n  {'kind':12s} {'ms':>7s} {'share':>7s} {'n':>6s} {'ms/pass':>9s}   what")
    for (name, sub), ms in per_sub.most_common():
        n = per_sub_n[(name, sub)] / rounds
        say(f"  {name}/{sub:<7d} {ms / rounds:7.2f} {100 * ms / rounds / device:6.1f} % "
            f"{n:6.0f} {ms / rounds / n:9.3f}   {NAMES.get((name, sub), '')}")

    say("\n\nwhat the graph asked for, by the line that asked:")
    say(f"  {'site':28s} {'kind':14s} {'rows(M)':>8s} {'cols(N)':>8s} {'inner(K)':>9s} {'n':>4s}")
    grouped = collections.Counter()
    for c in calls:
        grouped[(c.get("site", "?"), c["kind"], c["rows"], c["cols"], c["inner"])] += 1
    for (site, kind, rows, cols, inner), n in sorted(
            grouped.items(), key=lambda kv: (kv[0][0], -kv[1])):
        say(f"  {site:28s} {kind:14s} {rows:8d} {cols:8d} {inner:9d} {n:4d}")

    say(f"\n  {len(calls)} calls, {len(grouped)} distinct site/shape pairs")
    unnamed = sum(1 for c in calls if "site" not in c)
    if unnamed:
        say(f"  {unnamed} calls carry no site: a call was accounted without the hook "
            f"seeing it, and the table above is missing part of the frame")
    if TA.MISSED:
        say(f"  shapes the hooks could not read: {dict(TA.MISSED)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
