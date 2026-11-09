import sys, re
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c28_stamp.py -- the per-frame attribution table from the face stamp (C28 step 3).
# The twin stamps 16 magic bytes into plan face 1287; a master frame overwrites that face
# with real quant data. So the face dump says which graph RAN, independent of any host print.
# Cross-checked against (a) the engine's own verdict print and (b) whether face 1285 stalled
# versus the previous frame (a stalled 1285 == the segment did not write it == reuse).
MAGIC = '1d578ac2c871e751'   # the first 8 bytes of the stamped uint4 (LE of 0xC28A571D, 0x51E771C8)
def twin_exec(hexstr):
    # hex = 16 bytes: magic8 | counter4 (LE) | stamp4 (LE, == 1)
    if not hexstr or not hexstr.startswith(MAGIC): return None
    c = hexstr[16:24]
    return int(c[6:8] + c[4:6] + c[2:4] + c[0:2], 16)
for p in sys.argv[1:]:
    stamp = {}
    fh = {}
    ver = []
    runs = {}
    for l in open(p, encoding='utf-8', errors='replace'):
        s = l.strip()
        m = re.search(r'stamp run=(\d+) f1287=([0-9a-f]{32})', s)
        if m:
            stamp[int(m.group(1))] = m.group(2)
            continue
        m = re.search(r'framehash run=(\d+) (\S+) bytes=\d+ fnv=([0-9a-f]+)', s)
        if m:
            fh[(int(m.group(1)), m.group(2))] = m.group(3)
            continue
        m = re.search(r'frames=(\d+) skipped=(\d+) lastdiff=(-?\d+).*-> (MASTER|TWIN)', s)
        if m:
            ver.append((int(m.group(1)), int(m.group(3)), m.group(4)))
            continue
        m = re.search(r'run (\d+): ([0-9.]+) ms', s)
        if m:
            runs[int(m.group(1))] = float(m.group(2))
    print('== %s ==' % p.split('\\')[-1].replace('.log', ''))
    print('  run | face-stamp       | engine print | 1285 stall? | lastdiff | ms   | agree')
    for i in sorted(runs):
        st = stamp.get(i)
        ex = twin_exec(st) if st else None
        who = ('TWIN#' + str(ex)) if ex is not None else ('master?' if st else '-')
        v = ver[i] if i < len(ver) else (0, -9, '?')
        stall = (i > 0 and fh.get((i, 'f1285')) == fh.get((i - 1, 'f1285')))
        agree = ((ex is not None) == (v[2] == 'TWIN'))
        print('  %4d | %-16s | %-12s | %-11s | %8d | %5.2f | %s' % (
            i, who, '%s(%d)' % (v[2], v[1] if v[1] != -2 else -2),
            'YES' if stall else 'no', v[1], runs[i], 'OK' if agree else 'MISMATCH'))
print('=== done wb_c28_stamp ===')
