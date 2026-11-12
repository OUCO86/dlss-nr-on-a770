import sys, collections
sys.stdout.reconfigure(encoding='utf-8')
A = open(r'E:\DSH\tmp\c61cdump\base_s0p_1301.bin', 'rb').read()     # shipped build, plain route (DD49827D...)
B = open(r'E:\DSH\tmp\c27dump\f.c27_s0p.1301.bin', 'rb').read()     # C61d build,   plain route (249A46F3...)
print('sizes', len(A), len(B))
W, H = 960, 544
print('elements = %d  (W*H=%d)  bytes/elem = %.2f' % (len(A) // 4, W * H, len(A) / (W * H)))
nd = 0
rowdiff = collections.Counter()
coldiff = collections.Counter()
bands = collections.Counter()
first = []
for i in range(0, len(A), 4):
    if A[i:i + 4] != B[i:i + 4]:
        nd += 1
        e = i // 4
        r = e // W
        c = e % W
        rowdiff[r] += 1
        coldiff[(c // 64)] += 1
        bands[(r // 128) if False else (r // 64)] += 1
        if len(first) < 6:
            first.append((e, r, c, A[i:i + 4].hex(), B[i:i + 4].hex()))
print('\ndiffering ELEMENTS = %d / %d  (%.2f%%)' % (nd, len(A) // 4, 100.0 * nd / (len(A) // 4)))
print('first 6 differing elements (elem,row,col,base,c61d):')
for t in first:
    print('   ', t)
print('\nrows with diffs: %d of %d  (max per row %d, mean %.1f)' % (
    len(rowdiff), H, max(rowdiff.values()), sum(rowdiff.values()) / len(rowdiff)))
rows_sorted = sorted(rowdiff.items(), key=lambda x: -x[1])[:10]
print('top rows:', rows_sorted)
print('\n64-col bands: %s' % dict(sorted(coldiff.items())))
print('\n64-row bands (row//64 -> diff count):')
for b in sorted(bands):
    print('   rows %4d-%4d : %7d  (%.1f%% of the band)' % (b * 64, b * 64 + 63, bands[b], 100.0 * bands[b] / (64 * W)))
