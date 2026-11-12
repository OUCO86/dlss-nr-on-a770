import re, sys, os, collections
sys.stdout.reconfigure(encoding='utf-8')

R = r'E:\DSH\refs\A770-Kernel-Optimization\references'
for f in ('hardware/hardware.md', 'hardware/bandwidth.md', 'workflow/pitfalls.md', 'pitfalls.md'):
    p = os.path.join(R, f.replace('/', os.sep))
    if not os.path.isfile(p):
        print('MISSING', p); continue
    print('==== %s (%d bytes) ====' % (f, os.path.getsize(p)))
    for i, L in enumerate(open(p, encoding='utf-8', errors='replace').read().split('\n')):
        t = L.strip()
        if not t:
            continue
        if re.search(r'(GRF|SLM|block_load|256|512|DPAS|8x8x16|VNNI|ExecutionSize|L1|L2 |ridge|TFLOP|GB/s|threads|EU|Xe-core|prefetch|named_barrier|Large)', t, re.I):
            if len(t) < 240:
                print('  %4d: %s' % (i + 1, t[:200]))

# --- what our shipped kernels actually do ---
H = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl'
sizes = collections.Counter(); dpas = collections.Counter(); grf = []
for f in sorted(os.listdir(H)):
    if not f.endswith(('.hpp', '.cpp')):
        continue
    p = os.path.join(H, f)
    for i, L in enumerate(open(p, encoding='utf-8', errors='replace').read().split('\n')):
        for m in re.finditer(r'slm_block_load<\s*([A-Za-z_0-9:\s]+?)\s*,\s*(\d+)\s*>', L):
            typ, n = m.group(1).strip(), int(m.group(2))
            esz = {'float': 4, 'sycl::half': 2, 'half': 2, 'uint8_t': 1, 'int8_t': 1, 'uint32_t': 4, 'char': 1, 'unsigned': 4}.get(typ, 4)
            sizes[(typ, n, n * esz)] += 1
        for m in re.finditer(r'dpas<\s*([^>]+)>', L):
            dpas[m.group(1).strip()] += 1
        if re.search(r'doubleGRF|Large GRF|reqd_work_group|num_registers', L):
            grf.append('%s:%d %s' % (f, i + 1, L.strip()[:110]))
print('\n=== shipped SLM block-load widths (type, simd N, bytes = N*sizeof) ===')
for (typ, n, b), c in sorted(sizes.items(), key=lambda x: -x[0][2])[:12]:
    print('   %-12s N=%-4d bytes=%-5d count=%d  %s' % (typ, n, b, c, 'OVER-256-B?' if b > 256 else ''))
print('=== shipped dpas template args ===')
for k, v in dpas.most_common(8):
    print('   dpas<%s> x%d' % (k, v))
print('=== Large GRF / register directives in our tree ===')
for g in grf[:6]:
    print('   ', g)
print('   (none found)' if not grf else '')
