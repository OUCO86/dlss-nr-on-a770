import sys, re, collections
sys.stdout.reconfigure(encoding='utf-8')
# tools/wb_c26_scratch.py -- the scratch-level (POOL-BLOCK) dependency census across the
# twin span boundary, from the engine's own record-time touch dump ([pgt] lines, presence
# gated NR_PG_TOUCHDUMP). The plan-face census said the span is closed over PLAN ids; this
# one asks the same question over POINTERS, which is where the pool scratch lives: a
# surviving closure whose touch set shares a pointer with a dissolved closure's touch set
# is reading (or writing) a block that the twin graph leaves unwritten.
# Uses the LAST 693 [pgt] lines = the kept recording (the plan records twice).
p = sys.argv[1]
span_lo, span_hi = int(sys.argv[2]), int(sys.argv[3])
lines = [l.rstrip('\n') for l in open(p, encoding='utf-8', errors='replace') if l.startswith('[pgt] cmd=')]
# keep the last contiguous run of lines whose cmd restarts at 0
idxs = [int(re.search(r'cmd=(\d+)', l).group(1)) for l in lines]
starts = [i for i, v in enumerate(idxs) if v == 0]
keep = lines[starts[-1]:]
rows = []
for l in keep:
    m = re.match(r'\[pgt\] cmd=(\d+) name=(\S+) touch=(.*)$', l)
    if not m: continue
    cmd = int(m.group(1)); nm = m.group(2)
    tok = m.group(3).split(' | ids=')
    # %p prints bare hex (no 0x) or "(nil)" -- take every hex-looking token as a pointer
    ptrs = [x for x in tok[0].split() if re.fullmatch(r'(?i)[0-9a-f]{6,}', x)]
    ids = [int(x) for x in (tok[1].split() if len(tok) > 1 else []) if re.fullmatch(r'-?\d+', x)]
    rows.append((cmd, nm, ptrs, ids))
print('kept recording closures=%d (span %d..%d)' % (len(rows), span_lo, span_hi))
inspan = collections.defaultdict(list)
outspan = collections.defaultdict(list)
for cmd, nm, ptrs, ids in rows:
    for pt in ptrs:
        (inspan if span_lo <= cmd <= span_hi else outspan)[pt].append((cmd, nm))
common = set(inspan) & set(outspan)
print('pointers touched inside the span: %d ; outside: %d ; SHARED: %d'
      % (len(inspan), len(outspan), len(common)))
cnt = collections.Counter()
for pt in common:
    ins = inspan[pt]; outs = outspan[pt]
    key = (tuple(sorted(set(n for _, n in ins))), tuple(sorted(set(n for _, n in outs))))
    cnt[key] += 1
print('SHARED-pointer family pairs:')
for k, v in cnt.most_common(20):
    print('   x%-4d  inside=%s  outside=%s' % (v, ','.join(k[0]), ','.join(k[1])))
# also: how many of the shared pointers are PLAN faces (ids) vs pool scratch? the [pgt]
# line lists ids separately; a pointer that is NOT in any id list of the closure is scratch.
print('examples (first 10 shared pointers):')
# Map a shared pointer back to a PLAN id when possible: pgraph_ids() pushes the ids and
# the resolved pointers in the SAME order (g_pg_pending / g_pg_pending_ids are mirrors), so
# for a closure whose k-th touch pointer is its k-th id, pointer==face means k < len(ids).
ptr2id = {}
for cmd, nm, ptrs, ids in rows:
    for k, pt in enumerate(ptrs):
        if k < len(ids):
            ptr2id.setdefault(pt, set()).add(ids[k])
for pt in list(common)[:12]:
    who_in = ','.join('%d:%s' % (c, n) for c, n in inspan[pt][:4])
    who_out = ','.join('%d:%s' % (c, n) for c, n in outspan[pt][:4])
    print('   ptr=%s plan_ids=%s\n        inside =[%s]\n        outside=[%s]' % (
        pt, sorted(ptr2id.get(pt, [])), who_in, who_out))
print('shared pointers with NO plan-id mapping (=> pool scratch): %d of %d' % (
    len([pt for pt in common if pt not in ptr2id]), len(common)))
print('=== done wb_c26_scratch ===')
