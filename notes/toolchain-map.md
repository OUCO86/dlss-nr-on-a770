# 工具链位置地图（2026-10-16 21:40）—— 防清理 · 防误判 · 防装到 C 盘

> 规矩：**所有工具一律装在 E 盘**（用户明令：C 盘没空间，且发生过工具被清理的事故）。
> 任何新会话/新任务开工前，先读本文件，不要靠扫磁盘猜"本机有没有编译器"。

## 1. 主工具链（都在 E:\WorkBuddy\，不会被 C 盘清理波及）

| 东西 | 绝对路径 | 版本/大小 | 装法与出处 |
|---|---|---|---|
| **SYCL/DPC++ 编译器 icx** | `E:\WorkBuddy\toolchain-mamba\sycl\Library\bin\icx.exe` | conda-forge `dpcpp_win-64 2026.1.1`（498 MB 全套） | micromamba 装，`MAMBA_ROOT_PREFIX=E:\WorkBuddy\toolchain-mamba\root`，HOME/TMP 全锁 E 盘（见当天日志 15:43 节） |
| **Level Zero SDK**（头+loader） | `E:\WorkBuddy\toolchain-mamba\sycl\Library\include\level_zero\{ze_api.h,ze_ddi.h}`；`Library\lib\{ze_loader.lib,ze_validation_layer.lib,ze_tracing_layer.lib}` | `level-zero-devel`（conda-forge，2026-10-16 装进同一 env） | 探针②用 |
| **SYCL 运行时 dll（跑 exe 的地方）** | `E:\WorkBuddy\2026-10-09-04-20-55\oneapi\`（sycl9.dll、sycl-jit.dll、ur_adapter_level_zero(.v2).dll、dnnl.dll、tbb12 等） | — | **exe 必须 stage 到这里从这跑**（MSYS 的 PATH 喂不饱原生加载器，前辈踩过） |
| **旧 oneAPI 运行时（前辈留的）** | `E:\WorkBuddy\2026-10-09-04-20-55\toolchain\oneapi\compiler\latest\bin\icx.exe` | 只剩 runtime，编译器本体已被前辈清掉 | `oneapi/build_probe.sh` 引的就是它 |
| **MSVC 编译器 cl.exe** | `E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.51.36231\bin\Hostx64\x64\cl.exe` | VS18 | 藏在 ProgramData 第 13 层——浅 find 会漏（踩过） |
| **Windows SDK** | `E:\Windows Kits\10`（Include/Lib `10.0.26100.0`） | — | 含 vulkan-1.lib/d3d12.lib 等 |
| **Python（隔离 venv）** | `C:\Users\wangz\.workbuddy\binaries\python\envs\default\Scripts\python.exe` | 3.13 | WorkBuddy 自带，别装包到全局 |

## 2. 编译命令（照抄，别自创）

- **SYCL/ESIMD 核**：`bash E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\bench\esimd\build_esimd.sh <src.cpp> <out.exe>`
  - 关键：flag 写 `//nologo //O2 //fsycl`（双斜杠），**不设 `MSYS_NO_PATHCONV`**；
    `SYCL_DEVICE_FILTER=level_zero:gpu`（ESIMD 只走 L0）；脚本自带 INCLUDE/LIB 与 stage+run。
- **纯 C++（非 SYCL，如 ze/D3D12/Vulkan 探针）**：照 `E:\WorkBuddy\2026-10-09-04-20-55\oneapi\build_probe.sh`
  的 env（INCLUDE/LIB=MSVC+SDK），icx 不带 `//fsycl`，`//link` 挂 `.lib`。
  先例：`enum_ext.exe`（Vulkan 扩展枚举，19:00 跑通）。
- **出货 C（libxmx/nr_net）**：`tools/build_fused.bat`；OptiScaler 侧 `tools/build_optiscaler.py`
  （⛔/MP 被沙箱误伤→进程级并行，脚本内注释）。

## 3. 防清理三条（用户要求）

1. 新工具只准装进 `E:\WorkBuddy\toolchain-mamba\`（conda env 同目录）或 `E:\WorkBuddy\2026-10-09-04-20-55\toolchain\`，
   **禁止 C 盘、禁止 `AppData`**；装前先看本文件确认没有现成的。
2. 每次安装后**把绝对路径+版本+装法追加进本文件**（这就是"文档里写上工具位置"的执行方式）。
3. `E:\WorkBuddy\toolchain-mamba\` 里放一个 `DO-NOT-DELETE.txt` 标记（见下），
   并在 `notes/INDEX.md` 挂本文件的链接，避免被当成临时目录清掉。
