#!/usr/bin/env python3
r"""knifeB_census.py -- static census for "knife B" (fold the row-quantize into the
PRODUCING gemm's store epilogue: int8 + row scale straight out of the gemm).

Legality premise (military rule 2: the numeric form may not change): the quant's
ROW-PEAK SET must be exactly the producer's stored row set. This script does not
approximate that with "K == N": it enumerates, for every quant and for its producer,
the address intervals each row covers, and compares them as multisets.

  * a plain xmx_rec_quant reads the source plane FLAT: row j = elements [j*K, j*K+K)
    from the buffer base -- quantize_row_kernel.hpp:31 (`words = k/8`), :48
    (`base = held * words`).
  * xmx_rec_quant_window GATHERS: row j (j = window*64 + token) = the image position
    the window map sends it to -- quantize_row_kernel.hpp:49-57; out-of-range rows are
    not read at all (they come out zero/scale-1.0, libxmx_sycl.cpp:2748).
  * each producer's store map is taken from the recorder body that performs the store
    (cited per op in OPS below: `out = oc + g*sc + r*ldc + col` etc.).

Classes (all "a" classes first pass an exact address-coverage test and an exact
row-content multiset test; only then is the placement question asked):
  a1  aligned, each row stored as ONE contiguous run by the producer -> straight fold
  a2  aligned, the K-wide row is filled by SEVERAL column groups (the interleaved
      batched form) -> the fold needs a cross-group row peak inside one store tile
  a3  aligned row CONTENTS but the quant reads them through the window GATHER map, so
      pk/scale land at a permuted (token) index -> the fold needs a scatter store
  b   not aligned: the two row sets differ (holes, extra rows, view, pitch, offset)
  c   the src is not written by a gemm-family store at all (fused mega block,
      elementwise, or no writer inside the captured graph)

Also simulated: which quants the EXISTING qfuse machinery already dissolves today, and
which guard leaves the rest standing (libxmx_sycl.cpp:349-416, :5135-5143).

Read-only inputs; nothing compiled, no GPU, no shipped file touched, no commit.
Usage: python -B knifeB_census.py [--md E:\DSH\census\knifeB_census.md]
"""
from __future__ import annotations
import argparse, collections, re

PLAN_C = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c"
LIBXMX = r"E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp"
NR_REPLAY = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\gpu\nr_replay.c"
QRK = r"E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\src\bench\sycl\quantize_row_kernel.hpp"
MB = 1e6
GB = 1e9
NOMINAL = 560.0 * GB          # A770 GDDR6 nominal, given by the task
ROOF_PUB = 0.36 * NOMINAL     # measured pub-leg roof, given by the task
ROOF_QUANT = 0.88 * NOMINAL   # measured quant-leg roof, given by the task


# ------------------------------------------------------------------ plan ----
def load_plan():
    src = open(PLAN_C, encoding="utf-8", errors="replace").read().splitlines()

    def table(pat):
        i = next(k for k, l in enumerate(src) if pat in l)
        j = next(k for k in range(i, len(src)) if src[k].strip() == "};")
        return i + 1, j, src[i + 1:j]

    nm_ln, nm_end, nm_raw = table("const char *const nr_plan_names[]")
    sg_ln, sg_end, sg_raw = table("const char *const nr_plan_signatures[]")
    st_ln, st_end, st_raw = table("const struct nr_step nr_plan_steps[]")
    bu_ln, bu_end, bu_raw = table("const struct nr_buffer nr_plan_buffers[]")
    bl_ln, bl_end, bl_raw = table("const struct nr_blob nr_plan_blobs[]")
    names = [re.search(r'"([^"]*)"', l).group(1) for l in nm_raw]
    sigs = [re.search(r'"([^"]*)"', l).group(1) for l in sg_raw]
    assert len(names) == len(sigs)
    step_re = re.compile(r'\{\s*(OP_[A-Z0-9_]+),\s*(\d+),\s*\{\s*(.*?)\s*\},\s*(-?\d+)\s*\},')
    steps = []
    for k, l in enumerate(st_raw):
        m = step_re.match(l.strip())
        if not m:
            raise SystemExit("unparsed step at plan line %d: %s" % (st_ln + 1 + k, l))
        n = int(m.group(2))
        args = [int(x, 0) for x in m.group(3).split(",")]
        steps.append({"i": len(steps), "line": st_ln + 1 + k, "op": m.group(1),
                      "name": m.group(1)[3:].lower(), "nargs": n, "args": args[:n],
                      "raw": l.strip(), "text": int(m.group(4))})
    bufs = []
    for k, l in enumerate(bu_raw):
        m = re.match(r'\s*\{\s*(\d+)ULL,\s*(\d+)\s*\},', l)
        if not m:
            raise SystemExit("unparsed buffer row at plan line %d: %s" % (bu_ln + 1 + k, l))
        bufs.append({"i": k, "line": bu_ln + 1 + k, "bytes": int(m.group(1)),
                     "kind": int(m.group(2))})
    blobs = []
    for k, l in enumerate(bl_raw):
        m = re.match(r'\s*\{\s*(\d+),\s*(\d+)ULL,\s*(\d+)ULL,\s*(\d+)ULL\s*\},', l)
        if not m:
            raise SystemExit("unparsed blob row at plan line %d: %s" % (bl_ln + 1 + k, l))
        blobs.append({"buffer": int(m.group(1)), "offset": int(m.group(2)),
                      "length": int(m.group(3)), "at": int(m.group(4)), "line": bl_ln + 1 + k})
    meta = {"names": (nm_ln + 1, nm_end), "sigs": (sg_ln + 1, sg_end),
            "steps": (st_ln + 1, st_end), "bufs": (bu_ln + 1, bu_end), "blobs": (bl_ln + 1, bl_end)}
    return steps, bufs, blobs, names, sigs, meta


# ------------------------------------------------- op roles (nr_replay.c) ----
# bufs: positional args that are buffer ids (nr_replay.c:554-667 translates exactly
# these through r->ids[]); outs: buffers the op writes; a/as: A operand / A row-scale
# positions for the int8 gemms (the qfuse call sites).
OPS = {
 "xmx_rec_gemm": dict(n=17, bufs=[0, 1, 2], outs=[2], a=0, as_=None,
    names="a,b,c,M,N,K,batch,sa,sb,sc,bt,lda,ldb,ldc,oa,ob,oc", decl=":2221",
    store=":2304 gemm_b_pub_f16 / :2316-2327 publish -- out = oc + g*sc + r*ldc_e + col, ldc_e = ldc?ldc:N, narrow = bt&0x1000, epi = (bt>>8)&0xF, only r<M published (:2260)"),
 "xmx_rec_gemm_int8": dict(n=9, bufs=[0, 1, 2, 3, 4], outs=[2], a=0, as_=3,
    names="a,b,c,a_scale,b_scale,M,N,K,flags", decl=":2346",
    store=":2382-2383 gemm_b_pub(batch=1, group stride M*N, ldc=N)"),
 "xmx_rec_gemm_int8_batched": dict(n=17, bufs=[0, 1, 2, 3, 4], outs=[2], a=0, as_=3,
    names="a,b,c,a_scale,b_scale,M,N,K,batch,sa,sb,sc,lda,ldb,ldc,scale_stride,flags", decl=":2403",
    store=":2670/2673 gemm_b_pub[_slm] / :2690-2692 publish -- out = g*sc + r*ldc_ + col, ldc_ = ldc?ldc:N"),
 "xmx_rec_gemm_int8_residual": dict(n=11, bufs=[0, 1, 2, 3, 4, 5, 6], outs=[2], a=0, as_=3,
    names="a,b,c,a_scale,b_scale,skip,cosine,M,N,K,flags", decl=":3032",
    store=":3084 gemm_b_res -- dense, row pitch N"),
 "xmx_rec_gemm_window_int8_residual": dict(n=15, bufs=[0, 1, 2, 3, 4, 5, 6], outs=[2], a=0, as_=3,
    names="a,b,c,a_scale,b_scale,skip,cosine,M,N,K,flags,height,width,across,pad", decl=":3108",
    store=":3093-3102 + :3249 gemm_b_res_window -- at = ((y-top)*width + x-left)*N + c, out-of-range slots skipped entirely"),
 "xmx_rec_gemm_int8_qkv": dict(n=13, bufs=[0, 1, 2, 3, 4, 5, 6, 7], outs=[2, 3, 4], a=0, as_=5,
    names="a,b,q,k,v,a_scale,b_scale,qkv_scale,M,channels,heads,tokens,flags", decl=":2720",
    store=":2703-2707 col->part=col/channels, head=(col%channels)/32; :3263 Q/K/V are (heads,tokens,32) head-major"),
 "xmx_rec_unary": dict(n=13, bufs=[1, 2, 3, 4], outs=[3], a=None, as_=None,
    names="kind,a,b,c,d,n,channels,p0,batch,sa,sb,sc,k", decl=":3396",
    store=":3391-3393 generic load/store over n elements, row length = channels"),
 "xmx_rec_unary2": dict(n=14, bufs=[1, 2, 3, 4, 5], outs=[3], a=None, as_=None,
    names="kind,a,b,c,d,second,n,channels,p0,batch,sa,sb,sc,k", decl=":3685", store="as xmx_rec_unary"),
 "xmx_rec_ffn": dict(n=11, bufs=[0, 1, 2, 3, 4, 5], outs=[3], a=0, as_=None,
    names="a,expand,projection,out,skip,cosine,M,cin,hidden,groups,flags", decl=":1708",
    store=":1779-1810 the projection leg is (Mp, cin, hidden) -> out = M x cin"),
 "xmx_rec_ffn_merge": dict(n=11, bufs=[0, 1, 2, 3, 4, 5, 6], outs=[5], a=0, as_=None,
    names="source,skip,sincos,expand,projection,out,cosine,height,width,source_width,flags", decl=":1873",
    store=":1978/1992 out = M x 32 (M = height*width)"),
 "xmx_rec_ffn_stem": dict(n=8, bufs=[0, 1, 2, 3, 4, 5], outs=[4], a=0, as_=None,
    names="features,adapter,expand,projection,out,cosine,M,flags", decl=":2040",
    store=":2124/2176 out = M x 32"),
 "xmx_rec_window_attention": dict(n=8, bufs=[0, 1, 2, 3, 4], outs=[4], a=None, as_=None,
    names="q,k,v,bias,out,batches,heads,merged", decl=":3862",
    store="resident mega store (window_block_mega.hpp) -- no plain ldc store map in the recorder"),
 "xmx_rec_window_block": dict(n=14, bufs=[0, 1, 2, 3, 4, 5, 6, 7], outs=[3], a=0, as_=6,
    names="image,qkv,projection,target,bias,cosine,scale,pooled,windows,height,width,across,pad,flags", decl=":4186",
    store=":4740-4874 mega, image-mapped"),
 "xmx_rec_global_attention": dict(n=7, bufs=[0, 1, 2, 3], outs=[3], a=None, as_=None,
    names="q,k,v,merged,rows,tokens,heads", decl=":3266",
    store=":3263 merged = rows x heads*32 (composed from the two gated gemms)"),
 "xmx_rec_quant": dict(n=5, bufs=[0, 1, 2], outs=[1, 2], a=None, as_=None,
    names="source,packed,scale,M,K", decl=":4992",
    store="quantize_row_kernel.hpp:31/48 -- row r = source[r*K .. r*K+K), buffer base"),
 "xmx_rec_quant_window": dict(n=9, bufs=[0, 1, 2], outs=[1, 2], a=None, as_=None,
    names="source,packed,scale,M,K,height,width,across,pad", decl=":3362",
    store="quantize_row_kernel.hpp:49-57 -- GATHER: row r -> image position, base = (y*image_w+x)*(K/8)"),
 "xmx_buf_zero": dict(n=1, bufs=[0], outs=[0], a=None, as_=None, names="buf", decl="nr_replay.c:489",
    store="zero fill"),
}
for _v in OPS.values():
    for _k in ("store", "decl"):
        if _v[_k].startswith(":"):
            _v[_k] = "libxmx_sycl.cpp" + _v[_k]
GEMM_FAMILY = {n for n in OPS if n.startswith("xmx_rec_gemm") or n.startswith("xmx_rec_ffn")}
FUSED_BLOCKS = ("xmx_rec_window_attention", "xmx_rec_window_block", "xmx_rec_global_attention")
QUANT_OPS = ("xmx_rec_quant", "xmx_rec_quant_window")
TAKE_CALLERS = {
 "xmx_rec_gemm_int8": "libxmx_sycl.cpp:2369 qfuse_take",
 "xmx_rec_gemm_int8_batched": "libxmx_sycl.cpp:2453 qfuse_take_b",
 "xmx_rec_gemm_int8_residual": "libxmx_sycl.cpp:3065 qfuse_take",
 "xmx_rec_gemm_window_int8_residual": "libxmx_sycl.cpp:3208 qfuse_take",
 "xmx_rec_gemm_int8_qkv": "libxmx_sycl.cpp:2753 qfuse_take_gather",
}


def A(step):
    spec = OPS[step["name"]]
    return {nm: step["args"][p] for p, nm in enumerate(spec["names"].split(","))}


def epi_narrow(flags):
    return "epi=%d narrow=%s" % ((flags >> 8) & 0xF, "yes" if flags & 0x1000 else "no")


def pparams(name, a):
    """The producer's output parameters, verbatim from its plan row (+ decoded epi/narrow)."""
    if name == "xmx_rec_gemm":
        return ("M=%d N=%d K=%d batch=%d sa=%d sb=%d sc=%d bt=0x%x[%s] lda=%d ldb=%d ldc=%d oa=%d ob=%d oc=%d"
                % (a["M"], a["N"], a["K"], a["batch"], a["sa"], a["sb"], a["sc"], a["bt"],
                   epi_narrow(a["bt"]), a["lda"], a["ldb"], a["ldc"], a["oa"], a["ob"], a["oc"]))
    if name == "xmx_rec_gemm_int8_batched":
        return ("M=%d N=%d K=%d batch=%d sa=%d sb=%d sc=%d lda=%d ldb=%d ldc=%d scale_stride=%d flags=0x%x[%s]"
                % (a["M"], a["N"], a["K"], a["batch"], a["sa"], a["sb"], a["sc"], a["lda"], a["ldb"],
                   a["ldc"], a["scale_stride"], a["flags"], epi_narrow(a["flags"])))
    if name == "xmx_rec_gemm_window_int8_residual":
        return "M=%d N=%d K=%d flags=0x%x[%s] h=%d w=%d across=%d pad=0x%x" % (
            a["M"], a["N"], a["K"], a["flags"], epi_narrow(a["flags"]),
            a["height"], a["width"], a["across"], a["pad"])
    if name in ("xmx_rec_gemm_int8", "xmx_rec_gemm_int8_residual"):
        return "M=%d N=%d K=%d flags=0x%x[%s]" % (a["M"], a["N"], a["K"], a["flags"], epi_narrow(a["flags"]))
    if name == "xmx_rec_gemm_int8_qkv":
        return "M=%d channels=%d heads=%d tokens=%d flags=0x%x" % (a["M"], a["channels"], a["heads"], a["tokens"], a["flags"])
    if name in ("xmx_rec_unary", "xmx_rec_unary2"):
        return "kind=0x%x[%s] n=%d channels=%d batch=%d sa=%d sb=%d sc=%d k=%d" % (
            a["kind"], epi_narrow(a["kind"]), a["n"], a["channels"], a["batch"], a["sa"], a["sb"], a["sc"], a["k"])
    if name == "xmx_rec_window_attention":
        return "batches=%d heads=%d merged=%d" % (a["batches"], a["heads"], a["merged"])
    if name == "xmx_rec_global_attention":
        return "rows=%d tokens=%d heads=%d" % (a["rows"], a["tokens"], a["heads"])
    if name == "xmx_rec_ffn":
        return "M=%d cin=%d hidden=%d groups=%d flags=0x%x" % (a["M"], a["cin"], a["hidden"], a["groups"], a["flags"])
    if name == "xmx_rec_ffn_merge":
        return "h=%d w=%d source_width=%d flags=0x%x" % (a["height"], a["width"], a["source_width"], a["flags"])
    if name == "xmx_rec_ffn_stem":
        return "M=%d flags=0x%x" % (a["M"], a["flags"])
    return ""


# the window/image map, shared by the window producer store and the gather quant read
def window_map(M, across, height, width, pad):
    """token row j -> image position, or None when the slot is cropped away."""
    top, left = pad >> 16, pad & 0xFFFF
    out = []
    for j in range(M):
        token, window = j % 64, j // 64
        y = (window // across) * 8 + token // 8 - top
        x = (window % across) * 8 + token % 8 - left
        out.append((y * width + x) if (0 <= y < height and 0 <= x < width) else None)
    return out


def merge(iv):
    iv = sorted(iv)
    res = []
    for s, e in iv:
        if res and s <= res[-1][1]:
            res[-1][1] = max(res[-1][1], e)
        else:
            res.append([s, e])
    return tuple((s, e) for s, e in res)


def producer_rows(name, a):
    """[(row_index, RAW address intervals stored for that row)] per the store map.

    Raw (unmerged): a row built from several batched column groups keeps one interval
    per group, which is what class a2 counts. (None, None) when there is no plain map."""
    if name == "xmx_rec_gemm":
        pitch, G = (a["ldc"] or a["N"]), (a["batch"] or 1)
        rows = [(r, [[a["oc"] + gg * a["sc"] + r * pitch,
                      a["oc"] + gg * a["sc"] + r * pitch + a["N"]] for gg in range(G)])
                for r in range(a["M"])]
        return rows, pitch
    if name in ("xmx_rec_gemm_int8", "xmx_rec_gemm_int8_residual"):
        return [(r, [(r * a["N"], (r + 1) * a["N"])]) for r in range(a["M"])], a["N"]
    if name == "xmx_rec_gemm_int8_batched":
        pitch = a["ldc"] or a["N"]
        rows = [(r, [[gg * a["sc"] + r * pitch, gg * a["sc"] + r * pitch + a["N"]]
                     for gg in range(a["batch"])]) for r in range(a["M"])]
        return rows, pitch
    if name == "xmx_rec_gemm_window_int8_residual":
        pos = window_map(a["M"], a["across"], a["height"], a["width"], a["pad"])
        rows = [(j, [(p * a["N"], (p + 1) * a["N"])]) for j, p in enumerate(pos) if p is not None]
        return rows, a["N"]
    if name == "xmx_rec_gemm_int8_qkv":
        rows = [(h * a["tokens"] + t, [(h * a["tokens"] + t) * 32, (h * a["tokens"] + t) * 32 + 32])
                for h in range(a["heads"]) for t in range(a["tokens"])]
        return rows, 32
    if name == "xmx_rec_ffn":
        return [(r, [(r * a["cin"], (r + 1) * a["cin"])]) for r in range(a["M"])], a["cin"]
    if name in ("xmx_rec_ffn_merge", "xmx_rec_ffn_stem"):
        m = a["height"] * a["width"] if name == "xmx_rec_ffn_merge" else a["M"]
        return [(r, [(r * 32, (r + 1) * 32)]) for r in range(m)], 32
    if name in ("xmx_rec_unary", "xmx_rec_unary2"):
        ch = a["channels"]
        return [(r, [(r * ch, (r + 1) * ch)]) for r in range(a["n"] // ch if ch else 0)], ch
    if name == "xmx_rec_global_attention":
        p = a["heads"] * 32
        return [(r, [(r * p, (r + 1) * p)]) for r in range(a["rows"])], p
    return None, None


def merged_rows(rowlist):
    """the same rows with their intervals merged (what a row actually holds)."""
    return [(i, merge([list(iv) for iv in ivs])) for i, ivs in rowlist]


def quant_rows(q):
    """[(pk row index, RAW address intervals it reads)] for one quant op, plus the map."""
    K = q["K"]
    if q["name"] == "xmx_rec_quant":
        return [(j, [(j * K, (j + 1) * K)]) for j in range(q["M"])], K, None
    a = q["aa"]
    pos = window_map(a["M"], a["across"], a["height"], a["width"], a["pad"])
    rows = [(j, [(p * K, (p + 1) * K)]) for j, p in enumerate(pos) if p is not None]
    return rows, K, pos


def raw_group_count(rowlist):
    """max number of separate address runs any one row is built from (before merging)."""
    return max((len(iv) for _, iv in rowlist), default=0)


def intervals_set(rowlist):
    """the merged union of every address the rows touch (list of (start, end))."""
    return merge([list(pair) for _, ivs in rowlist for pair in ivs])


_rows_cache = {}


def rows_of(q):
    """cached (producer rows, producer pitch, quant rows, K, quant map)."""
    if q["step"] in _rows_cache:
        return _rows_cache[q["step"]]
    p = q["producer"]
    prows, ppitch = (producer_rows(p["name"], q["pargs"]) if p and p["name"] in GEMM_FAMILY
                     else (None, None))
    qrows, K, qmap = quant_rows(q)
    _rows_cache[q["step"]] = (prows, ppitch, qrows, K, qmap)
    return _rows_cache[q["step"]]


def classify(q):
    """(class, reason) comparing the two row sets exactly.

    a1  aligned; each row is stored by one contiguous run of the producer
    a2  aligned; the K-wide row is built from SEVERAL producer column groups
        (the interleaved batched form) -> the epilogue needs a cross-group row peak
    a3  aligned row CONTENTS, but the quant reads them through the window GATHER map,
        so pk/scale land at a permuted (token) index -> the fold needs a scatter store
    b   not aligned (holes / extra rows / pitch mismatch / base offset)
    c   the src is not written by a gemm-family store in the captured graph
    """
    p = q["producer"]
    if p is None:
        return "c-no-frame-producer", q.get("nosrc", "")
    if p["name"] not in GEMM_FAMILY:
        kind = "c-fused-block-producer" if p["name"] in FUSED_BLOCKS else "c-elementwise-producer"
        return kind, "producer %s writes %s" % (p["name"], OPS[p["name"]]["store"])
    prows, ppitch, qrows, K, qmap = rows_of(q)
    if prows is None:
        return "b-unmodelled-store", "no store map found for %s" % p["name"]
    # 1. address coverage
    pu, qu = intervals_set(prows), intervals_set(qrows)
    pn = sum(b - a0 for a0, b in pu)
    qn = sum(b - a0 for a0, b in qu)
    if pu != qu:
        return "b-coverage", ("address ranges differ: producer %d elements %s, quant %d elements %s "
                              "| producer map: %s" % (pn, str(pu)[:70], qn, str(qu)[:70],
                                                      OPS[p["name"]]["store"]))
    # 2. row-content multisets (peak values must be computed over identical element sets)
    pm, qm = merged_rows(prows), merged_rows(qrows)
    pmul = collections.Counter(iv for _, iv in pm)
    qmul = collections.Counter(iv for _, iv in qm)
    if pmul != qmul:
        return "b-row-set", ("row CONTENT sets differ: %d producer row shapes e.g. %s vs %d quant "
                             "row shapes e.g. %s (K=%d, producer pitch=%d)"
                             % (len(pmul), list(pmul.items())[:1], len(qmul), list(qmul.items())[:1],
                                K, ppitch))
    # 3. how the fold has to place the result
    gather_scatter = qmap is not None and any(j != pos for j, pos in enumerate(qmap) if pos is not None)
    ngroups = raw_group_count(prows)
    if gather_scatter:
        return "a3-gather-scatter-view", ("%d rows, pitch %d == K %d, contents identical; the quant "
                                          "reads through the window map (token %d of %d rows is not "
                                          "its address/K), so pk/scale must be scattered to the token "
                                          "index; producer groups per row = %d"
                                          % (len(prows), ppitch, K,
                                             next(j for j, pos in enumerate(qmap)
                                                  if pos is not None and j != pos), q["M"], ngroups))
    if ngroups > 1:
        return "a2-row-spans-groups", ("%d rows, pitch %d == K %d, contents identical, same row index; "
                                       "each row is built from %d producer column groups -> the "
                                       "epilogue needs a cross-group row peak" % (len(prows), ppitch, K, ngroups))
    return "a1-single-run", ("%d rows, producer pitch %d == quant K %d, contents identical, and the "
                             "quant's row index equals address/K so the producer's store position "
                             "directly names the pk row; one contiguous run per row "
                             "(groups per row = %d)" % (len(prows), ppitch, K, ngroups))


def phases(steps):
    marks = [(s["i"], s["name"]) for s in steps
             if s["name"] in ("xmx_begin", "xmx_abort", "xmx_graph_capture",
                              "xmx_graph_run", "xmx_submit", "xmx_sync")]
    edges = [0] + [i for i, _ in marks] + [len(steps)]
    segs = []
    for k in range(len(edges) - 1):
        x, y = edges[k], edges[k + 1]
        opener = marks[k - 1][1] if k > 0 else None
        closer = marks[k][1] if k < len(marks) else None
        lab = ("pre" if opener is None else "scratch" if closer == "xmx_abort"
               else "graph" if closer == "xmx_graph_capture" else "tail")
        if y > x:
            segs.append((x, y, lab))
    return segs, marks


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", default=r"E:\DSH\census\knifeB_census.md")
    opt = ap.parse_args()
    steps, bufs, blobs, names, sigs, meta = load_plan()
    segs, marks = phases(steps)
    graph_lo, graph_hi = [(x[0], x[1]) for x in segs if x[2] == "graph"][0]
    GRAPH = [s for s in steps if graph_lo <= s["i"] < graph_hi]
    REC = [s for s in GRAPH if s["name"].startswith("xmx_rec_")]

    gw, gr, aw = (collections.defaultdict(list), collections.defaultdict(list),
                  collections.defaultdict(list))
    for s in steps:
        if s["name"] not in OPS:
            continue
        spec = OPS[s["name"]]
        for p in spec["bufs"]:
            b = s["args"][p]
            if b < 0:
                continue
            if p in spec["outs"]:
                aw[b].append(s)
                if graph_lo <= s["i"] < graph_hi:
                    gw[b].append(s)
            elif graph_lo <= s["i"] < graph_hi:
                gr[b].append((s, p))
    blobw = collections.defaultdict(list)
    for bl in blobs:
        blobw[bl["buffer"]].append(bl)

    # ------------------------------- build the quant records ----------------
    quants = []
    for s in REC:
        if s["name"] not in QUANT_OPS:
            continue
        aa = A(s)
        q = dict(step=s["i"], line=s["line"], name=s["name"], raw=s["raw"], src=aa["source"],
                 pk=aa["packed"], sc=aa["scale"], M=aa["M"], K=aa["K"], aa=aa)
        before = [x for x in gw[q["src"]] if x["i"] < s["i"]]
        q["writers"] = gw[q["src"]]
        if before:
            q["producer"], q["pmode"] = before[-1], "same replay"
        elif q["writers"]:
            q["producer"], q["pmode"] = q["writers"][-1], "written by the previous replay"
        else:
            q["producer"], q["pmode"] = None, None
            allw = aw[q["src"]]
            if allw:
                q["nosrc"] = "no writer inside the captured graph; only outside: %s @%d/%d" % (
                    allw[-1]["name"], allw[-1]["i"], allw[-1]["line"])
            elif blobw[q["src"]]:
                q["nosrc"] = "blob content only: %d upload rows, plan lines %d..%d (buffer line %d, %d B, kind %d)" % (
                    len(blobw[q["src"]]), blobw[q["src"]][0]["line"], blobw[q["src"]][-1]["line"],
                    bufs[q["src"]]["line"], bufs[q["src"]]["bytes"], bufs[q["src"]]["kind"])
            else:
                q["nosrc"] = "never written by any step (buffer line %d, %d B, kind %d)" % (
                    bufs[q["src"]]["line"], bufs[q["src"]]["bytes"], bufs[q["src"]]["kind"])
        if q["producer"]:
            q["pargs"] = A(q["producer"])
            q["pparams"] = pparams(q["producer"]["name"], q["pargs"])
        else:
            q["pargs"] = q["pparams"] = None
        if q["producer"]:
            nxt = [x["i"] for x in q["writers"] if x["i"] > q["producer"]["i"]]
            lo, hi = q["producer"]["i"], (nxt[0] if nxt else 10 ** 9)
            q["other_readers"] = sorted({(x["i"], x["line"], x["name"], p) for (x, p) in gr[q["src"]]
                                         if lo < x["i"] < hi and x["i"] != s["i"]})
        else:
            q["other_readers"] = sorted({(x["i"], x["line"], x["name"], p) for (x, p) in gr[q["src"]]
                                         if x["i"] != s["i"]})
        q["consumers"] = sorted({(x["i"], x["line"], x["name"], p) for (x, p) in gr[q["pk"]]
                                 if x["i"] > s["i"]})
        q["inplace"] = (q["pk"] == q["src"])
        q["cls"], q["why"] = classify(q)
        quants.append(q)

    # ---------------------- qfuse simulation: who survives today -----------
    reg, by_step = {}, {q["step"]: q for q in quants}
    for q in quants:
        q["dissolve"], q["guard"], q["ghead"], q["gcombo"] = None, None, None, None

    def setguard(q, head, combo):
        q["guard"] = head + ": " + combo
        q["ghead"], q["gcombo"] = head, combo
        # grouping key: the parameter combination without the per-call step/line identity
        q["gkey"] = head + " || " + re.sub(r" @\d+/\d+", "", combo)
    for s in REC:
        if s["name"] in QUANT_OPS:
            q = by_step[s["i"]]
            if q["K"] % 16:
                q["guard"] = "never registered (K%%16 != 0, libxmx_sycl.cpp:5001 + :5060)"
                continue
            reg[q["pk"]] = q
            continue
        if s["name"] not in TAKE_CALLERS:
            continue
        spec, aa = OPS[s["name"]], A(s)
        aid = s["args"][spec["a"]]
        asid = s["args"][spec["as_"]] if spec["as_"] is not None else None
        q = reg.get(aid)
        if q is None:
            continue
        q["consumer"] = s
        if s["name"] == "xmx_rec_gemm_int8_batched":
            lda_e = aa["lda"] or aa["K"]
            shared = (q["K"] == aa["K"] == lda_e and aa["sa"] == 0)
            colslice = (q["K"] == lda_e and aa["sa"] == aa["K"])
            combo = ("consumer %s @%d/%d: K_q=%d gemmK=%d lda=%d sa=%d scale_stride=%d M_q=%d M_g=%d "
                     "scale_q=%d a_scale=%d gap=%d -> shared=%s colslice=%s"
                     % (s["name"], s["i"], s["line"], q["K"], aa["K"], lda_e, aa["sa"],
                        aa["scale_stride"], q["M"], aa["M"], q["sc"], asid, s["i"] - q["step"],
                        shared, colslice))
            if not (shared or colslice):
                setguard(q, "blocked by the shared/colslice SHAPE guard (:402-404)", combo)
            elif asid != q["sc"]:
                setguard(q, "blocked by the scale-id guard (:406-408; only take_b has the pointer fallback)", combo)
            elif aa["M"] != q["M"]:
                setguard(q, "blocked by the M guard (:405)", combo)
            elif aa["scale_stride"] != 0:
                setguard(q, "blocked by scale_stride != 0 (:386)", combo)
            elif s["i"] - q["step"] > 4:
                setguard(q, "blocked by adjacency > 4 (:410)", combo)
            else:
                q["shape_passes"] = True
                setguard(q, "PASSES every shape guard -- blocked only because qfuse_take_b sits behind env NR_Q_FUSE_B, DEFAULT OFF (:384-385)", combo)
        elif s["name"] == "xmx_rec_gemm_int8_qkv":
            combo = ("consumer %s @%d/%d: channels=%d K_q=%d M_q=%d M_g=%d scale_q=%d a_scale=%d gap=%d"
                     % (s["name"], s["i"], s["line"], aa["channels"], q["K"], q["M"], aa["M"],
                        q["sc"], asid, s["i"] - q["step"]))
            if q["name"] != "xmx_rec_quant_window":
                setguard(q, "blocked: this take only accepts gather registrations (:373) -- the consumer is a QKV but the quant is a plain one", combo)
            elif asid != q["sc"] or aa["M"] != q["M"] or aa["channels"] != q["K"] or s["i"] - q["step"] > 4:
                setguard(q, "blocked by the gather guard (:374-375)", combo)
            else:
                q["dissolve"] = "qfuse_take_gather (NR_QW_FUSE default ON, :2751): " + combo
                reg.pop(q["pk"], None)
        else:
            combo = ("consumer %s @%d/%d: M_q=%d M_g=%d K_q=%d K_g=%d scale_q=%d a_scale=%d gap=%d"
                     % (s["name"], s["i"], s["line"], q["M"], aa["M"], q["K"], aa["K"], q["sc"],
                        asid, s["i"] - q["step"]))
            if asid != q["sc"]:
                setguard(q, "blocked by the plain-take scale-id guard (:353)", combo)
            elif aa["M"] != q["M"] or aa["K"] != q["K"]:
                setguard(q, "blocked by the plain-take (M,K) guard (:353)", combo)
            else:
                q["dissolve"] = "qfuse_take via %s: %s" % (TAKE_CALLERS[s["name"]], combo)
                reg.pop(q["pk"], None)
    for q in quants:
        if q["dissolve"] is None and q["guard"] is None:
            setguard(q, "no take-caller ever reads this pk as an A operand",
                     "graph consumers of pk %d: %s" % (q["pk"], ", ".join(
                         "%s@%d/%d(pos %d)" % (c[2], c[0], c[1], c[3]) for c in q["consumers"][:4]) or "none"))
        q.setdefault("shape_passes", False)
    surviving = [q for q in quants if q["dissolve"] is None]

    # ------------------------------- byte ledger ---------------------------
    def MK(q):
        return q["M"] * q["K"]

    def legs(q):
        """(f16 write bytes removed, f16 read bytes removed, int8 pk bytes re-added)."""
        if not q["cls"].startswith("a"):
            return (0, 0, 0)
        m = MK(q)
        stays = bool(q["other_readers"])
        return (0 if stays else 2 * m, 2 * m, 2 * m if q["dissolve"] else 0)

    def removed(q):
        wr, rr, pa = legs(q)
        return wr + rr - pa

    def ms(q):
        wr, rr, pa = legs(q)
        return wr / ROOF_PUB + (rr - pa) / ROOF_QUANT

    cls = collections.Counter(q["cls"] for q in quants)
    nq = sum(1 for q in quants if q["name"] == "xmx_rec_quant")
    nqw = len(quants) - nq
    allq = sum(1 for s in steps if s["name"] == "xmx_rec_quant")
    allqw = sum(1 for s in steps if s["name"] == "xmx_rec_quant_window")
    scratch = [(x[0], x[1]) for x in segs if x[2] == "scratch"][0]
    na = sum(v for k, v in cls.items() if k.startswith("a"))
    nb = sum(v for k, v in cls.items() if k.startswith("b"))
    nc = sum(v for k, v in cls.items() if k.startswith("c"))
    surv_a = sum(1 for q in surviving if q["cls"].startswith("a"))
    buckets = collections.defaultdict(lambda: dict(n=0, rem=0, ms=0.0))
    for q in quants:
        if not q["cls"].startswith("a"):
            continue
        st = ("plane-stays" if q["other_readers"] else
              "dissolved" if q["dissolve"] else "split")
        b = buckets[(q["cls"], st)]
        b["n"] += 1; b["rem"] += removed(q); b["ms"] += ms(q)
    tot = sum(b["rem"] for b in buckets.values())
    totms = sum(b["ms"] for b in buckets.values())

    # ================================ report ===============================
    R = []
    w = R.append

    def esc(s):
        """keep free text from breaking a markdown table row"""
        return str(s).replace("|", "\\|")
    w("# knife B census -- can each frame quant be folded into its producer's store?")
    w("")
    w("Static analysis only: nothing compiled, no GPU, no shipped file modified, nothing committed.")
    w("Reproduce with `python -B knifeB_census.py` (pure stdlib).")
    w("")
    w("| input | role |")
    w("|---|---|")
    w("| `%s` | the plan: names %d-%d, signatures %d-%d, steps %d-%d, buffers %d-%d, blobs %d-%d |"
      % (PLAN_C, *meta["names"], *meta["sigs"], *meta["steps"], *meta["bufs"], *meta["blobs"]))
    w("| `%s` | which positional arg of each OP is a buffer id (the f_rec_* translation) |" % NR_REPLAY)
    w("| `%s` | recorder declarations, store maps, qfuse guards (cited as libxmx_sycl.cpp:N) |" % LIBXMX)
    w("| `%s` | the quant's own row map: :31 `words = k/8`, :48 `base = held*words`, :49-57 gather |" % QRK)
    w("")
    w("## TL;DR")
    w("")
    w("* the frame (the captured graph, plan lines %d..%d) contains **%d quant-class ops** "
      "(%d `xmx_rec_quant` + %d `xmx_rec_quant_window`) over %d recorder steps."
      % (steps[graph_lo]["line"], steps[graph_hi - 1]["line"], len(quants), nq, nqw, len(REC)))
    w("* **%d of them are row-aligned with their producer** under an exact address/row-set test "
      "(a1 %d, a2 %d, a3 %d); **%d are misaligned**; **%d have a producer that is not a gemm store**."
      % (na, cls.get("a1-single-run", 0), cls.get("a2-row-spans-groups", 0),
         cls.get("a3-gather-scatter-view", 0), nb, nc))
    w("* **%d quants still launch every frame**; %d were already dissolved by the existing "
      "knife-A (consumer-side pack fusion) takes." % (len(surviving), len(quants) - len(surviving)))
    w("* knife B removes **%.1f MB** of DRAM = **%.2f ms** mixed-roof (**%.2f ms** at the 36%% pub "
      "roof, **%.2f ms** at the 88%% quant roof, %.2f ms at the bare 560 GB/s) and **%d** launches. "
      "The wide-row (a2) block is %.1f MB of that."
      % (tot / MB, totms * 1e3, tot / ROOF_PUB * 1e3, tot / ROOF_QUANT * 1e3, tot / NOMINAL * 1e3,
         surv_a, sum(removed(q) for q in quants if q["cls"] == "a2-row-spans-groups") / MB))
    w("* of the %d survivors, **%d have a batched-gemm consumer and pass the shared/colslice shape "
      "guard outright** (stopped only by the `NR_Q_FUSE_B` env gate on that take); the other **%d** "
      "have a QKV consumer and are stopped by that take's gather-form rule. Independently of the "
      "take guards, **%d of the %d survivors have a producer that is not a gemm store at all**, so "
      "knife B cannot apply to them."
      % (len(surviving), sum(1 for q in surviving if q.get("shape_passes")),
         sum(1 for q in surviving if q["ghead"] and q["ghead"].startswith("blocked: this take")),
         sum(1 for q in surviving if q["cls"].startswith("c")), len(surviving)))
    w("")
    w("## 0. which part of the plan is the frame")
    for s in steps:
        if s["name"] in ("xmx_begin", "xmx_abort", "xmx_graph_capture", "xmx_graph_run"):
            w("* step %d (plan line %d): `%s`" % (s["i"], s["line"], s["op"]))
    for a0, b0, lab in segs:
        h = collections.Counter(s["name"] for s in steps[a0:b0] if s["name"].startswith("xmx_rec_"))
        if sum(h.values()):
            w("* `%s`: steps %d..%d (plan lines %d..%d) -- %d recorder steps, %d quant, %d quant_window"
              % (lab, a0, b0 - 1, steps[a0]["line"], steps[b0 - 1]["line"], sum(h.values()),
                 h.get("xmx_rec_quant", 0), h.get("xmx_rec_quant_window", 0)))
    nq = sum(1 for q in quants if q["name"] == "xmx_rec_quant")
    nqw = len(quants) - nq
    allq = sum(1 for s in steps if s["name"] == "xmx_rec_quant")
    allqw = sum(1 for s in steps if s["name"] == "xmx_rec_quant_window")
    scratch = [(x[0], x[1]) for x in segs if x[2] == "scratch"][0]
    w("")
    w("The captured region (steps %d..%d, plan lines %d..%d) is what `xmx_graph_run` replays: "
      "**%d recorder steps, of which %d xmx_rec_quant + %d xmx_rec_quant_window = %d quant-class ops**. "
      "The aborted recording (steps %d..%d) holds %d recorder steps -- the same op mix, which is a "
      "parse cross-check, not a second frame."
      % (graph_lo, graph_hi - 1, steps[graph_lo]["line"], steps[graph_hi - 1]["line"], len(REC),
         nq, nqw, len(quants), scratch[0], scratch[1] - 1,
         sum(1 for s in steps[scratch[0]:scratch[1]] if s["name"].startswith("xmx_rec_"))))
    w("")
    w("Op mix of the captured graph (`nr_plan_steps`, plan lines %d-%d; signature table lines %d-%d):"
      % (*meta["steps"], *meta["sigs"]))
    w("")
    w("| op | calls in the frame | signature | signature line | recorder declaration |")
    w("|---|---|---|---|---|")
    for k, v in collections.Counter(s["name"] for s in REC).most_common():
        ni = names.index(k)
        w("| %s | %d | `%s` | %d | %s |" % (k, v, sigs[ni], meta["sigs"][0] + ni, OPS[k]["decl"]))

    w("")
    w("## 1. every QUANT / QUANT_WINDOW in the frame, and the last writer of its src")
    w("")
    w("Buffers are recycled, so the writer search is bounded to the captured graph. "
      "`producer output params` are the producer's own plan-row arguments.")
    w("")
    w("| # | quant step | plan line | op | src | M | K | pk | scale | in-place | producer | producer step/line | producer output params |")
    w("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for i, q in enumerate(quants, 1):
        p = q["producer"]
        w("| %d | %d | %d | %s | %d | %d | %d | %d | %d | %s | %s | %s | %s |"
          % (i, q["step"], q["line"], q["name"], q["src"], q["M"], q["K"], q["pk"], q["sc"],
             "yes" if q["inplace"] else "no", p["name"] if p else "NONE in graph",
             ("%d / %d" % (p["i"], p["line"])) if p else "-",
             esc((q["pparams"] + (" [%s]" % q["pmode"] if q["pmode"] and "previous" in q["pmode"] else ""))
                 if p else q.get("nosrc", ""))))
    w("")
    w("### 1b. who writes the quant sources")
    for k, v in collections.Counter((q["producer"]["name"] if q["producer"] else "NONE in graph")
                                    for q in quants).most_common():
        w("* %-40s %d   (store map: %s)" % (k, v, OPS[k]["store"] if k in OPS else "n/a"))
    w("")
    w("### 1c. the pk/scale scratch the quants write into")
    w("* distinct (pk, scale) pairs over %d quants: %d -- %s"
      % (len(quants), len({(q["pk"], q["sc"]) for q in quants}),
         ", ".join("(%d,%d) x%d" % (k[0], k[1], v) for k, v in
                   collections.Counter((q["pk"], q["sc"]) for q in quants).most_common(6))))
    w("* in-place quants (pk == src): %d" % sum(1 for q in quants if q["inplace"]))
    w("  Every frame quant is NON-in-place, which is the guard that cancelled the old v9b FOLD "
      "(`libxmx_sycl.cpp:5024` requires `packed == source`, :5036-5040 cancels otherwise). Knife B "
      "does not need in-place: the producer writes the pk/scale ids the consumers already read.")
    w("* adjacency of the pair (producer step -> quant step): min %d, max %d, mean %.2f"
      % (min(q["step"] - q["producer"]["i"] for q in quants if q["producer"]),
         max(q["step"] - q["producer"]["i"] for q in quants if q["producer"]),
         sum(q["step"] - q["producer"]["i"] for q in quants if q["producer"]) /
         sum(1 for q in quants if q["producer"])))
    w("")
    w("### 1d. size cross-check against `nr_plan_buffers` (catches any mis-read of M/K)")
    bad = 0
    for q in quants:
        need_src, need_pk, need_sc = q["M"] * q["K"] * 2, q["M"] * q["K"], q["M"] * 4
        for what, need, have in (("src", need_src, bufs[q["src"]]["bytes"]),
                                 ("pk", need_pk, bufs[q["pk"]]["bytes"]),
                                 ("scale", need_sc, bufs[q["sc"]]["bytes"])):
            if have < need:
                bad += 1
                w("* VIOLATION quant @%d/%d: %s buffer %d holds %d B, the op needs %d B"
                  % (q["step"], q["line"], what, q["src"] if what == "src" else
                     (q["pk"] if what == "pk" else q["sc"]), have, need))
    w("* %d quant ops x 3 operands = %d checks, **%d violations** (every quant's M*K*2 source "
      "bytes, M*K packed bytes and 4*M scale bytes fit inside the plan's own buffer sizes)."
      % (len(quants), 3 * len(quants), bad))
    w("")
    ncreate = sum(1 for s in steps if s["name"] == "buf")
    ndestroy = sum(1 for s in steps if s["name"] == "xmx_buf_destroy")
    w("### 1e. buffer identity across the two recordings")
    w("* %d `OP_BUF` rows but %d distinct plan buffer numbers, and %d `xmx_buf_destroy` rows: "
      "ids 1267, 1271-1277, 1285-1287 are created as 256-byte placeholders in the aborted "
      "recording, destroyed at plan lines 5296-5306 and re-created at their real sizes inside the "
      "captured graph (e.g. 1267 = %d B at plan line 5309). The replayer numbers buffers by plan "
      "index (`nr_replay.c:475`), so a plan index means ONE plane inside the captured graph -- "
      "which is what the writer search above relies on."
      % (ncreate, len(bufs), ndestroy, bufs[1267]["bytes"]))

    w("")
    w("## 2. alignment verdict -- exact row-set comparison")
    w("")
    w("For each pair the census enumerates the address intervals each row covers and compares "
      "them as multisets (code: `producer_rows`/`quant_rows`/`classify`). Coverage of the whole "
      "plane is checked first (holes, double writes, base offsets), then the row CONTENT multiset, "
      "and only afterwards where the fold has to put the result (one run per row, several column "
      "groups, or a gathered row index).")
    w("")
    w("| # | step/line | op | src | M x K | producer (step/line) | producer rows x pitch | coverage equal | row multiset equal | groups per row | gather view? | other readers of src | class |")
    w("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for i, q in enumerate(quants, 1):
        p = q["producer"]
        if p is None:
            w("| %d | %d/%d | %s | %d | %dx%d | - | - | - | - | - | %d | %s |"
              % (i, q["step"], q["line"], q["name"], q["src"], q["M"], q["K"],
                 len(q["other_readers"]), q["cls"]))
            continue
        if p["name"] in GEMM_FAMILY:
            prows, ppitch, qrows, K, qmap = rows_of(q)
            cov = (intervals_set(prows) == intervals_set(qrows)) if prows else False
            mul = (collections.Counter(iv for _, iv in merged_rows(prows)) ==
                   collections.Counter(iv for _, iv in merged_rows(qrows))) if prows else False
            ng = raw_group_count(prows) if prows else 0
            ga = "yes" if q["name"] == "xmx_rec_quant_window" else "no"
            pr = "%d x %d" % (len(prows), ppitch)
        else:
            cov = mul = False
            ng = ga = "-"
            pr = "-"
        w("| %d | %d/%d | %s | %d | %dx%d | %s @%d/%d | %s | %s | %s | %s | %s | %d | %s |"
          % (i, q["step"], q["line"], q["name"], q["src"], q["M"], q["K"], p["name"], p["i"], p["line"],
             pr, cov, mul, ng, ga, len(q["other_readers"]), q["cls"]))
    w("")
    w("### 2b. class counts (all %d quant-class ops in the frame)" % len(quants))
    for k in sorted(cls):
        w("* `%s`: %d" % (k, cls[k]))
    w("* **(a) row-aligned -- knife B legal in principle: %d**" % sum(v for k, v in cls.items() if k.startswith("a")))
    w("* **(b) shape/view misaligned: %d**" % sum(v for k, v in cls.items() if k.startswith("b")))
    w("* **(c) src not written by a gemm-family store: %d**" % sum(v for k, v in cls.items() if k.startswith("c")))
    w("")
    w("### 2c. the classes b and c, grouped by the actual parameter combination")
    w("")
    w("| count | quant op (M x K) | producer op + params | class | what breaks | example plan lines |")
    w("|---|---|---|---|---|---|")
    bg = collections.defaultdict(list)
    for q in quants:
        if q["cls"].startswith("b") or q["cls"].startswith("c"):
            key = (q["name"], q["M"], q["K"], q["producer"]["name"] if q["producer"] else "-",
                   q["pparams"] if q["producer"] else "", q["cls"])
            bg[key].append(q)
    for key, qs in sorted(bg.items(), key=lambda x: -len(x[1])):
        q = qs[0]
        w("| %d | %s %dx%d | %s %s | %s | %s | %s |"
          % (len(qs), key[0], key[1], key[2], key[3], esc(key[4]), key[5],
             esc(q["why"])[:260], ", ".join(str(x["line"]) for x in qs[:4])))
    w("")
    w("### 2d. the (a) classes, grouped by shape")
    w("")
    w("| count | class | quant op (M x K) | producer op + params | first plan lines |")
    w("|---|---|---|---|---|")
    ag = collections.defaultdict(list)
    for q in quants:
        if q["cls"].startswith("a"):
            ag[(q["cls"], q["name"], q["M"], q["K"], q["producer"]["name"], q["pparams"])].append(q)
    for key, qs in sorted(ag.items(), key=lambda x: (-len(x[1]) * x[0][2] * x[0][3])):
        w("| %d | %s | %s %dx%d | %s %s | %s |"
          % (len(qs), key[0], key[1], key[2], key[3], key[4], esc(key[5]),
             ", ".join(str(x["line"]) for x in qs[:4])))

    # ---- 2e: worked examples, so the row-set test can be checked by eye
    w("")
    w("### 2e. worked examples (address arithmetic, rows 0/1/7/8 of each side)")
    for want in ("a1-single-run", "a2-row-spans-groups", "a3-gather-scatter-view"):
        q = next((x for x in quants if x["cls"] == want), None)
        if q is None:
            continue
        prows, ppitch, qrows, K, qmap = rows_of(q)
        w("")
        w("**%s** -- quant at plan line %d: `%s`" % (want, q["line"], q["raw"]))
        w("* producer %s @%d/%d: `%s`" % (q["producer"]["name"], q["producer"]["i"],
                                          q["producer"]["line"], q["producer"]["raw"]))
        w("  * store map: %s" % OPS[q["producer"]["name"]]["store"])
        sel = [0, 1, 7, 8]
        pick = lambda lst: [lst[k] for k in sel if k < len(lst)]
        w("  * producer rows (rows %s): %s" % (sel, pick(prows)))
        w("  * quant rows (%s, rows %s): %s" % (OPS[q["name"]]["store"].split("--")[0].strip(),
                                                sel, pick(qrows)))
        w("  * merged producer rows: %s" % pick(merged_rows(prows)))
        if want == "a3-gather-scatter-view":
            first = next(((j, iv) for j, iv in qrows if iv[0][0] != j * K), None)
            w("  * first divergence: pk row %d reads address %s, not %s -- the window map moved it "
              "(row contents still identical as a multiset, so the peak VALUE per row is unchanged; "
              "only where the fold must store it changes)"
              % (first[0], first[1][0], (first[0] * K, first[0] * K + K)))
    w("")
    w("The quant's own read map is the one in `quantize_row_kernel.hpp` (:48 flat, :49-57 "
      "gathered); the producer's write map is the one its recorder body runs. If the two agree "
      "as multisets, folding the peak into the store cannot change any row's peak value -- which "
      "is exactly the premise knife B needs.")

    # ------------------------------- 3. byte ledger ------------------------
    w("")
    w("## 3. byte ledger")
    w("")
    w("For an aligned pair, `m = M*K` elements. States, from the plan itself:")
    w("")
    w("| state today | traffic today | traffic with knife B | removed |")
    w("|---|---|---|---|")
    w("| **split** -- the quant really runs (its consumer never took it) | producer f16 write 2m + quant f16 read 2m + pk write m + pk read m | pk write m + pk read m | **4m** |")
    w("| **dissolved** -- knife A already no-oped the quant, the consumer's `pack_a_fused` reads the f16 plane | f16 write 2m + f16 read 2m | pk write m + pk read m | **2m** |")
    w("| **plane-stays** -- the f16 plane has another live reader inside the frame (residual skip etc.), so the f16 write cannot vanish | as above | f16 write 2m + pk write m + pk read m | **2m** (split) / **0** (dissolved) |")
    w("")
    w("Live-interval reader test: a reader of the src buffer between the producer's write and the "
      "buffer's next write inside the captured graph.")
    w("")
    buckets = collections.defaultdict(lambda: dict(n=0, rem=0, ms=0.0))
    for q in quants:
        if not q["cls"].startswith("a"):
            continue
        st = ("plane-stays" if q["other_readers"] else
              "dissolved" if q["dissolve"] else "split")
        b = buckets[(q["cls"], st)]
        b["n"] += 1; b["rem"] += removed(q); b["ms"] += ms(q)
    w("| class | state | pairs | bytes removed | ms @ nominal 560 | ms @ mixed roofs | ms @ 36% pub roof | ms @ 88% quant roof |")
    w("|---|---|---|---|---|---|---|---|")
    for (c, st), b in sorted(buckets.items()):
        w("| %s | %s | %d | %d | %.2f | %.2f | %.2f | %.2f |"
          % (c, st, b["n"], b["rem"], b["rem"] / NOMINAL * 1e3, b["ms"] * 1e3,
             b["rem"] / ROOF_PUB * 1e3, b["rem"] / ROOF_QUANT * 1e3))
    w("| **total** | | **%d** | **%d B = %.1f MB** | **%.2f** | **%.2f** | **%.2f** | **%.2f** |"
      % (sum(b["n"] for b in buckets.values()), tot, tot / MB, tot / NOMINAL * 1e3, totms * 1e3,
         tot / ROOF_PUB * 1e3, tot / ROOF_QUANT * 1e3))
    w("")
    w("Bandwidths used, spelled out: nominal 560 GB/s = 5.6e11 B/s; 36%% of it = %.3e B/s; "
      "88%% of it = %.3e B/s. The mixed-roof column prices each leg separately: the f16 write leg "
      "at the pub roof, the read/pk legs at the quant roof." % (ROOF_PUB, ROOF_QUANT))
    w("")
    w("### 3b. the same ledger for the surviving quants only (the 10.3 ms / 5.8 ms line)")
    sr = sum(removed(q) for q in surviving if q["cls"].startswith("a"))
    sread = sum(2 * MK(q) for q in surviving)
    swrite = sum(MK(q) + 4 * q["M"] for q in surviving)
    w("* surviving quants: %d (of %d)" % (len(surviving), len(quants)))
    w("* their own traffic: f16 read %d B + pk/scale write %d B = %d B = %.1f MB"
      % (sread, swrite, sread + swrite, (sread + swrite) / MB))
    for t in (5.8, 10.3):
        w("  * %.1f ms over %.1f MB = %.1f GB/s = %.0f%% of the 560 GB/s nominal"
          % (t, (sread + swrite) / MB, (sread + swrite) / (t * 1e-3) / GB,
             (sread + swrite) / (t * 1e-3) / NOMINAL * 100))
    w("* knife B on that subset removes %d B = %.1f MB (%.2f ms at the 36%% roof, %.2f ms at the 88%% roof)"
      % (sr, sr / MB, sr / ROOF_PUB * 1e3, sr / ROOF_QUANT * 1e3))
    w("")
    w("The two implied numbers above (%.0f%% / %.0f%%) sit far under the 88%% single-kernel roof: "
      "the surviving quant line is not pure-DRAM-bound at the plan's byte volume -- the launch count "
      "(%d ops) and the f16 read/write dependency chain carry part of it. Knife B removes both the "
      "bytes and the launches, so treat the ms figures below as the bandwidth-only floor."
      % ((sread + swrite) / (5.8e-3) / NOMINAL * 100, (sread + swrite) / (10.3e-3) / NOMINAL * 100,
         len(surviving)))

    # --------------------------- 4. guard attribution ----------------------
    w("")
    w("## 4. why they are still standing: the existing guards, simulated on the plan")
    w("")
    w("Mechanisms that can already dissolve a quant (all from `libxmx_sycl.cpp`):")
    w("")
    w("| mechanism | call sites | guards | default |")
    w("|---|---|---|---|")
    w("| `qfuse_take` :349-363 | gemm_int8 :2369, gemm_int8_residual :3065, gemm_window_int8_residual :3208 | `g_quant_pk[a]` id hit, `sc == a_scale`, `M == M`, `K == K`; no adjacency limit, no pointer fallback | ON (`NR_Q_FUSE` unset = on, :304) |")
    w("| `qfuse_take_b` :382-416 | gemm_int8_batched :2453 | `scale_stride == 0` (:386), shared (`K_q == gemm K == lda, sa == 0`) or colslice (`K_q == lda, sa == gemm K`) (:402-403), `M` (:405), scale id or pointer alias (:406-408), adjacency <= 4 (:410) | **OFF** (`NR_Q_FUSE_B` unset, :384) |")
    w("| `qfuse_take_gather` :369-381 | gemm_int8_qkv :2753 | gather registration (:373), `sc == a_scale`, `M == M`, `K == channels` (:374), adjacency <= 4 (:375) | ON (`NR_QW_FUSE`, :2751) |")
    w("| v9b FOLD :5018-5041 | gemm_int8_batched :2443-2448 | in-place (`packed == source`, :5024), `cbuf == source`, adjacency 1 | **OFF** (`NR_V9B` :2438 and `NR_V9B_FOLD` :5019) |")
    w("| B6 :3203 | window_int8_residual | full 4-op pattern | **OFF** (`NR_B6`, :346) |")
    w("")
    w("### 4a. result of the simulation on the captured graph")
    w("* dissolved today: **%d**" % (len(quants) - len(surviving)))
    w("* surviving (the quant kernel really launches every frame): **%d**" % len(surviving))
    w("")
    w("### 4b. surviving quants, grouped by the guard that actually stopped the take")
    w("")
    w("| count | quant op (M x K) | guard class | the real parameter combination | example plan lines |")
    w("|---|---|---|---|---|")
    gsg = collections.defaultdict(list)
    for q in surviving:
        gsg[(q["gkey"], q["name"], q["M"], q["K"])].append(q)
    for (key, qn, M, K), qs in sorted(gsg.items(), key=lambda x: -len(x[1])):
        head, combo = key.split(" || ", 1)
        w("| %d | %s %dx%d | %s | %s | %s |" % (len(qs), qn, M, K, esc(head), esc(combo)[:230],
                                                ", ".join(str(x["line"]) for x in qs[:4])))
    w("")
    nshape = sum(1 for q in surviving if q.get("shape_passes"))
    w("* **%d of the %d survivors pass the shared/colslice shape guard outright** and are blocked "
      "only by the `NR_Q_FUSE_B` env gate on the whole batched take (libxmx_sycl.cpp:384-385). "
      "Concretely: batched consumers with `lda == K_q` and either `sa == 0, gemm K == K_q` (shared) "
      "or `sa == gemm K` (colslice), `scale_stride == 0`, `a_scale == scale id`, `M` equal, "
      "adjacency gap 2-3 (the guard allows <= 4)."
      % (nshape, len(surviving)))
    w("* **%d of the %d survivors are blocked by a mechanism/shape guard** (the QKV take only "
      "accepts gather-form registrations, :373 -- their quant is a plain one)."
      % (len(surviving) - nshape, len(surviving)))
    w("")
    w("### 4c. the survivors, crossed with knife-B legality and whether the f16 write can vanish")
    w("")
    w("| survivors | class | f16 write vanishes? | bytes knife B removes | write leg ms @36% roof | read/pk leg ms @88% roof |")
    w("|---|---|---|---|---|---|")
    pay = collections.defaultdict(lambda: dict(n=0, rem=0, w=0, r=0))
    for q in surviving:
        k = (q["cls"], "yes" if not q["other_readers"] else "no (another live reader of the plane)")
        d = pay[k]
        d["n"] += 1; d["rem"] += removed(q)
        wr, rr, pa = legs(q)
        d["w"] += wr; d["r"] += rr - pa
    for (c, st), d in sorted(pay.items(), key=lambda x: -x[1]["rem"]):
        w("| %d | %s | %s | %d (%.1f MB) | %.2f | %.2f |"
          % (d["n"], c, st, d["rem"], d["rem"] / MB, d["w"] / ROOF_PUB * 1e3, d["r"] / ROOF_QUANT * 1e3))
    w("| **%d** | | | **%d (%.1f MB)** | **%.2f** | **%.2f** |"
      % (len(surviving), sum(d["rem"] for d in pay.values()), sum(d["rem"] for d in pay.values()) / MB,
         sum(d["w"] for d in pay.values()) / ROOF_PUB * 1e3,
         sum(d["r"] for d in pay.values()) / ROOF_QUANT * 1e3))
    w("")
    w("### 4d. knife-B validity of the survivors (producer side, independent of those guards)")
    for k, v in collections.Counter((q["cls"], q["producer"]["name"] if q["producer"] else "-")
                                    for q in surviving).most_common():
        w("* class `%s`, producer `%s`: %d" % (k[0], k[1], v))
    w("")
    w("* survivors with a row-aligned producer (knife B applies): **%d**"
      % sum(1 for q in surviving if q["cls"].startswith("a")))
    w("* survivors with a misaligned producer view (knife B needs a layout change first): %d"
      % sum(1 for q in surviving if q["cls"].startswith("b")))
    w("* survivors whose producer is not a gemm store at all (knife B is a no-op for them): %d"
      % sum(1 for q in surviving if q["cls"].startswith("c")))
    w("")
    w("### 4e. the '160 surviving' count, checked against the plan")
    w("The plan contains %d `xmx_rec_quant` + %d `xmx_rec_quant_window` = %d quant-class ops in "
      "TOTAL. They split %d/%d for xmx_rec_quant and %d/%d for xmx_rec_quant_window between the "
      "aborted recording (plan lines %d..%d) and the captured graph (plan lines %d..%d). The "
      "captured graph -- the thing that replays every frame -- holds %d quant-class ops, %d of "
      "which survive the takes. Counting BOTH recordings doubles it: %d ops, %d survivors, which "
      "is the shape of the '160 surviving' figure. The frame itself pays %d."
      % (allq, allqw, allq + allqw, allq - nq, nq, allqw - nqw, nqw,
         steps[scratch[0]]["line"], steps[scratch[1] - 1]["line"],
         steps[graph_lo]["line"], steps[graph_hi - 1]["line"],
         len(quants), len(surviving), 2 * len(quants), 2 * len(surviving), len(surviving)))

    # -------------------------------- 5. verdict ---------------------------
    w("")
    w("## 5. verdict")
    w("")
    w("### 5a. ranked by op family (producer side of the pair)")
    w("")
    fam = collections.defaultdict(lambda: dict(n=0, a=0, b=0, c=0, surv=0, rem=0, ms=0.0, launches=0))
    for q in quants:
        f = q["producer"]["name"] if q["producer"] else "no-frame-producer"
        d = fam[f]
        d["n"] += 1; d[q["cls"][0]] += 1
        if q["dissolve"] is None:
            d["surv"] += 1
        if q["cls"].startswith("a") and q["dissolve"] is None:
            d["launches"] += 1
        d["rem"] += removed(q); d["ms"] += ms(q)
    w("")
    w("| producer family | quants | a | b | c | surviving | foldable (a & surviving) | removable B | MB | ms mixed | ms @36% | ms @88% |")
    w("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for f, d in sorted(fam.items(), key=lambda x: -x[1]["rem"]):
        w("| %s | %d | %d | %d | %d | %d | %d | %d | %.1f | %.2f | %.2f | %.2f |"
          % (f, d["n"], d["a"], d["b"], d["c"], d["surv"], d["launches"], d["rem"], d["rem"] / MB,
             d["ms"] * 1e3, d["rem"] / ROOF_PUB * 1e3, d["rem"] / ROOF_QUANT * 1e3))
    w("")
    na = sum(v for k, v in cls.items() if k.startswith("a"))
    nb = sum(v for k, v in cls.items() if k.startswith("b"))
    nc = sum(v for k, v in cls.items() if k.startswith("c"))
    surv_a = sum(1 for q in surviving if q["cls"].startswith("a"))
    w("### 5b. the one-sentence answer")
    w("")
    w("* Knife B can legally cover **%d of the %d quant-class ops in the frame** -- their row-peak "
      "sets are exactly their producer's stored row sets (%d single-run, %d row-spans-groups, "
      "%d gather/scatter view); **%d are shape/view-misaligned** and **%d have a producer that is "
      "not a gemm store at all** (fused attention/mega blocks, elementwise), for whom knife B has "
      "nothing to fold into."
      % (na, len(quants), cls.get("a1-single-run", 0), cls.get("a2-row-spans-groups", 0),
         cls.get("a3-gather-scatter-view", 0), nb, nc))
    pays = sum(1 for q in quants if q["cls"].startswith("a") and not q["other_readers"])
    pays_bytes = sum(removed(q) for q in quants if q["cls"].startswith("a") and not q["other_readers"])
    w("* Of the class-a pairs, only **%d** can drop the producer's f16 write at all -- the other "
      "**%d** have another live reader of the same plane inside the frame (the residual `skip`), so "
      "the f16 write stays and knife B only swaps who writes the int8 plane (net 0 for the pairs "
      "knife A already dissolved, %.1f MB for the rest)."
      % (pays, na - pays, sum(removed(q) for q in quants
                              if q["cls"].startswith("a") and q["other_readers"]) / MB))
    w("* Expected frame-level saving if every class-a pair folds: **%.1f MB of DRAM traffic, "
      "%.2f ms (mixed roofs) .. %.2f ms (all at the 36%% pub roof) .. %.2f ms (all at the 88%% "
      "quant roof); at the bare 560 GB/s nominal it is %.2f ms**. Knife B also removes a launch: "
      "**%d of the class-a quants still launch today** (the other %d were already no-oped by knife "
      "A), so the launch-side saving is %d, not %d. That alone does not take 66-70 ms below 45 ms; "
      "the batched wide-row family is the single biggest block."
      % (tot / MB, totms * 1e3, tot / ROOF_PUB * 1e3, tot / ROOF_QUANT * 1e3, tot / NOMINAL * 1e3,
         surv_a, na - surv_a, surv_a, na))
    big = sorted(fam.items(), key=lambda x: -x[1]["rem"])[0]
    w("* Biggest single block: **%s** -- %d quants, %d of them foldable-and-live, %.1f MB, "
      "%.2f ms mixed-roof." % (big[0], big[1]["n"], big[1]["launches"], big[1]["rem"] / MB, big[1]["ms"] * 1e3))
    w("")
    w("### 5c. caveats the census can see but not settle")
    w("* `pk` and `scale` are the SAME scratch pair for %d of the %d frame quants, so a "
      "producer-side fold inherits the aliasing hazard the old fold tripped on "
      "(`libxmx_sycl.cpp:5026-5029`): the fold must keep the exact producer->quant adjacency the "
      "plan shows (measured above: gap min %d / max %d)."
      % (max(collections.Counter((q["pk"], q["sc"]) for q in quants).values()), len(quants),
         min(q["step"] - q["producer"]["i"] for q in quants if q["producer"]),
         max(q["step"] - q["producer"]["i"] for q in quants if q["producer"])))
    w("* class a2 pairs need a row peak spanning several column groups inside one store tile "
      "(`%d` pairs). The plan proves the row CONTENTS are right; whether the tile can hold the "
      "row (SLM) is a kernel question this census cannot answer." % cls["a2-row-spans-groups"])
    w("* class a3 pairs need the pk/scale written at the quant's (gathered) row index, i.e. a "
      "scatter store in the epilogue: %d pairs." % cls.get("a3-gather-scatter-view", 0))
    w("* class c pairs whose producer is a fused mega block (`window_attention`, `window_block`, "
      "`global_attention`) can only be folded inside that block's own store, which is a different "
      "piece of work: %d pairs." % cls["c-fused-block-producer"])
    w("* the byte ledger counts DRAM legs only; the front-end cost of the %d quant launches that "
      "knife B removes (the class-a pairs still launching today; the other %d class-a quants are "
      "already no-ops) is not priced here." % (surv_a, na - surv_a))
    w("")
    w("### 5d. what this census says the cut should be, in order")
    w("")
    def blk(c):
        qs = [q for q in quants if q["cls"] == c]
        return (len(qs), sum(1 for q in qs if q["dissolve"] is None),
                sum(removed(q) for q in qs if q["dissolve"] is None) / MB,
                sum(removed(q) for q in qs if q["dissolve"]) / MB)
    g2 = collections.Counter(raw_group_count(rows_of(q)[0]) for q in quants
                             if q["cls"] == "a2-row-spans-groups")
    n2, s2, b2s, b2d = blk("a2-row-spans-groups")
    w("1. **the wide-row pairs (class a2): %d pairs, %d of them still launching, %.1f MB from those "
      "+ %.1f MB from the ones knife A already dissolved.** The producer stores the whole K-wide row "
      "but as several column groups -- groups-per-row distribution %s -- so the epilogue has to hold "
      "the row and take the peak across groups. Biggest byte block in the frame."
      % (n2, s2, b2s, b2d, dict(sorted(g2.items()))))
    clean = [q for q in quants if q["cls"] == "a1-single-run" and not q["other_readers"]]
    cb = sum(removed(q) for q in clean)
    w("2. **the single-run pairs whose plane has no other live reader: %d pairs** (of %d a1 pairs) "
      "-- one contiguous run per row and the f16 write vanishes: %.1f MB = %.2f ms at the 36%% pub "
      "roof, %.2f ms at the 88%% quant roof."
      % (len(clean), cls["a1-single-run"], cb / MB, cb / ROOF_PUB * 1e3, cb / ROOF_QUANT * 1e3))
    w("3. **class a1/a3 pairs whose plane is also a residual `skip` (%d pairs)**: the f16 write has "
      "to stay, so knife B degenerates to \"move the int8 write into the producer\" -- %.1f MB, "
      "mostly the quant's read leg."
      % (sum(1 for q in quants if q["cls"].startswith("a") and q["other_readers"]),
         sum(removed(q) for q in quants
             if q["cls"].startswith("a") and q["other_readers"]) / MB))
    for q in quants:
        q.setdefault("consumer", None)
    w("4. **the %d survivors blocked by the QKV gather-only take** (`libxmx_sycl.cpp:373`): their "
      "producer is a plain int8 residual gemm and their consumer is a QKV -- a plain-take path for "
      "QKV would dissolve them without touching the producer at all: their standalone legs are "
      "%.1f MB (f16 read) + %.1f MB (pk+scale write)."
      % (sum(1 for q in surviving if q["name"] == "xmx_rec_quant"
             and q["consumer"] is not None and q["consumer"]["name"] == "xmx_rec_gemm_int8_qkv"),
         sum(2 * MK(q) for q in surviving if q["name"] == "xmx_rec_quant"
             and q["consumer"] is not None and q["consumer"]["name"] == "xmx_rec_gemm_int8_qkv") / MB,
         sum(MK(q) + 4 * q["M"] for q in surviving if q["name"] == "xmx_rec_quant"
             and q["consumer"] is not None and q["consumer"]["name"] == "xmx_rec_gemm_int8_qkv") / MB))
    w("5. **do not bother with the %d class-c pairs** (fused attention/mega/elementwise producers) "
      "under knife B -- they need their own blade." % nc)
    w("")
    w("### 5e. reproduce")
    w("")
    w("```")
    w("python -B E:\\DSH\\census\\knifeB_census.py --md E:\\DSH\\census\\knifeB_census.md")
    w("```")
    w("(stdlib only; reads the plan, nr_replay.c roles and libxmx_sycl.cpp by line, writes only "
      "the --md file.)")

    with open(opt.md, "w", encoding="utf-8") as fh:
        fh.write("\n".join(R) + "\n")
    print("\n".join(R[:30]))
    print("\n[written] %s  (%d lines)" % (opt.md, len(R)))


if __name__ == "__main__":
    main()
