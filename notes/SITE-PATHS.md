# 现场路径台账（交接必读，2026-11-08 补记）

**补记原因**：我此前**没有把"游戏装在哪、实机日志在哪"写进任何账本**，导致用户问 NR 延迟时我找了十分钟。这份文件是硬缺口修复，**任何接手者先读这一页**。

| 项 | 值 |
|---|---|
| **游戏可执行与加载目录** | **`F:\Game\Lies of P\LiesofP\Binaries\Win64`**（`LOP-Win64-Shipping.exe`；**`dxgi.dll` = 26,664,448 B、10-14 15:00，是加载器**；oneAPI 运行时 `ur_adapter_level_zero*.dll`/`umf.dll`/`svml_dispmd.dll`/`libiomp5md.dll`/`common_clang64.dll` 等；另有一堆 `dlssnr_on_amd_setup*.exe` 安装器）|
| **UE 日志** | 该目录下**没有** `LiesofP\Saved\Logs`（深度 0-2 未见）⇒ **实机 NR 读数不看 UE 日志，看下面那条** |
| **★ 实机 NR 延迟日志** | **`E:\DSH\out\nr_net.log`**（写手 = **`E:\DSH\out\nr_net.dll`**；源码 `src/gpu/nr_net.h`、`src/gpu/nr_net_probe.c`）|
| **日志格式** | `record_fused: extent 544x960 = 522240 pixels, pitch 960, source 540x960`；`walk run #0: <ms>`；**每 5 帧一条 `nr_net_run #N: <ms>`**；**每 30 帧一条 `nr_net_run: 30 frames, min <x> ms, running-median <y> ms`** |
| **⚠ 关键限制** | **该文件每次游戏启动会被截断**（`created 11-01 00:47`、`modified 11-08 06:36`、**全文 789 行 = 130 个 30 帧窗 = 当前这一局**）⇒ **上一局的实机延迟不可回溯** |
| **汇总脚本** | **`E:\DSH\s6\pe_nrlog_sessions.py`**（按 `walk run #` 分段，输出每段 30 帧窗的 min/median）|
| **我们那颗 NR 件** | **`E:\DSH\out\libxmx.dll`** 与 **`E:\DSH\oneapi\libxmx_sycl.dll`**（两槽同 md5）；**身份权威 = `E:\DSH\out\SHIPPED_MD5.txt`**；provenance = `notes/DEPLOYED_ARTIFACT.md` |
| **要"实机 A/B"只有两条路** | ① **同一天、同场景、重启两次**（换槽一条命令，用户重启读数，比 30 帧窗中位）；② **给 `nr_net` 日志加会话头/时间戳/追加模式**（**属桥接侧仪表 ⇒ 必须先问用户是否允许动 `src/gpu/nr_net*`**）|
| **游戏进程名（每批 GPU 前必查）** | **`LOP-Win64-Shipping.exe`** |
