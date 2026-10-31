p='ffn_chip_kernel.hpp'
s=open(p,encoding='utf-8').read()

cs_fn = '''
// ============================================================================
// B3-ffn-20 COLSPLIT (the ROOT-CAUSE cure the user demanded -- no pivot, fix
// the blocker): the cs5/cs6p probes read correctly: deleting EITHER proj chain
// collapses proj+tail from 0.666ms to 0.008. Not "each chain costs 0.66" but
// "12 live simd<float,64> = the spill switch flips": 8 proj accs + 4 expand
// accs -> driver scratch (global round-trips per spill touch) = the 0.65 tax.
// THE CURE: keep peak live <= 8 BY SHAPE. Thread PAIRS own one tile: the even
// thread runs expand+encode (HS -> SLM slot), a sub-group barrier publishes
// it, then even does proj cols 0..15 (4 accs) and odd does cols 16..31 (4
// accs) -- NO thread ever holds more than 4 gemm accumulators. SLM: 2KB per
// TILE-slot (EA 1KB + HS 1KB, reused per c as today) = LW*1024 total = HALF
// the current footprint (also kills the SLM-contention half of the diagnosis).
// dpas order per accumulator UNCHANGED; the tail's per-column fold keeps the
// straight-line one-FMA shape (section-75 rule). The frame walk's 1301 is the
// correctness judge; bench_b3 prices it BEFORE the dll.
template <int LW, bool WSTAGE = false>
static inline event launch_ffn_chip_cs(queue& q, const half* dA, const half* dEp,
                                    const half* dPp, float* Cout, int M, int Mp,
                                    const void* dSkip = nullptr, const float* cp = nullptr,
                                    bool half_skip = false,
                                    bool pw16 = true,
                                    bool ff9 = true) {
    const unsigned cin = 32;
    int tiles = Mp / 16;
    const int TSL = LW / 2;                       // tile slots per WG (thread PAIRS)
    int wgs = (tiles + TSL - 1) / TSL;
    return q.submit([&](handler& h) {
        h.parallel_for(nd_range(range((size_t)wgs * (unsigned)LW), range((unsigned)LW)),
            [=](nd_item<1> it) SYCL_ESIMD_KERNEL {
            esimd::slm_init<(unsigned)LW * 1024u + (WSTAGE ? 16384u : 0u)>();   // 2KB per TILE slot (LW/2 of them) + weights
            uint wg = (uint)it.get_group(0);
            uint lid = (uint)it.get_local_id(0);
            const uint tsl = lid >> 1;            // slot index within the WG
            const uint ph  = lid & 1u;            // 0 = cols 0..15 (p-chain), 1 = 16..31 (q-chain)
            int tr = (int)(wg * (unsigned)TSL + tsl);
            const bool ours = (tr < tiles);       // guard WORK, never the barrier (hang lesson)
            uint ea = tsl * 2048u;
            uint hs = ea + 1024u;
            uint wsb = (unsigned)LW * 1024u;
            // ---- A staging into the slot's EA (even thread of the pair) ----
            if (ours && ph == 0u) {
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<half,32> v((half)0.f);
                    if (tr * 16 + r < (int)M)
                        v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + r) * cin, esimd::overaligned_tag<16>{});
                    esimd::simd<half,16> lo0 = v.template select<16,1>(0), hi0 = v.template select<16,1>(16);
                    esimd::slm_block_store(ea + (uint)r*32u, lo0, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 512u + (uint)r*32u, hi0, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int r = 0; r < 8; ++r) {
                    esimd::simd<half,32> v((half)0.f);
                    if (tr * 16 + 8 + r < (int)M)
                        v = esimd::block_load<half,32>(dA + (size_t)(tr * 16 + 8 + r) * cin, esimd::overaligned_tag<16>{});
                    esimd::simd<half,16> lo1 = v.template select<16,1>(0), hi1 = v.template select<16,1>(16);
                    esimd::slm_block_store(ea + 256u + (uint)r*32u, lo1, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(ea + 768u + (uint)r*32u, hi1, esimd::overaligned_tag<16>{});
                }
            }
            if (WSTAGE) {
                #pragma unroll
                for (int i = 0; i < 2; ++i) {
                    uint off = (uint)(lid * 256u + i * 128u);
                    esimd::simd<half,128> wv = esimd::block_load<half,128>(dEp + off, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(wsb + off * 2u, wv, esimd::overaligned_tag<16>{});
                }
                #pragma unroll
                for (int i = 0; i < 2; ++i) {
                    uint off = (uint)(lid * 256u + i * 128u);
                    esimd::simd<half,128> wv = esimd::block_load<half,128>(dPp + off, esimd::overaligned_tag<16>{});
                    esimd::slm_block_store(wsb + 8192u + off * 2u, wv, esimd::overaligned_tag<16>{});
                }
            }
            esimd::barrier();                     // EA (+weights) visible to the pair
            // 4 accumulators per thread (NOT 8): ph selects which output half.
            esimd::simd<float,64> r0(0.f), r1(0.f), r2(0.f), r3(0.f);
            const esimd::simd<half,8> z8((half)0.f);
            for (int c = 0; c < 4; ++c) {
                // ---- expand+encode: even thread of the pair ONLY ----
                if (ours && ph == 0u) {
                    for (int tl = 0; tl < 2; ++tl) {
                        esimd::simd<float,64> e00(0.f), e01(0.f), e10(0.f), e11(0.f);
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
                            e00 = esimd::xmx::dpas<8,8,float>(e00, b0, a0);
                            e01 = esimd::xmx::dpas<8,8,float>(e01, b1, a0);
                            e10 = esimd::xmx::dpas<8,8,float>(e10, b0, a1);
                            e11 = esimd::xmx::dpas<8,8,float>(e11, b1, a1);
                        }
                        uint hb = hs + (uint)(tl * 2u) * 256u;
                        if (pw16 && (tr + 1) * 16 <= (int)M) {
                            #pragma unroll
                            for (int r = 0; r < 8; ++r) {
                                esimd::simd<float,16> a0;
                                a0.template select<8,1>(0) = e00.template select<8,1>(r*8);
                                a0.template select<8,1>(8) = e01.template select<8,1>(r*8);
                                esimd::slm_block_store(hb + (uint)r * 32u,
                                    esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, a0)), esimd::overaligned_tag<16>{});
                                esimd::simd<float,16> a1;
                                a1.template select<8,1>(0) = e10.template select<8,1>(r*8);
                                a1.template select<8,1>(8) = e11.template select<8,1>(r*8);
                                esimd::slm_block_store(hb + 256u + (uint)r * 32u,
                                    esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, a1)), esimd::overaligned_tag<16>{});
                            }
                        } else {
                            #pragma unroll
                            for (int r = 0; r < 8; ++r) {
                                bool in0 = (tr * 16 + r) < (int)M, in1 = (tr * 16 + 8 + r) < (int)M;
                                esimd::simd<half,8> h00, h01, h10, h11;
                                if (in0) { esimd::simd<float,8> a = e00.template select<8,1>(r*8), b = e01.template select<8,1>(r*8);
                                    h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                                    h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                                else { h00 = z8; h01 = z8; }
                                if (in1) { esimd::simd<float,8> a = e10.template select<8,1>(r*8), b = e11.template select<8,1>(r*8);
                                    h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, a));
                                    h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, b)); }
                                else { h10 = z8; h11 = z8; }
                                esimd::slm_block_store(hb + (uint)r * 32u, h00, esimd::overaligned_tag<16>{});
                                esimd::slm_block_store(hb + (uint)r * 32u + 16u, h01, esimd::overaligned_tag<16>{});
                                esimd::slm_block_store(hb + 256u + (uint)r * 32u, h10, esimd::overaligned_tag<16>{});
                                esimd::slm_block_store(hb + 256u + (uint)r * 32u + 16u, h11, esimd::overaligned_tag<16>{});
                            }
                        }
                    }
                }
                esimd::barrier();                 // HS[c] of the pair visible to BOTH threads
                // ---- proj: each thread of the pair takes its 16-column half ----
                if (ours) {
                    #pragma unroll
                    for (int kc2 = 0; kc2 < 2; ++kc2) {
                        uint kcg = (uint)(c * 2 + kc2);
                        uint ab = hs + (uint)(kc2 * 2u) * 256u;
                        esimd::simd<half,128> a0 = esimd::slm_block_load<half,128>(ab, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> a1 = esimd::slm_block_load<half,128>(ab + 256u, esimd::overaligned_tag<16>{});
                        const half* bb = dPp + ((size_t)kcg * 2u + ph) * 2u * 128u;
                        uint wb = wsb + 8192u + kcg * 1024u + ph * 512u;
                        esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});
                        esimd::simd<half,128> b1 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 256u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb + 128, esimd::overaligned_tag<16>{});
                        r0 = esimd::xmx::dpas<8,8,float>(r0, b0, a0);
                        r1 = esimd::xmx::dpas<8,8,float>(r1, b1, a0);
                        r2 = esimd::xmx::dpas<8,8,float>(r2, b0, a1);
                        r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);
                    }
                }
            }
            // ---- per-half store tail (straight-line one-FMA shape, section-75) ----
            if (ours) {
                esimd::simd<float,16> wcP;
                if (dSkip && ff9) wcP = esimd::block_load<float,16>(cp + ph * 16u, esimd::overaligned_tag<16>{});
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
            }
        });
    });
}
'''
# insert right BEFORE the stem_mega comment block
anchor = '\n// P8-n / B1 BRICK 1 (section 100): the STEM MEGAKERNEL'
assert anchor in s
s = s.replace(anchor, cs_fn + anchor)
open(p,'w',encoding='utf-8').write(s)
print('launch_ffn_chip_cs appended')
