import re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

LOGS = [r'E:\DSH\logs\C53_tile_p%d.log' % i for i in (1, 2, 3)]
pat = re.compile(r'^\s{2}(\S.*?)\s+(raw|pub)\s+ms=\s*([0-9.]+)\s+GB/s=\s*([0-9.]+)\s+vs560=\s*([0-9.]+)%.*?GF/s=\s*([0-9]+)\s+diff=(\S+?)\s+SLM=(\d+)KB')
data = collections.defaultdict(lambda: collections.defaultdict(list))   # shape -> (variant,kind) -> rows
for lg in LOGS:
    try:
        txt = open(lg, encoding='utf-8', errors='replace').read()
    except OSError:
        print('missing', lg); continue
    shape = None
    for L in txt.split('\n'):
        m = re.match(r'== shape (\(.*?\)).*wg=(\d+)', L)
        if m:
            shape = m.group(1) + ' wg=' + m.group(2); continue
        m = pat.match(L)
        if m and shape:
            data[shape][(m.group(1).strip(), m.group(2))].append(
                dict(ms=float(m.group(3)), gb=float(m.group(4)), pct=float(m.group(5)),
                     gf=int(m.group(6)), diff=m.group(7), slm=int(m.group(8))))

for sh, d in data.items():
    ref = d.get(('shipped gemm_b', 'raw')); refp = d.get(('shipped gemm_b_pub', 'pub'))
    if not ref:
        continue
    r0 = min(r['ms'] for r in ref); rp0 = min(r['ms'] for r in refp) if refp else None
    print('\n== %s ==' % sh)
    print('   %-24s %-8s %-8s | %-8s %-8s | %-7s %-6s %-6s %s' % ('variant', 'raw ms', 'Δraw%', 'pub ms', 'Δpub%', 'GB/s', 'GF/s', 'SLM', 'diff/procs'))
    order = ['shipped gemm_b', 'd1', 'd3', 'bk64_d1', 'bk64_d2', 'bn128_nt64', 'bn128_nt64_bk64_d1',
             'bn128_nt64_bk64_d2', 'bn128_ser_d2', 'bn128_ser_d3', 'bn128_ser_bk64_d1', 'bn128_naive']
    for v in order:
        raw = d.get((v, 'raw')); pub = d.get((v, 'pub'))
        if not raw:
            continue
        mr = min(r['ms'] for r in raw); m0 = raw[0]
        mp = min(r['ms'] for r in pub) if pub else None
        dr = 100.0 * (mr - r0) / r0
        dp = (100.0 * (mp - rp0) / rp0) if (mp and rp0) else None
        diffs = {r['diff'] for r in raw + (pub or [])}
        print('   %-24s %8.4f %+8.1f%% | %8s %8s | %7.1f %6d %5dKB %s x%d' % (
            v, mr, dr,
            ('%8.4f' % mp) if mp else '    n/a ', ('%+7.1f%%' % dp) if dp is not None else '    n/a ',
            m0['gb'], m0['gf'], m0['slm'], ','.join(sorted(diffs)), len(raw)))
