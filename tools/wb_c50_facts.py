import os, re, sys
sys.stdout.reconfigure(encoding='utf-8')

ROOTS = [
    r'E:\WorkBuddy\a770-speedopt\notes',
    r'E:\DSH\refs\A770-Kernel-Optimization\references',
    r'E:\DSH\refs\A770-Kernel-Optimization',
    r'E:\DSH\refs\omni-xpu-kernel',
    r'E:\DSH\refs\InferRef',
]
PAT = re.compile(r'(GRF|general register|register file|128 GRF|64 ?B|EU\b|SLM|shared local|local memory|'
                 r'dpas|LSC|send\.ugm|occupanc|threads per|SIMD32|SIMD16|SIMD8|scratch|spills)', re.I)
hits = []
for root in ROOTS:
    if not os.path.isdir(root):
        print('MISSING ROOT:', root)
        continue
    for dirpath, dirs, files in os.walk(root):
        for f in files:
            if not f.lower().endswith(('.md', '.txt', '.rst')):
                continue
            p = os.path.join(dirpath, f)
            if os.path.getsize(p) > 400000:
                continue
            try:
                lines = open(p, encoding='utf-8', errors='replace').read().split('\n')
            except OSError:
                continue
            for i, L in enumerate(lines):
                if PAT.search(L) and len(L) < 300:
                    hits.append((p, i + 1, L.strip()))
print('total candidate lines:', len(hits))
KEY = re.compile(r'(GRF|register file|64 ?(bytes|B)\b|per thread|per EU|threads per EU|SLM|local memory|'
                 r'dpas|LSC|send\.ugm|occupanc)', re.I)
for p, n, L in hits:
    if KEY.search(L):
        print('%s:%d  %s' % (p.replace('E:\\', 'E:/'), n, L[:200]))
