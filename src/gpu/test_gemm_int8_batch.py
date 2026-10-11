#!/usr/bin/env python3
"""The grouped integer GEMM against the same groups done one at a time.

`xmx_rec_gemm_int8_batched` exists because the grouped feed-forward's four products
run as 104 dispatches on the float path and could not run as fewer on the integer
one: `gemm_staged_int8.comp` had nowhere to put a group index. It now takes the
group from `gl_WorkGroupID.z` and its row strides from past the 128 push bytes every
Vulkan device owes, so one dispatch covers every group.

What has to be true is that the group index changes nothing about the arithmetic:
`batch` groups in one dispatch must give exactly the bytes that `batch` separate
products give, whether the groups share their activations — the branched feed-forward
broadcasts A, `sa == 0` — or each take a column slice of a wider buffer, which is how
the split feed-forward's groups sit. Both are tried here, against integer arithmetic
done exactly in numpy to begin with.
"""
import numpy as np
import xmxres as X


def main():
    rt = X.Runtime()
    if not hasattr(rt.lib, "xmx_rec_gemm_int8_batched"):
        print("batched integer GEMM: skipped, the library has no such recorder")
        return
    rng = np.random.default_rng(11)
    cases = 0
    # cols a multiple of 32 and inner of 64, which is the integer GEMM's gate; rows
    # deliberately not a multiple of the block's, so the partial last block is tried.
    for rows, cols, inner, groups in ((64, 32, 64, 4), (128, 128, 256, 2),
                                      (100, 96, 128, 3), (64, 256, 64, 4),
                                      (256, 64, 256, 2), (70, 32, 128, 5)):
        # `shared` is the mode the grouped feed-forward wants — one quantise pass, one
        # scale per row, every group reading it — and `per group` the other, which the
        # kernel has to support because a group's rows may not be a whole activation.
        for broadcast, shared in ((True, True), (False, False), (False, True)):
            wide = groups * inner if not broadcast else inner
            a = rng.integers(-127, 128, (rows, wide), dtype=np.int8)
            weight = [rng.integers(-127, 128, (cols, inner), dtype=np.int8)
                      for _ in range(groups)]
            # One scale per row of A per group when the groups take their own rows, and
            # per row when they share them; one per weight column per group either way.
            a_scale = rng.uniform(0.001, 0.02,
                                  rows if shared else rows * groups).astype(np.float32)
            scale_stride = 0 if shared else rows
            b_scale = rng.uniform(0.001, 0.02, (groups, cols)).astype(np.float32)
            flat_b = np.concatenate([w.reshape(-1) for w in weight])
            strides = (0 if broadcast else inner, cols * inner, cols)
            leading = (0 if broadcast else wide, 0, groups * cols)
            buffers = [rt.buffer(a.size, np.int8), rt.buffer(flat_b.size, np.int8),
                       rt.buffer(rows * groups * cols + 64, np.float32),
                       rt.buffer(a_scale.size, np.float32),
                       rt.buffer(b_scale.size, np.float32),
                       rt.buffer(cols * inner, np.int8), rt.buffer(rows * cols, np.float32),
                       rt.buffer(cols, np.float32)]
            A, B, C, SA, SB, one_b, one_c, one_sb = buffers
            try:
                X.host_write(A, a)
                X.host_write(B, flat_b)
                X.host_write(SA, a_scale)
                X.host_write(SB, b_scale.reshape(-1))

                # The groups in one dispatch.
                X.host_write(C, np.full(C.nbytes // 4, np.nan, np.float32))
                rt.begin()
                rt.gemm_int8_batched(A, B, C, SA, SB, rows, cols, inner, batch=groups,
                                     strides=strides, leading=leading,
                                     scale_stride=scale_stride)
                rt.submit()
                got = X.host_view(C)[:rows * groups * cols].reshape(rows, groups * cols)
                assert np.isnan(X.host_view(C)[rows * groups * cols:]).all(), \
                    "written past the output"

                # The same groups one at a time, each from buffers of its own.
                want = np.empty_like(got)
                for g in range(groups):
                    X.host_write(one_b, weight[g])
                    X.host_write(one_sb, b_scale[g])
                    X.host_write(one_c, np.full(rows * cols, np.nan, np.float32))
                    slice_a = a if broadcast else a[:, g * inner:(g + 1) * inner]
                    rows_a = rt.buffer(slice_a.size, np.int8)
                    scale_a = rt.buffer(rows, np.float32)
                    try:
                        X.host_write(rows_a, np.ascontiguousarray(slice_a))
                        X.host_write(scale_a, a_scale[g * rows:(g + 1) * rows]
                                     if not shared else a_scale)
                        rt.begin()
                        rt.gemm_int8(rows_a, one_b, one_c, scale_a, one_sb,
                                     rows, cols, inner)
                        rt.submit()
                        want[:, g * cols:(g + 1) * cols] = \
                            X.host_view(one_c)[:rows * cols].reshape(rows, cols)
                    finally:
                        rows_a.free()
                        scale_a.free()

                assert np.array_equal(got.view(np.uint32), want.view(np.uint32)), (
                    f"{rows}x{cols}x{inner} x{groups} broadcast={broadcast} shared={shared}: "
                    f"{np.count_nonzero(got != want)} elements differ")

                # And that those bytes are the ones exact integer arithmetic gives.
                for g in range(groups):
                    slice_a = a if broadcast else a[:, g * inner:(g + 1) * inner]
                    exact = slice_a.astype(np.int64) @ weight[g].astype(np.int64).T
                    assert np.abs(exact).max() < 1 << 24, "the accumulator must stay exact"
                    scale_row = (a_scale[g * rows:(g + 1) * rows] if not shared
                                 else a_scale)[:, None]
                    exact_want = (exact.astype(np.float32) * scale_row) * b_scale[g][None, :]
                    assert np.array_equal(
                        got[:, g * cols:(g + 1) * cols].view(np.uint32),
                        exact_want.astype(np.float32).view(np.uint32)), \
                        f"group {g} disagrees with exact integer arithmetic"
                cases += 1
            finally:
                for buf in buffers:
                    buf.free()
    print(f"batched integer GEMM: {cases} cases bit-exact against one dispatch a group")


if __name__ == "__main__":
    main()
