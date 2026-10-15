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

## 7. B1a 设计（2026-10-15 晚，实现前钉死；shared 算术是主约束）

**范围裁定**：完整窗口 megakernel（FFN+attention 一趟）太大；B1a 先做
**ffn_fused 的 int8 模式**——它已拥有"一 subgroup 全行"（16 行 × 全部 32 输入通道 /
128 hidden 列都在手），正是拆掉行-max 依赖墙的形态。等于把 C1b fold + 合并
两个 GEMM + 消 hidden16 往返三件事一次做完，且 kernel 骨架已有（ffn_fused 现
10 趟/7.75ms 逐字节已验证）。

**位序论证（逐字节红线）**：现 int8 路径 = quantize_row(value16) → gemm_int8
(K=32, BK=64/TK=32 → 每 tile 1 个 int32 MMA from zero) → hidden16(fp16, gate+e4M3
publish) → quantize_row(hidden16) → gemm_int8_residual (K=128 = 2 个 BK 块 ×
每块 1 MMA，累加顺序 chunk 递增)。fused int8 模式必须复现：expand 每 tile
1 个 MMA from zero ✓（同 K 同序）；contract 按 chunk 0..3 升序累加进同一 acc ✓
（ffn_fused 现结构就是 chunk 序）。行 scale：quantize 的 peak=整行 max——
fused 里整行都在手，peak 逐元素一致 ✓。**但 hidden 的 peak 要在 contract 前
拿到全部 4 个 chunk** → 必须先把 hidden 全存 shared 再量化 → 预算：

**shared 重排（关键）**：ffn_fused 现 32KB = 16KB weights + 16×1KB(subgroup 的
hidden chunk+输出 stage)。int8 模式：hidden 全行 16×128 halves = 4KB/subgroup
装不下 16 个 subgroup（64KB）。解法：**int8 模式改 8 个 subgroup × 32 行？**
不——ROWS=16 固定。解法 B：**hidden 用 e4m3 字节容器**（16×128 bytes=2KB/
subgroup × 16 = 32KB，正好替换现 hidden-chunk+stage 的 16KB，weights 走 global/L2
非 staged 形态——ffn_fused 注释明说非 staged 形态本来就从 global 读 tiles）。
e4m3 是 publish 后的精确值，quantize 读它解包（unpack 用 LUT？不——这里读侧
只有 1 字节/元素，事务宽度问题在 16B 对齐的 uvec4 批量读下不存在：每 lane
一次 16B=16 个 e4m3，比 8B 探针宽）。**写码时以 scratch=0 + 逐字节门裁决。**

**graph**：NR_INT8_FFN_FUSE=1 时 record_feed_forward 的 expand8 分支改调
ffn_fused(int8 mode)（消 2×quantize + 2×gemm_int8 + hidden16 buffer）。
验证：test_ffn_fused 加 int8-mode 组（对照现四趟链逐字节）；帧级
frame_ledger on/off + test_frame_execution；每特化 XMX_PIPELINE_STATS scratch=0。

**收益预估**：224 个 quantize_row 里 FFN 相关 ~112 个（2×56?按 ledger:
feed_forward:719 站点 46+20+... 数一下）≈1.2-1.5ms + hidden16 往返 ~0.6ms +
dispatch 合并。B1a ≈ **-2ms**；B1b（窗口 attention+FFN 全 megakernel）再 -3-5ms。

## 8. 宽度扫描改写 B1（2026-10-16 01:00，用户观点被证实）

完整表 + 三条读表规则在 `notes/int8-width-sweep.md`。要点：

- **int8 红利由宽度决定，不由引擎决定**：同 8×8 coopmat，宽形状（M≥32640,
  N≥128, K≥128）int8 赢 **2-3.5×**（130560x1024x64: 3.54×）；窄形状（M≤8160,
  K=64）0.8-1.0×。fp16 在 6-7.6 TF/s 撞引擎天花板，int8 到 16-20.5。
- **修正 00:40 的"窄块 FFN 转 int8 净亏"**：那是我的实现开销（bytes[32] 数组
  spill Scratch=960、ROWS=8 固定开销、barrier 密度），不是方向错——同形状
  raw GEMM int8 赢 1.57×。kernel 要修：去 spill（两遍读 shared）、8 subgroup
  x 16 行（4KB+4KB=8KB x 8 = 32KB 正好）、expand 两 chunk 一批（8 累加器，
  不碰 16 悬崖）。
- **B1 的"变宽"具体化**：Mochi 的 tile 常数 gemm_wide_mt 64 / gemm_wide_nt 256
  就是这张表的兑现方式。窗口块 megakernel 每 workgroup 的行块从 8 提到 16-32，
  QKV 的 96 列、FFN 的 128 列以宽 tile 推进 → 从 0.8× 区搬进 2-3× 区。
- **按层选引擎**（grouped_integer_pays 先例）：l1/l2/l3 的 FFN 走 int8 赢
  （1.33-1.77× on contract, expand 用 TK=32 单步），l4/l5 保持 fp16。

B1a 重定义：修 ffn_fused_int8 至无 spill + 16 行块，重测 130560/32640/8160 三形状，
目标 >=1.3x on l1/l2；达成则接帧（NR_INT8_FFN_FUSE 门 + 逐字节对 numpy 参考链）。

## 9. 综合（2026-10-16 01:20）：引擎线关闭，B 修正为"消趟数"单核
今晚四组实测拼出的完整图：
1. **宽 GEMM 已在 int8**（276+60 趟覆盖 N≥96/K≥64 的 2-3.5× 区）。剩余 fp16 全是
   窄/小 M：window_block 内部每 subgroup M=8（扫描 M=640 段已 0.8×，M=8 更糟——
   B1b"窗口块转 int8"被现有数据判死，无需写码）；ffn_fused v2 实测 1.06-1.10×。
2. **Mochi 的宽 tile 不可移植**：gemm_wide_nt 256 = 32 累加器矩阵；压力探针实测
   悬崖 16（scratch 8KB、4.1×）。Xe-HPG 128-GRF 装不下 RDNA4 256-VGPR 的形状。
   Mochi 快 5× 的可迁移部分 = 趟数与搬运，不是 tile 宽度，也不是引擎。
3. ⇒ **B 的便携核心只剩一条：消趟数，引擎原样。** 第一刀 B1'（取代 B1a/B1b）：
   把 quantize 折进 **N=32 的 fp16 producer epilogue**——这些 producer 一个列块
   拥有整行（BN 墙不存在），写 int8+行 scale 喂给本来就存在的 gemm_int8。
   零画质变化、零引擎切换。消 281 趟里 N=32 来源的那批（~150 趟 ≈ 1.5-2ms）。
   machinery 复用 ffn_fused_int8 v2（e4m3 code / shared 量化 / ascale 2M 布局），
   去掉它捆绑的亏本 GEMM 切换。
4. 窗口块 megakernel（原 B1b）降级 B2 可选：消 10 趟间往返 ~1-2ms，v2 已证
   32KB 预算内塞得下整个块。B3=上下采样融合，B4=链计数器，不变。
5. ffn_fused_int8 处置：保留为"换引擎不变宽"的对照存证（scratch 0、结构正确、
   数值待逐字节测试——测试补上作归档，不接帧）。
