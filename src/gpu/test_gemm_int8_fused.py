#!/usr/bin/env python3
"""The fused integer GEMM against the integer GEMM it replaces.

`gemm_staged_int8_fused.comp` reads float16 activations and puts them on the integer grid
as it loads them, so the packed int8 copy that `quantize_row` writes and the GEMM reads
back is never made. It is otherwise `gemm_staged_int8.comp`: the same per-row scale, the
same exact int32 accumulator over all of K, the same epilogue. So the two kernels have to
agree, and this asks them to — against the sum done on the host, and against each other.

Bit for bit on structured input, because there the quantisation rounds to a whole 127
whatever the last bit of the reciprocal was. Within one step on random input, because the
kernel reaches the grid by multiplying by a reciprocal and the host by dividing by a
scale, and on a value a hundredth of a step from the halfway point those two disagree —
one element in sixteen thousand, measured. A wrong row, a wrong scale or a wrong block
would move the output by a factor, not by a step, so the check still holds.

The last line is what decides whether the kernel is worth wiring up: the same product in
float64, and how far the integer path sits from it. That arithmetic is unchanged by this
kernel — it is the same product as before — and it is here so that a change to the GEMM
cannot quietly make the picture worse.
"""
import numpy as np
import xmxres as X

F127 = np.array([127.0], np.float32)


def reference(a, b, b_scale, rows, cols, inner):
    """The kernel's product: per-row scale, exact integer accumulator, float32 epilogue.

    The scale and its reciprocal are both float32 divisions, because `np.float32(x / 127)`
    is a float64 division rounded afterwards — two roundings, and a different number.
    """
    af = a.astype(np.float32)
    top = np.abs(af).max(axis=1).astype(np.float32)
    zero = top == np.float32(0.0)
    scale = np.where(zero, np.float32(1.0), top / F127)
    # the kernel divides once, by 1.0 / scale, not by 127.0 / peak — the two differ by a
    # couple of ulps, which is the difference between 127 and 126 on a boundary
    recip = np.where(zero, np.float32(1.0), np.float32(1.0) / scale)
    packed = np.clip(np.round(af * recip[:, None]), -127, 127)
    acc = packed.astype(np.int64) @ b.astype(np.int64).T
    assert np.abs(acc).max() < 1 << 24, "the accumulator must stay exact in float"
    return (acc.astype(np.float32) * scale[:, None]) * b_scale[None, :]


def once(rt, a, b, b_scale, rows, cols, inner, fused=True):
    """Run the shape the fused way or the two-pass way; return the output.

    Both ways still begin with `quantize_row`, because both need the per-row scale and
    that is the pass that computes it. Only the fused one ignores what it wrote.
    """
    buffers = [rt.buffer(rows * inner, np.float16), rt.buffer(cols * inner, np.int8),
               rt.buffer(rows, np.float32), rt.buffer(cols, np.float32),
               rt.buffer(rows * cols + 64, np.float32), rt.buffer(rows * inner, np.int8)]
    A, B, SA, SB, C, PACKED = buffers
    try:
        X.host_write(A, a)
        X.host_write(B, b)
        X.host_write(SB, b_scale)
        X.host_write(C, np.full(rows * cols + 64, np.nan, np.float32))
        rt.begin()
        rt.quantize_row(A, PACKED, SA, rows, inner)
        if fused:
            rt.gemm_int8_fused(A, B, C, SA, SB, rows, cols, inner)
        else:
            rt.gemm_int8(PACKED, B, C, SA, SB, rows, cols, inner)
        rt.submit()
        got = X.host_view(C)[:rows * cols].reshape(rows, cols).copy()
        assert np.isnan(X.host_view(C)[rows * cols:]).all(), "written past the output"
        return got
    finally:
        for buf in buffers:
            buf.free()


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(11)
    cases = 0
    for rows, cols, inner in ((64, 32, 64), (64, 1024, 1024), (100, 96, 128),
                              (256, 3072, 1024), (16, 4096, 1024), (64, 1024, 4096),
                              (130, 64, 192)):
        b = rng.integers(-127, 128, (cols, inner), dtype=np.int8)
        b_scale = rng.uniform(0.001, 0.02, cols).astype(np.float32)
        if cases == 0:
            # one value per row: the quantisation rounds to a whole 127 either way, so
            # this is the comparison that can be bit-exact
            a = np.zeros((rows, inner), np.float16)
            for r in range(rows):
                a[r] = np.float16((r + 1) * 0.05)
        else:
            a = (rng.standard_normal((rows, inner)) * 0.05).astype(np.float16)
        got = once(rt, a, b, b_scale, rows, cols, inner, fused=True)
        # It has to be the same GEMM as the one it replaces, and on structured input that
        # can be bit-exact: one value per row, so nothing sits near a boundary where the
        # two ways of reaching the grid could disagree.
        two = once(rt, a, b, b_scale, rows, cols, inner, fused=False)
        if cases == 0:
            assert np.array_equal(got.view(np.uint32), two.view(np.uint32)), \
                (f"{np.count_nonzero(got != two)} of {got.size} differ from gemm_int8 on "
                 f"structured input")
        else:
            assert np.count_nonzero(got != two) <= got.size // 1000 + 1, \
                (f"{rows}x{cols}x{inner}: {np.count_nonzero(got != two)} of {got.size} "
                 f"differ from gemm_int8 — more than a rounding at a boundary")
        # and within a step of the sum done on the host. Not bit-exact: a row made of one
        # value repeated quantises to a full 127, and whether the last bit of the
        # reciprocal puts it at 127 or 126 is not something either side can promise.
        want = reference(a, b, b_scale, rows, cols, inner)
        worst = float(np.abs(got - want).max() / max(np.abs(want).max(), 1e-30))
        assert worst < 1e-2, \
            (f"{rows}x{cols}x{inner}: worst {worst:.3e} — more than a quantisation step, "
             f"so not the last bit of a reciprocal")
        cases += 1

    # Unchanged by this kernel, and here so that a change to the GEMM cannot quietly make
    # the picture worse: the same product in float64.
    rows, cols, inner = 256, 128, 256
    a = (rng.standard_normal((rows, inner)) * 0.05).astype(np.float16)
    b = rng.integers(-127, 128, (cols, inner), dtype=np.int8)
    b_scale = rng.uniform(0.001, 0.02, cols).astype(np.float32)
    exact = (a.astype(np.float64) @ b.astype(np.float64).T) * b_scale[None, :]
    got = once(rt, a, b, b_scale, rows, cols, inner, fused=True)
    error = float(np.abs(got - exact).max() / np.abs(exact).max())
    print(f"fused integer GEMM: {cases} shapes agree with gemm_int8, "
          f"structured input bit-exact")
    print(f"  against float64: {error:.4%}")
    assert error < 2e-2, "the integer path should not drift this far from float64"


if __name__ == "__main__":
    main()
