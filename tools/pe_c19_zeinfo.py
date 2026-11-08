import sys, re
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
path = sys.argv[1]
pat = re.compile(sys.argv[2]) if len(sys.argv) > 2 else re.compile(r"ffn", re.I)
t = open(path, encoding="utf-8", errors="replace").read()
blocks = re.split(r"\n  - name:", t)
print("blocks:", len(blocks))
for b in blocks[1:]:
    name = b.split("\n", 1)[0].strip()
    if not pat.search(name):
        continue
    g = re.search(r"grf_count:\s*(\d+)", b)
    s = re.search(r"simd_size:\s*(\d+)", b)
    slm = re.search(r"slm_size:\s*(\d+)", b)
    scr = re.search(r"scratch_mem_size:\s*(\d+)", b)
    st = re.search(r"static_data_memsize:\s*(\d+)", b)
    nsw = "no_stateless_write" in b
    print("name: %s" % name)
    print("   grf=%s simd=%s slm=%s scratch=%s static=%s nsw=%s" % (
        g.group(1) if g else "?", s.group(1) if s else "?",
        slm.group(1) if slm else "0", scr.group(1) if scr else "0",
        st.group(1) if st else "0", int(nsw)))
    es = re.search(r"esimd_simd_size.*", b)
    if es: print("   ", es.group(0))
