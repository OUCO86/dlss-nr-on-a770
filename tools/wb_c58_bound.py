import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
rows = list(csv.DictReader(open(r'E:\DSH\dlss-nr-on-a770\tools\rt_per_closure.csv', encoding='utf-8', errors='replace')))
fam = ('gemm_int8_residual', 'gemm_int8_batched', 'gemm_int8_qkv', 'gemm_window_int8_residual', 'gemm_int8')
agg = collections.Counter(); cnt = collections.Counter(); gf = collections.Counter()
for r in rows:
    f = (r['family'] or '').replace('xmx_rec_', '')
    if f not in fam:
        continue
    try:
        M = int(r['M']); N = int(r['N']); b = max(1, int(r['batch'] or 0))
    except ValueError:
        continue
    if M <= 0 or N <= 0:
        continue
    agg[f] += M * N * b; cnt[f] += 1
    try:
        gf[f] += float(r['gflop'])
    except ValueError:
        pass
tot = 0
for f in fam:
    if cnt[f]:
        print('  %-30s closures=%-4d C-elements=%11.3e  gflop-sum=%8.2f' % (f, cnt[f], agg[f], gf[f]))
        tot += agg[f]
print('  TOTAL encoded C elements/frame = %.3e (%.0f M)' % (tot, tot / 1e6))
ISSUE = 32 * 2.10e9          # 32 EU x 2.1 GHz, 1 SIMD instr/cycle/EU
print('\n  chain instruction model (measured from the shipped source):')
print('    e4m3_vec_v8  = 14 SIMD ops per vector of N   (bit_cast_view is free)')
print('    gate_vec_v8  = 22 SIMD ops per vector of N   (BLADE-6 note: scalar form was 15-30 instrs/element)')
for NVEC in (8, 16):
    for ops, chain in ((14, 'e4m3 only'), (22, 'gate+e4m3'), (30, 'gate+e4m3+scales')):
        instr = tot / NVEC * ops
        ms = instr / ISSUE * 1000.0
        print('    N=%-3d %-18s -> %9.3e instr/frame  %6.2f ms serial  %5.2f ms frame-visible (%4.1f%% of 42.15)' % (
            NVEC, chain, instr, ms, ms * 0.359, 100 * ms * 0.359 / 42.15))
print('\n  SWAR (2 values/lane) cuts instructions to 0.5-0.75x of the ALREADY-vectorized chain')
for NVEC in (8, 16):
    instr = tot / NVEC * 22
    ms = instr / ISSUE * 1000.0
    print('    at N=%d, gate+e4m3 chain: saving = %.2f - %.2f ms/帧 帧内可见 (%.1f%% - %.1f%% of 42.15)' % (
        NVEC, ms * 0.359 * 0.25, ms * 0.359 * 0.5, 100 * ms * 0.359 * 0.25 / 42.15, 100 * ms * 0.359 * 0.5 / 42.15))
