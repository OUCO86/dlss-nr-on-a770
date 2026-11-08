#!/usr/bin/env python3
# s6/stall_census2.py -- GEN scoreboard / memory-level-parallelism census.
# The ocloc disassembler does NOT print `wait` instructions: dependencies are
# carried by scoreboard annotations. A `send` line ends with {..., $k ...} meaning
# "result will be signalled on scoreboard k"; the first later line containing
# `$k.dst` (or `$k.src`) is where the thread actually stalls.
# So: distance(send -> first $k.dst) and (#scoreboards opened before that stall)
# tell us the kernel's memory-level parallelism. Small distance + MLP 1 = latency stall.
import io, re, sys, glob, os, collections
sys.stdout.reconfigure(encoding='utf-8')

SEND = re.compile(r'^\s*(?:\([^)]*\)\s*)?(send[a-zA-Z0-9_.]*|dpas[a-zA-Z0-9_.]*)\b(.*)$')
SB   = re.compile(r'\$(\d+)')
DST  = re.compile(r'\$\d+\.dst')
SRC  = re.compile(r'\$\d+\.src')

def analyze(path):
    lines = io.open(path, encoding='utf-8', errors='replace').read().splitlines()
    open_sb = {}          # scoreboard -> line index of the send that opened it
    dists = []            # distance from send to first consumer of its scoreboard
    inflight_at_wait = [] # how many scoreboards were open when the stall happened
    kinds = collections.Counter()
    n_send = n_cons = 0
    for i, ln in enumerate(lines):
        m = SEND.match(ln)
        if m:
            n_send += 1
            kinds[m.group(1)] += 1
            tail = m.group(2)
            for sb in set(x.group(1) for x in SB.finditer(tail)):
                # only track scoreboards that are awaited later on this same path
                open_sb.setdefault(sb, i)
            continue
        if DST.search(ln) or SRC.search(ln):
            n_cons += 1
            for mm in SB.finditer(ln):
                sb = mm.group(1)
                if sb in open_sb:
                    st = open_sb.pop(sb)
                    dists.append(i - st)
                    inflight_at_wait.append(len(open_sb) + 1)
    if not dists:
        return None
    d = sorted(dists)
    n = len(d)
    return dict(name=os.path.basename(path), lines=len(lines), sends=n_send, waits=n_cons,
                p50=d[n//2], p90=d[int(n*0.9)], mn=d[0], mx=d[-1],
                mean=sum(d)/n,
                mlp_mean=sum(inflight_at_wait)/len(inflight_at_wait),
                mlp_hist=collections.Counter(inflight_at_wait),
                kinds=kinds)

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else r'E:\DSH\tmp\k3ze\d_ctlf'
    filt = sys.argv[2] if len(sys.argv) > 2 else ''
    top  = int(sys.argv[3]) if len(sys.argv) > 3 else 10
    files = sorted(glob.glob(os.path.join(root, '.text*.asm')))
    if filt:
        files = [f for f in files if filt in f]
    rows = [r for r in (analyze(f) for f in files) if r]
    rows.sort(key=lambda r: r['p50'])
    print('files=%d  with-scoreboard-consumers=%d' % (len(files), len(rows)))
    print('%-46s %7s %6s %6s %5s %5s %5s %5s %8s' % ('instance(short)', 'lines', 'sends', 'waits', 'min', 'p50', 'p90', 'max', 'MLPavg'))
    def short(nm):
        m = re.search(r'\.text\._ZTS\w*(\w{0,60})', nm)
        return (m.group(1) if m else nm)[:46]
    for r in rows[:top]:
        print('%-46s %7d %6d %6d %5d %5d %5d %5d %8.2f' % (
            short(r['name']), r['lines'], r['sends'], r['waits'], r['mn'], r['p50'], r['p90'], r['mx'], r['mlp_mean']))
    print('\n=== 按 send 类型汇总（全体实例）===')
    tot = collections.Counter()
    for r in rows:
        tot.update(r['kinds'])
    for k, v in tot.most_common(12):
        print('   %-22s %8d' % (k, v))
    print('\n=== MLP 直方图（stall 时同时在飞的 scoreboard 数；全体）===')
    h = collections.Counter()
    for r in rows:
        h.update(r['mlp_hist'])
    for k in sorted(h)[:12]:
        print('   inflight=%-3d %8d' % (k, h[k]))
    return 0

if __name__ == '__main__':
    sys.exit(main())
