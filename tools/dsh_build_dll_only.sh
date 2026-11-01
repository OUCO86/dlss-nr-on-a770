#!/bin/bash
# build_dll_only.sh -- build_dll.sh's compile+stage part, no gates (for probes).
set -e
REPO="E:/DSH/dlss-nr-on-a770"; HERE="$REPO/src/bench/sycl"; cd "$HERE"
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
PYV="C:/Users/wangz/.workbuddy/binaries/python/versions/3.13.12/python.exe"
RUNDIR="E:/DSH/oneapi"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"; export LIBPATH="$LIB"
export SYCL_CACHE_PERSISTENT=1; export SYCL_CACHE_DIR="E:/DSH/sycl-cache"
"$PYV" - libxmx_sycl.cpp libxmx_sycl.def << 'PYEOF'
import re, sys
src, out = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8', errors='replace').read()
block = re.search(r'extern "C" \{(.*?)\n\} // extern "C"', s, re.S).group(1)
names = re.findall(r'^(?:const char\*|int|unsigned long long)\s+(xmx_\w+)\s*\(', block, re.M)
data = "\r\n".join(["LIBRARY libxmx_sycl", "EXPORTS"] + ["    " + n for n in names]) + "\r\n"
open(out, 'wb').write(data.encode('ascii'))
print(f"def: {len(names)} exports")
PYEOF
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc //DD_CRT_SECURE_NO_WARNINGS //Fe:libxmx_sycl.dll //LD libxmx_sycl.cpp //link //DEF:libxmx_sycl.def ze_loader.lib d3d12.lib dxgi.lib 2>/dev/null
cp -f libxmx_sycl.dll "$RUNDIR/"; cp -f libxmx_sycl.dll "E:/DSH/out/libxmx_new.dll"
md5sum libxmx_sycl.dll
