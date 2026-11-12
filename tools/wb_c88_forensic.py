import re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
pat = re.compile(r'\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}')

# 1) buffer sizes for the two wres tail operands (skip=1267, cosine=419) and the output 1283
print('=== OP_BUF sizes for the operands of interest ===')
for j, x in enumerate(L):
    m = pat.search(x)
    if m and m.group(1) == 'OP_BUF':
        v = [int(t) for t in re.findall(r'-?\d+', m.group(3))]
        if v and v[0] in (1267, 419, 1283, 1272, 1273, 422, 423, 1301):
            print('  line %5d  buf=%-5d size=%-12d extra=%s' % (j + 1, v[0], v[1], v[2:6]))

# 2) every step that mentions those buffers: is it a writer (first id) or a reader?
print('\n=== every step touching buf 1267 / 419 (writer = the op writes its output slot) ===')
touch = collections.Counter()
who = collections.defaultdict(list)
for j, x in enumerate(L):
    m = pat.search(x)
    if not m:
        continue
    op = m.group(1).replace('OP_XMX_REC_', '').replace('OP_XMX_', '')
    if op in ('BUF', 'BUF_PTR', 'PARAM', 'BINDING', 'IMAGE', 'SAMPLER'):
        continue
    v = [int(t) for t in re.findall(r'-?\d+', m.group(3))]
    for b in (1267, 419):
        if b in v:
            touch[(op, b)] += 1
            if len(who[(op, b)]) < 3:
                who[(op, b)].append((j + 1, v[:10]))
for (op, b), c in sorted(touch.items(), key=lambda kv: (kv[0][1], -kv[1])):
    print('  buf=%-5d %-30s x%d' % (b, op, c))
    for ln, v in who[(op, b)]:
        print('        line %5d  args=%s' % (ln, v))

# 3) the C512 tier's wres steps: what geometry do they pass (height/width/across/pad)?
print('\n=== the C512 tier wres steps: full arg list ===')
for j, x in enumerate(L):
    m = pat.search(x)
    if m and 'GEMM_WINDOW_INT8_RESIDUAL' in m.group(1):
        v = [int(t) for t in re.findall(r'-?\d+', m.group(3))]
        print('  line %5d: %s' % (j + 1, v[:16]))
