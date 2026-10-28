# B1 战役蓝图（window_block 指令深度战，2026-10-28 立）

> 索引：总蓝图 `notes/section100-blueprint.md` §7.5-靶① 指向本文。
> 分支：`b1-wblock-resident`（已推 origin；blade-1 已在此分支转正）。
> 战线目标：window_block 家族 帧内 26.1（small）+16.6（giant）=42.7ms → 前辈同级 6.2ms/10pass。
> 里程碑账：walk 227 →（P8 快刀）→ 117 →（B1 目标）→ **~80 以下**，再往后是 quant/attention 的 B2。

## 一、已锁死的机制模型（全部实测，不许再翻案）

1. **v4full 已经是 resident**（一 WG 一 window，7 stage 全 SLM）——P1 赢了"resident vs split"轴。
   剩余对前辈的 6.5x（93ns vs 608ns/window，前辈算力还弱 4.4x）**不在 global 往返轴上**。
2. **P8-n/o 三连否证**：消 L2 内流量（mega 删 dS/dH16）=零收益；占用（2→4 WG/SM）=零；
   时钟（900-rep 热漂）=1.1x 不是主因；双进程 2.07x=帧内 GPU 饱和，无 idle 可藏。
3. **P8-fill 探针（前辈 PROBE_FILL 移植）**：注入 128 条 ALU 链只付 18% 的价（+0.0475 vs 满价 0.26）
   ⇒ **v4 是延迟绑定（dependency chains + WG barriers），issue 利用率 ~20%**。
4. **blade-1（P8-q2 合并 store）已转正**：store 指令 8→4/行对，QKV 0.563→0.518、
   FULL 1.232→1.216、帧 A/B 9/10 +1.41ms、边际 wblock-small 27.1→26.1。
   它赢的原因与模型自洽：**SLM store→load 是链上延迟**，减 store=缩短链。
5. **P8-r 半 store 否证**：字节减半、指令数不变 → 更慢。判决=**只数指令，不数字节**（B1 设计红线）。

## 一点五、战果（本分支已转正两刀，延迟链论点=已验证盈利）

- **blade-1（P8-q2 合并 store，提交 86647a2）**：acc→SLM 相邻列半行合成一次
  simd<float,16> store（16→8 指令/part），store 0.056→0.032、QKV 0.563→0.518、
  FULL 1.232→1.216；帧 A/B 9/10 **+1.41ms**；JUDGE 七区全 EXACT。部署 c84d1d22。
- **blade-2（P8-blade2 两段式 QKV，提交 077fac5）**：三个 part 的 dpas+store 全做完
  →**一个** barrier→reload+epilogue+scatter 全做完（6 个 subgroup barrier→2）。
  scrA/scrB 分 subgroup 的 4KB SCR，scrC 别名 PPO 头（softmax 前死，phase-2 消费完
  再 barrier 排序）。QKV 0.518→0.474、FULL 1.216→1.111；帧 A/B 9/10 **+1.32ms**；
  端到端 100%×2。开发中 JUDGE 两次秒级逮 bug（scrB 误叠 4KB ATO 区→6 区 BAD；
  漏末尾 barrier→VPO dump 竞态 214/8.36M）——安全网价值实证。部署 **8ad560c2**。
- **分支累计**：walk 117→**~112.5**（-2.7ms）。两刀都砍在 barrier/指令数（延迟链），
  而消 L2 流量的 mega 死在同一模型下 ⇒ **latency-chain 论点是盈利的，v5 几何继续这条轴**。

## 二、v5 正式设计（shuffle-epilogue 版；8×8 naive 已封存见雷#6）

**v5 几何账（1c1f437 WIP 已证伪的路线，先记住）**：8×8 行/LW=128 的 naive 移植
**不划算**——epilogue lane8-15 空转 + 60KB SLM 掉到 1 WG/SM，QPO 0.894 > v4 0.651。
前辈的 8-subgroup 是 coopmat/SIMD32 的产物，dpas/SIMD16 移植要重设计。**此路封存。**

**★ 对照数修正（本轮精算，覆盖我之前的 6.5x 误账）**：前辈 window_block = 0.62ms/pass
× 10 pass，每 pass ~2135 window ⇒ **290ns/window**。我们 v4full = 1.11ms/2040w =
**545ns/window**。真实差距 = **1.9x**（不是 6.5x——我之前把前辈的 per-pass 当
per-window 除了）。v5 现实目标 = 545→~300（追平前辈），bench FULL 1.11→~0.7，
帧收益 wblock ~25.9→~16（**约 -10ms**）——仍是本战役最大单块，但预期按 1.9x 校准。

**v5 正式设计（shuffle-epilogue 版，保留 4×16 几何）**：
精读前辈 200-270 行后确认——**前辈也有 acc→scratch store→reload**（他的
coopMatStore 到 per-subgroup 1KB scratch + subgroupBarrier），所以"消 scr 往返"
不是他的武器。他的武器是 **epilogue 的 4-lane×8-channel 分布 + 2 次 shuffleXor**：
- 我们 v4 的 fat = `cosine_recip_vec`：**每 lane 32 通道标量数组读取**（h[ch]
  逐元素 extract，~60 个标量 eh_mul/eh_add）+ 每 lane 32-float 宽 reload。
- 前辈：每 lane 只碰 8 通道（4 lane 分一行），partial[2] + 2 次 shuffleXor(2),(1)
  完成 4-lane 归约——**代数上与我们 cosine_recip_vec 的 lane^2/lane^1 蝶形同树**
  （他就是这树的原始定义），所以**逐位恒等有构造性保证**。
- v5 = 前辈 epilogue 搬到我们 scr 布局：16 lane 每 pass 服务 4 行（lane l:
  row l>>2, channels (l&3)*8..+7），4 passes 覆盖 16 行。每 lane：4×vec2 load
  （8 floats）→ 8 通道平方树（eh_hfma×4+eh_mul×4+eh_add×4）→ shuffleXor(lane^2)、
  shuffleXor(lane^1) 两次 → 得该 lane 的 row recip → mulh/e4m3 8 通道 → scatter。
  **不动 dpas、不动 SLM map、不动 LW=64**——只换 QKV epilogue 的 lane 分布。
- 收益账：标量 extract 链（32/lane）→ 8/lane + 2 shuffle；reload 32-float 宽向量
  → 4×vec2。norm+scatter 0.021→~0.010，reload 侧宽 load 消失（blade-2 的 phase-2
  变轻）。三个 part 都吃。保守估 QKV 0.474→~0.38，FULL 1.11→~1.0；**若再配合
  scores 段的同类 epilogue 化（softmax 已是前辈形态，不动）收益有限**。
- **诚实分级**：v5-shuffle 单独 = bench -0.1ms 级（帧 -1~2ms），**不是** -10ms。
  到前辈 290ns 的差距大头在**每窗 dpas 指令数本身**（我们 SIMD16 192 dpas +
  128 scores + 64 attnV + 32 outproj ≈ 416 条 vs 前辈 coopmat 数）与 barrier 数。
  下一刀真正的大肉候选 = **window_block 的 tc 循环合并**（scores 4tc 与 attnV 2tc
  的 dpas 链间没有数据依赖的部分重叠）+ **barrier 再砍**（v4 剩 7 个 esimd + 1 group）。

**施工序（v5 修订版）**：
- v5a：QKV epilogue shuffle 化（bench_v4full 里加 launch_v5a，JUDGE QPO/KTO/VPO
  必须 EXACT——树同构论证在上，红了就是 lane 映射错）。
- v5b：若 v5a 兑现，推广到 blade-2 phase-2 的其余 reload 点（attended/ATO 是
  32 宽但无 norm 树——只换 load 宽度，收益小，先测）。
- v5c：barrier 审计：v4 现存 7 个 esimd::barrier + 1 group_barrier——逐个问
  "谁读谁写跨 lane？"能降 subgroup-local 的降、能删的删（blade-2 已证 barrier
  是真成本）。
- v5d：若 v5a-c 合计 <3ms 帧收益，**转攻 quant 11.5ms**（§四 B2，前辈 1.64ms
  的 7x 差距——那才是账面最大单体肉，读者折叠设计见 §四）。

前辈 window_block.comp（531 行，已精读）的形态与我们 v4 的三条结构差：

| 轴 | 前辈 | 我们 v4 | v5 动作 |
|---|---|---|---|
| 每 window 的 subgroup | **8 个 × 8 行**（LW=256，SIMD8） | 4 个 × 16 行（LW=64，SIMD16） | **8 × 8 行**（LW=128，SIMD16 每线程 8 行）→ 每线程链深减半 |
| epilogue 的 norm | **寄存器内 4-lane×8-ch + 2 次 shuffleXor**，行从不完整落地 | acc→scr f32 全行 store→barrier→reload→cosine_recip_vec | **shuffle-树直接照搬前辈**（他的树=参考树，匹配他的 lane 结构=位精确安全路）→ **scr 往返整个消失** |
| SLM 预算 | 16KB（K/V 各 4KB + 每 subgroup 1KB scratch） | 45KB（含 16KB SCR 中转） | ~32KB（maps 16KB + scores 流水 4×4KB）→ **LW=128 时 2 WG/SM 保住** |

**v5 的每段链都变短**：P0 gather 8 行/线程（1 store 对/线程）、QKV part 8 行 acc（4 个
simd<float,32> 而非 64×2）、epilogue 无 scr 往返（norm 走 shuffle、e4m3 scatter 直接从
寄存器）、scores/softmax/attnV 同样 8 行化。预期 = 前辈 93ns/window 的可达性论证
（同几何、同指令形态，我们 dpas 还快 4.4x）。

**位精确论证链（写码前钉死，写码中逐段 JUDGE）**：
- shuffle 树逐字照搬前辈（他=参考对质过的树）；ef_add/eh_round 链用我们的已证向量原语
- 7 区 JUDGE（QPO/KTO/VPO/scores/probs/attended/projected）每 stage 一开门——
  前辈的 map 与我们的 map 若不同，JUDGE 秒级逮住（P8 全窗期的安全网，第七逮也不会漏）
- 寄存器预算：8 行 acc=4×simd<float,32> + epilogue 临时 ≈ 12 GRF 内——安全线内
- 前辈的 K/V scatter（他 2 个 u32 store/lane）对应我们的 pb16t/pb16 map——
  **map 不变（JUDGE 锁死），只换谁算哪行**

## 三、前辈数字的正确读法（本轮精算，写死防再错）

前辈 frame-ledger（`notes/frame-ledger-a770.md`）：row/4 window_block **6.20ms/10 pass**
= 0.62ms/pass，每 pass ~2135 window（768x448 帧）⇒ **290ns/window**。
我们 v4full bench = 1.11ms/2040w = **545ns/window** ⇒ 真实差距 **1.9x**。
（此前"6.5x"是把前辈 per-pass 当 per-window 误除，作废。）
同口径帧账：前辈 6.2ms/10pass vs 我们 wblock 全族帧内 ~26ms / bench 折算 ~22ms。
**v5 战役的正确靶 = 545→~300ns/window，帧收益上限 ~8-10ms**——不是 25。

## 四、施工序（v5 修订版，每步独立转正/回滚，三关照旧）

- **v5a ✅ 已转正（65a1c37，部署 fa0598c8）**：实际打法比设计更简单——不搬
  shuffleXor 分布，直接把 cosine_recip_vec 的 32 标量 extract 树向量化（4 select +
  ~11 宽 ops + 2 个 select 蝶形；树同构=位精确论证见代码注释）。靶=相位梯定位的
  part0 0.278（首条链暴露延迟）vs part1/2 0.046/0.086。帧 A/B 8/10 **+0.77ms**，
  JUDGE 七区 EXACT + 端到端 100%×2。QKV 没降（0.463 平）但 FULL 1.110→1.088——
  收益在链重叠度不在段总量，与 fill 探针模型自洽。
- **v5b** attended/ATO 的 32 宽 reload 点（无 norm 树，只换 load 宽度）——先测再说。
- **v5c barrier 审计**：v4 现存 7 esimd::barrier + 1 group_barrier，逐个问
  "谁读谁写跨 lane"——blade-2 已证 barrier 是真成本（6→2 = +1.32ms）。
- **v5d 止损条款**：v5a-c 合计帧收益 <3ms ⇒ 转攻 **quant 11.5ms**（§五 B2，
  前辈 1.64ms，账面最大单体肉）。
- 真库接线模板（v5a 兑现后）：window_block_v4.hpp 同法改 + NR_WB_V5A 逃生舱 +
  帧 A/B 十对 + 三关。回滚纪律=军规⑤。

## 五、收益账（按 1.9x 校准后的诚实区间）

- v5a（shuffle epilogue）：bench FULL 1.11→~1.0；帧 -1~2ms。**单独不是大肉**。
- v5a+b+c 合计乐观：FULL →~0.85-0.9（545→~420ns）；帧 -4~6ms。
- **到前辈 290ns 的剩余差距主体 = 每窗 dpas 指令数**（我们 SIMD16 tile 数
  192+128+64+32 ≈ 416 条 vs 前辈 coopmat 8x16 数更少）——再往下要打
  tc 循环合并/更大 tile（SIMD32 dpas? = 新地形，未探）。
- quant B2 线：11.5→~4ms（折叠进生产 gemm 的 epilogue，P2 已证半条路）= 独立 -7ms。
- **walk 路径**：112.5 →(v5a-c)→ ~106-108 →(B2 quant)→ ~99-101 →(giants split 对拍)→ ~95。
  追平前辈 48ms 需要 B1+B2+B3 全部兑现 + 游戏侧 host 15ms 那条线（§六 另案）。

## 六、已排雷清单（v5 不许再进的地雷）

1. 半 store / 字节优化（P8-r：指令数才是货币）
2. 32-reg hoist（P8-g/g2：≤16-reg 预筛线）
3. mega 式消 L2 内往返（P8-n：边际不降=流量不在关键路径）
4. 占用/LW 加减 WG（P8-o：边际 9.0 vs 9.0）
5. 动态索引拼装 A-map（P8-e/§7.6：常量偏移 + JUDGE 逐区对质）
6. **naive 8×8 行移植**（1c1f437 WIP：idle-lane + 60KB=1WG/SM 双输，QPO 0.894>0.651）
   ——前辈的 8-subgroup 是 coopmat/SIMD32 产物，不能照搬进 dpas/SIMD16
7. **"消 scr 往返"当 v5 卖点**（精读前辈 200-270 行：他也有 coopMatStore→scratch→
   reload；他的赢面是 4-lane×8-ch epilogue 分布 + shuffleXor 树）
8. 6.5x 误账（已修正 1.9x，§三——所有预期按此校准，不许再画 25ms 的饼）

## 七点五、"追平前辈"的完整算术（用户 20:41 质问的答案，写死防再画饼/防再丧气）

**问题**：v5a-c 终态（~420ns/win）仍追不上前辈（290ns/win）——那 B1 还有什么意义？
**答案**：追平前辈从来不是 wblock 单族战役。三条线的账（device 侧，960x544）：

| 线 | 我们 | 前辈（折算/账载） | 差距 | 打法 | 预期回收 |
|---|---|---|---|---|---|
| **quant B2** | 11.5ms | 1.64ms（=7x，最大倍数） | ~9ms | 折叠进生产 gemm epilogue（P2 已证半条路：288/448 已溶） | **-7~9ms** |
| **wblock B1(v5a-c)** | 25.9 | ~9.7（290ns×折算） | 2.7x | shuffle/vector epilogue + barrier 审计（本蓝图） | **-4~6ms** |
| **wblock B3（指令数）** | ~420ns（v5 后） | 290ns | 1.45x | 更大 tile/tc 合并/SIMD32 新地形——**未探，单独立项** | 再 -6~8ms（不确定） |
| **ffn/giants** | 17+16.6 | ffn 5.6×折算 | ~2x | P8-l/m 已收两轮；giants split 对拍未做 | -3~5ms |
| **host/提交线** | 未动 | 前辈自己账：50-34.6=**15.4ms 不在设备上** | — | daemon 流水化（前辈 notes 提过 NR_DAEMON_PIPELINE，从未与 async 分开量过） | **-10ms 级潜力，零 GPU 风险** |

**合账**：112.5 → v5a-c ~107 → B2 ~99 → giants ~95 → B3 ~87 → host 线 ~75。
前辈 48 = 病态数据 + 24.8 TOPS coopmat 的产物；device-only 他 36.4。**我们的终点
不是"每族都追平"，是总量追平**——B2+host 两条低风险线就贡献 -17~19，超过 B1 全部。
v5 的真实意义 = 把"延迟链"论点兑现成钱 + 给 B3 探路（epilogue 指令画像）。
**优先级裁决（写死）：v5a-c 打完（已开工、论证全）→ 立即转 B2 quant（最大倍数）→
host 线并行另案（不碰 GPU 数值，风险最低肉最大）→ B3 视 B2 后剩余账再立项。**

## 六.五、B2 QUANT 战役 census（21:1x 本轮实测，下窗口开工直接读这里）

**帧账**：quant 家族现存 ESIMD 边际 ~10-11ms（NR_Q_STOP=9 实测 10.0-10.9）；前辈同级 1.64ms = **7x**。

**plan census（walk_plan.py 机制代码 148-270 行精读后修正版，552 个 QUANT 步按 src 最后写者分组）**：

| 组（src ← 写者） | N | 元素量 | 现状 |
|---|---|---|---|
| 1267 ← GEMM_INT8_RESIDUAL（ffn 输出） | x120 | 100.7M | 消费者配对存活（见下） |
| 1277 ← WINDOW_ATTENTION | x104 | 97.5M | 同上 |
| 1275/1274 ← GEMM_INT8_BATCHED | x72+x40 | 69+234M | **NR_Q_FUSE_B 门 OFF**（历史实测 fused-pack +8ms 吃掉 quant -12 = 净中性，00:45 判决存档） |
| 1275/1274 ← GEMM | x32+x32 | 17+42M | 配对存活 |
| GEMM_WINDOW_INT8_RESIDUAL 系（1279-1297） | x~86 | ~75M | 配对存活 |
| 其余小头 | x~18 | ~20M | — |

**机制要点（写码前必读）**：
1. `g_quant_pk` 以 **pk 缓冲（1272/1273 共享 scratch）** 为键——登记后**必须**下一个
   gemm 立刻消费（`qfuse_take` 查 a==pk），否则被后一个 quant 覆盖 = 存活。
   配对条件：sc/M/K 相等（+batched 的 lda/sa 形、gap<=4）。**16 个 scale-buf 不同的
   天然两 pass**（census 存档）。
2. 消费者侧（gemm 的 pack_a 内嵌量化）**已经打完**——P2 全溶解 448/448 的那轮 +
   batched 变体实测净中性关闭（NR_Q_FUSE_B）。**剩下的 10-11ms 不是配对没做，
   是配对几何不满足**（写者与读者不相邻 / scale buf 不同 / 多读者）。
3. **前辈的真打法 = 生产者侧**：quant 折进生产 gemm 的 store epilogue——他的
   gemm 存 f32 时顺手出 e4m3-packed int8 + row scale（193 个 quantize_row 共 1.64ms）。
   我们的障碍：row scale = 256 宽行的 max-abs 归约，生产 gemm 的 tile 输出跨
   subgroup 不持整行 ⇒ 需要"生产 gemm 输出行持有 + 行内归约 + packed store"三合一
   （= gemm_pub_pa16 家族的自然延伸，但 scale 归约是新地形）。
4. **候选靶排序（按组 x 元素量）**：(a) 1267←GEMM_INT8_RESIDUAL x120（ffn 三族的
   输出行=32 宽，quant 行=256 宽 ⇒ **8 个 ffn 输出行拼 1 quant 行**，跨行 scale——
   先查 ffn Cout 布局与 quant 行对齐）；(b) 1277←WINDOW_ATTENTION x104（attention
   输出 96 宽行 vs quant 256——同样先对账）；(c) x32 GEMM 小对（2040x256：
   gemm 输出行=256 宽**正好一行** = 最干净的第一个靶！(2040,256) 的 GEMM dst=1275
   直接 f16 行→e4m3+scale 内嵌 store）。
5. **★ 深剖结论（21:3x，覆盖上一条的初判——下窗口直接按这版开工）**：
   - "shared-scratch 多读者=不能折"的担心**错了**：1267/1277/1275 是 ping-pong
     scratch——每个写者之后**立刻**跟它的 QUANT（step14 BATCHED 写 1275 → step15
     QUANT 读 1275）。RESIDUAL x120 写 1267 → x104 QUANT_WINDOW 读。写读严格相邻。
   - **真靶 = (a) x120 GEMM_INT8_RESIDUAL→QUANT_WINDOW（1267，100.7M）+
     (b) x104 WINDOW_ATTENTION→QUANT（1277，97.5M）**。初判的 (c) GEMM x32 组
     实际相邻对只有 x10——降级为小修。
   - **打法 = 生产者侧内嵌量化**：生产 gemm 的 store epilogue 顺手出
     e4m3-packed int8 + row scale（qr_kernel_rowthread 已证 numpy-exact）：
     * (a) 在 GEMM_INT8_RESIDUAL 的 store pass：行宽 K=256（=quant 行宽，
       一行一 scale，无跨行归约！），acc 行已在 tile 里 → 行内 max-abs +
       fdiv_rn + e4m3 打包直写 pk(1272) + scale(1273)；f16 输出 1267 **仍要写**
       （skip 读者），但 QUANT 的 100.7M 读+写整个消失 = 每对省 ~1 pass。
     * (b) 在 WINDOW_ATTENTION 的 P7 store：行宽 96 vs quant K=256?
       **先核对 1277 的 quant (M,K)=(2560,256)/(9216,128)——行宽不匹配，
       需跨行 scale 设计，第二步做**。
   - **开工顺序（钉死）**：(a) 先行（行宽=256 完美匹配）→ 三关+帧 A/B →
     然后 (b) 行布局图 → 跨行 scale 设计。预期 (a) = -3~4ms（100.7M 的
     读+写+launch），(b) = -2~3ms。B2 合计 -5~7ms。
   - **形状对账（21:4x 实测，120/120 全配对）**：quant K == gemm N 全部相等
     （(2040,256)→(2560,256) x32、(640,512)→(768/960,512) x32、(8160,128)→
     (8640/9216,128) x24、(32640,64)→(32640-35712,64) x16、(192,1024)→(192,1024)
     x30）。M 不等 = QUANT_WINDOW 的 gather 行重复（窗口重叠 x16 纵向）——
     **scale 是按 unique 行算的，重复行 scale 相同** ⇒ 行内 max-abs 只需在
     gemm 输出行上算一次。**但行宽 N=256 跨 16 个 tc tile（tile8s=16x16），
     无单 subgroup 行持有** ⇒ 设计两案：(i) gemm 后接一个"行归约+打包"轻 pass
     （只读 f16 一次，替代 QUANT_WINDOW 的 gather-读+写，省 gather 重复读）；
     (ii) tc 循环内行 partial-max 寄存器累加 + 末尾行归约（真·内嵌，改 tc 循环
     结构=大手术）。**先做 (i)（低风险），(ii) 视 (i) 收益再立**。
   - 实现载体：GEMM_INT8_RESIDUAL 已有 fused-pub（gemm_b_pub_f16 家族）——
     在 pub 之外再加 packed-int8 第二 store（dC 行 f32→scale 归约→e4m3→pb16
     直写）。scale 归约=行内 max-abs：tile 的行持有度先查（N=256 宽行跨
     tc_n tile？→ 若是，行持有不成立，改用 blade-2 式两段：store f16 行到
     pk 前的过渡 slab——设计稿第一步=画 N=256 的 tc 切分图）。

## 六.六、B2 实测账（21:4x，覆盖 §六.5 的预估——下窗口按这版开工）

1. **EXEC census（新工具 NR_Q_STATS，执行时打印=真幸存）**：**160 发** real ESIMD
   quantize（不是初判的 224），形状全表：(640,2048)x32、(8160,512)x24、(32640,256)x16、
   (2040,256)x32、(192,1024)x16、(8160,128)x24、(32640,64)x16。pk 只有 1305/1312。
2. **三段定价（NR_Q_STOP=8/9 三态）**：real-ESIMD-kernel = **9.5ms**；fused-memcpy
   分支 = **0**（P2 的 memcpy 不花钱）；幸存全在 kernel 段。
3. **★ 地板分解（本轮最重要的一条账）**：160 发流量 = 1107MB → 420GB/s 下地板
   **2.64ms**；实测 9.5ms ⇒ **6.9ms = launch/延迟开销**（平均 59µs/发 vs 大形状
   32640x256 的 60µs——小形状全在发射延迟上）。**B2 的肉不是消流量，是消 launch**。
4. **消费者侧内嵌（take_b / NR_Q_FUSE_B）新账本下重测：3/8、-0.47 = 仍负**
   （两次独立判决一致，pack_a 内嵌量化的串行代价 > 省下的 launch。此路封存）。
5. **生产者侧真内嵌（前辈形态）= 唯一未打的 B2 刀**：gemm 的 tc 循环天然按行扫过
   全部 16 个 16-列 tile ⇒ **行 max-abs 可在 tc 循环里寄存器累加**（partial-max
   per row），tc 循环尾做 scale + e4m3 打包直写 pk+scale——quant launch 与 f16
   读（738MB）双双消失。前提核查（下窗口第一步）：batched gemm 的 subgroup
   ownership 是否一行归一个 subgroup（若列被切走则先改 ownership）。预期
   -5~6ms（消 6.9ms 开销的大部）。**开工序：(a) 先画 gemm_int8_batched 的
   tc/行 ownership 图 → (b) bench 原型（JUDGE=pk 逐字节对拍）→ (c) 三关。**
6. QUANT_WINDOW 幸存 ~1ms（x104 里大部分已被 P4b take 溶解）——不动。

## 七、交接检查单（新窗口开工先读这些）

1. 本蓝图全文 + 总蓝图 `notes/section100-blueprint.md` §7.5-7.6（★索引行在 7.5 头部）
2. 分支状态：`b1-wblock-resident`（origin），tip=本提交；部署 md5=**8ad560c2**
   （blade-1+2，游戏画面已验收 OK）；主分支 healthy-chain-resident-opt tip=12fb8f5 之前
3. bench 验收尺 = bench_v4full（7 区 JUDGE + PURE-LADDER + fill 探针 + part0 微梯）
4. WIP 封存：src/bench/sycl/bench_v5_WIP.cpp.txt（8×8 naive，勿复活）
5. 当日流水：E:/WorkBuddy/2026-10-25-22-59-21/.workbuddy/memory/2026-10-28.md（全文精读）
6. 下一步 = §四 v5a（shuffle epilogue，设计论证已在 §二）
