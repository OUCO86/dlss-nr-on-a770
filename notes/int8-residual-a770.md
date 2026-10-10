# 把残差折进 int8 的 GEMM：一次失败，和它逼出来的答案

一帧里 int8 的投影曾经是三趟：量化、GEMM，然后一趟自己的残差——把 float32 的
branch 写出来、再读回来、加上 `skip * cosine`、发布、再写出去。**120 趟，2.39 ms**，
占了设备 36.4 ms 的 6.5%，而且是浮点路径从来不用付的一趟。

浮点路径不用付，是因为它的 GEMM 有残差 epilogue。`gemm_staged_int8.comp` 没有。
所以这件事看起来很直白：给它也加一个。

## 第一次尝试：直接加进去 —— 净亏 16 ms

第一版做完了，而且**数值是对的**：`src/gpu/test_gemm_int8_residual.py`
242 例逐字节一致（含窗口反排、原地写回、五种 epilogue、两种 skip 宽度）。
帧里那 120 趟也确实消失了。

但整帧数字是这样的（同进程、交替、同一份权重）：

| | 设备 | 趟数 |
|---|---|---|
| 改之前（原始 spv） | 36.42 ms | 723 |
| 改之后（残差编译进同一个 spv） | **52.27 ms** | 603 |

按 family 拆开看，问题不在残差：

```
unary/5   残差    2.39 -> 0.00   （省了 2.39，符合预期）
gemm/30   int8    8.43 -> 26.13  （+17.7）
```

**所有 188 个 int8 乘积都变慢了三倍**，包括那些没有残差可加、0x20000 位根本没置的趟。
它们一条新增指令都没执行，只是待在同一个内核里。

### 为什么

`docs/a770-port/code-map.md` §2.3 的运行时旋钮表里记着 `XMX_PIPELINE_STATS`，
"导出编译器自己的寄存器/SIMD 报告"。问驱动要来的答案：

| 构建 | Instruction Count | **Scratch Memory Size** |
|---|---|---|
| 原始 int8 | 7637 | **0** |
| 我的 plain 重建 | 7629 | **0** |
| 带残差 epilogue | 3209 | **20992** |

GRF 是每线程 128 个寄存器（`references/hardware/hardware.md`），
**一个 8×8 的 int32 累加器是 256 字节 = 8 GRF**。这个内核每个 lane 挂
RM × RN = 2 × 4 = 8 个累加器，**64 GRF 光在累加器上**，还有操作数、寻址、epilogue
要放，共享内存也吃掉了 8 KB。再加一点点东西，驱动就把累加器溢出到显存；
而一旦每个线程槽要占 20992 字节 scratch，能同时驻留的线程数就塌了，
于是三倍。

参考 skill **A770-Kernel-Optimization**（Blackwood416，同款 A770）里那句更狠：

> On A770 ... any non-zero compiler spill with RPT>4 is a device-lost trigger.

即溢出在这张卡上不只是慢，是风险的标志。

## 第二次尝试：砍一半累加器 —— 溢出归零

`gemm_staged.comp`（浮点）早就留了这个旋钮：`-DSTAGED_BM=32 → gemm_staged32.spv`。
int8 内核把 `BM` 写成常量，先改成 `#ifndef STAGED_BM`，然后：

```
-DINT8_RESIDUAL=1              Scratch 20992
-DINT8_RESIDUAL=1 -DSTAGED_BM=32   Scratch 0   Workgroup Memory 5120
```

32 行 → WM = 8 → RM = 1 → 累加器从 8 个减到 4 个，空出 32 GRF，溢出消失。

代价是块从 64×32 变成 32×32，grid 变成 M/32，SLM 装载索引也要分流
（64 行是每线程 2 个 word、2 线程一行；32 行是 1 个 word、4 线程一行）。
所以它是**一条独立的流水线**，不是一个 flag：`work/gemm_staged_int8_residual.spv`，
由 `xmx_int8_residual_init` 建，`XMX_STAGED_BM_RESIDUAL = 32`。

## 结果

同进程交替、5 轮、订单每轮反转：

```
                  device     wall    passes
  fused           34.50     37.22     603
  two-pass        36.38     39.55     723
  saved            1.88 ms   (+5.2 % of the device's own time), 120 passes
  spread within a side 0.05 ms
```

按 family：

```
  unary/5   残差    2.39 -> 0.00
  gemm/30   int8    8.41 -> 9.00    (+0.59，epilogue 的真实成本)
  tiled             8.48 -> 8.41
  其余全部不动
```

省下 2.39，付掉 0.59，净 **1.88 ms**。单侧波动 0.05 ms。

## 两件必须记下来的事

**默认构建必须逐字节不变。** 我加 `#ifdef` 时顺手把存储下标外提成了
`at = r * pc.n + c`，spv 从 33444 变成 33408，two-pass 基准也从 36.42 漂到 36.66。
已改回按 `#ifdef` 分流，现在 `work/gemm_staged_int8.spv` 与改动前
**逐字节相同**（`cmp` 通过），基准回到 36.38。

**测试抓到一个真 bug。** 我一度把存储下标统一写成 `(r * pc.n + c)`，
但残差路径下 `at` 是被 `residual_output_index` **重映射过的图像索引**，
窗口块的反排就没了 —— 242 例立刻红。所以两个构建的存储下标必须各写各的。

## 真实游戏里：daemon 的 GPU 时间 40 → 38 ms

第一次在实机里看这一项，走的不是设计好的路径（热切换没生效，见下），但结果反而更干净。

`work/nr_daemon.log` 是 append-only 且没有时间戳，每次daemon 重启是天然的分界线。按
`listening on` 切成 7 段≥200 帧的游戏会话（`tools/log_gpu_hist.py`）：

```
gpu ms      38    39    40    41    42    43    44    45    46
run 1        0     0  1431   167     8     0     1     2     0
run 2        0     0  8619   807    13     2     2     4     1
run 3        0     0  1224    47     1     0     0     0     0
run 4        0     0 12510  3232    63    21    19    13     1
run 5        0     0  6726  1633    25     3    17     5     2
run 6        0     0  8929  2448    61    12    76    13     1
run 7     2821   519    56     5    24     5     1     0     0
```

前 6 段（**48139 帧**，改动前的构建）中位数**一律 40.0**，均值 40.20，散布 40–46。
第 7 段（改动后的这一次，**3431 帧**）中位数 **38.0**，均值 38.23，**82% 的帧正好 38**。

**−2.0 ms**，离线 A/B 预测的是 **−1.88 ms**。

这里为什么可以用跨场次对比——平时是不行的（同一份构建两场能差 6 ms）。因为差的是
**帧时间**（含游戏宿主侧），而这个 `gpu` 数是 daemon 自己的 GPU 段：48139 帧里它的
中位数六次都是整 40 ms，自身漂移远小于 1 ms。**这个量可以被跨场次比，`gpu` 比在这个
意义上比帧时间可靠。**（注意它仍然是墙钟，对 4.37 ms 的 fuse 改动当年毫无反应——
那次对应的是 43.3 两边一样。所以它不是万能的，只是这次凑巧效应落在它能看见的地方。）

⚠️ 仍然**不是局内 A/B**。真正闭局还得靠下面那一节。

## 热切换那次为什么"看起来没生效"

用户在游戏里双击了 `nr_residual_on/off.bat`，弹窗正常，JSON 也确实改了
（`int8_residual` 最后停在 `0`，文件时间 13:31:32），但日志里**一行
`settings: integer residual` 都没有**。

原因：`nr_settings.json` **只在有帧到达时才被读**（`Settings.refresh()` 是每帧调的）。
日志最后一行的 daemon 启动之后**一帧都没有**——说明那时候画面已经不在出帧了
（游戏关了，或者停在菜单/读盘）。文件写了，没人读。

两个改动，防止再发生：
- daemon 第一帧起打印 **`settings in effect: int8=1 int8_window_fuse=1 int8_residual=1`**
  这样一行。以后任何一段日志都能自证它跑的是哪张图，不用猜。
- 开关不再是一行 `json.dump`：改成 `tools/nr_switch.py`，写完盯着日志几秒，
  没被接住就**明确说是哪一种失败**——「这段时间内没有帧到达 daemon」还是
  「有帧但 daemon 不认这个名字（旧进程占着管道）」。后者才需要关游戏清 daemon。

⚠️ 中间我自己写错过一次：诊断去数日志末尾 400 行里的帧数。那是**上一场会话的旧帧**，
永远不会消失，于是游戏关了三小时它还会说"frames are flowing"。改成只数**新读到的**字节。
工具自己犯错会把人往错的地方带，比没有工具更糟。

## 怎么复现

```
python src/bench/int8_residual_ab.py 5          # 整帧，同进程交替
python src/gpu/test_gemm_int8_residual.py       # 242 例逐字节
XMX_PIPELINE_STATS=<file> python -c "..."       # 驱动自己的寄存器账
python tools/log_sessions.py                    # 日志按场次分段的 us summary
python tools/log_gpu_hist.py                    # 每场 gpu 时间的分布直方图
```
