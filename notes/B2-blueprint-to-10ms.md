# B2 蓝图：71 层完整模型到 10ms 的路线（2026-10-31 15:0x 制定）
# （军规与验收标准置顶，任何窗口开工先读这一页，再读流水/交接卡）

════════════════════════════════════════════════════════════════════
## ⚑ 军规（用户制定，违反=返工，顺序不可颠倒）

### 第 0 条 · 窗口开局必读（最高优先）
精读上一窗口**全部**流水（`.workbuddy/memory/YYYY-MM-DD.md` 全文，不许跳读/grep
代替）+ 本蓝图 + 项目 `MEMORY.md` + `notes/lmxx-architecture-comparison.md`。
读完要在回复里明说学到了什么、因此改了什么设计。

### 第 1 条 · 收益优先：负结果≠方案错，是实现错
参照 lmxx/前辈布局做的改动测出无收益甚至负收益——**第一动作是找解决方案把收益
弄到手，不是回退**。除硬件物理限制外都是实现问题；硬件限制多半也是"实现方式不
适配 A770"。判决为负的账必须写清：实现错在哪、下一形状是什么。留开关留仪器，
不把方案本身判死。（正面例：CS2 v1 半闲置 +0.22 → v2 全员有活干 -10%。）

### 第 2 条 · 先测量后开刀（防"十次九错靶"）
每个假说先用 <10 分钟探针判生死，再决定开刀。禁止烧完整实现才发现错靶。
仪器在手：bench_b3 / bench_batched / bench_res / bench_wa_res / bench_qrg /
bench_qilp / bench_laws / bench_nodetax / NR_RUN_TIMING / NR_*_STOP 家族。

### 第 3 条 · 诊断不得改变被测量（探针污染案 §6.29）
塞进 shipped 核的运行时诊断分支会毒化寄存器分配（实测：壳 1.28→0.005ms）。
规则：诊断用 **if constexpr 模板参数** 或 recorder 闭包级 stop；任何分段账必须
在"带/不带诊断"对照下测；作废账要明写作废并重测。

### 第 4 条 · 任何缓存/跳过/折并的"不变"前提，先 VERIFY 再上协议
内容稳定性用 diff 探针实测（WQ 案：160/160 STALE，-2.65 是 fast-but-wrong）。
16 对协议只测快慢不测对错——**三关（对错）永远先于协议（快慢）**。

### 第 5 条 · 引用任何外部数字先答三问
哪个模型（71 层完整 / 31 块 Small）？哪个分辨率（900/1080/960×544）？
什么形态（split / 半融合 / resident）？（本会话两次栽在这：带宽借口、31-block 误读）

### 第 6 条 · 遇到问题先全网搜索（含官方文档），归因一次一个变量
官方规格查 Intel ARK / NVIDIA / Khronos；坑查 GitHub issue 与前辈源码头注释
（前辈 src/gpu/*.comp 的文件头=已付学费的坑清单，先读再写）。
搜到即归档（refs/ + 中文提炼 + 来源 URL），下次读本地。

### 第 7 条 · 自己续跑
命令失败/一轮结束未到结论——不等催，当轮读报错→搜索→单变量对照→落盘→换路
继续。"？？"和"咋不动了"=已在违反。

════════════════════════════════════════════════════════════════════
## ⚑ 健康链路验收标准（每刀必过，缺一个 = 该刀不成立）

1. **1250 门全绿**（build_sycl_dll.sh 内嵌全套 golden 门：FFN/WINDOW/COEXIST/…）
2. **walk 1301 逐字节 EXACT**（对错权威=前辈 coopmat 引擎 golden，`cmp *.1301.bin bk.1301.bin`）
3. **passes=691 必查**（B6 误接线事故教训：684/690 少 passes=有 op 被吞）
4. **16 对协议**：同热交错 16 对，**赢≥10 且均值≤-0.5 = 转正**；±0.5 内 = 带内
   （留形不吹，P8-k）；负 = 按军规 1 处理（找形状，不裸回退）。
   仪器：两 dll 或同 dll 双开关（开关必须 `!getenv||atoi!=0` 形，防 =0 也算 ON）。
5. **三复现**：任何单点读数（腿账/归因）至少 3 次或两 rep 一致才入账。
6. **判决当场落盘**：commit message 写全（数字+机制+教训+下一刀），blueprint
   节号同步；部署位 `cp src/bench/sycl/libxmx_sycl.dll work/libxmx.dll` + md5 记录。
7. **游戏侧健康**：OptiScaler.log 的 `work=` 与 walk 同量级（游戏垫 ~17ms 自身
   负载属正常）；`gap run` 无 failures；画面 A/B 无差异投诉。

当前基线（2026-10-31）：walk 带 **66.2-66.5 冷**，部署位 md5 `1cb94804`
（CS2 全家族 + QFALIAS 资产默认 OFF + cstop 模板探针）。
同机 ground truth：前辈 coopmat 件 **47.19ms**（超越对象，不是老师）。

════════════════════════════════════════════════════════════════════
## 一、战略事实（全部实测背书，本窗口钉死）

- 模型=**71 层完整 NR**（不是 31 块 Small；Small 适配简单，之后再弄）。
- A770 16GB = 560GB/s + 262 Int8 TOPS(XMX) ≥ 3080L(448+238)。**零硬件借口。**
- 前辈 coopmat 版 47.19 = 贴 1267 残差流量屋顶（26.7GB=47.7ms）；其 B1a
  megakernel 被 **Vulkan coopmat 32KB SLM 死限**作废（§227）。
- 我们的 ESIMD 栈配额：64KB SLM/WG（chip 现役）+ XMX dpas 30.9-59 TOPS 实测
  + laws 在途 592-734GB/s。**前辈被禁的形态我们做得起。**
- lmxx 71 层完整模型的真实形态 = **~160 发 launch**（非 31）+ 六件套
  （块内融合/上采样折邻块/persistent stage/W5 权重共享/逐核 roofline 审计/微观数值）。
  其 9070XT 实测 900p 7.6 / 1080p 10.4ms。
- 我们 66.5 = 屋顶 47.7 + ~19ms latency 泡（s8v8/qkv 有效 100-190GB/s vs 在途上限）。
- 流量地板账（960×544，golden f32 残差锁死）：
  lmxx 深度融合 → 残差往返 400→142 次 = 9.5GB+1+0.5 ≈ 11GB = **19.6ms 下界**；
  层 resident 写读合一 → 71 次 = **~10.5ms 物理地板**。XMX 算力 0.2ms 全藏流量。
  → **10-12ms 是这套 golden 在 A770 上的物理地板，可达。**

## 二、腿账 v4（CS2 件实测，关键路径靶序）

| 腿 | 删除探针帧值 | 串行账(RUN_TIMING 干净件) | 状态 |
|---|---|---|---|
| ffn 系（stem -4.7 / main+merge -4.5） | **-9.5** | 11.9 | CS2 已削单核 -10%，残差税在流量 |
| quant | **-5.8**(核) | 10.3 | 核已 roofline；融合方向=读侧折（见 S2a） |
| unary | **-5.0** | 4.3 | 向量化已全覆盖；肉在折邻块（S2b） |
| wa 家族 | **-6.2** | 17.0 | TILE/MERGE 折在带内；供数未审计 |
| gemm 三兄弟（batched/res/wres/qkv） | ≈0（overlap 隐藏） | 64.7 | S4 W5 权重共享 = 对症（读÷5） |

## 三、开工序（B2 战役，每刀带图纸）

### S2a（本周主刀）读侧 quant 折进 residual gemm —— 目标 -12ms
- 靶：x120 GEMM_INT8_RESIDUAL 写 1267 → x104 QUANT_WINDOW 读（census 验证严格
  相邻、维度对上：resid 32ch 行 = qw 64 宽 2-token 窗口行 + gather pad 零行）。
- 图纸：前辈 `gemm_staged_int8_fused.comp` 头注释（设计+两个坑：on-chip 测 peak
  碎 int32 累加器 27.1 vs 14.8=禁；scale 由**写侧 publish epilogue 预给**=正解；
  一 div 不是一 value 一 div）；我们的 pub_vec_v8(3u)（写侧 e4m3 已在 epilogue）
  + QFALIAS（wire 已证）+ `pack_a_fused_b1`（资产）。
- 实现路线：residual gemm 的 store epilogue 顺手出 pk(1272)+scale(1273)
  （前辈"quantising as it goes"读侧反向=写侧版），QUANT_WINDOW no-op。
  注意 qw 的 gather 几何：折进 gemm store 时按 image 槽写（前辈
  residual_epilogue.glsl 的 index 映射 VERBATIM 可抄）。
- 判官：bench_res 先定价 → 三关 → 16 对 → 破 47 第一铲。

### S2b 上采样/小 op 折邻块（目标 -3~5ms）
- 前辈/lmxx 双图纸：lmxx 0.36#8（upsample 折下一块首层，-0.17/-0.25ms 实测，
  且"ViT/downsample 候选无增益不折"=负面清单）；前辈 publish/residual epilogue 系。
- 我们靶：unary 腿 32 发（POOL2/UPSAMPLE_ADD 已向量化）→ 折进前后 gemm 的
  load/store 边界；wa 供数审计先跑（NR_WA_STOP 细分）。

### S3 persistent stage（目标 -5~8ms）
- lmxx 0.37#3 复刻：每层 9-op 周期的相邻 op 串成**一个 cgraph 子图节点**
  （我们的 cgraph 就是 ready-queue；B6-1 教训=五件套形态太大，按他们 stage=6 层
  粒度重切；节点税 ~0.7µs 已测=nodetax，合并本身不值钱，值钱的是**融合边界内
  的 LDS 交接**）。
- 前置：S2a/S2b 把该折的折完，S3 只做"多 op 一核"的结构壳。

### S4 W5 权重共享治 s8v8（目标：gemm 三兄弟单核 2-3x，为关键路径腾 SM）
- 我们的旧账 §6.22：s8v8 每 kb 每 subgroup SLM 读 32KB vs unique 6KB = 5.3x 放大
  ——与 lmxx W5 的问题完全同构；他们实测读÷5、48.8→37µs、8KB 双缓冲。
- 图纸：lmxx `results/vit-qkv-20260929` 记录 + 我们 bench_batched（现成）。
  注意他们负结果：C512 proj 共权重更慢（不是所有权重共享都赚）。

### S5 逐核 roofline map 制度化
- 每窗口跑一次 RUN_TIMING（第二遍）× 每行配 bench 单价，离屋顶 >2x 的行排队。
- 本表已建（§6.30 干净版）。

## 四、已关门账（勿回锅）
- WQ-Cache 缓存前提（160/160 STALE）；quant 2-row ILP（roofline）；编码宽化边界表
  （ffn-3/4/12 赢长链、ffn-5/6 输短链/故意冗余）；PW32/SPLITC/ACCSLM（GRF 三杀）；
  qfuse_take_b 按 id 查（+25，QFALIAS 按指针已修但 colslice 扇出形态算术判死——
  除非 scale 预给设计改变流量，见 S2a）；f16-OUT（store 段 <1ms cstop2 实测）；
  节点合并（0.7µs/节点）；1267 dtype 改 f16（golden 锁死）；B6-1 五件套形态（+1.08）。
- 前辈负结果清单同样有效：C128/C64 persistent、C512 proj 共权重、MAKE_RESIDENT spike。

## 五、开关表（当前件）
NR_CHIP_CS=0 退 CS2 | NR_FF9=0 | NR_FF3=0 | NR_FFN_CHIPRES/TILE/DUAL/MEGA |
NR_WQFUSE=1(实验) | NR_Q_FUSE_B=1(QFALIAS 实验) | NR_QF_B1=0/1/2(pack 形态/归因) |
NR_WB_V3 / NR_WB_SPLIT（v4full 逃生）| NR_GA_TILE / NR_GA_MERGE | NR_V9B=1(证物) |
NR_*_STOP 家族（time-only，模板化的走 CSTOP）| NR_RUN_TIMING=1 | SM_LW（mega 阶梯）

## 六、文档索引
- 本蓝图 = 战略与军规（改动需明说）
- notes/b1-blueprint.md §6.19-6.30 = 刀账明细（历史战果与判决）
- notes/lmxx-architecture-comparison.md = 架构对照全文（三套账+勘误链）
- src/gpu/*.comp 头注释 = 前辈坑清单（读侧折/scale 预给/32KB 死限）
- refs/lmxxf-src（c5556c7）= lmxx 3080 分支；hip-port=71 层完整模型架构账
- .workbuddy/memory/2026-10-31.md = 本窗口流水（交接卡四份）
