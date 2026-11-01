# S6-1a 第 3 阶段：接进 shipped 引擎（三关 + 帧夹逼）

任务来源：用户 2026-11-01 11:3x 令（第 2 阶段 -6.31ms 串行 / 帧 -2.7ms 已验，不再重测）。
开工前 GPU 体检：Intel Arc A770（驱动 32.0.101.9150）无 SYCL/Level-Zero 计算进程；
模型运行时 Strata 走的是 **AMD RX 9070 XT**（backend=hip, gfx1201 profile），不占 Arc。
Arc 上只有桌面合成（GPU Engine 3D ~3.4%，来自 DeepSeek Harness 自己的 UI），与 stage1/2 的
"空闲"口径相同。跑完不留进程（见末尾清场记录）。

---

## 步骤 1：融合核搬进 shipped —— 完成

新文件 `src/bench/sycl/s6_ffn_block_kernel.hpp`（392 行）。
来源钉死：**`src/bench/sycl/s6_ffn_block2.cpp:68-400`**（`namespace ffn2` 的
`Shape` / `Args` / `fused<S,DUMP,NPHASE>`），开关名 **`NR_S6_FFN`**（文件头已写）。

VERBATIM 自检（不靠肉眼）：
```
src lines 69..400 (332 行)  vs  hpp 的 'template <int T_...' 起 332 行
PowerShell -cne 逐行比对：DIFFCOUNT=0
```
唯一新增 = `namespace ffn2 {` 之后一行 `using namespace sycl;`（bench 里它在文件作用域，
搬进头文件时收进 namespace，避免污染 libxmx_sycl.cpp；核体一个字没动）。

数值链照 §4 军规 5 / §17 三条硬要求复核过（核内无新分支）：
- `s8v8::pub_vec_v8` 三处（P2 epi3 / P4 epi1 / P6 epi1）逐字；
- `esimd::div_ieee`（= fdiv_rn）四处量化链逐字，`rnde` + `clamp(-127,127)` 逐字；
- **行峰值在 f16 舍入之后取**：P3/P5 读的是 SLM 里的 f16 面（`slm_block_load<half,16>`
  → `convert<float>` → `max(abs)`），不是舍入前的 float —— 与现路 `quantize_row_kernel` 同形；
- P6 的 `sk*cc + f0` 元素级标量式（auto-FMA，单次舍入）逐字；
- split-K 只在 int32 累加相位（KS4/KS6）；`F16PROJ` 分支保留 shipped 顺序 kc，**没有** split-K。
- `DUMP`/`NPHASE` 是编译期模板参数：shipped 实例化 = `fused<S,false,S::NPH>`，
  与 stage-2 计时腿（s6_ffn_block2.cpp:709-710）同一实例；`if (DUMP)` 与
  `if (NPHASE <= k) return;` 全部折叠掉 ⇒ 核内**无运行时诊断分支**（军规 4/9）。

## 步骤 2：recorder 接线（三处邻接配对）—— 完成

`libxmx_sycl.cpp` 改动（行号 = 改后）：
- `:49` 新 include `s6_ffn_block_kernel.hpp`（在 `pack_device.hpp` 之后、`gemm_s8_v8_kernel.hpp`
  已在前 ⇒ 无循环、无顺序坑）
- `:503-712` S6 机器（结构 + 状态机 + 闭包级开关）
- `:2641-2644` `xmx_rec_gemm_int8_batched`：`s6_take_expand` / `s6_take_proj`
- `:3316-3331` `xmx_rec_gemm_int8_residual`：`s6_take_residual` → 命中则
  `pg_push([s6f](){ s6_ffn_run(s6f); })` 并 return（不再走 split pack+gemm_b_res）
- `:5402` / `:5414` `xmx_rec_quant`：两条真实量化分支各 `s6_note_quant`
  （已溶解的 `g_fused_quant` memcpy 腿与 `NR_Q_STOP` 腿**不注** ⇒ 含它们的链永不闭合，保守）
- `:1015/1024/1052` `xmx_begin` / `xmx_abort` / `xmx_graph_capture` 各加 `s6_reset()`
  （候选里的 cmd 下标是 RECORD-scoped，跨录音必须死）

**邻接配对口径**（§9 实测 gap min2/max4）：captured 区里一条链的 6 发是**连续 recorder step**
（plan 5337/5340/5342/5345/5347/5349 之间的 `OP_*_INIT`/`OP_BUF` 不产生闭包 ⇒ gap=1）；
`s6_gap()` 取 `<=4` 为普查上界。

**状态机**：`QUANT`(arm) → `BATCHED`(expand) → `QUANT`(须=expand 的 c) → `BATCHED`(proj)
→ `QUANT`(须=proj 的 c) → `RESIDUAL`(须 skip==链首 QUANT 的 source) ⇒ FIRE。
每一步都要求 `packed/scale` 是**同一对 scratch id**（§16 的 pk1272/sc1273 复用形态），
且 M 全链一致、K 按 C/HID/C 递推。任何不匹配的 QUANT 一律**重新 arm**（不是"接着等"）。

**FIRE 的动作 = 六发全动或全不动**（用户红线）：
`g_cmds[cq1]=g_cmds[cb1]=g_cmds[cq2]=g_cmds[cb2]=g_cmds[cq3]=[](){}`（5 个 no-op）
+ 第 6 个（residual 自己的闭包）跑融合核。**没有**只跳部分的路径 —— 所以绝不会读脏 pool/dC。

**guard 逐字对 plan 实tuple 校过**（plan_960x544.c，只读 E:\WorkBuddy，未写）：
```
S1 (C=64 HID=256 M=32640) x8
  5337 QUANT    {1270,1272,1273,32640,64}
  5340 BATCHED  {1272,83,1274,1273,84, 32640,128,64,2, sa=0,sb=8192=N*K,sc=128=N,
                 lda=64,ldb=64,ldc=256=N*batch,ss=0,flags=4864=0x1300(epi3,narrow)}
  5342 QUANT    {1274,1272,1273,32640,256}
  5345 BATCHED  {1272,85,1275,1273,86, 32640,32,128,2, sa=128=K,sb=4096=N*K,sc=32=N,
                 lda=256=K*batch,ldb=128,ldc=64=N*batch,ss=0,flags=4352=0x1100(epi1,narrow)}
  5347 QUANT    {1275,1272,1273,32640,64}
  5349 RESIDUAL {1272,77,1267,1273,78,1270(skip==链首 src),73, 32640,64,64,
                 flags=266496=0x41100(epi1,narrow,half_skip)}
S2 (C=128 HID=512 M=8160) x12
  4055/4057/4059/4061/4063/4065 —— 同构（expand b=4 sb=16384 ldc=512；proj lda=512 ldc=128；
  residual N=K=128, skip=1279==链首 src）
```
⇒ 帧上会被接住的链 = **S1 x8 + S2 x12 = 20 条**。
**不接**：C=256 M=2040 族（它的 proj 在 `xmx_rec_gemm` f16，不是 `xmx_rec_gemm_int8_batched`
⇒ 三处配看不见它）和 C=512 M=640 的 F3。这两族 stage2 测过但本轮不接，如实记账。

**权重打包（不新增往返，只是换布局）**：
- `Bexp` = `gather_pack_b_b(HID, K, ldb=K, sb=0, batch=1)`，与 `pack_b(HID,K)` 同 map；
  合法性 = guard 里的 `sb == N*ldb`（组切片沿 N 连续）⇒ 宽的 HID×K 打包与
  现路 `batch×N×K` 是**同一批字节的另一种排布**，且现路那份因闭包 no-op 而不再产生 ⇒ 净设备内存不变。
- `Bproj` = `gather_pack_b_diag_b(...)`，**复用 P8-b wide-merge 的同一个 WKey**
  `{bp, N=32, K=128, 10000+batch}` ⇒ 与现路 wide 分支共享同一块（bench 里两侧就是同一 buffer）。
- `Bres` = `cached_pack_b_i8(bres, C, C)` = 现路 residual 自己那份，直接复用。
- 三处 b_scale / cosine 数组 = plan 里的原 buffer，融合核按宽索引直读（`bsExp` HID 个 float
  = batch*N 拼接；`bsProj` C 个；`bsRes` C 个）—— 与 §9 "b_scale raw = batch*N floats
  concatenated = the wide bs array" 一致。

## 编译

`bash E:/DSH/s6/cc.sh`（= build_dll.sh 的编译步，**保留 stderr**；build_dll_only.sh 把
stderr 丢进 /dev/null，语法错看不见，所以我另建了这个）
→ `E:/DSH/logs/s6_compile.log`：`def: 91 exports`，1053 warnings（全是 SYCL deprecated 噪声），
**0 error**。产物 `E:/DSH/out/libxmx_new.dll` = `E:/DSH/oneapi/libxmx_sycl.dll`
**md5 `615d5faa0b0a581f40b83150a944e5ce`**（3,772,416 B）。

## 步骤 3：三关

### 3a 门（39 门）
最终件（含 record-time witness）`md5 b2ab4a1973e6641d45d102fad6025b39`
（第一次编译件 `615d5faa…` 也跑过一遍，同 39/0，witness 只是 host printf，不改数值）：
- `bash E:/DSH/run_gates.sh`（= build_dll.sh 的门循环，同一 39 门清单，dll 已由
  `bash E:/DSH/s6/cc.sh` 编好并 stage 到 `E:/DSH/oneapi/`；build_dll.sh 会把同样的编译再跑
  一遍，编译步我已用等价配方跑通，见上）
  → **39 GREEN / 0 RED**（日志 `E:/DSH/logs/gates_s6off.txt`）
- 再跑一遍 **开关 ON**：`SUFFIX=_s6on GATE_ENV='NR_S6_FFN=1' bash E:/DSH/run_gates.sh`
  → **39 GREEN / 0 RED**（日志 `E:/DSH/logs/gates_s6on.txt`）
  ⇒ 门这一关两侧全绿；但门脚本自己的 op 流不构成 6 发邻接链（gate 日志里无 s6-fire），
  所以门绿只证明"没把现路弄坏"，不证明融合腿在 shipped 里对 —— 那由 1301 判。

### 3b 1301 逐位
| 件 | 开关 | 1301 md5 | 判定 |
|---|---|---|---|
| libxmx_new.dll | OFF（unset） | 249A46F374E98EB5FF5AD5E3A38EBC55 | **EXACT** = bk.1301.bin |
| libxmx_new.dll | NR_S6_FFN=1 | 249A46F374E98EB5FF5AD5E3A38EBC55 | **EXACT** |
金标 `bk.1301.bin` md5 = 249A46F374E98EB5FF5AD5E3A38EBC55（8,355,840 B）。
⇒ **NR_S6_FFN=0 逐位不变**（新件 OFF = 金标），**NR_S6_FFN=1 也逐位不变**（最终 1267→1301 面）。

### 3c passes（用户要求"先实测再下结论"）
实测：**passes 仍是 691，两侧都是**。
`nr_replay_now` 的 691 = `xmx_graph_run` 返回的 `g_graphs[id].size()` = **闭包条数**；
我的接线是把 5 个闭包的**函数体**换成 `[](){}`，**不删条目** ⇒ 计数不变。
`[cgraph] recorded graph id=0 (691 closures)` 两侧同串。
⇒ 判据不变，**691 不是被 S6 动摇的标准**；§5 预言的"691→~115-160"只有当
**闭包条目本身被合并掉**（真 megakernel 形态，S6-1b）才会发生。本轮不动条目。

### 3d 确定性两遍
同件（NR_S6_FFN=1）连跑两个独立进程，Tag 分别 `s6on` / `s6on_b`：
两个 `.1301.bin` md5 相同，且都 = 金标 ⇒ **两遍 100%**。
帧时（同件、同热、walk 4 遍取 run1..3）：
- OFF：69.05 / 70.32 / 71.28 ms
- ON ：66.38 / 67.21 / 67.17 ms（第二遍进程 66.69 / 66.28 / 67.60）

## 附加问题的答案（Track 2 输入）

### (i) cgraph 节点数 / 依赖
- **闭包数（passes）不变 = 691**（见 3c）。
- **captured cgraph 的设备节点数下降**：5 个 no-op 闭包**不产生任何 device op**
  （cgraph 是把闭包循环里的 GPU 操作录进 `command_graph`，闭包的 host 侧在录图时已经跑过），
  所以每条链从 `pack_a + gemm (+publish) ×2 + quantize ×3 + pack + gemm_res` 塌成
  **1 个 ESIMD 核**；20 条链 ⇒ 每帧少 **~100 个节点**（按现路每发的 launch 数算：
  3 个 quant + 2 个 batched 的 pack_a+gemm(+Bpack 命中缓存) + residual 的 pack_a+gemm_res）。
  依赖形状同步变窄：pk1272/sc1273 与 1274/1275 在 captured 区里不再是"写→读"节点，
  只剩 1270（读）与 1267（写）两个边界 = §16 要的效果。
  ⚠ 我没打印过节点计数（引擎不报），上面的 100 是从"no-op 闭包零 device op"+ 现路每发
  launch 数推的；要精确数得在 cgraph finalize 上挂探针 —— 本轮按军规 4/9 不在核/闭包里
  加运行时分支，没做。**这条标为"结构推断，未实测"**。
- PGRAPH（NR_PGRAPH 默认 OFF）的 touch-set 我按链的全部操作数登记（`pgraph_extra` 补了
  expand/proj 权重与两个 b_scale），S6-1b 上 PGRAPH 时不会漏边。

### (ii) NR_RUN_TIMING 第二遍表三行的新价（同件、同 session、开关两侧各跑一遍）
| 行（op 名） | 旧账（§3/§16） | 本件 OFF 实测 | 本件 ON 实测 | 变化 |
|---|---|---|---|---|
| `xmx_rec_gemm_int8_batched` | 18.5 | 18.1 / 18.5 / 18.5 / 18.9 | **7.4 / 7.6 / 7.3** | **−11.1** |
| `xmx_rec_gemm_int8_residual` | 18.0 | 17.7 / 17.4 / 17.2 / 17.6 | **23.2 / 23.8 / 23.5 / 23.2** | **+5.7** |
| `xmx_rec_quant` | 10.3 | 9.4 / 9.6 / 9.7 | **3.9 / 4.3 / 3.9** | **−5.7** |
| （参考）`xmx_rec_gemm_window_int8_residual` | — | 13.4 / 13.2 / 12.8 / 13.0 | 12.7 / 13.6 / 13.1 / 13.6 | 带内（未接） |
| **RUN_TIMING 串行合计** | 154 | **152 / 152 / 151 / 152** | **142 / 143 / 141 / 141** | **−10** |
读法（重要，别把行价当"这一族变快/变慢"）：
**residual 行涨了 5.7ms，因为融合核是挂在 residual 那个闭包里跑的** —— 它现在替整条 6 发链
付钱；batched 与 quant 两行的下降里包含被 no-op 掉的那 40 个 batched / 60 个 quant 闭包。
三行合起来 46.8 → 34.5 = **−12.3ms**（同族口径），串行合计 −10ms。
⇒ 给 Track 2 的净口径：**帧上 20 条链（S1x8 + S2x12）现路串行价 ≈ 13.6ms（bench 链 wall）
→ 融合后 ≈ 8.3ms**；RUN_TIMING 上多出来的 ~3ms 是**闭包数不变但 host 侧 pack/launch 记账消失**
（pool_get / cached_pack 查找 / 5 次 submit）—— 这部分在 bench 的 wall 口径里也算过，
所以 −10 vs −5.3 的差 = 帧上 split 腿的**启动开销比 bench 里更贵**（cgraph 外每发都要 submit）。

## 步骤 4：帧级判定（本任务真正的答复）

协议：`E:/DSH/ab.ps1 -DllA E:/DSH/out/libxmx.dll -DllB E:/DSH/out/libxmx_new.dll -Pairs 16 -EnvB 'NR_S6_FFN=1'`
**A 侧 unset**（我把 `NR_S6_FFN`/`NR_S6_TRACE` 加进了 ab.ps1 的清场名单 `:29`，
否则 B 腿设的 env 会漏进后续 A 腿 = 两侧都 ON，A/B 作废；这是脚本 v2 那类 bug 的同一个坑，
改后文件仍是 UTF-8 带 BOM）。B 腿只多 `NR_S6_FFN=1`，其余 env 两侧同场。
run0 丢弃、run1..3 取中位。日志 `E:/DSH/logs/ab_s6_shot{1,2,3}.txt`。

三枪（每枪 16 对）：
| 枪 | 对数 | B 赢 | 枪均值 |
|---|---|---|---|
| 1 | 16 | 16/16 | **-2.683** |
| 2 | 16 | 16/16 | **-3.032** |
| 3 | 16 | 16/16 | **-3.134** |
合并 48 对：
```
A mean 70.822 ms   B mean 67.872 ms
mean = -2.950   median = -3.005   sd = 0.847   SE = 0.122
B 快 48/48 (100%)   min -0.990   max -4.870
95% CI = [-3.190, -2.710]   (1.96*SE；t47=2.0117 给 [-3.196, -2.704])
```
48 对逐对 delta（枪1 | 枪2 | 枪3）：
```
-3.140 -2.460 -3.340 -1.230 -2.670 -2.160 -4.380 -2.780 -3.540 -3.270 -2.490 -3.140 -2.400 -2.600 -0.990 -2.340
-2.710 -2.940 -2.270 -3.570 -2.670 -2.850 -1.080 -3.720 -3.330 -2.460 -4.870 -3.190 -2.610 -3.100 -3.760 -3.390
-2.290 -2.850 -1.640 -4.100 -1.750 -4.100 -2.920 -3.180 -3.070 -3.780 -1.990 -3.180 -3.620 -3.270 -3.800 -4.610
```

### 判读（按用户给的三段式）
**均值 -2.950 <= -0.5 且赢 48/48 >= 10 ⇒ 可转正。** 默认没翻（`NR_S6_FFN` 仍 OFF），
数交给用户拍。**没翻默认 = 出货件行为逐位不变。**

**存活率（bench → 帧）：**
- 本轮只接了 **20 条链**（S1 x8 + S2 x12），不是 stage-2 的 36 条：
  bench 串行账 = 8(-0.3492) + 12(-0.2111) = **-5.32 ms**（S3 的 16 条没接，见步骤 2 末）
- 帧实测 = **-2.950 ms** ⇒ **存活率 55%**（stage-2 按 43% 猜的 -2.7，实测比它略好）
- 若把 S3（16 链 x -0.0617 = -0.99 串行）与 F3（未建）也算进 36 链的 -6.31 口径，
  帧 -2.95 / 串行 -6.31 = 47% —— 但**那是错的对比**：帧上只有 20 条在跑融合。
  正确口径就是 **5.32 → 2.95 = 55%**。
- 另：RUN_TIMING 的串行差 = -10.0 ms（152→142），比 bench 的 -5.32 大，
  但 RUN_TIMING 走的是 **plain 闭包循环**（NR_RUN_TIMING 分支在 cgraph 之前 return），
  把每发的 host submit/pool/wcache 记账全暴露出来；帧上真跑的是 captured graph（1 次 submit），
  所以那 -10 不是帧上限，别拿它吹。帧的实测就是 -2.95。

### 与"没接的两族"有关的下一铲（不裸回退、机制保留）
1. **S3（C=256 M=2040 x16）**：链形 5 发，proj 在 `xmx_rec_gemm`（f16），三处配文看不见它。
   接线要加第 4 个 site（`xmx_rec_gemm` 的 f16 分支），融合核的 `F16PROJ` 分支已在 hpp 里
   （`Shape<8,256,1024,true,1,2>`，f32 累加 ⇒ 不许 split-K，TS=16 顺序 VERBATIM）。
   bench 只赢 -0.062/链 ⇒ 16 x -0.062 = -0.99 串行，帧 ~-0.5：值，但优先级低于 P3 占用率刀。
2. **F3（C=512 M=640 x16，7 发混合形）**：stage-2 未建，符号未知。
3. **P3 requant 占用率刀**（stage-2 记的最大单项：S1 P3 .181 act 32/64、S2 .175 act 16/64）
   ⇒ 预估再 -1.3~-1.6 串行 ~= 帧 -0.7~-0.9。

## 清场 / 纪律自查
- 只写 `E:\DSH\`（新 hpp、libxmx_sycl.cpp、s6/cc.sh、s6/stage3.md、logs/、out/libxmx_new.dll、
  oneapi/libxmx_sycl.dll、dumps/s6*.1301.bin、ab.ps1 的清场名单一行）。
  **`E:\WorkBuddy` 只读**（plan_960x544.c 用 Get-Content 读，未写）；**C 盘未写**。
- 未 commit、未 push（`git status`：`M src/bench/sycl/libxmx_sycl.cpp` + 未跟踪 hpp）。
  完整 diff（636 insertions / **0 deletions**）落盘 `E:\DSH\logs\s6_diff.patch`。
  ⇒ 纯增量本身是"OFF = 现路逐位不变"的结构证据。
- 每个时刻 GPU 上只有一个进程（门/walk/A/B 全串行，跑前查过空闲）。
- 跑后清场：见下面"清场核验"。
