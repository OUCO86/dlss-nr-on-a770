import sys, re
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c25_legs.py -- compare two NR_RUN_TIMING dumps closure by closure over the
# ViT segment (fused route: GA closures at 320,329,...,383; chain = GA-2..GA+2 = 318..385).
def load(p):
    rows = {}
    for ln in open(p, encoding='utf-8', errors='replace'):
        m = re.match(r"rtcsv (\d+) (.+?) ([0-9.]+) pf=(-?\d+)", ln.strip())
        if m:
            rows[int(m.group(1))] = (m.group(2), float(m.group(3)), int(m.group(4)))
    return rows
A = load(sys.argv[1])   # master (never skips)
B = load(sys.argv[2])   # twin (chains dissolved)
print("master closures=%d twin closures=%d" % (len(A), len(B)))
def tot(d): return sum(v[1] for v in d.values())
print("TOTAL master=%.1f ms twin=%.1f ms delta=%+.1f ms (%.1f%%)" % (
    tot(A), tot(B), tot(B) - tot(A), 100.0 * (tot(B) - tot(A)) / tot(A)))
ga = sorted(i for i, v in A.items() if v[0] == 'xmx_rec_global_attention')
print("GA at %s" % ga)
chain = sorted(set(sum([list(range(g - 2, g + 3)) for g in ga], [])))
sa = sum(A[i][1] for i in chain); sb = sum(B[i][1] for i in chain)
print("chain span %d..%d n=%d: master=%.3f ms twin=%.3f ms drop=%.1f%%" % (
    chain[0], chain[-1], len(chain), sa, sb, 100.0 * (sa - sb) / sa))
print("  per-closure (master -> twin):")
for i in chain:
    print("   %4d %-34s %7.4f -> %7.4f  pf %d -> %d" % (i, A[i][0], A[i][1], B[i][1], A[i][2], B[i][2]))
# families outside the chain that moved (the criterion host is inside the span)
fam = {}
for i in sorted(set(A) | set(B)):
    nm = A.get(i, B.get(i))[0]
    d = B.get(i, (0, 0.0, 0))[1] - A.get(i, (0, 0.0, 0))[1]
    fam.setdefault(nm, [0, 0.0])
    fam[nm][0] += 1; fam[nm][1] += d
print("family totals delta (twin - master):")
for k, v in sorted(fam.items(), key=lambda x: x[1][1]):
    if abs(v[1]) > 0.005:
        print("   %-36s n=%3d  %+8.3f ms" % (k, v[0], v[1]))
print("=== done wb_c25_legs ===")
