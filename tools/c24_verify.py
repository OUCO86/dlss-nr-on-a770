import csv, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# 1) structural check of the audit table
rows = list(csv.reader(open(r"E:\DSH\tools\C24_walkorder_audit.csv", encoding="utf-8")))
hdr = rows[0]
print("cols=%d" % len(hdr))
bad = [i for i, r in enumerate(rows) if len(r) != len(hdr)]
print("rows=%d ragged=%s" % (len(rows) - 1, bad))

# 2) reproduce the quant launch geometry: qr_launch_esimd (LW=64) and the plain form (256 thr)
QR_GRID = 65535
def sub_max():
    return 32   # A770 sub_group_sizes max = 32

def esimd_ngroups(m, k, LW=64):
    chunks = k // 16
    SUB = min(sub_max(), LW)
    if chunks >= SUB:
        prub = SUB
    elif chunks <= 1:
        prub = 1
    else:
        v, lg = chunks - 1, 0
        while True:
            v >>= 1
            if not v:
                break
            lg += 1
        prub = 1 << (lg + 1)
    rows_per_wg = LW // prub
    ng = (m + rows_per_wg - 1) // rows_per_wg
    gxx = min(ng, QR_GRID)
    gyy = (ng + gxx - 1) // gxx
    return prub, rows_per_wg, ng, gxx, gyy

sh = list(csv.DictReader(open(r"E:\DSH\tools\shapes_census.csv", encoding="utf-8")))
seen = {}
for r in sh:
    if r["family"] in ("xmx_rec_quant", "xmx_rec_quant_window"):
        M = int(r["M"]); K = int(r["K"])
        seen[(r["family"], M, K)] = seen.get((r["family"], M, K), 0) + 1
print("\nquant launch geometry (LW=64 ESIMD route):")
maxng = 0
for (fam, M, K), n in sorted(seen.items(), key=lambda x: -(x[0][1])):
    prub, rpw, ng, gxx, gyy = esimd_ngroups(M, K)
    maxng = max(maxng, ng)
    print("  %-24s M=%-7d K=%-5d x%-3d prub=%-3d rows_per_wg=%-2d ngroups=%-6d gxx=%-6d gyy=%d" % (fam, M, K, n, prub, rpw, ng, gxx, gyy))
print("  max ngroups over the frame = %d  vs QR_GRID = %d  => gyy==1 everywhere: %s" % (maxng, QR_GRID, maxng < QR_GRID))

# 3) gemm planes for the biggest tile-decomposed legs (int8: BM=128 BN=64 BK=32)
BM, BN, NT = 128, 64, 32
def ceil_bm(m): return ((m + BM - 1) // BM) * BM
print("\ngemm_int8_residual / window_int8_residual planes (int8 A = Mp*K, B = N*K, skip = Mp*N*w):")
for M, N, K in [(32640, 64, 64), (2040, 256, 256), (640, 512, 512), (8160, 128, 128), (192, 1024, 4096), (192, 1024, 1024)]:
    Mp = ceil_bm(M)
    A = Mp * K; B = N * K; NB = N // BN; MB = Mp // BM
    skip2 = Mp * N * 2; skip4 = Mp * N * 4
    print("  M=%-6d N=%-5d K=%-5d Mp=%-6d MB=%-4d NB=%-3d A=%9d B=%9d skip(f16/f32)=%9d/%9d  A+B=%9d (%.1f%% of 16MB)" %
          (M, N, K, Mp, MB, NB, A, B, skip2, skip4, A + B, 100.0 * (A + B) / (16 * 1024 * 1024)))
print("\nf16 global_attention scores leg (f16v1::gemm_b, Mp=64 K=32 N=rows=130560 batches=heads):")
print("  A = 64*32*2 = %d B; B = 32*130560*2 = %d B; tr_n=4 tc_n=%d; B read tr_n times = %d B" %
      (64 * 32 * 2, 32 * 130560 * 2, 130560 // 16, 4 * 32 * 130560 * 2))
print("\nwindow_block image planes (C=32):")
for h, w in [(544, 960), (272, 480)]:
    print("  %dx%d: f16 %d B, f32 %d B" % (h, w, h * w * 32 * 2, h * w * 32 * 4))
