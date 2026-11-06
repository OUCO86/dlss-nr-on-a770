# gates_known_red.md — 两条**已知红门**的挂账与认证口径（2026-11-07 04:4x，子代理起草，父级裁决）

## 1. 是哪两门、红成什么样（cold 态 = 专用空 `SYCL_CACHE_DIR`）

| 门 | 红数 | 首个反例（一字不差，跨所有件） |
|---|---|---|
| `gate_window_block` | **9 fails = 全部用例**（`gate_window_block.py:194-205`） | `WB-16x24-epi1-narrow: target differs from the 3-leg chain (16x24 flags=0x1100)`；另有 `flags=0x0`（f32out）、`0x800000`（pool）、`0x1000000`（head）、`0x808000`、`0x1008000`、`0x9100` |
| `gate_gemm_f16_qkv_window` | **5 fails**（只有 **Q 面**红，K/V 逐位相同） | `QKVW-16x24-float Q: 67 bad; first 131 got 0xb300 want 0xb380`；`QKVW-8x8-half Q: 12 bad; first 101 got 0x2d80 want 0x2d00`；`QKVW-40x56-float Q: 274 bad; first 100 got 0xaf80 want 0xb000` |

日志：`E:\DSH\logs\gate_window_block*.log`、`E:\DSH\logs\gate_gemm_f16_qkv_window*.log`。

## 2. 认证口径（从现在起固定）

**一条刀件的合格线 = `38 门全绿` + `上面 2 门已知红（挂本文件）` + （staged 阶段）`gate_skip_graph` 按设计红**。
**缓存态只认 cold**：**专用空 `SYCL_CACHE_DIR` + 串行 + 无并发 GPU 进程**；**hot（受管 `E:\DSH\sycl-cache`）降级为取证材料，不再是认证环境，也不许再往里写**（军规 141 已改文）。
**每份读数必须标注 cold/hot**。

复现命令（**不碰加载位**；门脚本从 CWD 加载 `libxmx_sycl.dll`，见 `gate_gemm_f16_qkv_window.py:42`）：

```
mkdir E:\DSH\tmp\gs_<tag> ; cp builds\libxmx_<tag>.dll E:\DSH\tmp\gs_<tag>\libxmx_sycl.dll
SYCL_CACHE_DIR=E:\DSH\tmp\syclcache_<tag> bash E:/DSH/s6/run_gates_scratch.sh E:/DSH/tmp/gs_<tag> _<tag>
```
`s6/run_gates_scratch.sh` 已加护栏：**拒绝** `SYCL_CACHE_DIR=E:/DSH/sycl-cache`（未显式指定时用 `E:/DSH/tmp/syclcache_gatescratch`）。

## 3. 为什么这不是"今天的刀改坏的"——复现表（全部 cold、同一对门、反例值相同）

| 件（sha/来源） | 日期 | 两门 |
|---|---|---|
| `libxmx_bi410f34c.dll` = 5067820E（`410f34c`，窗口里最早的提交，11-01 01:13） | 11-01 | RED (9) / RED (5) |
| `libxmx_bia5cd419.dll` = 63F57AFF（S6-1a 默认 TRUE） | 11-01 13:01 | RED (9) / RED (5) |
| `libxmx_bifbb1042.dll` = 689024D8（混合链 M1/M2/M3） | 11-01 21:26 | RED (9) / RED (5) |
| `libxmx_bi08e8b62.dll` = 2F91B5DA / `libxmx_bic36f4e1.dll` = 811EEEF3（WB 驻留刀） | 11-02 09:20 / 09:56 | RED (9) / RED (5) |
| `libxmx_lcount4.dll`、`libxmx_bis4.dll`（**§121 之前**的源码） | 11-06 | RED (9) / RED (5) |
| `libxmx_lcount22/25.dll`（**smax 刀之前**） | 11-06 | RED (9) / RED (5) |
| `libxmx_shiplw1.dll` B7CBE3A2、`keep_pre_com2_E0B03E90.dll`、`libxmx_ctl2.dll` 503E6007 | 11-06 | RED (9) / RED (5) |
| `libxmx_com2.dll` 81F1ABBA（= 现槽 `A05A47AB` 源码）、`libxmx_com2b.dll` A87D929A（去掉 qkv_window 一族）、`libxmx_com4.dll` 5ED8E016 | 11-06 | RED (9) / RED (5) |
| `libxmx_ship1.dll`（11-03）、`backup_shipped_slot.dll`（11-04） | 历史出货件 | RED (9) / RED (5) |

**⇒ 从 11-01 01:13 到今天的每一件都红、反例一字不差 ⇒ 与今天所有刀无关。**

## 4. "历史上是绿的"是怎么来的（取证结论）

- **冷 JIT 是确定的**：两条**独立**新缓存跑同两门 ⇒ 日志字节相同、首个反例相同。
- **运行时不是变量**：所有 scratch 运行都打印 `[xmx_init] loaded sycl9.dll = E:\DSH\oneapi\sycl9.dll`；`oneapi` 与 `toolchain-mamba` 两份 `sycl9.dll` 同为 2026.1.0 / 3,831,424 B。
- **绿只在受管缓存里存在过**：`E:\DSH\sycl-cache`（**已打包** `builds\sycl-cache-managed-1107.tar`，322,916,864 B，md5 `EFC45FBC8BDA521EBB02F28AFBF37240`，324 条目，最早 11-01 01:47:07、最晚 11-06 20:08:50）里那两族的旧 Gen 是 **13,309 ops / 4,448 fixup**，而今天冷编译是 **28,066 ops / 8,389 fixup**（`s6/l1_per_instance2.py` 逐实例、`s6/l1_pins_report.py`）⇒ **门过去几个月是在复用一份来历不明的旧 Gen**。
- **事故记录（诚实）**：11-07 03:3x 子代理为测"帧是否依赖旧 Gen"，把 hot 腿的 `SYCL_CACHE_DIR` 指向了受管缓存 ⇒ **可能覆盖了那两条关键条目**；当时**尚无打包**（父级未及时执行军规 141 的备份要求）⇒ 现以 `sycl-cache-managed-1107.tar` 为唯一快照。**该快照是取证材料，不是认证环境。**

## 5. 语义裁决（父级，2026-11-07）

- **`gate_gemm_f16_qkv_window` 的 numpy 模型是权威**（`gate_gemm_f16_qkv_window.py:111`：gather → e4m3 half A → acc → cosine norm → e4m3 scatter）⇒ **不许重生成 golden**（那等于把设备行为判为正确）⇒ **按 bug 追**。
- **`gate_window_block` 没有 golden 可改**：它是**内部自洽对照**（composition vs 3-leg chain，`gate_window_block.py:11,188`）⇒ 冷态两条路互不一致 ⇒ 要么其中一条算错，要么**门的前提已过期**（见下）。

## 6. 已定位的分叉点（只读分析，未改任何码）

1. **出货帧走的是 composition**：`xmx_rec_window_block` 在 `!pooling && !head` 且没有 `NR_WB_SPLIT/NR_WB_V3/NR_RESIDENT_WB/NR_FULL_MEGA` 时进 **`wbv4::launch_v4full`**（`libxmx_sycl.cpp:6014-6025`）；pool/head 走另外的融合腿。960×544 出货计划里 window_block 共 10 个闭包（`[lcount]` 串）。
2. **两条路从"中间量化"开始分叉**：3-leg 链的 QKV 腿把 Q/K 走**两次 half 舍入 + e4m3 散布**再让下一腿读回量化值（`libxmx_sycl.cpp:3013-3027`），而 v4full 把 acc 留在 f32 里**不做那几次中间往返** ⇒ **逐位相等从来不是这两条路的构造性保证**；§100 当年宣称的 "seven regions bit-exact vs v3 / 100.0000% x2" 比的是 **v3/出货路**，不是这条 3-leg oracle。
3. **换分辨率/缩放会不会咬人**：**不会新增这条分叉的影响**（出货路仍是 composition，分辨率只改 extent）；**真正的风险是**：`gate_window_block` 作为 window_block 的**独立交叉验证网从 11-01 起就没在工作**，所以任何分辨率下 window_block 的错都没有守门人。⇒ 修法二选一（父级定）：**(a)** 承认 3-leg 与 composition 语义不同、把门的判据改成"与参考 GLSL/numpy 模型逐位对"；**(b)** 让 composition 在 QKV 处**保留同样的中间舍入**（会花内存往返，违背 §100 的初衷）。

## 7. 这两门红**不影响**的东西（读数在此）

**帧面在 cold 态全 EXACT**：非 fused `1301 = DD49827DD33A7EF07C2C17892F18970D`；fused `features CACD202969C821D87CBDC033879CA7AB`、`1301 ADC96F5D272501BD8FB229EB732A4C70`、`result 872C70D098DCA8CAAC9C3DE94665EFD7`；`[lcount-total] pf=522`、`scr=1,287,057,408`、`[hop-total] 3396 planes / 30,786,624,936 B` 一字不差。
**帧时与缓存态无关**：hot 均 55.02 ms vs cold 均 54.96 ms（Δ +0.05，带内）。
**首帧代价与 JIT 无关**：cold `run0 = 65.89` vs `run1-3 = 56.25-56.48`；hot `run0 = 65.48-65.66` vs `run1-3 ≈ 56.0` ⇒ **首帧 +9.6 ms（+17%）来自图实例化/池首触**；冷编译的一次性代价落在**串行 walk 第一趟**（209.1 ms vs 152.7-153.4 ms = +56 ms）。
