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
