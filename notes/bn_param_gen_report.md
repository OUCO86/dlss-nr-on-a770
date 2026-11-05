# BN-parameterized wide producer -- generator, structural diff, budget (knife2b #135 item (A), ZERO GPU)

## What exists now
- generator: `s6/pe_mk_bnparam.py` (single source of truth: `gemm_s8_v8_kernel.hpp:139-204`, the
  batched `gemm_b` with raw int32 C);
- output: `s6/gemm_s8_param.hpp` -> `s8par::gemm_b_param<BM,BN,BK>(q, Ap, Bp, C32, Mp, N, K, batch)`;
- compile proof: `s6/bnparam_check.cpp` instantiates `<128,64,32> <128,128,32> <128,256,32>
  <128,512,32>`; `icx -fsycl -c` => **exit=0** (obj 82,878 B). **Compile only -- no GPU was used, and
  nothing was linked or run.**
- **bench TU only**: the file is never included by `libxmx_sycl.cpp`.

## Structural diff against the shipped body (the honest list of what the generator changed)
Every change is a literal -> formula in BN; the algorithm is untouched.

| shipped line (`gemm_s8_v8_kernel.hpp`) | generated | why it is BN-derived |
|---|---|---|
| `int wi_row = lid / 4, wi_col = lid % 4;` | `lid / WI_COLS`, `lid % WI_COLS` with `WI_COLS = BN/16` | the 4 is the shipped `BN/16` |
| `nd_range(range(wg*batch*NT), range(NT))` with `NT = 32` | `NT = WI_ROWS * WI_COLS` | widening BN adds work-items across the row instead of more accumulators per item |
| `apb + kb*SLM_A + lid*128` (A block load 128 B) | `lid*A_LD`, `A_LD = SLM_A/NT` | 128/64/32 B per thread at BN=64/128/256 |
| `bp + kb*N*32 + lid*64` (B block load 64 B) | `lid*B_LD`, `B_LD = SLM_B/NT` | **provably constant 64** for BM=128, BK=32 (BN cancels) |
| `apb_g + (wg_row*(K/BK))*8*512` | `... * SLM_A` | identity: 8*512 = BM*BK |
| `bp_g + wg_col*(BN/8)*256` | `... * (BK*8)` | identity: 256 = BK*8 |
| `offA = buf*SLM_A + wi_row*512`, `offB = ... + wi_col*512` | `A_ROW = B_COL = BK*16 = 512` | unchanged value, named |
| `slm_init<3*SLM_A + 3*SLM_B>()` | same expression, SLM_B grows with BN | three-buffer s8d2 form preserved |
| the `for b` k-loop, `cur = b%3`, depth-2 prefetch, `esimd::barrier()` | **verbatim** | unchanged |
| `dpas<8,8,int32_t>` into `c00,c01,c10,c11` (four `simd<int32_t,64>`) | **verbatim** | each work-item still owns one 16x16 quad |
| the store pass (`row0/row1` assembly, `block_store<int32_t,16>`) | **verbatim** | 16 columns per item either way |
| operand maps `pack_a` / `pack_b` | **not touched** | `pack_b` already takes N; the packed-B tile size is (BN/8)*256 per column-group, which the base-pointer formula handles |

**So the claim "only tile-parameter lines differ" is verifiable by diffing the two bodies; nothing in
the reduction order, the k-loop, or the store map changed.** That makes this a **pure BN experiment**
(unlike s8v9, which changed BM and BN together -- rule 119).

## Budget self-check (rule 118; per-EU SLM = 64 KB, the ledger's own basis)
| BM | BN | NT | SLM total (3A+3B) | resident WG/EU | accumulators | A_LD | B_LD | WGs covering a row at N=256 / 768 / 1024 |
|---|---|---|---|---|---|---|---|---|
| 128 | **64 (shipped)** | 32 | 18,432 | **3** | 4 x simd<int32,64> = 2 GR/lane, **not** in the >8 zone | 128 | 64 | 4 / 12 / 16 |
| 128 | 128 | 64 | 24,576 | 2 | same 4 | 64 | 64 | 2 / 6 / 8 |
| 128 | 256 | 128 | 36,864 | **1** | same 4 | 32 | 64 | 1 / 3 / 4 |
| 128 | 512 | 256 | 61,440 | 1 | same 4 | 16 | 64 | 1 / 2 / 2 |
Nothing is killed by the 65,536 B hard cap; **BN=512 has only 4 KB/EU spare and A_LD=16 B is below the
16-byte aligned block-load sweet spot**, so BN=512 is expected to be the weak end and BN=256 is the
interesting one. **Occupancy is the variable under test: 3 -> 2 -> 1 resident/EU.**

## What the (B) batch can therefore measure (GPU, awaiting approval)
arms in ONE process, region-bracketed (`timeit_region`), 12 processes/shape:
1. `s8v8::gemm_b` (shipped BN=64, raw int32 C) vs `s8par::gemm_b_param<128,256,32>` at
   **2560x256x256b1** (winres, 16 legs, RT_ms_upper 3.87) -- **pure BN, same BM/BK/chain**;
2. `BN=64` vs `BN=256` at **2560x768x256b1** (qkv, 16 legs, 3.76) -- labelled **"wide, not BN=N"**
   (N=768 still spans 3 column groups);
3. `BN=64` vs `BN=128` and `BN=256` at **8160x128x128b1** (the control family where s8v9 was 3.0x
   slower -- with a pure-BN arm we finally separate BM from BN);
4. **fold legality is a separate arm**: `gemm_b_param` (int32 C) -> `qr_kernel` (the (2) arm) vs
   `v9`'s fused requantize, byte-compared on the int8 plane + scales. Speed never stands in for it.

Pre-registered line unchanged: `ratio = BN64 / BNwide >= 1.3` on any N>=256 shape -> engine
discussion; all < 1.3 -> the wide-producer line closes (then: BN=32 fast 2.1x, BN=128@8160 slow 3.0x,
pure-BN 128/256 by this shot) and the next knife is the two-phase cross-WG row-max (B case 2).
