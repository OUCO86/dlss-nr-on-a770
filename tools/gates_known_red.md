# 门梯已知红名单（known-red）— 父级裁决 2026-11-13 13:36

**验收口径（用户 13:34 拍板：可以改金标，别被条条框框卡死，最高优先级是速度）**
- 门梯（`tools/dsh_run_gates.sh`，40 条具名门）**当前不作为 C512 刀的验收尺**；改为：**候选件的 RED 集合必须是本名单的子集，且 fail 计数与基线逐条相同**（新增红 = 判红、停手）。
- 四闸逐字节阶梯（`tools/fused_face_baseline.md` 的指纹配方）+ `bad=0` bench + 帧 A/B 两口径（`REUSE=1` 与 `REUSE=0`）= 现在的硬尺。

**基线（出货件 `253F2CBD…`，镜像 RUNDIR、冷缓存，2026-11-13 12:2x 实测）与旧件（`6C4D7AF7…`）逐条相同：**
| 门 | fail 计数（两件相同） | 归因 |
|---|---|---|
| `gate_chain_qkv` | 13 | Q/K 的 `within-one / scale<=1ulp`（max 24770 / 16513）；V 全对 ⇒ `imfnat2/3` 把 `cr_div/qr_div/cr_plain_div` 换原生除法（SFU 倒数+乘）后 **`nr_model` 期望未换代** |
| `gate_qkv_qk` | 6 | 同上 |
| `gate_gemm_f16_qkv_window` | 11 | 同上族 |
| `gate_chain_s1` | 4 | 同上族 |
| `gate_global_attention` | 6 | 同上族 |
| `gate_vit_softmax` | 6 | 同上族 |
| `gate_quant_window` | 6 | 同上族 |
| `gate_cosine` | 5 | 同上族 |
| `gate_cosine_i8` | 7 | 同上族 |
| `gate_unary` | 5 | 同上族（publish 对 `nr_model`） |
| `gate_window_block` | 10 | WB 目标 vs 三腿链（`flags=0x1008000` 几何）⇒ 与 C512 刀无关（两把刀的允许表都排除该几何） |
| `gate_unary_kinds` | 2（1 条真红） | **`unary2`（launcher `:6617`、kind `0x10015`）的 `C(f32 merged)`**；疑设备 fma 一次舍入 vs 模型两步（e4m3 输出对）⇒ 待证伪 bench（两臂 `a+(b*d)` vs `sycl::fma`） |

**刀中性证据（三方对照，C106/C110）**：收紧 dll 开关 ON ≡ 全 OFF ≡ 无臂旧件 ⇒ 40 门 verdict 与 fail 计数逐条一致 ⇒ **这 12 红是基线自身性质，不是 C70→C109 刀链带来的** ✓✓✓

**金标换代（待做，不阻塞速度）**：按草案 `tools/gate_selfcheck_proposal.md` + Q/K 最小重录（`NR_GOLDEN_REV=<tag>`，旧金标不动、并列打旧期望 vs 设备字节、新字节落 `dumps/qkv_<rev>.<case>.bin`）；**决定性对照** = 用 `tools/imfnat3_revert.patch` 回退那半刀重编：回退件对旧金标 GREEN、现役件 RED ⇒ 证明是金标过期。
**另需修**：门脚本的 dll 回退加载（`__file__` 同目录）——那颗 11-04 散件我已改名 `src/bench/sycl/libxmx_sycl.dll.STRAY-11-04.disabled`；仍应加 `EXPECT_DLL_MD5` 自检（草案已写，未实现）。
