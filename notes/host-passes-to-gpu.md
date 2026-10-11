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

### 10.4 下一步

先做 10.3 的第 1 条：设备路径下让 `decode` 只在真正需要全帧 fp32 时才做
（letterbox 改在字节上判），**省约 2 ms**，且不动任何已验证的开关。
再回头拆那 4.9 ms 的未归因部分。
