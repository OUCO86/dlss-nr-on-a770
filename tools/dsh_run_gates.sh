#!/bin/bash
# run_gates.sh -- the 40-gate suite from build_dll.sh, WITHOUT rebuilding the dll
# (use after a build to re-judge, or with GATE_ENV to judge one gate under a switch).
#   bash E:/DSH/run_gates.sh                      # all gates, default env
#   GATE_ONLY=gate_gemm_int8_batched GATE_ENV="NR_G32_PUB=1" bash E:/DSH/run_gates.sh
#   RUNDIR=E:/DSH/tmp/gs_smax1 SYCL_CACHE_DIR=E:/DSH/tmp/syclcache_cert bash ... # judge a VARIANT
# Gates are the repo's own scripts (E:/DSH/dlss-nr-on-a770/src/bench/sycl/gate_*.py); they
# chdir into $RUNDIR and CDLL(./libxmx_sycl.dll) -- so $RUNDIR *is* the artifact under test
# (see rule 146: never trust a gate reading that does not name the dll it loaded).
# Logs -> E:/DSH/logs/<gate>.log.
set -u
HERE="E:/DSH/dlss-nr-on-a770/src/bench/sycl"
RUNDIR="${RUNDIR:-E:/DSH/oneapi}"
GATEPY="${GATEPY:-C:/Users/wangz/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/python.exe}"
export SYCL_CACHE_PERSISTENT="${SYCL_CACHE_PERSISTENT:-1}"
# Default to a DEDICATED cold cache for certification (rule 141); override with SYCL_CACHE_DIR=...
export SYCL_CACHE_DIR="${SYCL_CACHE_DIR:-E:/DSH/tmp/syclcache_cert}"
export DSH_ONEAPI="$RUNDIR"
# Keep the staged dir on PATH so the loaded dll still resolves sycl9/level-zero dependencies.
export PATH="$PATH;E:/DSH/oneapi"
DLL="$RUNDIR/libxmx_sycl.dll"
if [ -f "$DLL" ]; then
  M=$(certutil -hashfile "$(cygpath -w "$DLL" 2>/dev/null || echo "$DLL")" MD5 2>/dev/null | sed -n '2p' | tr -d ' ')
  echo "[gate-selfcheck] loaded dll = $DLL  md5 = ${M:-UNKNOWN}"
else
  echo "[gate-selfcheck] loaded dll = $DLL  MISSING"
fi
echo "[gate-selfcheck] SYCL_CACHE_DIR = $SYCL_CACHE_DIR (persistent=$SYCL_CACHE_PERSISTENT)"
GATES="gate_libxmx_sycl gate_unary gate_gemm_s8 gate_gemm_s8rq gate_chain_s1 gate_cosine gate_qkv_v gate_qkv_qk gate_softmax gate_cosine_i8 gate_softmax_i8 gate_qkv_v_i8 gate_requant_i8 gate_chain_scores gate_chain_qkv gate_gemm_s8rq32 gate_chain_attnv gate_graph gate_gemm_int8_residual gate_gemm_int8_qkv gate_window_int8_residual gate_quant_window gate_unary_kinds gate_gemm_f16 gate_gemm_f16_residual gate_ffn gate_ffn_stem gate_ffn_merge gate_gemm_f16_qkv_window gate_gemm_f16_window_residual_pool gate_window_block gate_window_block_head gate_merge_heads gate_window_attention gate_vit_softmax gate_global_attention gate_gemm_int8_batched gate_gemm_int8 gate_coexist gate_skip_graph"
[ -n "${GATE_ONLY:-}" ] && GATES="$GATE_ONLY"
green=0; red=0; reds=""
for x in $GATES; do
  if ( cd "$RUNDIR" && env SYCL_DEVICE_FILTER=level_zero:gpu ${GATE_ENV:-} "$GATEPY" "$HERE/$x.py" > "E:/DSH/logs/${x}${SUFFIX:-}.log" 2>&1 ); then
    green=$((green+1)); echo "GREEN $x"
  else
    red=$((red+1)); reds="$reds $x"; echo "RED   $x  (E:/DSH/logs/${x}${SUFFIX:-}.log)"
  fi
done
echo "gates: $green GREEN / $red RED$reds"
[ "$red" = "0" ]
