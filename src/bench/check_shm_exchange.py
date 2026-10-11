"""Does a frame that crossed in a mapping come back the same frame it would by pipe?

The layer's bytes reach the daemon one of two ways: written into the pipe, which copies
them into the kernel and out again, or left in a file mapping the daemon also has, which
copies them once. `shm_vs_pipe.py` says what the two cost. This says whether they agree.

It runs a real daemon — its own process, its own pipe — and sends it the same frames
twice, once each way, and compares what comes back. Nothing about the daemon knows which
it is getting: the only difference is a magic and four bytes in the header.

    python src/bench/check_shm_exchange.py [--frames 4] [--size 1920x1080]

Exits 77, skipped, off Windows.
"""
import argparse
import ctypes
import os
import pathlib
import struct
import subprocess
import sys
import time
from ctypes import wintypes

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
for sub in ("src/bench", "src/layer", "src/ref", "src/gpu"):
    sys.path.insert(0, str(ROOT / sub))

import live_rates                                            # noqa: E402

MAGIC = 0x304E524E
MAGIC_SHM = 0x324E524E
SHM_MAGIC = 0x4D52534E          # what the daemon writes in the mapping's layout head
HEAD = 64

_k32 = ctypes.WinDLL("kernel32", use_last_error=True)
_k32.OpenFileMappingA.restype = wintypes.HANDLE
_k32.OpenFileMappingA.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.LPCSTR]
_k32.MapViewOfFile.restype = ctypes.c_void_p
_k32.MapViewOfFile.argtypes = [wintypes.HANDLE, wintypes.DWORD, wintypes.DWORD,
                               wintypes.DWORD, ctypes.c_size_t]
_k32.UnmapViewOfFile.argtypes = [ctypes.c_void_p]
_k32.CloseHandle.argtypes = [wintypes.HANDLE]

FILE_MAP_ALL_ACCESS = 0xF001F


class Mapping:
    """The daemon's mapping, opened the way the layer does: by name, and its layout
    read out of the first 64 bytes."""

    def __init__(self, name):
        handle = _k32.OpenFileMappingA(FILE_MAP_ALL_ACCESS, False, name.encode())
        if not handle:
            raise OSError(ctypes.get_last_error(), f"OpenFileMappingA {name}")
        self._handle = handle
        self._base = _k32.MapViewOfFile(handle, FILE_MAP_ALL_ACCESS, 0, 0, 0)
        if not self._base:
            raise OSError(ctypes.get_last_error(), "MapViewOfFile")
        words = ctypes.cast(self._base, ctypes.POINTER(ctypes.c_uint32 * 4)).contents
        if words[0] != SHM_MAGIC:
            raise ValueError(f"the mapping is not the daemon's: {words[0]:#x}")
        self.slots = words[2]
        sizes = ctypes.cast(ctypes.c_void_p(self._base + 16),
                            ctypes.POINTER(ctypes.c_uint64 * 2)).contents
        self.colour, self.mask = sizes[0], sizes[1]
        self.stride = 2 * self.colour + self.mask

    def _at(self, slot, offset):
        return self._base + HEAD + slot * self.stride + offset

    def put(self, slot, payload):
        ctypes.memmove(self._at(slot, 0), payload, len(payload))

    def get(self, slot, count):
        return ctypes.string_at(self._at(slot, self.colour + self.mask), count)

    def close(self):
        _k32.UnmapViewOfFile(self._base)
        _k32.CloseHandle(self._handle)


def connect(path, tries=4000):
    """The pipe as the layer opens it, waiting out the daemon's start-up."""
    for _ in range(tries):
        try:
            return open(path, "r+b", buffering=0)
        except OSError:
            time.sleep(0.005)
    raise RuntimeError(f"no pipe at {path}")


def send(path, header, payload, want, mapping=None, slot=0):
    """One frame, and its whole answer, the way the layer does it."""
    if mapping is not None:
        mapping.put(slot, payload)          # before the header: the header says it is there
    with connect(path) as pipe:
        pipe.write(header)
        if mapping is None:
            view = memoryview(payload)
            while view:
                view = view[pipe.write(view):]
        # through the mapping the pipe carries four bytes, not a frame's worth
        take = 4 if mapping is not None else want
        got = bytearray()
        while len(got) < take:
            piece = pipe.read(take - len(got))
            if not piece:
                raise RuntimeError(f"the daemon answered {len(got)} of {take} bytes")
            got += piece
    return mapping.get(slot, want) if mapping is not None else bytes(got)


def run(mode, pipe_path, settings, frames, width, height):
    """A daemon of its own, `frames` frames one way, and what came back."""
    payloads = [live_rates.frame(width, height, i + 1) for i in range(frames)]
    header = struct.pack("<4I", MAGIC, width, height, live_rates.FORMAT_B8G8R8A8)
    shm_header = struct.pack("<4I", MAGIC_SHM, width, height,
                             live_rates.FORMAT_B8G8R8A8)
    pixels = width * height
    env = dict(os.environ)
    env["NR_SHM"] = str(mode)
    env["NR_ROOT"] = str(ROOT)
    env["NR_POSTPASS"] = "1"
    env["NR_INT8_PROJECT"] = "1"
    process = subprocess.Popen(
        [sys.executable, str(ROOT / "src" / "layer" / "nr_daemon.py"),
         "--socket", pipe_path, "--root", str(ROOT),
         "--settings", str(settings), "--max-pixels", str(pixels)],
        env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
        cwd=str(ROOT), bufsize=1)
    log = []
    try:
        deadline = time.time() + 300
        listening = False
        while time.time() < deadline:
            line = process.stdout.readline()
            if not line:
                if process.poll() is not None:
                    break
                continue
            log.append(line.rstrip())
            if "listening on" in line:
                listening = True
                break
        if not listening:
            raise RuntimeError("the daemon never listened:\n" + "\n".join(log[-20:]))
        mapping = None
        if mode:
            # the layer finds it by the pipe's name, and only after the daemon made it
            name = "Local\\NR_SHM_" + pipe_path.rsplit("\\", 1)[-1]
            for _ in range(400):
                # it exists as soon as the daemon makes it, and its layout a moment
                # later, when the pages are committed — so a mapping is not enough
                try:
                    mapping = Mapping(name)
                    break
                except (OSError, ValueError):
                    time.sleep(0.02)
            if mapping is None:
                raise RuntimeError(f"no mapping {name}")
        answers, took = [], []
        for index, payload in enumerate(payloads):
            mark = time.perf_counter()
            if mapping is None:
                answers.append(send(pipe_path, header, payload, pixels * 4))
            else:
                slot = index % mapping.slots
                answers.append(send(pipe_path, shm_header + struct.pack("<I", slot),
                                    payload, pixels * 4, mapping, slot))
            took.append(time.perf_counter() - mark)
        return answers, took, log
    finally:
        process.terminate()
        try:
            process.wait(timeout=20)
        except subprocess.TimeoutExpired:
            process.kill()


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--size", default="1920x1080")
    parser.add_argument("--frames", type=int, default=4)
    parser.add_argument("--settings", type=pathlib.Path,
                        default=ROOT / "work" / "nr_settings.json")
    args = parser.parse_args()
    if os.name != "nt":
        print("skipped: the mapping is a Windows answer to a Windows cost")
        return 77
    width, height = (int(v) for v in args.size.split("x"))
    pipe_path = rf"\\.\pipe\nr_check_shm_{os.getpid()}"
    print(f"{width}x{height}, {args.frames} frames, a daemon each way")

    results = {}
    for mode in (0, 1):
        answers, took, log = run(mode, pipe_path, args.settings, args.frames,
                                 width, height)
        results[mode] = (answers, took)
        name = "pipe" if not mode else "mapping"
        times = " ".join(f"{1000 * t:.1f}" for t in took)
        print(f"  {name:8} {len(answers)} answers, round trip ms: {times}")
        for line in log:
            if "mapping" in line or "rejected" in line or "Traceback" in line:
                print(f"    {line.strip()}")
        if len(answers) != args.frames:
            print("  FAILED: not every frame was answered")
            return 1

    left, right = results[0][0], results[1][0]
    same = 0
    for index, (was, now) in enumerate(zip(left, right)):
        if was == now:
            same += 1
            print(f"  frame {index}: byte-identical")
            continue
        got = np.frombuffer(now, np.uint8)
        want = np.frombuffer(was, np.uint8)
        delta = np.abs(got.astype(np.int16) - want.astype(np.int16))
        print(f"  frame {index}: {int((delta > 0).sum())} of {delta.size} bytes differ, "
              f"largest {int(delta.max())}")
    print(f"\nbyte-identical frames: {same}/{len(left)}")
    return 0 if same == len(left) else 1


if __name__ == "__main__":
    sys.exit(main())
