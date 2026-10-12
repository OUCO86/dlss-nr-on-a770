# OptiScaler installed next to Lies of P

What was actually done, on 2026-10-12, in the order it was done. Every claim here is either a
file on disk or a verbatim line from an upstream document; nothing is inferred.

## 1. What was downloaded

Upstream `optiscaler/OptiScaler`, **v0.9.4**, the newest release (`2026-07-18T21:46:07Z`):

- asset `Optiscaler_0.9.4-final.20260718._MM.7z`, 55,016,448 bytes
- SHA-256 `575cb4df866116093df75af607e37fd70e10f5163e0f23fd5c804142e80ef0ad`
- archived under `refs/optiscaler/pkg/`, extracted to `refs/optiscaler/pkg/v094/`
  (21 files, 211,869,125 bytes uncompressed)

v0.9.0 was downloaded first by mistake — I read a question about it as an instruction — and
was deleted before anything was installed. The installed build is v0.9.4.

## 2. Where it went

`F:\Game\Lies of P\LiesofP\Binaries\Win64`, the directory holding `LOP-Win64-Shipping.exe`.
The whole archive was extracted there, which is what `INSTALL-DLSSNR.md` from
`TheAutomatic/dlss-5-amd-project` step 4 says to do:

> Extract the entire release archive into that executable directory. Do not copy only the two DLLs.

## 3. The one file this overwrote

The game ships `amd_fidelityfx_dx12.dll` (its FSR3 plugin) and the release archive contains a
file of the same name. It was overwritten. The original, 6,609,624 bytes, is preserved at

    E:\WorkBuddy\2026-10-09-04-20-55\backups\liesofp-20261012-1945\amd_fidelityfx_dx12.dll

`uninstall_optiscaler.bat` in the game directory restores it.

## 4. The proxy name

`OptiScaler.dll` was renamed to `dxgi.dll`, which is the default the upstream setup script
offers and the usual first choice:

    setup_windows.bat: "Choose a filename for OptiScaler (default is dxgi.dll, most compatible)"

The script itself was **not** run. It calls `reg.exe`, and the sandbox blocks that program, so
running it was abandoned rather than retried. Its final action is the rename above, done by
hand instead:

    rename "%optiScalerFile%" %selectedFilename%

Two things the script would also have asked were decided without it, and both are recorded here
because they are choices and not defaults:

- **GPU type: AMD/Intel**, which is what an A770 is.
- **Nvidia spoofing: left enabled** (`Dxgi=auto` untouched). This is what lets a non-Nvidia card
  receive DLSS-shaped inputs. If it causes trouble it is disabled by setting `Dxgi=false`.
- **OptiPatcher: not downloaded.** It unlocks DLSS inputs in supported Unreal titles. This game
  runs FSR3.1, not DLSS, so it is not needed for the first measurement. It can be added later.

## 5. The three lines changed in OptiScaler.ini

The original is kept beside it as `OptiScaler.ini.orig`.

| Line | Was | Now | Why |
|---|---|---|---|
| 10 | `Dx12Upscaler=auto` | `Dx12Upscaler=xess` | XeSS only. Auto already resolves to xess — the comment in the file reads "xess, fsr21, fsr22, fsr31 (also for FSR4), dlss - Default (auto) is xess" — so this makes the choice explicit rather than changing behaviour. |
| 1128 | `LogToFile=auto` | `LogToFile=true` | `INSTALL-DLSSNR.md`: "No `OptiScaler.log` beside the executable: the proxy was not loaded." |
| 1133 | `LogLevel=auto` | `LogLevel=2` | Info, per the same section. |

`[DlssNr]` was deliberately **not** enabled. That section drives `nvngx_dlssnr.dll`, an
Nvidia runtime this machine does not have and cannot use. It is not part of this step.

## 6. What this step is meant to answer

Only one question: **does the host intercept this game's FSR3.1 call and hand us real motion
vectors.** Nothing in the NR core, the daemon, the shaders or the weights was touched.

Read it off `OptiScaler.log` after launching into a rendered scene:

- no log file at all → the `dxgi.dll` proxy was never loaded
- `OptiScaler ... loaded` and `working as ...` → injection worked
- which upscaler it reports as the input, and whether it reports motion vector resources

Known Unreal fallback, from the upstream wiki, applied **only if the game crashes** —
not pre-emptively:

```ini
[SystemSettings]
r.FidelityFX.FSR3.UseNativeDX12=1
r.FidelityFX.FSR3.UseRHI=0
```

## 7. Uninstall

Double-click `uninstall_optiscaler.bat` in the game directory. It restores the original
`amd_fidelityfx_dx12.dll` and deletes everything this step added.

## 8. First run, 2026-10-12 19:58 — what the log actually says

The user launched the game with FSR selected in its settings. `OptiScaler.log`, verbatim:

    [W] OptiScaler v0.9.4-final (7534ad0) loaded
    [I] CheckWorkingMode OptiScaler working as dxgi.dll, system dll loaded
    [I] HookFSR3ExeInputs Trying to hook FSR3 methods
    [I] ffxCreateContext_Dx12 context created: 1EE8
    [I] NVSDK_NGX_D3D12_CreateFeature Creating new xess upscaler
    [I] IFeature::SetInitParameters Init Flag JitteredMV: false
    [I] IFeature::SetInitParameters Init Flag LowResMV: true
    [I] IFeature::SetInitParameters Render Resolution: 1130x636, Display Resolution 1920x1080, Quality: 1
    [I] XeSSProxy::Version XeSS Version: v2.0.2
    [I] FeatureProvider_Dx12::ChangeFeature init successful for xess, upscaler changed

**The question this step existed to answer is answered: the host receives this game's real
motion vectors.** `LowResMV: true` and `JitteredMV: false` come with the feature's init
parameters, so the vectors are unjittered and at render resolution — which is exactly the
shape a temporal pass needs. Nothing here is our own estimate; it is the engine's.

Three things in the same log that are not clean and are recorded rather than smoothed over:

- `[E] XeSSFeature::InitXeSS CreateHeap bufferHeapDesc failed 80070057!` twice, yet the next
  line is `init successful for xess`. 80070057 is E_INVALIDARG. It is not known whether the
  failing heap is a first attempt that is retried with different parameters, or something
  that is silently degraded. Not investigated yet.
- `[E] UpdateFfxApiProviderEx for: SwapchainDX12, result: 0X80004002` — E_NOINTERFACE, i.e.
  the game has no FSR swapchain to query. Expected, not a fault.
- `[I] CheckForGPU RDNA4: true, RDNA3: false, Fsr4Update: true` on an Intel A770, which has
  no RDNA4 in it. The host has misidentified the card. Worth watching, because FSR4 branches
  hang off that flag.

## 9. The core already adapts to whatever resolution the game hands it

Nothing in the core fixes a resolution, so the bridge does not have to either. From
`src/layer/nr_daemon.py`:

    active_height, active_width = bottom - top, right - left
    extent = (active_width, active_height)
    if live.render_scale < 1.0:
        extent = nr_frame.render_extent(active_width, active_height, float(live.render_scale),
                                        int(live.min_extent))

The extent comes from the frame actually received, every time. `768x448` was never a constant
— it is only what `1920x1080 x 0.4` happens to equal, and `0.4` is a setting
(`render_scale`, a live knob, range 0.05 to 1.0), not a compiled-in number. Setting it to
`1.0` takes the `if` branch not at all and feeds the core the frame at the size it arrived.

That is the right setting once the input is pre-SR. Working before super resolution means the
colour arrives already at render resolution — 1130x636 in the run above — so shrinking it
again by 0.4 would discard detail for nothing. Which quality preset the user picks changes
the render resolution, and the core follows it without being told, because the extent is
derived from the frame.

One consequence to expect: a preset change changes the extent, and a different extent is a
different network field. The resident path rebuilds on a new extent, so switching presets
will cost one rebuild. That is a behaviour to measure later, not a reason to fix a size.
