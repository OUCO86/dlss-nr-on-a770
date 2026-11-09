import sys, re, collections
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
SRC = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
t = open(SRC, encoding="utf-8", errors="replace").read()
steps = re.findall(r"\{\s*(OP_[A-Z_0-9]+),\s*(\d+),\s*\{([^}]*)\}", t)
print("total steps:", len(steps))
cnt = collections.Counter(o for o, n, s in steps)
for o, c in cnt.most_common():
    print("  %-40s %d" % (o, c))
print()
ga = [i for i, (o, n, s) in enumerate(steps) if o == "OP_XMX_REC_GLOBAL_ATTENTION"]
print("GA steps:", len(ga), "at plan idx", ga)
print()
for i in ga:
    lo, hi = max(0, i - 4), min(len(steps), i + 5)
    print("--- window around GA idx %d ---" % i)
    for j in range(lo, hi):
        o, n, s = steps[j]
        a = [int(x.strip()) for x in s.split(",")][:14]
        mark = " <== GA" if j == i else ""
        print("  %4d %-36s n=%s %s%s" % (j, o, n, a, mark))
    print()
