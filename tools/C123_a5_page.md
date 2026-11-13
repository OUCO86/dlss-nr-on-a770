# A5 (`att5::fused`) — what one fused launch actually holds, and whether its SLM layout transfers to the C512 block

Source read, zero GPU: `src/bench/sycl/libxmx_sycl.cpp:928-1115` + one `NR_ATT5_TRACE=1` leg (`logs/C123_trace.log`, 909 trace lines, `RF=0`/`LOST=0`).

## 1. The state machine (verbatim structure)
| stage | recorder taken | line |
|---|---|---|
| 1 | `xmx_rec_quant_window` (`g_a5.c_qw`, stores `src/pk/sc/M/K/ih/iw/across/pad`) | `:988-991` |
| 2 | `xmx_rec_gemm_int8_qkv` (`c_qkv`, weights `wqkv`, `bsqkv`, `qkv_scale`, ids `q/k/v`) | `:1037-1043` |
| 3 | `xmx_rec_window_attention` (`c_wa`, `bias`, `att`, `batches`) | `:1045-1052` |
| 4 | the second quant (`c_q2`, `pk2`, `sc2`) — **optional** | `:1056-1060` |
| done | the window-residual leg = the chain's last op ⇒ **"the four earlier closures become no-ops and THIS closure runs `att5::fused`"** | `:1067-1068` |

Gates: `a5_gap(prev, cmd)` (the closures must be adjacent in the recording) + a tuple check per stage
(`:1039-1040`, `:1050-1051`) + `batches/heads * tokens == M` (`:1051`).

## 2. What the fused launch keeps resident (from a real `[a5-fire]` line)
```
[a5-fire] n=1 M=32640 C=64 heads=2 windows=510 across=30 pad=0 img=136x240
          noop=19/20/21/0 fused@23 WKeyQKV=(82,192,64,0) WKeyPROJ=(80,64,64,0)
          qkv=1276/1275/1277 pk=1273/1274 pk2=...
```
- **resident inside the one launch**: the packed A (`pk = 1273/1274`), and the **Q/K/V planes
  (`1276/1275/1277`) become internal faces** — `:1108-1110`: *"the fused closure also reads/writes the
  Q/K/V planes (they are its internal faces now that 642/643 are no-ops)"* ⇒ those three faces stop
  round-tripping through global for that chain ✓✓✓
- **still in global**: the chain input (`src = 1268` on the geom line), the weights (`WKeyQKV`,
  `WKeyPROJ`), and the chain's output face (the `wres` target, e.g. `1284/1288`) + the scale arrays.
- **bookkeeping requirement**: the fused closure touches planes that `645`'s own `pgraph_ids()` never
  listed, and the scheduler treats "same device pointer in two closures" as a conflict in **any**
  direction (`:118-143`), which is exactly what produced the historical **82.6 % scattered divergence**
  on real plan data (knife2b #82/#83) ⇒ `pgraph_extra()` exists for out-of-band touches (`:1113-1115`),
  with `NR_ATT5_TOUCH=0` as the A/B switch. **Any new fusion must carry these declarations or it is a
  race, not a speed-up** ✓✓✓

## 3. Does its SLM layout transfer to the C512 block? — **No, by arithmetic** ✓✓✓
Every fired chain is **C=64 / heads=2 / K=64**; the block's chains 25/33 are **C=512 / heads=16 /
K=512** and are rejected at **stage 1 with reason `M/K/geom`** (`[a5-geom] qw cmd=304 ... M=768 K=512
ih=20 iw=32 across=4 pad=262144` ⇒ `[a5-dbg] qw-REJECT ... M/K/geom` ✓✓).

Per-window residency cost, one 64-token window:

| quantity | C=64 (fires today) | C=512 (the block) |
|---|---|---|
| Q/K/V int8, 3 × 64 × C | 3 × 4,096 B = **12,288 B** | 3 × 32,768 B = **98,304 B** |
| packed A row group | 4,096 B | 32,768 B |
| scores f16 64×64 | 8,192 B | 8,192 B |
| **total** | **~24.6 KB ⇒ ≤ 43,690 ⇒ 3 WG/Xe-core ✓** | **≥ 139 KB ⇒ > 65,536 per-WG cap ✗✗✗** |

⇒ **98,304 B is exactly the number that killed the whole-chain residency in C100** ✓✓ — the C=512 case
cannot be made resident per window, and the only way to shrink it is to split the 512 channels across
work-groups and hand off partials, which is the K-split / band-scale line already priced at **+89…132 %
(bench) and forbidden by rule 218** ✓✓✓.

⇒ **⇒⇒⇒ Consequence for the campaign ✓✓✓**: A5-style fusion is **not** available to the C512 block. The
block's 0.57 ms/chain and its 1.04-1.13 ms total are therefore not "un-fused slack" — the fusion route
that the rest of the model already enjoys is closed here by the channel count. Any further block win
has to come from **not materializing the 512-channel planes at all** (fewer channels, different window
tiling, or a different attention form), i.e. a model/layout change with picture-level consequences —
not from a scheduling or residency knife.

## 4. What the pricing legs add (filled after the run)
`stop{chain 1}` (A5-fired) vs `stop{25}`/`stop{33}` (rejected), same session, 3 cold processes each,
warm-min, paired with each chain's own byte-audit total ⇒ **ms per MB for a fused chain vs a split
chain** — that is the empirical size of the fusion advantage, so the "fusion is closed" claim above is
backed by measurement and not only by the SLM arithmetic. *(numbers in `s6/layer1.md §220`.)*
