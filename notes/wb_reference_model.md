# wb_reference_model.md — `window_block` 的**参考权威模型**与两条路的逐位对照（2026-11-07 ①，零改码）

**模型来源（唯一权威）**：`E:\DSH\refs\dlss-nr-on-intel\src\gpu\window_block.comp`（+ `cosine_tree.glsl`、`publish.glsl`）。
**对照件**：`E:\DSH\out\libxmx.dll` = `A05A47AB302FA4D1545F41AA46B4A260`（现槽、未动），经 `E:\DSH\tmp\gs_model\libxmx_sycl.dll` 副本加载（**不碰加载位**）。
**工具**：`E:\DSH\s6\wb_model.py`（模型 + 双路捕获，`python s6/wb_model.py H W TOP LEFT FLAGS`）；日志 `E:\DSH\s6\wbm_0.log`、`wbm_1.log`。
**缓存态**：cold（专用空 `E:\DSH\tmp\syclcache_model`）。

## 1. 参考的 op 顺序（模型照此实现，行号即出处）

| 阶段 | 出处 | 语义 |
|---|---|---|
| 行枚举 = (window, token)，token = sub·8 + r；像素 y=(window/across)·8+sub−top、x=(window%across)·8+r−left；界外补零 | `:103-112`、`:126-136` | **不是像素主序**（我们第一版模型错在这里，改对后 V 面逐位全等） |
| A 腿 gather 后 **`e4m3`** 再存 f16 | `:133`、`:135-136` | 量化在进 coopmat 之前 |
| QKV GEMM：K=32 拆两步 ×16，**f32 累加器** | `:148-158` | dpas 序 |
| 存 f32 → 每行 **`half_round`×8** | `:162`、`:177` | |
| **余弦归一化 = f16 域的蝶形树**：`hfma(h[2+p],h[2+p], hmul(h[p],h[p]))`、`hfma(h[6+p],…,hmul(h[4+p],…))`、`hadd` → `shuffleXor 2` → `shuffleXor 1` → `hadd(whole0,whole1)`，`norm = max(…, half_round(COSINE_NORM_FLOOR))`，`reciprocal = half_round(inversesqrt(norm))`，`scale = half_round(qkv_scale)`（只 Q） | `:180-191`（`COSINE_NORM_FLOOR = 0.00006198883056640625`，`cosine_tree.glsl:10`） | **lane→通道映射：lane l 持 {8g+2l, 8g+2l+1}, g=0..3**（`:169-175`） |
| `value = hmul(h, reciprocal)`；Q 再 `hmul(value, scale)`；**`h = e4m3(value)`** | `:192-196` | |
| **V：不 half_round，直接 `e4m3(h)`** | `:198` | |
| 注意力分数 `Q·Kᵀ`（两步 ×16）+ **f32 bias 直接加** | `:234-245` | |
| softmax 权重 = `half_round(logit)*0.044921875 + 1.30078125`，`clamp(1.03125, 1.5693359375)`，再 **`unpackHalf2x16((packHalf2x16(affine)<<5) + 0x7ff88000)`**（指数位加法 = exp2 技巧） | `:85-94`、`:253-256` | |
| 分母 = 每行 64 个权重**按 `:279-286` 的顺序 f32 逐次加**，再 **`half_round(1.0 / half_round(total))`** | `:275-288` | |
| 权重乘分母：`precise float first = pair.x * scale;` → **`e4m3(half_round(first))`** | `:290-297` | |
| attnV = 权重·V（四步 ×16，f32 累加） | `:300-312` | |
| 注意力输出 publish：**`e4m3`** 存 f16 | `:320-329` | |
| 输出投影（两步 ×16） | `:332-349` | |
| 残差：**`precise float total = fma(skip[i], cosine[i], branch)`——一次融合舍入，"写出来让编译器没得选"** | `:353-381` | |
| `publish(epilogue, total)`：0=原值、1=`e4m3`、4=`half_round`；narrow→f16 存、否则 f32 存；pool 另存 `e4m3` 并按 POOL2_SKIP 序求 2×2 和 | `:380-396` | |

## 2. 逐位对照（tiny 形状 `16x24 top=0 left=0 flags=0x0`，windows=6 rows=384，cold）

| 对照 | 不同字节 / 总字节 | 首个不同（元素级） |
|---|---|---|
| **composition target vs chain target**（门现在测的就是这个） | **1,459 / 49,152（3.0%）** | — |
| **model V vs chain V** | **0 / 24,576 ⇒ 逐位全等 ✓** | ⇒ **模型的 gather+e4m3+GEMM+e4m3 主干是对的**（连 e4m3 量化器与 f16 存回都对上） |
| model Q vs chain Q | **59 / 24,576（0.24%）** | idx 369：model `0.1875` / chain `0.2031`（**1 个 e4m3 档**） |
| model K vs chain K | **6 / 24,576（0.02%）** | idx 1032：model `-0.2188` / chain `-0.2344`（1 档） |
| model attended vs chain attended | 772 / 24,576 | 由 Q/K 的 1 档差累积 |
| **model target vs COMPOSITION target** | **4,439 / 49,152（9.0%）** | elem 384（pixel 12 ch 0）model `-0.75868964` vs device `-0.76333183`（0.6%） |
| **model target vs CHAIN target** | **5,895 / 49,152（12.0%）** | elem 288（pixel 9 ch 0）model `-0.17426758` vs device `-0.16935034`（2.8%） |
| **牙齿测试**（模型故意改坏：把 ch0 的符号翻掉再量化） | **5,816 / 49,152 ⇒ 判红 ✓** | 对照器有牙齿，不是"怎么都比不过" |

## 3. 三条结论（不含猜测）

1. **主干已被模型证明正确**：**V 面 12,288 个元素逐位全等** ⇒ 我的 e4m3 量化、f16 存回、gather 映射、GEMM 累加（f64→f32 近似）都对上 ⇒ **对照器可信**。
2. **Q/K 只差 0.24% / 0.02%，且都是 1 个 e4m3 档** ⇒ 差异集中在**归一化的 `inversesqrt` 近似**与 **dpas 累加序**两处（模型只能取"正确舍入的 1/sqrt"，参考用 GLSL `inversesqrt` = 实现质量近似）⇒ **这是可解释的模型不确定项，不是我们两条路的错**。
3. **⇒ 真正结构性的偏离在 composition 侧**：我们的 3-leg 链走 `ctree::cosine_reciprocal`（`cosine_tree_kernel.hpp:23,49,59` = 参考的 f16 蝶形树，**与 `window_block.comp:180-191` 同构** ⇒ 所以与模型只差 1 档），而**融合 composition 走 `wbv3::cosine_recip_vec`**（`window_block_v3.hpp:85+`；调用点 `window_block_v4.hpp:298-301`：**32 个通道在 f32 域顺序 `ef_add` 累加，再一次 `eh_round`**）⇒ **求和序与数值域都不同** ⇒ **这才是 composition != chain（9/9 用例全红）的主因**。

## 4. 修法提案（等批，不改码）

- **(a) 改 composition（推荐给正确性优先）**：把 `wbv3::cosine_recip_vec` 换成**参考的 f16 蝶形树**（lane 映射 `{8g+2l, 8g+2l+1}`、`hmul/hfma/hadd`、`shuffleXor 2→1`、`max(…, half_round(FLOOR))`、`half_round(inversesqrt)`）。**代价**：ESIMD 下要做 lane 内的 8 值分组 + 两次 xor-shuffle 等价物（`select`/`permute`），预计每行多几十条指令、**不增加内存往返**；**收益**：`gate_window_block` 9 用例有望转绿，**并让 window_block 重新有独立守门人**（今天它没有）。
- **(b) 只改门**：把判据降级为"与参考模型逐位对 + 与链带容差对"，**并在 `tools/gates_known_red.md` 记清 composition 的归一化偏离**。**代价小，但等于承认出货路偏离参考** ⇒ **我不建议**（实机就是这条路）。
- **(c) 先补模型不确定项**：把 `inversesqrt` 与 dpas 累加序也钉死（用一只**单行微探针**：喂 32 个已知 f16，直接读回 reciprocal 的位）⇒ 之后 model 与 chain 应当**完全逐位相等**，(a) 的验证才有零噪声基线。**建议 (c) → (a) 顺序执行，(c) 很便宜（一次小 kernel，秒级）。**

## 5. 出货形状（960×544 的 window block 几何）为什么帧面仍然 EXACT

**帧面 golden 是从 composition 自己生成的**（`out/plan_960x544.bin` 的三面对照 = 同一实现的历史快照）⇒ **composition 与参考的偏离不会让帧面变红**；**红只在门的 3-leg 对照里出现** ⇒ **所以"帧面对 ≠ 语义对"**：这正是这条门存在的意义，也是它从 11-01 起失守的代价。
**注意**：出货形状走的是同一 `wbv4::launch_v4full`（`libxmx_sycl.cpp:6014-6025`）⇒ **偏离同样存在于实机**，只是没有对照能看见。**要拿到 960×544 几何下的对照数，需要在 ② 之后用同一模型跑一次大形状的捕获（≈2-3 分钟 GPU，本轮未做）。**
