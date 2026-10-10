#!/usr/bin/env python3
"""The part of a frame the device does not account for.

The daemon prints `gpu A+B+Cms`, and B is a wall clock around `xmx_graph_run` -- which is
`vkQueueSubmit` followed by `vkWaitForFences`, so B is everything from handing the work
over to the fence coming back. The device timestamps say how long the passes themselves
took. The two should agree, and on a 768x448 frame with the integer path on they do not:
B reads about 40 ms where the passes add to about 27.

So the gap is real money -- a third of the frame again, and nothing in the pass table
claims it. Before spending anything on it, find out what it is. The candidates are
shaped differently:

    a fixed cost of submitting and being woken, which no amount of pass tuning touches
    time on the device that no pass is credited with, such as between the last pass and
    the fence, or in work the graph does that is not a pass at all

If the gap stays put while the pass time is made to change, it is the first. If it moves
with the work, or if it is bigger when profiling is on, it is the second -- and then the
pass table has been under-reporting the device, which would change what is worth doing.

Runs the same frame repeatedly so the graph is captured once and replayed from then on,
which is what a game does after its first frame.

    python src/bench/graph_gap.py [rounds]
    NR_PROFILE_GAP=1 python src/bench/graph_gap.py    # also with device timestamps on
"""
import os
import pathlib
import statistics
import sys
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
sys.path.insert(0, str(ROOT / "src" / "layer"))


def frame():
    """The real captured frame, at the extent the game runs."""
    raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
    if raw[:4].tobytes() != b"NRN0":
        raise SystemExit(f"not an NRN capture: {raw[:4].tobytes()!r}")
    width, height = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
    body = raw[16:].reshape(height, width, 4)
    rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
    import nr_daemon
    return np.ascontiguousarray(nr_daemon.resample(rgb, (448, 768)), np.float32)


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 6
    profiling = os.environ.get("NR_PROFILE_GAP", "0") != "0"

    import xmxres
    import nr_model
    import nr_frame_resident as F

    print(f"768x448, {rounds} frames after the graph is captured, "
          f"device timestamps {'on' if profiling else 'off'}", flush=True)

    import nr_frame
    colour = frame()
    geometry = nr_frame.network_geometry(colour.shape[1], colour.shape[0])
    features = nr_frame.make_features(colour, geometry=geometry,
                                      **nr_frame.controls("standard"))
    colour = None            # the frame holds the only copy worth keeping

    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    xmxres.profile(profiling)      # before the graph is recorded, so passes are stamped
    rt = xmxres.Runtime()
    height, width = geometry.network_height, geometry.network_width
    frameobj = F.ResidentFrame(rt, model.weights, height, width)
    print(f"  network extent {width}x{height}", flush=True)

    walls, devices, passes = [], [], []
    try:
        for i in range(rounds + 1):
            if profiling:
                xmxres.profile_reset()
            out = frameobj.run(features)
            carried, ran, read = frameobj.split
            each = xmxres.profile_each() if profiling else ()
            device = sum(ms for ms in each if ms >= 0)
            if i == 0:
                # the first run records the graph; it is not the steady state a game sees
                print(f"  frame 0 (capturing): wall {1000 * ran:7.2f} ms"
                      + (f", device {device:7.2f} ms" if profiling else ""), flush=True)
                continue
            walls.append(1000 * ran)
            devices.append(device)
            passes.append(len(each) if profiling else 0)
            print(f"  frame {i}: wall {1000 * ran:7.2f} ms, carried {1000 * carried:5.2f}, "
                  f"read {1000 * read:5.2f}"
                  + (f", device {device:7.2f} ms, {len(each)} passes" if profiling else ""),
                  flush=True)
    finally:
        close = getattr(frameobj, "close", None)
        if close is not None:
            close()

    if not walls:
        return 1
    wall = statistics.median(walls)
    print(f"\n  wall clock around the graph   {wall:7.2f} ms   "
          f"(min {1000 * min(walls):.2f}, max {1000 * max(walls):.2f})")
    if profiling:
        device = statistics.median(devices)
        print(f"  device, passes only           {device:7.2f} ms")
        print(f"  unaccounted for               {wall - device:7.2f} ms   "
              f"({100 * (wall - device) / wall:.0f} % of the wall clock)")
        print(f"  pass count                    {statistics.median(passes):7.0f}")
    else:
        print("  (device times need NR_PROFILE_GAP=1; a second run gives both)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
