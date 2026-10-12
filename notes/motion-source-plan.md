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
| `engine` | the game's own vectors | DX12 only, later |
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

The sources are asked in order of trust and the first that answers usefully wins: the
engine's own vectors when they exist, then `global` when they do not, then identity. That
ordering is what makes M5 an addition.

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
