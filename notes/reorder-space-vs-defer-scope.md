# scope note -- what tools/reorder_space.csv does and does NOT judge (rule 73b)
# written 2026-11-05 after the parent's correction of the fatM_space reading (knife2b #115)

tools/reorder_space.csv (generator s6/pe_b3_space2.py / pe_b3_space3.py) answers ONE question:

  CAN TWO SAME-SHAPE CLOSURES BE MOVED NEXT TO EACH OTHER by a permutation of record order,
  under the dependency relation the engine itself uses (touch overlap = conflict)?

  Its columns (adj_pairs / min_gap / ext_blockers_nearest / move_nearest) are measures of
  MOVING closures. "space_opened = no" means: versioning the plane did not make moving easier.

It does NOT answer the DEFER-AND-MERGE question, which is different and was the one the fat-M
target list actually needs:

  DEFER-AND-MERGE keeps every closure where it is in record order. The earlier shot's GEMM is simply
  re-emitted ONCE, later, at the position of the last member. Nothing moves. Its blocking conditions
  are:
    (a) the members must not write the same plane (or the same slice of it) -- otherwise the merged
        launch destroys the value the intervening chain reads;
    (b) no closure between a member and the merge point may rewrite that member's INPUT planes
        (this is R4 from section 56b in its pure form);
    (c) no closure between a member and the merge point may READ that member's OUTPUT plane -- a
        reader there needs the value before the merged launch would produce it;
    (d) holding the inputs until the merge point must be affordable in device memory.

  That test lives in s6/pe_fatM_defer.py (per-group, tools/fatM_defer_legality.csv) and
  s6/pe_fatM_pairs.py (every same-shape pair with gap <= 40, tools/fatM_defer_pairs.csv).

Do not read a reorder_space verdict as a merge verdict, or the other way round. The two tests can
disagree: a pair can be immovable (adjacency blocked) and still be defer-mergeable in principle --
and the A4 group turned out to fail BOTH, for the stronger reason that the eight members are
consecutive writers and readers of one plane (the residual stream), i.e. they are chain links, not
independent shots.
