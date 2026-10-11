"""Sample the running daemon log and summarise the current operating point.

Usage:
    python tools/sample_log.py [seconds] [--log work/nr_daemon.log]

Reads the tail of the daemon log for `seconds` (default 20) and reports
frame rate, per-stage GPU time, gate statistics and any NaN sightings.
Standard library only -- safe to run with any interpreter.

Two frame times are reported and they are not the same number. "daemon" is the
time the Neural Renderer took over one frame, which is the whole of what the
daemon can see. "game" is the interval between the game's presents, logged by
the layer: it also holds what the game spent rendering that frame and what the
present waited for. The daemon's number was read as the frame rate for a long
time here, and it is only a part of it.
"""

import os
import re
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

IN_RE = re.compile(r"\bin ([0-9.]+)s\b")
CHANGE_RE = re.compile(r"\bchange ([0-9.]+)\b")
GATE_RE = re.compile(r"\bgate ([0-9.]+)\b")
HELD_RE = re.compile(r"\bheld (\d+)%")
CUT_RE = re.compile(r"\bcut ([0-9.]+)\b")
GPU_RE = re.compile(r"\bgpu (\d+)\+(\d+)\+(\d+)ms\b")
NET_RE = re.compile(r"\bnetwork (\d+)x(\d+) scale ([0-9.]+)")

# The layer's own report of the game's frame time, which the daemon cannot make:
#   [nr_layer] frame: 120 presented, 33.4 ms median (p25 33.1 / p75 33.8),
#                     min 32.9 max 41.2  =>  29.9 fps
# Groups: presents, median ms, p25, p75, min, max, fps.
FRAME_RE = re.compile(r"\[nr_layer\] frame: (\d+) presented, ([0-9.]+) ms median "
                      r"\(p25 ([0-9.]+) / p75 ([0-9.]+)\), "
                      r"min ([0-9.]+) max ([0-9.]+)\s+=>\s+([0-9.]+) fps")


def tail_lines(path):
    with open(path, "r", errors="replace") as fh:
        return fh.read().splitlines()


def summarise(lines):
    frames = [ln for ln in lines if " in " in ln and "network" in ln]
    # The layer's frame report stands on its own: a session where the daemon took no
    # frames at all still has the game's frame time, and that is worth seeing.
    reported = [m.groups() for m in (FRAME_RE.search(ln) for ln in lines) if m]
    if not frames and not reported:
        return None

    def collect(rx, cast=float):
        out = []
        for ln in frames:
            m = rx.search(ln)
            if m:
                out.append(cast(m.group(1)))
        return out

    def mean(xs):
        return sum(xs) / len(xs) if xs else float("nan")

    def pct(xs, p):
        if not xs:
            return float("nan")
        ys = sorted(xs)
        return ys[min(len(ys) - 1, int(round(p / 100.0 * (len(ys) - 1))))]

    inter = collect(IN_RE)
    gpu = [tuple(int(g) for g in m.groups()) for m in (GPU_RE.search(ln) for ln in frames) if m]
    held = collect(HELD_RE, int)

    net = None
    for ln in frames:
        m = NET_RE.search(ln)
        if m:
            net = (int(m.group(1)), int(m.group(2)), float(m.group(3)))
            break

    return {
        "frames": len(frames),
        "fps": 1.0 / mean(inter) if inter else float("nan"),
        "frame_ms": mean(inter) * 1000.0,
        "frame_p95_ms": pct(inter, 95) * 1000.0,
        "gpu_prepare_ms": mean([g[0] for g in gpu]),
        "gpu_network_ms": mean([g[1] for g in gpu]),
        "gpu_finish_ms": mean([g[2] for g in gpu]),
        "gpu_total_ms": mean([sum(g) for g in gpu]),
        "gpu_network_max_ms": max([g[1] for g in gpu]) if gpu else float("nan"),
        "change": mean(collect(CHANGE_RE)),
        "gate": mean(collect(GATE_RE)),
        "held": mean(held),
        "cut": mean(collect(CUT_RE)),
        "network": net,
        "nan_lines": sum(1 for ln in lines if "nan" in ln.lower()),
        "game_reports": len(reported),
        "game_presented": sum(int(r[0]) for r in reported),
        "game_frame_ms": mean([float(r[1]) for r in reported]),
        "game_fps": mean([float(r[6]) for r in reported]),
        "game_worst_ms": max([float(r[1]) for r in reported]) if reported else float("nan"),
        "game_p75_ms": mean([float(r[3]) for r in reported]),
    }


def main(argv):
    seconds = float(argv[0]) if argv and not argv[0].startswith("-") else 20.0
    log = os.path.join(ROOT, "work", "nr_daemon.log")
    if "--log" in argv:
        log = argv[argv.index("--log") + 1]

    start = len(tail_lines(log))
    t0 = time.time()
    sys.stderr.write("sampling %.0fs ...\n" % seconds)
    time.sleep(seconds)
    lines = tail_lines(log)[start:]
    wall = time.time() - t0

    s = summarise(lines)
    if s is None:
        print("no frames captured in the last %.1fs" % wall)
        return 1

    print("window     : %.1fs wall, %d frames" % (wall, s["frames"]))
    print("frame rate : %.2f fps  (%.1f ms/frame, p95 %.1f ms)   <- daemon: NR only"
          % (s["fps"], s["frame_ms"], s["frame_p95_ms"]))
    if s["game_reports"]:
        print("game frame : %.1f ms  (%.1f fps, p75 %.1f, worst window %.1f)  "
              "over %d presents in %d reports"
              % (s["game_frame_ms"], s["game_fps"], s["game_p75_ms"],
                 s["game_worst_ms"], s["game_presented"], s["game_reports"]))
    else:
        print("game frame : none reported -- the layer's lines are missing, which is "
              "the ordinary state before this build")
    print("gpu        : %.1f + %.1f + %.1f = %.1f ms  (network peak %.0f ms)"
          % (s["gpu_prepare_ms"], s["gpu_network_ms"], s["gpu_finish_ms"],
             s["gpu_total_ms"], s["gpu_network_max_ms"]))
    if s["network"]:
        print("network    : %dx%d  scale %.2f" % s["network"])
    print("change     : %.5f" % s["change"])
    print("gate       : %.3f   held %.0f%%   cut %.4f" % (s["gate"], s["held"], s["cut"]))
    print("nan lines  : %d" % s["nan_lines"])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
