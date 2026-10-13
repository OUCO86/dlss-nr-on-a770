@echo off
rem build_fuse_probe.bat -- the offline probe: the fused open, without a game.
rem Same cl environment as tools\build_fused.bat.
setlocal EnableExtensions
set "VSROOT=E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community"
set "ROOT=E:\WorkBuddy\2026-10-09-04-20-55"
set "REPO=%ROOT%\src\dlss-nr-on-a770"
set "WORK=%REPO%\work"
set "GPU=%REPO%\src\gpu"
set "VCVER=14.51.36231"
set "SDKVER=10.0.26100.0"
set "VCTOOLS=%VSROOT%\VC\Tools\MSVC\%VCVER%"
set "SDKDIR=E:\Windows Kits\10"
set "PATH=%VCTOOLS%\bin\Hostx64\x64;%PATH%"
set "INCLUDE=%VCTOOLS%\include;%SDKDIR%\Include\%SDKVER%\ucrt;%SDKDIR%\Include\%SDKVER%\um;%SDKDIR%\Include\%SDKVER%\shared;%SDKDIR%\Include\%SDKVER%\winrt"
set "LIB=%VCTOOLS%\lib\x64;%SDKDIR%\Lib\%SDKVER%\ucrt\x64;%SDKDIR%\Lib\%SDKVER%\um\x64"

cl -nologo -O2 -EHsc -D_WIN32 -Fe:"%WORK%\nr_import_probe.exe" "%GPU%\nr_import_probe.cpp" d3d12.lib dxgi.lib
if errorlevel 1 ( echo ERROR: nr_import_probe failed & exit /b 1 )
echo done: %WORK%\nr_import_probe.exe
endlocal
