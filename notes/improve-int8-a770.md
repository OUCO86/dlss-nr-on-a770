# The integer path on the A770: not a traffic saving, an instruction saving

2026-10-09. `notes/phase23-integer-weights.md` closed the integer question on an iGPU with
"it would buy nothing anyway", and `notes/improve-int8-bottleneck.md` reopened it for the
eight global blocks without ever putting the kernel in the graph. This is the A770's own
answer, and it is not the one either note was arguing about.

## What was measured first, and what it ruled out

The machine the numbers had to come from is the one the game runs: **768x448** (render
scale 0.4), 47 ms on the device, 404 passes. Not 1080p — 1080p is 214 ms here and every
conclusion drawn from it is a conclusion about a frame nobody renders.

| one 768x448 frame | |
|---|---|
| passes | 404 |
| bytes moved | 3.50 GB |
| device time | 37.5 ms (47 ms wall, the rest is the host) |
| **so** | **93 GB/s, 32 % of this card's 291 GB/s** |

Three candidate levers, each measured rather than assumed:

- **Weight bytes.** `src/bench/traffic_audit.py`: the GEMMs' weight operands are **0.08 GB of
  3.50 GB**. The whole model read once is 0.29 GB, 8 %. Halving it is worth almost
  nothing — and at 32 % of peak bandwidth, bytes are not what the frame waits on anyway.
  This is the argument `phase23` made from arithmetic before FFN batching; on this card
  it is now a measurement, and it holds.
- **Pass count.** `work/pass_overhead.py`: one pass costs **4.4 us** that is not its own
  work. 404 of them is 1.8 ms of 37.5. Cutting the pass count in half would buy 0.9 ms.
- **The work itself.** `src/bench/pass_time.py`, passes with M at or below 8192: **23.49 ms,
  62.7 % of the frame** — and it does not follow the frame. At 384x224 the whole graph is
  26.35 ms, so nearly all of that 23.5 ms is a fixed cost of the deep blocks: small M,
  very deep K, 0.16 to 0.64 ms a pass at 3 to 14 GB/s.

The third one is where the frame is.

## The measurement that matters

`work/int8_ab.py`, 24 dispatches each, device timestamps, every shape checked bit for bit
against exact integer arithmetic before its time is allowed to mean anything:

| M x N x K | fp16 | int8 | |
|---|---|---|---|
| 32 x 1024 x 4096 | 13.64 ms | 1.81 ms | **7.55x** |
| 96 x 1024 x 4096 | 6.42 ms | 2.25 ms | **2.86x** |
| 32 x 1024 x 1024 | 3.53 ms | 0.53 ms | **6.64x** |
| 96 x 256 x 256 | 0.51 ms | 0.23 ms | 2.21x |
| 384 x 64 x 256 | 0.51 ms | 0.25 ms | 2.07x |
| 86016 x 32 x 128 | 3.18 ms | 1.60 ms | 1.99x |

Per dispatch that is 0.568 ms against 0.075 ms on the shape the frame's own
`gemm_residual` passes use, and the frame's passes measure 0.61 to 0.64 ms — so the
baseline is the real one and not a stand-in.

**The float side is not a bad baseline that int8 is flattering.** For M of 32 the port
already routes to the 32-row staged build with the 64-deep K step (`small` in
`libxmx.c`, `notes/improve-b.md`), which is the fastest float path that exists here. What
int8 changes is the instruction: configuration 4 covers K=32 per multiply-add against the
float configuration's 16, so a pass waiting on that loop takes half the trips round it and
moves half the bytes while doing so. `improve-int8-bottleneck.md` measured 1.23x to
1.75x on these shapes on an iGPU that was not waiting on them; on this card, which is,
it is 2x to 7.5x.

## The kernel is already here and already correct

- A770 exposes configuration 2 as **8x8x32** `sint8 x sint8 -> sint32` — not Xe2's
  8x16x32. Both integer shaders were adapted to that and verified: five shapes through
  the one-shot runner bit-exact, six through the resident runtime bit-exact
  (`work/int8_probe.py`, `src/gpu/test_gemm_int8_staged.py`).
- `xmx_int8_init`, `xmx_rec_gemm_int8` and `Runtime.gemm_int8` all exist. **Nothing in the
  graph calls them.** That is the whole gap.

## What stands between this and a frame

`gemm_staged_int8.comp` has no epilogue. The passes that hold the 23.5 ms are
`gemm_residual` — GEMM, residual, cosine and the E4M3 publish in one pass — so the
integer path has to be `gemm_int8` into a scratch, then `rt.residual(...)` after it, and
the residual's own cost has to be paid. On these shapes that scratch is 32x1024 floats,
which is nothing; the question is whether two passes where there was one loses what the
instruction count won.

Then, in order of how much of the prize they gate:

1. **A quantiser for the activations.** Per row, one pass per GEMM, fp16 in and int8 plus
   a float32 scale per row out. No such shader exists. Per row is not a detail:
   `phase23` measured a single per-tensor grid as rounding 21.5 % of l1's non-zero values
   away entirely, and per token each row gets its own grid.
2. **The weights, once, at load.** `src/gpu/int8_quant.py` already does per output
   channel, which is what the kernel's column scale consumes.
3. **The accuracy bill, at this extent.** `src/bench/int8_bottleneck.py` measures it in
   the metric this project judges by and takes `--size 768x448 --activations`, but it
   needs a real frame and this tree has none (`pngs/` is empty, `work/frame_in.png` is
   not there). `improve-int8-bottleneck.md`'s 4.8 % of the effect was measured at 1080p
   on blocks 31-38; the number that decides this is the same measurement at 768x448,
   where its own trend says the cost is larger — the smaller the frame, the larger the
   share.

## The quantiser exists now

`src/gpu/quantize_row.comp`, `xmx_quant_init` / `xmx_rec_quant`, `Runtime.quantize_row`,
`src/gpu/test_quantize_row.py`. One workgroup a row: the row's maximum as a tree
reduction in shared memory, then `roundEven(value / s)` with `s = max|row| / 127`, and a
row of zeros keeps `s = 1.0` rather than dividing by zero. `roundEven` and not `round`,
because the host reference is numpy's `np.round`.

Five cases agree with `int8_quant.quantise(a, axis=1)` — including a row of zeros and
70000 rows, which is past one dispatch's x extent and exercises the y dimension.

Two things it does not demand, and why:

- **The scale is exact to one ulp, not bit for bit.** The device compiles `top / 127.0`
  into a reciprocal multiply; on 4 of 96 rows of one case it lands one ulp below the
  correctly-rounded quotient. Bounded rather than fixed: the alternative is to move the
  host reference to the device's answer, which is the thing this project does not do.
- **A packed value may sit one step either side of the host's** when it is on the
  boundary that ulp moves, and the reconstruction is held to half a step plus one ulp of
  the quotient — which is the real bound, not a comfortable one.

## It is in the graph now, and it is not free

`NR_INT8_PROJECT=1` puts the eight bottleneck blocks' two projections on configuration
4 — the feed-forward's down (`96 x 1024 x 4096`) and the attention's out
(`96 x 1024 x 1024`). Not the expansion: its epilogue is the quadratic gate and the
integer kernel has none, so the publish would be a pass of its own and would cost more
than the instruction count wins (`work/int8_ab.py`: 0.104 ms against 0.048 + 0.059).
Not the QKV projection either, whose epilogue is three splits and two cosine publishes.

`record_project_residual` grew a third path: `quantize_row`, `gemm_int8`, `residual`.
One more pass than the fused float one, because the kernel has no epilogue, and the
residual is the pass the graph already had for the unfused comparison.

**What it is worth, on the wall and on the device, at 768x448:**

| | fp16 | int8 | |
|---|---|---|---|
| wall, best of 4, three alternating runs | 47 / 46 / 46 ms | 45 / 44 / 44 ms | **-2 to -3 ms** |
| device, `work/pass_where.py` | 37.48 ms | 35.18 ms | **-2.30 ms** |
| the bottleneck blocks alone | 5.32 ms | 3.55 ms | **-1.77 ms** |

**What it costs, on the real frame `work/capture.nrn`, still, no history:**

| | |
|---|---|
| the network's own effect, mean \|output - input\| | 5.1726 of 255 |
| what the integer path moved, mean \|int8 - fp16\| | **0.5225 of 255** |
| **as a share of the effect** | **10.10 %** |
| median / p99 / worst pixel | 0.59 / 3.00 / **11.21** of 255 |

`work/int8_quality.py` measures it, `work/int8_crop.py` shows it.

## Where the 10 % comes from, and why it is not a bug

`work/int8_error_split.py` takes block 31's real projection and the real activation the
frame produces and asks each grid alone: the projection comes out **1.15 % from exact
arithmetic, rms against the projection's own rms**. Blocking the grids along K — four
grids a row instead of one, four a column instead of one — takes that to 0.97 %. So
almost all of it is the eight bits, not the resolution of the grid, and there is nothing
to win by spending passes on finer scales.

The 10 % is that 1.15 % seen through the graph: the feed-forward's contribution to the
picture is roughly ten times what survives into the composition, so a percent of the
projection is ten percent of the effect. It also means the two levers are locked
together — quantising fewer of the eight blocks, or fewer of the two projections, buys
back damage in exact proportion to the milliseconds it gives up.

## Where it does not pay, and why

`work/int8_ab.py` now times every GEMM shape the frame spends a millisecond on, plus
the row grid each would need:

| M x N x K | fp16 | int8 | + row grid | in frame |
|---|---|---|---|---|
| 96 x 1024 x 4096 | 0.268 | 0.094 | 0.012 | **0.39x** |
| 96 x 4096 x 1024 | 0.104 | 0.043 | 0.005 | 0.46x |
| 96 x 1024 x 1024 | 0.071 | 0.028 | 0.005 | 0.46x |
| 384 x 512 x 512 | 0.044 | 0.017 | 0.006 | 0.54x |
| 384 x 64 x 256 | 0.021 | 0.010 | 0.005 | 0.72x |
| 1344 x 256 x 256 | 0.030 | 0.015 | 0.012 | 0.93x |
| 1344 x 32 x 128 | 0.013 | 0.008 | 0.009 | 1.33x |
| 5376 x 32 x 128 | 0.015 | 0.008 | 0.031 | 2.62x |
| 21504 x 32 x 128 | 0.031 | 0.014 | 0.115 | **4.13x** |
| 86016 x 32 x 128 | 0.133 | 0.067 | 0.667 | **5.53x** |

The row grid is a pass over M x K that reads two bytes a value and writes one, so the
integer path moves **more** bytes than the float one unless the GEMM was waiting on its
K loop and not on memory. Past about 1536 rows it costs more than it saves, and the
graph's own switch says so: `record_project_residual` takes the integer path only at
M at or under 1536 with K at or above 256.

That is the whole remaining prize, and it is in the window levels, not the bottleneck:
about 1.15 ms in `C=512`'s `384 x 64 x 256` and its two `384 x 512 x 512` residuals, at
whatever damage those layers add on top.

## The quantise pass is the whole cost, and it can be fused away

`work/int8_cover.py` times every GEMM shape the frame actually calls, three ways: at
fp16, at int8 with the row-quantise pass in front of it as the graph runs it today,
and at int8 with the quantise pass removed — the world where quantising the activation
is part of the GEMM that consumes it rather than a pass of its own.

| | the frame's GEMMs |
|---|---|
| fp16 | 14.76 ms |
| int8 as it runs today, quantise pass included | 20.90 ms — **6.14 ms slower** |
| int8 with the quantise pass fused away | 6.89 ms — **7.87 ms faster** |

That third column is not a small change of emphasis, it is a different result. Today's
integer path wins on ten of thirty-six shapes, all of them small; with the quantise
pass fused away it wins on **twenty-five**, at **1.85x to 2.46x**, and it wins on the
large-M small-K shapes that carry 62.7 % of the frame. The pass that makes int8
possible is the only reason int8 loses.

Fusing it means the GEMM reads a float16 activation instead of a packed one, quantises
into shared memory on the way in, and pays for it in arithmetic rather than in a trip
to DRAM. It cannot reuse the kernel unchanged for two reasons:

- the row scale needs the row's maximum over all of K, and a tiled GEMM only ever sees
  a slice of K — so the scale has to be per K-block, which is finer, not coarser, and
  is not what `quantise_weight` produces today; and
- an int32 cooperative-matrix accumulator cannot be scaled in place, so each K block
  has to be converted to float, scaled, and added into a float accumulator.

Both are available: `coopmat<float, ...>(int32_accumulator)`, `f * scalar` and
`total = total + f * s` all compile under this glslang. What has not been measured is
what the finer grid costs in quality, or what the in-kernel quantise costs in
arithmetic; the 7.87 ms is a ceiling for the idea, not a promise about the kernel.

## The fusion was built, measured, and lost — and the pass was fixed instead

Both of the obstacles above turned out to be available, so the kernel was built:
`gemm_staged_int8_fused.comp`. It is slower, and by enough that the answer is settled.

| measured on the frame's GEMMs, fp16 14.78 ms | |
|---|---|
| int8 with the quantise pass, before | 20.98 ms |
| **int8 with the quantise pass, after** | **8.90 ms** |
| the per-K-block fused kernel (8 rows x 64 of K) | 27.05 ms |
| the per-row fused kernel | 34.55 ms |

The per-K-block build loses its whole advantage to one thing: the accumulator. Scaling
each K block where it is produced means turning int32 into float32 and adding it into a
float accumulator once per block, and at K of 4096 that is sixty-four times where the
kernel it replaces does it once, in the epilogue. It measured 27.05 ms against 6.90 ms
for the GEMM alone. The per-row build keeps the integer accumulator across all of K but
is slower still, at 34.55 ms, and the reason is the one that kills the idea outright:

**a tiled GEMM reads the activation once per column block.** At BN of 32 and N of 512
that is sixteen times. Fusing the quantise into the GEMM does not remove sixteen reads,
it upgrades all sixteen from int8 to float16. The quantise pass reads the activation
once; the GEMM reads it N / BN times, and that number is not small on the shapes that
matter. So the fusion trades one float16 read for N/BN of them.

SageAttention reaches the same conclusion from the other side and says so in its own
README: quantisation is deliberately kept out of the GEMM and excluded from its
reported timings.

## The pass was the cost all along, and it was not a bandwidth problem

What the 20.98 ms was actually made of, on 21504 x 128 x 64, the shape that carries the
frame:

| | |
|---|---|
| the GEMM | 30.8 us |
| **the quantise pass feeding it** | **189 us** |

Ten times the thing it feeds, to move 4 MB — which is 7 us of this device's bandwidth.
`quantize_row.comp` was one workgroup of 256 threads per row. At K of 64 a row is
sixty-four float16, so sixty-four of those threads had anything to do and each read
**two bytes** where it could have read sixteen; the row maximum was a tree reduction in
shared memory behind eight barriers; and there were 21504 workgroups of it.

It is now a warp per row, and where a row is shorter than a warp, several rows to a
warp: whole 16-byte words per thread, the row maximum four shuffles inside the lanes
that own the row, and no barrier anywhere. The scale is unchanged — one per row,
`max|row| / 127`, `roundEven` — so nothing about the picture changes; 131072 packed
values in the test, seven of them off by one.

**189 us to about 9 us, and the integer path as a whole from 6.20 ms slower than fp16
to 5.88 ms faster.** That is 12 ms a frame, and it is the whole of the difference
between the two columns at the top of this note.

Two things bit while writing it, both worth remembering:

- A row that depends on the lane must not `return` before a shuffle. The lanes that
  fell off the end left the rest of the subgroup waiting, and the device was lost. Hold
  the last row instead and guard the stores.
- The reciprocal is `1.0 / scale`, not `127.0 / scale` — `scale` is already
  `peak / 127`. Written the second way every value saturates to +/-127 and the row
  scales still come out right, which is what makes it look like a memory bug.

## Two things worth saying about how this was measured

`buffer_from(array)` takes float32 by default. Used on an int8 array it uploads four
bytes a value and the kernel reads garbage that still times perfectly — the byte count a
kernel reads is the kernel's business, not the buffer's. Every shape above is verified
bit-exact before its speed is reported, and before that check was added all seven shapes
reported "wrong" rather than a number.

The frame records itself twice, once dry to size the scratch. An audit that hooks the
runtime sees both and reports double. `src/bench/traffic_audit.py` and `src/bench/pass_time.py` both
clear after `_prepare_scratch`; before they did, a 3.50 GB frame read as 18.43 GB at
1080p and 36.85 GB — and the first version of the audit printed a confident 36.85.

## Why the frame's big shapes are not on the integer path, and what it would take

`work/int8_usage.py` counted 32 integer calls in a 768x448 frame out of 516 GEMMs, all of
them M=96, and the reason is not any of the three that suggest themselves.

**Not the shape.** `quantise_weight` refuses K not a multiple of 64 or N not a multiple of
32, because the staged integer kernel tiles (32, 64) in (N, K) and
`cooperativeMatrixRobustBufferAccess` is false here. `work/int8_gate.py` walks all 248
candidate weights: **32 fail, and every one of them is a 32-channel block**, whose K is 32.
The weights behind the 21504-row GEMMs — (64, 64), (128, 64), (128, 32) — all pass.

**Not the speed, any more.** Re-measured after the `quantize_row` rewrite
(`work/int8_cover.py`), the shapes that used to be the worst on the integer path are now
among the best:

| M x N x K | n | fp16 | int8 | before the rewrite |
|---|---|---|---|---|
| 21504 x 64 x 64 | 20 | 37.8 us | 28.7 us (**1.32x**) | 209.1 us (0.18x) |
| 21504 x 128 x 64 | 16 | 57.0 us | 40.2 us (**1.42x**) | 212.9 us (0.27x) |
| 21504 x 32 x 128 | 16 | 34.1 us | 32.7 us (1.04x) | unmeasured |

The old numbers are what excluded them, and the old numbers were the quantise pass, not
the GEMM: at `21504 x 64 x 64` the GEMM itself was 19.5 us against fp16's 37.8.

**Not the accuracy, and the argument that scoped the work has been invalidated by the work.**
`notes/improve-int8-bottleneck.md` scoped integer weights to blocks 31-38 on a gradient
over the pyramid: l1 loses 21.5 % of its non-zero values to an int8 grid and carries 31.95 %
relative error, l5 loses 0.4 % and 1.59 %. `src/bench/int_activations.py` says at line 37
that those are **per-tensor** grids — one scale for a whole activation. The kernel does not
do that; `quantize_row` gives every row its own, which is the entire reason the pass exists.

`work/int8_levels.py` re-measures the same activations both ways, on `work/capture.nrn`:

| level | pixels | C | per-tensor lost / mean err | per-row lost / mean err |
|---|---|---|---|---|
| l1 | 86016 | 32 | 28.11 % / 8.63 % | 2.30 % / 1.04 % |
| **l2** | **21504** | **64** | 12.47 % / 5.68 % | **1.54 % / 0.87 %** |
| l3 | 5376 | 128 | 5.78 % / 3.56 % | 1.35 % / 0.92 % |
| l4 | 1344 | 256 | 3.22 % / 2.23 % | 1.21 % / 0.91 % |
| l5 | 384 | 512 | 4.68 % / 2.15 % | 1.55 % / 1.13 % |
| l6 (bottleneck) | 96 | 1024 | 1.69 % / 1.29 % | 1.24 % / 1.01 % |

The gradient is a property of the coarse grid. Under the grid that ships it collapses, and
**l2 — the level every 21504-row GEMM lives at — is cleaner than l6, the level the integer
path is currently confined to.**

**So it is wiring, in three places.** `quantise_weight` is called from exactly one
constructor, `GlobalBlockWeights` (blocks 31-38); `BlockWeights` and `SplitBlockWeights`
never make an integer copy of anything. `integer=` is passed at exactly two call sites, both
in `record_global_block`. And `record_project_residual` — which already has the branch, and
already pays for it with a residual pass of its own — is reached from `record_feed_forward`
and `record_split_feed_forward` **without** it, three times. The window blocks' out
projection (`record_window_attention`, the `gemm_residual` with `reverse=`) has no integer
branch at all, and that is where all four 21504-row `x 64 x 64` shapes come from.

What each gap is worth, from the same table, as a sum over the frame:

- **already taken**: 3.54 ms (the bottleneck's down 2.84, its out 0.70). The frame A/B
  measures 3 ms of it, so the per-shape sums run about 15 % optimistic.
- **quantise the window blocks' feed-forward weights and pass `integer=` at the three sites
  that already accept it**: 2.06 ms (`384 x 512 x 512` x40, `5376 x 128 x 128` x30,
  `1344 x 256 x 256` x32). No kernel work.
- **give the window blocks' out projection an integer branch**: 2.24 ms over twelve shapes,
  0.37 of it `21504 x 64 x 64` x20. No kernel work either — `gemm_int8` then `residual`,
  which already takes `reverse=`; only the branch does not pass it through.
- **the rest needs a kernel**: the grouped feed-forward (`_ffn_groups`, batched with strides
  and a gate epilogue) 2.33 ms, and the bottleneck's expansion 0.99 ms, which wants the gate
  epilogue on the integer kernel.

Accuracy is a price, not a prohibition. The 32 calls today cost 10.1 % of the effect, and it
grows with how much is converted; the per-row numbers say the activations have room, but the
end-to-end figure would have to be re-measured before any of this is switched on.

**2026-10-11: the wiring was built for the window blocks, and the rest was measured and
declined.** `src/bench/ffn_int8_probe.py` puts the 130 float16 products still in a frame
against the integer path, in one process and alternating: at the group count a frame
actually runs, the integer path is **0.26 ms slower**, and the reason is not the
arithmetic — with both routes taken apart into separate calls, integer is 34 % faster.
It is `gemm_int8` having no batch, where `_ffn_groups` calls `gemm` with `batch=groups`
and that batch is worth 35 % of the work. See `notes/frame-ledger-a770.md`. The useful
question is therefore "does the integer kernel get a batch", not "does this get
converted" — and the answer to the second one, as things stand, is no.

## The window blocks' out projection, and the count that cost the device

Routing the window blocks' out projection through `record_project_residual` lost the
device on the first block that had a quantised weight. The bug was the residual's length,
and it is visible in `resident.comp` without running anything:

```glsl
uint c = index % channels, rest = index / channels;
uint py = rest / width + (pc.k >> 16), px = rest % width + (pc.k & 0xFFFFu);
at = (((py / size) * across + px / size) * size * size
      + (py % size) * size + px % size) * channels + c;
```

With bit 14 set, `index` is an **image** index — `rest / width` is the row — so the count
has to be `height * width * channels`. The projection's own row count is
`windows * tokens`, which a shifted origin makes **larger** than the pixel count: block 6
at 24x32 with origin (-4, -4) has 20 windows, 1280 rows against 768 pixels. Those extra
512 rows indexed past the branch on the read and past `target` on the store.

The one call that already did this (`record_block`, the unfused window residual) passes
`pixels * w.channels`, which is why it works. `record_project_residual` now derives the
count from `reverse` when it has one.

The lesson is the one the arena's own docstring states: a wrong assumption about shared
scratch is silent, and here it was not silent only because the device gave up. Read the
kernel before dispatching into it; do not bisect on the hardware that is also the display.

## Wiring the window blocks, measured

The three gaps above are closed. `quantise_weight` now runs in `BlockWeights` and
`SplitBlockWeights` too, `integer=` is passed at the three call sites that already took
it, and the window blocks' out projection goes through `record_project_residual` so it
has an integer branch. `NR_INT8_PROJECT` turns all of it on; `NR_INT8_WINDOW=0` and
`NR_INT8_WINDOW_OUT=0` take the window halves back and leave the bottleneck's.

What that changed, on a 768x448 frame (`work/int8_usage.py`):

| | fp16 GEMMs | integer GEMMs |
|---|---|---|
| float path | 516 | 0 |
| bottleneck only (before) | 484 | 32 (6 %) |
| **all three (now)** | **276** | **240 (46 %)** |

Frame time, 768x448, best of five (`work/int8_frame_cost.py`):

| | ms |
|---|---|
| float | 46.43 |
| bottleneck only | 44.23 |
| + window feed-forward | 43.33 |
| + window out | 43.13 |
| **all three** | **41.66** |

So 4.77 ms, of which the bottleneck's share was 2.20 and the window blocks' 2.57. The
per-shape sums promised 4.3 ms for the window half and it delivered 2.6; the sums run
optimistic by about 40 % here, not the 15 % they did on the bottleneck.

What it costs, on `work/capture.nrn` against the float path (`work/int8_quality.py`):

| | mean moved, of 255 | as a share of the network's effect | p99 | worst | pixels over 1 |
|---|---|---|---|---|---|
| bottleneck only | 0.52 | 10.10 % | 3.00 | 11.2 | 25.7 % |
| **all three** | **0.75** | **14.52 %** | **4.07** | **12.0** | **40.9 %** |

The output's own spread moves 0.3 % (std 0.23643 against 0.23575) and the shift is
symmetric — p1 -2.76, median +0.03, p99 +2.51 of 255 — so this is error and not a change
of level.

### The number that looked too good, and why it is not the one to judge by

`test_resident` compares a frame against the host reference by correlation, and turning
the window feed-forward on made that correlation go **up**: 0.9739 to 0.9814, past the
float path's own 0.9750. Its absolute error fell too, 1.575e-2 to 1.342e-2. A quantised
pass cannot agree with a float32 reference better than float16 does, so that is not
precision; it is the test's input. `test_frame` builds a 320x320 synthetic feature —
sinusoidal colour, three channels of `default_rng(5)` noise — whose activation
distributions are nothing like a frame's, and the per-row grid behaves differently on
them. On the real frame the same switch costs what it should: 10.1 % to 14.5 %.

Correlation is also blind to scale, which is why `spread` is checked beside it, and the
spread moved 0.9728 to 1.0097 on the synthetic input but 1.0000 to 0.9971 on the real
one. Judge these switches by `work/int8_quality.py`.

One combination does fail `test_resident`: the window out projection on its own, without
the feed-forward, gives corr 0.9629 against the 0.97 threshold. Both on, or neither.

## What it does in the game, and why you cannot feel it

Everything above was measured off a Python harness. The switch was then taken into
the game and A/B'd there, standing still, seven times, and the daemon's own log is
the record: it stamps `gpu A+B+Cms` on every frame and prints a line whenever a
setting rebuilds the graph. `work/daemon_ab.py` reads those back.

| segment | frames | pre | network | post |
|---|---|---|---|---|
| int8 OFF | 2770 | 2 | 44 ms | 1 |
| **int8 ON** | **656** | 2 | **39 ms** | 1 |

39 against 44, so 5 ms and 11.4 %, slightly better than the harness promised
(4.77 ms, 10.3 %). The pre and post columns do not move, which is the point: only
the network changed, and only the projections run there.

That the switch really rebuilt the graph is not a matter of reading the log line
and hoping. `nr_frame.set_int8` returns False when the value already matches, and
the daemon only prints on True — so the print is proof `runtime.int8_project`
moved, and every `quantise_weight` behind it ran again.

### The frame and the eye

No difference was visible, in motion or standing still, and the numbers say why.

The network's whole effect on the picture is about 5.17 of 255. What the integer
path costs is 0.75 of 255 — 14.5 % of that effect, but 0.3 % of the picture. Its
p99 is 3.5, which is roughly where a step becomes findable in a still image, and
only 1 % of pixels get there.

`work/int8_diff_image.py` makes it visible anyway, by multiplying: it writes the
float frame, the integer frame, and the difference times 25 between them. The
middle panel is grey wherever the two agree, and that is most of the picture —
every flat surface, every smooth gradient. What is not grey is outlines, UI edges
and fine texture. Staring at a wall was never going to show anything.

The 5 ms is invisible for the same kind of reason. A frame is about 70 ms end to
end, and the layer reuses 87 % of its pixels between frames, so the saving arrives
diluted: 7 % of the frame, felt as nothing, worth having for free.

So: no visible cost, and 5 ms. Leave it on.

## The QKV projection: the last group in the frame worth taking

Everything above leaves one thing on the table. `work/int8_cover.py` counted a frame's
GEMMs at 276, of which 240 are integer; `work/qkv_census.py` asks what the rest are and
answers **120 `gemm_qkv` calls, 40.9 GMAC — two thirds of the frame's GEMM arithmetic.**

The gate is not what keeps them out. Three `qkv_weight` shapes exist in the model —
K=64/N=192, K=128/N=384 and K=32/N=96 — and the K=32 one is indeed refused by
`quantise_weight`'s `K % 64`. But **no `gemm_qkv` in a 768x448 frame has K=32**: every one
of the 120 calls is K in {64, 128, 256, 512, 1024} and every one passes. The 32-channel
blocks' weights are in the model and never reach this call at this extent.

| M | N | K | n | kind | MMAC/frame |
|---|---|---|---|---|---|
| 96 | 3072 | 1024 | 16 | bottleneck (ViT) | 4832 |
| 1792 / 1536 | 768 | 256 | 32 | window | 10469 |
| 768 / 576 / 512 / 384 | 1536 | 512 | 32 | window | 14093 |
| 6656 / 6144 / 5824 / 5376 | 384 | 128 | 24 | window | 7078 |
| 24000 / 23040 / 22400 / 21504 | 192 | 64 | 16 | window | 4470 |

**What they cost, measured where they are spent.** `work/qkv_frame_probe.py` records the
projection twice — same inputs, same targets — and takes the difference: 43.0 -> 49.5 ms.
So the 120 calls are **6.5 ms of a 43 ms frame**, 15 %. An estimate from the shapes and a
throughput figure said 1.46 ms and, halved for optimism, 0.7; that estimate was wrong by
nine times, which is why the measurement came first.

### The scale that survives the normalise is the row's, not the column's

The integer GEMM writes `acc * a_scale[row] * b_scale[column]`. A row's activation scale
multiplies all 32 channels of a head by one number, so the cosine normalise divides it
straight back out. A column's does not, which is a real difference — but it is not an
error, because `round(W[:,c] / s_c) * s_c` is `W[:,c]` again either way, and the per-column
grid is the finer of the two. `work/qkv_scale_spread.py` measures both against the half
product the frame computes today, over every QKV weight in the model:

| weight scale | worst mean angle | worst p99 |
|---|---|---|
| **per column (what ships)** | **0.517 deg** | 0.684 deg |
| one per head of 32 | 0.980 deg | 1.141 deg |

Half a degree, and per-head is 1.4x to 1.9x worse. So the weights stay per-column, as they
are everywhere else on this path, and nothing about the normalise needed changing.

### The kernel: the same 8 KB, written over in place

`qkv_epilogue.glsl` wants a float stage; the integer GEMM's stage is `int32_t`. A second
8 KB shared array would take the workgroup from a 16 KB share of the core's shared memory
to a 32 KB one and halve how many fit — for *every* integer GEMM in the graph, not only
the ones using this epilogue, and `notes/improve-shared-memory.md` is what that costs.
Instead the dequantised floats are written back over the integers they came from, one word
for one word, and read back through `intBitsToFloat` — `QKV_READ` in
`qkv_epilogue.glsl`, defaulting to the float read the fp16 kernel already does.

The two scale vectors have nowhere to go: in this mode `c`, `d` and `residual_cos` are the
three targets. They take the GEMM's stride words at offsets 80 and 88, which this kernel
never reads — the same reuse `xmx_rec_qkv` already makes of offset 80 for its fifth
pointer. `xmx_rec_gemm_int8_qkv` fills them; `Runtime.gemm_int8_qkv` wraps it.

The window blocks pay two passes the float path does not: the integer kernel has no window
gather, so they partition first and then quantise. That is most of why 6.5 ms of GEMM
yields 1.9 ms rather than 3.

### What it is worth

Three alternating runs of `work/int8_frame_cost.py 768 448`:

| run | QKV=0 min | QKV=0 median | QKV=1 min | QKV=1 median |
|---|---|---|---|---|
| 1 | 43.23 ms | 43.49 ms | **41.29 ms** | **41.31 ms** |
| 2 | 43.23 ms | 43.49 ms | **41.17 ms** | **41.39 ms** |
| 3 | 43.13 ms | 43.29 ms | **41.33 ms** | **41.58 ms** |

**1.9 ms, 4.5 %**, and no interleaving: every "on" run is under every "off" run. A second
set of runs agreed (43.21/43.20/43.18 against 41.36/41.48/41.28).

Split by family (`work/qkv_frame_split.py`, `work/qkv_quality_split.py`): converting only
the bottleneck's 16 is worth 0.65 ms and costs 0.69 points of effect; only the window
blocks' 104 is inside the noise for time and costs 0.37 points; both together are worth
1.9 ms and cost 2.82 — more than the sum of its parts, in both directions, which is what
twelve blocks of compounding attention does to an error and what sharing one pipeline does
to a dispatch stream. Only "both" is worth shipping.

### What it costs the picture

`work/int8_quality.py`, the real capture, against the float path:

| | mean | as % of effect | median | p99 | worst | over 2/255 |
|---|---|---|---|---|---|---|
| integer path as it was | 0.7423 | 14.35 % | 0.798 | 4.294 | 12.918 | 13.03 % |
| **plus the QKV projection** | **0.8884** | **17.17 %** | **0.926** | **4.850** | **12.389** | **19.05 %** |

+0.146 of 255 on the mean, +0.56 on p99. Judged against the trade the project already
takes: the window blocks' down and out projections cost +4.25 points for 2.6 ms, 1.63
points per millisecond. This costs 2.82 points for 1.9 ms, **1.48 points per
millisecond** — a better rate than what is already on by default, so it is on.

### State

- Switch: **`NR_INT8_QKV`, default "1"**, under `NR_INT8_PROJECT` like the path's other
  switches, so a plain `test_resident.py` is still 415 passes. `NR_INT8_QKV=0` takes it
  back.
- Gated on the native build exporting `xmx_rec_gemm_int8_qkv`, so the daemon's current
  `work/libxmx.dll` keeps the float path rather than failing to load, until the release
  build (`tools/build_msvc.bat`, `tools/build_shaders.sh`) replaces it.
- Validated: `src/gpu/test_gemm_int8_qkv.py`, 14 cases bit-identical to the float path on
  operands exact on both grids — both normalisations, every shape the frame asks for,
  guards past all three targets. The ordinary integer GEMM is unchanged (6 shapes
  bit-exact) and `test_resident.py` is 415 passes with the switch off.
- Not built into `work/libxmx.dll` or `work/gemm_staged_int8.spv` here: the daemon holds
  both open. `work/build_qkv_test.ps1` builds `work/_test_libxmx_qkv.dll` and
  `work/_test_int8_qkv.spv`, which everything above was measured through.
- What is left: the two passes a window block pays before its integer projection. Folding
  them into one — partition and quantise in a single dispatch — or giving
  `gemm_staged_int8.comp` the window gather `gemm_staged.comp` has would be worth another
  millisecond or so at no accuracy cost.
