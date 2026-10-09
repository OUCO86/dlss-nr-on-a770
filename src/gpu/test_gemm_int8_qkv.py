#!/usr/bin/env python3
"""The QKV projection's epilogue on the integer path, against the float path's.

Both GEMMs are fed the same numbers on grids where neither loses anything: the integer
operands are small integers times a power of two, so `float(acc) * a_scale * b_scale` is
the exact product and so is the half GEMM's own float32 accumulation of the same terms.
Two different instructions, one answer — which makes this a bit-exact test of everything
the integer path adds: where the three targets are found in the push block, where the row
and column scales moved to, and the epilogue reading its stage back out of the integer
block it was written into.

What it does not test is accuracy: that is `work/qkv_scale_spread.py` (at most half a
degree of direction against the half product) and `work/int8_quality.py` (the picture).
"""
import os
import pathlib
import sys

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import xmxres as X  # noqa: E402

GUARD = 64
FILL = np.float16(-11.1)          # not an E4M3 value, so no correct output can equal it
STEP = np.float32(2.0 ** -8)      # the grid: integers on it are exact in half and in float


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(2024)
    cases = 0
    # every QKV shape the frame asks for (work/qkv_census.py), plus a partial last block
    shapes = ((6, 64, 64), (2, 64, 128), (2, 64, 256), (1, 64, 512), (1, 96, 1024),
              (3, 64, 128), (1, 160, 128))
    for windows, tokens, channels in shapes:
        heads, rows = channels // 32, windows * tokens
        buffers = []

        def alloc(count, dtype):
            buf = rt.buffer(count, dtype)
            buffers.append(buf)
            return buf
        try:
            integers = rng.integers(-40, 41, size=(rows, channels))
            # the two kernels store the projection oppositely: the integer one wants B as
            # N x K because it loads a fragment by column, the float one as K x N
            weight_int = rng.integers(-40, 41, size=(3 * channels, channels))
            weight_kn = np.ascontiguousarray(weight_int.T)
            a_scale = np.full(rows, STEP, np.float32)
            b_scale = np.full(3 * channels, STEP, np.float32)
            a16 = alloc(rows * channels, np.float16)
            a8 = alloc(rows * channels, np.int8)
            w16 = alloc(3 * channels * channels, np.float16)
            w8 = alloc(3 * channels * channels, np.int8)
            sa = alloc(rows, np.float32)
            sb = alloc(3 * channels, np.float32)
            scale = alloc(heads, np.float32)
            half_targets = [alloc(rows * channels + GUARD, np.float16) for _ in range(3)]
            int_targets = [alloc(rows * channels + GUARD, np.float16) for _ in range(3)]
            X.host_write(a16, (integers * STEP).astype(np.float16))
            X.host_write(a8, integers.astype(np.int8))
            X.host_write(w16, (weight_kn * STEP).astype(np.float16))
            X.host_write(w8, weight_int.astype(np.int8))
            X.host_write(sa, a_scale)
            X.host_write(sb, b_scale)
            X.host_write(scale, rng.uniform(.5, 12, heads).astype(np.float32))
            # a zero row takes the norm floor, as it does on either path
            integers[1] = 0
            X.host_write(a8, integers.astype(np.int8))
            X.host_write(a16, (integers * STEP).astype(np.float16))

            for vit in (False, True):
                for buf in half_targets + int_targets:
                    X.host_write(buf, np.full(rows * channels + GUARD, FILL, np.float16))
                rt.begin()
                rt.gemm_qkv(a16, w16, *half_targets, scale, rows, channels, heads, tokens,
                            vit=vit)
                rt.gemm_int8_qkv(a8, w8, *int_targets, sa, sb, scale, rows, channels, heads,
                                 tokens, vit=vit)
                rt.submit()
                for name, want, got in zip("QKV", half_targets, int_targets):
                    want = X.host_view(want, np.float16)
                    got = X.host_view(got, np.float16)
                    if not np.array_equal(got.view(np.uint16), want.view(np.uint16)):
                        bad = np.flatnonzero(got.view(np.uint16) != want.view(np.uint16))
                        raise AssertionError(
                            f"{name} differs at {bad.size} of {got.size} (first {bad[0]}: "
                            f"{got[bad[0]]} against {want[bad[0]]}) windows={windows} "
                            f"tokens={tokens} C={channels} vit={vit}")
                    assert (got[rows * channels:] == FILL).all(), f"{name} guard overwritten"
                    # every element written, so agreement is not two untouched fills
                    assert not (got[:rows * channels] == FILL).any(), f"{name} left unwritten"
                cases += 1

            # the host-side guards
            for args, why in (
                    ((a8, w8, int_targets[0], int_targets[0], int_targets[2], sa, sb, scale),
                     "an aliased target"),
                    ((a8, w8, int_targets[0], int_targets[1], a8, sa, sb, scale),
                     "a target aliasing an input")):
                try:
                    rt.gemm_int8_qkv(*args, rows, channels, heads, tokens)
                except ValueError:
                    continue
                raise AssertionError(f"integer QKV accepted {why}")
            try:
                rt.gemm_int8_qkv(a8, w8, *int_targets, sa, sb, scale, rows, 32, 32, tokens)
            except ValueError:
                pass
            else:
                raise AssertionError("integer QKV accepted a 32-channel shape the kernel "
                                     "cannot carry")
        finally:
            for buf in buffers:
                buf.free()
    print(f"integer QKV projection: {cases} cases bit-identical to the float path "
          f"({os.environ.get('XMX_INT8_SPV', 'work/gemm_staged_int8.spv')})")


if __name__ == "__main__":
    main()
