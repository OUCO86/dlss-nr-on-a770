/*
 * xmx_shape.h — the cooperative-matrix shapes, for the C side of the build.
 *
 * These must agree with the .comp kernels. They are the numbers the driver on
 * this machine actually advertises (logs/a770-coopmat.txt, driver 101.9030):
 *
 *   Intel Arc A770 (0x56a0)          Xe2 / LNL, what upstream targeted
 *     0   8   8  16  fp16 -> fp32      8  16  16  fp16 -> fp32
 *     1   8   8  32  u8   -> u32       8  16  32  s8   -> s32
 *     2   8   8  32  s8   -> s32
 *
 * Only N differs. Anything that sizes a dispatch grid, picks a tile or decides
 * how many output columns a workgroup covers has to come from here rather than
 * from a literal, or it silently computes half the output when N changes.
 *
 * XMX_TILE_* is the block libxmx asks a workgroup to cover — columns per
 * workgroup in the N direction, rows in M. Those are set by the model (a head
 * is 32 channels, the compact head's output is 4), not by the hardware, so
 * they read the same 16x32 / 8x16 here that they did on Xe2. What changes with
 * the shape is only how many tiles make up that block.
 */

#ifndef XMX_SHAPE_H
#define XMX_SHAPE_H

/* The float16 configuration, config 0 on this device. */
#define XMX_TM 8
#define XMX_TN 8
#define XMX_TK 16

/* The integer configurations, configs 1 and 2 on this device. */
#define XMX_TM_INT8 8
#define XMX_TN_INT8 8
#define XMX_TK_INT8 32

/* The register-tiled build (gemm_tiled.spv) is RM = 2, RN = 4, so its block is
 * TM*RM x TN*RN = 16 x 32 — the width the QKV epilogue needs, a head being 32
 * channels. Xe2 reached the same 16x32 with RM = 2, RN = 2 because its tiles
 * were twice as wide. Overridable with XMX_TILE_M / XMX_TILE_N so another
 * block can be measured without rebuilding. */
#define XMX_TILE_M 16
#define XMX_TILE_N 32

/* The second register-tiled build (gemm_tiled32.spv) is RM = 4, RN = 4, a 32x32
 * block. It is quicker where it applies — real shape set 5565 against 5389 GF/s,
 * clean 5222 against 4829 — and it does not apply everywhere: a taller block
 * needs M to be a whole multiple of it and the QKV epilogue's live rows are not
 * (logs/test-final6.txt, "needs ... a 32-column block"). So the two builds are
 * shipped side by side and the routing picks per shape — 32x32 where M and N
 * are both whole blocks of it, 16x32 otherwise — rather than one block being
 * asked to serve every shape. Overridable with XMX_TILE32_M / XMX_TILE32_N;
 * XMX_TILED32=0 takes the 16x32 build everywhere, for the comparison. */
#define XMX_TILE32_M 32
#define XMX_TILE32_N 32

/* The plain resident kernel (gemm_resident.spv) is RM = 1, RN = 2, so one
 * workgroup covers 8 x 16 — the width the compact head needs, its N being 16.
 * Xe2 reached 8x16 with RM = 1, RN = 1. Note RN is not the hardware shape
 * (that is XMX_TN alone); it is how many of those tiles a workgroup holds, and
 * it is bounded below by what the epilogues have to see at once. */
/* The 8x32 tiled build (gemm_tiled8.spv) is RM = 1, RN = 4: half the 16x32's rows and
 * twice the workgroups. Off unless XMX_TILED8 asks for it. */
#define XMX_TILE8_M 8
#define XMX_TILE8_N 32

#define XMX_BLOCK_RM 1
#define XMX_BLOCK_RN 2
#define XMX_BLOCK_M (XMX_TM * XMX_BLOCK_RM)
#define XMX_BLOCK_N (XMX_TN * XMX_BLOCK_RN)

/* The staged kernels — fp16 and int8 alike — compute a fixed 64 x 32 block
 * regardless of the tile shape underneath, because the block is the model's
 * geometry (a 32-channel head), not the hardware's.  STAGED_BM makes 32-row
 * builds; the int8 build is 64 x 32 with BK = 64. */
#define XMX_STAGED_BN 32
#define XMX_STAGED_BM 64

/* Ceiling division: a partial tile still needs a workgroup, and it masks the
 * rows and columns past the edge rather than writing them. */
#define XMX_DIV_UP(a, b) (((a) + (b) - 1) / (b))

#endif /* XMX_SHAPE_H */
