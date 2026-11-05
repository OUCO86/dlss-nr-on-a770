# The serial-sum -> frame-time factor (knife2b #131, item (5)) -- recomputed from two measured numbers, not inherited

## The two numbers
| quantity | value | source |
|---|---|---|
| serial sum of the frame's closures | **114.63 ms** (691 rows) | `s6/RT_shipped.timing.txt` (`rtcsv` lines, sum printed with the table) |
| frame time of the shipped build | **57.3 ms/frame** | the standing replay measurement (`nr_replay_now`, shipped `3BAECF2A…`) |
| **factor** | **57.3 / 114.63 = 0.4998 => ~0.50** | this note |

## Why the old 0.43 is obsolete
0.43 was measured on an EARLIER build (before the A5 fusion promotion and before S6-1a). On that build the serial sum was
larger relative to the frame because the fused chains removed serial work but not the same amount of frame time.
**Use 0.50 for the current build and always state the vintage of both numbers.**

## A second vintage in the same folder (do not mix them)
`tools/rt_per_closure.csv` sums to **135.617 ms** (691 rows) -- a different capture of the same 691 closures, i.e. the
per-closure table carries a noisier/higher accounting than `RT_shipped.timing.txt`. Its GEMM FLOP sum is **266.0 GFLOP**,
which at 57.3 ms/frame is **4.64 TFLOP/s** of frame-averaged GEMM throughput.
=> **Any "ms/frame" claim must name which sum it came from.** The scorecard and the autopsy use
`RT_shipped.timing.txt` (114.63 ms) for frame arithmetic and `rt_per_closure.csv` only for per-leg GFLOP/TOPS shape.

## Frame-averaged throughput vs the reference
- us (this build): **266.0 GFLOP of GEMM in 57.3 ms = 4.64 TFLOP/s** frame-averaged;
- them (Arc 140V): **459.6 GFLOP in 327 ms = 1.405 TFLOP/s** frame-averaged (`notes/phase21-fusion-and-tiling.md:214`),
  with the kernel-alone bar 0.73-1.35 TFLOP/s per op (`notes/phase13-torch-and-blas.md:89-98`);
- card peaks: A770 37.5 TFLOP/s f16 / 262 TOPS int8 (`notes/b1-blueprint.md:837`, `notes/optiscaler-bridge.md:1273`);
  Arc 140V 31.9 TFLOP/s f16 / ~64-67 TOPS int8 (`refs .../notes/phase26-the-register-ceiling.md:42-43`).
=> **frame-averaged we are 3.3x their frame-averaged number**, and on the one directly comparable op we are 6.13x faster
(`tools/ref_bench.csv` row "block 0 ffn").
