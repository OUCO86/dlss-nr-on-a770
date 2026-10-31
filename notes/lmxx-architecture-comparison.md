# lmxx 3080 整体架构 vs 前辈 49ms vs 我们：到 10ms 的路（2026-10-31 14:4x，精读 lmxx 架构后重写）

## 一、lmxx 3080 分支的整体架构逻辑（六刀之前 v0.1.0 就 15.83ms@720p——架构才是主体）

读 native_wave_c32_ffn.hlsl（一个完整 FFN 块）+ block*/c32* 命名体系 + README：

1. **一 fatbin = 网络一段 = 一个 megakernel**（15 fatbin / 31 块）。kernel 内部
   干完整功能块：quantize→expand gemm→gelu→proj gemm→residual fold——
   **阶段间数据走 LDS+寄存器，块内任何中间量不落显存**。
2. **残差 tile 在 wave 手里穿块**：wave(32 线程)持 16 token × 32ch；输入读一次、
   穿过整个块（gelu 的 e4m3 往返在 accumulator 寄存器内做 H()/F() 内联）、写回一次。
3. **权重每 kernel 载一次进 LDS（coeff 8KB），块内所有 token 复用**。
4. launch 数 = 31（每块一发）。**残差流量 = 2 × 31 次往返，不是 2 × 120 层**。

## 二、前辈 coopmat A770 版 47.19ms（同 walk 实测）——要超越的地板，不是老师

前辈源在 src/gpu/（22 个 .comp）。他们**已经在做块融合**：
- window_block.comp：QKV+attention+proj 三趟合一（Q/K/V 不出 workgroup，注释
  明说省 ~210MB/帧）；
- ffn_fused.comp：stem 三趟合一；
- gemm_staged_int8_fused.comp：**quant 折进 gemm 载入**（"quantising as it goes"），
  文件头还写了踩过的坑：on-chip 测 scale 会让 int32 累加器碎成 f32（27.1ms vs
  14.8），正解=**scale 由上一块的 publish epilogue 顺带写出，gemm 读时现成**。

**但他们停在 47 = 贴着自己的残差屋顶**：plan census 1267 写 122+读 278 次
=26.7GB=47.7ms@560。为什么他们不往上融合？§227 案卷白纸黑字：
**"A770 的 32KB coopmat shared 配额与 megakernel 不相容，B1a 作废"**——
Vulkan coopmat 的 LDS 上限卡死了他们做 lmxx 式块穿寄存器。

## 三、我们反超前辈的硬件窗口（这是"为什么能到 10ms"的核心）

| 配额 | 前辈 coopmat | 我们 ESIMD | lmxx 需要 |
|---|---|---|---|
| 片上共享 | **32KB 死限**（B1a 作废主因） | **64KB/WG**（chip 现役） | 13KB LDS（720p tile） |
| 矩阵算力 | 24.8 TOPS coopmat 封顶 | XMX dpas 30.9-59 TOPS（实测） | TC 238 |
| 带宽 | 560GB/s | 560GB/s | 448（3080L 反而更低） |

**前辈想做而硬件不让做的（块 megakernel、残差穿寄存器），我们的 ESIMD 栈做得起。
这就是超 47 → 10ms 的窗口：不是抄前辈，是补上他被 32KB 卡死的那一层。**

## 四、10ms 的算术（A770@560GB/s，golden f32 残差锁死下）

10ms 预算 = **5.6GB/帧**。lmxx 形态在 960x544：
- 残差 f32 66.8MB × 2（一进一出）× **31 块** = 4.14GB
- 权重 ~1GB（每 kernel 载一次，64KB SLM 装得下单块权重）
- 图输入/输出/直方图 ≈ 0.3GB
- **总 5.4GB → 流量下界 9.6ms**；XMX 算力账（前辈宽 M 形态 8-30 TOPS，我们
  deep-K 30.9 已证）把计算藏进流量。→ **10-12ms 是这套 golden 下 A770 的物理地板。**

## 五、阶梯（每档有实测锚点）

| 档 | 形态 | 残差往返 | 帧预期 | 锚点 |
|---|---|---|---|---|
| S0 现状 | ~700 节点全 split | 400 次（26.7GB） | 66.5 | 实测 |
| S1 ILP 吃满 | 同图，s8v8/qkv 在途深度 2 预取 | 同 | ~60 | laws 592-734 vs 我们 100-190=19ms 泡 |
| S2 前辈级半融合 | quant 折生产 gemm epilogue（scale 由 publish 出——前辈文件头给了正解+踩坑）；window_block 级（v4full 已在跑） | ~150 次 | **~40-44 破 47** | 前辈 fused comp 全套设计在手 |
| S3 lmxx 块 megakernel | 一 kernel = attention 块 + ffn 块（9 层周期合 2 发）；残差 tile 穿寄存器/LDS；权重每 kernel 一载 | 62 次 | ~20-25 | 64KB SLM 装得下 8tok×32ch×f32×多阶段 |
| S4 fatbin 粒度 | 31 块 = 31 发 + cp.async 预取 + 多 wave 接力 | 31 次 | **10-12** | 上表 9.6ms 下界 |

## 六、开工序（替换全部旧刀序）

1. **S2 第一铲（今天）**：GEMM_INT8_RESIDUAL 的 store epilogue 内嵌 quant_window
   （§6.5 深剖钉死的真靶 (a)：x120 写 1267 → x104 QUANT_WINDOW 读，写读严格相邻，
   100.7M 元素）——省 1267 的 104 次读 = -6.9GB ≈ **-12ms**。
   设计母本=前辈 gemm_staged_int8_fused.comp（读侧折）+ 我们 pub_vec_v8(3u)
   （写侧 e4m3 已在 epilogue）。行 scale 归约=前辈 publish.glsl 同款（行在
   gemm 输出侧持有）。判官=三关+16 对+bench_res。
2. S2 第二铲：quant 折 qkv/batched 载入（前辈 fused 的读侧形态，QFALIAS 已证
   wire——这次按前辈的 scale 预给设计，不再 on-chip 测 peak）。
3. S3 立项：一 block 一核（母本=native_wave_c32_ffn.hlsl 结构 + v4full/chip 部件），
   64KB SLM 预算按 f32 残差重开（lmxx 是 f16，我们 golden 锁 f32=tile 宽度 x2）。
4. S1 的 s8v8 双缓冲 depth-2 降为配菜（S2 落地后这些 gemm 会被 epilogue 化重写，
   单独 ILP 优化给将死的形态镀金不值）。

## 七、教训记录（本轮对话）
- 我曾用"9070XT 2.3TB/s、3080 带宽归一"给差距找硬件借口——未查证编造，被用户
  点破，官方规格撤回（A770 560GB/s+262 TOPS ≥ 3080L 448+238）。
- 我一度把前辈 coopmat 版当"学习目标"——用户点破：它是被超越对象，照抄=停在 47。
  真正的老师=lmxx 的块级 megakernel 逻辑；前辈的价值=他踩过的坑清单
  （32KB 配额死因、on-chip scale 碎累加器、读侧折 vs 写侧折的实测数字）全在源码头注释里。
