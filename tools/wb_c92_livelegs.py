import csv, sys
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
leg = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    try:
        leg[int(r['closure'])] = r
    except ValueError:
        pass
ch = [r for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace'))
      if (r.get('C') or '').strip() == '512']
print('=== the LIVE chains: per-closure ms (a near-zero closure = folded/no-op) ===')
tot_all = tot_nz = 0.0
n_all = n_nz = 0
for r in ch:
    cid = int(r['chain'])
    if cid not in (25, 33):
        continue
    a, b = int(r['closure_first']), int(r['closure_last'])
    print('-- chain %d (closures %d-%d, %d ops) --' % (cid, a, b, b - a + 1))
    for c in range(a, b + 1):
        rr = leg.get(c)
        if not rr:
            continue
        ms = float(rr['ms'] or 0)
        fam = (rr['family'] or '').replace('xmx_rec_', '')
        tag = 'NO-OP/folded' if ms < 0.002 else ''
        print('   %4d %-28s %8.4f ms  %s' % (c, fam, ms, tag))
        n_all += 1
        tot_all += ms
        if ms >= 0.002:
            n_nz += 1
            tot_nz += ms
print()
print('live chains: closures=%d  real (non-folded) launches=%d  folded/no-op=%d' % (n_all, n_nz, n_all - n_nz))
print('their ms total=%.3f  (per live chain %.3f)' % (tot_all, tot_all / 2))
print('per live chain, real launches=%d  ms=%.3f  vs lmxx 0.10 ms/链 => %.1fx' % (n_nz // 2, tot_all / 2, (tot_all / 2) / 0.10))
