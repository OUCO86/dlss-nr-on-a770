#!/bin/bash
# build_sycl_dll.sh — reproducible build+gate for the libxmx_sycl skeleton (route A').
# Traps paid for in blood tonight (notes §20 + the abibridge/skeleton gates):
#  * the .def MUST be CRLF with NO BOM: the Write tool's LF + a \r\n join gives \r\r\n
#    and link.exe reports LNK1107 "invalid file". Generate it binary, from the source's
#    extern "C" block — senior build_fused.bat:29 generates the def the same way (never
#    hand-maintain it).
#  * icx wants //flag form (MSYS collapses // -> /); the def reaches the linker as
#    //DEF:NAME (senior -link -DEF: at build_fused.bat:33), NOT as a bare input file
#    (that reads as a COFF object -> LNK1107).
#  * the dll runs staged in oneapi/, where sycl9.dll + its chain (libmmd, tbb12,
#    ur_loader, ur_win_proxy_loader) sit; the gate preloads that chain because Python
#    3.8+ does not search PATH for a dll's DEPENDENCIES (0x7e MOD_NOT_FOUND otherwise).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
PYV="C:/Users/wangz/.workbuddy/binaries/python/versions/3.13.12/python.exe"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"

# 1. def from the source (single source of truth = the cpp's extern "C" block)
"$PYV" - libxmx_sycl.cpp libxmx_sycl.def << 'PYEOF'
import re, sys
src, out = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8', errors='replace').read()
block = re.search(r'extern "C" \{(.*?)\n\} // extern "C"', s, re.S).group(1)
names = re.findall(r'^(?:const char\*|int)\s+(xmx_\w+)\s*\(', block, re.M)
data = "\r\n".join(["LIBRARY libxmx_sycl", "EXPORTS"] + ["    " + n for n in names]) + "\r\n"
open(out, 'wb').write(data.encode('ascii'))
print(f"def: {len(names)} exports")
PYEOF

# 2. compile
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc //DD_CRT_SECURE_NO_WARNINGS //Fe:libxmx_sycl.dll //LD libxmx_sycl.cpp //link //DEF:libxmx_sycl.def

# 3. stage + gate from oneapi/ (the SYCL runtime chain lives there)
RUNDIR="E:/WorkBuddy/2026-10-09-04-20-55/oneapi"
cp -f libxmx_sycl.dll "$RUNDIR/"
echo "built libxmx_sycl.dll; running the gate from $RUNDIR:"
( cd "$RUNDIR" && SYCL_DEVICE_FILTER=level_zero:gpu "C:/Users/wangz/.workbuddy/binaries/python/envs/default/Scripts/python.exe" "$HERE/gate_libxmx_sycl.py" )
