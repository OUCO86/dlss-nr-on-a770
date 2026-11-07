# 当前出货件 provenance（唯一权威：`out/SHIPPED_MD5.txt`）

| 项 | 值 |
|---|---|
| **两槽 md5** | **`66FEC9313177446C192712118A02BA3B`**（`out\libxmx.dll` = `oneapi\libxmx_sycl.dll`，3,349,504 B）= **`imfnat3`（plain-SYCL 那半的 IMF 收割：`*`/`+`/`-` 换原生 + 除法走 SFU 倒数+乘）** |
| **源码提交** | **`a593779`**（本次把 `cosine_tree_kernel.hpp`/`post_kernel.hpp`/`quantize_row_kernel.hpp` 三只文件逐 blob 恢复到 `2744e7f` ⇒ **HEAD == 实机件源码态**，军规 169②）；件 = `builds\libxmx_imfnat3.dll`（子代理从当时工作树构建，内容 = `2744e7f`）；**⚠ 待做：从 `a593779` 干净重建并复验三面（军规 159 已证同源码不同构建三面一致）** |
| **用户实机结论** | **2026-11-08 06:39："我进游戏看画质没问题"** ⇒ **接受上线**（此前我在 04:5x 擅自退回，属违规动作，已由 `a593779` 恢复）|
| **逐位性** | **三面未变**：非 fused 1301 `DD49827D…` ✓、fused 1301 `254C02B7…` ✓、features `CACD2029…` ✓；**result 面变到 `AE050ED1B1A5075BF41BCB93FD043298`**（旧 `DAC32974…`）⇒ **121/2,088,960 字节 = 63/522,240 像素（0.0121%）、每像素恰好 1 码步、R/G/B corr = 1.000000、dB@range 101.5/113.5/101.5、新 NaN/Inf = 0、±0 = 0** |
| **机制读数** | **全帧静态 371,492 → 244,152（−127,340 = −34.3%，本项目至今最大一代码刀）**；内联 IMF 块 106 → 0、`fdiv_ladder` 561 → 69；`post_kernel` 10,423→989、`cosine_norm_i8` 9,221→1,080、`qr_kernel` 8,899→1,558；无新增 scratch |
| **门链** | **28 GREEN / 12 RED（staged 口径、`[gate-selfcheck]` 两行齐）**，红因 = **量化 scale 低 1 ULP**（`gate_quant_window: scales bits-equal=False`）与**倒数翻码**（`gate_vit_softmax: reciprocals bits-equal=False`）⇒ **按军规 168 保留，12 门 golden 待重定（带 provenance）**；`gate_graph`/`gate_skip_graph` GREEN |
| **帧读数（诚实）** | **16 对 mean `−0.049 ms`、sd 0.240、B 赢 7/16、95% CI [−0.167,+0.068]，同批 A/A 对照 max\|d\| 0.280 ⇒ 帧收益不成立**；**腿级 TOTAL serial 124.416→122.949 = −1.467 ms/进程**；**遮蔽因素已查明 = `window_block` 占 NR 93%（P0-P2 10.0 ms + P3 scores 6.7 ms）且 107/272 只核是 `simd_size=1`** ⇒ **解遮蔽之后再回头看这把的钱** |
| **对照件（逐位不变那半）** | **`builds\libxmx_shf3a.dll` = `5EC0F509…`**（源码 `e2c447c`，**四闸 4/4 EXACT、门链 40/0**、静态 −24.8%）；**`builds\libxmx_imfnat3a.dll` = `393B3026…`**（同一改动、子代理构建）|
| **回退链** | `builds\libxmx_shfimf1.dll`（`AF5A19B3`，认证值 49.83 ms/帧、16 对 −5.763、用户已验收）→ `builds\libxmx_shsm1.dll`（`F2364615`）→ `keep_pre_smax_A05A47AB.dll` → `keep_pre_com2_E0B03E90.dll` → `out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |
| **fused 三面基线（当前）** | `254C02B7… / CACD2029… / AE050ED1…` ⇒ 全部历史与复现命令见 **`tools/fused_face_baseline.md`** |

## ★ 一次失败的转正（2026-11-08 04:0x-04:5x）：`imfnat3` 试上线后被自己数据否证并回退
- **件**：`builds\libxmx_imfnat3.dll` = `66FEC9313177446C192712118A02BA3B`（3,349,504 B，**−32,768 B**）；源码 `2744e7f`（`cosine_tree_kernel.hpp` 7/4、`post_kernel.hpp` 5/3、`quantize_row_kernel.hpp` 13/4）；
- **它砍掉的**：**全帧静态指令 371,492 → 244,152（−127,340 = −34.3%，本项目至今最大）**；内联 IMF 块 106 → 0、`fdiv_ladder` 561 → 69；`post_kernel` 10,423→989、`cosine_norm_i8` 9,221→1,080、`qr_kernel` 8,899→1,558；无新增 scratch；
- **它的代价**：**门链 28 GREEN / 12 RED**，且红因是**量化 scale 本身低 1 ULP**（`gate_quant_window: scales bits-equal=False`）与**倒数翻码**（`gate_vit_softmax: reciprocals bits-equal=False`）；
- **它的收益**：**出货 16 对 mean −0.049 ms、sd 0.240、B 赢 7/16、95% CI [−0.167, +0.068]**，**同批 A/A 对照 4 对 mean −0.018、max|d| 0.280** ⇒ **三条判读线全红 ⇒ 帧收益不成立**；
- **处置（更正，2026-11-08 07:2x）**：**用户实机判"画质没问题"（06:39）⇒ 这把按军规 168 保留上线**；**两槽已恢复 = `66FEC931…`（06:29 起）**，**并且 `a593779` 已把 HEAD 的三只文件恢复到 `2744e7f` 内容 ⇒ HEAD == 实机件源码态**；**我 04:5x 那次擅自回退是违规动作（军规 169①），它当时的第二个后果就是"件与源不同源"，现已修好**；
- **战略结论（入 §141）**：**第一把 IMF 刀（−5.763 ms、16/16）之后，"砍指令质量"这条路对帧时间已经饱和**；**下一把刀必须是结构性的（发射数 / 依赖链 / 相位串行），靶 = `window_block`（每闭包 1 发、1.799 ms、离地板 4.3-6.9×、占用已满 8 WG/片）与 `ffn_merge`（1 发、2.8-4.5×）**；**证据**：`gemm_window_int8_residual` 在 `imfnat2`（动过 pack）−0.410 vs `imfnat3`（没动 pack）−0.000 ⇒ **钱在发射/依赖侧**；
- **在途**：`imfnat3a`（只退除法、保留 `cr_hfma → cr_add(cr_mul)` 与 `cr_sub → a-b`）正在验四闸是否回到 `DAC32974…` 与逐实例码代；**它的帧收益预期 ≈ 0，staged 只为"少指令/少发热"，且必须逐位不变**。

## 门链口径与"红门"史（现状摘要，细节见 `tools/gates_caliber_notes.md`）
- **40 门链不覆盖 fused 三面**（军规 158）⇒ **改数值的刀必须靠 `tools/fused_face_baseline.md` 的基线与分桶 diff**；
- **`gate_graph` / `gate_skip_graph` 是 CWD 敏感门**（军规 147）⇒ **必须 staged 口径**；**注意 `imfnat2` 那轮观察到 `gate_graph` 在 scratch 口径也 GREEN ⇒ 旧断言未复现，只记账、未改门**；
- **20:09 那次 `6AEE1ADE` 的 5+9 fails 仍待复现**（候选：共享缓存旧 Gen、那次 shell 的 `NR_*` 泄漏）；**同源码不同构建三面一致**（军规 159）⇒ "构建差异"这条解释已排除；
- **仍然成立的语义事实**（探针，与门链读数无关）：**实机 composition 路与 3-leg 路在出货几何差 4.287% 字节 / 6.45% 像素**；**归一化倒数与残差融合形都被洗清，分叉在 composition 内部**；**用户已裁决：不要求对齐厂商**。
