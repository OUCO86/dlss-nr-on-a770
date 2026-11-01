#!/usr/bin/env python3
"""frame_reachability.py -- which shipped CODE PATH each frame closure actually takes.

WHY (2026-11-01, three self-falsifications in one night): the RUN_TIMING serial table
(window_block 19.9 | batched 18.5 | res 18.0 | wa 17.0 | qkv 14.8 | wres 13.4 | ga 12.0 |
gemm(f16) 11.0 | quant 10.3 | ffn 6.1 | gemm_int8 5.3 | merge 4.0 | unary 2.8 | stem 1.8,
serial 154 / frame 66) is ground truth for what the FRAME pays, but every time we priced a
knife from a BENCH family price we used a branch the frame may not execute. Confirmed cases:
  * the N=32 batched sites: bench-priced gemm32_b + separate publish = 7.17 ms/frame serial,
    but the frame folds them through P8-b wide-merge (:2478-2503, DEFAULT ON) -> the split
    path is DEAD CODE there (probe print fired 0 times in a full replay);
  * blade-5's f16 fold and the v9/v9b int8 folds are separate branches again.
This script evaluates the shipped branch guards against the plan's own arg tuples for the
CAPTURED graph (the region xmx_graph_run replays) and prints, per family: the branch taken,
calls, per-call bytes, and the DEAD branches with the prices that must be voided.

Read-only inputs:
  plan : E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/work/plan_960x544.c (lines 5308..6643)
  code : E:/DSH/dlss-nr-on-a770/src/bench/sycl/libxmx_sycl.cpp (guard line numbers cited)
Output : E:/DSH/census/frame_reachability.md
Usage  : python -B tools/frame_reachability.py
"""
import re, collections, os

PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
OUT  = r'E:\DSH\census\frame_reachability.md'
GLO, GHI = 5308, 6643

# ---- arg layouts (recorder signatures in libxmx_sycl.cpp) ----
ARGS = {
 'OP_XMX_REC_GEMM_INT8_BATCHED': ('a b c a_scale b_scale M N K batch sa sb sc lda ldb ldc ss flags'.split(), 2403),
 'OP_XMX_REC_GEMM_INT8':         ('a b c a_scale b_scale M N K flags'.split(), 2346),
 'OP_XMX_REC_GEMM':              ('a b c M N K batch sa sb sc bt lda ldb ldc oa ob oc'.split(), 2221),
 'OP_XMX_REC_GEMM_INT8_RESIDUAL':('a b c a_scale b_scale skip cosine M N K flags'.split(), 3059),
 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL': ('a b c a_scale b_scale skip cosine M N K flags height width across'.split(), 3135),
 'OP_XMX_REC_GEMM_INT8_QKV':     ('a b q k v a_scale b_scale qkv_scale M channels heads tokens flags'.split(), 2747),
 'OP_XMX_REC_QUANT':             ('c pk scale source rows cols flags'.split(), 5019),
 'OP_XMX_REC_QUANT_WINDOW':      ('c pk scale source rows cols flags'.split(), 3389),
}

def load():
    L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
    ops = []
    for i in range(GLO, GHI + 1):
        m = re.match(r'\s*\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}', L[i - 1])
        if not m:
            continue
        op, body = m.group(1), m.group(3)
        vals = [int(x) for x in re.findall(r'-?\d+', body)]
        names = ARGS.get(op)
        d = {}
        if names:
            for j, nm in enumerate(names[0]):
                if j < len(vals):
                    d[nm] = vals[j]
        ops.append((i, op, d, vals))
    return ops

def epi_narrow(flags):
    return ((flags >> 8) & 0xF, (flags >> 12) & 1) if flags is not None else (None, None)

# ---- the batched family: exact replica of the shipped guards ----
def batched_branch(o):
    M, N, K, b = o['M'], o['N'], o['K'], o['batch']
    sa, sb, sc = o['sa'], o['sb'], o['sc']
    lda, ldb, ldc = o['lda'], o['ldb'], o['ldc']
    ss, flags = o['ss'], o['flags']
    epi, narrow = epi_narrow(flags)
    lda_e = lda or K
    ldb_e = ldb or K
    # v9 (:2563) is `if (false && ...)` -> DEAD BY CONSTRUCTION
    # v9b (:2600) NR_V9B default OFF -> dead at default env
    # P8-b wide-merge :2479-2483 (NR_B_WIDE default ON)
    wide = (N == 32 and b >= 2 and N * b <= 128 and sc == N and ldc == N * b and sa == K
            and lda_e == K * b and sb == N * K and ss == 0 and epi in (0, 1, 4) and narrow and K % 32 == 0)
    if wide:
        return ('WIDE-MERGE :2484 -> gemm_b_pub(Nw=%d,Kw=%d,batch=1)+fused pub' % (N * b, K * b),
                dict(M=M, N=N * b, K=K * b, batch=1))
    if N % 64 == 0 and epi in (0, 1, 3, 4):
        k = 'pub_slm (N==128, NR_PUB_SLM default ON) :2669' if N == 128 else 'gemm_b_pub :2673'
        return (k, dict(M=M, N=N, K=K, batch=b))
    if N % 32 == 0 and epi in (0, 1, 3, 4):
        return ('NR_G32_PUB branch :2693 (DEFAULT OFF -> not taken)', dict(M=M, N=N, K=K, batch=b))
    return ('SPLIT :2700 gemm32_b/gemm_b + separate publish :2702', dict(M=M, N=N, K=K, batch=b))

def f16_branch(o):
    N, K, bt, flags = o['N'], o['K'], o['bt'], None
    compact = (bt & 0x10000) != 0
    # :2303 if (gfold && gst == 0 && !compact)  -- gfold default ON, gst default 0
    if not compact:
        return ('FOLD :2304 gemm_b_pub_f16 (blade-5, default ON)', o)
    return ('SPLIT :2311/2316 f16 gemm + separate publish (compact head only)', o)

def mb(sh, per_elem_note=''):
    """bytes of one call of a gemm shape: A (int8) + B (int8) + C32 (int32)."""
    M, N, K, b = sh['M'], sh['N'], sh['K'], sh.get('batch', 1)
    return (b * M * K + b * N * K + b * M * N * 4) / 1e6

def main():
    ops = load()
    rec = [o for o in ops if o[1].startswith('OP_XMX_REC_')]
    W = []
    W.append('# frame reachability -- which shipped branch each frame closure actually takes')
    W.append('')
    W.append('Generated by `tools/frame_reachability.py` (read-only: plan + libxmx_sycl.cpp).')
    W.append('Region = the CAPTURED graph, plan_960x544.c lines %d..%d = the %d recorder closures'
             % (GLO, GHI, len(rec)))
    W.append('that `xmx_graph_run` replays per frame (cross-check: the judge prints passes=691).')
    W.append('The aborted recording (plan lines 3922..5294) is NOT replayed; any count that')
    W.append('includes it is 2x too high (see census/opcounts_graphonly.txt).')
    W.append('')
    # ---- batched family ----
    cnt = collections.Counter(); shapes = collections.defaultdict(list)
    for ln, op, o, vals in rec:
        if op != 'OP_XMX_REC_GEMM_INT8_BATCHED':
            continue
        br, sh = batched_branch(o)
        cnt[br] += 1
        shapes[br].append(mb(sh))
    W.append('## xmx_rec_gemm_int8_batched (72 calls/frame) -- branch actually taken')
    W.append('')
    W.append('| branch (guard line) | calls | MB/call (A+B+C32, one touch) | calls x MB |')
    W.append('|---|---|---|---|')
    for br, c in cnt.most_common():
        mbs = shapes[br]
        W.append('| %s | %d | %s | %.1f |' % (br, c, '%.1f-%.1f' % (min(mbs), max(mbs)) if len(set(map(round, mbs))) > 1 else '%.1f' % mbs[0], sum(mbs)))
    W.append('')
    W.append('DEAD branches in this family at the frame (default envs):')
    W.append('')
    W.append('| dead branch | guard | why dead | price that must NOT be booked |')
    W.append('|---|---|---|---|')
    W.append('| split chain: gemm32_b + SEPARATE scalar publish | :2700/:2702-2716 | all 20 N=32 calls are caught by wide_ok (:2479-2483) first (20/20, 0 missed); probe print in the split/fused branch fired 0 times in a full replay | 7.17 ms/frame serial (gemm 1.61 + publish 5.66) -- the number this knife-line used before the probe |')
    W.append('| v9 int8->int8+scale fold | :2563 | literally `if (false && ...)` (blocked by multi-group interleaved row-max, :2556-2562) | (its own bench prices) |')
    W.append('| v9b wide fold | :2600 | NR_V9B default OFF (shelved, section 99) | -6 ms claim from section 99 stays void |')
    W.append('| NR_G32_PUB branch (knife C) | :2693 | default OFF AND unreachable while NR_B_WIDE is ON (wide_ok returns first); live only as the NR_B_WIDE=0 escape | 0 |')
    W.append('| NR_B_STOP / NR_G_STOP ladders | :2466/:2675 | diagnostic only, default 0 | never a saving |')
    W.append('')
    W.append('Measured prices for the two N=32 shapes, SAME process/protocol (bench, 8 procs pooled,')
    W.append('msM = median of five 15-rep group-mins; `gemm32_tile_run.txt`):')
    W.append('')
    W.append('| path | (32640,32,128,b2) | (8160,32,128,b4) | 20 calls/frame serial |')
    W.append('|---|---|---|---|')
    W.append('| WIDE-MERGE gemm_b_pub (what the frame runs today) | 0.1185 | 0.1001 | %.2f ms |' % (0.1185 * 8 + 0.1001 * 12))
    W.append('| BN32 fused gemm32_b_pub (knife C/C-prime form) | 0.0701 | 0.0447 | %.2f ms |' % (0.0701 * 8 + 0.0447 * 12))
    W.append('| SPLIT gemm32_b + separate publish (dead on frame) | 0.4868 | 0.2756 | %.2f ms |' % (0.4868 * 8 + 0.2756 * 12))
    W.append('')
    W.append('=> the honest serial delta of knife C-prime on these 20 sites is **%.2f ms** (wide -> BN32'
             % ((0.0701 * 8 + 0.0447 * 12) - (0.1185 * 8 + 0.1001 * 12)))
    W.append('   fused), NOT the 6.1 ms the split-path prices suggested. Frame A/B (ab.ps1, 48 pairs,')
    W.append('   A = deployed dll default wide, B = new dll NR_B_WIDE=0 NR_G32_PUB=1): mean -0.466 ms,')
    W.append('   median -0.685, sd 1.479, 95%% CI [-0.89, -0.04], B faster in 31/48 pairs -> the effect')
    W.append('   is real in direction and sits ON the -0.5 promotion bar, not past it.')
    W.append('')
    # ---- f16 gemm ----
    c2 = collections.Counter()
    for ln, op, o, vals in rec:
        if op != 'OP_XMX_REC_GEMM':
            continue
        c2[f16_branch(o)[0]] += 1
    W.append('## xmx_rec_gemm (f16-in family, 42 calls/frame)')
    for k, v in c2.most_common():
        W.append('- %s : **%d** calls' % (k, v))
    W.append('')
    # ---- entry-guard violations: does any frame call trip a FAILMSG guard? ----
    W.append('## entry-guard audit (a violation would mean a live FAILMSG in the frame)')
    viol = []
    for ln, op, o, vals in rec:
        M, N, K = o.get('M'), o.get('N'), o.get('K')
        if op in ('OP_XMX_REC_GEMM_INT8', 'OP_XMX_REC_GEMM_INT8_RESIDUAL',
                  'OP_XMX_REC_GEMM_INT8_QKV', 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL') and None not in (N, K):
            if (N % 64) or (K % 32):
                viol.append((ln, op, M, N, K))
        if op == 'OP_XMX_REC_GEMM_INT8_BATCHED' and None not in (N, K):
            if (N % 32) or (K % 32):
                viol.append((ln, op, M, N, K))
        if op == 'OP_XMX_REC_GEMM' and None not in (N, K):
            if (N % 16) or (K % 16):
                viol.append((ln, op, M, N, K))
    W.append('')
    W.append('violations found: %d%s' % (len(viol), '' if not viol else ' -> ' + str(viol[:6])))
    W.append('')
    # ---- families not statically evaluable ----
    W.append('## families whose branch depends on RUNTIME state (buffer flags / caches), not plan args')
    W.append('These still need the same treatment; listed with their guard lines so the next pass can')
    W.append('encode them (guessing here would be exactly the error this census exists to prevent):')
    W.append('')
    W.append('| family | calls | guards to evaluate | runtime inputs needed |')
    W.append('|---|---|---|---|')
    W.append('| xmx_rec_quant | 224 | :5087 qrplain+K%16, :5120 wq_static, :5162 qfuse_on() | buffer generation numbers (genof), NR_Q_FUSE default ON |')
    W.append('| xmx_rec_quant_window | 52 | (no branch ifs in 3389..3423) | - |')
    W.append('| xmx_rec_gemm_int8_qkv | 60 | :2817 fused_q, :2842 qres_ok, :2855 vit=false | which quant registered a fuse |')
    W.append('| xmx_rec_gemm_window_int8_residual | 52 | :3207 B.S.fq, :3263 wrstop | fuse registration per buffer |')
    W.append('| xmx_rec_window_block | 10 | :4229 pooling, :4306/:4331 v4 routes, NR_WB_* | head/pooling flags from plan `pad`/across |')
    W.append('| xmx_rec_window_attention | 52 | :3921 lfw_pair&&b6_on, :3940 S.fq, :3983/:3997 wa_raw/rawv2 | g_lfw state, fuse flags |')
    W.append('| xmx_rec_global_attention | 8 | :3337 gat, :3362 gam (rows%16, Mp==rows) | env defaults of gat/gam |')
    W.append('| xmx_rec_ffn / ffn_stem / ffn_merge | 8+1+1 | :1763 ffntile&&ffchip&&hidden==128&&cin==32&&!narrow&&epi==0 | plan flags per call |')
    W.append('| xmx_rec_unary / unary2 | 16+1 | :3457/:3487/:3534/:3576 uvec..uvec4 + shape tests | env defaults |')
    W.append('')
    W.append('## what to do with the 154 ms serial table')
    W.append('RUN_TIMING itself is ground truth (it waits per closure), so the 154 ms total is what the')
    W.append('frame really executes -- the corrections above apply to BENCH-DERIVED predictions, not to')
    W.append('the table. Concretely: the batched 18.5 ms row already contains the WIDE path (~2.15 ms')
    W.append('for these 20 sites), never the 7.17 ms split figure. Any knife priced off a dead branch')
    W.append('is worth zero, and the three-way check for a knife is now: (1) probe/arg-substitution that')
    W.append('the branch is reachable, (2) bench price, (3) frame A/B with the env set on ONE side only.')
    txt = '\n'.join(W) + '\n'
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, 'w', encoding='utf-8').write(txt)
    print(txt)
    print('wrote', OUT, os.path.getsize(OUT), 'bytes')

if __name__ == '__main__':
    main()
