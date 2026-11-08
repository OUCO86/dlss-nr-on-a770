#!/usr/bin/env python3
# E:\DSH\tools\stall_census4.py -- corrected GEN scoreboard census, v2.
#
# Two dependency kinds are reported SEPARATELY (never merged):
#   first-wait : send -> the FIRST line that waits on that scoreboard, of ANY
#                kind ($k.dst, $k.src, bare $k on a dpas, or $k in sync.*()).
#                This is where the thread actually blocks.
#   data-wait  : send -> first $k.dst / dpas-$k / sync-allwr, i.e. where the
#                loaded DATA is consumed.
# A `$k.src` wait is a WAR hazard on the send's own ADDRESS/payload register
# (the instruction overwrites it). It still blocks on the scoreboard, so it is
# a REAL stall -- but it is a register-pressure stall, curable by giving the
# address its own register, NOT by prefetching. Conflating the two (as
# tools/stall_census.py did) produced p50=3 / MLP=5.34 on launch_v4full.
import io, re, sys, glob, os, collections
sys.stdout.reconfigure(encoding='utf-8')

SEND = re.compile(r'^\s*(?:\([^\)]*\)\s*)?(send[a-zA-Z0-9_.]*|dpas[a-zA-Z0-9_.]*)\b(.*)$')
TOK  = re.compile(r'\$(\d+)(?:\.(dst|src))?')
CMT  = re.compile(r'//\s*(.*)$')
SYNC = re.compile(r'^\s*sync\.\w+\s*(?:\(([^)]*)\))?')

def verb_of(cmt):
    c = cmt.strip()
    if 'block read' in c or 'block write' in c:
        return 'load.dc0' if 'read' in c else 'store.dc0'
    m = re.search(r';\s*([a-z0-9_.]+)', c)
    v = m.group(1) if m else ''
    if 'signal barrier' in c: v = 'signal.barrier'
    return v

def analyze(path):
    lines = io.open(path, encoding='utf-8', errors='replace').read().splitlines()
    open_load = {}                 # sb -> (line, comment-verb)
    open_store = {}
    first_d, data_d, src_only = [], [], 0
    inflight_first, inflight_data = [], []
    verbs = collections.Counter()
    unresolved = 0
    for i, ln in enumerate(lines):
        code = ln.split('//')[0]
        cm = CMT.search(ln)
        cmt = cm.group(1) if cm else ''
        m = SEND.match(ln)
        if m:
            mnem = m.group(1)
            if mnem.startswith('dpas'):
                verbs['dpas.8x8'] += 1
                for t in TOK.finditer(code):
                    sb = t.group(1)
                    if sb in open_load:
                        st = open_load.pop(sb)[0]
                        first_d.append(i - st); inflight_first.append(len(open_load) + 1)
                        data_d.append(i - st);  inflight_data.append(len(open_load) + 1)
                continue
            vs = verb_of(cmt)
            verbs[vs or mnem] += 1
            is_load  = vs.startswith('load')
            is_store = vs.startswith('store')
            for t in TOK.finditer(code):
                sb, side = t.group(1), t.group(2)
                if side:                                   # wait on this send line
                    if sb in open_load:
                        st = open_load[sb][0]
                        first_d.append(i - st); inflight_first.append(len(open_load) + 1)
                        if side == 'dst':
                            open_load.pop(sb)
                            data_d.append(i - st); inflight_data.append(len(open_load) + 1)
                        else:
                            src_only += 1
                    elif sb in open_store:
                        if side == 'src': open_store.pop(sb, None)
                else:                                      # bare $k on a send = open it
                    if is_load:      open_load[sb] = (i, vs)
                    elif is_store:   open_store[sb] = i
            continue
        sm = SYNC.match(ln)
        if sm:
            for t in TOK.finditer(sm.group(1) or ''):
                sb = t.group(1)
                if sb in open_load:
                    st = open_load.pop(sb)[0]
                    first_d.append(i - st); inflight_first.append(len(open_load) + 1)
                    data_d.append(i - st);  inflight_data.append(len(open_load) + 1)
                elif sb in open_store:
                    open_store.pop(sb, None)
            continue
        for t in TOK.finditer(code):
            sb, side = t.group(1), t.group(2)
            if sb not in open_load: continue
            st = open_load[sb][0]
            if side == 'src':
                first_d.append(i - st); inflight_first.append(len(open_load) + 1)
                src_only += 1
            else:                                          # dst, or bare on non-send
                open_load.pop(sb)
                first_d.append(i - st); inflight_first.append(len(open_load) + 1)
                data_d.append(i - st);  inflight_data.append(len(open_load) + 1)
    unresolved += len(open_load)
    def q(a, p):
        if not a: return None
        s = sorted(a); return s[min(len(s) - 1, int(len(s) * p))]
    def sh(a, k=5):
        return (sum(1 for x in a if x <= k) / len(a)) if a else None
    n_loads = sum(v for k, v in verbs.items() if k.startswith('load'))
    return dict(name=os.path.basename(path), lines=len(lines), verbs=verbs,
                n_loads=n_loads, n_stores=sum(v for k, v in verbs.items() if k.startswith('store')),
                n_dpas=verbs['dpas.8x8'],
                first=first_d, data=data_d, src_only=src_only, unresolved=unresolved,
                f_p50=q(first_d, .5), f_p90=q(first_d, .9), f_min=(min(first_d) if first_d else None),
                f_le5=sh(first_d), f_mlp=(sum(inflight_first)/len(inflight_first)) if inflight_first else None,
                d_p50=q(data_d, .5), d_p90=q(data_d, .9), d_min=(min(data_d) if data_d else None),
                d_le5=sh(data_d), d_mlp=(sum(inflight_data)/len(inflight_data)) if inflight_data else None)

def main():
    if len(sys.argv) > 2 and sys.argv[2] == '-1':
        r = analyze(sys.argv[1])
        print(r['name'])
        print('  loads=%d stores=%d dpas=%d | first-waits=%d data-waits=%d src-only=%d unresolved=%d'
              % (r['n_loads'], r['n_stores'], r['n_dpas'], len(r['first']), len(r['data']),
                 r['src_only'], r['unresolved']))
        print('  FIRST-WAIT  min=%s p50=%s p90=%s le5=%s MLP=%s' %
              (r['f_min'], r['f_p50'], r['f_p90'], r['f_le5'], r['f_mlp']))
        print('  DATA-WAIT   min=%s p50=%s p90=%s le5=%s MLP=%s' %
              (r['d_min'], r['d_p50'], r['d_p90'], r['d_le5'], r['d_mlp']))
        for k, v in r['verbs'].most_common(16):
            print('     %-32s %4d' % (k, v))
        return 0
    return 0

if __name__ == '__main__':
    sys.exit(main())
