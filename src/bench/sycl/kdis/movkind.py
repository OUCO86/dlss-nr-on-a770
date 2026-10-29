import re, sys, os
from collections import Counter

fn = sys.argv[1]
mov_kind = Counter()
stride_mov = 0
total = 0
arith_strided = 0
arith_plain = 0
peropcode_strided = Counter()
for line in open(fn, encoding='utf-8', errors='replace'):
    s = line.rstrip()
    st = s.strip()
    if not st or st.startswith('//'):
        continue
    # strip leading predicates/optional until opcode
    body = st
    while True:
        m = re.match(r'^\(([^)]*)\)\s+', body)
        if m:
            body = body[m.end():]
        else:
            break
    if not body or re.match(r'^L\d+:', body):
        continue
    toks = body.split()
    op = toks[0]
    total += 1
    # operand tokens start at toks[1] (mov: (8|M0) already stripped? no, (8|M0) is size|mask, part of opcode arg)
    # GEN line: opcode (N|Mx) dst src1 src2 ...
    # after predicate strip, toks[0]=op, toks[1]="(8|M0)" or "(1|M0)", then operands
    operands = [t for t in toks[2:]]
    # detect strided/replicated source: contains ';'
    srcs = operands[1:] if len(operands) > 1 else []
    has_strided_src = any(';' in o for o in srcs)
    if op == 'mov':
        if len(operands) >= 2:
            src = operands[1]
            if ';' in src:
                stride_mov += 1
                m2 = re.search(r'<(\d+);(\d+)', src)
                mov_kind[f'strided n={m2.group(1)} s={m2.group(2)}' if m2 else 'strided'] += 1
            elif src.startswith('acc0') or 'acc0' in src:
                mov_kind['acc0-readback'] += 1
            elif re.match(r'0x|^[\d.]+:|null', src):
                mov_kind['imm/null'] += 1
            else:
                mov_kind['plain r->r'] += 1
    if op in ('add','add3','mul','mad','mach','fma','and','or','xor','shl','shr','cmp','sel','bfn.0xFE','bfn.0xEA','bfn.0xD8','sub','not','addc','asr'):
        if has_strided_src:
            arith_strided += 1
            peropcode_strided[op] += 1
        else:
            arith_plain += 1
print(f'file={os.path.basename(fn)[:55]} total={total}')
print(f'mov: strided={stride_mov}  breakdown: ' + ', '.join(f'{k}={v}' for k,v in mov_kind.most_common(8)))
print(f'arith: strided-src={arith_strided} plain-src={arith_plain}  (strided-src = cross-lane move FUSED, costs no extra instr)')
print('  strided by op: ' + ', '.join(f'{k}={v}' for k,v in peropcode_strided.most_common(10)))
