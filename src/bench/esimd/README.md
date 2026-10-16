# ESIMD XMX microkernels — the rewrite's measurement ground

Built with the conda-forge `dpcpp_win-64 2026.1.1` at
`E:/WorkBuddy/toolchain-mamba/sycl` (installed 2026-10-16, entirely on E:, C:
untouched). `build_esimd.sh` reproduces the two traps that cost failed runs:
the `//flag` MSYS quoting (do NOT set MSYS_NO_PATHCONV) and the sibling-dll
run location (stage the exe into `oneapi/`, which holds sycl9.dll et al.).

- `esimd_dpas_peak.cpp` — raw XMX s8 DPAS issue ceiling, no data movement.
  **~195-200 TOPS = 75% of the 262 marketing figure** (4096 threads, ILP=4,
  long kernel; DCE excluded by linear scaling). This is the number that
  reframes the whole rewrite: the coopmat 24.8 ceiling is a Vulkan->DPAS
  codegen tax, not hardware — the array itself runs 8x faster. See
  notes/onednn-vs-coopmat-frameshape.md 补测三.
- `smoke_sycl.cpp` — the icx -> level-zero -> A770 chain gate.
