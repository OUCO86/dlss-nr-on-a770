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

# ============================ 军规 33（2026-11-02，promote2 铲）============================
# 全局标量（corr / dB / 均值分位数）看不见**局部结构灾难**：T1（1270 面降 e4m3）机器读数
# corr_min 0.9828 / 32.34 dB 全在可接受带，实机却是"彩色大方块"。唯一预警 = A 通道 corr 0.614。
# 所以任何改数值/改面的铲必须再看三样：
#   (a) per-tile 最差 dB（64x64 分块，报 min / p1 / p5，不是均值也不是 p99.9）
#   (b) 平坦区异常检测（低梯度块里 |d| 突增 = 色块/台阶前兆）
#   (c) 逐通道 corr，A/alpha 单独成判（A corr < 0.9 => 必须实机，不许因 RGB 高就放行）
# 另加一条本铲自用：**成片色偏探针**（每块逐通道均值偏移 / golden sigma）——"彩色方块"就是它。
TILE_DEFAULT = 64
A_CORR_MUST_SCREEN = 0.90      # A 通道单判门槛
FLAT_FRAC = 0.20               # 梯度最低的前 20% 块算"平坦区"
TILE_CSV_ROWS = 25             # 最差块打印/导出条数


def tile_metrics(gb, tb, rng, peaks, tile=TILE_DEFAULT):
    """按 tile x tile 分块（边缘允许残缺块）统计最差 dB / 平坦区 / 成片色偏。
       返回 None = 没有 numpy（调用方必须显式打印"未测"，不许静默绿）。"""
    try:
        import numpy as np
    except ImportError:
        return None
    G = np.frombuffer(memoryview(gb), dtype='<f4').reshape(H, W, 4).astype('f8')
    T = np.frombuffer(memoryview(tb), dtype='<f4').reshape(H, W, 4).astype('f8')
    D = G - T
    gsd = [float(G[:, :, c].std()) for c in range(4)]
    tiles = []
    for y in range(0, H, tile):
        y2 = min(H, y + tile)
        for x in range(0, W, tile):
            x2 = min(W, x + tile)
            g = G[y:y2, x:x2, :3]
            d = D[y:y2, x:x2, :3]
            rmse = float(np.sqrt(np.mean(d * d)))
            db = float('inf') if rmse == 0.0 else 20.0 * math.log10(rng / rmse)
            da = D[y:y2, x:x2, 3]
            rmse_a = float(np.sqrt(np.mean(da * da)))
            dba = float('inf') if rmse_a == 0.0 else 20.0 * math.log10(peaks[3] / rmse_a)
            gx = float(np.abs(g[:, 1:, :] - g[:, :-1, :]).mean()) if (x2 - x) > 1 else 0.0
            gy = float(np.abs(g[1:, :, :] - g[:-1, :, :]).mean()) if (y2 - y) > 1 else 0.0
            grad = gx + gy
            # 块内**结构保持率**（军规 33 的"彩色大方块"= 块内方差塌陷/台阶化）：
            # 用 test 自己的梯度能量 / golden 的梯度能量。塌陷 => 该块变成一片纯色 = 眼睛能看见的方块。
            gt = T[y:y2, x:x2, :3]
            tgx = float(np.abs(gt[:, 1:, :] - gt[:, :-1, :]).mean()) if (x2 - x) > 1 else 0.0
            tgy = float(np.abs(gt[1:, :, :] - gt[:-1, :, :]).mean()) if (y2 - y) > 1 else 0.0
            tgrad = tgx + tgy
            keep = (tgrad / grad) if grad > 0 else float('nan')
            shift = max(abs(float(np.mean(D[y:y2, x:x2, c])) / gsd[c]) if gsd[c] > 0 else 0.0
                        for c in range(3))
            tiles.append({'y': y, 'x': x, 'w': x2 - x, 'h': y2 - y, 'db': db, 'dbA': dba,
                          'grad': grad, 'tgrad': tgrad, 'keep': keep,
                          'mad': float(np.mean(np.abs(d))),
                          'maxabs': float(np.max(np.abs(d))), 'shift': shift})
    fin = sorted(t['db'] for t in tiles if t['db'] == float('inf') or t['db'] < float('inf'))
    def q(vals, p):
        if not vals:
            return float('inf')      # 全部块逐位全同 => 分位数记 inf，不许记 nan
        return vals[min(len(vals) - 1, int(p * (len(vals) - 1)))]
    ntile = len(tiles)
    nflat = max(1, int(FLAT_FRAC * ntile))
    flat = sorted(tiles, key=lambda t: t['grad'])[:nflat]
    sharp = sorted(tiles, key=lambda t: -t['grad'])[:nflat]
    gmad = float(np.mean(np.abs(D[:, :, :3])))
    flat_mad = float(np.mean([t['mad'] for t in flat]))
    sharp_mad = float(np.mean([t['mad'] for t in sharp]))
    fin_dbs = [t['db'] for t in tiles if t['db'] != float('inf')]
    keeps = sorted(t['keep'] for t in tiles if t['keep'] == t['keep'])
    worst = sorted(tiles, key=lambda t: (t['db'], -t['shift']))[:TILE_CSV_ROWS]
    worst_keep = sorted(tiles, key=lambda t: t['keep'])[:TILE_CSV_ROWS]
    return {'tile': tile, 'ntiles': ntile,
            'keep_min': (keeps[0] if keeps else float('nan')),
            'keep_p1': q(keeps, 0.01), 'keep_p5': q(keeps, 0.05), 'keep_p50': q(keeps, 0.50),
            'n_keep_lt08': sum(1 for k in keeps if k < 0.8),
            'n_keep_lt06': sum(1 for k in keeps if k < 0.6),
            'n_keep_lt04': sum(1 for k in keeps if k < 0.4),
            'n_keep_gt16': sum(1 for k in keeps if k > 1.6),
            'worst_keep': worst_keep,
            'db_min': (fin_dbs[0] if fin_dbs else float('inf')),
            'db_p1': q(fin_dbs, 0.01), 'db_p5': q(fin_dbs, 0.05),
            'db_p50': q(fin_dbs, 0.50), 'db_max': (fin_dbs[-1] if fin_dbs else float('inf')),
            'n_exact_tiles': sum(1 for t in tiles if t['db'] == float('inf')),
            'n_below40': sum(1 for t in fin_dbs if t < 40.0),
            'n_below35': sum(1 for t in fin_dbs if t < 35.0),
            'n_below30': sum(1 for t in fin_dbs if t < 30.0),
            'n_below25': sum(1 for t in fin_dbs if t < 25.0),
            'n_below20': sum(1 for t in fin_dbs if t < 20.0),
            'dbA_min': min((t['dbA'] for t in tiles if t['dbA'] != float('inf')),
                           default=float('inf')),
            'flat_grad_max': flat[-1]['grad'], 'flat_db_min': min(t['db'] for t in flat),
            'flat_mad': flat_mad, 'sharp_mad': sharp_mad, 'global_mad': gmad,
            'flat_over_global': (flat_mad / gmad if gmad > 0 else float('nan')),
            'flat_over_sharp': (flat_mad / sharp_mad if sharp_mad > 0 else float('nan')),
            'shift_max': max(t['shift'] for t in tiles),
            'n_shift_gt1': sum(1 for t in tiles if t['shift'] > 1.0),
            'n_shift_gt05': sum(1 for t in tiles if t['shift'] > 0.5),
            'worst': worst}


def print_tile_metrics(label, m):
    if m is None:
        print("%-26s 军规33 per-tile: **未测（无 numpy）** => 这一栏不许当绿" % label)
        return
    print("%-26s 军规33 per-tile(%d): dB@range min=%s p1=%s p5=%s p50=%s max=%s | "
          "块数=%d(其中逐位全同=%d) <40:%d <35:%d <30:%d <25:%d <20:%d"
          % (label, m['tile'], '%.2f' % m['db_min'], '%.2f' % m['db_p1'], '%.2f' % m['db_p5'],
             '%.2f' % m['db_p50'], '%.2f' % m['db_max'], m['ntiles'], m['n_exact_tiles'],
             m['n_below40'], m['n_below35'], m['n_below30'], m['n_below25'], m['n_below20']))
    print("%-26s   平坦区(最低20%%梯度, grad<=%.4f): dB_min=%s mean|d|=%.4f | 陡峭区 mean|d|=%.4f "
          "| 平坦/全域=%.3f 平坦/陡峭=%.3f  %s"
          % ('', m['flat_grad_max'], ('inf' if m['flat_db_min'] == float('inf') else '%.2f' % m['flat_db_min']),
             m['flat_mad'], m['sharp_mad'], m['flat_over_global'], m['flat_over_sharp'],
             'FLAT-ANOMALY(平坦区误差反而大 = 色块/台阶前兆)'
             if (m['flat_over_global'] > 1.5 and m['flat_over_sharp'] > 1.5) else 'flat-ok'))
    print("%-26s   成片色偏(每块逐通道均值偏移/golden sigma): max=%.3f  >1.0sigma 的块=%d  >0.5sigma=%d  %s"
          % ('', m['shift_max'], m['n_shift_gt1'], m['n_shift_gt05'],
             'BLOCK-TINT RISK' if m['n_shift_gt1'] > 0 else 'no coherent block tint'))
    print("%-26s   ★结构保持率(块内梯度 test/golden, 彩色方块=塌陷): min=%s p1=%s p5=%s p50=%s | "
          "<0.8:%d <0.6:%d <0.4:%d(块内结构塌光=眼睛可见方块) >1.6:%d(凭空长出结构=锯齿)  %s"
          % ('', '%.3f' % m['keep_min'], '%.3f' % m['keep_p1'], '%.3f' % m['keep_p5'],
             '%.3f' % m['keep_p50'], m['n_keep_lt08'], m['n_keep_lt06'], m['n_keep_lt04'],
             m['n_keep_gt16'],
             'BLOCK-COLLAPSE RISK' if m['n_keep_lt06'] > 0 else 'no block collapse'))
    print("%-26s   塌陷最狠 5 块: %s"
          % ('', '  '.join('(y=%d,x=%d keep=%.3f dB=%s)'
                           % (t['y'], t['x'], t['keep'],
                              'inf' if t['db'] == float('inf') else '%.1f' % t['db'])
                           for t in m['worst_keep'][:5])))
    print("%-26s   A 通道单判: dB@range(min over tiles)=%s | 最差 %d 块:"
          % ('', ('inf' if m['dbA_min'] == float('inf') else '%.2f' % m['dbA_min']), len(m['worst'])))
    for t in m['worst'][:10]:
        print("        tile y=%3d x=%3d %dx%d  dB=%8s  dB_A=%8s  grad=%.4f  mean|d|=%.4f  max|d|=%.4f  shift=%.3f"
              % (t['y'], t['x'], t['w'], t['h'],
                 'inf' if t['db'] == float('inf') else '%.2f' % t['db'],
                 'inf' if t['dbA'] == float('inf') else '%.2f' % t['dbA'],
                 t['grad'], t['mad'], t['maxabs'], t['shift']))


# ===================== judge40 铲（2026-11-02）：块退化探针并入一栏 =====================
# §45 缺口二：军规 33 的 (a)(b) 两栏抓不住 **T1 型灾难**（被眼睛否决的 T1 在 per-tile dB / 色偏 /
# 塌陷三栏上比被接受的 T2 还好看）。tools/block_collapse.py 按"块内塌陷 + 误差场成片/台阶化"
# 建模（逐通道 R/G/B/A + RGB，尺度 16/32/64/128）。db_meter 跑画质判据时自动带上这一栏。
# 判决权仍在用户眼睛（军规 33 (d)）：BLOCK-REJECT => 不许转正；BLOCK-WARN => 必须实机。
BLOCK_KEYS = ('C1_A_ts64_lt05_pct', 'C1_A_ts128_lt05_pct', 'C1_RGB_ts64_lt05_pct',
              'C1_RGB_ts128_lt05_pct', 'C2_levels_frac_min', 'C2_nzfrac_min',
              'C3_p64_A_x_ratio', 'C3_p64_A_y_ratio', 'C3_p64_R_x_ratio', 'C3_p128_A_x_ratio',
              'C4_A_ts64_blockiness', 'C4_A_ts128_blockiness', 'C4_A_ts16_segconst',
              'C4_A_ts64_maxblockmad', 'C4_RGB_ts128_blockiness',
              'C5_A_rms', 'C5_A_rho64', 'C5_A_rho128', 'C5_A_coh_len', 'C5_A_L_int',
              'C5_RGB_rho64', 'C5_RGB_rho128', 'C5_RGB_coh_len', 'C5_A_rel')


def block_probe_report(label, gb, tb):
    """返回 block_collapse.probe() 的扁平字典；无 numpy / 无工具 => None（调用方必须显式打未测）。"""
    try:
        import numpy as _np
    except ImportError:
        print("%-26s 块退化探针(block_collapse): **未测（无 numpy）** => 这一栏不许当绿" % label)
        return None
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import block_collapse as _bc
    except ImportError as e:
        print("%-26s 块退化探针: 导入失败(%s) => **未测**" % (label, e))
        return None
    G = _np.frombuffer(memoryview(gb), dtype='<f4').reshape(_bc.H, _bc.W, 4)
    T = _np.frombuffer(memoryview(tb), dtype='<f4').reshape(_bc.H, _bc.W, 4)
    r = _bc.probe(G, T)
    print("%-26s 块退化探针(judge40): %s" % (label, r['verdict_block']))
    print("%-26s   C1 块内方差坍缩(<0.5 块占比%%): A@64=%.2f A@128=%.2f RGB@64=%.2f RGB@128=%.2f | "
          "C2 levels_min=%.4f nz_min=%.4f | C3 网格比 p64: A x=%.3f y=%.3f R x=%.3f | p128 A x=%.3f"
          % ('', r['C1_A_ts64_lt05_pct'], r['C1_A_ts128_lt05_pct'], r['C1_RGB_ts64_lt05_pct'],
             r['C1_RGB_ts128_lt05_pct'], r['C2_levels_frac_min'], r['C2_nzfrac_min'],
             r['C3_p64_A_x_ratio'], r['C3_p64_A_y_ratio'], r['C3_p64_R_x_ratio'], r['C3_p128_A_x_ratio']))
    print("%-26s   C4 误差场台阶化(A): blk@64=%.3f blk@128=%.3f seg@16=%.3f mad64=%.2f | RGB blk@128=%.3f | "
          "C5 A(rms=%.3f rel=%.3f): rho64=%.3f rho128=%.3f coh_len=%.0f L_int=%.1f | RGB: rho64=%.3f rho128=%.3f coh=%.0f"
          % ('', r['C4_A_ts64_blockiness'], r['C4_A_ts128_blockiness'], r['C4_A_ts16_segconst'],
             r['C4_A_ts64_maxblockmad'], r['C4_RGB_ts128_blockiness'],
             r['C5_A_rms'], r['C5_A_rel'], r['C5_A_rho64'], r['C5_A_rho128'], r['C5_A_coh_len'],
             r['C5_A_L_int'], r['C5_RGB_rho64'], r['C5_RGB_rho128'], r['C5_RGB_coh_len']))
    return r


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

def report(label, gold, test, s, peak_override=None, gb=None, tb=None, tile=TILE_DEFAULT, block=True):
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
    # ---- 军规 33：A 通道单独成判 + per-tile 三样 ----
    ca = row['corr_A']
    row['A_gate'] = ('A-CORR-NAN' if ca != ca else
                     ('A-CORR-MUST-SCREEN(<%.2f)' % A_CORR_MUST_SCREEN if ca < A_CORR_MUST_SCREEN
                      else 'A-gate-ok'))
    print("%-26s A 通道单判: corr_A=%s => %s" % ('', f(row['corr_A'], 6, 4), row['A_gate']))
    m = None
    if tile and gb is not None and tb is not None:
        m = tile_metrics(gb, tb, rng, peaks, tile)
        print_tile_metrics(label, m)
        if m is not None:
            for k in ('db_min', 'db_p1', 'db_p5', 'db_p50', 'db_max', 'dbA_min', 'n_exact_tiles',
                      'n_below40', 'n_below35', 'n_below30', 'n_below25', 'n_below20',
                      'keep_min', 'keep_p1', 'keep_p5', 'keep_p50',
                      'n_keep_lt08', 'n_keep_lt06', 'n_keep_lt04', 'n_keep_gt16',
                      'flat_db_min', 'flat_mad', 'flat_over_global', 'flat_over_sharp',
                      'shift_max', 'n_shift_gt1', 'n_shift_gt05'):
                row['tile_' + k] = m[k]
    elif tile:
        print("%-26s 军规33 per-tile: 调用方没传原始 buffer => 未测" % label)
    row['_tile'] = m
    # ---- judge40 铲：块退化探针（C1 塌陷 / C2 等级 / C3 网格 / C4 误差场台阶 / C5 误差场相关）----
    bm = None
    if block and gb is not None and tb is not None:
        bm = block_probe_report(label, gb, tb)
        if bm is not None:
            for k in BLOCK_KEYS:
                row['blk_' + k] = bm[k]
            row['blk_verdict'] = bm['verdict_block']
        else:
            row['blk_verdict'] = 'NOT-MEASURED(无 numpy/无工具)'
    elif block:
        print("%-26s 块退化探针: 调用方没传原始 buffer => 未测" % label)
        row['blk_verdict'] = 'NOT-MEASURED(no buffer)'
    row['_block'] = bm
    return row, rng

def selftest(gold_path):
    gb = load(gold_path)
    print("== self-test 1: bk vs bk ==")
    s = stats(gb, gb)
    r, rng = report('bk-vs-bk', gold_path, gold_path, s, gb=gb, tb=gb)
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
    r2, _ = report('synth-noise-0.5571', gold_path, '(in-memory)', s2, gb=gb, tb=tb)
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
    ap.add_argument('--tile', type=int, default=TILE_DEFAULT,
                    help='军规33 per-tile 分块边长（默认 64；544 不整除 => 边缘残缺块）')
    ap.add_argument('--no-tile', dest='tile', default=None, action='store_const', const=0,
                    help='关掉 per-tile 三样（不许用它出转正结论）')
    ap.add_argument('--tile-csv', default=None, help='最差块逐条导出 CSV')
    ap.add_argument('--no-block', dest='block', action='store_false', default=True,
                    help='关掉 judge40 块退化探针（不许用它出转正结论）')
    ap.add_argument('--selftest', action='store_true')
    a = ap.parse_args()
    if a.selftest:
        gp = a.gold or r'E:\DSH\dumps\bk.1301.bin'
        selftest(gp)
        return
    if a.tile is None:
        a.tile = TILE_DEFAULT
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
        row, rng = report(os.path.basename(t), a.gold, t, s, a.peak_override,
                          gb=gb, tb=tb, tile=a.tile, block=a.block)
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
                           prev[0], t, s2, a.peak_override, gb=prev[1], tb=tb, tile=a.tile,
                           block=a.block)
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
    # 军规 33 汇总：最差 per-tile dB + A 通道单判 + 平坦区/色偏计数
    tmin = [r['tile_db_min'] for r in rows if 'tile_db_min' in r and r['tile_db_min'] != float('inf')]
    avals = [r['corr_A'] for r in rows if r.get('corr_A') == r.get('corr_A')]
    if tmin:
        print("SUMMARY 军规33: per-tile dB@range 最差=%.2f  p1 最差=%.2f  p5 最差=%.2f | "
              "<30dB 块最多=%d  <20dB 块最多=%d | 平坦区异常帧=%d  成片色偏块>1sigma 最多=%d | "
              "结构保持率 min=%.3f  <0.6 塌陷块最多=%d  <0.4=%d | "
              "corr_A 最低=%.4f => %s"
              % (min(tmin),
                 min(r['tile_db_p1'] for r in rows if 'tile_db_p1' in r),
                 min(r['tile_db_p5'] for r in rows if 'tile_db_p5' in r),
                 max(r['tile_n_below30'] for r in rows if 'tile_n_below30' in r),
                 max(r['tile_n_below20'] for r in rows if 'tile_n_below20' in r),
                 sum(1 for r in rows if r.get('tile_flat_over_global', 0) > 1.5
                     and r.get('tile_flat_over_sharp', 0) > 1.5),
                 max(r.get('tile_n_shift_gt1', 0) for r in rows if 'tile_n_shift_gt1' in r),
                 min((r.get('tile_keep_min', float('nan')) for r in rows
                      if r.get('tile_keep_min', None) is not None), default=float('nan')),
                 max(r.get('tile_n_keep_lt06', 0) for r in rows if 'tile_n_keep_lt06' in r),
                 max(r.get('tile_n_keep_lt04', 0) for r in rows if 'tile_n_keep_lt04' in r),
                 min(avals) if avals else float('nan'),
                 'A-MUST-SCREEN' if (avals and min(avals) < A_CORR_MUST_SCREEN) else 'A-ok'))
    else:
        print("SUMMARY 军规33: per-tile **未测** => 这一栏缺了就不许下转正结论（军规 33）")
    # ---- judge40 铲：块退化探针汇总 ----
    bc = {}
    for r in rows:
        v = r.get('blk_verdict', 'NOT-MEASURED')
        k = v.split('(')[0].split('[')[0].strip()
        bc[k] = bc.get(k, 0) + 1
    print("SUMMARY judge40 块退化探针: " + '  '.join("%s=%d" % kv for kv in sorted(bc.items())) +
          "  （BLOCK-REJECT => 不许转正；BLOCK-WARN => 必须实机；眼睛一票否决权不变）")
    if a.tile_csv:
        import csv
        cols = ['label', 'rank_by', 'y', 'x', 'w', 'h', 'db', 'dbA', 'grad', 'tgrad', 'keep',
                'mad', 'maxabs', 'shift']
        with open(a.tile_csv, 'w', newline='', encoding='utf-8') as f:
                w = csv.DictWriter(f, fieldnames=cols, restval='', extrasaction='ignore')
                w.writeheader()
                for r in rows:
                    m = r.get('_tile')
                    if not m: continue
                    for (rank, lst) in (('db', m['worst']), ('keep', m['worst_keep'])):
                        for t in lst:
                            d = dict(t)
                            d['label'] = r['label']; d['rank_by'] = rank
                            w.writerow(d)
        print("wrote", a.tile_csv, "(worst %d tiles per frame, 两种排名: dB / 结构保持率)" % TILE_CSV_ROWS)
    if a.csv:
        import csv
        # 修仪器 bug（本次逮到）：--cross 的 CROSS 行没有 row['md5']，旧写法取 rows[0].keys()
        # => KeyError: 'md5'。改成"所有行的键并集（保序）+ 缺项留空"。
        cols = list(dict.fromkeys(k for r in rows for k in r.keys() if not k.startswith('_')))
        with open(a.csv, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=cols, restval='', extrasaction='ignore')
            w.writeheader()
            for r in rows:
                w.writerow(r)
        print("wrote", a.csv, "(%d cols)" % len(cols))

if __name__ == '__main__':
    main()
