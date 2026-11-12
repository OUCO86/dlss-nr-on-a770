import sys, re
sys.stdout.reconfigure(encoding='utf-8')
t = open(r'E:\DSH\logs\C66b_zeinfo.log', encoding='utf-8', errors='replace').read().split('\n')
print('=== lines mentioning b6 / wa_res ===')
for L in t:
    if 'b6' in L or 'wa_res' in L:
        print('   ', L.strip()[:190])
print('=== instances whose metadata carries SLM 57344 ===')
n = 0
for L in t:
    if '57344' in L:
        print('   ', L.strip()[:190]); n += 1
        if n >= 5: break
print('count =', n)
print('=== metadata sample lines (mangled names) ===')
c = 0
for L in t:
    if '_ZTS' in L:
        print('   ', L.strip()[:190]); c += 1
        if c >= 4: break
print('=== GUARD summary lines ===')
for L in t:
    if 'GUARD' in L or 'elfs=' in L or 'only in' in L or 'MOVED' in L:
        print('   ', L.strip()[:150])
