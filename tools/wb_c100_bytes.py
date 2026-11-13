import sys
sys.stdout.reconfigure(encoding='utf-8')

# C100 (1): the byte account for a RESIDENT C512 chain. Facts used (hardware.md + ze_info):
#   SLM per Xe-core 128 KB; per-WG cap 65,536 B; occupancy: <=43,690 B -> 3 WG/core,
#   49,152 / 57,344 B -> 2 WG/core, >65,536 B -> 1 WG/core.
#   GRF per thread: grf<=128 registers, a register = 32 lanes x 4 B = 128 B -> 16,384 B/thread.
#   Chain shape: tokens T=64, channels C=512, NH=3C=1536, heads=16, M=768 rows (12 windows x 64).
T, C, NH = 64, 512, 1536
def b(x): return '%8d B  %6.1f KB' % (x, x / 1024.0)
def tier(slm, wg):
    if slm <= 43690: occ = '3 WG/core'
    elif slm <= 65536: occ = '2 WG/core'
    else: occ = 'IMPOSSIBLE (> per-WG cap)'
    waves = wg / 24.0 if occ == '3 WG/core' else (wg / 16.0 if occ == '2 WG/core' else wg / 8.0)
    return '%-22s WG=%4d -> %.2f waves/core' % (occ, wg, waves)

print('=== the pieces a resident chain must hold (per chain, C512) ===')
qkv_i8   = 3 * T * C                      # Q,K,V int8 (one window: 64 tokens x 512 ch, 3 planes)
scores   = T * T * 2                      # 64x64 f16
probs    = T * T * 2                      # 64x64 f16 (int8 probs would be 4096)
ctx_f16  = T * C * 2                      # attnV context 64x512 f16
ctx_f32  = T * C * 4
out_f32  = T * C * 4                      # the wres output tile for one window
out_f16  = T * C * 2
for nm, v in (('Q/K/V int8 (3 planes)', qkv_i8), ('scores f16', scores), ('probs f16', probs),
              ('ctx f16', ctx_f16), ('ctx f32', ctx_f32), ('out tile f32', out_f32), ('out tile f16', out_f16)):
    print('  %-26s %s' % (nm, b(v)))
print()
print('=== the WGs the chain spans: 12 windows x (NH/BN) column groups ===')
for bn in (64, 128, 256, 512):
    wg = 12 * (C // bn) if bn <= C else 12
    print('  BN=%3d -> col groups %2d, WG = 12*%-3d = %3d   (chain has 9 launches today)' % (bn, C // bn, C // bn, wg))
print()
cuts = []
# cut 1: everything in SLM, whole channel C=512, one window per WG
s1 = qkv_i8 + scores + probs + ctx_f16
cuts.append(('S1 whole C, SLM holds QKV+scores+probs+ctx', s1, 12 * (C // 512), 'GRF: none'))
# cut 2: Q/K/V live in GRF (each thread holds qkv_i8/64 bytes), SLM holds scores/probs/ctx
s2 = scores + probs + ctx_f16
per_thread = qkv_i8 / 64.0
cuts.append(('S2 QKV in GRF (12 regs/thread) + SLM scores/probs/ctx f16', s2, 12 * (C // 512),
             'GRF/thread = %.0f B = %.1f regs' % (per_thread, per_thread / 128.0)))
# cut 3: S2 + ctx split into 2 C-bands of 256 (processed sequentially inside the WG)
s3 = scores + probs + (T * 256 * 2)
cuts.append(('S3 QKV in GRF + ctx split 2x256 (SLM peak)', s3, 12 * (C // 512),
             'GRF/thread = %.0f B = %.1f regs' % (per_thread, per_thread / 128.0)))
# cut 4: S3 + BN=256 column groups (2 groups per window) so each WG handles 256 channels
s4 = (T*T*2)*2 + (T * 256 * 2) + (3 * T * 256)   # scores/probs + ctx band + the band's QKV slice
cuts.append(('S4 per-band WG: band C=256 (QKV band in SLM) + ctx band', s4, 12 * (C // 256), 'GRF: none'))
# cut 5: S4 with token split 2x32
s5 = (32*64*2)*2 + (32 * 256 * 2) + (3 * 32 * 256)
cuts.append(('S5 band C=256 + token 2x32', s5, 12 * 2 * (C // 256), 'GRF: none'))

for nm, slm, wg, grf in cuts:
    print('--- %s' % nm)
    print('    SLM peak %s   |  %s  |  %s' % (b(slm), tier(slm, wg), grf))
print()
print('=== the hard ceiling ===')
print('  per-WG SLM cap = %s  => a chain piece set bigger than that cannot be resident at all' % b(65536))
print('  3 WG/core needs SLM <= %s' % b(43690))
print('  Q/K/V int8 for one window (3 planes) = %s  -> ALONE exceeds the 3-WG line, and is '
      '98,304 B = %.0f%% of the per-WG cap' % (b(qkv_i8), 100.0 * qkv_i8 / 65536))
print('  GRF per WG (64 threads x 128 regs x 128 B) = %s  -> QKV fits in GRF with room' % b(64 * 128 * 128))
print('  but the shipped kernels already use grf=128 (census) -> the extra 12 regs for QKV are only'
      ' available if the tile registers shrink')
