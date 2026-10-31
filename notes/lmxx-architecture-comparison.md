# lmxx/前辈 coopmat vs 我们：完整架构对比（2026-10-31 14:2x，全部数字有据）

## 对比表
| 引擎 | GPU | 分辨率 | 实测 | 形态 |
|---|---|---|---|---|
| lmxx v0.3.0 3080 分支 | RTX3080Lap 700GB/s+TC | 720p 0.92Mpx | 5.62ms | NVIDIA 原版 megakernel SASS 的 PTX 指令级补丁（六刀全是微观：PRMT/HMNMX2/mapped 零拷贝/K16 原位拆/C32 168cap/mbarrier）。**非架构重写**。 |
| lmxx RDNA4 姊妹 | 9070XT **2.3TB/s** | 720p | 2.99ms | 同架构从零重做 |
| **前辈 coopmat A770（真参照）** | **A770 0.56TB/s** | **960x544 0.52Mpx** | **49ms**（游戏 work= 实测，§99） | 82 launch，每层 resident，层内中间量 LDS 交接 |
| 我们 B1（今天） | A770 | 960x544 | 66.5 walk（游戏 work≈84 含游戏自身负载） | ~700 节点 cgraph，核间 DRAM scratch |

## 更正（14:3x，用户点破后查证官方规格——之前的带宽归一是错的，撤回）
- Intel ARK / NVIDIA 官方：A770 16GB = **560 GB/s + 262 Int8 TOPS(XMX)**；
  RTX 3080 Laptop = 448 GB/s + ~238 TOPS(TC)。**A770 两项都不输甚至更优。**
  硬件没有任何借口。5.6ms vs 66.5ms 的差 100% 是架构成熟度差。
- 3080 上跑的是 NVIDIA 官方 DLSS5 架构（38 megakernel、核内 LDS 交接、激活不落
  显存——NVIDIA 按 3060 级 5-8ms 设计），lmxx 社区只补了指令。这套架构搬到
  A770（带宽更高+XMX int8 同级+16GB 显存）只会更快。
- 战略修正：全 resident megakernel 不是 "out of scope 的季度工程"，是主线终点；
  每层 resident（B6-2/B7）是它的逐层砖。流量下界账：全 resident 后每帧 DRAM
  ≈权重 ~1GB=1.8ms@560GB/s；bench_laws 实测在途能力 592-734GB/s 贴标称。
  10-15ms 是算术结果。50ms = B6-2 出口，不是墙。
- NVIDIA 的 DLSS5 网络本来就是按 3060 级 5ms 设计的（38 个 megakernel，每核内部 LDS/寄存器交接，中间量不落显存）。lmxx 是移植者不是架构师。
- 同 GPU 真参照 = 前辈 coopmat 49ms。差距 66.5/49 = **1.36x**，来源三条已量化：
  1. 接口税：A770 Vulkan-coopmat 封顶 24.8（§285 已证）；我们 ESIMD 40-59 TOPS 上限更高——输形态不输指令。
  2. 流量：我们 60.3GB/帧（1267=26.7GB 等），写+一读 38GB≈68ms=贴 DRAM 屋顶（§6.22）。前辈层内 resident 只流 ~25-30GB。
  3. gemm 形态：帧上窄 K 1.5-2.5 TOPS vs 前辈宽 M 8-30（§2433）。deep-K 30.9 TOPS 我们已实测可达（§537）= 形状问题非核问题。

## 路线图（每档的账）
- 刀尾（本周）：s8v8 三兄弟 tile 变体（串行 56.4ms；先 bench_batched 定价：BN128/BK64/累加器减半形）+ wa 供数审计 → 60-62。
- B6-2 层 resident（主刀）：residual-gemm+quant_window+ffn 一核（1267 省 18.6GB/帧读）→ ~49-52。= 前辈 82-launch 逐层复刻；v4full resident 骨架已在帧上跑（50 块全走）。
- B7 全布局原生：scratch 面 dtype/布局原生化 + gemm 宽形态（30.9 TOPS 已证）→ ~30-35。
- 全 resident megakernel（NVIDIA 38 核形态）：权重 1GB/帧=1.8ms 带宽下界，激活不出片上 → **10-15ms 物理可行**，代价=引擎重写（前辈 coopmat 同量级季度工程；他们停 49 = 半 resident 的封顶）。

## 判决性提醒
- 帧在路径上的账（腿账 v4）：ffn -9.5 / quant -5.8 / unary -5.0 / wa -6.2；gemm 三兄弟串行 64.7 但删除收益≈0（被 overlap 隐藏）——刀要砍在路径上，tile 变体的价值在腾出 SM 时间给 resident 化后的关键路径。
- 1267 f32→f16 不合法：它是残差累加面，golden=前辈 coopmat 引擎本身（walk 判官），多一次舍入必红（P3c 教训）。减它只能靠 resident（不落 DRAM），不能换 dtype。
