#!/usr/bin/env python3
"""Where a window block's 0.62 ms goes.

`window_block.comp` is the most expensive pass in the frame per pass — ten of them,
6.20 ms of the device's 34.6 — and it is already the fused spelling, so there is no
pass to take away from it. `notes/HANDOFF.md` timed its three phases once, at
1920x1088: 5.8 ms up to K and V in shared memory, 5.5 for the attention and 1.6 for
the projection and the store, of 12.9. This is that measurement again, at the extent
the daemon really runs (768x448) and with the kernel's own phases taken out rather
than estimated:

    python src/bench/window_block_probe.py --stop 0
    python src/bench/window_block_probe.py --stop 1
    python src/bench/window_block_probe.py --stop 2

`--stop` is `PROBE_STOP` in the shader, 0 in every build that ships: 1 returns after
the projection has K and V in shared memory, 2 after the attention, without the output
projection, the residual or the publish. One phase is the difference of two stops.

Two things about the numbers:

* A pipeline is built once per process (`libxmx.c`: `if (g.rblock) return 0;`), so the
  three stops are three processes. Run them in both orders and take the median of
  each; a single pair taken in one order is worth nothing on this card.
* A stop is biased low. What follows it is gone from the compiled kernel — 55772,
  31912 and 42120 bytes of SPIR-V — and with it those phases' registers, so the part
  that still runs may be scheduled better than it is in the kernel that runs it all.

Each pass is timed as `AMPLIFY` copies of itself in one submission against an empty
one, because one submission costs about 0.17 ms however little is in it.
"""
import argparse
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

AMPLIFY = 8
REPEATS = 7


def the_passes(rt):
    """Every window block one frame records, as the call the frame makes."""
    real = xmxres.Runtime.window_block
    seen = []

    def hooked(self, image, qkv, projection, target, bias, cosine, scale, height,
               width, origin, **kw):
        ph, pw, (top, left) = self.window_extent(height, width, origin, 8)
        seen.append(dict(
            height=int(height), width=int(width), origin=tuple(int(o) for o in origin),
            padded=(int(ph), int(pw)), pads=(int(top), int(left)),
            windows=int((ph // 8) * (pw // 8)),
            epilogue=int(kw.get("epilogue", 0)),
            narrow=bool(kw.get("narrow", False)),
            image_half=bool(kw.get("image_half", False)),
            pooled=kw.get("pooled") is not None,
            head=kw.get("head") is not None,
            head_columns=int(kw.get("head_columns", 4)),
            target_bytes=int(target.nbytes)))
        return real(self, image, qkv, projection, target, bias, cosine, scale,
                    height, width, origin, **kw)

    xmxres.Runtime.window_block = hooked
    # The frame's first pass plans the scratch, and planning records window blocks of its
    # own. Those are not part of a frame — they are why this counted twenty where the
    # ledger says ten — so the count starts after them.
    real_prepare = F.ResidentFrame._prepare_scratch

    def planned(self, capture):
        out = real_prepare(self, capture)
        del seen[:]
        return out

    F.ResidentFrame._prepare_scratch = planned
    try:
        model = nr_model.NeuralRenderingModel.from_safetensors(
            ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
        frame = F.ResidentFrame(rt, model.weights, 448, 768)
        frame.run(np.zeros((448, 768, 16), np.float32))
    finally:
        F.ResidentFrame._prepare_scratch = real_prepare
        xmxres.Runtime.window_block = real
    return seen


class Fixture:
    """One pass's buffers, built once and reused by every copy of it."""

    def __init__(self, rt, spec, seed):
        self.rt, self.spec = rt, spec
        height, width = spec["height"], spec["width"]
        pixels = height * width
        rng = np.random.default_rng(seed)
        # The image is the projection's input and the residual's skip. Values a network
        # carries: not so large that E4M3 saturates, not so small that the cosine floor
        # takes over and the arithmetic stops being representative.
        image = (rng.standard_normal((pixels, 32)) * 0.2).astype(np.float32)
        self.image = rt.buffer_from(image, np.float16 if spec["image_half"] else np.float32)
        self.qkv = rt.buffer_from((rng.standard_normal((32, 96)) * 0.05).astype(np.float16),
                                  np.float16)
        self.projection = rt.buffer_from((rng.standard_normal((32, 32)) * 0.05).astype(np.float16),
                                         np.float16)
        self.bias = rt.buffer_from((rng.standard_normal((64, 64)) * 0.1).astype(np.float32),
                                   np.float32)
        self.cosine = rt.buffer_from((rng.standard_normal(32) * 0.05 + 1.0).astype(np.float32),
                                     np.float32)
        self.scale = rt.buffer_from(np.array([0.125], np.float32), np.float32)
        self.target = rt.buffer(spec["target_bytes"] // 4, np.float32)
        self.extra = None
        if spec["head"]:
            self.extra = rt.buffer_from((rng.standard_normal((32, 16)) * 0.05).astype(np.float16),
                                        np.float16)
        elif spec["pooled"]:
            self.extra = rt.buffer(height * width // 4 * 32 // 2 + 64, np.float32)

    def record(self):
        s = self.spec
        keywords = dict(epilogue=s["epilogue"], narrow=s["narrow"],
                        image_half=s["image_half"])
        if s["head"]:
            keywords.update(head=self.extra, head_columns=s["head_columns"])
        elif s["pooled"]:
            keywords.update(pooled=self.extra)
        self.rt.window_block(self.image, self.qkv, self.projection, self.target,
                             self.bias, self.cosine, self.scale, s["height"], s["width"],
                             s["origin"], **keywords)

    def free(self):
        for name in ("image", "qkv", "projection", "bias", "cosine", "scale", "target",
                     "extra"):
            buffer = getattr(self, name, None)
            if buffer is not None:
                buffer.free()


def wall(rt, fixture, copies):
    """`copies` of the pass in one submission, timed from the host."""
    rt.begin()
    for _ in range(copies):
        fixture.record()
    mark = time.perf_counter()
    rt.submit()
    return time.perf_counter() - mark


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--stop", type=int, choices=(0, 1, 2), default=0)
    parser.add_argument("--fill", type=int, default=0,
                        help="rounds of independent arithmetic added to every workgroup; "
                             "build the same number into the spv with -DPROBE_FILL")
    parser.add_argument("--spread", action="store_true",
                        help="the rounds land at four points in the kernel instead of one; "
                             "build with -DPROBE_SPREAD=1 and a quarter of the rounds")
    args = parser.parse_args()
    rt = xmxres.Runtime()
    # The pipeline is built from this path the first time a window block is recorded,
    # and never rebuilt, so one process measures one stop.
    name = f"_probe_wb{args.stop}" + (
        f"s{args.fill}" if args.spread else (f"f{args.fill}" if args.fill else ""))
    xmxres.os.environ["XMX_WINDOW_BLOCK_SPV"] = str(ROOT / "work" / f"{name}.spv")
    passes = the_passes(rt)
    print(f"stop {args.stop}: {len(passes)} window blocks in one 768x448 frame",
          flush=True)

    groups = collections.Counter(
        (p["height"], p["width"], p["windows"], p["epilogue"], p["narrow"],
         p["image_half"], p["pooled"], p["head"]) for p in passes)
    print(f"  {'extent':>12s} {'windows':>8s} {'n':>3s} {'flags':>16s} {'us a pass':>10s}")
    totals = collections.defaultdict(list)
    for (height, width, windows, epilogue, narrow, half, pooled, head), n in sorted(
            groups.items(), key=lambda kv: -kv[0][2]):
        spec = next(p for p in passes
                    if (p["height"], p["width"], p["windows"], p["epilogue"], p["narrow"],
                        p["image_half"], p["pooled"], p["head"])
                    == (height, width, windows, epilogue, narrow, half, pooled, head))
        fixture = Fixture(rt, spec, height * 7919 + width * 104729 + windows)
        samples = []
        for _ in range(REPEATS):
            # Not the least of these: the difference of two timings is negative when
            # the empty submission was the slow one, and the least of seven differences
            # is then a noise floor rather than a measurement.
            samples.append((wall(rt, fixture, AMPLIFY) - wall(rt, fixture, 0))
                           / AMPLIFY * 1e6)
        each = statistics.median(samples)
        flags = " ".join(f for f in (f"e{epilogue}" if epilogue else "",
                                     "half-out" if narrow else "",
                                     "half-in" if half else "",
                                     "pool" if pooled else "",
                                     "head" if head else "") if f) or "-"
        print(f"  {height:5d}x{width:5d} {windows:8d} {n:3d} {flags:>16s} {each:10.1f}",
              flush=True)
        totals[(height, width, windows)].append(each * n)
        fixture.free()

    print(f"\n  stop {args.stop}, the frame's window blocks: "
          f"{sum(sum(v) for v in totals.values()) / 1000.0:.2f} ms")


if __name__ == "__main__":
    main()
