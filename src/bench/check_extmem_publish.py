#!/usr/bin/env python3
"""The offer itself: can the daemon hand the layer a buffer it can import?

`_extmem_publish` is the one step of Phase 2 that has to work before anything
else can: export a buffer and a semaphore, duplicate both handles into the
layer's process, and write them where the layer looks. Everything else fails
soft around it, so it is also the one step that can fail without a sign -
unless it raises, which is what it did once, and a missing import took the
daemon down and left the game waiting on a pipe nobody answered.

So this runs that one function, in the open, where its prints are visible and
an exception is an exception rather than a game that will not load. The
layer's pid is this process: duplicating a handle into yourself is the same
call, and the numbers it gives back are the ones a layer would import.

    python3 src/bench/check_extmem_publish.py
"""
import os
import pathlib
import sys
import types

ROOT = pathlib.Path(__file__).resolve().parents[2]
for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
    sys.path.insert(0, str(ROOT / sub))

# Read once, at construction, by everything that decides whether a buffer is
# exportable — as it is in the game.
os.environ["NR_EXTMEM"] = "1"
os.environ["NR_LAYER_PID"] = str(os.getpid())

import game_settings                                         # noqa: E402
import nr_daemon                                             # noqa: E402
import nr_frame                                              # noqa: E402
import nr_pipe                                               # noqa: E402

MAX_PIXELS = 1 << 22


def main():
    game_settings.apply()
    print(f"NR_EXTMEM={os.environ['NR_EXTMEM']}, NR_LAYER_PID={os.environ['NR_LAYER_PID']}")
    backend = nr_frame.ResidentBackend()
    mapping = nr_pipe.FrameMapping("nr_lop_publish", MAX_PIXELS)
    args = types.SimpleNamespace(max_pixels=MAX_PIXELS, mapping=mapping)
    try:
        nr_daemon._extmem_publish(args, backend)
        # Read while it is still open: the head is the whole point of the offer.
        head = bytes(mapping._map[:16])
    finally:
        mapping.close()
    flag = int.from_bytes(head[12:16], "little")
    if flag != 1:
        print("FAILED: the head says no handles were published")
        return 1
    print("the head carries the handles, which is what the layer looks for")
    return 0


if __name__ == "__main__":
    sys.exit(main())
