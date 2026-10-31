#!/bin/bash
# build_dll.sh — DS 接手专用：出货引擎 libxmx_sycl.dll + 全套门（1250 门），全部在 E:\DSH 内。
# 配方来自 WB 的 src/bench/sycl/build_sycl_dll.sh（坑：.def 必须 CRLF 无 BOM、//DEF:NAME 给 linker、
# gate 必须在放着运行时 dll 的目录里跑）。差别：RUNDIR/E:/DSH/oneapi，产物另存 E:/DSH/out/libxmx.dll。
set -e
REPO="E:/DSH/dlss-nr-on-a770"
HERE="$REPO/src/bench/sycl"
cd "$HERE"
SY="E:/WorkBuddy/toolchain-mamba/sycl"
VCTOOLS="E:/ProgramData/Microsoft/Microsoft Visual Studio/18/Community/VC/Tools/MSVC/14.51.36231"
SDK="E:/Windows Kits/10"
PYV="C:/Users/wangz/.workbuddy/binaries/python/versions/3.13.12/python.exe"
GATEPY="C:/Users/wangz/.workbuddy/binaries/python/envs/default/Scripts/python.exe"
RUNDIR="E:/DSH/oneapi"
export INCLUDE="$SY/Library/include;$VCTOOLS/include;$SDK/Include/10.0.26100.0/ucrt;$SDK/Include/10.0.26100.0/um;$SDK/Include/10.0.26100.0/shared"
export LIB="$SY/Library/lib;$VCTOOLS/lib/x64;$SDK/Lib/10.0.26100.0/ucrt/x64;$SDK/Lib/10.0.26100.0/um/x64"
export LIBPATH="$LIB"
export SYCL_CACHE_PERSISTENT=1
export SYCL_CACHE_DIR="E:/DSH/sycl-cache"

# 1. def 由源文件的 extern "C" 块生成（单一真源，别手维护）
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

# 2. 编译
"$SY/Library/bin/icx.exe" //nologo //Qstd=c++17 //O2 //fsycl //EHsc //DD_CRT_SECURE_NO_WARNINGS //Fe:libxmx_sycl.dll //LD libxmx_sycl.cpp //link //DEF:libxmx_sycl.def ze_loader.lib d3d12.lib dxgi.lib

# 3. stage 到 DSH 的运行时目录，并留一份带 md5 的产物
cp -f libxmx_sycl.dll "$RUNDIR/"
cp -f libxmx_sycl.dll "E:/DSH/out/libxmx_new.dll"
md5sum libxmx_sycl.dll | tee "E:/DSH/logs/dll_md5_$(date +%Y%m%d-%H%M%S).txt"

# 4. 全套门（清单与 WB 的 build_sycl_dll.sh 一致；任何一红=当场停，不过夜）
GATES="gate_libxmx_sycl gate_unary gate_gemm_s8 gate_gemm_s8rq gate_chain_s1 gate_cosine gate_qkv_v gate_qkv_qk gate_softmax gate_cosine_i8 gate_softmax_i8 gate_qkv_v_i8 gate_requant_i8 gate_chain_scores gate_chain_qkv gate_gemm_s8rq32 gate_chain_attnv gate_graph gate_gemm_int8_residual gate_gemm_int8_qkv gate_window_int8_residual gate_quant_window gate_unary_kinds gate_gemm_f16 gate_gemm_f16_residual gate_ffn gate_ffn_stem gate_ffn_merge gate_gemm_f16_qkv_window gate_gemm_f16_window_residual_pool gate_window_block gate_window_block_head gate_merge_heads gate_window_attention gate_vit_softmax gate_global_attention gate_gemm_int8_batched gate_gemm_int8 gate_coexist"
green=0; red=0
for g in $GATES; do
  if ( cd "$RUNDIR" && SYCL_DEVICE_FILTER=level_zero:gpu "$GATEPY" "$HERE/$g.py" > "E:/DSH/logs/$g.log" 2>&1 ); then
    green=$((green+1)); echo "GREEN $g"
  else
    red=$((red+1)); echo "RED   $g  (see E:/DSH/logs/$g.log)"
  fi
done
echo "gates: $green GREEN / $red RED"
[ "$red" = "0" ]
