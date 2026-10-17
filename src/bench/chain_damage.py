#!/usr/bin/env python3
"""Route-B QKV-seam damage on a REAL FRAME, network-wide -- at the game's TRUE int8 scope.

Section 55 voided the first version (it injected int8 into every weight GEMM of the
graph -- a world that does not exist). The shipping game's integer scope, from the
source: nr_resident.py:410 gates `int8_qkv` on `channels % 64 == 0`, and the ledger
counts 16 gemm_int8_qkv passes = the C=256 window blocks (15-21, 49-55); plus the eight
global blocks' (31-38) FFN pair on gemm_int8 (the int8_bottleneck-proven region).
Everything else stays float (NR_INT8_FFN_GROUPS=0, measured slower -- the ledger).

Modes, one variable each:
  float : pure reference (the shipped numpy graph);
  game  : the 32 in-scope GEMMs int8-quantised, direct e4m3 publish = what the user
          sees TODAY;
  mine  : same 32 GEMMs; additionally the 16 QKV exits carry the straight-through int8
          currency (requant), i.e. exactly the P1 seam form my chain puts between the
          QKV GEMM and the attention consumer (softmax_i8/attnV requantize IN their own
          epilogues, section 53; the boundary publish is the round-trip this measures).

The answer = MINE vs GAME. Input = the senior's own test_forward feature construction
(16 channels, 320x320 the smallest legal extent), colour channels from the REAL captured
frame (work/capture.nrn) resampled. Metric = the seniors' own (work/int8_quality.py):
per-pixel max-channel |diff| * 255 at thresholds 1/2/4/8.

    python3 src/bench/chain_damage.py [--extent 320]
"""
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / "src" / "ref"), str(ROOT / "src" / "gpu"), str(ROOT / "src" / "layer")]
import nr_model as M            # noqa: E402

LIMIT = 127
THRESHOLDS = (1, 2, 4, 8)
MODE = "float"                  # float | game | mine
_ROLE = {}                      # id(weight array) -> "qkv" | "ffn"
_SEAM = {"gemm": 0, "requant": 0}

def _quant_rows(a):             # per-token-row grid (quantize_row's shipped form)
    a = a.astype(np.float32)
    peak = np.max(np.abs(a), axis=-1, keepdims=True)
    sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
    return np.clip(np.round(a / sc), -LIMIT, LIMIT).astype(np.int8), sc

def _quant_cols(w):             # per-output-column weight grid
    w = w.astype(np.float32)
    peak = np.max(np.abs(w), axis=0, keepdims=True)
    sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
    return np.clip(np.round(w / sc), -LIMIT, LIMIT).astype(np.int8), sc

_ORIG_MATMUL = M.matmul
_ORIG_E4M3 = M.e4m3
_SEAM = {}

def _reset():
    global _SEAM
    _SEAM = {"qkv": 0, "ffn": 0, "proj": 0, "requant": 0}

def _requant_head_rows(x3, heads):
    """Faithful to section 39's currency: Q/K exit the normalisation holding ONE HEAD's
    32 channels in registers, so the requantize grid is per (token,head) row of 32 --
    not the whole 3C projection. x3 = (rows, 3C) -> three thirds (Q,K,V)."""
    rows, C3 = x3.shape
    C = C3 // 3
    q, k, v = x3[:, :C], x3[:, C:2 * C], x3[:, 2 * C:]
    out = []
    for part, is_v in ((q, False), (k, False), (v, True)):
        if is_v:      # section 41: V carries per-COLUMN (channel) scales over tokens
            peak = np.max(np.abs(part), axis=0, keepdims=True)
            sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
            part = (np.clip(np.round(part / sc), -LIMIT, LIMIT) * sc).astype(np.float32)
        else:         # per (row,head) grid of 32, the normalised-head form
            view = part.reshape(rows * heads, 32)
            peak = np.max(np.abs(view), axis=1, keepdims=True)
            sc = np.where(peak == 0, 1.0, peak / LIMIT).astype(np.float32)
            view = (np.clip(np.round(view / sc), -LIMIT, LIMIT) * sc).astype(np.float32)
            part = view.reshape(rows, -1)
        out.append(part)
    _SEAM["requant"] += 1
    return np.concatenate(out, axis=1)

def patched_matmul(a, b):
    role = _ROLE.get(id(b))
    if MODE in ("game", "mine") and role is not None:
        _SEAM[role] += 1
        flat = a.reshape(-1, a.shape[-1])
        a8, asc = _quant_rows(flat)
        w8, wsc = _quant_cols(b)
        out = ((a8.astype(np.int32) @ w8.astype(np.int32)).astype(np.float32) * asc) * wsc
        out = out.reshape(*a.shape[:-1], b.shape[-1])
        if MODE == "mine" and role == "qkv":
            heads = b.shape[-1] // 3 // 32
            out = _requant_head_rows(out.reshape(-1, b.shape[-1]), heads) \
                .reshape(*a.shape[:-1], b.shape[-1])
        return out
    return _ORIG_MATMUL(a, b)

# ---- the true-scope tagger: the SHIPPED guard, not a guessed block list ----
# nr_resident.py:410 gates int8 QKV on `channels % 64 == 0` (qkv_weight shape is
# (channels, 3*channels); test_nr_model.py:97 shows block5.layer0.qkv_weight == (64,192)).
# int8_bottleneck.py: the four weight GEMMs of the eight global blocks 31-38 are the
# expand (layer0.weight), feed-forward projection (layer1.weight), QKV (layer2.qkv_weight)
# and output projection (layer4.projection_weight). Applying the shipped channels guard to
# every qkv + the globals' pair, exactly as the running graph does, reproduces the ledger's
# 16 gemm_int8_qkv without me guessing which blocks they are.
GLOBAL_BLOCKS = tuple(range(31, 39))
GLOBAL_SUFFIX = {".layer0.weight": "ffn", ".layer1.weight": "ffn",
                 ".layer2.qkv_weight": "qkv", ".layer4.projection_weight": "proj"}

def tag_scope(model):
    orig_w = model.weight
    matched = {}
    def w(name):
        arr = orig_w(name)
        block = name.split(".")[0]
        idx = int(block[5:]) if block.startswith("block") else -1
        role = None
        if name.endswith(".qkv_weight"):
            # the shipped channels % 64 == 0 guard (channels = shape[0])
            if arr.shape[0] % 64 == 0:
                role = "qkv"
        elif idx in GLOBAL_BLOCKS:
            for suf, r in GLOBAL_SUFFIX.items():
                if name.endswith(suf):
                    role = r
                    break
        if role is not None:
            _ROLE[id(arr)] = role
            matched[name] = role
        return arr
    model.weight = w
    model._matched = matched

# ---- input: the senior's test_forward construction, colour from the real frame ----
def features(extent):
    raw = np.fromfile(ROOT / "work" / "capture.nrn", dtype=np.uint8)
    w, h = int(raw[4:8].view("<i4")[0]), int(raw[8:12].view("<i4")[0])
    body = raw[16:].reshape(h, w, 4)
    rgb = np.ascontiguousarray(body[:, :, [2, 1, 0]]).astype(np.float32) / 255.0
    import nr_daemon
    colour = np.ascontiguousarray(nr_daemon.resample(rgb, (extent, extent)), np.float32)
    f = np.zeros((1, extent, extent, 16), np.float32)
    rng = np.random.default_rng(1)
    f[0, ..., 0:3] = rng.normal(0, 1, (extent, extent, 3)).astype(np.float32)
    f[0, ..., 3] = 1
    centred = (colour - 0.5) * 0.125
    f[0, ..., 4:7] = centred
    f[0, ..., 7:10] = centred
    f[0, ..., 11] = 1
    f[0, ..., 12] = 1
    f[0, ..., 13] = -1
    f[0, ..., 14] = -1
    return f

def damage(other, reference):
    dmg = np.abs(other - reference).max(axis=-1) * 255.0
    out = [f">{t}:{np.count_nonzero(dmg > t) * 100.0 / dmg.size:6.3f}%" for t in THRESHOLDS]
    return f"mean {dmg.mean():.4f} p99 {np.percentile(dmg, 99):.3f} max {dmg.max():.3f} | " + " ".join(out)

def main():
    extent = 320
    if "--extent" in sys.argv:
        extent = int(sys.argv[sys.argv.index("--extent") + 1])
    weights, _ = M.load_logical(str(ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors"))
    model = M.NeuralRenderingModel(weights)
    tag_scope(model)
    M.matmul = patched_matmul
    inp = features(extent)
    outs = {}
    for mode in ("float", "game", "mine"):
        globals()["MODE"] = mode
        _reset()
        outs[mode] = np.asarray(model.forward(inp), np.float32)
        print(f"  {mode}: head {outs[mode].shape} finite={np.isfinite(outs[mode]).all()} "
              f"in-scope int8 GEMMs qkv={_SEAM['qkv']} ffn={_SEAM['ffn']} proj={_SEAM['proj']} "
              f"requants={_SEAM['requant']}")
        total_g = _SEAM["qkv"] + _SEAM["ffn"] + _SEAM["proj"]
        if mode in ("game", "mine"):
            assert total_g >= 16, f"scope not applied: {total_g} GEMMs"
        if mode == "mine":
            assert _SEAM["requant"] == _SEAM["qkv"] > 0, "mine must requant every qkv exit"
    print("\n== damage at the game's TRUE int8 scope (real frame, project metric x255) ==")
    print("  MINE vs GAME  (route-B seam swap on top of what the game runs today)  <-- THE answer:")
    print("   ", damage(outs["mine"], outs["game"]))
    print("  GAME vs FLOAT (the int8 tax the game ALREADY pays, context for scale):")
    print("   ", damage(outs["game"], outs["float"]))

if __name__ == "__main__":
    main()
