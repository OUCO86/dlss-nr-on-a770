# What the other two trees are doing

Read on 2026-10-09, while looking for anything we have not tried. Both are the same
network as ours; neither is a drop-in, because neither is our graph. What follows is
what is worth taking and what is not, with the reason in each case.

## The upstream we forked from: `Uzbekunknown/dlss-nr-on-intel`

The `windows` branch moved from `ec09d3e` to `2cba658` since we last looked. The whole
diff is **product, not performance**: a setup window, a `vulkan-1.dll` proxy so that
whatever starts the game — Steam, a launcher — gives NR its environment
(`src/layer/nr_vulkan_proxy.c`, 258 lines, plus generated exports), and a daemon that
ends with its game. `src/gpu/` is untouched.

Two things there are worth having eventually, neither of them speed:

- the proxy, which is how NR would survive being started by Steam rather than by our
  own batch file;
- `windows_launch.py` / the wizard, if this ever has to be installed rather than run.

Nothing in it changes a kernel, a tile or a barrier. Do not go looking for speed here.

## `gggz114514-oss/dlss5nr-b580-intelarc`

Same network, **Intel Arc B580 — also Xe2, also XMX**, but a completely different
stack: PyTorch XPU plus Triton kernels, not our resident Vulkan graph. Their numbers
are not comparable to ours and mostly are not better: their accepted line is
**55–60 ms at 1280×720** in Cyberpunk, and their off-line `process` is 45–46 ms at
864×480. We are at **44 ms at 768×448** — roughly half. So read this tree for
*methods*, never for a speed claim.

What it is genuinely good at is **writing down what failed**. Their
`docs/history/DEVELOPMENT_HISTORY.md` is the rare document that records the negative
results as carefully as the positive ones, and several of them are things we were
about to try:

| Their result | What it means for us |
|---|---|
| 无损 INT8: CPU eligibility 0/16/92%, real GPU **0%**; dynamic check + compensation + spill ate the gain; one path **25.6× slower** | Confirms our own finding that int8 here is a *quantised* path with a quality contract, not a lossless reformulation. Do not chase exactness. |
| ESIMD DPAS v2: full NR +2.843% fast, residual 0.546% **slower** | "A faster primitive is not a faster pipeline." We saw the same thing with NG unrolling. |
| `cut`/tile: good locally, **+5.5396 ms** on the full chain | The trap we already fell into with 1080p micro-benchmarks. |
| `a_insitu` W8A8 unfused: **+13.3%**, PSNR −9.62 dB | *Explicitly* does not rule out fused int8. This is the interesting one. |
| tail/sync: 7.6 ms of tail is ~96% queue drain; perfect-overlap estimate 0.2399 ms | Matches our own 8 ms boundary finding, and matches our conclusion that it cannot all be recovered. |
| INT8 face colour: repeated re-quantisation and **hidden clipping 1.53–3.74%** caused it; fixed by repairing the GPU quantisation range | The failure mode to watch for if we extend int8 beyond the deep blocks. |

### The one idea worth taking: fused activation quantisation

`current/runtime/modules/fused_activation_int8_v1.py` — 51 lines of Triton, and the
whole point is in the kernel body:

```python
a = tl.load(A + ...)                       # fp16 activation
maximum = tl.max(tl.abs(a), 1)
scale = tl.where(maximum > 0, tl.div_rn(maximum, 127.), 1.)
qa = (magnitude * sign).to(tl.int8)        # quantised in registers
total = tl.dot(qa, qw, out_dtype=tl.int32) # straight into the integer dot
value = (total.to(tl.float32) * scale[:,None]) * sw[None,:]
if HAS_INITIAL: value += tl.load(INITIAL...)   # and the residual, same pass
tl.store(OUT + offset, value.to(tl.float16), valid)
```

**One** dispatch where we currently run three: `quantize_row`, `gemm_int8`, and then
`residual` because our integer kernel has no epilogue. Their notes put the fused
quantiser at 392.851 → 371.269 ms over their sequence, and they list
"融合量化" as a thing they *intend* to bring to full size — it is not yet in their
default line either. So this is not a finished answer we can copy; it is a shape
worth copying.

Two constraints of theirs we have to respect differently:

- **K ≤ 256**, because they bound the int32 dot below 2²³ so reassociation cannot
  overflow. Our deep-block shapes are K=4096 and K=1024, so we cannot load the whole
  row to take its maximum the way they do. Ours has to be a K-loop, which means
  either a per-K-block scale or a cheap upstream `row_max` pass that writes only
  `M` floats.
- **Their per-row scale needs the whole row.** In a tiled GEMM that only sees a
  slice of K, a per-row maximum is not available on the fly. A K-block scale is
  finer, not coarser, so it is not a quality step backwards — but it is not what
  their kernel does, and it is not what our `quantise_weight` produces today.

`work/int8_cover.py` measures the size of the prize before any of it is written: its
`noquant` column is the world where the quantise pass costs nothing, and the distance
between that column and today's `int8` column is what fusion could buy.

## What neither tree has

Both of them measure **host-side process time** in the tens of milliseconds and treat
it as the number. Neither runs a resident Vulkan graph replayed per frame the way we
do, so neither has our particular problem — 404 dispatches, each with a barrier in
front of it, costing 8 ms of a 44 ms frame. Their answer to that is "fuse more",
which is also our answer, but they cannot tell us *which* passes, because their graph
is not our graph.
