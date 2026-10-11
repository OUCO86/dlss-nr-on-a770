#!/usr/bin/env python3
"""Where the answer is read from, kept apart from how the frame got in.

The round-trip check (`check_extmem_roundtrip.py`) compares one frame whose
bytes came on the wire and whose answer came back on it against one whose bytes
came in the daemon's buffer and whose answer came back in a slot. Two things
move at once there: how the frame got in, and where the answer was read from.
Whatever they differ by could belong to either.

So this one holds the way out still. Every frame's answer is read out of the
same slot, and the question is only whether what put the frame's bytes in
changes it:

    A  the bytes on the wire, the answer on the wire   (the old way, both ways)
    B  the bytes in a slot, the answer in a slot       (MAGIC_SHM, both ways)
    C  the bytes in the buffer, the answer in a slot   (MAGIC_EXTMEM)

A against B is the slot's own doing: the same frame, the same answer, read out
of two places. B against C is Phase 2's: the same slot both times, and only
where the bytes came from is different.

    python3 src/bench/check_answer_where.py
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

import numpy as np                                           # noqa: E402
import live_rates                                            # noqa: E402
import nr_daemon                                             # noqa: E402
import nr_pipe                                               # noqa: E402
import xmxres                                                # noqa: E402

WIDTH, HEIGHT, SCALE = 1920, 1080, 0.4
PIXELS = WIDTH * HEIGHT
ANSWER = 4 * PIXELS
FORMAT_B8G8R8A8 = live_rates.FORMAT_B8G8R8A8
MAX_PIXELS = 1920 * 1200
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


def describe(one, other):
    left = np.frombuffer(one, np.uint8)
    right = np.frombuffer(other, np.uint8)
    differ = int((left != right).sum())
    biggest = int(np.abs(left.astype(int) - right.astype(int)).max())
    return f"{differ:6d} of {len(one)} bytes differ, largest {biggest}"


def shape_of(one, other):
    """Where two answers differ, as rows, columns and channels."""
    left = np.frombuffer(one, np.uint8)
    right = np.frombuffer(other, np.uint8)
    where = np.flatnonzero(left != right)
    if not where.size:
        return "  (nothing differs)"
    row = where // (WIDTH * 4)
    inside = where % (WIDTH * 4)
    column = inside // 4
    rows = np.unique(row)
    columns = np.unique(column)
    steps = np.unique(np.diff(np.sort(rows))) if rows.size > 1 else []
    return (f"    {rows.size} rows ({int(rows.min())}..{int(rows.max())}, "
            f"steps {list(map(int, steps[:6]))}), "
            f"{columns.size} columns ({int(columns.min())}..{int(columns.max())}, "
            f"steps {list(map(int, np.unique(np.diff(np.sort(columns)))[:6]))}), "
            f"channels {sorted(set(int(c % 4) for c in inside))}")


def say(text):
    print(text, flush=True)


def drive(endpoint):
    code = 1
    try:
        while not ready(endpoint):
            time.sleep(0.1)
        payload = live_rates.frame(WIDTH, HEIGHT, 1)
        head_wire = struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                                FORMAT_B8G8R8A8)
        head_shm = struct.pack("<4I", nr_daemon.MAGIC_SHM, WIDTH, HEIGHT,
                               FORMAT_B8G8R8A8)
        head_ext = struct.pack("<4I", nr_daemon.MAGIC_EXTMEM, WIDTH, HEIGHT,
                               FORMAT_B8G8R8A8)

        # One frame to settle the buffers, thrown away.
        round_trip(endpoint, head_wire + payload, ANSWER)

        def by_wire():
            return round_trip(endpoint, head_wire + payload, ANSWER)

        def from_slot(head, extra):
            told = struct.unpack("<I", round_trip(endpoint, head + extra, 4))[0]
            if told != ANSWER:
                raise RuntimeError(f"the slot promises {told} bytes, not {ANSWER}")
            return bytes(mapping.answer(SLOT, told))

        def by_shm():
            mapping.request(SLOT, len(payload))[:] = payload
            return from_slot(head_shm, struct.pack("<I", SLOT))

        # A. The old way, both ways.
        a1 = by_wire()
        a2 = by_wire()
        say(f"A wire in / wire out   {describe(a1, a2)}")

        # The mapping, opened as the layer opens it.
        global mapping
        mapping = nr_pipe.FrameMapping(endpoint, MAX_PIXELS)

        # B. The bytes in a slot, the answer in a slot: the answer's way out is
        #    the one C uses, and only where the bytes came from is still the old
        #    one. Whatever A and B differ by is the slot's, not Phase 2's.
        b1 = by_shm()
        b2 = by_shm()
        say(f"B slot in  / slot out   {describe(a1, b1)}")
        say(f"B repeat                {describe(b1, b2)}")
        say(shape_of(a1, b1))

        # C. The bytes in the daemon's buffer, the answer in the same slot.
        backend = box["backend"]
        sid = box.get("sid")
        if sid is None:
            say("FAILED: the daemon never offered a semaphore")
            return 1
        view = backend.extmem_view(len(payload))
        lib = xmxres._load()
        frame = [0]

        def by_extmem():
            frame[0] += 1
            ctypes.memmove(view.ctypes.data, payload, len(payload))
            # Whether the layer has to fence and flush a bar write before it
            # announces it. NR_RT_NOFENCE=1 leaves both out, which is the
            # question: the real layer is C, and if it needs them it has to be
            # the one that calls them.
            if not os.environ.get("NR_RT_NOFENCE"):
                xmxres.write_fence()
                xmxres.buffer_flush(backend._extmem_raw)
            back = bytes(np.ascontiguousarray(view[:len(payload)]))
            if back != payload:
                raise RuntimeError("the buffer does not hold the bytes written to it")
            if lib.xmx_sem_signal(int(sid), frame[0]) != 0:
                raise RuntimeError("xmx_sem_signal")
            return from_slot(head_ext, struct.pack("<I", SLOT)
                             + struct.pack("<Q", frame[0]))

        c1 = by_extmem()
        c2 = by_extmem()
        say(f"C buffer in / slot out  {describe(a1, c1)}")
        say(f"C repeat                {describe(c1, c2)}")
        say(shape_of(a1, c1))
        say(f"B vs C                  {describe(b1, c1)}")
        say(shape_of(b1, c1))

        say("")
        say("read: A against B is the slot's own doing; B against C is Phase 2's.")
        code = 0
    except Exception as error:
        import traceback
        traceback.print_exc()
        say(f"FAILED: {error!r}")
    finally:
        os._exit(code)
    return code


mapping = None


def main():
    box["publish"] = nr_daemon._extmem_publish
    nr_daemon._extmem_publish = spy

    room = pathlib.Path(tempfile.mkdtemp(prefix="answer-where-"))
    settings = room / "settings.json"
    settings.write_text(json.dumps({"render_scale": SCALE, "int8": 1,
                                    "temporal": 0}))
    endpoint = rf"\\.\pipe\nr_answer_where_{os.getpid()}"
    threading.Thread(target=drive, daemon=True, args=(endpoint,)).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
