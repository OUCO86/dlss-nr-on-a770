import re, sys
# blockseq.py -- print the ORDER of per-frame recorder ops in the captured-graph region of
# plan_960x544.c so the S6 block chain is visible as a sequence (graph region only: steps 3915..5250).
P = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
lo, hi = 5308, 6643
pat = re.compile(r'\b(OP_XMX_[A-Z0-9_]+)\b')
rows = []
for i, line in enumerate(open(P, encoding='utf-8', errors='replace'), 1):
    if i < lo: continue
    if i > hi: break
    for m in pat.finditer(line):
        op = m.group(1)
        if op.startswith('OP_XMX_REC_'):
            nums = re.findall(r'\b\d+\b', line)
            rows.append((i, op, nums[:14]))
print("graph-region recorder ops:", len(rows))
start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
n = int(sys.argv[2]) if len(sys.argv) > 2 else 40
for (ln, op, args) in rows[start:start+n]:
    print(f"{ln:5d}  {op[8:]:32s}  {','.join(args)}")
