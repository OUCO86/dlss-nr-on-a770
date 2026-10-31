p='gemm_s8_v8_kernel.hpp'
s=open(p,encoding='utf-8').read()
import re

# The depth-1 loop text is IDENTICAL across the pub/res/res_window functions
# (load_block/load_grf lambdas + loop). Convert EVERY gemm-family kernel that
# uses the standard SLM_TOTAL two-buffer pipeline to three-buffer depth-2,
# EXCEPT gemm_b_pub_slm (its C-stage aliases the operand SLM at base 0 --
# different geometry, and it is not the frame's main path).
# Strategy: replace the shared constants' USES per function body.

# 1) global constants: keep old for pub_slm; add D3 trio
s=s.replace('''static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;''',
'''static const int SLM_TOTAL = 2 * SLM_A + 2 * SLM_B;
// B3-s8d2 (2026-10-31): the depth-2 three-buffer pipeline -- the 19.4ms gap to
// the senior's 47.19 roofline ride is LATENCY, not traffic (laws: 592-734 GB/s
// in-flight ceiling vs our gemms' 100-190 effective). Depth-1 keeps one 192B/
// thread pair in flight (~300-500ns DRAM) against ~150ns of dpas per block =
// the pipeline drains every kb. Three buffers + kb+2 prefetch = two pairs in
// flight. SLM 12->18KB (NT32: occupancy 5->3 WG/SM -- the trade the laws curve
// says to take). dpas order per kb VERBATIM = bit-exact. gemm_b_pub_slm KEEPS
// the two-buffer geometry (its C-stage aliases the operand SLM at base 0).''')

# 2) slm_init sites EXCEPT pub_slm's (16384/32768 ones are pub_slm -- skip):
n1 = s.count('esimd::slm_init<SLM_TOTAL>();')
s = s.replace('esimd::slm_init<SLM_TOTAL>();','esimd::slm_init<3 * SLM_A + 3 * SLM_B>();')
# 3) SLM_B_BASE uses inside load_block/load_grf of those kernels: the base moves to 3*SLM_A.
#    SLM_B_BASE is referenced ONLY in the pipeline lambdas; pub_slm references it too --
#    but pub_slm's slm_init is the HALF?16384:32768 line, NOT SLM_TOTAL... wait it uses
#    SLM_B_BASE at offset 2*SLM_A inside a 32768 region. So define per-kernel local instead:
# Revert the global-const substitution approach: instead, shadow SLM_B_BASE inside the
# converted functions via a local constexpr inserted right after their slm_init line.
s = s.replace('esimd::slm_init<3 * SLM_A + 3 * SLM_B>();','''esimd::slm_init<3 * SLM_A + 3 * SLM_B>();
            const int SLM_B_BASE2 = 3 * SLM_A; (void)SLM_B_BASE2;''')
# that shadow trick won't change the lambdas (they capture SLM_B_BASE by name from scope;
# a local const declared BEFORE the lambdas would win). Redo: put the shadow BEFORE
# load_block lambda. Find each converted function's load_block start.
out=[]
lines=s.split('\n')
i=0
converted=0
while i < len(lines):
    L=lines[i]
    out.append(L)
    if 'const int SLM_B_BASE2 = 3 * SLM_A; (void)SLM_B_BASE2;' in L:
        # remove the placeholder we just injected; instead inject shadow before next 'auto load_block'
        out[-1]=''  # drop placeholder line
        # scan forward to the load_block lambda line, inject shadow there
        j=i+1
        while j<len(lines) and 'auto load_block' not in lines[j]:
            out.append(lines[j]); j+=1
        if j<len(lines):
            out.append('            const int SLM_B_BASE = 3 * SLM_A;   // s8d2 shadow (three-buffer)')
            out.append(lines[j])
            converted+=1
        i=j+1
        continue
    i+=1
s='\n'.join(out)
# also fix the loop bodies: two-buffer cur/nxt -> three-buffer
old_loop='''            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b & 1, nxt = cur ^ 1;
                if (b + 1 < kb_n) load_block(nxt, b + 1);
                load_grf(cur, a0, a1, b0, b1);'''
new_loop='''            esimd::simd<int8_t, 256> a0, a1, b0, b1;
            esimd::simd<int32_t, 64> c00(0), c01(0), c10(0), c11(0);
            load_block(0, 0);
            if (K / BK > 1) load_block(1, 1);   // s8d2 prologue: two buffers filled
            esimd::barrier();
            int kb_n = K / BK;
            for (int b = 0; b < kb_n; ++b) {
                int cur = b % 3;
                if (b + 2 < kb_n) load_block((b + 2) % 3, b + 2);   // s8d2 depth-2
                load_grf(cur, a0, a1, b0, b1);'''
n=s.count(old_loop)
s=s.replace(old_loop,new_loop)
open(p,'w',encoding='utf-8').write(s)
print('loops converted:',n,'shadowed:',converted)
