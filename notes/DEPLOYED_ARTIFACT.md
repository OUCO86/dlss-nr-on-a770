# 当前出货件 provenance（唯一权威：`out/SHIPPED_MD5.txt`）

| 项 | 值 |
|---|---|
| **两槽 md5** | **`AF5A19B30E40B7594C142691F54B5B97`**（`out\libxmx.dll` = `oneapi\libxmx_sycl.dll`，3,382,272 B）|
| **源码提交** | **`92259ae`（IMF→原生算术根替换）** —— 构建 `tools/build_shipped.ps1 -Tag shfimf1`，走 `shipped_build.defs` 基座 |
| **构建日志 / 产物** | `E:\DSH\logs\build_shfimf1.log`、`E:\DSH\builds\libxmx_shfimf1.dll` |
| **帧读数（认证）** | 出货 **16 对 −5.763 ms、16/16、sd 1.295（2σ=2.591，\|均值\|/2σ = 2.2）**；A 侧 = 上一上线件 `F2364615`（均值 55.59）⇒ **B 均值 49.83 ms/帧**（min 48.82 / max 50.56）；**用户实机验收：画面没问题、帧数提高不少** |
| **门链（修好的仪器，带 `[gate-selfcheck]`）** | **`40 GREEN / 0 RED`**（staged 口径、当场新建空缓存 `tmp\syclcache_cert_imf_2350`）|
| **★ 但门链不覆盖 fused 三面** | 见 **`tools/fused_face_baseline.md`**：`gate_graph/gate_coexist/gate_skip_graph/gate_ffn/gate_chain_qkv` 里对 `ADC96F5D/872C70D0/CACD2029/254C02B7/DAC32974` **全部 0 命中** ⇒ **fused 路基线另立**（当前 = `254C02B7… / CACD2029… / DAC32974…`）|
| **回退件** | **`builds\libxmx_shsm1.dll`（`F2364615…`，51.5 ms/帧）**、`builds\keep_pre_smax_A05A47AB.dll`、`builds\keep_pre_com2_E0B03E90.dll`、`out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **上一件（已回退位）** | `F2364615EB59CED27F08A893E938C809`（源码 `993404f`，≈51.5 ms/帧，门链 40/0、三面 EXACT）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`（**非 fused 路，本刀逐字节未变**）；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |

## 已知偏差（每次转正必须消掉）
- **本次转正已对齐**：**出货件 `F2364615` 的源码 = HEAD `993404f`**，**包含全部仪表提交**（`030fb7f` rtcsv 带 pf、`d2edda2` 门文案、`4263111` access_bw、`246991a` NR_V2_STOP dump、`2a4c9eb` 门链 selfcheck 修复）。
- ⇒ **规则不变**：**下一次转正必须从 HEAD 重新构建并重新认证**：cold 帧面四闸 + **门链带 `[gate-selfcheck]` 两行（加载 dll 的路径 + md5 与 `SYCL_CACHE_DIR`）** + 出货 16 对 + 同批 4 对对照；**然后更新本文件**。
- ⇒ **A/B 的 A 侧一律用"上一只实体件"的副本**（本次是 `builds\keep_pre_smax_A05A47AB.dll`），**不许拿"HEAD 重建件"冒充 A**。

## 两条曾被宣布为"已知红"的门：现状 = GREEN（口径已修）
`gate_window_block`、`gate_gemm_f16_qkv_window`：
- **用修好的仪器（`RUNDIR` 可覆盖 + `[gate-selfcheck]` 打印加载件 md5 + 专用空缓存）复跑**：**旧件 `A05A47AB`（staged 与 scratch 两种口径）GREEN**、**新件 `F2364615`（两种口径）GREEN**、**新件全链 `40 GREEN / 0 RED`（两种口径各一次）**；
- **因此 `tools/gates_known_red.md` §3 那张"冷编译下每一件都红、反例一字不差"的表不可复现**：它是在**旧版 `s6/run_gates_scratch.sh` 硬编码 `DSH_ONEAPI=E:/DSH/oneapi`**（⇒ 门链其实一直在测加载槽件）的条件下取得的；**该文件必须重画**（口径表 + 复现命令 + 旧结论标为 `caliber suspect — 未复现`）；
- **仍未解释的一条**：20:09 那次 **staged 口径**（当时默认用**共享** `E:/DSH/sycl-cache`）里 `6AEE1ADE` 报 5+9 fails，而同源码的 `A05A47AB` 在专用空缓存下 40/0 ⇒ **待复现**（候选：共享缓存里的旧 Gen、或那次 shell 的 `NR_*` 泄漏）；**复现之前不许把它当证据**；
- **仍然成立的两条语义事实**（来自探针，与门链读数无关）：**实机 composition 路与 3-leg 路在出货几何差 4.287% 字节 / 6.45% 像素**；**归一化倒数与残差融合形都被洗清，分叉在 composition 内部**；**用户已裁决：不要求对齐厂商**（"我没要求你用原厂算法"）。
