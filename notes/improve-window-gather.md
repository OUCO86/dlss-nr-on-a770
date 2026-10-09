# The window gather moved into the quantiser

2026-10-10. `notes/improve-int8-a770.md`'s last section asked for this: a window block's
QKV projection on the integer path was paying `partition` purely to feed `quantize_row`.
This is the note that says what it was worth.

## What the graph was doing

The float path folds a window block's partition into the QKV projection's own loads
(`gemm_staged.comp`, bit 0x400000): the shifted-window gather happens where the operand is
read, so no copy ever exists. `gemm_staged_int8` has no epilogue, so the integer path had
nowhere to put it, and recorded a pass instead:

```
partition   image -> win16          (read the image, write it back in window order)
quantize    win16 -> aq + ascale    (read the copy back, grid each row)
gemm_int8_qkv                       (the projection)
```

The pass existed only to feed the next one. What it cost, on a real 768x448 frame, device
timestamps by kind (`work/pass_time.py`):

| kind | ms | n | GB |
|---|---|---|---|
| `partition` | **3.06** | 52 | 0.17 |

Fifty-two dispatches, 3.06 ms, at 56 GB/s — a gather is a poor reader, which is most of
why the pass was that expensive for the bytes it moved.

## What it does now

`quantize_row.comp` grew a gather mode, bit 0x400000 of `flags`: the row's words come from the
token's pixel in the image instead of from a copy. `xmx_rec_quant_window` records it and
`Runtime.quantize_window` calls it. Two passes became one.

The index is `partition`'s own, unchanged:

```
token  = row % 64                     window = row / 64
y      = (window / across) * 8 + token / 8 - pad_top
x      = (window % across) * 8 + token % 8 - pad_left
outside -> zero, as the partition wrote
```

A token's words are contiguous in the image because its channels are, so the 16-byte loads the
quantiser already issued still line up; `channels % 64 == 0` — the integer path's own gate —
keeps them aligned. The one case left unfused is a float32 image: `partition` rounds it to half
on the way out, and that rounding is the pass's, not the quantiser's.

## What it is worth

`work/fuse_ab.py`, three rounds of each spelling, alternating, medians:

| | fuse OFF | fuse ON | |
|---|---|---|---|
| passes | 756 | 600 | −156 |
| `partition` | 3.06 ms / 52 | 0 | gone |
| **device time a frame** | **31.60 ms** | **27.23 ms** | **−4.37 ms (−13.8 %)** |

The three runs of each spelling agree to within 0.03 ms, so that gap is not noise. It is also
bigger than the 3.06 ms the pass was charged with, which is the point of measuring a whole
frame rather than a pass: the pass's cost included its own write, and the read it enabled was
charged to the quantiser that made it.

## What it does not change

`work/fuse_equiv.py` renders the real captured frame both ways and compares the outputs:

```
768x448 x 3 channels, 1032192 values
byte for byte identical  (0 values differ, worst 0.000000 of 255)
```

Not a tolerance — identical. The gather reads the same half `partition` wrote, so the row's
peak, its scale and every packed byte have to come out the same, and they do. Nothing about the
picture moves; only a trip to memory goes away.

`src/gpu/test_quantize_window.py` checks the same thing at the kernel level over six shapes,
including both shifted origins and an extent that is not a whole number of windows, so the
padded rows that hang off the right and the bottom are covered as well as the left and top.

## How to measure it again

```
python work/fuse_ab.py 3                                  # 交替，中位数
NR_INT8_WINDOW_FUSE=0 python work/fuse_equiv.py work/_fuse_off
NR_INT8_WINDOW_FUSE=1 python work/fuse_equiv.py work/_fuse_on
python work/fuse_equiv.py compare work/_fuse_off work/_fuse_on
```

Do not run these while a game session is live: they load the device and they open
`work/nr_daemon.log`. Wait for the session to end, or sample the live log instead.
