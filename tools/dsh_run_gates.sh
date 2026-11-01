#!/bin/bash
# run_gates.sh -- the 40-gate suite from build_dll.sh, WITHOUT rebuilding the dll
# (use after a build to re-judge, or with GATE_ENV to judge one gate under a switch).
#   bash E:/DSH/run_gates.sh                      # all gates, default env
#   GATE_ONLY=gate_gemm_int8_batched GATE_ENV="NR_G32_PUB=1" bash E:/DSH/run_gates.sh
# Gates are the repo's own scripts (E:/DSH/dlss-nr-on-a770/src/bench/sycl/gate_*.py); they
# load E:/DSH/oneapi/libxmx_sycl.dll (the staged artifact). Logs -> E:/DSH/logs/<gate>.log.
set -u
HERE="E:/DSH/dlss-nr-on-a770/src/bench/sycl"
RUNDIR="E:/DSH/oneapi"
GATEPY="${GATEPY:-C:/Users/wangz/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/python.exe}"
export SYCL_CACHE_PERSISTENT=1
export SYCL_CACHE_DIR="E:/DSH/sycl-cache"
export DSH_ONEAPI="$RUNDIR"
GATES="gate_libxmx_sycl gate_unary gate_gemm_s8 gate_gemm_s8rq gate_chain_s1 gate_cosine gate_qkv_v gate_qkv_qk gate_softmax gate_cosine_i8 gate_softmax_i8 gate_qkv_v_i8 gate_requant_i8 gate_chain_scores gate_chain_qkv gate_gemm_s8rq32 gate_chain_attnv gate_graph gate_gemm_int8_residual gate_gemm_int8_qkv gate_window_int8_residual gate_quant_window gate_unary_kinds gate_gemm_f16 gate_gemm_f16_residual gate_ffn gate_ffn_stem gate_ffn_merge gate_gemm_f16_qkv_window gate_gemm_f16_window_residual_pool gate_window_block gate_window_block_head gate_merge_heads gate_window_attention gate_vit_softmax gate_global_attention gate_gemm_int8_batched gate_gemm_int8 gate_coexist"
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
