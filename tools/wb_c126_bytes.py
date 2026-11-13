import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# C126 (3): full-frame byte account for the two activation faces, from the real byte-audit legs
# (upper-bound-per-closure accounting, same caveat as before: a face is charged at its full size for
# every closure that touches it). Chain 25/33 are the live ones in the skip-ON config.
# NOTE: in the merged diag build the audit print sits inside the stopset block, so only the STOP
# legs carry [byte-audit] lines (C123_base* have none -- instrument quirk, recorded). The face bytes
# are independent of which chains a leg stops, so any stop leg gives the full per-chain table.
LOGS = [r'E:\DSH\logs\C123_st251.log', r'E:\DSH\logs\C123_st331.log', r'E:\DSH\logs\C125_res_s1.log']
per_chain = {}
for lg in LOGS:
    try:
        t = open(lg, encoding='utf-8', errors='replace').read()
    except FileNotFoundError:
        continue
    for ch, tot, faces in re.findall(r'\[byte-audit\] chain=(\d+) totalMB=([\d.]+) faces=([^\n]*)', t):
        per_chain[int(ch)] = {int(f): (float(mb), int(w)) for f, mb, w in re.findall(r'(\d+):([\d.]+)MB\(w(\d+)\)', faces)}
    break
print('chains in the audit:', len(per_chain))

# 1267 <-> mirror 1303, 1274 <-> mirror 1307 (proven by the identical byte sizes:
# 66,846,720 and 33,554,432 in the [buf-create] lines of logs/C123_trace.log)
PAIRS = {1267: 1303, 1274: 1307}
live = [25, 33]
print()
print('=== touched bytes for the two faces ===')
for plan_id, mir in PAIRS.items():
    live_mb = sum(per_chain[c][mir][0] for c in live if mir in per_chain.get(c, {}))
    all_mb = sum(per_chain[c][mir][0] for c in per_chain if mir in per_chain[c])
    n_live = sum(1 for c in live if mir in per_chain.get(c, {}))
    print('  face %d (mirror %d, %.1f MB each touch)  live chains: %d chains x touches => %.1f MB/frame'
          % (plan_id, mir, per_chain[25][mir][0] / max(1, 3), n_live, live_mb))
    print('      all 52 chains touched total: %.1f MB/frame (if none were skipped)' % all_mb)
print()
SLOPE = (0.00095, 0.00107)
for plan_id, mir in PAIRS.items():
    live_mb = sum(per_chain[c][mir][0] for c in live if mir in per_chain.get(c, {}))
    lo, hi = live_mb / 2 * SLOPE[0], live_mb / 2 * SLOPE[1]
    print('  face %d: live(block) touch %.1f MB -> halving saves %.1f MB -> block gain %.3f .. %.3f ms'
          % (plan_id, live_mb, live_mb / 2, lo, hi))
tot_live = sum(sum(per_chain[c][mir][0] for c in live if mir in per_chain.get(c, {})) for mir in PAIRS.values())
tot_all = sum(sum(per_chain[c][mir][0] for c in per_chain if mir in per_chain[c]) for mir in PAIRS.values())
print()
print('  BOTH faces: block touch %.1f MB => halve => block %.3f .. %.3f ms' % (tot_live, tot_live/2*SLOPE[0], tot_live/2*SLOPE[1]))
print('  BOTH faces: ALL-chain touch %.1f MB => halve => frame %.3f .. %.3f ms at the same slope' % (tot_all, tot_all/2*SLOPE[0], tot_all/2*SLOPE[1]))
print('  (frame note: in the skip-ON frame the other chains are no-oped, so the frame gain is bounded by')
print('   what those chains actually cost -- the all-chain number is an upper bound, stated as such)')
print()
print('=== element widths seen for the two mirrors ===')
for c in live:
    for mir in PAIRS.values():
        if mir in per_chain[c]:
            print('  chain %d face %d: %.1f MB, esz=w%d' % (c, mir, per_chain[c][mir][0], per_chain[c][mir][1]))
