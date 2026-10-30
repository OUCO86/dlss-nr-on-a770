import re, os, sys
from collections import Counter

# density ledger: dpas vs slm round-trips vs movish for the HOT-family kernels
HOT = ['gemm_b_pub','gemm_b_res','gemm_b_res_window','gemm_b_pub_f16','gemm_dual_pub',
       'gemm_pub','gemm_pub_pa16','gemm_b_merge_scale','gemm_res','gemm_b','launch_v4full',
       'qkv_norm_scatter','normalize_esimd','qkv_norm_esimd','quant','qr_','batched',
       'window_int8_residual','gemm_window','ffn','stem_mega','launch_ffn_chip',
       'merge_heads','unary','softmax','cosine','residual','pre_kernel','post_kernel',
       'gather','pack_','publish','window_block','wa_res','attnv']

def classify(fn):
    c = Counter(); msgs = Counter(); n = 0
    for line in open(fn, encoding='utf-8', errors='replace'):
        s = line.strip()
        if not s or s.startswith('//') or re.match(r'^L\d+:', s) or s.endswith(':'):
            continue
        while True:
            m = re.match(r'^\(([^)]*)\)\s+', s)
            if m: s = s[m.end():]
            else: break
        if not s: continue
        op = s.split()[0]
        c[op] += 1; n += 1
        m2 = re.search(r'// (?:wr:[^;]*; )?(.+?)\s*$', line)
        if m2 and op.startswith('send'):
            desc = m2.group(1); first = desc.split()[0]
            key = first if '.' in first else ('scratch' if 'scratch' in desc else first)
            msgs[key] += 1
    return c, msgs, n

rows = []
for d in ['dep_dis_0','dep_dis_1','dep_dis_2','dep_dis_3','dep_dis_4','dep_dis_5','dep_dis_6']:
    if not os.path.isdir(d): continue
    for base in os.listdir(d):
        if not base.startswith('.text.') or not base.endswith('.asm'): continue
        mangled = base[6:-4]
        # short family label
        lab = None
        for h in HOT:
            if h in mangled: lab = h; break
        if lab is None: continue
        c, msgs, n = classify(os.path.join(d, base))
        dpas = sum(v for k, v in c.items() if k.startswith('dpas'))
        slm_ld = sum(v for k, v in msgs.items() if k.startswith('load.slm'))
        slm_st = sum(v for k, v in msgs.items() if k.startswith('store.slm'))
        ugm = sum(v for k, v in msgs.items() if k.startswith(('load.ugm','store.ugm','oword','hword')))
        movish = c.get('mov',0)+c.get('sel',0)+c.get('join',0)
        if dpas == 0: continue
        rows.append((n, dpas, slm_ld, slm_st, ugm, movish, lab, mangled[:70], 100.0*dpas/max(n,1)))

rows.sort(key=lambda r: -r[0])
print(f'{"kernel":22s} {"instr":>6s} {"dpas":>5s} {"dens%":>6s} {"slmLD":>5s} {"slmST":>5s} {"ugm":>4s} {"movish":>6s}')
tot_instr=tot_dpas=0
for n, dpas, ld, st, ugm, mv, lab, mm, dens in rows[:30]:
    print(f'{lab:22s} {n:6d} {dpas:5d} {dens:6.1f} {ld:5d} {st:5d} {ugm:4d} {mv:6d}')
    tot_instr += n; tot_dpas += dpas
print(f'TOP30 totals: instr={tot_instr} dpas={tot_dpas} density={100.0*tot_dpas/tot_instr:.1f}%')
