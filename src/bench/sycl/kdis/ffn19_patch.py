import re
src=open('ffn_chip_kernel.hpp',encoding='utf-8').read()

# Extract the whole launch_ffn_chip (template header through its closing brace) and
# build launch_ffn_chip_def: expand c-loop WITHOUT the proj kc2 block; HS becomes
# 4 tiles (1KB per c); proj-p then tail-p then proj-q then tail-q AFTER the c loop.
m=re.search(r'template <int LW, bool WSTAGE = false, int CSTOP = 0, bool ACCSLM = false>\nstatic inline event launch_ffn_chip\(.*?\n\}\n', src, re.S)
assert m, 'launch_ffn_chip not captured'
fn=m.group(0)
fn=fn.replace('launch_ffn_chip(','launch_ffn_chip_def(')

# 1) SLM: EA 1KB + HS 4KB (four c-tiles) per thread; WSTAGE unchanged 16KB.
fn=fn.replace("esimd::slm_init<(unsigned)LW * (ACCSLM ? 4096u : 2048u) + (WSTAGE ? 16384u : 0u)>();   // EA+HS (+ACC 2KB/thread, ffn-18)",
              "esimd::slm_init<(unsigned)LW * 5120u + (WSTAGE ? 16384u : 0u)>();   // EA 1KB + HS 4x1KB (ffn-19 PROJDEF) (+16KB wstage)")
# drop ACCSLM branch from the template list: keep signature but ignore
# 2) hs base: per-thread 4KB region right after EA (LW-scaled)
fn=fn.replace("uint hs = FFC_EA_OFF + (unsigned)LW * 2048u + lid * 1024u;   // the HS area follows EA (LW-scaled)   // per-thread 1KB hidden stage (this chunk)",
              "uint hs = FFC_EA_OFF + (unsigned)LW * 1024u + lid * 4096u;   // PROJDEF: 4 x 1KB HS tiles (one per c)")
# HS store offsets inside tl loop: hb = hs + tl*2*256  ->  hs + c*1024 + tl*512
fn=fn.replace("uint hb = hs + (uint)(tl * 2u) * 256u;","uint hb = hs + (uint)c * 1024u + (uint)(tl * 2u) * 512u;")
# 3) proj kc2 block lives INSIDE the c loop currently, AFTER the tl loop. In the def
#    version we move it out. The proj block text:
proj_pat = re.compile(r'\n(\s*)// \(v3: NO barrier here.*?\n\s*if constexpr \(CSTOP == 3\).*?\n(\s*#pragma unroll\n\s*for \(int kc2 = 0; kc2 < 2; \+\+kc2\) \{.*?\n\s*\}\n)', re.S)
mm=proj_pat.search(fn)
assert mm, 'proj block not found'
projblock = mm.group(2)
fn = fn[:mm.start()] + '\n' + fn[mm.end():]
# inside projblock: hs read offset ab = hs + kc2*2*256 -> per-c: hs + c*1024 + kc2*512
projblock = projblock.replace("uint ab = hs + (uint)(kc2 * 2u) * 256u;","uint ab = hsb + (uint)(kc2 * 2u) * 256u;")
# accumulator decls + tail: build the deferred sequence.
# 4) after the c loop closes (the '            }' right before the wcA/wcB hoist),
#    insert: for PH in {0,1}: {accs; for c: for kc2 proj; tail-half stores}
tail_start = fn.index('            esimd::simd<float,16> wcA, wcB;')
# the old combined tail runs until the c-loop region end; find the close of the tail
# (the line before '            }   // tile loop (persistent form)')
tail_end = fn.index('            }   // tile loop (persistent form)')
tail_old = fn[tail_start:tail_end]
# strip the old tail, replace with deferred two-phase:
decl_and_acc = '''            // ---- ffn-19 PROJDEF: two independent proj passes, 4 accs each ----
            #pragma unroll 1
            for (int ph = 0; ph < 2; ++ph) {
                esimd::simd<float,64> r0(0.f), r1(0.f), r2(0.f), r3(0.f);   // ph0: cols 0..15 / ph1: 16..31
'''
proj_for = '''                #pragma unroll 1
                for (int c = 0; c < 4; ++c) {
                    uint hsb = hs + (uint)c * 1024u;
''' + projblock + '''                }
'''
# adapt projblock for ph: the p-chain lines exist (b0/b1 + p00..) AND q-chain lines
# (c0/c1 + q00..). After our regex move, projblock still has BOTH. For ph selection:
# replace p-chain dpas targets r0..r3 guarded by ph==0; q-chain r0..r3 guarded by ph==1.
pb = projblock
pb = pb.replace('p00 = esimd','r0 = esimd').replace('p01 = esimd','r1 = esimd')
pb = pb.replace('p10 = esimd','r2 = esimd').replace('p11 = esimd','r3 = esimd')
pb = pb.replace('q00 = esimd','r0 = esimd').replace('q01 = esimd','r1 = esimd')
pb = pb.replace('q10 = esimd','r2 = esimd').replace('q11 = esimd','r3 = esimd')
pb = pb.replace('esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});',
                'if (ph == 0) {\n                    esimd::simd<half,128> b0 = WSTAGE ? esimd::slm_block_load<half,128>(wb, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});')
pb = pb.replace('r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);\n                    bb += 256;',
                'r3 = esimd::xmx::dpas<8,8,float>(r3, b1, a1);\n                    }\n                    bb += 256;')
pb = pb.replace('esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});',
                'if (ph == 1) {\n                    esimd::simd<half,128> c0 = WSTAGE ? esimd::slm_block_load<half,128>(wb + 512u, esimd::overaligned_tag<16>{}) : esimd::block_load<half,128>(bb, esimd::overaligned_tag<16>{});')
pb = pb.replace('r3 = esimd::xmx::dpas<8,8,float>(r3, c1, a1);',
                'r3 = esimd::xmx::dpas<8,8,float>(r3, c1, a1);\n                    }')
proj_for = proj_for.replace(projblock, pb)

# tail-half: from tail_old, split: ph0 uses p-accs f0/f1/g0/g1 storing oa at rb and ob? --
# rebuild tail per ph explicitly (cols: ph0 -> rb+0..15 from r0/r1 (rows 0-7) and r2/r3 (rows 8-15); ph1 -> rb+16..31)
tail_new = '''                // ---- per-pass store tail (ph0 = cols 0..15, ph1 = 16..31) ----
                esimd::simd<float,16> wcP;
                if (dSkip && ff9) wcP = esimd::block_load<float,16>(cp + (unsigned)ph * 16u, esimd::overaligned_tag<16>{});
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
'''
fn = fn[:tail_start] + decl_and_acc + proj_for + tail_new + fn[tail_end:]
# remove the pre-declared p/q accs (now per-pass):
fn = fn.replace('''            esimd::simd<float,64> p00(0.f), p01(0.f), p10(0.f), p11(0.f);   // out cols 0..15 (DCE'd under ACCSLM)
            esimd::simd<float,64> q00(0.f), q01(0.f), q10(0.f), q11(0.f);   // out cols 16..31 (DCE'd under ACCSLM)
''','')
# remove the ACCSLM zero-init block (def version has no accb):
fn = re.sub(r'\n\s*uint accb = FFC_EA_OFF[^\n]*\n\s*if constexpr \(ACCSLM\) \{.*?\n\s*\}', '', fn, flags=re.S)
# also drop the ACCSLM dpas variant if embedded (projblock came from the plain else path? the
# regex captured from the CURRENT file which contains the if constexpr(ACCSLM) blocks -- 
# strip them to keep the plain form):
fn = re.sub(r'\n\s*if constexpr \(ACCSLM\) \{.*?\n\s*\} else \{', '', fn, flags=re.S)
fn = fn.replace('template <int LW, bool WSTAGE = false, int CSTOP = 0, bool ACCSLM = false>','template <int LW, bool WSTAGE = false>')

src = src + '\n' + fn
open('ffn_chip_kernel.hpp','w',encoding='utf-8').write(src)
print('launch_ffn_chip_def appended (PROJDEF ffn-19)')
