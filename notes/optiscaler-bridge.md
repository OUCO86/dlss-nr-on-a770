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

## 10. Where the code goes, now that the host has been seen running

Upstream v0.9.4 is cloned at `src/OptiScaler` (`--depth 1`, tag `v0.9.4`), so these are lines
in code we hold, not lines recollected from a browser.

**The insertion point.** `OptiScaler/inputs/NVNGX_DLSS_Dx12.cpp:949`:

    evalResult = deviceContext->feature->Evaluate(InCmdList, InParameters);

`TheAutomatic` hangs his pass *after* that line, on the upscaler's output. Our input is
pre-SR, so ours goes *before* it, on `Color`. Same file, same function, the other side of the
same call.

**What is in `InParameters` at that point.** For this game the inputs arrive through the FFX
path, `inputs/FfxApi_Dx12.cpp:614-636`, verbatim:

    params->Set(NVSDK_NGX_Parameter_Jitter_Offset_X, dispatchDesc->jitterOffset.x);
    params->Set(NVSDK_NGX_Parameter_Jitter_Offset_Y, dispatchDesc->jitterOffset.y);
    params->Set(NVSDK_NGX_Parameter_MV_Scale_X, dispatchDesc->motionVectorScale.x);
    params->Set(NVSDK_NGX_Parameter_MV_Scale_Y, dispatchDesc->motionVectorScale.y);
    params->Set(NVSDK_NGX_Parameter_DLSS_Pre_Exposure, dispatchDesc->preExposure);
    params->Set(NVSDK_NGX_Parameter_Reset, dispatchDesc->reset ? 1 : 0);
    params->Set(NVSDK_NGX_Parameter_Width, dispatchDesc->renderSize.width);
    params->Set(NVSDK_NGX_Parameter_Height, dispatchDesc->renderSize.height);
    params->Set(NVSDK_NGX_Parameter_Depth, dispatchDesc->depth.resource);
    params->Set(NVSDK_NGX_Parameter_ExposureTexture, dispatchDesc->exposure.resource);
    params->Set(NVSDK_NGX_Parameter_Color, dispatchDesc->color.resource);
    params->Set(NVSDK_NGX_Parameter_MotionVectors, dispatchDesc->motionVectors.resource);
    params->Set(NVSDK_NGX_Parameter_Output, dispatchDesc->output.resource);

That is the whole shopping list, and `MV_Scale_X/Y` is in it — the value our
`check_motion_convention` exists to pin down, handed to us by the engine instead of guessed.
The log's `LowResMV: true` says the vectors are at render resolution; `MV_Scale` is what turns
them into pixels, and the sign of the second component is exactly the trap recorded from the
Intel-Arc project in section 8.

**The shape, taken from his module and not invented.** His `dlssnr/README.md` states the
terms plainly: no compile switch, because "code behind an `#if` was code nobody compiled and
therefore nobody tested"; the call sites are one line each; deleting the module is deleting
them. Six of them, of which the ones that matter to us are the two in
`inputs/NVNGX_DLSS_Dx12.cpp` (one per evaluate route), the one in
`upscalers/IFeature_VkwDx12.cpp` (the Vulkan-on-D3D12 bridge — the mirror image of what we
need), and the three in `Config.h` / `Config.cpp`. We take the same shape: a directory beside
his, a handful of one-line call sites, no switch.

**Where we differ, and it is only the far end.** His module calls `nvngx_dlssnr.dll`. Ours
calls our own core, through a single C-ABI export, from a DLL the host does not link. The
frame crosses as handles and sizes, not as pixels on the host's side:

    struct NrBridgeFrame {           // what the host-side line hands over
        void* color; void* depth; void* motionVectors;
        unsigned renderWidth, renderHeight;      // from NGX Width/Height
        unsigned displayWidth, displayHeight;
        float jitterX, jitterY;                  // Jitter_Offset_*
        float mvScaleX, mvScaleY;                // MV_Scale_*
        float preExposure;                       // DLSS_Pre_Exposure
        int   reset;                             // Reset
    };

Field by field that is the list above and nothing added. If a field cannot be read, the field
is absent rather than defaulted, and the core falls back to identity — the same rule we
already hold for `confidence=0`.

**Failure.** His header: "it builds what it needs on first use and disables itself for the
session if anything fails, rather than retrying into a crash." Ours says the same thing: one
failure closes the pass for the frame, and the game keeps the frame it already had.

## 11. It builds here, and this is how

Answered by building it, not by estimating it. Upstream v0.9.4 was cloned to
`src/OptiScaler` and compiled whole; the result is `build_x64/OptiScaler.dll`,
26,487,808 bytes, exporting `D3D12CreateDevice`, `NVSDK_NGX_D3D12_EvaluateFeature`
and the rest of the NGX surface. That dll is the same shape as the `dxgi.dll`
already running in the game, so the build is reproducible and our module can be
added to it.

**Toolchain.** Visual Studio Community 2026 (18.10) at
`E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community`, compiler
`19.51.36260` under `VC\Tools\MSVC\14.51.36231`, Windows SDK `10.0.26100.0` at
`E:\Windows Kits\10` — on E, not C, which is why searching only C once produced
the wrong answer. This is the same toolchain `tools/build_msvc.bat` already uses
for our own dlls.

Two things the IDE would normally do for us are not available here, and both are
worked around rather than assumed:

- `vcvarsall.bat` locates the SDK through the registry, and `reg.exe` is blocked,
  so `INCLUDE` / `LIB` / `PATH` are set by hand — exactly what the project's own
  `tools/build_msvc.bat` does.
- The solution's build driver is blocked as a restricted binary, so `cl.exe` is
  driven directly, with the `Release|x64` settings read out of
  `OptiScaler.vcxproj` rather than invented. `tools/build_optiscaler.py` does the
  whole build; `tools/link_optiscaler.py` re-runs only the link, which is what
  you want after editing one file.

**Submodules are required.** The first clone had eight empty directories under
`external/` (xess, spdlog, simpleini, FidelityFX-SDK, ...). `git submodule update
--init --recursive --depth 1` fills them in about three minutes; without them
there are no headers to compile against.

Five settings that are not in the obvious place and each cost one failed build:

1. `CharacterSet` is `Unicode`, so `/DUNICODE /D_UNICODE` must be passed. Without
   them `GetModuleHandle` resolves to the `A` entry point and every wide string in
   the proxy headers fails to convert (`C2664`).
2. `RuntimeLibrary` is not set in the vcxproj, and VS defaults Release to the dll
   runtime, so `/MD` must be passed. Without it `cl` picks the static one, which
   drags in `LIBCMT` and then demands `WinMain`.
3. `cl`'s switch is `/LD`, not `/DLL`. `/DLL` before `/link` is silently not a
   cl switch, the image is linked as an executable, and the CRT asks for
   `WinMain`.
4. `ucrt.lib` (the dll-import flavour) has to be listed explicitly: the AMD
   prebuilt `ffx_*` libraries import `__imp_exp2f` from it, and `libucrt.lib`
   does not provide that symbol. `delayimp.lib` likewise supplies
   `__delayLoadHelper2` for the `/DELAYLOAD` entries.
5. Compile the vcxproj's own source list, not everything under the tree. Walking
   the directory pulls in `imgui.cpp`, `imgui_draw.cpp` and friends, which the
   project does not compile here and which fail under the shared precompiled
   header. Files the vcxproj marks `PrecompiledHeader=NotUsing` are built with
   `/Y-`.

**One warning left standing:** `LNK4098` — a default library `LIBCMT` conflicts
with the dll runtime. The link succeeds, so at least one of the prebuilt AMD
libraries was built against the static runtime. Whether mixing the two matters at
run time is not yet known, and is worth finding out before trusting a run that
behaves strangely.

## 12. Stage one: a probe that changes nothing

The module is in the fork at `OptiScaler/nrbridge/`, on local branch
`a770-nr-bridge`. It is one call, one line at the insertion point:

    // inputs/NVNGX_DLSS_Dx12.cpp, immediately before the upscaler runs
    if (Config::Instance()->NrBridgeProbe.value_or_default())
        NrBridge::ProbeBeforeUpscale(InCmdList, InParameters);

`ProbeBeforeUpscale` reads Color, Depth, MotionVectors and the exposure texture out
of the parameter block, reads `MV_Scale_X/Y`, `Jitter_Offset_X/Y`, pre-exposure and
reset beside them, and prints them. It reads no pixels, copies nothing and records
no command. The first six frames print in full; after that one line every 600.

Why a probe first, when the answer looks already known: `LowResMV: true` in the log
is the *host's* claim about init parameters. It is not the same claim as "a
resource arrived on this frame, at this size, with this scale", and everything
downstream — the sign of the second component, whether the scale is the frame
width — is a thing that has to be read, not assumed. `check_motion_convention`
exists in this repository precisely because that number has been got wrong before.
So stage one turns the interesting claim into a printed one, and stage two does not
start until it has been seen.

Two details worth keeping:

- Parameters are read the way the rest of the host reads them — typed `Get` first,
  then the untyped one — because the FFX path and the NGX path do not populate the
  same overload, and a single `Get` reads nothing on one of them.
- `NVSDK_NGX_Parameter_ExposureTexture` is the exposure key. `NVSDK_NGX_Parameter_DLSS_Exposure`
  does not exist; that was a compile error, not a guess.

Installed at `F:\Game\Lies of P\LiesofP\Binaries\Win64\dxgi.dll`, with `NrBridgeProbe=true`
in the `[Hotfix]` section. The official build it replaced is at
`backups/liesofp-20261012-1945/dxgi.dll.official-v094`; copying that back over
`dxgi.dll` returns to the unmodified host.

**Not yet known:** whether the probe prints motion vectors at all, what size they
are, and what the scale is. That is the next observation, and nothing is built on
top of it until it has been made.

## 13. What the probe printed, 2026-10-12 21:04

The user launched Lies of P with FSR selected, as before. `OptiScaler.log`, verbatim:

    [21:04:36.784051] [I] NrBridge::ProbeBeforeUpscale NrBridge frame 0 cmdList=0x22bf9d67cd0
      960x540 mv=(960,540) jitter=(0.125,0.278) preExp=0.360 reset=0 |
      color=960x540 R11G11B10_FLOAT(26) rt uav | mv=960x540 R16G16_FLOAT(34) rt uav |
      depth=1920x1080 R32G8X24_TYPELESS(19)
    [21:04:36.784065] [I] NrBridge::ProbeBeforeUpscale NrBridge contract:
      motion=true depth=true exposure=false backend=xess

**Motion vectors arrive, and they are the engine's.** Read off that line:

- `color` 960x540 `R11G11B10_FLOAT`, rt + uav — low dynamic range render target at render
  resolution, which is what pre-SR means here.
- `mv` 960x540 `R16G16_FLOAT`, rt + uav — two channels, float, **the same size as the
  colour**, i.e. render-resolution vectors, matching the host's `LowResMV: true`.
- `mv=(960,540)` — the scale is exactly the frame size, both components positive. It is
  worth saying plainly how different that is from the only other number we had: the B580
  project recorded `xessSetVelocityScale=(2,-2)`. Same host, same output backend, different
  game, different convention. This is the entire reason the probe exists and the reason
  `check_motion_convention` has to run on real frames rather than on a belief.
- `jitter` changes every frame (0.125/0.278, then -0.125/-0.278, then 0.375/0.056 ...)
  while the init flags say `JitteredMV: false`. So the colour is jittered and the vectors
  are not — the case a temporal pass wants, and the case where forgetting to unjitter
  produces the artefact we are chasing.
- `preExp` 0.360, then 0.250, then 1.000 later on. It moves, so it has to be read per
  frame and not captured once.
- `exposure=false` — this game hands no exposure texture, so the scalar is all there is.
- `depth` is 1920x1080 on the first two frames and 960x540 from the third onward. Not
  explained. Either the game is still resizing during the first evaluates, or the first
  two frames carry a different buffer. It settles, so it is recorded rather than chased,
  but a pass that reads depth must not assume the first frame is representative.

One thing the run also settled that was only argued before: the render resolution is
**960x540 here and was 1130x636 in the earlier log**. The user changed quality preset
between the two runs. Nothing in the bridge or the core has a fixed size, and §9's claim
that the extent follows the frame is now observed rather than read from the source.

**What this run did not do: change a single pixel.** The probe reads and prints. The
absence of any visible difference, and the absence of a menu entry, are both correct for
this stage — there is nothing yet to switch on.

---

## §14 Stage two hung the device — and what it settles about inserts

Stage two added a CPU readback of the motion vectors. It printed its line and then, seven
seconds later, the game went black and exited with a pop-up. The log ends with:

```
[21:18:42.371531] NrBridge sample 960x540 fmt=34 scale=(960,540) (480,270) raw=(0.0000,0.0000) ...
[21:18:49.302023] Device removed reason: DXGI_ERROR_DEVICE_HUNG
```

Three separate things in that readback were wrong. All three are written down in code we
already had, and none of them needed to be discovered by crashing.

**1. A copy recorded on a command list has not happened yet.** Our sampler recorded the
copy on the game's command list, then waited on a fence, then mapped. The fence belonged to
work submitted *before* this command list, which at that moment was still being recorded
and had not been executed — so the wait succeeded immediately and the buffer was read while
it was still empty. That is why every sample printed `raw=(0.0000,0.0000)`: not a verdict
about the vectors, a read of a buffer nothing had written. The readback resource was then
released while the GPU was still going to write into it, once the host executed the list.

The reference implementation has this exact failure in its own comments
(`refs/optiscaler/ta_DlssNr_Capture.h`, the `record()` note): *"the caller has to let the
GPU finish with these copies before mapping them ... The device was removed and the game
went down with nothing in the log — every single time anyone pressed the button."* It also
converts typeless formats to typed before taking a footprint, with the note *"an invalid
copy removes the device"*. Both were read before this was written and neither was applied.

**2. The barrier assumed a state the resource is not in.** The sampler transitioned the
motion texture from `NON_PIXEL_SHADER_RESOURCE`. It is not in that state at our insert
point. `upscalers/xess/XeSSFeature_Dx12.cpp:141-148` is explicit: for Unreal, which Lies of
P is, the host transitions the velocity texture **from `UNORDERED_ACCESS` to**
`NON_PIXEL_SHADER_RESOURCE` **inside** `Evaluate`. We run before `Evaluate`, so at that
moment the texture is still a UAV — which is also what its own desc says (`mv=960x540
R16G16_FLOAT rt uav`). A wrong `StateBefore` is not an error that fails politely on a
shipped driver.

**3. So the state has to be read, not assumed.** The place to read it is the same code:
`Config::Instance()->MVResourceBarrier`, falling back to `UNORDERED_ACCESS` for Unreal. Any
future insert in this host takes its `StateBefore` from there, for every resource, rather
than from a plausible-looking default.

**The A/B closed it.** The same ini setting, the same game, the same quality preset, with the
readback removed: 4800+ evaluates, no `Device removed`, no error line after startup. The only
variable between the two runs was that function.

What that run also gave us, from the periodic lines:

- The motion contract is steady, not a fluke of the first frames: `mv=960x540 R16G16_FLOAT`
  with `mv=(960,540)` on every printed frame out to 4800.
- **The command list is not one object.** Frames 0-2400 all arrive on `0x266adc91840`; from
  frame 3000 on they arrive on `0x267a01e72d0`, `0x266b4960990`, `0x2686569a840`. Inserting
  work later cannot assume a single command list, or cache anything keyed on it.
- `depth` again starts at 1920x1080 and settles to 960x540 by frame 2. `preExp` moves
  0.360 -> 0.250 -> 1.000. Both unchanged from the earlier run.
- About 600 evaluates per 10.3 s, i.e. ~58/s at 960x540 -> 1920x1080 through XeSS. This is the
  first number taken *with* OptiScaler in the path, so it is the only baseline of its kind.
- The startup `CreateHeap ... 80070057` line that was in the earlier log did not appear; the
  remaining two lines (`SwapchainDX12 0X80004002`, `Can't init FG Feature`) are frame
  generation only.

**Decision: the CPU readback is gone, not fixed.** The vectors are not going to be proved by
copying them to the host. They will be proved the way they are actually going to be used —
imported into the Vulkan side and consumed on the GPU, where the state question belongs to
whoever owns the resource, and where a mistake costs a wrong image instead of a hung device.
Until then this module records no command at all. The stage one probe stays, because
reading a parameter block cannot hang anything.

---

## §15 Everything invented was replaced by the reference's own shape (2026-10-12 21:5x)

The user said it twice and was right both times: *"the 都有现成的模板给你了你有啥不好做的"* and
then *"我直接叫你别干了"*. Everything below was a name of my own and is now gone. It is
written to HANDOFF.md as a standing order, and it is the first rule in the project index.

| What I had invented | What it is now (reference, `refs/optiscaler/`) |
|---|---|
| `NrBridge::ProbeBeforeUpscale` — an entry point I named | `DlssNr::EvaluateBeforeUpscale` (`ta_DlssNrFeature_Dx12.h`) |
| `struct Frame` with `hasMotion`/`hasDepth`/`hasExposure` bools | `AmdPreSr::Frame` (`ta_AmdPreSr.h`), field for field: the four **resource states**, `motionWidth/Height`, `motionJittered`, `temporalInputsValid`, `exposureScale`, `depthInverted`. Absence is a null pointer there, not a flag |
| no settings at all | `AmdPreSr::Settings` / `LookSettings` / `RtgiSettings`, with `SameHistorySettings` |
| no backend at all | `AmdPreSr::Backend`: `Backend(device, queue, dir)`, `Record(cmd, frame, settings) -> ID3D12Resource*`, `PendingListIndex`, `Submitting`, `Submitted`, `TraceBoundary`, `Shutdown`, `ReleaseSession`, `PollRelease`, `CompletePendingReleaseLocked`, `ResetGraphicsWaitState`, `InvalidateHistory`, `Status`, `IsRunning`, `RecordedFrames` |
| `[Hotfix] NrBridgeProbe` | `[DlssNr] Enabled`, `[DlssNr] RunBeforeSR` — the reference's own section and keys |
| a C-ABI and a separate runtime DLL, invented to keep GPL-3.0 at arm's length | deleted. The licence question it existed to answer is not worth a shape that differs from the spec's |

**The one difference that is allowed, and it is the only one:** the reference is an AMD card
whose upscaler output is FSR. Here the output upscaler is XeSS, because the A770 accelerates
it natively. Nothing in the bridge chooses an upscaler — OptiScaler's own path does, and the
pass only ever sees its inputs.

What stays ours, because it cannot be copied: reading this host's parameter block (typed `Get`
first, then untyped — the FFX and NGX paths populate different overloads), and resolving each
resource's real state from `Config::Instance()->ColorResourceBarrier / MVResourceBarrier /
DepthResourceBarrier / ExposureResourceBarrier` instead of assuming one.

`Record` returns null, which is the reference's own signal for "skip": the frame the game
handed over is the frame the upscaler gets. This is the seam, not the renderer.

---

## 15. The reference's own build, run on the A770 (2026-10-12, 22:55)

The packaged build (The's `OptiScaler.dll` 1.11.0 + `MochizukiNrRuntime.dll` +
`dlssnr-amd/` with the model we extracted from `nvngx_dlssnr.dll` 310.8.0) was installed over
our `dxgi.dll` and run in Lies of P. Logs:
`backups/optiscaler-logs/` and the game directory's `OptiScaler.log`.

### What the log says, verbatim

```
[22:55:55.898356] [I] DlssNr::AmdBridge::`anonymous-namespace'::IsAmd AMD NR physical adapter vendor: 8086, AMD: false
[22:55:55.980337] [I] DlssNr_Dx12::Dispatch DLSS-NR guides: depth inverted, motion vector scale 960 x 540, guides 960x540 for a 960x540 frame
[22:55:56.000397] [E] EnsureForwarder nvngx.dll_dlssnr.dll not found beside OptiScaler (...) or the game executable
[22:55:56.000436] [E] DlssNr_Dx12::Dispatch DLSS-NR unavailable: nvngx.dll_dlssnr.dll is missing
[22:57:34.962729] [I] ReportSkipOnce DLSS-NR did not run: it is switched off        <- turned off in the menu
```

**It never reached a GPU decision.** It failed on a missing 12 KB shim. There is no
`Device removed`, no new `[E]` beyond those two lines. The reading of vendor `8086` is a
log line, not a rejection — every later stage ran.

Two things are confirmed independently of the outcome: the host's own guides agree with our
probe exactly (motion vector scale 960 x 540, depth inverted, 960x540 guides for a 960x540
frame), and the game's FFX input reaches the pass as well as the DLSS one
(`DLSS-NR reached through the game's FFX input`).

### The bridge is the upstream bridge, not a different one

`ta_MochizukiNrRuntime.cpp:1`, verbatim:

```
// MochizukiNrRuntime.dll: mochizuki0323's Vulkan network (third_party/mochizuki) behind the lmxxf C ABI.
```

and `:511` refers to `upstream 743326d`. Its interop matches upstream `nr_pe_bridge.cpp`
entry for entry:

| The runtime | upstream `nr_pe_bridge.cpp` |
|---|---|
| `:712` `id.deviceLUIDValid && !memcmp(id.deviceLUID, &luid, sizeof luid)` | `:190-205` the same LUID match |
| `:918` `d->CreateSharedHandle(resource, nullptr, GENERIC_ALL, nullptr, &handle)` | `:530` |
| `:934` / `:947` `VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT` + `VkImportMemoryWin32HandleInfoKHR` | `:503` / `:457` |
| `:988` / `:993` shared fence -> `VkImportSemaphoreWin32HandleInfoKHR` | `:1031` |

The difference is one wrapper: The exposes it through lmxxf's C ABI, and the host side
(`MochizukiBackend.cpp`) only fills `MochizukiNrFrameInfo` — whose `void* color` and
`void* motion` are D3D12 resource pointers, not pixels — and calls `PrepareFrame`.

**Correction to an earlier guess of mine:** `mz_interpose.cpp` is not the bridge. It is a
pipeline prewarmer that renames `vkCreateComputePipelines` and friends to build
`dlssnr-amd/pipeline.cache` on several threads. Saved as `ta_mz_interpose.h`, whose header
comment says so.

### Where the real verdict will come from

`ta_MochizukiNrRuntime.cpp:767-771` requires five device extensions, and `:774` calls the
check that precedes `vkCreateDevice`:

```
// The capability precheck: what vkCreateDevice would refuse with the chain above, found and named before it is called.
```

A missing one throws `[unsupported] the driver lacks <name>`; `:811-831` then checks fourteen
features and throws `[unsupported] the driver lacks the Vulkan feature <name>`. On the A770
the two that matter are `cooperativeMatrix` and `shaderFloat8`. Whichever line appears is the
verdict the whole detour was made to obtain.

### The missing shim

`ta_forwarder_README.md`, verbatim on why it exists:

> Neural Rendering's snippet resolves the module that owns its caller's return address and
> refuses anything whose path does not contain `nvngx.dll` ... OptiScaler installs as
> `dxgi.dll` ... so it fails that test. This library exists to be named correctly.

The prebuilt DLL is **not** in the release package nor in the repository (only
`dlssnr_forwarder.cpp`, 44,695 bytes, is). The cheapest way past it is to put the real
`nvngx_dlssnr.dll` 310.8.0 in the game directory under the name `nvngx.dll_dlssnr.dll`:
the name passes the test and the snippet's own exports are what the host forwards to.
That is what was installed. It is reversible by deleting the two files.

---

## 16. Third run: the forwarder passes, the NGX core does not (2026-10-12, 23:43)

Building The's forwarder from his own source got past the second gate, and the third one is
the one that ends the detour. Verbatim:

```
[23:43:00.017] Util::FindFilePath nvngx.dll_dlssnr.dll found at F:/Game/Lies of P\LiesofP\Binaries\Win64
[23:43:00.019] EnsureForwarder DLSS-NR forwarder loaded from ...\nvngx.dll_dlssnr.dll
[23:43:00.019] NVNGXProxy::InitNVNGX
[23:43:00.019] [W] Util::LoadProxyLibrary Can't find _nvngx.dll, returning nullptr!
[23:43:00.020] [W] Util::LoadProxyLibrary Can't find nvngx.dll, returning nullptr!
[23:43:00.020] Util::NvngxPath trying to load nvngx from registry path!
[23:43:00.020] [E] DlssNr_Dx12::Dispatch DLSS-NR unavailable: the NGX core would not initialise
```

`_nvngx.dll` is NVIDIA's driver core. The whole `DlssNr` path — whatever `NrBackend` is set
to — initialises NGX before it reaches a backend, because the parameter block it builds is
the driver core's own capability block (`ta_dlssnr_forwarder.cpp:1-13`, verbatim: *"The
parameter block is the core's capability block rather than a fresh one"*). So the
`[unsupported] the driver lacks ...` line that the detour set out to read sits **behind** a
gate that cannot open on a machine with no NVIDIA driver, and reading it is not possible
this way.

Two gates were passed on the way, and both are worth keeping:

1. The forwarder builds. `tools/build_forwarder.py` compiles `ta_dlssnr_forwarder.cpp`
   (44,695 bytes; `windows.h` and `d3d12.h` are its only includes) into
   `nvngx.dll_dlssnr.dll`, 113,664 bytes, exporting the 25 `dlssnr_*` functions the host
   asks for. The prebuilt DLL The's README says is committed is in neither the package nor
   the repository.
2. The host reads this machine correctly and does not crash in it: vendor `8086`, the
   motion vector scale and depth inversion it derives agree with our own probe exactly, and
   the game's FFX input reaches the pass as well as the DLSS one.

What remains is the reason the detour was made: the bridge shape in `nr_pe_bridge.cpp` /
`MochizukiNrRuntime.cpp` (LUID match, `D3D12_RESOURCE_BIT` import, shared fence as a
Vulkan timeline semaphore) holds no vendor-specific extension, so it is the shape our own
bridge takes, with our own Vulkan context and our own network behind it.

---

## 17. The question that decides the design: can the A770 carry the bridge at all?

Asked before any of it went into the host, in a process of its own — `src/probe/extmem_probe.cpp`,
built by `tools/build_extmem_probe.py`. The question is about the driver, not about the game:
a D3D12 texture created as a shared resource, imported into a Vulkan device of our own on the
same adapter, with the two sides ordered on the GPU by a shared D3D12 fence imported as a
Vulkan timeline semaphore. Nothing crosses the CPU. If the driver cannot do this, the
"costs the least" design does not exist and the answer has to be found before it is built on.

Its output on this machine, 2026-10-12:

```
   adapter 0: vendor 0x1002 device 0x7550  AMD Radeon RX 9070 XT
   adapter 1: vendor 0x8086 device 0x56a0  Intel(R) Arc(TM) A770 Graphics
   d3d12 device: LUID 00000000000126f9
   vulkan: AMD Radeon RX 9070 XT (api 1.4.349) luid valid
   vulkan: Intel(R) Arc(TM) A770 Graphics (api 1.4.356) luid valid
   VK_KHR_external_memory_win32             present
   VK_KHR_external_semaphore_win32          present
   VK_KHR_timeline_semaphore                present
   timelineSemaphore yes, synchronization2 yes
   vulkan device created on the same adapter
     R8G8B8A8_UNORM     importable (dedicated only)
     R16G16_FLOAT       importable (dedicated only)
     R11G11B10_FLOAT    importable (dedicated only)
     R32_FLOAT          importable (dedicated only)
   imported: 960 x 540, 2097280 bytes, memory type 0      (each of the four)
   shared D3D12 fence -> timeline semaphore: ok
RESULT: the bridge's hand-over works on this adapter
```

**It works.** The A770 reports Vulkan 1.4.356, exposes the external-memory pair and timeline
semaphores, accepts all four formats the pass would be handed as dedicated-only imports, and
imports a shared D3D12 fence as a timeline semaphore. That is the whole hand-over: the
remaining work is recording the network on it and cutting the game's command list, not
finding out whether the ground exists.

Two things the run also confirmed. The LUID match is not decoration: the AMD card is
enumerated first and is not the card the game renders on, which is the reason this project
never takes `pds[0]`. And `dedicated only` means every imported image gets its own
allocation — the reference bridge allocates through `VkMemoryDedicatedAllocateInfo` for the
same reason, so this is the expected answer rather than a restriction to work around.

---

## 18. The second question: can the game's command list be cut? (2026-10-13, 00:2x)

The first question was about the driver (§17: can a shared D3D12 resource be imported into a
Vulkan device of our own). This one is about the game's own recording: the upscaler's
evaluate happens in the middle of a command list that belongs to the game, and the work has
to be sandwiched on the GPU —

```
[ producer ... ] -> Execute -> our work -> Execute -> [ continuation ... ]
```

Asked the same way, in a process of its own, on real hardware: `src/probe/split_probe.cpp`,
built by `tools/build_split_probe.py`. The shape is the reference's own submission module
(`refs/optiscaler/src/ta_submission`, taken unmodified) plus Detours from the OptiScaler
tree. Two textures make one execute prove both halves: the producer clears the first, the
continuation clears the second.

```
   adapter: vendor 0x1002  AMD Radeon RX 9070 XT
   adapter: vendor 0x8086  Intel(R) Arc(TM) A770 Graphics
   chosen: Intel(R) Arc(TM) A770 Graphics
   submission hooks armed: 0x00000000
   CreateCommandList: 0x00000000
   ILogicalCommandList: 0x00000000 (proxied)
   SplitSegments: 0x00000000
   between slot ran on queue 00000151981605B0 (hit 1)
   producer texture    : 1.00 0.00 0.00 1.00
   continuation texture: 0.00 1.00 0.00 1.00
RESULT: the list was cut and both halves ran, the between slot between them
```

Red in the first and green in the second is the ordering, not an inference from it: the
producer ran before the between slot and the continuation ran after it.

Two build notes that will matter again. The reference's tracker is C++20
(`std::unordered_map::contains`), so this is not a C++17 file. And the submission module's
only outside dependency is `../amd/GraphicsTracker.h` — it carries no host header, which is
what made it possible to ask this question without touching the host at all.

What this does **not** show: whether the list the game hands us at evaluate time is one that
may be cut. The reference lists what makes a list ineligible — an open split barrier, an open
or invalid query, predication, enhanced barriers, an open render pass, meta commands, RTAS
builds and copies, root or sample overflow. Lies of P is Unreal, and an evaluate inside a
render pass would be ineligible. That is the next question, and unlike these two it can only
be asked inside the game.

## §19 Answered in the game: the list can be cut (2026-10-13, 00:2x)

The build with `WrapLists=true` was installed as the game's `dxgi.dll` and the user launched
into a rendered scene. Nothing was cut — the build only reports. Verbatim from
`OptiScaler.log`:

```
[00:24:05.457504] [I] LogFrame NrBridge frame 1 960x540 mv=(960,540) jitter=(0.375,0.056)
                          preExp=0.360 reset=0 | color=960x540 R11G11B10_FLOAT(26) rt uav
                          | mv=960x540 R16G16_FLOAT(34) rt uav
                          | depth=1920x1080 R32G8X24_TYPELESS(19)
[00:24:05.457532] [I] LogFrame NrBridge contract: motion=true depth=true exposure=false
                          backend=xess
[00:24:05.457646] [I] EnsureSubmissionArmed NrBridge: submission hooks armed 0x0 on queue
                          0x19a9ea4e2f0
[00:24:36.833624] [I] NrBridge frame 1800: list 0x19c53b19060 proxied,
                          splitIneligible=false reason=eligible
[00:24:05.457632] [I] NrBridge frame 0: list 0x19aaf3c4f60 is not one of ours (qi 0x80004002)
```

Counted over the whole session:

| What | Count |
|---|---|
| `proxied, splitIneligible=false reason=eligible` | **24** |
| `proxied, splitIneligible=true` | **0** |
| `is not one of ours (qi 0x80004002)` | 12 |

**The answer is yes: every list this game hands us that we wrapped is eligible to be cut.**
No open render pass, no enhanced barrier, no open query. The Unreal case that was the reason
for asking does not happen here. `0x0` after `armed` is `S_OK` — the wrapping hook went in.

The twelve that are "not one of ours" are not a second kind of failure. They are two fixed
addresses, `0x19aaf3c4f60` and `0x19aaf3c2520`, seen from frame 0 onward and reused for the
whole session. They were created before the hook was armed: the device is created at
`00:23:52` and the first evaluate — which is when `EnsureSubmissionArmed` runs — is not until
`00:24:05`. A list the game made in those thirteen seconds was never wrapped, and a plain
`ID3D12GraphicsCommandList` answers `QueryInterface(ILogicalCommandList)` with
`E_NOINTERFACE`, which is what `0x80004002` is. It is a coverage gap in when we arm, not a
refusal by the driver. Moving the arm to the device hook closes it; nothing about the split
itself has to change.

Two more things the log settles. `reset=0` on every frame logged, so this game does not hand
us a reset flag through the parameter we read — the temporal reset has to come from somewhere
else or be inferred. And `exposure=false`: there is no exposure texture, which is the same
thing the init flags said (`AutoExposure: true`, handled by the host's own XeSS path).

No new error line appeared. The only two `[E]` lines in the whole log are the two already
known from §8 — `UpdateFfxApiProviderEx for: SwapchainDX12, result: 0X80004002` and
`XeSSFeature::InitXeSS CreateHeap bufferHeapDesc failed 80070057!` — both in the window before
the game was switched to FSR. The session ran past frame 15600 without hanging.

## §20 The cut runs, and both halves reach the queue (2026-10-13, 00:5x)

`LmxxfEvaluateCut.h` is the reference's own file, byte for byte, and the cut is made where the
reference makes it. Nothing is enqueued for the gap, so the only thing this build changes is
that the list is cut. Verbatim, on the same cadence as the frame line:

```
[00:56:10.502198] [I] LogFrame NrBridge boundary: eval=3600 cutHr=1 proxyHits=901
   cutsRecorded=901 rejected=0 unsplitSubmitted=20538 producerSubmitted=901
   continuationSubmitted=901 submitFailures=0 (counts are NOT GPU completion)
```

| Field | Value | What it is |
|---|---|---|
| `cutsRecorded` | 901 | `TrySplitAtEvaluate` returned `S_OK` |
| `producerSubmitted` | **901** | the first half was executed |
| `continuationSubmitted` | **901** | the second half was executed |
| `submitFailures` | **0** | no `ExecuteOnWithBetween` failed |
| `rejected` | 0 | no list refused to be cut |
| `unsplitSubmitted` | 20538 | lists that were never cut, submitted in their original batch |

The three that matter are equal and the failure count is zero: every cut produced two
executions, in order. The image did not change and the session did not hang. The gap between
those two executions is where the reference puts its renderer, and it is now open.

`unsplitSubmitted` being large is the intended behaviour, not a shortfall. The reference keeps
uncut lists in one contiguous `ExecuteCommandLists` because splitting every submission would
change resource decay on its own; 20538 is the game's other lists going through untouched.

Two things worth keeping. First, `cutHr` alternates between 0 (`S_OK`) and 1 (`S_FALSE`, its
documented meaning of "not a list we wrapped"), which is the boot-list gap from §19 still
showing up frame by frame. Second, everything stays at zero until about frame 2400: the title
and load screens submit boot lists only, so the first NR-capable frames arrive after that.

### A judgment of mine that was wrong, and what replaced it

The first cut build printed the between slot's own counters, and I read `between=0` as the slot
never running. It was not evidence of anything. The reference's `BetweenThunk` begins

```cpp
if (!p.targetList || p.targetList != list)
    return;
```

which returns before it increments anything, and with no renderer there is no pending enqueue,
so `targetList` is null and the counters read zero whether or not the slot ran. The check was
replaced by the reference's own, found as a string in its shipped
`pkg/ta_v1.11.0/OptiScaler.dll`:

```
lmxxf boundary: eval={} proxy={} cutHr={:X} proxyHits={} cutsRecorded={} rejected={}
unsplitSubmitted={} producerSubmitted={} continuationSubmitted={} submitFailures={}
(counts are NOT GPU completion)
```

which is why §20's line has the fields it has. The parenthetical is the reference's own warning
that these are submission counts and not GPU completions.

### Found in the same binary, for the boot-list gap

```
HookToDevice lmxxf SubmissionHooks::ArmCreate failed: {:X}
HookToDevice lmxxf early executable proxy: {} (submission hook ready={})
lmxxf: Split failed hr=%08X reason=%s
lmxxf: split ineligible: %s (NO NR)
```

`HookToDevice` settles where the reference arms: at the device, with `ArmCreate`, which needs a
device and not a queue. That is what makes early wrapping possible at all — a hook armed after
the game has already built its boot lists cannot reach them. This is the change §19 identified,
and now it has an original to copy rather than a guess to follow.

## §21 The gap probe: two crashes, then the reference's own shape (2026-10-13, 01:4x)

Both crashed attempts shared one assumption: that the between slot can carry a D3D12 command
list submission of our own. The diagnostics disproved it in one line each time -- the first
slot run removed the device within a millisecond:

    01:47:08.451  cut #1: list armed for the slot
    01:47:08.455  gap run #1: took=2.285ms
    01:47:08.456  LocalPresent 887A0005 / Device removed reason: INVALID_CALL

What that rules out, with the counts from earlier sessions: nested ExecuteCommandLists through
the trampoline is fine (the split's producer and continuation halves are nested submissions,
and they ran 901 times without the probe), and Signal from inside the expansion is fine (the
reference's own LogicalList::Execute signals its retire fence in the same nesting). What was
left was the thing the two attempts had in common and the reference never does.

And the reference says so, in its own words, in the passthrough path of its runtime:

    // an ExecuteCommandLists from here would re-enter the game's detoured one

Its between work is: producer->Signal(toVk.fence) on the game's queue, the real work as a
Vulkan vkQueueSubmit, then producer->Wait(fromVk.fence). No D3D12 list is ever executed in the
slot. The fence Signal/Wait is the D3D12 half of that shape, and it is the piece our host has
already proven at that nesting depth.

The probe is now exactly that piece: the slot job calls queue->Signal on a fence we own, once
per cut, and nothing else. It touches no resource, knows no state, and GetCompletedValue turns
the same signal into GPU-side proof that the queue reached the gap in order. The earlier
"decay" diagnosis of the first crash is withdrawn: the diagnostics show the first run dying,
and decay is a second-run phenomenon. The upload-heap fix was answering a question the session
never reached.

What the earlier attempts did prove, and stays true: the trampoline handoff, the cut itself,
and the between slot's CPU path all run. What is new in this build: Gap has a fence and
counters, nothing else -- no allocators, no lists, no copy.

### §21 result: the slot runs, and the GPU reaches it (2026-10-13, 01:57)

    NrBridge gap: between=1533 enqueue=1533 skipped=0 | runs=1533 submits=1533 failures=0
    cpu=8.829ms max=0.021ms gpuDone=1533 gapSignalled=1533
    NrBridge boundary: eval=4800 cutHr=0 cutsRecorded=1533 rejected=0
    producerSubmitted=1533 continuationSubmitted=1533 submitFailures=0

Every cut reached the slot (between = enqueue = runs = submits = 1533, skipped 0, failures 0),
and the GPU side agrees: gpuDone caught up to the last value queued from the slot, so the
signal enqueued between the halves was carried out in order and not merely recorded.

The cost of standing in the gap: 8.829 ms of CPU over 1533 runs, 0.0058 ms each, with a peak of
0.021 ms. That is the fixed price every frame pays for the bridge, before any Vulkan work is
put in it, and it is three orders of magnitude below the 30 ms frame this has to fit into.

Two errors in the log, both already known from §8: SwapchainDX12 0x80004002 and XeSS
CreateHeap 80070057. No new error, no device removal, past frame 4800.

What is left of the probe is now scaffolding: the fence signal is real, the Vulkan work it
stands in for is not. The next thing in its place is the reference's own order --
producer->Signal, vkQueueSubmit, producer->Wait.

## §22 The hand-over, measured outside the game: the import, not the wait (2026-10-13, 02:3x)

The stall was reproduced in a process of its own, with no game, no hook and no frame -- a
console probe that builds a D3D12 device and queue on the A770, a Vulkan device on the same
adapter, and runs the hand-over both ways across two shared fences. src/probe/handshake_probe.cpp,
tools/build_handshake_probe.py. Five cases, one variable each:

    case A  two-step import, wait, empty command buffer
       d3d12 signalled 1; vulkan reads 1
       vulkan submit finished (the wait was satisfied)
       vulkan signalled 1 into the other fence; d3d12 reads 1

    case B  import at create, wait, empty command buffer
       d3d12 signalled 1; vulkan reads 0
       vulkan submit DID NOT FINISH in 2s (the wait was never satisfied)
       vulkan signalled 1 into the other fence; d3d12 reads 0

    case C  two-step import, wait, barrier recorded          -- as A
    case D  two-step import, wait at TOP_OF_PIPE             -- as A
    case E  two-step import, no wait, signal only            -- finished, d3d12 reads 1

The adapter does the hand-over in both directions. What it does not do is accept the fence
when the import is chained onto the semaphore's creation: with the import in the create,
Vulkan reads 0 out of a fence D3D12 had already carried to 1, the submit waits for a value
that will never arrive, and the value Vulkan signals back never reaches D3D12 either. The
driver does report the handle type as importable, and it accepted the create without error --
the failure is silent, which is why it cost 1382 ms of waiting and a frame rate before it cost
anything legible.

It is also the shape the reference does not use. nr_pe_bridge.cpp Device::import_fence (989)
creates the semaphore as a timeline and then imports the handle into it, as two calls. And
VkImportSemaphoreWin32HandleInfoKHR carries an implicit valid usage that pNext must be NULL,
which the one-call version necessarily breaks by hanging the semaphore type off the import.

Cases C, D and E narrow the rest: an empty command buffer is not the problem, the wait stage
is not the problem, and the Vulkan to D3D12 direction does not depend on the wait at all.
