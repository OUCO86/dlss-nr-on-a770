# 把 CPU 从像素路径上踢下去（2026-10-11 起的方案）

用户的要求很直接：**「前半段能挪也要挪过来。争取 CPU 少用甚至不用。」**
本轮的目标函数因此变了：不是继续压设备时间，而是**把宿主仍在做的事搬上卡**。
（两者的方向是相反的 —— 压设备时间会让帧更快但占用率更低；本轮的活会同时抬两头。）

## 0. 目标形态

```
今天：  渲染 → CopyImageToBuffer → Map → 管道(8.3MB) → 宿主解码/缩放/features/to_half
             → 图 → read_head → 宿主合成/量化/编码 → 管道(8.3MB) → BufferToImage → present

想要：  渲染 ──┬─ …

CPU 全程不碰一个像素。чим ... 
```

## 1. 现状：70 ms 一帧，每一毫秒都已经有主

| 段 | ms | 谁在做 | 备注 |
|---|---|---|---|
| 设备（NR 图） | ~33 | A770 | GPU Engine 实测占用率 = **47.4%**，与 33/70 吻合 |
| `nr_image.compose_encode` | ~4（今天从 8.98 降下来） | 宿主 | 后处理的大头 |
| `nr_image.bilinear` ×2 | 4.00 | 宿主 | 缩放到网络 extent 和给 history |
| `mean_change` | ~0（今天清零） | 宿主 | — |
| `nr_image.features` | 1.89 | 宿主 | 组装 16 通道输入 |
| `nr_image.to_half` | 2.17 | 宿主 | fp32→fp16 后写进 mapped 显存 |
| `nr_image.decode8` | 1.90 | 宿主 | 管道字节 → RGB |
| `history keep` / `take` | 2.17 / 1.23 | 宿主 | 含一次 resample / 切帧检测 |
| sendall / receive | 1.11 / 0.66 | 宿主 | 8.3 MB ×2 的 IPC |
| read_head | 0.54 | 宿主 | 把结果读回来 |
| hold/release/weight | 1.19 | 宿主 | 只为了日志三个数 |

**能搬走的那一大块 ≈ 10 到 13 ms**，全发生在 1920x1080 全分辨率上。

## 2. 一条被推翻的前提：渲染根本不在另一张卡上

旧笔记一直按「AMD 渲染 / A770 跑 NR」来推理。**错得很关键。**

typeperf 按 pid 和 luid 拆开后（游戏正在跑）：

| 进程 | pid | luid | per-sample max |
|---|---|---|---|
| daemon（跑 NR） | 28064 | `0x000126F9` | **47.42%** |
| DOOM Eternal | 27700 | **同一个** `0x000126F9` | 5.29% |
| 桌面那一堆进程 | 各种 | `0x00012B34` | ~0.1% |

DOOM **在自己的 luid 之外完全是 0**。它全部的 GPU 工作都和 NR 在同一张卡上。

后果，按重要性排：

1. 9070XT 从此不进任何推理（**用户明令过的**）。
2. **不需要跨设备传输**了。渲染结果和 NR 的输入在同一颗 GPU 上，
   理想形态里那条 `CopyImageToBuffer → Map → 管道 → CPU 搬运 → 再上传` 的回路可以不复存在，
   连 8.3 MB ×2 的 IPC 也一起消失。
3. 代价：它们共用**同一条 3D 队列**，DOOM 的绘制和 NR 的 723 趟 dispatch 串行 ——
   这就是 harness 里六类引擎有五类常年为 0 的原因。

## 3. 三个 Stage，按逐渐远离 CPU 排的

### Stage A —— 不改 layer，只把宿主的活做成 GPU 算子

不必从零写：`resident.comp` 里已经有 23 个 unary 算子
（`TO_HALF` / `FROM_HALF` / `UPSAMPLE2` / `UPSAMPLE_MERGE` / `UPSAMPLE_ADD` / `POOL2` /
`ADD` / `SCALE` / `SCALE_CHANNEL` / `GATE` / `RESIDUAL` / `PARTITION` / `REVERSE` /
`SPLIT_HEADS` / `MERGE_HEADS` / `POOL2_SKIP` / ...）。

可以立刻动的两处：

| 宿主 pass | ms | 现成的 GPU 对应 | 缺口 |
|---|---|---|---|
| `to_half` | 2.17 | **`TO_HALF` unary 已经有了** | 只需把 features 以 fp32 写进显存再跑一趟 |
| `compose` 的上采样部分 | 部分 | `UPSAMPLE2` / `UPSAMPLE_MERGE` / `UPSAMPLE_ADD` | grade / temporal blend / 量化 / 编码还没合并进去 |
| `bilinear` 给 history 的那次 | 部分 | `POOL2`（2 倍 area mean） | 任意倍率的 bilinear 没有 |

还完全 VM 不存在的，必须新写：
- `decode8`（BGRA 字节 → RGB 排列）
- features 组装
- `compose_encode` 里剩下的 grade + temporal + 量化 + 编码一整串

预期：宿主 ~13 ms → ~3 ms。**元気 parce que 不用新写太多 Org。**

### Stage B —— external memory：连那 8.3 MB 都不要传

layer 和 daemon 各有一个 `VkDevice`（哪怕是一颗 GPU）。要让 daemon 直接用 layer 拷出来的那一帧，
跨进程共享得走 `VK_KHR_external_memory_win32`，同步配 `VK_KHR_external_semaphore_win32`。

⚠️ **必须先验证这颗 Intel Arc 在 Windows 上真的支持**，否则 Stage B 不成立，退回 Stage A。

### Stage C —— 更远的：把图搬进 layer（本轮不做）

彻底消灭进程边界。代价是把整套 C/NumPy 前处理也移植到 layer 的 C 里。

## 4. 前面的雷

- 🚩 **CPU 直接在 mapped 显存上做 NumPy 计算会出 NaN。**
  `NR_INPUT_VIEW=1`（features 直接建在 mapped buffer 里）在 Windows 独显上默认关闭，
  注释记着每帧全 NaN。而**关掉它之后那条回退路径最后写的其实是同一个 buffer**（回退是
  `_native_half(flat, view)` / `np.copyto(view, ...)`）—— 所以「独显的 mapped 显存不能写」
  这个解释站不住，真因没查过。
  本轮 Stage A/B 能不能成立也挂在同一件事上：**「宿主写出来 GPU 立刻看得见」是整个方案的前提。**
  → 第一步就去把这个 pin 死（下面 §5）。

- 🚩 `NR_DAEMON_PIPELINE=2` + `NR_LAYER_ASYNC`：真实游戏 **72.8 → 130.9 ms 倒退**。
  离线的 71 → 43.55 ms 是假的（那个客户端没有 present 循环，能提前发帧）。
  ⚠️ 但这两个开关**从来没分开测过**，一直是同时切的。

## 5. 第一步：先写一个 Vulkan probe（不急着改 AnyValue）

用 MSVC 编译一个纯 C 的小程序，一次回答三件事：

1. `VK_KHR_external_memory_win32` / `external_semaphore_win32` 在不在 —— Stage B 的 go/no-go。
2. 「宿主写 DEVICE_LOCAL\|HOST_VISIBLE\|HOST_COHERENT 的 BAR 映射 → GPU 读」
   到底会不会读到旧数据 —— 也就是那个 NaN 的真因。分别试：
   直接写 / `vkFlushMappedMemoryRanges` 之后 / 先在宿主 buffer 里算好再整块拷进去。
3. 宿主写入的方式差异（逐元素 ufunc 写 vs 整块 copyto）对结果有没有影响。

这一步**不需要编 GLSL**（复用现成的 `resident.spv` / `gemm_*.spv` 就行），
也就绕开了本机没有 glslangValidator 的限制。它对 structure 的影响：
如果刷一下就干净了，那么 Stage A 第一天就能动工。
