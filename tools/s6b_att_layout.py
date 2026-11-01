# s6b_att_layout.py -- S6-1b' PHASE-1 (attention side, 5 fa) SLM byte budget.
# Same sign convention / alias-block style as tools/s6b_layout.py (S6-1b 11-fa), but the
# chain is only P7..P11:
#   QUANT_WINDOW -> GEMM_INT8_QKV -> WINDOW_ATTENTION -> QUANT -> GEMM_WINDOW_INT8_RESIDUAL
# Our grid: int8 pk (1B/elem) + per-row scale sc (4B/token); f16 faces = 2B/elem;
# the scores/accumulator stage is f32 = 4B/elem (the shipped gemm acc + softmax row source).
# A WG owns T tokens of one window (T = TOK = 64 = a whole window), heads = C/32, TOK = 64.
# QKV face: QKV=0 -> the window-major global native face (S30 / lmxx form: attention reads
#   the Q/K/V dpas tiles straight from global, ZERO pack); QKV=1 -> SLM tiles (the b6 form).
# Btile: 0 -> the int8 gemm's B (weights) fed from global (R2); >0 -> SLM double buffer.
# ATT: per-head serial (ATT_SERIAL=1 -> one head's att at a time) or both heads at once.
# SKIP/OUT2: 1 = the 1267 skip / 1270 out staged in SLM (they are GLOBAL in this design).
CAP, CLIFF = 65536, 32768

def budget(C, T=64, TOK=64, QKV=0, BT=1, ATT_SERIAL=1, SKIPSLM=0, OUT2SLM=0, SCG=0):
    H = C // 32
    s = {}
    s['pk0+sc']  = (C + (0 if SCG else 4)) * T                  # P7 out (A operand of the QKV gemm)
    s['qkv']     = (6*C*T if QKV else 0)                        # P8 out / P9 in (3C f16)
    s['scores']  = 4*T*TOK                                      # P9 f32 acc stage (per head, serial)
    s['probs']   = 2*T*TOK                                      # P9 softmax out (f16, pack_a16 map)
    s['smtab']   = 0 if SCG else 4*T                            # 1/sum row scalars (registers here)
    s['att']     = (2*(C if not ATT_SERIAL else 32)*T if ATT_SERIAL else 2*C*T)
    s['pk2+sc2'] = (C + (0 if SCG else 4)) * T                  # P10 out (A operand of the wres gemm)
    s['B']       = BT * (4096 if C == 64 else 8192)             # int8 gemm B tiles (double buffer)
    s['skip']    = 2*C*T if SKIPSLM else 0                      # 1267 (P7 src + P11 skip)
    s['out2']    = 2*C*T if OUT2SLM else 0                      # 1270 (P11 out)
    # alias blocks (lifetime: P7..P11 are strictly serial inside one WG)
    A = max(s['scores'], s['pk2+sc2'], s['smtab'])              # Z0: acc/scores -> PKT+AS2
    B = max(s['pk0+sc'], s['probs'])                            # Y0: PK0 -> probs
    Cc = max(s['att'], s['B'], s['out2'])                       # X0: B tiles -> ATT -> B tiles
    D = s['qkv']                                                # the SLM-tile variant only
    E = s['skip']                                               # never aliasable if resident
    noalias = sum(s.values())
    ali = A + B + Cc + D + E
    return s, noalias, (A, B, Cc, D, E), ali

def line(name, **kw):
    C = kw['C']; T = kw.get('T', 64)
    s, tot, blk, ali = budget(**kw)
    print(f"{name:34} C={C:<4} T={T:<3} | noalias {tot:>7} | A {blk[0]:>6} B {blk[1]:>6} "
          f"C {blk[2]:>6} D {blk[3]:>6} E {blk[4]:>6} | PEAK {ali:>7} "
          f"cap {ali-CAP:>+7} cliff {ali-CLIFF:>+7} {'CLIFF-OK' if ali<=CLIFF else ('CAP-OK' if ali<=CAP else 'REJECT')}")
    return ali

if __name__ == '__main__':
    print("== S6-1b' phase 1: attention-side 5-fa, ONE WG = one 64-token window ==")
    print("-- the b6 cross-check (QKV tiles in SLM, B in SLM, both heads' att) --")
    line('b6 form C64 (expect 57,344)', C=64, QKV=1, BT=1, ATT_SERIAL=0)
    print("-- this shovel's target form (S30: qkv + B tile fall to global) --")
    line('C64 qkvG BtileSLM att-serial', C=64, QKV=0, BT=1, ATT_SERIAL=1)
    line('C64 qkvG BtileG att-serial',   C=64, QKV=0, BT=0, ATT_SERIAL=1)
    line('C64 qkvG BtileG att-both',     C=64, QKV=0, BT=0, ATT_SERIAL=0)
    line('C64 qkvSLM BtileG att-both',   C=64, QKV=1, BT=0, ATT_SERIAL=0)
    print("-- C=128 rung --")
    line('C128 qkvG BtileG att-serial',  C=128, QKV=0, BT=0, ATT_SERIAL=1)
    line('C128 qkvG BtileSLM att-serial',C=128, QKV=0, BT=1, ATT_SERIAL=1)
    line('C128 qkvG BtileG att-both',    C=128, QKV=0, BT=0, ATT_SERIAL=0)
    line('C128 qkvSLM BtileSLM att-both',C=128, QKV=1, BT=1, ATT_SERIAL=0)
    print("-- what falls to global costs (bytes touched per window, write+read) --")
    for C in (64, 128):
        print(f"  C={C}: qkv face 3C f16 = {6*C*64} B/window (write) + {6*C*64} B (read back) "
              f"= {12*C*64} B/window of L2 traffic")
        print(f"  C={C}: B tiles (qkv 3x2kb + wres 2x2kb) = {(3*2+2*2)*(2048 if C==64 else 4096)} B/window "
              f"read with {(4 if C==64 else 8)}x thread redundancy")
    print("-- 1267 / 1270 if they had to be resident (they do NOT here) --")
    for C in (64, 128):
        print(f"  C={C}: skip 1267 = {2*C*64} B, out 1270 = {2*C*64} B  (S29: 1267 uncuttable inside a full block)")
