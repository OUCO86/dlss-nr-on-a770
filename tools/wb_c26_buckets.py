import sys
import numpy as np
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c26_buckets.py -- the rule-156 bucket table for a list of face pairs.
#   usage: python wb_c26_buckets.py labelA:pathA.bin:pathB.bin labelB:... ...
# Prints one row per pair: bytes differing (and %), 4 B units differing, half code-step
# histogram, max/median code step, and the NaN/Inf population of A vs B (with the NEW
# counts). Compact table for the parent/user, not a single total.
PAIRS = []
for spec in sys.argv[1:]:
    lbl, a, b = spec.split('|')   # label|pathA|pathB  ('|' avoids the drive-colon clash)
    PAIRS.append((lbl, a, b))
hdr = ('pair', 'bytes_diff', 'bytes%', 'units4_diff', 'halves_diff', 'cs1', 'cs2', 'cs3-8',
       'cs9-64', 'cs65-1k', 'cs>1k', 'cs_max', 'cs_med', 'NaN_A', 'NaN_B', 'Inf_A', 'Inf_B',
       'newNaN', 'newInf')
print('\t'.join(hdr))
for (lbl, pa, pb) in PAIRS:
    A = np.fromfile(pa, dtype=np.uint8); B = np.fromfile(pb, dtype=np.uint8)
    n = min(A.size, B.size)
    same_size = A.size == B.size
    A = A[:n]; B = B[:n]
    if not same_size:
        print('%s\tSIZE MISMATCH %d vs %d' % (lbl, 0, 0)); continue
    bad = int(np.count_nonzero(A != B))
    if bad == 0:
        print('%s\t0\t0.0000\t0\t0\t0\t0\t0\t0\t0\t0\t0\t0\t-\tEXACT\t-\t-\t0\t0' % lbl)
        continue
    ua = A.reshape((-1, 4)); ub = B.reshape((-1, 4))
    u = int(np.count_nonzero(np.any(ua != ub, axis=1)))
    ha = A.view(np.uint16); hb = B.view(np.uint16)
    sel = ha != hb
    hdiff = int(sel.sum())
    sa = ha[sel].astype(np.int64); sb = hb[sel].astype(np.int64)
    step = np.abs(sa - sb)
    hist = [int(np.count_nonzero(step == 1)), int(np.count_nonzero(step == 2)),
            int(np.count_nonzero((step >= 3) & (step <= 8))),
            int(np.count_nonzero((step >= 9) & (step <= 64))),
            int(np.count_nonzero((step >= 65) & (step <= 1024))),
            int(np.count_nonzero(step > 1024))]
    va = A.view(np.uint16).view(np.float16); vb = B.view(np.uint16).view(np.float16)
    na = int(np.isnan(va).sum()); nb = int(np.isnan(vb).sum())
    ia = int(np.isinf(va).sum()); ib = int(np.isinf(vb).sum())
    nn = int(np.count_nonzero(~np.isnan(va) & np.isnan(vb)))
    ni = int(np.count_nonzero(~np.isinf(va) & np.isinf(vb)))
    print('%s\t%d\t%.4f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d' % (
        lbl, bad, 100.0 * bad / n, u, hdiff, hist[0], hist[1], hist[2], hist[3], hist[4],
        hist[5], int(step.max()), int(np.median(step)), na, nb, ia, ib, nn, ni))
print('=== done wb_c26_buckets ===')
