import re, glob, os
# find kernels with scratch in ze_info across all 7 modules + which asm files have scratch msgs
for d in ['dep_dis_%d' % n for n in range(7)]:
    zi = os.path.join(d, '.ze_info')
    if not os.path.exists(zi):
        continue
    z = open(zi, 'rb').read().decode('utf-8', 'replace')
    idx = [m.start() for m in re.finditer(r'- name:\s+\S+', z)]
    for j, st in enumerate(idx):
        en = idx[j+1] if j+1 < len(idx) else len(z)
        b = z[st:en]
        sc = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', b)
        if sc:
            name = re.search(r'- name:\s+(\S+)', b).group(1)
            print(f'{d}: scratch={sc.group(1)}B  {name[:100]}')
