import re, sys, collections
rows = open(sys.argv[1], encoding='utf-8').read().splitlines()
pat = re.compile(r'(\w+)::fused T(\d+) C(\d+) HID(\d+) F16=(\d) KS4=(\d+) KS6=(\d+) '
                 r'P4F=(\S+) PK=(\S+) SP=(\S+) BAR=(\S+) DUMP=(\S+) P=(\S+) SINK=(\S+)\s+'
                 r'(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)')
agg = {}
for r in rows:
    m = pat.search(r)
    if not m: continue
    ns,T,C = m.group(1), m.group(2), m.group(3)
    cfg = f'{ns} T{T}C{C} P4F={m.group(8)} PK={m.group(9)} SP={m.group(10)} BAR={m.group(11)}'
    grf, simd, slm, spill, priv, scrb, scrins = m.groups()[14:]
    def num(x):
        try: return int(x)
        except: return 0
    a = agg.setdefault(cfg, dict(n=0, grf=set(), slm=set(), priv=0, spill=0, scrb=0, scrins=0, dump=set()))
    a['n'] += 1; a['grf'].add(grf); a['slm'].add(slm)
    a['priv'] = max(a['priv'], num(priv)); a['spill'] = max(a['spill'], num(spill))
    a['scrb'] = max(a['scrb'], num(scrb)); a['scrins'] = max(a['scrins'], num(scrins))
    a['dump'].add(f"P{m.group(13)}D{m.group(12)}S{m.group(14)}")
print(f'{"config":46s} {"inst":>4s} {"grf":>6s} {"slm(B)":>8s} {"priv(B)":>8s} {"spill":>6s} {"scrB":>5s} {"scrInstr":>9s}')
for k in sorted(agg):
    a = agg[k]
    print(f"{k:46s} {a['n']:4d} {'/'.join(sorted(a['grf'])):>6s} {'/'.join(sorted(a['slm'])):>8s} "
          f"{a['priv']:8d} {a['spill']:6d} {a['scrb']:5d} {a['scrins']:9d}")
