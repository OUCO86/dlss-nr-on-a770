import re, sys
sys.stdout.reconfigure(encoding='utf-8')
CPP = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp'
src = open(CPP, encoding='utf-8', errors='replace').read().split('\n')

FAMS = [('gemm_int8_qkv', 3), ('window_attention', None), ('quant', None), ('gemm', 0),
        ('gemm', 2), ('gemm_int8_batched', 2), ('gemm_int8_residual', 7), ('unary', None)]

# locate every recorder definition
defs = {}
for i, L in enumerate(src):
    m = re.search(r'\b(xmx_rec_[a-z0-9_]+)\s*\(', L)
    if m and ('{' in L or L.rstrip().endswith(')')) and re.search(r'(static |^int |^void |inline )', L):
        defs.setdefault(m.group(1), []).append(i + 1)
print('recorder definitions found:')
for k, v in sorted(defs.items()):
    print('   %-34s line(s) %s' % (k, v[:4]))

print('\n=== the launch line inside each recorder that carries the 1274/1313 operand ===')
targets = ['xmx_rec_gemm_int8_qkv', 'xmx_rec_window_attention', 'xmx_rec_quant', 'xmx_rec_gemm',
           'xmx_rec_gemm_int8_batched', 'xmx_rec_gemm_int8_residual', 'xmx_rec_unary']
for t in targets:
    for ln in defs.get(t, [])[:1]:
        # scan forward for the recorder call (xmx_rec_* or the launch helper) with its args
        for j in range(ln - 1, min(len(src), ln + 90)):
            L = src[j]
            if re.search(r'(xmx_rec_[a-z0-9_]+\s*\(|launch|parallel_for|GQ->)', L) and L.strip() and not L.strip().startswith('//'):
                print('  %-28s def@%-6d launch@%-6d: %s' % (t, ln, j + 1, L.strip()[:120]))
                break
