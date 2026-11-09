import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c26_timeline.py -- ZERO-GPU face lifecycle proof for the C26 (S2) skip set.
# Walks the KEPT recording of plan_960x544.c (OP_XMX_BEGIN #2 .. OP_XMX_GRAPH_CAPTURE),
# assigns a PLAIN-route closure index to every REC_* op (1:1), and prints, for the faces
# 1267 / 1285 / 1286 / 1287 / 1271 / 1274, the ordered writer/reader timeline with the
# closure index and the arg role. The question this answers: if we dissolve [entry GEMM ..
# last attention residual], does any SURVIVING closure read a face that only the dissolved
# set wrote (=> stale-by-design) or that nobody wrote this frame (=> garbage)?
SRC = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
t = open(SRC, encoding="utf-8", errors="replace").read()
steps = re.findall(r"\{\s*(OP_[A-Z_0-9]+),\s*(\d+),\s*\{([^}]*)\}", t)
# find the kept recording: second OP_XMX_BEGIN .. GRAPH_CAPTURE
begins = [i for i, (o, n, s) in enumerate(steps) if o == "OP_XMX_BEGIN"]
cap = [i for i, (o, n, s) in enumerate(steps) if o == "OP_XMX_GRAPH_CAPTURE"][0]
b = begins[-1]
print("kept recording: plan idx %d .. %d" % (b, cap))
ROLES = {
 "OP_XMX_REC_QUANT": "R,W,W",
 "OP_XMX_REC_QUANT_WINDOW": "R,W,W",
 "OP_XMX_REC_GEMM": "R,R,W",
 "OP_XMX_REC_GEMM_INT8": "R,R,W,R,R",
 "OP_XMX_REC_GEMM_INT8_BATCHED": "R,R,W,R,R",
 "OP_XMX_REC_GEMM_INT8_QKV": "R,R,W,W,W,R,R,R",
 "OP_XMX_REC_GEMM_INT8_RESIDUAL": "R,R,W,R,R,R,R",
 "OP_XMX_REC_GEMM_WINDOW_INT8_RESIDUAL": "R,R,W,R,R,R,R",
 "OP_XMX_REC_GLOBAL_ATTENTION": "R,R,R,W",
 "OP_XMX_REC_WINDOW_ATTENTION": "R,R,R,R,W",
 "OP_XMX_REC_FFN": "R,R,R,W,R,R",
 "OP_XMX_REC_FFN_STEM": "R,R,R,R,W,R",
 "OP_XMX_REC_FFN_MERGE": "R,R,R,R,R,W,R",
 "OP_XMX_REC_WINDOW_BLOCK": "R,R,R,W,R,R,R,W",
 "OP_XMX_REC_UNARY": "kind,R,R,W,R",
 "OP_XMX_REC_UNARY2": "kind,R,W,W,R,R",
 "OP_XMX_REC_VIT_SOFTMAX": "R,W,R",
 "OP_XMX_REC_MERGE_HEADS_SCALE": "R,W,R",
 "OP_XMX_REC_PRE": "?",
 "OP_XMX_REC_POST": "?",
}
rows = []   # (closure idx, plan idx, op, args, roles)
ci = 0
for j in range(b, cap + 1):
    o, n, s = steps[j]
    if not o.startswith("OP_XMX_REC_"):
        continue
    a = [int(x.strip(), 0) for x in s.split(",")]
    roles = ROLES.get(o, "")
    rows.append((ci, j, o, a, roles))
    ci += 1
print("plain-route REC_* closures in the kept recording = %d (expect 691)" % ci)
# the ViT segment anchors
ga = [r for r in rows if r[2] == "OP_XMX_REC_GLOBAL_ATTENTION"]
print("GA closures (plain idx): %s" % [r[0] for r in ga])
qk = [r for r in rows if r[2] == "OP_XMX_REC_GEMM_INT8_QKV" and len(r[3]) > 12 and r[3][12] == 8192]
print("vit QKV closures (flags 8192): %s" % [r[0] for r in qk])
res = [r for r in rows if r[2] == "OP_XMX_REC_GEMM_INT8_RESIDUAL"]
print("int8_residual closures: %d" % len(res))
# entry GEMM: the GEMM whose output == 1285; exit GEMM: the GEMM whose input == 1285
ent = [r for r in rows if r[2] == "OP_XMX_REC_GEMM" and len(r[3]) > 2 and r[3][2] == 1285]
exi = [r for r in rows if r[2] == "OP_XMX_REC_GEMM" and len(r[3]) > 0 and r[3][0] == 1285]
print("entry GEMM (c=1285): %s   exit GEMM (a=1285): %s" % ([(r[0], r[1], r[3][:4]) for r in ent],
                                                            [(r[0], r[1], r[3][:4]) for r in exi]))
# the last attention residual of the segment = the RES writing 1285 nearest before the exit GEMM
if exi:
    ex = exi[0][0]
    attn_res = [r for r in res if r[0] < ex and len(r[3]) > 2 and r[3][2] == 1285]
    seg_end = attn_res[-1][0]
    print("segment span (plain closure idx): %d .. %d ; n=%d ; fused idx = +1" % (ent[0][0], seg_end, seg_end - ent[0][0] + 1))
# timeline for the faces that matter
def face_timeline(face):
    ev = []
    for (c, j, o, a, roles) in rows:
        for pos, v in enumerate(a):
            if v != face:
                continue
            role = roles.split(",")[pos] if pos < len(roles.split(",")) else "?"
            ev.append((c, o.replace("OP_XMX_REC_", ""), role, pos))
    return ev
for face in (1267, 1285, 1271, 1286, 1287):
    ev = face_timeline(face)
    print("\n=== face %d : %d events (closure idx, op, role, argpos) ===" % (face, len(ev)))
    # compact: group by op+role with the idx list
    g = collections.OrderedDict()
    for c, o, role, pos in ev:
        g.setdefault((o, role, pos), []).append(c)
    for k, v in g.items():
        s = ",".join(str(x) for x in v[:14]) + ("...(+%d)" % (len(v) - 14) if len(v) > 14 else "")
        print("   %-28s role=%-4s argpos=%d n=%3d  [%s]" % (k[0], k[1], k[2], len(v), s))
    # the decisive question: between the last IN-SEGMENT writer and the next writer/reader
    if exi:
        ex = exi[0][0]
        w_in = [c for c, o, role, pos in ev if role in ('W', 'Wc', 'Wq', 'Wk', 'Wv', 'Wm') and ent[0][0] <= c <= ex]
        r_after = [c for c, o, role, pos in ev if role.startswith('R') and c > ex]
        w_after = [c for c, o, role, pos in ev if role in ('W', 'Wc', 'Wq', 'Wk', 'Wv', 'Wm') and c > ex]
        print("   in-segment writers: %d (last=%s) ; first reader after segment=%s ; first writer after segment=%s"
              % (len(w_in), w_in[-1] if w_in else None, r_after[0] if r_after else None, w_after[0] if w_after else None))
print("\n=== done wb_c26_timeline ===")
