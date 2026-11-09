import csv, sys, collections
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

pm = list(csv.DictReader(open(r"E:\DSH\tools\path_membership.csv", encoding="utf-8")))
sh = list(csv.DictReader(open(r"E:\DSH\tools\shapes_census.csv", encoding="utf-8")))
shby = {}
for r in sh:
    shby[int(r["closure"])] = r

rows = []
for r in pm:
    c = int(r["closure"])
    fp = float(r["frame_price_ms_if_deleted"])
    s = shby.get(c, {})
    rows.append(dict(closure=c, fam=r["family"], leg=float(r["leg_ms"]), fp=fp,
                     shape=s.get("shape","?"), M=s.get("M",""), N=s.get("N",""), K=s.get("K",""),
                     batch=s.get("batch",""), dtype=s.get("dtype",""), epi=s.get("epi",""),
                     gflop=s.get("gflop",""), bytes=s.get("bytes","")))

rows.sort(key=lambda x: -x["fp"])
print("=== TOP 20 CLOSURES BY frame_price_ms_if_deleted (joined with shapes_census) ===")
for r in rows[:20]:
    print("clos=%-4d %-30s leg=%7.4f fp=%7.4f dtype=%-5s M=%-7s N=%-6s K=%-6s b=%-3s shape=%s" %
          (r["closure"], r["fam"], r["leg"], r["fp"], r["dtype"], r["M"], r["N"], r["K"], r["batch"], r["shape"]))

print()
print("=== DISTINCT SHAPES PER FAMILY (count, leg sum, fp sum) ===")
agg = collections.defaultdict(lambda: dict(n=0, leg=0.0, fp=0.0, shapes=collections.Counter()))
for r in rows:
    a = agg[r["fam"]]
    a["n"] += 1; a["leg"] += r["leg"]; a["fp"] += r["fp"]
    a["shapes"][(r["M"], r["N"], r["K"], r["batch"], r["dtype"])] += 1
for fam, a in sorted(agg.items(), key=lambda kv: -kv[1]["fp"]):
    print("%-32s n=%-4d leg=%8.3f fp=%8.4f" % (fam, a["n"], a["leg"], a["fp"]))
    for shp, cnt in a["shapes"].most_common(8):
        print("      M=%-8s N=%-6s K=%-6s b=%-4s dt=%-5s x%d" % (shp[0], shp[1], shp[2], shp[3], shp[4], cnt))
