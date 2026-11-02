# judge40 — 第 40 门（跳块整图回归）+ T1 型灾难探针（2026-11-02 13:0x 起）

## 0. 前置确认（动手前）
- `git branch --show-current` = **ds-quality-relax-2026-11-02**，`git log -1` = **6a58645**（T2 转正 + §45 两缺口）。工作区干净（`git status --porcelain` 0 行）。
- 工程仓 = `E:\DSH\dlss-nr-on-a770`（`E:\DSH` 本身不是 git 仓，README:18）。
- `E:\DSH\out\libxmx.dll` / `E:\DSH\oneapi\libxmx_sycl.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0**（转正件，未动）。
- `run_gates.sh` 门名单 = 39 条（第 15 行），末尾门 `gate_coexist`。

## 1. 标定样本（第 1 步）
| 角色 | 文件 | md5 | 字节 |
|---|---|---|---|
| T1（被眼睛否决，1270 面 e4m3） | `dumps\t1_1270e4m3_a.1301.bin`（b/c/d 同 md5） | `481C6CAEEC169157D947E682620C8B27` | 8,355,840 |
| T2 = 转正件 = 新金标 | `dumps\t2_skipc512_a..d.1301.bin` = `bk.1301.skip.bin` = `bk.1301.bin` | `DD49827DD33A7EF07C2C17892F18970D` | 8,355,840 |
| 旧 1a 金标（画质对照） | `dumps\bk.1301.pre-skip-1a.bin`（= `old1a.1301.bin`） | `249A46F374E98EB5FF5AD5E3A38EBC55` | 8,355,840 |

## 2. 探针（第 2 步）：`tools/block_collapse.py` + 并入 `tools/db_meter.py` 一栏

### 2.1 先摸清 T1 到底长什么样（临时脚本 `s6/_t1_explore.py`、`_t1_explore2.py`、`_coh_curve.py`）
**先算后改（军规 22）：三条"按字面实现"的统计在 T1 上全部落空，必须先把机理测出来再定形式。**
- **T1 塌的不是 RGB，是 A 通道**：64x64 块内 `var(test)/var(golden)` —— R min 0.897 / G 0.989 / B 0.994（**RGB 完全不塌**），**A min 0.374、4.17% 的块 <0.5**；尺度越粗越明显（A@128 10.71%、A@256 16.7%）。
- **不是"常数块"**：块内不同量化值个数 T1 0.9651 vs T2 0.9590（每像素基本都不同值）；相邻差非零比例 T1 0.9999 / T2 1.0000 ⇒ **C2 全盲**。
- **不在 64/128 网格上**：沿 p=64/128 网格的 mean|Δ| / 非网格 mean|Δ| —— T1 1.005/1.017、T2 0.979/1.020（golden 自己也是 1.02~1.04）⇒ **C3 全盲**。原因写死：T1 是 **1270 面**降 e4m3，那块网格经过重采样进到 1301 面，**不落在 1301 的 64/128 网格上**（周期扫描 p=8..272 也没有峰，D 的 R 通道在任何 p 上都是 1.11，属 8 的约数族假象）。
- **真正的 T1 指纹 = 误差场"成片"**：A 通道误差 **幅度与 T2 几乎相同**（rms 7.17 vs 6.92，这就是 §45 里 dB/色偏分不开的原因），但**空间结构完全不同**：
  - 误差场自相关（A，x/y 平均）：rho64 **T1 0.550 / T2 0.309**；rho128 **0.373 / 0.184**；coh_len **64 / 1**；积分相关长度 **79.4 / 51.9** px；
  - 纯 x 方向 rho 到 lag 256 仍有 **T1 0.565 vs T2 0.212**（y 方向 T1 在 128 之后掉下去 => 台阶是**横向长条**，不是正方格）。
  - 误差场分段常数度：A segconst@16 **0.181 / 0.377**；A blockiness@64 **1.292 / 0.770**、@128 **1.508 / 0.787**；A 最坏块 mean|d| **14.34 / 10.18**（= 0.45σ / 0.32σ）。
  ⇒ **A 是合成权重面，块状 A 误差 = 屏幕上成片错色 = 用户看到的"彩色大方块"**；这条与 §45"唯一与眼睛同序的是 corr_A"完全咬合。

### 2.2 探针形式（`E:\DSH\dlss-nr-on-a770\tools\block_collapse.py`）
C1 块内方差坍缩比（逐通道 R/G/B/A+RGB，尺度 16/32/64/128）· C2 块内有效等级数（levels/像素、相邻差非零比例）· C3 网格台阶能量（p=64/128，x/y，test 与 golden 各算再比）· C4 误差场分段常数度（segconst / blockiness / maxblockmad）· C5 误差场空间自相关（rho@1/64/128/256、coh_len、L_int）。
判决用**三族**（互不相同的机理，避免同一栏重复计数）：
`F1 塌陷(C1) | F2 相关(C5) | F3 台阶(C4)`；**>=2 族命中 => BLOCK-REJECT；1 族 => BLOCK-WARN(必须实机)；0 族 => block-ok；任一通道 C1 的 <0.5 块占比 >=25% => 无条件 REJECT（大面积抹平）**。幅度地板：某通道 rms(D)/rms(golden) < 0.02 => 该通道 F2/F3 不适用（误差小到看不见，谈成片没有意义）。
并入 `tools/db_meter.py`：新增 `block_probe_report()`，每次画质判据自动多一栏 `块退化探针(judge40): <verdict>` + csv 列 `blk_*`（可用 `--no-block` 关掉，但**不许用它出转正结论**）。db_meter 自测仍过（bk vs bk = inf/IDENTICAL；sigma=0.5571 合成噪声 dB@range 28.13 / dB@[0,1] 5.08，且该 iid 噪声案例在探针上 = **block-ok** => 与合成负对照一致）。

### 2.3 标定矩阵（全部读数见 `s6/judge40.csv`；原始逐栏 csv：`judge40_collapse_main.csv`、`judge40_matrix_oldaxis.csv`、`judge40_self_newaxis.csv`、`judge40_synth.csv`、`judge40_pop.csv`）
| 对照 | 判决 |
|---|---|
| **T1 vs 旧金标**（481C6CAE） | **BLOCK-REJECT 3/3 族**：F1[C1_A@64 4.17%、C1_A@128 10.71%] + F2[rho64 0.550、rho128 0.373、coh_len 64、L_int 79.4] + F3[blk64 1.292、blk128 1.508、seg16 0.181、mad/σ 0.45] |
| T1 另一进程（t1_b） | 同上，**逐位相同读数**（同件两进程 => 探针可复现） |
| **T2 vs 旧金标**（转正件=新金标） | **block-ok（0 族命中）** |
| 旧金标 vs 旧金标（old1a） | `EXACT(no error field)` => **0 假阳** |
| 新金标 vs 新金标（bk.1301.bin vs bk.1301.skip.bin，含 t2_a/t2_b 两进程） | `EXACT` x4 => **0 假阳** |
| T1_a vs T1_b（同件两进程互比） | `EXACT` => 无跨进程抖动 |
| T2_a vs old1a（新金标 vs 旧金标 = 被接受的改动本身） | **block-ok** |
| **合成 S1**：A 通道 64x64 块均值化 | **REJECT**（C1_A@64=100%、@128=92.9%） |
| **合成 S2**：A 通道 iid 高斯 **rms=7.17（与 T1 的 A 误差同幅度）** | **block-ok**（rho64=-0.0004）=> 探针不测幅度 |
| **合成 S3**：A 通道 128 块间随机台阶 | **REJECT**（F2+F3：rho64 0.527、blk128 巨值、seg16 0.000） |
| **合成 S4**：RGB 三通道 64x64 块均值化 | **REJECT**（C1_R/G/B/RGB@64 全 100%） |
| **合成 S5**：RGB iid 噪声 rms=0.40（与 T2 的 RGB 误差同幅度） | **block-ok** |
| 总体：`SYNTH-self`（golden vs golden） | `EXACT` => 0 假阳 |

### 2.4 人群扩展（同一旧金标轴，非眼睛样本 => 只作分布检查，不当判据）
- **红族（与 T1 同机理）**：`bgS_e4_wres`(= T1 同一刀的 §34 版，读数与 T1 **逐位相同**) REJECT 3/3；`bgN_e4m3w_a`（e4m3 权重）REJECT 3/3；**`bgS_s8_wres`（int8 残差面）REJECT（大面积抹平：R 通道 50.8% 的块 var 比<0.5）** => 下一把 `WB f16->int8` 铲的同类灾难**已经被这台仪器抓过一次**，这条是协议里最硬的先例。
- **绿族（跳块同类，眼睛未测）**：`skip_C512alla`（= T2 的 env 路径）block-ok；`skip_big28a` / `skip_mix16a` / `skip_L512x1a` 各 **1 族命中 => BLOCK-WARN(必须实机)**，不是 REJECT => 门不越权替眼睛裁决。
- **逐位全同族**：`cur / walkfix / s6prom / det_ffn0_1 / bgS_e4_res / bgP_on / bf2_fold_a / bf3_fold` 全部 `EXACT`（0 假阳）。

### 2.5 有牙 / 没牙（诚实结论）
- **有牙**：C5（A 误差场空间自相关）与 C4（A 误差场台阶化）、C1 的 **A 通道 @128 尺度**。T1 与 T2 的分离倍数 1.5~64x，且合成正/负对照双向正确（**同幅度的 iid 噪声不红，块化才红**）。
- **没牙（照字面实现的三条里有两条半失败）**：
  - **C2 块内等级数：完全无信号**（T1 没有任何块退化成常数）；
  - **C3 网格台阶能量：完全无信号**（方块不在 64/128 网格上；重采样把网格打散了）——**还缺的东西：要在**输入面（1270）自己的网格上**测，或先做周期反卷积；本轮没做，列为后续仪器项；
  - **C1 在 RGB 上无信号**（T1 的 RGB 不塌），只有 A 通道有；且 @16 尺度反序 => 尺度必须写死 64/128。
- 所以"做不到完全按题面三统计分离"是事实；**分离成功的是加了 C4/C5（误差场空间结构）之后的同一把探针**，题面要求的 C1/C2/C3 全部实现并给出读数与 NO-SEPARATION 结论。

## 3. 第 40 门（第 3 步）：`src/bench/sycl/gate_skip_graph.py`

**内容**：整图（5254 步 / **chains=52** / **closures=691** / names=1382）+ 跳 C512 全 14 链，走 `oneapi/nr_replay_now.exe`（帧判官本体），被测件 = 转正件 **ABB969FE4AAF0F94AA03C3F53781EDD0**（`out/libxmx.dll` 进程 1、2 + `oneapi/libxmx_sycl.dll` 进程 3 交叉核对）。门**不 stage、不改写任何 dll/金标**，只写 `dumps/gate40_p{1,2,3}.1301.bin` 与 `logs/gate40_*.txt`。

**断言（单门手跑 = 26 条 ok / 0 FAIL，`SKIP_GRAPH GREEN (0 fails)`）**
- 身份：`out/libxmx.dll` 与 `oneapi/libxmx_sycl.dll` md5 都 = ABB969FE；金标 `bk.1301.skip.bin` md5 = DD49827D；
- record-time 原文（进程 1/2/3 一字不差）：
  - `[skip-chains] graph=0 closures=691 names=1382 name_offset=691 chains=52 NR_SKIP_CHAINS='18,19,20,21,22,23,24,26,27,28,29,30,31,32'`
  - `[skip-chains] graph=0 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`
- `SKIPPED closures` 行数 = **14**、链号集合 = {18..24, 26..32}、逐条累加 no-op 闭包 = **168**；
- **没有一条 `OUT OF RANGE ... ignored`**（这正是 gate_graph/gate_coexist 里"假跳块"的signature，本门把它当 FAIL）；
- `[cgraph] recorded graph id=0 (691 closures)`、4 趟 replay 每趟都返回 **(691 passes)**；
- 1301 dump 8,355,840 B，md5 = **dd49827dd33a7ef07c2c17892f18970d = 新金标**，**三个独立进程全部 EXACT**；
- 跑完再核：两个 dll 仍是 ABB969FE（门没动过件）。

**门名单**：`E:\DSH\run_gates.sh` 第 15 行末尾**加一条** `gate_skip_graph`（其余 39 条一字未改），仓内镜像 `tools/dsh_run_gates.sh` 同步（`fc` 证两文件无差异）。

## 4. 给 WB 四腿 f16->int8 铲的评估协议草案（**只写方案，不施工**）

### 4.0 为什么这把铲必须先过探针（本铲的直接理由）
`WB 四腿 f16->int8` 改的是**数值契约**，与 T1（1270 面降 e4m3）同族。§45 已证：改数值契约的灾难**不体现在误差幅度上**（T1 与 T2 的 A 误差 rms 7.17 vs 6.92 几乎相同），只体现在**误差成片/块内结构塌陷**上。人群扩展里已经有一条同类先例：**`bgS_s8_wres`（1270 面 s8 残差）= 大面积抹平，R 通道 50.8% 的 64x64 块 var(test)/var(golden) < 0.5**（探针无条件 REJECT）。⇒ 这把铲没有探测器绝不上机。

### 4.1 判据顺序（每一关都是门，不是建议）
1. **40 门全绿**（含新 `gate_skip_graph`）：数值契约改动不许动整图记账（`chains_skipped/refused/passes` 与逐位金标）。
2. **先离线件、不上加载位**：照 §41 的做法编 `test_wbint8.dll`（宏后面），4/4 独立进程落 dump。逐位判据换轨：**改了数值 => 不再要求 1301 EXACT**，但**必须要求 CROSS（同件两进程互比）= IDENTICAL/inf**；不 IDENTICAL = 竞态（§41 先例），当场停，不进画质环节。
3. **`tools/db_meter.py` 五尺 + 军规 33 per-tile + A 单判 + 新的块退化栏**（同一条命令全出）：
   `py tools/db_meter.py dumps/bk.1301.skip.bin dumps/wbint8_a.1301.bin dumps/wbint8_b.1301.bin --cross --csv s6/judge_wbint8.csv --tile-csv s6/judge_wbint8_tiles.csv`
   - `corr_min_RGB >= 0.99` SAFE / `0.95..0.99` 必须实机 / `<0.95` REJECT；
   - `corr_A < 0.90` => `A-CORR-MUST-SCREEN`（§45：A 是唯一与眼睛同序的老指标）；
   - **`blk_verdict`（judge40 探针）**：见 4.2。
4. **帧 A/B 16 对**（同仪器同热、`walk.ps1`/`dsh_ab.ps1` 路数）：转正线 = 均值 <= -0.5 ms/帧且 CI95 不含 0；**性能读数只在过关之后才有意义**（军规 22 先算后改、军规 29 别把仪器价当刀价：T1 的 +56.6 ms 就是独立 QDQ 趟的仪器价）。
5. **用户实机裁决**（军规 33 (d)）：眼睛一票否决，任何"机器全绿"都不能替代。

### 4.2 探针用哪几栏、阈值多少（`tools/block_collapse.py` 的 `TH`，已随本铲入库）
三族命中规则：**>=2 族 = BLOCK-REJECT（一票否决，不进实机排队）；1 族 = BLOCK-WARN（必须实机）；0 族 = block-ok（仍要实机）**；任一通道 `C1 的 <0.5 块占比 >= 25%` = 无条件 REJECT。
| 族 | 栏 | 阈值 | 本轮标定读数（T1 红 / T2 绿） |
|---|---|---|---|
| F1 塌陷 | `C1_RGB@64 <0.5 块占比%` | >=3.0 | 0.00 / 0.00（int8 铲**主要盯这两栏**） |
| F1 塌陷 | `C1_RGB@128` | >=6.0 | 0.00 / 0.00；先例 `bgS_s8_wres` R@64=50.8% |
| F1 塌陷 | `C1_A@64` / `C1_A@128` | >=3.0 / >=6.0 | 4.17 / 2.50；10.71 / 3.57 |
| F2 相关 | `C5_RGB_rho64` / `rho128` / `coh_len` | >=0.55 / >=0.45 / >=48 | 0.253 / 0.362（**RGB 上无分离力 => 阈值来自合成对照，保守**） |
| F2 相关 | `C5_A_rho64` / `rho128` / `coh_len` / `L_int` | >=0.45 / >=0.28 / >=48 / >=65 | 0.550/0.309；0.373/0.184；64/1；79.4/51.9 |
| F3 台阶 | `C4_RGB_blk64` / `blk128` / `seg16` / `maxblockmad/rms` | >=1.20 / >=1.20 / <=0.25 / >=0.45 | 合成标定（RGB 未过人眼） |
| F3 台阶 | `C4_A_blk64` / `blk128` / `seg16` / `maxblockmad/rms` | >=1.20 / >=1.20 / <=0.25 / >=0.45 | 1.292/0.770；1.508/0.787；0.181/0.377；0.45σ/0.32σ |
**不许动的东西**：`C2 块内等级数` 与 `C3 64/128 网格台阶能量` 本轮判为 **NO-SEPARATION**（T1 没有常数块、方块不在 1301 的 64/128 网格上）=> 只作记录，**不进判决**，也不许为了"看起来有牙"去调它们的阈值。

### 4.3 什么情况下必须回实机（用户眼睛），什么情况必须回我重跑
**必须回实机**（任一成立就去，不带侥幸）：
- (a) 探针 **BLOCK-WARN**（1 族命中）；(b) `corr_min_RGB ∈ [0.95,0.99)`；(c) `corr_A < 0.90`；
- (d) **任何改面/改数值契约/跳块的铲，即使探针 block-ok**（T1 的教训：幅度类指标抓不住块化，最终判据是眼睛）；
- (e) 任何时间性现象（帧间闪烁、同件两进程不 IDENTICAL）——眼睛一票否决权不变。
**必须回我（DS 侧）重跑/补仪器**：
- 探针 REJECT 而眼睛说没问题 => 先查**金标代际用错**（旧件必须显式 `-Gold bk.1301.pre-skip-1a.bin`；选错金标 = 假红或假绿，GOLDEN.md 写死），再查探针是否命中在辅助栏；不许直接放宽阈值；
- 探针 block-ok 而眼睛否决 => **把该样本入库成新的红族标定样本**（像 T1 这次一样），用它的读数重新定阈值并写进 `TH` 注释；
- 需要在**改动真正发生的那张面**上测（1270/1267/1274/1275）：当前探针只吃 960x544 的 1301 面；把 `block_collapse.py` 加面尺寸参数，才能把 `C3` 从"NO-SEPARATION"救回来（在 1270 面上网格是对齐的）。这是下一件仪器活，**不是这把铲的前提**。

### 4.4 交付形态（这把铲过关时要交齐的东西，照 §45 的样板）
`out/test_wbint8.dll` md5 + 4/4 独立进程 dump md5 + `s6/judge_wbint8.csv`（含 `blk_*` 列）+ `s6/judge_wbint8_tiles.csv` + 16 对 A/B 表（mean/median/sd/CI95/赢数）+ 40 门日志 + 用户实机结论；**不 commit/push、不部署**，由用户决定何时 cp。

### 3.1 全套 40 门读数（`bash E:/DSH/run_gates.sh`，日志 `logs/run_gates_40.txt`，13:5x）
```
gates: 40 GREEN / 0 RED
```
逐条：`gate_libxmx_sycl … gate_coexist`（原 39 条一字未改）+ `gate_skip_graph` = **GREEN**。
`logs/gate_skip_graph.log` 里三个进程的关键原文（一字不差）：
```
[skip-chains] graph=0 closures=691 names=1382 name_offset=691 chains=52 NR_SKIP_CHAINS='18,19,20,21,22,23,24,26,27,28,29,30,31,32'
[skip-chains] graph=0 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)
ok    gate40_p1: 1301 EXACT vs bk.1301.skip.bin  md5=dd49827dd33a7ef07c2c17892f18970d
ok    gate40_p2: 1301 EXACT vs bk.1301.skip.bin  md5=dd49827dd33a7ef07c2c17892f18970d
ok    gate40_p3: 1301 EXACT vs bk.1301.skip.bin  md5=dd49827dd33a7ef07c2c17892f18970d
SKIP_GRAPH GREEN (0 fails)
```
跑后复核：`out\libxmx.dll` = **ABB969FE**、`oneapi\libxmx_sycl.dll` = **ABB969FE**（未被 stage）；金标三件 md5 未变（DD49827D / DD49827D / 249A46F3）；`out\test_*.dll` 未动；无残留 GPU 进程；oneapi 无新增临时 exe；新增证据文件 = `dumps\gate40_p{1,2,3}.1301.bin`（各 8,355,840 B）+ `logs\gate40_gate40_p{1,2,3}.txt`。

### 2.6 跨轴稳健性（补测，13:5x）：把 T1 对**新金标** `bk.1301.skip.bin` 再判一次
`=> BLOCK-REJECT(2/3 族命中)`：F2 相关[rho64 0.634、rho128 0.483、coh_len 64、L_int 108.2] + F3 台阶[blk64 1.246、blk128 1.542]；F1 塌陷**不命中**（C1_A@64 只剩 0.83%）。
⇒ 结论写进协议：**在金标换代之后的轴上，塌陷族(F1)会退化，必须靠 F2/F3**；这也是为什么 `bgS_s8_wres` 那种 50.8% 大面积抹平要单独设"无条件 REJECT"。

### 纪律复核
只写 `E:\DSH\`（tools/、src/bench/sycl/、s6/、dumps/gate40_*、logs/）；`E:\WorkBuddy` 只读、C 盘未写、游戏目录未动；未 commit/未 push（`git status --porcelain`：`M tools/db_meter.py`、`M tools/dsh_run_gates.sh`、`?? src/bench/sycl/gate_skip_graph.py`、`?? tools/block_collapse.py`）；金标只读；GPU 每次开跑前查 `LOP`/replay/bench = 无，跑完无残留进程；无临时 exe 遗留。
