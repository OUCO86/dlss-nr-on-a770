import csv, sys
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
ch = [r for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace'))
      if (r.get('C') or '').strip() == '512']
leg = list(csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')))
key = None
for k in leg[0]:
    if 'ms' in k.lower():
        key = k; break
famkey = [k for k in leg[0] if 'family' in k.lower() or 'closure' in k.lower()]
print('rt_per_closure columns:', list(leg[0].keys()))
print('ms column:', key)
bycl = {}
for r in leg:
    try:
        bycl[int(r['closure'])] = r
    except (ValueError, KeyError):
        pass
SKIP = {18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32}
tot_live = 0.0; tot_all = 0.0
tile_live = 0.0; tile_all = 0.0
TILE = ('gemm_int8_qkv', 'gemm_window_int8_residual', 'gemm_int8', 'gemm_int8_batched', 'gemm_int8_residual')
for r in ch:
    cid = int(r['chain']); live = cid not in SKIP
    a, b = int(r['closure_first']), int(r['closure_last'])
    s = 0.0; st = 0.0
    for c in range(a, b + 1):
        rr = bycl.get(c)
        if not rr:
            continue
        ms = float(rr[key]) if rr[key] not in (None, '') else 0.0
        fam = (rr.get(famkey[-1]) or '').replace('xmx_rec_', '')
        s += ms
        if fam in TILE:
            st += ms
    tot_all += s; tot_live += s if live else 0
    tile_all += st; tile_live += st if live else 0
    if live:
        print('  live chain %2d  closures %3d-%3d  total %8.3f ms   tile-family %8.3f ms' % (cid, a, b, s, st))
print()
print('all 16 C512 chains: total %8.3f ms   tile-family %8.3f ms (%.1f%%)' % (tot_all, tile_all, 100 * tile_all / tot_all))
print('live  2 C512 chains: total %8.3f ms   tile-family %8.3f ms (%.1f%%)  <<< the tile route ceiling in the SHIPPED block' % (tot_live, tile_live, 100 * tile_live / tot_live))
print('per live chain: total %.3f ms  tile-family %.3f ms' % (tot_live / 2, tile_live / 2))
