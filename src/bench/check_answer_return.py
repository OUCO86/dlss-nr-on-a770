#!/usr/bin/env python3
"""The way back, against the way it was: the same words, read out of two places.

Phase 2's second half takes the answer out of the slot in the mapping and puts it
in a buffer of the daemon's own, which the layer imports and reads where the
device left it. What has to be true is narrower than "it runs": the words have to
be the same words. A frame that comes back a pixel off in a corner is a frame
nobody is going to notice in a log that only says how many milliseconds it took.

So this runs the daemon twice over the same frames — once with the answer in the
buffer, once with it in the slot — and compares the answers byte for byte. The
two runs are separate processes because the switch is read once, at start-up:
a buffer is exportable or it is not from the moment it is allocated.

    python3 src/bench/check_answer_return.py [frames]

`--child 0|1` runs one of the two halves and writes its answers out; that is how
the parent asks for them, not a way in of its own.
"""
import os
import pathlib
import subprocess
import sys
import tempfile

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
WIDTH, HEIGHT = 1920, 1080
PY = sys.executable


def child(external, frames, out):
    """Run the daemon over `frames` frames and leave the answers in `out`."""
    import ctypes
    import json
    import struct
    import threading
    import time

    for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
        sys.path.insert(0, str(ROOT / sub))
    os.environ["NR_EXTMEM"] = "1"
    os.environ["NR_POSTPASS"] = "1"
    os.environ["NR_LAYER_PID"] = str(os.getpid())
    os.environ["NR_EXTMEM_ANSWER"] = "1" if external else "0"

    import live_rates                                        # noqa: E402
    import nr_daemon                                         # noqa: E402
    import nr_pipe                                           # noqa: E402
    import xmxres                                            # noqa: E402

    ANSWER = 4 * WIDTH * HEIGHT
    MAX_PIXELS = 1 << 22
    box = {}
    box["publish"] = nr_daemon._extmem_publish
    nr_daemon._extmem_publish = lambda args, backend: (
        box["publish"](args, backend),
        box.__setitem__("sid", getattr(args, "extmem_sem", None)),
        box.__setitem__("backend", backend))[0]

    endpoint = rf"\\.\pipe\nr_return_{os.getpid()}"
    answers = []

    def drive():
        try:
            for _ in range(2000):
                try:
                    open(endpoint, "r+b", buffering=0).close()
                    break
                except OSError:
                    time.sleep(0.005)
            mapping = nr_pipe.FrameMapping(endpoint, MAX_PIXELS)

            def trip(data, want):
                with open(endpoint, "r+b", buffering=0) as pipe:
                    view = memoryview(data)
                    while view:
                        view = view[pipe.write(view):]
                    got = bytearray()
                    while len(got) < want:
                        piece = pipe.read(want - len(got))
                        if not piece:
                            raise RuntimeError(f"{len(got)} of {want} bytes")
                        got += piece
                return bytes(got)

            header = struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                                 live_rates.FORMAT_B8G8R8A8)
            # One frame on the wire: it is what makes the daemon offer its buffers.
            trip(header + live_rates.frame(WIDTH, HEIGHT, 0), ANSWER)
            backend, sid = box["backend"], box.get("sid")
            if sid is None:
                raise RuntimeError("no semaphore was ever offered")
            raw = backend.extmem_view(ANSWER)
            lib = xmxres._load()
            for index in range(1, frames + 1):
                payload = live_rates.frame(WIDTH, HEIGHT, index)
                ctypes.memmove(raw.ctypes.data, payload, len(payload))
                if lib.xmx_sem_signal(int(sid), index) != 0:
                    raise RuntimeError("xmx_sem_signal")
                slot = index % mapping.slots
                told = struct.unpack("<I", trip(
                    struct.pack("<4I", nr_daemon.MAGIC_EXTMEM, WIDTH, HEIGHT,
                                live_rates.FORMAT_B8G8R8A8)
                    + struct.pack("<I", slot) + struct.pack("<Q", index), 4))[0]
                if told & 0x80000000:
                    at, count = struct.unpack_from("<II", mapping.answer(slot, 8), 0)
                    buffer = backend._extmem_answer
                    whole = xmxres.host_view(buffer, np.uint8, shape=(buffer.nbytes,))
                    answers.append(np.ascontiguousarray(whole[at:at + count]).copy())
                else:
                    answers.append(np.frombuffer(mapping.answer(slot, told),
                                                 np.uint8).copy())
            np.savez(out, *[np.array(a, np.uint8) for a in answers])
        except Exception as error:                            # noqa: BLE001
            import traceback
            traceback.print_exc()
            print(f"FAILED: {error!r}", flush=True)
        finally:
            os._exit(0)

    room = pathlib.Path(tempfile.mkdtemp(prefix="answer-return-"))
    settings = room / "settings.json"
    played = ROOT / "work" / "nr_settings.json"
    settings.write_text(played.read_text() if played.exists()
                        else json.dumps({"render_scale": 0.4, "int8": 1}))
    threading.Thread(target=drive, daemon=True).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else 8
    if "--child" in sys.argv:
        which = sys.argv[sys.argv.index("--child") + 1]
        child(which == "1", frames, sys.argv[-1])
        return 0

    room = pathlib.Path(tempfile.mkdtemp(prefix="return-pairs-"))
    got = []
    for flag in ("0", "1"):
        out = room / f"answers-{flag}.npz"
        subprocess.run([PY, str(pathlib.Path(__file__).resolve()), str(frames),
                        "--child", flag, str(out)], check=False)
        got.append(out)

    left, right = (np.load(p) for p in got)
    keys = sorted(set(left.files) & set(right.files))
    print(f"the answer in the slot, and in the buffer the layer imports:")
    print(f"  {len(keys)} frames compared")
    bad = 0
    for key in keys:
        a, b = np.asarray(left[key], np.uint8), np.asarray(right[key], np.uint8)
        if a.size != b.size:
            print(f"  frame {key}: {a.size} bytes against {b.size}")
            bad += 1
            continue
        differ = int((a != b).sum())
        biggest = int(np.abs(a.astype(int) - b.astype(int)).max())
        print(f"  frame {key}: {differ} of {a.size} bytes differ, largest {biggest}")
        if differ:
            bad += 1
    print()
    if bad or not keys:
        print("FAILED: the way back does not give back the same words")
        return 1
    print("the same words either way")
    return 0


if __name__ == "__main__":
    sys.exit(main())
