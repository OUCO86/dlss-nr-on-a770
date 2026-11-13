import sys, re, csv
sys.stdout.reconfigure(encoding='utf-8')

# C102: the block's floor analysis, per family, for the LIVE C512 chains (25/33).
# For each leg we take the plan's real operands and sizes, compute (a) the minimum BYTES it must
# move (operands read + result written, using the plan's OP_BUF element widths where the plane is
# the buffer itself) and (b) its FLOP count, then compare with the shipped-graph ABLATION price
# (family ms / launches, C97-C99) and with the per-closure ms from the ledger (labelled: the
# ledger is the SERIAL path, used here only to split a family across its legs, never as a price).
# Machine floors (hardware.md, measured on this A770):
DRAM = 291.1e9        # B/s
L2   = 854.6e9
INT8 = 201e12         # ops/s (2 x per FLOP -> 100.5 T MAC/s)
F16  = 100.6e12       # FLOP/s fp16
PLAN = r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c'
BUF = {}
for line in open(PLAN, encoding='utf-8', errors='replace'):
    m = re.search(r'\{\s*OP_BUF,\s*\d+,\s*\{\s*(\d+)\s*,\s*(\d+)', line)
    if m: BUF[int(m.group(1))] = int(m.group(2))

def perlaunch_bytes_read(ids, n_elems):
    # a leg reads at least the operand bytes it touches; for packed int8 A/B we size them by shape
    return sum(BUF.get(i, 0) for i in ids)

T, C, NH, heads = 64, 512, 1536, 16
M, Mp = 768, 768
rows = [
  # family, legs/frame(all tiers), ms/frame(ablation), shape-based min bytes per leg, flops per leg
  ('gemm_int8_qkv (qres)',  16, 3.49,
      M*C*1 + NH*C*1 + 3*M*C*2,                      2*M*NH*C),
  ('window_attention',      16, 3.86,
      3*M*C*2 + M*C*2 + (192*64*64*2)*2,             2*192*(64*64*32 + 64*32*64)),
  ('gemm_window_int8_res',  32, 1.78,
      M*C*1 + C*C*1 + M*C*2 + M*C*2,                 2*M*C*C),
  ('gemm_int8_residual',    32, 1.16,
      640*C*1 + C*C*1 + 640*C*2 + 640*C*2,           2*640*C*C),
  ('gemm_int8',             32, 0.34,
      640*C*1 + C*C*1 + 640*C*2,                     2*640*C*C),
  ('unary (whole family)',  32, 2.83,
      30566400*6//32,                                0),
]
print('%-24s %6s %9s %12s %10s %8s %8s' % ('family','legs/f','ms/frame','min B/leg','flop/leg','B floor','flop floor'))
for nm, legs, ms, byt, fl in rows:
    bf = byt / DRAM * 1e3
    ff = (fl / F16 * 1e3) if fl else 0.0
    perleg = ms / legs
    print('%-24s %6d %9.2f %12d %10d %8.4f %8.4f   leg=%.4f ms -> bytes %.0f%%  flop %.1f%% of its floor'
          % (nm, legs, ms, byt, fl, bf, ff, perleg,
             100.0 * bf / perleg if perleg else 0.0,
             100.0 * ff / perleg if (perleg and ff) else 0.0))
print()
print('NOTE: min B/leg counts the operand planes a leg must touch at least once (packed int8 A +')
print('      weights + f16 result + the residual skip plane where the family has one). It is a')
print('      LOWER bound, not a prediction. flop/leg uses the leg shape x2 (MAC->FLOP).')
print('      The ms/frame column is the SHIPPED-GRAPH ablation (C97-C99); legs/frame counts the')
print('      C512-tier legs only where the census gave them (unary counts all 32).')
