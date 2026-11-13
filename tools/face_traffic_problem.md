# The C512 block's remaining traffic problem — one page for the user's decision

Status of the block (all numbers measured on the shipped graph path, chain-level stop ablation, plain
caliber, same-session baseline, 4 cold processes per stop arm):

| quantity | value | how measured |
|---|---|---|
| block cost (2 live chains, pair stop) | **0.87 ms** (this shovel) / 1.04 (C115) / 1.13 (C117) | `stop{25,33}` minus baseline, same session |
| block cost (sum of single-chain stops) | **0.850 ms** | `stop{25}` + `stop{33}` |
| => block multiple vs the 0.21 ms target | **4.1x - 5.4x** | both accounts reported, never one |
| bytes touched per live chain | 502.9 MB (25) / 520.2 MB (33) | `[byte-audit]` (per-closure full-face accounting = upper bound) |
| **of which the two activation faces** | **401.8 MB/chain = 79 %** | 1303 (=1267 mirror) 200.5 MB touched by **3 closures**; 1307 (=1274 mirror) 201.3 MB touched by **6 closures** |
| measured byte-cost slope | **0.00095 - 0.00107 ms/MB** | chain 1 (A5-fused) vs chains 25/33 (rejected), same session |

## What is already done to this block (measured tonight, not assumed)
- **The WA middle is already one resident launch** (`wares::launch_wa_res`, `:6953-6972`): the Q/K operand
  packs are skipped, the V pack is skipped under P10c RAW-V, and `dScores / dProbs / dAp` **never touch
  global** (verbatim `:6963-6964`). Turning that off (`NR_WA_RES=0`) costs the block **+0.47 ms** and the
  frame **+3.45 ms** — so the residency work is already paid for and already in the shipped build.
- **Tile / launch-count / pack-granularity knives are flat inside the block** (C115/C116: block delta
  0.00 ms; PUB128 +0.19 unreplicated, C512_BAND inert on this path).
- **Fusion buys nothing here** (C123: the A5-fired chain costs 0.00107 ms/MB, the rejected chains
  0.00095 / 0.00071 — the same, so merging launches is not the lever).
- **The block contains no f32 faces at all** (C121: every face it touches is esz = 2).

## The one lever with magnitude left: touch-count, not width
Halving the two faces' bytes (f16 -> int8/e4m3, per-row scale) removes **401.8 MB/chain of touched
bytes** => **block -0.38 ~ -0.43 ms => block ~0.44-0.49 ms => 2.1-2.3x**. That is worth having, and it is
a numeric change on the residual stream and the attention output — i.e. it goes into the picture.

**But it is not a small knife, and the reason is structural, not effort:**
1. **The width is declared by the plan, not the engine**: `OP_BUF 1267/1274` carry `kind = 0`, and
   `xmx_buf_create_kind(bytes, kind)` maps `kind == 0 => esz = 2` (`:1423`). The plan binary
   (`out/plan_960x544.bin`) is a protected artifact — so the engine would have to **override the kind by
   face id at creation** and then every consumer must agree.
2. **Both faces are shared across the whole model**: 1267 is written by 3 recorder classes and read by 5
   (`FFN / FFN_MERGE / FFN_STEM / GEMM_INT8_RESIDUAL / GEMM_WINDOW_INT8_RESIDUAL`) over **52 chains**;
   1274 is written by 2 and read by **8 classes**. There are **203 `sycl::half*` cast sites** in the
   recorder file; the ones on these two faces are ~40-80. A per-chain (block-only) conversion is
   **inexpressible** on a shared face — this was already proven for 1274 in C118 and for 1267 in C124.
3. So (yi)+(bing) is one **global width policy change**: create-site override + writer publish width +
   scale plane per reader + every reader's element stride, plus the full numeric ladder (new four faces,
   byte-difference %, real-face numeric columns, 1000 frames, block, frames on both calibers). It cannot
   be completed and gated inside one 100-minute shovel without risking a half-done numeric knife.

## The structural option (what lmxx actually does, from his own numbers)
His `c512_qkv_attention_compact_w16` runs with **LDS 6,144 B per work-group** and **0.068 ms/chain at
544p-equivalent**. He does not materialize 66.8 MB and 33.6 MB activation faces per chain at all — the
chain's working set is a tile, and the planes that do exist are packed/imported once.

Our unique face bytes per live chain are only ~140 MB (C121) but they are **touched 9 times** (3 + 6).
Even at the L2 reuse rate, 140 MB is 0.164 ms/chain — already **2.4x his 0.068**. So:

- **width change (yi+bing): block -> ~2.1-2.3x. Necessary, not sufficient.**
- **touch-count change: to reach 1.0x (0.10 ms/chain) the block may touch at most ~90-105 MB/chain at the
  measured slope — i.e. the two faces must be touched **once**, not 3 and 6 times.**
  Concretely: fold the readers into the producer the way `launch_wa_res` already folded
  scores->softmax->attnV->merge (`:6961-6964`), i.e. a **head-sliced resident chain** that reads 1267
  once per window and produces the attention output without ever writing 1274 to global.
  SLM budget for that shape: one window (64 tokens) x one 32-channel head = 12.3 KB of half operands
  + 8 KB scores + 8 KB probs = **~28.7 KB <= 43,690 => 3 work-groups/Xe-core** — the same arithmetic that
  already makes `wa_res` legal. **This does not hit the C100 death conditions** because it never holds
  the 512-channel row (98,304 B) resident: it holds one 32-channel head slice at a time and loops heads
  inside the work-group, which is also exactly what lmxx's 6,144 B LDS implies.
- **What that would touch**: `xmx_rec_quant_window` (producer of 1272/1273), `xmx_rec_gemm_int8_qkv`
  (writer of 1275/1276/1277), `xmx_rec_window_attention` (already resident), `xmx_rec_gemm_window_int8_
  residual` (the consumer that re-reads 1267/1272/1273). Four recorders, one new resident chain, plus
  the `pgraph_extra()` touch declarations (mandatory — the scheduler treats a shared device pointer in
  two closures as a conflict in any direction, `:118-143`, which is exactly the signature of the old
  82.6 % scattered divergence).

## Decision the user has to make
1. **Accept a numeric change on the two main activation faces** (f16 -> e4m3/int8, per-row scale):
   block 4.1-5.4x -> **2.1-2.3x**, needs a full shovel (global width policy + full ladder), picture must
   be judged on hardware.
2. **And/or open the structural chain** (head-sliced resident qkv+attention+residual, 28.7 KB SLM):
   the only route that can reach **1.0x**, because it removes the 3x and 6x re-touching instead of
   halving bytes. Bigger engineering risk (four recorders + buffer lifetime + `pgraph_extra`), numeric
   change only if the reduction order changes — a head loop that keeps the same fp32 accumulation order
   can stay bit-exact, which is what `wa_res` proved (`EXACT` at 9.2x).
3. Doing only (1) leaves the block at ~2.1-2.3x. Doing only (2) leaves the width as is and attacks the
   touch count. **(1) then (2) is the order I would take**, because (1) is mechanical and its measurement
   also re-prices the slope that (2) will be judged against.
