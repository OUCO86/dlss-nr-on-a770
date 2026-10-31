# DS 接手账（2026-11-01 00:3x，分支 `ds-takeover-2026-11-01`，起点 fe32d33）

> 新窗口开工顺序不变：先 [B2-blueprint-to-10ms.md](B2-blueprint-to-10ms.md)（军规原文+补条 7-12），
> 再 [section100-blueprint.md](section100-blueprint.md) 的「🚩🚩🚩 底线」+§七，
> 再最近 1-2 天 `.workbuddy/memory/` 流水全文。**本文件只加三样东西：参照系钉正、里程碑阶梯、S6 的健康链路闸。**

## 0. 接手核验（本轮实测，不是复述笔记）

- 编译链可用：icx 2026.1.1（`E:/WorkBuddy/toolchain-mamba/sycl`）+ MSVC18 + SDK 10.0.26100，
  照 [build_sycl_dll.sh](../src/bench/sycl/build_sycl_dll.sh) 的 `//flag` 配方现编现跑通（A770，Level-Zero）。
- 判官可用：`oneapi/nr_replay_now.exe`（默认载 `work/libxmx.dll`）→ **691 passes，68.91/69.03/70.28 ms**；
  `gate_libxmx_sycl.py` → **GREEN (0 fails)**；金标 `oneapi/bk.1301.bin` 在位。
- 部署位 = `work/libxmx.dll` md5 **b8908bd2…**（与 10-31 22:2x 卡一致）；游戏位 `F:\Game\Lies of P\LiesofP\Binaries\Win64`。
- 推送可用：`origin = ssh://git@ssh.github.com:443/OUCO86/dlss-nr-on-a770.git`，远端 tip = 本地 tip = fe32d33。
- 参照系原文复核：[DevHistory.md](../../../refs/lmxxf-src/Development/DevHistory.md) §4.1/§4.4、
  [hip-port/CHANGELOG.md](../../../refs/lmxxf-src/Development/hip-port/CHANGELOG.md) 0.36/0.37、
  [a770-skill/README-提炼.md](../../../refs/a770-skill/README-提炼.md)。

## 1. 参照系（三把尺，全部有出处，不许混用）

| 尺 | 数字 | 口径 | 出处 |
|---|---|---|---|
| 前辈 coopmat（同机 A770） | **47.19 ms** | 71 层、960×544、Vulkan coopmat（24.8 TOPS 接口税） | B2 §一 |
| lmxx 3080L **路线 A**（同代无 fp8） | **108.5-114.6 ms @1080p / 75.3-80.4 @900p**；**35 核/帧** | 71 块完整模型、RDNA4→sm_86 移植、转线前的半成品 | DevHistory [#L76-L77](../../../refs/lmxxf-src/Development/DevHistory.md#L76-L77)、[#L129](../../../refs/lmxxf-src/Development/DevHistory.md#L129) |
| 同一路线 A 归一到我们 960×544 | **≈25.8 ms**（带宽 448→560 修正 ≈20.6） | 等像素折算 | 已核 |

- 我们 66.5 ms@0.522Mpx = **282 ms @1080p 等效** ⇒ 比"半成品"的 3080L 路线 A 慢 **2.6x**，比前辈慢 1.4x。
- 3080L 路线 A 在 Ampere 上背两道税（f32-acc TC 砍半 + wave32↔warp32 洗牌，DevHistory [#L19](../../../refs/lmxxf-src/Development/DevHistory.md#L19)）；
  A770 无洗牌税（ESIMD 手写 dpas）、XMX 也无 fp8（[phase50#L28](phase50-what-the-model-computes-in.md#L28)）——**同代同数值形态，我们该更快，差距全在形态不在硬件。**
- ⛔ 不许再引用：9070XT 的 7.6/10.4 ms（fp8+3.7x 带宽卡）、3080L 的 5.62/8.38/11.07 ms（**31 块 Small 降质模型**，用户已钉死不看）。

## 2. 里程碑阶梯（用户 2026-11-01 定：保守路线，分三段）

| 段 | 目标 | 判据 | 手段 |
|---|---|---|---|
| **M1** | **破前辈 <45 ms** | 三关全绿 + 16 对均值 ≤-0.5 | 刀 A（s8v8 三兄弟 tile 变体）+ 刀 B（quant 折叠）；两把都是**设计已备、机制在库、从未实现** |
| **M2** | **追平 3080L 路线 A 归一值 ~26 ms** | 同上 + 环节数 691→≤160 | **S6 块驻留**：window 块五阶段一核（lmxx `c64/c128_wave2_bi_bo` 的 A770 对应物）→ 全帧按块一核 + persistent stage（对应 `sp_run256_w16`） |
| **M3** | **反超到 10-15 ms** | 环节数 ~71-115 + 每核离屋顶 ≤1.5x | 残差往返 400→**71 次**（4.8GB=8.6ms 地板）+ 权重每块一读（1GB=1.8ms）+ I/O 0.5GB |

**微刀路线的天花板已用数据钉死**：691 环节 × ~95µs、环节间零并行（PGRAPH 案，fe32d33），
单环节内剩余可砍加总 ≈30 ms ⇒ 微刀终点 ~36 ms。**M2 起任何进 dll 的改动必须是"消一族/消一环"级，
微刀只允许停在 bench 层。**

## 3. 现成账（CS2 件，NR_RUN_TIMING 第二遍，串行 154 / 帧 66）

window_block 19.9 | batched 18.5 | res 18.0 | wa 17.0 | qkv 14.8 | wres 13.4 | ga 12.0 |
gemm(f16) 11.0 | quant 10.3 | ffn 6.1 | gemm_int8 5.3 | merge 4.0 | unary 2.8 | stem 1.8
（出处 [b1-blueprint.md#L1131-L1133](b1-blueprint.md#L1131-L1133)；读这张表必须用第二遍，且它是**串行口径**，重叠吃掉 ~55%。）

单核级最大可收项实测 = publish/encode 尾税（本轮现成仪器 `bench_batched.exe` 复跑）：
130560×384×128 gemm_b 0.568 → pub 0.893（+0.325/发，380→131 GB/s）；32640×128×64 +0.120/发；8160×384×128 +0.087/发。
⇒ **单核刀的极限就是 2-4 ms/族**，这就是 M1 的两把刀，也是 M1 的全部。

## 4. S6 的健康链路闸（军规 1-4 在块驻留上的具体化，缺一不许上 dll）

1. **大宽数据不破**：块内 GEMM 必须是宽 M（M=rows×windows 的金字塔切片，帧上 130560/32640/8160 档），
   **绝不为"驻留"把 M 切成单窗口 64 行的小 dispatch**。前辈 256 线程/WG 的 coopmat 配型在 ESIMD 下 HANG（§100 四·P1），
   我们的安全区是 LW=64×2040；块几何必须从 LW=64 起，token 数按 C 反比缩放。
2. **单一世界 int8 直通不破**：块内 plane 存 **int8+scale**（生产者 store 直出，消费者 pack 直读），
   **不得新增任何中间量化往返**；f16 面只允许出现在 plan 规定处。
   ⚠ 已判死勿回锅：E4M3 **字节面用在累加残差流** = 数值 17dB<40dB（10-31 RES8 两度判死）——
   块驻留省的是**往返次数**，不是 dtype；dtype 刀只在无累加的单次 publish 面上合法。
3. **CPU 不碰像素路径**：块驻留的 ready-queue/边界全部在设备侧；host 只做一次 submit。
4. **无额外开销**：不得为驻留新增 buffer、新增 launch、新增 pack 趟；SLM 预算先判（64KB/WG 帽、
   >32KB 掉 resident WG、SLM 按 2 的幂分配——前辈 recip 数组把 2KB 顶到 4KB 代价 23ms 的案在 §100·P5）。
5. **数值形态 VERBATIM**：块内五阶段的每一步算子顺序与现路逐位一致（load 紧邻表达式、无 phi、
   命名临时量独立），改动先过 numpy golden 考古，过不了就地死刑。

## 5. 判官要改的一处（S6 落地时）

`passes=691` 现在是"op 没被吞"的结构证据；**S6 后环节数必须下降**（691→~115-160）。
所以届时的绿线改成：**逐环节对质 = 每个 megakernel 的输入/输出面与旧路逐字节一致 + walk 1301 EXACT + 确定性两遍**，
并把新的环节数记入关门账（防止以后把"691"当永久标准）。

## 6. 关门账新增（本轮，勿回锅）

- 参照系混用（3080L 的 10ms = 31 块 Small；9070XT 的 10.4ms = fp8 卡）——引用前先答三问（模型/分辨率/形态）。
- 微刀到 10ms：数学上不成立（cap ~30ms 总收益）。
- 其余关门项见 B2 §三（RES8 字节面、PGRAPH 多流、B6-1 小链融合、WQ-Cache、rowsplit quant、f16-pack 标量残留、
  S4 GRF-resident-B、PW32/SPLITC/ACCSLM、节点合并、f16-OUT）。

## 7. 刀 A 已扫完（bench 层，2026-11-01 01:0x；全表 diff=0，未碰 dll、未部署、WB 侧零改动）

交付（在 `src/bench/sycl/`，本仓副本，已从 WB 树移过来并把 WB 恢复干净）：
`bench_s8v8_tile.cpp`（模板 `gemm_var<BNV,BKV,NTV,NBUF,MODE,PUB>`，11 变体 × raw/pub 两腿 × 6 真实形状，
每变体逐字节对拍现形 `gemm_b`/`gemm_b_pub`）、`spillcheck_cache.py`（**从 SYCL 持久 JIT 缓存里的 zebin ELF**
出每核 grf/simd/slm/spill/scratch 账；AOT 链接路这次死在 ocloc "more than one module with an entry point"，
**缓存路量到的才是真跑的二进制** = 新仪器）、`bench_s8v8_tile_run3.txt`（min-of-15 全表）。

复现坑（已写进文件头，别再踩）：`build_esimd.sh` 必须 **cd 到 src/bench/sycl 传相对名**（绝对路径下 `//Fe:` 不被 MSYS 折叠）；
BK=64 时 B 的两块 kk32 在全局隔 N·32 字节，**只有 N==BN 才连续** → load_block 必须按 kc 分片拷（修前 bk64 全族 diff≠0）。

**判决（五条）**：
1. 深度轴 2/3/4 缓冲全在 ±3% 带内 ⇒ **s8d2 已在平台期，深度没有收成**。
2. 22 个变体核 + shipped 全家：**grf=128、SIMD32、spill=private=scratch=0、scratch 指令=0**，slm_size 与请求精确一致（12-48KB）
   ⇒ **过去把 PW32/SPLITC/ACCSLM 的失败归给"GRF 墙/spill"是不精确的**：这台编译器上不溢，差别全在时序。
3. 蓝图 §1144-46 的"BN 加倍+累加器减半（16col×2tile 串行）"**只在 raw 腿成立**（2040 −13.8%、130560 −4.3% 最优）；
   在 **fused-pub 腿上全形状 +8~+35% 反向**（第二遍 K 扫描把 publish 尾巴串行化）。
4. pub 腿（帧里实际吃的那条腿）的正确形态 = **bn128_nt64_bk64**（BN128/NT64/BK64/双缓冲，SLM 32KB，零溢出）：
   N%128==0 的 batched/qkv 站点 pub −4~−12%、raw −4~−8%，逐字节全等。
5. **墙在哪（最重要）**：raw 腿大 M 已到 **493 GB/s = 88%·560**（贴屋顶），
   **pub 腿封顶 ~36%·560** ⇒ **三兄弟的墙 = publish 尾巴本身，不是 tile、不是深度、不是 spill。**

**刀 A 的真实价（诚实账）**：已扫形状按帧调用数折算 ≈ **−0.9ms（串行口径）**；扣 ~55% 重叠后**帧上估 −0.4~0.6ms**。
未覆盖：两个 N=32 形状（×16/×24，走 `gemm32_b` 的 BN32/NT16 几何）需再扫一轮；
(640,64,256,8) 的 shipped pub 腿有**跨进程双峰** 0.036/0.073/0.131（小 grid 冷启动彩票，只能帧尺判）。
⇒ **刀 A 是一口牙，不是 M1 的整口**。

## 8. M1 的主口重钉（由刀 A 的测量直接导出）

pub 腿 36%·屋顶 + quant 腿 10.3ms（串行）/5.8ms（关键路径）是**同一件事的两面**：
现路 = `gemm → 写 f16 面（pub 尾巴：encode+store）→ 独立 quant 读 f16 → 写 pk → gemm 读 pk`。
**消掉 f16 面 + 消掉独立 quant = 同时消掉 pub 尾巴和 quant 腿 = 消 link，不是削 link。**
所以 M1 的主口 = **刀 B**：producer store 直出 int8+scale（scale-pregive，前辈 fused.comp 的头坑清单已给设计），
消费者 pack_a_fused 直读（PAF 机制在库），覆盖 batched/qkv/residual 三族的 160 幸存 quant。
## 9. 刀 B 普查结案（2026-11-01 03:1x，纯静态，可复现：`tools/knifeB_census.py` → `notes/census-knifeB-2026-11-01.md` 813 行）

**先更正帧的边界（旧笔记错在这里）**：captured graph（begin@step3915/line5308 → capture@step5251/line6644）才是每帧重放的：
**691 recorder step 里 quant 类 = 224 `xmx_rec_quant` + 52 `xmx_rec_quant_window` = 276**。
旧账"160 幸存 quant"是**两份 recording 相加**（scratch 期 + graph 期）⇒ **每帧真在跑的幸存 = 80 个**（196 个已被现成 take 消掉）。
另：`NR_QW_FUSE` **默认 ON**（`libxmx_sycl.cpp:2751`）⇒ **104/104 QUANT_WINDOW 早在 P4b（10-27）就溶解了**，
WB 最后一条信息把"已消灭的靶"当成"还挂着的靶"，这是它 15-20ms 说法的第一个错。

**对齐判定（没用 K==N 近似；逐行枚举双方地址区间 → 全平面覆盖 → 行内容多重集 → 落点）**：
- (a) 行对齐 **212**：a1 单段 72 / **a2 一行由多列组拼成 88**（组数分布 {2:16, 4:24, 8:48}，batched 的 `ldc==N*batch`、`sc==N` 交错宽行）/ a3 gather 视图需 scatter 52；
- (b) **形状错位 0 个**；
- (c) src 不是 gemm 写 **64**（window_attention 52 + global_attention 8 + unary 4）——这批刀 B 无效。
- 自校验：276×3=828 次 `M*K*2 / M*K / 4*M` 对 `nr_plan_buffers` 字节，**0 违例**。

**字节账（m=M*K）**：split 折 4m、已溶解折 2m、面还有别的活读者（residual skip）则 f16 写下不掉（只省 2m）。
class-a 可减 **721,121,280 B = 721.1 MB** ⇒ @560 标称 **1.29ms**；@36%（pub 实测屋顶）**3.58ms**；@88%（raw 实测屋顶）**1.46ms**；逐腿混合 **2.56ms**。

**★★ 最重要的一条（改变整个 M1 的判断）**：幸存 80 个自身流量只有 **534.4 MB**，
但它们的串行价 10.3ms / 关键路径 5.8ms ⇒ 反推有效带宽 **51.9-92.1 GB/s = 标称的 9-16%**。
⇒ **quant 这条线不是带宽绑定，是功/延迟绑定**。折并只能拿走它**字节账那一份（≈2.5ms）**，
拿不走它的 10.3ms；剩下的 7-8ms 是 elementwise + 依赖链，**只有把"每个 op 各做一遍"变成"每个块做一遍"（=S6 resident 形态）才能消**。

**guard 归因（按 plan 逐个模拟）**：80 幸存里 **72 个全部通过 `shared/colslice` 形状 guard**
（`lda==K_q`、`sa==0 或 ==gemmK`、`scale_stride==0`、`a_scale==scale id`、M 同、gap 2-3≤4），
**只因整条 `qfuse_take_b` 挂在 env `NR_Q_FUSE_B` 后面默认 OFF**（`:384-385`）；8 个被 `take_gather` 的 gather-form 规则（`:373`）挡；0 个被 guard 本身挡。
全部 quant 都是 non-in-place，244/276 共用同一对 scratch (pk=1272, scale=1273) —— 老 v9b FOLD 的 `:5024` 守卫会取消这种形态；
刀 B 不要求 in-place，但必须保住 plan 里的 producer→quant 邻接（实测 gap min 2 / max 4）。
⚠ 历史账：`take_b` 端到端曾判"NEUTRAL（batched fused pack +8ms 吃掉 quant -12）"⇒ **光打开开关不会白赢**，
必须先把 fused pack 做成刀 A 量出的 `nt64_bk64` 形态（−4~−12%）再测。

**刀 B 的真实价 = 帧级 1.3–3.6ms（混合 2.56ms）**，最大单块 = **gemm_int8_batched 宽行族（a2）**：56 个 quant、536.9 MB、混合 1.98ms；
排序 batched 536.9 > gemm f16 107.9 > window_int8_residual 60.6 > gemm_int8 12.6 > int8_residual 3.1。
**刀 B 的真门槛在 a2**：行内容合法但一行由 2/4/8 个列组拼成，epilogue 要**跨组取行峰值**（SLM 或两趟）——普查答不了，必须 bench 判。

## 10. 里程碑重排（由 §7+§9 的算术直接导出，必须诚实）

刀级总收成：A 0.4-0.6 + B 1.3-3.6 + gemm32（扫完定，估 0.5-1）≈ **4-6ms ⇒ 66 → 61±2**。
**M1（破 45，需要 −21）在刀级不存在**，无论怎么排刀都到不了。可达性账：
帧 66.5 = 串行 154 × ~43%（重叠吃掉 55%）⇒ 要 45 帧就得把串行砍到 ~104（**−50ms**）。
−50ms 只可能来自：**把 71 个块的 op 边界消掉**（每边界现在都要 encode+publish 一遍 + 下游 pack+quant 一遍）。
⇒ **M1 的正身 = S6 的第一块**，刀 A/B 的全部意义是**顺手把 S6 需要的两个接口建出来**：
① producer store 直出 int8+scale（=S6 的 plane 格式，也是单一世界 int8 直通的正解）；
② 消费者 `pack_a_fused` 的 `nt64_bk64` 宽形态（=S6 的供数形态）。
新分支上的施工序改为：**S6-0 逐核离屋顶表（已有仪器）→ S6-1 单块五阶段原型（bench 层，SLM 预算先判）→ S6-2 接 cgraph 消边界 → 刀 A/B 作为随行小刀在同一次三关里合测**。
## 11. ★ 刀 C = BN32 publish 折叠（2026-11-01 04:0x，已批准施工；这是本轮找到的唯一 5-10ms 级刀）

**发现（gemm32 家族 34 变体核 × 两腿 × 两形状 × 8 进程池化，全表 diff=0）**：
- 帧上 N=32 的 batched 站点只有 **20 发/帧**（×8 + ×12；先前 ×16/×24 是**系统性 2x 虚高**，见 §12）。
- 这 20 发的成本构成：**gemm32_b 本体 0.0936/0.0688 ms + 独立标量 publish 趟 0.3927/0.2049 ms**
  ⇒ **publish 是 gemm 本体的 3-4 倍**，有效带宽只有 **31 GB/s = 5.5-5.7% 屋顶**。
- publish 为什么这么慢（三条实测代码结构，不是 bench 伪影）：
  (a) generic-SYCL **标量 parallel_for**，一元素一 work-item，e4m3 编码链（fmul_rn×2+rint+half-round+clamp）阻止向量化；
  (b) **每元素两次 64 位整数除法**（`i/mn`、`rem/N` 都是运行值）= P4-quant-2 那条除法税；
  (c) 写面是 **64B 部分行**（帧上 sc=32/ldc=64 与 sc=128/ldc=128，group g 只写每 128B 行的前/后半）。
- **为什么 blade-5 当年没覆盖到**：`xmx_rec_gemm_int8_batched` 的 int8 融合分支守卫是
  [libxmx_sycl.cpp:2660](../src/bench/sycl/libxmx_sycl.cpp#L2660) `if ((N % 64u) == 0u && epi∈{0,1,3,4})`，
  N=32 过不了——因为头文件里**只有 BN64 几何的 pub 核**：`gemm_b_pub` 的网格 `(Mp/128)*(N/64)` 在 N=32 = **0 ⇒ 空 launch**
  （旧 `bench_n32.cpp:4-5` 里 N=32 那 0.0019ms 的"快"就是 no-op，军规 4 第四次逮到 bench 自欺）。
  `gemm32`(:280)/`gemm32_b`(:209) **只有 raw，没有 pub 孪生**；v9 融合在 `:2563` 被 `if (false && …)` 焊死
  （多组交错 ⇒ quant 行 max 跨两组），v9b 是 opt-in 且比 v8 慢。
- **tile 单独不值一刀**：只换形（NT32/BK64/BUF2，形状 B 从 24.4%→48.5-57.1% 屋顶）= **−0.41ms 串行**。
  融合才是肉：**只融合 −5.27ms 串行 / 融合+换形 −6.1ms 串行**（batched 行 18.5 → ~12.4）；
  **帧口径 −2.6 ~ −6.1ms**（66/154=43% 存活率；若这些闭包在关键路径则靠近上限——必须用 `NR_B_STOP` 夹逼取边际，不许外推）。
- 形态已验：`BN32/BK32/NT32/BUF2、线程 tile 8r×16c`，pub 腿 0.0717/0.0416 ms，**SLM 10KB（比现形 15KB 更省，不撞 32KB 占用崖）**，
  35 个核全部 grf=128 / spill=private=scratch=0 / scratch 指令=0（刀 A 结论 #2 在本族同样成立）。
- 与刀 B 不重复也不冲突：刀 C 消 `gemm→f16面` 之间那发独立 publish；刀 B 消 `f16面→quant→pk`。
  两者抢同一 producer 站点 ⇒ **顺序：先刀 C，再刀 B**（刀 B 受"行 max 跨两组"阻断，见 `:2556-2562`）。
- 另一条**零新核**备选：wide-merge（b 组并成 Nw=32·b、Kw=128·b 的宽 GEMM，raw A 天然宽行 lda=Kw，
  B 走 `gather_pack_b_diag_b` 缓存）与 split 链**逐字节全等**，且 Nw=64/128 直接满足 `:2660` 现成融合路。
  要不要用取决于宽 K 下的单价（`bench_n32` 有仪器无日志）⇒ 作为对照先测一枪。

**施工序（已下令，军规 8 优先）**：第 0 步补 **strided 写面单价**（帧上真实 sc/ldc）→ 不划算就停；
划算才加 `s8v8::gemm32_b_pub`（~90 行，从已验 bench 形态 VERBATIM 搬）→ 守卫 `N%64`→`N%32` + 逃生门 `NR_G32_PUB`（默认 OFF 待转正）
+ **独立 publish 闭包必须 no-op**（只跳 gemm 会读脏 dC）→ `dsh_build_dll.sh`（1250 门）→ `dsh_walk.ps1`（1301 EXACT + **passes 必须仍 691**）
→ `NR_B_STOP` 夹逼定边际 → `dsh_ab.ps1` 16 对。红则按军规 7 写"实现错在哪 + 下一形状"，机制与开关保留。

## 12. ★★ 新发现的系统性记账错误：op 调用数 2x 虚高（必须修所有旧账）

plan 里有**两份 recording**：scratch 期（begin@step2529/line3922 → **abort**@step3902/line5295）与
captured graph（begin@step3915/line5308 → capture@step5251/line6644）。**每帧重放的只有后者**（691 recorder step）。
过去笔记里凡是"扫全部 plan steps"得到的 op 计数都**把两区各数一遍相加** ⇒ **2x 虚高**。已确认受害的数字：
- "160 幸存 quant" → 实际 **80**/帧；"104 QUANT_WINDOW" → 实际 **52**；
- N=32 batched "×16/×24" → 实际 **×8/×12**（= 刀 C 从 −12.2 降到 −6.1 串行）；
- 1267 的 "W122 / R278" 与"残差往返 400 次"、"120 发 GEMM_INT8_RESIDUAL"、"真实流量 8GB/帧 = 14ms 地板"
  **全部要按图区重数**（§11 已下令出 `opcounts_graphonly.txt`）。
⇒ **两个方向的影响**：(1) 过去几把刀的"预期收益"普遍虚高（字节账按 2x 流量算的）；
(2) **流量地板同步下修**：若 1267 往返与面触量都 /2，8GB→~4GB ⇒ 地板 ~7ms 而不是 14ms，
**10ms 目标比 §B2 里写的"11-14ms 地板"更近**——这是本轮最影响终局判断的一条修正。
军规新增第 13 条候补：**任何计数类普查必须先声明"只数 captured graph 区（line 5308-6643）"，两区相加=2x 假账**。

**关门账新增（本轮全部实测/可复现，勿回锅）**：
"104 发 QUANT_WINDOW 还挂着"（已溶解，`NR_QW_FUSE` 默认 ON）| "160 幸存 quant"（每帧 80）|
"S2a 值 15-20ms"（字节账上限 1.3-3.6ms）| "quant 腿按带宽屋顶估"（实测只有 9-16% 标称 ⇒ 非带宽绑定）|
"N=32 家族换 tile 就快"（只 −0.41ms 串行）| "gemm_b_pub 能用于 N=32"（网格 0 ⇒ 空 launch，旧 0.0019ms 是 no-op 假数）|
"深度 2/3/4 缓冲还有肉"（±3% 带内，s8d2 已平台期）| "GRF/spill 是墙"（22+35 个变体核 spill=private=scratch=0）。

## 13. 刀 C 第 0 步 GATE = PASS（帧形 strided 单价，04:4x）+ 每帧真实发数表

**帧形参数从 plan arg tuple 直读**（不是猜）：`lda=K·batch、sa=K、sb=N·K（每组自带权重）、sc=N=32、ldc=N·batch`（A=64 / B=128）、
`col_stride=N`（因 sb≠0，:2674）、`scale_stride=0`、epi1、narrow ⇒ 写面 = 宽行里的 **32-half = 64B 部分行**。
（更正 §11 里一处转述排版错：B 形是 `sc=32 / ldc=128`，不是 `sc=128/ldc=128`——真按后者会地址重叠。）

M=32640 N=32 K=128 b=2（×8 发/帧）：8 进程池化、5 组×15、组间 60ms、msM 中位；**融合腿对拍"现形 gemm32_b + recorder publish 逐字搬"的输出面，逐字节 diff=0**（A 比较 2,088,960 / B 1,044,480 元素）：

| 形态 | msM | GB/s | %560 |
|---|---|---|---|
| 现形 gemm32_b（帧形 pack） | 0.0930 | 202 | 36.1% |
| recorder 独立 publish（帧 map 逐字） | 0.3928 | 31.9 | **5.7%** |
| **SPLIT TOTAL（现路）** | **0.4858** | — | — |
| anchor32 pub（现形几何融合） | 0.1190 | 123 | 21.9% |
| **BN32/BK32/NT32/BUF2 8r×16c pub（选形）** | **0.0735** | 199 | 35.5% |

M=8160 N=32 K=128 b=4（×12 发/帧）：现形 0.0701 + publish 0.2056 = **SPLIT 0.2756**；选形融合 **0.0461**（159 GB/s = 28.4%）。
⇒ **−0.4123×8 = −3.30ms、−0.2295×12 = −2.75ms，合计 −6.05ms/帧 串行**（现路 7.19 → 1.14）；
**帧口径 ≈ −2.6ms（×43% 重叠存活），上限 −6.1ms**（待 `NR_B_STOP` 三档夹逼定案）。
**64B 部分行写的代价很小**：A 0.0717→0.0735（+2.5%）、B 0.0416→0.0461（+11%）⇒ **不是当年 take_b 那种 +8ms 陷阱**。
**选形定案**：BN32/BK32/NT32/BUF2、8行×16列、SLM 10KB（比现形 15KB 省）、**BK32 ⇒ 不需要新 pack**；BK64 形两形状都不带（A 不稳、B 反向）。

### 每帧真实发数（只数 captured graph 区；`tools/opcounts_graphonly.py` → `census/opcounts_graphonly.txt`）
**硬交叉核对：图区 `OP_XMX_REC_*` 之和 = 691 = 判官 passes ✓**（被放弃的 scratch 区也是 691 ⇒ 同一 op 混合、不是第二帧 ⇒ **两区相加必为 2x 假账**）。

quant 224 + quant_window 52 = **276 quant 类** | `gemm_int8_batched` **72**（融合路 52：2040×128×256×8 ×16、640×64×256×8 ×16、8160×128×128×4 ×12、32640×128×64×2 ×8；**N=32 split 路 20**）| `gemm_int8_residual` **68** | `gemm_int8_qkv` **60** | `gemm_window_int8_residual` **52** | `gemm(f16)` **42** | `gemm_int8` **24** | `window_attention` **52** | `window_block` **10** | `global_attention` **8** | `unary` 16 + `unary2` 1 | `ffn` 8 + `ffn_stem` 1 + `ffn_merge` 1。
伪 op（非 launch，每帧仍动数据）：`QUANT_INIT` 276、`INT8_INIT` 156、`INT8_RESIDUAL_INIT` 120、`WINDOW_INIT` 52、`FFN_INIT` 10、`WINDOW_BLOCK_INIT` 10、`GLOBAL_ATTENTION_INIT` 8。
**GEMM 族每帧字节（S6 流量账可直接换）**：batched **1035.4 MB**、residual 282.1、window_res 249.3、f16 gemm 191.3、gemm_int8 90.7 MB/帧
⇒ 光这五族 = **1.85 GB/帧**，加 quant 类 0.53 GB 与 window_block/wa/ga/unary/ffn 的面，**总触量约为旧"8GB"叙事的一半上下**
⇒ **S6 的奖赏按这张新表重算**（旧的 26.7GB / 400 往返叙事作废）。
⚠ 新线索待普查：`*_INIT` 伪 op 每帧重写 plane（这正是 WQ-Cache 160/160 STALE 的死因）——
**若权重/常量面每帧被 init 族重写，那是军规 3 意义上的"多余往返"**，要单独量它每帧搬多少字节。

## 14. ★★★ 刀 C 自证伪 = 帧上死代码（2026-11-01 05:4x）+ 两处仪器 bug（旧 16 对数据作废）

**证伪链（closure 级探针，探针已撤、过关件已还原）**：写码进 shipped 之后、宣称收益之前，
用一次性闭包级 printf 探针重编 dll 跑两遍 ⇒ **PROBE_hits = 0（OFF/ON 都是 0）**，而探针字符串确在运行的 dll 里（md5 D24ED7A994C4）
⇒ 我的 `NR_G32_PUB` 分支从没执行。根因：`xmx_rec_gemm_int8_batched` 闭包开头就有 **P8-b wide-merge**
（[libxmx_sycl.cpp:2478-2503](../src/bench/sycl/libxmx_sycl.cpp#L2478-L2503)，**默认 ON**，逃生门 `NR_B_WIDE=0`）：
`wide_ok = N==32 && batch>=2 && N*batch<=128 && sc==N && ldc==N*batch && sa==K && lda==K*batch && sb==N*K && ss==0 && epi∈{0,1,4} && narrow && K%32==0`
⇒ **把 plan 里 20 发逐条代入：20/20 命中，0 漏** ⇒ `gemm32_b + 独立 publish`（:2699-2716）在帧上是**纯死代码**，
**§11/§13 报的 −6.05ms 串行价（含那条 0.3928/0.2056ms 的 publish 趟）帧上根本不付**。
（`bench_n32.cpp:74-91` 的注释早就记过 wide-merge 实测 0.511→0.138 / 0.280→0.103 ms/发、2 发→1 发——我测的 split 价正好等于它的 "before"。）

**三关记录（诚实，全部真跑过）**：`39/39 门 GREEN`（**门脚本实数 = 39 个，不是"40 门"**；gate 断言行合计 1291 条 ok/PASS/GREEN）；
`gate_gemm_int8_batched` 在 `NR_G32_PUB=1` 下也 GREEN（"OUT BITS EQUAL (0 bad bytes of 8355840)"）；
walk OFF = 66.24/67.81/66.86 ms、**passes=691**、**1301 EXACT**（md5 249A46F374E9 = bk.1301.bin）；
walk ON = 66.34/66.33/66.73、**691 不变**（no-op 闭包仍计数，预言对）、**1301 EXACT**；
A/B 部署件 vs 新件 OFF = 均值 −0.084（11/16）= 带内无回归；新件 OFF vs ON = +0.016（8/8）。

**两处仪器 bug（必须记账、旧数据作废）**：
1. `ab.ps1` 局部量 `$b`/`$a` 与参数 `$B`/`$A` 同名（**PowerShell 变量名大小写不敏感**）⇒ 第 2 对起把上一次的毫秒数当 dll 路径传进 exe（"cannot load 66.47"），delta 全是同一个陈旧数。
   **旧版 ab.ps1 出过的所有 16 对数一律作废**（我已重写成 v2：`$ma/$mb` + 每侧进程清场 + `EnvA/EnvB` 参数 + passes 逐对打印）。
2. `ab.ps1`/`walk.ps1` 原为 UTF-8 无 BOM ⇒ PS 5.1 按 GBK 解码，中文注释字节截断字符串、`<--` 被当重定向符。已加 BOM。
3. 顺带：`NR_B_STOP` 探针（:2466/:2490、:2667-2668）都在 wide/其它分支内，**不覆盖 N=32 split 路** ⇒ 原计划的三档夹逼对该站点不适用。

**处置**：`gemm32_b_pub` + `NR_G32_PUB` **不撤，降级为 S6 砖**——理由：这是 **BN32 几何第一次有 pub 孪生核**（结构性缺口补齐，S6 块驻留要 BN32 fused store 时它就是现成件），
也是 `NR_B_WIDE=0` 逃生路的正确形态；默认 OFF，**任何账里不许给它记收益**。
**刀 C′**（wide-merge → BN32 融合）：wide 的块对角 B（Nw·Kw 里只一半非零）被每个行带重读，B 流量 4.08/4.19 MB vs BN32 家族 1.04/1.05 MB = **4x 冗余读**，
这是真实结构浪费；但**判据只允许用 16 对帧夹逼**（A=默认 wide，B=`NR_B_WIDE=0 NR_G32_PUB=1`），预期 ≈0（这条家族已被 overlap 吃掉）。

**★★ 战略结论（今晚第三次被同一件事打脸：wide 死代码 / 四族同删只省 22.2 / gemm 三兄弟删了反而慢）**：
**154ms 串行账里有一大块帧上根本不付 ⇒ RUN_TIMING 串行账不能当刀序依据。**
下一把**仪器**（比任何刀都优先）= **帧可达性普查**：对 captured graph 的 691 个闭包，用 plan 参数**静态求值 shipped 里所有分支守卫**
（`wide_ok :2478-2503`、`N%64 pub :2660`、`v9 if(false&&) :2563`、`qfuse_take/take_b/take_gather`、`NR_V9B/NR_G32_PUB`、epi/narrow/flags 位），
产出：每族实际走哪条支路（发数+每发字节）、**帧上不付的死代码分支清单**（用来作废旧账）、剔掉不可达支路后的**真实串行账**、由此导出的**关键路径候选**。
落盘 `tools/frame_reachability.py` + `census/frame_reachability.md`。
**军规候补第 14 条：任何"家族价"必须先证"帧上可达"（closure 级探针或守卫静态求值），否则那可能是死代码的价格。**

## 15. ★★ S6-1 可行性算术（06:4x，用 `notes/opcounts-graphonly-2026-11-01.txt` 的真形状/真字节直接算，不需要新测量）

**每块的几何**：qkv 族参数给出块 = **64 token × C 通道**，金字塔层级 C ∈ {64,128,256,512,1024}：
`(2560,256,8,64)×16`、`(768,512,16,64)×8`、`(960,512,16,64)×8`、`(192,1024,32,192)×8`、
`(8640,128,4,64)×6`、`(9216,128,4,64)×6`、`(32640/35712/33728/34560, 64,2,64)×2`
⇒ 每帧：qkv 60 + window_attention 52 + window_int8_residual 52 + quant_window 52 + quant 224 + batched 72 + residual 68 = **580 / 691 个闭包属于"块内链"**。

**SLM 预算（决定 S6 能从哪一层做起）**：块驻留要在片上存**双缓冲两块 64×C 的 f16 tile**（数值不许变 ⇒ 不能像 lmxx 那样用 byte plane，我们的累加残差面用字节已判死 17dB）：
`2 planes × 64 token × C × 2 B = 256·C B` ⇒
| C | tile 双缓冲 | 判定（64KB/WG 帽、>32KB 掉 resident WG） |
|---|---|---|
| 64 | 16 KB | **✓ 最松**，还能放 B tile + 双缓冲操作数 |
| 128 | 32 KB | **✓ 正好在占用崖下沿** |
| 256 | 64 KB | ✗ 撞帽（零余量给权重/操作数） |
| 512 / 1024 | 128 / 256 KB | ✗✗ 不可能片上驻留 |
⇒ **S6 第一块从 C=64/128 层做起**（这些层恰好是发数最多的：32640/35712/33728/34560 的 C=64 ×8、8640/9216 的 C=128 ×12、2040/640/8160 的 batched ×40）；
C=256/512/1024 层（×40 发）留给"寄存器穿阶段"或按列切两半，**不许用 byte plane 蒙**。

**奖赏算术**：这 580 个块内闭包的每帧字节（A+B+C32 各一遍，不含 pack 重读）= batched **1035.4** + residual **282.1** + window_res **249.3** + quant 类 **534.4** + f16 gemm 191.3 ≈ **2.3 GB/帧**，
而其串行价 ≈ 18.5+18.0+13.4+10.3+11.0 = **71.2ms ⇒ 平均只有 ~32 GB/s = 6% 标称屋顶**
⇒ 这一大块**不是带宽成本，是小发数 × 依赖链 × elementwise 的成本**（与 §9 的 quant 结论一致）。
块驻留把每块的 qkv→wa→win_res→quant→ffn 边界消掉 = **580 发 → ~50-70 发**，
消掉的是：每边界的 f16 面写+读、publish/encode 重做、pack 重读、launch/依赖。
**保守预期：串行 154 → 90-110，帧 66.5 → 40-50 ⇒ 这就是 M1（破 45）的来源。**

**S6 的三个接口（今晚已经备好的砖）**：
1. `gemm32_b_pub`（BN32 几何第一个 fused-store 孪生核，39 门 + 1301 EXACT 已验）= 块内 store 直出已 publish 的面；
2. 刀 A 的 `bn128_nt64_bk64` pack 形态 = 块内供数形态（−4~−12%，逐字节全等）；
3. 刀 B 的 producer-side int8+scale（census 判 212/276 合法、a2 跨列组行峰值待 bench）= 块内 plane 格式。

**下一步（顺序固定）**：① 帧可达性普查（正在跑，剔掉死代码支路后重算真实串行账 + 选第一族）→ ② **C=64 单块五阶段原型**（bench 层，`qkv→wa→win_res→quant→ffn` 在 64KB 帽内穿 SLM/寄存器，对拍现路逐字节）→ ③ 原型赢才接 cgraph（691→~120）→ ④ 三关 + 16 对。

## 16. ★★★ S6-1 施工图钉死：每块 = 11 个闭包（plan 实读，行号可查），第一铲切 FFN+outproj 那 6 个

`tools/blockseq.py`（只数 captured graph 区）把每帧 691 个 recorder op 按**顺序**打出来，块链重复单元实测是 **11 发**（plan 行 5337-5383 连续两遍，逐字对得上）：

```
 1  QUANT                     1270 -> pk1272/sc1273   M=32640 K=64      (行 5337)
 2  GEMM_INT8_BATCHED         pk1272 x W83 -> 1274    32640,128,64,b2   (5340)  FFN expand
 3  QUANT                     1274 -> pk1272          32640 K=256       (5342)
 4  GEMM_INT8_BATCHED         pk1272 x W85 -> 1275    32640,32,128,b2   (5345)  FFN projection
 5  QUANT                     1275 -> pk1272          32640 K=64        (5347)
 6  GEMM_INT8_RESIDUAL        pk1272 x W77 -> **1267** skip=1270        (5349)  out-proj + 残差 -> 写累加残差面
 7  QUANT_WINDOW              1267 -> pk1272          32640 K=64        (5351)
 8  GEMM_INT8_QKV             pk1272 x W81 -> q/k/v   32640,64,2,64     (5354)
 9  WINDOW_ATTENTION          q,k,v,bias -> 1277      1020 windows      (5357)
10  QUANT                     1277 -> pk1272          32640 K=64        (5359)
11  GEMM_WINDOW_INT8_RESIDUAL pk1272 x W79 -> 1270    skip=1267         (5361)  下一块的 skip 面
```
⇒ **52 条块链 × 11 ≈ 572 发** + window_block 10 + ffn 8 + stem/merge + attention 族 = 691 ✓（与判官 passes 闭合）。
注意：**`pk 1272 / sc 1273` 是每块复用的同一对 scratch**（census 早先量到 244/276 共用它）⇒ 块内所有中间面都在 L2 里打转，**真正的 DRAM 往返只有 1267 与 1270 两个大面**（各 4.18MB @M=32640）。

**第一铲（S6-1a）= 把 1-6 这 6 发融成 1 发**（FFN expand→quant→projection→quant→out-proj+残差）：
- 片上工作集（每 WG 拥有 64 token 的一个 window，C=64、hidden=256）：
  `in tile 64×64×2B=8KB + hidden 64×256×2B=32KB + out tile 8KB ≈ 48KB` ⇒ **在 64KB 帽内**（余 16KB 放 B tile 双缓冲）；
  C=128 层（8640/9216）工作集 ≈ 96KB ⇒ **超帽**，那一层要按列切两半或只做 1-3 发。⇒ **S6-1a 先打 C=64 层**（32640/35712/33728/34560 四档 ×2 = 8 条链/帧，加 2040/640/8160 档）。
- 收益算术：这三族串行价 = batched **18.5** + residual **18.0** + quant **10.3** = **46.8ms**（154 的 30%），
  其中 1-6 的链内往返（pk/sc 写读 ×3 + 1274/1275 面写读）在块内**全部消掉**，只剩 1267 的一次写 + 1270 的一次读。
  **保守目标：46.8 → 15-20ms 串行 ⇒ 帧 −12~−18ms ⇒ 66 → 48-54**，这就是"破 45"那一档的主口。
- 数值红线（军规 1/2/5）：块内 quant 的**行峰值必须在 f16 舍入之后取**（与现路逐位同）；`pk/sc` 的数值链 VERBATIM；
  宽 M 不破（64 token × C 是块内 tile，不是 global 小 M dispatch —— §100 P1 已论证 resident 与大宽标准兼容）；
  不新增量化（只是把同一次量化搬到生产者 store 里）；CPU 不碰。
- **判据**：bench 层先做"6 发 vs 1 发、逐字节对拍 pk→1267 面"，**单价低于 6 发之和才接 cgraph**；
  接上后 passes 会从 691 掉（这是预期的，见 §5 判官改动），届时绿线改成"逐链对拍 + 1301 EXACT + 确定性两遍"。

**为什么这次不是 B6-1 的重演**（B6-1 死于 +1.42）：B6-1 融的是 `wa+quant+outproj+res-fold` 五发、**plane 照写**，消的全是 L2 已吸收的小面往返；
S6-1a 融的 1-6 里含 **hidden=256 的大面（1274/1275）与 pk 的三次写读**，而且把 `1267` 的写与 `1270` 的读**留在块边界**（该付的还是要付）。
分界线就是 §100 那条：**消真冗余指令/真往返，不消 L2 内流量。**

## 17. ⚠ S6-1a 的 SLM 预算修正（07:3x，§16 里"48KB 在帽内"是粗估，作废）

每 WG 拥有 **T 个 token**、C=64、hidden=256 的片上工作集（f16=2B / int8=1B）：
`in 128T` + `pk(in) 64T` + `hidden 512T` + `pk(hidden) 256T` + `out 128T` + `pk(out) 64T` + `skip 128T` + `写 1267 暂存 128T`，
B 权重 tile（双缓冲，固定项）：expand `BK32×BN128×2=8KB`、projection `BK32×BN64×2=4KB`、outproj `4KB`。
**峰值同活 ≈ `hidden + pk(hidden) + in + B 双缓冲` = 896T + ~10KB：**

| T | 峰值 | 判定（64KB/WG 帽、>32KB 掉 resident WG） |
|---|---|---|
| 64 | 56+10 = **66KB** | ✗ 撞帽（§16 的 48KB 漏了 pk 面与双缓冲） |
| **32** | 28+10 = **38KB** | ✓ 安全，剩 ~26KB 给 skip/更深双缓冲 |
| C=128 层（hidden=512） | `1792T+16KB` ⇒ T=32 是 73KB | ✗ ⇒ 那一层要按列切两半或 T=16，**不在第一铲** |

⇒ **第一铲按 T=32 token/WG 设计**（64-token 的 window 拆 2 个 WG）。
**这不违反军规 1**：GEMM 的 M 仍是 32640 行（宽 M 在 grid 维，不是 per-WG tile），§100 P1 已论证"片上 SLM 里的 GEMM ≠ global 小 M dispatch"；
不许因为 T 小就退化成逐 window 小 dispatch。
三条硬要求：① 三处 pk/sc **不许落 global**（这正是这一铲的意义），只活在 SLM/寄存器；1267 一写 + 1270 一读可保留；
② 行峰值必须在 **f16 舍入之后**取，`fdiv_rn` 链照 `quantize_row_kernel.hpp` VERBATIM；
③ 对拍点 = 三处 pk/scale + 最终 1267 面，逐字节 diff=0 是入场券，不一致就打印第一个偏差坐标。









