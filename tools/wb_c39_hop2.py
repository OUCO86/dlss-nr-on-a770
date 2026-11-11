import re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

FAM = ['xmx_rec_window_block', 'xmx_rec_global_attention', 'xmx_rec_ffn_merge', 'xmx_rec_ffn',
       'xmx_rec_gemm_int8_residual', 'xmx_rec_window_attention', 'xmx_rec_gemm_int8_qkv',
       'xmx_rec_gemm_window_int8_residual', 'xmx_rec_quant', 'xmx_rec_unary']
BW = {'contig': 305.5, 'tile8_walk': 219.9, 'col64_stride': 244.1, 'gather5': 224.8,
      'upsample2x': 260.9, 'pack_scatter_w': 190.0}
FORMS = {'xmx_rec_window_block': ('pack_scatter_w', 'tile8_walk'),
         'xmx_rec_global_attention': ('contig', 'gather5'),
         'xmx_rec_ffn_merge': ('contig', 'upsample2x'),
         'xmx_rec_ffn': ('contig', 'gather5')}

def read_ms(p):
    d = {}
    for line in open(p, encoding='utf-8', errors='replace'):
        m = re.match(r'rtcsv (\d+) (\S+) ([0-9.]+) pf=(-?\d+)', line.strip())
        if m:
            d[int(m.group(1))] = (m.group(2), float(m.group(3)))
    return d

def read_hop(p):
    d = {}
    for line in open(p, encoding='utf-8', errors='replace'):
        m = re.search(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=(\d+)', line)
        if m:
            d[int(m.group(1))] = (m.group(2), int(m.group(3)), int(m.group(4)))
    return d

for tag, msp, hpp in [('FUSED', r'E:\DSH\logs\C30_rt_f_run_timing.txt', r'E:\DSH\logs\C27_rt_f2.log'),
                      ('PLAIN', r'E:\DSH\logs\C30_rt_p_run_timing.txt', r'E:\DSH\logs\C27_rt_p2.log')]:
    ms = read_ms(msp); hop = read_hop(hpp)
    fam = collections.defaultdict(list); fh = collections.defaultdict(lambda: [0, 0, 0])
    for c, (n, v) in ms.items():
        fam[n].append(v)
    for c, (n, pl, by) in hop.items():
        fh[n][0] += by; fh[n][1] += pl; fh[n][2] += 1
    print('=== %s route: ms rows=%d hop rows=%d ===' % (tag, len(ms), len(hop)))
    for n in FAM:
        v = fam.get(n)
        if not v:
            continue
        mb = fh[n][0] / 1e6
        f1, f2 = FORMS.get(n, ('contig', 'gather5'))
        if mb <= 0:
            print('  %-34s n=%-3d per=%6.3f sum=%7.3f | NO HOP ROWS' % (n, len(v), sum(v) / len(v), sum(v)))
            continue
        lo, hi = mb / BW[f2], mb / BW[f1]
        tot = sum(v)
        print('  %-34s n=%-3d per=%6.3f sum=%7.3f | hop %8.1f MB (%d planes) | floor %.3f..%.3f | mult %.2f..%.2fx | gap2x %.2f..%.2f ms' % (
            n, len(v), tot / len(v), tot, mb, fh[n][1], lo, hi, tot / hi, tot / lo,
            tot - 2 * hi, tot - 2 * lo))
    print('  frame hop total = %.2f GB, planes=%d' % (sum(x[0] for x in fh.values()) / 1e9, sum(x[1] for x in fh.values())))
