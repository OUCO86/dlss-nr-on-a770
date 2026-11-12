import re, os, sys, glob
sys.stdout.reconfigure(encoding='utf-8')
D = r'G:\Users\wangz\Documents\deepseek-harness\default-workspace\dump'
rows = []
for p in glob.glob(os.path.join(D, '*.asm')):
    name = os.path.basename(p)
    m = re.search(r'gemm_varILi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELi(\d+)ELb(\d)E', name)
    if not m:
        continue
    BM, BK, NT, NBUF, MODE, PUB = [int(x) for x in m.groups()]
    txt = open(p, encoding='utf-8', errors='replace').read()
    lines = [L for L in txt.split('\n') if L.strip().startswith(('0x', 'send', '\t')) or re.match(r'\s*[0-9a-fA-F]{4,}\s', L)]
    n_send = len(re.findall(r'\bsend\.[a-z]+', txt))
    n_ugm = len(re.findall(r'send\.ugm', txt))
    n_lsc = len(re.findall(r'send\.lsc|\bcd\.|\.b1\b', txt))
    n_dp = len(re.findall(r'\bdp\.[a-z0-9]+|dpas', txt))
    n_mac = len(re.findall(r'\bmac\.|\bfma\.', txt))
    slm = re.search(r'dcl\.[a-z]*|slm', txt)
    rows.append((BM, BK, NT, NBUF, MODE, PUB, len(txt.split('\n')), n_send, n_ugm, n_dp, n_mac, name))
rows.sort(key=lambda r: (r[5], r[4], r[0], r[1], r[2]))
print('%-4s %-4s %-4s %-5s %-5s %-4s %8s %7s %7s %6s %6s' % ('BM', 'BK', 'NT', 'NBUF', 'MODE', 'PUB', 'asm ln', 'send', 'ugm', 'dp', 'mac'))
for r in rows:
    print('%-4d %-4d %-4d %-5d %-5d %-4d %8d %7d %7d %6d %6d' % r[:11])
print('\nvariant kernels found:', len(rows))
