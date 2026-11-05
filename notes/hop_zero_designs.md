# Zero-hop designs and the first cut (knife2b #132, host only -- NO implementation)

Numbers come from `tools/hop_budget.csv` (per-plane accounting: 10.42 GB/frame, 18.60 ms floor),
`tools/hop_edges.csv` (per-edge accounting: 7.31 GB read, 26.10 ms write+read floor),
`tools/quant_scope_audit.csv` (276 quantisation points), `tools/xmx_roof.csv` (arm prices) and
`tools/ref_bench.csv` (the reference bar). The two hop accountings differ on purpose: the per-plane one
counts each write once (conservative), the per-edge one counts a write per reader (upper bound).
**Design targets are sized with the conservative number.**

---

## Design A -- the `QKV -> attention` round trip (156 edges, 2.22 GB read, floor 7.93 ms)

**What the hop is.** `qres::gemm_qkv_res` (NR_QKV_RES default ON, `libxmx_sycl.cpp:4294`) already produces
Q, K and V **plus the residual in one launch**, but the three planes still land in DRAM and the
attention closure reads them back. Fusing the attention scores into the QKV producer would remove that
write+read.

**Why it is not simply "extend A5".**

| tier | unfused qkv legs | K/V bytes per head (rows x C x 2) | Q/K/V write per chain | A5-style fusion status |
|---|---|---|---|---|
| C64  | part of the 60 | 192 x 64 x 2 = 24.6 KB | ~38 MB | **7 legs already fused (A5)**; the rest are the candidates |
| C128 | yes | 384 x 128 x 2 = 98 KB | ~150 MB | **measured RED**: the C128 fused tile needs SLM 41,984 B and ran +51% worse (section 101) |
| C256 / C512 | yes | 196 KB / 786 KB | bigger | SLM/GRF further out of reach; the 64 KB hard cap per WG is already exceeded at C128 |

**Budget check (rule 22/30).** A fused scores-into-QKV kernel must hold, per work-group, the Q row-band
(BANDS x 16 rows x C) plus the K plane for the head (rows x C) -- at C=128/rows=384 that is 98 KB of
operand alone, i.e. **3x the 32,768 B two-resident line and above the 65,536 B hard cap**.

**Verdict.** Only the **C64 tier** has a physically possible A5-style extension, and it is already the
tier where A5 runs (7 of 60 legs). **Remaining clearable by A: the ~9 unfused C64 qkv legs, i.e.
about 2.22 GB x (9/156) = 128 MB read + matching write => floor ~0.46 ms serial.** Small.
**A is NOT the first cut.**

---

## Design B -- the `QUANT` independent pass (the four QUANT edge classes: 2.25 + 1.70 + 1.64 + 0.49 + 0.25 ms floor; the 80 unfused quant closures measured 3.58 ms serial)

**What the audit says (`tools/quant_scope_audit.csv`).**
- **196 of 276 quantisation points are already DISSOLVED** into their producer's store (qfuse / P8-l), costing 0.439 ms of bookkeeping.
- **8 points are CLEARABLE as they stand** (row fits inside one work-group tile): 0.019 ms -- noise.
- **72 points are NOT clearable at the current tiles**, and they are the expensive ones: **3.584 ms measured**.
  Their row lengths: `K=256` x24, `K=2048` x16, `K=128` x12, `K=512` x12, `K=1024` x8 -- i.e. the row-max
  spans more columns than any single work-group of the producer owns, which is exactly the condition
  that killed s8v9's fused requantize at the multi-group shapes (section 99: `sc=128 < ldc=256`, the
  row-max would have to see another group's columns).

**The two sub-cases.**
1. **`K <= BN_of_producer` (the 12 K=128 + 24 K=256 legs, measured ~1.6 ms serial)**: foldable with a
   **wider producer** -- `BN=128` exists (s8v9, `slm 13,312 B`, scratch 0/0, measured 3.0x slower at
   8160x128x128) and `BN=256` does not exist. **Before any implementation, the price of a BN=256
   producer must be measured** (roof rows: none exist at K=256 with BN=256).
2. **`K >= 512` (the 36 expensive legs, ~2.0 ms serial, incl. the 16 x 33.55 MB K=2048 planes at 0.104-0.111 ms each)**:
   the row cannot live in one work-group at any sane tile. Folding here needs a **cross-work-group
   reduction** (two-phase: producer publishes partial row-max in SLM + a tiny fixup pass) -- that is a
   NEW mechanism, not an extension of qfuse, and it changes nothing numerically only if the fixup is
   the same `fdiv_rn/rint` chain (precedent: the P8-l publish fold).

**Verdict.** **B is the first cut**, but only case (1): extend the fold to the K=128/K=256 producers
after pricing a BN=256 wide producer (roof measurement first, then a bench pair). Ceiling = the
measured 1.6 ms serial of those 36 closures, times whatever the wider tile keeps.

---

## Design C -- `window_block` (10 legs, 17.9 ms serial, 6.89 ms above its 4-phase roofs)

The hop ledger gives this family small floors (operand 1.21 + write 0.21 ms) and its four gemm phases
already explain 9.61 ms of 17.92; `NR_WB_FUSE` is worth +0.08 ms when switched off (section 98) and
section 105 measured the two v4ph legs as **neither bandwidth- nor XMX-bound**. So its remaining
6.89 ms is **inside-kernel serialisation, not a hop** -> it needs the launch-level instrument
(suppressed) or a phase-by-phase bench, **not** a hop removal. **C is not a hop design.**

---

## The `[hop]` instrument (rule 104 enforcement -- design only, ~30 lines, print-only at capture)

Per closure at record time we already know the operand plane list (`g_cmds_touch`) and the output
plane list (the ROLE tables used by `s6/pe_hop_budget.py`). Add, gated by `NR_HOP`:

```
[hop] cmd=<idx> name=<closure> w=<n_planes>(<bytes>) r=<n_planes>(<bytes>) planes=<ids...>
```

plus a per-frame total line `[hop-total] write_bytes=… read_bytes=… edges=…`. Because it is computed
from the same vectors as `[vec-align]`/`[poolseq]`, it inherits rule 57's five-vector discipline (no
new per-closure vector unless it is cleared at `xmx_begin`/`xmx_abort` -- the §B step-1 bug).

**Acceptance for every cut:** the `[hop]` diff between the two arms must show the byte drop for that
edge class, **not only the time change** (the parent's rule: no time-only inference).

---

## First cut to price (proposal, implementation NOT approved)

**Cut 1 = Design B case (1): requantize fold for the K=128 / K=256 producers.**
- **Target closure list**: the 36 quant closures in `tools/quant_scope_audit.csv` with
  `clearable != no` after a BN>=K producer (K=128: 12 legs; K=256: 24 legs), measured 1.6 ms serial.
- **Prerequisite measurement (GPU, cheap)**: roofs for a **BN=256 producer** at the frame shapes
  (`int8 8160x128x128`, `9216x256x?`, `640x2048x512`...) -- no such kernel exists, so this is a bench
  kernel built from `s8v9` with `BN=256` (geometry change, same pack family). **~24 processes.**
- **Bench pair protocol (rule 74)**: >=10 processes per shape, >=60 s apart, min-of-15x5, nosink,
  paired inside the same process (rule 55), **byte diff = 0** (value-preserving fold), ledger per
  column with priced legs `scratch=0/instr=0`, `private/spill = n/a(ocloc1.73)`.
- **Pre-registered judgement**: `ratio = split_price / folded_price >= 1.3` -> report for approval;
  `< 1.3` -> stop. Frame line: 16 pairs, <= -0.5 ms/frame and >= 10/16 wins to promote.
- **Hop witness**: `[hop]` diff on the QUANT edge classes must show the read+write bytes of those
  36 planes disappear.
