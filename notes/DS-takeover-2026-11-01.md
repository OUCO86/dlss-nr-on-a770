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
预期 −3~5ms（腿账 5.8 的一部分），判官 = bench 单价 → 三关（1250 门 + walk 1301 EXACT + passes）→ 16 对。
刀 A 的 nt64_bk64 形态作为**随行小刀**（同一批站点，−0.4~0.6ms），两刀合测一次三关，省一次协议成本。

