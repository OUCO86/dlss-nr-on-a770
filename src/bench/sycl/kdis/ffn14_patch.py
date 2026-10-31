p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

# 1) declarations: drop p/q pre-decl + cstop==1 line (keep the probe harmless)
old1='''            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31
            if (cstop == 1) { tr0 = tiles; continue; }   // expand-only stop (after the HS stores above)'''
new1='''            // B3-ffn-14 SPLIT-PROJ: p-chain (out cols 0..15) and q-chain (16..31)
            // are INDEPENDENT (share only read-only SLM a0/a1 + weight stream).
            // Run them as two half-loops with accumulators declared INSIDE each
            // and the store tail consumed per half -- the compiled function's
            // PEAK LIVE SET drops (the cs4-shell floor = the function's register
            // budget: 1.28ms in-function vs 0.011ms standalone same-shape).
            // dpas order per accumulator UNCHANGED; per-column store addresses
            // UNCHANGED = bit-exact by construction.'''
assert old1 in s, 'anchor1 miss'
s=s.replace(old1,new1)

# 2) split the kc2 loop + per-half tail
old2='''                #pragma unroll
                for (int kc2 = 0; kc2 < 2; ++kc2) {
                    uint kcg = (uint)(c * 2 + kc2);
                    uint ab = hs + (uint)(kc2 * 2u) * 256u;
                    esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                    const half* bb = dPp + ((size_t)kcg * 2u + 0u) * 2u * 128u;
                    uint wb = wsb + 8192u + kcg * 1024u;
                    esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    p00 = esimd::xmx::dpas<8,8,float>(p00, b0, a0);
                    p01 = esimd::xmx::dpas<8,8,float>(p01, b1, a0);
                    p10 = esimd::xmx::dpas<8,8,float>(p10, b0, a1);
                    p11 = esimd::xmx::dpas<8,8,float>(p11, b1, a1);
                    bb += 256;
                    esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                    esimd::simd<half,128> c1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 768u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                    q00 = esimd::xmx::dpas<8,8,float>(q00, c0, a0);
                    q01 = esimd::xmx::dpas<8,8,float>(q01, c1, a0);
                    q10 = esimd::xmx::dpas<8,8,float>(q10, c0, a1);
                    q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);
                }
            }'''
new2='''                #pragma unroll 1
                for (int ph = 0; ph < 2; ++ph) {   // ffn-14: p-chain (ph0), q-chain (ph1)
                    if (cstop == 1 && ph == 1) break;   // expand-only stop keeps ph0's stores
                    esimd::simd<float,64> r0(0.f), r1(0.f), r2(0.f), r3(0.f);
                    #pragma unroll
                    for (int kc2 = 0; kc2 < 2; ++kc2) {
                        uint kcg = (uint)(c * 2 + kc2);
                        uint ab = hs + (uint)(kc2 * 2u) * 256u;
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                        const half* bb = dPp + ((size_t)kcg * 2u + (ph ? 1u : 0u)) * 2u * 128u;
                        uint wb = wsb + 8192u + kcg * 1024u + (uint)ph * 512u;
                        esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        r0 = esimd::xmx::dpas<8,8,float>(r0, b0, a0);
                        r1 = esimd::xmx::dpas<8,8,float>(r1, b1, a0);
                        r2 = esimd::xmx::dpas<8,8,float>(r2, b0, a1);
                        r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);
                    }
                    // ---- per-half store tail (ph0 = cols 0..15 w/ wcA; ph1 = 16..31 w/ wcB) ----
                    size_t outb2 = (size_t)(tr * 16) * cin + (size_t)ph * 16u;
                    const esimd::simd<float,16> wcP = ph ? wcB : wcA;
                    #pragma unroll
                    for (int r = 0; r < 8; ++r) {
                        if (tr * 16 + r < M) {
                            esimd::simd<float,8> f0 = r0.template select<8,1>(r*8), f1 = r1.template select<8,1>(r*8);
                            size_t rb = outb2 + (size_t)r * cin;
                            if (dSkip) {
                                esimd::simd<float,16> kA = half_skip
                                    ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb, esimd::overaligned_tag<16>{}))
                                    : esimd::block_load<float,16>((const float*)dSkip + rb, esimd::overaligned_tag<16>{});
                                { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcP.template select<8,1>(0) + f0;
                                  esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcP.template select<8,1>(8) + f1;
                                  esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb); }
                            } else {
                                f0.copy_to(Cout + rb + 0);
                                f1.copy_to(Cout + rb + 8);
                            }
                        }
                        if (tr * 16 + 8 + r < M) {
                            esimd::simd<float,8> f0 = r2.template select<8,1>(r*8), f1 = r3.template select<8,1>(r*8);
                            size_t rb2 = outb2 + (size_t)(8 + r) * cin;
                            if (dSkip) {
                                esimd::simd<float,16> kA = half_skip
                                    ? esimd::convert<float>(esimd::block_load<half,16>((const half*)dSkip + rb2, esimd::overaligned_tag<16>{}))
                                    : esimd::block_load<float,16>((const float*)dSkip + rb2, esimd::overaligned_tag<16>{});
                                { esimd::simd<float,8> oA = kA.template select<8,1>(0) * wcP.template select<8,1>(0) + f0;
                                  esimd::simd<float,8> oB = kA.template select<8,1>(8) * wcP.template select<8,1>(8) + f1;
                                  esimd::simd<float,16> oa; oa.template select<8,1>(0) = oA; oa.template select<8,1>(8) = oB; oa.copy_to(Cout + rb2); }
                            } else {
                                f0.copy_to(Cout + rb2 + 0);
                                f1.copy_to(Cout + rb2 + 8);
                            }
                        }
                    }
                }
            }'''
assert old2 in s, 'anchor2 miss'
s=s.replace(old2,new2)

# 3) the OLD store tail (which read p00..q11) must be deleted: from the ff9 wcA/wcB
#    hoist's cstop>=2 line through the end of the tail's r-loop block.
import re
i = s.index('            // NR_CS_STOP segment attribution (TIME-ONLY diagnostic; host-captured')
j = s.index('            }   // tile loop (persistent form)', i)
old_tail = s[i:j]
new_tail = '''            // (ffn-14: the store tail is now PER-HALF inside the ph loop; the
            // old combined tail reading p00..q11 is GONE. cstop>=2 semantics:
            // the probe stops before the proj loops entirely:)
            if (cstop >= 2) { tr0 = tiles; continue; }
'''
s = s[:i] + new_tail + s[j:]
open(p,'w',encoding='utf-8').write(s)
print('ffn-14 complete')
