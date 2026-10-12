# 在 Arc A770 上跑起来（Windows）

上游那份 README 讲的是 Lunar Lake iGPU + Linux。这一篇是 **Intel Arc A770 独显 + Windows**
的实际跑法，包括启动方式、实时开关、当前实测数字，以及踩过的坑。

---

## 一、硬件前提

| 部件 | 型号 | 作用 |
| --- | --- | --- |
| GPU0 | AMD RX 9070 XT（`VEN_1002&DEV_7550`） | 渲染游戏 |
| GPU1 | **Intel Arc A770**（`VEN_8086&DEV_56A0`） | 跑 NR 网络 |
| CPU | Ryzen 9 5900X 12C/24T | — |
| 内存 | 80 GB | 不是瓶颈 |
| 驱动 | 32.0.101.9030 | — |

> ⚠️ **这台机器上枚举顺序是 AMD 在前**，所以任何直接取 `pds[0]` 的代码都会选到
> 错误的卡。本分支用 `src/gpu/gpu_pick.h` 按 vendor / device id 匹配 Intel，
> **所有创建设备的入口都必须走它**。

### A770 特性（实测，不要再推断）

- coopmat fp16：**8×8×16**；int8：**8×8×32**
- **没有 bf16**（Vulkan 侧未暴露）
- **没有 large GRF 模式**（GRF 128 封顶）
- SLM：驱动上报 48 KiB / workgroup

---

## 二、启动游戏

### 方式一：双击桌面 bat（推荐）

双击桌面 **`DOOM Eternal (NR).bat`**。它只是个薄封装，真身是
`E:\WorkBuddy\2026-10-09-04-20-55\tools\nr_play.bat`，所以永远只有一份配置要改。

游戏路径：`F:\Game\DOOM Eternal\DOOMEternalx64vk.exe`
（**native Vulkan 版，双击就能直接跑，不需要 Steam**）

### 方式二：命令行

```bat
cd /d E:\WorkBuddy\2026-10-09-04-20-55\tools
nr_play.bat
```

`nr_play.bat` 做的事只有两步——**在同一个 cmd 里 `set` 完环境变量，再从它启动游戏**：

```bat
set "NR_ROOT=%REPO%"
set "NR_PYTHON=C:\Users\wangz\.workbuddy\binaries\python\envs\default\Scripts\python.exe"
set "PYTHONUTF8=1"
set "VK_LAYER_PATH=%REPO%\work\layer-win"
set "VK_INSTANCE_LAYERS=VK_LAYER_dlssnr_intel"
set "ENABLE_NR_LAYER=1"
set "NR_LAYER_SPAWN=1"
set "NR_LAYER_LIVE=2"
set "NR_LAYER_ASYNC=1"
set "NR_LAYER_SOCKET=\\.\pipe\nr_lop"
set "NR_LAYER_TRIGGER=%REPO%\work\nr_trigger"
set "NR_SETTINGS=%REPO%\work\nr_settings.json"
set "NR_LAYER_LOG=%REPO%\work\nr_daemon.log"

start "" /D "%GAME%" "%EXE%"
```

### 🔴 两条红线（违反 = 事故，都是真踩过的）

1. **只能用进程级环境变量**。在一个 `.bat` 里 `set` 完，再从**同一个 cmd** 启游戏。
   **禁止 `setx`、禁止写注册表、禁止注册隐式层**
   （`HKCU\SOFTWARE\Khronos\Vulkan\ImplicitLayers`）。
   那样做会让**所有 Vulkan 程序**都被注入 NR 层，最后得重启电脑才能恢复。

2. **daemon 不要手动起**。它由游戏自己 spawn（`NR_LAYER_SPAWN=1`），
   是游戏的子进程，游戏关它自动没。
   手动另起一个 = 两个 daemon 抢同一管道 `\\.\pipe\nr_lop` = **游戏卡死**。

---

## 三、加载链路

```
游戏 exe 启动
  → Vulkan loader 读 VK_INSTANCE_LAYERS
  → 在 VK_LAYER_PATH 下找 manifest VkLayer_dlss_nr.json
  → 加载 work\nr_layer.dll
  → 层按 NR_LAYER_SPAWN=1 spawn src/layer/nr_daemon.py --socket '\\.\pipe\nr_lop'
  → 每帧送帧给 daemon 跑网络
```

日志：`work\nr_daemon.log`。
**等出现 `listening on \\.\pipe\nr_lop` 再判断任何事情。**

---

## 四、运行中实时开关（全部不用重启游戏）

| 想做什么 | 双击 | 原理 |
| --- | --- | --- |
| 开 NR 效果 | 桌面 `NR 开启.bat` | 创建 `work\nr_trigger` |
| 关 NR 效果 | 桌面 `NR 关闭.bat` | 删除 `work\nr_trigger` |
| 切 int8 | `tools\nr_int8_on.bat` / `nr_int8_off.bat` | 改 `work\nr_settings.json` 的 `int8` |
| 应急停 daemon | `tools\nr_daemon_stop.bat` | — |

- `nr_trigger`：C 层每帧 `access()` 一次，文件在不在决定这一帧是否应用 NR 输出，
  **下一帧就生效**。
- `nr_settings.json`：daemon 读，`int8` 值变了才重建命令图。

---

## 五、当前实测工作点

2026-10-10 01:07，DOOM Eternal，1920×1080，NR 开 / int8 开：

| 指标 | 值 |
| --- | --- |
| 帧率 | **13.5 fps** |
| 帧时间 | 74.0 ms（p95 80 ms，无抖动） |
| GPU | prepare 2.0 + **network 40.1** + finish 1.0 = **43.1 ms** |
| 宿主 CPU | 约 31 ms |
| 网络输入 | 768×448（render_scale 0.40） |
| 画质/时序 | change 0.0253、gate 0.655、held 84%、cut 0.0049 |
| NaN | **0 行** |

**瓶颈**：GPU 43 ms 和宿主 31 ms **完全串行、零重叠**，游戏在干等 NR 出结果。
已排除两个常见猜测：

- 不是带宽 —— 整帧只跑到约 93 GB/s，是 DRAM 峰值 291 的 32%。
- 不是 pass 太多 —— 404 个 pass × 4.4 µs 固定开销 = 1.8 ms，砍光也就这点。

---

## 六、收益开关台账（全部保持开启，不许关）

| 开关 | 默认 | 说明 |
| --- | --- | --- |
| `int8`（`nr_settings.json`） | 1 | **总开关，实际靠这个** |
| `NR_INT8_WINDOW` | "1" | window block FFN |
| `NR_INT8_WINDOW_OUT` | "1" | window block 输出投影 |
| `NR_INT8_OUT` | "1" | attention out |
| `NR_INT8_EXPAND` | "1" | FFN expansion（+0.6 ms） |
| `NR_INT8_QKV` | "1" | QKV 投影（**+1.9 ms**） |
| `NR_INT8_TRANSITION` | "0" | 实测无收益，按计划关 |

`NR_INT8_PROJECT` 代码默认 "0"，但 daemon 读 `nr_settings.json` 的 `int8` 后注入，
所以实际是开的（日志会打印 `integer projections on; rebuilding the graph`）。

---

## 七、已定结论（别再重测）

- **int8 在 A770 上是巨赢**。赢在 config 4 一条指令覆盖 K=32（fp16 只有 16），
  指令数减半；**不是省流量**（权重只占整帧流量约 8%）。
  典型：32×1024×4096 → 13.64 ms → **1.81 ms**（7.55×）。
- **staged 在 A770 上全面劣于 tiled**（各 K 都约 2×），默认 `XMX_PREFER_STAGED=0`。
  但 `0x400000`（window gather）、`0x800000`（pooled residual）和 staged32 **必须用** staged。
- 块几何守卫 `N%32==0 && K%32==0` 绕不过去。
- **双 tiled pipeline**（16×32 + 32×32，`M%32==0 && N%32==0` 走后者）已落地，+10%。
- RM/RN 是软件 tile 数（寄存器预算），TM/TN/TK 才是硬件原生形状。RN=8 会溢出 GRF。
- **QKV 帧内实际 6.5 ms（占 15%）**；用"逐形状求和"估帧时间**会高估约一倍，别用**。

---

## 八、有问题的部分（不启用，留着排错）

- `src/gpu/gemm_staged_int8_fused.comp` + `test_gemm_int8_fused.py`：
  融合量化 + GEMM 的内核**失败** —— 一分块，激活就要被读 N/BN 次，反而更慢。
  已放弃，代码里没有任何路径启用它。
- `NR_INT8_TRANSITION`：接线保留，默认关（实测无收益）。

---

## 九、验证与采样

画质判据用**真实帧**的 `work/int8_quality.py`。

⚠️ **不要用 `test_resident.py` 的 corr 判据**：那是给 fp16 合成输入写的，
int8 全开时报 3 个 FAILED 是**已知的正常状态**，不构成回退理由。

实时采样：

```bat
cd /d E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770
python tools\sample_log.py 30
```

输出窗口内帧率、GPU 三段耗时、gate / held / cut 与 NaN 行数。
