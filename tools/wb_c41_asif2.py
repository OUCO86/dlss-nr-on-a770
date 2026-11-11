import csv, re, sys
sys.stdout.reconfigure(encoding='utf-8')

# ---- plane_map gives, per run-plane, the recorder families x slot counts, the dtype evidence,
#      the f16 round-trip measurement and the executed traffic (plane_traffic.csv) ----
tr = {}
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_traffic.csv', encoding='utf-8')):
    try:
        tr[r['plane_id_this_run']] = (float(r['executed_read_MB_per_frame']), float(r['executed_write_MB_per_frame']),
                                      int(float(r['commands_touching_per_frame'])))
    except (ValueError, KeyError):
        pass

SER = {'window_block': 12.744, 'global_attention': 3.562, 'ffn_merge': 1.482, 'ffn': 4.904,
       'gemm_int8_residual': 22.438, 'window_attention': 13.664, 'gemm_int8_qkv': 12.500,
       'gemm_window_int8_residual': 14.574}
MB = {'window_block': 794.1, 'global_attention': 378.1, 'ffn_merge': 108.6, 'ffn': 677.0,
      'gemm_int8_residual': 5724.6, 'window_attention': 2465.3, 'gemm_int8_qkv': 3092.8,
      'gemm_window_int8_residual': 4093.6}
FORM = {'window_block': 190.0, 'global_attention': 224.8, 'ffn_merge': 305.5, 'ffn': 305.5,
        'gemm_int8_residual': 305.5, 'window_attention': 305.5, 'gemm_int8_qkv': 305.5,
        'gemm_window_int8_residual': 305.5}

sav = {k: 0.0 for k in SER}
f32planes = []
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_map.csv', encoding='utf-8')):
    pid = r['plane_id_this_run']
    dt = (r.get('measured_dtype') or '') + ' ' + (r.get('dtype_evidence') or '')
    dom = r.get('measured_domain_and_f16_safety') or ''
    recs = r.get('recorders (name x slot count)') or ''
    if pid not in tr:
        continue
    rd, wr, tot = tr[pid]
    if 'f32' not in dt:
        continue
    pairs = re.findall(r'xmx_rec_([a-z_0-9]+)\s*x(\d+)', recs)
    if not pairs:
        continue
    n_tot = sum(int(n) for _, n in pairs)
    f32planes.append((pid, rd + wr, n_tot, dom[:70], ' '.join('%s x%s' % p for p in pairs)[:80]))
    for fam, n in pairs:
        if fam in sav:
            sav[fam] += (rd + wr) * (int(n) / n_tot) * 0.5      # f16 halves that traffic

print('f32-class planes with per-family slot attribution:')
for p in f32planes:
    print('   plane %-6s exec %8.1f MB/frame  slots %d  [%s]' % (p[0], p[1], p[2], p[4]))
    print('          f16 evidence: %s' % p[3])
print('\n=== P8 as-if table (f32 accumulator slabs -> f16; only that traffic halves) ===')
print('%-30s %8s %8s %8s %8s %8s %8s %8s' % ('family', 'leg ms', 'MB now', 'MB as-if', 'floor now', 'floor as-if', 'mult now', 'mult as-if'))
tot_sav = 0.0
for fam in SER:
    s = sav[fam]; tot_sav += s
    mb2 = MB[fam] - s
    f1 = MB[fam] / FORM[fam]; f2 = mb2 / FORM[fam]
    print('%-30s %8.3f %8.1f %8.1f %8.3f %8.3f %7.2fx %7.2fx' % (
        fam, SER[fam], MB[fam], mb2, f1, f2, SER[fam] / f1, SER[fam] / f2))
print('total as-if traffic removed = %.1f MB/frame' % tot_sav)
for bw in (305.5, 224.8, 190.0):
    print('   frame-level gain at %.1f GB/s = %.3f ms/frame' % (bw, tot_sav / bw))
