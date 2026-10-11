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

## 6. 风险

- **layer 进程里多一个 VkDevice**：游戏进程里同时有 AMD 和 Intel 两个 device，
  驱动稳定性未知。这是本方案最大的未知项。
- **收益可能不如 3 ms**：CPU 写 BAR 的实测带宽要量，不要照抄 1.5 ms 这个估计。
- **daemon 不随游戏退出**（已知坑，见 MEMORY.md）：Phase 2 之后更麻烦——
  新游戏连上旧 daemon，拿到的 handle 属于已经不存在的 buffer。
  换开关前必须：关游戏 → 杀 daemon → 再启动。
