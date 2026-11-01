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
