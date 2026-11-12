import re, sys, os, collections
sys.stdout.reconfigure(encoding='utf-8')
H = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl'
FILES = ['gemm_s8_v8_kernel.hpp', 'window_attention_kernel.hpp', 'wa_res_kernel.hpp', 'qkv_resident.hpp',
         'gemm_int8_kernel.hpp', 'gemm_window_int8_kernel.hpp', 'window_block_v4ph.hpp', 'publish_kernel.hpp']
ESZ = {'float': 4, 'sycl::half': 2, 'half': 2, 'uint8_t': 1, 'int8_t': 1, 'uint32_t': 4, 'int32_t': 4,
       'unsigned': 4, 'char': 1, 'bfloat16': 2, 'int': 4, 'uint16_t': 2, 'sycl::ext::intel::esimd::half': 2}
# match slm_block_load< T , N >  OR  slm_block_store( off, VALUE ) where VALUE's type is inferred from
# the declared simd<...> on the same/previous line, plus slm_block_store< T,N >(off, v)
patL = re.compile(r'slm_block_load<\s*([A-Za-z_:0-9 ]+?)\s*,\s*(\d+)\s*>')
patS = re.compile(r'slm_block_store<\s*([A-Za-z_:0-9 ]+?)\s*,\s*(\d+)\s*>\s*\(')
patS2 = re.compile(r'slm_block_store\s*\(([^;]{0,180}?)\)\s*;')
patDecl = re.compile(r'(?:esimd::)?simd<\s*([A-Za-z_:0-9 ]+?)\s*,\s*(\d+)\s*>\s+([A-Za-z_][A-Za-z_0-9]*)')
rows = []
present = []
for f in FILES:
    p = os.path.join(H, f)
    if not os.path.isfile(p):
        print('MISSING FILE:', f); continue
    present.append(f)
    lines = open(p, encoding='utf-8', errors='replace').read().split('\n')
    decl = {}
    for i, L in enumerate(lines):
        for m in patDecl.finditer(L):
            decl[m.group(3)] = (m.group(1).strip(), int(m.group(2)))
        for m in patL.finditer(L):
            t, n = m.group(1).strip(), int(m.group(2))
            rows.append((f, i + 1, 'load', t, n, n * ESZ.get(t, 4)))
        for m in patS.finditer(L):
            t, n = m.group(1).strip(), int(m.group(2))
            rows.append((f, i + 1, 'store', t, n, n * ESZ.get(t, 4)))
        for m in patS2.finditer(L):
            if patS.search(L):
                continue
            inner = m.group(1)
            # find the value identifier and look up its declared simd type
            ids = re.findall(r'\b([A-Za-z_][A-Za-z_0-9]*)\b', inner)
            for c in reversed(ids):
                if c in decl:
                    t, n = decl[c]
                    rows.append((f, i + 1, 'store(inf)', t, n, n * ESZ.get(t, 4)))
                    break
print('scanned:', ', '.join(present))
print('\n%-30s %6s %-11s %-10s %5s %7s' % ('file', 'line', 'kind', 'type', 'N', 'bytes'))
buck = collections.Counter()
for f, ln, k, t, n, b in rows:
    tag = '  <== <=64 B (widen candidate)' if b <= 64 else ('  <== 128 B' if b == 128 else '')
    print('%-30s %6d %-11s %-10s %5d %7d%s' % (f, ln, k, t, n, b, tag))
    buck[(f, b)] += 1
print('\n=== per-file byte-size histogram ===')
for (f, b), c in sorted(buck.items()):
    print('   %-32s %4d B x %d' % (f, b, c))
print('\ntotal sites:', len(rows), ' <=64 B:', sum(1 for r in rows if r[5] <= 64),
      ' 256 B:', sum(1 for r in rows if r[5] == 256))
