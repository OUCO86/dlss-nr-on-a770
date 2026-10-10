#!/usr/bin/env python3
"""Does the host's image library actually use more than one core?

`src/ref/nr_image.c` puts an OpenMP `parallel for` on every row loop, and
`tools/build_win.bat` passes `/openmp`, and the built DLL imports VCOMP140. That is three
things that can each be true while the passes still run on one thread: the pragma expands
to nothing when `_OPENMP` is not defined at compile time, and a runtime that cannot be
reached is the same as no runtime at all.

So this does not read the build. It asks the machine. One child process per thread count
- `OMP_NUM_THREADS` is read once, when the runtime starts, so no single process can try
two - and each times the same passes on the same buffers, 1920x1080.

    python src/bench/host_threads.py [threads ...]

If the times are flat across the thread counts, the parallel for is not running, and
`src/ref/nr_image.c` is leaving most of a 24-thread machine idle.
"""
import os
import pathlib
import statistics
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
WIDTH, HEIGHT = 1920, 1080
ROUNDS = 40


def child(threads):
    os.environ["OMP_NUM_THREADS"] = str(threads)
    sys.path.insert(0, str(ROOT / "src" / "ref"))

    import numpy as np
    import nr_image

    if nr_image.library() is None:
        print("no native library: the NumPy fallback is what is being timed", file=sys.stderr)
        return 1

    raw = np.random.default_rng(7).integers(0, 256, HEIGHT * WIDTH * 4,
                                            dtype=np.uint8).tobytes()
    colour = np.random.default_rng(8).random((HEIGHT, WIDTH, 3), np.float32)
    half_target = np.empty((HEIGHT, WIDTH, 3), np.float16)

    def once(kind):
        if kind == "decode8":
            return nr_image.decode8(raw, WIDTH, HEIGHT, True)
        if kind == "bilinear":
            return nr_image.bilinear(colour, (448, 768))
        return nr_image.to_half(colour, half_target)

    for kind in ("decode8", "bilinear", "to_half"):
        once(kind)                                  # warm the allocator and the runtime
        times = []
        for _ in range(ROUNDS):
            clock = time()
            once(kind)
            times.append((time() - clock) * 1000)
        print(f"{kind:10s} {statistics.median(times):7.2f} ms  "
              f"(min {min(times):.2f}, max {max(times):.2f})")
    return 0


from time import perf_counter as time  # noqa: E402  (imported after the fork on purpose)


def main():
    counts = [int(a) for a in sys.argv[1:]] or [1, 2, 4, 8, 12, 24]
    print(f"{WIDTH}x{HEIGHT}, median of {ROUNDS} calls, one process per thread count\n")
    for threads in counts:
        print(f"--- OMP_NUM_THREADS={threads} ---")
        subprocess.run([sys.executable, __file__, "--child", str(threads)], check=False,
                       env={**os.environ, "OMP_NUM_THREADS": str(threads)})
        print()
    return 0


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--child":
        raise SystemExit(child(int(sys.argv[2])))
    raise SystemExit(main())
