import re, sys, os, collections
sys.stdout.reconfigure(encoding='utf-8')
H = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl'
sizes = collections.Counter(); dpas = collections.Counter(); notes = []
ESZ = {'float': 4, 'sycl::half': 2, 'half': 2, 'uint8_t': 1, 'int8_t': 1, 'uint32_t': 4,
       'unsigned': 4, 'char': 1, 'sycl::ext::intel::esimd::half': 2, 'bfloat16': 2, 'int': 4}
for f in sorted(os.listdir(H)):
    if not f.endswith(('.hpp', '.cpp')):
        continue
    p = os.path.join(H, f)
    try:
        txt = open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        continue
    for i, L in enumerate(txt.split('\n')):
        for m in re.finditer(r'slm_block(?:_store)?<\s*([A-Za-z_:0-9 ]+?)\s*,\s*(\d+)\s*>\s*\(', L):
            typ = m.group(1).strip(); n = int(m.group(2))
            b = n * ESZ.get(typ, 4)
            sizes[(typ, n, b)] += 1
            if b > 256:
                notes.append('OVER-256B  %s:%d  %s' % (f, i + 1, L.strip()[:120]))
        for m in re.finditer(r'slm_block_store\([^,]+,\s*([A-Za-z_0-9]+)', L):
            pass
        for m in re.finditer(r'dpas<\s*([^>]*)>', L):
            dpas[m.group(1).strip()] += 1
        if re.search(r'doubleGRF|large_grf|Large GRF|reqd_work_group_size|num_regs|slm_init<', L):
            if 'slm_init<' in L:
                mm = re.search(r'slm_init<\s*(\d+)', L)
                if mm:
                    sizes[('slm_init', int(mm.group(1)), 0)] += 1
            else:
                notes.append('GRF-DIRECTIVE  %s:%d  %s' % (f, i + 1, L.strip()[:120]))
print('=== our shipped SLM block access widths (simd N x sizeof; cap = 256 B per hardware.md:38) ===')
over = 0
for (typ, n, b), c in sorted(sizes.items(), key=lambda x: -(x[0][2]))[:16]:
    if typ == 'slm_init':
        continue
    tag = '  <<< OVER 256 B' if b > 256 else ''
    if b > 256:
        over += c
    print('   %-14s N=%-4d bytes=%-5d count=%-4d%s' % (typ, n, b, c, tag))
print('   accesses over 256 B =', over)
print('=== our slm_init sizes per file (cap 65,536 B/每 WG; ~32 KB starts losing resident WG per hardware.md:67) ===')
for (typ, n, _b), c in sorted(sizes.items(), key=lambda x: -x[0][1]):
    if typ == 'slm_init':
        print('   slm_init<%d> x%d  %s' % (n, c, '  <<< > 32 KB' if n > 32768 else ''))
print('=== our dpas template args (DG2 shape = 8x8x16; ES16 unsupported per hardware.md:31) ===')
for k, v in dpas.most_common(10):
    print('   dpas<%s> x%d' % (k, v))
print('=== notes ===')
for x in notes[:12]:
    print('   ', x)
