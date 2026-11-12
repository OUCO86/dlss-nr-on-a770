# C46 · 71 层逐层对表 + S6 块驻留资源闸门 + 第一把骨架探针方案（2026-11-12 11:0x，**零 GPU**）

**靶（钉死，`tools/target_check.py` 判定行原样见 §133.1）**：lmxx 3080L **路线 A = 71 层完整模型 / 每帧 35 核**；实测 111.300 ms @2.21 Mpx ⇒ **等像素 @544p = 26.3 ms**、**带宽归一 = 20.6 ms**、第一战役目标 **20 ms**、同等融合深度物理地板 **11 ms**。我们 42.15（fused 含复用）/46.26（不开）⇒ **对靶 1.60×、对带宽归一 2.05×、对 20 ms 目标 2.11×**；**判定行：比过 3080L 路线 A（等像素）? NO；破 20 ms? NO；破前辈 47.19? YES**。
**禁止当靶**：31-block Small（5.62/8.38/11.07）；9070XT hip-port 10.4 ms（fp8 + 3.7× 带宽）。

## A. 逐层对表（CSV 同步件 `tools/L71_vs_lmxx.csv`）
腿 ms 取 `logs/C26_mstlgt_run_timing.txt`（fused，C18 基线之后）与 `logs/C30_rt_p_run_timing.txt`（plain）；闭包按 `tools/chain_map.csv` 的 `(tier, C, closure_first..last)` 归层；MB 取 C39 在现役件上的 hop 普查（`rt_f2`）。

| lmxx 类（35 核里的） | 发数 | @544p 等效 ms | 我们的对应层（闭包数） | fused 腿 ms | plain 腿 ms | MB/帧 | **比值** |
|---|---|---|---|---|---|---|---|
| `c64_wave2_bi_bo/bi/bi_ho/up_lb_sh` | 10 | **3.50** | **C64 层 8 条链（86 闭包）** | 10.416 | 9.622 | 3,858 | **2.98×** |
| `c128_wave2_bi_bo/up_lb_sh/bi_ho` | 13 | **3.93** | **C128 层 12 条链（136）** | 18.249 | 17.440 | 5,899 | **4.64×** |
| `c256_wave2_bi_bo/bi` + **`sp_run256_w16`（persistent）** | 9 | **4.78** | **C256 层 16 条链（169）** | 27.490 | 25.033 | 7,654 | **5.75×** |
| `c512_qkv_attention_compact_w16` | 16 | **1.09** | **C512 层 16 条链（193）** | 31.299 | （plain 列失真，见注） | 7,859 | **19.6×** |
| `mh_attention_project_*` + `mh_pool_project_*`（DevHistory §4.3/4.4：单发 **0.077-0.216 ms@1080p**，共 ~31 发） | ~31 | **~0.63** | **`window_block` 10 闭包**（pool 8160w / head 8349w / 8 兄弟） | 12.751 | 12.687 | 794 | **~20×** | 1267/1303/1266/1270/1240-1262 | 他们 `mh_pool_project_c32_b8_out8` grid 34560/block32/**regs 44**/SMem 0；`_group_c512_out8_f8w16` grid **40**/block 512/regs 121/SMem 8,320；`_group_c64` grid 2160/SMem 1,152 ⇒ **C512 的 pool 只发 40 组、SMem 8 KB（不是两块 64×512 f16）** |
| `vit_stream_qkv/contract/project` + `vit_expand_blocked` + `vit_attention_fused` + `split_ffn_one` + `split_projection` + `decoder_project2x` + `vit_gather` | ~58 | **~4.9** | **ViT 段**（`global_attention` 8 + `ffn` 8 + `ffn_stem` 1 + `ffn_merge` 1 + `gemm_int8` 8 + ViT 侧 qkv 8） | ~16.5（notes 记 13.94 为窄口径） | ~15.4 | ~2,600 | **~3.4×**（notes 口径 2.8×） |
| `c32_wave1_prefix/post/chain/up/finish/mapped` | 9 | **7.5** | **全分辨率段**（`pre` 2 + `unary` 16 + `unary2` 1 + `quant(FUSED-pack)` 144 + `gemm(f16)` 42 的一部分） | ~25（跨层混杂，归组不精确） | — | ~5,000 | **~3.3×** |
| **合计** | **35** | **26.3** | **693 闭包** | 串行 **117.434** / 帧 **42.15** | 121.9 / 36.71 | 30,848 | **帧 1.60×** |
**归一假设（写死）**：① 像素因子 **4.23**（2.21 Mpx → 0.522 Mpx）按**线性**折算 ⇒ 对 token 数正比的类（C64/C128/C256/C512 wave2、ViT、split_ffn）成立；② **非线性的类**：`c32_wave1_*`（全分辨率、与输入图像尺寸直接挂钩，且他们把上采样折进下一块首层 ⇒ 折算只近似线性）、`mh_pool_project_*`/`mh_attention_project_*`（grid 与 pool/head 尺寸相关：我们 pool 8160 窗 / head 8349 窗 vs 他们 1080 grid ⇒ 比例约 7.6×，不是 4.23×）、`sp_run256`（persistent：grid 893 固定，**不随分辨率线性**）；③ 串行腿 ms ≠ 帧 wall：重叠吃掉 ~55%（§六.二十八：串行 149 vs 帧 67）⇒ **本表的"×倍"是形态/工作量对比，不是帧时对比**；帧对比只用 target_check 的 1.60×/2.05×/2.11×。
**最贵五类（按绝对超额腿 ms，串行口径）**：**① C512 层 +29.7；② C256 层 +22.7；③ C128 层 +14.3；④ ViT 段 +11.6；⑤ window_block +10.7**（C64 +6.9 居六）。
**结构缺口（不是速度缺口）**：`sp_run256_w16` 那 3.60 ms 是**用 2 发 persistent 吃掉整个 C256 层** ⇒ 我们**没有 persistent stage 这一形**（§六.十五 SLICE 史）；`c512_qkv_attention_compact` 是 **16 发做完整层注意力**，我们 193 发做同层 ⇒ 缺口 = **块驻留**。

## B. S6 块驻留的资源闸门算术（**这一节是战役能不能干的先决条件**）
lmxx 形态：一块一 megakernel，块内五阶段（FFN contract → feature-scale → QKV → attention → out-proj + diag residual）**全在 LDS 两块 64×C plane 交替**里 ⇒ **我们的等价需求 = 2 × 64 token × C × 元素字节 ≤ 65,536 B/每 WG**（§58 实测：65,536 是 **per-WG cap、不是每片池**），且 **grf ≤128/线程**（军规 182）、**scratch = 0**。
| 类 | 他 SMem | 我们 f16 两块 64×C 需 SLM | 我们 int8 两块需 SLM | **判定** |
|---|---|---|---|---|
| C32 wave1 | 10,240 | 8,192 | 4,096 | ✅ **装得下**（余量 57 KB） |
| C64 wave2 | 12,288 | 16,384 | 8,192 | ✅ **装得下**（现役 v4full 已在 45-56 KB 桶跑通 ⇒ 加 skip 流水也够） |
| C128 wave2 | 24,576 | 32,768 | 16,384 | ✅ **装得下，且有余量放权重 tile/skip** ⇒ **首选试验层** |
| C256 wave2 | 49,152 | 65,536 = **顶格**（无余量） | 32,768 ✅ | ⚠ **f16 装不下（0 余量）⇒ 必须 int8 staging 或 32-token 子块（32,768 f16）** |
| C512（qkv+attention compact） | 6,144（他们只放压缩 tile，plane 走 int8/fp8） | 131,072 ✗ **2.0× 超** | 65,536 = 顶格 ✗ 无余量 | ⚠ **必须 token 子集 32（int8 = 32,768 ✅）** ⇒ 但 **token 半宽 = dpas 半宽 tile 效率损失**（slice2 已实测这一代价 ⇒ 必须先算净账） |
| `sp_run256` persistent | 49,152 + **LMem 576** + **Regs 255** | 同上（C256） | 同上 | ❌ **不可行**：他用 240-255 regs + LMem spill 做 persistent 循环；**我们 grf 上限 128、scratch 必须 0 ⇒ 缺口 1.9-2.6× regs 且没有 LMem 等价物**（DG2 的 private/scratch 非零 = 当场判死，军规 182）⇒ **persistent 这一形不照搬；改用"一块一核、非 persistent"** |
**GRF 侧（每线程 128 GRF ≈ 4 KB/线程，§六.三十 的 s8v8 账：NT32 + 8 累加器 = 4 KB/线程）**：块 plane 绝不能进 GRF（C=128 f16 ⇒ 每线程 256 B 勉强、C=256 ⇒ 512 B、C=512 ⇒ 1 KB，再叠累加器 + B 操作数 + 地址 ⇒ 必炸）⇒ **正解与 lmxx 一致：plane 驻 SLM、只有 A/B tile 与累加器进 GRF**；且 §六.十八 已证 **s8v8 每 kb 每 subgroup SLM 读 32 KB vs unique 6 KB = 5.3× 读放大** ⇒ **块驻留会把 SLM 带宽压力再放大 ⇒ 必须同时做 GRF 常驻 B 操作数（A3），否则驻留换来的字节节省会被 SLM 读取代价吃掉**（这条是本战役的第二个闸门，写死）。
**并行度闸门（SLICE 1/2/B6 的死因，必须列）**：一块一核 ⇒ WG 数 = 该层 block 数。C128 层 12 链的 split 链现有 WG ≈ 768(qres) + 1020(wa) + 255×(gir/batched/wres)；**融合核必须 ≥ 1,020 WG**（slice1 只有 510-558 fat WG ⇒ 帧 +0.5；slice2 修到 1020-1116 仍 +1.5，因为 BN=32 半宽 dpas ⇒ **两把刀都负 = 半宽损失 > 省下的往返**）⇒ **C128 的 f16/int8 满宽（BN=64）+ 32,768 B SLM 有余量 ⇒ 是唯一"既满宽又装得下"的层 ⇒ 这就是试验层选择理由**。

## C. 第一把骨架探针（**先不建，方案交回**）
- **选哪一块**：**C128 层的一条链**（12 链之一；`chain_map.csv` tier=C128、C=128、M_att=35712/32640、op_seq = `QUANT_WINDOW, GEMM_INT8_QKV, WINDOW_ATTENTION, QUANT, GEMM_WINDOW_INT8_RESIDUAL, QUANT, GEMM_INT8_BATCHED, QUANT, GEMM_INT8_BATCHED, QUANT, GEMM_INT8_RESIDUAL` = **11 只闭包 / 链**）。
- **为什么是它**：① 绝对超额第三大（+14.3 ms 串行，整层）；② **闸门全绿**：f16 两块 plane 32,768 B ⇒ SLM 余量 32 KB；**可保 BN=64 满宽 dpas**（避开 slice2 的半宽死因）；③ 并行度可对齐 split（12 链 × 每链的 block 数 ≥1,020 WG，用 §六.十五 SLICE 2 定案的 (window, head) batch 语义）；④ 现役件上该层的 touched MB 与 hop 面全部已知 ⇒ **省多少可以当场算，不用猜**。
- **ARM0（现形）**：一条链的 11 只闭包照 split 链跑（含 `1272` pk scratch、`1274/1275/1276` QKV plane、`1277` merged、`1270` outproj 面 ⇒ 全部过 DRAM）；**ARM1（块驻留）**：一核吃完整链，五阶段中间量**只在 SLM**（pk 不落 1272、QKV 不落 1274/75/76、merged 不落 1277），**只有 skip 读 1267 一次 + 写 1267 一次**（块边界）。
- **对拍基准**：照 `bench_lfw`/`bench_lfw2`/`bench_b6` 的仪器纪律（**planes + Out 两帧形状 8/8 EXACT 才算几何对**；`bench_b6` 已 12/12 EXACT ⇒ 复用其 reference 链 = 现链 wa+quant+outproj+residual 四件套）；**判官哈希全部输入面**（军规 192）+ **in_order**（190）+ 30 s 自检（冻结输入 ×3 nbad=0、0xAA 预填无洞）。
- **门槛**：**≥25% 才建件**（军规 8/174/203）；该链现役腿 ≈1.52 ms ⇒ 门槛 = **每链省 ≥0.38 ms**。
- **预期省（先算再建，军规 203）**：C128 层 12 链总 hop = **5,899 MB/帧**；链内中间面（1272 的 8.9 GB 里属 C128 的份额 + 1274/75/76 的 102.5+266.8 归属份额）≈ **2.6-3.4 GB/帧** ⇒ 按 560 GB/s 实测屋顶 = **4.6-6.1 ms/帧（12 链）** ⇒ **每链 0.38-0.51 ms ⇒ 正好压在 25% 线上** ⇒ **探针必做，不做不知道**；但注意 target_check 的大账：**1267 从 26.7 GB → 4.8 GB = 屋顶 47.7 → 8.6 ms** ⇒ **只有把 1267 的 ping-pong 也消掉才是大刀本体**。
- **★ B6-1 为什么白消（新方案不得重犯）**：B6-1 只把 5 个 split op 串成一核、**plane 照写** ⇒ 消的全是 **L2 已吸收的小面（1277/1272/1270）**，而 **1267 大面原样进出 DRAM** ⇒ 省 0.7 GB/16 层（1.3 ms）付不起链延迟（+2.4 ms）⇒ **本次 ARM1 的验收硬条件：1267 的中间量不落 global（每块 1 读 1 写），且必须报"消掉的 MB 里有多少是 1267/1274 大面"**，否则就是重犯。
- **GPU 预算**：1 次编译 + 3 冷进程（bench 件，非引擎腿）≈ **5-8 min ≤ 15** ✓；ocloc 当场看 `grf≤128 / scratch=0 / SLM≤65,536`（超了当场判死）。
- **开工前必过归档坑名单**：`wa_res` 头注释 **WA_KT 2KB sizing OVERLAPPED QT = 半行错**；§96 **plain 核里 SLM-fed dpas 静默归零 ⇒ 只有 ESIMD `nd_range` + global scratch + group_barrier 安全**（注意：这与 scratch=0 冲突 ⇒ 块驻留核必须走 **ESIMD + SLM 常驻** 的已证安全类，即 v4full/wa_res/lfw2 同族，并复算 SLM 读放大 5.3× 这一条）；`select<N,1>(k)` 先问 k 是偏移还是块号；任何塞进核的运行时诊断分支必须同二进制带/不带对照（§六.二十九 探针污染案）。
