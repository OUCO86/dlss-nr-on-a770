# spillcheck_cache.py -- per-kernel grf/simd/slm/spill/private/scratch ledger for the
# JIT persistent cache (the binaries that ACTUALLY RAN, not an AOT rebuild).
# Same ELF-scan + ocloc disasm parse as kdis/spillcheck.py, but the inputs are the
# SYCL_CACHE_PERSISTENT 0.bin files (UR-wrapped; the zebin ELFs inside carry
# e_machine=0xCD). Kernel identity comes from the mangled template arguments, e.g.
# t8v::gemm_var<BNV,BKV,NTV,NBUF,MODE,PUB> -> gemm_varILi64ELi32ELi32ELi2ELi0ELb0EE.
# Usage: python spillcheck_cache.py [cache_dir] [outdir_short_path] [mtime_cutoff_epoch]
#   defaults: the bench/esimd/sycl-cache dir, E:/tmp/s8v8k, 0
# (MAX_PATH trap from blueprint 6.8: dump to a SHORT path.)
import struct, subprocess, sys, os, re

cache = sys.argv[1] if len(sys.argv) > 1 else r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\bench\esimd\sycl-cache'
outdir = sys.argv[2] if len(sys.argv) > 2 else r'E:\tmp\s8v8k'
since = float(sys.argv[3]) if len(sys.argv) > 3 else 0.0
ocloc = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'

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

def label(name):
    m = re.search(r'gemm_varILi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELb([01])E', name)
    if m:
        BN,BK,NT,NB,MD,PB = m.groups()
        mode = {'0':'bn64','1':'bn128nt64','2':'bn128ser','3':'bn128naive'}[MD]
        return f'{mode} BN{BN} BK{BK} NT{NT} BUF{NB} {"pub" if PB=="1" else "raw"}'
    for fn, nm in (('gemm_b_pub','s8v8::gemm_b_pub'),('gemm_b_res8','s8v8::gemm_b_res8'),
                   ('gemm_b_res_window','s8v8::gemm_b_res_window'),('gemm_b_res','s8v8::gemm_b_res'),
                   ('gemm_b_pub_slm','s8v8::gemm_b_pub_slm'),('gemm32_b','s8v8::gemm32_b'),
                   ('gemm32','s8v8::gemm32'),('gemm_b','s8v8::gemm_b'),('gemm','s8v8::gemm')):
        if re.search(r's8v8.*?\d+' + fn + r'[ER]', name) or ('::'+fn) in name:
            return nm + ('' if fn != 'gemm' else '(v8)')
    if 'gather_pack' in name: return 'packdev::gather_pack*'
    if 'pack' in name: return 'packdev::pack*'
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

print(f'{"kernel":34s} {"grf":>4s} {"simd":>4s} {"slm(B)":>7s} {"spill(B)":>8s} {"priv(B)":>8s} {"scrB":>5s} {"scrInstr":>8s}')
for v in sorted(seen.values(), key=lambda r: r[1]):
    print(f'{v[1]:34s} {v[2]:>4s} {v[3]:>4s} {v[4]:>7s} {v[5]:>8s} {v[6]:>8s} {v[7]:>5s} {v[8]:>8d}')
