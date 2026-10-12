# A motion source, and the interface around it

2026-10-12. The owner's call, after the artefacts were traced to it: **the temporal path
must have real motion.** A Vulkan layer cannot supply it today, and that is no reason to
build the path twice — the interface has to be the one DX12 will plug into later.

What follows is the plan that came out of reading what is already here, because most of
this turns out to exist.

## 1. What is already built, and what is missing

The reprojection half of a temporal pipeline is **already in this repository**, and it is
already on the device:

| | where | state |
|---|---|---|
| five-tap Catmull-Rom reprojection | `src/gpu/history.comp` | done — `pc.flags != 0` reads a motion buffer and builds the sample coordinate itself |
| engine pixel motion -> normalised UV | `work/mlx-dlss/python/mlxdlss/temporal.py` `normalize_pixel_motion` | done — takes `(H, W, 2)`, `scale_x/y`, `jitter_dx/dy` |
| per-frame motion into the session | `TemporalSession.process(frame, motion=...)` | done — a field passed here **outranks** the callable source in `resolve_motion`, and survives alongside it |
| the estimate's confidence | `history_confidence` | done — its own parameter, which is what lets a field be damped without touching the gate |
| a motion *source* argument | `nr_temporal.session(motion=...)` | only `"zero"` and `"flow"` exist |
| anything that produces the field | — | **missing, and this is the whole job** |

So the contract wants a per-pixel field in pixels, `(height, width, 2)`, `float32`, at the
processing extent. Everything downstream of that — the reconstructed history, the learned
gate, the blend — is written and measured. `notes/phase12` measured what correct history
buys: **a gate of 0.705 against 0.032 for the panning scene**, and flicker down 3.6x by
the third frame. What we run today is the 0.032 case.

The evidence that this is what the owner is looking at is `trip_motion.py`: a real frame
drifted two pixels a frame comes back from answer 4 with 71-79% of the dark window's
spectrum in the 60-105 degree bins, against 23.8% in the source. Same directions and the
same 8-55 px band as his own screenshots.

## 2. Why it is an interface and not a patch

Because the *source* of the field is the part that differs per approach, and three quite
different things can produce one:

- a present-time Vulkan layer, which sees the finished frame and nothing else;
- a DX12 interception at the upscaler's own call site, where the game hands over the
  colour, the depth and its motion vectors (`HANDOFF:300`, deferred by the owner on
  2026-09-26);
- an estimator, when neither is available.

The temporal path must not know which. One interface, several back ends, and the day the
DX12 one arrives is the day a line changes and not a subsystem.

```python
class MotionSource:                 # src/ref/nr_motion.py
    """Per-pixel motion in pixels, at the receiver's own extent.

    `field(current, previous)` -> `((height, width, 2) float32, confidence)` where the
    confidence is per pixel in 0..1, or `None` for "identity is as good as it gets",
    which every caller treats as today's path and not as a failure. DLSS5-Feeder ships
    exactly such a mask alongside its own estimated vectors, flagged where the estimate
    is not to be trusted, so this is the shape the ecosystem already uses.
    """
    name = "zero"

    def field(self, current, previous):
        return None
```

The four back ends, in the order they get built:

| back end | what it returns | available |
|---|---|---|
| `zero` | identity — today's behaviour | always, and it is the fallback |
| `global` | one translation for the whole frame, by phase correlation | **today, Vulkan included** |
| `engine` | the game's own vectors, read where it hands them to its own upscaler | DX12 first; needs a temporal upscaler to intercept — none in DOOM Eternal on this card |
| `flow` | dense OpenCV DIS | exists, measured not useful — stays off |

### The rule that keeps today's path

This is the owner's condition, and it is the part of the design most likely to be got
wrong later: **identity plus `hold_floor` is not a stopgap to be deleted once real motion
arrives — it stays, and motion is added on top of it.** A frame with no trustworthy motion
has to come out exactly the way it comes out today.

That falls out of one multiplication. A source returns a field *and* a confidence, both
per pixel, and what the session receives is their product:

    motion_supplied = field * confidence          # per pixel, 0..1

`confidence` collapsing to zero makes that the zero field, and the zero field *is* today's
identity reprojection — `sample_history` then samples the history where the pixel already
is. So the degradation is continuous and needs no second code path: there is no branch that
chooses between "with vectors" and "without", only a weight that may be zero over part of
the frame and full over another.

**The confidence scales the field and nothing else.** `resolve_motion` reads it as evidence,
but the gate has its own input — `history_confidence`, which today carries the `temporal`
knob, with `hold_floor` and `release` under it. Multiplying the gate by the new confidence
too would be the natural thing to write and exactly the thing that breaks this promise: a
frame with no usable motion would come back with less history than it gets today, which is
a change, not a fallback. One place it acts, and that place is the field.

Nothing about that is allowed to be optional:

- `hold_floor`, `release` and `temporal` keep their meanings and their defaults
  (`hold 1`, `release 24`, `HOLD_RAMP 4`). No knob is repurposed to mean "motion".
- A source that fails, is unsure, or is simply absent returns no usable field, and the frame
  proceeds unchanged. Failure has to fall *backwards*, never forwards.
- `NR_MOTION=zero` restores today's behaviour outright, which is also how it ships until
  M3's numbers hold. New behaviours are opt-in, one word away, and never the default by
  right of being new.
- The regression test for M4 is byte-identity against the shipped path when no field is
  supplied — not "looks the same", but the same bytes, because anything less lets a future
  change quietly move the frame.

**`global` is not the thing `phase54` ruled out.** That note measured *dense* optical flow
as a stand-in for per-pixel vectors: DIS costs 7 ms and moves the whole-frame gate from
0.076 to 0.111, nearly all of it landing on moving pixels, which is the ghosting case.
This is two scalars estimated over a downsampled pair, and the case that needs it is the
one the failure was measured on — a standing player, framed on something still, everything
moving together. Two numbers where that round needed 1280x720 of them.

## 3. The plan

**M1 — the interface and `zero`.** `src/ref/nr_motion.py` with `MotionSource`, the `zero`
back end, and a test suite over the contract itself: shape and dtype, that a zero field is
bit-identical to today's output, and crucially the **sign**, checked with
`nr_temporal.check_motion_convention` — a sign error is silent, the network still runs and
still draws a picture. Nothing in the frame path changes. This lands as its own commit.

**M2 — `global`, measured offline.** Phase correlation over a small luma pyramid of the
previous and current frame: downsample to roughly 96x56, one `rfft2` pair, read the peak,
refine to a sub-pixel shift. Cost target **under 0.2 ms**, which is the budget the owner
set for anything added to a frame. Verified against `trip_motion.py`, whose true drift is
known: the estimate has to land within half a pixel of 2,1.

**M3 — does it stop the slant.** Same captured frame, same drifted sequence, same eight
frames through the same daemon, with the estimate supplied instead of zero. Pass criterion
is the number that started this: the 60-105 degree share of the dark window falls from
**71-79% back towards the source's 23.8%**, over the whole band, with no change to
`intensity`, `detail_strength` or any knob that weakens what NR does. Gate second: the
device at `gpu 0+38+0` still. Quality third, on real frames with `work/int8_quality.py`.

**M4 — wire it into the daemon, then into the device.** `nr_daemon.py` asks one
`MotionSource` for the field, takes the product with the confidence, and hands it to the
session; `history.comp` already takes it via `flags`. Behind `NR_MOTION`, whose default
stays `zero` — today's behaviour — until M3's numbers hold, and stays `zero` afterwards for
anybody who wants it. Enabling it changes what a confident frame does and nothing else;
a frame whose source has nothing to say is byte-identical to one run without this work at
all, and that is a test rather than an intention.

The sources are asked **in the owner's order**, not in order of apparent sophistication:

**our own estimate first, then the game's vectors if the estimate cannot answer, then
identity.** Section 8 says why that order is right and not merely cautious — the title running
today has nothing to intercept, so a plan that leads with the vectors would spend its first
week waiting for something it cannot have. Switching the order later, if measurement ever
says the released vectors are better, is a one-line change and not a redesign.

**M5 — the `engine` back end, which is the DX12 one.** Separate process or injected DLL,
delivering over the same transport the extmem path already uses; the daemon cannot tell
which source answered. This is where the real work is — its own Windows build, its own
transport, and a motion-vector convention per game — and it is the two to three weeks
`HANDOFF:300` already estimated. The point of M1-M4 is that none of it is blocked on it,
and none of it gets thrown away when it arrives.

## 4. Risks, each with its own measurement

- **The estimate can be wrong.** Mitigation is not hope: `confidence` scales the field, and
  an unreliable estimate must fall back to `zero`, which is today's behaviour exactly. A
  wrong field is worse than none, so the fallback is the default and not the exception.
- **Rotating sprites break a pure translation.** A browser cursor or a spinning fan does
  not follow the camera. Where `global` has nothing to say, `confidence` has to say it.
- **Sub-pixel accuracy decides whether this helps at all.** A whole-pixel error is most of
  the drift we are correcting. Measured in M2 before M3 spends any more time on it.
- **Scene cuts.** Handled already — `scene_cut_threshold` clears the history, and any new
  source goes through `resolve_motion`, which knows about it.

## 5. What this is deliberately not

Not a change to `render_scale`, not a change to `intensity` or either strength, and not a
filter over the output. Every previous round that touched those either cost quality or
measured well and changed nothing the owner could see. Motion is the one thing the
evidence points at, and it is the one thing that makes the temporal path do what it was
recovered to do.

Order of work: M1, M2, M3. If M3 does not move the 71-79% number, the wrong thing was built
and we stop there rather than going on to M4 with a story instead of a measurement.

## 6. Three tiers of trust when the vectors are not there

The owner corrected this document's ordering and he is right, and it is worth saying what his
correction buys rather than only recording it: the plan had put the released vectors first as
though they were the prize and estimating was making do. That is backwards for the title running
today, which has nothing to intercept at all — a plan that leads with the vectors spends its first
week waiting for input it cannot have. **Our own estimate leads. The released vectors are what we
fall back to when it fails. Identity is the floor.**

Within the leading estimate, do **not assume a transform** and do not simply translate the history
by `(dx, dy)`. That is exactly the wrong guess, because it trusts the estimate where the estimate
has earned no trust. Verify it against the history instead:

1. **Search the neighbourhood.** For each pixel try candidate offsets in `±(dx, dy)` and see
   which one actually finds the current value already present in the history. Multiple hypotheses,
   best match wins — a match is evidence, an assumption is not.
2. **Where the search fails, say so.** Several hypotheses returning nothing that matches is a
   *failure*, not a small value to be used anyway. The failure moves up rather than pretending.
3. **Fall back to what the pixels can settle on their own.** Reduced to photometric quantities
   only — no motion — with confidence deliberately middling, `0.6` to `0.8`, honest about being a
   guess. Better a visible `0.7` than a confident wrong field.
4. **Identity last**, which is today's behaviour exactly.

The estimate therefore carries its own verification, which is what makes it safe to lead: a field
that cannot find its own prediction in the history does not get applied.

## 7. Two paths at once means two paths that can each be run alone

The owner's second condition, and it is a design requirement rather than a debugging convenience:
with two behaviours able to be alive in one frame, not knowing which ran turns every later
complaint into guesswork. Before M4 puts this on a frame:

- **Each path runs alone.** A source can be forced, so "path A reproduces it and path B does not"
  is answerable in one run instead of inferred from a diff.
- **Each stage reports.** Capture, prepare, history, network, compose, temporal, present — each
  records that it started and finished, per frame, with its time.
- **A stall names itself.** When a frame hangs, the last stage that *completed* is on record. "It
  froze" is not a diagnosis; "it froze after `history`, before `compose`" is, and it costs one line
  per stage to have.
- **Both paths stay testable independently** even when only one is usable in a given title, so a
  broken path fails loudly on its own instead of silently degrading.

This one is also why the fork is worth having. Upstream cannot answer "which of your temporal
behaviours produced this pixel, and where did it stop" — it has one behaviour and no stages named.
Ours will have two, and observability is what makes carrying two survivable.

## 8. Where released vectors actually are

The owner's reading is the correct one and it corrects a shorthand this repository has been using
for a year. "`vkQueuePresentKHR` has no motion vectors" was never a law about the frame — it is a
statement about *one* hook being the last door on a long corridor. Everything the temporal path
wants is handed over much earlier, **where the game passes its own temporal buffers to its own
upscaler**: DLSS, FSR 2+ or XeSS each receive render-size colour, depth, motion vectors and jitter,
by definition, because that is their contract. Intercept *that* call and the vectors are exact and
free. `notes/phase41-doa6-and-vkd3d.md` already found them named in DOA6's `sl.common.dll` as
`kBufferTypeHUDLessColor` / depth / motion-vector tags, which is the same door.

So `engine` is not a fantasy and not a rewrite: it is choosing the same interception point everyone
else already uses — Streamline's tags under Proton, OptiScaler's hooks for NGX/FFX/XeSS on Windows —
and delivering the result through the same `MotionSource`. What changed with the owner's point is
not the possibility but the **address**: the upscaler's input, not the swapchain's present.

It is still gated on the title having such an upscaler to intercept. DOOM Eternal exposes none here
(NVIDIA-only DLSS, no XeSS or FSR 2 path for this card) — which is precisely why estimating leads
and why the owner's ordering is the right one. DOA5LR is the natural second target precisely because
the upstream project ran there, and it is the first place the `engine` back end can be checked
against a title upstream already validated.

### An independent project reached the same map, and published its estimator

`mochizuki0323/DLSSNR-AMD` is NVIDIA's NR network reimplemented as Vulkan compute for an RX 9070 XT,
and it sorts games into exactly these doors: `optiscaler`, which reads **the engine's own** vectors,
only where the game has DLSS, FSR or XeSS; and ReShade, whose **"motion is estimated from the
picture by a ReShade shader"**, everywhere else — **including every native Vulkan title** (README
"Supported games"). A project built for non-NVIDIA hardware on Vulkan, with no reason to be
cautious, therefore estimates motion on the one configuration we have.

Better than agreement, it published the estimator: `linux/shaders/passes/motion_estimate.comp`. Its
header states the contract this plan inherits — `prev_uv = uv + mv * MVecScale`, the vector pointing
**back** one frame, `history = CatmullRom5(history, prev_uv)` — and two things to copy rather than
rediscover. It estimates in the *consumer's* domain, because "there is no component swap left to get
wrong". And where a match cannot be justified it writes exactly zero:

> where the match cannot be justified we write exactly zero, which makes prev_uv == uv, which makes
> the history sample this pixel's own colour. That is the colour-only behaviour the original itself
> was shown to fall back to — the degradation target is a verified state, not a guess.

That is this plan's fallback, independently arrived at and called verified. Its rejection is relative
— `best_sad > reject * contrast`, against the patch's own contrast, never an absolute threshold — and
candidates that leave the frame are disqualified rather than clamped, because clamping made flat
edges score better than the correct vector. M2 should be written in that shape.

Its moving-sequence figures against NVIDIA's own DLL (46.3-47.0 dB PSNR at 1080p, ten frames each
over a still scene, a moving object and a panning camera) are also the standard this work should be
held to, rather than "the slant got fainter".

Archived with a Chinese summary at `refs/DLSSNR-AMD/`.

### An independent project says the same thing, and sharpens it

`mochizuki0323/DLSSNR-AMD` is what this would look like if somebody else had built it: NVIDIA's NR
network reimplemented as Vulkan compute, on an RX 9070 XT. Its `ARCHITECTURE.md` splits into the
same doors — `optiscaler` when the game has DLSS/FSR/XeSS, and ReShade with **estimated** motion
when it does not — and says outright that the vectors "are the engine's own, not estimated as in the
ReShade routes". **For a native Vulkan title its route is ReShade as a layer, and the motion is
estimated.** So a project built for non-NVIDIA cards, on Vulkan, with no reason to be conservative,
reaches exactly the conclusion this plan reaches: the released vectors exist only where a temporal
upscaler already receives them.

It also corrects a shorthand I have been using. Its Vulkan route puts ReShade *under the game's own
Vulkan device*, which sees the depth. Ours sits at `vkQueuePresentKHR`, which sees the finished
frame. **The API is not the obstacle; how late we are is.** That is the owner's point stated
precisely: earlier hooks see more. It does not change today's answer for DOOM Eternal — a velocity
buffer that is never handed to anything cannot be intercepted from any position — but it is worth
having right, because it is what makes the DX12 move a change of address rather than a change of
technology.

Two things there are worth taking rather than rebuilding: `shaders/passes/motion_estimate.comp`, a
screen-space estimator already written as Vulkan compute, whose contract is the same one this plan
inherits (`prev_uv = uv + mv * MVecScale`, the vector pointing back a frame) and whose unprovable
matches are written as zero — the same degradation this document promises; and the OptiScaler-NR
route as the worked example of `engine` on DX12.

And a number to aim at. Against NVIDIA's own DLL on an RTX 5090, that project reports **46.3–47.0 dB
PSNR and 0.997–0.998 SSIM at 1080p over moving sequences with motion vectors and history** — a still
scene, a moving object, a panning camera. "The slant is fainter" is not a finish line; that is.


## 6. Where vectors can actually come from — and what each one costs

The owner is right that `vkQueuePresentKHR` is not the only door, and worth being precise
about which door is which, because the honest answer is that they differ enormously in cost.

**The frame at present is the last door, and the worst one.** By then the depth and the
velocity buffers have usually been released or refilled, the HUD is composited into the
colour, and the only thing left is the picture. That is why every advisory note in this
repository says the same thing — `phase53`, `phase54`, `CLAUDE.md` — and why identity
reprojection was chosen.

**What the game hands to its own temporal upscaler is the good door.** Every game with
DLSS, FSR 2+ or XeSS has already produced colour, depth, motion vectors and jitter at
render size and already passes them somewhere. Intercept *that* call and the vectors are
free and exact. This is what OptiScaler does (`NVNGX` / `FFX` / XeSS hooks) and what
`sl::kBufferTypeMotionVectors` tags name in Streamline. It is also what
`phase41-doa6-and-vkd3d.md` found already sitting in DOA6's `sl.common.dll`.

Three things constrain it, and the third is the one to say plainly:

- **The game must have a temporal upscaler to intercept.** No upscaler, no vectors. DOOM
  Eternal has no XeSS or FSR 2 path on this hardware and DLSS is NVIDIA-only, so for the
  one title running today there is nothing to intercept. DOA5LR, which the owner is
  installing, is older still. This route buys the *future* titles — and it is the route the
  DX12 move is for — but it does not rescue today's frame.
- **The presentation need not be the interception.** Hooking earlier in the frame, at the
  game's own passes rather than at the swapchain, is legitimate and in principle richer; but
  reading a velocity attachment out of someone else's render target descriptors is a
  per-title reverse-engineering job, and this project's whole argument has been that it is
  sitting at *one* place that works everywhere. Weighing one title's vectors against that is
  the decision M5 has to make, later, with its own measurement.
- **Whatever it feeds has to be `Engine`-shaped.** This matters more than where it came
  from: between a hook that yields real vectors and anything assumed about their convention
  lies the failure `check_motion_convention` exists to catch.

So the picture is: today's titles get `global` or identity; tomorrow's get `engine` through
an interception we do not have to write from scratch. Both arrive at the same field.

## 7. Two paths at once means two paths that can each be inspected

The owner's second condition, and it belongs in the design rather than in the debugging:
once two behaviours can be alive in the same frame, anything short of *knowing which one ran*
turns every future complaint into guesswork. Concretely, before M4 ships anything:

- **A path can be forced.** `NR_MOTION=identity` and `NR_MOTION=global` select one outright,
  and `NR_MOTION=auto` is what production uses. "Which one is running" is answerable in one
  word, not inferred from a diff.
- **Every frame says what it did.** Source chosen, whether it answered, the frame's drift in
  pixels, the confidence it was given. One line, next to the line that already prints `held`
  and `gpu`. A bad number on that line is the difference between "NR is broken" and "the
  estimate misses when the scene pans".
- **Each source is separately testable** — `global` against a synthetic shift whose answer is
  known, `identity` against today's byte-for-byte output — so a failure names its own path.
- **And the fallback is visible rather than silent.** When a source declines, the frame runs
  as today's and the log says it declined. A fallback that nobody sees is how a regression
  spends a month looking like a mystery.

That is the fork's own argument for existing. Upstream cannot answer "which of your two
temporal behaviours produced this pixel" because it has one; we will have two, and the cost
of that is telling the truth about which ran.
