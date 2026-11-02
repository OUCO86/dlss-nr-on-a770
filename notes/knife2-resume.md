# 刀 2 = 放宽 wide_ok（N==32 → N=64/128 + f16 侧）· 工作日志

分支确认：主检出 `E:/DSH/dlss-nr-on-a770` = `ds-quality-relax-2026-11-02` @ `808cb9a`，porcelain 0。
金标只读核对：`out\libxmx.dll` = **ABB969FE4AAF0F94AA03C3F53781EDD0** ✓；`dumps\bk.1301.bin` = `bk.1301.skip.bin` = **DD49827D…** ✓；`bk.1301.pre-skip-1a.bin` = **249A46F3…** ✓。
`LOP-Win64-Shipping.exe` 进程数 = 0 ✓（GPU 空闲）。

## 读码结论（第 1 步地基）

### 守卫原文（libxmx_sycl.cpp:3101-3105，int8 batched 家族）
```
wide_ok = wmerge && !fused_b && N==32 && batch>=2 && N*batch<=128
  && sc==N && ldc_==N*batch && sa==K && lda_e==K*batch && sb==N*K
  && scale_stride==0 && epi∈{0,1,4} && narrow && K%32==0
```
命中后（:3106-3126）：`gather_pack_a_b_v(Kw,Kw,0,1)`（A 直读宽行）+ `gather_pack_b_diag_b`（B 块对角，WKey{b,N,K,10000+batch} 缓存）+ `s8v8::gemm_b_pub(M,Mp,Nw,Kw,1,0,Nw,0,0,narrow,epi)`。

### census（tools/shapes_census.csv，691 行）逐族核对
| 族 | 发数 | 形 | lda/sa | 现走 | 守卫为什么挡 |
|---|---|---|---|---|---|
| int8 batched | 8 | 32640×32×128 b2 | lda=256=K·b, sa=128=K | **已并 wide**（Nw=64,Kw=256） | — |
| int8 batched | 12 | 8160×32×128 b4 | 同上 | **已并 wide**（Nw=128,Kw=512） | — |
| int8 batched | 8 | 32640×128×64 b2 | lda=64=K, **sa=0** | split（b 维进 grid） | 非块对角 ⇒ wide 不适用；fat-N 实测 1.01x 无肉 |
| int8 batched | 12 | 8160×128×128 b4 | lda=128=K, sa=0 | split | 同上（1.01x） |
| int8 batched | 16 | 2040×128×256 b8 | lda=256=K, sa=0 | split | 同上（1.07x） |
| **int8 batched** | **16** | **640×64×256 b8** | lda=2048=K·b, sa=256=K, sc=64=N, ldc=512=N·b, sb=16384=N·K, ss=0, epi=1, narrow=1, K%32=0 | split | **只挡在 `N==32` 与 `N*batch<=128`**（Nw=512） |
| **f16 gemm** | **16** | **2040×32×128 b8** | lda=1024=K·b, sa=128=K, sc=32=N, ldc=256=N·b, sb=4096=N·K, epi=1, narrow=1 | split（f16 rec 无 wide 支） | f16 家族**根本没有 wide 支路**；需新写 `gather_pack_b16_diag_b`（块对角预铺）|
| **f16 gemm** | **16** | **640×256×64 b8** | lda=512=K·b, sa=64=K, sc=256=N, ldc=2048=N·b, sb=16384=N·K, **epi=2**, narrow=1 | split（fold pub 已在出货：`gemm_b_pub_f16` 默认 ON，epi2 走标量形式） | 同上 + N=256；**epi=2 的 pub 早已折进现路**（:2905-2917 B5-2/BLADE-5），wide 只是换形 ⇒ 逐字节 diff 是充分证明，不需要额外的"epi2 pub 等价性"论证（int8 守卫排除 epi2 是 FMA-contraction 问题，f16 现路已解决） |

⇒ **本刀真正的肉 = 16（int8 N=64）+ 32（f16 b8）**；36 发 sa=0 的 int8 batched **不走 wide**（fat-N 已实测 1.01-1.07x 无肉，军规：别走那条）。
⇒ "52/72 batched" 的普查口径 = 72−20 已并 = 52 未并，其中 wide 合法候选只有 16；其余 36 是 sa=0 广播形，**刀 2 不拿**（留下 = 0 ms，因为 fat-N 无肉；不是守卫挡的，是形状本身没肉）。

### 闭包索引（census closure = run_timing pass 序号，0..690）
- int8 640×64×256 b8：closure 217,229,241,253,265,277,289,301,391,403,415,427,439,451,463,475
- f16 2040×32×128 b8：closure 131,141,151,161,171,181,191,201,487,497,507,517,527,537,547,557
- f16 640×256×64 b8：closure 215,227,239,251,263,275,287,299,389,401,413,425,437,449,461,473

### 分档开关设计（第 3 步）
`NR_B_WIDE`：`0`=旧守卫（已出货行为逐位不变，默认不设=现状）；`1`=int8 放宽 N∈{32,64}、Nw≤512（拿 16 发 int8）+ **f16 新增 wide 支 N∈{32,64}、Nw≤512**（拿 16 发 f16 2040×32×128）；`2`=两侧放宽到 N≤256、Nw≤2048（拿 16 发 f16 640×256×64 epi2；int8 N=128 站点 sa=0 ⇒ 守卫自然不命中）。
**注意**：任务书原话"2=N32+N64+N128"——普查里 f16 块对角族是 **N=256** 不是 128，档 2 必须含 256 才能铺那 16 发；如实按 N≤256 实现并在此标注偏差。

### 显存/预铺成本（初算，第 3 步实测报数）
wide-diag B 缓存（每权重一份，init 一次跨帧不变）：
- int8 640×64×256b8：512×2048×1B = 1.0 MB ×16 权重 = 16 MB（对照现路 8×64×256=128 KB ×16 = 2 MB，净增 ~14 MB）
- f16 2040×32×128b8：256×1024×2B = 0.5 MB ×16 = 8 MB（现路 8×128×32×2=64 KB ×16 = 1 MB，净增 7 MB）
- f16 640×256×64b8：2048×512×2B = 2.0 MB ×16 = 32 MB（现路 8×64×256×2=256 KB ×16 = 4 MB，净增 28 MB）
⇒ 合计 wide 面 ~56 MB、净增 ~49 MB 设备显存；init 时间 = pack 一次/权重，不进帧（wcache 命中后跨帧复用）。

---

## 暂停令落盘（2026-11-02 17:4x，掉电安全模式）

### 已完成（带产物与 md5）
**第 0 步 = 完成**。仪器 hunk：`src/bench/sycl/libxmx_sycl.cpp` **11 行纯新增**（`rtcsv <pass> <name> <ms>` 逐发 dump，`NR_RUN_TIMING` 门后，默认侧零改动）——工作树唯一脏文件。
变体件 `E:\DSH\builds\libxmx_rt2.dll` = **9FDD0E93336F3C7445CFC0A49A4A5CF2**（`s6/build_variant.sh rt2` 出，未 stage oneapi/out）。
跑批：`nr_replay_now rt2 + NR_RUN_TIMING=1` → 4 run 全 691 passes，串行 **136.2-136.4 ms**（JIT 缓存热、GPU 凉态）。
账表 `E:\DSH\tools\rt_per_closure.csv`（691 行：closure,family,rt_label,M,N,K,batch,ms,gflop,tops；生成器 `s6/k2_mkrt.py`）。
**自校验读数**：逐发和 135.6 ≈ 该遍总 136 ✓；家族小计 vs §19/§37 的 1a 账：全部 −0.03…−1.48 ms（≈0.95 倍率，方向一致）✓；`quant(FUSED-pack)`/`quant_window(FUSED-pack)` 标签 = 已溶 quant 的改名（closure 对齐仍对）。
**三目标族实测现值（本刀受影响站点，取代分摊价）**：
| 族 | 发数 | 实测现值 ms | 旧分摊现值 | 偏差 |
|---|---|---|---|---|
| S0 int8 640×64×256 b8 | 16 | **2.944** | 0.42 | 分摊低估 7x（军规 40 坐实） |
| S1 f16 2040×32×128 b8 | 16 | **3.643** | 3.53 | 基本吻合 |
| S2 f16 640×256×64 b8 (epi2) | 16 | **3.968** | 4.43 | 基本吻合 |
| 合计 | 48 | **10.55** | 8.37 | 刀 2 的"现值"底盘 = 实测 10.55 |

**第 1 步 = 完成**。`E:\DSH\s6\knife2_sites.csv`（48 行逐站：closure 索引、plan 实参、现走形、守卫挡因、合并形 (Nw,Kw)、实测现值、屋顶预测、风险）+ 生成器 `s6/k2_sites.py`。要点：
- S0 的 16 发**只差 `N==32` 与 `N*batch<=128` 两个条件**，其余守卫条件全中（块对角形完整）。
- 36 发 sa=0 的 batched（32640×128×64b2/8160×128×128b4/2040×128×256b8）**不是被守卫挡**，是形状本身非块对角 ⇒ wide 不适用；fat-N 已实测 1.01-1.07x 无肉 ⇒ 刀 2 明确不拿（普查"52/72"里真正可铺 wide 的只有 16 发 int8 + 32 发 f16）。
- **epi=2 那 16 发（S2 f16 640×256×64 b8）处置倾向 = 纳入**：int8 守卫排除 epi2 的原因是 `gemm_b_pub` 的 FMA contraction（:3170-3175 注释），**f16 侧不存在这个问题**——f16 家族现路已默认走 `gemm_b_pub_f16` 折叠 pub（B5-2/BLADE-6，epi2 走已证的 `pub_vec_v8` 向量链），wide 只是换 (Nw,Kw)，逐字节 diff 由第 2 步原型直接证。
- 分档开关设计：`NR_B_WIDE` 0=旧守卫 / 1=int8 N∈{32,64} Nw≤512 + f16 新 wide 支 N∈{32,64} / 2=两侧 N≤256、Nw≤2048。**偏差标注**：任务书写"2=N32+N64+N128"，普查里 f16 块对角族是 **N=256**（640×256×64b8），档 2 必须含 256 才铺得到那 16 发；int8 N=128 站点 sa=0 ⇒ 守卫自然不命中。

### 第 2 步 = 只到"仪器就绪"，未跑（按暂停令不新开）
- `E:\DSH\s6\knife2_probe.cpp`（3 站点：split vs wide-diag 成对单价 + 逐字节 diff + pack_b init 腿；f16 块对角预铺 `gather_pack_b16_diag_b` 先写在 probe 本地，第 3 步再进 `pack_device.hpp`——映射已按 `gather_pack_b16_b` 逐字节镜像核对）。
- 已编译 `E:\DSH\oneapi\knife2_probe.exe` = **B5A82BE2B42BD16E2EB16B870698B4A0**（exit=0，0 errors；**从未跑过**，保留给下次开工，删不删由下次裁决）。
- 判据未动：倍率 <1.5x ⇒ 停下回报。

### 两个重要发现（未闭合的账，下次先读这段）
1. **已出货 wide 的 20 发 N=32 站点 + sa=0 的 20 发（32640×128×64b2 ×8 + 8160×128×128b4 ×12）在帧账上 ≈0.002-0.004 ms/发**（rt_per_closure 实测）。带 `NR_BPACK_TRACE=1` 的 replay 里 **`[bwide]` 打印 0 次**、`[bpack]` 前 8 条全是 2040×128×256b8 ⇒ **这 40 发在默认侧根本没到 pack/gemm 分支**（不是"wide 让它们便宜"）。机制未查明（skip-map 显示 closures_noop=0；v9b/qfuse_b/S6 默认全 OFF）。**对刀 2 无碍**：目标 48 发全在活跃链上（0.17-0.27 ms/发）；但这推翻"20 发已并 wide 在帧上付 0.10-0.14/发"的读法，**§7.3 路线图里 P8-b 的既有回收要按 ~0 重记**。
2. **NR_B_WIDE=0 对照跑作废**：wideOFF 总 167.9 vs wideON 135.6，但 +32 ms **均匀分布在全家族**（qkv +5.2、wb +4.2、res +3.7…wide 站点本身 0.03→0.05 没动）= 连续 45 分钟 GPU 跑批后的**热/频漂移**（军规 5 的"同热"对 RUN_TIMING 扫同样成立）。⇒ 下次任何跨进程 RUN_TIMING 对照要么交替跑，要么先凉 GPU。

### 工作树复原状态（本条写完时点）
- `out\libxmx.dll` = **ABB969FE…** ✓ 未动；`oneapi\libxmx_sycl.dll` = **ABB969FE…** ✓（本轮从未 stage）；三份金标 DD49827D/DD49827D/249A46F3 ✓ 未动。
- 脏文件仅 `src/bench/sycl/libxmx_sycl.cpp`（+11 行 rtcsv hunk，第 0 步仪器，**保留勿 checkout**——rt2 变体件已含它，checkout 后需重建）。
- 仓库 `src/bench/sycl/` 下有 build_variant 残留 `libxmx_sycl.dll/.lib/.exp/.def`（gitignored，porcelain 只见 .cpp）；`E:\DSH\oneapi\run_timing.txt` = **wideOFF 那次**的 dump（下次开工先重跑默认侧覆盖它）。
- 日志计数核对过：`s6/K2_rt_run1.log`（4 run 行）、`s6/K2_diag_trace.log`（88 行非空）、`s6/K2_diag_qstats.log`（144 REC 行）、`s6/K2_rt_wide0.log`（4 run 行）✓。GPU 残留进程 0 ✓。

### 下次开工第一条命令（按序）
1. `git branch --show-current`（期望 ds-quality-relax-2026-11-02 @808cb9a）+ 查 LOP-Win64-Shipping。
2. 凉 GPU ≥5 分钟后跑第 2 步原型（每站点 10 进程）：
   `Set-Location E:\DSH\oneapi; $env:K2_SITE='0'; $env:SYCL_CACHE_DIR='E:\DSH\sycl-cache-k2'; $env:SYCL_CACHE_PERSISTENT='1'; $env:SYCL_DEVICE_FILTER='level_zero:gpu'; 1..10 | % { .\knife2_probe.exe >> E:\DSH\s6\K2_probe_S0.log 2>&1 }`（S1/S2 同理换 K2_SITE；跑前确认 knife2_probe.exe md5=B5A82BE2…）。
3. 判据：PAIR 行 ratio ≥1.5 ⇒ 进第 3 步（f16 diag pack 进 pack_device.hpp + wide_ok 分档 + 默认侧 1301=DD49827D 自证）；台账用 `s6/mk_roof_ledger.py` 改 cache 目录到 sycl-cache-k2（key 含 simd）。
4. 若 diff≠0 或 ratio<1.5 ⇒ 停下回报（贴 hunk + 第一个偏差坐标）。
