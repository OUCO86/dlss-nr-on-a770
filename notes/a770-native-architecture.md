# A770-native 架构（2026-10-16 定案，B 的设计基线）

> 取代 mochi-rewrite-plan 里"照 Mochi 形状做"的提法。修正来自 2026-10-15/16 夜的全部实测：
> **Mochi 的形状是 RDNA4（256 VGPR、宽 coopmat、FP8）预算下的产物，照搬到 Xe-HPG
> 每一条路都撞墙（宽 tile=累加器悬崖 4.1×、窄 tile 换引擎=1.06×）。但它快 5× 的三个
> 结构性原因——融合广度、趟数、host 零工作——全部与寄存器预算无关，全部可迁移。**
> 所以新架构 = Mochi 的融合广度 + Mochi 的链与计划表 + **从 A770 实测重新推导的
> tile/寄存器/LDS 预算**。这不是脱离参考，是参考形状在 Xe-HPG 上的重新配平。

## 1. 设计参数表（每条都有实测出处，不是规格书抄的）

| # | 参数 | 值 | 出处 |
|---|---|---|---|
| P1 | 同时存活累加器上限 | **≤12 安全（scratch 0），16 悬崖（4.1×）** | reg_pressure_probe，9 变体扫描 |
| P2 | LDS 预算 | 32KB/workgroup（hidden 128 列 = 2KB/subgroup 流式两半可装下） | ffn_fused_int8 v2 实测 Workgroup=32768、scratch=0 |
| P3 | 引擎按形状选 | 宽区（N≥128,K≥128 或 M≥32640）int8 1.3-3.5×；窄/浅区 fp16 | int8-width-sweep.md 48 形状 |
| P4 | 访存事务宽度 | load/store 一律 ≥16B；窄容器（8B）每字节更贵 | e4m3 探针（省字节反慢 5-18%，DRAM-bound 仍慢） |
| P5 | quantize 不可独立存在 | 276 个 quantize 无一宽度 ≤32 → 行-max 依赖只能靠 **tile 拥有整行** 消解 | 账本分桶（本文件提交前刚测） |
| P6 | 发射口无空闲 | fill 实验直线无平台期；XMX 19.5% active 但端口被逐元素占满 | 前辈 26.10 + spv-memops（register-move 300-940/核） |
| P7 | coopmat 原生形状 | 8×8×32 int8 / 8×8×16 fp16——**窄 tile 是硬件原生，不需要也不应该学 64×256** | xmx_shape.h + 全部实测 |

## 2. 新架构的形状（每条规则对应一台墙）

1. **一个 workgroup 拥有一个完整窗口块**（64 token × 全部通道）。
   这是 P5 的唯一解：producer 拥有整行 → 行-max 在手上 → quantize 折进 epilogue，
   276 个独立趟消失。窗口块的通道数恰好让这条路成立：
   - QKV 输出 **96 列 = 12 个累加器 = P1 的顶格**（不差一个刚好）；
   - attention scores 64 列 = 8 ✓；attnV/outproj/contract 32 列 = 4 ✓；
   - 唯一超标的是 FFN expand 的 128 列 = 16——**用 v2 已验证的两半流式**
     （2×64 列、每半 8 累加器，中间过 shared）。
   各阶段顺序执行，峰值累加器 12，全程 scratch=0 可达（v2 已证同类结构）。
2. **中间值走 LDS，不走 global**（P2 预算内），也不学 Mochi 走寄存器（P1）。
   v2 的"hidden 字节 + int32 暂存"就是模板：4KB/subgroup。
3. **趟数目标 ~100-150**：窗口块 10 趟（每块一趟）、global/ViT 块、上下采样融合
   （Mochi 的 ds_fuse/ups_fused 模式，纯 LDS 内操作）、head、temporal。
4. **静态计划表**：移植 `refs/DLSSNR-AMD/core/nr_native_plan.cpp`（79 行 C++，
   与硬件无关）+ 已有的 plan_960x544.c/nr_replay 进程内直传（27 线已开工）。
   host 每帧 717 次 Python 推形状 → 0。
5. **链计数器**：移植 `shaders/nr_chain.glsl`（NR_CHAIN/NR_TCHAIN，纯
   atomic + epoch 算术，与硬件无关）。趟间从"命令缓冲串行"变"排空重叠"。
6. **16B 访存纪律**（P4）：所有 global 交接用 vec4/uvec4；容器不缩窄。
7. **引擎按 P3 表逐形状配**：不存在"全局换 int8"或"全局 fp16"。

## 3. 为什么这次不是又一次撞墙（与今晚失败实验的区别）

- ffn_fused_int8 输在**只换引擎不拥有整行**（FFN 的 hidden 128 列超 P1，量化往返
  还在）——它的教训被规则 1 的两半流式吸收。
- BN=64 输在**旧 tile 框架内加宽**（qkv_epilogue 写死 32）——规则 1 直接把
  epilogue 重写进 megakernel，没有旧框架。
- e4m3 输在**省字节**——规则 2/6 省的是**趟和事务数**，字节不缩。
- 合并/向量化输在**已做**——新架构不重复它们，只消它们没消的：691→~150 趟。

## 4. 诚实预期（不重犯"32ms 天花板/15ms 地板"的错）

- 消掉的：quantize 3.09ms 的大部分（P5 折进 epilogue）、族间 global 往返
  （spv-memops 的 register-move 大头）、qkv 12.54ms 里 attention 与投影间的
  Q/K/V 落片往返、dispatch 间隙（B4）。
- 不动的：矩阵功本身（int8 已在吃 2-3.5× 区）、fp16 窄形状（P3 判的）。
- device 44.75 → **25-30ms**（不是 15-20：那需要 Mochi 的宽 tile 红利，P1/P7 已证
  这台机器给不了）。wall → ~30-35ms → **30fps 上下**。
- 这是"完完全全适合 A770"的形状能给的上限；再往上就是换硬件的事。

## 5. 工作量与顺序（每期一个 flag、一个逐字节/逐数值门、游戏内验证）

- **B1 窗口块 megakernel**（规则 1+2 的第一次完整兑现：一个 workgroup 一个窗口，
  QKV→norm→attn→outproj→FFN→residual→publish 全内，quantize 归零）。
  新 kernel ~1000-1500 行 GLSL，从 window_block + ffn_fused + qkv_epilogue 的
  已验证位序组合，不是白手起家。数值门：对现有四趟链逐字节（fp16 段）+
  对 numpy int8 参考（int8 段，前辈 test_gemm_int8_staged 模式）。
- B2 global/ViT 块、B3 上下采样：同模式复制。
- B4 链计数器：nr_chain.glsl 移植（独立、低风险、可最后做）。
- 每期结束 ledger 报趟数（691→…）与 device ms。

## 6. 存证

今晚全部负结果与参数实测：notes/int8-width-sweep.md、improve-int8-bottleneck.md
（e4m3 两节）、frame-ledger-a770.md（字节账+宽度账）、reg_pressure_probe 表在
mochi-rewrite-plan.md §6；ffn_fused_int8 v2（scratch 0、1.06-1.10×）留作对照。
