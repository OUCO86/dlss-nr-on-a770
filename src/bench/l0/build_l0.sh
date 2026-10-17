#!/bin/bash
# build_l0.sh — reproducible build+run for the Level Zero <-> D3D12 interop probes.
# Precedent: oneapi/build_probe.sh (seniors). Key traps, all paid for in blood today:
#  * //flag form (MSYS collapses // -> / for icx; do NOT set MSYS_NO_PATHCONV).
#  * source file BEFORE //link — //link swallows everything after it ("no input files").
#  * run from E:/WorkBuddy/2026-10-09-04-20-55/oneapi/ (ze_loader.dll + d3d12 runtime
#    siblings live there; MSYS PATH does not satisfy the native loader).
#  * D3D12-side rules are in the probe source comments (GENERIC_ALL handle access,
#    READBACK heap starts COPY_DEST, CreateCommandList returns an OPEN list,
#    queue->Signal is the only host fence advance).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"

src="$1"; out="$2"; shift 2 2>/dev/null || true
[ -f "$src" ] || { echo "no such src: $src"; exit 1; }
# the Vulkan leg's headers (work/vulkan-headers) join INCLUDE only when the source
# names vulkan.h; the import library is repo-local (tools/lib/vulkan-1.lib, the same
# one build_fused.bat links libxmx against -- no Vulkan SDK required).
VKROOT="E:/WorkBuddy/2026-10-09-04-20-55"
case "$src" in *probe_vk*)
    export INCLUDE="$VKROOT/work/vulkan-headers/include;$INCLUDE"
    export LIB="$VKROOT/tools/lib;$LIB"; export LIBPATH="$LIB"
    ;;
esac
libs="d3d12.lib dxgi.lib ze_loader.lib"
case "$src" in *caps*) libs="ze_loader.lib";; esac
case "$src" in *probe_vk*) libs="vulkan-1.lib ze_loader.lib";; esac
echo "icx -> $out ($libs)"
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //EHsc "//Fe:$out" "$src" //link $libs

RUNDIR="E:/WorkBuddy/2026-10-09-04-20-55/oneapi"
cp -f "$out" "$RUNDIR/"
echo "built; running from $RUNDIR:"
( cd "$RUNDIR" && "./$(basename "$out")" )
