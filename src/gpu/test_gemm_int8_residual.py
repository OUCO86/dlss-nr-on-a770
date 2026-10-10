#!/usr/bin/env python3
"""The integer GEMM's residual epilogue against the two passes it replaces.

`gemm_staged_int8.comp` had no epilogue, so every integer projection ended by writing
its float32 branch out and reading it back in a residual pass of its own: 120 passes a
frame, 2.38 ms of the device's 36.4, and one pass more than the float path pays for the
same job (`notes/frame-ledger-a770.md`). It has one now, and this test is what makes
that safe — not an average error, but the same bits, because the pass being removed is
not an approximation either.

The comparison is the two an identical pair of quantised operands can produce:

    quantize_row · gemm_int8 · residual          what the graph has been recording
    quantize_row · gemm_int8_residual            what it records now

over the frame's own shapes, every publish, both widths of skip and both of output,
and a window block's write back into the unpadded image.

What it is looking for, specifically, is an ulp. Adding the residual where a stored
branch used to be invites an FMA across a rounding point the two-pass path did not
have, and `ffn_fused.comp` hit exactly that: written as `branch + skip * cosine` it was
contracted one way and missed by an ulp, so it is written there as `fma` and `precise`.
This is the test that would have caught it, and it reads every byte.
"""
import numpy as np
import xmxres as X


def main():
    rt = X.Runtime()
    if not rt.int8_residual:
        print("integer residual: skipped (this native build has no integer residual "
              "epilogue — build the shaders and libxmx) — a skip is not a pass")
        return 0
    rng = np.random.default_rng(44)
    cases = 0
    # Whole blocks first, then one whose last block of rows is partial, then two of the
    # shapes the frame itself asks for (`notes/frame-ledger-a770.md`).
    for rows, cols, inner in ((64, 32, 64), (100, 96, 128), (384, 512, 512),
                              (1344, 256, 256), (5376, 128, 128)):
        cases += check(rt, rng, rows, cols, inner, None)
    # A window block's output projection: padded rows in window order, written back into
    # the unpadded image. The shifted origin is what puts more window rows than pixels in
    # front of the index map.
    for height, width, channels, inner in ((13, 19, 32, 64), (16, 24, 128, 128),
                                           (19, 9, 32, 64)):
        for origin in ((0, 0), (-4, -3)):
            ph, pw, _ = rt.window_extent(height, width, origin)
            cases += check(rt, rng, ph * pw, channels, inner, (height, width, 8, origin))
    print(f"integer residual: {cases} cases bit-identical to the two passes it replaces")
    return 0


def check(rt, rng, rows, cols, inner, reverse):
    """One shape through every publish and both widths, fused against the pair."""
    written = reverse[0] * reverse[1] if reverse else rows
    buffers = []

    def upload(values, dtype=np.float32):
        buf = rt.buffer_from(values, dtype)
        buffers.append(buf)
        return buf

    def allocate(count, dtype=np.float32):
        buf = rt.buffer(count, dtype)
        buffers.append(buf)
        return buf

    done = 0
    try:
        source = upload(rng.normal(0, .3, (rows, inner)), np.float16)
        weight = upload(rng.integers(-127, 128, (cols, inner), dtype=np.int8), np.int8)
        column = upload(rng.uniform(0.001, 0.02, cols).astype(np.float32))
        cosine = upload(rng.uniform(-1.5, 1.5, cols))
        packed = allocate(rows * inner, np.int8)
        row_scale = allocate(rows, np.float32)
        branch = allocate(rows * cols, np.float32)
        for skip_half in (False, True):
            skip_dtype = np.float16 if skip_half else np.float32
            values = rng.normal(0, .5, written * cols).astype(skip_dtype)
            skip = upload(values, skip_dtype)
            for narrow in (False, True):
                dtype = np.float16 if narrow else np.float32
                sentinel = np.float16(-11) if narrow else np.float32(-11)
                out = allocate(written * cols + 16, dtype)
                expected = allocate(written * cols + 16, dtype)
                for epilogue in (0, X.EPI_E4M3, X.EPI_GATE, X.EPI_GATE_E4M3, X.EPI_HALF):
                    for buf in (out, expected):
                        X.host_write(buf, np.full(written * cols + 16, sentinel, dtype))
                    rt.begin()
                    rt.quantize_row(source, packed, row_scale, rows, inner)
                    rt.gemm_int8(packed, weight, branch, row_scale, column, rows, cols, inner)
                    rt.residual(branch, skip, cosine, expected, written * cols, cols,
                                epilogue=epilogue, narrow=narrow, b_half=skip_half,
                                reverse=reverse)
                    rt.gemm_int8_residual(packed, weight, out, row_scale, column,
                                          skip, cosine, rows, cols, inner,
                                          epilogue=epilogue, narrow=narrow,
                                          skip_half=skip_half, reverse=reverse)
                    rt.submit()
                    np.testing.assert_array_equal(
                        X.host_view(out, dtype).view(np.uint8),
                        X.host_view(expected, dtype).view(np.uint8),
                        err_msg=(f"{rows}x{cols}x{inner} reverse={reverse} "
                                 f"epilogue={epilogue} narrow={narrow} "
                                 f"skip_half={skip_half}"))
                    # Nothing written past the output, either.
                    tail = X.host_view(out, dtype)[written * cols:]
                    assert (tail.view(np.uint16) == np.float16(-11).view(np.uint16)).all() \
                        if narrow else (tail == -11).all(), "written past the output"
                    done += 1
                if narrow == skip_half:
                    # In place, which is how a window block writes its own image back.
                    rt.begin()
                    rt.gemm_int8_residual(packed, weight, skip, row_scale, column,
                                          skip, cosine, rows, cols, inner,
                                          epilogue=X.EPI_HALF, narrow=narrow,
                                          skip_half=skip_half, reverse=reverse)
                    rt.submit()
                    np.testing.assert_array_equal(
                        X.host_view(skip, dtype).view(np.uint8),
                        X.host_view(expected, dtype)[:written * cols].view(np.uint8))
                    X.host_write(skip, values)
                    done += 1
    finally:
        for buf in buffers:
            buf.free()
    return done


if __name__ == "__main__":
    main()
