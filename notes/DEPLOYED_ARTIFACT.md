# 当前出货件 provenance（唯一权威：`out/SHIPPED_MD5.txt`）

| 项 | 值 |
|---|---|
| **两槽 md5** | **`5EC0F5095C20CD7FD40519B41B758DDC`**（`out\libxmx.dll` = `oneapi\libxmx_sycl.dll`，3,348,480 B）= **`shf3a`（`imfnat3a`：只把 `*`/`+`/`-` 换原生，除法退回 `fdiv_rn`）** |
| **源码提交** | **`e2c447c`**；构建 `tools/build_shipped.ps1 -Tag shf3a`（父级从干净 HEAD 重建），走 `shipped_build.defs` 基座；日志 `E:\DSH\logs\build_shf3a.log` |
| **逐位性** | **四闸 4/4 逐字节 EXACT**：非 fused 1301 `DD49827D…`、fused 1301 `254C02B7…`、features `CACD2029…`、**result 回到 `DAC32974…`**（= 除法确实退回去了）；**门链 staged 口径 `40 GREEN / 0 RED`**（`[gate-selfcheck]` 两行齐、`syclcache_3a_staged` 新建）；**守卫：271 只共同核 `grf_count`/`simd_size`/`type: scratch`/SLM 参数差异全 0、`send.slm` 3,545 → 3,545** |
| **机制读数** | **全帧静态 371,492 → 279,463（−92,029 = −24.8%）；动态 468,002 → 375,970（−92,032 = −19.7%）**；内联 IMF 块 106 → 28；`goto` −21,951、`join` −13,662（**这一半收益里 39% 是软件块内部控制流塌掉**）；ESIMD `div_ieee` 那半一根没动（69 体 / 472 站点 / 动态 111,612） |
| **帧读数（诚实）** | **8 对 mean `+0.174 ms`、sd 0.314、2σ 0.629、B 赢 3/8 ⇒ 统计上中性**（**没赚到，也没证明亏**）；**A/B 本批都在 ≈46.2-46.4 ms**（**同一只 `AF5A19B3` 这批读 46.2、上一批读 49.8 ⇒ 热漂，绝对值不可跨批比**）；**⚠ 待复核：若后续批次再出现一致正 delta，就把它退回 `AF5A19B3`** |
| **上一件（回退位）** | **`builds\libxmx_shfimf1.dll` = `AF5A19B3…`**（源码 `92259ae`，**认证值 49.83 ms/帧**、16 对 −5.763、用户已实机验收）|
| **回退链** | `builds\libxmx_shfimf1.dll`（`AF5A19B3`）→ `builds\libxmx_shsm1.dll`（`F2364615`）→ `keep_pre_smax_A05A47AB.dll` → `keep_pre_com2_E0B03E90.dll` → `out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |
| **fused 三面基线** | `254C02B7… / CACD2029… / DAC32974…`（**未变**）⇒ 历史与复现命令见 **`tools/fused_face_baseline.md`** |
| **帧读数（认证）** | 出货 **16 对 −5.763 ms、16/16、sd 1.295（2σ=2.591，\|均值\|/2σ=2.2）**；A 侧 = `F2364615`（均值 55.59）⇒ **B 均值 49.83 ms/帧**（48.82-50.56）；**用户实机验收：画面没问题、帧数提高不少** |
| **门链** | **`40 GREEN / 0 RED`**（staged 口径、当场新建空缓存 `tmp\syclcache_cert_imf_2350`、带 `[gate-selfcheck]`）|
| **fused 三面基线** | `254C02B7… / CACD2029… / DAC32974…`；非 fused 1301 = 金标 `DD49827D…` ⇒ 全部历史与复现命令见 **`tools/fused_face_baseline.md`** |
| **回退链** | `builds\libxmx_shsm1.dll`（`F2364615…`，51.5）→ `builds\keep_pre_smax_A05A47AB.dll`（55.1）→ `builds\keep_pre_com2_E0B03E90.dll`（56.1）→ `out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |

## ★ 一次失败的转正（2026-11-08 04:0x-04:5x）：`imfnat3` 试上线后被自己数据否证并回退
- **件**：`builds\libxmx_imfnat3.dll` = `66FEC9313177446C192712118A02BA3B`（3,349,504 B，**−32,768 B**）；源码 `2744e7f`（`cosine_tree_kernel.hpp` 7/4、`post_kernel.hpp` 5/3、`quantize_row_kernel.hpp` 13/4）；
- **它砍掉的**：**全帧静态指令 371,492 → 244,152（−127,340 = −34.3%，本项目至今最大）**；内联 IMF 块 106 → 0、`fdiv_ladder` 561 → 69；`post_kernel` 10,423→989、`cosine_norm_i8` 9,221→1,080、`qr_kernel` 8,899→1,558；无新增 scratch；
- **它的代价**：**门链 28 GREEN / 12 RED**，且红因是**量化 scale 本身低 1 ULP**（`gate_quant_window: scales bits-equal=False`）与**倒数翻码**（`gate_vit_softmax: reciprocals bits-equal=False`）；
- **它的收益**：**出货 16 对 mean −0.049 ms、sd 0.240、B 赢 7/16、95% CI [−0.167, +0.068]**，**同批 A/A 对照 4 对 mean −0.018、max|d| 0.280** ⇒ **三条判读线全红 ⇒ 帧收益不成立**；
- **处置**：**04:5x 已回退到 `AF5A19B3`**（两槽 + `out/SHIPPED_MD5.txt` 已复算核对，三金标未动）；**`imfnat3` 件留在 `builds\` 当账**；
- **战略结论（入 §141）**：**第一把 IMF 刀（−5.763 ms、16/16）之后，"砍指令质量"这条路对帧时间已经饱和**；**下一把刀必须是结构性的（发射数 / 依赖链 / 相位串行），靶 = `window_block`（每闭包 1 发、1.799 ms、离地板 4.3-6.9×、占用已满 8 WG/片）与 `ffn_merge`（1 发、2.8-4.5×）**；**证据**：`gemm_window_int8_residual` 在 `imfnat2`（动过 pack）−0.410 vs `imfnat3`（没动 pack）−0.000 ⇒ **钱在发射/依赖侧**；
- **在途**：`imfnat3a`（只退除法、保留 `cr_hfma → cr_add(cr_mul)` 与 `cr_sub → a-b`）正在验四闸是否回到 `DAC32974…` 与逐实例码代；**它的帧收益预期 ≈ 0，staged 只为"少指令/少发热"，且必须逐位不变**。

## 门链口径与"红门"史（现状摘要，细节见 `tools/gates_caliber_notes.md`）
- **40 门链不覆盖 fused 三面**（军规 158）⇒ **改数值的刀必须靠 `tools/fused_face_baseline.md` 的基线与分桶 diff**；
- **`gate_graph` / `gate_skip_graph` 是 CWD 敏感门**（军规 147）⇒ **必须 staged 口径**；**注意 `imfnat2` 那轮观察到 `gate_graph` 在 scratch 口径也 GREEN ⇒ 旧断言未复现，只记账、未改门**；
- **20:09 那次 `6AEE1ADE` 的 5+9 fails 仍待复现**（候选：共享缓存旧 Gen、那次 shell 的 `NR_*` 泄漏）；**同源码不同构建三面一致**（军规 159）⇒ "构建差异"这条解释已排除；
- **仍然成立的语义事实**（探针，与门链读数无关）：**实机 composition 路与 3-leg 路在出货几何差 4.287% 字节 / 6.45% 像素**；**归一化倒数与残差融合形都被洗清，分叉在 composition 内部**；**用户已裁决：不要求对齐厂商**。
