# 诊断铲：window_block(10) + global_attention(8) 的算力/相位账（只测不改）

分支 `ds-quality-relax-2026-11-02`（`git branch --show-current` 已确认 = 该分支，HEAD a1b4391）。
纪律：不动 shipped 三源、不接图、不 commit/push；只写 `E:\DSH\`；`out\libxmx.dll`(E2D5E574) / `libxmx_new.dll`(460FC367) 不动。

## 0. 已读的三处（口径锚）
- §19：家族价口径 = `NR_RUN_TIMING` 逐闭包 wait 的地面真值；判据三段式（可达性 / bench 单价 / 帧 A/B）；
  已知 `window_block 19.9/10 发 = 1.99ms/发`、`global_attention 12.0/8 发 = 1.50ms/发`（去 2x 记账）。
- §24：相位算力 P4 contract **39.6/55.2 TOPS**、P2 expand 5.49/5.33、P6 res 4.05/7.40
  ⇒ dpas 矩阵相不是瓶颈，锅在 elementwise（requant/publish/pack）。军规 19：grf 顶格 128 的核里加宽探针不免费。
- §35/§36：消腿 ≠ 省时间（三次独立同判）；§36 的相位归因只用**带出口 sunk 曲线看形**，
  nosink cum 在产物只活 SLM 的格子会被 DCE 剪（P9/P10 格两轮符号相反 ⇒ 不可信）。
- `notes/s6b-att-stage.md` ①/⑤：SLM 算术模型（片名/别名/峰值 vs 65,536 帽 与 32,768 崖）；
  信用证明 = b6 旧形复算 57,344B 与 `b6_res_kernel.hpp:56 SLMB=57344` 逐字节吻合。

## 1. 第 1 步（完成）：18 发的参数 / FLOPs / dpas 交叉核对
产物：`E:\DSH\s6\wb_ga_ops.csv`（逐发实参+几何+MAC）、`E:\DSH\s6\wb_ga_tops.csv`（逐发 GFLOP/价/TOPS/离屋顶倍数）、脚本 `wbga_ops.py`、`wbga_tops.py`。

**图区 691 个 recorder op 里**：`WINDOW_BLOCK` 10 发 = graph pass **{1,3,5,7,9,682,684,686,688,690}**；
`GLOBAL_ATTENTION` 8 发 = pass **{319,328,337,346,355,364,373,382}**（步长 9）。
（pass↔plan 行号映射由 `wbga_ops.py` 的序列扫描直接得出，与 `tools/blockseq.py` 同尺。）

**参数语义（grep 行号，未整读）**
- `xmx_rec_window_block` = `libxmx_sycl.cpp:4872`（14 参：image,qkv,projection,target,bias,cosine,scale,pooled,windows,height,width,across,pad,flags）；
  `:4898` **C=32、heads=1、tokens=64、NH=96**；`:4899` rows=windows*64；`:4901` top=pad>>16、left=pad&0xffff；
  `:4895/4896/4897/4879/4880` flag 位：image_half=0x8000、epi=(f>>8)&0xF、narrow=0x1000、pooling=0x800000、head=0x1000000；
  **`:4910` 自带 flop_note 四腿**：wb_qkv(W·64, 96, 32) / wb_scores(W·64, 64, 32) / wb_attnv(W·64, 32, 64) / wb_proj(W·64, 32, 32)。
- 路由（帧上真走的那条，§19 的可达性）：plain 8 发 → `wbv4::launch_v4full`（`:4965-4980`，默认）；
  pool 1 发（8160w, flags 0x800000）+ head 1 发（8349w, flags 0x1000000）→ `wbv4ph::launch_v4ph`（`:4988-5012`）。
- `xmx_rec_global_attention` = `:3952`（7 参 q,k,v,merged,rows,tokens,heads）；**6 腿**：
  `pack_a16_b`(Q :3986) → `pack_b16_t_b`(K :3987) → `f16v1::gemm_b`(scores :3988) →
  `smax::vit_softmax_tiled`(:3997-3998，NR_GA_TILE 默认 ON) → `pack_b16_b`(V :4006) →
  `f16v1::gemm_b_merge_scale`(attnV+merge fold :4022，NR_GA_MERGE 默认 ON)。
- **18 发里没有 FFN**：window_block recorder 只组 attention 半边（`:4853-4864` 的 leg1/leg2/leg3 注释）；
  FFN 是独立族（ffn 8 + ffn_merge 1 + ffn_stem 1），不在本铲账上。⇒ 任务书里的"FFN expand/contract"在这两族**不适用**，已核。

**逐发 FLOPs（=2×MAC）**
- WB：每窗 524,288 MAC = **1.048576 MFLOP/窗**（4 腿）；head 形再加 32,768 MAC/窗（`window_block_v4ph.hpp:402 tile8s(h…,2,1)` = 64×16×32）。
  十发 = {8160 pool, 2040, 2135, 2074, 2100(f0), 2040, 2135, 2074, 2100, 8349 head} ⇒ **35.367 GFLOP**。
- GA：每发 75,497,472 MAC = **0.15099 GFLOP**（scores 37.75M + attnV 37.75M MAC）⇒ 八发 **1.208 GFLOP**。
- 18 发合计 **36.575 GFLOP**。

**dpas 条数反推（独立核对，§36 在 P4 上的做法）**
- `window_block_v4.hpp`：`tile8s/tile8ss`（`window_block_v3.hpp:216/233`）每 kc = 4 条 `esimd::xmx::dpas<8,8,float>`，操作数 `simd<half,128>` ⇒ 每条 8×8×16 = **1024 MAC**。
  每窗：QKV 4sg×3part×2 tile8s(kb_n=2)×8 = **192**；scores 4sg×4tc×8 = **128**；attnV 4sg×2tc×tile8ss(kb_n=4→16) = **128**；outproj 4sg×2tc×8 = **64** ⇒ **512 条/窗 = 524,288 MAC** ✓ 与 `:4910` flop_note 逐位相同。
- GA：`gemm_f16_v1_kernel.hpp:2-3` "one work-item = one 16×16 tile = 4 dpas per 16-K step"；
  scores = (192/16)²×32 batch = 4608 tiles × kb_n(2)×4 dpas × 1024 = **37,748,736 MAC** ✓；
  attnV = 12×2×32 = 768 tiles × kb_n(12)×4 × 1024 = **37,748,736 MAC** ✓。

## 2a. RUN_TIMING 复测（件 E2D5E574 未动，本 session 末遍，`E:\DSH\oneapi\run_timing.txt`）
- 691 passes / total **144 ms**；`xmx_rec_window_block = 20.0 ms`、`xmx_rec_global_attention = 11.6 ms` ⇒ 复现 19.9/12.0 ✓
- 逐发（末遍 top-25 全含 18 发）：WB = 5.0(pass1 pool) / 4.8(pass690 head) / 1.2,1.3,1.2,1.2 / 1.2,1.2,1.2,1.8；GA = 1.4×7 + 1.8×1
- **家族 TOPS**：WB 35.367/20.1 = **1.76 TOPS**；GA 1.208/11.6 = **0.104 TOPS**；18 发 36.575/31.7 = **1.15 TOPS**
- 离 **22.6 TOPS（int8 锚）**：WB **12.8x**、GA **217x**

## 2c. 单发夹逼（`src/bench/sycl/wb_ga_probe.cpp`，新件 untracked；GPU event / barrier 夹逼，min-of-15×5、5 组、60ms 间隔；日志 `E:\DSH\s6\WBGA_probe1.log`）
**WB（纯 GPU，单发）**：2040w **0.9837** | 2135w 1.0679 | 2074w 1.0009 | 2100w(f4352) 1.0473 | 2100w(f0) 1.0341 | **8160w POOL(v4ph) 4.0399** | **8349w HEAD(v4ph) 3.9745** ms
⇒ 10 发合计 **16.20 ms** vs RUN_TIMING 20.1 ⇒ **1.24x**（<2 ⇒ 不触发停线）；差值 = host submit + `pool_get` + `cached_pack_b_f16` 查找
⇒ 每窗单价 **0.482 / 0.496 / 0.477 µs/WG**（2040 / 8160 / 8349）⇒ **两个 8K 巨头没有"巨头发病理"，就是 4x 窗数**（§100 P8-h 的 parity 结论在探针上复现）
⇒ WB 家族 TOPS（探针价）= 35.367/16.20 = **2.18 TOPS**

**★ 屋顶不是 22.6（本铲最重要的口径修正）**：这两族的 gemm **全是 f16 dpas**（`tile8s/tile8ss/f16v1`，操作数 `simd<half,128>`），
而 22.6 TOPS 是 **int8** 锚（130560×384×128）。同一引擎、同一进程实测（probe 的 ROOF 段，`f16v1::gemm_b` 宽 M=130560、batch=1）：
| 形状 | ms | TOPS |
|---|---|---|
| M130560 × N96 × K32（= WB qkv 腿的形） | 0.2922 | **2.75** |
| M130560 × N64 × K32（= WB scores 腿的形） | 0.2199 | 2.43 |
| M130560 × N32 × K32（= WB proj 腿的形） | 0.1452 | 1.84 |
| M130560 × N192 × K32（= GA scores 的 N/K） | 0.5069 | 3.17 |
| M130560 × N32 × K192（= GA attnV 的 N/K） | 0.2482 | 6.46 |
| M130560 × N384 × K128（宽锚） | 1.0391 | **12.35** |
⇒ **本机 f16 在 K=32 浅 K 上的屋顶只有 2.4-3.2 TOPS**；宽锚 384×128 的 f16 = 12.35 TOPS ≈ int8 22.6 的一半（XMX f16:int8 = 1:2 ✓ 自洽）。
⇒ **WB 的 2.18 TOPS = 同 N/K 宽 M f16 屋顶（2.75）的 79%**；"离 22.6 有 12.8x"里绝大部分是**精度差（f16 vs int8）+ 浅 K 差**，不是躺着的算力。

**GA（barrier 夹逼，底噪 0.0146 ms）**：整链 **2.948 ms/发** vs RUN_TIMING **1.45 ms/发** ⇒ **2.03x ⇒ 触发任务书的停线条件**（已回报，见下）
- 分腿：pack_a16_b(Q) 0.0807 | pack_b16_t_b(K) 0.0670 | `gemm_b` scores **0.0799** | **`vit_softmax_tiled` 2.4924** | pack_b16_b(V) 0.0788 | `gemm_b_merge_scale` attnV **0.0825**
- ⇒ 两条 gemm 腿合计 0.162 ms = **0.93 TOPS**；三腿 pack 0.227 ms；**softmax 一腿 2.49 ms = 全链 84%**
- 对照：`NR_GA_TILE=0 & NR_GA_MERGE=0` 的 8 腿 split 形 = 3.046 ms（只 +0.1 ms ⇒ 折叠腿不是税，softmax 才是）

## 3. WB 内部分相（stop_stage 纯 stop、无 dump 出口；cum 曲线）
| 形 | QKV(10) | +scores(5) | +probs(6) | +attend(8) | +proj(9) | +FULL(0) |
|---|---|---|---|---|---|---|
| 2040w v4full | 0.3611 | 0.2828 | **0.0027 ← 不可信** | 0.1729 | 0.1078 | 0.0552 |
| 8160w v4ph POOL | 1.4429 | 0.9370 | 0.2047 | 0.6739 | 0.3872 | 0.3979 |
| 8349w v4ph HEAD | 1.4751 | 0.9578 | 0.2136 | 0.6848 | 0.3917 | 0.2609 |
- shipped 核只有 10/5/6/8/9/0 六个出口（101/102/103 是 `bench_v4full.cpp` 自己加的，shipped 里没有）⇒ P0 gather 单独拿不到。
- **2040w 的 probs 格 0.0027 不可信**（§36 同款坑：softmax 产物只活 SLM，stop=6 时没有 global 汇 ⇒ 被 DCE 剪）；
  两个 8K 巨发的 probs 格 0.20-0.21 可信（后面还有 attnV/proj/publish 消费它）。
- 四腿 dpas 相合计 = FULL 的 **94%**（2040w，扣掉可疑格后重算 0.9246/0.9826）/ **90%**（8160w）
  ⇒ **出口相（residual+publish / pool fold / head GEMM+compact store）只占 5.6-10%**（0.055 / 0.398 / 0.261 ms）
- 每相里 **dpas vs 该相的 elementwise 尾（e4m3_vec / pack map / cosine_recip / store16s）没有拆开**——shipped 核没有 101/102/103 级微出口（那是 `bench_v4full.cpp` 自加副本里的）。
  但 §100 的 FILL PROBE 已证 v4 是 **LATENCY-bound、~20% issue utilization**（`bench_v4full.cpp:466-478`），与本铲"矩阵腿已在 81-150% 屋顶"完全咬合：不是矩阵引擎在等，是链/屏障在等。

## 4. ★ 屋顶-by-形状（本铲最值钱的产出，已落 `E:\DSH\dlss-nr-on-a770\tools\xmx_f16_roof.csv`，30 行）
配方（同进程、同引擎、宽 M=130560、batch=1、单发 GPU event、min-of-15×5、5 组 60ms）：
`f16v1::gemm_b` + `packdev::pack_a16_b/pack_b16_b`；`s8v8::gemm_b` + host `s8v8::pack_a/pack_b`（int8 要求 N%64==0、K%32==0、M 补到 128 倍数）。
| N | f16 K32 | K64 | K128 | K192 | K384 | | int8 K32 | K64 | K128 | K192 | K256 | K384 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
|32 | **1.84** | 3.64 | 5.43 | 6.46 | 8.59 | | – | – | – | – | – | – |
|64 | 2.43 | 4.82 | 8.95 | 11.38 | 13.92 | | **3.90** | 7.38 | 12.78 | 16.99 | 20.33 | 25.45 |
|96 | **2.75** | 5.35 | 10.11 | – | 17.84 | | – | – | – | – | – | – |
|128| – | – | – | – | – | | 5.05 | – | 17.22 | – | – | 33.70 |
|192| **3.17** | – | 11.44 | 16.04 | – | | 5.62 | – | 19.65 | – | – | – |
|384| – | – | **12.37** | – | – | | – | – | **22.73** | – | – | – |
- **仪器自校验**：int8 N384K128 = 22.73 TOPS ⇒ 复现仓内锚 `130560×384×128 = 0.5684 ms = 22.6 TOPS`（差 0.6%）✓
- **dtype 倍率（实测）**：int8/f16 = **1.43-1.84x**（浅 K 处只有 1.4-1.6，不是 2.0）
- **K 深度倍率（实测，同 N）**：K32→K384 = **x4.67(N32) / x5.72(N64) / x6.50(N96)**；int8 N64 = x6.52
- ⇒ 军规候补 26（用户令）：**任何"离屋顶几倍"必须先按 dtype + N/K 查这张表；int8 的 22.6 不得当通用屋顶。**

## 5. WB 逐腿 vs 该形状屋顶（用 8160w POOL 的 stop 阶梯差；2040w 的 softmax 格被 DCE，弃用）
| 腿 | 形状 N×K | 发内 GF/ms | TOPS | f16 宽M屋顶 | **占屋顶** | int8 屋顶 | 占 int8 |
|---|---|---|---|---|---|---|---|
| QKV | 96×32 | 3.2086/1.4429 | 2.22 | 2.75 | **81.0%** | 4.54* | 49.0% |
| scores | 64×32 | 2.1391/0.9370 | 2.28 | 2.43 | **93.9%** | 3.90 | 58.5% |
| attnV | 32×64 | 2.1391/0.6739 | 3.17 | 3.64 | **87.3%** | 5.57* | 57.0% |
| outproj | 32×32 | 1.0695/0.3872 | 2.76 | 1.84 | **150.0%** | 2.95* | 93.5% |
（* = 派生/内插数，不是实测。）矩阵腿占全发 **85.1%**；elementwise 相（softmax 0.2047 + tail/publish 0.3979）= **14.9%**。
⇒ **WB 的四条矩阵腿已经在"同 N/K 宽 M f16 屋顶"的 81-150% 上**（outproj 甚至超过宽 M 屋顶，因为它把 A 供在 SLM）。
⇒ 十发矩阵腿实测折算 **14.00 ms** → f16 屋顶算术 **13.09 ms**（只剩 **−0.91 ms**）→ int8 屋顶算术 **8.15 ms**（**−5.86 ms**，但要改数值契约）。

## 6. GA 腿账（帧上门为主，探针只当形状线索）
**帧上 A/B（件 E2D5E574，NR_RUN_TIMING，每配置 4 遍取末三遍中位，`E:\DSH\s6\WBGA_rt_{default,tile0,tile0_merge0,merge0}.log`）**：
| 配置 | global_attention 家族 | Δ vs default |
|---|---|---|
| default（TILED softmax + MERGE 折叠） | **11.7 ms** | – |
| NR_GA_TILE=0（普通 softmax + 多一趟 pack_a16_b） | 12.0 | +0.3 |
| NR_GA_MERGE=0（attnV 出 dCtx + 独立 merge_heads 环） | 12.3 | +0.6 |
| 两个都 0（8 腿 split） | 12.7 | +1.0 |
⇒ 两次折叠只值 **1.0 ms/帧**（additive ✓ 0.3+0.6≈1.0）；**同一次 merge_heads 环 = 196,604 元素 / 0.075 ms ⇒ 帧上 elementwise 速率 ≈ 2.6 G elem/s**。
**GA 每发 1.45 ms 的分配（帧口径）**：两条 gemm 腿 0.162（探针单发 event，可信）+ 三腿 pack ≈ 0.25 + **softmax ≈ 1.0**。
softmax 摸 1.18M 元素 × 2 趟 = 2.36M 次 ⇒ **2.36M/1.0 ms = 2.4 G elem/s ⇒ 与 merge 环同速** ⇒ **softmax 不是"这个核慢"，是"这条 op 就是这么多 elementwise 触点"**。
**停线记录（已回报）**：探针链 2.895-2.948 ms/发 vs RUN_TIMING 1.45 ⇒ 2.03x；探针里 softmax 2.49-2.50 ms。
把 rows/tokens/heads 改成**运行期取值**（getenv，防常量折叠/全展开）重跑 ⇒ softmax 仍 2.5022 ⇒ **常量折叠不是解释**；
台账（`E:\DSH\s6\WBGA_ledger.txt`）：探针实例 `smax::vit_softmax_tiled` grf=128、simd=16、slm/spill/private/scratch **全无条目**、scratch 指令 0 ⇒ **不是 spill**。
⇒ 结论 = **探针 TU 的实例化 ≠ dll 的实例化（codegen/inlining 不同）⇒ 探针绝对值不得给 dll 内核定价**（§36 仪器坑的第二形态，入册建议）。
GA 矩阵腿离屋顶：scores 0.94 TOPS = 该形 f16 屋顶(3.17) 的 **29.9%**；attnV 0.92 TOPS = 屋顶(6.46) 的 **14.2%** ⇒ 但两腿合计只 0.162/1.45 = **11% 的发价** ⇒ **矩阵不是 GA 的肉**。

## 7. 交回四行 + 判决
① **逐发 FLOPs/TOPS 表**：`E:\DSH\s6\wb_ga_tops.csv`（18 发）；家族 **WB 1.76 TOPS（帧价）/ 2.18（探针价）**、**GA 0.104 TOPS**、18 发 36.575 GFLOP/31.7 ms = 1.15 TOPS。
② **离屋顶几倍（每核一个数，按 §4 的形匹配屋顶，不按 22.6）**：
 - `window_block`：矩阵腿 = 该形 f16 宽M屋顶的 **81-150%（均值 92%）** ⇒ **离屋顶 1.09x**（几乎贴顶）；离 int8 屋顶 = 49-94% ⇒ 若换 int8 还有 **1.7-2.1x** 可用。
 - `global_attention`：矩阵腿 = 该形 f16 屋顶的 **14-30%** ⇒ 离屋顶 3.3-7.0x，**但矩阵只占发价 11%** ⇒ 这个倍数不值钱。
③ **内部分相账**：
 - WB（stop 阶梯）：QKV 35.7% > scores 23.2% > attnV 16.7% > outproj 9.6% > **publish/pool/head 出口 9.8%** > softmax 5.1%；四条腿里挂的是 **dpas + 其 SLM elementwise 尾（e4m3_vec / pack map / cosine_recip / store16s）**，不是 gather/publish。
 - GA（帧上门 + 单发 event）：softmax 一腿 ≈ 1.0/1.45 = **69%**；pack 三腿 17%；两条 gemm 11%；两次折叠（TILED/MERGE）净贡献 1.0 ms/帧。
④ **判决（二选一 = 有肉，但不在"算力"上）**：
 - **WB：这里没有 −10 ms。** 矩阵腿已贴形匹配屋顶（92%），f16 口径只剩 **−0.9 ms/10 发**；要 **−5.9 ms** 必须把四腿换 **int8**（dtype 门，改数值契约：A/B 要换成 pk/sc 网格 + 每行 scale、权重要预整定 int8 pack、epilogue 要加 requant）——这是质量决定，不是性能决定。
 - **GA：这里有 −2.5…−5.5 ms 串行，靠融合不靠算力。** 11.6 ms/8 发里 8 ms 是 softmax 的 2.36M×8 次 elementwise 触点 + 每次 op 6 次发射。切法 = 把 **scores+softmax+attnV 收进一 WG 常驻**（= §36 已为 window 侧做过的那件事，搬到 GA 形）：消 dScores(4.72MB f32)+dAp(2.36MB) 两趟 global 往返与 4-5 次发射，softmax 在 SLM/寄存器里做。
   纸算 SLM 预算（**未实测**，照 §36/s6b_att 的算法）：一 WG 拥有 48 行×192 列 ⇒ scores f32 36,864B + probs(别名进 scores 尾) + V tile 12,288B + K tile 12,288B + Q tile 3,072B ≈ **64KB ⇒ 进 65,536 帽但超 32,768 崖**；要 **24 行(≈43.9KB)或 16 行(≈41.5KB)** 才进崖内 ⇒ 与 §29/§36 同一条"贴崖/超崖"曲线，需要实测。
   按 §36 实测比例（−19.9% wall / −26.6% GPU）外推 ⇒ **−2.3…−3.1 ms/帧串行**；若 softmax 在 SLM 里跑到 2x ⇒ 到 **−5.5 ms**。
 - **火力建议**：这两族的"18 发 = 31.9 ms"里，**真正能被"形状/dtype"动的是 GA 的融合（−2.5…−5.5）与 WB 的 int8 门（−5.9，需质量裁决）**；WB 的 f16 矩阵腿已经不值得动。

## 9. 台账（第 2 步 a）+ 停线根因 + softmax 宽度阶梯
**9a. shipped 件自己的台账**（`E:\DSH\s6\WBGA_ledger_dll.txt`；方法 = 把 walk 指到**空缓存** `E:\DSH\sycl-cache-wbga` 跑一遍（4 runs、691 passes、帧 63.3-64.6 ms ⇒ 与"串行 144/帧 63"口径一致），再用 `spillcheck_wbga.py` 扫该缓存）：
| 核（计价腿，全部来自 dll） | grf | simd | slm(B) | spill | private | scratch | scratch 指令 |
|---|---|---|---|---|---|---|---|
| `wbv4::launch_v4full`（plain 8 发） | 128 | 1 | **45,056** | 0 | 0 | 0 | **0** |
| `wbv4ph::launch_v4ph`（pool+head 2 发） | 128 | 1 | **45,056** | 0 | 0 | 0 | **0** |
| `f16v1::gemm_b`（GA scores） | 128 | 1 | 6,144 | 0 | 0 | 0 | 0 |
| `f16v1::gemm_b_merge_scale`（GA attnV+merge） | 128 | 1 | 0 | 0 | 0 | 0 | 0 |
| `packdev::pack_a16_b` / `pack_b16_b` | 128 | **32** | 0 | 0 | 0 | 0 | 0 |
| `packdev::pack_b16_t_b` | 128 | 32 | 0 | 0 | **一个实例 608B** | 0 | 0 |
| `smax::vit_softmax_tiled` | 128 | **8** | 0 | 0 | 0 | 0 | 0 |
| `smax::vit_softmax_kernel`（GA_TILE=0 逃路） | 128 | 8 | 0 | 0 | 0 | 0 | 0 |
⇒ §36 的"计价腿 private/spill/scratch=0"在两族上**基本达成**；唯一红点 = `pack_b16_t_b` 的一个实例 **private=608B**（scratch 指令 0 ⇒ 未见显式 scratch 访存，标为待查，不当结论）。
⇒ **两个 window_block 核 slm = 45,056B ⇒ 超 32,768 崖 ⇒ 驻留 1**（§29 曲线：超崖一项就 ≥24%）。这就是 §36④"驻留/线程那笔钱还没吃"在 WB 上的具体形状：**要拿的是把 SLM 压回 ≤32,768（省 12,288B）**，不是矩阵。

**9b. ★ 停线根因（已证实，不是猜测）**：同一份 `softmax_kernel.hpp`、同一套编译旗标，
 - dll 实例：`smax::vit_softmax_tiled` **simd = 8**
 - 探针实例：**simd = 16**
⇒ 探针的 2.49-2.50 ms 与 dll 的 ≤1.07 ms（帧上反推）**不是同一个二进制**。
⇒ **入册建议（军规候补）：探针/独立 TU 的绝对值不得给 shipped dll 内核定价；两份实例的台账必须逐列（grf/simd/slm/private/scratch）对上才算同形。** 这是 §36 仪器坑（per-launch event 返回 0）的第二形态。
（已排除的解释：常量折叠/全展开——把 rows/tokens/heads 改成运行期 getenv 取值重跑，softmax 仍 2.5022；spill/scratch——台账两侧都是 0。）

**9c. softmax 的 SIMD 宽度阶梯（bench 局部副本，不动 shipped 头；`E:\DSH\s6\WBGA_probe_smx.log`）**
副本与 shipped 版**逐字节 EXACT**（mismatch = 0 / 1,179,648 half）⇒ 是同一算式，只是外面套 `nd_range` 把宽度钉死：
| 实例（同一 TU 内） | msM |
|---|---|
| shipped 调用形（`range<1>`，IGC 自选 ⇒ 本 TU 给 simd=16） | 2.4330 |
| 副本 **SG=4** | **2.0654** |
| 副本 **SG=8** | 2.0678 |
| 副本 SG=16 | 2.2776 |
| 副本 SG=32 | 2.2777 |
⇒ **同 TU 内，宽度 8/4 比 16/32 便宜 15%**（2.433 → 2.066）。这解释了"探针 simd=16 比 dll simd=8 慢"的一部分，但**解释不完**：dll 帧上反推 ≤1.07 ms，仍比探针最好的 2.07 快 ~2x ⇒ 剩下的差是大 TU 的 inlining/codegen，未定位。
⇒ 若宽度这条能在 dll 上兑现（需要 shipped 改动 = 施工，本铲不做），量级 = 该腿 −15% ⇒ 家族 **−1.3 ms/帧 串行**（0.16 ms/发 × 8），**不是大刀**。

## 10. 最终判决（交回四行的正式版，见 §7 的 ①②③④）
一句话：**18 发 = 31.7-32.2 ms 串行里，"算力"这条腿已经没有肉；剩下的肉在 (a) GA 的 6 次发射 + softmax 的 2.36M×8 次 elementwise 触点（只有融合能消），和 (b) WB 的 dtype（f16→int8，−5.9 ms，但要质量裁决）。**

## 11. 现场纪律（本铲复核）
- 只写 `E:\DSH\`：新件 `src/bench/sycl/wb_ga_probe.cpp`（untracked，未 commit/push；内含 softmax 的 **bench 局部副本** `smaxx::tiled_sg`，shipped 头一字未改）、
  `tools/xmx_f16_roof.csv`（新，untracked）、
  `E:\DSH\s6\{wbga.md, wb_ga_ops.csv, wb_ga_tops.csv, wbga_ops.py, wbga_tops.py, wbga_proj.py, spillcheck_wbga.py, WBGA_*.log/.err/.txt}`、
  台账解包 `E:\DSH\tmp\pc_wbga`、`E:\DSH\tmp\pc_wbga2`、空缓存 `E:\DSH\sycl-cache-wbga`。
- **shipped 三源零改动**：`git status --porcelain` = 只有 `?? src/bench/sycl/wb_ga_probe.cpp`、`?? tools/xmx_f16_roof.csv`
  （`M notes/DS-takeover-2026-11-01.md` = 父代理在写，本铲没碰过那个文件，只读过）。
- `out\libxmx.dll` = **E2D5E574**（3,772,928B，未动）、`out\libxmx_new.dll` = **460FC367**（3,813,376B，未动）、`oneapi\libxmx_sycl.dll` = E2D5E574（未动）。
- 跑前查过 LOP/game（无；只有 Steam++ 加速器，不占 GPU）；跑完不留进程；**临时 `_wbga.exe`（repo 与 oneapi 两份）已删**。
- 没接图、没跑 39 门、没 commit/push。


