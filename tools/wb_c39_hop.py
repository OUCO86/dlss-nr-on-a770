import re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

FAM = ['xmx_rec_window_block', 'xmx_rec_global_attention', 'xmx_rec_ffn_merge', 'xmx_rec_ffn',
       'xmx_rec_gemm_int8_residual', 'xmx_rec_window_attention', 'xmx_rec_gemm_int8_qkv',
       'xmx_rec_gemm_window_int8_residual']
BW = {'contig': 305.5, 'tile8_walk': 219.9, 'col64_stride': 244.1, 'gather5': 224.8,
      'upsample2x': 260.9, 'pack_scatter_w': 190.0}
FORMS = {'xmx_rec_window_block': ('pack_scatter_w', 'tile8_walk'),
         'xmx_rec_global_attention': ('contig', 'gather5'),
         'xmx_rec_ffn_merge': ('contig', 'upsample2x'),
         'xmx_rec_ffn': ('contig', 'gather5')}

def parse(logp, rtp):
    # per-closure ms from the run_timing ledger
    ms = {}
    try:
        for line in open(rtp, encoding='utf-8', errors='replace'):
            m = re.match(r'rtcsv (\d+) (\S+) ([0-9.]+) pf=(-?\d+)', line.strip())
            if m:
                ms[int(m.group(1))] = (m.group(2), float(m.group(3)), int(m.group(4)))
    except OSError:
        pass
    # per-closure hop bytes from the leg log
    hop = {}
    for line in open(logp, encoding='utf-8', errors='replace'):
        m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
        if m:
            hop[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))
    return ms, hop

for tag, logp, rtp in [('FUSED', r'E:\DSH\logs\C27_rt_f.log', r'E:\DSH\logs\C30_rt_f_run_timing.txt'),
                       ('PLAIN', r'E:\DSH\logs\C27_rt_p.log', r'E:\DSH\logs\C30_rt_p_run_timing.txt')]:
    ms, hop = parse(logp, rtp)
    print('=== %s route: closures ms=%d hop=%d ===' % (tag, len(ms), len(hop)))
    fam = collections.defaultdict(list); famhop = collections.defaultdict(lambda: [0, 0])
    for c, (n, v, pf) in ms.items():
        fam[n].append(v)
    for c, (n, pl, by) in hop.items():
        famhop[n][0] += by; famhop[n][1] += pl
    for n in FAM:
        v = fam.get(n)
        if not v:
            continue
        mb = famhop[n][0] / 1e6
        f1, f2 = FORMS.get(n, ('contig', 'gather5'))
        fl_lo = mb / BW[f2]; fl_hi = mb / BW[f1]
        tot = sum(v)
        print('  %-34s n=%-3d per=%6.3f sum=%7.3f | hop MB/frame=%8.1f planes=%-5d | floor %.3f..%.3f ms | mult %.2f..%.2fx' % (
            n, len(v), tot / len(v), tot, mb, famhop[n][1], fl_lo, fl_hi, tot / fl_hi, tot / fl_lo))
    if hop:
        tot_bytes = sum(v[0] for v in famhop.values()) / 1e6
        print('  ALL-family hop total = %.1f MB/frame over %d planes' % (tot_bytes, sum(v[1] for v in famhop.values())))
