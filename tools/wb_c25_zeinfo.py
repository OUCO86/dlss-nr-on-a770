import os, re, sys, subprocess, json
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c25_zeinfo.py -- per-ELF ocloc .ze_info instance census for TWO JIT caches (CPU only),
# then the instance-name diff: what the C25 patch ADDED, and proof that nothing else moved.
#   usage: python wb_c25_zeinfo.py <cacheA> <cacheB> <workdir>
OCLOC = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'
cacheA, cacheB = sys.argv[1], sys.argv[2]
work = sys.argv[3] if len(sys.argv) > 3 else r'E:\DSH\tmp\k3ze\c25sep'
subprocess.run(['cmd', '/c', 'rmdir', '/s', '/q', work], capture_output=True)
os.makedirs(work, exist_ok=True)

def census(cache, tag):
    out = {}
    n = 0
    for root, dirs, fs in os.walk(cache):
        for fn in sorted(fs):
            p = os.path.join(root, fn)
            if os.path.getsize(p) < 5000:
                continue
            data = open(p, 'rb').read()
            i = data.find(b'\x7fELF')
            while i >= 0:
                if i + 20 <= len(data) and data[i + 18] == 0xCD:
                    ep = os.path.join(work, '%s_e%d.bin' % (tag, n))
                    open(ep, 'wb').write(data[i:])
                    dd = os.path.join(work, '%s_d%d' % (tag, n))
                    os.makedirs(dd, exist_ok=True)
                    subprocess.run([OCLOC, 'disasm', '-file', ep, '-dump', dd, '-device', 'dg2'],
                                   capture_output=True)
                    for f2 in os.listdir(dd):
                        if not f2.endswith('.ze_info'):
                            continue
                        txt = open(os.path.join(dd, f2), encoding='utf-8', errors='replace').read()
                        for block in re.split(r'\n  - name:', txt)[1:]:
                            nm = block.split('\n', 1)[0].strip()
                            g = re.search(r'grf_count:\s*(\d+)', block)
                            s = re.search(r'simd_size:\s*(\d+)', block)
                            b = re.search(r'barrier_count:\s*(\d+)', block)
                            slm = re.search(r'slm_size:\s*(\d+)', block)
                            scr = 'type: scratch' in block
                            scrs = re.search(r'type: scratch[\s\S]{0,120}?size:\s*(\d+)', block)
                            key = nm[:150]
                            val = (g.group(1) if g else '?', s.group(1) if s else '?',
                                   b.group(1) if b else '?', slm.group(1) if slm else 'ABSENT',
                                   int(scr), scrs.group(1) if scrs else '0')
                            out.setdefault(key, set()).add(val)
                    n += 1
                i = data.find(b'\x7fELF', i + 1)
    print('%s: elfs=%d instances=%d' % (tag, n, len(out)))
    return out

A = census(cacheA, 'A')
B = census(cacheB, 'B')
ka, kb = set(A), set(B)
print('names only in B (ADDED by the patch): %d' % len(kb - ka))
for k in sorted(kb - ka):
    print('   ADD %s  %s' % (k, sorted(B[k])))
print('names only in A (REMOVED): %d' % len(ka - kb))
for k in sorted(ka - kb):
    print('   DEL %s  %s' % (k, sorted(A[k])))
ch = [k for k in (ka & kb) if A[k] != B[k]]
print('common instances with MOVED metadata: %d' % len(ch))
for k in sorted(ch)[:20]:
    print('   MOVE %s  A=%s B=%s' % (k, sorted(A[k]), sorted(B[k])))
# the hard guard: scratch must be 0 everywhere, grf <= 128, and no instance may RAISE its SLM
worst_scr = []
worst_grf = []
for k, vals in B.items():
    for (g, s, b, slm, scr, sz) in vals:
        if scr or sz != '0':
            worst_scr.append((k, g, s, b, slm, scr, sz))
        try:
            if int(g) > 128:
                worst_grf.append((k, g))
        except ValueError:
            pass
print('GUARD scratch!=0 in B: %d' % len(worst_scr))
for r in worst_scr[:10]:
    print('   SCRATCH %s' % (r,))
print('GUARD grf>128 in B: %d' % len(worst_grf))
for r in worst_grf[:10]:
    print('   GRF %s' % (r,))
print('=== done wb_c25_zeinfo ===')
