#!/usr/bin/env python3
"""frame-bytes.py -- the frame's DRAM byte floor, per pass family, from the ledger.

The question (user, 2026-10-15): how much of the 44.75 ms is bytes we cannot avoid,
and how much is overhead we can fuse away? No profiler on this machine (no VTune/GPA),
but the ledger (work/ledger-960x544.txt) already carries every pass's shape AND its
measured device time, and Blackwood calibrated this exact card's rooflines
(notes: B_DRAM_contiguous read 291.11 GB/s, copy 340, L2_reuse 854.6).

Method: for each of the 77 site/shape rows, compute the minimum DRAM bytes the pass
must touch (operands in, result out, per the dtypes the frame records actually use),
then compare measured ms against bytes/291 GB/s. A pass at ~1.0 ratio is at the
bandwidth floor -- the only lever is fewer bytes (fusion, dtype, layout). A pass at
~0.3 is a third of the floor's time: launch/latency/ALU bound, and the lever is
fusion or persistent scheduling.

Dtype assumptions (from the ledger's narrow flags and nr_resident's calls):
  gemm_int8/_qkv: A int8 (M*K), B int8 (N*K), C half (M*N*2) -- the frame records
    every int8 GEMM with narrow=True except the global-block ones (float32 C).
  quantize_row: reads fp16 (M*K*2), writes int8 (M*K*1) + 4B a row of scales.
  window_block: reads the image window (M*32*2), writes it back (M*32*2); the
    QKV/projection weights (96*32 + 32*32 halves = 10 KB) re-read per window from
    L2 (they are 10 KB against a 16 MB L2 -- resident, so NOT counted as DRAM;
    this is the same assumption Blackwood's B_L2_reuse pattern encodes).
  ffn_fused: reads fp16 in (M*32*2), writes half out (M*32*2); hidden on chip.
  window_attention: reads q,k,v halves (3*M*32*2), writes out (M*32*2).
  gemm (float): fp16 in, fp16 out.
Scales/epsilons/biases: counted where listed, negligible otherwise.

    python src/bench/frame-bytes.py [ledger-file]
"""
import re
import sys

DRAM = 291.11e9          # B/s, Blackwood B_DRAM_contiguous read (stable, [MEASURED])
COPY = 340.03e9          # B/s when reads+writes both stream (used for the floor)
L2 = 854.6e9

def gemm_bytes(m, n, k, c_half=True, a_int8=True, b_int8=True):
    ab = m * k * (1 if a_int8 else 2)
    bb = n * k * (1 if b_int8 else 2)
    cb = m * n * (2 if c_half else 4)
    return ab + bb + cb

def quant_bytes(m, k):
    return m * k * 3 + m * 4          # fp16 in + int8 out + row scales

def wb_bytes(m):
    return m * 32 * 2 * 2             # image in + image out (weights L2-resident)

def attn_bytes(m):
    return m * 32 * 2 * 4             # q,k,v in + out

def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "work/ledger-960x544.txt"
    rows = []
    for line in open(path, encoding="utf-8", errors="replace"):
        m = re.match(r"\s+(\S+:\d+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)", line)
        if m:
            site, kind, M, N, K, n = m.group(1), m.group(2), *map(int, m.groups()[2:])
            rows.append((site, kind, M, N, K, n))

    fam = {}
    for site, kind, M, N, K, n in rows:
        if kind == "gemm_int8" or kind == "gemm_int8_residual":
            b = gemm_bytes(M, N, K, c_half=(M <= 8160 or N <= 512))
        elif kind == "gemm_int8_qkv":
            b = gemm_bytes(M, N, K, c_half=True)
        elif kind == "gemm":
            b = gemm_bytes(M, N, K, c_half=True, a_int8=False, b_int8=False)
        elif kind in ("quantize_row", "quantize_window"):
            b = quant_bytes(M, N)          # ledger puts the width in the N column
        elif kind == "window_attention" or kind == "global_attention":
            b = attn_bytes(M)
        elif kind == "ffn_fused" or kind == "ffn_fused_stem" or kind == "ffn_fused_merge":
            b = gemm_bytes(M, N, K, c_half=True, a_int8=False, b_int8=False)
        elif kind == "upsample_add":
            b = M * N * 2 * 3
        else:
            continue
        fam.setdefault(kind, [0, 0])
        fam[kind][0] += b * n
        fam[kind][1] += n

    # window_block: the ledger's hooks could not read its shapes, but the probe
    # (window_block_probe.py, 768x448) lists the extents. At 960x544 the 32-channel
    # blocks run at the padded net; token counts from the probe's own table scaled to
    # this frame. Bytes = image in + image out, 32 channels fp16 = 128 B/token.
    # block0 448x768=5376 win, 224x384 ~1344-1421 win x9; tokens = windows*64.
    wb_windows = 5376 + 9 * 1380
    wb_tokens = wb_windows * 64
    fam["window_block"] = [wb_tokens * 128, 10]

    # measured device ms per family, from the ledger's kind table (960x544).
    measured = {
        "gemm_int8": 17.56 * 24 / (24 + 60), "gemm_int8_qkv": 17.56 * 60 / (24 + 60),
        "gemm": 0.71, "quantize_row": 3.09 * 224 / 281, "quantize_window": 3.09 * 52 / 281,
        "window_block": 9.04, "window_attention": 3.89, "global_attention": 0.67,
        "ffn_fused": 7.75 * 8 / 10, "ffn_fused_stem": 7.75 * 1 / 10,
        "ffn_fused_merge": 7.75 * 1 / 10, "upsample_add": 1.35 * 5 / 24,
    }

    print(f"{'family':20s} {'n':>4s} {'MB':>8s} {'floor':>6s} {'ms':>6s} "
          f"{'ms/floor':>8s}  bound")
    tot_b = tot_ms = 0
    for kind, (b, n) in sorted(fam.items(), key=lambda kv: -measured.get(kv[0], 0)):
        ms = measured.get(kind, 0)
        floor = b / COPY * 1e3
        tot_b += b; tot_ms += ms
        ratio = ms / floor if floor > 0 else 0
        tag = "BW" if ratio < 1.4 else ("mix" if ratio < 2.5 else "OVERHEAD")
        print(f"  {kind:18s} {n:4d} {b/1e6:8.1f} {floor:6.2f} {ms:6.2f} "
              f"{ratio:8.1f}  {tag}")
    print(f"\n  frame floor: {tot_b/1e6:.0f} MB = {tot_b/COPY*1e3:.2f} ms at "
          f"{COPY/1e9:.0f} GB/s copy roofline")
    print(f"  measured (these families): {tot_ms:.1f} ms -> "
          f"{tot_ms/(tot_b/COPY*1e3):.1f}x the byte floor")
    print("  ratio<1.4 = at the bandwidth wall (only lever: fewer bytes);")
    print("  ratio>2.5 = overhead/latency/launch bound (fusion + persistent help).")

if __name__ == "__main__":
    main()
