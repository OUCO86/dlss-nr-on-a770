import sys, re
sys.stdout.reconfigure(encoding='utf-8')
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
pat = re.compile(r'\{\s*(OP_XMX_REC_[A-Z0-9_]+|OP_[A-Z0-9_]+),\s*\d+,\s*\{([^}]*)\}')
TARGET = 1274
rows = []
for ln, line in enumerate(open(PLAN, encoding='utf-8', errors='replace'), 1):
    m = pat.search(line)
    if not m:
        continue
    op = m.group(1).replace('OP_', '')
    args = [int(t) for t in re.findall(r'-?\d+', m.group(2))]
    if TARGET in args:
        pos = args.index(TARGET)
        rows.append((ln, op, args[:10], pos))
print('=== plan steps touching buffer %d (n=%d) ===' % (TARGET, len(rows)))
for ln, op, a, pos in rows[:26]:
    print('  line %6d  %-34s arg#%d  args=%s' % (ln, op, pos, a))
print()
print('=== how the engine declares widths for these ops (element size lives in the recorder) ===')
SRC = open(r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp', encoding='utf-8', errors='replace').read()
for name in ('xmx_rec_gemm_window_int8_residual', 'xmx_rec_gemm_int8_residual', 'xmx_rec_window_attention',
             'xmx_rec_quant_window', 'xmx_rec_publish', 'xmx_rec_unary'):
    n = len(re.findall(r'\b%s\b' % name, SRC))
    print('  %-36s mentioned %3d times in libxmx_sycl.cpp' % (name, n))
print()
print('NOTE: this is the inventory the P8 (1274 -> f16) knife must cover: every step that reads or')
print('      writes 1274, with the argument position it appears at. Element-size changes at 1274')
print('      must be matched at EVERY one of these sites (strides, scales, and the buffer kind).')
