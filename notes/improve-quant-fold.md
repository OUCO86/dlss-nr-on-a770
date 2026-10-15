# C1：把 quantize_row 折进 producer —— 结构分析（2026-10-14）

Task #69 的第一刀。分析基于 960x544 的新 plan（448 个 `xmx_rec_quant`，
`work/plan_960x544.json`），方法是回溯每个 quant 的 source 最近一次被哪个
recorder 写出（跳过非 recorder 步骤，所以 312 个的"距离"是 2）。

## 结论一：按 buffer id 做全局数据流会失真

scratch buffer 跨 block 复用，同一个 id 一帧里被写读几十次。"source 还有没有
别的 float reader"这种全局判据在复用下永远是"有"，会把所有折叠点误杀。
可用的判据是**局部相邻性 + tile 几何**。

## 结论二：折叠的硬障碍是行 max，不是 pass 相邻

`quantize_row.comp` 一 warp 一行，行 max 全行在手。producer（GEMM）的 workgroup
只有 `XMX_STAGED_BN=32` 列宽（`xmx_shape.h:75`）：

- **N=32 的 producer：一行就在一个 workgroup 手里，行 max 免费 —— 可折。**
- N=64/128/256 的 producer：一行分 2-8 个 workgroup，行 max 要跨 workgroup 聚合
  （atomic 或第二趟），折叠不再白捡。

Mochi 为什么能在 kernel 里内联量化（`shaders/pipelines.json` 的 `NR_QUANT_MODE=4`、
`persist_df/ds/up/strag`）：他们的 FFN/attention kernel 是 **persistent-CTA 形状，
一个 workgroup 吃整行/整块**，行 max 天然在手。那是 C4 的结构，不是 C1 的补丁。

## 结论三：可折簇（N=32 producer → 它的 quant）

| producer 家族 | quant 数 | 说明 |
|---|---|---|
| `xmx_rec_gemm_window_int8_residual` | 88 | out 投影 N=32，行在单 workgroup 内 |
| `xmx_rec_gemm_int8_batched`（cols=32 的两簇） | 40 | 8160x32x128(24) + 32640x32x128(16) |
| `xmx_rec_gemm_int8_residual`（N=32 部分） | ~16 | window ffn down |
| 合计 | **~144 / 448** | 约 1/3 的量化税 |

按 `frame-ledger-a770.md` 的 2.43 ms@768x448（448 个）折算，960x544 下这 144 个
约 **0.8-1.1 ms**，外加消掉 144 次 barrier 与 144 个 packed scratch 的分配。

不可折的 304 个：source 是 cols=64/128/256 的 producer（expansion、group project、
first projection）或早期写、多处读的 buffer（value16/features 类，128 个"无近邻"）。

## 方案（等确认）

C1a（本刀）：给 `gemm_staged_int8` 加一个 "int8 publish" epilogue 变体——
`publish` 时不写 f16/e4m3，改算行 max（N=32 在手）→ 写 int8 packed + row scale。
Python 侧对 N=32 的 int8 producer 调用点删掉后置 quantize。判据：折叠前后
packed+scale 逐字节一致（照 `test_gemm_int8_batch.py` 的路子），画质重测。

C1b（下一刀，若 C1a 立住）：cols=64 的两簇用"行内两次 tile + atomicMax 局部聚合"
或干脆 persistent 行形状——那时再测值不值。

C4（远期）：向 Mochi 的 persistent-CTA 收敛，一次吃掉全部 448 个 quant。
