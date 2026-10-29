import struct, subprocess, sys, os, re

exe = sys.argv[1]
outdir = sys.argv[2] if len(sys.argv) > 2 else 'tmp_dis'
ocloc = r'E:\WorkBuddy\toolchain-mamba\ocloc\bin\ocloc.exe'
d = open(exe, 'rb').read()
i = 0; elfs = []
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
        elfs.append((i, end-i))
    i += 1
print(f'{exe}: {len(elfs)} zebin module(s)')
os.makedirs(outdir, exist_ok=True)
for n, (s, sz) in enumerate(elfs):
    bf = os.path.join(outdir, f'mod_{n}.bin')
    open(bf, 'wb').write(d[s:s+sz])
    dd = os.path.join(outdir, f'mod_{n}')
    os.makedirs(dd, exist_ok=True)
    r = subprocess.run([ocloc, 'disasm', '-file', bf, '-dump', dd, '-device', 'dg2'],
                       capture_output=True, text=True)
    zi = os.path.join(dd, '.ze_info')
    if os.path.exists(zi):
        z = open(zi, 'rb').read().decode('utf-8', 'replace')
        idx = [m.start() for m in re.finditer(r'- name:\s+\S+', z)]
        for j, st in enumerate(idx):
            en = idx[j+1] if j+1 < len(idx) else len(z)
            b = z[st:en]
            name = re.search(r'- name:\s+(\S+)', b).group(1)
            def g(k):
                m = re.search(k + r':\s*(\S+)', b)
                return m.group(1) if m else '-'
            sc = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', b)
            asmf = os.path.join(dd, '.text.' + name + '.asm')
            nscr = 0
            if os.path.exists(asmf):
                nscr = sum(1 for L in open(asmf, encoding='utf-8', errors='replace') if 'scratch' in L)
            short = re.sub(r'ERN4sycl.*', '', re.sub(r'_ZTSZZ?', '', name))[:38]
            print(f"  {short:40s} grf={g('grf_count'):>4s} simd={g('simd_size'):>3s} slm={g('slm_size'):>6s} spill={g('spill_size'):>6s} priv={g('private_size'):>6s} scratchB={sc.group(1) if sc else '-':>5s} scratchInstr={nscr}")
