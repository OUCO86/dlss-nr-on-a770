import csv, re, sys
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()

chains = [r for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace'))
          if (r.get('C') or '').strip() == '512']
pat = re.compile(r'\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}')

print('=== the C512 tier: every step REAL args as the launcher receives them ===')
seen = {}
for r in chains[:4]:
    ln = int(r['plan_line']); n = int(r['n_ops'])
    print('\n-- chain %s (M_att=%s, %d ops, plan line %d) --' % (r['chain'], r['M_att'], n, ln))
    for i in range(ln, ln + n + 10):
        m = pat.search(L[i - 1])
        if not m:
            print('   line %d: NOT A STEP: %s' % (i, L[i - 1][:80])); continue
        op, nargs, body = m.group(1), int(m.group(2)), m.group(3)
        vals = [int(x) for x in re.findall(r'-?\d+', body)]
        print('   %-34s nargs=%-3d vals=%s' % (op.replace('OP_XMX_REC_', ''), nargs, vals[:14]))
        seen.setdefault(op.replace('OP_XMX_REC_', ''), []).append(vals)

print('\n=== distinct arg signatures per family across the whole tier ===')
for fam, rows in sorted(seen.items()):
    sigs = {}
    for v in rows:
        sigs[tuple(v)] = sigs.get(tuple(v), 0) + 1
    print('  %-30s variants=%d' % (fam, len(sigs)))
    for k, c in list(sigs.items())[:3]:
        print('      x%-3d %s' % (c, list(k)[:14]))
