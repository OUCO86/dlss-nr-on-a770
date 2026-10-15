#!/usr/bin/env python3
"""quantize_row_e4m3 against quantize_row, on the same published values.

The claim C1b rests on: a value a producer published through `publish.glsl`'s e4m3()
is exactly representable in float16, so reading it from a byte container or a half
container decodes to the same float32, and the grid/peak/rounding come out bit-for-bit
identical — only the bytes the pass moves differ.

To test that without depending on any rounding implementation, the inputs are built
straight from the E4M3 code space: every value is one of the 254 finite codes decoded
(the same decode the shader does), so it is on the grid by construction. The half
container and the byte container then hold the identical float32, and the two device
paths must agree exactly. Also checked against the host quantiser.
"""
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import xmxres as X
import int8_quant

def e4m3_decode_code(c):
    """One 8-bit E4M3 code -> float32, matching quantize_row.comp's e4m3_decode."""
    exp, man = (c >> 3) & 15, c & 7
    if exp == 0:
        v = man / 8.0 * 2.0 ** -6            # subnormal: mant * 2^-9
    else:
        v = (1.0 + man / 8.0) * 2.0 ** (exp - 7)
    return -v if (c & 0x80) else v

# the finite code space (0x7f/0xff are NaN in this format)
CODES = np.array([c for c in range(256) if c not in (0x7F, 0xFF)], np.uint8)
GRID = np.array([e4m3_decode_code(int(c)) for c in CODES], np.float32)

FAILURES = []
def check(name, ok, detail=""):
    print(f"  [{'ok  ' if ok else 'FAIL'}] {name}{'  ' + detail if detail else ''}", flush=True)
    if not ok:
        FAILURES.append(name)

def main():
    rt = X.Runtime()
    rng = np.random.default_rng(11)
    for rows, inner in ((32, 128), (8160, 128), (1024, 256), (96, 64)):
        pick = rng.integers(0, CODES.size, (rows, inner))
        codes = CODES[pick]                    # the byte container
        pub = GRID[pick].astype(np.float32)    # the value each code stands for
        half = pub.astype(np.float16)          # the half container
        # 地基1, re-asserted on real grid values: fp16 holds every e4m3 code exactly
        check(f"{rows}x{inner} e4m3 value fits fp16 exactly",
              np.array_equal(half.astype(np.float32), pub))

        src_h = rt.buffer(rows * inner, np.float16); X.host_write(src_h, half)
        src_b = rt.buffer(rows * inner, np.uint8);  X.host_write(src_b, codes)
        pa = rt.buffer(rows * inner, np.int8);  sa = rt.buffer(rows, np.float32)
        pb = rt.buffer(rows * inner, np.int8);  sb = rt.buffer(rows, np.float32)
        for b in (pa, pb): X.host_write(b, np.full(rows * inner, 0, np.int8))
        for b in (sa, sb): X.host_write(b, np.full(rows, np.nan, np.float32))
        rt.begin()
        rt.quantize_row(src_h, pa, sa, rows, inner)
        rt.quantize_row_e4m3(src_b, pb, sb, rows, inner)
        rt.submit()
        wp, ws = X.host_view(pa, np.int8, (rows, inner)).copy(), X.host_view(sa, np.float32, (rows,)).copy()
        qp, qs = X.host_view(pb, np.int8, (rows, inner)).copy(), X.host_view(sb, np.float32, (rows,)).copy()
        check(f"{rows}x{inner} e4m3 path == half path (packed)", np.array_equal(wp, qp),
              f"{int((wp!=qp).sum())} differ")
        check(f"{rows}x{inner} e4m3 path == half path (scale)", np.array_equal(ws, qs),
              f"{int((ws!=qs).sum())} differ")
        want_p, want_s = int8_quant.quantise(pub, 1)
        tol = np.abs(qp.astype(np.int32) - want_p.astype(np.int32))
        check(f"{rows}x{inner} e4m3 path vs host quantise",
              (tol <= 1).all() and np.allclose(qs, want_s, rtol=2e-7, atol=0),
              f"max packed off {int(tol.max())}")
        for b in (src_h, src_b, pa, pb, sa, sb): b.free()

    print(f"\nquantize_row_e4m3: {'ALL OK' if not FAILURES else 'FAILURES: ' + str(FAILURES)}")
    return 1 if FAILURES else 0

if __name__ == "__main__":
    sys.exit(main())
