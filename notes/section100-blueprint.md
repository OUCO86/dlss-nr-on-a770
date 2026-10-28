# A770 NR 引擎 §100 作战蓝图（2026-10-26 版，2026-10-28 12:5x 修订）
> 用途：每个新窗口开工前先读这份。它是账本、路线图和军规的三合一。
> **⚡ 2026-10-28 修订要点：先看 §七（最新游戏路径账本 + 部署链 + 新增军规补条 + 剩余靶图）。
> §一/§三/§五 的旧数字已被 §七 取代（walk 214→~120-128；sync 账本口径作废，以游戏路径账本为准）。**

---

## 🚩🚩🚩 底线（军规，任何一步不可违背）

**数据链路健康是根本。破坏了它，做什么都白搭，之前所有工作全部作废。这是不可碰的底线。**

1. **不出现小 M**：GEMM 必须宽 M 大 tile（R8a）；batch 进 grid 维，绝不拆成一堆小 dispatch。
2. **不出现中间量化往返**：全程 int8 直通 + 单一世界；quant 只在 plan 规定处发生；不为省时间放宽任何数值标准（改数值形态必须先过 numpy golden 考古，过不了就地死刑）。
3. **不出现额外开销**：CPU 不碰像素路径；无 host pack/download；无多余 launch；无多余 buffer 往返；不为绕路新增搬运。
4. **照搬的是思路，不是代码**：前辈 coopmat/Vulkan 的实现不能直接搬进 SYCL/ESIMD；可搬的是结构（resident、fold、SLM staging、acc-via-SLM、epilogue-on-accumulator）。
5. **每步三关**：39 独立门 GREEN → 端到端 recorded walk 100.0000% 0 mismatch（vs bk 基线）+ 确定性两遍 100% → 同热交替 A/B 计时。任何一关红 = 当场回滚，不过夜。否证也要落盘（否证是资产）。
6. **每步流程**：先查参考（文件:行）→ 写明"学到什么、因此改了什么设计" → 先立门再写码 → 动手 → 三关 → 自查违规（小M?中间量化?额外开销?CPU牵扯?）→ 提交推送 → 部署 md5 入账 → 游戏验收画面。

---

## 一、现状与主因（证据链，全部实测）

**当前**：引擎 walk 214ms（E1 修复后）；游戏内前辈病态 coopmat 链路 = 49ms。同工具同 plan 对照：

| | 前辈 coopmat 引擎 | 我的引擎 |
|---|---|---|
| pass 数 | 723 | 691（几乎一样） |
| 设备时间 | 36.4ms（frame-ledger）/ 48ms（本 box） | 214ms |
| **每 pass 均价** | **0.050ms** | **0.31ms（6.2x）** |

**主因不是算术，是拓扑**：前辈每个 op 是**片上 resident**（中间值不出芯片）；我是 **split 多 pass**（中间值经 global 往返）。同一 block 前辈一个 pass 6.2ms/10 个做完（window_block.comp：7 个 stage 全在 SLM，Q/K/V/scores/probs/ctx 从不进 global）；我把同一个 block 拆成 5 个家族 ≈130ms。他的 quant 折进生产者 store，193 个 quantize_row 共 1.64ms；我的独立 quant 家族 44.3ms。"leg3 40ms hand-off 之谜"就是这件事的局部：resident 里那个 global hand-off 根本不存在。

**split 的历史价值**（诚实账）：它是逐 op 位精确对质的脚手架——39 门 + 端到端 100% 的健康链路就是这么建起来的。现在脚手架功成，必须转 resident。前辈的 resident 不违反大宽标准（片上 SLM 里的 GEMM，不是 global 小 M dispatch）——**健康链路和 resident 是可以兼得的，而且兼得才是这套架构的本意**。

---

## 二、理论地板（为什么目标必须远低于 49ms）

960x544 帧的硬数据量（前辈 notes 里的字节账）：
- 权重 int8：~55MB/帧 → 5.5TB/s 下 0.01ms 级，L2 常驻后每 pass 摊销 <0.05ms
- 全帧 GEMM FLOPs：~400 GFLOP → A770 dpas int8 峰值 ~110 TOPS 打五折（宽 M 实际可达区）= **~7ms**
- 全帧数据搬运（resident 化后只剩输入输出）：~150MB → 5TB/s = **~0.03ms**；保守按 400GB/s 有效 = 0.4ms
- 前辈 723 pass 若全融合理想形态：dispatch 开销 ~0.01-0.02ms/个 = 7-14ms（这是 coopmat 引擎 36ms 的成分之一，megakernel 化能压掉大半）

**结论：健康链路 + 全程 resident + int8 直通 + 宽 M 的理论地板 ≈ 10-15ms。** 前辈 48ms 是病态数据 + coopmat 在 A770 上只有 24.8 TOPS 上限的产物——他的链路是"数据病态但思路健康"。我们数据健康、算法用 A770 原生最优（dpas 宽 tile + SLM staging + fold），**跑不赢他就是丢人**。

## 三、目标

- **中期里程碑**（P1-P7 走完）：**≤ 24ms**（前辈的 2x）
- **终局**（P8 逐核精修后）：**10-15ms**（前辈的 3-5x，逼近理论地板）
- 每个 P 的单项预期写死在下表，做完对账，不达预期就归因重排。

---

## 四、作战序列（P1→P8）

> **状态速览（10-28）**：P1✅ P2✅ P3✅ P4✅ P5✅（QKV 尾巴=P6/P7/P11 战线收官）P6 例行验收✅（用户三次游戏确认）P7✅（=§7.2 游戏路径账本）P8 进行中（P8-a/b/d/e/f 转正、P8-c 普查中性、P8-g/g2 否证在案）。**当前 ~127ms，中期里程碑 ≤24ms 未达——剩余靶见 §7.5。**

### P1 window_block op 转 resident —— 预期 -100ms 级（不是 -40）
账本上这条链的总和：window_block 42.8 + wb-window-res 17.4 + quant_window 15.1 + qkv 32.5 + window_attention 32.8 = **160.6ms（sync 口径）** → 前辈对应 row/4 6.2 + row/3 3.0 + gemm 里 qkv 份额 ≈ **12ms**。

**★ 核心算子不动原则（用户 10-26 13:08 明令，实测背书——写在 P1 头上防误读）**：
"转 resident"修的是【中间数据住哪 + stage 数据流纪律】这个**内部机制**，不是计算核心，更不是重新设计核心。账本已证明核心是健康的、就是 A770 最优：QKV 宽 GEMM 本体只花 5.7ms/30call（0.09-0.56ms/个=前辈 width-sweep 目标区）；前辈的 coopmat 算子在 A770 只有 24.8 TOPS 硬上限，我们的 dpas 宽 tile 是他的 3-4 倍——**他的核心恰恰不是 A770 最优，值得学的只有他的数据流组织**。v3/v4 的计算继续用已证的 dpas tile8/store16（f16v1 逐字，39 门绿）算大宽数据。

**前辈 workgroup 形状实测否证（10-26 15:25，c0_256 实验）**：他的 256 线程/WG（8×32 subgroup coopmat 形状）在 ESIMD 下**直接 HANG**——bench_v2crash mode=0 nd(2040×256) 打印 launch 行后 90s 无返回被掐（§96 旧账：LW>=128 ESIMD+barrier HANGS；LW=64×2040 windows 是验证过的安全区）。**他的形状搬不过来也不该搬**（那是 coopmat 专用配型）。可搬的是他的 **stage 纪律**：每 subgroup 1KB scratch 逐阶段复用（不是 45KB 大别名区）、权重一次进 SLM 常驻（他实测教训 "read from memory by row... 1.6ms of 7.1"）、双层 barrier（subgroup 内自己 barrier、跨行才 group barrier）、K 转置 ColumnMajor 读。

**P1 首刀实测（10-26，提交 a36c9dc）：wbv3 直接转正失败，否证入账。**
- 同热 A/B：split 222.7-223.9 vs NR_WB_V3 226.4-229.2（每对 split 赢）；sync 家族 window_block 42.9→46.1。
- **根因=v3 的 stage 机制执行得糙**（45KB 别名区浪费 occupancy、7 阶段全组 barrier、每阶段并行度低），不是 resident 思路错——前辈 0.62ms/call 证明 resident 本身可以很快。
- **P1 正确做法=v3 的 stage 级 bisect + 按前辈纪律修机制**：先用 NR_V2_STOP 找出 5.7ms/call 里最肥的阶段 → 逐段修（scratch 复用缩 SLM、SLM 常驻权重、barrier 分层），**算子保持 dpas 宽 tile 不动**。每修一段跑 NR_WB_V3 同热 A/B；转正判据=家族账 window_block 42.9 → 先 <15ms（我们的 tile 比前辈大，合理目标 1-1.5ms/call，不必到他的 0.62——那是 coopmat 8x16 tile 的产物）。
- 判据不变：opt-in → stage-dump 对质 → 三关（39 门 + 端到端 100.0000% + 确定性两遍）→ 同热 A/B → 转正。
- 目标：window_block 家族 42.9→~10-15ms 起步，整链（含 wb-window-res 17.4 + quant_window 15.1 + qkv 尾巴 20.8 + attention 往返 32.8 被吸收）**预期 -80~120ms**。

**✅ P1 DONE（10-26 21:5x，三形态全部 resident）**：plain（v4, 2.12x）+ pool（v4ph fold）+ head（v4ph 片上 GEMM）全部转正。window_block op = ONE kernel（QKV+norm+scores+softmax+PV+outproj+residual+publish+pool-fold+head-GEMM）。leg4 独立 GEMM、dOut16 往返、dA4/dB4/dH4 pool buffers、Stage 缓冲全部消失。walk 227→~204（本链累计 -23ms）。
**破案记录（教训级）**：pool/head 的"神秘 1-ULP"= **FMA 收缩对 scope/phi 结构敏感**——操作数 load 预初始化+分支重赋值会把 `a*b+c` 拆成两次舍入（muladd），load 与表达式直线相邻才缩成单条 HW FMA。witness 链（dump sk/cosv/acc → numpy fma-vs-muladd 重构）一次定位；修复=表达式移进 if(inimg){} 直线块（前辈 :433-436 同形）。修后 total 0/16.7M、两 head 门直接全绿。**写新核的军规补一条：ESIMD 里每个已证数值表达式必须保持"load 紧邻表达式、无 phi"的形态。**
- 部署链：c0fcc750 → 11c55383（pool）→ b17d55eb（head）。逃生舱 NR_WB_V4_NO_POOL=1 / NR_WB_V4_NO_HEAD=1 / NR_WB_V3=1 / NR_WB_SPLIT=1。

### P2 quant 折进生产者 store —— 预期 -35ms
44.3ms → 前辈 1.64ms 量级。参照 gemm_staged_int8.comp store 出口直出 int8+scale；我的现成件=v9b fold（已证 bit-exact）+ g_fused_quant no-op 机制。给每个生产者 GEMM（batched/residual/f16）配 fold store。

**✅ P2 DONE（10-27 凌晨，实际 -16ms 级，未达 -35 全额=归因入 P7）**：打法与蓝图预设不同且有据——v9b 式"折进 GEMM 生产者 store"被 §99 历史否证（宽合并慢 16ms），改用**消费者侧溶解**（用户"别合并 kernel，消灭它"方向）：pack_a_fused 把 quant 算术 VERBATIM 融进 gemm 的 pack 读路径（读 f16→行内峰值→量化→直写 dpas tile+scales），int8(48)+residual(136)+window(104)=288/448 call 溶解转正（NR_Q_FUSE 默认开，=0 逃生舱）。sync 账本 quant 29.6→13.1。bench_p2quant 否证"除法瓶颈"（DIV/RECIP/PURE 全 446GB/s=带宽贴顶）；NR_QUANT_SKIP 钉死 552 call 帧内真实代价 21ms。batched(144) 融合 bench 3.25x 赢但端到端严格 A/B 五对=中性→探针 OFF（NR_Q_FUSE_B）不硬转正——"不为融合而融合"（用户语）；"8x 冗余是元凶"亦否证（v3 零冗余 0.071 慢于冗余版 0.058：L1 兜底+ILP）。quant_window(104/16ms) 消费者=QKV 语义不匹配，不硬接。**链路审计（10-27 早）**：四雷排查修 1 真雷——fold 注册表 record-scoped 但 xmx_begin/abort/graph_capture 不清空（跨录制/换 plan 会 no-op 错闭包，v9b recycled-buffer 同族坑）→ c94872f 修，部署 md5=**0c3b1edf**。军规补账：单家族账本 delta 不能当判据（挪账假象），判据=同热端到端 A/B。

### P3 ffn 家族转 ffn_fused 结构 —— 预期 -30ms
40.4ms → 前辈 5.5ms。参照 ffn_fused.comp："hidden layer kept on chip"——expand 的 publish 在 accumulator 上做、经 SLM 直接喂 projection，252MBx2 的 hidden 往返消失；一个 subgroup 带 16 行过两个 GEMM。

**🔨 P3 进行中（10-27 早）**：
- **P3a ✅（0291bd7）**：gemm_pub_pa16——expand 的门控输出**直接写 projection 的 pack_a16 A-tile**（(tr,tc)==(tr,kc=tc) 同 16x16 几何、同 pub_esimd(3) 值、pad 行显式零）。dH(33MB/call)+pack_a16 趟消失。门逮住块步长 bug（expand kb_n vs projection tc_n）。三关全过，A/B 每对赢 2-3ms。
- **P3b ✅（e276b10）**：同杠杆接 stem+merge（B→C 腿同构；residual 腿维持 split——gemm_res 1-ULP 教训）。ffn 三族 20 call/帧 全 tile 链。39 绿、端到端 100%×2、A/B 每对赢 4-5ms。部署 md5=**9ef11353**。walk 227→~190（-38ms）。
- **P3c ⏳（下一刀，蓝图正主）**：真 ffn_fused——hidden 跨两 GEMM **片上驻留**（subgroup 16 行、32 列 chunk、expand acc→SLM→projection 操作数；ffn_fused.comp:11-16 前辈原图 + 我们 v4ph head 路已证"acc→SLM pack→tile8s 第二 GEMM"同型机制）。收益=再消 tile 缓冲的 write+read（~66MB/call×20）+ 一 launch。风险=大核重写，先立门（gate_ffn 三族的 within-one 锚点现成）。
- 军规自查（P3a/b）：无小 M（tile 链全 16x16 宽块）、无新增量化往返（tile 直写=消往返）、无 CPU 牵扯、launch 净减。✅

### P4 剩余 attention/独立 pass 归户 —— 预期 -10ms
global_attention 11.2 + unary 4.9 等，逐个对照前辈对应 pass 账（row/5 0.042ms/个）。

**✅ P4a/P4b/P4c DONE（10-27 早，游戏侧对拍结案）**：
- P4a（eecead1）：global_attention vit_softmax store 直写 attnV A-tile（dProbs 67MB/call + pack 趟双消），A/B 赢 1-2ms。
- P4b（def106a）：**104/104 quant_window gather-quant 全溶解进 QKV pack_a_fused_gather**（P2"语义不匹配"是读错——普查钉死单读者+索引同构）。A/B 每对赢 8-10ms=本窗口最大单刀。
- P4c（3e230a2）：window_attention smax_esimd store 直写 tile（又消 dProbs 33MB/帧）。A/B 赢 1.5-3ms。
- **游戏侧每帧 harness（e010377，nr_net_run 30 帧一报进 work/nr_net.log）**：对拍 OFF(P1-era)=215 vs ON=197 → **-18ms 在玩家侧兑现**（离线 -21 吻合）；OptiScaler bridge 账本 work=197/wait+fence<2ms → NR=202ms 帧的 97%。教训入册：插桩前先确认每帧路径（第一版插错在 record 期）。
- 部署：**fdc8b483**=当前 ON 件（游戏加载位）；对照 work/libxmx_p1era.dll(44bc1b64)。逃生舱：NR_Q_FUSE / NR_QW_FUSE / NR_FFN_TILE / NR_GA_TILE / NR_WA_TILE（全 =0 关）。

### P5 = QKV resident epilogue（下一窗口开工，靶 21.3ms 尾巴）
QKV 内部账（NR_QKV_STOP 阶梯）：pack 5.9 + GEMM 5.5（健康）+ **norm_scatter 尾巴 21.3**（dC int32 Mp×3C×4=25MB/call 写+读 + 标量蝴蝶核低效）。前辈正解=qkv_epilogue.glsl（已精读）：**BN=32 head-aligned 列块 + 归一在 stage 就地做 + 绝不加额外 SLM 分配**（前辈原注释：一个 64 元素 recip 数组把 stage 2KB 顶到 4KB、WG 驻留减半、代价 23ms——SLM 按 2 的幂分配）。军规①合规论证：v9b 败在窄 **M**(BM=32)，P5 保 BM=128 宽 M、只把 QKV 一族的 N 切成 32 对齐 head 块——width-sweep 先例支持窄 N 合法。实现路径二选一：(a) s8v8::gemm 加 BN=32 变体+acc-via-SLM stage 内 butterfly（gemm_b_pub_slm 机制现成）；(b) 先修 norm_scatter 核本身（向量化/coalesced），再折进 gemm。先立门（GEMM_INT8_QKV 门现成）再写码。工具链：nr_net.dll 重编用手动 cl（见 10-27 流水备忘）。

### P5 batched/residual/gemm-f16 几何精修 —— 预期 -20ms
P1-P3 后剩余 GEMM 家族按 width-sweep 目标线逐核修（C2 acc-via-SLM 已接 N=128 族；v9c 单/双缓冲否证已记档）。

### P6 游戏侧对质 + 帧时间验收（每刀之后例行）

### P7 数字对账与重排（做完 P1-P5 重拉账本，未达预期项归因）

### P8 终局精修 —— 目标 10-15ms
逐核对前辈 width-sweep + occupancy/GRF 调优（improve-large-grf.md、improve-shared-memory.md 的前辈踩坑账直接复用）。

---

## 五、当前已入账（§100 窗口，全部已推送）

| 提交 | 内容 | 效果 |
|---|---|---|
| 1061ebc/a28f274/d9906c0 | 门先行 + pool/head 接融合腿 + 2x2 pool 折进核 | -3~4ms |
| d72a1a6/5ae45e4 | C1/C2 batched acc-via-SLM（N=128 族） | 单核 -7~24% |
| 32790d9~1ada6e1 | D 探针链（8 轮）：leg3 40ms 机制事实矩阵 | 否证存证 |
| 50f67eb | **E1：v9b 暗坑（代码默认与笔记结论相反）** | **-13ms（227→214）** |
| 1742239 | QKV 内部三档账本（GEMM 5.7 健康 / dC 尾巴 20.8） | 靶子钉死 |

已部署：work/libxmx.dll md5=**9da723f3**（游戏画面已验收 OK）。回退=swap_engine.bat revert。

## 六、新窗口开工仪式（照此执行）

1. 精读本文件 + `notes/a770-native-architecture.md` 最新节 + `.workbuddy/memory/` 最近两天流水（全文，不许跳读）。
2. 从 P1 的"先查参考"开始：读 window_block.comp 全文 + wbv3 现状 + §99 的 v2/mega 失败记录（为什么败、约束是什么）。
3. 写设计（学到什么/改什么）→ 用户点头 → 开工。
4. 每刀三关 + 自查 + 提交推送 + 部署对质。

---

## 七、2026-10-28 修订：游戏路径账本（P7 口径）+ 收官盘面 + 军规补条 ★★★ 新窗口先读这节

### 7.1 当前盘面

- **walk 227 → ~120-128ms**（§100 战役累计 **-100~107ms**）。游戏侧已验收（用户 10-28 两次确认画面 OK、帧数提升）。
- 部署链尾（游戏加载位 `work/libxmx.dll`）：
  - 当前件 md5=**883bd207**（=0e16d72 构建，含 NR_WA_STOP 探针，默认关行为不变）
  - 功能件序列：5cc20f24(P3收官) → 7b58778c(P10) → 0835db5(P10b) → ed5a3bc(P10c) → 5ac705ed(P11探针) → 91c313d5(**P11 转正**) → 0b0727a5(**P8-a**) → 83b7c020(**P8-b**) → a892c77d(**P8-c/d**) → e4f08183(**P8-e**) → 1ddf4ed9(**P8-f**) → 0e16d72(**P7 账本探针**)
- 逃生舱全清单（默认全 ON，=0 关）：NR_Q_FUSE / NR_QW_FUSE / NR_FFN_TILE / NR_FFN_CHIP / NR_GA_TILE / NR_WA_TILE / NR_WA_RES / NR_WA_RAWV / NR_QKV_VITES / NR_B_WIDE / NR_BPACK_VEC / NR_PACKA_VEC / NR_PACKA16_VEC / NR_GPACK_VEC。

### 7.2 游戏路径家族账本（cgraph ON 直测，帧 baseline ~129ms，两遍均值）

**这是唯一可信的账本口径。** sync 口径（NR_RUN_TIMING 逐闭包 GQ->wait()）把流水线串行化，floor 虚高到 ~107——游戏真路径 floor=**27.8**。

| 家族 | 游戏路径成本 | 状态 |
|---|---|---|
| window_block（plain 路 16 call） | **29.4**（1.84/call） | **头牌靶**：bench 合成域 1.30/call → 真形状/真值域 gap 0.54/call |
| qkv（120 call） | 15.2 = tail 9.6 + gemm 4.8 + pack 0.8 | gemm/tail 已贴已证线（P5/P6/P7/P11 四试在案）|
| window_res（104） | 14.6 = gemm 13.7 + pack 0.9 | gemm_b_res 本体 bench 证速；pack 已 fused |
| global_att（16） | 12.8 = gemms 12.0 + rest 0.8 | gemm 本体已证速；resident 被形状算术否证（重算 scores=翻倍）|
| residual（136） | 10.6 = gemm 9.3 + pack 1.3 | 同上结案形态 |
| window_attention（104） | **7.0**（每 call 1 resident launch 全 RAW） | P10/P10b/P10c 完全兑现 |
| batched（144） | **0.6** | **P8-b 宽合并吃光**（sync 曾虚报 64.5！） |
| ffn 三族 chip | ~6-8 | P3 收官（chip 单核） |
| quant/unary | ~17（sync 口径）→ 游戏路径含在 floor 27.8 内 | P2/P4b 已溶解 288/448 |
| **不可约地板** | **27.8** | ffn+quant+unary+提交+pool/head 路（691 闭包 cgraph） |

对照蓝图目标：中期里程碑 ≤24ms、终局 10-15ms。**当前 ~127 = 里程碑未达**；剩余可挖=window_block 29.4 的域 gap + 三 gemm 族尾巴 + 地板 27.8 的逐核精修。理论地板的"7-14ms dispatch 成分"已被 cgraph 压掉大半（ON vs OFF=132 vs 146，省 14ms）。

### 7.2b 精细修正（10-28 13:3x，提交 7367422：NR_WB_PH_STOP + NR_Q_STOP 探针 + bench 帧形状阶梯）

**上面 window_block 行读数已被推翻（探针语义：NR_V2_STOP=65530 同时杀两路——v4full/v4ph 两分支都有该判断；"both"行与"v4"行相等即此故）**。路由普查（flags bit23=POOL/bit24=HEAD）：

- **4 个 giant call = v4ph 路（8160w POOL x2 + 8349w HEAD x2，level-0 全分辨率块，544x960 域）= 19.5ms（4.88/call）**——头牌靶。v4full 在 giant 形状的 bench 参考值 4.89/5.14/call（帧形状阶梯）与 v4ph 帧内边际几乎相等：两路在 giants 上打平，谁都没贴已证线——giants 单 call 4.9ms x4 是纯 GPU 时间，可挖。
- 16 small = **~10.5ms（0.66/call 有效）**——bench 隔离计时 1.25-1.32/call 但帧内边际 0.66：小 call 是 latency-bound，cgraph 把 bench 成本部分藏进重叠里。**对 latency-bound 核，帧内边际才是真价。**
- 幸存 split quant（P2 未溶解的 ~160 个）= **12.0ms** = 第二账目。
- **新账本军规（§7.4 第 9 条）：家族真价=帧内边际（cgraph 重叠后），不是 bench 隔离时间——latency-bound 小核 bench 会虚高、GPU-bound 大核两者相等。定靶前先分类。**

### 7.3 已结案家族（附 launch 计数证据，不许重挖）

- **qkv 家族**：P5（resident epilogue 慢 1-3ms）/P6（v2/v3 尾巴重构全败，v1 近最优）/P7（vit 两段合一中性）/P11（vit lane 核**转正**：449 真凶=嵌套 eh_mul 被核内改写→STEPPED 命名临时量；帧 0% 真凶=host 建表 rsqrt 融合污染 inf 槽→非有限守卫+volatile 屏障）。终账 15.2。
- **batched**：P8-b **宽合并转正**（block-diagonal 精确合并，零 padding，40/40 命中）；v9b 幽灵正名（死因=BM=32 几何，宽思路本身对）。终账 0.6。
- **window_attention**：P9（attnV+merge 折叠）→P10（整块 resident）→P10b（Q/K RAW gather）→P10c（V RAW gather）=每 call 1 launch 全 RAW。终账 7.0。
- **residual 两族**：pack-fold 被形状算术否决（K 大 N/BN 冗余读净亏）；gemm_b_res 已 fused；本体 bench 证速。终账 25.2。
- **gemm_f16**：P12a（v1→v2）/P12b（publish-fold）双中性（N 小 dC 热 L2）；P8-d（A 腿向量化）**转正**。
- **global_attention**：resident 需重算 scores=翻倍 gemm，净亏 ~5x，形状算术结案。
- **window_block 内部 stage 账（bench_v4full 纯停点，2040w）**：QKV 0.567（P0 0.058/Q 0.141/K 0.185/V 0.181）+ scores 0.265（P8-f hoist 后）+ softmax 0.058 + attnV 0.177 + outproj+store 0.19 ≈ FULL 1.255。

### 7.4 军规补条（本窗口新增，全部入册）

1. **ESIMD 已证数值链每一步必须有独立命名临时量、紧邻使用**——嵌套表达式=编译器改写风险区（P11-449 案：eh_mul 三重嵌套被改写跳中间 half-round）。与 phi/scope FMA 收缩同族。
2. **host 建表/构造循环同样在编译器改写危险区**——向量化 rsqrt 融合毁掉非有限输入槽（P11 帧 0% 案）。数值构造件：volatile 屏障拆步 + 非有限显式守卫。
3. **门域必须对照真实帧域审计**（band-3 门全绿照样全帧崩；vit norm 在帧域 as=3.53 下溢出 inf，163k/196k 行）。端到端对质不可省。
4. **结案汇报必须附 launch 计数证据**；**bench 空 launch 自查**（wg=0 的"EXACT"行=没测——bench_batched N=32 案、RAW 调用行被编辑吞案，共四逮 bench 自欺）。
5. **bench 副本核的胜负不能外推到真库核**（P8-g/g2 否证：hoist 在 bench 赢、真核 32-reg 区 spill 帧输）。寄存器当量预筛：simd<half,128>=4 GRF regs/lane@SIMD16；≤16 regs 区（P8-f 赢）、32 regs 区（P8-g 输）。帧 A/B 用真库两 dll 才是裁判。
6. **每步重读当步构建输出**（0 GREEN+EXIT=1=什么都没测——旧 dll 假结论家族三次）。提交声明的门状态必须在同次编辑对照代码验证。
7. **单家族 sync 账 delta 不能当判据**（挪账假象）；**亚 ms 级 stage 改动用纯停点 bench 阶梯 + 单族 sync 账定案**（帧总时噪声=20 族抖动之和）；**家族/帧级判据一律用 cgraph ON 游戏路径账本**。
8. 军规原五条（小 M / 中间量化往返 / 额外开销 / 照搬思路不照搬代码 / 三关）不变。

### 7.5 剩余靶图（按 §7.2 账本排序）

1. **window_block giants（13:3x 定案）**：4 个 v4ph call（8160w POOL + 8349w HEAD）=19.5ms 纯 GPU。v4full 在 giant 形状 4.89/5.14/call 与 v4ph 打平——两条 resident 路都不是 giants 的已证最优；候选=giants 走 **split wide-M 路**（§99 健康形态：rows=windows*64=522k-534k 的宽 gemm，width-sweep 2-3.5x 红利区）对拍 resident。先给 bench_v4full/bench 加 v4ph-giants 与 split-wide-giants 两条的帧形状对拍（判官=stage-dump 位精确），再定。第二靶=**幸存 split quant 12.0ms**：先普查谁没被 P2 溶解（读者计数），能否多读者合并/延迟量化再折。
   - **14:5x P8-j（K>512 quant 双读→单读 rowgroup）转正**：第六逮 bench 说谎=bench_qtime 测的是旧 plain 路（2-28GB/s）而帧走 qr_launch_esimd——帧路 bench（bench_qesimd 普查形状加权 12.4ms@84GB/s）钉死肥点=K>512 双读 ESIMD 支（640x2048 19GB/s、192x4096 15）。新核 qr_kernel_rowgroup：LW64 一组一行、K/1024×simd<half,16> 进寄存器（4-16 regs=安全区）、单读、SLM 256B 精确桶（P8-c 规则）、hmax 交换序=构造性位精确。bench_qrg 五形状 int8 diff 0 + scale diff 0，3-4x。三关：43 绿（QUANT numpy golden 判官）+ 端到端 100%×2 + 同件 env A/B **8/8 W（+1.60..+5.03，均值 +3.06）**；walk 120-123→**117-118**。顺带入账：K=64 rowthread 不肥（x2/x4 多行=打平，158 是噪声）；QKV A-hoist（16-reg 类）bench 中性**不转正**——elementwise 成本在 scr 往返不在 dpas 载重（B1 设计的又一颗钉）。提交 54308c6，部署 md5=ba618e6c。
   - **13:4x P8-i（quant 重复量化缓存）——静态审计否证，零代码零风险结案**：普查 448 幸存 quant → 48 个 (M,K,src) 键重复、字节账 87% 表面冗余——**但写穿插审计（plan 逐 op 的 dst-slot 写者表，两版 OUT 表交叉验证）证明：同键两次 quant 之间 src 必被上一层残差 gemm 重写（0/448 真冗余）**。这些"重复"是 transformer 残差流：同一 buffer 槽位每层装不同张量，每层的量化都是真需求。用户方案的 version-cache 在帧内命中率=0，收益=0。**教训（第 10 条军规）：缓存/复用类优化先跑写者审计（op 序列上 src 两次消费之间有没有 dst 写），10 行 python 杀死的方案比写一周代码再帧 0% 便宜三个数量级。** quant 12.0ms 的账=带宽地板（567MB int8 + 1.1GB f16 ≈ 1.7GB @ ~140GB/s），核本体已是 P2 时代的 ESIMD HW-fdiv 已证形态。
   - **14:2x P8-h giants 判死（提交 fe144ac）**：三探针钉死——占用（SLM 48→32KB=2→4 WG/SM：4.88→4.97 无改善）、尾部（2x4080=5.66 vs 1x8160=5.58 线性）、**per-WG 时间全家族平坦（smalls 0.61 = giants 0.60 µs/WG）**。giants 19.5ms=4x 数据×家族 per-WG 成本，**没有专属低效**（这解释了 v4full/v4ph/split 三路打平）。giants stage 剖面：QKV 2.115（P0 0.22/Q 0.67/K 0.86/V 0.58；dpas 每段仅 16 条指令）、scores 1.30、softmax 0.35、attnV 0.77、outproj 0.62、store 0.30。**XMX 利用率 0.8%——99% 时间在等 elementwise**（acc→scr 往返、e4m3_vec、cosine_recip、scatter）。⇒ window_block 剩余肉=**全家族 per-WG elementwise 链重写 = 蓝图 B1 megakernel 项**（宽 tile、消中间往返；~1000 行结构重写，带 P8-g 寄存器雷区）——**下一窗口 P8 收官大战，不是快刀**；开工先精读本节+fe144ac 提交文+P8-g/g2 否证链。
2. V-part scatter（0.181/call）：pb16_dest_kn 行奇偶映射不可 pair-merge；换 V tile 布局牵动 attnV 读侧=大改，暂记。
3. attnV/outproj hoist：**已否证**（32-reg 区 spill，P8-g/g2 两刀在案）——不要再试整块 hoist；若要试按 ≤16-reg 分半 hoist。
4. 三 gemm 族（residual/winres/global）本体已 bench 证速；尾巴（publish/scale）已 fused。剩余=width-sweep 逐形状精修（前辈 int8-width-sweep.md 表=红利地图：M 大 N 大才 2-3.5x；Large-GRF 模式=前辈实测否证，不走）。
5. ~~地板 27.8 组成拆解~~（**15:0x 已结清，提交 913ca53**：NR_F_STOP/NR_QW_STOP/NR_U_STOP 探针。四族单独价=ffn 16.1 / split quant 11.5（P8-j 后）/ unary 9.4 / quant_window 0.3（P4b 已融合=非靶）；**同删四族只省 22.2 ≠ 单独和 37.3——15ms 被 cgraph 重叠吸收**。军规第 9 条的量化实锤：帧 119.8 是全重叠总账，各族隔离定价会高估可回收量。B1 的真奖品=关键路径上那部分（per-WG elementwise scr 往返=P8-i2/j 两钉所指），不是家族加和。）
6. 游戏侧 vs 离线残余 ~12ms（持续满载时钟差）——暂不追。
