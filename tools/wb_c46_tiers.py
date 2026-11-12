import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

# leg ms per closure (fused = C26 master ledger; plain = rt_p ledger)
def load_rt(path):
    d = {}
    for line in open(path, encoding='utf-8', errors='replace'):
        m = re.match(r'rtcsv (\d+) (\S+) ([0-9.]+) pf=(-?\d+)', line.strip())
        if m:
            d[int(m.group(1))] = (m.group(2), float(m.group(3)))
    return d
F = load_rt(r'E:\DSH\logs\C26_mstlgt_run_timing.txt')
P = load_rt(r'E:\DSH\logs\C30_rt_p_run_timing.txt')

hop = {}
for line in open(r'E:\DSH\logs\C27_rt_f2.log', encoding='utf-8', errors='replace'):
    m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
    if m:
        hop[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))

# chain_map: closure ranges per chain + tier
rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\chain_map.csv', encoding='utf-8')))
tier_of = {}
for r in rows:
    try:
        a, b = int(r['closure_first']), int(r['closure_last'])
    except ValueError:
        continue
    for c in range(a, b + 1):
        tier_of[c] = (r['tier'], r['C'], int(r['chain']))

agg = collections.defaultdict(lambda: [0, 0.0, 0.0, 0.0])   # tier -> closures, fused ms, plain ms, MB
for c, (n, v) in F.items():
    t = tier_of.get(c, ('OUTSIDE-CHAIN', '-'))[0]
    a = agg[t]; a[0] += 1; a[1] += v
    if c in P:
        a[2] += P[c][1]
    if c in hop:
        a[3] += hop[c][2] / 1e6
print('%-16s %8s %11s %11s %11s' % ('tier', 'closures', 'fused ms', 'plain ms', 'MB/frame'))
for k, a in sorted(agg.items(), key=lambda x: -x[1][1]):
    print('%-16s %8d %11.3f %11.3f %11.1f' % (k, a[0], a[1], a[2], a[3]))

# per (tier, family) leg ms, to line up with lmxx kernel classes
tf = collections.defaultdict(lambda: [0, 0.0])
for c, (n, v) in F.items():
    t = tier_of.get(c, ('OUTSIDE-CHAIN', '-'))[0]
    k = (t, n.replace('xmx_rec_', ''))
    tf[k][0] += 1; tf[k][1] += v
print('\nper (tier, family): closures / fused ms  (top 30 by ms)')
for k, a in sorted(tf.items(), key=lambda x: -x[1][1])[:30]:
    print('   %-8s %-30s %4d %9.3f' % (k[0], k[1], a[0], a[1]))
