#!/usr/bin/env python3
"""
nr_resident — whole blocks of the graph recorded as one device submit.

`xmxres` gives the primitives; this assembles them into the shapes the recovered
graph actually has. One block is a single command buffer: its feed-forward, its
window attention and both residuals, with nothing crossing back to the host in
between.

The E4M3 publishes are what make the layout work. Because the publish is
elementwise, a branched feed-forward can write each of its heads straight into a
slice of one wide buffer and publish the whole thing in a single dense pass — no
concatenation, no strided elementwise kernel.
"""
from __future__ import annotations

import os
import pathlib
import sys

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "ref"))

import int8_quant  # noqa: E402
import nr_model  # noqa: E402
import xmxres  # noqa: E402


def quantise_weight(runtime, array):
    """A weight matrix on the integer path, or None if the shape will not go.

    `array` is (K, N), the layout the recovered weights are in. The kernel wants B as
    (N, K), because it loads a B fragment by column (`gemm_staged_int8.comp`), and it
    scales after the accumulator, so a scale per output channel costs nothing
    (`src/gpu/int8_quant.py`). Quantised once, here, because weights do not change
    between frames.
    """
    inner, cols = array.shape
    if cols % 32 or inner % 64:
        return None
    packed, scale = int8_quant.quantise(array, 0)
    return (runtime.buffer_from(np.ascontiguousarray(packed.T), np.int8),
            runtime.buffer_from(scale, np.float32))


def quantise_grouped_weight(runtime, array):
    """A per-group weight tensor on the integer path, or None if the shape will not pay.

    `array` is (groups, inner, cols) — `group_expand_weight`, `group_project_weight` and
    the branched blocks' fused expansion alike. Each group is quantised on its own: the
    scale is one per output column, and a single grid over all of them would let a group
    with large weights flatten its neighbours'.

    The kernel reads group `g`'s matrix at `g * cols * inner` and its scales at
    `g * cols`, which is the order these are concatenated in.

    Only the tile gate is applied here: whether a shape is worth putting on the integer
    path at all depends on the row count, which is a property of the extent and is
    known only where the product is recorded, so `grouped_integer_pays` decides there.
    """
    groups, inner, cols = array.shape
    if cols % 32 or inner % 64:
        return None
    packed = np.empty((groups, cols, inner), np.int8)
    scale = np.empty((groups, cols), np.float32)
    for group in range(groups):
        p, s = int8_quant.quantise(array[group], 0)
        packed[group] = p.T
        scale[group] = s
    return (runtime.buffer_from(np.ascontiguousarray(packed.reshape(-1, inner)), np.int8),
            runtime.buffer_from(np.ascontiguousarray(scale.reshape(-1)), np.float32))


def grouped_integer_pays(rows, cols, inner):
    """Whether a grouped product's shape is faster on the integer path. Measured, not argued.

    `work/probe-ffn-int8-batched.txt` times all seven shapes the frame groups, four
    routes each, alternating in one process. Two of the seven lose, and both lose by
    less than ten microseconds a call, against wins of twelve to eighty-two elsewhere:

        1344 x  32 x 128    +6.3 us      384 x 256 x  64    +9.6 us
        1344 x 128 x 256   -34.1 us      384 x  64 x 256   -12.2 us
        5376 x  32 x 128    -4.6 us    21504 x  32 x 128   -28.7 us
                                       21504 x 128 x  64   -82.2 us

    The two that lose are the shallow ones at a small row count: at 1344 rows a group
    has 1344 x 32 outputs to show for its quantise, and the integer GEMM's halved
    multiply-add cannot give back what that costs. At 21504 rows the same 32 columns
    win by 28.7, so it is not the narrow N on its own — it is narrow N over too few
    rows. Below 64 columns the product has to be over 5376 rows to pay; at 256 columns
    and 64 deep it does not pay at any row count the frame runs.
    """
    if cols % 32 or inner % 64:
        return False
    if (cols, inner) == (256, 64):
        return False
    # 诊断逃生门（2026-10-14 黑屏定位）：NR_INT8_FFN_BATCH=0 只关 grouped 的
    # batched 分支，int8_first（gemm_int8 单发）不受影响。默认开，不改行为。
    if os.environ.get("NR_INT8_FFN_BATCH", "1") == "0":
        return False
    return cols >= 64 or rows >= 5376


def integer_pair(w, s):
    """A block's quantised down projection with this scratch's row grid, or None.

    The four things `record_project_residual`'s integer branch wants. `None` is a block
    that has no integer copy — one the switch is off for, or one whose weight failed the
    tile gate — and sends the call down the float path unchanged.
    """
    pair = getattr(w, "int8_ffn", None)
    return None if pair is None else (pair[0], pair[1], s.aq, s.ascale)


class SplitBlockWeights:
    """A split-family block (23-30, 40-47): four layers, sixteen heads, C=512."""

    def __init__(self, runtime, weights, index):
        self.index, self.heads = index, 16
        self.origin = nr_model.recovered_window_origin(index)
        self.projection = weights[f"block{index}.layer3.projection_weight"]
        self.channels = self.projection.shape[0]
        self.groups = self.channels // 64
        bias = weights[f"block{index}.layer2.attn_bias"]
        if nr_model.uses_fragment_swizzle(index, 16):
            bias = nr_model.recover_attention_bias_layout(bias)
        self.first = runtime.buffer_from(weights[f"block{index}.layer0.first_projection_weight"],
                                         np.float16)
        self.expand = runtime.buffer_from(weights[f"block{index}.layer0.group_expand_weight"],
                                          np.float16)
        self.project = runtime.buffer_from(weights[f"block{index}.layer0.group_project_weight"],
                                           np.float16)
        self.weight3 = runtime.buffer_from(weights[f"block{index}.layer1.weight3"], np.float16)
        self.ffn_cos = runtime.buffer_from(weights[f"block{index}.layer1.ffn_cos_skip"])
        self.qkv = runtime.buffer_from(weights[f"block{index}.layer2.qkv_weight"], np.float16)
        self.scale = runtime.buffer_from(weights[f"block{index}.layer2.attn_scale"])
        self.bias = runtime.buffer_from(bias)
        self.out = runtime.buffer_from(self.projection, np.float16)
        self.attn_cos = runtime.buffer_from(weights[f"block{index}.layer3.attn_cos_skip"])
        self.branched = False
        self.split = True
        # the split family's down projection is `weight3`; its out projection is the
        # window attention's, as any window block's is (`work/int8_levels.py`: the levels
        # these live on tolerate a per-row int8 grid as well as the bottleneck does)
        self.int8_ffn = self.int8_out = None
        if runtime.int8_project:
            if os.environ.get("NR_INT8_WINDOW", "1") != "0":
                self.int8_ffn = quantise_weight(runtime,
                                                weights[f"block{index}.layer1.weight3"])
            if os.environ.get("NR_INT8_WINDOW_OUT", "1") != "0":
                self.int8_out = quantise_weight(runtime, self.projection)
        # the projection the integer path could not take at all until its epilogue could
        # be carried: Q, K and V, whose Q and K are normalised after the scales land
        self.int8_qkv = (quantise_weight(runtime, weights[f"block{index}.layer2.qkv_weight"])
                         if runtime.int8_qkv else None)
        # The split family's first projection is not grouped — it is one 512x512 product
        # a block — but it is the single largest win left in the frame's float16 products:
        # 16 of them, 63.6 us each cheaper on the integer path
        # (`work/probe-ffn-int8-batched.txt`). It needs no batch to take it.
        self.int8_first = (quantise_weight(
            runtime, weights[f"block{index}.layer0.first_projection_weight"])
            if (runtime.int8_ffn_groups
                and os.environ.get("NR_INT8_FFN_FIRST", "1") != "0") else None)
        # the split family's per-group expansion and projection, on the integer grid
        self.int8_expand = self.int8_project = None
        if runtime.int8_ffn_groups:
            self.int8_expand = quantise_grouped_weight(
                runtime, weights[f"block{index}.layer0.group_expand_weight"])
            self.int8_project = quantise_grouped_weight(
                runtime, weights[f"block{index}.layer0.group_project_weight"])


class BlockWeights:
    """One block's weights, uploaded once and kept on the device."""

    def __init__(self, runtime, weights, index, *, heads):
        prefix = f"block{index}.layer0"
        self.split = False
        self.index, self.heads = index, heads
        self.origin = nr_model.recovered_window_origin(index)
        self.projection = weights[f"{prefix}.projection_weight"]
        self.channels = self.projection.shape[0]

        bias = weights[f"{prefix}.attn_bias"]
        if nr_model.uses_fragment_swizzle(index, heads):
            bias = nr_model.recover_attention_bias_layout(bias)

        take = lambda name, dtype=np.float16: runtime.buffer_from(
            weights[f"{prefix}.{name}"], dtype)
        self.qkv = take("qkv_weight")
        self.out = take("projection_weight")
        self.bias = runtime.buffer_from(bias, np.float32)
        self.scale = runtime.buffer_from(weights[f"{prefix}.attn_scale"], np.float32)
        self.attn_cos = runtime.buffer_from(weights[f"{prefix}.attn_cos_skip"])
        self.ffn_cos = runtime.buffer_from(weights[f"{prefix}.ffn_cos_skip"])

        self.branched = f"{prefix}.ffn_expand_weight" in weights
        if self.branched:
            expansion, branch = nr_model._fused_branched_weights(
                weights[f"{prefix}.ffn_expand_weight"],
                weights[f"{prefix}.ffn_branch_projection_weight"])
            self.groups = expansion.shape[0]
            self.expand = runtime.buffer_from(expansion, np.float16)
            self.branch = runtime.buffer_from(branch, np.float16)
            self.ffn_out = take("ffn_output_projection_weight")
        else:
            self.groups = 0
            self.expand = take("weight1")
            self.branch = take("weight2")
            self.ffn_out = None

        # The integer path's copies, made once. Two projections can take it: the
        # feed-forward's down — `ffn_out` where the block is branched, `weight2` where it
        # is not — and the attention's out. Neither the expansion, whose epilogue is the
        # quadratic gate and the integer kernel has none, nor the QKV projection, which
        # has no integer kernel at all. `quantise_weight` returns None for a shape the
        # (N % 32, K % 64) tile will not carry, which is every 32-channel block's out
        # projection and nothing else in this graph (`work/int8_gate.py`).
        # Both follow `NR_INT8_PROJECT` now, and `NR_INT8_WINDOW=0` or
        # `NR_INT8_WINDOW_OUT=0` takes one of them back. They were off while the out
        # projection's residual was being given the window row count instead of the
        # image's, which cost the device; `record_project_residual` derives the count
        # from `reverse` and it no longer does. What they are worth together, and what
        # they cost, is measured in `work/int8_frame_cost.py` and `work/int8_quality.py`:
        # 2.6 ms of a 46 ms frame, and the frame's own error against the float path
        # from 10.1 % of the network's effect to 14.5 %.
        self.int8_ffn = self.int8_out = None
        if runtime.int8_project:
            if os.environ.get("NR_INT8_WINDOW", "1") != "0":
                self.int8_ffn = quantise_weight(
                    runtime, weights[f"{prefix}.ffn_output_projection_weight"
                                     if self.branched else f"{prefix}.weight2"])
            if os.environ.get("NR_INT8_WINDOW_OUT", "1") != "0":
                self.int8_out = quantise_weight(runtime, self.projection)
        self.int8_qkv = (quantise_weight(runtime, weights[f"{prefix}.qkv_weight"])
                         if runtime.int8_qkv else None)
        # the branched blocks' per-group expansion and contraction, the same way. Only
        # the branched blocks have groups, so an ordinary block leaves these None and
        # its feed-forward is the single product it always was.
        self.int8_expand = self.int8_branch = None
        if runtime.int8_ffn_groups and self.branched:
            self.int8_expand = quantise_grouped_weight(runtime, expansion)
            self.int8_branch = quantise_grouped_weight(runtime, branch)


class GlobalBlockWeights:
    """A bottleneck block (31-38): every token attends to every other, 32 heads, C=1024."""

    def __init__(self, runtime, weights, index):
        self.index, self.heads, self.split, self.branched = index, 32, False, False
        self.projection = weights[f"block{index}.layer4.projection_weight"]
        self.channels = self.projection.shape[0]
        self.expand = runtime.buffer_from(weights[f"block{index}.layer0.weight"], np.float16)
        self.ffn_proj = runtime.buffer_from(weights[f"block{index}.layer1.weight"], np.float16)
        self.hidden_width = weights[f"block{index}.layer0.weight"].shape[1]
        self.ffn_cos = runtime.buffer_from(weights[f"block{index}.layer1.ffn_cos_skip"])
        self.qkv = runtime.buffer_from(weights[f"block{index}.layer2.qkv_weight"], np.float16)
        # the learned scale alone: the ViT's query takes half(sqrt(32)) as a multiply of its
        # own before it (VIT_ROOT in cosine_tree.glsl)
        self.scale = runtime.buffer_from(weights[f"block{index}.layer2.attn_scale"])
        self.out = runtime.buffer_from(self.projection, np.float16)
        self.attn_cos = runtime.buffer_from(weights[f"block{index}.layer4.attn_cos_skip"])
        # The three projections the integer path can take: the feed-forward's expansion and
        # down, and the attention's out. The expansion used to be excluded because its
        # epilogue is the quadratic gate and the integer kernel had none, so it would have
        # paid a whole pass to publish; gemm_staged_int8 now applies the publish in its
        # write-back, so it takes the gate like any other.
        #
        # Measured on the frame the network actually runs (`work/int8_quality.py`,
        # the capture at 768x448): 43.70 ms -> 43.12 ms on `work/int8_frame_cost.py
        # 768 448`, three alternating runs, every "on" run under every "off" one; and
        # the picture 0.7512 -> 0.7423 of 255 against the float path, 14.52 % ->
        # 14.35 % of the network's own effect. It is faster and slightly cleaner, and
        # `NR_INT8_EXPAND=0` takes it back.
        self.int8_ffn = self.int8_out = self.int8_expand = None
        if runtime.int8_project:
            self.int8_ffn = quantise_weight(runtime, weights[f"block{index}.layer1.weight"])
            if os.environ.get("NR_INT8_OUT", "1") != "0":
                self.int8_out = quantise_weight(runtime, self.projection)
            if os.environ.get("NR_INT8_EXPAND", "1") != "0":
                self.int8_expand = quantise_weight(
                    runtime, weights[f"block{index}.layer0.weight"])
        self.int8_qkv = (quantise_weight(runtime, weights[f"block{index}.layer2.qkv_weight"])
                         if runtime.int8_qkv else None)


class GlobalScratch:
    """Working buffers for one bottleneck block over `tokens` tokens."""

    def __init__(self, runtime, weights, tokens, arena=None):
        channels, heads = weights.channels, weights.heads
        # the token count is the bottleneck's pixel count and need not be tile-aligned.
        # Whole 64-row blocks put its deep-K GEMMs (K up to 4096) on the staged kernel,
        # which is faster there: 240 -> 256 tokens at 720p took the frame from 240.6 to
        # 235.4 ms on the GPU, three alternating runs each. Pad rows are zero, are excluded
        # from the softmax, and leave every real row bit-identical. The eighth is a guard,
        # not a measurement: at 384x384 (64 tokens) and 1024x576 (192) the question does
        # not arise, and a large pad would pay for rows nobody needs. Below 64 tokens —
        # the small network frames `min_extent` allows — the pad is taken outright: those
        # GEMMs wait on their K loop, not on rows, so 64 cost what 16 do, and a whole block
        # lets the QKV projection's epilogue leave the tiled kernel (0.22 -> 0.14 ms a call,
        # about 0.6 ms of a 192x128 frame). At 32 tokens or fewer — 16 at 256x128; 320x320
        # has 64 — a 32-row build of the staged kernel does better still: half of each K
        # step's work on the 64-row block was the pad (libxmx.c, `small`).
        padded = xmxres.align(tokens, 16)
        if tokens <= 32:
            padded = 32
        elif tokens <= 64 or xmxres.align(tokens, 64) * 8 <= padded * 9:
            padded = xmxres.align(tokens, 64)
        self.tokens, self.padded = tokens, padded
        padded, hidden = self.padded, weights.hidden_width
        make = (arena.buffer if arena is not None else
                lambda name, count, dtype=np.float32: runtime.buffer(count, dtype))
        self.value = make("global.value", padded * channels).zero()
        # The chain's value as half, between the blocks and through them (`chain` in
        # record_global_block). Its pad rows are zero from here on and never written.
        self.io16 = make("global.io16", padded * channels, np.float16).zero()
        self.value16 = make("value16", padded * channels, np.float16)
        self.hidden16 = make("hidden16", padded * hidden, np.float16)
        self.branch = make("branch", padded * channels)
        self.ffn = make("ffn", padded * channels)
        self.ffn16 = make("ffn16", padded * channels, np.float16)
        self.proj = make("proj", padded * channels * 3)
        self.q16, self.k16, self.v16 = (make(name, padded * channels, np.float16) for name in ("q16", "k16", "v16"))
        self.key16 = make("key16", padded * channels, np.float16)   # see record_qkv_projection
        self.scores = make("scores", heads * padded * padded)
        self.probs16 = make("probs16", heads * padded * padded, np.float16)
        self.context = make("context", heads * padded * 32)
        self.reciprocal = make("reciprocal", heads * padded)   # the ViT softmax's, a row each
        self.merged16 = make("merged16", padded * channels, np.float16)
        # the fused attention's output: merged16 shares q16's role, which it still reads
        self.context16 = make("context16", padded * channels, np.float16)
        self.attention = make("attention", padded * channels)
        self.out = make("global.out", padded * channels)
        # The integer path's operands: the activations on a grid a row, one pass per
        # GEMM, and the row's scale beside it. Sized for the deepest K any of them has.
        self.aq = make("global.aq", padded * max(hidden, channels), np.int8)
        self.ascale = make("global.ascale", padded)

    def free(self):
        for name in dir(self):
            value = getattr(self, name)
            if isinstance(value, xmxres.Buffer):
                value.free()


def record_qkv(runtime, w, s, windows, tokens, channels, heads, *, vit=False):
    """Split V; optionally normalize Q/K directly from the projection buffer. `vit`: the
    ViT's normalisation and query scale."""
    if runtime.fuse_qk and runtime.joint_qkv:
        runtime.prepare_qkv(s.proj, s.q16, s.k16, s.v16, w.scale, windows, tokens, heads,
                            vit=vit)
        return
    if runtime.fuse_qk:
        with runtime.independent():
            runtime.cosine_publish(s.proj, s.q16, windows * heads * tokens,
                                   tokens=tokens, heads=heads, scale=w.scale,
                                   narrow=True, qkv_part=0, vit=vit)
            runtime.cosine_publish(s.proj, s.k16, windows * heads * tokens,
                                   tokens=tokens, heads=heads, narrow=True, qkv_part=1,
                                   vit=vit)
            runtime.split_heads(s.proj, s.v16, windows, tokens, channels, heads, 2,
                                epilogue=xmxres.EPI_E4M3, narrow=True)
        return
    with runtime.independent():
        for index, part in enumerate((s.q16, s.k16)):
            runtime.split_heads(s.proj, part, windows, tokens, channels, heads, index,
                                epilogue=xmxres.EPI_HALF, narrow=True)
        runtime.split_heads(s.proj, s.v16, windows, tokens, channels, heads, 2,
                            epilogue=xmxres.EPI_E4M3, narrow=True)
    with runtime.independent():
        runtime.cosine_publish(s.q16, s.q16, windows * heads * tokens,
                               tokens=tokens, heads=heads, scale=w.scale,
                               narrow=True, from_half=True, vit=vit)
        runtime.cosine_publish(s.k16, s.k16, windows * heads * tokens,
                               tokens=tokens, heads=heads, narrow=True, from_half=True,
                               vit=vit)


def record_qkv_projection(runtime, a, w, s, windows, tokens, channels, heads, *,
                          window=None, image_half=False, publish_image=False, vit=False):
    """The QKV projection and everything that prepares Q, K and V after it.

    Returns the buffer K ended up in. With `qkv_epilogue` it is one GEMM whose epilogue
    normalises Q and K and publishes V (`qkv_epilogue.glsl`), and K goes to `s.key16`
    rather than `s.k16`: k16 shares the arena role of the projection's input, which other
    workgroups are still reading while this one's epilogue writes. Otherwise the
    projection goes to memory in float32 and `record_qkv` reads it back, as it always did.

    With `window=(height, width, origin)` `a` is the image, not its partition: the epilogue
    GEMM gathers the window rows itself. Without the epilogue that gather has nowhere to
    live, so the partition is recorded here as it always was. `publish_image` says the
    projection reads the image published — a 32-channel block's raw feed-forward output.
    `vit`: the ViT's normalisation and query scale, wherever Q and K are made.

    On the integer path (`runtime.int8_qkv`, `NR_INT8_QKV`) the same epilogue runs on
    `gemm_staged_int8`, which has no window gather, so a window block used to partition
    first — as it did before the gather was folded into the float GEMM — and then quantise
    the partition a row at a time. It does not any more: the gather moved into the quantiser
    (`Runtime.quantize_window`, bit 0x400000), which reads the token out of the image where
    it lies instead of out of a copy written in window order. Same values, same grid, one
    pass where there were two — and the one that went was 3.08 ms of the 31.57 ms the device
    spends on a 768x448 frame. `NR_INT8_WINDOW_FUSE=0` pays it again.
    """
    rows = windows * tokens
    qkv8 = getattr(w, "int8_qkv", None)
    if runtime.int8_qkv and qkv8 is not None and channels % 64 == 0:
        weight8, column_scale = qkv8
        if window is not None:
            height, width, origin = window
            if runtime.int8_window_fuse and image_half and not publish_image:
                # the partition's own index, in the pass that used to follow it
                _, padded_width, _ = runtime.window_extent(height, width, origin)
                runtime.quantize_window(a, s.aq, s.ascale, rows, channels,
                                        height=height, width=width,
                                        across=padded_width // 8,
                                        pad=((-origin[0]) << 16) | (-origin[1]))
            else:
                runtime.partition(a, s.win16, height, width, channels, origin=origin,
                                  narrow=True, a_half=image_half,
                                  epilogue=xmxres.EPI_E4M3 if publish_image else 0)
                a = s.win16
                runtime.quantize_row(a, s.aq, s.ascale, rows, channels)
        else:
            runtime.quantize_row(a, s.aq, s.ascale, rows, channels)
        runtime.gemm_int8_qkv(s.aq, weight8, s.q16, s.key16, s.v16, s.ascale, column_scale,
                              w.scale, rows, channels, heads, tokens, vit=vit)
        return s.key16
    if window is not None:
        if runtime.qkv_epilogue and rows % 64 == 0:
            runtime.gemm_qkv(a, w.qkv, s.q16, s.key16, s.v16, w.scale, rows, channels, heads,
                             tokens, window=window, image_half=image_half,
                             publish_image=publish_image)
            return s.key16
        height, width, origin = window
        runtime.partition(a, s.win16, height, width, channels, origin=origin, narrow=True,
                          a_half=image_half,
                          epilogue=xmxres.EPI_E4M3 if publish_image else 0)
        a = s.win16
    elif publish_image:
        raise ValueError("only a window-gathered projection publishes its image")
    if runtime.qkv_epilogue and rows % 16 == 0:
        runtime.gemm_qkv(a, w.qkv, s.q16, s.key16, s.v16, w.scale, rows, channels, heads,
                         tokens, vit=vit)
        return s.key16
    runtime.gemm(a, w.qkv, s.proj, rows, 3 * channels, channels)
    record_qkv(runtime, w, s, windows, tokens, channels, heads, vit=vit)
    return s.k16


def record_project_residual(runtime, a, weight, branch, skip, cosine, target,
                            rows, channels, inner, *, epilogue=0, skip_half=False,
                            narrow=False, integer=None, reverse=None):
    """A projection and its residual: `target = a @ weight + skip * cosine`.

    Fused, the residual is the GEMM's own epilogue and the float32 branch never goes
    to memory (ProjectsCodex's phase38, `notes/improve-fusions.md`). Unfused it is the
    two passes this graph always had, kept for paired comparison and as the reference
    the fused path is bit-identical to. `NR_FUSE_RESIDUAL=0` selects them.

    `integer` is `(weight8, column_scale, packed, row_scale)` — the weight quantised
    per output channel and the activation's row grid — and takes the third path, which
    is the same two passes as the float one now that `gemm_staged_int8.comp` has a
    residual epilogue of its own: the quantise, then a product that adds `skip *
    cosine` and publishes. Before it had one, the integer path was three passes and
    carried a residual no other path paid for — 120 of them a frame, 2.38 ms
    (`notes/frame-ledger-a770.md`).

    What it buys is the instruction, not the bytes:
    configuration 4 covers twice the K of the float one per multiply-add, and these
    are the passes that wait on their K loop (`notes/improve-int8-a770.md`).

    That is also why it is not offered everywhere, and where the line falls has moved
    once. The row grid is a pass over M x K that reads two bytes a value and writes one,
    and while that pass cost ten times the GEMM it feeds it cost more than the GEMM
    saved on any shape where the GEMM was waiting on memory rather than on its K loop:
    on the frame's own shapes (`work/int8_ab.py`) `21504 x 32 x 128` paid 4.1x and
    `384 x 64 x 256` paid 0.72x, and the line was drawn at M at or under 1536 with K at
    or above 256.

    Then `quantize_row` was rewritten — a warp per row, whole words per thread, the row
    maximum four shuffles instead of a shared-memory tree behind eight barriers — and
    the pass went from 189 us to about 9 us on `21504 x 128 x 64`, twenty-one times
    quicker for the same bytes (`notes/improve-int8-a770.md`). Measured again on every
    shape the frame asks for (`work/int8_cover.py`) the integer path now wins on
    twenty-four of thirty-six, including every one of the large-M shapes the old line
    excluded, and loses on one: `384 x 256 x 64`, by 12 %. The line is that shape.

    `reverse=(height, width, window, origin)` is the window blocks' out projection: its
    skip is the image in image order and the residual gathers its window rows out of it,
    which is the residual's own gather and costs nothing extra on either path.
    """
    if integer is not None and rows <= 512 and inner <= 64:
        integer = None
    # The residual's own length. Without `reverse` it is the projection's rows; with it
    # the residual writes the image and reads the branch through the window reverse, and
    # its linear index is an image index — `rest / width` in resident.comp — so the count
    # is the image's, which the padded window count is not: a shifted origin has more
    # window rows than there are pixels, and passing those cost the device.
    count = (rows if reverse is None else reverse[0] * reverse[1]) * channels
    if integer is not None:
        weight8, column_scale, packed, row_scale = integer
        runtime.quantize_row(a, packed, row_scale, rows, inner)
        if runtime.int8_residual:
            runtime.gemm_int8_residual(packed, weight8, target, row_scale, column_scale,
                                       skip, cosine, rows, channels, inner,
                                       epilogue=epilogue, narrow=narrow,
                                       skip_half=skip_half, reverse=reverse)
            return
        runtime.gemm_int8(packed, weight8, branch, row_scale, column_scale,
                          rows, channels, inner)
        runtime.residual(branch, skip, cosine, target, count, channels,
                         epilogue=epilogue, b_half=skip_half, narrow=narrow,
                         reverse=reverse)
        return
    if runtime.fuse_residual:
        runtime.gemm_residual(a, weight, skip, cosine, target, rows, channels, inner,
                              epilogue=epilogue, skip_half=skip_half, narrow=narrow,
                              reverse=reverse)
    else:
        runtime.gemm(a, weight, branch, rows, channels, inner)
        runtime.residual(branch, skip, cosine, target, count, channels,
                         epilogue=epilogue, b_half=skip_half, narrow=narrow,
                         reverse=reverse)


def record_global_block(runtime, w, s, source=None, target=None, *, chain=False):
    """A bottleneck block: the wide feed-forward, then attention over every token.

    With `chain` the block reads and writes `s.io16`, the value as half. Between the
    blocks it is published E4M3, so the half is exact, and the float32 copy each block
    went through — widened on the way in, narrowed again for the feed-forward, published
    and narrowed on the way out, four passes — is not needed: the feed-forward reads the
    half, its residual widens it, and the output projection publishes into it. Only the
    real rows are stored, so the pad rows stay the zeros the float32 input's were.

    The block is the vendor's (notes/opendlss-reference.md): the feed-forward's output
    published, as the QKV projection's input and the attention's skip, and the ViT's own
    attention — its normalisation, its exponential, the weights unnormalised and the
    reciprocal on the value sum.
    """
    channels, heads, padded = w.channels, w.heads, s.padded
    if chain:
        source = value16 = s.io16
    else:
        source = source or s.value
        value16 = s.value16
        runtime.to_half(source, value16, padded * channels)
    target = s.io16 if chain else (target or s.out)
    # The expansion on the integer path: the same row grid the down projection uses,
    # quantised once here, and the gate applied in the kernel's write-back. The shapes
    # line up with the scratch's deepest K, which this GEMM is: K = channels.
    expand8 = getattr(w, "int8_expand", None)
    if expand8 is not None:
        runtime.quantize_row(value16, s.aq, s.ascale, padded, channels)
        runtime.gemm_int8(s.aq, expand8[0], s.hidden16, s.ascale, expand8[1],
                          padded, w.hidden_width, channels,
                          epilogue=xmxres.EPI_GATE_E4M3, narrow=True)
    else:
        runtime.gemm(value16, w.expand, s.hidden16, padded, w.hidden_width, channels,
                     epilogue=xmxres.EPI_GATE_E4M3, narrow=True)
    # Published, as half, in `ffn` — the residual role, live until the attention's residual
    # has read it: `ffn16`'s role is K's too, which the projection's passes write.
    ffn8 = getattr(w, "int8_ffn", None)
    record_project_residual(runtime, s.hidden16, w.ffn_proj, s.branch, source, w.ffn_cos,
                            s.ffn, padded, channels, w.hidden_width, skip_half=chain,
                            epilogue=xmxres.EPI_E4M3, narrow=True,
                            integer=None if ffn8 is None else
                            (ffn8[0], ffn8[1], s.aq, s.ascale))

    key = record_qkv_projection(runtime, s.ffn, w, s, 1, padded, channels, heads, vit=True)
    if runtime.fuse_global_attention:
        # QK^T, the softmax, PV and the head merge in one pass, and no score stored
        merged = s.context16
        runtime.global_attention(s.q16, key, s.v16, merged, padded, s.tokens, heads)
    else:
        merged = s.merged16
        runtime.gemm(s.q16, key, s.scores, padded, padded, 32, batch=heads,
                     strides=(padded * 32, padded * 32, padded * padded), transpose_b=True)
        runtime.vit_softmax(s.scores, s.probs16, s.reciprocal, heads * padded, s.tokens,
                            stride=padded)
        runtime.gemm(s.probs16, s.v16, s.context, padded, 32, padded, batch=heads,
                     strides=(padded * padded, padded * 32, padded * 32))
        runtime.merge_heads(s.context, merged, 1, padded, channels, heads,
                            epilogue=xmxres.EPI_E4M3, narrow=True, scale=s.reciprocal)
    out8 = getattr(w, "int8_out", None)
    integer = None if out8 is None else (out8[0], out8[1], s.aq, s.ascale)
    if chain:
        record_project_residual(runtime, merged, w.out, s.attention, s.ffn, w.attn_cos,
                                target, s.tokens, channels, channels,
                                epilogue=xmxres.EPI_E4M3, narrow=True, skip_half=True,
                                integer=integer)
    else:
        record_project_residual(runtime, merged, w.out, s.attention, s.ffn, w.attn_cos,
                                target, padded, channels, channels, skip_half=True,
                                integer=integer)


def run_global_block(runtime, w, s, value):
    """Host convenience: `value` is (tokens, channels)."""
    tokens, channels = value.shape
    xmxres.host_write(s.value, value, rows=(s.padded, channels))
    runtime.begin()
    record_global_block(runtime, w, s)
    passes = runtime.submit()
    return xmxres.host_view(s.out, shape=(s.padded, channels))[:tokens].copy(), passes


class BlockScratch:
    """Working buffers for one block at one extent, allocated once and reused."""

    def __init__(self, runtime, weights, height, width, arena=None):
        channels, heads = weights.channels, weights.heads
        # Sized for the largest window count any origin can produce, so blocks at the
        # same level share one scratch even though their shifts differ. Getting this
        # wrong is silent: a shifted block has more windows than an unshifted one and
        # would write past the end of buffers cut to the unshifted size.
        padded_height, padded_width, _ = runtime.window_extent(height, width, (-4, -4))
        self.height, self.width = height, width
        self.tokens = 64
        self.windows = (padded_height // 8) * (padded_width // 8)
        self.batch = self.windows * heads
        pixels = height * width
        windowed = self.windows * self.tokens * channels
        hidden = weights.groups * 128 if weights.branched else weights.expand.nbytes // 2 // channels

        if getattr(weights, "split", False):
            hidden = weights.groups * 256
        # Every buffer a block wrote in float32 only to read it straight back went
        # away when the publishes moved into the pass that produces the value.
        make = (arena.buffer if arena is not None else
                lambda name, count, dtype=np.float32: runtime.buffer(count, dtype))
        self.value = make("value", pixels * channels)
        self.value16 = make("value16", pixels * channels, np.float16)
        self.hidden16 = make("hidden16", pixels * hidden, np.float16)
        self.heads16 = (make("heads16", pixels * channels, np.float16)
                        if weights.branched or getattr(weights, "split", False) else None)
        self.branch = make("branch", pixels * channels)
        self.ffn = make("ffn", pixels * channels)
        self.win16 = make("win16", windowed, np.float16)
        self.proj = make("proj", windowed * 3)
        self.q16, self.k16, self.v16 = (make(name, windowed, np.float16) for name in ("q16", "k16", "v16"))
        self.key16 = make("key16", windowed, np.float16)   # see record_qkv_projection
        self.scores = make("scores", self.batch * self.tokens * self.tokens)
        self.probs16 = make("probs16", self.batch * self.tokens * self.tokens, np.float16)
        self.context = make("context", self.batch * self.tokens * 32)
        self.merged16 = make("merged16", windowed, np.float16)
        # the fused attention's merged output: scores' and context's role, unused by then
        self.context16 = make("context16", windowed, np.float16)
        self.attended = make("attended", windowed)
        # The integer path's operands. Rows is the worse of the image and the padded
        # window count, because the out projection runs over windows and a shifted origin
        # has more of them than there are pixels; K is the deeper of the two projections.
        rows = max(pixels, self.windows * self.tokens)
        self.aq = make("aq", rows * max(hidden, channels), np.int8)
        self.ascale = make("ascale", rows)
        self.out = make("out", pixels * channels)
        self.core16 = (make("core16", pixels * channels, np.float16)
                       if getattr(weights, "split", False) else None)
        self.hidden_width = hidden

    def free(self):
        for name in dir(self):
            value = getattr(self, name)
            if isinstance(value, xmxres.Buffer):
                value.free()


def _ffn_groups(runtime, a, b, c, rows, cols, inner, groups, *, leading, strides,
                epilogue, integer=None):
    """Independent group products, with the same tiles and rounding in either mode.

    Batch strides advance the group, row strides advance the pixel within that group.
    In particular, a zero A batch stride broadcasts the branched FFN input; output
    groups occupy disjoint column slices, not consecutive dense matrices.

    `integer` is `(weights, scales, activations, row scales)` on the integer grid, the
    activations already quantised by the caller — one pass over the whole of them, one
    scale per row, which every group then reads. Without it the float call is made
    exactly as it always was.
    """
    if integer is not None:
        weight8, column_scale, a8, row_scale = integer
        runtime.gemm_int8_batched(a8, weight8, c, row_scale, column_scale,
                                  rows, cols, inner, batch=groups, strides=strides,
                                  leading=leading, epilogue=epilogue, narrow=True)
        return
    if runtime.batch_ffn:
        runtime.gemm(a, b, c, rows, cols, inner, batch=groups, strides=strides,
                     leading=leading, epilogue=epilogue, narrow=True)
    else:
        with runtime.independent():
            for group in range(groups):
                runtime.gemm(a, b, c, rows, cols, inner, leading=leading,
                             offsets=tuple(group * step for step in strides),
                             epilogue=epilogue, narrow=True)


def _can_make_input(runtime, w, s):
    """Whether this block's feed-forward is the fused kernel's staged shape."""
    return (runtime.fuse_ffn and not w.branched and not getattr(w, "split", False)
            and w.channels == 32 and s.hidden_width == 128 and (s.height * s.width) % 16 == 0)


def can_merge_input(runtime, w, s):
    """Whether this block's feed-forward can make block 70's merged input itself."""
    return (runtime.fuse_merge_ffn and _can_make_input(runtime, w, s)
            and s.height % 2 == 0 and s.width % 2 == 0)


def can_make_stem(runtime, w, s):
    """Whether this block's feed-forward can make block 0's stem itself."""
    return runtime.fuse_stem_ffn and _can_make_input(runtime, w, s)


def record_feed_forward(runtime, w, s, source, source_half=False, source16=None,
                        merge=None, stem=None):
    """The block's feed-forward, into `s.ffn`. Branched or plain, as the block is.

    `source_half` says the block's input is already float16 — true whenever it is an
    E4M3 publish, which is exact in half — so the GEMM reads it as it is and the residual
    reads the narrow buffer directly. A float32 input is raw — block 0's stem, the merge
    into block 70 — and the GEMM reads it published while the residual takes it as it
    came; `source16` says that published copy has already been written there, by the pass
    that produced the input, so the publishing pass is not needed.

    `merge` is block 70's input still unmade — the level above, the skip, the sin-cos
    table and the level above's width — for the feed-forward to make itself
    (`can_merge_input`); `stem` is block 0's, the features and the adapter
    (`can_make_stem`). `source` is then unused.

    Returns whether `s.ffn` was stored as half: the branched blocks publish it as E4M3,
    which half holds exactly, so they store it narrow and every pass after reads half the
    bytes; the plain blocks' output is unpublished float32 and stays that.
    """
    pixels, channels = s.height * s.width, w.channels
    if merge is not None:
        if not can_merge_input(runtime, w, s):
            raise ValueError("this block's feed-forward cannot make its own input")
        above, skip, sincos, above_width = merge
        runtime.ffn_fused_merge(above, skip, sincos, w.expand, w.branch, s.ffn, w.ffn_cos,
                                s.height, s.width, above_width)
        return False
    if stem is not None:
        if not can_make_stem(runtime, w, s):
            raise ValueError("this block's feed-forward cannot make its own stem")
        features, adapter = stem
        runtime.ffn_fused_stem(features, adapter, w.expand, w.branch, s.ffn, w.ffn_cos, pixels)
        return False
    value16 = source if source_half else (source16 or s.value16)
    if not source_half and source16 is None:
        runtime.e4m3_half(source, s.value16, pixels * channels)
    if w.branched:
        if (runtime.fuse_branched_ffn and pixels % 16 == 0 and channels % 16 == 0
                and channels == w.groups * 32):
            # every group's expand and projection in one pass, the hidden layer on chip
            runtime.ffn_fused(value16, w.expand, w.branch, s.heads16, pixels, channels, 128,
                              groups=w.groups, epilogue=xmxres.EPI_E4M3, narrow=True)
        else:
            # One quantise over the whole activation, one scale per row, every group
            # reading both: the expansion broadcasts A, so there is only one grid to
            # make and no partition to pay for.
            integer = None
            if (getattr(w, "int8_expand", None) is not None
                    and grouped_integer_pays(pixels, 128, channels)):
                runtime.quantize_row(value16, s.aq, s.ascale, pixels, channels)
                integer = (w.int8_expand[0], w.int8_expand[1], s.aq, s.ascale)
            _ffn_groups(runtime, value16, w.expand, s.hidden16, pixels, 128, channels,
                        w.groups, leading=(0, 0, s.hidden_width),
                        strides=(0, channels * 128, 128), epilogue=xmxres.EPI_GATE_E4M3,
                        integer=integer)
            # The contraction is 32 columns over the same rows, and at the extents where
            # that pays — 5376 rows and more — it does, while at 1344 it does not. The
            # gate decides; at the small extents this stays the float call it was.
            integer = None
            if (getattr(w, "int8_branch", None) is not None
                    and grouped_integer_pays(pixels, 32, 128)):
                runtime.quantize_row(s.hidden16, s.aq, s.ascale, pixels, s.hidden_width)
                integer = (w.int8_branch[0], w.int8_branch[1], s.aq, s.ascale)
            _ffn_groups(runtime, s.hidden16, w.branch, s.heads16, pixels, 32, 128,
                        w.groups, leading=(s.hidden_width, 0, channels),
                        strides=(128, 128 * 32, 32), epilogue=xmxres.EPI_E4M3,
                        integer=integer)
        # the fused multi-head kernels publish the residual before attention reads it,
        # which the residual now does on its way out — as half, which holds it exactly
        record_project_residual(runtime, s.heads16, w.ffn_out, s.branch, source, w.ffn_cos,
                                s.ffn, pixels, channels, channels,
                                epilogue=xmxres.EPI_E4M3, skip_half=source_half,
                                narrow=True, integer=integer_pair(w, s))
        return True
    elif (runtime.fuse_ffn and channels == 32 and s.hidden_width % 32 == 0
          and pixels % 16 == 0):
        # both GEMMs in one pass, the hidden layer never written (ffn_fused.comp)
        runtime.ffn_fused(value16, w.expand, w.branch, s.ffn, pixels, channels,
                          s.hidden_width, skip=source, cosine=w.ffn_cos,
                          skip_half=source_half)
        return False
    else:
        runtime.gemm(value16, w.expand, s.hidden16, pixels, s.hidden_width, channels,
                     epilogue=xmxres.EPI_GATE_E4M3, narrow=True)
        record_project_residual(runtime, s.hidden16, w.branch, s.branch, source, w.ffn_cos,
                                s.ffn, pixels, channels, s.hidden_width,
                                skip_half=source_half, integer=integer_pair(w, s))
        return False


def record_split_feed_forward(runtime, w, s, source, source_half=False):
    """The split family's core: e4m3(x @ first), then a per-64-group 64 -> 256 -> 64 MLP.

    The gate sits between the two group GEMMs with no publish, so the wide buffer is
    gated in one dense pass; the group outputs are published once, together. The
    feed-forward's output is published too, as the 64-256 channel blocks' is, and stored
    as half: the QKV projection and the attention's residual both read the publication
    (notes/opendlss-reference.md).
    """
    pixels, channels, groups = s.height * s.width, w.channels, w.groups
    wide = groups * 256
    value16 = source if source_half else s.value16
    if not source_half:
        runtime.e4m3_half(source, s.value16, pixels * channels)
    if getattr(w, "int8_first", None) is not None:
        runtime.quantize_row(value16, s.aq, s.ascale, pixels, channels)
        runtime.gemm_int8(s.aq, w.int8_first[0], s.heads16, s.ascale, w.int8_first[1],
                          pixels, channels, channels, epilogue=xmxres.EPI_E4M3, narrow=True)
    else:
        runtime.gemm(value16, w.first, s.heads16, pixels, channels, channels,
                     epilogue=xmxres.EPI_E4M3, narrow=True)
    _ffn_groups(runtime, s.heads16, w.expand, s.hidden16, pixels, 256, 64,
                groups, leading=(channels, 0, wide),
                strides=(64, 64 * 256, 256), epilogue=xmxres.EPI_GATE)
    # The projection is the one of the split family's two group products that pays: its
    # K is 256, four tiles deep, where the expansion's is 64 and too shallow to hide a
    # quantise behind. The groups take column slices of one wide activation, so the
    # quantise is one pass over all of it and they share its row scales.
    integer = None
    if (getattr(w, "int8_project", None) is not None
            and grouped_integer_pays(pixels, 64, 256)):
        runtime.quantize_row(s.hidden16, s.aq, s.ascale, pixels, wide)
        integer = (w.int8_project[0], w.int8_project[1], s.aq, s.ascale)
    _ffn_groups(runtime, s.hidden16, w.project, s.core16, pixels, 64, 256,
                groups, leading=(wide, 0, channels),
                strides=(256, 256 * 64, 64), epilogue=xmxres.EPI_E4M3,
                integer=integer)
    record_project_residual(runtime, s.core16, w.weight3, s.branch, source, w.ffn_cos,
                            s.ffn, pixels, channels, channels, skip_half=source_half,
                            epilogue=xmxres.EPI_E4M3, narrow=True, integer=integer_pair(w, s))


def can_fuse_window_block(runtime, w, s):
    """Whether this block's attention half runs as one pass a window (window_block.comp)."""
    return (w.channels == 32 and w.heads == 1 and s.tokens == 64 and runtime.fuse_window_block
            and runtime.qkv_epilogue and runtime.fuse_partition
            and runtime.fuse_window_attention and runtime.fuse_attention_merge
            and runtime.fuse_window_residual)


def record_window_attention(runtime, w, s, source, target=None, publish=0,
                            target_half=False, source_half=False, pool=None, head=None):
    """Window attention over `source`, into `s.attended` — in window order.

    With a `target`, the output projection finishes the block instead: it adds
    `source * attn_cos` and writes straight back into the unpadded image, so neither
    `s.attended` nor the residual's own window-reversing pass is needed
    (ProjectsCodex's phase39). `source` is then the residual's skip, as it always was.

    The reverse back to image order is the following residual's own gather, so nothing
    is written in image order here. The window count follows this block's own origin,
    not the scratch's worst case.
    """
    channels, heads, tokens = w.channels, w.heads, s.tokens
    if ((target is not None or pool is not None or head is not None)
            and can_fuse_window_block(runtime, w, s)):
        # the three fused passes below in one, a window a workgroup (window_block.comp);
        # only on top of them, so that turning one of them off still compares its own path
        if head is not None:
            weights, head_target, columns = head
            runtime.window_block(source, w.qkv, w.out, head_target, w.bias, w.attn_cos,
                                 w.scale, s.height, s.width, w.origin,
                                 image_half=source_half, head=weights, head_columns=columns)
        elif pool is not None:
            pooled, published = pool
            runtime.window_block(source, w.qkv, w.out, published, w.bias, w.attn_cos, w.scale,
                                 s.height, s.width, w.origin, narrow=True,
                                 image_half=source_half, pooled=pooled)
        else:
            runtime.window_block(source, w.qkv, w.out, target, w.bias, w.attn_cos, w.scale,
                                 s.height, s.width, w.origin, epilogue=publish,
                                 narrow=target_half, image_half=source_half)
        return
    padded_height, padded_width, _ = runtime.window_extent(s.height, s.width, w.origin)
    windows = (padded_height // 8) * (padded_width // 8)
    batch = windows * heads
    windowed = windows * tokens * channels
    # A raw source is a 32-channel block's feed-forward output, which the residual reads
    # as it is and the projection published; the wider blocks' is published already.
    publish_image = not source_half
    if runtime.fuse_partition:
        # the projection gathers its window rows from the image itself
        key = record_qkv_projection(runtime, source, w, s, windows, tokens, channels, heads,
                                    window=(s.height, s.width, w.origin),
                                    image_half=source_half, publish_image=publish_image)
    else:
        runtime.partition(source, s.win16, s.height, s.width, channels, origin=w.origin,
                          narrow=True, a_half=source_half,
                          epilogue=xmxres.EPI_E4M3 if publish_image else 0)
        key = record_qkv_projection(runtime, s.win16, w, s, windows, tokens, channels, heads)
    fused = runtime.fuse_window_attention and tokens == 64
    merged = fused and runtime.fuse_attention_merge
    attended = s.context16 if merged else s.merged16
    if fused:
        # One dispatch for QK^T, softmax and PV (ProjectsCodex's phase42). Never into
        # `merged16`: it shares q16's arena role, and another workgroup may still be
        # reading Q while this one stores. Merged, the same dispatch also does the head
        # merge and writes the published result into `context16`, whose role (the
        # scores') the fused path leaves unused.
        runtime.window_attention(s.q16, key, s.v16, attended if merged else s.context,
                                 batch, heads, bias=w.bias, merged=merged)
    else:
        runtime.gemm(s.q16, key, s.scores, tokens, tokens, 32, batch=batch,
                     strides=(tokens * 32, tokens * 32, tokens * tokens), transpose_b=True)
        runtime.softmax(s.scores, s.probs16, batch * tokens, tokens, narrow=True,
                        bias=w.bias, heads=heads)
        runtime.gemm(s.probs16, s.v16, s.context, tokens, 32, tokens, batch=batch,
                     strides=(tokens * tokens, tokens * 32, tokens * 32))
    if not merged:
        runtime.merge_heads(s.context, s.merged16, windows, tokens, channels, heads,
                            epilogue=xmxres.EPI_E4M3, narrow=True)
    if pool is not None:
        # block 0: the output only ever read pooled or published, both made here
        pooled, published = pool
        runtime.gemm_residual_pool(attended, w.out, source, w.attn_cos, published, pooled,
                                   windows * tokens, channels,
                                   (s.height, s.width, 8, w.origin), skip_half=source_half)
    elif target is not None:
        # Through the same helper the feed-forward uses, so the integer branch is one
        # place. Its intermediate is `s.attended`, not `s.branch`: the projection runs
        # over windows, and a shifted origin has more window rows than there are pixels,
        # so the block's pixel-sized buffers are a row count short. `attended` is the
        # window-sized one and this path leaves it unused.
        out8 = getattr(w, "int8_out", None)
        record_project_residual(runtime, attended, w.out, s.attended, source, w.attn_cos,
                                target, windows * tokens, channels, channels,
                                reverse=(s.height, s.width, 8, w.origin),
                                epilogue=publish, narrow=target_half,
                                skip_half=source_half,
                                integer=None if out8 is None else
                                (out8[0], out8[1], s.aq, s.ascale))
    else:
        runtime.gemm(attended, w.out, s.attended, windows * tokens, channels, channels)


def can_pool_output(runtime, w, s):
    """Whether this block's window residual can pool and publish its own output."""
    _, _, (top, left) = runtime.window_extent(s.height, s.width, w.origin)
    return (runtime.fuse_pool and runtime.fuse_window_residual and w.channels == 32
            and not getattr(w, "split", False) and s.tokens == 64
            and s.height % 2 == 0 and s.width % 2 == 0 and top % 2 == 0 and left % 2 == 0)


def record_block(runtime, w, s, source=None, target=None, publish=0, source_half=False,
                 target_half=False, source16=None, merge=None, stem=None, pool=None,
                 head=None):
    """A whole window block: feed-forward, attention, both residuals.

    `source` and `target` default to the scratch's own buffers; passing them lets one
    level's blocks chain into the next without a copy. `publish` is the epilogue the
    closing residual applies, which is how a block's output is published without a
    second pass over it. `pool=(pooled, published)` is block 0's: its output is written
    only pooled and published, both by the closing residual (`can_pool_output`), and
    `target` is unused.
    """
    source = source or s.value
    target = target or s.out
    pixels = s.height * s.width
    if getattr(w, "split", False):
        if source16 is not None:
            raise ValueError("the split feed-forward takes no prepared half copy")
        record_split_feed_forward(runtime, w, s, source, source_half)
        ffn_half = True
    else:
        ffn_half = record_feed_forward(runtime, w, s, source, source_half, source16=source16,
                                       merge=merge, stem=stem)
    if pool is not None and not can_pool_output(runtime, w, s):
        raise ValueError("this block's window residual cannot pool its own output")
    if head is not None and not can_fuse_window_block(runtime, w, s):
        raise ValueError("only a fused window block computes the head itself")
    if runtime.fuse_window_residual:
        record_window_attention(runtime, w, s, s.ffn, target=target, publish=publish,
                                target_half=target_half, source_half=ffn_half, pool=pool,
                                head=head)
        return
    record_window_attention(runtime, w, s, s.ffn, source_half=ffn_half)
    # the window reverse is the residual's own gather, not a pass of its own
    runtime.residual(s.attended, s.ffn, w.attn_cos, target, pixels * w.channels,
                     w.channels, reverse=(s.height, s.width, 8, w.origin),
                     epilogue=publish, narrow=target_half, b_half=ffn_half)


def run_block(runtime, w, s, value):
    """Host convenience: one block, one submit, numpy in and numpy out."""
    xmxres.host_write(s.value, value)
    runtime.begin()
    record_block(runtime, w, s)
    passes = runtime.submit()
    return xmxres.host_view(s.out, shape=value.shape).copy(), passes


# --------------------------------------------------------------------------
# transitions between levels
# --------------------------------------------------------------------------


class Transition:
    """The weights a level change needs, uploaded once."""

    def __init__(self, runtime, weights, index, *, kind):
        self.kind = kind
        prefix = f"block{index}.layer0"
        # The level change's own projection on the integer path. Both of them are a plain
        # GEMM with a publish the integer kernel already has — the downsample's is E4M3
        # into a half target, the upsample's is nothing at all into a float32 one — so
        # unlike the QKV projection this needed no new kernel, only the weight here and
        # the row grid where it is used.
        #
        # Both of the two level changes pass the tile gate (block14 K=128 N=256, block22
        # K=256 N=512) and both are wired, but it buys nothing and so it is off: three
        # alternating runs of `work/int8_frame_cost.py 768 448` give 43.15/43.12/42.93 ms
        # without it and 42.96/42.97/43.19 ms with it — the same number either way, and
        # the median the other way (43.31-43.37 against 43.36-43.71). K=128 is below
        # where the integer path pays for its row grid at all, which is the same line
        # `work/int8_cover.py` drew. Kept wired because it costs nothing to keep:
        # `NR_INT8_TRANSITION=1` turns it on.
        self.int8 = None
        if kind in ("down", "up"):
            self.weight0 = runtime.buffer_from(weights[f"{prefix}.weight0"], np.float16)
            self.out_channels = weights[f"{prefix}.weight0"].shape[1]
            if runtime.int8_project and os.environ.get("NR_INT8_TRANSITION", "0") != "0":
                self.int8 = quantise_weight(runtime, weights[f"{prefix}.weight0"])
        if kind == "up":
            self.sine = runtime.buffer_from(weights[f"{prefix}.sin"])


def record_downsample(runtime, transition, scratch, source, target, height, width,
                      channels, *, pad_to=0, source_half=False, target_half=False):
    """Pool the block's unpublished output, publish it, then project.

    The fused `ds` kernels pool the half-precision output before its E4M3 publish and
    publish the pooled tensor again before the QMMA projection, so both are here.
    """
    if pad_to:
        padded_height = -(-height // pad_to) * pad_to
        padded_width = -(-width // pad_to) * pad_to
        runtime.pad_end(source, scratch.padded, height, width, padded_height,
                        padded_width, channels, a_half=source_half, narrow=source_half)
        source, height, width = scratch.padded, padded_height, padded_width
    half_height, half_width = height // 2, width // 2
    pixels = half_height * half_width
    runtime.pool2(source, scratch.pooled16, height, width, channels,
                  epilogue=xmxres.EPI_E4M3, narrow=True, a_half=source_half)
    grid = getattr(transition, "int8", None)
    if grid is not None:
        runtime.quantize_row(scratch.pooled16, scratch.aq, scratch.ascale, pixels, channels)
        runtime.gemm_int8(scratch.aq, grid[0], target, scratch.ascale, grid[1],
                          pixels, transition.out_channels, channels,
                          epilogue=xmxres.EPI_E4M3, narrow=target_half)
    else:
        runtime.gemm(scratch.pooled16, transition.weight0, target, pixels,
                     transition.out_channels, channels, epilogue=xmxres.EPI_E4M3,
                     narrow=target_half)
    return half_height, half_width


def record_upsample_merge(runtime, transition, scratch, source, skip, target,
                          source_height, source_width, height, width, channels,
                          out_channels, *, source_half=False, skip_half=False,
                          target_half=False, published=None):
    """Project, nearest-upsample onto the skip, add the scaled skip, publish.

    The fused `upsample` kernels read the merged tensor as E4M3, so the publish is
    part of the transition rather than of the block that follows. With `published`,
    `target` takes the merge raw instead and `published` the publication: block 66's
    input, which its feed-forward's GEMM reads published and its residual raw.
    """
    epilogue = xmxres.EPI_E4M3 if published is None else 0
    source_pixels = source_height * source_width
    projected16 = source if source_half else scratch.projected16
    if not source_half:
        runtime.to_half(source, scratch.projected16, source_pixels * channels)
    grid = getattr(transition, "int8", None)
    if grid is not None:
        runtime.quantize_row(projected16, scratch.aq, scratch.ascale,
                             source_pixels, channels)
        runtime.gemm_int8(scratch.aq, grid[0], scratch.projected, scratch.ascale,
                          grid[1], source_pixels, out_channels, channels)
    else:
        runtime.gemm(projected16, transition.weight0, scratch.projected,
                     source_pixels, out_channels, channels)
    if runtime.fuse_transition:
        # the upsample, the scaled skip and the add in one pass (resident.comp UPSAMPLE_ADD)
        runtime.upsample_add(scratch.projected, skip, transition.sine, target, height, width,
                             source_width, out_channels, skip_half=skip_half,
                             epilogue=epilogue, narrow=target_half, published=published)
        return
    with runtime.independent():
        runtime.upsample2(scratch.projected, scratch.upsampled, source_width, height,
                          width, out_channels)
        runtime.scale_channel(skip, transition.sine, scratch.scaled,
                              height * width * out_channels, out_channels,
                              a_half=skip_half)
    runtime.add(scratch.upsampled, scratch.scaled, target, height * width * out_channels,
                epilogue=epilogue, narrow=target_half)
    if published is not None:
        runtime.e4m3_half(target, published, height * width * out_channels)


class TransitionScratch:
    """Buffers a transition needs, sized for the largest level that uses it."""

    def __init__(self, runtime, elements, half_elements, arena=None):
        make = (arena.buffer if arena is not None else
                lambda name, count, dtype=np.float32: runtime.buffer(count, dtype))
        # `padded` holds whichever width its source has, so it is sized for float32
        self.padded = make("transition.padded", elements)
        self.pooled16 = make("transition.pooled16", elements, np.float16)
        self.projected = make("transition.projected", elements)
        self.projected16 = make("transition.projected16", elements, np.float16)
        self.upsampled = make("transition.upsampled", elements)
        self.scaled = make("transition.scaled", elements)
        # the level changes' row grid: `aq` one byte a value for the widest level's
        # pixels x channels, `ascale` one float a row.
        self.aq = make("transition.aq", elements, np.int8)
        self.ascale = make("transition.ascale", elements)

    def free(self):
        for name in dir(self):
            value = getattr(self, name)
            if isinstance(value, xmxres.Buffer):
                value.free()
