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

## done (2026-10-11, `1bbb31f`): a better first step than either

Writing the composition out at all turned out to be the thing to attack, and item (2) above was
never needed to get it — which the paragraph above got wrong. Nothing reads the composition
except the `change` figure, `--dump` and `--meter`, and only the first runs during a game. Fold
that figure into the pass **and** withhold the frame, and the whole 25 MB disappears at once.

`nr_compose_encode` takes two trailing arguments: `output` NULL withholds the composition, and
`change` with a row step accumulates the figure instead. Both are off by default, so everything
that wanted the composition still gets it.

| `daemon_stages.py 1920x1080@0.4`, median of 14 | before | after |
|---|---|---|
| `compose_encode` | 5.68 | 3.99 |
| `post_send` | 5.18 | **2.12** — the `mean_change` there has nothing left to read |
| `total` | 68.35 | **62.23** |
| `round_trip` | 65.10 | **62.90** |

Notes on how:

- The slow path already holds both operands in registers, so metering is three `fabsf` adds per
  pixel. The fast path is a template specialised over five switches; putting a condition inside
  it would have cost more than it saves, and it has only just written its row — so it is metred
  from the row afterwards, which is still in cache.
- Metred **before** `unit`, matching NumPy: the composition was never clamped, only the codec
  clamps. Getting this wrong moves the figure by several parts in a thousand.
- Summed in `double`. In float32 the mean over this many values loses enough to show five places.

`src/bench/check_compose_change.py` is the check the risk above asked for — one process,
alternating, both paths: the encoded frame is identical in 11 of 11 turns and the figure agrees
to 3.7e-09 (slow path) and exactly (fast path). `src/ref/test_native_image.py` still passes,
which is what covers the composition `--dump` keeps.

To go back without a rebuild: `cp work/libnr_image.dll.backup work/libnr_image.dll` (the old dll,
kept) and take the commit out.

## building the library on this machine

> ⚠️ **This section was wrong once and is corrected 2026-10-11 07:3x.** It said "this machine
> has no `cl.exe`". It does: `E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community\...`.
> A `find -maxdepth 12` misses it because `ProgramData` is hidden and `cl.exe` sits 13 levels
> down — the same path was already committed in this tree's own `tools\build_msvc.bat`. Look
> there first. Machine facts now live in project memory §0.5 and `HANDOFF.md` §1.5.

The shipped `work/libnr_image.dll` is an **MSVC** build (depends on `VCOMP140.DLL` +
`KERNEL32` only) and it **reproduces byte for byte** here:

| check | shipped | rebuilt |
|---|---|---|
| size | 146432 | **146432** |
| imports | `VCOMP140.DLL`, `KERNEL32` | same |
| exports | 21 | 21 |
| `vmulps` / `mulss` / `addss` / `vcvtps2ph` | 0 / 510 / 353 / 67 | **0 / 510 / 353 / 67** |
| `cmp` | — | differs at **byte 273** only (PE timestamp) |

The command is `build_win.bat`'s step 5/6 (and `tools\build_msvc.bat`'s step 3/4):

```
cl /nologo /O2 /TP /D_WIN32 /D_CRT_SECURE_NO_WARNINGS /fp:precise /openmp /DNR_F16C \
   /LD src/ref/nr_image.c /link /DEF:work/libnr_image.def
```

with the `.def` scraped from the source (MSVC exports nothing unless told to).

### why not `/arch:AVX2`

The rebuild having no `vmulps` at all invites the obvious fix. Tried, same-source:

| build | `vmulps` | temporal, no mask |
|---|---|---|
| `/O2` (as shipped) | 0 | 9.49 / 10.40 ms |
| `/O2 /arch:AVX2` | **16** | 9.57 / 9.45 ms |

MSVC's vectoriser barely moves — 16 instructions out of a pixel loop that gcc's reorganises
into 2662. Put plainly: **gcc can vectorise this code, MSVC cannot.** So could the dll simply
be shipped as a gcc build? Benchmarked earlier, the gcc `-march=x86-64-v3` build is the *same*
speed (8.61 vs 9.01) — because, as §"is it arithmetic?" establishes, this pass is not waiting
on instructions. Shipping a gcc dll would also trade `VCOMP140` for `libgomp`, and take the
`winmode=0` loading caveat with it. **Not worth it. Keep MSVC.**
