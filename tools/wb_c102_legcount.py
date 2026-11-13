import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8')
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
pat = re.compile(r'\{\s*(OP_XMX_REC_[A-Z0-9_]+),\s*\d+,\s*\{')
cnt = collections.Counter()
for line in open(PLAN, encoding='utf-8', errors='replace'):
    m = pat.search(line)
    if m:
        cnt[m.group(1).replace('OP_XMX_REC_', '')] += 1
for k in ('WINDOW_ATTENTION', 'GEMM_INT8_QKV', 'GEMM_INT8', 'GEMM_INT8_RESIDUAL',
          'GEMM_INT8_BATCHED', 'GEMM_WINDOW_INT8_RESIDUAL', 'UNARY', 'QUANT', 'QUANT_WINDOW', 'GEMM'):
    print('%-28s %4d steps in the plan (= launches/frame)' % (k, cnt.get(k, 0)))
