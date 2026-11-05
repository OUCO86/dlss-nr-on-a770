# Launch-counter instrument -- design (knife2b #140, host only; NO engine edit made yet)

Purpose (the parent's standing order after D closed): turn "how many submissions are left, and what is
each leg's time made of" into a measurement instead of an inference. Two counters, both presence-gated,
both diagnostic-path only (the shipping replay must be untouched -- rule 41/93 lineage).

## What to count, per closure
```
[lcount] cmd=<idx> name=<closure> pf=<parallel_for> st=<single_task> sub=<submit>
         mc=<memcpy> ms=<memset> bar=<ext_oneapi_submit_barrier>
         planes_w=<n>(<bytes>) planes_r=<n>(<bytes>)
[lcount-total] pf=… st=… sub=… mc=… ms=… hop_write_bytes=… hop_read_bytes=…
```
Printed once per graph id at capture/replay end, and (for the A/B acceptance) once per arm so the two
arms can be diffed closure by closure.

## Why the obvious "counting queue proxy" does NOT work here
Every helper takes `sycl::queue&` and the recorders pass `*GQ` (`packdev::pack_a16_b(*GQ, …)`,
`qr_launch(*GQ, *GD, …)`, `f16v1::gemm_b(*GQ, …)`). Replacing `GQ`'s type with a counting proxy would
break ~hundreds of those call sites. So the instrument goes the other way:

## The chosen shape: TLS closure id + one bump line per launch helper
1. **TLS cursor**: `static thread_local int g_lc_cur = -1;` set by the replay/record loops that already
   iterate closures (`libxmx_sycl.cpp:2284` the RT loop, `:2350` the submit probe, `:2400` the cgraph
   record, `:2487` the warm loop): `g_lc_cur = (int)fi;` before `fn()`, `-1` after.
2. **Counters**: `static std::vector<LCount> g_lcount;` sized to the closure count when `NR_LCOUNT` is
   set (rule 57 discipline: the vectors are cleared in `xmx_begin`/`xmx_abort`, and the presence gate
   means zero cost when unset).
3. **Bump sites** (one line each, in the launch helpers, not at call sites):
   `packdev::{pack_a16_b, pack_b16_b, pack_b16_t_b, pack_a16, pack_b16, pack_a16_v, pack_b16_t,
   gather_pack_*, pack_a_fused*}`, `s8v8::{gemm, gemm_b, gemm_b_pub, gemm_b_pub_slm, gemm32_b,
   gemm32_b_pub, gemm_b_res, gemm_b_res_window, gemm_resid_pub}`, `f16v1::{gemm_b, gemm_b_pub_f16,
   gemm_b_merge_scale, gemm_pub_pa16, gemm, gemm_resid_pub}`, `qres::gemm_qkv_res`,
   `smax::{vit_softmax_tiled, vit_softmax_kernel, softmax_i8_kernel}` (these are launched through
   `GQ->parallel_for` at the recorder, so those ~6 recorder-side launches get an explicit bump),
   `qr_launch`, `ffnc::launch_ffn_chip`, `wbmega::*`, `att5::*`, and the recorder-side
   `GQ->parallel_for` for `merge_heads_scale` (`libxmx_sycl.cpp:4875`) and the pool/memcpy helpers.
   Counting inside the helper also captures the graph-capture path for free, because capture replays the
   same helper bodies.
4. **`[hop]` numbers** reuse the existing per-closure operand vectors (`g_cmds_touch`, and the id mirror
   `g_pg_pending_ids`) -- no new per-closure vector unless it is cleared with them (the §B step-1 desync
   bug is the cautionary tale).

## Cost and risk
- ~25 one-line bumps + ~40 lines of counter/report code; **all inside `if (g_lc_cur >= 0)`**, so the
  shipping path is byte-identical when `NR_LCOUNT` is unset;
- it requires an engine rebuild to run => **variant into `builds\` only**, never `out\libxmx.dll`;
  the shipped slot stays `3BAECF2A…` and the three golds stay untouched;
- acceptance for the instrument itself: the census must reproduce the already-known closure count
  (691) and the per-family launch totals must be consistent with `tools/shapes_alive.csv` leg counts;
  if they do not, the instrument is wrong, not the frame.

## What it buys (the reason the parent wants it)
Tonight's unresolved attributions are all "how many submissions and of what kind":
- `global_attention` 8 legs: six launches measured at 0.175 ms without the softmax (region) -- the
  instrument says whether the frame's graph actually replays those six or fewer after A5-style fusion;
- the 28 D-reachable / 44 D-unreachable quant points: the census turns "independent pass" into a
  counted launch + counted plane round-trip;
- the hop ledger (10.42 GB, 18.60 ms floor): `[hop]` makes the before/after byte claim checkable
  instead of inferred (rule 104).
