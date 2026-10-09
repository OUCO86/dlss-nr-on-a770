# improve-tiled32 — two register-tiled blocks instead of one

Opened 2026-10-09 on the A770 port. The question was whether the register-tiled GEMM
should hold a 16x32 or a 32x32 block of the output, and the answer turned out to be
"both, chosen per shape".

## The block is not the hardware

`RM`/`RN` — how many cooperative-matrix tiles a workgroup keeps in registers — are a
register budget, not a device property. The hardware shape on Xe-HPG is 8x8x16 (fp16) and
8x8x32 (int8); `xmx_shape.h` sets those. `RM = 2, RN = 4` (16x32) and `RM = 4, RN = 4`
(32x32) are both the hardware's own tiles, just a different number of them. Choosing
between them is free of any "make the block match Xe2" argument in either direction.

What is *not* free is the width: the QKV epilogue normalises a head inside one workgroup,
so the block has to be 32 columns wide, and the compact head's scatter needs 16. Those are
model geometry, and both builds satisfy them.

## Why not just ship the wider one

Measured on the real shape set (tools/bench_shapes.py, staging off, driver 101.9030):

    A  16x32 only                       42.36 ms   5398 GF/s
    B  32x32 where it applies, else 16x32  38.52 ms   5935 GF/s
    C  32x32 forced on every tiled shape  41.13 ms   5559 GF/s

C is the number that made 32x32 look like a 3 % win when it was measured alone: a shape
whose M is not a whole 32 rows then falls all the way back to the single-tile resident
kernel, and the fallback is slow enough to eat the win. B keeps those shapes on a tiled
kernel, which is why it beats both — the two-build routing is worth +10 %, not +3 %.

## What the routing has to get right

`use32` is not `tiled32`. Three paths have a block of their own and a grid that divides by
it — the staged kernel (64x32), its 32-row builds, and the window-gathered/pooled-residual
variants that live only in `gemm_staged.comp` — and handing any of them the 32x32 pipeline
while dispatching the staged grid computes the wrong rows. That was the first bug found
here (test_resident, blocks 6/9/20/23/44 wrong, corr 0.81-0.99): `staged` and `small` have
to exclude the wider block, while `tiled32` itself still counts for the QKV epilogue's
32-column test, which only asks whether *some* tiled build could take the shape.

Second: a shape of 32 rows or fewer is `small`'s, i.e. the staged 32-row build, not the
32x32 tiled block. `test_tiled32.py` lists it in neither set for that reason.

## Files

- `tools/build_shaders.sh`, `Makefile`, `CMakeLists.txt`, `tools/build_win.bat`: the second
  build, `gemm_tiled32.spv` from `gemm_resident.comp -DRM=4 -DRN=4`. The Xe2 values
  (`-DRM=2 -DRN=2`) in the Linux/SDK tables were corrected to `-DRN=4` at the same time;
  they would have built a 16x16 block with a 16x32 dispatch.
- `src/gpu/libxmx.c`: `xmx_tiled32_init` (family 12 — the specialised-pipeline cache is
  keyed on family and flags alone, so the two builds cannot share family 1),
  `xmx_tiled32(on)`, `xmx_tiled32_calls`, and the `tiled16`/`tiled32`/`use32` choice.
- `src/gpu/test_tiled32.py`: 44 cases bit-identical between the blocks, with the routing
  counter asserted in both directions.
