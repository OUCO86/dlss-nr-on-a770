#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""wb_slm_mkcsv.py -- 把 WB 驻留刀的四行交回落成 E:/DSH/s6/wbslm.csv
列：variant,slm_before,slm_after,grf,simd,private,scratch,scrInstr,exact,pairs,mean,wins,ci,note
输入：
  E:/DSH/s6/wbslm_ledger_before.txt   基线台账（fresh JIT cache，出货 dll E2D5E574）
  E:/DSH/s6/wbslm_ledger_all.txt      变体台账
  E:/DSH/logs/ab_<stamp>.txt          16 对 delta（每行一个数，B-A，ms）
  E:/DSH/logs/walk_<tag>.txt          walk 的 1301 判定 + passes
"""
import csv, math, os, re, statistics, sys

def ledger_rows(path):
    rows = {}
    if not os.path.exists(path): return rows
    for L in open(path, encoding="utf-8", errors="replace"):
        m = re.match(r"^(wbv4[ph]*::launch_v4\w+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)", L.strip())
        if not m: continue
        lab, jit, form, grf, simd, slm, spill, priv, scrb, scrins = m.groups()
        rows[(lab, form)] = dict(grf=int(grf), simd=int(simd), slm=int(slm),
                                 spill=spill, priv=priv, scrB=scrb, scrInstr=int(scrins))
    return rows

def deltas(path):
    v = []
    for L in open(path, encoding="utf-8-sig", errors="replace"):
        L = L.strip()
        try: v.append(float(L))
        except ValueError: pass
    return v

def walk_verdict(tag):
    """walk.ps1 的 log 只有原始 replay 输出；判定 = 直接比 1301 dump 的 md5 与 passes。"""
    import hashlib
    dump = rf"E:\DSH\dumps\{tag}.1301.bin"; gold = r"E:\DSH\dumps\bk.1301.bin"
    if not os.path.exists(dump): return "no-dump", "?"
    h = lambda p: hashlib.md5(open(p,'rb').read()).hexdigest().upper()
    exact = "1301 EXACT" if h(dump) == h(gold) else "1301 MISMATCH"
    log = rf"E:\DSH\logs\walk_{tag}.txt"
    pm = re.findall(r"\((\d+) passes\)", open(log, encoding="utf-8-sig", errors="replace").read()) if os.path.exists(log) else []
    return exact, (pm[-1] if pm else "?")


def ci95(v):
    n = len(v)
    if n < 2: return "n/a"
    m = statistics.mean(v); sd = statistics.stdev(v)
    t = {2:12.71,3:4.303,4:3.182,5:2.776,6:2.447,7:2.365,8:2.306,9:2.262,10:2.228,
         11:2.201,12:2.179,13:2.160,14:2.145,15:2.131,16:2.120}.get(n, 1.96)
    h = t*sd/math.sqrt(n)
    return f"[{m-h:+.3f},{m+h:+.3f}]"

def main():
    logs = sys.argv[1:]
    if not logs:
        cands = sorted([f for f in os.listdir(r"E:\DSH\logs") if re.match(r"ab_\d{8}-\d{6}\.txt$", f)])
        logs = [os.path.join(r"E:\DSH\logs", c) for c in cands[-1:]]
    d = []
    for lg in logs: d += deltas(lg)
    before = ledger_rows(r"E:\DSH\s6\wbslm_ledger_before.txt")
    after  = ledger_rows(r"E:\DSH\s6\wbslm_ledger_all.txt")
    exact, passes = walk_verdict("wbslm_b2")
    per = [round(statistics.mean(deltas(lg)), 3) for lg in logs]
    mean = round(statistics.mean(d), 3); wins = sum(1 for x in d if x < 0)
    z = lambda v: "0" if v in ("-", None, "") else str(v)
    rows = []
    for lab in ("wbv4::launch_v4full", "wbv4ph::launch_v4ph"):
        b = before.get((lab, "closure"), {}); a = after.get((lab, "closure"), {})
        rows.append(dict(
            variant="wb_slm_b", slm_before=b.get("slm", ""), slm_after=a.get("slm", ""),
            grf=a.get("grf", ""), simd=a.get("simd", ""), private=z(a.get("priv")),
            scratch=z(a.get("scrB")), scrInstr=a.get("scrInstr", ""),
            exact=exact, pairs=len(d), mean=f"{mean:+.3f}", wins=wins, ci=ci95(d),
            note=f"{lab} passes={passes} slm {b.get('slm')}->{a.get('slm')} "
                 f"驻留 {65536//b.get('slm',1)}->{65536//a.get('slm',1)} (Level-Zero 帽 65,536) "
                 f"每轮均值={per}"))
    out = r"E:\DSH\s6\wbslm.csv"
    new = not os.path.exists(out)
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print("ab logs:", logs, "pairs:", len(d), "mean:", mean, "wins:", wins, "ci:", ci95(d), "per-run:", per)
    print("wrote", out)
    for r in rows: print(" ", r["variant"], r["slm_before"], "->", r["slm_after"], "|", r["note"])

if __name__ == "__main__":
    main()
