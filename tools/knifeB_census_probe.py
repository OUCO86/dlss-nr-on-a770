#!/usr/bin/env python3
"""Quick structural probe of plan_960x544.c before the real census is written."""
import re, collections

PLAN = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
src = open(PLAN, encoding="utf-8", errors="replace").read().splitlines()

def table(start_pat):
    i = next(k for k, l in enumerate(src) if start_pat in l)
    j = next(k for k in range(i, len(src)) if src[k].strip() == "};")
    return i + 1, j, src[i+1:j]

names_ln, names_end, names_raw = table("const char *const nr_plan_names[]")
sigs_ln, sigs_end, sigs_raw = table("const char *const nr_plan_signatures[]")
steps_ln, steps_end, steps_raw = table("const struct nr_step nr_plan_steps[]")
bufs_ln, bufs_end, bufs_raw = table("const struct nr_buffer nr_plan_buffers[]")
blobs_ln, blobs_end, blobs_raw = table("const struct nr_blob nr_plan_blobs[]")

names = [re.search(r'"([^"]*)"', l).group(1) for l in names_raw]
sigs = [re.search(r'"([^"]*)"', l).group(1) for l in sigs_raw]
print("names", len(names), "at lines", names_ln+1, "-", names_end+1)
print("sigs", len(sigs), "at lines", sigs_ln+1, "-", sigs_end+1)
print("steps", len(steps_raw), "at lines", steps_ln+1, "-", steps_end+1)
print("bufs", len(bufs_raw), "at lines", bufs_ln+1, "-", bufs_end+1)
print("blobs", len(blobs_raw), "at lines", blobs_ln+1, "-", blobs_end+1)

step_re = re.compile(r'\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{\s*(.*?)\s*\},\s*(-?\d+)\s*\},')
steps = []
for k, l in enumerate(steps_raw):
    m = step_re.match(l.strip())
    if not m:
        print("UNPARSED STEP", steps_ln+1+k, l); continue
    op = m.group(1); n = int(m.group(2))
    cells = [int(x, 0) for x in m.group(3).split(",")]
    steps.append((op, n, cells, int(m.group(4)), steps_ln+1+k))
assert len(steps) == len(steps_raw)

hist = collections.Counter(s[0] for s in steps)
for op, c in hist.most_common():
    nm = op[3:].lower()
    print("%-40s %5d  sig=%s" % (op, c, sigs[names.index(nm)] if nm in names else "?"))

for i, s in enumerate(steps):
    if s[0] in ("OP_XMX_BEGIN", "OP_XMX_ABORT", "OP_XMX_SUBMIT", "OP_XMX_SYNC",
                "OP_XMX_GRAPH_CAPTURE", "OP_XMX_GRAPH_RUN", "OP_XMX_GRAPH_DESTROY",
                "OP_XMX_SPECIALIZE"):
        print("landmark step %d line %d %s args=%s" % (i, s[4], s[0], s[2][:s[1]]))
