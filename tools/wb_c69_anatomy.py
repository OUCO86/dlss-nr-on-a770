import csv, sys, collections
sys.stdout.reconfigure(encoding='utf-8')
T = r'E:\DSH\dlss-nr-on-a770\tools'

# C512 tier chains from chain_map
chains = [r for r in csv.DictReader(open(T + r'\chain_map.csv', encoding='utf-8', errors='replace'))
          if (r.get('C') or '').strip() == '512']
cids = []
for r in chains:
    a, b = int(r['closure_first']), int(r['closure_last'])
    cids.append((r['chain'], r['M_att'], r['op_seq'], list(range(a, b + 1))))
allc = [c for _, _, _, L in cids for c in L]
print('C512 chains=%d  closures=%d' % (len(cids), len(allc)))

# per-closure leg ms + family + shapes
leg = {}
for r in csv.DictReader(open(T + r'\rt_per_closure.csv', encoding='utf-8', errors='replace')):
    try:
        leg[int(r['closure'])] = ((r['family'] or '').replace('xmx_rec_', ''), float(r['ms']),
                                  r['M'], r['N'], r['K'], r['batch'], r['rt_label'])
    except ValueError:
        pass

tot = 0.0
zero = 0
per_chain = []
fam_ms = collections.Counter()
fam_n = collections.Counter()
for ch, M_att, op_seq, L in cids:
    s = 0.0
    for c in L:
        if c in leg:
            f, ms = leg[c][0], leg[c][1]
            s += ms
            fam_ms[f] += ms
            fam_n[f] += 1
            if ms < 0.005:
                zero += 1
    per_chain.append((ch, M_att, len(L), s))
    tot += s
print('\nchain  M_att  closures  leg_ms')
for ch, m, n, s in per_chain:
    print('  %-4s %-7s %-6d %8.3f' % (ch, m, n, s))
print('\nC512 tier leg total (fused ledger) = %.3f ms   closures with leg < 0.005 ms (no-op/skip) = %d / %d' % (tot, zero, len(allc)))
print('\nper-family in this tier:')
for f, ms in fam_ms.most_common():
    print('   %-32s n=%-4d %8.3f ms' % (f, fam_n[f], ms))

# what the tier costs if the 14 skipped chains (18-24,26-32) are no-ops
skip_ids = {'18', '19', '20', '21', '22', '23', '24', '26', '27', '28', '29', '30', '31', '32'}
kept = [(ch, m, n, s) for ch, m, n, s in per_chain if ch not in skip_ids]
skipped = [(ch, m, n, s) for ch, m, n, s in per_chain if ch in skip_ids]
print('\n=== re-price under the shipped skip promotion (T_SKIP_CHAINS_DEF = 18..24,26..32) ===')
print('  chains skipped = %d  their legs = %.3f ms' % (len(skipped), sum(x[3] for x in skipped)))
print('  chains kept    = %d  their legs = %.3f ms' % (len(kept), sum(x[3] for x in kept)))
kept_ms = sum(x[3] for x in kept)
print('\n  lmxx same block @544p = 1.60 ms  (4.602+2.157+0.145+0.079 = 6.983 @1080p / 4.23 px factor ~1.60)')
print('  ratio (shipped, skip ON)  = %.2fx   excess = %+.2f ms' % (kept_ms / 1.60, kept_ms - 1.60))
print('  ratio (skip OFF, full 16) = %.2fx   excess = %+.2f ms' % (tot / 1.60, tot - 1.60))
