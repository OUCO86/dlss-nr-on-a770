#!/usr/bin/env python3
"""Route-B seam damage through the whole 71-block numpy network (real-frame input).

The ONLY question section 48 nailed as right: NOT int8-GEMM vs float-GEMM (the game
already runs int8 projections today -- nr_settings.json int8=1, ledger gemm_int8_qkv x16),
but "my requant-at-seam vs the shipped e4m3-at-seam", both on the same int8-GEMM path.

Method = the seniors' own (src/bench/int8_bottleneck.py + work/int8_quality.py): patch the
graph's GEMM/publish seams, run ONE input through the whole numpy network
(nr_model.NeuralRenderingModel.forward), and read the damage in the metric this project
judges by (|other-reference| per pixel, thresholds 1,2,4,8). One variable per mode.

Modes:
  float   : nr_model as-is (float projections, e4m3 publish)              -- reference A
  oldseam : entry int8-quantise + int8 GEMM + DIRECT e4m3 (the game today, network-wide)
  mine    : same entry/GEMM, requantize-to-int8 at each QKV/attention seam THEN publish
            (my straight-through currency + the P1 boundary publish)

The answer the user's image-quality question needs = MINE vs OLDSEAM (the seam swap's cost
on what the game ALREADY produces). INPUT = the senior's own test_forward features
(320x320, the smallest legal extent), colour channels from the real captured frame so the
distribution is a real game frame, not pure noise.

    python3 src/bench/chain_damage.py [--extent 320]
"""
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / "src" / "ref"), str(ROOT / "src" / "gpu"), str(ROOT / "src" / "layer")]
import nr_model as M            # noqa: E402
try:
    import nr_daemon            # noqa: E402  (resample, as work/int8_quality.py uses)
except Exception:
    nr_daemon = None            # fall back to a plain area-average below

LIMIT = 127
THRESHOLDS = (1, 2, 4, 8)
MODE = "float"

# ---- the int8 seam primitives (the chain's real quantise/requantise contracts) ----
def _quant_rows(a):                      # per-token-row symmetric int8 -> (int8, scales)
    a = a.astype(np.float32)
    peak = np.max(np.abs(a), axis=-1, keepdims=True)
    sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
    return np.clip(np.round(a / sc), -LIMIT, LIMIT).astype(np.int8), sc

def _quant_cols(w):                      # per-output-column int8 of (K,N) -> (int8, scales[N])
    w = w.astype(np.float32)
    peak = np.max(np.abs(w), axis=0, keepdims=True)
    sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
    return np.clip(np.round(w / sc), -LIMIT, LIMIT).astype(np.int8), sc

def _requant_last(x):                    # my straight-through currency at a seam:
    q, sc = _quant_rows(x)               # int8 requantize along the last (channel) axis
    return (q.astype(np.float32) * sc).astype(np.float32)

_ORIG_MATMUL = M.matmul
_ORIG_E4M3 = M.e4m3

_SEAM = {"matmul": 0, "e4m3": 0}      # proves the patch actually fires (a zero-diff
                                       # result must be earned, not assumed -- a patch that
                                       # silently misses would also report "0 damage")

def patched_matmul(a, b):
    # SAME int8 entry+weight GEMM for both oldseam and mine (this is what the game runs
    # TODAY: nr_settings int8=1 -> gemm_int8_qkv). The ONE variable is the seam's exit
    # round (handled in patched_e4m3), so matmul itself is mode-independent. Attention
    # GEMMs (b rank>=3, activation x activation) stay in half as the senior's
    # int8_bottleneck.py states -- only weight GEMMs (b rank-2) go integer.
    if MODE in ("oldseam", "mine") and b.ndim == 2 and a.shape[-1] >= 16:
        _SEAM["matmul"] += 1
        flat = a.reshape(-1, a.shape[-1])
        a8, asc = _quant_rows(flat)
        w8, wsc = _quant_cols(b)
        out = ((a8.astype(np.int32) @ w8.astype(np.int32)).astype(np.float32) * asc) * wsc
        return out.reshape(*a.shape[:-1], b.shape[-1])
    return _ORIG_MATMUL(a, b)

def patched_e4m3(v):
    v = np.asarray(v, np.float32)
    # The seam exit round is the single variable:
    #   oldseam : e4m3(dequantized GEMM value)                 -- ONE round (game today)
    #   mine    : e4m3( requant-to-int8(dequantized GEMM) )     -- int8 straight-through
    #             currency THEN the P1 boundary publish (TWO rounds). This is exactly the
    #             ~2% stage-level rms delta section 51 measured, propagated through the net.
    if MODE == "mine" and v.ndim >= 2 and v.shape[-1] >= 16:
        _SEAM["e4m3"] += 1
        v = _requant_last(v)
    return _ORIG_E4M3(v)

# ---- the senior's test_forward features, colour channels from a real frame ----
def features(extent):
    weights_used = None
    raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
    w, h = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
    body = raw[16:].reshape(h, w, 4)
    rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
    colour = np.ascontiguousarray(nr_daemon.resample(rgb, (extent, extent)), np.float32)
    f = np.zeros((1, extent, extent, 16), np.float32)
    rng = np.random.default_rng(1)
    yy, xx = np.mgrid[0:extent, 0:extent].astype(np.float32)
    f[0, ..., 0:3] = rng.normal(0, 1, (extent, extent, 3)).astype(np.float32)  # the senior's luma-ish
    f[0, ..., 3] = 1
    centred = (colour - 0.5) * 0.125          # the senior's colour scaling, real pixels
    f[0, ..., 4:7] = centred
    f[0, ..., 7:10] = centred
    f[0, ..., 11] = 1
    f[0, ..., 12] = 1
    f[0, ..., 13] = -1
    f[0, ..., 14] = -1
    return f

def damage(other, reference):
    dmg = np.abs(other - reference).max(axis=-1) * 255.0     # per-pixel max channel diff
    out = [f">{t}:{np.count_nonzero(dmg > t) * 100.0 / dmg.size:6.3f}%" for t in THRESHOLDS]
    return f"mean {dmg.mean():.4f} p99 {np.percentile(dmg, 99):.3f} max {dmg.max():.3f} | " + " ".join(out)

def main():
    extent = 320
    if "--extent" in sys.argv:
        extent = int(sys.argv[sys.argv.index("--extent") + 1])
    weights, _ = M.load_logical(str(ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors"))
    model = M.NeuralRenderingModel(weights)
    M.matmul = patched_matmul
    M.e4m3 = patched_e4m3
    inp = features(extent)
    outs = {}
    for mode in ("float", "oldseam", "mine"):
        globals()["MODE"] = mode
        _SEAM["matmul"] = _SEAM["e4m3"] = 0
        outs[mode] = np.asarray(model.forward(inp), np.float32)
        print(f"  {mode}: head {outs[mode].shape} finite={np.isfinite(outs[mode]).all()} "
              f"seams fired: matmul={_SEAM['matmul']} requant-e4m3={_SEAM['e4m3']}")
    assert _SEAM["matmul"] > 0 and _SEAM["e4m3"] > 0, "the seam patch never fired -- " \
        "any 0-damage result below would be meaningless; the filter (b.ndim==2, K>=16) is wrong"
    print("\n== seam damage, whole network, real-frame input (project's metric, *255) ==")
    print("  MINE vs OLDSEAM  (the route-B seam swap's cost on what the game ALREADY runs):")
    print("   ", damage(outs["mine"], outs["oldseam"]))
    print("  OLDSEAM vs FLOAT (the int8-entry tax the game pays TODAY, network-wide):")
    print("   ", damage(outs["oldseam"], outs["float"]))
    print("  MINE vs FLOAT    (full integer world vs pure-float reference):")
    print("   ", damage(outs["mine"], outs["float"]))

if __name__ == "__main__":
    main()
