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
