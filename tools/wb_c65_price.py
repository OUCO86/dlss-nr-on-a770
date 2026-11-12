import csv, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'
LOG = r'E:\DSH\logs\C27_rt_f2.log'

# closure -> (name, touched runtime plane ids, total hop bytes)
rows = []
pat = re.compile(r'\[lcount\] cmd=(\d+) name=(\S+).*?\[hop\] planes=(\d+) bytes=([\d,]+) scr=\d+ ids= (.*)$')
for line in open(LOG, encoding='utf-8', errors='replace'):
    m = pat.search(line)
    if m:
        rows.append((int(m.group(1)), m.group(2).replace('xmx_rec_', ''),
                     set(int(x) for x in m.group(5).split()),
                     int(m.group(4).replace(',', ''))))
print('parsed closures:', len(rows))

# closure -> shapes
sh = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    try:
        sh[int(r['closure'])] = (int(r['M']), int(r['N']), int(r['K']), int(r['batch'] or 1))
    except ValueError:
        pass

# what each family does with the accumulator face (engine code evidence)
ROLE = {   # family: (role, dtype, evidence)
    'gemm_int8_residual':            ('write', 'f32', 'C-out; RESIDUAL plan step carries no flags word -> narrow=0 (:5349)'),
    'gemm_window_int8_residual':     ('write', 'f32', 'C-out (:5349 family twin)'),
    'gemm_int8_qkv':                 ('write', 'f32', 'C-out @3 of 1274'),
    'gemm_int8_batched':             ('write', 'f32', 'C-out @2 of 1274'),
    'gemm':                          ('write', 'f32', 'C-out @0/@2 of 1274 (f16 gemm writes an f32 C32 accumulator)'),
    'quant_window':                  ('read',  'half', 'libxmx_sycl.cpp:6155  sycl::half* a = (sycl::half*)s->second.p'),
    'quant':                         ('read',  'f32', 'qr_kernel on float* source'),
    'window_attention':              ('read',  'half', 'attention stages on half planes (dH16/dOut1275 half)'),
    'global_attention':              ('read',  'half', 'ViT attention on half planes'),
    'unary':                         ('read',  'half', 'E4M3_HALF/POOL kinds on half'),
    'window_block':                  ('rw',    'f32', 'engine-side f32 staging (per-slice)'),
    'ffn':                           ('read',  'f32', 's6_ffn_block_kernel.hpp:93-100 f32 operand pointers (FROZEN guard file)'),
    'ffn_merge':                     ('read',  'f32', 'same frozen family'),
    'ffn_stem':                      ('read',  'f32', 'same frozen family'),
}
for PLANE, NAME in ((1309, '1267 (runtime 1309)'), (1313, '1274 (runtime 1313)')):
    agg = collections.defaultdict(lambda: [0.0, 0])
    for c, fam, ids, hb in rows:
        if PLANE not in ids:
            continue
        M, N, K, b = sh.get(c, (0, 0, 0, 1))
        role, dt, ev = ROLE.get(fam, ('?', '?', 'unmapped'))
        # region of THIS plane touched by this closure (element count x element size)
        if role == 'write':
            elems = M * N if M and N else 0
        elif fam in ('quant', 'quant_window'):
            elems = M * K if M and K else 0
        elif fam in ('window_attention', 'global_attention'):
            elems = M * K if M and K else 0
        elif fam == 'unary':
            elems = M * N if M and N else (K * b if K else 0)
        else:
            elems = M * N if M and N else 0
        esz = 2 if dt == 'half' else 4
        agg[(fam, role, dt)][0] += elems * esz / 1e6
        agg[(fam, role, dt)][1] += 1
    tot = sum(v[0] for v in agg.values())
    half = sum(v[0] for k, v in agg.items() if k[2] == 'half')
    f32 = sum(v[0] for k, v in agg.items() if k[2] == 'f32')
    print('\n=== plane %s : attributed region = %.1f MB/frame ===' % (NAME, tot))
    for (fam, role, dt), (mb, n) in sorted(agg.items(), key=lambda x: -x[1][0]):
        print('   %-30s %-6s %-5s %9.1f MB  closures=%d' % (fam, role, dt, mb, n))
    print('   already f16 = %.1f MB (%.1f%%)   still f32 = %.1f MB (%.1f%%)' % (
        half, 100.0 * half / tot if tot else 0, f32, 100.0 * f32 / tot if tot else 0))
    print('   >>> P8 removable = f32/2 = %.1f MB  =>  %.2f ms/frame @291.1 GB/s' % (f32 / 2, (f32 / 2) / 291.1))
