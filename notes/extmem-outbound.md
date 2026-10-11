# Phase 2 去程：帧进 daemon 自己的 buffer

结论先说：**去程是逐字节正确的**。1920x1080，同一份字节，走管道、走共享内存、
走 external memory 三条路，答案 **0 / 8294400 字节不同**。

而在此之前它被认为错了整整一天，报的是 **2024 字节不同**。那 2024 个字节是
**测试脚本自己写的 0**，不是设备读错了。

## 那 2024 个字节是从哪来的

`nr_pipe.FrameMapping.__init__` 里有一行预提交页面用的代码：

```python
np.frombuffer(self._map, np.uint8)[::4096] = 0
```

它把整个 mapping（含所有槽位的答案区）每 4096 字节写一个 0。`check_extmem_
roundtrip.py` 原来在**每次读答案之前**都重新构造一个 `FrameMapping`，于是 daemon
刚写进槽位的答案被按页打洞。

五项特征全部对上，一项不差：

| 观测 | 算出来的 |
|---|---|
| 2024 字节不同 | 8294400 / 4096 = 2025，按区起点偏移取整到 **2024** |
| 15 个列，步长 128 | 4096 字节 = 1024 像素；gcd(1024, 1920) = **128**，1920/128 = **15** |
| 1080 行全覆盖 | 2024 × 1024 / 1920 = **1079.5**，扫过全部行 |
| 只影响通道 0 | 答案区起点 `HEAD + colour + mask` = 20745128，mod 4096 = 2984 → 相对偏移 ≡ 1112 (mod 4096)，**1112 % 4 = 0** |
| largest 253 | 某个 253 被写成 0 |

另外三条也顺带解释了：

- **"wire vs wire 是 0"** —— wire 帧的答案走管道，从来没被碰到过。
- **"两帧 extmem 完全一致"** —— 两次都被同样地打洞，看起来像"确定性错误"。
- **"换一张图 → 75% 不同"** —— 设备确实读到了写入的字节，所以这个"证据"
  当时反而把方向引到了"部分未刷出"上。

## 是怎么找到的

把两个变量分开。原测试里 wire 帧和 extmem 帧之间**同时变了两个东西**：帧怎么进来，
和答案从哪读出来。新写的 `src/bench/check_answer_where.py` 把"答案从哪读"固定住，
三路都从同一个槽位读：

| | 帧怎么进来 | 答案从哪读 |
|---|---|---|
| A | 管道 | 管道 |
| B | 槽位（`MAGIC_SHM`） | 槽位 |
| C | buffer（`MAGIC_EXTMEM`） | 槽位 |

A 对 B 是槽位自己的账，B 对 C 才是 Phase 2 的账。三路全是 0 —— 于是问题只可能在
"A 对 B"这一段，而 A 是走管道的，从没被碰过 → 只能是 B/C 读答案的那一步。
那一步唯一做的事就是 `FrameMapping(...)`。

## 因此回滚的东西

追这个幽灵的时候改过两处，理由现在不成立，已还原：

1. **`extmem_input` 的 buffer kind**：`HOST_READ`（系统内存，cached）→ 回到
   `HOST_WRITE`（**type 3，卡上 BAR 显存**）。离设备更近。复测同为 0 字节不同。
2. **`libxmx.c` 里那三段的注释**：原文写着"实测 2024 字节""设备读到陈旧的字节"
   这类陈述，全是假的。已改成说实话。

## 留着的，和为什么要留

- **`vkCmdPipelineBarrier(HOST → ALL_COMMANDS)`**（`xmx_begin`，有 pending wait 时）。
  规范 chap7 原文：

  > Queue submission commands automatically perform a domain operation from host
  > to device for all writes performed before the command executes ... In the few
  > circumstances where **a submit does not occur between the host write and the
  > device read access**, writes can be made available by using an explicit memory
  > barrier.

  我们这里 host 写之后**确实有 submit**（等完 timeline semaphore 才提交），属于
  "不需要"的那一类。留着是保险，不是修复。加了 `NR_NO_HOST_BARRIER=1` 可以摘掉，
  是第一个该从 profile 里丢的东西。
  ⚠️ 这个开关要生效得重建 `work/libxmx.dll`；本轮没重建（默认行为不变，不需要）。
- **buffer 也带 `VkExternalMemoryBufferCreateInfo`**（原来只给 memory 带了）。
  规范上两边应当一致，与导入侧成对。没测出过差别，留着是因为它本来就该有。
- `xmx_buf_flush` / `xmx_write_fence`：实测去掉也 0 字节不同（`NR_RT_NOFENCE=1`
  在 `check_answer_where.py` 里）。留着供以后排查。

## 规范归档

搜到并归档在 `refs/vulkan-sync/`（上级目录）：

- `chap7-synchronization.html` —— availability / visibility / domain operation 的定义；
  `vkQueueSubmit` 的隐式 domain operation 覆盖范围；`vkSignalSemaphore` 的第一同步域
  "includes execution of vkSignalSemaphore on the host and **anything that
  happened-before it**"。
- `vkSignalSemaphore.html` —— 仅对 timeline 合法；第二段同步域为空。
- `host-write-visibility.md` —— 同期整理的要点：**coherent ≠ 可见**；semaphore 只
  建立执行顺序；Arm 关于 HOST_COHERENT 是 uncached / write-combining 的说明。

⚠️ 那篇 `host-write-visibility.md` 里"实测 barrier 未解决"一节是错的 —— 当时没有
  可以解决的问题。已在此更正。

## 下一步（回程，待做）

1. probe type 2 能否导出（回程的 answer buffer）
2. `RequestPass.answer` 加 exportable
3. daemon 把 answer 的 handle 传给 layer
4. layer 不再从 slot memcpy 出答案
5. 补"answer 已读完"的信号（否则下一帧会覆盖）
6. 回程等价性验证：与去程同一套三路对照

## 复现命令

```
"E:/AI/Program/Python/Python311/python.exe" src/bench/check_answer_where.py
"E:/AI/Program/Python/Python311/python.exe" src/bench/check_extmem_roundtrip.py
```

⚠️ 踩过的坑，别再踩：

- 测试里 **mapping 要在任何帧之前开一次，然后一直用**。在读完答案的循环里 new 一个
  就是在给自己的答案打洞。已写进 `FrameMapping.__init__` 的 docstring。
- 生产代码里只有 daemon 构造一次 `FrameMapping`；layer 是 C 的 `nr_shm_open`，
  只读 head 不写，所以这个坑只在测试侧。
- 改了 `libxmx.c` 要重建 `work/libxmx.dll` 才生效（本轮刻意没重建）。
- print 要 `flush=True`，`os._exit` 会把缓冲区带走。

---

# 附：游戏里 NR 不生效 —— 原始字节被当成帧去 resample

## 现象

`work/nr_daemon.log` 第 15 场会话（extmem 开）：**7445 帧里 28 帧成功、7407 帧被拒**

```
frame rejected/failed; game keeps original: not enough values to unpack (expected 2, got 1)
```

按会话统计，指向很明确：

| 会话 | extmem | 帧数 | 拒绝 |
|---|---|---|---|
| 1–12 | 关 | 数万 | **0** |
| 13, 14 | 开（只 1–2 帧） | 3 | 0 |
| 15 | 开 | 7445 | **7407** |

## 根因

`History.keep(..., words=payload)` 是 daemon 说"设备留下了这一帧的预测，宿主只留游戏
发来的原始字节"。这些字节交给 `take` 后作为 `history_full` 返回，**所有调用方都只当标志位用**
（`history_full is not None`，在 1326 / 1340 / 1467 三处）。

只有一处当帧用：`take` 里要把 `previous` 重采样到网络尺寸，而 `previous` 在
`self.output is None` 时回落到 **`self.words`** —— 一维 uint8，不是帧。
`resample` 第一行 `height, width = image.shape[:2]` 就直接炸。

**为什么只有 extmem 会触发**：取决于 `payload` *是什么类型*。

| 帧从哪来 | `payload` 类型 | `isinstance(..., np.ndarray)` |
|---|---|---|
| 管道 | `bytes` / `bytearray` | False → 跳过重采样 ✅ |
| shm 槽位 | `memoryview` | False → 跳过 ✅ |
| **extmem buffer** | **`np.ndarray`（一维 uint8）** | **True → 去重采样 → 崩** ❌ |

同一个 daemon、同一份字节，只因为容器类型不同，一条路每帧崩、另两条路从来没事。
**`isinstance(x, np.ndarray)` 不是"这是一个帧"的判据。**

## 修复

`nr_daemon.py:726`：

```python
elif isinstance(previous, np.ndarray) and previous.ndim >= 3:
```

加了 `previous.ndim >= 3` —— 帧是 (H, W, C)，原始字节是一维。修完之后 extmem 的行为
与管道/槽位**完全一致**（`inner = None`，`history_full` 仍作为标志位返回）。

## 为什么之前两次端到端测试没抓到

- **`check_answer_where.py` / `check_extmem_roundtrip.py`**：只跑几帧，而且等答案，
  历史还没建立起来。
- **`check_many_frames.py` 200 帧**：合成帧每帧都换种子，`cut ≈ 0.235` 一直高于
  `cut_limit` → `take` 在 715 行就判"切场"返回 `(None, None, None)`，**永远走不到
  726 行那次重采样**。

游戏里**画面静止时** `cut` 小，历史被保留 → 走到 726 行 → 崩。这解释了日志里
"成功帧都带 cut 0.15–0.25（大），失败帧没有输出（崩了）"。

→ 加了 `NR_MF_STILL=1`（每次发同一帧）的静止帧模式，端到端立刻复现：

```
修复前（HEAD 版本）+ 静止帧 + extmem：
  frame rejected/failed: not enough values to unpack (expected 2, got 1)   ← 与游戏一字不差
修复后：30 / 60 帧全部应答
```

**教训：合成测试里"每帧都不一样"是最容易造的，也是最容易骗过自己的。游戏大部分
时间是静止的，那一半才是有历史的那一半。**

## 找到它靠的是 traceback

之前的日志是"每帧一行消息、七千行、从来说不出在哪一行"。已给 daemon 加了
`frame_failure(error)`：**同一类失败第一次发生时打印 traceback**，之后只打消息。
（两处 except 都换成了它。）用户重跑 30 秒就拿到了：

```
File "nr_daemon.py", line 1304, in stage_prepare
File "nr_daemon.py", line 730, in take
File "nr_daemon.py", line 441, in resample
ValueError: not enough values to unpack (expected 2, got 1)
```

⚠️ 这个改动本身值得留着：没有它这次还要再盲查一天。

## 回归

- `check_history_words.py`：`bytes` 与 `uint8 array` 两条路现在一致（修复前一条崩一条过）
- `check_answer_where.py`：三路仍 **0 / 8294400** 字节不同
- `check_extmem_roundtrip.py`：通过
- `check_many_frames.py 60 extmem` 静止帧：全过
- `check_many_frames.py 30 shm` 静止帧：全过（非 extmem 路径无回归）

纯 Python 改动，**不需要重建 dll**。

---

# 游戏实测（2026-10-12 02:47，通过）

`nr_play_extmem.bat` 进固定场景跑一轮，**1614 帧、0 拒绝**，用户确认观感没问题。

| | 修复前（第 15 场） | 修复后（第 17 场） |
|---|---|---|
| 总帧 | 7445 | 1614 |
| 拒绝 | **7407** | **0** |
| 帧时间中位 | — | **40.0 ms / 25.0 fps** |
| `gpu` 设备 | — | **38 ms**（38 / 38 / 44） |

对照：验收基线就是 **40 ms / gpu 0+38+0**；历史最好的无 extmem 场次（第 9 场 19676 帧、
第 11 场 2543 帧）也是 **40.0 ms / gpu 38**。→ **去程上线，无回归。**

⚠️ **去程那约 3 ms 的净收益在这个数上看不出来**：帧时间的 p25、p75 和中位**全都是精确的
40.0 ms**，说明被帧率上限钉住了（DOOM Eternal 自己的或 RTSS 的）。要量到那 3 ms，得先
解开上限，或者只比 daemon 自己的时间。别指望在 40.0 这个数上看出差别。

数字来源：`work/nr_daemon.log`，第 17 场会话。

---

# 回程（Phase 2 第二步）：实测不成立，已关掉

开关 `NR_EXTMEM_ANSWER`（默认 0），`tools/nr_play_extmem.bat` 里设过 1 又改回 0。
代码保留，注释里写了为什么关。

## 游戏实测

| 场次 | 配置 | 帧数 | 帧时间中位 | `gpu` | 拒绝 |
|---|---|---|---|---|---|
| 17 | 只去程 | 1613 | **40.0 ms** | 38 | 0 |
| 18 | **去程 + 回程** | **255** | **50.0 ms** | 38 | 0 |
| 19 | 只去程（回程关掉后） | 1230 | **40.0 ms** | 38 | 0 |

回程那场只跑了 255 帧就**闪退**（另外两场都是 1200+ 帧）。daemon 侧日志完全正常：
0 拒绝、`gpu` 仍是 38 —— **崩的是游戏进程**。

## 根因：host 读 BAR 慢到不能用

`src/bench/check_bar_read.py` 量的（各 9 次取中位）：

| 内存 | 读 7.9 MB | 折合 |
|---|---|---|
| **type 3，VRAM 通过 BAR** | **376.77 ms**（memmove） / 409.10 ms（numpy copy） | **0.02 GB/s，47.6 ms/MB** |
| type 2，系统内存 | **0.40 ms**（memmove） / 1.20 ms（numpy copy） | 19.48 GB/s，0.05 ms/MB |

**慢约 950 倍。**

## 为什么：同一个窗口，两个方向不是一个价

PCIe 的 BAR 窗口是 uncached。写可以合并（write-combining）并**不等待**——
posted write，发出去就完事；读**必须等往返**，而且没有预取，一个 cache line 一次往返。
7.9 MB / 64 B ≈ 13 万次往返，每次约 3 µs，就是那 376 ms。

这正好把去程和回程分成了两半：

| | 谁 | 对 BAR 做什么 | 价 | 结论 |
|---|---|---|---|---|
| **去程** | layer | **写** BAR | 合并、posted，8.3 MB ≈ 1.5 ms（参考 §已测） | **成立**，已上线 40 ms |
| **回程** | layer | **读** BAR | 逐 cache line 往返，8.3 MB ≈ 376 ms | **不成立** |

## 设计文档那张表错在哪

`notes/host-passes-to-gpu.md` 的「收益重估」表写：

> | 输出 | GPU 写 `HOST_READ`(系统内存) 1.84 + daemon 读 + 写共享内存 + layer 读 | GPU 写 VRAM(~0) + **layer 读 BAR** | 约 1–2 ms |

它把"layer 读 BAR"估成 1–2 ms。参考里其实**从来没量过这个数** —— §结论 3 量的是
"设备写系统内存 0.197 ms/MB ≈ 5.1 GB/s"，§14 量的是"host 写 BAR ≈ 1.5 ms"，
**host 读 BAR 一次都没测**。那张表是拿写的数字去猜读的。

而实际上回程能省的**上限**也只有 daemon 那一次拷进 shm 的 memcpy（8.3 MB ≈ 0.7 ms）：
layer 的读从"系统内存"换成"BAR"，成本从 0.40 ms 变成 376 ms。
**净 = +376 ms 级别，收益上限 0.7 ms。**

## 还有没有别的做法

answer 留在 type 2（系统内存）并导出它，layer 仍从系统内存读（0.40 ms，与现在从 shm 读一样），
省掉 daemon 拷进 shm 的 0.7 ms。但：
- type 2 能否跨进程导出**未验过**；
- 收益上限 0.7 ms；
- 闪退的那一半风险——**游戏进程里第二个 VkDevice**（设计文档 §7 点名"本方案最大的未知项"）——
  并不会因此消失。

**0.7 ms 的收益对上崩溃的风险，不值得。** 回程就此搁置。

## 另一个要记住的教训

离线账本当时就给了信号：回程关 34.80 ms / 回程开 **35.77 ms**（+0.97 ms）。
我把它解释成"账本只量设备时间，省的是宿主 memcpy，量不到"就开了。
**那个信号是对的，我不该绕过去。** 离线数字与预期相反时，先解释清楚再上线。

## 修正与补全（回答"去程不也一样吗"）

### 用户问得对：去程里 layer 本来就在读一块 BAR 映射，为什么不慢？

因为**那块不是 BAR 显存**。`nr_layer.c:1346` 分配 staging 时的优先顺序是：

```c
type = memory_type(data, bits, HOST_VISIBLE | HOST_COHERENT | HOST_CACHED);
if (type == UINT32_MAX)
    type = memory_type(data, bits, HOST_VISIBLE | HOST_COHERENT);
```

**`HOST_CACHED` 排在最前面**，而独显一定提供这种类型——它就是**系统内存**，
进 CPU cache、有硬件预取。所以 layer 读 AMD 的 staging 是在读系统内存，
19.5 GB/s 那一档，不是 0.02 GB/s 那一档。

而 A770 的 **type 3** 是 `DEVICE_LOCAL | HOST_VISIBLE | HOST_COHERENT`，
**没有 HOST_CACHED** —— 它是真 VRAM 通过 BAR，uncached。回程把答案放进它，
layer 再读，就落到了 0.02 GB/s 那一档。

🚩 **分水岭不是"显存 vs 系统内存"，是那块内存带不带 `HOST_CACHED`。**

| 内存 | 标志 | CPU 读 7.9 MB |
|---|---|---|
| 系统内存（layer 的 staging 在这） | HOST_VISIBLE+COHERENT+**CACHED** | 0.40 ms |
| 真 VRAM 过 BAR（回程把答案放这儿） | DEVICE_LOCAL+HOST_VISIBLE+COHERENT（**无 CACHED**） | 376.77 ms |

### 所以不对称的根源是"写还是读"，不是"谁在做"

两个方向里 GPU 那一步都很快、且都不是变量（`gpu` 两场都是 38 ms，一动没动）：
- 去程：GPU 把 image 拷进 staging（AMD 卡上，与 Intel 无关）
- 回程：GPU 把答案写进 buffer（写自己的内存，0.36 ms）

Phase 2 真正改动的，都是 layer 对**同一块 uncached BAR 显存**做的那个动作：

| | layer 对 BAR 显存做 | 事务类型 | 价 |
|---|---|---|---|
| 去程 | **写** | posted，可合并，不等回应 | 8.3 MB ≈ 1.5 ms　**成立** |
| 回程 | **读** | non-posted，uncached 无预取，64 B 一次往返 | 7.9 MB ≈ 376 ms　**不成立** |

### 要说清楚的一点：376 ms 不是游戏里看到的数字

游戏里回程的表现是 **40.0 → 50.0 ms 掉了一个帧率档（25→20 fps），然后 255 帧后闪退**，
不是 +376 ms。帧时间只有 10 ms 精度且被 vsync 量化，量不出真实代价；
layer 里的 memcpy 与我离线测的读取粒度也不一定一样。

**方向是确定的（掉档 + 崩溃），幅度不能拿 376 ms 直接套。**
离线那个数字的作用是说明"这个方向差 950 倍"，不是预测游戏里会慢多少。

### 那为什么去程也没看到收益？

同样是精度问题：帧时间只有 10 ms 精度 + vsync 量化，
量不出设计文档估的 1.5–2 ms。去程开与不开**都是 40.0 ms**——
这既不能证明有收益，也不能证明没收益。**要看清这个量级的差异，得换指标**
（daemon 自己记的分段时间，或者不看 vsync 的裸时间）。
