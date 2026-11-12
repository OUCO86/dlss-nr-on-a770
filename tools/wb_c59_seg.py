import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

# face bytes + executed MB/frame per slab
slab = {}
for r in csv.DictReader(open(T + r'\plane_traffic.csv', encoding='utf-8', errors='replace')):
    pid = r['plane_id_this_run']
    try:
        face = int(r['bytes']) / 1e6
        ex = float(r['executed_total_MB_per_frame'])
    except (ValueError, KeyError):
        continue
    slab[pid] = (face, ex, int(r['commands_touching_per_frame']))

# family per closure (from the RUN_TIMING ledger names)
fam_of = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    try:
        fam_of[int(r['closure'])] = (r['family'] or '').replace('xmx_rec_', '')
    except (ValueError, KeyError):
        pass

C32FAM = {'pre', 'unary', 'unary2', 'quant', 'gemm'}      # the C32 segment families (quant(FUSED-pack) is a quant row)
touch = collections.Counter()      # (slab) -> touches by C32 families
tot = collections.Counter()        # slab -> total touches
for r in csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8', errors='replace')):
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    f = fam_of.get(c, '')
    ids = set(r['write_plane_ids'].split()) | set(r['read_plane_ids'].split())
    for p in ids:
        tot[p] += 1
        if f in C32FAM:
            touch[p] += 1

print('%-6s %10s %12s %8s %10s %10s %12s %12s' % ('slab', 'face MB', 'exec MB/帧', 'touches', 'C32 touch', 'C32 share', 'removable MB', 'ms@291.1'))
L2 = 16.0
rem_tot = 0.0
for pid, (face, ex, n) in sorted(slab.items(), key=lambda x: -x[1][1])[:12]:
    share = (touch[pid] / n) if n else 0.0
    c32_ex = ex * share
    if face > L2:
        # re-reads exceed L2 -> they are DRAM-served; residency leaves 1 write + 1 read of the face
        rem = max(0.0, c32_ex - 2.0 * face * share)
    else:
        rem = 0.0        # the whole plane is L2-resident -> residency saves instructions, not DRAM
    rem_tot += rem
    print('%-6s %10.2f %12.1f %8d %10d %10.2f %12.1f %12.2f  %s' % (
        pid, face, ex, n, touch[pid], share, rem, rem / 291.1,
        'L2-absorbed (face<=16MB)' if face <= L2 else 'DRAM-served re-reads'))
print('\n=== C32-segment residency: removable DRAM traffic = %.0f MB/帧' % rem_tot)
print('    at 291.1 GB/s (B_DRAM_contiguous read)  = %.2f ms/帧' % (rem_tot / 291.1))
print('    at 340.0 GB/s (B_DRAM copy)             = %.2f ms/帧' % (rem_tot / 340.0))
print('    at 854.6 GB/s (if it were L2 traffic)   = %.2f ms/帧' % (rem_tot / 854.6))
print('    4 ms/帧 出口线 => %s' % ('PASS (run the bench arm)' if rem_tot / 291.1 >= 4.0 else 'STOP (bound below the line)'))
