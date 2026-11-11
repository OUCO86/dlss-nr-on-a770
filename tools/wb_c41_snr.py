import sys
import numpy as np
sys.stdout.reconfigure(encoding='utf-8')
rng = np.random.default_rng(20261112)
N = 400000
print('=== residual-chain error growth with an f16 rounding on the accumulator at every stage ===')
print('(inputs: unit-variance adds; f16 = 10-bit mantissa, ulp = 2^-11 = 4.88e-4 on a unit-scale value)')
for stages in (12, 68):
    true = np.zeros(N); app = np.zeros(N)
    rs = np.random.default_rng(7)
    for i in range(stages):
        add = rs.normal(0.0, 1.0, N)
        true += add
        app = (app + add).astype(np.float16).astype(np.float64)   # the f16 accumulator
    e = app - true
    sr = np.sqrt(np.mean(true ** 2)); er = np.sqrt(np.mean(e ** 2))
    print('   %2d stages: signal RMS %.3f  error RMS %.4f  rel %.3e  SNR %5.1f dB   worst-elt rel %.3e' % (
        stages, sr, er, er / sr, 20 * np.log10(sr / er), np.max(np.abs(e)) / max(1e-9, np.max(np.abs(true)))))
print('   reference: RES8 (the byte-plane knife already judged dead) = SNR 17 dB << 40 dB approval line')
print('   single-stage f16 rounding alone: ulp/2 relative = 2.4e-4 -> SNR ~ 72 dB')
