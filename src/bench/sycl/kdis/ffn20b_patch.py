p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

# v2: from the v1 cs function, restructure:
#  - A staging: even rows 0..7, odd rows 8..15 (parallel)
#  - expand tl loop: each thread does tl == ph only (parallel halves)
#  - barrier per c (HS group published to the pair)
#  - proj: both threads, kc2 loop, cols split by ph (4 accs each)
i0 = s.index('template <int LW, bool WSTAGE = false>\nstatic inline event launch_ffn_chip_cs(')
i1 = s.index('\n// P8-n / B1 BRICK 1', i0)
v1 = s[i0:i1]

v2 = v1.replace('launch_ffn_chip_cs(', 'launch_ffn_chip_cs2(')

# A staging split by ph:
old_a = '''            // ---- A staging into the slot's EA (even thread of the pair) ----
            if (ours && ph == 0u) {
                #pragma unroll
                for (int r = 0; r < 8; ++r) {'''
new_a = '''            // ---- ffn-20 CS2: A staging SPLIT across the pair (rows 0..7 even,
            // 8..15 odd); expand tl SPLIT (even=group0, odd=group1); proj COLS
            // split by ph. BOTH threads busy in every phase; peak live accs
            // per thread = 4 (e) + 4 (r) = 8 -- the spill switch OFF (shipping
            // = 12). v1 (idle odd in expand) priced +0.22: the half-idle
            // penalty ate the spill win -- this version removes the idleness.
            if (ours && ph == 0u) {
                #pragma unroll
                for (int r = 0; r < 8; ++r) {'''
assert old_a in v2; v2=v2.replace(old_a,new_a)
# move second A loop under ph==1:
old_a2 = '''                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<half,32> v((half)0.f);
                    if (tr * 16 + 8 + r < (int)M)'''
new_a2 = '''            }
            if (ours && ph == 1u) {
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<half,32> v((half)0.f);
                    if (tr * 16 + 8 + r < (int)M)'''
assert old_a2 in v2; v2=v2.replace(old_a2,new_a2)

# expand: tl loop becomes tl = ph only:
old_e = '''                if (ours && ph == 0u) {
                    for (int tl = 0; tl < 2; ++tl) {'''
new_e = '''                if (ours) {
                    for (int tl = (int)ph; tl < (int)ph+1; ++tl) {'''
assert old_e in v2; v2=v2.replace(old_e,new_e)

v2 = v2.replace('''            esimd::barrier();                     // EA (+weights) visible to the pair''',
                '''            esimd::barrier();                     // EA (+weights) visible to the pair''')
# add the per-c barrier AFTER the encode (v1 already has 'esimd::barrier(); // HS[c] ...' -- good).
# proj in v1 is 'if (ours) { for kc2...' -- same. OK.
# the v1 tail is already per-ph. OK.

s = s[:i1] + '\n' + v2 + s[i1:]
open(p,'w',encoding='utf-8').write(s)
print('cs2 appended')
