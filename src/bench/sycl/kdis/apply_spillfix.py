import io, re

# 1) insert cosine_reciprocal_32 into cosine_tree_kernel.hpp
ct = open('cosine_tree_kernel.hpp', 'r', encoding='utf-8')
src = ct.read(); ct.close()
snippet = open('kdis/cr32_snippet.txt', 'r', encoding='utf-8').read()
sn = '\n'.join(l[4:] if l.startswith('    ') else l for l in snippet.split('\n'))
anchor = '// cosine_tree.glsl:47-54, the ViT variant (opendlss_reference), verbatim.'
assert 'cosine_reciprocal_32' not in src, 'already inserted'
src = src.replace(anchor, sn + '\n\n' + anchor, 1)
open('cosine_tree_kernel.hpp', 'w', encoding='utf-8').write(src)
print('ct: inserted cosine_reciprocal_32')

# 2) rewrite the hv[32] block in window_block_resident.hpp  (scalars named rv0..rv31 to avoid
#    shadowing the existing `half* h16` SLM pointer)
wr = open('window_block_resident.hpp', 'r', encoding='utf-8')
w = wr.read(); wr.close()

old = """                    float hv[32];
                    for (int c = 0; c < 32; ++c) hv[c] = f32[scratch + local*32u + c];
                    half* dst = (part == 0u) ? (h16 + QSTASH + 256u*sub + local*32u)
                            : (part == 1u) ? (h16 + KSTASH + (row + local) * 32u)
                            : (h16 + VSTASH + (row + local) * 32u);
                    if (part < 2u) {
                        for (int c = 0; c < 32; ++c) hv[c] = qr_half_round(hv[c]);
                        float recip = ctree::cosine_reciprocal(hv);   // the golden's exact chain
                        float scale = part == 0u ? qr_half_round(QkvScale[0]) : 1.0f;
                        for (int c = 0; c < 32; ++c) {
                            float value = ctree::cr_hmul(hv[c], recip);
                            if (part == 0u) value = ctree::cr_hmul(value, scale);
                            dst[c] = half(qr_e4m3(value));
                        }
                    } else {
                        for (int c = 0; c < 32; ++c) dst[c] = half(qr_e4m3(hv[c]));
                    }
"""
assert old in w, 'WR block NOT FOUND'

R = lambda i: f'rv{i}'
H = lambda i: f'h{i}'
decl = '                    float ' + ', '.join(f'{R(i)} = f32[scratch + local*32u + {i}u]' for i in range(32)) + ';\n'
rounds = ''.join(f'                        {R(i)} = qr_half_round({R(i)});\n' for i in range(32))
callargs = ', '.join(R(i) for i in range(32))
recip = f'                        float recip = ctree::cosine_reciprocal_32({callargs});\n'
puts = ''.join(
    f'                        float v{i} = ctree::cr_hmul({R(i)}, recip);\n'
    f'                        if (part == 0u) v{i} = ctree::cr_hmul(v{i}, scale);\n'
    f'                        dst[{i}] = half(qr_e4m3(v{i}));\n' for i in range(32))
vputs = ''.join(f'                        dst[{i}] = half(qr_e4m3({R(i)}));\n' for i in range(32))

new = ("""                    // SPILL FIX (ISA ledger 2, 2026-10-29): this hv[32] array escaped its
                    // element indexing -> private_size=1792B (=32*4*8) + scratch 8192B/thread +
                    // 311 scratch msgs in the GEN asm. 32 named scalars (rv0..rv31; NOT hvN --
                    // the outer half* h16 SLM pointer would be shadowed) + the GENERATED
                    // named-arg twin of the golden's tree (cosine_reciprocal_32, kdis/gen_cr32.py;
                    // identical operation ORDER). K's scale==1.0f multiply is bit-neutral:
                    // cr_hmul(half-representable x, 1.0f) == x exactly.
""" + decl +
"""                    half* dst = (part == 0u) ? (h16 + QSTASH + 256u*sub + local*32u)
                            : (part == 1u) ? (h16 + KSTASH + (row + local) * 32u)
                            : (h16 + VSTASH + (row + local) * 32u);
                    if (part < 2u) {
""" + rounds + recip +
"""                        float scale = part == 0u ? qr_half_round(QkvScale[0]) : 1.0f;
""" + puts +
"""                    } else {
""" + vputs + """                    }
""")

w = w.replace(old, new, 1)
open('window_block_resident.hpp', 'w', encoding='utf-8').write(w)
print('wr: rewrote hv[32] -> 32 named scalars (rv0..rv31)')
