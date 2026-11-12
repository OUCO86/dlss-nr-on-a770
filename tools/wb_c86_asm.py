import os, re, sys, subprocess, collections
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
OCLOC = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'
# usage: wb_c86_asm.py <cache_dir> <work_dir> [name-substring ...]
CACHE, WORK = sys.argv[1], sys.argv[2]
NAMES = sys.argv[3:]
if os.path.isdir(WORK):
    subprocess.run(['cmd', '/c', 'rmdir', '/s', '/q', WORK], capture_output=True)
os.makedirs(WORK, exist_ok=True)
files = []
for root, dirs, fs in os.walk(CACHE):
    for fn in fs:
        p = os.path.join(root, fn)
        try:
            if os.path.getsize(p) >= 5000:
                files.append(p)
        except OSError:
            pass
files.sort(key=lambda x: -os.path.getsize(x))
rows = []
for n, p in enumerate(files[:14]):
    data = open(p, 'rb').read()
    i = data.find(b'\x7fELF')                       # first ELF per file (12-file cap)
    if i < 0 or i + 20 > len(data) or data[i + 18] != 0xCD:
        continue
    ep = os.path.join(WORK, 'e%d.bin' % n)
    open(ep, 'wb').write(data[i:])
    dd = os.path.join(WORK, 'd%d' % n)
    os.makedirs(dd, exist_ok=True)
    subprocess.run([OCLOC, 'disasm', '-file', ep, '-dump', dd, '-device', 'dg2'], capture_output=True)
    for f2 in os.listdir(dd):
        fp = os.path.join(dd, f2)
        if f2.endswith('.ze_info'):
            txt = open(fp, encoding='utf-8', errors='replace').read()
            for blk in re.split(r'\n  - name:', txt)[1:]:
                nm = blk.split('\n', 1)[0].strip()
                g = re.search(r'grf_count:\s*(\d+)', blk)
                slm = re.search(r'slm_size:\s*(\d+)', blk)
                bc = re.search(r'barrier_count:\s*(\d+)', blk)
                scr = re.search(r'type: scratch[\s\S]{0,200}?size:\s*(\d+)', blk)
                rows.append(('meta', nm, int(g.group(1)) if g else -1, int(slm.group(1)) if slm else -1,
                             int(bc.group(1)) if bc else -1, int(scr.group(1)) if scr else 0, 0, 0, 0))
        elif f2.endswith('.asm'):
            t = open(fp, encoding='utf-8', errors='replace').read()
            ops = re.findall(r'^\s+([a-z][a-z0-9_.]*)', t, re.M)
            c = collections.Counter(o.split('.')[0] for o in ops)
            nm = f2.split('\t')[0] if '\t' in f2 else f2[6:-4]
            rows.append(('asm', nm, sum(v for k, v in c.items() if 'dpas' in k),
                         sum(v for k, v in c.items() if k.startswith('send')), len(ops), 0, 0, 0, 0))
meta = {}
for r in rows:
    if r[0] == 'meta':
        meta[r[1][:70]] = r[2:6]
print('%-58s %6s %6s %6s %6s' % ('kernel (truncated)', 'grf', 'SLM', 'barr', 'scratch'))
shown = 0
for nm, v in sorted(meta.items()):
    g, slm, bc, scr = v
    if NAMES and not any(s in nm for s in NAMES):
        continue
    print('%-58s %6d %6d %6d %6d' % (nm[:58], g, slm, bc, scr))
    shown += 1
    if shown >= 14:
        break
print('\n%-58s %6s %5s %5s %5s' % ('kernel', 'instr', 'dpas', 'send', '-'))
shown = 0
seen = set()
for r in rows:
    if r[0] != 'asm':
        continue
    nm = r[1]
    if nm in seen:
        continue
    seen.add(nm)
    if NAMES and not any(s in nm for s in NAMES):
        continue
    print('%-58s %6d %5d %5d' % (nm[:58], r[4], r[2], r[3]))
    shown += 1
    if shown >= 14:
        break
print('files scanned:', len(files), 'ELFs carved:', sum(1 for r in rows if r[0] == 'meta'))
