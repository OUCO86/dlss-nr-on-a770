# 混合链规格（S6-1a → 下一铲；用户 2026-11-01 18:4x 说"排"，落盘防上下文压缩丢尾巴）

## 0. 为什么是"混合"而不是"整体换移植核"（实测依据，§24/§26）
分相对账（同一 1.0695 GFLOP/链的 op，S1/S2）：

| 相 | K 深度 | 1a TOPS | 移植核 TOPS | 判决 |
|---|---|---|---|---|
| P1 quant | — | 0.0316 ms | — | **保留 1a** |
| **P2 expand** | **K=64（浅）** | **24.4 / 30.2** | 5.49 / 5.33 | **保留 1a（我们赢 4.4 倍）** |
| **P3 requant** | elementwise | **0.2182 / 0.2091 ms** | requant 0.295 ms | **1a 更便宜，但两趟结构要改（见 M2）** |
| **P4 contract/proj** | **K=256/512（深）** | 28.0 | **39.6 / ≥55** | **换成移植核形态（赢 1.4-2 倍）** |
| P5 outquant | elementwise | 0.0600 / 0.0186 ms | — | 保留 |
| P6 res | K=64 | 4.10 | 4.05 | 平，保留 |
| 台账 | | **private/spill/scratch = 0** | **private 3328/6464B + scratch 61/182** | 移植核有工程缺陷要修（M3） |

链口径现状：**1a = 0.4647 / 0.3787**；移植核最好档 = 0.6019 / 0.4210；现路 split = 0.8139 / 0.5898。
elementwise 占 1a 链 **73.2% / 70.0%** ⇒ 主战场是 P3，不是矩阵相。

## 1. 三处改动（按顺序做，每处都要过 diff=0）
- **M1 = P4 换成移植核的 contract 形态**
  来源 VERBATIM：`src/bench/sycl/port_ffn_fused.cpp` 的 PHASE4（行号见 `notes/port-B.md` R4 段：SLM int8 当 A、B 预铺 512B fragment 块、scale 在 epilogue 乘）。
  目标：**P4 0.0382 → ~0.027 ms（S1）**、S2 进入 ≥55 TOPS 区。
  禁区：**不许动 P1/P2**（我们在浅 K 上赢他们 4.4 倍，混进去就是自伤）。
- **M2 = 把 T1a 的"整行行峰"折进 P2 的 epilogue**
  做法：每个 wave 算完自己那 64 列 hidden tile 后，在寄存器内先取局部行峰，再 **对 SLM 里该行的 4 个槽做 `max`**（`float max` 满足结合/交换 ⇒ 位同），P3 于是**只剩一趟 encode**，不再有"先扫全行求峰、再扫全行量化"的两趟结构。
  目标：**P3 0.218 → ~0.13-0.15 ms（S1）**、S2 0.209 → ~0.13。
  硬要求：SLM 槽数 = 每行 `HID/64` 个（S1=4、S2=8），**不许加 global 面、不许加 launch**。
- **M3 = 台账红线：混合后 `private/spill/scratch` 必须保持 0**
  用 `src/bench/sycl/spillcheck_port.py`（JIT 缓存路）逐档出 `grf/private/spill/scratch/slm_size`；
  若 M1 把移植核的 private 3328/6464B 带进来 ⇒ **先修再谈性能**（累加器压力：每 wave 4 个 16×16 tile、grf 已顶格 128 ⇒ 减活 simd 数量或拆相）。

## 2. 判据与协议（不许挪）
1. **入场券**：与现 1a 链 **13 检查点逐字节 diff=0**（S1/S2；检查点清单照 `notes/port-B.md`：pk1/sc1/e4m3-enc/e4m3-dec/hid-f16/pk2-slm/pk2-frag/sc2/out-1275/pk3/pk3-frag/sc3/**1267-FINAL**）。不绿就停，**不许放宽对拍**。
2. **单价协议**：每形状**独立进程**（军规 16）、**主数一律 nosink**（军规 19：grf 顶格核里加宽 sink 会让链 +65%，1a 上 4-lane 也要 +13.7%）、min-of-15×5 组、组间 60ms、报 msM/msm/msX/med；
   **<0.05ms 的相禁用截断相减定绝对值**（军规 20：cum(P3) 抖 0.2590→0.2968 会把 P4 减出 0.0005ms = 2049 TOPS 荒谬值）⇒ 相位只给区间或只比 cum。
3. **目标**：链 wall **S1 ≤ 0.33 / S2 ≤ 0.30**（= 每链 −0.13 / −0.08）。
4. **帧口径预估（只当预估，不当结论）**：20 链/帧 × −0.105 ≈ **−2.1 ms 串行**…按 55% 存活 ⇒ **帧 −1.2~−1.6 ms**；若 M2 的 P3 削到位可到 **帧 −2~−3 ms**。

## 3. 接线（M1-M3 全绿之后才做）
复用**已出货的 `NR_S6_FFN` 状态机**（`libxmx_sycl.cpp:503-712`，六发邻接 QUANT→BATCHED→QUANT→BATCHED→QUANT→RESIDUAL，gap≤4，六发全动或全不动），**只换核体**：`s6_ffn_block_kernel.hpp` 里 P4 的实现与 P2/P3 的衔接 ⇒ 不动邻接逻辑、不动 guard、不动权重 WKey。
三关：39 门（默认侧 + `NR_S6_FFN=0` 逃生侧各一遍）→ walk **1301 EXACT**（金标 `249A46F374E9…`）+ passes 691 → 确定性两遍 → **16 对**（A=`out\libxmx.dll` E2D5E574 现出货件，B=新件；env 两侧都不设，靠二进制差异）。
**注意 A 侧基线已经换件**：从今往后帧夹逼的 A = **E2D5E574（含 1a）**，不再用 B8908BD2，否则会把已吃到的 −3.0ms 重复计一遍。

## 4. 队列（一次一个代理，用户规矩）
1. **S6-1b 可行性探针**（`4785a92d…` 正在跑）：整块 SLM 预算 + stub 实测 64/16 token 两档并发与代价；顺带把 C2 的 13 检查点门补绿（D2H 换 `malloc_host`/`q.copy`——OOM 定性数：失败点仍能单块分配 1074MB，失败请求 2.09MB ⇒ 不是设备字节预算，是 host-pinned/staging 配额）。
2. **本规格（混合链 M1/M2/M3）** ← 探针一交数就开。
3. **S6-1b 整块融合（11 发 → 2 发）**：其余 10 发块内驻留，**attention 仍单独一发**（他们家 attention 核全依赖 `WaveReadLaneAt/WaveActiveSum`，我们无该原语 ⇒ 按"完整机制移植"原则不能忠实搬，要用 SLM 造等价交换需单独批准）。锁在边界里的 **3.70 ms/帧串行（帧 −2.0ms）** 与 R1 的兑现都在这一铲。
4. **其他核移植**（零 shuffle 那一族优先）：`native_wave_c64/c128/c256_wave2_bi_bo`、`split_ffn_one_w2f8_w16`、`native_wave_ffn_proj0_fused`；依赖 shuffle 的五个（`native_c32_ffn_fused.hlsli`、`native_wave_c32_ffn_blocked`、`native_wave_attention_direct`、`native_wave_c32_split_attention`、`native_wave_vit_attention_half`）排最后。

## 5. 出货件与回滚（别弄丢）
- 游戏加载位 = `E:\DSH\out\libxmx.dll` = **E2D5E574…**（1a 已转正、用户实机验收过画面+变快）；旧基线留 `libxmx_B8908BD2.dll.keep`；台账 `out\DEPLOY.md5.txt`。
- 备份 = `E:\DSH\backup\pre-port-2026-11-01\`（含被移植核原文），**不许覆盖**。
- 回滚 = 一条 copy（`.keep → libxmx.dll`）或游戏侧 `NR_S6_FFN=0`。
