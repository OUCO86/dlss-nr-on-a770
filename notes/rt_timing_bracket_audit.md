# RT bracket audit -- is `NR_RUN_TIMING` a bracket or a single event? (knife2b #133, item (c), ZERO GPU)

## The instrument, verbatim (`src/bench/sycl/libxmx_sycl.cpp`)

```
2278  // NR_RUN_TIMING=1: time every closure so the 89s/frame is attributed to families
2280  static bool rtiming = getenv("NR_RUN_TIMING") != nullptr;
2281  if (rtiming) {
2284      for (auto& fn : g_graphs[id]) {
2285          auto t0 = std::chrono::steady_clock::now();
2286          fn();
2287          GQ->wait();   // section 92: without this the closures submit async and the
2288                        // per-closure wall time is meaningless (GPU overlaps between
2289                        // closures -- the sum exceeded the whole run). Waiting makes
2290                        // each number the family's REAL GPU time. Diagnostic path only.
2291          ms.push_back(... steady_clock::now() - t0 ...);
2292      }
2315          std::fprintf(f, "rtcsv %zu %s %.4f\n", i, nm2, ms[i]);
2334      GQ->wait();
2335      return passes;                     // <-- the shipping path below never runs
2337  // DISPATCH-OVERHEAD PROBE (section 97) ...
2371  // SECTION 98: command_graph replay (the shipping path)
```

## Verdict -- three findings, one of them changes the meaning of every family price

1. **It is not an event instrument at all.** Each number is a **host steady-clock wall bracket**
   around `fn(); GQ->wait();` -- submit (CPU) + GPU drain + sync latency for that closure.
   So it is an **upper bound** on the closure's GPU time, not a lower bound.
2. **It runs on a diagnostic path that RETURNS at line 2335, before the cgraph replay (line 2371+)
   that we ship.** `RT_shipped.timing.txt` / `tools/rt_per_closure.csv` therefore price the
   **plain per-closure loop, not the shipped single-graph frame**. The "factor 0.50"
   (`tools/frame_factor.md`) is a **cross-path ratio** (plain-path serialized wall 114.63 ms vs
   shipped cgraph frame 57.3 ms), not an overlap coefficient. The ledger's own numbers agree:
   the plain path measured **72.6 ms/frame** vs cgraph **57.4 ms** (section 98/PGRAPH door), and
   the RT sum (114.63) exceeds even the plain frame because every closure pays its own submit +
   `wait()` latency.
3. **No mis-attribution**: `tools/rt_per_closure.csv` aligns with the plan 1:1 --
   **0 / 691 family-vs-plan-op mismatches, and the `closure` column equals the row index for all
   691 rows** (`s6/pe_rt_align.py`). So the table's labels are right; only the *meaning* of the
   milliseconds was mis-stated by me.

## What this does to the ga contradiction (and to 军规 111)

- `RT` says a ga leg = 1.42 ms **wall including its submit and sync**; my bench says the softmax
  kernel alone is 2.02 ms. Both cannot be true for the same execution -- and the earlier campaign
  already had this exact datum: **`s6/wbga.md` §9c** measured the softmax at **2.0654-2.4330 ms in a
  probe TU** and **back-derived its in-frame cost to <= 1.07 ms**, calling the remaining 2x gap
  "大 TU 的 inlining/codegen，未定位".
- ⇒ **My §132 claim ("RT understates ga by ~0.9 ms/leg, +60%") is wrong in direction and I retract
  it.** The correct statement: **RT over-states per-closure cost (it is a plain-path wall bracket),
  while the isolated bench arm over-states the kernel's in-frame cost (probe-TU codegen).** The
  softmax's true in-frame price is the back-derived **<= 1.07 ms/leg (~8.6 ms serial for 8 legs)**,
  not 2.02 ms.
- **军规 111 needs re-labelling**: the rule as written ("闭包级归因低估 ga") is the opposite of what
  the source shows. Suggested wording: *"RT/`NR_RUN_TIMING` 是 plain-path 的 host 墙钟括号（含
  submit + wait），返回于 cgraph 之前 ⇒ 它是该闭包的**上界**，且不是出货路径的价；isolated bench
  单核跨度是**该 TU 的价**，in-frame 价必须用帧级反推或括号法复核。两套数不许混。"*

## Which families' rankings are most affected (upper-bound bias)

Per-closure submit+sync costs roughly a constant ~0.05-0.15 ms, so the bias scales with the **number
of closures**:

| family | legs | RT ms | bias direction | why |
|---|---|---|---|---|
| `quant` / `quant_window` | 276 | 4.04 | **over-stated most** | 276 x (submit+wait) on tiny kernels |
| `window_attention` | 52 | 15.89 | over-stated moderately | 52 brackets |
| `gemm_int8_residual` | 68 | 22.47 | over-stated moderately | 68 brackets |
| `window_block` | 10 | 17.92 | **least over-stated** | few, big closures |
| `global_attention` | 8 | 11.37 | least over-stated | few, big |
| `ffn_merge` / `ffn_stem` | 1 / 1 | 3.55 / 1.67 | least | single |
⇒ **Re-ranking risk is concentrated in the many-small-leg families** (quant, wa, residual): their RT
prices are the least trustworthy for GPU cost, and their share of the "hop/quant" story is exactly
where I have been pointing.

## The minimal bracket re-check work order (GPU, <= 45 min, AWAITING APPROVAL)

For the six families above, take 1-2 representative closures each and price them **bracketed in a
bench TU that mirrors the shipped module** (the probe's `timeit_region` arms), 6 processes each:
`6 families x 2 shapes x 6 processes = 72 processes` -- too much; **scope it to 3 families
(quant, window_attention, global_attention) x 1 shape x 6 processes = 18 processes ~ 22 min**, and
report the RT-vs-bracket ratio per family as a bias factor to apply to the ranking table.
