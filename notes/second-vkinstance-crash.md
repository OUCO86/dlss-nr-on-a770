# 游戏建第二个 VkInstance 时，layer 被重入

**状态**：修了一个有官方文档支撑的缺陷（per-instance dispatch table），实测成功率
从 2/4 升到 3/4；**剩下的 1/4 根因未定**，游戏进程消失时日志零异常。

---

## 1. 现象

开着 NR 启动 DOOM Eternal，**有概率直接闪退**；关着 NR 启动、进游戏后再开就一定行。
用户 2026-10-12 11:2x 的确切描述：

> 卡过游戏 logo 之后、要加载有 NR 处理的画面那段……因为可以明显感觉到卡顿一下 NR
> 开始处理，能启动时候也有这个过程，只是现在是起不起来，游戏直接闪退。

## 2. 定位：日志里"两次 init 间隔极短"是失败场次独有的形状

`active; socket=` 那组行打在 `vkCreateInstance` 的钩子里（`nr_layer.c`），
所以**每组 = 游戏进程建了一个 VkInstance**。用脚本按行号精确分段后：

| 场次 / 进程 | init 次数 | 两次 init 之间隔了 | 结果 |
|---|---|---|---|
| 场次 32 第一场 | **1** | — | 活（21 窗口） |
| 场次 32 pid 27436 | 2 | 仅 11 行（swapchain×2 + queues + mapping） | **死**，480 帧后 |
| 场次 32 pid 6748 | 2 | 仅 11 行 | **死**，480 帧后 |
| 场次 32 pid 21000 | 2 | 15 个窗口（NR 关闭期） | 活（28 窗口） |

失败的共同形状：**跑了 4 个窗口（480 帧）就死**，帧时间从 48 ms 一路降到 18~37 ms
之间 —— 也就是"加载完成、NR 刚开始稳定工作"的那一刻。

⚠️ **行号必须用脚本精确定位。** 我一开始靠数行，错了，白推了一轮。

## 3. 排除掉的假说（都验证过，别再回头挖）

1. ❌ **"第二个 instance 不渲染，所以崩"** —— 成功的场次（23-31）**也是 2~4 次
   init**，建多个 instance 是常态，不是异常。
2. ❌ **"device 槽位（8 个）耗尽"** —— `nr_DestroyDevice` 会 `memset` 释放槽位，
   而且 `nr_layer.c:1479` 的注释说明前辈已经处理过这个。
3. ❌ **`nrx_open` 建第二个 VkDevice 撞车** —— 它在 480 帧之前就完成了，不是崩点
   （但那个"每帧重建 VkDevice"的 105 ms 老路是另一回事，已修，见
   `phase2-extmem-offers.md`）。

## 4. 修的：per-instance 的 dispatcher，与"只初始化一次"

Khronos `docs/LoaderLayerInterface.md`（v1.4.323）要求 layer **per-instance** 建
dispatch table：

```cpp
layer_init_instance_dispatch_table(*pInstance, my_data->instance_dispatch_table,
                                   fpGetInstanceProcAddr);
```

`my_data` 是 per-instance 的。而我们的 layer 把 `pfnNextGetInstanceProcAddr` 存成了
**一个全局指针**：

```c
next_instance_proc = link->u.pLayerInfo->pfnNextGetInstanceProcAddr;  // 全局
layer_instance = *instance;                                           // 全局
```

第二个 instance 一来就覆盖，游戏还在用 instance 1 画，layer 却拿 instance 2 的指针
去回答 instance 1 的问题。

更糟的是每次 `vkCreateInstance` 都**重跑一遍初始化**：重读所有开关、重算
`async_depth`、再 `ensure_daemon()`、把 `layer_instance` 从正在跑的帧底下抽走。
这四件事在帧跑到一半时做，没有一件是安全的。

**改法**（`nr_layer.c`）：

- `instance_next[8]` 表 + `next_for(instance)` 按 instance 查表；第一个的留作兜底
  —— physical-device 查询本来就不属于任何 instance，用谁都能答对。
- **第二个及以后的 instance 只记下 dispatcher、跳过初始化**。它的 device 仍由
  `nr_CreateDevice` 跟踪，不受影响。
- 日志打一行 `the game made a second instance; the layer stays with the first,
  which is the one that draws`，只打一次（`second_instance_said`）。

## 5. 实测（场次 33，行 140768-144206，2026-10-12 11:4x）

用户连开 4 次游戏，**全部开着 NR 启动**（这次不再"关了开"）。

### 修复生效

`the game made a second instance ...` 打了 **4 次**（行 140781 / 141621 / 141918 /
143358），每次后面都跟 `the frame goes straight into the daemon's buffers`
→ **导入 4/4 成功**。全段 `could not be imported` **0 次**、`did not answer` **0 次**、Traceback **0 次**，daemon 处理 3328 帧。

### 成功率

以 `active; socket=` 一次 = 一次游戏启动来分段：

| | 尝试数 | 活的 | 成功率 |
|---|---|---|---|
| 场次 32（修复前） | 4 | 段1（21 窗口）、段6+7（28 窗口） | **2/4** |
| 场次 33（修复后） | 4 | 段2（23 窗口）、段3（13 窗口）、段4 | **3/4** |

样本只有 4 次，统计上不显著，但方向与用户体感一致（"成功概率增加很多"）。

失败的那次是**第二次**（pid 29700，行 141614-141911）：4 个窗口 = 480 帧，
帧时间 `48.0 → 46.8 → 17.7 → 36.9` ms，然后进程消失。

### 性能没有代价

| 段 | 窗口 | 帧时间中位 | fps 中位 |
|---|---|---|---|
| 段2（23 窗口） | 2760 帧 | **28.9 ms** | **34.6 fps** |
| 段3（13 窗口） | 1560 帧 | **28.9 ms** | **34.6 fps** |

与既有的 30 ms / 33 fps 基线一致。段2 的稳态：
`27.9 27.9 28.8 28.7 28.9 29.5 29.5 29.7 29.1 28.7 28.7 28.7 28.3 29.4 29.3 30.0 27.5 29.0 29.0`。

## 6. 剩下 1/4 的根因：未定，且拿不到崩溃模块

失败时**日志零异常**：`could not be imported` 0、`did not answer` 0、Traceback 0，
daemon 侧也没有 error 行。layer 和 daemon 都没来得及记录任何东西。

也查了 Windows 应用程序日志：近 3 小时只有 11 条错误，全是 `.NET Runtime` /
`BD.WTTS.Services`（WorkBuddy 自己的服务噪音）；近 24 小时的 ID 1000/1001/1002
有 970 条，同样全是它。**没有一条 Application Error。**

→ 游戏进程是"消失"而不是"抛未处理异常"，这条路拿不到崩溃模块名。

### 一个对不上的疑点（别再靠推理，要加日志）

失败那局之后紧接着的一次（行 141912）**没打 NEWPROC 却打了完整 INIT**。

按代码两条路都说不通：

- 若是**同一个进程**的第二个 instance —— `layer_instance` 是全局，全文只有
  `nr_layer.c:1320` 一处赋值，而且**没有 `vkDestroyInstance` 钩子**去清它，
  所以第二个 instance 必然走"跳过初始化"分支，**不该打 INIT**；
- 若是**新进程** —— pid 必变，daemon 侧 `_extmem_publish` 的 pid 判重就会触发，
  **该打 NEWPROC**。

要定论只能加日志：layer 打"本进程 pid + 第几个 instance"，daemon 打连接 pid。
现在两边都没有 pid 的直接记录可比 —— daemon 的 pid 来自
`GetNamedPipeClientProcessId`（`nr_pipe.py:223`），日志里只在新进程时才打印。

## 7. 顺带修正的一条测量口径

`p25 < 8 ms 就丢弃` 这条铁律一直被归因于 **alt-tab 失焦**。**这个归因是错的。**

把场次 33 全部 53 个窗口的 p25 按每局排开，规律一目了然：

```
第1次  3.8  4.0  4.0  4.5  5.1 │ 8.2  9.3  8.7  8.7  8.8  8.8  8.7  8.7
第2次  3.7  3.8  3.8  4.0        │ （死了，没有后半段）
第3次  3.6  3.8  3.9  4.2  5.0  7.1 │ 9.6  9.3  8.5  8.5  8.5  8.5  8.6  8.6  8.5  8.6  8.5  8.7  9.1  9.2  9.0  9.0  8.9
第4次  4.0  4.2  4.1  4.2        │ 10.1  14.0  10.3  11.1  9.1  9.1  9.1  9.0  9.1
```

**p25 < 8 的是每局游戏的开头 4~6 个窗口，不是失焦窗口。** 那是加载 / 启动阶段，
present 还不受 vsync 约束，帧间隔能短到 3.6 ms。游戏一进稳态，p25 就稳定在
8.5~9.1。场次 32 的 12 个低 p25 窗口也是同一个形状（每局开头）。

所以那条铁律**仍然可用**（它剔除的正是启动阶段，那段帧率不代表稳态），
但**理由要换**：不是"窗口失焦了"，是"游戏还在加载"。

### 一个副产品：失败那局的特征

**第 2 次的 4 个窗口 p25 全是 3.7~4.0 —— 它整局都停在启动阶段，从没进入稳态。**

对照它那 4 个窗口的帧时间 `48.0 → 46.8 → 17.7 → 36.9`：一直在降，从没稳住。
而活下来的三局都是"前几个窗口 p25 低 → 之后升到 8.5+ 并稳住"。

→ 这给了失败一个**可观测的判据**，比"日志里什么都没有"强：
**p25 一直停在 4 附近不升上去的那一局，就是要死的那一局。**

⚠️ 这仍然只是相关性，不是因果。4 次样本里 1 次失败，不足以断言。

