import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

tier_of = {}
for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8')):
    try:
        a, b = int(r['closure_first']), int(r['closure_last'])
    except ValueError:
        continue
    for c in range(a, b + 1):
        tier_of[c] = r['tier']

rows = list(csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8')))
touch = collections.defaultdict(set)       # closure -> {1267/1274}
role = collections.defaultdict(lambda: [0, 0])   # (tier,plane) -> [writes, reads]
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    for p in ('1267', '1274'):
        if p in r['write_plane_ids'].split():
            touch[c].add(p); role[(tier_of.get(c, 'OUT'), p)][0] += 1
        if p in r['read_plane_ids'].split():
            touch[c].add(p); role[(tier_of.get(c, 'OUT'), p)][1] += 1
print('=== every plan-level touch of 1267 / 1274, by tier (writes, reads) ===')
tw = tr = 0
for k, v in sorted(role.items()):
    print('   tier %-8s plane %s : writes=%-4d reads=%-4d' % (k[0], k[1], v[0], v[1]))
    tw += v[0]; tr += v[1]
print('   TOTAL writes=%d reads=%d touches=%d' % (tw, tr, tw + tr))

# region size per touching closure, from the shapes ledger
sh = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8')):
    try:
        sh[int(r['closure'])] = (r['family'], int(r['M']), r['N'], r['K'])
    except (ValueError, KeyError):
        pass
# the touched planes' region per closure = M x C x esz; C comes from the tier (64/128/256/512) or the family
Cmap = {'C64': 64, 'C128': 128, 'C256': 256, 'C512': 512}
tot = collections.Counter()
for c, ps in touch.items():
    t = tier_of.get(c, 'OUT')
    C = Cmap.get(t)
    if not C:
        continue
    m = sh.get(c, (None, 0, None, None))[1]
    if not m:
        continue
    for p in ps:
        esz = 4 if p == '1267' else 2
        tot[(t, p)] += m * C * esz / 1e6
print('\n=== region-based executed traffic for 1267 / 1274 (the 口径 the L2 scoreboard uses) ===')
allm = 0.0
for (t, p), mb in sorted(tot.items()):
    print('   tier %-6s plane %s : %8.1f MB/帧' % (t, p, mb))
    allm += mb
print('   TOTAL 1267+1274 region traffic = %.1f MB/帧 (%.2f GB)' % (allm, allm / 1000.0))
print('   frame hop census (all planes, C39 fresh) = 30,848 MB/帧 = 30.85 GB')
print('   => the plan-level "1267 = 26.7 GB/帧" (W122 x R278 x full face 66.85 MB) is the FULL-FACE 口径;')
print('      the region 口径 gives %.2f GB for 1267+1274 combined, i.e. %.1f%% of the frame census' % (
    allm / 1000.0, 100.0 * allm / 30848.0))
