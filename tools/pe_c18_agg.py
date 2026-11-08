import io, re, glob, statistics, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

def load(p):
    d = {}
    for ln in io.open(p, encoding='utf-8', errors='replace'):
        m = re.match(r'rtcsv\s+(\d+)\s+(\S+)\s+([0-9.]+)', ln.strip())
        if m:
            d[int(m.group(1))] = (m.group(2), float(m.group(3)))
    return d

def agg(side):
    fs = [load(p) for p in sorted(glob.glob(r'E:\DSH\s6\rt_c18_%s_*.txt' % side))]
    if not fs:
        return None
    fam = collections.Counter()
    for d in fs:
        for i, (f, ms) in d.items():
            fam[f] += ms
    n = len(fs)
    tot = sum(fam.values())
    return dict(n=n, fam={k: v / n for k, v in fam.items()}, tot=tot / n)

A = agg('A'); B = agg('B')
print('procs A=%d B=%d' % (A['n'], B['n']))
print('\n=== fused 族级腿 ms（每进程均值；A = C7 控制，B = C18 变体）===')
print('%-40s %9s %9s %9s' % ('family', 'A', 'B', 'delta'))
keys = sorted(set(A['fam']) | set(B['fam']), key=lambda k: -A['fam'].get(k, 0))
for k in keys[:12]:
    a = A['fam'].get(k, 0.0); b = B['fam'].get(k, 0.0)
    print('%-40s %9.3f %9.3f %+9.3f' % (k, a, b, b - a))
print('%-40s %9.3f %9.3f %+9.3f' % ('TOTAL serial', A['tot'], B['tot'], B['tot'] - A['tot']))

da = [load(p) for p in sorted(glob.glob(r'E:\DSH\s6\rt_c18_A_*.txt'))]
db = [load(p) for p in sorted(glob.glob(r'E:\DSH\s6\rt_c18_B_*.txt'))]
print('\n=== window_block 逐闭包（A vs B 均值）===')
ids = sorted({i for d in da for i, (f, _) in d.items() if f == 'xmx_rec_window_block'})
sa = sb = 0.0
for i in ids:
    va = statistics.mean([d[i][1] for d in da if i in d])
    vb = statistics.mean([d[i][1] for d in db if i in d])
    sa += va; sb += vb
    print('  closure %3d  A=%6.3f  B=%6.3f  delta=%+6.3f  (%+.1f%%)' % (i, va, vb, vb - va, 100 * (vb - va) / va if va else 0))
print('  WB family: A=%.3f  B=%.3f  delta=%+.3f ms/进程 (%+.1f%%)' % (sa, sb, sb - sa, 100 * (sb - sa) / sa))
