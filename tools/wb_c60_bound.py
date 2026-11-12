import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

# ---- family serial legs (fused build, C39 ledger) ----
fam_ms = collections.Counter(); fam_clo = collections.Counter()
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    f = (r['family'] or '').replace('xmx_rec_', '')
    try:
        fam_ms[f] += float(r['ms']); fam_clo[f] += 1
    except ValueError:
        pass
WIN = ('gemm_int8_qkv', 'window_attention', 'gemm_window_int8_residual', 'gemm_int8_batched',
       'gemm_int8_residual', 'quant', 'quant_window', 'gemm')
serial = sum(fam_ms[f] for f in WIN)
closures = sum(fam_clo[f] for f in WIN)
OV = 42.15 / 117.434                     # measured overlap factor (frame wall / serial)
print('=== window-chain families (the 52 chains) ===')
for f in WIN:
    print('   %-30s closures=%-4d serial=%7.3f ms  frame-visible=%6.3f ms' % (f, fam_clo[f], fam_ms[f], fam_ms[f] * OV))
print('   TOTAL closures=%d  serial=%.2f ms  visible=%.2f ms' % (closures, serial, serial * OV))

# ---- account 1: dispatch / skeleton (C43/C44 measured 9-12% of leg) ----
sk_lo, sk_hi = 0.09 * serial * OV, 0.12 * serial * OV
print('\n=== 三笔账（帧内可见 ms，重叠系数 %.3f）===' % OV)
print('  1) dispatch/skeleton：C43/C44 实测占腿 9-12%% => %.2f - %.2f ms/帧' % (sk_lo, sk_hi))
print('     但这条已被实测否掉可收性：b6/lfw/B6 四组测量 Δ≈0（少 launch 不省时间，§六.三十 节点税 0.7 us）')
print('     => 非数值口径下可收 ≈ 0.0 - 0.5 ms/帧')

# ---- account 2: encode chain (C58 model, self-validated 13.98 serial vs 14.55 measured) ----
ELEM = 3.415e8
ISSUE = 32 * 2.10e9
enc_serial = ELEM / 8 * 22 / ISSUE * 1000.0
enc_vis = enc_serial * OV
print('  2) 编码链（C58 模型自校验）：342M 值、gate+e4m3 22 条/8 值 => %.2f ms 串行 / %.2f ms 可见' % (enc_serial, enc_vis))
print('     其中"阶段之间不重复编码"可跳过 ~55-65%% => %.2f - %.2f ms/帧' % (0.55 * enc_vis, 0.65 * enc_vis))
print('     ★ 但阶段之间的 quant 是数值语义的一部分：跳过它 = 改数值（P8 同类），不是非数值杠杆')

# ---- account 3: plane round-trip DRAM-served (C59 per-plane L2 test) ----
slab = {}
for r in csv.DictReader(open(T + r'\plane_traffic.csv', encoding='utf-8', errors='replace')):
    try:
        slab[r['plane_id_this_run']] = (int(r['bytes']) / 1e6, float(r['executed_total_MB_per_frame']))
    except (ValueError, KeyError):
        pass
rem = 0.0
print('  3) 中间面往返（只算 face > L2 16 MB 的 DRAM 服务部分）：')
for pid, (face, ex) in sorted(slab.items(), key=lambda x: -x[1][1]):
    if face > 16.0 and ex > 20:
        r = ex - 2 * face
        rem += max(0.0, r)
        print('       slab %-5s face %6.2f MB  exec %7.1f MB/帧  DRAM 可消 %7.1f MB' % (pid, face, ex, r))
print('     => %.0f MB/帧 = %.2f ms@291.1 / %.2f ms@340' % (rem, rem / 291.1, rem / 340.0))

best = 0.5 + 0.0 + rem / 291.1
num = 0.5 + 0.65 * enc_vis + rem / 291.1
print('\n=== 合并上界 ===')
print('  非数值口径（三笔都按已证可收性）：%.2f ms/帧   < 8 ms 线 => 判停' % best)
print('  若允许改数值（跳过阶段间 requant）：%.2f ms/帧  —— 但那是 P8 同类，须用户看画面' % num)
