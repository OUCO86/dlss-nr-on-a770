import re

src = open('window_block_mega.hpp', 'r', encoding='utf-8').read()
assert 'cosine_recip_esimd_32' not in src

# 1) named-arg twin of cosine_recip_esimd (same op order, no arrays)
def p(lane, par):
    ch = lane*2+par
    return (f'eh_add(eh_hfma(h{ch+8},h{ch+8},eh_mul(h{ch},h{ch})),'
            f' eh_hfma(h{ch+24},h{ch+24},eh_mul(h{ch+16},h{ch+16})))')

twin = (
    "// cosine_recip_esimd_32 -- GENERATED (kdis/gen_cr32.py lineage) named-arg twin of\n"
    "// cosine_recip_esimd above: IDENTICAL operation order, 32 named floats, no array inside.\n"
    "// SPILL FIX (ISA ledger 2, 2026-10-29): the caller's h[32] escaped -> scratch 2304B/thread.\n"
    "static inline float cosine_recip_esimd_32(" + ', '.join(f'float h{i}' for i in range(32)) + ") {\n"
    "    float one00 = eh_add(eh_add(" + p(0,0) + ", " + p(2,0) + "), eh_add(" + p(1,0) + ", " + p(3,0) + "));\n"
    "    float one01 = eh_add(eh_add(" + p(0,1) + ", " + p(2,1) + "), eh_add(" + p(1,1) + ", " + p(3,1) + "));\n"
    "    float norm = eh_add(one00, one01);\n"
    "    float floorv = eh_round(ctree::COSINE_NORM_FLOOR);\n"
    "    norm = norm > floorv ? norm : floorv;\n"
    "    return eh_round(1.0f / esqrt(norm));\n"
    "}\n\n"
)
anchor = "// gate_esimd / pub_esimd: the epi2/3 gate polynomial + publish dispatch, ESIMD-native."
src = src.replace(anchor, twin + anchor, 1)

# 2) rewrite the h[32] epilogue block in launch_full (lines ~174-213)
old = """                    float h[32];
                    for (int i = 0; i < 32; ++i) h[i] = rowv[i];
                    esimd::simd<half, 32> out8;
                    if (part < 2) {
                        for (int i = 0; i < 32; ++i) h[i] = eh_round(h[i]);
                        // ctree::cosine_reciprocal order, scalar (ESIMD-native helpers)
                        float partial[4][2];
                        for (int lane = 0; lane < 4; ++lane)
                            for (int parity = 0; parity < 2; ++parity) {
                                int ch = lane * 2 + parity;
                                float first  = eh_hfma(h[ch + 8],  h[ch + 8],  eh_mul(h[ch],       h[ch]));
                                float second = eh_hfma(h[ch + 24], h[ch + 24], eh_mul(h[ch + 16], h[ch + 16]));
                                partial[lane][parity] = eh_add(first, second);
                            }
                        float two[4][2], one[4][2];
                        for (int lane = 0; lane < 4; ++lane)
                            for (int p2 = 0; p2 < 2; p2++) two[lane][p2] = eh_add(partial[lane][p2], partial[lane ^ 2][p2]);
                        for (int lane = 0; lane < 4; ++lane)
                            for (int p2 = 0; p2 < 2; p2++) one[lane][p2] = eh_add(two[lane][p2], two[lane ^ 1][p2]);
                        float norm = eh_add(one[0][0], one[0][1]);
                        float floorv = eh_round(ctree::COSINE_NORM_FLOOR);
                        norm = norm > floorv ? norm : floorv;
                        float recip = eh_round(1.0f / esqrt(norm));
                        float sc = part == 0 ? eh_round(QkvScale[0]) : 1.0f;
                        for (int i = 0; i < 32; ++i) {
                            float v = eh_mul(h[i], recip);
                            if (part == 0) v = eh_mul(v, sc);
                            out8[i] = half(qr_e4m3_scalar(v));
                        }
                        half* dst = part == 0 ? dQ : dK;
                        out8.copy_to(dst + (size_t)(row0 + lid) * 32u);
                    } else {
                        for (int i = 0; i < 32; ++i) out8[i] = half(qr_e4m3_scalar(h[i]));
                        out8.copy_to(dV + (size_t)(row0 + lid) * 32u);
                    }
"""
assert old in src, 'mega epilogue block NOT FOUND'

R = lambda i: f'rv{i}'
decl = '                    float ' + ', '.join(f'{R(i)} = rowv[{i}]' for i in range(32)) + ';\n'
rounds = ''.join(f'                        {R(i)} = eh_round({R(i)});\n' for i in range(32))
callargs = ', '.join(R(i) for i in range(32))
recip = f'                        float recip = cosine_recip_esimd_32({callargs});\n'
puts = ''.join(
    f'                        float v{i} = eh_mul({R(i)}, recip);\n'
    f'                        if (part == 0) v{i} = eh_mul(v{i}, sc);\n'
    f'                        out8[{i}] = half(qr_e4m3_scalar(v{i}));\n' for i in range(32))
vputs = ''.join(f'                        out8[{i}] = half(qr_e4m3_scalar({R(i)}));\n' for i in range(32))

new = ("""                    // SPILL FIX (ISA ledger 2, 2026-10-29): h[32] + partial/two/one arrays
                    // escaped -> scratch 2304B/thread (ze_info spill audit). Named scalars +
                    // the generated named-arg twin (identical operation order).
""" + decl +
"""                    esimd::simd<half, 32> out8;
                    if (part < 2) {
""" + rounds + recip +
"""                        float sc = part == 0 ? eh_round(QkvScale[0]) : 1.0f;
""" + puts +
"""                        half* dst = part == 0 ? dQ : dK;
                        out8.copy_to(dst + (size_t)(row0 + lid) * 32u);
                    } else {
""" + vputs + """                        out8.copy_to(dV + (size_t)(row0 + lid) * 32u);
                    }
""")
src = src.replace(old, new, 1)
open('window_block_mega.hpp', 'w', encoding='utf-8').write(src)
print('mega: applied named-scalar spill fix')
