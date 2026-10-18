@echo off
rem build_replay_standalone.bat -- the offline replay EXE (nr_replay.c main) against the
rem CURRENT plan. The same cl invocation as tools\build_fused.bat step 2, with -LD dropped
rem and -DNR_REPLAY_STANDALONE added (notes/optiscaler-bridge.md 28.8's two ways of building
rem the same file). NOT a bridge or game artifact -- offline benchmark / bit-check tool only.
setlocal EnableExtensions
set "VSROOT=E:/ProgramData/Microsoft/Microsoft Visual Studio\18\Community"
set "ROOT=E:/WorkBuddy/2026-10-09-04-20-55"
set "REPO=%ROOT%\src\dlss-nr-on-a770"
set "WORK=%REPO%\work"
set "GPU=%REPO%\src\gpu"
set "VKINC=%ROOT%\work\vulkan-headers\include"
set "VCVER=14.51.36231"
set "SDKVER=10.0.26100.0"
set "VCTOOLS=%VSROOT%\VC\Tools\MSVC\%VCVER%"
set "SDKDIR=E:/Windows Kits\10"
set "PATH=%VCTOOLS%\bin\Hostx64\x64;%PATH%"
set "INCLUDE=%VCTOOLS%\include;%SDKDIR%\Include\%SDKVER%\ucrt;%SDKDIR%\Include\%SDKVER%\um;%SDKDIR%\Include\%SDKVER%\shared"
set "LIB=%VCTOOLS%\lib\x64;%SDKDIR%\Lib\%SDKVER%\ucrt\x64;%SDKDIR%\Lib\%SDKVER%\um\x64"
cl -nologo -O2 -std:c11 -TC -D_WIN32 -DNR_REPLAY_STANDALONE -I"%WORK%" -I"%GPU%" -Fe:"%WORK%\nr_replay_now.exe" "%GPU%\nr_replay.c" "%WORK%\plan_960x544.c"
if errorlevel 1 ( echo ERROR: standalone replay failed & exit /b 1 )
echo done: work/nr_replay_now.exe (embeds the current 5254-step plan)
endlocal
