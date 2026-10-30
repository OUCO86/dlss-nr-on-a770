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

**下一步（按账本证据排序，写死）** [13:5x 帧 A/B 更新——(1)(2)(3) 全部判死，别再接着修]：
(1) 修 launch_resident 的 spill（数组→命名 temp/标量链），对照 spill_size 归零 + JUDGE；
(2) 修好后 resident 核上热（撤 NR_RESIDENT_WB 门），用 703-SLM-load 供数结构 vs v4full 的
    54+156 对比，决定 B5 各层融合核的 SLM 布局规范；
(3) 再进 B5-1（QKV tail 折叠——注意 P5 证伪 nuance：tail 是 14ms butterfly 计算，
    折叠必须连带把 butterfly 也 ESIMD 化且不与 dpas 循环串行）。
**★13:5x 判决（nr_replay_now 帧尺，同 dll ec147ecb）**：(2)=657ms、launch_full=575ms、
NR_QKV_RESV2=2（连续 ESIMD tail）=126.6 vs v1 113.2 —— **三条门后路线全部帧死，
spill 清零救不了几何**。B5 唯一正确形态 = **在 v4full 自己的宽-M 几何上做跨家族融合**：
(a) quant 折进生产 gemm 的 store epilogue（B2 线，跨 kernel 的 global 中间量消除=
P1 判决原文支持的"另一回合"，不是 P8-n 的 resident 内部往返）；
(b) qkv tail 的 butterfly 用 v5a 式 4-lane 向量树（P6 v2 的"连续 item"形态已两次帧死，
别再碰）；(c) blade-3 已把 v4full 的 QKV staging 定型（48×d64x16t），B5 重写直接复用。

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

**★ density.py 全链普查（13:1x，"38x 差距"的指令级铁证）**：热家族 kernel 的 dpas 密度
（dpas 条数 / 静态指令总数）：**v4full=4.1%，gemm_b 族=0.1-0.7%，ffn 族=1.1-4.1%，
wa_res=1.0%**；TOP30 合计 57400 条指令里只有 381 条 dpas = **0.7%**。
⇒ 我们 1-2% 的 TC 利用率不是测速口径，是**指令构成**：每 1 条矩阵指令配 ~24-100 条
搬运/标量指令（movish 占 33-47%）。lmxxf 的核是 fragment 直喂 TC，这个比值倒过来。
**这坐实了 §六.九 的三条成因之②，也判死了"指令削减 2% 刀能追平"——密度差是 1-2 个数量级，
只有 launch 塌缩（把 55 次 wblock + 每 call 的 pack/gemm/tail 三段融成一个 resident 核、
让中间量留在片上）能把分母的搬运项整体消掉。**

**blade-3 实测判决（13:5x，热路径第一刀，提交 d38ed4c，新 dll=ec147ecb）**：
QKV phase-1 的 32 条 `store.slm.d64x8t`/part → 合并同行左右半成 `simd<float,32>` 单 store
（96→48 条/call，构造性位精确）。三关全过（gate 绿 / 端到端 100%×2 vs bk.1301.bin + 确定性 0 /
bench 尺 A/B **5/5 W，FULL 1.112→1.093 -1.9%**）。但**帧 A/B 5 对 vs 52f2a0c4：
均值 -0.17ms，落在 ±1ms 噪声带=帧级中性**。按 P8-k 军规保留（无负收益）。
⇒ **诚实结论（写给下一个窗口，也是给用户的直话）**：单 kernel 指令削减在帧级被摊薄
（wblock 42ms ÷ ~55 call = -0.02ms/call 清不出噪声）。**112→20 不可能靠 blade 级微脂，
必须打 launch 塌缩。blade-3 保留是为 B5 重写时这些 store 已经是最优形态，不返工。**
⚠ 用词校准（军规自查轮点破，防与 §六.6-7 打架）："launch 塌缩" = 消 kernel 之间的
**global 中间量往返**（P1 判词主因），**不是**消发射开销——cgraph 下纯发射开销实测≈0
（§六.6-7：160 个小 quant 发射藏得很好，9.05ms 里 launch-scheduling≈0）。
两个概念混着卖就是画饼，任何窗口引用这句话前先分清是哪个。

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

**链路健康自查（军规⑥要求，14:0x，防 B5 走歪——用户点名"别改着改着变不健康链路"）**：
- 结构证据：blade-3 后 nr_replay_now 仍是 **691 passes**（与基线逐 pass 同构），
  端到端 1301 字节全等 ⇒ 只改了热核内部 store 宽度，**没动任何拓扑**。
- **B5 用词澄清（钉死，下窗口不许再歧义）**：B5 的 "resident 融合" = 军规④前辈判词原文的
  "片上 SLM staging、中间量不出 global、quant 折进生产者 store"——**几何必须是 v4full 的
  宽-M ESIMD（LW=64 全载 tile8s/tile8ss，军规①）**。coopmat 血统的三个核（wbres/wbmega/
  launch_full）已帧 A/B 判死（657/575/127ms），**任何窗口不得以"resident"名义复活它们**。
- 军规②红线再抄一遍：B5-1 把 quant/norm 折进 gemm epilogue 时，**数值形态必须 VERBATIM
  现路**（qr_e4m3 链、sum 顺序、eh 步各自命名 temp——P11 教训）；要改形态先过 numpy golden
  考古，过不了就地死刑。
- 军规⑤判据在 B5 上的具体化：融合刀的判据 = **家族边际**（§7.4 第 12 条：隔离 bench 赢
  必须边际确认；cgraph 重叠吸收 15ms 的实锤在 §7.5-5）——每刀先跑 NR_Q_STOP=8/9 式
  停点探针定边际，再帧 A/B 十对。
- 部署链当前位：**a3efdf6c**（B5-1..4 dC 全歼，walk 112.5→~103-106；游戏画面验收=下次开机用户确认；回退=libxmx_b3.dll=ec147ecb 或 libxmx_v5c.dll=52f2a0c4，均在 oneapi/ 原位）。

## 七、交接检查单（新窗口开工先读这些）

1. 本蓝图全文 + 总蓝图 `notes/section100-blueprint.md` §八军规原文 + §7.4-7.6（补条与账本）
   + **§六.八 ISA 账本与 §6.8-首刀/blade-3 + §六.九 硬件对照账（10-29 新增，必读）**
2. 分支状态：`b1-wblock-resident`（origin tip=本提交）；**部署 md5=ec147ecb**（blade-3，
   691 passes 拓扑未动，1301 端到端 EXACT；游戏画面验收=下次开机确认）；
   回退位=oneapi/libxmx_v5c.dll（52f2a0c4，blade-1+2+v5a/v5c，游戏画面已验收 OK）
3. bench 验收尺 = bench_v4full（7 区 JUDGE + PURE-LADDER + fill 探针 + part0 微梯 + GIANT 梯）
3b. **帧尺 = oneapi/nr_replay_now.exe <dll路径>**（run0..3 打印 ms/691 passes；
   NR_DUMP_OUT=<前缀> 产 .1301.bin 对 bk.1301.bin；env off 必须 unset 不能置空串）
3c. **ISA 回路 = kdis/spillcheck.py <AOT-exe> <outdir>**（grf/simd/slm/spill/scratch 账）
   + census.py/gapmap.py/loopmix.py/density.py；AOT 配方在 §六.八（gen 管线只在链接跑）
4. WIP 封存：src/bench/sycl/bench_v5_WIP.cpp.txt（8×8 naive，勿复活——
   它的失败机制已在 §六.6-10 W2 推导清楚：dpas 半载+idle lanes）
4b. v6 开工必读 = §六.6-10 的 v6 设计 + 两条警告 W1/W2 + 方案 A/B 对拍第一步
5. 当日流水：E:/WorkBuddy/2026-10-25-22-59-21/.workbuddy/memory/2026-10-29.md（全文精读）
6. 下一步（14:0x 定案，与 §六.6 B2 判决对齐——**NR_Q_FUSE 早已默认开（P2 288/448 溶解），
   take_b 两次判死，B2 已降级"~2-3ms 残肉+高手术成本"，别再拿它当大肉画饼**）：
   (1) **B5-1 = qkv 家族（帧账 27.6ms，未被 B2 判决覆盖）**：先给 qkv_norm_scatter_esimd
       本体上 v5a 式 4-lane 向量 butterfly 树（纯 kernel 内形态，不碰拓扑；⚠ "连续 item"
       v2 形态已两次帧死 127 vs 113，勿再走）→ 立 NR_QKV_STOP 边际探针定刀值 → 三关+帧 A/B；
   (2) **B3 = wblock 指令数战（v4full 自家几何，blade-3 是第一刀已定型 QKV staging）**：
       gapmap 还剩 scores 段 16×d64x8t、attnV/outproj 段 store16s 群没砍；
       mov=875/体的构成继续拆（loopmix 已入库）；每刀 JUDGE+边际+帧 A/B；
   (3) B2 残肉（生产者内嵌 -2ms 上限）排最后，动 5 个 gemm 族 epilogue 的成本高，
       等 (1)(2) 出账后再裁决。
   ~~接受 ~112 为终点~~（永久作废，用户 10-28 判决 + §六.九 硬件账双重死刑）。

## 六.十、B5-5 解剖图（17:3x 普查，下窗口直接开工用——今天的 dC 全歼已游戏验收）

**幸存结构税最后一层 = pack 腿 + 接力 plane**（dC 已死，别再找它）。实测+普查钉死：
- 三族同删上限（NR_WB_STOP=0 NR_WA_STOP=9 NR_WRES_STOP=2 交错三对）= **-24.7ms**
  （sync 加和 58.8 的 42% 被 cgraph 吸收——军规⑫再实锤）。其中纯 gemm/softmax 计算
  ~15ms 融合消不掉；**真结构可回收 ≈ 7-10ms** = pack 腿 + launch 塌缩 + plane 往返。
- qkv 内部分段（NR_QKV_STOP 三态）：pack 腿 ≈ **6ms**（stop1-stop2），gemm+tail ≈ 7.5。
- take_b（消费者内嵌 quant）在新结构下重测仍 **-14ms**（124-127 vs 110-113）——
  **三连判死，永久封存，任何窗口勿再试**（pack_a 内嵌量化的串行代价是根，与 cgraph 无关）。
- 幸存 160 发 quant 的 src=1307/1295/1280/1282/1292/1298/1271/1303 = **游戏导入的
  图像金字塔平面**（plan 里无 recorder 写者）——它们不是往返税，是输入本身，消不掉。

**B5-5 的正确刀形（已解剖，含一个陷阱）**：
wres 的 pack 腿 = pack_a_fused（**行主序** 1270→dAp），qkv 的 pack 腿 =
pack_a_fused_gather（**gather** 1270→dAp）。两者映射不同 ⇒ **dAp 不能直接复用**
（我差点按"结果复用"接线——映射对不上就是帧 0%，停手了）。正解两选一：
(a) wres epilogue 直出 gather-tiled int8+scales（qres 同款 SLM dead-operand 行归约，
    ~90 行 kernel + fold-slot 接线）——消 qkv 的 120 发 gather pack（-6ms 级）；
(b) 前辈真形 = 每层一个核（wres+qkv+wa 三合一），pack 腿整体不存在——大工程，
    建议先 (a) 后 (b)，(a) 的 gather-tiled store 机制就是 (b) 的积木。

## 六.十一、B5-1..4 完整性审计 + B5-5 设计定案（17:4x，用户"不留返工尾巴"核查轮）

**审计结论：dC 往返层已清，且与前辈形态同构**。逐刀边界（下次别当"没弄完"重挖）：
1. B5-1 qres：guard `C%64==0 && NH==3C && heads==C/32` = 帧内 120/120 全覆盖（含 vit）。无尾巴。
2. B5-2 gemm-f16 fold：82/84 覆盖。**唯一 dC 残留 = 2 发 compact（N=16/ldc=4 head 形）**：
   gemm_b_pub_f16 的 BN=64 tile 几何装不下 N=16（tile 半空 = 违反军规①宽 tile），
   dC 仅 32KB/call 且 L2 热。**裁决：保留 split 是几何正确，不是偷懒**——若将来
   head 形改宽（N>=64 合并），此 2 发自动进 fold。别再为它写特化核。
3. B5-3 chipres(epi0/!narrow guard)=帧内 ffn/stem/merge 全形状覆盖。无尾巴。
4. B5-4 GA fold：rows%16==0 帧内全部满足。无尾巴。
5. **幸存 160 发 quant 归因结案（今天新证）**：pk=1305/1312 是**引擎内部 scratch
   （buffer 表只到 1301，1302+ = init/pre 家族的运行期内部缓冲）**，且 1305 被
   batched144+residual104+qkv104+wres104+int8-32 **多消费者共享**——一个 pk 平面喂
   5 族不同 (M,K) 视图 ⇒ tiled 直写满足不了所有消费者的 tile 布局（一个平面只能按
   一种 K 切块）。**⇒ 这 160 发不是往返税，是共享输入平面本身；消它=改游戏侧缓冲
   复用=plan/bridge 禁区。我写的 tiled-quant 变体核因此无接线点，已撤销不留死码**
   （git checkout，树干净）。
6. take_b 新结构下重测仍 -14ms ⇒ 消费者内嵌 quant **三连判死永久封**（§六.十）。

**B5-5 设计定案（开工序写死，下窗口直接建，不再解剖）**：
- 靶 = **每层 wres+wa 二合一**（104+104 发 → 104 发；wb 只有 20 发且已 resident，
  二合一后再并入 = 前辈 window_block.comp 三合一形态）。
- 几何对齐（已核）：wres WG = BM128×BN64 tile（N=64 层行完整在一个 WG ⇒ 行 peak
  可在 epilogue 内算，无跨 WG）；wa WG = 1 window(batch) 64 tokens ⇒ **一个融合 WG
  = 2 windows**（wres 的 128 行 = 2×64 token 行，行序 window*64+token 天然对上）。
- SLM 预算（64KB 帽内）：wres operand 双缓冲 32KB + 行峰/scale 尾 2KB +
  wa 的 Z(probs staging)——**复用 wres 的 dead operand 区**（qres 同款 aliasing，
  B5-1 已证形态）：acc f32 落 SLM → wa scores gemm 直接吃（Q/K/V=acc tile 的
  head 切片 = qkv 已折叠进 wres epilogue？不——qkv 的 B 是权重，A 是 1270：
  正确链 = wres epilogue 顺手做 gather-tiled int8 直出 dAp（N=64 层行完整 ⇒ 可fold），
  qkv 的 pack 腿与 1270 f16 plane 双双消失 → qkv gemm 的 acc 直接进 wa 的 SLM。
- 预期（诚实）：消 1270 plane 往返（0.66GB/帧）+ 104 发 pack + 104 launch
  = 帧内边际 **-7~10ms**（三族同删上限 24.7 里 gemm 计算本体 ~15 不随融合消失）。
- 门 = 新 bench_layer_fused：split 链 (wres+qkv+wa) vs 融合核，Q/K/V/Out 逐字节对拍；
  GEMM_WINDOW_INT8_RESIDUAL + INT8_QKV + WINDOW_ATTENTION 三门现成判官。
- pad≠0 的 78 层 = 最大难点：out-of-bound 行 wres 现在 continue 跳过不写 1270，
  融合核里这些行必须**照 gather-pack 语义写零行+scale 1.0**（不是跳过）——
  这是当年 131/8192 同族坑，开工第一件事就是门里放 pad 层（416×236 那 12 层）。

## 六.十二、层链全解剖（17:4x，plan 序列 2586-2661 逐 call 实读——B5-5 的最后一块拼图）

**每层真实链（N=64 窗口层，plan 原文 dump）**：
```
quant(1277→1272)  ─┐ 被 wres 的 take 溶解（pack_a_fused 读 1277）
wres(1272→1270)    │ 6 发真 launch：wres/batched/batched/residual/qkv/wa
quant(1270→1272)  ─┤ 被 batched1 溶解                        + 6 发 pack 腿
batched→1274       │                                        = 每层 12 发
quant(1274→1272)  ─┤ 被 batched2 溶解
batched→1275       │
quant(1275→1272)  ─┤ 被 residual 溶解
residual(skip=1270)→1267
quant_window(1267→1272) ─┐ 被 qkv 的 gather-pack 溶解
qkv→1274/1275/1276       │
wa→1277 ─────────────────┘
```
**dC/quant 层已全歼**（448 quant 里 288 溶解 + 160 = pyramid 输入不可消）。
**剩下的最后一层结构 = 每层 6 条 pack 腿**（pack_a_fused：读 f16 平面→行峰→量化→
tiled 写，一条独立 launch ~0.02-0.05ms；全帧 pack 腿合计 ≈ 8-12ms sync）。

**为什么 pack 腿不能顺手折进 gemm（两面墙，今天实证的）**：
1. **行峰跨 WG 冗余墙**：gemm 的 A 行被 N/64 个 wg_col 重复读；行峰要整行
   （K=2048=4KB/线程）⇒ 每个消费者重算一遍峰 = take_b 三连判死的根。
   前辈解法 = **生产者直写 tiled int8 + scale**（峰只算一次，生产者持有整行）。
2. **生产者直写的覆盖面墙**（逐边界核过）：
   - wres(N=64)→batched1：行完整在 WG、行序 window*64+token == pack_a 的 srow
     （无 gather）⇒ **可折**，但只覆盖 16/104 发（N=128/256/512 的行跨 2-8 个
     wg_col = 撞墙 1）；
   - residual→qkv：residual 出行 32640（510 窗）vs qkv 需 35712（558 窗，pad 金字塔
     扩窗）= 行集不同 + gather remap ⇒ **不可直写**（quant_window 的 gather 就是为它存在）；
   - wa→quant→wres：wa 的 Out 行 = window-major，wres 的 pack 消费它 K=64 ⇒ 可折
     （行完整），但 wa 的 BN=32 尾部分片跨 2 个 wg ⇒ 撞墙 1 变体。

**B5-5 终裁决（写死）**：pack 腿的完全消亡 = **前辈每层一核**（wres+qkv+wa 一个
resident WG，中间量全在 SLM，无平面无 pack）——这是 B5-5b，一个 ~400-600 行的
新核工程，门=bench_layer_fused 逐字节对拍 split 链（先放 pad 层=131/8192 同族坑）。
**今天不硬开**：解剖已完整、设计已钉死（§六.十一+十二），下窗口直接从
"gate first, then 400 lines" 起步。在会话尾端盲写大核 = 制造下一次证伪，
比不写更贵。

## 六.十三、BLADE-4 密度刀（18:3x-18:5x，用户"代码本身还有很多要改"点破后当轮落地）

**用户的判词是对的**：结构刀（B5-1..4）之外，density 账本（dpas 0.1-0.7%）指的就是
**代码质量**。最大的一坨：residual 两族（帧内最大家族，sync 46ms）的 fused store
把 pub 链写成 **256 次/线程的标量 pub_esimd 调用**（gate+e4m3 每次 15-30 条指令
≈ 5000 条 epilogue 指令 vs 8-32 条 dpas）——而 bench_pubvec 已证的向量孪生 pub_vec_v8
就在同一个文件里没人用（section-92 时代的保守遗留）。
**刀**：fma 表达式逐元素原样保留（尊重 "别向量化 res 的 fma" 警告——simd 版
sk*c+f 降成 muladd=两次舍入=帧 0%），只向量化 PUB 步（epi!=2 守卫，帧 res flags
0x41100→epi1 在已证位精确集内；epi2 留标量 -0.0 路）。四站点 gemm_b_res x2 +
gemm_b_res_window x2；gemm_pub/pa16 标量循环同加守卫（逃生舱一致性）。
**三关**：1250 ok 全绿（GEMM_INT8_RESIDUAL/WINDOW_INT8_RESIDUAL/f16-residual 独立
numpy 判官）+ 端到端 1301 EXACT x2 + 确定性 0 + **帧 A/B 3/3：107→85 = -22ms**。
**walk 战役总账：227 → 112.5 →（dC 全歼 -10.4）→（blade-4 -22）= ~85**。
三族删除上限复测 24.7→**12.4**（blade-4 把三族 12ms 标量税直接消掉，剩下的是
计算本体——融合也不再省）。部署位 work/libxmx.dll = **0b0075e1**（游戏验收=下次开机）。
**教训入册（军规⑬候补）**：普查账本里"密度异常"= 代码质量异常，每个 0.x% 的家族
都要按"这个 epilogue 是不是标量循环"过一遍——下一个同类靶：f16v1 gemm_b 族
（9214 指令/9 dpas，movish 4320——先数标量 pub 循环占比再开刀）；batched 族
gemm_b_pub 已用 pub_vec_v8 但 density 仍 0.3-0.6% = 靶在 pack/load_block 的
select/join 群，不是 pub。softmax 的 64 步顺序 ef_add = golden 序不可向量化
（位精确红线），别再打它主意。

## 六.十四、硬件对照账修订（19:3x 用户新证：lmxxf 的 3080 是笔记本版）
**lmxxf 参考机 = RTX 3080 LAPTOP（≈ desktop 3070 略强），不是台式 3080。**
重算 §六.九 的对照：台式 3080 ~30 TFLOPS f16 / 936 GB/s；**笔记本 3080 ≈ 18-20 TFLOPS
/ ~760 GB/s**（GA104 cut-down，功耗墙）。A770 = 37.5 TFLOPS f16 / 560 GB/s。
⇒ 对手算力只有我们的 ~一半、带宽略高；11.7ms 的 lmxxf 帧折算到我们的算力预算，
**我们 76.9 的差距比之前算的更大、更没有硬件借口**——用户判词"弹药相同硬件占优还输"
在笔记本 3080 事实下更强成立。这把 B5-5b + 供数寻址战从"追平"抬到"应当碾压"，
优先级再上调。已入流水。

## 六.十五、B5-5b SLICE 1（lfw=qkv+wa 每窗口一核）：已建通、仪器全绿、帧账负、退回探针（21:5x-22:2x）

**用户的批评成立**：我写 lfw 核时凭 qres/wa_res 源码镜像推几何，没先读归档
（refs/a770-skill + notes/dpas-resident-findings.md）。归档里两条直接命中：
① §96 探针矩阵（plain kernel 里 SLM-fed dpas 静默归零；ESIMD nd_range + global
scratch + group_barrier 才安全——我的核是 SYCL_ESIMD_KERNEL+slm_init，属已证安全类）；
② **wa_res 头注释里就写着"WA_KT 2KB sizing OVERLAPPED QT = 半行错，gate 抓的"**
——我犯的正是同族坑。教训：写新核前先把归档 notes 的坑名单过一遍（已在做，这次没做够）。

**做了什么**：lfw_res_kernel.hpp（qkv gemm BM64/NT16 + v5a tail + blade-7 宽消息
tile gather + wa_res stages1-3 全在一个 WG=一 window）+ recorder P2 式配对
（stash→confirm→qkv 闭包 no-op→wa 闭包跑 pack+launch_lfw）+ **bench_lfw.cpp 仪器**
（对照=qres 出 planes + wa_res 消费——wa_res 转正同款纪律）。
**调试完全靠仪器**：首跑 planes 全 EXACT（NT16 新几何对）、Out head-1 全错 →
一眼定位 SLM 区尺寸（每 tile 区要 2×4KB=8KB，我照 wa_res 的 4KB 抄——它的 WG 只
装一头，我的装两头）→ 修 QT/KT/VT=32768/40960/49152、SLMB=57344（56KB，还在
64KB 桶=v4full/wa_res 同桶不损驻留）→ **bench_lfw 8/8 EXACT（两帧形状 planes+Out）**
+ 全门绿 + walk 1301 EXACT。

**帧判决（诚实）**：交错 A/B 4 对 = 3 负 1 正（+0.5 均值，带内偏负）。根因=
**WG 并行度**：融合核 510-558 个 WG 串行走 qkv+attention 全链 vs split 链
768(qkv)+1020(wa) 个 WG 的 GPU 级并行——cgraph 下 split 的两核还能互相重叠。
**SLICE 1 不转正**（默认 OFF，NR_LFW_FUSE=1 探针保留，代码在树里是已证仪器资产）。

**SLICE 2 定案（下刀形已想清）**：WG=一 (window,head) batch（1020-1116 WG，并行度
与 split 持平），qkv gemm 只算该 head 的 BN=32 列带（dpas 半宽=损失 1/2 tile 效率，
但 plane 写只写自己 head 的 slice=与 wa_res 的 batch 语义天然对齐），tail 用 v5a 树
（32 列正好=一棵）。预期：并行度不再输 split，省下的=1 launch + QK plane 的
gather 重读（1274/75 只在 fused 内存在；1276 V-plane 保留给下游 batched2 读=半消）。
bench_lfw 仪器已就位（改 reference 链即可对拍），pad 层雷不变。

## 六.十六、B5-5b SLICE 2 判决：qkv+wa 融合在 cgraph 下二连不转正（07:50-08:2x）

lfw2_res_kernel.hpp（WG=一 (window,head) batch，BN=32 半宽 qkv gemm NT=16，
v5a tail 双写 plane+tile，blade-7 gather，wa stages1-3 VERBATIM）：
- **bench_lfw2 8/8 EXACT**（两帧形状 planes+Out 零差）——几何全对，slice 1 的
  并行度批评（510 fat WG）已按定案修掉（1020+ WG 与 split 持平）；
- 全门 1250 绿 + 端到端 walk 1301 EXACT + 16 层配对确认（NR_LFW_DBG printf）；
- **帧 A/B 7 对 = +1.5ms 均值偏负**（干净 5 对 +0.5/+1.7/+0.6/-0.2/+0.5，
  pair6 的 +10.4 是热漂移弃用）。**不转正**（默认 OFF 探针保留，与 slice 1 同格）。

**结构性结论（两 slice 合读，写死防第三次回头）**：qkv+wa 融合的收益账在今天的
代码状态下已经**不值**——split 链上它俩的剩余成本只剩 (a) 2 发 launch/cgraph 下
已 ~µs 级、(b) plane 写读（但 plane 必须写：下游层链的 quant 读它们=bench 实证）。
融合付出去的是 BN=32 半宽 dpas（tile 效率减半）+ 每 WG 串行 stage 边界。
**lmxxf 82-launch 快的根因不是 launch 少，是每个核的形态效率高**——我们的下一层
收益在 B3 形态战（v4full 4.5% 热循环密度 vs 他 40-50%：宽 tile/更深 K 循环/
SLM 消息数），不在继续融合 qkv+wa。B5-5 家族到此关门（dC 全歼=结构清零已兑现，
融合片=已建已证不转正）。三族同删 12.4ms 上限里真正可回收的部分需要的是
"更快的 gemm 本体"，不是"更少的核"。

## 六.十七、"双WG异构分治+跨WG SLM接力"提案判死（08:2x，外部 AI 方案，三条硬墙全部来自自家归档实测）

提案：DPAS 满宽 WG 池(768) + attention 轻量 WG 池(1020) 同 launch 异构，
"跨 WG SLM 环形缓冲"接力，声称净赚 3-5ms。判死依据（无需新实验，归档就是铁证）：
1. **SLM 是 WG 私有**：§96 bench_srcmodes D/F 探针证的是同一 WG 内跨 SUBGROUP 可见；
   归档原话 "stage handoff through GLOBAL per-window scratch"。XE_HPG 无 cluster
   distributed shared memory（那是 NVIDIA Hopper 的东西）。跨 WG SLM 通路不存在。
2. **同 launch 双池接力需要 device-wide barrier → spin-wait → 共驻容量算死**：
   768x32 + 1020x16 = 40896 线程 > A770 并发容量 32768（32 Xe-core x 1024）→ 必死锁。
   与 §96 DEVICE_LOST 毒同源。
3. **plane 不可省**（bench_lfw 调试实锤：planes=本层输出+下层 quant 输入，必须写）。
且提案的"目标态"（BN=64 满宽 qkv 池 + 1020 attention 池 + 并行度对齐）**就是现役
qres+wa_res 链本身**；增量机制不存在 ⇒ 3-5ms 无来源。两条真融合路（slice1 胖 WG、
slice2 半宽）都已实测帧负 ⇒ B5-5 家族关门是数据判决。
**军规自查（满宽高并行=健康）：现役链无违规**（qres BN64x768 ✓ wa_res 1020 ✓
v4full ✓ batched/residual BM128xBN64 ✓）。差距本体=核内 dpas 供数形态
（热循环 4.5-5.2% vs 前辈 40-50%）⇒ 下一战场 B3：v4full/gemm 家族热循环的
mov 群 980 / SLM 消息 171 vs dpas 112 —— 更深 K 循环、GRF 常驻、每 dpas 摊更少
SLM 消息。纯核内手术，门+交错 A/B 判生死，不碰链路结构。

## 六.十八、b3-2 实验判决 + "寄存器广播"提案裁决（09:0x-09:2x）

**b3-2 实验（已做已回退，未提交）**：s8v8 全 8 站点 A 侧去 SLM 改 direct-global
读（L1 预取假说）。三关全过（1301 EXACT）但交错 A/B 4 对 = +0.4 中性偏负
（无一赢对）=> git checkout 回退，基线 74.7 复验。**结论：A 侧 SLM staging 留着。**

**外部参考的 L1 合并诊断**：采纳其现象解释（4x 同址散读重发有真实代价，与
+0.4 一致），但其硬件数字（"每周期合并 2 个同线请求"、"延迟翻 3-4 倍"）未经
本机 PM 证实，标 unverified。

**其处方"单线程宽 load + subgroup 寄存器广播"= 判死，两条自家铁证**：
1. **本工具链没有公开的 subgroup 寄存器交换原语**——§20 归档注（quantize_row
   header line 10："this toolchain has no public sub_group.shuffle_xor"），当年
   quantize 行归约正是因此改走 SLM+barrier；全仓 grep esimd::shuffle = 0 命中。
   "GEN 原生广播指令"在 SPIR-V GEN 后端存在但公开 API 不可达——不是没用它，
   是用不了（这正是当年绕过 joint_matrix 时探过一遍的边界）。
2. 引用出处更正（09:4x 用户澄清）：`src/dlss5nr-b580/` = **病态链路时代的姊妹
   移植项目**（B580 卡），其 L1/bank grep 命中的全是 AMD 审计文档——即便其中有
   延迟数据也属于另一卡另一链路，不搬进 A770 账本。用户裁定：B580 仅在 A770
   路穷尽后作最后参考。提案引用它当"已证事实"仍属跨项目挪用，判死依据不变：
   核心=工具链无公开跨线程寄存器搬运原语（§20），与本条无关。

**b3-2 回退后真正的密度账（本次分析落盘，B3 的正解方向）**：s8v8 每 kb 每 subgroup
SLM 读 = 32KB（A 16KB：每 band 被 4 个 wi_col 线程重复读 4x；B 16KB：被 8 个
wi_row 线程重复读 8x），unique 只有 6KB ⇒ **5.3x SLM 读放大**，SLM 带宽 ~2x
压过 XMX 吞吐（4dpas=32cyc vs 32KB@~512B/cyc=64cyc）——这才是 4.5% 密度的本体。
NT=16 减冗余已算死（累加器 2KB/线程=GRF 满→spill）。正解方向 = **GRF 常驻操作数**
（B=权重整个 K 段驻 GRF，SLM 只走 A：per-kb SLM 读 16KB 而非 32KB）——这是
bench_s8v2 级形态实验（新 fragment 布局），不是 dll 里的快刀；先在 bench 仪器上
打，三关+交错 A/B 判生死。

## 六.十九、★两张地图终结试错框架（09:4x，演绎链落盘）：帧是 MEMORY-BOUND，不是密度问题

**腿账地图**（cgraph 墙钟边际，B3-1 基线 74.0-74.3，单次读数）：
quant 全删 -6.9 | gemm-f16 全删 -7.2（pack 腿 5.4 + gemm 1.8）| wa -3.5 |
**batched 全删 +0.7、qkv 全删 +7.0（删计算核帧反而慢=全藏在重叠下）** |
residual/wres pack 腿 ≈0（已吸收）。
**流量地图**（plan 缓冲表逐 call 读写计）：名义 60GB/帧，DRAM 地板 107ms>实际
74ms ⇒ L2 吸收过半，**帧在内存侧**。流量前四=residual 10.3GB/quant 8.8GB/
wres 8.2GB/qw 7.9GB。

**框架修正（写死，防再追错指标）**：§六.九"前辈 40-50% vs 我们 1-2%"是**量纲错位**
（他们=TC 时间占帧份额，我们=指令密度）。腿账证明 dpas 密度不在关键路径上——
**关键路径=quant/f16-pack/wa 三条 memory 腿**。blade-4 赢 22ms 的真实机制=砍掉
标量 store 群的发射+L2 压力（不是"喂饱 dpas"）。密度账本降格为次级指标。

**B3-2 由地图指定（非试错）**：quant 家族 -6.9ms 关键路径。160 幸存=pyramid
输入 f16→int8（pk 共享不可 tiled=§六.十一），但**核本身是纯带宽件**：我们
187-357GB/s（§99 普查）vs 前辈 staged 表 374GB/s ⇒ 1.7-2x 差距在 K=64/128/256
档的 f16 平面读模式。仪器=bench_qv3 现成。路径：单形状对前辈表 → 家族边际
（Q_STOP=9 已给上限 -6.9）→ 帧 A/B。

## 六.二十、前辈表的硬件出处钉死（09:4x，用户的耻辱判词 + 归档铁证）

improve-b 的 staged 表（3742GF/0.071ms 那组）+ "30-45 GB/s vs 70-91 天花板"
= **Lunar Lake 核显上测的**（coopmat-table.txt 探针：device "Intel(R) Graphics (LNL)"、
Mesa ANV、Linux；本机 A770=560GB/s+262TOPS 独显）。⇒
1. "单核 gemm 只差 1-1.5x"不是好消息——**独显对核显打平=实现质量耻辱线**，
   前辈表是 FLOOR 不是 TARGET（A770 上 gemm 应数倍于该表）；
2. 前辈在 90GB/s 机器上把帧跑到 11.7ms@1080p，我们在 560GB/s 机器上 74ms@544p：
   带宽预算 6x、像素 1/4 ⇒ 差距全部是实现，与 §六.九 结论一致、现在更刺眼。
3. 腿账地图（§六.十九）+ 本判词合读：memory 腿（quant -6.9/f16-pack -5.4/wa -3.5）
   先砍=帧账直接收益；gemm 核级差距=第二战场（bench_batched 表已给 Floor）。

## 六.二十一、腿账第二版 + U 系三刀 + ffn 阶梯（10:3x-11:2x）

**腿账 v2（三复现稳）**：BASE 68.3-69.6 | quant -6.1 | f16-pack -5.0 | wa -4.6 |
**ffn -11.4**（阶梯：chip-vs-split +3.8、tile-vs-twopass +25、chipres +1.5——
两次形态换都赢过；chip 核自身 bench_ffnchip=106-135 GB/s vs 前辈 374=腿的大头） |
unary -7.5 | stem -7.6 | merge -4.9 | gemm 本体 ≈0。

**U-1（E4M3_HALF 18.5M 元素 SIMD16 化）16 对 12 赢 -0.50 转正；U-2（UPSAMPLE_ADD
8.0M）+U-3（POOL2 3.9M）合测 16 对 13 赢 -1.16 转正（U-3 增量带内=P8-k 留形）**。
unary 家族 24M/30.6M 元素已向量化。判官=UNARY_KINDS 独立门（帧的 kind 全覆盖）。

**ffn-1（chip HS staging 16B 对 → 32B join，256→128 条窄 store/tile）**：门绿+1301
EXACT，16 对在跑。**ESIMD 核内禁 non-const static（§96 再证）**——开关必须 host
捕获参数（fjoin 走 launch_ffn_chip 尾参）。

**16 对协议正式成为 <4ms 刀的判定标准**（4 对被 ±4 噪声带淹；16 对均值 0.5+ 且
赢≥10 = 转正；±0.3 内 = 真中性）。噪声三源（用户归因，采纳入册）：boost 动态调频
（非温度）、cgraph 帧间调度间隙、L2 冷热波动——腿账隔离口径天然避开三者。

战役账：112.5 → 74.5（昨日收）→ **68.3-68.5（今）**：PAF -0.5 + U系 -1.2 + ffn-1(待判)。
距 50 = 还差 ~18：ffn 腿剩余（chip 核 106→374 GB/s 形态战 = 最大单块）、
wa -4.6、quant -6.1、f16-pack -5.0 的核级账。

## 六.二十二、★★ 真正的问题钉死（11:4x，用户的质问命中）：帧=plane 搬运屋顶，B5 结论要修正

**流量账**（plan buffer 图逐 call 读写计数）：60.3GB/帧。前三大往返：
- buf1267（residual 主平面 66.8MB）W122×R278 = **26.7GB**
- buf1274（33.6MB 输出平面）W264×R258 = **17.5GB**
- buf1272（pk scratch 17.8MB）W488×R488 = **8.9GB**
**写下限 19GB=34ms，写+一读=38GB=68ms ≈ 当前帧时** ⇒ 帧贴在 plane 传输屋顶上；
blade 级核内优化只能在屋顶上削 10-15ms 的发射/延迟开销（今天 U 系/PAF 的账正是
这个量级）。**50ms 及以下必须删往返本身。**

**§六.十六 结论修正（诚实）**："融合不值"只对"两 op 融合+保留 plane 双写"成立
（slice1/2 的实际形态）。前辈 82-launch 的根因不是核快 4 倍，是**每层一 mega-kernel、
层内中间量不出片上**（全网 ~5GB/帧量级）。B5-5 家族不该关门——该开 **B6：
每 window 整块 resident 核**（quant→qkv→wa→outproj→residual→ffn 一核，
plane 只在层边界存在）。

**B6 算术（可行性先过）**：64-token 块链上片上足迹 pk 4KB + qkv tiles 12KB +
scores 16KB(Z) + probs/attended 8KB + outproj A-tile 4KB + ffn hidden 8KB +
skip 流水读 ≈ **55-65KB → 64KB SLM 桶装得下**（v4full 已在 45-56KB 桶跑通）。
每层流量：现在 ~6 plane 往返 ≈250MB/层 → B6 后 = skip 读+写 ≈134MB/层，
**全帧 60GB → ~30GB**（再叠 ffn 融合则 ~25GB）⇒ DRAM 屋顶 68ms → **~45-53ms**。
这就是 <50 的唯一路，也是最终目标的路。

**已证积木全部复用**：lfw2 两 phase（bench_lfw2 8/8 EXACT 就是 B6 的 phase1-2！）
+ s8v8::gemm_b_res（outproj+residual 折叠，转正件）+ ffn_chip 两 gemm（转正件）
+ fused-quant publish（take 机制）。B6-1 = bench_b6 仪器：lfw2 核加 phase-3
（attended→e4m3 rowmax quant→outproj gemm（SLM A tile）→deq+skip fold→写 1267），
对拍=现链 wa+quant+outproj+residual 四件套。
