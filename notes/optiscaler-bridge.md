# OptiScaler as host: the bridge we write, the core we keep

2026-10-12. The owner's decision, after asking whether Vulkan can go through OptiScaler too
(it can — see `motion-source-plan.md` §9.1). This note is the executable half: what we
actually build, and what we deliberately do not touch.

The licence question is settled the same way `TheAutomatic/dlss-5-amd-project` settles it:
**the host is GPL-3.0 and we stay outside it** by being a separate DLL behind a C-ABI, which
is exactly how their `LmxxfNrGetApi` runtime relates to OptiScaler. This repository is
Apache-2.0 and stays Apache-2.0.

## 0. Three layers, and only one of them is new

| layer | what it is | do we touch it |
|---|---|---|
| **host** | OptiScaler, injected as `dxgi.dll` (or `winmm.dll`, `version.dll`, …) | **no.** Not modified, not linked, not vendored |
| **bridge** | *our* DLL: takes the host's upscaler inputs, hands them to our core, returns the result | **this is the whole job** |
| **core** | the Vulkan network, the daemon, the shaders, the weights, temporal, int8 | **no.** The 30 ms baseline is measured on it and is not to be disturbed |

`TheAutomatic` runs exactly this shape: host + bridge + somebody else's network core
(`mochizuki`, `daniel`, or `lmxxf`), switched with `NrBackend`. **He did not rewrite
mochizuki's network to make it work, and we do not rewrite ours.** The distinction matters
because "port to OptiScaler" and "rewrite the core" differ by months.

That is why the cost estimate that frightened this plan earlier was wrong. It priced a core
rewrite. What we are doing is a bridge.

## 1. The input is per game, and that is a design constraint

The host does not invent an upscaler; it intercepts the one the game is already calling. So
the input side is **title-specific**, and the owner is right that each game's upscaler has to
be adapted individually.

OptiScaler's own compatibility list, verbatim:

```
| [Lies of P](Lies-of-P) | ✅ | DLSS, FSR3.1 | ✨ |  | ... |
```

So Lies of P offers **two** possible inputs — the DLSS one (which needs NVIDIA spoofing on
this card) and **FSR3.1** (which is what the owner says the game is actually running). The
bridge therefore needs an input adapter chosen by what the host reports, not one hardcoded
path:

| input the game is calling | what it hands over | notes |
|---|---|---|
| FSR 3.1 | colour, depth, motion vectors, jitter, exposure | the first FSR version with a fully standardised API — the good case |
| FSR 2.x | same set, but custom interfaces per studio | see §3 for the UE tweak |
| DLSS / NGX | same set | needs GPU spoofing on Arc |
| XeSS | colour and motion vectors, **but the UE XeSS plugin does not supply depth** | verbatim from the host README, §3 |

Consequence for the bridge: **the MV convention is per input, not per game.** `check_motion_convention`
already exists for exactly this and must run on the first real field of every new input type.

## 2. Input follows the game; output is XeSS and nothing else

**The input is not ours to choose — the game decides it.** Whatever upscaler the title is
already calling is what the host can intercept (§1). For Lies of P that is **FSR3.1**.

**The output is ours to choose, and the owner's ruling is XeSS only**: XeSS is the Intel-native
path on this A770 (XMX engines), so FSR and the rest are not candidates and are not evaluated
further. This is precisely where copying `TheAutomatic` would be wrong — that project is AMD
and its output is FSR. Same bridge, different output, because the card is different.

- input: **FSR3.1** (what Lies of P is running)
- output: **XeSS** on XMX — the only backend considered
- our NR: inserted **pre-SR**, on the low-resolution colour, before XeSS upscales

Two official statements make XeSS the right output here rather than merely an available one.
Config.md, verbatim, for the DirectX 12 backend list:

```
; xess, fsr21 or fsr22
; Default (auto) is xess
```

and Features.md, verbatim:

> Supports DXGI spoofing (when running as `dxgi.dll`) as Nvidia GPUs (**with XeSS detection
> to enable XMX on Intel Arc cards**)

The second is the reason this is a hardware argument and not a preference: the host detects
XeSS and switches on the XMX path for Arc. XeSS is a temporal upscaler too, so it wants the
same set the others do — colour, depth, motion vectors, exposure — which is convenient for
us: the input we need for NR is the input XeSS needs anyway.

The second one is the reason to prefer XeSS on this hardware specifically: the host detects
XeSS and switches on the XMX path for Arc. That is the "Intel-native" part, and it is a
configuration choice, not a port.

## 3. Lies of P: what is known, and what is still a guess

Measured on this machine today (this repository's own history, `2026-10-09`):

- **DX12 only.** The shipping build ignored `-dx11`; the crash log still said `D3D12`.
- `Engine/Plugins/Runtime/Nvidia/DLSS/Binaries/ThirdParty/Win64/nvngx_dlss.dll` — a DLSS-SR
  path exists.
- `LiesofP/Binaries/Win64/amd_fidelityfx_dx12.dll` — the FFX plugin is present, and was
  loaded even with FSR 1/2/3 all set to Off in the game's settings.
- **The old red line belongs to the old route.** We abandoned this title because vkd3d crashed
  inside `amd_fidelityfx_dx12.dll`, and wrote "do not put anything in the Lies of P folder
  again". That was a judgement about *vkd3d*, and this route does not use vkd3d. It stays
  reversible anyway: everything we add is a file we can delete, and nothing is renamed.

The one thing to watch, from the host's README, verbatim:

> For **Unreal Engine** games, only UE XeSS -> Opti XeSS/FSR4 work

and, on FSR inputs, verbatim:

> Since FSR2 and FSR3 support custom interfaces, game support will depend on the developers'
> implementation. With Unreal Engine games, you might need ini tweaks for FSR inputs.

Lies of P is UE, so if the game crashes once the host is installed, the first thing to try is
the published tweak — `Engine.ini`, verbatim from the host's wiki:

```ini
[SystemSettings]
r.FidelityFX.FSR3.UseNativeDX12=1
r.FidelityFX.FSR3.UseRHI=0
```

(`UseRHI=0` is the FSR3.1 variant; plain FSR3 uses only the first line.)

## 4. Installation, as far as the official documents go

The current README says plainly, verbatim: *"For installation steps, please check the
**Wiki**"*. The wiki's installation page is an index pointing at **Manual-Installation**,
which I failed to retrieve (proxy error, retried). **So the steps below are the shape, not a
transcript, and the wiki page should be read before touching the game folder.**

The shape, from the official `Spoofing.md`, `Features.md` and the installation text carried in
the project's own README history:

1. Install **non-nvngx** — i.e. OptiScaler is *not* loaded as `nvngx.dll`. This is the mode
   that enables spoofing, and spoofing is what we need for a card that is not NVIDIA.
2. A signed NVIDIA `nvngx_dlss.dll` is needed to get past DLSS's signature check. Lies of P
   already ships one **in the engine plugin folder**, not next to the exe — copy it beside the
   exe and rename the copy to `nvngx.dll`.
3. Rename OptiScaler's own `nvngx.dll` to one of the supported loader names and put it in the
   game folder. Supported names include `dxgi.dll`, `winmm.dll`, `version.dll`, `wininet.dll`,
   `winhttp.dll`, and `OptiScaler.asi` with an ASI loader.
4. Enable spoofing in `OptiScaler.ini` under `[Spoofing]`. For Vulkan titles the two keys are
   `Vulkan=true` and `VulkanExtensionSpoofing=true`; for DX12 the DXGI spoofing is on by
   default when running as `dxgi.dll`, and `Spoofing.md` is the authority.
5. Choose **xess** as the output upscaler (§2).
6. Select our bridge as the NR backend, the way `NrBackend` selects theirs.

**Uninstall is deletion**: the renamed loader, `nvngx.dll`, `OptiScaler.ini`, and the
`OptiScaler\` folder. Nothing in the game is patched.

> ⚠️ The host's own warning, verbatim: *"**Do not use this mod with online games.** It may
> trigger anti-cheat software and cause bans!"*

## 5. How the pixels reach our core — follow `TheAutomatic`, whose backend is Vulkan too

The owner's instruction is to follow `TheAutomatic` rather than invent a shape, and the reason
is that his backend sits on **Vulkan** — `mochizuki`'s core — which is what our core already
is. The map is one-to-one:

| `TheAutomatic` | us |
|---|---|
| OptiScaler host | OptiScaler host (unchanged) |
| `MochizukiNrRuntime.dll` behind one C-ABI export | our bridge DLL behind one C-ABI export |
| mochizuki's **Vulkan** network | **our Vulkan network** (`src/gpu`, the shaders, the weights) |
| D3D12↔Vulkan interop adapted from `MatheusFerreiraS/neural-amd-opti` | same source, adapted for Arc |

Verbatim from their `docs/mochizuki.md`:

> This backend runs mochizuki0323's Vulkan network on the game's AMD adapter while the
> game stays on native D3D12. … The runtime adapts native D3D12/Vulkan interop and pipeline
> prewarming code from [MatheusFerreiraS/neural-amd-opti](https://github.com/MatheusFerreiraS/neural-amd-opti).

That repository is real: `MatheusFerreiraS/neural-amd-opti`, branch `dlss-neural-rendering`,
described as *"Modified OptiScaler focused on adding neural-rendering"*. It is where the
interop and the pipeline prewarming come from, and it is the piece to read before writing ours.

**So the default is B, in-process interop** — a `VkDevice` inside the game process sharing
with D3D12 — because that is what the reference does and what the owner asked for. What it
costs us is specific and worth naming: our network is currently driven from a **separate
daemon process** (the extmem path, measured in both directions), so following the reference
means the network has to be reachable **in-process**. The Vulkan half — `src/gpu`, the SPIR-V,
the weights — is C and already loadable that way; the part that has to move is the Python
scheduling layer above it.

**A stays as the fallback**, not as the plan: keep the daemon where it is and hand it the
host's D3D12 resources through Win32 handles, which is machinery this repository already proved.
It is the cheaper experiment if in-process turns out to be a larger job than it looks, but it
is not what the reference does, and choosing it should be a decision made out loud rather than
by default.

Either way the question that decides everything is the same and comes first: **do we get real
motion vectors, and do they have the sign we think.**

## 6. Acceptance

- The host logs that it intercepted an upscaling feature, and names which one. If it never
  does, there is nothing to bridge and no vectors — check whether the game is *calling* an
  upscaler at all (§1).
- The bridge receives a motion field and **prints it**: magnitude, and the result of
  `check_motion_convention`. A sign error is silent and still draws a picture.
- The 60–105° share of the dark window falls from **71–79% towards the source's 23.8%**
  (the number that started this), on a real frame from this title.
- Frame time is re-measured on the new baseline. Every historical number in this repository
  was taken without an upscaler in the path and is void once there is one (§9.7 of the plan).
- With the bridge disabled, the frame is byte-identical to today's. That is a test, not a
  promise.

## 7. Risks

- **UE + FSR inputs are the fragile combination** (§3). Have the two `Engine.ini` lines ready
  before starting, not after the crash.
- **XeSS needs depth.** FSR and DLSS inputs supply it; the UE XeSS plugin does not. If we ever
  fall back to a XeSS input on a UE title, expect that to break.
- **The upscaler costs GPU time too**, and this A770 is already the ceiling — `NR_LAYER_ASYNC`
  measured `gpu` rising 38→43 ms the moment two things shared it.
- **Spoofing is per title.** What works in one game says nothing about the next; every new
  target repeats §6 from the top.

## 8. What we take from the Intel-Arc project in `src/dlss5nr-b580` — and what we don't

That repository (`gggz114514-oss/dlss5nr-b580-intelarc`) is DLSS5-NR on an Arc **B580**, and
it is the closest thing to us that exists on this machine. The owner's ruling stands: **its
bridge is not our bridge** — a different shape (ASI plugin, three entry routes, an identity
substitution gated on resource-state proofs) and not one he wants. We do not adopt it.

Two things in it are still worth having, and both are evidence rather than code:

**1. It did take the motion vectors.** The owner suspected it never did. Its own route note
says otherwise — the DLSS entry records *"标准 NGX 颜色、运动、深度、jitter"*, the frame
contract carries a real `1280x720x2` current-to-previous field, and its run contract lists
*"融合真实运动与历史"*. So the doubt is answered: **the vectors were there.**

**2. But it never got NR onto the screen.** The same note, in its own words: *"仍未替换一帧"*
and *"实际 NR 仍为 0"*, with the acceptance rule stated plainly — *"`intercepts>0` 仅证明钩子
看到调用，`processed_frames>0` 才证明 NR 已运行"*. The later README figure (55–60 ms) is a
**base** frame time and is not a claim that NR was running. **Interception is not integration.**

That distinction is exactly the one this plan is built around, and it is worth carrying into
our own acceptance: a hook that fires proves nothing. §6 requires `processed_frames > 0` and a
picture, not a counter.

**Taken:** its XeSS material only (per the owner), plus one number — it observed
`xessSetVelocityScale=(2,-2)` with Opti's internal NGX scale at `(1280,720)`. A velocity scale
that is not the frame size, and whose second component is negative, is precisely the
convention trap `check_motion_convention` exists to catch, and it should be checked against
ours on the first real field.

**Not taken:** the ASI plugin, the three-route entry design, the identity-substitution
machinery, the Python/Triton backend, and any of its frame-time figures as a target for us.

## 9. Where the sources are

Archived at `refs/optiscaler/`: official `README.md`, `Features.md`, `Spoofing.md`,
`Config.md`, the compatibility list, the Unreal Engine tweaks page, and issue #15 verbatim —
plus `TheAutomatic`'s README, `docs/mochizuki.md` and `docs/architecture/overview.md`. Chinese
summary with the verbatim/paraphrase distinction marked: `refs/optiscaler/提炼.md`.
