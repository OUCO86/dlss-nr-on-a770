import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

T = r'E:\DSH\dlss-nr-on-a770\tools'
TARGET = '1274'          # the plan buffer id (run-plane 1313)

# ---- 1) who writes / reads 1274, per closure, with operand position if recorded
rows = list(csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8')))
W = collections.defaultdict(set); R = collections.defaultdict(set)
edges = collections.Counter()
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    fam = r['family']
    if TARGET in r['write_plane_ids'].split():
        W[fam].add(c)
    if TARGET in r['read_plane_ids'].split():
        R[fam].add(c)
    if TARGET in (r['shared_plane_ids'] or '').split():
        edges[(fam, r['peer_family'], r['edge_type'])] += 1
print('=== plan buffer 1274 (run-plane 1313) ===')
print('WRITER families:')
for f, cs in sorted(W.items()):
    print('   %-34s closures=%d  %s' % (f, len(cs), sorted(cs)[:14]))
print('READER families:')
for f, cs in sorted(R.items()):
    print('   %-34s closures=%d  %s' % (f, len(cs), sorted(cs)[:14]))
print('edge pairs (writer-family, reader-family, type) with counts:')
for k, v in edges.most_common(14):
    print('   %-70s %d' % (str(k), v))

# ---- 2) the plane_map view: slot counts and operand positions
for r in csv.DictReader(open(T + r'\plane_map.csv', encoding='utf-8')):
    if r['plane_id_this_run'] == '1313':
        print('\nplane_map 1313: recorders -> %s' % (r.get('recorders (name x slot count)') or '')[:300])
        print('              operand positions -> %s' % (r.get('operand positions seen') or '')[:300])
        print('              commands/frame touching=%s  executed r/w MB=%s/%s  dtype=%s' % (
            r.get('commands_per_frame_touching_it'), r.get('executed_read_MB_per_frame'),
            r.get('executed_write_MB_per_frame'), r.get('measured_dtype')))
        break

# ---- 3) the code sites: where each recorder family passes this buffer
CPP = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp'
src = open(CPP, encoding='utf-8', errors='replace').read().split('\n')
print('\n=== recorder function definitions in libxmx_sycl.cpp (candidate sites) ===')
for i, L in enumerate(src):
    if re.search(r'void\s+xmx_rec_(gemm_int8_qkv|window_attention|quant|gemm|gemm_int8_batched|unary)\s*\(', L):
        print('   %5d: %s' % (i + 1, L.strip()[:120]))
