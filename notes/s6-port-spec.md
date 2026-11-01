# 移植规格（用户 2026-11-01 12:1x 定的新原则）

## 0. 原则（写死，覆盖我此前"移植机制不移植代码"的做法）
**完整机制移植**：以他们的核为**唯一蓝本**，**最小改动他们的核心**；**我们的链路去满足他们的核的要求**（喂它要的布局/几何/数据通路），
而不是把他们的核改造成我们现在这个样子。
**只允许改两类**：① **数据类型适配**（e4m3 网格 → 我们的 int8+scale 网格；fp8 硬件依赖 → int8 原生 dpas）；
② **对我们无用或有害的内容**（硬件做不到的原语、会撞我们占用崖/死锁区的几何参数）——**且每一处都必须单独列名+给理由+留证**，不许静默改。
**先备份再移植**（备份清单见 §6）。
军规候补第 17 条即此原则。

## 1. 第一铲选哪个核（按"可移植性"实测筛过）
grep 全 `shaders/dx12-network/` 的 sub-group 原语使用：
- **`native_wave_ffn_fused.hlsl`（101 行，Swin FFN expand+contract 一发）= 零 shuffle、零 wave 内交换**，只用 wave-scope 矩阵 + LDS + 1 个 barrier ⇒ **最可忠实移植**，而且它正是我们已经融过的那条链（同一形状族）。
- **不可忠实移植（依赖 `WaveReadLaneAt`/`WaveActiveSum`，我们工具链没有该原语，grep esimd::shuffle=0 已证）**：
  `native_c32_ffn_fused.hlsli`(:67-78)、`native_wave_c32_ffn_blocked.hlsl`(:180-240)、
  `native_wave_attention_direct.hlsl`(:56-204)、`native_wave_c32_split_attention.hlsl`(:238-820)、`native_wave_vit_attention_half.hlsl`(:50-67)。
  ⇒ 这五个**先不碰**；要移植它们必须另找 SLM 等价实现，那属于"改核心"，违反本原则，需单独批准。

## 2. 他们的核要求什么（我们必须供上的东西，逐条）
读 `native_wave_ffn_fused.hlsl` 得出的硬要求：

| # | 他们的核的要求（代码位置） | 我们链路必须供上的东西 |
|---|---|---|
| R1 | **A 直接从 global 按 fragment 序载入**：`A::Load(input, gid.x*16*MATRIX_CHANNELS + g*32, MATRIX_CHANNELS, RowMajor, 16)`（:56） | 面必须是 **token×channel 行主序、channel stride = C**，且 **16 token 一组连续**；⇒ **生产者的 store 必须按此布局直写**（= B7 布局原生），**运行期不许再有 pack 趟** |
| R2 | **权重预铺**：`NATIVE_TILED_WEIGHTS` 下 `B::Load(weights, ((col/16)*(C/32)+g)*512, 16, RowMajor, 16)`（:60/:85） | init 期把权重 blob 一次性铺成 **512B fragment 块**（跨帧不变，不是每帧功） |
| R3 | **hidden 只在 LDS**：`groupshared uint hidden[16*HIDDEN/4]`（=16×4C 字节），注释 "The 4C-wide hidden tensor never touches VRAM"（:47-48） | 块内 **不许生成 global hidden 面**；我们的 1274/1275 面在这条链上必须消失（只保留块边界 1267/1270） |
| R4 | **量化在累加器寄存器内完成再落 LDS**：`acc.Set(Activate(...))` → `acc.Cast<OPERAND>().Store(hidden, ...)`（:71-75） | 我们对应物：`pub_vec_v8` 之后 **直接落 int8+scale 到 SLM**；**P3 requant 相整相消失** |
| R5 | **两相之间一次 barrier**：`GroupMemoryBarrierWithGroupSync()`（:78） | ESIMD `group::barrier(sycl::fence_option::CTA)`；**不许有条件绕过 barrier**（正案：early-return-before-barrier = HANG） |
| R6 | **K 步进 = 32**（A 16×32 / B 32×16，`for g < C/32`）（:44-45,:55） | 与 XMX `dpas<8,8,32>` 的 K=32 原生一致（`hw-coopmat`：int8 8×8×32）⇒ **天然对齐，不用改** |
| R7 | **几何 cull**：`if(gid.x*16 >= width*height) return;`（:51） | 我们的 plan 是 window-major（M=510×64 等）⇒ **token 序必须映射成他们的线性 image 序**，或按他们的 cull 语义重排 grid（这是"链路满足核"的核心动作之一） |
| R8 | **wave 数 = C/16**、`numthreads(32*WAVES)`（:15,:49-50） | 见 §3-D1（硬件冲突项） |

## 3. 只允许的两类改动（逐条列名，不许静默）
**T 类 = 数据类型适配（允许，因为这是唯一"他们硬件比我们有优势"的点，且我们占优）**
- T1 `OPERAND = F8_E4M3FN`（:19）→ **int8 + 独立 scale 数组**（plan 语义）。`Ffast()`（:29，软件 e4m3 RNE）**不搬**，换成我们已 golden 锁定的 int8 量化链（`fdiv_rn` + 行峰，照 `quantize_row_kernel.hpp`）。
  ⇒ 连带要求：消费者 gemm 的 **scale 乘法留在 epilogue**（我们现在已有 `a_scale/b_scale`，不新增功）。
- T2 `H()`（:25-27 软件 f16 RNE）→ 我们已有等价物（publish 的 f16 舍入），**语义必须逐位对齐**（这是 golden 判据之一）。
- T3 `dx::linalg` wave-scope MMA（:44-46，且他们为了 3080L 自己 fork 了 LLVM：`Development/tools/llvm-fork`、`llvm-patch1`）→ **ESIMD `dpas<8,8,32>`**，fragment 顺序必须与 R1/R2 的 load 意图一致。

**D 类 = 对我们有害/做不到（允许，但必须留证）**
- D1 **线程几何**：他们 `WaveSize(32)` + `numthreads(32*WAVES)`，C=256 ⇒ **512 线程/组**。
  我们正案：**前辈 256 线程/WG 的 coopmat 配型在 ESIMD 下直接 HANG**（§100 P1 / bench_v2crash），
  且 `LW>=128 + barrier` 是死锁区、`LW=64×2040 windows` 是验证过的安全区；本机 `max_work_group_size=1024`（我实测）。
  ⇒ 第一铲按 **C=256 档用 256 线程/组（8 waves）**、C=64 档用 64 线程，**先跑一个 barrier 存活探针**再定；偏离他们的原值必须写在这里，不许改核内注释了事。
- D2 **SLM/占用崖**：他们 `hidden` LDS = 16×4C B：C=256 ⇒ **16KB**（✓ 我们 64KB 帽内、且 <32KB 占用崖）；
  他们的 c256/c512 用 49152B smem（OccW 1）——我们 >32KB 会掉 resident WG ⇒ **那些档要按我们的占用崖重排 tile**，属 D 类，逐条列。
- D3 **sub-group 原语缺失**：见 §1 末——依赖 shuffle 的五个核**本轮不移植**。

## 4. 判据（不许挪）
1. **入场券**：与现路逐字节对拍。注意 **T1 改了网格 ⇒ 不许拿"和现路逐位同"当唯一判据**：
   必须同时过 **numpy golden 考古**（军规 2：改数值形态先过 golden），golden 不过 ⇒ 就地死刑，不许用"误差差不多"糊过去。
2. **单价**：三形状独立进程（军规 16）、min-of-15×5 组、msM、**每相位加 sink 防 DCE**（军规 15）。
   对照 = S6-1a 已验融合链：S1 0.4647 / S2 0.3787 / S3 0.3660；现路 = 0.8139 / 0.5898 / 0.4277。
   **目标：链 wall ≤ 0.30 / 0.25 / 0.24**（R1+R2 消 pack 0.308ms/链、R4 消 P3 0.181ms/链、D1 提占用）。
3. **上限对照**：若三档达成 ⇒ 全帧 52 链折算应到 **−20ms 级串行**；若达不到 −10ms，说明我对他们布局的收益判断错，立刻改路线并公开更正。
4. 帧级：接 cgraph 后走 39 门 + walk 1301 + **48 对**（env 只在 B 侧）。

## 5. 施工顺序（一次一个代理）
① `#1 S6-1a 接 cgraph`（**在跑**，交帧级真数）
② `#2 本移植试验`：先只移植 `native_wave_ffn_fused.hlsl` 一个核 → R1/R2/R3/R4 全供上 → golden + 单价 → 达标才接 cgraph
③ `#3 形状合并`（Track 2，把 32640 那三发并宽）
④ 再回头处理 §1 那五个依赖 shuffle 的核（需要单独批准，因为那是"改核心"）

## 6. 备份（移植前必做，已执行/待执行都标）
- `E:\DSH\backup\pre-port-2026-11-01\src\` = 当前 shipped 全部源文件（`libxmx_sycl.cpp`、`gemm_s8_v8_kernel.hpp`、`pack_device.hpp`、`quantize_row_kernel.hpp`、`qk_norm_chain.hpp`、`ffn_chip_kernel.hpp`、`qkv_resident.hpp`、`b6_res_kernel.hpp`、`wa_res_kernel.hpp`、`gemm_f16_v1_kernel.hpp`、`window_block_v4_kernel.hpp`）
- `E:\DSH\backup\pre-port-2026-11-01\dll\` = `libxmx.dll`(B8908BD2 部署件) + `libxmx_new.dll`(当前过关件) + `md5.txt`
- 另存：`E:\DSH\backup\pre-port-2026-11-01\lmxx_src_ref\` = 被移植的那个核原文（101 行）+ 它的 `dx/linalg.h` 依赖说明，**移植对照用**
- 回退 = 整目录 copy 回，不需要想。
