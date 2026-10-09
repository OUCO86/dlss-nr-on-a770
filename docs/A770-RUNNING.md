# Arc A770 分支：怎么把它跑起来

上游那份 README 讲的是 Lunar Lake iGPU + Linux。这一份是 **Intel Arc A770 独显 + Windows**
的实际跑法，包含启动命令、实时开关、当前实测数字和踩过的坑。

---

## 1. 这台机器的硬件前提

| 部件 | 型号 | 作用 |
|---|---|---|
| GPU0 | **AMD RX 9070 XT**（`VEN_1002&DEV_7550`） | 渲染游戏 |
| GPU1 | **Intel Arc A770**（`VEN_8086&DEV_56A0`） | 跑 NR 网络 |
| CPU | Ryzen 9 5900X 12C/24T | — |
| 内存 | 80 GB | 资源不是瓶颈 |
| 驱动 | 32.0.101.9030 | — |

> ⚠️ **枚举顺序是 AMD 在前**。任何直接取 `pds[0]` 的代码都会选到错误的卡。
> 本分支的做法是 `src/gpu/gpu_pick.h`：按 vendor / device id 匹配 Intel，
> **所有创建设备的入口都必须走它**。

### A770 的硬件特性（实测，不要再推断）

- coopmat fp16：**8×8×16**
- coopmat int8：**8×8×32**
- **没有 bf16**（Vulkan 侧未暴露）
- **没有 large GRF 模式**（GRF 128 封顶）
- SLM：驱动上报 48 KiB / workgroup

---

## 2. 启动游戏（唯一入口）

**双击桌面上的 `DOOM Eternal (NR).bat`。**

它只是个薄封装，真身是 `E:\WorkBuddy\2026-10-09-04-20-55\tools\nr_play.bat`。

游戏：`F:\Game\DOOM Eternal\DOOMEternalx64vk.exe`
（**native Vulkan 版，双击直接能跑，不需要 Steam**）

### `nr_play.bat` 做了什么

在一个 cmd 进程里 `set` 好全部环境变量，然后**从同一个 cmd** 启动游戏：

```bat
set "NR_ROOT=%REPO%"
set "NR_PYTHON=C:\Users\wangz\.workbuddy\binaries\python\envs\default\Scripts\python.exe"
set "PYTHONUTF8=1"
set "VK_LAYER_PATH=%REPO%\work\layer-win"
set "VK_INSTANCE_LAYERS=VK_LAYER_dlssnr_intel"
set "ENABLE_NR_LAYER=1"
set "NR_LAYER_SPAWN=1"
set "NR_LAYER_LIVE=1"
set "NR_LAYER_SOCKET=\\.\pipe\nr_lop"
set "NR_LAYER_TRIGGER=%REPO%\work\nr_trigger"
set "NR_SETTINGS=%REPO%\work\nr_settings.json"
set "NR_LAYER_LOG=%REPO%\work\nr_daemon.log"

start "" /D "%GAME%" "%EXE%"
```

**为什么必须这样**：

- 环境变量只在**进程级**生效，关掉 cmd 就没了 —— 不污染系统。
- **绝不能用 `setx`**，**绝不能写注册表**，**绝不能注册隐式层**
  （`HKCU\SOFTWARE\Khronos\Vulkan\ImplicitLayers`）。
  那样做会让**所有 Vulkan 程序**都被注入 NR 层，是要重启电脑才能恢复的事故。
- **daemon 不要手动起**。它由游戏自己 spawn（`NR_LAYER_SPAWN=1`），是游戏的子进程，
  游戏关它自动没。手动另起一个 = 两个 daemon 抢同一管道 = **游戏卡死**。

### 加载链路

```
游戏 exe 启动
  → Vulkan loader 读 VK_INSTANCE_LAYERS
  → 在 VK_LAYER_PATH 下找 manifest VkLayer_dlss_nr.json
  → 加载 work\nr_layer.dll
  → 层按 NR_LAYER_SPAWN=1 spawn src/layer/nr_daemon.py --socket '\\.\pipe\nr_lop'
  → 每帧送帧给 daemon 跑网络
```

daemon 日志：`work\nr_daemon.log`。**等到出现 `listening on \\.\pipe\nr_lop` 再判断任何事情。**

---

## 3. 运行中实时开关（不用重启游戏）

| 想做什么 | 双击 | 原理 |
|---|---|---|
| 开 NR 效果 | 桌面 `NR 开启.bat` | 创建 `work\nr_trigger` |
| 关 NR 效果 | 桌面 `NR 关闭.bat` | 删除 `work\nr_trigger` |
| 切 int8 | `tools\nr_int8_on.bat` / `nr_int8_off.bat` | 改 `work\nr_settings.json` 的 `int8` |
| 应急停 daemon | `tools\nr_daemon_stop.bat` | — |

- `nr_trigger` 由 C 层每帧 `access()` 一次，文件在不在决定这一帧是否应用 NR 输出，
  **下一帧就生效**。
- `nr_settings.json` 由 daemon 读，值变了才重建命令图。

---

## 4. 当前实测工作点

2026-10-10 01:07，DOOM Eternal 1920×1080，NR 开、int8 开：

| 指标 | 值 |
|---|---|
| 帧率 | **13.5 fps** |
| 帧时间 | 74.0 ms（p95 80 ms，无抖动） |
| GPU | prepare 2.0 + **network 40.1** + finish 1.0 = **43.1 ms** |
| 宿主 CPU | 约 31 ms |
| 网络输入 | 768×448（render_scale 0.40） |
| 画质/时序 | change 0.0253、gate 0.655、held 84%、cut 0.0049 |
| NaN | **0 行** |

**瓶颈在哪**：GPU 43 ms 与宿主 31 ms **完全串行、零重叠**，游戏在干等 NR 出结果。
已排除的两个假设：

- 不是带宽：整帧只跑到约 93 GB/s，是 DRAM 峰值 291 的 32%。
- 不是 pass 太多：404 个 pass × 4.4 µs 固定开销 = 1.8 ms，砍掉也才这点。

---

## 5. 收益开关台账（全部保持开启，不许关）

| 开关 | 默认 | 说明 |
|---|---|---|
| `int8`（`nr_settings.json`） | 1 | **总开关，实际靠这个** |
| `NR_INT8_WINDOW` | "1" | window block FFN |
| `NR_INT8_WINDOW_OUT` | "1" | window block 输出投影 |
| `NR_INT8_OUT` | "1" | attention out |
| `NR_INT8_EXPAND` | "1" | FFN expansion（+0.6 ms） |
| `NR_INT8_QKV` | "1" | QKV 投影（**+1.9 ms**） |
| `NR_INT8_TRANSITION` | "0" | 实测无收益，按计划关 |

`NR_INT8_PROJECT` 代码里默认 "0"，但 daemon 读 `nr_settings.json` 的 `int8` 后注入，
所以实际是开的（日志会出现 `integer projections on; rebuilding the graph`）。

---

## 6. 已定结论（别再重测）

- **int8 在 A770 上是巨赢**。赢在 config 4 一条指令覆盖 K=32（fp16 只有 16），
  指令数减半；**不是省流量**（权重只占整帧流量约 8%）。
  典型：32×1024×4096 → 13.64 ms → **1.81 ms**（7.55×）。
- **staged 在 A770 上全面劣于 tiled**（各 K 都约 2×），默认 `XMX_PREFER_STAGED=0`。
  但 `0x400000`（window gather）、`0x800000`（pooled residual）和 staged32 **必需** staged。
- 块几何守卫 `N%32==0 && K%32==0` 绕不过去。
- **双 tiled pipeline**（16×32 + 32×32，`M%32==0 && N%32==0` 走后者）已落地，+10%。
- RM/RN 是软件 tile 数（寄存器预算），TM/TN/TK 才是硬件原生形状。RN=8 会溢出 GRF。
- **QKV 帧内实际 6.5 ms（占 15%）**；用"逐形状求和"估帧时间**高估约一倍，别用**。

---

## 7. 有问题的部分（不启用，留着排错）

- `src/gpu/gemm_staged_int8_fused.comp` + `test_gemm_int8_fused.py`：
  融合量化 + GEMM 的内核**失败** —— 一旦分块，激活要被读 N/BN 次，反而更慢。
  已放弃，代码里没有任何路径启用它。
- `NR_INT8_TRANSITION`：接线保留，默认关（实测无收益）。

---

## 8. 验证与采样

画质判据用**真实帧**的 `work/int8_quality.py`。

⚠️ **不要用 `test_resident.py` 的 corr 判据**：那是给 fp16 合成输入写的，
int8 全开时报 3 个 FAILED 是**已知的正常状态**，不构成回退理由。

实时采样工具：

```bat
cd E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770
python tools\sample_log.py 30
```

输出窗口内的帧率、GPU 三段耗时、gate / held / cut 和 NaN 行数。
