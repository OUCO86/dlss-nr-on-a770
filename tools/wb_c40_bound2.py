import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

# quartet closures on the CURRENT fused build (the 4 consecutive legs ending at each GA)
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
qset = set()
for i in sorted(ms):
    if ms[i][0] == 'xmx_rec_global_attention':
        qset.update(range(i - 3, i + 1))
qset = {j for j in qset if j in ms}
serial = sum(ms[j][1] for j in qset)
print('quartet: %d closures, serial %.3f ms/frame, hop %.1f MB/frame' % (
    len(qset), serial, sum(hop[j][2] for j in qset if j in hop) / 1e6))

rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\graph_dag.csv', encoding='utf-8')))
w_of = collections.defaultdict(set); r_of = collections.defaultdict(set)
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    w_of[c].update(x for x in r['write_plane_ids'].split() if x.isdigit())
    r_of[c].update(x for x in r['read_plane_ids'].split() if x.isdigit())

# per-plane frame traffic (executed read/write MB) + how many commands touch it
pl = {}
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_traffic.csv', encoding='utf-8')):
    try:
        pl[r['plane_id_this_run']] = (float(r['executed_read_MB_per_frame']), float(r['executed_write_MB_per_frame']),
                                      int(float(r['commands_touching_per_frame'])))
    except (ValueError, KeyError):
        pass

# a plane is REMOVABLE by fusing the quartet if it is written by >=1 quartet closure and read by >=1
# (different) quartet closure. Its share of the plane's frame traffic = quartet commands / all commands.
q_cmds = collections.Counter()
for c in qset:
    for pid in w_of[c] | r_of[c]:
        q_cmds[pid] += 1
rem = 0.0; det = []
for pid, n in q_cmds.items():
    wq = any(pid in w_of[c] for c in qset); rq = any(pid in r_of[c] for c in qset)
    if not (wq and rq) or pid not in pl:
        continue
    rd, wr, tot_cmd = pl[pid]
    share = min(1.0, n / max(1, tot_cmd / 2.0))       # quartet closures vs all touching commands
    mb = (rd + wr) * share
    rem += mb
    det.append((pid, mb, rd, wr, n, tot_cmd))
print('\nremovable handoff traffic (quartet-internal planes, share-scaled) = %.1f MB/frame' % rem)
for d in sorted(det, key=lambda x: -x[1])[:10]:
    print('   plane %-6s share-mb %7.1f  (read %8.1f write %8.1f MB/frame; quartet closures %d of %d touching)' % d)
for bw, tag in [(305.5, 'contig'), (224.8, 'gather5'), (190.0, 'pack_scatter')]:
    ms_sav = rem / bw + (len(qset) - 8) * 2.2 / 1000.0
    print('   bound at %s GB/s: traffic %.3f ms + 24 launches 0.053 ms = %.3f ms = %.1f%% of the quartet serial' % (
        tag, rem / bw, ms_sav, 100 * ms_sav / serial))
print('\nWB P3 (backup probe) => skipped by rule: every shipped instance runs grf=128 (C37 ocloc GUARD grf>128 = 0,')
print('leg_decomp grf column 128 on all three families) => a finer WG split needs MORE registers => dead per jun182.')
