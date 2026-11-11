import csv, re, sys, collections
import numpy as np
sys.stdout.reconfigure(encoding='utf-8')

# ---------- per-family touched MB from the fresh C39 census (fused route, shipped dll) ----------
hop = {}
for line in open(r'E:\DSH\logs\C27_rt_f2.log', encoding='utf-8', errors='replace'):
    m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
    if m:
        hop[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))
fam_mb = collections.defaultdict(float)
for c, (n, pl_, by) in hop.items():
    fam_mb[n] += by / 1e6

# ---------- plane table: which planes are f32-class and how big their executed traffic is ----------
pl = {}
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_traffic.csv', encoding='utf-8')):
    try:
        pl[r['plane_id_this_run']] = dict(rd=float(r['executed_read_MB_per_frame']), wr=float(r['executed_write_MB_per_frame']),
                                          tot=int(float(r['commands_touching_per_frame'])), dtype=r['dtype_evidence'],
                                          save=r['f16_saving_MB_per_frame (executed/2)'], risk=r['join_confidence'])
    except (ValueError, KeyError):
        pass
# map plan-buffer ids (graph_dag) to run-plane ids via plane_map's artifact column when present
pm = {}
for r in csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\plane_map.csv', encoding='utf-8')):
    pm[r['plane_id_this_run']] = r.get('recorders (name x slot count)', '')

# family -> the f32-class planes it touches, and the share of that plane's commands
rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\graph_dag.csv', encoding='utf-8')))
touch = collections.defaultdict(set)          # (family, plan_buffer) -> closures
for r in rows:
    try:
        c = int(r['closure'])
    except ValueError:
        continue
    fam = hop.get(c, ('?', 0, 0))[0]
    for pid in (r['read_plane_ids'] + ' ' + r['write_plane_ids']).split():
        if pid.isdigit():
            touch[(fam, int(pid))].add(c)

FAMS = ['xmx_rec_window_block', 'xmx_rec_global_attention', 'xmx_rec_ffn_merge', 'xmx_rec_ffn',
        'xmx_rec_gemm_int8_residual', 'xmx_rec_window_attention', 'xmx_rec_gemm_int8_qkv',
        'xmx_rec_gemm_window_int8_residual']
BW = {'contig': 305.5, 'gather5': 224.8, 'pack_scatter': 190.0}
SER = {'xmx_rec_window_block': 12.744, 'xmx_rec_global_attention': 3.562, 'xmx_rec_ffn_merge': 1.482,
       'xmx_rec_ffn': 4.904, 'xmx_rec_gemm_int8_residual': 22.438, 'xmx_rec_window_attention': 13.664,
       'xmx_rec_gemm_int8_qkv': 12.500, 'xmx_rec_gemm_window_int8_residual': 14.574}
FORM = {'xmx_rec_window_block': 'pack_scatter', 'xmx_rec_global_attention': 'gather5',
        'xmx_rec_ffn_merge': 'contig', 'xmx_rec_ffn': 'contig'}

print('=== P8 as-if: f32 accumulator planes -> f16 (traffic halved on those planes only) ===')
print('%-34s %8s %8s %8s %8s %8s %8s' % ('family', 'MB now', 'MB f16', 'floor now', 'floor f16', 'mult now', 'mult f16'))
tot_sav = 0.0
for fam in FAMS:
    mb = fam_mb[fam]
    # f16-able traffic = the family's share of the planes whose measured dtype is f32
    sav = 0.0
    for (f, pb), cs in touch.items():
        if f != fam:
            continue
        # plan buffer ids 1300..1317 are the big slab planes; look up run-plane 1309/1313/1311/1314/1316 by id match
        rp = pl.get(str(pb))
        if not rp or 'f32' not in (rp['dtype'] or ''):
            continue
        share = min(1.0, len(cs) / max(1.0, rp['tot'] / 2.0))
        sav += (rp['rd'] + rp['wr']) * share * 0.5
    tot_sav += sav
    fl = FORM.get(fam, 'gather5')
    fn = mb / BW[fl]
    f16 = max(0.0, mb - sav) / BW[fl]
    print('%-34s %8.1f %8.1f %8.3f %8.3f %7.2fx %7.2fx  (leg %.3f ms)' % (
        fam, mb, mb - sav, fn, f16, SER[fam] / fn, SER[fam] / f16, SER[fam]))
print('total as-if traffic removed (all families, upper bound) = %.1f MB/frame' % tot_sav)
for bw, tag in BW.items():
    print('   frame-level gain at %s GB/s = %.3f ms/frame' % (tag, tot_sav / bw))

# ---------- numeric risk: f16 rounding on a 12-stage residual accumulator chain ----------
print('\n=== numeric risk: residual chain with an f16 rounding at every stage ===')
rng = np.random.default_rng(20261112)
for stages in (12, 68):
    acc = np.zeros(200000, dtype=np.float64)
    sig = 0.0
    for i in range(stages):
        add = rng.normal(0.0, 1.0, acc.size)
        accn = acc + add
        acc = accn.astype(np.float16).astype(np.float64)      # the f16 accumulator rounding
        sig += add ** 2
    err = np.sqrt(np.mean((acc - np.cumsum(np.zeros(0)) * 0) ** 2))  # placeholder
    # measure vs the true (f64) chain
    true = np.zeros(acc.size); rng2 = np.random.default_rng(20261112)
    for i in range(stages):
        true += rng2.normal(0.0, 1.0, acc.size)
    e = acc - true
    rms = np.sqrt(np.mean(e ** 2)); sig_rms = np.sqrt(np.mean(true ** 2))
    print('   %2d stages: signal RMS %.3f  error RMS %.4f  rel %.2e  SNR %.1f dB' % (
        stages, sig_rms, rms, rms / sig_rms, 20 * np.log10(sig_rms / rms)))
print('   f16 ulp on a unit-scale value = 2^-11 = 4.88e-4; single rounding SNR ~ 66 dB')
print('   RES8 (the byte-plane knife already judged dead): SNR 17 dB << 40 dB approval line')
