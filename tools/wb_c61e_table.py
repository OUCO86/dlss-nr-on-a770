import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
rows = [r for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace'))]
per = collections.defaultdict(lambda: collections.Counter())
tot = collections.Counter()
for r in rows:
    f = (r['family'] or '').replace('xmx_rec_', '')
    if f == 'gemm_int8_residual':
        try:
            K = int(r['K']); Mp = int(r['Mp']) if r.get('Mp') else 0
        except ValueError:
            K = 0
        per[K]['n'] += 1
        try:
            per[K]['ms'] += float(r['ms'])
        except ValueError:
            pass
        if Mp:
            per[K]['mp_not128'] += (Mp % 128 != 0)
        else:
            per[K]['mp_unknown'] += 1

print('=== gir (gemm_int8_residual) by K -- the predicate is (K %% 64 == 0 && K <= 512) ===')
print('%-8s %-6s %-10s %-14s %s' % ('K', 'n', 'serial ms', 'new-path?', 'Mp %% 128 != 0'))
for K in sorted(per):
    c = per[K]
    newp = 'YES' if (K % 64 == 0 and K <= 512) else 'no (falls back)'
    print('%-8d %-6d %-10.3f %-16s %s' % (K, c['n'], c['ms'], newp, c['mp_not128']))
print('total closures =', sum(c['n'] for c in per.values()),
      ' covered by the predicate =', sum(c['n'] for K, c in per.items() if K % 64 == 0 and K <= 512))

# the C61b predicate (K % 64 == 0, no K<=512 cap) -- what C61b actually switched
print('\n=== what C61b switched (K %% 64 == 0 only) vs C61c/d (K %% 64 == 0 && K <= 512) ===')
a = sum(c['n'] for K, c in per.items() if K % 64 == 0)
b = sum(c['n'] for K, c in per.items() if K % 64 == 0 and K <= 512)
print('   C61b: %d closures   C61c/d: %d closures   DIFFERENT SET = %d closures' % (a, b, a - b))
print('   => C61b and C61c/d read the SAME packed plane only for the %d shared closures;' % b)
print('      for the %d K>512 closures C61b used s8v8b while C61c/d used s8v8.' % (a - b))
print('   => yet all three builds produced the IDENTICAL plain-1301 md5 (249A46F3...):')
print('      C61b (old packer + gather reader) == C61c/d (new packer + linear reader) byte-for-byte,')
print('      and both != the shipped build (old packer + old reader).')
print('   => CONCLUSION: the plain-route divergence is NOT shape-coverage related and is NOT')
print('      the bmerge site (dead path). It is a property of the s8v8b reader/packer PAIR that')
print('      is invariant to which of the two implementations is used, while the fused route is')
print('      EXACT => the two routes must differ in WHICH gir instances reach this site.')

# route-level closure census from the two RUN_TIMING ledgers (no shapes there, but the label
# sequence is the route's real execution list)
def labels(p):
    out = []
    for L in open(p, encoding='utf-8', errors='replace'):
        t = L.split()
        if len(t) >= 3 and t[0] == 'pass':
            out.append(t[2])
    return out
f = labels(r'E:\DSH\logs\C30_rt_f_run_timing.txt')
q = labels(r'E:\DSH\logs\C30_rt_p_run_timing.txt')
for name, seq in (('fused(rt_f)', f), ('plain(rt_p)', q)):
    c = collections.Counter(x for x in seq if 'residual' in x)
    print('\n   %-14s passes=%d  residual-family labels: %s' % (name, len(seq), dict(c)))
