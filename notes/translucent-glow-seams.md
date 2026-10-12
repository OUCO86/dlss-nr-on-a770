# A fire's glow comes back as patchwork — three measured explanations, none of them right

2026-10-12. The user's report, in his words: game light effects — the
full-screen translucent wash a fire throws — come back **like translucent
patchwork, with seams you can see**, and a trace left behind. Every other part of
the picture is fine. He thought it might be DOOM's own and not worth chasing, and
he was half right: it is not worth chasing *by guessing*, which is what this note
is the record of.

**The one hard clue he gave, and it is the one that matters:** with NR off there
is no patchwork — and the game is rendering at 0.4 either way. So the 0.4 is not
the cause. Something NR does to the frame, on top of the game's own upscale, is.

## The route a frame takes, which is what makes 0.4 twice

The clue rules the game's own scaling out and points at the second one, because
the frame is scaled **twice**:

```
the game renders at 0.4 and upsamples to 1920x1080 with its own TAAU   <- no seams
layer takes the 1080p frame at vkQueuePresentKHR
daemon scales it to 768x448 for the network
network -> head 768x448
nr_image.compose_encode: "bilinear of the head to the colour's extent"  <- 2.5x again
composed with the 1080p colour, written as 8-bit bytes
```

So the network's numbers reach the frame through an upscale the game never had to
do, and it was fair to suspect it.

## 1. The upscale's own grid — 2.5 px apart, 4% of a level

`src/bench/grid_artifact.py`. A bilinear upscale is C0 but not C1: its slope jumps at
every source grid line, 2.5 output pixels apart, and the eye is very good at
finding a first-derivative discontinuity where there is no texture to hide it.

Measured against the true signal, on a broad glow:

| kernel | slope jump | max error |
| --- | --- | --- |
| bilinear (what runs) | 16.0x the true one | 0.000685 |
| smoothstep | 146.7x | 0.000877 |
| catmull-rom | 13.0x | 0.000685 |
| b-spline | 7.2x | 0.000685 |

The relative jump looks alarming. The absolute one does not. The head reaches the
frame as `out = rgb + blend * (predicted - rgb)` with `predicted = rgb +
half(h) * 0.25`, so a head error of `e` costs the frame `0.25 * e` — and one
8-bit level is 0.0039, so the head would have to be wrong by 0.0157 to move the
frame one level. **The error is 0.000685: 4% of a level.** A grid 2.5 px wide and
4% of a level deep is not the thing on the screen.

Note also that the three 4-tap kernels give *exactly* the same max error. At this
scale the error is the sampling's, not the kernel's: a glow 169 head-pixels wide
is oversampled to death, and no kernel can lose what was never missing. Changing
the kernel here would cost work and buy nothing.

## 2. The network's own 8x8 windows — 20 px apart, and not there

`image_io.smooth_pattern` exists for exactly this question, and its comment says
the network has 8x8 attention windows and five 2x resamplings, so content with a
fixed period can meet processing with a fixed period. An 8-pixel window in the
768-wide head is **20 pixels in the frame** — which is the size a seam has to be
to be called patchwork, unlike the 2.5 above.

`src/bench/seam_probe.py` runs the game's own route (`bilinear` down, `run_head`,
`compose_encode` up) on a smooth glow and asks each half separately:

| | around 20 px | around 2.5 px |
| --- | --- | --- |
| input | 786.9 | 0.371 |
| head (at its own scale) | 2.10 | 0.000 |
| composed frame | **735.6** | 0.343 |

**The composed frame carries less at 20 px than the input does, not more.** The
network adds no period of its own here. If the head had one, the frame would have
to inherit it.

(It also carries less at 2.5 px, which is the second measurement saying the same
thing as the first.)

## 3. Quantisation into bands — the red channel says no

The interesting number from that run was that the written bytes used **38 levels
in the blue channel** against 137 in the game's own. That is the shape banding
has: a gradient spread over a third of the levels it had, each step three and a
half times as tall, the boundary between two steps a line you can see.

It was the blue channel. Blue is `warm[2] = 0.26` of the glow — a narrow range
that never had many levels to begin with. `src/bench/dither_probe.py`, measuring **red**, the channel the fire actually is:

| frame | mean run of one byte | p99 | levels |
| --- | --- | --- | --- |
| the game's own bytes | 21.66 | 262 | 136 |
| the composed frame | **18.98** | 205 | 128 |
| the composed frame, dithered | 5.76 | 68 | 128 |

The composed frame's runs are **shorter** than the game's, not longer, and it
holds 128 levels against the game's 136. On this input the network is not
banding the frame; if anything it is smoothing it slightly.

A dither still works — runs 18.98 to 5.76, levels to 128, at a cost of 0.250 of a
level with no pixel moved more than one — so if banding is ever the complaint,
that is the answer and it is nearly free. It is not the answer to *this*, because
on the measured channel there is no banding to answer.

⚠️ A trap in this measurement, found the hard way: `compose_encode` returns the
composition as **RGB** and writes the bytes as **BGRA**. Comparing
`composed[..., 0]` against `encoded[..., 0]` compares red against blue and reports
a 19.6-level difference that is not there. Red is `encoded[..., 2]`.

## What is left, and why guessing has to stop here

All three were measured on a **synthetic glow**: a smooth Gaussian wash, linear,
no texture, no dither. It is not DOOM's frame. A real fire is a bloom built in
HDR, tone-mapped, composited over the scene, and accumulating through the game's
own TAA — and every one of those changes what the network is asked to do and what
a seam in it would look like. Two of the three explanations above died on
absolute numbers that a different input would move; none died on logic.

So the next step is the frame, not another hypothesis. The layer will write it:

```
set NR_LAYER_CAPTURE=<a path>
set NR_LAYER_EVERY=1
```

`nr_layer.c:1861` writes `data->mapped` — **the frame as the game presented it,
before the network sees it** — as a 16-byte header `{magic, width, height,
vk_format}` followed by the pixels, every present, overwriting. `magic` is
`0x304E524E`, or `0x314E524E` when a mask travels with it. numpy reads that
directly; ImageMagick, which `image_io` wants and this machine does not have, is
not needed.

To catch the fire: stand in front of it for a few seconds, then quit. The file
holds the last frame presented. It is 8.3 MB a frame at 1080p, so the game will
stutter while it is on — it is a capture, not a way to play.

With a real frame the same three questions get asked again on the thing the user
is actually looking at, plus the ones a synthetic glow cannot even express:
whether the seam sits where the bloom's own low-resolution buffer sits, whether
it is in the composed frame or only in the bytes, and whether it is still there
on a frame where the fire is not.
