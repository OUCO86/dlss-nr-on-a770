import sys, re, os
import numpy as np
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c28_sweep.py -- the C28 step-4 clean picture ledger for the TH sweep.
#   usage: python wb_c28_sweep.py <ctl-leg> <leg1> [<leg2> ...]
# Per leg: how many frames actually ran the twin (from the engine verdict print, cross-checked
# against the face stamp), the steady-state ms split master/twin, and for the faces `result`
# and `1301` the bucket set: bytes differing, 4 B units (pixels) differing, code-step
# histogram, max/median, NaN/Inf of A vs B, new NaN/Inf. One row per bucket pair -- NOT a
# single total (rule 156).
D = r'E:\DSH\tmp\c27dump'
MAGIC = '1d578ac2c871e751'   # the twin stamp's first 8 bytes (see wb_c28_stamp.py)
def parse(p):
    ver, st, runs = [], {}, []
    for l in open(p, encoding='utf-8', errors='replace'):
        s = l.strip()
        m = re.search(r'frames=\d+ skipped=(\d+) lastdiff=(-?\d+).*-> (MASTER|TWIN)', s)
        if m: ver.append((int(m.group(1)), int(m.group(2)), m.group(3)))
        m = re.search(r'stamp run=(\d+) f1287=([0-9a-f]{32})', s)
        if m: st[int(m.group(1))] = m.group(2)
        m = re.search(r'run (\d+): ([0-9.]+) ms', s)
        if m: runs.append((int(m.group(1)), float(m.group(2))))
    return ver, st, runs
def buckets(a, b):
    A = np.fromfile(a, dtype=np.uint8); B = np.fromfile(b, dtype=np.uint8)
    n = min(A.size, B.size); A = A[:n]; B = B[:n]
    bad = int(np.count_nonzero(A != B))
    if bad == 0: return 'EXACT'
    u = int(np.count_nonzero(np.any(A.reshape(-1, 4) != B.reshape(-1, 4), axis=1)))
    ha = A.view(np.uint16); hb = B.view(np.uint16)
    sel = ha != hb
    sa = ha[sel].astype(np.int64); sb = hb[sel].astype(np.int64); step = np.abs(sa - sb)
    h = [int(np.count_nonzero(step == 1)), int(np.count_nonzero(step == 2)),
         int(np.count_nonzero((step >= 3) & (step <= 8))), int(np.count_nonzero((step >= 9) & (step <= 64))),
         int(np.count_nonzero((step >= 65) & (step <= 1024))), int(np.count_nonzero(step > 1024))]
    va = A.view(np.float16); vb = B.view(np.float16)
    na, nb = int(np.isnan(va).sum()), int(np.isnan(vb).sum())
    ia, ib = int(np.isinf(va).sum()), int(np.isinf(vb).sum())
    nn = int(np.count_nonzero(~np.isnan(va) & np.isnan(vb))); ni = int(np.count_nonzero(~np.isinf(va) & np.isinf(vb)))
    return ('bytes=%d(%.4f%%) units=%d hist=%s max=%d med=%d NaN=%d->%d Inf=%d->%d newNaN=%d newInf=%d'
            % (bad, 100.0 * bad / n, u, '/'.join(str(x) for x in h), int(step.max()),
               int(np.median(step)), na, nb, ia, ib, nn, ni))
legs = sys.argv[1:]
ctl = legs[0]
cv, cs, cr = parse(r'E:\DSH\logs\C27_%s.log' % ctl)
print('control leg = %s   twin frames by stamp = %d   runs=%d' % (
    ctl, sum(1 for k in cs if cs[k] .startswith(MAGIC)), len(cr)))
for lg in legs[1:]:
    v, s, r = parse(r'E:\DSH\logs\C27_%s.log' % lg)
    nth = sum(1 for k in s if s[k] .startswith(MAGIC))
    nth_print = sum(1 for x in v if x[2] == 'TWIN')
    ms_t = [mm[1] for i, mm in enumerate(r) if (v[i][2] == 'TWIN' if i < len(v) else False)]
    ms_m = [mm[1] for i, mm in enumerate(r) if (v[i][2] == 'MASTER' if i < len(v) else False)]
    def rep(x):
        x = sorted(x)
        return '-' if not x else 'n=%d med=%.2f min=%.2f max=%.2f' % (len(x), x[len(x)//2], x[0], x[-1])
    th = re.search(r't(\-?\d+)$', lg).group(1) if re.search(r't(\-?\d+)$', lg) else '?'
    print('== %s : TH=%s  twin_frames stamp=%d print=%d  master_ms[%s]  twin_ms[%s]' % (
        lg, th, nth, nth_print, rep(ms_m), rep(ms_t)))
    for face in ('result', '1301'):
        a = os.path.join(D, 'f.c27_%s.%s.bin' % (lg, face))
        b = os.path.join(D, 'f.c27_%s.%s.bin' % (ctl, face))
        if os.path.isfile(a) and os.path.isfile(b):
            print('     %-7s vs ctl: %s' % (face, buckets(b, a)))
        else:
            print('     %-7s : dump missing (%s / %s)' % (face, os.path.isfile(a), os.path.isfile(b)))
print('=== done wb_c28_sweep ===')
