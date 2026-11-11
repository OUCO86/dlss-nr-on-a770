import re, os, sys, statistics
sys.stdout.reconfigure(encoding='utf-8')
LOG = r'E:\DSH\logs'
TAGS = ['result', 'history', 'head', 'f1285', 'f1267vit', 'f1271vit', 'features']

def load(n):
    p = os.path.join(LOG, 'C27_%s.log' % n)
    if not os.path.isfile(p):
        return None
    s = open(p, encoding='utf-8', errors='replace').read()
    fh = {}
    for m in re.finditer(r'framehash run=(\d+) (\S+) bytes=(\d+) fnv=([0-9a-f]+)', s):
        fh[(int(m.group(1)), m.group(2))] = m.group(4)
    runs = [float(m.group(1)) for m in re.finditer(r'run \d+: ([0-9.]+) ms', s)]
    per = re.findall(r'PERIOD frame=(\d+) decision=(\w+) period=(\d+) idx=(\d+) reset=(\w+)', s)
    return fh, runs, per

def med(v):
    s = sorted(v[2:])
    return statistics.median(s) if s else float('nan')

print('=== (2) static: 8 frames x 7 faces per-frame FNV vs the REUSE=0 legs ===')
for leg, off in [('p16f', 's0f'), ('p8f', 's0f'), ('p4f', 's0f'), ('p16p', 's0p'), ('p8p', 's0p'), ('p4p', 's0p')]:
    b, L = load(off), load(leg)
    if not b or not L:
        print('   %-5s MISSING' % leg); continue
    dif = [(i, t) for i in range(8) for t in TAGS if b[0].get((i, t)) != L[0].get((i, t))]
    dec = ','.join(x[1][:2] for x in L[2][:10])
    print('   %-5s vs %-4s : %-15s decisions(ma/tw)=%s' % (leg, off, 'ALL 8x7 EQUAL' if not dif else 'DIFF %d %s' % (len(dif), str(dif[:4])), dec))

print('=== (3) frame ms (steady median, first 2 runs dropped) ===')
for n in ['s0f', 'p16f', 'p16f2', 'p16f3', 'p8f', 'p4f', 's0p', 'p16p', 'p16p2', 'p16p3', 'p8p', 'p4p']:
    L = load(n)
    if L:
        print('   %-6s med=%7.2f  runs=%s' % (n, med(L[1]), ' '.join('%.1f' % x for x in L[1][2:])))
for route, off, legs in [('fused', 's0f', ['p16f', 'p16f2', 'p16f3']), ('plain', 's0p', ['p16p', 'p16p2', 'p16p3'])]:
    base = med(load(off)[1]); vs = [med(load(x)[1]) for x in legs]
    print('   %s: REUSE=0 %.2f | period16 mean %.2f spread %.2f => delta %+.2f ms/frame' % (
        route, base, statistics.mean(vs), max(vs) - min(vs), statistics.mean(vs) - base))
for leg in ['p8f', 'p4f', 'p8p', 'p4p']:
    L = load(leg)
    if L:
        print('   %-5s med=%.2f' % (leg, med(L[1])))
print('=== done wb_c37_report2 ===')
