import sys, re
sys.stdout.reconfigure(encoding='utf-8')

SRC = open(r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp', encoding='utf-8', errors='replace').read().split('\n')

print('=== (1) what one window_attention closure actually pushes (read :6891-7010) ===')
pat = re.compile(r'(packdev::\w+|parallel_for|s8v8::\w+|qres::\w+|GQ->parallel_for)')
for j in range(6890, 7010):
    x = SRC[j].rstrip()
    m = pat.search(x)
    if m and 'if (' not in x[:6]:
        print('  :%5d  %s' % (j + 1, x.strip()[:118]))
print()
print('=== guards seen on this path (221: read the branch + any VERDICT comment) ===')
for j in range(6885, 6960):
    x = SRC[j].strip()
    if re.search(r'NR_WA_RES|rawv2|wat|smaxplain|VERDICT|P10|P9', x):
        print('  :%5d  %s' % (j + 1, x[:126]))
print()
print('=== (2) unary family: per-kind elements and the two cost hypotheses ===')
# from wb_c101_ukinds.py (plan census):
kinds = {18: (10, 16322560), 21: (8, 7966720), 12: (10, 4179968), 16: (4, 2097152)}
fam_ms = 2.83
tot_el = sum(v[1] for v in kinds.values())
tot_leg = sum(v[0] for v in kinds.values())
print('  family: %d legs, %.2f M elements, %.2f ms/frame (ablation)' % (tot_leg, tot_el / 1e6, fam_ms))
print('  hypothesis A (cost ~ bytes):')
for k, (legs, el) in sorted(kinds.items()):
    print('     kind %3d: %2d legs, %8d elem -> %.2f ms/frame  (%.4f ms/leg)'
          % (k, legs, el, fam_ms * el / tot_el, fam_ms * el / tot_el / legs))
print('  hypothesis B (cost ~ launches, i.e. per-leg fixed cost dominates):')
for k, (legs, el) in sorted(kinds.items()):
    print('     kind %3d: %2d legs -> %.2f ms/frame  (%.4f ms/leg)'
          % (k, legs, fam_ms * legs / tot_leg, fam_ms / tot_leg))
print('  => the two hypotheses differ a lot for kind 18 (53%% of elements, 31%% of legs):')
print('     A gives %.2f ms/frame, B gives %.2f ms/frame -> the kind-level split needs a MEASURED'
      % (fam_ms * kinds[18][1] / tot_el, fam_ms * kinds[18][0] / tot_leg))
print('     per-kind stop (or the serial ledger by kind) before any knife here. (2) done as an')
print('     account, not a measurement - stated so on purpose.')
