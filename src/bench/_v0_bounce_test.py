#!/usr/bin/env python3
"""V0 control for the (-4) hunt: pure mid-graph submit->host-touch->begin, NO Level Zero,
NO flag changes. If THIS survives, the crash comes from the L0 dll coexisting with Vulkan
in one process (never tested before -- section 17 was L0+L0, section 18 D3D12+L0)."""
import os, pathlib, sys
import numpy as np
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / "src" / "ref"), str(ROOT / "src" / "gpu"), str(ROOT / "src" / "layer")]
os.environ["NR_FRAME_MODE"] = "block"
import xmxres, nr_frame, nr_daemon
raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
w, h = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
body = raw[16:].reshape(h, w, 4)
rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
colour = np.ascontiguousarray(nr_daemon.resample(rgb, (448, 768)), np.float32)
C = {"bounce": 0, "pass": 0}
backend = nr_frame.ResidentBackend()
rt = backend.runtime
orig = rt.gemm_qkv
def bounce(a, weight, q, k, v, scale, rows, channels, heads, tokens, *,
           window=None, image_half=False, publish_image=False, vit=False):
    if window is not None or vit or tokens != 64:
        return orig(a, weight, q, k, v, scale, rows, channels, heads, tokens,
                    window=window, image_half=image_half, publish_image=publish_image, vit=vit)
    rt.submit()
    av = xmxres.host_view(a, np.float16, shape=(rows, channels))
    av[:] = np.ascontiguousarray(np.round(av.astype(np.float32)).astype(np.float16))
    rt.begin()
    C["bounce"] += 1
    return orig(a, weight, q, k, v, scale, rows, channels, heads, tokens,
                window=window, image_half=image_half, publish_image=publish_image, vit=vit)
rt.fuse_partition = False   # force the non-window door: bounce must ACTUALLY fire
rt.gemm_qkv = bounce
try:
    head, _ = nr_frame.run_head(backend, colour)
    out = np.asarray(nr_frame.compose(head, colour), np.float32)
    print(f"V1 RESULT: survived, bounces={C['bounce']}, head finite={np.isfinite(out).all()}")
finally:
    backend.close()
