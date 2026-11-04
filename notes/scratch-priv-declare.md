# k3_declare.md -- B step 3 (scratch versioning of 1305/1306): the DECLARED change set, written
# BEFORE any versioned run. Format follows s6/k1_declare.md. Anything outside this set = REFUSE and
# stop (the R4/R6 enforcement style the parent asked for).
# Source of the predictions: s6/pe_b3_price.py (the engine's own greedy wave planner, replayed
# offline on the recorded touch sets) + s6/pe_scratch_priv_budget.py (live-interval scan).

## What will be changed
- Plan/runtime planes: id 1305 (int8 packed face, 9,142,272 B) and id 1306 (row-scale plane,
  142,848 B) -- the kept recording's instances of plan-table buffers 1272 / 1273.
- Mechanism: give each producer/consumer GROUP a private copy instead of one shared buffer reused
  by 244 writers and 244 readers. K = 4 concurrent copies (pending the parent's byte-budget OK):
  extra device memory = (K-1) x 9,285,120 B = 26.6 MiB on top of today's [pool] 311 MB / 51 mallocs.
- Numbers VERBATIM: no arithmetic, quantization or rounding changes; only which memory a value
  lands in.

## Predicted post-change readings (these are the declared targets; deviations = stop)
1. 1301 buffer, BOTH arms: EXACT dd49827dd33a7ef07c2c17892f18970d (default = shared, versioned arm
   = must be the SAME md5).
2. [vec-align]: cmds=691 touch=691 group=691 poolblk=691 idsnap=691 -> ALIGNED (unchanged).
3. [skip-chains]: closures=691 names=1382 name_offset=691 chains_skipped=14 refused=0
   closures_noop=168 passes=691 (unchanged).
4. Touch graph ([pgt-final] + the offline planner):
   - the 1305/1306 consecutive links (396 + 396 today) must DISAPPEAR;
   - remaining consecutive links: PREDICTED 498 / 690 (offline number after versioning {1305,1306});
   - wave plan: waves 691 -> PREDICTED 418, maxwidth 1 -> PREDICTED 4, critical path
     114.63 -> PREDICTED 102.57 ms serial (headroom +12.06);
   - the remaining chain holders must be exactly: 1308 (180 links), 1307 (135), 1303 (78),
     1310 (68), 1309 (60) -- anything else appearing as a holder means my id mapping is wrong.
5. [poolseq] canonical sequence: WILL change (that is the point of the shovel). Declared envelope:
   - the per-closure get COUNT may rise only for the 244 writers / 244 readers of 1305/1306, by at
     most +1 each; every other closure's count must be identical;
   - total gets: today 438 per capture run; PREDICTED between 438 and 438 + 3 x (number of distinct
     concurrent groups) with K=4, i.e. <= ~1300;
   - the ORDER of get/put events belonging to closures that never touch 1305/1306 must be
     unchanged (their ordinals may shift only because of interleaving caused by the new copies --
     if a non-participant's own event sequence changes, that is R6 and we stop).
6. [pool] mallocs / bytes: must be reported; PREDICTED mallocs rise from 51 (new bucket sizes for
   the private copies) and bytes rise by roughly 26.6 MiB (K=4). A jump far above that (e.g.
   +2 GiB = the "every writer gets its own copy" upper bound of 2,127 MiB for 1305) = design error,
   stop.
7. Frame arms (the parent's criterion is pending -- see the A/B question in the report):
   - shipping path (cgraph, no env): PREDICTED delta ~= 0 BY CONSTRUCTION, because the cgraph
     executor replays in recorded order and never consults touch sets. This arm is a sanity read
     only.
   - PGRAPH arm (NR_PGRAPH=2): this is where the +12.06 ms serial headroom could be spent; the
     2026-11-01 measurement of that executor was 156 ms at waves=691/maxwidth=1, so the predicted
     test is 418 waves x width 4 -- the arm must come DOWN toward/below the cgraph 57 ms for the
     shovel to be called a win.

## Not claimed
No frame-gain promise. The headroom numbers above are an upper bound from the engine's own planner
(model rule 54), not a measurement of the reordered/versioned executor.


## MEASURED OUTCOME (appended after the runs -- the declare/check loop must be closed in the artifact)
- item 1-3 (1301 both arms EXACT, ALIGNED, skip-chains unchanged): MET.
- item 4 (touch): NOT MET as declared. The declared prediction (links 690->498, waves 691->418,
  maxwidth 1->4, critical path 102.57) came from a MODEL THAT DELETED the plane from the touch sets.
  Real versioning re-types the dependency into K independent chains, so the producer and its own
  consumers still share a physical buffer. Measured (pointer ordinals, rule 64): links 690/690,
  waves 691, maxwidth 1 in BOTH arms; id 1305 maps to 4 distinct pointers (122 closures each) and
  1306 likewise -- the mechanism works, the dependency simply does not disappear.
- item 5 (poolseq envelope): NOT MET as declared -- I predicted the canonical sequence WOULD change;
  measured it did NOT (both arms fa4d3da2aa18a510 / e62607c36a3c7410). Reason: the ring buffers are
  xmx_buf_create_kind allocations, they never go through pool_get/pool_put, so the fetch sequence is
  untouched. My declaration was wrong about the mechanism's footprint, not about behaviour.
- item 6 (pool totals): unchanged (51 / 311 MB) for the same reason; the real device-memory delta is
  the ring: 26.6 MiB at K=4 (versioned_ids=2 extra_bytes=27,855,360), inside the approved budget.
- item 7 (frames): shipping path +0.087 ms (4 pairs, within band); PGRAPH path 72.6 -> 72.9 ms,
  +0.310 ms (4 pairs) => versioning buys the PGRAPH executor nothing either.
