"""One real frame through the real daemon, drifting two pixels a frame.

The flicker trip answered clean too: a breathing glow leaves no directional
structure behind. What is left is motion. The temporal path reprojects by
identity - the history is blended in where it was, not where things went - so
every frame the view moves, the previous answer sits one step off, and at 30 fps
a small drift is several pixels a frame. This trip drifts the captured frame
two pixels right and one down per frame, a slow aim wobble, and watches for
direction-locked streaks growing in the answer.

    python3 src/bench/trip_motion.py [frame.nrn] [repeats] [out.npz]
"""
import json
import os
import pathlib
import struct
import sys
import tempfile
import threading
import time

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[2]
WIDTH, HEIGHT = 1920, 1080
ANSWER = 4 * WIDTH * HEIGHT
MAX_PIXELS = 1 << 22
PY = sys.executable


def child(source, frames, out):
    import ctypes

    for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
        sys.path.insert(0, str(ROOT / sub))
    os.environ["NR_EXTMEM"] = "1"
    os.environ["NR_POSTPASS"] = "1"
    os.environ["NR_LAYER_PID"] = str(os.getpid())
    os.environ["NR_EXTMEM_ANSWER"] = "0"          # the answer comes back in a slot

    import live_rates                                          # noqa: E402
    import nr_daemon                                           # noqa: E402
    import nr_pipe                                             # noqa: E402
    import xmxres                                              # noqa: E402

    box = {}
    publish = nr_daemon._extmem_publish

    def watch(args, backend, *rest, **kwargs):
        got = publish(args, backend, *rest, **kwargs)
        box["sid"] = getattr(args, "extmem_sem", None)
        box["backend"] = backend
        return got

    nr_daemon._extmem_publish = watch

    endpoint = rf"\\.\pipe\nr_trip_{os.getpid()}"
    answers = []
    payloads = [np.ascontiguousarray(frame).tobytes() for frame in source]

    def drive():
        try:
            for _ in range(3000):
                try:
                    open(endpoint, "r+b", buffering=0).close()
                    break
                except OSError:
                    time.sleep(0.005)
            mapping = nr_pipe.FrameMapping(endpoint, MAX_PIXELS)

            def trip(data, want):
                # A named pipe instance is not always there the moment we ask;
                # busy is not fatal, so give it a moment and ask again.
                last = None
                for _ in range(200):
                    try:
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
                    except OSError as error:
                        last = error
                        time.sleep(0.02)
                raise RuntimeError(f"pipe never opened: {last!r}")

            header = struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                                 live_rates.FORMAT_B8G8R8A8)
            trip(header + payloads[0], ANSWER)      # makes the daemon offer
            backend, sid = box["backend"], box.get("sid")
            if sid is None:
                raise RuntimeError("no semaphore was ever offered")
            raw = backend.extmem_view(ANSWER)
            lib = xmxres._load()
            for index in range(1, frames + 1):
                data = payloads[(index - 1) % len(payloads)]
                ctypes.memmove(raw.ctypes.data, data, len(data))
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
                    whole = xmxres.host_view(buffer, np.uint8,
                                             shape=(buffer.nbytes,))
                    answers.append(np.ascontiguousarray(whole[at:at + count]).copy())
                else:
                    answers.append(np.frombuffer(mapping.answer(slot, told),
                                                 np.uint8).copy())
            np.savez(out, *[np.array(a, np.uint8) for a in answers])
            print(f"    got {len(answers)} answers", flush=True)
        except Exception as error:                              # noqa: BLE001
            import traceback
            traceback.print_exc()
            print(f"FAILED: {error!r}", flush=True)
        finally:
            os._exit(0)

    room = pathlib.Path(tempfile.mkdtemp(prefix="one-frame-"))
    settings = room / "settings.json"
    played = ROOT / "work" / "nr_settings.json"
    settings.write_text(played.read_text() if played.exists()
                        else json.dumps({"render_scale": 0.4, "int8": 1}))
    threading.Thread(target=drive, daemon=True).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()


def main():
    if "--child" in sys.argv:
        which = sys.argv[sys.argv.index("--child") + 1]
        frames = int(sys.argv[sys.argv.index("--child") + 2])
        child(np.load(which), frames, sys.argv[-1])
        return 0

    source_path = sys.argv[1] if len(sys.argv) > 1 else None
    frames = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    out = sys.argv[3] if len(sys.argv) > 3 else None

    sys.path.insert(0, str(ROOT / "src" / "bench"))
    from read_capture import read

    frame = read(source_path or str(ROOT / "work" / "capture_in.nrn"))["bgra"]
    frame = np.ascontiguousarray(frame)
    print(f"  source frame {frame.shape} {frame.dtype}")

    # a slow aim wobble: two pixels right and one down each frame, sub-pixel by
    # bilinear shift. Identity reprojection leaves every history one step behind.
    count = frames

    def shift(image, dx, dy):
        ix, fx = int(np.floor(dx)), dx - np.floor(dx)
        iy, fy = int(np.floor(dy)), dy - np.floor(dy)
        base = np.roll(np.roll(image, iy, 0), ix, 1).astype(np.float64)
        right = np.roll(np.roll(image, iy, 0), ix + 1, 1).astype(np.float64)
        down = np.roll(np.roll(image, iy + 1, 0), ix, 1).astype(np.float64)
        both = np.roll(np.roll(image, iy + 1, 0), ix + 1, 1).astype(np.float64)
        return (base * (1 - fx) * (1 - fy) + right * fx * (1 - fy)
                + down * (1 - fx) * fy + both * fx * fy)

    swings = []
    for i in range(count):
        moved = shift(frame, 2.0 * i, 1.0 * i)
        moved[..., 3] = frame[..., 3]
        swings.append(np.clip(moved, 0, 255).astype(np.uint8))
    print(f"  drifted {count} frames, 2 px right + 1 px down each")

    room = pathlib.Path(tempfile.mkdtemp(prefix="one-frame-"))
    payload = room / "frames.npy"
    np.save(payload, np.stack(swings))
    answers = room / "answers.npz"
    import subprocess
    subprocess.run([PY, str(pathlib.Path(__file__).resolve()),
                    "--child", str(payload), str(frames), str(answers)],
                   check=False)
    if not answers.exists():
        print("  no answers came back")
        return 1
    got = np.load(answers)
    keys = sorted(got.files, key=lambda k: int(k.split("_")[-1]))
    print(f"  {len(keys)} frames came back")
    target = out or str(ROOT / "work" / "motion_pair.npz")
    np.savez(target, source=frame, **{f"answer_{i}": got[k] for i, k in enumerate(keys)})
    print(f"  saved to {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
