# lmxx 3080/9070XT 分支的 71 层完整模型架构 vs 前辈 47ms vs 我们：10ms 路径（14:5x 重写，前版 31-block 误读已废）

## 0. 勘误链（本轮对话内两次被用户点破，记录防再犯）
- 撤"带宽归一"：A770=560GB/s+262 TOPS ≥ 3080L=448+238（官方规格）。零硬件借口。
- 撤"31 块=31 megakernel"：31 块/15 fatbin 是 Preset 2 的 0.5x Small **降画质新模型**
  （只快 ~30%，用户明确：那个好适配、之后再弄）。**我们跑的是 71 层完整 NR 模型**
  （=前辈 coopmat 47ms 同款）。本章全部数字取自 lmxx 姊妹项目 **hip-port（RX 9070XT
  上 71 层完整模型的从零重做）**的 CHANGELOG——这才是 71 层模型的架构账。

## 1. lmxx 71 层完整模型的真实架构账（hip-port CHANGELOG，逐条实测）

**基线轨迹（9070XT，网络离线 1000 帧稳态）**：
- 0.01：71 块全部 wave-matrix 核、逐块 split、186ms（bit-identical）
- 0.03：硬件 f16/E4M3 转换 + **fused QKV+norm** → 62.7ms
- 0.30：**wave-owned 核**（C32 全十块/C64 融合窗）−6%
- 0.36 第8项：**上采样折进下一层首块**（C64/C128/C32），−0.17/−0.25ms，launches −3
- 0.37：**C256 persistent stage**（每 stage 内 6 层走**设备 ready-queue**，超时自动回退串行）launches 197→179；**ViT QKV 五 wave LDS 共权重**（8KB 双缓冲，读÷5）48.8→37.0µs；C512 head-pool+proj 合一 launch；**逐核 roofline 对照表**（"our 169 vs **reference 154 launches**"——他们对标的参照系是 154 发！）
- 0.38：**900 档 7.6ms / 1080 档 10.4ms，launches 162/158**；composite quantization（FP8 往返=整数位掩码，全 2^32 输入证明）；三处宽 store 重写。
- 未采纳（负结果，同样有价值）：C128/C64 persistent（<0.5%）、C512 proj 共权重（bit-exact 但更慢）、MAKE_RESIDENT spike（离线复现不了）。

**71 层模型每帧 launch 数：~160（不是 31！）**。他们到 7.6ms@900p 靠的不是把 71 块合成 31 发，而是：
1. **块内融合到底**：QKV+norm、attention+proj+residual、upsample+下块首层——中间量 LDS/寄存器穿阶段；
2. **persistent ready-queue**：一个 stage 的多层在设备内排队跑（launch 边界消失）；
3. **wave-owned**：一个 wave 拥有一层的全部阶段；
4. **权重共享**（W5：5 wave LDS 共权重双缓冲）；
5. **逐核 roofline 审计**：每个核对着 per-kernel map 找离带宽/算力屋顶的差距，逐个削；
6. **数字级微观**（FP8 往返=位掩码、宽 store、recip+FMA）——每刀 0.005-0.07ms 但全收。

## 2. 前辈 coopmat 47ms 的真实位置（超越对象，不是老师）

前辈=同 71 层模型、同 A770、半融合（window_block 三合一、ffn_fused 三合一、
fused gemm 读侧 quant）+ resident 缓冲，**47.19 实测贴 1267 残差 ping-pong 屋顶**。
§227 案卷：他们想做更深的 B1a megakernel，**Vulkan coopmat 32KB SLM 死限作废**。
他们的残差往返数（census 400 次）比 lmxx 的形态（融合后 ~2×71=142 次量级）多 ~2.8 倍
——**这就是 47→~20 的空间，前辈被工具链卡住没走到的那步**。

## 3. 我们到 10ms 级的修正账（960×544，golden f32 残差）

融合到 lmxx 深度后的每帧 DRAM 硬流量：
- 残差 1267：71 块链 × 写1+读1 × 66.8MB ≈ **9.5GB**（现 26.7GB，降 2.8 倍）
- 权重 ~1.0GB（LMXX 教训：W5 五 wave 共享后权重读 ÷5）
- 图 I/O + history ≈ 0.5GB
- **总 ~11GB @ 560GB/s = 19.6ms 流量下界**；再往下：残差面在层内 resident（写读合一）
  → 残差往返 142→71 次 ≈ 4.8GB → **下界 ~10.5ms**。
- 算力账：XMX 262 TOPS、模型 ~40-50 GOPs/帧 = 0.2ms——计算完全藏在流量里。
**结论：10-12ms = lmxx 同等融合深度在 A770 上的物理地板；9070XT 在 3.7 倍分辨率上
才 7.6ms，我们在 0.52Mpx 到 10ms 完全成比例。之前"31 发 megakernel"的说法作废，
正确目标形态 = ~160 发 + 块内全融合 + persistent stage。**

## 4. 开工序（照 lmxx 的演化路径补我们的缺课，按性价比排）

lmxx 从 186→7.6ms 的每一步都有我们的对应物。我们已做的：b3-1/PAF/ffn 系宽 store
（=他们第 4 类）、chip/v4full 阶段融合（=他们 0.03 类）。**我们缺的四大件**：

1. **S2a 读侧 quant 折进 gemm**（前辈 fused 设计 + 我们的 QFALIAS wire + 他们的
   scale-pregive 教训）：residual x120→quant_window x104 相邻对已验证。-12ms 预期。
   **本周主刀。**
2. **S2b 上采样/小 op 折进邻块**（他们 0.36#8 的复刻）：unary 腿 -5.0、wa 供数 -4.4
   都是这条路（"ViT/downsample 候选实测无增益不折"——连哪些不该折他们都有账）。
3. **S3 persistent ready-queue stage**（他们 0.37#3：C256 六层设备内排队，
   launches 197→179）：我们的 cgraph 就是现成的"queue"——把同层相邻 9-op 周期录成
   一个子图节点串（B6-1 的教训=五件套形态，改按他们 stage=6 层的粒度）。
4. **S4 wave-owned + W5 权重共享**：s8v8 三兄弟的 SLM 放大 5.3x（§6.22 旧账）
   = W5 直接对症（5 wave LDS 共权重双缓冲）——他们实测读÷5、48.8→37µs。
5. **逐核 roofline 审计文化**：他们的 kernel-map（169 vs 154）打法=我们已有的
   RUN_TIMING 表制度化——每表行配一个 bench 单核价，离屋顶 >2 倍的排队修。

## 5. 教训记录
- 两次被用户点破（带宽借口、31-block 误读）根因相同：**没读全参照系就下结论**。
  lmxx 主仓库 README 的 5.62ms 是 Small 模型；71 层完整模型的架构在 hip-port
  姊妹线（9070XT 从零重做，bit-exact 对照）。以后引用任何数字先答"哪个模型、
  哪个分辨率、什么形态"三问。
