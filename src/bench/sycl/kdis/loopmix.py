import re, sys, os
from collections import Counter

# find backward-goto loops in GEN asm and count instruction mix INSIDE each loop body
def analyze(fn, min_body=40):
    lines = open(fn, encoding='utf-8', errors='replace').readlines()
    labels = {}
    for i, L in enumerate(lines):
        m = re.match(r'^(L\d+):', L.strip())
        if m: labels[m.group(1)] = i
    gotos = []
    for i, L in enumerate(lines):
        for m in re.finditer(r'goto \(.*?\)\s+(L\d+)\s+(L\d+)', L):
            t = m.group(1)
            if t in labels and labels[t] > i:
                gotos.append((i, labels[t], t))
    # merge overlapping loops by (start,end)
    loops = sorted(set(gotos), key=lambda x: (x[1]-x[0]))
    seen = []
    for a, b, t in loops:
        if any(a >= sa and b <= sb for sa, sb, _ in seen): continue
        seen.append((a, b, t))
    for a, b, t in seen:
        seg = lines[a:b+1]
        c = Counter(); n = 0
        for L in seg:
            s = L.strip()
            if not s or s.startswith('//'): continue
            while True:
                m = re.match(r'^\(([^)]*)\)\s+', s)
                if m: s = s[m.end():]
                else: break
            if not s or re.match(r'^L\d+:', s): continue
            op = s.split()[0]
            c[op] += 1; n += 1
        if n < min_body: continue
        dpas = sum(v for k, v in c.items() if k.startswith('dpas'))
        slm = c.get('send.slm', 0)
        ugm = c.get('send.ugm', 0) + c.get('send.dc0', 0)
        mov = c.get('mov', 0) + c.get('sel', 0) + c.get('join', 0)
        print(f'  loop {t}: body={n:5d} dpas={dpas:3d} slm={slm:4d} ugm={ugm:3d} movish={mov:5d} '
              f'dpas%={100.0*dpas/n:5.1f} top=' + ','.join(f'{k}={v}' for k, v in c.most_common(6) if k not in ('dpas',)))

for fn in sys.argv[1:]:
    print(f'== {os.path.basename(fn)[:78]}')
    analyze(fn)
