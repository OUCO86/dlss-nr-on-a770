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

## 6. ⚠ 跨进程 semaphore 在这张卡上不排序（2026-10-11 实测）

设计里「帧开始靠 layer 给 daemon 的 semaphore」**不成立**。证据在
`src/bench/check_extmem_sem.py`（`extmem_xproc.exe semhost <pid>` 提供延迟 signal）。

| 阶段 | 谁等谁 | 结果 |
|---|---|---|
| 1. 同进程 | 一个 submit 等一个还没人 signal 的 semaphore | **1201 ms**（signal 在 1200 ms 之后才发）→ wait 是真的 |
| 2. 跨进程 | 同一个 driver，semaphore 由另一进程 `DuplicateHandle` 过来 | **0.4 ms**，第二次 **0.2 ms** → 一次都没拦住 |

排除掉的几种解释：

- **不是参数没传进去**：`XMX_EXTMEM_TRACE=1` 会打印
  `libxmx: submit <cb> waits on semaphore <sem>`，两行都打了，
  `xmx_extmem_wait_pending` 也从 True 变 False。wait 确实进了 `vkQueueSubmit`。
- **不是"导入时已经是 signaled"**：那种情况第一次会放过去、第二次应该拦住。
  两次都放行，所以是**每一次 wait 都失效**。
- **不是导入写法的问题**：创建后 `vkImportSemaphoreWin32HandleKHR` 和创建时
  `pNext = VkImportSemaphoreWin32HandleInfoKHR` 都试过，一样。
- **不是跨进程共享本身有问题**：buffer 那一路（`check_extmem_export.py`）是好的，
  0/1048576 错。坏的只有 semaphore 的 wait。

另外：`vkWaitSemaphores` 查导入 semaphore 的状态会**让驱动崩**（读 0 地址，
整个 Python 进程就没了）。所以连"它现在是什么状态"都问不出来。这个函数已经删掉。

### 这条发现的连带影响：probe §15 那几项要打折

`host-passes-to-gpu.md` §15 的第 4/6/7 项用的正是这条路径（父导出 semaphore、
子导入并 wait）。wait 既然可能是空转的，那几个 **0 错就不能当成"同步有效"的证据**——
它们只说明**数据能共享**，排序是时间上凑巧（1 MB、GPU 很快）。

第 8/9 项（父 CPU 写 BAR → 子 GPU 读）不受这条影响：那两趟本来就没有 GPU 写方，
写是 CPU 做的，靠的是"写在读之前发生"。**共享与可见性仍然成立，只有排序没保证。**

### 替代方案：排序改用 layer 自己的 fence

既然跨进程的 wait 靠不住，而 layer 反正要在 A770 上建一个 VkDevice（要 `vkMapMemory`
才能读 answer），就让它自己收尾：

| 时刻 | 谁 | 做什么 |
|---|---|---|
| 帧开始 | layer | CPU 写 raw（BAR）→ **自己的 queue 提交一个空 batch** → 等**自己的 fence** → 再发管道通知 |
|  | daemon | 收到通知就跑，不 wait 任何东西 |
| 帧结束 | daemon | GPU 写 answer（VRAM），最后一次 submit 的 fence 照旧等 |
|  | layer | 收到管道 notice 后直接 CPU 读 BAR |

- `vkQueueSubmit` 之前完成的 host 写，对该 submit 可见（规范 host write ordering），
  空 batch 的 fence 等到手，写就一定到了 VRAM。
- **daemon 侧零改动**，不需要 `xmx_sem_import` / `xmx_extmem_wait`（已加，但别用）。
- 代价：layer 每帧多一次空 submit + fence wait，量级 0.1–0.3 ms，**待实测**。
- 残留风险：daemon 的 GPU 读会不会命中陈旧的 L2。probe §15 第 8/9 项给了旁证——
  同一块 BAR 被 CPU 写过两轮不同的值（0x0F、0xF0），子的 GPU 两次都读到新值，
  没有读到上一轮的陈值。但那不是专门的 cache 测试，接进去之后要看画质。

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
