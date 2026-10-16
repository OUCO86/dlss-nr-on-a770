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

## 10. K=32 单步实测（02:20，§9 先验被修正；B1 的核心待证假设成形）

expand-only 探针（ffn_fused_int8.comp 加 EXPAND_ONLY，同文件 ifdef 先例、默认关）：
K=32 的 int8 单步（1 条 TK=32 MMA + dequant + e4m3 encode + shared 写）vs fp16 同形 GEMM：

| M | fp16 | int8(含 encode) | ratio |
|192|0.065|0.097|0.67| |2040|0.049|0.095|0.52| |8160|0.071|0.096|0.73| |32640|0.126|0.131|0.96| |130560|0.493|0.305|**1.61**|

**现象**：int8 从 M=192 到 8160 几乎恒定 ~0.095ms = **每 launch 固定成本地板**
（shared 初始化 + barrier + encode epilogue），非计算成本。fp16 随 M 线性。
只有 M=130560 计算压过地板，int8 才赢。

**对 §9 的修正（诚实，铁律⑥：现象真、我的先验归因错）**：
§9 说"int8 含边界仍赢"——在 standalone 小 M 上**被证伪**。但那个框错了：
standalone 把每个 GEMM 当独立 launch 付地板；megakernel 的意义正是把
QKV+attn+FFN 的固定成本合并成**每窗口一次**，l0 的 192 token 搭在同一窗口块顺风车。

⇒ **B1 的核心待证假设（不是先验）**：单一 int8 世界成立 ⟺ megakernel 能把
这个 ~0.095ms/launch 地板摊到"每窗口一次"而非"每 GEMM 一次"。
摊得掉 → l0-l4 全 int8，§7 红利①②③全收，device 奔 28ms。
摊不掉 → §8 退路表生效（l0/l1 保 fp16），单一世界降级为"l2-l4 单一 + l0/l1 例外"。
B1 第一段（窗口块 megakernel，先只做 QKV+attn）跑完 ledger 就给出这个答案。
数据至此完整：P1-P7 + §7 六红利 + §8 退路表 + §10 地板。B1 零测量依赖。

## 11. 设计规则 R8（用户 02:32 点破框定错误）：流水线不产小 M 形态，退路清单作废

我 §10 把 l0=192/l1=2040 当给定输入去设计退路——错。大换血的含义是
**流水线形状由我设计**，那规则就是构造性保证，不是事后权衡：

**R8a：独立 GEMM 趟的 M 一律 ≥ 8160（§10 表的 int8 翻正点）。**
不满足的形状（l0 全局块 192 token、l1 的 2040）**不得成为独立趟**——整个
l0 级别是一个 block-megakernel（前辈 global_attention 已是"一 level 一核"形态），
l0 内部的 QKV/attn/outproj/FFN 是核内 stage：无 launch、无独立趟、地板只付一次。
l1 同理并入其窗口块 megakernel。**小 M 工作不消失，但它永远是 stage 不是 dispatch。**

**R8b：§10 的 0.095ms 地板是我 v2 kernel 的实现成本，不是 int8 固有税。**
拆解：每 chunk 双 barrier（v2 保守照抄 staged）、encode 走 shared 往返、
LDS 本不需要任何初始化（Vulkan shared 是 uninitialized，v2 没有清零步骤但
barrier 密度可减半）、fp16 同形地板也有 0.049。B1 的 kernel 规则：
stage 间交接用 subgroup-only barrier（窗口 64 行 < 256 线程 workgroup 时根本
不需要全 workgroup barrier）、encode 直接在 coopMatStore 的寄存器里做完。
目标地板 ≤ 0.03ms——然后 §10 的 ratio 表在 M≥192 全线翻正。

**R8c：§8 从"退路清单"降级为"合并清单"**——列的是"哪些形状必须并入哪个
megakernel"，不是"哪里退回 fp16"。单一世界由构造成立：
独立趟全在 int8 红利区（P3/§8 数据），小 M 全在 megakernel stage 里（R8a），
float 只在四个数学孤岛（§9）。
B1 的待证假设随之收窄：不再是"单一世界成不成立"，而是
"stage 形态的地板摊薄 + R8b 的实现优化能否兑现"——ledger 一趟直接见分晓。

数据完整性复查：§10 表测的是"独立 GEMM"形态，R8a 后这些行只有 M≥8160 的
会作为独立趟存在（全部 int8 赢），M<8160 的行变成 stage 参数——B1 里用
PROBE_STOP 式分段实测 stage 成本（前辈先例），不需要新的 standalone 数据。

## 12. B1a 实测否证（2026-10-16 11:00）：tiling 冲突的 GEMM 不能折进一个 workgroup

window_mega（FFN 折进 window_block）跑通了，**bit-exact**（A/B head 0-diff、
回归全绿、6 块 fold 移除 6 趟 415→409），但 **device 慢 6ms**（60.85→66.81，
特化后仍 73 vs 69 wall）。根因是结构性的，不是实现偷懒：

- window_block 把 QKV 权重 6KB stage 进 shared（母体核心优化）。
- FFN 的 expand+branch = 16KB，attention 工作集（K/V 8KB + hidden chunk + ffout）
  已占满 32KB ⇒ **FFN 权重无处 stage，只能每 subgroup 从 global 读**。
- l1：2040 窗口 × 8 subgroup × 16KB = 261MB 权重流量（≫16MB L2，几乎全 miss）；
  而 ffn_fused 独立跑 510 workgroup × 16KB = 8MB 全进 L2。
- 叠加 M 碎片化：FFN 从 256 行/workgroup 退到 64 token/窗口（宽度扫描的反面教训）。

⇒ **架构修正**：megakernel 折的是 **elementwise 进 GEMM epilogue**（红利①，
不碰 GEMM 的 tiling），不是把 **tiling 冲突的两个 GEMM 折进一个 workgroup**。
FFN 要大 M（行批 + 权重驻留 L2），attention 要窗口局部（64 token 共享 K/V）——
两者对 A770 的 32KB shared 与 coopmat 批处理的要求根本不相容。B1a 作废为
"measured dead-end"（代码保留，flag 默认关），B1 的正确落点改为不碎片化的折叠：
  - B1c：把 e4m3_half(partition) 折进 ffn_fused 的 gather（ffn_fused 已读 value16，
    改读 s.value 内联 publish）——省一趟 ~0.7ms，FFN 保持大 M，零碎片。
  - B3：上下采样融合（partition/upsample 那 1.6ms），同理不碰 GEMM tiling。
红利①的"elementwise 免费"是对的；错的是我把它外推成"GEMM 也能互相折"。

## 13. B1c 靶子蒸发（2026-10-16 12:30）：前辈 :627 第一条已做完，第二条流量打平
- 账本独立 partition 趟 = **0**：quantize_window(flags 0x400000) 已是"partition 折进
  quantise"的成品（quantize_row.comp 注释："until now paid partition for it"——过去式）。
- 第二条（quantise 折进 gemm_int8_qkv 的 A-loader，即给 staged_int8 补 window gather）：
  流量账现状 3B/elem(读2写1) + GEMM 读 packed 1B×3列块 = 6B；折进去 = 读 image 2B×3列块
  = 6B —— **打平，多付 gather+quantise ALU ×3**；且 K 多步(256/512/1024)时行峰值不在
  单 K-step tile 内 = P5 墙原样复现。float 路径能折是因为它的 partition 是 fp16(省4B/elem)，
  int8 的 packed 容器已经把读侧砍半，折的毛利没了。⇒ B1c 作废，无新刀。
- 剩余未动工项只有 B4（链计数器，红利⑥ launch 间隙）——先 scope 再决定。

## 14. B4 否证（2026-10-16 12:40）：barrier 不占可测时间（未特化口径）
前辈早留了旋钮 `XMX_BARRIER_MODE` 0..3（libxmx:1245），笔记里没有实测记录。交错 A/B
（每 mode 5 样本、mode 顺序打乱消热噪声）：
```
mode 1 (默认): device med 64.72 best 61.13 | wall med 71.1 best 67.7
mode 2 (去 src WRITE): med 65.03 best 64.55 | wall med 71.5 best 71.0
mode 3 (全跳 23 个 barrier): med 64.70 best 64.65 | wall med 71.3 best 71.2
```
三 mode 中位数一致（64.7-65.0）⇒ 那 23 个 vkCmdPipelineBarrier 在 device 时间上
**没有可测成本**（单跑看到的 mode2"快 2.1ms"是噪声：同配置两次 mode1 差 1.4ms）。
符合预期：同 command buffer 内 compute dispatch 本就按序，barrier 只加 fence，
不改变 dispatch 顺序；消 fence 不重叠 launch（数据依赖挡着）。
⚠ 口径 caveat：devtime 未调 rt.specialize()，测的是未特化帧；出货是特化帧。
若特化后帧更短、launch 间隙占比更高，B4 才可能显形——但链计数器(§5 B4)要消的是
"dispatch 间 ramp/drain 不重叠"，而 mode3 已让 dispatch 背靠背无 barrier 仍不省，
⇒ 这台 Intel 驱动没有前辈 RDNA 那种 per-dispatch launch 间隙可消。B4 判定为低价值，
不再投入（除非特化口径重测显示 gap）。

## 15. 今晚 B 系列收敛（2026-10-16 12:45）：可迁移红利已穷尽或已存在
四轮实测，每条都撞墙或靶子已不存在：
- B1a FFN 折进 window_block：bit-exact 但 device 慢 6ms（§12 tiling 冲突：FFN 权重
  无法 stage + M 碎片化）。作废。
- B1c quantise 折进 int8 GEMM：前辈 :627 第一条(partition→quantise)已做成
  quantize_window；第二条流量打平撞 P5。靶子不存在（§13）。
- B4 barrier/链计数器：交错 A/B 不省时间（§14）。
- 红利①(residual/publish 折 GEMM epilogue)：record_project_residual、各 GEMM 的
  epilogue publish——**前辈实现早已收割**。剩 quantize 3.09ms 是这台机器不可约
  （P5 行-max + 流量打平，今晚两次独立证）。
⇒ A770-native 大换血的"完美贴合"实测落点 ≈ 前辈现有实现（device ~45 特化口径）
  + 已存在的红利；Mochi 快 5× 的剩余部分是硬件（256-VGPR 宽 tile、FP8、宽 coopmat），
  不是架构能补的。出货路径（windows 主线、mega flag 默认关）今晚零改动。

## 16. 架构分叉实证（2026-10-16 19:00）：ESIMD 进不了 Vulkan——重写核心层=换后端到 Level Zero
三个实证（全部本机跑出来的，非推测）：
- `SYCL_DUMP_IMAGES=1` dump v2 核的 SPIR-V：`sycl_spir64.spv` 声明
  **SPV_INTEL_vector_compute**（+memory_access_aliasing、fp_fast_math_mode）。DPAS 是它的指令。
- 枚举本机 Intel Vulkan 驱动（32.0.101.9150）全部 160 个 device extension：
  INTEL 系只有 `VK_INTEL_performance_query`、`VK_INTEL_device_info`——**没有任何 vector-compute 扩展**。
  ⇒ SPV_INTEL_vector_compute 的 SPIR-V 在 Vulkan 侧加载不了（vkCreateShaderModule 会拒）。
- 前辈 Mochi 参考本身也是 Vulkan coopmat（ta_MochizukiNrRuntime.cpp:746
  CooperativeMatrixFeaturesKHR + :757 FP8）——它在 AMD 快是因为 RDNA3 coopmat 宽 tile，
  不是因为它的 API 选择高级。**在 A770 上，Vulkan coopmat=24.8 接口税，此路封顶。**
⇒ 结论：要拿 ESIMD 的 40-59 TOPS（v1/v2 实测），核心层后端必须从 Vulkan 换成
  **Level Zero**（SYCL/L0 正是 Blackwood 前辈全部 ESIMD 工作所在的世界）。
  libxmx.c 3777 行、233 处 Vulkan API（含与桥接 D3D12 的 external fence/semaphore/memory
  Win32 互操作）——L0 全部有对应物（zeImportExternalFence/Semaphore、D3D12 共享 handle，
  同 vendor 栈比跨 Vulkan 更直接）。Python 侧 xmx_* 记录接口可保持不变，只换 C 后端。
三选项（已实证边界）：
  A) L0 + ESIMD 手写核：唯一通向 72-100+ TOPS 的路；工作量最大（后端重写+互操作重验）；
     前辈 Blackwood 的核（GEMM/RMSNorm/softmax/GEMV 全套 ESIMD ladder）都在 L0，可照抄。
  B) 留 Vulkan coopmat：封顶 24.8（今晚已证），等于放弃重写目标。
  C) L0 + oneDNN 直通：拿 71.9 饱和但不能融合/改算法（接缝税 5ms 原样在）、
     eager dispatch 税（前辈实测 +0.2-0.5ms/次×300）在 L0 下同样存在。
推荐 A，分阶段；最大未知=L0↔D3D12 桥接互操作，先做阶段 1 探针再投大工程。

## 17. 门控探针①（2026-10-16 21:4x）：SYCL 提交开销能不能撑起"一次 submit 跑完静态计划"——能
问题来源：§16 选项 C 被否的机制=前辈实测 oneDNN eager 税 +0.2-0.5ms/次×300。选项 A 的
自研核走不走同样的坑？用实测回答（probe_graph.cpp，tiny kernel 只测提交机制，趟数=真实帧 691）。

本机实测（A770/120W，SYCL_DEVICE_FILTER=level_zero:gpu，30 帧中位/最好）：
- EAGER  691 次独立 submit/帧 : med 6.06 ms（8.8 us/submit）
- MEGA   1 次 launch 装下全部 : med 0.073 ms
- GRAPH  录一次 691-node、每帧 replay : med 1.58 ms（2.3 us/node）
- GRAPH-ESIMD  把 vector_compute(ESIMD DPAS) 核放进 graph 节点 : **OK**（值对，非仅编译过）

结论（对重写路线的三块硬事实）：
1. **自研核没有 oneDNN 那种 host marshalling 税**：裸 submit 8.8us vs oneDNN 0.2-0.5ms，
   差 20-50×——选项 C 的"装不进静态计划"在自研核上不存在，这是"手写两边可控"的又一实证。
2. **"一次 submit 跑完 691 趟"两条路都通**：megakernel（最优，0.073ms，host 几乎归零）
   或 SYCL command_graph（1.58ms，保留 pass 粒度、可增量迁移、有真实依赖边）。
   ⇒ 691→~150 的"消趟数"红利（§7⑥/§15）在 host 侧兑现路径已被实测打通。
3. **ESIMD 核 graph 兼容已证**（gate 1b）：§16"裸 C+ze_loader 有 kernel 名坑"因此不必先撞——
   务实形态 SYCL/ESIMD + L0 command graph 成立（19:55 的判断被实测确认）。
caveat（诚实）：GRAPH 1.58ms 是 host wall（含 q.wait），比 MEGA 高 20×；真实帧 device
~44ms 下它可被隐藏，但**最终形态应往 megakernel 收敛**，graph 是"保留现有 pass 图、先换后端"
的过渡形态——正好匹配"libxmx 重写第一期不动调度、第二期合并"的分期。

## 18. 门控探针②（2026-10-16 23:0x）：D3D12↔Level Zero 互操作全绿——选项 A 技术门控解除
源码 `src/bench/l0/probe_d3d12_ze.cpp`（编译 `src/bench/l0/build_l0.sh`，exe 在 oneapi/ 跑）。
本机 A770/120W，D3D12 与 L0 都显式选同一物理卡（vendor 0x8086 dev 0x56a0）。

结果（PROBE_D3D12_ZE GREEN, 0 fails）：
- GATE A（同步）：D3D12 SHARED fence 的 NT handle → `zeDeviceImportExternalSemaphoreExt`
  (flag=D3D12_FENCE) 成功；immediate list 上 wait(value=2) 在 fence=1 时**正确阻塞**
  (sync=NOT_READY)、`cmdq->Signal(fence,2)` 后**正确解锁**(sync=SUCCESS)；控制组 wait(999)
  正确超时、解锁后设备留干净（10-13 那次"doomed wait 污染一分钟"的坑已按先例处理）。
- GATE B（内存）：D3D12 committed resource(HEAP_FLAG_SHARED, 16MB=前辈 hand-over 下限)
  → `zeMemAllocDevice` pNext=`ze_external_memory_import_win32_handle_t`
  (flag=D3D12_RESOURCE) 成功，ptr 非空、alloc type=2(device)。
- GATE C/C2/C3（数据通路，一次一个变量逐步钉死）：
  C  = L0 `AppendMemoryCopy` host→imported 16MB，sync=SUCCESS（16B 也 SUCCESS）；
  C2 = L0 读回 imported→host：**BIT-EXACT**（0/1024 错）——L0 读写这块内存正确；
  C3 = L0 写 imported → D3D12 CopyResource 到 READBACK → Map 比对：**BIT-EXACT 0/4194304**。
  这正是出货管线要的方向（NR 写、游戏读），跨 API 零拷贝共享成立。
- C0（对照）：plain L0 device alloc 同用法 copy+sync 全过 ⇒ 上面不是我的用法错。

三个纠正/新事实（推翻或补 §16 的凭印象处）：
1. ⚠ **§16 写的 `zeImportExternalFence` 不存在**（本机 SDK spec 1.19.12 全文零命中）。
   fence 走 **external-semaphore 扩展**：`zeDeviceImportExternalSemaphoreExt` +
   `ZE_EXTERNAL_SEMAPHORE_EXT_FLAG_D3D12_FENCE`(ze_api.h:15085) +
   `ze_external_semaphore_win32_ext_desc_t{handle}`(:15111)；推进/等待=
   `zeCommandListAppend{Signal,Wait}ExternalSemaphoreExt`(:15267/:15317)。
2. 🚩 **硬约束：external semaphore 的 signal/wait 只能挂在 immediate command list 上**
   （spec 明写 "Commandlist handle does not correspond to an immediate command list"=invalid arg）。
   ⇒ L0 重写的提交形态必须含 immediate list（或 graph 里用 immediate），
   "全部录进一个 deferred list 一次 execute"对 fence 节点不成立——这条要写进重写设计。
3. 🚩 **能力查询必须用 dedicated getter `zeDeviceGetExternalMemoryProperties`**：
   把 `ze_device_external_memory_properties_t` 挂 `zeDeviceGetProperties` 的 pNext，
   本机驱动**不填**（返回 0x0，差点误判"驱动不支持 import"）；dedicated getter 返回
   importTypes=0xc4（OPAQUE_WIN32|D3D12_HEAP|D3D12_RESOURCE 全支持）、exportTypes=0x4。
   （又一次"观测真、归因假"：0x0 是我问错了地方，不是驱动没能力。）

D3D12 侧脚手架踩坑固化（写进 build_l0.sh 注释）：
- `CreateSharedHandle` 的 Access：fence 用 **GENERIC_ALL**（SYNCHRONIZE 与 0 都被拒）——
  前辈先例 `nr_fuse_probe.cpp:243-244`，照抄即过。
- 共享 buffer 一步 `CreateCommittedResource`+`D3D12_HEAP_FLAG_SHARED`（前辈 :70）；
  `CreateHeap(1MB)+Placed` 被拒 E_INVALIDARG——别重开这个案。
- readback 用 **READBACK heap、初始态 COPY_DEST**；UPLOAD+`GENERIC_READ→COPY_DEST` 是
  非法 transition，runtime validation 失败表现为 **Close() 返回 E_INVALIDARG**（MS 文档
  ResourceBarrier 节逐字："Validation failure causes ID3D12GraphicsCommandList::Close to
  return E_INVALIDARG"）。
- `CreateCommandList` 返回的是 **open** list（再 Reset 反而 E_FAIL）。
- icx 链接：源文件必须在 `//link` **之前**（`//link` 吞掉后面所有参数，前辈
  `build_probe.sh` 正是这个顺序）。
- host 推进 fence 只能经 `ID3D12CommandQueue::Signal`（d3d12.h:8740；没有 host SetSignal）。

⇒ §16 的"最大未知=L0↔D3D12 桥接互操作"已闭合：①②两块门控全绿。
**技术上前置条件全部满足**，投 libxmx.c 3777 行重写（Vulkan→L0）不再有未知。
按规矩：**等大用户明确点头才开工重写**；开工第一期=后端替换+immediate list 提交形态，
Python 侧 xmx_* 接口不变，之后才是 §17 的调度合并与 int8 直通链。
