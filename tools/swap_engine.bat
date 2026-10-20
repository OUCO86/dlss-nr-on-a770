@echo off
rem swap_engine.bat -- step 5 (section 90/91/92): swap the game's engine dll from the
rem shipping Vulkan-coopmat libxmx.dll to my Level-Zero/SYCL engine, or revert.
rem The game loads work/libxmx.dll (NrFolder() defaults to this work/ dir, and the
rem bridge SetDllDirectoryA's it, so the SYCL runtime staged here resolves).
rem
rem SECTION 92 FINDING: this loader build discovers UR adapters ONLY from the EXE's own
rem directory (UR_ADAPTERS_SEARCH_PATH / FORCE_LOAD are ignored by it -- proven offline).
rem The game exe lives in the game folder, so the Level-Zero adapter must sit THERE for
rem SYCL to see the Arc as Level Zero; without it the game process enumerates only the
rem OpenCL Arc, and the fused kernels fault there (the 2026-10-20 GPUCrash). So swap also
rem deploys the adapter + its deps into the game dir, and revert removes exactly those.
rem   swap   : work/libxmx.dll <- work/libxmx_sycl.dll; + 7 adapter files to the game dir
rem   revert : work/libxmx.dll <- backup; - the 7 adapter files from the game dir
rem REVERSIBLE: the original engine is always kept; the game-dir files are new-only
rem (verified zero collisions against the pre-swap manifest, notes/game-dir-manifest-*.json).
setlocal EnableExtensions
set "W=E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work"
set "G=F:\Game\Lies of P\LiesofP\Binaries\Win64"
set "CMD=%~1"
set "ADAPTERS=ur_adapter_level_zero.dll ur_adapter_level_zero_v2.dll umf.dll libhwloc-15.dll libiomp5md.dll svml_dispmd.dll common_clang64.dll"

if /I "%CMD%"=="swap" goto swap
if /I "%CMD%"=="revert" goto revert
echo usage: swap_engine.bat [swap ^| revert]
echo   swap   -- game runs my Level-Zero engine (work/libxmx_sycl.dll) + adapter in game dir
echo   revert -- game runs the shipping coopmat engine (backup) + adapter removed
exit /b 1

:swap
if not exist "%W%\libxmx_sycl.dll" ( echo ERROR: work/libxmx_sycl.dll missing & exit /b 1 )
if not exist "%W%\libxmx.dll.bak-1020-coopmat" ( echo ERROR: backup missing, refusing & exit /b 1 )
copy /Y "%W%\libxmx_sycl.dll" "%W%\libxmx.dll" >nul
if errorlevel 1 ( echo ERROR: swap copy failed & exit /b 1 )
for %%f in (%ADAPTERS%) do copy /Y "%W%\..\..\..\oneapi\%%f" "%G%\%%f" >nul
echo SWAPPED: work/libxmx.dll is now the Level-Zero engine, adapter deployed to the game dir.
echo Backup kept at libxmx.dll.bak-1020-coopmat. Launch the game (double-click) and
echo toggle Neural Rendering in the OptiScaler panel (Insert) to A/B. If the picture
echo is wrong, run: swap_engine.bat revert
exit /b 0

:revert
if not exist "%W%\libxmx.dll.bak-1020-coopmat" ( echo ERROR: backup missing & exit /b 1 )
copy /Y "%W%\libxmx.dll.bak-1020-coopmat" "%W%\libxmx.dll" >nul
if errorlevel 1 ( echo ERROR: revert copy failed & exit /b 1 )
for %%f in (%ADAPTERS%) do del /Q "%G%\%%f" 2>nul
echo REVERTED: work/libxmx.dll is the shipping coopmat engine; adapter removed from game dir.
exit /b 0
