p='gemm_f16_v1_kernel.hpp'
s=open(p,encoding='utf-8').read()
old="""                    esimd::simd<float,8> p0 = s8v8::pub_vec_v8<8>(epi, r00), p1 = s8v8::pub_vec_v8<8>(epi, r01);
                    size_t base = ob + (size_t)row0 * ldc + (unsigned)tc * TS;
                    if (narrow) { esimd::simd<half,8> h0 = esimd::convert<half>(p0), h1 = esimd::convert<half>(p1);
                        h0.copy_to(Oh + base); h1.copy_to(Oh + base + 8u); }
                    else { p0.copy_to(Of + base); p1.copy_to(Of + base + 8u); }"""
new="""                    // B3-ffn-8 (the encode-widening family, ffn-3/4 precedent):
                    // r00|r01 are ADJACENT 8-col groups of one row -> ONE 16-wide
                    // pub + ONE 16-wide store (elementwise chains = bit-identical;
                    // epi2 keeps its scalar -0.0 path via pub_vec_v8's internal
                    // branch -- the widening does NOT touch that logic).
                    { esimd::simd<float,16> rr; rr.template select<8,1>(0) = r00; rr.template select<8,1>(8) = r01;
                      esimd::simd<float,16> pp = s8v8::pub_vec_v8<16>(epi, rr);
                      size_t base = ob + (size_t)row0 * ldc + (unsigned)tc * TS;
                      if (narrow) esimd::convert<half>(pp).copy_to(Oh + base);
                      else pp.copy_to(Of + base); }"""
assert old in s, 'site1 miss'
s=s.replace(old,new)
old2="""                    esimd::simd<float,8> p0 = s8v8::pub_vec_v8<8>(epi, r10), p1 = s8v8::pub_vec_v8<8>(epi, r11);
                    size_t base = ob + (size_t)row1 * ldc + (unsigned)tc * TS;
                    if (narrow) { esimd::simd<half,8> h0 = esimd::convert<half>(p0), h1 = esimd::convert<half>(p1);
                        h0.copy_to(Oh + base); h1.copy_to(Oh + base + 8u); }
                    else { p0.copy_to(Of + base); p1.copy_to(Of + base + 8u); }"""
new2="""                    { esimd::simd<float,16> rr; rr.template select<8,1>(0) = r10; rr.template select<8,1>(8) = r11;
                      esimd::simd<float,16> pp = s8v8::pub_vec_v8<16>(epi, rr);
                      size_t base = ob + (size_t)row1 * ldc + (unsigned)tc * TS;
                      if (narrow) esimd::convert<half>(pp).copy_to(Oh + base);
                      else pp.copy_to(Of + base); }"""
assert old2 in s, 'site2 miss'
s=s.replace(old2,new2)
open(p,'w',encoding='utf-8').write(s)
print('f16_v1 pub widened')
p2='ffn_chip_kernel.hpp'
s2=open(p2,encoding='utf-8').read()
old3="""                        esimd::simd<half,8> h00 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e00.template select<8,1>(r*8)));
                        esimd::simd<half,8> h01 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e01.template select<8,1>(r*8)));
                        esimd::simd<half,8> h10 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e10.template select<8,1>(r*8)));
                        esimd::simd<half,8> h11 = esimd::convert<half>(s8v8::pub_vec_v8<8>(3u, e11.template select<8,1>(r*8)));
                        esimd::slm_block_store(hb + (uint)r * 32u, h00, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + (uint)r * 32u + 16u, h01, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, h10, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u + 16u, h11, esimd::overaligned_tag<16>{});"""
new3="""                        esimd::simd<float,16> x0, x1;
                        x0.template select<8,1>(0) = e00.template select<8,1>(r*8); x0.template select<8,1>(8) = e01.template select<8,1>(r*8);
                        x1.template select<8,1>(0) = e10.template select<8,1>(r*8); x1.template select<8,1>(8) = e11.template select<8,1>(r*8);
                        esimd::simd<half,16> hj0 = esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, x0));
                        esimd::simd<half,16> hj1 = esimd::convert<half>(s8v8::pub_vec_v8<16>(3u, x1));
                        esimd::slm_block_store(hb + (uint)r * 32u, hj0, esimd::overaligned_tag<16>{});
                        esimd::slm_block_store(hb + 256u + (uint)r * 32u, hj1, esimd::overaligned_tag<16>{});"""
assert old3 in s2, 'stem site miss'
s2=s2.replace(old3,new3)
open(p2,'w',encoding='utf-8').write(s2)
print('stem_mega pub widened')
