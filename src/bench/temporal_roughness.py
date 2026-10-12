"""Does the temporal gate make a moving scene rougher?

One frame repeated settles and comes back smoother than it went in, which is not
what the player sees. What the player stands in front of does not hold still: a
fire's glow moves a few levels of 255 every frame. Below `release` (24) the gate
does not count that as movement, so `hold` keeps feeding last frame's result
into this one, and two different moments get mixed into one picture.

So this feeds a sequence - one real frame carrying a smooth, low-amplitude glow
that shifts each step, the way a fire actually breathes - and measures the
roughness of each answer against the frame that produced it. Then it does it
again with `temporal` turned down, which costs nothing: the knob's own note says
carrying the previous frame costs a few per cent of the frame time.
"""
import json
import os
import pathlib
import struct
import subprocess
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


def flicker(base, index):
    """A few levels of smooth glow, shifted a little each frame."""
    h, w = base.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    u = xx / w
    v = yy / h
    phase = index * 0.9
    wave = (0.5 * np.sin(2 * np.pi * (3.1 * u + 0.7) + phase)
            + 0.5 * np.sin(2 * np.pi * (2.3 * v - 1.1) + phase * 0.7))
    out = base.astype(np.float32) + (wave * 3.0)[..., None]
    return np.clip(out, 0, 255).astype(np.uint8)


def child(source_path, frames, out, temporal):
    import ctypes

    for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
        sys.path.insert(0, str(ROOT / sub))
    os.environ["NR_EXTMEM"] = "1"
    os.environ["NR_POSTPASS"] = "1"
    os.environ["NR_LAYER_PID"] = str(os.getpid())
    os.environ["NR_EXTMEM_ANSWER"] = "0"

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

    endpoint = rf"\\.\pipe\nr_temp_{os.getpid()}"
    sequence = np.load(source_path)          # (frames, h, w, 4)
    answers = []

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
            trip(header + sequence[0].tobytes(), ANSWER)
            backend, sid = box["backend"], box.get("sid")
            if sid is None:
                raise RuntimeError("no semaphore was ever offered")
            raw = backend.extmem_view(ANSWER)
            lib = xmxres._load()
            for index in range(1, frames + 1):
                payload = sequence[index - 1].tobytes()
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
                    whole = xmxres.host_view(buffer, np.uint8,
                                             shape=(buffer.nbytes,))
                    answers.append(np.ascontiguousarray(whole[at:at + count]).copy())
                else:
                    answers.append(np.frombuffer(mapping.answer(slot, told),
                                                 np.uint8).copy())
            np.savez(out, *[np.array(a, np.uint8) for a in answers])
        except Exception as error:                              # noqa: BLE001
            import traceback
            traceback.print_exc()
            print(f"FAILED: {error!r}", flush=True)
        finally:
            os._exit(0)

    room = pathlib.Path(tempfile.mkdtemp(prefix="temporal-"))
    settings = room / "settings.json"
    played = ROOT / "work" / "nr_settings.json"
    text = played.read_text() if played.exists() else json.dumps(
        {"render_scale": 0.4, "int8": 1})
    values = json.loads(text)
    values["temporal"] = temporal
    settings.write_text(json.dumps(values))
    print(f"    temporal={temporal}: {json.dumps(values)}", flush=True)
    threading.Thread(target=drive, daemon=True).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()


def run(sequence, frames, temporal, room):
    payload = room / f"seq-{temporal}.npy"
    np.save(payload, sequence)
    answers = room / f"answers-{temporal}.npz"
    subprocess.run([PY, str(pathlib.Path(__file__).resolve()),
                    "--child", str(payload), str(frames), str(answers),
                    str(temporal)], check=False,
                   stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    return answers if answers.exists() else None


def main():
    sys.path.insert(0, str(ROOT / "src" / "bench"))
    sys.path.insert(0, str(ROOT / "work"))
    from read_capture import read
    from _verdict import box_residual

    if "--child" in sys.argv:
        which = sys.argv[sys.argv.index("--child") + 1]
        child(which, int(sys.argv[sys.argv.index("--child") + 2]),
              sys.argv[-2], float(sys.argv[-1]))
        return 0

    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    base = read(str(ROOT / "work" / "capture_in.nrn"))["bgra"]
    base = np.ascontiguousarray(base)
    sequence = np.stack([flicker(base, i) for i in range(frames)])
    print(f"  sequence {sequence.shape}, a glow that shifts a few levels a frame")

    def gradient_rms(grey):
        gy = np.diff(grey, axis=0)
        gx = np.diff(grey, axis=1)
        return float(np.sqrt((gy ** 2).mean() + (gx ** 2).mean()))

    room = pathlib.Path(tempfile.mkdtemp(prefix="temporal-"))
    print(f"\n  {'temporal':>8} {'in grad':>9} {'out grad':>9} {'ratio':>7} "
          f"{'r4 ratio':>9} {'diff std':>9}")
    for temporal in (1.0, 0.5, 0.0):
        got = run(sequence, frames, temporal, room)
        if got is None:
            print(f"  {temporal:>8}  no answers")
            continue
        answers = np.load(got)
        keys = sorted(answers.files, key=lambda k: int(k.split("_")[-1]))
        last = np.frombuffer(answers[keys[-1]], np.uint8)
        last = last[:4 * HEIGHT * WIDTH].reshape(HEIGHT, WIDTH, 4).astype(np.float32)
        # The answer to the last frame, judged against that frame, not the first.
        shown = sequence[frames - 1].astype(np.float32)
        a, b = shown[..., 2], last[..., 2]
        ra = box_residual(a, 4).std()
        rb = box_residual(b, 4).std()
        diff = b - a
        print(f"  {temporal:>8.2f} {gradient_rms(a):9.3f} {gradient_rms(b):9.3f} "
              f"{gradient_rms(b) / gradient_rms(a):7.3f} {rb / ra:9.3f} "
              f"{diff.std():9.3f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
