# where the host's time goes (2026-10-11)

Every number is a median of 41 runs of `src/bench/bench_compose_encode.py` on one real
1920x1080 frame (`work/capture.nrn`), with the knobs the daemon hands the pass live: history
on, hold 1, release 24, samples 8, no control mask. `OMP_NUM_THREADS=24` unless stated.

## the host today

`src/bench/daemon_stages.py 1920x1080@0.4 --frames 14`, medians, ms:

| stage | fresh | **held** (what a game looks like) |
|---|---|---|
| gpu_run | 45.55 | 45.12 |
| compose_encode | 6.09 | **9.33** |
| post_send (after the answer has gone) | 5.68 | **7.63** |
| resample (two bilinears) | 4.83 | 4.52 |
| decode | 2.18 | 1.91 |
| gpu_in | 2.18 | 2.25 |
| features | 1.82 | 2.09 |
| history_take | 1.52 | 1.42 |
| **daemon_rest** (all of it less the graph) | 24.35 | **29.48** |

Device and host are serial: about 45 ms of graph plus about 25 ms of host, one after the other.

## what `compose_encode` spends its milliseconds on

It is the largest single thing the daemon owns. Eight questions, answered by experiment:

| question | measurement | answer |
|---|---|---|
| is OpenMP working? | 1 thread 39.31, 6: 10.25, 12: 9.05, 24: 8.94 ms | yes, but nothing past 6 threads |
| is the head's upscale a share? | head already at 1080p 9.79 vs 9.33 | **no** — free here |
| is it arithmetic? | the shipped MSVC dll has **no** `vmulps`/`vaddps` at all (0/0 against 510 `mulss` / 353 `addss`); rebuilt with gcc `-march=x86-64-v3` it has `vmulps` 2662 / `vaddps` 2468 | no — the vectorised build is the same speed (8.61 vs 9.01) |
| is it memory latency? | colour aliased in as history and previous too: 8.48 vs 9.45 | about 1 ms of it |
| is it bandwidth? | ~134 MB a frame in ~8.6 ms ≈ 16 GB/s, against a machine copying 50 MB in 2.4 ms single-threaded and gaining nothing from more threads | **yes — that is what this pass is** |
| **what can come out?** | ablation of the two full-frame float writes, gcc build | **writing `output` costs ~5 ms** (temporal 8.61 → 3.58; still 7.99 → 1.93). `kept` went to a thread-local scratch row because this run passes no `neural`, so its true cost wants a second pass |

Not arithmetic, not latency, not the resize. It is the memory traffic, and about a quarter of
that traffic is the float32 composition the daemon later reads back to print `change` and to
downsample into the next frame's history.

## the two fusions this points at

Both are the same trick this tree has already paid for twice — window gather into
`quantize_row` (−4.37 ms), the residual into the GEMM epilogue (−1.88 ms): **fold what reads a
buffer back into the pass that produced it.**

1. **`change` into the composition.** The daemon does `mean_change(composed[::4], colour[::4])`
   after the answer leaves; the composition has both operands in registers one row ago. Summing
   there costs almost nothing and takes a timed NumPy stage off the frame.
2. **the next history into the composition.** `History.keep` bilinear-downsamples the
   composition; that is a read of the 25 MB that was just written. Doing it inside the row loop
   removes the read and, with (1), would leave the float32 composition with no reader at all —
   in which case the ~5 ms write goes away.

Together: on the order of 5 ms of a 70 ms frame, at no cost to the picture (nothing changes the
bytes the game is handed; both purely move work).

Risks, said out loud: `change` is a printed figure, so its sum must stay within the noise of
the NumPy pairwise sum it replaces — it will not be bit-identical by construction and needs its
own check; and the history downsample is on **`post_send`**, off the frame's path today, so (2)'s
payoff is throughput, not latency, unless enough of it lands to shorten the daemon's turn.

## building the library on this machine

Read this before touching anything — see §"本机工具链" of the project memory and
`docs/a770-port/code-map.md`. In short: the shipped `work/libnr_image.dll` is an **MSVC**
build (it depends on `VCOMP140.DLL` and nothing else) and **this machine has no `cl.exe`**; the
compiler here is MinGW-W64 gcc, whose dlls `ctypes` will only load with `winmode=0`.
