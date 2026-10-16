#!/bin/bash
# build_esimd.sh — reproducible build+run for the ESIMD XMX microkernels.
#
# WHY THIS FILE EXISTS: the conda-forge dpcpp (icx //fsycl) on Windows/MSYS has a
# flag-quoting trap that cost a full failed build tonight. icx is a clang-cl-style
# driver: it wants `/nologo /O2 /fsycl` (single slash). But MSYS bash rewrites a
# single-slash arg into a Windows path. The fix is to write them as `//nologo`
# etc. AND to NOT set MSYS_NO_PATHCONV — with that var set, `//` is passed
# literally as `//nologo` and icx rejects it ("no such file or directory").
# Without it, MSYS collapses `//nologo` -> `/nologo` exactly as icx wants.
# (Precedent: the seniors' oneapi/build_probe.sh uses the same `//` form.)
#
# Everything lives on E: — the toolchain, the JIT cache, the outputs. C: untouched.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"
export SYCL_CACHE_PERSISTENT=1
export SYCL_CACHE_DIR="$HERE/sycl-cache"
# ESIMD needs the Level Zero backend (OpenCL does not expose it); the seniors'
# smoke ran on L0 (driver string 1.17.x). sycl-ls shows OpenCL by default.
export SYCL_DEVICE_FILTER=level_zero:gpu
export PATH="$SY/Library/bin:$PATH"
mkdir -p "$SYCL_CACHE_DIR"

# usage: build_esimd.sh <src.cpp> <out.exe> [extra //D defines...]
src="$1"; out="$2"; shift 2 2>/dev/null || true
[ -f "$src" ] || { echo "no such src: $src"; exit 1; }
echo "icx -> $out  ($*)"
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc "$@" "//Fe:$out" "$src"

# RUN TRAP (cost two failed runs tonight): the exe finds sycl9.dll etc. by the
# Windows search order — next to the EXE, then PATH. But under MSYS a PATH entry
# pointing at the conda bin does NOT satisfy the native loader for a sibling
# dependency chain (tbb12, ur_adapter_level_zero, ...); it only works when every
# runtime dll sits beside the exe. The seniors solved this by copying the whole
# set into oneapi/ once. So: stage the exe into oneapi/ (which already holds
# sycl9.dll, dnnl.dll, tbb12.dll, ur_adapter_*.dll) and run it from there.
RUNDIR="E:/WorkBuddy/2026-10-09-04-20-55/oneapi"
cp -f "$out" "$RUNDIR/" 2>/dev/null || { echo "cannot stage into $RUNDIR"; exit 1; }
echo "built $out; running from $RUNDIR:"
( cd "$RUNDIR" && "./$(basename "$out")" )

