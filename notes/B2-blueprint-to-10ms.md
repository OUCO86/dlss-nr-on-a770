# B2 战役蓝图（2026-10-31 立；军规原文继承自 §100 总蓝图，本文件只做补条与战线更新）
# 权威军规原文 = notes/section100-blueprint.md 的「🚩🚩🚩 底线」一节，逐字如下，不许改写：

════════════════════════════════════════════════════════════════════
## ⚑⚑ 底线（军规，任何一步不可违背）【§100 原文】

**数据链路健康是根本。破坏了它，做什么都白搭，之前所有工作全部作废。这是不可碰的底线。**

1. **不出现小 M**：GEMM 必须宽 M 大 tile（R8a）；batch 进 grid 维，绝不拆成一堆小 dispatch。
2. **不出现中间量化往返**：全程 int8 直通 + 单一世界；quant 只在 plan 规定处发生；
   不为省时间放宽任何数值标准（改数值形态必须先过 numpy golden 考古，过不了就地死刑）。
3. **不出现额外开销**：CPU 不碰像素路径；无 host pack/download；无多余 launch；
   无多余 buffer 往返；不为绕路新增搬运。
4. **照搬的是思路，不是代码**：前辈 coopmat/Vulkan 的实现不能直接搬进 SYCL/ESIMD；
   可搬的是结构（resident、fold、SLM staging、acc-via-SLM、epilogue-on-accumulator）。
5. **每步三关**：39 独立门 GREEN → 端到端 recorded walk 100.0000% 0 mismatch（vs bk 基线）
   + 确定性两遍 100% → 同热交替 A/B 计时。任何一关红 = 当场回滚，不过夜。
   否证也要落盘（否证是资产）。
6. **每步流程**：先查参考（文件:行）→ 写明"学到什么、因此改了什么设计" → 先立门再写码
   → 动手 → 三关 → 自查违规（小M?中间量化?额外开销?CPU牵扯?）→ 提交推送 →
   部署 md5 入账 → 游戏验收画面。

## ⚑ 健康链路验收标准（三关细则，=军规 5 的操作化）【原文口径】
- 门全套（现 1250 门，build_sycl_dll.sh 内嵌）GREEN；
- recorded walk 100.0000% 0 mismatch vs bk.1301.bin + **passes=691 必查**（少=op 被吞）；
- 确定性两遍 100%；同热交替 A/B；单家族账本 delta 不能当判据（挪账假象），
  判据=同热端到端 A/B；16 对协议（赢≥10 且均值≤-0.5 转正；±0.5 带内留形不吹）。

## ⚑ 本战役新增补条（2026-10-31 血案入账，编号续军规）
7. **收益优先**：参照 lmxx/前辈布局的改动测出负收益=我的实现有问题，不是方案错。
   第一动作=找解决方案把收益弄到手；负账必须写"实现错在哪、下一形状"。留开关留仪器。
   （正面例：CS2 v1 半闲置+0.22 → v2 全员有活干 -10%。）
8. **先测量后开刀**：假说先 <10 分钟探针判生死再开刀；禁止烧完整实现才发现错靶。
9. **诊断不得改变被测量**：运行时 if 探针会毒化寄存器分配（cs4 壳 1.28→0.005ms 案）——
   进核诊断一律 if constexpr 模板参数或闭包级 stop；分段账必须在带/不带诊断对照下测。
10. **缓存/跳过/折并的"不变"前提先 VERIFY**：内容稳定性用 diff 探针实测（WQ 案
    160/160 STALE）；三关（对错）永远先于 16 对（快慢）。
11. **引用外部数字先答三问**：哪个模型（71 层完整/31 块 Small）、哪个分辨率、
    什么形态（本会话两次栽：带宽借口、31-block 误读）。规格必查官方（Intel ARK/NVIDIA）。
12. **自己续跑**：失败/未到结论当轮自愈继续，不等催。

════════════════════════════════════════════════════════════════════
## 一、战线现状（2026-10-31，接 §100 的 P1-P8 序列）

- §100 蓝图早已写下：**理论地板=健康链路+全程 resident+int8 直通+宽 M ≈ 10-15ms**；
  中期 ≤24ms、终局 10-15ms；"跑不赢前辈就是丢人"。B2 不新造路线=把 P 序列跑完。
- 现状：walk 带 **66.2-66.5 冷**（部署位 `1cb94804`：CS2 全家族+QFALIAS 资产 OFF+
  cstop 模板探针）。同机 ground truth：前辈 coopmat 件实测 **47.19ms**（=超越对象）。
- 里程碑账（§100 口径更新）：463 → 214 → 127（10-28）→ 112.5 → 74.5 → **66.5**。
- 腿账 v4（关键路径靶序，CS2 件实测）：ffn -9.5（stem-4.7/main+merge-4.5）|
  quant -5.8 | unary -5.0 | wa -6.2 | gemm 三兄弟 ≈0（overlap 隐藏，串行 64.7）。
- 流量精确账（plan census）：1267=26.7GB(47.7ms@560 屋顶) + 1274=17.3 + 1272=8.9 +
  其余≈7.6；L2 命中修正后前辈 47.19≈其残差屋顶。**我们的 19.4ms 超额=latency 泡**
  （s8v8/qkv 有效 100-190GB/s vs laws 在途 592-734）。

## 二、作战序（= §100 P5/P8 + B2 战线的续跑，按 lmxx 71 层架构账排）

lmxx hip-port（71 层完整模型，9070XT 从零重做）实测架构账：~160 发 launch +
块内融合打穿 + persistent stage（ready-queue，197→179）+ W5 五 wave LDS 共权重
（读÷5）+ 逐核 roofline map + 微观数值刀；900p 7.6/1080p 10.4ms。其负结果清单
（C128/C64 persistent 不值、C512 proj 共权重更慢、MAKE_RESIDENT 不复现）与
前辈 fused.comp 头坑清单（on-chip 测 peak 碎 int32 累加器 27.1 vs 14.8；scale
必须生产侧预给）= 已付学费，先读再写（军规 6）。

1. **S2a 读侧 quant 折进 residual-gemm store epilogue**（=§100 P2 未竟的 residual
   侧+P5 行-max 的合流；104 对相邻已 census：resid 写 1267 → QUANT_WINDOW 读，
   写读严格相邻）：预期 -12ms。图纸=前辈 gemm_staged_int8_fused.comp（读侧版）+
   residual_epilogue.glsl 的 image 槽映射（写侧版）；scale 走 publish 预给（军规 2
   的合法路径：quant 只在 plan 规定处发生=折进 store 不算新增往返，反而消往返）。
   判官=bench_res 定价 → 三关 → 16 对。**破 47 第一铲。**
2. **S2b 小 op 折邻块**（lmxx 0.36#8）：unary 32 发/UPSAMPLE 折前后 gemm 边界；
   wa 供数审计先跑（闭包级 stop，零核内探针）。-3~5ms。
3. **S3 persistent stage = 现主刀**（lmxx 0.37#3；=§100 R8a/P8 megakernel stage 化）：
   同层 9-op 周期按 6 层 stage 粒度串 resident 链（B6-1 五件套教训=粒度，不是方向）。
   -5~8ms。
4. ~~S4 W5 权重共享~~ **10-31 判死**（上条关门账）：s8v8 密度账的 5.3x 是片段结构必税，
   唯一例外 K=64 家族 1.05x（0.28ms/帧，不值三关）。密度刀清零。
5. **S5 逐核 roofline map 制度化**：RUN_TIMING(第二遍) × 每行 bench 单价，离屋顶
   >2x 排队修。每窗口一跑。

## 三、已关门账（勿回锅，全部实测判决）
WQ-Cache 缓存前提 | quant 2-row ILP（roofline）| 编码宽化边界表（ffn-3/4/12 赢长链、
5/6 输短链/故意冗余）| PW32/SPLITC/ACCSLM（GRF 三杀）| take_b 按 id 查（+25；
QFALIAS 按指针已修但 colslice 扇出算术判死，除非 S2a 的 scale-pregive 改流量）|
f16-OUT（store 段 <1ms）| 节点合并（0.7µs/节点）| 1267 dtype→f16（golden 锁死，
军规 2 死刑已判）| B6-1 五件套形态（+1.08）| v5-8x8naive（§100 封存）|
**B6-1 五件套 10-31 复判（仪器修复后真账）：bench_b6 旧 trio 计时=0 是仪器坏
（per-event profiling 对 4 个 shipped 核返回 0），修成 wall back-to-back 后
ratio=1.00（510/558 两形状）；帧 16 对=8/8 全负 均值 +1.42 → 形态真死。
教训=**消 4.6/4.2/2.1MB 小面往返=零收益（L2 早吸收了）；1267 的 66.8MB
大面 R278 才是 DRAM 真身——S3 的靶不是"小链合并发"，是大面跨层驻留**。**
rowsplit quant（10-31 事件计时 7/7 形状 0.33-1.0x；§6.6-3 的 59µs/发=wall-clock
伪账）** | **quant 腿旧价 9.5→新价 5.8（CS2/s8d2 时代）** | **f16-pack 标量残留
（GA 三 pack vec 化 ≤0.067ms/帧不值；vec 小 per 反慢=pack_a16_v 192x512 0.015→0.044
已证；pack 真身=gather traffic 本体）** | **S4 GRF-resident-B（bench_s8w5：K=64
1.05x / K=128 0.72-0.78x 全 EXACT——B 片段 8x SLM 冗余=dpas 8x8x32 的 wi_row 数
=片段结构必税，SLM 省与 occupancy 零和；lmxx W5 是 AMD wave64 跨 wave 共 LDS，
Intel 片段结构无对应物）**。

## 四、开关表（当前件）
NR_CHIP_CS(默认ON) | NR_FF9/FF3(ON) | NR_FFN_CHIPRES/TILE/DUAL, MEGA(OFF) |
NR_WQFUSE/OFF | NR_Q_FUSE_B/OFF + NR_QF_B1 0/1/2 | NR_WB_V3/SPLIT(逃生) |
NR_GA_TILE/MERGE(ON) | NR_V9B/OFF | NR_*_STOP 家族 + CSTOP 模板 | NR_RUN_TIMING |
SM_LW | 分支=b1-wblock-resident（origin 已推）。

## 五、文档索引
- 本文件 = B2 战线入口（军规补条+作战序+关门账）
- **notes/section100-blueprint.md = 军规原文+P1-P8 全史+理论地板推导（最高权威）**
- notes/b1-blueprint.md = B1 战线明细（§6.19-6.30 刀账）
- notes/lmxx-architecture-comparison.md = 三套架构对照+勘误链（14:5x 版）
- src/gpu/*.comp 头注释 = 前辈坑清单 | refs/lmxxf-src/Development/hip-port/CHANGELOG.md
  = 71 层模型架构演化账 | .workbuddy/memory/ = 流水
