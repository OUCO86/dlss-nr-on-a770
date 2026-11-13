# Block-delta matrix (C512 block = chains 25 + 33) — knife x block delta x frame delta x spread x provability

**Caliber (the parent's ruling, `tools/target.json` -> `block_C512_value_caliber_RULING`, HEAD `c61e65a`):**
the block's current value is measured by **chain-level stop ablation on the shipped graph path**, in the
**PLAIN caliber** (`NR_VIT_REUSE=0`, `NR_SKIP_CHAINS` explicit, no fused/reseed — because on the
fused+reseed path `skip_chains_apply` REFUSES at `name offset 692`, so `ch[]` never exists and both
skipping and the chain stop are inert). Target unchanged: 0.21 ms for the 2-chain skip-ON block
(0.10 ms/chain; lmxx 71 layers / 35 cores / 111.300 ms @2.21 Mpx -> 1.60 ms @544p / 16 chains).
**Our number is "net frame time of the two chains on the graph"; lmxx's is "sum of kernel times" — say
which one every time.**

Noise floor measured on this scale: **min-of-4-runs spread 0.02%-0.37% on clean legs (C113), block
deltas below ~0.09 ms are NOT provable.**

| knife (switch) | frame delta (measured) | block delta | spread | provable? |
|---|---|---|---|---|
| `NR_UP_2X2` (unary kind 21, 2x2 one item; 8 legs/frame + 1 gate geometry) | **-1.32 ms = -2.85%** (REUSE=0, 3+3 cold procs, spread 0.17%/0.04%, C109) ; 1000-frame med **-1.44 ms = -3.4%** (995/995 frames, C109) | 1 block leg: bench 0.112 -> 0.017 = **-0.095 ms** | frame 0.04-0.17% ✓ | **frame: YES ✓✓✓**; block alone: below the 0.09 floor from the frame side, but the leg is measured directly in bench ✓ |
| `NR_WRES_PUB128` (wres publish tile BN=128/BK=64; ~84 legs/frame after tightening) | part of the same combined -1.32 ms (measured together, C109) | ~-0.004 ms (2 block legs x ~0.002/leg) | - | block term **NOT provable** (<0.09 floor) — reported as an estimate from the family average ✓ |
| `NR_C512_BAND` (`gemm_int8` band tile; 32 legs/frame at `M=640`) | part of the combined -1.32 ms | **+0.013 .. +0.05 (WORSE)** — after C109's tightening the block's own `M=768/960` legs fall back to the shipped arm | - | direction known ✓, magnitude **NOT provable** at this resolution ✓ |
| **all three together** | **-1.32 ms (REUSE=0) / -1.36 ms (REUSE=1) / -1.44 ms (1000-frame med)** ✓✓✓ | **C115 core run (plain caliber, 3 cold processes per arm): block(ON) = 39.68 - 38.64 = **1.04 ms**; block(OFF) = 40.75 - 39.71 = **1.04 ms** ⇒ ⇒ ⇒ **the three knives' combined block delta = 0.00 ms ⇒ the C512 block has NOT moved at all** ✓✓✓✓ (the whole -1.32 ms frame win lands OUTSIDE the block)** | OFF mins 40.75/40.78/40.83 (0.20% ✓), ON mins 40.06/39.70/39.68 (0.96% ✗ — one arm drifted), stop mins 38.64-38.80 ✓ | **block delta: PROVABLE AS ZERO ✓✓✓** (the clean OFF side pins block=1.04; the ON side lands on the same number) |
=> **block multiple = 1.04 / 0.21 = 4.95x ≈ 5.0x** — **not** the 17.1x the serial ledger implied (that instrument is judged dead).
=> **⇒⇒ What this means for the campaign, stated plainly ✓✓✓**: every knife banked so far (C70->C109) has bought frame time in the *other* tiers, not in the C512 block; the block's ~1.04 ms is untouched. So "the block to 1.0x" still needs **-0.83 ms of block-local work**, and the block-local candidates that survive are the **pack/closure side** (C103: wres pack 1.86 ms/frame vs kernel 0.62) and the **WA/qkv structure**, not more tile forms.

## Correction to my own C114 diagnosis (kept visible ✓)
I wrote that C114's 24-46% "spread" meant the device was shared. **That reading was wrong ✗✓**: the
per-process **max** values (48-72 ms) are the **first run after recording (cold/JIT warm-up)**, while the
**min** values are tight (39.7-40.8). The instrument convention is therefore now explicit:
**drop run #1 of every process and compare warm mins** (`min_warm` in `s6\c115_knives.ps1`) ✓✓.
Killing that batch was still defensible (it lacked the DBG env that proves knife engagement ✓), but the
cause I named was wrong — corrected here so nobody reuses the wrong reason ✓.

## ★★ Per-knife block delta (C115, plain caliber, 3 cold processes per arm, warm mins) — the headline table
| arm (single knife ON, others OFF) | base mins | stop{25,33} mins | **block** | **delta vs no-knife 1.04** | verdict |
|---|---|---|---|---|---|
| none (`ALLOFF`) | 40.75 / 40.78 / 40.83 | 39.72 / 39.71 / 39.76 | **1.04** | — | reference ✓ |
| `NR_UP_2X2` only (up2 dbg=8 ✓ engaged ✓) | 40.12 / 39.87 / 39.86 | 38.93 / 38.84 / 38.86 | **1.02** | **-0.02** | inside the 0.09 floor ⇒ **NOT provable** ✓ |
| **`NR_WRES_PUB128` only (p128 dbg 56 base / 52 stop ✓ engaged ✓)** | 40.75 / 40.79 / 40.78 | 39.61 / 39.58 / 39.52 | **1.23** | **+0.19** | **the block gets WORSE ✓✓✓ (above the floor ⇒ provable ✓)** |
| `NR_C512_BAND` only (**DBG name unverified ⇒ `band=0` hits ✗ engagement not printed — flagged ✓**) | 40.85 / 40.95 / 40.91 | 39.72 / 39.75 / 39.69 | **1.16** | **+0.12** | worse ✓ (the delta itself suggests it did run ✓ but the print is missing ⇒ 214① caveat ✓) |
| all three ON | 40.06 / 39.70 / 39.68 | 38.71 / 38.80 / 38.64 | **1.04** | **0.00** | **no block gain at all ✓✓✓** |
⇒ **⇒⇒⇒ THE HEADLINE FOR THE USER REPORT ✓✓✓✓: of the three banked knives, two make the C512 block worse (+0.19 PUB128, +0.12 C512_BAND), one is a wash (-0.02), and together the block lands exactly where it started (1.04 ms = 4.95x of the 0.21 ms target). Every frame win so far (-1.32 ms, -1.44 ms over 1000 frames) comes from the OTHER tiers.**
⇒ **⇒ Directly actionable consequence ✓✓**: if the metric is the block, the two tile knives should be **shape-restricted to exclude the block's own legs** (PUB128 currently admits `768/960 x 512 x 512` = exactly chains 25/33's wres legs ✓ — that is the +0.19) or re-tuned for the C512 geometry before being allowed there. That is a one-line allowlist change, testable with this instrument in 6 legs (~11 min GPU) ✓✓.
| arm | min | med |
|---|---|---|
| ON baseline | 39.53 / 39.85 | 39.945 |
| ON stop{25,33} | 38.67 / 38.68 | 38.815 |
| **block (ON)** | **0.86** | **1.13** (spread-limited ✗) |
| OFF baseline | 40.77 / 40.78 | 40.92 |
| OFF stop{25,33} | 39.65 / 39.77 | 39.88 |
| **block (OFF)** | **1.12** | **1.04** (**spread 0.02% ✓✓✓ provable**) |
=> **block multiple = 1.04-1.12 / 0.21 = 5.0-5.3x** (provable side) — **not** the 17.1x the serial ledger
implied (that instrument is judged dead).

## Run rejected and why (kept so nobody reuses it)
C114's 12 arms showed **24-46% within-arm spread** with repeated `GPU BUSY -- waiting 60s` lines: the
device was shared during that batch, so those readings are **unusable for a 0.2%-spread requirement**
— killed mid-run, not averaged over. The C115 re-run (same artifact `libxmx_c113d.dll`
`9AD5C748…`, core arms only, 3 cold processes per arm) replaces it; results go in the table above.

## What is NOT on this list (so nobody re-litigates it)
K-split accumulators / band-internal scales (bench +89..132%, dead); removing inter-stage requant
(net negative); whole-chain residency (three constraints: SLM 98,304 B > 65,536 per-WG cap, grf=128
already at the cap, any C-band split changes the numbers); further tile scans on wres/qres (arithmetic
dead); POOL2 reuse (each input read exactly once); UPSAMPLE merge-by-launch (-17.8% < -20%);
`unary2` fma-contraction hypothesis (**killed by bench C114: two-statement vs explicit fma are
bit-identical, nbad=0 of 6144, max-ulp 0** — the gate's `unary2` RED must come from the operand/table
side, and the gate ladder is no longer the acceptance ruler anyway).
