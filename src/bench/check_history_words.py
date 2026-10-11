#!/usr/bin/env python3
"""The history the device kept, taken back: raw words are not a frame to resample.

`History.keep(..., words=payload)` is how the daemon says "the device kept this
frame's prediction, so the host holds only the bytes the game sent". `take` then
hands those bytes back as `history_full`, which every caller reads as a flag —
`history is not None`, at three places — and never as a frame.

Except at one: `take` also offers to resample `previous` down to the network's
extent, and `previous` falls back to `self.words` when there is no output. The
words are one dimension of uint8. `resample` starts `height, width =
image.shape[:2]`, and on one dimension that is
`ValueError: not enough values to unpack (expected 2, got 1)`.

Whether it fires depends on what `payload` *is*, which is why it took a game to
find: a frame that crossed in the daemon's own buffer (Phase 2) is a NumPy
array, and one that crossed on the wire or in a slot is bytes or a memoryview.
`isinstance(previous, np.ndarray)` lets the first through and stops the other
two. Same daemon, same frame, one of them refuses every frame.

    python3 src/bench/check_history_words.py
"""
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src" / "bench"))
sys.path.insert(0, str(ROOT / "src" / "layer"))

import numpy as np                                           # noqa: E402
import nr_daemon                                             # noqa: E402

# 1920x1080 as the game sends it, and the network's extent at render_scale 0.4.
PIXELS = 1920 * 1080
SHAPE = (432, 768, 3)
KEY = ("shot",)


def attempt(label, payload):
    """Keep `payload` as the words, then take the history back."""
    history = nr_daemon.History()
    # Twice, because the first `take` has nothing behind it and returns early:
    # the resample is only reached on a frame whose history is already there.
    for _ in range(2):
        history.keep(KEY, None, SHAPE, None, words=payload)
        try:
            inner, full, pixels = history.take(KEY, SHAPE, 0.5, cut=0.1)
        except ValueError as error:
            print(f"  {label:<22} raised: {error}")
            return False
    ok = inner is None and full is not None
    print(f"  {label:<22} took it back: inner={inner is None and 'None' or 'a frame'}, "
          f"history_full={'set' if full is not None else 'None'} "
          f"{'OK' if ok else 'UNEXPECTED'}")
    return ok


def main():
    print("what the device kept, as the host holds it:")
    # What a frame on the wire or in a slot is.
    wire_ok = attempt("bytes (the wire)", bytes(4 * PIXELS))
    # What a frame in the daemon's own buffer is: the same bytes, as an array.
    buffer_ok = attempt("uint8 array (Phase 2)", np.zeros(4 * PIXELS, np.uint8))
    print()
    if wire_ok and buffer_ok:
        print("both ways take the history back; the words are never resampled")
        return 0
    print("FAILED: the two ways do not agree — see the note in this file")
    return 1


if __name__ == "__main__":
    sys.exit(main())
