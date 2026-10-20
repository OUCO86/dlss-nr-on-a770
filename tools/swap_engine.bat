@echo off
rem swap_engine.bat -- step 5 (section 90/91): swap the game's engine dll from the
rem shipping Vulkan-coopmat libxmx.dll to my Level-Zero/SYCL engine, or revert.
rem The game loads work/libxmx.dll (NrFolder() defaults to this work/ dir, and the
rem bridge SetDllDirectoryA's it, so the SYCL runtime staged here resolves).
rem   swap   : work/libxmx.dll  <- work/libxmx_sycl.dll   (backup kept)
rem   revert : work/libxmx.dll  <- work/libxmx.dll.bak-1020-coopmat
rem REVERSIBLE: the original is always kept. Run with the game CLOSED.
setlocal EnableExtensions
set "W=E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work"
set "CMD=%~1"

if /I "%CMD%"=="swap" goto swap
if /I "%CMD%"=="revert" goto revert
echo usage: swap_engine.bat [swap ^| revert]
echo   swap   -- game runs my Level-Zero engine (work/libxmx_sycl.dll)
echo   revert -- game runs the shipping coopmat engine (backup)
exit /b 1

:swap
if not exist "%W%\libxmx_sycl.dll" ( echo ERROR: work/libxmx_sycl.dll missing & exit /b 1 )
if not exist "%W%\libxmx.dll.bak-1020-coopmat" ( echo ERROR: backup missing, refusing & exit /b 1 )
copy /Y "%W%\libxmx_sycl.dll" "%W%\libxmx.dll" >nul
if errorlevel 1 ( echo ERROR: swap copy failed & exit /b 1 )
echo SWAPPED: work/libxmx.dll is now the Level-Zero engine.
echo Backup kept at libxmx.dll.bak-1020-coopmat. Launch the game (double-click) and
echo toggle Neural Rendering in the OptiScaler panel (Insert) to A/B. If the picture
echo is wrong, run: swap_engine.bat revert
exit /b 0

:revert
if not exist "%W%\libxmx.dll.bak-1020-coopmat" ( echo ERROR: backup missing & exit /b 1 )
copy /Y "%W%\libxmx.dll.bak-1020-coopmat" "%W%\libxmx.dll" >nul
if errorlevel 1 ( echo ERROR: revert copy failed & exit /b 1 )
echo REVERTED: work/libxmx.dll is the shipping coopmat engine again.
exit /b 0
