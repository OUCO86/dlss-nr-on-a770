# gates_caliber_notes.md — 门链的**两种口径**、必读的 selfcheck 行、以及旧"已知红门"结论的作废（2026-11-07 09:1x，子代理写、父级入库）

> 本文件取代 `tools/gates_known_red.md`（那只留一根指针）。
> **军规 146**：任何门读数必须写明**本次实际加载的 dll 路径 + md5**；不带这两行，读数不算数。
> **军规 147**：`gate_graph` 与 `gate_skip_graph` 是 **CWD 敏感门**，不是件敏感门 ⇒ 必须 **staged 口径**测。

## 1. 两种口径，各自适用哪些门

| 口径 | 怎么跑 | 适用门 | 已知表现 |
|---|---|---|---|
| **staged**（`RUNDIR=CWD=E:/DSH/oneapi`，即加载槽本体） | `bash E:/DSH/dlss-nr-on-a770/tools/dsh_run_gates.sh`（默认 `RUNDIR=E:/DSH/oneapi`） | **全部 40 门**（唯一能让 `gate_graph`/`gate_skip_graph` 有效工作的口径） | 现槽 `F2364615…` = **40 GREEN / 0 RED** |
| **scratch**（`RUNDIR=E:/DSH/tmp/gs_<tag>`，里面放被测变体并命名 `libxmx_sycl.dll`） | `RUNDIR=E:/DSH/tmp/gs_<tag> SYCL_CACHE_DIR=E:/DSH/tmp/syclcache_<tag> GATE_ONLY=… GATE_ENV="…" bash tools/dsh_run_gates.sh` | **只有 38 门可用**；`gate_graph`、`gate_skip_graph` 在此口径下**必红**（与件无关） | 现槽与变体在此口径都是 **36 GREEN / 4 RED**（4 = 2 只 CWD 敏感 + 当时另两只） |

**CWD 敏感门的失败签名**（用来一眼判定是口径问题而不是件问题）：日志里先出现
`[skip-chains] chain=NN OUT OF RANGE (valid 0..18446744073709551615)` ⇒ **链登记表为空**，随后 `gate_graph` 崩在 `xmx_buf_download` 的访问违例（`OSError: exception: access violation reading 0xFFFFFFFFFFFFFFFF`）。
**实测对照（同一只件、同一冷编译、只换 CWD）**：`A05A47AB` 在 `CWD=E:/DSH/oneapi` 下 `gate_graph` **GREEN** + `gate_skip_graph` **GREEN**；在任何 scratch 目录（**连 oneapi 的 16 只依赖 dll 全复制进去都一样**）下两门 **RED** ⇒ **依赖解析不是变量，CWD 才是**。

## 2. `[gate-selfcheck]` 两行（每份门读数必须带）

```
[gate-selfcheck] loaded dll = E:/DSH/tmp/gs_smax1v/libxmx_sycl.dll  md5 = aa8ad914ad48550b5cbd1a3d6fe52ecf
[gate-selfcheck] SYCL_CACHE_DIR = E:\DSH\tmp\syclcache_smax1v (persistent=1)
```
`tools/dsh_run_gates.sh` 现在自己打这两行（`RUNDIR` 可覆盖 ⇒ 测变体成为可能；默认专用空缓存 `E:/DSH/tmp/syclcache_cert`；`E:/DSH/oneapi` 留在 `PATH` 上解析 `sycl9.dll` 等依赖）。
**更强的进程内证明**（子代理工装 `s6/gate_selfcheck.py`，runpy 跑门 + `GetModuleHandleW("libxmx_sycl.dll")`/`GetModuleFileNameW` 取**真实加载路径** + md5，`finally` 保证崩溃也打）：
`GATESELFCHK dll_loaded_path=E:\DSH\tmp\gs_smax1v\libxmx_sycl.dll md5=AA8AD914… cache=E:\DSH\tmp\syclcache_smax1v_sc cwd=E:\DSH\tmp\gs_smax1v`

## 3. ★ 旧结论作废：`gates_known_red.md` §3 那张表 **caliber suspect — 未复现**

旧表写的是"11-01→今天每一件在 cold 态都红 `gate_window_block`(9 fails) 与 `gate_gemm_f16_qkv_window`(5 fails)，反例一字不差"。**它依赖的仪器是 `s6/run_gates_scratch.sh` 旧版**：`:22` 硬编码 `export DSH_ONEAPI="E:/DSH/oneapi"`，而门脚本 `gate_*.py` 用 `_STAGE=os.environ["DSH_ONEAPI"]` ⇒ `os.chdir(ONER)` ⇒ `CDLL(cwd/libxmx_sycl.dll)` ⇒ **门链一直在加载加载槽实体件，`cp` 进 `gs_<tag>\` 的变体从未被加载**。所以那张表实际测的是"同一只槽件在同一次冷编译下的重复读数"——**它的"每件都红、反例一字不差"恰恰是这套失效仪器的必然结果**。
**修好仪器后的复跑（2026-11-07，cold、专用空缓存、串行）**：
| 件 | md5 | 口径 | 成绩 |
|---|---|---|---|
| 旧出货槽 | `A05A47AB302FA4D1545F41AA46B4A260` | **staged**（`CWD=E:/DSH/oneapi`，缓存 `syclcache_gatetests`，专项 4 门腿） | **子代理 08:5x 实测：`gate_graph` GREEN、`gate_skip_graph` GREEN、`gate_window_block` RED、`gate_gemm_f16_qkv_window` RED** |
| 旧出货槽 | 同上 | scratch（`gs_slot` + `syclcache_slot`） | 36 GREEN / 4 RED（红 = `gate_graph`、`gate_skip_graph`〔CWD 敏感〕+ `gate_window_block`、`gate_gemm_f16_qkv_window`） |
| softmax 新形变体 | `AA8AD914AD48550B5CBD1A3D6FE52ECF` | scratch（带 `[smaxform]` 分流） | 36 GREEN / 4 RED ⇒ **RED 集与槽件相同，零新增失败** |
| **转正后的现槽** | **`F2364615EB59CED27F08A893E938C809`** | **staged 与 scratch 各一次（父级 09:0x）** | **40 GREEN / 0 RED（staged）**；父级称 scratch 口径亦 40/0，**与子代理 08:5x 的 scratch 读数（4 红）不一致** |
**⇒ 两份"翻案"读数（父级 09:0x：旧槽两门 GREEN）与子代理 08:5x 的读数（同一只旧槽同两门 RED，两种口径都 RED）尚未对齐 ⇒ 这两门的红/绿目前是待复现项，不得当件属性写进任何合格线。**
⇒ **旧表把这两门当作"件属性恒定红"的记账作废**（仪器确实失效过：门链曾一直测加载槽件）；**但两门目前处于"两份读数不一致"状态（见上表末两行）⇒ 在复现之前，谁也不能把它们写成恒定红或恒定绿**。现行合格线按 **staged 口径 40 GREEN / 0 RED**（父级 09:0x 转正读数）执行，**子代理 08:5x 的 4 红读数列为待复现项**（§4 的复现命令同样适用于这两门）。
**语义事实仍然成立**（来自只读探针，与门链读数无关）：composition 与 3-leg 链在出货几何差 **4.287% 字节 / 6.45% 像素**；归一化倒数与残差融合形都被洗清；**用户已裁决：不要求对齐厂商算法** ⇒ 两条内部路互不一致本身不是 bug。

## 4. 待复现项（复现之前不许当证据）

**2026-11-07 20:09 那次 staged 门链报的 `6AEE1ADE`（`libxmx_shicom2.dll`）5+9 fails 至今未复现**：本文件 §3 的复跑里同一只件在 scratch 口径 = 36 GREEN / 4 RED，**RED 集里没有 5+9 fails 那两门的形态**。两个候选成因，按优先级排：
1. **共享缓存里的旧 Gen**：那次跑用了非专用/复用的 `SYCL_CACHE_DIR`（军规 141 之前的习惯）⇒ 门脚本执行的是**来历不明的旧机器码**，与当时 dll 源码不一致（`sycl-cache-managed-1107.tar` 快照就是为这类取证留的，**它是取证材料，不是认证环境**）；
2. **那次 shell 的 `NR_*` 泄漏**：门脚本会继承调用方环境里的 `NR_*` 开关（`ab.ps1` v3 就是为此才在每腿开头清 `NR_*`）⇒ 比如 `NR_SKIP_CHAINS` / `NR_GA_TILE` / `NR_WB_V4` 被上一次实验留下，直接改变被测路。
**复现命令（照抄即可，两行前置检查是硬要求）**：
```
env | grep -E '^(NR_|SYCL_|DSH_ONEAPI)'          # 1) 看有没有泄漏；有就 unset 再跑
ls -l "$SYCL_CACHE_DIR"                          # 2) 必须是**专用空目录**（新 mkdir，不是复用、不是 E:/DSH/sycl-cache）
mkdir -p E:/DSH/tmp/gs_shicom2 E:/DSH/tmp/syclcache_g_shicom2
cp E:/DSH/builds/libxmx_shicom2.dll E:/DSH/tmp/gs_shicom2/libxmx_sycl.dll
RUNDIR=E:/DSH/tmp/gs_shicom2 SYCL_CACHE_DIR=E:/DSH/tmp/syclcache_g_shicom2 SUFFIX=_repro \
  bash E:/DSH/dlss-nr-on-a770/tools/dsh_run_gates.sh
```
（`gate_graph`/`gate_skip_graph` 在此口径下红属正常，见 §1；要判这两门必须 **staged**。）

## 5. 与本文件有关的两条**仪器级**新事实（已入 layer1 §53d/§56）

1. **ocloc 的 `.ze_info` 不吐 `slm_size`（键不存在 ≠ 0）**：`local_accessor` 核（softmax 新形）在 `.ze_info` 里表现为 payload 参数 `arg_type: arg_bypointer / addrmode: slm / addrspace: local`，**没有 `slm_size` 键**；`private_size`/`spill_size` 两个键也**根本不存在**（只在真有 scratch 时出现 `type: scratch / size: N`）⇒ **过去所有台账里的 `slm=0`/`-` 是"键不存在"，不是"值为 0"**（`pe_append121.py:9` 已记同类缺口）。
2. **launch 期分配可用"撞上限"探针实测**（`E:\DSH\builds\smax2_slm_probe.exe`，md5 `6AAFB2B1…`，日志 `s6/smax2_slmprobe.log`）：`1,024 / 7,168 / 65,536 B` **ACCEPTED**（并真读写最远端），`80,000 B` **REFUSED = level_zero error 40** ⇒ 请求量按字节兑现。**同一方法现在要用于 `window_block`：`leg_decomp.csv` 的 `slm_bytes=45,056` 目前只是源码里的 `esimd::slm_init<45056>()` 常量（`window_block_v4.hpp:22/36`），**尚无 launch 期实测**（layer1 §56 待办）。
