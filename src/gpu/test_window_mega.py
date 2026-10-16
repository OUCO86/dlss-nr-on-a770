#!/usr/bin/env python3
"""window_mega — a whole 32-channel window block, feed-forward folded in.

The reference chain is what the graph runs for an l1 sequential block (nr_resident
:795-798 then :880): `e4m3_half(image, value16)` (the input publish the
feed-forward reads), `ffn_fused(value16, expand, branch, sffn, pixels, 32, 128,
skip=image, cosine=ffn_cos)` — which leaves sffn float32 and UNPUBLISHED — then
`window_block(sffn, qkv, projection, target, ...)`. The megakernel takes the
block's input `image` (s.value) and must write the same `target`.

Gate (user's call, 2026-10-16): the fold re-splits rows (a window is 64 tokens,
not 256 rows), so the fp32 accumulation can re-associate by a ulp under a
different register budget — the compiler-contraction class this codebase already
documents. So: the half/e4m3 paths (where the publish absorbs a ulp) must be
bit-exact, 0 diffs; the float32 path allows at most 2 ulps per element, measured
as float32 bit distance (within a sign, one bit = one ulp). The final arbiter is
in-game observation, which this gate exists to reach.
"""
import numpy as np
import xmxres as X

GUARD = 64
FILL16 = np.array([0x7E5A], np.uint16).view(np.float16)[0]
FILL32 = np.array([0x7FC0DEAD], np.uint32).view(np.float32)[0]
MAX_ULP = 2                       # the bounded gate for the float32 output


def fill(dtype):
    return FILL16 if np.dtype(dtype) == np.float16 else FILL32


def filled(values, dtype):
    bits = np.uint16 if np.dtype(dtype) == np.float16 else np.uint32
    return np.asarray(values).view(bits) == np.asarray(fill(dtype)).view(bits)


def ulp_report(w, g, dtype):
    """(exact, worst_ulp, n_bad): bit distance per element, sign-aware."""
    if np.dtype(dtype) == np.float16:
        wb, gb = w.view(np.uint16).astype(np.int64), g.view(np.uint16).astype(np.int64)
    else:
        wb, gb = w.view(np.uint32).astype(np.int64), g.view(np.uint32).astype(np.int64)
    same_sign = np.signbit(w) == np.signbit(g)
    dist = np.abs(wb - gb)
    dist = np.where(same_sign, dist, np.where(w == g, 0, 1 << 30))
    return bool((dist == 0).all()), int(dist[same_sign].max(initial=0)), \
        int(((dist > MAX_ULP) | ~same_sign & (w != g)).sum())


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(77)
    cases, fails, notes = 0, [], []
    for height, width in ((16, 16), (24, 40), (32, 32)):
        for origin in ((0, 0), (-4, -4)):
            ph, pw, (top, left) = rt.window_extent(height, width, origin, 8)
            windows, rows, pixels = (ph // 8) * (pw // 8), ph * pw, height * width
            buffers = []

            def alloc(n, dtype):
                b = rt.buffer(n, dtype)
                buffers.append(b)
                return b

            image = alloc(pixels * 32, np.float32)
            value16 = alloc(pixels * 32, np.float16)      # the graph's e4m3_half of the input
            qkv = alloc(32 * 96, np.float16)
            projection = alloc(32 * 32, np.float16)
            bias = alloc(64 * 64, np.float32)
            cosine = alloc(32, np.float32)
            scale = alloc(1, np.float32)
            expand = alloc(32 * 128, np.float16)
            branch = alloc(128 * 32, np.float16)
            ffn_cos = alloc(32, np.float32)
            sffn = alloc(pixels * 32 + GUARD, np.float32)
            attended = alloc(rows * 32, np.float16)
            q = alloc(rows * 32, np.float16)
            k = alloc(rows * 32, np.float16)
            v = alloc(rows * 32, np.float16)

            X.host_write(image, rng.normal(0, 3.0, pixels * 32).astype(np.float32))
            X.host_write(qkv, rng.normal(0, 0.2, 32 * 96).astype(np.float16))
            X.host_write(projection, rng.normal(0, 0.1, 32 * 32).astype(np.float16))
            X.host_write(bias, rng.normal(0, 0.5, 64 * 64).astype(np.float32))
            X.host_write(cosine, rng.uniform(-1.5, 1.5, 32).astype(np.float32))
            X.host_write(scale, np.array([0.177], np.float32))
            X.host_write(expand, rng.normal(0, 0.25, 32 * 128).astype(np.float16))
            X.host_write(branch, rng.normal(0, 0.1, 128 * 32).astype(np.float16))
            X.host_write(ffn_cos, rng.uniform(-1.5, 1.5, 32).astype(np.float32))

            for epilogue, narrow in ((0, False), (X.EPI_E4M3, True)):
                dtype = np.float16 if narrow else np.float32
                want = alloc(pixels * 32 + GUARD, dtype)
                got = alloc(pixels * 32 + GUARD, dtype)
                for b in (want, got):
                    X.host_write(b, np.full(pixels * 32 + GUARD, fill(dtype), dtype))
                rt.begin()
                # reference: what record_feed_forward does for an l1 sequential block
                # (nr_resident:753-756 then :795-798) — e4m3_half the input, then the
                # fused feed-forward reading the half, skip the raw float32 source,
                # leaving sffn float32 and UNPUBLISHED. Then the attention half reads sffn.
                rt.e4m3_half(image, value16, pixels * 32)
                rt.ffn_fused(value16, expand, branch, sffn, pixels, 32, 128,
                             skip=image, cosine=ffn_cos)
                rt.window_block(sffn, qkv, projection, want, bias, cosine, scale,
                                height, width, origin, epilogue=epilogue, narrow=narrow,
                                image_half=False)
                # the megakernel, same block from the same input.
                rt.window_mega(image, qkv, projection, got, bias, cosine, scale,
                               expand, branch, ffn_cos, height, width, origin,
                               epilogue=epilogue, narrow=narrow, image_half=False)
                rt.submit()
                n = pixels * 32
                w = X.host_view(want, dtype)[:n]
                g = X.host_view(got, dtype)[:n]
                exact, worst, bad = ulp_report(w, g, dtype)
                label = f"{height}x{width} origin {origin} epi {epilogue} narrow {narrow}"
                if narrow:
                    ok = exact                     # the half/e4m3 path: bit-exact
                else:
                    ok = bad == 0 and worst <= MAX_ULP   # float32: bounded-ulp gate
                ok = ok and filled(X.host_view(got, dtype)[n:], dtype).all() \
                     and not filled(g, dtype).any()
                if not ok:
                    fails.append(f"{label}: exact={exact} worst_ulp={worst} bad={bad}")
                elif not exact:
                    notes.append(f"{label}: {worst} ulp max (within gate)")
                cases += 1
                for b in (want, got):
                    b.free()
            for b in buffers:
                b.free()
    print(f"window_mega: {cases} cases against ffn_fused+window_block; "
          f"{'GATE PASSED' if not fails else 'FAILURES: ' + str(fails)}")
    for note in notes:
        print(f"  note: {note}")
    return 1 if fails else 0


if __name__ == "__main__":
    raise SystemExit(main())
