#!/usr/bin/env python3
"""V2: run the SENIOR's own activation-bounce hook (int8_bottleneck global_block_int8,
mid-graph submit->round->begin at blocks 31-38) on today's tree. If it survives, the
(-4) is specific to bouncing at the WINDOW QKV door (arena roles), not to mid-graph
submits in general. One variable from V1: the location."""
import os, pathlib, sys
import numpy as np
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / "src" / "bench"), str(ROOT / "src" / "ref"),
                str(ROOT / "src" / "gpu"), str(ROOT / "src" / "layer")]
os.environ["NR_FRAME_MODE"] = "block"
import nr_daemon
raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
w, h = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
body = raw[16:].reshape(h, w, 4)
rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
colour = np.ascontiguousarray(nr_daemon.resample(rgb, (448, 768)), np.float32)
import int8_bottleneck
out, counts = int8_bottleneck.render(colour, False, True)
print(f"V2 RESULT: senior hook survived, operands quantised={int8_bottleneck.OPERANDS[0]}, "
      f"head finite={np.isfinite(out).all()}")
