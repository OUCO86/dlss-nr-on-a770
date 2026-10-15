# B：按 Mochi 形状重写 —— 立项方案（2026-10-15，分支 `mochi-rewrite`）

> 状态：**待用户确认后才动代码**。本文所有数字都有实测出处（见"证据"节）。

## 0. 为什么走这条路（一句话）

局部刀已实测全部耗尽（合并=0、e4m3 容器=负、BN=64 撞 epilogue、向量化=已做、
persistent=无空闲发射槽）。帧的问题不是任何单核慢，是 **691 趟小 pass 互相之间
搬进搬出**：每核 300-940 次 register 搬运、window_block scratch 12KB（spill 实锤）。
Mochi 用 52 个 pipeline / ~150 趟做同一张网络。差距 24× 是结构性的（前辈 26.11）。

## 1. 参考读到的 Mochi 真实形状（全部本地存证 refs/DLSSNR-AMD/）

- **52 个 pipeline**（`shaders/pipelines.json`），名字即特化：
  `fswin32/64/128/256` = **一个窗口块一个 megakernel**（QKV+norm+attention+
  outproj+FFN expand+contract+residual+downsample 全在里面，按通道数编译四份）；
  `fswinds*`=带 downsample、`fswinfusedup*`=带 upsample、`gemmvqkvnorm*`=ViT 的
  QKV+norm 融合、`gemmvact`=激活量化融进 producer。
- **静态计划表**（`core/nr_native_plan.cpp`，79 行）：`records[]` 19 列一张表，
  网络构建时把每层形状/tokens/grid 一次算好，运行时按表 dispatch，host 每帧 0 工作。
- **趟间链**（`shaders/nr_chain.glsl`，NR_CHAIN/NR_TCHAIN）：dispatch 之间的 barrier
  换成计数器——生产者 signal、消费者按 tile 等待，**上一趟还在排空时下一趟已发射驻留**。
  防死锁论证在注释里（按 launch 顺序，等待者不会占住生产者需要的槽）。
- 反汇编 Mochi 真实 spv（g_fswin32/64/128/256，用 src/bench/spv-memops.py）：
  **SHARED 0**、coopmat-mma 站点 4、register 搬运 11764-21538（大量本地数组，
  RADV 把它们放 LDS）。⇒ Mochi 的窗口块**不做显式 shared staging**，
  中间值全在编译器管理的寄存器/LDS 里——这正是它没有 quant/residual 独立趟的原因。

## 2. 核心洞察：为什么 Mochi 没有 quantize 趟，而我们今天撞的所有墙都同源

我们的 tile（BM=64/BN=32、窗口=64 token）**不拥有完整的行**：一行 hidden=128 列
散在 4 个列块 → 行 max 要跨 workgroup → 量化只能独立成趟（quantize_row 281 次）。
Mochi 的 workgroup **拥有一个完整窗口 = 所有 token × 所有列** → 行 max 天然在手
→ 量化折进 producer epilogue，**零独立趟**。

BN=64 撞墙、fold 撞行 max 墙、e4m3 撞事务宽度墙——**三堵墙同一个根因：tile 太小，
不拥有行**。把 tile 放大到"一 workgroup 一窗口块"，三堵墙一起消失。
这就是 B 的全部理由，也是它和今天所有局部刀的本质区别。

## 3. 分期（每期独立可验证、可回退，铁律⑤一次一个变量）

### B1 窗口块 megakernel（第一刀，最大单体）
把 `window_block`（9.04ms/10 趟）+ `ffn_fused`（7.75ms/10 趟）+ 它们之间的
`gemm_int8_qkv`（12.54ms/60 趟）+ `quantize_window`（0.57ms）+ `window_attention`
（3.89ms/52 趟）**合成一趟 per-block**：一个 workgroup 拥有一个 8×8 窗口，
QKV→norm→attention→outproj→FFN expand（gate+e4m3，行 max 在 shared）→contract
→residual→publish，中间值不落 global。
- 判据：`test_window_block.py` + `test_ffn_fused.py` + `test_glue.py` 逐字节，
  帧级 `test_frame_execution`，ledger 对照。
- 几何与位序：保持现有 mma 的 K 步顺序（expand 2×TK16、contract 8×128、
  attention 与 window_block 现状），publish 点不变 → 逐字节可守。
- 显存/shared 预算：Q/K/V 8KB + hidden 64×128×2B=16KB（或 e4m3 8KB）+ 工作区，
  32-48KB/workgroup——ffn_fused 现在已用 32KB，量级相同。
- 回退：`NR_FUSE_BLOCK=0` 走旧路径（沿用 fuse_window_block 的 flag 惯例）。
- 预期：这五族 33.8ms → ~20-24ms（消掉族间 global 往返 + 281 里的窗口 quant 部分
  + 60 趟 qkv gemm 的 dispatch 成本）。device 44.75 → ~32-35。

### B2 ViT/全局块 megakernel
`attn`/`gemmvqkvnorm*`/`gemmvact`/`ffwd3` 同款融合 global 块与 ViT 块
（row/5、gemm_int8 5.02、相关 quant）。预期再 -4-6ms。

### B3 上下采样融合（`fswinds*`/`fswinfusedup*` 对应）
downsample/upsample + residual 融进相邻块（前辈 marker：`ds_fuse 15`、
`ups_fused_mode 2`）。预期再 -2-3ms。

### B4（可选，最后）趟间计数器链（NR_CHAIN/NR_TCHAIN 移植）
消 dispatch 发射/排空间隙。今天 mode-3 barrier 实测只值 1.78ms，B1-B3 后趟数
已大降，这刀的边际收益要重新评估后再决定做不做。

### 目标
B1-B3 后 device ~22-26ms（960x544），wall ~31-35ms，~30fps。
再往下的地板是矩阵功本身（~5-8ms）+ 不可约激活流量。

## 4. 风险登记（诚实）

1. **寄存器压力**：Mochi 是 AMD（256 VGPR），Xe-HPG GRF 128×256b。megakernel 在
   A770 上会 spill——但前辈 fill 实验证明发射口已饱和，spill 走 L2 的代价要实测；
   B1 的 shared 方案（显式 staging）是保守版，先按我们的 LDS 文化写，不做 Mochi 的
   "全寄存器"版。
2. **逐字节红线**：融合改变 mma 调度顺序的风险——用"保持 K 步顺序+publish 点不变"
   的构造性方法（window_block 已用此法成功融合三趟，有先例）。
3. **工作量**：B1 是新 kernel ~800-1200 行 GLSL + 计划器改动 + 测试扩展。
   按前辈惯例（fused 系列）每期一个 commit、一个 flag、一次游戏内验证。
4. **主线保护**：本分支所有实验不进 `windows`；B1 游戏内验证通过才谈合并。

## 5. 证据索引

- 局部刀全灭：`notes/improve-int8-bottleneck.md`（2026-10-15 两节）、
  `notes/frame-ledger-a770.md`（拆核+字节账+宽度账三节）。
- Mochi 形状：`refs/DLSSNR-AMD/{shaders/pipelines.json, core/nr_native_plan.cpp,
  shaders/nr_chain.glsl}` + `refs/optiscaler/pkg/ta_v1.11.0/dlssnr-amd/shaders/g_fswin*.spv`
  （反汇编经 `src/bench/spv-memops.py`）。
- 24× 差距分解与"按 Mochi 形状做"拍板：`notes/optiscaler-bridge.md` 26.4-26.11、27.1。
- 帧内 20 趟大核分段：`src/bench/window_block_probe.py`（两序一致）。

## 6. 寄存器压力实测（用户要求：写 megakernel 之前先测上限，2026-10-15）

探针 `work/reg_pressure_probe.comp`（staged int8 骨架 + NACC 个同时存活累加器，
每个配不同 fb 防 CSE 折叠；每 NACC 独立进程——管线每进程只建一次，前辈教训），
经 XMX_PIPELINE_STATS 读驱动自己的 scratch 报告 + device time（32640x64x1024）：

| NACC | Scratch | ms | GF/s |
|---|---|---|---|
| 2 | 0 | 0.299 | 14318 |
| 4 | 0 | 0.328 | 13038 |
| **8** | **0** | 0.334 | 12805 |
| **12** | **0** | 0.422 | 10146 |
| **16** | 8192 | **1.735** | 2466 ← 悬崖 |
| 20 | 10240 | 3.926 | 1090 |
| 24 | 12288 | 5.940 | 720 |
| 28 | 14336 | 7.853 | 545 |
| 32 | 16384 | 9.776 | 438 |

**结论（B1 设计约束，量化）：**
1. **安全线 = 同时存活 ≤12 个 8x8 累加器（scratch 0）；16 开始悬崖（4.1× 减速），
   每 +4 累加器 +8KB scratch、速度再腰斩。** 与前辈 int8-residual 悬崖
   （xmx_shape.h:78-85，8 累加器+1 epilogue 变量 → 20992B → 3×）同源吻合。
2. **Mochi 的"全寄存器"形态在 A770 上不可复制**：块级 megakernel 若让
   QKV(4)+attn(8)+outproj(4)+FFN(8+8) 同时存活 = 20+ → 直接 4-10× 减速，
   比它省下的 staging 往返贵得多。**保守版（阶段间用 shared 交接、每阶段 ≤12）
   不是"效能没他好"，是这台硬件上唯一不进悬崖的形态。**
3. B1 各阶段峰值存活核对：QKV acc[4]、QK^T acc[8]、attnV/outproj acc[4]、
   FFN result[8]（跨 chunk 存活）+h[8]（chunk 内临时，与 result 有顺序依赖可复用）
   ——**全部 ≤12，安全区内**。设计红线：任何新阶段不得让 >12 个累加器同时存活；
   FFN 的 h 必须复用 result 的寄存器（写码时验证 scratch=0）。
4. 探针注意：NACC≥16 时 fb[NACC] 也占寄存器（真实核每阶段只有 2-4 个 fragment），
   所以悬崖位置对真实核可能略靠后（14-18 之间），但"12 安全、16 危险"的
   设计约束按保守值执行。
