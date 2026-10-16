#!/usr/bin/env python3
"""window_mega — a whole 32-channel window block, feed-forward folded in.

The reference chain is what the graph runs for an l1 sequential block (nr_resident
:795-798 then :880): `ffn_fused(image, expand, branch, sffn, pixels, 32, 128,
skip=image, cosine=ffn_cos)` — which leaves sffn float32 and UNPUBLISHED — then
`window_block(sffn, qkv, projection, target, ...)`. The megakernel takes the block's
input `image` (s.value) and must write the same `target`, byte for byte, with sffn
never leaving the workgroup.

Covers both window origins, the three publishes the graph uses (float32 target, half
target, E4M3-as-half), and a cropped window. Nothing outside the image may be written.
"""
import numpy as np
import xmxres as X

GUARD = 64
FILL16 = np.array([0x7E5A], np.uint16).view(np.float16)[0]
FILL32 = np.array([0x7FC0DEAD], np.uint32).view(np.float32)[0]


def fill(dtype):
    return FILL16 if np.dtype(dtype) == np.float16 else FILL32


def filled(values, dtype):
    bits = np.uint16 if np.dtype(dtype) == np.float16 else np.uint32
    return np.asarray(values).view(bits) == np.asarray(fill(dtype)).view(bits)


def main():
    rt = X.Runtime()
    rng = np.random.default_rng(77)
    cases, fails = 0, []
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
                # reference: the feed-forward into sffn (float32, unpublished), then the
                # attention half reading sffn — exactly the graph's two calls.
                rt.ffn_fused(image, expand, branch, sffn, pixels, 32, 128,
                             skip=image, cosine=ffn_cos)
                rt.window_block(sffn, qkv, projection, want, bias, cosine, scale,
                                height, width, origin, epilogue=epilogue, narrow=narrow,
                                image_half=False)
                # the megakernel, same block from the same input.
                rt.window_mega(image, qkv, projection, got, bias, cosine, scale,
                               expand, branch, ffn_cos, height, width, origin,
                               epilogue=epilogue, narrow=narrow, image_half=False)
                rt.submit()
                w = X.host_view(want, dtype)
                g = X.host_view(got, dtype)
                n = pixels * 32
                ndiff = int(np.count_nonzero(w[:n].view(np.uint16 if narrow else np.uint32)
                                             != g[:n].view(np.uint16 if narrow else np.uint32)))
                ok = ndiff == 0 and filled(g[n:], dtype).all() and not filled(g[:n], dtype).any()
                label = f"{height}x{width} origin {origin} epi {epilogue} narrow {narrow}"
                if not ok:
                    fails.append(f"{label}: {ndiff} differ")
                cases += 1
                for b in (want, got):
                    b.free()
            for b in buffers:
                b.free()
    print(f"window_mega: {cases} cases against ffn_fused+window_block; "
          f"{'ALL BIT-EXACT' if not fails else 'FAILURES: ' + str(fails)}")
    return 1 if fails else 0


if __name__ == "__main__":
    raise SystemExit(main())
