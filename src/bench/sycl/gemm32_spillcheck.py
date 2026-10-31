# gemm32_spillcheck.py -- per-kernel grf/simd/slm/spill/private/scratch ledger for the
# gemm32_tile.cpp sweep, read out of the SYCL persistent JIT cache (the binaries that
# ACTUALLY RAN -- the AOT link route dies on ocloc "more than one module with an entry
# point" once the TU carries ~34 kernel instantiations; see gemm32_tile.cpp TRAP 7).
# Same ELF-scan + ocloc disasm parse as spillcheck_cache.py (刀 A's instrument), but the
# kernel identity here is g32v::gemm32_var<BNV,BKV,NTV,NBUF,MODE,PUB> ->
# gemm32_varILi32ELi32ELi16ELi3ELi0ELb0EE (the lambda mangled name carries the same
# template argument list, so re.search on the mangled string is enough).
# MODE: 0 = 16r x 16c per thread (shipped BN32/NT16 map), 1 = 8r x 16c (NT32 half-row),
#       2 = 16r x 8c (NT32 half-col); BNV 64/128 rows are the padded ILLEGAL forms.
# Usage: python gemm32_spillcheck.py [cache_dir] [outdir_short_path] [mtime_cutoff_epoch]
import struct, subprocess, sys, os, re

cache  = sys.argv[1] if len(sys.argv) > 1 else r'E:\DSH\sycl-cache'
outdir = sys.argv[2] if len(sys.argv) > 2 else r'E:\tmp\g32k'
since  = float(sys.argv[3]) if len(sys.argv) > 3 else 0.0
ocloc  = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'

def elfs_in(d):
    i = 0; out = []
    while True:
        i = d.find(b'\x7fELF', i)
        if i < 0: break
        emach = struct.unpack('<H', d[i+18:i+20])[0]
        if emach == 0xCD:
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

MODEN = {0:'nt16_16x16', 1:'nt32_halfrow', 2:'nt32_halfcol', 3:'bn64map', 4:'bn128map'}
def label(name):
    m = re.search(r'gemm32_varILi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELb([01])E', name)
    if m:
        BN, BK, NT, NB, MD = (int(x) for x in m.groups()[:5])
        PB = m.group(6)
        return 'g32v BN%-3d BK%-2d NT%-2d BUF%d %-12s %s' % (
            BN, BK, NT, NB, MODEN.get(MD, 'MODE%d' % MD), 'pub' if PB == '1' else 'raw')
    if re.search(r's8v8.*?8gemm32_b[ER]', name) or '::gemm32_b' in name:
        return 's8v8::gemm32_b (shipped)'
    return 'other'

os.makedirs(outdir, exist_ok=True)
bins = []
for root, dirs, files in os.walk(cache):
    if '0.bin' in files:
        bf = os.path.join(root, '0.bin')
        mt = os.path.getmtime(bf)
        if mt >= since: bins.append((mt, bf))
bins.sort()
seen = {}
for mt, bf in bins:
    d = open(bf, 'rb').read()
    for n, (s, sz) in enumerate(elfs_in(d)):
        idx = len(seen)
        mb = os.path.join(outdir, f'c{idx}.bin')
        open(mb, 'wb').write(d[s:s+sz])
        dd = os.path.join(outdir, f'c{idx}')
        os.makedirs(dd, exist_ok=True)
        subprocess.run([ocloc, 'disasm', '-file', mb, '-dump', dd, '-device', 'dg2'],
                       capture_output=True)
        zi = os.path.join(dd, '.ze_info')
        if not os.path.exists(zi): continue
        z = open(zi, 'rb').read().decode('utf-8', 'replace')
        for m in re.finditer(r'- name:\s+(\S+)', z):
            st = m.start(1)
            name = m.group(1)
            blk = z[st:st+4000]
            def g(k):
                mm = re.search(k + r':\s*(\S+)', blk)
                return mm.group(1) if mm else '-'
            sc = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', blk)
            asmf = os.path.join(dd, '.text.' + name + '.asm')
            nscr = 0
            if os.path.exists(asmf):
                nscr = sum(1 for L in open(asmf, encoding='utf-8', errors='replace') if 'scratch' in L)
            lab = label(name)
            if lab == 'other': continue
            key = (lab, g('grf_count'), g('slm_size'))
            seen[key] = (mt, lab, g('grf_count'), g('simd_size'), g('slm_size'),
                         g('spill_size'), g('private_size'),
                         sc.group(1) if sc else '-', nscr)

print(f'{"kernel":44s} {"grf":>4s} {"simd":>4s} {"slm(B)":>7s} {"spill(B)":>8s} {"priv(B)":>8s} {"scrB":>5s} {"scrInstr":>8s}')
for v in sorted(seen.values(), key=lambda r: r[1]):
    print(f'{v[1]:44s} {v[2]:>4s} {v[3]:>4s} {v[4]:>7s} {v[5]:>8s} {v[6]:>8s} {v[7]:>5s} {v[8]:>8d}')
