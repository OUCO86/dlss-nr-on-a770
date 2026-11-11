import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

P = r'E:\DSH\dlss-nr-on-a770\tools\stall_sites.csv'
rows = list(csv.DictReader(open(P, encoding='utf-8', errors='replace')))
print('rows=%d' % len(rows))

def num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return 0.0

agg = collections.defaultdict(lambda: dict(sites=0, src=0.0, dst=0.0, tot=0.0,
                                           src_cy=0.0, dst_cy=0.0, raw=0.0, addr=0.0, waw=0.0, pay=0.0, oth=0.0))
for r in rows:
    inst = (r['instance'] or '')[:34]
    a = agg[inst]
    a['sites'] += 1
    ns, nd, nt = num(r['n_src_waits']), num(r['n_dst_waits']), num(r['total_waits'])
    fs, fd, mx = num(r['first_src_dist']), num(r['first_dst_dist']), num(r['max_dist'])
    a['src'] += ns; a['dst'] += nd; a['tot'] += nt
    a['src_cy'] += ns * max(fs, 1.0); a['dst_cy'] += nd * max(fd, 1.0)
    a['raw'] += num(r['CLASS_RAW']); a['addr'] += num(r['CLASS_ADDR_RECYCLE'])
    a['waw'] += num(r['CLASS_WAW']); a['pay'] += num(r['CLASS_store_payload']); a['oth'] += num(r['CLASS_other'])

KEEP = ['xmx_rec_gemm_int8_qkv', 'xmx_rec_gemm_int8_residual', 'xmx_rec_window_block',
        'xmx_rec_window_attention', 'xmx_rec_ffn_merge', 'ffn2L', 'ffncL', 'smax', 'att5',
        'xmx_rec_gemm_window_int8_residual', 'xmx_rec_global_attention', 'wbv4ph', 'wbv4', 'gemm_s8']
print('%-36s %6s %7s %7s %7s %8s %8s %7s' % ('instance(prefix)', 'sites', 'srcW', 'dstW', 'totW', 'src_cyc', 'dst_cyc', 'math%'))
for k, a in sorted(agg.items(), key=lambda x: -x[1]['tot']):
    if not any(s in k for s in KEEP):
        continue
    cy = a['src_cy'] + a['dst_cy']
    mathpct = 100.0 * a['dst_cy'] / cy if cy else 0.0
    print('%-36s %6d %7.0f %7.0f %7.0f %8.0f %8.0f %6.1f%%' % (
        k, a['sites'], a['src'], a['dst'], a['tot'], a['src_cy'], a['dst_cy'], mathpct))
