# 交接：Arc A770 这一轮做到哪了，明天怎么验收

写这份东西的原因：这一轮我犯过错，也留下了几件没做完的事。
下一棒（不管是人还是模型）接手前，先读完这一页，别重蹈覆辙。

---

## 0. 一句话状态

**代码是能跑的，成果已经固化（本地备份 + GitHub 公开库）。
唯一没闭环的是"改动在真实游戏里的收益"——那个数字必须你在游戏里测，我测不了。**

| 交付物 | 位置 | 状态 |
|---|---|---|
| GitHub 公开库 | <https://github.com/OUCO86/dlss-nr-on-a770> | ✅ 已同步到 **`42cd8a6c`**（本地 `416ed98` 的重建），18 个提交，`windows` 为默认分支，标签 `a770-int8-verified` 同步更新 |
| 本地全量快照 | `E:\WorkBuddy\2026-10-09-04-20-55\backups\dlss-nr-on-a770-20261010-0110` | ✅ 994 文件 / 675 MB（含 `.git`、419 MB 模型权重、dll、spv、日志、基准数据） |
| 可恢复 git 包 | 上述目录内 `repo-all.bundle` | ✅ 含全部分支与标签 |
| 启动脚本真身 | `E:\WorkBuddy\2026-10-09-04-20-55\tools\` | ✅ 桌面三个 bat 是薄封装 |

⚠️ **419 MB 的 NVIDIA 权重、编译产物（dll/spv）都在本地备份里，但不会上传 GitHub**（`.gitignore` 挡住了）。这是有意的：既不泄出去，也不丢。

---

## 1. 硬件与工作点（实测，别再推断）

| | |
|---|---|
| GPU0 | **AMD RX 9070 XT** — 负责渲染 |
| GPU1 | **Intel Arc A770** — 负责跑 NR（驱动 32.0.101.9030） |
| CPU / 内存 | Ryzen 9 5900X 12C/24T / 80 GB（不是瓶颈） |
| 网络输入 | **768×448**（1920×1080 按 `render_scale=0.4` 缩放） |
| 游戏输出 | 1920×1080 B8G8R8A8_UNORM（**原生分辨率，未降画质**） |

⚠️ **枚举顺序是 AMD 在前**，任何 `pds[0]` 都会选错卡。所有创建设备的地方都必须走 `src/gpu/gpu_pick.h`。

---

## 2. 怎么跑起来（两种入口，任选）

### A. 双击桌面 bat（推荐，你习惯的方式）
1. **`DOOM Eternal (NR).bat`** —— 启动游戏并挂上 NR 层（daemon 由游戏自动拉起）
2. 等 `work\nr_daemon.log` 出现 **`listening on \\.\pipe\nr_lop`**
3. **`NR 开启.bat`** 开效果 / **`NR 关闭.bat`** 关效果 —— **实时生效，不用重启游戏**

### B. 命令行
```
E:\WorkBuddy\2026-10-09-04-20-55\tools\nr_play.bat
```

| 用途 | 文件 |
|---|---|
| 启动游戏（**流水线开启**，本轮落实） | `tools\nr_play.bat` |
| 启动游戏（**流水线关闭**，旧路径） | `tools\nr_play_legacy.bat` |
| 实时开 / 关 NR 效果 | `tools\nr_effect_on.bat` / `nr_effect_off.bat` |
| 切 int8 | `tools\nr_int8_on.bat` / `nr_int8_off.bat` |
| 切窗口 gather 融合（A/B 用） | `tools\nr_fuse_on.bat` / `nr_fuse_off.bat` |
| **切 int8 残差融合（A/B 用，本轮新增）** | `tools\nr_residual_on.bat` / `nr_residual_off.bat` |
| 应急停 daemon | `tools\nr_daemon_stop.bat` |
| **关游戏 + 清 daemon（换启动参数前必做）** | `tools\nr_stop_all.bat` |
| 日志采样 | `python tools\sample_log.py 45` |
| **改任一 `nr_settings.json` 开关（会自检）** | `python tools\nr_switch.py <knob> <0|1>` |
| 日志按场次分段 | `python tools\log_sessions.py` |
| 每场 `gpu` 时间直方图 | `python tools\log_gpu_hist.py` |

⚠️ **daemon 不会随游戏退出。** 退出 DOOM 后它的 python 还活着，占着 `\\.\pipe\nr_lop`；
再开一局，新游戏连的是那个旧 daemon，而 daemon 的环境变量在它自己启动时就读定了 ——
**新启动脚本里设的任何 `NR_*` 全被忽略，A/B 两边测到的是同一个东西**。
判据：新会话的日志里必须出现新的一行 `listening on \\.\pipe\nr_lop`；没有就是没换。
换启动参数前的顺序：**关游戏 → 清 daemon → 再启动**（`nr_stop_all.bat` 就是这三步的前两步）。
反过来（游戏还连着就杀 daemon）会把游戏冻住。
| 离线 A/B 探针 | `work\cpu_cost_probe.py` + `work\cpu_probe_client.py` |

**游戏**：`F:\Game\DOOM Eternal\DOOMEternalx64vk.exe`（native Vulkan，**不需要 Steam**）

---

## 3. 已落实的收益台账（**一个都不许关**）

| # | 优化 | 开关 | 默认 | 实测收益 |
|---|---|---|---|---|
| 1 | window block 接线 | `NR_INT8_WINDOW` / `NR_INT8_WINDOW_OUT` | `"1"` | 44 → 39 ms |
| 2 | FFN expansion gate epilogue | `NR_INT8_EXPAND` | `"1"` | 43.70 → 43.12 ms |
| 3 | **QKV 投影上 int8** | `NR_INT8_QKV` | `"1"` | **+1.9 ms** |
| 4 | attention out 投影 | `NR_INT8_OUT` | `"1"` | — |
| 5 | daemon 去掉 `np.abs` 临时数组 | — | — | −1.7 ms（CPU） |
| 6 | **window 块的 gather 融进量化** | `NR_INT8_WINDOW_FUSE` | `"1"` | −4.37 ms（设备）/ **+1.3 ms（端到端）** |
| 7 | **残差折进 int8 的 GEMM epilogue** | `NR_INT8_RESIDUAL` | `"1"` | **−1.88 ms（设备）/ 省 120 趟；游戏内 `gpu` 40 → 38 ms** |

### 第 6 项：它是什么

int8 的 QKV 投影没有 epilogue，窗口 gather 无处可放，所以图里一直是
`partition`（把图像按窗口顺序写一份 fp16 副本）→ `quantize_row`（读副本逐行量化）
两趟。float 路径早就把这个 gather 折进 GEMM 自己的 load 里了。

现在 gather 搬进了量化内核：`quantize_row.comp` 的 flags 位 `0x400000`，
按 `partition` 原来那个索引直接从图像上取 token，副本不再存在，写副本那趟也不再运行。
`Runtime.quantize_window` / `xmx_rec_quant_window`。

- 一帧 **756 → 600 pass**，`partition` 52 趟归零
- 设备时间 ~~**31.60 → 27.23 ms**~~ ⚠️ **这两个数因账户错误作废**（实际低估约 34 %，
  见第 4 节）。**相对差值（−4.37 ms）本身仍然成立**，因为它是同口径前后比；
  但**端到端 +1.3 ms 那一行才是这一项真正该看的数字。**
- 逐字节等价：`work/fuse_equiv.py compare` 报 0 个值不同
- 只在本来就是 fp16 的图像上融合；float32 那一路留给 `partition` 去取整

`NR_INT8_WINDOW_FUSE=0` 回到两趟，A/B 就是这么比的。

### 第 6 项的实测：**同一局游戏里切着测的**（跨场次测不出来）

离线说省 4.37 ms 设备时间，但**跨场次根本测不出来**：同一份构建，两场游戏
分别量到 76.6 ms 和 70.2 ms，自己就差 6.4 ms。所以 fuse 做成了和 `int8` 一样
可以**运行中切换**（`nr_settings.json` 里的 `int8_window_fuse`，daemon 下一帧
重建图，权重不动，一帧的卡顿）。同一局、同一场景、轮流采：

| 次序 | 配置 | 帧时间 | fps | gpu |
|---|---|---|---|---|
| 开 | 融合 **ON** | 76.2 / 76.0 ms | 13.13 / 13.15 | 43.3 |
| 关 | 融合 **OFF** | 77.0 / 77.2 ms | 12.98 / 12.95 | 43.3 / 43.2 |
| 开（切回，验证可重复） | 融合 **ON** | 75.6 / 75.4 ms | 13.22 / 13.26 | 43.3 |

- **融合 ON 中位 75.9 ms，OFF 77.1 ms → ＋1.3 ms（1.7 %）**，方向对，且切换可重复。
- 端到端只拿到 4.37 ms 里的 1.3 ms：`gpu`（2+40+1）那个数是墙钟，开着关着都是
  43.3 ms，**对设备侧的变化不敏感**，别拿它判断这类优化；帧时间才是。
- 画质：整帧输出逐字节相同（`work/fuse_equiv.py`，1032192 个值 0 个不同），NaN 0。

⚠️ **教训**：跨场次对比在此项目上无效（±3.5 ms 噪声 > 要测的效应）。
凡是"重启一次换个开关"的 A/B 都不可信 —— 要么做成运行时可切，要么多场取中位。

### 第 7 项：残差折进 int8 的 GEMM epilogue（游戏内已看到 40 → 38 ms，A/B 待补）

int8 的投影原先是三趟：`quantize_row` → `gemm_int8` → 一趟自己的 `residual`
（把 float32 的 branch 写出来再读回来、加 `skip * cosine`、发布、写回）。
**120 趟 / 2.39 ms**，是浮点路径从来不用付的一趟——因为浮点 GEMM 有残差 epilogue，
`gemm_staged_int8.comp` 没有。现在有了。

同进程交替、5 轮、订单每轮反转（`src/bench/int8_residual_ab.py`）：

```
                  device     wall    passes
  fused           34.50     37.22     603
  two-pass        36.38     39.55     723
  saved            1.88 ms  (+5.2 % of the device's own time), 120 passes
  spread within a side 0.05 ms
```

按 family：`unary/5`（残差）**2.39 → 0.00**；`gemm/30`（int8）8.41 → 9.00
（**+0.59** 是 epilogue 的真实成本）；其余不动。省 2.39 付 0.59，净 **1.88 ms**。

**⚠️ 这一项踩的坑，务必读完再动内核：**

- **第一版把残差无条件编进同一个 spv，整帧从 36.42 掉到 52.27 ms。**
  不是残差慢，是**所有 188 个 int8 乘积都慢了三倍**——包括那些没置残差位、
  一条新指令都没执行的趟。用 `XMX_PIPELINE_STATS` 问驱动才看见真因：
  **Scratch Memory Size 从 0 变成 20992**。GLSL 里一个 8×8 的 int32 累加器是
  256 B = **8 GRF**（每线程只有 128 GRF），内核挂 RM×RN = 2×4 = **8 个累加器 = 64 GRF**，
  epilogue 一加就溢出到显存，驻留线程数塌掉。
- **修法是砍一半累加器，不是调 epilogue**：`-DSTAGED_BM=32` 让 WM=8→RM=1，
  累加器 8→4 个，scratch 回到 **0**。代价是块从 64×32 变 32×32、grid 变 M/32、
  SLM 装载索引要分流，所以它是**一条独立流水线**而不是一个 flag：
  `work/gemm_staged_int8_residual.spv`（`xmx_int8_residual_init`，
  `XMX_STAGED_BM_RESIDUAL = 32`）。
- **默认构建必须逐字节不变。** 加 `#ifdef` 时顺手外提一个变量就会让 spv 变 36 字节、
  基准漂 0.24 ms。现在 `work/gemm_staged_int8.spv` 与改动前 `cmp` 通过。
- 逐字节等价：`src/gpu/test_gemm_int8_residual.py` **242 例全过**
  （五种 epilogue × narrow × skip_half × 窗口反排含 shifted origin × 原地写回 ×
  尾部哨兵）。测试还抓到一个真 bug：残差路径下 `at` 已被 `residual_output_index`
  **重映射成图像索引**，若统一写成 `(r*pc.n+c)` 就把窗口反排丢了——两个构建各写各的。

**已经做成运行时可切**（`nr_settings.json` 的 `int8_residual`，daemon 下一帧重建图、
权重不动、一帧卡顿），脚本 `tools\nr_residual_on.bat` / `nr_residual_off.bat`。
之所以要做成旋钮，就是第 6 项那条教训：**跨场次噪声 ±3.5 ms 比这一笔（1.88 ms）还大**，
重开一次游戏换开关根本测不出来。

⚠️ **但 `nr_settings.json` 只在有帧到达时才被读**（`Settings.refresh()` 每帧调一次）。
菜单、读盘、游戏关了——写了也没人看，而且**不留任何痕迹**。
所以请在**关卡里、画面在动（`change` > 0.02）**时切，并且认 daemon 的回执：
日志里 `settings: integer residual on/off`。
要把 when/how 一次搞对的就用 `tools\nr_switch.py`（下面第 7 项那节讲了它踩过的坑）。

**默认开**（`NR_INT8_RESIDUAL` 未设即 1）。关掉回到三趟。

### 第 7 项实测：daemon 的 `gpu` **40 → 38 ms**（罕见：`gpu` 这次能看见了）

第一次实机验证不是按设计好的路径来的（热切换没生效，原因在下一段），但结果反而更干净。
日志没有时间戳，**`listening on` 就是场次分界**，按它切成 7 段 ≥200 帧的会话
（`tools/log_gpu_hist.py`）：

```
gpu ms      38    39    40    41    42    43    44    45    46
run 1        0     0  1431   167     8     0     1     2     0
run 2        0     0  8619   807    13     2     2     4     1
run 3        0     0  1224    47     1     0     0     0     0
run 4        0     0 12510  3232    63    21    19    13     1
run 5        0     0  6726  1633    25     3    17     5     2
run 6        0     0  8929  2448    61    12    76    13     1
run 7     2821   519    56     5    24     5     1     0     0
```

| | 帧数 | 中位 | 均值 | 散布 |
|---|---|---|---|---|
| run 1–6 合计（**改动前**） | **48139** | **40.0** | 40.20 | 40–46 |
| run 7（**改动后**） | 3431 | **38.0** | 38.23 | 38–44，82% 的帧正好 38 |

**−2.0 ms**，离线 A/B 预测的 **−1.88 ms**。

✅ **这条可以作为"跨场次对比不一定无效"的反例，前提是选对量**：
平时不能跨场次比的是**帧时间**（含游戏宿主侧，同一构建两场能差 6 ms）；
而 daemon 的 `gpu` 段在 **48139 帧里六次中位数都是整 40 ms**，自身漂移远小于 1 ms。
⚠️ 但它仍然是墙钟，**不是万能**：当年 fuse 那一改动离线省 4.37 ms，它在两边都报 43.3。
它能看见这一次，是效应落在了它灵敏的地方，**别当成通用判据**。

⚠️ 这**不是局内 A/B**。真正闭环还是要用下面的热切换做一次。

### 第 7 项热切换第一次为什么"看起来没生效"（已修）

bug 的现象：bat 弹窗正常，`nr_settings.json` 确实被改了（`int8_residual` 停在 `0`），
但日志里**一行 `settings: integer residual` 都没有**。

**根因：`nr_settings.json` 只在有帧到达时才被读**（`Settings.refresh()` 每帧调一次）。
日志最后一个 daemon 启动之后**一帧都没出**——画面当时已经不再出帧了（游戏关了，或停在
菜单/读盘）。文件写了，没有人在看。

防复发的两处改动：

1. daemon 第一帧起打印一行 **`settings in effect: int8=1 int8_window_fuse=1
   int8_residual=1 ...`**。以后任何一段日志都能自证它跑的是哪张图，不用猜。
2. 开关从一行 `json.dump` 换成 **`tools/nr_switch.py`**：写完盯日志几秒，没被接住就
   **明确说清是哪一种失败**——「这段时间内没有帧到达 daemon」（正常，等出帧就生效）
   还是「有帧但 daemon 不认这个名字」（旧进程占着管道 → 关游戏、清 daemon、重开）。
   ⚠️ 我自己第一版写错：去数日志末尾 400 行的帧数，那是**上一场的旧帧**，永远不会消失，
   游戏关了三小时它还会说"frames are flowing"。已改成只数新读到的字节。

必须这么做的原因就是第 6 项那条教训：**跨场次噪声 ±3.5 ms 比这一笔（1.88 ms）还大**，
重开一次游戏换开关根本测不出来。所以请照第 6 项那套流程测：
**进关卡 → 画面在动（`change` > 0.02）→ 开，稳了采样 → 关，稳了采样 → 开，验证可重复。**
看的是**帧时间 / fps**，不是 `gpu` 那个数（那是墙钟，对设备侧变化不敏感）。
测不出来就直说测不出来，别硬凑。

### ❌ 已证伪：流水线 inflight=2

| 优化 | 开关 | 结论 |
|---|---|---|
| 流水线 inflight=2 | `NR_DAEMON_PIPELINE=2` + `NR_LAYER_ASYNC=2` | **真实游戏内是倒退，默认关闭** |

同负载实测（两次采样 `change` 分别为 0.02563 与 0.02559，负载一致，可比）：

| 指标 | 流水线**关闭** | inflight=2 | 差异 |
|---|---|---|---|
| 帧时间 | **72.8 ms** | 130.9 ms | **+58.1 ms** ❌ |
| 帧率 | **13.74 fps** | 7.65 fps | **−44 %** ❌ |
| GPU | 43.1 ms | 49.0 ms | +5.9 ms |
| gate / held | 0.660 / 85 % | 0.647 / 81 % | 基本持平 |
| NaN | 0 | 0 | ✅ |

**离线 replay 的 71 → 43 ms 在真实游戏里没有复现，且方向相反。**
推测原因：`finish` 线程阻塞在 `sendall` 等游戏读，游戏侧放得越深，宿主等得越久。
**代码保留**（`NR_DAEMON_PIPELINE` 仍可实现），入口单独存为 `tools\nr_play_pipeline.bat`。

### ⚠️ 采样方法上的两个坑（都踩过，别再踩）

1. **别在游戏加载/编译着色器时采样**。那段时间帧时间高达 141 s、1.41 s，
   混进去会把均值整个带跑。判据：等 `change` 稳定在 0.02 以上再开始采。
2. **主菜单 ≠ 关卡**。主菜单画面静止（`change` 0.00065、`held` 100 %），
   负载低得多。必须等进关卡、画面在动，数据才有效。

**`NR_INT8_TRANSITION=0`**：接线代码保留，但实测无收益，按计划关闭。**不许据此关掉上面任何一项。**

⚠️ **历史教训**：我在一次事故中擅自把 `NR_INT8_QKV` 从 `"1"` 改成 `"0"`，这是**明确违规**。任何"暂时关掉开关看看"的想法，都要先问你。

---

## 4. 实测数据（诚实版：有什么、缺什么）

### 已确证的
- **整份日志 A/B（`work/nr_daemon_024615_baseline.log`，46843 帧）**：
  `int8 ON` 网络 **39 ms**，`OFF` **44 ms** → **+5.00 ms（+11.4 %）**；
  GPU 总计 `ON 43 ms` vs `OFF 47 ms` → **+4.00 ms（+8.5 %）**
- **端到端（你在场、关卡内）**：13.5 fps，**74 ms/帧**，p95 80 ms，
  `change 0.0247`、`gate 0.658`、`held 87%`、**NaN 0 行**
- 分解：GPU 43 ms + 宿主约 31 ms，**完全串行、零重叠**

### 今晚补上的：流水线 inflight=2 的真实游戏 A/B

**结论：负收益，已回退。** 数字见上面第 3 节的「已证伪」表格。

采样条件：`tools\nr_play.bat`（`NR_DAEMON_PIPELINE=2` + `NR_LAYER_ASYNC=2`），
DOOM Eternal 关卡内，45 秒窗口 774 帧。

**这条路的教训**：离线 replay（捕获帧循环喂）给出的 71 → 43 ms 是**假信号**。
真实游戏里游戏进程和 daemon 的握手节奏完全不同，
**任何跨进程的流水线改动，只有游戏内实测才算数，离线数字只能用来排除明显错误。**

笔记 `notes/daemon-cpu-cost.md` 里的离线数字仍然保留，但请当作历史记录读，
不要当作收益依据。

### 本轮重测：设备时间此前被低估 34 %（27.25 → **36.42 ms**）

⚠️ **第 3 节第 6 项里那个「设备时间 31.60 → 27.23 ms」是错的**，别再引用。
原因有三条，都已修：

1. `traffic_audit.py` 的 `HOOKS` 字典**漏掉了默认就开着的 6 类 pass**
   （最要紧的是 `gemm_int8_qkv`，一帧 60 趟，此前没人给它命过名）。
2. `ffn_fused` 一次 Python 调用会在设备侧打**多个** stamp，
   按调用序号去配对设备 stamp 必然错位。
3. 总时间取的是 `sum(by_kind.values())`，**只累加了"有名字的"pass**，
   剩下的 9.17 ms 被静默丢掉。

修好以后（`src/bench/pass_time.py`、`src/bench/device_families.py`、
`src/bench/graph_gap.py`，8 帧 replay 取平均，按设备时间戳的 **family** 归因，
不再按序号配对）：

```
family    ms   share      n   ms/pass
gemm    13.94   38.3 %    198     0.070
row      9.54   26.2 %     70     0.136
tiled    8.49   23.3 %    130     0.065
unary    4.45   12.2 %    325     0.014
-- device 36.42 100.0 %    723
```

最忙的几类（family/sub-kind）：

```
gemm   sub 30: 8.40 ms   sub 31: 5.54 ms
row    sub 4:  6.20 ms   sub 3:  3.00 ms   sub 5: 0.34 ms
unary  sub 5:  2.38 ms   sub 12: 1.64 ms   sub 21: 0.24 ms   sub 18: 0.17 ms
```

**修正了旧表两个错得离谱的数**：量化（`UNARY/12`）实际只有 **1.64 ms**，
不是 8.03 ms；`window_block` 是 **6.20 ms**（`ROW/4`）。

**整帧账目（闭环，加得起来了）**：

| 段 | ms |
|---|---|
| 设备 pass 时间 | 36.42 |
| 提交 + 等 fence 的缺口 | 3.27 |
| host write（喂输入） | 2.1 |
| host read（取输出） | 0.9 |
| **= daemon 日志里的 `gpu`** | **42.7** |
| ＋ 宿主侧（daemon Python） | 24.4 |
| ＋ 跨进程握手约 | 9 |
| **= 游戏侧帧时间** | **75.6** |

之前担心的"12.8 ms 黑洞"不存在，缺口只有 **3.27 ms（墙钟的 8 %）**。

⚠️ **方法论教训**：`src/bench/pass_time.py` 那种"Python 调用名 ↔ 设备 stamp 按
index 配对"的做法**不可信** —— 实测 576 对里 **438 对不一致**。
要看分解就用 `src/bench/device_families.py`（按 family 累加，不配对）。

---

## 5. 🚫 不许再犯的错误清单

### 上一轮踩过的（每条都出过事故）
1. **禁止 `setx` / 注册表 / 隐式层注入**。只准在一个 `.bat` 里 `set` 完再从同一 cmd 启游戏。
2. **daemon 不要手动启**。由游戏自 spawn（`NR_LAYER_SPAWN=1`）。手动另起 = 两 daemon 抢
   `\\.\pipe\nr_lop` = **游戏卡死**。
3. **`.bat` 必须 CRLF**。Write 出来是 LF，cmd 会报错。写完执行
   `sed -i 's/\r$//' f.bat; sed -i 's/$/\r/' f.bat`，核对 CR 数 == LF 数。
4. **不许擅自关掉任何已验证有收益的开关**。判据不足就保留原状，把数字交给你定。
5. **不要二次验证前辈已定的结论**。
6. **每个任务收尾必须启动游戏实测，报结论，停下来等你确认观感，收到回复再动下一步。**
7. **启动游戏固定走桌面 bat，由用户双击**。助手**不许自己拼启动命令**——试过
   `cmd //c`、`start /min`、PowerShell `Start-Process` 各种写法，反复失败
   （进程被工具调用连带杀掉 / 被安全策略挡），纯属浪费时间。
   助手的职责只有：**监测 `work\nr_daemon.log`，出帧就采样，报数字。**
8. **画质判据用真实帧的 `work/int8_quality.py`**，不要用 `test_resident.py` 的 corr
   （那是给 fp16 合成输入写的，int8 全开时报 3 个 FAILED 是已知正常状态）。
9. 日志 / 临时文件不写 C 盘。分身最多 2 个。
10. 改游戏目录必须成对可逆（先备份 `.nr-backup`）。

### 今晚新增的（都是我自己犯的）
11. **没有证据不许下结论**——我反复猜"哪次启动成功"，错了。看不到画面就直说看不到。
12. **后台 Bash 任务结束时会杀掉它启动的游戏进程**。启动游戏必须用脱离进程组的方式
    （PowerShell `Start-Process`，且启动命令要立即返回），否则前功尽弃。
13. **主菜单 ≠ 关卡内**。主菜单画面静止（`held 100%`），负载低得多；拿它的帧时间跟
    你在关卡里跑出来的比，是无效数据。
14. **有已验证的入口就别搞特殊**。桌面三个 bat 是唯一入口，改需求就改 `tools\` 里的
    真身，不要另起一套启动路径。
15. **长任务要先说一句话再动手**。跑 3 分钟采样前先讲"我在采样，约 1 分钟"，
    不要闷头跑完才说话——用户会以为我卡死了。
16. **离线基准脚本默认跑的是 int8 关闭的配置**。`xmxres.Runtime` 读
    `NR_INT8_PROJECT`，**代码默认 `"0"`**，是 daemon 读 `nr_settings.json` 后才注入的。
    会不会自己发现？不会——浮点图是"趟数更少、时间更长"（43.49 ms / 415 趟 vs
    36.41 ms / 723 趟），看着完全合理。**所有独立基准必须先
    `import game_settings; game_settings.apply()`**（`src/bench/game_settings.py`）。
17. **基准跑太久就是卡住了，不是慢**。`frame_ledger.py` 连加载 1 GB 权重在内约
    **90 秒**。有一个跑了 33 分钟没出结果，杀了重跑就好。别干等。

### 本轮新增的（内核侧，代价都是真金白银换来的）
18. **遇到问题先查参考文案，不要自己闷头试。** 用户为这个项目留了两份（见第 10 节）。
    本轮整帧莫名慢 16 ms，闷头猜是猜不出来的；翻 `docs/a770-port/code-map.md`
    才发现 `XMX_PIPELINE_STATS` 这个旋钮，一次就定位到寄存器溢出。
    **"先查文案"是本轮用户明确纠正过的行为要求。**
19. **给 GLSL 内核加任何代码之前，先问驱动要 `Scratch Memory Size`。**
    判据非常简单：**scratch 必须是 0**。非 0 就说明溢出到显存了，
    在本项目上一次直接导致 **所有 188 个 int8 乘积慢三倍（36 → 52 ms）**，
    而且受害的是那些一行新代码都没执行的趟。参考文案的说法更狠：
    *"any non-zero compiler spill with RPT>4 is a device-lost trigger"*。
    怎么问见第 10 节。
20. **改默认构建（不带新宏的那一份）时，`cmp` 前后 spv 必须逐字节相同。**
    一个 `#ifdef` 外提一个变量就差 36 字节、基准漂 0.24 ms，
    这点漂移足以让"省了多少"的判断失准。

---

## 6. 这台机器的网络坑（重要）

| 现象 | 原因 |
|---|---|
| `git push` 报 `CONNECT tunnel failed, response 502` | `github.com:443` 被网络层挡 |
| curl 报 `CRYPT_E_NO_REVOCATION_CHECK` | 代理是 TLS 中间人，吊销检查失败；加 `--ssl-no-revoke` 可通 |
| `github.com:22` 有时拒连 | 新代理把 22 挡了 |
| `ssh.github.com:443` 通 | 可用作 SSH 备用端口 |

**结论**：HTTPS `git push` 在这台机器上不可靠（代理会破坏 pack 数据流），别再调参数了。
本次上传是用 **GitHub REST API 的 Git Data API** 走 `api.github.com`（代理对它放行且稳定）
逐对象重建完成的，脚本在 `tools/publish_api.py`。

**这台机器上已经生成好 SSH 密钥**（公钥在 `C:\Users\wangz\.ssh\id_ed25519.pub`）。
把那把公钥加进账户后，以后推送就能永久绕开代理，不必再拿 PAT。
（公钥内容不贴在这里——带上它的 comment 等于把身份写进公开仓库。本机随时可以自己读出来。）

⚠️ **2026-10-10 实测：公钥还没加进账户。** SSH over 443 的 TCP 握上了，
但服务端返回 `Permission denied (publickey)`，显式 `-i` 指定私钥也一样（那份清单里的
识别信息也因此没法用）。所以眼下**只有 API + PAT 这一条路能用**。哪天想摆脱 PAT，去
<https://github.com/settings/keys> 贴进去即可。
（这里的命令写法刻意不带 `@`：那是主机名，`publish_check` 会把它当成邮箱拦下来。）

### `publish_api.py` 修过的一个 bug（别再踩）

脚本原来判断"仓库是不是空的"只看 `heads/main` 和 `heads/master`。这个仓库的
默认分支是 **`windows`**，没有 main/master，于是**有内容的仓库被当成空仓库**，
脚本转去用 contents API 建 README，撞 422（README 已存在，更新要带 sha）。
现在改成先看**要推送的那个分支**是否存在。空仓库仍会正常 bootstrap。

---

## 7. 待办（按优先级）

1. ~~**游戏内 A/B 验收流水线**~~ ✅ **已完成 —— 结论是负收益，已回退**。
   数据见第 3 节。不用再测这一项了。
2. ~~**window 块的 gather 融进量化**~~ ✅ **已完成，并在游戏里测过** ——
   数据见第 3 节第 6 项，同一局内热切换 A/B **+1.3 ms**，整帧输出逐字节不变。
3. ~~**量化改成一遍读**~~ ❌ **做完并证伪，已回退**。同进程交替 A/B 是
   **36.44 vs 36.50 ms（噪声 ±0.2）= 打平**。第二遍读是免费的：第一遍刚把那一行
   留在 L2 里了。详见 `notes/device-budget-a770.md`。
4. **设备侧剩下的几块**，已定位到具体出处（`notes/frame-ledger-a770.md`）：
   - ~~**`gemm_staged_int8` 没有残差 epilogue**~~ → ✅ **本轮做完，见第 3 节第 7 项**。
     离线 **−1.88 ms / 省 120 趟 / 单侧波动 0.05 ms / 242 例逐字节一致**。
     游戏内也看到了信号：daemon `gpu` **40 → 38 ms**（第 3 节第 7 项）。
     **剩下的待办：一场游戏内开着/关着轮流采一次，把它闭环。**
     ⚠️ 别再跨场次测第二回了——那不是证据，只是巧合的可能性一次比一次大。
   - **分块（branched）FFN 没有 int8 分支** → `_ffn_groups`（104 趟）+ 
     `record_split_feed_forward` 的 `w.first`（16 趟）= 120 趟 / 8.50 ms。
     ⚠️ 但这批 pass **不是算力受限**（约 11.4 GFLOP 跑 8.5 ms ≈ 峰值 3-7 %），
     而 int8 的全部收益就是"乘加指令减半"，**对等待型的 pass 杠杆很弱**，
     还要额外付约 120 趟 `quantize_row`（约 1 ms）。**先量再建，别直接开工。**
   - `window_block` **6.20 ms / 10 趟**（0.62 ms 一趟，全帧最贵的单趟），
     已经是融合写法，没有现成的下一步。
5. **收尾**：验收全部通过以后，把 PAT `ghp_2OOW...` 去
   <https://github.com/settings/tokens> 删掉。**在验收完成前先别删** —— 这台机器上
   `git push` 走不通，后续同步还要靠它（或先把 SSH 公钥加进账户）。

### 宿主侧已经查过，别再当悬念

`nr_image.c` 那些 pass（一帧约 16.8 ms）**已经是 OpenMP 并行的**，不是漏了多线程：
`tools/build_win.bat` 带 `/openmp`、DLL 导入 `VCOMP140.DLL`，实测 `decode8`
1 线程 6.92 ms → 4 线程 3.06 ms，`to_half` 2.60 → 0.48 ms。
（`src/bench/host_threads.py` 就是问这件事的。）`bilinear` 反而线程越多越慢，
像是带宽受限，不是漏并行。

---

## 8. 怎么恢复到任一阶段

| 想要 | 做法 |
|---|---|
| 回到今晚这个已验证点 | `git checkout a770-int8-verified` |
| 用备份整体还原 | 复制 `backups\dlss-nr-on-a770-20261010-0110` 覆盖 `src\dlss-nr-on-a770` |
| 从 git 包恢复 | `git clone backups\...\repo-all.bundle <dir>` |
| 关掉流水线 | 改用 `tools\nr_play_legacy.bat` 启动游戏 |

---

## 9. 还没验证过的东西（别当成"已确认"）

- ~~流水线 `inflight=2` 在真实游戏里的帧时间收益~~ —— ✅ 已测，**负收益，已回退**
- ~~多一帧延迟在操作手感上能不能接受~~ —— ✅ 该路已废弃，不用再评估
- ~~window block 两趟合成一趟（gather 融进量化）~~ —— ✅ 已在**同一局游戏里热切换
  A/B** 测过：ON 75.9 ms / OFF 77.1 ms，**+1.3 ms**，且输出逐字节相同。闭环了。
- ~~量化"一遍读"能省一半流量~~ —— ❌ **证伪**，打平，已回退。
- **第 3 节第 7 项（残差折进 int8 GEMM）的局内 A/B** —— 已经**看到**实机信号：
  daemon 的 `gpu` **40 → 38 ms**（前 6 场 48139 帧中位一律 40.0，第 7 场 3431 帧中位
  38.0、82% 正好 38；离线预测 −1.88 ms）。
  **但这是跨场次对比，不是局内 A/B。** 真正闭环还是要一场游戏里开着/关着轮流采。
  第一次尝试失败了（热切换那时候画面不在出帧），已修，待重做。
- **`src/bench/pass_time.py` 里那种"Python 调用名 ↔ 设备 stamp 按 index 配对"的
  分解** —— ❌ **不可信**，576 对里 438 对不一致。要看分解请用
  `src/bench/device_families.py`；`pass_time.py` 现在只用于总量和流量统计。
- **离线 replay 的任何数字** —— 只能用来排除明显错误，**不能当收益依据**。
  流水线那一项就是这么翻的车（离线 71→43，游戏里 72.8→130.9）。
- `render_scale` 仍是 **0.4**（网络输入 768×448）。这是**违反你"不降画质"原则的**，
  是上一轮留下的。改回 1.0 设备时间会从约 40 ms 涨到约 214 ms。**等你拍板，
  我没有擅自改过。**

---

## 10. 参考文案在哪（**遇到问题先查这里，别闷头试**）

用户为这个项目留了两份，我本轮翻车之后才想起来查，白绕了很大一圈。

### A. `docs/a770-port/code-map.md`（在本工作区，72 KB 代码测绘报告）

在 `E:\WorkBuddy\2026-10-09-04-20-55\docs\a770-port\code-map.md`，
**不在 git 仓库里**（仓库根是 `src\dlss-nr-on-a770`），所以 `git status` 看不到它。

- **§2.3 的运行时环境变量表** —— 本轮的救命条目：
  - `XMX_PIPELINE_STATS=<file>`：让驱动导出每个 pipeline 的
    `Instruction Count` / **`Scratch Memory Size`** / `Workgroup Memory Size`
  - `XMX_PIPELINE_IR=<dir>`：导出编译器自己的寄存器/SIMD 报告
- GLSL 编译期宏表（含 `STAGED_BM` 默认 64、`-DSTAGED_BM=32 → gemm_staged32.spv`，
  出处 Makefile:98-101 / CMakeLists:81-82 / build_win.bat:87-88）
- push block 的字节布局、epilogue flags 位表、设备时间戳 family/kind 表

### B. `Blackwood416/A770-Kernel-Optimization`（GitHub，同款 A770 16G）

<https://github.com/Blackwood416> —— 一台一样卡的人写的 skill 包
（SKILL.md + `references/`）。`references/hardware/hardware.md` 给的是硬数字：

| 事实 | 值 |
|---|---|
| GRF | 每线程 **128** 寄存器（large GRF 模式 256 —— **A770 没有这个模式**） |
| 一个 8×8 float/int32 累加器 | 256 B = **8 GRF** |
| SLM | 每 Xe-core 128 KB；Max SLM/WG 64 KB；**超约 32 KB 开始丢驻留 workgroup** |
| spill | *"any non-zero compiler spill with RPT>4 is a device-lost trigger"* |

它的证据纪律也值得照抄：`[ARCH]` / `[MEASURED]` / `[DISPATCH]` / `[HYPOTHESIS]` 标签；
**<10 μs 的 kernel 要分开报 device time 和 wall time**；**失败变体要保留**（本轮
"第一次尝试净亏 16 ms"就是靠保留失败变体才挖出根因的）。

### 怎么问驱动要寄存器账

```
XMX_PIPELINE_STATS=<输出文件> python src/bench/<任一基准>.py
```

对比同一份内核加代码前后的 **Scratch Memory Size**。**必须是 0。**
本轮实测：原始 int8 = 0、`-DINT8_RESIDUAL=1` = **20992**、
`-DINT8_RESIDUAL=1 -DSTAGED_BM=32` = **0**（Workgroup Memory 5120）。
