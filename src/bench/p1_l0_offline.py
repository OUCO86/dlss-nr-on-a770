#!/usr/bin/env python3
"""P1 offline paired render: the game's REAL resident GPU pipeline, run TWICE on one
real captured frame -- (A) shipped QKV door, (B) my L0 int8 chain swapped in at the same
door via the scaffold's host-bounce -- and diff the final composed image.

This is the number that actually answers the user's image-quality question: both sides
are the shipping pipeline (real GPU coopmat kernels everywhere else, real weights, real
frame); the ONLY difference is which engine computes the 80 window QKV projections. Unlike
the section 57 whole-network numpy proxy it has no synthetic float reference to amplify
against and no e4m3 butterfly floor to hide behind: the baseline (A) IS the pixels the
game shows, so |B - A| means exactly what it says.

The bounce must be host-bounce (submit -> round the buffer -> begin) like the senior's
src/bench/int8_bottleneck.py int8_rows, NOT inside the live game pipe (the extmem frame
semaphore makes a mid-graph rt.submit illegal there: "resident fence wait (-4)", the
trap today's first attempt hit). ResidentBackend.run_head is the offline graph driver
work/int8_quality.py already uses for exactly this damage measurement.

    python3 src/bench/p1_l0_offline.py            # -> work/p1_l0_offline.npz + the table
"""
import ctypes, os, pathlib, sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / "src" / "ref"), str(ROOT / "src" / "gpu"),
                str(ROOT / "src" / "layer"), str(ROOT / "src" / "bench")]
os.environ["NR_FRAME_MODE"] = "block"     # live record per block; the bounce never runs under replay

import nr_model as M      # noqa: E402
import nr_frame           # noqa: E402
import nr_daemon          # noqa: E402  (resample)
from read_capture import read  # noqa: E402


def frame_colour():
    raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
    w, h = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
    body = raw[16:].reshape(h, w, 4)
    rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
    # the game's network extent at render_scale 0.4 (work/int8_quality.py uses 448x768)
    return np.ascontiguousarray(nr_daemon.resample(rgb, (448, 768)), np.float32)


def render(l0):
    import l0_qkv_scaffold
    backend = nr_frame.ResidentBackend()
    try:
        if l0:
            l0_qkv_scaffold.install_l0_qkv(backend.runtime)
        head, _ = nr_frame.run_head(backend, frame_colour())
        out = np.asarray(nr_frame.compose(head, frame_colour()), np.float32)
        if l0:
            l0_qkv_scaffold.report()
            sw = l0_qkv_scaffold._C["swapped"]
            fb = l0_qkv_scaffold._C["fellback"]
            assert sw > 0, f"bounce never fired (fellback={fb}) -- diff would be meaningless"
            print(f"  L0 render: swapped={sw} fellback={fb}")
        return out
    finally:
        backend.close()


def damage(other, reference):
    d = np.abs(other - reference).max(axis=-1) * 255.0
    return (f"mean {d.mean():.4f} p99 {np.percentile(d, 99):.3f} max {d.max():.2f} | "
            + " ".join(f">{t}:{np.count_nonzero(d > t) * 100.0 / d.size:6.3f}%" for t in (1, 2, 4, 8)))


def main():
    print("  pass A: shipped QKV door (game as it runs today)")
    a = render(l0=False)
    print("  pass B: my L0 int8 chain swapped at the same QKV door")
    b = render(l0=True)
    np.savez(ROOT / "work" / "p1_l0_offline.npz", shipped=a, l0=b)
    print("\n== real resident GPU pipeline, one real frame (768x448), only the QKV engine "
          "differs (project metric, x255) ==")
    print("  L0-chain vs SHIPPED :", damage(b, a))
    print(f"  (saved work/p1_l0_offline.npz for crops/inspection)")


if __name__ == "__main__":
    main()
