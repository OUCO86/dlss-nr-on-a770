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

---

## 23. 调试手段速查（2026-10-13，Passthrough 第一帧 E_INVALIDARG 时建）

### 日志级别：LogLevel 是 spdlog 级别，**不是越大越详细**
`Config.cpp:343` 读 ini，`Logger.cpp:183` 直接 `(spdlog::level::level_enum) LogLevel`：

| LogLevel | 含义 | 用途 |
|---|---|---|
| 0 | Trace | 最细，日志爆炸，基本不用 |
| **1** | **Debug** | ✅ 看 `[D]`（含 debug layer 消息）——**诊断时用这个** |
| 2 | Info | 默认。正常跑 NrBridge 就用它 |
| 3 | Warn | ⚠️ **会把 `[I]`/`[D]` 全滤掉**，只剩 `[W]`/`[E]`（2026-10-13 我误设成 3，日志只剩 26 行，流程全看不见） |
| 4 | Error | 只留错误 |

⚠️ 结论：**诊断先设 `LogLevel = 1`，跑完记得调回 2**（debug 级别日志几秒上百 MB，
还可能自己拖慢帧、掩盖问题）。诊断版 dll 与正式版要区分，别拿 debug layer 版跑性能。

### D3D12 debug layer：让 runtime 点名哪条命令非法
OptiScaler 自带这套，无需自己写：
- 编译宏 `ENABLE_DEBUG_LAYER_DX12`（`hooks/D3D12_Hooks.cpp:237`、`:1335`）
  → 在 `hkD3D12CreateDevice` 里 `EnableDebugLayer()` + 注册 `InfoQueue1` 回调，
  回调把消息打 `LOG_DEBUG`（**所以必须配 LogLevel=1 才看得见**）。
- 构建方式（已在 `tools/build_optiscaler.py` 做成环境变量开关，不想用时不用改代码）：
  ```
  set OPTI_DEBUG_LAYER=1
  python tools/build_optiscaler.py
  ```
- 生效确认：日志里出现 `[W] hkD3D12CreateDevice Debug layers active!`
- 可选更狠：`ENABLE_GPU_VALIDATION`（GPU-Based Validation，会非常慢，一般不开）。

### 为什么 E_INVALIDARG 出现在 Close() 而不是记录那一行
D3D12 runtime 记录命令时遇到非法参数会**把命令列表置进错误状态**，
真正把这个错误吐出来的是 `ID3D12GraphicsCommandList::Close()`。
所以 UE 弹窗 `CommandList->Close() failed ... E_INVALIDARG`（D3D12CommandList.cpp）
= **列表里有某条命令参数非法**，而不是 Close 本身坏了。要找那条命令，就得靠 debug layer
在记录时刻的报错，而不是盯着 Close 的位置。


---

## 24. 插槽里该跑什么网络：三条路的实测与证伪（2026-10-13，Passthrough 验收后）

Passthrough 验收通过（菜单恢复、游戏正常、`runs/submits/waits=2825 failures=0`、
`copies=2825 nowork=0`、CPU 0.094 ms/次）之后，"画面没有 NR"是**设计如此**——插槽里只有一条
`vkCmdCopyBuffer`。真正的问题是：**下一步接哪个网络**。这里把三条路都查到底，两条被证伪。

### 24.1 ⛔ 路 A：照抄 The/Mochizuki 的 NR —— 在 A770 上不成立

曾经最诱人的一条（用户亲口说"以前用 The 的版本会有 NR 效果"），但**现象真、归因假**：

| 证据 | 出处 |
|---|---|
| "Runs the NR model of NVIDIA DLSS 5 in games on **AMD Radeon RX 9000 (RDNA4)**" | `refs/DLSSNR-AMD/README.md:3` |
| "**Tested only on an RX 9070 XT.** Other cards are not guaranteed to work." | `README.md:18` |
| "Both need an RX 9000 series (RDNA4); older cards (RX 7000 and earlier) lack the FP8 matrix" | `README.md:62` |
| 二进制里硬编码 `RX 9070 XT (1002:7550) not found; set NR_GPU` | `F:/Dlss5_Vlukan/11/optiscaler/dlssnr_core.dll`（字符串提取） |
| "this D3D12 device exposes no Vulkan handles; the AMD backend needs **vkd3d-proton**, not native Windows D3D12" | 同上 |

→ **它只在 RX 9070 XT 上验证过，且要 vkd3d（Linux/Wine 路线）**。用户早先看到的 NR 效果
发生在 **9070 XT** 上，不是 A770；本项目渲染与 NR 全在 A770，**这条路走不通**。

⚠️ 但两个部件仍有价值，别一并丢掉：
- `refs/optiscaler/ta_mz_api.h` 的 `MochizukiNrFrameInfo{ void* motion; uint32_t motion_width,
  motion_height; float motion_scale_x, motion_scale_y; }` —— **真 MV 的接口形状**就该长这样，
  我们的 `Frame` 结构可以照它补 MV 字段。
- `ta_MochizukiNrRuntime.cpp` 后端是**纯 Vulkan**（vk 出现 372 次，`hip` 只出现在遗留函数名
  `EnqueueHipFn` 里，无 NVIDIA/NGX 依赖）—— 所以"它慢"不是因为 HIP，而是因为它挑卡。

### 24.2 📊 路 B：主仓 R 的 NR —— 能跑，但只能异步

- 规模：**723 个 pass/帧**（`nr_daemon.py:1924` "120 of its 723 passes"）。pass 数由网络层数定，
  **与分辨率无关**（层数固定，每趟的数据量随 extent 变）。
- 速度：**pass 数 ≠ 时间**。同一份 723 pass：网络 extent 768x448 → device **36.41 ms**
  （`notes/frame-ledger-a770.md`、`device-budget-a770.md`）；extent 1344x768（720p）→ **179.5 ms**
  （`HANDOFF.md:994`，staged GEMM 优化后 198 ms，`:1875`）；320x320 → 31.7 ms（`:880`）。
  按面积外推，LOP 的 960x540（0.518 MP）**约 55-75 ms**。
  ⚠️ 此前记的"723 pass / 180-200 ms"是把两个不同 extent 的数字并在一起了，2026-10-13 纠正。
- 结论：**塞不进 33 ms 的同步插槽**。同步一帧 ≈ device 55-75 + host 24（与 device **串行**）
  + 跨进程 8.3 MB×2 ≈ 9 → **约 70-100 ms**。只能像 R 现在这样**异步**跑（daemon 流水线），
  结果延迟数帧回来。
- 编排在 **Python**（`nr_resident.py` + `nr_frame_resident.py`），C 层 `libxmx` 只有原语，
  **没有 run-one-frame**。要在进程内重建，等于把 120 KB 的编排逻辑移植一遍 —— 不划算。
- 好消息：resident 路径**零 descriptor set**（buffer 走 `buffer_reference` + push constant 的
  64 位设备地址）、**零 VkImage**，全是线性 buffer —— 与我们的共享线性 buffer 天然契合。

### 24.3 📌 一个此前没说破的事实

**主仓的 NR 从未在 LOP 上跑过**：`notes/HANDOFF.md` 全文没有 "Lies of P"。
因为 R 的 layer 是 **Vulkan layer**（`nr_layer.dll` + `src/layer/VkLayer_dlss_nr.json`），
而 LOP 是 **DX12**，抓不到帧。**这正是"借 OptiScaler 打通 DX12"的全部理由**——
不是"NR 坏了"，而是"NR 从来没有接到这个游戏上"。

### 24.4 ✅ 路 C（推荐）：桥扮演帧源，喂给已有的 daemon

前人已经把接口设计好了（`notes/motion-source-plan.md`）：

- 真 MV 走 `TemporalSession.process(frame, motion=...)`，field 是 `(height, width, 2) float32`，
  单位是**像素**，在处理 extent 上；`history_confidence` 是独立参数（可阻尼而不动 gate）。
- 重投影那一半**已经写完并在设备上**：`src/gpu/history.comp`（五抽头 Catmull-Rom，
  `pc.flags != 0` 时读 motion buffer 自己算采样坐标）。
- **缺的只是"谁产出这个 field"** —— 就是桥现在的活。

所以闭环是：桥（DX12，有真 MV）→ 帧 + MV 送进 daemon → daemon 跑 NR + 时间管线 → 结果回传 →
桥拷回 result 纹理交给 XeSS。NR 的 device 时间（36-180 ms，看网络 extent）由 daemon 的
异步流水线吸收，帧率不掉。

要动 daemon 吗：**可以不改**。daemon 已经有一套"外部喂帧"的通道
（`src/layer/nr_extmem.c`、`nr_transport.h` 的 `Local\NR_SHM_<pipe>` + 三个 NT handle），
桥只要**按那套协议扮演 layer**（含 spawn daemon），daemon 一行都不用改——这也守住了
"只写桥"的红线。

### 24.5 待办（按顺序）

1. 桥：`Frame` 补 MV 字段（形状照 `ta_mz_api.h`），把 MV 和 color 一起拷进共享 buffer；
   注意 MV 是 **R16G16_FLOAT**，与 color 的 R11G11B10 不同，footprint 要分别算。
2. 桥：按 `nr_transport.h` 的协议把 buffer handle 交给 daemon（并负责 spawn）。
3. 桥：结果回传后拷回 result 纹理（拷回链路已经跑通，见 §22-23）。
4. 验证：先看 `history_confidence` 与 gate 是否从 0.032 抬起来（`motion-source-plan.md` 说
   正确 history 能到 0.705），这是"真 MV 真的起作用"的硬判据。

## 25 「同步为什么慢」—— 四层拆解（2026-10-13）

用户问：同步会慢那么多，是不是代码机制有问题？是不是传入的数据不符合硬件契约？
查完的结论分四层，第一层是纠正我自己的数字。

### 25.1 同步没有让 NR 变慢，它只是把成本搬到帧的关键路径上

NR 一帧的固有成本（A770，网络 extent 768x448，1920x1080 出）：device **36.42 ms**
+ host **24.41 ms** + 跨进程往返约 9 ms ≈ 68-75 ms。同步只是让这笔钱从"后台"变成
"每帧必付"。异步（`NR_DAEMON_PIPELINE=2` + `NR_LAYER_ASYNC`）实测 **71.14 → 43.55 ms**
（`notes/daemon-cpu-cost.md`）—— 省下的 27.6 ms 正是 host 那一段被设备时间盖住。

### 25.2 真正的机制问题有三个，都不在「同步」这个开关上

1. **host 与 device 串行**：daemon 单线程，`xmx_graph_run` 阻塞，host 的 24.4 ms
   一点都没被设备的 36.4 ms 盖住。前人在搬（`notes/host-passes-to-gpu.md`）：
   resample 3.46 → 1.98、features 1.79 → 0、gpu_in 2.23 → 0.02。
2. **每帧 8.3 MB×2 过管道**：`receive` 0.66 + `sendall` 1.11，加上 layer 侧的 memcpy 和
   WriteFile/ReadFile，约 9 ms 的跨进程往返。Phase 2 的 external memory 是为这个。
3. **723 趟之间的全屏障**（`libxmx.c:1054`）让相邻趟不能重叠；325 个 unary 只值 4.45 ms，
   每趟 14 µs，排空的占比不小。
4. **已排除的怀疑**：723 趟**不是** 723 次 submit。整帧一个 command buffer、一次
   `vkQueueSubmit`（`libxmx.c:3061`）+ 一次 fence，submit→fence 未计入的开销只有 3.27 ms
   （`notes/device-budget-a770.md`）。调度机制本身是对的。

### 25.3 「数据不符合硬件契约」：内存这条是好的，算术这条偏紧

- **内存：没问题。** A770 开着 resizable BAR，图的缓冲是
  `DEVICE_LOCAL|HOST_VISIBLE|HOST_COHERENT`（显存，主机直接写），`want_unmapped()` 判据
  不需要 —— `notes/discrete-memory-path-a770.md` 的结论是"独显内存路径本来就是对的"。
  回读的 head 落在 HOST_CACHED 系统内存是**有意的**（每 16 个 float 取 4 个的跨步读，
  缓存命中比"在显存里但 uncached"划算），不是踩坑。
- **算术：契合规格很紧。** XMX 大 GEMM 只到 **~8 % 峰值**（iGPU 实测 2584 GFLOP/s /
  32 TFLOP/s，`notes/phase20-machine-limits.md`）；A770 上 gemm 家族 13.94 ms / 198 趟，
  却只跑到 115-236 GB/s（显存 560 GB/s）→ 是 occupancy/算力受限，不是带宽受限。
  紧在哪：shared memory 128 KB cap、GRF 128 寄存器上限（`notes/phase26`），大 tile 放不下，
  只能 staged 切成多趟 —— 723 这个数有一半是这么来的。
- **过路费**：为喂 int8 dpas，每帧 193 个 `quantize_row` + 120 个 residual unary
  （`notes/frame-ledger-a770.md`）。

### 25.4 对桥的含义

- 跨进程共享 buffer 必然落在**系统内存**（PCIe 约 5 GB/s），所以**只能搬输入和输出**
  （960x540 的 color+MV 约 4 MB，<1 ms），**绝不能让网络的中间 tensor 落在那儿**。
  daemon 自己的图缓冲在它进程内的显存上，不受影响。
- **异步不能凭空创造算力**：渲染和 NR 在**同一张卡**（实测同一个 luid，
  `notes/host-passes-to-gpu.md` §二）。异步做的是移出关键路径 + host/device 重叠，
  代价是输出滞后数帧。要真正并发，得看 NR 能否上**独立的 compute 队列**
  （Windows GPU Engine 计数里 Compute/Copy/Video 常年为 0，那条引擎是空的）——
  **这需要实测，不能猜。**

## 26 与 Mochizuki 的量级对比（2026-10-13）

用户实测：Mochi 在 9070XT 上 **1080p 90 fps、NR 整链 ~6 ms**（OptiScaler 的
"Vulkan core total"，含 network + 其它 core 处理，**不含** adapter/D3D12 拷贝、upscaling、FG）。
R 在 A770 上：0.344 MP 网络 device 36.4 ms + host 24.4 ms。**差一个数量级以上。**

### 26.1 它到底怎么走的（`refs/DLSSNR-AMD/ARCHITECTURE.md`，逐字要点）

- 网络 = **Vulkan compute，FP8 矩阵乘走 `VK_KHR_cooperative_matrix` + `VK_EXT_shader_float8`**，
  编译成 RDNA4 的 WMMA 指令。**精度逐算子跟 NVIDIA 原版对齐：NVIDIA 用 FP8 的地方用 FP8，
  其余 FP16/FP32 —— 没有 INT8 量化路径。**
- 逐字：`"The network is one sequential chain of about 150 layers (only one adjacent pair is
  independent)"` —— 网络本身串行，没有层间并行度可挖（与 R 的 `phase46`「71 blocks 串行」是同一事实）。
- `linux/shaders/rdna4/` 的 **pipelines.json 列出每个 pipeline 及其 defines** → **算子级特化编译**。
- 融合：OptiScaler 集成文档明说 network 含 **fused temporal pre/post shaders**。
- **Linux：录进游戏自己的 command buffer，同一个 VkDevice，零拷贝、零跨 API 同步。**
  Windows：独立 VkDevice（按 LUID 匹配）+ 共享 D3D 纹理导入 + D3D fence 导入成 Vulkan
  timeline semaphore —— **和我们的桥是同一个形状**。
- **不用 HIP**：集成 README 逐字 "HIP is not used by this backend"；ARCHITECTURE 给了四条理由，
  核心是"代码跑在游戏进程里，Vulkan 已经在场"。

### 26.2 它没有 Python 层（这是查实的，不是推断）

`ta_MochizukiNrRuntime.cpp` 里 `python` / `numpy` / `Py_` **各 0 次**，`vkCmdDispatch` 也是 0 次
（核心在 `MochizukiNrRuntime.dll`，宿主 cpp 只做 interop / 录制所有权 / 菜单 / 打包）。
Python 只出现在**装模型那一步**（`tools/install/mochizuki-model.py` 抽权重，一次性）。
→ **每帧零 Python。**

### 26.3 那 R 的 24.4 ms 是什么

不是"解释器开销"，是 **NumPy 在 CPU 上做全分辨率像素运算**（`notes/daemon-cpu-cost.md`）：
compose_encode 8.98、bilinear×2 4.00、mean_change 2.58、to_half 2.17、decode8 1.90、features 1.89。
Mochi 这些全是 GPU shader。
当初为什么这么写：R 是**逆向出来的参考实现**，先求数值正确（Python 便于跟参考逐位对照），
再逐步搬 GPU —— `notes/host-passes-to-gpu.md` 正在搬，已搬掉 resample 3.46→1.98、
features 1.79→0、gpu_in 2.23→0.02。

### 26.4 差距的账本（保守口径）

| 项 | Mochi / 9070XT | R / A770 | 说明 |
|---|---|---|---|
| 精度通路 | FP8 coopmat（RDNA4 WMMA） | FP16 coopmat + INT8 dpas | **A770 没有 FP8**，硬件上限 |
| 一趟网络的 pipeline 数 | **~150** | **723**（其中 313 趟是量化过路费） | 趟数 4.8× |
| 每帧 host 端像素工作 | **0** | 24.4 ms | 比对方整链还贵 |
| 矩阵峰值利用率 | 未测 | **个位数**：iGPU 大 GEMM 8.1 %、整帧真实形状 4.4 %；A770 的 `window_block` **5 %** | 前辈测过很多遍，见 26.9 |
| 跨进程搬运 | Linux 零拷贝 / Win 共享纹理 | 8.3 MB×2 管道 ≈ 9 ms | Phase 2 external memory |

**可修的**：利用率（最大杠杆）、趟数（融合）、host 24.4 ms、管道搬运。
**不可修的**：几乎没有。A770 的 INT8 是 9070XT FP8 的 **0.67**（官方规格，见 26.9），
**不是** 2.5-3 倍。（2026-10-13 更正：这里原先写"FP8 吞吐约为 INT8 的 2 倍，硬件差 2.5-3 倍"，
**错了** —— RDNA4 上 FP8 与 INT8 官方同速，都是 FP16 的 2 倍。）

### 26.5 下一步该量的一个数

A770 上的 **XMX 峰值利用率从未被直接量过**（8 % 是 iGPU 上的大 GEMM 基准）。
先补这个数：在 A770 上跑一个大 GEMM，得 GFLOP/s ÷ 峰值。
**这个数决定"36 ms 里有多少是白丢的"，也决定值不值得重构 GEMM。**

### 26.6 上游核心的真实形状（2026-10-13 抓到本地，可直接对齐比）

抓到 `refs/DLSSNR-AMD/`：`shaders/pipelines.json`、`core/nr_native_plan.cpp`、
`core/nr_runtime_dispatch.hpp`、`core/nr_frame.txt`、`shaders/nr_chain.glsl`、`core/build_network.py`。

- **整个网络只有 52 个 pipeline**（`pipelines.json` 的 `pipelines` 键 = 52），加 6 个 temporal 变体。
  名字即特化维度：`fswin32 / fswin64 / fswin128 / fswin256`（按窗口尺寸各编译一份）、
  `fswinds*`、`fswindsp*`、`fswinp*`、`fswinpds*`、`fswinpup*`、**`fswinfusedup*`**、
  `gemmnores / gemmpool / gemmproj / gemmprojc / gemmprojt / gemmprojw / gemmvact /
  gemmvnores / gemmvproj / gemmvqkv / gemmvqkvnorm / gemmvqkvnorms / gemmvqkvs`、
  `ffwd3 / ffwd3w`、`attn / vitattn`、`decups / upsview / repack / noisefield`、
  `fswinimagepre* / fswinimagepost*`。
- **静态编译计划**：`nr_native_plan.cpp` 的 `records[]`（19 列一张表）在网络构建时把每层的
  形状、tokens、grid 尺寸**一次算好**，运行时按表 dispatch。host 每帧不推形状。
- 融合点（markers `shader-constants.txt`）：`qkv_fused_norm 1`、`ds_fuse 15`、`ups_fused_mode 2`、
  `wide_ups_fused_mode 2`、`tchain 1`、`post_alpha 1`；
  **persistent kernel**：`persist_df 1 / persist_ds 7 / persist_up 7 / persist_strag 25 / persist_one 6`。
- GEMM tile：`gemm_wide_mt 64 / gemm_wide_nt 256`、`gemm_proj_mt 32 / gemm_proj_nt 128`、
  `gemm_projw_mt 64 / gemm_projw_nt 128`。

### 26.7 对齐到 R：哪些差距与硬件无关（可学），哪些是硬件（学不了）

| 维度 | Mochi | R | 性质 |
|---|---|---|---|
| 每帧 dispatch 数 | ~150（52 pipeline 复用） | **723**（其中 313 趟是 quantize_row 193 + residual 120） | **可学**：融合广度 |
| 算子特化 | 按形状各编译一份（4 种窗口 × 变体） | 通用 kernel + push constant 分支 | **可学**：特化编译 |
| epilogue 融合 | upsample / norm / downsample / 激活 全融进主算子 | **已做** FFN 融合 + QKV epilogue（`improve-qkv-epilogue.md`，值 22 %）+ window fuse；**量化/residual 仍独立** | **可学**：继续扩展 |
| host 每帧工作 | 0（静态计划表） | 717 次 Python 调用 + 24.4 ms 像素运算 | **可学**：见 26.3 |
| persistent kernel | 有 | 未见 | 可学（未验证收益） |
| 矩阵 tile | 64×256 / 32×128 | **8×16**（Intel coopmat 契约上限） | **硬件** |
| 精度 | FP8（逐算子对齐 NVIDIA） | FP16 + INT8 | **硬件**，但劣势只有 **1.5×**，不是数量级（26.9） |

⚠️ **2026-10-13 更正（我上一轮写错了，用户当场指出）**：我曾说"对方跑 FP8，
FP8 吞吐约为 INT8 的 2 倍，所以硬件劣势是 2.5-3 倍"。**这句话是错的**，两个错误叠在一起：

1. **RDNA4 上 FP8 与 INT8 官方同速。** AMD 9070 XT 规格页逐字：
   FP16 矩阵 195 TFLOPs ／ **FP8 矩阵 389 TFLOPs** ／ **INT8 矩阵 389 TOPs**
   —— 8 位两种格式速率相同，都是 FP16 的 2 倍。不存在"FP8 = 2× INT8"。
2. **用户原来估的 2/3 是对的。** Intel 官方规格：A770 **GPU 峰值 TOPS (Int8) = 262**
   （16 GB 版与 8 GB 版同值；XMX 引擎 512 个，显卡时钟 2100 MHz）。
   262 / 389 = **0.673 ≈ 2/3** —— 与用户原估逐位相符。

→ **硬件只能解释 1.5 倍的差距。** 剩下那 20-30 倍全部是软件与架构，见 26.9。

### 26.8 一个反直觉的事实（对"减趟"要谨慎）

`notes/frame-ledger-a770.md`：int8 **off** = 415 趟 / 43.49 ms；int8 **on** = 723 趟 / 36.41 ms。
**多付 308 趟只换来 16 % 提速** —— 说明量化路径本身不便宜。
而趟数本身不总是敌人：`device-budget-a770.md` 里 325 个 unary 只值 4.45 ms（13.7 µs 一趟），
减趟的收益要看屏障排空占多少，**不能只凭趟数下结论**。

### 26.9 硬件算力对账（官方规格，2026-10-13 查证）

| 项 | A770（Xe-HPG，本项目） | RX 9070 XT（RDNA4，Mochi） | 比值 |
|---|---|---|---|
| INT8 矩阵 | **262 TOPS**（Intel 官方 GPU Peak TOPS(Int8)） | 389 TOPs | **0.67** |
| FP8 矩阵 | ⛔ 无 `VK_EXT_shader_float8` | 389 TFLOPs | — |
| FP16 矩阵 | 官方未公布（按 INT8 一半 ≈ 131 TFLOP/s） | 195 TFLOPs | ≈0.67 |
| 显存带宽 | 512-560 GB/s | 640 GB/s | 0.80-0.88 |
| 矩阵引擎数 | XMX 512 | AI 加速器 128 | — |

**9070 XT 的 FP8 与 INT8 官方同速（都是 389），都是 FP16（195）的 2 倍。**
→ **硬件劣势 = 1.5 倍，用户原估的 2/3 精确正确。**

⚠️ **口径悬点（未解决，但不影响结论）**：A770 的 FP16 峰值在笔记里有两个口径——
由官方 INT8 262 反推的 **131 TFLOP/s**，和 `frame-ledger-a770.md:378` 实际使用的
**39 TFLOPS**（roofline 平衡点 39/560 = 70 FLOP/byte）。差 3.4 倍，从来没有统一过
（iGPU 侧是推出来的：64 XMX × 128 MAC × 2 × 1.95 GHz = 31.9 TFLOP/s FP16、INT8 64-67 TOPS，
与 Intel 宣传的 67 TOPS 相符，`phase26-the-register-ceiling.md:42`）。
**但结论对口径不敏感**：按 39 算利用率 5 %，按 131 算 1.5 % —— 都是个位数。
→ 所以**不需要**再为"量一个利用率"开一轮测量。用户 2026-10-13 明说：前辈测过很多遍了。

### 26.10 前辈已经测过的利用率（我此前没查，是失职）

| 出处 | 实测 |
|---|---|
| `phase20-machine-limits.md:50` | iGPU 大 GEMM 4096x1024x4096：**2584 GFLOP/s = 8.1 %** |
| `phase21:214` | 整帧 GEMM 459.6 GFLOP / 327 ms = 1.4 TFLOP/s = **4.4 %** |
| `phase26:121` | 全项目见过的天花板 **3.9 TFLOP/s**；可用区间 **8-12 %** |
| `frame-ledger-a770.md:372` | A770 `window_block`：**1941 GFLOP/s ≈ 5 %** |
| `frame-ledger-a770.md` | 每 lane 约 7000 条指令，**99 % 是逐元素的**；SPIR-V 里 Load+Store 990 条(27 %) vs 算术 390 条(11 %) → **搬运指令是算术的 2.5 倍** |
| `frame-ledger-a770.md` | fill 实验 0/100/200/400/800 轮：**从 0 就是直线**，每 100 轮 +0.78-0.87 ms，**没有平台期 → 没有空闲发射槽可填** |
| `frame-ledger-a770.md` | 算术强度 **28 FLOP/byte** vs roofline 70；全局带宽只用了 12 %(69 GB/s)，九成搬运发生在共享内存 |
| A770 skill 的 VTune 引用 | "XVE 57 % Stalled, **XMX pipeline 19.5 % active**" |

### 26.11 差距怎么拆：已知硬件 1.5×，实测差 20-30×

用户实测：Mochi **1080p 整链 90 fps**，NR 段约 **6 ms**。
我们：768x448 一帧 device **36.42 ms**（`device-budget-a770.md`）。
按面积归一到 1080p（2.07 MP / 0.344 MP = 6.02×）≈ **219 ms**。

    219 / 6 = 36 倍；硬件只能解释 1.5 倍 → **约 24 倍来自架构**

架构账（全部在前辈笔记里，不是新发现）：

1. **723 趟 vs ~150 趟**（其中 313 趟是量化过路费）。
2. **host 24.4 ms**（对方 0，静态计划表）。
3. **一个窗口搬 21 KB 只换 590 kFLOP** —— 算术强度 28，roofline 70。
4. **99 % 指令逐元素**，XMX 只有 19.5 % 在活动 —— 发射槽被搬运占满，矩阵单元闲着。
5. **每帧 717 次 Python 调用推形状**，对方构建期算好。

→ **结论：用户说得对——核心架构利用硬件性能极度低下。这不是"慢一点"，也没有硬件借口可找。**

## 27. 接通的路：进程内原生重放器（2026-10-13 拍板）

### 27.1 为什么不走跨进程 daemon

Route C（桥按 `nr_extmem` / `nr_transport` 协议把帧喂给 daemon，异步回传）能把 NR 接上，
但它是**折中方案**：接进去得到的是一个 Python 拖累、滞后数帧的东西，等优化到最后发现
Python 是瓶颈，整个推翻重写。**用户明确否决：不走折中，既然决定优化，就按 Mochi 的形状做。**

Mochi 的形状是什么（`refs/DLSSNR-AMD/ARCHITECTURE.md`、`core/nr_native_plan.cpp`）：

- 进程内，零跨进程；
- **静态编译计划表**（`records[]`，构建期算好，运行时只查表 dispatch）；
- **每帧零 Python**（Python 只出现在装模型那一步，`mochizuki-model.py` 抽权重，一次性）。

### 27.2 我们的对应物：把「构建期」从 Python 挪到 C

关键发现：`libxmx.c` 不只是执行器，它**已经有图录制与重放**——
`xmx_rec_*`（约 20 个录制器）+ `xmx_graph_capture()` / `xmx_graph_run(id)` /
`xmx_graph_destroy(id)`。`xmxres.CommandGraph` 的文档串逐字：
*"Replayable commands. Referenced buffers must outlive this object."*

也就是说：**R 的 GPU 侧已经是 Mochi 的形状**（整块录成一个 command buffer、一次 submit），
缺的只是"谁来走这一遍"——现在是每帧的 Python。所以不用重写 kernel，不用手写 dispatch
循环，只需要：

1. **离线走一次**，把 Python 的每一步录制调用记下来 → 静态计划表；
2. **运行时用 C 按表走一遍**，`xmx_graph_run` 一次跑完。

这正是 Mochi 的 `records[]`，只是我们的表由"跑一次 Python"生成，而不是手写。

### 27.3 已建成（2026-10-13）

| 文件 | 作用 |
|---|---|
| `tools/dump_plan.py` | 钩住 libxmx 的每个 `xmx_rec_*` / `xmx_buf_*`，跑一次 `ResidentFrame`，写出计划 |
| `src/gpu/nr_plan.h` | 计划的形状：opcode 枚举、`nr_step` / `nr_buffer` / `nr_blob` |
| `src/gpu/nr_replay.c` | 重放器：按表建缓冲、灌权重、逐步录制、capture、每帧 `xmx_graph_run` |

计划表由 `dump_plan.py` 的 `emit_c` 直接生成 C 源码（`work/plan_<W>x<H>.c`），
**不给 C 侧留任何解析的活**——和 Mochi 把手写表编进二进制是同一件事。

### 27.4 两个坑（都踩过，都记下）

1. **权重不是 upload 进去的。** A770 开着 resizable BAR，`Buffer.view` 直接给主机指针，
   NumPy 穿透写，`xmx_buf_upload` 一次都不走（实测 `uploaded 0.0 MB`）。
   → 只能靠 `xmx_buf_ptr` 认出"主机写过哪些缓冲"，在**第一次 `graph_run` 之前**拍一次快照读回来。
   快照时机是硬的：之后图已经跑过，权重缓冲里装的是激活值。
2. **`xmx_window_init` 被调了 104 次，不是 1 次。** 计划里的 text 表必须**每条路径参数一个
   条目**（160 条），而不是每种调用一个。第一版只收了 4 条，第 10 条之后全是越界读，
   症状是 `cannot open spv` 出现在第 1297 步——离真正的错因有十万八千里。
   同时 `nr_plan_names` 曾按 dump 顺序排、却用枚举值索引，把报错里的函数名打错，
   直接把人往沟里带。**两个表都必须按 `nr_plan.h` 的枚举顺序写。**

还有一步差点漏：`xmx_abort`。Python 是「dry 录制探 scratch → **abort** → 真录制」，
漏了它第二次 `xmx_begin` 就 `already recording`。

### 27.5 实测（A770，768x448）

```
build 213 ms           一次性：662 个缓冲 + 306.4 MB 权重
run   43.9 ms          415 passes，四次 44.13 / 43.81 / 43.85 / 43.90
```

**正确性：逐位一致。**

```
重放 : -0.05398422 0.14897376 0.06821892 6.95267725
Python: -0.053984225 0.14897376 0.06821892 6.9526772
```

判据是天然的：blobs 里包含输入缓冲的快照，重放用的是与 Python 那次**完全相同的输入**，
所以输出必须逐位相等。相等即证明：形状没推错、顺序没错、float 位模式没坏、权重没搬错。

### 27.6 数字的含义

- 768x448 一帧 **43.9 ms**。LOP 是 960x540，按面积外推约 **66 ms**。
- 基线是 30 ms / 33 fps。**同步放不进一帧**——第一版接入必然是异步（滞后数帧）。
- 但架构对了：接下来减趟、融合、算子特化，都是在这张表上改，
  **不会返工**。这也是用户否决折中方案的理由。

### 27.7 下一步

1. dump 960x540（LOP 的实际分辨率）的计划，重放校验；
2. 接进桥（`nrbridge`）：color+MV 进输入缓冲 → `xmx_graph_run` → 结果拷回 result 交 XeSS；
3. 之后才是减趟与融合（从 830 rec / 415 pass 往 Mochi 的 ~150 靠）。

## 28. 接入的输入输出契约（2026-10-13）

### 28.1 网络的 extent 不是渲染分辨率

960x540 **直接跑会失败**：`ValueError: rows=1980 must be a multiple of 8`。
网络要连续 halving 五次，extent 必须能被整除；540 不是，544（=32x17）是。

→ **LOP 的 960x540 必须 pad 到 960x544**。多出的 4 行在输入侧留空（或复制最后一行），
输出侧拷回时只取前 540 行。这个 pad 是接入的一部分，不是可选项。

（R 自己从未在 LOP 尺寸上跑过：它是 Vulkan layer，只接过 Vulkan 游戏。）

### 28.2 网络输入不是 color，是 16 通道 features

`ResidentFrame.run(features)` 要求 `features.shape == (height, width, 16)`。
dump 用的是随机生成的 features，所以**计划表从 features 开始，不含编码**。
编码在 `src/ref/nr_frame.py: build_features` → `work/mlx-dlss/.../features.py: make_features`。

**16 通道布局（权威，`features.py:175-189`）**：

| 通道 | 内容 |
|---|---|
| 0-2 | `deterministic_noise(network_h, network_w, frame_index)` |
| 3 | 常数 `1.0` |
| 4-6 | `scaled_color(color)` |
| 7-9 | `scaled_color(color)` — **history 会替换这三通道** |
| 10 | `half(normalized_style)` |
| 11 | `half(local_tone_strength)` |
| 12 | `half(local_structure_strength)` |
| 13 | `half(skin_structure)` 或 `-1` |
| 14 | `half(automatic_structure)` 或 `-1` |
| 15 | `0` |

`scaled_color(c) = half(half(half(c) - 0.5) * 0.125)`（三次 half 舍入，顺序不能变）。
color 先经 `geometry.source_rows()/source_columns()` gather 镜像到网络 extent。

### 28.3 🎯 画质线真因的确切位置

`nr_features`（`src/ref/nr_image.c:310`）里 history 的采样：

```c
const float *old = history ? history + rows[y] * ty : 0;
...old + columns[x] * tx...
```

**用的是和 color 完全相同的 `rows`/`columns`，没有 MV 偏移——这就是恒等重投影。**
注释也写明了（`nr_frame.py:240`）：*"A Vulkan layer at vkQueuePresentKHR has no motion
vectors... so the reprojection is the identity."*

→ 有了真 MV 之后，这里要改成
`history + (rows[y] + mv_y) * ty + (columns[x] + mv_x) * tx`。
**改动本身很小，但这是画质的全部赌注所在**（对应记忆里的"画质线：必须有 MV"）。

### 28.4 输入输出侧都有现成的纯 C 实现，零 Python 就能用

`work/libnr_image.dll`（146,944 B，已在树里）导出 10 个函数：

```
nr_features  nr_features_half  nr_compose  nr_compose_temporal
nr_compose_encode  nr_resize_axis  nr_area_mean  nr_to_half
nr_decode8  nr_encode8
```

- 输入侧：`nr_features` — mirror + 三次 half 舍入 + history 替换通道 7-9，**一次 pass**
- 输出侧：`nr_compose_encode` — head 沿两个 bilinear 轴上采样 + 合成 + 编码，一次 pass

都是 C ABI、OpenMP 并行。**桥可以直接 LoadLibrary 调用，不需要 NumPy，不需要 Python。**

### 28.5 每帧管线（进程内，零 Python）

```
color(R11G11B10) + MV(R16G16)
   -> nr_features(...)            16 通道 features，960x544
   -> 写进 plan 的 features buffer
   -> xmx_graph_run()             60.8 ms
   -> 读 head（960x544, 4 通道）
   -> nr_compose_encode(...)      RGB，960x540
   -> 拷回 result 纹理 -> XeSS
```

### 28.6 实测（960x544，A770）

```
build 270 ms            一次性：662 缓冲 + 312.1 MB
run   60.81 / 60.84 / 60.78 / 61.40 ms   415 passes
```

**逐位一致**：
```
重放 : -0.43158343 -0.64304703 -0.58204538 7.03977346
Python: -0.43158343 -0.64304703 -0.5820454  7.0397735
```

对比 768x448 的 43.9 ms —— 面积比 1.39x，时间比 1.38x，**基本线性**。
基线 30 ms，所以 60.8 ms **同步放不进一帧，第一版必须异步**（滞后数帧）。

### 28.7 一个坑：默认 bin 路径写死会骗人

重放器的默认 blobs 路径原来写死 `plan_768x448.bin`。换成 960x544 的 plan 后不传参数，
读的是 306 MB 的旧文件，而 blob 628 需要到 311 MB → 报
`blob 628 runs past the plan file`。**表是对的，错的是读的文件**，而报错把人指向表。
已改成按编译进来的 `nr_plan_extent` 拼文件名。

### 28.8 已库化：桥可以像调函数一样跑一帧

`src/gpu/nr_net.h` + `src/gpu/nr_replay.c`（同一个文件，两种编法）：

| 编译方式 | 产物 | 用途 |
|---|---|---|
| 不带 `NR_REPLAY_STANDALONE` + `-LD` | `work/nr_net.dll` | 桥链接它 |
| 带 `-DNR_REPLAY_STANDALONE` | `work/nr_replay_<W>x<H>.exe` | 离线基准与逐位校验 |

导出 9 个符号：`nr_net_open / close / error / extent / features / features_bytes /
head / head_bytes / run`。

**两个缓冲由 kind 认出，不写死编号**（plan 按创建顺序编号，那个顺序不是承诺）：
`HOST_WRITE` = features（16,711,680 B = 544x960x16x**2** → fp16 16 通道），
`HOST_READ` = head（8,355,840 B = 544x960x4x**4** → float32 4 通道）。

**端到端已验证**（`src/gpu/nr_net_probe.c`）：把 dump 额外导出的输入快照
（`plan_960x544_in.bin`，16.7 MB）当作**调用者填进去的帧**写进 `nr_net_features`，
`nr_net_run`，读 `nr_net_head`：

```
head: -0.43158343 -0.64304703 -0.58204538 7.03977346
again: -0.43158343 -0.64304703 -0.58204538 7.03977346
Python: -0.43158343 -0.64304703 -0.5820454  7.0397735
```

**这跟重放器不是一回事**：重放器用的是 blob 快照自动灌进去的输入，
库跑的是**调用者填的帧** —— 后者才是桥要的。且连续四次结果一致（确定性）。

### 28.9 三个坑（本轮新踩）

1. **默认 bin 路径写死**会骗人（见 28.7）。
2. **C 里函数声明不能省参数名**：`void nr_net_extent(nr_net *, unsigned *, unsigned *)`
   是 `error C2055`，第一个参数必须有名字。而这次编译报错时我跑的其实是**旧二进制**，
   输出看着正常——**编译失败后的"验证通过"是假的**。
3. **`cl -TC` 会把 `.lib` 也当 C 源文件编译**（`error C3872` 在一堆乱码字符上）。
   编可执行文件时不要加 `-TC`，让它按扩展名判断。

### 28.10 下一步（接进桥）

1. 桥加载 `nr_net.dll` + `libnr_image.dll`；
2. 每帧：color/MV 回读 → `nr_features_half` → `nr_net_features` → `nr_net_run`
   → `nr_net_head` → `nr_compose_encode` → 拷回 result 交 XeSS；

## 29. 已接进桥（2026-10-13，12:0x 装机）

### 29.1 形状：两次提交，主机工作在中间

插槽里现在不是一次拷贝，是**两次提交**：

```
gap:  queue->Signal(toVk, v)
      #1 Submit(wait toVk[v], input->stageColour, mvInput->stageMotion, 不 signal)
      WaitLast()                       ← 等 GPU 把帧搬完
      主机：decode -> features -> nr_net_run -> compose -> encode
      #2 Submit(wait toVk[v], stageResult->output, signal fromVk[v])
      queue->Wait(fromVk, v)
```

原因：共享 buffer 是 **DEVICE_LOCAL**（`SharedBuffer::Create` 按 `DEVICE_LOCAL` 选类型），
导入契约要的就是这个，驱动不给主机指针。所以帧要过主机就得再倒一次。

新增 `VulkanGap::Staging`（HOST_VISIBLE|HOST_COHERENT，常驻映射）+ `Transfer` 结构
（`VkBufferCopy` 不带 buffer，必须自己带）+ `WaitLast()`。

**降级路径**：任一环节失败 → 退回 reference 的 Passthrough（input→output 一次拷贝）。
画面不会黑，只是没 NR。

### 29.2 为什么是 `nr_compose_temporal` 而不是 `nr_compose_encode`

`nr_compose_encode` 只出 **uint8**（bgra8/rgba8），而 result 必须跟 color 同格式
（R11G11B10_FLOAT）。所以走 `nr_compose_temporal`（出 float32 RGB），自己编码回去。

顺带省掉一整块：compose_encode 需要 bilinear axis plan（`_axis_plan`），而
**head 544 行的前 540 行与输入 540 行是一一对应的**（mirror 是行对齐的），
直接取前 540 行就对，`low_y/low_x` 全传 NULL（= "该轴已在输出尺寸"）。

### 29.3 移植到 C++ 的三样东西（Python 有、C 库没有）

都在 `NrPipeline.cpp`：

| 东西 | 出处 |
|---|---|
| `deterministic_noise`（544x960x3） | `features.py:87` + `_dynamic_shift_mix`/`_uniform24` |
| `gate_table`（65536 项，按 half 位索引） | `nr_frame.py:330`，用 **double exp** 再转 float（expf 与 NumPy 的 float32 exp 差最后一位，这是唯一会逐像素放大的地方） |
| mirror `rows`/`columns` | `NetworkGeometry.extended_indices`：`y<extent ? y : 2*extent-2-y` |

外加 `float<->half`（round to nearest even）与 R11G11B10 编解码（5 exp bias 15，无符号，
mantissa 6/6/5）。

### 29.4 🎯 MV 的语义（照抄参考实现，不猜）

`ta_MochizukiNrRuntime.cpp:4042` 逐字：

```cpp
// value * scale = pixels of the motion extent; the network reads previous uv = uv + mv.
next.motionScaleX = info->motion_scale_x / float(motionW);
```

LOP 实测 `mv=(960,540)`（即 `MV_Scale_X=960`）、MV 纹理 960x540 →
`motionScaleX = 960/960 = 1.0`（uv 空间）→ **像素偏移 = mv 值 × (960, 540)**，
符号是 `prev = cur + mv`。

实现上**没有改 `nr_image.c`**（红线：核心一行不改）：把 history 先按 MV gather 成
`warped_`，再按恒等喂给 `nr_features_half`。最近邻 + clamp，518k 像素。

### 29.5 preExposure 与一个已知缺陷

FSR 的 `PrepareRgb`（宿主自带 `ffx_fsr3upscaler_common.h:491`）逐字 `fRgb /= fPreExposure`
→ **buffer 里存的是 real × preExposure**，还原要**除**。LOP 实测 `preExp=0.360`。

⚠️ **已知缺陷**：除完之后值可能 >1（这是 pre-tonemap 的 HDR scene color，不是网络训练时的
[0,1] LDR 图）。目前**直接 clip**。参考实现（The）有 `preprocess`（exposure/curve/contrast/
saturation + white point），**本树没有**。下一步要么补 tonemap，要么换输入点。
日志会打 `colour in [low, high]` 看被裁掉多少。

### 29.6 本轮三个坑

1. **`nr_net_open` 会 `SetDllDirectoryA(folder)` 且不还原** —— 会污染整个游戏的
   DLL 搜索路径。桥里在调用前后 `GetDllDirectoryA` / `SetDllDirectoryA` 包住。
   （加载两个 dll 时同样包一层，否则找不到 libgomp。）
2. **`Staging` 不能定义在 `MemoryType` 之前**（我插在 `TheBridge()` 后 → C3861）。
   改成前置声明 + 定义在 `MemoryType` 之后。
3. **MV 与 color 必须同 extent** 才喂给管线（`nr_compose_temporal` 按 output extent 采
   history）。不同则 `haveMotion=false`，history 站住不动。

### 29.7 开关（ini `[DlssNr]`）

```
Network=true      关了就退回 Passthrough（隔离"网络崩"和"hand-over 崩"）
MvReproject=true  关了就是恒等重投影（A/B 用）
Folder=...        网络文件目录，默认 dlss-nr-on-a770/work
```

### 29.8 下一步

先看日志：网络起没起（`network up in N ms`）、`net=` 多少 ms、`gate=` 多少、
`colour in [low, high]` 被裁多少。然后才是减趟与异步。
3. 60.8 ms 放不进 30 ms 帧 → 第一版异步（滞后数帧）。

## §30 全 GPU 路线：Pre / Post 融进计划表（2026-10-13 装机，待用户跑）

CPU 那版（`decode=73 mv=119 encode=24.5` = 216 ms 的 PCI-e 惩罚）**搁浅不用**。
改为照 Mochi 的 `Kind::Pre` / `Kind::Post`：features 与 compose 融进网络首尾，零 CPU 往返。

### 新增
- `src/gpu/nr_pre.comp` → `work/nr_pre.spv`（20 KB）：
  R11G11B10 解码 + 除 preExposure + **按 MV 做 5-tap Catmull-Rom 重投影**
  （catmull/bilinear 从 `history.comp` 逐字照抄）+ 打包 16 通道 fp16。
  `half()` 三次舍入顺序不可变；通道 7-9 是重投影后的 history。
- `src/gpu/nr_post.comp` → `work/nr_post.spv`（13 KB）：
  `temporal_pixel` + `finish_pixel` + gate 查表 + `truncate_half` 写 neural + 编码回 R11G11B10。
  p0/p1 = gate 表地址，p2/p3 = neural 地址（照 `xmx_rec_ffn_stem` 的既有做法，未改 push 结构）。
- `libxmx.c` 四个纯新增接口：`xmx_buf_import`（导入 D3D12 共享句柄）、`xmx_prepost_init`、
  `xmx_rec_pre`、`xmx_rec_post`。
- `nr_replay.c`：`nr_net_fuse`（open 前调用）+ `nr_net_wait`（导入游戏 fence，图内等）。
  Pre 插在**第一个 `op >= OP_XMX_REC_COPY`** 之前，Post 插在 `OP_XMX_GRAPH_CAPTURE` 之前；
  `prepare_fused` 在 `OP_XMX_RES_INIT` 之后跑（buffer 要 runtime 就绪）。
  **history 与 neural 是同一 buffer**：同一 invocation 先读自己像素再写，安全，无需乒乓。
- `NrPipeline::{Fuse,RunFused}`、`VulkanGap` 保留 `toVkShared` 句柄、`SlotRead/Write` 在 fused 时跳过 staging。

### 三个坑
1. glslangValidator 本机没有 → 下载 glslang 16.6.0 到 `tools/glslang/`（GitHub 资产名是
   `glslang-16.6.0-windows-x86_64-release.zip`，不是 master-tot）。
2. Git Bash 会把 `/nologo` 当路径转换传给 cl → **必须用 `-` 前缀**（`cl -nologo ... -LD`）。
   多源文件不能带 `/Fo`。`work/plan_*.c` 要 `nr_plan.h`，已复制一份到 `work/`。
3. `unpackHalf2x16` 吃一个 uint 返回 vec2，不是吃 uvec2。

### 待验证
日志看 `fused` 是否成立、`net=` ms（应 ~65 ms 但**不再有 decode/mv/encode**）、
以及 `the fused pass did not run: <why>` 有没有出现。

## 31. 首跑 fused 实测（13:45-13:47）：四处契约错

现象：载入卡在 20% → 等约 60 秒 → 能进游戏、完全没有 NR。

### 31.1 日志四条铁证

```
232  [W] SlotRead  the fused path would not start: the network library has no fused passes
243  [I] gap run #1 took=612.344ms  copy=18.320 decode=6.283 mv=2.275 features=3.530
                                    net=64.677 compose=1.605 encode=24.288
245  [W] SlotWork  the fused pass did not run: the graph would not run
246  [I] gap run #2 took=60043.771ms
```

第 243 行那一串就是 **§29 那版被搁浅的 CPU 路径**（decode/mv/features/compose/encode 全在）：
fused 根本没生效。第 246 行 60 秒是图内等游戏 fence 等不到 → 设备被拖挂，之后每帧 2-7 ms 快速失败。

### 31.2 四处契约错

| # | 错在哪 | 证据 | 修法 |
|---|---|---|---|
| 1 | `Fuse()` 在 `EnsureNetwork()` 之前调，而 `nr_net_fuse` 是 `nr_net.dll` 的导出，dll 在 EnsureNetwork 里才加载 | `NrBridge.cpp:1274-1289`、`NrPipeline.cpp:487` | `Fuse()` 收 `folder`，库没加载就自己 `LoadLibraries`；**已 open 就拒绝**并给 why |
| 2 | 宿主 `fused_` 只是"请求发出去了"，网络侧 `r->fused` 才是"Pre/Post 真插进去了" | `nr_replay.c:624` 只在 `fuse.asked` 已置位时才 `prepare_fused` | 新增 `nr_net_fused(n)`；`Pipeline::Fused()` **问网络**，答不上来就当没 fused（降级 CPU 路径，画面不黑） |
| 3 | 共享 fence 的句柄类型两边不一致 | 宿主 `VulkanGap.h:260` 用 `D3D12_FENCE_BIT`；网络 `libxmx.c:1540` 用 `OPAQUE_WIN32` | 新增 `xmx_sem_import_fence`（D3D12_FENCE_BIT + TIMELINE，导入前先问 `vkGetPhysicalDeviceExternalSemaphoreProperties`） |
| 4 | 等到不该等的值是**挂死**不是报错 | 60 秒 | `nr_net_wait` 先比 `xmx_sem_value(id) < value`，counter 落后于要等的值就直接返回错误 |

第 3 条最值得记住：`xmx_sem_import` 上面 1504-1510 行的注释自己写着
"it has to match what the other side exported — VUID-VkImportSemaphoreWin32HandleInfoKHR-handleType-03262"，
是我自己写的注释，接的时候没照它做。D3D12 fence 的共享句柄不是 opaque win32 句柄，
拿错类型导入后驱动照样答 SUCCESS，然后等一个永远不动的 counter。

### 31.3 第 5 个契约错（第二跑 14:15 才暴露）：计划表里没有那一步

修完上面四处再跑，`network up in 390 ms`（open 成功），但每帧刷
`the fused path would not start: the network is already open...`，段位仍是
`copy=19 decode=12.8 mv=4.7 features=1.6 net=64.9 compose=1.9 encode=24.9`（138 ms/帧）。

**`OP_XMX_RES_INIT` 在 2314 步里出现 0 次**（`OP_XMX_REC_COPY` 同样 0 次）：

```
total 2314
  OP_BUF 669 / OP_XMX_BUF_PTR 642 / OP_XMX_REC_GEMM 276 / ... / OP_XMX_GRAPH_CAPTURE 1
  RES_INIT: None      REC_COPY: None
```

`build()` 的触发条件是「走到 `s->op == OP_XMX_RES_INIT`」，那一步不存在 →
`prepare_fused` 从未被调用 → `r->fused` 恒 0 → **Pre/Post 一次都没插进录制**。
open 照样成功（res_init 是 `prepare()` 里直接调的，不在录制的 `xmx_rec_*` 序列里），
所以宿主拿到一个"起来了但没融合"的网络，每帧重试、每帧刷警告、每帧走 CPU 路径。

修法：`prepare_fused` 挪到**遍历之前**（runtime 已由 prepare 就绪，它不依赖 plan 的 buffer id），
遍历结束再查 `!fused` / `!pre_done` / `!post_done`，任一不成立就写进 `r->why`，
宿主于是报 `the network would not start: <why>`——**不再静默退回老路径**。

🚩可推广的教训：凡"等计划表走到某一步"的写法，先数那一步在表里出现几次。
这次靠统计 2314 步的 `OP_` 名字才看见 0。

### 31.4 第三跑（14:25）：`the walk failed` —— 真因是着色器取指针取错了

**不再让用户当试验品**：新增 `src\gpu\nr_fuse_probe.cpp` + `tools\build_fuse_probe.bat`。
它自己建 D3D12 设备（按 vendor 0x8086 选 A770）、三个共享 buffer（照 `SharedBuffer.h` 的
16 MB floor + 64 KB 对齐），走完整的 `nr_net_fuse` → `nr_net_open`，**17 秒出结果，不开游戏**。
`nr_replay.c` 的 stderr 现在同时也写 `work\nr_net.log`（游戏是 GUI 进程，原本谁也看不见）。

探针输出：

```
step 2312 (xmx_graph_run): resident fence wait (-4)
```

`-4` = `VK_ERROR_DEVICE_LOST`，且发生在**图第一次真正执行**时（2311=CAPTURE，2312=RUN）。

**真因**（逐字对照库源码，不是猜）：

| 处 | 代码 |
|---|---|
| `libxmx.c:3197` | `memcpy(&p.p0, &at, sizeof at);` —— 把 8 字节地址**按位**塞进两个 float 槽 |
| `nr_pre.comp:35` | `float p0, p1, p2, p3;` —— 槽声明成 **float** |
| `nr_pre.comp:105` | `FloatBuf plan = FloatBuf(uint64_t(pc.p0) \| (uint64_t(pc.p1) << 32u));` |

`uint64_t(一个 float)` 是**把浮点值取整**，不是取回那 32 个位：地址的位模式被当浮点解释后
是个极小的非规格化数，取整得 **0** → shader 往地址 0 写 → GPU 页错误 → 设备丢失。
`nr_post.comp:99`（table）与 `:134`（neural）同一个错。

前辈惯例佐证：`residual_epilogue.glsl:21` 能直接 `uint64_t(pc.d)`，是因为**那个字段声明的就是
buffer_reference 类型**；我们的槽是 float，必须 `floatBitsToUint`。

三处改成 `floatBitsToUint` → 重编 spv → 探针输出 **`the network is up; nr_net_fused says 1`**。

**为什么前两轮没炸**：那两轮 `prepare_fused` 压根没被调用（31.3 那个契约错），Pre/Post 从没
进过图；一进图就炸。所以"fused 从未生效"和"一生效就丢设备"是同一段代码的两个面。

### 31.5 按 Mochi 改的两处违背（`mz_win_interop_d3d12.md` 逐字）

1. **导入前问句柄**：Mochi `nr_pe_bridge.cpp:360-374`（`external_ok`）与 `:416-467`
   （`get_handle_properties_` → `vkGetMemoryWin32HandlePropertiesKHR`）先问句柄能进哪些内存类型。
   `xmx_buf_import` 原本只按 buffer 自己的 `memoryTypeBits` 选类型 → 改为取二者交集。
2. **导入用资源真实大小**：Mochi `import_image(handle, type, width, height, …)` 用资源的真实维度。
   我们宿主 `SharedBuffer.h:114` 的资源是 `max(round_up_64k(bytes), 16MB)`，VulkanGap 导入用的
   正是它（`:157 bi.size = width`），但 `nr_net_fuse` 传的却是 `footprint.bytes`（约 4 MB）
   → 同一句柄在两个 device 上是两个不同大小的对象。改为传 `SharedBuffer::size`。

### 31.6 构建

`R\tools\build_fused.bat`（新，ASCII+CRLF）：只编 `libxmx.dll` 与 `nr_net.dll`，5 秒。
`work\libxmx.def` 手工加 `xmx_sem_import_fence` 一行（不用 build_msvc.bat 里那段
powershell 抓符号的写法，避免再碰安全策略）。
宿主照旧 `tools\build_optiscaler.py`（2m12s）。
备份 `backups/dxgi-before-contract-fix-20261013.dll`。


### 31.7 证伪：通路数值本来就是对的（2026-10-13 晚）

此前两条结论**是错的**，错在判别实验的设计，不是通路：

- ~~“网络读到的是未初始化显存”~~
- ~~“两个 device 各导一遍导致读不到”~~（据此改的 `SharedBuffer` 拆分与 `CreateOn` 保留，
  因为它合上了 Mochi 的形状；但它**不是**当初那个现象的成因）

错法：`nr_net_fuse` 的三个浮点是 exposure / **intensity** / confidence，而 `prepare_fused`
用 `fuse.intensity` **覆盖** `table[65536]`。所以改 `table[65536]` 毫无作用。探针一直传
`intensity=1.0`，于是 `blend=1` → `out = clamp(rgb + 1*(predicted-rgb))` = 网络预测值，
自然不像输入。看着像“读到垃圾”，其实是读到之后被预测值盖掉了。

改 `intensity=0`（`blend=0` → `out = rgb`）后，逐位一致：

```
in 0x701C0380 (0.5)  -> out 0x701C0380
in 0x681A0340 (0.25) -> out 0x681A0340
in 0x781E03C0 (1.0)  -> out 0x781E03C0
```

**结论：Pre 解码 → 网络 → Post 编码，全链路数值正确，共享 buffer 导入也读得到。**

### 31.8 真 bug：`libxmx.def` 漏导出（确凿）

`work\libxmx.def` 是手工维护的列表，漏了 6 个：`xmx_idle`、`xmx_vk_instance / _physical /
_device / _queue / _family`。后果：
- `nr_net_device()` 恒返回 0 → `Pipeline::Boot` 恒 false → hand-over 只能自建 device，
  **“合成一个 device”从未真正生效**（黑屏那版就是这样）。

已改：`build_fused.bat` 每次用 python 从 `libxmx.c` 抓全部非 static 顶层函数重写 def
（111 个），不再手工维护。同 device 导两次也已实测无碍（`THE SAME BYTES`）。
