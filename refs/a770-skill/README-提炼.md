# A770-Kernel-Optimization skill 包 · 本地提炼（2026-10-16 抓自 GitHub）

来源：https://github.com/Blackwood416/A770-Kernel-Optimization （作者同款 A770 16G，
oneAPI 2026.1，驱动 32.0.101.8724/8860）。原文已存 refs/a770-skill/。

## 决定重写路线的硬数字（全部 [MEASURED]）

1. **XMX 引擎的真实上限不是 coopmat 的 24.8**——那是 Vulkan coopmat→DPAS 的 codegen 税。
   官方库 oneDNN 走 ngen/DPAS 到大形状 **71.9 TOPS int8**（=营销峰值 262 的 27%，120W 下）。
2. **手写 ESIMD DPAS 核能到 oneDNN 的 90%**（ladder 第 18 步 0.0613ms vs oneDNN 0.0552ms，
   bf16 1024×1536×512）。"手写核 ≥ oneDNN 80%"这个门槛**前辈已替你验证过**。
   剩余 1.11× 是 ngen 级 DPASW/SWSB 调度，SYCL/ESIMD 表达不了。
3. **甜点位（照抄起步）**：per-thread C tile 16x16、BK=32、VNNI 打包 B（host 侧）、
   A 也 host 打包直读、4-buffer B SLM 流水线、每 2K 一个 barrier、N-first walk。
   SLM >32KB 开始掉 resident workgroup。GRF 128（A770 无 large GRF）。
4. **oneDNN 在帧的碎形状上只有 2.4-15.6 TOPS**（0/14 形状赢过我们 coopmat）；它只在
   帧里不存在的巨型形状(8192×1024×1024)才 71.9。**要 75%，必须把网络重排成大 GEMM。**

## 对"75% 硬件算力"目标的诚实校准（必须先钉死分母）

- 262 TOPS 是 **225W 参考卡满频**营销值；本机 **120W**，XMX 实际频率峰值更低。
- 目前**没有任何已知路径到过 262 的 75%（=196）**——Intel 官方库自己只到 27%。
- 真正该先测的是 **XMX 阵列的裸 DPAS 发射上限**（不含数据搬运）：
  若它 ≈90-100 TOPS（120W 真实峰值），那 oneDNN 71.9 已是 72-80%，"75%"基本已达成，
  重写要做的是把碎形状喂进引擎；若它 ≈200+，oneDNN 只用了 36%，还有大空间。
  **这个数决定整个目标的定义，且必须用 ESIMD 测（coopmat 有接口税）。**

## 手写 vs 直通 oneDNN 的评估结论（用户判据：接缝形态 + 打包税）

- **直通缺陷**：oneDNN 只会 GEMM，不能改算法。帧的链路是 GEMM-变换-GEMM-变换，
  变换（gate/行-max量化/softmax/归一化）是它表达不了的半边。每层输出 s32→独立核
  读回变换→requantize→喂下一层。这个"重新打包税"=账本 quantize 3.09ms+publish
  往返~2ms≈**5ms（帧 11%）**，走 oneDNN 一分省不掉。手写核把变换折进累加器出栈，
  中间形态不落显存。
- **更硬的障碍**：oneDNN 是 JIT 不透明核，每次调用要 host dispatch（eager 税
  +0.2-0.5ms/次 × 300 GEMM = 60-150ms wall），装不进"一次 submit 跑完"的静态计划表。
- **判定**：手写为主（腿 A）——形态双向控制省 5ms + 静态表只有自研核进得去 +
  ladder 已证 90%。直通作退路（腿 B）仅当某巨型形状手写够不到时局部借用，且
  输出布局契约定死为"行主序 s8 + 独立 scale 数组"（=oneDNN 理想输入，插拔零重打包）。

## 起步缺口

- **icx/SYCL 编译器已被前辈清掉**（toolchain/oneapi/compiler 只剩 runtime dll）。
  腿 A 第一个实验（XMX 裸发射上限）必须重装 DPC++ 编译器（~1-2GB，conda dpcpp_win-64
  或 oneAPI 离线包）。这是重活，需用户知情后再装。
