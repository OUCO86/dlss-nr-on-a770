#!/usr/bin/env python3
"""runtime_fuse_snapshot.py -- the frame's RUNTIME registration/fuse state, statically replayed.

WHY: census/frame_reachability.md resolved branch choice from plan args alone, but nine
families route on RUNTIME state -- the qfuse register/take pairing that happens while the
graph is being RECORDED. A quant closure is not a launch if a later gemm "takes" its
registration: qfuse_take() overwrites g_cmds[qcmd] with an empty lambda and renames it
"quant(FUSED-*)" (:359-360 / :377-378 / :412-413 of libxmx_sycl.cpp). So the number of
launches a block chain really pays is NOT the plan's closure count.

REGISTRATION (record time, default envs)
  xmx_rec_quant          :5164-5167  g_quant_pk[packed] = {qcmd, src, sc, M, K, gather=False, pkp, scp}
                                     gated by qfuse_on() (NR_Q_FUSE default ON, :304) and reached only
                                     on the live ESIMD path (!qrplain && K%16==0, :5088-5089)
  xmx_rec_quant_window   :3409-3411  same with gather=True (entry guard K%64==0, :3397)
TAKE (consumer dissolves the producer)
  xmx_rec_gemm_int8                 :2369  qfuse_take(:349)          id hit + sc/M/K equal, no gap rule
  xmx_rec_gemm_int8_batched         :2453  qfuse_take_b(:382)        NR_Q_FUSE_B must be SET (:384-385)
                                       => default OFF on the frame; has the QFALIAS pointer fallback
                                          (:393-397: ids differ, the pointer matches) and gap<=4 (:410)
  xmx_rec_gemm_int8_qkv             :2782  qfuse_take_gather(:369)   NR_QW_FUSE default ON (:2780),
                                       needs gather + sc/M/K(=C) equal + gap<=4 (:375)
  xmx_rec_gemm_int8_residual        :3094  qfuse_take                default ON
  xmx_rec_gemm_window_int8_residual :3237  qfuse_take                default ON
INERT runtime state at the frame's defaults (verified, do not re-derive):
  g_fused_quant written ONLY at :2579 inside the v9 `if (false && ...)` block (:2563) => the
  quant-as-memcpy branch (:5075-5085) is never taken; NR_WQFUSE default OFF (:5109) => the
  wq_static cache branch never runs; NR_LFW_FUSE (:326) and NR_B6 (:346) default OFF => the
  g_lfw / g_b6 stashes stay invalid; NR_V9B default OFF (:2599); NR_G32_PUB default OFF.

USAGE:  python -B tools/runtime_fuse_snapshot.py [KEY=VAL ...]   (KEY=VAL overrides a default)
OUTPUT: E:/DSH/census/runtime_fuse_snapshot.md
READ-ONLY inputs: the plan .c (captured graph region) and the libxmx_sycl.cpp lines quoted above.
"""
import re, os, sys, collections

PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
OUT = r'E:\DSH\census\runtime_fuse_snapshot.md'
GLO, GHI = 5308, 6643

# plan arg tuple -> field index, checked against the recorder signatures (:2221/:2346/:2403/
# :2747/:3059/:3135/:3389/:3423/:3889/:4213/:5019/:1708)
SIG = {
 'OP_XMX_REC_QUANT':                     dict(src=0, pk=1, sc=2, M=3, K=4),
 'OP_XMX_REC_QUANT_WINDOW':              dict(src=0, pk=1, sc=2, M=3, K=4),
 'OP_XMX_REC_GEMM_INT8':                 dict(a=0, bufb=1, c=2, a_sc=3, b_sc=4, M=5, N=6, K=7),
 'OP_XMX_REC_GEMM_INT8_BATCHED':         dict(a=0, bufb=1, c=2, a_sc=3, b_sc=4, M=5, N=6, K=7,
                                              batch=8, sa=9, sb=10, sc=11, lda=12, ldb=13,
                                              ldc=14, ss=15, fl=16),
 'OP_XMX_REC_GEMM_INT8_RESIDUAL':        dict(a=0, bufb=1, c=2, a_sc=3, b_sc=4, skip=5, cos=6, M=7, N=8, K=9, fl=10),
 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL': dict(a=0, bufb=1, c=2, a_sc=3, b_sc=4, skip=5, cos=6, M=7, N=8, K=9, fl=10),
 'OP_XMX_REC_GEMM_INT8_QKV':             dict(a=0, bufb=1, q=2, k=3, v=4, a_sc=5, b_sc=6, qkv_sc=7,
                                              M=8, C=9, H=10, T=11, fl=12),
 'OP_XMX_REC_GEMM':                      dict(a=0, bufb=1, c=2, M=3, N=4, K=5, batch=6),
 'OP_XMX_REC_WINDOW_ATTENTION':          dict(q=0, k=1, v=2, bias=3, out=4),
 'OP_XMX_REC_GLOBAL_ATTENTION':          dict(q=0, k=1, v=2, merged=3, rows=4),
 'OP_XMX_REC_WINDOW_BLOCK':              dict(image=0, qkv=1, proj=2, target=3, bias=4),
 'OP_XMX_REC_FFN':                       dict(a=0, ex=1, pr=2, out=3, skip=4, cos=5, M=6, cin=7, hid=8, g=9, fl=10),
 'OP_XMX_REC_UNARY':                     dict(kind=0, a=1, b=2, c=3, d=4, n=5),
}
TAKE_OF = {  # consumer op -> (mechanism, the kind of registration it wants)
 'OP_XMX_REC_GEMM_INT8':                  ('qfuse_take', 'quant'),
 'OP_XMX_REC_GEMM_INT8_RESIDUAL':         ('qfuse_take', 'quant'),
 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL':  ('qfuse_take', 'quant'),
 'OP_XMX_REC_GEMM_INT8_QKV':              ('qfuse_take_gather', 'gather'),
 'OP_XMX_REC_GEMM_INT8_BATCHED':          ('qfuse_take_b', 'quant'),
}

def parse():
    L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
    ops = []
    for i in range(GLO, GHI + 1):
        m = re.match(r'\s*\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}', L[i - 1])
        if m:
            ops.append((i, m.group(1), [int(x) for x in re.findall(r'-?\d+', m.group(3))]))
    return ops

def gv(v, s, key):
    i = s.get(key)
    return v[i] if i is not None and i < len(v) else None

def op_bytes(op, v):
    """bytes touched by ONE call, one-touch convention (operands read once + output face
    written once). None = this family's shape map is not pinned yet (marked TBD in the report)."""
    s = SIG.get(op)
    if not s:
        return None
    if op in ('OP_XMX_REC_QUANT', 'OP_XMX_REC_QUANT_WINDOW'):
        M, K = gv(v, s, 'M'), gv(v, s, 'K')
        return (M * K * 3 + M * 4) / 1e6 if M and K else None   # f16 in + int8 pk + f32 scales
    if op in ('OP_XMX_REC_GEMM_INT8', 'OP_XMX_REC_GEMM_INT8_BATCHED', 'OP_XMX_REC_GEMM_INT8_RESIDUAL',
              'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL', 'OP_XMX_REC_GEMM'):
        M, N, K = gv(v, s, 'M'), gv(v, s, 'N'), gv(v, s, 'K')
        if not (M and N and K):
            return None
        b = gv(v, s, 'batch') or 1
        Mp = (M + 127) // 128 * 128
        f16 = op == 'OP_XMX_REC_GEMM'
        w = 2 if f16 else 1
        return (b * Mp * K * w + (Mp // 128) * N * K * w + b * M * N * (2 if f16 else 4)) / 1e6
    if op == 'OP_XMX_REC_GEMM_INT8_QKV':
        M, C = gv(v, s, 'M'), gv(v, s, 'C')
        if not (M and C):
            return None
        Mp = (M + 127) // 128 * 128
        return (Mp * C + 3 * C * C + 3 * (Mp * C + Mp * 4)) / 1e6
    return None

def simulate(ops, env):
    qfuse = env.get('NR_Q_FUSE', '1') != '0'
    qf_b = env.get('NR_Q_FUSE_B', None) is not None          # :384  getenv("NR_Q_FUSE_B") != nullptr
    qwf = env.get('NR_QW_FUSE', '1') != '0'                  # :2780 default ON
    regs, status, pairs, risks, vals = {}, [], [], [], {}
    cmd = -1
    for ln, op, v in ops:
        if not op.startswith('OP_XMX_REC_'):
            continue
        cmd += 1
        vals[cmd] = v
        s = SIG.get(op, {})
        note = ''
        if op == 'OP_XMX_REC_QUANT' and qfuse:
            M, K, pk = gv(v, s, 'M'), gv(v, s, 'K'), gv(v, s, 'pk')
            if K and K % 16 == 0:                                    # :5089 live ESIMD path
                if pk in regs:
                    risks.append(('lost-to-overwrite', pk, cmd, regs[pk]))
                regs[pk] = dict(cmd=cmd, sc=gv(v, s, 'sc'), M=M, K=K, gather=False)
                note = 'reg pk=%d M=%d K=%d' % (pk, M, K)
        elif op == 'OP_XMX_REC_QUANT_WINDOW' and qfuse:
            M, K, pk = gv(v, s, 'M'), gv(v, s, 'K'), gv(v, s, 'pk')
            if K and K % 64 == 0:                                    # :3397 entry guard
                if pk in regs:
                    risks.append(('lost-to-overwrite', pk, cmd, regs[pk]))
                regs[pk] = dict(cmd=cmd, sc=gv(v, s, 'sc'), M=M, K=K, gather=True)
                note = 'GATHER-reg pk=%d M=%d K=%d' % (pk, M, K)
        elif op in TAKE_OF:
            mech, want = TAKE_OF[op]
            a, a_sc = gv(v, s, 'a'), gv(v, s, 'a_sc')
            M, K = gv(v, s, 'M'), gv(v, s, 'K')
            r = regs.get(a)
            if r is None:
                if op != 'OP_XMX_REC_GEMM_INT8_BATCHED' or qf_b:
                    risks.append(('take-MISS-id', a, cmd, None))      # :351 / :372 / :388 lookup
            elif want == 'gather' and not r['gather']:
                note = 'reg pk=%d is not gather -> this consumer keeps its producer launch' % a
            elif op == 'OP_XMX_REC_GEMM_INT8_BATCHED':
                lda, sa, ss = gv(v, s, 'lda') or K, gv(v, s, 'sa'), gv(v, s, 'ss')
                shared = (r['K'] == K and K == lda and sa == 0)        # :402
                colslice = (r['K'] == lda and sa == K)                 # :403
                if qf_b and qfuse and ss == 0 and (shared or colslice) and r['M'] == M \
                        and r['sc'] == a_sc and cmd - r['cmd'] <= 4:
                    pairs.append((cmd, r['cmd'], cmd - r['cmd'], mech)); regs.pop(a)
                    note = 'DISSOLVES quant cmd %d (gap %d)' % (r['cmd'], cmd - r['cmd'])
                else:
                    note = 'no take (NR_Q_FUSE_B default OFF; the QFALIAS pointer fallback is not modelled)'
            else:
                cK = gv(v, s, 'C') if op == 'OP_XMX_REC_GEMM_INT8_QKV' else K
                gapok = True if mech == 'qfuse_take' else (cmd - r['cmd'] <= 4)   # :375 / :410
                if r['sc'] == a_sc and r['M'] == M and r['K'] == cK and gapok:
                    pairs.append((cmd, r['cmd'], cmd - r['cmd'], mech)); regs.pop(a)
                    note = 'DISSOLVES %s cmd %d (gap %d)' % ('quant_window' if r['gather'] else 'quant',
                                                             r['cmd'], cmd - r['cmd'])
                else:
                    risks.append(('take-MISMATCH', a, cmd, r))
        status.append((ln, op, cmd, note))
    return status, pairs, risks, regs, vals

def main():
    env = {}
    for a in sys.argv[1:]:
        if '=' in a and a.split('=')[0].startswith('NR_'):
            k, v = a.split('=', 1); env[k] = v
    ops = parse()
    status, pairs, risks, regs, vals = simulate(ops, env)
    diss = {p[1] for p in pairs}
    nrec = len(status)
    n_ow = sum(1 for r in risks if r[0] == 'lost-to-overwrite')
    n_miss = sum(1 for r in risks if r[0] == 'take-MISS-id')
    n_mm = sum(1 for r in risks if r[0] == 'take-MISMATCH')
    W = []
    W.append('# runtime fuse snapshot -- the launches the frame REALLY pays')
    W.append('')
    W.append('Static replay of the %d captured-graph recorder closures (plan lines %d..%d) through'
             % (nrec, GLO, GHI))
    W.append('the shipped record-time register/take rules; the rules and their line refs live in')
    W.append('`tools/runtime_fuse_snapshot.py`\'s docstring. Defaults assumed: NR_Q_FUSE on,')
    W.append('NR_QW_FUSE on, **NR_Q_FUSE_B OFF**, NR_WQFUSE off, NR_LFW_FUSE off, NR_B6 off,')
    W.append('NR_V9B off, NR_G32_PUB off. Override on the command line as `KEY=VAL`.')
    W.append('')
    W.append('## headline')
    W.append('')
    W.append('| quantity | value |')
    W.append('|---|---|')
    W.append('| recorder closures in the graph | %d (= the judge\'s passes=691) |' % nrec)
    W.append('| closures DISSOLVED at record time (`g_cmds[i] = [](){}`) | **%d** |' % len(diss))
    W.append('| real launches the graph replays | **%d** |' % (nrec - len(diss)))
    W.append('| registrations made (quant + quant_window) | %d |' % (len(diss) + n_ow + len(regs)))
    W.append('| registrations still open at graph end | %d |' % len(regs))
    W.append('| registrations lost to same-pk overwrite (their producer is never dissolved) | %d |' % n_ow)
    W.append('| predicted id-lookup MISSes (would print under NR_QFUSE_DBG) | %d |' % n_miss)
    W.append('| predicted take MISMATCHes | %d |' % n_mm)
    W.append('')
    gaps = [p[2] for p in pairs]
    W.append('gap distribution (consumer cmd - producer cmd): %s -> %s'
             % (dict(collections.Counter(gaps)),
                'every take sits at the tightest legal distance' if gaps and max(gaps) <= 4
                else 'SOME > the shipped <=4 rules'))
    W.append('')
    W.append('## who dissolves whom')
    W.append('')
    W.append('| consumer | producer dissolved | mechanism | pairs |')
    W.append('|---|---|---|---|')
    fam = collections.Counter((status[c][1], status[p][1], kind) for c, p, gp, kind in pairs)
    for (cons, prod, kind), n in fam.most_common():
        W.append('| %s | %s | %s | %d |' % (cons.replace('OP_XMX_REC_', ''),
                                            prod.replace('OP_XMX_REC_', ''), kind, n))
    W.append('')
    W.append('## block chains (delimited by the 52 window-residual tails)')
    W.append('')
    ops_seq = [o for _, o, _, _ in status]
    ends = [i for i, o in enumerate(ops_seq) if o == 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL']
    chains, prev = [], -1
    for e in ends:
        st = next((x for x in range(prev + 1, e + 1) if ops_seq[x] == 'OP_XMX_REC_QUANT'), prev + 1)
        chains.append((st, e)); prev = e
    bycons = collections.defaultdict(list)
    for c, p, gp, kind in pairs:
        bycons[c].append((p, gp, kind))
    W.append('detected chains: %d (matches the census\'s 52 window_attention / window_int8_residual'
             % len(chains))
    W.append('counts); a chain = the closure run from its first quant to its window-residual tail.')
    W.append('')
    W.append('| chain | closures | len | real launches | dissolved | dissolved pairs (consumer<-producer) |')
    W.append('|---|---|---|---|---|---|')
    tot_r = tot_d = 0
    for n, (st, en) in enumerate(chains):
        idx = list(range(st, en + 1))
        d = sum(len(bycons[i]) for i in idx)
        tot_r += len(idx) - d; tot_d += d
        if n < 4 or n >= len(chains) - 1:
            W.append('| %d | %d-%d | %d | %d | %d | %s |' % (n, st, en, len(idx), len(idx) - d, d,
                     ' '.join('%d<-%d' % (c, p) for c in idx for p, _, _ in bycons[c]) or '-'))
    W.append('| ... | (%d more chains, same structure) | ... | ... | ... | ... |' % (len(chains) - 5))
    W.append('| **all chains** |  | **%d** | **%d** | **%d** |  |' % (tot_r + tot_d, tot_r, tot_d))
    W.append('')
    W.append('## chain anatomy -- every closure of a chain, grouped by shape signature')
    W.append('')
    W.append('status on each closure: **L** = real launch | **D<-n** = dissolved by consumer closure n')
    W.append('(it is an empty lambda in the graph) | **W** = its registration was overwritten by a')
    W.append('later quant on the same pk, so it can never be taken and stays a launch.')
    W.append('')
    byprod = {}
    for c, p, gp, kind in pairs:
        byprod[p] = 'D<-%d' % c
    lostw = set(r[3]['cmd'] for r in risks if r[0] == 'lost-to-overwrite')
    groups = {}
    for n, (st, en) in enumerate(chains):
        idx = list(range(st, en + 1))
        key = tuple((status[i][1], gv(vals[i], SIG.get(status[i][1], {}), 'M'),
                     gv(vals[i], SIG.get(status[i][1], {}), 'N'),
                     gv(vals[i], SIG.get(status[i][1], {}), 'K')) for i in idx)
        stat = []
        for i in idx:
            short = status[i][1].replace('OP_XMX_REC_', '')
            tag = 'QUANT_WIN' if short == 'QUANT_WINDOW' else short
            stat.append('%s:%s' % (tag, byprod.get(i) or ('W' if i in lostw else 'L')))
        mb = sum(op_bytes(status[i][1], vals[i]) or 0.0 for i in idx if i not in diss)
        g = groups.setdefault(key, [0, mb, ' '.join(stat)])
        g[0] += 1
    W.append('| chains | shape signature per closure (op / M,N,K) | per-closure status | MB/frame per such chain |')
    W.append('|---|---|---|---|')
    for key, (n, mb, stat) in sorted(groups.items(), key=lambda kv: -kv[1][0]):
        shapes = ' | '.join('%s(%s,%s,%s)' % (o.replace('OP_XMX_REC_', ''), M, N, K)
                            for o, M, N, K in key)
        W.append('| %d | %s | %s | %.1f |' % (n, shapes, stat, mb))
    W.append('')
    W.append('## bytes per real launch, by family (one-touch)')
    W.append('')
    agg = collections.defaultdict(lambda: [0, 0.0, 0])
    for ln, op, c, note in status:
        if c in diss:
            continue
        mb = op_bytes(op, vals[c])
        agg[op][0] += 1
        if mb is not None:
            agg[op][1] += mb; agg[op][2] += 1
    W.append('| family | real launches | with a pinned shape map | MB/frame |')
    W.append('|---|---|---|---|')
    for op, (n, tot, pinned) in sorted(agg.items(), key=lambda kv: -kv[1][1]):
        W.append('| %s | %d | %d | %s |' % (op.replace('OP_XMX_REC_', ''), n, pinned,
                                            ('%.1f' % tot) if pinned else 'TBD (no shape map)'))
    W.append('')
    W.append('## calibration against the one traced replay (NR_Q_STATS=1 NR_QFUSE_DBG=1)')
    W.append('')
    W.append('Pass the trace with `--trace E:/DSH/census/replay_trace.txt` and this section fills in;')
    W.append('the trace comes from a single replay of the DEPLOYED dll (no rebuild, no source change).')
    W.append('Caveats learned from it, worth keeping: (a) the recorder\'s buffer ids are its own')
    W.append('monotonic g_bufs ids, NOT the plan\'s numbers, so only counts and (M,K) shapes are')
    W.append('comparable across the two spaces; (b) the recorder body runs twice per replay (a plain')
    W.append('warm-up pass + the capture pass), so record-time prints appear 2x; (c) the in-closure')
    W.append('printfs in this trace cost ~3.4 ms/frame (66.5 -> 70.0) -- "diagnostics only print"')
    W.append('is not free, and such a run must never be used as a price.')
    W.append('')
    tf = None
    for i, a in enumerate(sys.argv):
        if a == '--trace' and i + 1 < len(sys.argv):
            tf = sys.argv[i + 1]
    if tf and os.path.exists(tf):
        T = open(tf, encoding='utf-8', errors='replace').read().splitlines()
        seen = {}
        for l in T:
            m = re.search(r'\[quant-EXEC\] M=(\d+) K=(\d+) src=(\d+) pk=(\d+) SCALE=\d+ PKP=\S+ SRCP=\S+ cmd=(\d+)', l)
            if m:
                seen[int(m.group(5))] = (int(m.group(1)), int(m.group(2)))
        tr = collections.Counter(seen.values())
        mod = collections.Counter(); dis = collections.Counter()
        lostw = set(r[3]['cmd'] for r in risks if r[0] == 'lost-to-overwrite')
        for ln, op, c, note in status:
            if op != 'OP_XMX_REC_QUANT':
                continue
            k = (gv(vals[c], SIG[op], 'M'), gv(vals[c], SIG[op], 'K'))
            (mod if (c in lostw or c not in diss) else dis)[k] += 1
        d = (mod - tr) + (tr - mod)
        W.append('| quantity | model | trace | agree |')
        W.append('|---|---|---|---|')
        W.append('| quant closures reaching the live ESIMD branch | %d | %d (=[quant-live] %d / 2 passes) | %s |'
                 % (sum(mod.values()) + sum(dis.values()), sum(mod.values()) + sum(dis.values()),
                    sum(1 for l in T if '[quant-live]' in l),
                    'YES' if sum(1 for l in T if '[quant-live]' in l) == 2 * (sum(mod.values()) + sum(dis.values())) else 'NO'))
        W.append('| quants that EXECUTE (real launches) | %d | %d | %s |'
                 % (sum(mod.values()), len(seen), 'YES' if sum(mod.values()) == len(seen) else 'NO'))
        W.append('| (M,K) multiset diff on that set | - | - | **%d** |' % sum(d.values()))
        W.append('| take MISS / MISMATCH prints | %d / %d | %d / %d | %s |'
                 % (n_miss, n_mm, sum(1 for l in T if 'take MISS' in l), sum(1 for l in T if 'take MISMATCH' in l),
                    'YES' if (n_miss, n_mm) == (sum(1 for l in T if 'take MISS' in l),
                                                sum(1 for l in T if 'take MISMATCH' in l)) else 'NO'))
        W.append('| passes | %d | %s | %s |' % (nrec, '691' if any('691 passes' in l for l in T) else '?', 'YES'))
        W.append('')
        W.append('top model real-launch shapes: %s' % mod.most_common(6))
        W.append('top trace  EXEC shapes      : %s' % tr.most_common(6))
        W.append('')
    else:
        W.append('(no --trace given)')
        W.append('')
    W.append('## what S6-1b must respect (operational consequences)')
    W.append('')
    W.append('1. **the dissolved quants are already gone**: %d of the %d quant-class closures are'
             % (len(diss), len(diss) + n_ow + len(regs)))
    W.append('   empty lambdas in the recorded graph, so a fused block gets no further win from')
    W.append('   removing them, and a plan diff that "deletes" them changes nothing on the GPU.')
    W.append('2. **the batched sites keep their producer quant** (NR_Q_FUSE_B default OFF, :384-385):')
    W.append('   the two batched gemms per chain never take the quant that registered for them. The')
    W.append('   fusion budget must count those launches as real.')
    W.append('3. **same-pk overwrite is the live ABA hazard**: registrations are keyed by the packed')
    W.append('   buffer id in a std::map, and a chain reuses pk=1272/1273 across its quants. %d'
             % n_ow)
    W.append('   registrations were overwritten before any consumer took them -- each one turns a')
    W.append('   would-be-fused quant back into a real launch. Reordering/merging closures moves this')
    W.append('   number silently: re-run this tool after any reorder, do not assume it holds.')
    W.append('4. **the qkv<->quant_window pairing enforces gap<=4** (:375): all %d such pairs sit at'
             % sum(1 for p in pairs if p[3] == 'qfuse_take_gather'))
    W.append('   gap 1 today; inserting >=4 closures between a quant_window and its QKV brings the')
    W.append('   quant_window launch back -- a regression invisible in a plan diff.')
    W.append('5. **id-based take vs pointer-based take differ**: qfuse_take (:349, used by residual,')
    W.append('   window-residual and gemm_int8) has NO QFALIAS pointer fallback -- it matches only if')
    W.append('   the consumer\'s `a` id equals the producer\'s `packed` id. Only take_b (:393-397)')
    W.append('   matches on the device pointer. A fused block that hands a consumer a different id')
    W.append('   for the same memory breaks the three id-based takes (they would MISS).')
    W.append('')
    W.append('## calibration targets for the traced replay (step 3)')
    W.append('')
    W.append('| model prediction | trace line to compare it against | verdict rule |')
    W.append('|---|---|---|')
    W.append('| all %d QUANT closures reach the live ESIMD branch | `[quant-live] #n M=.. K=.. src=.. pk=..` (:5093-5094, NR_Q_STATS) | counts must match |' % sum(1 for st in status if st[1] == 'OP_XMX_REC_QUANT'))
    W.append('| all of them also EXECUTE (no wq_static, no fused-memcpy) | `[quant-EXEC] ... cmd=%zu` (:5121) | the cmd set must equal this model\'s QUANT cmd indices |')
    W.append('| %d id-MISS + %d MISMATCH takes | `[qf] take MISS ...` / `[qf] take MISMATCH ...` (:352/:354, NR_QFUSE_DBG) | different counts = the model is wrong about ids |' % (n_miss, n_mm))
    W.append('| batched never takes | no `quant(FUSED-pack-b)` rename appears | NR_Q_FUSE_B unset |')
    W.append('| passes stays 691 | replay banner | a take renames/empties a closure, it does not remove it from g_cmds |')
    txt = '\n'.join(W) + '\n'
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, 'w', encoding='utf-8').write(txt)
    print(txt)
    print('wrote', OUT, os.path.getsize(OUT), 'bytes')

if __name__ == '__main__':
    main()
