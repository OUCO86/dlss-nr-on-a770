import re, os, glob
# Build E:/DSH/s6/s6b_feas.csv from the probe logs (authoritative for cfg / slm / status / ms).
# Ledger columns (grf / private / scratch) come from S6b_spillcheck_probe.txt: EVERY probe
# kernel is grf_count=128, simd_size=16, and has NO private/spill/scratch section in the
# ocloc .ze_info (= 0). slm_size is NOT emitted for local_accessor kernels -- it is a
# launch-time driver allocation (payload arg addrmode:slm), so the slm_bytes column here is
# the compile-time layout number, which the JIT cap enforcement (error 40) independently proves.
rows = {}
for p in sorted(glob.glob(r'E:\DSH\s6\S6b_c*_*.log')):
    txt = open(p, encoding='utf-8', errors='replace').read()
    for m in re.finditer(r'CSVROW;(\d+);([^;]+);(\d+);(\d+);(\d+);(\d+);(\d+);(\d+);(\d+);(\d+);(\d+);([A-Za-z0-9\-]+);([0-9.]+);([0-9.]+);([0-9.]+);([0-9.]+);([0-9.]+);(\d+)', txt):
        cfg, name, T, C, raw, slm, kv, bt, scg, inp, nbar, status, gmsm, gmsM, gmsX, gmed, wmsM, nz = m.groups()
        cfg = int(cfg)
        cur = rows.get(cfg)
        score = {'REJECT': 1, 'SKIP': 1, 'LIVE-smoke': 2, 'LIVE': 3}
        if cur is None or score.get(status, 0) >= score.get(cur['status'], 0):
            rows[cfg] = dict(name=name, T=int(T), C=int(C), raw=int(raw), slm=int(slm), kv=int(kv),
                             bt=int(bt), scg=int(scg), inp=int(inp), nbar=int(nbar), status=status,
                             gmsm=float(gmsm), gmsM=float(gmsM), gmsX=float(gmsX), gmed=float(gmed),
                             wmsM=float(wmsM), nz=int(nz))
ORDER = {0:'C64_T64_full',1:'C64_T16_full',2:'C128_T64_full',3:'C128_T16_full'}
notes = {
 0:'REQUIRED C=64 T=64; 11 fences; full plan',
 1:'REQUIRED C=64 T=16; full plan (window k/v in SLM)',
 2:'REQUIRED C=128 T=64; hidden slice ALONE = 65536B',
 3:'REQUIRED C=128 T=16; full plan; 64B over the cap',
 4:'cut: B streamed (BT=0) -> still 256B over cap',
 5:'cut: B streamed + scales global -> exactly 65536B',
 6:'cut: pk2 in-place compaction + B tile -> exactly 65536B',
 7:'cut: window k/v in GLOBAL (re-buys the 1277/qkv round trip)',
 8:'cut-all: kv global + B streamed + scales global = 16384B (residency 4)',
 9:'C=128 T=16 kv global (41024B, residency 1)',
 10:'C=128 T=16 cut-all = 32768B = EXACTLY the 32KB cliff',
 11:'C=64 T=32 full plan (1a ownership, 49280B)',
 12:'C=64 T=32 kv global (41088B)',
 14:'C=64 T=64 in-place + B4096 + scales global (61440B)',
 13:'C=128 T=32 kv global + B tile (73856B)',
 15:'BARRIER KNOB: cfg1 layout with 1 fence',
 16:'BARRIER KNOB: cfg1 layout with 0 fences (racy by design)',
 17:'BARRIER KNOB: cfg7 layout with 1 fence',
 18:'BARRIER KNOB: cfg7 layout with 0 fences',
 19:'BARRIER KNOB: cfg6 layout with 1 fence',
 20:'BARRIER KNOB: cfg6 layout with 0 fences',
}
hdr = 'cfg,tokens_per_wg,slm_bytes,grf,private,scratch,status,msM,note'
out = [hdr]
for cfg in sorted(rows):
    r = rows[cfg]
    status = {'REJECT': 'REJECT(JIT err40)', 'SKIP': 'SKIP(host self-refuse)'}.get(r['status'], r['status'])
    extra = ''
    if r['status'] == 'LIVE':
        extra = ' | gpu msm=%.4f msX=%.4f med=%.4f | wall msM=%.4f | fences=%d | KVSLM=%d BT=%d SCG=%d INPLACE=%d | residency=floor(65536/slm)=%d' % (
            r['gmsm'], r['gmsX'], r['gmed'], r['wmsM'], r['nbar'], r['kv'], r['bt'], r['scg'], r['inp'], 65536 // r['raw'])
    else:
        extra = ' | over the 65536B cap by %d B | fences=%d | KVSLM=%d BT=%d SCG=%d INPLACE=%d' % (
            r['raw'] - 65536, r['nbar'], r['kv'], r['bt'], r['scg'], r['inp'])
    out.append('%d,%d,%d,128,0,0,%s,%.4f,"%s"' % (
        cfg, r['T'], r['raw'], status, r['gmsM'], notes.get(cfg, r['name']) + extra))
open(r'E:\DSH\s6\s6b_feas.csv', 'w', encoding='utf-8').write('\n'.join(out) + '\n')
print('\n'.join(out))
