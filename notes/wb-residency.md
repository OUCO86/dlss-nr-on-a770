# WB 驻留刀 (wb_slm) — 45,056B → ≤32,768B

任务：`window_block` 两核（`wbv4::launch_v4full` / `wbv4::launch_v4ph`）SLM 从 45,056B 压到 ≤32,768B（超占用崖 ⇒ 驻留 1 → 2）。
分支 `ds-quality-relax-2026-11-02` @ `d8fc40a`（已确认 `git branch --show-current`）。GPU 起跑前无 LOP / nr_replay / s6_ / port_ / bench_ / s6b_ 进程。

## 0. 现场事实（grep 得来，未整读大文件）
- `src/bench/sycl/window_block_v4.hpp` (393 行)：`L20 constexpr uint S_AQO=0, S_QPO=4096, S_KTO=8192, S_VPO=12288, S_ATO=16384, S_PPO=20480, S_SCR=28672;` `L21 SCR_SG=4096` `L35 esimd::slm_init<45056>()`
- `src/bench/sycl/window_block_v4ph.hpp` (462 行)：同一张 map（L20/L21/L37）。
- **两文件里没有任何非-SLM 的 `local_accessor`**（grep `local_accessor|range_local` = 0 命中）⇒ SLM 只有这一片。
- 算术：4096(AQO)+4096(QPO)+4096(KTO)+4096(VPO)+4096(ATO)+8192(PPO)+16384(SCR=4SG×4KB) = **45,056** ✓ 与台账逐字节对上。
- 先例：`window_block_v3.hpp:184-196` 已经用"别名 constexpr 基址"手法（`ATO = QPO`、`DPJ = DSC`、`WGT = DCQ`，注释写生命周期）；§36 的 att 相峰值 32,768B 贴崖、`private/spill/scratch=0`。
- 军规 28 ⇒ 这两核是 `SYCL_ESIMD_KERNEL`，**只能动几何/布局，不能上 `reqd_sub_group_size`**。

## 1. 分相结构（两核共有）
P0 gather→AQO | P1+P2 两相 QKV（ph1: dpas→3 块 f32 累加面 scrA/scrB/scrC；ph2: 重载+epilogue+scatter→QPO/KTO/VPO）| group_barrier | P3 scores(dpas, A=QPO 提到寄存器, B=KTO)→SCR | P4 softmax(读 SCR 行, 写 PPO) | P5 attnV(A=PPO, B=VPO)→SCR | P6 attended→ATO, outproj(A=ATO)→SCR | P7 residual+publish(读 SCR)。
`stop_stage`/`DumpKV` 诊断腿（军规 4/9：只给诊断用，帧路径不触发）⇒ 别名后这些 dump 读的是已重用的字节 = 陈旧，**判官不用它们**。

## 1x. 第 1 步结案：复算吻合 + 别名方案（tools/wb_slm_layout.py，退出码 0）
- **复算**：regex 从两核源码读 map 基址 + `slm_init` 声明 => 区末端最大 45,056 == 声明 45,056 == 台账 ⇒ **算术模型可信**（§36 的信用规矩）。
- 现路逐块账（谁写谁读 + 生命周期）：
  | 块 | 字节 | 活(相区间) | 写 | 读 | 作用域 |
  |---|---|---|---|---|---|
  | AQO | 4,096 | P0..PH1 | P0 gather | PH1 tile8s A 侧 | 本 SG |
  | QPO | 4,096 | PH2_0..P3 | ph2 part0 | P3 hoist | 本 SG |
  | KTO | 4,096 | PH2_1..P3 | ph2 part1 | P3 dpas B 侧 | **跨 SG 读** |
  | VPO | 4,096 | PH2_2..P5 | ph2 part2 | P5 dpas B 侧 | **跨 SG 读** |
  | ATO | 4,096 | P6A..P6B | P6 头段 | P6 dpas A 侧 | 本 SG |
  | PPO | 8,192 | PH1..PH2_2 (scrC) + P4..P5 (probs) | ph1 part2 / P4 | ph2 part2 / P5 | 本 SG |
  | SCR | 16,384 | PH1..PH2_1 (scrA/B) + P3..P7 | P3/P5/P6 | P4/P6/P7 | 本 SG |
- **现路按相活跃并集峰值只有 28,672B ⇒ 闲置 16,384B 可挖**（现路只别名了一处：scrC->PPO）。
- **别名方案（省 12,288B => 32,768B）**：每 SG 一段 **7,168B** 私有槽（基址 4096+sgid*7168）+ 一片**连续 4,096B 全局区给 VPO**。
  - S0 sg+0 (2048)：accA(PH1..PH2_0) → QPO(PH2_0..P3) → PROBS(P4..P5)
  - S1 sg+2048 (2048)：accB(PH1..PH2_1) → SCORES(P3..P4) → ATT(P5..P6A) → PROJ(P6B..P7)
  - S2 sg+4096 (2048)：accC(PH1..PH2_2) → SCORES 续(P3..P4) → HEAD-A(v4ph P7 head)
  - S3 sg+6144 (1024)：AQO(P0..PH1) → KTO(PH2_1..P3) → ATO(P6A..P6B)
  - 全局 0..4095：VPO(PH2_2..P5)
  **每笔不相交理由已在脚本里逐条写死**；唯一的"同相交接"= accA→QPO（PH2_0 内先读本 SG 的 f32 行、写者的值就是这条读的派生值，数据依赖锁死顺序），脚本白名单登记。
- **为什么 32,768 是这把刀的结构地板**：PH1 同时活 accA+accB+accC = 3x2048/SG + AQO 1024/SG = **7,168B/SG**（两相 QKV 的既有形状，不许改数值链就动不了）；VPO 必须是**连续 4096B**（P5 的 `wbv3::tile8ss` 里 B 侧步长写死 = kc*(tc_n*2*256) = 1024，helper 被 v3 共用不许改）⇒ 地板 = 4x7168 + 4096 = **32,768B**，正好贴崖（§36 att 相同形：峰值 32,768 贴崖、private/spill/scratch=0）。
- **帽口径写死（上级转来的外部提醒）**：本战役用的是 **Level-Zero `local_mem_size = 65,536`**（§29 实测 65,536 含、65,600 拒）；上游 Vulkan 口径报的"A 系 48KB"是**另一个口径**。**32,768B 同时满足两个口径**，结论不依赖口径之争。
- **外部检查表对账（上游 ScratchArena 角色别名表）**：它的"`projection ← hidden16/proj/attended/attention`"与我的 S1（ATT→PROJ 同槽）、"`query/probability ← heads16,probs16`"与我的 S0（QPO→PROBS 同槽）、"`input/key ← value16,k16`"与我的 S3（KTO 别名进 AQO/ATO 死区）**同类**；红线"残差必须活到最后一次残差"对应我的 PROJ 活到 P7（proj 在 P7 才被读）✓。

## 2x. 第 2 步：别名手术已落盘（E:\DSH\s6\patch_wbslm.py，25 条规则 x 2 文件全部命中数吻合）
- 动的是**基址常量 + 每 SG 基址 `sbase`/`sgb()` + 跨 SG 读 KTO 的新步长 + 诊断 dump 的地址重映射**；
  **dpas 序列、eh_round/ef_div、publish/requant 链、栅栏、stop_stage 语义：一字未改**。
- 关键重映射（只改地址，不改值）：
  - KTO 从"全局 4096B（块 = kc2*2048 + sgid*512 + js*256）"改成"**每 SG 连续 1KB**（块 = kc2*512 + js*256）"：写侧 :190 与读侧 :224/:231/:232（`bb+2048/2304` -> `bb+512/768`）成对改，**逻辑元素不变**。
  - `*2` 在每条 SLM 地址表达式里只出现一次（军规 25）：所有 `sh16/lh16` 的地址 = `基址 + (half-index 表达式)*2u`，half-index 里不含字节换算。
  - 诊断 dump（stop_stage 10/11/12、5/6/8/9）按新布局重映射（`dump_qpo/dump_kto` 走逻辑字节序）；**帧路径 DumpKV=nullptr，这些分支 HEAD 里本来就有，没有新增运行期诊断分支**（军规 4/9）。
- 编译期钉死：5 条 `static_assert`（SLM_BYTES==32768、SCORES/PROBS/KTO/ATO/HEAD-A 必须整段落在 SG 槽内）。
- 补丁中途逮到一处脚本缺陷并修好：`sgb` 行尾漏换行把 `uint top` 吞进行注释（=> 语法错），已修；教训 = **补丁脚本必须打印每条规则的命中数**（这次 25 条全数吻合，否则不会暴露）。

## 2y. ★ 失败线触发过一次：ATO 别名进 S3 = 1301 全帧 MISMATCH（已定位、已修、已入册）
- 第一版（builds/wb_slm_a.dll, md5 75645a66…）walk：**1301 MISMATCH**（8,355,840B 里 6,560,814 字节不同；x/y 全域均匀、y mod 8 平坦）=> 不是局部地址错，是**整条链的值都变了**（上游 QKV 面被污染）。
- 根因：**S3（sg+6144，1024B）里 KTO 与 ATO 同槽 = 跨 SG 读竞态**。
  KTO 在 **P3 被别的 SG 读**（`bb = sgb(tc)+S_KTO`，tc=0..3 扫全部四个 SG 的 K 面），而全核**只有一个 group_barrier**（v4.hpp:208 / v4ph.hpp:202，在 PH2 与 P3 之间）；P3 之后到 P6 只有 SG 级 `esimd::barrier()`。
  => 快的 SG 在 P6A 写自己的 ATO（同槽）会覆盖慢的 SG **还没读完的 KTO**。
- 修法：**ATO 搬进 S2 后半（sg+5120，全程只有本 SG 写/读）**；S3 只留 AQO/KTO。`static_assert` 加两条把"ATO/HEAD-A 必须在 S2 内"钉死（编译期，无运行期分支）。
- **仪器升级（这条比修一个 bug 值钱）**：`tools/wb_slm_layout.py` 增加**跨 SG 读规则**：
  `XSG_READ`（KTO@P3、VPO@P5）+ `GROUP_BARRIERS`（只有 (PH2_2,P3) 一处）=> 同槽里"跨 SG 读的租户"与"更晚的写者"之间没有 WG 级栅栏就报错。
  **反证测试**（E:/DSH/s6/t_negcheck.py）：把 ATO 塞回 S3，检查器必须报"竞态：槽 S3 里 KTO 被跨 SG 读到 P3，而 ATO 在 P6A 写同一槽" => PASS（检查器有牙，不是只复算字节数）。
  ⇒ 军规候补 30：**SLM 别名槽的合法性 = 生命周期不相交 + 跨 SG 读的租户与更晚写者之间必须有 WG 级栅栏**；只有 SG 级 barrier 不算。

## 3x. 三关（第一/二关已过，第三关在跑）
- **台账（key 含 simd，两实例分开；工具 E:/DSH/s6/spillcheck_wbslm.py）**
  | 核 | 侧 | jit 缓存 | grf | simd | slm(B) | spill | private | scratch | scratch 指令 |
  |---|---|---|---|---|---|---|---|---|---|
  | wbv4::launch_v4full | 前(出货 E2D5E574, 新缓存 sycl-cache-base0) | 09:39:18 | 128 | 1 | **45,056** | 0 | 0 | 0 | **0** |
  | wbv4ph::launch_v4ph | 前 | 09:39:18 | 128 | 1 | **45,056** | 0 | 0 | 0 | **0** |
  | wbv4::launch_v4full | 后(wb_slm_b) | 09:38:08 | 128 | 1 | **32,768** | 0 | 0 | 0 | **0** |
  | wbv4ph::launch_v4ph | 后 | 09:38:08 | 128 | 1 | **32,768** | 0 | 0 | 0 | **0** |
  ⇒ **省 12,288B 进崖**；`private/spill/scratch=0`、**scratch 指令=0**（红线守住：没有拿 scratch 换 SLM）；grf 仍 128 顶格、simd 仍 1（ESIMD 显式契约，军规 28）。
- **walk**：`wb_slm_b.dll` Tag=wbslm_b ⇒ **1301 EXACT (249A46F374E98EB5FF5AD5E3A38EBC55) + passes 691**；默认侧（不设任何 NR_* env）就是这一侧 ⇒ 无开关、无 env 依赖。
  基线同场对照：`E:\DSH\out\libxmx.dll` Tag=wbslm_A1 也 EXACT、passes 691（判官本身可信）。

## 4x. 第三关：16 对（A=出货 E2D5E574，B=wb_slm_b，两侧都不设 env）
- run1（ab_20261102-093941）：**16 对，B 赢 12 / 负 4，均值 −0.284 ms** ⇒ 判定带内
- run2（ab_20261102-094305）：**16 对，B 赢 12 / 负 4，均值 −0.446 ms** ⇒ 判定带内
- **合并 32 对：赢 24 / 负 8，均值 −0.365 ms/帧，95% CI [−0.567, −0.163]**（CI 不含 0 ⇒ 收益方向是真的；符号检验 p≈0.006）
- 两轮的 A/B passes 全部 691/691 ✓（没有多/少发）
- 对照 §37 的上限估计（−3.9 ms 串行 ≈ 帧 −1.7）：**只兑现约 21%**（−0.37/−1.7）⇒ 崖那笔钱是真的，但 stub 曲线（§24/§29 的 0.4750→1.3512，+184%）给的是**无 dpas 的骨架价**，真核的矩阵腿已在 92% 屋顶（§37），驻留 1→2 只买到"栅栏/供给"的一部分，买不到算术。

## 5x. 判决与证据（四行交回的浓缩）
1. **SLM 账**：45,056 -> **32,768**（省 12,288，正好贴崖）；别名配对与生命周期 = `tools/wb_slm_layout.py`（含逐相活跃并集 + 跨 SG 读规则 + 反证测试）。
2. **台账（key 含 simd）**：两核均 `grf=128 / simd=1 / slm 45,056->32,768 / private=0 / spill=0 / scratch=0 / scratch 指令=0` ⇒ **没有拿 scratch 换 SLM**（§38 的红线）。
3. **walk**：`E:\DSH\builds\wb_slm_b.dll` **1301 EXACT = 249A46F374E98EB5FF5AD5E3A38EBC55、passes=691**，默认侧（无 env）；基线同场也 EXACT。
4. **判决 = 带内（不转正）**：均值 −0.365 ms/帧（32 对，CI [−0.567,−0.163]）没到 −0.5 转正线；也**不是判负**（方向稳定、零质量代价）。**留形不吹**：代码在工作树里未提交（本铲不 commit/push）。
   **驻留 1->2 的证据**：不是"应该更快了"，而是 ①JIT 台账 `slm_size` 实测 45,056 -> 32,768（同一仪器、含 simd 的 key）；②§29 实测曲线 24,640B/驻2、36,928B/驻1 ⇒ 32,768 落在驻2 一侧（65,536//32,768=2，Level-Zero `local_mem_size=65,536` 口径写死，不用上游 Vulkan 48KB 口径）；③帧侧确实拿到 −0.37 ms（32 对 CI 不含 0），与"进崖"方向一致但幅度远小于上限。
5. **下一铲的抓手（本铲买到的机制账）**：
   - 还想再省 4,096B（到 28,672）只有一条路：**拆 VPO 的连续性**（`wbv3::tile8ss` 的 B 侧步长写死 kc*1024）或**拆 PH1 的三块 f32 累加面**（3x2048/SG 同时活 = 两相 QKV 的既有形状）。两者都不是"只动 SLM 布局"，属另一把刀（且 §37 已判 WB 矩阵腿贴屋顶，别再往算术上投）。
   - **军规候补 30（本铲新条）**：别名槽合法性 = 生命周期不相交 **+ 跨 SG 读的租户与更晚写者之间必须有 WG 级栅栏**；本核只有一个 group_barrier（PH2_2->P3），所以**跨 SG 可见的字节只能在 :208 之前写**（VPO 全局区、S3 的 KTO 是仅有的两处）。
   - 仪器教训：**逐相活跃并集只算字节会漏竞态**（第一版 45,056->32,768 的字节账全对，1301 仍全帧 MISMATCH：6.56M/8.36M 字节差、x/y 全域平坦 = 上游面被污染的特征）。

## 6x. 现场核验（收尾）
- 出货件未动：`E:\DSH\out\libxmx.dll` md5 = **E2D5E5740035BE47321D55A1C7385C8D** ✓（全程只读它，变体只进 builds/）。
- 分支基底：开工时 tip `d8fc40a`；期间上级入库了 `49d1d6f`+`08e8b62`（只动 notes 与 tools/playtest.ps1），**两核源码在 HEAD 里仍是 v1 map（45,056）** => 我的 diff 对当前 HEAD 干净、`wb_slm_layout.py` 的 BEFORE 复算仍从 HEAD 读到 45,056 ✓。
- 工作树（**未 commit / 未 push**）：`M src/bench/sycl/window_block_v4.hpp`、`M src/bench/sycl/window_block_v4ph.hpp`、新增 `tools/wb_slm_layout.py`、`tools/wb_slm_mkcsv.py`。
- 变体件：`E:\DSH\builds\wb_slm_b.dll`（= `libxmx_wb_slm_b.dll`，md5 见 E:\DSH\s6\WBSLM_build_wb_slm_b.log）；废档 `wb_slm_a.dll` 已删（1301 MISMATCH，不留陷阱）。
- 临时物：ocloc 反汇编目录（pc_wbslm_*，143MB）已删；台账文本留 `E:\DSH\s6\wbslm_ledger_before.txt` / `wbslm_ledger_all.txt`；无遗留进程（nr_replay/LOP/ocloc 计数 0）。
- 复跑清单（任何人可复现）：
  1) `py tools/wb_slm_layout.py`（复算 45,056 + 别名校验 + 反证测试 `py E:/DSH/s6/t_negcheck.py`）
  2) `bash E:/DSH/s6/build_wbslm.sh wb_slm_b`
  3) `SYCL_CACHE_PERSISTENT=1; SYCL_CACHE_DIR=E:\DSH\sycl-cache` 后 `& E:/DSH/walk.ps1 -Dll E:\DSH\builds\wb_slm_b.dll -Tag <tag>`
  4) `py E:/DSH/s6/spillcheck_wbslm.py E:\DSH\sycl-cache <outdir> <cutoff_epoch>`（key 含 simd）
  5) `& E:/DSH/ab.ps1 -DllA E:\DSH\out\libxmx.dll -DllB E:\DSH\builds\wb_slm_b.dll -Pairs 16`
  6) `py tools/wb_slm_mkcsv.py <ab 日志...>` => `E:\DSH\s6\wbslm.csv`
