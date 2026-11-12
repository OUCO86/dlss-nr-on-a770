import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
LOG = r'E:\DSH\logs\C27_rt_f2.log'      # fused-route leg with per-closure [hop] region bytes

# 1) per-closure region (executed) bytes and the plane ids it touches, from the hop census
hop = {}
cur = None
for line in open(LOG, encoding='utf-8', errors='replace'):
    m = re.search(r'\[lcount\] cmd=(\d+)', line)
    if m:
        cur = int(m.group(1)); continue
    m2 = re.search(r'\[hop\] planes=(\S+) bytes=([\d,]+)', line)
    if m2 and cur is not None:
        ids = [int(x) for x in re.findall(r'\d+', m2.group(1))]
        by = int(m2.group(2).replace(',', ''))
        hop.setdefault(cur, []).append((ids, by))

# 2) closure -> recorder family + shapes
fam = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    fam[int(r['closure'])] = ((r['family'] or '').replace('xmx_rec_', ''), r['M'], r['N'], r['K'], r['batch'])

# 3) closure -> touched plane ids (C15 census, runtime ids)
touch = {}
for r in csv.DictReader(open(T + r'\C15_targets.csv', encoding='utf-8', errors='replace')):
    try:
        touch[int(r['closure'])] = set(int(x) for x in r['touch_ids'].split())
    except ValueError:
        pass

# 4) dtype knowledge per family, from the ENGINE code (what the accessor actually casts to).
#    'half'  = this family already accesses the accumulator face as f16 (no P8 gain),
#    'f32'   = still f32 (P8 would halve it),
#    '?'     = depends on the leg's flags (listed separately).
DTYPE = {
    'quant_window':  'half',   # libxmx_sycl.cpp:6155  sycl::half* a = (sycl::half*)s->second.p
    'quant':         'f32',    # the plain quantisers read the f32 accumulator (qr_kernel on float*)
    'gemm_int8_residual': 'f32',      # narrow comes from flags & 0x1000; the RESIDUAL plan step carries no flags word
    'gemm_window_int8_residual': 'f32',
    'gemm_int8_qkv': 'f32',
    'gemm_int8_batched': 'f32',
    'gemm':          'f32',
    'window_attention': 'half',      # the attention stages work on half planes (dH16/dOut1275 half)
    'unary':         'half',         # E4M3_HALF/POOL kinds operate on half
    'window_block':  '?',
    'ffn':           '?',             # partly inside the frozen s6_ffn_block_kernel.hpp
    'ffn_merge':     '?',
    'ffn_stem':      '?',
}

for PLANE, NAME in ((1309, '1267 (runtime 1309)'), (1313, '1274 (runtime 1313)')):
    acc = collections.Counter(); det = collections.defaultdict(lambda: [0, 0])
    for c, seen in hop.items():
        f = fam.get(c, ('?', '', '', '', ''))[0]
        for ids, by in seen:
            if PLANE in ids:
                d = DTYPE.get(f, '?')
                acc[d] += by
                det[(f, d)][0] += by
                det[(f, d)][1] += 1
    tot = sum(acc.values())
    print('\n=== plane %s : executed region bytes that touch it = %.1f MB/frame ===' % (NAME, tot / 1e6))
    for d in ('half', 'f32', '?'):
        mb = acc[d] / 1e6
        print('   already %-5s : %8.1f MB  (%.1f%%)' % (d, mb, 100.0 * mb / tot if tot else 0))
    print('   per family:')
    for (f, d), (by, n) in sorted(det.items(), key=lambda x: -x[1][0])[:12]:
        print('     %-30s %-5s %9.1f MB  touches=%d' % (f, d, by / 1e6, n))
    f32 = acc['f32'] / 1e6
    print('   >>> P8 removable on this plane = f32 share / 2 = %.1f MB  =>  %.2f ms/frame @291.1 GB/s' % (f32 / 2, f32 / 2 / 291.1))
