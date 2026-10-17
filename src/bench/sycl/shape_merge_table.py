#!/usr/bin/env python3
# shape_merge_table.py — OFFLINE projection: what does merging small-M passes of the
# SAME (N,K) group into one big-M pass buy?  Nothing here touches the scheduler; this
# table decides whether the merge is worth funding BEFORE any kernel work.
#
# Baseline (what the shipped frame ACTUALLY runs, per notes/frame-ledger-a770.md
# 2026-10-11 re-measure, device 34.61 ms):
#   gemm/30 int8 staged   0.048 ms/pass   (188 passes)
#   tiled/0 fp16 staged   0.065 ms/pass   (130 passes)
# Merged cost model: device-time from the width sweep (notes/int8-width-sweep.md,
# int8 column = staged gemm_int8, the honest engine comparison) at the nearest
# measured (M,N,K) grid point. The fused-requant kernels (v3 N=64, v2 N=128) measured
# 8.3-15.7 TOPS at big M, inside the sweep's int8 band, so the sweep is a fair proxy
# for the single-world target form. Merging an fp16 group ALSO flips the engine to
# int8 — that is the whole point of the single world.
#
# Merge legality (section 27 red lines), checked per group:
#   R8a: merged M >= 8160 (int8 break-even) — groups below stay fp16/stage-internal.
#   Same (N,K) is the CANDIDATE condition; same WEIGHT is the hard requirement and
#   the ledger does not record weight identity — so every row is an UPPER BOUND
#   (assumes all passes in the group share one weight). Groups where the bound is
#   small are dead regardless of weight identity: no refinement needed. Groups where
#   the bound is large get a follow-up probe in nr_resident.py.
# Dispatch saving: EAGER submit = 8.8 us/pass (section 17 probe, A770/120W).

import re, math
from collections import defaultdict

LEDGER = r"E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/work/ledger-20261011.txt"
OUT    = r"E:/WorkBuddy/2026-10-09-04-20-55/src/dlss-nr-on-a770/notes/shape-merge-projection.md"

# width sweep int8 staged device-ms grid: (M,N,K) -> ms   (notes/int8-width-sweep.md)
SWEEP = [
 (640,32,64,.064),(640,32,128,.065),(640,32,256,.068),
 (640,128,64,.063),(640,128,128,.066),(640,128,256,.069),
 (640,256,64,.064),(640,256,128,.065),(640,256,256,.070),
 (640,1024,64,.064),(640,1024,128,.067),(640,1024,256,.070),
 (8160,32,64,.064),(8160,32,128,.067),(8160,32,256,.075),
 (8160,128,64,.068),(8160,128,128,.071),(8160,128,256,.080),
 (8160,256,64,.085),(8160,256,128,.092),(8160,256,256,.110),
 (8160,1024,64,.151),(8160,1024,128,.181),(8160,1024,256,.251),
 (32640,32,64,.069),(32640,32,128,.077),(32640,32,256,.084),
 (32640,128,64,.107),(32640,128,128,.131),(32640,128,256,.172),
 (32640,256,64,.157),(32640,256,128,.195),(32640,256,256,.270),
 (32640,1024,64,.409),(32640,1024,128,.542),(32640,1024,256,.834),
 (130560,32,64,.118),(130560,32,128,.146),(130560,32,256,.200),
 (130560,128,64,.294),(130560,128,128,.379),(130560,128,256,.581),
 (130560,256,64,.512),(130560,256,128,.725),(130560,256,256,1.091),
 (130560,1024,64,1.819),(130560,1024,128,2.673),(130560,1024,256,4.143),
]
Ms = sorted({m for m,_,_,_ in SWEEP}); Ns = sorted({n for _,n,_,_ in SWEEP}); Ks = sorted({k for _,_,k,_ in SWEEP})
GRID = {(a,b,c):ms for a,b,c,ms in SWEEP}

def nearest(m,n,k):
    def pick(axis,v): return min(axis, key=lambda a: abs(math.log(a)-math.log(v)))
    M,N,K = pick(Ms,m), pick(Ns,n), pick(Ks,k)
    return M,N,K,GRID[(M,N,K)]

def tops(m,n,k,ms): return 2.0*m*n*k/(ms/1e3)/1e12

# parse ledger GEMM rows: site kind M N K count
rows=[]
pat = re.compile(r"^\s{2}(\S+)\s+(gemm_int8_qkv|gemm_int8|gemm)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$")
for line in open(LEDGER, encoding="utf-8", errors="ignore"):
    mm = pat.match(line.rstrip())
    if mm:
        site,kind,M,N,K,cnt = mm.group(1),mm.group(2),int(mm.group(3)),int(mm.group(4)),int(mm.group(5)),int(mm.group(6))
        k = "int8" if kind.startswith("gemm_int8") else "fp16"
        rows.append((site,k,M,N,K,cnt))

BASE = {"int8":0.048, "fp16":0.065}   # ledger-measured ms/pass, shipped form

groups=defaultdict(list)
for site,k,M,N,K,cnt in rows:
    groups[(N,K)].append((site,k,M,cnt))

L=[]
L.append("# 形状合并离线投影（2026-10-17，§7⑥/R8a；纯离线，不动调度器）\n")
L.append("账本=`work/ledger-20261011.txt`（768x448 帧，device 34.61ms）。现状基线=账本实测 ms/pass")
L.append("（int8 staged 0.048、fp16 tiled 0.065）——**出货真正跑的形态**，不是我造的（§27 教训）。")
L.append("合并后=int8 staged 宽度扫描最近邻（单一世界目标形态代理）。每行=**上界**（假设组内所有")
L.append("趟共享同一 weight；账本不记 weight 身份——上界小的组直接结案，上界大的才去 nr_resident 细化）。")
L.append("dispatch 省=(趟数-1)×8.8us（§17 EAGER submit 实测）。R8a 列=合并后 ΣM 是否≥8160。\n")
L.append("| (N,K) | 趟数 | ΣM | 现状ms | 合并后ms@最近邻 | 核省ms | disp省ms | 合计省ms | R8a |")
L.append("|---|---|---|---|---|---|---|---|---|")

tot_cur=tot_mg=tot_disp=0.0; npass_cur=npass_mg=0
big=[]
for (N,K),items in sorted(groups.items(), key=lambda kv:-sum(c for _,_,_,c in kv[1])):
    cnt=sum(c for _,_,_,c in items)
    cur=sum(BASE[k]*c for _,k,_,c in items)
    if cnt<2:
        continue
    sm=sum(M*c for _,_,M,c in items)
    nM,nN,nK,mg = nearest(sm,N,K)
    saved_core = cur-mg
    saved_disp = (cnt-1)*0.0088
    tot=saved_core+saved_disp
    tot_cur+=cur; tot_mg+=mg; tot_disp+=saved_disp
    npass_cur+=cnt; npass_mg+=1
    r8a = "✓" if sm>=8160 else "✗(小M)"
    L.append(f"| {N}x{K} | {cnt} | {sm} | {cur:.3f} | {mg:.3f} (@{nM}) | {saved_core:+.3f} | {saved_disp:.3f} | {tot:+.3f} | {r8a} |")
    if tot>0.02: big.append(((N,K),cnt,sm,tot))

L.append(f"\n**可合并组小计**：{npass_cur} 趟 → {npass_mg} 趟；现状 {tot_cur:.2f}ms → 合并 {tot_mg:.2f}ms + disp 省 {tot_disp:.2f}ms = **净省 {tot_cur-tot_mg+tot_disp:.2f}ms**（上界，全共享 weight 假设）。\n")
L.append("## 读表规则（诚实）\n")
L.append("1. **上界不是结论**：只有组内真共享 weight 才成立。`_ffn_groups` 的 8 个 (N,K) 组是")
L.append("   不同 block 实例（weight 不同）→ **不可沿 M 合并**（Mochi 的合并=一个窗口块一个")
L.append("   megakernel，是沿 token 批不是跨 block 拼 weight）。真正候选=同 `record_qkv_projection`")
L.append("   内不同 heads 的碎 M？需 nr_resident 探针确认 weight 身份。")
L.append("2. **R8a 是硬门**：ΣM<8160 的组即使可合并也不该成为独立 int8 趟（§10 地板）——它们是")
L.append("   megakernel 的 stage，红利在消 launch 不在拼 M。")
L.append("3. 结论方向：跨 block 的 (N,K) 组基本不可拼（weight 不同）；可拼的只有**单 block 内**")
L.append("   的窗口碎片（同 weight、同 N=3×channels、M=各窗口 token 数）。下一步=读 nr_resident")
L.append("   确认哪些 site 循环内 weight 恒定、其 M 碎片能否沿窗口合并。")

open(OUT,"w",encoding="utf-8").write("\n".join(L))
print("\n".join(L))
print(f"\nWROTE {OUT}")
