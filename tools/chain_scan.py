# chain_scan.py -- segment the captured-graph recorder ops (plan_960x544.c lines 5308..6643,
# graph region ONLY per 军规 13) into BLOCK CHAINS so NR_SKIP_CHAINS can address them by
# index without guessing.
#
# Chain k = the k-th OP_XMX_REC_QUANT_WINDOW in graph order (52 of them). The chain runs to
# its terminating OP_XMX_REC_GEMM_INT8_RESIDUAL (inclusive); if a head-family op
# (FFN / FFN_STEM / FFN_MERGE / WINDOW_BLOCK / UNARY2) or a new QUANT_WINDOW comes first,
# the chain is UNTERMINATED (only the last decoder block, k=51, does that -- it feeds the
# network head straight from its attention-residual leg).
#
# SKIPPABLE = pure residual block: every op in the range is one of
#   QUANT_WINDOW GEMM_INT8_QKV WINDOW_ATTENTION QUANT GEMM_WINDOW_INT8_RESIDUAL
#   GEMM_INT8_BATCHED GEMM GEMM_INT8 GEMM_INT8_RESIDUAL
# and the chain terminated normally. Chains that carry UNARY(/2)+GEMM patch-merge legs are
# TIER TRANSITIONS: no-oping them would leave the next tier reading a stale pyramid face ->
# never skip those (they are marked, not silently offered).
#
# Usage:
#   py tools/chain_scan.py --csv E:\DSH\s6\chain_map.csv [--dump]
#   py tools/chain_scan.py --range A B          # raw op dump (closure indices)
import re, sys, csv, io
from collections import Counter

P = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
LO, HI = 5308, 6643
pat = re.compile(r'\b(OP_XMX_[A-Z0-9_]+)\b')

OPEN = 'QUANT_WINDOW'
CLOSE = 'GEMM_INT8_RESIDUAL'
HEADY = {'FFN', 'FFN_STEM', 'FFN_MERGE', 'WINDOW_BLOCK', 'UNARY2'}
PURE = {'QUANT_WINDOW', 'GEMM_INT8_QKV', 'WINDOW_ATTENTION', 'QUANT',
        'GEMM_WINDOW_INT8_RESIDUAL', 'GEMM_INT8_BATCHED', 'GEMM', 'GEMM_INT8',
        'GEMM_INT8_RESIDUAL'}
# M / C argument positions per op family (verified against the printed census)
MPOS = {'QUANT': 4, 'QUANT_WINDOW': 4, 'GEMM_INT8_QKV': 9, 'GEMM_WINDOW_INT8_RESIDUAL': 8,
        'GEMM_INT8_RESIDUAL': 8, 'GEMM_INT8_BATCHED': 6, 'GEMM': 4, 'GEMM_INT8': 6}
CPOS = {'QUANT': 5, 'QUANT_WINDOW': 5, 'GEMM_INT8_QKV': 10, 'GEMM_WINDOW_INT8_RESIDUAL': 9,
        'GEMM_INT8_RESIDUAL': 9, 'GEMM_INT8_BATCHED': 7, 'GEMM': 5, 'GEMM_INT8': 7}
# closure-level recorder names in libxmx_sycl.cpp (g_cmd_names / __func__)
CNAME = {k: 'xmx_rec_' + k.lower() for k in set(list(MPOS) + list(CPOS) + list(HEADY) +
                                                ['UNARY', 'WINDOW_ATTENTION',
                                                 'GLOBAL_ATTENTION'])}

def load():
    rows = []
    for i, line in enumerate(io.open(P, encoding='utf-8', errors='replace'), 1):
        if i < LO: continue
        if i > HI: break
        for m in pat.finditer(line):
            op = m.group(1)
            if op.startswith('OP_XMX_REC_'):
                nums = [int(x) for x in re.findall(r'\b\d+\b', line)]
                rows.append((i, op[len('OP_XMX_REC_'):], nums))
    return rows

def seg(rows):
    n = len(rows)
    chains = []           # dict(start, end, term)
    i = 0
    while i < n:
        if rows[i][1] == OPEN:
            a = i
            b = n - 1
            term = False
            for j in range(i, n):
                nm = rows[j][1]
                if j > i and (nm == OPEN or nm in HEADY):
                    b = j - 1
                    break
                if nm == CLOSE:
                    b = j
                    term = True
                    break
            chains.append({'start': a, 'end': b, 'term': term})
            i = b + 1
            continue
        i += 1
    return chains

def main():
    rows = load()
    if '--range' in sys.argv:
        k = sys.argv.index('--range')
        a = int(sys.argv[k + 1]); b = int(sys.argv[k + 2])
        for i in range(a, min(b + 1, len(rows))):
            print("%3d %-28s %s" % (i, rows[i][1], ','.join(str(x) for x in rows[i][2][:12])))
        return
    print("graph-region recorder ops:", len(rows))
    chains = seg(rows)
    print("chains (QUANT_WINDOW-anchored):", len(chains))
    out = []
    for k, c in enumerate(chains):
        a, b = c['start'], c['end']
        ops = [r[1] for r in rows[a:b + 1]]
        rw = rows[a]
        C = rw[2][CPOS['QUANT_WINDOW']] if len(rw[2]) > CPOS['QUANT_WINDOW'] else None
        M = rw[2][MPOS['QUANT_WINDOW']] if len(rw[2]) > MPOS['QUANT_WINDOW'] else None
        Ms = []
        for r in rows[a:b + 1]:
            p = MPOS.get(r[1])
            if p is not None and len(r[2]) > p:
                Ms.append(r[2][p])
        pure = all(o in PURE for o in ops)
        tier = {64: 'C64', 128: 'C128', 256: 'C256', 512: 'C512'}.get(C, 'C%s' % C)
        out.append(dict(chain=k, tier=tier, C=C, M_att=M, n_ops=b - a + 1,
                        closure_first=a, closure_last=b, plan_line=rw[0],
                        terminated=int(c['term']), pure=int(pure),
                        skippable=int(pure and c['term']),
                        Ms=','.join(str(x) for x in Ms),
                        op_seq=','.join(ops)))
    csvpath = sys.argv[sys.argv.index('--csv') + 1] if '--csv' in sys.argv else None
    if csvpath:
        with io.open(csvpath, 'w', encoding='utf-8', newline='') as f:
            w = csv.DictWriter(f, fieldnames=list(out[0].keys()))
            w.writeheader()
            for r in out:
                w.writerow(r)
        print("wrote", csvpath)
    if '--dump' in sys.argv or not csvpath:
        for r in out:
            print("chain %2d %-5s C=%-4s M=%6s  closures %3d..%3d (%2d)  term=%d pure=%d skip=%d"
                  % (r['chain'], r['tier'], r['C'], r['M_att'], r['closure_first'],
                     r['closure_last'], r['n_ops'], r['terminated'], r['pure'], r['skippable']))
    hist = Counter((r['tier'], r['n_ops'], r['skippable']) for r in out)
    for k in sorted(hist):
        print("tier/n_ops/skippable", k, "x", hist[k])
    inchain = sum(r['n_ops'] for r in out)
    print("ops inside chains: %d of %d (outside: %d -- stem/mega-block/ViT-bottleneck/head)"
          % (inchain, len(rows), len(rows) - inchain))
    kinds = Counter()
    covered = set()
    for r in out:
        covered.update(range(r['closure_first'], r['closure_last'] + 1))
    for i, rr in enumerate(rows):
        if i not in covered:
            kinds[rr[1]] += 1
    print("non-chain op kinds:", dict(kinds))

main()
