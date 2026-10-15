# The eight global blocks survive int8, and the bigger the frame the better

`notes/phase23-integer-weights.md` closed the integer question in 2026-09-09 and closed it
correctly, on two grounds. Cooperative-matrix config 4 is `sint8 x sint8 -> sint32`: both
operands integer, no mixed mode, so integer weights force integer activations. And the
published activations carry up to **180 000x** of dynamic range, where a per-tensor int8
grid rounds 21.5 % of the non-zero values on level `l1` away entirely.

Both facts are still true. What was never measured is that they are facts about the
**whole** graph, and the graph is not uniform.

## Why the bottleneck is a different proposition

`src/bench/int_activations.py`, re-run unchanged, prints a gradient rather than a verdict:

| level | int8 rounds to zero | relative error | against E4M3's 6.25 % step |
|---|---|---|---|
| l1 | 21.5 % | 31.95 % | five times worse |
| l2 | 4.2 % | 10.10 % | worse |
| l3 | 2.1 % | 5.96 % | level |
| l4 | 0.9 % | 3.15 % | twice as fine |
| l5 | **0.4 %** | **1.59 %** | **four times as fine** |

The graph is already built around a 6.25 % relative step, taken at roughly a hundred E4M3
publishes between input and output. At `l5` an int8 grid is *finer than that*. `phase23`
measured `l1` and stopped, which was the right thing to do for an all-or-nothing question
and the wrong thing to conclude about a part.

Blocks 31-38, the ViT-1D bottleneck, sit at that end. Counted from the logical shapes
rather than quoted: **100 663 296 of 145 755 123 parameters, 69.1 % of the model**. They are
also the small-M, large-matrix GEMMs where config 4's doubled K removes the most
instructions — 1.30x to 1.87x on those exact shapes, measured on this machine.

So the three things line up: the blocks that hold most of the weights are the blocks whose
activations tolerate int8 and the blocks where int8 pays best.

## What it costs, on real frames

`src/bench/int8_bottleneck.py`. Every 2-D weight of blocks 31-38 is rounded onto an int8
grid per output channel and back; the 1-D tensors — gates, `attn_scale`, the transition
scalars — are not GEMM operands and are untouched. Judged the way this project judges, as a
share of the effect the network exists to produce, not as a share of the head's sd:

| frame | extent | the effect | int8 damage | share | worst |
|---|---|---|---|---|---|
| Cyberpunk 2077 | 1920x1080 | 6.03 L | **0.29 L** | **4.8 %** | 14.3 L |
| Cyberpunk 2077 | 1280x720 | 6.48 L | 0.45 L | 6.9 % | 15.3 L |
| a test image | 256x512 | 5.32 L | 0.80 L | 15.0 % | 8.9 L |

Levels of 255. Each row carries a control: the same configuration rendered twice differs by
**0.000 L**, so the damage column is the quantiser and not the machine.

And the damage is not a haze over the picture. At 1080p:

| | int8 moves | the network itself moves |
|---|---|---|
| above 1 level | 11.2 % of pixels | 99.6 % |
| above 4 levels | **0.157 %** | 49.8 % |
| above 8 levels | **0.003 %** | 22.8 % |

The network changes half the frame by more than four levels. int8 changes one and a half
pixels in a thousand by that much, and 62 pixels out of two million by more than eight.

## The trend is the useful part

15.0 % at 256x512, 6.9 % at 720p, 4.8 % at 1080p. **The cost falls as the frame grows.**
The bottleneck's output is raised back through five upsamples and blended with skip
connections carrying the full-resolution detail; the more fine detail the skips carry, the
more they dilute an error made at 1/32 of each axis. A first reading of this taken at
256x512 gave 15 % and was quoted as the answer for a day. It was the answer for a frame
nobody renders.

## What this does not say

- **Weights only.** A real config-4 kernel quantises the activations too. That half was
  measured on the CPU reference at 320x320 and at 256x512, where it added 0.4 points
  (15.3 % -> 15.7 %) — near enough to free. It has **not** been measured at 1080p and
  cannot be until the kernel exists.
- **No speed was measured here.** The prize is inferred: GEMM is 216 ms of 488 at 720p, the
  bottleneck is part of it, and the integer path is 1.3-1.87x on those shapes. Call it
  under a tenth of the frame on this iGPU. `phase23`'s "it would buy nothing anyway" rested
  on traffic arithmetic from before FFN batching and is not re-checked here.
- **The discrete case is an expectation, not a result.** On a card with five times this
  machine's bandwidth the passes that `phase45` measured at the memory ceiling shrink and
  GEMM becomes a larger share of the frame, so a GEMM-only optimisation should pay more
  there. There is no discrete GPU here to show it.

## Measured again, 2026-09-26: the activations, the live extent, the kernel

**The activations cost almost nothing, at every extent.** `int8_bottleneck.py
--activations` rounds the A operand of each of the four weight GEMMs of blocks 31-38 onto
an int8 grid per row before the GEMM — config 4's input, to within half's 2^-11 — on top
of the weights:

| frame | extent | weights only | weights and activations |
|---|---|---|---|
| Cyberpunk 2077 | 1920x1080 | 4.8 % | 5.0 % |
| Cyberpunk 2077 | 1280x720 | 6.9 % | 6.7 % |
| a test image | 256x512 | 15.0 % | 15.5 % |

**The live extent is where it costs most.** 640x360 at render scale 0.5 hands the network
a 320x180 frame, padded to 320x320 (`--size 320x180`). Eleven frames — six DoA5 fights at
1080p, three at 720p, both Cyberpunk frames — with weights and activations on int8: **5.5
to 15.1 % of the effect, 9-13 % on most**; 0.2-1.0 levels of 255 on average, a p99 of 1.6-5
levels, the worst pixel 5-14. Weights alone, 5.6-13.1 %. The trend above holds at the small
end too: the smaller the frame, the larger the share — and the live extent is the smallest
frame there is.

**The kernel, `gemm_staged_int8.comp`**: the staged GEMM with int8 tiles and a 64-deep K
step (two config-4 multiply-adds), the weights stored transposed so a B fragment is read by
column, the scales applied to the exact int32 accumulator in the epilogue — bit-exact
against numpy on six shapes (`test_gemm_int8_staged.py`). Against the FP16 staged kernel on
the bottleneck's shapes, eight copies of the weights rotated so they come from memory as in
a frame:

| tokens | FP16, a block's four GEMMs | int8 | |
|---|---|---|---|
| 64 (a 320x320 network) | 824 us | 546 us | 1.51x |
| 256 (1280x768) | 1857 us | 1309 us | 1.42x |

Per shape 1.23x to 1.75x, the most on the feed-forward's projection (K = 4096). Applied to
the in-frame FP16 times, that is about 1.5 ms of a 25 ms graph at 320x320 and 2.8 ms of
145 at 1280x768, before the activations are quantised — a pass per GEMM operand, or a
per-row maximum carried by the pass before. Not in the graph yet: its epilogues (the gate
and E4M3 publish, the residual, the QKV epilogue) are the FP16 kernel's and would have to
be shared with it.

So the trade at the live extent, where speed matters most, is about 5 % of the graph for
about a tenth of the effect.

## Two silent no-ops, and what caught them

Both attempts at this experiment first produced a perfect result from doing nothing. The
CPU run reported identical heads because `progress` was never passed to `forward`, so the
hook never learned which block it was in. The resident run reported zero damage because the
weight filter tested `dtype == float16` and `load_logical` returns float32.

In both cases the thing that caught it was a counter printed beside the result — *how many
matrices were quantised* — and in both cases the result without it was a confident 0.0 %.
`notes/HANDOFF.md` already carries the general form: a test that exercises the mechanism
around the thing under test proves nothing about it. The specific form is worth adding:
**an experiment that can do nothing must report how much it did.**

## 2026-10-15 C1b 开工发现（BN 参数化 + 账本重算）
- 帧账本(960x544, 493 calls/691 pass)：quantize_row 现仅 **3.09ms/281 次**（旧 float 时代是 14ms）。
  **前人否决"读取侧融合"是 14ms 时代测的，账已变**——但融合本身仍慢，因为读取侧重读代价：
  A 被 N/BN 个列块反复读，每次重量化。BN=32 时 N=64→重读 2×，这才是 fused 慢的真因。
- **BN=64 解锁点**：N≤64 的 GEMM 只有一个列块 → A 读 1 次 → 重读罚消失。
- 已安全参数化 gemm_staged_int8.comp 的 BN（`#ifndef STAGED_BN 32`）：默认 64x32 构建
  **逐字节 == 在跑的 spv**（cmp 通过）。wide 变体 -DSTAGED_BM=32 -DSTAGED_BN=64 编译过、
  **驱动报告 Scratch=0**（与默认同，寄存器不溢出）、shared 同 8192。
  ⚠ 但 B/A 的 fill 映射(line 154 `bn=thread/4`)仍按 BN=32 硬编码，wide 版只填了 32/64 列，
  要补 fill 逻辑才能正确跑——这是下一步的实际工作量。
- 更干净的落点其实是**写入侧折叠**：expand GEMM(nr_resident:559) 现写 hidden16(fp16)+
  EPI_GATE_E4M3，随后 record_project_residual→quantize_row(:781) 再读回量化。让 expand
  直接出 int8+行 scale，省掉 :781 那次 quant（hidden 宽 128/256，是大 quant）。
- 帧里还有 18 次 gemm/0(0.71ms) 是没转 int8 的小 GEMM（downsample/upsample），可一并转。

## 2026-10-15 e4m3 容器实验：基础设施已落地，但**不省时间**（负结果，已定案）
- 落地：quantize_row.comp 加 flag 0x8000000 的 e4m3 字节读分支；libxmx.c 新导出
  `xmx_rec_quant_e4m3`；xmxres 新 `quantize_row_e4m3`。新 dll 已重建（115 导出），
  备份 `libxmx.dll.bak-20261015-e4m3pre`、`quantize_row.spv.bak-20261015-e4m3pre`。
- 正确性：`test_quantize_e4m3.py`（新）——同一批 e4m3 网格值，字节容器与 half 容器
  两条设备路径 **packed 与 scale 逐位相同**（0 differ），4 形状全过。地基1 亦真
  （e4m3→fp16→fp32 逐位还原）。
- 无回归：half 热路径 0.0596 vs 旧 spv 0.0581（噪声内）；整帧 44.85 vs 44.75（噪声内）；
  `test_frame_execution` + `test_glue` 全 bit-exact。**分支保留但无站点调用**（死代码存证）。
- 性能：字节读比 half 读**慢 5-14%**，且撑到 133MB（远超 16MB L2、真 DRAM-bound）仍慢 5%。
  两种解码都试了：算术重建（8 exp2）-14%，256 项 shared LUT（8 LDS + 填表 barrier）-13%。
  half 路径每 8 值只花 4 次 unpackHalf2x16——省下的访存不够付解码。
- **由此纠正帧字节账的解读**：quantize 族标 ratio=1.0"BW"是误读。3MB/pass ÷ 0.011ms =
  273GB/s 看着撞 291 屋顶，但省一半读字节反而更慢 ⇒ 它实际是 **ALU/发射受限**，
  数据本就 L2 热（producer 刚写）。省字节无效；要省时间只能省每元素算术，或**消掉这个 pass**。
- 推论：C1b 的真正形态仍是 fold 进 producer（消 pass），不是换容器。而 fold 的障碍是
  行 max 需整行（BN 限制）+ qkv_epilogue 写死 32 列一 head——两条都已实测撞墙。
  下一刀因此转向：(a) 攻 quantize 的 ALU（SIMD 化 round/clamp，收益 ~1ms 上限），
  或 (b) 转 C 结构刀（persistent GEMM，攻 ratio 21-26 的大头）。

## 2026-10-15 e4m3 慢的真机制（探针分离，推翻"字节账"分母）
三方对照（同一 e4m3 字节 load，只换 decode）：exp2 -16% / unpackHalf -17% / float(b) -18%。
**decode 从最贵换到免费，时间恒定 0.069** ⇒ 惩罚不在解码 ALU。half(16B load)=0.059 vs
e4m3(8B load)=0.069，唯一差 load 宽度 ⇒ **成本由访存事务数决定，不由字节数决定；
8B 窄 load 每字节比 16B 宽 load 贵——搬得少反而慢**。
- 统一解释全帧反常：合并零收益、GEMM ratio 25×、e4m3 省字节反慢——**全帧是事务数/发射
  受限，非带宽受限**。frame-bytes.py 用"字节流量"当分母是错的，正确分母=load/store 指令数+发射。
- quantize pass 已近其结构最优(16B load+unpackHalf)。省时间两条都撞墙且同根因:
  换容器撞 load 宽度墙; fold 消它撞 BN 墙(行 max 需整行, workgroup 只 32 列)。
  **两墙同一根因=workgroup 太小→一行散在多列块→既要独立 quantize、又摊不薄每 pass 固定 load 成本。**
- ⇒ persistent 大核(一 workgroup 拥有整行)同时拆两墙: 消 quantize pass + 减 load 事务。
  C 结构刀是 a/b 的共同根因解，不是并列选项。
