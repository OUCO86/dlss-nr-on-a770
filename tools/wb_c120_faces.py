import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8')

# C120 (A): what ARE faces 1303 and 1307 (the two faces that dominate the block's byte audit)?
# The audit charges a face's FULL size per touching closure (an upper bound) -- so before any
# conclusion, establish: (i) where the id comes from (plan OP_BUF? runtime create? import?),
# (ii) its declared size and element kind, (iii) which recorder touches it and with what shape.
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
lines = open(PLAN, encoding='utf-8', errors='replace').read().split('\n')

bufs = {}
oppat = re.compile(r'\{\s*OP_BUF,\s*\d+,\s*\{\s*(\d+)\s*,\s*(\d+)')
imppat = re.compile(r'\{\s*OP_XMX_BUF_IMPORT\w*,\s*\d+,\s*\{([^}]*)\}')
for ln, l in enumerate(lines, 1):
    m = oppat.search(l)
    if m:
        bufs[int(m.group(1))] = (int(m.group(2)), ln)
print('plan OP_BUF count = %d   id range = %s .. %s' % (len(bufs), min(bufs) if bufs else '-', max(bufs) if bufs else '-'))
for i in (1303, 1307, 1305, 1304, 1308, 1309, 1310, 1267, 1274):
    if i in bufs:
        sz, ln = bufs[i]
        print('  id %-5d plan line %6d  size = %11d B  (%.1f MB)  esz2 elems = %s' % (i, ln, sz, sz / 1e6, sz // 2))
    else:
        print('  id %-5d NOT a plan OP_BUF  => created at runtime (xmx_buf_create / import / pool)' % i)
print()
print('=== biggest plan faces (top 12 by size) ===')
for i, (sz, ln) in sorted(bufs.items(), key=lambda kv: -kv[1][0])[:12]:
    print('  id %-5d %11d B (%.1f MB)  line %d' % (i, sz, sz / 1e6, ln))
print()
print('=== import steps in the plan (weights enter here) ===')
imp = []
for ln, l in enumerate(lines, 1):
    m = imppat.search(l)
    if m:
        a = [int(x) for x in re.findall(r'-?\d+', m.group(1))]
        imp.append((ln, a[:6]))
print('  import steps:', len(imp))
for ln, a in imp[:12]:
    print('    line %6d args=%s' % (ln, a))
print()
print('=== the create/import entry points in the engine source (read-only) ===')
SRC = open(r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp', encoding='utf-8', errors='replace').read()
for name in ('xmx_buf_create_kind', 'xmx_buf_import', 'xmx_buf_create', 'g_nextbuf'):
    print('  %-22s occurrences: %d' % (name, len(re.findall(r'\b%s\b' % name, SRC))))
