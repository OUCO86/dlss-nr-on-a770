import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

# 1) the C64 chains: closure ranges from chain_map.csv
cm = list(csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace')))
print('chain_map cols:', list(cm[0].keys())[:14])
c64 = [r for r in cm if (r.get('C') or '').strip() == '64']
print('C64 chains:', len(c64))
rngs = []
for r in c64[:3]:
    print('   sample row:', {k: (v[:40] if isinstance(v, str) else v) for k, v in list(r.items())[:8]})

# 2) hop census: closure -> (name, touched ids, bytes)
pat = re.compile(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=([\d,]+) scr=\d+ ids= (.*)$')
hop = {}
for line in open(r'E:\DSH\logs\C27_rt_f2.log', encoding='utf-8', errors='replace'):
    m = pat.search(line)
    if m:
        hop[int(m.group(1))] = (m.group(2).replace('xmx_rec_', ''),
                                [int(x) for x in m.group(5).split()],
                                int(m.group(4).replace(',', '')))

INTER = {1272, 1273, 1274, 1275, 1276, 1277, 1270, 1286, 1287, 1311, 1312, 1314, 1315, 1316}
HEAD_TAIL = {1267, 1309}

# figure out the C64 closure ids from chain_map (columns holding closure ranges)
def closures_of(rows):
    ids = set()
    for r in rows:
        try:
            a, b = int(r['closure_first']), int(r['closure_last'])
            ids.update(range(a, b + 1))
        except (ValueError, KeyError):
            pass
    return ids

cids = closures_of(c64)
print('C64 closure ids parsed:', len(cids), sorted(cids)[:12], '...', sorted(cids)[-6:] if cids else '')

if cids:
    tot = inter = ht = other = 0
    fam = collections.Counter()
    for c in cids:
        if c not in hop:
            continue
        nm, ids, by = hop[c]
        tot += by
        if any(i in INTER for i in ids):
            inter += by
        if any(i in HEAD_TAIL for i in ids):
            ht += by
        fam[nm] += by
    print('\n=== C64 chain closures: hop bytes (region口径, per touch totals) ===')
    print('   total                       = %8.1f MB/frame' % (tot / 1e6))
    print('   closures touching INTERNAL planes = %8.1f MB/frame (%.1f%%)' % (inter / 1e6, 100.0 * inter / tot if tot else 0))
    print('   closures touching head/tail      = %8.1f MB/frame (%.1f%%)' % (ht / 1e6, 100.0 * ht / tot if tot else 0))
    for f, by in fam.most_common(10):
        print('     %-30s %9.1f MB' % (f, by / 1e6))
    print('\n   A1 removes the INTERNAL plane round trips => removed share = %.1f%%' % (100.0 * inter / tot if tot else 0))
    print('   at B_L2_reuse 854.6 GB/s: %.2f ms/frame   at DRAM 291.1: %.2f ms/frame' % (
        inter / 1e6 / 854.6 * 1000.0 / 1000.0 * 1000, inter / 1e6 / 291.1))
