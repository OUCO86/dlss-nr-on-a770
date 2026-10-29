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
| **wblock B3（几何/链数）** | 497ns（giants 实测） | 290ns | 1.70x | **已否证关闭**：dpas@SIMD16 满载只允许 16 行/sg=v4 几何；8x8 移植 giants 1.60x 慢（W2''）| **无**（此轴已死）|
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
7. **★ B2 kernel-形态收割完毕（21:5x，bench_qr/qr2/qr3 三连，诚实账）**：
   - 稳态三态（去 JIT）：full=120.5 / s8=111.5 / s9=112.1 ⇒ **kernel-time 9.05ms，
     launch-scheduling ≈ 0（-0.58=噪声）**——"消 launch"论点被**否证**（图执行器
     把 160 个小发射藏得很好）。
   - 隔离 sum-of-shapes = 5.26ms（202 GB/s 平均）；帧内 9.05 ⇒ 3.74ms = L2 竞争
     价（rule-11 的缓存交互，不是 kernel 形态问题）。
   - 形态扫描（RG<LW,CH16> 全家族 + LW=128）：640x2048 "WIN" 经**对拍裁决 bench
     撤销**（warm-up 假象：shipped 0.036-0.040 vs mine 0.036-0.045，pk/scale
     diff=0 证同形）；LW=128 无赢（0.044 vs 0.043）。**rowthread/rowgroup64
     就是当前地板形态**。
   - **B2 剩余唯一未打刀 = 生产者侧真内嵌（§六.5-5 的跨-WG 行归约问题）**：
     N=256 行跨 4 个 WG（BN=64），行 max-abs 需要 SLM slab 二次扫或跨 WG 全局
     归约——两种都把"quant 读 f16"变成"gemm 写 f16 + gemm 读回 f16"，字节不变
     只省一 launch（已证≈0 开销）⇒ **按当前形态账，真内嵌收益上限 = 隔离
     5.26 - 内嵌后 ~3 = 仅 -2ms 级，且要动 5 个 gemm 族的 store epilogue**。
   - **B2 判决（写死）：quant 家族从"7x 最大肉"降级为"~2-3ms 残肉 + 高手术
     成本"。账本重排：剩余大肉 = (i) giants-split-wide 对拍（§六 P8-h 计划里
     从未执行的那条：4 个 v4ph call 16.6ms vs split wide-M 路——§99 宽 gemm
     2-3.5x 红利区，未对拍）；(ii) wblock 帧内 26+16.6 的 B3 指令数战（SIMD32
     新地形）；(iii) host/提交线（前辈账 15.4ms 不在设备，从未动过）。
     **下窗口开工序：(i) 先行（纯对拍实验，一天内出判决）→ (iii) 并行另案
     → (ii) 视剩余预算立项。**
8. **实验 (i) 已跑（21:5x，giants split-vs-v4ph 交错配对 8 轮）**：
   no-POOL delta = **-1.28**（split 反而慢）、no-HEAD delta = **+1.14**（split 快）
   ——两方向相反、都在 ±1.2 噪声带内 ⇒ **v4ph 与 split 在 giants 上打平，
   路由已在最优点附近，此线无肉**（§六.6-7 的 (i) 关闭）。
   注：第一轮批量测（非交错）给过 +4.4/+4.6 的假信号——**又是热漂移**，
   交错配对是铁律（rule 归档再+1）。
   **账本再重排**：(i) 关闭后 = (ii) host 线 + (iii) B3。
9. **★ 实验 (ii) 已由游戏日志直接关闭（21:5x，F://Game//Lies of P\...\OptiScaler.log
   实测帧账，20:25 用户刚验收的那局）**：
   `gap run took=131.9ms | signal=0.006 read=0.027 wait=0.60 fence=0.007
   work=131.26 write=0.03 | copy/decode/features/compose/encode/host = 全 0.000`
   ⇒ **我们的 C++ 进程内 bridge 已经把 host 线压到 ~0.7ms**（前辈 15.4ms 的账是
   Python-daemon 时代的遗产——游戏 10-16 起走进程内 nr_net，无 daemon 无管道）。
   **host 线无肉，此线关闭。** (ii) 的"并行另案"取消。
   游戏 131.9 vs 离线 walk ~112-120 的差 = 持续满载时钟（§7.5 已记 ~12ms 残差，
   暂不追）。
10. **★★ 历史线重定义 + “诚实墙”撤回（10:38 用户点破，写死不再犯）**：
   **项目真实历史**：起点 = uzbekunknown/dlss-nr-on-intel 移植（本地
   src/dlss5nr-b580 就是这一脉的存档）→ 优化到 ~59ms → 判定“整体不适合
   A770、上限无肉” → **推翻重写 = 现在的大宽数据链路全新核心，
   目标从出发就是 20ms 以内**。当前新核心战役才打到 112ms（峰值 170 起步）
   = 第一波家族手术完成，**距目标还差 5.6x —— 谁也没权利说“没肉/墙”**。
   - 我上午写的“纯工程收割尽头 ~95-100、架构差不是懒惰差” **撤回**：
     它锚错了对象（拿"追前辈/追 B580"当锚，而锚应是 20ms 设定）。
   - **“架构差”的真含义用户赋能了**：B580 式小 program 几何确实不适合
     A770（这是推翻它的理由）；宽-M 是正确架构。但 **112→20 的差不是
     家族内精修，是整帧融合级别的活**：前辈/前人的 P1 判决原文——
     "中间量 round-trip global = 6.2x 的主因；resident 一刀枢死整个结，
     ~160ms → ~12ms"。v4full 只把 window_block 内部 7 stage 变 resident；
     **帧的其余 670 发还是 split**（qkv tail 的 dC global 往返、winres、
     residual、quant、unary…）。lmxxf-3080 反过来的数字也印证这一点：
     全帧只有 **82 launch**（FB00-06 每层一个融合核，producer 直接喂
     consumer 的 matrix fragment，QKV_FUSE/T=2 复用/plane 生命周期）。
     我们 691 vs 82 ⇒ **launch 结构差 = 5.6x 的主要来源之一**，这不是
     “B580 目标数”问题，是“方法”问题：**把层内链融进一个 wide-M resident 核**。
   - **新战役 B5 = 整帧层内 resident 融合（目标锚 20ms）**，施工顺序按
     “链最短、机制现成”排：
     * **B5-1 = QKV tail 折叠**：qkv 家族旧账 27.6 = pack 1.4 + wide gemm 5.7
       + **dC 往返尾 20.8**（1742239 字段；P7 cgraph 口径 tail 9.6）。
       wide-M gemm 写 int32 dC → qkv_norm_scatter_esimd 读回→norm→pack。
       托 = 把 norm+pack 折进 gemm store epilogue（gemm_b_pub 家族机制现成，
       BN=64 tile 内 32 通道 head 边界对齐→行内 norm 可算）。预期 -6~9ms。
     * B5-2 = winres + 其 quant 同级融合；B5-3 = residual 链；B5-4 = C32 层
       （wblock 输出→down→下一层）；B5-5 = ViT 层；每层一个 resident 核。
     * 铁律不变：毀先于建（每层开工前先拉该层的 stage 微梯定位）；三关+帧 A/B；
       P8-n 教训只适用 resident 内部往返，跨 kernel 的 global 中间量消除
       是另一回合（P1 判决原文支持），仍以帧 A/B 为裁判。
   - 上一条"终版账本"的“接受 ~112 为终点”选项同时作废。
   - **(iii) B3 = wblock 战（唯一的大肉）**：帧内 wblock 26（small）+16.6
     （giants）= 42.6ms vs 前辈折算 ~10-13。
   - **★ (β) 探针已跑并出判决（22:2x，dpas_probe.cpp 已入库）**：esimd
     `dpas<SD,RC>` 的 static_assert = **RC<=8、SD==8**（XMX 阵列就是 8x8）
     ⇒ 前辈 coopmat 8x16 在硬件上同样拆两条 dpas，**"dpas 指令数差距"归因
     作废**（§五 表里"更大 tile/SIMD32 新地形"一行作废，§五"差距主体=每窗
     dpas 指令数"一句作废）。
   - **★ 修正后的归因（本轮最有价值的结论）**：差距 = **每 SM 的独立链数**
     （线程级并行度）。前辈 256 线程/窗 + **16KB SLM**（K/V 各 4KB + 每
     subgroup 1KB scratch 跨 stage 复用，他注释原文）⇒ >=2 WG/SM = 512+
     线程/SM；我们 LW=64 + 45KB SLM ⇒ **1 WG/SM = 64 线程/SM**——延迟绑定
     核（fill 探针）没有链可换。v5-WIP 双输里 60KB=1WG/SM 是主症、idle-lane
     是表症。
   - **✖ v6 设计（已执行并全线否证，见 W2''——保留原文供考古）**：
     * LW=128 = 8 subgroup x 16 lane x 8 行/subgroup（前辈的行账）；
     * **epilogue = 前辈的 4-lane x 8-channel 树**：每行 4 lane（lane l:
       row=sg*8+(l>>2)、ch=(l&3)*8..+7），行归约 2 次 shuffleXor(2)/(1)
       ——**16 lane 全活**（v5-WIP 的 lane<8 空转正是缺这一步）；树同构
       位精确论证已在 v5a 入册；
     * **SLM 预算 16KB**（前辈账）：KTO+VPO 8KB + 每 subgroup 1KB scratch
       跨 stage 复用（gathered row/projections/logits/weights/attended/
       projected 轮用同一 KB——前辈原文）；AQO 进 scratch；Q 可留寄存器
       （前辈把 query 存 regs 给 scores 用！）⇒ **16KB => 2-4 WG/SM**；
     * dpas 序列与 scatter map 不变（JUDGE 逐区对质）。
     * 预期：wblock 42.6 -> **15-20**（-22~28ms，walk -> ~85-90）。
       **这是账本上最后一块大肉，也是追平前辈 wblock 族的正解。**
   - **★ v6 的两条实测警告（本轮新收，开工前必读）**：
     (W1) **占用轴单变量证据偏弱**：v4occ 探针（未入库，方法=SCR 别名进
         操作数区把 SLM 45KB 压到 28KB，数据有 race 但计时有效）测得
         1.161 -> 1.130 = **仅 -2.6%%**。"2 WG/SM"单独不是那个数量级的
         杠杆。v6 的收益必须来自 **几何+scratch+并行度三件套同时改**，
         不是 SLM 缩小本身。若 v6 只做 SLM 压缩 = 预期内 -3%% 级。
     (W2) **⚠ 已被 09:05 复核否证（写得太快，自纠）**：当时推测"8 行 tile 在
         SIMD16 下 dpas 半载（一半 message 是 padding）"。复核 esimd dpas.hpp
         + 我们自己的 tile8s：`dpas<SD=8,RC=8>` 的 A 操作数=128 half=
         **恰好 8 行 x 16K**（a0 一个 16 行块=两条 dpas：a0=rows0-7、
         a1=rows8-15）。v5-WIP 的 tile8h 载的也是同样的 128-half 满条
         ⇒ **dpas 半载不存在**；"方案 A（两 subgroup 拼 16 行 tile）"
         解决的是不存在的问题，作废。
     (W2') **v5-WIP 慢的真因（复核后重钉）**：①"6 个 barrier"说法**错**——
         WIP 已是两段式（查代码证实，只剩 2 个）；③60KB SLM=2 WG/SM 不是主症。
         ② **epilogue idle-lane（lane<8 半退休）= 唯一确认的结构缺陷**。
     (W2'') **★ 决定性否证（09:3x，bench_v6 giants 数据点，一次跑拿的）**：
         v6 核（=v5-WIP+stop6 dump 越界修复）在 **8160w GIANT 形状**
         （grid 够大、占用不是借口：2 WG/SM x 128 线程 = 256 线程/SM > v4 的
         128）**per-window 仍比 v4 慢 1.60x**（797 vs 497 ns/win；small 也 1.57x）。
         ⇒ **8x8 行几何在 dpas/SIMD16 栈上是方向性死路**，不是"修 idle-lane
         就活"——线程数翻倍、链深减半、barrier 已两段式，全都补上还是慢 1.6x。
         根因（本轮想透，写死）：dpas<8,8>@SIMD16 要 **16 行/subgroup 才满载**
         （a0/a1 两条满 128-half 消息）；窗口只有 64 行 ⇒ 每窗最多 4 subgroup
         =v4 的 4x16 就是 **SIMD16 栈上的唯一满载几何**。前辈的 8x8 行是
         SIMD8x32lane（8 行 x 4 lane 的 A 消息满载）的产物，**不可移植**。
         ⇒ v4 几何=已是最优适配；v6/v5 线**关闭**（雷 #6 定案）。
     (W2c) **★ 诚实的残余卡（未打的最后一张几何牌，EV 明码标价）**：
         giants 测的 v6 带 **idle-lane 浪费**（epilogue lane8-15 空转——SIMD16
         指令照发 16 条 lane，半退休=elementwise 发射功 x2）。真 v6.1（4-lane
         树全 16 lane 活）没测过。但两个理由说它 EV 低：
         ① 补 idle-lane 只消掉 ~1.6x 里的一宗罪，**另一宗=B-操作数
           (weights) 被 8 个 subgroup 重复载 = 2x SLM 读**（tile8h 每 sg 都
           载全套 B；v4 4 sg 只载一半的量）——这是 8-sg 几何的结构性代价；
         ② fill 探针说延迟余量已由 2 WG/SM 提供（80%% 吸收），链深减半的
           红利早被 v4 吃到。两罪消一罪 + 结构代价仍在 ⇒ **v6.1 大概率
           打平 v4，不是 -22ms**。若下窗口非要打几何牌，先 bench_v6 里
           给 epilogue 换 4-lane 树（~80 行改动，JUDGE 现成）再跑同一
           giants 对照——一小时出判决，不许先写真库。
     (W2d) **★ W2c 的牌也基本死（09:5x 原语检查）**：SYCL ESIMD
         **没有 subgroupShuffleXor 原语**（全 esimd 头 grep 零命中）——
         前辈的 4-lane 树靠 Vulkan subgroupShuffleXor，我们这栈要模拟
         只能 SLM 中转（部分和写 scratch 再读回）= **又一次 scr 往返，
         与消 idle-lane 的目的自相矛盾**。v5a 的 select-树（整行在
         单 lane 向量内完成归约）恰恰就是这个缺失原语的 SIMD16
         等价物——它已经吃了。**前辈 epilogue 武器在语法层不可移植**
         盖章。几何线死透：不要再打。
     (W3=新钉) **v6 的正确构成**（= v5-WIP 几何 + v4 的教训全叠上）：
         * LW=128、8 subgroup x 8 行（dpas 满条，W2 否证后此几何无障碍）；
         * **blade-2 两段式** QKV（phase1 三 part dpas+store 全做、1 barrier、
           phase2 reload+epilogue+scatter 全做）；
         * **epilogue = 前辈 4-lane x 8-ch 树**（shuffleXor(2)/(1)，16 lane
           全活；树同构=v5a 已入册；每 lane 4x vec2 load、8 通道 mulh/e4m3、
           K/Q 8x2-half scatter、V 8x1-half——store 总量与 v4 每窗相同）；
         * 后段（scores/softmax/attnV/outproj/P7）v5-WIP 已移植过且单跑
           probe 全 OK——softmax 的 lane<8 idle 同理解药（64 列 = 8 lane x
           8 列? softmax 树=标量 ef_add 链不可动序，但行可以在 lane 间分）；
         * SLM: 前辈 16KB 预算（scratch 跨 stage 复用 + Q 留寄存器）= 二阶段
           优化，v6.1 先保 60KB 能跑对再压。
         **下窗口第一步（改）= 直接建 v6.1：v5-WIP 核 + 两段式 + 4-lane 树，
         JUDGE QPO/KTO/VPO 对拍 v4 dump。方案 A/B 对拍作废（A 已死）。**
   - (α) tc 循环合并 = v6 后的精修；(γ) softmax 64 步标量链（改求和顺序=
     违反参考树，golden 考古门才允许动）仍然封存。
   - quant 真内嵌 = 2-3ms 残肉高成本，排在 B3 后。
   - **剩余全部加起来 ~15-20ms**（B3 乐观 +10、quant +3、giants +2、GA +2）
     ⇒ 离线地板 ~95-100，游戏侧 ~115。追平前辈 48 需要**算法级改动**（数值
     形态=底线区，需 golden 考古）或接受 2x 为当前架构终点。**把这条诚实写死：
     纯工程收割的尽头在 ~95-100，不是 48。**

## 六.七、★★ lmxxf 源码精读（10:2x，用户点死我的一课）——我的"架构差"结论被证伪

仓库=refs/lmxxf-src（GIT_SSL_NO_VERIFY=1 克隆成功，记忆惯例再次兑现）。
**同一张网**（nvngx_dlssnr Preset2，FB00→C32 / FB01-03→C64/128/256 /
FB04→C512 / FB05→ViT / FB06→decoder），RTX 3080 Laptop（sm_86，132W，
安培=5年前架构，FP16 mma ~125TF ≈ 我们 dpas 的量级）：

- 1080p 全网核时 **11.86ms**（v2.3 逐核硬件时间戳账本，82 launch/frame，
  FB00=4.26 + FB05 ViT=3.13 + FB04=0.93…）；720p=6.13ms。
- 我们 960x544（像素只有他 1080p 的 **1/4**）：walk ~112ms。
- **算力同级、像素 1/4、我们慢 ~9x ⇒ ◀◀ 我昨天写的"1.7-1.9x 是架构差、
  纯工程无可收" 全然错误。他们的数字证明实现差距是主，不是铸造差。**
  之前的对标错在只拿前辈（前一个工程师，coopmat 路径）的 6.2ms 说事，
  没把"同网同卡级别 11.86ms@1080p"拾起来当标。

**他们的方法论（源码级，不是公众号级），全部是我们从未做过的**：
1. **v2 偶奇 K16 零洗牌**：内积交换律拆偶奇两条 mma，原地喂寄存器→
   SASS 直方图 **SHFL 81853→4517（数出来的，不是猜的）**，1.56-1.61x。
   且诚实声明"交换律≠结合律，FP16 累加顺序变了"——保留 PSNR 不偷 gold。
2. **v2.1 解 .maxnreg**：`cuobjdump -res-usage` 数 **LDL/STL 溢出**（FB04:
   2169 条 LDL！），放宽后砍 97-99%，再快 35-37%，逐比特一致。
   逐包消融（FB01/02 放宽反慢 0.29ms → 保留原值）。
3. **v2.2 SWAR 双通道量化**：8944 处 e4m3 解包 29→20 条（b32密封+无分支
   lop3 mask 选择），穷举 3355万组 0bit 验证；+ mbarrier 异步化 316 处
   cp.async wait。组合 7.2%。
4. **v2.3 真实发射账本**：MinHook 拦 NVAPI 发射链 → **逐核硬件时间戳**，
   82 launch 全表（我们的 NR_*_STOP 是跳过定价，他们是直接测每核）——
   发现 FB00/FB05 占头、发现 720p 弱缩放（grid 取整后 1.33-2 CTA/SM）。
5. **v2.4 寄存器池**：dead-operand 按需解包，临时 b32 峰值 64→40/80→56。
   **A、B 两刀正确但无稳定收益 → 不进默认**；C 仅 0.4-1.5%。
6. **v2.5 Hybrid 解包分流：负结果**——PRMT 25483→19774 静态减了，
   总时间反慢 0.4-2.1% → 拒绝发布。**他们也天天证伪自己**，区别在于
   证伪建在指令级账本上，不是 wall-clock 倒推。

**对我们战役的直接启示（新战役 B4 = ISA 账本战，下窗口主托）**：
- 我们从来没数过自己核的 GEN 指令直方图。工具链已打通一半：exe 的 __CLANG_
  节里挖出 3 个 SPIR-V 模块（kdis/m0-2.spv，ESIMD 核在其中）；ocloc compile
  直接吃 .spv 失败（error -11，它要 OpenCL 格式）→ **下一步 = NEO 驱动的
  Program Dump（ZE_ENABLE_PROGRAM_DUMP=1 + NEOProgramDumpEnabled 系列 env，
  或 intel-gpu-tools）拿 GEN ISA 原文**，然后数四个直方图：
  (a) sendr/sampler shuffle 数（我们的 SHFL 时刻）；
  (b) decl/stmt 栈溢出数（我们的 LDL/STL，P8-g 故事的 ISA 版）；
  (c) e4m3/qr 链的标量展开密度（我们的 SWAR 机会，对标 v2.2 的 29→20）；
  (d) 每核动态发射帐（把 pass-timing 从报警阈值改成全表，对标 v2.3）。
- 前辈的 6.2ms 不是天花板；lmxxf 在同网 1080p 打到 11.86ms 且逐核账本显示
  他们也还未收割完（720p 弱缩放、ViT 小 grid、HMMA 重叠率待计数器）。
  我们的目标重定义：**960x544 同网同数据域，工程收割的合理终点应在
  30-40ms 量级**（他们 1080p 11.86 折像素比 1/4 ≈ 3-4ms 纯核，但我们多
  一个全帧 pre/post 与病态数据域；取 30-40 保守）——不是 112。

### 6.7-勘误（10:3x，用户点破对照方向搞反）——上面"9x/实现差"作废

**我把 B580 仓库的对照方向弄反了。** `src/dlss5nr-b580` **不是**该追的新标杆：
它恰恰是当初被**直接移植**到 A770、因架构不合（B580=Battlemage 新代 XMX，
A770=Alchemist 老代 XMX，供数/fragment 布局与矩阵指令行为不同）而**被推翻**的
那条"病态链路"的来源。现在的**大宽数据核心（healthy wide-M dpas）正是为纠正它
重写的**——这是已验证的既定架构决定，**不得回头采用 B580/Triton 的小 program 几何**。

⇒ 因此：
1. 上面"同指令类下我们慢 5x / 9x ⇒ 实现差不是架构差"**收回**。B580 的 39-40ms/720p
   不是 A770 的靶（不同 XMX 代 + 已被否证的那条路）。lmxxf-3080 的 11.86ms/1080p
   也**只是 NVIDIA sm_86/PTX/mma 另一套栈**，同样不能当 A770 目标数。
2. **唯一可借的是"思路/方法"，不是"目标"**：(a) 指令级账本（SASS/GEN/SPIR-V 直方图
   去数 SHFL/spill/标量展开——我们从没数过自己核）；(b) 具体手法候选：QKV_FUSE
   单 K-loop 出 Q/K/V、T=2 权重 fragment 复用（少重复 load）、plane0/plane1 生命周期
   复用（不写 global 中间量）、预排权重到 fragment-native 布局（热循环零 scatter）、
   sched_barrier 压未来片、PACK8 成对转换。这些是**跨栈通用的"消冗余功"思路**，
   可在我们的 wide-M 几何内评估——不是换架构。
3. 上午"架构差、纯工程无可收"和刚才"实现差 9x"**两个极端都错**。正确姿态：
   架构(宽-M dpas)已定且对 A770 最优；**在不动架构的前提下,用他们的"先数指令
   账本再下刀"方法找我们自己的冗余功**——这才是 B4 的正解。


## 六.八、★★ ISA 工具链已打通 + 四大账本落地（11:2x-11:4x，用户点死"先给我打通"）

**打通配方（AOT 路线，JIT-dump 在 Windows 驱动上不落盘，别再试）**：
1. `icx //fsycl -fsycl-targets=spir64_gen -Xs "-device dg2" ... //Fe:xxx.dll //LD libxmx_sycl.cpp //link //DEF:...`
   —— ★gen 管线只在**链接 exe/dll 时**跑；`-c` 编 .o 时 `-Xs` 被 clang-cl 报 "argument unused"、
   .o 里只有 LLVM bitcode（`BC\xc0\xde` 包装）没有 zebin。上次 AOT 失败根因=`-out` 应为 `-dump`、
   且节区提取长度要含节头表（`shoff+shent*shnum`，我先前漏了 3 字节截断 → "Out of bounds section headers"）。
2. 提取：python 扫 PE 里 `\x7fELF` + e_machine==0xCD（EM_INTELGPU）→ 按节表算全长写 `dep_N.bin`。
3. `ocloc disasm -file dep_N.bin -dump <dir> -device dg2` → 每个 kernel 一个 `.text.<mangled>.asm`
   （点开头，glob `*.asm` 匹配不到，脚本要用 listdir）+ `.ze_info`（YAML 资源清单）+ `.spv`。
4. 验证：`bench_aot.exe`（spir64_gen/dg2 构建）在 GPU 上跑 7 区 JUDGE 全 EXACT，
   1.082ms vs JIT 1.080ms —— AOT 与 JIT 同码同速，账本可信。
   产物与脚本全在 `src/bench/sycl/kdis/`：`ledgers_20261029.txt`（指令账本）、
   `spill_ledger_20261029.txt`（溢出账本）、`census.py`/`spill_ledger.py`/`movkind.py`/`parse_zeinfo.py`。

**账本 1（洗牌/搬运，lmxxf 的 SHFL 类比）**：GEN 的 `mov r8.0<1>:ud r3.0<0;1,0>:ud` 形态里
`<n;stride,...>` 是**操作数级跨 lane 重排——免费、不花指令**。v4full 实测：movish=981/2568 条
（mov 899 + sel 51 + join 31）；launch_resident 实测 strided-mov=3512、arith 带 strided-src=15681
（cmp 3919 / and 3222 / add 2178...）——**这些"洗牌"在 GEN 上本来就是零成本编码**，
不存在 SASS SHFL 那种独立指令。⇒ lmxxf 手法(a)"偶奇 K16 零洗牌"在我们栈上的对应物
= **消掉真实花指令的搬运**：`sel`(51)+`join`(31)+**SLM 往返 store/load**（v4full: slmST=156/slmLD=54；
resident: slmLD=703!!）。**头号搬运靶 = resident 核的 703 次 SLM load**（它 simd=8，
每条是 8-lane 消息；dpas 只有 51 条却配 703 次 SLM 读 = 供数结构问题）。

**账本 2（寄存器溢出，lmxxf 的 maxnreg/LDL 类比）**：ze_info 有官方字段 **`spill_size`**。
全链 402 kernel 中 17 个带 spill/private/scratch。★判决级发现：
**`wbres::launch_resident`（B5 旗舰 resident 融合核，NR_RESIDENT_WB 门后）
spill=4544B + private=1792B + scratch=8192B/thread，且 asm 里实打实 311 条 scratch 读写消息**
——它就是 P6 qkv_norm_scatter_v2 "ESIMD arrays spill" 同一个病：**局部数组被 SLM/scratch 化**。
其余：qkv gemm 热核 private=7680B（SIMD16，无 scratch 消息=编译器放 SLM/寄存器）、
stem_mega/ffn_chip scratch=1024-1312B。⇒ lmxxf 手法(b) 的对应物 = **把 resident 核里的
simd 局部数组改成命名标量/temp 链**（我们 P11 教训同款：named temp adjacent to use）。
**这是 B5-1 开工前的先决修复**——不修它，resident 核永远被 4.5KB spill 拖死。

**账本 3（e4m3/SWAR 密度）**：resident 2119 个 `:hf`（half）操作数触点、rnde 只有 10——
fp16 链本身已是 packed 形态；SWAR 成对转换机会在 scalar 量化路径（qr_e4m3_scalar），
B2 已数过（9.05ms，优先级低）。

**账本 4（per-pass 计时）**：GIANT 梯已存在（bench_v4full 的 stop 梯 + QKV parts：
P0=0.22 Q=1.24 K=0.19 V=0.17，scores=1.41 attnV=0.62 outproj=0.53 store=0.43）。

**下一步（按账本证据排序，写死）**：
(1) 修 launch_resident 的 spill（数组→命名 temp/标量链），对照 spill_size 归零 + JUDGE；
(2) 修好后 resident 核上热（撤 NR_RESIDENT_WB 门），用 703-SLM-load 供数结构 vs v4full 的
    54+156 对比，决定 B5 各层融合核的 SLM 布局规范；
(3) 再进 B5-1（QKV tail 折叠——注意 P5 证伪 nuance：tail 是 14ms butterfly 计算，
    折叠必须连带把 butterfly 也 ESIMD 化且不与 dpas 循环串行）。

### 6.8-首刀（11:5x，工具链打通当轮直接开挖的溢出修复，已验证）

**手法**：lmxxf 的"解除寄存器紧箍咒"在我们栈上的对应物 = **消掉逃逸的局部数组**
（数组被动态下标取地址 → 编译器放 private/scratch → 每条访问 = 一条 scratch 消息）。
- `cosine_tree_kernel.hpp`：新增 GENERATED `cosine_reciprocal_32(rv0..rv31)`（kdis/gen_cr32.py
  从原树逐 op 生成，**op 顺序与 golden 完全一致**）。
- `window_block_resident.hpp`：stage-3 的 `float hv[32]` → 32 个命名标量 rv0..rv31
  （★不能叫 hvN/hN——外层 `half* h16` SLM 指针会被 h16 遮蔽，踩过一次编译错）。
  K 的 scale==1.0f 乘法位中性（cr_hmul(half 可表示 x, 1.0f) == x）。
- `window_block_mega.hpp`：launch_full stage-3 同款（h[32]+partial/two/one 数组群）→
  `cosine_recip_esimd_32` 命名孪生 + rv 标量。★mega 体内还有**更多**逃逸数组
  （stage 计 h[32]×2、wf[64]、proj[32]、hq/hk/hv[8]、pv[8]、hv[32]/hr[32]）——只修了
  stage-3 一处，scratch 仍 2304B。**B5 前要把 mega 全部数组清干净**（逐个同款手法）。

**指标回路（固化）**：`icx ... -fsycl-targets=spir64_gen -Xs "-device dg2" <src> -o kdis/x.exe`
→ `kdis/spillcheck.py x.exe <outdir>` 打印每 kernel 的 grf/simd/slm/spill_size/private_size/
scratchB/scratchInstr。resident 核基线→首刀：**spill 4544→2400、private 1792→1536、
scratch 8192B→4096B、scratch 消息 311→266**。未归零——剩余源=其余逃逸数组
（`cosine_reciprocal(hv)` 已修，但 stage-5/7 的 probs 循环还有标量形态，weights_pair_u32
的调用点也可能；下窗口继续数）。
**★Windows MAX_PATH 坑**：ocloc disasm 的 .text.<mangled>.asm 文件名 ~170 字符，
深层目录（kdis/dep_dis_N/）下**静默不生成**（rc=0 但目录里只有 sections.txt）——
必须 dump 到短路径（如 /tmp/w1）。dep_dis_* 当初能成是因为路径恰好没超。

**验证**：mega_aot2.exe（修复后）7 区 JUDGE 全 EXACT、v4full FULL 1.086ms（vs 基线 1.082，
噪声带内）——两处修复对热路径零扰动、对 resident/mega 数值恒等（op 顺序不变）。
编译门=GREEN（bench_wbres_compile + bench_v4full 双双 AOT 编过）。
★尚未做：resident 核端到端 100%×2（它本来就没上热，等 spill 归零后再走三关转正流程）。

**13:0x 帧 A/B 判决（nr_replay_now.exe 同 dll 三路由，覆盖上面的"上热"计划）**：
默认 v4full=**113.8ms**；NR_FULL_MEGA=1（launch_full，scratch 已归零）=**~575ms**；
NR_RESIDENT_WB=1（coopmat resident，spill 修半）=**~657ms**。
⇒ **两个门后核即使清零溢出仍慢 5-6x——它们输在几何（section 92-94 一代巨型单窗 WG 核），
不是 spill。"修好再上热"路线作废；B5 融合必须在 v4full 宽-M 几何上重写，不复活旧核。**
溢出修复本身保留（launch_full scratch 2304→0 已提交 bc774a2，作为 ESIMD 手法库+样板，
将来 B5 重写直接复用这套 named-scalar/VAL-重载/sc8 分 pass 技术）。
⚠ getenv 坑：`NR_FULL_MEGA=`（空串）在 C 里是真——做 off 对照必须 unset。
⚠ walk 计时器正身 = `oneapi/nr_replay_now.exe <dll路径>`（打印 run0..3 ms / 691 passes）。
walk_plan.py 的 sigs 断言是 json(31 压缩表) vs .c(55 全枚举) 索引错位，已红，不要用它测速。

**v4full 热路径微结构（asm 直数，下一刀的靶）**：102 条 dpas 里 **90/101 对背靠背（间隙 0 条）**
——dpas 主循环已紧，XMX 发射间隙不是问题；成本集中在**少数巨型 epilogue 间隙**
（36/50 条 SLM 指令的 QKV/scores staging 段，mean 17.5 条/dpas 全被这几个大间隙拉高）。
⇒ 攻击面 = epilogue staging 的 SLM 往返与 mov 群（QKV 段 1.61ms、scores 段 1.41ms 的
giants 微梯已定位），不是 dpas 载重本身。

**spill 天花板的架构结论（11:5x，重要）**：resident 修完所有标量数组后 spill 仍 2400B≠0，
因为剩余 4 处是 `jm::joint_matrix<...layout::dynamic> acc[4]/context[4]/projected[4]`
——**coopmat 动态布局碎片是结构性 spill，编译器无法 SROA**（j 虽是编译期循环，但
joint_matrix 类型本身的存储就是 register-tile，数组化后 IGC 落 private）。
⇒ **coopmat 血统（wbres）天生带 spill 地板；ESIMD 血统（wbmega/v4full 手写 dpas）没有这个地板**。
这再次印证 §6.7-勘误：B5 融合核必须走 **ESIMD wide-M**（v4full 的 dpas 几何），不是 coopmat。
mega 的剩余 scratch（2304B）**全是可修的标量数组**（wf[64]/proj[32]/hq,hk,hv[8]/pv[8]/hv[32]/hr[32]
——见 window_block_mega.hpp stage 计），逐个同款命名标量手法可归零。**B5 开工第一子任务
= 把 mega 全部标量数组清干净、scratch→0**，这是 resident 融合上热的先决条件。

## 六.九、★★ 硬件对照账（12:4x，用户点题"落实差距"——这张表之后"硬件差"借口永久作废）

**lmxxf 的卡（RTX 3080 Laptop 150W 版，其 README 自述 48SM@1695/1605MHz）vs 我们的 A770 16GB：**

| 参数 | RTX 3080 Laptop | Arc A770 16GB | A770/3080L |
|---|---|---|---|
| 矩阵单元 | 192 Tensor(3代) | 512 XMX | 数量 2.7x |
| TC/XMX FP16(dense) | ~76 TFLOPS | **~137 TFLOPS** | **1.8x 我赢** |
| TC/XMX INT8 | ~152-168 TOPS | **262 TOPS**(Intel官方) | **1.6x 我赢** |
| FP32/FP16 CUDA | 19-21 TFLOPS | 17.2 TFLOPS | 0.85x 我略输 |
| 显存带宽 | 448 GB/s | **560 GB/s** | **1.25x 我赢** |
| L2 | 4 MB | **16 MB** | **4x 我赢** |
| 片上可配共享存储 | 128KB/SM×48≈6.1MB(L1/smem 可配) | 16KB SLM×32=512KB | 0.08x 我输(但有 4x L2 补) |
| 频率 | boost 1.54-1.71GHz | 2.10GHz | 我赢 |
| TGP | 150W | 225W | — |

**差距分解（同一网络，诚实算术）**：
- lmxxf：1080p（2.07M px）全网 11.72ms。我们：960x544（0.52M px = **1/4 像素**）walk 112.5ms
  ⇒ **等像素折算 38x 差**。
- 硬件比值：矩阵算力 1.8x、带宽 1.25x、L2 4x **都对我们有利** ⇒ 38x 差距 **100% 是实现效率**，
  没有任何一条硬件轴能解释它。"15 年前老架构"是营销话术——A770 是 2022 的卡、
  XMX 纸面就比 GA104 的 TC 快。
- 效率差的三条硬证据（都已实测）：
  ① **launch 数**：他们 82/帧（MinHook 拦截实测），我们 691/帧（plan 普查）= 8.4x；
  ② **矩阵利用率**：我们普查 batched 1.5 / qkv 2.5 / residual 1.9 TF vs XMX 峰值 137 TF ≈ **1-2%**；
     lmxxf FB04/05 纯 TC 预算 0.23-1.84ms / 11.72ms ≈ **40-50%**；
  ③ **数据搬运**：他们 fragment 直写 + plane 生命周期（不落 global）；我们中间量 global 往返
     （P1 前辈判词"round-trip global = 6.2x 主因"）。
- ⇒ **B5 战役（整帧 resident 融合）就是这条差距的正解**，不是可选项：691→~80 launch、
  利用率 2%→30%+ 才到得了 20ms 锚点。**可达性算术（保守版）**：lmxxf 实测 1080p=11.72ms；
  我们像素 1/4 ⇒ ~2.9ms；A770 TC 算力 1.8x ⇒ ~1.6ms；带宽敏感层 /1.25 ⇒ ~2ms 量级。
  即"追平 lmxxf 效率"在 544p 上是 **~2-3ms 的账**，20ms 锚点比这还松 7-10 倍——
  差距不在硬件，在 8.4x launch 数 + 2% 矩阵利用率 + global 往返这三条实现账上。
- ⚠ 旧模型修正：§一 锁的"~400GF fp16"是**我们核的实测吞吐**，不是硬件峰值；
  峰值=137TF（XMX FP16）。两数并存不矛盾，引用时注明是哪个。

## 七、交接检查单（新窗口开工先读这些）

1. 本蓝图全文 + 总蓝图 `notes/section100-blueprint.md` §7.5-7.6（★索引行在 7.5 头部）
2. 分支状态：`b1-wblock-resident`（origin），tip=本提交；部署 md5=**8ad560c2**
   （blade-1+2，游戏画面已验收 OK）；主分支 healthy-chain-resident-opt tip=12fb8f5 之前
3. bench 验收尺 = bench_v4full（7 区 JUDGE + PURE-LADDER + fill 探针 + part0 微梯）
4. WIP 封存：src/bench/sycl/bench_v5_WIP.cpp.txt（8×8 naive，勿复活——
   它的失败机制已在 §六.6-10 W2 推导清楚：dpas 半载+idle lanes）
4b. v6 开工必读 = §六.6-10 的 v6 设计 + 两条警告 W1/W2 + 方案 A/B 对拍第一步
5. 当日流水：E:/WorkBuddy/2026-10-25-22-59-21/.workbuddy/memory/2026-10-28.md（全文精读）
6. 下一步（09:3x 定案）= **v5/v6 几何线已关**（W2''/W2c giants 1.60x 判决）。
   剩余选项按 EV 排序：(1) v6.1 4-lane 树一小时快判（低 EV，见 W2c）；
   (2) wblock 微脂（V-scatter 跨 lane 配对=transpose 问题、softmax 链=golden 门）；
   (3) 接受 ~112 为 dpas/SYCL 栈的当前终点（前辈 48-62 是 coopmat/Vulkan 栈的
   产物——**架构差不是懒惰差**，§六.6-10 诚实墙）。用户裁决点=要不要打 (1)。
