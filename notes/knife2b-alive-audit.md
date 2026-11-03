# knife2b —— 刀 2 续（2026-11-03 会话，被暂停令打断在"第 1 步的 GPU 复核之前"）

**本文件 = 下次开工第一读。** 写作时点 2026-11-03 10:2x（+08:00），掉电安全模式落盘。

## 0. 会话状态与现场（10:2x 实证 md5）

- 分支：主检出 `E:/DSH/dlss-nr-on-a770` = `ds-quality-relax-2026-11-02` @ **`c516627`**，`git status --porcelain` = **0 行（CLEAN）**。工作树另有两只 detached worktree：`E:/DSH/wt-08e8b62`（= 转正件 ABB969FE 的源码基座）、`E:/DSH/wt-73f73b2`。
- **本会话 GPU 进程 = 0**：`knife2_probe.exe` **一次都没跑**、`nr_replay_now` **一次都没跑**、没有任何 stage、没有新编译。`sycl-cache-k2` 实测 **0 个文件**（= probe 从未跑过的旁证）。
- 卡的热状态：**冷**（机器重启后无负载；本会话只做了 host 侧读码 + CSV 分析，GPU 占用 0 分钟）。下次开工**不需要再等冷却**，但跨配置对照仍须同热交替。
- `LOP-Win64-Shipping.exe` 计数 = **0**（`GameInputRedistService/GameInputRawInputProxy` 是系统服务，不算 BUSY —— §47 已记过）。
- 未 commit / 未 push（用户自己提）。

md5（10:2x 全部核过，与 §51④ 一致 ⇒ 现场未被我动过）：

| 文件 | md5 |
|---|---|
| `E:\DSH\out\libxmx.dll`（加载位） | `ABB969FE4AAF0F94AA03C3F53781EDD0` ✓ |
| `E:\DSH\oneapi\libxmx_sycl.dll` | `ABB969FE4AAF0F94AA03C3F53781EDD0` ✓ |
| `E:\DSH\dumps\bk.1301.bin` | `DD49827DD33A7EF07C2C17892F18970D` ✓ |
| `E:\DSH\dumps\bk.1301.skip.bin` | `DD49827DD33A7EF07C2C17892F18970D` ✓ |
| `E:\DSH\dumps\bk.1301.pre-skip-1a.bin` | `249A46F374E98EB5FF5AD5E3A38EBC55` ✓ |
| `E:\DSH\oneapi\knife2_probe.exe` | `B5A82BE2B42BD16E2EB16B870698B4A0` ✓（仍未跑） |
| `E:\DSH\builds\libxmx_rt2.dll` | `9FDD0E93336F3C7445CFC0A49A4A5CF2` ✓ |
| `E:\DSH\oneapi\nr_replay_now.exe` | `A55B1F3435FD1E64117778199CF9EE0A` |
| `E:\DSH\tools\rt_per_closure.csv` = 仓内同名 | `F00CBB1E8525B5E09DEFCC9AD8FD786D` |
| `E:\DSH\dlss-nr-on-a770\tools\knife2_sites.csv` | `E8E968F0B330AAE323853A7974431A5B` |
| `E:\DSH\dlss-nr-on-a770\tools\chain_map.csv` | `D5EDE262DAC68EFBE6B1FFC5B605ABC9` |

## 1. 第 1 步（§51⑦ 疑账）：**静态部分已闭合 ⇒ 判决 = 我的假设成立（还差 GPU 复核那一步）**

### 1.1 机制找到了，就在出货源码里（不用 GPU 就能定）
`src/bench/sycl/libxmx_sycl.cpp:647-688` = `s6_take_residual()`（S6-1a 块驻留 FFN 链的收口处）。`:676-678` 原文：

```
// THE RULE: all six or none. Five no-ops + one fused launch.
g_cmds[g.cq1] = [](){}; g_cmds[g.cb1] = [](){}; g_cmds[g.cq2] = [](){};
g_cmds[g.cb2] = [](){}; g_cmds[g.cq3] = [](){};
```

- 开关 `NR_S6_FFN` **默认 ON**（`:556-559`：`getenv("NR_S6_FFN") ? atoi!=0 : true`），逃生门 `NR_S6_FFN=0` ⇒ `s6_on()` 假 ⇒ 所有 guard 死 ⇒ **完全回到 pre-S6 老路**（`out\DEPLOY.md5.txt:22-24` 记的正是这次转正：`:559` 默认 false→true）。
- 被 no-op 的五条腿 = `QUANT, BATCHED, QUANT, BATCHED, QUANT` ⇒ **每条 FFN 链正好 2 发 batched 被吞**，链尾的 `GEMM_INT8_RESIDUAL` 闭包改跑融合核（所以它 0.42-0.58 ms，比 pre-S6 的单发残差贵）。
- ⇒ **假设成立：那 40 发不是厂商意义上的死代码，是被已出货的 1a 顶替成 no-op。** `[bwide]` 0 次 = 它们连 record 分支都没进（闭包体已被替换成空 lambda），不是"wide 让它们便宜"。

### 1.2 数量对上了（**双向 bijection**，脚本 `s6/k2b_chainmap.py` → 输出存 `s6/k2b_chainmap.txt`）
- `tools/rt_per_closure.csv` 里 `family=xmx_rec_gemm_int8_batched` 且 `M ∈ {32640, 8160}` 的行 **正好 40 行**，ms 全部 **0.0020-0.0044**（40 行合计 **0.0846 ms** = 计时地板，与"闭包体为空"一致）。
- 这 40 行 = **19 条链 × 2 发**（chain_map 里 `op_seq` 含 2×`GEMM_INT8_BATCHED` 的链恰是：0,1,2,3,4,5,6,7,8,41,42,43,44,45,46,47,48,49,50）**+ 1 对链外闭包**（`c14/c16`，属 closures 12-18 那段 chain_map 未覆盖的头段）= **20 对 = 40 发** ✓
- 反向核对：chain_map 52 链里凡有 2 发 batched 的链，**无一遗漏**都在这 40 行里 ⇒ 数量不是巧合。
- 逐对明细（closure 号 → 形）：`c25/c27`(chain0) `c36/c38`(1) `c47/c49`(2) `c61/c63`(3) `c72/c74`(4) `c83/c85`(5) `c94/c96`(6) `c105/c107`(7) `c116/c118`(8) `c568/c570`(41) `c579/c581`(42) `c590/c592`(43) `c601/c603`(44) `c612/c614`(45) `c623/c625`(46) `c636/c638`(47) `c647/c649`(48) `c658/c660`(49) `c669/c671`(50) `c14/c16`(链外)。每对里**前一个 = `sa=0` 广播形**（M32640: N=128 K=64 b2 / M8160: N=128 K=128 b4 = cb1），**后一个 = wide 合法形**（N=32 K=128 b2/b4 = cb2）。
- plan 行号（chain_map 的 `plan_line`）：chain0=5351, 1=5375, 2=5397, 3=5419, 4=5444, 5=5466, 6=5488, 7=5510, 8=5532, 41=6389, 42=6413, 43=6435, 44=6457, 45=6479, 46=6501, 47=6523, 48=6547, 49=6569, 50=6591。
- **0/40 落在 §2 说的编译期跳块链里** ⇒ T2 跳块不是这 40 发的机制，S6 是。

### 1.3 ★ 必须修正任务书的预期数（否则会误判成"部分成立"）
- `[bwide]` 只在 `wide_ok` 命中时打（`:3112-3120`）。40 发里**只有 20 发**（cb2）满足 wide 形；另 20 发（cb1，`sa=0`）走 gather 分支 ⇒ 打 `[bpack]`。
- `[bpack]` 有 **`bgp <= 8` 打印上限**（`:3157`）⇒ B 侧最多 8 行，**不能拿它的行数当发数**。
- `nr_replay_now` 一个进程 = **4 个 run**（`s6/K2_rt_run1.log`：`run 0..3: 136.18-136.44 ms (691 passes)`）⇒ **B 侧 `[bwide]` 预期 ≈ 20 × 4 = 80 行**（若 wide 分支只在 record 期走一次，则 ≈20 行；按行数 ÷ run 数核）。A 侧 = **0**。
- ⇒ 判读线（下次照这个报，别含糊）：
 ① B 侧 `[bwide]` ≈ 20/发·每 run 且那 40 发 ms 从 0.002 跳到 0.1x ⇒ **假设成立**（P8-b 的 wide-merge 在 shipped 路径上已被 1a 取代 ⇒ "已出货合并机制的既有回收"按 ≈0 重记）；
 ② B 侧仍 0 ⇒ 假设否证 ⇒ 停下回报；
 ③ B 侧有但每 run 不是 20 ⇒ 部分成立，报差额链号。

### 1.4 GPU 复核 = **未跑**，命令已备好并过语法检查
```
pwsh -NoProfile -File E:\DSH\s6\K2b_ab.ps1        # A,B,A,B 同热交替；产物 s6\K2b_{A,B}{1,2}.log + *_rt.txt
& 'C:\Users\wangz\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe' E:\DSH\s6\k2b_rtcmp.py
```
- `K2b_ab.ps1` = `850EFEAE7A0ECAE5CF7340B8C57B13F3`（**PARSE OK、未跑过**）：自带 LOP 占用闸、金标 md5 前后打印、`rtcsv 行数 < 691` 即 STOP（防 §47 那种空日志）、本批时长入账。
- `k2b_rtcmp.py` = `FC93716A894954A80B740B9EBAD0133E`（py_compile 过）：按 4 个 run 分桶，直接给 40 发疑账 + S0/S1/S2 各 16 站在 A/B 两侧的 ms 分布与 `[bwide]/[bpack]` 计数。
- 用的件 = `builds\libxmx_rt2.dll`（含 rtcsv hunk），**直接把 dll 路径喂给 `nr_replay_now.exe` ⇒ 不需要 stage 到 oneapi**（`WBGA_ga_gates.ps1:21` 先例）。跑完 `oneapi\run_timing.txt` 会被覆盖成默认侧 dump（§51④ 本来就要覆盖它）。

## 2. ★★ 本次最大的新发现（比疑账更要紧，直接改刀 2 的经济账与门的口径）

**转正件带"编译期跳块默认"，而它不在当前仓源码里。**
- `out\DEPLOY.md5.txt:49-52`：`ABB969FE` = `cand_skip`，**源 = `wt-08e8b62`（08e8b62 + `s6/patch_testdefs.py` 钩子）+ `//DT_SKIP_CHAINS_DEF="18,19,20,21,22,23,24,26,27,28,29,30,31,32"`**，无 DM_BAR；证据 = `chains_skipped=14 refused=0 **closures_noop=168**`（14 链 × 12 op）。
- `git grep DT_SKIP_CHAINS_DEF` 在 `c516627` 只命中 `notes/promote-skip-c512.md:43` ⇒ **仓 HEAD 源码不带这个默认**；`build_variant.sh` 从仓 HEAD 出件 ⇒ **不跳链**。
- 逐站对号（`k2b_chainmap.txt` 第 (2) 段）：
  - **S0 int8 `640×64×256b8`：16 站里 14 站在被跳的 C512 链**（229,241,253,265,277,289,301 = chains18-24；403,415,427,439,451,463,475 = chains26-32）；活着的只有 `c217`(chain17, 0.1743) 与 `c391`(链外, 0.1723)。
  - **S2 f16 `640×256×64b8` epi2：同样 14 死 / 2 活**（活 = `c215` 0.2333、`c389` 0.2323）。
  - **S1 f16 `2040×32×128b8`：16 站全活**（chains 9-16、33-40，C128/C256，不在 skip 名单）。
  - ⇒ **48 站里 28 站在加载位上已经是 0 帧价**（T2 整链跳，比 wide 更彻底）。rt2 底盘 10.55 ms 中 **6.095 ms 是 off-path**；**刀 2 真正可回收的底盘 ≈ 4.46 ms 串行**（3.643 + 0.347 + 0.466）。
  - ⇒ 按屋顶价（G41 0.1307 / G35 0.1343 / G39 0.1124）：wide 侧 = 2.091 + 0.269 + 0.225 = **2.585 ms** ⇒ **纸面回收 ≈ 1.87 ms 串行 ≈ 0.80 ms 帧**（×0.43），**不是 §51⑩ 的 4.6 ms 串行，更不是 7.6**。
  - 再收紧一层：S1 的 14 站所在链 `skippable=1` 只是**现在**没被跳；若哪天 C256/C128 也跳，刀 2 只剩 ~0.3 ms 串行残值 ⇒ **刀 2 的窗口期 = "这些链还留在帧上"**。
- **两颗地雷（第 3/4 步会踩）**：
  ① **逐位门会假红**：新金标 `DD49827D` 是"跳 14 链"的产物。从仓 HEAD 直接 build 的 `NR_B_WIDE=2` 变体**不跳链** ⇒ 1301 必然 ≠ DD49827D（落在 `249A46F3` 那代）。⇒ **刀 2 变体必须复刻转正基座**：`REPO=E:/DSH/wt-08e8b62` + `python s6/patch_testdefs.py` 钩子 + `//DT_SKIP_CHAINS_DEF="18,...,32"`，且 `s6_ffn_block_kernel.hpp` 回到未打 S6_BAR 补丁的原始态（md5 `490647A9…`），见 `s6/build_cand_a_only.sh` / `s6/build_test_dll.sh`（后者 `NEVER stages into oneapi/`、`NEVER touches out\libxmx.dll`）。
  ② **帧 16 对会被 ±4.79 ms 污染**：A 侧 ABB969FE（跳链）vs B 侧不跳链 ⇒ 测的是 T2 不是刀 2。
- 顺带把 §51⑦ 的"机制未查明 + `DEPLOY.md5.txt` 有没有 /D 编译期默认"这条**未查项关掉**：有，且它**不影响**那 40 发（0/40 在被跳链里），但**影响刀 2 的 48 站**（28/48）。

## 3. 第 2 步（`knife2_probe.exe` 终审成对实测）：**未跑，0 进程**

`E:\DSH\sycl-cache-k2` 实测 0 文件 ⇒ 台账源尚未生成。下次原样跑（每站 10 个独立进程）：
```
Set-Location E:\DSH\oneapi
$env:SYCL_DEVICE_FILTER='level_zero:gpu'; $env:SYCL_CACHE_PERSISTENT='1'; $env:SYCL_CACHE_DIR='E:\DSH\sycl-cache-k2'
foreach ($s in 0,1,2) { $env:K2_SITE="$s"; 1..10 | ForEach-Object { .\knife2_probe.exe >> "E:\DSH\s6\K2_probe_S$s.log" 2>&1 } }
Get-Content E:\DSH\s6\K2_probe_S0.log,E:\DSH\s6\K2_probe_S1.log,E:\DSH\s6\K2_probe_S2.log | Select-String 'DIFF;|PAIR;'
```
- 判据写死：任一站 `diff≠0` ⇒ 停下回报（贴第一个偏差坐标 + 该行地址表达式原文）；`ratio<1.5` ⇒ 停下回报；`ratio≥1.5` ⇒ 才进第 3 步。
- 读数口径（交接清单已给，勿改）：计价取 `CSVROW` 第 10 列 `msM_med`；`PAIR;ratio = split_total/wide_total`（**不含 pack_b**，pack_b 是 `INIT ONLY` 行）；S0 `cmp=327680`，S1/S2 `cmp=Mp×Nw`。
- 台账：`s6/mk_roof_ledger.py <cache目录> <outdir> <hours_back>`，cache 目录填 `sycl-cache-k2`，**去重 key 含 simd+module_id**，label 映射 = `s8v8::gemm_b_pub`、`f16v1::gemm_b_pub_f16`、`packdev::gather_pack_a_b_v/a16_b/b_b/b16_b` + probe 本地 lambda `gather_pack_b16_diag_b`；**计价腿必须 private/spill/scratch=0**。
- ★ 新读法（本会话加的）：**S0/S2 两站的 wide 单价即使 1.5x 也不带帧价**（14/16 站在转正件上已被 T2 跳掉）⇒ 三站 ratio 照判"机制真假"，**帧价值只按 S1 的 16 站 + S0/S2 各 2 站算**。

## 4. 坑清单（下次别再踩；P7/P8 是本次新添）

| # | 坑 |
|---|---|
| P1 | **f16 新 wide 支的 `WKey` 必须另立第 4 字段**（int8 先例 `:3124` = `10000+batch`；f16 split 现用 `:2892` = `nb*2+transposed`）。复用 split 键 ⇒ wide 支静默吃到非块对角预铺 B，编译过、门可能照样绿，到 1301 才爆。实施后先跑 1301 对拍再看门，并在 trace 里打 `WKey` 四元组。 |
| P2 | **`epi` 守卫只放宽 f16 侧**；int8 的 `epi∈{0,1,4}` 不动（`gemm_b_pub` 把 `ac*-0.0559+0.447` 折成 FMA、跳掉 `fmul_rn` 中间舍入，`:3170-3175` 注释）。f16 S2（epi2）走已证的 `pub_vec_v8` ⇒ 纳入与否只由 `DIFF;diff=0` 说了算。 |
| P3 | `:3166` 的 `if(++once==144)` **永远不会打印**（batched 执行计数 = 72×4=288）⇒ 不能当"没执行"的证据。 |
| P4 | `[bpack]` 打印有 `bgp<=8` 上限（`:3157`）；`[bwide]` 无上限（`:3120`）。计数别混。 |
| P5 | `run_timing.txt` 写在 **CWD**（= `oneapi\`），且 `rtcsv` 行**只进文件不进 stdout**（`:1507/:1525`）⇒ `[bwide]`(stdout) 与 `rtcsv`(文件) 不能直接交错，按 pass 序号对齐；每跑一次立刻存拷，否则被下一跑覆盖。 |
| P6 | 一个 `nr_replay_now` 进程 = **4 runs** ⇒ trace 计数要 ÷4 才是"每 run 的发数"。 |
| P7 | **（新）`DT_SKIP_CHAINS_DEF` 不在仓源码里** ⇒ 任何"从仓 HEAD build 的变体"都不跳链 ⇒ 1301 对 `DD49827D` 假红、帧 16 对被 4.79 ms 污染。见 §2。 |
| P8 | **（新）`.ps1` 里写中文注释会被按 ANSI 解析而炸**（本次实测：`[scriptblock]::Create` 报"字符串缺少终止符"）。⇒ 脚本/日志一律纯 ASCII，中文只进 `.md`。另外 pwsh 自定义函数名不能撞内置单字母别名（`h` = `Get-History`，本次也撞过）。 |
| P9 | 别 `2>&1 | Out-Null`（§47 吞过一次）；跑批前后核对文件存在 + 日志计数非空 —— `K2b_ab.ps1` 已内置这条闸。 |
| P10 | 热协议（§51⑥）：跨进程/跨配置一律同热交替或先凉 ≥5 min；连续跑批 >20 min 要插冷却并把"本批时长"记账（`K2b_ab.ps1` 末行会打 `batch_minutes`）。 |

## 5. 下次开工第一条命令（按序，原样可粘贴）

1. `Set-Location E:\DSH\dlss-nr-on-a770; git branch --show-current`（期望 `ds-quality-relax-2026-11-02`）、`git status --porcelain`（期望 0）；查 `LOP-Win64-Shipping`（期望 0）。
2. **第 1 步 GPU 复核**（≈4-6 min，A/B 同热交替）：`pwsh -NoProfile -File E:\DSH\s6\K2b_ab.ps1` ⇒ 再 `python E:\DSH\s6\k2b_rtcmp.py` ⇒ 按 §1.3 三态报。
3. **第 2 步 probe**（≈40-60 min，3 站 × 10 进程；每 2 站之间插 ≥5 min 冷却）：§3 的命令块。跑完核对三份 `K2_probe_S*.log` 各 ≥10 条 `DIFF;` 与 ≥10 条 `PAIR;`，并 `Get-Process nr_replay|knife2_probe` = 0。
4. 第 3 步实施前**先解决 §2 的地雷**：变体基座 = `wt-08e8b62` + `patch_testdefs.py` + `//DT_SKIP_CHAINS_DEF`，不是仓 HEAD。`NR_B_WIDE` 分档（0=旧守卫 / 1=N32+N64、Nw≤512 / 2=N≤256、Nw≤2048，默认不设=现状逐位不变）；f16 侧把 `gather_pack_b16_diag_b` 从 probe 本地搬进 `pack_device.hpp`；**帧价值按 §2 的 20 活站重算**。
5. 第 4 步三关：逐位（1301 = `DD49827D` EXACT，`passes` 若变如实报）、确定性 ≥4 进程 distinct md5=1、40 门（跑完把 `oneapi\libxmx_sycl.dll` 复原成 `ABB969FE…`）、帧 16 对（A = `out\libxmx.dll`，unset 所有 `NR_*`；判读 ≤−0.5 且赢 ≥10/16）。**按 §2 的 20 活站预期，帧收益中心值 ≈ −0.8 ms 而不是 −3.3/−2.0 ⇒ 16 对的噪声带（sd ≈0.5）能分辨，但别期待 −3。**

## 6. 本会话产出文件（都在 `E:\DSH\s6\`，未 commit）

| 文件 | md5 | 状态 |
|---|---|---|
| `k2b_chainmap.py` | `26ADE192E006FD7C50C9C5D0694D3B39` | 已跑（host-only，无 GPU） |
| `k2b_chainmap.txt` | `5D01D29C60D511916FCD194312FBDF31` | 其输出（40 发逐链对号 + 48 站 skip 对号） |
| `K2b_ab.ps1` | `850EFEAE7A0ECAE5CF7340B8C57B13F3` | **未跑**，PARSE OK |
| `k2b_rtcmp.py` | `FC93716A894954A80B740B9EBAD0133E` | **未用**，py_compile OK |
| `knife2b.md` | 本文件 | 落盘 |

（`py_compile` 在 `s6\__pycache__\` 留了两个 .pyc，无害，下次可删。）

## 7. 交回五行草稿（GPU 部分待跑，静态部分已可交）

① **§51⑦ 疑账判决 = 假设成立（静态已证，GPU 复核待跑）**：机制 = S6-1a `:677-678` 在 record time 把每条 FFN 链的 5 腿（含 2 发 batched）写成 `[](){}`；40 发 = 19 链 × 2 + 链外 1 对；`[bwide]` 0 次 = 闭包体已被替换，不是 wide 让它便宜。**但预期数要修正：B 侧 `[bwide]` = 20/发·每 run（不是 40），另 20 发走 `[bpack]` 且其打印有 8 行上限。**
② 三站 diff/ratio/台账 = **未跑**（0 进程，`sycl-cache-k2` 空）。
③④ 未开始（第 3/4 步未动，按暂停令）。
⑤ **实测回收 vs 预测**：本次静态重读把底盘从 48 站 10.55 ms 缩到 **20 活站 4.46 ms 串行**（28 站已被 §45 的编译期跳块在链级吃掉）⇒ 纸面回收 **7.6 → 4.6 → 1.87 ms 串行 ≈ 0.80 ms 帧**；**violation 还剩**：刀 2 若做完，48 站里剩下的活站 violation ≈ 2.59 ms 串行（wide 侧价），而那 28 死站的 6.10 ms 已经是 T2 的账、不能再记给刀 2。

---

**10:3x：落盘完毕，上面这份续跑包已原样交回父代理（`session-84f13124-…`）。** 下次自己从这里读起 —— §5 = 命令顺序；§1.3 = `[bwide]` 的正确预期（**20/发·每 run，不是 40**）；§2 = 刀 2 的钱 + 两颗门地雷（`DD49827D` 需要跳链基座才谈得上逐位）；§4 = 坑 P1-P10。本会话 GPU 一个进程都没跑过 ⇒ 卡仍是冷态，`knife2_probe.exe`（`B5A82BE2…`）与 `K2b_ab.ps1`（`850EFEAE…`）都还等着第一次执行。

**P11（10:4x 新添，本次实测）**：本机的 `pwsh Get-Content` **把无 BOM 的 UTF-8 中文按 GBK 读**，一个汉字的第二字节会吞掉紧随其后的换行 ⇒ **行数被合并**（本文件 145 个 LF，`Get-Content` 只数出 87 行），中文也会显示成乱码。⇒ **凡是含中文的账本/日志：行数与内容核对一律走 python（`open(...,'rb')` 或 `encoding='utf-8'`）或 `rg`，不要用 `Get-Content`/`Select-String`**；`.ps1` 与机器读的 log 一律纯 ASCII（P8 的延伸）。`K2b_ab.ps1` / `k2b_rtcmp.py` 已按这条写（log 全 ASCII）。

---

# §52 第 0 步 = **完成**（可复现性已修好 + 疑账实测闭合）　2026-11-03 11:3x-12:0x

## 52-① 编译期默认机制正式进仓（未 commit；仓 porcelain 只见 3 个新文件）
| 新文件 | md5 |
|---|---|
| `dlss-nr-on-a770\tools\patch_testdefs.py`（= `s6\patch_testdefs.py` 逐字节副本） | `A26A8A818CB0E983A45DB60B8FD6CCFE` |
| `dlss-nr-on-a770\tools\shipped_build.defs`（唯一一条 `/D`） | `79B75599010E50ACD37F658F425648EA` |
| `dlss-nr-on-a770\tools\build_shipped.ps1`（仓侧正规构建：不脏仓、不 stage、不写 out） | `1D756E68EA6274C59EBCCC5CBA38755E` |
| `E:\DSH\out\SHIPPED_BUILD.md`（出货件 = 哪个 commit + 哪些定义 + 哪个脚本 + 复现证据） | `CA08E2490424467F96514785498A3E61` |

**★ 更正我上一轮的 grep 误判**：宏名是 **`T_SKIP_CHAINS_DEF`**。MSYS 下 `//DT_SKIP_CHAINS_DEF="…"` = `/D` + `T_SKIP_CHAINS_DEF` ⇒ 之前 `git grep DT_SKIP_CHAINS_DEF` 只命中 notes 是**搜索词错了**，不是"仓源码里没有这套机制的引用"。`wt-08e8b62` 的工作树里钩子处于**已应用状态**（`libxmx_sycl.cpp` md5 `4E9231D259688F2CCEC50667A2F46522`，porcelain ` M .cpp + M .def`）= 出货基线的实物参照，按令**未动**。
**新坑 P15（PS 引号）**：`/DT_SKIP_CHAINS_DEF="18,…"` 经 PS 5.1 传给 native `icx.exe` 时**双引号被吞** ⇒ 宏展开成整数 `18` ⇒ 两个钩子点编译错误（`libxmx_sycl.cpp:1108` / `:1180`）。⇒ `shipped_build.defs` 里必须写 **`\"`** 转义形式（文件已改并注明）。

## 52-② 复现证据（从仓 HEAD 出件 ⇒ 对上新金标）
- `tools\build_shipped.ps1 -Tag ship1` ⇒ **`E:\DSH\builds\libxmx_ship1.dll` = `7BB0618E8B68129DC2791090438B66F9`，3,813,376 B（与 `ABB969FE` 同尺寸）**；icx exit=0、**编译 1.3 分钟**、711 warnings / 0 errors（`logs\build_ship1.log`）；scratch 里 patched 源 = `1A3AF9239706EF7CA893628762A731B1`；构建后 `git status --porcelain` = **3**（只有上面三个新文件 ⇒ 仓没被脏）。
- **4 个独立进程 walk**（`-Dll builds\libxmx_ship1.dll`，tags `ship1_a..d`）⇒ **1301 = `DD49827D…` EXACT ×4 ⇒ distinct md5 = 1**（军规 31）；691 passes / 1302 buffers / 5254 steps；`logs\walk_ship1_[a-d].txt` 里：`[skip-chains] NR_SKIP_CHAINS='18,19,20,21,22,23,24,26,27,28,29,30,31,32'` + **14 行 `chain=NN SKIPPED … (12 no-ops)`** = **168 个 no-op 闭包**，链号恰为 `{18..24, 26..32}` ✓
- dll md5 ≠ `ABB969FE`：差 = HEAD 的 +11 行 `rtcsv` 仪器（`NR_RUN_TIMING` 门后）+ 时间戳 ⇒ **复现判据用「输出逐位 + 尺寸」，不是字节相同**。
- **★ 对照实测把地雷①钉死**：`walk -Dll builds\libxmx_rt2.dll -Tag rt2noskip`（仓 HEAD、不带 `/D`）⇒ **1301 = `249A46F3…` = MISMATCH**（旧金标那一代）⇒ **任何从仓 HEAD 直接 build 的刀变体都会在逐位门上假红**。今后门 / 4-4 确定性 / 帧 16 对必须跑在 `tools\build_shipped.ps1` 基座上（+ 本刀自己的 diff）。
- 观察（别误用）：walk 的 run wall 对跳块**不敏感**（ship1 62-63 ms vs rt2 65-68 ms）⇒ **别拿 walk wall 当 T2 收益的证据**，帧账只认 `ab.ps1` 的 in-process 配对。

## 52-③ §51⑦ 疑账 = **实测闭合，假设成立**（`K2b_ab.ps1` A,B,A,B 同热交替；本批 0.2 min；冷机起跑；0 残留）
| 侧 | `[bwide]` | `[bpack]` | 那 40 发合计（末跑 691 行） | 单发 min..max |
|---|---|---|---|---|
| **A** 默认（`NR_S6_FFN` 不设 = ON） | **0** | 8（打印上限） | **0.246 / 0.206 ms** | 0.0035 – 0.0263 |
| **B** `NR_S6_FFN=0`（回 pre-1a 老路） | **100 = 20/发 × 5 跑** | 8（打印上限） | **11.79 / 12.57 ms** | 0.199 – 0.65（1 发 1.46） |

⇒ 40 发**确实是被已出货的 1a 顶成 no-op**，不是厂商意义上的死代码；把 1a 关掉它们每发要付 0.20-0.65 ms（合计 11.8-12.6 ms 串行）。
⇒ **§50 里「已出货合并机制（P8-b wide-merge）的既有回收」按 ≈0 重记**：那 20 发 wide 站点在 shipped 路径上根本不执行，wide 分支只是 1a 未命中时的备胎。
⇒ 三态判据落点 = **①成立**（数量按修正后的 20/发·每跑整除，无差额站）。
**新坑 P12**：一个 `nr_replay_now` 进程 = **5 次 691-pass 流**（1 record + 4 replay），而 `run_timing.txt` 以 `"w"` 打开 ⇒ **只保留最后一跑的 691 行 rtcsv**；trace 计数要 ÷5，rtcsv 只有一个桶。
**新坑 P13**：**冷机 RUN_TIMING 绝对值上漂约 35%**（A 侧 S0/S1/S2 本批 = 3.56/4.94/4.67 ms vs `rt_per_closure` 的 2.94/3.64/3.97）⇒ **跨会话的绝对 ms 不可比**，只有同批内 A/B 差可用（§51⑥ 的另一面：不只热漂，还有冷漂）。

# §53 第 1 步 = **完成**（398 发 alive 审计）
- 产物 **`E:\DSH\tools\shapes_alive.csv`** `1DE6782E3A35986BA8DD2307A55C27F5`（398 行 × 23 列：`alive / cause / group / merge_group_members / merge_group_alive / merge_still_alive / recovery_alive_ms`）；生成器 `s6\k2b_alive.py` `53CE3C5ADA6655E0C6CB9E8402234803`；摘要 `s6\k2b_alive.txt` `78F0CFC3E03EF612FA6CF47F30C3F152`。
- 死因判定 = **三条机器证据，零猜测**：R1 roofgap 自带 `chain` 列 ∈ `{18..24,26..32}`（T2 编译期跳块）；R2 `rt_per_closure` 的 ms ≤ 0.005（计时地板）；R3 **S6-1a 五腿 no-op 用「记录流里的六发 FFN 尾」自动检出**（`QUANT,BATCHED,QUANT,BATCHED,QUANT,RESIDUAL` 连续 6 发 ⇒ 前 5 发被 `:676-678` 吞）：命中 **20 处**，含 `chain_map` 覆盖不到的 12-18 段 ⇒ **40 发全数命中**，与 52-③ 的实测互相咬合。
- **总量**：398 发 = **活 260 / 死 138**；死因构成 = skip 链 **98 发（paper 11.90 ms）** + S6 no-op **40 发（0.26 ms）**。
- ★ **加载位上活着的 violation 总量 = 35.14 ms 串行 = 帧 15.11 ms**（paper 47.30 / 20.34）⇒ **§50 的「20.3 ms/帧」地图里有 5.2 ms/帧 已经是死账**。
- **三刀活站价值**（paper = `violation_ms` 分摊口径；现值 = `rt_per_closure` 实测口径）：

| 刀 | 站数 | 活/死 | paper 回收 | **活站回收（串行 → 帧）** | 实测现值 全 / 活（串行） |
|---|---|---|---|---|---|
| **刀 1 = A1+A2+A3** | 60 | **60 / 0** | 12.08 | **12.08 ms → 帧 5.19** | 16.79 / 16.79（A1 3.76 + A2 3.87 + A3 9.16） |
| **刀 3 = A4** | 56 | **28 / 28** | 20.32 | **15.79 ms → 帧 6.79** | 14.03 / 8.07 |
| **刀 2 = B1** | 48 | **20 / 28** | 7.63 | **3.81 ms → 帧 1.64** | 10.55 / 4.45 |
| B2（fat-N sa=0） | 36 | 16 / 20 | 1.01 | 0.95 → 帧 0.41 | 4.03 / 3.98 |
| 其它 198 站 | 198 | 136 / 62 | 6.26 | 2.50 → 帧 1.07 | — |

- 刀 3 的 28 个死站**全是 `640x512x512b1`**（该形 32 站里 28 落在被跳的 C512 链）；其余 3 个 A4 子形（`192x1024x4096` / `192x4096x1024` / `192x3072x1024` 各 8）**24 站全活** = paper 15.14 ms。
- **合并退化（机器规则：同一 `merged` 目标活成员 <2 ⇒ 合并无意义）**：全体死亡的 merged 目标恰有 4 个 = `8160x512x128b1`(12)、`8160x128x512b1`(12)、`32640x256x64b1`(8)、`32640x64x256b1`(8) ⇒ **正是 §51⑦ 那 40 发的两种合并形（B2 的 fat-N 与 P8-b 的 wide）双双归零**；其余 24 个 merged 目标仍活。
- **新坑 P14**：`shapes_roofgap.csv` 的 `orig` 串是 **`MxNxKb<batch>`（只有两个 `x`）**，我第一版正则写成三段 `x` ⇒ **静默 0 命中**（所有 measured 组都 0）。⇒ 已加自校验列 `comparable/mismatch`，**0 comparable 必须警觉**；另外 qkv/residual 族在 `rt_per_closure` 里 `K` 为空 ⇒ 交叉核对降级为"可比的才比"，**不许静默丢行**。

# §54 第 2 步 = **只出裁决建议（未实施、未开新铲）**
1. **下一刀 = 刀 1（A1+A2+A3）**：活站价值 **帧 5.19 ≥ 2.5 线**，且 **60/60 站全活、零依赖、b 进 grid 逐位天然保**（每元素 K 归约不变，batch 只是 grid 维）。**刀 1 的 §50 预测（12.1 ms 串行 / 帧 −5.2）在 alive 审计后一字未变** = 全图里唯一没被 1a/T2 预先吃掉的合并刀。
2. **刀 3（A4）= 帧 6.79 更大但排第二**：依赖刀 1 的 stride 分配器；56 站里 28 站已死；真正的肉集中在 24 站（15.14 ms paper）；该族 4 个屋顶低可信点（§50）需 ≥10 进程重取 ⇒ **刀 1 之后立刻做刀 3，不要先做**。
3. **刀 2 降级 = 确认**（活站帧 1.64；paper 7.6 里 3.8 是死账）⇒ 建议**不为刀 2 跑那 1.5 小时的三站 probe**。`knife2_probe.exe`（`B5A82BE2…`）仍未跑、`sycl-cache-k2` 仍空，留着当"单价 ratio 真假"的备用仪器。**ratio 与活站价值是两回事**：probe 测的是 split vs wide 的**单价倍率**（机制真假），不会因为 28 站已死而变难看；刀 2 的问题从来不是单价，是**没几发还活着**。
4. **port-E 不受本账影响**：其选块 C=64 档 S1 链（closure 641-651 = chain 48）按 alive 表**全活**（C64 档链不在 T2 名单）⇒ 若改派 port-E，前置仪器不用重做。
5. 若批刀 1，下一条命令（等令再动）= 新建 `src/bench/sycl/batch_merge_probe.cpp`（照 `shape_roof_probe.cpp` 的 harness；4 个真实族各测 `b1/b4/b8/b16`，f16+int8、raw+pub，**≥10 独立进程取中位**，`SYCL_CACHE_DIR=E:\DSH\sycl-cache-bmerge` 独立目录、台账 key 含 simd+module_id），判据 = `diff=0` + `ratio≥1.5` + 计价腿 `private/spill/scratch=0`；变体若进 dll，基座必须是 `builds\libxmx_ship1.dll` 那一套（`tools\build_shipped.ps1`）。

# §55 现场复原（12:0x 实证）
`out\libxmx.dll` = **ABB969FE…** ✓；`oneapi\libxmx_sycl.dll` = **ABB969FE…** ✓（**本会话从未 stage**：walk/replay 都是把 dll 路径直接喂给 `nr_replay_now.exe`）；三金标 **DD49827D / DD49827D / 249A46F3** ✓ 未动；`out\test_1270e4m3.dll = D37FFD5D…`、`out\test_skip_c512.dll = 2D878C07…` ✓ 未动；`wt-08e8b62` 原样（` M .cpp + M .def`）✓；`knife2_probe.exe` `B5A82BE2…` 仍未跑。
新增件：`builds\libxmx_ship1.dll` `7BB0618E…`（**ship 基座，可直接当刀变体的底**）；`builds\libxmx_rt2.dll` 不变；walk 产物 `dumps\ship1_[a-d].1301.bin`（4×`DD49827D`）与 `dumps\rt2noskip.1301.bin`（`249A46F3`，对照证据）。
进程：**`nr_replay=0 / LOP-Win64-Shipping=0 / icx=0`** ✓。未 commit / 未 push。
**热状态**：本会话 GPU 累计 ≈ **0.5 分钟**（A/B 0.2 + 4 walk 0.2 + 对照 walk 0.1），远 <20 min ⇒ 无冷却要求；最后一次 GPU 动作在 11:5x ⇒ **下次开工卡是凉的**（但 P13 说明冷机绝对 ms 会偏高 ~35%）。
