import csv, re, sys, collections, statistics
sys.stdout.reconfigure(encoding='utf-8')

RT = r'E:\DSH\logs\C26_mstlgt_run_timing.txt'          # fused master ledger, C18 base (post-C18)
fam = collections.defaultdict(list)
for line in open(RT, encoding='utf-8', errors='replace'):
    m = re.match(r'rtcsv (\d+) (\S+) ([0-9.]+) pf=(-?\d+)', line.strip())
    if m:
        fam[m.group(2)].append(float(m.group(3)))

PL = r'E:\DSH\dlss-nr-on-a770\tools\rt_per_closure.csv'  # plain route, 11-02 = PRE-C18 (flagged)
pl = collections.defaultdict(list); gflop = {}
for r in csv.DictReader(open(PL, encoding='utf-8')):
    try:
        pl[r['family']].append(float(r['ms'])); gflop[r['family']] = float(r['gflop'])
    except ValueError:
        pass

BW = {'contig': 305.5, 'tile8_walk': 219.9, 'col64_stride': 244.1, 'gather5': 224.8,
      'upsample2x': 260.9, 'pack_scatter_w': 190.0}
HOP = {'xmx_rec_window_block': 79.41, 'xmx_rec_global_attention': 47.27, 'xmx_rec_ffn_merge': 108.64}
FORMS = {'xmx_rec_window_block': ('tile8_walk', 'pack_scatter_w'),
         'xmx_rec_global_attention': ('gather5', 'contig'),
         'xmx_rec_ffn_merge': ('upsample2x', 'contig')}

roof = [r for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\xmx_f16_roof.csv', encoding='utf-8'))]
f16 = [float(r['TOPS']) for r in roof if r['dtype'] == 'f16' and r['TOPS']]
f16_best = max(f16); f16_med = statistics.median(f16)

out = []
for k, label in [('xmx_rec_window_block', 'window_block'), ('xmx_rec_global_attention', 'global_attention'),
                 ('xmx_rec_ffn_merge', 'ffn_merge'), ('xmx_rec_ffn', 'ffn (chip_cs2)')]:
    fc, pc = fam.get(k, []), pl.get(k, [])
    fsum, psum = sum(fc), sum(pc)
    if k in HOP:
        mb = HOP[k] * len(fc)
        f1, f2 = FORMS[k]
        flo, fhi = mb / BW[f2], mb / BW[f1]           # ms/frame (fast form .. slow form)
        floform = '%s %.1f GB/s .. %s %.1f GB/s' % (f2, BW[f2], f1, BW[f1])
        basis = 'touched-plane hop census (leg_decomp hop_per_closure_MB x closures; NOT declared footprint)'
    else:
        gf = gflop.get(k, 0.0) * len(fc)
        ach = [gflop[k] / x for x in pc if x]          # TFLOPS achieved per closure (plain ledger)
        flo = gf / f16_best; fhi = gf / f16_med
        floform = 'XMX f16 roof %.2f TOPS (best row) .. %.2f TOPS (median row)' % (f16_best, f16_med)
        basis = 'arithmetic-bound: gflop/frame / XMX f16 roof (no per-family hop census exists for ffn)'
    ratio_lo = fsum / fhi; ratio_hi = fsum / flo       # with the favourable floor first
    gap_lo = fsum - 2.0 * fhi; gap_hi = fsum - 2.0 * flo
    out.append(dict(family=label, fused_n=len(fc), fused_per=round(fsum / len(fc), 3), fused_sum=round(fsum, 3),
                    fused_min=round(min(fc), 3), fused_max=round(max(fc), 3),
                    plain_n=len(pc), plain_per=round(psum / len(pc), 3) if pc else '',
                    plain_sum=round(psum, 3),
                    mb_or_gflop=('%.1f MB/frame' % (HOP[k] * len(fc))) if k in HOP else ('%.2f GFLOP/frame' % (gflop.get(k, 0) * len(fc))),
                    floor_lo=round(flo, 3), floor_hi=round(fhi, 3), floor_form=floform, traffic_basis=basis,
                    mult_lo=round(ratio_lo, 2), mult_hi=round(ratio_hi, 2),
                    gap_lo=round(gap_lo, 3), gap_hi=round(gap_hi, 3),
                    verdict='FAIL' if ratio_lo > 2.0 else ('MARGINAL' if ratio_hi > 2.0 else 'PASS')))

hdr = ['family', 'fused_closures', 'fused_per_closure_ms', 'fused_giants_ms', 'fused_sum_ms',
       'plain_closures', 'plain_per_closure_ms', 'plain_sum_ms', 'executed_bytes_or_flops',
       'floor_ms_lo', 'floor_ms_hi', 'floor_form', 'traffic_basis', 'multiple_lo', 'multiple_hi',
       'gap_to_2x_lo_ms', 'gap_to_2x_hi_ms', 'verdict']
with open(r'E:\DSH\tools\L2_scoreboard.csv', 'w', encoding='utf-8', newline='') as f:
    w = csv.writer(f); w.writerow(hdr)
    for o in out:
        w.writerow([o['family'], o['fused_n'], o['fused_per'], '%.3f-%.3f' % (o['fused_min'], o['fused_max']),
                    o['fused_sum'], o['plain_n'], o['plain_per'], o['plain_sum'],
                    o['mb_or_gflop'], o['floor_lo'], o['floor_hi'], o['floor_form'], o['traffic_basis'],
                    '%.2fx-%.2fx' % (o['mult_lo'], o['mult_hi']), '', '%.3f-%.3f' % (o['gap_lo'], o['gap_hi']),
                    '', o['verdict']])
for o in out:
    print('%-18s fused %d clo sum=%6.3f per=%6.3f (%.3f-%.3f) | plain %d clo sum=%6.3f per=%6.3f | %s | floor %.3f-%.3f | mult %.2f-%.2fx | gap %.2f-%.2f ms | %s' % (
        o['family'], o['fused_n'], o['fused_sum'], o['fused_per'], o['fused_min'], o['fused_max'],
        o['plain_n'], o['plain_sum'], o['plain_per'], o['mb_or_gflop'], o['floor_lo'], o['floor_hi'],
        o['mult_lo'], o['mult_hi'], o['gap_lo'], o['gap_hi'], o['verdict']))
print('\nf16 roof: best=%.2f TOPS median=%.2f (rows=%d)' % (f16_best, f16_med, len(f16)))
print('fused serial total (whole frame, this ledger) = %.3f ms over %d closures' % (
    sum(sum(v) for v in fam.values()), sum(len(v) for v in fam.values())))
print('=== done wb_c38_scoreboard ===')
