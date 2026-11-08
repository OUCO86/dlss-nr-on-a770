import sys, re, collections
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
t = open(r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c",
         encoding="utf-8", errors="replace").read()
steps = re.findall(r"\{\s*OP_XMX_REC_WINDOW_BLOCK,\s*14,\s*\{([^}]*)\}", t)
print("OP_XMX_REC_WINDOW_BLOCK steps:", len(steps))
def parse(s):
    return [int(x.strip()) for x in s.split(",")]
cnt = collections.Counter(); rows = []
for k, s in enumerate(steps):
    a = parse(s)
    image, qkv, projection, target, bias, cosine, scale, pooled = a[0:8]
    windows, height, width, across, pad, flags = a[8:14]
    pooling = bool(flags & 0x800000); head = bool(flags & 0x1000000)
    narrow = bool(flags & 0x1000); epi = (flags >> 8) & 0xF; ihalf = bool(flags & 0x8000)
    route = "v4ph(pool)" if (pooling and not head) else ("v4ph(head)" if (head and not pooling) else
            ("both->split" if (pooling and head) else "non-pool/head"))
    cnt[route] += 1
    rows.append((k, windows, height, width, across, pad, epi, int(narrow), int(pooling), int(head), int(ihalf), route))
for r, c in cnt.items(): print("   %-16s %d" % (r, c))
print("\nidx  windows  h   w  across  pad  epi narrow pool head ihalf  route")
for r in rows:
    print("%3d %7d %4d %4d %6d %4d %3d %6d %4d %4d %5d  %s" % r)
