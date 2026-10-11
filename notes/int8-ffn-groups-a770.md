# The grouped feed-forward on the integer path

2026-10-11. The branched and split blocks' per-group feed-forward — 130 of a frame's
products and 8.4 of its 34.7 ms on the device — was on the float path for a reason that
was measured, and the measurement was misread.

## The reason it was float, and what it was really saying

`src/bench/ffn_int8_probe.py` (2026-10-10) compared three routes and concluded the
integer path lost by 0.26 ms:

```
  groups     fp16/b     fp16/1       int8
       4       9.55      14.92       9.81
```

But the `int8` column was `groups` separate `gemm_int8` calls, because the integer GEMM
had no group index, and the `fp16/b` column was **one batched call**. The integer path
was not losing to the float path; it was losing *the batching* to it, and paying for it
twice over. The same table contains both halves of the correction:

* unbatched against unbatched, integer wins by **1.55x** (median over the 17 shapes,
  1.08x to 2.44x)
* batching the float call is worth **5.37 ms** of 14.92

Those two are independent, so they should multiply. They could not, because one of them
was not available on the integer path at all.

## What was built

`gemm_staged_int8.comp` takes the group from `gl_WorkGroupID.z` and its row strides from
past the 128 push bytes every Vulkan device owes:

* `libxmx.c` — `struct push` appended to 160 bytes. The 128 below are full: this kernel
  spends offsets 80 and 88, every other GEMM's `lda` and `ldc`, on its two scale
  vectors, because the QKV epilogue needed two more pointers than the block had room
  for and the grouped feed-forward was not on the integer path when it was laid out.
  The Arc's limit is 256 (`vulkaninfo`, measured on both adapters), so appending costs
  nothing and no earlier offset moves.
* `xmx_rec_gemm_int8_batched` — a separate recorder rather than a change to
  `xmx_rec_gemm_int8`, so the call every other integer product makes is untouched.
  `batch=1` with no strides or leading gives every offset zero, so the two agree bit for
  bit; `src/gpu/test_gemm_int8_batch.py` checks that, in 18 cases, against both `batch`
  separate products and exact integer arithmetic in numpy.
* `nr_resident.quantise_grouped_weight` — one grid per group, laid out the way the
  kernel reads them: group `g`'s matrix at `g * cols * inner`, its scales at `g * cols`.
* The row scales are shared unless told otherwise (`scale_stride=0`). A group's rows
  are a *column slice* of a wider activation, so a grid per group would need a partition
  first — a pass this change exists not to pay for. One quantise over the whole
  activation, one scale per row, every group reading it.

## Which shapes take it

`grouped_integer_pays(rows, cols, inner)`, from `work/probe-ffn-int8-batched.txt`, which
times all seven shapes the frame groups, four routes, alternating in one process:

```
    1344 x 128 x 256   -34.1 us        1344 x  32 x 128    +6.3 us
      384 x  64 x 256   -12.2 us         384 x 256 x  64    +9.6 us
     5376 x  32 x 128    -4.6 us       21504 x  32 x 128   -28.7 us
                                       21504 x 128 x  64   -82.2 us
```

The two that lose are shallow products over too few rows: at 1344 rows a 32-column
group cannot give back what the quantise costs, and at 21504 the same 32 columns win by
28.7. So it is not narrow N on its own. `21504 x 128 x 64` is the largest win in the
frame and is 64 deep — a blanket "K must be 128" gate would have thrown it away, which
is what the first gate did.

Below 64 columns the product needs 5376 rows to pay. 256 columns over 64 does not pay at
any row count the frame runs.

## What it is worth

`src/bench/frame_ledger.py`, 768x448, median of 3 replays:

| | off | on |
|---|---|---|
| device | 34.75 ms / 603 passes | **32.83 ms / 691 passes** |
| tiled/0 (float grouped) | 8.38 (130) | 1.48 (42) |
| gemm/30 (integer) | 9.22 (188) | 13.49 (276) |
| quantize_row | 1.59 (193) | 2.43 (281) |

**-1.92 ms, 5.5 %.** The 88 extra passes are quantises.

Per pass it agrees with the probe: the products that moved went from 87 us to 61 us,
30 % cheaper, against 27 % there. The whole-frame figure is smaller than the probe's
because only the shapes that pay were moved — the two that lose stay float, and so do
the ten single products in the downsample and upsample transitions, which are worth
about 0.05 ms between them at `batch=1` and not worth their quantise.

## What it costs

`work/int8_quality.py` on the real capture, against the same frame with the switch off
(every other integer switch on in both):

```
  the network's own effect          5.5379 of 255
  what this switch moved            0.8271 of 255
  that is                          14.93 % of the effect
```

That is the increment this one switch adds, not the integer path's total. It is larger
than the 4.4 points the window and out projections together cost, and is the thing to
look at in a game before turning it on.

## Status

`NR_INT8_FFN_GROUPS` defaults to **0**. Nothing a game runs changes until it is set and
the picture has been looked at. It is not wired into `nr_settings.json` for live
switching: unlike the other integer knobs it decides how the weights are quantised, so
it cannot move between frames the way `int8_window_fuse` does.

It is in `graph_key` (bit 27), which it has to be: it changes which passes a frame
records, and a graph built for one setting and replayed under the other would be the
silence this project has been bitten by before.

## Left over

42 float products remain, 1.48 ms:

* `1344 x 32 x 128` (16) and `384 x 256 x 64` (16) — measured to lose, left float
* ten single products in the transitions — about 0.05 ms in total, not worth a quantise

`record_split_feed_forward`'s first projection, `384 x 512 x 512` over 16 blocks, was the
largest single win in the frame at -63.6 us each and is **not** grouped: it takes the
integer GEMM as it always was, with no batch. It is part of this switch and accounted
above.

## 🚩 未修 bug：游戏里这个开关根本不会打开（2026-10-11 发现，用户要求先只加日志）

`xmxres.Runtime.__init__`：

```python
self.int8_ffn_groups = (self.int8_project
                        and os.environ.get("NR_INT8_FFN_GROUPS", "0") != "0"
                        and hasattr(self.lib, "xmx_rec_gemm_int8_batched"))
```

`int8_project` 在构造时是 **False** —— `NR_INT8_PROJECT` 代码默认 `"0"`，游戏里是 daemon
读 `nr_settings.json` 的 `int8=1.0` 之后才打开，走 `nr_frame.py:526` 的
`self.runtime.int8_project = on`，**只赋这一个字段，`int8_ffn_groups` 不重算**。

→ 离线基准能生效（`frame_ledger` 自带 `NR_INT8_PROJECT=1`，构造时就是 True，所以
34.75 → 32.83 ms 是真的），**游戏里永远 False**。
2026-10-11 18:3x 那一局因此跑的还是老图：`gpu 0+38+0`、帧时间 40 ms，与基线一字不差；
用户"感觉可以" = 基线的观感，不含这个开关。

教训：离线基准自己设了 `NR_INT8_PROJECT=1`，而游戏靠 `nr_settings.json`，
**两条路的开关时序不同** —— 凡"由另一个开关门住"的开关都要检查这个。

### 修复（改天，别现在动）
1. `xmxres.Runtime.__init__`：把不依赖 `int8_project` 的那半单独存
   `self._ffn_groups_wanted = env != "0" and hasattr(lib, "xmx_rec_gemm_int8_batched")`；
   `self.int8_ffn_groups = self.int8_project and self._ffn_groups_wanted`。
2. 加 `Runtime.set_int8(on)`：同时更新两个字段，返回是否变化。
3. `nr_frame.py:526` 改调 `self.runtime.set_int8(on)`，别直接赋值。

### 已加的日志（2026-10-11，仅观测，不改行为，commit 待做）
- daemon 启动：`runtime options` 末尾多 `NR_INT8_FFN_GROUPS=<0|1>`，紧跟一行
  `grouped feed-forward: NR_INT8_FFN_GROUPS=<env> in the environment, switch on|off (integer projections on|off at startup)`
- 首帧 int8 打开后：`settings: grouped feed-forward on the integer grid: on|off`

修 bug 前这两行会显示 **env=1 但 switch=off**，那就是 bug 本身的证据。
