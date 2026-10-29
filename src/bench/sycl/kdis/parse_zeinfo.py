import re, sys
z = open('.ze_info', 'rb').read().decode('utf-8', 'replace')
idx = [m.start() for m in re.finditer(r'-\s+name:\s+\S+', z)]
print('kernels:', len(idx))
def g(b, k):
    m = re.search(k + r':\s*(\S+)', b)
    return m.group(1) if m else '-'
for j, st in enumerate(idx):
    en = idx[j+1] if j+1 < len(idx) else len(z)
    b = z[st:en]
    name = re.search(r'-\s+name:\s+(\S+)', b).group(1)
    short = re.sub(r'ERN4sycl.*', '', re.sub(r'_ZTSZZ?', '', name))[:44]
    print(f"{short:46s} grf={g(b,'grf_count'):>4s} slm={g(b,'slm_size'):>6s} dpas={g(b,'has_dpas'):>5s} bar={g(b,'barrier_count'):>3s} simd={g(b,'simd_size'):>3s} scratch={g(b,'scratch_size')}")
