#!/usr/bin/env python
# k2b_alive.py -- step 1 of the 2026-11-03 order: mark which of the 398 merge-candidate sites are
# ALIVE on the shipped load slot (ABB969FE), so violation_ms stops being quoted off-path.
#
# Machine evidence only (no guessing):
#   R1 chain id in the compile-time skip list (T_SKIP_CHAINS_DEF in out\DEPLOY.md5.txt:49-52)
#   R2 per-closure RUN_TIMING ms <= FLOOR  => the closure body is a no-op / already dissolved
#   R3 structure: which no-op mechanism (T2 chain skip / S6-1a five-leg no-op at :676-678 /
#      quant dissolved into the pack by the shipped FUSED-pack path / other floor case)
#
# Inputs : E:\DSH\tools\shapes_roofgap.csv      (398 rows; chain / orig / merged / violation_ms)
#          E:\DSH\tools\rt_per_closure.csv     (691 rows; per-closure measured ms)
#          E:\DSH\dlss-nr-on-a770\tools\chain_map.csv (52 chains; op_seq)
# Outputs: E:\DSH\tools\shapes_alive.csv  + stdout summary (tee to E:\DSH\s6\k2b_alive.txt)
import csv, collections, re, sys

# PS 5.1 decodes a child's stdout with the console codepage (GBK) => any non-ASCII in a redirected
# log turns into U+FFFD. So this script writes its own UTF-8 summary file and prints an ASCII-folded
# copy to the console. (knife2b.md P11)
_SUMF = open(r"E:\DSH\s6\k2b_alive.txt", "w", encoding="utf-8")
_print = print
def print(*a, **k):
    _print(*[x.encode('ascii', 'replace').decode() if isinstance(x, str) else x for x in a], **k)
    _print(*a, file=_SUMF, **k)

RG   = r"E:\DSH\tools\shapes_roofgap.csv"
RT   = r"E:\DSH\tools\rt_per_closure.csv"
CM   = r"E:\DSH\dlss-nr-on-a770\tools\chain_map.csv"
OUT  = r"E:\DSH\tools\shapes_alive.csv"

SKIP = {18,19,20,21,22,23,24,26,27,28,29,30,31,32}   # shipped compile-time default
FLOOR = 0.005                                        # timer floor band (0.0020-0.0044 seen)

rt   = {int(r['closure']): r for r in csv.DictReader(open(RT, encoding='utf-8', errors='replace'))}
cm   = {int(r['chain']): r for r in csv.DictReader(open(CM, encoding='utf-8', errors='replace'))}
rows = list(csv.DictReader(open(RG, encoding='utf-8', errors='replace')))

# S6-1a six-op FFN tail: the 5 legs before GEMM_INT8_RESIDUAL get no-op'd (:676-678).
# Detect the tail from the RECORDED STREAM itself (family adjacency in rt_per_closure), not from
# chain_map -- that way the out-of-chain pair (closures 12-18, chain=-1) is caught too.
TAIL = ['xmx_rec_quant','xmx_rec_gemm_int8_batched','xmx_rec_quant',
        'xmx_rec_gemm_int8_batched','xmx_rec_quant','xmx_rec_gemm_int8_residual']
_ids = sorted(rt)
S6_KILLED = set()
for i in range(len(_ids) - 5):
    w = _ids[i:i+5]
    if w[-1] != w[0] + 4:                           # the five legs must be consecutive
        continue
    fams = [rt[j]['family'] for j in w] + [rt[w[-1]+1]['family']]
    if fams == TAIL:
        S6_KILLED.update(w)                        # the five legs (residual keeps running, fused)

def s6_tail_legs(chid):
    return set()

# knife groups from notes/shape-merge-plan.md 7.1 (orig shape strings)
GROUPS = {
 'A1': ['2560x768x256b1'],
 'A2': ['2560x256x256b1'],
 'A3': ['2040x256x256b1','8160x128x128b1'],
 'A4': ['192x1024x4096b1','192x4096x1024b1','192x3072x1024b1','640x512x512b1'],
 'B1(knife2)': ['640x64x256b8','2040x32x128b8','640x256x64b8'],
 'B2': ['2040x128x256b8','8160x128x128b4','32640x128x64b2'],
}
def group_of(orig):
    for g, shapes in GROUPS.items():
        if orig in shapes: return g
    return ''

# merge-group liveness: rows sharing the same `merged` target
merge_alive = collections.Counter()
merge_total = collections.Counter()

recs = []
for r in rows:
    c = int(r['closure']); ch = int(r['chain']) if r['chain'] not in ('', '-1') else None
    rr = rt.get(c, {})
    ms = float(rr['ms']) if rr.get('ms') else None
    viol = float(r['violation_ms']) if r.get('violation_ms') else 0.0
    cause = ''
    if ch is not None and ch in SKIP:
        alive = 0; cause = 'skip-chain(T2 compile-time default)'
    elif ms is not None and ms <= FLOOR:
        alive = 0
        lab = (rr.get('rt_label') or '')
        fam = (rr.get('family') or '')
        if c in S6_KILLED:
            cause = 'S6-1a noop (:676-678 five chain legs)'
        elif 'FUSED-pack' in lab:
            cause = 'quant dissolved into pack (shipped FUSED-pack)'
        elif fam.endswith('quant') or fam.endswith('quant_window'):
            cause = 'quant off-path (floor)'
        else:
            cause = 'off-path floor (mechanism to name)'
    else:
        alive = 1
    g = group_of(r['orig'])
    recs.append(dict(r, closure=c, chain=ch, rt_ms=('' if ms is None else f"{ms:.4f}"),
                     alive=alive, cause=cause, group=g, viol=viol))
    merge_total[r['merged']] += 1
    merge_alive[r['merged']] += alive

for x in recs:
    x['merge_group_members'] = merge_total[x['merged']]
    x['merge_group_alive']   = merge_alive[x['merged']]
    x['merge_still_alive']   = 1 if merge_alive[x['merged']] >= 2 else 0
    x['recovery_alive_ms']   = x['viol'] if (x['alive'] == 1 and x['merge_still_alive'] == 1) else 0.0

cols = ['closure','plan_line','chain','tier','family','dtype','orig','merged','mech',
        'rt_ms','price_ms','orig_roof_ms','merged_ms','violation_ms','ratio','status',
        'group','alive','cause','merge_group_members','merge_group_alive','merge_still_alive','recovery_alive_ms']
with open(OUT, 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=cols, extrasaction='ignore')
    w.writeheader()
    for x in recs: w.writerow(x)

# ---------------- summary ----------------
tot_v  = sum(x['viol'] for x in recs)
alive_v= sum(x['viol'] for x in recs if x['alive'])
al     = sum(1 for x in recs if x['alive'])
print(f"rows={len(recs)}  alive={al}  dead={len(recs)-al}")
print(f"violation_ms paper total = {tot_v:.2f} ms serial  => frame x0.43 = {tot_v*0.43:.2f} ms")
print(f"violation_ms ALIVE total = {alive_v:.2f} ms serial => frame x0.43 = {alive_v*0.43:.2f} ms")
print(f"recovery counted only where the merge still has >=2 alive members = "
      f"{sum(x['recovery_alive_ms'] for x in recs):.2f} ms serial => frame {sum(x['recovery_alive_ms'] for x in recs)*0.43:.2f} ms")
print()
print("--- dead causes ---")
cc = collections.Counter(x['cause'] for x in recs if not x['alive'])
vv = collections.defaultdict(float)
for x in recs:
    if not x['alive']: vv[x['cause']] += x['viol']
for k, n in cc.most_common():
    print(f"  {n:4d}  {vv[k]:7.2f} ms  {k}")
print()
print("--- per knife group (paper vs alive) ---")
for g in list(GROUPS) + ['(other)']:
    sub = [x for x in recs if (x['group'] == g or (g == '(other)' and not x['group']))]
    if not sub: continue
    p = sum(x['viol'] for x in sub); a = sum(x['viol'] for x in sub if x['alive'])
    ra = sum(x['recovery_alive_ms'] for x in sub)
    nal = sum(1 for x in sub if x['alive'])
    print(f"  {g:14s} n={len(sub):3d} alive={nal:3d}  paper={p:6.2f}  alive-price={a:6.2f}  "
          f"alive-recovery={ra:6.2f} ms serial => frame {ra*0.43:5.2f} ms")
print()
print("--- merged targets that go degenerate (<=1 alive member) ---")
deg = [(m, merge_total[m], merge_alive[m]) for m in merge_total if merge_alive[m] <= 1]
for m, t, a in sorted(deg, key=lambda x: -x[1])[:25]:
    print(f"  merged={m:24s} members={t:3d} alive={a}")
print(f"  ... {len(deg)} degenerate merge targets out of {len(merge_total)}")
print()
print("--- 'off-path floor (mechanism to name)' rows, by family ---")
un = [x for x in recs if x['cause'].startswith('off-path floor')]
byf = collections.Counter((x['family'], x['orig']) for x in un)
for (fam, orig), n in byf.most_common(20):
    print(f"  {n:3d}  {fam:38s} {orig}")
print(f"  total unnamed-floor rows = {len(un)}")
print()
print("--- per orig-shape breakdown inside the knife groups (alive / dead by cause) ---")
for g in GROUPS:
    sub = [x for x in recs if x['group'] == g]
    if not sub: continue
    print(f" [{g}]")
    byshape = collections.defaultdict(lambda: [0,0,0,0.0,0.0])   # total, alive, dead, paper_viol, alive_viol
    for x in sub:
        b = byshape[x['orig']]
        b[0] += 1
        if x['alive']: b[1] += 1
        else: b[2] += 1
        b[3] += x['viol']
        if x['alive']: b[4] += x['viol']
    for s, (t, a, d, p, av) in sorted(byshape.items(), key=lambda kv: -kv[1][3]):
        print(f"   {s:22s} n={t:3d} alive={a:3d} dead={d:3d}  paper={p:6.2f}  alive={av:6.2f} ms serial")
print()
print("--- MEASURED current price per knife group (rt_per_closure, not apportioned) ---")
# orig string is MxNxKx<bN>; sum the measured ms of the closures that carry that shape.
def shape_tuple(orig):
    # the census writes shapes as MxNxKb<batch> -- '640x64x256b8' = M640 N64 K256 batch8
    # (only TWO 'x' separators; a third one in the regex silently matched nothing: 2026-11-03 12:1x)
    m = re.match(r'^(\d+)x(\d+)x(\d+)b(\d+)$', orig)
    if not m: return None
    return (int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4)))
for g in list(GROUPS):
    sub = [x for x in recs if x['group'] == g]
    tot = alv = 0.0; n = na = 0; cmpable = mism = 0
    for x in sub:
        t = shape_tuple(x['orig'])
        r = rt.get(x['closure'])
        if not r or not r.get('ms'): continue
        # sanity cross-check only: some families leave K empty in rt_per_closure (qkv/residual),
        # so a missing field is NOT counted as a mismatch -- dropping rows silently was the bug.
        if t and all(r.get(k) not in (None, '') for k in ('M','N','K','batch')):
            cmpable += 1
            if (int(r['M']), int(r['N']), int(r['K']), int(r['batch'])) != t: mism += 1
        v = float(r['ms']); tot += v; n += 1
        if x['alive']: alv += v; na += 1
    print(f"  {g:12s} n={n:3d} alive={na:3d}   measured now = {tot:6.2f} ms serial   alive-only = {alv:6.2f} ms "
          f"=> frame {alv*0.43:5.2f} ms   [shape cross-check: {cmpable} comparable, {mism} mismatch]")

print()
print("--- dead rows by tier (which chains the T2 skip removed) ---")
bt = collections.Counter((x['tier'], x['cause'][:12]) for x in recs if not x['alive'])
for (tier, cz), n in sorted(bt.items()):
    print(f"   tier={tier:12s} cause={cz:12s} n={n}")
