#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
block_collapse.py -- "块退化"探针（T1 型灾难探测器）。judge40 铲，2026-11-02。
================================================================================
为什么另起一把（notes/DS-takeover-2026-11-01.md §45 缺口二）：
  军规 33 的 per-tile dB / 成片色偏 / 结构保持率三栏在牙齿对照里**没有分离力**：
  被眼睛否决的 T1 读数（dB min 34.80 / 色偏 0.316σ / 塌陷 0 块）比被接受的 T2
  （28.85 / 0.375σ / 0 块）还"好看"；唯一与眼睛同序的是 corr_A（T1 0.614 < T2 0.773）。
  => 本探针不测"误差有多大"，测"误差有多**方块化**"。

五个统计（全部逐通道 R/G/B/A + RGB 联合）：
  C1 块内方差坍缩比  var(test)/var(golden) 逐块：报 <0.2%%/<0.5%% 占比 + min/p1/p5/p50
  C2 块内有效等级数  每块不同量化值个数（量化 1e-4）/ 像素数，以及相邻差非零比例
  C3 块边界台阶能量  沿 p=64/128 网格的 mean|Δ| / 非网格位置 mean|Δ|（test 与 golden 各算，再比）
  C4 误差场分段常数度  D=test-golden：segconst = 块内方差均值/全图方差（iid≈1，成片<<1）；
                      blockiness = mean|块均值跳变| / mean|块内相邻差|（台阶化 => 大）
  C5 误差场空间自相关  rho_D(lag) 沿 x 与 y，lag=1/64/128/256；
                      coh_len = rho>=0.5 的最大 lag；L_int = 积分相关长度（到 256）
                      —— **这是本探针唯一有牙的一栏**（T1 与 T2 的 A 误差幅度几乎相同
                         rms 7.17 vs 6.92，但 T1 的 A 误差在 256 px 上仍相关 0.57，T2 只有 0.21）。

标定纪律（写死，不许调阈值凑）：
  * 自比（同文件、同件两进程）必须 0 假阳；
  * 合成对照必须双向：块化扰动（同幅度）=> 红；iid 噪声（**同 rms**）=> 不红；
  * T1（否决）红、T2（接受）不红，两侧都要留余量；
  * 做不到分离的统计在 verdict 里写 NO-SEPARATION 并给出两侧读数。
用法:
  py tools/block_collapse.py GOLD TEST [TEST ...] [--ts 64] [--csv out.csv] [--pairs]
  py tools/block_collapse.py --synth GOLD          # 合成正/负对照（不需要 test）
"""
import sys, os, math, argparse, hashlib
import numpy as np

W, H = 960, 544
CH = ['R', 'G', 'B', 'A']
TS_MAIN = 64
TS_SWEEP = (16, 32, 64, 128)
GRID_P = (64, 128)
LEVEL_QUANT = 4
GVAR_EPS = 1e-9
COH_LAGS = (1, 64, 128, 256)

# ---- 阈值（2026-11-02 标定：T1 否决 / T2 接受 / 合成块化 / 合成 iid；rho = x/y 两向平均）----
TH = {
    # (A) 块内结构塌陷：C1 逐尺度，占比阈值
    'C1_lt05_pct_ts64':  3.0,   # T1 4.17% 红 / T2 2.50% 绿
    'C1_lt05_pct_ts128': 6.0,   # T1 10.71% 红 / T2 3.57% 绿  （余量最大的一栏）
    'C1_lt05_pct_ts32':  3.0,   # T1 0.78% / T2 0.20%
    'C1_lt05_pct_ts16':  3.0,   # T1 0.44% / T2 0.98%  <= 注意：ts16 上 T2 反而更高 => ts16 只作辅助
    'C1_min':            0.10,  # 或：有块塌到 <0.10 且 <0.2 的块占比 >=1%
    'C1_lt02_pct':       1.0,
    # (B) 误差场成片/台阶化（A 通道）
    'A_coh64':   0.45,   # rho(lag64):  T1 0.550 / T2 0.309
    'A_coh128':  0.28,   # rho(lag128): T1 0.373 / T2 0.184
    'A_coh256':  0.30,   # rho(lag256): T1 0.156 / T2 0.155  => **无分离力**（见 NO-SEPARATION 记录）
    'A_cohlen':  32.0,   # coh_len:     T1 64 / T2 1
    'A_Lint':    65.0,   # 积分相关长度: T1 79.4 / T2 51.9
    'A_blk128':  1.20,   # C4 blockiness(ts128): T1 1.508 / T2 0.787
    'A_blk64':   1.20,   # C4 blockiness(ts64):  T1 1.292 / T2 0.770
    'A_seg16':   0.25,   # C4 segconst(ts16):    T1 0.181 / T2 0.377（反向：T1 更成片）
    'A_cohlen':  48.0,   # coh_len: T1 64 / T2 1 / skip 族 8..32
    'A_Lint':    65.0,   # 积分相关长度: T1 79.4 / T2 51.9
    'A_madsig':  0.40,   # C4 maxblockmad(ts64)/golden rms: T1 0.45 / T2 0.32
    # (C) RGB 同族（本轮 T1/T2 在 RGB 上**无分离力** => 阈值取自合成对照，见 judge40.md）
    'RGB_coh64': 0.55, 'RGB_coh128': 0.45, 'RGB_cohlen': 48.0, 'RGB_Lint': 90.0,
    'RGB_blk64': 1.20, 'RGB_blk128': 1.20, 'RGB_seg16': 0.25, 'RGB_madsig': 0.45,
    # (D) 幅度地板：低于它，该通道"成片"判据不适用
    'D_AMP_FLOOR': 0.02,
}


def load(path):
    a = np.fromfile(path, dtype='<f4')
    if a.size != W * H * 4:
        sys.stderr.write("block_collapse: %s has %d floats, expected %d (960x544 RGBA f32)\n"
                         % (path, a.size, W * H * 4))
        sys.exit(2)
    return a.reshape(H, W, 4)


def md5(path):
    h = hashlib.md5()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def _blk(a, ts, c):
    ny, nx = H // ts, W // ts
    return a[:ny * ts, :nx * ts, c].reshape(ny, ts, nx, ts).transpose(0, 2, 1, 3)


def _blkrgb(a, ts):
    ny, nx = H // ts, W // ts
    return a[:ny * ts, :nx * ts, :3].reshape(ny, ts, nx, ts, 3).transpose(0, 2, 1, 3, 4)


# ---------------- C1 ----------------
def c1_variance_collapse(G, T, ts):
    out = {}
    for c in range(4):
        gb, tb = _blk(G, ts, c), _blk(T, ts, c)
        vg, vt = gb.var(axis=(2, 3)), tb.var(axis=(2, 3))
        m = vg > GVAR_EPS
        out[CH[c]] = vt[m] / vg[m]
    g, t = _blkrgb(G, ts), _blkrgb(T, ts)
    vg, vt = g.var(axis=(2, 3, 4)), t.var(axis=(2, 3, 4))
    m = vg > GVAR_EPS
    out['RGB'] = vt[m] / vg[m]
    return out


# ---------------- C2 ----------------
def c2_levels(G, T, ts):
    out = {}
    lv, nz = [], []
    npx = float(ts * ts)
    for c in range(4):
        b = _blk(T, ts, c)
        flat = np.round(b.reshape(b.shape[0], b.shape[1], -1), LEVEL_QUANT)
        for i in range(flat.shape[0]):
            for j in range(flat.shape[1]):
                lv.append(len(np.unique(flat[i, j])) / npx)
        dxh = np.diff(b, axis=3) != 0
        dyv = np.diff(b, axis=2) != 0
        for i in range(b.shape[0]):
            for j in range(b.shape[1]):
                nz.append(0.5 * (dxh[i, j].mean() + dyv[i, j].mean()))
    out['levels_frac'] = np.array(lv)
    out['nzfrac'] = np.array(nz)
    return out


# ---------------- C3 ----------------
def c3_grid_energy(G, T, p):
    res = {}
    xs = np.arange(W - 1); ys = np.arange(H - 1)
    bx = (xs + 1) % p == 0; by = (ys + 1) % p == 0
    for c in range(4):
        dtx = np.abs(np.diff(T[:, :, c], axis=1)); dgx = np.abs(np.diff(G[:, :, c], axis=1))
        dty = np.abs(np.diff(T[:, :, c], axis=0)); dgy = np.abs(np.diff(G[:, :, c], axis=0))
        tx = dtx[:, bx].mean() / max(dtx[:, ~bx].mean(), 1e-12)
        gx = dgx[:, bx].mean() / max(dgx[:, ~bx].mean(), 1e-12)
        ty = dty[by, :].mean() / max(dty[~by, :].mean(), 1e-12)
        gy = dgy[by, :].mean() / max(dgy[~by, :].mean(), 1e-12)
        res[CH[c] + '_x'] = (float(tx), float(gx), float(tx / max(gx, 1e-9)))
        res[CH[c] + '_y'] = (float(ty), float(gy), float(ty / max(gy, 1e-9)))
    return res


# ---------------- C4 ----------------
def c4_error_field(G, T, ts):
    D = T - G
    out = {}
    for c in range(4):
        b = _blk(D, ts, c)
        vg = float(D[:, :, c].var()); vw = float(b.var(axis=(2, 3)).mean())
        inner = 0.5 * (float(np.abs(np.diff(b, axis=3)).mean()) +
                       float(np.abs(np.diff(b, axis=2)).mean()))
        bm = b.mean(axis=(2, 3))
        jump = 0.5 * (float(np.abs(np.diff(bm, axis=1)).mean()) +
                      float(np.abs(np.diff(bm, axis=0)).mean()))
        ginner = 0.5 * (float(np.abs(np.diff(G[:, :, c], axis=1)).mean()) +
                        float(np.abs(np.diff(G[:, :, c], axis=0)).mean()))
        out[CH[c]] = {'segconst': (vw / vg if vg > GVAR_EPS else float('nan')),
                      'blockiness': (jump / inner if inner > 1e-12 else float('nan')),
                      'amp': float(np.abs(b).mean()),
                      'flatrel': (inner / ginner if ginner > 1e-12 else float('nan')),
                      'maxblockmad': float(np.abs(b).mean(axis=(2, 3)).max())}
    # RGB 联合（三通道一起看：彩色大方块在 RGB 上的合成表现）
    bg, bt = _blkrgb(G, ts), _blkrgb(T, ts)
    b = bt - bg
    vg = float(D[:, :, :3].var()); vw = float(b.var(axis=(2, 3, 4)).mean())
    inner = 0.5 * (float(np.abs(np.diff(b, axis=3)).mean()) + float(np.abs(np.diff(b, axis=2)).mean()))
    bm = b.mean(axis=(2, 3, 4))
    jump = 0.5 * (float(np.abs(np.diff(bm, axis=1)).mean()) + float(np.abs(np.diff(bm, axis=0)).mean()))
    ginner = 0.5 * (float(np.abs(np.diff(G[:, :, :3], axis=1)).mean()) +
                    float(np.abs(np.diff(G[:, :, :3], axis=0)).mean()))
    out['RGB'] = {'segconst': (vw / vg if vg > GVAR_EPS else float('nan')),
                  'blockiness': (jump / inner if inner > 1e-12 else float('nan')),
                  'amp': float(np.abs(b).mean()),
                  'flatrel': (inner / ginner if ginner > 1e-12 else float('nan')),
                  'maxblockmad': float(np.abs(b).mean(axis=(2, 3, 4)).max())}
    return out


# ---------------- C5 ----------------
def _rho(d, lag, axis):
    if axis == 1:
        a, b = d[:, :W - lag], d[:, lag:]
    else:
        a, b = d[:H - lag, :], d[lag:, :]
    a = a - a.mean(); b = b - b.mean()
    den = math.sqrt(float((a * a).sum()) * float((b * b).sum()))
    return float((a * b).sum() / den) if den > 1e-12 else float('nan')


def c5_autocorr(G, T, lags=COH_LAGS):
    D = T - G
    out = {}
    for c in range(4):
        d = D[:, :, c]
        rms = float(np.sqrt((d * d).mean()))
        grms = float(np.sqrt((G[:, :, c] - G[:, :, c].mean()).var() + G[:, :, c].mean() ** 2))
        rx = [_rho(d, L, 1) for L in lags]
        ry = [_rho(d, L, 0) for L in lags]
        rho = [0.5 * (a + b) if a == a and b == b else float('nan') for a, b in zip(rx, ry)]
        coh = max([L for L, v in zip(lags, rho) if v == v and v >= 0.5] + [0])
        # 积分相关长度（梯形，到最大 lag）
        Li = 0.0
        for i, L in enumerate(lags):
            prev = lags[i - 1] if i else 0
            v = rho[i] if rho[i] == rho[i] else 0.0
            Li += v * (L - prev)
        out[CH[c]] = {'rms': rms, 'grms': grms, 'rel': rms / grms if grms > 0 else float('nan'),
                      'rho': rho, 'coh_len': float(coh), 'L_int': Li}
    # RGB 联合（三通道 rho 的最大值 = 最保守）
    mx = []
    for i in range(len(lags)):
        vals = [out[CH[c]]['rho'][i] for c in range(3) if out[CH[c]]['rho'][i] == out[CH[c]]['rho'][i]]
        mx.append(max(vals) if vals else float('nan'))
    out['RGB'] = {'rms': float(np.sqrt((D[:, :, :3] ** 2).mean())),
                  'grms': float(np.sqrt((G[:, :, :3] ** 2).mean())),
                  'rel': float(np.sqrt((D[:, :, :3] ** 2).mean()) / np.sqrt((G[:, :, :3] ** 2).mean())),
                  'rho': mx, 'coh_len': float(max([L for L, v in zip(lags, mx) if v == v and v >= 0.5] + [0])),
                  'L_int': float('nan')}
    return out


# ---------------- 汇总 + 判决 ----------------
def probe(G, T, ts=TS_MAIN):
    r = {}
    for ts2 in TS_SWEEP:
        for k, v in c1_variance_collapse(G, T, ts2).items():
            r['C1_%s_ts%d_min' % (k, ts2)] = float(np.min(v)) if v.size else float('nan')
            r['C1_%s_ts%d_p1' % (k, ts2)] = float(np.percentile(v, 1)) if v.size else float('nan')
            r['C1_%s_ts%d_p5' % (k, ts2)] = float(np.percentile(v, 5)) if v.size else float('nan')
            r['C1_%s_ts%d_p50' % (k, ts2)] = float(np.percentile(v, 50)) if v.size else float('nan')
            r['C1_%s_ts%d_n' % (k, ts2)] = int(v.size)
            r['C1_%s_ts%d_lt02_pct' % (k, ts2)] = 100.0 * float(np.mean(v < 0.2)) if v.size else 0.0
            r['C1_%s_ts%d_lt05_pct' % (k, ts2)] = 100.0 * float(np.mean(v < 0.5)) if v.size else 0.0
            r['C1_%s_ts%d_lt08_pct' % (k, ts2)] = 100.0 * float(np.mean(v < 0.8)) if v.size else 0.0
    for k, v in c2_levels(G, T, ts).items():
        r['C2_%s_min' % k] = float(np.min(v)); r['C2_%s_p1' % k] = float(np.percentile(v, 1))
        r['C2_%s_p50' % k] = float(np.percentile(v, 50))
        r['C2_%s_lt50_pct' % k] = 100.0 * float(np.mean(v < 0.5))
    for p in GRID_P:
        for k, (tv, gv, rr) in c3_grid_energy(G, T, p).items():
            r['C3_p%d_%s_test' % (p, k)] = tv
            r['C3_p%d_%s_golden' % (p, k)] = gv
            r['C3_p%d_%s_ratio' % (p, k)] = rr
    for ts2 in TS_SWEEP:
        for k, v in c4_error_field(G, T, ts2).items():
            for kk, vv in v.items():
                r['C4_%s_ts%d_%s' % (k, ts2, kk)] = vv
    c5 = c5_autocorr(G, T)
    for k, v in c5.items():
        r['C5_%s_rms' % k] = v['rms']; r['C5_%s_grms' % k] = v['grms']; r['C5_%s_rel' % k] = v['rel']
        r['C5_%s_coh_len' % k] = v['coh_len']; r['C5_%s_L_int' % k] = v['L_int']
        for L, vv in zip(COH_LAGS, v['rho']):
            r['C5_%s_rho%d' % (k, L)] = vv
    r['verdict_block'] = judge(r)
    return r


def judge(r):
    """三个独立族（family），每族内部多栏：
       F1 塌陷族  = C1 块内方差坍缩比（逐通道 / 逐尺度）
       F2 相关族  = C5 误差场空间自相关（rho64/rho128/coh_len/L_int）
       F3 台阶族  = C4 误差场分段常数度（blockiness / segconst / maxblockmad）
    判决：任一通道 C1<0.5 占比 >=25%（大面积抹平，无歧义）=> REJECT；
          >=2 族命中 => REJECT；恰好 1 族 => WARN（必须实机）；0 族 => block-ok。
    幅度地板守卫：某通道 D 的 rms 相对该通道 golden 的 rms < TH['D_AMP_FLOOR'] =>
    该通道的 F2/F3 判据不参与（误差小到看不见，再谈成不成片没有意义）。"""
    if all(r['C5_%s_rms' % c] == 0.0 for c in CH):
        return 'EXACT(no error field)'
    fam = {'F1_塌陷': [], 'F2_相关': [], 'F3_台阶': []}
    def live(c):
        return r['C5_%s_rel' % c] == r['C5_%s_rel' % c] and r['C5_%s_rel' % c] >= TH['D_AMP_FLOOR']
    mass = False
    for c in ('R', 'G', 'B', 'A', 'RGB'):
        for ts2 in (64, 128):
            p05 = r['C1_%s_ts%d_lt05_pct' % (c, ts2)]
            key = 'C1_lt05_pct_ts%d' % ts2
            if p05 >= TH[key]:
                fam['F1_塌陷'].append('C1_%s@%d: %.2f%% 块 var(test)/var(golden)<0.5 (阈 %.1f%%)'
                                      % (c, ts2, p05, TH[key]))
            if p05 >= 25.0:
                mass = True
            mn = r['C1_%s_ts%d_min' % (c, ts2)]
            if mn == mn and mn < TH['C1_min'] and r['C1_%s_ts%d_lt02_pct' % (c, ts2)] >= TH['C1_lt02_pct']:
                fam['F1_塌陷'].append('C1_%s@%d: min=%.3f 且 %.1f%% 块<0.2'
                                      % (c, ts2, mn, r['C1_%s_ts%d_lt02_pct' % (c, ts2)]))
    for c in ('A', 'RGB'):
        if not live(c):
            continue
        for lag in (64, 128):
            v = r['C5_%s_rho%d' % (c, lag)]
            key = ('A_coh%d' % lag) if c == 'A' else ('RGB_coh%d' % lag)
            if v == v and v >= TH[key]:
                fam['F2_相关'].append('C5_%s_rho%d=%.3f>=%.2f' % (c, lag, v, TH[key]))
        if r['C5_%s_coh_len' % c] >= TH['A_cohlen' if c == 'A' else 'RGB_cohlen']:
            fam['F2_相关'].append('C5_%s_coh_len=%.0f>=%.0f'
                                  % (c, r['C5_%s_coh_len' % c], TH['A_cohlen' if c == 'A' else 'RGB_cohlen']))
        li = r['C5_%s_L_int' % c]
        if li == li and li >= TH['A_Lint' if c == 'A' else 'RGB_Lint']:
            fam['F2_相关'].append('C5_%s_L_int=%.1f>=%.0f' % (c, li, TH['A_Lint' if c == 'A' else 'RGB_Lint']))
        for ts2 in (64, 128):
            v = r['C4_%s_ts%d_blockiness' % (c, ts2)]
            key = ('A_blk%d' % ts2) if c == 'A' else ('RGB_blk%d' % ts2)
            if v == v and v >= TH[key]:
                fam['F3_台阶'].append('C4_%s_blk%d=%.3f>=%.2f' % (c, ts2, v, TH[key]))
        v = r['C4_%s_ts16_segconst' % c]
        if v == v and v <= TH['A_seg16' if c == 'A' else 'RGB_seg16']:
            fam['F3_台阶'].append('C4_%s_seg16=%.3f<=%.2f(误差成片)' % (c, v, TH['A_seg16' if c == 'A' else 'RGB_seg16']))
        mad = r['C4_%s_ts64_maxblockmad' % c]
        gr = r['C5_%s_grms' % c]
        if mad == mad and gr > 0 and mad / gr >= TH['A_madsig' if c == 'A' else 'RGB_madsig']:
            fam['F3_台阶'].append('C4_%s_maxblockmad/sigma_golden=%.2f>=%.2f'
                                  % (c, mad / gr, TH['A_madsig' if c == 'A' else 'RGB_madsig']))
    nfam = sum(1 for k in fam if fam[k])
    if mass:
        return 'BLOCK-REJECT(大面积抹平: 某通道 >=25% 块 var 比<0.5) ' + \
               ('| ' + ' ; '.join('; '.join(v) for k, v in fam.items() if v) if nfam else '')
    if nfam >= 2:
        return 'BLOCK-REJECT(%d/3 族命中) ' % nfam + ' || '.join('%s[%s]' % (k, '; '.join(v))
                                                                for k, v in fam.items() if v)
    if nfam == 1:
        k = [x for x in fam if fam[x]][0]
        return 'BLOCK-WARN(1/3 族命中，必须实机) %s[%s]' % (k, '; '.join(fam[k]))
    return 'block-ok'


def fmt(x, w=8, p=3):
    if x is None or (isinstance(x, float) and x != x):
        return ' ' * (w - 3) + 'n/a'
    if isinstance(x, float) and x in (float('inf'), float('-inf')):
        return ' ' * (w - 3) + ('inf' if x > 0 else '-inf')
    return '%*.*f' % (w, p, x)


def print_probe(label, r, ts=TS_MAIN):
    print("\n### %s  (主尺度 %dx%d, 完整块=%d)" % (label, ts, ts, r['C1_RGB_ts%d_n' % ts]))
    print("  C1 块内方差坍缩比 var(test)/var(golden)：每尺度报 <0.5% 块占比 (min)")
    for k in ('R', 'G', 'B', 'A', 'RGB'):
        print("     %-3s " % k + '  '.join("ts%-3d: %6.2f%% (%s)" %
              (t2, r['C1_%s_ts%d_lt05_pct' % (k, t2)], fmt(r['C1_%s_ts%d_min' % (k, t2)], 6, 3))
              for t2 in TS_SWEEP))
    print("  C2 块内有效等级数（levels/像素、相邻差非零比例）：min/p1/p50 | <0.5 的块%")
    for k in ('levels_frac', 'nzfrac'):
        print("     %-12s %s %s %s | %6.2f%%" % (k, fmt(r['C2_%s_min' % k], 8, 4),
                                                fmt(r['C2_%s_p1' % k], 8, 4), fmt(r['C2_%s_p50' % k], 8, 4),
                                                r['C2_%s_lt50_pct' % k]))
    print("  C3 网格台阶能量（test/golden 的 边界/非边界 比；1.00 = 无网格对齐）")
    for p in GRID_P:
        print("     p=%-4d %s" % (p, '  '.join("%s x=%s y=%s" % (c, fmt(r['C3_p%d_%s_x_ratio' % (p, c)], 6, 3),
                                                                fmt(r['C3_p%d_%s_y_ratio' % (p, c)], 6, 3)) for c in CH)))
    print("  C4 误差场分段常数度（segconst: iid≈1 成片<<1 | blockiness: 台阶化=>大 | maxblockmad）")
    for ts2 in TS_SWEEP:
        print("     ts=%-4d %s" % (ts2, ' | '.join("%s seg=%s blk=%s mad=%s" %
              (c, fmt(r['C4_%s_ts%d_segconst' % (c, ts2)], 6, 3), fmt(r['C4_%s_ts%d_blockiness' % (c, ts2)], 6, 3),
               fmt(r['C4_%s_ts%d_maxblockmad' % (c, ts2)], 7, 2)) for c in ('R', 'G', 'B', 'A', 'RGB'))))
    print("  C5 误差场空间自相关 rho(lag)（★主判据）+ 相关长度")
    for k in ('R', 'G', 'B', 'A', 'RGB'):
        print("     %-3s rms=%8.4f rel=%s  rho1=%s rho64=%s rho128=%s rho256=%s  coh_len=%5.0f  L_int=%8.1f"
              % (k, r['C5_%s_rms' % k], fmt(r['C5_%s_rel' % k], 6, 4), fmt(r['C5_%s_rho1' % k], 6, 3),
                 fmt(r['C5_%s_rho64' % k], 6, 3), fmt(r['C5_%s_rho128' % k], 6, 3),
                 fmt(r['C5_%s_rho256' % k], 6, 3), r['C5_%s_coh_len' % k], r['C5_%s_L_int' % k]))
    print("  => verdict: %s" % r['verdict_block'])


# ---------------- 合成对照（探针的"牙齿"证明） ----------------
def synth(G):
    """对 golden 施加工知答案的扰动，证明探针测的是**块化**而不是**误差幅度**。"""
    rng = np.random.RandomState(20261102)
    cases = []
    def cp():
        return G.copy()
    # S1: A 通道 64x64 块均值化（=块内结构塌光，彩色大方块的正解）
    a = cp()
    for y in range(0, H, 64):
        for x in range(0, W, 64):
            a[y:min(H, y + 64), x:min(W, x + 64), 3] = a[y:min(H, y + 64), x:min(W, x + 64), 3].mean()
    cases.append(('SYNTH-A-blockmean64(必须红)', a))
    # S2: A 通道 iid 高斯噪声，rms 与 T1 的 A 误差同量级（7.17）
    b = cp(); b[:, :, 3] = b[:, :, 3] + rng.normal(0.0, 7.17, (H, W))
    cases.append(('SYNTH-A-iid-rms7.17(必须不红)', b))
    # S3: A 通道块间随机台阶（块 128，块内常数、块之间跳）
    c3 = cp()
    for y in range(0, H, 128):
        for x in range(0, W, 128):
            c3[y:min(H, y + 128), x:min(W, x + 128), 3] += rng.normal(0.0, 7.0)
    cases.append(('SYNTH-A-step128(必须红)', c3))
    # S4: RGB 三通道 64x64 块均值化（彩色大方块的 RGB 版）
    c4 = cp()
    for y in range(0, H, 64):
        for x in range(0, W, 64):
            v = c4[y:min(H, y + 64), x:min(W, x + 64), :3].mean(axis=(0, 1))
            c4[y:min(H, y + 64), x:min(W, x + 64), :3] = v
    cases.append(('SYNTH-RGB-blockmean64(必须红)', c4))
    # S5: RGB iid 噪声，rms 与 T2 的 RGB 误差同量级（0.40）
    c5 = cp(); c5[:, :, :3] = c5[:, :, :3] + rng.normal(0.0, 0.40, (H, W, 3))
    cases.append(('SYNTH-RGB-iid-rms0.40(必须不红)', c5))
    # S6: 自比（同一份 golden）
    cases.append(('SYNTH-self(必须 0 假阳)', G.copy()))
    rows = []
    for lab, T in cases:
        r = probe(G, T)
        print_probe(lab, r)
        r['label'] = lab
        rows.append(r)
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('gold'); ap.add_argument('tests', nargs='*')
    ap.add_argument('--ts', type=int, default=TS_MAIN)
    ap.add_argument('--csv', default=None)
    ap.add_argument('--pairs', action='store_true')
    ap.add_argument('--synth', action='store_true')
    a = ap.parse_args()
    G = load(a.gold)
    print("block_collapse: gold=%s md5=%s  (960x544 RGBA f32, %d B)"
          % (a.gold, md5(a.gold), W * H * 16))
    print("阈值(2026-11-02 标定): " + '  '.join("%s=%s" % (k, v) for k, v in TH.items()))
    rows = []
    if a.synth:
        rows += synth(G)
    prev = None
    for t in a.tests:
        T = load(t)
        r = probe(G, T, a.ts)
        r['label'] = os.path.basename(t); r['gold'] = os.path.basename(a.gold)
        r['md5'] = md5(t)
        print_probe(os.path.basename(t), r, a.ts)
        rows.append(r)
        if a.pairs and prev is not None:
            r2 = probe(prev[1], T, a.ts)
            r2['label'] = "[PAIR %s vs %s]" % (os.path.basename(prev[0]), os.path.basename(t))
            print_probe(r2['label'], r2, a.ts)
            rows.append(r2)
        prev = (t, T)
    if a.csv and rows:
        import csv
        cols = list(dict.fromkeys(k for r in rows for k in r.keys()))
        with open(a.csv, 'w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=cols, restval='', extrasaction='ignore')
            w.writeheader()
            for r in rows:
                w.writerow(r)
        print("\nwrote", a.csv, "(%d cols)" % len(cols))


if __name__ == '__main__':
    main()
