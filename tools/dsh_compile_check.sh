#!/bin/bash
# compile_check.sh -- bench.sh's exact toolchain/env recipe, COMPILE ONLY (no GPU run):
# used to prove a bench source still builds without taking time on the A770.
# Same traps as bench.sh: //flags (clang-cl), no MSYS_NO_PATHCONV, cd + relative names.
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"
export PATH="$SY/Library/bin:$PATH"
src="$1"; out="$2"; shift 2 2>/dev/null || true
[ -f "$src" ] || { echo "no such src: $src"; exit 1; }
echo "icx (compile only) -> $out  ($*)"
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc "$@" "//Fe:$out" "$src"
rc=$?
echo "icx_exit=$rc  artifact=$([ -f "$out" ] && echo yes || echo no)"
exit $rc
