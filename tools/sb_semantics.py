#!/usr/bin/env python3
# E:\DSH\tools\sb_semantics.py -- DECISIVE test of what $k.src / $k.dst means.
# For every scoreboard wait annotation `$k.X` we know the send that opened $k:
#   send line:  send.<t> (sz|pr) <dstreg> <addreg> <hdr> <imm> <desc> {..$k..}
#               // wr:.., rd:<N>   -> the send's DESTINATION range is
#               [<dstreg>, <dstreg>+N)  (rd:N == number of GRFs written back)
#               and its ADDRESS (source) register is <addreg>.
# Then for the waiting line we ask, mechanically:
#   reads_dst  : some SOURCE operand of this line lies in the send's dst range
#                -> the line consumes the loaded DATA  (RAW = real latency stall)
#   writes_dst : this line's DESTINATION operand lies in that range
#                -> WAW/output ordering on the same GRF (register reuse)
#   writes_addr: this line's DESTINATION operand == the send's address register
#                -> the pointer register is being recycled (not data)
# The cross-tab of X vs. these three tells us which suffix means what.
import io, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

SEND   = re.compile(r'^\s*(?:\([^\)]*\)\s*)?(send[a-zA-Z0-9_.]*|dpas[a-zA-Z0-9_.]*)\b(.*)$')
ANN    = re.compile(r'\{([^}]*)\}')
RD     = re.compile(r'read\b|rd:\s*(\d+)')
RREG   = re.compile(r'\b(r|acc|a)(\d+)')
RDCNT  = re.compile(r'rd:\s*(\d+)')

def operands(code):
    """return (dst_regs, src_regs) as sets of GRF numbers, best-effort"""
    toks = code.split()
    # drop mnemonic + exec-size/predicate groups
    i = 0
    while i < len(toks) and (not re.match(r'^[a-z]', toks[i])): i += 1
    if i < len(toks): i += 1                      # mnemonic
    regs = []
    while i < len(toks):
        t = toks[i]
        if t.startswith('{'): break
        m = re.match(r'^(r|acc|a)(\d+)', t)
        if m: regs.append((m.group(1), int(m.group(2))))
        i += 1
    if not regs: return set(), set()
    dst = {r for k, r in regs if k == 'r'}
    dst = {regs[0][1]} if regs[0][0] == 'r' else set()
    src = {r for _, r in regs[1:]}
    return dst, src

def main():
    path = sys.argv[1]
    lines = io.open(path, encoding='utf-8', errors='replace').read().splitlines()
    send = {}                       # sb -> (line, mnem, dstbase, nregs, addreg)
    tab = collections.Counter()
    rows = []
    for i, ln in enumerate(lines):
        code_all = ln.split('//')[0]
        cmt = ln.split('//')[1] if '//' in ln else ''
        stripped = ANN.sub(' ', code_all)
        m = SEND.match(ln)
        if m:
            mnem = m.group(1)
            tail = m.group(2)
            tcode = ANN.sub(' ', tail.split('//')[0])
            mm = RDCNT.search(cmt)
            n = int(mm.group(1)) if mm else 0
            toks = [t for t in tcode.split() if re.match(r'^(r|acc|a)\d', t)]
            dstb = int(re.match(r'^(?:r|acc|a)(\d+)', toks[0]).group(1)) if toks else None
            addr = int(re.match(r'^(?:r|acc|a)(\d+)', toks[1]).group(1)) if len(toks) > 1 else None
            for a in ANN.findall(code_all):
                for t in re.finditer(r'\$(\d+)(?:\.(dst|src))?', a):
                    if t.group(2): continue
                    send[t.group(1)] = (i, mnem, dstb, n, addr)
            continue
        for a in ANN.findall(code_all):
            for t in re.finditer(r'\$(\d+)\.(dst|src)', a):
                sb, x = t.group(1), t.group(2)
                if sb not in send: continue
                si, mnem, dstb, n, addr = send[sb]
                if dstb is None: continue
                lo, hi = dstb, dstb + max(n, 1)
                d, s = operands(stripped)
                reads_dst  = any(lo <= r < hi for r in s)
                writes_dst = any(lo <= r < hi for r in d)
                writes_addr= (addr is not None and any(r == addr for r in d))
                cls = 'READS_DST(RAW)' if reads_dst else (
                      'WRITES_ADDR(recycle)' if writes_addr else (
                      'WRITES_DST(WAW)' if writes_dst else 'neither'))
                tab[(x, cls)] += 1
                rows.append((i + 1, sb, x, cls, mnem, 'r%d..r%d' % (lo, hi - 1),
                             'addr=r%s' % addr, ' '.join(sorted(str(v) for v in d)),
                             ' '.join(sorted(str(v) for v in s))))
    print('file=%s' % path.rsplit('\\', 1)[-1])
    print('\nCROSS-TAB  annotation-suffix x what the line mechanically does')
    cls_order = ['READS_DST(RAW)', 'WRITES_ADDR(recycle)', 'WRITES_DST(WAW)', 'neither']
    print('%-8s %18s %20s %18s %10s' % ('suffix', *cls_order))
    for x in ('src', 'dst'):
        print('%-8s %18d %20d %18d %10d' %
              (('.' + x), tab[(x, cls_order[0])], tab[(x, cls_order[1])],
               tab[(x, cls_order[2])], tab[(x, cls_order[3])]))
    tot_src = sum(tab[('src', c)] for c in cls_order)
    tot_dst = sum(tab[('dst', c)] for c in cls_order)
    print('TOTAL  .src=%d  .dst=%d' % (tot_src, tot_dst))
    print('\nsample rows (line, sb, suffix, class, send-mnem, send-dst-range, addr, dsts, srcs):')
    for r in rows[:24]:
        print('  %5d $%-3s %-4s %-20s %-10s %-10s %-9s d=%-8s s=%s' %
              (r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8]))
    return 0

if __name__ == '__main__':
    sys.exit(main())
