import re, sys, glob, os
from collections import Counter

pat_pred = re.compile(r'^\((?:~?[a-z0-9_]+\.)?[a-z0-9_.]+\)\s+')
pat_opt = re.compile(r'^[A-Z]\)\s+')  # (W) prefix

def opcode_of(line):
    s = line.strip()
    if not s or s.startswith('//') or s.endswith(':') or s.startswith('L') and ':' in s[:12] and not s[:s.index(':')].strip().replace('_','').isalnum():
        pass
    # strip leading predicate "(f0.1) " / "(~f1.0.any16h) " / "(W) "
    while True:
        m = re.match(r'^\(([^)]*)\)\s+', s)
        if m and not m.group(1).startswith('W)'):
            s = s[m.end():]
            continue
        if s.startswith('(W) '):
            s = s[4:]
        break
    # label def like L440:
    if re.match(r'^L\d+:', s):
        return None
    tok = s.split()
    if not tok:
        return None
    op = tok[0]
    # send.slm etc keep dotted; strip trailing modifiers on msg ops
    return op

def hist(fn):
    c = Counter()
    n = 0
    for line in open(fn, encoding='utf-8', errors='replace'):
        line = line.rstrip()
        if line.startswith('        ') or line.lstrip().startswith('('):
            op = opcode_of(line)
            if op:
                c[op] += 1
                n += 1
    return c, n

fn = sys.argv[1]
c, n = hist(fn)
print(f"== {os.path.basename(fn)[:70]} total_instr={n}")
for op, k in c.most_common(40):
    print(f"  {k:7d}  {op}")
# grouped ledgers
mov = sum(k for op,k in c.items() if op in ('mov','mov.b16','mov.b8'))
sel = sum(k for op,k in c.items() if op.startswith('sel') or op.startswith('cbit'))
slm_ld = sum(k for op,k in c.items() if 'slm' in op and ('ld' in op.lower() or 'read' in op.lower()))
arith = sum(k for op,k in c.items() if op in ('add','add3','mul','mad','mach','fma','shl','shr','and','or','xor','not','bfn.0xFE','bfn.0xD8','bfn.0xE4','cmp','sub'))
print(f"  -- ledger: mov={mov} sel/cbit={sel} arith={arith} dpas={c.get('dpas',0)} send.slm={c.get('send.slm',0)} send.ugm={c.get('send.ugm',0)} send.gtwy={c.get('send.gtwy',0)} goto={c.get('goto',0)}")
