# BN=32 routing feasibility at the frame's N=128 int8 shapes -- pure code reading (no GPU)
Order: knife2b #126, shovel (a). Sources are quoted with line numbers from
`src/bench/sycl/libxmx_sycl.cpp` and `src/bench/sycl/gemm_s8_v8_kernel.hpp`.

## Verdict (three-state)
**`routing 合法（画质零代价）` -- BUT the shipped comparator is NOT the arm my roof table measured,
and the env switch alone will not fire at N=128.** Two hard preconditions:

1. **The shipped N=128 route is `s8v8::gemm_b_pub_slm<HALF>` (acc-via-SLM publish tail), not
   `gemm_b_pub`.** `libxmx_sycl.cpp:4108-4117`:
   `if ((N % 64u) == 0u && (epi == 0u||1u||3u||4u)) { static bool pubslm = ... : true; if (pubslm && N == 128u) s8v8::gemm_b_pub_slm(...) }`
   Its own comment: "the N=128 batched family rides the senior's acc-via-SLM tail (bench_batched:
   BIT-EXACT diff 0, 0.148->0.112 / 0.227->0.210 / 0.196->0.150 at the frame's three N=128 shapes)".
   => **`xmx_roof.csv` has NO row for `gemm_b_pub_slm`** => the "BN=32 is 2.1x faster" reading
   (0.0370 vs 0.0782) compared BN=32 against a **non-shipped** arm. The real price pair is
   `gemm_b_pub_slm` vs `gemm32_b_pub`.
2. **`NR_G32_PUB=1` will NOT fire at N=128 as the code stands**: the pubslm branch (4108-4117)
   returns before the g32pub branch (4148-4154) is reached. The header comment at 4137-4144 already
   records that for the 20 N=32 calls the P8-b wide-merge branch catches them first ("a probe print
   in a rebuilt dll fired ZERO times with NR_G32_PUB=1 during a full replay -- proof, not inference").
   => To exercise BN=32 at N=128 one needs `NR_PUB_SLM=0` + `NR_G32_PUB=1` together, which ALSO moves
   every N%64 leg from the SLM tail to the register tail -- two variables at once, so the bench must
   price the three arms separately (see below).

## Q1 -- pack_b layout / stride constraints at BN=32, N=128
`gemm_s8_v8_kernel.hpp`:
```
void pack_b32(const int8_t* B, int8_t* Bp, int N, int K) {   // identical map to pack_b --
    pack_b(B, Bp, N, K);                                     // it already takes N (N/8=4 tiles at 32)
}
```
=> **BN=32 and BN=64 consume the SAME packed B layout** -- the map is tiled by 8 columns and 32-deep
k-blocks, so BN only decides how many tiles one work-group reads (N/8 = 16 tiles at N=128; BN=32 takes
4 of them, BN=64 takes 8). The device mirror used by the batched family is
`packdev::gather_pack_b_b(*GQ, Braw, dBp, N, K, ldb_e, sb, batch)` (`libxmx_sycl.cpp:3983`) -- one
packer serves both routes.
=> **Correction to my own ledger note**: the `gemm32_b_pub_forced` roof rows were annotated
"operands packed for BN=64: timing representative, VALUES meaningless". That annotation is WRONG --
pack_b32 IS pack_b, so the forced legs used the correct operands and their values are meaningful.
(Also fixes the concern that (b) would need two different packings: it does not.)
Plan-real N=128 batched legs (from `tools/shapes_census.csv` / the plan tuples):
`32640x128x64 b2 (x16)` and `8160x128x128 b4 (x24)` -- note these are the multi-group INTERLEAVED
calls (sc < ldc), exactly the structure that killed s8v9's fused requantize (section 99);
`gemm32_b_pub` takes the same `sc/ldc/scale_stride/col_stride` parameters as `gemm_b_pub`, so the
addressing is compatible; the single-group shapes my roof probe measured (8160/8640/9216 x128 x128
b1) are a DIFFERENT population (they come from the residual/qkv families' phase geometry).

## Q2 -- publish/store addressing: byte-identical?
Both tails compute the same address expression:
* `gemm_b_pub`:  `size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;` (and `rr1` for the second
  8-row half), then `esimd::convert<half>(pub).copy_to((half*)Cout + out)` / `pub.copy_to((float*)...)`
* `gemm32_b_pub`: `size_t out = (size_t)g * sc + (size_t)rr0 * ldc + gc;` -- same form, same narrow /
  epi chain (`pub_vec_v8<16>(epi, convert<float>(acc) * rs * cs)`).
=> **byte-for-byte the same destination map** (P8-b precedent class: `sc==N && ldc==N*batch` style
constraints are passed through unchanged). No stop-the-line condition here.

## Q3 -- does changing BN change the reduction order (i.e. is it numerics-free)?
* k-loop in both: `for (int b = 0; b < kb_n; ++b` (ascending, kb_n = K/32);
* accumulator chain in both: `dpas<8, 8, int32_t>(c00, b0, a0) / (c01, b1, a0) / (c10, b0, a1) / (c11, b1, a1)`
  -- four int32 accumulators per work-item, 8x8 tiles, int32 (exact) additions;
* what BN changes is **which columns a work-item owns** (`WI_ROWS=BM/16`, `WI_COLS=BN/16`;
  `gemm32_b_pub` uses `COL_BANDS = BN32/16`), i.e. the mapping WI -> output columns, NOT the per-element
  k-order.
=> **Every output element accumulates over the same ascending kb sequence of int32 dpas steps in both
kernels => bit-exact** (int32 addition is associative/exact, and the order is identical anyway).
=> So the knife is **quality-zero-cost** in principle; the final proof remains the 1301 byte-diff gate
(dual EXACT `DD49827D`) once it is actually routed -- I do not claim it here.

## Q4 -- the existing N=32 precedent and what must be relaxed for N=128
Guard text (`libxmx_sycl.cpp:4148-4151`):
```
static bool g32pub = getenv("NR_G32_PUB") ? atoi(getenv("NR_G32_PUB")) != 0 : false;
if (g32pub && (N % 32u) == 0u && (epi == 0u || epi == 1u || epi == 3u || epi == 4u)) {
    s8v8::gemm32_b_pub(*GQ, dAp, dBp, Cout, as, bs, M, Mp, N, K, batch, sc, ldc_, scale_stride,
                       (sb != 0u) ? N : 0u, narrow, epi);
    pool_put(dAp); return;
}
```
* The guard itself already admits N=128 (`N % 32 == 0`, epi 1/4 are the frame's N=128 epilogues).
* What blocks it for N=128 is **branch order** (the `pubslm` branch at 4108-4117 returns first), and
  for N=32 it is the **P8-b wide-merge** branch above both.
* So routing N=128 to BN=32 needs either (i) `NR_PUB_SLM=0` (reverts the whole N%64 family to the
  register tail, then `NR_G32_PUB=1` fires) -- mixes two changes, or (ii) an engine edit that tests
  g32pub before pubslm -- **implementation, not approved**.

## What the roof table still lacks before any price is quoted
1. **`gemm_b_pub_slm` roof rows** (the shipped N=128 arm) at 8160/8640/9216 x128 x128 b1 and at
   `32640x128x64 b2` / `8160x128x128 b4` (the frame's real multi-group shapes). The probe can add a
   `SRP_PUBSLM=1` leg (the kernel is in the same header; `template <bool HALF>`, SLM 32,768 / 18,432).
2. **The capacity curve at SLM=32,768 B** (the shipped pub_slm arm reserves 32 KB, so 2 resident per
   EU, not 3) -- my measured curve used 18,432 B.
3. Only then: the (b) three-arm bench (`gemm_b_pub` / `gemm_b_pub_slm` / `gemm32_b_pub`), >=10 procs
   per shape, same-process pairing, byte-diff 0, ledger with scratch 0/0 and `n/a(ocloc1.73)`.

## Occupancy context the reading also surfaced (do not lose)
* `4111-4113`: "N=64 keeps the register tail -- the 32KB stage costs occupancy there (0.033->0.074,
  the v9c lesson)";
* `3870-3872`: v9b (BM=32 wide-N merge) measured 0.53-0.80 ms vs 0.11-0.21 ms through v8
  `gemm_b_pub_slm` -- "the v9b default was MASKING C2 (those calls never reached pub_slm)".
=> Two prior occupancy traps in exactly this corner; the fill lever must be priced against
`pub_slm`, not against the register-tail arm, or it will repeat them.
