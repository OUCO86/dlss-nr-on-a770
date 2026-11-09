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
13. **计数类普查必须先声明"只数 captured graph 区"**（`plan_960x544.c` line 5308-6643 = steps 3915-5250）。
    plan 里有两份 recording：scratch 期（begin@line3922 → **abort**@line5295）与捕获图区；每帧只重放后者。
    **两区相加 = 2x 假账**（已确认受害："160 幸存 quant"→80、"104 QUANT_WINDOW"→52、N=32 batched"×16/×24"→×8/×12、
    1267 的 W122/R278、"残差往返 400 次"、"真实流量 8GB/帧 = 14ms 地板"——**按图区重算地板 ≈7ms ⇒ 10ms 目标因此更近**）。
    硬交叉核对法：图区 `OP_XMX_REC_*` 之和必须 = 判官 `passes`（现 691）。工具 `tools/opcounts_graphonly.py`、`tools/blockseq.py`。
14. **任何"家族价"必须先证"帧上可达"**（守卫静态求值或 closure 级探针），否则那可能是**死代码的价格**。
    判据固定三段：①**可达性** → ②**bench 单价**（同进程、min-of-15×5 组、msM、逐字节 diff=0）→ ③**帧 A/B**
    （env 只设 B 侧，A 侧必须 unset——空串在 C 里=真；16 对，必要时 32-48 对）。
    `NR_RUN_TIMING` 的 154ms 是逐闭包 wait 的**地面真值**；要修的是"从 bench 家族价外推刀收益"那一步。
    实案：刀 C 报 −6.1ms/帧串行，探针证明那 20 发走 P8-b wide-merge（:2478-2503 默认 ON，`wide_ok` 20/20 命中）
    ⇒ `gemm32_b + 独立 publish` 帧上从不执行；刀 C′ 重定价后 bench −1.05ms → 帧 −0.466ms（48 对，**存活率 44% ≈ 家族 43%，第一次两口径咬合**）。
    另：`*_STOP` 探针与任何诊断打印**永不记收益**；**shipped 注释里不许留死路价**。

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
3. ~~RES8 字节面~~ **10-31 20:4x 两刀合判（数字见关门账）**：
   (a) 流量前提被静态 plan census 推翻：§6.22 的"1267=26.7GB=47.7ms 屋顶"把
   每次调用按整面计数——实际每 op 只碰金字塔切片（M=32640×N=64=4.17MB，不是
   66.8MB）。真实 1267 触量 = W500MB+R1.16GB；全帧计数 5.2GB（含 window_block
   等约 +2.6GB）≈ 8GB = **14ms 地板，不是 47.7**。帧 66ms vs 地板 14ms =
   **帧不是流量 bound，是 latency/staging bound**（laws 100-190 vs 592-734 一致）。
   前辈 47.19 同 regime——"贴屋顶"叙事作废。(b) RES8 数值：真实 1267 面 pow2
   行-scale e4m3 往返 = 面内 SNR 32.5dB；120 层残差链仿真（同噪声流对照）=
   **17dB << 40dB 批准线** → 字节面在大环流面上数值死刑（lmxx 的 E4M3 skip 面
   成立因为那是单次 publish 无累加的面，我们 1267 是累加流）。
   ★ 重定向后的大刀 = **S6 块驻留+全核 roofline 化**（把 8GB 从 ~120GB/s 有效
   推到 500+GB/s = 帧 66→~15-20ms）：persistent stage 化同层周期、
   中间量出核前穿 LDS/寄存器、每核对着 bench 单价+RUN_TIMING 离屋顶 >2x 排队修。
   s8d2（2.5x 小 M 家族）与 ffn-12/CS2 是这个战役的第一批砖。
3. 旧版 RES8 立项记录（保留备查）：
   1267 残差面 f16→**行-scale E4M3 字节**（lmxx 3080L 路线 A 同款：核名 b8/b8d、
   `residual scale f32[] + E4M3 bytes`）。bench_res8 实测：写 0.555→0.417、
   读 0.606→0.402 ms/触（解码 ALU 免费）；帧 W122+R278 冷回放净省 73.5ms，
   L2 修正后保守 **-15~25ms = 第一把真大刀**。数值有损（6.25% 相对步长）→
   验收 = 对 bk.1301 PSNR≥40dB + NR_RES8=0 逐位逃生门（旧路不删）。
   手术现场（plan census 钉死）：
   - 写者 4 处：gemm_b_res c=1267（×120，flags 0x41100 epi1，pub_vec 后
     行 peak→scale→byte 化；BN=64=N ⇒ 整行在一个 WG 内，SLM 128×4 partial
     max + 1 barrier 即可）；ffn_chip 三族 out=1267（stem ×2/main ×16/merge
     ×2）；xmx_rec_gemm c=1267（f16 族 ×2）；初始 blob 上传转换（×1）。
   - 读者 5 处：GEMM_WINDOW_INT8_RESIDUAL skip=1267（×104，half_skip 形改
     byte_skip：64B 载+行 scale 解码）；GEMM_INT8_RESIDUAL skip=1267（×16）；
     QUANT_WINDOW source=1267（×104，gather 读=qr_kernel 的 e4m3 解码支路，
     前辈 quantize_row.comp 本来就有 e4m3 容器支路=图纸）；QUANT source=1267
     （×16 rowthread 读）；FFN skip=1267（×20）。
   - buffer 层：1267 分配 = bytes/2 + rows×4 scale（recorder 侧记账，
     g_bufs[id].bytes 语义不变）；blob 上传走转换核。
   判官 = PSNR(bk.1301) + 三关(逃生门) + 16 对。开工序：先 gemm_b_res 写侧 +
   window-resid 读侧成对切（同层闭环）→ walk 对拍 PSNR → 再推 FFN/QUANT 面。
4. S3 persistent stage（=§100 R8a；RES8 之后的第二铲：消 1267 边界读写本身，
   400 触→71 触）；B6-1 教训=只融小链不动大面。
4. ~~S4 W5 权重共享~~ **10-31 判死**（上条关门账）：s8v8 密度账的 5.3x 是片段结构必税，
   唯一例外 K=64 家族 1.05x（0.28ms/帧，不值三关）。密度刀清零。
5. **S5 逐核 roofline map 制度化**：RUN_TIMING(第二遍) × 每行 bench 单价，离屋顶
   >2x 排队修。每窗口一跑。

## 三、已关门账（勿回锅，全部实测判决）
RES8 字节面（两度判死钉死：(1) 数值 17dB<40dB；(2) 质量放开后 in-kernel 实测
bench_res8cmp gemm_b_res8 vs gemm_b_res = 0.76x/0.61x/0.60x/0.49x（SNR 35.4dB 达标
但核反而慢）——根因=这些 gemm 核离 DRAM 屋顶 10-19 倍（32640x64x64 写 4.2MB=7.5µs
roof vs 实测 108µs），字节减半省的是本来就只占 <10% 的 store 腿，encode/hmax/SLM
别名 tile 往返的 ALU 反而净亏。字节面=死路，与画质无关，与"核不贴屋顶"有关。）|
★ 同一测量钉死真靶 = gemm 三兄弟跑在 XMX 的 1% 与 DRAM 屋顶的 5-10%：density
campaign（blade-4 已证 22ms 先例：砍标量 store/pub 群）。下一刀序=bench_res 家族
单核解剖：gemm_b_res 108µs/发 vs 前辈同 op ~50µs（47ms 帧反推）= 2x 差距在
epilogue 的 256 标量 fma（golden 锁）+ dpas 短 K；batched pub 尾同刑。| §6.22 整面流量计数法
（每 op 按整面计=16x 高估；真实 8GB/帧=14ms 地板，帧=latency bound）|
PGRAPH 多流并行（11-01 建成并实测判死：691 闭包 touch-set 全登记、贪心波次
规划器输出 waves=691/maxwidth=1 = 帧是严格串行依赖链（每层读写同一条残差流
+ 金字塔共享 pk/scale 面），op 间零可挖并行度——双流跑 156ms 纯因每波 barrier
开销。双流/四流=死。链的短路只有一条=减环节数=融合，而融合唯一没试过的
形态 = lmxx C256 persistent ready-queue（6 层一 launch，链 691->~115 环节）
= S6 本体，非 B6-1 那种小链。）|
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
21. **`OUT_OF_DEVICE_MEMORY(39)` 不等于字节不够**：越界读设备指针同样报 39。
    "失败点还能单块分配 1074MB" 这类 memprobe 数只证明**字节池没满**，不证明**本次请求合法**。
    查序固定：**先算 请求字节 vs 分配字节**（`std::vector<T>(n)` = n 个 T，不是 n 字节；拷贝长度一律 `size()*sizeof(T)`，
    且分配处与拷贝处必须出自**同一表达式**），再谈配额/驱动。正案：2026-11-01 C2 的 `scB`（分配 130,560B、请求 522,240B = 4.0x）被误判成"staging 配额"。

════════════════════════════════════════════════════════════════════
## 军规 0 修订（2026-11-02 02:2x，用户放权）——**判官从"逐位 EXACT"改为"画面不闪 + dB 门槛"**
- **目标阶梯改定**：**71 层完整模型 ⇒ 期望值放宽到 ~20ms**；**31 块 Small 暂不解禁**，解禁后再以 **<10ms** 为目标。
- **画质权限**：最宽 —— "只要画面不闪、不明显糊"。硬红线仍保留：**不闪**（时序稳定）与**不明显糊**（细节保真）。
- **新判官（自本日起生效）**：对 vendor 金标 `dumps/bk.1301.bin` 计算 **PSNR / RMSE / worst-frame dB**（lmxx 口径：单帧 + 序列 + worst-frame 三数并列）。
  门槛：**≥40dB = 安全**、**≥35dB = 可接受**、**<35dB 需实机画面验收**；**任何时序闪烁 = 一票否决**（与 dB 无关）。
  `1301 EXACT` 降级为**回归对照**（用于"未改数值"的铲），不再是所有铲的入场券。
- **跳块参考（用户点名 lmxx 数据）**：`CHANGELOG` [#L291](refs/lmxxf-src/Development/hip-port/CHANGELOG.md#L291)/[#L295](refs/lmxxf-src/Development/hip-port/CHANGELOG.md#L295)：
  `DLSS5_SKIP_BLOCKS=42,43,46` ⇒ **−0.20 ms(900)/−0.32 ms(1080)，代价 −3.3dB**，且明写"肉眼看不出差距"级别的安全跳块；
  其余更大的跳表（ViT+C512 up/down）会把 dB 打到 **33-35dB**，属于"NR 等于没开"级别 —— **禁用**。
  ⇒ **我们的跳块铲必须以 42/43/46 为白名单起点，逐块实测 dB，不许照抄大表。**
════════════════════════════════════════════════════════════════════
33. **画质判据不许只看全局标量**（corr / dB / 均值分位数）。正案：2026-11-02 T1（1270 面降 e4m3）机器读数 **corr_min 0.9828、32.34 dB@range、mean|d|/sigma 0.125、p99.9|d|/sigma 0.613** 全在可接受带，**实机却是"彩色大方块"= 结构性灾难**；因为 1270 是按窗/按块的面，坏的是成片区域，被其余 99% 正确区域稀释。
    任何改数值/改面的铲，画质表必须同时给：**(a) per-tile 最差 dB**（64x64 或 128x128 分块，报 min / p1 / p5，不是只报均值与 p99.9）；**(b) 平坦区异常检测**（大片低梯度区域里 |d| 突增 = 色块/台阶前兆）；**(c) 逐通道 corr，A/alpha 通道单独成判**（A 通道 corr < 0.9 直接进"必须实机"名单，不许因 RGB corr 高就放行）；**(d) 最终以用户实机裁决为准**。
    本次唯一出现的预警信号就是 **A 通道 corr 0.614**。
34. **源码级审计结论必须在机器级复核才算数**（反汇编 .text md5、关键指令计数、台账逐列含 simd/module_id 去重）。
    正案：§43 判 1a 融合核 = RACE（只有 SG 级 esimd::barrier），但 DM_BAR=1 把 12 处换成 sycl::group_barrier 后 **ffn2 两段 .text 反汇编 md5 完全相同、signal barrier 都是 8 条** => esimd::barrier() 在机器级本来就是 CTA 栅栏（工具链原文：esimd/memory.hpp:12045 与 esimd/detail/memory_intrin.hpp:651 "generic group barrier"；SG 级另有 experimental/esimd/memory.hpp:42 split_barrier）。反证有牙：dm_probe 多插 1 条 => 变 9 条、asm 尺寸变，证明宏真进设备编译。
    => 本案形态是"源码看着危险、机器上不存在"：verdict 从 RACE 变 OK 只因改了写法而非语义。若不比 md5，就会把一次空操作记成零成本的安全改进。推论：§40/§41 的竞态不是"缺栅栏"，而是别名让读与更晚的写落在同一个 CTA 栅栏区间内仍重叠；barrier_audit 的 REUSE 条目须再分「跨栅栏重叠=真竞态」与「同相内重叠=需查是否同 SG」，verdict 分 source-level / machine-level 两栏。
39. **移植判决必须先定义"完整移植"的可检查清单**（七项：核 / 几何 / 面布局 / 权重编码与 scale / epilogue 折叠 / launch 形态 / 供数路径）。缺任何一项，结论一律标 `移植不完整`，**禁止写"不适用/不适合"**——那是不可证伪的甩锅（M1 当年写"形态不迁移"，真缺的是 `act 48/64` 的几何与 window-major 布局）。判据：整套搬入后若性能不达他们报告量级，先列缺项补全再测；七项全齐仍不达，才允许下形态结论，并必须点名是哪一项被数学钉死。
40. **家族价按 FLOPs 分摊只可用于排序，不可当绝对值**。正案：`violation_ms` 现值来自 RUN_TIMING 家族价分摊，出现 6 行负值 = 分摊失真（不是"合并变慢"）。合并类铲的前置仪器 = 691 行全量 RUN_TIMING 逐发 dump（现在只打 top-25）。
41. **pub 腿代价随 K 变深而塌缩**：浅 K 时 pub/raw = 41-59%（640x512x512: 4.22/10.23），深 K 大 M 时 81-85%（5120x512x512: 17.59/20.79）=> 折叠 epilogue 与胖形状必须同时做，单做一件只兑现一半（与 §47 四腿只有 68% 是 dpas、port-C2 elementwise=61.9% 三面咬合）。
16b. **军规 16 补条（2026-11-03 实测）**：`.ps1` 里写中文注释会被按 ANSI 解析炸（报"字符串缺少终止符"）。=> **脚本与日志一律纯 ASCII，中文只进 .md**；另外 pwsh 自定义函数名**不得撞内置单字母别名**（`h` = `Get-History`，本次撞过）。原有 16 条（改过 .ps1 必重验 UTF-8 BOM）仍适用于含中文的脚本，但**新写的脚本优先 ASCII，从源头免掉这个坑**。
16c. **含中文的账本/日志一律用 python 或 rg 核对行数与内容**；`.ps1` 与机器读的 log 保持纯 ASCII；可能被 pwsh 读的 .md 存 UTF-8 带 BOM。根因（实测）：pwsh 的 Get-Content/Select-String 把无 BOM 的 UTF-8 中文按 GBK 读，汉字尾字节吞掉紧随的换行 => 行数被合并（同文件 python 147 个 LF vs pwsh 87 行）；这也是 16b 那条 .ps1 解析炸的根因。
42. **跨链合并的前置条件 = 同形腿在记录秩序里相邻 + 其输入面不被中途回收/改写**。任一不满足 => closure 级重写不可行，必须上升到记录/计划层换序（port-E 量级）。正案：刀 1 十轮排除，R9 决定性对照（keep+scratch，合并腿只写丢弃缓冲、每腿仍按出货位置发射 => 仍错，证明"重写本身在改图"）；机器事实 = 96 个 residual 站点里相邻（cmd 连续）的同形腿对 = 0，组成员间隔 10 = 一条链长。
43. **violation_ms 地图必须再加一层 filter：这一刀要不要跨链换序**。否则活站 violation 会被当成可回收 —— 实测刀 1（12.08 ms 串行）与刀 3（15.79）撞同一堵墙。
44. **移植判决的"七项全做"必须先证"七项可同时成立"**。正案：port-E 阶段 A —— 他们的核把并行度钉死在 8,160 线程（`grid x LW ≡ ngrp x W` 恒等 + `static_assert(TG==16)` 忠实性禁 + split-K 被 ① 禁 + W/G 抬大撞 64KB SLM 帽，三行 SKIPROW），而 A770 甜区约 130,560 线程 => 七项互斥。结论必须写成"哪几项互斥"（本案：② 几何与 ⑦ 供数在他们的形下互斥），而不是"整套行/不行"。真价值判定：接口（③ 零-pack 布局 + ④ e4m3/scale 编码 + ⑤ epilogue 折叠）可搬且有效；他们的核不可喂饱且带 private 6.3KB / scratch 178-289 条，过不了我们计价腿红线。
45. **跨进程 TOPS 阶梯必须逐进程间隔 >=60 s 并记录 batch 时长**；进程内 min-of-15x5 不防热。正案：同一 `S1 LW16 KN1`，15 进程连跑 P4 中位 15.06，改 60 s 间隔 = 37.7（对齐 port-C1 的 39.6），差 2.5 倍。
46. **任何核进 shipped 前必须过"自重复门"**：同一进程内连发 200 次，每次发射前把跨波交接面 memset 成哨兵（0xA5），与 launch-0 逐字节比，要求 **bad = 0**。单进程约 15 秒，比跨进程 gate 又便宜又强。正案：port 核（lmxx 忠实移植）在 LW=16 档 200 连发里 2-4 次产出不同（dOUT/dPK3/dSC3，出错行全是 16 的倍数 = fragment band 边界；两个 a_scale 反推行峰 256.0 与 288.0 都是 f16 精确值 => 是"别的行的真实值"，组级污染而非乱码）。
47. **低基率竞态（约 5%）不能用 n=10 冷进程判别器归因**：本案 KN=1 LW=32 合并历史 1/20、KN=1 LW=16 0/15，Fisher p 约 0.5 分不出。要么放大样本（>=40 进程），要么改用同进程放大器（军规 46 的 200 连发）。并记住：冷进程判别器还受热态污染（§63 P18）。
48. **ESIMD 里 16 行 tile 的"8 行 fragment 边界"是危险线**：任何跨波 / 跨半片的 SLM 槽与带（band）设计都要按这条线检查。正案：port 核（lmxx FFN 融合核）1000 连发的 8 次自重复失败里，出错行 `row % 16` 只落在 0 与 7（tile 首行与第一个 8 行半片末行），与硬坑 #18(2)（dpas 累加器 fragment 只有 8 行、`select<8,1>(row*8)` 的 row 必须 0..7）同一边界族。另：军规 46 的门上调为 **>=1000 连发 bad=0**（200 只做快速筛）——实测同一 port 核 1 x 200 连发 bad=0、2 x 1000 连发各 bad=4，真基率约 0.5%。
49. **bench 里跨 kernel 的面交接必须显式 `q.ext_oneapi_submit_barrier()`；`q.wait()` 只保证完成，不保证下一个 kernel 读到**。正案：B2a 合成体首跑 4 进程里 2 个 GATE RED，且 RED 错在 REF 侧（`gather_pack_b_b` 出口面 `dBpE` 前 8 字节全 0，输入正确 => REF expand 写出全零 hidden => 下游 8 个检查点全 DIFF）。加三处 device 探针后确认不是 D2H 读空也不是内存压力（当时只分配 120 MB），就是 pack 输出在下一发读之前不可见；插 9 处 submit barrier 之后 6/6 GREEN、cross 两次 IDENTICAL。危害类型 = 随机假红，比假绿更难查，因为它会把"合成体错了"当成结论。
50. **计价腿一律 `DUMP=false`**：`DUMP=true` 的腿每发要多写约 90 MB 诊断面（fScores 16.7 + fProbs 8.4 + pQ/pK/pV 12.6 + fATT 8.4 + gHID 16.8 + gPK2 8.4 + gPK2F 8.4 + ...）。正案：B2 第一轮 ladder 用 DUMP=true 的 CHAIN3 只得 1.2077 vs REF13 1.4126（"只省 15%"），换成出货形态 CHAIN3n 才是 1.0535。做法 = 同一 exe 两形态：**门用 DUMP=true 那套过，价用 DUMP=false 那套取**。
51. **哨兵自重复门比对的面集合必须等于该形态真正会写的面**。正案：`--stress0`（DUMP=false）把 `out1275/pk3` 这类 DUMP-only tap 纳入比对 => 每发假 bad（dout=4,177,908 / dpk3=2,051,314），因为该形态根本不写诊断面（哨兵原地不动）。否则测的是仪器不是核。
52. **台账 label 正则必须验"行数有没有增加"**（漏行不报错）。正案：`spillcheck_port.py` 的 ffn3 正则要求 `INS\d+_5Shape`，实际 mangled 名是 `INS_4ffn25ShapeI`（嵌套名替换）=> ffn3 三行被静默丢掉，台账里看不见这条腿；加宽后 66 行、三行都在。
53. **任何 `DUMP=true` 的腿，tap 指针必须全非空**：nullptr => 设备当场 fastfail `0xC0000409`，且往往发生在 GATE GREEN 之后，极易误判成"门过了但跑不动"。正案：`ffn2::fused<DUMP=true>` 会写 `dpk1/dsc1` 两个 tap，Args 留 nullptr 直接炸（`ffn3` 因跳过 P1 才允许这两处为 null）。
54. **生产者/折叠类改动必须在合成体里成对计价**：单腿最优不等于链最优。正案：R1 零-pack 生产者腿在链里是 **净亏 +0.11 ms**（CHAIN3n 1.0535 vs CHAIN2 0.9413）；两半各自单独价 0.4329 + 0.4109 = 0.844，合成体实测 0.941 => **0.10 ms 是背靠背交接代价**。⇒ 与 §35（折叠铲 +1.78）、§47（int8 只兑现 36%）是同一经验的不同侧面：**"消掉一腿"的收益必须在该腿真正被消掉的那个形态里量。**
55. **背靠背大核的"相互干扰"必须用"无依赖对照臂"分离**（发数与网格完全相同、只去掉 RAW）。正案：C-0 的 `CHAIN2I` = 0.9414 vs `CHAIN2` = 0.9421（差 +0.0007 = 噪声）=> 那 0.12 ms 不是写->读可见性依赖，而是两个 1020 WG / 31-32 KB SLM 大核同进程连跑的相互干扰（L2、占用率、时钟爬升）。推论：单独腿价相加（0.4336 + 0.3862 = 0.8198）!= 背靠背价（0.9421）=> **外推一律用合成体自己的价**（军规 54 的推论）；且半链价与合成价必须在同一冷却状态下测（本案第一遍因未冷却造出过假的"交接代价"，进程内探针 `FFN2L` 才是判据）。
56. **接图前必须做"运行期逐操作数 id + bytes + pitch 对账"**：把每个操作数的 bytes 与 bench 假设逐项核对，校验要同时查 **bytes 上界 == plane_want** 与 **pitch/维度语义**。正案：C-1 的 `NR_ATT5_FUSE=1` 档 1301 差 82.6% 字节、first diff byte 0，根因不是核而是绑定 —— 引擎的 1267 是整幅 960x544（66,846,720 B，pitch 960）而 bench 的 dImg 是 136x240（pitch 240），融合核 P7 gather 与 P11 skip 按 `x + y*image_w` 寻址于是读错像素；而 `P(id,bytes,what)` 只校验下界，buffer 比需要的大就静默放过。另：Q/K/V 面 4,571,136 = 2x(558x64x64) 是 558 窗口的另一实例（plan 首轮录制建 tiny placeholder 后续 resize => id->pointer 在运行期可能指向别的实例），本案链是 510 窗口。
57. **recorder 里任何"改写 closure 体"的融合，必须让 `g_cmds` / `g_cmd_names` / `g_cmds_touch` 三个向量逐位同长同序**。正案：C-1 的 A5 分支多推一条 `g_cmd_names.push_back(__func__)`（645 在 `pgraph_ids`/`flop_note` 处已推）=> name 向量比 closure 多 4 条 = 正好 4 次 fire => `[skip-chains] REFUSED: name offset 695 not a whole recording` => **整套跳块机构静默失效**，表现成"融合数值错了 + 慢 4.4 ms"的假象。判据：`[skip-chains]` 头部行的 `closures / names / name_offset` 在开关两侧必须相同。
58. **诊断签名（军规 32 的新变体）**：**"MISMATCH 恰好等于某颗历史金标" = 配置没有生效的指纹，不是数值改动**。正案：`att5i_on.1301.bin` 与 `bk.1301.pre-skip-1a.bin` 逐字节完全相同（8,355,840 B）。=> 遇到这种"等于历史 gold"的差，**先查开关/配置/计数器（REFUSED、noop 计数、fire 数），再去查核与 REF**——这一条省下的是"抄 REF"那一整铲。
59. **开关默认 OFF 的件，部署进加载位 = 不生效**。转正前必须把开关固化成编译期默认（照 tools/shipped_build.defs 里 T_SKIP_CHAINS_DEF 的先例），并且换位后做三件核验：① out\libxmx.dll 与 oneapi\libxmx_sycl.dll md5 一致；② 该件在不设任何 env 时的 [skip-chains] / fires 计数就是预期档；③ 帧收益的 A/B 两侧都不依赖 env（ab.ps1 会清场）。正案：att5m 部署后才发现 a5_on()（libxmx_sycl.cpp:785）默认 false，16 对是靠 B 侧设 NR_ATT5_FUSE=1 才赢的 => 当场退回 ABB969FE。
60. **引擎侧自重复门 `NR_SELFREP=N`（军规 31 的加强）**：同一进程连放 N 帧，每帧下载 1301（8,355,840 B）与上一帧逐字节比，**从第 10 帧起比**（plan 回放有跨帧 history，run0 vs run500 合法不同，稳态才是基准），要求 bad=0。任何新接入的融合腿都要过这一门——bench 的 200/1000 连发只测单核，测不到图内真实操作数与跨帧状态。正案：NR_ATT5_FUSE=1 档 runs=1000 compared=989 bad=0（约 7000 次融合 launch）。仪器 = src/gpu/nr_replay.c 的 NR_SELFREP（presence-gated），builds/nr_replay_sr.exe = 9FB2ED24。
62. **身份守卫必须读单一出处，不许写死常数**。正案：第 40 门 `gate_skip_graph` 以前写死 `abb969fe…`，于是每次转正都会产生一个"按设计 RED"的门，把实质检查（skip 计数、三进程 1301 逐位 = 新金标）淹掉，还让人误判"变体没过 40 门"。现在读 `out/SHIPPED_MD5.txt`（缺失即 RED，不许静默放行）。推论：任何"工件是不是当前转正件"的判断都该由一份 md5 清单驱动，而不是代码里的常数。
61. **witness 计数为 0 时，必须先确认 witness 开关本身是开的**，再下"机制没生效"的结论。正案：`walk_att5p_noenv.txt` 报 fires=0，实际是那次没开 `NR_ATT5_TRACE`（witness 不打）——差点把"编译期默认 ON 已生效"误判成没生效。推论：每个 witness 都要有一行"开关状态"自证（例如打印 `TRACE=%d FUSE=%d`），否则 0 无法与"没看"区分。
63. **SLM / occupancy 类手术之前，先算两件事：同形 compute anchor（占屋顶 %）与 DRAM 占比（相对实测带宽）**；两者都不 binding 就别动 SLM。正案：WB 驻留铲 —— c1/c690 各 4.24/4.28 ms，DRAM 只占实测带宽 3.2-5.6%（权重全按 miss L2 算也只 10%），compute 已贴 xmx_roof.csv 同形锚点最好值（2.02-2.17 vs 2.20 TFLOP/s），resident 1->2 不解结 => 历史兑现率 9%（上限 -3.9ms 串行 vs 实测 -0.365/32 对）正是应得数。推论：window_block 这两发要再快只能换 tiling / 提高复用因子（更大 N/K、把窗口合并成宽 M），而这落在换序墙（军规 42/43）的射程里。
65. **witness 必须打在"被观察的那次改动之后"**：record 期的 `[pgt]` 打不出 capture 期的换序，比较会得到 "changed=0" 的假结论。正案：B 第二步第一版 touch diff 假干净 => 新增 `[pgt-final]`（capture 后对冻结向量打）才真能验声明集合。推论：每加一种"改动时机"，就要配一个对应时机的 witness。
66. **id 镜像只记能解析到 live buffer 的 id**：同一 initializer_list 里混的 flag 字（例 `134221248` = pooling 位）跨进程值不稳，会让 touch/依赖 diff 看起来非空。
67. **`NR_SELFREP` 仪器有累积/泄漏型退化**（不是竞态）：每帧耗时单调爬升（63.5 -> 89.3 ms，单帧最高 2295；另一臂 71.3 -> 174），并在 run 659 / 906 处崩死；同一失效模式在 §95（没有换序的 att5o2，run 528）就出现过。=> **军规 60 的门在修好仪器之前只算"部分可信"**；修法建议：每 ~250 帧重启进程、每帧只下载单面、定期清 pool/graph；**并始终跑一个 OFF 对照臂**（本案 OFF 对照 1000 帧 bad=0，才把病因定到仪器而不是换序）。
68. **判"能不能换序"必须用角色感知模型（RAW/WAR/WAW，按 recorder 签名分输入/输出），调度器代理（任意共享 id 即冲突）只能当安全上界**。实测：691 闭包 / 238,395 个有序对里，代理约束 175,538（73.6%）vs 角色感知 134,784（56.5%）；且 `236>237` 按代理 blocked、实际换序后 1301 逐位 EXACT（读-读型无害重叠）。
69. **任何按"面"做的分析，必须先用 [bufnew] 把 plan 表 id 映射到运行期 id**：xmx_buf_create_kind@1250 每次 g_nextbuf++，第一次录制造 id 1..1301、保留那次造 1302..1313（同一 plan 面两次录制 id 不同，偏移 +33..+36）。正案：§109 用 plan 表 1272/1273 去减运行期 touch 集 = 减了个空，导致"版本化后 maxwidth 仍是 1"的假结论；映射后 {1305,1306} 私有化让 maxwidth 1->4、可挖头部 0->12.06 ms 串行。
70. **往 dll 里加打印时，任何下标表达式先算边界**：本案 [bufnew] 初版写 g_cmd_names[names.size()-cmds.size()+cmds.size()] = names.size() 越界，跑前肉眼逮住；这类错在运行期以 fastfail 出现（0xC0000409 同族）。
71. **判"某个只影响 touch/依赖图的改动能不能买帧"之前，先确认出货执行器读不读那张图**：cgraph 单流按记录序重放，根本不读 touch set => 任何"松绑约束"类改动在默认路上按构造收益 = 0。要么同时换执行器（PGRAPH），要么把这类改动定性为"前置"，不许报帧收益。
72. **"删面/删边"式的反事实是错的建模**：任何"放松依赖"的假设必须改成"重定型"式——在实测的指针视图上跑同一台规划器，并先做"模型 vs 实测"牙齿检查再报数。正案：§110 用"删掉 1305/1306"算出 +12.06/+30.88 ms 头部，实测版本化后 waves/maxwidth/关键路径一字不变（头部 0.00），因为真实版本化把一条依赖拆成 K 条独立链，生产者与自己的消费者仍共享同一物理面（只是换成另一块）。
73. **依赖图类结论要先问：这条边是真数据流还是 scratch 复用**。正案：closure 300 的 quant -> gemm_int8_batched 共享 1305/1306 是真数据流，且被 1308(180)/1307(135)/1303(78->71)/1310(68)/1309(60)/1313(55) 同时持有 = 过度决定 => 691 闭包的串行不是假串行；换序空间实测上限只有 1.66 ms 且 5 个可行组全是 xmx_rec_unary（不是合并靶）=> 换序器不建。
74. **屋顶倍率 != 收益**：任何"合并/换形"的帧价值必须先跑同进程成对单价（>=10 独立进程、进程间 >=60s），屋顶比只用来判断"离顶多远"。正案：刀 2 的 −1.64 帧按屋顶倍率（1.58/13.5/19.7）估得，实测 ratio 0.70/0.73/0.82 => 帧价值为负、−1.64 作废。胖形状类铲一律"先 bench 成对单价，再动引擎"。
75. **块对角 wide 合并按 b 倍多算 FLOPs**（合并形 M x N*b x K*b = b^2 份单组功、真活只有对角 b 份）=> 只有当"拆腿形每次 dispatch 欠填充"时才划算。P8-b 当年 3.5x/6.14x 合并的是 N=32、b=2..4 的每条一闭包旧形；对已经"一次 dispatch"的 batched 站点（R8a：batch 在 grid 的 z、pack_A 一次、pack_B 一次缓存、gemm 一次、publish 一次）放宽到 N=64/256、b=8 必亏。真正零额外 FLOPs 的胖形状是 fat-M（M 乘 b、N/K 不变），靶单 tools/fatshape_next.csv：fat-M 活站 38、有同形屋顶 30、上限 <=16.237 ms 串行；最大簇 = xmx_rec_gemm_int8_residual 192x1024x4096b1 -> 1536x1024x4096b1（closure 316..379 八站，9.49 ms）。
76. **跨链合并的前提是"成员写不同面"**：写同一面 = 残差链的连续环节，不是并列射击 => 合并非法。正案：全帧同形对（gap<=40）244 对，LEGAL=0、BLOCKED=244，且 244/244 挡因都是 shared-output；A4 八站写同一块 1267 且每发输出在 +1 处就被 QUANT 读走，输入面只活 1-9 个闭包（site316 的 Araw id=1286 / a_scale id=1287 被紧邻 317 QUANT 改写，skip id=1285 被 321 改写）。推论：本引擎里能消的只有"链内相邻环节"（融合），不能消"链间同类环节"。
73b. **相邻性口径与 defer-and-merge 口径不能互读**：reorder_space.csv 判"挪闭包"；defer-and-merge 不挪闭包、只把前面几发的 gemm 推迟到最后一发处发射。用前者判后者 = 方法错误（§114 到 §115 的纠正）。
77. **排序/筛选口径必须匹配被筛对象的真实结构**，且未映射区不得连段。正案：融合候选普查 v1 用"同族相邻段"筛 => 几乎全是 none，因为本引擎的融合是"同一链上相邻的**不同族**腿并进一核"（A5 = quant_window->qkv->wa->… 五相一核），而 §106 已证同族相邻对 = 0 => 用已知为零的口径筛不出东西；v2 又因 scope 回落把未映射区（C512 attention 区不在 chain_map 闭包范围内）连成 16-17 腿巨段 => 上限虚高；修 = 段长封顶 8 腿（一条链实际 6-11 个 op：A5 并 5、S6-1a 并 6、port-E CHAIN2 并 11 个 plan op）+ scope 标签统一。
78. **屋顶表是按机制分型的，不能跨型借用**：`xmx_roof.csv` 的点是 gemm 腿（dpas 屋顶，`gemm_b`/`gemm_b_pub`），而 attention/window_block/global_attention 三族 0 个同形点（qkv 0/60、wa 0/52、ga 0/8、wb 0/10）且它们的地板是带宽型（整面字节 ÷ 实测 560 GB/s）。=> 要判这两族的倍率必须先造带宽型计价臂，不许拿 gemm 屋顶或内插替代（军规 26/35a）。
79. **任何组号 / 下标 / 枚举值必须用被控程序自己打出的名字回验**，不能拿源文件里数出来的顺序当口径。正案：B3-b 按 pe_k3_roofgroup.py 报的 SRP_GRP=45 跑了 3 进程，日志打出的是 G45_wb_534336 => probe 内部下标 != 源文件行序 => 测的是已有屋顶点而不是缺的 130560x32x128；发现后当场 kill 剩余批次，且因 B3-c 已死该缺形没有消费者 => 不补（军规 26/35a）。
80. **判"某机制有没有做"要扫该记录器里所有默认 ON 的开关 + 无条件调用**；"没开关"不等于"没融合"。正案：xmx_rec_ffn@3128-3190 里 NR_FFN_TILE + NR_FFN_CHIP 默认 ON（ffnc::launch_ffn_chip，注释写明 ONE launch、hidden 永不下芯片、连 pack_a16 都吃掉、bench 4.4x、BIT-EXACT），我 §116 只看 S6 的 s6_family(C,HID) 就把 ffn 八站标成未融合；更深一层 gemm_int8_residual 没有开关但正文直接调 s8v8::gemm_b_res（gemm+残差一核）与 packdev::pack_a_fused => 无条件融合。推论：排序表里"未融合 => 可并"的行全部要重标，真正的剩余空间是"每族还剩几次发射"。
81. **逐位等价的融合，字节测试没有判别力**：关掉机制后 1301 仍 EXACT 只说明"换一条更长的路算同样的值"。=> 机制存活判据 = 时间差（且按军规 35b：1 次 walk 只当筛子，>= ~1.0 ms/帧 要 16 对定案，更小标"未分辨"）；字节不变在此是好消息（机制数值中性）。正案：八臂（FFN_TILE / FFN_CHIP / G_FOLD / GA_MERGE / WA_MERGE / GA_TILE / WB_FUSE + 基线）1301 全部 EXACT DD49827D，而 off-差分别是 +25.55 / +6.08 / +4.99 / +0.61 / +0.54 / +0.38 / +0.08 ms/帧。
82. **用 enqueue 类代理数"还剩几次发射"不可用**：NR_SUBMIT_PROBE 四臂显示每个家族 enqueue 近乎减半、连与开关无关的家族也 -0.3~-1.3 => 冷启动/首跑效应主导；且它跑的是普通闭包环不是 cgraph 重放、提前 return => GPU 时间不是出货路时间。=> 要这张图必须每闭包发射计数器（single_task/parallel_for/memcpy/memset presence-gated 或转发 queue 包装），且它动 7,000 行 TU 的公共路径 => 单独一铲，不许当顺手小事。
83. **锚点/屋顶对照必须按记录器自己的相位逐相求和**（flop_note 元组；没有 flop_note 的家族用发射调用实参），不许拿"整条多相闭包"比"单条 gemm 屋顶行"。且 above_phase_roof = 实测 − Σ相位屋顶 只对纯 gemm 家族可读作 kernel 效率余量；含非-gemm 工作的家族（global_attention 的 softmax/归一与 merged 面搬运、window_block 的 gather、window_attention 的 softmax、ffn 的 gelu）那是别的工作量不是浪费。正案：v1 把 global_attention 报成"占屋顶 2%、可挖 11 ms"是假信号；v2 逐相求和后，gemm_int8_residual 不被解释 11.118 ms（77%，每腿 0.34 vs 相位屋顶 0.078 = 4.4 倍差距）是真余量，而 window_block 只有 2.012（17%）=> wb 不是 kernel 级靶，与 §105 两腿 2.02-2.17 vs 锚点 2.20 互证。
84. **锚点必须取 max(相位计算屋顶, 字节地板)**，并把"字节绑定"当作杠杆方向的判据：字节绑定的腿，杠杆是流量（dtype/面宽/复用），不是 tile 填充率。正案：v3 表里 gemm_int8_residual headroom 12.13 ms 且 46/54 腿字节绑定、gemm_int8_qkv 5.52 ms 26 腿字节绑定 => 方向是流量；window_block 只有 2.01 ms（17%）=> 不是 kernel 级靶（与 §105 两腿贴锚点、§98 WB_FUSE off-差 +0.08 三点互证）。
85. **台账工具必须能吐 `private/spill`**：mk_roof_ledger.py 走 ocloc disasm 那条路不吐这两列（要读 .state/.hw 资源段），导致屋顶点上健康闸第 4 条无法执法。=> 任何"计价腿干净"的断言在缺这两列时只能算部分成立，必须如实标注。
86. **台账列名诚实化**：`-` 不得同时表示"键不存在"和"值为 0"。ocloc 1.73 不吐 private_size/spill_size（每核只有 grf_count/simd_size/slm_size/barrier_count + 仅在有 scratch 时出现的 type: scratch size:N 块）=> 必须写 n/a(ocloc1.73)。并要重核历史结论：§60 的 "port::fused private 6,304-6,464 B" 其实是 SCRATCH 字节（spillcheck_port.py 里那两个 g() 恒为 -，数值来自 scratch 块），结论更硬因为 scratch 走 DRAM 比 private 更糟。
87. **解析器固定字符窗是隐形 bug**：窗口 6,000 字符在长 payload 下会把资源字段推出窗外（症状 = 某些行连 slm 都读成 ?）。块边界必须按结构（到下一个 - name: 为止），不按长度。
88. **判"一条腿被什么绑定"要同时算三个地板**：① 计算屋顶（同形 dpas 点）② 字节地板（合计字节 ÷ 实测带宽）③ 波次填充（工作组数 ÷ 可并发数）。正案：residual 族最大流量的腿（c18/c29/c34/c53）实测只有 15-44 GB/s = 560 锚点的 2.7-7.9%，既不贴计算屋顶也不贴字节地板；M=32,640 N=64 K=64 在 BM=128/BN=64 下只有 255 个工作组（不到一个满波）=> 绑定点是波次填充，杠杆是 tiling/发射形状（BM 128->64 => 255->510 WG），不是面宽。
89. **流量模型必须先排除已被融合/no-op 的腿**：把 A5-fused / FUSED-pack 标记腿与 ms<0.02 的腿塞进按 tile 常数推重读因子的模型，会算出 3,300-6,500 GB/s（560 锚点的 600-1,100%）的荒谬等效带宽。正案：traffic_breakdown 第一版如此，排除 7 条后 159 条腿全部合理。
90. **假设必须由它自己的实验判死，不能留在账上当前提**。正案：B 流量表推出"residual 腿绑在波次填充（255 WG < 一个满波）"，而为验证它专门测的 s8v9（行 tile 减半、组数翻倍）在唯一合法帧形 8160x128x128 上反而慢 3.0x（公平口径加回它吃掉的 quant 腿仍慢 1.8-2.1x）=> 该假设当场撤销，不得继续用它给任何刀定价。
91. **屋顶置信标准 = nproc>=12 且 spread<=20% 才算 hard**；不满足的行不得进建议；引用历史 headroom 数字必须同时标 low-conf(spread,nproc)。正案：anchor_gap v4 加置信列后 258 条活闭包里 HARD-anchored = 0、low-conf = 197、no-roof = 61；今晚报过的 residual 12.13 / qkv 5.52 / gemm 3.32 / wb 2.01 / ffn 1.61 全部建在 6 进程或高 spread 的旧行上（旧台账 244 行测于军规 35b 收紧之前）=> 这是历史置信债，不是当晚算错。全台账当时只有两行 hard：gemm32_b_pub 130560x32x128（1.2%）与 gemm_b_rq_v9 8160x128x128（0.6%）。
92. **"实测 >> 字节地板"要先分解那一段差距**（launch / 同步 / occupancy / 依赖等待），否则任何"减字节"的刀都是在 10 倍差距里赌一小块。正案：8160x128x128 的字节地板 7.7 us，出货腿实测 78.6 us = 10 倍。
93. **测量批进行中绝不重建被测件**；批脚本开工必须断言 exe 存在 + md5 稳定；$ErrorActionPreference 不得用 Continue 吞 CommandNotFound，失败必须让批中止。正案：48 进程屋顶批从 rep3 起每轮 CommandNotFound 白占 40 分钟（GPU 没被用机器没热），根因是我在批跑期间编译带解剖腿的新版，那次 icx exit=1 —— icx 失败时不产出 exe 并把旧文件清掉 => 被测件在批跑中途消失。这是 §47"删 exe 后继续跑"的同族，这次是编译失败删的。
94. **设备填充率 = 工作组数 ÷ (EU 数 x 每 EU 驻留数)，是第三个地板，且常常是首要解释**；用设备规格 EU 数时要标"未实测"。正案：8160x128x128 出货 gemm_b_pub 是 NT=32、128 个工作组、SLM 18,432B/组 => 每 EU 驻 65,536/18,432=3 组；A770 = 512 EU（32 Xe-core x 16，规格数未实测）=> 容量 1,536 组 => 填充 8.3%；字节地板 9.4us（pub C，含 tiling 重读 A x2 B x64）vs 实测 78.6us = 6-8 倍；8.3% 填充 => 可用带宽约 1/12 => 9.4 x 12 ≈ 113us 与实测同量级 => 首要解释是填充不足，不是 launch 也不是流量。抬填充只有增组数：BN 64->32（gemm32_b_pub 已存在）=> 256 组 16.7%；split-K（K=128->4x32）=> 512 组 33%。
90b. **军规 90 的正确写法：假设要么被实验判死、要么标"未检验"，不得当前提**。更正：§122 说"v9 把工作组数翻倍所以波次填充假设被证伪"是算术错——8160x128x128 上 v8(BM128/BN64) 与 v9(BM64/BN128) 都是 128 组，v9 慢 3.0x 的原因是 BN=128 的 B-tile + 融合重量化更贵，与填充无关 => 波次填充假设**仍未被检验**。
95. **"腿太宽导致工作组数不足"是一类独立的低效**，判据是实测容量曲线上的填充比。正案：8160x128x128b1 上 BN 从 64 降到 32（组数 128->256）=> 0.0782 -> 0.0370 ms，快 2.1x（HARD：spread 2.2%、12 进程），高于预登记的 1.3x 线；且比 BN=64 那 36 个进程里最快的一次还快 >=1.6x。推论：路由到已有的更窄 tile 核（gemm32_*）是一条不改核、只改路由的刀。
96. **并发容量必须实测，不能用 EU 数 x 每 EU 驻留数推算**。正案：同一空核（NT=32、SLM 18,432B/组）扫工作组数 64/128/256/512/1024/2048 => 2.80/2.90/2.90/3.10/3.55/4.65 us => 真实容量 ~512-1024 组，加组几乎免费（512 组只比 128 组贵 0.2us）。此前用 512 EU x 3 = 1,536 组推出的"8.3% 填充"已被取代（~1/4-1/8）。证据 tools/capacity_curve.csv。
97. **倍率必须与"出货实际走的那条臂"比；屋顶表必须先覆盖出货实现路径**。正案：今晚"BN=32 比 BN=64 快 2.1x"比的是 gemm_b_pub（寄存器尾，未出货）与 gemm32_b_pub_forced；出货 N=128 走 s8v8::gemm_b_pub_slm（libxmx_sycl.cpp:4108-4117，pubslm 默认 ON，注释原文 the N=128 batched family rides the senior acc-via-SLM tail … BIT-EXACT diff 0, 0.148->0.112 / 0.227->0.210 / 0.196->0.150 在帧的三个 N=128 形状上；SLM = HALF ? 18432 : 32768），而 xmx_roof.csv 里没有它的任何行 => 该 2.1x 不能当引擎收益。推论：每加一条杠杆候选先问三件事：出货走哪条臂？它在屋顶表里有没有行？比较对象是不是它？另两条同角落的旧坑：4111-4113 N=64 不配 SLM 尾（the 32KB stage costs occupancy there，0.033->0.074，v9c 教训）；3870-3872 v9b（BM=32 宽 N 合并）0.53-0.80ms vs v8 gemm_b_pub_slm 0.11-0.21ms，且 the v9b default was MASKING C2（那些调用根本没走到 pub_slm）。

98. **设备指针只能用 sycl::free(p, q)**：对 sycl::malloc_device 的指针调 CRT free() 会让进程在打印之后才崩 => 症状是"数据被静默截断"而不是"报错"。正案：探针里 18 处裸 free()（全是我加的 v9 / force32 / pubslm 三条腿）vs 探针自身 11 处 sycl::free => §119/§122 的 v9 批、§124 的 force32 批、本铲第一次 pub_slm 批都是截断跑；已打印的行计时仍有效（崩溃在打印之后），但同批排在其后的腿没跑到。修 = pe_free_fix.py 全部改 sycl::free(x,q)（余 0），重编 exit=0 exe 829,952B @08:16:25 md5 69F58243。
99. **批脚本的完整性闸不只是"exe 存在 + md5 稳定"（军规 93），还必须断言每个进程打出收尾标记（=== done grp=）且行数 = 预期腿数**；否则"部分成功"会被当成成功，台账静默缺行。
100. **填充类杠杆要先问"帧里真实的形状是否已在实测容量附近"**，不能拿相位形的填充比给整个族定杠杆。正案：8160x128x128 b1 出货臂 128 组相对实测容量 ~512-1024 只有 13-25% 填充，但帧里真实的 batched N=128 形是 b4（512 组）与 b2（1024 组）已在满波附近；三臂 hard-vs-hard ratio = 1.09（8640）/ 1.14（9216）低于预登记 1.3 => BN=32 填充杠杆在 N=128 判死。同 SLM 容量曲线（SLM 32,768、n=65 进程/点）：64=>2.50、128=>3.00、256=>2.70、512=>2.90、1024=>3.40 us => 加组几乎免费在出货臂足迹下同样成立。
101. **ratio 的分母必须是 hard 行**（nproc>=12 且 spread<=20%，军规 91）；分母不硬的读数不得用来翻案。正案：8160x128x128 b1 上 pub_slm 0.0759 的 spread 62% => 那条 ratio 2.05 作废，不得用来推翻 8640/9216 的 1.09/1.14。
102. **"核内几何旋钮判死"不等于"挖核线收口"**：旋钮（BN/BM/SLM 驻留/换序/合并）只管形状与调度，判死它们之后仍要问"同一条腿里，乘法和收尾各花多少"。正案：8160x128x128b1 raw gemm_b（int32 C）= 0.0280ms 而 gemm_b_pub = 0.0784ms => publish/尾是乘法的 2.8x；NR_G_FOLD（publish 折进 gemm 存储）关掉值 +4.99 ms/帧 => 尾巴是真金，但它只在 gemm 族做了。我们自己的硬锚点已有 9.33 TOPS（int8 gemm32_b_pub 130560x32x128，12 进程 1.2%），而帧里最贵的腿跑在 1.5-3.5 TOPS => 2.3x 差距在自己核内，不在硬件也不在层数。
103. **同族相邻形状的 time/size 不成比例 = 结构异常信号，必须归因**：8160x128x128b1 的 BN=64 家族三批独立都 ~0.078ms，而 8640/9216（尺寸只差 6%）只有 0.049/0.054（快 60%）=> 不是红利是 outlier。可疑方向：ldc/sc 对齐、M=8160 非 128 整倍数（63.75 个行 tile 的破 tile 尾）、pack_b 的 B 面分桶。
104. **链路中间交流开销（hop）是一等指标，与 ms 并列**：任何"照搬上游数据结构/搬运拓扑"的保留理由都不成立——忠实移植保的是机制与数值语义，数据布局与 hop 拓扑是我们的代码、我们的责任。每一刀必须实测报 hop 次数与字节的变化 + 时间变化，不许只用时间反推。正案：我们的融合（A5 五相一核、S6 六相一核、qfuse 溶解 144 条 quant 腿、G_FOLD 把 publish 折进 gemm 存储、QKV_RES/WA_RES/gemm_b_res 无条件）都发生在相内/块内；而 quant -> gemm -> 写面 -> 再读面 -> 求 row-max -> 再写量化面 -> gemm 这条环与环之间的两遍结构仍在落全局面：gemm_int8_residual 68 腿 20.06ms + gemm_window_int8_residual 52 腿 11.36 + gemm_int8_qkv 60 腿 9.67 + gemm_int8_batched 72 腿 4.86 = 45.95 ms 串行 ≈ 23 ms/帧 作用面。核心算力不是问题：可比形上我们比参考工程公布值快 6.13x（130560x32x128 我们 0.2035ms vs 他们折算 1.248ms），我们 HARD 锚点 int8 22.73/15.4/9.33 TOPS，参考工程自己写着 The kernel wins every row … The path loses most of them。
105. **不许把"臂差"直接当"hop 成本"**：raw gemm_b（int32 C，4B/元素）0.0280ms 与 gemm_b_pub（f16，2B/元素）0.0784ms 之差混着三件事——requantize 算术、store 形态（写更少字节反而更快 => 不是字节数问题）、取 scale 的读。必须先拆再定价（autopsy 的 leg_autopsy.csv 就是拆它）。
106. **hop 的成本有两副面孔**：独立搬运闭包（本案实测 3.08 ms 串行）与藏在生产者/消费者核内的 store/load（本案 hop 字节地板 18.60 ms 串行，差额约 15.5 ms 在核内，与 raw gemm_b 0.0280ms -> gemm_b_pub 0.0784ms 的 0.050ms 尾巴同源）=> 消 hop 必须两条路都走：删搬运闭包（qfuse/G_FOLD 类）+ 改核内 store/load 路径（直通、加宽、就地算尺度）。只用一条会低估或高估收益。
107. **hop 计数按面不按边**：每个面写一次 + 每个读者一次；按边计会 2x 虚高。正案：第一版按边计得 14.7 GB / 26.2 ms，修正为 10.42 GB / 18.60 ms。
108. **子臂时间大于整条闭包时，先做"臂形 vs 出货形"逐项对账（rows/tokens/heads/sc/ldc/batch/epi/flags）与 WG 配置对账（ocloc 反汇编 + barrier_audit），再怀疑缓存效应**；spread > 100% 的臂直接标 invalid 不得引用。正案：smax::vit_softmax_tiled 单臂 2.0179 ms（12 进程 0.1% spread）> 整条 global_attention 闭包 1.41-1.45 ms；先怀疑探针 dSc 未初始化（NaN/denormal）=> 修好重测 2.0178->2.0179 自我否证；f16v1::gemm_b_merge_scale spread 222% 直接标 invalid。另：三个 pack 臂 = 1.14x 于自身地板 => 打包不是坑。
109. **链/区间计时必须双事件括号**：前后各一枚 submit-barrier，区域 = a.command_start .. b.command_end。返回单个事件只报最后一条核的跨度；尾部 barrier 事件只测 barrier 自己（本案读到 0.0010ms 的假值）。正案：探针 chain_* 臂与 COVERED_* 全部作废，改 timeit_region() 后才拿到 ga 的真数（REGION_all6 2.2767ms vs 假 chain_all6 0.0784ms）。
110. **臂级与闭包级读数必须互校；出现"单臂 > 整链"先怀疑仪器再怀疑物理**。正案：vit_softmax_tiled 单臂 2.0179ms > 整条 ga 闭包 1.42ms，先后怀疑探针实参不同（对账证明同形同结构）与未初始化输入（重测 2.0178->2.0179 自我否证），最终定位为计时括号缺陷。
111. **rt_per_closure 的闭包级归因不能当 GPU 时间下界**：ga 括号法实测 2.2767ms/腿（8 腿 = 18.2ms 串行）而闭包归因只有 1.41-1.45ms/腿（11.37ms）=> 低估约 0.9ms/腿。此前所有按家族排序的价格表（含 114.63 串行和）都要标"下界"，并对前几大族按括号法复核。
112. **三套价格口径不许混**：(i) NR_RUN_TIMING = plain-path 每闭包 steady_clock 括住 fn(); GQ->wait(); => 含 CPU submit + GPU drain + 同步延迟，是上界，且量的不是出货路（该分支 libxmx_sycl.cpp:2278-2335 在 2335 行 return passes，出货 cgraph 从 2371 行才开始）；(ii) isolated 单核跨度 = 该 TU 的价（受 inlining/codegen 影响，softmax 探针 TU 2.02-2.43ms vs 帧内 <=1.07ms，见 s6/wbga.md §9c 2026-11-02 早已测出）；(iii) 帧内价必须帧级反推或括号复核。正案：§132 说 RT 低估 ga 约 60% 方向反了已撤回；旁证 plain 帧 72.6 / cgraph 帧 57.4 / RT 合计 114.63 => RT 高于两者，每闭包多付一次 submit+wait。frame_factor.md 的 0.50 是跨路径比不是重叠系数。
113. **动刀之前先量化"排序仪器本身的族间偏差"**：RT 偏差按闭包数放大（quant/quant_window 276 腿 4.04ms 最被抬高；window_attention 52 腿 15.89 与 gemm_int8_residual 68 腿 22.47 次之；window_block 10、global_attention 8、ffn_* 受影响最小）=> 先做 3 族 x 1 形 x 6 进程 = 18 进程括号法复核（<=22 min GPU）拿到 RT ÷ 括号法偏差因子，再决定 softmax 与 B(1) 谁先。
114. **读数打架先搜仓内旧账，再上仪器**。正案：s6/wbga.md §9c（2026-11-02）早已测出 softmax 在探针 TU = 2.0654-2.4330ms 并从帧反推 in-frame <=1.07ms，当时记为"大 TU 的 inlining/codegen 未定位"；两天后我们才用它解释"单臂 > 整链"。
115. **形态类改动要分两笔账：搬运形态（存到哪、少几趟）与数学形态（每元素算什么）**。实测：NR_GA_TILE=0 vs ON（少一趟 dProbs 写 + 少一趟 pack_a16_b）帧差 +0.209 ms（8 对，B 赢 2/8，符号 6/8），与历史 +0.38 ms 同号同量级 => 只改搬运形态的档位单独不值一铲；tiled 与 plain 付同一份行数学，所以该实验既不能否定也不能证明"lane 跨列"那一刀。不许用"该相作用面 ms"暗示数学那一半也会被消掉。
116. **写 esimd 跨 lane fold 之前必须确认运行期 sub-group 宽度（sg.get_local_range()）**：本案 shipped softmax 实例 simd=8，按 32 lane 设计的 fold 距离（1..7、8/16/24）全部越界、语义不成立；且"1 item = 1 行"不等于"只用 1 个 lane"（编译器已把行内循环 8 宽化）。另：local_accessor<float,1>(range, group) 与 sycl::access::fence_mode 在本工具链不存在。
117. **"行被拆给多个 WG"通常是 tile 宽度问题，不是内存布局问题**：先查 ldc/sc 是否本来就是连续 pitch（本案 gemm_s8_v8 传 ldc=N、sc=Mp*N，面 pitch 本身没有交错），再看 BM/BN/BK 常量（BM=128 BN=64 BK=32 NT=32 => 一个 work-group 只写一行的 64 列）。=> 想"每组行连续"只需宽生产者 BN>=N，不需要动 pitch/pack/publish 寻址。正案：tools/layout_interleave_audit.csv 28 个面类，写者 RT_ms(上界) 合计 38.12 ms。
118. **tile 宽度的占用效应非单调，禁止用相邻档位外推**：BN=32 实测 2.1x 快、BN=128（s8v9）实测 3.0x 慢、BN=256 未知。代价项：SLM_B = BK x BN 线性涨（32x256 = 8KB + SLM_A），累加器 WI_ROWS x WI_COLS x 12 > 8 落在 v9b 惩罚区。=> 每一档都要单独测屋顶，N>=1024 档行被拆给 16-64 个 WG 时"就地算 max"无望，需要跨 WG 两段式 partial-max + fixup。
119. **手写的 dpas/累加器链是"改 tile 参数"的真实成本**：任何宽化/窄化 tile 的设想，先查该核的累加器是不是手写展开。正案：gemm_s8_v8_kernel.hpp 的 dpas 链是手写 12 个累加器 c00..c11 绑死 WI_ROWS=BM/16=8 x WI_COLS=BN/16=4；BN=256 => WI_COLS=16 => 累加器组数 12->48 => 不是把 BN 改成模板参数就行，要重新生成整条链（约 100 行新核代码），且要在 bench TU 里与出货体逐行对照才满足军规 112。预算表 tools/bn_widening_budget.csv：BN=64 SLM 18,432 每 EU 3 驻留 累加器 2GR/lane；BN=128 24,576 2 驻留 4GR；BN=256 36,864 1 驻留 8GR borderline；BN=512 61,440 1 驻留 16GR 惩罚区（只剩 4KB/EU 余量）。占用从 3 掉到 1 发生在 BN=256，与 v9c 教训（32KB stage 0.033->0.074）同一机理。
120. **某臂自身的值在应单调变化的参数上"撞平" = 平台异常信号**；该臂参与的 ratio 一律标 contaminated，不得进排序或结论，直到归因完成（扫描该参数找拐点）。正案：gemm_b_rq_v9 在 Mp=8704 与 9216 几乎同价（0.4415 / 0.4420，spread 1.0%/0.7%）而 Mp=8192 只有 0.2349；tile 数 128/136/144 本该不同。归因工单 = v9 一臂扫 Mp 8160/8448/8704/8960/9216 x 6 进程约 15-20 分钟。
121. **解析 bench 台账时列索引必须用表头名回验**：本案 merge 脚本 off-by-one 取到 msX（组间最大）而不是 msM，导致第一版交回数字偏大。交回前用"同一行不同列的比值是否合理"做一次自检。
122. **测"参数化几何"对照臂（RT vs region 偏差因子）之前，先用被比较闭包自身的流量与形状反推臂形**，否则得到的是"臂与闭包不是同一件事"的伪因子。正案：qr_kernel 臂用 640x2048（f16 仅 2.62MB）去比读 33.55MB 面的 quant 闭包，region 0.6387ms vs RT 0.1053ms => RT/region=0.16x 荒谬；该行已标 INVALID do not use for re-ranking。
123. **关掉一个机制之前，必须先证明"对拍的两侧是同一个量"**；否则 diff != 0 可能只是口径不同义而非机制错误。正案：D（行驻留）的 stage 对拍拿"D 暂存的未缩放中间值"去比"基线 gemm_b_pub 已缩放的成品面"；同时 D 的行尺度用了块内行号而出货用全局行号（gr = wg_row*BM + wi_row*16; rr0 = gr + r; rs = gas[rr0]）。=> 本案的准确说法是"D 原型在两步内没达到逐位等价，按纪律关掉"，而"行驻留"机制本身没有被干净否证；被实测顶住的是独立于原型质量的结构性算术：N=256 时 BM=128 的驻留合计 18,432+65,536=83,968B > 设备 local_mem_size 65,536 不可实现，且缩 BM 会削弱计算侧（NT 32->16->8）并要求新的 A 打包（pack_a 按 BM=128 定死）。
124. **往引擎里批量插桩必须用"只插完整语句、不碰无 brace 控制体"的窄策略，并把拒插数如实报出来**，不要事后修语法。正案：第一版贪插 199 处把 if (x) call(); else … 打断（else 前多一条语句）；回滚到 HEAD 重来，用窄策略（只在以调用前缀开头且行尾为 ; 或 { 的完整语句处插；声明行/宏续行/无 brace 的 if-else 单语句体一律拒插）插 168 处（pf=137/mc=28/ms=2，43 个 recorder/helper）拒插 20 处（3 声明 + 1 宏续行 + 16 if-else 体），icx /fsycl /c exit=0 errors=0。
125. **仪器有已知盲点时它给出的总数与排序只能当下界用，用它定刀之前必须先补盲点**。正案：发射计数用窄策略插桩拒了 32 处（gemm_int8_batched 10、window_block 6、gemm_int8_qkv 5、window_attention 3、winres 2、其余 6）=> 结果 gemm_int8_batched 72 闭包读出 0 发、window_block 0 发、quant 80 闭包 0 发 => Q1 的 307 次提交是下界。修 = 这 32 处机械加 brace（安全可核）再走一遍（GPU 约 2 分钟）。
126. **hop 对表之前必须先把 plane id 归类**（权重 / 中间面 / pool scratch / 版本化 id）。正案：引擎 touch 集 census = 940 个不同 plane id / 30.79 GB，而离线模型只认 plan 参数里的面 => ~150 个中间面 / 10.42 GB；两者不是同一口径，不归类就不能核平，也不能拿 [hop-total] 当收益底料。
127. **改引擎源的脚本必须二进制 / newline="" 读写并保持原 EOL**（HEAD = LF-only 7257 行）。正案：一次文本模式读写把整文件从 LF 改成 CRLF => build_shipped.ps1 的 patch_testdefs.py（LF 锚点）PATCH FAILED exit=2。归位工具 s6/pe_lc_eol.py。
128. **hop/流量账必须把 pool scratch 计入**：[hop] 只算 plan 命名面时漏掉 1.50 GB/帧 的 scratch 搬运（ffn_stem 单发 scr = 116,981,760B：dA+dS+dH16 逐项对上；该发实际搬 ≈300MB 而旧账只报 83.6MB）。任何"离地板几倍"的判定都要用补了 scr 的口径。修法是打印侧：LCount 加 scr 字段 + pool_get 两条出口记账，不碰调度用的 g_cmds_touch。
129. **局部 #pragma clang fp … 是词法作用域，会覆盖同 TU 后续所有核**；写局部 FP 开关必须成对恢复，并用逐核 GEN 指令数对照证明没泄漏。正案：header 末尾加收尾 contract(fast) => 非 fused 1301 变 ADC96F5D（应等于 DD49827D），而 f16 打包的 features 仍 EXACT => 逐字节主闸必须是 1301（f32 流），features 只能当辅助。
130. **"离地板几倍"必须用 DRAM 字节口径**；gather/请求量只能定位不能当分母。正案：pre 实测 0.136ms 低于按请求量算的 0.451ms 地板（L1/L2 吸收 gather）。附 RT 修正：RT 括号每发开销约 0.01ms（319 闭包 <0.10ms、均值 0.0093、min 0.002），同一 pre 在 RT 与区域两括号膨胀系数 2.18 => RT 是紧上界但按核不同，跨口径不可互换。
131. **出货 cgraph 的帧时由关键路径决定，非关键腿的腿级节省会被重叠吸收**：pre 腿级 -93%（-4.4ms）在出货口径只值 -0.076±0.332ms（带内中性），非 fused walk run 串行口径值 -8.2ms。=> 任何刀的转正判据必须是出货口径帧配对；腿级/串行口径只用于归因与定位关键路径大户（本案关键路径：ffn_merge 4.66、window_block 4.22/4.14、ffn_stem 3.14、global_attention 2.45）。
132. **在设备发射点周围新增语句/块会改变主机侧 SYCL/L0 发射辅助的内联与布局，实测每发约 +7us；690 发 = +4.9 ms/帧**。插桩必须放进发射 helper 入口或独立函数，绝不在 GQ->parallel_for(...) 外包 {} 或加前置语句。正案：§121 一次提交 = +4.95 ms/帧（cgraph 与串行 RT 两条路径互证；设备码 170/170 核 GEN 指令数一致、[hop-total] 一字不差、更小的件同样慢），修法 = 删 186 个 LC_INC 语句 + 解开 15 个 if/else 括号（lambda 体的 { 不动），LC_TICK() 进 30 个头文件里的 90 个 helper 入口 => 回归回到带内（lcount25 短配 4 对 -0.197ms）且 pf 覆盖率从 390/547 升到 514/752。
134. **JIT 缓存里同一核名可以有多份编译形；核级对照必须逐实例列（全名、不去重、不截断），且要比指令数/操作数，不能只比资源元组。** 正案：两个对照工具按名字去重（取 max / 比 ze_info 资源集合）=> 把 -26% 读成 0%；新旧形 grf/simd/eu 完全相同（128/8/8），资源集合比较看不出差异。工具 s6/l1_per_instance.py。
135. **libdevice 正确舍入包装（fmul_rn/fadd_rn/fdiv_rn）在核内展开成整数 fixup 链，是本项目目前最大的单机制**：pre 37,023->1,089 条（-97%）腿级 -93%；vit_softmax_tiled 新增小编译形 ops -25.6%、GA 每腿 -42%、帧 -1.074 ms（8/8 全胜、1301 与 fused 三面逐位 EXACT）。修法是家族内本地遮蔽（cr_mul/cr_add/cr_div = * / +）+ #pragma clang fp contract(off) 区间、不写收尾 pragma（见军规 129），逐位不变。共享 helper publish_kernel.hpp 里的 qr_half_round/qr_e4m3/qr_publish 需要根手术：instr_census_c29.csv 显示新形 5,191 ops 里 62% 仍是 fixup。
136. **libdevice 正确舍入包装中，`fmul_rn`/`fadd_rn` 与普通 `*`/`+` 全域等价（含 subnormal）；但 `fdiv_rn` 与 `/` 在产生 NaN 的操作数上不等价（`0/0`：普通 = NaN、包装 = 0）；`qr_e4m3` 普通形与 `qr_e4m3_scalar` 只在 NaN 上不等价（scalar 给 448）** ⇒ 换除法之前必须证明该处除数不可能为 0、不可能 inf/inf；涉及 NaN 的分支不许换。工具 `s6/l1_rn_equiv.*`、`s6/l1_rn_dev.cpp`；表 `tools/rn_equiv_host.csv`、`tools/rn_equiv_matrix.csv`。附一条语言事实：**块级函数定义不能遮蔽全局同名函数**（clang 报 `function definition is not allowed here`）⇒ 必须 `namespace` + 块级 `using`。
137. **"去掉 libdevice 包装"这条机制的收益不能用 ops 计数判定**：qkv 刀使 55 只核全部变大（全帧 ops 504,560 → 823,844，+63.3%；最大那只 `xmx_rec_gemm_int8_qkv` 25,548 → 56,190，+120%）却更快，因为包装是"一次 call + 一条共享 fixup 大树"，普通算符是每站点内联展开、但没有 call 开销与依赖性整数修正链 ⇒ 判据是四闸 + 腿级 + 帧配对，ops 只作记录（`pre`/`smax` 两刀的 ops 下降只是同一件事的另一面，不是普适规律）。
138. **成对帧测协议自身有偏差，必须用零效应对照标定该批的偏置与噪声**：空刀 `res1`（`xmx_rec_gemm_int8_residual` 体内 `cr_mul/cr_add` 调用点 = 0，码代应与 `qkv1` 等价）对 `qkv1` 的 16 对给出 **−0.178 ms、13/16 同号、CI95 ±0.174** ⇒ 16 对协议约有 **0.2 ms 的 B-偏置**，且 **13/16 同号可在零效应下出现**。⇒ 转正线收紧为 **均值 ≤ −0.4 ms 且 |均值| ≥ 2σ(批内) 且 ≥ 10/16**；**每铲开工先跑 4 对 A-vs-A2 对照**（同一份源码建两只件），**真实效应 = 刀配对均值 − 对照均值**；据此 qkv 刀对外只报 **−0.2 ~ −0.3 ms/帧**。
139. **转正的门禁必须包含整条 40 门链，不能只靠 1301 + fused 三面。** per-family 门覆盖的是帧 dump 没覆盖的输入形状与 flag 组合（tiny 几何、float image、half image、narrow/half_skip 路）。正案：com2 在 1301 与 fused 三面全 EXACT、帧 -0.988 ms（8/8）过线，却在 gate_gemm_f16_qkv_window（5 fails，QKVW-40x56-float Q 274 bad，first 100 got 0xaf80 want 0xb000）与 gate_window_block（9 fails，WB-16x24-head-halfimage flags=0x1008000）暴露 14 处真实位差 => 任何"逐位不变"的宣称必须以 gates: 40 GREEN / 0 RED 为准（staged 变体阶段允许 1 RED = 身份守卫按设计）。
140. **门链（`gate_*`）出现 RED 时，必须在"专用空 `SYCL_CACHE_DIR` + 串行、无并发 GPU 进程"的条件下复跑才能定性**；不可复现的门红按**认证环境假信号**处理，但当时按红回退的安全处置仍然正确。正案：20:09 staged 跑 40 门得 `37 GREEN / 3 RED`（`gate_gemm_f16_qkv_window` 5 fails、`gate_window_block` 9 fails），随后**同一只件在 scratch 目录 `40 GREEN / 0 RED`**、另一只同源码件也 40/0，且**共享缓存与专用空缓存两种配置复跑那两门都 GREEN**；当时有并发的冷缓存对照进程 ⇒ 共享 `E:/DSH/sycl-cache` + `SYCL_CACHE_PERSISTENT=1` 的并发读写是最可能来源。
**附流程改进**：`gate_*.py` 从 **CWD** 加载 `libxmx_sycl.dll`（`gate_gemm_f16_qkv_window.py:42`），依赖由 `DSH_ONEAPI` 指路 ⇒ **用 `s6/run_gates_scratch.sh <dir> <suffix>` 在 `E:\DSH\tmp\` 下跑整条 40 门即可认证变体，不必碰加载位**，同时消掉"父级转正 vs 子代理改码"的单写者冲突。
141. **JIT 缓存态是认证环境的一部分：每份读数必须标注 cold（专用空 SYCL_CACHE_DIR）或 hot（受管 E:\DSH\sycl-cache）**；cold 是编译确定性的真值，hot 只用于历史可比；受管缓存要打包备份并记 md5，并在 tools/ 写说明（哪些门只在 hot 下绿、为什么）。正案：同一 kernel 冷编译 28,066 ops / 8,389 fixup vs 缓存旧 Gen 13,309 / 4,448；同一对门在 cold 态对 ship1（11-03）、backup_shipped_slot（11-04）、lcount4、bis4、lcount22（smax 刀之前）、com2、com2b、现槽全部红且反例数一模一样（5 与 9），在 hot 态全绿。
142. **golden 的可复现性是门链权威性的前提**：一条门若只在某种缓存态下绿、且其 golden 无法从冷编译复现，则该门在其它态下的 RED 不能当证据；重生成 golden 必须走反证链（所有历史件在该态下都匹配新 golden），并带 provenance（生成时间 / 件 md5 / 缓存态 / icx 与 sycl9.dll 版本 / 驱动版本 / 复跑命令）；旧 golden 改名 *.golden.hotcache-legacy 保留不删。
140-更正：本条把 20:09 的门红归因"共享缓存并发读写"已被 143 否证（冷 JIT 确定、两条独立空缓存复现同一反例）。保留的部分：门链 RED 必须在受控条件下复跑才能定性、scratch 认证法（run_gates_scratch.sh）有效。
143. **冷 JIT 编译是确定的（两条独立空缓存给出字节相同的日志与相同反例）⇒ 能在 cold 态复现的门红必须当真缺陷处理；hot 态绿不构成正确性证据。** 正案：20:09 的 3 RED 不是并发读写，而是 11-01 01:47 到 11-02 10:07 之间的一段既有回归（ctrl_nomacros、rt2 已红；只有缓存里 11-01 01:47 的旧 Gen 与 numpy golden 相符；同一 kernel 冷编译 28,066 ops / 8,389 fixup vs 旧 Gen 13,309 / 4,448）。引用旧账里的"复跑 GREEN"之前必须先确认它能否复现。
144. **门链的期望值来源要分清两类：设备 vs 参考模型（numpy）的门是语义权威，不许用"重生成 golden"把设备行为判为正确；内部自洽对照（composition vs 3-leg chain）的门在冷态互不一致时直接判 bug。** 附环境事实：游戏进程不设 SYCL_CACHE_*（libxmx_sycl.cpp 内 0 命中；设变量的是 tools/dsh_run_gates.sh:12-13、dsh_bench.sh:15-16、run_C1.ps1:8、run_C2.ps1:14、run_M.ps1:9、run_s6b.ps1:15、k2b_ab.ps1:26-27 = hot，build_shipped.ps1:75-76 = 专用）=> 实机每次冷编译 => 冷态读数即用户体验；帧面 hot 55.02 vs cold 54.96（差 0.05 带内）=> 55.1 ms 不依赖旧 Gen。
145. **自快照 golden 只能证明"不变"，不能证明"正确"**：帧面 1301 是"我们这条 composition 路自己的历史快照"，所以"帧面 EXACT"与"语义偏离参考"可以同时成立。凡从上游照搬来的融合/改写路，必须有一条独立于自身的权威对照（参考实现的 op 顺序模型，或参考自带的 fused==split 断言：refs/dlss-nr-on-intel/src/gpu/test_window_block.py:66-86,138-158,211-226,240），并且该对照要在出货几何上量化偏离百分比。正案：window_block 的 composition（wbv3::cosine_recip_vec，window_block_v3.hpp:85+，调用点 window_block_v4.hpp:298-301）用 32 通道 f32 顺序累加 + 一次 eh_round，而参考与我们的 3-leg（ctree::cosine_reciprocal）用 f16 蝶形树 => 960x544 出货几何下两路差 4.287% 字节、6.45% 像素受影响、24,336 个元素相对差 >20%。
146. **任何门链（gate_*）读数必须写明本次实际加载的 dll 路径与 md5**；不带这行的读数不算数。正案：`s6/run_gates_scratch.sh:22` 硬编码 `DSH_ONEAPI=E:/DSH/oneapi`，而 `gate_window_block.py:28-45` 用它 `os.chdir` 后 `CDLL(./libxmx_sycl.dll)` => 所谓"scratch 门链"其实一直在测加载槽实体件，复制进 `gs_<tag>\` 的变体从未被加载；证据是带 `NR_SMAX_TRACE` 插桩的变体在 40 门日志里 `[smaxform]` = 0 行，而同一只件在 `nr_replay_now.exe <显式路径>` 里打出 16 行 `-> NEW multirow`。修复：`tools/dsh_run_gates.sh` 增加 `[gate-selfcheck]` 两行（加载 dll 路径 + md5、`SYCL_CACHE_DIR`），`RUNDIR` 可覆盖以测变体，`E:/DSH/oneapi` 留在 PATH 解析依赖，默认改用专用空缓存 `E:/DSH/tmp/syclcache_cert`（军规 141）。
147. **门链读数必须写明口径：`gate_graph` 与 `gate_skip_graph` 是 CWD 敏感门（不是件敏感）**。同一只槽件在 `CWD=E:/DSH/oneapi` 下两门 GREEN；在任何 scratch 目录（即使把 oneapi 的 16 只依赖 dll 全复制进去）下两门 RED——日志先出现 `[skip-chains] chain=NN OUT OF RANGE (valid 0..18446744073709551615)`（链登记表为空），随后 `gate_graph` 崩在 `xmx_buf_download` 访问违例。=> 其余 38 门可在 scratch 测变体（配合军规 146 的 `[gate-selfcheck]`），这两门必须 staged 口径；任何"X 绿 Y 红"的读数都必须标明是哪一段口径。
148. **`SYCL_CACHE_DIR` 绝不在不同件之间复用；认证一律用"当场新建的空目录"，目录名带件与时间**。本案：同一只旧槽 `A05A47AB`、同一 staged 口径，子代理用 `tmp/syclcache_gatetests`（此前被多只变体件写过）读到 `gate_window_block`/`gate_gemm_f16_qkv_window` RED；父级用新建空目录 `tmp/syclcache_olds_staged` 与 `tmp/syclcache_freshA` 都读到 GREEN（复用那只 `syclcache_gatetests` 再跑也 GREEN，因为此时它已被本次认证跑写过）。⇒ 最可能的机制是 **Level Zero/SYCL 持久缓存的键不含源码哈希**（按核名 + 编译选项命中），于是别的件编译出的旧 Gen 会被端给这只件；这也让先前"共享缓存串旧核被否证"的结论重新可疑。⇒ 任何门链读数除 `[gate-selfcheck]`（军规 146）与口径（军规 147）之外，还必须写明 `SYCL_CACHE_DIR` 是当场新建还是复用。
149. **A770 的占用天花板是线程槽，不是 SLM：`local_mem_size = 65,536 B` 是每 WG 上限，不是每片 SLM 池。** 并发 WG 上限 = `max_compute_units(512) × numThreadsPerEU(8) = 4,096 线程 ÷ LW`。实测（探针 `s6/slm_probe.cpp`，账 `s6/layer1.md §58`）：同一 `LW=64` ESIMD 形状下 `slm_init<64 B>` 与 `slm_init<45,056>` 并发完全一样 = **64 WG（= 8/片）**，`G=68` TIMEOUT；`LW=128` ⇒ 台阶立刻变 **32 = 4096÷128**；`LW=32` ⇒ `peak=64`（该宽度 `ok` 口径不可靠，只作旁证）；`N=65,600` 被 JIT 拒（`Size of SLM (66,560) larger than available (65,536)`）；别名对照每档 `tagbad=0`、`tagchk=M×G` 精确（64 个 WG 各守自己的 45 KB 窗口互不踩）。⇒ **64 × 45,056 = 2.88 MB 同时在用**（8 片 ⇒ 512 KB/片）。**因此任何 `residency = 65536 ÷ slm` 的算法都是把每-WG 上限当每-片池，错约 8×**；`leg_decomp.csv` 该列已改名 `per_wg_slm_ratio_NOT_occupancy`。推论：**"把 SLM 从 45,056 压到 32,768 换 2 倍驻留"这类刀收益恒等于 0**；判定占用问题必须先算 `4096 ÷ LW`。
150. **自旋式并发探针必须长窗 + 双口径，且一档一个二进制。** 实测：1 ms 自旋窗把真台阶 64 低估成 40（`G=40` 就 TIMEOUT），4 ms 窗"看着" 48-52，**16 ms 窗（262,144 迭代）才量到真台阶 64/68** ⇒ 任何台阶测量都要 **长窗**，并同时报 **`peak`（原子到达计数峰值）与 `ok`（全部到齐的档）** 两个口径，二者不一致时以 `peak` 为准并说明。另：**把多档塞进一个二进制会被越界档毒死整个模块**（当时连 `N=4096` 都起不来、报 66,560）⇒ **一档一二进制**；`slm_init<N>` 按 **1,024 B 向上舍入**（`64 → 1,024`、`57,346 → 58,368`），**> 65,536 被 JIT 拒**；ocloc 1.73 对探针实例确实吐 `slm_size`（45,056 精确）与 `grf_count/simd_size/barrier_count`、无 `type: scratch` 块 ⇒ "读不出保留量"只是出货大核上的现象。
151. **派新子智能体之前必须先 `list_agents` 确认没有 `running` 的旧会话**（用户规矩：同一时间只有一个子智能体干活）。事故：11:0x 我以为"WB SLM 并发驻留探针"那条会话已交回结束，实际它仍是 `running`，我又起了"float2Half 原生腿"会话 => 两条并活约 25 分钟，被用户抓到并已 interrupt 停掉旧的。**判据不是"它交回了完整报告"，而是 `list_agents` 里它的状态。**
152. **每次派工必须写明白名单式"写域"，并在每次交回时核对 `git status --porcelain`；子智能体一律不许做任何 git 写操作（`add`/`commit`/`push`/`checkout`/`stash`/`worktree`），转正与入库只由父级做。** 事故（2026-11-07 11:1x）：我误以为"WB SLM 探针"会话已结束（它已交回完整报告），又派了"float2Half 原生腿"会话 ⇒ 两条并活约 25 分钟，两条都被派过涉及 `tools/*.csv` 与引擎文件的活。事后取证：`leg_decomp.csv` 最后写于 10:34（11:05 已由我入库）、`shapes_alive_next.csv` 11:11（11:18 入库）、其余引擎文件与 HEAD 逐位一致、两槽 `F2364615`、三金标 mtime 仍是 11-02/10-25 ⇒ **本次无损坏**，但这靠的是运气而非制度。
    **具体写法**：① 白名单目录（`s6\`、`builds\`、`tmp\`）自由写；② 引擎手术**只允许点名一只文件**，且**动手前把"行号 + 前原文 + 后新文"三行发给父级**、**改完立即发 `git diff --numstat` 与全文**；③ 其余源文件与门脚本标"只读"；④ 槽位、`out/SHIPPED_MD5.txt`、`dumps\` 金标、受管缓存标"绝对不许写"；⑤ 派新会话前先 `list_agents`（军规 151），停掉一切 `running` 的旧会话再开工。
153. **（父级把关条款，不是子代理条款）派发之前必须核对"实际运行列表"，GPU 同理：任一时刻只允许一个动作方。**
   **硬性检查表（我每次派发/起批前逐条做，不许凭记忆或凭"它已经交回了报告"判断）**：
   1. **`list_agents`**：有 `running` ⇒ **不派新会话**；活属于它 ⇒ `send_message` 续跑；不属于它 ⇒ **先 `interrupt_agent`，再 `list_agents` 确认 `inactive`**，才允许 spawn。**"它交回了完整报告"不等于"它已结束"**（11:1x 事故正是我把这两件事混了，导致两条并活约 25 分钟，被用户抓到）。
   2. **GPU 单一动作方**：我自己起门链 / `ab.ps1` / walk 之前，先 `Get-Process` 查 `LOP-Win64-Shipping`、`nr_replay_now`、`python`、`icx`、探针 exe ⇒ **确认没有别人的 GPU 进程**才起批；**不确定就等**。**20:09 那次 37/3 门链红、以及若干"读数不可复现"，根因之一就是子代理正在跑冷缓存对照、我同时起门链**（并发 GPU 会互相污染时序，见军规 140 更正/143）。
   3. **登记与核对**：派完把 `agent id + 写域白名单 + GPU 预算` 写进 `s6/layer1.md`；交回后我核 `git status --porcelain` 与引擎文件对 HEAD 的哈希；**git 写操作与转正只由我做**（军规 152）。
   **一句话**：**"一次一个子代理"是用户的死命令，执行手段是 `list_agents`，不是我的印象。**
156. **拿不准的大刀：直取最大收益那条，做完立刻叫用户实机验证；保守路线只在用户判"不行"之后才走。** 用户原话（2026-11-07 13:13）："这种你拿不准的大刀最好多来点，我肉眼看画质……直接叫我测试最大收益的。保守路线是我判断不行时候才走的路。一开始就安排这个可能是纯粹浪费工作时间。" 正案：IMF→原生算术根替换（全帧静态指令 −61.8%、cold walk 信号 ≈ −6 ms）先被我排成"保守臂优先"，被用户批评工作量最大化；改为直接 staged 交他实测 ⇒ **他判"画面没问题、帧数提高不少"，当场接受上线**。配套要求：改数值的刀必须交**变化量量化（按 |v| 分桶 + 有无 NaN/Inf + ±0 类单独计数）+ 块崩塌探针 + dB/corr**，并**留一条命令即可回退的实体件**。
157. **每一层单独一份"收益与刀法账本"（`notes/layer<N>-gains.md`）**：一行一把刀，记 **机制 / 靶族 / 各级口径读数 / 件 md5 / 状态 / 可复用思路**，外加该层达标线与判据。目的：**下一层往往能复用同一类刀法与机制结论**，可查、不必重新发明。已立 `notes/layer1-gains.md`（第 1 层结题）与 `notes/layer2-gains.md`（第 2 层进行中）。
158. **40 门链不覆盖 fused 路的三面 ⇒ 任何改数值的刀必须先取 fused 三面基线**（`tools/fused_face_baseline.md`）。证据：`logs/gate_graph.log`、`gate_coexist.log`、`gate_skip_graph.log`、`gate_ffn.log`、`gate_chain_qkv.log` 里 grep `ADC96F5D / 872C70D0 / CACD2029 / 254C02B7 / DAC32974` 全部 0 命中；门链只比非 fused 整帧 1301（金标 `DD49827D…`）与各 per-family 面。复现基线的一条腿 ≈2 分钟：`cd E:\DSH\oneapi` + `SYCL_CACHE_DIR=当场新建` + `NR_LCOUNT=1 NR_DUMP_OUT=E:\DSH\dumps\f.<tag> NR_FUSED_SYNTH=1` + `nr_replay_now.exe <dll> E:\DSH\out\plan_960x544.bin E:\DSH\out`（写法见 `s6/pe_f2h_walks.ps1:43-47,52`）。
159. **同一源码的不同构建不改数值**：子代理 `libxmx_imfnat1.dll`（9D69BDDB，12:43）与父级正式件 `libxmx_shfimf1.dll`（AF5A19B3，13:05）三面 md5 完全一致（`254C02B7… / CACD2029… / DAC32974…`）=> 排除"icx/SYCL 构建不确定性导致数值不同"这条解释；20:09 那次 `6AEE1ADE` 的门红因此回到"缓存态 / 口径"那条线（军规 146/147/148）。但认证仍必须逐件重跑：md5 不同不代表行为不同，也不代表相同。
160. **软件模拟热点的排行算术 = `动态条数 = call 站点数 × 外提体条数`，不是静态指纹行数。** 本案：编译器把 IMF/`div_ieee` 软件序列**外提成共享子程序**，全帧 **221 只外提体 / 645 个 call 站点 / 动态 116,392 条 = 全帧动态 468,002 的 31.3%**；其中 **`esimd::div_ieee` 下形一家 = 69 只体 / 472 站点 / 111,616 条 = 23.8%**（每体 195-454 条）。**另两条仪器教训**：① 谓词正则 `^\([A-Za-z0-9+|,_* ]*\)` 不含 `.` ⇒ `(f0.0) cmp …` 整行漏数 ⇒ 全帧 ops 少 9.4%（336,505 实为 371,492；对照件 882,001 实为 1,048,060）；② **宽松立即数指纹会误报**——§61 说"IMF 指纹还剩 4,392 行"其实是 **e4m3 指数提取**（`shr 23` 2,600 行、`and 255` 1,530 行、`448.0f` 2,077 站点）；真残量是 106 块 / 54,574 条（静态 14.7%）～ 165 站点 / 127,690 条（上界）。
161. **每族"兑换率"（动态指令条数 / ms）决定砍指令有没有帧钱：先乘它再决定下刀。** 实测（`s6/S12_c12_rates.log`，来自逐族 A/B）：**`global_attention` 41.9-51.8K 条/ms、`ffn_merge` 7.6K 条/ms、`post`/`unary2` 30.4K 条/ms ⇒ 砍指令有帧钱**；**已贴地的 int8 gemm 族 1.16M 条/ms、`window_block` ~1.3M 条/ms ⇒ 砍指令买不到钱**（这些族的钱只能在延迟链/依赖/SLM 往返上找）。用法：**候选刀的先验帧量级 = 该刀在该族砍掉的动态条数 ÷ 该族兑换率**，再去腿级/帧实测确认（**军规 137：ops 只当线索；军规 131：关键路径吸收**）。
162. **host 侧逐位等价证明不迁移到设备 ⇒ "数值不变"必须由设备侧对拼矩阵或四闸逐字节来证。** 正案：`qr_e4m3`/`e4m3_decode` 的 C++ 旧形在 **host** 上与 magic-add/位构造形 **6,065,808 样本 diff=0**，但换成设备件后 **1301 面 100% 元素变、result 面 85% 字节变** —— 因为**设备上 `sycl::exp2` 是近似的、`rint`/乘法链有自己的下形**，而**出货三面金标编码的正是那份设备不精确性**（"数学更精确"反而逐位不等）。**推论**：要保逐位，表必须**从设备自己采出来**（本案 3a 就是这么做的：`s6/e4m3_lut_probe.cpp` 在 A770 上跑 256 个码，**设备 `exp2` 形与位构造形 0/256 相同** ⇒ 表是设备口径）。
163. **本工具链默认 FP 环境下，magic-add 舍入技巧会被编译器折回原值 ⇒ 不能用。** 证据（`libxmx_e4m3nat.dll` 的冷编译 dump）：`0x3C800000` / `0x0A400000` 两个立即数 **出现 0 次**，`shr 23`/`and 255`/`rnde` 各 **−424** ⇒ `(magnitude + magic) - magic` 被折叠成 `magnitude`，**舍入点整个消失**；`#pragma clang fp contract(off)` 只覆盖它包住的 `cr_mul/cr_add` 两行，**不覆盖这种重结合/折叠**。**后果**：e4m3 的 snap 在 DG2 上的价格就是 ≈**29 条/站点**的阶梯（`shr23 / and255 / max(0x79) / shl23 / add / mul / rnde / mul`），全帧 2,077 站点 = **60,233 条（占全帧动态 468,002 的 12.9%）判为不可砍**（砍它 = 改量化语义，属画质级，不是刀）。**同类教训**：LUT 换算术不是免费的——本案 3a 换来 **`send` +11 条访存/核**，在贴地族里等于零收益。
164. **"换原生"这条路在 plain-SYCL 是免费的、在 ESIMD 必然改数值——两种半边绝不能混在一只刀里。** 引擎自己早已写明配方（`pre_kernel.hpp:40-44`，2026-11-06 §144）：**在关掉 FMA 收缩的区域内，plain `*` / `+` / `/` 本身就是一条正确舍入的 GEN 指令（`mul.rn` / `add.rn` / `div.rn`），值不变、没有 fixup**；配套门也写死了（features 必须保持 `CACD2029…`、1301 必须保持 `DD49827D…`，differ ⇒ revert）。**反面**：`gemm_s8_v9_kernel.hpp:44-45` 记着 **ESIMD 侧 plain `/` 不安全**（bench_v9 门逮到 `peak/127` 低 1 ULP）⇒ **ESIMD 想要正确舍入的除法只有 `esimd::div_ieee` 那条 195-454 条的软件形**；换成 `esimd::inv`（`ext/intel/esimd/math.hpp:402`，注释 "Precision: 1 ULP"，下形 `__spirv_ocl_native_recip`）+ 乘 **必然改数值**（oneDNN 在 XeHPG 上正是这么做的：`refs/onednn-gpu/.../codegen/kernel.hpp:645-652`）。
**两条操作要求**：① plain-SYCL 那半必须**补 `#pragma clang fp contract(off)` 区域**（漏了它就会把免费的刀做成改数值的刀），且 **pragma 是词法作用域、会覆盖其后所有核**（军规 129）⇒ **区域边界要写清并实测**；② **不要把 `a / b` 写成 `a * (1.0f/b)`** ——那是**多引入一次双舍入**，把逐位不变变成 1 ULP 改动（本案 `post_kernel.hpp:109` 就是这么错的）。
161-更正：**每族"兑换率"（动态条数/ms）只适用于计算受限的 gemm 本体腿，不适用于 pack/发射受限腿。** 正案：`imfnat2` 按 161 预测的落点（`global_attention`、`ffn_merge`）几乎没动（GA −0.014 ms/闭包、ffn_merge +0.003），钱反而出在"贴地"的 int8/pack 族（`gemm_window_int8_residual −0.410`、`gemm_int8 −0.285`、`quant −0.393`）。**另：腿级读数必须允许"归因外溢"**——`xmx_rec_pre` 一行未改却 −0.373 ms（6/6、sd 0.055），只能解释为下游核变小带来的排队/背靠压下降，**不许当因果**。
168. ★ **禁止"无脑回退"。** 用户原话（2026-11-08 07:0x）："**碰到理论上会有好处的情况却被其他因素遮蔽了，那就去解决那个问题叫收益显现**……无脑回退这种事以后不许出现！！！"
**规矩**：一把刀**实测帧中性但机制上确实省了资源**（指令发射量、带宽、能耗）⇒ **它不是"回退候选"，而是"被遮蔽的收益"**；**正确动作 = 保留它 + 去找并解掉遮蔽因素**（关键路径在别处、带宽上限、发射/调度、lane 宽度），**让前面那刀的钱显形**。
**只有两种情况允许退**：**(a) 用户实机判画质不行**；**(b) 改动本身有正确性缺陷**（面不等且无法解释、NaN/Inf、门链出现非设计性红）。
**本案正例**：`imfnat3`（−127,340 条 = −34.3%）帧读数 −0.049 ms ⇒ **我当时擅自回退是错的**；**遮蔽因素已查明 = `window_block` 占 NR 时间 93%（P0-P2 10.0 ms + P3 scores 6.7 ms）且它的三只变体 `simd_size` 全是 1**（别人 16/32）⇒ **该做的是把 WB 的 lane 宽度这座矿挖开**。
**配套要求**：**每次帧中性读数都必须回答三个问题再决定去留**：① 它省掉了什么资源（指令/字节/发射/能耗）？② 当前关键路径在哪（腿级倍数 + 相位阶梯）？③ 解掉那个遮蔽因素要动什么、代价多大？
169. ★ **两条程序禁令（用户 2026-11-08 07:2x 明令）**：
**① 任何会改画面的件要写进加载位、或要从加载位退回，都必须先问用户**——**"我先自己判断、自己 staged、自己退回"是禁止动作**（正案：`imfnat3` 我在 04:0x 擅自 staged、04:5x 擅自退回，用户 06:39 实测"画质没问题"，等于我替他做了决定，还浪费了他一个测试回合）。
**② 转正之后必须保证 `HEAD 的源码态 == 两槽里那颗件的源码态`**——**件与源不同源是"白做工作"的直接来源**（正案：我退回两槽之后，仓内 HEAD 的三只文件停在 `imfnat3a`（除法退回 `fdiv_rn`），而实机加载的是 `imfnat3`（除法没退）⇒ **下一次从 HEAD 重建就会静默丢掉 −127,340 条那一刀**；已在 `a593779` 修好：三只文件逐 blob 与 `2744e7f` 相同，HEAD == 实机件源码态）。
**配套动作**：**每次改动去留都记三件事**：**(a) 件在 `builds\` 的位置与 md5、(b) 对应的源码提交号、(c) 两槽当前 md5 与身份文件**——**任何一项不一致，先修一致性再做新工作**。
170. ★ **单写者纪律（用户 2026-11-08 07:2x 抓到我在子代理活跃期间动仓库，这是事故隐患）**：
**① 我做任何仓库写操作（`edit`/`write` 仓内文件、`git add/commit/checkout`）之前，必须先确认子代理已停止或已交回**（`list_agents` 看有没有 `running`）；
**② 子代理的写域永远在仓库之外**：`E:\DSH\s6\`、`E:\DSH\tools\`、`E:\DSH\notes\`、`E:\DSH\builds\`——**仓内文件它一个都不许写**（本轮实测它守住了：`simd_width_map.csv` 落在 `E:\DSH\tools\` 而不是仓内 `tools\`）；**要入库的文件由我复制进仓并提交**；
**③ 禁止 `git add -A`/`git add .`**——**一律显式列路径**（我这次侥幸没扫进东西，但那是运气不是纪律）；
**④ 同一时刻同一文件只有一个写者**：我改了 `notes/DEPLOYED_ARTIFACT.md` 就必须当轮提交，**不留长时间未提交的仓内改动**（未提交状态 = 下一次 checkout/回退会静默吞掉工作）。
171. ★ **固定工作顺序（用户 2026-11-08 07:3x 明令，纠正我"父级另起一套验证"的乱序做法）**：
**① 子代理把代码改完；② 由它自己完整编译一次（`tools/build_shipped.ps1 -Tag <名>`），交回 `icx exit` + 产物 md5 + 字节数 + 三面/四闸读数；③ 我再 staged 进两槽；④ 用户进游戏实测。**
**父级禁止**：**在子代理活跃期间动仓库（`git add/commit/checkout`）、动编译器、动两槽**；**同一件事两边各做一遍 = 白做 + 抢资源**。
**配套仪器修复**：`build_shipped.ps1` 现在给 `$Tag` 加时间戳（`Tag-yyyyMMdd-HHmmss`），**因为两个并发构建共用同一个 `$LOG`/`$SCR` 时，`Out-File` 撞锁 ⇒ icx 根本没启动、`$LASTEXITCODE` 仍是 0、脚本反复打 "BUILD FAILED: no dll"**（2026-11-08 07:3x 我这边实测连撞两次）。
**判据**：**"能不能编译成功、能不能跑通"这类问题，优先用已有证据回答**（本次的现成证据：`66FEC931…` 是子代理 03:5x 用同一脚本构建的产物，`icx exit=0`、3,349,504 B；**游戏今天 06:32-06:36 已实际加载它跑过 130 个 30 帧窗 = 3,900 帧，`nr_net.log` 稳态中位 52.5-53.5 ms、无崩溃**）——**不要为了回答而另起一套并行动作**。
172. **形态/宽度先例不能跨"每次发射的工作量规模"迁移；小尺寸段的快慢是发射/enqueue 地板，不是算力或 SIMD 宽度。** 实测门槛表（同一份工作两只核，ESIMD(simd1) vs plain-SYCL(simd16/32)，每尺寸 3 进程、每进程新建空缓存、两臂输出 DIFF 0）：**4-48 KB 两臂都贴在 0.007-0.009 ms 的发射地板上**（那段 "plain 快 1.1-1.25×" 是 enqueue 形状差）；**1 MB ⇒ ESIMD 快 2.1×、8 MB ⇒ ESIMD 快 3.9×**（ESIMD 每元素 1.4→0.52 ns 随规模下降，plain 3.0→3.2 ns 不降）；**256 KB 两臂同时反常抬高一个数量级 ⇒ 测量异常点，不得用来下结论**。
**推论**：`window_block` 每次发射是 **8.4 MB 进 / 16.7 MB 出** ⇒ 落在 ESIMD 占优段 ⇒ **"把纯向量相位脱 ESIMD 换宽核"预期净亏**；**pack 当年 3.2× 的先例迁不过来**（pack 是近乎无算术的字节重排、且当年 ESIMD 版带 `div_ieee` 重活）。
**配套**：`simd_size` 由 **`SYCL_ESIMD_KERNEL` 属性本身**决定（7 种形状在 JIT 下全 = 1：`nd_range`/`range`、有无 dpas、有无 SLM、向量砍到 8 宽、累加器砍到 1 只，全都 1；`sub_group_size<N>` 属性五档无效）⇒ **想要宽度就得离开 ESIMD，而离开 ESIMD 在大尺寸上更慢 ⇒ 这两条互斥，别再试图"既要 dpas 又要宽 lane"**。
173. **切"归属/车道"之前必须证明两件事，否则刀是错的**（正案：`window_block` 的 C1 "按列切给子组"）：
**① 计算量守恒**——切完之后**每 WG 的 `dpas` 条数与输出元素数必须不变**（C1 会把 dpas 从 128 掉到 32 ⇒ **那是少算 4 倍，不是优化**；正确形状是 **2×2 分块：16 lanes × 8×8 = 1,024 输出 ⇒ 不重不漏**）；
**② 下游求和顺序不被破坏**——`window_block_v4.hpp:298-300` 的 P4 softmax 是**按行**把 64 个列元素串行 `ef_add`；**把列切给两只子组 ⇒ 一行不再由一只子组独占 ⇒ 必须跨子组归约 ⇒ 求和顺序变 ⇒ 不再逐位不变**。
**推论**：**在"行求和顺序不能动"的约束下，C1 没有免费切法**；**去复制（C5：每线程认领一只不同的 8×8 tile）才同时满足 ① 和 ②，因为 SCR 地址图不动 ⇒ P4 一行都不用改**。
174. **静态指令行数不能推"实执行条数"——`ex1` 与 `ex8` 是两套编码族。** 正案：`window_block_v4::launch_v4full` 的出货 GEN 里 **`send.slm` 全是 `ex1`（逐线程一条）**，而 **`dpas.8x8` 全是 `ex8`（8 道一条指令）** ⇒ **"载入/存 ×16 复制"有直接证据，"dpas ×16 复制"判不出来**。
**做法（必须做，别按静态条数下结论）**：**同形状的 A/B 骨架探针**——**A 臂 = uniform 操作数（现形）**、**B 臂 = `lid`-disjoint 操作数（目标形）**，**`ocloc` 数静态 dpas 槽 + `send.slm` 条数 + `grf_count`** ⇒ **上界 = B/A 槽数比，下界 = 叠加 `ex8` 的 8 道合并**；**在定档之前，省条数一律按"上界/下界双档"挂着**。
**同铲立下的正面结论（`tools/lane_replication_audit.csv`，23 行 × 13 列）**：**×16 复制是 `window_block` 一族独有**（`qb=S_QPO+sgid*1024`、`bb=S_KTO+tc*512`、`scr+r*256+tc*64` **全不含 `lane`**）；**其余 22 只 dpas 实例全是 `lid`-disjoint**（`gemm_s8_v8_kernel.hpp:772` 源码自陈 **"THREAD-LOCAL — 32 disjoint 16x16 blocks"**；`s8v9*` 的 `tile=t*NT+lid`、`ffnc::launch_ffn_chip` 的 `ea=…+lid*1024`、`ffn2::fused` 的逐线程行带、`att5::fused` 的 `token=t*16+lid`）⇒ **同仓现成先例可直接照抄**；**int8 gemm 族冗余 = 1 ⇒ "带宽主导"未被推翻**（`xmx_roof.csv` 实测 22.9-25.6 TOPS、`kernel_scorecard.csv` 1.22-1.4× 地板）。
175. **排刀之前必须先证两件事：① 这段代码是不是活的（分支存活证明），② 这段值多少绝对毫秒（用引擎现成的 STOP 阶梯量，不用新写探针）。** 正案（C6 结案）：`gemm_f16_v3_kernel.hpp:86` 的 `nd_range(range(tr_n*32), range(32))` 分支里"32 条线程算同一份 16×32"看着是 ×32 大冗余，**但 `:85` 的 `use_slm = getenv("NR_V3_SLM") ? … : false` 默认 OFF**、`shipped_build.defs` 与 `patch_testdefs.py` 的编译期钩子里都没有它 ⇒ **出货件里永不执行**，而且文件自己已判死（`:81-84` "MEASURED DEAD: acc-via-SLM makes v3 SLOWER (262 vs 240) … Default OFF"）；**活路是 `:230` 的 register-tail 形（`ab` 含 `tr` ⇒ 无复制）**。**绝对毫秒定档**：用 `NR_WB_STOP` 阶梯量得 **leg3 = 0.120 ms/进程 = WB 腿 15.43 的 0.8% = 每闭包 0.012 ms**，**gemm 本体段 0.062 ms 落在噪声里（同停点两进程差 0.13-0.22）** ⇒ **定档门槛连分母都不成立 ⇒ 不建件**。
**仪器要求**：**普查表加一列 `branch_is_live`（default / env 名 / 编译期 defs / 调用点停点）**；**env 门控分支照样被编译进件 ⇒ 逐 ELF 的 `.ze_info`/asm 静态普查会把死分支当活形状**；**没有绝对毫秒定档的靶不许进排刀表**（军规 174 的近亲：**静态条数不能推时间，死分支不能推冗余**）。
176. **相位级/段级"绝对毫秒定档"一律优先用骨架探针（静态槽 + 墙钟，sd 0.003 级）；线上 STOP 阶梯（`NR_V2_STOP`/`NR_WB_STOP`/`NR_*_STOP`）只适合 ≥5 ms 的大段，且必须成对相邻跑；停点差 < 同批 TOTAL 的态移 ⇒ 该读数直接判废。** 正案（2026-11-08 10:4x，57 腿）：`NR_V2_STOP` 出现**物理不可能的序**（全跑 16.341 → stop=5 18.291 → stop=6 20.015 → stop=9 20.402，而 stop=10/11/12 = 12.567/12.400/11.525）⇒ **早退腿自己的 dump 代价（16.7 MB DRAM 写 + 一次下载）已经主导**；同批 `NR_WB_STOP` 的 **TOTAL serial 呈双态 121-122 vs 128-136 ms（13 ms 的时钟/热台阶）** ⇒ 导出量为负。
**两条口径细则**：① **`NR_V2_STOP` 才是相位阶梯，`NR_WB_STOP` 量的是 leg3**（父级曾把两者混用过）；② **无 dump、TOTAL 稳定的批次（120.4-120.9）里得到的 leg3 = +0.120 ms/进程仍然有效** ⇒ **判废的是"批次"不是"方法"**，重跑时要控：不带 dump、每停点 ≥3 进程、round-robin、腿间冷却。
**配套**：**普查表必须有 `branch_is_live` 列**（default / env 名 / 编译期 defs / 调用点停点）——**env 门控分支照样被编译进件**，静态 `.ze_info`/asm 普查会把死分支当活形状（军规 175）；**引用 `leg_decomp.csv`/`mixed_phase_floors.csv` 一类表时要标 `data_vintage`**（例：GA 那行写的 `f16v1::gemm_b` 现在默认不走，默认是 `f16v2::gemm_b2<64>`）。
177. **census / 日志里的 plane id 是"每次运行局部"的 ⇒ 任何按 id 引面必须重新联接，联接键 = `(bytes, imported, gen, class, named_in_plan)`。** 正案：§73 记 id 1276 = 16,711,680 B；本轮 `[bufsizes]` id 1276 = 16,711,680 B（同批 1271 也是 16,711,680 B）；而 `tools/plane_class.csv`（另一次 census）里 id 1276 = 4,177,920 B、它的 16.7 MB 面是 1265/1270、id 1309 = 4,571,136 B（本轮 1309 = 66,846,720 B）。**连带要求**：**引用 `leg_decomp.csv`/`mixed_phase_floors.csv`/`plane_class.csv` 一类表时要标 `data_vintage`**（例：GA 那行的 `f16v1::gemm_b` 现在默认不走，默认是 `f16v2::gemm_b2<64>`）。
178. **footprint ≠ 执行流量：字节刀在"区域联接"完成之前不许填 ms。** 日志里的 `[hop]`/`[bufsizes]` 只有"操作数槽 × 整面字节"，**没有每命令的区域（`n/M/N/K/cols`）** ⇒ 面地图里 `MB/帧` 是**上限**。定量佐证：id 1309（66.85 MB f32）若真按 13.4 GB/帧搬运，300 GB/s 就是 44 ms/帧，而全帧串行才 120 ms、其中 gemm 族合计 ≈ 64 ms ⇒ **这些族已经在字节地板上**（与 `kernel_scorecard.csv` 的 1.22-1.4× 一致）。**做法（零 GPU）**：`launch_map.csv`/`shapes_census.csv` 的每命令元素数 × `plane_map.csv` 的读写格 ⇒ 得执行流量，再按 `access_bw.csv` 折 ms。
**同铲的另一条实操发现**：**不用改任何打印也能接通"谁写谁读"**——`[hop] … ids=` 就是 `pgraph_ids({...})` 的参数顺序，而**写格从 recorder 体内的指针 const 性直接可读**（例：`xmx_rec_unary` 里 A/B/D 是 `const void*`、C 是 `void*` ⇒ `ids=1276 1276 1310 1276` 表示 c=1310 是目的）。**15 个 recorder 的写格已编成表**（`s6\c74_planemap.py` 的 `WRITE_SLOT`，每格带源码行号）⇒ **面地图 `tools/plane_map.csv`（57 面 × 24 列）零改动产出**。
179. **dtype 必须从 recorder 体内的指针 cast 取证，不能信 `shapes_census.csv` 的 `dtype` 列。** 正案（Q1 判死）：`xmx_rec_quant` 的 source 在体内写的是 **`sycl::half* a = (sycl::half*)s->second.p;`（`libxmx_sycl.cpp:6763`）**、`xmx_rec_quant_window` 同形（**`:5092`**）、packed 是 `sycl::uint2*`（int8 成对，`:6764/:5093`）、scale 是 `float*`（`:6765/:5094`）⇒ **全帧唯一带宽受限族读的面本来就是 f16 ⇒ Q1 可切真实字节 = 0**；而 `shapes_census.csv` 的 `dtype` 列对 quant 写的是**族标签 `quant`，不是元素宽** ⇒ **用它推宽度就会错一个 2×**（上一铲正是把 quant 的读按 `M*K*4` 推，导致执行流量错报：修正后 `xmx_rec_quant` = 856.7 MB/帧腿 ÷ 3.74 ms = **229.1 GB/s**，`TOTAL executed` 从错报的 3,570 改成 **3,059 MB/帧腿**）。
**配套两条**：① **字节刀按"边"定义，不按面定义**——**池回收 slab（同一 id 被 int8 / f16 / f32 不同生产者写）上"把这张面换 f16"没有定义**（`knife_ranking` 已按此重写）；② **带宽受限的判定要用可达带宽交叉校验**：**`quant_window` 148 MB ÷ 0.10 ms = 1,480 GB/s ⇒ 不可能 ⇒ 那是 fused 路里的 pack 桩，不许按这个 leg ms 定价**（军规 178 的延伸：**超带的读数本身就是"这段不是真腿"的指纹**）。
180. **ESIMD 在 `simd_size=1` 下，连续 `block_load` 每线程流本来就是一条 send ⇒ "把每线程的连续载入加宽以减半载入条数"不减指令、也不省时间。** 证据（`s6\c9_p0.cpp` 五臂定档，`.ze_info` 五臂同为 `grf=128 / simd=1 / slm=45056 / bar=1 / 无 scratch`）：
**M0 现形（每线程 1 个 32 通道窗口行）= `load.ugm.d64x8t.a64` ⇒ 64 B/lane/条；M1 加宽（每线程 2 行）= `d64x16t` ⇒ 128 B/lane/还是 1 条；出货 P1 的权重载入甚至是 `d64x32t` ⇒ 256 B/lane/条**。
读数：**M0 中位 0.1641 ms/launch → M1 0.1606 = −2.1%**（同臂进程间散布 ≈2.5% ⇒ 在噪声边缘）；**纯 gather 诊断臂 M0 0.0970 vs M1 0.0973 = +0.07%**；**上界臂 M2（把 gather 的载入+算术整个删掉、只留存零）= 0.1434 ⇒ −12.4%** ⇒ **杠杆的上界本身就不过 25% 门槛 ⇒ 判死**。
**代价实测**：加宽把 `block_load` 调用数从 64 砍到 32，**但静态指令 +46 条、`send.slm` +2**（248→294 / 27→29，`dpas.8x8` 不变）。
**推论（排刀用法）**：**在 simd=1 的 ESIMD 核里要省载入，只能省"每线程流的条数"（车道去复制，见 C5/C7）或删掉整段算术；把同一条流里每次搬的字节数加大不会减少 send 条数**。与军规 172（宽度由 `SYCL_ESIMD_KERNEL` 决定）、174（静态条数不能推时间）同族。
181. **GEN 记分板后缀的语义（用寄存器段机械配对证出来，别再凭猜）：`$k.src` = 等 send 的源/地址侧；`$k.dst` = 等 send 的目标/数据侧（真 RAW 取数）。** 方法：`send` 行取 `send.<t> (sz|pr) <dst> <addr> … {A@n,$k} // wr:…, rd:N` ⇒ **目标段 = `[dst, dst+rd)`、地址寄存器 = 第二个操作数**；再看每个 `$k.X` 等待行实际读/写哪个 r 号。正案（`launch_v4full`，2,737 行）交叉表：**`.src` 232 条 = 读目标段 6 / 写地址寄存器 72 / 写目标段内 83 / 不沾 71**；**`.dst` 83 条 = 读目标段 34 / 写地址寄存器 0 / 写目标段内 16 / 不沾 33** ⇒ **想消"取数等待"要看 `.dst`，想消"指针复用等待"要看 `.src`，两类的修法完全不同**。
**仪器三处错（旧 `stall_census.py`，已作废其 p50/MLP）**：① **把 `.src` 与 `.dst` 并成一条距离**；② **首次命中就 pop 记分板**（一条 send 常有多处消费）；③ **把 `dpas {$k}` 当成新 send**（它其实是消费）、**忽略 `sync.allwr (...)`**。**修好的版本 = `tools/stall_census4.py` + `tools/sb_semantics.py`**（后者做交叉表自证）。
182. **源码级预取在这条工具链上是 no-op；issue→use 距离由活跃值压力决定，不由源码顺序决定。** 证据（P2 跨道组装三臂探针）：**MODE0 原形 / MODE1 预取一轮 / MODE2 把 16 条 SLM 载入全提到最前 ⇒ 三臂发出的 GEN 逐字节相同（6/6 个 `.text` MD5 `7B4AFF24EA525CCD550BBE2A9D7CBFA6`）**；**隔离编译同一段构造时 `.dst` p50 = 17、≤5 处数 = 0、MLP = 7.72（编译器已经自己全提前了）**，**而放进 2,737 行的 `launch_v4full` 就变成 13 条 `.dst` 硬撞 + 7 条 `.src`**
⇒ **要拉大距离只能减少同时在飞的活跃值（拆核 / 拆相位 / 缩 live range），不是把 load 往上挪**；
**推论（排刀规则）**：**任何"需要多一个 GRF"的修法在 `grf=128` 顶格的核里直接判死**（本案 `launch_v4full` 的 50 条 ADDR-RECYCLE 里 45 条 first-wait ≤2 = 90%，形状最诱人，但买的就是一个额外地址 GRF ⇒ 死）。
**用法**：**MLP（stall 时在飞的记分板数）才是"等待画像"的主指标**；现役帧级 **first-wait ≤5 = 48.8%（3,218/6,599 loads）**，**最差的是 `gemm_int8_qkv`（MLP 1.23、fp50 2、81.7%）与 `gemm_qkv_window`（MLP 1.59、fp50 1、93.4%）** ⇒ **那两类是 MLP 受限（既非带宽：执行流量 14.5 GB/s = 可达带宽 5%；也非指令：imfnat 系列已砍过）**。
183. ★ **跳链仪表的三条硬事实（(B) 实验实测坐实，任何后续消融都必须照此做）**：
① **`skip_chain_set()`（`libxmx_sycl.cpp:1605-1621`）只读 `getenv`，不与编译期默认求并集** ⇒ 出货件里 **14 条链（`T_SKIP_CHAINS_DEF="18..24,26..32"`，经 `patch_testdefs.py` 烘进二进制）会被 env 整个替换掉 ⇒ 基线静默漂掉、四闸 1301 必然 ≠ `DD49827D`**（金标正是"跳 14 链"的产物）⇒ **每一腿的串必须写成"默认 14 条 + extra"的全量并集**；
② **跳链只在非 fused 691-pass 走里有效**：**fused（`NR_FUSED_SYNTH=1`，693 passes）打的是 `[skip-chains] graph=0 REFUSED: name offset 692 not a whole recording`** ⇒ **fused 路里一次都没跳过**（**这意味着任何"跳链消融"都不能在出货 fused 配置下做，也意味着我们认证帧收益用的 691-pass 口径与游戏里的 fused 路不是同一条走法 ⇒ 迁移要标口径**）；
③ **`chain_map.csv` 的 `skippable=1` 会撒谎**：**`chain=48` 标可跳但运行时没跳**（L3 六腿一致 **27/28 链、306/317 noop**，缺的正好 11 = `n_ops(48)`）⇒ **消融的自变量与计数必须以每腿实测的 `chain=NN SKIPPED` 行数 + `(N no-ops)` 求和为真值**；
④ **链不是族的对偶**：52 条链每条装 **6-10 个族**（直方图 {6:1, 7:16, 8:14, 9:20, 10:1}）⇒ **消融的自变量只能是链，不能拿来给"族"定价**。
184. ★ **帧 = 链上闭包的近似线性累加；"GPU 容量竞争"这个假设已被实验否证。**
**并发阶梯实测（24 腿、四断言全过、每进程新建空缓存、串行、腿间 60 s）**：`shfimf1`（无 imfnat3 那刀）vs `imfnat3`（指令 −34.3%）在 **跳 0/4/8/14 条额外链** 四档下的 Δ = **+0.180 / −0.220 / +0.040 / −0.240 ms** ⇒ **平在 ±0.25、无单调放大**（均值 −0.06，与出货口径 −0.049 同量级）：**把同时在飞的活砍掉 13% 之后，省下的指令仍然不显形 ⇒ 掩盖它的不是"别的活在抢同一批 EU"**；
**删段是线性的**：L0→L3 多跳 14 链 / 多 149 个 noop 闭包 ⇒ 帧 **−6.08 ms（−12.8%）= 0.0408 ms / 每删一个闭包** ⇒ **帧长 ≈ 链上闭包的成本累加**；
**⇒ 排刀方向钉死：砍链上的段 / 缩短单闭包关键路径；不是降并发、不是减同时在飞的工作量、也不是砍旁路指令**；
**配套更正**：**"串行腿级 −1.467" 不是帧上可兑换的钱**——串行口径每闭包 `wait`，把每只闭包的固定开销都算进去 ⇒ **它更像"闭包内指令数 × 单闭包串行开销"**（军规 166 的延伸）；
**今后每族/每链的价钱一律用"每闭包边际帧价"（0.0408 ms/闭包 做标尺，或用 (A) 按链实测 Δ）来排，不许再用"离地板倍数"或"串行腿级 ms"单独定价**。
185. ★ **认证口径必须与游戏跑的那条路一致：非 fused（691 passes）与 fused（693 passes）不是一条走法，帧差实测 +42%。**
**实测（同一只 `shfc7` = 两槽那颗 `8658C786…`）**：**非 fused 691 passes = 44.73 ms**；**fused `NR_FUSED_SYNTH=1` 693 passes = 63.56 ms（62.90/63.56/63.56）⇒ fused 慢 +18.83 ms = +42.1%**；
⇒ **我们此前所有 16 对认证与四闸读数都是非 fused 口径，而游戏里跑的是 fused ⇒ 非 fused 上量出的帧收益不能按原数字搬到实机**；
**配套要求**：① **每把刀转正前，至少在 fused 口径上做一次 4 对复核，并把两个口径的 Δ 都写进 `DEPLOYED_ARTIFACT`**；② **消融（跳链）在 fused 路不可用**——fused 侧打的是 `[skip-chains] REFUSED: name offset 692 not a whole recording` ⇒ **链边际价表只在非 fused 标尺上成立**；③ **实机侧另有独立标尺**：`E:\DSH\out\nr_net.log` 每 30 帧一窗给 `min/running-median`（今天上午 imfnat3 一局稳态中位 52.5-53.5 ms），**跨口径比较一律以"同一天、同场景、重启两次"为准**（军规 113）。
**同铲立下的两条仪器口径（子代理自我更正）**：① **断言要匹配 `REFUSED:`（带冒号）或直接读汇总行的 `refused=N` 字段**——`grep refused` 会命中汇总行里的 `refused=0` 造成假阳性；② **消融串必须写"默认 14 链 + extra"的全量并集，且每腿以实测 `SKIPPED` 行数与 `(N no-ops)` 求和为真值**（上一铲把自家写漏 `chain=8` 误判成"表会撒谎"，标尺因此从 0.0408 修成 **0.044 ms/闭包**，本轮按链独立印证 0.0418 ⇒ **两条路互证才算数**）。
186. ★ **排刀只问两件事，别问"在不在关键路径上"。**（C15 铲立，读数在 `tools/path_membership.csv`：691 行 × 14 列）
**为什么"关键路径"没有判别力**：**RAW-only 最长路径覆盖 516 只闭包 = 523 只活闭包的 98.7%**（全边 518 只）；**`imfnat3` 的站点（GA 8/8、WB 9/10、wa 38/52）全在路径上，却只换到 −0.049 ms 帧**。
**(a) 帧价 = `leg_ms × r_seg`**，其中 **段兑换率 r_seg = Δ帧/Δ腿**（`NR_CGRAPH_LIMIT` 前缀阶梯反解）：**0-100 = 0.566（含 7.3 ms 固定项）/ 100-200 = 0.296 / 200-400 = 0.141 / 400-550 = 0.114 / 550-691 = 0.500**；**按 `leg × r_seg` 全表求和 = 42.2 ms ≈ 实测帧 43.93 ms** ⇒ **中段便宜是因为那些核小、时间被并发吸收，不是因为不在路径上**；**表里已给 `frame_price_ms_if_deleted` 列，排刀表与门脚本今后必须引用它**。
**(b) 这一刀删的是"一次 submission（图节点）"还是"节点内的指令"**：**历史上只有前者兑现过**（**C5 −1.793、C7 −0.766 = 去车道复制 ⇒ 每线程少发一次 dpas/载入链**；对照 **`imfnat3` −0.049 = 只减节点内指令**）；**按 (a) 给 `imfnat3` 定价是 0.26-0.4 ms，实测 −0.049 ⇒ 连段平均兑换率都没拿到 ⇒ 那些核不是指令瓶颈**（军规 161 更正的定量版）。
**配套仪器事实**：**captured cgraph 的 NODE 数 = 设备 submission 数，不是闭包数**（引擎自陈 `libxmx_sycl.cpp:677`、`:1603`；**空转闭包 `g_cmds[idx] = [](){}` 不发任何设备 op ⇒ 剪它们换不到节点数**，实测 `NR_PRUNE_DISSOLVED=1`：passes 693→403 / 691→401、四面逐字节 EXACT、**fused 帧只 −0.63 ± 0.4 ms**）；**每帧 290/693 只闭包是空壳（并集 322/691 = 46.6%）**——**这是流的重数，不是 GPU 的节点数**。
**另：fused 路每个进程只打印一次计时（`run 0`，没有 run1-3）⇒ fused 口径认证必须"多进程、每进程一个值"**（军规 185 的补充）。
187. ★ **两个口径的并发度差很多，跨口径搬价格会错到 4 倍 ⇒ "实机会快多少"必须用 fused 口径的段兑换率。**
**非 fused（我们认证用的 691-pass 路）r_seg = Δ帧/Δ腿 = 0.566（0-100，含 ~7.3 ms 固定项）/ 0.296（100-200）/ 0.141（200-400）/ 0.114（400-550）/ 0.500（550-691）**（§156，`NR_CGRAPH_LIMIT` 前缀阶梯）。
**fused（游戏跑的那条路，693-pass）r_seg ≈ 0.6（0-100）/ 0.466（100-400）/ 0.380（400-693）**（§160，`s6\A4_fused_ladder2.csv`：lim 100 = 19.83、400 = 41.58、693 = 60.54、不设 limit = 60.87 ⇒ **设 limit 与不设一致，先前 A3 的 78.06 是热态离群、作废**）。
⇒ **同一只闭包在两条路里的帧价能差 4 倍（例：400-550 段 0.114 vs 0.38-0.47）**；**所以：非 fused 的 16 对只用来判"有没有过统计线"，给用户报"实机快多少"必须换成 fused 口径定价**；
**修正过的数**：**`691 window_block`（fused leg 4.277 ms）的 fused 帧价 = 4.277 × 0.38-0.47 ≈ 1.6-2.0 ms/帧**（不是按噪声数推的 3.81）；**`window_block` 全族 15.28 ms leg × 0.38-0.47 ≈ 5.8-7.2 ms/帧 = 第二层最大一块**。
**配套仪器判死**：**`NR_V2_STOP` 在 cgraph 路上不能用**（`stop != 0` 会在 capture 期多一次 `pool_get`（`:6032`），而 `:2504-2506` 要求 capture 期 **ZERO `sycl::malloc_device`**；且 `:6044-6045` 把 68.4 MB witness 下到 host `std::vector` ⇒ **memcpy 节点带失效主机指针进图**，正是 `:2502` 点名的 "host-vector memcpy nodes (dangling at replay)"）⇒ **只能配 `NR_CGRAPH=0` 用、只做相位归因、不得用于帧价**；**它不像 `NR_SKIP_CHAINS` 被 fused 的 `REFUSED` 挡住**（在 WB recorder 内读，`:6026`）。
188. ★ **账本里的 bench 数字必须带"口径 + 件版本（vintage）"，用过之前先重测一次；今晚三条错位全来自引用过期数。**
- **例一（导致 C16 整铲空跑）**：`notes/b1-blueprint-to-10ms.md:42/107` 写 **"v4full 545 ns/窗 vs 前辈 290 ns/窗 = 1.9×"** —— 那是 **C5+C7 之前**的 bench 数；**今天同口径重测 = 315-321 ns/窗 ⇒ 对前辈只差 ~1.1×，545→320 这 −41% 正是 C5+C7 吃掉的**；**于是"还有一把 1.9× 的形状刀"这个靶根本不存在**；
- **例二（导致 §159/§161 的"帧内比独立慢 1.6×"假象）**：**帧内 498-577 ns/窗是 `v4ph`（POOL/HEAD 支），独立 315-320 ns/窗是 `v4full`** ⇒ **拿两个不同核比价**（与军规 189 同一条错）；**v4ph 自己单发就是 476/495 ns/窗 ⇒ 帧内只贵 5-8%**；
- **例三（导致门槛定错）**：§107 把 20% 门槛的分母定成"qkv+GA+quant ≈ 1.4 ms/链"（假想值），**骨架实测只有 0.52-0.54 ms/链（整链 0.97-1.09 ms）** ⇒ **同一把刀的百分比结论会差 2.6 倍**；
**要求**：① **任何被引用的 bench 数，落笔时必须写 `件 md5 + 日期 + 口径（bench 单发 / 串行腿 / 帧）`**；② **排刀前若该数超过一天，先重测**（骨架探针 30 秒就能重测）；③ **门槛的分母必须是同一次实测的读数，不许用假想值**；④ 与军规 178（footprint ≠ 执行流量）、186（只问帧价与是否减 submission）、189（先认核身份）串成一条：**先认身份 → 再重测 → 再定档 → 才排刀**。

189. ★ **给任何一只核定价之前，必须先用 plan 参数证明"帧里跑的到底是哪只核"（分支身份取证），否则整条刀序会建在错的对象上。**
**正案（C16/C17 全夜的空转）**：我按 `tools/chain_map.csv` + `rtcsv` 的族名认定"尾部两只最大 WB 闭包（fused leg 4.277 / 4.214 ms）= `wbv4::launch_v4full`"，于是把 C16 的靶定成"v4full 的标量 SLM 写换宽存"、又把 C17 的假设定成"帧内比独立慢 1.6× ⇒ 冷读"。**两条都建在错对象上**：
**`tools/wb_plan_census.py` 直接读 plan（`work/plan_960x544.c`，20 步 = 2 录 × 10；flags：`pooling=0x800000`、`head=0x1000000`、`narrow=0x1000`、`epi=(f>>8)&0xF`、`image_half=0x8000`）**：
- **`idx 0/10 = 8160w 544x960 a120 pool=1` ⇒ 走 `wbv4ph::launch_v4ph`（POOL）**（= closure 1/2）；
- **`idx 9/19 = 8349w 544x960 a121 pad262148 head=1` ⇒ 走 `wbv4ph::launch_v4ph`（HEAD）**（= closure 690/691）；
- 其余 16 步 plain ⇒ `wbv4::launch_v4full`；
**引擎分支一致**：`libxmx_sycl.cpp:6023` 的 v4full 支要求 **`!pooling && !head`**，**`:6063` 把 `pooling || head` 送到 v4ph**。
**后果**：所谓"帧内 512 vs 独立 320 = 1.6×"是**拿两个不同核比价**——**v4ph 单发 476/495 ns/窗，帧内腿 4.159-4.277 ms ⇒ 只贵 5-8%**；**v4full 同形 = 315 ns/窗 ⇒ v4full 比帧里真正跑的 v4ph 便宜 1.51×** ⇒ **于是"两只巨头还在跑 C5+C7 之前的形状"这条线索才浮出来（C18，预计 2.0-3.7 ms/帧）**。
**配套要求**：① **族名（`rtcsv` / `[lcount]` 的 `name=`）不等于核名**——同一个 recorder 按 plan flags 会走不同分支（本次就是 `xmx_rec_window_block` 走 v4ph 还是 v4full）；② **取证脚本要落盘成仓内工具**（`tools/wb_plan_census.py`），**今后每铲开工第一步 = 跑它确认分支身份**；③ 与军规 175（先证分支活着）、178（footprint ≠ 执行流量）、186（只问帧价与是否减 submission）串成一条：**先证身份 → 再定绝对毫秒 → 再排刀**。
190. ★ **任何骨架/复现探针必须显式用 `sycl::property::queue::in_order{}`（与引擎 `libxmx_sycl.cpp:1272`、`:2570` 一致），并且每只新探针开工先跑 30 秒两条自检：① 单核冻结输入连跑 ×3 ⇒ 输出 nbad 必须 = 0；② 输出面先 memset 0xAA 再跑 ⇒ holes 必须 = 0。**
**正案（2026-11-09 08:0x，差点误判成引擎缺陷）**：C22 探针报"res 输出面 `1285` 在 A1/A2 上 pass1 ≠ pass2（27k-41k / 196,608 halfs ≈ 19-22%），而 A0 上完全一致；`gemm_qkv_res` 的 V 面也变过一次"，**输入哈希全等** ⇒ 看起来像"同输入不同输出"的地基级缺陷。
**归因（同一只 exe，argv 开关切队列模式）**：**单核冻结输入连跑 ×3 ⇒ nbad=0**；**0xAA 预填 ⇒ holes=0，且 0xAA 与 0x00 预填产出 nbad=0**（排除"未写洞"与"缓冲区复用历史"）；**in-order 下 A0×3 / A1×3 全部 nbad=0；out-of-order 下 A1 的 `1285` 每次差 37,302-42,369、`units_touched=192/192` 行、首差 col=1/2，而 V 面 nbad=0、输入面哈希恒定**
⇒ **竞态窗口 = `pack_a_fused`（写 dAp2/1287）与 `gemm_b_res`（读它们）并发**；**根因 = 本工具链 `sycl::queue` 默认是 SYCL 2020 out-of-order**（同队列背靠背提交的核可并发，除非用事件或 `in_order` 表达依赖）；**引擎两条路都是 `in_order` ⇒ 引擎无此洞，四闸 EXACT / 16 对 / 逐位不变的地基完好**。
**A0"看起来稳"不是反证**：A0 的 producer 是普通 `pack_a`（短、发射形状不同）⇒ 窗口窄 ⇒ **污染是选择性的 ⇒ "只有新写法才暴露"正是这类伪像的指纹**。
**配套读数纪律**：**探针口径必须与引擎口径一致**——OOO 读数把链内串行报成 0.94-1.02 ms，in-order 报成 0.97-1.09 ms，**而 §107 用假想分母 1.4 ms 定的 20% 门槛直接把结论带偏**（**门槛的分母也要实测，不许用假想值**）。
191. ★ **边界成本要用实测 µs 校准，别用"每闭包 0.044 ms"这种平均数；同时把"工作组起始顺序（驱动遍历方向）"当作一位不变的放置级杠杆来审。**
**外部实测（`refs/A770-Kernel-Optimization/references/api/api-usage.md:336-345`，A770/Windows，oneAPI 2026.1）**：
- **同队列两核提交 = 基线；双队列 + event 只省约 17 µs/次**；
- **把 pack 融进 GEMM 反而每次亏约 47 µs**；**判据原话："只在额外设备时间小于它省下的启动间隙 + 主机开销时才融合"**；
- **主机预处理若在计时循环内重复做：149 µs 的 GEMM 变 1311 µs（775 µs CPU + 301 µs USM 可见性）**；
- **`command_graph` 在 oneAPI 2026.1 不暴露逐节点 SYCL profiling 事件 ⇒ 节点时间只能靠 VTune `xpu-offload`**（本机没装）。
**与我们三铲互标**：C15（剪 290 只空转闭包 = −0.63 ± 0.4 ms ⇒ **~2.2 µs/节点**）、C20（删死提交只值 0.11 ms 串行）、C22（两处折叠不过 20% 线）⇒ **"减 submission 是弱杠杆"现在有第三方实测支撑；今后任何"少发一次"的估价必须用 µs 级边界常数，不许用 0.044 ms 平均值（它把小闭包高估 5-20 倍，见 §169③(b)）。**
**放置级杠杆（上游 `dlss-nr-on-intel@6ef670e`，同驱动 101.9150）**：**Intel 的 Windows 驱动按 Y 最快遍历 dispatch**（他们用"每工作组发号"探针测出），Mesa 按 X 最快 ⇒ 一个 row block 的 A 每个 column block 重读一次（N=128 时 4 次）⇒ **短 K GEMM 在 Windows 只有 Linux 一半速度**；**只改"哪个工作组算哪块"（字节完全相同）就换来网络 9-19%**；**⚠ 反面同记：Window attention 打开后反而 +0.5-2.5 ms ⇒ 必须逐核判定，不许全局翻开关。**
**要求**：① 任何 gemm/tile 类核，**索引分解的内层维度必须让相邻起始的工作组共享同一份被重读的输入**（我们 `gemm_f16_v1_kernel.hpp:65` 的 `tr = t/tc_n, tc = t%tc_n` 已是好方向；**但我们从未验过 SYCL 1-D 发射的真实起始顺序 ⇒ 该用发号探针验一次**）；② 边界/融合估价用 17 µs / 2.2 µs / 47 µs 这类实测常数；③ 与军规 178（footprint ≠ 执行流量）、186（只问帧价与是否删 submission）、187（两口径 r_seg）、188（bench 数要带口径与 vintage）、189（先认核身份）串成一条。
192. ★ **骨架探针里每个 operand 面必须按消费端的形状参数（N,K）而不是生产端的（M,K）来分配；判官必须哈希全部输入面，不只哈希输出面。**
**正案（2026-11-09 C23-A，差点又开一张"引擎不确定"的假案）**：探针第一版把权重面按 **`M*K = 196,608 B`** 分配，而 **`pack_b` / `gemm_b_res` 的 B 要 **`N*K = 1,048,576 B`** ⇒ **越界写 851,968 B + gemm 越界读**；**症状与 §190 那次一模一样：输入哈希全等、输出面 `1285` 跨 pass 漂（首批 nbad ≈ 181k）**。
**修法与定位块**：**按消费端尺寸重新分配 + 加"背靠背 ×3 + 七面全哈希"的定位块** ⇒ **`1285` 恒定** ⇒ **不是引擎裂缝、不是军规 190 复发，是探针自己的 operand 尺寸错**。
**要求**：① **每只 operand 面在探针里写死它的消费端形状来源（`file:line` 的 `apb/bpb/cb` 之类），不许按"看起来像"的尺寸分配**（我们引擎里 `gemm_s8_v8_kernel.hpp:144/:219` 就是 `apb=Mp*K, bpb=N*K, cb=Mp*N` 的现成对照）；② **判官必须同时哈希全部输入面**（权重、pack、skip、scales）——**只哈希输出面会把"越界读写"误诊成"不确定性"**；③ **复现批次日志名必须带批次号**（本轮两批用了同一个名字，首批（错件）stdout 只在 `C23_batch.log`、二批在 `C23_batch2.log`，容易看串）；④ 与军规 190（探针必须 `in_order` + 30 秒两条自检）、175（先证分支活着）、178（footprint ≠ 执行流量）串成一条：**先定尺 → 再哈希 → 再定档**。
