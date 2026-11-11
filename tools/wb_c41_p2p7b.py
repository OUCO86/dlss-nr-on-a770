import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

# ---- P2 ceiling: even a MAGIC free 1267 (= run plane 1309) for the WB set cannot pass 25%
pl = {}
bad = 0
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_traffic.csv', encoding='utf-8')):
    try:
        pl[r['plane_id_this_run']] = (float(r['executed_read_MB_per_frame']), float(r['executed_write_MB_per_frame']),
                                      int(float(r['commands_touching_per_frame'])), r.get('on_disk_artifact', '') or '')
    except (ValueError, KeyError):
        bad += 1
print('plane_traffic rows=%d unparsed=%d  (looking for the 1267 artifact)' % (len(pl), bad))
hit = [ (k,v) for k,v in pl.items() if '1267' in v[3] ]
print('rows whose artifact mentions 1267:', hit[:3])
if not hit:
    hit = [('1309', pl.get('1309', (370.05, 177.67, 200, 'dumps/bgP_on.1267.bin (from plane_map.csv)')))]
art_key, (rd, wr, tot, art) = hit[0]
print('run-plane 1309 (plan buffer 1267, artifact %s): read %.1f write %.1f MB/frame over %d commands' % (art, rd, wr, tot))
wb_serial = 12.744
for bw in (305.5, 224.8, 190.0):
    magic = (rd + wr) / bw + 0.110
    print('   ABSOLUTE ceiling if every WB closure read 1267 for FREE: %.3f ms = %.1f%% of the WB family serial' % (
        magic, 100 * magic / wb_serial))
# the honest in-set share (WB writes 1267 x4, WB reads it x1 => 5 of 200 commands)
share = 5 / (tot / 2.0)
print('   honest in-set share (5 of %d touching commands => %.3f): %.1f MB => %.3f ms + 0.110 = %.3f ms = %.2f%%' % (
    tot, share, (rd + wr) * share, (rd + wr) * share / 224.8, (rd + wr) * share / 224.8 + 0.110,
    100 * ((rd + wr) * share / 224.8 + 0.110) / wb_serial))

# ---- P7: ffn2::fused stall attribution from the existing stall ledgers (zero GPU)
for f in ['stall_hotspots_d_ctlf.csv', 'stall_hotspots_d_k12f.csv', 'stall_hotspots_bb_aware.csv']:
    p = r'E:\DSH\dlss-nr-on-a770\tools' + '\\' + f
    try:
        rr = list(csv.DictReader(open(p, encoding='utf-8', errors='replace')))
    except OSError:
        print('%s MISSING' % f); continue
    cols = list(rr[0].keys())
    hits = [r for r in rr if any(('ffn2' in (v or '')) or ('ffn_merge' in (v or '')) for v in r.values())]
    print('\n%s: rows=%d ffn2-hits=%d cols=%s' % (f, len(rr), len(hits), cols[:9]))
    for h in hits[:6]:
        print('   ', {k: (v or '')[:46] for k, v in list(h.items())[:7]})
