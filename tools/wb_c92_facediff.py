import sys, os, struct, math
sys.stdout.reconfigure(encoding='utf-8')
# C92 face-level numeric column: compare the ON faces against the OFF (baseline) faces, which
# are the pinned env-limited goldens. Reports byte-difference %, and in the f16 domain the
# max relative change and any NaN/inf introduced.
# NOTE: the legs script's path rewrite flattened the dump prefix (c91dump\c91. -> c92dump.c92.),
# so the C92 faces live at E:\DSH\tmp\c92dump.c92.<leg>.<face>.bin -- same bytes, different name.
pairs = [
    ('1301 fused', r'E:\DSH\tmp\c92dump.c92.on_f.1301.bin', r'E:\DSH\tmp\c92dump.c92.off_f.1301.bin'),
    ('result',     r'E:\DSH\tmp\c92dump.c92.on_f.result.bin', r'E:\DSH\tmp\c92dump.c92.off_f.result.bin'),
    ('features',   r'E:\DSH\tmp\c92dump.c92.on_f.features.bin', r'E:\DSH\tmp\c92dump.c92.off_f.features.bin'),
    ('1301 plain', r'E:\DSH\tmp\c92dump.c92.on_p.1301.bin', r'E:\DSH\tmp\c91dump\c91.off_p.1301.bin'),
]
for name, a, b in pairs:
    if not (os.path.exists(a) and os.path.exists(b)):
        print('%-12s MISSING (%s / %s)' % (name, os.path.exists(a), os.path.exists(b))); continue
    da, db = open(a, 'rb').read(), open(b, 'rb').read()
    if len(da) != len(db):
        print('%-12s size differs: on=%d off=%d' % (name, len(da), len(db))); continue
    diff = sum(1 for x, y in zip(da, db) if x != y)
    # element-wise view (f16 where the face is half-valued; fall back to raw compare)
    n = len(da) // 2
    try:
        va = struct.unpack('<%de' % n, da); vb = struct.unpack('<%de' % n, db)
        nel = 0; maxrel = 0.0; badnum = 0; sumrel = 0.0
        for x, y in zip(va, vb):
            fx, fy = float(x), float(y)
            if not math.isfinite(fx) and math.isfinite(fy): badnum += 1
            if not math.isfinite(fy) and math.isfinite(fx): badnum += 1
            d = abs(fx - fy)
            if d > 0:
                nel += 1
                den = max(abs(fy), 1e-6)
                r = d / den
                if r > maxrel: maxrel = r
                sumrel += r
        print('%-12s bytes: different=%d / %d = %.3f%% | f16 elements: changed=%d (%.3f%%) max rel=%.3f%% mean rel=%.4f%% non-finite introduced=%d'
              % (name, diff, len(da), 100.0 * diff / len(da), nel, 100.0 * nel / n, 100.0 * maxrel, 100.0 * sumrel / max(nel, 1), badnum))
    except Exception as ex:
        print('%-12s bytes: different=%d / %d = %.3f%%  (element view failed: %s)' % (name, diff, len(da), 100.0 * diff / len(da), ex))
