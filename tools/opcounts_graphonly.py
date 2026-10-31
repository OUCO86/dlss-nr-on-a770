#!/usr/bin/env python3
"""opcounts_graphonly.py -- REAL per-frame op counts, captured-graph region ONLY.

WHY THIS EXISTS (2026-11-01): the per-frame call counts floating in the notes
(bench_n32.cpp:2 "x16 + x24 = 40 calls", DS-takeover-2026-11-01.md:105) are a SYSTEMATIC
2x overcount: plan_960x544.c contains TWO recordings of the same frame --
  * the ABORTED scratch recording, plan lines 3922..5294 (steps 2529..3901), and
  * the CAPTURED graph, plan lines 5308..6643 (steps 3915..5250),
and only the captured graph is what xmx_graph_run replays every frame (knife-B census,
section 0: "the same op mix, which is a parse cross-check, not a second frame"). Counting
both doubles every number. This script counts the captured region only, and cross-checks
the total against the judge's `passes=691`.

Reproduce:  python -B tools/opcounts_graphonly.py        (pure stdlib, read-only inputs)
Output:     E:/DSH/census/opcounts_graphonly.txt

Inputs (read-only):
  plan   : E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/work/plan_960x544.c
           names 1277-1331, signatures 1335-1389, steps 1393-6646, buffers 6651-7952
  branch : E:/DSH/dlss-nr-on-a770/src/bench/sycl/libxmx_sycl.cpp (recorder dispatch guards)
"""
import re, sys, collections, os

PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
OUT  = r'E:\DSH\census\opcounts_graphonly.txt'
GLO, GHI = 5308, 6643          # the captured graph = what is replayed per frame
SLO, SHI = 3922, 5294          # the aborted scratch recording = NOT replayed (cross-check only)

# OP_XMX_REC_* -> recorder entry point (the f_rec_* translation in src/gpu/nr_replay.c,
# as tabulated by tools/knifeB_census.py).
REC = {
 'OP_XMX_REC_GEMM':                 'xmx_rec_gemm (f16-in gemm family; blade-5 fold :2303)',
 'OP_XMX_REC_GEMM_INT8':            'xmx_rec_gemm_int8',
 'OP_XMX_REC_GEMM_INT8_BATCHED':    'xmx_rec_gemm_int8_batched',
 'OP_XMX_REC_GEMM_INT8_RESIDUAL':   'xmx_rec_gemm_int8_residual',
 'OP_XMX_REC_GEMM_INT8_QKV':        'xmx_rec_gemm_int8_qkv',
 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL': 'xmx_rec_gemm_window_int8_residual',
 'OP_XMX_REC_QUANT':                'xmx_rec_quant',
 'OP_XMX_REC_QUANT_WINDOW':         'xmx_rec_quant_window',
 'OP_XMX_REC_UNARY':                'xmx_rec_unary',
 'OP_XMX_REC_UNARY2':               'xmx_rec_unary2',
 'OP_XMX_REC_WINDOW_BLOCK':         'xmx_rec_window_block',
 'OP_XMX_REC_WINDOW_ATTENTION':     'xmx_rec_window_attention',
 'OP_XMX_REC_GLOBAL_ATTENTION':     'xmx_rec_global_attention',
 'OP_XMX_REC_FFN':                  'xmx_rec_ffn',
 'OP_XMX_REC_FFN_STEM':             'xmx_rec_ffn_stem',
 'OP_XMX_REC_FFN_MERGE':            'xmx_rec_ffn_merge',
}
# arg tuples: which positions are (M,N,K,batch) for the gemm-class ops (from the signatures
# at plan lines 1335-1389; same order knifeB_census uses).
# arg positions (0-based) of (M,N,K,batch) per recorder signature in libxmx_sycl.cpp:
#   xmx_rec_gemm_int8_batched  (a,b,c,a_scale,b_scale, M,N,K,batch, sa,sb,sc,lda,ldb,ldc,ss,flags)  :2403
#   xmx_rec_gemm               (a,b,c, M,N,K,batch, sa,sb,sc,bt,lda,ldb,ldc,oa,ob,oc)               :2221
#   xmx_rec_gemm_int8          (a,b,c,a_scale,b_scale, M,N,K,flags)                                 :2338
#   xmx_rec_gemm_int8_residual (a,b,c,a_scale,b_scale,skip,cosine, M,N,K,flags)                     :3032
#   xmx_rec_gemm_window_int8_residual (same prefix)                                                 :3108
#   xmx_rec_gemm_int8_qkv      (a,b,q,k,v,a_scale,b_scale,qkv_scale, M,channels,heads,tokens,flags)  :2720
GEMMSHAPE = {
 'OP_XMX_REC_GEMM_INT8_BATCHED': (5, 6, 7, 8),
 'OP_XMX_REC_GEMM_INT8':         (5, 6, 7, None),
 'OP_XMX_REC_GEMM_INT8_RESIDUAL':(7, 8, 9, None),
 'OP_XMX_REC_GEMM':              (3, 4, 5, 6),
 'OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL': (7, 8, 9, None),
}
QKV = 'OP_XMX_REC_GEMM_INT8_QKV'

def scan(lo, hi):
    L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
    cnt = collections.Counter(); shapes = collections.defaultdict(collections.Counter)
    args = collections.defaultdict(list)
    for i in range(lo, hi + 1):
        m = re.match(r'\s*\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{([^}]*)\}', L[i - 1])
        if not m: continue
        op, nargs, body = m.group(1), int(m.group(2)), m.group(3)
        vals = [int(x) for x in re.findall(r'-?\d+', body)]
        cnt[op] += 1
        if op in GEMMSHAPE:
            p = GEMMSHAPE[op]
            M, N, K = vals[p[0]], vals[p[1]], vals[p[2]]
            b = vals[p[3]] if p[3] is not None and p[3] < len(vals) else 1
            shapes[op][(M, N, K, b)] += 1
            args[op].append((i, vals))
        elif op == QKV:
            # (M, channels, heads, tokens) -- the qkv epilogue family, no plain N/K
            shapes[op][(vals[8], vals[9], vals[10], vals[11])] += 1
            args[op].append((i, vals))
    return cnt, shapes, args

def main():
    g_cnt, g_shapes, g_args = scan(GLO, GHI)
    s_cnt, _, _ = scan(SLO, SHI)
    L = open(PLAN, encoding='utf-8', errors='replace').read().splitlines()
    out = []
    W = out.append
    W('opcounts_graphonly.txt -- per-frame op counts, CAPTURED GRAPH region only')
    W('plan_960x544.c lines %d..%d (steps 3915..5250). The aborted recording (lines %d..%d,'
      % (GLO, GHI, SLO, SHI))
    W('steps 2529..3901) holds the SAME op mix and is NOT replayed -- any count that sums')
    W('both is 2x too high (this is the correction to bench_n32.cpp:2 "x16+x24=40 calls").')
    W('')
    rec_total = sum(v for k, v in g_cnt.items() if k in REC)
    W('CROSS-CHECK: sum of OP_XMX_REC_* in the graph region = %d  (the judge reports passes=691)'
      % rec_total)
    W('             same scan over the aborted region            = %d'
      % sum(v for k, v in s_cnt.items() if k in REC))
    W('')
    W('%-42s %8s %8s   recorder / what it launches today' % ('OP', 'graph', 'scratch'))
    W('-' * 118)
    for k, v in sorted(g_cnt.items(), key=lambda x: -x[1]):
        W('%-42s %8d %8s   %s' % (k, v, s_cnt.get(k, 0), REC.get(k, '(init/declaration pseudo-op, no launch)')))
    W('')
    W('=== gemm-class shape breakdown (graph region only) ===')
    for op in sorted(g_shapes, key=lambda o: -sum(g_shapes[o].values())):
        if op == QKV: continue
        W('')
        W('%s  -> %s' % (op, REC[op]))
        W('   %-34s %6s %10s %10s %10s %10s' % ('(M,N,K,batch)', 'calls', 'A MB', 'B MB', 'C32 MB', 'frame MB'))
        tot_mb = 0
        for (M, N, K, b), c in sorted(g_shapes[op].items(), key=lambda x: -x[1]):
            aMB = b * M * K / 1e6; bMB = b * N * K / 1e6; cMB = b * M * N * 4 / 1e6
            frame = c * (aMB + bMB + cMB); tot_mb += frame
            W('   %-34s %6d %10.2f %10.2f %10.2f %10.2f' % ('(%d,%d,%d,%d)' % (M, N, K, b), c, aMB, bMB, cMB, frame))
        W('   family total (A+B+C32 once each, excl. pack re-reads / publish / quant): %.1f MB/frame' % tot_mb)
    W('')
    W('%s -> %s   (no plain N/K: the qkv epilogue takes M, channels, heads, tokens)' % (QKV, REC[QKV]))
    W('   %-40s %6s' % ('(M,channels,heads,tokens)', 'calls'))
    for tup, c in sorted(g_shapes[QKV].items(), key=lambda x: -x[1]):
        W('   %-40s %6d' % (str(tup), c))
    W('')
    W('=== the N=32 batched sites (the 刀 C target) ===')
    for (M, N, K, b), c in sorted(g_shapes['OP_XMX_REC_GEMM_INT8_BATCHED'].items()):
        br = 'fused pub (N%64==0 branch, libxmx_sycl.cpp:2660)' if N % 64 == 0 else \
             'SPLIT: gemm32_b + separate publish (:2680/:2682)'
        W('   M=%-7d N=%-4d K=%-4d batch=%-2d  x%-3d  %s' % (M, N, K, b, c, br))
    W('')
    W('=== quant-class (knife B) ===')
    W('   xmx_rec_quant %d + xmx_rec_quant_window %d = %d quant-class launches/frame'
      % (g_cnt['OP_XMX_REC_QUANT'], g_cnt['OP_XMX_REC_QUANT_WINDOW'],
         g_cnt['OP_XMX_REC_QUANT'] + g_cnt['OP_XMX_REC_QUANT_WINDOW']))
    W('   (OP_XMX_QUANT_INIT %d is the declaration pseudo-op, not a launch)'
      % g_cnt['OP_XMX_QUANT_INIT'])
    txt = '\n'.join(out)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, 'w', encoding='utf-8').write(txt + '\n')
    print(txt)
    print('\nwrote', OUT, os.path.getsize(OUT), 'bytes')

if __name__ == '__main__':
    main()
