#!/usr/bin/env python3
# E:\DSH\tools\stall_census5.py -- BASIC-BLOCK-AWARE scoreboard census.
# Why: on the qkv instances the linear "lines between send and wait" metric is NOT
# an execution-path metric -- .text._ZTSZZ21xmx_rec_gemm_int8_qkv... has 3,496 labels,
# 1,937 gotos and 1,245 joins in 14,674 lines, i.e. a fully unrolled dispatch state
# machine. A send in one branch arm and a `$k.dst` in another arm are never on the
# same dynamic path, so their "distance" is meaningless.
# Rule: a block starts at a label, ends at goto/br/join/end-of-thread (label lines
# themselves open a new block). Only waits inside the SAME block as the send count.
import io, re, sys, glob, os, collections
sys.stdout.reconfigure(encoding='utf-8')

SEND = re.compile(r'^\s*(?:\([^\)]*\)\s*)?(send[a-zA-Z0-9_.]*|dpas[a-zA-Z0-9_.]*)\b(.*)$')
TOK  = re.compile(r'\$(\d+)(?:\.(dst|src))?')
CMT  = re.compile(r'//\s*(.*)$')
LBL  = re.compile(r'^\s*[.]?L\w+\s*:')
TERM = re.compile(r'^\s*(?:\([^\)]*\)\s*)?(goto|br\b|break|cont|join|while|if)\b')
EOT  = re.compile(r'end of thread')
SYNC = re.compile(r'^\s*sync\.\w+\s*(?:\(([^)]*)\))?')

def verb_of(c):
    c = c.strip()
    if 'block read' in c or 'block write' in c: return 'load.dc0' if 'read' in c else 'store.dc0'
    m = re.search(r';\s*([a-z0-9_.]+)', c)
    v = m.group(1) if m else ''
    if 'signal barrier' in c: v = 'signal.barrier'
    return v

def analyze(path):
    lines = io.open(path, encoding='utf-8', errors='replace').read().splitlines()
    blk = 0; nblk = 1
    open_load = {}; open_store = {}
    f_d, d_d, infl_f, infl_d = [], [], [], []
    cross = 0; src_only = 0
    verbs = collections.Counter(); big = collections.Counter()
    for i, ln in enumerate(lines):
        code = ln.split('//')[0]
        cm = CMT.search(ln); cmt = cm.group(1) if cm else ''
        if LBL.match(ln):
            blk += 1; nblk += 1
        m = SEND.match(ln)
        if m:
            mnem = m.group(1)
            if mnem.startswith('dpas'):
                verbs['dpas.8x8'] += 1
                for t in TOK.finditer(code):
                    sb = t.group(1)
                    if sb in open_load:
                        st, ob = open_load.pop(sb)
                        if ob != blk: cross += 1; continue
                        f_d.append(i - st); infl_f.append(len(open_load) + 1)
                        d_d.append(i - st); infl_d.append(len(open_load) + 1)
                continue
            vs = verb_of(cmt); verbs[vs or mnem] += 1
            for t in TOK.finditer(code):
                sb, side = t.group(1), t.group(2)
                if side:
                    if sb in open_load:
                        st, ob = open_load[sb]
                        if ob != blk: cross += 1; continue
                        if side == 'dst':
                            open_load.pop(sb)
                            f_d.append(i - st); infl_f.append(len(open_load) + 1)
                            d_d.append(i - st); infl_d.append(len(open_load) + 1)
                        else:
                            src_only += 1; f_d.append(i - st); infl_f.append(len(open_load) + 1)
                    elif sb in open_store and side == 'src':
                        open_store.pop(sb, None)
                else:
                    if vs.startswith('load'):   open_load[sb] = (i, blk)
                    elif vs.startswith('store'):open_store[sb] = i
            continue
        sm = SYNC.match(ln)
        if sm and sm.group(1):
            for t in TOK.finditer(sm.group(1)):
                sb = t.group(1)
                if sb in open_load:
                    st, ob = open_load.pop(sb)
                    if ob != blk: cross += 1; continue
                    f_d.append(i - st); infl_f.append(len(open_load) + 1)
                    d_d.append(i - st); infl_d.append(len(open_load) + 1)
            continue
        if EOT.search(ln):
            open_load.clear(); open_store.clear(); continue
        for t in TOK.finditer(code):
            sb, side = t.group(1), t.group(2)
            if sb not in open_load: continue
            st, ob = open_load[sb]
            if ob != blk:
                cross += 1; open_load.pop(sb); continue
            if side == 'src':
                src_only += 1; f_d.append(i - st); infl_f.append(len(open_load) + 1)
            else:
                open_load.pop(sb)
                f_d.append(i - st); infl_f.append(len(open_load) + 1)
                d_d.append(i - st); infl_d.append(len(open_load) + 1)
    def q(a, p):
        if not a: return None
        s = sorted(a); return s[min(len(s) - 1, int(len(s) * p))]
    return dict(name=os.path.basename(path), lines=len(lines), nblk=nblk,
                n_loads=sum(v for k, v in verbs.items() if k.startswith('load')),
                n_dpas=verbs['dpas.8x8'], cross=cross, src_only=src_only,
                f=f_d, d=d_d, unresolved=len(open_load),
                f_p50=q(f_d, .5), f_p90=q(f_d, .9), f_min=(min(f_d) if f_d else None),
                f_le5=(sum(1 for x in f_d if x <= 5) / len(f_d)) if f_d else None,
                f_mlp=(sum(infl_f) / len(infl_f)) if infl_f else None,
                d_p50=q(d_d, .5), d_le5=(sum(1 for x in d_d if x <= 5) / len(d_d)) if d_d else None,
                d_mlp=(sum(infl_d) / len(infl_d)) if infl_d else None)

def lbl(nm):
    n = re.sub(r'^\.text\.', '', nm); n = re.sub(r'\.asm$', '', n)
    m = re.search(r'(launch_v4full|launch_v4ph|launch_v3|launch_v2|launch_full|launch_mega256|launch_leg1)', n)
    if m: return m.group(1)
    m = re.search(r'2\d(xmx_rec_\w+?)E', n)
    if m:
        lam = re.search(r'EUlS4_E(\d+)_EE$', n) or re.search(r'itemILi1ELb1EEEE(\d+)_', n)
        return m.group(1).replace('xmx_rec_', '') + '#' + (lam.group(1) if lam else 'x')
    m = re.search(r'N(\d{2})(\w{3,26})E', n)
    if m:
        inner = re.search(r'(\d{2})(\w{4,22})ER', n) or re.search(r'(\w{4,22})ERN', n)
        return m.group(2) + (('::' + inner.group(1)) if inner else '')
    return n[:30]

def main():
    if len(sys.argv) > 2 and sys.argv[2] == '-1':
        r = analyze(sys.argv[1])
        print('%s\n  lines=%d blocks=%d  loads=%d dpas=%d | same-BB waits=%d CROSS-BB(dropped)=%d unresolved=%d'
              % (r['name'], r['lines'], r['nblk'], r['n_loads'], r['n_dpas'], len(r['f']), r['cross'], r['unresolved']))
        print('  BB-AWARE FIRST min=%s p50=%s p90=%s le5=%s MLP=%s' % (r['f_min'], r['f_p50'], r['f_p90'], r['f_le5'], r['f_mlp']))
        print('  BB-AWARE DATA  p50=%s le5=%s MLP=%s' % (r['d_p50'], r['d_le5'], r['d_mlp']))
        return 0
    root = sys.argv[1] if len(sys.argv) > 1 else r'E:\DSH\tmp\k3ze\d_ctlf'
    rows = []
    for f in sorted(glob.glob(os.path.join(root, '.text*.asm'))):
        r = analyze(f)
        if not r['f'] or r['n_loads'] == 0: continue
        r['inst'] = lbl(r['name']); r['score'] = r['n_loads'] * (r['f_le5'] or 0)
        rows.append(r)
    rows.sort(key=lambda x: -x['score'])
    print('BB-AWARE frame: instances=%d' % len(rows))
    print('%-28s %7s %6s %6s %5s %5s %5s %6s %6s %7s %6s' %
          ('instance', 'lines', 'blocks', 'loads', 'p50', 'p90', 'min', 'le5%', 'MLP', 'crossBB', 'dpas'))
    for r in rows[:18]:
        print('%-28s %7d %6d %6d %5s %5s %5s %6.1f %6.2f %7d %6d' %
              (r['inst'][:28], r['lines'], r['nblk'], r['n_loads'], r['f_p50'], r['f_p90'],
               r['f_min'], 100 * (r['f_le5'] or 0), r['f_mlp'] or 0, r['cross'], r['n_dpas']))
    with io.open(os.path.join(r'E:\DSH\tools', 'stall_hotspots_bb_aware.csv'), 'w', newline='', encoding='ascii') as fh:
        w = csv_w = None
        import csv as _c
        w = _c.writer(fh)
        w.writerow(['instance', 'lines', 'blocks', 'loads', 'dpas', 'first_p50', 'first_p90',
                    'first_min', 'share_le5', 'MLP_mean', 'data_p50', 'data_share_le5', 'data_MLP',
                    'cross_block_waits_dropped', 'same_block_waits', 'score'])
        for r in rows:
            w.writerow([r['inst'], r['lines'], r['nblk'], r['n_loads'], r['n_dpas'], r['f_p50'],
                        r['f_p90'], r['f_min'], '%.3f' % (r['f_le5'] or 0), '%.2f' % (r['f_mlp'] or 0),
                        r['d_p50'], '%.3f' % (r['d_le5'] or 0), '%.2f' % (r['d_mlp'] or 0),
                        r['cross'], len(r['f']), '%.1f' % r['score']])
    tl = sum(r['n_loads'] for r in rows); ts = sum(r['score'] for r in rows)
    tc = sum(r['cross'] for r in rows)
    print('FRAME: loads=%d same-BB short(<=5)=%.0f (%.1f%%)  cross-BB waits dropped=%d' %
          (tl, ts, 100.0 * ts / tl, tc))
    return 0

if __name__ == '__main__':
    sys.exit(main())
