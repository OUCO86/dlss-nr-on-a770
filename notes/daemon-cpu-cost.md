# what a frame costs on the host (2026-10-09)

1920x1080 in, network at 768x448 (render_scale 0.4), int8 on, A770, the pipeline off and
the layer synchronous — which is how the daemon is running in the game. Every number is a
median over 30+ frames of a real captured frame (`work/capture.nrn`) replayed through a
second daemon on its own pipe (`\\.\pipe\nr_lop_probe`), never touching the one a game may
be using.

How they were taken: `work/cpu_cost_probe.py` imports `nr_daemon` and wraps the callables a
frame walks through, so nothing in `src/layer/` had to change to be measured. Times are
*exclusive* — a segment is charged for itself alone, with the calls it made taken out — so
`history keep` and the `resample` inside it do not double-count. `work/cpu_probe_client.py`
is the game's end of the pipe; `--inflight N` is what `NR_LAYER_ASYNC` does from the layer.

Two runs ten minutes apart disagree by a millisecond or two on the device alone, so the
before/after below was measured **on alternating frames inside one process**
(`NR_PROBE_ALTERNATE=1`, 35 frames of each spelling): whatever drifts between two frames is
noise on both.

## the frame

| stage | ms | where it lives |
|---|---|---|
| network: the device, Python blocked in the graph run | 40.03 | `src/gpu` |
| `nr_image.compose_encode` — compose, grade, blend, quantise, one pass | 8.98 | `src/ref` -> `nr_image.c` |
| `nr_image.bilinear` x2 — the network's input, and the history's | 4.00 | called from `nr_daemon` |
| `mean_change` — the `change 0.023` figure in the log | 2.58 | `src/layer` (fixed here) |
| `nr_image.to_half` — features fp32 -> fp16 into mapped memory | 2.17 | `src/gpu` |
| `history keep` incl. its resample | 2.17 | `src/layer` |
| `nr_image.features` | 1.89 | `src/ref` -> `nr_image.c` |
| `nr_image.decode8` | 1.90 | `src/ref` -> `nr_image.c` |
| `history take` — the shot-cut test | 1.23 | `src/layer` (fixed here) |
| `sendall` — 8.3 MB back to the layer | 1.11 | `src/layer` (`nr_pipe.py`) |
| `receive` — header + 8.3 MB from the layer | 0.66 | `src/layer` |
| `read_head` — the network's answer off the device | 0.54 | `src/gpu` |
| `hold_floor` + `release_factor` + `history_weight` (the log's `held`/`released`/`gate`) | 1.19 | `src/layer`, printed only |
| letterbox, settings refresh, `_knobs`, geometry, the rest | ~0.4 | `src/layer` |
| **host time a frame** | **26.11 before / 24.41 after** | |
| **frame, as the layer sees it** | **~68** | |

So: of a 68 ms frame, about 40 ms is the device and about 26 ms is host work, and the two
never overlap — one request runs end to end in one thread, and the graph run blocks until
the device is done. Nothing before `sendall` can be dropped without dropping work: the
table above accounts for 95 % of the frame, so there is no hidden per-frame cost left in
`nr_daemon` beyond these rows.

## what was changed

Two lines, both in `src/layer/nr_daemon.py`, both computing a number the daemon prints:

1. `stage_finish`'s `changed` — `float(np.abs(composed[::4] - colour[::4]).mean())` builds
   two 6.2 MB arrays a frame and drops them. It now writes into a buffer kept for the shape
   (`_SCRATCH` / `mean_change`, nr_daemon.py:136-161). Standalone on two cold 1920x1080
   frames: 2.99 ms to 0.58 ms.
2. `History.take`'s cut — the same shape of expression at the network's extent (2.2 ms
   before, 1.2 after). The buffer rides on the `History` (`self._difference`), which is
   already reached under `args.history_lock`, so it is safe with the pipeline's threads.

Measured on alternating frames, 35 of each spelling:

* host time a frame: **26.11 -> 24.41 ms (-1.70 ms, -6.5 %)**
* the layer's own wait (frame started to the answer's last byte leaving): 61.41 -> 60.99 ms
  (**-0.42 ms**)

The answer the daemon sends back is **byte-identical** either way — the 8 294 416 bytes of
a 1920x1080 answer hashed the same before and after (md5 4dc89b8031511396ff1d99f55c7badbf,
same input frame replayed from `work/capture.nrn`), which is the check that these are the
same numbers and not just the same sort of numbers.

The second number is smaller on purpose, and it is the honest one to quote: most of what
these two lines cost is spent *after* `sendall`, behind a game that already went back to
drawing. It saves CPU, not frame time — except for the cut, which is in `prepare` and
squarely on the path.

## what was measured and is not worth doing

* **Pipe buffer size.** A frame is 8.3 MB and the pipe holds 1 MB of it, so it looked like
  several writer-waits-for-reader round trips. At 16 MB nothing moved: receive 0.60 ms
  (0.63 at 1 MB), sendall 1.13 ms (1.10). `nr_pipe.py` left alone.
* **`NR_DAEMON_PIPELINE=2` with a client that keeps two frames in flight** — that is the
  other 25 ms. Same daemon, same weights: **inflight 1: 71.14 ms a frame; inflight 2:
  43.55 ms** (22.96 fps against 14.06). Deeper than the pipeline (inflight 3 against a
  depth of 2) buys nothing: 43.77 ms. It is already written and already measured, and it is
  off because it costs a frame of lag and was felt: `notes/HANDOFF.md`, "the async live
  mode exists, and is off by default for a reason" — on the iGPU the host work was too
  small a share for the overlap to pay. On this machine the split is 26 ms host against
  40 ms device, not 13 against 46, which is a different trade. **Left off, not turned
  off** — it needs `NR_DAEMON_PIPELINE` on the daemon and `NR_LAYER_ASYNC` on the game, and
  a decision about the lag.
* **Sampling the log's figures more coarsely** — every eighth row instead of every fourth
  in `mean_change` would be worth ~1.2 ms more, and the `held`/`released`/`gate` block is
  1.19 ms for three printed numbers. Both change what the log says, so neither was done.

## where the rest of it is, and who owns it

Nothing here was touched, because it is not in `src/layer/`:

* **`nr_image.compose_encode`, 8.98 ms — the largest host pass in the frame** (13 % of it).
  `nr_frame.compose_encode` (`src/ref/nr_frame.py:717`) calls it with the full-resolution
  colour, the previous output and the head. If anything is to be found on the host, it is
  here.
* **The two `bilinear` passes, 4.00 ms.** One is the network's input and unavoidable. The
  other is `History.keep` downsampling the previous full-resolution prediction to the
  network's extent — it runs after `sendall`, so it is off the path, but it is 2 ms of
  memory traffic every frame for a downsample the next frame reads once.
* **`nr_image.to_half`, 2.17 ms** — 5.5 M features cast to fp16 into mapped device memory,
  because the features are built on the host and copied. Building them straight into the
  mapped input (`NR_INPUT_VIEW=1`) would skip the copy entirely, and does work on the
  140V, but on this discrete card the graphs come back NaN (the comment at nr_daemon.py:926-941). If that is ever pinned down, this is 2 ms.
* **`nr_image.features` 1.89 ms and `decode8` 1.90 ms** are already one native pass each.

## the C layer, not changed

Read, not touched — changing it means rebuilding the injected layer, which is the user's
call. Per frame, on the game's present thread, when the layer runs synchronously
(`nr_layer.c`):

* `process_frame` (nr_layer.c:1278) does `memcpy(data->mapped, data->result, needed)` —
  8.3 MB in, 8.3 MB out — plus `exchange`, which is a `WriteFile` of 8.3 MB and a
  `ReadFile` of 8.3 MB on a pipe whose buffer is 1 MB.
* With `NR_LAYER_UI_MASK` on, `settled` (nr_layer.c:1256-1267) walks all 2 073 600 pixels
  comparing bytes, and `process_frame` copies the frame into `outgoing` first
  (nr_layer.c:1294-1296) so the mask can travel behind it — another 8.3 MB copy and 2 MB more on
  the wire. `mask_worth_sending` (nr_layer.c:1273-1276) drops the mask when it covers too much
  or too little, but `settled` has already run by then.
* Nothing there takes a lock per frame; `lock` (nr_layer.c:177) guards device and
  swapchain bookkeeping, and the present path is serialised by the queue itself.

That is a handful of milliseconds a frame, all inside the game's own process, and it is
what a copy of the frame to the daemon costs by construction. The only way to take it out
is to stop copying — shared memory with the daemon instead of a pipe — which is a bigger
change than this note is.

## the premise about `held 87 %`

`held` in the log is the share of *pixels* the game handed back unchanged
(`nr_frame.hold_floor` over `colour[::8,::8]`), not the share of frames the network skipped.
The network runs on every frame that reaches the daemon: `stage_network` has no way past
`backend.run_features`, and nothing in `stage_prepare` returns early on `held`. At 87 % held
the device still spends its 40 ms; only the composition's blend is cheaper per pixel. The
knob that actually skips frames is `NR_LAYER_LIVE` — the layer sends every Nth present — and
`tools/deploy.bat:220` sets it to 1, so every present is being processed today.

## files

* `work/cpu_cost_probe.py` — the instrumented daemon (own pipe, own settings, own log).
* `work/cpu_probe_client.py` — the layer's end: replays a captured frame, `--inflight` for
  the async mode, `--jitter` to make a frame that moves.
* `work/cpu_micro.py` — the bare NumPy lines, timed against two real frames.
* `work/nr_settings_probe.json` — a copy of `nr_settings.json` for the probe; the real one
  was not touched.
