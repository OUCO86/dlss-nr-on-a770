import csv, re, sys
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
SKIP = {18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32}     # shipped NR_SKIP_CHAINS
pat = re.compile(r'\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}')

# arg positions per family, read straight from the launcher signatures
POS = {
    'GEMM_INT8': (5, 6, 7, None),                       # M, N, K, batch
    'GEMM_INT8_RESIDUAL': (7, 8, 9, None),
    'GEMM_WINDOW_INT8_RESIDUAL': (7, 8, 9, None),
    'GEMM': (3, 4, 5, 6),
    'GEMM_INT8_BATCHED': (5, 6, 7, 8),
    'GEMM_INT8_QKV': (8, None, 9, None),                # M, channels(=K), heads
    'QUANT': (3, 4, None, None),
    'QUANT_WINDOW': (3, 4, None, None),
}
chains = [r for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace'))
          if (r.get('C') or '').strip() == '512']
print('C512 chains in the plan: %d   (shipped skip set: %s)' % (len(chains), sorted(SKIP)))
rows = []
for r in chains:
    cid = int(r['chain']); ln = int(r['plan_line']); n = int(r['n_ops'])
    live = cid not in SKIP
    for i in range(ln, ln + n):
        m = pat.search(L[i - 1])
        if not m:
            continue
        fam = m.group(1).replace('OP_XMX_REC_', '').replace('OP_XMX_', '')
        if 'INIT' in fam:
            continue
        vals = [int(x) for x in re.findall(r'-?\d+', m.group(3))]
        p = POS.get(fam)
        if not p:
            continue
        g = [None if v is None else (vals[v] if v < len(vals) else None) for v in p]
        rows.append((fam, cid, live, g))

print('\n=== legs that SURVIVE the skip (these are the only ones the engine can switch) ===')
for fam in ('GEMM_INT8_QKV', 'GEMM_WINDOW_INT8_RESIDUAL', 'GEMM_INT8', 'GEMM_INT8_BATCHED', 'GEMM',
            'GEMM_INT8_RESIDUAL', 'QUANT', 'QUANT_WINDOW'):
    sel = [x for x in rows if x[0] == fam and x[2]]
    dead = [x for x in rows if x[0] == fam and not x[2]]
    sig = {}
    for _, cid, _, g in sel:
        sig[tuple(g)] = sig.get(tuple(g), 0) + 1
    print('  %-28s live=%-3d skipped=%-3d  live shapes (M,N,K,batch): %s'
          % (fam, len(sel), len(dead), ['x%d %s' % (c, list(k)) for k, c in list(sig.items())[:4]]))

print('\n=== which chains survive ===')
print('  ', sorted({x[1] for x in rows if x[2]}))
