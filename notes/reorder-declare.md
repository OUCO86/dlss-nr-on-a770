# k1_declare.md -- B step 2 (i): the DECLARED change set, written BEFORE any reordered run
# (knife2b #108 / the parent's rule: declare first, then run; any change outside the declared
# set = REFUSE on the spot, no "accept first, explain later").
# Data source: logs/walk_B3_allwitness.txt ([pgt] with ids, [poolblk], [poolseq-canon]) +
# tools/chain_map.csv. All three pairs come from tools/group_census_nearest_pair.csv (gap = 2).

## The three pairs, as recorded (no reorder yet)
pair 568..570  chain 41 (C256)
  c568 xmx_rec_gemm_int8_batched   ids={1050,1051,1305,1306,1307}  pool gets=0
  c569 xmx_rec_quant               ids={1305,1306,1307}            pool gets=0
  c570 xmx_rec_gemm_int8_batched   ids={1052,1053,1305,1306,1308}  pool gets=0
  legs 568/570 share only the two scratch ids {1305,1306}; the intervening 569 overlaps BOTH legs.
pair 567..569  chain 41 (C256)
  c567 xmx_rec_quant               ids={1295,1305,1306}            pool gets=0
  c568 xmx_rec_gemm_int8_batched   ids={1050,1051,1305,1306,1307}  pool gets=0
  c569 xmx_rec_quant               ids={1305,1306,1307}            pool gets=0
pair 235..237  chain 19 (C512)
  c235 quant(FUSED-pack)                 ids={1305,1306,1310}                    pool gets=0
  c236 xmx_rec_gemm_window_int8_residual ids={442,445,446,1284,1303,1305,1306}   pool gets=0
  c237 quant(FUSED-pack)                 ids={1284,1305,1306}                    pool gets=0
  NOTE: 236 and 237 share plane 1284 -- a REAL plane dependency, not just scratch ids.
  This arm is therefore the one expected to be able to FAIL 1301; if it does, that is a
  legitimate REFUSE of the R4/R6 kind (a dependency really was crossed), not a mechanism bug.

## The moves to be applied (one closure each, NR_BMERGE_ORDER, default off)
  arm B5_mv569 : "569>570"   (568 and 570 become adjacent at 568/569)
  arm B5_mv568 : "568>569"   (567 and 569 become adjacent)
  arm B5_mv236 : "236>237"   (235 and 237 become adjacent)
  arm B5_mvall : "569>570,568>569,236>237"  (the first two are in the same region; after the
                  first move the second spec's index refers to the NEW coordinate, which is
                  still 568>569 for the same element -- checked by hand above)

## DECLARED change set (everything outside this = REFUSE)
1. POOL SEQUENCE (military rule 64: canonical ordinals + bucket sizes, never raw pointers):
   PREDICTED **IDENTICAL** hash in every reordered arm (baseline warm = fa4d3da2aa18a510,
   capture = e62607c36a3c7410). Reason: all six permuted closures issue ZERO pool_get/put
   events, so permuting them cannot reorder any pool event; and the hash covers
   (closure index, kind, first-seen ordinal, size) -- a closure with no events contributes nothing.
   If the hash moves at all in these arms => REFUSE and stop.
2. TOUCH SETS ([pgt] ids): the MULTISET of (name, id-set) pairs must be unchanged; only the
   POSITIONS may permute, and only inside {568,569,570}, {567,568,569}, {235,236,237}.
   Any id-set appearing at a position outside those windows => REFUSE.
3. [grp] family member index lists: allowed to shift by the same permutation only.
4. [vec-align]: must stay ALIGNED (five per-capture vectors equal length) -- the reorder moves
   the element in every vector atomically, so a desync here is a bug in MY mechanism, not physics.
5. [skip-chains]: chains_skipped=14 refused=0 closures_noop=168 passes=691 unchanged (the reorder
   runs AFTER the skip pass, so chain ranges were already resolved; if these numbers move => REFUSE).
6. 1301: must be EXACT DD49827DD33A7EF07C2C17892F18970D in EVERY arm (baseline and reordered).
   A mismatch in an arm whose legs share only scratch ids (569/568 moves) would mean the
   reorder crossed a dependency the touch census did not name => stop and report.
   A mismatch in the 236 arm is the expected R4/R6 shape and is still a stop, but a USEFUL one:
   it is the first machine-level demonstration that the declared-set gate actually fires.

## What this experiment is NOT
No merge, no new kernel, no numeric change, no expected frame gain (the parent pre-registered
gain ~ 0): the only question is whether the reorder mechanism itself holds, and whether the
declared-set gate can prove it.
