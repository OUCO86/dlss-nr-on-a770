import re, os, sys, statistics
sys.stdout.reconfigure(encoding='utf-8')
LOG = r'E:\DSH\logs'
def runs(n):
    s = open(os.path.join(LOG, 'C27_%s.log' % n), encoding='utf-8', errors='replace').read()
    v = [float(m.group(1)) for m in re.finditer(r'run \d+: ([0-9.]+) ms', s)]
    return v[2:]     # drop the two cold frames
for n in ['s0f', 'p16f', 'p16f2', 'p16f3', 'p8f', 'p4f', 's0p', 'p16p', 'p16p2', 'p16p3', 'p8p', 'p4p']:
    v = runs(n)
    print('%-6s n=%d mean=%6.2f med=%6.2f max=%6.2f' % (n, len(v), statistics.mean(v), statistics.median(v), max(v)))
base_f = statistics.mean(runs('s0f')); base_p = statistics.mean(runs('s0p'))
p16f = statistics.mean([statistics.mean(runs(x)) for x in ['p16f', 'p16f2', 'p16f3']])
p16p = statistics.mean([statistics.mean(runs(x)) for x in ['p16p', 'p16p2', 'p16p3']])
print('DELTA(mean) fused: p16 %+.2f  p8 %+.2f  p4 %+.2f   (base %.2f)' % (
    p16f - base_f, statistics.mean(runs('p8f')) - base_f, statistics.mean(runs('p4f')) - base_f, base_f))
print('DELTA(mean) plain: p16 %+.2f  p8 %+.2f  p4 %+.2f   (base %.2f)' % (
    p16p - base_p, statistics.mean(runs('p8p')) - base_p, statistics.mean(runs('p4p')) - base_p, base_p))
