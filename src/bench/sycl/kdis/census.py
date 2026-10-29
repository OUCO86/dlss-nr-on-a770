import re, glob, os, sys
from collections import Counter

# census across all deploy-chain disasm dirs
dirs = sys.argv[1:] or ['dep_dis_0','dep_dis_1','dep_dis_2','dep_dis_3','dep_dis_4','dep_dis_5','dep_dis_6']

def demangle_short(name):
    # extract readable kernel name from mangled .text._ZTS...
    m = re.search(r'([A-Za-z_][A-Za-z0-9_]{2,})ER?N?4?sycl', name)
    # simpler: pull known namespaces/functions
    for pat in ['qfuse_take','qfuse','gemm_b_res_window','gemm_b_pub','gemm_b_res','gemm_window_int8','window_block','launch_full','launch_mega256','launch_leg1','launch_v3','launch_v4full','qkv_norm_scatter_vit_esimd','qkv_norm_scatter_esimd','qkv_norm_scatter_v2','qkv_norm_esimd','normalize_esimd','gemm_b_pub_f16','gemm_dual_pub','gemm_pub_pa16','gemm_merge_scale','gemm_b_merge_scale','gemm_pub','gemm_res','gemm_b','gemm','ffn_tail_res','gather_a16','gather_b16','pack_a16_b','pack_a16_v','pack_b16_b','pack_b16_t','gather_b16_t','pack_b16_t_b','unary','softmax','cosine','quant']:
        if pat in name:
            return pat
    return name[:40]

def classify(fn):
    c = Counter(); msgs = Counter(); n = 0
    for line in open(fn, encoding='utf-8', errors='replace'):
        s = line.strip()
        if not s or s.startswith('//') or re.match(r'^L\d+:', s) or s.endswith(':'):
            continue
        while True:
            m = re.match(r'^\(([^)]*)\)\s+', s)
            if m:
                s = s[m.end():]
            else:
                break
        if not s:
            continue
        op = s.split()[0]
        c[op] += 1; n += 1
        m2 = re.search(r'// (?:wr:[^;]*; )?(.+?)\s*$', line)
        if m2 and op.startswith('send'):
            desc = m2.group(1)
            first = desc.split()[0]
            # dotted keys (load.slm..., store.ugm...) are single tokens
            if '.' in first:
                key = first
            elif 'scratch' in desc:
                key = 'scratch'
            else:
                key = first
            msgs[key] += 1
    return c, msgs, n

rows = []
for d in dirs:
    zeinfo = os.path.join(d, '.ze_info')
    resmap = {}
    if os.path.exists(zeinfo):
        z = open(zeinfo, 'rb').read().decode('utf-8', 'replace')
        idx = [m.start() for m in re.finditer(r'- name:\s+\S+', z)]
        for j, st in enumerate(idx):
            en = idx[j+1] if j+1 < len(idx) else len(z)
            b = z[st:en]
            name = re.search(r'- name:\s+(\S+)', b).group(1)
            grf = re.search(r'grf_count:\s*(\d+)', b)
            slm = re.search(r'slm_size:\s*(\d+)', b)
            sc = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', b)
            resmap[name] = (int(grf.group(1)) if grf else 0, int(slm.group(1)) if slm else 0, int(sc.group(1)) if sc else 0)
    for base in os.listdir(d):
        if not base.startswith('.text.'):
            continue
        fn = os.path.join(d, base)
        base = os.path.basename(fn)
        mangled = base[len('.text.'):-len('.asm')] if base.endswith('.asm') else base[6:]
        c, msgs, n = classify(fn)
        slm_ld = sum(v for k, v in msgs.items() if k.startswith('load.slm'))
        slm_st = sum(v for k, v in msgs.items() if k.startswith('store.slm'))
        ugm_ld = sum(v for k, v in msgs.items() if k.startswith('load.ugm'))
        ugm_st = sum(v for k, v in msgs.items() if k.startswith('store.ugm'))
        scr = sum(v for k, v in msgs.items() if 'scratch' in k)
        dpas = c.get('dpas.8x8', 0) + c.get('dpas', 0) + c.get('dpas.wg', 0)
        movish = c.get('mov', 0) + c.get('sel', 0) + c.get('join', 0)
        grf, slm_sz, scr_sz = resmap.get(mangled, (0, 0, 0))
        rows.append((demangle_short(mangled), n, movish, slm_ld, slm_st, ugm_ld, ugm_st, dpas, scr, scr_sz, grf, slm_sz, base[:50]))

rows.sort(key=lambda r: -r[1])
print(f'{"kernel":24s} {"instr":>6s} {"movish":>6s} {"slmLD":>5s} {"slmST":>5s} {"ugmLD":>5s} {"ugmST":>5s} {"dpas":>4s} {"scrM":>4s} {"scrB":>5s} {"grf":>3s} {"slmB":>6s}')
for r in rows[:60]:
    print(f'{r[0]:24s} {r[1]:6d} {r[2]:6d} {r[3]:5d} {r[4]:5d} {r[5]:5d} {r[6]:5d} {r[7]:4d} {r[8]:4d} {r[9]:5d} {r[10]:3d} {r[11]:6d}')
print(f'... total kernels: {len(rows)}')
tot_scr = sum(r[8] for r in rows); tot_scrb = sum(r[9] for r in rows)
print(f'CHAIN LEDGER: total scratch instr msgs={tot_scr}, kernels with scratch bytes={sum(1 for r in rows if r[9]>0)}, total scratch bytes={tot_scrb}')
