"""compose_encode measured on its own, against the shapes the daemon really hands it.

`notes/daemon-cpu-cost.md` calls this the largest host pass in a frame (8.98 ms of about 68)
and says "if anything is to be found on the host, it is here". Before changing a line, this
times it several ways an argument alone cannot answer:

  - how long the fused call takes at the live 1080p shapes and knobs
  - whether OpenMP is doing anything at all (--threads 1 against the default)
  - what the fast vectorised row loop is worth: the C goes per-pixel, one at a time, when a
    control mask is passed (`nr_image.c`'s `fast`)

    python work/bench_compose_encode.py
    python work/bench_compose_encode.py --threads 1
    python work/bench_compose_encode.py --kernel build /
        work/libnr_image.dll   # a rebuilt dll, without touching work/libnr_image.dll
"""
import argparse
import os
import pathlib
import statistics
import struct
import sys
import time

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
if not os.environ.get("NR_ROOT"):
    os.environ["NR_ROOT"] = str(ROOT)
for sub in ("src/ref", "src/layer", "src/gpu"):
    sys.path.insert(0, str(ROOT / sub))

parser = argparse.ArgumentParser()
parser.add_argument("--threads", default=os.environ.get("OMP_NUM_THREADS", ""))
parser.add_argument("--repeats", type=int, default=41)
parser.add_argument("--frames", default="work/capture.nrn")
parser.add_argument("--kernel", default="", help="a libnr_image.dll built somewhere else")
args, _ = parser.parse_known_args()

if args.threads:
    # before the library is loaded: libgomp reads this when it starts
    os.environ["OMP_NUM_THREADS"] = str(args.threads)

import nr_image            # noqa: E402
import nr_frame            # noqa: E402


def frame_npy(path):
    """One NRN0 capture as float32 (H, W, 3) in 0-1, the way `decode` leaves it."""
    raw = open(path, "rb").read()
    magic, width, height, vk_format = struct.unpack("<4I", raw[:16])
    body = raw[16:]
    pixels = np.frombuffer(body, np.uint8).reshape(height, width, 4).copy()
    return np.divide(pixels[..., 2::-1], np.float32(255.0), dtype=np.float32)


def median_ms(call, repeats):
    call()
    runs = []
    for _ in range(repeats):
        started = time.perf_counter()
        call()
        runs.append(time.perf_counter() - started)
    runs.sort()
    middle = runs[len(runs) // 2]
    spread = runs[int(0.75 * len(runs))] - runs[int(0.25 * len(runs))]
    return 1000 * middle, 1000 * spread


colour = np.ascontiguousarray(frame_npy(str(ROOT / args.frames)))
height, width = colour.shape[:2]
step = 8

if args.kernel:
    # load the given library and rebind the argtypes against it, so a dll built somewhere
    # else can be timed without touching the one the daemon loads
    import ctypes as C
    if os.name == "nt":
        folder = str(pathlib.Path(args.kernel).resolve().parent)
        nr_image._DLL_DIRECTORIES.append(os.add_dll_directory(folder))
    probe = C.CDLL(str(pathlib.Path(args.kernel).resolve()), winmode=0)
    # the argtypes `nr_image._library` sets on the real dll, copied onto this one
    shipped = nr_image._library()
    for name in ("nr_features", "nr_features_half", "nr_to_half", "nr_compose_temporal",
                 "nr_compose_encode", "nr_resize_axis", "nr_area_mean", "nr_compose",
                 "nr_decode8", "nr_encode8"):
        source, target = getattr(shipped, name), getattr(probe, name)
        target.argtypes, target.restype = source.argtypes, source.restype
    nr_image._library = lambda *a, **k: probe
    print(f"kernel under test: {args.kernel}")

if nr_image.library() is None:
    sys.exit("no native image library: build it first (make work/libnr_image.so)")

# the network's head at the daemon's extent and channel count, gathered the way the temporal
# composition reads it: four channels with a history, three without
rng = np.random.default_rng(20261011)
head4 = np.ascontiguousarray(
    (rng.random((height // 4, width // 4, 4), dtype=np.float32) - 0.5) * 0.25)
head3 = np.ascontiguousarray(head4[..., :3])
history = np.ascontiguousarray(clamp := np.clip(colour * 0.94 + 0.01, 0, 1))
previous = np.ascontiguousarray(np.clip(colour * 0.88 + 0.02, 0, 1))
encoded = np.zeros((height, width, 4), np.uint8)
table = np.ascontiguousarray(nr_frame.gate_table(float(nr_frame.BLEND_SCALE)))
control = np.ascontiguousarray(np.full((height, width, 1), np.float32(0.75)))

hold = float(nr_settings_hold := 1.0)
slope = float(np.float32(-255.0 * hold / nr_frame.HOLD_RAMP))
release = nr_frame.release_slope(24.0)

print(f"{width}x{height} colour, head {head4.shape[1]}x{head4.shape[0]}x{head4.shape[2]}, "
      f"OMP_NUM_THREADS={os.environ.get('OMP_NUM_THREADS', '(default)')}")
print(f"{'call':58s} {'median':>9s} {'iqr':>7s}")


def row(label, call):
    middle, spread = median_ms(call, args.repeats)
    print(f"{label:58s} {middle:9.2f} {spread:7.2f} ms", flush=True)
    return middle


def call_temporal(mask):
    def run():
        return nr_image.compose_encode(
            head4, colour, history, previous, mask, encoded, top=0, left=0, bgra=True,
            intensity=1.0, blend_scale=float(nr_frame.BLEND_SCALE), hold=hold, slope=slope,
            table=table, confidence=1.0, release=release, samples=step)
    return run


def call_still(mask):
    def run():
        return nr_image.compose_encode(
            head3, colour, None, None, mask, encoded, top=0, left=0, bgra=True,
            intensity=1.0, samples=step)
    return run


row("compose_encode temporal (history), no mask  [fast path]", call_temporal(None))
row("compose_encode temporal (history), with mask", call_temporal(control))
row("compose_encode still, no mask                [fast path]", call_still(None))

# The head arrives at the network's extent and is scaled to the colour's inside the pass, so
# the pass is doing two things at once. Hand it a head already at the colour's extent and
# there is no axis plan at all: what is left is the composition and the encoder alone.
full4 = np.ascontiguousarray(
    (rng.random((height, width, 4), dtype=np.float32) - 0.5) * 0.25)
full3 = np.ascontiguousarray(full4[..., :3])


def call_temporal_full():
    def run():
        return nr_image.compose_encode(
            full4, colour, history, previous, None, encoded, top=0, left=0, bgra=True,
            intensity=1.0, blend_scale=float(nr_frame.BLEND_SCALE), hold=hold, slope=slope,
            table=table, confidence=1.0, release=release, samples=step)
    return run


row("  same temporal, head already at 1080p (no upscale)", call_temporal_full())

# Why it costs what it costs. Two probes that need no change to the C.
#
# 1. Aliasing: hand colour in as the history and the previous frame too. The instruction
#    stream is exactly the same, but there is one 25 MB stream instead of three, so whatever
#    drops out is memory latency and traffic, not arithmetic.
# 2. Multithreaded reference: what the machine actually moves when nothing else gets in the
#    way. If this pass is far below it, there is something to have.


def call_aliased():
    def run():
        return nr_image.compose_encode(
            head4, colour, colour, colour, None, encoded, top=0, left=0, bgra=True,
            intensity=1.0, blend_scale=float(nr_frame.BLEND_SCALE), hold=hold, slope=slope,
            table=table, confidence=1.0, release=release, samples=step)
    return run


row("  same temporal, colour aliased as history and previous", call_aliased())

from concurrent.futures import ThreadPoolExecutor  # noqa: E402

both = np.ascontiguousarray(np.empty_like(colour))


def copy_slab(top_row, bottom_row):
    np.multiply(colour[top_row:bottom_row], np.float32(0.5), out=both[top_row:bottom_row])


for workers in (4, 12, 24):
    edges = [(height * i // workers, height * (i + 1) // workers) for i in range(workers)]

    def once(workers=workers, edges=edges):
        with ThreadPoolExecutor(max_workers=workers) as pool:
            list(pool.map(lambda pair: copy_slab(*pair), edges))

    row(f"  reference: same copy on {workers:2d} threads", once)

# what the memory alone costs at these shapes: touch every byte of the colour, once, in
# NumPy. If the fused pass is near it, the arithmetic is free and only the traffic is left.
read_only = np.ascontiguousarray(np.empty_like(colour))
row("reference: copy colour -> another 1080p buffer",
    lambda: np.multiply(colour, np.float32(0.5), out=read_only))
