#!/bin/bash
# bench.sh — DS 接手专用：编译 + stage + 运行 ESIMD/SYCL bench（全部在 E:\DSH 内，不碰 WB）
# 照抄 E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/src/bench/esimd/build_esimd.sh 的坑配方：
#   * icx 是 clang-cl 驱动：flag 写 //nologo（双斜杠），且 **不要设 MSYS_NO_PATHCONV**
#   * ESIMD 只走 Level Zero：SYCL_DEVICE_FILTER=level_zero:gpu
#   * exe 必须 stage 到放着 sycl9.dll 全链的目录里跑（=E:/DSH/oneapi），PATH 喂不饱原生加载器
set -e
SY="E:/WorkBuddy/toolchain-mamba/sycl"           # 只读引用现有工具链
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
RUNDIR="E:/DSH/oneapi"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"
export SYCL_CACHE_PERSISTENT=1
export SYCL_CACHE_DIR="E:/DSH/sycl-cache"
export SYCL_DEVICE_FILTER=level_zero:gpu
export PATH="$SY/Library/bin:$PATH"
mkdir -p "$SYCL_CACHE_DIR"

src="$1"; out="$2"; shift 2 2>/dev/null || true
[ -f "$src" ] || { echo "no such src: $src"; exit 1; }
echo "icx -> $out  ($*)"
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc "$@" "//Fe:$out" "$src"
cp -f "$out" "$RUNDIR/"
echo "built $out; running from $RUNDIR:"
( cd "$RUNDIR" && "./$(basename "$out")" )
