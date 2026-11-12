import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

# plane traffic (executed read/write MB per frame + how many commands touch the plane)
tr = {}
for r in csv.DictReader(open(T + r'\plane_traffic.csv', encoding='utf-8')):
    try:
        tr[r['plane_id_this_run']] = (float(r['executed_read_MB_per_frame']), float(r['executed_write_MB_per_frame']),
                                      int(float(r['commands_touching_per_frame'])))
    except (ValueError, KeyError):
        pass

# adjacent RAW pairs from graph_dag, with the planes involved
rows = list(csv.DictReader(open(T + r'\graph_dag.csv', encoding='utf-8')))
pair = collections.defaultdict(lambda: [set(), 0])
for r in rows:
    try:
        c = int(r['closure']); p = int(r['peer_closure'])
    except ValueError:
        continue
    if p != c + 1 or r['edge_type'] != 'RAW':
        continue
    ids = {x for x in (r['shared_plane_ids'] or '').split() if x.isdigit()}
    if not ids:
        continue
    k = (r['family'].replace('xmx_rec_', ''), r['peer_family'].replace('xmx_rec_', ''))
    pair[k][0] |= ids
    pair[k][1] += 1

# attributed removable MB: for each pair type, for each plane, (rd+wr) x (pair's closure-pairs / half the touching commands)
print('%-46s %6s %6s %10s %10s %10s' % ('boundary (writer -> reader)', 'pairs', 'planes', 'MB attrib', 'ms@305.5', 'ms@190'))
out = []
for (fa, fb), (ids, n) in pair.items():
    mb = 0.0
    for pid in ids:
        if pid in tr:
            rd, wr, tot = tr[pid]
            mb += (rd + wr) * min(1.0, n / max(1.0, tot / 2.0))
    out.append((mb, fa, fb, n, len(ids)))
tot_mb = 0.0
for mb, fa, fb, n, np_ in sorted(out, reverse=True):
    tot_mb += mb
    print('%-22s -> %-22s %6d %6d %10.1f %10.3f %10.3f' % (fa, fb, n, np_, mb, mb / 305.5, mb / 190.0))
print('TOTAL attributed intermediate traffic across adjacent boundaries = %.1f MB/frame' % tot_mb)
print('   = %.2f ms/frame at 305.5 GB/s, %.2f ms/frame at 190 GB/s  (frame serial 117.434 ms; frame wall ~42-46 ms)' % (
    tot_mb / 305.5, tot_mb / 190.0))

# geometry of the two sides (from leg_decomp + the shipped sources)
print('\nper-family geometry (shipped):')
geo = {
 'gemm_int8_residual': 's8v8::gemm_b BM128/BN64/BK32 NT32, slm 18,432, 1 barrier (gemm_s8_v8_kernel.hpp:30-32,65-66)',
 'gemm_int8_qkv': 's8v8 family, same NT32 form, slm 18,432',
 'quant': 'quantize_row / pack side, LW 32/64, slm small (publish_kernel.hpp)',
 'quant_window': 'same pack family',
 'window_attention': 'att5::fused (C64/heads2) LW64, keeps QKV/ex/prob in SLM',
 'gemm_window_int8_residual': 'b6_res / s8v9 family, slm ~10,240',
 'gemm_int8_batched': 's8v8 batched, NT32, slm 18,432',
 'window_block': 'wbv4ph::launch_v4ph LW64, slm 45,056, 18 barriers (window_block_v4ph.hpp:34-38)',
 'global_attention': 'packdev pack x4 + f16v1::gemm_b x2 + smax::vit_softmax_tiled (768xLW256, slm 0, barriers 0)',
 'ffn': 'ffnc::launch_ffn_chip', 'ffn_merge': 'ffn2::fused 1a: 1,536 gr x LW64, slm 8,192, 12 SG barriers',
 'unary': 'unary/publish chain',
}
for k, v in geo.items():
    print('   %-26s %s' % (k, v))
