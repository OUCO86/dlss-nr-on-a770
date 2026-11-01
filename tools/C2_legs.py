#!/usr/bin/env python3
# C2_legs.py -- turn the CSVROW lines in the C2 run logs into E:/DSH/s6/C2_legs.csv
# columns: shape,leg_or_phase,ms,msM,flops,TOPS,note
import re, sys, glob
logs = sys.argv[1:] or sorted(glob.glob(r'E:\DSH\s6\C2_S1b.log') + glob.glob(r'E:\DSH\s6\C2_S2b.log'))
rows, seen = [], set()
for lf in logs:
    try:
        txt = open(lf, encoding='utf-8', errors='replace').read()
    except OSError:
        continue
    for m in re.finditer(r'^CSVROW;([^;]+);([^;]+);([0-9.\-]+);([0-9.\-]+);([0-9.\-]+);([0-9.\-]+);(.*)$',
                         txt, re.M):
        sh, leg, ms, msM, fl, tops, note = [x.strip() for x in m.groups()]
        key = (sh, leg)
        if key in seen:
            continue
        seen.add(key)
        note = note.replace('"', '""')
        rows.append((sh, leg, ms, msM, fl, tops, note))
with open(r'E:\DSH\s6\C2_legs.csv', 'w', encoding='utf-8', newline='') as f:
    f.write('shape,leg_or_phase,ms,msM,flops,TOPS,note\n')
    for r in rows:
        f.write(','.join([r[0], r[1], r[2], r[3], r[4], r[5], '"' + r[6] + '"']) + '\n')
print(f'wrote E:/DSH/s6/C2_legs.csv  ({len(rows)} rows from {len(logs)} logs)')
for r in rows:
    print(f'  {r[0]:3s} {r[1]:34s} ms={r[2]:>8s} msM={r[3]:>8s} TOPS={r[5]:>8s}')
