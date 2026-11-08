import io, sys, statistics
sys.stdout.reconfigure(encoding='utf-8')
rows = [l.strip().split(',') for l in io.open(r'E:\DSH\s6\A1_node_ladder.csv', encoding='utf-8', errors='replace') if l.strip()]
hdr = rows[0]
print('cols:', hdr)
acc = {}
for r in rows[1:]:
    if len(r) < 9 or r[0] == 'done':
        continue
    lim, rep = int(r[0]), r[1]
    med = r[7]
    passes, closures, md5 = r[8], r[9], r[-1]
    try:
        m = float(med)
    except Exception:
        continue
    acc.setdefault(lim, []).append((m, closures, passes, md5))
pts = []
print('\n%-6s %-22s %-10s %-8s' % ('lim', 'med ms (reps)', 'closures', 'passes'))
for lim in sorted(acc):
    vs = [v[0] for v in acc[lim]]
    cl = acc[lim][0][1]; pa = acc[lim][0][2]
    print('%-6d %-22s %-10s %-8s' % (lim, ' / '.join('%.2f' % x for x in vs), cl, pa))
    pts.append((lim, statistics.median(vs)))
if len(pts) >= 3:
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    n = len(xs)
    sx = sum(xs); sy = sum(ys); sxx = sum(x*x for x in xs); sxy = sum(x*y for x, y in zip(xs, ys))
    slope = (n*sxy - sx*sy) / (n*sxx - sx*sx)
    icept = (sy - slope*sx) / n
    yhat = [icept + slope*x for x in xs]
    ss_res = sum((y - yh)**2 for y, yh in zip(ys, yhat)); ss_tot = sum((y - sum(ys)/n)**2 for y in ys)
    r2 = 1 - ss_res/ss_tot if ss_tot else 0.0
    print('\n=== 1a 结论 ===')
    print('每只图节点（cgraph node）的边际成本 = %.4f ms  (R2=%.3f, intercept=%.2f ms)' % (slope, r2, icept))
    print('对照：跳链阶梯 (B) 的 0.044 ms/闭包、按链 (A) 的 0.0418 ms/闭包')
    print('691 节点 => 节点固定成本合计 ≈ %.1f ms；实测帧 ≈ 44.7 ms（非 fused cold）' % (slope*691))
    if abs(slope - 0.044) < 0.012:
        print('=> 两条独立路咬合：每只闭包 ~0.044 ms 是图节点级成本（出货路 = 一次 graph submit，主机派发不是盖子）')
    else:
        print('=> 两路不咬合：节点级成本与跳链成本不同源，需再看 DAG/关键路径（1b）')
