# §100 蓝图：从 214ms 到 <48ms 的全面作战图（2026-10-26）

## 🚩🚩🚩 底线（表头，任何一步不可违背——用户 2026-10-26 明令）

1. **数据链路健康是根本，不可碰。** 破坏链路健康，后面做什么都白搭、之前所有工作全部作废。
   - **不出现小 M**：GEMM 走宽 M 大 tile（R8a）；batch 进 grid 维，不拆小 dispatch。
   - **不出现中间量化往返**：int8 直通 + 单一世界；quant 只在 plan 规定处发生；不为省时间引入新量化或放宽 golden 数值标准（rcp-form 这类数值形态改动必须先过 numpy golden 考古，过不了就死）。
   - **不出现额外开销**：CPU 不碰像素路径、无 host pack/download、无多余 launch、无多余 buffer 往返。
   - **每步三关**：39 门 GREEN + 端到端 recorded walk 100.0000% 0 mismatch（vs bk 基线）+ 确定性两遍 100%。任何一关红=当场回滚，不过夜。
2. **照搬的是思路，不是代码。** 前辈的 coopmat/Vulkan 具体实现不能直接搬进 SYCL/ESIMD；可搬的是**结构**（resident、fold、SLM staging、acc-via-SLM）。
3. **每步流程**：先查参考（文件:行）→ 解释参照是什么+打算怎么做 → 动手 → bench 判 → 三关 → 自查违规（小M/中间量化/额外开销/CPU）→ 提交推送 → 用户验收。

---

## 一、主因（已找到，证据钉死）

**不是 GEMM 算术慢，不是 pass 数量多——是每个 pass 的"实现方式"把中间数据甩进 global 再读回来。**

对照（同工具、同 plan、同 691/723 个 pass）：

| | 前辈 coopmat 引擎 | 我的引擎（E1 后） |
|---|---|---|
| 设备时间 | 36.41ms（frame-ledger）/ 48ms（本 box replay 实测） | 214ms |
| pass 数 | 723 | 691（几乎一样！） |
| **每 pass 均价** | **0.050ms** | **0.31ms（6.2x）** |

前辈 frame-ledger 的家族账（36.41ms 全账）：
```
gemm  13.94ms/198pass(0.070)  row  9.54/70(0.136)  tiled 8.50/130(0.065)  unary 4.45/325(0.014)
其中：row/4 = window_block 整块 0.62ms/个×10 = 6.2ms（一个 pass 装下整个 block 的全部 7 个 stage，中间值全留片上）
      unary/12 = quantize_row 193 pass 共 1.64ms（quant 折进生产者 store，独立 pass 只 0.009ms）
```
我的 sync 家族账（303ms 串行口径 / 214ms 异步）：
```
window_block 42.8 | window_attention 32.8 | qkv 32.5 | batched 31.1 | quant 29.2
residual 22.5 | ffn 19.2 | gemm-f16 18.8 | wb-window-res 17.4 | quant_window 15.1
global_attn 11.2 | ffn_merge 10.8 | ffn_stem 10.4 | unary 4.9 | gemm_int8 4.6
```
**同一个 plan op，前辈实现=片上 resident，我的实现=多 pass split**——这就是 6x 的全部来源。
（leg3 的 40ms hand-off 之谜也是同一件事的局部表现：split 实现里 writer→reader 经 33MB global 的代价；resident 实现里那个 hand-off 根本不存在。）

## 二、为什么当初的 split 不算"挖坑"，但现在必须转（诚实账）

- split 是**逐 op 位精确对质的脚手架**：每个 op 拆成可独立验证的腿，才有 39 门+端到端 100% 的今天。这个价值是真实的。
- resident 尝试过四次，每次都被硬约束挡回：v2（M=64 小 tile 违规）、FULL_MEGA/RESIDENT_WB（ESIMD 多 subgroup 崩）、v3（45KB SLM 方案 opt-in 已 bit-exact，没转正）。
- **前辈的 window_block.comp 本身就是 per-window resident（64 token 一 workgroup）**——它不违反 R8a，因为 stage GEMM 在片上 SLM 里做，不是 global dispatch。转 resident 与链路健康标准不冲突，前提=照 v3 的已证机制走。

## 三、作战序列（按 家族账本大小 × 前辈对应实现 排，每刀独立提交独立三关）

### P1 window_block 内部机制 resident 化（账本 42.8+wb-window-res 17.4+quant_window 15.1+qkv 尾巴 20.8+attention 往返，整链 sync 口径 160.6ms → 前辈对应 ~12ms）

**★ 核心算子不动原则（用户 10-26 13:08 明令，实测背书）**：P1 修的是【中间数据住哪 + stage 数据流纪律】这个**内部机制**，不是计算核心。账本已证明我们的核心是健康的：QKV 宽 GEMM 本体 5.7ms/30call（0.09-0.56ms/个=前辈区）；前辈 coopmat 在 A770 只有 24.8 TOPS 上限，我们的 dpas 宽 tile 是他的 3-4x——**他的核心不是 A770 最优，他的价值只在数据流组织**。v3/v4 的计算继续用已证的 dpas tile8/store16（f16v1 逐字，39 门绿）+ 大宽数据。

**前辈 workgroup 形状实测否证（10-26 15:25）**：他的 256 线程/WG（8×32 coopmat）在 ESIMD 下直接 HANG——bench_v2crash mode=0 nd(2040×256) 无返回（90s 掐断；§96 旧账 LW>=128 ESIMD+barrier hangs，LW=64×2040 windows 是验证过的安全区）。**不搬他的形状，只搬他的 stage 纪律**：每阶段 scratch 复用（他每 subgroup 仅 1KB）、权重一次进 SLM 常驻（他的实测教训 1.6ms of 7.1ms）、双层 barrier（subgroup 内自 barrier、跨行才 group barrier）、K 转置 ColumnMajor 读法。

- 首刀已否证（a36c9dc）：wbv3 直接转正失败——46.1 vs 42.9（每对 split 赢）。根因=v3 的 stage 机制糙：45KB 别名区、7 阶段全组 barrier、每阶段只 4 个 SIMD16 subgroup 并行度。**resident 思路没错（前辈 0.62ms/call 证），v3 的实现没执行到位。**
- P1 正确做法：对 v3 做 **stage 级 bisect**（NR_V2_STOP 已有）找出 5.7ms/call 里哪段最肥 → 按前辈纪律逐段修（scratch 复用、SLM 常驻权重、barrier 分层），算子保持 dpas 宽 tile。每修一段跑一次 NR_WB_V3 同热 A/B，转正判据=家族账 window_block 42.9 → 目标 <15ms（不必到前辈 6.2——我们的 tile 更大，合理预期 3-4ms/call 级）。
- 目标：window_block 家族 42.8→~10-15ms 起步，**预期 -30~50ms**（含 wb-window-res/quant_window/qkv 尾巴/attention 往返被吸收）。

### P2 quant 家族折进生产者（29.2+15.1=44.3ms → 前辈 1.64ms）
- 参照：gemm_staged_int8.comp 的 store 出口直接出 int8+scale；quantize_row.comp 只剩非 GEMM 生产者。
- 我的现成机制：v9b fold（g_fused_quant + no-op quant）已证 bit-exact；E1 已把 v9b 的错默认修掉。缺的是**给每个生产者 GEMM 配 fold store**（batched 已有 rq9b 路；residual/f16 家族还没有）。
- 目标：**预期 -30~40ms**。

### P3 ffn 家族转 ffn_fused 结构（19.2+10.8+10.4=40.4ms → 前辈 gemm/31 5.53ms）
- 参照：ffn_fused.comp——"hidden layer kept on chip"：expand GEMM 的 publish 出口直接进 SLM 当 projection 的操作数，252MB×2 的 hidden 往返消失。一个 subgroup 带 16 行过两个 GEMM，32 hidden 列一批。
- 我的现成件：gemm_b_pub/res 的 fold store、SLM staging。做法=在 ffn recorder 里做一个 fused-expand-projection 核（或两核共享 SLM——受 launch 边界限制，选前辈的单核双 GEMM 形态）。
- 目标：**预期 -25~30ms**。

### P4 window_attention 转单 pass（32.8ms → 前辈 row/3 3.0ms）
- 参照：window_attention.comp / Codex phase42 移植（improve-fusions.md：QK^T+softmax+PV 一趟，scores 和 probs 两次 memory 往返删掉）。
- 我的现成件：smax_esimd、packdev、gemm_b 全绿。
- 目标：**预期 -20~25ms**。

### P5 qkv epilogue 折进 GEMM store（32.5 中尾巴 20.8ms）
- 参照：gemm_staged_int8 0x100000 位（BN=32=head 对齐，norm 蝶形在 SLM stage 上做）。
- 蓝本 op 序列：qkv_norm_scatter_esimd（已绿）逐字，数据源 dC→SLM。
- 注意：P1 若把 QKV 吸进 resident block，P5 自动被覆盖——**所以 P5 排在 P1 后，可能直接消失**。
- 目标：-15~20ms（若 P1 没吃掉）。

### P6 已折家族的几何精修（batched 31.1 / residual 22.5 / gemm-f16 18.8）
- 参照：width-sweep 目标线（0.071/0.107/0.172ms 级）+ KC 单缓冲（v9c2 已测：单/双同速，v9c 的病根不在 SLM 大小——这条先记档不追）+ acc-via-SLM（C2 已接 N=128 族）。
- 目标：-20~30ms。

### P7 收尾：global_attention(11.2)/unary(4.9)/ffn_stem/merge 残余
- 逐个对照前辈对应 pass 账，能折则折。目标：-10~15ms。

## 四、总账（诚实预期，2026-10-26 用户点破后修正）

**理论地板 ≈ 10-15ms**（全帧 GEMM FLOPs ~400GFLOP 在 dpas 宽 tile 实际可达区 ~7ms + resident 化后搬运 <1ms + dispatch 开销压到最小）。前辈 48ms 是"数据病态 + coopmat 在 A770 只有 24.8 TOPS 上限"的产物。健康链路 + A770 原生最优算法**必须**大幅跑赢他——只能到 55-70ms 等于承认这套架构白建。

- 中期里程碑（P1-P3 走完）：**≤ 24ms**（前辈 2x）
- 终局（P8 逐核精修）：**10-15ms**（前辈 3-5x，逼近地板）
- P1 的真实杠杆 = 整条 block 链 160.6ms（sync 口径）→ 前辈对应 ~12ms 量级，不是先前写的 -35~50。

**顺序原则：P1 先打**——resident 化 window_block 一刀吃掉账本里最纠缠的一坨（leg3 hand-off、wb-window-res、quant_window、qkv 尾巴、attention 往返全在其中）。

## 五、每刀验收清单（贴墙）

1. 参照原文（文件:行）读全，写明"学到什么、因此改了什么设计"。
2. 先门后码：给该 op 加/用既有独立门，期望值先钉。
3. 改完：39 门 → 端到端 walk 两遍 → 同热 A/B → 自查（小M?中间量化?额外开销?CPU?）→ 提交推送 → 部署 md5 入账 → 用户游戏验收。
4. 任何一关红：git revert，当场落盘失败原因（否证也是资产）。
