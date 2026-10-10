#!/usr/bin/env python3
"""Where a frame's bytes go, split into weights and activations, split by level.

The A770 measurement that matters (notes, 2026-10-09): one 1080p frame moves about
12.3 GB through 516 GEMMs and the network stage sits at 74 % of DRAM peak. On that
machine time is bytes, so the question "does int8 pay" is the question "what share of
the bytes are GEMM operands, and how many of those are weights".

This walks one real frame with every data-moving runtime method hooked and accounts
each call. Buffers carry their dtype only as a size, so the width of a buffer is
recovered the way src/bench/dtype_traffic.py recovers it: 4 bytes if it is big enough
to hold float32 at this element count, else 2.

Weights are counted twice, because the two counts answer different questions: once per
dispatch (`weights_fresh`) and once per pass (`weights_once`, which is what a weight
matrix that stays in L2 across a batched GEMM's windows actually costs in DRAM).
"""
import collections
import os
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
sys.path.insert(0, str(ROOT / "src" / "ref"))
import xmxres
import nr_model
import nr_frame_resident as F

CALLS = []
LABEL = {}
MISSED = collections.Counter()


def width(buf, count):
    return 4 if buf.nbytes >= count * 4 else 2


def account(kind, reads, writes, rows=0, cols=0, inner=0, batch=1, stamps=(0, 0)):
    """reads/writes are lists of (buffer, element count).

    `stamps` is the half-open range of device timestamps this call produced. One runtime
    method is not always one device pass: `ffn_fused` records several, and pairing a pass
    with its Python call by index puts every pass after the first such call one place
    along from its own shape. Ranges rather than indices are what make the attribution
    line up.
    """
    rb = sum(c * width(b, c) for b, c in reads if c > 0)
    wb = sum(c * width(b, c) for b, c in writes if c > 0)
    CALLS.append(dict(kind=kind, read=rb, write=wb, rows=rows, cols=cols,
                      inner=inner, batch=batch, stamps=stamps))
    return rb, wb


def wrap(name):
    """Hook one runtime method by name; the shapes come from its own signature."""
    real = getattr(xmxres.Runtime, name)

    def hooked(self, *args, **kw):
        sig = HOOKS[name]
        try:
            bound = sig(self, args, kw)
        except Exception:
            # A hook that cannot read a call's shapes must say so, not silently
            # account nothing: UNREAD is the size of the hole in this audit.
            MISSED[name] += 1
            bound = None
        if bound is not None:
            account(name, *bound)
        return real(self, *args, **kw)

    hooked.__name__ = name
    setattr(xmxres.Runtime, name, hooked)


def s_gemm(self, args, kw):
    a, b, c, rows, cols, inner = args[:6]
    batch = kw.get("batch", 1)
    compact = kw.get("compact_output", False)
    outw = 4 if not kw.get("narrow", False) else 2
    reads = [(a, rows * inner * batch), (b, inner * cols)]
    writes = [(c, rows * (4 if compact else cols) * batch)]
    # the weight matrix is read once per pass and once per batch item, counted apart
    CALLS.append(dict(kind="gemm", read=reads[0][1] * width(a, reads[0][1]),
                      write=writes[0][1] * outw, rows=rows, cols=cols, inner=inner,
                      batch=batch, weight_once=inner * cols * width(b, inner * cols),
                      weight_fresh=inner * cols * width(b, inner * cols) * batch))
    return None


def s_gemm_residual(self, args, kw):
    a, b, skip, cosine, target, rows, cols, inner = args[:8]
    return ([(a, rows * inner), (b, inner * cols), (skip, rows * cols), (cosine, cols)],
            [(target, rows * cols)], rows, cols, inner, 1)


def s_gemm_residual_pool(self, args, kw):
    a, b, skip, cosine, skip_out, pooled, rows, inner = args[:8]
    reverse = args[8] if len(args) > 8 else None
    return ([(a, rows * inner), (b, inner * 32), (skip, rows * 32), (cosine, 32)],
            [(skip_out, rows * 32), (pooled, rows * 32 // 4)], rows, 32, inner, 1)


def s_gemm_qkv(self, args, kw):
    a, weight, q, k, v, scale, rows, channels, heads, tokens = args[:10]
    return ([(a, rows * channels), (weight, channels * 3 * heads * 32), (scale, 1)],
            [(q, rows * heads * 32), (k, rows * heads * 32), (v, rows * heads * 32)],
            rows, 3 * heads * 32, channels, 1)


def s_gemm_int8(self, args, kw):
    a, b, c, a_scale, b_scale, rows, cols, inner = args[:8]
    return ([(a, rows * inner), (b, cols * inner), (a_scale, rows), (b_scale, cols)],
            [(c, rows * cols)], rows, cols, inner, 1)


def s_gemm_int8_qkv(self, args, kw):
    """The integer QKV projection: one pass, three outputs.

    It was not in HOOKS at all, so while `NR_INT8_QKV` is on — which it is by default —
    every one of these passes reached the device without anyone counting it. The frame
    looked 9 ms cheaper than it was and the projection that pays for the whole integer
    path was absent from the table.
    """
    a, b, q, k, v, a_scale, b_scale, qkv_scale, rows, channels, heads, tokens = args[:12]
    return ([(a, rows * channels), (b, 3 * channels * channels),
             (a_scale, rows), (b_scale, 3 * channels), (qkv_scale, heads)],
            [(q, rows * channels), (k, rows * channels), (v, rows * channels)],
            rows, channels, channels, 1)


def s_pool2_skip(self, args, kw):
    """`pool2` and the half skip in one read of the float32 source."""
    source, pooled, skip, height, width, channels = args[:6]
    return ([(source, height * width * channels)],
            [(pooled, (height // 2) * (width // 2) * channels),
             (skip, height * width * channels)],
            height * width, channels, 0, 1)


def s_upsample_add(self, args, kw):
    """`upsample2`, the skip's per-channel scale and the add, in one pass."""
    source, skip, factors, target, height, width, source_width, channels = args[:8]
    count = height * width * channels
    published = kw.get("published")
    writes = [(target, count)]
    if published is not None:
        writes.append((published, count))
    return ([(source, count), (skip, count), (factors, channels)],
            writes, height * width, channels, 0, 1)


def s_sample_history(self, args, kw):
    """The history resampled onto this frame by the recovered filter: one pass a frame,
    and the largest unattributed one there was."""
    history, motion, target, height, width = args[:5]
    channels = kw.get("channels", 3)
    count = height * width * channels
    return ([(history, count), (motion, count)],
            [(target, count)], height * width, channels, 0, 1)


def s_prepare_qkv(self, args, kw):
    source, q, k, v, scale, windows, tokens, heads = args[:8]
    rows = windows * tokens * heads
    return ([(source, rows * 3 * 32), (scale, heads)],
            [(q, rows * 32), (k, rows * 32), (v, rows * 32)],
            rows, 32, 0, 1)


def s_vit_softmax(self, args, kw):
    source, target, reciprocal, rows, tokens = args[:5]
    width = kw.get("stride", 0) or tokens
    return ([(source, rows * width)],
            [(target, rows * width), (reciprocal, rows)], rows, width, 0, 1)


def s_copy(self, args, kw):
    source, target, nbytes = args[:3]
    return ([(source, nbytes)], [(target, nbytes)], 0, 0, 0, 1)


def s_quantize_row(self, args, kw):
    source, packed, scale, rows, inner = args[:5]
    return ([(source, rows * inner)],
            [(packed, rows * inner), (scale, rows)], rows, inner, 0, 1)


def s_quantize_window(self, args, kw):
    """The gathered quantiser reads the image, whose rows are wider than a token's:
    a whole padded row of pixels, not `rows` tokens of `inner` channels. The read is
    charged once per token either way, which is what the pass touches."""
    source, packed, scale, rows, inner = args[:5]
    return ([(source, rows * inner)],
            [(packed, rows * inner), (scale, rows)], rows, inner, 0, 1)


def s_gemm_dual(self, args, kw):
    a, b, c, half_copy, rows, cols, inner = args[:7]
    return ([(a, rows * inner), (b, inner * cols)],
            [(c, rows * cols), (half_copy, rows * cols)], rows, cols, inner, 1)


def s_ffn_fused(self, args, kw):
    a, expand, projection, target, rows, channels, hidden = args[:7]
    groups = kw.get("groups", 1)
    skip, cosine = kw.get("skip"), kw.get("cosine")
    reads = [(a, rows * channels), (expand, groups * channels * hidden),
             (projection, groups * hidden * 32)]
    if cosine is not None:
        reads += [(cosine, channels), (skip, rows * channels)]
    return (reads, [(target, rows * groups * 32)], rows, groups * 32, hidden, 1)


def s_ffn_fused_merge(self, args, kw):
    source, skip, sincos, expand, projection, target, cosine = args[:7]
    rows, channels, hidden = args[7], args[8], args[9]
    return ([(source, rows * channels), (skip, rows * channels), (sincos, rows * 32),
             (expand, channels * hidden), (projection, hidden * 32), (cosine, channels)],
            [(target, rows * 32)], rows, 32, hidden, 1)


def s_ffn_fused_stem(self, args, kw):
    features, adapter, expand, projection, target, cosine, rows = args[:7]
    return ([(features, rows * 16), (adapter, 16 * 32), (expand, 32 * 128),
             (projection, 128 * 32), (cosine, 32)],
            [(target, rows * 32)], rows, 32, 128, 1)


def s_window_block(self, args, kw):
    image, qkv, projection, target, bias, cosine, scale, height, width_ = args[:8]
    origin = args[8] if len(args) > 8 else kw.get("origin", (0, 0))
    ph, pw, _ = xmxres.Runtime.window_extent(height, width_, origin, 8)
    rows = ph * pw
    return ([(image, rows * 32), (qkv, 32 * 3 * 32), (projection, 32 * 32),
             (bias, 8 * 8), (cosine, 32), (scale, 32)],
            [(target, rows * 32)], rows, 32, 32, 1)


def s_window_attention(self, args, kw):
    q, k, v, target, batches, heads = args[:6]
    return ([(q, batches * 64 * heads * 32), (k, batches * 64 * heads * 32),
             (v, batches * 64 * heads * 32)],
            [(target, batches * 64 * heads * 32)], batches * 64, heads * 32, 32, 1)


def s_global_attention(self, args, kw):
    q, k, v, merged, rows, tokens, heads = args[:7]
    return ([(q, rows * heads * 32), (k, tokens * heads * 32), (v, tokens * heads * 32)],
            [(merged, rows * heads * 32)], rows, heads * 32, 32, 1)


def s_upsample_merge(self, args, kw):
    source, skip, sincos, merged, merged16, height, width_ = args[:7]
    rows = height * width_
    return ([(source, rows * 32), (skip, rows * 32), (sincos, rows * 32)],
            [(merged, rows * 32), (merged16, rows * 32)], rows, 32, 32, 1)


def s_unary(self, args, kw):
    kind, source, target, count = args[:4]
    second = kw.get("second")
    third = kw.get("third")
    reads = [(source, count)]
    if second is not None:
        reads.append((second, count))
    if third is not None:
        reads.append((third, count))
    return (reads, [(target, count)], 0, 0, 0, 1)


def s_partition_reverse(self, args, kw):
    source, target, height, width_, channels = args[:5]
    return ([(source, height * width_ * channels)], [(target, height * width_ * channels)],
            height * width_, channels, 0, 1)


def s_heads(self, args, kw):
    source, target, windows, tokens, channels, heads = args[:6]
    return ([(source, windows * tokens * channels)], [(target, windows * tokens * channels)],
            windows * tokens, channels, 0, 1)


def s_cosine(self, args, kw):
    source, target, rows = args[:3]
    return ([(source, rows * 32)], [(target, rows * 32)], rows, 32, 0, 1)


def s_softmax(self, args, kw):
    source, target, rows, width_ = args[:4]
    return ([(source, rows * width_)], [(target, rows * width_)], rows, width_, 0, 1)


HOOKS = {
    "gemm": s_gemm,
    "gemm_residual": s_gemm_residual,
    "gemm_residual_pool": s_gemm_residual_pool,
    "gemm_qkv": s_gemm_qkv,
    "gemm_int8": s_gemm_int8,
    "gemm_int8_qkv": s_gemm_int8_qkv,
    "quantize_row": s_quantize_row,
    "quantize_window": s_quantize_window,
    "gemm_dual": s_gemm_dual,
    "ffn_fused": s_ffn_fused,
    "ffn_fused_merge": s_ffn_fused_merge,
    "ffn_fused_stem": s_ffn_fused_stem,
    "window_block": s_window_block,
    "window_attention": s_window_attention,
    "global_attention": s_global_attention,
    "upsample_merge": s_upsample_merge,
    "unary": s_unary,
    "partition": s_partition_reverse,
    "reverse": s_partition_reverse,
    "split_heads": s_heads,
    "merge_heads": s_heads,
    "cosine_publish": s_cosine,
    "softmax": s_softmax,
    "pool2_skip": s_pool2_skip,
    "upsample_add": s_upsample_add,
    "copy": s_copy,
    "sample_history": s_sample_history,
    "prepare_qkv": s_prepare_qkv,
    "vit_softmax": s_vit_softmax,
}
MISSING = [name for name in HOOKS if not hasattr(xmxres.Runtime, name)]


def main():
    height = int(os.environ.get("AUDIT_H", "1080"))
    width_ = int(os.environ.get("AUDIT_W", "1920"))
    for name in HOOKS:
        if hasattr(xmxres.Runtime, name):
            wrap(name)
    model = nr_model.NeuralRenderingModel.from_safetensors(
        ROOT / "work" / "mlxw" / "dlssnr-logical.safetensors")
    rt = xmxres.Runtime()

    # The frame records itself twice: once dry, to size the scratch, and once for real.
    # Only the second one is a frame's traffic.
    real_prepare = F.ResidentFrame._prepare_scratch

    def counted(self, capture):
        out = real_prepare(self, capture)
        CALLS.clear()
        MISSED.clear()
        return out

    F.ResidentFrame._prepare_scratch = counted
    frame = F.ResidentFrame(rt, model.weights, height, width_)
    frame.run(np.zeros((height, width_, 16), np.float32))

    total_read = sum(c["read"] for c in CALLS)
    total_write = sum(c["write"] for c in CALLS)
    fresh = sum(c.get("weight_fresh", 0) for c in CALLS)
    once = sum(c.get("weight_once", 0) for c in CALLS)
    by_kind = collections.Counter()
    for c in CALLS:
        by_kind[c["kind"]] += c["read"] + c["write"]

    print(f"\n{height}x{width_}: {len(CALLS)} passes accounted, "
          f"{len(MISSING)} hooks absent {MISSING}")
    if MISSED:
        print(f"  UNREAD: {sum(MISSED.values())} calls whose shapes this could not read "
              f"{dict(MISSED)} — they are in the pass count and not in the bytes")
    print(f"  read   {total_read / 1e9:8.2f} GB")
    print(f"  write  {total_write / 1e9:8.2f} GB")
    print(f"  total  {(total_read + total_write) / 1e9:8.2f} GB")
    print(f"  of which GEMM weight operands, counted once per pass: {once / 1e9:.2f} GB"
          f"  ({100 * once / (total_read + total_write):.0f} %)")
    print(f"  the same, counted fresh for every batch item:          {fresh / 1e9:.2f} GB"
          f"  ({100 * fresh / (total_read + total_write):.0f} %)")

    print("\n  by pass kind (GB, read + write):")
    for kind, total in by_kind.most_common():
        print(f"    {kind:22s} {total / 1e9:8.2f}  {100 * total / (total_read + total_write):5.1f} %")

    print("\n  the GEMM-shaped passes, by rows (tokens) descending:")
    gemms = [c for c in CALLS if c.get("inner")]
    gemms.sort(key=lambda c: -c["rows"])
    rows_bytes = collections.Counter()
    rows_count = collections.Counter()
    for c in gemms:
        rows_bytes[c["rows"]] += c["read"] + c["write"]
        rows_count[c["rows"]] += 1
    running = 0
    gtotal = sum(c["read"] + c["write"] for c in gemms)
    for rows, total in rows_bytes.most_common(14):
        running += total
        print(f"    rows={rows:<8d} n={rows_count[rows]:<5d} {total / 1e9:8.2f} GB"
              f"  {100 * total / gtotal:5.1f} % of the GEMM-shapes")

    print("\n  the ten heaviest single passes:")
    for c in sorted(CALLS, key=lambda c: -(c["read"] + c["write"]))[:10]:
        print(f"    {c['kind']:22s} rows={c['rows']:<7d} cols={c['cols']:<6d}"
              f" inner={c['inner']:<6d} batch={c['batch']:<5d}"
              f" {(c['read'] + c['write']) / 1e6:9.1f} MB")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
