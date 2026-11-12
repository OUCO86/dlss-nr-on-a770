import sys
sys.stdout.reconfigure(encoding='utf-8')
src = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\bench_b6.cpp'
dst = r'E:\DSH\tmp\c47\c47_bench_b6.cpp'
s = open(src, encoding='utf-8', errors='replace').read()
shim = ('// C47 shim (my copy, engine tree untouched): the launch-count macros live in\n'
        '// libxmx_sycl.cpp, so a standalone bench TU defines them as no-ops.\n'
        '#define LC_TICK() do {} while (0)\n'
        '#define LC_ADD(field, v) do {} while (0)\n'
        '#define C47_PROBE 1\n')
open(dst, 'w', encoding='utf-8').write(shim + s)
print('wrote', dst, 'bytes', len(shim) + len(s))
