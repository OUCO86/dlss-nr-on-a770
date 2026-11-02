# 合并转正铲 promote2.md — (A) T2 跳 C512 全 14 链 + (B) 1a 栅栏硬化
running log, append-only. Started 2026-11-02 11:1x (+08:00).

## 现场核验（动手前）
- 主仓 = `E:\DSH\dlss-nr-on-a770`，`git branch --show-current` = **ds-quality-relax-2026-11-02**，tip = **0f03a35**（"用户实机裁决入库 §42 + 军规 33"）。工作树只有一条未跟踪 `tools/barrier_audit.py`（§43 仪器，未 commit）=> 源码干净。
- 稳定基线 worktree = `E:\DSH\wt-08e8b62`（08e8b62 + `s6/patch_testdefs.py` 的编译期默认宏钩子，已应用；`M libxmx_sycl.cpp/.def` = 就是那处钩子）。**§40 的别名手术不在这棵树里**（§41 已回退，tip 与 08e8b62 对 `libxmx_sycl.cpp`/`s6_ffn_block_kernel.hpp`/两个 window_block hpp 的 diff = 空，实测 `git diff --stat 08e8b62 HEAD` 无输出）。
- 出货位 `out\libxmx.dll` md5 待复核；回退点 `out\libxmx.bak-shipped.dll`、`out\libxmx.before-E2D5E5740035.keep` 均在（3,772,928B，2026-11-01 12:33）。
- 两个测试件 `out\test_1270e4m3.dll`(D37FFD5D) / `out\test_skip_c512.dll`(2D878C07) **不改**。
- §43 正文不在 notes 里（notes 只到 §42，1030 行）；**§43 = `E:\DSH\s6\note43.md` + 账 `E:\DSH\s6\barrier.md`**，已读：1a `ffn2::fused` = **RACE**（WG 栅栏 0 / SG 栅栏 12），出货件 12/12 逐位 = 金标 `249A46F3`，`DM_BAR=1` 判别器**只在 bench 层编好、dll 层未编**（§43 "21 处" = bench 的 s6_ffn_block4.cpp；出货 hpp 实到 **12 处** `esimd::barrier`）。
- GPU：`Get-Process` 里 **无 LOP / 无 nr_replay**（起跑前再查一次）。

## 第 1 步 — DM_BAR 判别器读数（栅栏净价）  [DONE 12:0x]
件：`builds\dm_bar.dll` ECA5A5EBA0962C2260C443F10B829402（3,812,864B，08e8b62+testdefs 树 + `//DDM_BAR=1`）
    `builds\dm_ctrl.dll` 6598EF34705E377C232A012C05E66FE3（同一补丁源码、**不带**宏 = 中性对照）
    `builds\dm_probe.dll` 89B137DB38C50AD4547E8228F35DBCEC（DM_BAR=1 + 额外 1 条 esimd::barrier = **反证见证**）
补丁：`s6/patch_bar.py` 在 `wt-08e8b62/src/bench/sycl/s6_ffn_block_kernel.hpp` 加 `S6_BAR()` 宏（12 处 `esimd::barrier()` 全换；不带 -D 时逐字=原码）。hpp md5 490647A9→F50DA026（两棵树改前 md5 相同，已核）。

**① 1301 逐位（栅栏只改可见性顺序的判据）：4/4 独立进程 = 金标 `249A46F374E98EB5FF5AD5E3A38EBC55`**（dmb1..dmb4；另 dm_ctrl 1/1、dm_probe 1/1、shipL 1/1 也 EXACT）。passes 691 不变。
**② 16 对 A=`out\libxmx.dll`(E2D5E574) vs B=dm_bar，两侧不设 env**：均值 **−0.056 ms/帧**，sd 0.458，SE 0.115，**CI95 [−0.299, +0.187]**，B 赢 9/16。
 ⇒ **栅栏成本判据（≤ +0.5ms 带内）= PASS**（读数落在 0 附近，CI 含 0，不是"赚到的 −0.056"）。
**③ 台账（`s6/spillcheck_p2.py`，去重 key 已修成含 simd + module_id；旧 key `(lab,grf,slm)` 会把 dm_bar/dm_ctrl/出货件糊成一行）**
 两侧 ffn2 完全同列：**grf=128 / simd=1 / slm=31,744B / spill=0 / private=0 / scratch=0 / scratch 指令=0**（S1 `Shape(32,64,256,0,4,2)`、S2 `Shape(16,128,512,0,4,2)`）。§34/35/36 标准守住。

## ★★ 第 1 步的真实发现（比净价更要紧）：B 在机器层 = **空操作**
- `dm_bar` 与 `出货件` 的 ffn2 设备码 **逐字节相同**：两段 `.text` 反汇编 md5 = `21DDE963AC6AF9BEDEBB6B1EA6B28795`(S2) / `053032299BADFDC09BE3144438741E26`(S1)，两边一致；`signal barrier` 指令 **8 条**（= S1/S2 活动路径上的 8 个实站点；12 处里 2 处在 `if(DUMP)`、2 处在 F16PROJ 分支被折掉）。
- **反证（仪器有牙）**：`dm_probe`（DM_BAR=1 且多插 1 条 `esimd::barrier()`）⇒ 同一核 **9 条** signal barrier、asm 尺寸变了（150,057/150,480）。⇒ `//DDM_BAR=1` **确实进了设备编译**，不是宏没生效。
- 工具链头文件同向印证（只读）：`sycl/ext/intel/esimd/detail/memory_intrin.hpp:651` 注释 `esimd_barrier, generic group barrier`；`sycl/ext/intel/esimd/memory.hpp:12045` `esimd::barrier(){ __esimd_fence(global_coherent_fence|local_barrier); __esimd_barrier(); }`；同目录 `experimental/esimd/memory.hpp:42` 另有"work-group **split** barrier"才是子组级工具。
 ⇒ **`esimd::barrier()` 在本核降级到与 `sycl::group_barrier(it.get_group())` 同一条 CTA 栅栏指令。**
 ⇒ **B 的净价 = 0.000 ms、0 字节机器码；B 的机器层收益 = 0。** §43 审计判据里"esimd::barrier 只是 SG 级、缺 WG 级栅栏"这条**前提**在"头文件 + 逐字节同码"两条证据下站不住：1a 的 RACE 条目应重新定性为 **源码级可疑 / 机器级同一栅栏**（不是"潜在竞态已消"，也不是"竞态已现形"——12/12 确定性那条实测仍站着）。
 ⇒ 源码级升级仍然值得合并（表达 CTA 意图、`barrier_audit` verdict 从 RACE→OK、并为以后在 1a 里加别名的人留护栏），但**不能把它当正确性修复来记账**，也不该为它单独说"消掉了竞态"。

## 栅栏审计 verdict（升级后的仪器，同一脚本跑两棵树）
仪器更新（`tools/barrier_audit.py`）：(a) `S6_BAR()` 按 DM_BAR 两侧分类、跳过预处理行（防假 OK）；(b) 1a landmark 改**按锚点正则定位**（硬化在 hpp 顶部加宏块 ⇒ 行号整体 +18，硬编码会错位 = §43 修过的假 RACE 会复发）；(c) `BARRIER_SRC` 可指别的树；(d) 1a 一次跑 DM_BAR=0/1 两行。反证仍 PASS（S2 版 NO-RACE / ATO->S3 报 RACE，exit 0）。
- **BEFORE**（tip 未硬化，`s6/barrier_audit_before.csv`，38 行）：`ffn2::fused (1a)` = **RACE**（WG=0 SG=12，7 条 HANDOFF/REUSE 条目，与 §43 一致）。
- **AFTER**（硬化后源码，`s6/barrier_audit_after.csv`）：`[DM_BAR=0]` 仍 **RACE**（WG=0 SG=12）；`[DM_BAR=1]` = **OK**（WG=12 SG=0，0 条）。其余 9 核 verdict 一字未变。

## 改令记录（用户 12:3x）
**转正件走 A-only，不带 B**。理由 = 上面那条机器级证据（B 是 codegen 空操作，只给 shipped 源码添宏噪声）。
B 的机器级证据与 §43 定性更正**留在账里**（见上一节）；`barrier_audit.py` 已按要求改成 **source-level / machine-level 两栏**（`verdict_source` + `verdict_machine`，未做 ISA 对照的核一律标 `not-measured`，不许当绿），并在文件里写死**机器级判据草案**（REUSE/HANDOFF 再分「跨已发射栅栏区间重叠」=真竞态候选 vs「同一区间内重叠」=只能报源码级；§40/§41 的红按此重新解释为"别名让读与更晚的写落在同一个 CTA 栅栏区间内仍重叠"，修法是拆槽/挪相而不是加 group_barrier）。草案**未施工**。
`patch_bar.py --revert` 已把 `s6_ffn_block_kernel.hpp` 退回原状（md5 回到 490647A9…，工作树只剩 `M libxmx_sycl.cpp/.def` = testdefs 钩子）。

## 第 2 步 — 合并候选（改令后 = A-only）`builds\cand_skip.dll`
构建脚本 `s6/build_cand_a_only.sh`（REPO=E:/DSH/wt-08e8b62；`//DT_SKIP_CHAINS_DEF="18,19,20,21,22,23,24,26,27,28,29,30,31,32"`，**无** DM_BAR）。
- **cand_skip.dll md5 = ABB969FE4AAF0F94AA03C3F53781EDD0**（3,813,376B）
- ★ 与用户实机验收过的 `out\test_skip_c512.dll`(2D878C07…) 逐字节对照（`s6/cmp_dll.py`）：**只差 6 个字节**，两段各 3B（0x110、0x166724）= PE 时间戳/构建 id 类字段 ⇒ **转正件在机器上就是那只被眼睛验收过的件**，不是"另一个件"。
- 曾按原令编过带 B 的合并件 `builds\cand_skip_bar.dll`(0C961F7F…) 与 A-only 的 `builds\cand_skip_only.dll`(68AC0391…，带宏但不开) —— 留作对照，不部署。
**A 的 record-time 证据（walk_csL.txt:17-32）**：
`[skip-chains] graph=0 closures=691 names=1382 name_offset=691 chains=52 NR_SKIP_CHAINS='18,…,32'`；
14 条 `chain=NN SKIPPED closures …(12 no-ops): xmx_rec_quant_window .. xmx_rec_gemm_int8_residual`（链 18-24、26-32）；
**`chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`** ⇒ 硬守卫没拒任何一条、passes 不变。
**8/8 独立进程确定性（军规 31）**：csL,cs2..cs8 = **8 个独立进程、distinct md5 = 1** = **`DD49827DD33A7EF07C2C17892F18970D`**；
  且这个 md5 与 §33 的 `skip_C512alla/b`、§41 的 `t2_skipc512_a..d` **完全相同** ⇒ 三条独立路径（env 开关 / 编译期默认 / 本次转正件）逐位一致。
  对旧金标 `bk.1301.bin`(249A46F3) 报 `1301 MISMATCH` 是**预期**（整条链被移除，逐位已不可能），不是失败线里那条"不该变的场合"。
  帧读数 run1..3 中位 = 58.35-59.40 ms（出货件同场 63.07-63.54）。
**台账（`s6/spillcheck_p2.py`，key 含 simd + module_id）**：cand 的 ffn2 S1/S2 = **grf 128 / simd 1 / slm 31,744B / spill 0 / private 0 / scratch 0 / scratch 指令 0**，module_id 5379550853650700359 = 与出货件/dm_ctrl **同一设备模块**（A-only 没碰任何核代码，符合预期）。
**B 的验收（barrier_audit 两栏，改令后只作证据不部署）**：BEFORE `s6/barrier_audit_before.csv` = source RACE（WG=0/SG=12）；AFTER `s6/barrier_audit_after.csv` = `[DM_BAR=0]` source RACE、`[DM_BAR=1]` source **OK**（WG=12/SG=0），machine 栏两行都写"已实测：两种写法逐字节同码"。反证仍 PASS、exit 0。

## 第 3.1 步 — 39 门（cand 已 stage 到 `E:\DSH\oneapi\libxmx_sycl.dll`，旧件留 `oneapi\libxmx_sycl.E2D5E574.keep`）
**结果 = 39 GREEN / 0 RED**（`bash E:/DSH/run_gates.sh`，GATEPY = DSH 自带 python）。
**但必须如实说：这 39 门里没有任何一扇在测跳块路径。**逐条核过（logs 里 grep `[skip-chains]`）：
- 只有 **2** 扇门的日志出现 `[skip-chains]`：`gate_graph`（28 条打印）与 `gate_coexist`（14 条），且两边都是 **`chains_skipped=0 refused=14 closures_noop=0 passes=1 (unchanged)`** —— 那两扇门的小图只有 1 条链，请求的链号 18..32 全部 `OUT OF RANGE … ignored`（`refused` 计数器在这里数的是"越界请求"，**不是**硬守卫拒绝）⇒ 门的数值判据一字未动。
- 其余 37 扇门连 `skip_chains_apply` 的打印都没有（它们不建 52 链的整图）⇒ **跳块类门红"预期"没有发生，因为门根本没有跳块类**。
⇒ 不许改门到绿（一字未改门）；跳块路径的门 = 本次靠 **walk 整图（passes 691 不变 + chains_skipped=14 refused=0 + 8/8 逐位 + 画质表 + 用户实机）**，建议下一铲把"整图 52 链 + skip 后对新金标逐位"做成第 40 门（现在它只活在 walk 里）。

## 第 3.2 步 — 新基线冻结（顺序：先 8/8，再冻结）
8 个独立进程 distinct md5 = 1（`DD49827DD33A7EF07C2C17892F18970D`，见上）⇒ 允许冻结。
- `dumps\bk.1301.bin`(249A46F3…) **改名保留** = `dumps\bk.1301.pre-skip-1a.bin`（旧金标不删）
- 新金标 = `dumps\bk.1301.skip.bin`(DD49827D…)；`dumps\bk.1301.bin` = 同一字节的软拷贝 ⇒ walk 的 `1301 EXACT` 自动对新金标
- 用法与两代含义写进 **`dumps\GOLDEN.md`**（含照抄可用的命令：旧件回归必须显式 `-Gold …pre-skip-1a.bin`，否则假红）
- 冻结后复核：`out\libxmx.dll`(新) → **1301 EXACT vs 新金标**（logs\walk_dep1.txt）；旧 1a 件 → **1301 EXACT vs 旧金标**（logs\walk_old1a.txt）

## 第 3.3 步 — 16 对（A=E2D5E574 vs B=cand_skip，两侧不设 env）
**mean −4.794 ms/帧、median −4.750、sd 0.529、SE 0.132、CI95 [−5.074, −4.514]、B 赢 16/16** ⇒ 判定 = 转正。
与 §41 的 −5.133 [−5.644,−4.621] 同向同量级：本次比那条**少赚 0.34 ms**，远小于失败线的 +1.5 ms ⇒ 不触线。
第二次 16 对（`test_skip_c512` vs `cand_skip`，用来隔离栅栏净价）**取消**：改令后 B 不进件，且两件逐字节只差 6B 时间戳；
栅栏净价已在第 1 步单独量过（16 对 −0.056、CI [−0.299,+0.187]、9/16 ⇒ 带内 0 成本）。

## 第 3.4 步 — 画质表（军规 33，新做的仪器）
`tools/db_meter.py` 加：**per-tile 64×64 最差 dB（min/p1/p5/p50 + <40/<35/<30/<25/<20 块数）**、**平坦区异常**（最低 20% 梯度块的 mean|d| vs 全域/陡峭）、**成片色偏**（每块逐通道均值偏移 / golden sigma）、**结构保持率**（块内梯度 test/golden，彩色方块 = 塌陷）、**A 通道单判**（corr_A < 0.90 ⇒ MUST-SCREEN）。顺手修一个仪器 bug：`--cross` + `--csv` 旧写法取 `rows[0].keys()` ⇒ `KeyError: 'md5'`（现 = 键并集 + restval）。自测仍过（bk vs bk = inf/IDENTICAL；合成噪声 σ=0.5571 ⇒ 27.88 dB@range / 5.08 dB@[0,1]，与写死的期望 27.89/5.09 一致）。
**新件 vs 旧金标**（`s6\judge_promote2.txt` / `judge_promote2.csv` / `judge_promote2_tiles.csv`）：
corr R .965 G .991 B .988 **A .773**（luma .991）；dB@range 30.80；135 块里 dB min 28.85 / p1 28.41 / p5 30.09 / p50 29.36；
**<20dB 块 = 0**、<30dB 29 块；平坦区无异常（平坦/陡峭 = 0.87）；成片色偏 max 0.375σ（>1σ 块 0）；结构保持率 min 0.906（<0.6 块 0）；
**CROSS（两个独立进程）= IDENTICAL / inf** ⇒ 无跨进程抖动。A 通道单判 = **MUST-SCREEN（0.773 < 0.90）** ⇒ 与 §42 一致：这类改动必须眼睛过。
★ **牙齿对照（必须如实说，`s6\judge_teeth.txt`）**：同一套指标跑"被眼睛否决的 T1"与"被接受的 T2"——
T1 per-tile dB min **34.80**、色偏 max 0.316σ、塌陷 0 块；T2 dB min **28.85**、色偏 max 0.375σ、塌陷 0 块 ⇒
**per-tile dB / 色偏 / 塌陷三样在 T1 与 T2 之间没有分离力，甚至方向相反**（T1 读数更好却被否决）。
唯一与眼睛同序的信号仍是 **corr_A：T1 0.614 < T2 0.773**（两者都 <0.9 ⇒ 都进实机名单）。
⇒ 结论：**新表不能当"T1 型彩色方块"的探测器**；它给的是"没有 <20dB 成片坏块、无平坦区异常、无跨进程抖动"这类**排除性**读数。
T2 的"彩色方块型风险"因此判 = **机器读数无此类信号 + 用户实机已验收**，但这条判断的分量主要来自眼睛，不来自这张表。

## 第 4 步 — 部署（只在 DSH 内）+ 交回
- `builds\cand_skip.dll`(ABB969FE…) → **`out\libxmx.dll`**（游戏加载位）；旧件先留 `out\libxmx.keep-E2D5E5740035.pre-promote`。
- 部署后 md5 链：out\libxmx.dll = ABB969FE；回退点 out\libxmx.bak-shipped.dll = E2D5E574、out\libxmx.before-E2D5E5740035.keep = E2D5E574、out\libxmx_B8908BD2.dll.keep = B8908BD2；两个测试件 md5 未变（2D878C07 / D37FFD5D）；bench 位 oneapi\libxmx_sycl.dll = ABB969FE（旧件留 oneapi\libxmx_sycl.E2D5E574.keep）。
- `out\DEPLOY.md5.txt` 已追加一条（旧/新 md5、时间、8 条判据摘要、一键回退 copy）。
- 一键回退：`Copy-Item E:\DSH\out\libxmx.keep-E2D5E5740035.pre-promote E:\DSH\out\libxmx.dll -Force`（回退后 walk 要显式 `-Gold dumps\bk.1301.pre-skip-1a.bin`）。
- 纪律复核：只写 `E:\DSH\`（builds/、out/、dumps/、logs/、s6/、tools 副本在仓内未 commit）；`E:\WorkBuddy` 只读；C 盘未写；游戏目录一字未动；未 commit/push；GPU 每次开跑前查 `LOP`=0、跑完无残留进程；未产生临时 exe。
- 源码现场：`wt-08e8b62` 只剩 `M libxmx_sycl.cpp/.def`（= testdefs 钩子）；`s6_ffn_block_kernel.hpp` 已 revert 回 490647A9…（B 的宏不进 shipped）。主仓 tip 未动。
