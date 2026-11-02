# s6/wbint8.md — WB int8 试点铲（2026-11-02）：第 1 步净价 bench 交回

## 0. 现场与规矩核对
- 分支 **`ds-quality-relax-2026-11-02` @ tip `c3e3572`**（`git branch --show-current` 已确认），工作区 = `E:\DSH\dlss-nr-on-a770`，开工时 `git status` 干净。
- 只读核对（15:20 交回时再验，**一字未变**）：`out\libxmx.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0**；`dumps\bk.1301.bin` = `bk.1301.skip.bin` = **DD49827DD33A7EF07C2C17892F18970D**；`bk.1301.pre-skip-1a.bin` = **249A46F374E98EB5FF5AD5E3A38EBC55**。`builds\` 无本铲新件。
- `git status --porcelain` 只有一条：`?? src/bench/sycl/wb_int8_probe.cpp`（新探针，untracked）。**未 commit、未 push、未动加载位、未写 E:\WorkBuddy、未写 C 盘。**
- **LOP = Lies of P 的游戏进程**（`F:\Game\Lies of P\...\LOP-Win64-Shipping.exe`；判据照 `notes/promote-skip-c512.md:10` + `playtest.ps1:38`）。第一版脚本把系统服务 `GameInput*` 误当游戏报假 BUSY ⇒ 已修成 `^LOP|nr_replay|^wb_int8_probe$|^bench_`。**全程 34 个独立进程，每次跑前查闸，跑完无残留。**
- 读了：`notes/DS-takeover-2026-11-01.md` §37/§45/§46/§44+军规 34；`notes/wbga-diagnosis.md` §2c/§3/§4/§5；`tools/xmx_f16_roof.csv`；`s6/wb_ga_ops.csv`、`s6/wb_ga_tops.csv`。

## 1. 仪器（新件，untracked，不 commit）
| 件 | 用途 |
|---|---|
| `src/bench/sycl/wb_int8_probe.cpp` | 三笔净价探针；harness 照 `wb_ga_probe.cpp`（GPU event、min-of-15×5、5 组 60ms、**nosink**、形状走运行期 env） |
| `s6/cc_wbint8.sh` | 编到 `E:\DSH\oneapi\wb_int8_probe.exe`；**独立 JIT 缓存 `E:\DSH\sycl-cache-wbint8`**（军规 29） |
| `s6/run_wbint8.ps1` | 每 (sec,M,epi) **一个独立进程**（军规 16）；ASCII-only（**军规 16 的 BOM 教训本轮再踩**：含中文注释的 .ps1 被按 GBK 解析 → 语法错） |
| `s6/wbint8_ledger.py`、`s6/spillcheck_wbint8.py` | 台账（key 含 simd+module） |
| `s6/wbint8_final.py` → `s6/wbint8_netprice.csv` | 净价终表（多次独立重复的中位 × 两种定价模型） |
| `s6/wbint8_mkcsv.py` → `wbint8_legs.csv`；`wbint8_epi.py`；`wbint8_roof_ext.csv` | 逐腿原始值 / epi 敏感性 / 屋顶新行 |

形状 = plan 实参：**M=130560（2040w plain）与 M=522240（8160w POOL）**；四腿 **QKV N96K32 / scores N64K32 / attnV N32K64 / proj N32K32**。
**int8 引擎约束（实测确认）**：`s8v8::gemm_b/gemm_b_pub` 要 **N%64==0** ⇒ **N=96 与 N=32 只能走 BN32 的 `gemm32_b`/`gemm32_b_pub`**（M 补 128、K%32==0；130560/522240 已是 128 倍数）。

## 2. 第 1 笔：f16 腿现值（复现屋顶表 + 对 dll 分相）
dll 侧（`wbga-diagnosis.md` §3，8160w POOL 的 stop 阶梯）：**QKV 1.4429 | scores 0.9370 | probs(softmax) 0.2047 | attnV 0.6739 | proj 0.3872 | 出口 tail 0.3979**（四腿 = 3.4410 = 该发 85.1%；六格和 4.0437 与探针 FULL 4.0399 咬合 ✓）。
探针 f16（`f16v1::gemm_b`，msM，独立重复中位）：
| 腿 | M=130560 | 屋顶表(同 N/K) | M=522240 | TOPS(522240) |
|---|---|---|---|---|
| QKV N96K32 | 0.2928 | 0.2922 ✓（0.2%） | **0.9490** | 3.38 |
| scores N64K32 | 0.2193 | 0.2199 ✓ | 0.6446 | 3.32 |
| attnV N32K64 | 0.1481 | 0.1471 ✓ | 0.3747 | 5.71 |
| proj N32K32 | 0.1453 | 0.1452 ✓ | 0.3826 | 2.80 |
⇒ **宽 M 红利（屋顶表没记的一层）**：同 N/K 从 M=130560→522240，f16 TOPS **x1.23**（2.74→3.38）⇒ **拿 M=130560 的屋顶去裁 POOL/HEAD 两发 = 低估 f16 屋顶 23%**（§5 的"QKV 占屋顶 81%"在 522240 上是 **64%**）。
⇒ **dll 每相里非 dpas 的 elementwise = 32%**（四腿 3.4410 vs 探针纯 dpas 2.3444）——**dtype 砍不到这块，这才是这铲真正的天花板**。

## 3. 第 2 笔：int8 腿同形状（先预测、再实测）
| 腿 | 预测(M=130560) | 实测 | 偏差 | 实测 int8/f16 |
|---|---|---|---|---|
| QKV N96K32 | 0.180（内插 4.48 TOPS） | **0.1752** | −2.7% ✓ | **1.67x** |
| scores N64K32 | 0.1371（表 3.901） | 0.1375 | +0.3% ✓ | 1.60x |
| attnV N32K64 | 0.0725（借 N64K64 锚 7.376） | **0.1099** | **−34% ⇒ 超 25%，要说明** | **1.35x** |
| proj N32K32 | 表无行 | 0.0997 | — | 1.46x |
**为什么 attnV 差 34%**：屋顶表的 int8 行**只有 N64/N128/N192/N384，没有 N32/N96**；int8 在 **N=32（BN32 几何）屋顶塌得比 f16 快**：N32K64 int8 = 4.87 TOPS vs N64K64 锚 7.38（−34%），同形 f16 只 −24%。
⇒ **军规 26 补条：int8 屋顶不得按 f16 的 N 比例内插；N<64 必须实测。** 40 行新点（含宽 M 红利行）已落 `s6/wbint8_roof_ext.csv`。

## 4. 第 3 笔：换精度的三笔代价
**(a) 激活面量化腿 —— 按折叠形态计价**（`packdev::pack_a_fused_gather` = 仓内 P4b 既有形态：一次读 f16 图面 + 行峰 + `fdiv_rn` + scatter 进 BM128/BK32 int8 tile；对照同 gather 的 f16 侧 `gather_pack_a16`）。**3 次独立进程中位的增量**：
| A 面 | POOL 发 | plain 发 |
|---|---|---|
| K=32（QKV/scores/proj 的 A） | **+0.0785** | **+0.0273** |
| K=64（attnV 的 A=probs） | **+0.0014（免费）** | +0.0087 |
⇒ 量化 ALU 本身不贵（写侧还省一半字节）。**独立趟形态（`pack_a_fused` − `pack_a` = +0.25 ms）是仪器价，不算数**（任务书第 3 步④的警告）。
**(b) int8 权重预整定（init 一次，不进帧）**：`cached_pack_b_f16` → `cached_pack_b_i8`（仓内已有，key=(bufid,N,K)，pack 一次复用）。字节 **减半**：QKV 6144→3072 / scores 4096→2048 / attnV 4096→2048 / proj 2048→1024B（十发合计 16,384→8,192B）。init 的 device pack 价 **f16 0.0198 vs int8 0.0196 ms（同价）** ⇒ **不进帧、不改帧价**；它改的是 **B 供数的网格 = 数值契约**。
**(c) epilogue requant（折进 store）**：两侧都取"出口带 publish"的对称形态（f16 = `f16v1::gemm_b_pub_f16`；int8 = `s8v8::gemm_b_pub`/`gemm32_b_pub`：acc×as×bs → pub → f16 面）。**链上真实出口 = epi1（e4m3 snap）**：`window_block_v4.hpp:163/171` 就是 `convert<half>(e4m3_vec<32>(qv))`；epi4（half-round）只当对照。
| 腿（M=522240，epi1） | f16 raw→pub | int8 raw→pub | **int8 比 f16 多付** |
|---|---|---|---|
| QKV（BN32） | 0.9496→1.1791 = +0.229 | 0.5618→0.8580 = +0.296 | **+0.067** |
| scores（BN64） | 0.6446→0.8017 = +0.157 | 0.3895→0.5778 = +0.188 | +0.031 |
| attnV（BN32） | 0.3747→0.4565 = +0.082 | 0.2739→0.3595 = +0.086 | +0.004 |
| proj（BN32） | 0.3826→0.4403 = +0.058 | 0.2411→0.3361 = +0.095 | +0.037 |
⇒ **requant 的净增量不是主犯**（+0.004…+0.067 ms/发）。
（对照实验：把 N=96 补到 128 走 BN64 ⇒ 每列只便宜 4-9%，但要**多写 33% 的出口列** ⇒ 不划算。）

## 5. ★ 净价终表（十发外推；**epi1 = 10 次独立进程配对 / epi4 = 3 次**；两种模型都交回）
外推：家族行数 2,125,248 = POOL 522240 + HEAD 534336 + 8 发 plain 1,068,672；两形每行价几乎相同（2.763e-6 vs 2.766e-6 ms/行）⇒ **POOL 每行价 x4.0697**。
- **M1（乐观）**：int8 = dll 相 × 行数加权 `r_pub` + A 量化求和
- **M2（保守、贴结构）**：int8 = dll 相 + `(i8_pub − f16_pub)` 求和 + A 量化求和 ⇒ **相内其余 elementwise 记为不变**
| 腿 | N×K | epi1 `r_pub` | **M1 净Δ** | **M2 净Δ** | 十发 f16 | M1 | M2 |
|---|---|---|---|---|---|---|---|
| **QKV（试点靶）** | 96×32 | 0.751 | **−18.3%** | **−15.6%** | 5.872 | 4.795 | 4.955 |
| scores | 64×32 | 0.735 | −16.5% | −15.7% | 3.813 | 3.184 | 3.215 |
| attnV | 32×64 | 0.792 | −18.1% | −14.9% | 2.742 | 2.247 | 2.333 |
| proj | 32×32 | 0.761 | **+0.4%** | −10.3% | 1.576 | 1.582 | 1.413 |
| **四腿合计** | | | **−15.7%** | **−14.9%** | **14.003** | **11.808** | **11.916** |
（**epi4 对照**：QKV −16.0%/−12.7%；scores −14.8%/−13.4%；attnV −16.6%/−13.4%；proj +1.8%/−7.6%；四腿 −13.8%/−12.5%。）
★ **判定量的不确定度（`s6/wbint8_ci.py`，10 次独立进程、同一次运行内配对）**：
**QKV 一腿十发净Δ（M2/epi1）= 中位 −15.5%，5-95 分位 [−16.7%, −14.4%]，min −16.9% / max −13.6%；配对样本过 15% 线的比例 = 90%。**
⇒ **中心值就压在判定线上，置信带跨线**（不是"稳稳过线"，也不是"稳稳不过线"）。
**肉的去向（四腿/十发/epi1+M2）**：dpas 纸面肉 **−5.06 ms**（§37 的 −5.86 兑现 **87%**）→ **A 面量化吃回 +0.87**、**requant 净增量吃回 +0.30** ⇒ 净 **−2.09 ms 串行 = −0.90 ms/帧**。
⇒ **§37 的"帧 ≈ −2.5"只有 ~36-40% 落地：四腿全换 = −0.90…−0.94 ms/帧；QKV 一腿单独 = −0.39…−0.46 ms/帧。**
⚠ **proj 腿的 M1（+0.4%）与 M2（−10.3%）分叉最大，原因已查清**：探针的 f16_pub（0.4403）**比 dll 的整个 proj 相（0.3872）还贵** ⇒ 对细腿（proj/attnV）**探针的"全局 f16 publish"不是 shipped 的 SLM 出口的代理**，M1 的比值在这些腿上不可信；**QKV 腿最可信**（探针 f16_pub = dll 相的 82%）。

## 6. 判定：**QKV 净价 = 踩在线上，不在线上之上有把握**
★ **10 次独立进程、同一运行内配对**的不确定度（`s6/wbint8_ci.py`，M2 保守口径、epi1）：
**QKV 一腿十发净Δ 中位 −15.5%，5-95 分位 [−16.7%, −14.4%]，min −16.9% / max −13.6%；配对样本过 15% 线的比例 = 90%。**
⇒ 按写死的线（≥15%）**判定 = 勉强 GO**，但**中心值就是线本身**（−15.5% vs 线 15.0%），置信带**跨线**。乐观口径（M1）才给到 −18.3%。
- **过线只在 epi1（链上真实出口）口径成立**；换 epi4 ⇒ QKV 保守净价 **12.7% ⇒ 不过线**。
- **第一轮单测把 QKV 算成 −10.1%（NO-GO）**——根因 = `gemm32_b_pub` 与 M=130560 的 `gemm_b_pub_f16` 跨进程单轮散布 **8-21%**；≥3（最终 10）独立进程配对后才翻到线上。⇒ **新军规 35：判定线在 15% 量级时单轮探针比值不可用于裁决。**
- **吃回去的两笔都不是 requant**：(1) **这十发只有 68% 是 dpas**（另 32% = gather/SLM 面/e4m3 snap/cosine_recip，换 dtype 砍不到）；(2) **A 面量化 +0.87 ms/十发**（K=32 面 0.0785 POOL / 0.0277 plain；K=64 面免费）——**它把 proj 腿整个吃平**。requant 净增量只吃回 +0.30。
- **★ 一条硬事实：仓内没有 wbv4 真实几何（A 供在 SLM、N=96）的 int8 引擎孪生。** 本轮 int8 价全来自"宽 M + global packed A"的 s8v8 引擎；**N=96 只能走 BN32，而 BN32 的 raw→pub 附加率 = 1.53x（BN64 只 1.27x）** ⇒ 第 2 步要**从零造 BN32-int8 + SLM-A 几何**，**−15.5% 是现有引擎的最好情况，不是新几何的价**。
- **性价比红线**：试点靶 QKV 的帧价 **−0.39…−0.46 ms**（M2/M1、epi1），**低于 §40 驻留刀已经拿到的 −0.365 ms/32 对（逐位 EXACT、上限 −3.9 ms）**；而 int8 改的是**数值契约**，同类灾难判例就在旁边（`bgS_s8_wres` = 1270 面 int8 残差，§46⑥ **BLOCK-REJECT**，R 通道 50.8% 块 var 比 <0.5）。
⇒ **我的建议：不施工**（剩的时间给驻留刀：零画质风险、上限 2.3 倍大）。**若仍要试点**：按 QKV 一腿做，但**先补 BN32-int8 + SLM-A 的 pub 几何并重算净价**，否则第 2 步是在给一个没量过的形状下注。**我没有自行开工第 2 步**，等父代理/用户裁这条线。

## 7. 台账（军规 34：计价腿必须机器级干净）
`s6/WBINT8_ledger.txt`（独立缓存，key 含 simd+module）：
| 计价腿 | grf | simd | slm(B) | barrier | has_dpas | scratch | spill | private | scratch 指令 |
|---|---|---|---|---|---|---|---|---|---|
| f16v1::gemm_b | 128 | 1 | – | – | true | 0 | 0 | 8B(payload 指针槽) | **0** |
| f16v1::gemm_b_pub_f16 | 128 | 1 | – | – | true | 0 | 0 | 0 | **0** |
| s8v8::gemm_b (BN64) | 128 | 1 | 18432 | 1 | true | 0 | 0 | 8B | **0** |
| s8v8::gemm32_b (BN32) | 128 | 1 | 15360 | 1 | true | 0 | 0 | 8B | **0** |
| s8v8::gemm_b_pub | 128 | 1 | 18432 | 1 | true | 0 | 0 | 0 | **0** |
| s8v8::gemm32_b_pub | 128 | 1 | 10240 | 1 | true | 0 | 0 | 0 | **0** |
| packdev::pack_a_fused_gather / pack_a_fused / pack_a / pack_a16_b / gather_pack_a16 / pack_b* | 128 | 1(ESIMD)/16/32 | – | – | – | 0 | 0 | 8B | **0** |
⇒ **所有计价腿 scratch=0 / spill=0 / scratch 指令=0**（`private_size` 那 8B = `private_base_stateless` 的 payload 指针槽，不是 spill）。
★ **抓到的红点（军规 23/29 同族）**：`packdev::pack_a_fused_b1` = **scratch 1472B / 211 条 scratch 指令**（§38 的红点还活着）。`spillcheck_wbint8.py` 第一版因 **label 子串顺序**把它误标成 `pack_a_fused`，差点写成"我量价的量化腿带 scratch" ⇒ 已改最长优先匹配。
★ **我自己的仪器也翻过一次车**：删掉 exe 后继续跑重复，`& ".\wb_int8_probe.exe"` 的失败被 `2>&1 | Out-Null` 吞掉 ⇒ 那 6 次"重复"根本没跑（只写了空日志）。发现后重编再跑，并核对日志计数（**军规 14：仪器必须自报它做了多少**）。

## 8. 产物与现场
- csv/表：`s6/wbint8_legs.csv`、`s6/wbint8_netprice.csv`、`s6/wbint8_roof_ext.csv`、`s6/WBINT8_ledger.txt`；**43 份独立探针进程日志** `s6/WBINT8_{legs,quant,quantg,packb}_M*.log`（legs 28 = epi1 10/M + epi4 3/M + 早期单轮与 pad 对照；quant 4；quantg 8；packb 1）+ `WBINT8_compile.log`。
- 脚本：`s6/{cc_wbint8.sh,run_wbint8.ps1,wbint8_mkcsv.py,wbint8_netprice.py,wbint8_epi.py,wbint8_final.py,wbint8_ledger.py,spillcheck_wbint8.py}`。
- 临时 exe `E:\DSH\oneapi\wb_int8_probe.exe`：**交回时已删**（为了补 6 次 epi1 重复曾重编一次，补完再删）；JIT 缓存 `E:\DSH\sycl-cache-wbint8` 留着复跑；**无残留进程**；`git status --porcelain` 只剩 `?? src/bench/sycl/wb_int8_probe.cpp`。
- 变体件：**没有**；`builds\` 未新增；`out\` 与三份金标未碰。

## 9. 新军规候选（待父代理入册）
- **26 补条**：int8 屋顶**不得按 f16 的 N 比例内插**；N<64（BN32）实测比 N64 锚低 34%。
- **35**：**判定线在 15% 量级时单轮探针比值不可用** —— 同形状同引擎的 `*_pub` 跨进程散布 8-21% ⇒ **净价裁决必须 ≥3（本轮用到 6）独立进程取中位**（本铲实测翻车一次：单轮 NO-GO → 中位勉强 GO）。
- **36**：**换 dtype 的净价上限 = 该相里 dpas 的份额**（本轮 WB 四腿 = 68%）⇒ 任何 dtype 铲算术前先扣这一层，否则会写出 −5.9 这种纸面数。
- **37**：**屋顶表必须记 M**（宽 M 红利 x1.23；M=130560 的表去裁 M=522240 的腿 = 低估 23%）。
- **38**：细腿（proj/attnV）上**探针的"全局 publish"不是 shipped 的 SLM 出口的代理**（proj：探针 f16_pub 0.4403 > dll 整相 0.3872）⇒ 比值模型在细腿上不可信，只能用增量模型。
- 仪器规矩：**label 子串匹配必须最长优先**（军规 23 第三次）。

## 10. 时间
14:10 开工 → **15:25 交回第 1 步**（预算 2h，用 1h15m）。第 2 步**未开工**，等 §6 的性价比红线裁决。
