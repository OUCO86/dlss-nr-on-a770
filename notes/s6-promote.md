# S6-1a 转正（promote）— 2026-11-01 12:3x–12:5x +08:00

用户令：翻默认 ON → 重验三关（默认路径 = 融合路）→ 部署到游戏加载位 → RUN_TIMING 对照。
完整逐步读数在 `E:/DSH/s6/promote.md`（工作区账本，含失败现场）。本文件 = 仓内摘要 + 代码引用的靶子。

## 改动（本体只有一行）
- `src/bench/sycl/libxmx_sycl.cpp` **`:559`**：`NR_S6_FFN` 默认 `false` → **`true`**
  （`unset` ⇒ 融合；`NR_S6_FFN=0` 或任何 `atoi()==0` ⇒ 逃生门 = 完全走 pre-S6 现路，`s6_on()` 假
  ⇒ `:575/:592/:617/:653` 四个消费点全死 ⇒ OFF 侧就是旧代码逐字）
- `src/bench/sycl/libxmx_sycl.cpp` **`:522-534`**：开关注释块重写。理由只引出货 in-process 帧 A/B：
  **48 对 mean −2.950 ms/帧、融合侧 48/48 赢、95% CI [−3.190, −2.710]**（三枪 16 对 = −2.683/−3.032/−3.134）
  = `notes/s6-stage3.md` 步骤 4；并明写**不许**拿 off-path 账（bench wall / RUN_TIMING 串行合计）当出货价。
- `src/bench/sycl/libxmx_sycl.cpp` **`:683`**：`NR_S6_TRACE` **保持 presence-gated = 默认关**（record-time host witness，未改）。
- `src/bench/sycl/s6_ffn_block_kernel.hpp` **`:11-14`**：头部注释同步（原写 "default OFF" 过期）；**核体一字未动**。
- 新件编译 md5：**`E2D5E5740035BE47321D55A1C7385C8D`**（3,772,928 B；`def: 91 exports`，1054 warnings / 0 error）。

## 重验四关（全部在默认路径上，即"不靠 env"）
| 关 | 命令 | 读数 |
|---|---|---|
| 门（默认 = 融合） | `SUFFIX=_promoteon bash E:/DSH/run_gates.sh` | **39 GREEN / 0 RED**（`logs/gates_promote_on.log`） |
| 门（逃生门） | `SUFFIX=_promoteoff GATE_ENV='NR_S6_FFN=0' bash E:/DSH/run_gates.sh` | **39 GREEN / 0 RED**（`logs/gates_promote_off.log`） |
| walk | `walk.ps1 -Dll out/libxmx_new.dll -Tag s6prom` | **1301 EXACT = 249A46F374E98EB5FF5AD5E3A38EBC55**（= `dumps/bk.1301.bin`，8,355,840 B）、**691 closures**、run1..3 = 67.42 / 67.48 / 67.87 ms |
| 确定性两遍 | 同上 `-Tag s6prom_b`（独立进程） | md5 两遍相同且 = 金标；run1..3 = 66.93 / 68.31 / 68.37 ms ⇒ **100%** |
| 16 对确认 | `ab.ps1 -DllA out/libxmx.dll -DllB out/libxmx_new.dll -Pairs 16`（**两侧不设 env**） | A=71.364 / B=68.344；**mean −3.020**、median −3.000、sd 0.843、SE 0.211、**16/16 赢**、CI **[−3.433, −2.607]**（t15 → [−3.469, −2.571]）⇒ 判定 **转正** |

16 对逐对 delta：
```
-3.610 -3.530 -2.180 -2.640 -1.490 -4.490 -3.740 -2.790 -3.200 -2.680 -3.060 -2.500 -1.630 -3.650 -4.190 -2.940
```
合并口径：48 对（stage3，−2.950）+ 16 对（本次，−3.020）= **64 对，64/64 融合侧快**，同向同量级。
门侧诚实标注沿用 stage3：门脚本的 op 流不构成 6 发邻接链 ⇒ 门绿只证明"没弄坏现路"，融合腿由 1301 判。

## 部署（只在 DSH 内；游戏目录一字未动）
```
out\libxmx.dll          E2D5E5740035BE47321D55A1C7385C8D   新（默认 ON）  <- 游戏加载位（OptiScaler Folder=E:\DSH\out）
out\libxmx_new.dll      E2D5E5740035BE47321D55A1C7385C8D   同一件
oneapi\libxmx_sycl.dll  E2D5E5740035BE47321D55A1C7385C8D   门/walk 加载的那份
out\libxmx_B8908BD2.dll.keep  B8908BD20DEC482AAE7C9887F9273C58  旧件留档（pre-S6 出货基线）
out\libxmx_b8908bd2.dll.bak   B8908BD20DEC482AAE7C9887F9273C58  10-31 既有，未动
backup\pre-port-2026-11-01\dll\{libxmx.dll=B8908BD2…, libxmx_new.dll=B2AB4A19…}   未动（md5+mtime 核过）
```
台账 `E:/DSH/out/DEPLOY.md5.txt`。**回滚 = 一条 copy**：`out\libxmx_B8908BD2.dll.keep -> out\libxmx.dll`，
或游戏侧设 `NR_S6_FFN=0` 走逃生门（两条路都验过 39 门 / 1301）。

## RUN_TIMING 对照（转正后稳态，件 = 部署后的 out\libxmx.dll）
表存 `E:/DSH/census/run_timing_after_promote.txt`（两遍取第二遍；另加一腿同 session 逃生门对照）。
三行新价（同 session，ON 末遍 vs OFF 末遍）：**batched 21.4 → 7.5（−13.9）**、
**residual 19.9 → 24.5（+4.6，融合核挂在 residual 闭包里替整条 6 发链付钱）**、**quant 13.7 → 4.8（−8.9）**；
三行合计 55.0 → 36.8（**−18.2**）；串行合计 run1..3 中位 **174.42 → 155.22（−19.20）**。
⇒ 融合签名在位（batched ~7.5、quant ~4.8）证明默认真的走融合路，`NR_S6_TRACE` 保持关。
⚠ 这张表是**机制账**（plain 闭包循环，在 cgraph 之前 return），且本 session 整体比 stage3 慢 ~8%
（run#0 337/358/367 vs 267 ms）⇒ **不跨 session 比绝对值**，帧价只认 in-process A/B。
引擎这张表实际打印 **17 行**（15 个 op 行 + 2 个 `quant(FUSED-pack)` 记账行），已原样存盘。

## 纪律
只写 `E:\DSH\`；`E:\WorkBuddy` 只读（工具链/头/库）；**C 盘未写**（machine/user 无 `SYCL_*`，
`AppData\{Local,Roaming}\Intel` 近 1 小时无新写入，已查）；游戏目录未动；`backup\pre-port-2026-11-01\` 未动；
GPU 跑前跑后体检无 bench/nr_replay 残留（唯一的 `python` = Strata 模型服务，HIP/AMD 侧，不占 Arc）。
**未 commit、未 push**（`git status`：`M libxmx_sycl.cpp`、`M s6_ffn_block_kernel.hpp`、新文件 `notes/s6-promote.md`）。

## 顺带发现的工具坑（未改脚本）
`walk.ps1` 的 `param([int]$Runs=4)`（`:10`）与 `:25/:29` 的 `$runs` 在 PowerShell 里大小写不敏感 =
同一变量 ⇒ 赋值被 `[int]` 类型约束挡掉，控制台那行 `runs  : ` 只会打 `4` 并吐
`Cannot convert the "System.Object[]" … to type "System.Int32"`。**只影响显示**：`run N: … (691 passes)`
在原始日志完好，1301 / passes 判定不经过该变量。修法（待用户拍）：`:25/:29` 改名 `$runLines`。
同类坑已在 `ab.ps1` v2 修过（`$b` 覆写参数）。另：本机没有 PS7 `pwsh.exe`，`.ps1` 一律用
Windows PowerShell 5.1 的 `powershell.exe` 跑，脚本必须 **UTF-8 带 BOM**（否则 GBK 解码炸字符串）。
