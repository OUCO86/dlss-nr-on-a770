import sys, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
t = open(r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c",
         encoding="utf-8", errors="replace").read()
steps = re.findall(r"\{\s*(OP_[A-Z_0-9]+),\s*(\d+),\s*\{([^}]*)\}", t)
print("total steps:", len(steps))
ga = [i for i, (o, n, s) in enumerate(steps) if o == "OP_XMX_REC_GLOBAL_ATTENTION"]
print("GA steps:", len(ga), "at plan idx", ga)
for i in ga:
    lo, hi = max(0, i - 3), min(len(steps), i + 3)
    print("--- window around GA idx %d ---" % i)
    for j in range(lo, hi):
        o, n, s = steps[j]
        a = [int(x.strip()) for x in s.split(",")][:12]
        mark = " <== GA" if j == i else ""
        print("  %4d %-34s n=%s %s%s" % (j, o, n, a, mark))
