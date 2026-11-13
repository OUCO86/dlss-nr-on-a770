import sys, re
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
SRC = r'E:\DSH\dlss-nr-on-a770\src\bench\sycl\libxmx_sycl.cpp'
L = open(SRC, encoding='utf-8', errors='replace').read().split('\n')

print('=== C127 (1): where an operand element width comes from, for the recorders that read 1274 ===')
print('    (the plan is read-only, so the question is: does the ENGINE decide the width, or the plan?)')
for j, x in enumerate(L, 1):
    if re.search(r'a_half|b_half|half_skip|kind & 0x|flags & 0x8000|flags & 0x10000|flags & 0x40000', x) and x.strip() and not x.strip().startswith('//'):
        print('%5d: %s' % (j, x.strip()[:136]))
print()
print('=== the plan step for a 1274 consumer: are the flags carried in the step args? ===')
P = open(r'E:\WorkBuddy\2026-10-09-04-20-55\src\dlss-nr-on-a770\work\plan_960x544.c', encoding='utf-8', errors='replace').read().split('\n')
n = 0
for ln, l in enumerate(P, 1):
    m = re.search(r'\{\s*OP_XMX_REC_([A-Z0-9_]+),\s*\d+,\s*\{([^}]*)\}', l)
    if not m:
        continue
    a = [int(x) for x in re.findall(r'-?\d+', m.group(2))]
    if 1274 in a:
        n += 1
        if n <= 8:
            print('  plan %6d %-26s args=%s' % (ln, m.group(1), a[:12]))
print('  total steps touching 1274:', n)
print()
print('=== the OP_BUF step for 1274 (does it carry a kind/width field?) ===')
for ln, l in enumerate(P, 1):
    m = re.search(r'\{\s*OP_BUF,\s*\d+,\s*\{\s*1274\s*,([^\}]*)\}', l)
    if m:
        print('  plan %6d OP_BUF 1274 fields:%s' % (ln, m.group(1)[:120]))
print()
print('=== how the engine creates a plan buffer: does it pass a kind? ===')
for j, x in enumerate(L, 1):
    if re.search(r'case OP_BUF|OP_BUF:|xmx_buf_create', x) and x.strip() and not x.strip().startswith('//'):
        print('%5d: %s' % (j, x.strip()[:140]))
