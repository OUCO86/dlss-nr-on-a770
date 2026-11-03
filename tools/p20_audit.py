import re, csv, io
# P20 audit: in every stress / relaunch harness, list each kernel->kernel (or memset->kernel)
# handoff and whether an explicit ext_oneapi_submit_barrier() sits between them.
FILES = {
 'port_ffn_fused.cpp': 'PORT_STRESS',
 's6b_att.cpp': 'S6B_ATT_REPEAT',
 'stress_repeat.cpp': 'CTRL(stress_repeat)',
 's6_ffn_block4.cpp': 'M_REPEAT',
 'port_e_chain.cpp': 'chain stress + REF/CHAIN legs',
}
rows = []
for f, arm in FILES.items():
    p = r"E:\DSH\dlss-nr-on-a770\src\bench\sycl" + "\\" + f
    ls = io.open(p, encoding='utf-8', errors='replace').read().splitlines()
    # find the arm's loop region
    start = None
    for i, l in enumerate(ls):
        if arm.split('(')[0] in l and ('getenv' in l or 'M_REPEAT' in l):
            start = i; break
    if start is None:
        rows.append([f, arm, 'ARM-NOT-FOUND', '', ''])
        continue
    end = min(len(ls), start + 120)
    seg = ls[start:end]
    for i, l in enumerate(seg):
        if re.search(r'(parallel_for|packdev::|s8v8::|qres::|wares::|f16v\d::|qr_launch_esimd|::fused<|\.submit\(|memset\()', l) and not l.strip().startswith('//'):
            after = " ".join(x.strip() for x in seg[i:i+4])
            has_b = 'ext_oneapi_submit_barrier' in after
            has_w = '.wait()' in after or re.search(r'\bq\.wait\(\)', after)
            rows.append([f, arm, str(start + i + 1), l.strip()[:70],
                         'BARRIER' if has_b else ('wait-only' if has_w else 'NO-SYNC')])
with io.open(r"E:\DSH\s6\p20_audit.csv", 'w', encoding='utf-8', newline='') as w:
    cw = csv.writer(w); cw.writerow(['file', 'arm', 'line', 'call', 'sync'])
    cw.writerows(rows)
print("rows", len(rows))
from collections import Counter
print(Counter((r[0], r[4]) for r in rows))
for r in rows:
    if r[4] != 'BARRIER': print("  NO-BARRIER:", r)
