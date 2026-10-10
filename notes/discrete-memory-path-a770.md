# A770 的独显内存路径：本来就是对的（2026-10-11）

`docs/a770-port/code-map.md` §5 的 P3 写着「独显内存路径 —— A770 是独显，这条必做」。
这条笔记是那条建议的实测结果：**在这台机器上它已经成立，没有可捡的时间。**
结论是量出来的，不是读代码推出来的。

## 怎么量的

代码里本来就埋好了报告（`libxmx.c` 的 `note_memory()` / `xmx_memory()`），
Python 侧也有现成的两个函数，不需要新写任何东西：

```python
import sys
sys.path.insert(0, "src/gpu")
import xmx
print(xmx.device_name())
print(xmx.memory_note())
```

## 量到什么

```
libxmx: device 1/2 Intel(R) Arc(TM) A770 Graphics (vendor 0x8086, device 0x56a0) [Intel vendor match]
device : Intel(R) Arc(TM) A770 Graphics
memory : card memory: type 3, heap 15.9 GiB, DEVICE_LOCAL HOST_VISIBLE HOST_COHERENT
       ; readback cached: type 2, heap 40.0 GiB, HOST_VISIBLE HOST_COHERENT HOST_CACHED
```

## 怎么读

**选卡是对的。** `device 1/2`，走的是 `gpu_pick.h` 的 Intel vendor 匹配这一支。
枚举顺序里 0 号是 AMD RX 9070 XT，全仓库唯一会选错的地方就是这里，现在没选错。

**图的缓冲落在显存，而且主机看得见。** kind 0（GRAPH）拿到 type 3：
`DEVICE_LOCAL + HOST_VISIBLE + HOST_COHERENT`，堆 **15.9 GiB**，就是 A770 自己的显存。
`want_unmapped()` 返回 0 的判据在 `libxmx.c` 的 `HOST_VISIBLE_VRAM_FLOOR`（1 GiB）：
**整机显存都对主机可见，也就是 resizable BAR 是开着的。**

**回读缓冲落在系统内存，是设计如此。** kind 1（HOST_READ，`head`）拿到 type 2：
`HOST_CACHED`，堆 40 GiB。`head` 是「每 16 个 float 取 4 个」的跨步读，
`memtype()` 的注释说得很清楚：缓存命中比「在显存里但 uncached」划算，
哪怕缓存的这块内存在总线另一侧。

## 结论

- **没有撞上 phase63 那个坑。** 那份笔记里 Arc B580 慢 50 倍，是因为每个缓冲都要
  host-cached，在独显上那就是系统内存、每次访问横穿 PCIe。这里没有：
  图的缓冲在显存里，而且是 mapped，主机直接写进去。
- **`XMX_STAGING=1` 不要开。** 那条路径（device-local 且 unmapped，靠显式拷贝进出）
  是给**没有** resizable BAR 的机器准备的；phase65 说它是「在没有问题的硬件上证明
  问题不存在」的用法。这台机器有 BAR，开了只是白白多两次拷贝。
- **所以 P2 结案：这里没有白捡的时间。** 设备侧那 38 ms 是算力，不是等 PCIe。

剩下真正在总线上的流量是结构性的，phase63 已经列过：
特征每帧写一次（输入的必经之路）；权重在 **extent 变化**时重传一次（约 292 MB，
权重跟 extent 无关，所以理论可省，但要把所有权从 `ResidentFrame` 里拆出来，是一次重构）。

## 复现条件

不需要游戏，不需要权重，单独一个 Python 进程即可（会开一个 Vulkan 上下文）。
