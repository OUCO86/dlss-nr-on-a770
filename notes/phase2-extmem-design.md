# Phase 2 接入设计：layer 与 daemon 共享显存

前置已验证（`notes/host-passes-to-gpu.md` §15，`src/gpu/extmem_xproc.c`）：
两块 VkDeviceMemory 可以跨进程共享（含 semaphore 携带依赖），且 **CPU 写 type 3 的 BAR、
另一个进程的 GPU 立刻读得到**。本文是把这件事接到真实链路上去的设计。

## 1. 现在的帧是怎么走的

### layer 侧（`src/layer/nr_layer.c`，在游戏进程里）

| 环节 | 位置 |
|---|---|
| present 入口 | `nr_QueuePresentKHR:1652` → `present_locked:1511` → `process_frame:1380` |
| swapchain image → staging（AMD 卡的 buffer） | `transfer():1237`，`vkCmdCopyImageToBuffer:1296`，等 fence `:1325` |
| **拷进共享内存** | `nr_layer.c:271`（`exchange_send:257` 内，`memcpy(nr_shm_request(...))`） |
| 回程读结果 | `exchange_receive:296`，`memcpy(reply, nr_shm_answer(...)):306` |
| 结果写回 image | `memcpy(data->mapped, result, needed):1422` → `transfer(..., to_image=1):1590` |
| 同步 | 管道：layer 发 20 字节 header（带 slot）`:272-277`，daemon 回 4 字节 notice；layer 在 `nr_link_read`（`nr_transport.h:133`）`PeekNamedPipe` + `Sleep(1)` 轮询 |
| 已有的 VkDevice | `data->device:965`，**是游戏那张 AMD 卡的**，不是 A770 |
| 与 daemon 的关系 | `ensure_daemon:591` → `CreateProcessA:813`，`bInheritHandles=TRUE`；**父子关系是真的**，但 `pi.hProcess` 在 `:824` 立刻被关掉 |

### daemon 侧（独立进程，Python + `libxmx.dll`）

| 环节 | 位置 |
|---|---|
| 输入 buffer（`raw`，HOST_WRITE） | `nr_frame_resident.py:789`，写入 `:862`（`xmxres.host_write`） |
| 输出 buffer（`answer`，HOST_READ） | `nr_frame_resident.py:831`，读取 `:973` |
| 分配入口 | `xmx_buf_create_kind`（`libxmx.c:1168`），`vkAllocateMemory:1197` |
| ⚠ 注意 | `ai.pNext` 已被 `VkMemoryAllocateFlagsInfo`（DEVICE_ADDRESS）占用 `:1192-1195`，`VkExportMemoryAllocateInfo` 要链在它后面 |
| instance 扩展 | `libxmx.c:711-713`，**目前一个都没开** |
| device 扩展数组 | `libxmx.c:874-876` |
| Python 侧签名表 | `xmxres.py:94` 起，`:160-161` 设 argtypes |
| DLL 导出 | `xmx_*` 非 static 函数由 `tools/build_win.bat:100` 自动扫进 `work/libxmx.def` |
| 同步 | 阻塞管道 `nr_daemon.py:1038` 读 header；完成 `send_answer:214-228`（先拷 answer 进 shm `:227`，再发 4 字节 `:228`） |

## 2. 改成什么样

layer 不再往共享内存里拷那一帧，而是**直接写 daemon 导出的那块 BAR 显存**；
daemon 也不再往共享内存里回拷结果，layer **直接读**。

| 项 | 现在 | 之后 |
|---|---|---|
| 入：layer | 拷进 shm（系统内存，~0.7 ms） | 拷进 BAR（~1.5 ms） |
| 入：daemon | 读 shm + 写进 BAR（~2.2 ms） | 无（0） |
| 出：daemon | GPU 写 HOST_READ（系统内存）1.84 ms + 拷进 shm 0.7 | GPU 写 VRAM ≈ 0 |
| 出：layer | 读 shm 0.7 | 读 BAR ~1.5 |

**净省约 3 ms。** ⚠ 跟 §14 那张表的说法要区分：PCIe 上传并没有消失，
`HOST_WRITE` 本来就是 type 3 = VRAM + BAR，"上传"就是 CPU 写 BAR，只是换了个进程写。
省掉的是共享内存两侧的 memcpy 和 GPU 往系统内存写的那一趟。

## 3. 改动清单

### daemon / libxmx（先做，离线可验）

1. instance 加 `VK_KHR_external_memory_capabilities`、`..._semaphore_capabilities`（`libxmx.c:711`）。
2. device 扩展加 `VK_KHR_external_memory_win32`、`VK_KHR_external_semaphore_win32`（`:874`）。
3. 新增 `xmx_buf_create_exportable(bytes, kind)`：与 `xmx_buf_create_kind` 并列，
   **不改旧函数**（旧签名被 Python 侧大量调用）。区别只在 `ai.pNext` 链尾挂上
   `VkExportMemoryAllocateInfo{OPAQUE_WIN32}`。
4. 新增 `xmx_buf_handle(id)` → `vkGetMemoryWin32HandleKHR`，返回 handle 数值（`uint64`）。
5. 新增 semaphore 的导出/导入：`xmx_sem_export()`、`xmx_sem_import(uint64)`。
6. `xmxres.py:94` 起登记这三个函数的 ctypes 签名。

### handle 怎么回到 layer（这是唯一有点绕的地方）

buffer 在 daemon 手里，得从**子**进程把 handle 给**父**进程：

- layer spawn daemon 时命令行带上 `--parent-pid <pid>`；
- daemon 用它 `OpenProcess(PROCESS_DUP_HANDLE, ...)` 拿到父进程句柄，
  再 `DuplicateHandle(..., GetCurrentProcess(), hmem, parent, &dup, ...)`，
  把 **dup**（在父进程里有效的那个值）通过管道发给 layer。

（继承只能父→子，反着不行，所以必须走 DuplicateHandle。）

### layer 侧

7. 在 **A770 上另建一个 VkDevice**（`data->device` 是 AMD 卡的，用不了；
   `src/gpu/gpu_pick.h` 里有选卡的现成逻辑），开 external memory 扩展。
8. 导入 raw / answer 两块 buffer 并 `vkMapMemory`，直接用指针读写。
9. 导入两个 semaphore，帧起止各一个。

### 开关与回退

- 新开关 `NR_EXTMEM`（环境变量），**默认 0**。daemon 与 layer 都要看到它
  （`nr_play.bat` 里 `set` 好，跟其它 `NR_*` 一样）。
- 不是热切换：buffer 要不要 exportable 得在分配时定，所以开关只在启动时读一次。
- 默认关，意味着改坏了也只是没收益，不会回退到比现在差。

## 4. 同步设计

| 时刻 | 谁 | 做什么 |
|---|---|---|
| 帧开始 | layer | CPU 写 raw（BAR），提交一个空 batch signal `sem_start` |
|  | daemon | 图的第一次 submit **wait** `sem_start` |
| 帧结束 | daemon | 最后一次 submit **signal** `sem_done` |
|  | layer | wait `sem_done`，读 answer |

`extmem_xproc.c` 第 6 项已经证明这条路：**父进程不等自己的 fence，只靠 semaphore，
子进程照样读到新值**。

⚠ 要确认 `libxmx.c` 的 submit 接口能不能带 wait/signal semaphore（现在的
`xmx_submit`-类函数可能没有这两个参数），没有的话要先加。

## 5. 验证计划（按顺序，跑完一项再进下一项）

1. ✅ **libxmx 导出 → 独立进程导入（已过，2026-10-11）**：
   `src/bench/check_extmem_export.py`，`extmem_xproc.exe guest`。
   daemon 侧用 `rt.buffer(..., HOST_WRITE, exportable=True)` 建一块 1 MB，写 `0xA5`，
   `DuplicateHandle` 给 guest，guest 用自己的 VkDevice 读回：**0 / 1048576 字节错**，
   落在 memory type 3。反向 guest 填 `0x5A`，daemon 这边也读到了。
   非导出的三条路径（GRAPH / HOST_WRITE / HOST_READ）upload→download 往返照旧逐字节相同。
2. **离线单帧 bit-identical**：daemon 跑一帧，`raw` 由外部进程按现在的字节填进去，
   answer 与现在**逐字节相同**。
3. **游戏实测**：`NR_EXTMEM=1` 的 bat，看帧时间（口径照旧：`work\nr_daemon.log`）。

## 6. 跨进程排序：binary 不行，timeline 行（2026-10-11 实测）

**这一节改过两次，第二次推翻了第一次。两个版本都留着，因为错的那一个错得很有
代表性：观测是真的，结论是假的。**

### 6.1 曾经写错的结论（已作废，只作教训）

曾在 `src/bench/check_extmem_sem.py` 里测到：同进程 wait 有效（1201 ms），
跨进程 wait 完全无效（0.4 ms / 0.2 ms，两次都放行）。当时排除掉了"参数没传进去"
（`XMX_EXTMEM_TRACE=1` 证明进了 `vkQueueSubmit`）、"导入时已 signaled"（第二次该拦住）、
"导入写法"（两种都试）、"共享本身坏了"（buffer 一路 0/1048576 错），
于是写成"这张卡的跨进程 semaphore 不排序"。

**那四个排除都对，但都排错了地方——问题不在驱动，在测试的用法本身。**

### 6.2 为什么那次测的是越界用法

规范的两条：

- **VUID-vkQueueSubmit-pWaitSemaphores-03238**：binary semaphore 的 wait 必须引用
  一个**已经提交**的 signal 操作。
- 「Semaphore State Requirements for Wait Operations」：binary semaphore 在被等之前，
  要么已经是 signaled，要么有一个**已提交、pending 执行**的 signal。

那次测试是：先 submit wait，1.2–1.5 秒**之后**另一进程才 submit signal。
所以 wait 提交那一刻，semaphore 既不 signaled 也没有 pending signal——**越界**。

而 `capabilities` 章节明确写了越界时驱动可以怎么做，三种都合法：

> Continuing execution of the violating command or operation **as if the semaphore
> wait completed successfully** after an implementation-dependent timeout. In this
> case, **the state of the payload becomes undefined**, and future operations on
> semaphores sharing the payload will be subject to these same rules.

这一条把当时看到的每一件事都解释了：放行一次不是"幽灵 signal"，是 payload 从此
undefined，之后**每一次** wait 都走同一条路。驱动在同进程里能拦住，是因为它在用户态
看得到那个"还没提交的 signal"，那是超出规范的宽容，不是保证。

顺带：`vkWaitSemaphores` 那个"驱动崩"也不是驱动的问题——它是 **timeline** semaphore
专用的 host 等待，对 binary semaphore 调用属于未定义行为。

### 6.3 现在的做法：timeline semaphore

Timeline semaphore 没有 signal-before-wait 的要求（`VK_KHR_timeline_semaphore`
的 Issues 里写得很直接：*"Does the new synchronization primitive have the same
signal-before-wait requirement as the existing semaphores do? RESOLVED: No."*），
而且**可以从 host 直接 signal**（`vkSignalSemaphore`），layer 不需要提交任何 GPU 工作。

先确认这张卡肯不肯共享它（`extmem_xproc.exe caps`）：

```
handle type        sem type  export import
opaque_win32       binary    1      1
opaque_win32       timeline  1      1      ← 可用
opaque_win32_kmt   binary    0      0
opaque_win32_kmt   timeline  0      0
d3d12_fence        binary    0      1      ← 只能导入别人的，不能导出
d3d12_fence        timeline  0      1
external fence opaque_win32  1      1
```

`check_extmem_sem.py` 三阶段，延迟分别取 1200 / 1500 / 2000 ms：

| 阶段 | 结果 |
|---|---|
| 1. 同进程 binary wait | 1501 ms → 这张卡的 wait 是真的 |
| 2. 跨进程 binary，wait 早于 signal 提交 | 0.4 ms → 越界用法，合法，不作为判据 |
| 3a. 跨进程 timeline，另一进程 host signal | counter 从 0 变 **1** → payload 真的共享 |
| 3b. 同上，signal 在 N ms 之后 | **1201.1 / 1501.4 / 2001.0 ms**，紧跟 N |

之后那个无 wait 的 submit 照旧 0.4 ms，wait 没有漏到后面。

### 6.4 接线方式（改自 6.1 的 fence 方案）

| 时刻 | 谁 | 做什么 |
|---|---|---|
| 帧开始 | layer | CPU 写 raw（BAR）→ `vkSignalSemaphore(value = 帧号)` → 管道通知 |
|  | daemon | 收到后 `xmx_extmem_wait(sid, value = 帧号)`，第一次 submit 带上它 |
| 帧结束 | daemon | GPU 写 answer，最后一次 submit 的 fence 照旧等 |
|  | layer | 收到管道 notice 后直接 CPU 读 BAR |

- 比 fence 方案更好：layer **不用建 queue、不用提交空 batch、不用等 fence**，
  一次 host 调用即可。代价从 0.1–0.3 ms 降到接近 0。
- `timelineSemaphore` 是 1.2 核心但默认关，device 要显式启用（libxmx 已在
  `VkPhysicalDeviceVulkan12Features` 里打开）。
- **semaphore 类型必须两边一致**（VUID 03262）：`xmx_sem_import(handle, timeline=1)，
  且 wait 必须带 value——timeline 的 wait 不给值是非法提交。
- 每帧 value 递增（帧号即可，单调递增，永不回退）。
- 残留风险不变：daemon 的 GPU 读会不会命中陈旧 L2。probe §15 第 8/9 项是旁证
  （同一块 BAR 被 CPU 写过两轮不同值，子的 GPU 两次都读到新值），接进去之后看画质。

### 6.5 probe §15 那几项要打折（这一条仍然成立）

`host-passes-to-gpu.md` §15 第 4/6/7 项用的是 binary semaphore，且 wait 早于 signal，
就是 6.2 里那个越界用法。那几项的 **0 错只能证明数据能共享，不能证明排序有效**。
第 8/9 项（CPU 写 BAR → 另一进程 GPU 读）不受影响：那里本来没有 GPU 写方，
靠的是"写在读之前发生"，与 semaphore 无关。

## 7. 风险

- **layer 进程里多一个 VkDevice**：游戏进程里同时有 AMD 和 Intel 两个 device，
  驱动稳定性未知。这是本方案最大的未知项。
- **收益可能不如 3 ms**：CPU 写 BAR 的实测带宽要量，不要照抄 1.5 ms 这个估计。
- **daemon 不随游戏退出**（已知坑，见 MEMORY.md）：Phase 2 之后更麻烦——
  新游戏连上旧 daemon，拿到的 handle 属于已经不存在的 buffer。
  换开关前必须：关游戏 → 杀 daemon → 再启动。
- **排序只有 fence + 时序保证，没有跨进程原语兜底**（§6）。真出问题表现为
  **偶发**画质错（某一帧读到了上一帧的字节），不会稳定复现，很难定位。
  接进去之后必须跑够帧数看 `change` / `cut` 有没有毛刺。
