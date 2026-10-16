#!/usr/bin/env python3
"""The SYCL quantize_row translation, gated against the SHIPPED numpy contract.

Authority = int8_quant.quantise (exactly what src/gpu/test_quantize_row.py uses), with
the senior's BOUNDED criteria — not bit-exact — because the same "device division lands
one ulp from the correctly-rounded quotient" fact is what they bound:

  * scale within 1 ulp of numpy's
  * packed value within 1 of numpy's
  * the reconstruction stays within half a step (+ one ulp of the quotient)

The C++ host reference in the probe had its own rounding bug (nearbyint(38.5)=39); this
file is the real gate. Reads the qr_<case>.bin dumps the SYCL probe wrote.

gather (flag 0x400000): the kernel reads the image at (y,x) reconstructed from the
window/token index — the same math as quantize_row.comp — so the golden must gather the
same way, not reshape contiguously.
"""
import pathlib
import sys
import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[3]   # src/bench/sycl -> repo root
sys.path.insert(0, str(ROOT / "src" / "gpu"))
import int8_quant
HERE = pathlib.Path(__file__).resolve().parent


def e4m3_decode(c):
    exp, man = (c >> 3) & 15, c & 7
    v = man / 8.0 * 2.0 ** -6 if exp == 0 else (1.0 + man / 8.0) * 2.0 ** (exp - 7)
    return -v if (c & 0x80) else v
E4M3 = np.array([e4m3_decode(c) for c in range(256)], np.float32)


def load(fn):
    raw = fn.read_bytes()
    m, k, flags, e4m3, src_bytes = np.frombuffer(raw[:20], np.uint32)
    off = 20
    src = np.frombuffer(raw[off:off + int(src_bytes)], np.uint8); off += int(src_bytes)
    packed = np.frombuffer(raw[off:off + m * k], np.int8); off += m * k
    scale = np.frombuffer(raw[off:off + m * 4], np.float32)
    return int(m), int(k), int(flags), bool(e4m3), src, packed, scale


def golden_vals(m, k, flags, e4m3, src):
    """The float32 matrix each output row should quantise, reproducing the kernel's reads."""
    if e4m3:
        return E4M3[src[:m * k].astype(np.uint16)].astype(np.float32).reshape(m, k)
    if flags & 0x400000:
        # gather: src is the whole image (image_h*image_w*k halves). The kernel's held-row
        # -> (y,x) math mirrors quantize_row.comp; reconstruct the gathered m x k.
        img = src.view(np.float16).astype(np.float32)
        # image_h*image_w*k = len; but we don't know h,w here — the probe used a square-ish
        # image. Recover from the probe's fixed case: 448x768, window_cols=8, pad=(2,3).
        image_h, image_w, window_cols, pad_top, pad_left = 448, 768, 8, 2, 3
        size = 8
        vals = np.zeros((m, k), np.float32)
        for row in range(m):
            token = row % (size * size); window = row // (size * size)
            y = (window // window_cols) * size + token // size - pad_top
            x = (window % window_cols) * size + token % size - pad_left
            if 0 <= y < image_h and 0 <= x < image_w:
                vals[row] = img[(y * image_w + x) * k:(y * image_w + x) * k + k]
        return vals
    return src.view(np.float16).astype(np.float32)[:m * k].reshape(m, k)


def judge(name, fn):
    m, k, flags, e4m3, src, got_packed, got_scale = load(fn)
    vals = golden_vals(m, k, flags, e4m3, src)
    want_packed, want_scale = int8_quant.quantise(vals, 1)
    gp = got_packed.reshape(m, k)

    ulps = np.abs(got_scale.view(np.int32) - want_scale.view(np.int32))
    step = gp.astype(np.float64) * got_scale.astype(np.float64)[:, None]
    limit = 0.5 + np.float64(2.0 ** -16)
    within = np.abs(step - vals.astype(np.float64)) <= got_scale.astype(np.float64)[:, None] * limit
    ok_scale = int(ulps.max()) <= 1
    d = np.abs(gp.astype(np.int32) - want_packed.astype(np.int32))
    ok_packed = int(d.max()) <= 1
    ok_step = bool(within.all())
    worst = float(np.max(np.abs(step - vals) / got_scale[:, None]))
    ok = ok_scale and ok_packed and ok_step
    print(f"  [{'ok  ' if ok else 'FAIL'}] {name}: scale<=1ulp(max {int(ulps.max())}, "
          f"{int(np.count_nonzero(ulps))}/{m}), packed<=1(max {int(d.max())}, "
          f"{int((gp!=want_packed).sum())}/{m*k}), within-one {ok_step} (worst {worst:.5f})", flush=True)
    return ok


def main():
    bins = sorted(HERE.glob("qr_*.bin"))
    if not bins:
        print("no qr_*.bin dumps — run the SYCL probe first"); return 1
    allok = all(judge(b.stem[3:], b) for b in bins)
    print(f"\nSYCL quantize_row vs numpy contract: {'ALL OK' if allok else 'FAILURES'}")
    return 0 if allok else 1


if __name__ == "__main__":
    sys.exit(main())
