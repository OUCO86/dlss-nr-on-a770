# fused 路三面基线（`tools/fused_face_baseline.md`）

**为什么要有这份文件**：40 门链**不覆盖 fused 路的三面**——我在 `logs/gate_graph.log`、`gate_coexist.log`、`gate_skip_graph.log`、`gate_ffn.log`、`gate_chain_qkv.log` 里 grep `ADC96F5D / 872C70D0 / CACD2029 / 254C02B7 / DAC32974` ⇒ **全部 0 命中**。
⇒ **门链只能证明"非 fused 整帧流（1301）与各族面不变"，不能证明 fused 路不变**（军规 145 的又一例）。**改数值的刀必须先取这份基线。**

## 基线 A（= 上线件 `AF5A19B3…`，源码 `92259ae`，2026-11-08 00:0x，cold 专用缓存 `tmp\syclcache_fbase_*`）——**已被下面"基线更新 04:0x"取代**
| 面 | 字节数 | md5 | 文件 |
|---|---|---|---|
| fused **1301** | 8,355,840 | **`254C02B73108E18FCF68221D4C6D530C`** | `E:\DSH\dumps\f.af5a19b3.1301.bin` |
| fused **features** | 16,711,680 | **`CACD202969C821D87CBDC033879CA7AB`** | `E:\DSH\dumps\f.af5a19b3.features.bin` |
| fused **result**（RGBA8）| 2,088,960 | **`DAC329740BFC8F96F61C3070D13FF1B6`** | `E:\DSH\dumps\f.af5a19b3.result.bin` |
| 非 fused **1301**（金标，未变）| 8,355,840 | `DD49827DD33A7EF07C2C17892F18970D` | `dumps\bk.1301.skip.bin` |

**历史值（IMF 刀之前，`F2364615` 谱系）**：features `CACD2029…`（**未变**）、fused 1301 `ADC96F5D…`（**变到 `254C02B7…`**）、result `872C70D0…`（**变到 `DAC32974…`**）。
**变化量（子代理 `s6/f2h_frame_diff.py`，自比对照全 0）**：fused 1301 **2,088,959 / 2,088,960 元素不同**（`|v|<6.104e-5` 桶 89、`[6.1e-5,1)` 桶 1,191,116（mean|d| 0.154、max 8.06、符号翻转 102,196）、`≥1` 桶 897,754（mean|d| 0.478）；result **85.1% 字节不同**（mean|Δ| 63/255、`|Δ|≥8` 1.31M、`≥32` 0.96M）；**无新 NaN/Inf、±0 符号类 0**。
**离线判官**：`db_meter` min corr **0.9805**（CORR-ONSCREEN-ACCEPT）、per-tile dB@range 最差 **35.36**、无 <30 dB 块、无成片色偏、结构保持率 min **0.973**、**corr_A 0.8737（A 通道必须实机看）**；`block_collapse` = **block-ok**。
**用户实机结论（2026-11-07 13:13）**：**"画面没问题，帧数提高不少"** ⇒ 接受上线。

## 复现命令（一条腿 ≈2 分钟，cold 专用缓存）
```
cd E:\DSH\oneapi
set SYCL_DEVICE_FILTER=level_zero:gpu
set SYCL_CACHE_PERSISTENT=1
set SYCL_CACHE_DIR=E:\DSH\tmp\syclcache_fbase_<HHmm>     # 必须当场新建（军规 148）
set NR_LCOUNT=1
set NR_DUMP_OUT=E:\DSH\dumps\f.<tag>
set NR_FUSED_SYNTH=1
nr_replay_now.exe E:\DSH\oneapi\libxmx_sycl.dll E:\DSH\out\plan_960x544.bin E:\DSH\out
```
**开关出处**：`libxmx_sycl.cpp` 的 `NR_DUMP_OUT` + `NR_FUSED_SYNTH`（fused 合成路），驱动写法见 `s6/pe_f2h_walks.ps1:43-47,52`。

## ★ 基线更新 2026-11-08 04:0x —— **当前上线件 = `imfnat3`（`66FEC9313177446C192712118A02BA3B`，3,349,504 B）**
| 面 | 新基线 md5 | 相对上一基线 |
|---|---|---|
| 非 fused **1301**（= 门链金标）| `DD49827DD33A7EF07C2C17892F18970D` | **未变 ✓** |
| fused **1301** | `254C02B73108E18FCF68221D4C6D530C` | **未变 ✓** |
| fused **features** | `CACD202969C821D87CBDC033879CA7AB` | **未变 ✓** |
| fused **result** | **`AE050ED1B1A5075BF41BCB93FD043298`** | **变了**（旧 `DAC32974…`）|
**变化量实测**（`s6/c51_decodecmp.py`，把 11+11+10 打包面解回浮点再比）：**121 / 2,088,960 字节不同（0.006%）⇒ 63 / 522,240 像素（0.0121%）、每像素恰好 1 个码步**；**R/G/B corr = 1.000000**、**dB@range 101.5 / 113.5 / 101.5**、`mean|d|/σ ≈ 0`、**新 NaN/Inf = 0**、**±0 = 0**；**控制腿（旧槽）三面全 EXACT ⇒ 环境可复现**。
**根因（军规 165）**：`cr_div` 从 `fdiv_rn` 换成 plain `/` ⇒ **在 Xe-HPG 上走 SFU 倒数 + 乘（1 ULP）**；**post 的 `ratio = model/proxy → shown*ratio → encode11/encode10` 落在量化步上 ⇒ 1 ULP 翻一个码**；`cr_sub → a-b` 与本次差异无关（两边 `sub` 计数都是 0）。
**上一基线（`imfnat1`/`F2364615` 谱系）**：`254C02B7… / CACD2029… / DAC32974…`，其变化量与判官读数见下文；**再往前（IMF 刀之前）**：fused 1301 `ADC96F5D…`、result `872C70D0…`。
**门链红名单（`imfnat2` 同族改动时实测 29 GREEN / 11 RED）**：`gate_unary`、`gate_chain_s1`、`gate_cosine`、`gate_qkv_qk`、`gate_cosine_i8`、`gate_chain_qkv`、`gate_gemm_f16_qkv_window`、`gate_window_block`、`gate_vit_softmax`、`gate_global_attention`、`gate_skip_graph`（最后一条在 scratch 口径是按设计的身份守卫红）。**`imfnat3` 的红名单由子代理用 staged 口径重测中；重定 golden 必须等用户实机结论，且要带 provenance。**

## ★ 一条顺带结论（否证了"构建不确定性会改数值"）
同一源码的**两只不同构建**（子代理 `libxmx_imfnat1.dll` = `9D69BDDB…`，12:43；父级正式件 `libxmx_shfimf1.dll` = `AF5A19B3…`，13:05）**三面 md5 完全一致**（`254C02B7 / CACD2029 / DAC32974`）
⇒ **icx/SYCL 构建差异不改数值** ⇒ **20:09 那次 `6AEE1ADE` 的门红与"同源码不同构建"无关**，回到"缓存态 / 口径"那条解释（军规 146/147/148）。
