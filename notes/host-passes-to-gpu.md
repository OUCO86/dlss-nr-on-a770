# 把 CPU 从像素世界里踢出去（2026-10-11 起主导的优化）

## 出发点

用户提了一个观察，然后下了决断：

> 显卡占用率很低才 50% 多，功耗才 90 多 W。…… **占用率在变低证明优化有效果，这个必须做；
> 但优先级是先让它提上去 …… 现在明摆着就是有闲置。前半段能挪也要挪过来，争取 CPU 少用甚至不用。**

于是本轮的**目标函数变了**：不再是「压缩设备时间」，而是「**把宿主仍在做的事搬上卡**」。
前一类优化会让帧更快但占用率更低；这一类是同时抬两头。

⚠️ 与本文最相关的一条旧结论（`daemon-cpu-cost.md`）需要重读：那里把「把 features 直接建在
mapped 显存里」的方案记为 **NR_INPUT_VIEW=1 在独显上每帧全 NaN**。这条挡在本轮主方向上，
见下面「先决条件」。

## 一、现状：70 ms 里各站哪一段

实测口径（游戏在跑，`src/bench/daemon_stages.py` 的分解 + GPU Enginetimestamp）：

| 段 | ms | 谁在干活 |
|---|---|---|
| **设备（NR 图）** | **~33** | A770，自己就是它 47% 占用率的全部来源 |
| 宿主：receive | 0.66 | CPU（8.3 MB 进 daemon）|
| 宿主：decode8 | 1.90 | CPU，转格式 + 归一化 |
| 宿主：`nr_image.bilinear` × 2 | 4.00 | CPU，缩放到网络 extent 和 history |
| 宿主：`nr_image.features` | 1.89 | CPU，组装 10/N 通道输入 |
| 宿主：`nr_image.to_half` | 2.17 | CPU，cast 到 fp16 再写 mapped 显存 |
| 宿主：read_head | 0.54 | CPU，把结果读回来 |
| 宿主：`nr_image.compose_encode` | **~4**（今天从 8.98 降下来的）| CPU，合成 + 量化 + 编码 |
| 宿主：sendall | 1.11 | CPU（8.3 MB 回 layer）|
| 其余更小的项（history keep/take、grading gate 统计等） | ~5 | CPU |

**能搬走的那一大块 ≈ 10 到 13 ms，全是在 1920x1080 的全分辨率上跑的像素活。**

## 二、被推翻的前提：渲染根本不在另一张卡上

旧笔记一直按「GPU0 AMD 渲染 / GPU1 A770 跑 NR」来推理。**这是错的，而且错得不轻。**

typeperf 按 pid 和 luid 拆开后的实测（游戏正在跑）：

| 进程 | pid | luid | per-sample max占用 |
|---|---|---|---|
| daemon（跑 NR） | 28064 | `0x000126F9` | **47.42%** |
| DOOM Eternal | 27700 | **同一个 `0x000126F9`** | 5.29% |
| 一大堆桌面进程 | 各种 | `0x00012B34` | ~0.1% |

DOOM **在自己的 luid 之外完全是 0**。它所有 GPU 工作都和 NR 在同一张卡上。

这条修正带来的东西比想象的多：

1. 9070XT 从此不进任何推理。
2. **不需要 device-to-device 传输**了：渲染结果和 NR 的输入在同一颗 GPU 上，
   理想形态里那条 `vkCmdCopyImageToBuffer → 映射 → 管道 → CPU 搬运 → 再上传` 的回路**可以不复存在**。
3. 现在仍能不清零。（代价：**同一条 3D 队列**既画 DOOM 又跑 NR 的 723 趟 dispatch，
   两者串行，23 类是 Compute/Copy/Video 引擎常年为 0。）

## 三、目标形态

```
layer: swapchain image
       → cmd_blit 到一个允许导出的 VkImage（避开 swapchain image 不可导出的限制）
       → 导出 NT handle + external semaphore
daemon: 导入 image
       → GPU 上完成 解码/缩放/features/to_half/网络/compose/编码 全部
       → 输出到一个共享 image
layer:  直接 present，或 cmd_copy 回 swapchain
```
**CPU 全程不碰一个像素。** 现阶段流通的 16.6 MB/帧सी管道双向搬运也就一并消失。

## 四、分阶段

### Phase 1 — 不改 layer，只把宿主的活做成 GPU pass（收益确定，风险低）

分两个出口：
- **后处理**：head 已经在显存里，且 `resident.comp` 已有 `UPSAMPLE2 / UPSAMPLE_MERGE /
  UPSAMPLE_ADD / TO_HALF / FROM_HALF / GATE / SCALE / ADD / RESIDUAL` 一整套元素算子，
  把 `nr_image.compose_encode` 的语义（grade + temporal blend + quantize + encode）写成一条同样的路子；
- **前处理**：`decode8 → bilinear → features → to_half` 融合成一个「从 BGRA 字节到 features16」的输入 pass。

预期：宿主 ~13 ms → ~3 ms（只剩一次 8.3 MB 上传 + 一次下传 + IPC）。
预期 resid：帧 ~70 → ~55 ms，GPU 忙 33 → ~45 ms，**占用率 ~47% → ~65%**。

### Phase 2 — external memory：连 8.3 MB 也不要传（**这是目标形态的关键一步**）

layer 与 daemon 各有一个 `VkDevice`（即使同一颗 GPU），要让 daemon 直接用 layer 拷出来的
那一帧，跨进程共享 VkImage/VkBuffer 得走 `VK_KHR_external_memory_win32`（配
`VK_KHR_external_semaphore_win32` 做同步）。**必须先验证 Intel Arc 在 Windows 上支持，
否则 Phase 2 不成立，退回 Phase 1。**

### Phase 3 — 更远的：把图搬进 layer（暂不计划）

彻底消灭进程边界，代价是把 C/NumPy 的前处理也移植到 C。不在本轮。

## 五、先决条件：先钉死那个 NaN（**价格最低、信息最大**）

`NR_INPUT_VIEW=1`（features 直接建在 mapped 显存）在 Arc 140V / Intel Linux 驱动上正常，
在 Windows 独显上每帧全 NaN ── 这个现象现在**只被当成「独显就这样」，没真正解释过**。

嫌疑：**host 写 DEVICE_LOCAL|HOST_VISIBLE|HOST_COHERENT 的 BAR 映射，GPU 侧读到陈旧数据**。
（按 P2 测绘，daemon 的图缓冲正是 type 3 DEVICE_LOCAL + HOST_VISIBLE + HOST_COHERENT。）

如果根因是缓存可见性，那么：

* 它可能很容易修（`vkFlushMappedMemoryRanges` / `vkInvalidateMappedMemoryRanges`）；
* Phase 1/2 能不能成立也挂在同一件事上 —— **Phase 2 里 layer 和 daemon 要互相读写对方导出的
  显存，「能不能写出 GPU 立刻看得见的值」是整个方案的前提。**

所以本轮第一步不是写新的融合 pass，而是**写一个 50 行的 C probe**：
映射一块 DEVICE_LOCAL|HOST_VISIBLE buffer → CPU 写 → GPU 读 → 校验；
分别试「直接写」「`vkFlushMappedMemoryRanges` 后」「cop中转后」三种。
把 NaN 的原因从「独显就这样」变成一句可验证的话。

## 六、验收标准（沿用本仓规矩）

1. 每步都要**同进程 A/B**，outputs **逐字节相同**（`test_native_image.py` 那一套）。
2. 每一步都要同时报**帧时间**和**GPU 占用率**两个数字 —— 本轮的目标是抬后者，
   只看帧时间会把 Phase 1 这类改动判成「没及格」，那是错的口径。
3. 一条本轮专用的判据：本轮的目标是**抬占用率**，所以「帧时间没降」不等于失败 ——
   每一步都要把「CPU 少做了多少」和「GPU 多做了多少」两个数分开报，
   只报帧时间会把这类改动错判成没及格。

---

## 七、Phase 1 的前处理已落地（2026-10-11）

`resident.comp` 多了两个算子，宿主侧由 `nr_frame_resident.RequestPass` 管着：

| kind | 干什么 | 输入 → 输出 |
|---|---|---|
| `PRE_INNER`（23） | `nr_decode8` + `resample` 的两个轴合成一趟；顺带按 workgroup 求 \|本帧 inner − 上一帧 inner\| 的和 | 游戏的 BGRA 字节（显存）→ inner fp32（显存）+ 分组和 |
| `PRE_FEATURES`（24） | `nr_features_half` 的全部语义：三级 half 舍入、geometry 镜像、noise、五个 controls、history 通道 7-9 | inner + history + noise → 16 通道 fp16，**写进图自己的输入 buffer** |

于是 `decode → resample → features → to_half → 写进 mapped 显存` 这四趟宿主活变成两趟设备活，
**解码后的帧和缩放后的帧都不再回宿主**（后处理还要用全分辨率的解码结果，所以 `decode8`
本身仍在宿主，见「还没搬走的」）。

开关：`NR_PREPASS=0` 整条回宿主路径。信箱之外自动回退的两种情况：letterbox 裁过的帧，
以及 `a2b10g10r10`（那个 pass 按字节读通道，10-bit 不是字节）。

### 数字

`src/bench/daemon_stages.py 1920x1080@0.4`，同一份构建只切 `NR_PREPASS`（ms，15 帧中位）：

| 阶段 | 宿主（=0） | 设备（=1） |
|---|---|---|
| resample | 3.46 | **1.98**（只剩后处理那一次） |
| history_take | 1.22 | **0.00**（cut 由设备算） |
| features | 1.79 | **0**（融进 pass） |
| gpu_in（写进图） | 2.23 | **0.02** |
| gpu_run | 43.96 | 43.76 |
| to_answer | 62.34 | **55.40** |
| round_trip | 65.15 | **58.14** |

端到端 `src/bench/check_request_pass.py`：前处理 **13.44 → 3.05 ms**，整帧 **67.69 → 54.57 ms**。
`src/bench/check_pre_inner.py` / `check_pre_features.py`：随机全分辨率帧 **5/5 与 6/6 逐字节相同**，
cut 的分组和与宿主的差 6e-08（浮点求和顺序，非误差）。

### 三个坑

1. **shader 里的 `/ 255.0` 会被编译成乘倒数**，和宿主 C 的除法在最后一位上分道扬镳，
   约一半的值差 1 ULP（identity 几何下测出来的：`check_pre_inner.py identity`）。
   改成查 256 项表，表由宿主自己算 —— 顺带也更快。
2. **`buffer.download` 极慢**（4.7 MB 要 179 ms）。验证脚本里读回来比对可以，
   生产路径一次都不读（inner 直接喂给下一个 pass），别被这个数吓到。
3. `a2b10g10r10` 也是 4 字节/像素，按字节解会全错。`_request_pass` 只认 `bgra8` / `rgba8`。

### 还没搬走的

- `decode8`（1.7 ms）：后处理要用全分辨率解码帧，除非把 `compose_encode` 也搬上卡。
- `compose_encode`（3.8–5.5 ms）和 `history.keep` 的那次 resample（~2 ms）：Phase 1 的后半。
- 那条 `CopyImageToBuffer → 管道 8.3 MB → 宿主` 的来路：要等 Phase 2 的 external memory。


## 8. 八秒一帧：持有了一个已被关闭的 frame（2026-10-11，上线当天实测撞到）

上线第一局，开头 60 ms，第 134 帧之后变成 **8.2 秒一帧**，`gpu 8189+39+1ms` ——
第一段（宿主往图的输入写）暴涨，中间段（跑图）还是正常的 38 ms，**显卡空转**。
触发点是紧前面那一帧 **letterbox**（`network 448x448`，之后回到 768x448）。

### 根因

`ResidentBackend`（`src/ref/nr_frame.py`）默认 `max_cached_frames=1`：

    Retains the most recently used extents, one by default. Evicted frames are closed,
    releasing their GPU allocations and captured commands. A caller must not keep using
    a frame after asking this backend for a different extent.

**这句警告就写在它的 docstring 里，我动手前没读到。**

- letterbox 帧是另一个 extent → `backend.frame(448,448)` → 768x448 那张图被 **evict 并 close()**；
- `RequestPass` 构造时抓的是 `backend.frame(...)` 的返回值，于是手里攥着一个已释放的图；
- 更糟：`_request_pass` 在 `boxed` 时**直接 return None 但没更新 `request_key`**，
  所以下一帧 key 没变、**不重建**，继续用那个攥着已释放 frame 的 pass；
- `assemble()` 返回已关闭图的 `input_view()`，`ResidentFrame.run` 拿的是新图，
  两者指针不同 → 走 `host_write` → **从一块已经 close 的设备 buffer 读 8.3 MB**。

### 为什么画质没坏

从已释放显存读出来的字节**碰巧还没被覆盖**，head 仍然 byte-identical。
所以唯一症状就是帧率 —— 这正是最难自查的一类：数据是对的，只是慢了 300 倍。

### 修法

1. `RequestPass` 改持 **backend**，在 `assemble()` 里现取 `backend.frame(*extent)` ——
   从根上不可能攥住一个已关闭的 frame。
2. `RequestPass.close()` 显式 free 那一批 buffer，不等 GC。
3. `_request_pass`：把 key 的计算提到所有 `return None` **之前**，
   任何回退路径都顺带清掉 `args.request`。

### 回归测试

`src/bench/check_request_switch.py`：跑帧 → 要一次 letterbox extent → **不重建 pass**，
继续用同一个对象跑帧。这是最严苛的形式（复现"key 没变所以不重建"那条路径）。

| | 切换后 `carried` | head |
|---|---|---|
| 修复前 | **10163.02 ms** | 4/4 逐字节相同（！） |
| 修复后 | **0.03 ms** | 6/6 逐字节相同 |

⚠️ 教训：**正确性判据抓不到这类 bug**。byte-identical 全过，只有帧率能显示它。
凡是"把活搬到设备"的改动，除了比对输出，**必须有一条"什么都没拷贝"的时间断言**。

### 另一个教训：动手前要把参考文案读完

`docs/a770-port/code-map.md` 我只 grep 了章节标题。P3 和 P4 两节正是这次动的东西，没读：

- P3：⚠️ **权重每次 extent 变化要跨 PCIe 重传 ~292 MB**（`notes/phase63:150-155`）。
  即 extent 切换本身就很贵，letterbox 越多越亏。
- P4：宿主通道的 OpenMP 分块是按 8 核 Lunar Lake 调的，换 CPU 要重测。

**这是本轮第二次因为没查而栽（第一次是误判"本机没有 MSVC"）。下同：**
改任何模块前，先把 `code-map.md` 里对应章节 + 该模块自己的 docstring 读完，
不能只 grep 标题。

## 9. 这三趟还能不能再降精度（fp16 / int8）—— 量过了，答案是别动精度，动位置

用户问：前后段现在跑的是 fp32 吗？挪到 GPU 了不能改 fp16 或干脆 int8 吗？

**是 fp32**（`resident.comp` 的 23/24/25 三个 kind，累加器、输入输出全 `float`；
只有 `PRE_FEATURES` 的**输出**是 fp16，因为图的输入本来就是 half；
`POST_COMPOSE` 内部把 head 先 `float16_t()` 再乘 0.25）。但精度不是它们的成本所在。

### 实测（`src/bench/prec_traffic.py`，1920x1080，15 次中位，纯 submit+wait）

| 趟 | 设备 ms | 说明 |
|---|---|---|
| `PRE_INNER` | **0.16** | 8.3 MB 读 + 4.1 MB 写 |
| `PRE_FEATURES` | **0.20** | 8.3 MB 读 + 11.0 MB 写（fp16） |
| `POST_COMPOSE`（answer 在**显存**） | **0.34** | 96.8 MB / 284 GB/s |
| `POST_COMPOSE`（answer 在**系统内存**） | **6.66** | 同一个 pass，慢 20 倍 |

三趟合计 **0.70 ms**。宿主原来这一段是 10–13 ms —— 已经赢了 15 倍以上。

### 结论 1：int8 在这里收益是 0，不是"小"

int8 在 A770 上的唯一好处是 XMX 的 DPAS 一次乘加覆盖 K=32（fp16 只 16），指令数减半
（`improve-int8-a770.md`）。**这三趟一条乘加都没有**，压根不碰 XMX。
int8 只剩"字节更小"，却要付量化/反量化的指令 —— 净亏。不用考虑。

### 结论 2：fp16 省不到 0.1 ms

它们是带宽受限：0.34 ms 动 96.8 MB ≈ **284 GB/s**（对照 `ew_rate.py` 同批 175–340 GB/s）。
把 fp32 的 `history`/`previous`/`composed` 换成 fp16 → 流量 96.8 → 59.5 MB → 省 **约 0.09 ms**。
**60 ms 的帧里 0.09 ms，不值得动**，还赔上 bit-identical 判据。

### 结论 3（真正的发现）：`HOST_READ` 在这张卡上是**系统内存**，6.32 ms 是过 PCIe

daemon 日志第一行就写着：

    buffers in card memory: type 3, heap 15.9 GiB, DEVICE_LOCAL HOST_VISIBLE HOST_COHERENT
    readback cached:        type 2, heap 40.0 GiB, HOST_VISIBLE HOST_COHERENT HOST_CACHED

`HOST_READ` 的 buffer（`libxmx.c` 里 `host_read` 优先 `HOST_CACHED`）落在 type 2 = **40 GiB
系统内存**。设备往那儿写是 **0.197 ms/MB ≈ 5.1 GB/s**：

- `+neural`（多写 24.9 MB）→ **+4.91 ms**；
- 同一趟写进 VRAM：多写 24.9 MB → **+0.03 ms**；
- 整个 answer 走 PCIe 的代价：**6.66 中的 6.32 ms**。

⚠️ 所以接线 `stage_finish` 时的三条硬约束：

1. `composed` / `neural` / `partial` / `samples` 一律 **GRAPH（VRAM）**；
   只有 `encoded words`（8.3 MB）允许 `HOST_READ`，代价 1.63 ms。
2. `head` 现在也是 `HOST_READ`（`nr_frame_resident.py:216`）→ 图最后一趟写它过一次
   PCIe（1.08 ms），`POST_COMPOSE` 读它再过一次（1.08 ms），宿主还读回 0.54 ms。
   接线后宿主不再需要 head（`samples` 由 pass 自己写），改成 GRAPH 三趟一起省。
3. 历史/上一帧像素（`d`）保持 `HOST_WRITE`（= VRAM + BAR 映射），常驻，不回宿主。
   `xmxres.py:228` 的 `GRAPH, HOST_READ, HOST_WRITE = 0, 1, 2`，别选错。

### 结论 4：fp16 什么时候才真的值钱 —— 只在"这份数据必须过 PCIe"的时候

| 过 PCIe 的东西 | fp32 | fp16（一半字节） | 省 |
|---|---|---|---|
| 上传 history+previous（过渡态） | 8.98 ms | 2.23 ms | **6.75 ms** |
| 写 composed+words 到 HOST_READ | 6.5 ms | 3.2 ms | 3.3 ms |

但这两笔都属于「**residency 做完就消失的成本**」—— 常驻之后上传是 0、composed 根本不出显存。
所以 fp16 是**退路**（万一 residency 做不成），不是主线。

### 精度代价（万一真要走 fp16）

`composed` / `history` / `previous` 都 clamp 在 [0,1]：fp16 在 1.0 附近步长 2^-11，
字节步长 1/255 ≈ 2^-8，**差 8 倍** → 只有正好压在 `.5` 边界上的像素会翻 1 个 LSB，肉眼无差别。
但 bit-identical 判据会破，验证脚本要改容差。

另：`inner` 存成 fp16 对 `PRE_FEATURES` 是**零代价**（它第一件事就是 `half_round(x)`，
x 已经是 half 就是恒等），但会轻微扰动 `cut`（0.0049，相对扰动约 1e-4）——可接受，仍非必要。

## 10. 前后段都上卡之后，一帧的钱花在哪（2026-10-11，离线实测）

### 10.1 `daemon_stages.py`（1920x1080@0.4，12 帧中位，实机开关 `NR_POSTPASS=1`）

| stage | fresh | held |
|---|---|---|
| receive（管道收 8.3 MB） | 1.48 | 1.47 |
| settings | 0.09 | 0.08 |
| **decode（宿主全帧解码）** | **2.00** | 1.92 |
| letterbox | 0.11 | 0.08 |
| history_take | 0.00 | 0.00 |
| gpu_in | 0.03 | 0.03 |
| **gpu_run（网络图墙钟）** | **43.50** | 43.49 |
| send | 1.04 | 0.99 |
| post_send | 0.11 | 0.42 |
| to_answer / round_trip | 53.23 / 54.23 | 52.63 / 53.67 |
| **rest（往返减图）** | **10.74** | 10.04 |

往返约 53 ms，图 43.5，宿主+传输约 **10 ms**。

### 10.2 `graph_gap.py` —— 那个 gap 到底是 2.75 ms，不是 8.9 ms

⚠️ **这个脚本不 `apply()` 游戏设置，默认跑的是 int8 关闭的浮点图**（415 趟 / 43.54 ms）。
必须 `NR_INT8_PROJECT=1` 才是实机那张图（603 趟）。判据：**趟数 603 而不是 415**。

    NR_INT8_PROJECT=1 NR_PROFILE_GAP=1 python src/bench/graph_gap.py 6
      wall clock around the graph   38.50 ms
      device, passes only           35.75 ms
      unaccounted for                2.75 ms  (7 %)
      pass count                      603

所以**设备"没记账"的时间只有 2.75 ms**。
（曾经以为的 8.9 ms 是拿 `daemon_stages` 的图墙钟 43.5 减 `frame_ledger` 的 34.61 得来的，
两者不是同一段：账本只跑网络图，不含前后段的 pass 和它们各自那一次 submit。）

### 10.3 剩下的宿主开销，按大小

1. **`decode` 2.00 ms —— 最可疑**：`nr_daemon.py:80` 的 `nr_image.decode8`，全帧 8.3 MB 解成
   25 MB fp32。而 `PRE_INNER` **已经在设备上解码过同一帧**（还顺手算了 cut）。设备路径下
   宿主这份 `whole` 只剩 letterbox 检测在用，而那个只想知道哪些行列是黑的，
   **在字节上就能判，不必解码成 fp32**。
2. 管道 `receive` 1.48 + `send` 1.04 = 2.52 ms：8.3 MB 一来一回，跨进程固有成本。
3. `to_answer` 53.23 减去上面各项之和约 48.4 → **约 4.9 ms 未归因**，下一轮要拆开。
4. `post_send` 0.11（fresh）/ 0.42（held）。

### 10.4 ✅ 已做：letterbox 改在字节上判，`decode` 不再每帧做（commit 5933b8f）

**为什么可以**：`LETTERBOX_TOLERANCE` 是 `2/255`，这是一句关于整数的话 —— 一条黑边
就是"每个颜色字节 ≤ 2"。而 RGB 三个字节恰好是 u32 的**低 24 位**（`bgra8` 与 `rgba8`
只是顺序不同，取最大值不在乎），alpha 在上面那个字节，不参与。

    所以整条线是否全黑 = `(word & 0x00FFFFFF).max() <= 0x020202`

`WORD_DARK` 由 `int(LETTERBOX_TOLERANCE * 255 + 0.5) * 0x010101` 算出来，跟着 tolerance 走。
`a2b10g10r10` 是 10-bit 打包、没有这样的字节 → 保留宿主路径。

**代价对比**（1920×1080，中位，纯 CPU）：

| | 之前 | 之后 |
|---|---|---|
| `decode`（8 MB → 25 MB fp32） | **3.08 ms** | 0（不做了） |
| `Letterbox` 缓存命中（8 条线） | 0.02 ms | **0.02 ms** |
| 合计 | 3.10 ms | **0.02 ms** |

（`daemon_stages` 里量到的是 2.00 ms，这次 3.08 是因为量的时候游戏在跑、CPU 有争用。
相对值可信。）

**什么时候仍然解码**（`stage_prepare`）：`request is None`（前段没上设备）、`boxed`、
`--dump` / `--meter`、或 `NR_POSTPASS=0`。`stage_finish` 里 `device` 判据为假时也会
补一次解码（带 interface mask 的帧、强度不为 1），**任何回退路径都不会拿到 None**。

**验证**：新增 `src/bench/check_letterbox_words.py`，**30 例 0 分歧** ——
条形边 / 条形边＋柱子 / **恰好压在阈值上（字节 2）** / **阈值之上（字节 3）** /
暗场景 / 全黑帧 / 只有一侧（不是 letterbox）／三种分辨率，外加缓存路径的 6 帧
（其中一帧强制失效重扫）。

### 10.5 🚩 这次踩的坑：解包顺序

`Letterbox._holds(colour, words, shape)` 里我写成 `height, width = shape`，
而 `active_region_words(words, *shape)` 要的是 `(width, height)` —— **行列反了**，
`reshape(1920, 1080)` 还能成功（总数一样），于是判定每帧失效、退回全帧扫描
（**2.20 ms** 而不是 0.02 ms）。修复后 `shape[::-1]`。
⚠️ 这类 bug 不会报错、不会算错，只会变慢 —— 只能靠时间断言抓。

### 10.6 下一步

1. 拆 `to_answer` 里**约 4.9 ms 未归因**的部分（10.3 第 3 条）。
2. 补设备模式的 `held%` / `released%`（previous 现在是字节，没解码）。
3. 管道 `receive` 1.48 + `send` 1.04 是跨进程固有成本，暂不动。

## 11. 一帧剩下的钱：不在算力上，在搬运和等待上（2026-10-11，`daemon_stages` 加计时后）

`daemon_stages` 原来有约 4.9 ms 不在任何 stage 里。原因是三个 `RequestPass` 调用
（`prepare` / `assemble` / `finish`）**根本没被计时** —— 三次派发到显卡，一次都没包。
现在包上了（`commit b0657ff`），并且输出多一行 `unaccounted`。

### 11.1 完整的一帧（1920x1080@0.4，12 帧中位，`NR_POSTPASS=1`，离线）

| stage | ms | 其中设备时间 |
|---|---|---|
| receive（管道收 8.3 MB） | 1.52 | — |
| settings | 0.08 | — |
| letterbox（字节上判） | 0.07 | — |
| **pass_prepare**（PRE_INNER + PRE_FEATURES） | **2.06** | 0.36 |
| pass_assemble | 0.28 | 0.20 |
| **gpu_run**（网络图，墙钟） | **43.51** | 34.61（账本） |
| **pass_finish**（POST_COMPOSE + POST_HISTORY） | **2.20** | 0.34 |
| send（管道发 8.3 MB） | 1.04 | — |
| post_send | 0.10 | — |
| **unaccounted** | **0.22** | — |
| **to_answer** | **51.24** | |
| **round_trip** | **52.17** | |

（改前：54.23。`decode` 那一行整条消失了。）

### 11.2 🚩 三个 pass 花 4.54 ms，设备只干 0.70 ms

差出来的 **3.84 ms** 是提交、同步和搬运。两件事：

**① `xmx_submit` 每次都 `vkWaitForFences`**（`libxmx.c` 的 `submit_commands`）——
也就是说**每次提交都是同步的**，一帧四次：prepare / assemble / 图 / finish。
每两次之间 GPU 是空的，等宿主把下一段录好。这就是"显卡占用率上不去"的机理：
不是算不完，是**被切成四段、段与段之间在等 Python**。

**② 那 8.3 MB 一帧里过了四趟总线**：

    游戏 --管道--> daemon          1.52 ms   （receive）
    daemon --PCIe 上传--> 显存     ~1.5 ms   （host_write，按 49.8 MB = 8.98 ms 推的）
    显存 --PCIe 回读--> daemon     1.63 ms   （words，HOST_READ，实测）
    daemon --管道--> 游戏          1.04 ms   （send）
                                   ------
                                   ~5.7 ms

`POST_COMPOSE` 本身的设备时间是 0.34 ms（`notes` §9 实测），`PRE_INNER` 0.16、
`PRE_FEATURES` 0.20 —— 前后段全部算力加起来 **0.70 ms**，而为了把字节搬到它能算的
地方、再把结果搬回去，付了 5.7 ms。

### 11.3 能不能合并提交 —— 屏障的情况

`libxmx.c` 里 `vkCmdPipelineBarrier` 只有 **4 处**（transfer 前后等特定场合），
603 趟 pass 之间**一道屏障都没有**，而画面是对的。说明在这张卡上，
**同一个 command buffer 里连续的 dispatch，顺序由驱动保证**。

所以把 prepare / assemble / 图 / finish 合成一次提交是**有可能**的，但要动 C：
- 图的命令在它自己的 `VkCommandBuffer` 里（`xmx_graph_run` 提交 `graphs[id].commands`），
  合并意味着一次 `vkQueueSubmit` 带多个 cb —— **跨 cb 的顺序不由规范保证**，
  需要驱动兜底，风险比同一 cb 内高。
- `prepare` 之后必须同步一次：`cut` 要 `partial.download()`，而 `cut` 在
  `history.take` 里用，那时图还没跑。除非让 cut 晚一帧。

### 11.4 下一步的三个选项（按性价比）

| | 做什么 | 省 | 风险 |
|---|---|---|---|
| **A** | 合并提交（改 C，一次 submit 带多 cb） | ~0.5–1 ms，且 GPU 段间不再空转 | 中（跨 cb 同步） |
| **B** | 攻设备侧 34.61 ms（占 69%） | 未知，要找新内核点 | 低（已有账本） |
| **C** | 管道改共享内存（改 C 层 + daemon） | ~2.6 ms | 高（跨进程改传输） |

⚠️ **A 的前提**：先确认"离线 43.5 ms vs 游戏内 38 ms"这 5.5 ms 差是不是 GPU 降频。
离线跑 bench 时显卡没压力会降频，那样所有离线数字都偏慢，A 的收益也会跟着变。
→ **前提已澄清，见 §12.4：不是降频，是两个数字跑的图不一样（int8 开关）。**

## 12. 选项 A（合并提交 / 让录制与图重叠）做过了：收益 0.03 ms，已回退（2026-10-11）

### 12.1 做法

`RequestPass.finish` 拆成 `record_finish`（只把两趟录进 `rcb`）+ `submit_finish`；
新增 `xmx_graph_launch`（提交图、**不等 fence**）与 `xmx_graph_wait`。
顺序只能是 **launch → record → wait → submit**：`xmx_graph_run` 拒绝在 `rcb` 打开时
replay（`libxmx.c` 的 "cannot replay during recording"），而先录制再提交图就等于没重叠。

### 12.2 数字（1920x1080@0.4，12 帧中位，两个场景各一组）

    NR_POSTPASS=1 NR_INT8_PROJECT=1 python src/bench/daemon_stages.py 1920x1080@0.4 --frames 12

| | off（录制在图之后） | on（录制与图重叠） |
|---|---|---|
| pass_record | 0.06（含在 finish 里） | **0.04** |
| pass_submit / pass_finish | 2.15 / **2.21** | **2.16** / — |
| gpu_run | 34.41 | 34.34 |
| **to_answer** | **42.41** | **42.38** |
| round_trip | 43.40 | 43.55 |

**−0.03 ms，就是噪声。A 不成立，代码已回退（dll 按 HEAD 重建过）。**

### 12.3 为什么不成立

假设是"GPU 在段与段之间空转等 Python 录命令"。实测**录两个 dispatch 只要 0.04 ms**：
Python 侧就是两次 ctypes 调用加一次标量组装，参数表只在第一帧建。**这项根本不存在。**

`pass_finish` 那 2.20 ms 的真实构成：

- 设备 **0.34 ms**（PRE_INNER 0.16 + PRE_FEATURES 0.20 之外的 POST_COMPOSE 0.34）
- **1.84 ms 是把 8.3 MB 答案写进 `HOST_READ` —— 那在本卡是系统内存**
  （`prec_traffic.py`：同一个 POST_COMPOSE，answer 在 HOST_READ **2.20 ms** vs 在 VRAM
  **0.36 ms**，差 1.84 ≈ 0.22 ms/MB ≈ 4.5 GB/s，与 §9 的 0.197 ms/MB 一致）
- 剩下约 0.2 ms 是 `vkQueueSubmit` + `vkWaitForFences` 的固定开销

**一次提交的固定开销只有 0.1–0.2 ms**（旁证：`pass_assemble` 0.28 = 设备 0.20 + 开销 0.08）。
四次提交合并到底最多省 0.3–0.4 ms，而要冒"跨 command buffer 顺序"的险。**不划算。**

### 12.4 🚩 顺带钉死：离线 43.5 vs 游戏 38，不是降频，是图的配置不同

`daemon_stages` 的 `--int8` 取 `NR_INT8_PROJECT`，**代码默认 "0"** → 之前每一次
"离线一帧"测的都是**浮点图**。同一条命令加 `NR_INT8_PROJECT=1`：

    gpu_run  43.89 → 34.41 ms （账本 603 趟，int8 图）
    settings in effect: ... int8=1 ...

游戏里 int8 是开的（38 ms）。所以 43.5 − 38 这 5.5 ms 是**两张不同的图**，不是频率。
（用户已限功耗，不存在撞墙降频 —— 用户说的是对的，只是原因不是我们猜的那个。）

还剩 38 − 34.4 = **3.6 ms**：游戏里 A770 同时在渲染和跑 NR，bench 时它只跑 NR。

**判据**：日志里 `settings in effect: … int8=1 …` 和 `runtime options … NR_INT8_PROJECT=1`。
以后所有离线一帧的数字都要带 `NR_INT8_PROJECT=1`，否则测的是没有游戏跑过的配置
（`game_settings.py` 的 docstring 说的就是这件事）。

### 12.5 一帧剩下的钱（int8=1，离线 `to_answer` 42.4 ms）

| 项 | ms |
|---|---|
| 设备图 | 34.4 |
| PCIe 上传 8.3 MB（`pass_prepare` 的 host_write） | ~1.5 |
| PCIe 回写 8.3 MB（answer 在系统内存） | 1.84 |
| 管道收 | 1.5 |
| 管道发 | 1.04 |
| 其余（letterbox / settings / 提交开销） | ~0.7 |

**那 8.3 MB 一帧过四趟总线，一共约 5.8 ms** —— 比合并提交能拿到的 0.3 ms 大 20 倍。
下一步要么动它（选项 C：共享内存；Phase 2：external memory，连上传回写一起省），
要么回到设备侧的 34.4 ms（选项 B）。
（判据：游戏内日志 `gpu 0+38+0` vs 离线 `gpu_run 43.51`。）

## 13. 选项 C：帧的 8.3 MB 改走共享内存（2026-10-11，已上线）

### 13.1 先量：管道到底收了多少钱（`src/bench/shm_vs_pipe.py`）

进程内两线程、三种方式交替，1920x1080（8.29 MB 单向），30 轮：

| 方式 | layer 端 | daemon 端 | 往返 |
|---|---:|---:|---:|
| pipe（现状） | 3.03 | 2.93 | **5.96 ms** |
| shm（大块走映射，管道带头和 4 字节通知） | 1.63 | 0.49 | **2.12 ms** |
| shm0（answer 就地读，不拷出来） | 1.02 | 0.48 | **1.49 ms** |

比 §12.5 估的 2.5 ms 还多：**那 2.5 ms 只是 daemon 一端的收+发**，layer 那一端的
3.03 ms 发生在游戏进程里、不在 daemon 的日志上，从来没被量过。

`shm0` 做不到：`data->result` 是 malloc 出来的、跨帧持有的（trigger 抬起时要重放
上一帧），不能指向会被下一帧复用的 slot。差 0.63 ms，留着。

### 13.2 协议（改动很小）

- 帧的字节放进映射，管道**只带 16 字节头**（SHM 模式 20 字节，多的是 slot 号）和
  回程 4 字节"answer 在你那个 slot 里"。
- **管道本身就是同步**：头在 request 写完之后才写，4 字节在 answer 写完之后才写。
  所以一个字节从管道读出来就是它背后那些字节已经就位的证明。没有事件、没有信号量。
- 映射由 daemon 造（像素上限是它的），layer 按名字开、从开头 64 字节读布局。
  一个 slot = 颜色 + mask + answer，4 个（= 同时在飞的帧数上限）。
- 老 layer / 老 daemon / Linux / `NR_SHM=0` 一律走管道，行为不变。

### 13.3 端到端验证（`src/bench/check_shm_exchange.py`）

真 daemon 进程 + 真管道 + 真映射，同样的帧各发一遍：
**8/8、12/12、6/6 逐字节相同**。往返 **45.0 ms → 41.5 ms**（1920x1080，稳态）。

⚠️ 前三帧仍然慢约 4.5 ms：每个 slot 的页在被写时才提交。daemon 建映射时先按页
touch 一遍也没消掉，是 layer 那一侧第一次 MapViewOfFile 后的软故障。只影响开局。

### 13.4 🚩 顺带挖出一个更大的：`nr_link_read` 的轮询粒度

layer 是**同步**模式（`NR_LAYER_ASYNC` 没设），send 完立刻 receive，所以它那次
等待 = daemon 处理整帧的时间（40 ms 量级）。而 `nr_link_read` 是
`PeekNamedPipe` + `Sleep(10)` 轮询 —— 本机实测 Sleep 粒度：**10 → 10.22 ms，
1 → 1.51 ms**。每帧白扔半个步长，**约 4.5 ms，花在游戏进程里**。

改成 `Sleep(1)`，并在首次连接时 `timeBeginPeriod(1)`（懒加载 winmm，不链库）——
否则 Windows 默认定时器是 15.6 ms，1 ms 不是 1 ms。

### 13.5 一帧剩下的钱（C 之后）

| 项 | 之前 | 现在 |
|---|---:|---:|
| 设备图 | 34.4 | 34.4 |
| PCIe 上传 + 回写 8.3 MB | 3.34 | 3.34 |
| 管道收 + 发 | 2.54 | ~0.15 |
| layer 端轮询等待 | ~4.5 | ~0.5 |
| 其余 | 0.7 | 0.7 |

剩下能动的：**设备侧 34.4 ms（选项 B，一组工作）**，以及 Phase 2 的 external memory
——让 layer 直接映射 daemon 那块 HOST_READ 内存，连上传回写一起省（理论 5.8 ms）。

## 14. Phase 2 的前提已验证：A770 上两个 VkDevice 能共享同一块 buffer（2026-10-11）

`src/gpu/extmem_probe.c`（编译：`tools\build_extmem_probe.bat`，运行：`work\extmem_probe.exe`）。
一块 1 MB 的 DEVICE_LOCAL buffer，从 device A 导出 `OPAQUE_WIN32` handle 到 device B 导入，
两边各自 `vkCmdFillBuffer` / `vkCmdCopyBuffer` 回读到宿主比对。

| | 结果 |
|---|---|
| `opaque_win32` buffer 的 exportable / importable | **1 / 1** |
| 两个 VkDevice 建在同一物理设备上 | 成功（两边 queue family 都是 0） |
| 导出 handle + 导入 + 绑定 | 成功 |
| A 写 → A 读（自洽） | 0 / 1048576 字节错 |
| B 写 → B 读（自洽） | 0 / 1048576 字节错 |
| **A 写 → B 读（无 semaphore，只等 A 的 fence）** | **0 / 1048576 字节错** |
| **A 写 → B 读（带共享 semaphore）** | **0 / 1048576 字节错** |
| **B 写 → A 读** | **0 / 1048576 字节错** |

**结论：Phase 2 在 A770 上成立。** 导入的是同一块内存（规范：`VkImportMemoryWin32HandleInfoKHR`
的 "the imported memory object holds a reference to its payload"，不是拷贝），双向都对。

### ⚠ 这个 probe 第一版报告"全部 stale"，那是它自己的 bug

第一版用 `vkCmdFillBuffer(..., 0xAB)` 而 `vkCmdFillBuffer` 填的是 **32 位** pattern，
所以内存里是 `AB 00 00 00`；比对却要求**每个字节**都等于 `0xAB` → 四个字节里三个必然不符，
于是 262144 个 word 全错。当时我把它解释成"fence 不够、需要 semaphore"，**那是猜的，而且猜错了**。
现在的 pattern 一律是四字节重复（`0xA5A5A5A5` / `0x5A5A5A5A` / `0x3C3C3C3C` / `0xC3C3C3C3`）。
⚠️ 教训：**"全部错"先怀疑测量本身**，尤其"按字节比对一个按字写入的值"这类单位错配。

### 关于 semaphore：实测不需要，但规范不保证

| 依据 | 内容 |
|---|---|
| 规范（`VkImportMemoryWin32HandleInfoKHR`） | 导入的是同一 payload；可以导入多次，每次是独立的 `VkDeviceMemory` |
| 规范（`VK_KHR_external_memory_win32` Issues 1） | OPAQUE_WIN32 的 handle 由应用 `CloseHandle`；与 fd 不同，导入不会把所有权交回驱动 |
| 引用到的规范原理 | "writes are only visible to the queue family that did them unless you transfer ownership"；漏掉的症状是"间歇性陈旧帧" |

本卡上两边 queue family 相同（都是 0），所以 fence 就够。但这是**同进程、同 family** 的情形；
真正的 Phase 2 是**跨进程**（layer 在游戏进程，daemon 单独进程），handle 要 `DuplicateHandle`，
同步要走 semaphore。**下一步 probe 就该测跨进程那一步，别拿同进程的结果当跨进程已验证。**

### 这一步能省的钱（沿用 §13.5）

| 项 | ms |
|---|---|
| PCIe 上传 8.3 MB（`pass_prepare` 的 host_write） | ~1.5 |
| PCIe 回写 8.3 MB（answer 落在系统内存的 `HOST_READ`） | 1.84 |
| 管道（共享内存化之后已经很小） | ~0.15 |

**约 3.5 ms**，外加 layer 端那次拷贝。仍未动的是设备侧的 32.8 ms。

## 15. ✅ 跨进程那一关也过了：两个进程共享一块 buffer，CPU 写的 GPU 立刻读得到（2026-10-11）

`src/gpu/extmem_xproc.c`（编译 `tools\build_extmem_xproc.bat`，运行 `work\extmem_xproc.exe`）。
一个 exe 两个角色：父进程 = layer 那一侧，子进程 = daemon 那一侧，中间两条匿名管道传命令。
父导出一块 1 MB 显存 + 两个 semaphore，`DuplicateHandle` 给子进程，子进程导入。

| # | 谁写 | 谁读 | 怎么排序 | 错字节 |
|---|---|---|---|---|
| 4 | 父 GPU（`CmdFill`） | 子 GPU | 导出 semaphore | **0** |
| 5 | 父 GPU | 子 GPU | 无 semaphore（父先等了自己的 fence） | 0 |
| 6 | 父 GPU，**父不等 fence** | 子 GPU | 只有 semaphore | **0** |
| 7 | 子 GPU | 父 GPU | 另一个 semaphore | **0** |
| 8 | **父 CPU 写 BAR** | 子 GPU | 空 batch signal semaphore | **0** |
| 9 | 父 CPU 写 BAR + `FlushMappedMemoryRanges` | 子 GPU | 同上 | **0** |

连跑四次，`total bytes wrong` 一律 0。

- 第 6 项是真正有用的那条：**semaphore 跨进程把依赖带过去了**，父进程压根没等自己的
  fence，子进程照样读到新值。第 5 项 0 错不能拿来当"不需要 semaphore"的证据——那时父
  进程自己 block 过，是宿主侧的顺序在兜底。
- 第 8/9 项：CPU 写的是 **type 3**（flags 0x7 = `DEVICE_LOCAL|HOST_VISIBLE|HOST_COHERENT`，
  heap 15.9 GiB，就是 §结论 3 测绘的那块 BAR 显存，daemon 的图缓冲也在这儿）。
  **不 flush 也干净**。

### ⚠ 驱动把 `memoryTypeBits` 报成 0

`vkGetMemoryWin32HandlePropertiesKHR` 对这两个 handle 都返回 **0x0**。规范原话是"one bit
set for every memory type which the specified handle can be imported as"，0 等于说"哪都
导不进去"，可这 handle 就是这块卡自己发的。同进程 probe（§14）根本没问过这个 API 也导入
成功了，所以按 0 判死就是把自己卡住。现在的实现：**bits == 0 时退回 buffer 自己的
`memoryTypeBits`**，让 `vkAllocateMemory` 来当裁判（实测放行）。

### 对那个 NaN 的裁决

§五 的嫌疑是"host 写 DEVICE_LOCAL|HOST_VISIBLE 的 BAR 映射，GPU 侧读到陈旧数据"。
**这一条现在可以划掉**：跨进程、1 MB、CPU 整块写、不 flush，另一个进程的 GPU 读到的是
新值，0 错。

但别把话说满：probe 写的是 `memset` 整块 1 MB，而 `NR_INPUT_VIEW=1` 是 NumPy 在 8.3 MB
mapped 内存上**逐元素**算完写。所以现在能确定的是"BAR 的可见性没问题"，**NaN 的真因仍
未定位**——它更可能在 NumPy 那侧的写入模式或 `nr_resident.py` 自己的路径上。
要钉死它还得单独 probe（NumPy 逐元素写 → GPU 读）。

### 收益重估（比 §14 那张表保守）

§结论 3 已经说了：`HOST_WRITE` 本来就是 type 3 = VRAM + BAR，**"上传"其实是 CPU 写 BAR**，
不是 GPU 过 PCIe 去系统内存读。所以 Phase 2 省不掉那次写 8.3 MB，省的是**多出来的那几趟
memcpy**：

| 方向 | 现在 | Phase 2 | 省 |
|---|---|---|---|
| 输入 | layer→共享内存 + daemon 读出来再写进 BAR | layer 直接写进导入的 BAR | 一趟 8.3 MB 读 + 一趟写，约 1.5–2 ms |
| 输出 | GPU 写 `HOST_READ`(系统内存) 1.84 + daemon 读 + 写共享内存 + layer 读 | GPU 写 VRAM(~0) + layer 读 BAR | 约 1–2 ms |

**合计 3 ms 上下**（§14 那张表的 3.5 ms 量级是对的，但"省掉 PCIe 上传"这个说法不准确，
上传还在，只是换了个进程做）。设备侧的 32.8 ms 仍未动。

### 接下来要动的地方

1. daemon 侧：把输入 buffer 和输出 buffer 都建成可导出的（type 3 / GRAPH），把 handle
   （`DuplicateHandle` 到 layer 进程）和两个 semaphore 的 handle 一起发给 layer。
2. layer 侧（`nr_layer.c`）：导入它们，帧字节直接写进导入的 BAR，回程直接读 BAR。
3. 同步：帧开始靠 layer 给 daemon 的 semaphore，帧结束靠 daemon 给 layer 的 semaphore。
   第 6 项证明这条路走得通。
4. **先做离线验证再碰游戏**：`nr_settings.json` 加一个开关，默认关，跑通了再开。
