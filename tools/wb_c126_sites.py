import sys, re
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
SRC = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp'
L = open(SRC, encoding='utf-8', errors='replace').read().split('\n')

print('=== C126 (1): the site list for turning face 1274 (and its runtime mirror 1307) from half to int8 ===')
print()
print('--- A. where the element width of a face is decided (create sites) ---')
for j, x in enumerate(L, 1):
    if re.search(r'xmx_buf_create_kind|g_bufs\[id\] = \{|esz = |kind == 0 \? 2', x) and x.strip():
        print('%5d: %s' % (j, x.strip()[:140]))
print()
print('--- B. every cast that reads a face as half (the readers to change) ---')
pat = re.compile(r'\(\s*(?:const\s+)?sycl::half\s*\*\s*\)')
cnt = 0
for j, x in enumerate(L, 1):
    if pat.search(x) and not x.strip().startswith('//'):
        cnt += 1
        if cnt <= 26:
            print('%5d: %s' % (j, x.strip()[:138]))
print('   ... total half-cast sites in the file:', cnt)
print()
print('--- C. how 1274 is created: the plan says OP_BUF 1274 with a kind field? ---')
P = open(r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c', encoding='utf-8', errors='replace').read().split('\n')
for ln, l in enumerate(P, 1):
    if re.search(r'OP_BUF,\s*\d+,\s*\{\s*(1274|1267)\s*,', l):
        print('  plan line %5d: %s' % (ln, l.strip()[:150]))
print()
print('--- D. the recorder that WRITES 1274 (QUANT arg#0) and its publish width ---')
for j, x in enumerate(L, 1):
    if re.search(r'int xmx_rec_quant\(|narrow|half_skip|publish', x) and x.strip() and j < 6400 and j > 6050:
        print('%5d: %s' % (j, x.strip()[:134]))
