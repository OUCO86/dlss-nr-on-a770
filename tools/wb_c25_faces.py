import sys, re, collections
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
SRC = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
t = open(SRC, encoding="utf-8", errors="replace").read()
steps = re.findall(r"\{\s*(OP_[A-Z_0-9]+),\s*(\d+),\s*\{([^}]*)\}", t)
FACES = [1267, 1285, 1286, 1287, 1274, 1275, 1276, 1277, 1270, 1288]
# arg-position roles per op (from the recorder signatures in libxmx_sycl.cpp)
ROLES = {
 "OP_XMX_REC_QUANT": "R,W,W,-,-",
 "OP_XMX_REC_QUANT_WINDOW": "R,W,W,-,-,-",
 "OP_XMX_REC_GEMM_INT8": "R,W,Wc,Ws,Wb,-,-,-,-",
 "OP_XMX_REC_GEMM_INT8_QKV": "R,Wb,Wq,Wk,Wv,Ws,Wbs,Wcos,-,-,-,-,-,-",
 "OP_XMX_REC_GLOBAL_ATTENTION": "Rq,Rk,Rv,Wm,-,-,-",
 "OP_XMX_REC_GEMM_INT8_RESIDUAL": "R,Wb,Wc,Ws,Wbs,Rsk,Wcos,-,-,-,-",
 "OP_XMX_REC_WINDOW_ATTENTION": "Rq,Rk,Rv,Rb,Wo,-,-,-,-,-",
 "OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL": "R,Wb,Wc,Ws,Wbs,Rsk,Wcos,-,-,-,-",
 "OP_XMX_BUF_ZERO": "?",
}
for f in FACES:
    hits = []
    for j, (o, n, s) in enumerate(steps):
        a = [int(x.strip(), 0) for x in s.split(",")]
        for pos, v in enumerate(a):
            if v == f:
                role = ""
                if o in ROLES:
                    r = ROLES[o].split(",")
                    role = r[pos] if pos < len(r) else "-"
                hits.append((j, o, pos, role))
    kinds = collections.Counter((o, pos) for j, o, pos, role in hits)
    print("=== face %d : %d mentions ===" % (f, len(hits)))
    for (o, pos), c in sorted(kinds.items(), key=lambda x: x[0][0]):
        print("    %-40s argpos=%d count=%d" % (o, pos, c))
    print("    first 12:", hits[:12])
    print("    last 8:", hits[-8:])
    print()
