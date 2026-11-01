# spillcheck_port.py -- per-kernel grf/simd/slm/spill/private/scratch ledger for the JIT
# persistent cache, adapted for the PORT bench kernels (p2::fused<Geo<C,HID,TG,G,WM,KNIFE>>,
# ffn2c::fused<Shape<T,C,HID,KS4,KS6,BAR>>, plus the original port::fused<Geo<C,HID>>).
# Same ELF-scan + ocloc disasm parse as src/bench/sycl/spillcheck_cache.py; only label() differs.
# Usage: python E:/DSH/s6/spillcheck_port.py [cache_dir] [outdir_short] [mtime_cutoff_epoch]
import struct, subprocess, sys, os, re

cache = sys.argv[1] if len(sys.argv) > 1 else r'E:\DSH\sycl-cache'
outdir = sys.argv[2] if len(sys.argv) > 2 else r'E:\tmp\pc'
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
    # <ns>L5fusedINS_[<其他命名空间前缀>*]<n>(Geo|Shape)I[J]Li..ELi..(E..)EELb(DUMP)ELi(NPHASE)E...
    # 2026-11-01 修：跨命名空间模板实参（ffn3::fused<ffn2::Shape<...>>）以前匹配不到，
    # 会被静默归入 other（C2-7"台账没拿到"有一半是这个）。前缀链与可选 J 现在都允许。
    mm = re.search(r'(\w+)L5fusedINS_(?:(?:\d+\w+)*)\d+(Geo|Shape)IJ?((?:Li-?\d+E|Lb[01]E)+)', name)
    if mm:
        ns, kind, argstr = mm.groups()
        args = [x if x != '' else y for x, y in
                re.findall(r'Li(-?\d+)|Lb([01])', argstr)]
        md = re.search(r'E{1,2}Lb(\d)ELi(\d+)E', name[mm.end():])
        dump, nph = (md.groups() if md else ('?', '?'))
        if kind == 'Geo':       # Geo<C,HID,TG,G,WM,KNIFE>  (B stage: Geo<C,HID>)
            while len(args) < 6: args.append('-')
            C,HID,TG,G,WM,KN = args[:6]
            return f'{ns}::fused C{C} HID{HID} TG{TG} G{G} WM{WM} KN{KN} dump{dump} P{nph}'
        T,C,HID,b,K4,K6,BAR = (args + ['-']*7)[:7]   # Shape<T,C,HID,F16,KS4,KS6,BAR>
        return f'{ns}::fused T{T} C{C} HID{HID} KS4_{K4} KS6_{K6} BAR{BAR} dump{dump} P{nph}'
    for fn, nm in (('gemm_b_pub','s8v8::gemm_b_pub'),('gemm_b_res8','s8v8::gemm_b_res8'),
                   ('gemm_b_res','s8v8::gemm_b_res'),
                   ('gemm_b_pub_slm','s8v8::gemm_b_pub_slm'),('gemm32_b','s8v8::gemm32_b'),
                   ('gemm32','s8v8::gemm32'),('gemm_b','s8v8::gemm_b'),('gemm','s8v8::gemm')):
        if re.search(r's8v8.*?\d+' + fn + r'[ER]', name) or ('::'+fn) in name:
            return nm + ('' if fn != 'gemm' else '(v8)')
    if 'qr_kernel' in name: return 'quantize_row'
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
            blk = z[st:st+6000]
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

print(f'{"kernel":52s} {"grf":>4s} {"simd":>4s} {"slm(B)":>7s} {"spill(B)":>8s} {"priv(B)":>8s} {"scrB":>5s} {"scrInstr":>8s}')
for v in sorted(seen.values(), key=lambda r: (r[1], r[2])):
    print(f'{v[1]:52s} {v[2]:>4s} {v[3]:>4s} {v[4]:>7s} {v[5]:>8s} {v[6]:>8s} {v[7]:>5s} {v[8]:>8d}')
