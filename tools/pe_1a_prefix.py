import io, re, sys, collections
sys.stdout.reconfigure(encoding='utf-8')

# --- 1) per-closure serialized times, in closure order (from the C7 leg batch) ---
pat = re.compile(r'rtcsv\s+(\d+)\s+(\S+)\s+([0-9.]+)')
per = {}
for p in [r'E:\DSH\s6\rt_c7leg_B_1.txt', r'E:\DSH\s6\rt_c7leg_B_2.txt', r'E:\DSH\s6\rt_c7leg_B_3.txt',
          r'E:\DSH\s6\rt_c7leg_A_1.txt', r'E:\DSH\s6\rt_c7leg_A_2.txt', r'E:\DSH\s6\rt_c7leg_A_3.txt']:
    try:
        txt = io.open(p, encoding='utf-8', errors='replace').read()
    except OSError:
        continue
    for m in pat.finditer(txt):
        per.setdefault(int(m.group(1)), collections.Counter())[m.group(2)] += float(m.group(3))
    if per:
        print('using', p, 'closures=', len(per))
        break

idx = sorted(per)
cost = []
for i in idx:
    tot = sum(per[i].values())
    fam = max(per[i].items(), key=lambda kv: kv[1])[0]
    cost.append((i, fam, tot))
print('closures with times: %d (range %d..%d)' % (len(cost), cost[0][0], cost[-1][0]))

# --- 2) prefix sums vs the NR_CGRAPH_LIMIT ladder ---
lad = {100: 14.70, 200: 18.99, 400: 24.50, 550: 27.06, 691: 43.93}
pre = 0.0
marks = {}
for (i, fam, c) in cost:
    pre += c
    if (i + 1) in lad:
        marks[i + 1] = pre
print('\n%-6s %10s %10s %10s' % ('lim', 'ladder ms', 'leg-sum ms', 'ratio'))
for lim in sorted(lad):
    ls = marks.get(lim)
    if ls:
        print('%-6d %10.2f %10.2f %10.2f' % (lim, lad[lim], ls, lad[lim] / ls if ls else 0))

# --- 3) where the tail cost lives ---
def band(a, b):
    c = collections.Counter(); tot = 0.0
    for (i, fam, v) in cost:
        if a <= i < b:
            c[fam] += v; tot += v
    return tot, c
for a, b in [(0, 100), (100, 200), (200, 400), (400, 550), (550, 691)]:
    tot, c = band(a, b)
    top = ', '.join('%s %.2f' % (k, v) for k, v in c.most_common(5))
    print('band %4d-%4d  leg-sum %6.2f ms  per-closure %6.4f ms   top: %s' % (a, b, tot, tot / (b - a), top))

# --- 4) family totals in closure order ---
fam_tot = collections.Counter(); fam_n = collections.Counter()
for (i, fam, v) in cost:
    fam_tot[fam] += v; fam_n[fam] += 1
print('\n%-38s %6s %9s %9s' % ('family', 'clos', 'leg ms', 'ms/clos'))
for k, v in fam_tot.most_common(14):
    print('%-38s %6d %9.2f %9.4f' % (k, fam_n[k], v, v / fam_n[k]))
