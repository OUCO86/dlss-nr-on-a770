import re, glob, os
from collections import Counter

# ---- 1. per-kernel resource + scratch table from ze_info ----
z = open('.ze_info', 'rb').read().decode('utf-8', 'replace')
idx = [m.start() for m in re.finditer(r'- name:\s+\S+', z)]
print(f'kernels: {len(idx)}')
for j, st in enumerate(idx):
    en = idx[j+1] if j+1 < len(idx) else len(z)
    b = z[st:en]
    name = re.search(r'- name:\s+(\S+)', b).group(1)
    short = re.sub(r'ERN4sycl.*', '', re.sub(r'_ZTSZZ?', '', name))[:40]
    def g(k):
        m = re.search(k + r':\s*(\S+)', b)
        return m.group(1) if m else '-'
    scratch = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', b)
    print(f"{short:42s} grf={g('grf_count'):>4s} slm={g('slm_size'):>6s} dpas={g('has_dpas'):>5s} scratch={scratch.group(1) if scratch else '0'}")

# ---- 2. per-kernel asm ledgers ----
def classify(fn):
    c = Counter()
    msgs = Counter()
    n = 0
    for line in open(fn, encoding='utf-8', errors='replace'):
        s = line.strip()
        if not s or s.startswith('//') or re.match(r'^L\d+:', s):
            continue
        # strip predicates/optionals
        while True:
            m = re.match(r'^\(([^)]*)\)\s+', s)
            if m:
                s = s[m.end():]
            else:
                break
        if not s:
            continue
        op = s.split()[0]
        c[op] += 1
        n += 1
        m2 = re.search(r'// (?:wr:[^;]*; )?([a-z0-9_.]+)', line)
        if m2 and op.startswith('send'):
            msgs[m2.group(1)] += 1
    return c, msgs, n

targets = {
    'v4full_F0':  '.text._ZTSZZ13launch_v4fullILi0E',
    'v4full_F32': '.text._ZTSZZ13launch_v4fullILi32E',
    'wbmega_full':'  .text._ZTSZZN6wbmega11launch_full',
    'wbv3_v3':    '.text._ZTSZZN4wbv39launch_v3',
    's8v8_gemmwin':'.text._ZTSZZN4s8v8L17gemm_b_res_window',
    's8v8_gemmpub':'.text._ZTSZZN4s8v8L10gemm_b_pub',
    'qkvnorm_scatter_esimd':'.text._ZTSZZN6wbmega22qkv_norm_scatter_esimd',
}
files = os.listdir('.')
for label, pat in targets.items():
    fn = next((f for f in files if f.startswith(pat.strip())), None)
    if not fn:
        print(f'!! {label}: no file for {pat}')
        continue
    c, msgs, n = classify(fn)
    # ledger groups
    movish = sum(v for k, v in c.items() if k in ('mov', 'mov.b16', 'mov.b8', 'sel', 'join', 'cbit'))
    slm_ld = sum(v for k, v in msgs.items() if k.startswith('load.slm'))
    slm_st = sum(v for k, v in msgs.items() if k.startswith('store.slm'))
    ugm_ld = sum(v for k, v in msgs.items() if k.startswith('load.ugm'))
    ugm_st = sum(v for k, v in msgs.items() if k.startswith('store.ugm'))
    scratch = sum(v for k, v in msgs.items() if 'scratch' in k)
    print(f'\n== {label}  file_instr={n}')
    print(f'   LEDGER movish={movish} sel={c.get("sel",0)} join={c.get("join",0)} dpas={c.get("dpas.8x8",0)+c.get("dpas",0)} | slm_ld={slm_ld} slm_st={slm_st} ugm_ld={ugm_ld} ugm_st={ugm_st} scratch_msgs={scratch}')
    print('   top15:', ', '.join(f'{k}={v}' for k, v in c.most_common(15)))
    print('   msgs :', ', '.join(f'{k}={v}' for k, v in msgs.most_common(12)))
