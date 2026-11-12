import re, sys, collections, os
sys.stdout.reconfigure(encoding='utf-8')
L = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss5-on-amd-9070xt-porting\Development\HIP'

print('=== files in the lmxx HIP dir ===')
for f in sorted(os.listdir(L)):
    p = os.path.join(L, f)
    if os.path.isfile(p):
        print('   %9d  %s' % (os.path.getsize(p), f))

h = open(os.path.join(L, 'hip_reference_network.h'), encoding='utf-8', errors='replace').read()
runs = re.findall(r'Run\("([a-z0-9_]+)",\s*"?([A-Za-z0-9_:.\-+]+)"?', h)
cnt = collections.Counter(k for _, k in runs)
print('\n=== Run() call sites in the network file: total=%d distinct=%d ===' % (sum(cnt.values()), len(cnt)))
for k, v in cnt.most_common(26):
    print('   %-48s %d' % (k[:48], v))

d = open(os.path.join(L, 'deep_fast.hip'), encoding='utf-8', errors='replace').read()
kern = re.findall(r'__global__[^\n]*?void\s+([A-Za-z0-9_]+)', d)
print('\ndeep_fast.hip __global__ kernels: distinct=%d' % len(set(kern)))
print('   ' + ', '.join(sorted(set(kern))[:48]))

# residency / launch-count claims in the lmxx docs
pat = re.compile(r'(persistent|LDS|launch|97|79|160|÷|shared)', re.I)
for root, dirs, files in os.walk(os.path.dirname(L)):
    for f in files:
        if f.lower().endswith(('.md', '.txt')) and os.path.getsize(os.path.join(root, f)) < 400000:
            t = open(os.path.join(root, f), encoding='utf-8', errors='replace').read()
            hits = [ln.strip() for ln in t.split('\n') if pat.search(ln) and len(ln) < 260]
            if hits:
                print('\n--- %s (%d hits)' % (os.path.join(root, f).replace(root + os.sep, ''), len(hits)))
                for x in hits[:6]:
                    print('    ' + x[:200])
