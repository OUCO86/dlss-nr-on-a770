# 当前出货件 provenance（唯一权威：`out/SHIPPED_MD5.txt`）

| 项 | 值 |
|---|---|
| **两槽 md5** | `A05A47AB302FA4D1545F41AA46B4A260`（`out\libxmx.dll` = `oneapi\libxmx_sycl.dll`，3,949,056 B）|
| **源码提交** | `f2a49ac`（Reapply com2）——**构建发生在 `4263111` / `030fb7f` / `d2edda2` 之前** |
| **构建方式** | `tools/build_shipped.ps1 -Tag shc2b`，走 `tools/shipped_build.defs` 基座（`/DT_SKIP_CHAINS_DEF="18,…,32"`、`/DT_ATT5_FUSE_DEF=1`；header 守卫 `s6_ffn_block_kernel.hpp = 490647A9…`）|
| **构建日志 / 产物** | `E:\DSH\logs\build_shc2b.log`、`E:\DSH\builds\libxmx_shc2b.dll` |
| **帧读数** | 出货口径 8 对 **−1.015 ms、8/8**（vs 上一转正件 `E0B03E90`）⇒ **≈55.1 ms/帧** |
| **当时门链** | `gates: 40 GREEN / 0 RED`（那时 `gate_window_block` 与 `gate_gemm_f16_qkv_window` 尚未在 cold 态被复现为红）|
| **回退件** | `builds\keep_pre_com2_E0B03E90.dll`、`builds\libxmx_pre-shiplw1-3BAECF2A.keep`、`builds\libxmx_sycl_3BAECF2A.keep`、`out\libxmx.before-ATT5.keep`（`ABB969FE`）|
| **金标** | `bk.1301.bin` / `bk.1301.skip.bin` = `DD49827DD33A7EF07C2C17892F18970D`；`bk.1301.pre-skip-1a.bin` = `249A46F374E9` |

## 已知偏差（每次转正必须消掉）
- **HEAD 比出货件多出三笔"仅仪表"提交**：`030fb7f`（`rtcsv` 同行带 `pf`，验收 `changed = 0 of 270`）、`d2edda2`（`gate_skip_graph` 文案）、`4263111`（`access_bw.csv` 数据）；**再加本次** `NR_V2_STOP` 门控的阶段 dump（+16/−1，默认不生效）。
- ⇒ **下一次转正必须从 HEAD 重新构建并重新认证**：cold 帧面四闸 + 门链 **38 绿 + 2 已知红** + 出货 16 对 + 同批 4 对对照；**然后更新本文件**。
- ⇒ **在此之前，任何 A/B 的 A 侧一律用 `A05A47AB…` 这只实体件**，**不许拿"HEAD 重建件"冒充 A**（否则仪表差异会混进刀效应）。

## 两条已知红门（详见 `tools/gates_known_red.md`）
`gate_window_block`（9 fails）、`gate_gemm_f16_qkv_window`（5 fails）：
- **cold 态对 11-01 至今每一件都复现，反例一字不差**（`410f34c` → 今天）；
- **(c2)(c3) 探针已证明根因在 composition 内部**：**归一化倒数完全相同（Q/K 行各 0/384、max bit-ulp 0）**、**残差是融合 `fma` 与参考一致**；
- **出货几何偏离量：4.287% 字节 / 6.45% 像素受影响 / 24,336 个元素相对差 >20%**；
- **是否对齐厂商由用户裁画质门**（现路已被实机验收；未裁之前 `composition` 一行不动）。
