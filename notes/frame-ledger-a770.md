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
