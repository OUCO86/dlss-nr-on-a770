#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
db_meter.py -- the judge (军规 0 修订, notes/B2-blueprint-to-10ms.md:180-189), FIVE-SCALE edition
=============================================================================================
Why five scales: the 2026-11-02 skip shovel (notes/DS-takeover-2026-11-01.md §33,
notes/skip-table.md "口径提醒") proved that dB alone is NOT a safe gate for STRUCTURAL
changes: the 1301 face amplifies structural edits systematically through the 120-layer
residual chain (L512x2 corr=0.986 mean|d|=0.34 vs L128x2 corr=0.70 mean|d|=1.63, and two
DIFFERENT skip sets are 16-28 dB apart from each other = the same order as their distance
to the golden). So dB is demoted to an auxiliary and Pearson corr becomes the primary
structural gate.

Face scale facts (measured on bk.1301.bin, not assumed):
  R[-7.8426..+5.2129]=13.0555  G[-7.6469..+5.9407]=13.5876  B[-6.6740..+5.9560]=12.6300
  A[5.6552..47.8708]=42.2156   RGB mixed dynamic range = 13.7986
  => dB@range (peak = golden's own range) is the SCALE-INVARIANT, gate-comparable number;
     dB@[0,1] (peak = 1.0) is what lmxx's 40/35 dB gate was measured on.
     On this face the two differ by 20*log10(13.7986) = 22.79 dB. NEVER compare a
     dB@range number with a dB@[0,1] threshold, and vice versa.

THE FIVE REPORTS (per channel R/G/B/A and for RGB aggregate):
  1. dB@range  = 20*log10( (golden channel max-min) / RMSE )
  2. dB@[0,1]  = 20*log10( 1.0 / RMSE )                -- lmxx-comparable ONLY if the face
                                                         were [0,1]; ours has range 13.8,
                                                         so this reads ~22.8 dB lower.
  3. Pearson corr  -- per channel, plus RGB-pooled and per-pixel-RGB-mean (luma) variants
  4. mean|d| and p99.9|d|, in units of the GOLDEN's own sigma (dimensionless)
  5. worst-1% pixels dB -- per-pixel RGB RMSE sorted; dB@range / dB@[0,1] at the 99th
     percentile and averaged over the worst 1% tail

NEW THRESHOLDS (hard-coded here and in the ledger, 2026-11-02):
  corr >= 0.99              -> STRUCTURALLY SAFE
  0.95 <= corr < 0.99       -> must be accepted by ON-SCREEN review (实机画面验收)
  corr <  0.95              -> REJECTED (the structure itself got broken)
  dB is auxiliary only; >=40 dB@range safe / >=35 dB@range acceptable still printed.
  Any temporal flicker = one-vote veto: use --cross (same config, two processes).

Dump format: 960x544 RGBA float32 little-endian = 522,240 px x 16 B = 8,355,840 B.
Any other size = parse error (exit 2).

Usage:
  py tools/db_meter.py GOLD A [B C ...] [--csv out.csv] [--cross] [--peak-override P]
  self-test:  --selftest   (bk vs bk = inf/IDENTICAL/corr 1; sigma=0.5571 synthetic noise
                            = 27.89 dB@range expected, 5.09 dB@[0,1], corr ~0.968)
"""
import sys, os, math, array, argparse, hashlib

W, H = 960, 544
NPIX = W * H
NBYTES = NPIX * 16          # 8,355,840
CH = ['R', 'G', 'B', 'A']

# ---- judge thresholds (2026-11-02, §33 lesson) ----
CORR_SAFE = 0.99            # >= : structurally safe
CORR_REJECT = 0.95          # <  : rejected, structure broken
DB_SAFE = 40.0              # dB@range, auxiliary
DB_OK = 35.0                # dB@range, auxiliary
GOLDEN_RGB_RANGE = 13.7986  # measured on bk.1301.bin; dB@range vs dB@[0,1] offset:
DB_SCALE_OFFSET = 20.0 * math.log10(GOLDEN_RGB_RANGE)   # = 22.79 dB

def load(path):
    sz = os.path.getsize(path)
    if sz != NBYTES:
        sys.stderr.write("db_meter: %s has %d bytes, expected %d (960x544 RGBA f32)\n"
                         % (path, sz, NBYTES))
        sys.exit(2)
    with open(path, 'rb') as f:
        b = f.read()
    a = array.array('f')
    a.frombytes(b)
    if sys.byteorder != 'little':
        a.byteswap()
    return a

def file_md5(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()

def dB(peak, rmse):
    if rmse == 0.0:
        return float('inf')
    return 20.0 * math.log10(peak / rmse)

def corr_of(a, b):
    """Pearson correlation between two float sequences."""
    n = len(a)
    if n == 0:
        return float('nan')
    ma = 0.0; mb = 0.0
    for i in range(n):
        ma += a[i]; mb += b[i]
    ma /= n; mb /= n
    saa = 0.0; sbb = 0.0; sab = 0.0
    for i in range(n):
        xa = a[i] - ma; xb = b[i] - mb
        saa += xa * xa; sbb += xb * xb; sab += xa * xb
    if saa <= 0.0 or sbb <= 0.0:
        return float('nan')
    return sab / math.sqrt(saa * sbb)

def pct(sorted_vals, q):
    """q in [0,1]; sorted_vals ascending list/array."""
    n = len(sorted_vals)
    if n == 0:
        return float('nan')
    i = int(q * (n - 1))
    return sorted_vals[i]

def stats_np(G, T, d):
    """numpy path. G/T/d: (NPIX,4) float32/64 arrays. Returns raw aggregates."""
    import numpy as np
    mse = np.mean(d * d, axis=0)
    absd = np.abs(d)
    mad = np.mean(absd, axis=0)
    p999 = np.percentile(absd, 99.9, axis=0)
    maxabs = np.max(absd, axis=0)
    gmin = np.min(G, axis=0); gmax = np.max(G, axis=0); gsd = np.std(G, axis=0)
    gmean = np.mean(G, axis=0); tmean = np.mean(T, axis=0)
    gc = G - gmean; tc = T - tmean
    num = np.sum(gc * tc, axis=0)
    den = np.sqrt(np.sum(gc * gc, axis=0) * np.sum(tc * tc, axis=0))
    corr_ch = [float(num[c] / den[c]) if den[c] > 0 else float('nan') for c in range(4)]
    # RGB pooled
    Gr = G[:, :3].ravel(); Tr = T[:, :3].ravel(); Dr = d[:, :3]
    mse_rgb = float(np.mean(Dr * Dr))
    mad_rgb = float(np.mean(np.abs(Dr)))
    p999_rgb = float(np.percentile(np.abs(Dr), 99.9))
    max_rgb = float(np.max(np.abs(Dr)))
    gmean_r = float(Gr.mean()); tmean_r = float(Tr.mean())
    gcr = Gr - gmean_r; tcr = Tr - tmean_r
    den_r = math.sqrt(float(np.sum(gcr * gcr)) * float(np.sum(tcr * tcr)))
    corr_rgb = float(np.sum(gcr * tcr) / den_r) if den_r > 0 else float('nan')
    # luma = per-pixel RGB mean
    gl = G[:, :3].mean(axis=1); tl = T[:, :3].mean(axis=1)
    gcl = gl - float(gl.mean()); tcl = tl - float(tl.mean())
    den_l = math.sqrt(float(np.sum(gcl * gcl)) * float(np.sum(tcl * tcl)))
    corr_luma = float(np.sum(gcl * tcl) / den_l) if den_l > 0 else float('nan')
    sd_rgb = float(np.std(Gr))
    rng_rgb = float(Gr.max() - np.min(G[:, :3]))
    px = np.sqrt(np.mean(Dr * Dr, axis=1))
    srt = np.sort(px)
    p99 = float(srt[int(0.99 * (NPIX - 1))])
    tail = srt[int(0.99 * (NPIX - 1)):]
    return {'mse': [float(x) for x in mse], 'mad': [float(x) for x in mad],
            'p999': [float(x) for x in p999], 'maxabs': [float(x) for x in maxabs],
            'gmin': [float(x) for x in gmin], 'gmax': [float(x) for x in gmax],
            'gsd': [float(x) for x in gsd], 'corr_ch': corr_ch,
            'mse_rgb': mse_rgb, 'mad_rgb': mad_rgb, 'p999_rgb': p999_rgb,
            'max_rgb': max_rgb, 'corr_rgb': corr_rgb, 'corr_luma': corr_luma,
            'sd_rgb': sd_rgb, 'rng_rgb': rng_rgb,
            'p99_px': p99, 'tail_px': tail.tolist(),
            'ident': bool(np.array_equal(G, T)), 'np': True}

def stats_py(gb, tb):
    """pure-python fallback (same definitions, no numpy)."""
    n = len(gb)
    se = [0.0] * 4; sa = [0.0] * 4
    sg = [0.0] * 4; st = [0.0] * 4; sgg = [0.0] * 4; stt = [0.0] * 4; sgt = [0.0] * 4
    gmin = [float('inf')] * 4; gmax = [float('-inf')] * 4
    absd = [array.array('d', bytes(8 * NPIX)) for _ in range(4)]
    px = array.array('d', bytes(8 * NPIX))
    ident = True
    k = 0; i = 0
    while i < n:
        e3 = 0.0
        for c in range(4):
            gv = gb[i + c]; tv = tb[i + c]
            e = gv - tv
            if e != 0.0:
                ident = False
            ae = -e if e < 0 else e
            absd[c][k] = ae
            se[c] += e * e; sa[c] += ae
            sg[c] += gv; st[c] += tv; sgg[c] += gv * gv; stt[c] += tv * tv; sgt[c] += gv * tv
            if gv < gmin[c]: gmin[c] = gv
            if gv > gmax[c]: gmax[c] = gv
            if c < 3:
                e3 += e * e
        px[k] = math.sqrt(e3 / 3.0)
        k += 1; i += 4
    corr_ch = []
    for c in range(4):
        ma = sg[c] / NPIX; mb = st[c] / NPIX
        saa = sgg[c] - NPIX * ma * ma; sbb = stt[c] - NPIX * mb * mb
        sab = sgt[c] - NPIX * ma * mb
        corr_ch.append(sab / math.sqrt(saa * sbb) if saa > 0 and sbb > 0 else float('nan'))
    def flat(c):
        return absd[c]
    # RGB pooled moments
    sgr = sum(sg[:3]); str_ = sum(st[:3]); sggr = sum(sgg[:3]); sttr = sum(stt[:3])
    srgt = sum(sgt[:3]); nn = 3 * NPIX
    saa = sggr - nn * (sgr / nn) ** 2; sbb = sttr - nn * (str_ / nn) ** 2
    sab = srgt - nn * (sgr / nn) * (str_ / nn)
    corr_rgb = sab / math.sqrt(saa * sbb) if saa > 0 and sbb > 0 else float('nan')
    # luma corr
    gl = array.array('d', bytes(8 * NPIX)); tl = array.array('d', bytes(8 * NPIX))
    i = 0; k = 0
    while i < n:
        gl[k] = (gb[i] + gb[i + 1] + gb[i + 2]) / 3.0
        tl[k] = (tb[i] + tb[i + 1] + tb[i + 2]) / 3.0
        k += 1; i += 4
    corr_luma = corr_of(gl, tl)
    mse = [s / NPIX for s in se]; mad = [s / NPIX for s in sa]
    p999 = []; maxabs = []; gsd = []
    gsum = 0.0; gsq = 0.0
    for c in range(4):
        p999.append(pct(sorted(absd[c]), 0.999)); maxabs.append(max(absd[c]))
        gsd.append(math.sqrt(max(sgg[c] / NPIX - (sg[c] / NPIX) ** 2, 0.0)))
    mse_rgb = sum(se[:3]) / (3.0 * NPIX); mad_rgb = sum(mad[:3]) / 3.0
    allabs = sorted(absd[0])
    for c in (1, 2):
        allabs = sorted(allabs + list(absd[c]))
    p999_rgb = pct(allabs, 0.999); max_rgb = allabs[-1]
    sd_rgb = math.sqrt(max(sggr / nn - (sgr / nn) ** 2, 0.0))
    rng_rgb = max(gmax[:3]) - min(gmin[:3])
    srt = sorted(px)
    return {'mse': mse, 'mad': mad, 'p999': p999, 'maxabs': maxabs,
            'gmin': gmin, 'gmax': gmax, 'gsd': gsd, 'corr_ch': corr_ch,
            'mse_rgb': mse_rgb, 'mad_rgb': mad_rgb, 'p999_rgb': p999_rgb,
            'max_rgb': max_rgb, 'corr_rgb': corr_rgb, 'corr_luma': corr_luma,
            'sd_rgb': sd_rgb, 'rng_rgb': rng_rgb,
            'p99_px': math.sqrt(srt[int(0.99 * (NPIX - 1))]),
            'tail_px': [v for v in srt[int(0.99 * (NPIX - 1)):]],
            'ident': ident, 'np': False}

def stats(gb, tb):
    try:
        import numpy as np
        G = np.frombuffer(memoryview(gb), dtype='<f4').reshape(NPIX, 4)
        T = np.frombuffer(memoryview(tb), dtype='<f4').reshape(NPIX, 4)
        return stats_np(G, T, G - T)
    except ImportError:
        return stats_py(gb, tb)

def verdict(corr_min):
    if corr_min != corr_min:      # nan
        return 'CORR-NAN?'
    if corr_min >= CORR_SAFE:
        return 'CORR-SAFE(>=0.99)'
    if corr_min >= CORR_REJECT:
        return 'CORR-ONSCREEN-ACCEPT(0.95..0.99)'
    return 'CORR-REJECTED(<0.95)'

def db_verdict(dbr):
    if dbr == float('inf'):
        return 'dB-EXACT'
    if dbr >= DB_SAFE:
        return 'dB-SAFE(>=40)'
    if dbr >= DB_OK:
        return 'dB-OK(>=35)'
    return 'dB-BELOW35'

def report(label, gold, test, s, peak_override=None):
    rng = s['rng_rgb']
    peaks = [s['gmax'][c] - s['gmin'][c] for c in range(4)]
    if peak_override:
        peaks = [peak_override] * 4
        rng = peak_override
    row = {'label': label, 'gold': gold, 'test': test}
    for c, nm in enumerate(CH):
        r = math.sqrt(s['mse'][c])
        row['rmse_' + nm] = r
        row['dBrange_' + nm] = dB(peaks[c], r)
        row['dB01_' + nm] = dB(1.0, r)
        row['corr_' + nm] = s['corr_ch'][c]
        row['mad_sig_' + nm] = s['mad'][c] / s['gsd'][c] if s['gsd'][c] > 0 else float('nan')
        row['p999_sig_' + nm] = s['p999'][c] / s['gsd'][c] if s['gsd'][c] > 0 else float('nan')
        row['maxabs_' + nm] = s['maxabs'][c]
    rr = math.sqrt(s['mse_rgb'])
    row['rmse_RGB'] = rr
    row['dBrange_RGB'] = dB(rng, rr)
    row['dB01_RGB'] = dB(1.0, rr)
    row['corr_RGB'] = s['corr_rgb']
    row['corr_luma'] = s['corr_luma']
    row['mad_sig_RGB'] = s['mad_rgb'] / s['sd_rgb'] if s['sd_rgb'] > 0 else float('nan')
    row['p999_sig_RGB'] = s['p999_rgb'] / s['sd_rgb'] if s['sd_rgb'] > 0 else float('nan')
    row['maxabs_RGB'] = s['max_rgb']
    tail = s['tail_px']
    def dbv(e, peak):
        return float('inf') if e == 0.0 else 20.0 * math.log10(peak / e)
    row['worst1_dBrange_p99'] = dbv(s['p99_px'], rng)
    row['worst1_dBrange_mean'] = (sum(dbv(e, rng) for e in tail) / len(tail)) if tail else float('inf')
    row['worst1_dB01_p99'] = dbv(s['p99_px'], 1.0)
    row['worst1_dB01_mean'] = (sum(dbv(e, 1.0) for e in tail) / len(tail)) if tail else float('inf')
    row['identical'] = s['ident']
    cmins = [row['corr_' + nm] for nm in CH[:3]] + [row['corr_luma']]
    cmins = [v for v in cmins if v == v]
    row['corr_min_RGB'] = min(cmins) if cmins else float('nan')
    row['verdict'] = verdict(row['corr_min_RGB'])
    row['verdict_dB'] = db_verdict(row['dBrange_RGB'])

    def f(x, w=7, p=3):
        if x != x: return ' ' * (w - 3) + 'nan'
        if x == float('inf'): return ' ' * (w - 3) + 'inf'
        return '%*.*f' % (w, p, x)
    print("%-26s corr R=%s G=%s B=%s A=%s | RGBpool=%s luma=%s | %s"
          % (label, f(row['corr_R']), f(row['corr_G']), f(row['corr_B']),
             f(row['corr_A']), f(row['corr_RGB']), f(row['corr_luma']), row['verdict']))
    print("%-26s dB@range RGB=%s (R=%s G=%s B=%s) | dB@[0,1] RGB=%s | %s | %s"
          % ('', f(row['dBrange_RGB'], 6, 2), f(row['dBrange_R'], 6, 2),
             f(row['dBrange_G'], 6, 2), f(row['dBrange_B'], 6, 2),
             f(row['dB01_RGB'], 6, 2), row['verdict_dB'],
             'IDENTICAL' if row['identical'] else ''))
    print("%-26s mean|d|/sigma_gold RGB=%s p99.9=%s | worst1%% dB@range p99=%s mean=%s (dB@[0,1] %s/%s)"
          % ('', f(row['mad_sig_RGB']), f(row['p999_sig_RGB']),
             f(row['worst1_dBrange_p99'], 6, 2), f(row['worst1_dBrange_mean'], 6, 2),
             f(row['worst1_dB01_p99'], 6, 2), f(row['worst1_dB01_mean'], 6, 2)))
    return row, rng

def selftest(gold_path):
    gb = load(gold_path)
    print("== self-test 1: bk vs bk ==")
    s = stats(gb, gb)
    r, rng = report('bk-vs-bk', gold_path, gold_path, s)
    print("   expect inf/IDENTICAL/corr=1 -> dBrange_RGB=%s corr_luma=%.6f ident=%s"
          % ('inf' if r['dBrange_RGB'] == float('inf') else '%.2f' % r['dBrange_RGB'],
             r['corr_luma'], r['identical']))
    print("== self-test 2: synthetic noise sigma=0.5571 (expect 27.89 dB@range / 5.09 dB@[0,1]) ==")
    try:
        import numpy as np
        G = np.frombuffer(memoryview(gb), dtype='<f4').reshape(NPIX, 4).astype('f8')
        rs = np.random.RandomState(20261102)
        noise = rs.normal(0.0, 0.5571, size=G.shape)
        T = (G + noise).astype('<f4')
        tb = array.array('f', T.tobytes())
    except ImportError:
        rs = __import__('random').Random(20261102)
        tb = array.array('f', gb)
        for i in range(len(tb)):
            tb[i] = tb[i] + rs.gauss(0.0, 0.5571)
    s2 = stats(gb, tb)
    r2, _ = report('synth-noise-0.5571', gold_path, '(in-memory)', s2)
    print("   golden RGB sigma=%.4f range=%.4f -> dB scale offset = %.2f"
          % (s2['sd_rgb'], s2['rng_rgb'], 20.0 * math.log10(s2['rng_rgb'])))
    return r, r2

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('gold', nargs='?')
    ap.add_argument('tests', nargs='*')
    ap.add_argument('--csv', default=None)
    ap.add_argument('--cross', action='store_true')
    ap.add_argument('--peak-override', type=float, default=None)
    ap.add_argument('--selftest', action='store_true')
    a = ap.parse_args()
    if a.selftest:
        gp = a.gold or r'E:\DSH\dumps\bk.1301.bin'
        selftest(gp)
        return
    if not a.gold or not a.tests:
        ap.error('need GOLD and at least one TEST dump (or --selftest)')
    print("judge: corr>=%.2f SAFE | %.2f..%.2f on-screen-accept | <%.2f REJECTED ; "
          "dB@range>=%.0f safe / >=%.0f ok (aux). Face range=%.4f => dB@range - dB@[0,1] = %.2f"
          % (CORR_SAFE, CORR_REJECT, CORR_SAFE, CORR_REJECT, DB_SAFE, DB_OK,
             GOLDEN_RGB_RANGE, DB_SCALE_OFFSET))
    gb = load(a.gold)
    print("db_meter: gold=%s  %d B (%dx%d RGBA f32)  md5=%s"
          % (a.gold, NBYTES, W, H, file_md5(a.gold)))
    rows = []
    prev = None
    first = True
    for t in a.tests:
        tb = load(t)
        s = stats(gb, tb)
        row, rng = report(os.path.basename(t), a.gold, t, s, a.peak_override)
        row['md5'] = file_md5(t)
        if first:
            print("          golden per-channel range/sigma: " +
                  "  ".join("%s[%.4f..%.4f] rng=%.4f sd=%.4f"
                            % (CH[c], s['gmin'][c], s['gmax'][c],
                               s['gmax'][c] - s['gmin'][c], s['gsd'][c]) for c in range(4)))
            print("          RGB mixed range=%.4f  RGB sigma=%.4f" % (rng, s['sd_rgb']))
            first = False
        rows.append(row)
        if a.cross and prev is not None:
            s2 = stats(prev[1], tb)
            r2, _ = report("[CROSS %s vs %s]" % (os.path.basename(prev[0]), os.path.basename(t)),
                           prev[0], t, s2, a.peak_override)
            rows.append(r2)
        prev = (t, tb)
    def mn(key):
        vals = [r[key] for r in rows if not r['label'].startswith('[CROSS')]
        fin = [v for v in vals if v != float('inf') and v == v]
        return min(fin) if fin else float('inf')
    nframes = len([r for r in rows if not r['label'].startswith('[CROSS')])
    print("SUMMARY over %d frame-pair(s): worst-frame dB@range RGB=%s  worst-1%% RGB=%s  "
          "min corr=%s (%s)"
          % (nframes,
             ('inf' if mn('dBrange_RGB') == float('inf') else '%.2f' % mn('dBrange_RGB')),
             ('inf' if mn('worst1_dBrange_p99') == float('inf') else '%.2f' % mn('worst1_dBrange_p99')),
             '%.4f' % mn('corr_min_RGB'), verdict(mn('corr_min_RGB'))))
    if a.csv:
        import csv
        with open(a.csv, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader()
            for r in rows:
                w.writerow(r)
        print("wrote", a.csv)

if __name__ == '__main__':
    main()
