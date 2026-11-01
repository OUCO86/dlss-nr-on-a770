import itertools
def layout(C, T, TOK, KVSLM, BT, SCG):
    # bytes; f16 = 2B/elem, pk int8 = 1B/elem, sc = 4B/token (SCG=1 -> scales in GLOBAL, not SLM)
    s = {}
    s['in']    = 2*C*T
    s['pk']    = (C + (0 if SCG else 4))*T
    s['pkH']   = (4*C + (0 if SCG else 4))*T
    s['hid']   = 8*C*T
    s['out']   = 2*C*T
    s['1267']  = 2*C*T
    s['q']     = 2*C*T
    s['kv']    = (4*C*TOK) if KVSLM else 0
    s['scores']= 2*T*TOK
    s['att']   = 2*C*T
    s['o2']    = 2*C*T
    s['B']     = BT
    tot = sum(s.values())
    A = max(s['hid'], s['q']+s['kv']+s['att'], s['out'])
    B = max(s['pkH'], s['scores'], s['pk'])
    Cc = max(s['in'], s['o2'])
    D = s['1267']
    E = s['B']
    ali = A+B+Cc+D+E
    return s, tot, (A,B,Cc,D,E), ali

cfgs = [
 (0,'C64_T64_full',      64, 64,64,1,8192,0),
 (1,'C64_T16_full',      64, 16,64,1,8192,0),
 (2,'C128_T64_full',    128, 64,64,1,8192,0),
 (3,'C128_T16_full',    128, 16,64,1,8192,0),
 (4,'C64_T64_noBtile',   64, 64,64,1,0,   0),
 (5,'C64_T64_noB_scG',   64, 64,64,1,0,   1),
 (6,'C64_T16_kvGlobal',  64, 16,64,0,8192,0),
 (7,'C64_T16_cut_all',   64, 16,64,0,0,   1),
 (8,'C128_T16_kvGlobal',128, 16,64,0,8192,0),
 (9,'C128_T16_cut_all', 128, 16,64,0,0,   1),
 (10,'C64_T32_full',     64, 32,64,1,8192,0),
 (11,'C64_T32_kvGlobal', 64, 32,64,0,8192,0),
 (12,'C128_T32_kvGlobal',128,32,64,0,8192,0),
 (13,'C64_T64_kvGlobal',  64,64,64,0,8192,0),
]
print(f"{'cfg':>4} {'name':22} {'C':>4} {'T':>4} | {'noalias':>8} {'A':>7} {'B':>7} {'Cc':>6} {'D':>6} {'E':>6} {'ALIAS':>7} {'vs65536':>8} {'vs32768':>8}")
for i,n,C,T,TOK,KV,BT,SCG in cfgs:
    s,tot,blk,ali = layout(C,T,TOK,KV,BT,SCG)
    print(f"{i:>4} {n:22} {C:>4} {T:>4} | {tot:>8} {blk[0]:>7} {blk[1]:>7} {blk[2]:>6} {blk[3]:>6} {blk[4]:>6} {ali:>7} {ali-65536:>+8} {ali-32768:>+8}")
print()
print("== the required four (full plan, scales in SLM, B tile in SLM) ==")
for i,n,C,T,TOK,KV,BT,SCG in [(0,'C64 T64',64,64,64,1,8192,0),(2,'C128 T64',128,64,64,1,8192,0),(1,'C64 T16',64,16,64,1,8192,0),(3,'C128 T16',128,16,64,1,8192,0)]:
    s,tot,blk,ali = layout(C,T,TOK,KV,BT,SCG)
    print(f"  {n:9} noalias={tot:7} aliased={ali:7}  ({ali/1024:.2f} KB)  cap-slack={65536-ali:+7}  cliff-slack={32768-ali:+7}")
    print("      slices:", ", ".join(f"{k}={v}" for k,v in s.items()))
