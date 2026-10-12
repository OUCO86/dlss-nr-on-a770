# Phase 2 回程：一次 offer 只属于一个进程

2026-10-12。一个 daemon 服务了两场游戏，第二场**整场没有 NR**（3647 帧全是
"the daemon did not answer"，游戏 16.7 ms / 59.9 fps，和 layer 不存在一样）。
日志里没有任何一行说是为什么。本文把它查清楚，并把两处都修了。

## 1. 现象

```
awk 'NR>=108282 && NR<=116060' work/nr_daemon.log | grep -c "did not answer"
3647
```

同一区间里 layer 一共初始化了 4 次，导入失败 2 次，成功 1 次：

```
108282  the frame's buffers could not be imported (vkAllocateMemory (import))
115700  listening on \\.\pipe\nr_lop      <- 这个 daemon 从头到尾只有这一次
115720  the frame goes straight into the daemon's buffers   <- 第一场，成功
116050  the frame's buffers could not be imported (vkAllocateMemory (import))
```

**两次失败都是"某个 daemon 的第二场游戏"**，第一场都成功。这就是全部线索。

## 2. 真因一：offer 是给一个进程的

handles 是 daemon 用 `DuplicateHandle` 复制进**当时那个游戏进程**的，写进
mapping 的 head（`nr_pipe.FrameMapping.publish_extmem`）。`_extmem_publish`
有 `extmem_published` 标记，**只 offer 一次**。

daemon 比游戏活得久（游戏退出后 python 进程还在，管道还在），于是第二场游戏
打开同一个 mapping，读到的是**第一场游戏进程里的句柄值**：

- 那个值在本进程里要么不存在，要么是别的对象的句柄；
- `vkAllocateMemory` 导入它 → 失败，报 `vkAllocateMemory (import)`；
- layer 退回 mapping 送帧（NR_MAGIC_SHM），本来应当照常工作；

规范原文（`refs/vulkan-sync/memory.html`，第 11 章，逐字）：

> Importing memory object payloads from Windows handles does not transfer
> ownership of the handle to the Vulkan implementation. For handle types defined
> as NT handles, the application must release handle ownership using the
> CloseHandle system call when the handle is no longer needed. For handle types
> defined as NT handles, the imported memory object holds a reference to its payload.

同一页也说导入不接管所有权、payload 可被多次导入——所以**重试是安全的**，
失败的原因不是"被别人占了"，是号码根本不对。

### 为什么不能只看 handle 值

修复要 layer 重试，而"重试"需要判据。handle 值不能当判据：**新进程的句柄表
从低位开始发号**，第二场游戏拿到的号码很可能和第一场一模一样。所以 head 里
加了 **offer 的计数**（version 3，偏移 72），由 daemon 每次 publish 时递增——
只有 daemon 知道它有没有重新 offer 过。

### 还要一个新的 semaphore

timeline semaphore 的计数只能前进（规范逐字，`refs/vulkan-sync/
VkSemaphoreSignalInfo.html`）：

> VUID-VkSemaphoreSignalInfo-value-03258
> value must have a value greater than the current value of the semaphore

新游戏从 1 开始数帧，而上一场已经把计数推到几千。所以每次重新 offer 都要
`export_semaphore()` 一个新的；buffer 则复用（backend 的，按 pixel 上限建一次）。

## 3. 真因二：答案回程不按帧决定

全仓 grep `answer_external`，定义只有一处：

```
src/gpu/nr_frame_resident.py:889:  self.answer_external = not self._answer_owned
```

它是**后端的长期属性**（回程开着就恒为真），不是"这一帧怎么来的"。于是 daemon
对**所有**帧——包括 layer 导入失败、走 mapping 送进来的那些——都回答成
"你的字在我的 buffer 的第 N 字节"，notice 带 `ANSWER_EXTERNAL`。

layer 那一侧 `nrx_answer()` 是 NULL（导入失败），`exchange_receive` 返回 -1，
打印 "the daemon did not answer"。**画面保持原样，一帧一帧，3647 次。**

静默失效比慢严重得多：用户以为 NR 开着。

## 4. 改了什么

| 文件 | 改动 |
|---|---|
| `nr_pipe.py` | `GetNamedPipeClientProcessId`；连接带上 `client_pid`；`clear_extmem()`；`VERSION = 3` + offer 计数 |
| `nr_daemon.py` | `_extmem_publish(args, backend, pid)`：pid 变了就收回旧 offer 再 offer 一次；semaphore 每次新建；`Frame.in_raw` |
| `nr_daemon.py` | `stage_finish` 的 `send_answer`：`at=` 只在 `frame.in_raw` 时给 |
| `nr_transport.h` | `NR_SHM_VERSION 3`、`NR_SHM_OFFERS 72`、`nr_shm_extmem` 多返回一个 offers |
| `nr_layer.c` | `extmem_look` 记住上次试的 offer 与 handle，变了才重试，最多 4 次 |
| `nr_layer.c` | 答案回程读不到时说一句明确的话（只说一次） |
| `nr_extmem.c` | 导入被拒时把 `VkResult` 的数值打出来 |

提交 `4a0437f`。dll 已重建（work/nr_layer.dll 就是 layer-win json 指向的那个）。

## 5. 待验证（要实机）

用户连开两次游戏，**中途不杀 daemon**，看日志：

1. 第二次启动应出现 `a new process is asking for frames (pid N); the frame's
   buffers are offered again`；
2. 第二场也要有 `the frame goes straight into the daemon's buffers`；
3. 不再出现 `did not answer` 刷屏；
4. 万一还是导入失败，现在会打印 `the import was refused: ... VkResult N`，
   并且画面**照常有 NR**（退回 slot），不再是静默失效。
