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

---

# §56 阶段 A（刀 1 四族成对实测）= **完成，判据 GO**　2026-11-03 12:0x-13:0x
**仪器**：仓内 `src/bench/sycl/batch_merge_probe.cpp`（untracked，`5F8081F94E6D498DA2066F567B6C1751`）；exe `oneapi\batch_merge_probe.exe` = `B4939F6887A7137B6C5DD3DE85088B07`；跑批 `s6/run_bmerge.ps1` + 补跑 `s6/k1_topup.ps1`；汇总 `s6/bmerge_sum.py` ⇒ `s6/bmerge_sum.txt` `03466E0322C3CCE2092F937C5884B773`；台账 `s6/BMERGE_ledger.csv` `85C2D7AF3AA0A83D0F67EF255129A594`（生成器 `s6/mk_bmerge_ledger.py`，cache=`sycl-cache-bmerge` 独立目录，key 含 simd+module）。
**四族（plan 真值，取自 `tools/shapes_alive.csv`）**：F0 `A1 qkv 2560×768×256`、F1 `A2 window-res 2560×256×256`、F2 `A3 res 2040×256×256`、F3 `A3 res 8160×128×128`。
**协议**：**同进程内 split(b×batch=1) / merged(1×batch=b) 交替配对**（P13：只比 `PAIR;ratio`）；5 组 × min-of-15、组间 60 ms、nosink、GPU-event 按形求和；样本进程 F0 15 / F1 18 / F2 10 / F3 10 ⇒ 96 个 (族,dtype,腿,epi,b) 组。

**① DIFF（逐字节）**：修正哨兵后 **128/128 = diff=0**（`s6/BMERGE_DCHK_F0..F3.log`）。主跑里 pub 腿的 nonzero 全是**哨兵伪差异**：`diff=(Mp−M)·N·esz`、`first_off=M·N·esz+1`（pub 核有 `if (rr<M)` 守卫、不写填充行；raw 核写满 ⇒ raw 全 0）——F0/F1 的 M=Mp ⇒ 连伪差异都不出现，这条自证成立。
**② RESTWIN 分离实验**（`s6/BMERGE_twin_F2/F3.log`）：孪生核 `s8v8::gemm_b_res_batch`（设备 `S8ResDesc` 表）vs 出货 `gemm_b_res`×b，F2/F3 的 **b=1,2,4,8 全部 diff=0** ⇒ **孪生核逐字节正确**。
**③ ratio（中位）**：best b=16 的 24 组里 **23 PASS**；唯一 FAIL = F3 int8 raw 1.464（F3 帧上的腿是 fused-store ≈ pub epi1 = **1.882** ✓）。按 §7.1 的 plan 档：

| 族 | int8 pub epi1 | int8 raw | f16 pub epi1 | 备注 |
|---|---|---|---|---|
| F0（b8 档） | **1.522** ✓ | 1.580 ✓ | 1.445 ✗ | b16：1.671 / 1.738 / 1.540 |
| F1（b8 档） | **1.597** ✓ | 1.400 ✗ | 1.896 ✓ | b16：1.937 / 1.771 / 2.259(n=3 低置信) |
| F2（b8 档） | **1.515** ✓ | 1.446 ✗ | 1.852 ✓ | b16：1.913 / 1.880 / 2.395 |
| F3（b4 档） | **1.317 ✗** | 0.921 ✗ | 1.069 ✗ | b8 档 1.605 ✓ / b16 1.882 ⇒ **该族必须并到 ≥b8，b4 无肉** |

⇒ **合并倍率随 b 显著增长，§7.1 写的 b8/b4 偏低；真要实施应取 b=16（一族 16 发正好并成 1 发）**。
**④ TOPS 对照 §50**：F0 int8 raw merged b8 = **29.80** vs `xmx_roof.csv` G18 = 29.73 ✓（差 0.2%，同形同核）；但我的 split b8 = 18.88 而 §50 的 G17 单发 b1 = 11.70 ⇒ **口径不同**（同进程连续 8 发合计 vs 单发 min-of-15）⇒ **别把 §50 的 2.54x 当本案 ratio**，本案同进程配对 = 1.58x。
**⑤ 台账**：20 条实例（`s8v8::gemm_b/gemm_b_pub/gemm32_b`、`f16v1::gemm_b/gemm_b_pub_f16`、`packdev::pack_a/pack_b/pack_a16_b/pack_b16_b`）⇒ **grf=128、simd=1/16/32、private/spill/scratch=0、scratch 指令=0** ✓。
**新坑 P16**：PS 5.1 的 `*>>`/`>>` 会把子进程输出**重编码成 UTF-16** 并与 ASCII 头混在一个文件里 ⇒ 机器读的 log 一律用 `cmd /c "exe >> log 2>&1"` 落原字节，解析用 python（BOM 嗅探）。本轮第一次跑批因此白烧 6 个进程。
**新坑 P17**：probe 在 **F1 形上随机 fastfail（0xC0000409）**（F1 14 次尝试 11 次崩；F0/F2/F3 干净），崩点集中在最后几条腿（大 b + 大 C 缓冲）⇒ 对策 = 分 dtype 补跑（`BMP_DT=int8`）+ 崩溃重试 + **逐点报 n**。

# §57 阶段 B = **卡点回报：合并侧未过逐位门（10 轮 build 后停手）**
已实现（都在仓里、未 commit；`porcelain = 2 M + 1 ??`）：
- 孪生核生成器 `s6/k1_add_batch_res.py` ⇒ `gemm_s8_v8_kernel.hpp` 新增 `S8ResDesc` + `gemm_b_res_batch`（体贴从 `gemm_b_res` **逐字节复制**，只改 group 索引与指针来源）；
- 引擎侧 `s6/k1_engine_bmerge.py` ⇒ `NR_BMERGE` 分档 + 记录期 stash（`xmx_rec_gemm_int8_residual`）+ **捕获期（skip pass 之后）** closure 重写 + `[bmerge]` 计数打印；
- 全部 build 走 `tools/build_shipped.ps1`（ship 基座 + `/D`），**单次编译仅 0.6-0.7 分钟** ⇒ 迭代便宜。

读数：
- **默认侧（不设 `NR_BMERGE`）= 1301 `DD49827D` EXACT ×4 独立进程** ✓ ⇒ "开关默认逐位不变"成立；`chains_skipped=14 refused=0 closures_noop=168 passes=691` 一字未变。
- **合并侧从未逐位**：MAX=16（k1a-k1c）1 组/16 发 ⇒ 4 进程 4 个不同 md5；MAX=2（8 组/2 发）⇒ 仍 MISMATCH。`s6/k1_bands.py`：**1301 面 100% 元素不同**（4 通道 × 544 行全错）⇒ 早期一次错误写入毒化整图。
- 逐轮排除：
  - **R1** 组内含被 skip 杀掉的成员（合并发射不出）⇒ 加 `g_skipped_cmds` 过滤 ✓ 仍错；
  - **R2** 成员**输出面**被中间 closure 触碰 ⇒ 加 `outs` 指针相交守卫（MAX16 时 4 组被拒）✓ 仍错；
  - **R3** 未注册 closure（touch=`{(void*)-1}`）视为冲突 ✓ 仍错；
  - **R4** 成员**输入面**（Araw/Braw/skip/cos/as/bs/a16r）在 pack 之后、合并发射之前被改写 ⇒ 加输入保护 ⇒ **MAX16 = groups=0 ⇒ 1301 EXACT（负对照干净）**；MAX2 的 8 组仍错；
  - **R5** 描述符表走 scratch pool 可能被复用 ⇒ 专用 malloc + 一次性上传 ✓ 仍错；
  - **R6** 持有 pool 块改变别的 closure 的取块序列 ⇒ 成员 A 面改专用 malloc（不进池）✓ 仍错；
  - **R7** cgraph 参与？⇒ `NR_CGRAPH=0`：默认侧 EXACT、合并侧仍错 ⇒ **与 cgraph 无关**；
  - **R8** 孪生核？⇒ probe RESTWIN diff=0 ⇒ **核无罪**；
  - **R9 决定性对照**（`NR_BMERGE_KEEP=1` 每条腿仍按出货位置发射自己的 gemm + `NR_BMERGE_SCRATCH=1` 合并腿只写丢弃缓冲）⇒ **仍错** ⇒ **"重写"本身在改图**；
  - **R10** 把组的全部设备对象（face/dtab/scratch）移到**重写期**分配（绝不在被捕获的 body 里 malloc，:1589 的规矩）⇒ keep+scratch 仍错；**纯合并 = 挂死**（`nr_replay_now` 22 分钟无输出，已杀 pid 4024）。
- **诚实结论**：刀 1 的**单价结论成立**（§56），但**"把 b 条链的腿推迟到组内最后一条链的位置"在当前记录顺序下不等价**；指针级依赖守卫（PGRAPH touch sets）不足以刻画真实依赖；R9/R10 说明连"额外发射一条写丢弃缓冲的腿"都会改变结果 ⇒ 最可能根因：这些腿的输入面（A 面 / a_scale / b_scale / skip / cosine）在链间被**复用/改写**，且引擎把 **scratch-pool 的取块序列当作正确性的一部分**。⇒ **closure 级重写做不成这件事**；刀 1 需要**记录/计划层换序 + 稳定面**（把同形腿排到相邻、并给它们不被回收的面）＝ port-E 量级，不是小刀。
- **安全性**：`NR_BMERGE` 默认 0；且在 R4 守卫下**默认档 MAX=16 = groups=0**（打开开关也不会合并任何腿）⇒ 这批 dirty 文件对出货路径无风险；**但别在 MAX≤4 档跑合并（会挂死）**。
- **40 门**：stage `builds\libxmx_k1i.dll` 后 = **39 GREEN / 1 RED**，唯一 RED 是 `gate_skip_graph` 的**自带 md5 守卫**（要求 oneapi 里的件 = ABB969FE，而我 stage 了候选件）；该门的功能检查全过（`chains_skipped=14 refused=0 closures_noop=168 passes=691` + 三进程 1301 EXACT）。**复原 `oneapi\libxmx_sycl.dll` = ABB969FE 后重跑 = 40 GREEN / 0 RED** ✓
- **帧 16 对：未跑**（B 未过门，按令不进 C3）。
- 中间件（只出 `builds\`）：`k1a 3B2FE100 / k1b 174083DA / k1c F4435F29 / k1d 7B626BFB / k1e 077B9933 / k1f 9C1CB0B8 / k1g 8AC8B7AA / k1h 0A2586F5 / k1i EF2C9677 / k1j B0AC7948 / k1k 60475C4B / k1l D62015D7 / k1m 22F49260`（3,844,608→3,853,312 B）。补丁全由 `s6/k1_*.py` 生成，可复现可回退（`git checkout -- src/bench/sycl/libxmx_sycl.cpp src/bench/sycl/gemm_s8_v8_kernel.hpp`）。

# §58 现场（14:0x 实证）
`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE…** ✓（门跑时 stage 过 k1i，**已复原并贴 md5**）；三金标 **DD49827D / DD49827D / 249A46F3** ✓；`out\test_*.dll` ✓ 未动；`wt-08e8b62` ✓ 未动；`knife2_probe.exe` `B5A82BE2…` 仍未跑。
仓：`ds-quality-relax-2026-11-02` @ **`3abc02a`**，porcelain = ` M gemm_s8_v8_kernel.hpp` / ` M libxmx_sycl.cpp` / `?? batch_merge_probe.cpp`（刀 1 未提交工作，**未 commit/未 push**）。
新产物：`oneapi\batch_merge_probe.exe` `B4939F68…`（留用别重编）、`s6/{cc_bmerge,run_bmerge,k1_topup,k1_gates}.ps1`、`s6/{bmerge_sum,k1_add_batch_res,k1_engine_bmerge,k1_fix_*,k1_add_*,k1_dep_probe,k1_bands,k1_mkledger}.py`、`s6/BMERGE_F{0..3}.log`、`s6/BMERGE_DCHK_F{0..3}.log`、`s6/BMERGE_twin_F{2,3}.log`、`s6/BMERGE_ledger.csv`、`s6/bmerge_sum.txt`、`s6/K1_dep_trace.log`、`s6/k1_probe_{fix,add_*}.py`。
进程：**`nr_replay=0 / batch_merge_probe=0 / LOP=0`**（挂死的 pid 4024 已杀）。
**热状态**：本会话 GPU 累计 ≈ **65 分钟**（含 22 分钟挂死进程）⇒ **下次开工先凉 ≥5 分钟**；跨配置对照仍须同热交替。

# §59 下一步建议（等裁决，未动）
1. **closure 级刀 1 判死**（R9/R10 的证据链），把"同形腿相邻 + 面不被回收"作为**任何合并刀的前置条件**写进 §7.1 的依赖列：刀 1/刀 3 都吃这条；
2. 机器可查的换序规模：96 个 residual 站点里**相邻（cmd 连续）的同形腿对 = 0**（组成员间隔 10 = 一条链的长度）⇒ 换序 = 重排记录序列，属 port-E 量级；
3. 若继续找"画质零代价"的帧钱：优先 **C1（quant 折进生产者 store）** 与 **③ window-major 面布局**（§50：pack 腿 23.7-34.9%/链），它们不依赖跨链换序；
4. 仪器全部保留可复用：`batch_merge_probe.exe` + `BMERGE_*` 日志 + 台账 + `shapes_alive.csv`（刀 3 的 A4 族若要测，换 `BMP_FAM` 加两族即可）。

---

# §60 port-E 阶段 A（bench 原型，不接图）= 跑完　14:1x-14:5x　**验收线未达标（G2）⇒ 按军规 39/令：不下形态结论**
**基座与仪器**（全部 bench 层；**仓内源一字未改**，porcelain 0，tip `42da541`）：
- `src/bench/sycl/port_ffn_fused.cpp` = 他们 FFN 融合核的忠实 ESIMD 移植（13 检查点）→ exe `oneapi\port_ffn_fused.exe` **`00613DFF…`（本轮重编，替换 11-01 的旧件）**；
- `src/bench/sycl/s6_ffn_block4.cpp` = 我们的 1a 链 + 他们的 R1/R2 零-pack 生产者（"1aR1"，M 铲编译期开关）→ `b4_base.exe FF8E19E3…`（`/DM_P4FORM=0`）、`b4_m2b.exe 77A3E9F9…`（`/DM_P4FORM=0 /DM_PEAK=1 /DM_P3SPLIT=1`）；另 `pe_ffn_block4.exe 0AF4868E…` = 仓内默认 defines（= M1 档，已知劣化，留形）；
- `src/bench/sycl/s6b_att.cpp` = att 半链 5 发合一相（12 检查点）→ `pe_s6b_att.exe 18F87833…`；
- 跑批 `s6/pe_runA.ps1`（背靠背矩阵）+ `s6/pe_runB.ps1`（**60 s 进程间隔的 G1/G2 阶梯**）；解析 `s6/pe_look{1,2,3,4}.py`；屋顶对照 `s6/pe_roof.py`；链价 `s6/pe_chain48.py`；缓存独立 `E:\DSH\sycl-cache-portE`；台账 `s6/spillcheck_port.py`、`s6/spillcheck_s6b.py`。

**A 级对拍（13+4 检查点）**：
- att 半链：**GATE GREEN（0 checkpoints differ）×3 进程，12/12 全 0**（pk0/sc0/Q/K/V/scores/probs/att/pk2/sc2/pk2-folded/**1270-FINAL**）+ LIVENESS 反证（probs×0.5 ⇒ 1270 有 2,082,479/2,088,960 half 变 ⇒ 非哑火）；
- 1aR1（block4）：**GATE PASS C2-R1 13/13 diff=0 ×4**（base/M2b × S1/S2）；
- 他们核（port_ffn_fused）**LW=16 档 10 进程全 GATE PASS（13/13）**；**⚠ LW=32 档 5 进程中 1 进程 GATE FAIL**：`DIFF out-1275 193/4,177,920 B`、`DIFF sc3 9/32,640`（first row **29872**：ref `2.01574802` vs port `2.26771665`）、`DIFF 1267-FINAL 996 B` ⇒ 单行**行峰**取到不同值 ⇒ **该档不可信**（与 §3 barrier 形式 / `M_BAR` 的 ACQUIRE 缺失同源，未归因到行）；
- **四项接口检查点在 LW=16 全绿**：面布局字节序（`pk1-face=0`、`faceA-vs-faceB=0`、`pk2-frag=0`、`pk3-frag=0`）、scale 粒度（`sc1/sc2/sc3=0`）、e4m3 编码（`e4m3-enc 8,355,840 B=0`、`e4m3-dec 16,711,680 B=0`）、epilogue 出口形态（`out-1275=0`、`1267-FINAL=0`、`1270-FINAL=0`）。

**B 级单价（G1/G2 × 相，min-of-15×5、60 ms 组间、nosink；进程间 60 s）**：

| 档 | LW | SLM(B) | 线程 | wall msM | P2 expand | P3 requant | P4 contract | P5 outq | P6 res | **P4 TOPS** |
|---|---|---|---|---|---|---|---|---|---|---|
| **G1 忠实** | 16 | 20,992（≤32KB 崖内） | 8,160 | 0.7183 | 0.1940 | 0.2954 | **0.0291** | 0.0319 | 0.1676 | **36.8**（间隔跑 36.54/37.47/37.75/37.89/39.34） |
| **G2 喂饱** | 32 | 41,984（**越 32KB 崖**） | 8,160 | 0.7516 | 0.1938 | 0.4008 | 0.0625 | 0.0107 | 0.0794 | **17.1**（14.90-18.11） |
| LW=64/128 | — | 83,968 / 165,888 | — | **SKIPROW：SLM > 65,536 帽**（S1 G16、S2 G8、S2 G16 三档编译期自拒） | | | | | | |

⇒ **G2 的 P4 = 17.1 < 39.6 ⇒ 验收线未过 ⇒ 本轮不下任何"谁的形式更好"的结论**。自查（七项缺哪几项）：
- **② 几何与 ⑦ 供数在他们的形下互相冲突**：`grid×LW ≡ ngrp×W`（S1 恒 **8,160** 线程 = 甜区 130,560 的 1/16）⇒ **抬 LW 不抬并发，只把 SLM 推过占用崖（驻留 3→1）**；要真喂饱必须动 TG（32-token 组，被 `static_assert(TG==16)` = R7 禁）、split-K（被 ① 禁）或 W（被 64KB SLM 帽禁）⇒ **七项在他们的核上无法同时成立**（这不是"没搬全"，是**结构性互斥**，证据 = 三行 SKIPROW + 两档 P4 对比）；
- **① 核已搬且逐位**（13/13），但**计价腿台账不干净**：`port::fused` = grf 128 / simd 1 / slm 21,504-29,696 / **private 6,304-6,464 B / scratch 指令 178-289**；我们的 `ffn2::fused`(1a) 与 `att5L::fused`(att) = **private/spill/scratch = 0、scratch 指令 0** ⇒ 健康闸第 4 条**他们不过**（port-C1 已归因的慢因，本轮复现）；
- ③④⑤ 在 LW=16 档均有证据（零-pack 面 `retile_a 2,088,960 B` + `retile_b 16,384 B`、e4m3 逐位、requant/publish/pack 全在核内 epilogue）；**⑥ "11 发 → 3 发"只有两半各自成立，尚未合成**（见"缺口"）。

**占屋顶 %（军规 26/37，按 (dtype,N,K,M)，M 成轴）**：
- P2 expand（int8 M=32640 N=256 K=64 b1）：同形屋顶 `gemm_b 0.1382 ms = 7.74 TOPS` ⇒ 实测 0.1940 ms = 5.52 TOPS = **71%**（该相还含 e4m3 编码 + SLM 落盘 ⇒ 非纯 gemm 腿）；
- P4 contract（N=64 K=256，**屋顶表无同形点**）⇒ 用全表最佳 int8 **41.24 TOPS**（M=1536 N=4096 K=1024）作上界 ⇒ 36.8 = **89%**；对照同 FLOPs 的 N=256/K=64 屋顶则快 **4.9×** ⇒ **"瓶颈不在 dpas"的定量证据**；
- P6 res（N=64 K=64 M=32640）：屋顶 3.44 TOPS（**spread 46.5% ⇒ 低可信**）⇒ 实测 1.59-3.36 = **46-98%**；
- 链整体 CHAIN TOPS = 3.35（G1）/ 3.20（G2）。

**每链单价 vs 现路**（**bench 内同仪器对照，不与 RUN_TIMING 串价混账**）：
- FFN 半 S1（C=64 M=32640）：现路 split 8 发 **0.8139** → 我们 1a **0.4647** → **1aR1 base 0.4731 / M2b 0.4109-0.4142**（GPU 0.3498-0.3507；all-in 含生产者 0.5255-0.5263）→ 他们核忠实移植 **0.7183**；
- FFN 半 S2（C=128）：split 0.5898 → 1a 0.3787 → **1aR1 M2b 0.2730**（GPU 0.2144；all-in 0.3883-0.3926）→ 他们核 0.4230（n=1）；
- att 半 C=64：现路 5 发（bench 内 cum）**0.6484** → 合一相 **wall 0.4329 / GPU 0.3531** = **−33% wall / −45% GPU**；att 半 C=128：**反而 +51%**（SLM 41,984 越崖）；
- **两半相加（bench 内）**：现路 0.8139 + 0.6484 = **1.462** → port-E 形态 0.411 + 0.433 = **0.844**（**−0.618 ms/链 = −42%**）；
- **8 条 C64 链外推**：`tools/rt_per_closure.csv` 实测 **chain 48 = 1.525 ms/链**（11 发：641/644/646/648/650 quant ≈0.002、**647/649 两条 batched 已被 1a no-op**、651 residual 0.5326 携带融合 FFN、att 半 642+643+645 = 0.978）；8 条 C64 链（0-3、48-51）实测 **1.217-2.116，均值 1.658 ms/链** ⇒ 按 bench 内 −42% 折算 = **−0.70 ms/链 ⇒ 8 链 −5.6 ms 串行 ⇒ 帧 −2.4 ms**（×0.43）；
- ⚠ **§50 的预测（0.61-0.81 ms/链、−10.4…−11.9 串行、−4.5…−5.1 帧）是拿 2.080 ms/链（1a 之前）当基线**；1a 出货后 C64 链实测基线只有 1.525-1.658 ⇒ **预测里约 0.4-0.55 ms/链已被 S6-1a 先吃掉**（军规 42/43 同一课）⇒ 诚实净值 = **串行 −5.6 / 帧 −2.4**，不是 −11。

**最难搬的一项 = ② 几何**：他们的并行度天花板（8,160 线程、LW=16、SLM 21.5 KB）与 A770 的占用崖/甜区结构性冲突；抬并行度必然放弃忠实几何（TG/W/split-K 三把都被禁或被帽挡），而放弃之后 port-E 就退化成 **"我们的 1a 链 + 他们的 R1/R2 零-pack 接口"** —— 这一条**已经跑通且更快**（M2b 0.411 vs 他们核 0.718，att 半 0.433 vs 0.648）⇒ **port-E 的真价值在接口（R1/R2/R4 零 pack + 折叠 epilogue），不在他们的核**。

**本轮未做（诚实缺口）**：
1. **端到端合成 bench（11 发 → 3 发）未写**：两半各自绿、各自有价，但"att 半的输出面（pk2/pk3 frag 序）直接喂 FFN 半的输入面"的合成体尚不存在 ⇒ 需要新建 `port_e_chain.cpp`（把 `att5::fused` 与 `ffn2c::fused` 在一个 TU 内按共享面串起来）；
2. G2 档结构性无法达成 ⇒ 验收线未过；
3. LW=32 的 flaky gate 只定位到"行峰不同"，未定位到指令级原因（`M_BAR=0` 的 `esimd::barrier()` 无 ACQUIRE 是首要嫌疑，port-M 已标过 M-FLAKY）。

# §61 新坑 P18 + 现场（14:5x 实证）
- **P18（本轮实测，重要）**：**背靠背进程阶梯会把 TOPS 压低 2 倍以上**。同一 `S1 LW16 KN1` 档：15 进程连跑（`pe_runA`）P4 中位 **15.06**（14.03-19.23）；改 **60 s 进程间隔**（`pe_runB`）P4 中位 **37.7**（36.54-39.34）= 与 `notes/port-C1.md` 的 **39.6** 对齐 ⇒ **进程内 min-of-15×5 不防热**；阶梯类测量必须逐进程间隔 ≥60 s 并记 batch 时长（`pe_runB` = **13.1 分钟**，`pe_runA` ≈ 9 分钟）。
- 现场：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE…**（本轮**从未 stage**）；三金标 **DD49827D / DD49827D / 249A46F3** ✓ 未动；`out\test_*.dll` ✓ 未动；仓 porcelain **0**、tip **`42da541`**、**未 commit/未 push**；`oneapi\` 新增/替换 bench exe：`port_ffn_fused 00613DFF…`(3,069,952 B，替换旧 3,049,472 B)、`pe_s6b_att 18F87833…`、`b4_base FF8E19E3…`、`b4_m2b 77A3E9F9…`、`pe_ffn_block4 0AF4868E…`；`batch_merge_probe B4939F68…`、`knife2_probe B5A82BE2…` 未动。
- 进程 **0 残留**；本轮 GPU ≈ **22 分钟**（矩阵 8.9 + 阶梯 13.1）⇒ 全会话累计 ≈ **87 分钟** ⇒ **下次开工先凉 ≥5 分钟**。

# §62 合成的关键问题（阶段 B 的前提）= **回答：零-pack 合成在"64-token 窗口"档成立**（代码级证据，未跑 GPU）
两半的 A 面 fragment map 逐式对比（`s6/pe_iface.py` / `s6/pe_bands.py` 提取）：
- **att 半**（`s6b_att.cpp:510`）：`PKT + (kb*2048 + row*32)`，`TOK=64`、`KBN=C/32`、`PKT = KBN×2048 B`（+ `AS2 = Z0 + KBN*2048`，scale 单列 `AS2 + row*4`）；
- **FFN 半**（`s6_ffn_block4.cpp:281/289`）：`O_PK + ((kb*BANDS + (t>>4))*512 + (t&15)*32)`，`BANDS=(T+15)/16` ⇒ **T=64 时 BANDS=4 ⇒ 该式 = `kb*2048 + t*32` ⇒ 与 att 半逐位同形**；scale 同理 `O_SC + t*4`。
- **他们的 port 核**（`port_ffn_fused.cpp`）：`TG=16 × G=4 = 64 token/WG`、每 16-token band 512 B ⇒ **同一 map** ✓✓。
⇒ **结论（给阶段 B）**：三方的 A 面 map 在 **64-token 窗口 + kb 块 2048 B + 16-token band 512 B + 每 token 32 B** 这一档**完全一致** ⇒ "att 半 P10 的出口面直接喂 FFN 半 P1 的入口面、**不加 pack 腿**"（健康闸第 3 条）**在布局上成立**。
⚠ 但**当前 block4 的 S1 跑的是 T=32**（台账 `ffn2::fused T32 C64 HID256`）⇒ 合成必须把 FFN 半的 token-group 抬到 **T=64**（BANDS=4），这是一次**几何改动、要重新计价**（port-C1 已证 T/LW 改动会挪 SLM 与占用：S1 T=32 的 SLM=31,744 B，T=64 会翻倍 ⇒ 撞 32KB 崖的风险要先测）。
⇒ 阶段 B 的最小验证顺序建议：① 先把 FFN 半在 `T=64` 下重跑 gate+价（一个进程，`s6_ffn_block4.cpp` 的 Shape 模板换 T）；② 再写 `port_e_chain.cpp` 把两半按共享面串成 3 发；③ 才谈接图（记录/计划层换序）。

---

# §63 B0（前置：把 port 核 LW=32 的 flaky 归因到指令级）　15:0x- 进行中
**判别器（正在跑，`s6/pe_b0.ps1`，job `pwsh-3a602c094c934e01`）**：三臂，每臂独立进程、进程间 **60 s**（军规 45/P18）：
- **A `KN=1 LW=32`（出事格）×10**、**B `KN=0 LW=32`（无 global RAW）×10**、**C `KN=1 LW=16`（同 RAW、小 WG）×5**；计数 = GATE FAIL 次数。（注：`M_BAR` 是 **block4/1a** 的开关，**port 核没有这个开关**——它从头到尾用的是真 `group_barrier`（`port_ffn_fused.cpp:347/398/447/500`），所以对 port 核而言**"栅栏类型"这一维已经被排除**；能分离"是否存在跨波 global RAW"的开关是 **KN（C1 的 SLM 刀）** ⇒ 判别器按 KN 做，等价且更直接。）

**代码级定位（已做，原文照抄）**：
- PHASE 3 出口（`port_ffn_fused.cpp:433-435`）：
  ```
  if (KN == 0) esimd::slm_block_store(OUTP + (uint32_t)r*(C*2u) + (uint32_t)col*2u, hh, overaligned_tag<16>{});
  hh.copy_to(a.dOut1275 + (size_t)(r0 + r)*C + col);   // their :98 (the 1275 plane)
  ```
- **中间只有一个 `group_barrier(gr);`（:447）**；
- PHASE 4 行峰（`:461-470`）：
  ```
  const half* rowp = a.dOut1275 + (size_t)(r0 + r) * C;
  esimd::simd<half,16> h = (KN == 0) ? esimd::slm_block_load<half,16>(OUTP + ...)
                                     : esimd::block_load<half,16>(rowp + c*16, overaligned_tag<16>{});
  mx = esimd::max(mx, esimd::abs(esimd::convert<float>(h)));   ...   float peak = esimd::hmax<float,float,16>(mx);
  ```
⇒ **`KN=1` 时 PHASE 4 从 GLOBAL 读回 PHASE 3（同一 WG 的其它波）刚写的 1275 行**；`KN=0` 时读的是 SLM 副本（`OUTP`）⇒ **没有跨波 global RAW**。这正是两臂的差别，也是"1/5 进程失败、且只在 LW=32"的宽度解释（LW=32 ⇒ 每 WG 波数翻倍 ⇒ 跨波窗口更宽）。
**`barrier_audit.py` 的两栏（§44 升级仪器，跑在 shipped 目录：`s6/barrier_audit_pe.csv`，38 行）**：它**不覆盖 bench 文件**（`port_ffn_fused.cpp`/`s6b_att.cpp` 不在名单），但对 **1a（`ffn2::fused`）** 给的是：`verdict_source = RACE`（O_PK/O_HID/O_PKH/O_OUT 四条 HANDOFF/REUSE），而 **`verdict_machine` = 实测：`esimd::barrier()` 与 `group_barrier(it.get_group())` 编出**同字节数的 .text**（S1 md5 `053032299BADFDC09BE3144438741E26` / S2 `21DDE963AC6AF9BEDEBB6B1EA6B28795`），都发 **8 条 signal barrier**；DM_PROBE 加 1 条 ⇒ 9 条 ⇒ **"读写在机器级是同一类 CTA 栅栏"** ⇒ 源码级 RACE 条目在机器级不成立**。⇒ 按 §44，port 核 flaky **不是"栅栏类型错"**；剩下的可能只有 (i) **栅栏位置/数量不够覆盖 global 可见性**（CTA barrier 是执行栅栏，**不等于 global L1 一致性**；跨波 global RAW 需要 coherent 存取或额外 fence），或 (ii) **行峰的归约/初始化**（`mx` 每行重置为 0 ✓、`hmax<16>` 顺序固定 ⇒ 无归约序问题；`esimd::max/abs` 无未初始化读 ⇒ **排除 (ii)**）。⇒ **首要嫌疑 = (i)：`KN=1` 的跨波 global RAW，缺的是 coherent fence，不是 barrier 类型**。
**出错行的坐标（解析，已算）**：`sc3` 只有 **9/32,640** 处不同、first row **29872**：
- 面布局 M=32640 = **510 windows × 64 tokens** ⇒ row 29872 = **window 466（0-based）、token-in-window 48**；band = `48>>4` = **3**、lane = `48&15` = **0**、col 0；
- 两个 scale 反推行峰（`scale = peak/127`）：ref `2.01574802 × 127 = 256.0`（f16 精确）、port `2.26771665 × 127 = 288.0` ⇒ **port 那一行看到的最大值是 288，参考是 256**；
- 对应 A 面坐标：row-major `dpk1 + 29872*C + kb*32`；fragment 序 `grp = 29872/16 = 1867, r = 0` ⇒ `dfrag + 1867*(16*C) + kb*512 + 0*32`；a_scale = `dsc1[29872]`；
- ⇒ **288 是"上一轮发射留下的值"而不是乱码**（bench 会对同一面连发 225+ 次，面被复用）⇒ **典型的"读到上一次发射的旧行"**，与"缺 global 可见性 fence/多一次栅栏"完全吻合（若是别名污染会大面积错，不会只有 9 行）。
**临时规矩（写进账，即刻生效）**：**归因未结之前，任何新合成链一律禁 `LW=32` 档**（只用 **LW=16** 与 **T=64**）；**带 flaky 的档不得接进 shipped**。
**计数与结论 = 待 job 完成填入**（A/B/C 三臂 fails 数）。**若 B 臂（KN=0）0 失败而 A 臂有失败 ⇒ 跨波 global RAW 坐实 ⇒ 修法 = 让 PHASE 4 读 SLM 副本（KN=0）或给 1275 的写/读加 coherent 通道，不是加 barrier**；届时对**已出货 1a** 的建议 = 审它有没有同类"跨波 global RAW"（`ffn2::fused` 的 O_OUT 是 SLM ⇒ 预计没有），**只报不改**。

---

# §64 B1（先算字节再编）= **算术过关，但几何不过 ⇒ 不编 T=64；合成改走 T=32 + 参数化 global 面 stride**（按军规 22/30 先回报）
**逐项 SLM 表（公式取自 `s6_ffn_block4.cpp:164-176`，S1 = C=64 / HID=256 / KS4=4 / KS6=2；`SLM = ((O_SC+SZ_SC+15)/16)*16`）**

| 区域 | 公式 | **T=32（现档）** | **T=64** |
|---|---|---|---|
| `O_PKH` hidden-int8 A 面 | `KB_H·BANDS·512`（KB_H=8） | 8·2·512 = **8,192** | 8·4·512 = **16,384** |
| `O_PK` pk 面 | `KB_C·BANDS·512`（KB_C=2） | 2·2·512 = **2,048** | 2·4·512 = **4,096** |
| `O_HID` hidden f16 | `T·HID·2` | 32·256·2 = **16,384** | 64·256·2 = **32,768** |
| `O_OUT` out f16（= M2 的 `O_PEAK` 别名，`SZ_PEAK=T·(HID/16)·4`） | `T·C·2` | 32·64·2 = **4,096**（peak 4,096 ✓ 别名成立） | 64·64·2 = **8,192**（peak 8,192 ✓） |
| `O_SC` 三个 scale 槽 | `3·128`（注释写死 **T≤32 floats each**） | **384** ✓ | **需要 3·256 = 768 ⇒ 现码 `O_SC+128`/`O_SC+256` 两处偏移会串槽 = 硬结构阻塞** |
| **合计 / 取整** | | **31,104**（JIT 台账实测 **31,744** ⇒ 驱动 padding 640） | **62,208**（+padding ≈ **62,848**） |
| 对 32,768 占用崖 | | **崖内 ⇒ 2 resident WG/slice** ✓ | **越崖 ⇒ 1 resident** |
| 对 65,536 硬帽 | | ✓ | ✓（勉强，余量 2,688 B） |

**几何（活动图）不过 —— 这才是决定项**：`nd_range(range(nblk·64), range(64))` ⇒ **每 WG 固定 64 个 ESIMD 线程**（`:253`），而各相的活跃线程数 `ACT`（`:193-205`）在 T=64 时**超出 WG**：
| 相 | ACT 公式 | T=32 | **T=64** |
|---|---|---|---|
| P2 expand | `(T/8)·(HID/16)` | 64 = LW ✓ 全活跃 | **128 > 64 ✗** |
| P4 contract | `(T/8)·(C/8)`（form2） | 32 ✓ | **64 ✓（刚好）** |
| P6 residual | `(T/8)·(C/8)·KS6` | 64 ✓ | **128 > 64 ✗** |
| P3（M2b） | `64` | 64 ✓ | 64 ✓ |
⇒ **T=64 需要 LW=128**，而 **`LW≥128 + barrier` = 已证的死锁区**（`notes/s6-port-spec.md` D1，前辈 256 线程/WG 在 ESIMD 下直接 HANG）；否则要给 P2/P6 加 per-thread 循环 = **改核心**（违反"不许顺手改数值/形态"）。
⇒ **B1 裁决：不编 T=64**（算术虽过硬帽，几何与 scale 槽两处都撞）。

**改道（不损失任何东西，且更省）**：合成**不需要 T=64**。两半的**元素级 fragment map 本来就同形**，差的是 **kb 块的带宽数**：
- att 半（`s6b_att.cpp:510`）：`PKT + kb·2048 + row·32`，row=0..63 ⇒ 每 kb 块 **4 个 16-token band**；
- FFN 半（`:281`）：`O_PK + (kb·BANDS + (t>>4))·512 + (t&15)·32`，BANDS=2 ⇒ 每 kb 块 **2 个 band**；
⇒ 把 FFN 半的 **global A 面寻址参数化**成 `kb·2048 + (hb·16 + band)·512 + lane·32`（`hb ∈ {0,1}` = 窗口半，随 WG 的 token 段给定）⇒ **T=32、LW=64、SLM 31,104（2 resident）一字不动**，只是把入口面的 kb stride 从 1024 改成 2048 + 一个 band base ⇒ **零 pack 腿、零 quant 腿**（健康闸第 3 条 ✓），且 FFN 半内部 SLM 的 PK 图不变。
**代价/待验**：一个 WG 处理的 32-token 段落在别人的窗口里 ⇒ **1 个窗口要 2 个 WG**（S1：510 窗口 ⇒ 1020 WG，与现档 `nblk=M/T=1020` **完全一致** ✓ 网格不变、只是面 stride 变）。⇒ **B2 按这条路写**。

---

# §65 B0 读数（**竞态坐实**，但不是我们原先猜的那把）　15:0x-15:4x
**① 冷进程判别器（`s6/pe_b0.ps1`，job `pwsh-3a602c094c934e01`，batch 31.6 min，0 残留）**：三臂各独立进程、进程间 60 s：
`KN=1 LW=32` **fails 0/10**、`KN=0 LW=32` **0/10**、`KN=1 LW=16` **0/5** ⇒ **冷档分不出**；把全部历史样本合起来：`KN=1 LW=32` = **1 fails / 20 进程**（pe_runA 5 + pe_runB 5 + B0 10），`KN=1 LW=16` = 0/15 ⇒ **基率 ≈ 5%，n=10 不够**（Fisher p≈0.5）⇒ **按令"≥10 冷进程"这条路不能归因**。
**② 换放大器（决定性）**：`E:\DSH\tmp\pe_stress.cpp`（**仓外副本**，源 = `port_ffn_fused.cpp`，md5 `3DB5E9D3…`）+ `s6/pe_mkstress.py`：同一进程内**连发 200 次 DUMP 核**，每次发射前把跨波交接面 `dOut1275` **memset 成哨兵 0xA5**，然后与 launch-0 的 `OUT/PK3/SC3/FR3` 逐字节比 ⇒ **不需要参考链就能测"自身可重复性"**（军规 31 的强化版）。读数（`s6/pe_b0s.ps1`，job `pwsh-000ab6ff01f047e1`，5.2 min）：

| 臂 | launches | **bad** | 带哨兵字节的次数 | 首个 bad |
|---|---|---|---|---|
| KN=1 LW=32 | 200 | **0** | 0 | — |
| KN=0 LW=32 | 200 | **0** | 0 | — |
| **KN=1 LW=16** | 200 | **4**（s=20/147/166/178） | 0 | dOUT=189 dPK3=583 **dSC3=27** row=17040 col=0 |
| **KN=0 LW=16** | 200 | **2**（s=132/135） | 0 | dOUT=98 dPK3=268 **dSC3=14** row=14336 col=0 |
⇒ **竞态坐实：port 核在 200 连发里 2-4 次（≈1-2%）产出与自身前一次不同的面**；并且原先的"只在 LW=32 / 只在 C1 刀（KN=1）"两条猜测**都被证伪**：
- **不是栅栏类型**：`KN=0/KN=1` 都翻；§44 机器级实测已证 `esimd::barrier()` 与 `group_barrier` 编出同一类 CTA 栅栏（8 条 signal barrier）⇒ 换类型无用；
- **不是 C1 的 global 读回刀**：`KN=0`（读 SLM 副本）同样翻；
- **不是 WG 宽度**：本轮 **LW=16 反而比 LW=32 更容易翻**（4/200 vs 0/200）⇒ 之前 1/20 集中在 LW=32 是小样本 + 背靠背热态，不是几何因果；
- **不是"读到哨兵"**：`sentinel_pairs = 0` ⇒ 错的字节不是未写过的槽，而是**别的真实值** ⇒ 排除"单纯读早了看到 0xA5"。
**③ 偏差的形状（定位到组级）**：出错行 **17040 / 14368 / 10272 / 2064 / 14336 全是 16 的倍数** = **fragment band / 每 WG 16 行的边界** ⇒ **整个 work-group 一级**的偏差；每次数到 **10-30 个行 scale**（`sc2/sc3`）不同 ⇒ 与 §57 那次 `first row 29872`（= 16×1867 ✓ 同样 band 对齐）同一签名：**行峰取到不同值 ⇒ 下游 pk3/out/1267 跟着差**。
**④ 剩下唯一活着的机理族 = 同一 WG 内跨波的 SLM 槽可见性/顺序**（不是 global、不是栅栏类型）：候选点已缩到两处——
 (a) `SCB`（行 scale 槽）：**4 字节粒度**跨波写 + 读（`:374 store(SCB + r*4, simd<float,1>)`；`:422-423 load<float,8>(SCB)`；`:474 store(SCB + 64 + r*4)`）；
 (b) `HIDF` 的 **in-place requant**（`:361-369` 先整行读峰、`:376-385` 再把同一批字节**原地覆写**）：PHASE 2 内**没有** barrier，行所有权虽按 `r = w*RPI + i` 划分（S1 RPI=4 ⇒ 每波 4 行、互不重叠 ✓），但 `HIDF` 的字节跨度是 `kb*512 + r*32` ⇒ **同一 512B band 内混着 4 个波的行** ⇒ 若 band 的写/读在机器级不是 32B 原子，就会出现"读到别的波刚覆写的行字节"的**组级**污染 ⇒ 与签名（band 对齐、整组 scale 变）吻合。
**⑤ 临时规矩（即刻生效，写进账）**：
1. **归因未结之前，任何新合成链禁 `LW=32` 档**（只用 LW=16 与 T=32）✓ 原令；
2. **追加**：合成链**一律用 KN=0（保留 SLM out 副本）**，不用 C1 的 global 读回刀（两臂都翻，而 KN=0 的翻法不依赖 global ⇒ 少一个变量）；
3. **追加**：**任何新核进 shipped 前必须过 200 连发压力门（bad=0）**（`pe_stress` 的哨兵法可以照搬成通用仪器），单进程一次 ≈ 15 s ⇒ 便宜；
4. **对已出货 1a 的建议**：同一个放大器套到 `ffn2::fused`（block4 的 DUMP 面）上跑 200 连发 ⇒ **只测不改**；若它也 bad>0，那 §43 的 RACE 条目就不是"机器级不成立"，而需要按 §44/§52 的**拆槽/挪相**修法（不是加 barrier）。**我下一步就去做这个读数。**
**⑥ 仍未结的部分（诚实）**：没做到"指令级"（未反汇编到具体 `lsc_load/store` 的 cache-control 位与 barrier 插入点）；那需要把 `pe_stress` 的失败样本配上 `ocloc` 反汇编 + 把 `HIDF` 的 band 跨度改成 32B 对齐分区做 A/B。⇒ 建议 B2 之后补这一刀，或先做 1a 的 200 连发（便宜、决定 shipped 是否有暴露）。
**热状态**：B0 冷阶梯 31.6 min + 压力 5.2 min ⇒ 本轮 GPU ≈ **37 分钟**；最后一次动作 15:4x ⇒ 下一段跑前凉 ≥5 分钟。

---

# §66 第 1 步（放大器套我们自己的核）= **判决 ①：两核 bad=0 ⇒ 出货件不暴露，port 核的病是它自己的**　15:5x-16:1x
**跑法**（`s6/pe_s1.ps1` 7.8 min + `s6/pe_s1b.ps1` 9.5 min，进程间 60 s，0 残留）：
| 核 | 进程 | 连发 | **bad** | 备注 |
|---|---|---|---|---|
| **`ffn2::fused`（已出货 1a 形态，`b4_base.exe` = M_P4FORM=0/PEAK=0/P3SPLIT=0）** | **3** | 200 each | **0 / 0 / 0（共 0/600）** | 每进程同时 **B3GATE PASS（9 ffn2 检查点 vs block3）** + **GATE PASS C2-R1（13/13）** |
| **`att5L::fused`（我们的 att 5 发一相）** | **3** | 200 × 两形（C=64 与 C=128） | **0（共 0/1200）** | 同时 **GATE: GREEN（0 checkpoints differ）× 两形 × 3** |
| `port::fused`（他们的核，对照） | 2 | **1000** each | **4 / 4** | 见下 |
| `qr_kernel_rowthread<64>`（无 SLM 无栅栏的负对照） | 1 | 200 | **0** | 仪器不误报 ✓ |
⇒ **统计**：我们的核 **0 bad / 1800 连发**；他们的核 **12 bad / 2400 连发（≈0.5%）**（4/1000 + 4/1000 + 0/200 + 4/200）⇒ Fisher 双侧 **p ≈ 2e-4** ⇒ **不是运气，是他们的核不可重复、我们的核可重复**。
**⚠ 方法学教训（写死）**：**200 连发不够**——同一 port 核一个 200 连发进程 **bad=0**、两个 1000 连发进程各 **bad=4** ⇒ 真基率 **≈0.5%**（不是 §65 估的 1-2%）⇒ **军规 46 的门要按"≥1000 连发 bad=0"执行**（200 只能当快速筛）；这也是 §65 那次"1/20 进程"读数的来历（0.5% × 20 ≈ 10% 概率抽中一次）。
**签名收窄（指令级归因的关键线索，比 §65④ 更硬）**：1000 连发里 8 次失败的**行号 mod 16 = {0: 4, 7: 4}** ⇒ **全部落在 16 行 tile 的 8 行 fragment 边界**（`row%16==0` = tile 首行、`==7` = 第一个 8 行半片的末行）⇒ 与 port-B 记过的 ESIMD 硬坑 #18(2)（**dpas 累加器 fragment 只有 8 行，`select<8,1>(row*8)` 的 row 必须 0..7**）同一边界族 ⇒ **嫌疑点收窄到"跨 8 行半片的 SLM 槽/带边界"**（`HIDF` 的 `kb*512 + r*32` band 里 16 行混 4 个波 + `SCB` 4 字节槽），**不是 global、不是栅栏类型、不是 WG 宽度**（`sentinel_pairs=0` 全次成立 ⇒ 不是"没写过的槽"）。
**临时规矩更新**：合成链继续禁 `LW=32`、用 `KN=0`；**新增**：任何进 shipped 的核 **≥1000 连发 bad=0**（200 只做快筛）。

# §67 第 2 步（仪器进仓，军规 46 可执行）= **完成，两颗牙都验过**
**仓内改动（bench 层，shipped 源未碰）**：
- `src/bench/sycl/stress_repeat.cpp`（新，untracked）= **负对照**：`qr_launch_esimd`/`qr_kernel_rowthread<64>`，M=32640、哨兵 memset、200 连发自比 ⇒ 实测 **bad=0** ✓（exe `oneapi\stress_repeat.exe` `9C8D0062…`）；
- `src/bench/sycl/port_ffn_fused.cpp`（+40 行，`PORT_STRESS=N`）⇒ 重编 `oneapi\port_ffn_fused.exe` `3BFCF6C7…`；
- `src/bench/sycl/s6b_att.cpp`（+61 行，`S6B_ATT_REPEAT=N`；**fATT 故意不 scrub/不比**：核不重写整块 att 面 ⇒ 第一版把它算进去造成 **bad=199/200 的假警**，已排除并注明在源码注释里）⇒ 重编 `oneapi\s6b_att.exe` `AB4ADC03…`；
- `tools/stress_repeat.ps1`（新，untracked，纯 ASCII）= 四臂矩阵（ctrl / port / att / ffn2）+ **60 s 进程间隔** + **自动"牙齿检查"**（CTRL 必须 bad=0、PORT 必须 bad>0，否则报"仪器坏了/正对照丢信号"）；
- `ffn2` 那一臂用的是仓里**已有**的 M-FLAKY 探针（`s6_ffn_block4.cpp:1580-1620`，`M_REPEAT=N`，taps 先 memset 0xA5 再逐发比 block3）——**注意它只在 `C2_STAGE=1 或 3` 才跑**（`C2_STAGE=2` 会释放 1a taps ⇒ 探针静默不执行，第一次跑就是这么漏掉的）。
**两颗牙（同一台仓内仪器）**：负对照 `qr_kernel_rowthread` **bad=0/200** ✓；正对照 `port::fused KN=1 LW=16` **bad=4/1000** ✓（200 连发时会显示 0/200 ⇒ 正对照需要 n≥1000）。
**现场**：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE** ✓ 未 stage；三金标未动；仓 porcelain = ` M port_ffn_fused.cpp` / ` M s6b_att.cpp` / `?? stress_repeat.cpp` / `?? tools/stress_repeat.ps1`（**未 commit/未 push**）；临时副本 `E:\DSH\tmp\pe_stress.cpp` `F3552A9C…`、`E:\DSH\tmp\pe_stress_att.cpp` `0CF3CEB2…`（已被仓内版取代，可删）；exe：`pe_stress 3DB5E9D3…`、`pe_stress_att E1F6345E…`、`b4_base FF8E19E3…`。进程 **0 残留**；本轮 GPU ≈ **55 分钟**（37 + 17）⇒ **下次开工凉 ≥5 分钟**。
**B2 状态：按令按住，等你一句。** 地基已就绪：我们的两半在 1000/600 连发下 self-reproducible=0 bad，接口 map 同形（§62/§64 的 T=32 参数化改道），SLM 算术过关（31,104 B ⇒ 2 resident）。

---

# §68 B2-ready（**续跑包**，用户 2026-11-03 16:2x 令：GPU 交还给游戏，B2 不批不开；这一节只为下次开工不留思考成本）

## ① B2 的第一条命令 = 原样可粘贴
**目标形态（写死，别再重新推导）**：一条 C=64 链 **11 发 → 3 发**
- **发 1 = `att5L::fused<64,2,…>`**（左半，5 腿合一：P7 `QUANT_WINDOW` → P8 `GEMM_INT8_QKV` → P9 `WINDOW_ATTENTION` → P10 `QUANT` → P11 `GEMM_WINDOW_INT8_RESIDUAL`）：`TOK=64`（一个 WG 一个 64-token 窗口）、**LW=16**、`SLMB=32,768 B`（= 占用崖，实测 2 resident）、网格 `windows×16 = 510×16 = 8,160` 线程、`PKT = KBN×2048 B` 在 SLM、map `PKT + kb*2048 + row*32`；**新增出口**：把 P10 的 pk2 以 **FFN 半的全局 fragment map** 落一份 global（见发 2 的 map），**不再**由 FFN 半重新 pack；
- **发 2 = R1 生产者（`quantize + fragment-order store`）**：照 `s6_ffn_block4.cpp` 已验的那一条腿，实测 **0.0892 ms**（`CSVROW;S1;R1_producer_quant+fragstore`）——它把链首 `QUANT` 与"入口面按 dpas fragment 序写"合成**一发**（= §50 的 ③/C1 路线，非新增 pack 腿）；
- **发 3 = `ffn2c::fused`（1a/M2b 形态，T=32）**：5 腿合一（expand → 核内 requant → contract → outquant → residual），**T=32 / LW=64 / SLM=31,104 B（2 resident）/ 网格 1020 WG**，**唯一改动** = global A 面寻址参数化：
  `O_PK 入口地址 = face + kb*2048 + (hb*16 + band)*512 + lane*32`（`kb = 0..1`，`hb ∈ {0,1}` = 64-token 窗口的哪一半，`band = (t>>4)`，`lane = (t&15)`），**内部 SLM 的 PK 图（`kb*BANDS + (t>>4)`，BANDS=2）一字不动**；
- **禁**：`LW=32`（§65 临时规矩 + port 核在 LW=32 的 0/200 与 LW=16 的 4/1000 都不给信任）、`T=64`（§64：ACT2/ACT6 = 128 > LW 64 ⇒ 要 LW=128 = 已证死锁区）、`KN=1`（用 **KN=0** 保留 SLM out 副本，少一个变量）。

**编译（CPU，不占 GPU）**
```
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File E:\DSH\s6\cc_portE.ps1 -Src E:\DSH\dlss-nr-on-a770\src\bench\sycl\port_e_chain.cpp -Out port_e_chain
```
**跑（GPU，先凉 ≥5 分钟；机器读日志走 cmd 原字节 = P16）**
```
Set-Location E:\DSH\oneapi
$env:SYCL_DEVICE_FILTER='level_zero:gpu'; $env:SYCL_CACHE_PERSISTENT='1'; $env:SYCL_CACHE_DIR='E:\DSH\sycl-cache-portE'
& cmd.exe /c "`".\port_e_chain.exe`" > `"E:\DSH\s6\PE_chain_g1.log`" 2>&1"
```

## ② B2 的判据（照抄，不许挪）
1. **逐字节**：**13 项（照 `port_ffn_fused`/block4 的 tap 集：pk1、pk1-face、sc1、hid、pk2、pk2-frag、sc2、out-1275、pk3、pk3-frag、sc3、1267/1270-FINAL + faceA-vs-faceB）+ 4 项接口检查点（面布局字节序、scale 粒度、e4m3 编码、epilogue 出口形态）= 全 diff 0**；任一点 ≠0 ⇒ **停下回报**（贴第一个偏差坐标 + 那行地址表达式原文，军规 25）。
2. **LIVENESS 反证**：把某个中间面 ×0.5 ⇒ 出口必须变（照 `s6b_att.cpp` 的 `LIVENESS(probs*0.5)` 写法，防"哑火合并"）。
3. **两组进程交叉** `--cross`：两个独立进程各自跑 gate，互相逐字节比（防"同一进程内自洽、跨进程不一致"）。
4. **新合成核必须过 `stress_repeat` 的 ≥1000 连发 bad=0**（军规 46/48；200 连发只是快筛 —— §66 实测 0.5% 基率下 200 发会漏报）：
```
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -File E:\DSH\dlss-nr-on-a770\tools\stress_repeat.ps1 -N 1000 -Arms ctrl,port,att,ffn2
```
（B2 完成后要把链 exe 加进 `-Arms`，并在 `s6/spillcheck_port.py` 的 `label()` 里加链核的 mangled 前缀，否则台账会**静默 0 行** = P14 型坑。）
5. **单价**：**≥10 独立进程、进程间 ≥60 s**（P18/军规 45：背靠背把 TOPS 压低 >2 倍）、min-of-15×5、60 ms 组间、**nosink**；台账逐列（key 含 simd+module_id），**计价腿 `private/spill/scratch = 0`、`scratch 指令 = 0`**；每相对 `tools/xmx_roof.csv` 报"占屋顶 %"（按 (dtype,N,K,M)，M 成轴；无同形屋顶点必须明说"低可信"，军规 26/37）。
6. **基线用实测**：`tools/rt_per_closure.csv` 的 **chain 48 = 1.525 ms/链**、**8 条 C64 链均值 1.658**；**不许再用 2.080**（§63⑤/§50 更正）。
7. **目标**：合成体 **≤0.844 ms/链**（bench 内 −42%）⇒ **8 链 −5.6 ms 串行 ⇒ 帧 −2.4 ms**（诚实净值；别报 −4.5/−5.1）。
8. **健康闸六条照旧**：不出现小 M/线程饥饿、**launch 只减不增**（11→3 ✓）、**不新增 quant/pack 腿**（发 2 的 fragstore 就是原 `QUANT` 本身 ✓）、计价腿台账干净、每对对照屋顶表、三关（1301 逐位 / 40 门 / 帧对）不变。

## ③ B2 前必须留的空（下次开工直接照着补，不用重新想）
1. **端到端合成体不存在**：`att5L::fused`（在 `s6b_att.cpp`，1104 行，单 main）与 `ffn2c::fused`（在 `s6_ffn_block4.cpp`，1909 行，单 main）**都是 bench 内联核，没有 header 可 include**；两边还有同名 helper（`Stat/timeit/csvrow/mk/diffbytes`）⇒ **不能 `#include` 拼 TU**（会撞名 + `main` 撞）。做法 = 新建 `src/bench/sycl/port_e_chain.cpp`，用 python 按行区间**机械抽取**两个核体（`att5::fused` ≈ `s6b_att.cpp:100-670`；`ffn2::fused` + `Shape` ≈ `s6_ffn_block4.cpp:150-1100`）进两个各自独立的 `namespace PE_ATT / PE_FFN`，再写新的 host main（≈250 行）。抽取脚本照 `s6/pe_mkstress*.py` 的 marker 写法（幂等、可重放）。
2. **共享面串法（唯一的新数据流）**：att 半的 P10 现在把 pk2 只留在 SLM（`PKT`）给 P11 用 ⇒ 合成时**必须多落一份 global fragment 面**给发 3 用；这份 store 的代价 = 与发 2（R1 生产者 0.0892 ms）同量级 ⇒ **要在 B2 单价里显式列出这一腿**，不许混进"零 pack"口号里。
3. **`WKey` 教训（四元组防串键）**：新核的 JIT cache key 第四字段（module id / defines）必须与两半的旧件**不同**，并在 trace 里打印四元组；否则 `sycl-cache-portE` 会把旧模块当新的复用 ⇒ 出现"改了源码读数不动"的假象（刀 1 的 WKey 事故同源）。
4. **台账标签**：`s6/spillcheck_port.py` 的 `label()` 目前认 `port::fused` / `ffn2c::fused` / `p2::fused` ⇒ **加 `pe_chain::` 前缀**，否则新核不进台账 = 静默漏判（P14）。
5. **flaky 探针的开关陷阱**：`ffn2` 的 M-FLAKY 只在 **`C2_STAGE=1 或 3`** 才执行（`C2_STAGE=2` 释放 1a taps ⇒ 探针**静默不跑**，本轮第一次就是这么漏的）。
6. **port 核的病只到"族"，未到"指令"**（§66 的 mod-16 ∈ {0,7} = 8 行 fragment 边界是最强线索）：下一步最便宜的 A/B = **按 NPHASE 截断做压力**（`PORT_STRESS_PHASE=2/3/4/5`，脚本 `s6/pe_mkstress_ph.py` 已写好、**未编译未跑**）⇒ 若 bad 只在 ≥4 出现 ⇒ 病在 outquant/residual；若 2/3 就翻 ⇒ 在 expand/requant。**GPU 归用户，跑前先凉 ≥5 分钟。**

## ④ 现场（16:2x 实证，全部 host 侧）
见 §69（清理 + md5 实证 + 进程 0）。**本轮到此停手，不开 B2、不做新测量、不编译。**

## B2-ready（**由主会话代写：代理在落盘前被暂停令打断**；下次开工直接照这一节走，不用再问）

**现场已核（16:2x，全部实证）**：`git` = `b54de7e`、porcelain **CLEAN**；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`ABB969FE…`**；三金标 `bk.1301.bin`=`bk.1301.skip.bin`=**`DD49827D…`**、`bk.1301.pre-skip-1a.bin`=**`249A46F3…`**；**GPU/bench 进程 = 0**；`E:\DSH\tmp\pe_stress.cpp`、`pe_stress_att.cpp` 仍在（已被仓内版 `src/bench/sycl/stress_repeat.cpp` 取代，可删）。

### ① B2 要写的东西（端到端合成体，**目前不存在**）
`src/bench/sycl/port_e_chain.cpp` = **一条 C=64 链、11 发 → 3 发**，两半各自已绿、只差串起来：
- **att 半** = `s6b_att.cpp` 的 `att5L::fused`（**0 bad / 1200 连发**，GATE GREEN，C64 档 5 发合一相 wall **0.4329** / GPU 0.3531）；
- **FFN 半** = `s6_ffn_block4.cpp` 的 `ffn2::fused`（**0 bad / 600 连发**，9/9 + 13/13；**M2b 档 0.4109-0.4142**）；
- **共享面直连（零 pack / 零 quant）**：把 **FFN 半的 global A 面寻址参数化**成
  `kb*2048 + (hb*16 + band)*512 + lane*32`（`hb ∈ {0,1}` = 窗口半），
  与 att 半的 `PKT + kb*2048 + row*32` **逐位同式**；scale 单列同形（`AS2 + row*4` vs `O_SC + t*4`）；
- **几何锁死**：**T=32、LW=64、SLM 31,104 B（2 resident WG）、网格 1020 WG**（与现档 `nblk = M/T = 1020` 一致）；**禁 LW=32**、**一律 KN=0**；
- **不许改数值**：累加顺序、`fdiv_rn`、e4m3 snap、`eh_round/ef_div`、FMA contraction 全部 VERBATIM。

### ② B2 的判据（写死，缺一不算成）
1. **13 + 4 项检查点逐字节 = 0**（4 项接口 = 面布局字节序 / scale 粒度 / e4m3 编码 / epilogue 出口形态）；
2. **LIVENESS 反证**（中间面 ×0.5 ⇒ 出口必须变）+ **`--cross` 两组进程 IDENTICAL**；
3. **新合成核必须过自重复门：`stress_repeat` ≥1000 连发 bad=0**（军规 46/48；**注意 200 连发只做快筛**——本案 port 核 1×200 bad=0、2×1000 各 bad=4，真基率 ≈0.5%）；
4. **单价**：≥10 个独立进程、**进程间 ≥60 s**（P18/军规 45：背靠背把 TOPS 压低 2.5 倍）、min-of-15×5、nosink、台账逐列（**key 含 simd+module_id**，`private/spill/scratch=0`、scratch 指令=0）；
5. **基线用实测**：`tools/rt_per_closure.csv` 的 **chain 48 = 1.525 ms/链**、**8 条 C64 链均值 1.658**（**不许再用 1a 之前的 2.080**）；
6. **目标 ≤0.844 ms/链**（bench 内 −42%）⇒ **8 链 −5.6 ms 串行 ⇒ 帧 −2.4**（**诚实净值，别报回 −4.5/−5.1**）。

### ③ B2 之前必须留的空 / 已知坑
- **`WKey` 四元组**：新支路的权重缓存键必须另立字段，**复用 split 键会静默吃到非块对角的预铺 B**（门可能照样绿、到 1301 才爆）；实施后**先跑 1301 再看门**，并在 trace 里打印四元组；
- **`att5L` 的 fATT 面故意不 scrub / 不比**（核不重写整块 att 面；第一版误算造成 **bad=199/200 假警**）；
- **`ffn2` 臂只在 `C2_STAGE=1 或 3` 执行**（`C2_STAGE=2` 释放 1a taps ⇒ 探针静默不跑）；
- **接图（阶段 C）需要记录/计划层换序 + 稳定面**（§56b：96 个 residual 站点里相邻同形腿对 = 0；R9 已证"重写本身在改图"）⇒ **B2 只在 bench 层，接图前另立铲**；
- **构建一律走 `tools/build_shipped.ps1` + `tools/shipped_build.defs`**（HEAD 不带 `/D` ⇒ 1301 会落在旧代 `249A46F3`，逐位门假红）。

### ④ 下次开工第一步（照抄）
```
# 0) 现场核对 + 凉 GPU >=5 分钟（本轮 GPU 已用 ~55 分钟）
cd E:\DSH\dlss-nr-on-a770 ; git status --porcelain        # 期望 0 行
Get-Process | ? { $_.ProcessName -like 'LOP-Win64-Shipping*' }   # 期望 0（用户在玩就等）
# 1) 先复现两颗牙（~2 分钟，确保仪器还在响）
cmd /c "E:\DSH\oneapi\stress_repeat.exe >> E:\DSH\s6\SR_ctrl.log 2>&1"     # 期望 bad=0/200
cmd /c "set PORT_STRESS=1000&& E:\DSH\oneapi\port_ffn_fused.exe >> E:\DSH\s6\SR_port.log 2>&1"   # 期望 bad>0
# 2) 再写 port_e_chain.cpp（按 ①），gate 全绿后才谈单价
```

### ⑤ 新仪器坑 P19（本次实测）：**python 在 GBK 控制台打印 CJK/箭头会 `UnicodeEncodeError` 崩**
⇒ **脚本里若要打印非 ASCII，先 `sys.stdout.reconfigure(encoding="utf-8")`**，或只打印 ASCII 摘要（**16c 的延伸：不只是 .ps1，任何机器读的 stdout 都优先 ASCII**）。

---

# §69 停机现场（**代理侧实证，16:2x**；本节取代上面"B2-ready 现场已核"里关于 tmp 的那句）
**只做 host 侧三件事，未跑任何 GPU、未编译。**
**① 清理（已执行）**：删除 `E:\DSH\tmp\pe_stress.cpp`（67,604 B，md5 `F3552A9C2715CFD1FE634050935DC769`）与 `E:\DSH\tmp\pe_stress_att.cpp`（81,593 B，md5 `0CF3CEB22CECEA89B6ECFB3FF7E334E1`）——功能已被仓内版取代（`src/bench/sycl/stress_repeat.cpp` + `port_ffn_fused.cpp`/`s6b_att.cpp` 内建的 `PORT_STRESS` / `S6B_ATT_REPEAT`）。
**留下一个半成品（如实登记，未编译未跑）**：`E:\DSH\tmp\pe_stress_ph.cpp`（68,306 B，16:22 生成）= §68③6 / 上面③ 说的 **NPHASE 截断压力 A/B** 副本；生成器 `s6/pe_mkstress_ph.py` 在仓外 `s6\`，下次一条命令可重建。
**② md5 实证（逐条跑过）**
```
out\libxmx.dll                ABB969FE4AAF0F94AA03C3F53781EDD0
oneapi\libxmx_sycl.dll        ABB969FE4AAF0F94AA03C3F53781EDD0
dumps\bk.1301.bin             DD49827DD33A7EF07C2C17892F18970D
dumps\bk.1301.skip.bin        DD49827DD33A7EF07C2C17892F18970D
dumps\bk.1301.pre-skip-1a.bin 249A46F374E98EB5FF5AD5E3A38EBC55
out\test_1270e4m3.dll         D37FFD5D081CEF1B7C394182A37F6457
out\test_skip_c512.dll        2D878C079E3AA46EC6C20E743381B70B
```
**③ 进程**：`nr_replay / stress_repeat / port_ffn_fused / s6b_att / b4_* / pe_* / batch_merge_probe / knife2_probe / icx` = **0**；`LOP-Win64-Shipping` = **0**（GPU 交还用户）。
**④ 日志计数核对**：本轮 46 个机器读日志**全部非空**（`B0_*` 30 个、`B0S_*` 4、`S1_*` 6、`S1b_*` 6、`S2_*` 5）；最短 = `S2_ctrl.log` **1 行** = 设计如此（`stress_repeat.exe` 只打一行 `STRESS SUMMARY … bad=0`），不是截断。
**⑤ 仓**：tip 已从 `d8af4d6` 前进到 **`b54de7e`**（主会话把 §67 仪器 + B2-ready 入库），porcelain **0**；**我未 commit、未 push**。
**⑥ 停机**：B2 未开、无新测量、无编译。下次开工：先凉 ≥5 分钟（本轮 GPU ≈55 分钟），再照上面"④ 下次开工第一步"复现两颗牙。

---

# §70 B2a = **合成体建成并通过门 1-3**　2026-11-04 02:0x-02:5x
**新文件（bench 层）**：`src/bench/sycl/port_e_chain.cpp`（480 行）+ 生成物 `src/bench/sycl/port_e_chain_bodies.inc`（`s6/pe_mkchain.py` 从 `s6b_att.cpp` + `s6_ffn_block4.cpp` **逐字抽取**、各自包进 `namespace PE_ATT / PE_FFN`、`main` 改名保留）。exe `oneapi\port_e_chain.exe`：本轮多次重编，最终 **`EC1D8CFE8A9554D10D1A4FD190E966D3`**（2,527,744 B），编译带 `-Defs '/DM_P4FORM=0 /DM_PEAK=1 /DM_P3SPLIT=1'`（M2b 档；`Shape` 有 static_assert 要求模板参数 = 宏 ⇒ 档位只能走编译期，不能运行期选）。

**形态**：一条 C=64 链（plan closures 641..651）= **11 个 plan op / 现路 13 个 device 发 → 3 发**：
- **L1** `PE_ATT::att5::fused<64,2,5,DUMP,LIVE>`（5 腿：QUANT_WINDOW→QKV→WINDOW_ATTENTION→QUANT→GEMM_WINDOW_INT8_RESIDUAL，出口 = 1270 token 序）
- **L2** `packdev::pack_a_fused(1270 → face + scA)`（链自己的 QUANT=646，顺手按 dpas fragment 序落 A 面 = R1 生产者）
- **L3** `PE_FFN::ffn3::fused<S,true,NPH-1,0>`（1a/M2b 五腿一发，P1 由 L2 供，出口 = 1267）
- 几何：**T=32 / LW=64 / SLM 31,744 B（台账实测，2 resident）/ 1020 WG**；**KN=0**；**未用 LW=32** ✓
- REF（对照）= 13 发拆腿链（att 5 + FFN 8：`qr_launch_esimd / gather_pack_a_b_v / gemm_b_pub_slm / qr / gather_pack_a_b_v / gemm_b_pub / pack_a_fused / gemm_b_res`）+ scores/probs 的 split 权威（`pack_a16_b / pack_b16_t_b / f16v2::gemm_b2 / smax::softmax_kernel`）

**门 1（逐字节）= 25 项全 0**：att 12 项（`pk0 sc0 Q-plane K-plane V-plane scores probs att(P9) pk2 sc2 pk2-folded 1270-FINAL`）+ FFN 13 项（`pk1 pk1-face faceA-vs-faceB sc1 hid pk2 pk2-frag sc2 out1275 pk3 pk3-frag sc3 1267-FINAL`）；其中 4 项接口 = 面布局字节序（`pk1-face` + `faceA-vs-faceB`：**一发生产者面 = 两发 qr+retile 面 = split packA 面**）、scale 粒度（`sc1/sc2/sc3` 每行一 float）、量化编码（`pk1/pk2/pk3`）、epilogue 出口形态（`out1275/pk3-frag/1267-FINAL`）。
**稳定性：6 个独立进程（40 s 间隔）= 6/6 GATE GREEN。**
**门 2（LIVENESS）= 过**：`faceB /= 2` 后重跑 L3 ⇒ `1267 differs in 1,158,095 / 4,177,920 bytes`，6 个进程数字完全一致 ⇒ 共享面真的喂到出口。
**门 3（cross）= IDENTICAL**：`PE_blobA.bin` / `PE_blobB.bin`（16,842,240 B = 1270+1267+face+scA+out1275+pk3+sc3）md5 同为 **`7E963BF25B6F3E8B4608D8F185FB875E`**，`CROSS …: IDENTICAL`。
**门 4（预跑，正式读数见 §72）= 合成体 2 × 1000 连发 bad=0**（L1+L2+L3 全链、每次发射前哨兵 memset、与 launch-0 逐字节比）。

# §71 **新坑 P20：bench 里 `q.wait()` 不保证 producer→consumer 可见性**（这次是先撞在我自己的合成体上）
**症状**：同一个 `port_e_chain.exe`、同一个 `sycl-cache-portE`，**4 个进程里 2 个 GATE RED**，且错在 **REF 侧**：`packdev::gather_pack_b_b` 的出口 `dBpE` 前 8 字节 = `0 0 0 0…`（输入 `dWER` 正确）⇒ REF 的 expand 写全零 hidden ⇒ 9 项 DIFF。
**排除**：不是 D2H 读空（设备侧探针也是零）、不是内存压力（当时只分配 120 MB）、不是编译差异（同一 exe）。
**修法**：每个 producer→consumer 交接点插 `q.ext_oneapi_submit_barrier()`（出货 bench 本来就这么写：`leg_pk2` = `pack_a_fused(...); return q.ext_oneapi_submit_barrier();`）。插了 9 处之后 **6/6 GREEN + 2/2 cross IDENTICAL**。
**审计（`s6/p20_audit.py` → `E:\DSH\s6\p20_audit.csv`，30 行）**：
| harness | 交接点 BARRIER | wait-only / NO-SYNC |
|---|---|---|
| `port_ffn_fused.cpp`（PORT_STRESS 臂） | 2（我加的开关） | 5（phase bisection 的 5 发计时 NO-SYNC）+ 2 |
| `s6b_att.cpp`（S6B_ATT_REPEAT 臂） | **0** | 9 |
| `s6_ffn_block4.cpp`（M_REPEAT 探针） | 3（开关） | 9 |
| `stress_repeat.cpp`（负对照） | 0 | 1（memset→launch，只有 wait） |
| `port_e_chain.cpp` | 9 | — |
**控制实验（port 核 `KN=1 LW=16`，同一 exe，`PORT_STRESS_BAR` 开关，2×1000 连发 × 两臂，进程间 60 s）**：
| 臂 | bad / 1000 | 签名 |
|---|---|---|
| **BAR=1（每处交接都有 submit barrier）** | **4 + 3 = 7 / 2000** | `dOUT/dPK3/dSC3`，`row%16 ∈ {0,7}`，`sentinel_pairs=0` |
| **BAR=0（原始 wait-only）** | **4 + 3 = 7 / 2000** | 同上 |
⇒ **两臂同率 ⇒ P20 解释不了 port 核的不自重复 ⇒ §64/§67 的结论维持**（他们的核真的不可重复，≈0.35%/发）；而且这反过来**加强**了 §66 的归因：错在**核内**（跨波 SLM/global 交接），不是 host 侧命令序列。
**要重读的历史账**：`notes/port-M.md:249-252` 的 **"1/158"** 用的是 `s6_ffn_block4.cpp` 的 `M_REPEAT` 探针（当时 wait-only、且 `C2_STAGE` 组合未知）⇒ 同一类嫌疑。**正在跑 A/B**（`s6/p20_block4.ps1`：S1/S2 × BAR=0/1 × 1000 连发，job `pwsh-86f918005a544e37`）⇒ 读数进 §72。
**军规候补（建议主会话入库）**：**军规 49 = bench 里任何"kernel 写 → 下一个 kernel 读/主机比"的交接必须显式 `ext_oneapi_submit_barrier()`；`q.wait()` 只保证完成、不保证下一个 kernel 读到。缺它会让逐字节门随机假红（也会让 flaky 探针读数失真）。**

# §72 **P20 对历史账的复验：`M_REPEAT` 探针在 barrier 两臂下都是 0 bad**（"1/158" 不升级、也不解释）　2026-11-04 03:2x-03:3x
**做法**：给 `s6_ffn_block4.cpp` 的 `M_REPEAT` 探针加 `M_REPEAT_BAR` 开关（默认 1 = 在 scrub→launch 与 launch→D2H 两处插 `ext_oneapi_submit_barrier()`；0 = 复现当年 wait-only）。exe `b4_m2b.exe`（M2b 档 defines）= **`2E7CC66FC86A8836185D272F27C18C1F`**（先 28F4A47B，随后修 FLAKY 行的 printf 参数）。
**四臂（`s6/p20_block4.ps1`，S1/S2 × BAR=0/1，各 1000 连发，进程间 60 s）**：
| 臂 | FLAKY 读数 | 逐发比对 |
|---|---|---|
| S1 C64 M32640 BAR=0 | **0 of 1000 differ from block3** | 9/9 B3GATE PASS |
| S1 C64 M32640 BAR=1 | **0 of 1000** | 9/9 PASS |
| S2 C128 M8160 BAR=0 | **0 of 1000** | 9/9 PASS |
| S2 C128 M8160 BAR=1 | **0 of 1000** | 9/9 PASS |
⇒ **已出货的 1a/M2b 形态在 4000 次连发下 0 bad**（barrier 与否都一样）⇒ **§35/port-M 的"1/158"在这台机器这个档上没有复现**，它既不是 P20 造成的假警，也不需要当作 shipped 暴露的证据；**定性维持 port-M §5 的原判**（那一次是 S2 单发、后续 152/600/1000 连发均 0）。
**牙齿检查**（`s6/p20_teeth.ps1`，200 连发两臂）：`bar=0` / `bar=1` 标签正确打印（第一次的 `(bar=%d)` 我漏了实参 ⇒ 打印成 `bar=-2007954142`，已修 `p20_fix_print.py`；env 是每臂独立设置的 ⇒ 四臂的 barrier 行为有效，只是标签脏）。
**于是 §71 的两条判决合起来**：
- **port 核（他们的）不自重复 = 维持**（barrier 两臂同率 7/2000，签名不变）；
- **我们的 1a/att5/合成体 = 干净**（合成体 2×1000 bad=0；1a 形态 4×1000 bad=0）。
**GPU 时长**：port 控制 5.9 min + block4 四臂 ≈ 15 min + 牙齿 3.5 min ≈ **24 min**（本轮累计 ≈ 45 min，仍在 5 h 时间盒内）。

# §73 单价第一轮（**含仪器成本，不能用作结论**）+ 发现两种免仪器形态　2026-11-04 03:4x-04:1x
**第一轮 ladder（10 进程 × 60 s，`s6/pe_price.ps1`，exe `EC1D8CFE`）**：
| 形态 | 每进程 med（ms/链） | 10 进程均值 |
|---|---|---|
| **REF13**（现路 13 发） | 1.4166 / 1.4316 / 1.4550（组内 min/med/max） | **≈1.43** |
| **CHAIN3**（3 发，**DUMP=true**） | 1.2049 / 1.2317 / 1.3062 | ≈1.21 |
⇒ **REF13 与引擎实测 `chain 48 = 1.525 ms` 对齐**（bench 少 cgraph 开销 ⇒ 略低）✓ 说明这台仪器是可信替身。
⇒ **但 CHAIN3 只省 15% 是仪器假账**：门 1 需要 DUMP=true，而 **DUMP=true 的 L1/L3 每发要多写约 90 MB 诊断面**（fScores 16.7 MB + fProbs 8.4 + pQ/pK/pV 12.6 + fATT 8.4 + gHID 16.8 + gPK2 8.4 + gPK2F 8.4 + …）⇒ **计价腿必须用 DUMP=false**。
**于是加了两种免仪器形态（同一 exe，门仍用 DUMP=true 的那套过）：**
- **`CHAIN3n`** = L1(DUMP=false) + L2(生产者) + L3(`ffn3` DUMP=false) = 3 发；
- **`CHAIN2`** = L1(DUMP=false) + `ffn2::fused<S,false,NPH,0>`（**1a 半自己在 P1 里量化 1270**）= **2 发**，**连生产者腿都不需要** ⇒ 11 op → 2 发。
**`CHAIN2` 的逐字节门（新增检查点，`PE_c2gate2.log`，exe `A4C3D8F86AC740DCFED0C6F0328D1DFB`）**：`CHAIN2-1267 diff = 0 (4,177,920 B)`、`CHAIN2-pk3 diff = 0` ⇒ **2 发形态同样逐位等于现路**（它的 1267 出口与 REF13 一致）✓
**踩过的坑（记档）**：`ffn2::fused<DUMP=true>` 会写 `dpk1/dsc1` 两个 tap ⇒ 我在 Args 里留了 **nullptr** ⇒ **设备直接 `0xC0000409` fastfail**（GATE GREEN 之后当场炸）⇒ 已补真缓冲。**任何 DUMP=true 的腿，其 tap 指针必须全部非空**（`ffn3` 因跳过 P1 才允许 dpk1/dsc1=null）。
**第二轮 ladder（10 进程 × 60 s，同时价 REF13 / CHAIN3 / CHAIN3n / CHAIN2）**：job `pwsh-b113620902244b03`，读数进 §74。

# §74 **B2b + B2c：门 4 / 门 5 / 门 6 全读数**　2026-11-04 04:0x-04:3x
exe（最终）`oneapi\port_e_chain.exe` = **`CBA02894CB4E0197F15BA0C428C70F04`**（2,543,104 B）。

## 门 4（自重复，军规 46/48）= **过**
| 形态 | 连发 | bad |
|---|---|---|
| DUMP=true（带仪器）`--stress 1000` | 2 进程 × 1000 | **0 / 2000** |
| **DUMP=false（出货形态）`--stress0 1000`** | 2 进程 × 1000 | **0 / 2000**（`STRESS SUMMARY … bad=0 first_bad_s=-1 dump0=1`）|
比对集 = 每次发射前对 **1270 / face / scA / 1267** 全部 memset 0xA5，与 launch-0 逐字节比 ⇒ 四个交接面全 0 差。
**坑（记档）**：`--stress0` 第一版把 `out1275/pk3` 也纳入比对 ⇒ 每发都报 `dout=4,177,908 / dpk3=2,051,314`，**那不是竞态，是 DUMP=false 的核根本不写诊断面**（哨兵留在原地）⇒ 已按 `STRESS_DUMP0` 跳过这两块。**哨兵法比对的面必须与该形态真正会写的面一致**，否则测的是仪器。

## 门 5（台账逐列）= **过**（`s6/PE_ledger4.txt`，去重 key 已含 simd + module_id）
| 计价腿 | grf | simd | slm(B) | spill | private | scratch B | scratch 指令 |
|---|---|---|---|---|---|---|---|
| `PE_ATT4att5::fused C64 heads2 P5 dump0 live0` | 128 | 1 | **32,768** | 0 | 0 | 0 | **0** |
| `PE_FFN4ffn2::fused T32 C64 HID256 P4F0 PEAK1 SP1 BAR0 dump0 P6 SK0`（CHAIN2 腿） | 128 | 1 | **31,744** | 0 | 0 | 0 | **0** |
| `PE_FFN4ffn3::fused T32 C64 HID256 … dump0 P5 SK0`（CHAIN3n 腿） | 128 | 1 | 31,744 | 0 | 0 | 0 | **0** |
| `packdev::pack* / gather_pack* / quantize_row`（生产者与 REF 腿） | 128 | 1/16/32 | 0-1024 | 0 | 0 | 0 | **0** |
⇒ **计价腿 private/spill/scratch = 0、scratch 指令 = 0** ✓（`-` = 该字段不存在 = 0）；对照 §60 的 `port::fused`（private 6,304-6,464 B + scratch 指令 178-289）⇒ **两半的核都干净**。
**又一处"静默 0 行"**：`spillcheck_port.py` 的 ffn3 标签正则原来要求 `INS\d+_5Shape`，而 ffn3 的 mangled 名是 `INS_4ffn25ShapeI`（嵌套名替换）⇒ **ffn3 的行被静默丢掉**（台账 60 行里没有它）。已加宽（`s6/p20_fix_label.py`）⇒ 现在 66 行、ffn3 三行都在。**教训：台账工具的 label 正则必须对每个新命名空间/新模板形态验一次"行数是否增加"，否则漏行不会报错。**

## 门 6（单价）= **读数如下（诚实净值，不是 −4.5/−5.1）**
10 个独立进程、进程间 60 s、每进程 min-of-15×5、nosink、**每进程 GATE GREEN**：
| 形态 | 发数 | mean-of-med | min-of-med | max-of-med | 进程间 spread |
|---|---|---|---|---|---|
| **REF13**（现路 13 发） | 13 | **1.4126** | 1.4052 | 1.4310 | 0.0258 |
| CHAIN3（DUMP=true，含仪器） | 3 | 1.2077 | 1.1997 | 1.2368 | 0.0371 |
| **CHAIN3n**（3 发，出货形态） | 3 | **1.0535** | 1.0481 | 1.0723 | 0.0242 |
| **CHAIN2**（**2 发**，att 合一 + 已出货 1a 半） | 2 | **0.9413** | 0.9380 | 0.9450 | **0.0070** |
**基线对齐**：bench 的 REF13 = 1.4126 vs 引擎实测 `chain 48 = 1.525`（bench 少 cgraph 开销 ⇒ 低 7%）✓ 这台仪器可用。
**外推（按比值，不按绝对值串账）**：
- **CHAIN2 / REF13 = 0.6664** ⇒ 落在 `chain48 1.525` 上 = **1.016 ms/链**，省 **0.509 ms/链**；落在 8 条 C64 链均值 `1.658` 上 = **1.105 ms/链**，省 **0.553 ms/链**
  ⇒ **8 链串行省 4.07-4.42 ms** ⇒ **帧净值 ×0.43 = 1.75-1.90 ms**
- CHAIN3n / REF13 = 0.7458 ⇒ 1.137-1.237 ms/链 ⇒ 8 链省 3.10-3.37 ms ⇒ 帧 1.33-1.45 ms
⇒ **没到订单里写的 ≤0.844 ms/链**（CHAIN2 实测 0.941）。差额 ≈0.10 ms = **两半背靠背跑的交接代价**（两半各自独立价 0.4329 + 0.4109 = 0.844 是"半链单独跑"的数，合成体里 1270 的写→读依赖 + 两半在同一进程连续占用把这块吃掉了）。**诚实说法：链 −33%，帧 −1.75…−1.90 ms。**
**★ 顺带一条判决：生产者腿（L2/R1）在合成体里不划算** —— CHAIN3n（带生产者）1.0535 vs CHAIN2（不带）0.9413 ⇒ **加一发生产者反而慢 0.11 ms**，因为已出货的 `ffn2` 半**本来就在 P1 里量化 1270**（不需要 fragment face）。⇒ **接图应走 CHAIN2 形态**（11 op → 2 发），`ffn3` + 生产者只作为 bench 里的对照保留。

# §75 接图（阶段 C）还缺什么 —— **只写清单，本轮不动 shipped、不接图**
**现状（shipped 侧已有的地基，`src/bench/sycl/libxmx_sycl.cpp`）**：FFN 半的融合**已经在 shipped 里**（`S6Fuse` / `s6_ffn_run` @713、五/六腿 no-op 规则 @676-679「all six or none」、`NR_S6_TRACE` record-time witness @683、权重包 `s6_pack_bexp_wide` WKey `c=30001` @694、`s6_pack_bproj_wide` WKey `c=10000+batchp` @703、`cached_pack_b_i8` @494、`WKey{id,a,b,c}` @475）。⇒ **CHAIN2 = 「已出货的 FFN 合一」+「新的一块 att 合一」**，不是从零接线。
**清单（按依赖顺序）**：
1. **新 op：`xmx_rec_att5_fused`（= 本 bench 的 L1）**：把 closures 641/642/643/644/645 五条 no-op、一发取代；照 S6 的「**要么五条全 no-op，要么一条都不**」规则写匹配器（匹配键 = op 序列 + M/C/heads/batches/across/pad + 输入面 id）。
2. **PGRAPH touch set 注册**：新 op 的读集（1267 图像、QKV/proj 权重 pack、bias、cos）与写集（1270）必须注册；**未注册 = `(void*)-1` ⇒ 引擎会把中间面当可回收面**（刀 1 判死的根因之一）。L1 内部的 Q/K/V/1277/PKT 面是**核内私有**，不注册进图 ⇒ 但它们必须是 **op 内 pool_get 序列稳定**（同形腿在记录秩序里相邻 ✓ 链内成立，无需跨链换序 ⇒ **与刀 1 的判死不冲突，这正是 B2 的价值**）。
3. **WKey 四元组**：L1 的两个权重 pack = `cached_pack_b_i8(b, Braw, 3C, C)`（QKV，现路 @3674/@4087 已用同键）与 `cached_pack_b_i8(b, Wraw, C, C)`（projection，@4091 同键）⇒ **CHAIN2 形态不需要新键**；若将来接 CHAIN3n（生产者 + ffn3），face/scA 不是权重、也不进 WKey，但**必须在 trace 里打印四元组**（照 `NR_S6_TRACE` 的格式加一行 `att5-fire`）。**风险仍在**：如果匹配器把 FFN 半的 `Bexp` 键（30001 wide）与 split 腿的 batched 键混用 ⇒ 静默吃非块对角预铺 B ⇒ **先跑 1301 再看门**（订单要求）。
4. **稳定面**：CHAIN2 只需 1270（现路已有该面、已有 id）⇒ **零新面**；CHAIN3n 需要新增 `face(Mp*C) + scA(Mp*4)` 两个 pool 稳定面 ⇒ 又多一条不选它的理由。
5. **应力门进 shipped**：接入后必须在 shipped 回放里跑 ≥1000 连发（`nr_replay_now` + 哨兵）+ 40 门套件 + **1301 逐位**（金标 `DD49827DD33A7EF07C2C17892F18970D`；`pre-skip-1a` = `249A46F374E98EB5FF5AD5E3A38EBC55`）；基座 = `tools/build_shipped.ps1 -Tag <tag>`（`/DT_SKIP_CHAINS_DEF="18,…,32"`，HEAD 不带 `/D` 会假红落在 249A46F3）。
6. **只接 C=64 的 8 条链**（0,1,2,3,48,49,50,51）：**att C128 合一相实测 +51% 更差**（SLM 41,984 越 32KB 崖）⇒ 不外推；C256/F3 保持现路。
7. **几何不许动**：T=32 / LW=64 / SLM 31,744（2 resident）/ 1020 WG；**禁 LW=32**（§65 已证死锁区）、**KN=0**。
8. **收益进账**：按 §74 的比值法，8 链串行 −4.07…−4.42 ms ⇒ **帧 −1.75…−1.90 ms**；接图后要用 `rt_per_closure.csv` 的逐 op 实测复核（别用 bench 绝对值直接减）。
9. **P20/军规 49 进 shipped 侧的对照**：shipped 的 cgraph capture/replay 里 producer→consumer 由图保证顺序，**但 bench 层任何新腿的比对都要带 barrier**（见 §71）。

# §76 C-0 第一遍（半链分解）：发现 **FFN2 单独价在进程间双峰** ⇒ 必须做依赖/换序判别臂　2026-11-04 04:2x
exe `port_e_chain.exe` = **`77F0487A7B99D6DC4016B3D8E08400DE`**（加了半链分解臂）。5 进程、**间隔 45 s（低于 60 s 规矩 ⇒ 这一遍只作线索，不作结论）**、全 DUMP=false、每进程 GATE GREEN。
| 臂 | 每进程 med（ms） | 均值 |
|---|---|---|
| `REF13` | 1.4289 / 1.4309 / 1.4296 / 1.4094 / 1.4129 | **1.4223** |
| `REFA5`（att 5 腿拆腿价） | 0.6573 / 0.6530 / 0.6511 / 0.6419 / 0.6429 | 0.6492 |
| `REFF8`（FFN 8 腿拆腿价） | 0.8157 / 0.8268 / 0.8072 / 0.7943 / 0.7945 | 0.8077 |
| **`L1n`（att 合一相，1 发）** | 0.4406 / 0.4457 / 0.4296 / 0.4303 / 0.4323 | **0.4357** |
| **`FFN2`（1a 合一相，1 发）** | **0.4981 / 0.4756 / 0.4944 / 0.3873 / 0.3863** | 0.4483（**双峰：0.386 vs 0.49**） |
| `CHAIN2n`（2 发合成） | 0.9490 / 0.9431 / 0.9537 / 0.9434 / 0.9412 | 0.9461 |
| `CHAIN3n`（3 发带生产者） | 1.0802 / 1.0847 / 1.1149 / 1.0501 / 1.0483 | 1.0756 |
**核对**：`REFA5 + REFF8 = 1.457` ≈ `REF13 = 1.422` ✓（拆腿相加与整链一致，差 +2.4% = 队列/匹配效应）⇒ **半链分解这台仪器本身可信**。
**att 半**：5 腿 0.6492 → 1 发 0.4357 = **−32.9%** ✓（与 §60 的 0.4329 对齐）
**FFN 半**：8 腿 0.8077 → 1 发 **0.386-0.498（双峰）** ⇒ 双峰必须先解释，否则"合成体 −0.10 ms 交接代价"这个数站不住：
- 若取 `FFN2 = 0.386`（后两个进程）⇒ `L1n + FFN2 = 0.822` vs `CHAIN2 = 0.946` ⇒ **交接代价 +0.124**；
- 若取 `FFN2 = 0.49`（前三个进程）⇒ `L1n + FFN2 = 0.926` vs `CHAIN2 = 0.946` ⇒ **交接代价只有 +0.020**。
⇒ **两种解释差 6 倍，必须判别。** 已加三条判别臂（同一 exe，接下来这一遍 5 进程 × **60 s**、先凉 5 分钟）：
- **`FFN2D`** = 同一个 1a 核，但它的输入面换成**早已写好的静态 1270**（REF 的那块）⇒ **断开对 L1 出口的 RAW**；
- **`CHAIN2I`** = `L1n` + 上面那个独立输入腿 ⇒ **发数与网格完全相同，只去掉依赖**；
- **`FFN2L`** = 把 `FFN2` 在定价块**最后**再测一遍 ⇒ 进程内漂移探针。
**判别逻辑**：`CHAIN2I ≈ CHAIN2` ⇒ 代价 = **两发本身的启动/网格切换**（与依赖无关，接图后也省不掉）；`CHAIN2I ≈ L1n + FFN2` 而 `CHAIN2` 更高 ⇒ 代价 = **1270 写→读可见性依赖**（⇒ 才谈得上"让 FFN 半直接吃 L1 的出口、不落 global"这类修法）。
**job**：`pwsh-71b3a64283684ecc`（含 300 s 冷却）。读数进 §77。

# §77 **C-0 判决：0.10-0.12 ms 不在依赖上，也不在 P1 供数上——它是"两发背靠背的相互干扰"；第一遍的 FFN2 双峰是热漂移**　2026-11-04 04:2x-04:3x
exe `port_e_chain.exe` = **`A6CA9F5D08E6F55DEB6748D5173F522C`**（加 `FFN2D / CHAIN2I / FFN2L` 三条判别臂）。**先凉 300 s**，然后 **5 进程 × 60 s**、全 DUMP=false、每进程 GATE GREEN、本批 3.4 min。
| 臂 | 5 进程 med | 均值 | 进程间 spread |
|---|---|---|---|
| `REF13`（现路 13 发） | 1.4118 / 1.4129 / 1.4099 / 1.4126 / 1.4090 | **1.4112** | 0.0039 |
| `REFA5`（att 5 腿） | 0.6495 / 0.6417 / 0.6425 / 0.6423 / 0.6414 | 0.6435 | 0.0081 |
| `REFF8`（FFN 8 腿） | 0.7969 / 0.7977 / 0.7954 / 0.7942 / 0.7937 | 0.7956 | 0.0035 |
| `L1n`（att 合一 1 发） | 0.4322 / 0.4347 / 0.4320 / 0.4372 / 0.4319 | **0.4336** | 0.0053 |
| `FFN2`（1a 合一 1 发） | 0.3840 / 0.3855 / 0.3876 / 0.3873 / 0.3868 | **0.3862** | 0.0036 |
| `FFN2D`（同核、输入换成早已写好的静态 1270 ⇒ **断开 RAW**） | 0.3866 / 0.3875 / 0.3860 / 0.3858 / 0.3871 | 0.3866 | 0.0017 |
| **`CHAIN2I`**（L1n + 那个**无依赖**的 FFN 腿） | 0.9410 / 0.9398 / 0.9452 / 0.9418 / 0.9393 | **0.9414** | 0.0054 |
| **`CHAIN2`**（L1n + **有依赖**的 FFN 腿） | 0.9422 / 0.9396 / 0.9488 / 0.9402 / 0.9397 | **0.9421** | 0.0092 |
| `FFN2L`（同一个 `FFN2` 在定价块最后再测 ⇒ 进程内漂移探针） | 0.3873 / 0.3853 / 0.3864 / 0.3875 / 0.3866 | 0.3866 | 0.0022 |
**三条结论**：
1. **`CHAIN2 − CHAIN2I = +0.0007`（噪声内）⇒ 那 0.12 ms 不是 1270 的写→读可见性依赖**；断开依赖（FFN 腿读一块静态旧 1270）一点没变快 ⇒ **不需要改 ffn2 的 P1 供数**（也不许为了这个去违军规 54）。
2. **`L1n + FFN2 = 0.8198` vs `CHAIN2 = 0.9421` ⇒ 净 +0.122 ms 落在"两发背靠背的相互干扰"**（同一进程里连着跑两个 1020-WG / 31-32 KB SLM 的大核：L2/占用率/时钟爬升都不如各跑各的）。**诚实外推只能用合成体自己的价**：`CHAIN2 / REF13 = 0.9421 / 1.4112 = **0.6676**` ⇒ 落在 `chain48 1.525` = **1.018 ms/链**（省 0.507）；落在 8 链均值 1.658 = **1.107 ms/链**（省 0.551）⇒ **8 链 −4.06…−4.41 ms 串行 ⇒ 帧 −1.75…−1.90 ms** ✓ 与 §74 一致。
3. **第一遍（§76）的 FFN2 双峰（0.49 vs 0.386）= 热漂移**：那一遍跑在 ~55 min 连续 GPU 之后**没有冷却**；这一遍先凉 300 s ⇒ FFN2 稳定 0.3862，且**进程内漂移探针 FFN2L = 0.3866（与 FFN2 同值）** ⇒ 双峰消失。**教训（进 P18/军规 45 的实例）**：半链单独价与合成价**必须在同一冷却状态下测**，否则会造出一个假的"交接代价"。
**C-0 关闭**：不碰 ffn2 的 P1；C-1 按 §75/§72b 的 9 条清单接 `xmx_rec_att5_fused`（CHAIN2 形态 = 11 op → 2 发）。



# §78 **C-1 现场：接图机制跑通了（匹配器会 fire、四条腿会 no-op），但 ON 侧不逐位、且在图内更慢 ⇒ 按⑤的停条件停下**　2026-11-04 04:4x-05:0x
**做了什么（只在 bench 层源 + `builds\` 变体件；没动 `out\`、没动 `oneapi\libxmx_sycl.dll`、没 commit）**
1. `src/bench/sycl/att5_fused_kernel.hpp`（42,540 B）= `s6b_att.cpp:87-617` 的 `namespace att5` **逐字抽出**（生成器 `s6/pe_mk_att5_hpp.py`；只把 bench 文件级的 `using namespace sycl;` / `namespace esimd = ...` 两条**搬进 namespace**，核体一字未改）。先单独 probe 编译通过（`E:\DSH\tmp\pe_att5_probe.cpp`）。
2. `src/bench/sycl/libxmx_sycl.cpp`（+176 行起，加诊断后更多；打补丁脚本 `s6/pe_c1b.py` + `pe_c1_addinclude.py` + `pe_c1_dbg*.py`）：
 - `#include "att5_fused_kernel.hpp"`；
 - `struct A5Chain` + `a5_on()`（**`NR_ATT5_FUSE` 默认 0**）+ 五个 record-time hook（`a5_note_qw / a5_take_qkv / a5_take_wa / a5_note_quant / a5_take_wres`，照 `S6Chain`/`s6_take_*`/`s6_gap` 先例，**"四条腿全 no-op 或全不 no-op"**）；
 - `a5_att_run()`：在 645 自己的 closure 里跑 `att5::fused<64,2,5,false,false>`，**操作数全部复用现路的 plan buffer**（1267 / QKV 三面 / 1270 / bias / qkv_scale / b_scale / cosine），**零新面、零 pool_get**（清单②/④）；权重走 `cached_pack_b_i8(wqkv, 3C, C)` 与 `cached_pack_b_i8(wo, C, C)` = **与 split 腿同一个 WKey**（清单③）；
 - `NR_ATT5_TRACE` record-time witness（fire 序号、M/C/heads/windows/across/pad/img、被 no-op 的 closure 号、fused 所在 closure 号、两个 WKey 四元组、各 buffer id）。
3. 变体件链：`builds\libxmx_att5a.dll = 35F6FFEA26064D7AA58FD169834DCA6B`（无诊断）→ `att5c/att5d`（加 `a5-dbg` 停点）→ **`att5e = C2D161DBAACF9D55699FF19F06740AB3`**（会 fire 的那版）。

**② 双档自证（读数）**
| 档 | passes | 1301 | 每 run 帧时 |
|---|---|---|---|
| **默认（不设 env，att5a）** | **691** ✓ | **EXACT = `DD49827DD33A7EF07C2C17892F18970D`** ✓ | 58.02 / 58.27 / 58.43 ms |
| **`NR_ATT5_FUSE=1`（att5e）** | 691 ✓（closure 数不变，与 S6 同口径） | **MISMATCH = `249A46F374E98EB5FF5AD5E3A38EBC55`**（= 三金标里的 **pre-skip-1a** 那颗）✗ | **62.71 / 62.84 / 62.85 ms ⇒ 比默认档慢 ≈4.4 ms/run** ✗ |
逐位差多少：`att5a_off.1301.bin` vs `att5e_on.1301.bin` = **82.635% 字节不同（6,904,834 / 8,355,840），第一个差异在 byte 0** ⇒ 不是末位漂移，是"整段输出换了来源"级别的错。
fire 情况：一次录制里 **只有 4 条 fire = 2 条 C64 链 × 2 次录制**，8 条 C64 链只匹配到 2 条；其余 `qw-REJECT M/K/geom` 是 C128/C256 链被正确拒掉 ✓。样例：
`[a5-fire] n=1 M=32640 C=64 heads=2 windows=510 across=30 pad=0 img=136x240 noop=19/20/21/0 fused@23 … 1267=1273 1270=1274 1277=1268 bias=1271`
**S6 没被我破坏**：两档 `[s6-fire]` 都是 **40 行**、样例一字不差（`fam=0 M=32640 C=64 HID=256 cmds 13..18 src=1271 pk=1273 sc=1274 -> out=1268 skip=1271`）⇒ FFN 半的既有融合不受影响 ✓
**排查中定到并已修的两处真 bug（在 att5d/e 里）**：
 - **644 的 QUANT 在 plan 里是 `quant(FUSED-pack)`**（P2 融合把它折进消费者），**根本不经过 `xmx_rec_quant` 的记录路径** ⇒ 状态机卡在 stage 3 永远到不了 stage 4 ⇒ 改成 **stage 3 也允许完成**（`pe_c1_dbg2.py`），并加 **`A5-NOOP-GUARD`**：stage 3 时 `c_q2 == 0`，**绝不能 no-op `g_cmds[0]`**（`pe_c1_dbg3.py`）——这个 guard 差点让我杀掉一条无关 closure；
 - stage 3 完成时 pk2/sc2 的 id 在 645 之前未知 ⇒ 校验按 stage 分支（`pe_c1_dbg4.py`）。
**头号可疑点（续跑第一刀该砍的地方）**：fire 行里 **`1267=1273 / 1270=1274`**，而 S6 行里 **`pk=1273 / sc=1274`** ⇒ 我把 641 的 source 和 645 的 out 绑到了 **在 FFN 角色里是 pk/sc scratch** 的号 ⇒ 高度怀疑 **plan 的 buffer id 在不同链之间按同形复用编号**，而 `A5Fuse` 取到的 `g.src` / `c` 不是这条链真正的 1267 / 1270 ⇒ 融合核**读错输入面、写错输出面** ⇒ 82% 全散。**修法**：像 S6 那样在 fire 时把每个 id 的 `g_bufs[].bytes` 与期望尺寸一起打进 witness（我已有 run 期 `P(id, bytes, what)` 校验，但它只在执行时才炸；把尺寸也打进 record-time witness 就能一眼看出绑错），并用 `NR_RES_BYTE`/`rb_push(c,…,"wres")` 的现有账本对照 1270 的 id。
**③ 自重复门（shipped 件 ≥1000 连发）：未跑**（ON 侧不逐位 ⇒ 先修绑定再跑才有意义）。
**④ 40 门 / ⑤ 帧 16 对：未跑**——⑤ 的停条件已触发（**图内比默认档慢 +4.4 ms/run，且 1301 不逐位**）⇒ 按⑥交续跑包。
**现场**：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`ABB969FE4AAF0F94AA03C3F53781EDD0`** 未动；三金标未动（`DD49827D` ×2 / `249A46F3`）；`builds\` 多 att5a/att5b/att5c/att5d/att5e 五颗；仓 = `M libxmx_sycl.cpp`（A5 接线 + 诊断，**未 commit**）、`M port_e_chain.cpp`（两形态 + 门 4 修正）、`?? att5_fused_kernel.hpp`；本轮 C-1 GPU ≈ 6 min（4 次 walk）。
**重要：默认档逐位不变 = 已自证 ✓** ⇒ 接线本身没有污染现状，ON 侧的错只在显式 `NR_ATT5_FUSE=1` 时发生 ⇒ **现在的 shipped 头等于是安全的一半**。


# §79 **C-1 停条件的根因已定位：plan 的 1267 是 **960x544x64** 全尺寸面，不是 bench 里的 136x240 子面 ⇒ 融合核的 gather 用了错的行距**　2026-11-04 05:2x
**证据（`builds\libxmx_att5g.dll = BC28CE374D6AFEBD35F5EA94EBC16005`，`NR_ATT5_FUSE=1 NR_ATT5_TRACE=1`，`walk_att5g_on.txt`，逐操作数一行）**：
```
[a5-op] img_want=4177920 plane_want=4177920
[a5-op] src1267 id=1303 bytes=66846720      <-- 不是 4,177,920
[a5-op] out1270 id=1271 bytes=4177920       OK
[a5-op] faceQ id=1308 bytes=4571136  faceK id=1307 bytes=33554432  faceV id=1309 bytes=4571136   <-- 都不是 plane_want
[a5-op] bias 71/32768 OK   qkv_scale 72/8 OK   qkv_bscale 83/768 OK   wres_bscale 81/256 OK
[a5-op] cosine 73/256 OK   W81 id=82 12288 OK   W79 id=80 4096 OK
```
**66,846,720 = 960 x 544 x 64 x 2**（精确）⇒ 引擎的 1267 是**整幅 960x544 的 f16 面**，而 bench 的 `dImg` 是 **136x240x64**（= 2,088,960 元素 = 4,177,920 B）。链的 M=32640 = 136x240 只覆盖**子窗口网格**，但**行距（pitch）是 960**，不是 240。
⇒ 融合核 P7 的 gather 与 P11 的 skip 读都按 `x + y*image_w` 寻址（image_w=240）⇒ **读错像素** ⇒ 1301 差 82.6%、第一个差异在 byte 0 ✓ 这条解释了全部现象，也解释了为什么 `P(id, bytes, what)` 的尺寸校验没炸（buffer 比需要的大 ⇒ 只查下界）。
**Q/K/V 三面同样不匹配**（4,571,136 / 33,554,432 / 4,571,136 ≠ 4,177,920）⇒ 现路的 QKV 面是**带 padding / 不同 dtype 的面**（K 面 33.5 MB ≈ 8x 于 f16 面 ⇒ 可能是 f32 或 4x 过采样）⇒ 融合核的 fragment 面不能直接绑这三个 id，**要么按现路的真实布局写，要么另立私有面**。
**修法（下一轮的头三刀，按代价从小到大）**：
1. **给 `att5::fused` 传图像 pitch**（新参数 `image_pitch`，plan 里 = 960；bench 侧 = image_w）：P7 的 gather 与 P11 的 skip 都改成 `base + y*image_pitch*C + x*C`。**这改的是核的寻址参数，不改数值链**（累加顺序/fdiv/e4m3 一字不动），但**必须在 bench 里重跑 25 检查点门**（bench 的 dImg 要扩成 960x544 全幅 + 同样的 top/left 偏移，才能复现引擎的输入）。
2. **Q/K/V 面**：先打印现路三面在 `xmx_rec_gemm_int8_qkv` 里的真实尺寸来源（`g_bufs[q].bytes` 是怎么算出来的、`l0_ceil_bm` 之类），把融合核的 fragment 面尺寸/对齐与之对齐；否则就**不用 plan 的 q/k/v id**，改用一个私有面（但那就违反清单④"零新面"，要回报）。
3. **fire 覆盖面**：8 条 C64 链只 fire 了 2 条 ⇒ 另外 6 条被 `qw-REJECT M/K/geom` 之外的条件挡掉，需要把每条链的 641-645 实际 tuple 打出来对比（`a5-dbg` 上限 40 行要放大）。
**未做**：③ shipped 侧 >=1000 连发（不逐位 ⇒ 无意义）、④ 40 门、⑤ 帧 16 对（停条件已触发：ON 侧 62.7-62.9 ms/run vs 默认 58.0-58.4 ms/run，**慢 +4.4 ms**，且 1301 不逐位）。
**安全边界确认**：`NR_ATT5_FUSE` **默认 0**，且默认档在 att5a 上已自证 **1301 EXACT = DD49827D + passes 691** ⇒ 这堆接线现在对 shipped 头**零影响**；`out\libxmx.dll` / `oneapi\libxmx_sycl.dll` = **ABB969FE** 未动；三金标未动。


# §80 **1301 差异的形态 = 全平面、亚 64 字节碎块的数值差 ⇒ 不是绑错 buffer，而是我的 bench REF 不等于引擎实际跑的拆腿路**　2026-11-04 05:1x（host 侧分析，零 GPU）
`s6/pe_diff_profile.py` 把 `dumps\att5a_off.1301.bin`（默认档 = 现 shipped，EXACT `DD49827D`）与 `dumps\att5g_on.1301.bin`（`NR_ATT5_FUSE=1`）逐字节比对：
```
diff bytes 6,904,834 / 8,355,840 = 82.635%
contiguous differing runs: 1,428,541      runs shorter than 4 KiB: 1,428,541 (全部!)
最长碎块只有 71 字节；两个 4,177,920 B 的 plane 块各自差 82.4% / 82.9%；完全相同的块: 0/2
```
**读法**：如果是"写错面 / 绑错 buffer"，差异会是**大块连续**（整段面要么对、要么全散）；这里是**每一处都差、但每次只差几个字节**（碎块最大 71 B、平均 ≈4.8 B）= **同一个量、数值略有不同**的签名 ⇒ 浮点/定点的**低位不同**，不是取错地址。
**⇒ 修正 §79 的判断**：`[a5-op]` 里 1267=66,846,720 B（= 960x544x64x2）**不是绑错**，而是 plan 把该面**过订**成整幅（split 腿同样以 height=136/width=240/across=30/pad=0 从这块的基址读，所以尺寸大是正常现象）；Q/K/V 三面 4,571,136 / 33,554,432 同理（过订/复用）。**下界校验 `P(id,bytes,what)` 通过 = 绑定合法。**
**真正的缺口**：门 1 的 25 检查点是拿**我在 bench 里搭的 REF13**（`pack_a_fused_gather / qres::gemm_qkv_res / wares::launch_wa_res / pack_a_fused / s8v8::gemm_b_res_window / qr_launch_esimd / gather_pack_a_b_v / s8v8::gemm_b_pub_slm / gemm_b_pub / gemm_b_res`）当对照；而**引擎默认档实际跑的不是这组腿**：
 - 641 = `quant_window(**FUSED-pack**)`（被 P4b/qfuse 溶解，pk 由 642 自己 gather）；
 - 644 = `quant(**FUSED-pack**)`（被 645 的 `pack_a_fused` 溶解，见 libxmx_sycl.cpp:4137-4141）；
 - 646-651 = S6-1a 已融合（`[s6-fire]` 40 行）。
⇒ **融合核与"引擎真实腿"之间从来没有做过逐位对照** ⇒ 82.6% 的碎块差异就是这么来的（很可能是 643 的 window_attention 在引擎里走的是另一个变体/另一个累加顺序，而不是 bench 用的 `wares::launch_wa_res`）。
**下一轮的第一刀（先于任何 shipped 改动）**：把 **bench 的 REF 换成"引擎真实路"** —— 直接从 `nr_replay_now` 的 dump（默认档 `att5a_off.1301.bin`）取该链的 1270 与 1267 两面，作为合成体的**唯一对照**（不再由我手工搭 13 条腿）。做法：`port_e_chain` 加 `--gold <1301.bin>` 模式，从 dump 里按 plan 的 buffer 偏移切出 1270/1267，与 CHAIN2/CHAIN3n 的出口逐字节比；**只有这个门绿了，接图才有意义**。
**同时保留**：现在这套 REF13 门仍然有用（它证明了两半的核彼此一致 + 与"我认知的拆腿路"一致），但它的名字要改准：**它是"bench 内部一致性门"，不是"对 shipped 的逐位门"**。
**未跑**：③ shipped ≥1000 连发、④ 40 门、⑤ 帧 16 对（⑤ 停条件已触发：ON 慢 +4.4 ms/run 且不逐位）。


# §81 **C-1 续（90 分钟窗口）：几何图 = 104 条 quant_window 全表；"只 fire 2 条"的原因找到了；pitch 假设被否**　2026-11-04 05:2x-05:4x
件：`builds\libxmx_att5h.dll = B9528F5D3567EF93A26E9D451A3DB2F2`（`a5-dbg` 上限 40 ⇒ **900**，并给每条 quant_window 打一行 `[a5-geom]`）。**只跑一次 walk**（`NR_ATT5_FUSE=1 NR_ATT5_TRACE=1`，`logs\walk_att5h_on.txt`，GPU ≈2 min）。
**104 条 quant_window**（= 全帧的窗口量化腿），**K=64 的 C64 族有四种几何**：
| M | across | pad | 含义 |
|---|---|---|---|
| **32640** | 30 | **0** | 无 halo 的那批 ⇒ **只有这批 fire**（4 行 = 2 条链 x 2 次录制）|
| 35712 | 31 | 262148 (top=4,left=4) | 带 4 像素 halo 的变体 |
| 33728 | 31 | 4 (top=0,left=4) | 单边 halo |
| 34560 | 30 | 262144 (top=4,left=0) | 单边 halo |
（K=128/256/512 的其它 tier 各自也有 2-3 种几何，全部被 `qw-REJECT M/K/geom` 正确挡掉：**100 次 qw-REJECT / 116 qkv-REJECT / 100 wa-REJECT / 100 wres-REJECT，`wres-TUPLE` 0 行** ⇒ 到了 645 时元组全部对得上，**没有一条链是在最后一步被元组挡掉的**。）
⇒ **"8 条 C64 链只 fire 2 条"的解释 = 匹配器目前只接受 `pad==0 && across==30 && M==32640` 的几何；带 halo 的三种变体（M=35712/33728/34560）被我的 `qw` 门槛挡在门外。** 这不是 bug，是**覆盖面决定帧价的一半**：要么把 att5 核的 gather 支持 pad（top/left 已经在参数里，`qr_kernel` 的 gather 就是 `y = ... - pad_top` 同一套），要么只接 pad=0 那批并如实报只兑现一半。
**pitch 假设被否（更正 §79）**：`[a5-geom]` 显示**所有** quant_window 的 `src/pk/sc = 1268/1273/1274` ⇒ **plan 在链之间复用同一组 scratch id**；而引擎自己的 gather 寻址就是 `base = (y*image_w + x)*K`（`quantize_row_kernel.hpp:57`、`pack_device.hpp:641`）⇒ **行距 = 传进去的 image_w（=240），不是 960** ⇒ 我 bench 的 136x240 局部几何与引擎**同语义**，`att5::fused` **不需要 `image_pitch` 参数**（军规 56 的"上界也查"仍要做，但这次不是绑错面）。
**新查到的两条真实尺寸事实（下一条该从这里接）**：
 - `faceQ/faceV` 的 plan buffer = **4,571,136 B = 35712 x 64 x 2** ⇒ QKV 三面按**全帧最大 M（35712）**订座，不是本链的 32640 ⇒ 过订，安全；
 - `faceK` = **33,554,432 B = 960 x 544 x 32 x 2 = 2^25** ⇒ **K 面是整幅 960x544、32 通道的图像序面**，不是 token 序面 ⇒ 融合核往它里写 fragment/token 序是**布局不符**（虽然 643 已被 no-op、没有别人读它，但这解释不了 82.6% 的散，因为 1270 才是出口）。
**ON 侧 82.6% 碎块式数值差的根因：仍未定**。已排除：绑错面（尺寸/复用都合法）、S6 被破坏（40 行 fire 不变）、wa 腿不等价（引擎 `wares::launch_wa_res(Q,K,V,dBv,Bp,Out,batches,heads,rawv2=true)` vs bench `(rQ,rK,rV,nullptr,dBias,r1277,...,true)`，rawv2=true 时 dBv 不被读 ⇒ 等价）。**剩下的头号嫌疑 = 642 的 qkv 腿**：引擎默认档里 641 被 qfuse 溶解后，**gather 由 642 自己做**（`pack_a_fused_gather` @3669）之后接的是哪一版 qkv（`qres::gemm_qkv_res` 还是 `dAp9b`/`Mp32` 那条 @3662 的变体）需要读 3640-3730 定死；bench 用的是 `qres::gemm_qkv_res(..., false, nullptr)`。**下一步第一刀 = 把 642 的默认分支逐行抄进 bench 的 REF，重跑 25 检查点门**（门必须在改后的 REF 上过），过了再谈接图与自重复门。
**现场**：进程 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE** 未动；三金标未动；`builds\` 多 att5h；`NR_ATT5_FUSE` 默认 0、默认档 att5a 已自证 `1301 = DD49827D` + `passes 691` ⇒ shipped 头零影响。C-1 累计 GPU ≈ 10 min。


# §82 **续跑包（本轮收口）：642 抄证 = 已忠实 ⇒ "REF 不忠实"这条本轮被我自己否掉；两条尾巴的处置状态**　2026-11-04 05:5x-06:0x（纯 host，零 GPU）
## 完成到什么程度
- **批准的那一刀（把 642 的默认分支逐行抄进 bench REF）执行前先做了逐参数对照 ⇒ 结论：bench 的 642 腿已经等于引擎默认分支，没有可抄的差异。**
 引擎 `xmx_rec_gemm_int8_qkv`（现文件 3822-4136）默认分支：`pool_get(na)` → `packdev::pack_a_fused_gather(*GQ, src, dAp, as, M, Mp, C, image_h, image_w, across, pad)`（@3897，qwf 默认 ON ⇒ 641 溶解）→ `qres::gemm_qkv_res(*GQ, dAp, dBp, Q, Kk, V, as, bs, qs, M, Mp, C, NH, heads, tokens, vit, vit_recip_tab())`（@3920，`NR_QKV_RES` 默认 ON）。
 bench 的 `leg_qkv`：`qres::gemm_qkv_res(q, rAp, dBp, rQ, rK, rV, rAS, dBS, dQS, M, Mp, C, NH, heads, TOK, false, nullptr)`。
 **唯一差别 = 最后两个实参**（`vit` 与 `recip_tab`）。查 `qkv_resident.hpp:165`：`float recip = vit ? vit_recip_vec(hr, recip_tab) : wbv3::cosine_recip_vec(hr);` ⇒ **`recip_tab` 只在 `vit=true` 时被读**；我们这条链 flags 里没有 0x2000 ⇒ `vit=false` ⇒ **`nullptr` 与 `vit_recip_tab()` 等价 ⇒ 642 忠实** ✓
 其余四条腿此前已逐条查过：641 溶解=同 `pack_a_fused_gather`；643 引擎 `wares::launch_wa_res(Q,K,V,dBv,Bp,Out,batches,heads,rawv2=true)` vs bench 的 `(...,nullptr,...,true)` ⇒ `rawv2=true` 时 dBv 不被读（@5101-5105 的 P10c 注释：RAW-V 把 V 的 pack 腿删掉）⇒ 等价；644 溶解=645 里的 `pack_a_fused`（@4137-4141）✓；645 = `s8v8::gemm_b_res_window(...)` ✓。
- **操作数尺寸对账（`[a5-op]` 运行期实测）全部符合 bench 假设**：`bias 71/32768`（= heads*4096 float ✓）、`qkv_scale 72/8`（= heads float ✓）、`qkv_bscale 83/768`（= 3C float ✓）、`wres_bscale 81/256`、`cosine 73/256`、`W81 82/12288`（= 3C*C ✓）、`W79 80/4096`（= C*C ✓）、`out1270 4,177,920` ✓。
⇒ **所以 ON 侧 82.6% 碎块式数值差，仍未定因**；已排除的清单变长了（见上）。**剩下的两类嫌疑**：
 (i) **融合核在真实 plan 数据上触发了合成数据没触发的路径**（bench 里 REF 与 CHAIN 用同一份随机输入 ⇒ 若核有数据相关隐患，bench 门会绿、引擎会散）；
 (ii) **K 面布局**（尾巴 1，见下）——若融合核的某个阶段其实**读**了它写入的 K 面的旧内容（引擎里旧内容 = 图像序数据，bench 里 = 我们自己写的数据），就会出现这种"只对真实数据错"的现象。
## 尾巴 1：`faceK` 布局不符 —— 处置状态：**未结，按你的要求不许靠推断**
事实：plan 的 K 面 = **33,554,432 B = 960x544x32x2（图像序）**，而 `att5::fused` 的 P8 往 `faceK` 写的是 **fragment/token 序**（bench 里 `fK = mh(nC*2)` = 4,177,920 B）。
- 已做的：`a5_att_run` 用 `P(id, bytes, what)` 只查**下界** ⇒ 通过（buffer 更大）。
- **未做的（下一刀）**：要**运行期证据**证明无人读 K 面 ⇒ 用现成的 PGRAPH touch-set 打印（`pgraph_ids`/`rb_push`/`NR_BPACK_TRACE` 家族）对比"默认档 vs ON 档"的读集；或者让 `a5_att_run` 先把 Q/K/V 三面 `memset` 成 0xA5 再跑融合核、然后 D2H 抽查 K 面**是否只被写过一次**（写两次/漏写都会露馅）。**若最终必须另立私有面 ⇒ 清单④"零新面"破了，要如实写新面字节数（Q/K/V = 3 x 4.18 MB）与 pool 影响。**
## 尾巴 2：四种 C64 几何的覆盖面 —— 处置状态：**未放宽（按你的顺序要求：REF 忠实 → 门绿 → 再放宽）**
现状：只有 `M=32640 / across=30 / pad=0` 这批 fire ⇒ **8 条 C64 链里只覆盖 2 条**。
**若现在就要报净值，必须写成：只覆盖 2/8 ⇒ 帧约 −0.4…−0.5 ms**（= 0.509 ms/链 x 2 链 x 0.43 ≈ 0.44 ms，按 §77 的每链省额），**−1.75/−1.90 是"四种几何全覆盖"才有的可兑现值**。
放宽本身是参数活（`top/left/across/M` 已是 `att5::fused` 的入参，`qw-REJECT` 只是我加的门槛），但**必须在门绿之后做**。
## 现场（已核）
- 进程 = 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0**；三金标 `DD49827DD33A7EF07C2C17892F18970D`（x2）/ `249A46F374E98EB5FF5AD5E3A38EBC55` 未动。
- git tip **e20179e**（§75 已入库），我未 commit；工作区 = `M src/bench/sycl/libxmx_sycl.cpp`（只有诊断：dbg 上限 900 + `[a5-geom]` + `[a5-op]` 逐操作数尺寸 + witness 实参数修正）。
- 变体件：`builds\libxmx_att5{a,b,c,d,e,f,g,h}.dll`，最新 **att5h = B9528F5D3567EF93A26E9D451A3DB2F2**（`NR_ATT5_FUSE` 默认 0；默认档在 att5a 上自证 `1301 = DD49827D` + `passes 691`）。
- 本轮 GPU ≈ 12 min（5 次 walk）；最后这一段是纯 host。
## 下一条命令（原样，按顺序）
1. **K 面读集证据**（host 先行）：`rg -n "pgraph_ids|g_touch|NR_BPACK_TRACE" src/bench/sycl/libxmx_sycl.cpp` 找打印点，然后
 `powershell -NoProfile -ExecutionPolicy Bypass -File E:\DSH\walk.ps1 -Dll E:\DSHuilds\libxmx_att5h.dll -Tag att5h_touch -Runs 1`（前置 `NR_ATT5_FUSE=1 NR_ATT5_TRACE=1` + 打开 touch 打印）⇒ 对比默认档同一打印。
2. **门绿之前不动几何、不接图、不跑自重复门/40 门/16 对。**
3. 门绿后再：放宽四种几何（`qw` 门槛改成按 plan 的四种 tuple）⇒ 重 fire ⇒ 再走 ③④⑤。
## 未验假设（明说）
- "82.6% 是数值差而非取错地址"——依据是碎块统计（1,428,541 段、最长 71 B、平均 4.8 B），**没有做过逐字段（f16 解码）对照**；
- "K 面无人在 ON 档读"——**推断**，未取运行期证据（尾巴 1 就是为它立的账）；
- "8 条 C64 链 = 四种几何各 2 条"——只看到 first-per-M 的四行，**每种的条数未数**（`[a5-geom]` 有 104 行，可以离线数出来，下一条命令前先数）。


## §82-补：**104 条 quant_window 的几何计数已数完（host 离线，零 GPU）⇒ "覆盖 2/8" 是精确事实，不是估计**
`walk_att5h_on.txt` 的 104 行 `[a5-geom]` 按 (K, M, across, pad) 计数（plan 每帧录制两次 ⇒ 每行数量除以 2 = 真实链数）：
| K（tier） | 几何 (M / across / pad) | 行数 | 链数 |
|---|---|---|---|
| **64** | 32640 / 30 / **0** | 4 | **2** |
| **64** | 33728 / 31 / 4 (top0,left4) | 4 | **2** |
| **64** | 34560 / 30 / 262144 (top4,left0) | 4 | **2** |
| **64** | 35712 / 31 / 262148 (top4,left4) | 4 | **2** |
| 128 | 8640/15/0、8640/15/262144、9216/16/4、9216/16/262148 | 6 x4 | 6 |
| 256 | 2560/8/{0,4,262144,262148} | 8 x4 | 16 |
| 512 | 768/4/{0,262144}、960/5/{4,262148} | 8 x4 | 16 |
| 合计 | | **104** | **52 = 8 + 6 + 16 + 16** ✓ |
⇒ **C=64 tier 的 8 条链 = 四种 halo 几何各 2 条**；我的匹配器只收 `pad=0` ⇒ **只覆盖 2/8** ⇒ **现在可兑现的帧净值只能写 ≈ −0.44 ms**（0.509 ms/链 x 2 链 x 0.43），**−1.75…−1.90 是四种几何全覆盖后的值**（§77/§81 的外推口径已按此更正）。
⇒ 放宽 = 把 `a5_note_qw` 的门槛从 `M==32640 && pad==0` 改成"四种 tuple 各自核对 `ih/iw/across/pad` 与 645 一致"（`top/left` 已经是 `att5::fused` 的入参，`qr_kernel`/`pack_a_fused_gather` 的 gather 就是同一套 `-pad_top/-pad_left`）⇒ **参数活，不改数值**；但按军规 56 与本轮顺序，**必须在 K 面读集证据 + 门绿之后再做**。


# §83 **批准那一刀的收尾（3/3 门绿）+ 一条新的头号嫌疑：融合 closure 没把 Q/K/V 报进 PGRAPH touch set**　2026-11-04 05:3x-05:4x
## 1) 25 检查点门按你的要求在改后 REF 上重跑：**3 个独立进程、间隔 60 s、3/3 GATE GREEN**
exe `oneapi\port_e_chain.exe` = **`A6CA9F5D08E6F55DEB6748D5173F522C`**（含 C-0 的三条判别臂 + CHAIN2 检查点）；日志 `s6\PE_final{1,2,3}.log`；每进程：`GATE: GREEN (0 checkpoints differ)`、`LIVENESS(faceB/2): 1267 differs in 1,158,095 / 4,177,920 bytes`（**三遍数字一模一样**）、`#### port_e_chain: GREEN (fails=0)`（这个计数含 `CHAIN2-1267 / CHAIN2-pk3` 两个 2 发形态检查点）⇒ **REF 抄证之后门仍然绿** ✓ 本批 GPU 2.0 min，进程 0 残留。
## 2) **新的头号嫌疑（host 侧读代码读出来的，零 GPU）**：`pgraph_ids` / `pg_push` 的 touch set 语义
`libxmx_sycl.cpp:118-143`：
 - **touch token = 设备指针**；"same pointer in two closures = conflict (any direction)"；**`(void*)-1` = 未注册 op ⇒ 自己一个 wave**；
 - `pgraph_ids({...})` 由 recorder 声明该 closure 摸到的**所有** buffer（读写不分），`pg_push` 把它存进 `g_cmds_touch`；
 - **`pgraph_extra(int id)`@135 的存在理由就是"recorder 要补一条 plan 外的被摸 buffer"**。
**我的 A5 分支只继承了 645 自己的 touch set（`a,b,c,a_scale,b_scale,skip,cosine`）⇒ 融合核实际还写/读 **Q/K/V 三面**（`f.q/f.k/f.v`）**而没有报进 touch set** ⇒ 调度器可以把它和别的摸同三面（同一指针）的 closure 排在一起 ⇒ **跨 closure 竞态** ⇒ 完全符合"碎块式、全平面、只对真实数据出现"的 82.6% 签名（bench 里没有别的 closure，所以测不出来）。
**下一刀（一行级，已备好）**：在 `a5_take_wres` 命中后、`pg_push` 之前补
 `pgraph_extra(g.q); pgraph_extra(g.k); pgraph_extra(g.v);`（**外加 641 的 pk/sc 若融合核也摸**）⇒ 重编 `builds\libxmx_att5i.dll` ⇒ 一次 walk（`NR_ATT5_FUSE=1 NR_ATT5_TRACE=1`）看 **1301 是否变 EXACT `DD49827D`**。
**若这一刀命中 ⇒ 尾巴 1（`faceK` 布局不符）同时结案**：它不是"布局错"，而是"没申报"，**零新面仍然成立**（清单④不破）。
## 3) 覆盖面口径已按 (b) 定死（§82-补）：**现在可兑现 ≈ −0.44 ms/帧（2/8 链）**；−1.75…−1.90 是四种 halo 几何全覆盖后的值；放宽按你的顺序排在门绿之后。
## 4) 现场
进程 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE…**；三金标未动；git tip **e20179e**，未 commit；工作区 = `M src/bench/sycl/libxmx_sycl.cpp`（只有诊断：dbg 上限 900 + `[a5-geom]` + `[a5-op]` + witness 实参数修正）；`builds\` = att5a…att5h（最新 **att5h = B9528F5D3567EF93A26E9D451A3DB2F2**）；本轮 GPU 累计 ≈ **14 min**（5 次 walk + 3 进程门 + 两次 ladder）。


# §85 ★★ **ON 侧"82.6% 数值差"的真相：不是数值，是我多推了一条 `g_cmd_names` ⇒ skip 机构 REFUSED ⇒ 14 条链不再被跳过。修好之后 `NR_ATT5_FUSE=1` 档 1301 = `DD49827D` EXACT**　2026-11-04 06:0x-06:2x
**发现链（host 比对，零 GPU）**：`walk_att5i_on.txt` 里有一行
 `[skip-chains] graph=0 REFUSED: name offset 695 not a whole recording`
而默认档是 `closures=691 names=1382 name_offset=691 chains=52` ⇒ **`g_cmd_names` 比 `g_cmds` 多了 4 条 = 正好 4 次 fire**：我在 A5 分支里又 `g_cmd_names.push_back(__func__)` 一次，而 645 在 `pgraph_ids`/`flop_note` 处已经推过 ⇒ **名称向量与 closure 向量错位 ⇒ NR_SKIP_CHAINS 整套机构拒绝工作 ⇒ 14 条链不再被跳过**。
**铁证**：`dumps\att5i_on.1301.bin` 与 `dumps\bk.1301.pre-skip-1a.bin` **逐字节完全相同**（8,355,840 B，`same bytes? True`）⇒ ON 侧的 1301 从来不是"融合核算错"，而是**skip 配置没生效**；那 +4.4 ms/run 也是同一件事（少了 14 条链的跳过）。
**修一行（`s6/pe_c1_namefix.py`：删掉重复的 name push）⇒ `builds\libxmx_att5j.dll = C3F926C226BD53E7B747C36216B3DF2F`**：
| 档 | 1301 | 计数 | 每 run 帧时 |
|---|---|---|---|
| 默认（不设 env）att5j_off | **EXACT `DD49827DD33A7EF07C2C17892F18970D`** ✓ | — | 58.0-58.7 ms |
| **`NR_ATT5_FUSE=1` att5j_on** | **EXACT `DD49827DD33A7EF07C2C17892F18970D`** ✓ | `chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)` ✓ 一字未变 | **58.02 / 58.26 / 58.70 ms（与默认档同热）** |
⇒ **接图的逐位门在 C=64/pad=0 的 2 条链上已经通过**（fire 仍是 4 = 2 链 × 2 次录制）。
**顺带**：这一版还含 §83 的 `A5-TOUCH`（把 Q/K/V + pk/sc 报进 `pgraph_extra`）。**它的必要性未单独证明**（att5i = touch 但无 namefix ⇒ pre-1a；att5j = 两者都有 ⇒ EXACT）⇒ 下一轮该做一次 **只去掉 touch** 的 A/B，确认 touch 申报是不是必需（按 §83 的语义它应当是必需的：融合 closure 确实摸了那三面，不申报就是让调度器看不见冲突）。
**新军规候补（军规 57）**：**recorder 里任何"改写 closure 体"的融合，必须保持 `g_cmds` / `g_cmd_names` / `g_cmds_touch` 三个向量逐位同长同序；多推一条 name 会让 NR_SKIP_CHAINS 静默 REFUSED，表现为"融合数值错了"的假象（1301 会等于某个历史 gold，而不是乱码）。判据：`[skip-chains]` 头部行的 `closures/names/name_offset` 在开关两侧必须相同。**
**GPU 记账**：C-1 累计 ≈ **19 min**（7 次 walk + 3 进程门 + 两次 ladder），每次都带 60 s 间隔/冷却。
**现场**：进程 0；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = ABB969FE 未动；三金标未动；git tip e20179e，未 commit；工作区 = `M src/bench/sycl/libxmx_sycl.cpp`；`builds\` 多 att5i/att5j（**att5j = C3F926C2…** 是下一铲的基座）。


# §87 **新时间盒开工：① touch 申报 A/B（结论=不需要，已删）+ ② 四种 halo 几何放宽（7/8 链 fire、两档 1301 都 EXACT、帧回放 −0.8…−1.5 ms/run）**　2026-11-04 05:5x-06:5x
## ① `pgraph_extra` 必需性 A/B —— 件 `builds\libxmx_att5k.dll = E97E9D81107C8FE2B60FDB8CA0E0F855`（`NR_ATT5_TOUCH` 开关，其余与 att5j 一字不动；三次 walk 各 60 s）
**先按军规 57 读计数，再看 1301**：三臂的 `[skip-chains]` 全部是
 `closures=691 names=1382 name_offset=691 chains=52` + `chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)`
| 臂 | 1301 |
|---|---|
| ON + TOUCH=1 | **EXACT `DD49827DD33A7EF07C2C17892F18970D`** |
| **ON + TOUCH=0** | **EXACT**（同一颗 md5）|
| 默认档（不设 FUSE）+ TOUCH=0 | **EXACT** |
⇒ **申报不是必需的 ⇒ 已删**（`s6/pe_c1_touchdel.py`；注释里留了 A/B 读数和 caveat："这颗 plan 不需要" ≠ "任何 tier 都不会重叠"，将来别的 tier 接融合要先重跑这个 A/B）。
## ② 放宽四种 halo 几何 —— 件 **`builds\libxmx_att5m.dll = 0FCF9C20B0204D7E626824423FE639F4`**（当前基座）
改的只有 `a5_note_qw` 的门槛：`M==32640 && pad==0` ⇒ **四个 (M, across, pad) 白名单**；**核与数值一字未改**（`top/left/across` 本来就是 `att5::fused` 的入参，引擎 gather 就是 `quantize_row_kernel.hpp:54-57` 同一套 `-pad_top/-pad_left`）。
| 档 | 1301 | `[skip-chains]` | fires |
|---|---|---|---|
| `NR_ATT5_FUSE=1` | **EXACT `DD49827D…`** ✓ | `closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)` ✓ | **14 行 = 7 链 × 2 次录制** |
| 默认（不设 env） | **EXACT `DD49827D…`** ✓ | 同上 ✓ | **0** ✓ |
fire 按几何：`32640/30/0` = 4 行（2 链）✓、`33728/31/4` = 4（2 链）✓、`35712/31/262148` = 4（2 链）✓、**`34560/30/262144` = 2（只有 1 链）** ⇒ **7/8 覆盖**。
**第 8 条放不进去的确切原因（不是 halo）**：它的窗口残元腿 flags = **`epi=0 narrow=0 half=1`**（witness 原文：`[a5-dbg] wres-TUPLE cmd=56 a=1273 … M=34560 N=64 K=64 epi=0 narrow=0 half=1 skip=1268 src=1268 ih=136 iw=240 ac=30 pad=262144 heads=2 batches=1080`），而 `att5::fused` 的 P11 只实现 **epi=1 + narrow + half_skip** 这一种出口形态 ⇒ 元组校验把它正确拒掉。**接它 = 给核加第二种 epilogue = 改数值面 ⇒ 不在本铲范围。**
**帧回放（同热，run1-3）**：**ON = 57.29 / 57.40 / 57.36 ms** vs **默认 = 58.09 / 58.23 / 59.09 ms** ⇒ **≈ −0.8…−1.5 ms/run** ✓ 与 7/8 的预期（`7 × 0.509 × 0.43 ≈ 1.53 ms`）同量级；**口径按 7/8 报，不再用 8/8 的 −1.75…−1.90**。
## ③ 自重复门（进行中）：新仪器 + 读数
**仪器**：给 replay 工具加 `NR_SELFREP=N`（`src/gpu/nr_replay.c`，presence-gated；每帧后把 buffer 1301（8,355,840 B）下载并与**上一帧**逐字节比，**从第 10 帧起比**——plan 回放有跨帧 history，run0 vs run500 合法地会不同，稳态才是基准）。重编工具 `builds\nr_replay_sr.exe = 9FB2ED24B3426835A55E2C8C2E9BDD6A`（脚本 `s6/build_replay_sr.bat`）。
**牙齿检查（先证工具忠实）**：不带 SELFREP 跑默认档 ⇒ 计数与 walk 完全一致（`closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0 closures_noop=168`）、`run 0..3` 都在、**`SR_teeth.1301.bin` md5 = `DD49827DD33A7EF07C2C17892F18970D` = 金标** ✓ ⇒ 工具可用。
**两臂（`s6/pe_selfrep_run.ps1`，job `pwsh-97ebbec92513453c`，各 1000 帧、60 s 间隔）**：ON(`NR_ATT5_FUSE=1`) 与默认档对照 ⇒ 读数进 §88。
**GPU 记账**：① 3 次 walk ≈ 4.5 min + ② 2 次 walk ≈ 3 min + 牙齿 1 次 ≈ 1.5 min + ③ 两臂 ≈ 8 min ⇒ 本盒 ≈ **17 min**。


# §88 **③ 自重复门在 shipped 件上过：ON 档 1000 帧连发、989 次相邻帧逐字节比 = ad=0**（默认档对照同样 0）　2026-11-04 06:0x-06:2x
件：uilds\libxmx_att5m.dll = 0FCF9C20B0204D7E626824423FE639F4 + 新仪器 uilds\nr_replay_sr.exe = 9FB2ED24B3426835A55E2C8C2E9BDD6A（NR_SELFREP 在 **每帧后**把 buffer 1301（8,355,840 B）下载并与**上一帧**逐字节比；从第 10 帧起比，因为 plan 回放有跨帧 history，run0 vs run500 合法地会不同 —— 稳态才是基准）。
**牙齿检查**（不带 SELFREP，默认档）：closures=691 names=1382 name_offset=691、chains_skipped=14 refused=0 closures_noop=168 passes=691、SR_teeth.1301.bin md5 = **DD49827DD33A7EF07C2C17892F18970D = 金标** ⇒ 重编的工具与 oneapi\nr_replay_now.exe 等价 ✓
| 臂 | fires | SELFREP |
|---|---|---|
| **NR_ATT5_FUSE=1（ON）** | **14 = 7 链 x 2 录制** | **id=1301 runs=1000 compared=989 bad=0 first_bad_run=-1** ✓ |
| 默认档（不设 env，对照） | 0 | 
uns=1000 compared=989 bad=0 ✓ |
⇒ **融合后的 shipped closure 在真实 plan 操作数上自重复：1000 帧 x 7 条链 = 约 7000 次融合 launch，0 bad**（军规 46/48/51 满足；面集合 = 该形态真正会写的 1301 双面，不是诊断面）。
**两臂的 [skip-chains] 计数一致**（chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)）⇒ 军规 57 的三向量同长同序在 1000 帧尺度上也成立 ✓
**GPU**：③ 两臂 ≈ 8 min（1000 帧 x 2 + 60 s 间隔）。④ 40 门、⑤ 帧 16 对随后。


# §89 **④ 40 门：变体件上 39 GREEN / 1 RED，而那颗 RED 是 `gate_skip_graph` 的**工件身份守卫**（它的实质检查在变体下也 EXACT）；复原 ABB969FE 后该门 GREEN**　2026-11-04 06:3x-06:5x
**做法（不碰 `out\libxmx.dll`，只临时 stage `oneapi\libxmx_sycl.dll`，并先做备份）**：
 - 备份：`oneapi\libxmx_sycl.dll`(ABB969FE…) → `builds\libxmx_sycl_ABB969FE.bak.dll`（md5 复核 = ABB969FE ✓）
 - stage：`builds\libxmx_att5m.dll`（0FCF9C20…）→ `oneapi\libxmx_sycl.dll`
 - `bash E:/DSH/run_gates.sh`（40 门，一字未改）
**结果**：**39 GREEN / 1 RED**，RED = `gate_skip_graph`。
**RED 的原因（读日志 `logs\gate_skip_graph.log`）**：该门自己的**工件守卫**在叫：
 `FAIL  … out/libxmx.dll 与 oneapi/libxmx_sycl.dll 必须 ABB969FE（你没有改写任何 dll）`
而它在**变体下**的实质检查全部 ok：`gate40_p3: 691 passes`、`1301 dump … (8355840 B)`、**`1301 EXACT vs bk.1301.skip.bin md5=dd49827d…`** ✓ ⇒ **不是融合把 skip/graph 门打坏了，是这道门设计上只认 ABB969FE 基座**（与 §69 那次"stage 非 ABB969FE ⇒ RED，复原后 40 GREEN"同一现象，已在账）。
**复原 + 复跑**：`oneapi\libxmx_sycl.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0** ✓（`out\libxmx.dll` 全程未动，同为 ABB969FE ✓）；`GATE_ONLY=gate_skip_graph bash E:/DSH/run_gates.sh` ⇒ **GREEN，1 GREEN / 0 RED** ✓
⇒ **④ 的诚实写法：变体件 = 39/40 GREEN + 第 40 门的实质子检查也 EXACT（只有工件身份守卫按设计 RED）；基座复原后 40/40 GREEN。**
**⑤ 帧 16 对已开跑**（job `pwsh-f5cad28889a7406c`）：`ab.ps1 -DllA out\libxmx.dll -DllB builds\libxmx_att5m.dll -Pairs 16 -EnvB 'NR_ATT5_FUSE=1'`（A 侧 unset 全部 NR_*，ab.ps1 v3 每腿自清 ✓）；**预期口径 = 7/8 覆盖 ⇒ ≈ −1.0…−1.5 ms/帧**（不是 8/8 的 −1.75…−1.90）。读数进 §90。
**GPU 记账**：③ 8 min + ④ 40 门 ≈ 12 min + 复原复跑 1 门 ≈ 0.5 min + ⑤ 16 对（进行中，预计 20-35 min）。


# §90 **⑤ 帧 16 对 = −0.978 ms/帧（赢 15/16，CI95 [−1.186, −0.769]）+ ⑥ 逐 op 复核：串行 −2.30 ms 与帧 −0.98 严格对得上（×0.43），并揪出一笔 +0.73 ms 的白工**　2026-11-04 06:5x-08:0x
## ⑤ 帧 16 对（同热交替，A = `out\libxmx.dll` = ABB969FE 且 unset 全部 NR_*，B = `builds\libxmx_att5m.dll` + `NR_ATT5_FUSE=1`）
`ab.ps1` v3（每腿自清 NR_*），16 对，run0 丢弃、run1-3 取中位：
```
pair  1..16 delta: -0.670 -0.470 -1.440 -1.080 -1.150 -0.810 -1.200 -1.030 -1.090 +0.040 -1.580 -1.160 -1.290 -1.030 -0.700 -0.980
A mean 58.872 ms   B mean 57.894 ms   n=16  mean -0.978  sd 0.392  se 0.098  **CI95 [-1.186, -0.769]**  **赢 15/16**
判定：**转正**（判据 <=-0.5 且赢 >=10/16 ✓）；passes 两侧每对都 691/691 ✓
```
⇒ **7/8 链覆盖的实际帧净值 = −0.98 ms**（不是 8/8 的 −1.75…−1.90；口径已按 §87 更正）。
## ⑥ 逐 op 复核（新件 `builds\libxmx_rt2a5.dll = F662051077B2BA709CEBA7EF7C348C31` = RUN_TIMING 仪器 + A5 接线；两臂各 691 行 rtcsv，`s6/pe_rt_ab.ps1` / `s6/pe_rt_read.py`）
| closure 名 | 默认档 ms/帧 | ON 档 ms/帧 | Δ | 行数 off→on |
|---|---|---|---|---|
| `xmx_rec_window_attention` | 16.48 | 13.30 | **−3.18** | 52 → 45（7 条被 no-op）|
| `xmx_rec_gemm_int8_qkv` | 14.55 | 12.58 | **−1.96** | 60 → 53 |
| `quant_window(FUSED-pack)` | 0.12 | 0.10 | −0.02 | 52 → 45 |
| `xmx_rec_gemm_window_int8_residual` | 12.98 | **14.07** | **+1.09** | 52 → 52（融合 launch 挂在这条上）|
| `xmx_rec_quant` | 3.65 | **4.38** | **+0.73** | **80 → 87** |
| `xmx_rec_gemm_int8_batched` / `_residual` | 7.10 / 22.28 | 7.10 / 22.87 | +0.01 / +0.59 | 72 / 68 不变 |
| `quant_window(A5-fused)` / `gemm_int8_qkv(A5-fused)` / `window_attention(A5-fused)` | — | **0.02 / 0.01 / 0.01**（7 行 each） | ≈0 ✓ | 0 → 7 |
| **TOTAL（691 行）** | **135.98** | **133.68** | **−2.30 ms 串行/帧** | |
**对账**：串行 −2.30 ms × 0.43 = **−0.99 ms/帧** ⇒ **与 ⑤ 实测 −0.978 严格吻合** ✓（仪器与图内自洽，不是撞来的）。
**融合 launch 的真实单价**：`wres_window` 52 条里 7 条背上融合 ⇒ +1.09/7 = **0.156 ms** 增量；原来这条自己 ≈0.25 ms ⇒ **融合后这条 ≈0.40 ms/链** ✓ 与 bench 的 `L1n = 0.4336` 同量级 ✓
**★ 揪出一笔白工（下一铲的钱在这里）**：`xmx_rec_quant` 行数 **80 → 87、+0.73 ms** ⇒ 那 7 条链的 **644 QUANT 从"FUSED-pack 溶解态"退回成真发**：我在 645 里 `return 0` 太早，**跳过了 `fused_w`/`g_fused_quant` 的登记**（@4137-4141 那套 fold），于是 644 不再被溶解、白做一次量化 ⇒ **≈0.104 ms/链 × 7 = 0.73 ms 串行 ≈ 0.31 ms/帧 可以捡回来**。修法 = A5 命中时把该链 644 的 fold 登记补上（或显式 no-op c_q2），**不改数值**。
**剩余活站（给下一铲排序用）**：
 1. 捡回 644 的白工（+0.31 ms/帧，纯登记活）；
 2. 第 8 条 C64 链（`epi=0 narrow=0`）要接得给 P11 加第二种 epilogue 形态 ⇒ **改数值面**，代价另评；
 3. C128 tier（12 条链，att 合一在 bench 上 **+51% 更差**、SLM 41,984 越 32KB 崖 ⇒ **不接**，除非先解决 SLM）；
 4. FFN 半已出货（S6-1a，`chains_skipped=14` 不变）；刀 1（跨链合并）已判死。
**GPU 记账**：⑤ 16 对 ≈ 22 min（单批，>20 min ⇒ 批后冷却）+ ⑥ 两臂 ≈ 4 min ⇒ 本盒 GPU ≈ **31 min**；`out\libxmx.dll` / `oneapi\libxmx_sycl.dll` 收尾均为 **ABB969FE4AAF0F94AA03C3F53781EDD0**（④ 的 stage 已复原并复核），三金标未动，进程 0。


# §91 **那笔 +0.73 ms 白工的机制已读死（为下一铲备好三条路，均未动手）**　2026-11-04 06:4x-06:5x（纯 host）
**为什么 ON 档多出 7 条真发 `xmx_rec_quant`（80→87 行、+0.73 ms）：**
 - 642 的 qkv 折叠在**运行期**登记 `g_fused_quant[c] = a_scale`（`libxmx_sycl.cpp:3670`，在 `pg_push` 的 body 里）；
 - 644 的溶解也是**运行期**判断：它的 body 先查 `g_fused_quant.find(source)`（@6217-6218），查到就退化成 memcpy/不做；
 - **A5 命中后 642 的 body 被 no-op ⇒ 登记不再发生 ⇒ 644 在运行期查不到 ⇒ 退回真发量化** ⇒ +0.104 ms/链 × 7 = +0.73 ms 串行（≈ **0.31 ms/帧**）。
 - 这也解释了为什么我原先在 645 **record 期** no-op `g_cmds[c_q2]` 的打算没用：A5 的 fire 发生在 645 的 record 时刻，而 644 的溶解决定在**运行期**才做，那时 map 已经空了。
**三条候选修法（代价从小到大，都没做）**：
 1. **让融合 closure 在运行期补登记**：在 `a5_att_run()` 末尾把该链 644 的 (source -> a_scale) 写进 `g_fused_quant`（语义 = "int8+scale 已由 producer 写好"）。**但 att5 核在 DUMP=false 时根本不写 pk2/sc2**（P10 的全局 store 在 `if (DUMP)` 里）⇒ 单补登记 = 让 644 读到没人写过的面 ⇒ **数值危险，必须先做第 2 条**。
 2. **打开 P10 的 PKT/AS2 全局写出**（≈2 MB/链 的 int8+float 写，远便宜过一次完整量化）：把 `att5_fused_kernel.hpp` 的 P10 outlet store 从 `if (DUMP)` 里拆出来、变成 shipped 侧的一个独立开关（例如 `WRITEOUT`），融合 closure 写完之后 644 的溶解 memcpy 甚至可以直接省掉。⇒ **改的是写出面，不动数值链**，但要重跑 25 检查点门 + 双档 1301 + SELFREP。
 3. **不动它**：接受 0.73 ms 串行（0.31 ms/帧）的损失，当前净值仍 −0.98 ms/帧。
**我的建议顺序**：先 2 再 1（2 是 1 的前提），做完必须重跑：bench 25 检查点门（3 进程）→ 双档 1301 → `NR_SELFREP=1000` → 40 门（记得备份/stage/复原 ABB969FE）→ 16 对复测（预期 −0.98 → **约 −1.3 ms/帧**）。
**未验假设**：+0.73 ms 的归因来自行计数（80→87）与 `g_fused_quant` 的代码语义，**没有单独跑一次"只补登记不写面"的对照**（那会 RED，正好可以证伪/证实这条链）——留给下一铲，别在没门的情况下试。


# §92 **白工的修法收敛成一行（比 §91 的三条更准）；未动手，等批**　2026-11-04 06:4x（纯 host，零 GPU）
§91 说"要先打开 P10 的 PKT/AS2 写出"——**查完溶解机制后发现不必**。真正的机制：
- 644 的溶解 = **运行期** `g_fused_quant.find(source)`（@6217-6218），命中就走 memcpy；
- 那条登记由 **642 的 qkv 折叠在自己的 body 里**写：`g_fused_quant[c] = a_scale`（@3670）；
- A5 把 642 的 body no-op ⇒ 登记消失 ⇒ 644 退回真发（实测 +0.104 ms/链 × 7 = +0.73 ms 串行）。
**一行修法**：在 `a5_take_wres()` 里、no-op 之后补
 `g_fused_quant[g.att] = a_scale;`   // source(=1277 面) -> 该链 644 的 a_scale buf，照 @3670 的约定
⇒ 644 走溶解分支（一次 2 MB memcpy，拷的是**没人读**的 pk2/sc2）⇒ 预计把 +0.73 ms 压到 ≈+0.07 ms ⇒ **串行 −2.30 → ≈ −2.95 ms ⇒ 帧 −0.98 → ≈ −1.25…−1.30 ms**。
**前提仍未证**：pk2/sc2 在 ON 档"没人读"是推断（= §82 尾巴 1 的同一族）。**批准后的第一刀不是改代码，而是取证据**：把两档的 `g_cmds_touch`（每 closure 的 touch 指针表）打出来，查 pk2/sc2 的指针除 644/645 外还出现在哪些 closure ⇒ 若出现第三方 ⇒ 这条路作废，回到 §91 的选项 2（打开 P10 写出）。
**验证链（若动手）**：touch 证据 → bench 25 检查点门（3 进程）→ 双档 1301（默认必须仍 `DD49827D`）→ `NR_SELFREP=1000` bad=0 → 40 门（备份/stage/复原 ABB969FE）→ 16 对复测。
**现场**：未改任何代码（`pe_c1_foldreg_note.py` 只是草稿，**没有执行**）；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = ABB969FE；进程 0；工作区 = `M src/gpu/nr_replay.c`；最优基座 = `builds\libxmx_att5m.dll = 0FCF9C20…`；本盒 GPU ≈ 31 min（已批间冷却）。


# §93 **plan 步骤对 scratch id 的引用普查（host，零 GPU）⇒ 尾巴 1 的结论改成"不能靠 id 推断无人读，只能靠 touch set + 实测"**　2026-11-04 06:4x
工具：`s6/pe_plan_refs.py` 直接扫嵌入 plan 的 C 表（`E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/work/plan_960x544.c`，5254 条 OP_ 步骤行）。
**先证这份 plan 与线上同源**：用它编出的 `builds\nr_replay_sr.exe` 在默认档 1301 = **`DD49827D` = 金标**（§88 牙齿检查）✓ ⇒ 普查对象正确。
| buffer id | 被多少条 OP_ 步骤行引用 |
|---|---|
| 1267 | 403 |
| 1270 | 29 |
| 1271 | 23 |
| **1272 / 1273**（pk/sc scratch） | **979 / 979** |
| **1274** | 511 |
| **1275 / 1276 / 1277** | 515 / 243 / 243 |
| 1268 / 1278 / 1298 | 4 / 4 / 4 |
| 1303 / 1305 / 1306 / 1307 / 1308 / 1309 | **0**（只在运行期 `[a5-op]` 里出现 ⇒ 它们是**第二次录制/resize 后的实例号**，不在静态步骤表里）|
**读法与后果**：
 1. **pk/sc scratch 是全帧复用的**（979 条步骤引用 1272/1273）⇒ **"这条链的 pk2/sc2 没人读"不能从 id 上推**——同一个 id 在别的链/别的步骤上是有读者的。⇒ §82 尾巴 1 的"643 已 no-op 所以没人读"这种推断**作废**；安全性只能来自两处证据：**(a) PGRAPH `g_cmds_touch` 的逐 closure 指针表**（还没打），**(b) 实测**：1301 逐位（两档 EXACT ✓）+ `NR_SELFREP=1000` 相邻帧 0 bad ✓（§88）——**实测已经过了，但机制账要补 (a)。**
 2. 好消息：溶解 644 走的是** shipped 默认的既有路径**（45 条链的 `quant(FUSED-pack)` 本来就在 memcpy 这些共享 scratch）⇒ §92 那一行 `g_fused_quant[g.att] = a_scale;` 不会发明新的共享写，只是把这条链并入既有溶解态 ⇒ **风险等级 = 低**，但 (a) 的证据仍要先补，因为它同时是尾巴 1 的结案材料。
 3. `[a5-op]` 里的 1303/1305-1309 **不在静态步骤表**里 ⇒ 它们是第二次录制的实例 ⇒ 说明 **record-time 与 run-time 的 id 解析不是同一套**，这正是 §85 军规 57（三向量同长同序）那条坑的深层原因：**任何按 id 的静态推理都可能对不上运行期实例**。
**下一铲的顺序（已按此修正）**：先打 `g_cmds_touch`（presence-gated，只打印不改行为）⇒ 确认 pk2/sc2/QKV 三面在 ON 档的读集 ⇒ 再落 §92 的一行登记 ⇒ 然后走完整验证链（bench 门 → 双档 1301 → SELFREP → 40 门 → 16 对）。
**现场**：仍未改任何代码；`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = ABB969FE；进程 0；工作区 = `M src/gpu/nr_replay.c`；本盒 GPU ≈ 31 min（无新增）。


# §94 **尾巴 1 结案（有证据了）：PGRAPH 的冲突模型是"指针相等即冲突"，所以"别的 closure 也摸同一地址"不是数据危险，而是调度约束；A5 在 ON 档 1301 EXACT + SELFREP 0/1000 = 实测安全**　2026-11-04 06:5x-07:0x（一次 walk + host 分析）
**仪器**：`libxmx_sycl.cpp` 的 `pg_push` 加 presence-gated 的 `NR_PG_TOUCHDUMP`（record-time 打印每个 closure 的 touch 指针表；**无设备副作用、不加 op**，军规 4/9），并给 `[a5-op]` 的 src1267 / out1270 / faceQ/K/V 补 `ptr=%p` 探针。件 **`builds\libxmx_att5n.dll = 6E01CBEBBA265A454E3822D3E985D2AB`**；**开诊断后 ON 档仍 `1301 EXACT = DD49827D`** ⇒ 诊断不改变行为 ✓
**读数**（`s6/pe_touch_read.py`，1382 条 `[pgt]` = 691 × 2 录制 ✓ 军规 57 再一次成立）：
| A5 操作数（运行期实际地址） | 有多少 closure 的 touch 表包含它 |
|---|---|
| `src1267` id=1303（66,846,720 B） | 200 |
| `out1270` id=1271（4,177,920 B） | 28 |
| `faceQ` id=1308 | 308 |
| `faceK` id=1307 | 266 |
**怎么读**（这是 §82 尾巴 1 的正解）：源码注释写死了语义 —— `libxmx_sycl.cpp:118-122`：**"touch tokens = DEVICE POINTERS … same pointer in two closures = conflict (any direction); (void*)-1 = conflict-with-everything (unregistered op -> own wave)"** ⇒ **"很多 closure 摸同一地址"不是"有人在读我的脏数据"，而是 PGRAPH 把它们判为互相冲突、拆进不同 wave**（保守调度）。所以：
 - **不存在"K 面被别人按图像序读走"的语义风险**：那些 closure 与我们的融合 closure 之间被冲突图强制串行化；
 - **不做 `pgraph_extra` 申报也不会读到脏数据**（§87 ① 的 A/B 已证 1301 EXACT），代价只是**少一层调度约束**（可能允许更多重叠 ⇒ 也正是它没有把结果改坏的证据）；
 - **实测层面**：ON 档 `1301 EXACT`（两次独立录制）+ **`NR_SELFREP=1000` 相邻帧逐字节 0 bad**（§88）⇒ **尾巴 1 结案：安全，机制 = 保守的指针冲突模型，不是 id 复用**（§93 的 id 普查只说明 id 不是地址，不能作为推理依据 —— 这也写进账了）。
**顺带一条对下一铲（§92 的一行 `g_fused_quant[g.att] = a_scale`）的判定**：溶解分支写的是 **共享 scratch（1272/1273 家族）**，而 PGRAPH 会把摸同一地址的 closure 强制串行 ⇒ **不会串数据**；且这条溶解路径本来就是 45 条链的 shipped 默认行为 ⇒ **风险等级低，可以做**。
**现场**：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **ABB969FE…**；三金标未动；进程 0；工作区 = `M src/gpu/nr_replay.c`（SELFREP 仪器）+ `M src/bench/sycl/libxmx_sycl.cpp`（TOUCHDUMP + ptr 探针，**未 commit**）；件：`att5m = 0FCF9C20…`（功能基座）、`att5n = 6E01CBEB…`（带 touch 诊断）；本盒 GPU ≈ **33 min**（新增仅 1 次 walk）。


# §95 **① 捡 644 白工：指纹到手（`xmx_rec_quant` 行数 87→80）、双档 1301 EXACT、SELFREP 1000 bad=0 —— 但出现一次不可复现的崩（run 528，0xC00000FD），正在放大验证**　2026-11-04 06:5x-07:2x
**改法（比 §92 那一行更对）**：不在 A5 分支里发明登记，而是**复用 shipped 既有机制** —— 645 的正常路在 @4386 调
 `QuantFused qfw; const bool fused_w = qfuse_take(a, a_scale, M, K, qfw);`
而 `qfuse_take`（@362-376）的动作正是 **`g_cmds[out.qcmd] = [](){};  g_cmd_names[out.qcmd] = "quant(FUSED-pack)";`** ⇒ 我的分支提前 return 把它跳过了 ⇒ 644 退回真发。
补丁 `s6/pe_c1_fold2.py`：在 `if (a5fire) {` 之后、`pg_push` 之前补
 `QuantFused qfw5; qfuse_take(a, a_scale, M, K, qfw5);`
（**§92 原来设想的 `g_fused_quant[g.att]=a_scale` 作废**：那条会让 644 走 memcpy 分支，把 **f16 的 1277 当 int8 拷进共享 scratch 1273/1274** ⇒ 危险；qfuse_take 是纯 no-op ⇒ 干净。）
件：功能 **`builds\libxmx_att5o2.dll = 17FBD1B9152054F1A2F9540CC6E01427`**；计时同款 **`builds\libxmx_rt2o2.dll = C18FF1962A690491E0B3670B2F126D18`**（先有一次 att5o/rt2o = 补丁锚点没对上的**空枪**，md5 `CCBE4ACA…`/`E827C617…`，别拿它们读数）。
### 指纹（rt2o2，两臂各 691 行 rtcsv，`s6/pe_fold_verify.ps1`）
| 臂 | 总计 ms/帧 | `xmx_rec_quant` **行数** | 该族 ms | A5-fused 行数 |
|---|---|---|---|---|
| 默认 | 140.12 | **80** ✓ | 3.73 | 0 |
| **ON** | **133.05** | **80** ✓（改前是 **87**）| 3.82 | **21**（= 7 链 × 3 条 no-op）|
⇒ **644 白工已回收**：ON 侧总账从上一铲的 133.68 → **133.05（−0.63 ms 串行）**，与预测的 +0.73 同量级 ✓（两臂不同 build 的 off 总数 135.98 vs 140.12 不可跨 build 比，**只用同 build 的 off/on 差**）。
### 双档 1301 + 军规 57 计数（att5o2）
- 默认档 `FOLD_off.1301.bin` = **`DD49827DD33A7EF07C2C17892F18970D` EXACT** ✓
- ON 档 `FOLD_on.1301.bin` = **同一颗 EXACT** ✓
- 两侧 `[skip-chains]` 一字不差：`closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)` ✓；fires：默认 **0**、ON **14**（7 链 × 2 录制）✓
### SELFREP 与那次崩
- 第一次（`FOLD_srep_on`）：**跑到 run 528 进程死**，退出码 **3221225725 = 0xC00000FD（STACK_OVERFLOW）**，日志停在 `run 528: 85.00 ms (691`，没有 SELFREP 行；
- 第二次（`SREP_on2`）：**1000 帧全跑完，`SELFREP id=1301 runs=1000 compared=989 bad=0 first_bad_run=-1`** ✓；
- **正在做第三、四次 1000 帧放大**（job `pwsh-4839f2d1a4734feb`，`s6/pe_srep_x3.ps1`）⇒ **若不再复现**：记为"一次未复现的工具侧崩"（注意 SELFREP 每帧多下载 8 MB，run 时长 85 ms vs 裸跑 58 ms ⇒ 仪器本身有额外负载）；**若复现**：按军规 47 当真竞态处理，① 这一铲先扣住。
**口径提醒**：SELFREP 的每帧时间含 D2H，不能当帧价用（帧价只认 `ab.ps1`）。


# §96 **① 收尾：SELFREP 三臂共 3000 帧 bad=0（那次崩未复现）；② A5 已固化成编译期默认 ON（`T_ATT5_FUSE_DEF=1`），三项核验到手**　2026-11-04 07:0x-07:3x
## ① 的自重复门补测（`s6/pe_srep_x3.ps1`，件 att5o2 + 工具 `nr_replay_sr`）
| 臂 | 结果 |
|---|---|
| `SREP_on2`（第一次复跑） | `runs=1000 compared=989 bad=0` ✓ |
| `SREPx3_1` | 1000 帧跑完，`bad=0` ✓ |
| `SREPx3_2` | 1000 帧跑完，`bad=0` ✓ |
⇒ **合计 3000 帧相邻比对（约 21,000 次融合 launch）0 bad**；§95 里那次 **run 528 的 0xC00000FD 崩未复现**（三次都没再现）⇒ 记为**未复现的工具侧异常**（仪器每帧多下载 8 MB，run 时长 85 ms vs 裸跑 57-58 ms ⇒ 仪器本身有额外负载；**帧价只认 `ab.ps1`，SELFREP 的时间数不作价**）。若它再现，按军规 47 当真竞态处理。
## ② 固化成编译期默认 ON（军规 59）
- 源码：`a5_on()` 的默认值改成宏 ⇒ `#ifndef T_ATT5_FUSE_DEF / #define T_ATT5_FUSE_DEF 0 / #endif` + `getenv("NR_ATT5_FUSE") ? atoi!=0 : (T_ATT5_FUSE_DEF != 0)`（`s6/pe_c1_macro.py`）⇒ **bench/其它构建不带宏 = 仍默认 OFF**，只有 load-slot 走 `tools/shipped_build.defs`；
- `tools/shipped_build.defs` 加 **`T_ATT5_FUSE_DEF=1`** + 出处注释（`s6/pe_c1_defs.py`）；
- 件：**`builds\libxmx_att5p.dll = 3BAECF2A4B0F49F45E2557CE4808C2CF`**，build 行实到 `/DT_SKIP_CHAINS_DEF=\"18,…,32\"  /DT_ATT5_FUSE_DEF=1` ✓
**军规 59 的三件核验（我这边能给的读数）**：
| 核验 | 读数 |
|---|---|
| **不设任何 env**（只开 `NR_ATT5_TRACE` 取 witness） | **`fires = 14`（7 链 × 2 录制）** ✓、`chains_skipped=14 refused=0 closures_noop=168 passes=691 (unchanged)` ✓、**1301 EXACT `DD49827D…`** ✓、run 57.11 / 57.12 / 57.10 ms |
| **逃生门 `NR_ATT5_FUSE=0`** | `fires = 0` ✓、计数同上 ✓、**1301 EXACT** ✓、run 58.28 / 58.14 / 58.22 ms |
| 两侧帧差 | **−1.1 ms/run**（57.11 vs 58.19）⇒ 与 ① 之后应有的 −1.25…−1.30 相符（walk 的 run 数含冷启动 run0，未计） |
⇒ **换位（`out\libxmx.dll` ← 这颗）由你执行**；换位后 ① 的 md5 一致性（`out\libxmx.dll` == `oneapi\libxmx_sycl.dll`）由你复核，我不碰那颗。
## ③ 已开跑
40 门（att5p stage 进 `oneapi\libxmx_sycl.dll`，先备份 `builds\libxmx_sycl_ABB969FE.bak2.dll`，跑完复原）= job `pwsh-e6f9fc25030e4e46`；随后帧 16 对（A = `out\libxmx.dll` = ABB969FE、unset 全部 NR_*；B = `att5p`、**同样不设 env** ⇒ 靠编译期默认 ON，判读 ≤−1.0 且赢 ≥10/16）。


# §97 **③ 交回：40 门（变体 39/40 + 守卫门复原后 GREEN）+ 帧 16 对（编译期默认 ON、两侧都不设 env）= **−1.251 ms/帧，赢 16/16，CI95 [−1.352, −1.151]** ⇒ 与预测 −1.25…−1.30 正中；比上一铲 −0.978 的改进 = **−0.273 ms**，与"捡 644 白工"预测的 +0.31 对得上**　2026-11-04 07:3x-08:0x
## 40 门（`att5p` stage 进 `oneapi\libxmx_sycl.dll`；先备份 `builds\libxmx_sycl_ABB969FE.bak2.dll`）
**39 GREEN / 1 RED**，RED 仍是 `gate_skip_graph` 的**工件身份守卫**（它只认 ABB969FE 在 oneapi 槽里；它的实质 1301 检查在变体下 EXACT，见 §89 同一现象）。
**复原**：`oneapi\libxmx_sycl.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0** ✓、`out\libxmx.dll` = **ABB969FE…** ✓；复原后单跑该门 ⇒ **GREEN（1/0）** ✓
## 帧 16 对（A = `out\libxmx.dll`(ABB969FE)，B = `builds\libxmx_att5p.dll`，**两侧都不设任何 NR_\_*** ⇒ 靠编译期默认 ON；ab.ps1 v3 每腿自清）
```
deltas: -0.840 -1.650 -1.370 -1.220 -1.100 -1.190 -1.180 -1.230 -1.190 -1.120 -1.380 -1.370 -1.220 -1.090 -1.360 -1.510
A mean 58.631  B mean 57.380   n=16  mean **-1.251**  sd 0.188  **CI95 [-1.352, -1.151]**  **赢 16/16**  每对 passes 691/691
判定：**转正**（判据 <=-1.0 且赢 >=10/16 ✓✓）
```
**与预测对齐**：上一铲（env 切换、无 fold）= −0.978 [−1.186,−0.769]；这一铲 = −1.251 [−1.352,−1.151] ⇒ **改进 −0.273 ms**，与 §92/§95 预测的"+0.31 ms/帧（0.73 ms 串行 × 0.43）"吻合 ✓；sd 也从 0.392 收到 0.188（同热更稳）。
**方差口径**：两铲都是 run0 丢弃、run1-3 取中位；CI 只覆盖同热重复性，不含跨盒热漂移。
## 出处已写进 `out\SHIPPED_BUILD.md` §6（军规 59 要求的"哪个 commit + 哪些 /D"）
`basis = ABB969FE 基座 + commit d64fa0f（A5 接线/att5_fused_kernel.hpp/NR_SELFREP/TOUCHDUMP）+ 工作区未 commit 的 M libxmx_sycl.cpp（A5-FOLDRESCUE + T_ATT5_FUSE_DEF）与 M tools/shipped_build.defs（T_ATT5_FUSE_DEF=1）`；`/D 全串 = /DT_SKIP_CHAINS_DEF=\"18,…,32\" /DT_ATT5_FUSE_DEF=1`；`件 = builds\libxmx_att5p.dll = 3BAECF2A4B0F49F45E2557CE4808C2CF`；证据（双档 EXACT、三向量计数、SELFREP 3000 帧 0 bad、40 门口径、帧价）都在那一节里。
**换位由父执行**（我不碰 `out\libxmx.dll`）；换位后建议再跑一次 40 门求 **40/40 GREEN**，并把新 md5 追加进 `out\DEPLOY.md5.txt`。
**GPU 记账（本盒）**：① 验证 ≈ 16 min（rt 两臂 + 双档 + SELFREP×4）+ ② 三次 walk ≈ 5 min + ③ 40 门 ≈ 13 min + 复原单门 ≈ 0.7 min + 16 对 ≈ 24 min（含 300 s 批间冷却）⇒ **≈ 59 min**，批间均有 ≥60 s，>20 min 批后冷却已做。


# §98 **换位已发生（两槽 = `3BAECF2A…`）+ 守卫门在新件下 RED 的实证 + 兑现率重算（串行 −2.9 ms vs att 半区原价 6.87 ms = **42%**）+ 下一铲排序**　2026-11-04 07:4x-08:0x（一次 40 s 单门，其余纯 host）
## 1) 换位与备份
`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`3BAECF2A4B0F49F45E2557CE4808C2CF`**（父执行，军规 59 的 ① 两槽一致 ✓）；旧基座备份 **`builds\libxmx_sycl_ABB969FE.bak2.dll = ABB969FE4AAF0F94AA03C3F53781EDD0`** ✓ 可回退。
## 2) ★ 守卫门现在会 RED（实证，不是预测）
单跑 `gate_skip_graph`（07:5x，40 s）⇒ `0 GREEN / 1 RED`。日志尾部三条 ok + 一条 FAIL：
```
ok  gate40_p3: 1301 EXACT vs bk.1301.skip.bin  md5=dd49827dd33a7ef07c2c17892f18970d
ok  out/libxmx.dll 这一腿 1301 逐位相同 = 新金标 dd49827d…
ok  oneapi/libxmx_sycl.dll 同一只字节 1301 也 = 新金标
FAIL 要求 out/libxmx.dll 与 oneapi/libxmx_sycl.dll 必须 ABB969FE（你没有改写任何 dll）
```
⇒ **实质检查全过，RED 只来自写死的 ABB969FE 期望** ⇒ 要 40/40 得由**父**把守卫期望换成 `3BAECF2A…`（或改成读 `out\DEPLOY.md5.txt` 的当前条目），**我不改门**（纪律）。换完应重跑整轮 40 门。
## 3) 仪器假象一条（防误读）
`walk_att5p_noenv.txt` 的 `fires=0` 是**没开 `NR_ATT5_TRACE`** ⇒ witness 不打；**"不设 env 时 fires=14" 的正证是 `walk_att5p_trace.txt`（TRACE 开、FUSE 不设）= 14** ✓。
**新军规候补（军规 61）**：**witness 计数为 0 时，先确认 witness 开关本身是开的，再谈"没 fire"** —— 否则会把仪器当成结论（与军规 52 同族：标签/开关没对上，读数是假的）。
## 4) 兑现率重算（把 ⑥ 的"剩余活站"改成有账可依）
- **同 build 内**的 rtcsv 对（rt2o2）：默认 **140.12** vs ON **133.05** ⇒ −7.07 ms —— **这个差不可跨 build 用**（rt2a5 的默认臂是 135.98，两 build 的默认臂差 +4 ms = 热/JIT），**只用 ON 臂跨 build 比 fold 前后：133.68 → 133.05 = −0.63 ms 串行** ✓（= 捡回 644 白工的量级，预测 0.73）。
- **帧价才是准绳**：`ab.ps1` 实测 **−1.251 ms/帧** ⇒ 除以 0.43 的图内系数 ⇒ **串行等效 ≈ −2.9 ms/帧**；
- **att 半区（641-645）的原价**（rt_per_closure，chain 48）= 0.0021 + 0.2922 + 0.4266 + 0.0021 + 0.2592 = **0.9822 ms/链** × 7 链 = **6.875 ms** ⇒ **兑现率 = 2.9 / 6.875 = 42%**（上一铲 2.3/6.875 = 33%）；
- **与 bench 的差**：bench CHAIN2 vs REF13 = 0.6676 ⇒ 省 33%（串行口径），引擎里省 42% ⇒ **两边口径不同**：bench 的 REF13 是**未融合的手工拆腿**，引擎默认路的 641/644 已被 qfuse 溶解、643 走 `wa_res`  resident 融合 ⇒ **引擎的拆腿基线本来就比 bench 便宜** ⇒ 所以"bench 单价 −0.509 ms/链"到了图内只剩 ≈0.42 ms/链（−2.9/7）。**这条差异已量化，不再是暗账。**
## 5) 下一铲排序（按已量化的余量）
 1. **8/8 覆盖**：第 8 条 C64 链 = `epi=0 narrow=0` ⇒ 要给 P11 加第二种 epilogue（改数值面）⇒ **收益 ≈ 1 链 = 0.42 ms 串行 ≈ 0.18 ms/帧**，**代价 = 重新过 25 检查点门 + 双档 1301 + SELFREP** ⇒ 性价比偏低，**除非顺带把 epi 形态做成参数化复用**；
 2. **同族推广**：C=128 tier（6 链）在 bench 上 **+51% 更差**、SLM 41,984 越 32KB 崖 ⇒ **不接**；C=256/C=512 的 att 半区**没做过合成体** ⇒ 若要接，先做 bench 合成（不进图）；
 3. **兑现率本身**：42% 说明图内还有 ~58% 的 att 半区开销没被这条融合吃掉（跨链调度、pool、PGRAPH wave 划分）⇒ **下一铲最值钱的一刀可能是"图内 per-closure 复核"**：现在两槽已是新件，**直接跑 `NR_RUN_TIMING=1` 的新件 + `rt_per_closure.csv` 对比**，把 641-645 的现值读成 0/近 0，并把剩下的 att 半区时间去 attributed 到具体 op（这是纯读数，不改代码）；
 4. **`gate_skip_graph` 守卫期望更新 + 重跑 40 门**（父的动作，我在旁边给读数）。

# §98-注 **编号说明**：§84 与 §86 **没有落盘**（§84 当时被 §85 的破案直接取代；§86 的脚本有一个引号语法错、当场放弃，内容改成了 §87 开头的现场记录）。**编号空洞是有意的，不要去找它们的内容**；所有实际读数都在 §87-§98 里。


# §99 **转正落地 + 守卫改成读单一出处 + 全量 40 门在转正件上 40 GREEN / 0 RED**　2026-11-04 07:4x-08:0x
**父的动作**（我不碰加载位）：`out\libxmx.dll` = `oneapi\libxmx_sycl.dll` = **`3BAECF2A4B0F49F45E2557CE4808C2CF`**（= `builds\libxmx_att5p.dll`）✓ 两槽一致（军规 59 ①）；回退点 `out\libxmx.before-ATT5.keep` = **`ABB969FE…`** ✓；提交 **`65b67eb`**（用了我的 `s6/pe_c1_commitmsg.md` 草稿）；出处 `out\SHIPPED_BUILD.md` §6 已核，并复制进仓 **`notes/SHIPPED_BUILD.md`** ✓。
**流程级修正（父做的，我记账）**：`gate_skip_graph.py` 的 `SHIP_MD5` **不再写死 ABB969FE**，改成**读 `out\SHIPPED_MD5.txt`**（内容 `3baecf2a…`），**文件缺失 = RED**（不许静默放行），**实质检查一字未改**，`py_compile` 过，入库 **`b564cb1`**。
**为什么这条值得立案**：§89 里我为了跑 40 门只能 stage 变体、然后看着身份守卫 RED —— **每次转正都会让这道门按设计 RED，把它的实质检查（1301 逐位、跨槽一致）淹在噪声里**；换成"读单一出处"之后，身份守卫第一次能同时表达"这是当前转正件"和"你没偷改 dll"。
**建议军规 62**：**任何"工件身份"类断言必须读单一出处文件（`out\SHIPPED_MD5.txt`），不许把 md5 常数写进门里；出处缺失必须 RED，不能默认放行。**
**A 读数**：`bash E:/DSH/run_gates.sh`（前置 300 s 冷却，不 stage 不复原）⇒ **`gates: 40 GREEN / 0 RED`** ✓ 跑完两槽 md5 复核仍是 `3BAECF2A…` ✓。


# §100 **剩余活站重排（新表 `tools/shapes_alive_next.csv`）：底料 = 在**转正件**上取的逐 op 清单**　2026-11-04 08:0x（纯 host + 一次 RUN_TIMING 取数）
## 取数（`NR_RUN_TIMING=1`，件 = `out\libxmx.dll` = `3BAECF2A…`，**不设其它 env**；`s6/RT_shipped.timing.txt` 691 行）
**逐 op 家族（串行 ms/帧，行数）**：`gemm_int8_residual 20.06(68)`、`window_block 18.19(10)`、`global_attention 11.48(8)`、`gemm_window_int8_residual 11.36(52)`、`window_attention 10.19(45)`、`gemm_int8_qkv 9.65(53)`、`gemm 7.03(42)`、`ffn 6.24(8)`、`int8_batched 4.86(72)`、`unary 2.96(16)`、`gemm_int8 2.72(24)`、**`quant 2.72(80)`**、`ffn_merge 3.55(1)`、`ffn_stem 1.72(1)`、`unary2 1.34(1)`、`quant(FUSED-pack) 0.38(144)`、`quant_window(FUSED-pack) 0.11(45)`、**`*(A5-fused) 合计 0.065(21)`** ⇒ **总计 114.63 ms**。
**att 半区按 tier（串行 ms/帧）**：**C256 13.39** > **C128 10.56** > **C64 5.46** > **C512 1.76**（+ 不在 chain 区间内的 2.75）。
**A5-fused 命中的链 = 0,1,2,48,49,50,51（7 条）** ⇒ **C64 tier 唯一没接的是 chain 3**（就是 §87 里 `epi=0 narrow=0 half=1` 那条）✓ 与 §98 的口径闭合。
## 候选排序（表在 `dlss-nr-on-a770\tools\shapes_alive_next.csv`，四列 = 活站价值(串行/帧) / 需要的机制 / 要不要跨链换序(军规 43)）
| # | 候选 | 串行 ms | 帧 ms | 换序 | 一句话 |
|---|---|---|---|---|---|
| 1 | **WB 驻留重做**（`window_block` 45,056→32,768 SLM） | 家族现值 **18.19** | 历史上限 −3.9 串行；**实测 −0.365/32 对** | 否 | **A5 之后最大的单一活家族**，方向有先例、有实测下界；前置 = `barrier_audit` 的 verdict_source/verdict_machine 两栏 + 军规 60 的 `NR_SELFREP` 臂 |
| 2 | **C1 quant 折进生产者 store** | 现值只剩 **2.72**（80 行） | ≈ −1.2 上限 | 否 | **A5 + qfuse 已经把大头吃掉了**（144 行溶解成 0.38 ms）⇒ 从 §50 的 2.6-9.5 ms 缩水到 2.72；v9b 那套 fold 曾被测出更慢（宽 N 要宽 BM，64KB SLM 装不下）⇒ **先按军规 54 在合成体里重新定价，再谈实现** |
| 3 | **A5 8/8：chain 3 的第二种 epilogue** | 该链 att 半区 0.98 | **≈ −0.22** | 否 | 要给 P11 加 epi=0 的出口形态 + 配套 skip 读 ⇒ **动数值面**（store map / skip 读），要重过 25 检查点门 + 双档 1301 + SELFREP；**性价比全表最低**，除非别的原因要顺手重构 P11 |
| 4 | **C256 / C512 的 att 腿**（16 + 16 链） | **13.39 / 1.76** | 不给预测 | 否 | 表上最大的两块，但 **C128 已经实验过：att 合一 +51% 更差、SLM 41,984 越 32KB 崖** ⇒ 判定 = **先做 bench 合成体、在该 tier 上打赢拆腿 REF 才允许进图**；三项约束 = heads==2 / tokens==64 / SLM 上限。**不顺手写预测收益** |
| 5 | **跨链合并类（刀 1 / 刀 3）** | n/a | n/a | **是（军规 43）** | 需要 record/plan 层换序；最小机制清单：(a) recorder 能读的邻接/依赖标注，(b) capture 期合法性检查（宁可 refuse 不许猜），(c) 逐链 pool_get/pool_pull 块序列 witness，(d) 编译期回退开关（T_*_DEF）而不只是运行期。**刀 1 已死过一次 ⇒ 排最后** |
| — | `gemm_int8_residual 20.06` / `global_attention 11.48` | 20.06 / 11.48 | n/a | n/a | 不是 att 半区站点；S6 已把 FFN 残元能吃的吃了。**列出来是为了表的完整性，不是候选** |
## 我建议的下一刀（等你点）
**= 候选 1（WB 驻留重做）**，理由：(i) 18.19 ms 串行 / 只有 10 个 closure ⇒ **单位 closure 价值最高**（1.8 ms/发）；(ii) 有历史实测下界 −0.365 ms/32 对，不是空想；(iii) 不跨链换序 ⇒ 不碰军规 43 的雷区；(iv) 它的前置（barrier_audit 两栏 + SELFREP 臂）**已经在手里**（`nr_replay_sr` 就是现成仪器）。
**开工顺序**：先纯 host 做 SLM 预算表（45,056 → 32,768 差 12,288 B 从哪来：tile 形状 / 双缓冲 / stage 复用），再改 bench 件量一版 occupancy，最后才进 `builds\` 出变体并走双档 1301 + SELFREP + 16 对。
**若你要更稳的**：候选 2 的**重新定价**是纯 host（用 `RT_shipped.timing.txt` + 合成体 bench），零 GPU 也能交一铲。


# §101 **候选 4（C256 / C512 att 腿）的三项约束判定 —— 备查，本铲不做**　2026-11-04 08:1x（纯 host）
**判定 = 现在不能把 att5 形态套上去；三条约束里两条直接不合格。**
1. **heads / tokens**：`att5::fused<C,HEADS,PHASES,…>` 的几何锁是 **heads=2、tokens=64、C=64**（`s6b_att.cpp` 里 `Shape` 有 `static_assert` 把模板参数与 M 档绑死）。转正件里 10 个 `xmx_rec_window_block` 的自带几何是 **C=32 / heads=1 / tokens=64**（`libxmx_sycl.cpp:5410`）⇒ **与 att5 的 C=64/heads=2 不是同一族**；而 C256/C512 的 att 腿（`xmx_rec_gemm_int8_qkv` + `xmx_rec_window_attention`）在 chain_map 里是 **C=256: heads=? / C=512: heads=?**（tier 列已给 M 与 C），**要套 att5 必须先证明 heads/tokens 与 fragment 布局一致**，否则 P8 的 fragment 面越界。
2. **SLM**：att5 核在 C=64 已经是 **32,768 B**（`att5::fused` 台账 slm=32768，2 个驻留 WG/SM）；**C128 实测 41,984 B ⇒ 越 32KB 崖**，且 bench 上 C128 的 att 合一形态 **+51% 更差**（§66/§67 的档价）⇒ **C256/C512 只会更大**（fragment 面与 KV tile 随 C 线性/超线性涨）⇒ **不进图**。
3. **数值面**：att5 的 P11 只实现 **epi=1 + narrow + half_skip** 一种出口；C256/C512 的残元腿 flags 分布未测（要按 §87 的 `[a5-geom]`/`wres-TUPLE` 普查一遍才知道有几条能对上）⇒ **在拿到普查之前不许写预测收益**（父的要求）。
**结论写法（进表）**：`C256 13.39 ms / C512 1.76 ms 串行 = 表上最大的两块活站，但 att5 形态在此二 tier 的三项约束里 SLM 一项已被 C128 实验证否、heads/tokens 需重新证明 ⇒ 判定 = 先做该 tier 的 bench 合成体并打赢拆腿 REF，才允许讨论进图；本铲不做，不给预测帧值。`
**顺手可做的零风险前置（若以后要点刀）**：把 C256/C512 的 `wres-TUPLE` 普查跑一遍（`[a5-geom]` 已有 104 行数据 ⇒ **纯 host 就能列出这两个 tier 的 epi/narrow/half 分布**）⇒ 这样"能不能对上出口形态"先有数，再谈 SLM。


# §102 **WB 驻留重做 (a)：SLM 预算表已出（`E:\DSH\tools\wb_slm_budget.csv`）+ 三条硬前置的 verdict**　2026-11-04 08:1x-08:2x（纯 host，零 GPU）
**先说对象的身份（免得打错靶）**：`xmx_rec_window_block` 在 plan 里 **20 步 = 2 次录制 × 10**；按 flags 分路（`s6/pe_wb_census.py`，flags 解码 @5391-5409：pooling=0x800000、head=0x1000000、narrow=0x1000、epi=(f>>8)&0xF）：
 - **v4ph(pool) 1 条**（8160 窗、544x960、across120）+ **v4ph(head) 1 条**（8349 窗、across121、pad262148）⇒ **只有这 2 条走 `wbv4ph::launch_v4ph`（SLM 45,056）**；
 - 其余 **8 条 = non-pool/head**（2040-2135 窗、272x480）⇒ 走另一条路（**不是 45,056 那个核**）。
**逐 closure 实测（转正件 `3BAECF2A…`，`NR_RUN_TIMING`，`s6/RT_shipped.timing.txt`）**：`c1 = 4.243 ms`、`c690 = 4.278 ms` ⇒ **两条 v4ph 巨人 = 8.52 ms**，占 `window_block` 家族 18.19 ms 的 **47%**；另 8 条各 1.16-1.28 ms。
⇒ **这一铲的靶 = 那 2 条巨人 closure（8.52 ms 串行 / 帧）**，不是整个 18.19 ms 家族。

## 前置 1：`barrier_audit.py` 两栏（`tools/barrier_audit.py --emit-csv E:\DSH\tools\barrier_audit_wb.csv`，38 行，退出码 0 = **反证两例通过、仪器有牙** ✓）
| 核 | WG/SG 栅栏 | **verdict_source** | **verdict_machine** |
|---|---|---|---|
| `wbv4ph::launch_v4ph`（window_block_v4ph.hpp） | **WG=1 / SG=16** | **OK** ✓ | **PARTIAL**（2026-11-02 的旧账：`.text` 里 18 条 signal barrier，**没做逐字节对照**）|
| `wbv4::launch_v4full`（window_block_v4.hpp） | WG=1 / SG=13 | OK ✓ | PARTIAL（15 条，同上）|
⇒ **诚实结论：source 栏干净、machine 栏只是 PARTIAL ⇒ 这一栏没清账。** 处置：**(b) 出 occupancy 台账时按军规 34 补做机器级**（改完源码后重跑 audit + 台账列含 simd/module_id 去重 + 对新旧 `.text` 做 barrier 计数与逐字节对照）；**在 machine 栏补清之前不出 `builds\` 变体**（父的前置）。
**关键结构事实（决定后面所有动作）**：v4ph **只有一个 WG 栅栏**（line 202，注释写明 "KTO/VPO shared for P3/P5"），其余 16 条全是 SG 级 `esimd::barrier()` ⇒ **跨 SG 的交接只有 KTO/VPO 两处，都被这唯一一条 WG 栅栏盖住**。

## 前置 2：别名手术只用**拆槽/挪相**，**加 barrier 的方案一律标 `不采纳`**
表里已按此写：**KTO 与 VPO 的槽被显式标 `KEEP + 拒绝在 P6/P7 复用`**，理由写死：现有那条 WG 栅栏在 P3 读**之前**，若把这两个槽挪给 P6 用，就**必须新增一条 WG 栅栏** ⇒ **直接 `不采纳`** ✓（这正是 §40/§41 当年 RACE_REUSE 的形态）。

## 前置 3：军规 30 逐段（谁写、谁读、何时读、槽是否重叠）—— 见 CSV 的 `writers/readers/overlap_now` 三列
**12,288 B 的差额由两段凑齐（且两段互相独立）**：
1. **−4,096：`AQO` 让位给 `ATO`**（P0-P2 之后 AQO 死；ATO 只在 P6 活；**两边都是 SG-local**（写读都在 `+sgid*1024` 自己的片）⇒ **不需要任何新栅栏** ✓）
2. **−8,192：`SCR` 的 per-SG 高水位 4,096 → 2,048**（把 **P3 scores / P4 softmax / P5 attnV 拆成两个 8 行半块**：现在每 SG 的 scores 块 = 16 行 x 64 列 x 4 B = 4,096；拆半 = 2,048 ⇒ 4 SG 共省 8,192。**SCR 的每一次使用都是 `+ sgid*SCR_SG` ⇒ 全程 SG-local ⇒ 拆槽不引入任何跨 SG 语义** ✓）
⇒ **45,056 − 12,288 = 32,768** ✓ 数值上正好闭合。
**但有一处必须先量再赌**：第 2 段把热相（P3/P4/P5）的循环次数翻倍、dpas 累加器从 `simd<float,64> x4` 变成两半的 `simd<float,32> x4` ⇒ **v9b 的教训（每线程累加器进 >8 的惩罚区）说这有可能把驻留收益吃掉** ⇒ **(b) 必须成对计价（军规 54/55）：现档 45,056 / 新档 32,768 / 新档+拆槽变体，三态同形态对同一 shape 出价**。
**停止条件（照父的规矩写死）**：**若只做第 1 段 = 40,960，够不到 32,768 ⇒ 停下回报，不算部分出货**；若第 2 段在 (b) 里价格变差 ⇒ 同样停下。
**另两条要记的账**：
 - **靶子只有 2 个 closure / 帧（8.52 ms 串行）** ⇒ 历史"上限 −3.9 ms 串行"对应这两条；**而历史实测只有 −0.365 ms/32 对** ⇒ **兑现率 ≈ 9%** ⇒ 说明驻留/occupancy 之外还有更强的限制（很可能是 D2H/全局带宽或 wave 划分）⇒ **(b) 之前我不承诺帧值**；
 - **8 条 non-pool/head 走的是另一条路**（不是 45,056 的核）⇒ 本铲不动它们；若 (b) 显示 32,768 的收益主要来自 occupancy，那 8 条的 shape 也值得单独看一眼（**但那是下一铲，不在本铲范围**）。


# §103 **(b1) 机器级对照 = PASS：barrier 条数 18 → 18 一字不差、台账干净、SLM 45,056→40,960 到手；但 state-2 只到 40,960 ⇒ 按判决线 3 = 停下回报（state-3 半块拆分未做）**　2026-11-04 08:2x-08:4x（纯 CPU + 两次 20 s 的 JIT 触发，零测量）
## 仪器怎么搭的（前一次机器级只是"数了 barrier 没逐字节"，这次补全）
1. `s6/pe_mk_wbslm.py` 从 **shipped 头文件逐字复制** 出 `src/bench/sycl/wb_v4ph_slm.hpp`：只改三处（namespace `wbv4ph`→`wbv4phS`、region 常量按 `WBS_STATE` 选表、`esimd::slm_init<WBS_SLM>()`）⇒ **文本 diff 只有这几行**（`s6/pe_wbs_srcdiff.py` 打印），**barrier 调用点 17 = 17**；
2. `src/bench/sycl/wb_slm_stub.cpp` = 只实例化核的 codegen stub（`stop_stage=0xFFFF` ⇒ 核第一行就 return，指针全是假值 ⇒ **不执行任何访存**），跑一次只为把设备码写进 `sycl-cache-portE`（两次 20 s，不是测量）；
3. `s6/pe_wbs_text.py`：从 JIT 缓存的 `0.bin` 里按 ELF 段表切出 **本核的 `.text`** 直接逐字节比；
4. `s6/spillcheck_wb.py`（`spillcheck_port.py` 的 label 放宽版，`s6/pe_wbs_ledger.py` 驱动）：拿到 **ocloc 反汇编出的 `.text.…launch_v4ph….asm`** ⇒ **数 `signal barrier`** ✓ 这就是缺失的那件仪器。
## 读数（两态成对）
| state | grf | simd | **slm(B)** | spill | private | scratch | asm 行数 | **signal barrier** |
|---|---|---|---|---|---|---|---|---|
| **1 = 现档（shipped 布局）** | 128 | 1 | **45,056** | - | - | - | 3,485 | **18** |
| **2 = 仅 `AQO→ATO` 别名** | 128 | 1 | **40,960** ✓ | - | - | - | 3,487（**+2 行**）| **18** ✓✓ |
**ELF 段级对照**（`pe_wbs_text.py`）：18 段里 **14 段逐字节相同**；只有本核 `.text`（46,400→46,592，**+192 B**）、`.symtab`、`.spv`（369,200→369,076，−124 B）、`.ze_info` 变 ⇒ **不是"整核重写"**；`.text` 差异 = **5,911 段、最长 87 B、中位 3 B** ⇒ 正是 SLM 立即数重编码的形状 ✓
**判决线 1 的硬要求（barrier 条数不许变）满足：18 → 18** ⇒ **没有新增栅栏**（前置 2 在机器级也成立）✓
**军规 30 / 仪器互证**：`barrier_audit.py` 在**改后源码**上（`BARRIER_SRC=E:\DSH\tmp\wb_slm_shadow`，把副本按原名放进去）⇒ **所有区段 verdict_source = OK，WG=1/SG=16 不变** ✓；而它自己的反证用例正是 **"故意 ATO→S3 ⇒ RACE_REUSE（KTO 跨 SG 读到 P3，更晚 ATO 在 P6A 写同一区域，之间没有 WG 栅栏）"** ⇒ **我在 §102 里拒绝复用 KTO/VPO 槽的判断，与仪器的反证形态完全同一** ⇒ 这次是"仪器先说危险、我没去碰"，不是"事后找理由" ✓
## 现在的状态与停止点
- **(b1) 通过**（source + machine 两栏都有实测，不再是 2026-11-02 的 PARTIAL）；
- **但 state-2 只到 40,960**，**state-3（SCR 每 SG 4,096→2,048 的半块拆分）还没实现** ⇒ 按**判决线 3**：`只到 40,960 而 32,768 不可达 ⇒ 停下回报，不算部分出货` ⇒ **我在此停，不进 (b2) 计价**（40,960 这一档单独进图没有意义：occupancy 从 45,056→40,960 仍 >32,768，**驻留数不会从 1 变 2**，判决线 4 注定不满足）。
**(b2) 要不要跑，等你一句话**：可跑的两条腿 = (i) 先实现 state-3（P3/P4/P5 拆 8 行半块，**这才是那 8,192 B 的来源**，也是我标了 medium-high 风险的那段：dpas 累加器从 `simd<float,64>×4` 变两半 `×4`，v9b 惩罚区）；(ii) 或者先只做 **40,960 的 per-launch 计价**（现档 vs 别名档）来**回答你 ⑥ 想要的"当年为什么只兑现 9%"**——这一条不需要 state-3，只要把探针 `wb_ga_probe.cpp` 改成调 `wbv4phS::launch_v4ph`（已有副本，两行文本改动）就能成对出价。
**我的建议**：先做 (ii)（便宜、且它给的是**下一刀的定价依据**，判死也算赚），再做 state-3 的实现与三态对照。
**GPU**：本铲只用了 **~40 s**（两次 stub JIT 触发，零测量）；进程 0；两槽仍 `3BAECF2A…` ✓、三金标未动 ✓、`out\SHIPPED_MD5.txt` 未动 ✓；未 commit；新产物 `wb_v4ph_slm.hpp`、`wb_slm_stub.cpp`、`s6/pe_mk_wbslm.py`、`s6/pe_wbs_srcdiff.py`、`s6/pe_wbs_text.py`、`s6/pe_wbs_ledger.py`、`s6/spillcheck_wb.py`、`tools/barrier_audit_wb_slm.csv`、`tools/wb_slm_budget.csv`。
