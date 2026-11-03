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
