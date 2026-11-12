import sys, os, math, struct, statistics
sys.stdout.reconfigure(encoding='utf-8')
# C84-(0): band-internal vs whole-row quantization scales, measured on REAL activations.
# bk.1301 = the C512 tier's input plane (the window block's output, the source of
# QUANT_WINDOW): 8160 rows x 512 cols x f16 = 8,355,840 B. Read-only golden; never written.
P = r'E:\DSH\dumps\bk.1301.skip.bin'
data = open(P, 'rb').read()
M, K = 8160, 512
assert len(data) == M * K * 2, (len(data), M * K * 2)
rows = [struct.unpack('<%de' % K, data[r * K * 2:(r + 1) * K * 2]) for r in range(M)]
nf = sum(1 for rr in rows for x in rr if not math.isfinite(x))
print('plane: %d x %d f16   non-finite elements %d (%.2f%%)  -> the window block leaves a tail unwritten'
      % (M, K, nf, 100.0 * nf / (M * K)))
used = 0
for bw in (128, 64):
    tot = changed = 0
    maxq = 0
    maxabs = sumabs = maxrel = sumrel = 0.0
    ratios = []
    nseg = nskip = 0
    for rr in rows:
        wpeak = max([abs(x) for x in rr if math.isfinite(x)] or [0.0])
        if wpeak == 0.0:
            continue
        ws = wpeak / 127.0
        used += 1
        for c0 in range(0, K, bw):
            seg = rr[c0:c0 + bw]
            if not all(math.isfinite(x) for x in seg):
                nskip += 1
                continue
            nseg += 1
            bpeak = max(abs(x) for x in seg)
            bs = max(bpeak, 1e-9) / 127.0
            ratios.append(bs / ws)
            for x in seg:
                q0 = max(-127, min(127, int(round(x / ws))))
                q1 = max(-127, min(127, int(round(x / bs))))
                tot += 1
                if q0 != q1:
                    changed += 1
                if abs(q1 - q0) > maxq:
                    maxq = abs(q1 - q0)
                e = abs(q1 * bs - q0 * ws)
                if e > maxabs:
                    maxabs = e
                sumabs += e
                rel = e / wpeak
                if rel > maxrel:
                    maxrel = rel
                sumrel += rel
    print('\n== band width %d  (rows used=%d segments=%d skipped=%d) ==' % (bw, used, nseg, nskip))
    print('   codes changed: %d / %d = %.2f%%   max|dq| = %d codes' % (changed, tot, 100.0 * changed / tot, maxq))
    print('   dequant error: max %.4g  mean %.4g   / row peak: max %.3f%%  mean %.4f%%'
          % (maxabs, sumabs / tot, 100.0 * maxrel, 100.0 * sumrel / tot))
    print('   band/row scale ratio: min %.3f  median %.3f  max %.3f' % (min(ratios), statistics.median(ratios), max(ratios)))
    print('   scale storage per plane (M=8160): whole-row %d B   band %d B   ratio x%d'
          % (M * 4, M * (K // bw) * 4, K // bw))
