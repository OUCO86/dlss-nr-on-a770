import sys, re, collections
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
t = open(r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c",
         encoding="utf-8", errors="replace").read()
# ffn_merge takes 11 args: source skip sincos expand projection out cosine height width source_width flags
steps = re.findall(r"\{\s*OP_XMX_REC_FFN_MERGE,\s*(\d+),\s*\{([^}]*)\}", t)
print("OP_XMX_REC_FFN_MERGE steps:", len(steps))
for k, s in steps:
    print("  argc:", s)
rows = []
for k, (n, s) in enumerate(steps):
    a = [int(x.strip()) for x in s.split(",")]
    source, skip, sincos, expand, projection, out, cosine = a[0:7]
    height, width, source_width, flags = a[7:11]
    M = height * width
    narrow = bool(flags & 0x1000); epi = (flags >> 8) & 0xF
    # engine route (libxmx_sycl.cpp:3537/3549/3556): merge_chip = ffntile2&&ffchip2&&!narrow&&epi==0
    # chipres default on => launch_ffn_chip_cs2<16,false> (NR_CHIP_LW16 default true)
    if narrow or epi:
        route = "legacy tile path (f16v1)"
    else:
        route = "merge_chip+chipres: passA ew + ffnc::launch_ffn_chip_cs2<16,false>"
    rows.append((k, int(n), source, skip, sincos, expand, projection, out, cosine,
                 height, width, source_width, flags, epi, int(narrow), M, route))
print("\nidx argc src skip sc exp prj out cos h    w    srcw   flags epi nar  M       route")
for r in rows:
    print("%3d %4d %4d %4d %3d %4d %4d %4d %3d %4d %4d %6d %8d %3d %3d %7d  %s" % r)
# also count neighbors: which op sits before/after in the plan? print sequence of OP names around each ffn_merge
ops = re.findall(r"OP_([A-Z_0-9]+),\s*\d+,\s*\{", t)
idxs = [k for k, (n, s) in enumerate(steps)]
print("\ntotal plan steps:", len(ops))
