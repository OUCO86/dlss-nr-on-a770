@echo off
rem build_fused.bat -- the two dlls the fused path runs on: libxmx.dll and nr_net.dll.
rem
rem The same cl invocation as the project's tools\build_msvc.bat, reduced to the two
rem things the fused path changed: libxmx.c (the D3D12 fence import) and nr_replay.c
rem with the plan table compiled in (nr_net_wait, nr_net_fused). Nothing else that
rem build_msvc.bat makes is touched by this.
setlocal EnableExtensions
set "VSROOT=E:\ProgramData\Microsoft\Microsoft Visual Studio\18\Community"
set "ROOT=E:\WorkBuddy\2026-10-09-04-20-55"
set "REPO=%ROOT%\src\dlss-nr-on-a770"
set "WORK=%REPO%\work"
set "GPU=%REPO%\src\gpu"
set "VKINC=%ROOT%\work\vulkan-headers\include"
set "VKLIB=%ROOT%\tools\lib"
set "VCVER=14.51.36231"
set "SDKVER=10.0.26100.0"
set "VCTOOLS=%VSROOT%\VC\Tools\MSVC\%VCVER%"
set "SDKDIR=E:\Windows Kits\10"
set "PY=C:\Users\wangz\.workbuddy\binaries\python\versions\3.13.12\python.exe"
set "PATH=%VCTOOLS%\bin\Hostx64\x64;%PATH%"
set "INCLUDE=%VCTOOLS%\include;%SDKDIR%\Include\%SDKVER%\ucrt;%SDKDIR%\Include\%SDKVER%\um;%SDKDIR%\Include\%SDKVER%\shared;%SDKDIR%\Include\%SDKVER%\winrt"
set "LIB=%VCTOOLS%\lib\x64;%SDKDIR%\Lib\%SDKVER%\ucrt\x64;%SDKDIR%\Lib\%SDKVER%\um\x64"

rem The exported names, taken from the source itself. A hand-kept list is a list that
rem falls behind, and a name it misses is a call the host is given a null for -- which
rem is how the device handles came back as zero and the hand-over quietly kept a
rem device of its own. So the def is written here, not maintained.
"%PY%" -c "import re,sys; s=open(r'%GPU%\libxmx.c',encoding='utf-8',errors='replace').read(); n=sorted({m.group(2) for m in re.finditer(r'(?m)^([A-Za-z_][\w \*]*?)\b(xmx_\w+)\s*\([^;]*\)\s*\{', s) if 'static' not in m.group(1)}); open(r'%WORK%\libxmx.def','w',encoding='ascii',newline='\r\n').write('\r\n'.join(['LIBRARY libxmx','EXPORTS']+['    '+x for x in n])+'\r\n'); print('def:',len(n),'exports')"
if errorlevel 1 ( echo ERROR: could not write libxmx.def & exit /b 1 )

echo [1/2] libxmx.dll
cl -nologo -O2 -std:c11 -TC -D_WIN32 -I"%VKINC%" -I"%GPU%" -Fo:"%WORK%\libxmx.obj" -Fe:"%WORK%\libxmx.dll" -LD "%GPU%\libxmx.c" -link -DEF:"%WORK%\libxmx.def" "%VKLIB%\vulkan-1.lib"
if errorlevel 1 ( echo ERROR: libxmx.dll failed & exit /b 1 )

echo [2/2] nr_net.dll
cl -nologo -O2 -std:c11 -TC -D_WIN32 -DNR_NET_BUILD -I"%WORK%" -I"%GPU%" -Fe:"%WORK%\nr_net.dll" -LD "%GPU%\nr_replay.c" "%WORK%\plan_960x544.c"
if errorlevel 1 ( echo ERROR: nr_net.dll failed & exit /b 1 )
echo done: libxmx.dll nr_net.dll
endlocal
