#!/usr/bin/env python3
"""The 32x32 register block against the 16x32 one.

The resident GEMM is built twice — `gemm_tiled.spv` holding a 16x32 block of the output
in registers and `gemm_tiled32.spv` a 32x32 one — and libxmx picks between them by
shape: the wider block where M and N are both whole blocks of it, the narrower one
otherwise. Both are the hardware's own 8x8 tiles, and each row's sums and each K step
are its own, so on identical inputs the output has to match byte for byte whichever
block computed it.

What this file is really guarding against is the grid: a block is only correct with the
dispatch that divides the extent by *that* block, and a routing that picks the wider
kernel while dividing by the narrower one writes a quarter of the output and leaves the
rest untouched. So every case checks three things — nothing past M rows written, nothing
left unwritten, and the two blocks agreeing bit for bit — and it also checks the
routing counter, so a shape that silently stops taking the wider block is a failure and
not an invisible slowdown.

Shapes whose M is not a whole 32 rows are the other half: they must keep the 16x32
block even with the wider one enabled, which is the whole reason both builds ship.
"""
import numpy as np
import xmxres as X

GUARD = 64
FILL16 = np.array([0x7E5A], np.uint16).view(np.float16)[0]
FILL32 = np.array([0x7FC0DEAD], np.uint32).view(np.float32)[0]

# (rows, cols, inner, batch): the bottleneck's and the window block's shapes, a batch of
# heads as the attention computes them, and the two that must stay on the narrower block.
# 32 rows is not in either list: `small` sends a GEMM of 32 rows or fewer to the staged
# kernel's own 32-row build, which is a third block and not this test's subject.
ELIGIBLE = ((64, 64, 32, 1), (64, 32, 128, 1), (96, 96, 32, 1), (128, 128, 64, 1),
            (256, 128, 32, 1), (64, 64, 32, 8), (192, 32, 64, 1), (128, 96, 128, 1))
INELIGIBLE = ((16, 64, 32, 1), (48, 128, 64, 1), (80, 96, 32, 1))


def fill(dtype):
    return FILL16 if np.dtype(dtype) == np.float16 else FILL32


def filled(values, dtype):
    bits = np.uint16 if np.dtype(dtype) == np.float16 else np.uint32
    return np.asarray(values).view(bits) == np.asarray(fill(dtype)).view(bits)


def one(rt, rng, rows, cols, inner, batch, name, dtype, kw):
    """Run one shape on both blocks and return the two outputs, plus which block ran."""
    total = rows * cols * batch
    a = rt.buffer(rows * inner * batch, np.float16)
    b = rt.buffer(inner * cols * batch, np.float16)
    out = rt.buffer(total + GUARD, dtype)
    X.host_write(a, rng.normal(0, 2.0, rows * inner * batch).astype(np.float16))
    X.host_write(b, rng.normal(0, 0.3, inner * cols * batch).astype(np.float16))
    results = []
    ran = []
    try:
        for wide in (0, 1):
            if rt.lib.xmx_tiled32(wide) != 0:
                raise X.failure(rt.lib, "xmx_tiled32")
            X.host_write(out, np.full(total + GUARD, fill(dtype), dtype))
            before = rt.lib.xmx_tiled32_calls()
            rt.begin()
            rt.gemm(a, b, out, rows, cols, inner, batch=batch, **kw)
            rt.submit()
            ran.append(rt.lib.xmx_tiled32_calls() - before)
            got = X.host_view(out, dtype)
            assert filled(got[total:], dtype).all(), f"{name}: written past M rows"
            assert not filled(got[:total], dtype).any(), f"{name}: output left unwritten"
            results.append(got[:total].copy())
        return results, ran
    finally:
        for buf in (a, b, out):
            buf.free()


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(3232)
    variants = [("plain", np.float32, {}),
                ("transposed", np.float32, {"transpose_b": True}),
                ("e4m3", np.float16, {"epilogue": X.EPI_E4M3, "narrow": True}),
                ("gate e4m3", np.float16, {"epilogue": X.EPI_GATE_E4M3, "narrow": True})]
    cases = 0
    for rows, cols, inner, batch in ELIGIBLE + INELIGIBLE:
        eligible = rows % 32 == 0
        for name, dtype, kw in variants:
            outputs, ran = one(rt, rng, rows, cols, inner, batch, name, dtype, kw)
            assert ran[0] == 0, f"{name} {rows}x{cols}x{inner}: the 16x32 block was not used"
            assert ran[1] == int(eligible), (
                f"{name} {rows}x{cols}x{inner}: the 32x32 block ran {ran[1]} times, "
                f"expected {int(eligible)}")
            reference = outputs[0].view(np.uint8)
            got = outputs[1].view(np.uint8)
            if not np.array_equal(got, reference):
                differ = np.flatnonzero(got != reference).size
                raise AssertionError(f"{name} {rows}x{cols}x{inner} batch {batch}: "
                                     f"{differ} bytes differ from the 16x32 block")
            cases += 1
    rt.lib.xmx_tiled32(1)
    print(f"register-tiled GEMM: {cases} cases bit-identical between the 16x32 and 32x32 "
          f"blocks, nothing written past M, the wider block taken only where the shape is "
          f"a whole block of it")


if __name__ == "__main__":
    main()
