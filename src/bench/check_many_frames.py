#!/usr/bin/env python3
"""Frame after frame, the way a game sends them, until one of them fails.

Every check written for Phase 2 sends a handful of frames — enough to say the
bytes arrived, not enough to say the daemon survives an evening. The game's log
showed 28 frames answered and 7407 refused with one message and no traceback,
which is a number no four-frame test was ever going to produce.

So this sends frames until one fails, or until it runs out. Same daemon, same
buffer, same pipe; the frames differ from each other the way a game's do. A
failure prints where it came from — the daemon says that once, for the first
frame of each kind.

    python3 src/bench/check_many_frames.py [frames] [mode]

`mode` is how the frame's bytes travel: `extmem` (the daemon's own buffer,
Phase 2), `shm` (a slot in the mapping), or `wire` (the pipe). The default is
`extmem`, which is the one the game was running.
"""
import ctypes
import json
import os
import pathlib
import struct
import sys
import tempfile
import threading
import time

ROOT = pathlib.Path(__file__).resolve().parents[2]
for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
    sys.path.insert(0, str(ROOT / sub))

os.environ["NR_EXTMEM"] = "1"
os.environ["NR_LAYER_PID"] = str(os.getpid())
# The postpass is on under the game (`nr_play*.bat` sets it) and it is a whole
# other way out of the frame: `RequestPass.finish` composes and encodes on the
# device and the host never holds the composed frame. Off, the daemon takes the
# host's path and the two do not share a line of the code that can fail.
os.environ["NR_POSTPASS"] = os.environ.get("NR_POSTPASS", "1")

import numpy as np                                           # noqa: E402
import live_rates                                            # noqa: E402
import nr_daemon                                             # noqa: E402
import nr_pipe                                               # noqa: E402
import xmxres                                                # noqa: E402

WIDTH, HEIGHT = 1920, 1080
ANSWER = 4 * WIDTH * HEIGHT
FORMAT_B8G8R8A8 = live_rates.FORMAT_B8G8R8A8
MAX_PIXELS = 1 << 22          # the daemon's own default, which is what the game gets
SLOT = 0

box = {}


def spy(args, backend):
    box["publish"](args, backend)
    box["sid"] = getattr(args, "extmem_sem", None)
    box["backend"] = backend


def connect_pipe(path):
    for _ in range(2000):
        try:
            return open(path, "r+b", buffering=0)
        except OSError:
            time.sleep(0.0005)
    raise RuntimeError(f"no pipe at {path}")


def round_trip(endpoint, data, want):
    with connect_pipe(endpoint) as pipe:
        view = memoryview(data)
        while view:
            view = view[pipe.write(view):]
        got = bytearray()
        while len(got) < want:
            piece = pipe.read(want - len(got))
            if not piece:
                raise RuntimeError(f"the daemon answered {len(got)} of {want} bytes")
            got += piece
    return bytes(got)


def ready(endpoint):
    try:
        open(endpoint, "r+b", buffering=0).close()
    except OSError:
        return False
    return True


def say(text):
    print(text, flush=True)


def drive(endpoint, frames, mode):
    code = 1
    try:
        while not ready(endpoint):
            time.sleep(0.1)
        mapping = nr_pipe.FrameMapping(endpoint, MAX_PIXELS)
        head = {"extmem": nr_daemon.MAGIC_EXTMEM,
                "masked": nr_daemon.MAGIC_EXTMEM_MASKED,
                "shm": nr_daemon.MAGIC_SHM,
                "wire": live_rates.MAGIC}[mode]
        masked = mode == "masked"
        sid = None
        view = None

        # The layer names a different slot each frame — `shm_turn++ % shm.slots` —
        # and a test that always asks for slot 0 is not asking the same question.
        turn = [0]

        def next_slot():
            slot = turn[0] % mapping.slots
            turn[0] += 1
            return slot

        def from_slot(header, slot, extra=b""):
            told = struct.unpack("<I", round_trip(endpoint, header + extra, 4))[0]
            if told != ANSWER:
                raise RuntimeError(f"the slot promises {told} bytes, not {ANSWER}")
            return bytes(mapping.answer(slot, told))

        def send(index):
            # A game holds still between frames far more than it moves, and that
            # is the other half of the daemon: a frame that barely moved keeps
            # its history, one that moved a lot is refused it. Frames that all
            # differ from each other - the easy kind to make - exercise only the
            # second, which is why a hundred of them can pass while a game that
            # stood still for a second took every frame down. NR_MF_STILL sends
            # the same frame every time.
            still = os.environ.get("NR_MF_STILL")
            payload = live_rates.frame(WIDTH, HEIGHT, 1 if still else index)
            if mode == "wire":
                return round_trip(endpoint, struct.pack("<4I", head, WIDTH, HEIGHT,
                                                        FORMAT_B8G8R8A8) + payload,
                                  ANSWER)
            if mode == "shm":
                slot = next_slot()
                mapping.request(slot, len(payload))[:] = payload
                return from_slot(struct.pack("<4I", head, WIDTH, HEIGHT,
                                             FORMAT_B8G8R8A8),
                                 slot, struct.pack("<I", slot))
            # extmem: the bytes go into the daemon's buffer, the semaphore says
            # they are there, and only the header goes on the wire.
            if sid is None:
                raise RuntimeError("no semaphore was ever offered")
            ctypes.memmove(view.ctypes.data, payload, len(payload))
            slot = next_slot()
            if masked:
                # The interface mask goes in the slot beside the frame, a byte a
                # pixel, which is where the daemon reads it from.
                # A band across the top, not the whole frame: a mask covering
                # everything is read as the scene holding still and dropped, which
                # is a different path from the one a HUD takes.
                band = np.zeros(WIDTH * HEIGHT, np.uint8)
                band[:WIDTH * (HEIGHT // 5)] = 255
                mapping.interface(slot, WIDTH * HEIGHT)[:] = band
            lib = xmxres._load()
            if lib.xmx_sem_signal(int(sid), index) != 0:
                raise RuntimeError("xmx_sem_signal")
            return from_slot(struct.pack("<4I", head, WIDTH, HEIGHT,
                                         FORMAT_B8G8R8A8),
                             slot, struct.pack("<I", slot) + struct.pack("<Q", index))

        # The first frame goes on the wire whatever the mode: it is what makes the
        # daemon offer the buffer, and there is nothing to write into before it has.
        say(f"sending {frames} frames, {mode}")
        round_trip(endpoint, struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                                         FORMAT_B8G8R8A8)
                   + live_rates.frame(WIDTH, HEIGHT, 0), ANSWER)
        if mode in ("extmem", "masked"):
            backend = box["backend"]
            sid = box.get("sid")
            if sid is None:
                say("FAILED: the daemon never offered a semaphore")
                return 1
            view = backend.extmem_view(ANSWER)

        done = 0
        for index in range(1, frames + 1):
            answer = send(index)
            if len(answer) != ANSWER:
                raise RuntimeError(f"frame {index} came back {len(answer)} bytes")
            done += 1
            if index % 10 == 0:
                say(f"  {done} frames answered")
        say(f"\nall {done} frames answered; nothing failed here")
        code = 0
    except Exception as error:
        import traceback
        traceback.print_exc()
        say(f"FAILED: {error!r}")
    finally:
        os._exit(code)
    return code


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    mode = sys.argv[2] if len(sys.argv) > 2 else "extmem"

    box["publish"] = nr_daemon._extmem_publish
    nr_daemon._extmem_publish = spy

    room = pathlib.Path(tempfile.mkdtemp(prefix="many-frames-"))
    settings = room / "settings.json"
    # The knobs the game is actually running, not a tidy subset of them. A test
    # that writes `temporal: 0` because a still frame is easier to compare is
    # testing a different daemon: the game runs temporal 1, hold 1, release 24,
    # and a history that is there is a whole branch this never enters.
    played = ROOT / "work" / "nr_settings.json"
    if played.exists():
        settings.write_text(played.read_text())
        print(f"settings: as the game plays them ({played})", flush=True)
    else:
        settings.write_text(json.dumps({"render_scale": 0.4, "int8": 1,
                                        "temporal": 1, "hold": 1, "release": 24}))
    endpoint = rf"\\.\pipe\nr_many_{os.getpid()}"
    threading.Thread(target=drive, daemon=True,
                     args=(endpoint, frames, mode)).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
