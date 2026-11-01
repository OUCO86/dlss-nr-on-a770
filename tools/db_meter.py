#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
db_meter.py -- the new judge (notes/B2-blueprint-to-10ms.md 军规 0 修订, 2026-11-02):
PSNR / RMSE / worst-1%-pixel dB of a dumped frame face against the vendor golden,
replacing the "1301 bit-EXACT" gate. The gate numbers (>=40 dB safe, >=35 dB acceptable)
come from the lmxx hip-port, whose compared face is the clamped [0,1] network picture.
Our buffer-1301 face is NOT [0,1] (it spans about -7.8 .. +47.9), so dB is reported on
BOTH scales and the SCALE-INVARIANT one (peak = golden's own dynamic range) is the one to
read against the 40/35 dB gate:

  dB@range = 20*log10((max-min of the golden channel) / RMSE)     <- gate-comparable
  dB@1     = 20*log10(1.0 / RMSE)                                  <- raw, lmxx-style peak

Dump format (checked against bk.1301.bin): 960x544 RGBA float32 little-endian,
522,240 px x 16 B = 8,355,840 B. Anything else = parse error (exit 2).

Metrics per comparison:
  per-channel R/G/B/A: RMSE, dB@range, dB@1, maxabs
  RGB mean:            RMSE, dB@range, dB@1, maxabs
  worst-1% pixels:     per-pixel RGB RMSE; dB@range at the 99th percentile and the mean
                       dB over that worst 1%
  identical            bit-for-bit (md5-equal) -> inf
Multi-frame: pass several test dumps; the summary prints worst-frame dB = min over frames.
--cross also compares consecutive test dumps: the flicker proxy (same config, two
processes). If cross-process dB << golden dB the config flickers -> void it.

Usage:
  py tools/db_meter.py GOLD A [B C ...] [--csv out.csv] [--cross] [--peak-override P]
"""
import sys, os, math, array, argparse, hashlib

W, H = 960, 544
NPIX = W * H
NBYTES = NPIX * 16          # 8,355,840
CH = ['R', 'G', 'B', 'A']

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

def md5_of_bytes(b):
    return hashlib.md5(b).hexdigest()

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

def stats(gb, tb):
    """gb/tb: array('f') of length NPIX*4. Returns dict of raw sums (scale-free)."""
    try:
        import numpy as np
        G = np.frombuffer(memoryview(gb), dtype='<f4').reshape(NPIX, 4)
        T = np.frombuffer(memoryview(tb), dtype='<f4').reshape(NPIX, 4)
        d = G - T
        mse = np.mean(d * d, axis=0)                        # per channel
        maxabs = np.max(np.abs(d), axis=0)
        gmin = np.min(G, axis=0); gmax = np.max(G, axis=0)
        rgb_mse = float(np.mean(d[:, :3] * d[:, :3]))
        px = np.sqrt(np.mean(d[:, :3] * d[:, :3], axis=1))  # per-pixel RGB rmse
        srt = np.sort(px)
        p99 = float(srt[int(0.99 * (NPIX - 1))])
        tail = srt[int(0.99 * (NPIX - 1)):]
        ident = bool(np.array_equal(G, T))
        return {'mse': [float(x) for x in mse], 'maxabs': [float(x) for x in maxabs],
                'gmin': [float(x) for x in gmin], 'gmax': [float(x) for x in gmax],
                'rgb_mse': rgb_mse, 'rgb_maxabs': float(np.max(np.abs(d[:, :3]))),
                'p99': p99, 'tail': tail.tolist(), 'ident': ident, 'np': True}
    except ImportError:
        pass
    se = [0.0] * 4
    ma = [0.0] * 4
    gmin = [float('inf')] * 4
    gmax = [float('-inf')] * 4
    px = array.array('d', bytes(8 * NPIX))
    n = len(gb)
    k = 0
    i = 0
    ident = True
    while i < n:
        for c in range(4):
            gv = gb[i + c]; tv = tb[i + c]
            if gv != tv:
                ident = False
            if gv < gmin[c]: gmin[c] = gv
            if gv > gmax[c]: gmax[c] = gv
            e = gv - tv
            ae = -e if e < 0 else e
            if ae > ma[c]: ma[c] = ae
            se[c] += e * e
        px[k] = (se[0] * 0 + (gb[i] - tb[i]) ** 2 + (gb[i + 1] - tb[i + 1]) ** 2 +
                 (gb[i + 2] - tb[i + 2]) ** 2) / 3.0
        k += 1
        i += 4
    lst = sorted(px)
    p99 = math.sqrt(lst[int(0.99 * (NPIX - 1))])
    tail = [math.sqrt(e) for e in lst[int(0.99 * (NPIX - 1)):]]
    return {'mse': [s / NPIX for s in se], 'maxabs': ma, 'gmin': gmin, 'gmax': gmax,
            'rgb_mse': (se[0] + se[1] + se[2]) / (3.0 * NPIX),
            'rgb_maxabs': max(ma[:3]), 'p99': p99, 'tail': tail, 'ident': ident, 'np': False}

def report(label, gold, test, s, peak_override=None):
    rgb_range = max(s['gmax'][c] for c in range(3)) - min(s['gmin'][c] for c in range(3))
    peaks = [ (s['gmax'][c] - s['gmin'][c]) for c in range(4) ]
    if peak_override:
        peaks = [peak_override] * 4
        rgb_range = peak_override
    row = {'label': label, 'gold': gold, 'test': test}
    for c, nm in enumerate(CH):
        r = math.sqrt(s['mse'][c])
        row['rmse_' + nm] = r
        row['dBrange_' + nm] = dB(peaks[c], r)
        row['dB1_' + nm] = dB(1.0, r)
        row['maxabs_' + nm] = s['maxabs'][c]
    rr = math.sqrt(s['rgb_mse'])
    row['rmse_RGB'] = rr
    row['dBrange_RGB'] = dB(rgb_range, rr)
    row['dB1_RGB'] = dB(1.0, rr)
    row['maxabs_RGB'] = s['rgb_maxabs']
    tail = s['tail']
    def dbv(e):
        return float('inf') if e == 0.0 else 20.0 * math.log10(rgb_range / e)
    row['worst1_dBrange_p99'] = dbv(s['p99'])
    vals = [dbv(e) for e in tail]
    fin = [v for v in vals if v != float('inf')]
    row['worst1_dBrange_mean'] = (sum(fin) / len(fin)) if fin else float('inf')
    row['identical'] = s['ident']
    def f(x, w=8, p=2):
        if x == float('inf'): return ' ' * (w - 3) + 'inf'
        return '%*.*f' % (w, p, x)
    print("%-30s" % label,
          " dB@range R=%s G=%s B=%s | RGB=%s | dB@1 RGB=%s | RMSE_RGB=%.6f maxabs=%.6f"
          " | worst1%%=%s (mean %s) | %s"
          % (f(row['dBrange_R']), f(row['dBrange_G']), f(row['dBrange_B']),
             f(row['dBrange_RGB']), f(row['dB1_RGB']), row['rmse_RGB'], row['maxabs_RGB'],
             f(row['worst1_dBrange_p99']), f(row['worst1_dBrange_mean']),
             'IDENTICAL' if row['identical'] else ''))
    return row, rgb_range

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('gold')
    ap.add_argument('tests', nargs='+')
    ap.add_argument('--csv', default=None)
    ap.add_argument('--cross', action='store_true')
    ap.add_argument('--peak-override', type=float, default=None)
    a = ap.parse_args()
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
        if first:
            print("          golden per-channel range: " +
                  "  ".join("%s[%.4f..%.4f]=%.4f" % (CH[c], s['gmin'][c], s['gmax'][c],
                                                     s['gmax'][c] - s['gmin'][c])
                            for c in range(4)))
            print("          RGB dynamic range (dB@range peak) = %.4f" % rng)
            first = False
        rows.append(row)
        if a.cross and prev is not None:
            s2 = stats(prev[1], tb)
            rows.append(report("[CROSS %s vs %s]" % (os.path.basename(prev[0]),
                                                     os.path.basename(t)),
                               prev[0], t, s2, a.peak_override)[0])
        prev = (t, tb)
    # worst-frame summary (multi-frame judge)
    def mn(key):
        vals = [r[key] for r in rows if not r['label'].startswith('[CROSS')]
        fin = [v for v in vals if v != float('inf')]
        return min(fin) if fin else float('inf')
    print("SUMMARY over %d frame-pair(s): worst-frame dB@range RGB=%s  worst-1%% RGB=%s"
          % (len([r for r in rows if not r['label'].startswith('[CROSS')]),
             ('inf' if mn('dBrange_RGB') == float('inf') else '%.2f' % mn('dBrange_RGB')),
             ('inf' if mn('worst1_dBrange_p99') == float('inf') else '%.2f' % mn('worst1_dBrange_p99'))))
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
