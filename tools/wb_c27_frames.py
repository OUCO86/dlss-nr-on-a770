import sys, re, os
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c27_frames.py -- the per-frame divergence table requested by C27 step 1.
#   usage: python wb_c27_frames.py <ctl.log> <leg1.log> [leg2.log ...]
# For each leg: per frame -> is each fingerprint EQUAL to the control's same frame, plus
# the engine's verdict (lastdiff) and whether that frame ran the twin.
TAGS = ['result', 'history', 'head', 'f1285', 'f1267vit', 'f1271vit', 'features']
def parse(p):
    fh = {}     # (run, tag) -> fnv
    vd = []     # per-frame verdicts in order
    runs = {}   # run -> ms
    for l in open(p, encoding='utf-8', errors='replace'):
        s = l.strip()
        m = re.search(r'framehash run=(\d+) (\S+) bytes=(\d+) fnv=([0-9a-f]+)', s)
        if m:
            fh[(int(m.group(1)), m.group(2))] = m.group(4)
            continue
        m = re.search(r'\[vit-reuse\] frames=(\d+) skipped=(\d+) lastdiff=(-?\d+).*-> (MASTER|TWIN)', s)
        if m:
            vd.append((int(m.group(1)), int(m.group(2)), int(m.group(3)), m.group(4)))
            continue
        m = re.search(r'run (\d+): ([0-9.]+) ms', s)
        if m:
            runs[int(m.group(1))] = float(m.group(2))
    return fh, vd, runs
paths = sys.argv[1:]
ctl, cctl, rctl = parse(paths[0])
print('control = %s   frames=%d' % (os.path.basename(paths[0]), len(rctl)))
print('frame | ' + ' | '.join('%-9s' % t for t in TAGS) + ' | lastdiff | graph  | ms')
for p in paths[1:]:
    fh, vd, runs = parse(p)
    print('== %s ==' % os.path.basename(p).replace('.log', ''))
    for i in sorted(runs):
        cells = []
        for t in TAGS:
            a = ctl.get((i, t)); b = fh.get((i, t))
            if a is None or b is None:
                cells.append('%-9s' % '-')
            else:
                cells.append('%-9s' % ('same' if a == b else 'DIFF'))
        v = vd[i] if i < len(vd) else (0, 0, -3, '?')
        print('%5d | ' % i + ' | '.join(cells) + ' | %8d | %-6s | %.2f' % (v[2], v[3], runs[i]))
print('=== done wb_c27_frames ===')
