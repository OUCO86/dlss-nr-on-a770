#!/usr/bin/env python
# k2b_rtcmp.py -- 读 s6/K2b_{A,B}{1,2}_rt.txt（rtcsv 行）+ .log（[bwide]/[bpack] 计数），
# 对 §51(7) 的 40 发疑账与刀 2 的 48 站逐发比 ms。用法： python k2b_rtcmp.py
import re, os, glob, collections, sys

# PS 5.1 decodes a child's stdout with the console codepage (GBK) => self-write a UTF-8 report
# and print an ASCII-folded copy to the console (knife2b.md P11).
_SUMF = open(r"E:\DSH\s6\k2b_rtcmp_out.txt", "w", encoding="utf-8")
_print = print
def print(*a, **k):
    _print(*[x.encode('ascii', 'replace').decode() if isinstance(x, str) else x for x in a], **k)
    _print(*a, file=_SUMF, **k)

SUS = [14,16,25,27,36,38,47,49,61,63,72,74,83,85,94,96,105,107,116,118,
       568,570,579,581,590,592,601,603,612,614,623,625,636,638,647,649,658,660,669,671]
S0 = [217,229,241,253,265,277,289,301,391,403,415,427,439,451,463,475]
S1 = [131,141,151,161,171,181,191,201,487,497,507,517,527,537,547,557]
S2 = [215,227,239,251,263,275,287,299,389,401,413,425,437,449,461,473]

def parse_rt(path):
    """rtcsv <pass> <name> <ms> ; 同一进程内 4 个 run 依次 -> 按出现次序分桶。"""
    runs = collections.defaultdict(dict)
    seen = collections.Counter()
    for ln in open(path, encoding='utf-8', errors='replace'):
        m = re.match(r'^rtcsv (\d+) (\S+) ([\d.]+)\s*$', ln)
        if not m: continue
        p = int(m.group(1)); ms = float(m.group(3))
        run = seen[p]; seen[p] += 1
        runs[run][p] = ms
    return runs

def summarize(tag, runs, ids):
    per = []
    for r in sorted(runs):
        vals = [runs[r].get(i) for i in ids if runs[r].get(i) is not None]
        if vals: per.append((r, sum(vals), min(vals), max(vals), len(vals)))
    print(f"-- {tag}: run 序 (ms 和, min, max, n) = " + "; ".join(f"r{r}:({s:.4f},{a:.4f},{b:.4f},{n})" for r,s,a,b,n in per))
    if not per: print("   !! 没有 rtcsv 行"); return
    tot = sum(s for _,s,_,_,_ in per)/len(per)
    lo  = min(a for _,_,a,_,_ in per); hi = max(b for _,_,_,b,_ in per)
    print(f"   合计均值 = {tot:.4f} ms   单发 min..max = {lo:.4f} .. {hi:.4f}")
    return tot

def read_text(path):
    """PS 5.1 redirection (*>) writes UTF-16LE with a BOM; the C++ tools write ANSI/UTF-8.
    Sniff the BOM so trace counts never come back silently zero (seen 2026-11-03 11:5x)."""
    raw = open(path, 'rb').read()
    if raw[:2] in (b'\xff\xfe', b'\xfe\xff'):
        return raw.decode('utf-16', errors='replace')
    return raw.decode('utf-8', errors='replace')

def counts(log):
    if not os.path.exists(log): return None
    txt = read_text(log)
    return (txt.count('[bwide]'), txt.count('[bpack]'))

for pair in (1,2):
    for side in ('A','B'):
        rt = rf"E:\DSH\s6\K2b_{side}{pair}_rt.txt"
        log = rf"E:\DSH\s6\K2b_{side}{pair}.log"
        if not os.path.exists(rt):
            print(f"[skip] {rt} 不存在"); continue
        print(f"=== side {side}{pair} ===")
        c = counts(log)
        if c: print(f"   [bwide]={c[0]}  [bpack]={c[1]}   (预期 A=0；B: 20/发 x run 数；[bpack] 受 bgp<=8 上限)")
        runs = parse_rt(rt)
        summarize(f"40 发疑账 (n={len(SUS)})", runs, SUS)
        summarize(f"S0 (n=16)", runs, S0)
        summarize(f"S1 (n=16)", runs, S1)
        summarize(f"S2 (n=16)", runs, S2)
        # 那 40 发在 B 侧是否变成 0.10-0.14 量级
        for r in sorted(runs):
            v = [runs[r][i] for i in SUS if i in runs[r]]
            if v and side == 'B':
                print(f"   B r{r}: 40 发 ms 分布 = " + ", ".join(f"{x:.4f}" for x in sorted(v)))
