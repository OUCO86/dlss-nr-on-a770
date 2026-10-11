#!/usr/bin/env python3
"""What a byte is worth in the request's own passes.

The three passes the host no longer runs — PRE_INNER, PRE_FEATURES, POST_COMPOSE —
compute in float32 and move float32. This measures the cost of the bytes they move
by removing whole operands, so "would half precision help" gets an answer in
milliseconds instead of an argument: each variant below differs from the one above
it by a known number of megabytes, and the slope is what fp16 would buy.

    python src/bench/prec_traffic.py [repeats]

Every number is a device-side submit-and-wait unless the label says host.
"""
import os
import pathlib
import statistics
import sys
import time

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
for part in ("src", "src/gpu", "src/ref"):
    sys.path.insert(0, str(ROOT / part))

_probe = ROOT / "work" / "_pre_resident.spv"
if _probe.exists():
    os.environ.setdefault("XMX_UNARY_SPV", str(_probe))

import nr_frame                                     # noqa: E402
import nr_image                                     # noqa: E402
import xmxres                                       # noqa: E402

WIDTH, HEIGHT = 1920, 1080
HEAD_WIDTH, HEAD_HEIGHT = 768, 448
LOCAL = 256
STEP = 8
PIXELS = WIDTH * HEIGHT
MB = 1024.0 * 1024.0


def axis_plan(source_extent, count):
    packed = []
    for array in nr_image._axis_plan(source_extent, count):
        flat = np.ascontiguousarray(np.asarray(array).reshape(-1))
        if flat.dtype != np.float32:
            flat = np.ascontiguousarray(flat.astype(np.int32)).view(np.float32)
        packed.append(flat.astype(np.float32))
    return np.ascontiguousarray(np.concatenate(packed))


def median(fn, repeats):
    samples = []
    for _ in range(repeats):
        samples.append(fn())
    return statistics.median(samples), min(samples)


def main():
    repeats = int(sys.argv[1]) if len(sys.argv) > 1 else 15
    rng = np.random.default_rng(20261011)
    rt = xmxres.Runtime()

    inner_w, inner_h = (int(v) for v in
                        nr_frame.render_extent(WIDTH, HEIGHT, 0.4, 512))
    inner_pixels = inner_w * inner_h

    # ---- PRE_INNER -----------------------------------------------------
    plan = np.ascontiguousarray(np.concatenate(
        [axis_plan(HEIGHT, inner_h), axis_plan(WIDTH, inner_w),
         (np.arange(256, dtype=np.float32) / np.float32(255.0))]))
    scale_at = plan.size - 256
    raw = rt.buffer(PIXELS, np.uint32, xmxres.HOST_WRITE)
    plan_buf = rt.buffer(plan.size, np.float32, xmxres.HOST_WRITE)
    inner = [rt.buffer(inner_pixels * 3, np.float32, xmxres.GRAPH) for _ in range(2)]
    partial = rt.buffer(-(-inner_pixels // LOCAL), np.float32, xmxres.HOST_READ)
    xmxres.host_write(plan_buf, plan)
    xmxres.host_write(raw, rng.integers(0, 1 << 32, size=PIXELS, dtype=np.uint32))

    def pre_inner_pass(previous=None):
        rt.begin()
        rt.pre_inner(raw, plan_buf, inner[0], width=inner_w, height=inner_h,
                     source_width=WIDTH, source_height=HEIGHT, partial=partial,
                     scale_at=scale_at, previous=inner[1] if previous else None)
        t = time.perf_counter()
        rt.submit()
        return (time.perf_counter() - t) * 1e3

    # ---- PRE_FEATURES --------------------------------------------------
    feat_plan = np.ascontiguousarray(np.concatenate(
        [axis_plan(inner_h, inner_h), axis_plan(inner_w, inner_w),
         rng.random(inner_pixels * 3).astype(np.float32),
         rng.random(5).astype(np.float32)]))
    columns_at = inner_h
    noise_at = columns_at + inner_w
    controls_at = noise_at + inner_pixels * 3
    feat_plan_buf = rt.buffer(feat_plan.size, np.float32, xmxres.HOST_WRITE)
    features = rt.buffer(inner_pixels * 16, np.float16, xmxres.GRAPH)
    xmxres.host_write(feat_plan_buf, feat_plan)

    def pre_features_pass():
        rt.begin()
        rt.pre_features(inner[0], feat_plan_buf, features, width=inner_w,
                        height=inner_h, inner_width=inner_w, columns_at=columns_at,
                        noise_at=noise_at, controls_at=controls_at, history=None)
        t = time.perf_counter()
        rt.submit()
        return (time.perf_counter() - t) * 1e3

    # ---- POST_COMPOSE --------------------------------------------------
    channels = 4
    gate = nr_frame.gate_table(float(nr_frame.BLEND_SCALE))
    par = np.ascontiguousarray(np.concatenate(
        [axis_plan(HEAD_HEIGHT, HEIGHT), axis_plan(HEAD_WIDTH, WIDTH),
         (np.arange(256, dtype=np.float32) / np.float32(255.0)), gate,
         np.zeros(32, np.float32)]))
    x_at = 3 * HEIGHT
    decode_at = x_at + 3 * WIDTH
    gate_at = decode_at + 256
    scalar_at = gate_at + 65536
    composed = PIXELS * 3
    neural = composed
    groups = -(-PIXELS // LOCAL)
    partial_at = composed + neural
    samples_at = partial_at + groups
    encoded_at = samples_at + (-(-WIDTH // STEP) * -(-HEIGHT // STEP)) * channels
    size = encoded_at + PIXELS
    par[scalar_at] = 1.0            # intensity
    par[scalar_at + 1] = 1.0        # scale
    par[scalar_at + 5] = 1.0        # confidence
    par[scalar_at + 8] = WIDTH
    par[scalar_at + 9] = 4          # change_rows
    par[scalar_at + 10] = STEP
    par[scalar_at + 11] = samples_at
    par[scalar_at + 12] = encoded_at
    par[scalar_at + 13] = partial_at
    par[scalar_at + 14] = neural

    head = rt.buffer(HEAD_HEIGHT * HEAD_WIDTH * channels, np.float32, xmxres.GRAPH)
    par_buf = rt.buffer(par.size, np.float32, xmxres.GRAPH)
    history = rt.buffer(2 * PIXELS * 3, np.float32, xmxres.HOST_WRITE)
    answer = rt.buffer(size, np.float32, xmxres.HOST_READ)
    xmxres.host_write(par_buf, par)
    xmxres.host_write(head, rng.random(HEAD_HEIGHT * HEAD_WIDTH * channels)
                      .astype(np.float32))

    answer_vram = rt.buffer(size, np.float32, xmxres.GRAPH)

    def compose(with_history, with_previous, neural_on=False, target=None):
        rt.begin()
        rt.post_compose(raw, head, par_buf, history, answer if target is None else target,
                        width=WIDTH,
                        height=HEIGHT, source_width=WIDTH, head_width=HEAD_WIDTH,
                        head_height=HEAD_HEIGHT, channels=channels,
                        with_history=with_history, with_previous=with_previous,
                        neural=neural_on)
        t = time.perf_counter()
        rt.submit()
        return (time.perf_counter() - t) * 1e3

    block32 = rng.random(2 * PIXELS * 3).astype(np.float32)
    block16 = rng.random(PIXELS * 3).astype(np.float16)

    print(f"{WIDTH}x{HEIGHT} frame, inner {inner_w}x{inner_h}, "
          f"head {HEAD_WIDTH}x{HEAD_HEIGHT}x{channels}, {repeats} reps")
    print()

    rows = []

    def row(label, fn, mb=None):
        med, low = median(fn, repeats)
        rows.append((label, med, low, mb))
        return med

    def note(label, med, low, mb):
        extra = f"   {mb / med / 1e3:7.1f} GB/s" if mb else ""
        print(f"  {label:<42} {med:7.2f} ms  (min {low:6.2f}){extra}")

    print("device, POST_COMPOSE — answer in system memory (HOST_READ, as it is today):")
    a = row("no history, no previous", lambda: compose(False, False), None)
    b = row("+ history  (reads 24.9 MB)", lambda: compose(True, False), 24.9)
    c = row("+ previous (reads 49.8 MB)", lambda: compose(True, True), 49.8)
    d = row("+ neural   (writes 24.9 MB more)", lambda: compose(True, True, True), None)
    for label, med, low, mb in rows:
        note(label, med, low, mb)
    per_mb_read = (c - b) / 24.9
    per_mb_write = (d - c) / 24.9
    print()
    print(f"  slope: {(c - b):.2f} ms for 24.9 MB read  -> {per_mb_read:.4f} ms/MB"
          f"  ({1 / per_mb_read / 1e3:.0f} GB/s)")
    print(f"  slope: {(d - c):.2f} ms for 24.9 MB written across PCIe -> "
          f"{per_mb_write:.4f} ms/MB  ({1 / per_mb_write / 1e3:.1f} GB/s)")
    print()

    rows.clear()
    print("device, POST_COMPOSE — the same pass writing into card memory instead:")
    v0 = row("full operands, answer in VRAM", lambda: compose(True, True, False,
                                                              target=answer_vram), None)
    v1 = row("+ neural, answer in VRAM", lambda: compose(True, True, True,
                                                         target=answer_vram), None)
    for label, med, low, mb in rows:
        note(label, med, low, mb)
    print(f"  the same 24.9 MB written inside VRAM: {(v1 - v0):.2f} ms "
          f"({(v1 - v0) and 24.9 / (v1 - v0) / 1e3:.0f} GB/s)")
    print(f"  what crossing PCIe costs for the whole answer: "
          f"{(c - v0):.2f} ms of the {c:.2f}")
    print()

    rows.clear()
    print("device, the two request passes:")
    e = row("PRE_INNER, no previous", lambda: pre_inner_pass(False), None)
    f = row("PRE_INNER, with previous (reads 4.13 MB)",
            lambda: pre_inner_pass(True), 4.13)
    g = row("PRE_FEATURES", pre_features_pass, None)
    for label, med, low, mb in rows:
        note(label, med, low, mb)
    print()

    print("host, pushing the temporal operands at the device (HOST_WRITE):")
    h32, _ = median(lambda: timed(lambda: xmxres.host_write(history, block32)), 7)
    print(f"  {'history+previous as float32 (49.8 MB)':<42} {h32:7.2f} ms"
          f"   {49.8 / h32 / 1e3:7.1f} GB/s")
    half = rng.random(PIXELS * 3 // 2).astype(np.float32)      # 12.45 MB: half the bytes
    h16, _ = median(lambda: timed(lambda: xmxres.host_write(history, half)), 7)
    print(f"  {'history+previous as float16 (24.9 MB)':<42} {h16:7.2f} ms"
          f"   {24.9 / h16 / 1e3:7.1f} GB/s")
    print()
    print("traffic the passes move, float32 as they stand:")
    print(f"  POST_COMPOSE  read {8.29 + 5.5 + 49.8:6.1f} MB   "
          f"write {24.9 + 8.29:6.1f} MB   total {8.29 + 5.5 + 49.8 + 24.9 + 8.29:6.1f} MB")
    print(f"  POST_COMPOSE  with the operands in half: "
          f"total {8.29 + 5.5 + 24.9 + 12.5 + 8.29:6.1f} MB")
    print(f"  PRE_INNER     read {8.29 + 4.13:6.1f} MB   write {4.13:6.1f} MB   "
          f"total {8.29 + 4.13 + 4.13:6.1f} MB")
    print(f"  PRE_FEATURES  read {4.13 + 4.13:6.1f} MB   write {11.0:6.1f} MB   "
          f"total {4.13 + 4.13 + 11.0:6.1f} MB")
    return 0


def timed(fn):
    t = time.perf_counter()
    fn()
    return (time.perf_counter() - t) * 1e3


if __name__ == "__main__":
    sys.exit(main())
