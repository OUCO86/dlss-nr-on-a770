import re, os

rows = []
for n in range(7):
    zi = f'dep_dis_{n}/.ze_info'
    if not os.path.exists(zi):
        continue
    z = open(zi, 'rb').read().decode('utf-8', 'replace')
    idx = [m.start() for m in re.finditer(r'- name:\s+\S+', z)]
    for j, st in enumerate(idx):
        en = idx[j+1] if j+1 < len(idx) else len(z)
        b = z[st:en]
        name = re.search(r'- name:\s+(\S+)', b).group(1)
        def g(k):
            m = re.search(k + r':\s*(\S+)', b)
            return m.group(1) if m else None
        spill = g('spill_size'); priv = g('private_size'); scratch = re.search(r'type:\s+scratch[\s\S]*?size:\s+(\d+)', b)
        rows.append((name, g('grf_count'), g('simd_size'), g('slm_size'), g('barrier_count'), g('has_dpas'), spill, priv, scratch.group(1) if scratch else None, g('eu_thread_count')))

# short readable name
def short(name):
    m = re.search(r'N(\d+)(\w+)L?(\d*)(\w+)', name)
    if m:
        ns, fn = m.group(2), m.group(4)
        return f'{ns}::{fn}'
    m = re.search(r'(\w{4,30})ERNS', name)
    return m.group(1) if m else name[:34]

spills = [r for r in rows if (r[6] and r[6] != '0') or (r[7] and r[7] != '0') or r[8]]
print(f'total kernels: {len(rows)}; with spill/private/scratch: {len(spills)}')
print(f'{"kernel":30s} {"grf":>4s} {"simd":>4s} {"slmB":>6s} {"spillB":>7s} {"privB":>6s} {"scrB":>6s} {"bar":>3s} dpas')
for r in sorted(spills, key=lambda r: -(int(r[6] or 0)+int(r[7] or 0))):
    print(f'{short(r[0]):30s} {r[1] or "-":>4s} {r[2] or "-":>4s} {r[3] or "-":>6s} {r[6] or "-":>7s} {r[7] or "-":>6s} {r[8] or "-":>6s} {r[4] or "-":>3s} {r[5] or "-"}')

# top kernels by size overall
print('\n=== biggest 15 kernels (instr count from earlier) ===')
