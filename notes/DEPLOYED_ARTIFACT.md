# 当前出货件 provenance（唯一权威：`out/SHIPPED_MD5.txt`）

| 项 | 值 |
|---|---|
| **两槽 md5** | **`66FEC9313177446C192712118A02BA3B`**（`out\libxmx.dll` = `oneapi\libxmx_sycl.dll`，**3,349,504 B**）= **`imfnat3`** |
| **源码提交** | **`2744e7f`**（plain-SYCL 那半的 IMF 残量收割：`cosine_tree_kernel.hpp` 7/4、`post_kernel.hpp` 5/3、`quantize_row_kernel.hpp` 13/4）|
| **构建方式** | `tools/build_shipped.ps1 -Tag imfnat3`，走 `tools/shipped_build.defs` 基座；**由子代理在其工作树上构建，文件内容与 `2744e7f` 逐 blob 相同**；**⚠ 待做：父级从 HEAD 重建并复验三面（军规 159 证过同源码不同构建三面一致）** |
| **构建日志 / 产物** | `E:\DSH\logs\build_imfnat3.log`、`E:\DSH\builds\libxmx_imfnat3.dll` |
| **机制读数** | **全帧静态指令 371,492 → 244,152（−127,340 = −34.3%，本项目至今最大的一代码代降幅）**；**内联 IMF 块 `imf_nan` 106 → 0**、`fdiv_ladder` 561 → 69；`postpass::post_kernel` 10,423→989 与另一特化 9,330→1,173、`ctree::cosine_norm_i8` 9,221→1,080、`qr_kernel` 8,899→1,558；`call` 645 不变（ESIMD 那半已 byte-exact 还原）、`send.slm` +2、**无新增 scratch** |
| **画质读数** | **只动了 fused `result` 一面**：`121 / 2,088,960` 字节（0.006%）⇒ **63 / 522,240 像素（0.0121%）、每像素恰好 1 个码步**；**R/G/B corr = 1.000000**、**dB@range 101.5 / 113.5 / 101.5**、`mean|d|/σ ≈ 0`、**新 NaN/Inf = 0**、**±0 = 0**；**⇒ 待用户实机确认**（军规 156）|
| **门链** | **`imfnat3` 的 staged 口径红名单重测中**；同族改动的 `imfnat2` 实测 **29 GREEN / 11 RED**（红的全是面比较类门，见 `tools/fused_face_baseline.md`）；**golden 重定必须等用户结论 + provenance** |
| **帧读数** | **上一件 `AF5A19B3` 的认证值 = 49.83 ms/帧**（16 对 −5.763、16/16、sd 1.295）；**`imfnat3` 的腿级与 16 对正在跑**（A = `builds\libxmx_shfimf1.dll`）|
| **回退链** | **`builds\libxmx_shfimf1.dll`（`AF5A19B3…`，49.83 ms/帧）** → `builds\libxmx_shsm1.dll`（`F2364615…`，51.5）→ `builds\keep_pre_smax_A05A47AB.dll`（55.1）→ `builds\keep_pre_com2_E0B03E90.dll`（56.1）→ `out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`（**本刀逐字节未变**）；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |
| **fused 三面基线（新）** | `254C02B7… / CACD2029… / AE050ED1B1A5075BF41BCB93FD043298`（旧 result `DAC32974…` 已被取代）⇒ 全部历史与复现命令见 **`tools/fused_face_baseline.md`** |

## 已知偏差（每次转正必须消掉）
- **本次转正的构建来源是子代理工作树**（内容 = `2744e7f`，逐 blob 已核）⇒ **待父级从 HEAD 干净重建并复验三面**（`DD49827D…` 非 fused、`254C02B7…` fused 1301、`CACD2029…` features、`AE050ED1…` result）；**复验通过前，任何 A/B 的 A 侧一律用实体件**（`builds\libxmx_shfimf1.dll`），**不许拿"HEAD 重建件"冒充 A**。
- **下一次转正照旧**：从 HEAD 重建 → cold 帧面四闸 → 门链带 `[gate-selfcheck]` 两行（加载 dll 路径 + md5、`SYCL_CACHE_DIR`）→ 出货 16 对 + 同批 4 对对照 → 更新本文件。

## 门链口径与"红门"史（现状摘要，细节见 `tools/gates_caliber_notes.md`）
- **40 门链不覆盖 fused 三面**（军规 158）⇒ **改数值的刀必须靠 `tools/fused_face_baseline.md` 的基线与分桶 diff**；
- **`gate_graph` / `gate_skip_graph` 是 CWD 敏感门**（军规 147）⇒ **必须 staged 口径**；**本轮子代理又观察到 `gate_graph` 在 scratch 口径也 GREEN ⇒ 旧断言未复现，只记账、未改门**；
- **20:09 那次 `6AEE1ADE` 的 5+9 fails 仍待复现**（候选：共享缓存旧 Gen、那次 shell 的 `NR_*` 泄漏）；**同源码不同构建三面一致**（军规 159）⇒ "构建差异"这条解释已排除；
- **仍然成立的语义事实**（来自探针，与门链读数无关）：**实机 composition 路与 3-leg 路在出货几何差 4.287% 字节 / 6.45% 像素**；**归一化倒数与残差融合形都被洗清，分叉在 composition 内部**；**用户已裁决：不要求对齐厂商**。
