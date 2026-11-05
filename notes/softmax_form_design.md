# Softmax form design (knife2b #133, host only -- NO implementation, NO GPU spent)

Basis: `s6/pe_ga_reg_merge.py` readings in `tools/ga_autopsy_region.csv`, the shipped call site
`src/bench/sycl/libxmx_sycl.cpp:4843-4846`, and the kernel text
`src/bench/sycl/softmax_kernel.hpp` (`smax::vit_softmax_tiled`).

## 1. What is measured (six-launch REGION arms, 6 processes, min-of-15x5, nosink)

| arm | ms | spread |
|---|---|---|
| `REGION_all6` (the whole ga closure body) | **2.2767** | 1.9% |
| `REGION_no_softmax` (same chain, softmax removed) | **0.1749** | 10.3% |
| `REGION_softmax_only` | **2.0402** | 1.6% |
| `vit_softmax_tiled` single-kernel span | **2.0175** | 0.0% |
| the three pack arms | 0.0015 / 0.0016 / 0.0016 | 39-80% (1.1-1.2x their byte floor -> healthy) |
| the two gemm arms | 0.1248 / 0.1326 | 62-70% |

**softmax share of the chain = 2.2767 - 0.1749 = 2.1018 ms per ga leg.** Eight legs in the frame
=> **16.2-16.8 ms serial** (CEILING basis: the measured per-leg cost x the leg count; realization is
unknown until a paired price exists). The frame is 57.3 ms, serial sum 114.63 ms, factor 0.50
(`tools/frame_factor.md`), so this is the largest single-kernel hole found in the whole investigation.

Its own byte floor is 0.0126 ms (7.08 MB: `heads*rows*rows` f32 read + f16 write at the measured
560 GB/s anchor) => **the kernel runs 160x above its traffic floor**.

## 2. Why (read off the source, not inferred)

`vit_softmax_tiled` is launched as `parallel_for(range(heads*rows), ...)` = **6,144 work-groups of ONE
work-item each** (`unsigned r = it.get_id(0); if (r >= nrows) return; const float* row = src + r*stride;`).
Each item then walks ITS OWN row, in blocks of 64 columns:

```
for b in blocks:                       // tokens=192 -> 3 blocks
    for c in 0..7:
        for j in 0..3:
            k0 = b*64 + c + 16*j ; k1 = k0 + 8
            w0 = vit_weight(row[k0]); w1 = vit_weight(row[k1])
            pair[j] = cr_hadd(w0, w1)
        column[c] = hadd(hadd(hadd(pair[0],pair[1]),pair[2]),pair[3])
    total += hadd(hadd(column0,column2,column4,column6), hadd(column1,column3,column5,column7))
recip[r] = qr_half_round(fdiv_rn(1.0f, total))
for k in 0..stride-1: Ap[tile(k)] = half(qr_e4m3(vit_weight(row[k])))   // scalar, one f16 at a time
```

Two structural costs, both fixable without changing a single value:

1. **One lane of parallelism per row.** 192 columns are processed by a single thread; the machine has
   32 lanes per subgroup. 6,144 tiny groups = launch/scheduling churn plus 1.18M scalar `vit_weight`
   evaluations (2.02 ms / 1.18M = 1.7 ns/element, i.e. a few scalar instructions per element).
2. **Scalar stores.** The A-tile map is `h*per + ((tr*kb_n+kc)*2+strip)*128 + il*16 + k16`: the last
   index `k16` runs 0..15 **contiguously**, so 16 halfs = **32 bytes per store** are available, but the
   loop writes one f16 at a time.

## 3. The bit-exact contract that must survive (from the header, lines 5-15)

- `totals` is defined by **exactly this pairing and this tree order**: pairs are `(k, k+8)` for
  `k = b*64 + c + 16*j`; `column[c]` folds `pair[0..3]` left-associatively; the block total folds
  `even/odd` columns; blocks accumulate into `total` in increasing `b`. **A butterfly/relaxed reduce
  changes the answer** -- the header says so explicitly for the sequential variant, and the tiled one
  reproduces the vendor's half-domain tree (`cr_hadd` on packed half pairs).
- `recip = qr_half_round(fdiv_rn(1.0f, total))`, one per row.
- per element: `qr_e4m3(vit_weight(row[k]))` -- a *pure function of the element*, no cross-element
  state, so it can be evaluated in any order.

## 4. Proposed form (value-identical by construction)

**Work-group = 8 rows x 32 lanes** (`nd_range<2>(rows_rounded*32? ...)` -- exact launch geometry to be
fixed in the bench kernel first). Per row, per 64-column block `b`:

- **lane `l` (0..31) owns one pair**: `c = l % 8`, `j = l / 8` => `k0 = b*64 + c + 16*j`, `k1 = k0+8`.
  That is exactly the shipped pairing, so `pair[j]` for all (c,j) exists simultaneously across the
  subgroup -- **same values, same pairing**.
- `column[c] = hadd(hadd(hadd(pair[c,c+8],pair[c,c+16]),pair[c,c+24]),pair[c,c+32])` needs the four
  `j` values of the same `c`: lanes with the same `c` are `l = c, c+8, c+16, c+24` => **three
  `shift_group`/`perm_group` steps at distances 8, 16, 32 in a fixed order** reproduce the
  left-associative fold exactly.
- the block total: `even = hadd(hadd(hadd(col0,col2),col4),col6)`, `odd` likewise, then
  `cr_hadd(even, odd)` -- 8 columns => after the previous step lane `c` holds `column[c]`, so the
  even/odd folds are 3 + 3 shuffles at distances 2, 4 and one cross-lane `hadd`. **Deterministic order,
  same tree.**
- block accumulation into `total` stays in increasing `b` (a scalar loop over 3 blocks per row).
- `recip[r]` written once per row by lane 0.
- **normalise+store pass**: same lane mapping over `k16` runs: each lane computes 2 elements
  (`row[k]`, e4m3) and the 16 contiguous `k16` values land in **one 32-byte store** (a
  `simd<half,16>` write, or 2 x `simd<half,8>` if the map needs it).

Nothing in this changes: the pairing, the fold order, the block order, `fdiv_rn`, `qr_half_round`,
`qr_e4m3`, or the destination addresses. **The claim to be tested is exactly "same bytes out"**, and
the probe already has the `DIFFARM` pattern to prove it (old kernel writes `Ap_old`, new writes
`Ap_new`, byte-diff the plane + the `recip` array).

## 5. Budget check (rules 22/30)

- registers: each lane holds 2 floats per block (`w0,w1`), the running `pair/column` values (<= 8
  floats) and `total` -> well inside the 128-GRF ceiling at `simd=1`..`simd=8`;
- SLM: only if the shuffle route is rejected -- 64 floats per row staged = 256 B x 8 rows = **2 KB**,
  far under 32 KB;
- barrier count: 0 in the shuffle version (sub-group shuffles need no barrier); the SLM version needs
  1 per block per row-band (3 for tokens=192) -- **must be re-audited with `barrier_audit_*` before any
  engine use** (rule 30/63);
- launch count: `6144 groups -> 768 groups` (8 rows each) at the frame geometry. **That is the
  acceptance number for the "small WG" defect.**

## 6. What must be measured before any engine work

1. **bench arms** in `shape_roof_probe.cpp`: `SMAX_OLD` (shipped `vit_softmax_tiled`) vs `SMAX_NEW`
   (the form above) at the frame geometry (rows=192, tokens=192, heads=32) and at the two other
   in-frame attention geometries; `DIFFARM` byte-diff of `Ap` + `recip`;
2. **paired unit price**: >= 10 processes per shape, >= 60 s apart, min-of-15x5, nosink, paired inside
   the same process (rule 55), ledger rows with `scratch=0/instr=0` and
   `private/spill = n/a(ocloc1.73)` (rule 86);
3. **pre-registered judgement**: `ratio = OLD_ms / NEW_ms >= 1.3` -> report for engine implementation;
   `< 1.3` -> the form change is not worth it and the softmax hole stays open (reported as such);
4. only after that: engine route (a new gate `NR_SMAX_FORM`, default 0), the full gate chain
   (dual 1301 EXACT `DD49827D…`, `[vec-align]` five vectors, `[poolseq]`/`[pgt-final]`
   declare-vs-measured, >= 4 processes distinct md5, 40 gates, frame 16 pairs, <= -0.5 ms/frame and
   >= 10/16 wins), and the `[hop]` witness diff (this change does NOT remove a hop -- it makes the
   existing kernel wider -- so the hop counters must stay identical; that is its own check).

## 7. Honest caveats

- The 16.2-16.8 ms serial figure is a **CEILING basis**, not an expected saving; the realized saving
  depends on how much of the 160x gap is scalar-issue cost versus launch/scheduling cost, which only
  the bench pair answers.
- `REGION_no_softmax` (0.1749 ms) is itself **below** the sum of the two single-kernel gemm spans
  (0.1248 + 0.1326 = 0.2574) -- the same L2-hot effect seen in `chain_gemms_only` (0.0417 vs 0.1333):
  **single-kernel spans measured on an idle queue are inflated**; when the new form is priced, the
  comparison must be done with REGION-bracketed arms on both sides (rule 74's pairing plus the new
  bracket rule).
- The 8 ga legs are all at `rows=192/tokens=192/heads=32`; other attention shapes
  (`window_attention`, 45-52 legs) use different softmax instances -- this design targets the ga one
  first because it is the measured 2 ms hole.
