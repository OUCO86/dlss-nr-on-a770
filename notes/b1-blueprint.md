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

## 二、v5 = 前辈几何（本战役主刀，设计已钉死；几何账已算清）

**v5.1 几何算术（本轮已定，写码照此）**：8 subgroup × 8 行（LW=128，SIMD16）。
每 part = 8 行×32 列 = 两个 8×16 tile（c00,c01 + 第二 tc）= **4 dpas（v4 是 8）**，
活跃 acc = 4×simd<float,64> = 16 GRF（安全线内）。scatter 的 (r,c)→pb16t/pb16/sh16
map 不变（r=全局行 0-63）。**注意：QKV/scores/attnV/outproj 共享 subgroup ownership，
v5 必须整核同几何——不能只改 QKV 段（ownership 不一致则 scr/操作数域错位，
7 区 JUDGE 会红但那是半迁移不是 bug）**。这决定 v5 是一次完整重写（~250 行），
不是增量刀——按 §三 施工序 v5.1→v5.4 分阶段在 bench 里推进。

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

## 三、施工序（每步独立转正/回滚，三关照旧）

- **v5.1 bench 原型**（bench_v4full 里加 launch_v5，7 区 JUDGE 全绿才算成）：
  先只改 QKV 段到 8×8 行 + shuffle epilogue；scores/softmax/attnV/outproj 暂留 v4 形态
  （跨段接口=QPO/KTO/VPO map，不动）。预期 QKV 0.518→~0.30。
- **v5.2 后四段 8 行化**（scores 起，逐段 JUDGE）。预期 FULL 1.216→~0.75。
- **v5.3 真库接线**（window_block_v5.hpp + 路由 env NR_WB_V5，默认先 OFF 走 A/B），
  v4ph 同法跟进（giants 走 v5ph）。
- **v5.4 帧 A/B 转正** + 逃生舱 NR_WB_V5=0 + 部署入账。
- 回滚纪律：任何一步 JUDGE 红/三关红=当场回滚不过夜（军规⑤）。

## 四、收益账（诚实区间）

- bench 线：FULL 1.216→0.75-0.9（v5.2 后）；giants 4.51→~2.8-3.3
- 帧线：wblock 42.7 → **~25-30**（-13~18ms）→ walk **~100-104**
- 前辈同级 6.2ms 是 768x448 的 10 pass 账，我们 960x544 的 20 call 同级折算 ~12-15ms
  ——**v5 打满=追平前辈这一族**；打不满的部分留给 v6（barrier 流水/链再砍）。

## 五、已排雷清单（v5 不许再进的地雷）

1. 半 store / 字节优化（P8-r：指令数才是货币）
2. 32-reg hoist（P8-g/g2：≤16-reg 预筛线）
3. mega 式消 L2 内往返（P8-n：边际不降=流量不在关键路径）
4. 占用/LW 加减 WG（P8-o：边际 9.0 vs 9.0）——**v5 的 LW=128 不是为了占用，是为了链深**，
   且 SLM 必须 ≤32KB 保住 2 WG/SM（45KB 的旧 map 在 LW=128 会掉到 1 WG/SM——设计已避开）
5. 动态索引拼装 A-map（P8-e/§7.6：常量偏移 + JUDGE 逐区对质）
