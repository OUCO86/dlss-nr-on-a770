import sys, re
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
SRC = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp'
AUD = r'E:\DSH\logs\C123_base1.log'

IDS = [1267, 1272, 1273, 1274, 1275, 1276, 1277, 1284, 1285, 1288, 1290, 1291, 1303, 1305, 1307, 1308, 1309, 1310]

# (a) the plan's OP_BUF lines: id, size, and the kind/element field as recorded
print('=== plan OP_BUF entries for the block faces (id, size, then the remaining fields verbatim) ===')
lines = open(PLAN, encoding='utf-8', errors='replace').read().split('\n')
for ln, l in enumerate(lines, 1):
    m = re.search(r'\{\s*OP_BUF,\s*\d+,\s*\{([^}]*)\}', l)
    if not m:
        continue
    a = [int(x) for x in re.findall(r'-?\d+', m.group(1))]
    if a and a[0] in IDS:
        print('  line %6d  %s' % (ln, a))
print()

# (b) who writes / who reads each face, from the plan steps (argument position 0..3)
pat = re.compile(r'\{\s*OP_XMX_REC_([A-Z0-9_]+),\s*\d+,\s*\{([^}]*)\}')
w = {i: [] for i in IDS}
r_ = {i: [] for i in IDS}
for ln, l in enumerate(lines, 1):
    m = pat.search(l)
    if not m:
        continue
    op = m.group(1)
    a = [int(x) for x in re.findall(r'-?\d+', m.group(2))]
    for pos, v in enumerate(a):
        if v in IDS:
            (w if pos == 0 else r_)[v].append((op, pos))
print('=== writers (arg#0) and readers (arg#>=1) per face, from the plan ===')
for i in IDS:
    if i in (1303, 1305, 1307, 1308, 1309, 1310):
        continue     # runtime mirrors: not in the plan
    ww = sorted(set(x[0] for x in w[i])); rr = sorted(set(x[0] for x in r_[i]))
    print('  face %-5d writers=%-38s readers=%s' % (i, ','.join(ww) or '-', ','.join(rr) or '-'))
print()

# (c) element widths as the ENGINE declares them (read the recorder contracts, no guessing)
src = open(SRC, encoding='utf-8', errors='replace').read()
print('=== element widths from the recorders themselves ===')
for pat_ in (r'q,k,v: \(batches, 64, 32\) \w+',
             r'out: merged=1 -> \([^\n]*',
             r'// the QKV epilogue.s output[^\n]*',
             r'xmx_rec_quant_window[^{]*\{',
             r'pk: [^\n]*int8[^\n]*', r'scale[^\n]{0,60}float[^\n]{0,40}'):
    for m in re.finditer(pat_, src):
        print('   ', m.group(0)[:150])
print()

# (d) the byte audit for the two block chains, with widths, from a real leg
t = open(AUD, encoding='utf-8', errors='replace').read()
for ch, tot, faces in re.findall(r'\[byte-audit\] chain=(\d+) totalMB=([\d.]+) faces=([^\n]*)', t):
    if ch in ('25', '33'):
        fs = re.findall(r'(\d+):([\d.]+)MB\(w(\d+)\)', faces)
        big = [x for x in fs if float(x[1]) >= 1.0]
        print('  chain %s (%s MB): faces >=1 MB: %s' % (ch, tot, ' '.join('%s:%sMB(w%s)' % x for x in big)))
        widths = set(x[2] for x in fs)
        print('     distinct element widths seen in this chain:', sorted(widths))
