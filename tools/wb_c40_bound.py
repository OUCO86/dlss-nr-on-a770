import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

# ---- 1) find the C512 att quartets on the CURRENT fused build (qkv + global_attention + quant + residual)
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

names = [ms[i][0] for i in sorted(ms)]
quart = []
for i in sorted(ms):
    if ms[i][0] != 'xmx_rec_global_attention':
        continue
    grp = [i - 3, i - 2, i - 1, i]
    lab = [ms[j][0] for j in grp if j in ms]
    if lab == ['xmx_rec_gemm_int8_qkv', 'xmx_rec_global_attention', 'xmx_rec_quant', 'xmx_rec_gemm_int8_residual'] or \
       ['xmx_rec_gemm_int8_qkv'] <= lab and 'xmx_rec_global_attention' in lab:
        pass
    # accept any 4-window ending at GA that contains qkv + quant
    w = [ms[j][0] for j in range(i - 3, i + 1) if j in ms]
    if 'xmx_rec_gemm_int8_qkv' in w and 'xmx_rec_quant' in w:
        quart.append(tuple(range(i - 3, i + 1)))
    else:
        # widen: the quartet may not be exactly 4 consecutive
        w2 = [ms[j][0] for j in range(i - 4, i + 1) if j in ms]
        quart.append(('WIDE', i, w2))
print('GA closures:', [i for i in sorted(ms) if ms[i][0] == 'xmx_rec_global_attention'])
print('quartet windows:')
for q in quart[:10]:
    print('   ', q, [ms[j][0].replace('xmx_rec_', '') + ' ' + '%.3f' % ms[j][1] for j in (q if not isinstance(q[0], str) else range(q[1] - 4, q[1] + 1)) if j in ms])

# ---- 2) the legs inside each quartet: sum ms + hop bytes
qset = set()
for q in quart:
    if isinstance(q[0], str):
        qset.update(range(q[1] - 4, q[1] + 1))
    else:
        qset.update(q)
qset = {i for i in qset if i in ms}
fam = collections.Counter(ms[i][0] for i in qset)
tot_ms = sum(ms[i][1] for i in qset)
tot_hop = sum(hop[i][2] for i in qset if i in hop)
print('\nquartet closures=%d families=%s' % (len(qset), dict(fam)))
print('quartet serial ms = %.3f   hop total = %.1f MB' % (tot_ms, tot_hop / 1e6))

# ---- 3) intermediates INSIDE the quartets: edges whose both ends are in the same quartet
rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\graph_dag.csv', encoding='utf-8')))
inside = collections.defaultdict(int)
for r in rows:
    try:
        a = int(r['closure']); b = int(r['peer_closure'])
    except ValueError:
        continue
    if a in qset and b in qset and a != b and r['edge_type'] in ('RAW', 'WAR', 'WAW'):
        pb = int(r['plane_bytes'].replace(',', '')) if r['plane_bytes'].strip() else 0
        inside[(a, b, r['edge_type'])] = pb
print('\nin-quartet edges (intermediate planes that a fused kernel could keep on-chip): %d' % len(inside))
for k, v in list(sorted(inside.items(), key=lambda x: -x[1]))[:12]:
    print('   %s %s -> %s  plane %s B' % (k[1], k[0], k[2], v))
inter = sum(inside.values())
print('   sum of intermediate full-plane bytes = %.1f MB  (UPPER bound: a region join would price less)' % (inter / 1e6))

# ---- 4) the bound: what fusion can remove = intermediate write+read traffic + (legs-1) launches/closure-chain
BW = 224.8   # gather5 arm (conservative-ish); contig 305.5 for the optimistic end
launch_us = 2.2
n_chains = len(quart)
removed_launches = (len(qset) - n_chains) if n_chains else 0
for bw, tag in [(305.5, 'contig'), (224.8, 'gather5'), (190.0, 'pack_scatter')]:
    save_ms = inter / (bw * 1e6) + removed_launches * launch_us / 1000.0
    print('   bound with %s (%.1f GB/s): traffic %.3f ms + launches %d x 2.2us = %.3f ms  => %.1f%% of the quartet serial %.3f ms' % (
        tag, bw, inter / (bw * 1e6), removed_launches, removed_launches * launch_us / 1000.0,
        100.0 * save_ms / tot_ms, tot_ms))
