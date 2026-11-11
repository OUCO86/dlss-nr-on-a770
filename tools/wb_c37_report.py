import re, os, sys, hashlib, statistics
sys.stdout.reconfigure(encoding='utf-8')
LOG, DUMP = r'E:\DSH\logs', r'E:\DSH\tmp\c27dump'
TAGS = ['result', 'history', 'head', 'f1285', 'f1267vit', 'f1271vit', 'features']

def load(path):
    if not os.path.isfile(path):
        return None
    s = open(path, encoding='utf-8', errors='replace').read()
    fh = {}
    for m in re.finditer(r'framehash run=(\d+) (\S+) bytes=(\d+) fnv=([0-9a-f]+)', s):
        fh[(int(m.group(1)), m.group(2))] = m.group(4)
    runs = [float(m.group(1)) for m in re.finditer(r'run \d+: ([0-9.]+) ms', s)]
    per = re.findall(r'PERIOD frame=(\d+) decision=(\w+) period=(\d+) idx=(\d+) reset=(\w+)', s)
    return fh, runs, per

def med(v):
    s = sorted(v[2:])
    return statistics.median(s) if s else float('nan')

print('=== (1) four gates: REUSE=0 fused faces (c37b) ===')
for k, exp in [('1301', '254C02B73108E18FCF68221D4C6D530C'), ('features', 'CACD202969C821D87CBDC033879CA7AB'),
               ('result', 'AE050ED1B1A5075BF41BCB93FD043298')]:
    f = os.path.join(DUMP, 'f.c27_g_off_f.%s.bin' % k)
    h = hashlib.md5(open(f, 'rb').read()).hexdigest().upper() if os.path.isfile(f) else 'MISSING'
    print('   %-9s %s %s' % (k, h[:12], 'EXACT' if h == exp else 'DIFF'))

print('=== (2) static: REUSE=0 vs period 16 (and the period controls) : 8x7 per-frame FNV ===')
base = load(os.path.join(LOG, 'C37_s0f_a.log'))
for leg in ['p16f', 'p8f', 'p4f']:
    L = load(os.path.join(LOG, 'C37_%s_a.log' % leg))
    if not base or not L:
        print('   %-5s MISSING' % leg); continue
    dif = [(i, t) for i in range(8) for t in TAGS if base[0].get((i, t)) != L[0].get((i, t))]
    print('   %-5s vs s0f : %s   decisions=%s' % (leg, 'ALL 8x7 EQUAL' if not dif else 'DIFF %d %s' % (len(dif), str(dif[:5])),
          ','.join('%s/%s' % (x[2], x[1]) for x in L[2][:6])))
pb = load(os.path.join(LOG, 'C37_s0p_a.log'))
for leg in ['p16p', 'p8p', 'p4p']:
    L = load(os.path.join(LOG, 'C37_%s_a.log' % leg))
    if not pb or not L:
        print('   %-5s MISSING' % leg); continue
    dif = [(i, t) for i in range(8) for t in TAGS if pb[0].get((i, t)) != L[0].get((i, t))]
    print('   %-5s vs s0p : %s' % (leg, 'ALL 8x7 EQUAL' if not dif else 'DIFF %d %s' % (len(dif), str(dif[:5]))))

print('=== (3) frame ms: period 4/8/16, fused and plain, 3 processes each ===')
for route, off in [('fused', 's0f'), ('plain', 's0p')]:
    o = load(os.path.join(LOG, 'C37_%s_a.log' % off))
    if o:
        print('   %-6s REUSE=0 baseline med=%.2f' % (route, med(o[1])))
for leg in ['p16f', 'p8f', 'p4f', 'p16p', 'p8p', 'p4p']:
    vals = []
    for suf in 'abc':
        L = load(os.path.join(LOG, 'C37_%s_%s.log' % (leg, suf)))
        if L:
            vals.append(med(L[1]))
    if vals:
        print('   %-6s medians=%s  mean=%.2f  spread=%.2f' % (leg, ' '.join('%.2f' % v for v in vals),
              statistics.mean(vals), max(vals) - min(vals)))

print('=== (4) period=16 changing buckets (vs the same-sequence REUSE=0 control) ===')
def bucket(a, b, lab):
    fa, fb = [os.path.join(DUMP, 'f.c27_%s.%s.bin' % (x, lab)) for x in (a, b)]
    if not (os.path.isfile(fa) and os.path.isfile(fb)):
        print('   %-26s MISSING DUMP' % ('%s/%s' % (a, b))); return
    A, B = open(fa, 'rb').read(), open(fb, 'rb').read()
    nd = sum(1 for x, y in zip(A, B) if x != y)
    px = sum(1 for i in range(0, min(len(A), len(B)) - 3, 4) if A[i:i + 4] != B[i:i + 4]) if lab == 'result' else 0
    print('   %-26s bytes_diff=%d%s' % ('%s/%s/%s' % (a, b, lab), nd, ('  pixels4_diff=%d' % px) if px else ''))
for lab in ['1301', 'features', 'result']:
    bucket('m1c0', 'p16m1', lab)
for lab in ['1301', 'features', 'result']:
    bucket('m2c0', 'p16m2', lab)
print('=== done c37_report ===')
