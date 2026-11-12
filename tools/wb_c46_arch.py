import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

T = r'E:\DSH\dlss-nr-on-a770\tools'
LOG = r'E:\DSH\logs'

# ---------------- (1) our 693 closures: family composition ----------------
ms = {}
for line in open(r'E:\DSH\logs\C30_rt_f_run_timing.txt', encoding='utf-8', errors='replace'):
    m = re.match(r'rtcsv (\d+) (\S+) ([0-9.]+) pf=(-?\d+)', line.strip())
    if m:
        ms[int(m.group(1))] = (m.group(2), float(m.group(3)), int(m.group(4)))
hop = {}
for line in open(r'E:\DSH\logs\C27_rt_f2.log', encoding='utf-8', errors='replace'):
    m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
    if m:
        hop[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))
fam = collections.defaultdict(lambda: [0, 0.0, 0, 0])
for c, (n, v, pf) in ms.items():
    a = fam[n]; a[0] += 1; a[1] += v
    if c in hop:
        a[2] += hop[c][2]; a[3] += hop[c][1]
print('=== (1) our fused frame: %d closures ===' % len(ms))
print('%-36s %5s %9s %11s %8s %9s' % ('family', 'clos', 'leg ms', 'MB/frame', 'planes', 'ms/launch'))
tot_ms = tot_mb = 0.0
for k, a in sorted(fam.items(), key=lambda x: -x[1][0]):
    print('%-36s %5d %9.3f %11.1f %8d %9.4f' % (k.replace('xmx_rec_', ''), a[0], a[1], a[2] / 1e6, a[3],
          a[1] / max(1, a[3])))
    tot_ms += a[1]; tot_mb += a[2]
print('TOTAL closures=%d  serial ms=%.3f  MB/frame=%.1f' % (len(ms), tot_ms, tot_mb / 1e6))
print('launches/frame (planes as proxy) = %d' % sum(a[3] for a in fam.values()))

# ---------------- (2) adjacent block boundaries: removable handoff traffic ----------------
rows = list(csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8')))
pair = collections.defaultdict(lambda: [set(), 0, 0])       # (fa,fb) -> (plane ids, closures, )
plane_bytes = {}
for r in rows:
    try:
        c = int(r['closure']); p = int(r['peer_closure'])
    except ValueError:
        continue
    if p != c + 1 or r['edge_type'] != 'RAW':
        continue
    fa = r['family'].replace('xmx_rec_', ''); fb = r['peer_family'].replace('xmx_rec_', '')
    ids = {x for x in (r['shared_plane_ids'] or '').split() if x.isdigit()}
    if not ids:
        w = {x for x in r['write_plane_ids'].split() if x.isdigit()}
        rd = {x for x in r['peer_closure'] and (rows[0]['read_plane_ids'] or '').split()}
        ids = w
    key = (fa, fb)
    pair[key][0] |= ids
    pair[key][1] += 1
# per-plane full bytes from plane_map
for r in csv.DictReader(open(T + r'\plane_map.csv', encoding='utf-8')):
    try:
        plane_bytes[r['plane_id_this_run']] = int(r['bytes'])
    except (ValueError, KeyError):
        pass
# plan-buffer ids that graph_dag uses map onto the 1300s slab handles; keep both views
print('\n=== (2) adjacent (closure i -> i+1) RAW handoffs, by op-pair ===')
out = []
for (fa, fb), (ids, n, _x) in pair.items():
    mb = sum(plane_bytes.get(i, 0) for i in ids) / 1e6
    known = sum(1 for i in ids if i in plane_bytes)
    out.append((mb, fa, fb, n, len(ids), known))
for mb, fa, fb, n, nid, known in sorted(out, reverse=True)[:18]:
    print('   %-26s -> %-26s pairs=%-5d planes=%-3d (sized %d)  full-plane MB/frame=%.1f' % (fa, fb, n, nid, known, mb))
print('   ... %d distinct adjacent op-pairs total' % len(out))

# ---------------- (3) per-family kernel geometry (grf / slm / LW headroom) ----------------
print('\n=== (3) shipped kernel geometry per family (leg_decomp.csv) ===')
for r in csv.DictReader(open(T + r'\leg_decomp.csv', encoding='utf-8')):
    if r.get('grf'):
        print('   %-22s %-44s grf=%-4s simd=%-3s slm=%-7s barriers=%-3s clo=%-4s pf=%-4s' % (
            r.get('family', ''), (r.get('biggest_kernel') or '')[:44], r.get('grf'), r.get('simd'),
            r.get('slm_bytes'), r.get('barrier_count'), r.get('closures'), r.get('launches_pf')))
