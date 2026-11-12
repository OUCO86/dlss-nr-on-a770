import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

T = r'E:\DSH\dlss-nr-on-a770\tools'
# per-closure region bytes from the fresh census (fused, shipped dll)
hop = {}
for line in open(r'E:\DSH\logs\C27_rt_f2.log', encoding='utf-8', errors='replace'):
    m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
    if m:
        hop[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))
# tier per closure
tier_of = {}
for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8')):
    try:
        a, b = int(r['closure_first']), int(r['closure_last'])
    except ValueError:
        continue
    for c in range(a, b + 1):
        tier_of[c] = r['tier']

# which closures touch plan buffer 1267 / 1274, per tier, with the region share of the plane
rows = list(csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8')))
per = collections.defaultdict(lambda: [0, 0])      # (tier, plane) -> [closures, region MB]
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    t = tier_of.get(c, 'OUTSIDE')
    ids = set(r['write_plane_ids'].split()) | set(r['read_plane_ids'].split())
    for p in ('1267', '1274'):
        if p in ids:
            per[(t, p)][0] += 1
# region MB per closure for the residual folds: M_att x C x esz (f32 for 1267 accumulator, f16 for 1274)
M = {'C64': (32640, 64), 'C128': (8928, 128), 'C256': (2560, 256), 'C512': (864, 512)}
print('=== 1267 / 1274 touch counts per tier (graph_dag, fused build) ===')
for (t, p), a in sorted(per.items()):
    print('   tier %-8s plane %s  closures touching = %d' % (t, p, a[0]))

print('\n=== the residual ping-pong arithmetic per tier (region = M x C x esz) ===')
tot_now = tot_res = 0.0
for t, (m, C) in M.items():
    nch = {'C64': 8, 'C128': 12, 'C256': 16, 'C512': 16}[t]
    reg_f32 = m * C * 4 / 1e6
    reg_f16 = m * C * 2 / 1e6
    # split form: every residual fold writes C-out and the next fold reads it back (skip).
    # count the folds per chain from chain_map op_seq
    folds = 0
    for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8')):
        if r['tier'] != t:
            continue
        ops = (r['op_seq'] or '').split(',')
        folds += sum(1 for o in ops if 'RESIDUAL' in o) / nch
        break
    nfold = sum(1 for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8'))
                if r['tier'] == t and 'GEMM_INT8_RESIDUAL' in (r['op_seq'] or ''))
    nfoldw = sum(1 for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8'))
                 if r['tier'] == t and 'GEMM_WINDOW_INT8_RESIDUAL' in (r['op_seq'] or ''))
    # per chain: residual folds = nfold + nfoldw (each = 1 write of C + 1 read of skip)
    per_chain = (nfold + nfoldw) / max(1, nch)
    now = nch * per_chain * (reg_f32 * 2)          # write + read of the residual stream per fold
    resident = nch * 2 * reg_f32                    # 1 read + 1 write per chain at the layer boundary
    tot_now += now; tot_res += resident
    print('   %-5s chains=%-3d M=%-6d C=%-4d region=%6.2f MB  folds/chain=%.2f  split ping-pong=%8.1f MB/帧  resident=%7.1f MB/帧  saved=%8.1f MB/帧' % (
        t, nch, m, C, reg_f32, per_chain, now, resident, now - resident))
print('   TOTAL across the four tiers: split=%.1f MB/帧  resident=%.1f MB/帧  saved=%.1f MB/帧' % (tot_now, tot_res, tot_now - tot_res))
print('   at 560 GB/s = %.2f ms/帧 ; at 190 GB/s (worst form) = %.2f ms/帧' % ((tot_now - tot_res) / 560.0, (tot_now - tot_res) / 190.0))
print('   C64-only saving = ', end='')
m, C = M['C64']; reg = m * C * 4 / 1e6
nch = 8
nfold = sum(1 for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8')) if r['tier'] == 'C64' and 'GEMM_INT8_RESIDUAL' in (r['op_seq'] or ''))
nfoldw = sum(1 for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8')) if r['tier'] == 'C64' and 'GEMM_WINDOW_INT8_RESIDUAL' in (r['op_seq'] or ''))
per_chain = (nfold + nfoldw) / nch
saved64 = nch * (per_chain * 2 - 2) * reg
print('%.1f MB/帧 (=%.2f ms at 560 GB/s) ; C64 tier leg time = 10.416 ms => 25%% = 2.60 ms' % (saved64, saved64 / 560.0))
