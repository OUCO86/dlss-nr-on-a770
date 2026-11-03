#!/usr/bin/env python
# k2b_chainmap.py -- closure -> chain mapping for knife-2 accounting (host-side, no GPU).
# Inputs : E:/DSH/tools/rt_per_closure.csv (691 rows, from rt2 variant = NO skip default)
#          E:/DSH/dlss-nr-on-a770/tools/chain_map.csv (52 chains)
# Output : stdout table. Key question set:
#   (1) the 40 suspect batched closures (M in {32640,8160}) -- which chains, how many batched legs per chain
#   (2) the 48 knife-2 target sites (S0/S1/S2) -- which chains, and are those chains in the
#       SHIPPED compile-time skip set DT_SKIP_CHAINS_DEF="18,19,20,21,22,23,24,26,27,28,29,30,31,32"?
import csv, io, re, sys

RT = r"E:\DSH\tools\rt_per_closure.csv"
CM = r"E:\DSH\dlss-nr-on-a770\tools\chain_map.csv"
SKIPPED = {18,19,20,21,22,23,24,26,27,28,29,30,31,32}   # DT_SKIP_CHAINS_DEF in ABB969FE (promote2)

S0 = [217,229,241,253,265,277,289,301,391,403,415,427,439,451,463,475]
S1 = [131,141,151,161,171,181,191,201,487,497,507,517,527,537,547,557]
S2 = [215,227,239,251,263,275,287,299,389,401,413,425,437,449,461,473]

rt = list(csv.DictReader(open(RT, encoding='utf-8', errors='replace')))
cm = list(csv.DictReader(open(CM, encoding='utf-8', errors='replace')))
by_clos = {int(r['closure']): r for r in rt}

def chain_of(c):
    for row in cm:
        a, b = int(row['closure_first']), int(row['closure_last'])
        if a <= c <= b:
            return row
    return None

def fmt(c):
    r = by_clos.get(c)
    ch = chain_of(c)
    if ch is None:
        cs = "OUT_OF_CHAINS"
    else:
        nb = len(re.findall(r'GEMM_INT8_BATCHED', ch['op_seq']))
        cs = f"chain={ch['chain']:>2} tier={ch['tier']:>5} range={ch['closure_first']}-{ch['closure_last']} nbatched={nb} pure={ch['pure']} skip_ok={ch['skippable']}"
        cs += "  <<SKIPPED-IN-SHIP" if int(ch['chain']) in SKIPPED else ""
    ms = r['ms'] if r else '?'
    return f"  c{c:<4} ms={ms:<7} {cs}"

print("=== (1) the 40 suspect batched closures: M in {32640,8160}, family=xmx_rec_gemm_int8_batched ===")
sus = [r for r in rt if r['family'] == 'xmx_rec_gemm_int8_batched' and r['M'] in ('32640','8160')]
print(f"count = {len(sus)}")
tot = sum(float(r['ms']) for r in sus)
print(f"sum ms (rt2, no skip) = {tot:.4f}")
chains = {}
for r in sus:
    ch = chain_of(int(r['closure']))
    key = ch['chain'] if ch else 'OUT'
    chains.setdefault(key, []).append((int(r['closure']), r['N'], r['K'], r['batch'], r['ms']))
for k in sorted(chains, key=lambda x: (x == 'OUT', int(x) if x != 'OUT' else 0)):
    ch = None if k == 'OUT' else next(c for c in cm if c['chain'] == k)
    nb = len(re.findall(r'GEMM_INT8_BATCHED', ch['op_seq'])) if ch else 0
    tag = "SKIPPED-IN-SHIP" if ch and int(k) in SKIPPED else ("ship-active" if ch else "not-in-chain")
    print(f"chain {k}: nbatched_in_seq={nb} tier={ch['tier'] if ch else '-'} {tag} -> " +
          "; ".join(f"c{c}(N={n},K={kk},b={b})={m}" for c, n, kk, b, m in chains[k]))

print()
print("=== (2) the 48 knife-2 sites -> chain membership vs shipped skip set ===")
for name, lst in (("S0 int8 640x64x256b8", S0), ("S1 f16 2040x32x128b8", S1), ("S2 f16 640x256x64b8 epi2", S2)):
    act = dead = unk = 0
    tot_ms = 0.0
    print(f"-- {name} --")
    for c in lst:
        line = fmt(c)
        print(line)
        ch = chain_of(c)
        r = by_clos.get(c)
        if r: tot_ms += float(r['ms'])
        if ch is None: unk += 1
        elif int(ch['chain']) in SKIPPED: dead += 1
        else: act += 1
    print(f"   ACTIVE-in-ship={act}  DEAD-in-ship={dead}  outside-chains={unk}   rt2-sum={tot_ms:.3f} ms")
    print()

print("=== (3) shipped-skip reconciliation of the 40: how many suspects live in skipped chains ===")
d = sum(1 for r in sus if (ch := chain_of(int(r['closure']))) and int(ch['chain']) in SKIPPED)
print(f"   suspects in skipped chains = {d} of {len(sus)}  (=> the other {len(sus)-d} need another mechanism: S6-1a no-op at :677-678)")
