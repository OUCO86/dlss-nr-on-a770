# what a frame is actually made of (2026-10-10)

Measured again because two numbers refused to add up: `pass_time.py` said the device spent
27.25 ms on a 768x448 frame, while the daemon's own wall clock around `xmx_graph_run` said
about 40. A third of the frame was missing, and everything said about where the time goes
had been said against the wrong total.

## The accounting was wrong

`pass_time.py` attributes each device timestamp to the Python call that recorded it, by
index. Two things break that correspondence:

1. **`gemm_int8_qkv` was not in `traffic_audit.HOOKS`.** With `NR_INT8_QKV` on — it is on by
   default — sixty passes a frame were named by nobody. Same for `pool2_skip`,
   `upsample_add`, `copy`, `sample_history`. Added.
2. **One Python call is not always one device pass.** `ffn_fused` records several: they come
   back as `GEMM` and `ROW` stamps in pairs. Every pass after the first `ffn_fused` was
   therefore attributed one place along from its own shape.

And the total itself came from `sum(by_kind.values())`, which only ever summed the passes a
hook had named. What was left out was not noise: it was **9.17 ms of 36.42**, a quarter of
the device.

Both are fixed. The total now comes from every timestamp the device wrote, and whatever no
hook can name is printed as `(no name for these)` rather than dropped — an attribution that
quietly loses a quarter is worse than none.

## One frame, 768x448 network, 1920x1080 out

Wall clock from `src/bench/graph_gap.py` (five replays, dead steady: 39.63-39.94), against
the device's own timestamps:

| | ms | |
|---|---|---|
| device, all 723 passes | **36.42** | what the card is busy with |
| submit to fence — unaccounted | 3.27 | `vkQueueSubmit` to `vkWaitForFences`, less the passes |
| host write into mapped memory | 2.1 | features to the device's own memory |
| read the head back | 0.9 | the crop leaving the device |
| **daemon's `gpu A+B+C`** | **42.7** | what the log prints |

The rest of the 75.6 ms a game sees is host work (24.4, `notes/daemon-cpu-cost.md`) and the
cross-process round trip plus the layer's own wait (about 9). None of that is the network.

There is no 12 ms hole. The first reading of these two numbers — 27 against 40 — was an
accounting error, not a machine waiting on something unmeasured.

## The names in that table are not to be trusted

`pass_time.py` pairs pass *i*'s timestamp with the *i*-th Python call that recorded a pass.
`work/_check_pairs.py` asks the device what each of those passes actually was, and the two
answers disagree **438 times out of 576**: where Python says `quantize_row`, the device
says `GEMM/30`; where Python says `quantize_window`, the device says `TILED`.

So the table below is a set of shapes with the wrong milliseconds beside them. The shapes
themselves are fine — a hook reads them off its own arguments — and the total is fine, but
every per-kind figure is a mixture. Contributing to that: one recorder is not always one
pass (`window_block` records two), and the Python call that asks for a pass is not
necessarily the one whose stamp lands next to it.

`src/bench/device_families.py` sums the families instead, which is what the device itself
wrote and cannot be out of step. **Use that.** The `pass_time` table is kept below only
because it is what the earlier notes were argued from, and because the shape breakdown
beside it is still sound.

## Where the device's 36.42 ms goes — by family, which is the one that holds up

Mean of eight replayed frames (`AUDIT_ROUNDS=8`). Read the attribution with care: passes
after the first `ffn_fused` are a place out, so the small rows are approximate. The total is
not.

| kind | ms | share | n | GB/s |
|---|---|---|---|---|
| gemm (fp16) | 6.43 | 17.6 % | 130 | 115 |
| quantize_row | 4.81 | 13.2 % | 136 | 82 |
| unary | 4.54 | 12.5 % | 136 | 169 |
| *(no name — inside `ffn_fused`)* | 4.44 | 12.2 % | 6 | — |
| gemm_int8 | 4.39 | 12.1 % | 128 | 155 |
| ffn_fused | 3.97 | 10.9 % | 8 | 46 |
| quantize_window | 3.22 | 8.8 % | 52 | 63 |
| gemm_int8_qkv | 1.78 | 4.9 % | 60 | 236 |
| ffn_fused_stem | 1.22 | 3.3 % | 1 | 45 |
| window_attention | 1.01 | 2.8 % | 52 | 1491 |
| ffn_fused_merge | 0.38 | 1.0 % | 1 | 9 |
| everything else | 0.23 | 0.6 % | 8 | — |

FFN, taking `ffn_fused` together with the stem, the merge and the stamps it records that no
hook names, is about **10 ms — the largest thing in the frame**. It is nine
blocks and they are already fused (expansion, activation and projection in one pass, so the
hidden layer never reaches memory).

Quantising activations is **8.03 ms, 22 %** — more than the integer products it exists to
feed (6.17). That is not wasted: it is what turns those products' reads from two bytes into
one, and without it they would cost several times as much. It is just the second largest
line, which makes it the natural place to look.

### By family (src/bench/device_families.py, mean of 8 replays)

| family | ms | share | n | ms/pass |
|---|---|---|---|---|
| gemm | 13.94 | 38.3 % | 198 | 0.070 |
| row | 9.54 | 26.2 % | 70 | 0.136 |
| tiled | 8.49 | 23.3 % | 130 | 0.065 |
| unary | 4.45 | 12.2 % | 325 | 0.014 |

And by what the sub-kinds are, taken from the `stamp()` calls in `libxmx.c`:

| | ms | share |
|---|---|---|
| `tiled` — the float16 products | 8.49 | 23.3 % |
| `GEMM/30` — the integer products | 8.40 | 23.1 % |
| `ROW/4` — `window_block` | 6.20 | 17.0 % |
| `GEMM/31` — FFN, its stem and its merge | 5.54 | 15.2 % |
| `ROW/3` — `window_attention` | 3.00 | 8.2 % |
| `UNARY/5` | 2.38 | 6.5 % |
| **`UNARY/12` — every quantise in the frame** | **1.64** | **4.5 %** |
| the rest | 0.77 | 2.1 % |

Two of the earlier notes' conclusions do not survive this. Quantising is **1.64 ms, not
8.03** — `xmx_rec_quant` stamps itself `PK_UNARY, 12`, so it had been sitting inside the
unary line, and the 8.03 was other passes' milliseconds sitting beside its name. And
`window_block` at 6.20 ms never appeared at all, having been credited to whatever came
after it.

What does hold is that the products are the frame: **16.89 ms, 46 %, across the integer
and float16 GEMMs**, and of that the float16 half is 8.49 ms across 130 passes that the
integer path does not touch.

## Reading it twice is not why it costs that

`quantize_row` walks its row twice: once for the peak that sets the grid, then again to put
the values on it. Two reads of every word looked like the obvious saving, so: keep four
words a lane in named registers (an array would spill), read once, reduce, quantise from the
registers. `work/quantize_row_onepass.spv` is that spelling.

It buys nothing. `src/bench/quant_ab.py` puts the two head to head in one process —
`Runtime.quantize_row` re-reads `XMX_QUANT_SPV` on every call, so they can take turns
instead of paying four minutes of loading each — and they alternate, four rounds:

| round | two walks | one walk |
|---|---|---|
| 0 | 36.57 | 36.78 |
| 1 | 36.46 | 36.39 |
| 2 | 36.42 | 36.60 |
| 3 | 36.41 | 36.38 |
| **median** | **36.44** | **36.50** |

**+0.06 ms, inside a round-to-round noise of 0.2 ms.** There is nothing there.

It looked slower once. Measured the two spellings one after the other rather than
alternating, the difference read as +0.46 ms on both the device and the wall clock, which
agreed with each other and were both wrong — the card had drifted, and alternating is what
tells that apart from an effect.

Either way the reason is the same and it is the useful part: **the second walk costs
nothing**, because the first has just left the row in L2. Keeping the words costs
registers, which costs occupancy, and the two cancel.

The shader is back to two walks. The one-walk spelling is kept as a shader, not wired up,
with this note next to it.

So the 8.03 ms is not two reads where there could be one; the second is free, and replacing
it costs exactly as much as it saves. If it is to come down it will be by not running at all —
folding the quantise into the pass that produces the activations, which is what
`NR_INT8_WINDOW_FUSE` already does for a window block.

## What is left to try

* **FFN, ~10 ms.** Already fused, its own lines read slow (46 GB/s), and the two slowest
  single passes in the frame are both inside it (1.69 ms and 1.52 ms). Nine blocks against
  one idea each; worth knowing where its time goes before touching it.
* **The host's 24.4 ms against the device's 36.4.** Serial, because the daemon cannot start
  frame N's host work until frame N's answer comes back. `NR_DAEMON_PIPELINE=2` overlaps
  them across frames — but only into as many frames as the layer is willing to have in
  flight, so it needs `NR_LAYER_ASYNC` too, and *that* pair measured 130.9 ms against 72.8
  in a game (`docs/A770-HANDOFF.md`). The offline 71 → 43 in `notes/daemon-cpu-cost.md` has
  no game and no present loop in it. Whether the two can be told apart is still open: they
  have only ever been switched together.
