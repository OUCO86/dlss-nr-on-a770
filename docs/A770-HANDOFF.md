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
| 应急停 daemon | `tools\nr_daemon_stop.bat` |
| **关游戏 + 清 daemon（换启动参数前必做）** | `tools\nr_stop_all.bat` |
| 日志采样 | `python tools\sample_log.py 45` |

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

**已经生成好 SSH 密钥**，公钥加进 GitHub 后，这台机器以后推送就能永久绕开代理：
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODtt2c4snVUP5LSkjDRQa+Wt8w+Q/7yHtcfJje6l/99 OUCO86-A770
```
（私钥在 `C:\Users\wangz\.ssh\id_ed25519`）

⚠️ **2026-10-10 实测：这个公钥还没加进 GitHub 账户。** `ssh -T -p 443 git@ssh.github.com`
走通了 TCP，但返回 `Permission denied (publickey)`，显式 `-i` 指定私钥也一样。
所以眼下**只有 API + PAT 这一条路能用**。哪天想摆脱 PAT，去
<https://github.com/settings/keys> 把上面那串公钥贴进去即可。

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
4. **设备侧剩下的三块**，已定位到具体出处（`notes/frame-ledger-a770.md`）：
   - **`gemm_staged_int8` 没有残差 epilogue** → int8 路径每个投影多一趟
     `residual`，**120 趟 / 2.38 ms**。浮点路径的 `gemm_residual` 就是现成模板。
     **这一项形状最清楚、风险最可控，建议先做。**
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
- **`src/bench/pass_time.py` 里那种"Python 调用名 ↔ 设备 stamp 按 index 配对"的
  分解** —— ❌ **不可信**，576 对里 438 对不一致。要看分解请用
  `src/bench/device_families.py`；`pass_time.py` 现在只用于总量和流量统计。
- **离线 replay 的任何数字** —— 只能用来排除明显错误，**不能当收益依据**。
  流水线那一项就是这么翻的车（离线 71→43，游戏里 72.8→130.9）。
- `render_scale` 仍是 **0.4**（网络输入 768×448）。这是**违反你"不降画质"原则的**，
  是上一轮留下的。改回 1.0 设备时间会从约 40 ms 涨到约 214 ms。**等你拍板，
  我没有擅自改过。**
