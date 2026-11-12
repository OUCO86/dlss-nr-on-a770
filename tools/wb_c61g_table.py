import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
rows = [r for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace'))
        if (r['family'] or '').replace('xmx_rec_', '') == 'gemm_int8_residual']
g = collections.defaultdict(lambda: {'n': 0, 'ms': 0.0, 'closures': []})
for r in rows:
    K = int(r['K']); N = int(r['N']); M = int(r['M'])
    key = (K, N, M)
    g[key]['n'] += 1
    g[key]['ms'] += float(r['ms'])
    g[key]['closures'].append(r['closure'])
print('=== the gir decision table (predicate = K%%64==0 && K<=512) -- (K,N,M) shape groups ===')
print('%-6s %-6s %-6s %-4s %-9s %-9s %-34s' % ('K', 'N', 'M', 'legs', 'serial ms', 'BK64?', 'closure ids (first 6)'))
b64 = 0
for (K, N, M) in sorted(g, key=lambda x: (x[0], x[1])):
    d = g[(K, N, M)]
    yes = (K % 64 == 0 and K <= 512)
    b64 += d['n'] if yes else 0
    print('%-6d %-6d %-6d %-4d %-9.3f %-9s %-34s' % (
        K, N, M, d['n'], d['ms'], 'YES' if yes else 'no',
        ','.join(d['closures'][:6]) + ('...' if d['n'] > 6 else '')))
print('\ntotal legs = %d   BK64 = %d   BK32 fallback = %d' % (sum(d['n'] for d in g.values()), b64,
      sum(d['n'] for d in g.values()) - b64))
ns = sorted({N for (K, N, M) in g})
mps = sorted({M for (K, N, M) in g})
print('N set =', ns, '  M set =', mps)
print('\n=== what the C61f host arm ACTUALLY covered ===')
print('  one shape only: K in {64,128,512} with M=Mp=256, N=64, narrow=false, half_skip=false, epi=0')
print('  engine gir shapes above: N values %s, M values %s, and the flags (narrow/half_skip/epi) vary per leg' % (ns, mps))
print('  => the pair is proven bit-exact ONLY for the covered subset; the plain-1301 red is invariant')
print('     to packer/reader implementation => the uncovered (N, Mp, epi, half_skip, narrow) space is')
print('     where the divergence lives. Extend the SAME arm over the full shape/flag grid (no new bench).')
