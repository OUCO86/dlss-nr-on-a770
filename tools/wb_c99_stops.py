import sys, re
sys.stdout.reconfigure(encoding='utf-8')
L = open(r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp', encoding='utf-8', errors='replace').read().split('\n')
pat = re.compile(r'getenv\("(NR_[A-Z0-9_]*STOP)"\)')
seen = {}
for j, x in enumerate(L, 1):
    m = pat.search(x)
    if m:
        seen.setdefault(m.group(1), []).append(j)
for k, v in seen.items():
    print('%-18s lines %s' % (k, v[:6]))
