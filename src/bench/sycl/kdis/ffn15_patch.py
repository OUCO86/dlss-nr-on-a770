p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

# add PW32 template param
old0='''template <int LW, bool WSTAGE = false, int CSTOP = 0>
static inline event launch_ffn_chip('''
new0='''template <int LW, bool WSTAGE = false, int CSTOP = 0, bool PW32 = false>
static inline event launch_ffn_chip('''
assert old0 in s, 'anchor0 miss'
s=s.replace(old0,new0)

# replace the tl-loop region: from 'for (int tl = 0; tl < 2; ++tl) {' through its
# closing (the encode + fjoin stores + '}' of tl loop). Capture exact text.
i0 = s.index('            for (int c = 0; c < 4; ++c) {\n                for (int tl = 0; tl < 2; ++tl) {')
# find the end of the tl loop: the line '                }' right before the
# '(v3: NO barrier here' comment
i1 = s.index('                // (v3: NO barrier here', i0)
old_tl = s[i0+len('            for (int c = 0; c < 4; ++c) {\n'):i1]

new_tl = '''                if constexpr (!PW32) {
                for (int tl = 0; tl < 2; ++tl) {''' + old_tl[len('                for (int tl = 0; tl < 2; ++tl) {'):-len('                }\n')] + '''                }
                } else {
                // B3-ffn-15 PW32 (the clean ledger's ONLY remaining suspect: the
                // expand+encode block ~0.39ms; pub ran 16-wide on 32-wide EUs =
                // HALF the slot still wasted). Run BOTH tl gemms first (8 live
                // accumulators -- the v3c risk, priced by bench_b3 FIRST), then
                // per row join 4x8 into ONE simd<32> pub chain (elementwise =
                // bit-exact), splitting the half result into the SAME two 32B
                // stores the tl-split HS layout demands (proj loads unchanged).
                esimd::simd<float,64> e00a(0.f), e01a(0.f), e10a(0.f), e11a(0.f);
                esimd::simd<float,64> e00b(0.f), e01b(0.f), e10b(0.f), e11b(0.f);
                #pragma unroll
                for (int tl = 0; tl < 2; ++tl) {
                    auto& E00 = tl ? e00b : e00a; auto& E01 = tl ? e01b : e01a;
                    auto& E10 = tl ? e10b : e10a; auto& E11 = tl ? e11b : e11a;
                    #pragma unroll
                    for (int kc = 0; kc < 2; ++kc) {
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+0u)*256u, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ea + (uint)(kc*2u+1u)*256u, esimd::overaligned_tag<16>{});
                        uint tc = (uint)(c * 2 + tl);
                        const half* bb = dEp + ((size_t)kc * 8u + tc) * 2u * 128u;
                        esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((kc * 8u + tc) * 2u * 128u) * 2u, esimd::overaligned_tag<16>{})
                                                          : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wsb + (uint)((kc * 8u + tc) * 2u * 128u + 128u) * 2u, esimd::overaligned_tag<16>{})
                                                          : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        E00 = esimd::xmx::dpas<8,8,float>(E00, b0, a0);
                        E01 = esimd::xmx::dpas<8,8,float>(E01, b1, a0);
                        E10 = esimd::xmx::dpas<8,8,float>(E10, b0, a1);
                        E11 = esimd::xmx::dpas<8,8,float>(E11, b1, a1);
                    }
                }
                const esimd::simd<half,8> z8((half)0.f);
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    bool in0 = (tr * 16 + r) < (int)M, in1 = (tr * 16 + 8 + r) < (int)M;
                    if (in0) {
                        esimd::simd<float,32> x;
                        x.template select<8,1>(0)  = e00a.template select<8,1>(r*8);
                        x.template select<8,1>(8)  = e01a.template select<8,1>(r*8);
                        x.template select<8,1>(16) = e00b.template select<8,1>(r*8);
                        x.template select<8,1>(24) = e01b.template select<8,1>(r*8);
                        esimd::simd<half,32> hj = esimd::convert<half>(s8v8::pub_vec_v8<32>(3u, x));
                        esimd::slm_block_store(hs + (uint)r * 32u, hj.template select<16,1>(0), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 512u + (uint)r * 32u, hj.template select<16,1>(16), esimd::overaligned_tag<16>{});
                    } else {
                        esimd::slm_block_store(hs + (uint)r * 32u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + (uint)r * 32u + 16u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 512u + (uint)r * 32u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 512u + (uint)r * 32u + 16u, z8, esimd::overaligned_tag<16>{});
                    }
                    if (in1) {
                        esimd::simd<float,32> x;
                        x.template select<8,1>(0)  = e10a.template select<8,1>(r*8);
                        x.template select<8,1>(8)  = e11a.template select<8,1>(r*8);
                        x.template select<8,1>(16) = e10b.template select<8,1>(r*8);
                        x.template select<8,1>(24) = e11b.template select<8,1>(r*8);
                        esimd::simd<half,32> hj = esimd::convert<half>(s8v8::pub_vec_v8<32>(3u, x));
                        esimd::slm_block_store(hs + 256u + (uint)r * 32u, hj.template select<16,1>(0), esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 768u + (uint)r * 32u, hj.template select<16,1>(16), esimd::overaligned_tag<16>{});
                    } else {
                        esimd::slm_block_store(hs + 256u + (uint)r * 32u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 256u + (uint)r * 32u + 16u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 768u + (uint)r * 32u, z8, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hs + 768u + (uint)r * 32u + 16u, z8, esimd::overaligned_tag<16>{});
                    }
                }
                }
'''
s=s[:i0+len('            for (int c = 0; c < 4; ++c) {\n')] + new_tl + s[i1:]
open(p,'w',encoding='utf-8').write(s)
print('ffn-15 PW32 wired')
