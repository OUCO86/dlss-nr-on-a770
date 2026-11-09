import re, csv, sys, glob
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

out = []
for log in sorted(glob.glob(r"E:\DSH\s6\C24_walk_b8_p*.log")):
    proc = re.search(r"p(\d+)\.log", log).group(1)
    cur = None
    for line in open(log, encoding="utf-8", errors="replace"):
        line = line.strip()
        if line.startswith("C24V3 ARM "):
            cur = dict(proc=proc, log=log.split("\\")[-1])
            for kv in line[len("C24V3 ARM "):].split():
                k, _, v = kv.partition("=")
                cur[k] = v
        elif line.startswith("C24V3 ORDER ") and cur is not None:
            for kv in line[len("C24V3 ORDER "):].split():
                k, _, v = kv.partition("=")
                cur[k] = v
        elif line.startswith("C24V3 GAP ") and cur is not None:
            m = re.match(r"C24V3 GAP nonzero=(\d+)/(\d+) med_iter=(\d+) p90_iter=(\d+) max_iter=(\d+) quant_iter=(\d+) +med_us=([\d.]+) p90_us=([\d.]+) max_us=([\d.]+)", line)
            if m:
                cur.update(nonzero=m.group(1), total_diffs=m.group(2), med_iter=m.group(3),
                           p90_iter=m.group(4), max_iter=m.group(5), med_us=m.group(7),
                           p90_us=m.group(8), max_us=m.group(9))
        elif line.startswith("C24V3 ROWSHARE ") and cur is not None:
            m = re.match(r"C24V3 ROWSHARE windows=(\d+) distinct_rows min=(\d+) max=(\d+) mean=([\d.]+) \(contig ideal=(\d+), strided worst=(\d+)\)", line)
            if m:
                cur.update(win=m.group(1), rows_min=m.group(2), rows_max=m.group(3),
                           rows_mean=m.group(4), rows_ideal=m.group(5), rows_worst=m.group(6))
            out.append(cur); cur = None
        elif line.startswith("C24V3 SELF ") and cur is None:
            pass
    # arms without ROWSHARE are flushed when the next ARM line starts
fields = ["proc","log","name","G","LW","nb","W","dur_us","clk_iter","ns_per_iter","asc","desc",
          "mean_abs_dev","max_abs_dev","nonzero","total_diffs","med_iter","p90_iter","max_iter",
          "med_us","p90_us","max_us","win","rows_min","rows_max","rows_mean","rows_ideal","rows_worst"]

# re-parse keeping arms without ROWSHARE
out = []
for log in sorted(glob.glob(r"E:\DSH\s6\C24_walk_b8_p*.log")):
    proc = re.search(r"p(\d+)\.log", log).group(1)
    cur = None
    for line in open(log, encoding="utf-8", errors="replace"):
        line = line.strip()
        if line.startswith("C24V3 ARM "):
            if cur: out.append(cur)
            cur = dict(proc=proc, log=log.split("\\")[-1])
            for kv in line[len("C24V3 ARM "):].split():
                k, _, v = kv.partition("="); cur[k] = v
        elif cur is None:
            continue
        elif line.startswith("C24V3 ORDER "):
            for kv in line[len("C24V3 ORDER "):].split():
                k, _, v = kv.partition("="); cur[k] = v
        elif line.startswith("C24V3 GAP "):
            m = re.match(r"C24V3 GAP nonzero=(\d+)/(\d+) med_iter=(\d+) p90_iter=(\d+) max_iter=(\d+) quant_iter=(\d+) +med_us=([\d.]+) p90_us=([\d.]+) max_us=([\d.]+)", line)
            if m:
                cur.update(nonzero=m.group(1), total_diffs=m.group(2), med_iter=m.group(3),
                           p90_iter=m.group(4), max_iter=m.group(5), med_us=m.group(7),
                           p90_us=m.group(8), max_us=m.group(9))
        elif line.startswith("C24V3 ROWSHARE "):
            m = re.match(r"C24V3 ROWSHARE windows=(\d+) distinct_rows min=(\d+) max=(\d+) mean=([\d.]+) \(contig ideal=(\d+), strided worst=(\d+)\)", line)
            if m:
                cur.update(win=m.group(1), rows_min=m.group(2), rows_max=m.group(3),
                           rows_mean=m.group(4), rows_ideal=m.group(5), rows_worst=m.group(6))
    if cur: out.append(cur)

with open(r"E:\DSH\tools\C24_walkorder_probe.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=fields)
    w.writeheader()
    for r in out:
        w.writerow({k: r.get(k, "") for k in fields})
print("rows=%d -> E:/DSH/tools/C24_walkorder_probe.csv" % len(out))
for r in out:
    print("%s %-22s G=%-5s LW=%-3s nb=%-3s W=%-4s dur_us=%-8s clk=%-8s ns/it=%-7s dev_mean=%-8s dev_max=%-6s rows=%s/%s (ideal %s)" %
          (r["proc"], r["name"], r["G"], r["LW"], r.get("nb",""), r.get("W",""), r["dur_us"], r.get("clk_iter",""),
           r.get("ns_per_iter",""), r.get("mean_abs_dev",""), r.get("max_abs_dev",""),
           r.get("rows_mean","-"), r.get("rows_worst","-"), r.get("rows_ideal","-")))
