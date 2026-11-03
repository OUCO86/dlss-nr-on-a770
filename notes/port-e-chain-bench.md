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

