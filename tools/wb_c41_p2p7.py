import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

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

WB = [2, 4, 6, 8, 10, 683, 685, 687, 689, 691]
rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\graph_dag.csv', encoding='utf-8')))
w_of = collections.defaultdict(set); r_of = collections.defaultdict(set)
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    w_of[c].update(x for x in r['write_plane_ids'].split() if x.isdigit())
    r_of[c].update(x for x in r['read_plane_ids'].split() if x.isdigit())
pl = {}
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_traffic.csv', encoding='utf-8')):
    try:
        pl[r['plane_id_this_run']] = (float(r['executed_read_MB_per_frame']), float(r['executed_write_MB_per_frame']),
                                      int(float(r['commands_touching_per_frame'])), r.get('main_edges', ''))
    except (ValueError, KeyError):
        pass

print('=== (1) P2: WB set 2,4,6,8,10 + 683,685,687,689,691 ===')
serial = sum(ms[c][1] for c in WB)
hb = sum(hop[c][2] for c in WB if c in hop)
print('WB serial = %.3f ms/frame   hop = %.1f MB/frame' % (serial, hb / 1e6))
for c in WB:
    print('   closure %-4d %-24s ms=%6.3f planes=%-3d MB=%7.1f  reads=%s writes=%s' % (
        c, ms[c][0].replace('xmx_rec_', ''), ms[c][1], hop[c][1] if c in hop else 0,
        (hop[c][2] / 1e6) if c in hop else 0.0, sorted(w_of[c]), sorted(r_of[c])))
# in-set handoff: written by one WB closure and read by another WB closure
inter = 0.0; det = []
for pid in {p for c in WB for p in w_of[c]}:
    wq = [c for c in WB if pid in w_of[c]]; rq = [c for c in WB if pid in r_of[c]]
    if wq and rq and set(wq) != set(rq) and pid in pl:
        rd, wr, tot, _ = pl[pid]
        share = min(1.0, (len(wq) + len(rq)) / max(1.0, tot / 2.0))
        mb = (rd + wr) * share
        inter += mb; det.append((pid, mb, rd, wr, len(wq), len(rq), tot))
print('   in-WB-set handoff planes: %d, removable share = %.1f MB/frame' % (len(det), inter))
for d in sorted(det, key=lambda x: -x[1])[:8]:
    print('      plane %-6s share %7.1f MB (read %8.1f write %8.1f; WB writers %d readers %d of %d cmds)' % d)
for bw, tag in [(305.5, 'contig'), (224.8, 'gather5'), (190.0, 'pack_scatter')]:
    s = inter / bw + 9 * 2.2 / 1000.0 + 9 * 10 / 1000.0
    print('   bound(%s): traffic %.3f + launches 0.020 + bubbles 0.090 = %.3f ms = %.1f%% of WB serial' % (
        tag, inter / bw, s, 100 * s / serial))
# also: what does 1267 (the ViT image plane) cost the WB set? (input, NOT removable by staging across WB)
for pid in ['1267', '1266', '1265', '1303']:
    if pid in pl:
        rd, wr, tot, e = pl[pid]
        print('   plane %s: read %.1f write %.1f MB/frame, %d cmds touching' % (pid, rd, wr, tot))

print('\n=== (2) P7: ffn_merge (closure 690) internal chain evidence ===')
c = 690
print('   ms=%.3f hop planes=%d MB=%.1f reads=%s writes=%s' % (
    ms[c][1], hop[c][1], hop[c][2] / 1e6, sorted(r_of[c]), sorted(w_of[c])))
for f in ['ffn_fusion_slm.csv', 'tail_dependency_analysis.csv', 'barrier_audit_after.csv']:
    p = r'E:\DSH\dlss-nr-on-a770\tools' + '\\' + f
    try:
        rr = list(csv.DictReader(open(p, encoding='utf-8', errors='replace')))
    except OSError:
        print('   %s MISSING' % f); continue
    hits = [x for x in rr if any('ffn2' in (v or '') or 'ffn_merge' in (v or '') for v in x.values())]
    print('   %s: rows=%d ffn-hits=%d cols=%s' % (f, len(rr), len(hits), list(rr[0].keys())[:10]))
    for h in hits[:4]:
        print('      ', {k: (v or '')[:60] for k, v in list(h.items())[:8]})
