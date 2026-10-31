import re
p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

# locate the c-loop block (proj inside) and the tail block; generate SPLITC variant
m = re.search(r'\n( *)for \(int c = 0; c < 4; \+\+c\) \{\n(.*?\n\1\})\n', s, re.S)
assert m, 'c-loop block not found'
cloop = m.group(2)
indent = m.group(1)

# the tail: from 'size_t outb = (size_t)(tr * 16) * cin;' to the close of its r-loop,
# i.e. up to the line before '}   // tile loop (persistent form)'
i0 = s.index('            size_t outb = (size_t)(tr * 16) * cin;')
i1 = s.index('            }   // tile loop (persistent form)')
tail = s[i0:i1]

# the wcA/wcB hoist lines (before outb):
i2 = s.index('            esimd::simd<float,16> wcA, wcB;', i1-20000 if i1>20000 else 0)
# find nearest wcA decl BEFORE i0
i2 = s.rindex('            esimd::simd<float,16> wcA, wcB;', 0, i0)
wcblk = s[i2:i0]

# ---- transform helpers ----
def qdrop(block):
    # remove the q-chain lines in the proj kc2 loop (c0/c1 loads + q dpas) and 'bb += 256;'
    out=[]
    skip=False
    for ln in block.split('\n'):
        t=ln.strip()
        if t.startswith('esimd::simd<half,128> c0 ='): skip=True
        if skip:
            if 'q11 = esimd::xmx::dpas' in t: skip=False
            continue
        if t=='bb += 256;': continue
        if re.search(r'\bq0[01]\b|\bq1[01]\b', t) and 'select<8,1>' in t and 'g0' in t: continue  # tail g-loads
        if re.match(r'esimd::simd<float,8> g0 =', t): continue
        out.append(ln)
    return '\n'.join(out)

def pdrop(block):
    out=[]
    for ln in block.split('\n'):
        t=ln.strip()
        if re.match(r'esimd::simd<half,128> b0 =', t): continue
        if re.match(r'esimd::simd<half,128> b1 =', t): continue
        if re.match(r'p0[01] = esimd::xmx::dpas', t): continue
        if re.match(r'p1[01] = esimd::xmx::dpas', t): continue
        if re.match(r'esimd::simd<float,8> f0 = p', t): continue
        if re.match(r'const half\* bb = dPp', t): continue
        if re.match(r'uint wb = wsb \+ 8192u', t): continue
        out.append(ln)
    return '\n'.join(out)

# renames: pass P uses p00..p11 -> r0..r3 ; pass Q q00..q11 -> r0..r3
def ren(block, which):
    if which=='p':
        for a,b in [('p00','r0'),('p01','r1'),('p10','r2'),('p11','r3')]:
            block=re.sub(r'\b'+a+r'\b',b,block)
    else:
        for a,b in [('q00','r0'),('q01','r1'),('q10','r2'),('q11','r3')]:
            block=re.sub(r'\b'+a+r'\b',b,block)
    return block

decl = '            esimd::simd<float,64> r0(0.f), r1(0.f), r2(0.f), r3(0.f);   // SPLITC half-accumulators\n'

# pass P: c-loop with q dropped, p renamed; tail with q-stores dropped (keep f0/f1 stores, kA fold)
P_c = ren(qdrop(cloop),'p')
P_tail = qdrop(tail)   # drops g0/g1 loads lines; but the g STORES reference g0/g1 -> must drop those store blocks too
# simpler for tails: rebuild from scratch per half -- write explicit tails:
P_tail_txt = '''            size_t outb = (size_t)(tr * 16) * cin;
            #pragma unroll
            for (int r = 0; r < 8; ++r) {
                if (tr * 16 + r < M) {
                    esimd::simd<float,8> f0 = r0.template select<8,1>(r*8), f1 = r1.template select<8,1>(r*8);
                    size_t rb = outb + (size_t)r * cin;
                    if (dSkip) {
                        esimd::simd<float,16> kA = half_skip
                            ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                            : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                        { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcA.template select<8,1>(0) + f0;
                          esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcA.template select<8,1>(8) + f1;
                          esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                    } else {
                        f0.copy_to(Cout + rb + 0);
                        f1.copy_to(Cout + rb + 8);
                    }
                }
                if (tr * 16 + 8 + r < M) {
                    esimd::simd<float,8> f0 = r2.template select<8,1>(r*8), f1 = r3.template select<8,1>(r*8);
                    size_t rb = outb + (size_t)(8 + r) * cin;
                    if (dSkip) {
                        esimd::simd<float,16> kA = half_skip
                            ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                            : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                        { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcA.template select<8,1>(0) + f0;
                          esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcA.template select<8,1>(8) + f1;
                          esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                    } else {
                        f0.copy_to(Cout + rb + 0);
                        f1.copy_to(Cout + rb + 8);
                    }
                }
            }
'''
Q_tail_txt = P_tail_txt.replace('r0.','r0.').replace('wcA','wcB')
Q_tail_txt = Q_tail_txt.replace('rb, esimd::overaligned_tag','rb + 16u, esimd::overaligned_tag')
Q_tail_txt = Q_tail_txt.replace('Cout + rb)','Cout + rb + 16u)')
Q_tail_txt = Q_tail_txt.replace('Cout + rb + 0)','Cout + rb + 16)').replace('Cout + rb + 8)','Cout + rb + 24)')
Q_tail_txt = Q_tail_txt.replace('f0 = r0','f0 = r0').replace('f0 = r2','f0 = r2')
Q_tail_txt = Q_tail_txt.replace('f0 = r0.template','f0 = r0.template')
# pass Q c-loop: drop p-chain and f-loads; q renamed
Q_c = ren(pdrop(cloop),'q')
# fix Q weight addressing: original q loads were c0=wb+512/c1=wb+768 (WSTAGE) and bb/bb+128 AFTER bb+=256.
# pdrop removed the 'const half* bb' and 'uint wb' lines -- re-add Q-specific:
Q_c = Q_c.replace('''                        uint kcg = (uint)(c * 2 + kc2);''','''                        uint kcg = (uint)(c * 2 + kc2);
                        const half* bb = dPp + ((size_t)kcg * 2u + 1u) * 2u * 128u;
                        uint wb = wsb + 8192u + kcg * 1024u + 512u;''')
Q_c = Q_c.replace('esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u','esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb')
Q_c = Q_c.replace('esimd::simd<half,128> c1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 768u','esimd::simd<half,128> c1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u')
Q_c = Q_c.replace('esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});\n                        r0','esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});\n                        r0')

# wc hoist per pass: P uses wcA only, Q wcB only
wcP = '            esimd::simd<float,16> wcA;\n            if (dSkip && ff9) wcA = esimd::block_load<float,16>(cp, esimd::overaligned_tag<16>{});\n'
wcQ = '            esimd::simd<float,16> wcB;\n            if (dSkip && ff9) wcB = esimd::block_load<float,16>(cp + 16, esimd::overaligned_tag<16>{});\n'

splitc = ('\n        if constexpr (SPLITC) {\n'
          '            // B3-ffn-16 SPLITC (the cs5 asymmetry: q-chain marginal 0.67ms,\n'
          '            // p-chain+tail ~0.01 = the LAST 4 accumulators tipping the GRF\n'
          '            // wall into spill). Run the whole c-loop TWICE: pass P keeps only\n'
          '            // 4 live accs (stores its tail, dies), pass Q likewise. Expand is\n'
          '            // RE-RUN per pass (deterministic dpas order = bit-identical HS).\n'
          '            // bench_b3 prices it BEFORE the dll.\n'
          '            {\n' + decl + P_c + '\n' + wcP + P_tail_txt + '            }\n'
          '            {\n' + decl + Q_c + '\n' + wcQ + Q_tail_txt + '            }\n'
          '        } else {\n')

# insert: wrap [cloop .. tail end] with if constexpr
start = m.start(1)+len(indent)-0  # begin of 'for (int c' line's indent
# use positions: c-loop begins at m.start(2); tail ends at i1
a = m.start(2)
b = i1
new_mid = splitc + s[a:b] + '        }\n'
s = s[:a] + new_mid + s[b:]
# template param:
s=s.replace('template <int LW, bool WSTAGE = false, int CSTOP = 0, bool PW32 = false>','template <int LW, bool WSTAGE = false, int CSTOP = 0, bool PW32 = false, bool SPLITC = false>')
open(p,'w',encoding='utf-8').write(s)
print('ffn-16 SPLITC generated (bench-priced first)')
