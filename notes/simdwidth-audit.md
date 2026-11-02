# simd 宽度审计铲（2026-11-02，分支 ds-quality-relax-2026-11-02，HEAD 7a9dd58）

纪律：只写 E:\DSH\；不动 out\libxmx.dll (E2D5E574)；变体出 E:\DSH\builds\libxmx_simd<N>_<tag>.dll；不 commit/push。
A 侧基线 = E2D5E574（含 1a）。ab.ps1 v3 协议（两侧不设 env，16 对，≤−0.5 且赢≥10/16 = 转正）。

## 0. 开工前核实的两个关键事实（改变本铲走向）

**F1：shipped dll 的 `smax::vit_softmax_tiled` 台账本来就是 simd=8**（`E:\DSH\s6\WBGA_ledger_dll.txt` :23）。
§37/§9c 那条 −15% 阶梯（SG4 2.0654 / SG8 2.0678 / SG16 2.2776 / SG32 2.2777 / IGC自选16 2.4330）
是**探针 TU 内部**的对照：探针用 `nd_range local=SG` 钉 WG 宽度（`wb_ga_probe.cpp:113-158`），
其 range<1> 调用形在探针 TU 里 IGC 自选了 16 —— **探针的 2.4330 不是 dll 的价**。
⇒ **softmax 的"16→8"这笔钱在 shipped 里已经在袋**；dll 上剩下的宽度空间只有 8→4（探针阶梯 0.1% = 噪声级）。
⇒ 本铲主靶改为**台账里宽度可疑的其他核**：`packdev::pack_a16_b/pack_b16_b/pack_b16_t_b`（**simd=32**）、
  `qr_kernel`/`merge_heads`/ffn 族（待全引擎台账）、以及 simd=1 的 ESIMD 族（dpas 操作数形状锁 N=8，见 §0-F2）。

**F2：属性写法可用性（仓内已有先例）**：
- `[[intel::reqd_sub_group_size(N)]]` 挂在**核 lambda 参数表之后**：`bench_reqd_esimd.cpp:40-44`、`bench_jmf32.cpp:37` —— 本工具链可用、已在 plain nd kernel + esimd 体上试到过 section 96。
- **红警**：`refs/a770-skill/references/workflow/pitfalls.md:130` —— joint_matrix 核上 `sub_group_size<16>`/`reqd_sub_group_size(16)` 触发 **IGC 内部 divide-by-zero**（oneAPI 2026.1）。ESIMD dpas 核的 `simd<half,128>` 操作数形状**强制 dpas N=8**（bench_reqd_esimd 头部注释）；reqd32+esimd+dpas 曾疑 div0。⇒ **矩阵族（gemm_b/launch_v4full/launch_v4ph/qres/wares）的宽度刀有仪器地雷，SIMT 族（softmax/pack/qr/merge）才是安全靶**。
- 工具链另有 `sycl::ext::oneapi::experimental::properties::sub_group_size<N>`（`include/sycl/ext/oneapi/kernel_properties/properties.hpp:219`）= 推荐新写法；handler.parallel_for 的 property 重载已 deprecated。

## 1. 第 1 步设计（对任务书的两处偏离，先记后做）
- 任务书预期"台账 simd 16→8"；实际 dll=8 ⇒ 改成**强制 4**（预期台账 8→4，证属性有效；探针阶梯 4≈8 ⇒ 预期带内）。
  这仍满足失败线的实质："属性是否真的改变台账 simd 列" + "1301 必须 EXACT"。
- 属性用 `[[intel::reqd_sub_group_size(N)]]` 宏门控（编译期 -D 选 N），一行不改数值路径。

## 2. 全引擎台账基线（07:45-07:55，空缓存 walk 法复用诊断铲；产物 E:\DSH\s6\SIMD_ledger_dll_full.txt + simd_ledger_base.csv，262 行）
- **每个核在运行期缓存里有两种命名实例**：`RoundedRangeKernel<...>`（range-launch 包装）与裸闭包 `_ZTSZ...`；**两者的 simd 可以不同**：
  pack 族 = 16（Rounded）/**32（闭包）**；vit_softmax 两形都 = **8**；qr/gemm/wbv4/ffn2 两形都 = 1。
- **诊断铲旧台账的两个仪器错**（本轮新证）：
  (a) 旧 spillcheck_wbga.py 去重 key 不含 simd ⇒ 同名两实例**塌成一行**（"pack simd=32" 只报了闭包形）；
  (b) 旧 label() 子串匹配把 **gather_pack_b16_t_b**（private=608 的那条）误标成 pack_b16_t_b ⇒ **红点真身 = gather_pack_b16_t_b 的闭包形实例**，
      且该实例 **scrInstr=0**（private 分配了但 .text 里无 scratch 访存）= IGC 保守预留、无实测流量代价；同 TU 的 Rounded 形（simd=16）没有 private。结案。
- 新红点（本铲登记，未追）：qkv_scatter private=7680；pack_a_fused* scratch 1376-1472B（scrI 0-211）；ffnc::launch_ffn_chip scratch 2272B/350 条；stem_mega scratch 1024B；b6 scratch 512B/6 条；f16v3::gemm_resid_pub 512B/4 条。

## 3. 第 1 步属性写法验证（smx4 变体，75269BEC，07:58）
- `[[intel::reqd_sub_group_size(4)]]`：**编译通过（仅 deprecated 警告，clang 建议换 [[sycl::reqd_sub_group_size(N)]]，同一 lowering）；launch 时运行期拒**：
  `step 5252 (xmx_graph_run): graph_run: Sub-group size 4 is not supported on the device`；台账里该核仍 = **8**（IGC 没按 4 出码）。
  ⇒ **A770 合法宽度只有 8/16/32**（hardware.md:21）；探针阶梯的"SG4"是 **nd_range WG=4**，不是 sub-group=4，两回事。
- 1301 未出 dump（walk 在 5252 步死）⇒ 该变体作废，属"宽度非法"而非"数值改变"，不触发 MISMATCH 停线。
- **⇒ 机制验证改走：softmax 强制 16（台账应 8→16）+ pack 强制 8（台账应 16/32→8）**；值候选=pack8（32→8 是探针阶梯里明确输的那档）与 smx8（pin 效应：探针里 forced16 比 auto16 还快 6%）。

## 4. 基线控制（新发现，必须入 ab）
- **HEAD 无旗标重建 = 73C050E6 ≠ E2D5E574**（shipped 早于 HEAD 已合入的默认-OFF 机制如 bgfold/qfuse；§35 已证默认侧帧 62.97-63.13 ≈ E2D5E574 63.26-64.58 带内）。
- ⇒ 所有变体都从 HEAD 编 ⇒ **补一发 ctrl_nohup vs E2D5E574 的 16 对**隔离基线差；变体 delta 若与该控制同号同量级 = 带宽内不算钱。

## 5. 帧夹逼（ab.ps1 v3 协议：两侧无 NR_* env，A=E2D5E574，16 对；缓存 env 仅 SYCL_CACHE_* 仪器用）
| 靶 | 变体 md5 | 16 对均值 | 赢 | 95%CI | 判定 |
|---|---|---|---|---|---|
| 控制（HEAD 无旗标） | 73C050E6 | +0.048 | 7/16 | [-0.21,+0.33] | 带内 ⇒ 基线差已隔离 |
| smx pin8 | D9A89366 | **+0.234** | 3/16 | [+0.01,+0.42] | 带内偏负 ⇒ pin 效应不是钱 |
| smx16 | CA3C5BE2 | **+0.362** | 2/16 | [+0.19,+0.61] | **CI 不含 0 的退让** ⇒ 宽度阶梯在 dll 上成立（+10.5% softmax 价），shipped 已在 8=赢家档 |
| pack8（GA 三腿） | A5A0A59A | -0.049 | 9/16 | [-0.34,+0.24] | 带内（腿太小，-15%≈-0.13ms 帧淹没在噪声） |
| packwide8（31 条 SIMT pack/gather 腿） | 29CD588E | **+1.952** | 0/16 | [+1.68,+2.18] | **明确判负** ⇒ pack 族 IGC 选 32 正确；往下切宽度 = 每帧 +2ms |

（walk 帧口径旁证：控制 63.2-63.5 / smx8 63.2-63.9 / smx16 63.3-63.6 / pack8 63.1-63.6 / merge8 62.9-63.5 / packwide8 **64.5-65.4**。）

## 6. 判决（四行交回）
**① 哪种属性写法真的改变台账**：`[=](sycl::item<1> it) [[intel::reqd_sub_group_size(N)]] {`（N∈{8,16,32}）——**只改「闭包命名形」实例，而闭包形正是活实例**（packwide 铁证：Rounded 形全程 16 不动，帧却 +1.95）；`RoundedRangeKernel` 包装形忽略挂在被 inline 内函数上的属性（非核入口）。N=4 编译过但运行期拒（设备无宽度 4，台账也不动）。**SYCL_ESIMD_KERNEL 核与 reqd_sub_group_size 在 clang 前端互斥**（error: attributes are not compatible；两种顺序都试过）⇒ qr/wbv4/gemm/ffn2 全矩阵族**没有属性级宽度刀**。
**② 逐靶表**：见 `E:\DSH\s6\simdwidth.csv`（10 行，含每核台账前后 + EXACT + CI）。全部变体 1301 EXACT（宽度只改并行形态，数值零风险，无一 MISMATCH）。
**③ 合计能到多少 ms/帧**：**0 ms/帧（可转正档 = 空集）**。§37 肉 3 的 −1.3ms/帧 是**探针 TU 内部对照**（探针 range<1> 形自选 16 vs 探针 forced 8），**shipped dll 的活实例本来就是 8 ⇒ 这笔钱早已在袋**。本铲把宽度阶梯正反两向都钉死：softmax 8→16 = +0.36ms（阶梯成立）、pack 32→8 = +1.95ms（IGC 的宽档对 gather 腿是正确的）。
**④ 建议**：**不写死任何 reqd_sub_group_size 进 shipped**（smx/pack/merge 现宽已是各族赢家档；pin 效应实测 +0.23 微负）。宏门（SIMDREQ_SMAX/PACK/MERGE，默认 0=shipped 行为）**留在 relax 分支当砖**：将来若重写 launch 形（range→nd_range 或 properties-tag）可复用。矩阵族想动宽度必须走 ESIMD properties/几何路线（非一行属性），且 §37 已判矩阵腿贴屋顶——不值。

## 7. 红点结案（诊断铲待查项）
- `packdev::pack_b16_t_b private=608B` 真身 = **gather_pack_b16_t_b 的闭包形（32 宽）实例**；旧 spillcheck_wbga.py 两处仪器错（去重 key 不含 simd；label 子串匹配把 gather_* 误标进 pack_*）。608B 无 scratch 访存指令（scrInstr=0）= IGC 保守预留、无实测代价；强制 8 会消除它但宽度 8 亏 1.95ms ⇒ **结案：不动**。
- 新登记（未追）：qkv_scatter private=7680B；pack_a_fused* scratch 1376-1472B（scrI 0-211）；ffnc::launch_ffn_chip scratch 2272B/350 条；stem_mega 1024B/14 条；b6 512B/6 条；f16v3::gemm_resid_pub 512B/4 条。

## 8. 现场纪律
- 只写 E:\DSH\：新件 E:\DSH\s6\{simdwidth.md, simdwidth.csv, spillcheck_simd.py, simd_ledger_parse.py, wl.ps1, build_variant.sh, build_chain*.sh, qr_probe_build.sh, patch_s8v9.py, SIMD_*.log/.txt, simd_ledger_base.csv}、E:\DSH\builds\libxmx_simd{4,8,16}_{smx,pack,packwide,merge}.dll + libxmx_ctrl_nohup.dll、E:\DSH\sycl-cache-{smx4,simd8_smx,simd16_smx,simd8_pack,simd8_packwide,simd8_merge,ab}、E:\DSH\tmp\{smx_attr_check.cpp,pc_simd_*}。
- **未动**：out\libxmx.dll=E2D5E574 ✓、out\libxmx_new.dll=460FC367 ✓、oneapi\libxmx_sycl.dll=E2D5E574 ✓（从未 stage）。
- 源改动（relax 分支、未 commit）：softmax_kernel.hpp / pack_device.hpp / quantize_row_kernel.hpp / libxmx_sycl.cpp(merge) / gemm_s8_v9{,b,c}_kernel.hpp —— **全是宏门控属性，默认 SIMDREQ_*=0 ⇒ 无属性 ⇒ 行为与 shipped 逐字节同源**。
- GPU 独占检查跑前跑后各一次：无 LOP/游戏、无其它 replay；跑完无残留进程（nr_replay_now/icx 全零）；无临时 exe 遗留（qrtest.dll 已在脚本内 rm；smx_attr_check.exe 见清理）。
- 没接新算法、没改数值、没 commit/push。
