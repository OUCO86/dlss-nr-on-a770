import re
p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

# template param
s=s.replace('int CSTOP = 0, bool PW32 = false>','int CSTOP = 0, bool PW32 = false, bool SPLITC = false>')

# Grab the existing per-c expand+encode block text (the !PW32 path) and the proj
# block and the tail -- we REFOLD them into a pass lambda under if constexpr.
# 1) the c-loop start line through the proj kc2 loop end (before the wcA hoist):
a = s.index('            for (int c = 0; c < 4; ++c) {\n                if constexpr (!PW32) {')
b = s.index('            esimd::simd<float,16> wcA, wcB;', a)
cloop = s[a:b]   # includes expand + proj loops
# 2) the tail from wcA decl through the end of the r-loop (before tile-loop close):
t0 = b
t1 = s.index('            }   // tile loop (persistent form)')
tail = s[t0:t1]

passfn = '''            // B3-ffn-17 SPLITC (the GRF-wall proof from the symmetric cs5/cs6p
            // probes: deleting EITHER proj chain saves 0.65ms -- impossible for
            // independent chains (they'd save 0.33 each) unless the 8 live
            // accumulators (p00..q11, declared OUTSIDE the c loop) spill: the
            // function's peak live set = 8 proj + 4 expand = 12 x simd<float,64>.
            // THE CUT: run the whole c-loop TWICE (pass 0 = p-chain only, its
            // tail stores cols 0..15; pass 1 = q-chain only, cols 16..31). The
            // expand+encode block RE-RUNS per pass -- deterministic dpas order =
            // bit-identical HS (the same values, computed twice, costs the
            // 0.39ms we can afford: the spill tax is 0.65). Peak live: 4+4.
            auto one_pass = [&](int ph) SYCL_ESIMD_FUNCTION {
                esimd::simd<float,64> r0(0.f), r1(0.f), r2(0.f), r3(0.f);   // ph0: p00 p01 p10 p11 / ph1: q...
'''
# transform cloop: e-loop stays; proj: replace p00/p01/p10/p11 and q00..q11 with r0..r3,
# and the b/c loads: ph selects source offset.
pc = cloop
pc = re.sub(r'\bp00\b','r0',pc); pc = re.sub(r'\bp01\b','r1',pc)
pc = re.sub(r'\bp10\b','r2',pc); pc = re.sub(r'\bp11\b','r3',pc)
pc = re.sub(r'\bq00\b','r0',pc); pc = re.sub(r'\bq01\b','r1',pc)
pc = re.sub(r'\bq10\b','r2',pc); pc = re.sub(r'\bq11\b','r3',pc)
# the proj loads: b0=(wb), b1=(wb+256) for p; c0=(wb+512), c1=(wb+768) for q.
# after renaming BOTH chains write r0..r3 -- need to keep only the ph-appropriate one:
pc = pc.replace('''                    esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    r0 = esimd::xmx::dpas<8,8,float>(r0, b0, a0);
                    r1 = esimd::xmx::dpas<8,8,float>(r1, b1, a0);
                    r2 = esimd::xmx::dpas<8,8,float>(r2, b0, a1);
                    r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);
                    bb += 256;''','''                    const half* bb2 = dPp + ((size_t)kcg * 2u + (unsigned)ph) * 2u * 128u;
                    uint wbp = wsb + 8192u + kcg * 1024u + (uint)ph * 512u;
                    esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wbp, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb2, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wbp + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb2 + 128, esimd::overaligned_tag<16>{});
                    r0 = esimd::xmx::dpas<8,8,float>(r0, b0, a0);
                    r1 = esimd::xmx::dpas<8,8,float>(r1, b1, a0);
                    r2 = esimd::xmx::dpas<8,8,float>(r2, b0, a1);
                    r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);
                    (void)bb;''')
# remove the q-chain original lines (they now duplicate r0..r3 writes): the c0/c1 loads + 4 dpas
pc = re.sub(r'\n\s*esimd::simd<half,128> c0 = WSTAGE.*?\n\s*esimd::simd<half,128> c1 = WSTAGE.*?\n\s*r0 = esimd::xmx::dpas<8,8,float>\(r0, c0, a0\);\n\s*r1 = esimd::xmx::dpas<8,8,float>\(r1, c1, a0\);\n\s*r2 = esimd::xmx::dpas<8,8,float>\(r2, c0, a1\);\n\s*r3 = esimd::xmx::dpas<8,8,float>\(r3, c1, a1\);', '', pc, flags=re.S)
# drop the old 'const half* bb = dPp + ((size_t)kcg * 2u + 0u) * 2u * 128u;' and 'uint wb = ...' lines? keep as-is (unused now) -- actually they ARE used by the replaced block? we replaced with bb2/wbp; old bb/wb lines remain: harmless (dead).
# the p/q accumulator DECL lines inside cloop: 'esimd::simd<float,64> p00...' already renamed to r0..; but they were declared in the tail region (before c loop) not inside cloop -- check: decls are ABOVE the c loop. In cloop they don't appear. Good: r0..r3 declared in passfn header.
# BUT cloop's proj loop references r0..r3 -- declared in passfn. OK.

# transform tail: f0 from r0/r1 rows, g from r2/r3: ph0 stores cols 0..15 (oa only), ph1 stores 16..31
tc = tail
tc = re.sub(r'\bp00\b','r0',tc); tc = re.sub(r'\bp01\b','r1',tc)
tc = re.sub(r'\bp10\b','r2',tc); tc = re.sub(r'\bp11\b','r3',tc)
tc = re.sub(r'\bq00\b','r0',tc); tc = re.sub(r'\bq01\b','r1',tc)
tc = re.sub(r'\bq10\b','r2',tc); tc = re.sub(r'\bq11\b','r3',tc)
# wcA/wcB: select by ph
tc = tc.replace('esimd::simd<float,16> wcA, wcB;','esimd::simd<float,16> wcA, wcB;')
# the tail stores BOTH oa(rb, cols0-15 from f0/f1=p-chain rows) and ob(rb+16, from g0/g1=q rows)
# but after renaming, row0-7 group: f0=r0, f1=r1 (ph0 chain rows), g0=r0? NO -- q00->r0 too.
# PROBLEM: tail uses p00..p11 AND q00..q11; both renamed to r0..r3 -- collision.
# Fix: tail per ph uses only ITS r0..r3: ph0 -> f0=r0,f1=f1? Let's rebuild tail explicitly instead of transform.
tailpass = '''                // ---- per-pass store tail (ph0 = cols 0..15, ph1 = 16..31) ----
                esimd::simd<float,16> wcP;
                if (dSkip && ff9) wcP = esimd::block_load<float,16>(cp + (ph ? 16u : 0u), esimd::overaligned_tag<16>{});
                size_t outb = (size_t)(tr * 16) * cin + (size_t)ph * 16u;
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    if (tr * 16 + r < M) {
                        esimd::simd<float,8> f0 = r0.template select<8,1>(r*8), f1 = r1.template select<8,1>(r*8);
                        size_t rb = outb + (size_t)r * cin;
                        if (dSkip) {
                            esimd::simd<float,16> kA = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                            { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcP.template select<8,1>(0) + f0;
                              esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcP.template select<8,1>(8) + f1;
                              esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                        } else { f0.copy_to(Cout + rb + 0); f1.copy_to(Cout + rb + 8); }
                    }
                    if (tr * 16 + 8 + r < M) {
                        esimd::simd<float,8> f0 = r2.template select<8,1>(r*8), f1 = r3.template select<8,1>(r*8);
                        size_t rb = outb + (size_t)(8 + r) * cin;
                        if (dSkip) {
                            esimd::simd<float,16> kA = half_skip
                                ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                                : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                            { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcP.template select<8,1>(0) + f0;
                              esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcP.template select<8,1>(8) + f1;
                              esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                        } else { f0.copy_to(Cout + rb + 0); f1.copy_to(Cout + rb + 8); }
                    }
                }
'''

# strip p/q accumulator DECL lines from cloop if any survived (they were outside): none.
# build the SPLITC block: passfn = header + pc (expand+proj) + tailpass + close; then calls.
# pc currently contains BOTH chains? we replaced p-chain and removed q-chain lines -> ph-param loads.
splitc = passfn + pc + tailpass + '''            };
            one_pass(0);
            one_pass(1);
'''

# splice: replace [a, t1) with if constexpr wrapper
newblock = ('        if constexpr (SPLITC) {\n' + splitc + '        } else {\n'
            + s[a:t1] + '        }\n')
s = s[:a] + newblock + s[t1:]
open(p,'w',encoding='utf-8').write(s)
print('ffn-17 SPLITC spliced')
