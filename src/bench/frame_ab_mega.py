#!/usr/bin/env python3
"""Frame-level A/B for the B1a megakernel: NR_FUSE_WINDOW_MEGA off vs on.

Runs the whole 960x544 frame twice — once with the folded window block off (the
graph as shipped) and once on — and asserts the final head output is bit-identical,
then reports the pass-count change (the fold must remove dispatches, or the gate
never fired and the equality is vacuous). Two separate backends because the flag is
read when the Runtime is built and the recorded graph differs.

This is the offline gate before the in-game check the user asked for: it proves the
fold changes no output on the real l1 path (narrow=True / EPI_E4M3, which
test_window_mega already showed bit-exact) and that the megakernel is actually
replacing passes in the graph.
"""
import os
import sys
import pathlib

import numpy as np

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / 'ref'))


def head_and_passes(mega):
    os.environ["NR_FUSE_WINDOW_MEGA"] = "1" if mega else "0"
    import nr_frame
    if not nr_frame.WEIGHTS.exists():
        print("frame AB: skipped (local logical weights missing)")
        return None
    backend = nr_frame.ResidentBackend()
    frame = backend.frame(544, 960)
    rng = np.random.default_rng(28)
    color = rng.random((544, 960, 3), dtype=np.float32)
    features = nr_frame.make_features(color, **nr_frame.PROFILES['standard'])
    passes = []
    head = frame.run(features, execution='replay', submits=passes)
    return np.array(head, copy=True), passes[0]


def main():
    off, p_off = head_and_passes(False)
    on, p_on = head_and_passes(True)
    if off is None or on is None:
        return 0
    exact = (off == on).all()
    ndiff = int((off != on).sum())
    print(f"frame AB 960x544: passes off={p_off} on={p_on} (fold removed {p_off - p_on})")
    print(f"head bit-identical: {exact}  ({ndiff} elements differ of {off.size})")
    if not exact:
        a, b = off.astype(np.float64), on.astype(np.float64)
        d = np.abs(a - b)
        rel = d / np.maximum(np.abs(a), 1e-6)
        print(f"  max abs diff: {d.max():.4e}   max rel diff: {rel.max():.4e}")
        # ulp distance on the float32 view of the differing elements
        oa, ob = off.reshape(-1), on.reshape(-1)
        wa = oa.view(np.uint32).astype(np.int64)
        wb = ob.view(np.uint32).astype(np.int64)
        same = np.signbit(oa) == np.signbit(ob)
        dist = np.where(same, np.abs(wa - wb), np.where(oa == ob, 0, 1 << 30))
        worst = int(dist.max())
        print(f"  worst ulp distance: {worst}   (elements >2ulp: {int((dist > 2).sum())})")
        print(f"  diff>0.001 abs: {int((d > 1e-3).sum())}   diff>0.01: {int((d > 1e-2).sum())}")
    if p_off == p_on:
        print("  WARNING: pass count unchanged — the megakernel gate did not fire; "
              "the equality proves nothing.")
        return 2
    return 0 if exact else 1


if __name__ == '__main__':
    raise SystemExit(main())
