# staged against tiled, re-measured (2026-10-10)

The claim in `libxmx.c` — that on Xe-HPG staging costs about half the GEMM
throughput, so a plain GEMM goes to the tiled kernel — is the kind of number
worth not trusting. It is also counter-intuitive: staging is supposed to be the
trick that *saves* the traffic, and on the two other platforms this tree runs on
it does. So it was measured again, on this device, with the dll a game loads.

It holds.

## how

`src/bench/st_vs_tiled.py`. One process per spelling, because `XMX_PREFER_STAGED` is
read when the library starts. Best of seven submits of four dispatches, the same
shape of measurement `tools/bench_overhead.py` used, so the old numbers and the
new ones are the same kind of number.

`XMX_PREFER_STAGED` only takes the routing back when `M % 64 == 0`, which gives
the sweep a control group it did not ask for: two of the frame's shapes have
M = 96, where the variable does nothing. Both spells of those two come out the
same (0.96 and 0.98), which is the measurement saying it has no bias of its own.

## the K sweep, M = 61440, N = 128

| K | tiled GF/s | staged GF/s | staged / tiled |
|---|---|---|---|
| 32 | 1733.8 | 1589.8 | 0.92 |
| 128 | 5350.5 | 3379.4 | 0.63 |
| 512 | 6863.6 | 4125.7 | 0.60 |
| 2048 | 7075.1 | 4318.5 | 0.61 |
| 8192 | 6869.5 | 3513.8 | 0.51 |

Against the pair in the comment (staged 1494/2848/3478/3685/3482, tiled
2135/5340/6811/6888/6850): the tiled column reproduces to within a few per cent
at every depth but K of 32, and the staged column lands a little higher than it
did. The gap is the same gap. `logs/bench-overhead.txt` is this sweep's staged
half, which is how one measurement ended up in a log and the other in a comment.

## the frame's own shapes

| M | N | K | tiled GF/s | staged GF/s | ratio |
|---|---|---|---|---|---|
| 21504 | 128 | 64 | 3635.9 | 1775.4 | 0.49 |
| 5376 | 128 | 128 | 2769.8 | 1657.2 | 0.60 |
| 1344 | 256 | 256 | 2989.6 | 1412.1 | 0.47 |
| 384 | 512 | 512 | 2670.1 | 1068.0 | 0.40 |
| 96 | 4096 | 1024 | 5760.4 | 5555.8 | 0.96 — control |
| 96 | 1024 | 4096 | 2477.5 | 2431.7 | 0.98 — control |

## why it is counter-intuitive, and why it is still true

The intuition is not wrong, it is about a different machine. Upstream's
threshold of 32 came from the same sweep on Xe2/140V, where staging paid;
`notes/HANDOFF.md` has the Linux side saying the tiled kernel is slower than the
staged one at every whole shape. What Intel's compiler does with the staged
kernel's K loop on Windows is the difference, and it is a compiler difference,
not a property of staging.

So: keep the routing as it is. Do not spend time on a staged path for a plain
GEMM on this card. The three things that *need* the staged kernel still need it —
the window gather (0x400000), the pooled residual in an epilogue (0x800000), and
the 32-row builds `small` selects — and they pay the same tax, which is worth
remembering when one of them looks slow.

## what this settles about the fused integer GEMM

`gemm_staged_int8_fused` was built to fold the quantise pass into the GEMM, and
it lost: 27.05 ms for the per-K-block build, 34.55 ms for the per-row one,
against 8.90 ms for the two passes kept apart. It is easy to read that as
"staged is slow, and this kernel is a staged one" and stop there. It is not the
reason, and it matters that it is not, because the reason generalises:

**The quantise pass is not an overhead, it is a saving.** A GEMM reads its
activation once per column block — N / BN times. Quantising once, outside, turns
all N / BN of those reads from two bytes into one. Folding the quantise into the
GEMM does not remove the pass; it removes the *saving*, and upgrades every one
of those reads back to float16. At BN of 32 and N of 512 that is sixteen reads
doubled to pay for one read avoided.

`notes/improve-int8-a770.md` reaches this from the measurement and SageAttention
reaches it from the other direction — quantisation is deliberately outside its
GEMM and outside its reported timings. Two measurements, one conclusion.

**So the fused kernel is not a staged-vs-tiled question at all.** Making staged
as fast as tiled would not rescue it. Today's numbers make it plain: on
96 x 1024 x 4096 the pair costs 107.9 us and the fused kernel 413.5, while the
GEMM on its own is 96.6 — the fused kernel is slower than the float16 GEMM it
was written to beat.

Where the quantise pass can still be made cheaper is by merging it with the pass
that produced the activation, which is what `NR_INT8_WINDOW_FUSE` does for the
window blocks. That keeps the saving and drops the pass. It does not put the
quantise inside the GEMM.
