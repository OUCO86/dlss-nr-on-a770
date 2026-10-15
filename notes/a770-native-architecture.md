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

## 7. A770 的红利清单（收获面，用户 2026-10-16 01:56 追问后补全）

避墙(P1-P7)只是防守；这张架构的收入是六条，每条有实测：

| 红利 | 证据 | 收法 |
|---|---|---|
| ① epilogue 算术免费 | 前辈:fp16 staged GEMM +e4m3+gate = 531/530/533us 不变 | quantize 3.09 + residual ~2 + publish ~0.7 + partition/upsample 1.6 ≈ **7ms 池**折进 store 循环 |
| ② int8=2×矩阵率+半发射成本(TK32/16) | 宽度扫描 1.3-3.5×，20.5 vs 7.6 TF/s | P3 逐形状配；megakernel 批窗口把有效 M 推入红利区 |
| ③ 512 XMX 奖励广度不奖励深度 | 26.9:XMX 512 vs 128；19.5% active | 原生 8x8x32、≤12 累加器、32KB LDS → occupancy 拉满 |
| ④ 16MB L2 权重重载免费 | L2_reuse 854GB/s；块权重 6-16KB | megakernel 不做权重 LDS staging，LDS 留给中间值 |
| ⑤ LDS 交接便宜 | e4m3 反证(贵的是 global 窄事务)；window_block 已用 | 阶段间 coopMatStore→LDS→load，不落 global |
| ⑥ 发射口是唯一稀缺 | fill 无平台期；register-move 300-940/核 | 一切以每帧指令数为货币(691→~150 的理由) |

**收获预算**：①7 + ③⑤往返 3-5 + ⑥launch 2-3 + ②新增 1-2 ≈ 13-17ms
⇒ device 44.75 → **28-32ms**（比 §4 的 25-30 更保守可辩护）。
⚠ 反面细节：residual 折进 staged int8 GEMM 在 K=64 不免费(1162 vs 531,前辈实测)——
①只对 fp16 staged 与 store-loop 形态成立；megakernel 的 LDS-residual 形态 B1 内单独验证。
桥接层不动（用户确认，2026-10-16）：红利全在核心层与计划器。

## 8. B1 引擎决策表（02:10 补测，megakernel 实际 GEMM 形状，特化对特化）

| 形状 | M=192/2040 | M=8160 | M=32640 | M=130560 |
|---|---|---|---|---|
| QKV N=96 K=64/128 | 0.81-0.86 | 1.17-1.41 | 1.22-1.44 | **1.87-1.88** |
| QKV N=96 K=1024（l0） | 1.61-1.72 | 2.40 | 2.12 | **2.55** |
| attnV N=32 K=64 | 0.74-0.81 | 0.91 | 1.19 | 1.41 |
| outproj N=32 K=128 | 0.87 | 0.89 | 1.34 | 1.54 |
| attn scores N=64 K=32 | — | — | — | — （int8 闸门拒 K=32） |
| QKV@l3-4/outproj@l3-4 K=32 | — | — | — | — （同上，TK=32 单步是唯一路） |

**B1 的引擎规则（可直接写进计划器）**：
1. **K=32 的形状**（attn scores、l3-4 的 QKV/outproj）：staged int8 进不去（inner%64），
   megakernel 用 TK=32 单步 int8（ffn_fused_int8 的 expand 先例）或保持 fp16——
   B1 第一段先 fp16（window_block 现状），int8@K32 是 B1 之后的独立实验。
2. **N=96 K≥64**：M≥8160 走 int8（1.17-2.55×），M=192/2040 保持 fp16。
3. **N=32 K≥64**：M≥32640 走 int8（1.19-1.54×），以下 fp16。
4. 帧内分布：l0(192 行)→fp16；l1(2040)→fp16 除 QKV-K1024；l2(8160)→QKV int8；
   l3(32640)/l4(130560)→全部 int8。
红利区数据至此完整：P1-P7 + §7 六条 + 本表。明天 B1 开工不再需要任何测量。

## 9. 统摄法则（用户 2026-10-16 02:15）：单一数据世界，float 只在数学强制的孤岛

**取代 §8 的"按层选引擎"。** 那是 R 的两世界遗留（fp16/int8 共存，边界处才有
quantize/publish 摩擦）。既然核心自己写、什么都改，正解是**一个世界**：

- **GEMM 操作数一律 int8、累加器一律 int32（精确）、贯穿全链**——不在 fp16↔int8
  之间来回，就没有那条边界上的 quantize/dequantize/publish 摩擦（§7 红利①的 7ms 池
  正是这条边界税）。
- **float 只保留在数学上不可约的孤岛**（不是妥协，是 Mochi 的实际形状——它是 FP8 GEMM
  + float softmax，同款）：
  1. attention softmax 的 exp（bit-trick，attention.comp/window_block 现成）；
  2. layernorm 的 inversqrt / reciprocal（cosine_tree.glsl）；
  3. dequant 的 scale 乘（int32→float 的那一步，publish.glsl）；
  4. publish 舍入链（half_round/e4m3）。
  这些在 int8 GEMM 的 **epilogue/store 循环里**做，不落回 fp16 世界再重新量化。

### 与 §8 冲突处的裁决（诚实）
§8 实测：孤立 GEMM 在 tiny-M（l0=192、l1=2040）int8 反而 0.74-0.86×慢。
但**系统级**不同：把这两个形状单独退回 fp16，就要在它们前后各插一次
quantize/dequantize 跨界——边界税 > 那 0.2× 的 GEMM 罚金。
⇒ **B1 内必测的一条**（唯一还缺的数据，且只有 megakernel 里才是真形状，
standalone 测不了——gemm_int8 的 inner%64 闸门拒 K=32，而 K=32=head_dim
正是 attention scores 的宽度）：l0/l1 的 int8-vs-fp16 **含边界成本**对比。
先验：int8 K=32 = 一条 TK=32 MMA，fp16 K=32 = 两条 TK=16 MMA（②红利半发射成本），
v2 的 expand 已跑通这个单步形态。预期 int8 含边界仍赢，但这是 B1 要证的，不假设。

### K=32 的 int8 不是硬件限制，是遗留闸门
coopmat int8 原生 8×8×**32**——K=32 恰好一条 MMA。"staged 拒 K=32"是前辈
gemm_staged_int8 的 inner%64 检查（为 BK=64 的 K-loop 设的），不是 Xe-HPG 的边界。
megakernel 自己写 K-loop，K=32 单步完全合法（v2 expand 已证）。⇒ 单一世界无硬件障碍。

### 这条法则让架构"发货这张卡的优势"的方式
不是"每个 GEMM 求最快"（那会碎片化成 fp16/int8 混跑），而是"整条数据流求最快"：
int8 贯穿 → 零边界税 → 512 XMX 全程喂 int8 双率（②③）→ float 只在四个孤岛、
在 epilogue 内做完（①）。这才是 A770 最擅长的形态：宽数据流、浅每步、少趟、
无格式转换。§8 的表降级为"若某形状边界税反超预期时的退路清单"，不是默认路由。
