#!/usr/bin/env python3
"""quantize_row.comp against the host's own quantiser, value for value.

The integer path cannot take a float activation, so before any of it can go into a frame
the activations have to be put on its grid, and `notes/phase23-integer-weights.md` is the
note that says the shape of that job is the whole question: one grid per tensor rounds
21.5 % of a level's non-zero values away, one per row does not.

So this checks exactly what the host reference (`int8_quant.quantise(a, axis=1)`)
produces — the packed bytes, the per-row scales, and the rounding — including the two
edges that only show up in a frame: a row that is entirely zero, and more rows than a
dispatch's x extent can hold.

Values are made in half first, because that is what the shader reads: the host side
quantises the half's own value, not some float that was never representable.
"""
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres as X
import int8_quant

FAILURES = []


def check(name, ok, detail=""):
    print(f"  [{'ok  ' if ok else 'FAIL'}] {name}{'  ' + detail if detail else ''}", flush=True)
    if not ok:
        FAILURES.append(name)


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(3)
    cases = 0

    def one(values, label):
        """`values` float32 already representable in half; returns the number checked."""
        nonlocal cases
        half = values.astype(np.float16)
        wide = half.astype(np.float32)
        rows, inner = wide.shape
        source = rt.buffer(rows * inner, np.float16)
        packed = rt.buffer(rows * inner, np.int8)
        scale = rt.buffer(rows, np.float32)
        X.host_write(source, half)
        X.host_write(packed, np.full(rows * inner, 0, np.int8))
        X.host_write(scale, np.full(rows, np.nan, np.float32))
        rt.begin()
        rt.quantize_row(source, packed, scale, rows, inner)
        rt.submit()
        got_packed = X.host_view(packed, np.int8, (rows, inner)).copy()
        got_scale = X.host_view(scale, np.float32, (rows,)).copy()
        want_packed, want_scale = int8_quant.quantise(wide, 1)

        # The device's `top / 127.0` is a reciprocal multiply and lands one ulp below the
        # correctly-rounded quotient on some rows. That is a fact about the division and
        # not something to paper over on either side, so what is demanded is bounded
        # rather than exact: the grid may be a ulp finer, a value may fall one step
        # either side of the host's when it sits on the boundary that ulp moves, and the
        # reconstruction has to stay inside one step of the value it replaced.
        ulps = np.abs(got_scale.view(np.int32) - want_scale.view(np.int32))
        # Reconstructed in double: a half step is the bound, and comparing in the
        # activations' own 32 bits would spend part of it on the product's rounding.
        step = got_packed.astype(np.float64) * got_scale.astype(np.float64)[:, None]
        # Half a step, plus one ulp of the quotient that was rounded: the quotient is
        # formed in the activations' own 32 bits and reaches 128, so its ulp is 2^-16 and
        # a value within that of a boundary can round the way the boundary says.
        limit = 0.5 + np.float64(2.0 ** -16)
        within = np.abs(step - wide.astype(np.float64)) <= (
            got_scale.astype(np.float64)[:, None] * limit)
        ok_scale = int(ulps.max()) <= 1
        ok_packed = int(np.abs(got_packed.astype(np.int32)
                               - want_packed.astype(np.int32)).max()) <= 1
        ok_step = bool(within.all())
        worst = float(np.max(np.abs(step - wide) / got_scale[:, None]))
        check(f"{label} {rows}x{inner}", ok_scale and ok_packed and ok_step,
              f"scales within {int(ulps.max())} ulp ({int(np.count_nonzero(ulps))} of {rows} rows),"
              f" {int(np.count_nonzero(got_packed != want_packed))} packed values off by one,"
              f" worst {worst:.6f} of a step, within one: {ok_step}"
              f" (NaN {int(np.count_nonzero(np.isnan(step)))})")
        for buf in (source, packed, scale):
            buf.free()
        cases += 1

    # A wide dynamic range within each row, which is the case that kills a per-tensor grid.
    one(rng.standard_normal((32, 4096)).astype(np.float32)
        * (10.0 ** rng.uniform(-3, 3, (32, 1))), "wide range")
    one(rng.standard_normal((96, 1024)).astype(np.float32) * 0.05, "plain")
    one(rng.standard_normal((1, 16)).astype(np.float32), "one row")

    # A row that is entirely zero: a scale of 1.0 and zeros, not a division by zero.
    zeros = rng.standard_normal((8, 256)).astype(np.float32)
    zeros[3, :] = 0.0
    one(zeros, "with an empty row")

    # More rows than one dispatch's x extent: the shader has to use y.
    one(rng.standard_normal((70000, 16)).astype(np.float32), "past 65535 rows")

    print(f"\nactivation quantiser: {cases} cases against int8_quant.quantise")
    if FAILURES:
        print(f"  {len(FAILURES)} failed: {FAILURES}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
