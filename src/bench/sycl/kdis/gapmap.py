import re, os
# locate the QKV phase-1 store loop in v4full asm: the big gaps had 36/50/29/23 slm STORES.
# Count how many of the 156 slm stores are d64x4t (the 16-float merged stores = 4/reg) vs others.
f="dis/.text._ZTSZZ13launch_v4fullILi0EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_.asm"
lines=open(f,encoding='utf-8',errors='replace').readlines()
# dpas line indices
idxs=[i for i,L in enumerate(lines) if 'dpas' in L]
print('dpas total', len(idxs))
# per gap, count slm stores by comment type
for n,(a,b) in enumerate(zip(idxs,idxs[1:])):
    seg=lines[a:b]
    st=[L for L in seg if 'send.slm' in L and 'rd:0' in L]
    ld=[L for L in seg if 'send.slm' in L and 'rd:' in L and 'rd:0' not in L]
    if len(st)+len(ld) >= 10:
        from collections import Counter
        cc=Counter(re.search(r'; (\S+)',L).group(1) for L in st if re.search(r'; (\S+)',L))
        cl=Counter(re.search(r'; (\S+)',L).group(1) for L in ld if re.search(r'; (\S+)',L))
        print(f'gap {n} ({a}->{b}): stores={len(st)} loads={len(ld)} storemap={dict(cc)} loadmap={dict(cl)}')
# also count where the big LOAD clusters sit (phase-2 reloads)
big_ld=[]
for n,(a,b) in enumerate(zip(idxs,idxs[1:])):
    seg=lines[a:b]
    ld=[L for L in seg if 'send.slm' in L and 'rd:' in L and 'rd:0' not in L]
    if len(ld)>=8: big_ld.append((n,a,b,len(ld)))
print('big load gaps:', big_ld)
