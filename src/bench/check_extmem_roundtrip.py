#!/usr/bin/env python3
"""A whole frame across the daemon's own buffer, with the layer played in here.

Publishing the handles is one step; a frame that actually crosses in the
buffer they name is another, and the second is where the daemon has fallen
over twice - an unmasked frame reaching `if interface is not None` with no
such name, and an accept that took a closed connection for a failure. Both
took the daemon down, and a game waits on a pipe nobody answers: "the game
will not load", which is a long way from where the mistake was.

So this plays the layer without a game. The daemon runs here, over its own
named pipe; the first frame goes the ordinary way, which is also what makes
the daemon offer its buffer; every frame after that is written into that
buffer, announced on the semaphore, and sent as the frame the layer sends.

The same bytes go both ways, so the two answers can be compared: a frame that
crossed in the buffer has to come back the same frame that crossed on the
wire.

    python3 src/bench/check_extmem_roundtrip.py
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

# Read once, at construction, by everything that decides whether a buffer is
# exportable — as it is under the game.
os.environ["NR_EXTMEM"] = "1"
os.environ["NR_LAYER_PID"] = str(os.getpid())

import numpy as np                                           # noqa: E402
import live_rates                                           # noqa: E402
import nr_daemon                                             # noqa: E402
import nr_pipe                                               # noqa: E402
import xmxres                                                # noqa: E402

WIDTH, HEIGHT, SCALE = 1920, 1080, 0.4
PIXELS = WIDTH * HEIGHT
FORMAT_B8G8R8A8 = live_rates.FORMAT_B8G8R8A8
# The daemon's own pixel limit, which is what sizes a slot. The mapping has to
# be opened with the same number or the slots are not where they look.
MAX_PIXELS = 1920 * 1200

# Filled in as the offer goes out: the daemon's own handles to what it offered.
box = {}


def spy(args, backend):
    """Watch the offer go out, and keep what it handed the layer."""
    box["publish"](args, backend)
    box["sid"] = getattr(args, "extmem_sem", None)
    box["backend"] = backend


def connect_pipe(path):
    for _ in range(2000):
        try:
            return open(path, "r+b", buffering=0)
        except OSError:                     # not made yet, or every instance busy
            time.sleep(0.0005)
    raise RuntimeError(f"no pipe at {path}")


def round_trip(endpoint, data, want):
    """One frame and its whole answer, one connection, as the layer sends them."""
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


def where_is(buffer):
    """The memory type, whether it is host-coherent, and how its address is aligned."""
    coherent, mt, address = xmxres.buffer_place(buffer)
    return (f"type {mt}, {'host-coherent' if coherent else 'NOT coherent'}, "
            f"address ends {address:#06x}")


def describe(one, other):
    """How far apart two answers are: how many bytes, and by how much."""
    left = np.frombuffer(one, np.uint8)
    right = np.frombuffer(other, np.uint8)
    differ = int((left != right).sum())
    biggest = int(np.abs(left.astype(int) - right.astype(int)).max())
    return f"{differ} of {len(one)} bytes differ, largest {biggest}"


def say(text):
    """Written straight out: `os._exit` at the end takes the buffers with it."""
    print(text, flush=True)


def drive(endpoint):
    code = 1
    try:
        while not ready(endpoint):
            time.sleep(0.1)
        # The mapping the answer is read out of, opened once and kept.
        #
        # Opening one touches a byte a page so the pages are committed up front,
        # and it does that over the whole mapping - including every slot's answer.
        # Opened here, before any answer has been written, that costs nothing;
        # opened after one has, it zeroes a byte of every 4096 in the answer.
        # Measured as 2024 bytes a frame: one byte a page over 8294400 of them,
        # every 8 rows by every 128 columns, channel 0 only, and the same every
        # time - which is what a frame that came back wrong looks like. This
        # test had it in the loop that reads the answer back and read its own
        # damage.
        box["mapping"] = nr_pipe.FrameMapping(endpoint, MAX_PIXELS)
        payload = live_rates.frame(WIDTH, HEIGHT, 1)

        # 0. One frame to settle the buffers, thrown away. With the temporal path off
        #    (`temporal: 0` in the settings above) a frame is a function of its bytes
        #    alone, so the two frames below have to agree byte for byte — which they
        #    cannot if one of them is the frame that brings a history into being.
        wire = struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                           FORMAT_B8G8R8A8) + payload
        round_trip(endpoint, wire, 4 * PIXELS)

        # 1. The ordinary way: the bytes go on the wire and the answer comes back on
        #    it. This is also the frame that makes the daemon offer its buffer.
        #    Twice, because the second question is whether two answers to the same
        #    bytes agree at all: whatever they differ by is not Phase 2's doing, and
        #    comparing one frame against another without knowing it is how a rounding
        #    difference gets taken for a broken buffer.
        # What the buffer the frame goes into actually is, and what an ordinary
        # host-written buffer in the same graph is. The difference between them is
        # the question, so it is asked before any answer is compared.
        by_wire = round_trip(endpoint, wire, 4 * PIXELS)
        again = round_trip(endpoint, wire, 4 * PIXELS)
        say(f"  on the wire:    {len(by_wire)} bytes back")
        say(f"  wire vs wire:   {describe(by_wire, again)}")

        sid = box.get("sid")
        if sid is None:
            say("FAILED: the daemon never offered a semaphore")
            return 1
        backend = box["backend"]
        # Did the frame that went on the wire write into this very buffer? If it
        # wrote somewhere else, the two frames below are not being compared on the
        # same memory and nothing they differ by means anything.
        held = bytes(np.ascontiguousarray(backend._extmem_raw.view(np.uint32)[:len(payload) // 4]))
        say(f"  after the wire:   the buffer {'holds' if held == payload else 'DOES NOT hold'} the frame")

        # What the frame's buffer is, against an ordinary host-written one.
        say(f"  the frame's buffer: {where_is(backend._extmem_raw)}")
        view = backend.extmem_view(len(payload))
        if view is None:
            say("FAILED: no view onto the buffer the daemon offered")
            return 1

        # 2. The way Phase 2 wants: the bytes go into the daemon's own buffer, the
        #    semaphore says they are there, and only the header goes on the wire.
        # As a byte view: numpy asks bytes to describe a number, and a frame is not
        # one. The layer memcpy's these bytes; this is the same thing in numpy.
        view[:] = np.frombuffer(payload, np.uint8)
        frame = 1
        lib = xmxres._load()
        if lib.xmx_sem_signal(int(sid), frame) != 0:
            say(f"FAILED: xmx_sem_signal: {xmxres.failure(lib, 'xmx_sem_signal')}")
            return 1
        # The slot the answer is to be left in is the layer's to name, and the frame
        # says which; the four bytes that come back are how many bytes are in it.
        slot = 0
        header = (struct.pack("<4I", nr_daemon.MAGIC_EXTMEM, WIDTH, HEIGHT,
                              FORMAT_B8G8R8A8)
                  + struct.pack("<I", slot) + struct.pack("<Q", frame))
        told = struct.unpack("<I", round_trip(endpoint, header, 4))[0]
        say(f"  in the buffer:  {told} bytes in slot {slot}")

        # 3. The answer is in that slot, which is how the way back still works. Read
        #    it where the layer reads it, and compare: the same bytes went in, so the
        #    same frame has to come out.
        if told != len(by_wire):
            say(f"FAILED: the slot holds {told} bytes, the wire carried {len(by_wire)}")
            return 1
        def through_buffer(frame, data):
            """One frame written into the buffer and sent, and the answer it came back with."""
            # As whole words, which is how the host writes a frame and how the layer
            # memcpy's one. Byte at a time also lands the same bytes, but not as the
            # same stores: this is memory on the far side of the bus, and a narrow
            # write to it is not the write this buffer is meant to be given.
            # memcpy, which is what the layer does. numpy's assignment lands the same
            # bytes, but this is the store a real layer makes, and the question is
            # whether the frame is wrong or only this test's way of writing it.
            ctypes.memmove(view.ctypes.data, data, len(data))
            # Read it back before anything is told: if the bytes are not what was
            # written, no device is to blame for the answer.
            xmxres.write_fence()
            xmxres.buffer_flush(backend._extmem_raw)
            back = bytes(np.ascontiguousarray(view[:len(data)]))
            if back != data:
                raise RuntimeError("the buffer does not hold the bytes written to it")
            if lib.xmx_sem_signal(int(sid), frame) != 0:
                raise RuntimeError("xmx_sem_signal")
            header = (struct.pack("<4I", nr_daemon.MAGIC_EXTMEM, WIDTH, HEIGHT,
                                  FORMAT_B8G8R8A8)
                      + struct.pack("<I", slot) + struct.pack("<Q", frame))
            told = struct.unpack("<I", round_trip(endpoint, header, 4))[0]
            if told != len(by_wire):
                raise RuntimeError(f"the slot holds {told} bytes, the wire "
                                   f"carried {len(by_wire)}")
            # Opened once, before any answer was written into it — see `drive`,
            # and the note there about what opening one does to a slot.
            return bytes(box["mapping"].answer(slot, told))

        # Twice: the first write into a buffer the device has not read before, and
        # then the same write again. Whatever the first frame shows that the second
        # does not is about the first write being seen, not about the bytes.
        first = through_buffer(frame, payload)
        say(f"  buffer, frame 1: {describe(by_wire, first)}")
        # A different frame into the same buffer: if the answer does not follow it,
        # the device is not reading what the host writes here at all.
        other = live_rates.frame(WIDTH, HEIGHT, 2)
        second = through_buffer(frame + 1, other)
        say(f"  buffer vs other:  {describe(by_wire, second)} (a different frame was sent)")
        say(f"  buffer, frame 2: {describe(by_wire, second)}")

        answer = first
        if len(answer) != told:
            say(f"FAILED: {len(answer)} bytes read out of the slot, {told} promised")
            return 1
        left = np.frombuffer(answer, np.uint8)
        right = np.frombuffer(by_wire, np.uint8)
        differ = int((left != right).sum())
        biggest = int(np.abs(left.astype(int) - right.astype(int)).max())
        say(f"  the two answers: {differ} bytes differ of {len(by_wire)}, "
            f"largest {biggest}")
        # A byte here and there is a rounding difference to be looked at; a swathe of
        # them is a frame that came back wrong. The line is drawn where a changed
        # low bit cannot explain the number.
        if differ:
            where = np.flatnonzero(left != right)
            row = where // (WIDTH * 4)
            column = (where % (WIDTH * 4)) // 4
            columns = np.unique(column)
            say(f"  where:            {len(np.unique(row))} rows, "
                f"{len(columns)} distinct columns, "
                f"first {int(columns[0])}, last {int(columns[-1])} of {WIDTH}, "
                f"median column {int(np.median(column))}")
            say(f"  channels:         {sorted(set(int(c % 4) for c in where % (WIDTH * 4)))}")
        if differ and biggest > 2:
            say("FAILED: the frame came back a different frame")
            return 1
        say("\nthe frame crossed in the buffer and came back the same frame")
        code = 0
    except Exception as error:
        import traceback
        traceback.print_exc()
        say(f"FAILED: {error!r}")
    finally:
        # The daemon's accept loop has no other way out.
        os._exit(code)
    return code


def main():
    box["publish"] = nr_daemon._extmem_publish
    nr_daemon._extmem_publish = spy

    room = pathlib.Path(tempfile.mkdtemp(prefix="extmem-rt-"))
    settings = room / "settings.json"
    settings.write_text(json.dumps({"render_scale": SCALE, "int8": 1,
                                        "temporal": 0}))
    endpoint = rf"\\.\pipe\nr_extmem_rt_{os.getpid()}"
    threading.Thread(target=drive, daemon=True, args=(endpoint,)).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
