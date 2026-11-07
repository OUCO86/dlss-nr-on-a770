# 大扫铲：全帧"软件模拟热点"普查 + 社区对照（2026-11-08，零 GPU）

**铲手**：子代理（唯一在跑）。**纪律**：本轮零 GPU、零 git 写、引擎文件只读；只用已存在的冷编译 dump 与源码。
**写过的东西**：`E:\DSH\tools\frame_hotspots.csv`（新建）、`E:\DSH\s6\c2_*.py / c3_*.py / c4_*.py / c6_*.py / c7_*.py / c9_*.py / c10_*.py / c12_*.py / c13_*.py / c15_*.py` 与日志 `E:\DSH\s6\S2_*.log / S3_*.log / S4_*.log / S6_*.log / S7_*.log / S9_*.log / S10_*.log / S12_*.log / S13_*.log`、`E:\DSH\s6\layer1.md §63`。
`git status --porcelain` = **空**（仓内零改动；csv 写在受管 `E:\DSH\tools\`，不在仓内）。

---

## 0) 用的是哪只件的哪一次 dump（provenance）

- dump 目录 **`E:\DSH\tmp\f2h_ze\d_B_0_16`**（270 只 `.text.*.asm`），来自冷缓存 **`E:\DSH\tmp\syclcache_f2h_var_n_w1`**，
  = **`builds\libxmx_imfnat1.dll` = `9D69BDDB266E16E39D0DCB2EBC807595`**（3,382,272 B）的一次 **非 fused 1301 cold walk**
  （日志 `s6/S1_f2h_walks.log`：`var_n exit=0 wall_s=35.9 files 0->12 (FRESH: pre=0)`，1301 = `DD49827D…` = 金标）。
- 上线件 = **`AF5A19B30E40B7594C142691F54B5B97`**（`out\libxmx.dll` / `oneapi\libxmx_sycl.dll`，同尺寸 3,382,272 B）。
  父级已证 **同一源码树两次不同构建三面 md5 完全一致**（`tools/fused_face_baseline.md` 末段）
  ⇒ **`9D69BDDB` 的 GEN 就是上线件的 GEN**（`92259ae` 的 `publish_kernel.hpp` 手术 = `58acba8` 的内容）。
- fused 面的冷缓存也在手（`tmp\syclcache_f2h_var_f_w1`），本轮没反汇编它（见 §6 的下一步）。

---

## 1) ★ 先修仪器：上一把的"全帧 ops"口径**少数了 9.4%**

`hf_frame_reach.py` / `f2h_codegen_diff.py` 的谓词正则 `^\([A-Za-z0-9+|,_* ]*\)` **不含 `.`** ⇒
所有 `(f0.0)` / `(~f0.0)` / `(W&~f1.0)` 这类**被浮点谓词保护的指令行整行没被计数**。
修好的归一化器（`s6/c2_look.py`）读数：

| 口径 | 上一把（少算） | 本轮（含谓词行） |
|---|---|---|
| 对照件 hb0（IMF 前） | 882,001 | **1,048,060** |
| 上线谱系（IMF 后） | 336,505 | **371,492** |
| 全帧砍掉 | −61.8% | **−64.6%** |

⇒ 账本里 `336,505` 与每只核的 ops 都要按这个口径重述（父级已说马上更正入库）。
**新口径的两条"动态"总数（本轮全部读数的分母）**：
- **静态指令体 = 371,492 条**（270 只实例）；
- **动态 = 468,002 条** = 静态 + 外提体按 call 站点重复执行多出来的 **96,510 条**（见 §2）。

**重标定的每站点价格**（同一批 `s6/hr_bisect` 探针 arm，用修好的归一化器重数，`s6/S2_c2_probeval.log`）：

| 构造 | 条/站点（旧口径） | **条/站点（新口径）** |
|---|---|---|
| `__imf_fmul_rn` | 309 | **410.8** |
| `__imf_fadd_rn` | 1,048 | **1,233.2** |
| `__imf_fdiv_rn` | 642 | **776.8** |
| 原生 `*` / `+`（contract off） | ~1 | **1.0** |
| 原生 `+` 再套 f16 往返 | ~4 | **1.2** |

---

## 2) ★★★ 本轮最大的机制发现：**IMF/除法在帧里不是逐站点内联，而是被外提成共享子程序按站点调用**

`E:\DSH\tmp\f2h_ze\d_B_0_16` 全帧：**221 只被 `call` 的外提体、645 个 call 站点**；
外提体里静态只 19,882 条，但**按站点重复执行 = 116,392 条动态 = 静态体的 31.3%**。
按构造归族（`s6/c13_hotspots.py`、`s6/c10_bodyfamilies.py`）：

| 外提体族 | 体数 | call 站点 | 体条数 | **动态条数** | 占全帧动态 |
|---|---|---|---|---|---|
| **`esimd::div_ieee` 的下形**（体内 `shr 23`×4 + `and 255`×4 + `math.*`×2，**没有** 448.0f 夹取 ⇒ 不是 e4m3，是**除法**） | **69** | **472** | 15,903 | **111,616** | **23.8%** |
| 其他外提区（pack/store 循环、`send` 密集） | 152 | 173 | 3,979 | 4,776 | 1.0% |
| f16 往返 helper | 14 | 14 | 882 | 882 | 0.2% |

体形按站点数排（`s6/S10_c10_families.log`）：`195 条 × 306 站点 = 59,670`、`454 × 32 = 14,528`、
`447 × 32 = 14,304`、`200 × 48 = 9,600`、`250 × 38 = 9,500`、`251 × 15 = 3,765`。
主人（`s6/c3_full.py` rollup，动态条数）：
`packdev 60,470` ＋ `quantize_row 28,153` ＋ `ffn2::fused 9,722` ＋ `att5::fused 8,459` ＋ `b6 4,251` ＋ `s8v9 1,594` ＋ `f16v1 1,002` ＋ `rec:unary 392`。

**为什么这台机器上躲不掉**：Intel 自己的 oneDNN GPU JIT 写明
**`fdiv_ieee()` 在 XeHPG 上没有硬件指令**（`refs/onednn-gpu/src/gpu/intel/gemm/jit/dsl/ir/codegen/kernel.hpp:645`），
所以他们 **`inv(1,tmp,src1); emul(mod,dst,src0,tmp)` = 2 条**（`:648-650`），只有 XeHPC+ 才发 `fdiv_ieee`（`:682`）。
我们的 A770 = **XeHPG** ⇒ 引擎里 `esimd::div_ieee`（`gemm_s8_v9_kernel.hpp:44-50` 自称"hw correctly-rounded"）
**在设备上不是一条指令，而是 195-454 条的软件形** —— 这就是全帧最大的一坨"软件模拟"。

**同时：内联的 `__imf_*` 残量比上一把的"指纹行数"小得多。**
真正的块锚点 = 块内规范 NaN 常量 `mov … 0x7FC00000`（四只软件臂里都**恰好每站点 1 次**，两只原生臂 0 次）：
- **内联 IMF 块 = 106 块 / 54,574 条 = 静态的 14.7%**（按块锚点间距**实测**，`s6/c2_imf_span.py`）；
  分类（`s6/c4_hotspots.py`）：fadd 形 16 块/19,739、fdiv 形 19 块/14,551、fmul 形 18 块/7,345、部分折叠 46 块/12,939。
- 用"探针独占 marker 集"上界法（`s6/c7_anchor_sites.py`）：**fmul 74 站点 / fadd 58.4 / fdiv 32.6 ⇒ 165 站点 / 127,690 条 = 静态的 34.4%**。
  ⇒ **残量区间 = 55K–128K 条**（两法之间的差是"常量被折掉、marker 不再命中"的块）。
- ★ **`s6/layer1.md §61` 留下的"IMF 指纹行还剩 4,392"不是 IMF 的账**：那套宽松立即数集
  （`0x7FFFFF / 0x1FFF / 0x1000 / 0x200 / 8388607 / 255 / >>23`）同时命中 **e4m3 的指数提取**与别的位活。
  本轮实测：`shr 23` 全帧 2,600 行、`and 255` 1,530 行、`448.0f` 夹取 2,077 行 —— 这些是 **e4m3/量化**，不是 IMF。

---

## 3) ★★ 三条被否证的怀疑（记下来免得再铲一遍）

1. **`sycl::half` 的算术/比较运算符不是热点**：全帧带 `:hf` 的算术只有 **mul 1,022 / add 294 / mad 8 / cmp 26 / sel 18 / math.inv 38**，
   全是**原生带类型指令**；`half_type.hpp` 便携 C++ 形的指纹（`0x1FFF`、`>>13`、`<<10`、`0x7c00`、`0x3ff`）**命中 0**。
   （`s6/S2_c2_crosstabB.log`；`s6/c2_probe_sig.py` 在 `d_syclcache_hrbisect_bb2_122904_1`：48 个"原生+half 往返"站点 = **58 条**。）
2. **`f32->f16` 转换腿早就是原生**：`mov :hf` 23,834 行（6.4%），**每行 1 条**，不是软件模拟；
   它的钱在"**往返次数太多**"（11,917 次往返），不在"每次太贵"。
3. **`exp2 / sqrt / recip` 已经走 SFU**：`math.inv 661`、`math.sqt 70`、`math.exp 23`、softmax 的 `(packed<<5)+0x7FF88000` 位技巧
   ⇒ 数学函数族**没有**可砍的软件模拟（`s6/c13_hotspots.py`）。
   **唯一例外**：`quantize_row_kernel.hpp:71-75` 的 `e4m3_decode` 每个字节调 **两次 `sycl::exp2`** ⇒ 见 §5 刀 3 的 LUT 案。

---

## 4) 排名（判据 = 全帧动态条数 × 该族是否在关键路径）

关键路径口径用父级的腿级 A/B（`notes/layer2-gains.md §5`，6 进程/侧、cold、专用空缓存）：

| 族 | B 每闭包 | 倍数 | 本轮该族的软件模拟条数 | 兑换率（本轮实测，`s6/S12_c12_rates.log`） |
|---|---|---|---|---|
| `global_attention`（含 `packdev`/`ctree`/`smax1`/`f16v1`） | 0.516 | **2.1-3.3×（未过）** | div_ieee 60,470 + ctree IMF 22,643 + f16 往返 | **41.9K-51.8K 条/ms** |
| `ffn_merge`（`ffn2::fused`、`ffn_tail_res`） | 1.618 | **2.8-4.5×（未过）** | div_ieee 9,722 | **7.6K 条/ms**（最敏感） |
| `window_block`（`wbv4*`、`b6`） | 1.806 | **4.3-6.9×（未过）** | div_ieee 4,251 + e4m3 119 站点 | **~1.3M 条/ms ⇒ 对指令条数完全无感**（IMF 刀只动了 −0.017） |
| `unary2`/`postpass` | — | — | IMF 12,301 | 30.4K 条/ms |
| `gemm_int8_qkv` / `gemm_int8_residual` 等 int8 族 | — | **1.22-1.4× 贴地** | div_ieee 28,153(quant) + IMF 39,298 | **1.16M 条/ms ⇒ 砍了没钱**（军规 131） |

⇒ **只提三把刀。int8 gemm 族里那 39K 条 IMF 与 28K 条 div_ieee 明确不排（贴地）。**

---

## 5) 三把最大刀

### 刀 1 ★★ **`esimd::div_ieee` → `inv` + `emul`（或"每行一次倒数 + 每元素乘"）**
- **砍哪里**：`pack_device.hpp:111/173/212/567/616/689`、`quantize_row_kernel.hpp:241/249/280/329`、
  `att5_fused_kernel.hpp:111/113/451/452`、`b6_res_kernel.hpp:392/393`、`gemm_s8_v8_kernel.hpp:1245/1253`、
  `gemm_s8_v9b_kernel.hpp:266/267/279`、`gemm_s8_v9c_kernel.hpp:309/310/322`（定义在 `gemm_s8_v9_kernel.hpp:44-50`）。
- **预计条数**：111,616 动态里的 **~100,000+ 条**（472 站点 × 195-454 → 2-3 条）。
  落族：**GA 的 packdev 60,470**（未过线 2.1-3.3×）+ **ffn_merge 9,722**（未过线，兑换率最狠）+ post/unary2。
- **预计帧量级**：GA 60,470 / 45K ≈ **−1.3 ms**，ffn_merge 9,722 / 7.6K ≈ **−1.3 ms**，加 post/quant 的零头
  ⇒ **腿级 −2 ~ −3 ms**（与第一把 IMF 刀同一量级；帧要打折 cgraph 重叠）。
- **风险类**：**会改数值**（1 ULP 的商；`quantize_row_kernel.hpp:104-109` 记着"近似倒数低 1 ULP ⇒ X.5 tie 翻成 64 vs 63"）。
  保守变体：只把 **每元素除** 改成 **每行一次倒数 + 每元素乘**（`softmax_kernel.hpp:85/135/204/247` 已是这个形状，
  lmxx `attention.comp:236-238` 也是这个形状），把改动面从 472 站点收到 pack/quant 的 K 条链。
- **验证**：① fused 三面 vs `254C02B7 / CACD2029 / DAC32974`（`tools/fused_face_baseline.md`）逐字节 + 按 `|v|` 分桶量化变化量；
  ② 非 fused 1301 金标 `DD49827D`（pack/quant 不在 fused 路，可能这里 EXACT）；③ `db_meter` + `block_collapse`；
  ④ **腿级 ≥10 进程**（GA / ffn_merge / quant / unary2 四条腿）；⑤ 出货 16 对 + 同批 4 对对照；⑥ 交用户实机（军规 156）。

### 刀 2 ★ **把最后一坨内联 IMF 收掉：`cr_hfma`（`cosine_tree_kernel.hpp:28`）与 `cr_sub`（`post_kernel.hpp:28`）改用已经变原生的 `cr_mul`/`cr_add`**
- **砍哪里**：`cosine_tree_kernel.hpp:28`（`fadd_rn(fmul_rn(l,r),acc)`）与 `post_kernel.hpp:28`；
  顺带 `cosine_tree_kernel.hpp:50/60/70` 与 `post_kernel.hpp:109` 的 `fdiv_rn` 直调（= 刀 1 的 plain-SYCL 版本）。
- **预计条数**：实测 **54,574**（106 块）到上界 **127,690**（165 站点）；其中 fadd 形 19.7K-72.0K 是大头。
  落族：`ctree 22,643`（GA，未过线）+ `postpass 12,301`（unary2）；**`rec:gemm_int8_qkv 39,298` 贴地 ⇒ 不排钱**。
- **预计帧量级**：GA 22,643 / 51.8K ≈ **−0.44 ms**，post/unary2 12,301 / 30.4K ≈ **−0.4 ms**
  ⇒ **腿级 −0.8 ~ −1.5 ms**（区间取决于折叠掉多少）。
- **风险类**：**仅极小值与 NaN/±0 类**（`s6/S1_hrbisect_census.log`：NORMAL 桶 mul 15,830,236 对、add 16,045,744 对
  `imf != native = 0`；subnormal 两路都 FTZ；差只落在 ±0 符号 31,752 与 NaN 载荷 537,084）。
  **但**：刀 1 已经证明"换原生"会让设备**重结合**（`add 636→36`、`add3 289→2`、`mul 173→519`）⇒ 必须按刀 1 的量化流程复验。
- **验证**：同刀 1（三面基线 + 分桶 + 腿级 + 16 对 + 用户实机）。`cr_hfma` 的 `l*r` 在 f16-精确域里 **f32 精确**
  （11×11 = 22 ≤ 24 位）⇒ 乘法腿可证不变，只有加法的结合序是变量。

### 刀 3 **e4m3 的两种下形合一 + `e4m3_decode` 换 256 项 LUT**
- **砍哪里**：`publish_kernel.hpp:33-41`（C++/libdevice 形，全帧 **2,077 站点 × 29-51 条 ≈ 60,233 条**）
  → 换成已在出货路逐位过门的 ESIMD 形 `s8v8::e4m3_vec_v8`（`gemm_s8_v8_kernel.hpp:397-411`，
  **实测 14 条/站点**，att5/b6 里）或 `qr_e4m3_scalar`（`publish_kernel.hpp:51-67`）；
  以及 `quantize_row_kernel.hpp:71-75` 的 `e4m3_decode`（每字节 2 次 `sycl::exp2`）→ **256 项 f32 常量表**（1 KB）。
- **预计条数**：60,233 → ~29,000 ⇒ **省 ~31,000 条**，外加 decode 的 exp2 链。落族：`ffnc 20,900`（ffn/ffn_stem）、
  `f16v1`（GA scores）、`rec:window_block 119 站点`（WB 对指令条数无感 ⇒ 只算顺带）。
- **预计帧量级**：**−0.3 ~ −0.6 ms 腿级**（ffn 族 4.97 ms RT、8 闭包、每发 0.62 ms）。
- **风险类**：**数值不变（可证）**。我把 lmxx 的 **magic-add 舍入形**（`refs/dlss-nr-on-intel/src/gpu/publish.glsl:41-46`）
  与出货形做了 **host 逐位对照：6,048,389 个样本、DIFFERENT = 0**（`s6/c9_e4m3_magic.py` → `s6/S9_c9_e4m3magic.log`；
  样本含全部 65,536 个 f16 精确值、全部 256 个 e4m3 码 ±、4M 随机位形、2M 管线幅度域、角值）。
  ⇒ 这把刀**不需要用户实机裁决画质**，走门链即可（但仍是 `qr_e4m3` 的 C++ 形，要过 PUBLISH 门）。
- **验证**：门链（`gate_qkv_v` / `gate_requant_i8` / `gate_quant_window` / `gate_ffn*`）+ 逐实例码代 changed 计数 + 三面 EXACT 期望。

---

## 6) 社区对照（`refs/`，零 GPU；每条带 `文件:行号`）

### lmxx = `refs/dlss-nr-on-intel`（同一张 DLSS-NR 图的 RDNA 移植）
| 他们在做什么 | 行号 | 我们能不能照搬 |
|---|---|---|
| `hmul/hadd/hfma` = **`precise float t = l*r (+acc)` + `half_round(t)`** —— **一个正确舍入库调用都不用** | `src/gpu/cosine_tree.glsl:16-18`；调用点 `:28-29`、`:52` | **直接照搬** = 刀 2。GLSL 的 `precise` 只挡 FMA 收缩，和我们的 `contract(off)` 同义；我们已经把 `cr_mul/cr_add` 换原生，只剩 `cr_hfma` 没换 |
| 余弦归一化的倒数用 **`inversesqrt`**（硬件 SFU），ViT 用 `1.0/sqrt` | `src/gpu/cosine_tree.glsl:39`、`:58` | **照搬有风险**：他们不要求逐位对齐 numpy；我们 `cosine_tree_kernel.hpp:50/60/70` 的 `fdiv_rn(1,sqrt)` 是刻意的 |
| 行的倒数**每行算一次**、元素只乘 | `src/gpu/attention.comp:236-238`、`:354-358`、`:127-135` | **照搬** = 刀 1 的保守变体 |
| e4m3 两种拼法：我们的阶梯形（`:48-53`）与 **magic-add 舍入形**（`:41-46`，`magnitude+magic − magic`） | `src/gpu/publish.glsl:37-56` | **照搬**（我已 host 证逐位等价，§5 刀 3） |
| half 往返只用**硬件转换**，注释写明"手工做指数尾数要 10 条 + 2 分支，硬件只要 2 条" | `src/gpu/publish.glsl:12-21` | 已经是我们的形态（`:hf` mov） |
| exp2 用 **packed-half 位技巧** `(packHalf2x16(affine) << 5) + 0x7FF88000u` | `src/gpu/attention.comp:165-166`、`:301-302`、`global_attention.comp:82-83` | 已经是我们的形态（`softmax_kernel.hpp:10/71/127`） |
| XMX/合作矩阵全程 `coopmat<float16_t>` + `f16vec4` 共享缓冲 | `src/gpu/ffn_fused.comp:104/107/150-179` | 不适用（我们走 SYCL/ESIMD `dpas.8x8`，已在出货路） |

### oneDNN-GPU = `refs/onednn-gpu`（Intel 自己的库，同一 GPU 家族）
| 机制 | 行号 | 可用性 |
|---|---|---|
| **"fdiv_ieee() 在 XeHPG 上不支持 ⇒ 用 inv-based 序列"**：`inv(1,tmp,src1); emul(mod,dst,src0,tmp)` | `src/gpu/intel/gemm/jit/dsl/ir/codegen/kernel.hpp:645-652`（XeHPC+ 才发 `fdiv_ieee`，`:680-682`；`:593` 另记"立即数 src0 不支持 fdiv_ieee"） | **这就是刀 1 的正当性来源**：A770 = XeHPG，`div_ieee`/`fdiv_rn` 必然是软件形。我们不能照抄 ngen，但 SYCL 侧有 `sycl::native::recip` / `ext::intel::math::inv` + 乘 |
| 量化取整用**一条饱和 RNE 转换**：`convert_char_sat_rte(min(max(a,-8),7))` | `src/gpu/intel/include/math_utils.h:671-677`、`conversion.h:63` | **可照搬**：我们的 `rint + 双 clamp`（`quantize_row_kernel.hpp:114-115`）在 SYCL 里是 `sycl::to_packable`/`vec.convert<int8, rounding_mode::rte>`；见 `src/gpu/generic/sycl/sycl_q10n.hpp:139` |
| 全程 ESIMD + dpas，**没有任何 per-element 的 `fdiv_rn` 包装** | `src/gpu/intel/**`（`ext::intel` 只出现在 `device_info.cpp:124`） | 机制结论：**别人不用 libdevice 的舍入包装**；我们的 `ext::intel::math::fadd_rn/fmul_rn/fdiv_rn` 是这条路上唯一在付软件模拟钱的写法 |

### ggml-sycl = `refs/llama-sycl/ggml/src/ggml-sycl`
| 机制 | 行号 | 可用性 |
|---|---|---|
| **LUT 反量化**：`get_int_from_table_16(q4, table)` 把 16 项表当 uint32 读；`kvalues_mxfp4[q & 0xF]` | `vecdotq.hpp:114-131`、`:1207-1208`；`dequantize.hpp:431-432`、`:444-448`、`:1775-1798`、`:1825` | **直接照搬** = 刀 3 的 `e4m3_decode`（256 项 f32 表，1 KB）替代每字节 2 次 `sycl::exp2`（`quantize_row_kernel.hpp:71-75`） |
| **ESIMD 向量数学**：`simd<float,16> e = exp2(t)`（注释：sigmoid 走 exp2；宽度 1 的 simd 是 EM 管的退化情形，所以广播到 16 条 lane） | `dmmv.cpp:1593-1604`；累加器 `dmmv.cpp:1751-1752` | **适用**（我们 ESIMD 核已在用同类形）；plain-SYCL 核里 `sycl::exp2` 是 per-element，不划算 |
| **打包半精度**：`sycl::half2`、`make_half2`、`__half22float2`、`ggml_sycl_mad(half2,half2)` | `common.hpp:224`、`:930-947`、`:975-1010`、`:680` | **部分适用**：SYCL 有 `sycl::half2`，但我们的 `qr_half_round` 语义要求"回到 f32"，half2 只能砍往返次数不能砍语义 |
| 反面例子：`ggml_sycl_ue4m3_to_fp32` 用 `sycl::pow(2.0f, exp-7)` 逐元素 | `common.hpp:1159-1174`（另 `cpy.hpp:337` 用 `floor(log2(amax))`） | **不要照搬**（比我们现在的形更贵）；只借它的"表/位技巧"那半边 |

### `refs/fsr-sdk`
克隆里**只有文档与 .bat**（`readme.md` 等），没有 shader 源 ⇒ **本轮在 FSR 上没有可读的机制证据**；
`refs/nvidia-dlss` 同样没有可对照的设备算术源码。**要 FSR 的 EASU/RCAS 系数表对照，需要重新取源（不在本轮预算）。**

---

## 7) 本轮**没有**下刀的三件（按父级令留给批）
1. fused 面的冷 dump（`tmp\syclcache_f2h_var_f_w1`）没反汇编 ⇒ 刀 1/2 在 fused 三面的动态条数还没量（下一步第一条命令就是它）。
2. `.ze_info` 只在每只 ELF 的第一份里（union 目录只剩 1 份）⇒ 本轮**没有** per-instance 的 `simd_size/grf_count`；
   要按实例分"每元素成本"得逐缓存条目单独反汇编（CPU，可下轮做）。
3. `esimd::div_ieee` 的"每行倒数 + 每元素乘"保守变体我只做了源码定位，没写候选形（引擎只读）。
