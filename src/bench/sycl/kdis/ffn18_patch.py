p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

s=s.replace('int CSTOP = 0, bool PW32 = false, bool SPLITC = false>','int CSTOP = 0, bool PW32 = false, bool SPLITC = false, bool ACCSLM = false>')

# 1) slm_init: +2KB/thread ACC area when ACCSLM
old='''            esimd::slm_init<(unsigned)LW * 2048u + (WSTAGE ? 16384u : 0u)>();   // EA+HS (+16KB weight stage)'''
new='''            esimd::slm_init<(unsigned)LW * (ACCSLM ? 4096u : 2048u) + (WSTAGE ? 16384u : 0u)>();   // EA+HS (+ACC 2KB/thread ffn-18) (+16KB weight stage)'''
assert old in s; s=s.replace(old,new)

# 2) the accumulator declarations: ACCSLM -> zero-init SLM instead
old='''            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31
            if constexpr (CSTOP == 1) { tr0 = tiles; continue; }   // expand-only stop (after the HS stores above)'''
new='''            uint accb = FFC_EA_OFF + (unsigned)LW * 2048u + lid * 2048u;   // ACCSLM tile (2KB/thread)
            if constexpr (ACCSLM) {
                const esimd::simd<float,64> zz(0.f);
                #pragma unroll
                for (int i = 0; i < 8; ++i) esimd::slm_block_store(accb + (uint)i * 256u, zz, esimd::overaligned_tag<16>{});
            } else {
            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31
            }
            if constexpr (CSTOP == 1) { tr0 = tiles; continue; }   // expand-only stop (after the HS stores above)'''
assert old in s; s=s.replace(old,new)

# 3) proj kc2 loop: load accs from SLM, dpas, store back (keeps GRF peak at 4+operands)
old='''                        esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
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
                        q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);'''
new='''                        esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        if constexpr (ACCSLM) {
                        // B3-ffn-18 ACCSLM (the GRF wall PROVEN by the symmetric
                        // cs5/cs6p probes: deleting EITHER proj chain saves 0.65 --
                        // superlinear = the 8 cross-c live accumulators (2KB/thread)
                        // spill). The proj accumulators live in a per-thread SLM
                        // tile: load 4 (p), dpas, store back, load 4 (q), dpas,
                        // store -- GRF peak = 4 accs + operands, no spill. SLM
                        // traffic +32KB/thread/tile rides the (cheap) SLM port;
                        // LW16 total SLM 4KB x 16 = 64KB = the proven bucket.
                        esimd::simd<float,64> p00 = esimd::slm_block_load<float,64>(accb + 0u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> p01 = esimd::slm_block_load<float,64>(accb + 256u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> p10 = esimd::slm_block_load<float,64>(accb + 512u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> p11 = esimd::slm_block_load<float,64>(accb + 768u, esimd::overaligned_tag<16>{});
                        p00 = esimd::xmx::dpas<8,8,float>(p00, b0, a0);
                        p01 = esimd::xmx::dpas<8,8,float>(p01, b1, a0);
                        p10 = esimd::xmx::dpas<8,8,float>(p10, b0, a1);
                        p11 = esimd::xmx::dpas<8,8,float>(p11, b1, a1);
                        esimd::slm_block_store(accb + 0u, p00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 256u, p01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 512u, p10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 768u, p11, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> q00 = esimd::slm_block_load<float,64>(accb + 1024u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> q01 = esimd::slm_block_load<float,64>(accb + 1280u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> q10 = esimd::slm_block_load<float,64>(accb + 1536u, esimd::overaligned_tag<16>{});
                        esimd::simd<float,64> q11 = esimd::slm_block_load<float,64>(accb + 1792u, esimd::overaligned_tag<16>{});
                        bb += 256;
                        esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> c1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 768u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        q00 = esimd::xmx::dpas<8,8,float>(q00, c0, a0);
                        q01 = esimd::xmx::dpas<8,8,float>(q01, c1, a0);
                        q10 = esimd::xmx::dpas<8,8,float>(q10, c0, a1);
                        q11 = esimd::xmx::dpas<8,8,float>(q11, c1, a1);
                        esimd::slm_block_store(accb + 1024u, q00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 1280u, q01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 1536u, q10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(accb + 1792u, q11, esimd::overaligned_tag<16>{});
                        } else {
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
                        }'''
assert old in s, 'proj anchor miss'
s=s.replace(old,new)

# 4) the tail reads p00..q11: for ACCSLM load them from SLM into regs first (tail peak is OK: no expand accs live there)
old='''            size_t outb = (size_t)(tr * 16) * cin;'''
new='''            if constexpr (ACCSLM) {
                esimd::simd<float,64> p00 = esimd::slm_block_load<float,64>(accb + 0u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> p01 = esimd::slm_block_load<float,64>(accb + 256u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> p10 = esimd::slm_block_load<float,64>(accb + 512u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> p11 = esimd::slm_block_load<float,64>(accb + 768u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> q00 = esimd::slm_block_load<float,64>(accb + 1024u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> q01 = esimd::slm_block_load<float,64>(accb + 1280u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> q10 = esimd::slm_block_load<float,64>(accb + 1536u, esimd::overaligned_tag<16>{});
                esimd::simd<float,64> q11 = esimd::slm_block_load<float,64>(accb + 1792u, esimd::overaligned_tag<16>{});
                ffn_tail_regs(p00,p01,p10,p11,q00,q01,q10,q11, hs, ea, dSkip, cp, half_skip, ff9, Cout, tr, M, cin, outb0);
            } else {
            size_t outb = (size_t)(tr * 16) * cin;'''
assert old in s, 'tail anchor miss'
s=s.replace(old,new,1)
open(p,'w',encoding='utf-8').write(s)
print('ffn-18 ACCSLM wired PARTIAL (tail call stub ffn_tail_regs NOT yet defined -- will inline instead)')
