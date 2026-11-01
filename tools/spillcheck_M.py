# spillcheck_M.py -- per-INSTANTIATION ledger (grf/simd/slm/spill/private/scratch-bytes/
# scratch-instructions) for the mixed-chain shovel. Adapted from s6/spillcheck_port.py, which
# dedups by (label, grf, slm) and therefore MERGES the SINK=0 / SINK=1 instantiations of the
# same (DUMP,NPHASE) -- exactly the case the M3 red line must not blur.
# Here every kernel entry of every ELF is printed with its FULL mangled name, plus the
# (DUMP,NPHASE,SINK) triple decoded from it, so the ledger is one row per real binary.
# Usage: py E:/DSH/s6/spillcheck_M.py [cache_dir] [outdir_short] [mtime_cutoff_epoch]
import struct, subprocess, sys, os, re

cache  = sys.argv[1] if len(sys.argv) > 1 else r'E:\DSH\sycl-cache'
outdir = sys.argv[2] if len(sys.argv) > 2 else r'E:\DSH\s6\_pcM'
since  = float(sys.argv[3]) if len(sys.argv) > 3 else 0.0
ocloc  = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'

def elfs_in(d):
    i = 0; out = []
    while True:
        i = d.find(b'\x7fELF', i)
        if i < 0: break
        if struct.unpack('<H', d[i+18:i+20])[0] == 0xCD:
            shoff = struct.unpack('<Q', d[i+0x28:i+0x30])[0]
            shent = struct.unpack('<H', d[i+0x3a:i+0x3c])[0]
            shnum = struct.unpack('<H', d[i+0x3c:i+0x3e])[0]
            end = i + shoff + shent*shnum
            for k in range(shnum):
                p = i + shoff + k*shent
                so = struct.unpack('<Q', d[p+0x18:p+0x20])[0]
                ss = struct.unpack('<Q', d[p+0x20:p+0x28])[0]
                end = max(end, i+so+ss)
            out.append((i, end-i))
        i += 1
    return out

def dec(name):
    # <ns>::fused<Shape<T,C,HID,F16PROJ,KS4,KS6>, DUMP, NPHASE, SINK>
    mm = re.search(r'(\w{3,6})L5fusedINS_\d+(Geo|Shape)I((?:Li-?\d+E|Lb[01]E)+)', name)
    if not mm: return None
    ns, kind, argstr = mm.groups()
    args = [x if x != '' else y for x, y in re.findall(r'Li(-?\d+)|Lb([01])', argstr)]
    tail = name[mm.end():]
    md = re.search(r'E{1,2}Lb(\d)ELi(\d+)E(?:Li(\d+)E)?', tail)
    dump, nph, sink = (list(md.groups()) + [None]*3)[:3] if md else ('?','?','?')
    if kind == 'Shape':
        T,C,HID,F16,K4,K6,P4F,PEAK,SPLIT,BAR = (args + ['-']*10)[:10]
        lab = (f'{ns}::fused T{T} C{C} HID{HID} F16={F16} KS4={K4} KS6={K6} '
               f'P4F={P4F} PK={PEAK} SP={SPLIT} BAR={BAR} DUMP={dump} P={nph} SINK={sink}')
    else:
        C,HID,TG,G,WM,KN = (args + ['-']*6)[:6]
        lab = f'{ns}::fused C{C} HID{HID} TG{TG} G{G} WM{WM} KN{KN} DUMP={dump} P={nph} SINK={sink}'
    return lab

os.makedirs(outdir, exist_ok=True)
bins = []
for root, dirs, files in os.walk(cache):
    if '0.bin' in files:
        bf = os.path.join(root, '0.bin')
        if os.path.getmtime(bf) >= since: bins.append((os.path.getmtime(bf), bf))
bins.sort()
rows = []
for mt, bf in bins:
    d = open(bf, 'rb').read()
    for n, (s, sz) in enumerate(elfs_in(d)):
        idx = len(rows)
        mb = os.path.join(outdir, f'c{idx}.bin'); open(mb, 'wb').write(d[s:s+sz])
        dd = os.path.join(outdir, f'c{idx}'); os.makedirs(dd, exist_ok=True)
        subprocess.run([ocloc, 'disasm', '-file', mb, '-dump', dd, '-device', 'dg2'], capture_output=True)
        zi = os.path.join(dd, '.ze_info')
        if not os.path.exists(zi): continue
        z = open(zi, 'rb').read().decode('utf-8', 'replace')
        for m in re.finditer(r'- name:\s+(\S+)', z):
            name = m.group(1); blk = z[m.start(1):m.start(1)+6000]
            lab = dec(name)
            if lab is None: continue
            def g(k):
                mm = re.search(k + r':\s*(\S+)', blk); return mm.group(1) if mm else '-'
            sc = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', blk)
            asmf = os.path.join(dd, '.text.' + name + '.asm'); nscr = 0
            if os.path.exists(asmf):
                nscr = sum(1 for L in open(asmf, encoding='utf-8', errors='replace') if 'scratch' in L)
            rows.append((lab, g('grf_count'), g('simd_size'), g('slm_size'), g('spill_size'),
                         g('private_size'), sc.group(1) if sc else '-', nscr, os.path.getmtime(bf)))

print(f'{"kernel":96s} {"grf":>4s} {"simd":>4s} {"slm(B)":>7s} {"spill(B)":>8s} {"priv(B)":>8s} {"scrB":>5s} {"scrInstr":>8s}')
for v in sorted(rows, key=lambda r: (r[0])):
    print(f'{v[0]:96s} {v[1]:>4s} {v[2]:>4s} {v[3]:>7s} {v[4]:>8s} {v[5]:>8s} {v[6]:>5s} {v[7]:>8d}')
