# one frame, all the way down (2026-10-10)

`src/bench/frame_ledger.py` records one real frame with every runtime method hooked,
keeps the part of the graph that asked for each one, and then replays it with the
device's own timestamps on. Device 36.41 ms, 723 passes, 717 Python calls.

It runs in about **90 seconds**, including loading a gigabyte of weights. A run that
takes much longer than that is stuck, not slow: one took 33 minutes and never finished,
and the fix was to kill it and start again.

## the trap: a script that is not the daemon runs with the integer path off

`xmxres.Runtime` reads `NR_INT8_PROJECT`, and **its default is `"0"`**. The daemon is
what turns it on — it reads `int8` out of `work/nr_settings.json` and injects the
variable before the runtime is built. A benchmark that builds its own `Runtime`
therefore measures a configuration no game has ever run.

It does not announce itself. The two configurations:

| | integer path **off** | integer path **on** |
|---|---|---|
| device | **43.49 ms** | **36.41 ms** |
| passes | 415 | 723 |
| projections come out of | `nr_resident.py:429` (`gemm_residual`) | `nr_resident.py:422` (`gemm_int8`) |
| `gemm_int8` in the ledger | none | 188 |

The float graph is *fewer passes and slower*, which is exactly what "the integer path
adds a quantise and a scale to every product" should look like. The tell is the
presence of `gemm_int8`, or the absence of it.

`src/bench/game_settings.py` sets the eight switches the daemon injects; every
standalone benchmark should call `game_settings.apply()` before building a `Runtime`.
`NR_INT8_TRANSITION` is `0` there on purpose — measured, no gain, left off.

## where the device's 36.41 ms goes

```
family    ms   share      n   ms/pass
gemm    13.94   38.3 %   198     0.070
row      9.54   26.2 %    70     0.136
tiled    8.50   23.3 %   130     0.065
unary    4.45   12.2 %   325     0.014
```

and by kind:

```
tiled/0    8.50  130 passes  0.065 ms/pass   the float16 products
gemm/30    8.41  188 passes  0.045           int8 GEMM, staged
row/4      6.20   10 passes  0.620           window_block
gemm/31    5.53   10 passes  0.553           ffn_fused / _merge / _stem
row/3      3.00   52 passes  0.058           window_attention
unary/5    2.38  120 passes  0.020           the residual after an int8 product
unary/12   1.64  193 passes  0.009           quantize_row
row/5      0.34    8 passes  0.042           global_attention
```

## the float16 products: 130 passes, 8.50 ms, and only three places ask for them

This was the open question — "129 of 130 shapes the integer kernel would accept", so
why are they still float? Because **the call sites have no integer branch at all**:

| site | passes | shapes (M x N x K) |
|---|---|---|
| `_ffn_groups:581` | **104** | `1344x128x256`x16, `1344x32x128`x16, `384x256x64`x16, `384x64x256`x16, `5376x128x128`x12, `5376x32x128`x12, `21504x128x64`x8, `21504x32x128`x8 |
| `record_split_feed_forward:690` | **16** | `384x512x512`x16 — the block's `w.first` |
| `record_downsample:911` | 5 | the level transitions (`NR_INT8_TRANSITION=0`) |
| `record_upsample_merge:941` | 5 | the level transitions, going up |

So it is the **split (branched) feed-forward** — the 64-256 channel blocks — 120 of the
130. Not a shape gate rejecting them: `_ffn_groups` and `record_split_feed_forward`
simply never offer an integer path, unlike `record_project_residual` which does.

Rough arithmetic on those 120: about **11.4 GFLOP** in 8.5 ms, i.e. ~1.3 TFLOPS, which
is 3-7 % of what the card can do. **They are not arithmetic bound.** Halving the
multiply-add count — which is all configuration 4 buys — is a weak lever on a pass that
is waiting on something else, and it would come with ~120 more `quantize_row` passes
(about 1 ms) and a fresh set of weights to quantise. Expected gain: a few ms at best.
Judge it before spending a night on it.

## the integer path's own wart: 120 residual passes, 2.38 ms

`record_project_residual`'s integer branch is three passes where the float path is two
(or one): `quantize_row` → `gemm_int8` → **a `residual` of its own**, because
`gemm_staged_int8` has no residual epilogue. `nr_resident.py:424`, 120 times a frame,
2.38 ms — 6.5 % of the device, and it is pure overhead the float path does not pay.

Giving `gemm_staged_int8` the residual epilogue `gemm_residual` already has would drop
those 120 passes. It is the cleanest of the remaining items — the work is a shader
change with an existing float template, not a new idea — but it is a shader change, and
the `reverse` variant (the window blocks' residual gathering its skip out of image
order) is the awkward part of it.

## ranked, for whoever picks this up

1. **`gemm_staged_int8` takes a residual epilogue** — 120 passes, 2.38 ms, known shape
   of the fix, moderate shader risk.
2. **The split feed-forward on the integer path** — 120 passes, 8.50 ms, but the passes
   are not arithmetic bound, so the gain is uncertain. **Measure before building.**
3. **`window_block`, 10 passes at 0.62 ms each** — the most expensive pass in the frame
   per pass, and it is already the fused spelling. Nothing obvious; needs its own look.
4. **The host's 24.4 ms against the device's 36.4** — serial. `NR_DAEMON_PIPELINE=2`
   with `NR_LAYER_ASYNC=2` measured 130.9 ms against 72.8 in a game. The two have only
   ever been switched together, so they have never actually been told apart.

Do not start at 2. Start at 1, or measure 2 properly first.

## two things about the hooks that cost an hour

* `traffic_audit.wrap` assumes the shape reader returns a tuple, and `account` is then
  called by the hook. **`s_gemm` does not** — it appends to `CALLS` itself and returns
  `None`, to carry the per-pass and per-dispatch weight counts separately. Anything
  built on "the hook accounts the call" silently loses every `gemm`. `frame_ledger`
  now marks whatever the call added, however it added it, and says so if any call comes
  through unmarked.
* Walking the stack to find the caller works for most calls and returns **nothing at
  all** for some. Marking the recorder functions as they are entered — including their
  classes' methods — does not depend on who called whom, and is what the ledger uses.

## 2026-10-11 重测：前后段都搬上设备之后，设备侧 34.61 ms

`python src/bench/frame_ledger.py`（六轮 replay 34.53~34.65，散 0.12 ms），
完整输出在 `work/ledger-20261011.txt`。

    family           ms   share      n   ms/pass
    gemm          14.58   42.1 %    198     0.074
    row            9.55   27.6 %     70     0.136
    tiled          8.42   24.3 %    130     0.065
    unary          2.05    5.9 %    205     0.010
    -- device     34.61  100.0 %    603

    gemm/30  int8 GEMM, staged    8.98  25.9 %  188 趟  0.048
    tiled/0  浮点 tiled           8.42  24.3 %  130 趟  0.065
    row/4    window_block         6.20  17.9 %   10 趟  0.620
    gemm/31  ffn_fused            5.60  16.2 %   10 趟  0.560
    row/3    window_attention     3.00   8.7 %   52 趟  0.058
    unary/12 quantize_row         1.62   4.7 %  193 趟  0.008
    row/5    global_attention     0.35   1.0 %    8 趟

与 2026-10-10 那份（36.43 ms）比的唯一差别：**unary 4.45 → 2.05**，
正是残差折进 int8 GEMM epilogue 省下的 2.38 ms，一笔对一笔，没有别的漂移。

### 130 趟浮点 GEMM 的出处（tiled/0，8.42 ms）

    _ffn_groups:592                104 趟   (16+16+16+16+12+12+8+8)
    record_split_feed_forward:701   16 趟
    record_downsample:922            5 趟
    record_upsample_merge:952        5 趟

八个形状（M, N, K，几何上都满足 int8 的 N%32==0 && K%32==0 守卫）：
1344×128×256 / 1344×32×128 / 384×256×64 / 384×64×256 / 5376×128×128 /
5376×32×128 / 21504×128×64 / 21504×32×128。

### ❌ 这条路前辈已经走过，别再试：`NR_FUSE_BRANCHED_FFN`

那 104 趟就是这个开关的事。`notes/improve-fusions.md` 与 `notes/HANDOFF.md` 都记着：
720p −2.7 ms，**384×384 +2.6 ms（更慢）**，1080p −6.8 ms。
原因是深层是算术受限而非访存受限，那里一个 subgroup 管 16 行不如 staged GEMM 的 64。
**实机跑的是 768×448 的小 extent，所以留 off 是对的。**
（同批被否的还有：FFN 16 列分块无溢出反而慢 9%、staged GEMM 的寄存器预取流水慢 30%。）

### 剩下能看的

- `window_block` **6.20 ms / 10 趟**，0.62 ms/趟，全帧最贵的单趟，`NR_FUSE_WINDOW_BLOCK`
  已经开着，是融合后的写法。
- `gemm/30` 188 趟 int8，0.048 ms/趟，是已经有收益的那条路。
- ⚠️ **真正更大的一块不在设备上**：帧时间 50 ms，设备只有 34.61，
  差 15.4 ms 在提交间隙 + 宿主 + 跨进程。要继续提速，先量这 15 ms 花在哪
  （`src/bench/daemon_stages.py`），而不是再抠设备。

## 2026-10-11：那 130 趟浮点 GEMM 转 int8，实测是亏的

`src/bench/ffn_int8_probe.py`，完整输出 `work/probe-ffn-int8.txt`。
一帧里剩下的 130 趟浮点 GEMM（8.42 ms）**有 129 趟形状满足 int8 守卫**，
所以"接上去就能赢"的诱惑一直都在。`notes/improve-int8-a770.md` 那节的结论是
"是接线问题，不是形状/速度/精度"，还给了 1.32x / 1.42x / 1.04x。实测否掉了。

### 怎么量的（两个坑都踩了）

1. **一次 submit 约 0.17 ms**，不管里面那个 GEMM 多小。130 趟那么量出来是
   **22 ms 开销对着 8.42 ms 的真活**。改成一次提交录 12 个同样的乘积、减掉空提交，
   再除以 12 —— 墙钟口径因此可用，且不需要时间戳（时间戳自己也有开销，而 int8
   那边每趟多一个 `quantize_row`，会被多罚一次）。
2. **差值不能取最小**。`(12 个 − 空)` 这个差在空提交恰好慢的那轮会是负数，
   取九轮的最小值拿到的是噪声地板（一度全表 0.0 µs）。取**中位数**。

三轮同进程内交替（三条路线轮流），g4 列三次分别是 +0.30 / +0.27 / +0.21 ms：

    groups    fp16/b    fp16/1     int8   int8 vs fp16/b
         1      4.91      4.94     4.55             −0.36
         2      6.18      8.08     6.24             +0.05
         4      9.55     14.75     9.81             +0.26

`fp16/b` = 帧现在的写法（`batch=groups`）；`fp16/1` = 同样的活拆成 groups 个独立调用；
`int8` = 一趟 `quantize_row`（A 是广播，一次量化喂整组）+ groups 个独立 `gemm_int8`。

**账本说这 130 趟是 8.42 ms，g4 的 `fp16/b` 落在 9.55，g2 落 6.18 → 帧里的
groups 平均接近 4。** 那一行就是结论：**转 int8 慢 0.26 ms。不值得。**

### 但真正值钱的是另外两个数字

- **`fp16/b` 9.55 对 `fp16/1` 14.75：batch=4 省 5.2 ms（35%）。** 这一批 GEMM 的钱
  很大一块花在每次 dispatch 的固定成本上，batch 把它摊成了四分之一。
- **`int8` 9.81 对 `fp16/1` 14.75：都是拆开的形态，int8 快 34%。**
  所以 int8 的 GEMM 本身确实快，跟 `improve-int8-a770.md` 说的一致；
  **它输掉的是 batch，不是算术。**

→ 想从这批拿到钱，正确的问题不是"要不要转 int8"，而是"**给 int8 内核加 batch**"
（`gemm_int8` 现在既没有 batch 也没有 offsets，连 `_ffn_groups` 的 stride 都表示不了）。
按 fp16 那个 0.65 的折扣推算，int8 有 batch 大约 **6.4 ms，省 3.2 ms**。
⚠️ 那是推算，不是实测；而且前辈量过精度代价（现有 32 趟 int8 已经吃掉 10.1% 的
effect，转的越多代价越大），真要做，画质必须先重测。

### 所以

- ❌ 130 趟转 int8（无 batch 形态）：**净亏 0.26 ms，不做。**
- ⏳ 给 int8 内核加 batch：理论 3.2 ms，**内核工作 + 精度代价**，要用户拍板。
- ⏳ 设备侧剩下两坨更大的：`window_block` **6.20 ms / 10 趟**（0.62 ms/趟，全帧最贵
  单趟）和 `gemm/31 ffn_fused` **5.60 ms / 10 趟**。

## 2026-10-11：window_block 的三阶段，在 768x448 上实测

`src/bench/window_block_probe.py`。账本说这十趟是 6.20 ms，是设备侧最大的单趟
（0.62 ms 一趟），而它已经是融合写法，没有 pass 可以从它身上拿走。
`notes/HANDOFF.md` 量过一次三阶段，在 1920x1088：5.8 / 5.5 / 1.6 of 12.9。
这里是 768x448，且阶段是真的被拿掉的，不是估的。

### 怎么量的

`window_block.comp` 加了 `PROBE_STOP`（**0 = 什么都不停，每个 shipping 构建都是 0**：
`work/_probe_wb0.spv` 与在跑的 `work/window_block.spv` 逐字节相同，可以自己 cmp）：
1 = K/V 进共享内存后就返回，2 = attention 做完就返回，没有输出投影、残差、publish。
一个阶段 = 两个 stop 之差。

    glslang --target-env vulkan1.3 -DPROBE_STOP=<n> -Isrc/gpu \
            -o work/_probe_wb<n>.spv src/gpu/window_block.comp

两个坑：
- **一个 pipeline 一个进程**（`libxmx.c`: `if (g.rblock) return 0;`），所以三个 stop 是
  三个进程，必须**两个顺序各跑一遍**。跑了的：正序 6.02 / 2.48 / 4.64，倒序
  6.02 / 2.47 / 4.65 —— 差 ≤ 0.01 ms，可以相减。
- **规划那一遍也会录窗块**，不清掉就是 20 趟 12.07 ms，正好翻倍，看着像"账本错了"。

### 结果

| | ms | 占 |
|---|---:|---:|
| 完整 | **6.02** | |
| A：QKV 投影、归一化、K/V 进共享内存 | **2.48** | 41 % |
| B：attention（QK^T、softmax、PV） | **2.17** | 36 % |
| C：输出投影、残差、publish、pool/head 的尾巴 | **1.37** | 23 % |

十趟里两趟是 level 0（448x768，5529 / 5376 个窗），各 1.68 和 1.47 ms，**占 52 %**；
八趟是 level 1（224x384，约 1392 个窗），各约 0.35 ms。

### 硬件账（`XMX_PIPELINE_STATS`）

四个 specialization（flags 0 / 4352 / 0x800000 pool / 0x1000000 head）：
**Instruction Count 6472-7500，Scratch Memory Size = 0（无溢出，安全），
Workgroup Memory 16384，Loop Count 1**（循环全展开）。

每趟的乘加只有 64 次 8x8x16 —— 一个 workgroup 131072 FLOP，level 0 的 5529 个
workgroup 共 724 MFLOP，1.68 ms → **431 GFLOP/s，峰值约 1.7 %**。

**99 % 的指令是逐元素的。** 这就是它为什么慢，也是为什么改它这么难。

### 结论：这块没有结构性的钱

对照 Blackwood416 的 A770 skill（`E:/WorkBuddy/a770-speedopt/refs/`，
`references/techniques/sdpa-a770.md`），它的 VTune 结论是同一件事：
*"XVE 57 % Stalled, XMX pipeline 19.5 % active"*，
*"instruction volume and operand relay dominate"*。还有一句是这里的刹车：
> Higher occupancy is not the goal by itself: oneDNN ran at 28.7 % occupancy and beat
> an ESIMD variant at 58.4 % because it issued fewer instructions.

所以提高驻留不是方向（何况槽位大概已经满：256 线程 x 4 个 workgroup 一个 Xe-core，
16 KB SLM 也不是限制，作者的阈值是"超过约 32 KB 才开始丢"）。能做的只有减指令，
而减指令在这里就是动数值语义。

**已经有人试过并否掉的，别再试：**
- K/V/Q 存成 E4M3 字节省一半共享内存和流量 —— 更慢（projection 3.78 -> 3.93，
  attention 3.22 -> 3.93，`notes/improve-b.md`）。编码解码比省下的字节贵。
- 把 FFN 塞进 window block —— 0.95x（`improve-b.md`）。
- B 按列 / 按 K 对在共享内存里 —— 更慢（同上）。
- 作者自己已经做掉的两条：QKV epilogue 的归一化摊到 4 个 lane 一行
  （10.9 -> 7.1 ms），权重进共享内存（7.1 -> 6.2）。

**剩下的都是 1-3 % 一处，每处都要重验 bit-identical：**
- attention 里那条分母归一化的循环，每 lane 16 个值各做 `e4m3(half_round(x))`，
  两个量化串在一起，约 300 条指令。去掉 `half_round` 是双重舍入，会改结果。
- gather 那 8 次 `e4m3` 在 `image_half=0` 时是幂等的（e4m3(e4m3(x)) == e4m3(x)，
  尾数只剩 4 位，再过一遍的 roundEven 吃整数），可以跳过 —— 约 2 %，且只在
  image 为 float32 时成立。
- 一个 workgroup 做两个窗，权重那 6 KB 只读一次用两次。这是唯一还有点结构的，
  估 0.3-0.5 ms，但要重做几何和 pad，且共享内存从 16 KB 涨到 24 KB。

→ **建议转 B2（int8 内核加 batch，估 3.2 ms）**，比在这里抠这些划算得多。

## 2026-10-11：window_block 是不是并发不够 —— 加指令测出来的答案

上一节结尾说它"延迟受限、并发不足"。**那句说得不准，这里更正。** 用一个能直接
证伪的实验测了：`window_block.comp` 的 `PROBE_FILL`（0 = 每个 shipping 构建），
在每个 workgroup 最开头插 `N` 轮四条互不依赖的 vec4 乘加链，种子取自尚未写入的
共享内存，所以编译器折不掉。

    glslang --target-env vulkan1.3 -DPROBE_FILL=<n> -Isrc/gpu \
            -o work/_probe_wb0f<n>.spv src/gpu/window_block.comp
    python src/bench/window_block_probe.py --stop 0 --fill <n>

| fill | 0 | 100 | 200 | 400 | 800 |
|---|---:|---:|---:|---:|---:|
| 正序 ms | 6.03 | 6.79 | 7.57 | 9.31 | 12.73 |
| 倒序 ms | 6.02 | 6.80 | 7.61 | 9.30 | 12.89 |

**从 fill=0 就是直线，没有一点平台期。** 每 100 轮（每 lane 800 条指令）固定
约 0.78-0.87 ms；倒序复现，差 ≤ 0.16 ms。

一条独立指令都白拿不到，说明一件事：**没有空闲的发射槽可以填。** 如果内核是在
等自己的依赖链，最先加的那几百条会被气泡吃掉，曲线应该先平一段。它没平。

### 那"并发"到底够不够：把词拆开

| 层 | 数字 | 够不够 |
|---|---|---|
| workgroup 数（波数） | level 0 5529 个，128 个/Xe-core-整机 → **43 波**；level 1 1392 个 → 11 波，尾浪费 1.1 % | 够 |
| 每 Xe-core 驻留 | 硬件页 4096 硬件线程 / 8 = 512 XVE，32 Xe-core → 16 XVE/核，每 XVE 8 线程 × SIMD8 = 64 → **每核 1024 work-items**；256 线程的 workgroup → **4 个，正满** | 满 |
| 每 Xe-core 的 SLM | 16 KB × 4 = 64 KB，池子 128 KB | 不是限制（线程槽先到） |

所以"再塞更多 workgroup 进去"没有地方塞，槽位是满的。而 fill 实验证明满了也
还是喂不满发射端口 —— **瓶颈是每周期能发几条指令，不是有多少活排着队。**

### 于是只剩一条路：减指令，或者减同步

按同样的斜率，基线 6.02 ms ≈ 每 lane 7000 条指令的量。**99 % 是逐元素的。**
剩下还能看的，都是要动数值语义的，每处 1-3 %：

- attention 里 `weights()` 的位 hack（`half_round` → 乘 → 加 → clamp → packHalf2x16
  → 移位 → 加 → unpack），每 lane 8 次、每次约 10 条；归一化那 8 次
  `e4m3(half_round(x))` 是双重舍入，去掉会改结果。
- gather 那 8 次 `e4m3` 在 `image_half=0` 时幂等，可跳过（约 2 %）。
- **acc → coopMatStore → 读 → weights → 存 → 读 → 归一化 → 存 → coopMatLoad 这条
  共享内存往返链**：每个 logit 在场内存里过了四趟。lane 间换数据用的是 SLM 加
  barrier，`subgroupShuffle` 是寄存器内的。这是唯一还有结构的，但要重排布局，
  且每条都要重验 bit-identical。

❌ 别再试的（都量过）：K/V/Q 存 E4M3（更慢）、FFN 塞进来（0.95x）、B 按列或按 K
对在 SLM 里（更慢）、**一个 workgroup 做两个窗**（权重加载只有两条指令，摊不出来，
SLM 反而 16 → 32 KB）。
