"""How much of the artifact each knob can take off, and what it costs.

The artifact is the network's own checkerboard, laid over a smooth glow where
there is no texture to hide it. Filtering the finished frame can only chase it
at the cost of real detail, so before touching any code: what do the knobs that
already exist do to it?

The frame is the synthetic glow - the flattest, most exposing picture there is.

    python3 src/bench/knob_scan.py [frame.nrn] [repeats]

Each run is a whole daemon, so this is slow on purpose and cheap to read.
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


def child(source_path, frames, out, setting):
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
    endpoint = rf"\\.\pipe\nr_knob_{os.getpid()}"
    payload_bytes = np.load(source_path).tobytes() if source_path.endswith(
        ".npy") else pathlib.Path(source_path).read_bytes()[16:]
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
                                    raise RuntimeError(f"{len(got)} of {want}")
                                got += piece
                        return bytes(got)
                    except OSError as error:
                        last = error
                        time.sleep(0.02)
                raise RuntimeError(f"pipe never opened: {last!r}")

            header = struct.pack("<4I", live_rates.MAGIC, WIDTH, HEIGHT,
                                 live_rates.FORMAT_B8G8R8A8)
            trip(header + payload_bytes, ANSWER)
            backend, sid = box["backend"], box.get("sid")
            raw = backend.extmem_view(ANSWER)
            lib = xmxres._load()
            for index in range(1, frames + 1):
                ctypes.memmove(raw.ctypes.data, payload_bytes, len(payload_bytes))
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

    room = pathlib.Path(tempfile.mkdtemp(prefix="knob-"))
    settings = room / "settings.json"
    played = ROOT / "work" / "nr_settings.json"
    values = json.loads(played.read_text() if played.exists()
                        else json.dumps({"render_scale": 0.4, "int8": 1}))
    if setting and setting != "-":
        key, _, value = setting.partition("=")
        values[key] = float(value) if "." in value else int(value)
    settings.write_text(json.dumps(values))
    threading.Thread(target=drive, daemon=True).start()
    sys.argv = [str(ROOT / "src" / "layer" / "nr_daemon.py"), "--socket", endpoint,
                "--settings", str(settings), "--max-pixels", str(MAX_PIXELS)]
    nr_daemon.main()


def main():
    sys.path.insert(0, str(ROOT / "work"))
    from _verdict import box_residual

    if "--child" in sys.argv:
        at = sys.argv.index("--child")
        child(sys.argv[at + 1], int(sys.argv[at + 2]),
              sys.argv[at + 3], sys.argv[at + 4])
        return 0

    source = sys.argv[1] if len(sys.argv) > 1 else str(
        ROOT / "work" / "glow_source.nrn")
    frames = int(sys.argv[2]) if len(sys.argv) > 2 else 8

    raw = pathlib.Path(source).read_bytes()
    base = np.frombuffer(raw[16:], np.uint8).reshape(
        HEIGHT, WIDTH, 4).astype(np.float32)[..., 2]

    def grad(g):
        gy = np.diff(g, axis=0)
        gx = np.diff(g, axis=1)
        return float(np.sqrt((gy ** 2).mean() + (gx ** 2).mean()))

    def patch(g):
        return g[300:800, 500:1400]

    src = patch(base)
    print(f"  source {source}")
    print(f"  the glow as it went in: gradient {grad(src):.4f}\n")
    print(f"  {'setting':<24} {'glow grad':>10} {'x input':>8} "
          f"{'artifact':>9} {'r4':>8}")
    print(f"  {'(nothing on)':<24} {grad(src):10.4f} {1.0:8.2f} "
          f"{0.0:8.1f}% {box_residual(src, 4).std():8.4f}")

    room = pathlib.Path(tempfile.mkdtemp(prefix="knob-"))
    plans = [("intensity", 1.0), ("intensity", 0.5),
             ("detail_strength", 0.5), ("detail_strength", 0.0),
             ("temporal", 1.0)]
    for key, value in plans:
        setting = f"{key}={value}"
        answers = room / f"a-{key}-{value}.npz"
        subprocess.run([PY, str(pathlib.Path(__file__).resolve()),
                        "--child", source, str(frames), str(answers), setting],
                       check=False, stdout=subprocess.DEVNULL,
                       stderr=subprocess.STDOUT)
        if not answers.exists():
            print(f"  {setting:<24}  no answers")
            continue
        got = np.load(answers)
        keys = sorted(got.files, key=lambda k: int(k.split("_")[-1]))
        last = np.frombuffer(got[keys[-1]], np.uint8)[:4 * HEIGHT * WIDTH]
        last = last.reshape(HEIGHT, WIDTH, 4).astype(np.float32)[..., 2]
        out = patch(last)
        artifact = (grad(out) - grad(src)) / max(grad(base) * 0.0 + 1e-9, 1e-9)
        print(f"  {setting:<24} {grad(out):10.4f} {grad(out) / grad(src):8.2f} "
              f"{(grad(out) / grad(src) - 1.0) * 100:8.0f}% "
              f"{box_residual(out, 4).std():8.4f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
