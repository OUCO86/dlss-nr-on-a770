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

## 18. ★★★ S6-1a 第 1 阶段实测（08:1x）：块驻留第一次拿到真证据，但本形状判负

**对拍 = GATE PASS：九个检查点全部逐字节 diff=0**（`pk1/sc1`、`1274 面 16.7MB`、`pk2/sc2`、`1275 面`、`pk3/sc3`、**`1267 终面`**）。
第 1 轮在 `out1275` 起偏，根因 = 融合核 P4 行标量误读 `scA`（应为 `scH`，SLM_SC+128），一行修复后全绿。
⇒ **块驻留在数值上是可行的**（不必改任何数值形态，军规 2 合规）。

**单价（min-of-15×5 组、组间 60ms、msM；两轮一致）**：
- 对照腿 = 现路**真序列 8 发**（不是 6 发！）链 wall **0.797ms**：
  `op1 quant .092 | op2 pack .088 + op2 gemm(pubslm) .311 | op3 quant(K256) .198 | op4 pack .119 + op4 gemm(wide) .235 | op5+6 pack_a_fused .101 | op6 gemm_res .211`（单发和 1.354）。
- **记账事实：qfuse 在帧上不对称**——batched 的 quant 融合默认 OFF（`NR_Q_FUSE_B` opt-in，:384），
  residual 的融合默认 ON（:304/:3092）⇒ op5 已溶进 op6 的 `pack_a_fused`；op4 走 wide-merge（:2484-2503），不是 `gemm32_b+publish` 分裂路。
  （这又一次坐实 §14：**先证可达，再谈价格**。）
- 融合腿（T=32/WG、LW=64、grid=1020 WG、SLM 31104B→32KB 桶）：GPU-only **0.887** / wall **1.014**
  ⇒ **本形状判负：+0.09~+0.22ms/链 × 8 链 = +1.7ms**。

**相位二分（cum GPU）**：`P1 .032 | +P2 expand .043 | +P3 pkH quant .224 | +P4 proj gemm .294 | +P5 pkO quant .042 | +P6 res+write .253`

**★ 三条事实性结论**：
1. **SLM 驻留的 dpas 本体碾压现路**：P2 expand = 1.07 GFLOP/链 用 **0.0433ms = 24.7 TFLOP/s**；同样 FLOPs 现路（pack + `gemm_b_pub_slm`）要 **0.399ms ⇒ 7.7x 慢**。
   ⇒ **块驻留不是 B6-1 重演，算术上限真实存在**；这是这项目一个多月来关于 S6 的第一块硬证据。
2. **输点在几何不在概念**：P4/P6 的线程占用只有 **16/64 在算（75% 闲置）** + K 切 8 kb 无预取 ⇒ 两段占融合核 62%。
3. `P3 requant .224 ≈ 现路 op3 .198`：`div_ieee` 链是省不掉的数学成本（与 §9"quant 不是带宽绑定"一致）。

**判定（军规 7，不判死）**：下一铲 = **split-K 补 P4/P6 空线程**（P4 K=256 切 4 ⇒ 4rb×4cb×4ks=64 线程；P6 K=64 切 2 ⇒ 32 线程；
**int32 部分和相加位同**（无溢出 + 整数加法可结合，|acc|≤4.1M≪2^31，不破数值红线）；reduce staging 复用死区 SLM，不加 SLM）。
预估 P4→~.10、P6→~.15 ⇒ 融合 ~.60 ⇒ **每链 −0.20ms、帧 −1.6ms**。次级：B 的 s8d2 双缓冲；P3 生产者侧融合（需跨线程行峰 reduce，先不动）。

**已下的四条令（第 2 阶段）**：A. acc 上界推导写进文件头（防后人改 K/位宽破功）；B. **线程占用当第一判据**，每相位允许各自 work-item 映射，活线程数打进 NPHASE（编译期常量，军规 9）；
C. **必须再测 M=8160（C=128 档，×12 链）与 M=2040（×16 链）两条链**，给"每档现路 wall / 融合 wall / 差 / 链数"，最后折算**全帧 36 链的串行 ms**——只有 C=64 赢就直说，不许外推；
D. **判死线定死**：若全帧 36 链折算 **< −5ms 串行**（帧 −2ms 以下），S6-1a 判"当前形态不值"，**不再试第三形状**，改打另一条：
把 P2 的 24.7 TFLOP/s 单独搬进 shipped 的 batched 站点（只换 gemm 形态、不消边界），那条刀不需要块驻留也能吃 7.7x 的三分之一。
**两条路都要有数，不许混。**

## 19. 刀 C′ 帧夹逼结案 + 帧可达性普查（08:3x）+ 判据三段式入册

**C′（wide-merge → BN32 融合，仅那 20 发 N=32 站点）= 不转正**
`A=部署件 B8908BD2（默认 wide）` vs `B=新件 + 只在 B 侧 set NR_B_WIDE=0;NR_G32_PUB=1`（A 侧两变量 unset），修好的 ab.ps1，**16/16 对有读数、无 NaN**：
三枪均值 −0.744 / −0.127 / −0.527；**合并 48 对 = 均值 −0.466 ms、B 快 31/48(65%)、median −0.685、sd 1.479、SE 0.214、95% CI [−0.893, −0.039]**。
⇒ **未过 −0.5 转正线**；CI 上界 −0.04 ⇒ 统计上分不清"≤−0.5"与"≈−0.2"，要分清需 SE≈0.1 ⇒ 约 **250 对**，不值机时。
**处置**：默认 OFF、机制+开关留作 S6 砖；理由不是"没赢"，而是 **S6-1b 会把这个边界整个消掉**，现在翻默认只会给 S6 基线多一个变量。
**方法论里程碑**：bench 串行预测 −1.05ms vs 帧实测 −0.466 ⇒ **存活率 44% ≈ 家族平均 43%**——**今晚第一次两个口径咬合**（前几次都是死路价）。

描述性单价（不作判据；宽面 vs split 参考逐字节 diff=0）：
| 路 | (32640,32,128,b2) | (8160,32,128,b4) | 20 发/帧串行 |
|---|---|---|---|
| WIDE `gemm_b_pub`（帧上现路） | 0.1185（141 GB/s=25.2%） | 0.1001（105=18.7%） | **2.15 ms** |
| BN32 融合 `gemm32_b_pub` | 0.0701（209=37.2%） | 0.0447（164=29.3%） | **1.10 ms** |
| SPLIT gemm32_b+独立 publish（**死码**） | 0.4868 | 0.2756 | 7.20（作废） |
⇒ wide 的病确实在**块对角 B**：B 流量 `(Mp/128)·Nw·Kw` = 4.08/4.19 MB vs BN32 的 1.04/1.05 MB = **4x 冗余读**。

**三关（最终件 C7634EC50B3A；md5 链 DADF115C2B8D → 2E24A4A7C118 → C7634EC50B3A，三段都是注释-only，PE 时间戳导致 md5 变）**：
39/39 门 GREEN（断言行 1291）；`gate_gemm_int8_batched` 在 `NR_G32_PUB=1` 下仍 GREEN；walk 默认路 67.03/66.59/66.43、**691 passes**、**1301 EXACT**；walk 走 C′ 路 **1301 EXACT + 691 passes**。
**shipped 注释里那句 `−6.1 ms/frame serial` 已撤**（换成 bench 口径 + 可达性说明）——**以后 shipped 注释里不许留死路价**。

**帧可达性普查（`tools/frame_reachability.py` → `census/frame_reachability.md`）已判定的部分**：
- `gemm_int8_batched` 72 发全部归位：**36 走 pub_slm**（N==128，`NR_PUB_SLM` 默认 ON :2669）+ **16 走 gemm_b_pub**（N==64 :2673）+ **20 走 wide-merge**（:2484-2503）；
  每发字节（A+B+C32 各一次触碰）：pub_slm 12.8-37.6 MB/发（757 MB/帧）、gemm_b_pub 2.8（44）、wide Nw128 8.4（101）、wide Nw64 16.7（134）⇒ **该族 1036 MB/帧，与 opcounts 的 1035.4 自洽 ✓**。
- **帧上不付的死支路清单（作废其价）**：split `gemm32_b+publish`（7.17ms/帧串行，§11/§13 用过的那个数）、v9（:2563 `if (false &&`）、v9b（`NR_V9B` 默认 OFF）、`NR_G32_PUB`（默认 OFF 且被 wide_ok 挡在前面）、`NR_B_STOP/NR_G_STOP` 阶梯（诊断，永不记收益）。
- **入口守卫审计**：把 691 发的 plan 参数代进各族 `N%64 / K%32 / N%16` 守卫 ⇒ **违例 0**（帧上没有活 FAILMSG）。
- **f16 gemm 42 发**：compact 用 `bt & 0x10000` 判；非 compact ⇒ blade-5 的 FOLD（:2304）；compact ⇒ split（只有 compact head）。
- **诚实标 UNKNOWN（不猜）**：quant 224 / quant_window 52 / qkv 60 / window_int8_residual 52 / window_block 10 / window_attention 52 / global_attention 8 / ffn 8+1+1 / unary 16+1 —— 这些支路取决于**运行态**（`g_quant_pk` 注册与 take 序列、`g_bufs` 指针别名、`g_wcache/g_lfw/genof` 命中、`S.fq` fuse 位），plan 参数定不了。
  ⇒ 已下令补**运行态 fused 快照**（`census/runtime_fuse_snapshot.md` + `tools/runtime_fuse_snapshot.py`）：按 plan 顺序静态模拟注册-配对序列（gap≤4 规则），必要时一次带 trace 的 replay 校准模型；产物要能直接喂 S6-1b：**每条块链（52 条）→ 11 发实际状态 → 融合后剩几发 → 每发字节**。

**★ 判据三段式（写进 B2 军规，候补 13/14）**：
① **可达性**：守卫静态求值或 closure 级探针证明"帧上真走这条路"；
② **bench 单价**：同进程、min-of-15×5、msM，逐字节对拍 diff=0；
③ **帧 A/B**：env 只设一侧（另一侧必须 unset），16 对（必要时 32-48 对）。
`NR_RUN_TIMING` 的 154ms 是**逐闭包 wait 的地面真值**，要修的是"从 bench 家族价外推刀收益"那一步。












## 20. 工作模式（用户 2026-11-01 10:2x 令，已执行）
**同一时刻只派遣一个子智能体**：两个并行会抢模型请求与 GPU，反而更慢、更容易在长上下文请求上超时。
已按此执行：`runtime fuse 快照`（S6-1b 前置）已叫停，只留 `S6-1a 第 2 阶段`（split-K + 三族测价）在跑；它交数后再派下一个。
上下文纪律照旧：不整读大文件、grep 行号 + offset/limit ≤120 行、每步往 E:\DSH\s6\*.md 追加落盘、失败只重试那一步。

## 21. ★★★ S6-1a 第 2 阶段终表（11:1x）+ 一处必须当面更正的旧数

**⚠ 更正 §18**：stage-1 报的 `P2 expand 24.7 TFLOP/s / 现路 7.7x 慢` = **-O2 死代码消除伪影，作废**。
加了 sink（DUMP=true 截断）重测后的诚实值：**P2 = 8.7 TFLOP/s，仍比现路 pack+gemm 快 3.2x**（不是 7.7x）。
⇒ 这是本项目**第六次**逮到 bench 自欺（前五：空 launch 0.0019ms、cs4 探针污染、bench_b6 返回 0、wall-clock 伪账、跨进程双峰）。
**新军规候选 15**：截断式相位计时**必须加 sink**，否则无人读的相位被整个 DCE；
**新军规候选 16**：**多形状同进程连跑会互相污染**（连跑时 S2 dump 读零 + S3 setup DEVICE_LOST；分进程全绿）⇒ bench 方法论定为**每形状独立进程**。

**终表**（min-of-15x5 组、60ms 组间、msM、host wall 含 launch；三形状独立进程；代码 `src/bench/sycl/s6_ffn_block2.cpp`，账 `E:\DSH\s6\stage2.md`）：

| 族 | 形状 | 链/帧 | 现路链 wall | 融合 wall | 差/链 | 融合 GPU |
|---|---|---|---|---|---|---|
| S1 | C=64 M=32640 | 8 | 0.8139 | 0.4647 | **-0.3492** | 0.3867 |
| S2 | C=128 M=8160 | 12 | 0.5898 | 0.3787 | **-0.2111** | 0.3223 |
| S3 | C=256 M=2040 | 16 | 0.4277 | 0.3660 | **-0.0617** | 0.2081 |

⇒ **全帧 36 链折算 = -6.31 ms 串行**；**判死线 D（>=5ms）过线**（高 1.3ms，不富余）；按 43% 重叠存活 **约帧 -2.7ms**。

**占用率刀已见效**：P4 split-K 后 S1 .294 -> **.052**、P6 .253 -> **.053**（act 编译期常量随 bisection 打印）。
**剩余最大单项 = P3 requant**（S1 .181 / act 32/64；S2 .175 / act 16/64）=> 候选刀"一行拆 2 线程 + SLM 半行取 max（float max 满足结合律 => 位同）"，预估再 -1.3~-1.6ms 串行。
**红线没偷**：S3 的 projection 是 **f32 累加 => split-K 非法**（浮点加不结合），该相位保持 shipped 顺序 kc（TS=16，`gemm_b_pub_f16` VERBATIM），**16/64 占用是数值红线换来的结构性代价**，已如实计入"S3 只赢 0.062"。

**普查再修正**：帧上 FFN 闭包 = **52 条链 / 四族**，不是 36 条一批：
S1 x8（C=64）+ S2 x12（C=128, M=8160）+ S3 x16（C=256, M=2040，**链形不同：无 1274 requant，proj=GEMM_F16 直读 f16 面，5-op**）+ **F3 x16（C=512, M=640，7-op 混合 GEMM_INT8+GEMM_F16+BATCHED，本阶段未建，符号未知）**。BATCHED 72 对账闭合（2x8+2x12+16+16）。

**对拍口径**：S1/S2 九检查点全 diff=0；S3 七点全 0，其 `hid` 检查点是**转储工具伪影**（A5A5 毒化实锤：store 执行、写出恒零；命名临时量修复无效，"双消费"假设已证伪）——S3 hidden 的正确性由 `out1275` 逐字节全 0 **传递蕴含**（每行 256 输出依赖该行全部 1024 hidden 元素 x 随机稠密权重），论证已入代码注释。

**待用户拍板的两条路（尚未下令，遵守"重启前不发新指令"）**：
(a) **就此接 cgraph 走一次真三关**（拿帧级真数；理由：本项目已六次证明 bench 赢 != 帧上付钱，S6 的全部赌注是"消边界在帧上值多少"，只有进图 + walk 1301 + 16 对才知道）；
(b) 先补 P3 requant 占用率刀（半天，再 -1.3~-1.6ms 串行 ~= 帧 -0.6ms，信息量低）。
我的建议是 (a)：**-2.7ms 这一档本身不值三关的机时，但它买的是"S6-1b（整块 11 发融合，量级 -12~-18ms）该不该开"的判据**。

## 22. 新工作原则（用户 2026-11-01 12:1x）：**完整机制移植**，军规候补第 17 条
原则：**以他们的核为唯一蓝本、最小改动他们的核心；我们的链路去满足他们的核的要求**（喂它要的布局/几何/数据通路），
而不是把他们的核改造成我们现在这个样子。此前"移植机制不移植代码"的做法被判定**经常抓不到重点、导致处处碰壁**，作废。
**只允许改两类，且必须逐条列名留证**：T 类 = 数据类型适配（e4m3 网格 -> 我们 int8+scale；fp8 依赖 -> int8 原生 dpas；dx::linalg wave MMA -> ESIMD dpas<8,8,32>）；
D 类 = 对我们无用/有害（线程几何：他们 C=256 用 512 线程/组，而**前辈 256 线程 coopmat 配型在 ESIMD 下直接 HANG**、LW>=128+barrier 是死锁区、max_work_group=1024 实测；SLM 占用崖 >32KB；**sub-group shuffle 原语我们工具链没有**）。
**先备份再移植**（已执行：`E:\DSH\backup\pre-port-2026-11-01\` = 13 个源文件 + 全部 .hpp + 三个 dll + md5 清单 + 被移植核原文 + port_spec.md，约 14MB）。

**第一铲锁定的核**（按可移植性实测筛过）：`refs/lmxxf-src/Development/hip-port/shaders/dx12-network/native_wave_ffn_fused.hlsl`（101 行，Swin FFN expand+contract 一发）。
它**零 shuffle**，只用 wave-scope 矩阵 + LDS + 1 个 barrier ⇒ 可忠实移植；而且正是我们已融过的那条链。
**不可忠实移植（依赖 WaveReadLaneAt/WaveActiveSum，本轮不碰）**：`native_c32_ffn_fused.hlsli`、`native_wave_c32_ffn_blocked.hlsl`、
`native_wave_attention_direct.hlsl`、`native_wave_c32_split_attention.hlsl`、`native_wave_vit_attention_half.hlsl`（grep 命中 24 处）。

**他们的核要求我们供上的东西（R1-R8，全文在 `E:\DSH\s6\port_spec.md`）**：
R1 A 直接按 fragment 序从 global 载入 ⇒ **生产者 store 必须布局原生直写，运行期零 pack**（现路链里 pack 占 **0.308/0.814 = 38%**）；
R2 权重预铺成 512B fragment 块（init 一次，跨帧不变）；R3 hidden 只在 LDS（`16x4C` 字节，"never touches VRAM"）⇒ 1274/1275 面在这条链上消失；
R4 量化在累加器寄存器内做完直接落 LDS ⇒ **P3 requant 整相消失**（S1 .181 是最大单项）；R5 两相之间一次 barrier（不许条件绕过）；
R6 K 步进 = 32 ⇒ 与 XMX int8 原生 8x8x32 天然对齐；R7 几何 cull 用线性 image 序 ⇒ **我们的 window-major token 序必须映射成它的序**（"链路满足核"的关键动作）；R8 wave 数 = C/16（见 D 类冲突）。

**判据不许挪**：T1 改了网格 ⇒ **不能只拿"与现路逐位同"当判据**，必须同时过 **numpy golden 考古**（军规 2），不过就地死刑；
单价按军规 15/16（每相位加 sink 防 DCE、三形状独立进程）；目标链 wall **<= 0.30/0.25/0.24**（对照 S6-1a 0.4647/0.3787/0.3660、现路 0.8139/0.5898/0.4277）；
达不到 -10ms 串行折算我就公开改路线。

## 23. ★★★ 移植 B 阶段交工：忠实移植核 **跑通 + 逐字节 diff=0（13 检查点全 0）**

产物：`src/bench/sycl/port_ffn_fused.cpp`（803 行，bench 层，未接 shipped）；账 `notes/port-B.md`（B0-B10，184 行）+ `tools/port_B_diffs.csv`（26 行全 0）；`E:\DSH\s6\portB_final.log`（EXIT=0）。

**判据结果**：S1 (C=64,M=32640,HID=256,W=4,G=4,LW=16,SLM=29184B) 与 S2 (C=128,M=8160,HID=512,W=8,G=2,LW=16,SLM=28928B)：
`pk1-face / sc1 / e4m3-enc / e4m3-dec / hid-f16 / pk2-slm / pk2-frag / sc2 / out-1275 / pk3 / pk3-frag / sc3 / **1267-FINAL**` **全部 diff=0**（末端面 S1 4,177,920 B、S2 2,088,960 B）。

**R1-R7 逐条供上**（行号在 port-B.md）：R1 零 pack（核内 :247/:261-263 直读 face，face 在 setup 按 dpas-A fragment 序生成）；R2 权重预铺 512B fragment 块（:253-255/:369-371，setup :511）；R3 hidden 只在 SLM（:175，e4m3→int8 同一块原位复用，核内无 global hidden）；**R4 量化即落位**（:271/:288-291 寄存器内 encode → 落 SLM；:337-352 div_ieee → int8 原位落同一 fragment 偏移；契约 :366-368 把 SLM int8 当 A、:378-388 scale 在 epilogue 乘）⇒ **现路 P3 requant 整相在移植核里不存在**；R5 四个 `group_barrier`（:309/:357/:401/:440，无条件绕过，cull 写成 WG-uniform）；R6 K=32 全 `dpas<8,8,int32_t>`；R7 16-token 组 + 线性序 + cull。

**偏离清单（无静默改）**：T1 e4m3→int8+行 scale，连带 **T1a**（int8 要整行 HID 行峰而每 wave 只见自己 64 列 ⇒ SLM 内把 e4m3 字节**原位 requant**，他们核无此趟）、**T1b**（契约 epilogue 用现路 `pub_vec_v8(1u, acc*scH*bsProj)`，不搬他们 `Ffast(H(acc))` 双舍入）、**T1c**（SLM 暂存用 e4m3 字节，f16 暂存会把 S1 顶到 60KB 撞穿占用崖）；barrier 数他们 1 我们 4；T3 wave MMA→`dpas<8,8,32>`（16×16 tile=4 dpas，权重前槽/token 后槽=shipped 约定 `gemm_s8_v8_kernel.hpp:678`）；**新事实：本 oneAPI 没有 `sycl::fence_option`** ⇒ spec 里 `group_barrier(gr, fence_option::CTA)` 编不过，用 `group_barrier(gr)`；D1 = W=C/16、G=16/W ⇒ LW=16、SLM static_assert <32KB；split-K 本移植不用（顺序升序 kb ≡ 现路升序 ks，int32 精确区间内恒等）。

**★★★ 三个 ESIMD 硬坑（军规候补 18，全部静默错、不报错）**：
1. **`simd<bool,N>` 转 int32 得 0/1，不是全 1 掩码** ⇒ 用 `&/~` 做 blend 会静默只留 bit0（本案：e4m3 字节全花，-0.4375 写成 0xE8）。全 1 掩码必须用减法造。旁证：`window_block_v3.hpp:43-44` 早有文档。
2. **dpas 累加器 fragment 只有 8 行**：`select<8,1>(row*8)` 的 row 必须是 fragment 内行 0..7；喂瓦片行 8..15 ⇒ 越界到 64..120 ⇒ **每组后 8 行静默全错**。
3. **`convert` / `bit_cast_view` 不能挂在表达式模板上**；16-wide simd 的动态下标（`v[r+8]`）shipped 链从不用 ⇒ 必须具名中间量 + 拆成两个 8-wide 载入。

**参考数（非判据，DUMP=false，3 组×15）**：移植核 S1 **0.677** / S2 **0.407**；现路 split 0.8139/0.5898；1a 融合链 0.4647/0.3787；目标 ≤0.30/0.25
⇒ **低占用下移植核已经快过现路**（-17%/-31%），但慢于我们的 1a 融合链，主因是 **D1 的 LW=16 只喂了甜区 1/16 的线程**（S1 仅 8160 ESIMD 线程 vs 130560 甜区），不是算法工作量。
**对比陷阱（必须写清）**：1a 融合链里用的是 `esimd::barrier()`（只同步 lane，不是 CTA barrier，见 bench_bar 结论），移植核用真 `group_barrier` ⇒ **别让"移植核更慢"背错锅**。

**C 阶段令（已下）**：同一核、同一 diff=0 判据下扫 **G/LW**（G=4/8/16 ⇒ LW=16/32/64；SLM 帽定上限），先上两把砍 SLM 的现成刀（① 去掉 SLM 里的 out 副本、改从 global 1275 读回行峰；② hidden 暂存与 pkO 复用同块），并留一档 32-token 组；出三段归因（消 pack / 消 P3 / 占用）+ 二选一结论。

## 24. ★ 移植 C1（占用旋钮 + 一把 SLM 刀）结案：**移植问题已回答，火力转回我们自己的链**
全表见 `notes/port-C1.md` + `tools/port_C1_sweep.csv`（8 真档 diff 全 0、8 档编译期自拒 SKIP、2 诊断、3 对照）。
**三行判读**：
① **"占用率是好解决的旋钮" 被否证**：LW 16→32 **总线程数一根不变**（grid×LW ≡ ngrp×W：S1 恒 8160、S2 恒 4080/4096），只是把同一批线程打包成更少更大的 WG ⇒ S1 msM **+24.4%**、TOPS **−20%**（slm 21504→41984 **越过 32KB 占用崖**，驻留上界 3→1）；LW=64/128 直接被 **65536B SLM 帽**拒（hidden 面 16×HID = 4096/8192B **每 16-token 组**是主块，一把 out 刀省 2048/4096B 不够）。⇒ **要抬并发必须抬线程总量**（TG / W / split-K），不是抬 LW。
② **移植核 vs 我们 1a 融合链：1a 每档都赢**（最好档 LW=16：S1 0.6019 vs 0.4647 = 1a 快 22.8%；S2 0.4210 vs 0.3787 = 1a 快 11.1%）；但移植核比现路 split 快 **26-29%**。⇒ **你的"直接搬他的代码会不会更快"这个问题就此结案：比我们的旧路快，比我们现在的融合链慢；不值得换蓝本，但他给的 R1/R2（零 pack）是真礼物，要搬到我们自己的链上。**
③ **拐因 = SLM/占用，不是 spill**：LW16 与 LW32 台账逐列相同（grf **128 顶格**、private **3328B**(S1)/**6464B**(S2)、scratch 指令 61/182）；变的是 slm 与 WG 数；分相一致：**dpas 相两档相同（expand 0.194 vs 0.194）**，慢在 **SLM elementwise 相**（requant 0.295→0.400，+36%）。
**★ 相位算力（改变全局判断的数）**：P4 contract = **39.6 TOPS**(S1) / **55.2 TOPS**(S2)；P2 expand = 5.49/5.33；P6 res = 4.05/7.40。
⇒ **dpas 矩阵相早就不是瓶颈**；**requant/outquant 占移植链 62%**（0.295/0.6175）。我们全帧 2.3 TOPS 的锅在 **elementwise（requant/publish/pack）**，不在矩阵引擎——这与 §9（quant 线只有 9-16% 带宽 ⇒ 功/延迟绑定）完全咬合。
**★ 新测量陷阱（军规候补 19）**：在 **grf 已顶格 128** 的核里加宽探针不免费——64-wide sink 把 16 个 `simd<int32_t,64>` 累加器活跃期拉长 ⇒ private 3328→3584、scratch 指令 61→174、**链 +65%**（0.6019→0.9979）。同时证明**这个核本来不需要 sink**：每相末尾都有 SLM/global store，SLM 是 WG 共享存储 ⇒ 编译器不能证明无人读 ⇒ 不会被 DCE（np=1 的 expand 无 sink 仍 0.194ms）。⇒ 探针要**窄**（每 fragment 取 8 lane 就够钉住 dpas）；sink 改为默认编译期关闭（`-DPORT_SINKS` 才开），CSV 里带 sink 的两行标 DIAGNOSTIC。
**另一处该盯的账**：移植核 **private 3328B/6464B + scratch 指令 61/182**，而我们 shipped 的 22+35 个变体核是 spill=private=scratch=0 ⇒ **移植核有 private/scratch 流量**，这是它慢的另一来源（累加器压力：每 wave 4 个 16×16 tile × GRF128 顶格）。
**下一铲（已改方向，不再优化移植核）**：把 **R1/R2 零 pack 搬到我们已出货的 1a 链**，并先做 **1a 的相位账**（窄探针，遵守军规 19），因为要砍的是 1a 里同样存在的 requant 相（stage2 里 P3=0.181/0.4647 = 39%）。

## 25. 外部"带宽破局八招"逐条对账（用户 16:5x 转来的文案；按军规 11 逐条核，别整包采纳）
| 招 | 我们账上的状态 | 依据 |
|---|---|---|
| ① 强制全向量化 load/store（simd<T,64>） | **已大量做过，且有边界表**：长 pub 链赢（ffn-3/4、blade-4 -22ms、blade-7 消息账 1024×4B→16×256B），**短链输**（ffn-5/6 3w/12l 回退）。且 **grf=128 顶格的核里加宽=加寄存器压力**：C1 的 64-wide sink 当场把链拉到 **+65%**（private 3328→3584、scratch 指令 61→174）。"窄访问浪费 30%+" 无出处 | §6.27 边界表 / §24 |
| ② 消除 SLM bank conflict | **已判"机制错误"**：XE-HPG 无 bank 模型可推（当年供数清单 8 条逐条对照时就是这条被否） | 10-30 供数清单裁决 |
| ③ 显式 L1 预取 `intel::l1_cache_prefetch` | **本工具链没有该原语**：grep `E:\WorkBuddy\toolchain-mamba\sycl\Library\include` 里 `l1_cache_prefetch / block_prefetch / prefetch_ldsc / intel_prefetch` = **0 命中**（与 `esimd::shuffle` 缺失同类）。要用只能上 asm ⇒ 属"改核心" | 本轮实测 grep |
| ④ K 分块 tiling 降全局访问 2-4x | 移植核**已经在做**（R3 hidden 只在 SLM、R4 A 从 SLM 载入）；C1 台账：dpas 相在 LW16/LW32 下**成本相同**（expand 0.194 vs 0.194）⇒ 全局访问不是它的瓶颈。且全帧触量 ~4GB、地板 ~7ms vs 帧 66 ⇒ **帧不是带宽绑定** | §9 / §24 |
| ⑤ 双缓冲 | **已实测无收成**：深度 2/3/4 缓冲全在 ±3%，s8d2 已在平台期 | §21 / stage2 |
| ⑥ 绕过 L2（uncached USM） | **有害**：§100 P8-n/o 的分界线就是"消 L2 内往返不花指令 ⇒ 收益零"；反向把 L2 命中踢掉只会更差。"15-20%" 无出处 | §100 P8-n/o |
| ⑦ XMX 与内存交错调度 | **已在发生**：asm 直数 90/101 对 dpas 背靠背（间隙 0 条）；"dpas 扎堆重排"当年也被判机制错误 | §99 微结构账 |
| ⑧ "移植核没有冗余 pack/unpack，不会增加寄存器压力/不会溢 scratch" | **与实测直接冲突**：移植核 **private 3328B(S1)/6464B(S2) + scratch 指令 61/182**，而 shipped 的 22+35 个变体核 **spill=private=scratch=0** | §23 / §24 C1 台账 |
| "0.6 -> <0.3 直接超 1a" | **无实测支撑**；真实差距 0.6019 vs 1a 0.4647（29%），且 **62% 成本在 SLM elementwise 相（requant/outquant）**，不在矩阵相 | C1 |

**把"带宽"这个词校正一次**：移植核真正多出的带宽成本是 **scratch/private 流量**（那是带宽，只不过是 scratch 带宽）+ **SLM 消息宽度**；不是 GDDR 峰值，也不是全局访问量。
**所以若转去改移植核，刀序固定为两把（都可窄测）**：
- **P-2 先砍 private/scratch**：累加器压力（每 wave 4 个 16×16 tile × GRF128 顶格）⇒ 减活 simd 数量/拆相，目标是把 private 3328/6464 与 scratch 指令 61/182 **压到 0**（shipped 变体核已证明 0 是做得到的）；
- **P-1 再砍 SLM elementwise 的消息宽度**：requant/outquant 相（占 62%）按 blade-7 的"每线程一整块 + 一条 256B store"手法做，**先 bench 定价再谈上 dll**（ffn-5/6 的教训：短链上宽化会反噬）。

## 26. ★★ C2 交回：1a 的腿账 + 承重墙定区间 + **R1 的兑现位置被证明在 S6-1b**
产物 `notes/port-C2.md`（C2-0..9）、`tools/C2_legs.csv`（71 行）、`tools/C2_spillcheck.txt`；新源 `src/bench/sycl/s6_ffn_block3.cpp`（1345 行，1a 的**复制件**，shipped 三源 git status 全空）。

**① 承重墙 = 可信，绝对值写成区间**：**S1 P4 ∈ 17.8-53 TOPS（中心 39.6）、S2 P4 >= 55（中心 55.2）**。
逐项 FLOPs：P4 = BATCHED proj（wide-merge），S1 M=32640/N=64/K=256、S2 M=8160/N=128/K=512 ⇒ **两形状都 = 1.0695 GFLOP/链**；核结构反推 **261,120 条 `dpas<8,8,int32>`/链**，与 2MNK 逐项吻合、无隐藏工作量。
不相减的整核单价交叉核对：本机 ESIMD dpas 包络 **30.9-59 TOPS**、oneDNN 实际上限 ~200、锚 130560×384×128 = 22.6 TOPS；**本轮新拿：同一个 op 在 1a = 28.0 TOPS、在现路 split = 4.67 TOPS**。
P4 两头都没顶：DRAM 流量 4.2MB ⇒ 155GB/s = 带宽 28%；算力 = 262 TOPS 的 15%。
**军规 20 实测坐实**：1a 的 P4 四次相减得 0.0382/0.0036/0.0030/0.0005 ms（TOPS 28->2049 荒谬），S2 减出 **−0.0044**；而 cum(P4) 四次稳在 0.2972±0.0001 ⇒ **抖的是 cum(P3)（0.2590->0.2968）** ⇒ **<0.05ms 的相禁用截断相减定绝对值**。

**② 1a 腿账**：
- 1a 链内**没有独立 pack_a 腿**（已融进 P1）；**split 现路**的 pack_a 两腿 S1 = 0.1983 = **split 链的 24.6%**、S2 = 0.1761 = **27.9%**；含 pack_a_fused = **34.9%**。`pack_b` 四个权重包 0.069ms 但 **cache-owned ⇒ 不进帧账**。
- **elementwise 占链 70-73%**（S1 P1+P3+P5 = 0.0316+0.2182+0.0600 = **73.2%**；S2 = **70.0%**）；六相和 = 整链 GPU 的 100.0-100.3% ⇒ 无 DCE、无漏相。
- 六相 TOPS：S1 P2 **24.4** / P4 **28.0** / P6 **4.10**；S2 P2 **30.2** / P4 未定(>=55) / P6 **3.55**。
- **台账关键差异**：`ffn2::fused`（1a）全部档 **grf=128 顶格、private/spill/scratch = 0、slm 31744B** ⇒ **C1 发现的 private 3328/6464B + scratch 61/182 是移植核独有的**。
- 窄探针代价复核：1a 加 4-lane sink ⇒ 链 **+13.7%**（移植核是 +65%）⇒ 主数一律 nosink。

**③ ★ 零 pack（R1）在 1a 上不付钱**：链口径 −0.0316/−0.0215 ms/链，但 **all-in = +0.058 ms/链（亏）**，因为 shipped 1a 里 op1 QUANT 已 no-op ⇒ 生产者腿是新付的。
- 单价：R1 一趟生产者 `pack_a_fused` 0.0900 vs 现路两趟（`qr_launch_esimd` 0.0889 + `retile_a` 0.0750）= 0.1639 ⇒ 省 0.0739/链。
- 折算 20 链/帧：链口径 −0.511ms 串行（帧 −0.28）；**all-in +1.11ms/帧（亏）**；
- **下一步的账（未施工）**：fragment 序落位要折进 **1270 的上游生产者**，但上游多写 int8 面（S1 2.09MB/S2 1.04MB ≈ +0.004/+0.002ms）+ 同样的量化功（≈0.03ms，只是搬家）；**而写 1270 那一发同时是 P6 的 f16 skip 源 ⇒ 必须 f16 与 int8-face 两份都写 ⇒ 净收益 ≈ 0，除非连 1274/1275 的 pk 面也按 fragment 序落位** ⇒ **这就是 S6-1b（整块 11 发融合）才有的位置**。

## 27. ★★ 路线定案（用户 2026-11-01 18:4x："排"）：**混合链**已写成规格落盘，防上下文压缩丢尾巴
规格文件：`notes/s6-mixed-chain-spec.md`（M1/M2/M3 + 判据 + 接线 + 队列 + 回滚，全部写死）。
**定案依据 = 分相对账不是整体优劣**（§24/§26）：
- **P2 expand（K=64 浅）1a = 24.4/30.2 TOPS vs 移植核 5.49/5.33 ⇒ 我们赢 4.4 倍**；
- **P4 contract（K=256/512 深）移植核 = 39.6/>=55 TOPS vs 1a 28.0 ⇒ 他们赢 1.4-2 倍**；
- **P6 res 打平（4.10 vs 4.05）**；
- 移植核多付两处工程账：**requant 0.295 > 1a 0.218**（根因 T1a：int8+行 scale 要整行行峰，每 wave 只见 64 列 ⇒ 多一趟 SLM 原位 requant；他们 e4m3 无 scale 网格天生没这趟）与 **private 3328/6464B + scratch 61/182**（1a 实测全 0）。
⇒ **所以不整体换蓝本**：保留我们的 P1/P2，**只把 P4 换成他们的 contract 形态 + R1/R2 布局（M1）**，**把 T1a 的整行行峰折进 P2 epilogue 的 4 个 SLM max 槽**（float max 结合交换 ⇒ 位同；P3 从两趟变一趟，M2），**并守住 private/spill/scratch=0 的台账红线**（M3）。
**目标**：链 wall **S1 <=0.33 / S2 <=0.30**（现 1a 0.4647/0.3787）；帧预估 **−1.2~−1.6ms**，M2 削到位可到 **−2~−3ms**。
**判据**：13 检查点逐字节 diff=0 是入场券（不许放宽）；每形状独立进程；**主数一律 nosink**（4-lane 窄探针在 1a 上也 +13.7%，移植核 +65%）；**<0.05ms 的相禁用截断相减定绝对值**（军规 20）。
**接线**：复用已出货的 `NR_S6_FFN` 六发邻接状态机（`libxmx_sycl.cpp:503-712`），**只换核体**，不动邻接逻辑/guard/WKey。
**★ 基线换件提醒（重要，防止重复计钱）**：今后帧夹逼的 **A 侧 = E2D5E574（含 1a）**，不再用 B8908BD2，否则会把已吃到的 −3.0ms 再算一遍。
**队列（一次一个代理）**：① S6-1b 可行性探针（在跑，含把 C2 的 13 点门补绿：D2H 换 `malloc_host`/`q.copy`；OOM 定性 = 失败点仍能单块分配 1074MB 而失败请求 2.09MB ⇒ host-pinned/staging 配额，不是设备字节预算）→ ② **本混合链规格** → ③ **S6-1b 整块 11 发 -> 2 发**（attention 那一发仍单独留着：他们家 attention 核全依赖 `WaveReadLaneAt/WaveActiveSum`，我们无该原语，按"完整机制移植"原则不能忠实搬，要用 SLM 造等价交换需单独批准）→ ④ 其他零 shuffle 核移植（c64/c128/c256_wave2_bi_bo、split_ffn_one_w2f8_w16、ffn_proj0_fused）；依赖 shuffle 的五个排最后。

## 28. ⚠ 更正 §26/§27：**C2 的 OOM(39) 定性是错的**——不是配额，是一笔 **4x 越界读的尺寸 bug**（已修，判据/数值一字未改）
**真相**：走 `sycl::malloc_host` 分块后，`faceB/faceA` 那两笔 **2,088,960B 的 D2H 完全成功**；死的是 **`scB` 的一笔 522,240B**。
**算式（单位错）**：设备侧 `scB = mk(Mp*4)` = **Mp*4 字节** = 130,560B；host 侧 `std::vector<float> hScB(Mp*4)` = **Mp*4 个 float** = **522,240B**，拷贝长度又取 `hScB.size()*4` ⇒ **请求 = 分配的 4.0 倍** ⇒ 越过 USM 尾端 ⇒ L0 报成 `UR_RESULT_ERROR_OUT_OF_DEVICE_MEMORY(39)`。
**修法**：`std::vector<float> hScB(Mp)` ⇒ 拷 `Mp*4` 字节 = 分配字节数。
⇒ **§26/§27 里凡写"host-pinned/staging 配额"的地方作废，以本节为准**；我在 `50d07f5` 的 commit message 里把那个错定性原样带进去了，一并更正。
（C2 的"设备窗口 ~250MB 墙"仍然成立，那是另一件事，来自 C2-4a，别和这条混。）
**复盘一条方法学**：`memprobe` 打出的"失败点仍能单块分配 1074MB"这个数**把我们都带偏过**——它只证明"字节池没满"，不证明"这次请求合法"。**先算请求字节 vs 分配字节，再谈配额**。
**军规候补 21**：`OUT_OF_DEVICE_MEMORY(39)` **也会由越界读设备指针触发**，不一定是字节不够；
`std::vector<T>(n)` 的长度是 **n 个 T**、不是 n 字节——**字节数一律用 `size()*sizeof(T)` 与分配处逐字对照**，D2H/H2D 的拷贝长度必须由**同一表达式**给出（别一处写 `Mp*4` 一处写 `Mp*sizeof(float)`）。

## 29. ★★★ S6-1b「整块 11 发 + 一 WG 一整窗」**被硬件容量证伪**（A770 SLM 64KB）——这是本战役最值钱的一次否定
产物：`notes/s6b-feasibility.md`（全程追加式）、`tools/s6b_feas.csv`（21 行台账）、`src/bench/sycl/s6b_probe.cpp`、可复跑算术 `tools/s6b_layout.py`。

**帽边界钉死（stub 探针：11 片 + 5 别名块 + 11 个 `group_barrier`，无 dpas，每配置独立进程 + 20s 看门狗）**：
- `slm <= 65,536` **含**、**65,600 即被拒**（`UR_RESULT_ERROR_OUT_OF_RESOURCES(40)`，JIT 层真拒，`S6B_FORCE=1` 复现过）；
- **无一 HANG**；台账 **grf=128 顶格、private/spill/scratch = 0**（没有变差）。

**字节账（我们自己的 int8+scale 网格，非别名/别名后）**：
`C=64/T=64` 全案 **135,680B** ⇒ 别名后 **73,984B ⇒ 超帽 8,448B**；`C=128/T=64` = **139,520B（2.13x 帽）**；`C=128/T=16` 全案 65,600B（**差 64 字节被拒**）；`C=64/T=16` 全案 36,928B（超 32KB 崖 4,160）。
**`1267`（残差面）= 8,192B@C64 / 16,384B@C128，横跨 P6->P11 ⇒ 不可别名、不可落 global = 整块融合的固定税。**
⇒ **T=64 档"回到 32KB 崖内"算术上不可能**（`hidden ∪ qkv+att` 单块就 32,768B）。

**代价曲线（SLM 字节 -> 驻留 -> stub ms，GPU msM）**：
`16,384B/驻4 = 0.4750` → `24,640B/驻2 = 0.6457（+36%）` → `36,928B/驻1 = 1.3512（+184%）`；C=128 同形 **+60%**。
**11 个栅栏几乎免费**（同布局 11/1/0 栅栏 = 1.3512/1.3419/1.3455 ⇒ 0.4-1.8%）⇒ **贵的是字节与驻留，不是同步**。
⇒ **最省的 11 相骨架（cfg8，不含一次 dpas）GPU 0.4750 / wall 0.5480，已经超过 1a 一整条真链（0.4647）+22%（GPU）/+18-21%（wall）**；按 1a 的 T=32 所有权 = **3.0-3.1x**，T=64 贴帽档 = **3.7-3.9x**。

**唯一有讨论资格的几何**：`T=16 + 整窗 k/v 与 B tile 落 global`（24,640B / 驻2 / 0.6457）——
**但它把 §16 的立论打掉一半**：S1 每链多 **12.6MB 写 + 16.4MB 读**，且 R1 的 fragment 序落位要**跨 4 个 WG 对齐**。
切法排序（谁必须落 global）：`qkv(16,384) > B tile(8,192) > sc(1.3K)`，`hidden(32,768)` 是最后手段，**`1267` 不可切**。
（本铲按令**未测**后 5 发的现路单价 ⇒ 这里只给骨架价，不给净收益。）

**里程碑账因此改写**：
- ~~"S6-1b 整块融合 = 帧 −10~−11ms ⇒ ~52"~~ **作废**：11 发一 WG 一整窗在 64KB SLM 上不存在。
- 还在桌上的三件：**(1) 混合链 M1/M2/M3**（把 1a 的 P4 换成他们深 K 形态、T1a 行峰折进 P2 epilogue；目标 S1 <=0.33/S2 <=0.30 ⇒ 帧 −1.2~−3ms）——**下一铲，已排**；
  **(2) 半块融合 S6-1b′：11 发 -> 2 发（6+5）**，第二块只含 `quant_window/qkv/wa/win_res`（现路合计 ≈45ms 串行 / 52 链 ≈ **0.87ms/链**），其 SLM 预算必须先用 `s6b_layout.py` 算进帽再施工；
  **(3) 形状合并（Track 2 原意）**：把窄 K 并宽（P8-b 先例），这是 2.3 -> 10-22 TOPS 那条腿，与 SLM 无关。
- **军规候补 22**：**任何"驻留/融合"类方案先算 SLM 字节账（可复跑脚本），再写一行核代码**——本铲用 5 分钟算术 + 一个 stub 就否掉了一条两周施工路线。

### 29b. 探针收尾补记（19:4x）+ 一台仪器被修好
- **口径钉死**：1a 的 **GPU nosink = 0.3878 ms**、**wall = 0.4647 ms**（差 0.077 = launch/host 记账）。
  ⇒ §29 里"骨架 0.4750 已超 1a 整链"必须写成 **GPU 0.4750 vs 1a GPU 0.3878 = +22%**，**不许拿 stub 的 GPU 去比 1a 的 wall**。
- **仪器 bug（已修）**：`spillcheck_port.py` 的 `label()` 原来只匹配**同命名空间**的 `L5fusedINS_<n>(Geo|Shape)I`，
  于是跨命名空间的 `ffn3::fused<ffn2::Shape<...>>`（mangled 里是 `N4ffn25ShapeI`）**被静默归入 other** ——
  **C2-7"台账没拿到"有一半是这个造成的，不是真的没有台账**。探针版 `tools/spillcheck_s6b.py` 已加通用回退（`(\d+)(fused|probe)I` + 前缀链取命名空间），
  本轮把同样的宽容匹配补进 `spillcheck_port.py`（`INS_(?:(?:\d+\w+)*)\d+(Geo|Shape)IJ?...`）。
  ⇒ **军规候补 23**：仪器"读不到"先怀疑**匹配器**，再怀疑"数据不存在"；**静默归类为 other 的解析器 = 假阴性制造机**。
- 探针按令未测的两笔（下一铲要补）：**后 5 发（quant_window/qkv/wa/win_res）的现路链口径单价**，以及 **T=16 + 整窗 k/v 落 global 的真链（带 dpas）**能不能落进 `1a 0.3878(GPU) + 消掉的 0.1668-0.1983ms/链 pack 腿` 这个窗口。

## 30. ★★★ **更正 §16 的立论**：读了 lmxx 的 attention 真码才看清——**他们从来不做"整块一 WG 常驻"**
用户 19:5x 提醒"要参考他那边前后设计再下令"，我去读了实现，**§29 的证伪因此有了正确解释：被否掉的不是他们的方案，是我对他们方案的误读**。

**硬证据（`refs/lmxxf-src/Development/hip-port/shaders/dx12-network/native_wave_attention_direct.hlsl` 文件头 #L1-L10）**：
- "**Multihead window attention *without* LDS staging of Q/K/V**"；
- 前一相 `normalize` 把 f32 QKV 输出转成精确值，**按 window-major 存进 global**：`[window][token 0..63][3*CHANNELS]`；
- attention 本身：**"Q/K/V tiles are wave loads straight from that buffer; only the exp table lives in LDS"**；几何 = **每 (window, head) 256 线程 / 8 waves**。
**再看他们 §4.4 的 smem 账**（DevHistory 路线 A 35 核表）：`c512_qkv_attention_compact_w16` = **6,144B**、`c64_wave2_bi_bo` = 12,288B、`c128_wave2` = 24,576B、`c256_wave2` = 49,152B、`sp_run256_w16` = 49,152B。
⇒ **他们每一相的 LDS 都只有 6-49KB，而且最大的常驻是"FFN 的 hidden（16×4C）"，attention 只放一张 exp 表**。
⇒ **所以"整块 11 发塞进一个 WG"从来不是 lmxx 的设计**——§29 撞到的 64KB 帽，他们根本没去撞，因为他们的粒度是**"一相一核 + 布局原生的 global 面"**。

**由此把 R1 的兑现方式改写（这是本节的实际价值）**：
§26 说"R1 的钱锁在整块融合里、1a 上单独做要亏 +0.058/链"——**那个结论的前提（必须常驻才零 pack）是错的**。
lmxx 的零 pack 是靠 **把面按消费者 fragment 序写进 global**（不是靠 SLM 常驻）：
- 生产者多写的只是**同一批字节的另一种排布**（S1 的 int8 face = 2.09MB ⇒ ≈0.004ms）；
- 消费者 `A::Load(..., RowMajor/fragment)` **直接读、零 pack**（移植核已逐位证过这件事可行：`port-B.md` R1 :247/:261-263 + setup :501）；
- **不需要 1267/hidden 常驻 ⇒ 与 64KB SLM 帽无关**。
唯一要处理的是 §26 已点出的那笔：**写 1270 那一发同时是 P6 的 f16 skip 源 ⇒ 要 f16 与 int8-fragment 两份**（+2.09MB 写/链，实测代价 ~0.004ms，可接受）。

**修正后的 S6-1b′ 施工目标（取代 §29 里的"11 发 → 2 发常驻"）**：
1. **融合单元 = 相，不是块**：(i) FFN expand+contract（= 已出货 1a，31,744B SLM，已在帧上 −3.0ms）；
   (ii) **qkv + normalize + attention + outproj 做成一相**，照他们：**Q/K/V 从 global 按 window-major 直读、SLM 只放 exp 表（≈6-8KB）** ⇒ 我们的 64KB 帽与 32KB 崖**都不构成障碍**；
   (iii) **布局原生 global 面**：所有 pk 面由生产者按消费者 fragment 序写 ⇒ 全帧 **pack 腿清零**（split 路实测 pack_a = 0.1983/0.1761 ms/链 = 链的 24.6%/27.9%，§26）。
2. **发射数才是他们的第二优势**：hip-port 0.36/0.37 记的是 **launches 197→179/帧 @1080p**；我们同口径（0.522Mpx）是 **691**。按 §13 的 2x 更正后我们每帧真发 ~691（图区），仍远高于他们 ⇒ **"相数"这一项我们还有 3 倍空间**。
3. **军规候补 24**：**读外部方案要读它的"数据放在哪一层"（global 布局 vs LDS 常驻），别只读它的"融了几相"**——本次误读差点让我们把两周投进一个硬件上不可能存在的几何。

## 31. ★★ 混合链 M1/M2/M3 交数：**M1 否证（形态不是优势）**、**M2+M2b 到手 −0.9ms 帧**、以及**一条可能影响已出货件的非确定红**
件：`src/bench/sycl/s6_ffn_block4.cpp`（block3 复制件，起点 MD5 4299658C，block3 一字未改）；账 `notes/port-M.md`（296 行）+ `tools/M_sweep.csv`；新仪器 `tools/spillcheck_M.py`（逐实例出账，开关进 mangled 名）、`tools/M_ledger_agg.py`、`tools/run_M.ps1`。

**① M1 = NO-GO，一分未得（重要证否）**：**1a 的 P4 本来就已经是他们的 contract 形态**
（逐行对照 `s6_ffn_block3.cpp:264-266/299` vs `port_ffn_fused.cpp:408-413/430-431`：A=SLM fragment 序 int8、B=512B fragment 块、scale 在 epilogue 乘），
真正的差别只有 **wave 高 16-vs-8** 与 **K 链深 8-vs-2**。把移植核原样搬进 S1：`cum(P4) 0.2970 -> 0.7100`（P4 = 0.4497ms = **2.4 TOPS**，act 8/64）；
只减累加器的两个变体给 0.33/0.28ms；S2 同判（V1 0.3141、V3 0.2530 vs 1a <0.05）。趋势单调：**act 8/16/32/64 -> 0.45/0.33/0.28/0.004-0.042**。
⇒ **移植核的 39.6/55.2 TOPS 来自它自己的几何（LW=16、SLM 21504B、3 WG/slice、48 活线程/slice），不是来自形态**；
而那个几何装不进我们 64 线程/31104B 的块链，"整块换小 WG" = S6-1b，已被 §29 的 64KB SLM 帽证伪。**最终形 P4 保持 1a。**
（这同时**回收了 §30 的乐观**：他们 layout 里"形态"那一半我们早就有了；剩的真优势 = **零 pack 的 global 布局（§30 R1）** 与 **他们的几何/驻留排布**。）

**② 真正降的是 M2/M2b**：
- M2（行峰折进 P2 epilogue）：`cum(P3)` S1 **0.2940 -> 0.2050**（区间 0.2184 -> 0.1245，−0.094）、S2 **0.2670 -> 0.1194**（0.2105 -> 0.0615，−0.149）；代价 `cum(P2)` +0.008/+0.001。
- **M2b（把 encode 那一趟按行拆到 64/T 个线程）才是主刀**：P3 贵的是 **IEEE 除链只跑在 T 个线程上**；拆段后每个 part 从同一批槽自算同一行 scale（不相交 kb 段 ⇒ 位同是**结构保证**）。
- 链 wall（同谱系、每形状独立进程、nosink、min-of-15×5、60ms 组间）：**S1 0.3828 / S2 0.2573**；对照 split 0.8139/0.5898、**1a 0.4647/0.3787（本轮 base 重测 0.4549/0.3814）**、移植核最好档 0.6019/0.4210、1aR1 0.4900/0.3959（M2b 下 0.4113/0.2726）。
- **目标 S1 <=0.33 未达（差 0.053）；S2 <=0.30 达标（余 0.143）**。GPU msM：S1 0.3895->0.3225、S2 0.3223->0.1985。
- **帧口径：20 链 = −2.1 ms 串行 => 帧 ≈ −0.9 ms**（43% 存活；S3/F3 未建，不外推）。
**必要偏离（已留证）**：峰值槽数取 **HID/16**（S1 16、S2 32）而非规格写的 HID/64——我们 P2 的 wave 只拥有 16 列，HID/64 会让 4 个线程对同一 float 做**非原子 RMW = 丢更新**；HID/16 每槽恰好一个写者 ⇒ 无原子、无额外 barrier、**SLM 增量 0**。

**③ M3 台账：最终形没破 0** —— 两形状 × 13 实例全 `grf=128、slm 31744B、private/spill/scratch=0、scratch 指令=0`；M2 的 SLM 增量 = **0 字节**（峰值槽面别名到 OUT 死区，不跨 32KB 桶）。
破线只出现在 M1-V1（scratch 2304B + 35 条）——**移植核那笔 scratch 账在我们身上复现，已随 M1 一起弃用**。
（另更正代理自己一次列读错：2048/2304 在 **scratch 字节列**，不是 private；private/spill 一直是 0。）

**④ ★★ 非确定红（必须优先定性，且它牵涉已出货件）**：`M_REPEAT` 抓到 **1 发起始不符**：m2b 的 S2 **冷进程第一发** DUMP 与 block3 不一致
（hid 8067/8,355,840，首差 row=3 byte=6 A=00 B=80；级联 pk2 11585、sc2 107、out1275 131600、pk3 104455、sc3 842、**1267-FINAL 245603**）；
同二进制下一进程 9/9；此后连发 **152 发全 0**，其中 **base（=已出货 1a 同码）40 发也全 0** ⇒ 频率 ≈ **1/6 门进程、1/158 发射**。
红的位置**包含 P2 的产物 hid**，而 M2b 没改 P2 算法 ⇒ 嫌疑 = **相位栅栏缺 ACQUIRE**：
`esimd::barrier()` = 先 `__esimd_fence(global_coherent|local_barrier)` 再 `__esimd_barrier()`（`memory.hpp:12045-12048`），**fence 只在进入侧**。
**这条风险属于已出货的 1a 核（E2D5E574），不只是本铲。** 判别器已编好未跑：`//DM_BAR=1` = 把 21 处栅栏换成真 CTA 栅栏 `sycl::group_barrier(it.get_group())`。

**定案（写死，等用户回来执行）**：
1. **先做 flaky 定性**（冷进程 x N 对照 base/m2b/m2c + walk 确定性两遍 + `DM_BAR=1` 判别器）——**先于任何接线**；
2. 定性绿了再开**接 shipped 铲**：复用 `NR_S6_FFN` 六发邻接状态机、**只换核体**（M2+M2b），39 门两侧 + **1301 EXACT** + 确定性两遍 + 16 对，**A 侧基线 = E2D5E574（含 1a）**，档位 −0.9ms 帧；
3. 若 `DM_BAR=1` 证明是真 CTA 栅栏修掉了红 ⇒ **1a 出货件也要跟进这个栅栏修法**（那是正确性问题，优先级高于 −0.9ms）。

## 32. ⚠ 更正我反复写错的代际事实（用户第三次指出）：**e4m3 字节面架构不需要 fp8 硬件**
**卡片代际（写死，以后不许再混）**：
- **RTX 3080 Laptop = Ampere(sm_86)，无 FP8**，比 A770 还早几年；
- **Arc A770 = Xe-HPG(2022)，XMX 只有 fp16/bf16/int8，无 FP8**；
- **RX 9070 XT = RDNA4(gfx1201)，有 FP8**——lmxx 的 fast chain 主要跑在这上面（hip-port 0.20 起）。
**关键更正**：我此前说"他们的字节面到我们这里必须再量化成 int8+scale，等于改他们的设计"——**这句框错了**。
**lmxx 的路线 A 就是在 3080L（无 fp8 硬件）上跑他们那套 e4m3 字节面架构**：核里 `NATIVE_HW_H=0`、`NATIVE_HW_QUANTIZE=0`（默认走软件路径），`H()`/`Ffast()` 就是手写的 f16/e4m3 位技巧（`native_wave_ffn_fused.hlsl` #L20-L31）。
⇒ **e4m3 字节面在"没有 fp8 的卡"上完全可实现**，A770 不是障碍；障碍只是**没有 fp8 的 MMA 速率红利**（他们 3080L 路线 A 慢到 108-114ms 也正是这个原因）。
**而且我们自己的链里本来就有 e4m3 腿**：B 阶段十三检查点里就有 `e4m3-enc` / `e4m3-dec`，**与现路逐字节全等**（§23）⇒ 我们不是第一次碰这个网格。
**于是真正的未解问题（下一铲靶子，优先级高于形状合并）**：
> **为什么 lmxx 能把残差/激活流压在字节网格上做到 ~42dB（对 exact chain）/44-47dB（对 NVIDIA），而我们 RES8 只测到 17dB？**
候选解释（全部要实测，不许猜）：(a) RES8 当年压的是 **int8 无 per-row scale**（或 scale 粒度不对）；(b) 误差在 **71 块里累积**，单帧 dB 与序列 dB 不是一回事；(c) 他们的 e4m3 走 **±448 sat_cast 钳位 + `H()` 链**（0.10 版专治"黑块"，#L25），保相对精度的方式不同；(d) 我们的 **RMSE 域**与他们不同（他们在编码色域/网络输出上算）。
⇒ **这条一旦打通，流量地板从 ~7-12ms 掉到 ~4-6ms，71 层模型的 20ms 目标才有余量**。它是**当前性价比最高的一个未测事实**。
**军规 11 补条**：引用外部数字前先答三问之外，**还必须答第四问：那张卡的哪一代**（有无 fp8 / 有无 wave64 / LDS 多大 / 带宽多少）。本轮就是漏了这问，连错三次。

## 33. 跳块铲交数（03:1x）：**机制安全、单价真实，但跳块不是 20ms 的路**——并且**判官本身被发现有问题**
产物：`notes/skip-table.md`（全表+复现）、`notes/skip-ledger.md`、`tools/chain_map.csv`（52 链映射）、`tools/skip_prices.csv`；开关 `libxmx_sycl.cpp:1069-1212`（`NR_SKIP_CHAINS`/`NR_SKIP_MAP`，调用点 :1231，**147 行纯新增 / 2 hunk**）。
**安全性**：默认（未设变量）新件 dump md5 = **金标 249A46F3…**（两个独立进程）⇒ **默认侧逐位不变**；跳块 = 链区间闭包全 no-op（**passes 仍 691**，cgraph 节点减少），与 `NR_S6_FFN` 复合（capture 在 S6 record 之后 ⇒ 融合腿一起死）；**硬守卫**：`term=0` 或链内含 UNARY/patch-merge ⇒ **REFUSED 并打印，不静默跳**；核内零运行时分支。
**军规 13 的坑被证实并处理**：capture 时 `names=1382 / cmds=691`（`xmx_abort` 不清 `g_cmd_names`）⇒ 代码按 tail 切片 `offset=691` 并打印。
**链图**：52 条链 = 52 个 `xmx_rec_quant_window` 锚点；**可跳 44**（C64×6、C128×10、C256×14、C512×14），**拒跳 8**（转换链 3,9,17,25,33,41,47 含 UNARY+patch-merge + 末条 51）；链外 107 闭包 = stem/mega/ViT 瓶颈 8 块/头，本刀未碰。
**单价（会话内 Δ；控制 none = 63.32 ms）**：
- **C512（14 条）= −0.335 ms/链，且 dB 饱和**：跳 1 条 30.91 dB ⇒ **跳全部 14 条仍 30.80 dB**（后 13 条近乎免费），全档 **−4.69 ms**；
- C256（14 条）= −0.35 ms/链，dB **不饱和**（30.67 → 24.17），全档 −4.93 ms；
- C128 解码后段 −0.43…−0.53 ms/链；**lmxx 语义映射（链 42,43,46）= −1.36 ms @27.22 dB ⇒ 不能照抄**；
- C64 末条（链 50）−0.65 ms @21.90 dB；
- ★ **非线性/反噬**：跳**编码器** C128(4,5) = **+0.70 ms（更慢）**@17.07 dB；跳 C64(0) = **+5.45 ms**@19.51、(0,1)=+3.11@18.74 ⇒ **又慢又烂**（8 进程交替复核：63.2-63.6 vs 68.7-68.9，不是热漂移）。⇒ **单价必须按"档内跳几条 + 位置"读，不许外推；拆半档会反噬 locality，整档拆掉才拿回节省。**
**确定性/闪烁**：18 个集 × 2 进程 dump md5 **两两全同**（CROSS=inf）⇒ 无跨进程不一致；**但单帧重放确定性 ≠ 时序稳定**，闪烁仍需实机序列验收。
**★ 诚实上限**：只靠跳块，44 条全跳实测 **−19.35 ms ⇒ 物理上限 43.98 ms/帧 @960×544**，但那已是 **16.96 dB = NR 等于没开**；
**在 ≥35/≥40 dB 约束下跳块能给 = 0 ms**；在 30-31 dB 平台下 = **−4.7…−5.6 ms（63.3 → 57.7/58.6）**。
**⇒ 20ms 不能靠砍块，只能靠减环节（S6 驻留/融合）+ 减功（字节网格消 requant）。**
**★★ 判官被发现有问题（必须先修再用它评任何数值铲）**：`bk.1301.bin` 网络面**不是 [0,1]**（RGB −7.84…+5.96、A 5.66…47.87），lmxx 的 40/35 dB 是在 **clamped [0,1] 画面**上算的 ⇒ 尺度无关口径才可比；
且**结构改动会被 120 层残差链系统性放大**（`skip_diag.py`：L512x2 corr=0.986 mean|d|=0.34；L128x2 corr=0.70 mean|d|=1.63；**不同跳法两两 16-28 dB，与它们各自到金标的距离同量级**）——与"字节网格扰动穿 120 层 = 17 dB"完全一致。
⇒ 修法（下一铲第一步）：**把 dB 搬到 post 合成后的画面**，或改成 **A/B 自比对**（skip vs noskip）+ **clamped [0,1] 口径**，否则"任何跳块都过不了 35dB"会误杀本来能用的铲。
**仪器 bug 记账**：`walk.ps1` 的 `param [int]$runLines` 在第 25 行被重新赋值为匹配行 ⇒ 类型错杀它的 stdout 尾巴；本轮代理改从 `logs\walk_*.txt` 解析（未擅自改我的脚本）。

## 34. 字节网格铲交数（2026-11-02 04:1x）：**判官已修对；17 dB 是口径伪影；字节网格"分面而治"**
产物：`tools/db_meter.py`（五口径 + corr 门槛写死）、`E:\DSH\s6\judge_calib.csv`（跳块标定 54 行）、
`E:\DSH\s6\bytegrid.md`（本铲流水账）、`E:\DSH\s6\bg_ledger.csv` + `bg_variants.csv`/`bg_extra.csv`、
`E:\DSH\s6\bytegrid_judge.py`；开关 `src/bench/sycl/libxmx_sycl.cpp:1213-1395 + 6 hunk`（**198 行纯新增**，
站点 :3300/:3694/:3717/:3883）；新件 `out\libxmx_new.dll` md5 **274B2493…**（出货件 E2D5E574 未动）。
**(0) 新判官（写死进工具与账，以后所有数值铲用它）**：`corr ≥ 0.99` 结构安全 / `0.95 ≤ corr < 0.99`
必须实机画面验收 / `corr < 0.95` **否决**；dB 只作辅助，且**必须同时报 dB@range 与 dB@[0,1]**
（本面 RGB 混算量程 **13.7986** ⇒ 两口径差 **22.80 dB**，混了就是把好铲判死/把烂铲放过的根源）。
另报 `mean|d|/σ_gold`、`p99.9|d|/σ_gold`、`worst-1% 像素 dB`。自测：bk vs bk = inf/IDENTICAL/corr=1；
合成噪声 σ=0.5571 = **27.88 dB@range / 5.08 dB@[0,1]**（旧标定 27.89 吻合）。
**(1) 跳块标定（用现成 dumps，没重跑 GPU）**：corr 与 dB@range **不同轴**——
dec64x1 corrmin=0.9757 只有 21.90 dB，C512all corrmin=0.9652 却有 30.80 dB；
18 集里 `corr≥0.99` 的**只有 none**，14 集落实机验收带，4 集（L64x1/L64x2/L128x2/all44）corr<0.95 结构否决；
CROSS 18/18 逐位同。**⇒ 新判官没把跳块铲救活**（§33 的"≥35dB 下给 0ms"在 corr 口径下依旧成立），
但它把"幅度大"与"结构坏"分开了——这正是评字节网格要的分界。
**(2) RES8 考古：17 dB = 口径伪影 + 不可复现仿真；真死因不是画质**。
入仓仪器只有两个且都不碰 1301 面：`bench_res8cmp.cpp:75` = `10log10(Σref²/Σerr²)` **相对功率 SNR**
（合成数据 skip∈U(-6,6)、权重随机 int8）报 **35.4 dB**；`bench_res8.cpp` = 纯计时。
链仿真脚本**不在仓内**（`git log --diff-filter=A` 10-30..11-02 无；`g.1267.bin` 已删；WorkBuddy 工作树只剩 memory）
⇒ 17 dB **不可审计**，而它比的"40 dB 批准线"是 lmxx 在 clamped [0,1] 画面上算的 PSNR ⇒ 口径差 15-23 dB。
网格事实：当年压的是 **e4m3 + per-ROW(64 列) pow2 scale + ±448 钳位**（`gemm_s8_v8_kernel.hpp:830`、
`:393 e4m3_vec_v8` 的 `min(mag,448)`）——**不是** int8 无 scale，±448 钳位**早就在链里** ⇒ §32 候选 (a)(c) 否证；
作用面只有 **1267 累加残差**（1274/1275 从未压过）。
与口径有关的两条旧"否证"，本轮**被站点分解推翻一半**：
① 真 1267 面 **98.73% 脱 e4m3 网**（10-31 的 numpy 网格测试）= 它测的是**无 scale 的裸 e4m3 网格**；
   本轮实测：按**写者自己的几何**（该站点 rows×N + 行 pow2 scale）把 1267 snap 到
   `e4m3 × 2^ceil(log2(peak/448))` 网格 ⇒ **面里 0 位改动 / 1301 逐位 EXACT**
   ⇒ **"字节面 = 有损重编码"这句对"带行 scale 的 e4m3 面"不成立**；
   ② 但**时间那条否证仍成立**：字节面折进 gemm epilogue 实测 **0.49-0.76x = 反而慢**
   （commit 6c0a295，根因=核离 DRAM 屋顶 10-19 倍，store 腿 <10%）。
**(3) 实测（NR_RES_BYTE，QDQ 等价论证：pow2 scale 下解码值在 f16 精确 ⇒ 读者看到的数 = 真字节面的数）**：
| 面 | 网格 | corr_min / corr_luma | dB@range / dB@[0,1] | 判定 |
|---|---|---|---|---|
| 1274/1275 单相中间面（72 站点，185.27M 元素/帧） | int8 + 行 pow2（乃至 512 行共享 scale） | **1.0000 / 1.0000** | **inf / inf ⇒ 1301 逐位 EXACT** | **免费可用** |
| 同上 ×0.5 活性见证 | – | 0.9671 / 0.9889 | 28.23 / 5.43 | 证明站点在活路径（非哑火） |
| 1267 累加残差（68 站点，46.60M 元素/帧，recorder 1268） | **e4m3 + 行 pow2** | **1.0000 / 1.0000** | **inf ⇒ 1301 逐位 EXACT，面字节 0/33.42M 改动** | **免费** |
| 同上 | int8 + 行 pow2 | 0.9912 / 0.9949 | 34.90 / 12.11（面改动 95.9%） | **CORR-SAFE** |
| **1270 窗残差/skip**（104 站点，86.60M 元素/帧，recorder 1271/1282/1284/1289/1292） | e4m3 + 行 pow2 | 0.9828 / 0.9913 | 32.34 / 9.54（面改动 46.9%） | **实机验收带** |
| 同上 | int8 + 行 pow2 | **0.7903 / 0.8709** | **20.29 / -2.51**（面改动 85.4%） | **否决** |
| 1267+1270 合算（= 第 4 步的原始行，会骗人） | e4m3 / int8 | 0.9828 / 0.7807 | 32.34 / 20.30 | 见下"合算数为什么骗人" |
| 同上 e4m3 粒度放宽 | 16 行 / 64 行共享 scale | 0.9671→0.9531 | 29.25→25.49 | 越粗越差，放宽即近否决 |
⇒ **分面而治（站点分解 + 面字节对拍才是权威）**：**三条面流里有两条压 1 字节是免费的**
（1267 用 e4m3+行 pow2 ⇒ **面里 0 位改动、1301 逐位 EXACT**；1274/1275 用 int8+行 pow2，
连 512 行共享一个 scale 都 **0 位改动、逐位 EXACT**），1267 用 int8 也在 **corr 0.991-0.995 / 34.90 dB = 安全带**；
**唯一抵抗的是 1270**（窗残差/skip）：e4m3 打 46.9% 的面元素 ⇒ corr_min 0.9828（luma 0.9913）/ 32.34 dB
= 实机验收带，int8 打 85.4% ⇒ corr 0.790 / 20.29 dB = **否决**。
**合算数为什么骗人（军规 21 候补）**：s8row 合算 20.30 dB 看着像"残差流压字节必死"，
拆开才知道 20.3 dB 几乎全是 1270 给的；e4m3w 合算的 1301 md5 与"只打 1270"**逐位全同**（481C6CAE）
⇒ 1267 那 68 站点贡献 0 位。**任何多面族的数值铲，交数必须带站点分解**，否则一个数会把两族相反的结论糊成一个。
**(4) 流量账（这铲给的是字节，不是 ms）**：按站点实测触量
**1267 = 46.60M 元素/帧、1270 = 86.60M、1274/1275 = 185.27M**（f16 ⇒ 93.2 / 173.2 / 370.5 MB 写/帧）。
**免费那两条**（1267 用 e4m3 + 1274/1275 用 int8）= **231.9M 元素 = 463.7MB 写/帧**，
加它们各自 ≥1 趟读 ⇒ 字节化省 **~0.46GB/帧 = 图区口径 ~4GB/帧触量的 ~11%**；1270 若过实机验收再加 ~0.17GB（~16%）。
折算：按 560GB/s 标称屋顶 **0.8ms**（含 1270 = 1.1ms）；按本项目实测 120-190GB/s 有效带宽
**2.4-3.9ms**（含 1270 = 3.4-5.3ms）——**都是上限，本轮没有实测到**（探针的 ms 是仪器价，见 (5)①）。
⇒ **地板 ~7.1ms(标称 4GB/帧) 最多到 ~6.3ms，不是 4-6ms**；"4-6ms"要**残差流字节化 + S6 消往返**两件事一起成才成立，
而本轮把第一件事的证明拿到了（1267/1274/1275 免费），第二件事仍是 S6 的活。
⇒ **20ms 正路不变 = S6 块驻留**；字节网格的排法 = **块边界上 1267 存 e4m3+行 pow2、1274/1275 存 int8+行 pow2（都逐位不变），
1270 暂留 f16**；且**必须先推屋顶**——今天核形态下折字节的实测价 0.49-0.76x（反而慢），白付 ALU。
**(5) 仪器口径教训（军规 21 候选，写死）**：
① **探针的 Δms ≠ 铲的出货价**：独立 QDQ 趟的代价随并行度塌方（gran 1→512 = 187→43438 ms/帧），
   这种行只能标"仪器价"，不许进刀账；要价就去测折叠形态（本仓已测：0.49-0.76x）。
② **EXACT 的铲必须做"活性见证"才算数**：逐位不变有两种相反解释（无损 vs 打错地方）。
   加一个 `NR_RES_LIVE=1`（snap 后 ×0.5）的破坏性见证，一次跑就分开了。**今后任何"默认侧 EXACT"的新数值铲，
   交数时必须带活性见证行。**
③ recorder id ≠ plan id 的差不是 1 而是**按档位变**（1267→1268、1270→1271/1282/1284/1289/1292、1274/1275→1307/1308）；
   面行宽随档位变（同一块内存按 64/128/256/512/1024 列不同视图复用），**rows 一律按 bytes/(cols·2) 封顶**，
   按 `Mp`（ceil 到 128）盲算必越界。
④ 本文件 `extern "C" {`（:753）里**不能放模板**（"templates must have C++ linkage"）——新核要么 `extern "C++"` 包，要么放块外。
⑤ **静态面统计只能当线索，判据是运行级**：按"整面单一行宽"算格占用会得出 1267 = 98.36% 脱 e4m3 网
   （与 RES8 旧账 98.73% 几乎同数），但那混了**别的档位的旧视图 + 毒化行**（1267/1274 里 peak=65504、
   1267 有 520,336 个 NaN 元素）；只有**该站点自己的 rows×cols + 该站点选的 scale** 才是实现会用到的格。
   本轮翻案靠的就是"写者几何下 snap 后面字节 0 改动"这一条，不是靠静态占用率。

## 35. 折叠铲交数（2026-11-02 05:3x）：**这把刀的机制仓内早有（NR_Q_FUSE_B）；修了它的形门，仍判负——并证到它的上限就是中性**
产物：`src/bench/sycl/libxmx_sycl.cpp`（**41 行增 / 3 行删 / 6 hunk**：`NR_BG_FOLD` 别名 :385、
`bg_b1_ok()` 形门 + census :1400-1419、capture 打印 :1421-1425、record 期 b1 判定 :3072-3076、
run 期形选择 :3134、`NR_BG_FOLD_LIVE` 活性见证 :3137-3145）；新件 `out\libxmx_new.dll` = **460FC367…**
（出货件 `out\libxmx.dll` **E2D5E574 未动**；`oneapi\libxmx_sycl.dll` 门跑期间临时 stage、**已复原 E2D5E574**）；
`E:\DSH\s6\{bgfold.md, bgfold_ab.ps1, bgfold_gates.ps1}`。未 commit。
**★ 先记一条"别重复造"的事实**：用户描述的"pub epilogue 直出 pk/sc + 后置 QUANT 整发 no-op"，
**仓内已有实现 = `qfuse_take_b`（libxmx_sycl.cpp:383-417）+ 消费者的 `pack_a_fused_b/b1`（:3099-3107）**：
take 在 record 期把相邻 QUANT 闭包**整发** `[](){}`（:413，全动/全不动 §31 合规），
消费者读生产者的 f16 面**直出 fragment 序 int8 + scale**。默认 OFF 的历史标注是
"A/B 00:45 end-to-end **NEUTRAL**（batched fused pack +8ms eats the quant −12）"。
刀 B 普查（2ef0c51）另已判定：**80 个幸存 QUANT 里 72 个全过形状 guard，只因这条 take 挂在默认 OFF 后**。
**〔真正的增量 = 逮到形门写错】** `pack_a_fused_b1`（单读形，`pack_device.hpp:558-613`）**本来就能吃 col-slice**
（`:605-606` 有 sa==64/128 的编译期 select 偏移），但调用侧形门写的是 `lda_e<=512 && sa==0u`（:3104）
⇒ **frame 上多数 col-slice 站点被踢回每形重读整行的 `pack_a_fused_b`**（= 历史 +25ms 的病根，注释自己点名）。
已改成 record 期 `bg_b1_ok()`（lda∈{64,128,256,512} && (sa==0 || (kb_n==1 && sa∈{64,128} && (batch−1)·sa+K≤lda))，
**不满足就退回每形，绝不越界读**）。census：每录音 **72/72 消费者全折叠，形 split = 36 b1 / 36 每形**。
**〔三关〕** 默认侧两独立进程 1301 = **249A46F3… 金标**、passes 691、帧 62.97-63.13；
折叠侧 **1301 逐位 EXACT（四进程全等）+ passes 691**；**活性见证 `NR_BG_FOLD_LIVE=1`（a_scale×0.5）⇒ 1301 MISMATCH**
⇒ 折叠路真喂画面、非哑火；**39 门两侧 39 GREEN / 0 RED**（无红点需解释）。
**〔16 对〕** A=E2D5E574 默认 / B=新件 + 只 B 侧 `NR_BG_FOLD=1`：
**B 赢 0/16，均值 +1.780ms，中位 +1.800，sd 0.499，SE 0.125，95% CI [+1.535,+2.025]** ⇒ **判负、不转正**。
**〔归因（谁吃回去了）〕** 消掉的 QUANT+pack 两腿帧上只值 **A−C = −0.15ms**（C = 折叠 + `NR_QF_B1=2` 连折叠 pack 也跳
⇒ 两腿全没，帧不动）；新增的折叠 pack 收 **+2.11ms（B−C）**；形 split 头寸 **1.0-1.3ms（F vs B）**。
⇒ **净 = +1.96ms ≈ 16 对实测 +1.78**；**即使 36 站点全修成 b1，最好也只到 +0.5…+0.9ms ⇒ 过不了 −0.5ms 出货线**。
**这就是"上限=中性"的定量证明，不是不想修**（军规 7：机制+开关保留，默认 OFF，下铲可复用）。
**〔第三次独立同判〕** 消腿 ≠ 省时间：QFALIAS（4d1ac63，删 pack+144 quant 仍 +8.9）、跳块铲（§33）、本铲（A−C=−0.15ms）。
同一根因：**今天 cgraph 里这些腿藏在 overlap 下，帧 = latency/staging-bound**。
⇒ **字节落位（R1/R4）唯一的兑现位置是 S6 块驻留——那个 f16 面根本不存在的时候**。
下一铲序因此不变：**S6-1b 整块 11 发→2 发**，把 fragment 序字节落位**做在块内**（而不是在块边界加一趟）。
**〔仪器 bug 记账（用户的脚本我没动）〕** ① `run_gates.sh` 的 `GATEPY`（.workbuddy 那个 python env）**已不存在**
⇒ 门跑要用 DSH 自带 python（新驱动 `E:\DSH\s6\bgfold_gates.ps1`，39 门名单照抄）。
② **`ab.ps1:29` 的清场名单缺本铲/上铲的新开关**（`NR_BG_FOLD`/`NR_BG_FOLD_LIVE`/`NR_RES_*`/`NR_SKIP_*`）
⇒ B 侧开关会漏进下一对 A 腿（两侧同折叠 ⇒ delta 恒 0）。本轮用自建 `bgfold_ab.ps1`（同协议 + 55 个 NR_* 全清）。
**建议把 ab.ps1 名单补全**（照你上次修 NR_S6_FFN 那次）。

## 36. ★★ S6-1b′ 第一相（attention 侧 5 发 → 1 相）= **本会话第二个正向结果**（C=64 档 −19.9%，逐位 EXACT）
产物：`src/bench/sycl/s6b_att.cpp`（新）、账 `notes/s6b-att-stage.md`（210 行）、可复跑 `tools/s6b_att_layout.py`、台账 `tools/S6b_att_ledger2.txt`。shipped 三源零改动。
**① SLM 预算先算后写（军规 22）**：一 WG 拥有一个 64-token 窗（C=64/T=64）⇒ 别名后 **峰值 32,768B = 正好贴 32KB 崖**（§29 cfg10 实测该格驻留 2），帽余 32,768；只需两片落 global（**qkv 面 24,576B/窗 = §30 的布局原生面**）。
**算术模型的信用证明**：它把 b6 旧形复算成 **57,344B**，与 `b6_res_kernel.hpp:56 SLMB=57344` **逐字节吻合**。C=128/T=64 = 41,216~41,472B ⇒ 帽内但**超崖 8,448（驻留 1）**。
**② 现路 5 发链口径单价（新数据，以前只有家族账）**：C=64/S1 **wall 0.5402/0.5417、GPU 夹逼 0.4244/0.4251**；分相 wall 区间 `P7 0.097-0.099 | +P8 0.167-0.169 | +P9 0.196-0.197 | +P10 0.015-0.016 | +P11 0.063-0.064`；C=128 wall 0.3920-0.3932 / GPU 0.2802。
**③ 对拍 = 两档 × 12 检查点逐字节 diff=0**（pk0/sc0、Q/K/V 三面、scores、probs、att、pk2/sc2、pk2-folded、**1270-FINAL**）；**活性见证**：probs×0.5 ⇒ C=64 的 1270 变 2,082,479/2,088,960 个 half ⇒ 非哑火。
台账：**grf=128 顶格、private/spill/scratch = 0、scratch 指令 = 0**（全部计价腿）。
两处 bug 入册：(a) **判官自己错了一处下标**（att 检查点漏 `+c` ⇒ 虚报 96% 差异，而同时 pk2/sc2/1270 全 0 ⇒ **"面检查点互相矛盾 = 判官错的第一信号"**）；(b) 融合核真错一处：P10 读 ATT 写成 `(kb*4096+row*32)*2` ⇒ **半字/字节单位混在一个表达式** ⇒ 越进 scores 块。
⇒ **军规候补 25：SLM 地址表达式里 `*2` 只能出现一次；写之前把那行的单位写死在注释里。**
**④ 单价与判定**：
- **C=64 档融合赢**：wall **0.4340/0.4351 vs 0.5417/0.5402 = −0.1077/−0.1051 ms/链（−19.9%/−19.5%）**；GPU **0.3122 vs 0.4251 = −26.6%**。
 ⇒ 8 条 C=64 链 = **−0.84…−0.90 ms 串行 ⇒ 帧 ≈ −0.36ms**（43% 存活）。**且这条 5 发链现在比已出货 1a 的 6 发链还便宜（0.435 vs 0.4647 wall）**。
- ★ **而且这是在几何吃亏时拿到的**：融合核只有 **510 WG × 16 = 8,160 线程**，现路链同形状给 **~49,000 线程** ⇒ **赢的是"消往返"，"驻留/线程"那笔钱还没吃**。
- **C=128 档判负**：wall **+0.2004/+0.2034（+51%）**、GPU +68%；根因 = 线程数（2,160 vs ~26,000）+ 超崖 8,704B（驻留 1），**不是概念**。
- **二选一：接图只接 C=64 档（8 链）；C=128 不接。**
**⑤ 可信度自审（它主动标的坑）**：nosink 的 cum 曲线在 **P9/P10 那一格两轮符号相反（−0.0043/+0.0115）⇒ 该格不可信**（产物只活在 SLM、无 global 汇 ⇒ 被 DCE 剪过）；可信锚 = P0 0.0022 / P1 0.0332 / P2 0.1487 / P5 0.3079；**相位归因只能用带出口的 sunk 曲线（绝对值虚高，只看形）** ⇒ 军规 15/20 的第三条边界。
**⑥ 下一铲序（代理建议）**：(a) 接 shipped 三关 + 16 对（A=E2D5E574 含 1a，档位 −0.84ms 串行）；**(b) LW=64 重映射 = 乘数所在**（C=64 已贴崖余 0 ⇒ 必须先把 AS 挪进寄存器或把 scores 拆两半 −8,192B 才有帽）；(c) **最贵相 = P8（qkv gemm + v5a 尾 + 三面落位 0.22-0.23）**，可单独一刀（BN=192 一发、B tile 只读一遍），不需要块驻留也能吃。

## 37. ★★★ 诊断铲交回：**XMX 屋顶随 N/K 与精度变化极大**——"离屋顶几倍"必须先查形状表，否则会把 92% 误读成 8%
**新仓内参考表 `tools/xmx_f16_roof.csv`（30 行，同进程实测，宽 M=130560、batch=1）**
- f16（`f16v1::gemm_b`）TOPS：N32 = 1.84/3.64/5.43/6.46/8.59（K=32/64/128/192/384）；N64 = 2.43/4.82/8.95/11.38/13.92；N96 = 2.75/5.35/10.11/17.84；N192 = 3.17/11.44/16.04；N384K128 = **12.37**
- int8（`s8v8::gemm_b`）：N64 = 3.90/7.38/12.78/16.99/20.33/25.45；N128 = 5.05/17.22/33.70；N192 = 5.62/19.65；N384K128 = **22.73**（**仪器自校验：复现仓内 22.6 锚，差 0.6%**）
- **实测倍率：int8/f16 = 1.43-1.84x（浅 K 处只有 1.4-1.6，不是 2.0）；K 深度 x4.7-6.7（K32->K384 同 N）**
**⇒ 军规 26：任何"离屋顶几倍"必须先按 (dtype, N, K) 查这张表；拿 int8 宽形状锚去裁 f16 浅 K 腿 = 系统性误判 12 倍。**

**18 发最贵启动（`window_block` 10 + `global_attention` 8 = 31.7-32.2 ms 串行 = 全帧 21%，仅占 2.6% 发数）逐发 FLOPs/TOPS**（`tools/wb_ga_ops.csv`、`tools/wb_ga_tops.csv`；dpas 条数反推独立核对通过，与 `libxmx_sycl.cpp:4910` 的 flop_note 逐位相同）：
- WB 每窗 **524,288 MAC**（QKV 196,608 / scores 131,072 / attnV 131,072 / proj 65,536；head 形 +32,768）⇒ 十发 **35.367 GF** ⇒ 家族 **1.76 TOPS**；
- GA 每发 **0.15099 GF**（scores+attnV 各 37.75M MAC，rows=tokens=192、heads=32）⇒ 八发 **1.208 GF** ⇒ 家族 **0.104 TOPS**；
- **18 发合计 36.575 GF / 31.7 ms = 1.15 TOPS**。

**★ 判决：算力上没有肉（这是本铲最重要的结论）**
- **WB 矩阵腿 = 该形 f16 屋顶的 81-150%（均值 92%）⇒ 离屋顶 1.09x，几乎贴顶**（outproj 甚至超宽 M 屋顶，因 A 供在 SLM）。逐腿 TOPS：QKV 2.22(81%)/scores 2.28(94%)/attnV 3.17(87%)/proj 2.76(150%)。分相（用 shipped 自带 `stop_stage` 纯 stop 阶梯，8160w POOL）：**QKV 1.4429(35.7%) > scores 0.9370(23.2%) > attnV 0.6739(16.7%) > 出口 tail 0.3979(9.8%) > softmax 0.2047(5.1%)**，矩阵腿占 **85.1%**、elementwise 只占 15%。
 ⇒ **纯算力口径两族只剩 −0.9 ms（WB）/ −1.0 ms（GA）：这里没有 −10ms 的算力肉，明确否定。**
- **GA 的 gemm 腿离屋顶 3.3-7.0x，但两腿只占发价 11%（0.162/1.45ms）⇒ 这个倍数不值钱**；真正的 69% 是 **softmax ~1.0 ms/发**，跑 **2.4 G elem/s**，与 `merge_heads` 环（2.7 G elem/s，由 merge0 门 delta 反推）**同速** ⇒ **不是"这个核慢"，是"这条 op 的 elementwise 触点就是这么多"**。

**★ 还活着的四笔肉（都不在算力上）**
1. **WB 超占用崖**：两核台账 `slm 45,056B > 32,768` ⇒ **驻留 1**；§24/§29 实测超崖代价 ≥24% ⇒ **上限 −3.9 ms/10 发**（未实测）。切法 = 省 12,288B（SCR 4SG×4KB=16,384 + 六面 28,672；候选：PPO 与 scrC 之外再把 ATO 别名进 AQO 死区）。
2. **GA 融合**（scores+softmax+attnV 一 WG 常驻 = §36 已做过的事搬到 GA 形）：**−2.3…−5.5 ms 串行**（按 §36 实测 −19.9%wall/−26.6%GPU 外推 −2.3…−3.1；softmax 进 SLM 跑 2x 则 −5.5）。纸算 SLM：`960·RB + 24,576B` ⇒ **RB=8 = 32,256B 进崖 ✓**；RB=16 = 39,936 超崖；RB=48 = 70,656 帽都进不去。**代价 = 只有 768 WG ⇒ 线程薄（§36 C=128 判负那条教训）** ⇒ 要么按列切再跨 WG 归约行和。
3. **softmax 的 simd 宽度刀**：宽度阶梯（与 shipped **逐字节 EXACT**，mismatch=0/1,179,648）`SG4 2.0654 / SG8 2.0678 / SG16 2.2776 / SG32 2.2777 / shipped 形（IGC 自选=16）2.4330` ⇒ **−15%**；若在 dll 上兑现 ⇒ 家族 **−1.3 ms/帧**。**一行属性级别的刀，零质量代价。**
4. **WB 四腿 f16→int8 = −5.9 ms/10 发**（屋顶表算术 14.00 → 8.15 ms）——**需要质量裁决**：A/B 面换成仓内 int8 链的 pk/sc 网格（每行 scale）、`cached_pack_b_f16` 改 int8 预整定权重、epilogue 加 requant；**改的是数值契约不是性能**。

**★ 仪器规矩（§36 坑的第二形态，已入册）**：停线根因查实——探针链 2.90-2.95 vs RUN_TIMING 1.45 = **2.03x**，同一 `softmax_kernel.hpp` 同旗标，**dll 实例 simd=8、探针实例 simd=16 ⇒ 不是同一个二进制**；已排除常量折叠（改运行期 getenv 仍 2.5022）与 spill（两侧 private/spill/scratch 全 0）。
**⇒ 军规 27：探针/独立 TU 的绝对值不得给 shipped dll 内核定价；两份实例的台账必须逐列（grf/simd/slm/private/scratch）对上才算同形。**
唯一红点待查：`packdev::pack_b16_t_b` 一个实例 **private=608B**（scratch 指令 0）。

**诊断铲自己的排序建议（我已采纳并调整）**：(1) softmax simd 宽度刀（零风险、一行属性）→ (2) WB 驻留刀（−3.9 上限）→ (3) GA 融合（−2.3…−5.5，注意线程薄）→ (4) WB int8 dtype（−5.9，质量裁决）→ (5) att 相 LW=64 重映射。
**att 相 LW=64 与 P8 BN=192 与 WB 矩阵腿无关——WB 矩阵腿已在屋顶。**

## 38. 宽度审计铲结案：**可转正 = 0 ms/帧**；§37 肉 3（−1.3ms）从名单上**划掉**（幻影），但换来三条新事实
① **哪种写法真的改台账**：`[=](sycl::item<1> it) [[intel::reqd_sub_group_size(N)]] {`，N∈{8,16,32}。三条硬事实：
- **每个核在 JIT 缓存里有两种命名实例**：`RoundedRangeKernel<…>` 包装形 + 裸闭包形；**属性只动闭包形，而闭包形才是活实例**（packwide 铁证：Rounded 形全程 16 不动、帧却 +1.95ms）。**旧 `spillcheck_wbga.py` 的去重 key 不含 simd ⇒ 诊断铲那句"pack simd=32"只报了半个实例。**
- **N=4 非法**：`reqd(4)` 编得过（仅 deprecated 警告）但台账不动 + 运行期拒：`Sub-group size 4 is not supported on the device`；**探针阶梯里的"SG4"是 nd_range 的 WG=4，不是 sub-group**——两回事。
- **`SYCL_ESIMD_KERNEL` 与 `reqd_sub_group_size` 在 clang 前端互斥**（`error: attributes are not compatible`，两种顺序都试）⇒ `qr_kernel_rowthread`、`wbv4::launch_v4full/v4ph`、`f16v1::gemm_b*`、`qres`、`wares`、`ffn2::fused`、`pack_a_fused*` 这些 **ESIMD 族（矩阵+quant 主体）没有属性级宽度刀**；它们台账里的 `simd=1` 是**显式 SIMD 契约，不是 IGC 选错**。
② **逐靶**（全部 1301 EXACT，无一 MISMATCH；表 `tools/simdwidth.csv`）：
- `vit_softmax_tiled`：**活实例本来就是 simd=8 = 赢家档** ⇒ §37 的 −1.3ms 是**探针 TU 内部对照的幻影**，钱早已在袋；强制 16 = **+0.362ms/帧（2/16 赢，CI[+0.19,+0.61]）** ⇒ 宽度阶梯确实转移到 dll（探针 +10.1% vs dll +10.5% 咬合）；pin8 = +0.234（pin 效应微负）。
- `merge_heads` 环：活宽=8=赢家档；pin8 带内。
- `wbv4` 两核：ESIMD 互斥无法上属性；**slm 45,056B 超崖与宽度无关**（几何问题，归驻留铲）。
- `ffn2::fused`（1a）：ESIMD 互斥 ⇒ 本铲未碰其 codegen ⇒ **零退让风险**。
- pack/gather 族（31 条 SIMT）：活宽=32；强制 8 = **+1.952ms/帧（0/16 赢，CI[+1.68,+2.18]）明确判负** ⇒ **pack 族 IGC 选 32 是对的**（gather 腿宽=省指令，与 softmax 反向）；GA 三腿单独切 8 = −0.049 带内（腿只 2ms 串行，钱淹没）。
- 控制（HEAD 无旗标 vs E2D5E574）= +0.048 带内 ⇒ HEAD 基线与 shipped 帧等价，变体 delta 可归因于属性。
③ **建议：不把任何 `reqd_sub_group_size` 写进 shipped**（现宽即各族赢家档）；宏门 `SIMDREQ_SMAX/PACK/MERGE`（默认 0 = shipped 行为）留在 relax 分支当砖。
④ ★ **新抓出的红点（比宽度本身值钱）**：
- **`pack_a_fused_b1` 有 176-211 条 scratch 指令**（另有 pack_a_fused* 1376-1472B、`qkv_scatter` private 7680B、`ffnc::launch_ffn_chip` 2272B/350 条、`stem_mega` 1024B/14 条、`b6` 512B/6 条、`f16v3::gemm_resid_pub` 512B/4 条）。
 ⇒ **scratch = 真实的全局流量 + 延迟**，而 §34/§35/§36 已两次证明"计价腿 private/spill/scratch=0"是可达的标准（1a、att 相、移植核对照）。**这是下一条铲的头号靶**。
- `pack_b16_t_b private=608B` 结案：真身 = `gather_pack_b16_t_b` 的 32 宽闭包实例（旧 label 子串误标 + 去重 key 不含 simd，**军规 23 再犯**）；`scrInstr=0` ⇒ 无 scratch 流量、纯 IGC 预留、无代价。
**军规候补 28**：`SYCL_ESIMD_KERNEL` ⊥ `reqd_sub_group_size` ⇒ **ESIMD 核没有宽度属性刀**，要动宽度只能动显式 SIMD 契约（几何铲）。
**军规候补 29**：JIT 台账里**一个核有两个实例**（`RoundedRangeKernel` 包装形 + 裸闭包形），**任何按名字去重的仪器必须把 simd 计入 key**，否则只报半个实例（本铲两次踩）。
**下一铲序（代理建议，我已采纳）**：(1) **scratch/private 追因铲**（`pack_a_fused_b1` 176-211 条 = 就在 1a/折叠的活路径上）→ (2) WB 驻留刀（45,056→≤32,768，上限 −3.9）→ (3) GA 融合（−2.3…−5.5）。

## 39. ★ 上游对照：`Uzbekunknown/dlss-nr-on-intel` v0.0.3.1（本地已 clone 到 `E:\DSH\refs\dlss-nr-on-intel`，走 ssh-over-443，github.com 的 HTTPS 在这台机上被 DNS 污染）
**它就是我们的起点**（`b1-blueprint.md:300-301`：uzbekunknown 移植 = 本地存档 `src/dlss5nr-b580` ⇒ 优化到 ~59ms ⇒ 判定不适合 A770 ⇒ 推翻重写 = 现在的大宽数据核心）。
**而现在他们把我们当前列 prior art**：`notes/HANDOFF.md:401` "Prior art, found 11-01: **OUCO86/dlss-nr-on-a770** (Apache-2.0) is this code running NR on an A770"；`:184/:316` "An Arc A-series path with **8x8 matrix tiles, from OUCO86's A770 port**: **begun on 11-01 and paused**"、"the 8x8 builds are byte-identical to OUCO86's A770 [builds]"。

### ① "720p 40 帧"（issue #25）的原文与三个限定（`HANDOFF.md:259-300`）
> "#25, Nuclear Option through DXVK at **720p and 0.4**, **40 fps with NR's picture**, and **two Vulkan games where NR did nothing**."
- **720p + render scale 0.4 ⇒ 网络跑在 512×288 = 0.147 Mpx ⇒ 比我们 960×544（0.522 Mpx）少 3.5 倍像素**；
- 同一节里他们自己写 "**Which network it measured is unknown**"，并记录了一个真 bug：speed test 自 346d300 起不标网络，daemon 行是 "**network preset B (dlssnr-b-logical.safetensors), 31 blocks**" ⇒ **他们的发行版带两个网络：A=71 块、B=31 块，工具默认跑 B**；
- 同一份报告里还有"两个 Vulkan 游戏 NR 根本没生效"。
⇒ **"40fps@720p" 不是"71 层在 A770 上比我们快"**；它 = **0.4 尺度（3.5x 少像素）+ 网络身份不明（默认是 31 块 preset B）**。

### ② 他们唯一的 A770 满尺度数字 vs 我们归一化
> "the one speed test (#23) against phase72's Windows table: **32 ms at 640x360 and 0.4** ... **229 at 1920x1080 and 1.0** against [Arc 140V] **381-404**. **The A770 does a megapixel in half the time and loses at the small fields games run at: a fixed ~21 ms a frame**, which only a per-pass profile on such a card can place."
- 我们（71 块、已含 1a）：**63.5 ms @0.522 Mpx ⇒ 归一到 1920×1080（2.074 Mpx）= 252 ms**；他们 A770 = **229 ms**（网络未标）⇒ **同像素下差 ~10%**，不是数量级。
- 他们自认 **A770 有 ~21ms/帧的固定开销放不到位置上** ⇒ **与我们 §35 三次独立同判"帧是 latency/staging-bound"完全同一件事**。
- 他们的 dispatch 数：**1804 → 1664/帧 @720p**（phase32）——**比我们的 691 多**；720p 整帧 490-520ms（Arc 140V）。

### ③ 他们实测的 A 卡硬件账（可交叉验证我们的）
- A 系只有 **f16 8x8x16 与 int8 8x8x32**；subgroups 8-32；**48 KB shared memory**（他们 Vulkan 口径；我们 Level-Zero 实测 `local_mem_size=65,536`——**两条口径要调和，若将来走 Vulkan 会改 S6-1b 的帽**）；
- "**runs NR's 8x16x16 at subgroup 32 exactly — NR computes right there, slowly**"；矩阵微基准 8x8x16 = **57-60 TFLOP/s @sg8/16，36-39 @sg32** ⇒ "**subgroup 32 costs these cards ~40%**"（**独立佐证我们 §38：宽度是逐核的，不是全局的**）；
- 他们的 staged GEMM 在**真实形状**上只有 **5.5-15 TFLOP/s**（B580）/ 3.5-3.8（140V）；消融：**514ms 全帧 = 221 GEMM + 300 其它功** ⇒ **他们的时间也大头在非 GEMM 功**——与我们 §37（WB 矩阵腿已在 92% 屋顶）同构。

### ④ 他们已关闭的刀清单（省我们重复证明）
`register tiling, operand staging, integer weights, accumulator format, OpenCL, shared-memory bank padding, 256-register mode (~6%, 未采纳), E4M3 weights (~0.14 ms/帧), transposed static weights (更差：598.8 vs 521.8), tile 16x32 最优（32x32/32x16/16x64/8x32 都差）, small-M kernel（未试）`
⇒ **与我们"关门账"高度重叠**（bank padding、宽寄存器、整数权重、转置/布局、E4M3 小肉）；**唯一他们没试的是 small-M，而那是我们军规 1 明令禁止的**。

### ⑤ ★ 两条能直接搬进我们当前铲的方法（不是数字）
1. **`ScratchArena` 角色别名表**（phase32）：**按角色规划最大字节、冻结计划、只实体化用过的角色**；并列出**生命周期不相交可共块**的角色配对（projection / branch-value / input-key / query-prob / scores-context / residual），同时明确"**FFN 残差必须活到最后一次 attention 残差**"。⇒ **这正是我们 WB 驻留刀（45,056→≤32,768）与帧内存的现成检查表**（他们靠它 720p 常驻缓冲 5041→2303 MiB，−54%）。
2. **Q/K 融合**（phase32）：把"先拆 Q/K 到 f16、再读回做 cosine 归一化"融成一步，**保留原舍入点与归约顺序 ⇒ 逐位不变**，**消掉 140 个 dispatch ⇒ 帧 −3.7%**。⇒ **这就是我们 §35"消腿不省时间、消往返才省时间"的正例**，而且它给出了我们该抄的形状：**融合的对象是"拆分流 + 归一化"这种重复读，不是 gemm 本身**。
3. 反向警告（phase29，他们自己的口径）：**softmax 换 `packHalf2x16` 单核 −13.7%，但全帧只有 −1.1~−1.9%，1080p 无变化** ⇒ 他们白纸黑字写 "**The kernel gain is not a 14% frame gain**"。**这正是我们 §38 宽度刀 0 ms 的同一个教训。**

### ⑥ 资产一条（关系到你暂缓的 31 块）
**他们发行版直接带 preset B 的权重**：`dlssnr-b-logical.safetensors`（31 块）。⇒ **将来解禁 31 块时，权重不用我们自己从 dll 里抠**。

## 40. WB 驻留刀：SLM 45,056 -> 32,768、逐位 EXACT、32 对 24/32 赢 均值 -0.365 [-0.567,-0.163] => 带内（留形不吹，不单独转正）
产物：`E:\DSH\builds\wb_slm_b.dll`、账 `notes/wb-residency.md`、表 `tools/wbslm.csv`、可复跑 `tools/wb_slm_layout.py`（带反证测试）+ `tools/wb_slm_mkcsv.py`。
**① 先算后改（军规 22）**：regex 从 HEAD 读 map + `slm_init` => AQO/QPO/KTO/VPO/ATO 4,096x5 + PPO 8,192 + SCR 16,384 = **45,056，与台账逐字节对上**；逐相活跃并集峰值只有 **28,672 => 闲置 16,384 可挖**（现路只别名了一处 scrC->PPO）。别名后 = **每 SG 一段 7,168B 私有槽 + 4,096B 连续全局区给 VPO = 32,768B**（S0: accA->QPO->PROBS；S1: accB->SCORES->ATT->PROJ；S2: accC->SCORES 续->ATO->HEAD-A；S3: AQO->KTO；全局: VPO）。每笔"为什么不相交"逐条写死在脚本里。
**结构地板 = 32,768**：PH1 三块 f32 累加面 3x2048/SG + AQO 1024/SG = 7,168/SG 动不了（两相 QKV 既有形状）；VPO 必须连续（`wbv3::tile8ss` 的 B 侧步长写死 `kc*1024`，helper 被 v3 共用）=> **再省 4,096 要拆 helper 或拆累加面，那是另一把刀**。§37 的"省 12,288"正是这把刀的天花板。
**② 台账前后（key 含 simd，两实例分开；基线用全新 JIT 缓存跑出货件取得）**：`wbv4::launch_v4full` 与 `wbv4ph::launch_v4ph` 均 grf 128 / simd 1 / **slm 45,056 -> 32,768** / private=spill=scratch=0 / scratch 指令 0 => **没有拿 scratch 换 SLM**（§38 红线守住），也没上任何 `reqd_sub_group_size`（军规 28）。
**③ 三关与单价**：walk 默认侧（无 env）两个独立进程 **1301 EXACT = 249A46F3...**、**passes 691**；基线同场也 EXACT/691。16 对跑两轮：run1 12/16 赢 -0.284；run2 12/16 赢 -0.446；**合并 32 对 = 24/32 赢、均值 -0.365 ms/帧、95% CI [-0.567,-0.163]（不含 0 => 方向真实）**。
**④ 判决 = 带内**：未到 -0.5 转正线 => 留形不吹；质量代价为零（逐位 EXACT）。
**驻留 1->2 的证据（不是"应该更快了"）**：(a) 同仪器 slm_size 45,056->32,768；(b) §29 实测曲线（24,640/驻2、36,928/驻1）=> 32,768 落在**驻 2** 侧（65,536 // 32,768 = 2；口径写死 **Level-Zero local_mem_size = 65,536**，不用上游 Vulkan 48KB）；(c) 帧侧 -0.37 与 CI 咬合。
**但只兑现 §37 上限（-1.7/帧）的约 21%** => 教训：**§24/§29 的 +184% 曲线是"无 dpas 的 stub 价"**；真核矩阵腿已在 92% 屋顶 => **驻留那笔钱的真价约 -0.3...-0.45 ms/帧**。
**军规 30（本铲挖出，仪器有牙）**：别名槽合法 = **生命周期不相交 + 跨 SG 读的租户与更晚写者之间必须有 WG 级栅栏**。第一版把 ATO 别名进 S3（与 KTO 同槽）**字节账全对，但 1301 全帧 MISMATCH**（6.56M/8.36M 字节差、x/y 全域平坦）——根因 = **跨 SG 读竞态**：KTO 在 P3 被别的 SG 读，而全核只有一个 group_barrier（PH2_2->P3），P3..P6 只有 SG 级 esimd::barrier => 快 SG 在 P6 写自己的 ATO 会覆盖慢 SG 未读完的 KTO。修法 = ATO 移进 S2（全程本 SG 私有）+ 两条 static_assert 钉死。规则已写进 `tools/wb_slm_layout.py`（XSG_READ / GROUP_BARRIERS），并用 `E:\DSH\s6\t_negcheck.py` 反证：把 ATO 塞回 S3，检查器必须报竞态 => **PASS**。
上游 ScratchArena 角色配对与本铲槽表同类（projection<-attended/proj = S1；query/probability = S0；input/key<-KTO = S3），红线"残差活到最后一次残差"对应 PROJ 活到 P7。
**处置**：不单独跑三关转正；与下一把（M2/M2b + att 相）合并成一次三关落地，省一轮 39 门 + 16 对的机时。


## 41. ★★★ 正确性事件：§40 的 SLM 别名手术**引入跨进程竞态**，已回退；两个测试件从稳定基线重编交齐

**竞态定位（单变量，一步到位）**：tip `c36f4e1` 相对 `08e8b62` 在 shipped 源上**只差两个文件**（`window_block_v4.hpp` + `window_block_v4ph.hpp`，即 §40 别名手术，**无开关、始终生效**）；§33 跳块 / §34 `NR_RES_*` / §35 `NR_BG_FOLD` 三组机制**全默认 OFF** ⇒ 不可能影响默认路径。
- `ctrl_08e8b62.dll`（tip−1 无宏）walk × **4 个独立进程 ⇒ 4/4 = 金标 `249A46F3` EXACT**（帧 63.00-63.18）；
- tip 无宏件 ×2 ⇒ `CF608C6B` 与 `745662C0` **互不相同**；§40 成品 `wb_slm_b.dll` ×2 ⇒ **EXACT 与 F74AF8BC 互不相同**；
⇒ **竞态源 = §40 别名手术**。签名 = **6.56M/8.36M 字节差（78%）、x/y 全域平坦、y/x mod 8 均匀、首差在 byte 0**。

**处置**：`git checkout 08e8b62 -- <两文件>` **回退**；§40 重新归类为 **"未通过正确性门"**（−0.365 ms / 32 对的读数可能仍真，但件不可用；要回来必须先修栅栏并通过 4/4 确定性）。

**★ 军规 31（我此前的门太松，正式升级）**：**确定性门 = 最终件上 ≥4 个独立进程、数 distinct dump md5；两遍不够。**
§40 当时报的就是"两个独立进程 EXACT"，第三次就翻。**凡"带内/转正/出货"级结论，一律 4/4。**

**★ 军规 32（竞态签名可自动判）**：`diff 字节占比 ~78% + x/y 全域平坦 + mod 8 均匀` = **跨 SG / 缺栅栏竞态**；数值改动通常是稀疏或局部模式。写进判官脚本当场标记。

**出货件钉死**：`out\libxmx.dll = E2D5E574…C8D`（1a，游戏正在用）本轮 **4/4 进程 1301 EXACT** ⇒ **现在游戏里没有这条闪烁**。

**两个测试件**（都从 `08e8b62` + 中性宏补丁编；宏补丁不带宏时实测 1301 EXACT）：

| 件 | dll md5 | 编译期开关（游戏不设 env） | 帧 ms（4 独立进程） | 16 对 vs 出货件 | corr_min | dB@range | dB@[0,1] | 多进程 |
|---|---|---|---|---|---|---|---|---|
| `test_1270e4m3.dll` | `D37FFD5D…` | 只 1270 走 e4m3+行 pow2（52 站点/帧、86.60M 元素）；passes 743 | **122-125（仪器价，慢 ~56ms）** | **+56.619** CI[+55.6,+57.6] 0/16 | **0.9828**（R .983 G .992 B .990 **A .614**，luma .991） | 32.34 | 9.54 | **4/4 全同** |
| `test_skip_c512.dll` | `2D878C07…` | 跳 C512 全 14 条链；passes 691 不变 | **60.13-60.61** | **−5.133 ms**，CI[−5.644,−4.621]，**B 赢 16/16** | **0.9652**（R .965 G .991 B .988 **A .773**） | 30.80 | 8.01 | **4/4 全同** |

⇒ **T2 = 本轮最大的真实帧收益（−5.13 ms、16/16、确定性 4/4）**；它的画质属"corr 高但 dB 难看"那一类，**必须由眼睛判**。
⇒ **T1 只用于看画面**（慢 56ms 是 QDQ 探针仪器价，§34(5)①）；它的 **A 通道 corr 只有 0.614** ⇒ **半透明/发光边缘要专门看**。

**仪器 bug（已修在用副本，仓内同步）**：`playtest.ps1` 缺 UTF-8 BOM ⇒ PS 5.1 按 GBK 解码中文注释、字符串终止符被打断 ⇒ **ParserError，`-List/-Use/-Restore` 全废**。
**军规 16 再犯**：**任何工具改写 .ps1 之后必须重验 BOM。**



## 42. ★★ 用户实机裁决（11:0x）：**T2 跳 C512 = 接受**；**T1 1270-e4m3 = 否决（"彩色大方块"）** ⇒ 判官被抓到一次真实漏判

**裁决原文**：
- `-Use test_skip_c512.dll` ⇒ "**画面正常没问题接受**"
- `-Use test_1270e4m3.dll` ⇒ "**画面异常都是彩色大方块不接受**"

### ① T2 转正（本轮最大单刀）
`test_skip_c512.dll`（md5 `2D878C07…`，从稳定基线 `08e8b62` + 中性宏补丁编）：**跳 C512 全 14 条链**、`passes` 仍 691、**4/4 进程 dump md5 全同**、**16 对 −5.133 ms/帧 CI[−5.644,−4.621] B 赢 16/16**、corr_min 0.9652 / 30.80 dB@range。
⇒ **按军规 5/6 出货线：帧 A/B 过线 + 确定性 4/4 + 用户眼睛验收通过 ⇒ 转正**。
**判官换轨（必须写死）**：从此刻起
 - **金标分两条**：`dumps\bk.1301.bin` = **pre-skip（1a）参考**，只用于算 corr/dB（画质对照）；
   **新出货基线 = skip 件自己的 4/4 全同 dump**（`bk.1301.skip.bin`，待正式冻结），walk 的 `1301 EXACT` 门改为对**新基线**比，且**必须 4/4（军规 31）**；
 - **"跳块类改动"的画质判据 = corr + per-tile 指标 + 用户实机**三件齐全，**不再要求逐位 EXACT**（逐位在语义上已不可能：整条链被移除）。

### ② ★ 判官被抓到一次真实漏判（这条比 −5.13ms 更要紧）
T1 的机器读数：**corr_min 0.9828**（R .983 G .992 B .990，luma .991）、**32.34 dB@range**、mean|d|/σ **0.125**、p99.9|d|/σ **0.613** ⇒ 全部落在"可接受/实机验收带"。
**但实机是"彩色大方块"= 结构性灾难。**
⇒ **全局标量（corr / dB / 均值分位数）看不见局部结构灾难**：1270 是**按窗/按块的 skip 面**，坏的是**成片区域**，全域统计被其余 99% 正确区域稀释掉了。
**唯一的预警信号其实出现了**：**A 通道 corr 只有 0.614**（T2 的 A 是 0.773，也低——但 T2 是整档移除，A 通道语义不同）。
⇒ **军规 33（判官升级，已入 B2）**：任何改数值/改面的铲，画质表必须**同时**给
 - **per-tile 最差 dB**（按 64×64 或 128×128 分块，报 **min / p1 / p5**，不是只报 p99.9 与均值）；
 - **平坦区异常检测**（大片低梯度区域里的 |d| 突增 = 色块/台阶的前兆）；
 - **逐通道 corr，且 A/alpha 通道单独成判**（A 通道 corr < 0.9 ⇒ 直接进"必须实机"名单，不许因为 RGB corr 高就放行）；
 - 最后仍是**用户实机裁决**为准。
⇒ **T1 这条路线（1270 窗残差/skip 面降字节）就此判死**：不是 dB 不够，是**局部结构崩**；与 §34 的"1270 抵抗、1267 免费"一致，**1267-e4m3（逐位 EXACT、0 字节改动）不在死刑名单上**，但它只值流量的一条腿。

### ③ 现场与后续（**用户已 `-Restore`，加载位仍是 1a 出货件**）
- 用户实机流程：`-Use test_skip_c512.dll`（接受）→ `-Restore` → `-Use test_1270e4m3.dll`（否决）→ `-Restore`。
  **当前 `out\libxmx.dll` = `E2D5E574…`（1a 出货件，未改）**；两个测试件仍在 `out\test_*.dll`，回退点 `out\libxmx.bak-shipped.dll` 与 `out\libxmx.before-E2D5E5740035.keep`。
- **T2 已获用户画质批准 ⇒ 待正式转正**（下一把铲做）：冻结新基线 dump（`bk.1301.skip.bin`，4/4 全同）+ 39 门 + **8/8 确定性（军规 31）** + 把 walk/ab 的判据改成对**新基线**比 + 画质判据加 **per-tile 最差 dB / 平坦区异常 / A 通道单判（军规 33）** + 然后部署到加载位（附一键回退）。
- 正在跑的 `栅栏审计铲`（`a46b1bec`）不受影响：它审的是**源码里的跨 SG 租户与栅栏**；出货位此刻未变，所以它的 8/8 确定性读数仍对 1a 件有效。



## 44. ★★ 更正 §43：`esimd::barrier()` **在机器级就是 CTA 栅栏** ⇒ 1a 的 "RACE" 重新定性为「源码级可疑 / 机器级同一栅栏」；栅栏硬化 = **免费但什么都不修**
证据（`4de513f8` 的 DM_BAR 实验，件在 `E:\DSH\builds\`）：
- `dm_bar.dll`(ECA5A5EB) vs 出货件 `E2D5E574`：**ffn2 两段 `.text` 反汇编 md5 完全相同**（`21DDE963…` / `05303229…`），**`send.gtwy … signal barrier` 都是 8 条** ⇒ 把 12 处 `esimd::barrier()` 换成 `sycl::group_barrier(it.get_group())` **没有产生任何机器码差异**；
- **反证有牙**：`dm_probe.dll`（DM_BAR=1 再多插 1 条 `esimd::barrier`）⇒ 同一核变 **9 条**、asm 尺寸变 ⇒ **宏确实进了设备编译，不是没生效**；
- 工具链原文同向：`esimd/memory.hpp:12045` ⇒ `esimd::barrier(){ __esimd_fence(global_coherent_fence|local_barrier); __esimd_barrier(); }`；`esimd/detail/memory_intrin.hpp:651` ⇒ "esimd_barrier, **generic group barrier**"；另有子组级 `experimental/esimd/memory.hpp:42 split_barrier`（**那才是 SG 级**）。
**读数**：dm_bar 侧 **4/4 独立进程 1301 = 金标 EXACT**、passes 691；**16 对 A=出货 vs B=dm_bar：均值 −0.056 ms/帧、CI[−0.299,+0.187]、9/16** ⇒ **成本带内 ≈ 0**；台账两侧**逐列相同**（`grf 128 / simd 1 / slm 31,744 / spill=private=scratch=0 / scratch 指令 0`）。
**仪器修正**：`barrier_audit.py` 升级——`S6_BAR()` 按 DM_BAR 两侧分类、**跳过预处理行防假 OK**、1a landmark 改**按锚点正则**定位（硬化补丁在 hpp 顶部加宏块 ⇒ 行号整体 +18，硬编码必错位）、`BARRIER_SRC` 可指别树；反证仍 PASS。verdict 变化：BEFORE `ffn2::fused` = RACE(WG0/SG12)；AFTER `[DM_BAR=0]` 仍 RACE、`[DM_BAR=1]` = OK(WG12/SG0)，**其余 9 核一字未变**。
⇒ **推论（要重新解释 §40/§41 的竞态）**：既然每道相位边界本来就有 CTA 栅栏，§40 的红就**不是"缺栅栏"**，而是**别名让"读"与"更晚的写"落在同一个 CTA 栅栏区间内仍然重叠**（同一相内没有边界，或 REUSE 的写在读侧同一相）。
⇒ **给仪器加机器级判据（待做）**：REUSE 条目要再分 **「跨栅栏重叠」= 真竞态** 与 **「同相内重叠」= 需查是否同 SG**；verdict 必须分 **source-level / machine-level 两栏**。

**★ 军规 34（入 B2）**：**任何"源码级"审计/优化结论，必须在机器级复核才算数**——反汇编 `.text` md5、关键指令计数（这里是 `signal barrier` 条数）、台账逐列（含 simd/module_id 去重）。
  本案形态 = **"源码看着危险、机器上不存在"**；同一台仪器的 verdict 从 RACE 变 OK 只因为改了**写法**而不是改了**语义** ⇒ 若不比 md5，我们就会把一次空操作记成 −0 成本的安全改进。
  附带再犯记录：旧 `spillcheck` 去重 key `(lab,grf,slm)` 会把 dm_bar/dm_ctrl/出货件**糊成一行** ⇒ 已改成含 **simd + module_id**（军规 29 的同族）。

**处置**：**转正件走 A-only**（只带跳 C512，不带栅栏宏）——B 免费但零收益，且给 shipped 源码添噪声；**B 的机器级证据全部留账**。



## 45. ★★★ T2 转正并部署：跳 C512 全 14 链 = **-4.794 ms/帧（16/16）**，加载位现在是 ABB969FE；同时抓到两处判官缺口
**部署链**：`out\libxmx.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0**（3,813,376B）；旧 1a 件三处留底：`out\libxmx.bak-shipped.dll`、`out\libxmx.before-E2D5E5740035.keep`、`out\libxmx.keep-E2D5E5740035.pre-promote`。**一键回退**：`Copy-Item E:\DSH\out\libxmx.keep-E2D5E5740035.pre-promote E:\DSH\out\libxmx.dll -Force`（回退后 walk 要显式 `-Gold E:\DSH\dumps\bk.1301.pre-skip-1a.bin`）。`oneapi\libxmx_sycl.dll` 同步为 ABB969FE（旧件留 `.E2D5E574.keep`）。`out\DEPLOY.md5.txt` 已追加完整判据摘要。
**A-only**（按改令：栅栏宏不入件，§44 已证它是机器级空操作）。基线 = `08e8b62`（§41 证 4/4 稳定），**不含 §40 别名手术**。

**判据（全过）**
- **8/8 独立进程 distinct md5 = 1 = `DD49827DD33A7EF07C2C17892F18970D`**，且与 §33 的 `skip_C512a/b`、§41 的 `t2_skipc512_a..d` **同一 md5** ⇒ env 开关 / 编译期默认 / 转正件**三条路径逐位一致**。
- **金标换代**：旧 `bk.1301.bin`(249A46F3) 改名保留 = `bk.1301.pre-skip-1a.bin`（画质对照）；新金标 `bk.1301.skip.bin` + 软拷贝 `bk.1301.bin`；`dumps\GOLDEN.md` 写清两代表格、照抄可用的命令、以及"旧件必须显式 `-Gold …pre-skip-1a.bin` 否则假红"。
- **16 对（正式）**：A=E2D5E574 vs B=cand_skip ⇒ **mean −4.794、median −4.750、sd 0.529、CI95[−5.074,−4.514]、B 赢 16/16**。与 §41 的 −5.133 同向同量级（少赚 0.34ms，远小于失败线 1.5ms）。
- **转正件与用户实机验收过的 `test_skip_c512.dll` 逐字节只差 6B**（0x110、0x166724 各 3B，时间戳类字段，`s6/cmp_dll.py`）⇒ **机器上就是那只被眼睛验收过的件**，所以第二次 16 对（隔离栅栏净价）取消。
- **39 门 = 39 GREEN / 0 RED，一字未改门**。

**★ 缺口一（必须补）：39 门里没有任何一扇在测跳块路径。** 只有 `gate_graph`(28 打印) 与 `gate_coexist`(14 打印) 出现 `[skip-chains]`，而那里小图只有 1 条链、请求的 18..32 全部 `OUT OF RANGE … ignored` ⇒ `chains_skipped=0 refused=14 closures_noop=0 passes=1 (unchanged)`；其余 37 门连 `skip_chains_apply` 都没打印。
⇒ **"跳块会让整链门红"从未发生，因为门里根本没有跳块类**。**下一铲补第 40 门**：整图 52 链 + skip 后对新金标逐位（现在它只活在 walk 里）。

**★ 缺口二（更要紧）：新做的 per-tile 画质表抓不住 T1 型灾难。**
`tools/db_meter.py` 已加：per-tile 64×64（min/p1/p5/p50 + <40/<35/<30/<25/<20 块数）、平坦区异常、成片色偏（每块逐通道均值偏移/sigma）、**结构保持率**（块内梯度 test/golden）、**A 通道单判**（corr_A<0.90 ⇒ MUST-SCREEN）；并修了 `--cross + --csv` 的 `KeyError:'md5'` bug；自测仍过（bk vs bk = inf；sigma=0.5571 合成噪声 27.88/5.08 vs 期望 27.89/5.09）。
新件 vs 旧金标：corr R .965 G .991 B .988 **A .773**、dB@range 30.80；135 块 dB **min 28.85 / p1 28.41 / p5 30.09 / p50 29.36**；**<20dB 块 = 0**；平坦区无异常（平坦/陡峭 = 0.87）；色偏 max 0.375 sigma（>1 sigma 块 0）；结构保持率 min 0.906（<0.6 块 0）；**CROSS（两独立进程）= IDENTICAL/inf**。
**但牙齿对照（`tools/judge_teeth.csv`）：同一套指标跑"被否决的 T1"与"被接受的 T2"** ⇒ T1 dB min **34.80**、色偏 0.316 sigma、塌陷 0 块；T2 dB min **28.85**、色偏 0.375 sigma、塌陷 0 块 ⇒ **per-tile dB / 色偏 / 塌陷三样对 T1、T2 没有分离力，甚至方向相反**；唯一与眼睛同序的仍是 **corr_A（T1 0.614 < T2 0.773）**。
⇒ **结论：军规 33 的 (a)(b) 两栏目前不是 T1 型灾难的探测器**；要抓它需要一把按**"块内常量化 / 台阶化"**建模的探针（T1 的"彩色大方块"= 每块退化成常数），**先拿 T1 的 dump 标定再上**。这条排在任何新的画质改动铲之前。

**栅栏审计收尾（§44 的机器级判据落地）**：`tools/barrier_audit.py` 现在出 **`verdict_source` / `verdict_machine` 两栏**，未做 ISA 对照的核一律 `not-measured`；机器级判据草案写死：REUSE/HANDOFF 再分「**跨已发射栅栏区间重叠** = 真竞态候选」与「**同一区间内重叠** = 只算源码级」。BEFORE/AFTER 两份 csv 已入库（`tools/barrier_audit_before.csv` / `_after.csv`）：`ffn2::fused` source RACE(WG0/SG12) -> DM_BAR=1 后 source OK(WG12/SG0)，其余 9 核一字未变；反证仍 PASS。


## 46. ★★★ 画质判官补上了牙：**块退化探针（`tools/block_collapse.py`）能分开 T1 与 T2**；并补上**第 40 门（跳块整图回归）= 40 GREEN / 0 RED**
**① 关键机理（为什么 §45 的 dB/色偏/塌陷三栏失效）**：**T1 与 T2 的 A 通道误差幅度几乎相同（rms 7.17 vs 6.92）**——分开它们的不是幅度，是**空间成片度**。A 是合成权重面 ⇒ **块状 A 误差 = 屏幕成片错色 = 用户看到的"彩色大方块"**。这与 §45"唯一与眼睛同序的是 corr_A"完全咬合。
**② 三条题面统计里两条是死的（如实入库，没调阈值凑）**：
- **C2 块内有效等级数**：T1 0.9651 vs T2 0.9590 levels/像素 ⇒ **NO-SEPARATION**——**T1 没有任何块退化成常数**（方块是"错色"不是"去细节"）；
- **C3 块边界台阶能量**（64/128 网格）：T1 1.005/1.017 vs T2 0.979/1.020、金标自己 1.02-1.04 ⇒ **NO-SEPARATION**；原因已证：**1270 面降 e4m3 的块网格经重采样后不落在 1301 面的 64/128 网格上**（p=8..272 全周期扫描也无峰）；
- **C1 块内方差坍缩比**：只有 **A 通道 @64/@128 有牙**（T1 4.17%/10.71% vs T2 2.50%/3.57%；阈 ≥3.0 / ≥6.0）；**RGB 两族都 0.00% ⇒ 无分离力**（T1 塌的是 A 不是 RGB）。
**③ 真正有牙的是新加的两族**：
- **C4 误差场分段常数度**（A）：`blockiness@64 1.292 vs 0.770`、`@128 1.508 vs 0.787`（阈 ≥1.20）、`segconst@16 0.181 vs 0.377`（阈 ≤0.25）、`maxblockmad 14.34 vs 10.18`；
- **C5 误差场空间自相关**（A）：`rho64 0.550 vs 0.309`（阈 ≥0.45）、`rho128 0.373 vs 0.184`（≥0.28）、`coh_len 64 vs 1`（≥48）、`L_int 79.4 vs 51.9`（≥65）；**纯 x 方向 rho 到 lag256 仍 0.565 vs 0.212**（y 向 128 后掉 ⇒ **台阶是横向长条**）。
**④ 判决规则（写死进仪器）**：三族 **F1 塌陷 / F2 相关 / F3 台阶**；**≥2 族 = BLOCK-REJECT；1 族 = BLOCK-WARN（必须实机）；0 族 = block-ok**；任一通道 C1<0.5 占比 ≥25% ⇒ **无条件 REJECT**；幅度地板 `rms(D)/rms(golden) < 0.02` 时该通道 F2/F3 不适用；**眼睛一票否决权不变**。
**⑤ 标定证据（仪器有牙）**：T1 **3/3 族红**；T2 **0 族红**；旧金标自比 / 新金标自比 / 同件两进程互比 **全 EXACT、0 假阳**；**合成对照双向正确**：A 通道 64 块均值化 ⇒ REJECT(100%)；**A iid 噪声 rms=7.17（与 T1 同幅度）⇒ block-ok**（这就是幅度类指标失效的对照）；128 块间随机台阶 ⇒ REJECT；RGB 块均值化 ⇒ REJECT；RGB iid rms=0.40 ⇒ block-ok。
**⑥ 人群扩展（非眼睛样本）**：`bgS_e4_wres`(=T1 同刀) 与 `bgN_e4m3w` 均 **REJECT 3/3**；**`bgS_s8_wres`（1270 面 int8 残差）大面积抹平 REJECT（R 通道 50.8% 块 var 比 <0.5）⇒ int8 同类灾难这台仪器已经抓过一次**；`skip_C512alla` block-ok；`skip_big28a / skip_mix16a / skip_L512x1a` 各 1 族 ⇒ **WARN（必须实机）不是 REJECT**。
**跨轴稳健性**：T1 对**新金标**仍 BLOCK-REJECT(2/3 族)，但 **F1 塌陷族退化成 0.83%** ⇒ **换代轴上必须靠 F2/F3**（已写进协议）。
**⑦ 第 40 门**：`src/bench/sycl/gate_skip_graph.py`（整图 52 链 / 691 闭包 + 跳 C512 全 14 链，走 `nr_replay_now`；被测件 = 转正件 ABB969FE；进程 1/2 用 `out\libxmx.dll`，进程 3 用 `oneapi\libxmx_sycl.dll` 交叉核对；**门不 stage、不改写任何 dll/金标**）。`run_gates.sh` 只加一条（其余 39 条一字未改，仓内镜像 `tools/dsh_run_gates.sh` 已同步，`fc` 证无差异）。
读数：**40 GREEN / 0 RED**（`logs\run_gates_40.txt`）；单门 26 ok / 0 FAIL；原文 `[skip-chains] chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`、**`OUT OF RANGE ignored=0`（正是 gate_graph/gate_coexist 那种"假跳块"，本门当 FAIL）**；1301 三进程全 = 新金标 `DD49827D…`。
**⑧ 仪器缺口（明说）**：探针目前只吃 **960×544 的 1301 面**；要把 C3 救回来，得在**改动真正发生的那张面**（1270/1267/1274/1275）上加面尺寸参数测网格对齐——**这是下一件仪器活，不是任何铲的前提**。


## 47. WB int8 铲·第 1 步交回：**"帧 −2.5" 是纸上的；实测净价四腿全换 = 串行 −2.17 / 帧 −0.93（兑现 37%），QKV 单腿只有帧 −0.41…−0.48 ⇒ 判不施工**
净价表（十发外推；`r_pub` = 同引擎同形状 `int8(折叠 requant 出口) / f16(折叠 publish 出口)`；**A 量化 = `pack_a_fused_gather − gather_pack_a16`（折叠形态，不是独立趟）**）：
| 腿 | N×K | r_pub | M1 乐观 | **M2 保守（只换引擎+出口这一对）** | 十发 f16 | M2 后 |
|---|---|---|---|---|---|---|
| **QKV(靶)** | 96×32 | 0.745 | −19.0% | **−16.3%** | 5.872 | 4.912 |
| scores | 64×32 | 0.738 | −16.1% | −15.4% | 3.813 | 3.224 |
| attnV | 32×64 | 0.785 | −18.8% | **−15.9%** | 2.742 | 2.306 |
| proj | 32×32 | 0.756 | −0.2% | −11.6% | 1.576 | 1.393 |
| **合计** | | | −16.1% | **−15.5%** | **14.003** | **11.835** |
**肉的去向**：dpas 纸面肉 **−5.06 ms**（§37 的 −5.86 兑现 87%，这部分是真的）→ **A 面量化吃回 +0.87** → **requant 净增量只吃回 +0.30** ⇒ **净 −2.17 ms 串行 = 帧 −0.93**。
★ **主犯不是 requant，是"这十发里只有 68% 是 dpas"**（四腿 3.4410 vs 探针纯 dpas 2.3444；另 32% 是 gather / SLM 面 / e4m3 snap / cosine_recip，**换 dtype 砍不到**）。
**三条新实测事实**：
1. **int8/f16 实测只有 1.35-1.67x，没有 2.0x**（浅 K）；**attnV 只有 1.35x**；屋顶表缺 N32/N96 的 int8 行，**拿 N64 锚内插会错 34%** ⇒ **军规 35a：int8 屋顶不得按 f16 的 N 比例内插，N<64 必须实测**（40 行新点 `tools/wbint8_roof_ext.csv`）。
2. **宽 M 红利屋顶表没记**：同 N/K 从 M=130560→522240，f16 TOPS **x1.23**（2.74→3.38）⇒ §5 那句"QKV 占 f16 屋顶 81%"在 POOL/HEAD 两发上其实只有 **64%**。
3. **仓内没有 wbv4 真实几何（A 供在 SLM、N=96）的 int8 引擎孪生**：N=96/N=32 只能走 BN32 的 `gemm32_b/gemm32_b_pub`，而 **BN32 的 raw→pub 附加率 1.53x vs BN64 的 1.27x** ⇒ 上表 −16% 是**现有引擎的最好情况，不是新几何的价**。补 N 到 128 走 BN64 只便宜 4-9%/列，代价是多写 33% 出口列，不划算。
**GO/NO-GO 的诚实性**：按写死线（≥15%）**勉强 GO（QKV 保守 16.3%）**，但**过线只有 1.3 个点、小于仪器噪声**：第一轮单测给的是 **−10.1%（NO-GO）**，根因 = `gemm32_b_pub` / `M=130560` 的 `gemm_b_pub_f16` **跨进程单轮散布 8-21%**，取 6 次中位才翻到线上 ⇒ **军规 35b：判定线在 15% 量级时，单轮探针比值不可用于裁决，必须 ≥3（本次用 6）个独立进程取中位**。
**判决 = 不施工**（我的裁决）：QKV 一腿到手 **帧 −0.41…−0.48**，**低于 §40 驻留刀已拿到的 −0.365（逐位 EXACT）**，代价却是**数值契约改动**——而同类灾难判例就在旁边（**`bgS_s8_wres` = 1270 面 int8 残差，§46⑥ BLOCK-REJECT，R 通道 50.8% 块 var 比 <0.5**）。**若将来要试点，先补一条 "BN32-int8 + SLM-A" 的真几何再重算净价**，否则是在给没量过的形状下注。
**台账（军规 34）**：所有计价腿 `grf128 / simd1 / scratch 0 / spill 0 / scratch 指令 0`（`s8v8::gemm_b` 18432B、`gemm32_b` 15360B、`gemm32_b_pub` 10240B SLM）；`private_size` 那 8B 是 `private_base_stateless` 指针槽不是 spill。红点仍在：**`pack_a_fused_b1` = scratch 1472B / 211 条 scratch 指令**（§38 那个）——且第一版 ledger 脚本因 label 子串顺序把它误标成 `pack_a_fused`，差点把"量价用的量化腿带 scratch"写进结论 ⇒ **已改最长优先匹配**（军规 23 第四次应验）。
**两条仪器教训（入册）**：① **进程名闸**：游戏进程是 **`LOP-Win64-Shipping.exe`**，不是 `LOP`/`GameInput*`——第一版脚本把 `GameInput*` 系统服务当游戏报了假 BUSY；② **删 exe 后继续跑"重复"** ⇒ `& ".\exe"` 的失败被 `2>&1 | Out-Null` 吞掉，那 6 次根本没跑（只写空日志），发现后重编补跑 ⇒ **跑批前后必须核对"文件存在 + 日志非空"**。


### 47b. ⚠ 收紧 §47 的判定数（10 次独立进程 + 运行内配对的不确定度）——**方向不变，判决更站得住**
`QKV 一腿十发净Δ = 中位 -15.5%，5-95 分位 [-16.7%, -14.4%]（min -16.9 / max -13.6）；配对样本过 15% 线的比例 = 90%`
终表（10 次中位，M1 乐观 / M2 保守）：QKV **-18.3% / -15.6%**（5.872 → 4.795 / 4.955）；scores -16.5% / -15.7%；attnV -18.1% / -14.9%；proj **+0.4% / -10.3%**；**四腿合计 14.003 → 11.808 / 11.916 = -15.7% / -14.9% = 串行 -2.20 / -2.09 ms = 帧 -0.94 / -0.90 ms**。epi4 对照（3 次）：QKV -16.0% / -12.7%，四腿 -13.8% / -12.5%。
**对 §47 已入库数值的两处更正**：
(1) "QKV 保守 16.3%" → **15.5-15.6%，且 15% 判定线落在置信带内**（不是"过线 1.3 个点"，而是**中心值就踩在线上、带跨线**）；
(2) "四腿 -2.17 串行 / -0.93 帧" → **-2.09…-2.20 串行 / -0.90…-0.94 帧**。
**军规 35c（判定规则升级）**：**判定线附近的铲，中心值踩线 = 不施工**；必须报 **中位 + 5-95 分位 + 过线样本比例** 三件套，**只报中位等于没有判据**（本案 90% 样本过线，但中心值 15.5% 与线 15% 不可分）。
**再补一条比价格更硬的门槛**：**仓内没有 wbv4 真实几何（A 供在 SLM、N=96）的 int8 引擎孪生** —— N=96/N=32 只能走 BN32 `gemm32_b/gemm32_b_pub`，其 **raw→pub 附加率 1.53x**（BN64 只 1.27x）；把 N 补到 128 走 BN64 每列只便宜 4-9%，但要**多写 33% 出口列**（把 int8 想省的访存吐回去）⇒ **表里 -15.5% 是现有引擎的最好情况，不是新几何的价**。
⇒ **判决不变：不施工。** 到手只有 **帧 -0.39…-0.46**（QKV 单腿），低于 §40 驻留刀已拿到的 -0.365（逐位 EXACT），代价却是数值契约改动 + 旁边就是 `bgS_s8_wres` 的 BLOCK-REJECT 判例。


### 47c. WB int8 铲最终交回：**逐项分解 + 一条判死（WB 里"浅 K 转深 K"不可达）+ 三条新军规**
**逐项分解（十发 ms）**：dpas 肉 **-4.105** -> A 面量化 **+1.221** -> requant 净增量 **+0.797** => **净 -2.087 ms 串行 = -0.90 ms/帧 = §37 纸面 -5.86 的 36% 兑现**。
**谁把 1.5x 吃回去（实测排序，与猜测不同）**：① **结构：这十发矩阵腿里 33% 是非 dpas 的 elementwise**（gather / SLM 面 / e4m3 snap / cosine_recip；探针纯 dpas 2.344 vs dll 整相 3.441）——**换 dtype 砍不到**；② **A 面量化 +1.22**（K=32 面 +0.0785 POOL / +0.0277 plain；**K=64 面免费**）——**它把 proj 腿整个吃平**（proj M1 +0.4%）；③ requant +0.80（不是主犯）。
**三笔代价的计价口径**：(a) 量化按**折叠形态**计价（`pack_a_fused_gather` vs `gather_pack_a16`；独立趟 +0.25 ms 是仪器价，已排除）；(b) 权重预整定 = init 一次、**不进帧**（device pack f16 0.0198 vs int8 0.0196 ms 同价；字节减半 16,384->8,192B/十发）；(c) requant 折进 epilogue（`gemm_b_pub`/`gemm32_b_pub`）。
★ **判死：`先把 K 深度做起来` 在 window_block 里不可达**——K = C = 32、tokens = 64，**被模型钉死**，屋顶表的 K32->K384 x4.7-6.7 对这些腿**不适用**。**K 倍率来自算术强度（每次载入 B 复用 K 次），循环合并改不了复用因子。**
**屋顶表两条缺口**：int8/f16 实测只有 **1.35-1.67x**（没有 2.0x）；**N=32 的 int8 屋顶比 N=64 锚低 34%**（表里没有 N32/N96 行 => 内插必错）；**宽 M 红利 x1.23**（M=130560->522240）=> §5 的"QKV 占 f16 屋顶 81%"在 POOL/HEAD 上其实是 **64%**。40 行新点 = `tools/wbint8_roof_ext.csv`。
**新军规 36**：**dtype 铲的净价上限 = 该相里 dpas 的份额**（本案 67% => 1.5x 的屋顶乘 0.67 就掉到 ~1.33x，再扣量化腿就没了）。
**新军规 37**：**屋顶表必须把 M 记成轴**（宽 M 红利 x1.23 未记）。
**新军规 38**：**细腿上探针的"全局 publish"不是 shipped SLM 出口的代理**（proj 探针 f16_pub 0.4403 > dll 整相 0.3872 => 探针比被测量还慢，比值不可用）。
**军规 35 补强**：15% 量级的判定必须 **>=10 次独立进程 + 运行内配对 + 交回 5-95 分位**——本铲翻三次车：单轮 -10.1%（NO-GO）-> 6 次 -16.3%（GO）-> 10 次配对 -15.5% [-16.7,-14.4]（踩线）。
**两条现场仪器教训（已入册）**：游戏进程名是 **`LOP-Win64-Shipping.exe`**（不是 `LOP`/`GameInput*`，那是系统服务，会报假 BUSY）；**删 exe 后继续跑批** => `& ".\exe"` 的失败被 `2>&1 | Out-Null` 静默吞掉，那 6 次根本没跑只写空日志 => **跑批前后必须核对"文件存在 + 日志计数非零"**。
**红点仍在**：`packdev::pack_a_fused_b1` = **scratch 1472B / 211 条 scratch 指令**（§38 那个，本铲未用它计价）。

## 48. ★ 用户裁定：**要搬就连核带接口一整套搬**（port-D 撤回，改 port-E）+ **军规 39：移植判决必须先定义"完整"的可检查清单**
**用户的论证（接受）**：我们已做过两次半搬——① **他们的核 + 我们的接口**（M1）=> P4 从 39.6/55.2 塌到 **2.4 TOPS**（`act 8/64`）；② **我们的核 + 我们的接口**（1a）=> P2 24.4/30.2、P4 28.0、整链 0.4647/0.3787（已出货 −3.0 ms）。**若只换接口不换核，就会产出另一场"人家接口不适合咱们的核"的无用结论**——M1 那次已经是这种戏。
**他们的 39.6/55.2 本来就是"核 + 几何 + 编码 + 折叠"整套跑出来的** => **只有整套搬进来才有判决意义**；**搬全了还跑不出那个量级，只能说明没搬全**（可查清单见下），**不许下"不适合"的结论**。
**军规 39**：**任何"移植判决"必须先定义"完整移植"的可检查清单，逐项打勾；缺任何一项，结论一律标 `移植不完整`，禁止写"不适用/不适合"。** 否则"不适合"是不可证伪的甩锅（M1 就是前车之鉴：我们当时写的是"形态不迁移"，其实缺的是 `act 48/64` 的几何与布局）。
**port-E 的七项完整性清单（逐项必须打勾）**：① **核**（dpas 序列 / tile 形 / 累加器数 / 洗牌用法——他们没有 shuffle 的地方我们别加）；② **几何**（`LW=16 / SLM 21,504B / 3 WG per slice / 48 活线程 / K 链深 8-vs-2`，**照抄不许适配**）；③ **面布局**（**window-major `[window][token 0..63][3C]`**，Q/K/V 按消费者 dpas-tile 序、跨窗口 global 直读、**只有 exp 表进 LDS（他们 6,144B）**）；④ **权重编码与 scale**（**e4m3 字节面 + 行 pow2 scale + ±448 钳位 + 软件 `H()/Ffast()`**，§32 已证这套在无 fp8 卡上跑通）；⑤ **折叠**（**requant / publish / pack 全在 gemm epilogue 内** => 他们 71 块只有 35 个核、162-197 launch）；⑥ **launch 形态**（batched / 多输出列 / 一次读 B tile）；⑦ **供数路径**（**A/B 从 SLM/寄存器供，不从 DRAM 重读**；同一 op 驻留 28.0 vs global 4.67 TOPS = **6 倍**）。
**两级对拍（缺一不可）**：A 级机制正确性 = 与**他们自己的参考**逐字节对拍（`port_ffn_fused.cpp` 803 行 13 检查点 diff=0 的路子已证明可做到；**新增检查点覆盖接口**：面布局字节序、scale 粒度、e4m3 编码、epilogue 出口形态）；B 级性能判决 = 同形状同进程、**独立进程重复 >=10 次**（军规 35），报 **分相 TOPS + 整链 wall + 帧级 16 对**；对照基准三件套同时给：**他们报告的 39.6/55.2 与 5.49/5.33**、**我们 1a 的 24.4/30.2 与 28.0**、**现路 split 的 4.67**。
**判决线**：整套搬进来后 **P4 仍 <30 TOPS => 先自查七项缺哪几项、补全再测**；**七项全齐仍不行 => 才允许写"这套形态在 A770/我们的数据上跑不出来"，并且必须指出是哪一项钉死的**（例如 K = C = 32 这种数学钉死，§47c）。
**选块（工作量最小、判决最快）**：**C=64 档的一条完整链（S1）**——FFN 半块用他们 fused 形态（已有逐位绿的 13 检查点基座）+ att 半块按他们 window-major 布局（§30/§36 已证只有 exp 表进 LDS、Q/K/V 走 global）；**这条链我们已有 5 发融合原型 `s6b_att.cpp`（12 检查点 diff=0、C=64 档 −19.9%）=> port-E 就是在它上面把"接口 + 编码 + 几何"换成他们的**。
原来的**逐腿合并施工图**（`kb_n 合并 / 驻留 / 胖 N / 折叠`）降级为 **port-E 的备胎，不是主线**。

## 49. ★ 普查铲中段：两条自我否证 + 一条军规重申
**① 屋顶覆盖率被打回原形（诚实）**：398 发 gemm/attention 闭包里**只有 3 发有实测屋顶**（WB 的 pass1/pass3/pass682 四腿），**386 发 = `no-roof`**。
 ⇒ **§37 的"矩阵腿已贴 92% 屋顶"这句话的真实适用范围只有 `window_block` 那 4 条腿（可回收仅 3.4 ms 串行）**——**我们此前把 3 发的结论推广到了整帧**。任何后续引用必须带这个限定。
**② 整帧工作量更正**：腿和 = **266.0 GF**，不是 236（差在 `ffn_merge` 第二腿 +8.56 GF，shipped 未给 flop_note，按 :1978/:1992 出口形推；另 WB head 形 +32,768 MAC/窗未计 −0.5）。
 ⇒ **整帧有效算力 = 266/63.5 = 4.19 TOPS**（引用 236 时必须注明"不含 merge 第二腿"）；**lmxx route A 同口径 = 1056 GF / 111.3 ms = 9.5 TOPS** ⇒ **差距仍 2.3 倍，结论不变、数要换**。
**③ dtype 判据（可复用）**：参数表里**有没有 `a_scale/b_scale`** 即区分 int8 直通面与 f16 面 ⇒ `window_block` 四腿是 **f16**（§37 的 81-150% 就是拿 f16 屋顶比的）。
**④ ★ 军规 1 重申（我的措辞错误，已更正）**：我写了"肉在小 M 上"——**这与军规 1（最高优先级：不出现小 M；GEMM 必须宽 M 大 tile、batch 进 grid 维，绝不拆成一堆小 dispatch）表面冲突**，用户当场抓住。
 **正确表述**：普查发现的 `M=192/640/768/960/2560` 闭包**不是我们选择的小 M，而是模型金字塔深层（C=256/512，token 天然少）带进来的既有形状——它们正是军规 1 要消灭的对象**。
 ⇒ `shapes_roofgap.csv` 的排序列改名为 **`violation_ms`（军规 1 违规可回收 ms）**，并**按"合并后的大 M 形态"计价**；
 ⇒ **屋顶实测必须成对**：每类都测 `小 M 原形` 与 `合并后大 M / batch 进 grid` 两种形态（f16 与 int8 都测），报 **合并倍率 = 原形 ms ÷ 合并形 ms**；
 ⇒ **主线一句话**：**把军规 1 违规的小 M 闭包并成大 M / 胖 N 的少数核——这就是他们 71 块只用 35 个核的机制**；**任何"保留小 M 形状去优化它"的方案一律标 `违反军规 1，不采纳`**。
 **port-E 两档的军规地位**：**G2（喂饱档）不违反军规 1**（只动并行度不改形状）；**G1（忠实档，8160 线程）必须标注为"诊断用档，不得进 shipped"**——它存在的唯一目的是证明"喂饱后他们的形态能跑到多少"，不是让我们抄一个饥饿几何。

## 50. ★★★ 普查铲交回：**第一次有"画质零代价的 20.3 ms/帧"实测地图**，而且**合并机制已在出货代码里、守卫只放行 N==32**
**交付**：`tools/shapes_census.csv`（691 行每闭包一行，28 列）、**`tools/xmx_roof.csv`（244 个实测屋顶点：f16/int8 × raw/pub × M 成轴 × 原形与合并形成对；仪器自校验锚 130560x128x32 f16 2.85 / int8 5.00 vs 旧表 5.05 差 1%）**、`tools/shapes_roofgap.csv`（按 **`violation_ms`** 排序，**总 47.3 ms 串行 => 帧 x0.43 = 20.3 ms**）、**`notes/shape-merge-plan.md`（340 行 / 46KB 头号交付）**、探针 `src/bench/sycl/shape_roof_probe.cpp`、台账 `tools/SHAPE_ROOF_ledger.csv`（grf128/simd1/private=spill=scratch=0/scratch 指令 0）。GPU = 52 形状组 x 6 独立进程 = 312 进程，0 残留，加载位与三金标未动。
★ **新事实一（redirect 刀序）**：**合并倍率是实测的**：`192x1024x4096 b1->b8` = 8.04->**32.33（4.02x）**；`2560x768x256 b1->b8` = 11.70->**29.73（2.54x）**；`640x512x512` = 2.0x；`9216x384x128 b1->b4` = 1.95x；`640x64x256 b8 -> 块对角 wide 640x512x2048` = 2.30x；f16 `2040x32x128 b8 -> 2040x256x1024` = 2.65x；对照已出货 P8-b `8160x32x128 b4 (3.88) -> wide 8160x128x512 (23.82)` = **6.14x**。
★ **新事实二（否证一条我们原本会走的刀）**：**给单个 batched 发换胖 N（A 广播 sa=0）几乎无肉**：`2040x128x256b8->1024 = 1.07x`、`8160x128x128b4->512 = 1.01x`、`32640x128x64b2->256 = 1.01x` ⇒ **收益全在"把不同块/不同链的独立发并进 grid 维"与"块对角 wide 同时抬 N 与 K"，不在"把一条发单独做胖 N"。**
★★ **新事实三（最值钱）**：**这个合并机制已经在出货代码里** = `libxmx_sycl.cpp:3089-3126` 的 **P8-b block-diagonal WIDE-MERGE，默认 ON**（`Nw=N*batch, Kw=K*batch`、B 预铺块对角、A 用 `gather_pack_a_b_v` 直读宽行、**逐字节 diff 0、2 launch -> 1、实测 0.511->0.138 / 0.280->0.103**）——**但守卫只放行 `N==32`** ⇒ **52/72 发 batched + 32 发 f16 batched 还没走这条已证合法的路**。
★ **军规 41（新，正式入 B2）**：**pub 腿代价随 K 变深而塌缩**——浅 K 时 pub/raw = **41-59%**（`640x512x512`: 4.22/10.23），深 K 大 M 时 **81-85%**（`5120x512x512`: 17.59/20.79）⇒ **折叠 epilogue 与胖形状必须同时做，单做一件只兑现一半**（与 §47"四腿里只有 68% 是 dpas"、port-C2"elementwise=61.9%"三面咬合）。
★ **军规 40（新，正式入 B2）**：**家族价按 FLOPs 分摊只可用于排序，不可当绝对值**——`violation_ms` 的现值来自 RUN_TIMING 家族价按 FLOPs 分摊，已出现 **6 行负值 = 分摊失真**（不是"合并变慢"）⇒ **合并类铲的前置仪器 = 691 行全量 RUN_TIMING 逐发 dump**（现在只打 top-25）。
**参照系措辞更正**：lmxx route A = **36 个核种 / 153 launch / 111.302 ms @1920x1152**（`DevHistory.md:129-169` 逐行加和已核；LDS 6,144-49,152B、regs 119-255、OccW 8-16）——**"71 块 = 35 核"要说成"35-36 个核种"**。
**691 -> ? 路线图（诚实版）**：691 -> 627 -> 599 -> 550 -> ~380（刀 1-4）-> **115-160**（+ 面布局零 pack + 块驻留）；串行 143 -> 97 -> ~45-55 -> **~32 ms**。
⇒ **只靠合并+折叠追不平 8.4 TOPS**：刀 1-4 全做完 = **2.74 TOPS，只走完 1.86->8.4 的 13%**；剩下 87% 在 **③ window-major/fragment 序面（消 pack 腿 23.7-34.9%/链）+ ⑦ 块驻留（1267 往返 400->71 次 = 26.7GB->4.8GB，屋顶 47.7->8.6 ms）+ ② 喂饱并行度**。
⇒ **port-E = 同时补齐 ③⑥② 的那一铲**：选块 **C=64 档 S1 链（closure 641-651）**，**11 发 -> 3 发**，现值 **2.080 ms/链** -> 预测 **0.61-0.81 ms/链**（依据 = `xmx_roof.csv` 的 pub 屋顶行；`wa` 腿 b1020 未测 => 只给 0.35-0.45 区间）⇒ **C64 档 8 链 = -10.4…-11.9 ms 串行 => 帧 -4.5…-5.1**。
**前 3 刀（按 ms/工时）**：刀 1 = 跨块/跨链 batch 进 grid（**12.1 ms 串行 / 帧 -5.2**，零依赖、逐位天然保）；**刀 2 = 放宽 `wide_ok` 守卫 N==32 -> N=64/128（7.6 ms / 帧 -3.3，机制已在出货、工时最小）**，注意 16 发 `epi=2` 站点被现守卫排除 => 先补 epi2 的 pub 等价性；刀 3 = ViT/head MLP 跨块 b8（**20.7 ms / 帧 -8.9**，单刀最大，依赖刀 1 的 stride 分配器；该族 4 个低可信点散布 46-140% => 判决前 >=10 进程重取）。
**两个口径风险（已标）**：(1) `violation_ms` 现值 = 家族价按 FLOPs 分摊（排序可信、绝对值待校准，6 行负值即失真）；(2) 探针 pub 腿用 **epi=4（half-round）**，链上真实形态是 **epi=1（e4m3 snap）** => 头号待测；另待测 `wa` 的 b540/576/1020/1054/1080/1116、GA 反腿 192x32x192、ffn_stem/merge 的 raw 腿、40 个 pending-roof 闭包。


## 51. 刀 2 暂停收尾（续跑包，全文 `E:\DSH\s6\knife2.md`）+ 一条仪器坑 + 一条**未闭合疑账**

**① 第 0 步完成 = 逐发 RUN_TIMING 真账**（军规 40 的前置仪器）：`libxmx_sycl.cpp` **+11 行纯新增**（`rtcsv <pass> <name> <ms>`，在 `NR_RUN_TIMING` 门后，**默认侧零改动**）⇒ 变体 `builds\libxmx_rt2.dll` = `9FDD0E93…`；replay **4 × 691 passes**；**逐发和 135.6 ≈ 总 136 ✓**；家族小计对 §19/§37 的 1a 账 **全部 −0.03…−1.48 ms（约 0.95 倍率）✓**。账表 **`tools/rt_per_closure.csv`（691 行）**。
**三目标族实测现值（取代分摊值）**：S0 int8 `640×64×256b8` = **2.944 ms**（分摊 0.42 ⇒ **低估 7 倍，军规 40 当场坐实**）；S1 f16 `2040×32×128b8` = **3.643**（分摊 3.53 ✓）；S2 f16 `640×256×64b8 epi2` = **3.968**（分摊 4.43 ✓）；**48 发底盘 = 10.55 ms 串行实测**。

**② 第 1 步完成**：`tools/knife2_sites.csv`（48 站逐条：plan 实参 / 现走形 / 守卫挡因 / 合并形 `(Nw,Kw)` / 实测现值 / 屋顶预测 / 风险）。要点：**S0 只差 `N==32` 与 `N*batch≤128` 两条守卫**；**`sa=0` 的 36 发 wide 不适用（fat-N 无肉，明确不拿）**；f16 侧需新写 `gather_pack_b16_diag_b`（已按 `gather_pack_b16_b` 逐字节镜像写好，暂在 probe 本地）。

**③ 第 2 步只到仪器就绪（按暂停令未跑）**：`src/bench/sycl/knife2_probe.cpp`（3 站点 split vs wide-diag 成对单价 + 逐字节 diff + pack_b init 腿）已编译 = `oneapi\knife2_probe.exe` `B5A82BE2…`，**从未跑过，保留给下次**。

**④ 现场复原（md5 实证）**：`out\libxmx.dll` = **ABB969FE** 未动；**`oneapi\libxmx_sycl.dll` = ABB969FE**（本轮从未 stage）；三份金标 **DD49827D / DD49827D / 249A46F3** 未动；GPU 0 残留；四份日志计数核对非空。
**注意：`oneapi\run_timing.txt` 现在是 `NR_B_WIDE=0` 那次的 dump ⇒ 下次先重跑默认侧覆盖。**

**⑤ 下次开工第一条命令**（写在 `s6/knife2.md` 末段）：查 `LOP-Win64-Shipping`（须 0）⇒ **凉 GPU ≥5 分钟** ⇒ 进 `E:\DSH\oneapi`，设 `K2_SITE=0`、`SYCL_CACHE_DIR=E:\DSH\sycl-cache-k2`、`SYCL_CACHE_PERSISTENT=1`、`SYCL_DEVICE_FILTER=level_zero:gpu`，跑 `.\knife2_probe.exe` **10 个独立进程**追加进 `E:\DSH\s6\K2_probe_S0.log`（S1/S2 换 `K2_SITE=1/2`）⇒ 看 `DIFF;diff=0` 与 `PAIR;ratio`。
**判据：`ratio ≥1.5` 进第 3 步；`<1.5` 或 `diff≠0` ⇒ 停下回报。**

**★ ⑥ 新仪器坑（军规 5 的延伸，正式入册）**：**热漂移会伪造 RUN_TIMING 对照**——`NR_B_WIDE=0` 的对照跑总账 **+32 ms（136 → 168）**，但差值**均匀分布在全家族**、wide 站点本身只从 0.03 → 0.05 没动 = **连续 45 分钟跑批后的降频** ⇒ **该对照作废**。
⇒ **RUN_TIMING 跨进程对照也必须同热交替，或先凉 GPU ≥5 分钟**；军规 5 对逐发扫表同样成立。

**★★ ⑦ 未闭合疑账（比本刀更要紧，下次第一优先）**：**已出货 wide 的 20 发 `N=32` + `sa=0` 的 20 发，在帧账上只有约 0.002-0.004 ms/发**；`NR_BPACK_TRACE` 下 **`[bwide]` 打印 0 次** ⇒ **这 40 发在默认侧根本没走到 pack/gemm 分支**（skip-map `closures_noop=0`、`v9b/qfuse_b/S6` 全 OFF，**机制未查明**）。
⇒ **"P8-b 已出货在帧上付 0.10-0.14/发"的旧读法必须重记**——这与 §14 的"刀 C 自证伪 = 帧上死代码"是同一类事。
⇒ **刀 2 的 48 站全在活跃链上（0.17-0.27/发），本刀目标不受影响**；但**路线图里"已出货合并机制"的价值要按 ≈0 重算**。

**⑧ epi=2 那 16 发处置倾向 = 纳入**：int8 守卫排 epi2 的原因是 `gemm_b_pub` 的 FMA contraction；**f16 现路已默认折叠 pub 且 epi2 走已证的 `pub_vec_v8` 向量链**（B5-2/BLADE-6），wide 只换 `(Nw,Kw)` ⇒ **第 2 步 diff=0 即充分证明**。

**⑨ 分档修正**：任务书"档 2 = N32+N64+N128"，但普查 f16 块对角族是 **N=256**（`640×256×64b8`）⇒ **档 2 实现为 `N≤256、Nw≤2048`** 才铺得到那 16 发；int8 `N=128` 站点 `sa=0` 守卫自然不命中。

**⑩ 预测重读（代理主动给的诚实预警）**：7.6 ms 的构成（分摊 violation 0.16+3.27+4.21）在实测底盘下应读成 **S0 现值翻倍（2.94）、S1/S2 近原值**；屋顶合并价（G35 pub 0.134 / G41 pub 0.131 / G39 pub 0.112 ms/发 ×16）⇒ **纸面回收 ≈ 0.8+1.6+2.2 = 4.6 ms 串行，低于 7.6**（**wide 形带 b× 零元算术，分摊口径高估了合并腿的收益**）⇒ **第 2 步的成对实测就是这个数真假的终审。**



## 52. ★★★ 刀 2 暂停前交回：**两条改路线图的发现** —— (1) 48 站里 **28 站在加载位上早已 = 0**（被 T2 链级吃掉）；**(2) 转正件的编译期跳块默认不在仓源码里 ⇒ 出货件不可从 HEAD 复现**
**① §51⑦ 疑账静态闭合 = 我的假设成立（还差 GPU 复核）**：机制就在出货源码 —— `libxmx_sycl.cpp:647-688` `s6_take_residual()`，**:676-678** 原文 `// THE RULE: all six or none. Five no-ops + one fused launch.` + `g_cmds[g.cq1|cb1|cq2|cb2|cq3] = [](){}`；`NR_S6_FFN` 默认 ON（`:556-559`）。
 ⇒ **每条 FFN 链的 5 腿（含 2 发 batched）在 record time 被换成空 lambda** ⇒ `[bwide]` 0 次 = **它们连 record 分支都没进**，不是 wide 让它们便宜。
 **双向 bijection 已核**：`rt_per_closure.csv` 里 `family=xmx_rec_gemm_int8_batched` 且 `M∈{32640,8160}` **正好 40 行**、ms 全 **0.0020-0.0044**（合计 0.0846 = 计时地板）= **19 条链 × 2 发 + 1 对链外闭包（c14/c16）= 20 对 = 40 发**；逐对清单已落 `s6/k2b_chainmap.txt`（每对前者 `sa=0` 广播形 cb1、后者 wide 合法形 cb2）；**0/40 落在编译期跳块链里** ⇒ T2 不是这 40 发的机制。
 **预期数修正（否则会误判成"部分成立"）**：`[bwide]` 只在 `wide_ok` 命中时打（`:3112-3120`）⇒ 40 发里只有 **20 发**（cb2）满足 wide 形；另 20 发走 `[bpack]` 且有 **`bgp<=8` 打印上限**（`:3157`）；`nr_replay_now` 一进程 = **4 runs** ⇒ **B 侧预期 ≈80 行、A 侧 = 0**。
**② ★★ 刀 2 的钱被重新定价（这是本段最大影响）**：转正件 `ABB969FE` 带 **编译期跳块默认**（`out\DEPLOY.md5.txt:49-52`：源 = `wt-08e8b62` + `patch_testdefs.py` + `//DT_SKIP_CHAINS_DEF="18..24,26..32"`，`chains_skipped=14 / closures_noop=168`）。逐站对号：
 - **S0 int8 `640×64×256b8`：16 站里 14 站在被跳的 C512 链**（活着的只有 `c217` 0.1743、`c391` 0.1723）；
 - **S2 f16 epi2 同样 14 死 / 2 活**（`c215` 0.2333、`c389` 0.2323）；
 - **S1 f16 `2040×32×128b8`：16 站全活**（chains 9-16、33-40，C128/C256 不在 skip 名单）。
 ⇒ **48 站里 28 站在加载位上帧价已经 = 0**；rt2 底盘 10.55 ms 里 **6.095 ms 是 off-path** ⇒ **刀 2 真正可回收底盘 ≈ 4.46 ms 串行**；按屋顶价（G41 0.1307×16 + G35 0.1343×2 + G39 0.1124×2 = 2.585）⇒ **纸面回收 7.6 → 4.6 → ≈1.87 ms 串行 ≈ 帧 0.80 ms**。再收紧：S1 那 14 站所在链只是**现在**没跳 ⇒ **刀 2 的窗口期 = 这些链还留在帧上**。
**③ ★★ 出货件不可从 HEAD 复现（可重现性缺口，必须先修）**：`git grep DT_SKIP_CHAINS_DEF` 在 `c516627` **只命中 notes** ⇒ **从仓 HEAD 构的变体不跳链** ⇒ 两颗地雷：**(a) 逐位门会假红**（新金标 `DD49827D` 是"跳 14 链"的产物，HEAD 变体落在 `249A46F3` 那代）；**(b) 帧 16 对被 ±4.79 ms 污染**（A 跳链 vs B 不跳链 = 测的是 T2 不是刀 2）。
 ⇒ **修法（下次开工第 0 步）**：把 `patch_testdefs.py` 的编译期默认机制**正式进仓**（或把转正件的构建脚本 + 定义固化成 `tools/build_shipped.ps1`），**让 HEAD 能复现 `ABB969FE` 的语义**；否则**之后每一把刀的逐位门与帧对都不可信**。
**④ 新坑（已入册，下次别再踩）**：**P8 `.ps1` 写中文注释会被按 ANSI 解析炸**（本次实测报"字符串缺少终止符"）⇒ **脚本与日志一律纯 ASCII，中文只进 .md**；**pwsh 自定义函数名别撞内置单字母别名**（`h` = `Get-History`，本次撞过）。P5 `run_timing.txt` 写在 CWD、`rtcsv` 行只进文件不进 stdout ⇒ `[bwide]` 与 `rtcsv` **不能直接交错**，按 pass 序号对齐、每跑立刻存拷。P6 一进程 = 4 runs ⇒ trace 计数 ÷4。
**⑤ 现场复原实证**（本会话 **0 个 GPU 进程**，probe 从未跑过、`sycl-cache-k2` 实测 0 文件）：`out\libxmx.dll` 与 `oneapi\libxmx_sycl.dll` = `ABB969FE…`；三金标 `DD49827D / DD49827D / 249A46F3`；`test_*.dll` 未动；`knife2_probe.exe` = `B5A82BE2…`（保留，下次直接用别重编）；`builds\libxmx_rt2.dll` = `9FDD0E93…`；分支 `c516627` porcelain=0；**卡 = 冷**。续跑包全文 = `E:\DSH\s6\knife2b.md`（md5 `8F21EF0A…`）。

### 52b. ★ 新坑 P11（**顺带破了我今天早上的一个疑案**）：本机 `pwsh` 的 `Get-Content`/`Select-String` **把无 BOM 的 UTF-8 中文按 GBK 读** ⇒ 汉字尾字节吞掉紧随的换行 ⇒ **行数被合并**（同一文件 python 数出 147 个 LF，pwsh 只数 87 行）。这正是 P8（`.ps1` 含中文注释解析炸）的根因。
- **续跑包文件 md5 变化**：`E:\DSH\s6\knife2b.md` 从 `8F21EF0A…` -> **`29E0510B192264F1BE616F4DEEC906D1`**（18,048 B / 147 行）。
- ★ **破案的旧疑点**：今天 09:3x 我用 `(Get-Content notes\DS-takeover-2026-11-01.md).Count` 得 **407**，而同一文件 `Select-String` 显示 `## 40` 在 **L954** —— 当时我判"计数是仪器读数假象，不是丢内容"。**现在确认根因就是 P11：pwsh 的 GBK 误读把带中文的行成对合并，所以行数偏小**（内容没丢，判读没错，但**当时的"解释"不够准**）。
- **规矩（16c）**：**含中文的账本/日志一律用 python 或 rg 核对行数与内容**；`.ps1` 与机器读的 log **保持纯 ASCII**；写中文的 .md 若可能被 pwsh 读，**存 UTF-8 带 BOM**（`walk.ps1` 那次就是这么救的）。

## 53. ★★★ 可重现性已修好（以后所有门与帧对都必须走这个基座）+ §51⑦ 疑账实测闭合
**先更正一条我自己的 grep 误判**：宏名是 `T_SKIP_CHAINS_DEF`；MSYS 下 `//DT_SKIP_CHAINS_DEF=...` = `/D` + `T_SKIP_CHAINS_DEF` ⇒ 上轮 `git grep DT_SKIP_CHAINS_DEF` 只命中 notes 是**搜索词错了**，不是仓里没有。（`wt-08e8b62` 工作树里钩子是已应用态 = 出货实物基线，按令未动。）
**进仓四件**：`tools/patch_testdefs.py`(A26A8A81) · `tools/shipped_build.defs`(79B75599) · **`tools/build_shipped.ps1`(1D756E68)**（仓侧正规构建：scratch 拷贝 -> 打钩子 -> 带 `/D` 编译 -> 只出 `builds\`，**不脏仓、不 stage、不写 out**，并守卫 `s6_ffn_block_kernel.hpp == 490647A9` 未打 S6_BAR 态）· `out/SHIPPED_BUILD.md`(CA08E249)。
**复现证据（从仓 HEAD `c516627` 出件）**：`builds/libxmx_ship1.dll` = **`7BB0618E8B68129DC2791090438B66F9`**，3,813,376 B（与 `ABB969FE` 同尺寸）；icx exit 0、**编译仅 1.3 分钟**。**4 个独立进程 walk（ship1_a..d）=> 1301 = `DD49827D` EXACT x4 => distinct md5 = 1**；691 passes；`[skip-chains] NR_SKIP_CHAINS = 18..32` + **14 行 `chain=NN SKIPPED (12 no-ops)` = 168 no-op 闭包**，链号恰 `{18..24,26..32}`。
**dll 不逐字节相同**（差 = HEAD 的 +11 行 `rtcsv` 仪器 + 时间戳）=> **复现判据 = 输出逐位 + 尺寸**，不是二进制相同。
★ **地雷已钉死（对照实测）**：`walk -Dll builds/libxmx_rt2.dll`（仓 HEAD、**不带 `/D`**）=> **1301 = `249A46F3` = MISMATCH** ⇒ **从 HEAD 直接 build 的刀变体必然在逐位门假红**；**今后所有门 / 确定性 / 帧对必须走 `tools/build_shipped.ps1` 基座**。旁注：**walk 的 run wall 对跳块不敏感**（ship1 62-63 vs rt2 65-68 ms）=> **别拿 walk wall 当 T2 收益证据**（要用 ab.ps1 帧对）。
**§51⑦ = 假设成立（实测，A/B 同热交替，本批 0.2 min）**：A 默认（`NR_S6_FFN` 不设 = ON）`[bwide]` = **0**、`[bpack]` = 8（打印上限）、那 40 发合计 **0.246 / 0.206 ms**（单发 0.0035-0.026）；B `NR_S6_FFN=0` `[bwide]` = **100 = 20/发 x 5 跑**、合计 **11.79 / 12.57 ms**（单发 0.199-0.65，1 发 1.46）。
⇒ 40 发被已出货的 1a 顶成 no-op（关掉 1a 每发要付 0.2-0.65 ms）；**§50 里 P8-b 已出货合并机制的既有回收按 ≈0 重记**。
**新坑三条**：**P12** 一进程 = 5 次 691-pass 流，但 `run_timing.txt` 以 w 模式打开 => 只留最后一跑；trace 计数 ÷5。**P13** 冷机 RUN_TIMING 绝对值上漂 **约 35%**（A 侧 S0/S1/S2 = 3.56/4.94/4.67 vs 旧账 2.94/3.64/3.97）=> **跨会话绝对 ms 不可比，只能用同次运行内的配对比值**。**P15** PS 传 `/D` 时双引号被吞 => defs 必须写转义引号（否则宏变成整数 18，两处编译错误）。

## 54. ★★★ 活站审计：§50 那张帧 20.3 ms 地图里有 **5.2 ms/帧 已经是死账**；三刀按活站重价
产物 **`tools/shapes_alive.csv`**（398 行 x 23 列：`alive / cause / group / merge_group_alive / merge_still_alive / recovery_alive_ms`，md5 1DE6782E）；生成器 `s6/k2b_alive.py`(53CE3C5A)；摘要 `s6/k2b_alive.txt`(78F0CFC3)。
**死因三条全用机器证据**：R1 roofgap 自带 `chain` 列 in `{18..24,26..32}`（T2 跳块）；R2 `rt_per_closure` ms <= 0.005（计时地板）；R3 **S6 五腿 no-op 用记录流里的六发 FFN 尾自动检出 20 处**（含 chain_map 覆盖不到的 12-18 段）=> 40 发全中，与 §53 的 A/B 实测咬合。
**两个总量**：398 发 = **活 260 / 死 138**（死因：skip 链 98 发 = paper 11.90 ms；S6 no-op 40 发 = 0.26 ms）=> **加载位上活着的 violation 总量 = 35.14 ms 串行 = 帧 15.11 ms**（paper 47.30 / 20.34）。
**三刀活站价值**（paper = violation_ms；现值 = 实测）：
| 刀 | 站数 | 活/死 | paper 回收 | **活站回收 串行=>帧** | 实测现值 全/活 |
|---|---|---|---|---|---|
| **刀 1 A1+A2+A3** | 60 | **60 / 0** | 12.08 | **12.08 => 帧 5.19** | 16.79 / 16.79 |
| **刀 3 A4** | 56 | **28 / 28** | 20.32 | **15.79 => 帧 6.79** | 14.03 / 8.07 |
| 刀 2 B1 | 48 | **20 / 48** | 7.63 | 3.81 => 帧 1.64 | 10.55 / 4.45 |
| B2 fat-N | 36 | 16 / 20 | 1.01 | 0.95 => 帧 0.41 | 4.03 / 3.98 |
| 其它 198 | 198 | 136 / 62 | 6.26 | 2.50 => 帧 1.07 | - |
刀 3 的 28 个死站全是 `640x512x512b1`（32 站里 28 落在被跳的 C512 链）；其余 3 子形 24 站全活（paper 15.14 ms）。
**合并退化检查**（同一 `merged` 目标活成员 <2 => 合并无意义）：全体死亡的 merged 目标恰 4 个 = `8160x512x128b1`(12)、`8160x128x512b1`(12)、`32640x256x64b1`(8)、`32640x64x256b1`(8) => **正是 §51⑦ 那 40 发的两种合并形（B2 fat-N 与 P8-b wide）双双归零**；其余 24 个 merged 目标仍活。
**新坑 P14**：roofgap 的 `orig` 是 `MxNxKb<batch>`（**只有两个 x**），第一版正则写成三段 x => **静默 0 命中**；已加 `comparable/mismatch` 自校验列（**0 comparable 必须警觉**），且 qkv/residual 族 `K` 为空 => **只比对可比的、不许静默丢行**（军规 14 再应验）。

## 55. 裁决（我的）：**下一刀 = 刀 1（batch 进 grid，活站帧 5.19，60/60 全活、零依赖、逐位天然保）**；刀 3 紧随（帧 6.79 更大但有依赖与 28 死站）；**刀 2 降级、不为它跑 1.5 小时 probe**；`knife2_probe.exe`(B5A82BE2) 与空的 `sycl-cache-k2` 原样留着当备用仪器。
**关键澄清（代理主动点出，很好）**：**ratio != 活站价值** —— probe 测的是 split vs wide 的单价倍率，不会因为 28 站已死而变难看；**刀 2 的问题从来不是单价，是没几发还活着**。
**port-E 不受本账影响**：其选块 C=64 档 S1 链（closure 641-651 = chain 48）按 alive 表**全活**（C64 链不在 T2 名单）=> 改派 port-E 时前置仪器不用重做。

## 56. ★★★ 刀 1 交回：**单价 GO、实施判死** —— closure 级跨链换序在当前记录秩序下不等价；决定性对照 R9 证明"是重写本身在改图"
**阶段 A（成对实测）= GO**：仪器 `src/bench/sycl/batch_merge_probe.cpp`(5F8081F9) + `oneapi/batch_merge_probe.exe`(B4939F68，留用别重编)；四族 = `2560x768x256`(A1 qkv) / `2560x256x256`(A2 wres) / `2040x256x256` + `8160x128x128`(A3 res)；**同进程内 split(b x batch=1) vs merged(1 x batch=b) 交替配对**，5 组 x min-of-15、60ms 组间、nosink；样本进程 F0 15 / F1 18 / F2 10 / F3 10 => 96 组。
- **DIFF：修正哨兵后 128/128 = diff=0**（主跑里 pub 腿的 nonzero 是**哨兵伪差异**：`diff=(Mp-M)*N*esz`、`first_off=M*N*esz+1` —— pub 核有 `if(rr<M)` 守卫不写填充行、raw 核写满 => raw 全 0；F0/F1 的 M=Mp 连伪差异都没有）=> **合并本身逐字节安全**。
- **分离实验 RESTWIN**：孪生核 `s8v8::gemm_b_res_batch` vs 出货 `gemm_b_res` x b，**b=1,2,4,8 全 diff=0 => 核无罪**。
- **ratio（best b=16 的 24 组里 23 PASS）**：按 plan 档 F0 int8 pub epi1 **1.522** / F1 **1.597** / F2 **1.515** / F3 b4 **1.317 无肉、必须 >=b8**（b8=1.605、b16=1.882）。**合并倍率随 b 增长明显，§7.1 的 b8/b4 预估偏低；真要实施应并到 b=16（16 发一族 = 1 发）**。
- **TOPS 对照**：F0 int8 raw merged b8 = **29.80** vs `xmx_roof.csv` G18 29.73（差 0.2%）✓；但本案 split b8 = 18.88 vs §50 的 G17 单发 11.70 是**口径不同**（连续 8 发合计 vs 单发 min-of-15）=> **别拿 §50 的 2.54x 当本案 ratio（本案配对 = 1.58x）**。
- 台账 20 实例：**grf=128、private/spill/scratch=0、scratch 指令=0** ✓。
**新坑 P16**：PS 5.1 的 `*>>`/`>>` 会把子进程输出重编码成 UTF-16 并与 ASCII 头混在一个文件 => **机器读的 log 用 `cmd /c exe >> log 2>&1`，解析走 python（BOM 嗅探）**（本轮第一次跑批因此白烧 6 进程）。**P17**：probe 在 **F1 形上随机 fastfail `0xC0000409`**（F1 14 次尝试 11 崩，其他族干净）=> 分 dtype 补跑 + 重试 + 逐点报 n。

### 56b. 阶段 B（实施）= **未过逐位门，十轮排除后判死**
已落地（本轮入仓）：孪生核生成器 `s6/k1_add_batch_res.py`（体从 `gemm_b_res` 逐字节复制，只改 group 索引与指针来源）+ 引擎侧 `s6/k1_engine_bmerge.py`（`NR_BMERGE` 分档、记录期 stash、**捕获期 skip pass 之后**重写 closure、`[bmerge]` 计数）。全部 build 走 `tools/build_shipped.ps1` 基座。
- **默认侧（不设 `NR_BMERGE`）= 1301 `DD49827D` EXACT x4 独立进程** ✓，`chains_skipped=14 refused=0 closures_noop=168 passes=691` 一字未变 => **默认侧自证逐位不变成立**。
- **合并侧从未逐位**：MAX16（1 组/16 发）4 进程 4 个不同 md5；MAX2（8 组/2 发）仍 MISMATCH；`s6/k1_bands.py`：**1301 面 100% 元素不同**（4 通道 x 544 行全错）=> 早期一次错写毒化整图。
- **十轮排除**：R1 组内含被 skip 杀的成员 => 加 `g_skipped_cmds` 过滤；R2 输出面被中间 closure 触碰 => `outs` 指针相交守卫；R3 未注册 closure 视为冲突；R4 成员**输入面**（Araw/Braw/skip/cos/as/bs/a16r）在 pack 后、合并发射前被改 => 加输入保护（**此时 MAX16 = groups=0 => 1301 EXACT，负对照干净**）；R5 描述符表专用 malloc；R6 成员 A 面专用 malloc（不进池）；**R7 `NR_CGRAPH=0`：默认侧 EXACT、合并侧仍错 => 与 cgraph 无关**；**R8 孪生核在 probe 里 diff=0 => 核无罪**；**R9 决定性对照 `KEEP=1 + SCRATCH=1`（每条腿仍按出货位置发射自己的 gemm、合并腿只写丢弃缓冲）=> 仍错 => 是"重写"本身在改图**；**R10 把组的设备对象全部移到重写期分配 => keep+scratch 仍错，纯合并 = 挂死**（`nr_replay_now` 22 分钟无输出，已杀 pid 4024）。
- **诚实结论**：刀 1 的**单价结论成立**，但**"把 b 条链的腿推迟到组内最后一条链"在当前记录顺序下不等价**；PGRAPH 指针级守卫不足以刻画真实依赖；最可能根因 = 这些腿的输入面（A 面 / a_scale / b_scale / skip / cosine）在链间被**复用/改写**，且引擎把 **scratch-pool 的取块序列当作正确性的一部分**。=> **closure 级重写做不成这件事**；刀 1 需要**记录/计划层换序 + 稳定面**（同形腿排到相邻、面不被回收）= **port-E 量级，不是小刀**。
- **机器事实（关键）**：96 个 residual 站点里**相邻（cmd 连续）的同形腿对 = 0**（组成员间隔 10 = 一条链长）=> **记录秩序本身就不相邻，合并必须先换序**。
- **安全**：`NR_BMERGE` 默认 0，且默认档 MAX=16 在 R4 守卫下 **groups=0** => 这批改动对出货路径无风险；**但别在 MAX<=4 跑合并（会挂死）**。
- **40 门**：stage k1i 后 = **39 GREEN / 1 RED**，唯一 RED = `gate_skip_graph` 的**自带 md5 守卫**（要求 oneapi 里的件 = ABB969FE）；该门功能检查全过（skip 计数 + 三进程 1301 EXACT）。**复原 `oneapi/libxmx_sycl.dll` = ABB969FE 后重跑 = 40 GREEN / 0 RED** ✓。

### 56c. ★ 新前置条件（军规 42/43，已入 B2）：合并类刀必须先过"可合并性"两道闸
**军规 42：跨链合并的前置条件 = 同形腿在记录秩序里相邻 + 其输入面不被中途回收/改写**。二者任一不满足 => **closure 级重写不可行**，必须上升到**记录/计划层换序**（port-E 量级）。证据：R9 决定性对照（keep+scratch 仍错）+ 相邻同形腿对 = 0/96。
**军规 43：`violation_ms` 地图必须再加一层 filter —— "这一刀要不要跨链换序"**。否则"活站 15.11 ms/帧"会被读成可回收，实际刀 1（12.08）与刀 3（15.79）**同墙**。
⇒ **裁决（我的）**：**(a) closure 级刀 1 判死**（机制与开关入仓留形，默认 OFF）；**(b) 刀 3 同墙，不再单独尝试**；**(c) 下一铲 = `port-E`**：它按构造就带来"同形腿相邻 + 稳定面 + 换序"的地基（他们的接口 = 块内计划），且其选块 C=64 档 S1 链（closure 641-651 = chain 48）按 alive 表**全活**；**(d) 若 port-E 之前想要一笔不依赖换序的帧钱，走 C1（quant 折进生产者 store）**。
**§50 的三刀价值现在要这样读**：刀 1 帧 5.19 = **单价成立、实施需换序**；刀 3 帧 6.79 = **同一堵墙**；刀 2 帧 1.64 = **已降级**；**port-E 帧 -4.5…-5.1 = 当前唯一"按构造可实施"的大刀**。

## 63. ★★★ port-E 阶段 A 交回：**他们的核在 A770 上"喂不饱"是结构性的（G2 不可能）；但接口是真价值** ⇒ **净值重定：串行 −5.6 / 帧 −2.4**（不是 −4.5…−5.1）
**① 七项逐项**：① 核 搬了（`port::fused` 13 检查点 diff=0，全程零 `esimd::shuffle`）；② **几何：G1 照抄成立、G2 结构性做不到**（`grid x LW ≡ ngrp x W = 8,160` 恒等 ⇒ **抬 LW 不抬并发只推 SLM**：LW=32 => 41,984B 越崖（驻留 3->1）、LW=64/128 => **SKIPROW: SLM 83,968/165,888 > 65,536 帽**）；③ 面布局 搬了（att 半 Q/K/V 按 fragment 序写 global、`diff Q/K/V-plane=0`、P9 零 pack；FFN 半 `retile_a 2,088,960 B` + `retile_b 16,384 B` 预铺、hidden 只在 SLM）；④ e4m3+行 pow2+±448+软件 `H()/Ffast()` 搬了（`e4m3-enc=0 (8,355,840 B)`、`e4m3-dec=0 (16,711,680 B)`、`sc1/sc2/sc3=0`）；⑤ 折叠 搬了（P3 requant 在核内、P5 outquant 在核内、`out-1275=0`、`1267-FINAL=0`）；⑥ **launch 形态未合成**（两半各自成立：FFN 半 6 相 1 发 wall 0.718；att 半 5 发 1 发 wall 0.4329；**跨半合成体不存在**）；⑦ **供数是他们的短板**：`port::fused` = grf128/simd1/slm 21,504-29,696 但 **private 6,304-6,464 B + scratch 指令 178-289**，而我们的 `ffn2::fused` 与 `att5L::fused` = **private/spill/scratch=0、scratch 指令 0** ⇒ **他们的核过不了我们的计价腿红线**。
**② 对拍（A 级）全绿处**：att 半 GATE GREEN x3 进程 12/12 全 0 + LIVENESS 反证；1aR1（base 与 M2b x S1/S2）GATE PASS C2-R1 13/13 x4；他们核 **LW=16 档 10 进程全 GATE PASS（13/13）**；**4 项接口检查点全绿**（面布局字节序 / scale 粒度 / e4m3 编码 / epilogue 出口形态）。
⚠ **LW=32 档 5 进程中 1 进程 GATE FAIL**：`out-1275 193/4,177,920 B`、`sc3 9/32,640`（**first row 29872: ref 2.01574802 vs port 2.26771665**）、`1267-FINAL 996 B` ⇒ **单行行峰取到不同值** ⇒ 该档不可信；首要嫌疑 = `M_BAR=0` 的 `esimd::barrier()` 无 ACQUIRE（port-M 标过的 M-FLAKY），**未归因到指令**。
**③ G1/G2 x 六相 TOPS（min-of-15x5、60ms 组间、nosink、进程间 60 s）**：G1（LW16, SLM 20,992, 8,160 线程, wall 0.7183）：P2 expand 0.1940 / **5.52**；P3 requant 0.2954；**P4 contract 0.0291 / 36.8 TOPS**（间隔跑 36.54/37.47/37.75/37.89/39.34，对齐 `port-C1` 的 39.6）；P5 0.0319；P6 0.1676 / 1.59。G2（LW32, SLM 41,984 越崖, 仍 8,160 线程, wall 0.7516）：P4 **0.0625 / 17.1**（14.90-18.11）⇒ **G2 反而更差**。
占屋顶：P2 同形屋顶 int8 `M=32640 N=256 K=64 b1` = 0.1382 ms / 7.74 TOPS ⇒ **71%**；P4（N=64 K=256）**屋顶表无同形点**，用全表最佳 int8 **41.24 TOPS**（M=1536 N=4096 K=1024）作上界 ⇒ **89%**，而同 FLOPs 的 N=256/K=64 屋顶慢 **4.9 倍** ⇒ **"瓶颈不在 dpas、在 elementwise" 的定量证据**；P6 屋顶 3.44（spread 46.5% 低可信）⇒ 46-98%。
★ **新坑 P18（重要仪器规矩）**：**背靠背进程会把 TOPS 压低 2 倍以上** —— 同一 `S1 LW16 KN1`，15 进程连跑 P4 中位 **15.06**，改成 **60 s 进程间隔 = 37.7**（对齐 port-C1 的 39.6）⇒ **进程内 min-of-15x5 不防热**；**阶梯/扫档测量必须逐进程间隔并记 batch 时长**（本轮 `pe_runB` = 13.1 min）。
**④ 每链单价（bench 内同仪器，不与 RUN_TIMING 串价混账）**：FFN 半 S1（C=64 M=32640）：split 8 发 **0.8139** -> 我们 1a **0.4647** -> **1aR1 base 0.4731 / M2b 0.4109-0.4142**（GPU 0.3498-0.3507；all-in 含生产者 0.5255-0.5263）-> 他们核忠实移植 **0.7183**；FFN 半 S2（C=128）：split 0.5898 -> 1a 0.3787 -> **M2b 0.2730**（GPU 0.2144）-> 他们核 0.4230；att 半 C=64：现路 5 发 cum **0.6484** -> 合一相 **wall 0.4329 / GPU 0.3531（−33% wall / −45% GPU）**；att 半 C=128 **反而 +51%**（SLM 41,984 越崖）。**两半相加（bench 内）：现路 1.462 -> port-E 形态 0.844 = −0.618 ms/链 = −42%**。
**⑤ ★ 8 链外推与对 §50 预测的更正（军规 42/43 同一课）**：`rt_per_closure.csv` 实测 **chain 48 = 1.525 ms/链**（11 发：5 个 quant ≈0.002、**647/649 两条 batched 已被 1a no-op**、651 residual 0.5326 携带融合 FFN、att 半 642+643+645 = 0.978）；**8 条 C64 链（0-3、48-51）实测 1.217-2.116，均值 1.658 ms/链**。按 −42% 折算 ⇒ **−0.70 ms/链 => 8 链 −5.6 ms 串行 => 帧 −2.4**（x0.43）。
⚠ **§50 的 0.61-0.81 ms/链与 −10.4…−11.9 串行 / −4.5…−5.1 帧是拿 2.080 ms/链（1a 之前）当基线**；1a 出货后实测基线只有 1.525-1.658 ⇒ **预测里约 0.4-0.55 ms/链已被 S6-1a 先吃掉** ⇒ **诚实净值：串行 −5.6 / 帧 −2.4**。
**⑥ ★ 最难搬的一项 = ② 几何，且给出机器级原因**：他们的并行度天花板 = **8,160 线程（LW=16、`grid x LW` 恒等）+ SLM 21.5 KB**，而 A770 甜区约 **130,560 线程**；抬并行度的三条路全被禁：**TG=32**（被 `static_assert(TG==16)` = 忠实性禁）、**split-K**（被 ① 禁）、**W/G 抬大**（被 64KB SLM 帽挡 = 三行 SKIPROW）。⇒ **"七项全做"在他们的核上不可能同时成立**；放弃 ② 之后 port-E 退化成 **"我们的 1a 链 + 他们的 R1/R2 零-pack 接口"** —— 而这一条**已经跑通且更快**（M2b 0.411 vs 他们核 0.718；att 0.433 vs 0.648）⇒ **port-E 的真价值在接口，不在他们的核**。
**⑦ 阶段 B 的前提问题已答（纯代码级）**：**零-pack 合成在 64-token 窗口档成立**：att 半 `PKT + (kb*2048 + row*32)`、FFN 半 `O_PK + ((kb*BANDS + (t>>4))*512 + (t&15)*32)`，**T=64 => BANDS=4 => 该式逐位化为 `kb*2048 + t*32` = att 半同一 map**；他们 port 核（TG16 x G4 = 64 token/WG、band 512 B）也是同一 map；scale 单列（`AS2 + row*4` vs `O_SC + t*4`）同形 ⇒ **健康闸第 3 条（不新增 pack 腿）在布局上可满足**。⚠ 代价：block4 的 S1 现在跑 **T=32**（台账 `ffn2::fused T32 C64 HID256`，SLM 31,744 B）=> 合成要把 FFN 半抬到 **T=64**（BANDS=4），**SLM 会翻倍 => 撞 32KB 崖的风险要先单独计价**。
**军规 44（新）**：**移植判决的"七项全做"必须先证"七项可同时成立"**：本案他们的核把并行度钉在 8,160 线程（`grid x LW ≡ ngrp x W` 恒等 + `static_assert(TG==16)` + 64KB SLM 帽三条路全禁），**在 A770 上结构性喂不饱** => 七项互斥时，**结论要写成"哪几项互斥"，而不是"这堆东西整体不行/行"**。
**军规 45（新，P18）**：**跨进程 TOPS 阶梯必须逐进程间隔（>=60 s）并记录 batch 时长**；进程内 min-of-15x5 不防热（本案 15 进程连跑 P4 中位 15.06 vs 间隔跑 37.7，差 2.5 倍）。

## 64. ★★★ B0：**port 核"自身不可重复"坐实（200 连发里 2-4 次产出不一样）——我原先三条猜测全部被证伪**
**冷进程判别器 n 不够**（`s6/pe_b0.ps1`，batch 31.6 min，进程间 60 s）：`KN=1 LW=32` **0/10**、`KN=0 LW=32` **0/10**、`KN=1 LW=16` **0/5**；合并历史样本 `KN=1 LW=32` = **1/20**、`KN=1 LW=16` = 0/15 ⇒ **基率约 5%，n=10 不足以归因**（Fisher p 约 0.5）。
**注**：`M_BAR` 是 block4/1a 的开关，**port 核没有它** —— 它自始至终用真 `group_barrier`（`port_ffn_fused.cpp:347/398/447/500`）⇒ **对 port 核"栅栏类型"这一维已被排除**（§44 机器级也证了两种写法编出同类 CTA 栅栏、8 条 signal barrier）。
★ **换放大器才拿到决定性读数**（`E:\DSH\tmp\pe_stress.cpp` md5 `3DB5E9D3`，生成器 `s6/pe_mkstress.py`；`s6/pe_b0s.ps1`，5.2 min）：同进程内**连发 200 次 DUMP 核**，每次发射前把跨波交接面 `dOut1275` **memset 成哨兵 `0xA5`**，再与 launch-0 逐字节比：
| 臂 | launches | **bad** | 带哨兵字节 | 首个 bad 细节 |
|---|---|---|---|---|
| KN=1 LW=32 | 200 | **0** | 0 | - |
| KN=0 LW=32 | 200 | **0** | 0 | - |
| **KN=1 LW=16** | 200 | **4**（s=20/147/166/178） | 0 | dOUT=189 dPK3=583 **dSC3=27** row=**17040** col=0 |
| **KN=0 LW=16** | 200 | **2**（s=132/135） | 0 | dOUT=98 dPK3=268 **dSC3=14** row=**14336** col=0 |
⇒ **port 核自身不可重复：200 连发里 2-4 次（约 1-2%）产出不一样**。**四条猜测被证伪**：① **不是栅栏类型**（KN=0/1 都翻；§44 机器级同类）；② **不是 C1 的 global 读回刀**（KN=0 读 SLM 副本同样翻）；③ **不是 WG 宽度**（本轮 **LW=16 比 LW=32 更容易翻** 4/200 vs 0/200 ⇒ 之前 1/20 集中在 LW=32 是小样本 + 背靠背热态）；④ **不是"读早了看到哨兵"**（`sentinel_pairs = 0` ⇒ 错字节是**别的真实值**，不是未写过的槽）。
**签名与坐标已解析**：出错行 **17040 / 14368 / 10272 / 2064 / 14336 全是 16 的倍数** = **fragment band / 每 WG 16 行** 的边界（之前 `first row 29872` = `16 x 1867` 同一签名）。换算：`M=32640 = 510 windows x 64 tokens` ⇒ row 29872 = **window 466、token-in-window 48、band 3、lane 0、col 0**；A 面 row-major `dpk1 + 29872*C + kb*32`、fragment 序 `grp=1867, r=0 => dfrag + 1867*(16C) + kb*512`；a_scale = `dsc1[29872]`。两个 scale 反推行峰：ref `2.01574802 x 127 = 256.0`、port `2.26771665 x 127 = 288.0`（都是 f16 精确值）⇒ **不是乱码，是"别的行的真实值"** ⇒ 组级污染，每次 10-30 个行 scale。
**剩下唯一活着的机理族 = 同一 WG 内跨波的 SLM 槽可见性/顺序**，候选缩到两处：(a) `SCB` 行 scale 槽的 **4 字节粒度跨波写/读**（`:374 store(SCB + r*4, simd<float,1>)` / `:422-423 load<float,8>(SCB)` / `:474 store(SCB + 64 + r*4)`）；(b) `HIDF` 的 **in-place requant**（`:361-369` 整行读峰 -> `:376-385` 同一批字节原地覆写，**PHASE 2 内无 barrier**）：行所有权按 `r = w*RPI + i` 不重叠，但 **`kb*512 + r*32` 的 512B band 里混着 4 个波的行** ⇒ 若 band 级读写不是 32B 原子，就会读到别的波刚覆写的行字节 ⇒ **与"band 对齐、整组 scale 变"完全吻合**。
**未做到**：还没反汇编到具体 `lsc_load/store` 的 cache-control 位（"指令级"还差这一步）。下一步可 (i) 把 `HIDF` 的 band 按波分区做 A/B，或 (ii) 拿失败样本配 `ocloc` 反汇编对照。
**临时规矩（即刻生效）**：① 归因未结前**新合成链禁 LW=32**（只用 LW=16 + T=32）；② **合成链一律 `KN=0`**（保留 SLM out 副本，不用 C1 的 global 读回刀 —— 两臂都翻，KN=0 少一个变量）；③ **任何新核进 shipped 前必须过 200 连发压力门（bad=0）**；④ **要把同一放大器套到已出货的 1a（`ffn2::fused`）**：若它也 bad>0，则 §43 的 RACE 条目不再是"机器级不成立"，修法按 §44/§52 = **拆槽/挪相**（不是加 barrier）。

## 65. B1：**T=64 算术过关、几何不过 ⇒ 不编**；并找到**零代价改道**（合成根本不需要 T=64）
**逐项 SLM 表**（`s6_ffn_block4.cpp:164-176`，S1 = C=64/HID=256/KS4=4/KS6=2）：T=32 现档 `O_PKH 8192 + O_PK 2048 + O_HID 16384 + O_OUT 4096 + O_SC 384 = 31,104`（JIT 台账实测 31,744 = 驱动 padding）**崖内 => 2 resident WG**；**T=64**：`O_HID` 涨到 **32,768**、合计 **62,208**（+padding 约 62,848）**越 32KB 崖 => 1 resident**，且 **`O_SC` 需 768 而注释写死 T<=32 floats each** ⇒ `O_SC+128`/`+256` 两处偏移会串槽 = **硬结构阻塞**。
★ **但决定项是几何不是字节**：`nd_range(range(nblk*64), range(64))` ⇒ 每 WG 固定 **64 个 ESIMD 线程**，而 T=64 的活动图（`:193-205`）**超出 WG**：**ACT2 `(T/8)(HID/16)` = 128 > 64**、**ACT6 `(T/8)(C/8)*KS6 = 128 > 64`**（ACT4 64、ACT3 64 勉强够）⇒ **T=64 需要 LW=128，而 `LW>=128 + barrier` 是已证的死锁区**（`notes/s6-port-spec.md` D1：前辈 256 线程/WG 在 ESIMD 下直接 HANG）；否则要给 P2/P6 加 per-thread 循环 = **改核心**（违令）。
⇒ **B1 裁决：不编 T=64**（军规 22/30：先算字节，算不过就停下）。
★★ **零代价改道（代理找到，很好）**：合成不需要 T=64。两半元素级 map 本来就同形，差的是 kb 块带宽数：att 半 `PKT + kb*2048 + row*32`（每 kb 块 4 band）vs FFN 半 `O_PK + (kb*BANDS + (t>>4))*512 + (t&15)*32`（BANDS=2 => `kb*1024 + t*32`）⇒ **把 FFN 半的 global A 面寻址参数化**成 `kb*2048 + (hb*16 + band)*512 + lane*32`（`hb in {0,1}` = 窗口半）⇒ **T=32、LW=64、SLM 31,104（2 resident）一字不动**，只改入口面 stride 与一个 band base ⇒ **零 pack 腿、零 quant 腿**（健康闸第 3 条满足），网格仍是 1020 WG（与现档 `nblk = M/T = 1020` 完全一致）。

## 66. ★ 新军规 46/47（已入 B2）：低基率竞态必须用"同进程 200 连发 + 哨兵"放大器归因；任何核进 shipped 前必须过 bad=0 自重复门

## 67. ★★★ B0 续：**判决 ① —— 我们的两核 0 bad / 1800 连发；他们的核 12 bad / 2400（约 0.5%，Fisher p 约 2e-4）⇒ 出货件不暴露，port 核的病是它自己的**
| 核 | 进程 x 连发 | **bad** | 同时的门 |
|---|---|---|---|
| **`ffn2::fused`（已出货 1a 形态）** | 3 x 200 | **0/0/0（0/600）** | 每进程 **B3GATE PASS（9 检查点 vs block3）+ GATE PASS C2-R1（13/13）** |
| **`att5L::fused`（我们的 att 5 发一相）** | 3 x 200 x 两形（C64/C128） | **0（0/1200）** | 每形每进程 **GATE GREEN（0 checkpoints differ）** |
| `port::fused`（他们的核，对照） | 2 x **1000** | **4 / 4** | GATE PASS（逐字节门过，翻的是**自重复性**） |
| `qr_kernel_rowthread<64>`（无 SLM 无栅栏的负对照） | 1 x 200 | **0** | - |
★ **方法学更正（重要）**：**200 连发不够当判决** —— 同一个 port 核一个 200 连发进程 bad=0、两个 1000 连发进程各 bad=4 ⇒ **真基率约 0.5%**（不是 §65 估的 1-2%）；这也解释了"1/20 冷进程"（0.5% x 20 = 10% 抽中一次）。⇒ **军规 46 的门改成">=1000 连发 bad=0"，200 只做快速筛。**
**签名收窄（已接近钉到指令）**：1000 连发的 8 次失败里 **出错行 `row % 16` 分布 = {0: 4, 7: 4}** ⇒ **全部落在 16 行 tile 的 8 行 fragment 边界**（0 = tile 首行，7 = 第一个 8 行半片的末行）。**这与 ESIMD 硬坑 #18(2)（dpas 累加器 fragment 只有 8 行、`select<8,1>(row*8)` 的 row 必须 0..7）同一边界族**。
⇒ 嫌疑收窄到**跨 8 行半片的 SLM 槽/带边界**：`HIDF` 的 `kb*512 + r*32` band（一个 512B band 混 4 个波的行）+ `SCB` 的 4 字节跨波槽。
⇒ **再次排除**：栅栏类型（§44 机器级同类）、C1 global 读回刀（KN=0 也翻）、WG 宽度（LW=32 本轮 0/200，LW=16 才翻）、读到未写槽（**全部失败里 `sentinel_pairs=0`** => 错字节是别的真实值）。

## 68. ★ 自重复门已进仓成通用仪器（两颗牙都验过）
- 新 `src/bench/sycl/stress_repeat.cpp` = **负对照**（`qr_launch_esimd`/`qr_kernel_rowthread<64>`，M=32640，哨兵 memset，连发自比）=> `oneapi/stress_repeat.exe` `9C8D0062…`，实测 **bad=0** ✓；
- `src/bench/sycl/port_ffn_fused.cpp` +40 行（`PORT_STRESS=N`）=> `port_ffn_fused.exe` `3BFCF6C7…`；`src/bench/sycl/s6b_att.cpp` +61 行（`S6B_ATT_REPEAT=N`）=> `s6b_att.exe` `AB4ADC03…`；**注意 fATT 故意不 scrub/不比**（核不重写整块 att 面；第一版把它算进去造成 **bad=199/200 假警**，已在源码注释注明）；
- 新 `tools/stress_repeat.ps1`（纯 ASCII）= 四臂矩阵（ctrl / port / att / ffn2）+ 60 s 进程间隔 + **自动牙齿检查**（CTRL 必须 bad=0、PORT 必须 bad>0，否则明说"仪器没牙 / 正对照丢信号"）；
- `ffn2` 臂复用仓内已有的 M-FLAKY 探针（`s6_ffn_block4.cpp:1580-1620`，`M_REPEAT=N`）——**只在 `C2_STAGE=1 或 3` 才执行**（`C2_STAGE=2` 会释放 1a taps => 探针静默不跑，第一次就是这么漏掉的，已入账）；
- **两颗牙都过**：负对照 `qr_kernel_rowthread` bad=0/200 ✓；正对照 `port::fused KN=1 LW=16` bad=4/1000 ✓。
**规矩状态（即刻生效）**：① 合成链禁 **LW=32**、用 **KN=0**；② 进 shipped 前 **>=1000 连发 bad=0**（200 只做快筛）；③ **已出货 1a 不必修**（0/600 + 9/9 + 13/13）=> **不动 shipped**。
**军规 48（新，入 B2）**：**ESIMD 里 16 行 tile 的"8 行 fragment 边界"是危险线**：任何跨波/跨半片的 SLM 槽与带（band）设计都要按这条线检查——本案 port 核 8 次失败的出错行 `row % 16` 只落在 0 与 7；这与硬坑 #18(2)（dpas 累加器 fragment 只有 8 行）同族。
**对上游的一条诚实观察（值得记）**：**lmxx 的 FFN 融合核在我们工具链里逐字节正确、但不自重复（约 0.5%）** —— 他们的逐字节门（GATE PASS）抓不到这类事，因为那是单次输出对参考，不是自身重复。

## 70. ★★★ B2a 交回：**端到端合成体建成并通过门 1-3**（25 项逐字节全 0、6/6 进程 GREEN、LIVENESS、cross IDENTICAL）+ 新坑 P20（会**伪造 RED 门**的 bench 陷阱）
**合成体**：`src/bench/sycl/port_e_chain.cpp`（480 行）+ `src/bench/sycl/port_e_chain_bodies.inc`（由 `s6/pe_mkchain.py` 从 `s6b_att.cpp` + `s6_ffn_block4.cpp` **机械抽取、逐字不改**，各自包进 `namespace PE_ATT / PE_FFN`）；exe `oneapi/port_e_chain.exe` = **`EC1D8CFE8A9554D10D1A4FD190E966D3`**（2,527,744 B），编译 `s6/cc_portE.ps1 -Defs "/DM_P4FORM=0 /DM_PEAK=1 /DM_P3SPLIT=1"`（**M2b 档**；Shape 有 `static_assert` 要求模板参数 = 宏，所以档位走编译期）。
**形态**（一条 C=64 链，plan closures 641..651）：
- **L1** `PE_ATT::att5::fused<64,2,5,DUMP,LIVE>` = 5 个 plan 腿一发（QUANT_WINDOW -> QKV -> WINDOW_ATTENTION -> QUANT -> GEMM_WINDOW_INT8_RESIDUAL，出口 = 1270，token 序）；
- **L2** `packdev::pack_a_fused(1270 -> face + scA)` = 链自己的那发 QUANT（646），**顺手按 dpas fragment 序落 A 面**（R1 生产者）；
- **L3** `PE_FFN::ffn3::fused<S,true,NPH-1,0>` = 1a/M2b 的 FFN 五腿一发（expand -> requant -> contract -> outquant -> residual，出口 = 1267），**P1 由 L2 供**；
⇒ **11 个 plan op / 现路 13 个 device 发 -> 3 发**；几何锁死 **T=32 / LW=64 / SLM 31,104 B（2 resident）/ 1020 WG**；**KN=0**、**从未用 LW=32** ✓
**门 1 = 25 项全 0**：att 12 项（`pk0/sc0/Q-plane/K-plane/V-plane/scores/probs/att/pk2/sc2/pk2-folded/1270-FINAL`）+ FFN 13 项（`pk1/pk1-face/faceA-vs-faceB/sc1/hid/pk2/pk2-frag/sc2/out1275/pk3/pk3-frag/sc3/1267-FINAL`）；其中 4 项接口 = **面布局字节序**（`pk1-face` + `faceA-vs-faceB`：**一发生产者面 = 两发 qr+retile 面 = split packA 面，逐字节同**）、**scale 粒度**（每行一个 float）、**量化编码**、**epilogue 出口形态**。
**稳定性：6 个独立进程（40 s 间隔）= 6/6 GATE GREEN**，每进程 `#### port_e_chain: GREEN (fails=0)`。
**门 2 LIVENESS**：把 L2 的共享面 `faceB` 就地 /2 再重跑 L3 ⇒ **`1267 differs in 1,158,095 / 4,177,920 bytes`** ⇒ 共享面真的喂到出口，**且 6 个进程这个数字一模一样**。
**门 3 cross**：`PE_blobA/B.bin`（各 16,842,240 B：1270 + 1267 + face + scA + out1275 + pk3 + sc3）两进程 md5 同为 **`7E963BF25B6F3E8B4608D8F185FB875E`**，`CROSS: IDENTICAL` ✓

### ★ P20 / 军规 49：**bench 里 `q.wait()` 不等于 producer -> consumer 的可见性屏障**
症状：同一 exe、同一 cache 目录，**4 进程里 2 个 GATE RED**，且 **RED 错在 REF 侧**：`packdev::gather_pack_b_b` 的出口面 `dBpE` 前 8 字节 = `0 0 0 0…`（输入 `dWER` 正确）=> REF 的 expand 写出全零 hidden => `hid/pk2/pk2-frag/sc2/out1275/pk3/pk3-frag/sc3/1267` 全 DIFF。
定位：在 pack 前后加探针（`PACK-PROBE` / `REF pre-expand probe` / `REF-dH device probe`）=> **不是 D2H 读空、不是内存压力（当时只分配 120 MB）**，就是那发 pack 的输出在下一次 kernel 读之前**没可见**。
修法：**每个 producer -> consumer 交接点插 `q.ext_oneapi_submit_barrier()`**（出货 bench 本来就这么写：`leg_pk2` = `pack_a_fused(...); return q.ext_oneapi_submit_barrier();`）——**新写的 driver 漏了**。插 9 处之后 **5/5 -> 6/6 GREEN、cross 两次 IDENTICAL**。
⇒ **军规 49**：**bench 里跨 kernel 的面交接必须显式 `ext_oneapi_submit_barrier()`；`q.wait()` 只保证完成、不保证下一个 kernel 读到。** 否则逐字节门会**随机假红**——**比假绿更难查，因为它会把"合成体错了"当成结论**。
**下一步（代理已在跑）**：**B2b** = 门 4（合成体 `--stress 1000`，L1+L2+L3 全链哨兵重发）+ 门 5（台账逐列，`s6/spillcheck_port.py` 加 `port_e_chain` label）；**B2c** = 单价 ≥10 进程 x 60 s，对实测基线 **1.525 / 1.658**，目标 **<=0.844 ms/链 => 8 链 -5.6 串行 => 帧 -2.4**。
本轮 GPU 约 **11 分钟**（gate 稳定性 3.4 + cross 1.5 + 探针若干）；`out\libxmx.dll` 与 `oneapi\libxmx_sycl.dll` = **ABB969FE** 未动；三金标未动；进程 0 残留。

## 71. ★ P20 控制实验：**"port 核不自重复"维持**（BAR=0 与 BAR=1 **同率**）；四个连发 harness 原先确实都没有 submit barrier（已修）
**① 审计**（`tools/p20_audit.py` -> `tools/p20_audit.csv`，30 行 `file,arm,line,call,sync`）：
| harness | 交接点有 barrier | 只有 wait / 无同步 |
|---|---|---|
| `port_ffn_fused.cpp`（`PORT_STRESS` 臂） | 2（本轮加开关） | **5 处 phase-bisection 计时发 NO-SYNC + 2** |
| `s6b_att.cpp`（`S6B_ATT_REPEAT` 臂） | **0** | **9**（scrub->launch、pack->gemm 全 wait-only） |
| `s6_ffn_block4.cpp`（`M_REPEAT` 探针） | 3（本轮加开关） | 9 |
| `stress_repeat.cpp`（负对照） | 0 | 1（memset->launch） |
| `port_e_chain.cpp`（合成体） | **9**（P20 之后加的） | - |
⇒ **四个连发/比对 harness 原先全都没有 submit barrier** ⇒ 对旧结论的怀疑成立，必须做控制实验。
**② 控制实验**（同一 exe、同一 cache、**只切 barrier**；port 核 `KN=1 LW=16`；2 x 1000 连发 x 两臂；进程间 60 s；`s6/p20_ctrl.ps1`，5.9 min）：
| 臂 | bad / 1000 | 签名 |
|---|---|---|
| **BAR=1**（每处交接 `ext_oneapi_submit_barrier()`） | **4 + 3 = 7/2000** | `dOUT 约 89-193 / dPK3 约 157-526 / dSC3 约 6-26`，出错行 **`row%16 in {0,7}`**，`sentinel_pairs=0` |
| **BAR=0**（原始 wait-only） | **4 + 3 = 7/2000** | **完全相同** |
⇒ **两臂同率 ⇒ P20 解释不了 port 核的不自重复**；**结论维持：他们的核真的不可重复（约 0.35%/发）**。
⇒ **这反向加强了 §66 的归因**：错在**核内**（跨波 SLM/global 交接、8 行 fragment 边界），不是 host 侧命令序列。
⇒ **我上一条提的那条漏洞（"barrier 缺失可能让读到上一发旧值而非哨兵，所以 sentinel_pairs=0 没排除干净"）被这条 A/B 直接排掉**：加 barrier 后 bad 不降，且失败签名在两臂一致。
**③ 一条重要的推理补强（我自己补的）**：**缺 barrier = 更弱的同步 = 更容易暴露竞态**。所以 §67 里"我们的两核 0 bad / 1800 连发"是在**更苛刻的条件下**得到的 ⇒ **那个"我们的核干净"的结论不因 P20 削弱，反而更强**。
**④ 正在跑的历史悬案**：`notes/port-M.md:249-252` 的 **"1/158"** 出自 `s6_ffn_block4.cpp` 的 `M_REPEAT` 探针，当时也是 **wait-only** => 同一嫌疑。已给 block4 加 `M_REPEAT_BAR` 开关（默认 1）并重编 `b4_m2b.exe = 28F4A47B…`，跑 **S1/S2 x BAR=0/1 x 1000 连发**（job `pwsh-86f918005a544e37`，约 15 min）：
- **BAR=0 有 bad、BAR=1 归零** ⇒ §35/port-M 的 1/158 **降级为 harness 假警**（要重写的账 = §64④/§65②③/§66 里引用 1/158 的措辞 + 军规 46/48 的证据链加一条"P20 已排除"）；
- **两臂都有 bad** ⇒ 那条 1/158 是真的，**且已出货 1a 形态在 1000 连发下有暴露** => **B2 暂停、先救 shipped**（修法 = 拆槽/挪相，不是加 barrier）。
**⑤ 军规 49 已在 B2 正文**（上一条提交）：bench 里任何 kernel 写 -> 下一 kernel 读 / 主机比对的交接必须显式 `ext_oneapi_submit_barrier()`；`q.wait()` 只保证完成、不保证下一个 kernel 读到。缺它 => 逐字节门随机假红，**flaky 探针读数也会失真**（就是 ④ 这条）。
**合成体状态（不阻塞）**：门 1-3 全绿（25 项逐字节 0、LIVENESS 1,158,095/4,177,920、cross blob `7E963BF2…` IDENTICAL、6/6 进程 GREEN），**门 4 预跑 2 x 1000 bad=0**；exe `EC1D8CFE…`。

## 72. ★★★ B2b/B2c 交回：**门 4/5/6 全过，但单价读数改了方案 —— 生产者腿（R1/L2）在合成体里是净亏，应走 CHAIN2（2 发）**；诚实净值 = **链 −33% ⇒ 帧 −1.75…−1.90**（**没到 ≤0.844 ms/链**）
**§72 先收一条历史案（P20 复验）**：`M_REPEAT` 探针加 `M_REPEAT_BAR` 开关后四臂（S1/S2 x BAR=0/1，各 **1000 连发**，进程间 60 s）= **全部 0 bad**（`0 of 1000 differ from block3`，9/9 B3GATE PASS）
⇒ **已出货的 1a/M2b 形态在 4000 次连发下 0 bad，barrier 与否都一样** ⇒ **§35/port-M 的"1/158"在这台机这个档上没有复现**：既不是 P20 假警，也不是 shipped 暴露；**定性维持 port-M §5 原判**。
⇒ **§71+§72 合起来的判决**：**port 核（他们的）不自重复 = 维持**（两臂同率 7/2000，签名不变）；**我们的 1a / att5 / 合成体 = 干净**（合成体 2x1000 bad=0；1a 形态 4x1000 bad=0）。
**门 4（自重复）**：DUMP=true `--stress 1000` = **0/2000**；**DUMP=false（出货形态）`--stress0 1000` = 0/2000**（比对面 = 1270 / face / scA / 1267）。
★ **新坑（哨兵法的面集合）**：`--stress0` 第一版把 `out1275/pk3`（**DUMP-only tap**）也纳入比对 ⇒ 每发都报 `dout=4,177,908 / dpk3=2,051,314`，**不是竞态，是出货形态根本不写诊断面**（哨兵原地不动）⇒ **比对的面集合必须等于该形态真正会写的面，否则测的是仪器。**
**门 5（台账逐列，key 含 simd+module_id）**：`PE_ATT::att5::fused C64 heads2 P5 dump0 live0` = grf128/simd1/**slm 32,768**/spill0/private0/scratch0/**scrInstr 0**；`PE_FFN::ffn2::fused T32 C64 HID256 P4F0 PEAK1 SP1 BAR0 dump0`（**CHAIN2 的 FFN 腿**）= **slm 31,744，其余全 0**；`ffn3` 腿同样全 0；`packdev::pack*/gather_pack*`、`quantize_row` 全 0 ⇒ **对照 §60 的 `port::fused`（private 6,304-6,464 + scrInstr 178-289）：两半的核都干净** ✓
★ **又一处"静默 0 行"**：`spillcheck_port.py` 的 ffn3 标签正则要求 `INS\d+_5Shape`，实际是 `INS_4ffn25ShapeI`（嵌套名替换）⇒ **ffn3 的行原先被静默丢掉**（台账里看不见这条腿）。已加宽（`s6/p20_fix_label.py`）=> 66 行、ffn3 三行都在。**教训：台账 label 正则对每个新 namespace / 新模板形态都要验"行数有没有增加"，漏行不报错。**
**门 6（单价，10 独立进程 / 间隔 60 s / min-of-15x5 / nosink / 每进程 GATE GREEN）**：
| 形态 | 发数 | mean-of-med | 进程间 spread |
|---|---|---|---|
| **REF13**（现路 13 发） | 13 | **1.4126** | 0.0258 |
| CHAIN3（3 发，**DUMP=true 带仪器**） | 3 | 1.2077 | 0.0371 |
| CHAIN3n（3 发，出货形态） | 3 | **1.0535** | 0.0242 |
| **CHAIN2**（**2 发**：att 合一 + 已出货 1a 半，**无生产者腿**） | 2 | **0.9413** | **0.0070** |
**仪器可信度**：bench 的 REF13 = 1.4126 vs 引擎实测 `chain 48 = 1.525`（少 cgraph 开销 => 低 7%）✓。
**第一轮 ladder 是假账（已更正）**：CHAIN3 只省 15% 是因为 **DUMP=true 的 L1/L3 每发多写约 90 MB 诊断面**（fScores 16.7 + fProbs 8.4 + pQ/pK/pV 12.6 + fATT 8.4 + gHID 16.8 + gPK2 8.4 + gPK2F 8.4 …）=> **计价腿必须 DUMP=false**。
★ **判决级发现：生产者腿（L2 / R1）在合成体里净亏** —— CHAIN3n（带 `pack_a_fused` 生产者 + `ffn3`）= 1.0535，而 **CHAIN2（不带生产者，直接用已出货的 `ffn2` 半，它自己在 P1 里量化 1270）= 0.9413** => **加一发生产者反而 +0.11 ms**。**接图应走 CHAIN2；`ffn3` + 生产者只作 bench 对照保留。**
⇒ 这同时**否证了 §26/§30 里"R1 零-pack 生产者"在链级合成中的价值**：R1 的兑现位置不是"生产者一发写 fragment 序面"，而是"消费者自己在 P1 里就地量化" —— 与 §35（折叠铲 +1.78ms）、§47（int8 只兑现 36%）同一条经验的不同侧面。
**外推（按比值，不串绝对值）**：CHAIN2/REF13 = **0.6664** => 落在 1.525 上 = **1.016 ms/链**（省 0.509）；落在 8 链均值 1.658 上 = **1.105 ms/链**（省 0.553）=> **8 链串行 −4.07…−4.42 ms ⇒ 帧 −1.75…−1.90**。CHAIN3n/REF13 = 0.7458 => 帧 −1.33…−1.45。
⇒ **没达到订单里的 ≤0.844 ms/链**（CHAIN2 实测 0.9413）。差额约 0.10 ms = **两半背靠背的交接代价**（0.4329 + 0.4109 = 0.844 是两半"单独跑"的价，合成体里 1270 的写->读依赖把它吃掉了）。**诚实说法：链 −33%、帧 −1.75…−1.90，不是我之前说过的 −4.5/−5.1。**
**CHAIN2 也过了逐字节门**：`CHAIN2-1267 diff = 0 (4,177,920 B)`、`CHAIN2-pk3 diff = 0`（exe `A4C3D8F8…`）=> 2 发形态同样逐位等于现路 ✓
**一处设备级坑（已修）**：`ffn2::fused<DUMP=true>` 会写 `dpk1/dsc1` 两个 tap，Args 里留 nullptr => **当场 `0xC0000409` fastfail**（GATE GREEN 之后才炸）=> **任何 DUMP=true 的腿，tap 指针必须全非空**（`ffn3` 因跳过 P1 才允许 dpk1/dsc1=null）。

### 72b. 接图（阶段 C）清单 —— **只写清单，没动 shipped**
地基已在 shipped：FFN 半的融合已出货（`S6Fuse`/`s6_ffn_run`@713、"all six or none" no-op 规则@676-679、`NR_S6_TRACE`@683、`s6_pack_bexp_wide` WKey c=30001@694、`s6_pack_bproj_wide` c=10000+batchp@703）=> **CHAIN2 = 已出货 FFN 合一 + 一块新的 att 合一**。缺 9 条：
① 新 op `xmx_rec_att5_fused`（no-op 641-645，匹配器照 S6 规则）；② PGRAPH touch set 注册（读 1267/权重/bias/cos，写 1270；核内私有面不入图但 pool 要稳定）；③ **WKey：CHAIN2 不需要新键**（QKV = `cached_pack_b_i8(b,Braw,3C,C)`、proj = `(b,Wraw,C,C)` 现路已用同键）—— 风险只剩"匹配器把 FFN 的 wide 键与 split 的 batched 键混用" => **先跑 1301 再看门 + trace 打印四元组**；④ 稳定面：CHAIN2 **零新面**（1270 已有 id）；⑤ shipped 侧 **>=1000 连发** + 40 门 + 1301 金标（`DD49827D` / pre-skip `249A46F3`，基座 `tools/build_shipped.ps1`）；⑥ **只接 C=64 的 8 条链**（att C128 合一 +51% 更差、SLM 41,984 越崖，**不外推**）；⑦ 几何锁死不许动（T=32/LW=64/SLM 31,744/1020 WG，禁 LW=32、KN=0）；⑧ 收益用 `rt_per_closure.csv` 逐 op 复核；⑨ bench 层新腿一律带 barrier（军规 49）。
### 72c. 本轮新增军规候补（待我定稿入 B2）
- **50**：`DUMP=true` 的腿会多写约 90 MB 诊断面 => **计价腿一律 DUMP=false**，门用 DUMP=true 的那套过（同一 exe 两形态）。
- **51**：**哨兵自重复门比对的面集合必须等于该形态真正会写的面**（否则 DUMP-only tap 造成每发假 bad）。
- **52**：**台账 label 正则必须验"行数有没有增加"**（漏行不报错；本案 ffn3 三行被静默丢掉）。
- **53**：**任何 DUMP=true 的腿，tap 指针必须全非空**（nullptr => 设备 fastfail `0xC0000409`，且发生在 GATE GREEN 之后，极易误判为"门过了但跑不动"）。
- **54**：**生产者/折叠类改动必须在合成体里成对计价**——单腿最优不等于链最优（本案 R1 生产者 +0.11 ms 净亏；两半单独价 0.844 vs 合成 0.941，交接代价 0.10）。

## 73. ★ C-0 交回：**那 0.10-0.12 ms 不是 1270 的写->读依赖，也不该改 ffn2 的 P1 供数**；上一遍的 FFN2 双峰是**热漂移**
**做法**：先凉 300 s，再 **5 进程 x 60 s、全 DUMP=false、每进程 GATE GREEN**（exe `A6CA9F5D08E6F55DEB6748D5173F522C`，本批 3.4 min）。三条新判别臂：**`FFN2D`**（同一个 1a 核，输入换成早已写好的静态 1270 => 断开对 L1 出口的 RAW）、**`CHAIN2I`**（`L1n` + 无依赖腿 => **发数与网格完全相同，只去掉依赖**）、**`FFN2L`**（`FFN2` 在定价块最后再测一遍 = 进程内漂移探针）。
| 臂 | 均值 | spread |
|---|---|---|
| `REF13` | **1.4112** | 0.0039 |
| `REFA5`（att 5 腿） | 0.6435 | 0.0081 |
| `REFF8`（FFN 8 腿） | 0.7956 | 0.0035 |
| `L1n`（att 合一 1 发） | **0.4336** | 0.0053 |
| `FFN2`（1a 合一 1 发） | **0.3862** | 0.0036 |
| `FFN2D`（无 RAW） | 0.3866 | 0.0017 |
| **`CHAIN2I`（无依赖背靠背）** | **0.9414** | 0.0054 |
| **`CHAIN2`（有依赖背靠背）** | **0.9421** | 0.0092 |
| `FFN2L`（漂移探针） | 0.3866 | 0.0022 |
**三条结论**：
1. **`CHAIN2 − CHAIN2I = +0.0007`（纯噪声）=> 不是写->读可见性依赖**；把 FFN 腿输入换成静态 1270、完全断开 RAW，**一点没变快** => **不改 ffn2 的 P1 供数**，"让 FFN 半直接吃 L1 的 SLM 出口"这条路**被数据否掉，不必设计**。
2. **`L1n + FFN2 = 0.8198` vs `CHAIN2 = 0.9421` => +0.122 ms = 两发背靠背的相互干扰**（同一进程连跑两个 1020 WG / 31-32 KB SLM 的大核，L2、占用率、时钟爬升都不如各跑各的）=> **诚实外推只能用合成体自己的价**：`CHAIN2/REF13 = 0.6676` => **1.018 ms/链（落 chain48 1.525）/ 1.107 ms/链（落 8 链均值 1.658）** => **8 链 −4.06…−4.41 ms 串行 => 帧 −1.75…−1.90**（与 §74 一致）。
3. **§76 那遍 FFN2 双峰（0.49 vs 0.386）= 热漂移**：那遍跑在 ~55 min 连续 GPU 之后**没冷却**；这遍先凉 300 s => FFN2 稳 0.3862，且**进程内探针 FFN2L = 0.3866（同值）=> 无漂移**。**教训（P18/军规 45 的实例）：半链单独价与合成价必须在同一冷却状态下测，否则会造出一个假的"交接代价"**——我第一遍就差点把它当成依赖代价。
**军规 55（新）**：**背靠背大核的"相互干扰"必须用"无依赖对照臂"分离**（本案 `CHAIN2I`：发数与网格完全相同、只去掉 RAW）；不得把干扰当成依赖代价。**并且**：单独跑的腿价相加 != 背靠背价，**外推一律用合成体自己的价**（军规 54 的推论）。

### 73b. C-1 开工前勘察好的地基（**照 S6-1a 先例，不新造机制**）
- shipped 用 **header 装核体**：`#include "s6_ffn_block_kernel.hpp"`（@49，387 行，注释写明 "body VERBATIM from the byte-exact bench"）=> 新建 **`att5_fused_kernel.hpp`**（从 `s6b_att.cpp` 的 `namespace att5` 逐字抽出 `Shape/Outlets/fused<C,HEADS,PHASES,DUMP,LIVE>`）；
- 匹配器先例：`struct S6Chain`@541、`s6_on()`@556（`NR_S6_FFN` 默认 ON）、`s6_take_*`@575/592/617 逐级 stage 校验 + `s6_gap` 相邻检查、`s6_take_residual`@650 在最后一腿匹配时把前 5 个 closure 置 no-op、`g_s6_fires` 计数、`NR_S6_TRACE` record-time witness@683、**"all six or none"**@676-679；
- 权重键：`WKey{id,a,b,c}`@475 + `cached_pack_b_i8`@494；att 半两个 pack（QKV `3C x C`@3674/4087、proj `C x C`@4091）**现路已用同键** => CHAIN2 不需要新键，但按清单③在 trace 里打印四元组；
- 新开关 **`NR_ATT5_FUSE`，默认 0 = 现状逐位不变**；接图件只出 `builds\`；`out\libxmx.dll`(ABB969FE) 与三金标不动。

## 74. ★★ C-1 交回：**默认档自证逐位不变（1301 = `DD49827D`、passes 691、skip 计数一字未变）**；ON 档不逐位（82.6% 散）且图内慢 +4.4 ms/run ⇒ **停条件触发、按令交续跑包**；**根因已定位 = 我绑错 plan buffer + 图像 pitch 假设，不是核**
**做完的东西（bench 层 + 默认 OFF 的接线，未 commit）**：
- **`src/bench/sycl/att5_fused_kernel.hpp`**（42,540 B）= `s6b_att.cpp:87-617` 的 `namespace att5` **逐字抽出**（生成器 `s6/pe_mk_att5_hpp.py`；只把 bench 文件级 `using namespace sycl;` / `namespace esimd=` 搬进 namespace，**核体一字未改**）；先单独 probe 编译通过；
- `libxmx_sycl.cpp` +约 200 行：`struct A5Chain` + `a5_on()`（**`NR_ATT5_FUSE` 默认 0**）+ 五个 record-time hook（照 `S6Chain`/`s6_take_*`/`s6_gap` 先例，**四条腿全 no-op 或全不 no-op**）+ `a5_att_run()`（在 645 自己的 closure 里跑 `att5::fused<64,2,5,false,false>`，操作数全用现路 plan buffer、**零新面、零 pool_get**；权重走 `cached_pack_b_i8(wqkv,3C,C)` 与 `(wo,C,C)` = **与 split 腿同一个 WKey**）+ `NR_ATT5_TRACE` witness（fire 序号 / 几何 / 被 no-op 的 closure 号 / 两个 WKey 四元组 / **逐操作数 id+bytes**）；
- 变体件 `builds\libxmx_att5a.dll = 35F6FFEA`（干净版）-> `att5c/d/e/f/g`（诊断），**`att5g = BC28CE374D6AFEBD35F5EA94EBC16005`**。
**② 双档读数**（`walk.ps1 -Dll builds\...`）：
| 档 | passes | 1301 | 每 run 帧时 |
|---|---|---|---|
| **默认（不设 env）** | **691** | **EXACT = `DD49827D…`** | 58.02 / 58.27 / 58.43 ms |
| `NR_ATT5_FUSE=1` | 691（closure 数不变，与 S6 同口径） | **MISMATCH = `249A46F3…`（= pre-skip-1a 那颗）** | **62.71 / 62.84 / 62.85 => 慢 +4.4 ms/run** |
逐位差 = **82.635% 字节（6,904,834 / 8,355,840），第一个差异在 byte 0** => 不是末位漂移，是"输出换了来源"级别。**S6 没被破坏**：两档 `[s6-fire]` 都 40 行、样例一字不差 => FFN 半的既有融合不受影响。**fire 覆盖面**：8 条 C64 链只 fire 到 **2 条**（x2 次录制 = 4 行）。
★ **根因（`[a5-op]` 运行期逐操作数 id+bytes 实测）**：
`src1267 id=1303 bytes=66,846,720`（期望 4,177,920）、`out1270 id=1271 4,177,920` OK、`faceQ id=1308 4,571,136`、`faceK id=1307 33,554,432`、`faceV id=1309 4,571,136`（都不是 plane_want）；bias/scale/bscale/W 全 OK。
- **66,846,720 = 960 x 544 x 64 x 2（精确）** => **引擎的 1267 是整幅 960x544 的 f16 面**，而 bench 的 `dImg` 是 **136 x 240 x 64**；链的 M=32640 只覆盖子窗口网格，**行距 pitch = 960 而不是 240** => 融合核 P7 gather 与 P11 skip 按 `x + y*image_w` 寻址 => **读错像素** => 82% 全散；**这也解释了 `P(id,bytes,what)` 的下界校验为什么没炸：buffer 比需要的大**。
- **Q/K/V 三面也不匹配**：4,571,136 = 2 x (558 x 64 x 64) => **558 窗口**，而我们这条链是 **510 窗口** => **这些 id 属于另一条链 / 另一次录制的实例**（plan 首轮录制会把 buffer 建成 tiny placeholder、后续 resize => **id -> pointer 在运行期可能指向别的实例**）。
⇒ **结论：融合核本身没问题**（bench 里 25 检查点 0 差、0 bad / 2000），**错在 C-1 的 buffer 绑定与图像 pitch 假设**。

### 74b. ★ 新事实（对以后每一把接图铲都关键）+ 军规 56
**引擎面几何事实（实测）**：`1267` 类残差面在引擎里是 **整幅 960x544**（C=64 => 66,846,720 B），**pitch = 960**；bench 用的是 **链局部 136x240**（pitch 240）。**同一 id 的 buffer 在不同录制里可能 resize 成别的实例**（558 窗口 vs 510 窗口的 Q/K/V 面即为此例）。
**军规 56**：**接图前必须用运行期 `[a5-op]` 式的逐操作数 `id + bytes` 对账**，把每个操作数的 **bytes 与 pitch** 与 bench 假设逐项核对；**`P(id,bytes,what)` 只校验下界会静默放过"buffer 过大"**（本案就是）=> 校验要同时查 **bytes 上界 == plane_want** 与 **pitch/维度语义**，否则接图会把"读错像素"当成"核错了"。
**续跑包（下一条命令原样，按代价从小到大）**：① 给 `att5::fused` 加 `image_pitch` 参数（plan 侧 960、bench 侧 image_w），P7 gather / P11 skip 改 `base + y*pitch*C + x*C`；**bench 的 dImg 扩成 960x544 全幅 + 同 top/left**，然后**重跑 25 检查点门**（**不重跑门就不许再接图**）；② 核对 Q/K/V 三面在 `xmx_rec_gemm_int8_qkv` 里的真实尺寸来源（`g_bufs[q].bytes` 怎么算、`l0_ceil_bm` 之类）把 fragment 面对齐；**若必须另立私有面 => 违反清单④"零新面" => 停下回报**；③ fire 覆盖面：把 `a5-dbg` 的 40 行上限放大 + 对 8 条 C64 链逐条打 tuple，找出被挡掉的 6 条；④ 然后才是 自重复门（>=1000 连发，面集合按军规 51）-> 40 门 -> 帧 16 对。
**复现命令**：`tools/build_shipped.ps1 -Tag att5g`；`walk.ps1 -Dll E:\DSH\builds\libxmx_att5g.dll -Tag att5g_on -Runs 1`（前置 `NR_ATT5_FUSE=1 NR_ATT5_TRACE=1 SYCL_CACHE_DIR=E:\DSH\sycl-cache`）。
**安全边界**：`NR_ATT5_FUSE` 默认 0 且默认档已自证逐位不变（1301 = `DD49827D`、passes 691、`chains_skipped=14 refused=0 closures_noop=168` 一字未变）=> **这堆接线对现在的 shipped 零影响**；本轮 C-1 GPU 约 8 分钟（5 次 walk）。

## 75. ★ C-1 续（几何全表）：**"只 fire 2 条"的原因查明 = 匹配器只收 `pad=0 / across=30 / M=32640`，带 halo 的三种 C64 几何被挡**；**并且我 §74 的 pitch 归因被代理自己否证**（军规 56 保留，但这次的错不在那）
**件**：`builds\libxmx_att5h.dll = B9528F5D3567EF93A26E9D451A3DB2F2`（`a5-dbg` 上限 40 -> 900 + 每条 quant_window 一行 `[a5-geom]`）；**只跑一次 walk**（`NR_ATT5_FUSE=1 NR_ATT5_TRACE=1`，GPU 约 2 min）。
**① 全帧 104 条 quant_window 里，K=64 的 C64 族有四种几何**：
| M | across | pad | 结果 |
|---|---|---|---|
| **32640** | 30 | **0** | **只有这批 fire**（4 行 = 2 条链 x 2 次录制）|
| 35712 | 31 | 262148（top=4,left=4）| 被 `qw-REJECT M/K/geom` 挡 |
| 33728 | 31 | 4（top=0,left=4）| 同上 |
| 34560 | 30 | 262144（top=4,left=0）| 同上 |
reject 计数：**qw 100 / qkv 116 / wa 100 / wres 100，`wres-TUPLE` = 0 行** => **凡进到 645 的链，元组全部对上**（没有一条是在最后一步被挡的）。
⇒ **"帧价只兑现一半"的真实原因不是匹配器 bug，而是只覆盖了 pad=0 那批**；`att5` 核的 gather 参数里**已经有 `top/left`**（引擎 `qr_kernel` 的 gather 就是 `y = ... - pad_top`、`x = ... - pad_left` 同一套）=> **放宽到四种几何是参数活，不是改数值**。**要么放宽，要么只接 pad=0 那批并如实报只有一半。**
**② ★ 更正 §74：不是绑错面，也不需要 `image_pitch`**（代理自我否证，我采纳）：
- `[a5-geom]` 显示**所有** quant_window 的 `src/pk/sc = 1268/1273/1274` => **plan 在链之间复用同一组 scratch id（合法）**；
- 引擎自己的 gather 寻址 = `base = (y*image_w + x)*K`（`quantize_row_kernel.hpp:57`、`pack_device.hpp:641`）=> **行距就是传进去的 image_w（240），不是 960** => **bench 的 136x240 局部几何与引擎同语义** => **`att5::fused` 不需要 `image_pitch` 参数**；
⇒ **军规 56 的"上界也查"仍然要做**（它是对的通用规矩），**但 §74 里把 82.6% 归因到 pitch 是错的，现予更正**。
**③ 两条新尺寸事实（都是潜在陷阱，记下）**：`faceQ/faceV = 4,571,136 B = 35712 x 64 x 2` => **QKV 三面按全帧最大 M 订座（过订、安全）**；`faceK = 33,554,432 B = 960 x 544 x 32 x 2 = 2^25` => **K 面是整幅 960x544、32 通道的图像序面（不是 token 序）** => **融合核往它里写 fragment 序属于布局不符**；但 643 已被 no-op、无人再读 => **不能解释 82.6%**。⇒ **但这条要在接图时处理**：我们的"零新面"说法在这里其实是**把 fragment 序写进一张语义不同的现成面**（今天没人读，不等于以后没人读）。
**④ ON 侧 82.6% 碎块式数值差：根因仍未定**。**已排除**：绑错面 / S6 被破坏（两档 `[s6-fire]` 都 40 行、样例一字不差）/ wa 腿不等价（引擎 `wares::launch_wa_res(Q,K,V,dBv,Bp,Out,batches,heads,rawv2=true)`，rawv2 时 dBv 不被读 => 与 bench 的 `nullptr` 等价）。
**剩下头号嫌疑 = 642 的 qkv 腿**：默认档里 641 被 qfuse 溶解后 gather 由 642 自己做（`pack_a_fused_gather`@3669），但它接的是哪一版 qkv（`qres::gemm_qkv_res` 还是 @3662 那条 `dAp9b/Mp32` 变体）**还没读死**；**bench 用的是 `qres::gemm_qkv_res(..., false, nullptr)`**。
**下一刀**：把 642 的默认分支**逐行抄进 bench 的 REF** => **重跑 25 检查点门（门必须在改后的 REF 上过）** => 绿了再谈放宽四种几何 + 接图 + 自重复门；不绿就贴第一个偏差坐标停下。
**现场**：进程 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE** 未动；三金标未动；工作区只有诊断放宽 + a5-op witness（已随本条入库）；C-1 累计 GPU 约 10 min；**默认档仍自证 1301 = `DD49827D` + passes 691 => shipped 头零影响**。

## 76. ★★ C-1 收口（续跑包 §82）：**我提的"REF 不忠实"也被自我否证 ⇒ 82.6% 差仍未定因**；**覆盖面精确数完 ⇒ 现在可兑现的帧净值只有 ≈ −0.44 ms**（不是 −1.75/−1.90）
**① "把 642 的默认分支抄进 bench REF" => 逐参数对照后发现无差异可抄（我的假设否证）**：
引擎 `xmx_rec_gemm_int8_qkv`（3822-4136）默认分支：`pool_get(na)` -> `packdev::pack_a_fused_gather(*GQ, src, dAp, as, M, Mp, C, image_h, image_w, across, pad)`@3897（`NR_QW_FUSE` 默认 ON => 641 溶解）-> `qres::gemm_qkv_res(*GQ, dAp, dBp, Q, Kk, V, as, bs, qs, M, Mp, C, NH, heads, tokens, vit, vit_recip_tab())`@3920（`NR_QKV_RES` 默认 ON）。
bench：`qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS, M, Mp, C, NH, heads, TOK, false, nullptr)`。**唯一差别 = 末两个实参**；`qkv_resident.hpp:165`：`float recip = vit ? vit_recip_vec(hr, recip_tab) : wbv3::cosine_recip_vec(hr);` => **`recip_tab` 只在 `vit=true` 被读**，本链 flags 无 `0x2000` => `vit=false` => **`nullptr` 等价于 `vit_recip_tab()` => 642 忠实** ✓
（641/643/644/645 此前已逐条查过：643 引擎 `launch_wa_res(...,dBv,...,rawv2=true)` vs bench `(...,nullptr,...,true)`，rawv2 时 `dBv` 不被读@5101-5105 => 等价；644 溶解 = 645 里的 `pack_a_fused`@4137-4141；645 = `s8v8::gemm_b_res_window`。）
**② 覆盖面精确计数（host 离线，零 GPU）**：104 行 `[a5-geom]` 按 (K, M, across, pad) 计数（每帧录制两次 => 除以 2 = 链数）：
| tier | 几何 | 链数 |
|---|---|---|
| **C=64** | 32640/30/**pad0** | **2**（现在只有这批 fire）|
| | 33728/31/pad=4 | 2 |
| | 34560/30/pad=262144 | 2 |
| | 35712/31/pad=262148 | 2 |
| C=128 / 256 / 512 | 各 4 种 halo | 6 / 16 / 16 |
合计 **52 条**（8+6+16+16）= 104/2 ✓ => **C=64 的 8 条链 = 四种 halo 几何各 2 条，我只覆盖 pad=0 => 2/8**
⇒ **现在可兑现的帧净值只能写 ≈ −0.44 ms**（`0.509 ms/链 x 2 链 x 0.43`）；**−1.75…−1.90 是四种几何全覆盖之后的值**（§77/§81 口径已按此更正）。
⇒ 放宽本身是参数活（`top/left/across/M` 已是 `att5::fused` 入参，`qr_kernel`/`pack_a_fused_gather` 的 gather 就是同一套 `-pad_top/-pad_left`），**但顺序要求不变：K 面证据 + 门绿之后才做。**
**③ 尾巴 1（`faceK` 布局不符）= 未结，没靠推断糊过去**：plan 的 K 面 = `33,554,432 B = 960x544x32x2`（**图像序**），而 `att5::fused` P8 写的是 **fragment/token 序**；目前只有 `P(id,bytes,what)` 的**下界**检查通过。
下一刀两种做法都要留账：(a) 运行期读集证据 —— `rg -n "pgraph_ids|g_touch|NR_BPACK_TRACE" src/bench/sycl/libxmx_sycl.cpp` 找打印点 => `walk.ps1 -Dll builds\libxmx_att5h.dll -Tag att5h_touch -Runs 1`（前置 `NR_ATT5_FUSE=1 NR_ATT5_TRACE=1`）与默认档同打印对比；(b) 让 `a5_att_run` 先把 Q/K/V 三面 memset `0xA5` 再跑融合核、D2H 抽查 K 面是否只被写过一次。**若最终必须另立私有面 => 清单④"零新面"破了，如实写：新面 = 3 x 4,177,920 B（Q/K/V）+ pool 影响。**
**④ 82.6% 差的剩下两类嫌疑**：(i) **融合核在真实 plan 数据上触发了合成数据没触发的路径**（未测）；(ii) **K 面布局**（尾巴 1）。
**未验假设（代理自己明说）**：① "82.6% 是数值差而非取错地址"只依据碎块统计（**1,428,541 段、最长 71 B、平均 4.8 B**），**没做 f16 逐字段解码对照**；② "K 面在 ON 档无读者" = 推断；③ 真实数据路径差异 = 假说未测。
**现场**：进程 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE**；三金标未动；工作区只有诊断放宽（`a5-dbg` 上限 900、`[a5-geom]` 每 quant_window 一行、`[a5-op]` 逐操作数 id+bytes、witness 实参修正）；变体 `builds\libxmx_att5{a..h}`，最新 **att5h = B9528F5D**（`NR_ATT5_FUSE` 默认 0；默认档在 att5a 上自证 `1301 = DD49827D` + `passes 691`）；本轮 GPU ≈ 12 min，最后 25 min 纯 host。

## 77. ★★★ 破案：**ON 侧那 82.6% 从来不是数值错 —— 是我多推了一条 `g_cmd_names` => `NR_SKIP_CHAINS` 静默 REFUSED => 14 条链不再被跳过。修一行之后 `NR_ATT5_FUSE=1` 档 1301 = `DD49827D` EXACT**
**发现链（host 比对，零 GPU）**：`walk_att5i_on.txt` 里一行 `[skip-chains] graph=0 REFUSED: name offset 695 not a whole recording`，而默认档是 `closures=691 names=1382 name_offset=691 chains=52` => **name 向量比 closure 向量多 4 条 = 正好 4 次 fire**：A5 分支里又 `g_cmd_names.push_back(__func__)`，而 645 在 `pgraph_ids`/`flop_note` 处已经推过 => **错位 => 整套 skip 机构拒绝工作**。
★ **铁证**：`dumps/att5i_on.1301.bin` 与 `dumps/bk.1301.pre-skip-1a.bin` **逐字节完全相同**（8,355,840 B）=> 所谓"碎块式数值差"= **skip 配置没生效的旧状态**；**那个 +4.4 ms/run 的"变慢"也是同一件事**。
**修一行（`s6/pe_c1_namefix.py`：删掉重复的 name push）=> `builds/libxmx_att5j.dll = C3F926C226BD53E7B747C36216B3DF2F`**（下一铲的基座）：
| 档 | 1301 | 计数 | 每 run 帧时（同热）|
|---|---|---|---|
| 默认（不设 env，att5j_off） | **EXACT `DD49827D`** | - | 58.0-58.7 ms |
| **`NR_ATT5_FUSE=1`（att5j_on）** | **EXACT `DD49827D`** | **`chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`** | **58.02 / 58.26 / 58.70** |
⇒ **② 的双档自证两边都过**；fire 仍是 4 = 2 条链 x 2 次录制。另补跑 25 检查点门 3 进程（exe `A6CA9F5D`，间隔 60 s）：**3/3 GATE GREEN、fails=0、LIVENESS 三遍同值 1,158,095/4,177,920** ✓。
**军规 57（新，正式入 B2）**：**recorder 里任何"改写 closure 体"的融合，必须让 `g_cmds` / `g_cmd_names` / `g_cmds_touch` 三个向量逐位同长同序**。多推一条 name 会让 `NR_SKIP_CHAINS` **静默 REFUSED**，表现成"融合数值错了"的假象（**1301 不是乱码，而是等于某个历史 gold**）。**判据**：`[skip-chains]` 头部行的 `closures / names / name_offset` 在开关两侧必须相同。
★ **诊断签名（值得单独记，军规 32 的新变体）**：**"MISMATCH 等于某颗历史金标"= 配置没生效的指纹**，不是数值改动。本案 `att5i_on = 249A46F3`（pre-skip-1a 那颗）=> 当时就该先查 `[skip-chains]` 的 REFUSED 行，而不是去查核与 REF。**这一条省下的是"抄 REF"那一整铲。**
**两条尾巴状态**：① **`faceK` 布局不符：没结，但降级** —— 真相是 name 错位不是 K 面；不过 **touch 申报的必要性仍未单独证明**（att5i = 有 touch 无 namefix => pre-1a；att5j = 两者都有 => EXACT）。**下一铲做一次"只去掉 `pgraph_extra`"的 A/B**；按 §83 读到的语义（touch token = 设备指针、"same pointer in two closures = conflict (any direction)"、`(void*)-1` = 未注册 => 自己一个 wave），代理判断**申报是必需的**，但**这是推断，没跑对照**。
② **覆盖面**：已精确数完（§82-补）=> C=64 的 8 条链 = 四种 halo 几何各 2 条，现在只 fire pad=0 => **2/8** => **可兑现帧净值 ≈ −0.44**；**−1.75…−1.90 是全覆盖后的值**。**放宽是参数活（`top/left/across/M` 已是入参），门已绿 => 现在可以放宽。**

## 78. ★★★ ①+② 交回：**touch 申报不是必需的（已删，带 A/B 证据）**；**几何放宽成功 => 8 条 C64 链里 7 条 fire，两档 1301 都 `DD49827D` EXACT、skip 计数两侧一字不差；帧回放 ≈ −0.8…−1.5 ms/run**
**① `pgraph_extra` 必需性 A/B**（件 `builds/libxmx_att5k.dll = E97E9D81…`，新开关 `NR_ATT5_TOUCH`，其余与 att5j 一字不动；三档 walk 各 60 s 间隔；**先按军规 57 读计数再看 1301**）：
| 臂 | [skip-chains] | 1301 |
|---|---|---|
| ON + touch=1 | `closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0 closures_noop=168` | **EXACT `DD49827D`** |
| ON + touch=0 | **同上，一字不差** | **EXACT `DD49827D`** |
| 默认档（不设 FUSE） | 同上 | **EXACT `DD49827D`** |
⇒ **申报不是必需的 => 已删**（`s6/pe_c1_touchdel.py`），注释里留 A/B 读数与 caveat：**"这个 plan 里不需要"不等于"任何 tier 都不会重叠"**，将来若别的 tier 接融合，**先重跑这个 A/B**。
**② 放宽四种 halo 几何**（件 **`builds/libxmx_att5m.dll = 0FCF9C20B0204D7E626824423FE639F4`** = 当前基座；`a5_note_qw` 门槛从 `M==32640 && pad==0` 改成**四个 (M,across,pad) 白名单**；**核与数值一字未改**，`top/left/across` 本来就是入参）：
- **ON 档**：`1301 EXACT = DD49827D` ✓；`closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)` ✓（军规 57 三向量同长同序 ✓）
- **默认档**：`1301 EXACT` ✓、`fires=0` ✓、计数同上 ✓ => **开关两侧都逐位**
- **fire 普查**（`[a5-fire]` 按几何计数，14 行 = 7 链 x 2 次录制）：`32640/30/0` = 2 链 ✓；`33728/31/4 (top0,left4)` = 2 链 ✓；`35712/31/262148 (top4,left4)` = 2 链 ✓；**`34560/30/262144 (top4,left0)` = 1 链**（另一条被挡）=> **7/8 覆盖**
★ **第 8 条被挡的确切原因 = 不是 halo，是 epilogue 标志不同**：它的 645 窗口残元腿 flags = **`epi=0 narrow=0 half=1`**，而其它三种几何都是 **`epi=1 narrow=1 half=1`**；`att5::fused` 的 **P11 只实现 `epi=1 + narrow + half_skip` 一种出口形态** => **元组校验把它正确拒掉**（witness 原文：`[a5-dbg] wres-TUPLE cmd=56 a=1273 ... M=34560 N=64 K=64 epi=0 narrow=0 half=1 skip=1268 ... heads=2 batches=1080`）。
⇒ 要接它就得**给核加第二种 epilogue 形态 = 改数值面 => 不在本铲范围**。
★ **帧净值口径按 7/8 报：预期 `7 x 0.509 x 0.43 ≈ −1.53 ms/帧`**（不是 8/8 的 −1.75…−1.90）。
★ **实测帧回放（同热，run 1-3）**：**ON 57.29 / 57.40 / 57.36** vs **默认 58.09 / 58.23 / 59.09** => **约 −0.8…−1.5 ms/run** ✓ 与 7/8 预期同量级（walk 的 run0 含 JIT 冷启动，不计）。
**变体链**：att5j（namefix）-> att5k（touch A/B 开关）-> **att5m（当前基座：touch 已删 + 四几何放宽，两档 EXACT）**。本段 GPU 约 6 min（5 次 walk，均 60 s 间隔）。

## 79. ★★★ ③④⑤⑥ 交回：**A5 融合 = 帧 −0.978 ms（赢 15/16，CI95 [-1.186,-0.769]）= 够转正**；**新仪器 `NR_SELFREP`（引擎侧 1000 帧自比）过门 bad=0**；**⑥ 逐 op 对账严格吻合，并揪出一笔 +0.73 ms 的白工**
**③ 自重复门（shipped 件 + 真实 plan 操作数）**：`src/gpu/nr_replay.c` 加 **`NR_SELFREP=N`**（presence-gated；每帧后下载 buffer 1301（8,355,840 B）与**上一帧**逐字节比；**从第 10 帧起比**——plan 回放有跨帧 history，run0 vs run500 合法不同，稳态才是基准）=> `builds/nr_replay_sr.exe = 9FB2ED24…`。
**牙齿检查**（不带 SELFREP、默认档）：计数与 walk 完全一致、`SR_teeth.1301.bin` md5 = `DD49827D` = 金标 => 仪器忠实 ✓
| 臂 | fires | SELFREP |
|---|---|---|
| **`NR_ATT5_FUSE=1`** | 14 = 7 链 x 2 录制 | **`id=1301 runs=1000 compared=989 bad=0 first_bad_run=-1`** ✓（约 **7000 次融合 launch，0 bad**）|
| 默认档对照 | 0 | `runs=1000 compared=989 bad=0` ✓ |
**④ 40 门**（`run_gates.sh` 一字未改；先备份再 stage，跑完复原）：**变体 = 39 GREEN / 1 RED**，RED 是 `gate_skip_graph` 的**工件身份守卫**（要求 out 与 oneapi 都是 `ABB969FE`）——**它的实质子检查在变体下全过**（`gate40_p3: 691 passes`、`1301 dump 8,355,840 B`、**`1301 EXACT vs bk.1301.skip.bin`**）；**复原 `oneapi\libxmx_sycl.dll` = ABB969FE 后复跑 = GREEN（1/0）** => 诚实写法：**变体 39/40 + 第 40 门实质 EXACT（只有身份守卫按设计 RED）；基座复原后 40/40**。
**⑤ 帧 16 对**（A = `out\libxmx.dll`(ABB969FE) unset 全部 `NR_*`；B = `att5m` + `NR_ATT5_FUSE=1`；ab.ps1 v3，run0 丢弃、run1-3 中位）：
deltas: `-0.670 -0.470 -1.440 -1.080 -1.150 -0.810 -1.200 -1.030 -1.090 +0.040 -1.580 -1.160 -1.290 -1.030 -0.700 -0.980`
**n=16 mean −0.978 sd 0.392 CI95 [-1.186,-0.769] 赢 15/16**，每对 `passes 691/691` => **判据（<=−0.5 且 >=10/16）过 = 可转正**
⇒ **现在可兑现 = −0.98 ms/帧（7/8 链）**，**不是** 8/8 的 −1.75…−1.90。
**⑥ 逐 op 复核**（件 `builds/libxmx_rt2a5.dll = F6620510…` = RUN_TIMING + A5；两臂各 691 行 rtcsv）：
| closure | 默认 | ON | Δ | 行数 |
|---|---|---|---|---|
| `xmx_rec_window_attention` | 16.48 | 13.30 | **−3.18** | 52 -> 45 |
| `xmx_rec_gemm_int8_qkv` | 14.55 | 12.58 | **−1.96** | 60 -> 53 |
| `quant_window(FUSED-pack)` | 0.12 | 0.10 | −0.02 | 52 -> 45 |
| `xmx_rec_gemm_window_int8_residual` | 12.98 | **14.07** | **+1.09** | 52 -> 52 |
| `xmx_rec_quant` | 3.65 | **4.38** | **+0.73** | **80 -> 87** |
| 三条 no-op 行（A5-fused） | - | 0.02/0.01/0.01 | ≈0 | 0 -> 7 each |
| **TOTAL** | **135.98** | **133.68** | **−2.30 ms 串行/帧** | |
**对账**：`−2.30 x 0.43 = −0.99 ms/帧` 与 ⑤ 的 **−0.978** 严格吻合 ✓；融合后那条 wres ≈ **0.40 ms/链** 与 bench `L1n = 0.4336` 同量级 ✓
★ **白工（下一铲的钱）**：`xmx_rec_quant` 80 -> 87 行、+0.73 ms => 那 7 条链的 **644 QUANT 从"FUSED-pack 溶解态"退回成真发**——**645 里 `return 0` 太早，跳过了 `fused_w`/`g_fused_quant` 的 fold 登记（@4137-4141）** => 644 白做一次量化（约 0.104 ms/链）。**修法 = A5 命中时补上该链 644 的 fold 登记（或显式 no-op c_q2）= 纯登记活、不改数值 => 预计 +0.31 ms/帧。**
**剩余站排序**：⑴ 捡 644 白工（+0.31，登记活）；⑵ 第 8 条 C64 链（`epi=0 narrow=0`，要给 P11 加第二种 epilogue => 改数值面，代价另评）；⑶ **C128 tier 不接**（att 合一 +51%、SLM 41,984 越崖）。

### 79b. ★★ 我（主会话）的一次实操错误 + 两条新军规（59/60）
**错误实录**：06:3x 我按 ⑤ 的读数把 `att5m` 部署进加载位，**随即发现 `a5_on()` 的默认值是 0**（`libxmx_sycl.cpp:785`：`getenv("NR_ATT5_FUSE") ? atoi(...) : false`）=> **光换 dll 不生效**（16 对是在 B 侧设了 env 才赢的）。**已当场退回 `ABB969FE`**（备份 `out\libxmx.before-ATT5.keep`），并在 `out\DEPLOY.md5.txt` 补了更正；`att5m` 留在 `builds\` 当基座。
**军规 59**：**开关默认 OFF 的件，部署进加载位 = 不生效**。**转正前必须把开关固化成编译期默认**（照 `tools/shipped_build.defs` 里 `T_SKIP_CHAINS_DEF` 的先例，加 `T_ATT5_FUSE_DEF`），并且**换位后要做三件核验**：① `out\libxmx.dll` 与 `oneapi\libxmx_sycl.dll` md5 一致；② 该件在**不设任何 env** 时的 `[skip-chains]` / `fires` 计数就是预期档；③ 帧收益的 A/B 两侧都不依赖 env（ab.ps1 会清场）。
**军规 60（军规 31 的加强版，新仪器）**：**引擎侧自重复门 `NR_SELFREP=N`** —— 同一进程连放 N 帧，每帧下载 `1301` 与**上一帧**逐字节比，**从第 10 帧起比**（plan 回放有跨帧 history，run0 vs run500 合法不同），要求 **bad=0**。本案 `runs=1000 compared=989 bad=0`（约 7000 次融合 launch）。**任何新接入的融合腿都要过这一门**（bench 的 200/1000 连发只测单核，测不到图内真实操作数与跨帧状态）。

## 80. ★★ 两条尾巴**用证据结案**（不是推断）+ 644 白工机制读死 + 我的处置令
**① 新仪器 `NR_PG_TOUCHDUMP`**（`pg_push` 里 presence-gated 打印每个 closure 的 touch 指针表；无设备副作用、不加 op，军规 4/9）+ `[a5-op]` 补 `ptr=%p` 探针 => 件 `builds/libxmx_att5n.dll = 6E01CBEB…`；**开诊断后 ON 档仍 `1301 EXACT = DD49827D`** => 诊断不改变行为 ✓；读数 `[pgt] 1382 条 = 691 x 2 录制`（**军规 57 再次成立**）。
| A5 操作数（运行期地址） | touch 表包含该地址的 closure 数 |
|---|---|
| src1267（66,846,720 B） | 200 |
| out1270（4,177,920 B） | 28 |
| faceQ | 308 |
| faceK | 266 |
★ **正解已写进源码注释（`libxmx_sycl.cpp:118-122`）**：**touch token = 设备指针；同一指针出现在两个 closure = conflict（任意方向）；`(void*)-1` = 未注册 op => 自己一个 wave** => **"很多 closure 摸同一地址" = PGRAPH 把它们强制串行化（保守调度），不是"有人按别的布局读走我的数据"**。
⇒ **K 面 / pk2-sc2 没有语义风险**；`pgraph_extra` 不申报也不会读到脏数据（与 ① 的 A/B 一致），只是少一层重叠约束；实测再兜一层：ON 档 1301 EXACT（两次录制）+ `NR_SELFREP=1000` 相邻帧逐字节 0 bad。
⇒ 另留一笔：**id 不是地址，不能靠 id 推断**（这正是军规 57 那类坑的根）。
**② 覆盖面定死 = 7/8**：第 8 条 C64 链的 645 腿是 `epi=0 narrow=0 half=1`，超出 `att5::fused` P11 的唯一出口形态（`epi=1 + narrow + half_skip`）=> 接它 = 改数值面 => **冻结**，只在账里留"代价另评"；**C128 tier 不接、不外推**（att 合一 +51%、SLM 41,984 越崖）。
**③ 644 白工机制读死（纯 host）**：642 的 qkv 折叠在**运行期**登记 `g_fused_quant[c] = a_scale`（@3670，在 `pg_push` 的 body 内）；644 的溶解也是**运行期**判断（body 查 `g_fused_quant.find(source)`@6217-6218）；**A5 命中 => 642 body 被 no-op => 登记不再发生 => 644 查不到 => 退回真发量化** => +0.104 ms/链 x 7 = **+0.73 ms 串行 ≈ 0.31 ms/帧**（`xmx_rec_quant` 行数 80 -> 87 佐证）。
⇒ **顺带否掉一条错修法**：在 645 的 **record 期** no-op `c_q2` 救不回来——**溶解决定发生在运行期，那时 map 已经空了**。
⇒ **正解一行**：`a5_take_wres()` 里补 `g_fused_quant[g.att] = a_scale;`（拷共享 scratch、PGRAPH 按地址已串行化、且这条溶解本来就是 45 条链的 shipped 默认行为）。

### 80b. 我的处置令（已发给代理，时间盒 3 小时）
① **捡 644 白工**，三个必验：**`xmx_rec_quant` 行数 87 => 80**（这一刀的唯一指纹）、双档 1301 都 `DD49827D` EXACT + 军规 57 三向量计数两侧一致、`NR_SELFREP=1000` bad=0；
② ★ **把 A5 固化成编译期默认 ON**（`T_ATT5_FUSE_DEF`，照 `T_SKIP_CHAINS_DEF` 先例；出处写进 `out/SHIPPED_BUILD.md`）——**不做这步，转正就是假的**（我今天 06:3x 就是这么栽的，军规 59）；**逃生门 `NR_ATT5_FUSE=0` 仍逐位等于旧行为**（两档都 EXACT => 金标不换，好性质）；
③ **40 门 + 帧 16 对复测（B 侧不设 env，靠编译期默认）**：判读 **<=−1.0 且赢 >=10/16 = 我当场转正**；落在 −0.6 以内 => 停下归因。
**另记一笔我自己的失误**：我先前两次工具调用写坏了（把消息发成 placeholder），**那两条指令没送达**；代理靠自己把机制读死并结案了两条尾巴——**结果比我的指令更好**，但流程上我要认：发令后要确认送达。

## 81. ★★★ ①②③ 全交回：**帧 −1.251 ms/帧、赢 16/16、CI95 [-1.352,-1.151] = 达"当场转正"判据**；五项核验（指纹 / 双档 1301 / SELFREP / 40 门 / 出处）都到手
**① 捡 644 白工：改法比 §92 提的更对（代理自己查出并换掉）** —— **没用 `g_fused_quant[g.att]=a_scale`**：查 @6227-6235 的溶解分支会发现它会 `memcpy(pk, a, M*K)` **把 f16 的 1277 当 int8 拷进共享 scratch 1273/1274 => 危险**。
**改用 shipped 既有机制**：645 正常路在 **@4386** 调 `qfuse_take(a, a_scale, M, K, qfw)`，而 `qfuse_take`@362-376 的动作正是 `g_cmds[out.qcmd]=[](){}; g_cmd_names[out.qcmd]="quant(FUSED-pack)"` => **A5 分支提前 return 把它跳过了**。
**补丁** = 在 `if (a5fire) {` 内补 `QuantFused qfw5; qfuse_take(a, a_scale, M, K, qfw5);`（`s6/pe_c1_fold2.py`）。**注意：先有一次 att5o/rt2o 是锚点没对上的空枪 => 别用它们的读数**（军规 14 再应验）。
| 核验 | 读数 |
|---|---|
| **`xmx_rec_quant` 行数（唯一指纹）** | rt2o2 两臂各 691 行 rtcsv：默认 **80**、ON **80**（**改前 87**）✓ => ON 总账 **133.68 -> 133.05（−0.63 ms 串行）**，与预测 +0.73 同量级 ✓；**跨 build 的 off 总数（135.98 vs 140.12）不可比，只用同 build 的 off/on 差** |
| 双档 1301 + 军规 57 | 默认 `FOLD_off.1301.bin` = **`DD49827D` EXACT**；ON `FOLD_on.1301.bin` = **同一颗 EXACT**；两侧 `[skip-chains]` 一字不差；fires 默认 **0** / ON **14** |
| `NR_SELFREP=1000`（军规 60） | **三臂 x 1000 帧跑完、相邻 989 次比对/臂 => 3000 帧、约 21,000 次融合 launch，bad=0** ✓ |
⚠ **一次未复现的异常（如实记）**：第一次跑出现 **run 528 的 `0xC00000FD`（栈溢出）崩，三次复跑都没再现** => 记为**未复现的工具侧异常**（SELFREP 每帧多下载 8 MB，run 时长 85 ms vs 裸跑 57-58 => 仪器自身有负载；**SELFREP 的时间数不作帧价**）。**若再复现 => 按军规 47 当真竞态处理。**
**② 固化成编译期默认 ON（军规 59）**：`a5_on() => getenv("NR_ATT5_FUSE") ? atoi!=0 : (T_ATT5_FUSE_DEF != 0)`，源码带 `#ifndef T_ATT5_FUSE_DEF => 0`（**bench/其它构建不带宏仍默认 OFF**）；`tools/shipped_build.defs` 加 **`T_ATT5_FUSE_DEF=1`** + 出处注释；build 行实到 `/DT_SKIP_CHAINS_DEF="18,...,32" /DT_ATT5_FUSE_DEF=1`；件 **`builds/libxmx_att5p.dll = 3BAECF2A4B0F49F45E2557CE4808C2CF`（3,912,704 B）**。
- **不设任何 env**（只开 `NR_ATT5_TRACE` 取 witness）=> **`fires = 14`（7 链 x 2 录制）** ✓、skip 计数不变 ✓、**1301 EXACT `DD49827D`** ✓、run 57.11/57.12/57.10 ms
- **逃生门 `NR_ATT5_FUSE=0`** => `fires = 0` ✓、计数不变 ✓、**1301 EXACT** ✓、run 58.28/58.14/58.22 ms
- 出处写进 `out/SHIPPED_BUILD.md` §6（basis = ABB969FE 基座 + commit `d64fa0f` + 工作区未 commit 的两处改动 + `/D` 全串 + 件 md5 + 证据 + "换位后再跑 40 门求 40/40"）=> **我已把 `notes/SHIPPED_BUILD.md` 复制进仓**（`out\` 那份保留）
**③ 40 门 + 16 对**：40 门（stage att5p -> 跑 -> 复原）= **39 GREEN / 1 RED**，RED = `gate_skip_graph` 的**工件身份守卫**（只认 ABB969FE 在 oneapi 槽；其实质 1301 检查在变体下 EXACT）；复原后单跑该门 **GREEN（1/0）** ✓
**帧 16 对（A = `out\libxmx.dll`(ABB969FE)，B = `att5p`，两侧都不设 env）**：
`deltas: -0.840 -1.650 -1.370 -1.220 -1.100 -1.190 -1.180 -1.230 -1.190 -1.120 -1.380 -1.370 -1.220 -1.090 -1.360 -1.510`
**n=16 mean −1.251 sd 0.188 CI95 [-1.352,-1.151] 赢 16/16**，每对 `691/691` => **达"当场转正"判据（<=−1.0 且 >=10/16）**；比上一铲 −0.978 改进 **−0.273 ms**，与捡白工预测 +0.31 吻合 ✓；**sd 0.392 -> 0.188**（同热更稳）；**CI 只覆盖同热重复性，不含跨盒热漂移**。
本盒 GPU 约 **59 min**（① 16 + ② 5 + ③ 38，批间 >=60s、>20 min 批后已冷却）。


## 82. ★★★ **转正完全干净：全量 40 门 = 40 GREEN / 0 RED（跑在转正件本身、加载位、不 stage 不复原）**
`bash E:/DSH/run_gates.sh`（前置 300 s 冷却，上盒 GPU ~60 min）尾部：
```
GREEN gate_gemm_int8
GREEN gate_coexist
GREEN gate_skip_graph          <-- 新守卫（读 out/SHIPPED_MD5.txt）现在 GREEN
gates: 40 GREEN / 0 RED
```
**跑完槽位复核（没被动过）**：`out\libxmx.dll` = **`3BAECF2A…`**；`oneapi\libxmx_sycl.dll` = **同一颗** ✓（军规 59 ① 保持）；`out/SHIPPED_MD5.txt` = `3baecf2a4b0f49f45e2557ce4808c2cf` ✓（守卫的单一出处）；回退点 `out\libxmx.before-ATT5.keep` = **`ABB969FE…`** ✓（另有 `builds\libxmx_sycl_ABB969FE.bak{,2}.dll`）。进程 0。
**军规 62（采纳代理建议）**：**身份守卫必须读单一出处，不许写死常数** —— 写死会让每次转正都产生一个"按设计 RED"的门，**把实质检查淹掉**，还会让人误判"变体没过 40 门"。

### 82b. ★ 转正件上的**逐 op 新底账**（`NR_RUN_TIMING`，691 行，**总串行 114.63 ms**；对比 A5 前同族 135.98）
`gemm_int8_residual 20.06 (68) / window_block 18.19 (10) / global_attention 11.48 (8) / gemm_window_int8_residual 11.36 (52) / window_attention 10.19 (45) / gemm_int8_qkv 9.65 (53) / gemm 7.03 (42) / ffn 6.24 (8) / int8_batched 4.86 (72) / quant 2.72 (80) / unary 2.96 (16) / quant(FUSED-pack) 0.38 (144) / quant_window(A5-fused) 0.03 (7)`
**att 半区按 tier（串行 ms/帧）**：**C256 13.39 > C128 10.56 > C64 5.46（含 7 条融合 launch 自己在 wres 里的 3.75）> C512 1.76**。
**A5-fused 覆盖 = chains 0,1,2,48,49,50,51（7 条）** ⇒ **C64 里唯一没接的是 chain 3**（就是 `epi=0 narrow=0` 那条）✓
★ **一条要紧的张力（下一铲要正面回答）**：**剩下的钱最大的两块（C256 的 13.39、C128 的 10.56）恰好是我们融合形态装不下的 tier**（C128 合一在 bench 里 **+51% 更差**、SLM 41,984 越占用崖）。
⇒ 所以"接更多 tier"不是开关活，而是**tiling/几何活**：要么**把 T（每 WG token 数）降下来换 SLM**、要么**把窗口切小换 across** —— 两者都会改变网格与复用因子，**必须先按 `tools/xmx_roof.csv` 的 (dtype,N,K,M) 屋顶成对实测，再谈接图**（军规 26/35a/37/54）。


## 83. ★ WB 驻留重做 (a) 交回：**靶子重新钉小 = 只有 2 个 closure 走 45,056 B 的 `wbv4ph`（活站价值 8.52 ms 串行，占家族 47%）**；SLM 预算 12,288 B **数值上正好闭合**；三条前置 = **两条过、一条 PARTIAL（不掩盖）**
**① 靶子更正（重要）**：plan 里 `OP_XMX_REC_WINDOW_BLOCK` 20 步 = 2 次录制 x 10；按 flags 分路（`s6/pe_wb_census.py`；解码 @5391-5409：pooling=0x800000、head=0x1000000、narrow=0x1000、epi=(f>>8)&0xF）：
- **走 `wbv4ph::launch_v4ph`（SLM 45,056 B）的只有 2 条/帧**：`v4ph(pool)` 8160 窗 544x960 across120、`v4ph(head)` 8349 窗 across121 pad262148；
- 其余 **8 条是 non-pool/head（2040-2135 窗、272x480）=> 不是这个核**；
⇒ **转正件逐 closure 实测**（`NR_RUN_TIMING`）：**`c1 = 4.243 ms`、`c690 = 4.278 ms` => 两条巨人 = 8.52 ms 串行 = 家族 18.19 ms 的 47%**；另 8 条各 1.16-1.28 ms。**这一铲的活站价值 = 8.52 ms（2 个 closure/帧），不是 18.19。**
**② 前置 1 `barrier_audit` 两栏**（`tools/barrier_audit_wb.csv` 38 行，**退出码 0 = 反证两例通过、仪器有牙** ✓）：`wbv4ph::launch_v4ph`（WG=1/SG=16）= **verdict_source OK / verdict_machine PARTIAL**（旧账 2026-11-02：`.text` 里 18 条 signal barrier，**没做逐字节对照**）；`wbv4::launch_v4full`（WG=1/SG=13）= OK / PARTIAL（15 条）。
⇒ **诚实读数：source 栏干净，machine 栏没清账**；处置 = (b) 里补做（改完源码重跑 audit + 台账 simd/module_id 去重 + 新旧 `.text` 的 barrier 计数与逐字节对照）；**machine 栏补清之前不出 `builds\` 变体**。
★ **结构事实**：v4ph **全核只有 1 条 WG 栅栏**（line 202，注释自陈 "KTO/VPO shared for P3/P5"），其余 16 条都是 SG 级 `esimd::barrier()` => **跨 SG 交接只有 KTO/VPO 两处，且都被这条 WG 盖住**。
**③ 前置 2（只用拆槽/挪相）**：✓ **KTO 与 VPO 显式标 `KEEP + 拒绝在 P6/P7 复用`** —— 现有那条 WG 栅栏在 **P3 读之前**，把这两个槽挪给 P6 用就**必须新增一条 WG 栅栏** => **直接不采纳**（这正是 §40/§41 当年 RACE_REUSE 的形态）。
**④ 前置 3（军规 30 逐段：writers / readers / overlap 三列都在表）**：**12,288 B 由两段独立凑齐**：
1. **−4,096：`AQO` 让位给 `ATO`** —— AQO（P0 写、P1/P2 读，写读都在 `+sgid*1024` 自己的片 => **SG-local**）P2 之后死；ATO 只在 P6 活、同样 SG-local => **不需要任何新栅栏** ✓
2. **−8,192：`SCR` 的 per-SG 高水位 4,096 -> 2,048** —— 每 SG 的 scores 块 = 16 行 x 64 列 x 4 B = 4,096（@237/238）；**把 P3/P4/P5 拆成两个 8 行半块** => 2,048/SG => 4 SG 省 8,192；**SCR 每次使用都写死 `+ sgid*SCR_SG` => 全程 SG-local => 拆槽不引入跨 SG 语义** ✓
⇒ **45,056 − 12,288 = 32,768** ✓（`tools/wb_slm_budget.csv` 7 段列和已 python 复算：45056 -> 32768，delta 12288，unparseable = 0）
★ **核里已有先例**：`scrC = S_PPO + sgid*2048`（line 71 注释 **"scrC aliases the PPO head, dead until softmax"**）=> **拆槽/挪相本来就是这个核的既有做法**。
**⑤ 三条风险（都写进表）**：⑴ **两段缺一不可**：只做第 1 段 = 40,960 够不到 32,768 => **停下回报，不算部分出货**；⑵ **第 2 段有真实反噬风险**：热相（P3 scores / P4 softmax / P5 attnV）循环翻倍、dpas 累加器从 `simd<float,64> x 4` 变两半的 `simd<float,32> x 4` => **v9b 教训（每线程累加器进 >8 惩罚区）说这可能把驻留收益吃掉** => (b) 必须**三态成对计价**（现档 / 新档 / 新档+拆槽），**不拿单核价外推家族价**（军规 54/55）；⑶ **历史兑现率只有约 9%**：上限 −3.9 ms 串行 vs 实测 −0.365（32 对）=> occupancy 之外还有更强限制（D2H/全局带宽或 wave 划分）=> **(b) 之前不给帧值承诺**。
**零 GPU**（本铲至今只跑了 40 门 12 min + RUN_TIMING 2 min，均在上一盒）；新产物 `tools/wb_slm_budget.csv`、`tools/barrier_audit_wb.csv`、`s6/pe_wb_census.py`、`s6/pe_shipped_rt_read.py`、`s6/RT_shipped.timing.txt`。

## 84. ★ (b1) 交回：**机器级 PASS（barrier 条数 18 -> 18 一字不差）**；state-2 只到 **40,960**，state-3 未做 => **照预登记判决线 3 当场停，(b2) 未跑**
**补上 2026-11-02 缺的那件仪器**：
1. `s6/pe_mk_wbslm.py`：从 **shipped 头逐字复制** 出 `src/bench/sycl/wb_v4ph_slm.hpp`，**只改三处**（namespace `wbv4ph -> wbv4phS`、region 常量按 `WBS_STATE` 选表、`esimd::slm_init<WBS_SLM>()`）=> 文本 diff 就这几行，**barrier 调用点 17 = 17**；
2. `src/bench/sycl/wb_slm_stub.cpp`：只实例化核的 codegen stub（`stop_stage=0xFFFF` => 核第一行 return、指针全假 => **不执行任何访存**），跑一次只为把设备码写进缓存（两次约 20 s，**不是测量**）；
3. `s6/pe_wbs_text.py`：按 ELF 段表从 JIT 缓存切出**本核 `.text`** 逐字节比；
4. `s6/spillcheck_wb.py`（放宽 label 版，`s6/pe_wbs_ledger.py` 驱动）=> **拿到 ocloc 反汇编的 `.text....launch_v4ph....asm` 并数 `signal barrier`** —— 这就是当年 PARTIAL 缺的东西。
| state | grf | simd | **slm(B)** | spill/private/scratch | asm 行数 | **signal barrier** |
|---|---|---|---|---|---|---|
| **1 现档（shipped 布局）** | 128 | 1 | **45,056** | - | 3,485 | **18** |
| **2 仅 `AQO->ATO` 别名** | 128 | 1 | **40,960** | - | 3,487（**+2 行**）| **18** ✓ |
★ **判决线 1 的硬要求满足：barrier 18 -> 18 => 没有新增栅栏**（前置 2 在机器级成立）；
★ **ELF 段级对照**：18 段里 **14 段逐字节相同**，只有本核 `.text`（46,400 -> 46,592，**+192 B**）、`.symtab`、`.spv`（369,200 -> 369,076，−124 B）、`.ze_info` 变 => **不是"整核重写"**；`.text` 差异 = **5,911 段、最长 87 B、中位 3 B** => **正是 SLM 立即数重编码的形状**（+2 行 asm / +192 B 属寻址再折叠，不是栅栏）✓
★ **仪器互证很干净**：`barrier_audit.py` 跑改后源码（`BARRIER_SRC=E:\DSH\tmp\wb_slm_shadow`）=> **所有区段 verdict_source = OK、WG=1/SG=16 不变**；而它自带的反证用例正是 **"故意 ATO->S3 => RACE_REUSE（KTO 跨 SG 读到 P3，更晚 ATO 在 P6A 写同一区域，之间没有 WG 栅栏）"** => **§102 里"拒绝复用 KTO/VPO 槽"的判断与仪器反证同形 => 不是事后找理由。**
★ **一条物理判断（代理给的，我采纳）**：**40,960 这一档单独进图没有意义** —— occupancy 仍 > 32,768 => **resident WG 不会 1 -> 2 => 判决线 4 注定不满足** => 所以 (b2) 若只跑两态，测出来的最多是"寻址变短的噪声价"，不会给出可转正读数。
**本铲 GPU 约 40 s（仅两次 JIT 触发，零测量）**；产物：`tools/wb_slm_budget.csv`、`tools/barrier_audit_wb_slm.csv`、`s6/{pe_mk_wbslm,pe_wbs_srcdiff,pe_wbs_text,pe_wbs_ledger,pe_wbs_dis2,spillcheck_wb}.py`；工作区新增两个未跟踪 bench 件（`wb_v4ph_slm.hpp`、`wb_slm_stub.cpp`）已随本条入库。

## 85. ★★★ (ii) 交回：**WB 驻留铲按"物理判死"收 —— 这两发已经贴在我们自己测到的同形 compute anchor 上；不是带宽限制（3-6%），occupancy 也不是主限制**
**靶子**：`c1 = v4ph(pool) 4.243 ms`、`c690 = v4ph(head) 4.278 ms`（走 45,056 B 那个核的全部 = 2 发/帧）
**① 读放大**：pool 的窗口网格 **68 x 120 个 8x8 = 522,240 像素 = 544 x 960** => **放大 1.000（完美平铺，没有重叠）**；head = 69 x 121（含 top4/left4 halo）=> **1.023**
**② DRAM 流量**：输入 = windows x 64 tokens x 32 ch x 4 B = **66,846,720 B**（c1，**正好等于 1267 面，与 [a5-op] 实测一致** ✓）；输出：pool `narrow=0` => **再写一个整幅 f32 面 = 66,846,720 B**；head => 紧凑面 **8,355,840 B**。
⇒ **c1 合计 133.7 MB / 4.243 ms = 31.5 GB/s**；**c690 76.8 MB / 4.278 ms = 17.9 GB/s**
⇒ 对照我们自己的带宽实测（`notes/census-knifeB-2026-11-01.md` 的 bare **560 GB/s** nominal、`notes/section100-blueprint.md` 的 **446 GB/s** = 带宽贴顶）=> **这两发只用到 3.2%-5.6%**；**把权重流全按 miss L2 算**（8,192 B/窗 => +66.8 MB）也只到 **47/33 GB/s ≈ 10%** => **带宽判死：不是带宽限制 ✓**
**③ compute**：每窗 MACs = QKV 64x96x32 + scores 64x64x32 + attnV 64x32x64 + outproj 64x32x32 = **524,288**（head 再 +64x16x32 = 557,056）=> **c1 = 8.556 GFLOP => 2.02 TFLOP/s**；**c690 = 9.298 GFLOP => 2.17 TFLOP/s**
**④ 屋顶对照（军规 26：只用同形点、不外推）**：`tools/xmx_roof.csv` 里**有同 M/N/K 的 f16 点**：`M=64 N=64 K=32 b=320` => `gemm_b` **0.75**、`gemm_b_pub_f16` **1.31** TFLOP/s；`M=64 N=32 K=64 b=320` => **2.20 / 1.84**（batch 不同 => 只当锚点）
=> **融合块实测 2.02-2.17 = 贴在这些同形锚点的最好值上** => **它的 gemm 部分已经和我们测过的最快拆腿 f16 gemm 一样快**；而 A770 聚合上限（表里 int8 大形状实测 **41 TFLOP/s**）离它 ~20 倍 => **"离硬件顶很远"但"离这些 tile 形状的可达成速率已经到顶"**
**⑤ occupancy**：台账 **grf128 / simd1 / slm 45,056 / 无 spill private scratch** => 每 EU 1 个 resident WG；**32,768 是第二个能住下的门槛**
★ **三态结论**：**不是 bandwidth-bound（3-6%）+ occupancy 不是主限制（compute 已贴同形锚点）+ 剩下的解释是"单个 WG 内的 issue/dependency"** => **把 resident 从 1 抬到 2 并不解开这个结**。
★ **与历史数据自洽（这就是"当年为什么只兑现 9%"的答案）**：§40 那次已经把 SLM 做到 32,768、实测 **−0.365/32 对** vs 串行上限 −3.9 ms => 兑现 ~9%；**若真是 occupancy-bound，9% 说不过去；若不是，9% 正是应得的数** ✓
**建议**：**(i)（半块拆分换那 8,192 B）不做** —— 它买的是一个**不 binding 的旋钮**，代价却是 dpas 累加器形态改动 + v9b 的 >8-acc 惩罚区（medium-high）。**这一铲按判死收，但判死的理由是物理（limit 分析），不是"没到 32,768"。**
**保留的正面产出**：`tools/wb_slm_budget.csv`（12,288 B 的两段来源 + 逐段军规 30 判定）+ (b1) 的机器级仪器（**barrier 18->18、14/18 段逐字节相同、.text 差异中位 3 B**）——**这套仪器通用，下一铲任何 SLM/别名手术直接复用**。

### 军规 63（新，正式入 B2）：**SLM / occupancy 类手术之前，先算两件事：同形 compute anchor 与 DRAM 占比**；两者都不 binding 就别动 SLM。
本案：c1/c690 的 DRAM 只占实测带宽 3.2-5.6%（按 miss L2 算也只 10%），compute 已贴 `xmx_roof.csv` 同形锚点的最好值（2.02-2.17 vs 2.20）=> occupancy 1->2 不解结 => 历史兑现率 9% 正是应得数。
★ **推论（下一铲的方向）**：**window_block 这两发要再快，只能换 tiling/复用因子**（更大的 N/K 复用、把窗口合并成宽 M），**不是调 SLM** —— 而这正好落在"换序墙"（军规 42/43）的射程里：**胖形状需要记录/计划层把同形腿排到相邻**。

## 86. 换序墙（候选 5）最小机制清单交回 —— **四层 + 六条判据，不写收益预测**（全文 `notes/reorder-wall-checklist.md` §105）
**① recorder 的邻接/依赖标注（不是执行层）**：现只存设备指针集（`g_cmds_touch`@123-143、`pgraph_ids`@127、`pgraph_extra`@135、`pg_push`@140，语义 = "同址即冲突"），**没有"这组 op 允许并成一个 closure"的语义** => 加一个与 `g_cmds` 同长的 **`g_cmds_group`（int，默认 0）**，在 `pg_push` 里 push 组号 => **三向量同长同序（军规 57）**。先例：`S6Chain`@553、`s6_take_*`/`s6_gap`@582、`A5Chain`/`a5_take_wres`（**它们都不改 closure 数量与次序**；换序类第一次要改的是次序/分组 => **组号必须显式化，不能再靠 cmd 索引差**（`gap<=4` 那种容差换序后不成立）。**风险 = R9"重写本身就改图"** => 规矩：**只允许同组内合并，且合并后仍只 push 一条 closure**（body 内合并、closure 数不变），照 @528-532 的 "all six or none / 部分 no-op 禁止"。
**② capture 期合法性检查（宁 refuse 不猜）**：模板就在仓里 —— skip 守卫 `g_skipped_cmds`@1411、三条 REFUSED @1423（长度不齐）/ @1430（**"name offset not a whole recording" = §85 那次的警笛**）/ @1471（链不终止/不 pure => refuse）、汇总 @1482；合并类应在 **`xmx_graph_capture`@1923 之前**跑"分组合法性 pass"，不合法就 **REFUSED 退回拆腿**。三条换序判据：(a) 组内各腿 touch 指针集两两相交或明确声明可并行；(b) **组输入面在合并前不得被别的组改写**（**R4 直接教训**：`Araw/Braw/skip/cos/as/bs/a16r`）；(c) **不得改变别的 closure 的 pool 取块序列**（R6）。witness 三件套照 `[a5-fire]/[a5-geom]/[a5-op]` 的形状（**fire + 逐 op 的 id/bytes/ptr**）。
**③ pool 取块序列的 witness（把 R6 变成可测的东西）**：现成材料 `g_cmds_poolblk`@124（record-time 已存每个 closure 的 scratch 块列表）、`pool_get`@446 / `pool_put`@462 / `pool_clear`@471、`g_pool_sz`@200、`g_pool_mallocs`@444；最小改动 = 把 `g_pg_curblk`@125 快照写进 `g_cmds_poolblk`（字段已有）+ presence-gated 打印 `[poolseq] cmd=<n> blocks=<ptr,...>` => **换序前后两臂逐行 diff，任何一条变了就是 R6 命中 => 当场 refuse、不进图**。规矩：**合并体内部自己 get/put，边界上块数必须与拆腿时完全一致**。
**④ 编译期回退开关（不能只有运行期 env）**：先例 `T_SKIP_CHAINS_DEF`（@795 注释 -> `tools/shipped_build.defs`，经 `tools/patch_testdefs.py` 注入）+ 本案 `T_ATT5_FUSE_DEF`；合并类一律 **`T_<KIND>_FUSE_DEF`，默认 0 出变体、验过再换 1**；A/B 两侧都不设 env 才算出货态（军规 59 ③）。**身份守卫读单一出处（军规 62）**；**军规 57 的三向量对齐在换序类里最容易破**（换序天然改 `g_cmds`/`g_cmd_names` 对齐）。
**六条判据（全部是现成仪器，按序跑）**：1) 双档 1301 EXACT（拆腿档 = `DD49827D`，合并档必须同一颗）+ `[skip-chains]` 三向量计数两侧一字不差（57）；2) **`[poolseq]` 两臂逐行 diff = 空**（R6 的直接反证）；3) **`NR_PG_TOUCHDUMP` 两臂 touch diff**：只允许组内成员变化，**不允许第三方 closure 的指针重叠关系改变**（§94 读法：同址 = 串行化约束；换序改的正是这张约束图 => 必须留账）；4) **`NR_SELFREP=1000` bad=0**（军规 60）+ **>=4 独立进程 distinct md5=1**（军规 31）；5) **40 门**（守卫读单一出处 => 应 40/40）-> **帧 16 对**（两侧都不设 env）；6) **`NR_RUN_TIMING` 两臂逐 op 对账**（军规 40）。
**收益不写**（军规 26/35a/54）：刀 1/刀 3 的"帧 −5.19 / −6.79"是旧分摊账的**排序值**，本清单只给机制与判据。

### 86b. 我的两答：**⑴ (i) 半块拆分取消**（理由 = compute 已贴同形锚点、occupancy 不 binding，见 §85）；**⑵ 军规 63 已立案**（上一条提交 `d806667` 已把它写进 B2）。
★ **顺带核一处读数**：代理报 `out\SHIPPED_MD5.txt = 9334C18A…` 是**给 txt 本身取的哈希**，不是它记录的值；txt 内容 = `3baecf2a4b0f49f45e2557ce4808c2cf`，与两槽 dll 一致（守卫 MATCH）=> **仪器没坏，只是口径要说清：守卫比的是"txt 里那串"，不是"txt 的哈希"**。

## 87. ★ **用户拍板：开 B（换序墙）**；A（小刀：C1 折叠、chain 3 的 epilogue、WB 驻留已判死等）**推迟到"20 ms 阶段"再磨**　11:2x
**决策原文**："开b。a之后到20ms阶段再磨"。
**这意味着路线顺序（写死，防漂移）**：
1. **现在**：换序墙 = **记录/计划层的分组能力**。它是**刀 1（跨链 batch 进 grid，活站毛值 12.08 ms 串行）与刀 3（ViT/head MLP 跨块 b8，活站毛值 15.79）的唯一入口**，也是 §85 那条"window_block 离硬件顶 20 倍、但离这些 tile 形状的可达成速率已到顶"的**唯一出路（换 tiling / 提复用因子）**；
2. **A 类小刀冻结**（不是作废）：C1 quant 折叠（现值只剩 **2.72 ms 串行**，大头已被 A5 + qfuse 吃掉）、chain 3 的第二 epilogue（≈ −0.22、动数值面）、WB 驻留（**§85 已按物理判死**）——**等 20 ms 阶段再回来**；
3. **不变的封条**：跳块停在 **14/52**（不再加档）、**preset B（31 块）封存**、int8-only 换 dtype 已结案、`C128 att 合一` 不接（+51% 更差、SLM 41,984 越崖）。
**B 的第一步 = 只装仪表，不动发动机**（我的令，写在这里防跑偏）：
- 只做 **① `g_cmds_group` 分组标注**（与 `g_cmds` 同长，默认 0，在 `pg_push` 里 push；**军规 57 的四向量对齐**）+ **② 分组合法性 pass（REFUSE-only，先不做任何合并）** + **③ `[poolseq]` witness**；
- **不改任何执行语义**：双档 1301 必须 EXACT `DD49827D`、`[skip-chains]` 计数一字不差、**`[poolseq]` 两臂 diff 必须空**、≥4 进程 distinct md5=1、40 门 40/40、**帧 A/B 差 ≈ 0**（仪表不该买时间）；
- **真正的产出 = 分组普查表** `tools/group_census.csv`：全 52 条链里**每一组合法候选**的成员闭包、形状 (M,N,K,batch)、**在记录秩序里是否相邻（军规 42）**、touch 冲突、pool 块数 ⇒ **它回答"第二铲真合并时，哪些族能合法并、哪些必须先换序、换序要动多大"**。
**现场（开工前核）**：tip `28293f3` CLEAN；加载位 `out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`3BAECF2A…`**（A5 件，已 40/40 门 + 16 对 −1.251）；金标 `DD49827D` / `249A46F3` 未动；**GPU 空闲、无游戏进程**。

## 88. ★★★ B 第一步（只装仪表）交回：**验证链六步全过（仪表中性）+ 仪表第一次自证就逮到三处错位**；**普查给出 Q1/Q2/Q3 的精确答案：合并相关族相邻对 = 0、85 个非相邻组里 0 个干净区间 => 换序是帧级置换，不是局部交换**
件 = **`builds/libxmx_b1instr3.dll = F5A3F883C353B713885C0C1C434A10F6`**
### A 验证链（六步）
| 步 | 读数 |
|---|---|
| 1 双档 1301 | 默认档（无 witness）**EXACT `DD49827D`**；**全部 witness 开**（GROUP_TRACE+POOLSEQ+PG_TOUCHDUMP+ATT5_TRACE+POOL_STATS）**EXACT**；只开 poolseq **EXACT**；对照出货件 `3BAECF2A` + POOL_STATS 也 EXACT |
| 2 四向量计数 | `[vec-align] graph=0 cmds=691 touch=691 group=691 poolblk=691 idsnap=691 / names=1382 name_offset=691 => **ALIGNED**`；`[skip-chains]` 两侧一字不差 |
| 3 poolseq 两臂 diff | `allwitness` vs `poolonly`：**warm 哈希 `fa4d3da2aa18a510` 相同、capture 哈希 `e62607c36a3c7410` 相同**、`[poolseq-canon]` 每 closure get 计数序列相同；**独立不变量**：`[pool] mallocs=51 bytes=311 MB` 在出货件与仪表件上完全一致 |
| 4 确定性（军规 31） | **4 个独立进程（全 witness 开）=> 4 颗 1301 全 EXACT、distinct md5 = 1** |
| 5 40 门 | stage 仪表件（备份 `builds/libxmx_sycl_preB.bak.dll = 3BAECF2A`）=> **39 GREEN / 1 RED**，RED = 身份守卫（读 `out/SHIPPED_MD5.txt` => stage 变体必按设计 RED，军规 62）；**复原 = `3BAECF2A`** 后该门 GREEN；基座整轮 40/40 已在 08:4x 实测 => **仪表件实质门 39/39 全过** |
| 6 帧 4 对（两侧都不设 env） | `+1.360 / +0.230 / -0.970 / -1.100` => 均值 **−0.120 ms**、赢 2/4 => **|均值| < 0.15 带内中性**；**如实写：4 对分辨率 ±1.83 ms（sd 约 1.15、df=3），分不出 0.15 量级 => 这一步既没证明免费也没证明贵**。更硬的结构性论证：三件仪表都只在 **record/capture 期**跑（每帧一次，不在 replay 热路）；热路新增只有 `if (g_poolseq_on)` 一条可预测分支 + `pool_seq_note` 早退（691 次/帧）；默认全 presence-gated => 出货态不进这些函数。**以后要常开 witness，必须先 16 对** |
**停线未触发**：1301 与 poolseq 都没变 ✓
### ★ 仪表的第一次自证就逮到三处缺陷（这就是把自证明放进 dll、不放脚本里的理由）
1. **新向量不是 record-scoped**：只在 capture 清 => 但 plan **录制两次**（scratch -> `OP_XMX_ABORT` -> 保留），abort 不清新向量 => capture 时它们 **1382** 而 `g_cmds` **691** => **`[vec-align] REFUSED` 当场报警**。修 = `xmx_begin`@1415 与 `xmx_abort`@1425 一起清。**与 §85 同一类坑，这次是守卫先响** ✓
2. **对齐判据写错**：把 `g_cmd_names` 也算进"同长" => 它按 shipped 设计就是两录制累积（`names=1382 name_offset=691`）=> 改成只比五个 per-capture 向量、names 单独报 => **ALIGNED** ✓
3. **pool 哈希不能用裸指针**：驱动每次地址不同 => 同 arm 两次哈希就不一样（而 1301 逐位不变）=> 改成**首次出现序数 + bucket 尺寸**的规范序列 => 两臂哈希完全相同 ✓✓ **R6 要的是顺序与尺寸，不是地址**
★ **另一条事实**：`g_pg_curblk`@125 在 shipped 里**从未被置非空**（"planning run" 没接线）=> `g_cmds_poolblk` 一直是空字段。代理在 run 循环（cgraph record @2071、warm 平环 @2153）给每个 closure 打 stamp，才让 `pool_get/pool_put` 能归到 closure —— **这是本铲真正新造的机制，不是"填已有字段"那么简单**

### B 普查：`tools/group_census.csv`（678 行逐 closure）+ `group_census_families.csv`（90）+ `group_census_nearest_pair.csv`（90）
**Q1 = 对合并相关族，"现在就相邻、无需换序就能合法并"= 0**：678 个同形成员行里只有 **12 行距离 1，全是 `xmx_rec_unary`（不是合并目标）**；**每个 GEMM/attention/quant 族 `adjacent_pairs = 0`**：`gemm_int8_batched` 72 成员 min_gap=2、`gemm_int8_residual` 68 min_gap=4、`quant(FUSED-pack)` 144 min_gap=2、`gemm_int8_qkv` 53 min_gap=9、`window_attention` 45 min_gap=10、`gemm_window_int8_residual` 52 min_gap=10 => **§56b 的"相邻对=0、间隔=一条链长"在全帧所有族上被机器证实** ✓
**Q2 = 85 个非相邻组里 0 个是干净区间**（判据 = PGRAPH 自己的安全关系：touch 面相交即冲突、未注册 op 与一切冲突 => 保守方向只会高估阻塞）：最近一对的区间里总有 blocker，**外堵中位 8**，且**同族腿也常夹在中间**（C128 的 `quant(FUSED-pack)` 两两之间夹着 **96-100 条同族腿**）=> **把整族挪到一起 = 帧级置换，外堵 146-472 个 closure => 不是小动作**；R4 的靶已在 CSV 里点名（`blocker_names(first6)` 给 closure 号 + op 名；例 C256 `gemm_int8_qkv` 最近对 135..145 之间 9 个外堵）；**没有二元互挡环**，但 **>=3 条同形腿时，把 b 挪到 a 旁必然挪开另一条同族腿 c，而 c 自己也要与 a 相邻 => 这是整段链的置换问题，不是局部交换**（`same_family_legs_between` 就是它的量度）
**Q3 = 动作量级（实测）**：最近一对要挪 closure 数 **中位 10**（多数 1-9，少数 621）、外堵中位 8、**区间内 `pool_get` 事件数中位 1（max 423）** => **换序会牵动取块序列 = 实测**，也正是 `[poolseq]` 存在的理由；**最便宜的换序点已定位**（B 第二步的最小实验对象，gap=2）：**挪 1 个 closure、外堵 1 个、区间内 pool_get 0-1 次** = `xmx_rec_gemm_int8_batched` C256 对 **568..570**、`xmx_rec_quant` C256 对 **567..569**、`quant(FUSED-pack)` C512 对 **235..237**；**att 半区（C256）最贵**：gap=10 => 挪 9 + 外堵 6-9 + 区间内 11 次 pool_get
**没有写任何收益预测**（军规 26/35a/54）。本盒 GPU 约 45 min（含冷却）。

### 88b. 我的读法与决策（写死，防漂移）
**这一铲最大的价值是三件仪器**：`[vec-align]`（四向量对齐守卫，已在 §85 那类坑上第一次先响）、**`[poolseq]` 规范序列**（首次出现序数 + bucket 尺寸；R6 从"推断"变成可 diff 的东西）、`[grp]` 分组标注。**仪表留，不删。**
**普查的诚实结论 = B 的大奖比想象的贵**：合并相关族**相邻对 = 0**、**0 个干净区间**、把整族挪到一起 = **帧级置换（外堵 146-472 个 closure）** => **"局部换序"这条路对刀 1/刀 3 不成立**；刀 1 当年判死的机理（closure 级重写不等价）现在有了**全帧范围的机器解释**。
**因此 B 的第二步拆成两半，顺序固定**：
- **(i) 最小机制实验（gap=2 三对）**：**目的 = 验证换序机制本身是否成立**，**收益预登记为 ≈ 0**（一对而已），**判据 = 先声明"预期的 `[poolseq]` 变化集合"再跑**（真换序必然改 poolseq，所以规矩改成：**声明之外的任何变化 => 当场 refuse/停**）；
- **(ii) 纯 CPU 的"最大可合并质量"研究**：用 `[pgt]` 的 touch 依赖图，求**在依赖约束下的拓扑置换能把多少 ms 的同形腿变成相邻**（价格用 `rt_per_closure.csv` 实测值），并给出**要移动多少 closure**。**这一步给 B 第三步定价，不写帧收益承诺**（军规 54）。

## 89. ★★★ B 第二步两半都交回：**换序机制成立且行为中性**（三对 + 合并全部 1301 EXACT、poolseq 哈希一字不变、touch 只在声明窗口内变）；**(ii) 给出定价事实：帧排序约束的 58% 只来自两面（1272/1273 = int8 行尺度 scratch）=> B 第三步的先决条件是 scratch 版本化，不是换序器**；**但 SELFREP 仪器出现退化型崩溃，换序件的军规 60 门记为"未干净通过"**
### (i) 最小换序实验（先声明后跑：`notes/reorder-declare.md`）
**机制**（`s6/pe_b2_order.py`，presence-gated `NR_BMERGE_ORDER="<from>><to>,..."`，默认关）：在 `xmx_graph_capture` 里 **skip/bmerge 之后**执行，对 `g_cmds / g_cmds_touch / g_cmds_group / g_cmds_poolblk / g_pg_ids_snap` **原子 erase+insert**，`g_cmd_names` 在其 `name_offset` 上同样处理 => **军规 57 的五向量对齐不破**。件 **`builds/libxmx_b2order2.dll = 172145A31806EC21078E21C4412FAF69`**
| 臂 | 1301 | poolseq 哈希（warm/capture） | 变化位置 | 声明窗口外 | touch 多重集 |
|---|---|---|---|---|---|
| B6_base | **EXACT `DD49827D`** | `fa4d3da2aa18a510` / `e62607c36a3c7410` | 0 | - | - |
| `569>570` | **EXACT** | **与基线一字不差** | 2 | **NONE** | 不变 ✓ |
| `568>569` | **EXACT** | 同上 | 2 | NONE | ✓ |
| `236>237` | **EXACT** | 同上 | 2 | NONE | ✓ |
| 三动作合并 | **EXACT** | 同上 | 5 | NONE | ✓ |
**确定性（军规 31）**：换序 ON 的 4 个独立进程 => 4 颗 EXACT、**distinct md5 = 1** ✓；**40 门**：stage 换序件 = **39 GREEN / 1 RED**（身份守卫按设计），复原 `3BAECF2A` 后 GREEN => **实质门 39/39** ✓
**帧 4 对**：`+1.820 / +0.880 / -0.350 / -0.440` => **均值 +0.478 ms、赢 2/4、CI95 约 [-1.17, +2.12]** => **超了 0.3 的 sanity 线，如实报**；但 4 对分不出这个量级（半宽 1.65），形态像热漂移（前两对正、后两对负），换序只挪 5/691 条 closure => **既不能定代价也不能定免费，要 16 对**
★ **两个仪表缺陷（代理自造、已修）**：① **`[pgt]` 打不出换序** —— 它在 `pg_push`（**record 期**）打印，而换序发生在 **capture 期** => 第一版比较得到 "changed=0" 的**假结论**；修 = 新增 **`[pgt-final]`**（capture 后对冻结向量打）=> 才真能验声明集合；② **id 镜像把未解析的整数也记了**（有些调用点在同一 initializer_list 里混了 flag 字，如 `134221248` = pooling 位，其值跨进程不稳）=> touch diff 看起来非空；修 = `pg_note_ids` **只记能解析到 live buffer 的 id**
★ **SELFREP（军规 60）没有干净过 —— 但病因在仪器**：`B7_selfrep`（换序 ON）死在 **run 659/1000**；`B8_sr_on1` 死在 **run 906/1000**；`B8_sr_on2` **1000 跑完 bad=0** ✓；**同件换序 OFF 对照**也 **bad=0** ✓。
**退化特征（关键）**：每帧耗时单调爬升 —— `B7` 前 50 帧 63.5 ms => 后 50 帧 **89.3**（单帧最高 2295）；`B8_sr_on1` 71.3 => **174**；两个跑完的臂也轻微上升（64.9->70.7、64.4->71.5）=> **累积/泄漏型退化，不是竞态**；且 §95 那次（**没有换序的 att5o2**）也在 run 528 死过 => **同一失效模式早于换序存在**。
⇒ **换序件的军规 60 门记为"未干净通过"**（3 臂 1 过 2 退化致死，OFF 对照过）。修仪器建议：**每 ~250 帧重启进程**，或每帧只下载单面 + 定期清 pool/graph => **修完再补这道门**。

### (ii) 换序可行性 + 反事实定价（纯 CPU，零 GPU）
**依赖规模**（691 closure / 238,395 个可能有序对）：调度器代理（任意共享 id 即冲突）**175,538 = 73.6%**；**角色感知（RAW/WAR/WAW，按 recorder 签名分输入/输出）134,784 = 56.5%**
★ **定价事实**：**`1272` / `1273`（int8 行尺度 scratch）各 244 写者（QUANT 192 + QUANT_WINDOW 52）/ 244 读者（全部 int8 gemm 族）**，跨 closure 13..678，**488/691 条摸它们**
**反事实阶梯**（`tools/reorder_plan_study_counterfactual.csv`，生成器 `s6/pe_reorder_study3.py`）：
| 版本化哪些共享面 | 剩余约束对 | 可成组族数 | 最大 run | **可合并质量上限（ms 串行）** |
|---|---|---|---|---|
| 不版本化（现状） | 134,784（56.5%） | **6 / 83** | 3 | **≤ 7.16** |
| **{1272,1273}** | 57,216（**24.0%，去掉 58% 约束**） | 26 | 25 | **≤ 9.57** |
| {1272,1273,1274,1275} | 20,052（8.4%） | 35 | 50 | **≤ 21.60** |
| 全部 7 面（+1276/1305/1306） | 14,682（6.2%） | 49 | 50 | **≤ 33.91** |
**Q2 直答：没有环**（两种模型的边都只从记录序号小指向大 => 构造上就是 DAG；真 RAW/WAR 也不可能有环，因为这帧本来就按此序跑通）。**卡住相邻的是"被强制夹在中间的节点"**：现状下 **83 组里 77 组连一对都排不出相邻**。
★ **(i) 的实验证明代理会高估阻塞**：`236>237` 按代理是 blocked（共享 1284 面），实际换序后 **1301 逐位 EXACT** => 那次重叠是"读-读"型无害 => **判"能不能换"必须用角色感知模型，代理只能当安全上界**
**Q3 动作量级**：最近一对要挪 closure **中位 10**、外堵 **中位 8**、区间内 `pool_get` **中位 1 / max 423**（估算口径已在表里标明）；每族 movable/forced 在 `tools/reorder_plan_study_roleaware.csv`。**不写收益预测**（军规 26/35a/54）：上表是"若相邻达成，最多有多少站点可并"的上限。

## 90. ★ **用户实机验收通过：A5 件（`3BAECF2A…`）画面没问题** => **加载位成为新的 A 侧基线**　16:1x
- **帧基线更新**：63.5（接手起点）-> **57.3**（1a −3.0、T2 −4.8、A5 −1.251，全部 16 对 + 逐位/自重复背书）；**新 A 侧 = `out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = `3BAECF2A4B0F49F45E2557CE4808C2CF`**；回退点 `out\libxmx.before-ATT5.keep` = `ABB969FE…`（+ `builds\libxmx_sycl_ABB969FE.bak{,2}.dll`、`builds\libxmx_sycl_preB.bak.dll`）。
- **A5 = 画质零代价**（两档 1301 都 = 新金标 `DD49827D`）+ **40 门 40/40**（在转正件上实测）+ **`NR_SELFREP=1000` bad=0**（A5 当时那三臂是干净的，退化是后来 B 第二步的换序臂上才出现，见 §89）。
- **用户路线令（11:27）**："开b。a之后到20ms阶段再磨" => **B（换序墙）为主线**；A 类小刀（C1 折叠 2.72 ms 串行、chain 3 第二 epilogue ≈ −0.22、WB 驻留已按 §85 物理判死）**冻结到 20 ms 阶段**。
- **金标语义提醒**（防以后误判）：`bk.1301.bin` = `bk.1301.skip.bin` = `DD49827D`（跳块 + 1a + A5 代）；`bk.1301.pre-skip-1a.bin` = `249A46F3`（旧代）。**任何从仓 HEAD 不带 `/D` 构的件都会落在 `249A46F3` 那颗上 => 逐位门假红**（军规 59 / §77 的地雷，构建一律走 `tools/build_shipped.ps1` + `tools/shipped_build.defs`）。

## 91. ★ 用户新令（01:2x）：**"按你的推荐做"，但把"帧数稳定不稳定"往后放**——原话：**"这个问题等后面 1080p 帧数能到 30+ 以上才有意义。说白了就是现在这帧数根本没到可玩的程度，帧数稳定不稳定我都没法玩。"**
**解读与处置（写死）**：
- **目标函数换了**：不是"每帧抖不抖"，而是**"能不能把 NR 帧时压到可玩"**；**T1（长循环退化诊断）降级**：**不单独开 GPU**，只在 16 对/门的日志里顺手留每帧耗时趋势（零额外成本）；
- **B（换序/版本化/胖形状）= 主线**；A 类小刀继续冻结到 20 ms 阶段；
- **下一铲已批**：**`1272/1273` 的 scratch 版本化**（§89 定价：两面独占 58% 排序约束；版本化后约束 56.5% -> 24.0%、可成组 6/83 -> 26、最大 run 3 -> 25）。
★ **本铲要正面测的新假设**：**版本化可能不需要等到"真合并"就买帧** —— PGRAPH 现在按"同址即冲突"把 **488/691 条闭包强制串行化**；两面私有化之后重叠窗口变多 ⇒ **光靠调度就可能省时间**。判读线预登记：**16 对 ≤ −0.5 且赢 ≥10/16 = 转正**；**[−0.5, −0.15] = 带内只留账**；**≥ 0 ⇒ 版本化 alone 不买帧，降级回"换序前置"**。

### 91b. 20 ms 目标的算术（诚实账，防以后自己骗自己）
- **现状**：NR = **57.3 ms/帧**，工作量 **266 GF/帧**（§49 更正后的口径）=> **整帧有效算力 4.64 TOPS**；**lmxx route A = 1056 GF / 111.3 ms = 9.5 TOPS**（36 核种 / 153 launch @1920x1152）。
- **要到 20 ms**：`266 GF / 20 ms = 13.3 TOPS 有效` ⇒ **是 lmxx 实测路线 A 的 1.4 倍、是现在的 2.9 倍**。
- **可达屋顶（实测表 `tools/xmx_roof.csv` / `wbint8_roof_ext.csv`）**：f16 宽形（N384K128）**12.37 TOPS**；int8 宽形（N384K128）**22.73 TOPS**；int8/f16 实测比 **1.35-1.84 倍**（不是 2.0）。
⇒ **结论：20 ms 只有三条腿同时到位才可能**：① **算术搬到宽 tile**（胖形状 / 合并 / 高复用 = B 的射程）；② **dtype 上 int8 且形状同时变胖**（§47 已证：只换 dtype 不换形状只兑现 36%）；③ **流量降下来**（残差面 1 字节：~4 GB/帧的 7-12 ms 地板 => 4-6 ms）。
⇒ **任何一条腿单独做都到不了 20 ms**；这也是为什么 **B 排在 A 前面**。

## 92. ★★★ B 第三步 ①（设计 + 字节预算）交回：**内有一条 id 空间错误必须先纠（它让我 §89/§91 的定价作废）**；**并暴露一个结构性事实：出货路（cgraph 单流）根本不读 touch set => "版本化 alone 买帧"按构造 = 0**
### ① 纠错：**plan 表 id 与运行期 id 不是一套**
`xmx_buf_create_kind`@1250 每次 `g_nextbuf++` => **第一次录制造 id 1..1301，保留那次造 1302..1313**（同一 plan 面在两次录制里 id 不同，**偏移 +33..+36**）。
⇒ **§109 用 plan 表的 1272/1273 去减运行期 touch 集 = 减了个空** => **"版本化后 maxwidth 仍是 1"是假的**；**§89/§91 里那套 58% 约束、6/83 -> 26、上限 7.16/9.57/21.6/33.91 的定价全部作废，以下表为准**。
新仪表 **`[bufnew]`**（`id/bytes/kind/recording/during_closure`，presence-gated；探针件 `builds/libxmx_b3probe2.dll = 9ACD1257…`，**1301 仍 EXACT => 仪表中性** ✓；`b3probe = 50C9AF69…` 是未打补丁的空枪，别用）：
| 运行期 id | 字节 | 是什么 |
|---|---|---|
| **1305** | **9,142,272** | int8 **packed 面**（= plan 表 **1272** 的实例）|
| **1306** | **142,848** | **行尺度 scale 面**（= plan 表 **1273**）|
| 1307 | 33,554,432 | K 面（1274）；1308 = 4,571,136 Q 面（1275）；1309/1310 = V / 另一面（1276/1277）；1303 = 66,846,720 = 1267 整幅图像面 |
★ **军规 69（新）**：**任何按"面"做的分析必须先经 `[bufnew]` 把 plan 表 id 映射到运行期 id**（两次录制 id 不同、偏移 +33..+36）；**否则减的是空集，结论会反向**。（本案就是：约束定价从"maxwidth 1 不变"翻成"1 -> 4"。）
★ **军规 70（新，仪表侧）**：**往 dll 里加打印时，任何下标表达式先算边界**。本案 `[bufnew]` 初版写了 `g_cmd_names[names.size()-cmds.size()+cmds.size()]` = `names.size()` **越界**，跑前肉眼逮住；这类错在运行期以 fastfail 出现（§70 的 `0xC0000409` 同族）。
### ② 离线定价（**用引擎自己的贪心波次规划器**：`pgraph_plan`@164-182 复刻 + sentinel 规则 @142-143，零 GPU）
**牙齿检查**：不减任何面 => **waves=691 / maxwidth=1 / 关键路径 = 114.63 ms = 全部串行和 => 头部 0.00**，**精确复现 2026-11-01 的机器事实**（PGRAPH 判死那次规划器输出就是 waves=691/maxwidth=1，"每层读写同一条残差流 + 金字塔共享 pk/scale 面"）✓✓
| 版本化掉哪些面（运行期 id） | waves | **maxwidth** | 关键路径（串行和 114.63） | **可挖头部** |
|---|---|---|---|---|
| 无（现状） | 691 | **1** | 114.63 | **0.00** |
| **{1305,1306}** | 418 | **4** | **102.57** | **+12.06 ms 串行** |
| {1305,1306,1307,1308} | 433 | 5 | 83.76 | **+30.88** |
| +{1309,1310} | 487 | 4 | 86.06 | +28.57 |
⇒ **假设在模型意义上被证实**：只私有化 **1305/1306（合计 9,285,120 B）=> maxwidth 1 -> 4、头部 0 -> 12.06 ms 串行**；再抬 Q/K 两面 => **30.88**。现状下 1305/1306 **各挡住 396 条相邻链**；版本化后剩下的持有者是 1308(180)、1307(135)、1303(78)。
### ③ 字节预算（军规 22/30）
- **一份私有副本 {1305,1306} = 8.9 MiB**；**K 份并发 = (K-1) x 8.9 MiB** => K=2 -> 8.9；**K=4 -> 26.6**；K=8 -> 62.0；K=16 -> 132.8 MiB（今天 `[pool] mallocs=51 bytes=311 MB`）；
- 若连 **1307/1308** 也私有化：单副本 = 9.14 + 0.14 + 33.55 + 4.57 = **47.4 MiB** => **K=4 => +142 MiB**（这条要单独点头）；
★ **今天 peak 同时存活副本数 = 1**（writer -> 最后 reader 区间扫描：1305/1306 区间长度中位 2、peak 1）=> **私有化不是正确性要求，纯粹给调度/换序松绑 => 便宜，K 由我们选** ✓
### ④ ★★★ 结构性事实（代理提出、我确认它改变了这一铲的性质）
**出货路 = cgraph 单流按记录序重放**（`NR_PGRAPH` 默认 0 => `usecgraph=true`@2056）=> **它根本不读 touch set** => **"版本化 alone 买帧"在默认路上按构造 = 0**：原判据 #7（帧 16 对 A=出货、B=版本化）**必然落在 0**，**不是版本化没用，而是没有消费者**。
**能花这笔头部的是 PGRAPH 双流/四流执行器**；它 11-01 判死的原因是**每波 barrier 开销**（691 波 => 156 ms）。版本化把 **波数 691 -> 418、宽度 1 -> 4** => **开销降到约 60%、并行度 4x** => 值得一测，**但这就是"复活 PGRAPH"那一铲，不是独立一铲**。

## 93. ★★★★ **B 第三步的结论：版本化实现成功且行为中性，但它"没有打开任何空间"——我 §92 那张 +12.06/+30.88 ms 头部是模型错误造出来的；换序空间实测上限只有 1.66 ms 且全是 `unary`（不是合并靶）=> B 第四步（换序器）不该开工**
### ① 实现（件 `builds/libxmx_b3priv7.dll = 53AC1D563527140A63F5A55C453F99BC`）
开关 `NR_SCRATCH_PRIV`（默认 0）/ `NR_SCRATCH_PRIV_K`（环深 4）/ `NR_SCRATCH_PRIV_SIZES`（角色尺寸）。机制：`xmx_buf_create_kind` 按**字节尺寸角色**登记本录制的目标面（`xmx_begin` 清空），每个 quant/quant_window 生产者 `sp_advance()` 给每个 id 建 **K 份物理环**（slot0 = 今天那块 => 不泄漏）并把 `g_bufs[id].p` 指向新槽 => **逻辑面不变、物理面轮转**，数值链不碰。
**四个自造的坑都被逮到**：⑴ **目标 id 错**：按固定 id {1272,1273,1305,1306} 建环 => 但**运行期 1272/1273 是 512 B 占位面**，真正的链持有者是 **1305（9,142,272 B int8 packed）/1306（142,848 B 行尺度）**，且**只在第二次录制里创建** => 第一版 `extra_bytes=1536`、touch 不变 => **declare-vs-measured 对照逮住**；修 = 按尺寸角色登记（这两个尺寸在 `[bufnew]` 普查里全局唯一）=> **`versioned_ids=2 extra_bytes=27,855,360 (26.6 MiB)`** ✓ 正好批准额；⑵ helper 位置错（6,900 行文件里加静态 helper 必须先确认所有使用点都在其后）；⑶ **仪表看不见换 pointing**：`[pgt-final]` 只打 ids，逻辑 id 不变 => 隐形；修 = 加 **`|| ptrs=`**（规范序数，军规 64）=> **实测：C3_base 里 id 1305 只有 1 个物理指针（488 次），C3_priv 里变成 4 个（各 122 次），1306 同样 => 机制真生效** ✓✓；⑷ **定价模型错**（见 ②）。
**门（全过）**：双档 1301 都 **EXACT `DD49827D`**（版本化不改数值 => 金标不换）；`[vec-align]` 五向量 ALIGNED；`[skip-chains]` 计数一字不差；**非参与者 touch 集变化 = 0**；**4 独立进程 distinct md5 = 1**；**40 门 stage 变体 39/1（身份守卫按设计）复原后 GREEN => 实质 39/39**；`[pool] mallocs=51 bytes=311 MB` 两臂都不变（**环缓冲走 `xmx_buf_create_kind`，不经 pool**），真实增量 = 环的 26.6 MiB（在预算内）。
★ **我自己的一条声明错**：`notes/scratch-priv-declare.md` 里预告"poolseq 会变" => **实测两臂哈希相同**（`fa4d3da2aa18a510`/`e62607c36a3c7410`）=> **声明关于机制 footprint 错了，不是行为错**；已就地写 "MEASURED OUTCOME" 把 declare -> check 闭环。

### ② ★★ 真正的判据结果：版本化**不打开任何空间**（实测与修正模型一致）
**错在哪**：§110（以及 §109 的 7.16/9.57/21.60/33.91 阶梯）把"版本化"建模成**把面从 touch 集里删掉**。真实版本化是**把一条依赖拆成 K 条独立链**——**生产者与它自己的消费者仍共享同一块物理面**（只是换成另一块）=> **依赖不消失**。
| 视角 | 相邻链 links | waves | maxwidth | 关键路径 | 头部 |
|---|---|---|---|---|---|
| 实测 C3_base（ptr 视角） | 690/690 | 691 | **1** | 114.63 | **0.00** |
| **实测 C3_priv（K=4 版本化）** | **690/690** | 691 | **1** | 114.63 | **0.00** |
| 修正模型：再版本化 {1307,1308,1309,1310} | 690/690 | 691 | 1 | 114.63 | 0.00 |
| 修正模型：再版本化 1303（66.8 MB 图像面） | 690/690 | 691 | 1 | 114.63 | 0.00 |
**为什么链还全连**（`s6/pe_b3_holders.py`）：版本化把 1305 的持有从 396 降到 244（1306 同），**但那些对被 1308(180) / 1307(135) / 1303(78->71) / 1310(68) / 1309(60) / 1313(55) 同时持有** => **过度决定的链**；例：closure 300 `quant -> gemm_int8_batched` 共享 1305/1306 —— **这是真数据流，不是 scratch 复用**。
★ **换序空间表（`tools/reorder_space.csv`，修正模型 `s6/pe_b3_feas.py`）**：**可行组 5/83、最大 run 3、可合并质量上限 ≤ 1.66 ms 串行**，且这 5 组**全是 `xmx_rec_unary`**（不是合并靶）；**版本化任何深度都不改变这个数** => **§109/§110 的阶梯作废，今天的真实上限 ≈ 1.66 ms**。
### ③ 帧读数（各 4 对）与 **PGRAPH 正式关门**
- 出货路（cgraph）：A 不设 env（57.24-57.64 ms）、B `b3priv7 + NR_SCRATCH_PRIV=1` => **均值 +0.087 ms**（赢 2/4）=> 带内、按构造 ≈0，**|Δ| > 0.5 的停线未触发** ✓
- **PGRAPH**：A = `NR_PGRAPH=2` **72.31-72.83 ms**；B = `NR_PGRAPH=2` + 版本化 **72.61-73.26** => **+0.310 ms（赢 1/4）**
⇒ **(i) 我上一条那个 "PGRAPH ≈ 104 ms" 的模型偏高**：**今天 PGRAPH 只比 cgraph 贵约 15 ms（72.6 vs 57.4）** => **每波开销 ≈ 0.022 ms，不是我们引用的 0.143**；
⇒ **(ii) 版本化在 PGRAPH 下也不买帧** => 与修正模型一致 => **这扇门正式关闭**。

### 93b. 军规 72/73（入 B2）
**72**：**"删面/删边"式的反事实是错的建模**——任何"放松依赖"的假设必须改成**"重定型"式**：在**实测的指针视图**上跑**同一台规划器**，先做 **"模型 vs 实测"牙齿检查**再报数。正案：§110 用"删掉 1305/1306"算出 +12.06/+30.88 ms 头部，实测版本化后 **waves/maxwidth/关键路径一字不变**（头部 0.00），因为真实版本化把一条依赖拆成 K 条独立链、生产者与自己的消费者仍共享同一物理面。
**73**：**依赖图类结论要先问"这条边是真数据流还是 scratch 复用"**：本案 closure 300 的 `quant -> gemm_int8_batched` 共享 1305/1306 是**真数据流**（且被 1308/1307/1303 等多面同时持有 = 过度决定）=> **691 闭包的串行不是假串行**。

## 94. ★★★★ 胖形状第一刀（放宽 `wide_ok` / 块对角 wide）：**停线触发，未实施** —— **−1.64 帧不是真的，实测是负的**（三站 ratio 全 < 1，净亏 18-30%；S0 还 `diff≠0` = 数值 REFUSE）；**⑤ 靶单给出真正的机制 = `fat-M`（零额外 FLOPs）**
### ① 屋顶：早就齐了（本铲零新测，省一小时）
| 合并形 | leg | msM_med | TOPS | nproc | scratch |
|---|---|---|---|---|---|
| int8 `640x512x2048 b1`（G35_widediag） | `gemm_b` / `gemm_b_pub` | 0.0873 / 0.1343 | 15.374 / 9.990 | 6 | 0 |
| f16 `2040x256x1024 b1`（G41_f16wide） | `gemm_b` / `gemm_b_pub_f16` | 0.1230 / 0.1307 | 8.696 / 8.183 | 6 | 0 |
| f16 `640x2048x512 b1`（G39_f16wide） | `gemm_b` / `gemm_b_pub_f16` | 0.1699 / 0.1124 | 7.897 / 11.941 | 6 | 0 |
**口径缺口如实报**：这三行 `private/spill` 在台账里是 `-`（那轮 sweep 没记这两列，只有 `scratch=0`）=> 按军规 45 完整口径要再跑一轮；**但下面实测单价已直接判死，不必花**。
### ② 三站成对单价（首跑 `knife2_probe.exe = B5A82BE2`；`K2_SITE=0/1/2`、`K2_G=5 K2_R=15`、没设 `NR_PACKA_VEC/NR_GPACK_VEC`；**每站 10 独立进程、进程间 60 s**；取 `CSVROW` 第 10 列）
| 站 | 现形 -> 合并形 | **DIFF** | **ratio（split/wide）** | 判决 |
|---|---|---|---|---|
| **S0 int8** | `640x64x256 b8` -> `640x512x2048 b1` | **10/10 rep 都不为 0：164,620 / 327,680 元素（50.2%）** | 0.647 / **0.696** / 0.851 | **数值 REFUSE**，单价也亏 |
| **S1 f16** | `2040x32x128 b8` -> `2040x256x1024 b1` | **0 / 524,288** ✓ | 0.700 / **0.733** / 0.865 | **ratio < 1.3 => 停**（实际亏 27%）|
| **S2 f16** | `640x256x64 b8 epi2` -> `640x2048x512 b1` | **0 / 1,310,720** ✓ | 0.667 / **0.817** / 0.958 | **ratio < 1.3 => 停**（亏 18%）|
逐腿中位（ms/call，10 rep）：S0 split **0.1454** vs wide **0.2092**；S1 0.1880 vs 0.2598；S2 0.1909 vs 0.2346。
⇒ **按规矩当场停**：不动 `wide_ok`、不把 `gather_pack_b16_diag_b` 接进 `pack_device.hpp`（补丁器 `s6/pe_k2_pack.py` 已写好但**未执行**，留档备查）
### ★ 为什么会亏（物理，不是实现问题）
**块对角 wide 把 FLOPs 乘 b**：合并形 `(M x N*b x K*b)` = **b^2 份单组功，真活只有对角 b 份 => b 倍白算**（这里 b=8 => 8x）。**而 split 路早就是一次 dispatch**（R8a：batch 是 grid 的 z、`pack_A` 一次 / `pack_B` 一次缓存 / `gemm` 一次 / `publish` 一次）=> **没有启动开销可回收** => 宽形只剩浪费。
**P8-b 当年 3.5x / 6.14x 是另一件事**：它合并的是"每 group 一条闭包"的旧形（`N=32、b=2..4`、split 每条欠填充）=> 已出货、仍成立；**把同一机制放宽到 `N=64/256、b=8`，落在的正是"已经一次 dispatch"的站点 => 必亏**。
★ **修正 §89 的"活站价值帧 −1.64"**：那是按屋顶倍率（1.58 / 13.5 / 19.7）估的；**实测倍率 0.70 / 0.73 / 0.82 => 帧价值为负 => −1.64 作废**。**这是军规 72 的同族错误：拿屋顶比当收益、没跑成对单价。**

### ⑤ 靶单（零 GPU）：`tools/fatshape_next.csv`（398 行 / 260 活站；生成器 `s6/pe_fatshape_next.py`）
**两种"胖形状"在屋顶上完全不同命**：
| 机制 | 活站 | 有同形屋顶 | 帧价值上限（`recovery_alive_ms` 求和，**上限不是承诺**）|
|---|---|---|---|
| **fat-M（M 乘 b，N/K 不变 => 零额外 FLOPs）** | **38** | **30** | **<= 16.237 ms 串行** |
| block-diag wide（b x 额外 FLOPs） | 122 | 98 | <= 17.952 ms（**已实测判死**）|
| other | 16 | 16 | <= 0.950 ms |
| unparsed（合并形不是 `MxNxKb` 形式） | 84 | - | 0 |
**最大 fat-M 站点**：`xmx_rec_gemm_int8_residual 192x1024x4096 b1 -> 1536x1024x4096 b1`（closure **316/325/334/343/352/361/370/379**，每站 recovery **1.1865 ms => 8 站 9.49 ms**）；其次 `xmx_rec_gemm_int8 192x4096x1024 b1 -> 1536x4096x1024 b1`（0.4549 ms/站）。
**为什么 fat-M 与 block-diag 不同命**：fat-M 是**把 8 发 192 行拼成 1 发 1536 行**，**FLOPs 一份不加**、tile 填充率上升（192 行 = BM64 的 3 块 -> 24 块，尾波浪费下降）=> **前提是同一 B（权重）+ A/C 切片连续**（`shapes_alive.csv` 的 A4 组已按"8 发合一"登记）。
★ **对 §111 的一条修正（代理提出，我采纳）**：§111 那张"换序空间 = 1.66 ms"用的是**保守 touch 代理**（任意共享 id 即冲突）。**fat-M 类站点共享的是 B 权重 = read-read，不构成依赖** => **角色感知口径下这类空间要另算**。

### 94b. 军规 74/75（入 B2）+ 流程改动
**74**：**屋顶倍率 != 收益**。任何"合并/换形"的帧价值必须先跑**同进程成对单价**（>=10 独立进程、进程间 >=60 s）；屋顶比只用来判断"离顶多远"。正案：刀 2 的 −1.64 帧是按屋顶倍率估的（1.58/13.5/19.7），实测 ratio 0.70/0.73/0.82 => 帧价值为负。
**75**：**块对角 wide 合并按 b 倍多算 FLOPs**（b^2 功、b 份真活）=> 只有当"拆腿形每次 dispatch 欠填充"时才划算。P8-b 的 3.5x/6.14x 合并的是 N=32、b=2..4 的每条一闭包旧形；对已经"一次 dispatch"的 batched 站点（R8a：batch 在 grid z）放宽到 N=64/256、b=8 必亏。
**流程改动（写死）**：**胖形状类铲一律"先 bench 成对单价，再动引擎"** —— 这一铲就是被这条规矩救回来的。

## 95. ★★★★ **B（改形状 / 依赖图）这条线整体结案：在本帧没有合法落点** —— **全帧 244 个同形对，LEGAL = 0，且 244/244 挡因都是 `shared-output`（两发写同一面）=> 合法对总质量 = 0.000 ms 串行**；**本铲零 GPU**
### ① 先接住我的推理缺口纠正（代理自认方法错，不是数错）：已写死进 `notes/reorder-space-vs-defer-scope.md`（**军规 73b**）
**`reorder_space.csv` 判的是"挪闭包（相邻性）"；defer-and-merge 不挪任何闭包，只把前面几发的 gemm 推迟到最后一发的位置发射 => 两个判据不能互读。**
### ② A4 合法性读数（`tools/fatM_defer_legality.csv`，`s6/pe_fatM_defer.py`）
**四条判据**：(a) 成员不得写同一面；(b) 成员到合并点之间不得有人**改写成员的输入面**（= §56b R4 的真身）；(c) 成员到合并点之间不得有人**读成员的输出面**；(d) 多持有输入的显存可接受。
- **逐站输入面清单**：扫了 **48 个输入面**（`Araw/Braw/skip/cos/as/bs`，带运行期 id + 字节，经 `[bufnew]` 映射 => 军规 69 ✓）；
- **改写者扫描**：**21/48 面 BLOCKED**。点名：**site 316 的 `Araw id=1286`、`a_scale id=1287` 被紧邻的下一闭包 317（`QUANT`）改写**；**`skip id=1285` 被 321（下一个成员）改写** => **每一发的输入面只活 1-9 个闭包**；
- **输出面独立性：不成立** => **八站写的是同一块 1267**（`duplicates=[1267]`），而且**每一发的输出在 +1 处就被 `QUANT` 读走**（7 个提前读者）=> **这八发不是八次并列射击，是残差链上的八个连续环节**（写 1267 -> 317 读 -> … -> 325 再写 1267 -> 326 读 -> …）；
- **pool 代价：不是问题**（八站各持 1 块共 8 块 8,388,608 B；合并体只需 A pack `1536x4096 = 6,291,456 B` + C `1536x1024x2 = 3,145,728 B` => **合并反而更省**；我说的 1.6 MB 量级成立）；
- **结论 = `blocked`**（挡在 (a)+(b)+(c)，不是 (d)）
### ③ ★ 全帧普查（`tools/fatM_defer_pairs.csv`，`s6/pe_fatM_pairs.py`）
**同形对（gap <= 40）共 244 对 => LEGAL = 0 / BLOCKED = 244，244/244 挡因都是 `BLOCKED-shared-output` => 合法对总质量 = 0.000 ms 串行**
**保守性口径如实标**：witness 看不到"切片"（同一面的不同行块）=> 同面即判挡。**但对这些族这不保守**：`gemm_int8_residual / gemm_int8 / gemm_int8_batched` 的签名里**没有 sc/ldc 切片参数**（整面写），而且"下一闭包立刻读该面"是实测到的 => **它们确实是串行链，不是并列射击**。
### ④ 单价 / 屋顶：**没跑**（按规矩只有 legal / legal-with-holding 才进单价）；`1536x1024x4096` 的屋顶点也没补 —— **它现在没有消费者**，补了就是军规 26/35a 禁的"为不存在的手术备料"。

### 95b. **B 线的完整判决表**（以后引用就按这张，别再翻旧账）
| 路线 | 状态 | 依据 |
|---|---|---|
| 换序器（挪闭包） | **不建** | §93：角色感知 + re-typing + 实测（links 690/690、waves 691、maxwidth 1）|
| scratch 版本化 | **降级为管道**（默认 0、不转正、不推广到 1307/1308）| §93：既不打开并行度也不打开空间 |
| block-diag wide（放宽 `wide_ok`）| **判死** | §94：三站 ratio 0.70/0.73/0.82（净亏），S0 还 10/10 rep 逐位不同 |
| fat-M / defer-and-merge | **判死（合法性）** | §95：A4 `blocked`；244 同形对 0 合法 |
⇒ **改形状这条路在本帧没有落点。剩下的只有两条，且都不是"形状"**：
1. **消环节 = 链内融合**（A5/S6/qfuse 那套：把**同一链上相邻的几腿并进一核**，不动记录秩序、不改形状）——**已被验证买帧**（A5 = −1.251 ms/帧、16 对 16/16）；**未融合的大家族**：`window_block 18.19(10)`、`global_attention 11.48(8)`、`gemm 7.03(42)`、`ffn 6.24(8)`（串行 ms，`RT_shipped.timing.txt`）；
2. **单环节内效率**（tile 填充 / SLM / 带宽）—— 但**军规 63** 已对 WB 两腿算过"既不绑带宽也不绑 XMX"，要动得先有新的 disasm/occupancy 证据。
### 95c. **军规 76（新，入 B2）**：**跨链合并的前提是"成员写不同面"；写同一面 = 残差链的连续环节，不是并列射击 => 合并非法**（本案 244/244 都是这个挡因）。**推论：在本引擎里，能消的只有"链内相邻环节"（融合），不能消"链间同类环节"。**

## 96. ★ 阶段 A 交回：`tools/fusion_rank.csv`（16 行）+ **`ffn` 身份钉死** + 代理自认两次口径错（方法入账）。**A 阶段零 GPU**
**① 两次口径错（都修了）**：
- **v1 用"同族相邻段"当排序单位 => 几乎全是 `none`**：错。本引擎的融合是**同一链上相邻的不同族腿并进一核**（A5 = quant_window -> qkv -> wa -> … 五相一核），而 §106 已证**同族相邻对 = 0** => **用已知为零的口径筛融合候选，筛不出东西**；
- **v2 的 scope 回落把未映射区连成 16-17 腿的巨段**（C512 attention 区不在 `chain_map` 的闭包范围里）=> 上限虚高。修 = **段长封顶 8 腿**（一条链实际 6-11 个 op：A5 并 5、S6-1a 并 6、port-E CHAIN2 并 11 个 plan op）+ scope 标签统一。
**② ★ `ffn` 身份（军规 23）钉死**：`s6_on()` 默认 ON（S6-1a 转正，`NR_S6_FFN=0` 逃生口），**但 `s6_family(C,HID)` 只认 `C==64&HID==256` 与 `C==128&HID==512`** => **S6 融合的是 C64/C128 链的六相块**；账上 `xmx_rec_ffn` 的 **8 条腿在 closure 2/4/6/8/681/683/685/687（每腿 0.77-1.18 ms、共 6.237 ms）是 ViT 前后块的 FFN（另一档，未被 S6 覆盖）=> 未融合** ✓。同一区还有 `ffn_stem`@0（1.717）、`ffn_merge`@689（3.554）、`unary2`@680（1.340）、`window_block`@1/3/5/7/9/682/684/686/688/690（18.187）。**=> `ffn 6.24(8)` 是干净的未融合账，不是融合核自己的价。**
**③ 排序表（上限带 33.3%-42%，两端都是实测：33.3% = bench CHAIN2 合并率 0.9413/1.4112；42% = A5 在帧内兑现（6.875 ms att 半区省 42%）=> CEILING 不是承诺）**
| family | 腿 | 已融腿 | 每腿 ms | 含该族的融合段 | 段内串行合计 | **上限带** | 单位价值 | 先例距离 |
|---|---|---|---|---|---|---|---|---|
| **window_block** | 10 | 0 | **1.819** | 4 | **31.78** | **10.58-13.35** | **0.525（最高）** | **无可抄先例**；§105 已证两腿 v4ph 既不绑带宽也不绑 XMX（军规 63）=> 浪费在 latency/occupancy，融合未必治 |
| **ffn** | 8 | 0 | 0.780 | 3 | 22.72 | 7.57-9.54 | 0.351 | **S6-1a 有逐字节验证的融合块核**（`s6_ffn_block4.cpp`/`port_ffn_fused.cpp`）=> 可抄 |
| gemm_int8_qkv | 60 | 7（A5）| 0.161 | 53 | 35.40 | 11.79-14.87 | 0.222 | **A5 就是它自己的融合核** => 最近 |
| **global_attention** | 8 | 0 | **1.434** | **8（每 C512 链一段：317..319 / 325..328 / 334..337 / 343..346 / 352..355 / 361..364 / 370..373 / 379..382）** | 17.36 | 5.78-7.29 | 0.241 | A5 的同结构先例（不同档）|
| window_attention | 52 | 7（A5）| 0.196 | 45 | 18.04 | 6.01-7.58 | 0.134 | A5 |
| gemm_int8_residual | 68 | 0 | 0.295 | 8 | 16.33 | 5.44-6.86 | 0.080 | 无融合孪生 |
| gemm | 42 | 0 | 0.167 | 40 | 25.03 | 8.33-10.51 | 0.198 | R8a/P12b 已并（§94 实测宽形 = 亏）|
| gemm_int8_batched | 72 | 0 | 0.068 | 52 | 27.70 | 9.22-11.63 | 0.128 | P8-b 已并 N=32；§94 判放宽 = 亏 |
| quant | 224 | 144（qfuse）| 0.014 | 60 | 45.06 | 15.00-18.92 | 0.063 | qfuse 已并大头 |
| gemm_window_int8_residual | 52 | 0 | 0.218 | 38 | 25.57 | 8.52-10.74 | 0.069 | 无 |
**④ 三条红线（代理点出，我要它在动手前先认）**：
1. **A5 结构的直接延伸（C512 att 段）在 SLM 上是红的**：A5 在 C=64 用 31,744 B / 2 resident；**C128 档 41,984 B 越崖 => +51% 更差**（实测）；C512 照 A5 结构只会更糟 => **"并成一核"若照 A5 抄是先红的设计**（军规 22/30/63）；要做就得**换切分（沿 C 内循环）= 新设计**；
2. **window_block 的融合没有可抄核**，且 §105 说它**不绑带宽也不绑 XMX** => 融合不一定治它的病；
3. **屋顶缺口（军规 26/35a）**：`xmx_roof.csv` 里 **attention/wb/ga 三族 0 个同形屋顶点**（qkv 0/60、wa 0/52、ga 0/8、wb 0/10）=> 任何倍率都得先补屋顶；而现有 `shape_roof_probe.exe` 只跑 gemm 腿（`gemm_b/pub`），**wb/ga 的地板是带宽型（§6.22 整面流量法），不是 dpas 屋顶** => 补这型"屋顶"要**新造一套计价臂**。
**方法入账（军规 77 候选）**：**排序口径必须匹配被筛对象的真实结构**（本案：融合是"异族相邻腿并一核"，用"同族相邻"筛 = 用已知为零的口径筛东西）；**且未映射区不得连段**（scope 回落要封顶）。

## 97. ★★★★ **B3 中途急报：`ffn` 那 8 条腿早就在一核上（`NR_FFN_CHIP` 默认 ON、4.4x、BIT-EXACT）=> 我 §116 的身份判定半错；B3-c 不跑（跑它 = 为已转正的东西花 GPU，ratio 必然 ≈1）**；同时挖出一条更深的口径错：**"没开关"不等于"没融合"**
### ① 证据（源码正文，不是名字）：`xmx_rec_ffn`@3128-3190
```
static bool ffntile = !getenv("NR_FFN_TILE") || ...;   // 默认 ON
static bool ffchip  = !getenv("NR_FFN_CHIP")  || ...;  // 默认 ON
if (ffntile && ffchip && hidden == 128u && cin == 32u && !narrow && epi == 0u) { ... ffnc::launch_ffn_chip ... }
```
注释原话：**"P3c v3d ffn_fused CHIP kernel —— ONE launch，hidden 永不下芯片，连 pack_a16 都吃掉；bench_ffnchip **4.4x** vs 已转正的 tile-chain split，**BIT-EXACT**"**，后面还有 `NR_FFN_CHIPRES / NR_FFN_JOIN / NR_FF3 / NR_FF9 / NR_CHIP_CS` 一串默认 ON 的相位合并。
本案 8 站的 guard 全中：`cin=32` ✓ `hidden=128` ✓ `epi=(flags>>8)&0xF=0` ✓ `narrow=flags&0x1000=0` ✓ => **8/8 已在融合核上**；**closure 681 的 `flags=0` 与另七条的 `0x40000` 都不影响这个 guard => 我点的"681 三选一"根本不用选：融合核早就同时覆盖两形**（§117 白排了一道队）。
### ② ★ 我为什么漏，以及漏得更深的那一层
- 我只查了 S6 的 `s6_family(C,HID)`（它确实只认 C64/HID256、C128/HID512），**没读 ffn 记录器自己的默认 ON 开关** => **军规 23 的教训在高一层重演：判"融合没有"不能按名字/单一开关，要按该记录器里所有默认 ON 的机制**；
- **更深一层**：按开关扫（`tools/fusion_coverage.csv`，30 个开关带 guard 原文）已能看出 qkv/wa/ga/wb/batched/gemm/quant 全有默认 ON 的合并；**但 `gemm_int8_residual` 没有开关却被标成"未融合"也是错的** —— 它正文直接调 **`s8v8::gemm_b_res`（gemm+残差一核）与 `packdev::pack_a_fused`** => **有些融合是无条件的、没有逃生口 => "没开关" != "没融合"**。
### ③ 覆盖表（`tools/fusion_coverage.csv`，生成器 `s6/pe_fusion_coverage.py`）
| 家族 | 腿 | 现值 ms | 默认 ON 的机制 | 仍 OFF |
|---|---|---|---|---|
| ffn | 8 | 6.237 | FFN_TILE + **FFN_CHIP（一核 4.4x）** + CHIPRES + JOIN + FF3 + FF9 + CHIP_CS | - |
| ffn_stem | 1 | 1.717 | FFN_DUAL（两 gemm 一核）| - |
| gemm | 42 | 7.032 | G_FOLD（publish 折进 gemm 存储）| - |
| gemm_int8_batched | 72 | 4.859 | B_WIDE + BPACK_VEC + PUB_SLM | V9B、G32_PUB |
| gemm_int8_qkv | 60 | 9.673 | QW_FUSE + **QKV_RES（QKV+残差一核）** + QKV_VITES | - |
| global_attention | 8 | 11.475 | **GA_TILE + GA_MERGE** | - |
| window_attention | 52 | 10.212 | **WA_RES + WA_RAWV + WA_TILE + WA_MERGE** | - |
| window_block | 10 | 18.187 | **WB_FUSE + WB_FUSE_PH** | **LEG3_STG** |
| quant | 224 | 3.105 | Q_FUSE（144 腿已溶解）| - |
| gemm_int8_residual / gemm_window_int8_residual | 68 / 52 | 20.06 / 11.36 | **无条件融合**（`gemm_b_res`、`pack_a_fused`）=> 无开关可扫 | - |
⇒ **§116 排序表里"未融合 => 可并"的行（ffn / ga / wa / wb / residual）全部要重标**；**真正的剩余空间不是"开关有没有"，而是"每族还剩几次发射"**。
### ④ 一条 GPU 浪费（如实认）
B3-b 按 `pe_k3_roofgroup.py` 报的"SRP_GRP=45"跑了 3 个进程，**日志打出的是 `G45_wb_534336`** => **probe 内部下标 != 我在源文件里数出来的行序** => 测的是已有屋顶点而不是缺的 `130560x32x128`。发现后**当场 kill 剩余批次**（进程 0）；**且因为 B3-c 已死、那个缺形没有消费者 => 不补**（军规 26/35a：别为不存在的手术备料）。
**军规 79（新）**：**任何组号 / 下标 / 枚举值必须用被控程序自己打出的名字回验**，不能拿源文件里数出来的顺序当口径。
**军规 80（新）**：**判"某机制有没有做"要扫该记录器里所有默认 ON 的开关 + 无条件调用**；**"没开关"不等于"没融合"**（本案 `gemm_int8_residual` 的 `gemm_b_res` / `pack_a_fused` 就是无条件融合）。
### ⑤ 正在跑（~30 min GPU，出货件 `3BAECF2A`，不 stage）：**机制存活实测表 `tools/mechanism_liveness.csv`**
八臂：基线 + `NR_FFN_CHIP=0`、`NR_FFN_TILE=0`、`NR_GA_MERGE=0`、`NR_GA_TILE=0`、`NR_WA_MERGE=0`、`NR_WB_FUSE=0`、`NR_G_FOLD=0`；每臂 1 次 walk（3 runs 取稳态）+ 1301 判定 => **(a) 该机制在帧里真的活着吗（关了就换字节 => 活着且数值参与）；(b) 它已经贡献了多少 ms/帧（关掉后的时间差）** => **这是把 §116 排序修回真实的唯一办法，也是下一铲的定价底料。**

## 98. ★★★★ **机制存活表回来：`ffn` 的 tile+chip 两环已经吃进 ~31.6 ms/帧、`gemm` 的 publish 折叠吃进 ~5.0 ms**；**`NR_WB_FUSE` 只值 +0.08 ms（在本帧几乎不做事）**；**判据修正：逐位等价的融合，字节测试没有判别力 => 存活判据 = 时间差**；**发射数代理判红（不可用）**；**`NR_LEG3_STG` 数值中性但不更快 => 不成立**
### 1) `tools/mechanism_liveness.csv`（关掉默认 ON 机制的代价 = 该机制已吃进帧的证据；**不是可回收收益**）
| 臂 | 机制 | 稳态 ms/帧 | **off-差** | 1301 | 状态 |
|---|---|---|---|---|---|
| L_base | 全默认 | **56.97** | - | EXACT | 基线 |
| **L_ffntile** | `NR_FFN_TILE=0` | 82.52 | **+25.55** | EXACT | **LIVE**（定案需 16 对）|
| **L_ffnchip** | `NR_FFN_CHIP=0` | 63.05 | **+6.08** | EXACT | **LIVE** |
| **L_gfold** | `NR_G_FOLD=0` | 61.96 | **+4.99** | EXACT | **LIVE** |
| L_gamerge | `NR_GA_MERGE=0` | 57.58 | +0.61 | EXACT | **未分辨** |
| L_wamerge | `NR_WA_MERGE=0` | 57.51 | +0.54 | EXACT | **未分辨** |
| L_gatile | `NR_GA_TILE=0` | 57.35 | +0.38 | EXACT | **未分辨** |
| L_wbfuse | `NR_WB_FUSE=0` | 57.05 | **+0.08** | EXACT | **未分辨**（这个开关在本帧几乎不做事）|
★ **军规 81（新）**：**逐位等价的融合，字节测试没有判别力** —— 八臂 1301 全部 EXACT `DD49827D`（关掉只是换一条更长的路算同样的值）=> **存活判据 = 时间差**；**字节不变在这里是好消息**（机制数值中性）。
★ **大事实**：**`ffn` 两环（tile + chip）已经吃进 ~31.6 ms/帧**；**`gemm` 的 publish 折叠吃进 ~5.0 ms**；**`window_block` 的 `NR_WB_FUSE` 只值 +0.08 ms => 那 18.19 ms 的家族不靠这个开关活着** => 与 §105"wb 两腿既不绑带宽也不绑 XMX"**互证**。
### 2) `tools/launch_map.csv`：**判红 —— 这个代理不可用**（如实，不硬凑）
用现成 `NR_SUBMIT_PROBE`（按家族汇总每闭包 CPU enqueue）跑四臂：**base 11.0 / FFN_TILE off 5.5 / FFN_CHIP off 5.0 / G_FOLD off 6.6 ms** => **每个家族 enqueue 都近乎减半，连与开关无关的家族也 -0.3~-1.3** => **冷启动/首跑效应主导，不是机制效应** => **不能用来排"还剩几次发射"**。
★ 另注：`NR_SUBMIT_PROBE` 的路径跑的是**普通闭包环、不是 cgraph 重放**，且它提前 `return` => **它的 GPU 时间不是出货路的时间，只有 enqueue 列有意义**（已写进表 NOTE）。
⇒ **真要这张图需要一台每闭包发射计数器**（`single_task/parallel_for/memcpy/memset` 上 presence-gated 计数，或转发的 queue 包装类：~15 个转发方法 + `g_lc_cur` 游标 + capture 期打点）。**代理明确拒绝当顺手小事干**（动的是 7,000 行 TU 的公共路径，军规 70/77）=> 单独一铲（40-60 min，含 `build_shipped` 基座 + 最小门链）。
### 3) `NR_LEG3_STG`：**不是候选**（三步都做了）
- **语义**（源码 6340-6395）：把 window_block 第三相 `f16v3::gemm_resid_pub` 的**直写 plan 目标面**改成**先写 pool staging + 一次 device->device memcpy**，动机是绕开 compute-to-compute 的 coherent drain => **改搬运路径，不改累加顺序/量化** ✓
- **1301**：`M_leg3`（出货件 + `NR_LEG3_STG=1`）=> **EXACT `DD49827D`** ✓ 数值中性成立
- **时间**：稳态 **57.01-57.44 ms** vs 基线 56.97 => **ON 不比 OFF 快**（差 +0.04~+0.47，未分辨偏正）=> **按判读线（>= -0.15 即停）这一铲不成立 => 没跑 16 对**（省 ~30 min GPU）；**源码注释原文早就写着："the 33MB staging + memcpy is a PURE EXTRA cost ... Default OFF (kept as the mechanism witness)"**
### 4) 两条战略读数（代理给，我确认）
**B3 正式结案**：靶已被 `NR_FFN_TILE`/`NR_FFN_CHIP` 收割（不跑 c、不补 `130560x32x128` 屋顶，没有消费者）。
**两个最大家族的钱不在消环节上**：`gemm_int8_residual` 20.06 ms/68 腿（无条件已融：`gemm_b_res`/`pack_a_fused`）与 `window_block` 18.19 ms/10 腿（开关型融合只值 +0.08）=> **要挖只能挖单环节内部（相位内访存/填充），不是融合级**。

## 99. ★★★★ **锚点差距表（`tools/anchor_gap.csv`，零 GPU）：`gemm_int8_residual` 有 77% 时间不被它的 gemm 相位屋顶解释（每腿 0.34 ms vs 相位屋顶 0.078 => 4.4 倍差距）；`window_block` 只有 17%（四相解释 83%）=> wb 不是 kernel 级靶，与 §105 完全一致**；**先记一次 v1 口径错（假信号）**
### ① ★ v1 口径错（已修，方法入账 = 军规 83）
v1 拿"整条多相闭包"去比"一条 gemm 屋顶行" => 把 `global_attention` 报成"占屋顶 2%、可挖 11 ms" —— **假信号**。
v2 按**记录器自己的 gemm 相位**（`flop_note` 元组；ga 没有 flop_note => 用它的发射调用实参）**逐相求屋顶和**。
**钉死口径**：`above_phase_roof = 实测 − Σ相位屋顶` 的含义是**"这条闭包有多少时间不被它的 gemm 相位解释"**：
- 对**纯 gemm 家族**（residual / qkv / batched / gemm / gemm_int8）=> **可读作 kernel 效率余量**；
- 对**含非-gemm 工作**的家族（ga 的 softmax/归一、wb 的 gather、wa 的 softmax、ffn 的 gelu）=> **那是别的工作，不是浪费** => **不能当可挖 ms**（军规 54/74）。
### ② 结果：258 条活闭包里 **177 条有完整相位屋顶**
| family | 完整屋顶腿 | 实测 ms | **不被相位屋顶解释** | 占比 | 该怎么读 |
|---|---|---|---|---|---|
| **`gemm_int8_residual`** | 42 | 14.348 | **11.118** | **77%** | **真余量**：每腿 0.34 ms vs 相位屋顶 0.078 => **4.4 倍差距** |
| `global_attention` | 8 | 11.475 | 10.679 | 93% | **不是效率余量**（softmax/归一/merged 面搬运没进相位）=> **要先有"非-gemm 相"的地板才能判** |
| `gemm_int8_qkv` | 40 | 9.319 | 5.853 | 63% | 真余量（含 Q/K/V 三面写出 + 归一 scatter）|
| `gemm_window_int8_residual` | 18 | 4.765 | 4.155 | 87% | 真余量（含 gather/crop + publish）|
| `gemm` (f16) | 18 | 4.553 | 3.770 | 83% | 真余量 |
| `gemm_int8_batched` | 18 | 4.729 | 3.175 | 67% | 真余量（P8-b 之后）|
| `window_attention` | 16 | 4.328 | 2.695 | 62% | 含 softmax |
| `gemm_int8` | 10 | 2.695 | 2.083 | 77% | 真余量 |
| **`window_block`** | **7** | **11.622** | **2.012** | **17%** | **四相解释了 83% 的时间 => wb 不是 kernel 级余量的靶**（与 §105"两腿 2.02-2.17 vs 锚点 2.20 TOPS"完全一致）=> **我"先别再补 wb"那条令被数据证实** ✓ |
**单闭包 top**：ga 八腿（各 1.30-1.38 ms 不被解释，**先要非-gemm 地板**）=> **wb c690 只有 0.488（已 88.6% 贴顶 => 没肉）** => **`residual` c29 0.484 / c662 0.480 / c18 0.471（实测 0.55 vs 相位屋顶 0.078）=> 这才是该挖的对象**
### ③ 缺的**同形相位屋顶**（按腿数 x 实测 ms 排）
| 缺的相位形 | 影响腿 | 那些腿实测合计 |
|---|---|---|
| **`int8 8160x128x128b1`** | 12 | **5.680** |
| **`f16 130560x32x128b1`**（ffn project 相）| 8 | **6.237** |
| `f16 64x64x32b540` / `64x32x64b540`（wa 两相）| 6+6 | 1.979+1.979 |
| `f16 64x64x32b576` / `64x32x64b576` | 6+6 | 2.013+2.013 |
| `int8 8640x128x128b1` / `9216x128x128b1` | 6/6 | 1.538/1.655 |
| `f16 130560x96x32b1` / `130560x64x32b1`（wb 两相）| 2/2 | 2.322/2.322 |
### 军规 83（入 B2）：**锚点/屋顶对照必须按记录器自己的相位逐相求和**（`flop_note` 元组；没有 flop_note 的，用发射调用实参），**不许拿"整条多相闭包"比"单条 gemm 屋顶行"**；并且**`实测 − Σ相位屋顶` 只对纯 gemm 家族可读作 kernel 效率余量**，含非-gemm 工作的家族（ga 的 softmax/归一、wb 的 gather、wa 的 softmax、ffn 的 gelu）那是别的工作量，不是浪费。

## 100. ★★★★ **v3 锚点表（加了字节地板）把方向定死了：`gemm_int8_residual` headroom 12.13 ms，其中 46/54 腿是字节绑定 => 杠杆不是填充率，是流量**；**`ffn` 补上 project 相屋顶后 headroom 只剩 1.61 ms => 胖 ffn 彻底没肉**；**`window_block` 三点互证不是靶**
### (2) 补屋顶（军规 79 这次照办）
先从 `GROUPS` 字面量数条目定下标（53 条 => 新组 = 53/54），**再在每次进程输出里回读探针自己打的组名** => 12 次全部对上：`G54_i8_8160_128_128`、`G55_f16_130560_32_128` ✓
协议：min-of-15x5、nosink、**每点 12 个独立进程**（首轮 6 个的 spread 22-123% => 低置信 => 又跑 6 个池化；批前冷却 300 s）；台账 `grf=128 simd=1 slm=10,240/18,432 scratch=0 scratch_instr=0` ✓
★ **工具缺口如实记**：**`private/spill` 仍是 `-`** => `mk_roof_ledger.py` 走 ocloc disasm 那条路不吐这两列，**要读 `.state/.hw` 资源段才行**。**这条不修，健康闸第 4 条（计价腿 private/spill/scratch=0）在屋顶点上就无法执法。**
★ **低置信标注（必须一起读）**：`int8 gemm_b 8160x128x128` **spread 143.9%**、`f16 8160x128x128` 42.0%/37.5%、`gemm_b_pub` 42.6%；**只有 `int8 gemm32_b_pub 130560x32x128`（1.2%）算硬** => **residual 族的 headroom 有一部分建在低置信行上，用前需重测或取池内 min**（军规 35b）。
另：代理自己修了一处算错——合并脚本把 **TOPS 多乘了 1e3**（GFLOP/ms 本身就是 TFLOP/s）=> 8 行全改回（3.0-9.5 TOPS，与旧行同量纲）✓
### (1) v3 锚点表（`tools/anchor_gap.csv` 14 列；197/258 条活腿有完整锚点；**锚点 = max(相位计算屋顶, 字节地板)**）
| family | 有锚点的腿 | 实测 ms | **headroom** | 字节绑定的腿 |
|---|---|---|---|---|
| **`gemm_int8_residual`** | **54/54** | 20.03 | **12.13 ms** | **46** |
| `global_attention` | 8 | 11.48 | 10.68 **不可当可挖**（softmax/归一/merged 面搬运不在相位模型里）| 0 |
| `gemm_int8_qkv` | 40 | 9.64 | 5.52 | 26 |
| `gemm` (f16) | 18 | 7.00 | 3.32 | 18 |
| `gemm_int8_batched` | 18 | 4.73 | 3.17 | 2 |
| `window_attention` | 16 | 10.18 | 2.70 | 0 |
| `gemm_window_int8_residual` | 18 | 11.33 | 2.24 | 18 |
| `gemm_int8` | 10 | 2.70 | 2.08 | 8 |
| **`window_block`** | 7 | 18.19 | **2.01（17%）** | 0 |
| **`ffn`（新锚上）** | 8 | 6.24 | **1.61** | 0 |
★ **判决级两条**：① **`ffn` 补上 project 相屋顶后 headroom 只剩 1.61 ms => B3/胖 ffn 彻底没肉**（已在 chip 一核 + 贴着相位锚点）✓✓；② **`window_block` 四相解释 83% => 不是 kernel 级余量的靶**（§105"两腿 2.02-2.17 vs 锚点 2.20" + §98 `WB_FUSE` off-差 +0.08 ms + 本表，**三点互证**）✓
⇒ **真正的 kernel 级靶 = `gemm_int8_residual`（12.13 ms，46/54 腿字节绑定）+ `gemm_int8_qkv`（5.52 ms，26 腿字节绑定）**；**"字节绑定"这四个字把杠杆方向定死了：不是填充率，是流量。**
### (3) `tools/kernel_levers.csv`
- **L1 int8 BM 128->64（填充）**：M=192 => 2 行 tile 发 256 行算 192 = 75% 填充 -> BM=64 三 tile = 100%。**但 `gemm_s8_v5_kernel.hpp` 自己的注释记着第一次 BM=64 尝试是坏的**（`WI_ROWS=BM/16` 8->4 => `offA=wi_row*512` 越过 SLM_A 2,048 B）=> **这是 WI 映射重写，不是参数翻转**；SLM 18,432 -> ~16,384 B（32,768 线下 ✓）；**barrier/跨-WI staging 要重派生 => 军规 30/63**；**BM=64 的 int8 形没有屋顶点 => 先补屋顶才许谈倍率**；
- **L2 int8 BN 64->128（B 重读流量）★ 方向对的那个**：列 tile 16->8、A-tile 重读减半；SLM_B 2,048->4,096、总 SLM ~20,480 B（<32,768 ✓）；WI_COLS 4->8 => NT 32->64 或改映射；**`s8v9` 已经是 BM=64/BN=128 的现成核，但它在帧形上没有屋顶点 => 下一步补它**；
- **L3 f16 v1->v2（4x 复用）**：**已在 P12a 被一次 3 对 A/B 判过 NEUTRAL => 重开必须 >=10 对**；且 f16v2 帧形无屋顶点；
- **L4 window_block：不建议任何杠杆**；
- **L5 global_attention：先修锚点再谈杠杆**（softmax/搬运没有地板模型 => 那 10.68 ms 不是钱）。
### 一条源码状态（我裁定）
工作区那处 `M libxmx_sycl.cpp` = 代理给 `NR_SUBMIT_PROBE` 加的**暖机循环**（只影响诊断臂、不碰出货路；变体 `builds/libxmx_b4lm.dll = AC19B3EB…`）。**我的裁定：留着并入库**（presence-gated、诊断专用；它不伤出货路，而且若以后重开"发射计数器铲"，这是唯一半成品）；**但发射计数器铲仍然压住**，且**已入库的 §98 那张代理表标红结论不变**。

## 101. ★★★★★ **A+B 交回（零 GPU）：A 查出的不是工具缺口而是标签错；B 把靶从"加宽 tile"翻成"波次填充"，并给 1 字节残差面算了上限**
### A：**ocloc 1.73 根本不吐 `private_size`/`spill_size`** => 过去所有表里的 `-` 是**"键不存在"，不是"值为 0"**
- 每核只吐：`grf_count / simd_size / slm_size / barrier_count` + **只在真有 scratch 时出现的 `type: scratch ... size: N` 块**；
- ⇒ **§60 那句"`port::fused` = private 6,304-6,464 B"是标签错：那些数是 SCRATCH 字节**（`spillcheck_port.py` 里 `g(private_size)/g(spill_size)` 恒为 `-`，6,304-6,464 来自 scratch 块）；**结论不变而且更硬**：scratch 是走 DRAM 的溢出，比 private 更糟 => `port::fused` 照样过不了健康闸第 4 条；我们自己的 `ffn2/ffn3/f16v2/packdev::*` 全部 **scratch 0/0** ✓
- **修好的工具 `s6/mk_roof_ledger2.py`（三处）**：① **块窗口 = 到下一个 `- name:` 为止**（原来固定 6,000 字符，长 payload 会把资源字段推出窗外 => **这就是有些行连 `slm` 都读成 `?` 的原因**）；② **列名诚实化**：`scratch_bytes/scratch_instr` 真值，`private/spill` 一律写 **`n/a(ocloc1.73)`**，不再用 `-` 冒充 0；③ **两颗牙内建**（跑在 `E:\DSH\sycl-cache-portE`）：**牙 1（脏核必须非空）** `port::fused` => **scratchB 6,336/6,464、scratchInstr 181-197 PASS** ✓；**牙 2（净核必须 0/0）** `quantize_row` => **0/0（12 行）PASS** ✓
- **台账刷新**：`tools/xmx_roof.csv` 184/252 行按新语义重写（`int8 gemm32_b 130560x32x128` 的 slm 从 `?` => **15,360**；`gemm32_b_pub` 10,240；`gemm_b` 18,432 ✓）
### B：`tools/traffic_breakdown.csv`（tile 常数取出货 `gemm_s8_v5_kernel.hpp` 的 **BM=128/BN=64/BK=32** => 重读因子是算术不是猜）
**先排一颗雷（交前自查）**：第一版把 **A5/qfuse 的融合与 no-op 闭包**塞进流量模型 => 算出 **3,300-6,500 GB/s（560 锚点的 600-1,100%）** 的荒谬等效带宽 => 修 = **排除带 `(A5-fused)`/`(FUSED-pack)` 标记与 ms<0.02 的腿**（7 条）=> 159 条腿现在全部合理
| family | 腿 | A 重读 MB | B 重读 MB | 残差面读 MB | 输出面写 MB | 合计 MB | **加宽 tile 能砍** | **只有改面宽能砍** | tile 份额 |
|---|---|---|---|---|---|---|---|---|---|
| qkv | 39 | 10.5 | 5.2 | 0 | **172.6** | 189.2 | 5.2 | 86.3 | **5.6%** |
| residual | 54 | 7.8 | 3.9 | **82.8** | **82.8** | 178.9 | 3.4 | 82.8 | **3.9%** |
| winres | 38 | 2.9 | 1.5 | **85.0** | **85.0** | 176.0 | 0.9 | 85.0 | **1.1%** |
| batched | 18 | 4.3 | 2.1 | 0 | 68.2 | 75.7 | 2.1 | 34.1 | 5.7% |
| gemmint8 | 10 | 4.4 | 2.2 | 0 | 13.9 | 20.6 | 2.2 | 6.9 | 23.9% |
### ★ 三条硬结论（B 决定靶）
1. **字节花在"输出面写 + 残差面读"**：residual/winres 各 ~168 MB，占合计 **94%** => **L2（BN 64->128）最多砍 1-6% => 不是杠杆**；**而且对 N=64 的腿 BN=128 是负收益（-0.03~-0.04 MB => 反而多读 B）=> L2 在 residual/winres 上被算术判死**；
2. **"只有改面宽能砍"的那一半 ≈ 85 MB/族 = `NR_RES_BYTE` 的路**（当年死在时间上 0.49-0.76x）=> **B 表现在给出它的上限：residual/winres 各约 42-85 MB 的流量下降**；
3. ★★★ **最深的发现**：最大流量的腿（c18/c29/c34/c53...）**实测只有 15-44 GB/s = 560 锚点的 2.7-7.9%** => **既不贴计算屋顶、也不贴字节地板 => 是"每工作组效率/波次填充"问题**：residual 的 `M=32,640 N=64 K=64` 在 BM=128/BN=64 下**只有 255 个工作组（不到一个满波）** => **L1（BM 128->64）的意义从"填充率 75%->100%"升级为"工作组数 255->510（把波次填满）"** => **这正是必须测 s8v9（BM=64/BN=128）屋顶的理由 —— C 的靶被 B 正面定出来了**
### 军规 86/87/88（入 B2）
**86**：**台账列名诚实化**：`-` 不得用来同时表示"键不存在"和"值为 0"；ocloc 1.73 不吐 `private_size/spill_size` => 必须写 `n/a(ocloc1.73)`。并**重核历史结论**（本案 §60 的 "private 6,304-6,464B" 其实是 SCRATCH 字节 => 结论更硬，因为 scratch 走 DRAM 比 private 更糟）。
**87**：**解析器固定字符窗是隐形 bug**：窗口 6,000 字符在长 payload 下会把资源字段推出窗外（症状 = 某些行连 `slm` 都读成 `?`）=> **块边界必须按结构（到下一个 `- name:` 为止）**，不按长度。
**88**：**判"一条腿被什么绑定"要同时算三个地板**：① 计算屋顶（同形 dpas 点）② 字节地板（合计字节 ÷ 实测带宽）③ **波次填充（工作组数 ÷ 可并发数）**。本案 residual 前两个都不绑（2.7-7.9% 带宽、不贴计算锚点），**第三个绑**（255 WG < 一个满波）=> 杠杆是 tiling/发射形状，不是面宽。

## 102. ★★★★★ **C+D 交回：今晚第一个能站住的核内判决，以及一次把全晚账翻底朝天的置信审计**
### C：s8v9（BM=64/BN=128 宽生产者）屋顶 —— **判死，而且顺手否证了我自己 B 表里的"波次填充"假设**
**先一条对 C 清单的修正（重要）**：s8v9 的头写死 **`N MUST equal BN=128`**；而 §99 在引擎里把这条路径钉在 **`if (false && ...)`** 上，理由原文：**"every frame N=128 batched call is multi-group INTERLEAVED (sc=128 < ldc=256) and its quant row-max SPANS BOTH groups columns => a per-workgroup fused requantize cannot see the other group columns => the fold is invalid for these shapes"**
⇒ **我上一条列的 `192x1024x4096`(N=1024) 与 `192x192x128`(N=192) 都在 v9 定义域外**；**v9 在帧里唯一合法的定义域 = 单组 N=128 三条形**：`8160x128x128 b1`（12 腿 / 5.72 ms）、`9216x128x128 b1`（6 腿 / 1.51）、`8640x128x128 b1`（6 腿 / 1.49）=> 按此改测 8160 那一形（决策腿最多），另两形已建组（`G56`/`G57`）**未测**
| dtype | leg | shape | nproc | msM_med | **spread** | TOPS | grf/simd/**slm** | scratch/instr |
|---|---|---|---|---|---|---|---|---|
| int8 | **`gemm_b_rq_v9`** | 8160x128x128 b1 | **12** | **0.2345** | **0.6% => 硬** | 1.140 | 128/1/**13,312 B** | 0 / 0 |
| int8 | `gemm_b_pub`（出货 v8）| 同上 | 12 | 0.0786 | 42.6% ✗ | 3.400 | 128/1/18,432 | 0 / 0 |
| int8 | `gemm_b`（raw）| 同上 | 12 | 0.0280 | **143.9%** ✗ | 9.533 | 128/1/18,432 | 0 / 0 |
| int8 | `gemm32_b_pub` | 130560x32x128 b1 | 12 | 0.1146 | **1.2% => 硬** | 9.333 | 128/1/10,240 | 0 / 0 |
★ **判决**：**v9 健康面完全没问题**（SLM **13,312 B** 比 v8 的 18,432 还小、远在 32,768 两条线之内；scratch 0/0；barrier 1）；**但时间上 v9 = 0.2345 ms vs 出货 v8 `gemm_b_pub` = 0.0786 ms => 慢 3.0x**；**公平口径**要加 v9 吃掉的 quant 腿：8160x128 的 f16->int8 量化按字节地板只有 **~0.003-0.03 ms** => **v8+quant <= 0.11 ms => v9 仍慢 1.8-2.1x** => **宽生产者 + 融合重量化在本案帧形上判死**；
★★ **顺带证伪 B 表的"255->510 工作组、把波次填满"假设**：v9 正是行 tile 减半、组数翻倍的那个核 => **翻倍组数没让它更快，反而慢 3x => 这些腿的瓶颈不是波次填充**（**军规 90：假设必须由它自己的实验判死，不能留在账上当前提**）
### D：置信审计把全晚的账翻底朝天（`tools/anchor_gap.csv` v4，新增 `roof_confidence`）
**硬标准**：该相屋顶须 **`nproc>=12` 且 `spread<=20%`** 才算 `hard` => **`HARD-anchored = 0 / 258 条活闭包`；`low-conf = 197`；`no-roof = 61`**
⇒ **今晚我报过的所有 headroom（residual 12.13 / qkv 5.52 / gemm 3.32 / wb 2.01 / ffn 1.61）全部建在 6 进程或高 spread 的旧屋顶行上 => 按 D 的规矩，一条都不许进建议**；旧台账 244 行是军规 35b 收紧之前测的 => **这是历史数据的置信债，不是今晚算错**（v4 表每条都标了 `low-conf(spread=...%,nproc=...)`）
⇒ **全台账现在只有两行 `hard`**：`int8 gemm32_b_pub 130560x32x128`(1.2%) 与 `int8 gemm_b_rq_v9 8160x128x128`(0.6%) => **恰好就是 C 那条判决用的两行**
### 代理的单一靶建议（诚实版 = 否证 + 一张补置信工单）
1. **不再提任何 L1/L2 型核内几何靶**：唯一有硬锚点的形状上，宽生产者慢 1.8-3.0x => **核内 tile 几何这条路被自己的数据关掉**；
2. **B 表的算术不依赖屋顶（因此不受置信债影响）仍成立**：residual/winres **94% 的字节在 f16 残差面读 + 输出面写**，加宽 tile 只砍 <=6% => **若还要动核，只剩"改面宽"（`NR_RES_BYTE` 那条路）**；**但同一张表也算出：`8160x128x128` 的字节地板只有 7.7 us，出货腿实测 78.6 us => 10 倍于地板** => **面宽最多解释这 10x 里的一部分 => 先补"到地板之间那 ~70 us 是什么"的证据（launch/同步/occupancy），否则任何面宽刀都是赌**；
3. **补置信工单**：residual/qkv/batched 三族帧形屋顶重测到 **12 进程 + <=20% spread**：约 **10 形 x 12 进程 ≈ 40-45 min GPU** => 做完才允许再谈 headroom 排序与靶；
4. **另两形 v9（8640/9216）已建组未测**：要把 v9 否证从 1 形扩到 3 形，**24 进程 ≈ 30 min**（同协议）——按 8160 的读数预判同向。
### 军规 90/91/92（入 B2）
**90**：**假设必须由它自己的实验判死，不能留在账上当提**（本案：B 表推"波次填充是绑定点"，而专为验证它测的 v9 反而慢 3x => 该假设当场撤销，不得继续用它给任何刀定价）。
**91**：**屋顶置信标准 = `nproc>=12` 且 `spread<=20%` 才算 `hard`**；不满足的行不得进建议，且**引用历史 headroom 数字时必须同时标 `low-conf(spread,nproc)`**（本案：258 条活闭包 `HARD=0`，全晚 headroom 皆为低置信）。
**92**：**"实测 >> 字节地板"要先分解那一段差距**（launch/同步/occupancy/依赖等待），**否则任何"减字节"的刀都是在 10x 差距里赌一小块**（本案：地板 7.7 us vs 实测 78.6 us）。

## 103. ★★★★ **进度急报三条：(a) 一次 40 分钟空枪（已修，规矩入账）；(b) 我上一条那句"v9 把组数翻倍"是错的 => 波次填充假设**未被检验，而不是被证伪**；(c) 臂 C/D 先出数：**"到地板之间那 ~70 us"的首要解释 = 设备填充只有 8.3%**
### (a) 空枪事故（如实 + 已修）
第一次启动 48 进程批之后，**rep3 起每轮都是 `shape_roof_probe.exe: CommandNotFound`**，白占 ~40 分钟（**GPU 没被用 => 机器没热**）。
**根因**：在批跑**进行中**去编译带解剖腿的新版，**那次编译 `exit=1` —— icx 失败时不产出 exe 并把旧文件清掉** => 被测件在批跑中途消失。
**三条教训（军规 93）**：① **绝不在测量批进行中重建被测件**；② **批脚本必须开工自检**（先断言 exe 存在 + md5 稳定）；③ **`$ErrorActionPreference=Continue` 会把 `CommandNotFound` 咽掉 => 失败必须让批中止**（这是 §47"删 exe 后继续跑"的同族，这次是编译失败删的）。
现状：解剖臂 A 编译通过（`exit=0`，exe 756,736 B @06:24:53）=> 已重启 **4 形 x 12 进程**（`G17_qkv256_2560_768`、`G24_batched_2040_128_256_b8`、`G49_res_32640_64_64`、`G54_i8_8160_128_128`，**每轮回读探针自己打的组名** ✓ rep1 已验 G17 对名）；**臂 A 单独 12 进程随后跑，不混进这批**。
**臂 B（同网格只 load 不 dpas）已延后**：这个 esimd 版本**没有** `simd<int8_t,N>::slice<>`、**也没有** `esimd::reduce_add` => 保活写法不可用 => **如实记为工具缺口，不假装有数**。
### (b) ★ 更正 §122 一句话（纯算术）——**军规 90 用错了一次，这里改回**
`8160x128x128 b1`：v8(BM=128/BN=64) => `(8192/128)x(128/64) = **128 组**`；v9(BM=64/BN=128) => `(8192/64)x(128/128) = **也是 128 组**`
⇒ **"v9 把组数翻倍"作废** => v9 慢 3.0x 与填充无关（是 **BN=128 的 B-tile + 融合重量化更贵**）；
⇒ **"翻倍组数能否填满波次"这条假设仍未被检验**（**不是被证伪**）。**军规 90 的正确写法：假设要么被实验判死、要么标 `未检验`，不得当提**；我上一条按"已证伪"入账是过头了，现改回"未检验"。
### (c) 臂 C + 臂 D（CPU 算术，已落 `tools/leg70us_decomp.csv`）
- **臂 C**：出货 `gemm_b_pub` 该形 **NT=32、128 个工作组、SLM 18,432 B/组** => 每 EU 驻 `65,536/18,432 = 3` 组；**A770 = 512 EU（32 Xe-core x 16，设备规格数、本会话未实测）** => **容量 1,536 组 => 填充 128/1,536 = 8.3%**；
- **臂 D**：唯一操作数 3.2 MB => **地板 5.6 us**；按 tiling 重读（A x2、B x64）=> **9.4 us（pub C）/ 13.1 us（raw C）**；实测 **78.6 us => 6-8 倍于地板**；
- **两者相乘刚好对上**：**8.3% 填充 => 可用带宽约 1/12 => 9.4 x 12 ≈ 113 us >= 78.6** => **"那 70 us"首要解释是设备填充不足，不是 launch 开销、也不是流量**；
★ **可检验推论（下一铲候选）**：抬填充只有**增加工作组数** —— **`BN 64->32`（`gemm32_b_pub` 已存在）=> 128 -> 256 组（16.7%）**；或 **split-K（K=128 -> 4x32）=> 512 组（33%）**。
探针现在按 `N%64==0` 自动选 BN=64 => **要加一条 `SRP_FORCE32=1` 腿才能在 N=128 形上测到 BN=32 的屋顶**。
### 军规 93/94（入 B2）
**93**：**测量批进行中绝不重建被测件**；**批脚本开工必须断言 exe 存在 + md5 稳定**；**`$ErrorActionPreference` 不得用 `Continue` 吞 `CommandNotFound`，失败必须让批中止**（icx 编译失败会**删掉旧 exe 且不产出新的** => 批会静默空跑）。
**94**：**设备填充率（工作组数 ÷ (EU 数 x 每 EU 驻留数)）是第三个地板，且常常是首要解释**；EU 数用设备规格时要标"未实测"。正案：`8160x128x128` 出货腿 128 组 / 容量 1,536 组 = **8.3% 填充**，字节地板 9.4 us vs 实测 78.6 us => **9.4 x 12 ≈ 113 us 与实测同量级**，填充不足是首要解释而非 launch 或流量。

## 104. ★★★★★ **晨报到：填充假设成立（BN=32 在真实形状上快 2.1x，HARD 读数）+ 并发容量实测 + launch/流量两条解释被排除**；`HARD` 从 0 回填到 **26/258 条腿可排名，硬 headroom = 5.96 ms 串行（约 2.6 ms/帧上限）**
### ① 新增（有硬数据）
1. ★ **填充假设成立**：`8160x128x128 b1` 上 **BN=32（256 组）= 0.0370 ms、spread 2.2%、12 进程 => HARD**；出货 BN=64（128 组）= 0.0782 ms => **快 2.1x**（且比 BN=64 那 36 个进程里最快的一次还快 >=1.6x）=> **高于预登记的 1.3x 线**。证据 `tools/xmx_roof.csv`、日志 `s6/SHAPE_ROOF_f32.log`；
2. ★ **并发容量已实测**（替代规格数）：同一空核（NT=32、SLM 18,432 B/组）扫 WG：**64 => 2.80 us、128 => 2.90、256 => 2.90、512 => 3.10、1024 => 3.55、2048 => 4.65** => **真实容量 ~512-1024 组，加组几乎免费**（512 组只比 128 组贵 0.2 us）。证据 `tools/capacity_curve.csv`；
3. **launch 不是瓶颈**：臂 A 空核（该腿确切网格 128 组）= **2.9 us = 78.6 us 的 3.7%**；
4. **流量不是主因**：字节地板 5.6 us（唯一操作数）/ 9.4 us（含 tiling 重读）=> **只解释 7-17%**（`tools/leg70us_decomp.csv`）；
5. §60 的 "private 6,304-6,464 B" 是标签错（ocloc 1.73 不吐那两列，数值来自 scratch 块）=> 两颗牙已验（`port::fused` scratchB 6,336/6,464 + instr 181-197 PASS；`quantize_row` 0/0 PASS）=> 台账列名诚实化 `n/a(ocloc1.73)`；
6. **字节花在哪（算术，不依赖屋顶）**：residual/winres **94% 流量在 f16 残差面读 + 输出面写**；加宽 tile 只砍 <=6%；**BN=128 对 N=64 腿是负收益`（`tools/traffic_breakdown.csv`）。
### ② 推翻 / 更正（自报）
7. **B3（ffn 链内融合）判死**：`NR_FFN_CHIP/NR_FFN_TILE` 默认 ON 已把 ffn 融成一核（guard 全中 8/8）；补上 project 相屋顶后 **ffn headroom 只剩 1.61 ms**；
8. **存活表**：`NR_FFN_TILE=0` 帧 **+25.55 ms**、`NR_FFN_CHIP=0` +6.08、`NR_G_FOLD=0` +4.99、`NR_WB_FUSE=0` 仅 +0.08；**八臂 1301 全 EXACT => 字节测试对逐位等价融合无判别力**（军规 81/82）；
9. **`HARD=0/258` 的置信债**已用 4 形 x 12 进程回填 => **现在 26/258 可排名**；
10. 两条说过头的话已收回：(a) "v9 把工作组数翻倍" => 错（v8/v9 该形都是 128 组）；(b) "8.3% 填充" => 规格推算，**已被实测曲线取代（~1/4-1/8）**；
11. 一次 40 分钟空枪已自报并修（批中重建被测件 => exe 消失）+ 军规 93。
### ③ 能进建议的 headroom（`tools/anchor_gap.csv` v5，只有 hard 行参与）
| family | 可排名腿 | 实测 ms | **硬 headroom（串行）** |
|---|---|---|---|
| `gemm_int8_residual` | 8 | 4.293 | **3.146 ms** |
| `gemm_int8_qkv` | 16 | 3.808 | **2.131 ms** |
| `gemm_window_int8_residual` | 2 | 0.968 | **0.681 ms** |
| **合计** | **26 / 258** | 9.069 | **5.96 ms** |
**口径警告（必须一起读）**：residual 腿的硬锚点取的是 `int8 gemm_b 32640x64x64`（raw，16.7% hard），而出货腿是 **pub 形态**（同形 `gemm_b_pub` spread 38.3% 不硬）=> **raw 锚点低估 => 3.146 ms 是上限**；`int8 gemm_b 8160x128x128` 池到 36-60 进程仍 spread 146-148% => 该 raw 屋顶在本形不可用；**v9 与 `_forced` 行不进锚点**（v9 未出货；forced 的 B 面按 BN=64 打包 => 时间有代表性、数值无意义）。**不是空表，但只有 26 条腿够硬**；其余 232 条要再回填（每形 12 进程 => 全量 18 形 ≈ 7-9 h；前 8 形 ≈ 3.2 h）。
### ④ 填充判决与 split-K 的一条诚实标注
**成立**（①-1）：组数翻倍 => 快 2.1x；加组代价已被容量曲线证明几乎免费；launch/流量两条被排除。
**但 split-K（512 组）那一臂不可测**：树里没有 s8v8 的 split-K 核（split-K 只在 ffn2 的 int32 相位合法，f32 累加相位明令禁止）=> **不写新核 => 如实标"不可测"**，不拿它当证据也不拿它当反证。
### ⑤ 下一铲两个候选（前置证据状态）
**候选 1（推荐）：把 N=128 的 int8 腿从 BN=64 改路由到 BN=32（`gemm32_*` 核已在树里，N=32 的腿已经这么走）**
- 已满足：屋顶（HARD 0.0370）✓、容量曲线 ✓、A/C/D 分解 ✓、影响面（`gemm_int8_batched` 18 腿 4.73 ms + residual/winres 里 N=128 子集）✓；
- 仍缺：(a) 引擎侧 **BN=32 的 `pack_b` 布局与 `gemm32_*` 的 stride 约束在 N=128 形上是否成立**（4 个列 tile、sc/ldc 兼容性）——**纯读码可定**；(b) **bench 成对单价**（军规 74：现路 vs BN=32，>=10 进程/形、同进程配对、**逐字节 diff=0**、计价腿 scratch/spill/private=0）；(c) 改路由时 **barrier/occupancy 审计沿用**（同核不同路 => 核未变；军规 63 的"先算 DRAM 份额"已做）；
**候选 2：面宽 `NR_RES_BYTE`（1 字节残差面）**：B 表支持方向（94% 字节在残差/输出面）✓，**但它砍的是流量，而流量只解释 7-17%** => **在没有"到地板之间剩余 60+ us 的新解释"之前，面宽刀的收益上限被自己的算术压住**；且它是画质刀（要过三关 + `db_meter` + `block_collapse` + 用户点头）。**=> 暂不重开，除非候选 1 兑现后仍要挖。**
### 军规 95/96（入 B2）
**95**：**"腿太宽导致工作组数不足"是一类独立的低效**，判据 = 实测容量曲线上的填充比；本案 `8160x128x128` 把 BN 从 64 降到 32（组数 128->256）=> **快 2.1x（HARD）**。**推论：路由到已有的更窄 tile 核（`gemm32_*`）是一条不改核、只改路由的刀**。
**96**：**并发容量必须实测，不能用 EU 数 x 驻留数推算**：同一空核扫 64/128/256/512/1024/2048 组 => 2.80/2.90/2.90/3.10/3.55/4.65 us => **真实容量 ~512-1024 组，加组几乎免费（512 比 128 只贵 0.2 us）**；此前用 512 EU x 3 = 1,536 组推出的 "8.3% 填充" 已被取代（~1/4-1/8）。


## 105. ★★★★ **铲 (a) 交回（纯读码，零 GPU）：三态 = `合法（画质零代价）`，但最要紧的是它更正了我自己今晚那条头条——"BN=32 快 2.1x" 比的是"寄存器尾 vs 寄存器尾"，出货 N=128 走的是 `s8v8::gemm_b_pub_slm`，而屋顶表里没有它的任何行**

★ **出货臂**（`libxmx_sycl.cpp:4108-4117`，`pubslm` 默认 ON）注释原文：**"the N=128 batched family rides the senior 的 acc-via-SLM tail … BIT-EXACT diff 0, 0.148→0.112 / 0.227→0.210 / 0.196→0.150 在帧的三个 N=128 形状上"**，`SLM = HALF ? 18,432 : 32,768`
⇒ **`tools/xmx_roof.csv` 没有 `gemm_b_pub_slm` 的任何行** ⇒ **今晚那条 2.1x 不能当引擎收益**（军规 74/90/97）

### 四问四答（带行号原文，全文 `notes/bn32_routing_feas.md`）
1. **pack/stride**：`gemm_s8_v8_kernel.hpp` 里 `void pack_b32(...) { pack_b(B, Bp, N, K); }`，注释 **"identical map to pack_b — it already takes N as a parameter (N/8=4 tiles at 32)"** ⇒ **BN=32/BN=64 共用同一份打包 B**（8 列 tile × 32 深 k-block，BN 只决定一个 WG 吃几个 tile）；设备侧 `packdev::gather_pack_b_b`（3983 行）一套打包服务两条路 ⇒ **不需要两种打包**。
   ⇒ **顺带修我自己的标注**：`gemm32_b_pub_forced` 两行我写过"按 BN=64 打包 ⇒ 数值无意义"——**错**（`pack_b32` 就是 `pack_b`）⇒ **数值有效**，已改 2 行。
2. **出口同址 ✓**：两条尾都是 `size_t out = (size_t)g*sc + (size_t)rr0*ldc + gc;`，narrow/epi 链同为 `pub_vec_v8<16>(epi, convert<float>(acc)*rs*cs)` ⇒ **逐字节同址，不必停线**。
3. **归约顺序不变 ⇒ 画质零代价（待证）**：两核 k 循环都是 `for (int b = 0; b < kb_n; ++b)`（升序）、累加链都是 `dpas<8,8,int32_t>(c00..c11)`；**BN 改的是 WI→列 归属（`WI_COLS=BN/16`、`gemm32_b_pub` 用 `COL_BANDS=BN32/16`），不是每个元素的 k 序** ⇒ 每个输出元素的 int32 累加序列完全相同 ⇒ **逐位等价**（**最终仍要 1301 双 EXACT 才算证，不宣称**）。
4. **N=32 先例与要放宽的条件**：`4148-4151` 的 guard **本来就吃 N=128**（`N%32==0 && epi∈{0,1,3,4}`）；**挡住它的是分支顺序** —— `4108-4117` 的 `pubslm && N==128u ⇒ gemm_b_pub_slm` 先 return；`4137-4144` 还记着 N=32 那 20 条被 **P8-b wide-merge** 提前吃掉（**"rebuilt dll 里探针打零次 ⇒ proof, not inference"**）⇒ **要跑 BN=32 只能 `NR_PUB_SLM=0 + NR_G32_PUB=1`（一次动两个变量），或改码把 g32pub 排前（实现未批）**。

### 读码顺手挖出的两次旧坑（同一个角落，别重复）
- **`4111-4113`**：**N=64 不配 SLM 尾** —— "the 32KB stage costs occupancy there (0.033→0.074, the v9c lesson)"；
- **`3870-3872`**：**v9b（BM=32 宽 N 合并）0.53-0.80 ms vs v8 `gemm_b_pub_slm` 0.11-0.21 ms**，且 **"the v9b default was MASKING C2（那些调用根本没走到 pub_slm）"**
⇒ **填充杠杆必须跟 `pub_slm` 比，否则就是在重演这两次坑。**

### 军规 97（入 B2）：**倍率必须与"出货实际走的那条臂"比；屋顶表必须先覆盖出货实现路径**
正案：今晚 "BN=32 比 BN=64 快 2.1x" 比的是 `gemm_b_pub`（寄存器尾，未出货）与 `gemm32_b_pub_forced`；出货 N=128 走 `s8v8::gemm_b_pub_slm`（`libxmx_sycl.cpp:4108-4117`，`pubslm` 默认 ON，注释给出 0.148→0.112 / 0.227→0.210 / 0.196→0.150 的帧内实测；`SLM = HALF ? 18,432 : 32,768`），而 `xmx_roof.csv` 里没有它的任何行 ⇒ 该 2.1x 不能当引擎收益。
**推论：每加一条杠杆候选，先问三件事——出货走哪条臂？它在屋顶表里有没有行？比较对象是不是它？**（与军规 63/74/90 同族）



## 106. ★★★★ **短报：(b)①② 重跑中——抓到一个我自己的真 bug（CRT `free()` 释放设备指针 ⇒ 三批都是"截断跑"）+ `DIFFARM` 四臂逐字节 = 0（把 (a) 的"画质零代价"从读码升级为实测）**

### ① 真 bug：探针里用 **CRT `free()` 释放 `sycl::malloc_device` 指针** ⇒ 进程在打印完那几条腿之后崩
- **症状**：第一批 pub_slm 只跑出 `cap32 + pub_slm` 的行，**后面的 `int8 gemm_b / gemm_b_pub / gemm32_*_forced` 全不见了，也没有 `=== done grp=` 收尾** ⇒ 进程中途死；
- **定位**：`pe_free_check.py` 数出 **18 处裸 `free()`（全是我加的 v9 / force32 / pubslm 三条腿）vs 11 处 `sycl::free()`（探针自己的代码）** ⇒ 对设备指针调 CRT free ⇒ 崩；
- **波及面（如实）**：**§119/§122 的 v9 批、§124 的 force32 批、本铲第一次 pub_slm 批都是"截断跑"**；
  ⇒ **已经打印出来的那些行计时仍有效**（崩溃发生在打印之后）⇒ **v9 = 0.2345（spread 0.6%）、`gemm32_b_pub_forced` = 0.0370（2.2%）两条 HARD 读数仍然站得住**；
  ⇒ 但**同批排在其后的腿没跑到** ⇒ 若干形的 `gemm_b_pub` 只有 12 进程、且混批时后面的行丢失 ⇒ **这次重跑补齐**；
- **修**：`pe_free_fix.py` 把 18 处改成 `sycl::free(x, q)`（余 0）⇒ 重编 `exit=0`，**exe 829,952 B @08:16:25 md5 `69F58243…`**。
★ **军规 98（入 B2）**：**设备指针只能用 `sycl::free(p, q)`**；对 `sycl::malloc_device` 的指针调 CRT `free()` 会让进程**在打印之后**才崩 ⇒ **症状是"数据被静默截断"而不是"报错"**。
★ **军规 99（入 B2）**：**批脚本的完整性闸不只是"exe 存在 + md5 稳定"（军规 93），还必须断言每个进程打出收尾标记（`=== done grp=`）且行数 = 预期腿数**；否则"部分成功"会被当成成功，台账静默缺行。

### ② Smoke run（1 进程，G=3/R=10，只为验腿、不进台账）给出决定性一条
```
DIFFARM;M=8160;N=128;K=128;b=1;pubslm_vs_pubslmH=0;pubslm_vs_gemm_b_pub=0;pubslm_vs_gemm32_b_pub=0
```
⇒ **四条臂（`gemm_b_pub_slm<HALF=0>` / `<HALF=1>` / `gemm_b_pub` / `gemm32_b_pub`）在同一份 A/B 打包下输出逐字节完全相同**
⇒ **§126 (a) 的"BN 不改归约顺序 ⇒ 画质零代价"从读码判定升级为实测确认**（按规矩：diff≠0 就该当场停线回报；这里是 0 ✓）
**首读方向（非协议档）**：`pub_slm(H0)=0.0744`、`pub_slmH=0.0715`、`gemm_b_pub=0.0790`、**`gemm32_b_pub=0.0370`** ⇒ **`pub_slm / gemm32 ≈ 2.0` ⇒ 高于 1.3 预登记线**；
★ **另一条要先看**：**出货 SLM 尾只比寄存器尾快 ~6%（0.0744 vs 0.0790）**，与 §100 注释里"0.148→0.112"的幅度不符 ⇒ **那个收益是形状相关的**（注释那三个 N=128 形是 **b2/b4 多组形**，smoke 的是 **b1**）⇒ **留给 12 进程批定案**（这正是 (3) 第三条要标进 `xmx_roof.csv` 的东西）。

### ③ 正在跑（预计 ~92 min：08:2x → ~09:5x）
**5 形 × 12 进程**：`G27_batched_8160_128_128_b4`、`G29_batched_32640_128_64_b2`、`G54_i8_8160_128_128`、`G56_i8_8640_128_128`、`G57_i8_9216_128_128`；
每进程内产出：f16 两腿、int8 `gemm_b`/`gemm_b_pub`、`gemm32_b(_pub)_forced`、**`gemm_b_pub_slm` 与 `gemm_b_pub_slmH` 按 HALF 分开两行（不合并 ✓）**、**cap32 空核 64/128/256/512/1024 组（SLM 32,768 ⇒ 每 EU 2 驻）**、`b==1` 时 **DIFFARM 逐字节对拍**；
min-of-15×5、nosink、进程间 60 s、组间 300 s 冷却、**组名回验**、**开工断言 exe+md5、无输出即中止**（军规 93）。
**交回 ETA ~10:1x**：`xmx_roof.csv`（pub_slm 两行 + cap32 曲线 + 补齐的 `gemm_b_pub`）、`tools/capacity_curve_slm32k.csv`、`tools/three_arm_diff.csv`、**三臂 ratio 表**（预登记线 1.3）+ **按同 SLM 实测曲线重算的填充 %**（军规 96）。


## 107. ★★★★★ **三臂 hard-vs-hard 读数落地：BN=32 在 N=128 上 ratio = 1.09 / 1.14（预登记线 1.3）=> 填充杠杆在 N=128 判死**；**唯一 >1.3 的那形（8160 b1，2.05）它的分母（出货臂 pub_slm）本身 spread 62% 不硬 => 不能用它翻案**；**容量曲线按出货臂 SLM 足迹重测（n=65/点）=> "加组几乎免费"成立，但帧里真实的 batched N=128 形是 b4(512 组)/b2(1024 组) => 已在满波附近，填充不足只发生在 b1 相位形**
### 批的完整性（军规 99 的事后校验器已建并跑过）
`s6/pe_batch_audit.py` => **60 进程、`partial = 0/60`、每个进程都有 `=== done grp=` 收尾**（修完 `sycl::free` 之后）；**组名回验 0 mismatch**；**DIFFARM 三臂逐字节对拍在三个 b1 形上各 12 次全部 = 0**（`tools/three_arm_diff.csv`）=> **(a) 的"BN 不改归约顺序 => 画质零代价"在三个形状上各 12 次实测确认**（不只是 smoke 一次）
### ① `gemm_b_pub_slm` 屋顶（HALF 两档分行，未合并 ✓）
| shape | 臂 | msM_med | nproc | spread | 置信 |
|---|---|---|---|---|---|
| 8160x128x128 b1 | `gemm_b_pub_slm` (HALF=0, SLM 32,768) | **0.0759** | 12 | **62.0%** | **low-conf** |
| 8160x128x128 b1 | `gemm_b_pub_slmH` (HALF=1, SLM 18,432) | 0.0729 | 12 | 23.0% | low-conf |
| 8160x128x128 b1 | `gemm_b_pub`（寄存器尾）| 0.0784 | 12 | 22.7% | low-conf |
| 8160x128x128 b1 | **`gemm32_b_pub_forced`(BN=32)** | **0.0371** | 12 | **1.4%** | **HARD** |
| 8640x128x128 b1 | `slm` / **`slmH`** / `pub` | 0.0455(79%) / **0.0441(2.1% HARD)** / 0.0490(74.8%) | 12 | | |
| 8640x128x128 b1 | **`gemm32_b_pub_forced`** | **0.0418** | 12 | **1.2%** | **HARD** |
| 9216x128x128 b1 | `slm` / `slmH` | **0.0496(4.1%)** / **0.0468(5.0%)** | 12 | | **HARD** |
| 9216x128x128 b1 | **`gemm32_b_pub_forced`** | **0.0436** | 12 | **2.1%** | **HARD** |
| **8160x128x128 b4** | `slm` / `slmH` | **0.1477(2.8%)** / 0.1454(37.0%) | 17 | | **HARD** |
| **32640x128x64 b2** | `slm` / `slmH` | **0.2088(17.9%)** / **0.2061(4.8%)** | 12 | | **HARD** |
★ **`shipped_arm` 列已加进 `tools/xmx_roof.csv`（279 行，每条注明"这条腿在引擎里是谁、什么 guard、能不能走到"）** => 以后任何 headroom 计算按列取锚点（军规 97 的落地仪器）
### ② 同 SLM 实测容量曲线（`tools/capacity_curve_slm32k.csv`，池化 **n=65 进程/点**）
空核、NT=32、**SLM 32,768 B/组（= 出货 pub_slm HALF=0 的足迹，每 EU 2 驻）**：**64=>2.50、128=>3.00、256=>2.70、512=>2.90、1024=>3.40 us**（spread 7.7-13.0%）
⇒ **即便 SLM 翻倍到 32 KB，512 组仍与 128 组同价（2.9 vs 3.0 us），1024 组只贵 13%** => **加组几乎免费这条在出货臂的 SLM 足迹下同样成立**（军规 96 要求的"同 SLM 曲线"补上了）
⇒ **按这条曲线重算填充 %**：8160x128x128 **b1** 出货臂 = 128 组（BN=64）=> 相对 ~512-1024 的实测容量 = **13-25%**；**但帧里真实的 batched N=128 形是 b4（512 组）与 b2（1024 组）=> 它们已经在满波附近** => **填充不足只发生在 b1 那批（residual/qkv 的相位形），不在 batched 族的出货路径上**
### ③ 三臂 ratio（b1 形，预登记线 1.3）
| shape | 出货臂 pub_slm | BN=32 | ratio | 判定 |
|---|---|---|---|---|
| 8160x128x128 b1 | 0.0759（**62% 不硬**）| 0.0371（硬）| 2.05 | **不能用**（分母不硬）|
| 8640x128x128 b1 | 0.0441（slmH，硬）| 0.0418（硬）| **1.09** | **< 1.3 => 判死** |
| 9216x128x128 b1 | 0.0496（硬）| 0.0436（硬）| **1.14** | **< 1.3 => 判死** |
**顺带一条**：**pub_slm 只比寄存器尾快 3-9%**（1.033 / 1.077 / 1.085）=> **今晚 headroom 表拿 `gemm_b_pub` 当锚点并没有大错**（锚点偏低 => headroom 略偏大，幅度约 5%）；**§100 注释里 0.148->0.112 的 1.32x 是 b2/b4 多组形上的收益，不是 b1** => 已按列写进台账。
**初步结案口径（等 b4/b2 补测定案）**：**核内几何（BN 宽窄 / 组数）在 N=128 上被 hard-vs-hard 读数判死**；剩下唯一未测的方向是**面宽（`NR_RES_BYTE`，画质刀，要用户点头）**。
### 军规 100/101（入 B2）
**100**：**填充类杠杆要先问"帧里真实的形状是否已经在容量附近"**，不能拿相位形的填充比给整个族定杠杆。正案：b1 相位形 128 组确实欠填（13-25%），但 batched 族的出货形是 b4（512 组）/b2（1024 组）=> 已在满波附近；hard-vs-hard ratio 1.09 / 1.14 => 填充杠杆在 N=128 判死。
**101**：**ratio 的分母必须是 hard 行**（nproc>=12 且 spread<=20%，军规 91）；分母不硬的读数不得用来翻案。正案：8160x128x128 b1 的 2.05 因出货臂 spread 62% 而作废。

## 108. ★★★★ **③ 定案：多组形 ratio = 1.012 / 1.012（双臂 HARD）=> 填充杠杆（BN=32）在 N=128 全线判死 => 核内几何整条线结案**；本盒 GPU 约 92 分钟（pslm 60 进程 + g32mg 24 进程；进程间 60s、组间 300s 冷却；**编译都在批与批之间，没有批中重建被测件** 军规 93 ✓）
### 五形 ratio 全表（预登记线 >=1.3；hard = nproc>=12 且 spread<=20%）
| shape | 出货臂 | BN=32 | ratio | 判定 |
|---|---|---|---|---|
| **8160x128x128 b4**（帧真实 batched）| `gemm_b_pub_slm` **0.1479**（12，13.4% HARD）| **0.1462**（12，5.9% HARD）| **1.012** | **判死** |
| **32640x128x64 b2**（帧真实 batched）| **0.2092**（12，3.9% HARD）| **0.2067**（12，4.2% HARD）| **1.012** | **判死** |
| 9216x128x128 b1 | 0.0496（硬）| 0.0436（硬）| 1.14 | 判死 |
| 8640x128x128 b1 | 0.0441 slmH（硬）/ 0.0455 H0（不硬）| 0.0418（硬）| 1.09 / 1.03 | 判死 |
| 8160x128x128 b1 | 0.0759（**62% 不硬**）| 0.0371（硬）| **2.05** | **不能进建议**（分母不硬，军规 90/97/101）|
⇒ **五形里四条 hard-vs-hard 全部 <= 1.14** => 按预登记**停止，不交实施铲**
★ **8160 b1 的定性**：三批独立测到该形 BN=64 家族都是 ~0.078，而紧邻的 8640/9216 只有 0.049/0.054（**尺寸只差 6%，时间差 60%**）=> **这是 8160 形状自身的可疑点（outlier），不是填充红利** => **列为待查异常**（**这条可能是结构问题的入口，不是终点**）
### 机器化进台账的两条
- **`shipped_arm` 列已加**（`tools/xmx_roof.csv` **281 行**）：每行注明这条腿在引擎里是谁、guard 与可达性（含 `SHIPPED for N=128 batched (4117 pubslm && N==128u, HALF=0)`、`register tail … NR_PUB_SLM=0 时`、`N=32 走 NR_G32_PUB(4148) 但今天不可达`、`NOT shipped: probe-forced BN=32（pack_b32 就是 pack_b => 操作数/数值有效）`、`NOT shipped: s8v9 在 if(false && …) 之后`、`raw int32 C：从不是出货出口形态`）=> **以后 headroom 按列取锚点**（军规 97 的落地仪器）；
- **`pub_slm` 只比寄存器尾快 3-9%（b1 形）** => 今晚 headroom 表用 `gemm_b_pub` 当锚点的偏差约 5%；**§100 注释里 0.148->0.112（1.32x）不是普适**，只在当时那三个 N=128 形上成立；
- **同 SLM 实测容量曲线**（`tools/capacity_curve_slm32k.csv`，每点 n=65）：64=>2.50、128=>3.00、256=>2.70、512=>2.90、1024=>3.40 us => **SLM 32,768 下"加组几乎免费"仍成立**；**但帧里真实的 batched 形本来就是 512/1024 组 => 已在满波附近 => 没有填充可捡**。
### 完整性闸（军规 99）
`s6/pe_batch_audit.py`：**pslm 批 60/60 clean、g32mg 批 24/24 clean、partial = 0**；组名回验 0 mismatch；**DIFFARM 逐字节对拍在三个 b1 形 x 12 次全部 = 0**（`tools/three_arm_diff.csv`）=> **(a) 的"BN 不改归约顺序 => 画质零代价"实测成立**
### ★ 我的裁定（与代理建议不同）：**核内几何结案 != 挖核线收口**；下一铲 = **腿解剖（autopsy）**，不再试旋钮
代理建议"今晚挖核线到此收口、回到帧时本身、由用户定方向"——**我驳回**：已确认的事实是**我们自己的硬锚点里有 9.33 TOPS（`int8 gemm32_b_pub 130560x32x128`，12 进程 1.2% spread）**，而帧里最贵的腿跑在 **1.5-3.5 TOPS** => **2.3x 的差距在我们自己的核内，不在硬件、不在层数**。三条旋钮（BN/BM/SLM）判死只说明**这几个旋钮不管**，不等于没有结构问题。
**新线索（我自己从今晚数据里挑出来的两条，下一铲正面查）**：
1. **publish/尾比乘法本身贵**：`8160x128x128 b1` 上 raw `gemm_b` = **0.0280 ms**（int32 C），`gemm_b_pub` = **0.0784 ms** => **收尾是乘法的 2.8x**；`NR_G_FOLD`（把 publish 折进 gemm 存储）关掉值 **+4.99 ms/帧** => **尾巴是帧里的真金**，但它只在 `gemm` 族做了；
2. **8160 outlier**：同族 8640/9216 只差 6% 尺寸却快 60% => **形状相关的结构异常**（可疑点：`ldc/sc` 对齐、M=8160 不是 128 的整倍数 => 63.75 个行 tile 的**破 tile 尾**、pack_b 的 B 面尺寸分桶）。

## 109. ★★★★★ **用户立为纲：链路中间交流开销（hop）= 帧健康度指标；代码全部可改；"忠实移植"不再是保留搬运拓扑的理由**（11:4x）
**用户原话要点**："所有代码都是你自己写的，凡是造成 a770 瓶颈的问题都是自己挖的坑。尤其有中间过程成本的这类尤其严重。既然核心算力现在不是问题，那问题就出在自己挖的坑。代码全部都是能改的。**没有任何理由可以容忍链路中间交流的额外开销。这也是健康链路的标准之一，数据直通**（我一直以为现在已经是直通了，原来之前是指广域上的直通，微观细节上并没有，而且现在还是主要瓶颈）。"
### 我的确认（用我们自己的实测，不引外部）
- **核心算力不是问题**：可比形上我们比参考工程公布值快 **6.13x**（`130560x32x128` 我们 0.2035 ms vs 他们折算 1.248 ms）；我们自己的 HARD 锚点 **int8 22.73 / 15.4 / 9.33 TOPS**；参考工程自己承认 **"The kernel wins every row … The *path* loses most of them"**；
- **微观没直通**：我们的融合（A5 五相一核、S6 六相一核、qfuse 溶解 144 条 quant 腿、G_FOLD 把 publish 折进 gemm 存储、QKV_RES/WA_RES/gemm_b_res 无条件）**都发生在"相内/块内"**；**而 `quant -> gemm -> 写面 -> 再读面 -> 求 row-max -> 再写量化面 -> gemm` 这条"环与环之间"的两遍结构仍然在落全局面** —— **`gemm_int8_residual` 68 腿 / 20.06 ms、`gemm_window_int8_residual` 52 / 11.36、`gemm_int8_qkv` 60 / 9.67、`gemm_int8_batched` 72 / 4.86 = 45.95 ms 串行 ≈ 23 ms/帧 的作用面**；
- **一处自纠**：我不许再把 `raw gemm_b 0.0280 -> gemm_b_pub 0.0784` 的 0.050 ms 直接称作"hop 成本"——**它混着 requantize 算术、store 形态（raw 写 int32 4B/元素反而更快）、取 scale 的读**三件事，**必须拆开再定价**（autopsy 正在拆）。
### 由此改纲（已下令）：从"消几个 hop"改成"逐链清零 hop"
1. **`tools/hop_budget.md`**：52 条链逐链列 **每一次 写面->读面**（面 id、字节、写者/读者 closure）、**该链 hop 字节与实测 ms**、**已直通的部分（哪个机制）**、**剩余可清零的 hop 与位置** => **全帧 hop 总账**；
2. **`tools/quant_scope_audit.csv`**：每个量化/重量化点给 **行长 C、该行是否整个落在一个 WG tile 内、max 现在是独立一趟读全局面还是已在生产者存储里顺手算、该趟实测成本、消掉它的改动点、是否逐位等价**；**只允许"值不变"的那类**（换尺度粒度 = 画质刀，用户未开门不碰）；
3. **三档"零 hop 链核"设计**（C64 残差链 / C128 链 / window_block 族）：片上留什么（激活 tile 与 SLM/GRF 预算，64 KB/WG 帽、>8 累加器惩罚）、流进什么（权重按 k-block 从 L2/全局流入）、**行尺度就地算的位置（C <= tile 宽 => 成立）**、**逐位等价论证**（累加顺序、量化点、`fmul_rn` 不收缩）、barrier 变化、**以及"清零后这一链剩几次发射"（验收数）**；
4. **顺序**：第一刀 **已出货机制扩族**（`G_FOLD`/`qfuse` 覆盖那四族，零画质风险已证逐位）=> 第二刀 **就地算尺度**（quant 审计第一名）=> 第三刀 **零 hop 链核**（hop 预算第一名）。
**验收新增硬指标（写死）**：每一刀除时间外，**该链/该族的 hop 次数与字节必须实测下降**（`[hop]`/`[poolseq]`/`[pgt-final]` witness），**不许只用时间反推**。
### 军规 104（入 B2）：**链路中间交流开销（hop）是一等指标，与 ms 并列**；任何"照搬上游数据结构/搬运拓扑"的保留理由都不成立——忠实移植保的是**机制与数值语义**，**数据布局与 hop 拓扑是我们的代码、我们的责任**。每一刀必须报：**hop 次数与字节的变化 + 时间变化**，两者都要实测。

## 110. ★★★★★ **全帧 hop 总账落地（`tools/hop_budget.md` + `hop_budget.csv`，52 链逐链，零 GPU）：中间面 hop 流量 = 10.42 GB/帧 => 字节地板 18.60 ms 串行（串行和的 16%、帧时的 32%）；而"只为搬运/重量化存在的闭包"实测只有 3.08 ms 串行 => 差额 ~15.5 ms 藏在生产者/消费者核内的 store/load 里**
### 口径（先钉死防误读）
- **hop 定义**：某闭包写出的面被同链后面某个闭包再读回来（数据下过芯片）；**每个面只按"写一次 + 每个读者一次"计**（第一版按边计 => 2x 虚高到 14.7 GB / 26.2 ms，已修 => 现 10.42 GB / 18.60 ms）；
- **两个成本口径**：**(a) 字节地板** = 字节 / 560 GB/s（实测连续锚点，军规 78/94）；**(b) 实测搬运闭包 ms** = `rt_per_closure.csv` 里 `quant`/`quant_window` 这些**只为搬运/重量化存在**的闭包自身时间；
- 链外输入（图像、权重）不算 hop；已直通的（FUSED 标记、A5/S6/qfuse/G_FOLD/QKV_RES/WA_RES/gemm_b_res/pub_slm）单列。
### 总账
| 指标 | 数 | 说明 |
|---|---|---|
| 帧内 intra-chain hop 字节 | **10,418 MB/帧** | 52 条链合计 |
| **hop 字节地板** | **18.60 ms 串行** | / 560 GB/s |
| **搬运/重量化闭包实测** | **3.08 ms 串行** | quant + quant_window 非 FUSED 部分 |
| 帧时 / 串行和 | 57.3 / 114.63 ms（**因子 0.50**） | `tools/frame_factor.md`，旧 0.43 作废 |
★ **读法（这是本案的定量核心）**：**hop 的地板 18.60 ms 串行里，只有 3.08 ms 是"独立搬运闭包"花掉的** => **剩下的约 15.5 ms 藏在生产者与消费者各自的 store/load 里**（与 §109 那条 `raw gemm_b 0.0280 -> gemm_b_pub 0.0784` 的 0.050 ms 尾巴同源）=> **消 hop 必须两条路都走：删搬运闭包（qfuse/G_FOLD 那类）+ 改核内 store/load 路径（直通、加宽、就地算尺度）**。
### hop 边按"生产者 -> 消费者"排序（这就是坑的分布图）
| 生产者 | 消费者 | 边数 | 含义 |
|---|---|---|---|
| `GEMM_INT8_QKV` | `WINDOW_ATTENTION` | **156** | Q/K/V 三面下芯片再读回（QKV_RES 已一核出三面，**但面本身仍是 hop**）|
| `QUANT` | `GEMM_INT8_BATCHED` | **138** | 重量化独立一趟 |
| `QUANT_WINDOW` | `GEMM_INT8_QKV` | 104 | gather + 量化独立一趟 |
| `QUANT` | `GEMM_WINDOW_INT8_RESIDUAL` | 104 | 同上 |
| `QUANT` | `GEMM_INT8_RESIDUAL` | 102 | 同上 |
| `GEMM_INT8_BATCHED` | `QUANT` | 53 | gemm 出 f16 => 再量化 |
| `WINDOW_ATTENTION` | `QUANT` | 52 | attn 出 f16 => 再量化 |
| `GEMM_WINDOW_INT8_RESIDUAL` | `QUANT` / `GEMM_INT8_RESIDUAL` | 44 / 44 | 残差面再读 |
⇒ **最大两类：① QKV -> attention 三面往返（156 边）② QUANT 独立趟（448 边）**
### 逐链（前 6，按 hop 地板）
| 链 | tier | 闭包 | hop 边 | hop MB | 地板 ms | 搬运实测 ms |
|---|---|---|---|---|---|---|
| 17 | C256 | 16 | 26 | 379.1 | **0.677** | 0.114 |
| 3 | C64 | 14 | 22 | 278.2 | 0.497 | 0.009 |
| 25 | C512 | 13 | 23 | 268.8 | 0.480 | 0.007 |
| 9 | C128 | 13 | 20 | 265.8 | 0.475 | 0.083 |
| 47 | C128 | 13 | 18 | 226.1 | 0.404 | 0.006 |
| 41 | C256 | 13 | 18 | 224.0 | 0.400 | 0.006 |
⇒ **C64 那批链每链 200.9 MB / 0.359 ms 地板 => 52 条链量级均匀 => 清零 hop 的杠杆不在"挑最坏的链"，而在"消掉某一类边"（QUANT 独立趟 / QKV 三面往返）**
### 记分卡第一轴（GPU 批 ~12:0x 落）已出的两组他们的形
- **R00 `147456x32x96`（block0 qkv）**：我们 f16 `gemm_b_pub_f16` = **0.3723 ms = 2.43 TFLOP/s** vs 他们公布 kernel-alone **1.24 ms = 0.734** => **我们快 3.33x**（6 进程，spread ~1%）；int8 `gemm32_b_pub` = 0.2929 = 3.09 TOPS => **快 4.23x**
⇒ **第一轴（纯 GEMM）预计 8/8 全部过 bar => "核算力不是瓶颈"被我们自己的实测钉死**
### 军规 106/107（入 B2）
**106**：**hop 的成本有两副面孔**：独立搬运闭包（实测 3.08 ms 串行）与藏在生产者/消费者核内的 store/load（本案 hop 地板 18.60 ms 串行，差额约 15.5 ms 在核内）=> 消 hop 必须两条路都走：删搬运闭包（qfuse/G_FOLD 类）+ 改核内 store/load 路径（直通、加宽、就地算尺度）。只用其中一条会低估或高估收益。
**107**：**hop 计数按"面"不按"边"**：每个面写一次 + 每个读者一次；按边计会 2x 虚高（本案 14.7 GB / 26.2 ms => 修正为 10.42 GB / 18.60 ms）。

## 111. ★★★★ **GA 六臂解剖：撞出一条硬矛盾（单臂 softmax 2.0179 ms、0.1% spread > 整条闭包 1.41-1.45 ms），代理没有糊、当场点名；同时 ② 量化审计与 ③ 三档零 hop 设计交回**
### GA 六臂（`tools/ga_autopsy.csv`；探针喂的是 rows=192/tokens=192/heads=32；min-of-15x5 nosink；12 进程）
| 出货闭包里的六条发射 | msM_med | spread | 字节 | 地板 ms | ms/地板 |
|---|---|---|---|---|---|
| `pack_a16_b` (Q) | 0.0016 | 46% | 0.79 MB | 0.0014 | **1.14x** |
| `pack_b16_t_b` (K^T) | 0.0016 | 64% | 0.79 MB | 0.0014 | **1.14x** |
| `f16v1::gemm_b` scores | 0.1328 | 75% | 5.11 MB | 0.0091 | 14.6x |
| **`smax::vit_softmax_tiled`** | **2.0179** | **0.1% => 极硬** | 7.08 MB | 0.0126 | **159.7x** |
| `pack_b16_b` (V) | 0.0016 | 39% | 0.79 MB | 0.0014 | **1.14x** |
| `f16v1::gemm_b_merge_scale`（attnV+merge 已折叠）| 0.1265 | **222% => invalid** | 3.15 MB | 0.0056 | 22.5x |
| **六臂合计** | **2.2819** | | | | |
★ **硬矛盾**：闭包级归因八条 ga 腿各 1.41-1.45 ms（合计 11.37），**但单条 softmax 臂就 2.0179 ms，六臂和 2.28 > 整条闭包 1.42**；
代理先怀疑"dSc 未初始化（NaN/denormal）"=> **修好重测 2.0178 -> 2.0179，自己的假设被自己否证**（旧日志留证 `s6/SHAPE_ROOF_galegs_badinit.log`）；
口径松动的事实：`RT_shipped.timing.txt` 691 行合计 114.63 = 帧 57.3 的 2.0x（`tools/frame_factor.md`）=> 闭包归因含重叠，**但这不能解释"单臂比整链长"的方向矛盾**。
★ **我加的那道前置（代理原来没想到的第二种可能，更常见）**：**探针那条臂的实参可能不是出货那次调用的实参** => 已令先做零 GPU 的 **`tools/ga_arm_shape_recon.csv`**：`rows/tokens/heads/sc/ldc/batch/epi/flags` 逐项对（`shapes_census.csv` + `chain_map.csv` 的真实 plan 实参 vs 探针喂入），**任何一项不同 => 该臂作废并按真实形重跑**；**并用 ocloc 反汇编 + `barrier_audit` 确认出货 softmax 实例的 WG 数与每 WG 元素数**（别拿探针模板当出货模板）；**spread > 100% 的臂直接标 invalid**（`merge_scale` 222% 现在不能用）。
### (1) 连测一臂（8-15 min GPU，只在 (0) 同形之后）+ 预登记判读
- **连测 ≈ 1.4 ms** => 分臂被 **L2 冷热**污染 => softmax 真身远小于 2.0 ms，ga 的钱回到"闭包归因口径"；
- **连测 ≈ 2.28 ms** => **`vit_softmax_tiled` 就是第一靶**（159.7x 自己的字节地板、比两条 gemm 臂之和大 8x）=> 下一刀 = **重写 softmax 的输出/分块形态**（它现在是 6,144 个只处理 192 元素的小 WG）；
- **落在中间** => 报实测数 + 拆哪几条臂互相污染（用 buffer 复用顺序做对照臂）。
### 顺带钉掉一条：**三个 pack 臂 = 1.14x 于自己地板 => "打包是不是坑"问掉了：不是**（pack 腿健康）
### ② 量化点审计（`tools/quant_scope_audit.csv`，276 点，零 GPU）
| 桶 | 点数 | 实测 ms 串行 |
|---|---|---|
| **已溶解**（max 已在生产者存储里顺手算：qfuse/P8-l）| **196** | 0.439 |
| **可清**（现 tile 下行整条落在一个 WG 内）| 8 | 0.019 |
| **现 tile 下不可清**（行比任何单 WG 列跨度长）| **72** | **3.584** |
不可清的行长分布：**K=256x24、2048x16、128x12、512x12、1024x8** => **与 §99 判死 s8v9 的 `sc<ldc` 多组交错同源**（同一个坑的两次显形）。
（代理自报一条对齐错：第一版用 `RT[closure]` 字典把 196 个 FUSED 错配成 8 个 => 改成与 kept 记录 691<->691 按索引对齐才是上面三档。）
### ③ 三档零 hop 设计（`notes/hop_zero_designs.md`，未实现）
- **A（`QKV->attention` 三面往返，156 边 / 2.22 GB 读 / 地板 7.93 ms）**：C128 档融合要每 WG 驻 K/V 约 98 KB => **超 32,768 双线、超 65,536 硬帽**；C128 融合实测 +51% 更差（§101）=> **只有 C64 可扩，而 A5 已在 C64** => 剩余可清约 9 条腿 => 地板约 0.46 ms => **A 不是第一刀**；
- **B（QUANT 独立趟）**：case (1) **K=128/256 的 36 条腿（1.6 ms）可折**，前提 = 先测 **BN=256 宽生产者**屋顶（树里没有；s8v9 是 BN=128 且慢 3.0x）；case (2) **K>=512 的 36 条腿（2.0 ms）要跨 WG partial-max + 小 fixup**（逐位等价靠 fixup 复刻 `fdiv_rn/rint` 链，先例 P8-l）=> **新机制**；
- **C（window_block）**：hop 地板小（1.42 ms）、四相 gemm 屋顶解释 9.61/17.92 => **剩下 6.89 ms 是核内串行不是 hop** => 需要发射级仪表（仍压着）。
### 第一刀选法（我已定死规则，不让代理自选）
**softmax 若被证实是靶 => 第一刀 = softmax 形态**（11.37 ms 串行 / 帧约 5.7 ms 作用面，比 B(1) 的 1.6 ms 大一个量级）；**否则第一刀 = B case (1)**，但**前置 = 先说清 BN=256 与 s8v9（已实测慢 3.0x）差别在哪、为什么这次会不同；说不清就不跑那 24 进程**。B case (2) 与 C 排后。
### 军规 108（入 B2）：**子臂时间大于整条闭包时，先做"臂形 vs 出货形"的逐项对账与 WG 配置对账，再怀疑缓存效应**；spread > 100% 的臂直接标 invalid 不得引用。正案：`vit_softmax_tiled` 单臂 2.0179 ms（0.1% spread）> 整条 ga 闭包 1.41-1.45 ms；代理先假设未初始化输入并被自己的重测否证（2.0178->2.0179）。

## 112. ★★★★★ **今日收线：第一靶被实测钉死 = `smax::vit_softmax_tiled`，每腿 2.02-2.10 ms（159.6x 于自己字节地板、单核比两条 gemm 臂之和大 8x），8 腿 = 16.2-16.8 ms 串行 ≈ 帧的一半作用面**；**同时闭包级归因被证伪：`rt_per_closure` 对 ga 低估约 0.9 ms/腿（11.37 vs 18.2）=> 家族价格表整体可能是下界，不是真值**；**记分卡第一轴 8/8 全过参考 bar：可比形我们快 1.81-6.99x，帧平均 GEMM 4.64 vs 1.405 TFLOP/s = 3.3x**
### (0) 臂形 = 出货形对账（`tools/ga_arm_shape_recon.csv`）：六条臂实参与出货调用逐项相同（`libxmx_sycl.cpp:4834/4835/4836/4845-4846/4854/4870`）；八条 ga 闭包（c319/328/337/346/355/364/373/382）实参完全一致（rows=192, tokens=192, heads=32 => `CH=heads*32=1024`）。**WG 结构对账（`softmax_kernel.hpp` 原文）：`vit_softmax_tiled` = 一个 work-ITEM 一行、`range(heads*rows)` => 6,144 个每组 1 项的组，每组走 192 列 => 探针与出货同一结构，不是探针模板**。`gemm_b_merge_scale` 臂 spread 222% 已标 invalid。
### ★ 我自报的仪器缺陷（三层，全修好才拿到真数）
1. **`chain_*` 臂作废**：`timeit()` 测的是**返回事件自己的跨度** => 多发射 lambda 只报**最后一条核**（所以 `chain_all6` 的 0.0784 其实是 attnV 那条 gemm）；
2. **`COVERED_*`（尾部 submit-barrier）也作废**：barrier 事件只测 barrier 自己 = **0.0010 ms**（旧日志留证 `s6/SHAPE_ROOF_gacov_barrierbug.log`）；
3. **正解 = `timeit_region()`：前后各一枚 barrier，区域 = `a.command_start .. b.command_end`**。
### (1) REGION 读数（6 进程，min-of-15x5 nosink，`tools/ga_autopsy_region.csv`）
| 臂 | ms | spread | 于自己字节地板 |
|---|---|---|---|
| 三个 pack（Q / K^T / V）| 0.0015 / 0.0016 / 0.0016 | 46/80/39% | **1.1-1.2x => 打包腿健康** |
| `gemm_b` scores | 0.1248 | 70% | 13.7x |
| `gemm_b_merge_scale` attnV | 0.1326 | 62% | 23.6x |
| **`vit_softmax_tiled` 单核跨度** | **2.0175** | **0.0%** | **159.6x** |
| **REGION_all6（整条闭包）** | **2.2767** | 1.9% | 107x |
| **REGION_no_softmax（同链去掉 softmax）** | **0.1749** | 10.3% | 10.3x |
| REGION_softmax_only | 2.0402 | 1.6% | 161x |
⇒ **softmax 在链内份额 = 2.2767 − 0.1749 = 2.1018 ms**（与单核 2.0175 / 括号 2.0402 三数一致 => 稳）；**判读落在预登记第二支：连测 ≈ 2.28 ms => softmax 就是第一靶**。
★ **并推出**：八腿 x 2.28 = **18.2 ms 串行**，而 `rt_per_closure` 只归因 11.37 ms => **闭包级归因不能当 GPU 时间下界**（要写进验收口径）。
**源码级原因（已读）**：每组一个 work-item 处理一整行 192 列，每列 `vit_weight()` + `cr_hadd` 归约树，**无跨列 SIMD** => **1.18M 次标量 => 2.02 ms / 1.18M ≈ 1.7 ns/元素**。
**形态方向（未设计完）**：每组多行、**lane 跨列**，按同一索引式复现 `pair[4] -> column[8] -> even/odd -> total` 的合并次序 => **若次序不变则逐位等价**（这才是"把数据形态改成满足要求的形态"的正解，不是旋钮）。
### 记分卡第一轴（`tools/kernel_scorecard.csv`，他们的形喂我们的探针，6 进程/点）=> 8/8 全过 bar
| 他们的 op | 形(M,N,K) | 他们 kernel-alone | 我们 f16 `gemm_b` | 倍数 |
|---|---|---|---|---|
| block 0 qkv | 147456x96x32 | 1.24 | **0.3204（0.2%）** | **3.87x** |
| block 0 ffn | 147456x128x32 | 1.41 | **0.4183（5.5%）** | **3.37x** |
| blocks 1-3 | 36864x96x32 | 0.26 | 0.1371（2.1%）| 1.90x |
| blocks 5-7 | 9216x192x64 | 0.18 | 0.0993（3.9%）| 1.81x |
| blocks 9-13 | 2304x384x128 | 0.18 | 0.0740（3.3%）| 2.43x |
| blocks 15-21 | 576x768x256 | 0.17 | 0.0784（84.8% 低置信）| 2.17x |
| blocks 23-30 | 576x1536x512 | 0.71 | **0.1016（3.2%）** | **6.99x** |
| blocks 31-38 | 36x4096x1024 | 0.33 | 0.0807（n=5）| 4.09x |
⇒ **int8 更快**：`gemm32_b 147456x96x32` = 0.1923 = **4.71 TFLOP/s** => **6.45x**
**对用户那句的正面回答**：可比形上我们快 **1.81-6.99x**；**帧平均 GEMM：我们 266.0 GF / 57.3 ms = 4.64 TFLOP/s vs 他们 459.6 GF / 327 ms = 1.405 TFLOP/s => 3.3x**；卡峰 **A770 37.5 TFLOP/s f16 / 262 TOPS int8** vs **140V 31.9 / 64-67** => **零硬件借口**。
### hop 总账补充：按面（保守）10.42 GB/帧 => 地板 18.60 ms 串行；按边（上界）读 7.31 GB => 26.10 ms；边类前三：`QKV->WINDOW_ATTENTION` **2220 MB / 7.93 ms**、`BATCHED->QUANT` 793/2.83、`QUANT->BATCHED` 631/2.25；逐链均匀（最大链 0.677）=> 杠杆在消某一类边。
### 第一刀（按我的规则由 (1) 定死）= softmax 形态，不是 B(1)
- **作用面**：8 腿 x 2.02-2.10 = **16.2-16.8 ms 串行**（约帧的一半作用面，比 B(1) 的 1.6 ms 大一个量级）；
- **下一步**：先出 **softmax 形态设计**（每组多行 / lane 跨列 / **归约次序不变的逐位等价论证** / SLM-GRF 预算 / barrier 结构），再谈 bench 双臂成对单价（>=10 进程/形、同进程配对、**逐字节 diff=0**、预登记 ratio >= 1.3）；
- **hop 执法仪器**：`[hop]` 设计已在 `notes/hop_zero_designs.md`（presence-gated、从现成 touch 向量算、继承军规 57 向量纪律、清零前后逐闭包 diff => 军规 104）。
### 军规 109/110/111（入 B2）
**109**：**链/区间计时必须双事件括号**（前后各一枚 submit-barrier，区域 = `a.command_start .. b.command_end`）；**返回单个事件只报最后一条核的跨度**，尾部 barrier 事件只测 barrier 自己（本案 0.0010 ms）。
**110**：**臂级与闭包级读数必须互校；出现"单臂 > 整链"先怀疑仪器再怀疑物理**。本案仪器修好后矛盾消解，并暴露下一条。
**111**：**`rt_per_closure` 的闭包级归因不能当 GPU 时间下界**：ga 实测 2.28 ms/腿 vs 闭包归因 1.42 ms/腿（低估约 0.9 ms/腿，11.37 vs 18.2 ms 串行）=> **所有家族价格表都要按括号法复核**，此前"按家族排序"的结论要加"下界"标注。
今日 GPU 合计约 111 分钟（ref 58 + GA 六臂 13 + 重跑 13 + 链臂 13 + COVERED 7 + REGION 7）。

## 113. ★★★★★ **(a)+(c) 交回（零 GPU）：代理当场撤回 §132 那条"RT 低估 ga +60%"——方向是反的；真相是 RT 是 plain-path 墙钟括号（上界，且量的不是出货路）。同时站点普查证明：同病只有 ga 8 腿，softmax 的帧内价 <=1.07 ms/腿（不是 2.02）**
### (c) `notes/rt_timing_bracket_audit.md`：RT 不是单事件，是**另一条路径的墙钟括号**
源码原文（`libxmx_sycl.cpp:2278-2335`）：`NR_RUN_TIMING` 分支里每条 = **`steady_clock` 括住 `fn(); GQ->wait();`** => **CPU submit + GPU drain + 同步延迟全算进去** => **是上界，不是下界**；
★ **且该分支在 2335 行 `return passes`，出货的 cgraph 从 2371 行才开始 => RT 表量的是 plain 逐闭包路径，不是出货路径**；
- **旁证自洽**：plain 帧 72.6 ms、cgraph 帧 57.4 ms，而 RT 合计 **114.63 ms > 两者** => 每闭包多付一次 submit+wait；
- ⇒ **`tools/frame_factor.md` 的 0.50 是"跨路径比"，不是重叠系数**（代理已改口，但表还在用旧说法）；
- **对齐无错**：`s6/pe_rt_align.py` => **0/691 家族标签错位、closure 列 == 行号** => 标签可信，**是毫秒的含义被我说错了**；
- ★ **矛盾的真正解早有独立证据，代理没先找**：`s6/wbga.md §9c`（2026-11-02）在探针 TU 里测 softmax = **2.0654-2.4330 ms**，并**从帧反推 in-frame <= 1.07 ms**，当时把剩下的 2x 记为"大 TU 的 inlining/codegen，未定位" => **今天的 2.0175 属探针 TU 档，不是帧内价**；
- **建议重贴标签（军规 112）**：**RT = plain-path 墙钟括号 => 上界**；**isolated 单核跨度 = 该 TU 的价**；**帧内价必须帧级反推或括号复核**；**三套数不许混**；
- **排序影响（偏差按闭包数放大）**：`quant/quant_window` 276 腿（4.04 ms）**最被抬高**；`window_attention` 52（15.89）、`gemm_int8_residual` 68（22.47）次之；`window_block` 10、`global_attention` 8、`ffn_*` 受影响最小；
- **最小复核工单**：3 族（quant / window_attention / global_attention）x 1 形 x 6 进程 = **18 进程（<=22 min GPU）** => 产出"RT ÷ 括号法"偏差因子，贴回排序表。
### (a) `tools/softmax_sites.csv`：同病站点只有 ga 那 8 腿
| 站点 | 在帧? | 结构判据 |
|---|---|---|
| **A `smax::vit_softmax_tiled`**（定义 `softmax_kernel.hpp:214`；调用 `libxmx_sycl.cpp:4846`，`NR_GA_TILE` 默认 ON，guard `rows%16==0 && Mp==rows`）| **是，8 腿** | **1 行 = 1 work-item**（`range(heads*rows)` = 6,144 个单 item 组）；**lane 不跨列**；每元素 `vit_weight` + `cr_hadd` 树（`pair[4]->column[8]->even/odd->total`）；**存是逐元素 f16**（A-tile 里 `k16` 连跑 16 个 = 32 B 可合并却没用）=> **唯一在帧的同病站点** |
| B `vit_softmax_kernel`（`:171` -> `:4850`）| 只在 `NR_GA_TILE=0` 逃生档 | 同结构 + 多一趟 dProbs + pack（正是 tiled 消掉的）|
| C `softmax_kernel`（`:35`）| **引擎里无调用点**（只有 bench TU：`bench_smesimd.cpp:42` 等）| - |
| D `softmax_i8_kernel`（`:99` -> `:7008`，recorder `xmx_rec_softmax_i8`@6986）| **plan 里 `OP_XMX_REC_SOFTMAX_I8` = 0 条 => 不在本帧** | - |
| E `xmx_rec_vit_softmax`@5138（-> `:5151`）| **plan 里 `OP_XMX_REC_VIT_SOFTMAX` = 0 条 => 不在本帧** | - |
| **F wa / wb 的 softmax** | **是（52 + 10 腿）** | **在融合核内部**：`att5_fused_kernel.hpp`、`libxmx_sycl.cpp:5779`（"launch_full does all 7 stages … +softmax+…"）、WA 走 LFW-fused `:5384-5471`、WB 走 `wbmega`/`NR_WB_FUSE` => **多行 band + SLM 暂存的另一种结构 => 不是同一病**（这正是 A5/att5 已经改进过的形态）|
### 第一刀作用面（修正数）
- 只有 **ga 8 腿**；**帧内价 <= 1.07 ms/腿**（帧级反推，`wbga.md §9c`）=> **约 8.6 ms 串行 ≈ 4.3 ms/帧**；
- **CEILING = 帧内价 − 字节地板（0.0126 ms/腿）≈ 1.06 ms/腿 => 8.5 ms 串行 => 约 4.2 ms/帧**（**不是** §132 的 16.2-16.8 ms / 8.1-8.4 ms，那是探针 TU 档的价，两个口径混了）；
- ★ **另一条已封死的旧刀（必须避免重走）**：softmax 的 **SIMT 宽度在 dll 上已验证** —— shipped 实例本就 **simd=8**（`s6/WBGA_ledger_dll.txt:23`）；强制 16 = **+0.362 ms/帧（更差）**、pin 8 = +0.234、N=4 运行期拒（A770 只有 8/16/32）=> **宽度没肉**（`s6/simdwidth.md` §5-§6）；
- ⇒ **设计里真肉只剩两条**：**① 每组多行 => 6,144 组降到 768 组（调度/尾效应）；② 16 连跑 f16 合成一次 32 B 存**。两条都不改数值次序 => 逐位等价仍成立；**但收益上界约 4.2 ms/帧，不是 8.4**。
### 军规 112/113（入 B2）
**112**：**三套价格口径不许混**：(i) `NR_RUN_TIMING` = plain-path 每闭包 `steady_clock` 括住 `fn(); GQ->wait();` => **含 submit+drain+同步，是上界，且量的不是出货路（该分支在 2335 行 return，cgraph 从 2371 行才开始）**；(ii) **isolated 单核跨度 = 该 TU 的价**（受 inlining/codegen 影响，本案 softmax 探针 TU 2.02-2.43 ms vs 帧内 <=1.07）；(iii) **帧内价必须帧级反推或括号复核**。正案：§132 说"RT 低估 ga +60%"方向反了，已撤回。
**113**：**动刀之前先量化"排序仪器本身的族间偏差"**：RT 偏差按闭包数放大（quant 276 腿最被抬高、wa 52 与 residual 68 次之、wb 10 / ga 8 / ffn 受影响最小）=> 用 18 进程括号法复核拿到偏差因子，再决定谁先。

## 114. ★★★★ **(b0) 帧级标定交回；(b1)(b2) 没跑成，原因如实（真技术债，不是拖）**：softmax 的"搬运形态"档位（`NR_GA_TILE=0` vs ON）在帧里只值 **+0.209 ms（8 对，B 赢 2/8，符号 6/8 一致）**；**(b1) 卡在 sub-group 原语的真实宽度**——shipped softmax 实例是 **simd=8**，我按 32 lane 设计的 fold 距离（1..7、8/16/24）**全部越界、语义不成立**，不是补 include 而是真重写
### (b0) 读数（`ab.ps1`，同一件 `3BAECF2A…`，A 不设 env、B = `NR_GA_TILE=0`，8 对，`passes 691/691`）
```
pair 1 A=57.430 B=57.670 +0.240   pair 5 A=57.320 B=57.550 +0.230
pair 2 A=57.950 B=57.760 -0.190   pair 6 A=57.720 B=57.840 +0.120
pair 3 A=57.510 B=58.300 +0.790   pair 7 A=57.840 B=57.530 -0.310
pair 4 A=57.600 B=57.820 +0.220   pair 8 A=57.290 B=57.860 +0.570
== 8 对：B 赢 2 / 负 6，均值 +0.209 ms（带内中性），符号 6/8 一致
```
与历史那条 `NR_GA_TILE=0` **+0.38 ms（未分辨）** 同号同量级 => **softmax 的"版面/搬运档位"（少一趟 dProbs 写 + 少一趟 pack_a16_b）在帧里只值 ~0.2-0.4 ms**。
**这条回答了什么、没回答什么（不许过度解读）**：
- **回答**：只改"存到哪、少几趟"的形态 => 帧价值 **0.2 ms 级** => 这类改动单独不值一铲；
- **没回答**：softmax 的**行数学本身**（每行 192 列的 `vit_weight` + `cr_hadd` 树）值多少——**tiled 与 plain 付同一份数学** => **(b0) 既不能否定也不能证明"lane 跨列"那一刀**；
- **口径争议（8.6 vs 4.3 ms/帧）仍未定死**，要靠 (b2) 的括号偏差因子。
### (b1) 双臂已上膛没点火：卡在 sub-group 原语的真实签名（实测错误，不是猜）
已写进源码：`s6/smax2_probe.hpp`（bench-only 多行 x lane 跨列形态，**逐位等价论证写在文件头**：配对 `k0=b*64+c+16j / k1=k0+8`、列 fold 次序、块 fold `even/odd` 次序、padding、`fdiv_rn`、tile 地址映射全按 shipped 行号复刻）+ `s6/pe_smax_add.py`（`SMAX_OLD_region` / `SMAX_NEW_region` / `DIFFARM smax Ap_mismatch / recip_mismatch`）。
编译报错三轮：① `local_accessor<float,1>(range, group)` 与 `sycl::access::fence_mode` **本工具链不存在**；② 改用纯 shuffle 后：**`shift_group_left/right/permute_group_by_xor` 是 `sub_group` 集合原语**（要 `nd.get_sub_group()`），**而我按 32 lane 设计的 fold 距离在 shipped 实例 `simd=8` 的 8 宽 sub-group 下越界 => 语义不成立**；③ => **这不是补 include，是一次真重写**：必须按运行期 `sg.get_local_range()` 选 fold 方案（8 宽 => 列 fold 的四级 pair 跨 sub-group => 需要正确的 local memory 写法或分档 fold）。**代理没在盒内假装它写完 => 探针 exe 仍是 `4F13F90A…`（含 REGION 臂、不含 SMAX 臂）**
★ **对设计的修正**：因为 shipped 实例是 **simd=8**，"1 行 = 1 item => 只用 1 个 lane"的说法**不准确**（编译器已把行内循环 8 宽化）=> **设计里剩下的真肉是：6,144 -> 768 组（调度/尾）+ 32 B 合并存**，不是"从 1 lane 提到 32 lane"
### (b2) 没跑：quant 与 window_attention 在探针里没有可复现的臂（诚实）
quant 用 `qr_kernel`（无臂）；wa 的 softmax 在 **LFW/att5 融合核内部**（`libxmx_sycl.cpp:5384-5471`、`:5779`），要括号复核就得把融合核七阶段在 bench 里复刻 => 不是 22 分钟能干净做到的。
**但 ga 那族的偏差因子已免费拿到**：`RT 1.42 ms/腿（plain-path 墙钟上界）` vs `REGION_all6 2.2767 ms（探针 TU）` vs `帧级反推 <= 1.07 ms/腿`（`s6/wbga.md §9c`）=> **三档数并存在同一族上，正是军规 112 要禁止混用的样子**。
**最小可跑的 (b2-lite)**：给探针加一条 `qr_kernel` 臂（约 20 行）+ 6 进程（约 8 min GPU）=> 出 `tools/rt_bias_factors.csv` 第一行（quant 族）；wa 挂到明早。
### 军规 114/115/116（入 B2）
**114**：**读数打架先搜仓内旧账，再上仪器**（本案 `s6/wbga.md §9c` 2026-11-02 已测出探针 TU 与帧内两档价，我隔了两天才翻到）。
**115**：**形态类改动要分两笔账：搬运形态（存到哪、少几趟）与数学形态（每元素算什么）**。(b0) 实测：搬运形态档位只值 +0.209 ms/帧（8 对，符号 6/8 一致，与历史 +0.38 同号同量级）=> **不许用"该相作用面 ms"暗示数学那一半也会被消掉**。
**116**：**写 esimd 跨 lane fold 之前必须确认运行期 sub-group 宽度**（`sg.get_local_range()`）：本案 shipped softmax 实例 `simd=8`，按 32 lane 设计的 fold 距离（1..7、8/16/24）全部越界、语义不成立；且"1 item = 1 行"不等于"只用 1 个 lane"（编译器已把行内循环 8 宽化）。

## 115. ★★★★★ **(1) 布局审计交回（`tools/layout_interleave_audit.csv`，28 个面类；写者 `RT_ms(上界)` 合计 38.12 ms）——审计自己反驳了"`sc<ldc` 是最大自挖坑"这个假设的一半，并把第一刀改写成一句可测的话**
### 结论一：**交错不是内存布局问题**
`gemm_s8_v8_kernel.hpp`：**`static const int BM = 128, BN = 64, BK = 32, NT = 32;`** => **一个 work-group 只写一行的 64 列**；`libxmx_sycl.cpp:4117/4148` 传的是 **`ldc=N`、`sc=Mp*N`** => **面的 pitch 本身没有交错**；
⇒ **"改成每组行连续"不需要改任何布局**（pitch / `pack_b` / publish 寻址全不动），**只需要宽生产者 `BN >= N`**（军规 117）。
### 前 8 行（按解锁 ms 排）
| 写者族 | 面形(MxNxKbB) | 腿 | BN | 行被拆给几个 WG | 写者 RT_ms(上界) | 族级行 scope 量化点 | 面 MB |
|---|---|---|---|---|---|---|---|
| `gemm_window_int8_residual` | 2560x256x256b1 | 16 | 64 | **4** | 3.87 | 14（0.631 ms）| 0.66 |
| `gemm_int8_residual` | **8160x128x128b1** | 12 | 64 | **2** | **5.72** | (128 档 12 点) | 1.04 |
| `gemm_window_int8_residual` | 9216x128x128b1 | 6 | 64 | 2 | 1.51 | 14（0.631）| 1.18 |
| `gemm_window_int8_residual` | 8640x128x128b1 | 6 | 64 | 2 | 1.49 | 14（0.631）| 1.11 |
| `gemm_int8_qkv` | 2560x768x256b1 | 16 | 96 | 8 | 3.76 | 14（0.630）| 1.97 |
| `gemm_int8_residual` | 192x1024x4096b1 | 8 | 64 | **16** | 3.45 | - | 0.20 |
| `gemm_int8` | 192x4096x1024b1 | 8 | 64 | **64** | 2.01 | - | 0.79 |
| `gemm_int8_qkv` | 192x3072x1024b1 | 8 | 96 | 32 | 1.75 | - | 0.59 |
### ★ 结论二（审计自己的反证，防它误导下一铲）
- **N=128 那档（写者 RT 最大：5.72 + 3.0 ≈ 8.7 ms）：宽生产者我们已经造过 = s8v9（BM=64/BN=128），实测慢 3.0x（§102）** => **这一档的束缚不是 `sc<ldc`，是宽 tile 的占用/累加器成本**；
- **N>=256 档（28 个行级量化点 / 1.26 ms + 十几 ms 写者）：从没造过 BN>=256 的生产者 => 这条路未测**；代价项已列进 `layout_change_cost`：`SLM_B = BK x BN = 32 x 256 = 8 KB`（+ SLM_A）、累加器 `WI_ROWS x WI_COLS x 12 > 8` => **v9b 惩罚区**、**占用非单调（BN=32 实测 2.1x 快、BN=128 实测 3.0x 慢、BN=256 未知）**（军规 118）；
- **N>=1024 档（192x1024x4096、192x4096x1024）：行被拆给 16-64 个 WG => "就地算 max"基本无望**，要 B case (2) 的**跨 WG 两段式（partial-max + fixup）**。
⇒ **第一刀被改写成一句可测的话**：**"在 N=256 / 512 两档，宽生产者（BN=N）比 BN=64 快还是慢？"** —— 这是**屋顶臂问题**（bench 里把 BN 参数化测两档），比改引擎便宜（6 形 x 6 进程约 40 分钟，等批）。
### 口径改名已做（军规 112 文档化）
- **`tools/frame_factor.md` 重写**：0.50 标成**跨路径比**（RT = plain-path 墙钟上界；出货是 cgraph），新增一节 **"帧内价的唯一定义 = 帧级 A/B 实测差"**；三档口径命名 **`RT_ms(上界)` / `region_ms(TU)` / `frame_ms`**；
- **列名已改**：`anchor_gap.csv`（`measured_ms -> RT_ms_upper`、`hard_roof_ms -> region_ms_TU_roof`、`headroom_ms -> headroom_ms_RT_upper`）、`hop_budget.csv`（-> `RT_ms_upper_move_closure`）、`kernel_scorecard.csv`（`serial_ms -> RT_ms_upper`、`our_ms -> region_ms_TU`、`bar_ms -> frame_ms_ref_published`）。
### 军规 117/118（入 B2）
**117**：**"行被拆给多个 WG"通常是 tile 宽度问题，不是内存布局问题**：先查 `ldc/sc` 是否本来就是连续 pitch（本案 `ldc=N`、`sc=Mp*N` 无交错），再看 `BM/BN/BK` 常量。=> 想"每组行连续"只需宽生产者 `BN>=N`，不需要动 pitch/pack/publish 寻址。
**118**：**tile 宽度的占用效应非单调，禁止用相邻档位外推**：本案 BN=32 实测 2.1x 快、BN=128 实测 3.0x 慢、BN=256 未知；累加器 `WI_ROWS x WI_COLS x 12 > 8` 落在 v9b 惩罚区，`SLM_B = BK x BN` 线性涨。=> 每一档都要单独测屋顶。

## 116. ★★★★ **(0) `tools/bn_widening_budget.csv` 交回（零 GPU）：没有档被 65,536 硬帽直接否掉，但预算 + 读码暴露两件事**（占用在 BN=256 掉到 1 驻留；**dpas 链手写 12 累加器绑死 `WI_ROWS=BM/16 × WI_COLS=BN/16` ⇒ BN=256 要 48 个累加器 = 重写整条链，不是改模板参数**）
### 预算表（s8v8 三缓冲形：`SLM_A = BM*BK = 4096`、`SLM_B = BK*BN`、`slm_init<3A+3B>`；BN=64 的 18,432 B 与 ocloc 台账一致 ✓）
| BN | SLM 合计 | 每 EU 驻留组数（64 KB/EU；台账基准 18,432=>3、32,768=>2 ✓）| 累加器 int32/WI = 32*BN | 每 lane 累加器 GR | >8 惩罚区 | 一行被几个 WG 覆盖（N=256/768/1024）| 超硬帽 |
|---|---|---|---|---|---|---|---|
| **64（出货）** | 18,432 | **3** | 2,048 | 2 | no | 4 / 12 / 16 | NO |
| **128** | 24,576 | **2** | 4,096 | 4 | no | 2 / 4 / 8 | NO |
| **256** | 36,864 | **1** | 8,192 | 8 | **borderline** | 1 / 3 / 4 | NO |
| **512** | 61,440 | **1** | 16,384 | **16** | **yes** | 1 / 2 / 2 | NO（只剩 4 KB/EU 余量）|
⇒ **占用从 3 掉到 1 发生在 BN=256 这一档**（不是硬帽，是 occupancy）=> **与 v9c 教训（32 KB stage => 0.033->0.074）同一机理**。
### ★ 警告一：`BN=256/512` 那一枪今天不可能只靠复制体点火
`gemm_s8_v8_kernel.hpp` 里 **dpas 链是手写的 12 个累加器 `c00..c11`，绑死 `WI_ROWS = BM/16 = 8 x WI_COLS = BN/16 = 4`** => **BN=256 => WI_COLS=16 => 累加器组数 12 -> 48** => **不是把 BN 改成模板参数就行，要重新生成整条 dpas/累加器链**（约 100 行新核代码，且要在 bench TU 里与出货体逐行对照才满足军规 112 的"只差 BN 相关处"）。
### 代理提议的替代打法（同一假设、已有代码、今天可跑）
用树里已有的宽生产者 **s8v9（BM=64, BN=128）** 当宽臂，测 **N=256 / N=768** 两类面（审计里解锁量最大的两族）：预算上 s8v9 干净（SLM 24,576 => 2 驻留、累加器 4 GR/lane 不在惩罚区）；它把"一行被几个 WG 覆盖"从 4/8 降到 2/4 => **至少解锁一半交错**；`SRP_V9` 臂已在探针里 => **零新代码**；对照组同批复测 `8160x128x128b1`（证 bench 可信）。
### 我的两条附加口径（必须写进交回）
1. **混淆项要点名**：s8v9 同时改了 **BM（128->64）与 BN（64->128）** => **这不是纯 BN 实验**；**赢了不能归因给 BN，只能归因给"这组宽生产者几何"**；**输了也不能排除 BN=256/BM=128**；**要干净判 BN，只能写那 100 行**；
2. **`DIFFARM` 在 s8v9 上是"折叠合法性"的判据，不是速度的闸**：v9 是 **fused requantize**（`gemm_b_rq`），而 §99 已证它在 `sc<ldc` 多组交错形上折叠无效（row-max 跨两组）=> **N=256 时一行被 2 个 WG 覆盖，折叠仍可能非法 => diff≠0 是预期结果之一**；**因此这一枪把"速度"与"折叠合法性"分开报，不许用 diff≠0 去否掉速度读数，也不许用速度好去掩盖折叠非法**。
### 顺带（等批的两项，可零 GPU 推进）
- **(2) `qr_kernel` 臂**：签名已读到（`qr_launch(q, dev, qr_kernel(), dsrc(half*), dpack(uint2*), dscale(float*), m, k, flags, image_h, image_w, window_cols, window_pad, dprod, drecip)`）；**核体自己按 `it.get_sub_group().get_local_range().size()` 分档 => 正是 (3) 要用的先例**；
- **(3) `smax2_probe.hpp` 分档重写**：按 `sg.get_local_range()` in {8,16,32} 三档 fold + 跨 sub-group 那一级走 `local_accessor`（`qr_launch` 里有正确写法先例 `sycl::local_accessor<float,1> la(sycl::range<1>(256u), h);`）=> 设计与代码，不编译不跑。
### 军规 119（入 B2）：**手写的 dpas/累加器链是几何参数化的真实成本**：s8v8 的 12 个累加器 `c00..c11` 绑死 `WI_ROWS x WI_COLS`；改 BN 到 256 => 48 个累加器 => 要重新生成整条链（约 100 行）。=> **任何"只改 tile 参数"的设想，先查该核的累加器是不是手写展开的**。

## 117. ★★★★ **宽生产者批落定（36 进程，partial 0/36、组名回验 0 mismatch）：对照组通过 => bench 可信；N=128 档宽生产者判死（3.11x 慢，双臂 HARD）；但 8640/9216 两个点的 ratio 被 v9 自身的 Mp 平台异常污染，标 `contaminated` 不得引用**
### 对照组判定（先过这关）=> 通过
| 形 | 出货 `gemm_b_pub_slm` | 宽 `gemm_b_rq_v9` | 宽/出货 |
|---|---|---|---|
| **8160x128x128b1（对照）** | **0.0756（19.9% HARD）** | **0.2349（0.5% HARD）** | **3.11x 慢 => 精确复现 §102 的 3.0x => bench 可信、批有效** |
| 8640x128x128b1 | 0.0458（80.5% => **分母不硬**）| **0.4415（1.0% HARD）** | 9.64x 慢 => **contaminated**（见下）|
| 9216x128x128b1 | 0.0514（76.9% => **分母不硬**）| **0.4420（0.7% HARD）** | 8.60x 慢 => **contaminated** |
⇒ **按决策树：N=128 档宽生产者线结案**；现有独立点：**BN=32 快 2.1x（#104）· BN=128@8160 慢 3.0x（§102）· 本批对照 3.11x（HARD-vs-HARD）**；
⇒ **口径①仍成立**：s8v9 的"宽"是 **(BM=64, BN=128) 组合**，不是纯 BN 实验 => 输了**不排除 BN=256/BM=128**；
⇒ **口径②**：**这批只测速度、不判折叠合法性**（两臂 dtype 不同：`pub_slm` 出 f16 publish 面、`v9` 出 int8+scale => 不能 memcmp）。
### ★ 一条挂账异常（不糊）：v9 在 8640 与 9216 几乎同价（0.4415 / 0.4420，spread 1.0%/0.7%），而 8160 只有 0.2349
`Mp = 8192/8704/9216` => tile 数 128/136/144 => **不该同价** => 像 **Mp 过某阈值后 v9 走到同一个退化平台**（或 grid 撞上限）。
⇒ **归因工单（等批）**：v9 一臂扫 `Mp = 8160/8448/8704/8960/9216` x 6 进程 ≈ 15-20 min；**方向性结论不受它影响**（宽臂自身 spread <=1.2%），**但要用 v9 的绝对值就必须先归因**；**在那之前，8640/9216 两条 ratio 标 `contaminated`，不得进任何排序或结论**（军规 120）。
### (A) 已完成（零 GPU）：纯 BN 宽生产者已可用
- 生成器 `s6/pe_mk_bnparam.py` => **`s6/gemm_s8_param.hpp`（`s8par::gemm_b_param<BM,BN,BK>`）**：**BM=128 固定、NT 随 BN 长（32/64/128/256）、累加器恒 4 个 `simd<int32,64>` => 不进 >8 惩罚区**；
- **编译证明 exit=0**（`s6/bnparam_check.cpp` 实例化 BN=64/128/256/512，`icx -fsycl -c`，obj 82,878 B；**不链接、不跑、不进引擎**）；
- 报告 `notes/bn_param_gen_report.md`：结构 diff 逐行表（**只有 BN 派生字面量变**：`WI_COLS`、`NT`、`A_LD=SLM_A/NT`、`B_LD≡64`、`bp` 基址、`slm_init<3A+3B>`；**dpas 链、k 循环、存储装配、pack 映射字面不动**）+ 预算表（SLM 18,432/24,576/36,864/61,440；驻留 3/2/1/1；无档被 65,536 硬帽否）。
### 顺带（2）已就绪 / (3) 已完成不跑
- **(2) `qr_kernel` 臂已进源码并编译通过 => 探针 exe 现 `5C64DBC1…`（15:08:00）**，`SRP_QARM=1` 触发（形状 = 最贵 12 条 quant 腿 `M=640,K=2048`，几何复刻 `qr_launch`，`timeit_region()` 括号）=> 6 进程约 8-10 分钟出 `tools/rt_bias_factors.csv` 第一行；
- **(3) `smax2_probe.hpp` 按 `sg.get_local_range()` 三档重写完成**（设计+代码，未编译未跑，第三刀存着）。
### 代理自报一条仪器错（已更正）
第一版交回用了错的列（merge 脚本 **off-by-one => 取的是 `msX` 组间最大而不是 `msM`**）=> 全部以台账池化值为准（`pe_v9wide_pool.py` 复用已验证的正确索引）。**军规 99 的同族：解析列索引必须用表头回验，不能按位置猜。**
### 军规 120/121（入 B2）
**120**：**某臂自身的值在应单调变化的参数上"撞平"（本案 v9：Mp 8704 与 9216 同价 0.4415/0.4420，而 8192 是 0.2349）= 平台异常信号**；**该臂参与的 ratio 一律标 `contaminated`，不得进排序或结论**，直到归因完成（扫描该参数找拐点）。
**121**：**解析 bench 台账时列索引必须用表头名回验**（本案 merge 脚本 off-by-one 取到 `msX` 组间最大值而不是 `msM`，导致第一版交回数字偏大）；交回前用"同一行两个不同列的比值是否合理"做一次自检。

## 118. ★★★★★ **(B) 纯 BN 一枪落定 => 宽生产者线彻底结案（预登记第 2 行）**；**(2) quant 偏差因子判 `INVALID`（臂形错配），已标 `do not use for re-ranking`**
### ① 几何有效性自检（先过闸，用设备读数 + ocloc 台账，不靠源码推理）
`s6/DEVQ_geom.txt`（A770 实测）：**max_work_group_size = 1024、max_num_sub_groups = 128、sub_group_sizes = {8,16,32}、local_mem_size = 65,536 B** => **NT=32/64/128/256 全部 IMPLEMENTABLE**（没有档被硬帽直接否）；
`tools/roof_asm_struct.csv`（ocloc 读 `s8par` 活实例）：`<128,64,32>` **SLM 18,432**（预算 18,432 ✓）；`<128,128,32>` **24,576** ✓；`<128,256,32>` **36,864** ✓；**grf=128、simd=1(ESIMD)、scratch 0/0 三档全清** => **读数有效**（宽档没有寄存器余量但也没溢出）。
### ② DIFFARM（按口径分开报）
- **两臂都跑的每一次：`BN64 vs BN128 = 0`（24/24 进程，int32 C 逐元素全等）** => **纯 BN 化不改任何输出值** => (A) 生成器的正确性收口；
- `grp=53`（N=128）里 `BN64vsBN256 = 1048576 of 1048576` **不是失配**：**N=128 时 BN=256 臂被 `N%256==0` guard 跳过 => 那块缓冲全是 memset 0** => 差异是"没跑"的产物，已写清、不当结论用。
### ③ 三形 ratio（同进程配对、`timeit_region` 括号、min-of-15x5、nosink；12 进程/点，对照形 6）
| 形 | BN=64 | BN=128 | BN=256 | ratio = BN64/BNwide |
|---|---|---|---|---|
| `2560x256x256b1`（winres，解锁量最大）| **0.0285（1.4% HARD）** | 0.0668（**253.7% 低置信**）| 0.0484（**115.1% 低置信**）| **0.43x / 0.59x => 宽化慢 1.7-2.3x** |
| `2560x768x256b1`（qkv，**宽化但非 BN=N**，N=768 跨 3 组）| 0.0910（31.2% 低置信）| **0.0915（10.4% HARD）** | **0.0907（14.8% HARD）** | **0.99x / 1.00x => 持平** |
| `8160x128x128b1`（对照，**BM 固定 128**）| **0.0269（1.1% HARD）** | **0.0656（12.1% HARD）** | -（guard 跳过）| **0.41x => 慢 2.44x** |
⇒ **没有一个 N>=256 形到 `ratio >= 1.3` => 宽生产者线结案**。**六个独立点**：BN=32 快 2.1x（#104）· s8v9(BM+BN 同变)@8160 慢 3.0x（§102）· 纯 v9 几何@8640/9216 慢 9.6x/8.6x（#137，**contaminated**）· **纯 BN=128@8160 慢 2.44x（本批，HARD-vs-HARD）** · **纯 BN=128/256@2560x256 慢 2.3x/1.7x（本批，宽臂低置信）** · **纯 BN@2560x768 持平（本批，HARD）**。
⇒ **§117 口径①的 BM/BN 混淆已拆开**：s8v9 那个"(BM=64,BN=128) 组合"的输，现在在 **BM 固定 128 的纯 BN 下同样输（2.44x）** => **慢的是 BN 本身**；
⇒ **没有出现"更快但驻留=1"的特例**（256 档慢、768 档持平）=> 不涉及"赢在别处"的归因例外。
### ④ ★ (2) `qr_kernel` 臂：偏差因子不可用，如实挂账
region 括号 = **0.6387 ms（6 进程、0.3%）** vs RT 同形 = **0.1053 ms（16 条闭包）** => `RT/region = 0.16x`；
⇒ **这不是"RT 低估"的证据，是臂形不对**：那批 quant 闭包读的是 **33.55 MB 面**，而 `640x2048` 的 f16 只有 **2.62 MB** => **臂只喂 1/13 流量却贵 6 倍**（臂的 grid `rows_per_wg=8 => 80 WG、每线程 256 words` 大概率严重低效）；
⇒ **`tools/rt_bias_factors.csv` 该行已标 `INVALID -- do not use for re-ranking` 并写清原因**；要拿因子必须先从闭包自身流量反推臂形（M/K/面字节），约 10 分钟。
### 军规 122（入 B2）：**测"参数化几何"的对照臂之前，先用被比较闭包自身的流量/形状反推臂形**；否则得到的是"臂与闭包不是同一件事"的伪因子（本案 quant 臂只喂 1/13 流量却贵 6 倍 => RT/region = 0.16x 的荒谬值）。

## 119. ★★★★ **D（行驻留链核）一步出判决：`DIFFARM stage != 0` => 按预登记关掉 D 家族，不开第三轮。但关闭的证据链上有两个已知缺陷，必须同时记下（否则以后会拿一个弱证据当强结论）**
### 读数（`s6/ROWRES_smoke5.log`，1 发 smoke，探针 exe `8FCC4744…` @04:47:35）**补了 BM 匹配的 A 打包之后**：
```
DIFFARM stage mismatch = 606,208 of 655,360   (上一发 655,325 => 有改善但仍非 0)
hist: d<=-3=252,695  d=-2=12,310  d=-1=15,362  d=0=53,427  d=+1=12,169  d=+2=9,620  d>=+3=299,777
first row=0 col=0  baseline=113  D=117
```
### ★ 两个已知缺陷（代理按纪律没修，我在这里把它们钉在账上，防止"关掉"被当成"机制已被干净否证"）
1. **尺度索引错位（已定位，未修）**：出货 `gemm_b_pub` 的行尺度按**全局行号**索引（`gr = wg_row*BM + wi_row*16; rr0 = gr + r; rs = gas[rr0]`），**D 原型用块内行号** => **`wg_row>0` 的行全拿错尺度**；**这足以解释 hist 里大量 ±3 以上的大差**；**代理明说：若将来重开 D，先修这一处再看 stage**；
2. **对拍口径本身可能不同义（我要留一条问号）**：stage 比的是 **D 暂存的面** vs **基线 `gemm_b_pub` 发布的面**——**基线那一面是"已乘尺度"的成品，D 暂存的是"未缩放"的中间值**；**若如此，`stage mismatch` 非 0 有一部分是"两边不是同一个量"造成的，不是几何错**。**重开 D 之前必须先定义清"stage 对拍的两侧到底是不是同一个量"**（做法：让 D 也暂存"已缩放"值，或让基线暴露"未缩放"值，二者之一）。
⇒ **所以本案的准确说法是**：**D 原型在两步内没达到逐位等价，按纪律关掉**；**"行驻留"这个机制本身没有被干净否证**；**真正被实测顶住的是下面那条结构性算术（它不依赖 D 的原型质量）**。
### 今晚真正该留下的结论（`§139c`，独立于 D 原型质量）
**tile 几何这一族，两个方向都被实测顶住**：
- **加宽列块 => 累加器/占用爆**：`BN=32` 快 2.1x（#104），但**纯 `BN=128/256` 在 `N=256` 慢 1.7-2.3x、在 `N=768` 持平**（§138，HARD）；`s8v9`(BM+BN 同变) 慢 3.0-3.11x；
- **缩窄行块以求整行驻留** => (i) 计算侧削弱（`NT 32->16->8`）；(ii) 要新的 A 打包（`pack_a` 按 `BM=128` 定死）；(iii) **`N=256` 时 `BM=128` 的驻留合计 `18,432 + 65,536 = 83,968 B > 设备 local_mem_size 65,536` => 不可实现**（原型里 `static_assert` 直接拒绝），**N=512/1024/2048 只会更紧**；
- **D 的可达面本来就不大**：`tools/d_rowres_budget.csv` => **72 个不可折量化点里 D 只能碰 28 点 / 1.261 ms `RT_ms(上界)`**；**44 点 / 2.323 ms 结构上碰不到**，因为 **quant 归一化的"行" != gemm 产出的"行"（`K != 写者的 N`）**。
### 仪器事实（必须留档）
`RR_qr_only` 跨 smoke 从 **0.0419/0.0696 跳到 0.1553/0.1570（3.7x）** => **`qr_kernel` 臂自身跨进程抖动极大**；**任何用它做对照的 ratio 必须先证 spread <= 20%（12 进程）**（军规 91/122，与 §138 `rt_bias_factors.csv = INVALID` 同族）。
### 下一铲（已定死，不再猜）：**每闭包发射级仪表**
`single_task / parallel_for / memcpy / memset` presence-gated 计数 + `[hop]`（每闭包写面/读面次数与字节）+ **清零前后两臂逐闭包 diff** => **把"还剩几次发射、每条腿的时间构成"变成实测**（军规 104 的执法仪器）。
### 军规 123（入 B2）：**关掉一个机制之前，必须先证明"对拍的两侧是同一个量"**；否则 `diff != 0` 可能只是口径不同义。本案：D 暂存"未缩放"中间值 vs 基线发布"已缩放"成品面。

## 120. ★★★★ **发射级 + hop 仪表源码就位（本铲至今没跑 walk；只编不链不跑，`out\libxmx.dll` 仍 `3BAECF2A…`）**。账 = §140（2285 行）
### 做了什么（presence-gated `NR_LCOUNT`，默认 0 => 出货语义不变）
- **第五向量 `g_cmds_launch`（`struct LCount{int pf,mc,ms;}`）**与 `g_cmds` 同长同序：**`pg_push` 里 push、三个 clear 站点（1505/1516/2253）一起清、`bmerge` 的 `move_at` 一起搬**（军规 57；§B step-1 的 desync 是前车之鉴）；
- **游标 `lc_begin(i)/lc_end()` 挂在四个真正跑闭包的循环**：RT 环、submit-probe 环、**cgraph record**（`g_graphs[id][fi]()` => 计数发生在**录制期**，正是"这条闭包提交几次设备操作"的定义）、warm 环；**首遍 warm-up 故意不计数**；
- **dump `launch_hop_dump()` 接在 `pgraph_final_dump()` 之后**（同一冻结次序打印）：`[lcount] cmd=… name=… pf= mc= ms= | [hop] planes=… bytes=… ids=…` 与 `[lcount-total] … skipped_sites=… | [hop-total] planes=… bytes=…`；**hop 全部从现成 `g_pg_ids_snap` 算，不加新录制语义**。
### ★ 插桩策略与一次自造事故（教训入账 = 军规 124）
**168 个计数点：pf=137 / mc=28 / ms=2，分布在 43 个 recorder/helper**。插入策略 = **只在"该行以调用前缀开始且语句完整（行尾 `;` 或 `{`）"处插**；**声明行 / 宏续行 / 无 brace 的 if-else 单语句体一律拒插**（拒插 **20 处**：3 声明 + 1 宏续行 + 16 if-else 体）。
⇒ **第一版贪插到 199 处直接把语法打断**（`if (x)\n LC_INC(pf); call();\n else …` => `else` 前多了一条语句）；已回滚到 HEAD 重来，只编不链不跑，`icx /fsycl /c` **exit=0、errors=0**（`s6/LC_syntax5.log`）。
### 牙 1（静态，带行号）=> 过
`xmx_rec_global_attention` 里被计数的发射：`4889 pack_a16_b(Q)`、`4890 pack_b16_t_b(K^T)`、`4891 f16v1::gemm_b(scores)`、`4900 vit_softmax_tiled`（默认）、`4904 vit_softmax_kernel`（逃生）、`+pack_a16_b(dProbs)`（逃生）、`+pack_b16_b(V)`、`+gemm_b_merge_scale`（默认）、`+gemm_b`（逃生）、`+merge_heads parallel_for`（逃生）=> **默认路径 = 6 次发射**，与 §131/§132 六臂解剖逐一对上 => **仪表数的就是那条链，不是别的**。
### 牙 2（期望关系先写死，walk 之后照它核）
`[hop-total] bytes` 按 **touch 集**计（每闭包所有解析到活缓冲的 id，读写都算、含权重/图像输入）=> 与离线两张账的口径差应这样拆：`hop_budget.csv` 按面（保守）= **10,420 MB**；`hop_edges.csv` 按边 = **7,310 MB 读**（+对应写）；**预期 `[hop-total] >= 10,420 MB`，多出的部分必须能拆成 (i) 链外输入（权重/图像）被 touch、(ii) 同一面在同闭包读写双计、(iii) `pgraph_extra` 带进来的额外面 => 拆不平就是仪表错，不许拿"差不多"过**。
### 军规 124（入 B2）：**往引擎里批量插桩必须用"只插完整语句、不碰无 brace 控制体"的窄策略，并把拒插数如实报出来**，而不是事后修语法。正案：第一版贪插 199 处把 `if (x) call(); else …` 打断成 `else` 前多一条语句；回滚 HEAD 后用窄策略插 168 处（pf=137/mc=28/ms=2）拒插 20 处，`icx /fsycl /c` exit=0 errors=0。

## 121. ★★★★★ **发射级仪表 walk 跑完：`tools/launch_map.csv`（691 行）+ `launch_by_recorder.csv`（20 行）——Q1/Q2/Q3 第一次有了实测数；但两个洞如实挂账（307 是下界；牙 2 没拆平）**
### 建变体与两轮修仪表（都记账）
`build_shipped.ps1 -Tag lcount{,2,3,4}`（`tools/shipped_build.defs` 基座、header guard `490647A9…` ✓）=> 产物只进 `builds\`：`libxmx_lcount4.dll` md5 **`B9D1C043…`**；**`out\libxmx.dll` 全程 `3BAECF2A…` 未动**。
- ① **dump 挂在 capture 出口 => `g_cmds` 已被 move+clear => 全 0**；修 = **capture 时把 `g_cmds_launch`/`g_pg_ids_snap` 搬进 per-graph 向量、replay 出口按 graph id 打印**；
- ② **一次 walk 里每个闭包体执行两遍（warm in-order + cgraph record）** => GA 读出 12 = 静态 6x2；修 = **游标只留 record 那一条 => 现在计的是 graph 节点数**（正确口径）。
### 行为中性五连（同 build 门关/门开对照 + 多进程）=> 全过
| 检查 | 门关 | 门开 |
|---|---|---|
| 1301 | `DD49827DD33A…` EXACT | EXACT |
| `[vec-align]` | `cmds=691 touch=691 group=691 poolblk=691 idsnap=691 names=1382 => ALIGNED` | 同 |
| `[skip-chains]` | `chains_skipped=14 refused=0 closures_noop=168 passes=691` | 同 |
| `[poolseq-total]` | `gets=438 maxperclosure=7 hash=e62607c36a3c7410` | **hash 相同** |
| 独立进程 | - | **4 进程 1301 md5 全等（distinct=1）** |
帧时在带内（57.3-61.5 ms）。**40 门链没跑**（它打的是 `out\libxmx.dll`，不是变体）=> **这条挂在要求的 6) 上，没做就是没做**。
### Q1 全帧一共多少次设备提交：**307**（`pf=307 / mc=0 / ms=0`）=> **graph 内 0 次 memcpy/memset，面搬运全在内核里**；**但这是下界**（见洞 1）。
### Q3 平均每发多少钱（`RT_ms(上界)` 口径）
| recorder | 闭包 | 提交 | RT_ms(上界) | **ms/发** |
|---|---|---|---|---|
| `gemm_window_int8_residual` | 52 | 69 | 12.946 | 0.188 |
| `gemm` | 42 | 56 | 9.736 | 0.174 |
| **`global_attention`** | 8 | **48** | 11.368 | **0.237** |
| `gemm_int8_residual` | 68 | 34 | 22.471 | 0.661 |
| `gemm_int8_qkv` | 53 | 31 | 12.632 | 0.407 |
| `window_attention` | 45 | 31 | 12.288 | 0.396 |
| `unary` | 16 | 16 | 2.761 | 0.173 |
| `gemm_int8` | 24 | 10 | 5.259 | 0.526 |
| `ffn` | 8 | 8 | 4.972 | 0.622 |
| `ffn_merge` | 1 | 1 | 3.549 | 3.549 |
⇒ **没有任何 recorder 落在"每发 < 0.02 ms"的记账级区间** => **"再写融合核值不值"不在记账层**；**提交密度第一是 `global_attention`（6 发/闭包 x 8 = 48 发）；面字节第一是 `gemm_int8_residual`（touch 5.72 GB）**。
### Q2 还剩哪些"可消"的发射（点名）
榜（按提交数）：`winres 69`、`gemm 56`、**`ga 48`**、`residual 34`、`qkv 31`、`window_attention 31`、`unary 16`。
**ga 的 48 发 = 8 闭包 x 6 发**（pack Q / pack K^T / scores gemm / softmax / pack V / attnV-merge）=> **其中 4 发是 pack**（把 f16/int8 面重排一遍再喂 gemm）=> **pack -> gemm 边是单消费者、可并**；**softmax 前后各有跨 WG 归约 => 不可并**。**每条边的第二消费者判定要拿 `launch_map.csv` 的 ids 串起来核，这一份里没做。**
### ★ 两个必须如实挂的洞
1. **盲点 = 32 个拒插点**（窄策略拒的）：`gemm_int8_batched` **10**、`window_block` 6、`gemm_int8_qkv` 5、`window_attention` 3、`winres` 2、其余 6 => **后果当场可见：`gemm_int8_batched` 72 闭包读出 0 发、`window_block` 0 发、`quant` 80 闭包 0 发——它们的发射全在"无 brace 的 if/else 单语句体"里** => **307 是下界**；修 = 这 32 处机械加 brace（安全可核）再走一遍（GPU ~2 min）；
2. **牙 2 未拆平**：census touch 集 = **940 个不同 plane id / 30.79 GB**，离线按面只算到 ~150 个中间面 / **10.42 GB** => 差额主因是**引擎把 pool scratch、权重 blob、版本化 id 都登记进 touch**（离线模型只认 plan 参数里的面）=> **口径不同、不是数值错**；要核平必须先把 940 个 id 归类（权重 / 中间面 / scratch）。**没归类之前 `[hop-total]` 不能与 `hop_budget` 对表**（已按规矩标红，没用"差不多"过）。
### 军规 125/126（入 B2）
**125**：**仪器有已知盲点时，它给出的"总数/排序"只能当下界用**，且在用它定刀之前必须先补盲点。正案：窄策略拒插 32 处 => `gemm_int8_batched`/`window_block`/`quant` 读出 0 发 => 307 是下界 => 先机械加 brace 再走一遍（~2 min GPU）。
**126**：**hop 对表前必须先把 plane id 归类**（权重 / 中间面 / pool scratch / 版本化 id）：引擎 touch 集 940 个 id / 30.79 GB 与离线模型 ~150 面 / 10.42 GB 不是同一口径，**不归类就不能核平、也不能拿 [hop-total] 当收益底料**。

## 122. ★★★★★ **第 1 层（对接桥接的那一层）实测与社区参考到位：`{pre, ffn_stem}` = 4 次设备提交、0 memcpy/memset、3.86 ms/帧 = 真实地板 1.03 ms 的 3.75 倍 => 不达标；★ 同时补出一个被所有旧 hop 账漏掉的大数：全帧 pool scratch 搬运 = 1.50 GB/帧**
### 范围（用 ids 串认死）
桥接面 = `prepare_fused` 建的 **id1 colour 2,088,960B / id3 motion 4,177,920B / id6 history 6,266,880B / id4 plan 6,272,916B / id5 table 262,160B**（id2 result 属输出侧）；唯一读者 = **`xmx_rec_pre`**（写 features id1271 = 16,711,680B，**只有 1 个消费者 = `xmx_rec_ffn_stem`**）。
**提交数按源码手工核**：`pre :2835` = **1 发**；`ffn_stem :3597 pack_a16 + :3645 gemm_dual_pub + :3679-3680 chip_cs2` = **3 发**；权重 `cached_pack_b_f16`（`:3598/3667/3673`）**0 发/帧**（缓存命中）=> **第 1 层 = 4 发、0 memcpy、0 memset**。
### 真实地板重算（`s6/layer1.md §6b`，不是 touch 足迹口径）
- **`pre`**：touch 口径 `U = 35.78 MB => 104 µs`；**含 gather 请求量 `G = 154.85 MB => 451 µs`（@343 GB/s）**；实测 **2.06-2.18 ms => 4.8x(G) / 20.9x(U)**；**`NT 32->1024` 只差 5% => 不是 fill 问题**（fill = 16,320 WG / 容量 512 = 3,188%）；解剖：**5-tap warp = 1.217 ms = 59%**；`fdiv_rn` 全家 0.108 ms = 5.3%；features 写 0.012 ms；三个读 ≈ 0；发射地板 0.027 ms；**~0.82 ms 当时未归因**。
- **`ffn_stem`**：地板 **317.5 MB => 926 µs**；实测 **1.679 ms = 1.81x**；**分腿**：`packA 1.03x` ✓、`dual 1.32x` ✓、**`chip 2.32x` ✗**（stem 的钱在 chip 那一发）。
- **两条腿合计 3.86 ms vs 地板 1.03 ms = 3.75x** => **第 1 层达标线（<=1.5x）不过**。
### 容量与仪表（实测）
`CAP2` 单事件法与 `tools/capacity_curve.csv` 同口径：**SLM=0/NT=32 平台到 512 WG（1024 才 +15%）=> 容量 ≈512**；**SLM=32,768/NT=32 平台到 256（512 已 +10%）=> 256-512**。
ocloc 活实例：`pre` = grf128/simd8/**private_size 608 B/线程**/SLM 0；`chip_cs2<32>` = **slm_size 32,768**、grf128/simd1、**WG=2,040（源码显式）**；`gemm_dual_pub` = grf128/simd1、items 65,280（运行期定 NT）。
★ **仪表洞已补**：`[hop]` 原来只算 plan 命名面，**pool scratch（D 类 id）不在账里** => LCount 加 `scr` 字段、`pool_get` 两条出口记账（打印侧，不碰调度用的 `g_cmds_touch`）；**修后 `stem scr = 116,981,760 B`（dA+dS+dH16 逐项对上）、全帧 `scr = 1.50 GB/帧`**；行为中性：1301 EXACT DD49827D、vec-align 七条 ALIGNED、三个 fused 锚点一字不变、**stem pf 从 2 修成 3**。
### 社区参考（`E:\DSH\refs\COMMUNITY-FINDINGS.md`，每条带 `仓库:文件:行号`）
- **参考库同层 = 3.7-4.8 ms/帧、5-7 发 + 每帧 3 次纯拷贝 ≈18.8 MB**（`gpu_image_pipeline.py:185-187`）；**warp 也是 5-tap Catmull、每 tap 4 个点载入**（`image_history.comp:49-72,75-95,98-111`，`local_size 256`，**两个分辨率各做一次**）=> **我们"折进 pre 一发、不生成中间面"已经比他们少一遍搬运、少 6 次提交**；**第 5 条线（不比参考同层贵）= 过**；
- **省 tap 的做法只有硬件采样**：OptiScaler **BCDS：4 次硬件双线性 `SampleLevel` 顶 16 个三次权**（`output_scaling/precompile/bcds_catmull.hlsl:47-66,96-106`）与 FSR1 EASU 同型（`fsr1/fsr_easu.hlsl:26,63`）=> **硬件采样 = 定点权重 = 改数值**，只写方案不动代码；
- **网络受限**：`web_fetch` 三次全失败（api.github / github / raw 都连不上），`onednn-gpu`、`llama-sycl` 的 sparse 拉不下来（filtered clone 要网络）=> **B 组两问（oneDNN split-K/blocking、llama.cpp dp4a tile）本轮无参考可读**，如实挂账；能读到的最近对照是 `refs/dlss-nr-on-intel/notes/improve-fusions.md:232-260`（**加占用更慢："Threads were never short; the blocks serial K loops are what the time is made of"**、**空发 1.2-4 µs**、**权重 32 列 slabs 位相同但只在部分形状赚 => 他们没采用**）。
### 两枪的结果
1. **`pre_at_w`（坐标分解 10->6、去 `coords[]/weights[]` 数组）= 逐位 EXACT**（fused features md5 `CACD2029…` 与 shipped 一字不差）**但时间中性**（RT 括号 pass0 两侧都 4.9 ms；ocloc **private_size 仍 608**）=> **不转正、已回退**；
2. **显式 `NT=32` 已实现**（`libxmx_sycl.cpp:2835+`，默认 32、`NR_PRE_NT` 逃生）：探针配对 **2.171/2.192 -> 2.063/2.067 ms（-5%）**，fill 从上下界变成事实。
### 下一枪（已设计、等批）：`pre` 的 **SLM tile+halo 取样**
把 colour 的 `32x32`（含 halo）一次读进 SLM，**5-tap 权重与累加次序完全不变、只换取数源**；`G` 从 154.85 MB 降到 ≈35 MB；**WG 数 = 522,240/1024 ≈ 510 正好落在容量 512 的平台内**；预期 `pre` 2.06 -> **<=0.6-0.8 ms（省 1.3-1.5 ms/帧）**；**VERIFY 必须仍逐字节 EXACT**（不 EXACT 就说明推理错，当场停）。
**注意与 §102/§139 的区别**：那条"SLM 暂存判死"说的是 **gemm 累加器经 SLM 回读**（累加器爆、驻留掉）；**这里是 2D 图像窗口带 halo 的标准 tile 载入**，两回事，不许互相引用。
### 军规 127/128（入 B2）
**127**：**改引擎源的脚本必须二进制 / `newline=""` 读写并保持原 EOL**（HEAD = LF-only）：本案一次文本模式读写把整文件改成 CRLF，导致 `build_shipped.ps1` 里 `patch_testdefs.py` 的 LF 锚点 `PATCH FAILED exit=2`。
**128**：**hop/流量账必须把 pool scratch 计入**：`[hop]` 只算 plan 命名面时漏掉 **1.50 GB/帧** 的 scratch 搬运（stem 单发 scr = 116,981,760 B，实际搬 ≈300 MB 而旧账只报 83.6 MB）；任何"离地板几倍"的判定都要用补了 scr 的口径。

## 123. ★★★★★ **第 1 层交回（§9-§20）+ ★★ 一条自找的严重事实：HEAD 谱系比现出货件慢 +4.8 ms/帧——是已入库的仪表那串引进的回归，不是新刀造成的**
### ★ HEAD 回归（`ab.ps1` v3 出货口径，清所有 NR_*，run0 丢、run1-3 中位、对序交替）
| 配对 | A | B | 均值 ± CI95 | B 赢 |
|---|---|---|---|---|
| 现出货 vs **lcount14**（只带 §120-122 仪表、**无 pre 手术**）| `3BAECF2A` 57.2 | `0D4986C3` 62.0 | **+4.814 ± 0.298 ms** | **0/8** |
| 现出货 vs **lcount18**（仪表 + pre 手术）| 57.3 | `12D8F862` 62.3 | **+4.943 ms** | 0/16 |
| **lcount14 vs lcount18**（手术净效应，两侧都带仪表）| 62.1 | 62.0 | **-0.076 ± 0.332 ms** | 4/8 => **带内中性** |
⇒ **+4.8 ms 是仪表串引进的回归**（passes 两侧都 691、结构相同）=> **必须先查掉再谈任何层的 ms**；二分下一刀 = `ab.ps1 -DllA lcount11 -DllB lcount14`（约 6 分钟），可把回归缩到 **scr 记账 / cs2 括号 / NT 开关** 三处之内。
### ① 三臂配对（`l1_batch13`，引擎 RT 括号，3 对，三面逐字节 EXACT）
A shipped：pre 4.7/4.7/4.7、stem 3.3/3.6/3.3；B pre 显式 `NT=32`：**5.1/5.2/5.1（+9.6%）**；C `NR_CHIP_LW16=1`：pre 不变、**stem 3.2/3.2/3.2（-0.2 ms）**。
⇒ **NT 默认已改回 0**（`libxmx_sycl.cpp:2844`，`pe_l1nt0.py`，注释带三对读数与军规）；lcount14 过闸：非 fused 1301 **EXACT DD49827D**、`[vec-align]` 七条 ALIGNED、`pf=391`（+1 = 补的 cs2 括号）、fused 三面 EXACT。
### ② Patch B（`pre` 的 cr_* 手术）：**位相同、指令 -97.1%、腿级 -93%，但出货帧不涨**
- 改动：`pre_kernel.hpp` 在 `namespace prepass` 本地定义 `cr_mul/cr_add/cr_div = * / +`（遮蔽 `publish_kernel.hpp:21-22` 的 libdevice 包装），区间 `#pragma clang fp contract(off)`，**不写收尾 pragma**；
- **四闸 EXACT**：非 fused 1301 `DD49827D`（A/B 各一次）；fused features `CACD2029` / 1301 `ADC96F5D` / result `872C70D0`（4 条腿一字不差）；
- **GEN 指令**：`prepass::pre_kernel` **37,023 -> 1,089**；作用域审计（`l1_spill_census.py … ALL`，两份独立缓存逐核对照）：**除 pre 外无实质变化**（post +7、`gemm_int8_qkv` 28,513/47,075/1,392/21,991 完全相同、`vit_softmax`/`cosine_norm` 相同、`qr_*`/`pack_a_fused` ±1~4）=> **不泄漏**；**破 1301 的元凶 = 收尾的 `contract(fast)`**；
- **腿级（RT 括号）**：pre **4.734/4.718 -> 0.296/0.330 ms**；stem/post 不动；**RT 括号其实很紧**：319 闭包 < 0.10 ms（均值 0.0093）、min 0.002 ms => **旧结论"RT 是毫秒级松上界"加修正标记**；
- **出货口径**：**-0.076 ± 0.332 ms（4/8）= 带内中性** => **预登记线（<=-3.0 且 >=12/16）不达标 => 不转正**（件留 `builds\libxmx_lcount18.dll`）；
- **原因（读数支持）**：出货 cgraph 里闭包重叠，**pre 不在关键路径**；关键路径大户是 **`ffn_merge 4.66 / window_block 4.22,4.14 / ffn_stem 3.14 / global_attention 2.45`**（RT 表）——**前三条都不在第 1 层**；
- 非 fused `walk run` 口径第 1 对：A 179.8 / B 171.6 = **-8.2 ms**（串行跑就省得下来）=> **三套口径分开列（§19 定死格式）**。
### ③ 地板模型修正（军规 130）
`G`（请求量 154.85 MB）**作废**：新 pre 区域等效 **0.136 ms < G 地板 0.451 ms** => **L1/L2 吸收了 gather**，**分母只能用 DRAM 字节**。
新倍数（@343 GB/s，统一到区域等效）：**pre 0.136/0.151 vs 0.104 = 1.31/1.45x ✅**；**stem 1.44/1.59 vs 0.926 = 1.55/1.72x ⚠**；合计 **1.53/1.69x**（旧 3.75x）。
`NR_CHIP_LW16=1` 出货口径 8 对：**-0.158 ± 0.298 ms、4/8 => 带内中性**（腿级 -0.2 ms 被重叠吃掉大半）=> **stem 的 0.05-0.22x 缺口没能靠它闭合**。
### ④ 第 1 层六条线判定（§20）
**① fill 过**（pre 99.6-3,188%、chip<32> 400-800%、chip<16> 800-1,600%）；**② padding 过（0.0%）**；**③ 无下游重复 过**（ids 串）；**④ H2D/D2H = 0 过**（mc/ms = 0）；**⑤ 不比参考同层贵 过**（4 发 vs 5-7、0 拷贝 vs 3 拷贝 18.8 MB、腿级 1.6-3.9 ms vs 参考 3.7-4.8 ms）；
**⑥ 离地板 <=1.5x：pre 到线、stem 差 0.05-0.22x => 第 1 层不结案**。
### 军规 129/130/131（入 B2）
**129**：**局部 `#pragma clang fp …` 是词法作用域，会覆盖同 TU 后续所有核**；写"局部"FP 开关必须成对恢复，并**用逐核 GEN 指令数对照证明没泄漏**。本案：在 header 末尾加收尾 `contract(fast)` 把下游全放开融合 => **非 fused 1301 变成 ADC96F5D（不等于 DD49827D），而 features 仍 EXACT** => **逐字节主闸必须是 1301（f32 流），f16 打包的 features 只能当辅助**。
**130**：**"离地板几倍"必须用 DRAM 字节口径**；gather/请求量只能定位不能当分母。正案：pre 实测 0.136 ms 低于按请求量算的 0.451 ms 地板（L1/L2 吸收 gather）。另附 RT 修正：**RT 括号每发开销约 0.01 ms**（319 闭包 <0.10 ms、均值 0.0093、min 0.002），**同一 pre 在 RT 与区域两括号的膨胀系数 2.18** => **RT 是紧上界但按核不同，跨口径不可互换**。
**131**：**出货 cgraph 的帧时由关键路径决定，非关键腿的腿级节省会被重叠吸收**：pre 腿级 -93%（-4.4 ms）在出货口径只值 -0.076 ± 0.332 ms（带内中性），而在非 fused `walk run` 串行口径值 -8.2 ms。**=> 任何刀的转正判据必须是出货口径帧配对；腿级/串行口径只能用于归因与定位关键路径大户（本案关键路径：ffn_merge 4.66、window_block 4.22/4.14、ffn_stem 3.14、global_attention 2.45）。**
### 挂账（如实）
探针 `l1_probe.exe` 的 VERIFY/STEM/BW 臂多次 20 分钟停摆 => 逐字节闸已改到引擎里做；`web_fetch` 三次失败（api.github/github/raw 连不上）；`refs/fsr-sdk` 里没有 FSR3 HLSL；`onednn-gpu`/`llama-sycl` 的 sparse 由父级拉起。
### 变体清单（只进 builds）
lcount11 `256A34B4`、12 `9DC7C527`、13 `D97A64EC`、**14 `0D4986C3`（NT 默认 0，过闸）**、15 `3CC3CF99`（Patch A）、16 `B765299D`（Patch B 泄漏版）、17 `080D6671`、**18 `12D8F862`（Patch B 修正版，四闸 EXACT）**。

## 124. ★★★★★ **回归已消除（+4.950 -> 带内），而且仪表覆盖率反而变好；第 1 层六条线在各自口径下全过；两把刀在出货帧上带内中性**
### 改法（按批的做）**把计数从发射点搬进发射 helper 入口**：删掉 **186 个独立 `LC_INC` 语句**、**解开 15 个 `if/else` 体上的 `{ }`**（**lambda 体的 `{` 一律不动**：上一版脚本把 `pg_push([=](){` 的 `{` 当插桩括号删了，编译器当场拒建，已改保守规则且未出货）；**`LC_TICK()` 放进 30 个头文件里的 90 个发射 helper 入口**（`pack_device.hpp` 27、`gemm_s8_v8` 11、`window_block_mega` 8、`gemm_f16_v1` 7…）；`lc_begin/lc_end` 改成取差值写 `pf`；**两个诊断 `#ifdef`（`L1_NO_LCINC`/`L1_NO_IDVEC`）已删**。
### 件 = `builds\libxmx_lcount25.dll` = `060396C99F3E2799BCCD4E78E2A7EB7C`（3,948,032 B）
- **出货口径**：`lcount22` 8 对 = **+0.259（3/8）**；**`lcount25` 短配 4 对 = -0.197 ms（3/4 赢）** => **从 +4.950 回到带内**（判读线 |均值| <= 0.3 ✓）；
- **四闸全 EXACT**：非 fused 1301 `DD49827D`、fused features `CACD2029` / 1301 `ADC96F5D` / result `872C70D0`、`[vec-align]` 七条 ALIGNED、`[skip-chains] 14/0/168/691`；
- **`pf` 覆盖率变好**：非 fused **514**（旧逐点 390）、fused **752**（旧 547）=> **helper 入口把旧"窄策略"的盲区也数到了**；**`scr` 一字不差保住（1.29 / 1.50 GB）** ✓ 军规 128。
### 两处如实挂账
1. **`xmx_rec_global_attention` 现读 `pf=5`，手工数是 6 发**：缺的是 recorder 里**直接写 `GQ->parallel_for` 的站点**（不经过 helper）；**修法 = 把那几个站点重构进 helper，不是在发射点加语句**（军规 132）；
2. **`s6_ffn_block_kernel.hpp` 不能碰**：build 守卫钉死该文件哈希 `490647A9…`，给它加 tick 被 `GUARD FAIL` 当场拒建（件没出），已还原 => **该文件内的发射不计入 pf**。
### 两把刀在干净基线上的第一次有效读数（出货口径）
- **`Patch B`（pre 的 `cr_*` 手术）**：`lcount23`（同仪表、无手术）vs `lcount22`（有手术）8 对 = **-0.003 ms、4/8** => **帧上带内中性**；**腿级仍 4.73 -> 0.30 ms（RT）/ 区域等效 0.136-0.151 vs 地板 0.104 = 1.31/1.45x ✓** => **按军规 131：达标线成立、转正线不成立**（pre 不在 cgraph 关键路径上，§19 的重叠读数支持）；
- **`NR_CHIP_LW16=1`**：在 `lcount25` 上只切 env，8 对 = **-0.185 ms、B 赢 7/8、CI95 ≈ ±0.46** => **符号一致但均值没到 <= -0.4** => **不转正**（不拿 7/8 的符号充数）。
### 第 1 层最终判定（六条线，口径标注）
**① fill 过**（pre 99.6-3,188%、chip<32> 400-800%、chip<16> 800-1,600%）；**② padding 过（0.0%）**；**③ 无下游重复 过**（ids 串）；**④ H2D/D2H = 0 过**（`mc=0 ms=0`；全帧 scr 1.50 GB 另列）；**⑤ 不比参考同层贵 过**（4 发 vs 5-7、0 拷贝 vs 3 拷贝 18.8 MB、腿级 vs 参考 3.7-4.8 ms）；**⑥ 离地板 <= 1.5x（腿级/DRAM 字节口径）：pre 1.31/1.45x ✓；stem 带 `LW16` 后区域等效 1.24-1.39x ✓（不带则 1.55/1.72x ✗）**
⇒ **第 1 层六条线在各自口径下全过**；**但两把刀在出货帧上带内中性** => **第 1 层的钱已在腿级榨干；帧上看得见的钱在 `ffn_merge 4.66 / window_block 4.22、4.14 / ffn_stem 3.14 / global_attention 2.45`（RT 表）= 第 2 层**。
### 40 门冲突已按纪律停手（正确处置）
`tools/dsh_run_gates.sh` 的 40 门全部加载 `E:/DSH/oneapi/libxmx_sycl.dll`（staged 工件），而纪律写死加载位不许子代理动 => **两条指令冲突，它按纪律行停手**。**staged 与复原由父级做**，期望 **39 GREEN / 1 RED（`gate_libxmx_sycl` 身份守卫按设计）**。
### 军规 132（入 B2）：**在设备发射点周围新增语句/块会改变主机侧 SYCL/L0 发射辅助的内联与布局，实测每发约 +7 us；690 发 = +4.9 ms/帧**。**插桩必须放进发射 helper 入口或独立函数，绝不在 `GQ->parallel_for(...)` 外包 `{}` 或加前置语句**。正案：§121 一次提交 = +4.95 ms/帧，被当成"刀无效"排查了约两小时；修法 = 删 186 个 `LC_INC` 语句 + 解开 15 个 `if/else` 括号，`LC_TICK()` 进 90 个 helper 入口，**pf 覆盖率反而从 390/547 升到 514/752**。

## 125. ★★★★★ **第 2 层第一刀转正 => 帧 57.3 -> 56.3 ms（-1.074 ms、8/8 全胜）**。这是 A5 以来第一次帧上进账，而且**输出逐位相同（无画质风险）**
### 转正的两件（都位相同）
1. **`softmax_kernel.hpp` 的 `cr_*` 手术**（+26/-4 行：本地 `cr_mul/cr_add/cr_div` 遮蔽 `publish_kernel.hpp:21-22` 的 libdevice 正确舍入包装 + `#pragma clang fp contract(off)` 区间、**无收尾 pragma**、4 处 `fdiv_rn` -> `cr_div`）；
2. **`NR_CHIP_LW16` 默认 ON**（四处判定 `libxmx_sycl.cpp:3242/3341/3530/3715` 改成 `getenv(...) ? (...) : true`，**保留 `=0` 逃生**；符合军规 59：转正的刀必须默认生效）。
### 读数（出货口径 `ab.ps1` 同批配对，`-Pairs 8 -Runs 4`）
```
pair 1 A=57.300 B=56.320 -0.980    pair 5 A=57.080 B=56.320 -0.760
pair 2 A=57.900 B=56.480 -1.420    pair 6 A=57.530 B=56.250 -1.280
pair 3 A=57.550 B=56.320 -1.230    pair 7 A=57.290 B=56.250 -1.040
pair 4 A=57.100 B=56.590 -0.510    pair 8 A=57.760 B=56.390 -1.370
== 8 对：B 赢 8 / 负 0，均值 -1.074 ms；passes A/B = 691/691
```
**子代理侧更早的独立读数**：`lcount29`（只带 smax 刀）16 对 **-0.489 ms、15/16、CI95 ±0.183**；复合（`lcount29` + `NR_CHIP_LW16=1`）16 对 **-0.693 ms、14/16、CI95 ±0.298**；**叠加性**：预测 -0.674 vs 实测 -0.693（差 0.019 在 CI 内）=> **两把刀线性叠加**。**我这次建的是"两处都在默认里"的正式件，实测 -1.074 比复合 env 读数更好（件面不同：正式件走 `build_shipped.ps1` 的 defs 基座）。**
### 腿级与机制（第 2 层第一刀的归因）
- **腿级**：`global_attention` 八条腿 **2.19-2.69 -> 1.39-1.66 ms（每腿 -42%，串行合计 -8.1 ms）**；该路径 `passes=693 total` **148-168 -> 139-153 ms**；`window_block` 等其它大户两侧同值；
- **机制钉死（逐 ELF 实例对照，`s6/l1_per_instance.py`）**：GA 实际跑的 `vit_softmax_tiled`（`…NS_4itemILi1ELb1EEEE_`）在 c29 里**新增一个小编译形**：`12,793 行/6,981 ops` -> 新增 `9,385/5,191`（**行数 -26.6%、ops -25.6%**）；包装形同型；`softmax_kernel`/`softmax_i8_kernel` 多出一条 **`simd_size=32`** 编译形；**不调包装的 `smax_esimd`/`smax_esimd_tiled` 一字不差（474/507 行）=> 手术边界正好落在该落的地方**；
⇒ **GA 腿级 -42% 是直接效应**；**§24d/§24e 里"码代没变 / 占用耦合间接效应"两句撤回作废**；
- **估值更正**：**softmax 在 GA 的 `RT 18.96 ms` 里只占约 42%**（不是"整族可省 95%"）；`tools/instr_census_c29.csv` 显示**新形仍有 5,191 ops、其中 fixup 占 62%** => **这些包装链在共享 helper（`publish_kernel.hpp` 的 `qr_half_round/qr_e4m3/qr_publish`）里，家族级遮蔽碰不到** => **下一族 = 根手术**。
### 四闸与门链（转正前必过，全过）
- **非 fused 1301 = `DD49827DD33A7EF07C2C17892F18970D` EXACT**（gate40_p1/p2/p3 三次）；**fused 三面 `CACD2029` / `ADC96F5D` / `872C70D0` EXACT**；`[vec-align]` ALIGNED；`[skip-chains] 14/0/168/691`；`scr` 1,287,057,408 / 1,500,442,624 一字不差；
- **40 门**：staged 变体阶段 **39 GREEN / 1 RED（`gate_skip_graph` 身份守卫按设计）**；**正式件写入两槽 + 更新 `out/SHIPPED_MD5.txt` 之后：`gates: 40 GREEN / 0 RED`**；
- **逐核 GEN 对照**：270 个核里只有 1 个差 +1 条（JIT 噪声）；`pf` 覆盖率：非 fused **522**、fused **760**（GA 的 pf 5 -> 6）。
### 现场（新 ladder）**
**加载位 `out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = `B7CBE3A2AAED575984709097E98DB18D`（3,949,056 B）**；`out/SHIPPED_MD5.txt` = `b7cbe3a2aaed575984709097e98db18d`（**文件自身 md5 = `D427C836`**）；三金标 `DD49827D / DD49827D / 249A46F3` 未动；回退件 `builds\libxmx_pre-shiplw1-3BAECF2A.keep`、`builds\libxmx_sycl_3BAECF2A.keep`、`builds\backup_pre-gate-25.dll`、`out\libxmx.before-ATT5.keep`（`ABB969FE`）。
**帧阶梯更新：63.5 -> 58.5（1a -3.0、T2 -4.8）-> 57.3（A5 -1.251）-> 56.3（smax 刀 + LW16，-1.074）**
### 军规 134/135（入 B2）
**134**：**JIT 缓存里同一核名可以有多份编译形；核级对照必须逐实例列（全名、不去重、不截断），并且要比指令数/操作数，不能只比资源元组**。正案：两个对照工具按名字去重（一个取 max、一个比 `ze_info` 资源集合）=> 把 -26% 读成 0%；且新旧形 `grf/simd/eu` 完全相同（128/8/8），资源集合比较看不出差异。
**135**：**libdevice 正确舍入包装（`fmul_rn/fadd_rn/fdiv_rn`）在核内展开成整数 fixup 链，是本项目目前最大的单机制**：`pre` 37,023 -> 1,089 条（-97%）、腿级 -93%；`vit_softmax_tiled` 新增小编译形 ops -25.6%、GA 每腿 -42%、**帧 -1.074 ms（8/8）**。**修法是"家族内本地遮蔽 + `#pragma clang fp contract(off)` 区间、不写收尾 pragma"，逐位不变**；**共享 helper（`publish_kernel.hpp`）里的包装需要根手术**（`instr_census_c29.csv`：新形 5,191 ops 里 **62% 仍是 fixup**）。

## 126. ★★★★★ **qkv 族本地遮蔽转正（两槽 = `E0B03E90…`，40 门全 GREEN）+ ★ 一次"空刀变对照"的重要发现：16 对协议自身有约 0.2 ms 的 B-偏置**
### 转正读数
- **正式件 `builds\libxmx_shiqkv2.dll` = `E0B03E90D87F0FA90DCDE6BE3BB7366E`**（3,949,056 B）；**已写入两槽**；**`out/SHIPPED_MD5.txt` = `e0b03e90d87f0fa90dcde6be3bb7366e`**；**`gates: 40 GREEN / 0 RED`**；**非 fused 1301 `DD49827D` EXACT（gate40_p1/p2/p3）**；三金标未动；回退件 `builds\keep_pre_shiqkv2_B7CBE3A2.dll`（`B7CBE3A2`）、`builds\libxmx_pre-shiplw1-3BAECF2A.keep`（`3BAECF2A`）。
- **帧阶梯：63.5 → 58.5 → 57.3（A5）→ 56.3（smax + LW16，−1.074）→ ~56.0（qkv 刀）**
- **刀形**：`namespace qkvloc { static inline float cr_mul/cr_add = * / + }` + 在 `xmx_rec_gemm_int8_qkv` 体内两行 `using`；**只换乘加、不换除法、不加新 pragma**（这些体本来就在 smax 那刀的未收尾 `contract(off)` 区间内）；**语言事实：块级函数定义不能遮蔽全局同名函数**（clang `function definition is not allowed here`）⇒ **必须命名空间 + 块级 `using`**。
- **配对**：子代理 16 对 **−0.502 ms、16/16、CI95 ±0.133**；父级 8 对 **−0.381 ms、8/8**；**合计 24 对 24 胜、均值 ≈ −0.46**。
### ★★ 空刀 = 零效应对照（今晚最重要的方法发现）
`libxmx_res1.dll`（= qkv1 + `xmx_rec_gemm_int8_residual` 的 4 行 `using`）**其实是空刀**：普查显示 **`xmx_rec_gemm_int8_residual` 体内 `cr_mul/cr_add` 调用点 = 0**（它的算术全在 `s8v8` helper 里）⇒ 码代应与 qkv1 等价；
**但 16 对（A=qkv1、B=res1）给出 −0.178 ms、13/16 同号、CI95 ±0.174**
⇒ **16 对协议自身有约 0.2 ms 的系统性 B-偏置**，**且"13/16 同号"可在零效应下出现**。
⇒ **新转正线（父级批）**：**均值 ≤ −0.4 ms 且 |均值| ≥ 2σ(批内) 且 ≥ 10/16**；**每铲开工先跑 4 对 A-vs-A2 对照**（同一份源码建两只件）测该批协议偏差与噪声；**刀的真实效应 = 刀配对均值 − 对照均值**。
⇒ **据此 qkv 刀对外只报 −0.2 ~ −0.3 ms/帧**（−0.5 里含约 0.2 的协议偏置）；**件逐位相同 ⇒ 保留无风险**。
### ★ 机制更正（推翻我们自己前两刀的解读）
逐实例对照：`qkv1` 相对基线 **55 只核全部变大**、**全帧 ops 504,560 → 823,844（+63.3%）**、最大那只 `xmx_rec_gemm_int8_qkv` **25,548 → 56,190（+120%）**；**但腿级/帧级更快**。
⇒ **libdevice 包装 = 一次 call + 一条共享 fixup 大树**；**换普通算符 = 每站点各自内联展开**：条数上升，但**没有 call 开销与依赖性的整数修正链** ⇒ **更快**。
⇒ **这条机制的判据不是 ops 计数**（`pre`/`smax` 那两刀的 ops 下降只是同一件事的另一面）：**四闸 + 腿级 + 帧配对为准，ops 只作记录**（军规 137）。
### 相 A 的等价性矩阵（零 GPU 穷举，决定后面什么能换）
`tools/rn_equiv_host.csv`（1e7+ 样本，含 ±0、subnormal、tie、f16 边界 65504/65520、inf、nan）+ `tools/rn_equiv_matrix.csv`（器件侧 1 进程 2 秒）：
| 包装 | 判定 |
|---|---|
| `fmul_rn` vs `*` | **0 例不等价**（含 subnormal）⇒ 可换 |
| `fadd_rn` vs `+` | **0 例** ⇒ 可换 |
| `fdiv_rn` vs `/` | **11 例不等价，全是产生 NaN 的操作数**（`0/0`：普通 = NaN、包装 = 0）⇒ **换除法前必须先证该处除数不可能为 0、不可能 `inf/inf`** |
| `qr_e4m3` 普通形 vs `qr_e4m3_scalar` | **非 NaN 全域等价；NaN 处不等价（scalar 给 448）** ⇒ 涉及 NaN 的分支不许换 |
`qr_half_round` 全域等价；e4m3 网格 tie 扫 200k 点 RNE 一致。
### 根手术（共享 helper）挂账定论（不再试）
尺寸级二分：`pbe4`（只让 `qr_e4m3` 保留包装）= **3,940,864 B 几乎不缩**；`pbgate`（只让 `qr_gate_activation` 保留包装）= **3,371,520 B**；**两者 fused 面完全相同地红**（features `CACD2029` ✓、**1301 `254C02B7` ✗、result `DAC32974` ✗**）；**`pub1` 与 `pub1b`（加 `noinline` 恢复调用边界）给出两个一模一样的错值**
⇒ **病因不是收缩开关位置，而是全局替换波及其它 `cr_mul/cr_add` 消费者**（`cosine_tree`/`post`/`quantize_row`/recorder 内联体）；**`pbc` 正例证明：把替换限制在已在 `contract(off)` 区间内的文件 ⇒ 逐位不变**（军规 129 正例）。
**13 只 `qr_*` 量化核 ops/fixup 一字不差** ⇒ 它们走 `qr_e4m3_scalar`（`publish_kernel.hpp:42-58` 的 ESIMD 手写形，本来不调 `ext::intel::math`）⇒ 改不到也不变值 ✓。
### 族清单与顺序（`tools/cr_family_plan.csv`，零 GPU）
12 只族按 `腿数 × 调用点数` 排序：`1 gemm_int8_qkv`（20 点 / 106 腿 / RT 12.5）**已做**；`2 gemm_int8_batched`（4 / 64 / 7.5）**点名下一刀**；`3 global_attention`（1 / 48 / 11.2）**可能空刀**；`4 window_block`（4 / 10 / 18.0）；`5 ffn`（1 / 24 / 4.9）；`6 ffn_merge`（1 / 1 / 3.4）；`7 gemm_qkv_window`（5 / 0 腿）；`8 gemm_residual`（2）；`9 unary`（7 / 0 / 2.8）；`10 merge_heads_scale`（1）；`11 unary2`（2 / 1.6）；`12 gemm_window_residual_pool`（4）。
**全部 12 族 `cr_div_sites = 0`** ⇒ **除法/NaN 风险只在 `publish`/`smax` 里**（军规 136 的适用范围就此钉清）。
### 纪律事故（记档）
**第一次建正式件时，子代理第 2 族的 4 行还在工作树里** ⇒ 那只件（`485FA962`）含未验改动；**已 revert 并从干净 HEAD 重建（`E0B03E90`）全部重验**。
⇒ **立规：父级转正期间子代理不得改仓内任何文件（单写者原则）；下一族必须先点名。**

## 127. ★★★★★ **com2 复合刀：帧 -0.988 ms（8/8）与 -1.021（16/16）都达标，但 40 门链抓出 14 处真实位差 => 不转正，源码已 revert**
### 我做的转正动作与发现的顺序
1. commit `a93e190`（com2：11 个私有 namespace + 11 处体内 `using`，64 行插入）=> 从干净 HEAD 建正式件 `builds\libxmx_shicom2.dll` = `6AEE1ADED7741C45C6B8810BC89E423E`；
2. **staged 到 `oneapi` 跑 40 门 => `37 GREEN / 3 RED`：`gate_gemm_f16_qkv_window`、`gate_window_block`、`gate_skip_graph`**（第三只是身份守卫按设计，前两只是**真失败**）；
3. **主闸仍全绿**：非 fused **1301 `DD49827D` EXACT（gate40_p1/p2/p3 三次）**、fused 三面 `CACD2029 / ADC96F5D / 872C70D0` 也 EXACT；
4. **帧配对确实过线**：A = `E0B03E90`（keep 件）vs B = 正式件，**8 对：-1.190 / -0.990 / -0.440 / -0.690 / -1.040 / -1.070 / -1.360 / -1.120 => 均值 -0.988 ms、B 赢 8/8**（子代理 16 对 -1.021、16/16、CI ±0.079；本批对照 -0.160 => 真实约 -0.86）；
5. **但两门失败是硬伤，已回退**：`git checkout` 复原 `oneapi` = `E0B03E90`，**复跑 `gate_gemm_f16_qkv_window` / `gate_window_block` / `gate_skip_graph` = 3/3 GREEN**（证明失败由 com2 引起，不是环境）；**源码 `git revert a93e190`**，两槽仍是 `E0B03E90`、`out/SHIPPED_MD5.txt` = `e0b03e90…` 未动、三金标未动。
### 失败读数（真位差，不是抖动）
```
FAIL QKVW-40x56-float Q: 274 bad; first 100 got 0xaf80 want 0xb000
GEMM_F16_QKV_WINDOW RED (5 fails)
FAIL WB-16x24-head-halfimage: target differs from the 3-leg chain (16x24 flags=0x1008000)
WINDOW_BLOCK RED (9 fails)
```
⇒ **per-family 门用的输入与帧 dump 不同**（`40x56 float image`、`16x24 flags=0x1008000` half image、tiny 几何、narrow 路），**这些路径上把 `fmul_rn/fadd_rn` 换成普通算符会差 1 ulp 级别（`0xaf80` vs `0xb000`）**；**而 1301（整帧 f32 流）与 fused 三面都没覆盖到这些输入** => **主闸全绿不等于逐位安全**。
### 军规 139（入 B2）：转正的门禁必须包含**整条 40 门链**，不能只靠 1301 + fused 三面
**139**：**per-family 门（`gate_*`）覆盖的是帧 dump 没覆盖的输入形状与 flag 组合（tiny 几何、float image、half image、narrow/half_skip 路）**；本案 `com2` 在 1301 与 fused 三面全 EXACT、帧 -0.988 ms（8/8）过线，**却在 `gate_gemm_f16_qkv_window`（5 fails）与 `gate_window_block`（9 fails）暴露 14 处真实位差** => **任何"逐位不变"的宣称必须以 `gates: 40 GREEN / 0 RED`（staged 变体阶段允许 1 RED = 身份守卫按设计）为准**；**主闸只能证明"整帧 f32 流不变"，不能证明"所有输入路径不变"**。

## 128. ★★★★★ **com2 复合刀转正：帧 56.1 -> 55.1 ms（-1.015 ms、8/8；子代理 16 对 -1.021、16/16、CI ±0.079）；40 门 40 GREEN / 0 RED。20:09 那轮 3 RED 追认为认证环境假信号（不可复现）**
### 转正链（我做的，全部重验）
1. `git revert a93e190`（安全处置）=> **复跑两门 + 身份门 = 3/3 GREEN**（证明 20:09 的红不是门坏）；
2. 我自己在 scratch 里用 `s6/run_gates_scratch.sh` 把**两只 com2 件**（我的 `6AEE1ADE`、子代理的 `81F1ABBA`）各跑整条 40 门 => **两次都 40 GREEN / 0 RED**；
3. **staged 到 `oneapi` 用共享缓存跑那两门 = GREEN；换专用空缓存（`SYCL_CACHE_DIR=E:/DSH/tmp/syclcache_fresh`）= GREEN** => **20:09 的 5+9 fails 不可复现**；当时有并发 GPU 进程（子代理在做逐实例冷缓存对照），**共享 `E:/DSH/sycl-cache` + `SYCL_CACHE_PERSISTENT=1` 下并发读写 = 最可能的假信号来源**（军规 140）；
4. `git revert --no-edit 817c05d` 重新应用 com2（**11 个私有 namespace、22 行 using**：`gemm_qkv_windowloc`、`gemm_residualloc`、`ffnloc`、`ffn_mergeloc`、`batloc`、`qkvloc` 等，`:2945/3073/3289/3461/4002/4386…`）；
5. 从干净 HEAD 建正式件 **`builds\libxmx_shc2b.dll` = `A05A47AB302FA4D1545F41AA46B4A260`**（3,949,056 B）；**staged + 专用空缓存跑 40 门 = `40 GREEN / 0 RED`**；**出货口径 8 对（A = `keep_pre_com2_E0B03E90`）：-0.720 / -0.900 / -1.090 / -1.510 / -1.200 / -0.940 / -0.890 / -0.870 => 均值 -1.015 ms、B 赢 8/8**；
6. **两槽已写**：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = `A05A47AB…`；**`out/SHIPPED_MD5.txt` = `a05a47ab302fa4d1545f41aa46b4a260`**；**复跑 40 门 = 40 GREEN / 0 RED**；三金标 `DD49827D / DD49827D / 249A46F3` 未动。
### 码代同一性（子代理，逐实例）
**`changed = 18 of 270`，18 只全落在被点的 10 族内**（`unary` 4 只 6,693→3,425 等、`gemm_window_residual_pool` 2、`gemm_qkv_window` 2、`unary2` 2、`gemm_int8_batched` 2、`merge_heads_scale` 2、`ffn_merge` 2、`global_attention` 2）；**其余 252 只 ops/fixup 一字不差**；全帧 ops 823,844 → 800,047（-2.9%）；`xmx_rec_ffn`、`gemm_residual` 两处 using 在该 walk 未产生核变化（空刀）。
### 一条流程改进（采纳子代理提议，写进标准动作）
**`gate_*.py` 从 CWD 加载 `libxmx_sycl.dll`（`gate_gemm_f16_qkv_window.py:42`），依赖由 `DSH_ONEAPI` 指路 => 变体可以复制到 `E:\DSH\tmp\gatescratch\` 里跑整条 40 门，不必碰加载位。**
**=> 以后所有刀：交件前必须 `s6/run_gates_scratch.sh <dir> <suffix>` 跑出 `40 GREEN / 0 RED`（用专用空 `SYCL_CACHE_DIR`、串行、无并发 GPU 进程）。这同时消掉了"父级转正 vs 子代理改码"的单写者冲突。**
### 帧阶梯（今天）
**63.5 -> 58.5 -> 57.3（A5）-> 56.3（smax + LW16）-> 56.1（qkv 族）-> 55.1（com2 复合刀，11 处族内遮蔽）**；**今日累计 -2.2 ms/帧**，全部**逐位相同**（1301 + fused 三面 + 40 门）。
### 军规 140（入 B2）：**门链红必须在"专用空缓存 + 串行无并发"下复跑才算数；不可复现的门红按假信号处理，但当时的安全处置（回退）仍然是对的**

## 129. ★★★★★ **认证环境的根问题：两条门的 golden 不可复现——冷 JIT 编译 vs 缓存里来历不明的旧 Gen，同一个 kernel 的 ops 差一倍；从 11-03 `ship1` 到今天的每一件在冷编译下都红（反例数一模一样 5 与 9）**
### 读数（子代理在服务器断线期间证死的）
- `s6/run_gates_scratch.sh <scratch> <suffix>` + **专用空缓存** + 串行无并发：`libxmx_com4`（post/wbres/requant/f16v1）= **38 GREEN / 2 RED**（`gate_gemm_f16_qkv_window` 5 fails、`gate_window_block` 9 fails）⇒ 当场回退；
- **同一对门在 cold 态对下列每一件都红、且反例数完全相同（5 与 9）**：`libxmx_com2`（= 现槽源码件）、`libxmx_com2b`（去掉 qkv_window 一族）、`keep_pre_com2_E0B03E90`、`libxmx_shiplw1`（B7CBE3A2）、`lcount25`、`lcount22`（**smax 刀之前**）、`lcount4`、`bis4`（**§121 之前**）、**`ship1`（11-03 出货件）**、**`backup_shipped_slot`（11-04）**；
- **同一只件在 hot 缓存 `E:\DSH\sycl-cache` 下 GREEN**；
- **逐实例码代（`l1_per_instance2.py`）**：`xmx_rec_gemm_qkv_window` 体内核 **13,309 ops / 4,448 fixup（缓存旧 Gen，门绿）→ 28,066 / 8,389（今天冷编译，门红）**；`gemm_int8_qkv` **13,166 → 30,327**；
- **编译器与驱动都没变**：`sycl9.dll` 2026.1.0（文件 10-15）、驱动 32.0.101.9150（10-08）；
- **帧面在冷编译下完全不变**（现槽、全新空缓存）：**非 fused 1301 `DD49827D`、fused `CACD2029 / ADC96F5D / 872C70D0` 全 EXACT**，`pf=522`、`scr=1,287,057,408`、`[hop-total] 3396 planes / 30,786,624,936 B` 一字不差；
⇒ **冷/热差异只影响门里的形状族（40x56 / 8x8 / 16x24 / half image / narrow-crop / pooling），不影响 960x544 出货形状** ⇒ **实机风险低，但认证口径必须钉死**。
### 我的三条裁决
1. **com2 维持转正**：帧 −1.021（16/16）与 −1.015（8/8）真实、**帧面四闸在 cold 态也 EXACT** ⇒ 红不在它身上；
2. **认证两态并报，cold 为真值**（军规 141）：**`E:\DSH\sycl-cache` 从今起当受管工件备份 + 记 md5**，并在 `tools/` 写说明（哪些门只在 hot 下绿、为什么）；
3. **修那两门的 golden**（脚本化 `s6/l1_regengolden.sh`）：**从现 HEAD 正式件在 cold 态重生成**，**新 golden 必须同时被 `E0B03E90 / B7CBE3A2 / 3BAECF2A / ship1 / backup_shipped_slot / lcount4 / bis4` 在 cold 态匹配**（任一不匹配 ⇒ 停下回报）；**入库带 provenance（时间 / 件 md5 / 缓存态 / icx 与 sycl9.dll 版本 / 驱动版本 / 复跑命令）**；**旧 golden 改名 `*.golden.hotcache-legacy` 保留**（军规 142）。
### 新开的一条高价值问题（便宜但可能影响实机）
**游戏/回放到底用哪一态？** 要读码（`libxmx_sycl.cpp` 是否自设 `SYCL_CACHE_PERSISTENT`/缓存目录，给行号；`run_gates.sh`/`walk.ps1`/`ab.ps1` 各设了什么），并实测 **同一只件 4 对 hot vs 4 对 cold 的帧配对**；**若 cold 明显更慢 ⇒ 我们的 55.1 ms 依赖缓存里的旧 Gen**，**"冷启动/换机的真实帧数"要单列挂账，并考虑随件发布预热缓存**。
### 工具修正
`l1_span_count.py` 把注释里的文本算成调用点（`gemm_f16_v1_kernel.hpp` 的 22 点其实是 0）⇒ **只数代码不数注释**，重出 `tools/cr_family_plan.csv`；`post_kernel.hpp` 16 点、`wbres` 6 点、`requant` 4 点仍是候选。
### 军规 141/142（入 B2）
**141**：**JIT 缓存态是认证环境的一部分：每份读数必须标注 `cold`（专用空 `SYCL_CACHE_DIR`）或 `hot`（受管 `E:\DSH\sycl-cache`）**；**cold 是编译确定性的真值，hot 只用于历史可比**；**受管缓存要打包备份并记 md5**。
**142**：**golden 的可复现性是门链权威性的前提**：一条门若只在某种缓存态下绿、且其 golden 无法从冷编译复现 ⇒ **该门在其它态下的 RED 不能当证据**；**重生成 golden 必须走反证链（所有历史件在该态下都匹配新 golden），并带 provenance**。

## 130. ★★★★★ **更正我自己：20:09 那轮门红不是"并发读写"，而是 11-01 01:47 → 11-02 10:07 之间的一段既有回归；并且实机每次冷编译 ⇒ 冷态读数就是用户体验**
### 三条新事实（全部 cold 态、scratch CWD、未碰加载位）
1. **帧不依赖旧 Gen**：同一只现槽件 `A05A47AB`，**hot（受管 `E:\DSH\sycl-cache`）均 55.02 ms vs cold（今天新编译）均 54.96 ms，Δ +0.05 ms（带内）**；
2. **冷 JIT 是确定的**：两条**独立**新缓存跑同两门 ⇒ **日志字节相同、首个反例相同**（`QKVW-16x24-float Q: 67 bad; first 131 got 0xb300 want 0xb380`）
 ⇒ **军规 140 里"并发读写是最可能来源"的归因作废**；并且 `notes/DS-takeover-2026-11-01.md:2803` 记的"专用空缓存复跑 = GREEN"**在今夜同配置下复现为 RED** ⇒ **以复现为准重判**；
3. **回归窗口夹到 36 小时**：`ctrl_nomacros`（11-02 10:07）与 `rt2`（11-02 17:16）**已 RED**；缓存里 **11-01 01:47** 起的旧 Gen（`xmx_rec_gemm_qkv_window` 体内核 **13,309 ops / 4,448 fixup**）才与 numpy golden 相符，今天冷编译是 **28,066 / 8,389**
 ⇒ **改动落在 11-01 01:47 → 11-02 10:07**（候选 = §99/§100 的 P3a/P4 融合、attnV fold、`vit_softmax_tiled` 直写 `pack_a16`）。**两门 cold 复跑每次 ≈ 2 分钟 ⇒ 可直接提交二分。**
### 两条门的性质不同（这是关键区分）
- **`gate_gemm_f16_qkv_window`**：期望值来自**门内 numpy 参考模型**（`gate_gemm_f16_qkv_window.py:111`）⇒ 冷态**设备 ≠ 参考模型**，**只有 Q 面差、K/V 逐位相同 ⇒ 差异集中在 Q 归一化链**；**"重生成 golden" = 把设备行为判为正确 ⇒ 语义裁决：不许重生成，按 bug 追**；
- **`gate_window_block`**：**内部自洽对照**（composition vs 3-leg chain，`WB-16x24-epi1-narrow / f32out: target differs from the 3-leg chain`）⇒ **没有 golden 可改，冷态两条路互不一致 = 确定是 bug** ⇒ **先二分这个**。
### 认证口径改成（作废我上一条的"39/1 按设计"）
**修好之前：`38 门全绿 + 2 门已知红（挂 bug）+ 身份守卫（staged 时按设计红）`**，并把两门的**首个反例、二分结论**写进 `tools/gates_known_red.md`；**以后每铲的 40 门读数按这个口径判**。
### 一条要补的实机读数
**游戏进程不设 `SYCL_CACHE_*`**（`libxmx_sycl.cpp` 里 `SYCL_CACHE|_putenv|setenv` 0 命中；设变量的是 `tools/dsh_run_gates.sh:12-13`、`dsh_bench.sh:15-16`、`run_C1.ps1:8`、`run_C2.ps1:14`、`run_M.ps1:9`、`run_s6b.ps1:15`、`k2b_ab.ps1:26-27` = hot；`build_shipped.ps1:75-76` = 专用）
⇒ **实机每次冷编译 ⇒ 冷态读数就是用户看到的**；**要量冷态首帧代价（第一次 walk 的帧时 vs 稳态）**，若首帧明显更贵 ⇒ 单列挂账。
### 普查工具修正与 com4 的正确范围
`s6/l1_span_count2.py`（只数代码不数注释）：`gemm_int8_qkv` **20**、`gemm_qkv_window` **5**、`unary` 6、`gemm_int8_batched` 4、`gemm_window_residual_pool` 4、**`window_block` 4（com2 里其实没切它）**、`merge_heads_scale` 3、其余各 1-2；按区间的头文件：`softmax` 20（已切）、`wbres` 6、`requant` 4、`post` 16、`pre` 35 = **INSIDE 可切**；**`quantize_row` 0（`cr_div` 4）、`publish` 10、`cosine_tree` 8 = OUTSIDE ⇒ 不能切**；**`gemm_f16_v1` 真实调用点 = 0**（com4 那处是空刀）。
⇒ **com4 的正确重测 = `post(16) + wbres(6) + requant(4)`，cold 态跑"帧面四闸 + 38 门"，那两门的既有红单独记账。**
### 军规 143/144（入 B2；并更正 140）
**143**：**冷 JIT 编译是确定的（两条独立空缓存给出字节相同的日志与相同反例）⇒ 能在 cold 态复现的门红必须当真缺陷处理；hot 态绿不构成正确性证据。** 更正军规 140 的归因：20:09 的 3 RED **不是并发读写**，而是 11-01 01:47 → 11-02 10:07 之间的一段既有回归（`ctrl_nomacros`、`rt2` 已红；只有缓存里 11-01 01:47 的旧 Gen 与 numpy golden 相符）。**引用旧账里的"复跑 GREEN"之前必须先确认它能否复现。**
**144**：**门链的期望值来源要分清两类：`设备 vs 参考模型`（numpy）的门是语义权威，不许用"重生成 golden"把设备行为判为正确；`内部自洽对照`（composition vs 3-leg chain）的门在冷态互不一致时直接判 bug。** 附一条环境事实：**游戏进程不设 `SYCL_CACHE_*` ⇒ 实机每次冷编译 ⇒ 冷态读数即用户体验**（帧面 hot vs cold 只差 0.05 ms，带内）。

## 131. ★★★★★ **实机语义偏离参考，量化完成（960x544 出货几何）：`window_block` 的 composition 路与 3-leg 路差 4.287% 字节 / 6.45% 像素，其中 24,336 个元素相对差 >20%；门链里 `gate_window_block` 的 9/9 红是真 bug（门的 oracle 方向与参考同构）**
### 谁偏离（行号级）
- **参考** `refs/dlss-nr-on-intel/src/gpu/window_block.comp:180-191`：**f16 蝶形树**归一化（配对 hmul/hadd、`half_round(inversesqrt)`、`max(..., half_round(FLOOR))`），**且参考自己断言 fused == split 逐位相等**（`src/gpu/test_window_block.py:66-86 / :138-158 / :211-226 / :240`，`:240` 就是翻转 `rt.fuse_window_block` 做对拍）；
- **我们的 3-leg 链**：`ctree::cosine_reciprocal`（`cosine_tree_kernel.hpp:23,49,59`）**与参考同构**；
- **我们实机走的融合路**：`wbv3::cosine_recip_vec`（`window_block_v3.hpp:85+`，调用点 `window_block_v4.hpp:298-301`）**= 32 通道 f32 顺序累加 + 一次 `eh_round`** ⇒ **求和序与数值域都偏离参考**。
### 偏离量（cold、现槽件经 `tmp\gs_model` 副本加载，未碰加载位；工具 `s6/wbmodel.py`、`s6/wb_cap.py`、`s6/wb_cmp.py`）
| 形状 | 指标 | 读数 |
|---|---|---|
| tiny 16x24 | composition target vs chain target | **1,459 / 49,152 字节 = 3.0%** |
| **出货 544x960**（windows=8,160、rows=522,240）| 同上 | **2,865,706 / 66,846,720 字节 = 4.287%** |
| 同上 | **受影响像素**（至少一个通道相对差 >1e-3）| **33,674 / 522,240 = 6.45% 的画面** |
| 同上 | 幅值分布 | >1e-3: 910,873；>1e-2: 347,148；>5e-2: 93,214；**>2e-1: 24,336**（max 2677，近零分母放大）|
| 同上 | **参考模型 V 面 vs chain V** | **16,711,680 个元素只差 1 个（0.000006%）⇒ 模型成立** |
| 同上 | model vs chain / model vs composition | Q 0.510%、K 0.225%、attended 3.109%；**target：vs composition 5.355%、vs chain 7.924%** |
### 牙齿与噪声排除（(c) 微探针）
- **牙齿测试**：模型里故意把 ch0 符号翻掉 ⇒ **5,816 字节判红** ⇒ 对照器有牙；
- **`reciprocal` 三种形式**（f32 sqrt 取倒 / f64 正确舍入 / `x^-0.5`）给出**完全相同的差异数**（大形状 37,545 / 16.7M）⇒ **不是 reciprocal 形式**；
- **四种累加序**（BLAS f32 / f64→f32 / 严格 k=0..31 / 参考两段 x16）**差异数一字不差**（tiny 全 26 / 12,288）⇒ **不是 dpas 累加序**；
- **残差落在归一化的舍入链**：最好组合（先 `half_round(acc)` 预舍入、再 `half_round(h*recip)`）把 K 从 26 降到 **6 / 12,288（0.05%）**，但没有一种到 0 ⇒ **还欠一只直接读 `reciprocal` 中间位的小探针 kernel（已批为 (c2)，本轮没建、明确挂账）**。
### 为什么我们的门链之前没报警（军规 145）
**帧面 1301 是"我们这条 composition 路自己的历史快照"** ⇒ **它只能证明"不变"，不能证明"正确"**；**所以"帧面 EXACT"与"语义偏离参考"可以同时成立**。**今天 −2.2 ms 的每一刀都是逐位相同的，不受本条影响。**
### 待用户裁的三条路（我拿到 (c2) 基线后再问，不自己动）
**(a) 改 composition** 成参考的 f16 蝶形树（lane 映射 `{8g+2l,8g+2l+1}`、`shuffleXor 2→1`、`max(...,half_round(FLOOR))`、`half_round(inversesqrt)`；**不增加内存往返**）⇒ 9 用例有望转绿、`window_block` 重新有独立守门人，**但 6.45% 像素数值会变 ⇒ 必须实机判闪（闪 = 一票否决）**；
**(b) 保留现路**（f32 顺序累加在归一化上理论上精度更高，只是偏离厂商）⇒ 画面不变，**把门改成带容差的权威对照**（保留守门能力、承认已知偏差）；
**(c) 只改门不改路**：不建议（等于把偏离藏起来）。
### 军规 145（入 B2）：**自快照 golden 只能证明"不变"，不能证明"正确"**；凡从上游照搬来的融合/改写路，必须有一条**独立于自身**的权威对照（参考实现的 op 顺序模型或参考自带的 fused==split 断言），并且**该对照要在出货几何上量化偏离百分比**（本案：4.287% 字节 / 6.45% 像素 / 24,336 个 >20% 元素）。

#### 补一行（§131 内，上一条命令把它当命令解析掉了）
**两条路在不同阶段各自偏离**：**输出面上 composition 更贴参考模型（5.355% vs 7.924%）**，**归一化面上 chain 更贴模型**（Q 0.510%、K 0.225%、attended 3.109%）——**所以这不是"一条路对、一条路错"的简单情形：两条路各自在不同阶段偏离，但只有 chain 与参考的归一化算法同构，而实机走的是 composition。**

## 132. ★★★★★ **softmax 新形转正：帧 55.1 -> 51.5 ms（-3.68 ms、8/8；子代理 16 对 -3.627、16/16、sd 0.546、同批对照 +0.200）；两槽 = `F2364615…`；门链 `40 GREEN / 0 RED`（两种口径各一次，带 `[gate-selfcheck]`）**
### 这把刀是什么
**`smax::tiled_multirow`**：一行由 **32 lane（simd=16 时 2 个 sub-group）** 服务、**WG = 8 行 × 32 lane = 256**、四 pair 全进 local（`ps[rl*32 + c*4 + j]`）、行内 lane0 按 `hadd(hadd(hadd(p0,p1),p2),p3)` **左结合同序**、列折叠按 even/odd 收尾、块升序、**32 B 合并存**；`NR_SMAX_FORM` 默认 ON、`=0` 逃生；**guard** `tokens%64==0 && nrows%8==0 && stride%16==0 && stride>=tokens`。**只改 `softmax_kernel.hpp`（+106）**，`vit_softmax_tiled()`/`vit_softmax_kernel()` 一字未动。
### 读数（三级口径分开报，军规 112/131）
- **bench**（12 进程 × 4 对、冷缓存、件 `FA6287B3` 批后复验）：OLD `1.04734 ms` → NEW `0.35520 ms` ⇒ **ratio 2.948**（min 2.928、sd 0.010、**48/48 ≥ 2.0**）；**`Ap` 0/1,179,648、`recip` 0/6,144 逐位全等**；**组数实测 6,144 → 768（8.0×）**；**`w[k]` 复用判负**（慢 1.2% = 6×sd、多 6,144 B SLM、数值 0/0）⇒ **引擎不带 w 缓存**（推翻我给的"最大质量项"预期）；**ops 只降 6.5%（15,541 → 14,525）却快 2.9× ⇒ 军规 137 第二例**；
- **腿级（串行 `NR_RUN_TIMING`）**：`xmx_rec_global_attention` **11.116 → 5.988 ms/帧**（中位 −5.06、sd 0.201、**10/10**），每闭包 **1.389 → 0.749 ms**；**其余 20 族全在噪声带内** ⇒ **刀只咬 GA、无外溢**；
- **出货帧（cgraph）**：**16 对 −3.627 ms、16/16、sd 0.546**（父级另测 8 对 **−3.678、8/8**）⇒ **55.1 → ≈51.5 ms/帧**；**腿级 −5.06 > 帧 −3.63 = 重叠吸收的正常结果，两者不互相预测也不互相否定**。
### 码代（三方对照）
**槽实体 → HEAD 未打补丁：`0 changed of 270`**（仅仪表提交零码代漂移）；**HEAD 未打补丁 → 本刀：新增 `smax::tiled_multirow` 12,783 ops + 两只 `xmx_rec_unary` 各 ±1 op（182→181、202→203，净 0）** ⇒ **±1 由本补丁的 `static inline` 与 `<cstdlib>/<cstdio>` 改变 TU 内联/布局决策所致，不是仪表**；**语义未变**（四闸 + 逃生腿逐字节 EXACT；腿级 unary 2.939→2.858、sd 0.257 不显著）。**验收 ③ 按实测更正为"新增 1 核 + 2 只 unary 各 ±1（净 0）"。**
### ★★ 门链口径大修（军规 146/147）+ 一条旧结论作废
- **修好的仪器**：`tools/dsh_run_gates.sh` 现在先打 **`[gate-selfcheck]`：本次实际加载的 dll 路径 + md5、`SYCL_CACHE_DIR`**；**`RUNDIR` 可覆盖 ⇒ 能测变体**；**默认专用空缓存**；`oneapi` 留在 PATH 解析依赖。**旧版 `s6/run_gates_scratch.sh:22` 硬编码 `DSH_ONEAPI=E:/DSH/oneapi` ⇒ 所谓"scratch 门链"一直在测加载槽件**（证据：带 `NR_SMAX_TRACE` 插桩的变体在 40 门日志里 `[smaxform]` = 0 行，而同一件在 `nr_replay_now.exe <显式路径>` 打出 16 行 `-> NEW multirow`）。
- **`gate_graph` / `gate_skip_graph` 是 CWD 敏感门**：同一只槽件 `CWD=oneapi` 两门 GREEN，任何 scratch（连 16 只依赖 dll 都复制）两门 RED，日志先出 **`[skip-chains] chain=NN OUT OF RANGE (valid 0..18446744073709551615)` ⇒ 链登记表为空**，`gate_graph` 随后崩在 `xmx_buf_download` 访问违例 ⇒ **这两门必须 staged 口径**。
- ★ **复跑结果（修好的仪器 + 专用空缓存）**：**旧件 `A05A47AB` 在 staged 与 scratch 两种口径下 `gate_window_block`、`gate_gemm_f16_qkv_window` 都 GREEN**；**新件 `F2364615` 全链 `40 GREEN / 0 RED`（staged 一次、scratch 一次）** ⇒ **`tools/gates_known_red.md §3` 那张"冷编译下每一件都红、反例一字不差"的表不可复现，作废为 `caliber suspect`**；**20:09 那次 `6AEE1ADE` 的 5+9 fails 仍待复现（候选：共享缓存旧 Gen、那次 shell 的 `NR_*` 泄漏），复现之前不许当证据。**
- **语义事实仍成立（来自探针，与门链无关）**：composition 与 3-leg 在出货几何差 **4.287% 字节 / 6.45% 像素**；归一化倒数与残差融合形都被洗清；**用户已裁决不要求对齐厂商**。
### 帧阶梯（更新）
**63.5 → 58.5 → 57.3（A5）→ 56.3（smax cr_* 刀 + LW16）→ 56.1（qkv 族）→ 55.1（com2 复合刀）→ 51.5（softmax 新形）**；**本次一夜累计 −5.8 ms/帧**。

## 133. ★★★★★ **占用模型被探针改写：`local_mem_size` 是每 WG 上限、不是每片 SLM 池 ⇒ 并发 = 4096÷LW；`leg_decomp.csv` 的驻留列错约 8×；`window_block` 的 SLM 节食刀作废**
**探针**：`s6/slm_probe.cpp`（不 include 引擎头，只复制 `window_block_v4.hpp:32` 的 `LW=64` 与 `:36` 的 `slm_init<N>`），一档一二进制（`s6/cc_slm_probe.ps1`），每进程当场新建空 `SYCL_CACHE_DIR`（军规 148）；件 `builds\slm_probe_n<N>_lw<LW>.exe`（25 只）；账 `s6/layer1.md §58`；GPU ≈40 秒。
**读数**：`N ∈ {64, 8192, 16384, 24576, 32768, 40960, 45056, 49152, 57344, 57346, 65536}` 在 `LW=64` 下并发一律 **64 WG（8/片）**、`G=68` TIMEOUT；`LW=128` ⇒ **32**；`N=65,600` **REFUSED**（66,560 > 65,536）；`tagbad=0`、`tagchk=M×G` 精确；`live_after=0`、`sink≠0`（没被 DCE）。
**结论**：SLM 不是约束（45,056 B 的隐含上限是 11 WG/片，而线程槽只给 8 WG/片）⇒ **`SCR` f32→f16（省 8,192）+ `ATO→AQO`（省 4,096）⇒ 45,056→32,768 的占用收益 = 0**，**这把刀作废**；**`window_block` 的 4.3-6.9× 重新定性为"占用已满（8/片）⇒ 钱在每 WG 延迟链 + SLM 往返 + 每闭包 1 发"**。
**方法坑两条（军规 150）**：自旋窗太短会低估并发（1 ms ⇒ 40；16 ms ⇒ 64）；多档同二进制会被越界档毒死（连 `N=4096` 都起不来）。
**顺带纠正**：ocloc 1.73 对探针实例确实吐 `slm_size`（45,056 精确、64→1,024、57,346→58,368）与 `grf_count/simd_size/barrier_count`、无 `type: scratch` ⇒ "读不出保留量"只是出货大核的现象；`leg_decomp.csv` 其余 SLM 行（`ffn_merge` 31,744 ⇒ "2 WG"、`wbv3` 65,536 ⇒ "1 WG"）同样不是实测，该列已改名 `per_wg_slm_ratio_NOT_occupancy`。
**未测（别当结论）**：SLM 带宽/延迟是否随字节数变；出货核真实并发（要插桩 ⇒ 要改引擎，未做）；`grf` 压力对台阶的影响（探针本身 `grf=128` 与出货同值）。

### 11:55 **用户令（停止派新任务）**：**做完 float2Half 原生腿这把最大刀就要实机验证**；**验证前不得下发任何其他任务**；**他验证完回报、并明确说"继续"之前，一切铲都停**。
**当前唯一在跑的子代理**：`f2872c0d-5c83-45bc-8acb-0d76a9c1f090`，范围已收窄成四步（A 三拼法探针 → B 只改 `publish_kernel.hpp` 的 f32→f16 腿 → C 变化量量化 + 块崩塌/dB/corr + 腿级 ≥10 → D 出货 16 对 + 同批 4 对对照），**做完立刻停手交回**。**旧会话 `1b335290`（WB SLM 探针）已 interrupt，状态 inactive。**
**我（父级）在这期间只做**：核对写域（`git status` + 引擎文件对 HEAD 哈希）、**拿到 D 的读数后做转正**（从 HEAD 建正式件 → staged → 门链带 `[gate-selfcheck]` → 写两槽 → 更新 `out/SHIPPED_MD5.txt` 与 `notes/DEPLOYED_ARTIFACT.md` → 复跑门链 → 留回退件），**然后把件交给用户进游戏判**；**不再开任何新铲**。

## 134. ★★★★★ **IMF→原生算术根替换被用户实机验收上线：两槽 = `AF5A19B30E40B7594C142691F54B5B97`（3,382,272 B）**
- **上线时间**：2026-11-07 13:05 staged（`out\libxmx.dll` + `oneapi\libxmx_sycl.dll` + `out/SHIPPED_MD5.txt` 同步）；**回退件 `builds\libxmx_shsm1.dll` = `F2364615…`（51.5 ms/帧）**；三金标未动（新值另存 `dumps\n1301.imfnat1.*`、`f.imfnat1.*`）；**40 门故意未跑**（这只件按设计改数值，等用户裁完再决定重定基准还是回退 ⇒ 现已接受，**待补：三面基准重定 + 出货 16 对 + 腿级 ≥10**）。
- **用户实机结论（13:13）**：**"画面没问题，帧数提高不少"** ⇒ 接受；并给出两条流程令：**① 拿不准的大刀直取最大收益、做完就叫他实测（保守路线只在他判不行之后走）；② 每一层单开一份收益/刀法账本，方便后面的层复用**。
- **帧阶梯（更新）**：63.5 → 58.5 → 57.3（A5）→ 56.3（smax+LW16）→ 56.1（qkv 族）→ 55.1（com2 复合刀）→ **51.5（softmax 新形）→ ≈47-48（IMF 根替换，cold walk 信号；出货 16 对待补）**。
- **军规 156/157 入 B2**；`notes/layer1-gains.md`（第 1 层结题）与 `notes/layer2-gains.md`（第 2 层进行中）两份账本已建。

## 135. ★★★★★ **IMF 根替换认证完毕：出货 16 对 −5.763 ms、16/16、sd 1.295（|均值|/2σ=2.2）⇒ 帧 55.59 -> 49.83 ms/帧；门链 40 GREEN / 0 RED；同时逮到"门链不覆盖 fused 三面"这个覆盖洞**
- **16 对 delta**：`-3.46 -4.22 -4.54 -4.96 -4.99 -5.22 -5.66 -5.71 -5.81 -5.85 -6.10 -6.16 -6.41 -6.52 -7.88 -8.71` ⇒ **均值 −5.763、sd 1.295、2σ 2.591、B 赢 16/16**；**A = 上一上线件 `F2364615`（均值 55.59）、B = 当前 `AF5A19B3`（均值 49.83，区间 48.82-50.56）**；`passes 691/691` 每对都过；
- **门链（staged 口径、当场新建空缓存 `tmp/syclcache_cert_imf_2350`、`[gate-selfcheck]` 写明加载件 = `af5a19b3…`）= `40 GREEN / 0 RED`**；
- ★ **覆盖洞（军规 158）**：`logs/gate_graph.log`、`gate_coexist.log`、`gate_skip_graph.log`、`gate_ffn.log`、`gate_chain_qkv.log` 里 grep `ADC96F5D / 872C70D0 / CACD2029 / 254C02B7 / DAC32974` ⇒ **全部 0 命中** ⇒ **40 门链不比较 fused 路三面**；**改数值的刀必须先取 `tools/fused_face_baseline.md` 的基线**（当前三面 = `254C02B7… / CACD2029… / DAC32974…`，非 fused 1301 仍 `DD49827D…` 未变）；
- ★ **同一源码不同构建不改数值（军规 159）**：子代理 `libxmx_imfnat1.dll`（`9D69BDDB…`，12:43）与父级正式件 `libxmx_shfimf1.dll`（`AF5A19B3…`，13:05）**三面 md5 完全一致** ⇒ **排除"构建不确定性导致数值不同"这条解释**；**20:09 那次 `6AEE1ADE` 的门红回到"缓存态/口径"那条线**（军规 146/147/148）；
- **帧阶梯（更新）**：63.5 → 58.5 → 57.3 → 56.3 → 56.1 → 55.1 → 51.5 → **49.8 ms/帧（认证值）**；**2026-11-07 全天累计 −7.5 ms**；
- **回退链**：`builds\libxmx_shsm1.dll`(`F2364615`) → `builds\keep_pre_smax_A05A47AB.dll` → `builds\keep_pre_com2_E0B03E90.dll`；三金标未动（mtime 11-02/10-25）。

## 136. ★★★★ **腿级 A/B 刷新第 2 层的倍数表：`global_attention` 3.0-4.8× → 2.1-3.3×、`ffn_merge` 4.7-7.6× → 2.8-4.5×、`window_block` 几乎没动（4.3-6.9×）**
- **协议**：fused 693 passes、A/B 各 **6 个独立进程**、交替进行、**各自当场新建空缓存**（`syclcache_imfleg_{A,B}_0010`）；**A = `F2364615`（上一上线件）、B = `AF5A19B3`（当前）**；驱动 `s6/pe_imf_leg.ps1`（含 `GameWait` 守卫），汇总 `s6/imf_leg_agg.py`（解析 `rtcsv`）。
- **串行合计 138.781 → 132.516 ms（−6.265）**，与帧 −5.763 同量级但**口径不同、不互相预测**（军规 112/131）。
- **每闭包**：`global_attention` **0.775 → 0.516**；`ffn_merge` **2.730 → 1.618**；`window_block` **1.822 → 1.806（Δ −0.017）**；`window_attention` 0.310 → 0.308；`gemm_int8_residual` 0.346 → 0.344；`gemm_int8_qkv` 0.258 → 0.254。
- **逐族总 ms 的显著项**：GA **−2.076（6/6）**、`ffn_merge` **−1.112（6/6）**、`pre` **−0.704（6/6）**、`unary2` **−0.548（6/6）**；**只有 `gemm_int8_batched` +0.097 与 `ffn` +0.107 变差（均在 sd 内）**。
### 三条推论
1. **IMF 刀的钱落在"算术密集但未贴地"的族**（GA/ffn_merge/pre/unary2）；**已贴地的 int8 gemm 族几乎不动** ⇒ **军规 131/137 再成立一次**；
2. **`window_block` 对这把刀完全无感，因为它本来就是 ESIMD 原生腿** ⇒ **它的 4.3-6.9× 与软件模拟热点无关**，只能在**每 WG 延迟链 / SLM 往返 / 每闭包 1 发的依赖**上找；
3. **GA 只差最后一档**：`cr_hfma`（`cosine_tree_kernel.hpp:28`）与 `fdiv_rn`（`:50/60/70`，≈642 条/站点）仍是 IMF ⇒ **同一把刀的第二段，优先于开新刀**。

## 137. ★★★ **口径更正（子代理逮到我账本里的两个错）**
1. **全帧 ops 不是 336,505，而是 371,492**：我此前用的正则 `[A-Za-z0-9+|,_* ]` **不匹配带浮点谓词的行**（例 `(f0.0) cmp ...`），**漏掉 35,007 行 = 9.4% 的谓词保护指令**；修正工具 `s6/c2_look.py`、`s6/c3_full.py`。**§135/§136 里凡引"全帧 ops 882,001 → 336,505（−61.8%）"的地方，B 侧应读作 371,492；A 侧 882,001 同样偏低（同口径待重测）** ⇒ **−61.8% 这个比例待重算，但"下降过半"的定性不变**（**军规 137：条数本来就不当成绩，只当线索**）。
2. **每站点成本重标定（同一批 `hr_bisect` dump，新口径）**：**`fmul_rn` 410.8 条/站点、`fadd_rn` 1,233.2、`fdiv_rn` 776.8；原生 `mul/add`（含 half 往返）1.0-1.2 条/站点**。
3. ★ **新机制事实（改变排刀算术）**：**IMF 序列在帧里不全是逐站点内联，而是被编译器外提成共享子程序**：全帧 **221 只被 `call` 的外提体、645 个 call 站点 ⇒ 动态 116,392 条 = 静态体的 31.3%**（`att5::fused` 里一只 225 条的 e4m3 体外提后被 call 32 次）
 ⇒ **"软件模拟热点"的排序算术必须是 `动态条数 = call 站点数 × 外提体条数`，不是静态指纹行数**；**下一铲的 `tools/frame_hotspots.csv` 按这个口径重排**。

## 138. ★★★★★ **全帧"软件模拟热点"普查交回（零 GPU，`tools/frame_hotspots.csv` + `notes/bigknife-sweep-2026-11-07.md`）：全帧动态 468,002 条里 31.3% 是外提的软件序列，其中 `esimd::div_ieee` 下形一家就占 23.8%**
### 口径先修对
- **全帧静态 ops**：B（上线谱系）**371,492**、对照 `hb0` **1,048,060** ⇒ **第一把 IMF 刀实砍 −64.6%**（旧口径 336,505/882,001 漏了 9.4% 的谓词保护行：正则 `^\([A-Za-z0-9+|,_* ]*\)` 不含 `.` ⇒ `(f0.0) cmp …` 整行没数）；
- **每站点价格重标定**：**`fmul_rn` 410.8、`fadd_rn` 1,233.2、`fdiv_rn` 776.8、原生 `mul/add` 1.0、原生+half 往返 1.2 条/站点**。
### ★ 最大发现（改变排刀算术，军规 160）
**软件序列不是逐站点内联，而是被编译器外提成共享子程序按站点 call**：全帧 **221 只外提体 / 645 个 call 站点 / 动态 116,392 条 = 全帧动态 468,002 的 31.3%**；
**其中 `esimd::div_ieee` 的下形 = 69 只体 / 472 站点 / 动态 111,616 条 = 23.8%**（每体 195-454 条）；
**⇒ 排行算术 = `动态条数 = call 站点数 × 外提体条数`，不是静态指纹行数**。
### 两条否证（都入档，防止再走回头路）
1. **`sycl::half` 的算术/比较运算符不是热点**：全帧 `:hf` 只有 `mul 1,022 / add 294 / mad 8 / cmp 26 / sel 18 / math.inv 38`，**全是原生带类型指令**；便携形指纹 `0x1FFF / >>13 / <<10 / 0x7c00 / 0x3ff` **命中 0** ⇒ **我上一条怀疑的"下一个大热点是 half 运算符"被否证**；
2. **§61 说的"IMF 指纹还剩 4,392 行"不是 IMF 的账**：那套宽松立即数同时命中 **e4m3 指数提取**（`shr 23` 2,600 行、`and 255` 1,530 行、`448.0f` 2,077 站点）；**内联 IMF 真残量 = 106 块 / 54,574 条（静态 14.7%）～ 165 站点 / 127,690 条（marker 上界）**。
### ★ 每族兑换率（军规 161：先乘这个再决定砍不砍指令）
`GA 41.9-51.8K 条/ms`、`ffn_merge 7.6K 条/ms`、`post/unary2 30.4K 条/ms` ⇒ **砍指令有帧钱**；**贴地的 int8 gemm 族 1.16M 条/ms、`window_block` ~1.3M 条/ms** ⇒ **砍指令买不到钱，钱只能在延迟链/依赖上找**。
### 三把最大刀（子代理提的，按动态条数 × 关键路径）
- **刀 1 ★★ `esimd::div_ieee` → `inv + emul`（或每行一次倒数 + 每元素只乘）**：站点在 `pack_device.hpp:111/173/212/567/616/689`、`quantize_row_kernel.hpp:241/249/280/329`、`att5_fused_kernel.hpp:111/113/451/452`、`b6_res_kernel.hpp:392/393`、`gemm_s8_v8_kernel.hpp:1245/1253`、`s8_v9b/v9c`；**−100K+ 动态条**；落族 **GA 60,470 + ffn_merge 9,722（单这族 ≈ −1.3 ms）+ post/unary2**；**`quantize_row` 的 28,153 落在贴地的 `quant` ⇒ 不计帧钱**；预计 **腿级 −2 ~ −3 ms**；**风险：会改数值（1 ULP 商 ⇒ X.5 tie 翻）**；
- **刀 2 ★ 收掉最后一坨内联 IMF**：`cr_hfma`（`cosine_tree_kernel.hpp:28`）与 `cr_sub`（`post_kernel.hpp:28`）改用已经原生的 `cr_mul/cr_add` ⇒ **−54.6K（实测）~ −127.7K（上界）条**；落 `ctree 22,643`（GA ⇒ ≈ −0.44 ms）+ `postpass 12,301`（unary2 ⇒ ≈ −0.4 ms）；**`rec:gemm_int8_qkv` 的 39,298 条在贴地族 ⇒ 不算钱**；预计 **腿级 −0.8 ~ −1.5 ms**；风险：逐站点仅 ±0/NaN 类，**但刀 1 已证换原生会被重结合** ⇒ 必须走量化流程；
- **刀 3（零画质风险）`qr_e4m3` 两形合一 + `e4m3_decode` 换 256 项 LUT**：`qr_e4m3`（`publish_kernel.hpp:33-41`）**2,077 站点 × 29-51 条 = 60,233 条（12.9% 动态）**，而**同一函数的 ESIMD 形实测只 14 条/站点**（`gemm_s8_v8_kernel.hpp:397-411`、`att5/b6`）⇒ 把 plain-SYCL 站点换成 ESIMD/magic-add 形；`quantize_row_kernel.hpp:71-75` 的 `e4m3_decode` **每字节调 2 次 `sycl::exp2`** ⇒ 换 1 KB 的 256 项 f32 表；预计 **省 ~31K 条 + decode 链**；**风险：数值不变**——**lmxx 的 magic-add 形与出货形 host 逐位对照 6,048,389 样本 DIFFERENT = 0**（`s6/c9_e4m3_magic.py`，样本含全部 65,536 个 f16 精确值、全部 256 个 e4m3 码 ±、4M 随机位形、2M 管线幅度域、角值）⇒ **这把不用叫用户裁画质，走门链即可**。
### 社区锚点（带行号，可照搬性已判定）
- **lmxx**：`cosine_tree.glsl:16-18` 的 `hmul/hadd/hfma` = **`precise float t = l*r(+acc)` + `half_round(t)`，一个正确舍入库调用都不用**（⇒ 刀 2 的现成拼法）；`attention.comp:236-238/354-358/127-135` **每行一次倒数、元素只乘**（⇒ 刀 1 的保守形状）；`publish.glsl:41-46` **就是 magic-add e4m3 形**（⇒ 刀 3 直接照搬，已 host 证等价）；`publish.glsl:12-21` 明写"手工做指数/尾数要 10 条 + 2 分支，硬件转换只 2 条"；
- **oneDNN-GPU**：`…/jit/dsl/ir/codegen/kernel.hpp:645-652` **"fdiv_ieee() is not supported in XeHPG so we use a less precise, inv-based sequence"** → `inv + emul` 两条（`:680-682` 只有 XeHPC+ 才发真 `fdiv_ieee`；`:593` 另记"立即数 src0 不支持 fdiv_ieee"）⇒ **A770 = XeHPG，这是刀 1 的正当性来源**；`math_utils.h:671-677` + `conversion.h:63` 用 **`convert_char_sat_rte`**（一条饱和 RNE 转换）做 int8 取整+夹取 ⇒ 可替掉我们的 `rint + 双 clamp`；**整个 `src/gpu` 里没有一处 per-element 的 `ext::intel::math::f*_rn` 包装**；
- **ggml-sycl**：**LUT 反量化**现成机制 `vecdotq.hpp:114-131`、`dequantize.hpp:431-432/444-448/1775-1798/1825` ⇒ 刀 3 的 decode 表化；`dmmv.cpp:1593-1604/1751-1752` ESIMD 向量数学适用；**反面例子** `common.hpp:1159-1174` 的 `pow(2.0f, exp-7)` 逐元素 ⇒ 不要照搬；
- **`refs/fsr-sdk` 本轮无可读 shader 源**（只有文档与 `.bat`）、`refs/nvidia-dlss` 也没有可比对的设备算术源码 ⇒ 要做 FSR 系数表对照得重新取源。
### 顺带一条排刀结论
**`window_block` 的 4.3-6.9× 与软件模拟无关**（b6 只有 4,251 动态条、内联 IMF 块 0 只、兑换率 ~1.3M 条/ms）⇒ **它的钱仍只能在每 WG 延迟链 / SLM 往返 / 每闭包 1 发的依赖上找**（§136 推论 ② 成立）。

## 139. ★★★★ **刀 3 拆成 3a/3b：3a（decode 表）四闸全 EXACT 但只值 0.16% ⇒ 不上线；3b（magic-add）判死，机制抓到了**
### 3a `e4m3_decode` → 256 项表（**表按设备自己采出来的值建**）
- **四闸全 EXACT**：非 fused `DD49827D…` ✓、fused `254C02B7… / CACD2029… / DAC32974…` ✓（**每腿各自当场新建空缓存 `syclcache_k3a_{var_n,var_f,ctl_f}`，pre=0→post=12；控制腿（上线槽 `AF5A19B3`）三面全等 ⇒ 基线可复现**）；
- **设备口径已核**：`s6/e4m3_lut_probe.cpp` 在 A770 上跑 256 个码 ⇒ **设备自己算的 `exp2` 形与表用的位构造形 0/256 逐位相同**；
- **但收益极小**（`S32_c30_k3adiff.log`，同一非 fused cold walk）：shipped `371,492` → `370,902`（**Δ −590 条 = −0.16%**）、动态 `468,002 → 467,412`、call 站点 645 不变、**35 只实例变、235 只逐字节相同**（最大两处 `gemm_int8_qkv` −455、`qr_kernel` −139）；
- ★ **代价**：`qr_kernel` 的 `send` **18 → 29（+11 条访存）**、全帧 `send.*` +15 ⇒ **表把算术换成了访存**（`send.slm` 不变、`grf/simd` 不变、**无新增 scratch**）；
- **按军规 161 兑换率（`quant`/int8 族 1.16M 条/ms）⇒ ≈ 0.000-0.005 ms** ⇒ **决定：不上线**（不值 30 分钟 GPU 去测噪声），**留 `builds\libxmx_e4m3lut.dll`（`0EE101D7…`）当账**。
### 3b `qr_e4m3` → magic-add 形：**不是改 1 ULP，是舍入被整个删掉**
- 变体里 **`0x3C800000` / `0x0A400000` 两个立即数出现 0 次**，而 `shr 23` −424、`and 255` −424、**`rnde` −424**（`e4m3_448` 夹取 2,077→2,076）
 ⇒ **编译器把 `(magnitude + magic) - magic` 直接折回 `magnitude`**（默认 FP 环境下重结合/折叠；`contract(off)` 只管 `cr_mul/cr_add` 那两行）；
- 后果：1301 面 **2,088,960/2,088,960 = 100% 元素变**（mean|d| 0.156-0.482、max 6.43、**符号翻转 102,668**）、result 面 **85.15% 字节变**（mean|Δ| 63/255）⇒ **红线大面违约**；
- ⇒ **`qr_e4m3` 那 60,233 条（占全帧动态 12.9%）改判为"不可砍"**：要砍就等于取消 e4m3 量化语义（画质级改动，不是刀）；**在这台机器上 e4m3 snap 的价格就是 ≈29 条/站点的阶梯**（`shr23 / and255 / max(0x79) / shl23 / add / mul / rnde / mul`）。
### 军规 162/163 入 B2（两条都是这台工具链的硬事实）

## 140. ★★★★★ `imfnat2`（刀 1 ESIMD 限定 + 刀 2）读数交回：**机器层面成了，画质判据靠边；同时挖出引擎自己写好的免费配方，这把拆成两半**
### ① 形验证（`s6/c37_shapecheck.py` → `S38_shapecheck.log`；控制 = 上线件 371,492 条）
**全帧静态 371,492 → 267,229（−28.1%）；动态 468,002 → 303,195（−164,807 / −35.2%）**；
`esimd::div_ieee` 外提体 **69→49**、call 站点 **472→224**、动态 **111,616→46,646（−58%）**；**内联 IMF 块 106→20**；`call` 645→377；`sub/subb` 288→144；
**新形活着**：`mul :f` 10,472→11,585（**+1,113**）、**`math.inv` 后 4 条内跟 `mul` 的配对 63→68**（`s6/c39_guard.py`）⇒ **没被折回原值**；
**守卫**：`grf=128` 全不变、`send.slm` 3,545 不变、**`type: scratch` 1→0（无新增 spill）**；`simd` 只有一只实例 8→32（特化）；
**主人侧 div 动态**：`packdev 59,851→4,497（−92%）`、`att5 8,408→2,000`、`b6 4,200→992`；按令未动 `quantize_row 27,961`、`ffn2 9,690`、`s8v9 1,506`。
### ② 变化量分桶（对照 `tools/fused_face_baseline.md`；四处 **新 NaN/Inf = 0**）
| 面 | 不同元素 | `<6.1e-5` | `[6.1e-5,1)` | `≥1` | 符号翻转 | max\|d\| |
|---|---|---|---|---|---|---|
| 非 fused 1301 vs `DD49827D…` | 2,088,958/2,088,960 | 31 | 548,594（mean 0.171）| 1,540,333（mean 0.576）| 48,638 | 9.09 |
| fused 1301 vs `254C02B7…` | 2,088,960（100%）| 92 | 1,190,726（mean 0.251）| 898,142（mean 0.726）| 160,875 | 14.82 |
| fused result u8 vs `DAC32974…` | 1,789,648（85.67%）| — | — | mean\|Δ\| 54.05/255 | — | 255 |
| fused features | **未变 `CACD2029…`** | | | | | |
**`cr_div` 除数域逐站点证明**：`post_kernel.hpp` 里 `cr_div` 只有 1 个调用点 `:137`，除数 `proxyLinear = cr_mul(rgb, proxyScale)` 有 **`> 1e-6f` 守卫**；`rgb` 来自 `decode11/decode10`（`:33-40`，`(64+m)*exp2(e-21)` ≤ 65,024，必有限）⇒ **不可能 `0/0`、不可能 `inf/inf`**；`:109` 的除数 = `A.table[65538u]`（游戏给的 exposure）有 **`exposure > 0.0f` 守卫**，极小 exposure 时新旧形同样溢出 ⇒ **不引入新 NaN/Inf 类**。
### ③ ★ 画质判据并排（**它把已被实机接受的第一把刀也跑了一遍做校准**）
| 判据 | 第一把（已被接受）| `imfnat2` |
|---|---|---|
| dB@range RGB | **35.18** | **31.59（< 35）** |
| per-tile 64² <30 dB 块数 | **0** | **10**（<25：0）|
| **corr A** | 0.874 | **0.684** |
| 结构保持率 min | 0.973 | **0.808**（<0.8 块=0）|
| mean\|d\|/σ（p99.9）| 0.132（0.770）| 0.204（1.026）|
| 成片色偏 | 无 | max 0.605σ、>1σ 块=0 |
| judge | block-ok | **BLOCK-WARN**（A 通道 max-block-MAD/σ = 0.95 ≥ 0.40）|
### ④ 腿级（`s6/pe_k12_leg.ps1`，A=槽件 `AF5A19B3`、B=变体，6/侧交替、每进程新建空缓存、fused 693 passes）
**TOTAL serial 129.441 → 127.340 = −2.101 ms/进程**；批内配对帧信号 `−3.43 / −3.50 / −7.03 / +0.70 / −0.91 / −0.56` ⇒ **均值 −2.45、5/6**（**批内有热漂：A 从 138 降到 125 ⇒ 只有配对差可用，16 对才是定案口径**）；
**6/6 全赢**：`gemm_window_int8_residual −0.410`、`pre −0.373`、`gemm_int8 −0.285`；**4-5/6**：`quant −0.393`、`gemm_int8_residual −0.253`、`ffn −0.155`、`window_attention −0.124`、`global_attention −0.113`、`unary2 −0.053`；**反向**：`gemm_int8_batched +0.184`、`ffn_stem +0.038`、`window_block +0.018`、`ffn_merge +0.003`。
### ⑤ ★★ 机制事实（军规 164）：拆成"免费的一半"与"必然改数值的一半"
`pre_kernel.hpp:40-44` 引擎自己写明：**在关掉 FMA 收缩的区域内，plain `*` / `+` / `/` 本身就是一条正确舍入的 GEN 指令（`mul.rn`/`add.rn`/`div.rn`），值不变、没有 fixup** ⇒ **plain-SYCL 那一半（`post:27/28/109`、`cosine_tree:28`，还有 `cosine_tree:50/60/70` 与 `quantize_row:110/112/114/142` 的 `fdiv_rn`）应当逐位不变**（**前提：补上 `#pragma clang fp contract(off)` 区域——上一轮就是漏了它**；并且 `109` 要写 `rgb[ch] / exposure` 而不是 `×(1/exposure)`，后者多引入一次双舍入）；
**反面**：`gemm_s8_v9_kernel.hpp:44-45` 记着 **ESIMD 侧 plain `/` 不安全**（bench_v9 门逮到 `peak/127` 低 1 ULP）⇒ **ESIMD 想要正确舍入除法只有 `div_ieee` 那条 195-454 条的软件形** ⇒ **`esimd::inv` + 乘这一半必然改数值**（oneDNN 在 XeHPG 上正是这么换的）。
**⇒ 拆法**：`imfnat3`（纯逐位不变那半，**四闸必须全 EXACT，不需要用户实机**）+ `imfnat2b`（只含 ESIMD 那半，**用它单独去叫用户实机，判据不再被双舍入污染**）。
### ⑥ 一条更正 + 一条外溢警告（军规 161 更正）
- **更正**：`quantize_row_kernel.hpp:110/112/114/142` 是 **plain-SYCL `fdiv_rn`** 站点，与 **ESIMD `div_ieee`** 站点（`:241/249/280/329`）**是两类**，上一轮被混在一起按"贴地族"跳过了；
- **兑换率表不适用**：`imfnat2` 的钱出在"贴地"的 int8/pack 族，而预测落点 `GA −0.014/闭包`、`ffn_merge +0.003` 几乎没动 ⇒ **161 那张表只适用于 gemm 本体那类计算受限腿，不适用于 pack/发射受限腿**；
- **归因外溢**：`pre` 一行未改却 −0.373（6/6、sd 0.055）⇒ **只能解释为"下游核变小 ⇒ 排队/背靠压下降"**，**腿级读数必须允许这种外溢，不许当因果**。

## 141. ★★★★★ **一次失败的转正：`imfnat3`（−127,340 条 = −34.3%，本项目最大一代码代降幅）在 16 对上换不到帧时间 ⇒ 已回退，并据此改写战略**
- **16 对**（A=`libxmx_shfimf1.dll` / B=`libxmx_imfnat3.dll`；每腿新建空缓存 0→12、每腿开头清 `NR_*`、丢 run0 取 run1-3 中位、每对调换顺序、进程间 62 s）：
 `deltas: −0.410 −0.010 −0.180 +0.130 −0.350 +0.090 +0.170 +0.180 +0.080 +0.140 −0.020 −0.670 −0.080 +0.020 +0.010 +0.110`
 ⇒ **mean −0.049 ms、sd 0.240、2σ 0.480、B 赢 7/16、95% CI [−0.167, +0.068]**；**A 均值 46.190（sd 0.192）、B 均值 46.141（sd 0.106）**；
 **同批 A/A 对照 4 对**：`−0.280 +0.180 +0.070 −0.040` ⇒ **mean −0.018、sd 0.197、max|d| 0.280**；
 ⇒ **三条判读线全红**（`|mean| ≥ 2σ` ✗、`≥12/16` ✗、`≥0.15 ms` ✗）⇒ **帧收益不成立，完全落在同批噪声底以内**；
- **门链（staged 口径、槽件 `66FEC931`、`[gate-selfcheck]` 两行齐）= 28 GREEN / 12 RED**，红因是**量化 scale 本身低 1 ULP**（`gate_quant_window: packed 0-differ=False、scales bits-equal=False` ⇒ **§77 前科兑现**）与**倒数翻码**（`gate_vit_softmax: probs 0-differ=True、reciprocals bits-equal=False`）；差值本身都是 **1 码步级**；
- **腿级（6/侧交替、每进程新建空缓存）**：**TOTAL serial 124.416 → 122.949 = −1.467 ms/进程**；稳定项 `pre −0.338`(6/6)、`global_attention −0.191`(5/6)、`window_block −0.081`(5/6)；**明显反向 `window_attention +0.154`(1/6)**；
- **两条必须如实记的账**：① **`pre` 一行未动却 −0.338（6/6、sd 0.009）= 归因外溢**（下游核变小 ⇒ 排队/背靠压下降），不是 pre 的指令钱；② **`gemm_window_int8_residual` 在 `imfnat2`（动过 pack）−0.410、在 `imfnat3`（没动 pack）−0.000** ⇒ **那一族的钱来自 pack 发射侧**（**军规 161 更正的再验证**）；
- **热漂再一次证明**：同一只 `AF5A19B3` 这批读 **46.19**、上一批读 **49.83** ⇒ **绝对值不可跨批比，只有配对差可用**（军规 112/113）；
- **处置（04:5x）**：**两槽回退到 `AF5A19B3`**（已复算核对、`out/SHIPPED_MD5.txt` 同步、三金标未动）；`imfnat3` 件留在 `builds\` 当账；`imfnat3a`（只退除法、保留 `cr_hfma → cr_add(cr_mul)` 与 `cr_sub → a-b`）在验四闸是否回到 `DAC32974…` + 逐实例码代；
- **★ 战略改写**：**第一把 IMF 刀（−5.763 ms、16/16）之后，"砍指令质量"这条路对帧时间已经饱和**；**下一把必须结构性：发射数 / 依赖链 / 相位串行**，靶 = **`window_block`（每闭包 1 发、1.799 ms/闭包、离地板 4.3-6.9×、占用已满 8 WG/片、`send.slm` 203-267 行）** 与 **`ffn_merge`（1 发、2.8-4.5×）**。

## 142. ★★★★ **宽度这条路实测判死 + P3 的账重算：钱在 SLM 延迟/依赖，不在发射率**
### ① 门槛表（`wide_bench`，同一份工作两只核，每尺寸 3 进程、每进程新建空缓存、两臂输出 `DIFF 0`）
| 每次发射输入 | ESIMD ms | plain ms | ratio=plain/ESIMD |
|---|---|---|---|
| 4 KB | 0.00858 | 0.00686 | 0.800 |
| 8 KB | 0.00827 | 0.00737 | 0.891 |
| 12 KB | 0.00887 | 0.00737 | 0.831 |
| 48 KB | 0.00850 | 0.00774 | 0.911 |
| 256 KB | 0.07287 | 0.09311 | 1.278（**反常点，两臂都比 48 KB 与 1 MB 高一个数量级 ⇒ 不用它下结论**）|
| 1 MB | 0.01136 | 0.02407 | **2.119（ESIMD 快）** |
| 8 MB | 0.03438 | 0.13547 | **3.940（ESIMD 快）** |
⇒ **≤48 KB 两臂都贴在 0.007-0.009 ms 的发射/enqueue 地板上 ⇒ 那段"plain 快"是发射形状差，不是宽度红利**；**1 MB/8 MB 干净：ESIMD 每元素 1.4→0.52 ns 随规模下降，plain 3.0→3.2 ns 不降**；
**WB 每次发射 = 8.4 MB 进 / 16.7 MB 出 ⇒ 正落在 ESIMD 占优段 ⇒ "把纯向量相位脱 ESIMD"预期净亏 ⇒ 不建件**；**pack 的 3.2× 先例迁不过来**（pack 是近乎无算术的字节重排、当年 ESIMD 版还带 `div_ieee` 重活）。
### ② P3 审计（`tools/p3_slm_audit.csv`，21 行）
**先验纠正**：**6.68 ms 是十只闭包之和 ⇒ 每闭包 0.668 ms、每 window 327 ns、每 `dpas` 2.56 ns**（不是 25.6）；**2,040 WG ÷ 64 并发 = 31.9 波 ⇒ 每 WG 每条 (dpas+SLM) 操作摊 ~45 ns ⇒ SLM 延迟/依赖主导**；
**每 WG（4 子组、1 window）= 128 条 `dpas.8x8` + 80 条 SLM 载入**：**A 侧 16 条（`:219-222`，复用 8× ✓ 已做对）**；**K 侧 64 条（`:226-227`、`:232-233`，复用只 2×）**；
**★ 根因**：`bb = S_KTO + tc*512u`（`:225`）**不含 `sgid`** ⇒ **四只子组读同一段 4 KB ⇒ 16 KB SLM 流量换 4 KB 唯一数据**；
**P3→P4 的 SCR 往返 = 256 存（`:247-248`）+ 128 载入（`:268-311`）= 384 条纯开销**（这段归属本是子组局部，同一 `sgid` slab）；
**候选**：**C1 K-tile 按列切给子组（−48 载入/WG，`dpas/载入` 1.60→3.20，每元素 K=32 累加链不动 ⇒ 应当逐位 EXACT；风险 = SCR 地址与 P4 行归属要跟着改）**；**C4 P3→P4 寄存器融合（−384 条/WG，但 256 f32/线程 ⇒ 很可能溢到 scratch，必须先过 `type: scratch` 守卫）**；**C2 K 侧 hoist 进寄存器（`grf` 已顶格 128 ⇒ 必溢）**；**C3 换宽 dpas tile（`<8,16>`/`<16,8>` ⇒ 累加分解变了，不是逐位不变，要走画质门）**；
**仪器缺口（更正 A 仍在）**：`stop_stage` 阶梯给不了低于 dump 代价（≈2 ms）的段读数 ⇒ **C1/C4 的省条数用冷编译码代（ops / `send.slm` / dpas）验收，不用腿级 ms 验收 P3**。
### ③ 带宽清单（`tools/bandwidth_streams.csv`，9 行）
**最高风险 = `dC = pool_get(Mp*N*4)`（`libxmx_sycl.cpp:3011/3112/3194`，id 1309，f32 32 通道 66,846,720 B）**：被 `gemm_int8_residual ×136 / quant_window ×104 / window_int8_residual ×104 / window_block ×2` 碰，**且它是量化前的累加器 ⇒ `gate_quant_window` 已证 scale 低 1 ULP 就翻 tie ⇒ 第一刀不动它**；
**中风险**：`ffn` 的 `dsc1/dsc2/dsc3`（`s6_ffn_block_kernel.hpp:99-100`，id 1313/1311，喂 requantise 的 tie）；**别动**：`post_kernel.hpp:90 float* neural`（交给游戏的导入面）；
**最干净候选**：**`unary` 一族每帧把一张 f32 面读 48 次（id 1276，16,711,680 B，hop 申报 55.4 MB/腿）⇒ 换 f16 直接省读带宽，且 unary 的算术只是线性组合**；
**重申更正 B**：`[hop] bytes` 是申报足迹不是执行流量 ⇒ **逐帧字节按 (面)×(bytes)×(腿数) 算**；台账那个 **267.4 MB/帧 = 4 × 66.85 MB 的 f32 面减半**，与表里 id 1309/1313/1311 + 另一只 66.8 MB 实例对得上。

## 143. ★★★★★ **C5（`window_block` P3 去车道复制）认证完毕并转正上线：出货 16 对 −1.793 ms、16/16、sd 0.295（2σ=0.590）、同批 A/A 对照 mean −0.080 / max|d| 0.520 ⇒ 收益是噪声底的 3.0×；四闸 4/4 逐字节 EXACT ⇒ 不需要用户裁画质**
- **两槽 = `2F3ACF6C7E8BBC5098CF261F550A091D`（3,347,968 B）= 我从 HEAD `5daac9c` 干净重建的 `builds\libxmx_shfc5.dll`**；`out/SHIPPED_MD5.txt` 同步；**回退点 `builds\libxmx_imfnat3.dll`（`66FEC931…`）**；三金标未动；
- **16 对 delta**：`−2.210 −1.180 −1.600 −1.920 −1.430 −2.230 −1.760 −1.500 −1.510 −1.910 −2.170 −1.860 −1.760 −1.840 −2.010 −1.790` ⇒ **均值 −1.793、sd 0.295、2σ 0.590、|均值|/2σ = 3.04、B 赢 16/16**；**A 均值 46.26、B 均值 44.47 ms/帧**（**同批内可比；跨批绝对值不可比**）；**每对 `passes 691/691`**；
- **同批 A/A 对照 4 对**：`−0.520 −0.090 +0.100 +0.190` ⇒ **mean −0.080、max|d| 0.520** ⇒ **本批噪声底 ±0.52，我们的 −1.79 是它的 3.4×**；
- **★ 逐位不变成立（四面一字未改）**：非 fused 1301 `DD49827D…`、fused 1301 `254C02B7…`、features `CACD2029…`、result `AE050ED1…` ⇒ **四面基线不需要重画**；**且两只不同构建（子代理 `4EFAD2C4` 与父级 `2F3ACF6C`）四面完全一致**（军规 159 再证一次）；
- **腿级**：`xmx_rec_window_block` **17.963 → 16.134 = −1.828 ms/进程、6/6、sd(A) 0.042** ⇒ **每闭包 1.796 → 1.613 ms（−0.183，兑现 P3 每闭包 0.668 ms 的 27%）**；**TOTAL 串行只 −0.370**（未改动族 +1.46 的外溢，军规 166）——**但帧上拿到 −1.793 ⇒ 这一次"腿级 TOTAL 低估、帧配对才准"被正面证实**；
- **定档先例（军规 174 的实证）**：骨架探针 **ARM0 432 条 / 0.262 ms → ARM1 78 条 / 0.091 ms** ⇒ **静态 −82% 只兑换到时间 −65%**；
- **★ 下一把已点名（§77.7）**：**`f16v3::gemm_resid_pub` 冗余因子 = 32**（整个 WG 32 条线程算同一份 16×32 block；`libxmx_sycl.cpp:6496/6506/6520/6537/6553/6569/6577/6583/6615/6623` 确认在出货路上）⇒ **C6 = 同一套去复制，先零 GPU 定档再建件**；
- **帧阶梯（本批口径）**：`imfnat3` 46.26 → **C5 44.47 ms/帧**；**跨批参考：`AF5A19B3` 曾在另一批读 49.83（认证 16 对 −5.763）**。

## 144. ★★★★★ **C7（`window_block` P1/P5/P6 再去复制）认证完毕并转正：16 对 −0.766 ms、16/16、sd 0.235（2σ=0.470、|均值|/2σ=1.63）；四闸 4/4 逐字节 EXACT ⇒ 逐位不变；两槽 = `8658C78653ACE979A7FFEE8AD81CD627`（3,342,336 B）**
- **16 对 delta**：`−0.600 −0.520 −0.280 −0.530 −0.970 −0.590 −1.240 −0.810 −0.750 −0.600 −0.850 −0.840 −0.920 −0.830 −0.940 −0.990` ⇒ **均值 −0.766、sd 0.235、2σ 0.470、B 赢 16/16**；**A = `libxmx_shfc5.dll` 均值 44.32 → B = 43.55 ms/帧**；每对 `passes 691/691`；
- **同批 A/A 对照 4 对**：`−0.420 −0.090 −0.070 +0.080` ⇒ **mean −0.125、sd 0.211、max|d| 0.420** ⇒ **协议偏置 ≈ −0.13，净收益 ≈ −0.64 ms**；
- **四面（我从 HEAD `a2e7c3e` 重建的正式件 `8658C786`）**：`DD49827D…` / `254C02B7…` / `CACD2029…` / `AE050ED1…` **全部与基线一致** ⇒ **C7 逐位不变成立、基线不重画、不需要用户实机裁画质**；**子代理件 `745834F6` 与父级件 `8658C786` 四面一致**（军规 159 第三次验证）；
- **定档（先于改码）**：**P1 0.257→0.127（−51.3%）、P5 0.201→0.097（−51.9%）、P6 0.154→0.083（−45.8%）**；**守恒账**：P1 = 24 job × 64 = 1,536 = 3×16×32、dpas 48 不变；P5/P6 各 8 tile × 64 = 512、dpas 32/16 不变（**军规 173①**）；**三处 SCR 字节图 `row*128B + col*4B` 不动 ⇒ P2 行读回、P4 的 64 次串行 `ef_add`、P7 行读一律未触碰**；
- **守卫**：271 只共同核 **`grf/simd/type: scratch/SLM` 差异全 0**、`slm_init` 仍 45,056 B；**码代**：总指令 **2,397→1,806（−24.7%）**、`dpas.8x8` 静态站点 **98→17**、`send.slm` **191→125**；
- **腿级**：**`window_block` 16.179→15.367 = −0.813 ms/进程、6/6、sd(A) 0.060** ⇒ **每闭包 1.618→1.537**；**TOTAL 串行 −0.778**（**这次 TOTAL ≈ WB 自己的钱，外溢小**：`window_attention +0.156`、`gemm_int8_qkv +0.115`，被 `gemm_int8 −0.053`、`gemm −0.050` 等抵掉）——**与 §143 相反方向，说明外溢不是恒定的**；
- **先验更正（子代理自己做的）**：我给的"0.2-0.5 ms/闭包"偏乐观——**P5+P6 合计只有 0.044 ms/闭包**，**实测 −0.081 的大头来自 P1**（与探针 −51% 对得上）；**按 §143 的腿→帧比值 0.98 预期 −0.5~-0.8 ⇒ 实测 −0.766 命中区间**；
- **车道复制这条线的累计战果**：**C5 −1.793 + C7 −0.766 = −2.56 ms/帧**（**同一批口径链：46.26 → 44.47 → 43.55**），**全部逐位不变、全部 16/16**；
- **下一块田（已下令）**：**C6 = `f16v3::gemm_resid_pub` 冗余因子 32**（整个 WG 32 条线程算同一份 16×32 block；`libxmx_sycl.cpp:6496/6506/6520/6537/6553/6569/6577/6583/6615/6623` 确认在出货路上）⇒ **同一流程：零 GPU 定档 ≥25% 才切**；**回退链：`builds\libxmx_shfc5.dll`（`2F3ACF6C`）→ `libxmx_imfnat3.dll`（`66FEC931`，用户 06:39 实机验收）→ `libxmx_shfimf1.dll`（`AF5A19B3`，49.83 认证值）→ …**

## 145. ★★★★ **C6 结案：取消，不建件——因为靶子不存在（×32 复制在一条**默认关闭且已被文件自己判死**的 env 门控分支里），而活路只值 0.120 ms/进程**
- **读全的结果**：`gemm_f16_v3_kernel.hpp:86` 的 `if (use_slm) { nd_range(range(tr_n*32), range(32)) }` 就是 §77.7 我引的"32 线程算同一份 16×32"；**但 `:85` 的 `use_slm = getenv("NR_V3_SLM") ? … : false` ⇒ 默认 OFF**，`shipped_build.defs` 与 `patch_testdefs.py` 的编译期钩子里都没有它 ⇒ **出货件里这条分支永不执行**；**文件自己已判死（`:81-84` "section 100 D3 MEASURED DEAD: acc-via-SLM makes v3 SLOWER (262 vs 240) … Default OFF"）**；**活路是 `:230` 的 register-tail 形**（`tr = get_id(0)`、`ab = Ap + (tr*kb_n+kc)*2*128` **含 `tr` ⇒ 无复制**；B 侧只由 `kc` 决定 = 共享权重，正常 GEMM 形状）；
- **更正我上一铲说过头的一句**：f16v3 的 10 个调用点里**只有 3 处是活路**（`libxmx_sycl.cpp:6577` head、`:6583` pooling、`:6623` 正常路），**其余 7 处是 `NR_WB_STOP = 87/98/97/95/96/94/91` 诊断停点与默认关闭的 staging 路**；三条活路都在 **`xmx_rec_window_block`** ⇒ **f16v3 = WB 腿的 leg3**；
- **绝对毫秒用引擎现成的 `NR_WB_STOP` 阶梯量（比新写探针更硬：量的是出货路）**（`s6\pe_c6_ladder.ps1`，件 = 当时 staged 的 `8658C786` 只读复用、5 停点 × 2 进程交错、每进程新建空缓存、串行）：**leg3 总价 (99−86) = 0.120 ms/进程 = WB 腿 15.43 的 0.8% = 每闭包 0.012 ms**；分解：**gemm 本体 (87−85) = 0.062 ⇒ 落在噪声里**（同停点两进程就差 0.13-0.22）、tail 0.083、散列存 0.068、pack 0.030；**⇒ 定档门槛（≥25%）连分母都不成立**；
- **本轮没有改引擎、没有建件、没有跑四闸/腿级**（这是判定的一部分）；普查表 `E:\DSH\tools\lane_replication_audit.csv` 的 f16v3 行已就地更正为"活核 factor 1 / 死分支 factor 32（`NR_V3_SLM` 默认 OFF、文件记为 MEASURED DEAD）/ 3 处活调用点 / leg3 = 0.120 ms/进程 = WB 腿 0.8% / 停线理由"（24 行 × 13 列、7,047 B、ASCII）；**GPU ≈ 3-4 分钟**；两槽与三金标每批前后复算未变。
### 军规 175（同族于 174）
**读"复制因子 / 离地板倍数"之前必须先证"这条分支是不是活的"，并且任何冗余结论在排刀前要用引擎现成的 STOP 阶梯给该段定一次绝对毫秒。**
**env 门控分支（`getenv("NR_*")` 默认 OFF）照样被编译进件 ⇒ 逐 ELF 的 `.ze_info`/asm 静态普查会把死分支当活形状**（本铲就是这么错的）⇒ **普查表加一列 `branch_is_live`（default / env 名 / 编译期 defs / 调用点停点）**；**没有绝对毫秒定档的靶不许进排刀表**。
### 车道复制这条线结案
**活核里已收割完：C5 −1.793 + C7 −0.766 = −2.56 ms/帧，全部逐位不变、全部 16/16。**
**下一铲 = 零 GPU 的"靶排序表"**（每族 `leg ms × 离地板倍数 × 字节地板 × 可挖 ms 上限 × 已知机制是否饱和 × 候选杠杆`），由父级挑刀；**当前最大的非贴地族仍是 `window_block`（15.3 ms/进程、3.9-6.2× 地板）**。

## 146. ★★★★ **靶排序表出炉 + 一台仪器被判废（相位级定档以后只能用骨架探针）**
- **两张表**：`tools/knife_ranking.csv`（19 行 × 18 列）、`tools/lane_replication_audit.csv`（23 行 × 14 列，**新增 `branch_is_live`**）；
- **★ 线上停点阶梯现在量不动了**（57 腿，`s6\pe_k3e_ladders.ps1`，GPU 68 秒）：**`NR_V2_STOP` 出现物理不可能的序**（全跑 16.341 → stop=5 18.291 → stop=6 20.015 → stop=9 20.402，而 stop=10/11/12 = 12.567/12.400/11.525）⇒ **早退腿的 dump 代价（16.7 MB 写 + 下载）已经是主导项**；**`NR_WB_STOP` 同批废**（**TOTAL serial 双态 121-122 vs 128-136 ms = 13 ms 的时钟/热台阶** ⇒ 导出量为负）；**上一铲 §79.2 的 leg3 = +0.120 ms/进程仍然有效**（那批无 dump、TOTAL 稳在 120.4-120.9）；
- **军规 176（已入 B2）**：**相位级定档一律用骨架探针（静态槽 + 墙钟，sd 0.003 级）；线上 STOP 阶梯只适合 ≥5 ms 的段，且停点腿必须与对照腿成对相邻；停点差 < 同批 TOTAL 态移 ⇒ 直接判废**；**另：`NR_WB_STOP` 量的是 leg3，`NR_V2_STOP` 才是相位**（父级原话混用过，已更正）；
- **现役 per-family 数取自 C7 的配对腿级**（`rt_c7leg_B_*`，A/B 同分钟交替）：**`window_block` 15.887 ms/进程、1.589 ms/闭包**；
- **`branch_is_live` 全表补完**：**LIVE-DEFAULT**：`wbv4::launch_v4full`、`ffn2::fused`、`ffnc::launch_ffn_chip/_cs2`（`NR_FFN_CHIPRES/JOIN/FF3/CHIP_CS/FF9` 全默认 ON、`NR_CHIP_LW16` 默认 ON）、`s8v8::gemm_b_pub_slm`、`gemm_b_res_window`、`s8v5::gemm_qkv_v`、`qres::gemm_qkv_res`、`wares::launch_wa_res`、`att5::fused`（编译期 `T_ATT5_FUSE_DEF=1`）、`b6`、`lfw2`、`f16v2::gemm_b2<32/64>`、`f16v1::gemm_dual_pub/gemm_pub_pa16/gemm_b_merge_scale/gemm_b_pub_f16`；**DEAD-BY-DEFAULT**：`wbv4ph`、`wbv3`、`wbmega::launch_full`、`s8v8::gemm32_b_pub`、`gemm_b_res_batch`、`ffnc::stem_mega`、**`f16v1::gemm_b`**、`f16v3` 的 `nd_range` 分支与 staging 路；**DEAD-NO-SITE**：`ffnt::launch_ffn_fused`、`lfw::launch_lfw`、`qkv_resident`；**ROUTE-DEPENDENT/未复核**：`s8v8::gemm_b_pub`、`s8v9::gemm_b_rq`、`s8v9b::gemm_b_rq9b`；
- ★ **连带发现（引用要标 vintage）**：`leg_decomp.csv` 里 GA 那行写的是 **"f16v1::gemm_b (scores leg)"，但它现在默认不走**（默认是 `f16v2::gemm_b2<64>`）；
### 排刀结论（预估帧钱降序，**无绝对毫秒定档的候选一律 `est = -1` 不许排刀**）
1. **跨族字节面 `f32 → f16`**：**0.48-0.78 ms/帧**（**改数值 ⇒ 走用户实机，不走四闸**）；**最干净的一条 = id 1276（`unary` 每帧把一张 f32 面读 48 次）**；**id 1309 `dC`（被 `gemm_int8_residual ×136 / quant_window ×104 / window_int8_residual ×104 / window_block ×2` 碰、且是量化前累加器）押后**（`gate_quant_window` 的 1 ULP 前科）；
2. **`window_block` 依赖链/相位拆分 ≈ 0.21 ms/帧**（**复制杠杆已收割完**）；
3. **`window_attention` 字节 ≈ 0.16 ms/帧**；
4. **`gemm_*`/`ffn` 各族未定档 ⇒ 不许排刀**（要成对跑 `NR_RES_STOP`/`NR_B_STOP`/`NR_G_STOP`/`NR_STEM_STOP`/`NR_FFN_*`，否则又撞 13 ms 态移）。

## 147. ★★★★ **面地图出炉（`tools/plane_map.csv`，57 面 × 24 列，零改动零 GPU）；C8 的原靶已结案；新的字节刀第一名换人**
- **(A) 那行诊断改动不需要**：**`[lcount] … [hop] … ids=` 就是 `pgraph_ids({...})` 的参数顺序**（19 处调用点全部可枚举：`xmx_rec_unary` 的 `{a,b,c,d}` 在 `:5128`、`window_block` 的 `{image,qkv,projection,target,bias,cosine,scale,pooled}` 在 `:5967`、`gemm_int8_residual` 的 `{a,b,c,a_scale,b_scale,skip,cosine}` 在 `:4849`…），**而"哪一格是写"从 recorder 体内直接可读**（`xmx_rec_unary` 里 A/B/D 是 `const void*`、**C = `void*` 是目的**，`:5131-5135` ⇒ `ids=1276 1276 1310 1276` = a/b/d 读、**c=1310 写**）；**15 个 recorder 的写格已编成表**（`s6\c74_planemap.py` 的 `WRITE_SLOT`，每格带源码行号）⇒ **尺寸 / 谁写 / 谁读 / 每帧碰几次**全部零改动拿到；
- **C8 结案**：**id 1276（16.71 MB）对应盘上工件 `*.features.bin` 本来就是 f16**（域 −1..1.65、12.5% 精确 0、次正规带 0.005%、**f16 往返改变 0 个值**）⇒ **无刀可切**；
- **新第一名 = id 1313（33.55 MB f32、522,240 px × 16 通道）**：**87.6% 是精确 0**（零在 f16 里精确）、**溢出 0、次正规 0**、**f16 往返只改 11.74% 的值、误差恰好 1 个 f16 ulp（max abs 0.25、max rel 4.88e-4）、冲零 0** ⇒ **风险画像明显好于 1309**；
- **第二名 = id 1309（66.85 MB pre-quantise 累加器）**：域 −123.7..163.7 ⇒ f16 范围安全，**但 99.95% 的值会变 + `gate_quant_window` 的 1 ULP 前科 ⇒ 继续押后**；
- **第三名 1311/1314/1315/1316**：**无工件 ⇒ 域 UNKNOWN ⇒ 按军规 175 不许排刀**；
- **★ 军规 178（已入 B2）**：**footprint ≠ 执行流量**——日志只有"操作数槽 × 整面字节"，没有每命令的区域（`n/M/N/K/cols`）⇒ 表里 MB/帧是**上限**；**佐证**：1309 若真按 13.4 GB/帧搬运，300 GB/s 就是 44 ms/帧，而全帧串行才 120 ms、其中 gemm 族合计 ≈ 64 ms ⇒ **这些族已经在字节地板上**（与 1.22-1.4× 一致）；**任何字节刀在做完"区域联接"（零 GPU：`launch_map.csv`/`shapes_census.csv` 的每命令元素数 × 面地图）之前不许进 `knife_ranking` 的 ms 列**（第 1 行的 `estimated_frame_ms` 已清空、`rank_score = −1`）。
### 军规 177（同铲入库）
**census/日志里的 plane id 是每次运行局部的 ⇒ 任何按 id 引面必须重新联接，联接键 = `(bytes, imported, gen, class, named_in_plan)`**；三处互证的矛盾：§73 说 id 1276 = 16,711,680 B、本轮 `[bufsizes]` 也是 16,711,680（同批 1271 也是 16,711,680）、而 `tools/plane_class.csv`（另一次 census）里 id 1276 = 4,177,920 B、其 16.7 MB 面是 1265/1270、id 1309 = 4,571,136 B（本轮 1309 = 66,846,720 B）。

## 148. ★★★★ **区域联接出炉：footprint 高估 9.7-22.9 倍被量化确认；1313 是池回收 slab（混合 dtype）⇒ 字节刀必须按"边"定义，不能按面**
- **新表**：`tools/plane_traffic.csv`（385 面 × 18 列）、`tools/knife_ranking.csv`（21 × 18）；**引擎一行未改、GPU = 0**；
- **1313（33.55 MB）每帧执行流量 = 904.9 MB/帧（R 718.7 / W 186.2）vs footprint 8,791 ⇒ 高估 9.7×**；**1309：执行 584.6 vs footprint 13,369 = 22.9×**（**军规 178 的量化确认**）；
- **但 1313 不是逻辑缓冲，是池回收 slab**：它同时被 `gemm_int8_qkv` 的 k 输出（**int8**）、`window_attention` 的 out（f16）、`gemm` 的 c（**f32**）、`quant` 的 packed（int8）、`unary` 碰 ⇒ **"把这张面换 f16"在 slab 上没有定义**；**1311/1314/1315/1316 全是 int8 活动面 ⇒ 换 f16 反而更贵（无刀）**；
- **E1（最大字节 prize）**：`gemm_int8_residual` 写 f32 C（68 × 8.36 = **568 MB/帧**）→ `quant_window` 读它（52 × 8.36 = **435 MB/帧**）：这条边的累加器 f32→f16 = **省 ~501 MB/帧 = 1.64 / 2.28 / 2.64 ms/帧**；**风险 HIGH**（pre-quantise 累加器、实测 f16 往返 **99.95% 会变**、max abs 0.062 / rel 2.75%、`gate_quant_window` 的 1 ULP 前科）⇒ **§73 的"押后"在本铲之后仍然成立**；
- **E2**：1313 slab 的 f32-gemm 那一片（**132 MB/帧**）⇒ **省 66 MB/帧 = 0.22 / 0.30 / 0.35 ms/帧**，风险 LOW-MEDIUM（87.6% 精确 0、只 11.7% 会变、误差恰好 1 ulp）⇒ **正好骑在 0.25 ms/帧 的门槛上**；
- **校验当场抓出三件事**：**(a) census 的 `closure` 编号 ≠ 日志的 `cmd` 编号**（census closure 10 = unary，日志 cmd 10 = window_block）⇒ 第一版按索引 zip 是错的，改成**按族按序 zip**（每族 census 行数与每帧命令数逐一核对，合计 691 ✓）；**(b)** 自己 `MB/ms` 多乘 1000 的单位滑（已修）；**(c) 一条不可能的读数 = 真发现**：`xmx_rec_quant_window` 245.6 MB/帧 ÷ 0.10 ms = **2,456 GB/s ⇒ 不可能** ⇒ 它的 0.10 ms 是 **fused 路里的 pack 桩**（与 C7 腿级表 `quant(FUSED-pack) 0.333` / `quant_window(FUSED-pack) 0.103` 同源）⇒ **该族流量属 fused recorder，不许按这个 leg ms 定价**，已剔除并写进 note；
- **过校验才填 ms 的族**：`xmx_rec_quant` **1,270.2 MB/帧 ÷ 3.74 ms = 339.6 GB/s ✓ 落在 305-560 带内**、`unary` 70.9、`gemm_int8_batched` 29.6、`qkv` 14.5、`gemm_int8` 12.8、`gemm` 5.6 GB/s；
- **欠定档（UNKNOWN 格数已标、不填 ms）**：`gemm_int8_residual` 16.6 GB/s（**216 格未定价**）、`window_block` 0.4 GB/s（**52 格**；`mk_wb` 用了 census 的 `M=8160=tr_n`，而 WB 真正读的是 `windows × 64 × 32` ⇒ **欠约 16×**）、`window_attention` 33.5 GB/s（52 格）。

## 149. ★★★★ **Q1 取证判死：全帧唯一带宽受限族（`quant`）读的那几格本来就是 f16 ⇒ 字节线整体降级为次要靶；杠杆 2（P2 的 SLM 往返）可省上限 ~7% ⇒ 判死**
- **行号级证据**：`xmx_rec_quant` 的 source 在 recorder 体内是 **`sycl::half* a = (sycl::half*)s->second.p;`（`libxmx_sycl.cpp:6763`）**，`xmx_rec_quant_window` 同形（**`:5092`**）；packed = `sycl::uint2*`（int8 成对，`:6764/:5093`）、scale = `float*`（`:6765/:5094`）⇒ **Q1 可切真实字节 = 0**；
- **自我更正**：上一铲把 quant 的读按 `M*K*4`（f32）推 ⇒ **执行流量错报**；修正后 **`xmx_rec_quant` = 读 566.8 + 写 289.9 = 856.7 MB/帧腿 ÷ 3.74 ms = 229.1 GB/s（仍全帧最高）**；`quant_window` = 148.0 MB ÷ 0.10 ms = **1,480 GB/s ⇒ 仍是 fused pack 桩指纹**（剔除）；**TOTAL executed = 3,059 MB/帧腿**（上一铲的 3,570 作废）；每面执行 **1313 = 616.4**、**1309 = 547.7**；
- **一句话**：**字节线上只剩 1309 的 f32 C 边（E1，已因当事人全在 6-24 GB/s 延迟受限而判死）与 E2（0.22-0.35 ms，不过线）⇒ 字节线降级**；
- **杠杆 2 数清了**（P2 段 `:118-202`，simd=1、16 道子组、每线程 own 一行）：`:122-123` 每 part 1 读 128 B；`:146` 1 写 64 B（V temp）；`:153-156` 组装（仅 lane<4）16 读 × 16 B = 256 B；`:160` 1 写 256 B（宽存）；`:184` 1 写 64 B（K temp）；`:191-192` 组装 8 读 × 32 B = 256 B；`:197` 1 写 256 B；`:172-175` part0 2 × `sh16` 写 32 B ⇒ **"改成寄存器内 shuffle" 只能省 temp 写 + 组装读**（**最终的 256 B 宽存必须保留：S_VPO/S_KTO 是给下一相位跨子组读的**）⇒ 每 part ≈ 128 B/线程摊，对 P2 全部 SLM 字节（≈1,856 B/线程摊）**≈ 7% < 15% 门槛**；代价是 simd=1 下每搬 8 个值要 16 条 `select/permute` ⇒ **指令质量换字节 = §62/§63 判死过的方向**；**且这条往返本身就是 blade-7（`:134-145` 注释），已收割后的余额只有 ~7%，不能拿旧账算**；
- **杠杆 3（P0 gather `:44-64`）设计已备好、未跑**：`s6\c9_p0.cpp` 两臂同字节同 dpas——**MODE0 现形**（每线程 1 个 32 通道窗口行：`block_load<half,32>` + select 链 + `e4m3_vec` + `sh16` 窄存）、**MODE1 加宽**（每线程 2 行：`simd<half,64>` 一次载入 + 两条 `sh16` 存 ⇒ 载入条数减半、select 链不变）；骨架 2,040 WG × LW 64、`slm_init<45056>`、每臂 3 进程、每进程新建空缓存；驱动照 `s6\pe_c9_ab.ps1`（`/DPHASE=0 /DMODE=0|1`）；**≥25% 才进建件候选**。

## 150. ★★★★ **杠杆 3（P0 gather 加宽）定档判死 ⇒ `window_block` 四个杠杆全部结账，刀级余额见底**
- **定档（五臂 × 3 进程、每进程新建空缓存、串行、每进程前查游戏进程；GPU ≈ 0.08 秒）**：
 `M0 现形` 中位 **0.1641 ms/launch** → `M1 加宽（每线程 2 行）` **0.1606 ⇒ −2.1%**；
 **`M2 上界`（把 gather 的载入+算术整个删掉、只留存零）= 0.1434 ⇒ −12.4%** ⇒ **杠杆的上界本身就远不过 25% 门槛**；
 诊断臂（纯 gather）：M0 0.0970 vs M1 0.0973 ⇒ **+0.07% = 零**；同臂进程间散布 ≈2.5% ⇒ **−2.4% 在噪声边缘**；
 **守恒**：两臂每 WG 都是 64 像素 × 32 通道 = 2,048 half 读（4,096 B）+ 2,048 half 写进 `S_AQO` + **128 个 `sh16` 存槽不变**，只有 `block_load` 调用数 64→32；五臂 `.ze_info` 全同（`grf=128 / simd=1 / slm=45056 / bar=1 / 无 scratch`）；**`pad_top=pad_left=2` 证明 P0 边界分支是活的**（军规 175）。
- **★ 机理（比读数值钱）**：M1 的 `if (lid<32)` 成真分支（`(~f0.0.any32h) goto L2048 … join L2048`）⇒ gather 的 `send.ugm` 执行槽确实 4→2；**但 ocloc 显示 M0 的 32-half 本来就是一条 send**（`load.ugm.d64x8t.a64` = 64 B/lane/条），加宽后 `d64x16t` = 128 B/lane **还是 1 条**（出货 P1 权重载入甚至 `d64x32t` = 256 B/lane/条）⇒ **"每线程载入条数减半"这个先验在 simd=1 的 ESIMD 下不成立**；加宽的代价是 **+46 条静态指令 + 2 条 `send.slm`**（248→294 / 27→29，`dpas.8x8` 6 不变）。
- **诚实的一条**：§86.3 说探针"已写好"其实 `s6\c9_p0.cpp` **不存在** ⇒ 本轮现写（**前一条铲把没做的东西说成已做，被下一条铲当场纠正**）。
### WB 结账总表
**杠杆 1 barrier 合并（§84.2：五处每处都是文档化竞态修复，实测总价 2-5%）／杠杆 2 P2 的 SLM 往返（§86.2：可省 ~7% < 15%，且那条往返本身就是 blade-7）／杠杆 3 P0 gather 加宽（本节：上界 −12.4%）／杠杆 4 拆相位 S1（+50.2 MB/闭包 vs WB 只执行 10.18 MB/闭包）**
⇒ **已收割的只有车道复制（C5 −1.793 + C7 −0.766 = −2.56 ms/帧，全部逐位不变、全部 16/16）⇒ WB 摘出队首**。
### 剩下未定价的（下一铲要挑就得先定价）
`ffn` 4.72 ms/进程、`global_attention` 3.42、`ffn_merge` 1.50、`ffn_stem` 1.91 —— **全部没有绝对毫秒定档（军规 175/176：段 < 5 ms 不能用线上 STOP 阶梯，得用骨架探针）**；旧的 C1（K-tile 按列切）与 C4（P3→P4 寄存器融合）分别因"破坏 P4 行求和顺序"与"4,096 B = 吃满 grf 128 ⇒ 溢出 scratch"判死。

## 151. ★★★★★ **停顿画像做完了：C11（源码级预取）在代码层面不存在；真正的"等数据"大户是 `gemm_int8_qkv` / `gemm_qkv_window`（MLP 1.2-1.6、first-wait p50 = 1-2），不是 WB**
### ★ 先更正我上一节（§150）里的两条错账
1. **语义反了**：**`.src` = 等 send 的源/地址侧（指针复用）**、**`.dst` = 等 send 的目标/数据侧（真 RAW 取数）**——用寄存器段机械配对证出来（`send` 行 `rd:N` ⇒ 目标段 `[dst, dst+rd)`、地址寄存器 = 第二个操作数）：
 `launch_v4full` 交叉表：**`.src` 232 条里 72 条精确命中 send 的地址寄存器、只有 6 条读目标段；`.dst` 83 条里 34 条才是读目标段（真取数）、0 条碰地址寄存器**；
2. **"p50 = 3、MLP = 5.34、一半以上内存结果 3 条内被用掉"作废**（旧 `tools/stall_census.py` 三处错：**把两类并成一条距离、首次命中就 pop、把 `dpas {$k}` 当新 send、还忽略 `sync.allwr`**）；
 **修好后的真数（`tools/stall_census4.py`）**：**`.dst`（真数据）min 1 / p50 12 / p90 32 / ≤5 占 29.5% / MLP 3.21**；**`.src`（指针复用）min 1 / p50 6 / p90 30 / ≤5 占 49.4% / MLP 3.38**。
### C11 判死（理由比 25% 门槛更硬）
**三臂（MODE0 原形 / MODE1 预取一轮 / MODE2 十六载入全提到最前）发出的 GEN 逐字节相同**（6/6 个 `.text` MD5 `7B4AFF24EA525CCD550BBE2A9D7CBFA6`）⇒ **编译器在隔离形状下已经把 16 条 SLM 载入全部提前**（该臂 `.dst` p50 17、≤5 **0 处**、MLP **7.72**）⇒ **源码级预取是 no-op**；墙钟 MODE0 0.0561 / MODE1 0.0565 / MODE2 0.0579（差异在噪声内，每臂首进程是冷启动离群）。
**并且：同一段 P2 构造单独编译 = p50 17 / MLP 7.7 / 零条 ≤5；放进 2,737 行的 `launch_v4full` = 13 条 `.dst` 硬撞 + 7 条 `.src`**
⇒ **短距离不是源码顺序问题，是整核活跃状态把分配器压死的问题 ⇒ 要拉大 issue→use 距离只能减少同时在飞的活跃值（拆核/拆相位/缩 live range），不是把 load 往上挪**。
**刀 B（指针复用）也判死**：`launch_v4full` 的 **50 条 ADDR-RECYCLE 里 45 条 first-wait ≤2（90%）**——形状上最"值得做"，**但它要买的就是一个额外地址 GRF，而 `grf=128` 已顶格** ⇒ 按"要更多寄存器就直接判死、不许挤别的"这条规则 ⇒ 死。
### ★ 全帧画像（271 实例；`tools/stall_hotspots_d_ctlf.csv` / `..._d_k12f.csv` / `tools/stall_sites.csv` 12,634 条记分板记录）
- **帧级 first-wait ≤5 = 48.8%（3,218 / 6,599 loads）**；**改前 44.8%** ⇒ **C5/C7 没有把依赖变短，反而略变长**；**WB 族逐实例 p50/p90/MLP 两 dump 完全相同、`launch_v4full` 的 `.asm` MD5 两边一致（`2F308165…`）** ⇒ **去复制省的是"重复的等待"，不是"等待本身"**；
- **帧级停顿构成**：**RAW 5,850 / ADDR-RECYCLE 1,462 / WAW 826 / other 2,055**；
- **Top5（loads × share≤5）**：**`ffnc::launch_ffn_chip` ×2（656 loads、fp50 8、40.2%、MLP 3.05）**、**`gemm_int8_qkv#1`（282、fp50 2、81.7%、MLP 1.23）**、**`gemm_int8_qkv#0`（217、fp50 2、96.0%、MLP 1.59）**、**`gemm_qkv_window#0`（137、fp50 1、93.4%、MLP 1.59）**、**`launch_full`（199、fp50 4、54.4%、MLP 6.31）**
⇒ **帧里"等数据"最纯的地方是 qkv gemm 那几只（MLP 1.0-1.6 ⇒ 几乎零重叠），不在 WB**；这与执行流量口径对上了：**`qkv` 每帧 182.3 MB ÷ 12.7 ms = 14.5 GB/s = 可达带宽的 5%** ⇒ **它既不是带宽受限也不是指令受限，是 MLP 受限**。
- **按宽度归到源码（`launch_v4full` 267 条记录 = RAW 109 / RECYCLE 50 / WAW 16 / store-payload 133）**：`load.slm.d64x32t.a32`（`slm_block_load<half,128>`）→ **`:246-250`（P3 dpas 操作数）RAW 39 / RECY 10**；`load.ugm.d64x32t.a64`（全局 `block_load<half,128>`）→ **P0/P1，RAW 24 / RECY 20**；`load.slm.d64x2t.a32` → **`:153/:155`（P2 跨道组装）RAW 13 / RECY 7**；`load.slm.d64x4t.a32` → **`:191`（P2 K 侧）RAW 12 / RECY 10**。
**（靶号更正：我之前给的 `:226-233` 现在落在注释块里——C5 重写 P3 之后，P3 的 A/K 载入在 `:246-250`。）**

## 152. ★★★★ **C12 在第 1 步判死：qkv 那三只"高停顿"核根本没有 `dpas`；真正的墙是 `grf_count = 128` 顶格导致的分配器串行化**
- **父级点名的靶不成立**：`xmx_rec_gemm_int8_qkv#x`（14,674 行）、`#1`（25,176 行）、`xmx_rec_gemm_qkv_window#x`（12,477 行）**一条 XMX 都没有**，而且是 **SIMD8/16/32 核**（`.ze_info` 的 `simd_size`），不是 ESIMD `simd=1` ⇒ **"每线程 tile 对半 / dpas 守恒 / 累加器减半"没有作用对象**（守恒等式两边都是 0）；
- **真 qkv GEMM 只有 `s8v5::gemm_qkv_v`（765 行，dpas=4）与 `qres::gemm_qkv_res`（726 行，dpas=4）**，**它们 MLP 已经 5.00 / 5.86、`.dst` p50 = 7 / 23、≤5 只占 38.9% / 22.7%** ⇒ **本来就不等数据，没有刀**；
- **那三只 MLP 1.14-1.90 的核撞的是军规 182 的同一堵墙**：它们是 **int8/int32 反量化 + 标量乘加链**（194 条 `load.ugm.d32.a32.ca.ca.bss`、64 条 `store.ugm.d32.a64.wb.wb`、24 条 `store.ugm.d16u32.a32.wb.wb`）；
 **冒烟枪**：`gemm_int8_qkv#x` 的 214 条 load 里 **161 条（75%）的目标 GRF 就是它的地址 GRF**（`send.ugm (16|M0) r78 r78 … {ExBSO,A@5,$10}` → 下一条 `mov r86 ← r78 {$10.dst}` 距离 1 → 再 `shl r78 ← r84` 把 r78 当地址重写 → 又一条 `r78 r78`）⇒ **分配器把地址与返回值塞进同一段寄存器 ⇒ 下一条载入的地址计算必须等上一条记分板 ⇒ MLP 钉死 1.19**；
 **消它要么"地址/目标各留一段 GRF"要么"拆 `accN` 串行链成多累加器"——两个都要更多寄存器，而这三只 `grf_count` 全是 128 顶格 ⇒ 判死**；
- **仪器再补一刀（子代理做的，该他上一铲就做）**：新增 **`tools/stall_census5.py` = 基本块感知**（只在同一 BB 内算 send→wait；块 = label 起、`goto|br|join|end-of-thread` 止；跨块等待丢弃并单独计数）——**理由：`gemm_int8_qkv#x` 是 14,674 行 / 3,497 label / 1,937 goto / 1,245 join 的完全展开派发体，线性文本距离不该直接当延迟用**；**复核结论不翻**（跨块丢弃仅 2/14/5 条，对 217/282/137 条等待；**p50 1-2、≤5 占 91-96%、MLP 1.14-1.90 全部存活**）；
- **排名变了**（`tools/stall_hotspots_bb_aware.csv`；**帧级 same-BB short≤5 = 57.9%**，丢弃 847 条）：**新 #1 = `ffnc::launch_ffn_chip`（8,834 行 / 580 块 / 656 loads / dpas=32 / p50 5 / ≤5 占 53.1% / MLP 2.50）—— 帧里最重且真有 dpas 的一只**；#2-#5 = `gemm_int8_qkv#1`、`gemm_int8_qkv#x`、`gemm_qkv_window#x`、`window_block#3`（132 loads、p50 2、97.1%、MLP 1.62、dpas=0）；
- **另一处自我更正**：旧 `tools/stall_sites.csv` **把复用同一记分板号的多次 send 折叠成一条记录**（`launch_v4full` 只有 16 条）⇒ **已修成 reuse-aware：267 条**；帧级 12,634 条 = **RAW 5,850 / ADDR-RECYCLE 1,462 / WAW 826 / other 2,055**；`launch_v4full` = **RAW 109 / RECYCLE 50（其中 45 条 first-wait ≤2 = 90%）/ WAW 16 / store-payload 133**；**旧版分栏数（RAW 805 / RECYCLE 749）作废**。
**本轮 GPU = 0**（按 C11 立的规矩：刀没有对象，跑墙钟只会得到另一个 no-op）；引擎一行未改；HEAD `7819451`、dirty=0；两槽 `8658C786…` 与三金标未动。

## 154. ★★★★ **查"融合核/减闭包数这条线为什么没做完"的结论（用户令：只查，不动手）**
**这条线没有一次是被"叫停"的，它是三段不同结局，而且第三段至今挂着价格标签没去拿：**
1. **整块驻留（691 → ~120 只闭包）= 被硬件容量证伪**（§29）：**A770 SLM 64 KB 帽**；卡点是残差面 **`1267`（8,192 B@C64 / 16,384 B@C128）横跨 P6→P11 ⇒ 不可别名、不可落 global = 整块融合的固定税**；**当年吹过的"S6-1b = 帧 −10~−11 ms"明确作废**；
2. **但前提后来被更正**（§30）：读了 lmxx 真码才看清——**他们从来不做"整块一 WG 常驻"**，**他们的粒度是"一相一核 + 布局原生的 global 面"** ⇒ **§29 撞的那堵帽他们根本没去撞**；**所以"整块融合死亡"不等于"融合线死亡"**；
3. **半块融合（S6-1b′）= 正向并且已经出货**：§36 **attention 侧 5 发 → 1 相，C=64 档 −19.9%、逐位 EXACT（12 检查点 diff=0）**，原型 `src/bench/sycl/s6b_att.cpp` 后来**逐字抽成 `src/bench/sycl/att5_fused_kernel.hpp`（42,540 B）进 shipped 路**（今天的普查里 `att5::fused` 是 **LIVE-DEFAULT**，编译期 `T_ATT5_FUSE_DEF=1`）⇒ **融合线在这一段是"做完了并上线"的**；
4. **★ 至今没去拿的那一段（被押后、有价签）**：`notes/*` 2026-11-05 明确写着——**"最好抄 + 结构最像 A5 = `gemm_int8_qkv` + `global_attention` 的 C512 att 段：8 条 C512 链各有一段 4 腿连续未融合（closure 317..319、325..328、334..337、343..346、352..355、361..364、370..373、379..382），串行 17.36 ms ⇒ 上限 5.78-7.29 ms 串行 ⇒ 帧口径 ~2.5-3.1 ms（×0.43），先例 = `att5_fused_kernel.hpp`/`s6b_att.cpp`（12 检查点 diff=0、C64 −19.9%/链）"**；**押后的理由当时是"要先有 bench 组合能赢拆腿 REF"**；
5. **另一段失败是被帧夹逼判死的（不是没测）**：**刀 C′（wide-merge → BN32 融合，20 发 N=32 站点）48 对实测 mean −0.466 ms、B 快 31/48(65%)、95% CI [−0.893,−0.039] ⇒ 未过 −0.5 线**；**处置 = 默认 OFF、机制+开关留作 S6 砖**；**同批还立了"bench 串行 −1.05 vs 帧 −0.466 ⇒ 存活率 44% ≈ 家族平均 43%"这条换算率**（军规 131 的来源之一）。
### 与今天新标尺的接合（这才是要点）
**今天量到 0.044 ms/闭包（(B) 五档与 (A) 按链两条独立互标 0.044 / 0.0418）** ⇒ **C512 att 段那条融合 = 8 链 × 4 腿 → 1 相 ⇒ 每链少 3 只闭包 ⇒ 24 只闭包 × 0.044 = 1.06 ms/帧 是"闭包数"这一项的白送钱**，**再叠上 5.78-7.29 ms 串行的腿内节省（按 ×0.43 存活 ⇒ 2.5-3.1 ms）**；**两者口径不同不能直接相加，但这意味着这笔账应当重开一次**。
**明天第二层的活照旧；若要开融合线，第一个靶就是这段 C512 att 腿（已有 `att5_fused_kernel.hpp` 先例、已有 closure 编号、已有价签），不是重新发明。**

## 155. ★ **明日开工顺序（用户 2026-11-08 18:1x 令，写死，不许改序）**
**原则重申**：**一层一层过，绝对不许东一下西一下；先把手上的半工程关掉，再开新靶。**
### 第 0 步（开工先做，零 GPU，30 分钟内清完）：**关半工程**
1. **12 条因 `imfnat3` 变红的数值门重定基线**（带 provenance：件 md5 `66FEC931`/`8658C786`、日期、原因）：`gate_unary, gate_chain_s1, gate_cosine, gate_qkv_qk, gate_cosine_i8, gate_chain_qkv, gate_quant_window, gate_unary_kinds, gate_gemm_f16_qkv_window, gate_window_block, gate_vit_softmax, gate_global_attention`；**三条 `bk.1301*` 金标永远不动**；
2. **`notes/layer2-gains.md` 补 C7 行**（倍数 4.3-6.9× → 3.9-6.2×，腿级 16.179→15.367）；
3. **`tools/knife_ranking.csv` 里 `est = -1` 的行逐条标"已判死/待定价"**，**不许留空账**。
### 第 1 步（主任务）：**解决"大刀收益小"——找到并拆掉掩盖它的那个东西**
**已排除（都有读数，不许重走）**：容量竞争（(B) 四档 Δ 平在 ±0.25）、核内短等待（C13 四形：`≤5` 处数砍半墙钟 +0.6%、隔离编译 MLP 3.2→7.7 反而 +3.2%）、字节/带宽（执行流量 5-34 GB/s = 可达带宽 2-10%）、死分支（军规 175）、指令量本身（军规 161+更正）。
**剩下的两个候选，按此顺序量**：
- **(1a) 每闭包 0.044 ms 的构成**（**这是唯一还没拆过的数**）：**用不扰动调度的取法**——**不在 `parallel_for` 外加语句（军规 132）**，只在 `lc_begin(-1)` 既有钩子里读 host 时间戳 + `pf=` 计数；**产出：派发/启动 vs 执行 各占多少**；**注意 `NR_SUBMIT_PROBE=1` 会把帧打回 118.9 ms 串行 ⇒ 该读数只用于分配比例，不用于帧价**；
- **(1b) 图的假依赖**：**用已有 `WRITE_SLOT` 映射（每只闭包哪个 ids 槽是写，`s6\c74_planemap.py`）+ `chain_map.csv` + 每闭包实测成本建 DAG**；**产出 `tools/graph_dag_analysis.csv`**：关键路径长度与占帧比例、**边的分类（真数据依赖 / 仅因共用池 slab 而存在的 WAR-WAW 假依赖）**、**消掉假依赖后关键路径能缩几 ms**（**改法 = 让并发闭包各用各的 buffer，运行时零成本**）；
**验收（这就是"解决"的定义）**：**每修一处结构，就把 `AF5A19B3` vs `66FEC931` 那对重跑 4 对；Δ 从 −0.049 向 −1.4 走多少，就是那次改动把多少被掩盖的收益放了出来**；**Δ 不动 = 那个候选不是盖子，换下一个**；**两个候选都排除 ⇒ 我带着完整读数回来向你汇报，不再自己找方向**。
### 第 2 步（第 1 步结题后才许开）：**第二层的融合（减闭包数）**
**第一个靶已定、有先例、有价签**：**C512 att 段 8 条链 × 4 腿连续未融合**（closure `317..319, 325..328, 334..337, 343..346, 352..355, 361..364, 370..373, 379..382`），**串行 17.36 ms ⇒ 上限 5.78-7.29 ms ⇒ 帧 ~2.5-3.1 ms（×0.43）**；**先例 = 已出货的 `att5_fused_kernel.hpp`（C=64 档 −19.9%、逐位 EXACT）**；**再叠 24 只闭包 × 0.044 = 1.06 ms/帧 的闭包数钱**；
**不许再开旁支**：`wide-merge/BN32`（48 对判死）、`fat-M`（§94 三站 ratio<1）、`block-diag`（4× 冗余读）、`qfuse_take_b`（上限中性）——**这些都已结案，翻案要有新读数**。
### 现场（今天收工状态）
两槽 = **`8658C786…`（C7）**；**今天净收益 −2.56 ms/帧（C5 −1.793 + C7 −0.766，非 fused 口径、16/16、逐位不变）**；回退链 `shfc5(2F3ACF6C) → imfnat3(66FEC931) → shfimf1(AF5A19B3)`；三金标与四面基线未动；**无 running 子代理、无 GPU 作业、工作树 CLEAN**。

## 156. ★★★★★ **1a 结题：帧不是"每闭包 0.044 ms 固定成本"，而是"分段并发度"——尾部 141 只闭包几乎串行（边际 0.71），中段 150 只几乎全被盖住（边际 0.12）**
**新仪器（零改码、只加 env）**：**`NR_CGRAPH_LIMIT`**（`libxmx_sycl.cpp:2516`，只录前 `lim` 只闭包进 command graph）⇒ **节点数阶梯**；**出货路默认 `NR_CGRAPH=1`（`:2502`，一帧 = 一次 graph submit）⇒ 主机派发不是盖子**（`NR_SUBMIT_PROBE` 那条路是**绕过 cgraph 的旁路**，它把帧打到 118.9 ms，所以它的 enqueue 只能用来分配比例，不能当帧价）。
**阶梯读数**（`s6\A1_node_ladder.csv`，件 = 两槽那颗 `8658C786`，每档 2 进程、**每进程新建空缓存**、串行、腿间 62 s；`med` = run1-3 中位）：
| lim | 帧 ms | 该段 leg-sum（串行腿级，`rt_c7leg_B_1.txt` 693 闭包） | **段边际 = Δ帧/Δ腿** |
|---|---|---|---|
| 100 | **14.70** | 23.67 | （含固定项）|
| 200 | 18.99 | 38.26 | **0.294** |
| 400 | 24.50 | 70.50 | **0.171** |
| 550 | 27.06 | 92.55 | **0.116** |
| 691 | 43.93 | 116.29 | **0.710** |
**⇒ 固定项 ≈ 7-8 ms；帧的 ~36 ms 是执行，而执行的重叠度按段差 6 倍**：
- **闭包 400-550：边际 0.116 ⇒ 这 150 只几乎完全被并发盖住**（省它们的时间，帧不动）；
- **闭包 200-400：0.171；100-200：0.294**；
- **★ 闭包 550-691（最后 141 只）：边际 0.710 ⇒ 基本串行 = 帧的真正关键路径**；
**每段里的头几族**：`0-100` = WB 7.59 / res8 4.12 / ffn 2.65 / winres 2.45 / wa 2.09；`200-400` = res8 7.81 / qkv 4.17 / gemm_int8 3.92 / GA 3.55 / gemm 3.29；`400-550` = gemm 3.60 / wa 3.48 / winres 3.11 / batched 3.08 / qkv 2.95；**`550-691` = res8 5.37 / winres 3.87 / WB 3.42 / wa 2.85 / ffn 2.03（合计 17.5 ms 串行，边际 0.71 ⇒ ≈ 12.4 ms 直接落在帧上）**。
### 这把"大刀为什么没收益"彻底解释清楚（不再是名词）
**`imfnat3` 砍的站点（`post`/`cosine`/`qkv`/`quant`）落在边际 0.12-0.29 的中段 ⇒ 省的时间被并发盖住；C5/C7 砍的 `window_block` 有 7.59 ms 在头部、3.42 ms 在尾部（0.71 边际）⇒ 1:1 兑现。**
**⇒ 军规 184 的"0.044 ms/闭包"降级为平均值，真正的定价量 = 该闭包所在段的边际（0.12 / 0.17 / 0.29 / 0.71）。**
### 由此得到两条新刀（明早汇报，先按 1b 的 DAG 判定哪条合法）
- **K1（结构）**：**把尾部那 141 只的工作提前与中段重叠**（改 plan/graph 的闭包次序，把 tier-major 的尾巴打散）⇒ **理论上限 = 尾部 17.5 ms 里最多可藏掉 ~10 ms**；**合法性取决于"这些闭包之间是否真有数据依赖"——正是 1b 要答的**；
- **K2（刀序）**：**今后任何指令/结构刀先问"靶在哪个段"**：**尾部 0.71 ⇒ 值得做；400-550 段 0.12 ⇒ 白做**（这条直接改写排刀表：`knife_ranking` 的 est 一律乘上该族所在段的边际）。

## 157. ★★★★★ **1b（K1）结案：尾部串行是**真依赖**（残差流），假依赖这条路判死；但同一铲挖出真正的盖子 = **每只图节点的固定成本 ≈ 0.02-0.05 ms，而帧里有 133 只几乎不干活的小节点**
### ① K1 判死（有账）
**尾部 141 只活闭包：`141/141` 的 `last_RAW_pred = i-1` 且 `last_any_pred = i-1`** ⇒ **一只都动不了**，**即使把全部池 slab 版本化也动不了**；机理 = **每链以 `gemm_int8_residual` 写 1303（66,846,720 B f32 C slab）收尾、下一链以 `quant_window` 读 1303 起手 = 残差流本身**。
**假边总账**：去重边 1,995 = **RAW 673 / WAR 738 / WAW 584 ⇒ 假边 1,322 条（1,180 挂在 gen=2 的池回收 slab 上，分布在 22 张面）**；**但 522 对相邻活闭包里 516 对的共用面含真 RAW，只有 6 对是纯假**。
**最长路径**：全边 43.49 ms → 只留 RAW 43.20 ms ⇒ **拆光假边最多 0.29 ms**；**K=2/4/8 流 list-schedule 差值全是 0.29**；**复现引擎自陈（`:1294-1296`）：as-recorded 贪心波 = waves=523 / maxwidth=1**；版本化 `{1305,1306}` K=4 ⇒ waves 320 / maxwidth 4；全部 10 张 gen=2 面 K=4 ⇒ waves 217 / maxwidth 6 —— **并发度涨 3 倍而关键路径不动**。
**代价**：只版本化 `{1305,1306}` = **+27.85 MB**；版本化全部 22 张带假边的面（K=min(users,4)）= **+521.6 MiB** ⇒ **521.6 MiB 换 0.29 ms ⇒ 判死，不许花钱**；**且出货 `NR_PGRAPH` 默认 0（`:2501/:2559`）⇒ 帧走 cgraph 一次 submit，没有调度器按 DAG 重排 ⇒ 今天可兑换 = 0 ms**。
**排序规则也钉死了**：闭包顺序 = plan 步骤顺序（`src/gpu/nr_replay.c:39 nr_plan_steps[]`、dispatch `:469-534`；`walk_plan.py:95` 走 5,254 步），**引擎只照抄**（`pg_push :208-232` 按调用序追加、replay `:2518-2521` 同序、`:2542` 一次 submit、in_order 队列 `:1272`、cgraph 默认 ON `:2502`）；**引擎里唯一改序列的东西 = `skip_chain_set() :1605-1621`，只置空体、从不换序**。
### ② ★ 真正的盖子（1a + 1b 合起来的答案）
**每只图节点 ≈ 0.02-0.05 ms 帧成本，与它干不干活无关**：
- **`quant(FUSED-pack)` 102 只闭包 leg 合计只有 0.23 ms、`quant_window(FUSED-pack)` 31 只只有 0.07 ms** ⇒ **这 133 只节点执行上近乎空转，却各占一个图节点**；**按 0.03-0.05 ms/节点 ⇒ ≈ 4-6 ms/帧 的白捡钱**；
- **`imfnat3` 砍的站点在边际 0.12-0.29 的中段 ⇒ 省的是节点内的执行，节点一个没少 ⇒ 帧不动**；**C5/C7 砍的是 4.30 ms / 1.53 ms 的大节点 ⇒ 1:1 兑现**；
**⇒ 第二层的正确刀序 = 先减节点数（融合/删除小节点），再砍大节点内部执行。**
### ③ 仪器更正（影响以后所有铲子）
**(a) `ids=` 是 touch 集不是纯位置参数表**：`pg_note_ids :181-191` 会丢掉解析不到活 buffer 的操作数、`pgraph_extra :202-207` 追加带外格 ⇒ 观测到 `window_block` 7/8、`gemm_int8_residual` 8/12 两种 ragged；**前 NOPS 格仍是操作数位置、追加格全是读**（`:4740`、`:4750-4751`）；取证脚本 `s6\d5_slots.py`。
**(b) `pf=0` 不能当"闭包不干活"**：`LC_TICK()` 只在 kernel helper 入口计数（.hpp 里 90+ 处），**.cpp 内 69 处 `parallel_for` 不计数**（`xmx_rec_unary` 16 只 pf=0 但 leg 2.76 ms）⇒ **真空转只能按 lbl + 源码替换点 + leg≈0 三条同时成立来判**。
### ④ 新表（已进仓）
`tools/graph_dag.csv`（384,866 B / 2,165 行 × 20 列）、`tools/graph_dag_analysis.csv`、`tools/tail_dependency_analysis.csv`（19,778 B / 142 行 × 16 列）；脚本 `s6\d1-d9_*.py`；状态 `s6/layer1.md §96`。

## 158. ★★ **口径修正与一条新仪器事实（明天补交，先落盘防压缩）**
### ① 我 §156 的段边际混了口径（自我更正）
**`NR_CGRAPH_LIMIT` 阶梯跑的是非 fused（691 passes）**，而 **leg-sum 取自 `rt_c7leg_B_1.txt`（fused 693 passes，里面有 `quant(FUSED-pack)` 这类 fused 专属格）** ⇒ **Δ帧/Δ腿 的分母不同路** ⇒ **§156 那张表的"段边际"只能当形状看，不能当绝对价**；
**更正做法（已跑一半）**：同一口径两侧都取 —— 新腿 `s6\A3_fused_ladder.csv`（fused + `NR_CGRAPH_LIMIT`）。
### ② ★ 新仪器事实：**fused 路每个进程只打印一次计时（`run 0`），没有 run1-3**
`s6\A3_leg_550.log` 原文：`walk run #0: 204.0 ms` → `[cgraph] recorded graph id=0 (693 closures)` → **`run 0: 53.24 ms (693 passes)`** → 然后就是 dump，**再没有 run 1/2/3**；
⇒ **fused 口径的认证必须用"更多进程、每进程一个值"，不是"每进程 4 次 run 丢 run0"**；
**驱动已按此改**：`s6\pe_fused_pairs.ps1`（`NR_FUSED_SYNTH=1`、每腿新建空缓存、腿间 62 s、每批前查 `LOP-Win64-Shipping.exe`、A/B 交替、**含 A/A 对照腿**；每腿取 `run 0`，若将来出现 ≥4 次 run 则自动丢 run0 取中位）。
### ③ fused 阶梯（**单进程、只有 run0 ⇒ 绝对值不可信，只当形状**）
`lim` 100/200/400/550/693 ⇒ `run 0` = **21.27 / 24.07 / 36.03 / 53.24 / 78.06 ms** ⇒ 段边际 0.028 / 0.060 / 0.115 / 0.174 ms/节点；
**⚠ 但 `lim=693`（设了 limit）跑出 78.06，而不设 limit 的 fused 稳态是 63.56（(C) 三进程 62.90/63.56/63.56）⇒ 设 `NR_CGRAPH_LIMIT` 本身会改变行为（怀疑绕过了某段 warm）⇒ 这条仪器要用"设 limit 的 A/A"先自校，否则不许用来定价**；
⇒ **C15（剪 133 只空转节点）的价格只认"设 limit 与否都不用的前后对照**：**A = `builds\libxmx_shfc7.dll`、B = 剪过的变体，各 4 进程 fused**（`s6\pe_fused_pairs.ps1`）。
### ④ 待办（明天开工顺序不变）
第 0 步剩余项：`knife_ranking.csv` 的 est 值按段边际重标（等 §156 口径修正后再标）；**C15 若过四闸 ⇒ fused 口径 16 对 + 4 组 A/A（每进程一个值）才 staged**。

## 159. ★★★★★ **C15 判死（剪空转闭包换帧）+ 它把"图节点"这个概念纠正过来；留下一块现成砖**
### ① 我 §157 的立论被推翻，公开撤回
**"每只图节点 ≈ 0.02-0.05 ms 固定成本"没有仪器量过 ⇒ 是我的假设。** 实测：
- **那 290 只空转闭包在 captured cgraph 里根本不是节点**：替换点把 body 写成 `g_cmds[idx] = [](){}`（**`:449` `quant(FUSED-pack)`、`:467` `quant_window(FUSED-pack)`、`:502` pack-b、`:834-835` S6 六只（**不改名 ⇒ 按标签数必漏**）、`:1061-1064` A5 四只、`:4920` B6、`:5644` LFW），**空 lambda 不发任何设备 op**；
- **引擎自陈 `:677` 与 `:1603`**："passes 仍 691 … 而 captured cgraph 的 **NODE 数下降（no-op 闭包发零设备 op）**" ⇒ **节点数 = 设备 submission 数，不是闭包数**；
- **反拟合（拿我的 1a 阶梯 14.70/18.99/24.50/27.06/43.93）**：最优是 **`frame = 5.99 + 0.556 × legsum`（R² = 0.951）**，而**节点数/空闭包数的系数落在 −0.075…+0.36 的噪声带里**；8 条链的 skip 消融拟合 R² = 0.041 ⇒ **阶梯分不出"固定节点税"**。
### ② 靶数两度更正（最终）
按标签 **144 `quant(FUSED-pack)`（leg 合计 0.321 ms）+ 45 `quant_window(FUSED-pack)`（0.103）+ 21 A5-fused = 210 只**；**witness 实测 `dissolved=290`/帧**（fused 与非 fused 一样多，**不是 fused 独有**）；**非 fused 另有 `skip_noop=168`，与 290 的并集 = 322/691 = 46.6% 的闭包是空壳**。
### ③ 实测（7 腿，同件只差 env，**prune ON**）
**四面 4/4 逐字节 EXACT**：fused 1301 `254C02B7` ✓、features `CACD2029` ✓、result `AE050ED1` ✓（**passes 693 → 403**）、非 fused 1301 `DD49827D` ✓（**passes 691 → 401**）；对照 prune OFF 三面同样 EXACT ⇒ **"这些闭包不发设备 op + 压缩七条平行向量/重编号 `g_skipped_cmds` 不破坏池 in-order 指纹与依赖记账"从推断升级成实测**；
**fused 帧 A/B（每进程只有 run0）**：A(off) 67.01 / 67.21，B(on) 65.99 / 66.61；带 dump 那对 63.38 / 63.11 ⇒ **Δ = −0.63 ± 0.4 ms**，**远低于预登记的 1.5 ms 判死线** ⇒ **C15 判死**。
### ④ 留下的砖（不动 shipped）
**`NR_PRUNE_DISSOLVED=1`**（默认 OFF）：**把 290 只空壳从流里消掉（693→403 / 691→401）、四面逐字节 EXACT**；**`NR_C15_REPORT=1`**：空壳计数 witness；**`NR_BMERGE_ORDER` 排过序时它会 REFUSED 不静默剪**。
**处置**：**HEAD 不并入这个 diff（保持 HEAD = 出货件源状态，军规 169②）**；**改动以 `tools/C15_prune.diff`（+71/−1，单文件）存仓，将来做"减 submission"线时 `git apply` 一秒钟回来**；变体件 `E:\DSH\builds\libxmx_prune_c15-20261109-033252.dll`（`02949D08…` / 3,354,112 B）已入库留档。
### ⑤ 军规 186（子代理提议，我入册）
**排刀只问两件事，别问"在不在关键路径上"（RAW 最长路径覆盖 516/523 活闭包 = 98.7%，没有判别力；imfnat3 的站点全在路径上却只换 −0.049）**：
**(a) 帧价 = `leg_ms × r_seg`**（**段兑换率实测：0.566（0-100，含 7.3 ms 固定项）/ 0.296（100-200）/ 0.141（200-400）/ 0.114（400-550）/ 0.500（550-691）**；**按此全表求和 = 42.2 ms ≈ 实测 43.93 ms**；**表已做成 `tools/path_membership.csv`（691 行 × 14 列，含 `on_path / path_rank / slack_ms / frame_price_ms_if_deleted`）**）；
**(b) 这一刀删的是"一次 submission（图节点）"还是"节点内的指令"**——**历史上只有前者兑现过（C5 −1.793 / C7 −0.766 vs `imfnat3` −0.049）**；**指令刀连段平均兑换率都没拿到（定价 ≈0.26-0.4 ms，实测 −0.049，低 5-8 倍）⇒ 那些核不是指令瓶颈**。
### ⑥ 下一铲（已下令）
**C16 = C512 att 段融合：8 条链 × 4 腿连续未融合（closure `317..319, 325..328, 334..337, 343..346, 352..355, 361..364, 370..373, 379..382`，共 24 只闭包）**，**串行 17.36 ms ⇒ 帧 2.5-3.1 ms（§154.4 的现成价签）**；**这 24 只全在最长路径上，而且这一刀是"减 submission"不是"减指令"**；**先例 = 已出货的 `att5_fused_kernel.hpp`（C=64 档 −19.9%、逐位 EXACT）**。
