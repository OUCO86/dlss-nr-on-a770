import sys, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
t = open(r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c",
         encoding="utf-8", errors="replace").read()
# xmx_rec_ffn(int features,int skip,int expand,int projection,int out,int cosine,unsigned M,unsigned flags)?
# find the exact argc from the recorder comment first
steps = re.findall(r"\{\s*OP_XMX_REC_FFN,\s*(\d+),\s*\{([^}]*)\}", t)
print("OP_XMX_REC_FFN steps:", len(steps))
for k, (n, s) in enumerate(steps):
    a = [int(x.strip()) for x in s.split(",")]
    print("%3d argc=%s args=%s" % (k, n, a))
