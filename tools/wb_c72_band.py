import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

def parse(p):
    t = open(p, encoding='utf-8', errors='replace').read().split('\n')
    out = {}
    cur = None
    for L in t:
        m = re.match(r'== shape \((.*?)\)', L)
        if m:
            cur = m.group(1); out[cur] = {}
        else:
            m2 = re.match(r'(.+?)\s+(raw|pub)\s+ms=\s*([\d.]+)', L.strip())
            if m2 and cur:
                out[cur][(m2.group(1).strip(), m2.group(2))] = float(m2.group(3))
            elif 'N/A' in L and cur:
                out[cur].setdefault('_na_arms', []).append(L.strip()[:40])
    return out

P = [parse(r'E:\DSH\logs\C72_r%d.log' % i) for i in (1, 2, 3)]
shapes = list(P[0].keys())
print('shapes:', len(shapes))

def best(shape, arm, mode):
    vals = [d[shape].get((arm, mode)) for d in P if shape in d]
    vals = [v for v in vals if v]
    return min(vals) if vals else None

def gflops(shape):
    m = re.match(r'M=(\d+) N=(\d+) K=(\d+) b=(\d+)', shape)
    M, N, K, b = map(int, m.groups())
    return 2.0 * M * N * K * b / 1e9

print('\n=== per-shape best pub ms (3 cold procs, min) + effective TOPS ===')
for sh in shapes:
    for arm in ('shipped gemm_b_pub', 'bn128_nt64_bk64_d1', 'bk64_d1', 'bn128_ser_bk64_d1'):
        v = best(sh, arm, 'pub')
        if v:
            tops = gflops(sh) / (v / 1e3) / 1000.0
            print('  %-26s %-22s pub=%7.4f ms  %8.2f TFLOP/s(=TOPS for int8)' % (sh, arm, v, tops))
        elif 'NA' in P[0].get(sh, {}):
            pass
    if any('NA' in d.get(sh, {}) for d in P):
        print('  %-26s  -- all arms N/A at this shape (N%%BN or K%%BK) --' % sh)

# ---- the A1 bottom-up price: per chain, band-split vs whole-C ----
def chain_time(qkv_shape, band_mult):
    """sum of the four math stages for ONE C512 chain, using the measured per-launch times."""
    return None

KEY = {sh: sh for sh in shapes}
def show_pair(a0sh, a1shapes, label):
    t0 = best(a0sh, 'bn128_nt64_bk64_d1', 'pub')
    t1 = sum((best(s, 'bn128_nt64_bk64_d1', 'pub') or 0.0) for s in a1shapes)
    g0 = gflops(a0sh); g1 = sum(gflops(s) for s in a1shapes)
    print('\n  %s' % label)
    print('    A0 whole-C launch : %s  pub=%s ms  GFLOP=%.3f' % (a0sh, ('%.4f' % t0) if t0 else 'n/a', g0))
    print('    A1 band launches  : %s' % ', '.join(a1shapes))
    print('                        sum pub=%s ms  GFLOP=%.3f' % (('%.4f' % t1) if t1 else 'n/a', g1))
    if t0 and t1:
        print('    band-split penalty = %+.1f%%  (same total FLOPs: %.3f vs %.3f)' % (100.0 * (t1 - t0) / t0, g0, g1))

whole = next((s for s in shapes if s == 'M=768 N=512 K=512 b=1'), None)
b128 = next((s for s in shapes if s == 'M=768 N=128 K=512 b=4'), None)
b64 = next((s for s in shapes if s == 'M=768 N=64 K=512 b=8'), None)
if whole and b128:
    show_pair(whole, [b128], 'QKV stage: whole-C vs 4 bands of 128 (same FLOPs)')
if whole and b64:
    show_pair(whole, [b64], 'QKV stage: whole-C vs 8 bands of 64 (same FLOPs)')
sc = next((s for s in shapes if s == 'M=768 N=64 K=32 b=16'), None)
pv = next((s for s in shapes if s == 'M=768 N=32 K=64 b=16'), None)
pj = next((s for s in shapes if s == 'M=768 N=512 K=32 b=1'), None)
print('\n  attention inner stages (band form, one chain):')
for s in (sc, pv, pj):
    if s:
        v = best(s, 'bn128_nt64_bk64_d1', 'pub') or best(s, 'bk64_d1', 'pub')
        print('    %-24s pub=%s ms  GFLOP=%.3f' % (s, ('%.4f' % v) if v else 'n/a', gflops(s)))
