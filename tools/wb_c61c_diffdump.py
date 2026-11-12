import os, re, sys, hashlib, collections
sys.stdout.reconfigure(encoding='utf-8')
D = r'E:\DSH\tmp\c61cdump'
def load(tag):
    out = {}
    for f in os.listdir(D):
        m = re.match(r'p\.%s\.(.+)\.bin$' % re.escape(tag), f)
        if m:
            p = os.path.join(D, f)
            out[m.group(1)] = p
    return out
A = load('base'); B = load('c61c')
print('base dumps=%d  c61c dumps=%d' % (len(A), len(B)))
keys = sorted(set(A) & set(B), key=lambda k: (len(k), k))
first = None
rows = []
for k in keys:
    ha = hashlib.md5(open(A[k], 'rb').read()).hexdigest()
    hb = hashlib.md5(open(B[k], 'rb').read()).hexdigest()
    if ha != hb:
        ba = open(A[k], 'rb').read(); bb = open(B[k], 'rb').read()
        nd = sum(1 for x, y in zip(ba, bb) if x != y)
        off = next(i for i, (x, y) in enumerate(zip(ba, bb)) if x != y)
        rows.append((k, len(ba), nd, off, ha[:8], hb[:8], 'DIFF'))
        if first is None:
            first = k
    else:
        rows.append((k, os.path.getsize(A[k]), 0, -1, ha[:8], hb[:8], 'same'))
print('\n%-14s %10s %10s %10s %-9s %-9s %s' % ('plane', 'bytes', 'diffbytes', 'firstoff', 'md5a', 'md5b', 'verdict'))
for r in rows:
    print('%-14s %10d %10d %10d %-9s %-9s %s' % r)
print('\nFIRST DIFFERING PLANE =', first)
only_a = sorted(set(A) - set(B)); only_b = sorted(set(B) - set(A))
if only_a: print('only in base:', only_a[:12])
if only_b: print('only in c61c:', only_b[:12])
